enum AnimationState { close, open }

enum Direction { up, down }

enum SortType { mvskokeTitle, englishTitle, songNumber }

enum LineType {
  chorus,
  main, // main lyrics
  extra, // additional lyrics (translations, etc)
  header,
  metadata, // skip these lines
  comment,
}
