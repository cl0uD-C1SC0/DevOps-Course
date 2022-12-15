# Possiveis erros:

## ERRO ao subir o container cadvisor:

> <br>
> Trocar a imagem para: gcr.io/cadvisor/cadvisor <br><br>

## ERRO ao fazer o mount cpu no container prometheus:

> <br>
> Acrescentar abaixo do image o campo > user: root <br><br>

## ERRO ao fazer o mount cpu no container grafana:

> <br>
> Acrescentar abaixo do image o campo > user: root <br><br>

# Observações
> Adicionar exporter na mesma network que os outros containers para facilitar.
> Criar um scrap_config no prometheus.yml referenciando esse novo exporter.
> Reiniciar o docker-compose
> Verificar no prometheus se esta pegando corretamente as metricas.