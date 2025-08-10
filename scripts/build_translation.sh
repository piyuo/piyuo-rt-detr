#!/bin/bash# Script to convert CSV translation files to JSON files per locale
# Usage:
#   ./scripts/build_translation.sh         # Build all CSV files
#   ./scripts/build_translation.sh page    # Build only page.csv
#   ./scripts/build_translation.sh terms   # Build only terms.csv

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
TRANSLATION_DIR="./translation"
OUTPUT_DIR="./public/messages"

# Function to display usage
usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo "  $0                    # Build all CSV files in /translation"
    echo "  $0 [filename]         # Build specific CSV file (without .csv extension)"
    echo ""
    echo -e "${BLUE}Examples:${NC}"
    echo "  $0 page               # Build page.csv only"
    echo "  $0 terms              # Build terms.csv only"
    echo "  $0 privacy            # Build privacy.csv only"
}

# Function to log messages
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to process a single CSV file
process_csv() {
    local csv_file="$1"
    local filename=$(basename "$csv_file" .csv)

    log "Processing $csv_file..."

    if [[ ! -f "$csv_file" ]]; then
        error "File not found: $csv_file"
        return 1
    fi

    # Create Python script to process CSV
    cat > /tmp/process_csv.py << 'EOF'
import csv
import json
import os
import sys

def process_csv_file(csv_file, output_dir, filename):
    try:
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            header = next(reader)

            if header[0] != 'key':
                print(f'ERROR: First column must be "key", found: {header[0]}')
                return False

            languages = header[1:]  # Skip 'key' column
            print(f'Found {len(languages)} languages')

            # Initialize data structures for each language
            lang_data = {lang: {} for lang in languages}

            # Process all rows
            for row_num, row in enumerate(reader, start=2):
                if not row or not row[0].strip():  # Skip empty rows
                    continue

                key = row[0]

                for i, lang in enumerate(languages):
                    value_index = i + 1
                    if value_index < len(row):
                        value = row[value_index]
                        lang_data[lang][key] = value
                    else:
                        print(f'WARNING: Missing value for key "{key}" in language "{lang}" at line {row_num}')

            # Write JSON files for each language
            for lang, data in lang_data.items():
                lang_dir = os.path.join(output_dir, lang)
                os.makedirs(lang_dir, exist_ok=True)

                output_file = os.path.join(lang_dir, f'{filename}.json')

                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(data, f, ensure_ascii=False, indent=2)

                print(f'✓ Created {output_file}')

            return True

    except Exception as e:
        print(f'ERROR: {str(e)}')
        return False

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3 process_csv.py <csv_file> <output_dir> <filename>")
        sys.exit(1)

    csv_file = sys.argv[1]
    output_dir = sys.argv[2]
    filename = sys.argv[3]

    success = process_csv_file(csv_file, output_dir, filename)
    sys.exit(0 if success else 1)
EOF

    # Run Python script
    python3 /tmp/process_csv.py "$csv_file" "$OUTPUT_DIR" "$filename"

    if [[ $? -ne 0 ]]; then
        error "Failed to process $csv_file"
        return 1
    fi

    # Clean up
    rm -f /tmp/process_csv.py
}

# Main script logic
main() {
    log "Starting translation build process..."

    # Check if translation directory exists
    if [[ ! -d "$TRANSLATION_DIR" ]]; then
        error "Translation directory not found: $TRANSLATION_DIR"
        exit 1
    fi

    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    if [[ $# -eq 0 ]]; then
        # No arguments - process all CSV files
        log "Building all CSV files in $TRANSLATION_DIR..."

        local csv_files=("$TRANSLATION_DIR"/*.csv)

        if [[ ${#csv_files[@]} -eq 0 || ! -f "${csv_files[0]}" ]]; then
            error "No CSV files found in $TRANSLATION_DIR"
            exit 1
        fi

        for csv_file in "${csv_files[@]}"; do
            process_csv "$csv_file"
        done

    elif [[ $# -eq 1 ]]; then
        # One argument - process specific file
        local target_file="$1"

        # Handle help argument
        if [[ "$target_file" == "-h" || "$target_file" == "--help" ]]; then
            usage
            exit 0
        fi

        # Add .csv extension if not present
        if [[ "$target_file" != *.csv ]]; then
            target_file="$target_file.csv"
        fi

        local csv_path="$TRANSLATION_DIR/$target_file"

        log "Building specific file: $csv_path..."
        process_csv "$csv_path"

    else
        error "Too many arguments. Use -h for help."
        usage
        exit 1
    fi

    log "Translation build completed successfully! 🎉"
    log "Generated JSON files are available in: $OUTPUT_DIR"
}

# Run main function with all arguments
main "$@"
