#!/bin/bash

# mise
mise trust -a
mise install

# pre-commit
mise exec -- pre-commit install
