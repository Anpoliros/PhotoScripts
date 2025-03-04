import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.plugins.jpeg.JPEGImageWriteParam;
import javax.imageio.stream.ImageOutputStream;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.attribute.FileTime;
import java.util.Iterator;

//PngToJpegConverter
//转换PNG为JPEG
//参数1：是否删除原文件 delete/reserve
//参数2：是否级联处理 cascade/only_this
//参数3：目录路径
//
//实现方法：Graphics2d重绘

public class PngToJpegConverter {

    public static void main(String[] args) {
        if (args.length != 3) {
            System.out.println("Usage: java PngToJpegConverter <delete|reserve> <cascade|only_this> <directory_path>");
            return;
        }

        String deleteOption = args[0];
        String cascadeOption = args[1];
        String directoryPath = args[2];

        File directory = new File(directoryPath);
        if (!directory.isDirectory()) {
            System.out.println("The provided path is not a directory.");
            return;
        }

        processDirectory(directory, deleteOption.equals("delete"), cascadeOption.equals("cascade"));
    }

    private static void processDirectory(File directory, boolean deleteOriginal, boolean cascade) {
        File[] files = directory.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isDirectory() && cascade) {
                    processDirectory(file, deleteOriginal, cascade);
                } else if (file.getName().endsWith(".png") || file.getName().endsWith(".PNG")) {
                    convertPngToJpeg(file, deleteOriginal);
                }
            }
        }
    }

    private static void convertPngToJpeg(File pngFile, boolean deleteOriginal) {
        try {
            // 读取PNG文件
            BufferedImage pngImage = ImageIO.read(pngFile);
            // 创建JPEG文件
            File jpegFile = null;
            if (pngFile.getName().endsWith(".png")) {
                jpegFile = new File(pngFile.getParent(), pngFile.getName().replace(".png", ".jpeg"));
            } else if (pngFile.getName().endsWith(".PNG")) {
                jpegFile = new File(pngFile.getParent(), pngFile.getName().replace(".PNG", ".jpeg"));
            }

            // 使用Graphics2D重新绘制JPEG文件
            BufferedImage jpegImage = new BufferedImage(pngImage.getWidth(), pngImage.getHeight(), BufferedImage.TYPE_INT_RGB);
            Graphics2D g2d = jpegImage.createGraphics();
            g2d.drawImage(pngImage, 0, 0, null);
            g2d.dispose();

            // 保存JPEG文件，质量为1.0f
            Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpeg");
            if (writers.hasNext()) {
                ImageWriter writer = writers.next();
                JPEGImageWriteParam jpegParams = new JPEGImageWriteParam(null);
                jpegParams.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                jpegParams.setCompressionQuality(1.0f); // 最高质量

                try (ImageOutputStream ios = ImageIO.createImageOutputStream(jpegFile)) {
                    writer.setOutput(ios);
                    writer.write(null, new javax.imageio.IIOImage(jpegImage, null, null), jpegParams);
                }
            }


            // 保留原文件创建时间
//            BasicFileAttributes attrs = Files.readAttributes(pngFile.toPath(), BasicFileAttributes.class);
//            Files.setAttribute(jpegFile.toPath(), "creationTime", attrs.creationTime());
//            Path jpegFilePath = jpegFile.toPath();

            //提取png元数据
            Path pngFilePath = pngFile.toPath();
            BasicFileAttributes attrs = Files.readAttributes(pngFilePath, BasicFileAttributes.class);
            FileTime creationTime = attrs.creationTime();
            FileTime lastModifiedTime = attrs.lastModifiedTime();
            //写入jpeg元数据
            Path jpegFilePath = jpegFile.toPath();
            Files.setAttribute(jpegFilePath, "basic:creationTime", creationTime);
            Files.setAttribute(jpegFilePath, "basic:lastModifiedTime", lastModifiedTime);

            System.out.println("Converted: " + pngFile.getName() + " to " + jpegFile.getName());

            // 删除原文件
            if (deleteOriginal) {
                if (pngFile.delete()) {
                    System.out.println("Deleted original file: " + pngFile.getName());
                } else {
                    System.out.println("Failed to delete original file: " + pngFile.getName());
                }
            }

        } catch (IOException e) {
            System.err.println("Error processing file: " + pngFile.getName() + " - " + e.getMessage());
        }
    }
}
