#!/bin/bash
source ./vars.sh

# Parse arguments for quantity

# Get bitcoin chart data
btc_data=$(bitcoin-chart-cli --toplist 1)

# Use sed to extract the dollar value
price=$(echo "$btc_data" | sed -n 's/.*\$\([0-9,\.]*\) .*/\1/p' | tr -d ',')

# Calculate the total value if quantity is provided
if [[ -n "$quantity" ]]; then
  # Multiply the price by the quantity
  value=$(echo "$price * $quantity" | bc)

  # Use sed to extract the percentage change
  change_percent=$(echo "$btc_data" | sed -n 's/.* \([0-9\.]*%\)$/\1/p' | tr -d '%')

  # Extract the numerical value of the percentage change
  change_decimal=$(echo "$change_percent" | sed 's/\([0-9.]*\)%/\1/' | awk '{print $1/100}')

  # Calculate the dollar value of the percentage increase
  prev_value=$(printf "%.2f" $(echo "$value / (1 + ($change_decimal))" | bc))
  increase=$(printf "%.2f" $(echo "$value - $prev_value" | bc))

  cb_profit=$(printf "%.2f" $(echo "$value - ($cb * $quantity)" | bc))
  cb_profit_formatted=$(printf "%'.0f" "$cb_profit")

  # Format the increase with a comma for thousands separator
  increase_formatted=$(printf "%'.0f" "$increase")

else
  # If quantity is not provided, set value and increase to zero
  value=0
  increase_formatted=0
fi

# Use sed to extract the percentage change
change_percent=$(echo "$btc_data" | sed -n 's/.* \([0-9\.]*%\)$/\1/p' | tr -d '%')

# Determine the color for the percentage change
if [ -n "$change_percent" ] && [ $(echo "$change_percent < 0" | bc) -eq 1 ]; then
    percent_color="\e[31m"  # red
else
    percent_color="\e[32m"  # green
fi

if [ -n "$cb_profit" ] && [ $(echo "$cb_profit < 0" | bc) -eq 1 ]; then
    cb_color="\e[31m"  # red
else
    cb_color="\e[32m"  # green
fi

  # Add a plus or minus symbol before the increase depending on its sign
  if [ $(echo "$increase >= 0" | bc) -eq 1 ]; then
    increase_formatted="+\$$increase_formatted"
    change_percent="+$change_percent"
  else
    increase_formatted="-\$$increase_formatted"
  fi

  if [ $(echo "$cb_profit >= 0" | bc) -eq 1 ]; then
    cb_profit_formatted="+\$$cb_profit_formatted"
  else
    cb_profit_formatted="-\$$cb_profit_formatted"
  fi

# Format and print the formatted, colorized result
price_formatted=$(printf "%'.0f" "$price")
value_formatted=$(printf "%'.0f" "$value")
cb_formatted=$(printf "%'.0f" "$cb")

printf "\e[33m\n\t──▄▄█▀▀▀▀▀█▄▄──
\t▄█▀░░▄░▄░░░░▀█▄
\t█░░░▀█▀▀▀▀▄░░░█
\t█░░░░█▄▄▄▄▀░░░█
\t█░░░░█░░░░█░░░█
\t▀█▄░▀▀█▀█▀░░▄█▀
\t──▀▀█▄▄▄▄▄█▀▀──\033[0m\n\n"


printf "      ${percent_color}Price: \$%s%s%s%%\e[0m\n" "$price_formatted" " " "$change_percent"
printf "   Portfolio: \$%s %s\n" "$value_formatted" "$increase_formatted" 
printf "       CB: \$%s %s\n" "$cb_formatted" "$cb_profit_formatted"

