#!/usr/bin/env pwsh

<#
    .SYNOPSIS
    Tests various `Ping` endpoint(s) from the Healthchecks API Service.
    .DESCRIPTION
    Currently the tests ping the following URLs:
    - http://localhost:8000/ping/{ping_key}/ping-docsjimbrig
#>
#Requires -Module Pester
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, Position = 0)]
    [String]$PingKey = "$Env:API_PING_KEY"
)

Describe 'Ping Tests' {

    BeforeAll {
        $GLOBAL:PingRoot = "http://localhost:8000/ping/$PingKey"
        $GLOBAL:ExpectedResponse = 'OK'
    }

    It 'ping docs.jimbrig.com' {
        $PingUrl = "$PingRoot/ping-docsjimbrig"
        $PingResponse = Invoke-RestMethod -Uri $PingUrl
        $PingResponse | Should -Not -BeNullOrEmpty
        $PingResponse | Should -Be 'OK'
    }

}
