
分片：
    FileGrouper.java
    将给定目录下的文件分成若干组
	1.分片大小
	2.是否按日期排序
	3.路径
    java /Users/anpoliros/Documents/Scripts/FileGrouper.java 200 true ./Dir

打包：
    BatchZip.sh
    将当前目录中的子文件夹依次打包
    转到当前目录，执行该脚本即可

修改日期
    DataModifier.java
    将给定目录下的文件的修改日期改为创建日期
	1.要修改的文件类型
	2.是否级联处理
	3.路径

恢复原始状态：
    FileDrainer.java
    将给定目录中的子文件夹中的文件提取出来
	1.路径
	2.提取完成后是否删除空的子文件夹

PNG转换JPG
    PngConverter.java
	1.是否删除原文件
	2.路径