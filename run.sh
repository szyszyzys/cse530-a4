#!/bin/bash

GEM5_BINARY="/home/other/CSE530-FA2022/gem5/build_a4/build/X86/gem5.opt"

GEM5_CONFIG_SCRIPT="cse530_a4_sys_config.py"

BINARY_PATH="./a.out"
# Set the output directory where results will be saved
OUTPUT_DIR="experiment_results"

mkdir -p "$OUTPUT_DIR"

STATES_DIR="states"
mkdir -p "$STATES_DIR"

## CPU models to test
#CPU_MODELS=("X86TimingSimpleCPU" "X86MinorCPU")
#
## CPU clock frequencies (in Hz)
#CPU_CLOCKS=("1GHz" "1.5GHz" "2GHz" "2.5GHz" "3GHz")
#
## Memory configurations to test
#MEMORY_CONFIGS=("DDR3_1600_8x8" "DDR3_2133_8x8" "LPDDR2_S4_1066_1x32")


issue_widths=(2 4 6 8)
branch_predictors=("2bit" "tournament" "bimode" "ltage")
num_robs=(16 64 96 128 192)

# Loop over CPU models
for issue_width in "${issue_widths[@]}"; do
    # Loop over CPU clock frequencies
    for branch_predictor in "${branch_predictors[@]}"; do
        # Loop over memory configurations
        for num_rob in "${num_robs[@]}"; do
            # Construct a unique directory name based on the configuration
            OUTPUT_SUBDIR="${OUTPUT_DIR}/${branch_predictor}_${issue_width}_${num_rob}"

            # Create the output subdirectory
            mkdir -p "$OUTPUT_SUBDIR"

            # Run GEM5 with the specified configuration
            $GEM5_BINARY -d "$OUTPUT_SUBDIR" $GEM5_CONFIG_SCRIPT \
                --cse530-core-config="None"    \
                --cse530-issue-width="$issue_width" \
                --cse530-branch-predictor="$branch_predictor" \
                --cse530-num-robs="$num_rob" \
                --outdir="$OUTPUT_DIR" \
                --redirect-stderr /home/other/CSE530-FA2022/cse530_a4/cse530_a4_sys_config.py \
                --binfile=/home/other/CSE530-FA2022/cse530_a4/benchmarks/stanford/Quicksort  --l1i_size "4kB" --l1d_size "4kB" --l2_size "32kB"

            cp "${OUTPUT_SUBDIR}"/stats.txt "${STATES_DIR}/${branch_predictor}_${issue_width}_${num_rob}.txt"
            echo "Experiment completed: ${branch_predictor} ${issue_width} ${num_rob}"
        done
    done
done

echo "All experiments completed."
