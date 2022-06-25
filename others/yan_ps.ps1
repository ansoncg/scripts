# yan.ps1

$pasta_destino = "."

$link = Read-Host "Cole o link"
$lote = ($link -split '\.')[5]
if ($lote -eq "E569") {
    $lote = "1"
}
elseif ($lote -eq "E572") {
    $lote = "2"
}
$data = ($link -split '\.')[6]
$data = $data.substring(1)
# $horario = ($link -split '\.')[7]

$arquivo = $pasta_destino+ "/20horas" +$data +"lote" +$lote +".txt"
curl $link > $arquivo
