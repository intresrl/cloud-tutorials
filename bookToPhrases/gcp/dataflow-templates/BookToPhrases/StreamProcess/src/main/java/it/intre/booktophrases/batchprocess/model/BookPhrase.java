package it.intre.booktophrases.batchprocess.model;

import org.apache.beam.sdk.coders.DefaultCoder;

@DefaultCoder(org.apache.beam.sdk.coders.SerializableCoder.class)
public class BookPhrase extends BookPhraseLite {

  private int wordsCount;
  private int charsCount;

  public BookPhrase(String book, String phrase, int rowIndex, int wordsCount, int charsCount) {
    super(book, phrase, rowIndex);

    this.wordsCount = wordsCount;
    this.charsCount = charsCount;
  }

  public BookPhrase(BookPhraseLite lite, int wordsCount, int charsCount) {
    this(lite.getBook(), lite.getPhrase(), lite.getRowIndex(), wordsCount, charsCount);
  }

  public int getWordsCount() {
    return wordsCount;
  }

  public int getCharsCount() {
    return charsCount;
  }

  public String toString() {
    return super.toString() + " Words: " + wordsCount + " Chars: " + charsCount;
  }

  public boolean equals(Object obj) {
    return obj instanceof BookPhraseLite
        && ((BookPhrase) obj).getBook().equals(getBook())
        && ((BookPhrase) obj).getRowIndex() == getRowIndex()
        && ((BookPhrase) obj).getPhrase().equals(getPhrase())
        && ((BookPhrase) obj).charsCount == charsCount
        && ((BookPhrase) obj).wordsCount == wordsCount;
  }
}
