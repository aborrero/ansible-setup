#!/usr/bin/env python3

import sys
import yaml
import subprocess
import re

def show_help():
    print(f"Usage: {sys.argv[0]} [-h] <channel>")

def error(msg: str):
    print(f"ERROR: {msg}")
    exit(1)

def run(command: str):
    result = subprocess.run(command.split(' '), capture_output=True, text=True)
    return result.stdout.splitlines()

def get_channel_items(channel: str):
    return run(f"xfconf-query -c {channel} -l")

def translate_item(channel: str, item: str):
    value = run(f"xfconf-query -c {channel} -p {item}")[0]
    element = {
        "channel": channel,
        "property": item,
        "value": value,
        "type": get_type(value),
        # TODO: force_array?
        "force_array": "false"
    }

    return element

def get_type(value: str) -> str:
    if value == "true" or value == "false":
        return "bool"
    if value.isdigit():
        return "int"
    if re.match(r"^\d+(\.\d+)?$", value):
        return "double"
    return "string"

def main():
    args = sys.argv[1:]

    if len(args) != 1:
        show_help()
        exit(1)

    if args[0] in ["--help", "-h", "-H"]:
        show_help()
        exit(0)

    channel = args[0]
    channel_items = get_channel_items(channel)
    if len(channel_items) == 0:
        error("channel has no items")

    elements = []
    for item in channel_items:
        elements.append(translate_item(channel, item))

    yaml_string = yaml.safe_dump({"xfce_xfconf_data": elements})

    # do some formatting
    indent="  "
    for line in yaml_string.splitlines():
        if line.startswith("-"):
            # print empty line before each array element
            print()

        # indent each line
        print(f"{indent}{line}")

main()
