#!/bin/bash

# Grid size
GRID_WIDTH=26
GRID_HEIGHT=26

# Screen size
SCREEN_WIDTH=80
SCREEN_HEIGHT=24

# Compression factor
COMPRESSION_FACTOR=2

# Initial position of the entity
INITIAL_X=$((GRID_WIDTH / 2))
INITIAL_Y=$((GRID_HEIGHT - 1))

# Random seed for shuffling
RANDOM_SEED=12345

# Initialize the grid
grid=()
for ((i = 0; i < GRID_HEIGHT; i++)); do
  grid+=("$(printf '%*s' $GRID_WIDTH | tr ' ' '0')")
done

# Function to display the grid
display_grid() {
  # Check if the grid exceeds the screen size
  if ((GRID_HEIGHT > SCREEN_HEIGHT || GRID_WIDTH > SCREEN_WIDTH)); then
    local compressed_grid=()
    for ((i = 0; i < GRID_HEIGHT; i++)); do
      local row=""
      for ((j = 0; j < GRID_WIDTH; j++)); do
        if ((j % COMPRESSION_FACTOR == 0)); then
          row+=" ${grid[i]:j:1} "
        fi
      done
      compressed_grid+=("$row")
    done

    # Display the compressed grid
    printf "\n%s\n" "${compressed_grid[@]}"
  else
    # If the grid fits the screen, display it normally
    printf "\n%s\n" "${grid[@]}"
  fi
}

# Function to flip a random bit in the grid
flip_random_bit() {
  local x=$((RANDOM % GRID_WIDTH))
  local y=$((RANDOM % GRID_HEIGHT))
  local row="${grid[y]}"
  local bit="${row:x:1}"
  if [[ "$bit" == "0" ]]; then
    grid[y]="${row:0:x}1${row:x+1}"
  else
    grid[y]="${row:0:x}0${row:x+1}"
  fi
}

# Function to update the grid based on rules
update_grid() {
  # Create a copy of the grid
  local previous_grid=("${grid[@]}")

  # Loop through each pixel in the grid
  for ((y = 0; y < GRID_HEIGHT; y++)); do
    for ((x = 0; x < GRID_WIDTH; x++)); do
      local neighbor_bits=""
      for dx in {-1..1}; do
        for dy in {-1..1}; do
          if ((dx != 0 || dy != 0)); then
            local nx=$((x + dx))
            local ny=$((y + dy))
            if ((nx >= 0 && nx < GRID_WIDTH && ny >= 0 && ny < GRID_HEIGHT)); then
              neighbor_bits+=${previous_grid[ny]:nx:1}
            fi
          fi
        done
      done

      # Check the rules and update the current pixel
      local current_bit="${previous_grid[y]:x:1}"
      case "$current_bit" in
        0)
          if [[ "$neighbor_bits" == *"1"* ]]; then
            grid[y]="${previous_grid[y]:0:x}1${previous_grid[y]:x+1}"
          fi
          ;;
        1)
          if [[ "$neighbor_bits" != *"1"* ]]; then
            grid[y]="${previous_grid[y]:0:x}0${previous_grid[y]:x+1}"
          fi
          ;;
      esac
    done
  done
}

# Function to compress the grid by condensing continuous 1s into single pixels
compress_grid() {
  local compressed_grid=()
  for ((y = 0; y < GRID_HEIGHT; y++)); do
    local row="${grid[y]}"
    local compressed_row=""
    local continuous_count=0
    for ((x = 0; x < GRID_WIDTH; x++)); do
      local current_bit="${row:x:1}"
      if [[ "$current_bit" == "1" ]]; then
        ((continuous_count++))
      else
        if ((continuous_count > 0)); then
          compressed_row+="$continuous_count"
          continuous_count=0
        fi
        compressed_row+="0"
      fi
    done
    if ((continuous_count > 0)); then
      compressed_row+="$continuous_count"
    fi
    compressed_grid+=("$compressed_row")
  done
  grid=("${compressed_grid[@]}")
}

# Function to load external binary data into the grid
load_binary_data() {
  local binary_file="$1"
  if [[ ! -f "$binary_file" ]]; then
    echo "Error: Binary file '$binary_file' not found."
    exit 1
  fi

  # Read binary data from file and update grid
  local binary_data=$(xxd -b "$binary_file" | awk '{print $2}' | tr -d '\n')
  for ((y = 0; y < GRID_HEIGHT; y++)); do
    local row=""
    for ((x = 0; x < GRID_WIDTH; x++)); do
      local index=$((y * GRID_WIDTH + x))
      if ((index < ${#binary_data})); then
        row+=${binary_data:index:1}
      else
        row+="0"
      fi
    done
    grid[y]="$row"
  done
}

# Main loop to run the entity animation
while true; do
  clear
  draw_grid
  update_grid
  compress_grid

  # Check if the entity has grown too large and needs to be compressed
  local total_bits=$(count_total_bits)
  if ((total_bits > MAX_ENTITY_SIZE)); then
    echo "Entity has grown too large. Compressing..."
    compress_grid
  fi

  sleep $FRAME_DELAY
done

  # Load external binary data if provided
  if [[ -n "$BINARY_FILE" ]]; then
    load_binary_data "$BINARY_FILE"
    echo "Loaded binary data from file: $BINARY_FILE"
  fi

  # Main loop to run the entity animation
  while true; do
    clear
    draw_grid
    update_grid
    compress_grid

    # Check if the entity has grown too large and needs to be compressed
    local total_bits=$(count_total_bits)
    if ((total_bits > MAX_ENTITY_SIZE)); then
      echo "Entity has grown too large. Compressing..."
      compress_grid
    fi

    sleep $FRAME_DELAY
  done
