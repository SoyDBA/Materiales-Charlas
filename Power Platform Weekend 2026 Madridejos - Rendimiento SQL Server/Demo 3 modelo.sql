-- 15M de registros
SELECT
    COUNT(*) AS NumeroVentas,
    SUM(Importe) AS Importe
FROM dbo.Ventas2
WHERE Fecha >= '20250101'
  AND Fecha <  '20260101'


  -- 200M de registros
SELECT
    COUNT(*) AS NumeroVentas,
    SUM(Importe) AS Importe
FROM dbo.Ventas3
WHERE Fecha >= '20250101'
  AND Fecha <  '20260101'




  -- 200M de registros (mal)
SELECT
    COUNT(*) AS NumeroVentas,
    SUM(Importe) AS Importe
FROM dbo.Ventas3
WHERE YEAR(Fecha) = 2025