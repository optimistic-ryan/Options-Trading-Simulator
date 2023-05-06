# Options-Trading-Simulator

This SQL code creates several tables for storing data related to options trading and implements various functions for analyzing trading strategies.

## Table Structures
The code creates the following tables:

* `underlying_assets`: stores data for underlying assets such as stocks, including their ID, current price, ticker symbol, and company name.
* `options_contracts`: stores data for options contracts, including their ID, underlying asset ID, option type (call or put), strike price, expiration date, risk-free rate, volatility, and dividend yield.
* `trades`: stores data for trades made on options contracts, including their ID, options contract ID, trade type (buy or sell), quantity, trade date, and trade price.
* `trading_strategies`: stores data for trading strategies, including their ID and name.
* `strategy_trades`: stores data for the relationship between trading strategies and trades, linking the two through their IDs.
