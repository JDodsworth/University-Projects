# Python Projects   <img src="https://github.com/JDodsworth/Univeristy-Projects/assets/171965237/3bb38632-2ab9-456c-8e26-172ef365d5fb" alt="python_icon" width="40">
The following are the list of all my python projects from university. Most have an emphasis on finance, which is one of my topics of interest.

### Learning outcomes so far... 📗
- Python fundamentals: if statments, loops, operations, objects, variables
- Sequences, containers, file access, plotting
- Error handling and state retention
- Object-riented programming
- Professional formatting standards i.e. indentations, docstrings, comments

## Approximate Root
This file is of a simple function that finds the root of any given univariate function.

## Simulated Interest Rate Paths 
The following code creates simulated interest rate paths using the Vasicek model and Monte-Carlo simulations.

## Time Series - Implied Volatility
The following code produces a time series plot of implied volatility. The implied volatility is calculated by assuming that the theoritical price of an option (calculated by the Black-Scholes fomula) is equal to the market's view of the price of the option. Then, we can find the implied volatility that achieves this condition. 

Using the following test code and csv file of option data, we produce the plot below.
```
time_series_iv('option_data.csv','output_data.csv','plot',date_field = 'date', exercise_price = 3250, int_rate_field = 'int_rate', iv_field = 'iv', maturity_field = 'dtm', option_price_field = 'mid',option_type =   'put' ,underlying_price_field = 'underlying')
```

[option_data.csv](https://github.com/user-attachments/files/15777010/option_data.csv)

![Time Series IV Plot](https://github.com/JDodsworth/Univeristy-Projects/assets/171965237/6018dc6d-7037-452a-9a5b-63b7ccc99cdc)

## Bermudan Option Pricing Model
This file contains a module dedicated to pricing bermudan options using underlying asset value trees with either a Black_scholes model or Merton model. Below is a helpful diagram illustrating the module and its particular classes and methods.

![Bermudan Option Pricing Project diagram](https://github.com/JDodsworth/Univeristy-Projects/assets/171965237/d1b3a8bd-7f72-46e9-9b75-cc63ede330ea)


