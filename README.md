# Driver and module checker

A simple bash script to quickly check active drivers and available kernel modules for USB and PCI devices in a single view.

## 🛠️ Requirements

It only needs `lspci` and `lsusb`, which come in packages: `pciutils` and `usbutils`.

## 📖 Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/diegarius/drivers.git
   cd drivers

2. Make the script executable:
   ```bash
    chmod +x drivers.sh

3. Run the script:
   ```bash
    ./drivers.sh

