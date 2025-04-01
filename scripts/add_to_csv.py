import argparse
import pandas as pd

directive = "{{{0}: {1}}}\n"


def add_to_tsv(df, output_file):
    """
    Writes the song to a file
    """
    try:
        df.to_csv(output_file, mode='a', index=False, sep="\t", quotechar='"', header=False)
        print(f"Wrote song to {output_file}")
    except Exception as e:
        print(f"Error writing to {output_file}: {e}")

def make_dataframe(song_dict_en, song_dict_mus):
    # convert to dataframe
    id = song_dict_mus["id"]
    df = pd.DataFrame({
        "id": song_dict_mus["id"],
        "title": song_dict_mus["title"],
        "title_en": song_dict_mus["subtitle"],
        "lyrics_en": str("\n".join(song_dict_en["lyrics"])),
        "lyrics": str("\n".join(song_dict_mus["lyrics"])),
        "tags": str(song_dict_mus["comments"]),
        "pages": str(song_dict_mus["pages"])
    }, index=[int(id)])
    return df
    
def read_file(input_file):
    try:
        song_dict = {}
        song_dict["lyrics"] = []
        song_dict["comments"] = []
        song_dict["pages"] = []
        song_dict["subtitle"] = None
        with open(input_file) as infile:
            for line in infile.readlines():
                line = line.strip()
                if line.startswith("{title:"):
                    song_dict["title"] = line.split(":")[1].strip(" }")
                elif line.startswith("{subtitle:"):
                    song_dict["subtitle"] = line.split(":")[1].strip(" }")
                elif line.startswith("{comment:"):
                    if "page" in line:
                        song_dict["pages"].append(line.split(":")[1].strip(" }"))
                    else:
                        song_dict["comments"].append(line.split(":")[1].strip(" }"))
                else:
                    song_dict["lyrics"].append(line)
            song_dict["id"] = input_file.split("/")[-1].split("_")[0]
        return song_dict

    except FileNotFoundError:
        print(f"Error: The file {input_file} does not exist.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    parser = argparse.ArgumentParser(description="Copy contents of one file to another.")
    parser.add_argument('input_file', help="Path to the input file.")
    parser.add_argument('output_file', help="Path to the output file.")
    args = parser.parse_args()

    # make sure the output directory exists
    song_en = read_file(args.input_file)
    song_mus = read_file(args.input_file.replace("_en", "_mus"))
    df = make_dataframe(song_en, song_mus)
    add_to_tsv(df, args.output_file)

if __name__ == "__main__":
    main()