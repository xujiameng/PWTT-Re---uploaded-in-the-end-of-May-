关于PWTT项目代码的使用
====
<br>

### 主函数<br>

该项目中只包含有两个主函数：<br>
　　select_R_linear_fitting.m : 从原始信号数据获取有效的PWTT与BP峰值点位置信息并进行拟合 (可选择是否对有效数据计算平均值)<br>

　　baifenbiplot.m : 计算上一主函数计算有效值的变化率（提供两种变化率的计算并拟合，固定时间间的变量变化率拟合与每两点之间的变量变化率拟合）<br>
特别的，该函数需要在上一函数运行结束后运行<br><br>
### 子函数<br>
使用子函数的文件有：<br>
　　1.select_R_linear_fitting.m（主函数） <br>
　　使用的子函数包括：<br>
　　　　 usedbyplot：对原始数据进行处理，得到标记处异常点的PWTT数据及BP峰值点数据<br>
　　　　 test_R：计算得出每gap个数据取一个平均值后的数据，及这两组数据的拟合优度R<br><br>
     
　　2.usedbyplot.m （子函数）<br>
　　使用的子函数包括：<br>　　 
　　　　 ECG250：获取R波峰值点的位置信息
　　　　 BP250_2：对BP信号进行滤波
　　　　 find_peaks：结合R波信息，获取信息中峰值点位置
　　　　 improvements_to_7step：对7-step滤波法的改进，用于获取PPG峰值异常点信息<br><br>

　　3.ECG250.m （子函数）<br>
　　使用的子函数包括：<br>　　 
　　　　 detectionRR2：获取ECG信号峰值信息<br><br>
     
　　4.improvements_to_7step.m （子函数）<br>
　　使用的子函数包括：<br>　　 
　　　　 find_peaks：获取数据峰值点位置信息
　　　　
    
    
    
    
    
