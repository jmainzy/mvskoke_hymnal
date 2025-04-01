import argparse
import os
import shutil

def write_song(song_lines, output_dir, index):
    if not song_lines:
        return
    # Create a unique filename based on the song content
    filename = f"song_{index}.txt"
    output_file = os.path.join(output_dir, filename)
    
    with open(output_file, 'w') as out_file:
        for line in song_lines:
            out_file.write(line + '\n')
    
    print(f"Written {len(song_lines)} lines to {output_file}")

def split_file(input_file, output_dir):
    song_lines = []
    with open(input_file, 'r') as file:
        lines = file.readlines()

    song_num=1
    for line in lines:
        # Remove leading and trailing whitespace
        line = line.strip()
        # Ignore empty lines
        if line:
            song_lines.append(line)
        else:
            # empty lines start a new file
            write_song(song_lines, output_dir, song_num)
            song_num += 1
            song_lines = []
    # Write any remaining lines to a file
    write_song(song_lines, output_dir, song_num)

def main():
    parser = argparse.ArgumentParser(description="Split a text file by newlines.")
    parser.add_argument('input_file', help="Path to the input text file.")
    parser.add_argument('output_dir', help="Directory for the output files.")
    args = parser.parse_args()

    if os.path.exists(args.output_dir):
        # delete output directory if it exists
        shutil.rmtree(args.output_dir, ignore_errors=True)
    # create output directory
    os.makedirs(args.output_dir)

    split_file(args.input_file, args.output_dir)

if __name__ == "__main__":
    main()