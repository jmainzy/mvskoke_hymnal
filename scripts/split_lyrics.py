import argparse
import os
import re

directive = "{{{0}: {1}}}\n"

def get_split_lyrics(song_dict):
    """
    Splits the lyrics into English and Mvskoke
    """
    en_lyrics = []
    mus_lyrics = []
    i=0
    for line in song_dict["lyrics"]:
        if line.startswith("{"):
            # add directives to both
            en_lyrics.append(line)
            mus_lyrics.append(line)
            i=0
            continue
        elif not line.strip():
            # empty line
            en_lyrics.append(line)
            mus_lyrics.append(line)
            continue

        if i % 2 == 0:
            mus_lyrics.append(line)
        else:
            en_lyrics.append(line)
        i += 1
    return en_lyrics, mus_lyrics


def write_song(song_dict, out_file, lyrics):
    """
    Writes the song to a file
    """
    
    with open(out_file, 'w') as of:
        of.write(directive.format("title", song_dict["title"]))
        if "subtitle" in song_dict:
            of.write(directive.format("subtitle", song_dict["subtitle"]))
        of.write("\n")
        for line in lyrics:
            of.write(line+"\n")
        for line in song_dict["comments"]:
            of.write(directive.format("comment", line))
    
    print(f"Wrote song to {out_file}")

def read_file(input_file):
    try:
        song_dict = {}
        song_dict["lyrics"] = []
        song_dict["comments"] = []
        with open(input_file) as infile:
            for line in infile.readlines():
                line = line.strip()
                if line.startswith("{title:"):
                    song_dict["title"] = line.split(":")[1].strip(" }")
                elif line.startswith("{subtitle:"):
                    song_dict["subtitle"] = line.split(":")[1].strip(" }")
                elif line.startswith("{comment:"):
                    song_dict["comments"].append(line.split(":")[1].strip(" }"))
                else:
                    song_dict["lyrics"].append(line)

        return song_dict

    except FileNotFoundError:
        print(f"Error: The file {input_file} does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    parser = argparse.ArgumentParser(description="Copy contents of one file to another.")
    parser.add_argument('input_file', help="Path to the input file.")
    args = parser.parse_args()

    # make sure the output directory exists
    song = read_file(args.input_file)
    en_lyrics, mus_lyrics = get_split_lyrics(song)
    print(song)
    # remove the extension
    file_prefix = ".."+args.input_file.strip(".chordpro")
    output_file_en = file_prefix + "_en.chordpro"
    output_file_mus = file_prefix + "_mus.chordpro"
    print(f"Writing {output_file_en} and {output_file_mus}")
    write_song(song, output_file_en, en_lyrics)
    write_song(song, output_file_mus, mus_lyrics)

if __name__ == "__main__":
    main()