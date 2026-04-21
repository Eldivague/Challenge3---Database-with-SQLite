# Auditoría de Ventas con SQL 🐧

Este proyecto organiza y analiza los datos de una tienda para encontrar errores y mejorar la calidad de la información usando SQL y Python.

## 📁 Archivos
* **`schema.sql`**: El diseño de las tablas (Productos, Pedidos y Auditoría). Incluye reglas automáticas para evitar que se carguen datos por error.
* **`queries.ipynb`**: Análisis con Python donde busco inconsistencias y navego por el historial de la base de datos.

## 🔍 ¿Qué problemas resuelve?
El análisis se enfoca en encontrar errores reales en los datos, como:
1. **Relaciones Rotas:** Identifica pedidos o pagos que apuntan a clientes o órdenes que no existen en el sistema.
2. **Estados Imposibles:** Detecta pedidos que figuran como "entregados" pero que nunca pasaron por el proceso de "envío".
3. **Productos sin Pedidos:** Genera una lista de artículos que están en el catálogo pero que nunca fueron incluidos en ninguna compra.

## 🛠️ Herramientas
* **SQLite** (Base de datos)
* **Python** (Análisis de datos)