import os
import sys
import csv

directory = '/Users/juliamainzinger/Documents/Projects/mvskoke_code/mvskoke_hymnal/extras/recordings'
output_tsv = 'media.tsv'

def list_filenames_to_tsv(directory, output_tsv):
    filenames = os.listdir(directory)
    # get all filenames ending in .mp3
    filenames = [f for f in filenames if f.endswith('.mp3')]
    # sort filenames
    filenames.sort()
    with open(output_tsv, 'w', newline='', encoding='utf-8') as tsvfile:
        writer = csv.writer(tsvfile, delimiter='\t')
        writer.writerow(['id', 'song_id', 'title', 'performer', 'filename', 'copyright'])
        i = 1
        for fname in filenames:
            title = fname[:-4]  # remove .mp3
            writer.writerow([i, 1, title, 'Juanita McGirt', fname, 'Muskogee (Seminole/Creek) Documentation Project'])
            i += 1

if __name__ == "__main__":
    list_filenames_to_tsv(directory, output_tsv)