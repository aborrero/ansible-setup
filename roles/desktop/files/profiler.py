#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0

# (C) 2022 by Arturo Borrero Gonzalez <arturo@debian.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

import yaml
import argparse
import logging
import subprocess
import sys
import os


def read_yaml(file: str):
    try:
        with open(os.path.expanduser(file)) as f:
            return yaml.safe_load(f.read())
    except Exception as e:
        logging.error(f"couldn't read file '{file}': {e}")
        sys.exit(1)


def parse_args():
    desc = "Utility to manage setup profiles and other configs"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument(
        "--cfg",
        default="~/.config/profiler.yaml",
        help="YAML config file. Defaults to '%(default)s'",
    )

    subparser = parser.add_subparsers(
        help="possible operations",
        dest="op",
        required=True,
    )

    subparser.add_parser(
        "list",
        help="list profiles",
    )

    execparser = subparser.add_parser(
        "exec",
        help="list profiles",
    )
    execparser.add_argument("profile_name")

    return parser.parse_args()


def op_list(config: dict):
    for i in config:
        name = i["profile"]
        desc = i["description"]
        print(f" * {name}: {desc}")


def run(command: str):
    r = subprocess.run(command, shell=True, capture_output=True)
    if r.returncode != 0:
        logging.warning(f"command failed: {command}")
        logging.warning(f"{r.stderr}")


def setup_run(setup: dict):
    for command in setup:
        run(command)

def op_exec(config: dict, profile_name: str):
    for i in config:
        name = i["profile"]
        if name == profile_name:
            setup_run(i["setup"])
            return

    logging.error("profile not found")
    sys.exit(1)


def main():
    args = parse_args()

    config = read_yaml(args.cfg)

    if args.op == "list":
        op_list(config)
    elif args.op == "exec":
        op_exec(config, args.profile_name)

if __name__ == "__main__":
    main()
