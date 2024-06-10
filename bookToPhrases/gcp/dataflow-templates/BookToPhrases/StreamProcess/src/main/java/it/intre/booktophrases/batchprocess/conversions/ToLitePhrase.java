package it.intre.booktophrases.batchprocess.conversions;

import com.google.api.client.util.Strings;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.ReadableByteChannel;
import org.apache.beam.repackaged.core.org.apache.commons.lang3.ArrayUtils;
import org.apache.beam.sdk.io.FileIO;
import org.apache.beam.sdk.io.FileIO.ReadableFile;
import org.apache.beam.sdk.transforms.DoFn;
import it.intre.booktophrases.batchprocess.model.BookPhraseLite;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ToLitePhrase extends DoFn<ReadableFile, BookPhraseLite> {

  private static final Logger LOG = LoggerFactory.getLogger(ToLitePhrase.class);
  private static final char[] NEW_LINE_CHARS = new char[]{ '.', '?', '!'};

  private static final String[] INVALID_CHARS = new String[]{"\n", "\r"};

  @ProcessElement
  public void processElement(ProcessContext c) throws IOException {
    int rowNumber = 0;
    FileIO.ReadableFile f = c.element();
    LOG.info(String.format("Processing file: %s", f.getMetadata().resourceId()));
    String filePath = f.getMetadata().resourceId().toString();
    String fileName = filePath.substring(filePath.lastIndexOf("/") + 1);

    ReadableByteChannel inChannel = f.open();
    ByteBuffer buffer = ByteBuffer.allocate(1);
    StringBuffer line = new StringBuffer();
    while (inChannel.read(buffer) > 0) {
      buffer.flip();
      for (int i = 0; i < buffer.limit(); i++) {
        char ch = ((char) buffer.get());
        line.append(ch);
        if (isNewLine(ch)) {
          rowNumber = pushLine(c, line, fileName, rowNumber);
          line = new StringBuffer();
        }
      }
      buffer.clear();
    }
    pushLine(c, line, fileName, rowNumber);
    inChannel.close();
    LOG.info(String.format("File %s completed.", f.getMetadata().resourceId()));
  }

  private static int pushLine(DoFn<ReadableFile, BookPhraseLite>.ProcessContext c,
      StringBuffer line, String fileName, int rowNumber) {
    String newLine = cleanString(line.toString());
    if (isValidPhrase(newLine)) {
      c.output(toBookPhrase(fileName, newLine, rowNumber));
      rowNumber++;
    }
    return rowNumber;
  }

  public boolean equals(Object o) {
    if (o == this) {
      return true;
    } else if (!(o instanceof ToLitePhrase)) {
      return false;
    } else {
      ToLitePhrase other = (ToLitePhrase) o;
      return true;
    }
  }
  private static BookPhraseLite toBookPhrase(String bookName, String line, int rowNumber) {
    return new BookPhraseLite(bookName, line, rowNumber);
  }

  private static boolean isNewLine(char newChar) {
    return ArrayUtils.contains(NEW_LINE_CHARS, newChar);
  }

  private static boolean isValidPhrase(String sRaw) {
    return !Strings.isNullOrEmpty(sRaw);
  }

  private static String cleanString(String sRaw) {
    String fixedString = sRaw.trim();
    for (String c : INVALID_CHARS) {
      fixedString = fixedString.replace(c, " ");
    }
    // remove duplicated spaces
    fixedString = fixedString.replaceAll("\\s+"," ");
    return fixedString;
  }
}
