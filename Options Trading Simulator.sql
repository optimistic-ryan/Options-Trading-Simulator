-- Create the Tables

CREATE TABLE underlying_assets (
  id INT PRIMARY KEY,
  current_price DECIMAL(10, 2) NOT NULL,
  ticker_symbol VARCHAR(10) UNIQUE NOT NULL,
  company_name VARCHAR(100) NOT NULL
);

CREATE TABLE options_contracts (
  id INT PRIMARY KEY,
  underlying_asset_id INT NOT NULL,
  option_type CHAR(4) NOT NULL,
  strike_price DECIMAL(10, 2) NOT NULL,
  expiration_date DATE NOT NULL,
  risk_free_rate DECIMAL(5, 2) NOT NULL,
  volatility DECIMAL(5, 2) NOT NULL,
  dividend_yield DECIMAL(5, 2) NOT NULL,
  FOREIGN KEY (underlying_asset_id) REFERENCES underlying_assets(id)
);

CREATE TABLE trades (
  id INT PRIMARY KEY,
  options_contract_id INT NOT NULL,
  trade_type CHAR(4) NOT NULL,
  quantity INT NOT NULL,
  trade_date DATE NOT NULL,
  trade_price DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (options_contract_id) REFERENCES options_contracts(id)
);

CREATE TABLE trading_strategies (
  id INT PRIMARY KEY,
  strategy_name VARCHAR(50) NOT NULL
);

CREATE TABLE strategy_trades (
  strategy_id INT NOT NULL,
  trade_id INT NOT NULL,
  PRIMARY KEY (strategy_id, trade_id),
  FOREIGN KEY (strategy_id) REFERENCES trading_strategies(id),
  FOREIGN KEY (trade_id) REFERENCES trades(id)
);


-- Insert Data into Tables

INSERT INTO underlying_assets (id, current_price, ticker_symbol, company_name) VALUES
(1, 150, 'AAPL', 'Apple Inc.'),
(2, 250, 'GOOGL', 'Alphabet Inc.'),
(3, 100, 'MSFT', 'Microsoft Corporation'),
(4, 300, 'AMZN', 'Amazon.com Inc.'),
(5, 200, 'TSLA', 'Tesla Inc.');

INSERT INTO options_contracts (id, underlying_asset_id, option_type, strike_price, expiration_date, risk_free_rate, volatility, dividend_yield) VALUES
(1, 1, 'CALL', 150.00, '2022-05-19', 0.02, 0.5, 0.2),
(2, 1, 'PUT', 150.00, '2022-05-19', 0.02, 0.5, 0.2),
(3, 2, 'CALL', 1200.00, '2022-05-19', 0.02, 0.5, 0.2),
(4, 2, 'PUT', 1200.00, '2022-05-19', 0.02, 0.5, 0.2),
(5, 3, 'CALL', 200.00, '2022-05-19', 0.02, 0.5, 0.2),
(6, 3, 'PUT', 200.00, '2022-05-19', 0.02, 0.5, 0.2),
(7, 4, 'CALL', 3300.00, '2022-05-19', 0.02, 0.5, 0.2),
(8, 4, 'PUT', 3300.00, '2022-05-19', 0.02, 0.5, 0.2),
(9, 5, 'CALL', 600.00, '2022-05-19', 0.02, 0.5, 0.2),
(10, 5, 'PUT', 600.00, '2022-05-19', 0.02, 0.5, 0.2);

INSERT INTO trades (id, options_contract_id, trade_type, quantity, trade_date, trade_price) VALUES
(1, 1, 'BUY', 10, '2022-05-01', 5.00),
(2, 2, 'SELL', 10, '2022-05-01', 4.00),
(3, 3, 'BUY', 5, '2022-05-02', 10.00),
(4, 4, 'SELL', 5, '2022-05-02', 8.00),
(5, 5, 'BUY', 15, '2022-05-03', 7.00),
(6, 6, 'SELL', 15, '2022-05-03', 6.00),
(7, 7, 'BUY', 4, '2022-05-04', 25.00),
(8, 8, 'SELL', 4, '2022-05-04', 20.00),
(9, 9, 'BUY', 8, '2022-05-05', 12.00),
(10, 10, 'SELL', 8, '2022-05-05', 10.00);

INSERT INTO trading_strategies (id, strategy_name) VALUES
(1, 'Bullish Call Spread'),
(2, 'Bearish Put Spread'),
(3, 'Iron Condor'),
(4, 'Butterfly Spread'),
(5, 'Straddle');

