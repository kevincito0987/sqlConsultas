-- CONSULTAS BÁSICAS:

-- Consulta todos los datos de la tabla `usuarios` para ver la lista completa de clientes.

SELECT *
FROM empleados;

-- Muestra los nombres y correos electrónicos de todos los clientes que residen en la ciudad de Madrid. 

SELECT nombre, email
FROM usuarios
WHERE ciudad = 'Madrid';

-- Obtén una lista de productos con un precio mayor a $100.000, mostrando solo el nombre y el precio.

SELECT nombre, precio
FROM productos
WHERE precio > 100000;

--Encuentra todos los empleados que tienen un salario superior a $2.500.000, mostrando su nombre, puesto y salario. 

SELECT u.nombre, e.puesto, e.salario 
FROM empleados e
JOIN usuarios u ON e.usuario_id = u.usuario_id
WHERE e.salario > 2500000;

-- Lista los nombres de los productos en la categoría "Electrónica", ordenados alfabéticamente. 
SELECT nombre
FROM productos
WHERE categoria = 'Electrónica'
ORDER BY nombre ASC;

-- Muestra los detalles de los pedidos que están en estado "Pendiente", incluyendo el ID del pedido, el ID del cliente y la fecha del pedido. 
SELECT pedido_id, cliente_id, fecha_pedido 
FROM pedidos 
WHERE estado = 'Pendiente';

-- Encuentra el nombre y el precio del producto más caro en la base de datos. 

SELECT nombre, precio
FROM productos
ORDER BY precio DESC
LIMIT 1;

-- Obtén el total de pedidos realizados por cada cliente, mostrando el ID del cliente y el total de pedidos.  

SELECT cliente_id, COUNT(*) AS total_pedidos
FROM pedidos
GROUP BY cliente_id;

-- Calcula el promedio de salario de todos los empleados en la empresa.

SELECT AVG(salario) AS promedio_salario
FROM empleados;

-- Encuentra el número de productos en cada categoría, mostrando la categoría y el número de productos.

SELECT categoria, COUNT(*) AS total_productos
FROM productos
GROUP BY categoria;

-- Obtén una lista de productos con un precio mayor a $75 USD, mostrando solo el nombre, el precio y su respectivo precio en USD.

SELECT nombre, precio, (precio / 3940) AS precio_usd  -- Suponiendo un tipo de cambio de 1 USD = 3940 COP
FROM productos 
WHERE precio > (75 * 3940);

-- Lista todos los proveedores registrados.

SELECT *
FROM proveedores;