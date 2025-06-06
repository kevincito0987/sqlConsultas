-- Consultas multitabla joins.

-- Encuentra los nombres de los clientes y los detalles de sus pedidos.

SELECT u.nombre AS nombre_cliente, p.*
FROM usuarios u
JOIN pedidos p ON u.usuario_id = p.cliente_id;

-- Lista todos los productos pedidos junto con el precio unitario de cada pedido.

SELECT p.nombre AS nombre_producto, pd.precio_unitario, pd.cantidad
FROM productos p
JOIN detalles_pedidos pd ON p.producto_id = pd.producto_id;

-- Encuentra los nombres de los clientes y los nombres de los empleados que gestionaron sus pedidos

SELECT u.nombre AS cliente, e.nombre AS empleado, p.pedido_id
FROM pedidos p
JOIN usuarios u ON p.cliente_id = u.usuario_id
JOIN empleados em ON p.empleado_id = em.empleado_id
JOIN usuarios e ON em.usuario_id = e.usuario_id;

-- Muestra todos los pedidos y, si existen, los productos en cada pedido, incluyendo los pedidos sin productos usando `LEFT JOIN`

SELECT p.pedido_id, u.nombre AS cliente, pd.producto_id, pr.nombre AS nombre_producto
FROM pedidos p
LEFT JOIN usuarios u ON p.cliente_id = u.usuario_id
LEFT JOIN detalles_pedidos pd ON p.pedido_id = pd.pedido_id
LEFT JOIN productos pr ON pd.producto_id = pr.producto_id;

-- Encuentra los productos y, si existen, los detalles de pedidos en los que no se ha incluido el producto usando `RIGHT JOIN`. 

SELECT pr.nombre AS nombre_producto, pd.pedido_id, pd.precio_unitario
FROM productos pr
RIGHT JOIN detalles_pedidos pd ON pr.producto_id = pd.producto_id;

-- Lista todos los empleados junto con los pedidos que han gestionado, si existen, usando `LEFT JOIN` para ver los empleados sin pedidos.

SELECT e.empleado_id, u.nombre AS empleado, p.pedido_id
FROM empleados e
JOIN usuarios u ON e.usuario_id = u.usuario_id
LEFT JOIN pedidos p ON e.empleado_id = p.empleado_id;

-- Encuentra los empleados que no han gestionado ningún pedido usando un `LEFT JOIN` combinado con `WHERE`. 

SELECT e.empleado_id, u.nombre AS empleado
FROM empleados e
JOIN usuarios u ON e.usuario_id = u.usuario_id
LEFT JOIN pedidos p ON e.empleado_id = p.empleado_id
WHERE p.pedido_id IS NULL;

-- Calcula el total gastado en cada pedido, mostrando el ID del pedido y el total, usando `JOIN`. 

SELECT p.pedido_id, SUM(pd.precio_unitario * pd.cantidad) AS total_gastado
FROM pedidos p
JOIN detalles_pedidos pd ON p.pedido_id = pd.pedido_id
GROUP BY p.pedido_id;

-- Realiza un `CROSS JOIN` entre clientes y productos para mostrar todas las combinaciones posibles de clientes y productos.

SELECT u.nombre AS cliente, p.nombre AS producto
FROM usuarios u
CROSS JOIN productos p;

-- Encuentra los nombres de los clientes y los productos que han comprado, si existen, incluyendo los clientes que no han realizado pedidos usando `LEFT JOIN`.

SELECT u.nombre AS cliente, p.nombre AS producto
FROM usuarios u
LEFT JOIN pedidos pd ON u.usuario_id = pd.cliente_id
LEFT JOIN detalles_pedidos dp ON pd.pedido_id = dp.pedido_id
LEFT JOIN productos p ON dp.producto_id = p.producto_id;

-- Listar todos los proveedores que suministran un determinado producto.

SELECT pv.proveedor_id, pv.nombre AS proveedor
FROM proveedores_productos pp
JOIN proveedores pv ON pp.proveedor_id = pv.proveedor_id
WHERE pp.producto_id = 9; -- Reemplazarlo con el ID del producto específico.

-- Obtener todos los productos que ofrece un proveedor específico.

SELECT pr.producto_id AS proveedor_id, pr.nombre AS producto
FROM proveedores_productos pp
JOIN productos pr ON pp.producto_id = pr.producto_id
WHERE pp.proveedor_id = 3; -- Reemplazar con el ID del proveedor específico.

-- Lista los proveedores que no están asociados a ningún producto (es decir, que aún no suministran).

SELECT pv.proveedor_id, pv.nombre AS proveedor
FROM proveedores pv
LEFT JOIN proveedores_productos pp ON pv.proveedor_id = pp.proveedor_id
WHERE pp.producto_id IS NULL;

-- Contar cuántos proveedores tiene cada producto.

SELECT pr.producto_id, pr.nombre AS producto, COUNT(pp.proveedor_id) AS total_proveedores
FROM productos pr
LEFT JOIN proveedores_productos pp ON pr.producto_id = pp.producto_id
GROUP BY pr.producto_id, pr.nombre;

-- Para un proveedor determinado (p. ej. `proveedor_id = 3`), muestra el nombre de todos los productos que suministra.

SELECT pr.nombre AS producto
FROM proveedores_productos pp
JOIN productos pr ON pp.producto_id = pr.producto_id
WHERE pp.proveedor_id = 1; -- Reemplazar con el ID del proveedor específico.

-- Para un producto específico (p. ej. `producto_id = 1`), muestra todos los proveedores que lo distribuyen, con sus datos de contacto.

SELECT pv.nombre AS proveedor, pv.email, pv.telefono
FROM proveedores_productos pp
JOIN proveedores pv ON pp.proveedor_id = pv.proveedor_id
WHERE pp.producto_id = 3; -- Reemplazar con el ID del producto específico.

-- Cuenta cuántos proveedores tiene cada producto, listando `producto_id`, `nombre` y `cantidad_proveedores`.

SELECT pr.producto_id, pr.nombre AS producto, COUNT(pp.proveedor_id) AS cantidad_proveedores
FROM productos pr
LEFT JOIN proveedores_productos pp ON pr.producto_id = pp.producto_id
GROUP BY pr.producto_id, pr.nombre;

-- Cuenta cuántos productos suministra cada proveedor, mostrando `proveedor_id`, `nombre_proveedor` y `total_productos`.

SELECT pv.proveedor_id, pv.nombre AS nombre_proveedor, COUNT(pp.producto_id) AS total_productos
FROM proveedores pv
LEFT JOIN proveedores_productos pp ON pv.proveedor_id = pp.proveedor_id
GROUP BY pv.proveedor_id, pv.nombre;