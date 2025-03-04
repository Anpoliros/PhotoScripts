import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.attribute.FileTime;
import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;

public class PngToJpegConverter {

    // Function to convert PNG to JPEG while preserving metadata and optionally deleting the original file
    public static void convertPngToJpeg(boolean deleteOriginal, String dirPath) {
        File dir = new File(dirPath);
        if (!dir.exists() || !dir.isDirectory()) {
            System.out.println("The directory does not exist.");
            return;
        }

        // Iterate through the files in the directory
        File[] files = dir.listFiles((d, name) -> name.toLowerCase().endsWith(".png"));
        if (files == null || files.length == 0) {
            System.out.println("No PNG files found in the directory.");
            return;
        }

        for (File pngFile : files) {
            try {
                // Read the image from the file
                BufferedImage pngImage = ImageIO.read(pngFile);

                // Create a new image without the alpha channel (transparency), fill with white background
                BufferedImage jpegImage = new BufferedImage(
                        pngImage.getWidth(),
                        pngImage.getHeight(),
                        BufferedImage.TYPE_INT_RGB
                );

                // Draw the PNG image on the new image with a white background
                Graphics2D graphics = jpegImage.createGraphics();
                graphics.drawImage(pngImage, 0, 0, null);
                graphics.dispose();

                // Create the output JPEG file with .jpeg extension
                File jpegFile = new File(pngFile.getAbsolutePath().replaceAll(".PNG", ".jpeg"));

                // Preserve original metadata (creation and modification dates)
                Path pngFilePath = pngFile.toPath();
                BasicFileAttributes attrs = Files.readAttributes(pngFilePath, BasicFileAttributes.class);
                FileTime creationTime = attrs.creationTime();
                FileTime lastModifiedTime = attrs.lastModifiedTime();

                // Write the image as JPEG with high quality (near-lossless)
                writeJpegWithQuality(jpegImage, jpegFile, 1.0f);  // 1.0f means maximum quality, minimal compression

                // Set the original creation and modification times on the new JPEG file
                Path jpegFilePath = jpegFile.toPath();
                Files.setAttribute(jpegFilePath, "basic:creationTime", creationTime);
                Files.setAttribute(jpegFilePath, "basic:lastModifiedTime", lastModifiedTime);

                // Optionally delete the original PNG file
                if (deleteOriginal) {
                    if (pngFile.delete()) {
                        System.out.println("Deleted original file: " + pngFile.getName());
                    } else {
                        System.out.println("Failed to delete original file: " + pngFile.getName());
                    }
                }

                System.out.println("Converted " + pngFile.getName() + " to " + jpegFile.getName());

            } catch (IOException e) {
                System.err.println("Error processing file: " + pngFile.getName());
                e.printStackTrace();
            }
        }
    }

    // Helper method to write the image as JPEG with a specific quality
    private static void writeJpegWithQuality(BufferedImage image, File file, float quality) throws IOException {
        // Get JPEG writer
        ImageWriter writer = ImageIO.getImageWritersByFormatName("jpeg").next();
        try (FileOutputStream fos = new FileOutputStream(file);
             ImageOutputStream ios = ImageIO.createImageOutputStream(fos)) {

            writer.setOutput(ios);

            // Set JPEG quality parameters
            ImageWriteParam param = writer.getDefaultWriteParam();
            if (param.canWriteCompressed()) {
                param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
                param.setCompressionQuality(quality);  // 1.0 = maximum quality (least compression)
            }

            // Write the image with the specified quality
            writer.write(null, new IIOImage(image, null, null), param);
        } finally {
            writer.dispose();
        }
    }

    public static void main(String[] args) {
        // Example usage: pass 'true' to delete the original PNG file, and the directory path as the second argument
        boolean deleteOriginal = Boolean.parseBoolean(args[0]);
        String dirPath = args[1];

        convertPngToJpeg(deleteOriginal, dirPath);
    }
}
