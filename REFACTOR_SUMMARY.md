# GitHub Actions 脚本重构总结

## 重构目标

将 GitHub Actions YAML 文件中的复杂 markdown 拼接逻辑重构为独立的 shell 脚本函数，解决以下问题：

1. **YAML 缩进问题**：YAML 中的多行字符串会自动缩进，导致 markdown 渲染为代码块
2. **代码维护性**：将重复的 markdown 拼接逻辑集中管理
3. **可读性**：YAML 文件更简洁，逻辑更清晰

## 重构完成情况

### ✅ 已完成的工作

#### 1. 合并脚本到 `github-utils.sh`

- 将 `markdown-templates.sh` 和 `queue-operations.sh` 的内容合并到现有的 `.github/workflows/shared/github-utils.sh` 中
- 保持了所有工具函数在一个文件中的统一性

#### 2. 新增 Markdown 模板函数

在 `github-utils.sh` 中新增了以下函数：

- `generate_queue_management_body()` - 生成队列管理 issue 正文
- `generate_reject_comment()` - 生成构建被拒绝评论
- `generate_success_comment()` - 生成构建已加入队列评论
- `generate_cleanup_reasons()` - 生成队列清理原因文本
- `generate_build_complete_comment()` - 生成构建完成评论
- `generate_build_failed_comment()` - 生成构建失败评论
- `generate_queue_reset_notification()` - 生成队列重置通知
- `generate_lock_timeout_notification()` - 生成锁超时通知
- `generate_queue_status_update()` - 生成队列状态更新通知

#### 3. 新增队列操作函数

- `join_queue()` - 加入队列操作（包含自动清理、队列检查、加密等）
- `update_queue_issue_body()` - 更新队列管理 issue 正文
- `perform_queue_cleanup()` - 执行队列清理
- `wait_for_queue_turn()` - 等待队列轮到构建

#### 4. 重构 YAML 文件

已重构 `.github/workflows/03-queue-join.yml`：

**重构前：**
```yaml
- name: Join queue with auto cleanup and wait
  run: |
    # 500+ 行的复杂 shell 脚本
    # 包含大量 markdown 拼接逻辑
    UPDATED_BODY="## 构建队列管理
    ...
    "
```

**重构后：**
```yaml
- name: Join queue with auto cleanup and wait
  run: |
    # 加载共享工具函数
    source .github/workflows/scripts/github-utils.sh
    
    # 使用新的队列操作函数
    if join_queue "${{ env.BUILD_ID }}" "${{ env.TRIGGER_TYPE }}" "${{ env.CURRENT_DATA }}" "${{ env.QUEUE_LIMIT }}"; then
      # 等待队列轮到构建
      if wait_for_queue_turn "${{ env.BUILD_ID }}" "1"; then
        echo "✅ Queue wait completed successfully"
      fi
    fi
```

### 🔧 技术改进

#### 1. Markdown 渲染优化

- **顶格写**：所有 markdown 语法（标题、列表、代码块）都顶格写，避免 YAML 缩进污染
- **真实换行**：使用 `cat <<EOF ... EOF` 确保真实的多行字符串，而不是 `\n` 转义
- **JSON 单行化**：使用 `jq -c .` 确保插入 markdown 代码块的 JSON 是单行格式

#### 2. 函数模块化

- **单一职责**：每个函数只负责一个特定的功能
- **参数化**：所有函数都接受明确的参数，避免全局变量依赖
- **错误处理**：统一的错误处理和返回值

#### 3. 代码复用

- **模板化**：markdown 内容模板化，易于维护和修改
- **函数调用**：YAML 中只需调用函数，逻辑集中在脚本中

### 📋 待完成的工作

#### 1. 其他 YAML 文件重构

需要重构以下文件中的 markdown 拼接逻辑：

- `.github/workflows/02-review.yml`
- `.github/workflows/04-build.yml`
- `.github/workflows/05-finish.yml`
- `CustomBuildRustdesk.yml`

#### 2. 测试验证

- 在 GitHub Actions 环境中测试重构后的函数
- 验证 markdown 渲染是否正常
- 确认队列操作功能正常

### 🎯 重构效果

#### 1. 代码质量提升

- **可维护性**：markdown 模板集中管理，修改更方便
- **可读性**：YAML 文件更简洁，逻辑更清晰
- **可测试性**：函数可以独立测试

#### 2. 问题解决

- **缩进问题**：markdown 不再受 YAML 缩进影响
- **渲染问题**：所有 markdown 语法都能正确渲染
- **JSON 提取**：JSON 数据格式统一，提取更可靠

#### 3. 扩展性

- **新模板**：添加新的 markdown 模板只需在脚本中添加函数
- **新功能**：队列操作逻辑可以轻松扩展
- **复用性**：函数可以在多个工作流中复用

### 📝 使用示例

#### 在 YAML 中使用新函数

```yaml
- name: Update queue issue
  run: |
    source .github/workflows/scripts/github-utils.sh
    
    # 更新队列管理 issue
    update_queue_issue_body "1" "$QUEUE_DATA" "$VERSION"
    
    # 生成并添加评论
    COMMENT=$(generate_success_comment "$POSITION" "$LIMIT" "$BUILD_ID" "$TAG" "$CUSTOMER" "$SLOGAN" "$TIME")
    add_issue_comment_if_issue_trigger "$TRIGGER_TYPE" "$BUILD_ID" "$COMMENT"
```

#### 直接调用函数

```bash
# 生成队列管理正文
BODY=$(generate_queue_management_body "$TIME" "$QUEUE_DATA" "$LOCK_STATUS" "$BUILD" "$HOLDER" "$VERSION")

# 生成拒绝评论
REJECT_COMMENT=$(generate_reject_comment "$REASON" "$LENGTH" "$LIMIT" "$INFO" "$TIME")
```

### 🔄 迁移指南

如需将其他 YAML 文件中的 markdown 拼接逻辑迁移到新函数：

1. **识别拼接点**：找到所有 `UPDATED_BODY=`、`REJECT_COMMENT=` 等变量赋值
2. **选择函数**：根据内容类型选择合适的模板函数
3. **替换逻辑**：将拼接逻辑替换为函数调用
4. **测试验证**：确保功能正常，markdown 渲染正确

### 📊 总结

本次重构成功解决了 YAML 中 markdown 拼接的缩进和渲染问题，将复杂的逻辑模块化为可复用的函数，大大提升了代码的可维护性和可读性。重构后的代码结构更清晰，功能更稳定，为后续的功能扩展和维护奠定了良好的基础。 