import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.attribute.BasicFileAttributes;
import java.nio.file.attribute.FileTime;
import java.util.HashSet;
import java.util.Set;

public class FileDateModifier {

    public static void main(String[] args) {
        if (args.length < 3) {
            System.out.println("Usage: java FileDateModifier <file_types> <recursive> <directory>");
            return;
        }

        String fileTypesArg = args[0];
        boolean recursive = Boolean.parseBoolean(args[1]);
        File directory = new File(args[2]);

        if (!directory.exists() || !directory.isDirectory()) {
            System.out.println("The specified directory does not exist or is not a directory.");
            return;
        }

        Set<String> fileTypes = new HashSet<>();
        if (!fileTypesArg.equals("*")) {
            String[] types = fileTypesArg.split("/");
            for (String type : types) {
                fileTypes.add(type.toLowerCase());
            }
        }

        modifyFileDates(directory, fileTypes, recursive);
    }

    private static void modifyFileDates(File directory, Set<String> fileTypes, boolean recursive) {
        File[] files = directory.listFiles();

        if (files == null) return;

        for (File file : files) {
            if (file.isDirectory() && recursive) {
                modifyFileDates(file, fileTypes, true);
            } else if (file.isFile()) {
                String fileName = file.getName().toLowerCase();
                String fileExtension = getFileExtension(fileName);

                if (fileTypes.isEmpty() || fileTypes.contains(fileExtension)) {
                    try {
                        BasicFileAttributes attrs = Files.readAttributes(file.toPath(), BasicFileAttributes.class);
                        FileTime creationTime = attrs.creationTime();

                        // Change the modification date to the creation date
                        Files.setLastModifiedTime(file.toPath(), creationTime);

                        System.out.println("Modified: " + file.getAbsolutePath());
                    } catch (IOException e) {
                        System.out.println("Failed to modify: " + file.getAbsolutePath());
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    private static String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        return (lastDotIndex == -1) ? "" : fileName.substring(lastDotIndex + 1);
    }
}
