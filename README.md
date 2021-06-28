# msktrs
Musketeers Future List

## Requisitos
- Docker
  
### Ejecución local
- Ejecutar `./up.sh`
- La app corre en `http://localhost:8191/`
  - http://localhost:8191/fql.html
  - http://localhost:8191/cts.html
- El backend se puede acceder en forma directa en `http://localhost:8190/_msktrsbe/`
  - http://localhost:8190/_msktrsbe/fql
  - http://localhost:8190/_msktrsbe/cts
- Redis está expuesto en `http://localhost:8192`

## TODO
### Pedidos externos
- Gráfico de juegos comprados vs juegos nuevos 
 - Cuántos juegos nuevos agregamos a las colecciones, vs cuántos que no habíamos jugado antes jugamos
 - Ponele, un gráfico con el tiempo (semanal) en X y la cantidad de juegos sin jugar en Y 
- Grisado en vez de remover los no participantes
- H-Index
- Agregar porcentajes personales del último año o del año corriente (xx%)
- Estadísticas que muestro en el foro ponerlas en la web (texto o gráfico)

### Pedidos internos
- Que excluya los juegos que sólo tiene la persona excluida
- Lista de jugados, ordenados por cantidad de partidas, 6, 5, 4 jugados, etc... (se podría incluir el H-Index ahí)
- Gráfico de mean/STD por plays/month

### Docker
- Hotreload para desarollo en localhost
- Build and deploy script