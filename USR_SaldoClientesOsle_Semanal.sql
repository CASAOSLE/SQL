
ALTER PROCEDURE [dbo].[USR_SaldoClientesOsle_Semanal]( 
	@@Fecha1 DATETIME, 
	@@Fecha2 DATETIME,  
	@@Fecha3 DATETIME,   
	@@Fecha4 DATETIME,
	@@EmpresaReportCode INT,
	@@PorCliente BIT
	) 
 
AS BEGIN

SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

DECLARE @FechaMax DATETIME
SELECT @FechaMax = CASE 
	WHEN @@Fecha4 IS NOT NULL THEN @@Fecha4
	ELSE CASE 
		WHEN @@Fecha3 IS NOT NULL THEN @@Fecha3
		ELSE CASE	
			WHEN @@Fecha2 IS NOT NULL THEN @@Fecha2
			ELSE @@Fecha1
			END
		END
	END

IF(@@PorCliente = 0)
	SELECT  
		Sucursal = FAFEmpresa.Nombre,
		SaldoFecha1 = SUM(CASE WHEN BSAsientoItem.Fecha <= @@Fecha1 THEN ISNULL(BsAsientoItem.ImporteMonPrincipal, 0) * DebeHaber ELSE 0 END),
		SaldoFecha2 = SUM(CASE WHEN @@Fecha2 IS NOT NULL AND BSAsientoItem.Fecha <= @@Fecha2 THEN ISNULL(BsAsientoItem.ImporteMonPrincipal, 0) * DebeHaber ELSE 0 END),
		SaldoFecha3 = SUM(CASE WHEN @@Fecha3 IS NOT NULL AND BSAsientoItem.Fecha <= @@Fecha3 THEN ISNULL(BsAsientoItem.ImporteMonPrincipal, 0) * DebeHaber ELSE 0 END),
		SaldoFecha4 = SUM(CASE WHEN @@Fecha4 IS NOT NULL AND BSAsientoItem.Fecha <= @@Fecha4 THEN ISNULL(BsAsientoItem.ImporteMonPrincipal, 0) * DebeHaber ELSE 0 END)
	FROM BSAsientoItem 
	LEFT JOIN BSCuenta ON BSAsientoItem.CuentaID = BSCuenta.CuentaID
	LEFT JOIN BSTransaccion ON BsAsientoItem.TransaccionID = BSTransaccion.TransaccionID
	LEFT JOIN FAFEmpresa ON BSTransaccion.EmpresaID = FAFEmpresa.EmpresaID
	LEFT JOIN BSOrganizacion ON BSAsientoItem.OrganizacionID = BSOrganizacion.OrganizacionID
	WHERE BSAsientoItem.Fecha <= @FechaMax
		AND BSCuenta.ImpactaCtasCtes = 1
		AND BSOrganizacion.EsCliente = 1
		AND BSTransaccion.EmpresaID IN (SELECT id FROM FAFARbolSeleccion WHERE ReportCode = @@EmpresaReportCode)
	GROUP BY FAFEmpresa.Nombre
	
IF(@@PorCliente = 1)
	SELECT  
		Cliente = BSOrganizacion.Nombre,
		ClienteCodigo = BSOrganizacion.Codigo,
		Sucursal = FAFEmpresa.Nombre,
		SaldoFecha1 = SUM(CASE WHEN BSAsientoItem.Fecha <= @@Fecha1 THEN ISNULL(BsAsientoItem.ImporteMonPrincipal, 0) * DebeHaber ELSE 0 END),
		SaldoFecha2 = SUM(CASE WHEN @@Fecha2 IS NOT NULL AND BSAsientoItem.Fecha <= @@Fecha2 THEN ISNULL(BsAsientoItem.ImporteMonPrincipal, 0) * DebeHaber ELSE 0 END),
		SaldoFecha3 = SUM(CASE WHEN @@Fecha3 IS NOT NULL AND BSAsientoItem.Fecha <= @@Fecha3 THEN ISNULL(BsAsientoItem.ImporteMonPrincipal, 0) * DebeHaber ELSE 0 END),
		SaldoFecha4 = SUM(CASE WHEN @@Fecha4 IS NOT NULL AND BSAsientoItem.Fecha <= @@Fecha4 THEN ISNULL(BsAsientoItem.ImporteMonPrincipal, 0) * DebeHaber ELSE 0 END)
	FROM BSAsientoItem 
	LEFT JOIN BSCuenta ON BSAsientoItem.CuentaID = BSCuenta.CuentaID
	LEFT JOIN BSTransaccion ON BsAsientoItem.TransaccionID = BSTransaccion.TransaccionID
	LEFT JOIN FAFEmpresa ON BSTransaccion.EmpresaID = FAFEmpresa.EmpresaID
	LEFT JOIN BSOrganizacion ON BSAsientoItem.OrganizacionID = BSOrganizacion.OrganizacionID
	WHERE BSAsientoItem.Fecha <= @FechaMax
		AND BSCuenta.ImpactaCtasCtes = 1
		AND BSOrganizacion.EsCliente = 1
		AND BSTransaccion.EmpresaID IN (SELECT id FROM FAFARbolSeleccion WHERE ReportCode = @@EmpresaReportCode)
	GROUP BY FAFEmpresa.Nombre, BSOrganizacion.Nombre, BSOrganizacion.Codigo

END

