# �ֿ�����ű� (PowerShell�汾)
# ʹ��gh����99-delete_issues��99-delete_workflow_runs������

# ����Issues
function Cleanup-Issues {
    Write-Host "��ʼ����Issues..." -ForegroundColor Green
    
    # ����99-delete_issues������
    Write-Host "����99-delete_issues������..." -ForegroundColor Yellow
    
    try {
        $result = gh workflow run "99-delete_issues.yml" --field mode="ɾ��ģʽ" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "99-delete_issues�����������ɹ�" -ForegroundColor Green
            Write-Host $result
        }
        else {
            Write-Host "99-delete_issues����������ʧ��: $result" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "99-delete_issues�����������쳣: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# ����Workflow Runs
function Cleanup-WorkflowRuns {
    Write-Host "��ʼ����Workflow Runs..." -ForegroundColor Green
    
    # ����99-delete_workflow_runs������
    Write-Host "����99-delete_workflow_runs������..." -ForegroundColor Yellow
    
    try {
        $result = gh workflow run "99-delete_workflow_runs.yml" --field mode="ɾ��ģʽ" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "99-delete_workflow_runs�����������ɹ�" -ForegroundColor Green
            Write-Host $result
        }
        else {
            Write-Host "99-delete_workflow_runs����������ʧ��: $result" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "99-delete_workflow_runs�����������쳣: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    
    return $true
}

# ������
function Main {
    
    # ִ���������
    Write-Host "��ʼ�ֿ��������..." -ForegroundColor Cyan
    
    # ����Issues
    if (-not (Cleanup-Issues)) {
        Write-Host "Issues����ʧ��" -ForegroundColor Red
        exit 1
    }
    
    # ����Workflow Runs
    if (-not (Cleanup-WorkflowRuns)) {
        Write-Host "Workflow Runs����ʧ��" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "���������ɣ�" -ForegroundColor Green
    
    # ��ʾ������״̬
    Write-Host "�鿴������״̬:" -ForegroundColor Cyan
    Write-Host "  gh run list --workflow=99-delete_issues.yml" -ForegroundColor Yellow
    Write-Host "  gh run list --workflow=99-delete_workflow_runs.yml" -ForegroundColor Yellow
}

# ������
try {
    # ����������
    Main
}
catch {
    Write-Host "�ű�ִ�б��ж�: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 