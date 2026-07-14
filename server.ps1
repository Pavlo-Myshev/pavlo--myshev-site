$ErrorActionPreference = "Stop"
$port = 8000
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Start-Process "http://localhost:$port/"
Write-Host ""
Write-Host "PM Assistant is running at http://localhost:$port/" -ForegroundColor Green
Write-Host "Keep this window open. Press Ctrl+C to stop." -ForegroundColor Yellow
Write-Host ""
$mime = @{
 ".html"="text/html; charset=utf-8"; ".js"="application/javascript; charset=utf-8";
 ".css"="text/css; charset=utf-8"; ".json"="application/json; charset=utf-8";
 ".webmanifest"="application/manifest+json; charset=utf-8"; ".jpeg"="image/jpeg";
 ".jpg"="image/jpeg"; ".png"="image/png"; ".svg"="image/svg+xml"; ".ico"="image/x-icon"
}
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $path = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
  if ([string]::IsNullOrWhiteSpace($path)) { $path = "index.html" }
  $file = Join-Path $root $path
  if (Test-Path $file -PathType Leaf) {
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $ext = [System.IO.Path]::GetExtension($file).ToLower()
    $ctx.Response.ContentType = $(if($mime.ContainsKey($ext)){$mime[$ext]}else{"application/octet-stream"})
    $ctx.Response.StatusCode = 200
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
  } else {
    $bytes=[Text.Encoding]::UTF8.GetBytes("404")
    $ctx.Response.StatusCode=404
    $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
  }
  $ctx.Response.OutputStream.Close()
}
