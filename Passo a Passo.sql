-- ##################################################
--     PROJETO DE INTEGRAÇÃO SQL SERVER e EXCEL
-- ##################################################

-- 1. Apresentação


-- 2. Download Banco de Dados AdventureWorks 2014

/*
https://docs.microsoft.com/pt-br/sql/samples/adventureworks-install-configure?view=sql-server-ver16&tabs=ssms
*/

-- 3. Definindo os indicadores do projeto

-- i) Total de Vendas Internet por Categoria do Produto
-- ii) Receita Total Internet por Mês do Pedido
-- iii) Receita e Custo Total Internet por País
-- iv) Total de Vendas Internet por Sexo do Cliente

-- OBS: O ANO DE ANÁLISE SERÁ APENAS 2013 (ANO DO PEDIDO)


SELECT * FROM FactInternetSales
SELECT * FROM DimProductSubCategory
SELECT * FROM DimSalesTerritory
SELECT * FROM DimProduct

361







-- 4. Definindo as tabelas a serem analisadas

-- TABELA 1: FactInternetSales
-- TABELA 2: DimCustomer
-- TABELA 3: DimSalesTerritory
-- TABELA 4: DimProductCategory ***

-- *** Aqui precisaremos fazer um relacionamento em cadeia















-- 5. Definindo as colunas da view VENDAS_INTERNET


-- VIEW FINAL VENDAS_INTERNET

-- Colunas:

-- SalesOrderNumber                (TABELA 1: FactInternetSales)
-- OrderDate                       (TABELA 1: FactInternetSales)
-- EnglishProductCategoryName      (TABELA 4: DimProductCategory)
-- FirstName + LastName            (TABELA 2: DimCustomer)
-- Gender                          (TABELA 2: DimCustomer)
-- SalesTerritoryCountry           (TABELA 3: DimSalesTerritory)
-- OrderQuantity                   (TABELA 1: FactInternetSales)
-- TotalProductCost                (TABELA 1: FactInternetSales)
-- SalesAmount                     (TABELA 1: FactInternetSales)







-- 6. Criando o código da view VENDAS_INTERNET

-- i) Total de Vendas Internet por Categoria do Produto
-- ii) Receita Total Internet por Mês do Pedido
-- iii) Receita e Custo Total Internet por País
-- iv) Total de Vendas Internet por Sexo do Cliente

-- OBS: O ANO DE ANÁLISE SERÁ APENAS 2013 (ANO DO PEDIDO)

CREATE OR ALTER VIEW VENDAS_INTERNET AS
	SELECT
		fis.SalesOrderNumber AS 'Nº PEDIDO',
		fis.OrderDate AS 'DATA PEDIDO',
		dpc.EnglishProductCategoryName AS 'CATEGORIA PRODUTO',
		dc.FirstName + ' ' + dc.LastName AS 'NOME CLIENTE',
		SalesTerritoryCountry AS 'PAÍS',
		fis.OrderQuantity AS 'QTD. VENDIDA',
		fis.TotalProductCost AS 'CUSTO VENDA',
		fis.SalesAmount AS 'RECEITA VENDA'
	FROM FactInternetSales fis
	INNER JOIN DimProduct dp ON fis.ProductKey = dp.ProductKey
		INNER JOIN DimProductSubcategory dps ON dp.ProductSubcategoryKey = dps.ProductSubcategoryKey
			INNER JOIN DimProductCategory dpc ON dps.ProductCategoryKey = dpc.ProductCategoryKey
	INNER JOIN DimCustomer dc ON fis.CustomerKey = dc.CustomerKey
	INNER JOIN DimSalesTerritory dst ON fis.SalesTerritoryKey = dst.SalesTerritoryKey
	WHERE YEAR(OrderDate) = 2013

SELECT * FROM VENDAS_INTERNET



-- Alterando o banco de dados e atualizando no Excel

BEGIN TRANSACTION T1
	
	UPDATE FactInternetSales
	SET OrderQuantity = 20
	WHERE ProductKey = 361       -- Categoria Bike

COMMIT TRANSACTION T1

SELECT * FROM FactInternetSales











SELECT
	Gender AS 'Sexo',
	COUNT(ProductKey) AS 'Total vendas'
FROM
	FactInternetSales
		INNER JOIN DimCustomer
			ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
GROUP BY Gender



SELECT
	DimProductCategory.ProductCategoryKey AS 'Categoria',
	DimProductCategory.EnglishProductCategoryName AS 'Nome da categoria',
	COUNT(FactInternetSales.ProductKey) AS 'Total vendido',
	MONTH(OrderDate) AS 'Mês',
	ROUND(SUM(SalesAmount), 2) AS 'Receita Total por mês',
	SalesTerritoryCountry AS 'País',
	ROUND(SUM(TotalProductCost), 2) AS 'Custo total por país',
	ROUND(SUM(SalesAmount), 2) AS 'Receita total por país',
	Gender AS 'Sexo',
	COUNT(FactInternetSales.ProductKey) AS 'Total vendas'
FROM DimProductCategory
		INNER JOIN DimProductSubcategory
			ON DimProductCategory.ProductCategoryKey = DimProductSubcategory.ProductCategoryKey
				INNER JOIN DimProduct
					ON DimProduct.ProductSubcategoryKey = DimProductSubcategory.ProductSubcategoryKey
						INNER JOIN FactInternetSales
							ON FactInternetSales.ProductKey = DimProduct.ProductKey
								INNER JOIN DimSalesTerritory
									ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
										INNER JOIN DimCustomer
											ON FactInternetSales.CustomerKey = DimCustomer.CustomerKey
WHERE YEAR(OrderDate) = 2013
GROUP BY DimProductCategory.ProductCategoryKey, DimProductCategory.EnglishProductCategoryName, MONTH(OrderDate), SalesTerritoryCountry, Gender
ORDER BY MONTH(OrderDate) asc


SELECT
	MONTH(OrderDate) AS 'Mês',
	ROUND(SUM(SalesAmount), 2) AS 'Receita Total'
FROM
	FactInternetSales
GROUP BY MONTH(OrderDate)
ORDER BY MONTH(OrderDate) asc
	

SELECT * FROM DimSalesTerritory
SELECT * FROM FactInternetSales

SELECT
	SalesTerritoryCountry AS 'País',
	ROUND(SUM(TotalProductCost), 2) AS 'Custo total por país',
	ROUND(SUM(SalesAmount), 2) AS 'Receita total por país'
FROM
	FactInternetSales
		INNER JOIN DimSalesTerritory
			ON FactInternetSales.SalesTerritoryKey = DimSalesTerritory.SalesTerritoryKey
GROUP BY SalesTerritoryCountry
ORDER BY SalesTerritoryCountry asc