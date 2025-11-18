import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.*;
import java.util.Objects;

import javax.imageio.ImageIO;

public class WallpaperPicker {
    public static void main(String[] args) {
        if (args.length < 4) {
            System.out.println("Usage: java WallpaperPicker <delete|reserve> <cascade|onlyhere> <output-directory> <input-directory>");
            return;
        }

        boolean deleteSource = "delete".equalsIgnoreCase(args[0]);
        boolean cascade = "cascade".equalsIgnoreCase(args[1]);
        String outputDirectory = args[2];
        String inputDirectory = args[3];

        // 如果输出目录未提供，则使用默认目录
        if (Objects.equals(outputDirectory, "default")) {
            outputDirectory = inputDirectory + File.separator + "wallpaper_output";
        }

        File outputDir = new File(outputDirectory);
        if (!outputDir.exists()) {
            outputDir.mkdirs();
        }

        try {
            processDirectory(new File(inputDirectory), outputDir, cascade, deleteSource);
            System.out.println("Processing completed.");
        } catch (IOException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    private static void processDirectory(File inputDir, File outputDir, boolean cascade, boolean deleteSource) throws IOException {
        if (!inputDir.exists() || !inputDir.isDirectory()) {
            throw new IOException("Input directory does not exist or is not a directory: " + inputDir);
        }

        File[] files = inputDir.listFiles();
        if (files == null) return;

        for (File file : files) {
            if (file.isDirectory() && cascade) {
                // 递归处理子目录
                processDirectory(file, outputDir, true, deleteSource);
            } else if (isImage(file)) {
                BufferedImage image = ImageIO.read(file);
                if (image != null && image.getWidth() > image.getHeight()) {
                    // 复制文件到输出目录
                    File outputFile = new File(outputDir, file.getName());
                    Files.copy(file.toPath(), outputFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    System.out.println("Copied: " + file.getPath() + " to " + outputFile.getPath());

                    // 删除源文件
                    if (deleteSource) {
                        if (!file.delete()) {
                            System.err.println("Failed to delete file: " + file.getPath());
                        }
                    }
                }
            }
        }
    }

    private static boolean isImage(File file) {
        if (!file.isFile()) return false;
        String[] supportedFormats = {".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff"};
        String fileName = file.getName().toLowerCase();
        for (String format : supportedFormats) {
            if (fileName.endsWith(format)) return true;
        }
        return false;
    }
}