import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

//BatchZip
//将给定目录中的子文件夹依次打包
//参数1：指定7zip命令
//参数2：目录路径
//
//_7zz：7zip程序位置
//pwd：密码

public class BatchZip {

    //指定7zip路径
    public static String _7zz = "/Users/anpoliros/Applications/7z2403-mac/7zz";
    public static String pwd = "-pPHOTOSzbc23980813";

    public static void main(String[] args) {
        if (args.length < 2) {
            System.out.println("Usage: java BatchZip <7zip_command> <directory>");
            return;
        }

        //传参
        String zipCommand = args[0];
        String directoryPath = args[1];

        File directory = new File(directoryPath);

        if (!directory.exists() || !directory.isDirectory()) {
            System.out.println("The specified directory does not exist or is not a directory.");
            return;
        }

        invoke7ZipOnSubfolders(directory, zipCommand);
    }

    private static void invoke7ZipOnSubfolders(File directory, String zipCommand) {
        //收集子目录
        File[] subfolders = directory.listFiles(File::isDirectory);

        if (subfolders == null) return;

        for (File subfolder : subfolders) {
            try {
                //拼接命令
                String name = new String(subfolder.getAbsolutePath());
                name += ".zip";
                List<String> command = new ArrayList<>();
                command.add(_7zz);
                command.add(zipCommand);
                command.add(pwd);
                command.add(name);
                command.add(subfolder.getAbsolutePath());

                ProcessBuilder processBuilder = new ProcessBuilder(command);
                processBuilder.redirectErrorStream(true);
                
                Process process = processBuilder.start();

                // Print output from the command
                java.io.InputStream inputStream = process.getInputStream();
                java.util.Scanner scanner = new java.util.Scanner(inputStream);
                while (scanner.hasNextLine()) {
                    System.out.println(scanner.nextLine());
                }
                scanner.close();

                int exitCode = process.waitFor();
                System.out.println("Processed: " + subfolder.getAbsolutePath() + " with exit code: " + exitCode);

            } catch (IOException | InterruptedException e) {
                System.out.println("Failed to process: " + subfolder.getAbsolutePath());
                e.printStackTrace();
            }
        }
    }
}
