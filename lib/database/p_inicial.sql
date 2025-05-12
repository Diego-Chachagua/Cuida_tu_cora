-- Consulta de montos de los gastos del mes actual
SELECT SUM(monto_gasto) AS total_gastos FROM Gastos WHERE STRFTIME("%Y-%m", fecha_gasto) = STRFTIME ("%Y-%m", "now", "localtime");

-- Consulta de motos de los ingresos del mes actual

SELECT SUM(monto_ingreso) AS total_ingresos FROM Ingresos WHERE STRFTIME("%Y-%m", fecha_ingreso) = STRFTIME ("%Y-%m", "now", "localtime");