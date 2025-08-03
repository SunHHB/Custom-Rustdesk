# ͳһ�����������Խű� (PowerShell�汾)
# �������в��Թ��ܣ������˵�ѡ��

# ����debugģʽ
$env:ACTIONS_STEP_DEBUG = "true"
$env:ACTIONS_RUNNER_DEBUG = "true"

Write-Host "=== ͳһ�����������Խű� ===" -ForegroundColor Magenta
Write-Host "Debugģʽ������" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Magenta

# ��ʾ�˵�
function Show-Menu {
    Write-Host "`nѡ���������:" -ForegroundColor Cyan
    Write-Host "1. workflow_dispatch ��������" -ForegroundColor White
    Write-Host "2. issues ��������" -ForegroundColor White
    Write-Host "3. �鿴���¹���������" -ForegroundColor White
    Write-Host "4. ��ع���������״̬" -ForegroundColor White
    Write-Host "5. �鿴��������־" -ForegroundColor White
    Write-Host "6. �����������" -ForegroundColor White
    Write-Host "7. ����ģ����� (workflow_dispatch + issues)" -ForegroundColor White
    Write-Host "0. �˳�" -ForegroundColor Red
    Write-Host ""
}

# workflow_dispatch��������
function Test-WorkflowDispatch {
    Write-Host "`n=== workflow_dispatch �������� ===" -ForegroundColor Cyan
    
    $inputs = @{
        tag = "v1.2.3-test"
        email = "test@example.com"
        customer = "���Կͻ�"
        customer_link = ""
        slogan = "���԰汾"
        super_password = "test123"
        rendezvous_server = "192.168.1.100"
        rs_pub_key = ""
        api_server = "http://192.168.1.100:21114"
        enable_debug = "true"
    }
    
    Write-Host "��������:" -ForegroundColor Yellow
    foreach ($key in $inputs.Keys) {
        Write-Host "  $key`: $($inputs[$key])" -ForegroundColor Gray
    }
    
    try {
        Write-Host "`n���ڴ��� CustomBuildRustdesk ������..." -ForegroundColor Yellow
        
        $inputArgs = @()
        foreach ($key in $inputs.Keys) {
            $inputArgs += "--field", "$key=$($inputs[$key])"
        }
        
        $result = gh workflow run "CustomBuildRustdesk.yml" @inputArgs 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "? workflow_dispatch �����ɹ�" -ForegroundColor Green
            Write-Host $result -ForegroundColor Gray
            
            # ��ȡ����ID
            $runId = $result | Select-String -Pattern "Created workflow_dispatch event for .* at .*" | ForEach-Object {
                if ($_ -match "(\d+)") { $matches[1] }
            }
            
            if ($runId) {
                Write-Host "����ID: $runId" -ForegroundColor Cyan
                return $runId
            }
        } else {
            Write-Host "? workflow_dispatch ����ʧ��" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "? workflow_dispatch �����쳣: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# issues��������
function Test-IssuesTrigger {
    Write-Host "`n=== issues �������� ===" -ForegroundColor Cyan
    
    $issueBody = @"
# ��������

**��ǩ**: v1.2.4-issue-test
**����**: issue-test@example.com
**�ͻ�**: ���Կͻ�-issue
**��������ַ**: 192.168.1.200
**API������**: 192.168.1.200
**�м̷�����**: 192.168.1.200
**��Կ**: issue-test-key-456
**����**: ���԰汾-issue

�빹���Զ���RustDesk�ͻ��ˡ�
"@
    
    Write-Host "Issue����:" -ForegroundColor Yellow
    Write-Host $issueBody -ForegroundColor Gray
    
    try {
        Write-Host "`n���ڴ�������Issue..." -ForegroundColor Yellow
        
        $result = gh issue create --title "[build] ���Թ���" --body $issueBody 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "? Issue�����ɹ�" -ForegroundColor Green
            Write-Host $result -ForegroundColor Gray
            
            # ��ȡIssue���
            $issueNumber = $result | Select-String -Pattern "#(\d+)" | ForEach-Object {
                if ($_ -match "#(\d+)") { $matches[1] }
            }
            
            if ($issueNumber) {
                Write-Host "Issue���: $issueNumber" -ForegroundColor Cyan
                return $issueNumber
            }
        } else {
            Write-Host "? Issue����ʧ��" -ForegroundColor Red
            Write-Host $result -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "? Issue�����쳣: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# �鿴���¹���������
function View-LatestRuns {
    Write-Host "`n=== �鿴���¹��������� ===" -ForegroundColor Cyan
    
    try {
        Write-Host "���5������������:" -ForegroundColor Yellow
        gh run list --limit 5
    }
    catch {
        Write-Host "��ȡ�����б�ʧ��: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ��ع���������״̬
function Monitor-WorkflowRun {
    param([string]$RunId)
    
    if (-not $RunId) {
        $RunId = Read-Host "����������ID"
    }
    
    Write-Host "`n=== ��ع���������״̬ ===" -ForegroundColor Cyan
    Write-Host "����ID: $RunId" -ForegroundColor Yellow
    
    $maxAttempts = 30
    $attempt = 0
    
    while ($attempt -lt $maxAttempts) {
        $attempt++
        Write-Host "`n��鳢�� $attempt/$maxAttempts..." -ForegroundColor Gray
        
        try {
            $status = gh run view $RunId --json status,conclusion,createdAt,updatedAt,headBranch,event,workflowName
            
            if ($LASTEXITCODE -eq 0) {
                $statusObj = $status | ConvertFrom-Json
                Write-Host "״̬: $($statusObj.status)" -ForegroundColor $(if ($statusObj.status -eq "completed") { "Green" } elseif ($statusObj.status -eq "in_progress") { "Yellow" } else { "Red" })
                Write-Host "����: $($statusObj.conclusion)" -ForegroundColor $(if ($statusObj.conclusion -eq "success") { "Green" } elseif ($statusObj.conclusion -eq "failure") { "Red" } else { "Gray" })
                Write-Host "������: $($statusObj.workflowName)" -ForegroundColor Cyan
                Write-Host "�¼�: $($statusObj.event)" -ForegroundColor Cyan
                Write-Host "��֧: $($statusObj.headBranch)" -ForegroundColor Cyan
                
                if ($statusObj.status -eq "completed") {
                    Write-Host "? �������������" -ForegroundColor Green
                    return $statusObj
                }
            } else {
                Write-Host "��ȡ����״̬ʧ��" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "����쳣: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host "�ȴ�30�������..." -ForegroundColor Gray
        Start-Sleep -Seconds 30
    }
    
    Write-Host "��س�ʱ" -ForegroundColor Red
    return $null
}

# �鿴��������־
function View-WorkflowLogs {
    param([string]$RunId)
    
    if (-not $RunId) {
        $RunId = Read-Host "����������ID"
    }
    
    Write-Host "`n=== �鿴��������־ ===" -ForegroundColor Cyan
    Write-Host "����ID: $RunId" -ForegroundColor Yellow
    
    try {
        Write-Host "���ڻ�ȡ��־..." -ForegroundColor Yellow
        gh run view $RunId --log
    }
    catch {
        Write-Host "��ȡ��־ʧ��: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# �����������
function Cleanup-TestData {
    Write-Host "`n=== ����������� ===" -ForegroundColor Cyan
    
    try {
        Write-Host "�����г������Issues..." -ForegroundColor Yellow
        gh issue list --limit 10
        
        $issueNumber = Read-Host "`n����Ҫ�رյ�Issue��� (ֱ�ӻس�����)"
        if ($issueNumber) {
            Write-Host "���ڹر�Issue #$issueNumber..." -ForegroundColor Yellow
            gh issue close $issueNumber --delete-branch
            Write-Host "? Issue�ѹر�" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "����ʧ��: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ����ģ�����
function Complete-Simulation {
    Write-Host "`n=== ����ģ����� ===" -ForegroundColor Cyan
    Write-Host "������ִ�� workflow_dispatch �� issues ��������" -ForegroundColor Yellow
    
    $results = @{}
    
    # 1. workflow_dispatch����
    Write-Host "`n����1: workflow_dispatch ��������" -ForegroundColor Magenta
    $workflowRunId = Test-WorkflowDispatch
    $results["WorkflowDispatch"] = $workflowRunId -ne $null
    
    if ($workflowRunId) {
        Write-Host "`n�Ƿ��ش�����״̬? (y/n)" -ForegroundColor Yellow
        $monitor = Read-Host
        if ($monitor -eq "y" -or $monitor -eq "Y") {
            Monitor-WorkflowRun $workflowRunId
        }
    }
    
    # �ȴ�һ��ʱ��
    Write-Host "`n�ȴ�30��������һ������..." -ForegroundColor Yellow
    Start-Sleep -Seconds 30
    
    # 2. issues����
    Write-Host "`n����2: issues ��������" -ForegroundColor Magenta
    $issueNumber = Test-IssuesTrigger
    $results["IssuesTrigger"] = $issueNumber -ne $null
    
    # ������Խ��
    Write-Host "`n=== ���Խ��ժҪ ===" -ForegroundColor Magenta
    foreach ($test in $results.Keys) {
        $status = if ($results[$test]) { "? �ɹ�" } else { "? ʧ��" }
        $color = if ($results[$test]) { "Green" } else { "Red" }
        Write-Host "  $test`: $status" -ForegroundColor $color
    }
    
    Write-Host "`n����ģ�������ɣ�" -ForegroundColor Green
}

# ��ѭ��
function Main-Loop {
    do {
        Show-Menu
        $choice = Read-Host "������ѡ�� (0-7)"
        
        switch ($choice) {
            "1" { Test-WorkflowDispatch }
            "2" { Test-IssuesTrigger }
            "3" { View-LatestRuns }
            "4" { Monitor-WorkflowRun }
            "5" { View-WorkflowLogs }
            "6" { Cleanup-TestData }
            "7" { Complete-Simulation }
            "0" { 
                Write-Host "`n�˳����Խű�" -ForegroundColor Green
                return 
            }
            default { 
                Write-Host "`n��Чѡ�������� 0-7" -ForegroundColor Red
            }
        }
        
        if ($choice -ne "0") {
            Write-Host "`n�����������..." -ForegroundColor Gray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
    } while ($choice -ne "0")
}

# ������
try {
    Main-Loop
}
catch {
    Write-Host "`n���Թ����з�������: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 