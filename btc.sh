#!/bin/bash

# Default quantity value
quantity=1

# Parse arguments for quantity
while getopts "q:" opt; do
  case $opt in
    q)
      quantity="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Get bitcoin chart data
btc_data=$(bitcoin-chart-cli --toplist 1)

# Use sed to extract the dollar value
price=$(echo "$btc_data" | sed -n 's/.*\$\([0-9,\.]*\) .*/\1/p' | tr -d ',')

# Multiply the price by the quantity
value=$(echo "$price * $quantity" | bc)

# Use sed to extract the percentage change
change=$(echo "$btc_data" | sed -n 's/.* \([0-9\.]*%\)$/\1/p' | tr -d '%')

# Determine the color for the percentage change
if [ -n "$change" ] && [ $(echo "$change < 0" | bc) -eq 1 ]; then
    color="\e[31m"  # red
else
    color="\e[32m"  # green
fi

# Format and print the formatted, colorized result
price_formatted=$(printf "%'.0f" "$price")
value_formatted=$(printf "%'.0f" "$value")

printf "\e[32mCurrent Price:\e[0m \e[33m\$%s\e[0m\n" "$price_formatted"
printf "\e[32mTotal Value:\e[0m \e[33m\$%s\e[0m\n" "$value_formatted"
printf "${color}Change/24h: %s%%\e[0m\n" "$change"

