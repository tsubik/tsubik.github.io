---
layout: post
title: "Powershell script to bring your publish to the next level"
tags: ["Powershell",".NET"]
date: 2012-08-26
author: "Tomasz Subik"
permalink: /blog/powershell-script-to-bring-your-publish-to-the-next-level/
---

How many times during the development stage, your project file breaks after the merge? Everything looks great until you deploy
the app to test or production server(sic!). You finish your work, go home to spend a great evening with your girlfriend or friends, but the next day, while checking issues reported by the quality team, you might see something like this:

![Powershell_01](/images/blog/powershell_01.png "View not found")
<!--more-->

Or complaints of this kind: Why everything looks like shit!!??

What the hell!? That supposed to work perfectly fine! You go straight to Visual Studio looking for problematic files and baam! Found it!!

![Powershell_02](/images/blog/powershell_02.png "Solution Explorer")

Your view is there but not added to the project. It is that simple and silly. It can be any file - view,
stylesheet, script file, and a bunch of others.

So, we need a simple solution to prevent it from happening again.

The problem is trivial and the solution is so too. All you have to do is check if all files listed in the project's
catalog are included in the project configuration file. You can write a simple console app to
check it and warn you about files you might be missing.

But instead, I've prepared a PowerShell script. This is my first PowerShell script so be nice, and any improvements
are very welcome (please do it directly on <a href="https://gist.github.com/3296391">gist</a>).

<noscript><pre>
#Author: Tomasz Subik http://tsubik.com
#Date: 8/04/2012 7:35:55 PM
#Script: FindProjectMissingFiles
#Description: Looking for missing references to files in project config file
Param(
    [parameter(Mandatory=$false)]
    [alias("d")]
    $Directory,
    [parameter(Mandatory=$false)]
    [alias("s")]
    $SolutionFile
)

Function LookForProjectFile([System.IO.DirectoryInfo] $dir){
    [System.IO.FileInfo] $projectFile = $dir.GetFiles() | Where { $_.FullName.EndsWith(".csproj") } | Select -First 1

    if ($projectFile){
        $projectXmlDoc = [xml][system.io.file]::ReadAllText($projectFile.FullName)
        #[xml]$projectXmlDoc = Get-Content $projectFile.FullName
        $currentProjectPath = $projectFile.DirectoryName+"\"
        Write-Host "----Project found: "  $projectFile.Name

        $nm = New-Object -TypeName System.Xml.XmlNamespaceManager -ArgumentList $projectXmlDoc.NameTable
        $nm.AddNamespace('x', 'http://schemas.microsoft.com/developer/msbuild/2003')
        [System.Collections.ArrayList]$filesListedInProjectFile = $projectXmlDoc.SelectNodes('/x:Project/x:ItemGroup/*[self::x:Compile or self::x:Content or self::x:None]/@Include', $nm) | Select-Object Value

        CheckProjectIntegrity $dir $currentProjectPath $filesListedInProjectFile;
    }
    else { $dir.GetDirectories() | ForEach-Object { LookForProjectFile($_); } }
}

Function CheckProjectIntegrity([System.IO.DirectoryInfo] $dir,[string] $currentProjectPath,  [System.Collections.ArrayList] $filesListedInProjectFile ){
    $relativeDir = $dir.FullName -replace [regex]::Escape($currentProjectPath)
    $relativeDir = $relativeDir +"\"
    #check if folder is bin obj or something
    if ($relativeDir -match '(bin\\|obj\\).*') { return }

    $dir.GetFiles()  | ForEach-Object {
        $relativeProjectFile = $_.FullName -replace [regex]::Escape($currentProjectPath)
        $match = $false
        if(DoWeHaveToLookUpForThisFile($relativeProjectFile))
        {
            $idx = 0
            foreach($file in $filesListedInProjectFile)
            {
                if($relativeProjectFile.ToLower().Trim() -eq $file.Value.ToLower().Trim()){
                    $match = $true
                    break
                }
                $idx++
            }
            if (-not($match))
            {
                Write-Host "Missing file reference: " $relativeProjectFile -ForegroundColor Red
            }
            else
            {
                $filesListedInProjectFile.RemoveAt($idx)
            }
        }
    }
    #lookup in sub directories
    $dir.GetDirectories() | ForEach-Object { CheckProjectIntegrity $_ $currentProjectPath $filesListedInProjectFile }
}

Function DoWeHaveToLookUpForThisFile($filename)
{
    #check file extensions
    if ($filename -match '^.*\.(user|csproj|aps|pch|vspscc|vssscc|ncb|suo|tlb|tlh|bak|log|lib|sdf)$') { return $false }
    return $true
}

Write-Host '######## Checking for missing references to files started ##############'
if($SolutionFile){
  [System.IO.FileInfo] $file = [System.IO.FileInfo] $SolutionFile
  $Directory = $file.Directory
}
LookForProjectFile($Directory)
Write-Host '######## Checking for missing references to files ends ##############'
</pre></noscript>
<script src="https://gist.github.com/3296391.js?file=FindProjectMissingFilesReferences.ps1"> </script>

You can find script on <a href="https://gist.github.com/3296391">github</a>.

How can you use it in your current projects?

Just add the script somewhere to your project and use VS package manager
console tool.

<noscript>
<pre>
  PM> ./PKEWeb/Powershell/FindProjectMissingFiles.ps1 -s $dte.Solution.FileName
</pre>
</noscript>
<script src="https://gist.github.com/3296391.js?file=PM.ps1"> </script>
ENJOY!
