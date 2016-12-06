cls
$source = "C:\Repos\Incode10\"
$destination = "C:\Repos\API\"

Set-Location $source
Invoke-Expression "hg strip -f --no-backup 'roots(outgoing())'"
hg pull
hg up -C

Set-Location $destination
hg strip -r 0 -f --no-backup
hg purge --all --dirs --files

Copy-Item "$source.hgignore" "$destination.hgignore"

hg addremove | Out-Null
hg commit -m "#VXSPP-506: Initial Commit"

Write-Host "Moving shared projects into API"
$items = @("Api.Core", "Api.Dispatch.Service", "Api.Dispatch.Service.Tests", "Api.Security.Service", "ExpressApi", "ExpressWeb")
foreach($item in $items)
{
    Move-Item "$source\Foundation\$item" "$destination\$item"
}

Write-Host "Copying API.sln"
Copy-Item "$source\Foundation\API.sln" "$destination\API.sln" -Recurse

Write-Host "Copying nuget.exe"
$items = @("nuget.config", "packages.config", "nuget.exe")
foreach($item in $items)
{
    Copy-Item "$source\$item" "$destination\$item" -Recurse
}

Set-Location $destination
hg addremove | Out-Null
hg commit -m "#VXSPP-506: Brought in files from Incode10"

Write-Host $PWD
$DTE.Solution.Open("C:\Repos\API\API.sln")
#DTE.Solution.Remove(

$namesToRemove = @('Api.Alloy.Finance','Api.Incode.Common', 'Api.Incode.Common.Tests', 'Api.Incode.Finance', 'Api.Incode.Finance.Tests', 'Api.Incode.Personnel')
foreach($project in $DTE.Solution.Projects)
{
    Write-Host $project.ProjectName
    foreach($item in $project.ProjectItems)
    {
        Write-Host $item.Name
        if($namesToRemove.Contains($item.Name)) 
        {
            $DTE.Solution.Remove($item)
        }
    }
}

