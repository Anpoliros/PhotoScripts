import java.io.IOException;
import java.nio.file.*;
import java.util.*;

public class FileGrouper {

    private static void groupFiles(Path sourceDir, int groupSize, boolean sortByDate) throws IOException {
        if (!Files.isDirectory(sourceDir)) {
            System.out.println("Provided path is not a directory.");
            return;
        }

        // 获取目录中的所有文件，并根据文件名或创建日期排序
        List<Path> files = Files.list(sourceDir)
                .filter(Files::isRegularFile)
                .sorted((o1, o2) -> {
                    try {
                        if (sortByDate) {
                            return Files.getLastModifiedTime(o1).compareTo(Files.getLastModifiedTime(o2));
                        } else {
                            return o1.getFileName().compareTo(o2.getFileName());
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    return 0;
                })
                .toList();

        // 按照指定的数量分组
        for (int i = 0; i < files.size(); i += groupSize) {
            Path subDir = sourceDir.resolve("Group_" + (i / groupSize + 1));
            Files.createDirectories(subDir);

            for (int j = i; j < i + groupSize && j < files.size(); j++) {
                Path file = files.get(j);
                Files.move(file, subDir.resolve(file.getFileName()), StandardCopyOption.REPLACE_EXISTING);
            }
        }
    }

    public static void main(String[] args) throws IOException {
        if (args.length < 3) {
            System.out.println("Usage: GroupFiles <group_size> <sort_by_date> <directory_path> ");
            return;
        }

        Path sourceDir = Paths.get(args[2]);
        int groupSize = Integer.parseInt(args[0]);
        boolean sortByDate = Boolean.parseBoolean(args[1]);

        groupFiles(sourceDir, groupSize, sortByDate);
    }
}
