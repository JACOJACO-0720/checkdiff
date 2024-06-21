#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

LOG_DIR="/home/aivres/diffAction"
CURRENT_LOG="${LOG_DIR}/current_system_info_${TIMESTAMP}.log"
DIFF_LOG="${LOG_DIR}/diff_result_${TIMESTAMP}.log"

# -p is safe
mkdir -p $LOG_DIR

echo "Collecting current system information..."

echo "### BIOS ###" > $CURRENT_LOG
sudo lshw | grep -A 8 "BIOS" >> $CURRENT_LOG

echo "### BMC ###" >> $CURRENT_LOG
sudo ipmitool sdr list >> $CURRENT_LOG
sudo ipmitool sel elist >> $CURRENT_LOG

echo "### CPU ###" >> $CURRENT_LOG
lscpu >> $CURRENT_LOG

echo "### Drives ###" >> $CURRENT_LOG
lsblk | awk '{$4=""; print $0}' >> $CURRENT_LOG

echo "### PCI ###" >> $CURRENT_LOG
lspci >> $CURRENT_LOG

echo "### DMIDECODE ###" >> $CURRENT_LOG
sudo dmidecode >> $CURRENT_LOG

echo "### FRU ###" >> $CURRENT_LOG
ipmitool fru print >> $CURRENT_LOG

echo "### I2C ###" >> $CURRENT_LOG
sudo i2cdetect -l >> $CURRENT_LOG

echo "### Summary ###" >> $CURRENT_LOG
sudo lshw | grep -A 8 "BIOS" >> $CURRENT_LOG

PREVIOUS_LOG=$(ls -t ${LOG_DIR}/current_system_info_*.log 2>/dev/null | head -n 1)

if [ -n "$PREVIOUS_LOG" ]; then
    echo "Comparing with previous log ($PREVIOUS_LOG)..."

    diff -u $PREVIOUS_LOG $CURRENT_LOG > $DIFF_LOG

    if [ -s $DIFF_LOG ]; then
        echo "Differences found:"
        cat $DIFF_LOG
    else
        echo "succeed"
    fi
else
    echo "No previous log found, this is the first run."
fi

find $LOG_DIR -type f -name "current_system_info_*.log" -not -name "$(basename $CURRENT_LOG)" -delete
