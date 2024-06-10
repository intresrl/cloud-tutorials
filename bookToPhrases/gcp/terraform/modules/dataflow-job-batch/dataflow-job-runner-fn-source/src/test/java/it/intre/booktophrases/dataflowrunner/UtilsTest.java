package it.intre.booktophrases.dataflowrunner;

import org.junit.Assert;
import org.junit.Test;

public class UtilsTest {

    @Test
    public void buildJobName() {
        Assert.assertEquals("booktophrase-bucket-name", Utils.buildJobName("bucket", "name"));

        Assert.assertEquals("booktophrase-bucket-na-m-e", Utils.buildJobName("bucket", "na  m e"));

    }

    @Test
    public void testFixString() {
        Assert.assertEquals("winnie-the-pooh-by-a-a-milne-txt", Utils.fixString("Winnie-the-Pooh by A. A. Milne.txt"));
    }
}