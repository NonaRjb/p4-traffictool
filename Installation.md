---
title: Getting Started
layout: default
filename: Installation
--- 
# Getting Started
## Dependencies
* **p4c compiler:** The input to p4-traffictool is the json file produced by the open-source [p4c](https://github.com/p4lang/p4c) compiler, specifically the `p4c-bm2-ss` backend. You can use the scripts [here](https://github.com/jafingerhut/p4-guide) to install `p4c` and the `p4c-bm2-ss` backend. For the `p4c-bm2-ss` backend to compile correctly, you may need to install [behavioral model](https://github.com/p4lang/behavioral-model) first. Post installation, `p4c-bm2-ss` should be available in your _PATH_. 
* **Python interpreter:** p4-traffictool is written in Python and can work with both Python2 and Python3. Most Linux distributions come preinstalled with either Python2 or Python3. Required python packages: `json`, `sys`, `os`, `re` and `tabulate`. The first four are included in the standard python installation, you can install `tabulate` with `pip install tabulate`.
* **Traffic Tools:** Since you are trying to install and use p4-traffictool, we assume you have the appropriate traffic generation/parsing tools for which you would be auto-generating the code. p4-traffictool currently supports code generation for [Scapy](https://scapy.net), [PcapPlusPlus](https://github.com/seladb/PcapPlusPlus), [MoonGen](https://github.com/emmericp/MoonGen/) and [Wireshark Dissector](https://wiki.wireshark.org/Lua/Dissectors).

## Installation
* Clone this repository. 
```
git clone https://github.com/djin31/p4-traffictool.git
```
* Run `configure.sh` to check for dependencies.
* (Optional) Run `install.sh` to add the alias `p4-traffictool` to `.bashrc` in order to avoid specifying the full path to `p4-traffictool.sh` script.

## Installation checks and tests (optional)
To perform a sanity check that the code produced by the tool is compatible with the tools available on your system you can use `./runtests.sh`. It runs the tool with a sample p4 program and its corresponding json file to produce scapy codes and checks that they are equivalent.
It then uses the generated scapy code to produce a pcap file `tests_data.pcap`. Then it generates the lua dissector and uses it with tshark to parse the pcap file and checks if the fields are parsed correctly.

Fulfilling all the above required tests prints `Tests passed`. This ensures that the tool is compatible with the wireshark and scapy installation on your system. If your system is missing `p4c` or `p4c-bm2-ss` then suitable error message is displayed before `Tests passed`.

Use `./runtests.sh clean` to wipe out all the code and pcap file generated from the tests directory.
