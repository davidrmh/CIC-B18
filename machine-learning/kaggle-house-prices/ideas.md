# Ideas para el modelo de House Prices

* Realizar gráficas de dispersión (utilizar ggplot para facilitar el análisis de varias dimensiones)

* Encontrar **falsos NA**, por ejemplo, Alley, Fence.

* Normalizar atributos entre 0 y 1 (al menos para las variables continuas)

* Encontrar variables como RoofMatl que al parecer no juegan un papel importante
ya que la mayoría de las observaciones son de un sólo tipo y no hay patrón visible.

* YearBuilt vs SalePrice parece ajustar con un polinomio de segundo/tercer orden.

* Neighborhood parece no explicar mucho (????)

* Condition1 y Condition2 casi todas las observaciones son del tipo Norm, parece que
no juegan un papel importante.

|Atributos Potenciales|
|---------------------|
| YearBuilt |
| OverallQual|
| LotArea |
| GarageCars |
