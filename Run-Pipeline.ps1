param(
    [Parameter(Mandatory=$true)]
    [String]$AzureDevOpsPAT,
    [Parameter(Mandatory=$true)]
    [String]$Organization,
    [Parameter(Mandatory=$true)]
    [String]$Project,
    [Parameter(Mandatory=$true)]
    [Int]$PipelineId,
    [Parameter(Mandatory=$false)]
    [String]$PipelineBranch = 'main',
    [Parameter(Mandatory=$false)]
    [String]$PipelineVariables = '{}',
    [Parameter(Mandatory=$false)]
    [String]$StagesToSkip = '[]'
)

$AzureDevOpsPATSecure = $AzureDevOpsPAT | ConvertTo-SecureString -AsPlainText -Force
$Headers = @{Authorization = 'Basic ' + [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AzureDevOpsPATSecure)))"))}
$Uri = "https://dev.azure.com/$Organization/$Project/_apis/pipelines/$PipelineId/runs?api-version=6.0-preview.1"
$Body = "{
    'previewRun': 'False',
    'resources': {
        'repositories': {
            'self': {
                'refName': 'refs/heads/$PipelineBranch'
            }
        }
    },
    'stagesToSkip': $StagesToSkip,
    'variables': $PipelineVariables
}"

try {
    Write-Host "Starting Pipeline with id $PipelineId on branch $PipelineBranch"
    $Response = Invoke-RestMethod -Uri $Uri -Method POST -Headers $Headers -Body $Body -ContentType "application/json"
    Write-Host "Pipeline" $Response.pipeline.name "started"
} catch {
    Write-Host "There was an error executing the new pipelne:"
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
    Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
}
