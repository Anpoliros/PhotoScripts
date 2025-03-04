import java.io.IOException;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class FileDrainer {
    public static void moveFiles(Path sourceDir, boolean deleteSubDirs) throws IOException, InterruptedException {
        if (!Files.isDirectory(sourceDir)) {
            System.out.println("Provided path is not a directory.");
            return;
        }

        Path targetDir = sourceDir;
        List<Path> directories = new ArrayList<>();

        List<Thread> threads = new ArrayList<>();
        Files.walk(sourceDir)
                .forEach(path -> {
                    if (Files.isRegularFile(path)) {
                        Thread thread = new Thread(() -> {
                            try {
                                Path targetFile = targetDir.resolve(sourceDir.relativize(path));
                                Files.createDirectories(targetFile.getParent());
                                Files.move(path, targetFile, StandardCopyOption.REPLACE_EXISTING);
                                System.out.println("Moved: " + path + " to " + targetFile);
                            } catch (IOException e) {
                                System.err.println("Unable to move file: " + path);
                                e.printStackTrace();
                            }
                        });
                        threads.add(thread);
                        thread.start();
                    } else if (!path.equals(sourceDir)) {
                        directories.add(path);
                    }
                });

        for (Thread thread : threads) {
            thread.join();
        }

        if (deleteSubDirs) {
            for (Path dir : directories) {
                try {
                    Files.walk(dir)
                            .sorted(Comparator.reverseOrder())
                            .forEach(p -> {
                                try {
                                    Files.delete(p);
                                    System.out.println("Deleted: " + p);
                                } catch (IOException e) {
                                    System.err.println("Unable to delete: " + p);
                                    e.printStackTrace();
                                }
                            });
                } catch (IOException e) {
                    System.err.println("Error while deleting directories: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
    }

    public static void main(String[] args) throws IOException, InterruptedException {
        if (args.length < 1) {
            System.out.println("Usage: FileDrainer <source_directory_path> [delete_subdirs?]");
            return;
        }

        Path sourceDir = Paths.get(args[0]);
        boolean deleteSubDirs = false;

        if (args.length > 1) {
            deleteSubDirs = Boolean.parseBoolean(args[1]);
        }

        moveFiles(sourceDir, deleteSubDirs);
    }
}
