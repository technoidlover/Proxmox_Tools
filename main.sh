#!/bin/bash

# Clear the screen
clear

# Function to calculate padding for centering text
center_text() {
    local text=$1
    local terminal_width=$(tput cols)
    local text_length=${#text}
    local padding=$(( (terminal_width - text_length) / 2 ))
    printf "%${padding}s%s%${padding}s\n" "" "$text" ""
}

# Function to display the ASCII logo
display_logo() {
    center_text "|-------------------------------------------------------------------------------------------------------------------------------------------------------|"
    center_text "|                                                                                                                                                       |"
    center_text "|                                                                                                                                                       |"
    center_text "|                                                                                                                                                       |"
    center_text "|     _   _           _           _                _____ _             _ _         _____                                     _______          _         |"
    center_text "|    | \ | |         | |         (_)              / ____| |           | (_)       |  __ \                                   |__   __|        | |        |"
    center_text "|    |  \| | ___   __| | ___  ___ _  __ _ _ __   | (___ | |_ _   _  __| |_  ___   | |__) | __ _____  ___ __ ___   _____  __    | | ___   ___ | |___     |"
    center_text "|    | . | |/ _ \ / _| |/ _ \/ __| |/ _  | |_ \   \___ \| __| | | |/ _| | |/ _ \  |  ___/ |__/ _ \ \/ / |_ | _ \ / _ \ \/ /    | |/ _ \ / _ \| / __|    |"
    center_text "|    | |\  | (_) | (_| |  __/\__ \ | (_| | | | |  ____) | |_| |_| | (_| | | (_) | | |   | | | (_) >  <| | | | | | (_) >  <     | | (_) | (_) | \__ \    |"
    center_text "|    |_| \_|\___/ \__,_|\___||___/_|\__, |_| |_| |_____/ \__|\__,_|\__,_|_|\___/  |_|   |_|  \___/_/\_\_| |_| |_|\___/_/\_\    |_|\___/ \___/|_|___/    |"
    center_text "|                                    __/ |                                                                                                              |"
    center_text "|                                   |___/                                                                                                               |"
    center_text "|                                                                                                                                                       |"
    center_text "|                                                                made by MinhNH                                                                         |"
    center_text "|                                                                                                                                                       |"
    center_text "|                                                                                                                                                       |"
    center_text "|                                                                                                                                                       |"
    center_text "|-------------------------------------------------------------------------------------------------------------------------------------------------------|"
    echo
}

# Function to list all .sh files in the current directory
list_scripts() {
    scripts=($(ls *.sh 2>/dev/null))
    if [ ${#scripts[@]} -eq 0 ]; then
        center_text "❌ No .sh files found in the current directory."
        exit 1
    fi

    center_text "📂 Available scripts in the current directory:"
    for i in "${!scripts[@]}"; do
        center_text "  $((i+1)). ${scripts[$i]}"
    done
}

# Function to execute the selected script
execute_script() {
    local script_name=$1
    if [ -f "$script_name" ]; then
        center_text "🚀 Executing $script_name..."
        bash "$script_name"
    else
        center_text "❌ Error: $script_name does not exist."
    fi
}

# Main script
display_logo
list_scripts

# Prompt the user to select a script
center_text "Enter the number of the script you want to execute (1-${#scripts[@]}): "
read -p "" CHOICE

# Validate the choice
if [[ "$CHOICE" =~ ^[0-9]+$ ]] && (( CHOICE >= 1 && CHOICE <= ${#scripts[@]} )); then
    SELECTED_SCRIPT="${scripts[$((CHOICE-1))]}"
    execute_script "$SELECTED_SCRIPT"
else
    center_text "❌ Invalid choice. Please enter a number between 1 and ${#scripts[@]}."
fi