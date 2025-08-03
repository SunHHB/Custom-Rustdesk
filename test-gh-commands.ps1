# GitHub CLI ���Խű� (PowerShell�汾)
# ���Ը���gh�����

# ����gh�����Ƿ����
function Test-GHCommand {
    Write-Host "=== ����gh��������� ===" -ForegroundColor Cyan
    
    try {
        $version = gh --version
        Write-Host "? GitHub CLI �Ѱ�װ" -ForegroundColor Green
        Write-Host $version -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "? GitHub CLI δ��װ�򲻿���" -ForegroundColor Red
        Write-Host "�밲װ: https://cli.github.com/" -ForegroundColor Yellow
        return $false
    }
}

# ����gh��֤״̬
function Test-GHAuth {
    Write-Host "`n=== ����gh��֤״̬ ===" -ForegroundColor Cyan
    
    try {
        $auth = gh auth status
        Write-Host "? GitHub CLI ����֤" -ForegroundColor Green
        Write-Host $auth -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "? GitHub CLI δ��֤" -ForegroundColor Red
        Write-Host "������: gh auth login" -ForegroundColor Yellow
        return $false
    }
}

# ���Բֿ���Ϣ
function Test-RepoInfo {
    Write-Host "`n=== ���Բֿ���Ϣ ===" -ForegroundColor Cyan
    
    try {
        $repo = gh repo view --json name,description,url,defaultBranchRef
        Write-Host "? �ɹ���ȡ�ֿ���Ϣ" -ForegroundColor Green
        Write-Host $repo -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "? ��ȡ�ֿ���Ϣʧ��" -ForegroundColor Red
        return $false
    }
}

# ���Թ������б�
function Test-Workflows {
    Write-Host "`n=== ���Թ������б� ===" -ForegroundColor Cyan
    
    try {
        $workflows = gh workflow list
        Write-Host "? �ɹ���ȡ�������б�" -ForegroundColor Green
        Write-Host $workflows -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "? ��ȡ�������б�ʧ��" -ForegroundColor Red
        return $false
    }
}

# ����Issues�б�
function Test-Issues {
    Write-Host "`n=== ����Issues�б� ===" -ForegroundColor Cyan
    
    try {
        $issues = gh issue list --limit 5
        Write-Host "? �ɹ���ȡIssues�б�" -ForegroundColor Green
        Write-Host $issues -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "? ��ȡIssues�б�ʧ��" -ForegroundColor Red
        return $false
    }
}

# ���Թ�����������ʷ
function Test-WorkflowRuns {
    Write-Host "`n=== ���Թ�����������ʷ ===" -ForegroundColor Cyan
    
    try {
        $runs = gh run list --limit 5
        Write-Host "? �ɹ���ȡ������������ʷ" -ForegroundColor Green
        Write-Host $runs -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "? ��ȡ������������ʷʧ��" -ForegroundColor Red
        return $false
    }
}

# �����ض�������
function Test-SpecificWorkflow {
    param([string]$WorkflowName)
    
    Write-Host "`n=== �����ض�������: $WorkflowName ===" -ForegroundColor Cyan
    
    try {
        $workflow = gh workflow view "$WorkflowName.yml" --json name,state,path
        Write-Host "? �ɹ���ȡ��������Ϣ" -ForegroundColor Green
        Write-Host $workflow -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "? ��ȡ��������Ϣʧ��" -ForegroundColor Red
        return $false
    }
}

# ���Թ�������������ʵ��ִ�У�
function Test-WorkflowTrigger {
    param([string]$WorkflowName)
    
    Write-Host "`n=== ���Թ���������: $WorkflowName ===" -ForegroundColor Cyan
    
    try {
        # ֻ��鹤�����Ƿ���ڣ���ʵ�ʴ���
        $workflow = gh workflow view "$WorkflowName.yml" --json name
        Write-Host "? ������ $WorkflowName ���ڣ����Դ���" -ForegroundColor Green
        Write-Host "Ҫʵ�ʴ�����������: gh workflow run '$WorkflowName.yml'" -ForegroundColor Yellow
        return $true
    }
    catch {
        Write-Host "? ������ $WorkflowName �����ڻ��޷�����" -ForegroundColor Red
        return $false
    }
}

# ���Բֿ�״̬
function Test-RepoStatus {
    Write-Host "`n=== ���Բֿ�״̬ ===" -ForegroundColor Cyan
    
    try {
        $status = gh repo sync
        Write-Host "? �ֿ�ͬ���ɹ�" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "? �ֿ�ͬ��ʧ��" -ForegroundColor Red
        return $false
    }
}

# �����Ժ���
function Main-Test {
    Write-Host "��ʼGitHub CLI���ܲ���..." -ForegroundColor Magenta
    Write-Host "==========================================" -ForegroundColor Magenta
    
    $results = @{}
    
    # ��������
    $results["GHCommand"] = Test-GHCommand
    if (-not $results["GHCommand"]) {
        Write-Host "`n��������ʧ�ܣ�ֹͣ��������" -ForegroundColor Red
        return
    }
    
    $results["GHAuth"] = Test-GHAuth
    if (-not $results["GHAuth"]) {
        Write-Host "`n��֤����ʧ�ܣ����ֹ��ܿ��ܲ�����" -ForegroundColor Yellow
    }
    
    # ���ܲ���
    $results["RepoInfo"] = Test-RepoInfo
    $results["Workflows"] = Test-Workflows
    $results["Issues"] = Test-Issues
    $results["WorkflowRuns"] = Test-WorkflowRuns
    
    # �����ض�������
    $results["CustomBuildRustdesk"] = Test-SpecificWorkflow "CustomBuildRustdesk"
    $results["DeleteIssues"] = Test-WorkflowTrigger "99-delete_issues"
    $results["DeleteWorkflowRuns"] = Test-WorkflowTrigger "99-delete_workflow_runs"
    
    # �ֿ�״̬����
    $results["RepoStatus"] = Test-RepoStatus
    
    # ������Խ��ժҪ
    Write-Host "`n==========================================" -ForegroundColor Magenta
    Write-Host "���Խ��ժҪ:" -ForegroundColor Magenta
    
    foreach ($test in $results.Keys) {
        $status = if ($results[$test]) { "? ͨ��" } else { "? ʧ��" }
        $color = if ($results[$test]) { "Green" } else { "Red" }
        Write-Host "  $test`: $status" -ForegroundColor $color
    }
    
    # ͳ�ƽ��
    $passed = ($results.Values | Where-Object { $_ -eq $true }).Count
    $total = $results.Count
    $percentage = [math]::Round(($passed / $total) * 100, 1)
    
    Write-Host "`n������: $passed/$total ����ͨ�� ($percentage%)" -ForegroundColor $(if ($percentage -ge 80) { "Green" } elseif ($percentage -ge 60) { "Yellow" } else { "Red" })
    
    # �ṩ����
    Write-Host "`n����:" -ForegroundColor Cyan
    if ($results["GHAuth"] -eq $false) {
        Write-Host "  - ���� 'gh auth login' ������֤" -ForegroundColor Yellow
    }
    if ($results["CustomBuildRustdesk"] -eq $false) {
        Write-Host "  - ��� CustomBuildRustdesk.yml �������Ƿ����" -ForegroundColor Yellow
    }
    if ($results["DeleteIssues"] -eq $false -or $results["DeleteWorkflowRuns"] -eq $false) {
        Write-Host "  - ������������ļ��Ƿ����" -ForegroundColor Yellow
    }
}

# ������
try {
    Main-Test
}
catch {
    Write-Host "`n���Թ����з�������: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 