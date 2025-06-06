-- Subconsultas

-- Encuentra los nombres de los clientes que han realizado al menos un pedido de más de $500.000.
SELECT DISTINCT u.nombre 
FROM usuarios u 
JOIN pedidos p ON u.usuario_id = p.cliente_id 
WHERE p.pedido_id IN (
    SELECT pedido_id FROM detalles_pedidos WHERE precio_unitario * cantidad > 500000
);

-- Muestra los productos que nunca han sido pedidos. 

SELECT nombre 
FROM productos 
WHERE producto_id NOT IN (
    SELECT DISTINCT producto_id FROM detalles_pedidos
);

-- Lista los empleados que han gestionado pedidos en los últimos 6 meses.

SELECT DISTINCT u.nombre 
FROM empleados e
JOIN usuarios u ON e.usuario_id = u.usuario_id
WHERE e.empleado_id IN (
    SELECT empleado_id FROM pedidos 
    WHERE fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
);

-- Encuentra el pedido con el total de ventas más alto.

SELECT p.pedido_id, SUM(pd.precio_unitario * pd.cantidad) AS total_ventas
FROM pedidos p
JOIN detalles_pedidos pd ON p.pedido_id = pd.pedido_id
GROUP BY p.pedido_id
ORDER BY total_ventas DESC
LIMIT 1;

-- Muestra los nombres de los clientes que han realizado más pedidos que el promedio de pedidos de todos los clientes mostrando la cantidad de pedidos hechos.

SELECT u.nombre, COUNT(p.pedido_id) AS total_pedidos
FROM usuarios u
JOIN pedidos p ON u.usuario_id = p.cliente_id
GROUP BY u.usuario_id
HAVING total_pedidos > (        
    SELECT AVG(total_pedidos) 
    FROM (
        SELECT COUNT(pedido_id) AS total_pedidos 
        FROM pedidos 
        GROUP BY cliente_id
    ) AS subquery
);

-- Obtén los productos cuyo precio es superior al precio promedio de todos los productos mostrando sus precios.

SELECT p.nombre, p.precio
FROM productos p
WHERE p.precio > (
    SELECT AVG(precio) FROM productos
);

-- Lista los clientes que han gastado más de $1.000.000 en total.

SELECT u.nombre, SUM(pd.precio_unitario * pd.cantidad) AS total_gastado
FROM usuarios u
JOIN pedidos p ON u.usuario_id = p.cliente_id
JOIN detalles_pedidos pd ON p.pedido_id = pd.pedido_id
GROUP BY u.usuario_id
HAVING total_gastado > 1000000;

--Encuentra los empleados que ganan un salario mayor al promedio de la empresa, mostrando el salario promedio de la empresa que es de 2300000.

SELECT u.nombre, e.salario, salario_promedio
FROM empleados e
JOIN usuarios u ON e.usuario_id = u.usuario_id
JOIN (
    SELECT AVG(salario) AS salario_promedio
    FROM empleados
) AS avg_salario ON e.salario > avg_salario.salario_promedio;

-- Obtén los productos que generaron ingresos mayores al ingreso promedio por producto.

SELECT p.nombre, SUM(pd.precio_unitario * pd.cantidad) AS total_ingresos
FROM productos p
JOIN detalles_pedidos pd ON p.producto_id = pd.producto_id
GROUP BY p.producto_id
HAVING total_ingresos > (
    SELECT AVG(total_ingresos)
    FROM (
        SELECT SUM(precio_unitario * cantidad) AS total_ingresos
        FROM detalles_pedidos
        GROUP BY producto_id
    ) AS subquery
);

-- Encuentra el nombre del cliente que realizó el pedido más reciente.

SELECT u.nombre, p.fecha_pedido
FROM usuarios u
JOIN pedidos p ON u.usuario_id = p.cliente_id
ORDER BY p.fecha_pedido DESC
LIMIT 1;

-- Muestra los productos pedidos al menos una vez en los últimos 3 meses.
SELECT * FROM pedidos
WHERE fecha_pedido >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH);

SELECT COUNT(*) FROM pedidos WHERE fecha_pedido >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH);

-- Muestra los productos pedidos mostrando su nombre y precio al menos una vez en los últimos 3 meses// no sirve con subconsultas.

