if(file.exists("/dsvm"))
{
  Sys.setenv(SPARK_HOME="/dsvm/tools/spark/current",
    YARN_CONF_DIR="/opt/hadoop/current/etc/hadoop", 
    JAVA_HOME = "/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.111-1.b15.el7_2.x86_64",
    PATH="/anaconda/envs/py35/bin:/dsvm/tools/cntk/cntk/bin:/usr/local/mpi/bin:/dsvm/tools/spark/current/bin:/anaconda/envs/py35/bin:/dsvm/tools/cntk/cntk/bin:/usr/local/mpi/bin:/dsvm/tools/spark/current/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/hadoop/current/sbin:/opt/hadoop/current/bin:/home/remoteuser/.local/bin:/home/remoteuser/bin:/opt/hadoop/current/sbin:/opt/hadoop/current/bin"
  )
}

useHDFS <- TRUE

if(useHDFS) {

  ################################################
  # Use Hadoop-compatible Distributed File System
  ################################################
  
  rxOptions(fileSystem = RxHdfsFileSystem())
  
  dataDir <- "/user/RevoShare/remoteuser/Data"
  
  ################################################

  if(rxOptions()$hdfsHost == "default") {
    fullDataDir <- dataDir
  } else {
    fullDataDir <- paste0(rxOptions()$hdfsHost, dataDir)
  }  
} else {
  
  ################################################
  # Use Native, Local File System
  ################################################

  rxOptions(fileSystem = RxNativeFileSystem())
  
  dataDir <- file.path(getwd(), "delayDataLarge")
  
  ################################################
}

################################################
# Distributed computing using Spark
################################################

startRxSpark <- function() {
  rxSparkConnect(reset = T,
    consoleOutput=TRUE, numExecutors = 1, executorCores=2, 
    executorMem="1g")
}

rxRoc <- function(...){
  previousContext <- rxSetComputeContext(RxLocalSeq())

  # rxRoc requires local compute context
  roc <- RevoScaleR::rxRoc(...)

  rxSetComputeContext(previousContext)

  return(roc)
}
