#!/bin/bash

./scripts/compile_affinity.sh

./scripts/test_ref.sh
./scripts/test_scheduling.sh
./scripts/test_best_scheduling.sh
./scripts/test_affinity.sh