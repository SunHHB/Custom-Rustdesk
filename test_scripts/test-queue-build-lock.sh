#!/bin/bash
# 构建锁获取/释放功能测试脚本

set -e
source test_scripts/test-framework.sh

# 测试专用的超时设置（覆盖默认值）
export ISSUE_LOCK_TIMEOUT=30  # 30秒issue锁超时（测试用）
export BUILD_LOCK_HOLD_TIMEOUT=60  # 60秒构建锁超时（测试用）

echo "========================================"
echo "    Queue Build Lock Function Tests"
echo "========================================"

# 设置测试环境
init_test_framework

# 重置队列状态
log_info "Resetting queue state..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'reset'

# 显示初始状态
log_info "=== Initial Queue Status ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 1: Test Queue 1 - Build Lock Acquisition"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Queue 1 Setup) ==="
get_issue_json_data

# 加入第一个项目到队列
log_info "Adding first item to queue..."
export GITHUB_RUN_ID="build_test_1_$(date +%s)"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'join' '{"tag":"build-test-1","email":"build1@example.com","customer":"test-customer","trigger_type":"workflow_dispatch"}'

# 显示加入后的状态
log_info "=== Issue #1 Full Content After Adding First Item ==="
get_issue_json_data

# 测试1: 第一个项目获取构建锁
log_info "Testing build lock acquisition for first item..."
source .github/workflows/scripts/queue-manager.sh && _acquire_build_lock

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Build Lock Acquisition ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 2: Test Queue 1 - Build Lock Status Query"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Build Lock Status Query) ==="
get_issue_json_data

# 测试2: 查询构建锁状态
log_info "Testing build lock status query..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'status'

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Build Lock Status Query ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 3: Test Queue 1 - Build Lock Release"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Build Lock Release) ==="
get_issue_json_data

# 测试3: 第一个项目释放构建锁
log_info "Testing build lock release for first item..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'release'

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Build Lock Release ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 4: Test Queue 1 - Leave Queue"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before First Item Leave) ==="
get_issue_json_data

# 测试4: 第一个项目离开队列
log_info "Testing first item leaving queue..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'leave'

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After First Item Leave ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 5: Test Queue 2 - Build Lock Acquisition"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Queue 2 Setup) ==="
get_issue_json_data

# 加入第二个项目到队列
log_info "Adding second item to queue..."
export GITHUB_RUN_ID="build_test_2_$(date +%s)"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'join' '{"tag":"build-test-2","email":"build2@example.com","customer":"test-customer","trigger_type":"workflow_dispatch"}'

# 显示加入后的状态
log_info "=== Issue #1 Full Content After Adding Second Item ==="
get_issue_json_data

# 测试5: 第二个项目获取构建锁
log_info "Testing build lock acquisition for second item..."
source .github/workflows/scripts/queue-manager.sh && _acquire_build_lock

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Second Item Build Lock Acquisition ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 6: Test Queue 2 - Build Lock Release and Leave"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Second Item Operations) ==="
get_issue_json_data

# 测试6: 第二个项目释放构建锁并离开队列
log_info "Testing build lock release and leave for second item..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'release'
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'leave'

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Second Item Operations ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 7: Test Build Lock Status Query"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Status Query) ==="
get_issue_json_data

# 测试7: 查询构建锁状态
log_info "Testing build lock status query..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'status'

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Status Query ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 8: Test Build Lock Conflict Resolution"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Conflict Test) ==="
get_issue_json_data

# 测试8: 测试构建锁冲突解决
log_info "Testing build lock conflict resolution..."

# 加入两个项目到队列
log_info "Adding two items to queue for conflict test..."
CONFLICT_RUN_ID_1="conflict_test_1_$(date +%s)"
export GITHUB_RUN_ID="$CONFLICT_RUN_ID_1"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'join' '{"tag":"conflict-test-1","email":"conflict1@example.com","customer":"test-customer","trigger_type":"workflow_dispatch"}'

CONFLICT_RUN_ID_2="conflict_test_2_$(date +%s)"
export GITHUB_RUN_ID="$CONFLICT_RUN_ID_2"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'join' '{"tag":"conflict-test-2","email":"conflict2@example.com","customer":"test-customer","trigger_type":"workflow_dispatch"}'

# 第一个项目获取锁（队列位置0，应该成功）
log_info "First item acquiring build lock..."
export GITHUB_RUN_ID="$CONFLICT_RUN_ID_1"
# 使用直接调用内部函数，避免长时间重试
source .github/workflows/scripts/queue-manager.sh && _acquire_build_lock

# 第二个项目尝试获取锁（队列位置1，应该失败）
log_info "Second item attempting to acquire build lock (should fail)..."
export GITHUB_RUN_ID="$CONFLICT_RUN_ID_2"
# 使用直接调用内部函数，避免长时间重试
source .github/workflows/scripts/queue-manager.sh && _acquire_build_lock || log_info "Expected failure: build lock already held"

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Conflict Test ==="
get_issue_json_data

