import com.drew.imaging.ImageMetadataReader;
import com.drew.metadata.Metadata;
import com.drew.metadata.exif.ExifIFD0Directory;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public class WallpaperPickerMetadata {
    public static void main(String[] args) {
        if (args.length < 4) {
            System.out.println("Usage: java WallpaperPicker <delete|reserve> <cascade|onlyhere> <outputDir|null> <inputDir>");
            return;
        }

        // 参数解析
        boolean deleteSource = args[0].equalsIgnoreCase("delete");
        boolean cascade = args[1].equalsIgnoreCase("cascade");
        String outputDir = args[2].equalsIgnoreCase("null") ? null : args[2];
        String inputDir = args[3];

        File inputDirectory = new File(inputDir);
        if (!inputDirectory.exists() || !inputDirectory.isDirectory()) {
            System.out.println("Invalid input directory: " + inputDir);
            return;
        }

        // 设置默认输出目录
        if (outputDir == null) {
            outputDir = inputDir + File.separator + "wallpaper_output";
        }
        File outputDirectory = new File(outputDir);
        if (!outputDirectory.exists() && !outputDirectory.mkdirs()) {
            System.out.println("Failed to create output directory: " + outputDir);
            return;
        }

        processDirectory(inputDirectory, outputDirectory, cascade, deleteSource);
        System.out.println("Processing complete.");
    }

    private static void processDirectory(File inputDir, File outputDir, boolean cascade, boolean deleteSource) {
        File[] files = inputDir.listFiles();
        if (files == null) {
            return;
        }

        for (File file : files) {
            if (file.isDirectory() && cascade) {
                // 递归处理子目录
                processDirectory(file, new File(outputDir, file.getName()), true, deleteSource);
            } else if (isImage(file)) {
                boolean isHorizontal = false;
                try {
                    // 尝试通过元数据获取分辨率
                    Metadata metadata = ImageMetadataReader.readMetadata(file);
                    ExifIFD0Directory directory = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);

                    if (directory != null) {
                        int width = directory.getInt(ExifIFD0Directory.TAG_IMAGE_WIDTH);
                        int height = directory.getInt(ExifIFD0Directory.TAG_IMAGE_HEIGHT);
                        isHorizontal = width > height;
                    }
                } catch (Exception ignored) {
                    // 元数据提取失败，回退到读取图片内容
                }


                    try {
                        BufferedImage image = ImageIO.read(file);
                        if (image != null) {
                            isHorizontal = image.getWidth() > image.getHeight();
                        }
                    } catch (IOException e) {
                        System.err.println("Failed to process image: " + file.getAbsolutePath());
                    }


                // 复制横向图片
                if (isHorizontal) {
                    try {
                        File outputFile = new File(outputDir, file.getName());
                        Files.copy(file.toPath(), outputFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        System.out.println("Successfully copied: " + file.getAbsolutePath() + " to " + outputFile.getAbsolutePath());

                        if (deleteSource) {
                            file.delete();
                        }
                    } catch (IOException e) {
                        System.err.println("Failed to copy image: " + file.getAbsolutePath() + e.getMessage());
                    }
                }
            }
        }
    }

    private static boolean isImage(File file) {
        String[] imageExtensions = {"jpg", "jpeg", "png", "bmp", "gif"};
        String fileName = file.getName().toLowerCase();
        for (String ext : imageExtensions) {
            if (fileName.endsWith("." + ext)) {
                return true;
            }
        }
        return false;
    }
}