SELECT DISTINCT pedido_id FROM detalles_pedidos 
WHERE pedido_id IN (
    SELECT pedido_id FROM pedidos WHERE fecha_pedido >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
);
SELECT p.nombre, pd.precio_unitario
FROM productos p
JOIN detalles_pedidos pd ON p.producto_id = pd.producto_id
WHERE pd.pedido_id IN (
    SELECT pedido_id FROM pedidos WHERE fecha_pedido >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
);

-- Lista los empleados que no han gestionado ningún pedido. 

SELECT u.nombre 
FROM empleados e
JOIN usuarios u ON e.usuario_id = u.usuario_id
LEFT JOIN pedidos p ON e.empleado_id = p.empleado_id
WHERE p.pedido_id IS NULL
UNION
SELECT nombre 
FROM usuarios 
WHERE usuario_id IN (
    SELECT usuario_id FROM empleados 
    WHERE empleado_id NOT IN (SELECT DISTINCT empleado_id FROM pedidos)
);

-- Encuentra los clientes que han comprado más de tres tipos distintos de productos. 

SELECT u.nombre, COUNT(DISTINCT p.categoria) AS categorias_compradas
FROM usuarios u
JOIN pedidos pe ON u.usuario_id = pe.cliente_id
JOIN detalles_pedidos dp ON pe.pedido_id = dp.pedido_id
JOIN productos p ON dp.producto_id = p.producto_id
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(DISTINCT p.categoria) > 3;

-- Muestra el nombre del producto más caro que se ha pedido al menos cinco veces.

SELECT nombre, precio AS 'producto_mas_caro'
FROM productos
WHERE producto_id = (
    SELECT producto_id
    FROM (
        SELECT p.producto_id, MAX(p.precio) AS precio_maximo
        FROM productos p
        JOIN detalles_pedidos dp ON p.producto_id = dp.producto_id
        GROUP BY p.producto_id, p.nombre
        HAVING COUNT(dp.pedido_id) >= 5
        ORDER BY precio_maximo DESC
        LIMIT 1
    ) AS subconsulta
);

-- Mostrar el precio de cada producto en los pedidos y el por cada producto mostrar en cuantas veces se pidieron en los pedidos y mostrar el mas caro de ellos en orden descendente.

SELECT p.nombre, pd.precio_unitario, COUNT(pd.pedido_id) AS veces_pedido
FROM productos p
JOIN detalles_pedidos pd ON p.producto_id = pd.producto_id
GROUP BY p.producto_id, p.nombre, pd.precio_unitario
ORDER BY pd.precio_unitario DESC;   

-- Lista los clientes cuyo primer pedido fue un año después de su registro.

SELECT nombre 
FROM usuarios 
WHERE usuario_id IN (
    SELECT cliente_id FROM pedidos 
    GROUP BY cliente_id 
    HAVING MIN(fecha_pedido) >= DATE_ADD((SELECT fecha_registro FROM usuarios WHERE usuario_id = cliente_id), INTERVAL 1 YEAR)
);

-- Encuentra los nombres de los productos que tienen un stock inferior al promedio del stock de todos los productos y mostrar la cantidad y la cantidad promedio.

SELECT nombre, stock, (SELECT AVG(stock) FROM productos) AS promedio_stock
FROM productos
WHERE stock < (SELECT AVG(stock) FROM productos);

-- Lista los clientes que han realizado menos de tres pedidos mostrando su nombre y el numero de pedidos.

SELECT u.nombre, COUNT(p.pedido_id) AS total_pedidos
FROM usuarios u
JOIN pedidos p ON u.usuario_id = p.cliente_id
GROUP BY u.usuario_id, u.nombre
HAVING total_pedidos < 3;

-- Encuentra los nombres de los productos que fueron pedidos por los clientes que registraron en el último año mostrando su nombre y fecha contando desde el 2025.

SELECT DISTINCT p.nombre, pe.fecha_pedido
FROM productos p
JOIN detalles_pedidos dp ON p.producto_id = dp.producto_id
JOIN pedidos pe ON dp.pedido_id = pe.pedido_id
JOIN usuarios u ON pe.cliente_id = u.usuario_id
WHERE u.fecha_registro >= '2025-01-01'
ORDER BY p.nombre;

-- Muestra la fecha de los pedidos y de los usuarios que realizaron pedidos en los últimos 1 año y mostrando el id de ese pedido y el id de ese producto en el pedido.

SELECT p.pedido_id, u.nombre, p.fecha_pedido
FROM pedidos p
JOIN usuarios u ON p.cliente_id = u.usuario_id
WHERE p.fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
ORDER BY p.fecha_pedido DESC;
SELECT COUNT(*) FROM usuarios WHERE fecha_registro >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

