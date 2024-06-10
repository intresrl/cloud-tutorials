package it.intre.booktophrases.batchprocess.model;

import java.io.Serializable;
import org.apache.beam.sdk.coders.DefaultCoder;

@DefaultCoder(org.apache.beam.sdk.coders.SerializableCoder.class)
public class BookPhraseLite implements Serializable {

  private String phrase;
  private String book;
  private int rowIndex;

  public BookPhraseLite(String book, String phrase, int rowIndex) {
    this.phrase = phrase;
    this.rowIndex = rowIndex;
    this.book = book;
  }

  public String getPhrase() {
    return phrase;
  }

  public int getRowIndex() {
    return rowIndex;
  }

  public String getBook() {
    return book;
  }

  public String toString(){
    return "Book: " + book + " Row: " + rowIndex + " Phrase: " + phrase;
  }

  @Override
  public boolean equals(Object obj) {
    return obj instanceof BookPhraseLite
        && ((BookPhraseLite) obj).book.equals( book) && ((BookPhraseLite) obj).rowIndex == rowIndex;
  }
}
