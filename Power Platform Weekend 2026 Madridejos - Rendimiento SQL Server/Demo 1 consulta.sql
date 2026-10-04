-- Consulta 
SELECT
    COUNT(*) AS NumeroVentas,
    SUM(Importe) AS Importe
FROM dbo.Ventas
WHERE YEAR(Fecha) = 2025;

-- Misma tabla, mismo índice, 15x datos
SELECT
    COUNT(*) AS NumeroVentas,
    SUM(Importe) AS Importe
FROM dbo.Ventas2
WHERE YEAR(Fecha) = 2025;

-- Consulta arreglada
SELECT
    COUNT(*) AS NumeroVentas,
    SUM(Importe) AS Importe
FROM dbo.Ventas2
WHERE Fecha >= '20250101'
  AND Fecha <  '20260101'