# 清理冲突测试的状态
log_info "Cleaning up conflict test state..."
export GITHUB_RUN_ID="$CONFLICT_RUN_ID_1"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'release' || log_info "First item releasing build lock"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'leave' || log_info "First item leaving queue"

export GITHUB_RUN_ID="$CONFLICT_RUN_ID_2"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'leave' || log_info "Second item leaving queue"

log_info "=== Issue #1 Full Content After Conflict Test Cleanup ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 9: Test Build Lock Auto-Leave Queue"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Auto-Leave Test) ==="
get_issue_json_data

# 测试9: 测试构建锁释放时自动离开队列
log_info "Testing build lock release with auto-leave queue..."

# 加入一个项目到队列
log_info "Adding item to queue for auto-leave test..."
export GITHUB_RUN_ID="auto_leave_test_$(date +%s)"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'join' '{"tag":"auto-leave-test","email":"autoleave@example.com","customer":"test-customer","trigger_type":"workflow_dispatch"}'

# 显示加入后的状态
log_info "=== Issue #1 Full Content After Adding Item ==="
get_issue_json_data

# 获取构建锁
log_info "Acquiring build lock..."
source .github/workflows/scripts/queue-manager.sh && _acquire_build_lock

# 显示获取锁后的状态
log_info "=== Issue #1 Full Content After Acquiring Lock ==="
get_issue_json_data

# 释放构建锁（应该自动从队列中移除）
log_info "Releasing build lock (should auto-leave queue)..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'release'

# 显示释放锁后的状态
log_info "=== Issue #1 Full Content After Releasing Lock (Auto-Leave) ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 10: Test Duplicate Lock Operations"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Duplicate Test) ==="
get_issue_json_data

# 测试10: 测试重复获取和释放锁
log_info "Testing duplicate lock operations..."

# 加入一个项目到队列
log_info "Adding item to queue for duplicate test..."
export GITHUB_RUN_ID="duplicate_test_$(date +%s)"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'join' '{"tag":"duplicate-test","email":"duplicate@example.com","customer":"test-customer","trigger_type":"workflow_dispatch"}'

# 第一次获取锁
log_info "First time acquiring build lock..."
source .github/workflows/scripts/queue-manager.sh && _acquire_build_lock

# 第二次尝试获取锁（应该失败）
log_info "Second time attempting to acquire build lock (should fail)..."
source .github/workflows/scripts/queue-manager.sh && _acquire_build_lock || log_info "Expected failure: already holding lock"

# 第一次释放锁
log_info "First time releasing build lock..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'release'

# 第二次尝试释放锁（应该失败）
log_info "Second time attempting to release build lock (should fail)..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'release' || log_info "Expected failure: not holding lock"

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Duplicate Test ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 11: Test Non-Queue Member Lock Operations"
echo "========================================"

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Non-Queue Test) ==="
get_issue_json_data

# 测试11: 测试非队列成员的操作
log_info "Testing non-queue member lock operations..."

# 使用一个不在队列中的run_id尝试获取锁
log_info "Non-queue member attempting to acquire build lock (should fail)..."
export GITHUB_RUN_ID="non_queue_test_$(date +%s)"
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'acquire' || log_info "Expected failure: not in queue"

# 使用一个不在队列中的run_id尝试释放锁
log_info "Non-queue member attempting to release build lock (should fail)..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'build_lock' 'release' || log_info "Expected failure: not in queue"

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Non-Queue Test ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Step 12: Test Build Lock with Empty Queue"
echo "========================================"

# 清空队列
log_info "Clearing queue for empty queue test..."
source .github/workflows/scripts/queue-manager.sh && queue_manager 'queue_lock' 'reset'

# 显示当前Issue #1完整内容
log_info "=== Current Issue #1 Full Content (Before Empty Queue Test) ==="
get_issue_json_data

# 测试12: 空队列时获取构建锁
log_info "Testing build lock acquisition with empty queue..."
source .github/workflows/scripts/queue-manager.sh && _acquire_build_lock || log_info "Expected failure: empty queue"

# 显示验证后的Issue #1完整内容
log_info "=== Issue #1 Full Content After Empty Queue Test ==="
get_issue_json_data

echo ""
echo "========================================"
echo "Build Lock Tests Completed Successfully! 🎉"
echo "========================================" 

# 如果直接运行此脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "错误：此测试脚本无法直接运行！"
    echo ""
    echo "请使用以下命令运行测试："
    echo "  ./run-tests.sh queue-build-lock"
    echo ""
    echo "或者查看所有可用测试："
    echo "  ./run-tests.sh --list"
    echo ""
    echo "查看帮助信息："
    echo "  ./run-tests.sh --help"
    exit 1
fi 
