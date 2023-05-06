# Options-Trading-Simulator

This SQL code creates several tables for storing data related to options trading and implements various functions for analyzing trading strategies.

## Table Structures
The code creates the following tables:

* `underlying_assets`: stores data for underlying assets such as stocks, including their ID, current price, ticker symbol, and company name.
* `options_contracts`: stores data for options contracts, including their ID, underlying asset ID, option type (call or put), strike price, expiration date, risk-free rate, volatility, and dividend yield.
* `trades`: stores data for trades made on options contracts, including their ID, options contract ID, trade type (buy or sell), quantity, trade date, and trade price.
* `trading_strategies`: stores data for trading strategies, including their ID and name.
* `strategy_trades`: stores data for the relationship between trading strategies and trades, linking the two through their IDs.

## Data Insertion
The code inserts sample data into the tables, including underlying assets, options contracts, trades, and trading strategies.

## Functions
The code includes several functions for querying and analyzing data:

* `get_options_contracts`: retrieves all options contracts for a specific underlying asset.
* `get_trades_by_contract`: retrieves all trades for a specific options contract.
* `get_trades_by_strategy`: retrieves all trades for a specific trading strategy.
* `calculate_net_cost`: calculates the net cost of a trading strategy.
* `calculate_strategy_profit_loss`: calculates the total profit or loss for a trading strategy.
* `cdf_normal`: calculates the cumulative distribution function of a standard normal distribution at x.
* `black_scholes_probability`: calculates the probability that an option will be in-the-money at expiration assuming a lognormal distribution of the underlying asset price.
