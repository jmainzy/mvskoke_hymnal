import csv
import json
import sys

def csv_to_json(tsv_file_path, json_file_path):
    try:
        with open(tsv_file_path, mode='r', encoding='utf-8') as csv_file:
            csv_reader = csv.DictReader(csv_file, delimiter='\t')
            data = [row for row in csv_reader]

        with open(json_file_path, mode='w', encoding='utf-8') as json_file:
            json.dump(data, json_file, indent=4)

        print(f"TSV data successfully converted to JSON and saved to {json_file_path}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python tsv_to_json.py <input_csv_file> <output_json_file>")
    else:
        tsv_file_path = sys.argv[1]
        json_file_path = sys.argv[2]
        csv_to_json(tsv_file_path, json_file_path)