SELECT sub.pedido_id, sub.nombre AS cliente, sub.fecha_pedido, pr.nombre AS producto
FROM (
    SELECT p.pedido_id, u.nombre, p.fecha_pedido
    FROM pedidos p
    JOIN usuarios u ON p.cliente_id = u.usuario_id
    WHERE p.fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    ORDER BY p.fecha_pedido DESC
) AS sub
JOIN detalles_pedidos dp ON sub.pedido_id = dp.pedido_id
JOIN productos pr ON dp.producto_id = pr.producto_id;

SELECT * FROM detalles_pedidos;

-- Obtén el nombre del empleado que gestionó el mayor número de pedidos.

SELECT empleado, total_pedidos
FROM (
    SELECT u.nombre AS empleado, COUNT(p.pedido_id) AS total_pedidos
    FROM empleados e
    JOIN usuarios u ON e.usuario_id = u.usuario_id
    JOIN pedidos p ON e.empleado_id = p.empleado_id
    GROUP BY e.empleado_id, u.nombre
    ORDER BY total_pedidos DESC
    LIMIT 1
) AS subconsulta;

-- Lista los productos que han sido comprados en cantidades mayores que el promedio de cantidad de compra de todos los productos muestra el promedio de cantidad de compra.

SELECT nombre AS Producto, total_cantidad AS 'Cantidad Productos', promedio_cantidad AS Promedio
FROM (
    SELECT p.nombre, SUM(dp.cantidad) AS total_cantidad, 
           (SELECT AVG(cantidad) FROM detalles_pedidos) AS promedio_cantidad
    FROM productos p
    JOIN detalles_pedidos dp ON p.producto_id = dp.producto_id
    GROUP BY p.producto_id, p.nombre
) AS subconsulta
WHERE total_cantidad > promedio_cantidad;

-- Proveedores que suministran más productos que el promedio de productos por proveedor, proveedor y productos son tablas separadas.
SELECT pp.proveedor_id, pr.nombre AS nombre_proveedor, pp.producto_id, p.nombre AS nombre_producto, 
       (SELECT COUNT(*) FROM proveedores_productos WHERE proveedor_id = pp.proveedor_id) AS cantidad_productos_asociados
FROM proveedores_productos pp
JOIN proveedores pr ON pp.proveedor_id = pr.proveedor_id
JOIN productos p ON pp.producto_id = p.producto_id
WHERE pp.proveedor_id IN (
    SELECT proveedor_id
    FROM (
        SELECT proveedor_id, COUNT(producto_id) AS total_productos
        FROM proveedores_productos
        GROUP BY proveedor_id
        HAVING total_productos > (
            SELECT AVG(productos_por_proveedor) 
            FROM (
                SELECT proveedor_id, COUNT(producto_id) AS productos_por_proveedor
                FROM proveedores_productos
                GROUP BY proveedor_id
            ) AS subconsulta
        )
    ) AS filtro_proveedores
);

-- Proveedores que solo suministran productos de la categoría "Electrónica".

SELECT pp.proveedor_id, pr.nombre AS nombre_proveedor, pp.producto_id, p.nombre AS nombre_producto
FROM proveedores_productos pp
JOIN proveedores pr ON pp.proveedor_id = pr.proveedor_id
JOIN productos p ON pp.producto_id = p.producto_id
WHERE pp.proveedor_id IN (
    SELECT proveedor_id
    FROM proveedores_productos
    JOIN productos ON proveedores_productos.producto_id = productos.producto_id
    WHERE productos.categoria = 'Electrónica'
    GROUP BY proveedor_id
    HAVING COUNT(DISTINCT productos.categoria) = 1
);

-- Productos que solo tienen proveedores registrados hace más de un año mostrando la fecha.

SELECT p.producto_id, p.nombre AS nombre_producto, pp.proveedor_id, pr.nombre AS nombre_proveedor, pr.fecha_registro
FROM productos p
JOIN proveedores_productos pp ON p.producto_id = pp.producto_id
JOIN proveedores pr ON pp.proveedor_id = pr.proveedor_id
WHERE pr.fecha_registro < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY p.producto_id, p.nombre, pp.proveedor_id, pr.nombre, pr.fecha_registro
HAVING COUNT(DISTINCT pp.proveedor_id) = (
    SELECT COUNT(*) FROM proveedores_productos WHERE producto_id = p.producto_id
) AND COUNT(DISTINCT pr.fecha_registro) > 0;
