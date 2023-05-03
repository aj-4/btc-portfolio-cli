#!/bin/bash

# Check if -q flag is provided
if ! [[ "$*" =~ "-q" ]]; then
  echo "Error: Missing -q flag for quantity." >&2
  exit 1
fi

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
    color="\e[31m"  # red
else
    color="\e[32m"  # green
fi

  # Add a plus or minus symbol before the increase depending on its sign
  if [ $(echo "$increase >= 0" | bc) -eq 1 ]; then
    increase_formatted="+\$$increase_formatted"
    change_percent="+$change_percent"
  else
    increase_formatted="-\$$increase_formatted"
  fi

# Format and print the formatted, colorized result
price_formatted=$(printf "%'.0f" "$price")
value_formatted=$(printf "%'.0f" "$value")
increase_formatted=$(echo "$increase_formatted" | tr -d ',')

printf "Current Price:\e[0m \e[33m\$%s\e[0m\n" "$price_formatted"
printf "Total Value:\e[0m \e[33m\$%s\e[0m\n" "$value_formatted"
printf "Change/24h: ${color}%s%% / %s\n" "$change_percent" "$increase_formatted" | sed "s/\([0-9]\)\([0-9]\{3\}\)/\1,\2/g"

