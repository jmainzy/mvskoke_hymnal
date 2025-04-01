import argparse
import os
import re

title_marker = "###"
directive = "{{{0}: {1}}}\n"

def write_song(song_dict, output_dir, index):
    # Create a unique filename based on the song content
    title = song_dict["title"].replace(" ", "_")
    # format index with leading zeros
    index = str(index).zfill(3)
    filename = f"{index}_{title}.chordpro"
    output_file = os.path.join(output_dir, filename)
    
    with open(output_file, 'w') as out_file:
        out_file.write(directive.format("title", song_dict["title"]))
        if "subtitle" in song_dict:
            out_file.write(directive.format("subtitle", song_dict["subtitle"]))
        out_file.write("\n")
        for line in song_dict["lyrics"]:
            out_file.write(line+"\n")
        if "page" in song_dict:
            out_file.write("\n")
            for line in song_dict["page"]:
                out_file.write(directive.format("comment", line))
        if "notes" in song_dict:
            out_file.write("\n")
            for line in song_dict["notes"]:
                out_file.write(directive.format("comment", line))
    
    print(f"Wrote song to {output_file}")

def process_file(input_file, output_dir):
    try:
        index = input_file.split("_")[-1].split(".")[0]
        with open(input_file, 'r') as infile:
            song_dict = {}
            song_dict["lyrics"] = []
            song_dict["title"] = ""
            song_dict["notes"] = []
            song_dict["page"] = []
            title_flag = False
            for line in infile.readlines():
                line = line.strip()
                if title_marker in line:
                    title_flag = True
                    continue
                elif title_flag:
                    song_dict["title"] = line
                    title_flag = False
                    continue

                if "“" in line:
                    song_dict["subtitle"] = line
                elif "page" in line:
                    song_dict["page"].append(line)
                # if line starts with a number and a period, it's a verse
                elif re.match(r'^\d+\.', line):
                    # if there's already some lyrics, end the previous verse
                    if song_dict["lyrics"]:
                        song_dict["lyrics"].append("{end_of_verse}\n")
                    verse_num = line.split(".")[0]
                    song_dict["lyrics"].append(directive.format("start_of_verse", verse_num).strip())
                    # remove the verse number from the line
                    line = line.split(".")[1].strip()
                    song_dict["lyrics"].append(line)
                elif not song_dict["title"]:
                    # notes before the title
                    song_dict["notes"].append(line)
                else:
                    song_dict["lyrics"].append(line)
            print(song_dict)
            song_dict["lyrics"].append("{end_of_verse}\n")
            # Write the song to a file
            write_song(song_dict, output_dir, index)

    except FileNotFoundError:
        print(f"Error: The file {input_file} does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    parser = argparse.ArgumentParser(description="Copy contents of one file to another.")
    parser.add_argument('input_file', help="Path to the input file.")
    parser.add_argument('output_dir', help="Directory for the output file.")
    args = parser.parse_args()

    # make sure the output directory exists
    if not os.path.exists(args.output_dir):
        os.makedirs(args.output_dir)
    
    process_file(args.input_file, args.output_dir)

if __name__ == "__main__":
    main()