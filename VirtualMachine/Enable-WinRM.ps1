####This also create a self-signed certificate and can be safely executed more than once.  Must unblock WinRM port.
$Hostname="$($env:COMPUTERNAME)" #or "$($env:COMPUTERNAME).domain.com"
$subject="CN=$($Hostname)"

$certificate=Get-ChildItem cert:\localmachine\my | ?{$_.Subject -like $subject} | Select-Object -First 1
if($certificate){$certificate.thumbprint}
else{$certificate=New-SelfSignedCertificate -Subject $subject -TextExtension '2.5.29.37={text}1.3.6.1.5.5.7.3.1'
New-Item WSMan:\localhost\Listener -Address * -Transport HTTPS -HostName $Hostname -CertificateThumbPrint $certificate.Thumbprint}




