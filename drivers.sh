#!/bin/bash

declare -a results 
results=()

#0      1       2       3       4       5           6
#Index  USB/PCI Bus     Device  Driver  Modules   Desc
readonly COLS=7

row=-1
index=0

# lspci data extraction
while read -r linea; do
    if [[ $linea == [0-9][0-9]* ]]; then
        (( row++ ))
        index=$((row*COLS))
        results[((index))]=$((row+1))
        results[((index+1))]="PCI"
        busdev=${linea%% *}
        results[((index+2))]=${busdev%%:*}
        results[((index+3))]=${busdev#*:*}
        results[((index+6))]=${linea#* }
    fi
    if [[ $linea == *"driver"* ]]; then
        results[((row*COLS+4))]=${linea#*: }
    fi
    if [[ $linea == *"modules"* ]]; then
        results[((row*COLS+5))]=${linea#*: }
    fi
done < <(lspci -v)

# lsusb -t data extraction
mapfile -t usbdrivers <<< $(lsusb -t)
size_usbdrivers="${#usbdrivers[@]}"

# lsusb data extraction
found_bus=0
while read -r linea; do
    ((row++))
    index=$((row*COLS))
    results[((index))]=$((row+1))
    results[((index+1))]="USB"
    bus=${linea%% D*}
    results[((index+2))]=${bus#* }
    dev=${linea%%:*}
    results[((index+3))]=${dev#*ce }
    results[((index+6))]=$(sed -E "s/.*:[0-9a-z]{4} //" <<< $linea )
    
    # usb drivers extraction
    for ((i=0; i<="$size_usbdrivers"; i++)); do
        if [[ ${usbdrivers[i]} == *"Bus ${results[((index+2))]}"* ]]; then
            for ((j=i; j<="$size_usbdrivers"; j++)); do
                if [[ ${usbdrivers[j]} == *"Dev ${results[((index+3))]}"* ]]; then
                    drv=${usbdrivers[j]#*Driver=}
                    results[((index+4))]=${drv%%,*}
                    break
                fi
            done
        fi
    done
done < <(lsusb)

# table, options and details
while true; do
    clear
    format="%3s %-4s %-4s %-6s %-14s %-14.14s %-24s\n"
    printf "$format" "ID" "Type" "Bus" "Device" "Driver" "Modules" "Description"

    for ((i=0; i<=$index; i+=$COLS)); do
        printf "$format" "${results[i]}" "${results[((i+1))]}" "${results[((i+2))]}" "${results[((i+3))]}" "${results[((i+4))]}" "${results[((i+5))]}" "${results[((i+6))]}"
    done
    
    printf "\nEnter a number from ID column and press enter to see detailed information about a device.\n"
    printf "Press q and press enter to quit.\n"
    read -p "Option: " option

    if [[ $option =~ [0-9]{1,3} ]]; then
        if (( option > 0 && option <= (index/COLS)+1 )); then
            j=$(((option-1)*COLS))
            if [[ ${results[((j+1))]} == "PCI" ]]; then
                lspci -s "${results[((j+2))]}:${results[((j+3))]}" -v 2>/dev/null | less -S 
            else
                lsusb -s "${results[((j+2))]}:${results[((j+3))]}" -v 2>/dev/null | less -S
            fi
        fi
    fi

    if [[ $option == "q" ]]; then
        break
    fi
done

exit 0