INSERT INTO strategy_trades (strategy_id, trade_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(3, 6),
(4, 7),
(4, 8),
(5, 9),
(5, 10);


-- Query the Data

-- Get all options contracts for a specific underlying asset
CREATE OR REPLACE FUNCTION get_options_contracts(p_underlying_asset_id INTEGER)
RETURNS SETOF options_contracts AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM options_contracts WHERE underlying_asset_id = p_underlying_asset_id;
END;
$$ LANGUAGE plpgsql;

-- Get all trades for a specific options contract
CREATE OR REPLACE FUNCTION get_trades_by_contract(p_options_contract_id INTEGER)
RETURNS SETOF trades AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM trades WHERE options_contract_id = p_options_contract_id;
END;
$$ LANGUAGE plpgsql;

-- Get all trades for a specific trading strategy
CREATE OR REPLACE FUNCTION get_trades_by_strategy(p_strategy_id INTEGER)
RETURNS SETOF trades AS $$
BEGIN
  RETURN QUERY
  SELECT t.*
  FROM trades t
  JOIN strategy_trades st ON t.id = st.trade_id
  WHERE st.strategy_id = p_strategy_id;
END;
$$ LANGUAGE plpgsql;

-- Test the Functions
SELECT * FROM get_options_contracts(1);
SELECT * FROM get_trades_by_contract(1);
SELECT * FROM get_trades_by_strategy(1);


-- Analyze the Trading Strategies

-- Calculate the net cost of a trading strategy
CREATE OR REPLACE FUNCTION calculate_net_cost(p_strategy_id INTEGER)
RETURNS TABLE (strategy_id INTEGER, net_cost DECIMAL) AS $$
BEGIN
  RETURN QUERY
  SELECT st.strategy_id, SUM(t.trade_price * t.quantity * (CASE t.trade_type WHEN 'BUY' THEN -1 ELSE 1 END)) as net_cost
  FROM trades t
  JOIN strategy_trades st ON t.id = st.trade_id
  WHERE st.strategy_id = p_strategy_id
  GROUP BY st.strategy_id;
END;
$$ LANGUAGE plpgsql;

-- Calculate the total profit or loss for a trading strategy
CREATE OR REPLACE FUNCTION calculate_strategy_profit_loss(p_strategy_id INTEGER)
RETURNS TABLE (strategy_id INTEGER, profit_loss DECIMAL) AS $$
BEGIN
  RETURN QUERY
  SELECT st.strategy_id,
         SUM(t.trade_price * t.quantity * (CASE t.trade_type WHEN 'BUY' THEN -1 ELSE 1 END) *
             (CASE oc.option_type WHEN 'CALL' THEN (GREATEST(0, ua.current_price - oc.strike_price)) ELSE (GREATEST(0, oc.strike_price - ua.current_price)) END)
             ) as profit_loss
  FROM trades t
  JOIN strategy_trades st ON t.id = st.trade_id
  JOIN options_contracts oc ON t.options_contract_id = oc.id
  JOIN underlying_assets ua ON oc.underlying_asset_id = ua.id
  WHERE st.strategy_id = p_strategy_id
  GROUP BY st.strategy_id;
END;
$$ LANGUAGE plpgsql;

-- Test the Functions
SELECT * FROM calculate_net_cost(1);
SELECT * FROM calculate_strategy_profit_loss(1);


-- Black-Scholes Model

CREATE OR REPLACE FUNCTION cdf_normal(x numeric)
RETURNS numeric
AS $$
DECLARE
  t numeric;
BEGIN
  t := 1.0 / (1.0 + 0.2316419 * abs(x));
  RETURN 1.0 - 1.0 / sqrt(2.0 * pi()) * exp(-power(x, 2) / 2.0) * t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + 1.330274429 * t))));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Calculate the probability that an option will be in-the-money at expiration assuming a lognormal distribution of the underlying asset price
CREATE OR REPLACE FUNCTION black_scholes_probability(p_option_type CHAR(4), p_current_price DECIMAL, p_strike_price DECIMAL, p_risk_free_rate DECIMAL, p_time_to_maturity DECIMAL, p_volatility DECIMAL, p_dividend_yield DECIMAL)
RETURNS DECIMAL AS $$
DECLARE
  d1 DECIMAL;
  d2 DECIMAL;
  in_the_money_ratio DECIMAL;
BEGIN
  d1 := (ln(p_current_price / p_strike_price) + (p_risk_free_rate - p_dividend_yield + power(p_volatility, 2) / 2) * p_time_to_maturity) / (p_volatility * sqrt(p_time_to_maturity));
  d2 := d1 - p_volatility * sqrt(p_time_to_maturity);

  SELECT
    (CASE p_option_type
      WHEN 'CALL' THEN
        CUME_DIST() OVER (ORDER BY current_price) + (1 - cdf_normal(d1) * exp(-p_dividend_yield * p_time_to_maturity)) * exp(-p_risk_free_rate * p_time_to_maturity)
      WHEN 'PUT' THEN
        CUME_DIST() OVER (ORDER BY current_price DESC) + (1 - cdf_normal(-d1) * exp(-p_dividend_yield * p_time_to_maturity)) * exp(-p_risk_free_rate * p_time_to_maturity)
    END) INTO in_the_money_ratio
  FROM underlying_assets
  WHERE current_price <> p_strike_price;

  RETURN (CASE p_option_type
    WHEN 'CALL' THEN
      (1 - in_the_money_ratio) * p_current_price / (p_strike_price * exp(-p_risk_free_rate * p_time_to_maturity))
    WHEN 'PUT' THEN
      in_the_money_ratio * p_current_price / (p_strike_price * exp(-p_risk_free_rate * p_time_to_maturity))
  END);
END;
$$ LANGUAGE plpgsql;
