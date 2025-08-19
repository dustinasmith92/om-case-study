param (
 [string]$DirectoryPath = "" # Default to the current directory
)

# Get all files with the *.tfplan.json extension in the specified directory
$planFiles = Get-ChildItem -Path $DirectoryPath -Filter "tfplan-*.json"

# Check if any plan files were found
if ($planFiles.Count -eq 0) {
 Write-Host "No tfplan-*.json files found in '$DirectoryPath'."
 exit 0
}

# Loop through each found plan file
foreach ($planFile in $planFiles) {
    Write-Host "Processing $planFile..."
    
    # Check if file is valid JSON
    try {
        $jsonContent = Get-Content $planFile -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "  Error: '$planFile' is not valid JSON or not found." -ForegroundColor Red
        $exitCode = 1
        continue
    }

    $changeCount = if ($jsonContent.resource_changes) { $jsonContent.resource_changes.Length } else { 0 }
    
    if ($changeCount -eq 0) {
        Write-Host "  No changes detected. Safe to proceed." -ForegroundColor Green 
        continue
    }

    $errors = 0
    for ($i = 0; $i -lt $changeCount; $i++) {
        $actions = ($jsonContent.resource_changes[$i].change.actions -join ",")
        $address = $jsonContent.resource_changes[$i].address

        switch ($actions) {
            {$_ -in "create", "no-op"} {
                # No action needed for create or no-op
            }
            "update" {
                $before = $jsonContent.resource_changes[$i].change.before | ConvertTo-Json -Compress -Depth 100
                $after = $jsonContent.resource_changes[$i].change.after | ConvertTo-Json -Compress -Depth 100
                
                # Remove tags.GitCommitHash from comparison
                $beforeClean = $jsonContent.resource_changes[$i].change.before | 
                    Select-Object -Property * -ExcludeProperty tags | 
                    ForEach-Object { 
                        if ($_.tags) { 
                            $_.tags.PSObject.Properties.Remove('GitCommitHash')
                            $_ 
                        } else { 
                            $_ 
                        }
                    } | ConvertTo-Json -Compress -Depth 100
                
                $afterClean = $jsonContent.resource_changes[$i].change.after | 
                    Select-Object -Property * -ExcludeProperty tags | 
                    ForEach-Object { 
                        if ($_.tags) { 
                            $_.tags.PSObject.Properties.Remove('GitCommitHash')
                            $_ 
                        } else { 
                            $_ 
                        }
                    } | ConvertTo-Json -Compress -Depth 100

                if ($beforeClean -ne $afterClean) {
                    Write-Host "  ERROR: Resource '$address' update modifies more than 'tags.GitCommitHash'."
                    $errors++
                }
            }
            default {
                Write-Host "  ERROR: Resource '$address' has forbidden action(s): $actions"
                $errors++
            }
        }
    }

    if ($errors -eq 0) {
        Write-Host "  Plan is valid for '$planFile'. Safe to apply." -ForegroundColor Green
    }
    else {
        Write-Host "  Plan has $errors issue(s) in '$planFile'. Should NOT proceed."
        $exitCode = 1
    }
}

exit $exitCode