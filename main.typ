#import "@preview/ilm:1.4.1": *

#set text(lang: "en")



#show: ilm.with(
  title: [MTU MRI gpu cluster usage tutorial],
  author: "Jiangqiu Shen",
  date: datetime(year: 2025, month: 09, day: 16),
  abstract: [
    This document is a tutorial for using the MTU MRI GPU cluster.
    It covers topics such as accessing the cluster, submitting jobs, and managing data.
  ],
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
  chapter-pagebreak: false,
  appendix: (
    enabled: false,
    body: [#include "appendix.typ"],
  ),
)


#show link: set text(fill: blue)

#show raw: set text(font: "JetBrainsMono NFM", weight: "bold")

= Introduction

Welcome to the MTU MRI GPU Cluster Tutorial. This guide is designed for students who are new to concepts such as SSH, GPU computing, Python, PyTorch, and working with the MRI cluster at Michigan Tech. The tutorial is organized in a modular way, so you can easily find the information you need. For each topic, you will find links to detailed chapters.

First of all, We are going to go throught a quick example of running a python program in MTU MRI Cluster. This example inlcudes 3 stpes:
1. #link(<write>)[writing a simple python program], testing it locally.
2. #link(<browse>)[browse the MTU MRI cluster] to find available resources.
3. finally #link(<writeslurm>)[write a SLURM script] to submit the job to the cluster using SLURM.

Through this example, you can click any link to the detailed chapter if you want to learn more about a specific topic. Like #link(<ssh>)[SSH], #link(<python-conda>)[Python,Conda,pytorch], #link(<slurm>)[SLURM], and #link(<basiccmd>)[Basic Linux Commands] etc.

If you have any questions, please feel free to contact me (Jiangqiu Shen) at `jshen2@mtu.edu`.


= A Step By Step Example
== Create your GPU Application<write>
=== Install Python and PyTorch Locally
A fast way to get started is using #link(<python-conda>)[Conda] to create a python environment and install PyTorch.
1. You need to install Conda first. See #link(<python-conda>)[Python and Conda] chapter for details.
2. Run these commands in your terminal to create a conda environment named `myenv` and install PyTorch. Note that you may need different method to install pytorch depending on your local machine. Here I assume you have a *NVIDIA GPU *with *CUDA 12.9* installed within *Linux* or *Windows*. Please refer to #link("https://pytorch.org/get-started/locally/")[Pytorch Official Website] to find the right command for your machine. If you do not have a NVIDIA GPU, you can install the CPU version of PyTorch by running `pip3 install torch torchvision torchaudio` instead.

If you are not familiar with Terminal and shell, see #link(<shell>)[Terminal and Shell] chapter for details.

Example commands:
```bash
# Create the conda environment and install python
conda create -n myenv python
conda activate myenv
# Install PyTorch
pip3 install torch torchvision

```
=== Write a Simple Python Program
You can first create a simple project folder on your local machine, and use your favorite IDE to open it. For example, you can use your favorite #link(<shell>)[terminal and shell] and run some #link(<basiccmd>)[commands] to create A folder named `my_mri_project` in your home directory, and open it with #link(<vscode>)[VSCode].


```bash
cd ~;
mkdir my_mri_project;
# Open the project folder with VSCode
code my_mri_project;
```
*Notice*: if you are using windows, you might get an error shows that `code` command is not recognized. You can fix it by following these steps:
1. Open VSCode.
2. Press `Ctrl + Shift + P` to open the command palette.
3. Type `Shell Command: Install 'code' command in PATH` and select it.
4. Restart your terminal or command prompt to apply the changes.

Or you can just open the folder `my_mri_project` directly in VSCode by clicking `File` > `Open Folder...`, then select the folder.

Then create a python file named `myprog.py` in the folder by right-clicking on the folder in the Explorer view and selecting `New File`, then name it `myprog.py`, and write a simple PyTorch program to test if the GPU is available. For example here, I created a simple python program to check if CUDA is available.
#figure(caption: "A sample python code to detect GPU availability")[
  ```python
  # ~/my_mri_project/myprog.py
  import torch

  if __name__ == "__main__":
      gpu_available = torch.cuda.is_available()
      if gpu_available:
          print("CUDA is available. You can use GPU for your computations.")
      else:
          print("CUDA is not available. You will use CPU for your computations.")
      device = torch.device("cuda:0" if gpu_available else "cpu")
      print(f"Using device: {device}")
      x = torch.rand(5, 3).to(device)
      y = torch.rand(5, 3).to(device)
      z = x + y
      print("Result of x + y is:")
      print(z)


  ```
]


Now you can run the program locally to test if it works. Make sure you have activated the conda environment `myenv` that has PyTorch installed.

```bash
cd ~/my_mri_project;
# make sure you have activated the conda environment. If you have already activated it, you can skip this step.
conda activate myenv;
python myprog.py;
```

== Browse the MRI cluster to find available resources<browse>

MRI cluster is a powerful computing resource that provides access to high-performance GPUs and CPUs for scientific computing and machine learning tasks. Before you can run your program on the cluster, you need to understand how to access it and what resources are available.

MRI cluster uses #link(<slurm>)[SLURM] as the job scheduler, which allows you to submit your jobs to the cluster and manage them efficiently. You will also need to use #link(<ssh>)[SSH] to log in to the cluster and transfer your files, monitor your jobs, and retrieve your results. If you want to know more about the MTU MRI Cluster, see #link(<mri-cluster>)[Using the MRI Cluster] chapter for details.

To run our python program on the MRI cluster, we first need to know what resources are available. We will go through the following steps:



=== Log in to the MRI Cluster
*Important Notice*: According to MTU IT policies, you cannot access the MTU resource outside the campus network. If you are off-campus, you need to first connect to the MTU VPN. Please refer to #link("https://www.mtu.edu/it/remote-access-students/")[MTU VPN] for details.


First of all, you need to get an account to access the MTU MRI cluster. Please write an email to Dr. Dukka KC `dbkc@mtu.edu` to request an account. After you have an account, you can log in to the cluster using #link(<ssh>)[SSH]. The cluster address is `login-mri.research.mtu.edu`. For example, if your username is `yourusername`, you can run this command in your terminal (if you are using Windows, you can use PowerShell or an SSH client like PuTTY, check #link(<ssh>)[SSH chapter] for details):

```bash
ssh yourusername@login-mri.research.mtu.edu
```

after you login, you will be in your home directory `/home/yourusername`. *Do not store your files here.* You need to create a working directory in `/mnt/mridata/yourusername` by running this command:

```bash
bash /mnt/mridata/husky/create_user_folder_mridata.sh
```

Then you can check if the directory is created by running:
```bash
ls -l /mnt/mridata/yourusername
cd /mnt/mridata/yourusername
```
Now you are in your *REAL* working directory. You can create sub-folders here to organize your files.


=== Run Commands to Browse Available Resources

You have to check 3 things:
1. The available partitions and nodes. Learn about #link(<slurm>)[SLURM] chapter for details.
run:
```bash
sinfo
```
you will see something like this:
#figure(caption: "Output of sinfo command")[
  #image("sinfo.png")
]

This figure shows there are 6 partitions and the number of nodes of each partition as well as their status. *Just remember the partition names*, you will need them when you submit your job.

2. Show available software modules. Run:
```bash
module use /mnt/it_software/easybuild/modules/all
module avail
```
Tips: when you are in `module avail` list, you can use the `Up/Down` or `j/k` arrow keys to navigate, press `q` to quit.

you will see a long list of available modules like this:

#figure(caption: "Output of module avail command")[
  #image("modules.png")
]


3. Record what you need. For example, We need the `Anaconda3/2022.10` module, and we will using the `Gpu` node. We will use this information to write the SLURM script.

4. Do some init work. To run your python program, you might need to create a conda environment and install PyTorch *only once*. You can do this on the cluster by running these commands:
```bash
module use /mnt/it_software/easybuild/modules/all
module load Anaconda3/2022.10

# Create a new conda environment
conda create -n myenv python

# Activate the conda environment
conda activate myenv

# Install PyTorch with CUDA support
pip install torch torchvision torchaudio
```

these commands will create a conda environment named `myenv` and install PyTorch. You only need to do this once. Next time when you submit your job, you just need to load the Anaconda module and activate the conda environment `myenv`.

Good, we have done all the preparation work. Now we are ready to submit our job to the cluster.

== Write a SLURM script to submit your job <writeslurm>

Now go back to your local machine, and open the folder `my_mri_project` that contains the python program `myprog.py`. You need to create a SLURM script to submit your job to the cluster. Create a new file named `myslurm.sh` in the same folder, and write the following content:
#figure(caption: "A sample SLURM script to submit a job")[
  ```bash
  #!/bin/bash
  #SBATCH --job-name=my_mri_job          # Job name
  #SBATCH --nodes=1                      # Number of nodes
  #SBATCH --ntasks-per-node=1            # Number of tasks per node
  #SBATCH --cpus-per-task=4              # Number of CPU cores per task
  #SBATCH --mem=16G                      # Total memory per node (16GB)
  #SBATCH --time=00:10:00                # Time limit hrs:min:sec
  #SBATCH --partition=gpu             # Partition name (use mrigpu for GPU jobs)
  #SBATCH --output=my_mri_job.out        # Standard output and error log

  module use /mnt/it_software/easybuild/modules/all
  module load Anaconda3/2022.10

  # Activate your conda environment if needed
  source ~/anaconda3/etc/profile.d/conda.sh
  conda activate myenv

  cd /mnt/mridata/yourusername          # Change to your working directory
  python myprog.py                       # Run your python program
  ```
]

after doing this, you have 2 files in your local folder `my_mri_project`: `myprog.py` and `myslurm.sh`. remember, `myprog.py` is your python program, and `myslurm.sh` is your SLURM script to submit your job.

Now you need to transfer these 2 files to your working directory on the cluster.

== Transferring Files to the Cluster

You can use #link(<file-transfer>)[SCP or GUI tools] to transfer files. For example, you can run this command in your terminal (replace `yourusername` with your actual username):
```bash
# In your local machine terminal
scp ~/my_mri_project/myprog.py yourusername@login-mri.research.mtu.edu:/mnt/mridata/yourusername/
scp ~/my_mri_project/myslurm.sh yourusername@login-mri.research.mtu.edu:/mnt/mridata/yourusername/
```

Now you have transferred the files to your working directory on the cluster. You can log in to the cluster again using SSH, and check if the files are there by running:
```bash
# in your local terminal
ssh yourusername@login-mri.research.mtu.edu

# now you are logged in to the cluster
cd /mnt/mridata/yourusername
ls -l
```

You should see both `myprog.py` and `myslurm.sh` in the directory.

== Submit Your Job to the Cluster
Now you are ready to submit your job to the cluster using SLURM. You can run this command:
```bash
sbatch myslurm.sh
```

Congratulations! You have successfully submitted your job to the cluster. You can check the status of your job by running:
```bash
# in your terminal on the cluster
squeue -u yourusername
```

When your job is finished, you can check the output file `my_mri_job.out` in your working directory to see the results of your program:

```bash
cd /mnt/mridata/yourusername
# in your working directory on the cluster

cat my_mri_job.out
```
You should see output similar to this, indicating whether CUDA (GPU) is available and showing the result of the computation:
```
CUDA is available. You can use GPU for your computations.
Using device: cuda:0
Result of x + y is:
tensor([[...], [...], [...], [...], [...]])
```

Optional: If you want to download the output file to your local machine, you can use SCP again:
```bash
scp yourusername@login-mri.research.mtu.edu:/mnt/mridata/yourusername/my_mri_job.out ~/Downloads/
```






= SSH: Secure Shell <ssh>

*Important Notice*: According to MTU IT policies, you cannot access the MTU resource outside the campus network. If you are off-campus, you need to first connect to the MTU VPN. Please refer to #link("https://www.mtu.edu/it/remote-access-students/")[MTU VPN] for details.

== What is SSH?
SSH (Secure Shell) is a protocol that allows you to securely connect to a remote computer over a network. It provides a secure channel for communication, allowing you to execute commands, transfer files, and manage the remote system.

== How to Use SSH
There are different ways to use SSH depending on your operating system:
- *Linux ,Mac*: You can use the built-in terminal. Open your terminal and run:
  ```bash
  ssh yourusername@login-mri.research.mtu.edu
  ```
- *Windows 10,11*: Recent versions of Windows have a built-in SSH client. You can use PowerShell or Command Prompt. Open PowerShell and run:
  ```powershell
  ssh yourusername@login-mri.research.mtu.edu
  ```
  If you are using an older version of Windows, you can use an SSH client like PuTTY. See below:

- *Putty*: Download and install PuTTY from #link("https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.83-installer.msi")[Download Link]. Open PuTTY, enter the hostname `login-mri.research.mtu.edu`, Give it a name in Saved Sessions, and click "Save". Then click "Open" to start the SSH session.

if you want to use it next time, just open PuTTY and load the saved session: Click the session name and click "Load", then click "Open".

= Transferring Files: SCP and GUI Tools <file-transfer>

There also are different ways to transfer files to/from the cluster:
- *Linux, Mac or latest Windows*: You can use the built-in terminal with the `scp` command. For example, to copy a file from your local machine to the cluster:
  ```bash
  scp /path/to/local/file yourusername@login-mri.research.mtu.edu:/mnt/mridata/yourusername/
  ```
  To copy a file from the cluster to your local machine:
  ```bash
  scp yourusername@login-mri.research.mtu.edu:/mnt/mridata/yourusername/myfile.py /path/to/local/destination/
  ```
- *Windows without SCP command*: You can use an SCP client like WinSCP or FileZilla. Here we will use WinSCP as an example:
  1. Download and install WinSCP from #link("https://winscp.net/")[Download Link].
  2. Open WinSCP, enter the hostname `login-mri.research.mtu.edu`, your username, and password.
  3. Click "Login" to connect to the cluster.
  4. You can now drag and drop files between your local machine and the cluster.

= Python, Conda, and PyTorch <python-conda>

== What is Python， Conda, and PyTorch?
- *Python* is a popular programming language for scientific computing and machine learning.
- *Conda* is a package manager and environment management system that makes it easy to install and manage software packages and their dependencies.
- *PyTorch* is an open-source machine learning library based on the Torch library, widely used for deep learning applications.

So basiclly, you need first install `Conda`, then use `Conda` to create a `Python` environment with `python` installed. Finally, you can use `pip`  to install PyTorch in the python environment. Pytorch used to support to be install by conda directly, but now it is recommended to use `pip` to install it. please refer to #link("https://pytorch.org/get-started/locally/")[Pytorch Official Website] to find the right command for your machine.


== Installing Conda
It's different for your *local machine* and the *cluster*.
- *Local Machine*: You can download and install Miniconda or Anaconda from #link("https://www.anaconda.com/docs/getting-started/miniconda/install")[Miniconda] or #link("https://www.anaconda.com/products/distribution")[Anaconda]. Follow the installation instructions for your operating system. Personally, I recommend Miniconda as it is lightweight and allows you to install only the packages you need.

- *MRI Cluster*: You don't need to install Conda, just load the Anaconda module by running:
  ```bash
  module use /mnt/it_software/easybuild/modules/all
  module load Anaconda3/2022.10
  ```

== Creating a Python Environment
*Important*: You should create a new conda only once for each project. After that, you can just activate the conda environment when you need it. When you start a new project, you can reuse the same conda environment if you want, or create a new one with a different name.


You can create a new conda environment with a specific version of Python by running:
```bash
conda create -n myenv python
conda activate myenv
```

This will create a new environment named `myenv` and activate it. You can replace `myenv` with any name you prefer.

== Installing PyTorch
You can install PyTorch using `pip`. Make sure you have activated your conda environment first, then run:
```bash
pip install torch torchvision torchaudio 
```
this will install the latest version of PyTorch along with torchvision and torchaudio.


= MTU MRI Cluster <mri-cluster>
MTU MRI cluster is a powerful computing resource that provides access to high-performance GPUs and CPUs for scientific computing and machine learning tasks. It use s SLURM as the job scheduler, which allows you to submit your jobs to the cluster and manage them efficiently. You will also need to use SSH to log in to the cluster and transfer your files, monitor your jobs, and retrieve your results.

- The MRI cluster is available to students and researchers at Michigan Tech.
- You might need to connect to the MTU VPN if you are off-campus. Please refer to #link("https://www.mtu.edu/it/remote-access-students/")[MTU VPN] for details.
- To get an account, please write an email to Dr. Dukka KC `dbkc@mtu.edu`.
- The login address is: `ssh yourusername@login-mri.research.mtu.edu`


== First Login and Directory Setup
When you log in for the first time, you will be in your home directory (`/home/yourusername`). *Do not store your files here.*

To create a working directory, run:

```bash
bash /mnt/mridata/husky/create_user_folder_mridata.sh
```

To check your working directory:
```bash
ls -l /mnt/mridata/yourusername
cd /mnt/mridata/yourusername
```

- *Never run programs directly on the login node!*
- Always submit jobs using SLURM.

You can setup your conda environment and install necessary packages in your working directory. See #link(<python-conda>)[Python, Conda, and PyTorch] chapter for details.


== Useful Commands of Slurm <slurm>
Slurm is a job scheduler used in many HPC clusters, including the MTU MRI cluster. It allows you to submit, manage, and monitor jobs on the cluster.
Here are some useful SLURM commands:
- `sbatch <script.sh>`: Submit a job script.
- `squeue -u yourusername`: Show your jobs.
- `sinfo`: Show available partitions and nodes.
- `module use /mnt/it_software/easybuild/modules/all`: Add more modules.
- `module avail`: List available software modules.
- `module load ...`: Load a module.
- `module list`: Show loaded modules.



=== Submit a job
To submit a job, create a script (e.g., `myslurm.sh`):

```bash
#!/bin/bash
#SBATCH --job-name=myjob
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --partition=mrijobs
module use /mnt/it_software/easybuild/modules/all
module load Python/3.9.5-GCCcore-10.3.0
cd /mnt/mridata/yourusername
python mypyprog.py
```

Submit with:
```bash
sbatch myslurm.sh
```


=== Checking Job Status
- `squeue -u yourusername`: Check your jobs.
- `sinfo`: Check partitions.

= Useful Tips

== Terminal and Shell <shell>
Terminal is a text-based interface to interact with your computer: Like a command prompt or terminal emulator. Shell is the command-line interpreter that processes commands and scripts. Common shells include Bash, Zsh, and Fish for Linux/Mac, and PowerShell or Command Prompt for Windows.

So in short, terminal is the program you use to access the shell, and the shell is the program that interprets your commands.

Personally, I recommend using `fish` shell on Linux or Mac, and `PowerShell` on Windows. You can also install `Windows Subsystem for Linux (WSL)` on Windows to get a Linux-like environment. as `fish` provide an out-of-the-box user-friendly experience which include features like syntax highlighting, autosuggestions, and tab completions.
=== Tips to use a shell 
- Use `Tab` for auto-completion. for example, if you type `cd Doc` and press `Tab`, it will auto-complete to `cd Documents/` if that directory exists.
- Use `Up` and `Down` arrow keys to navigate through command history.
- Use `Ctrl + R` to search command history. Press `Ctrl + R`, then type a part of the command you want to find, and it will show you the most recent matching command. Press `Ctrl + R` again to cycle through older matches.
- Use `Ctrl + C` to cancel a running command.
- use `cd -` to go back to the previous directory.

== Tips for using vim:<vim>
Vim is a powerful text editor available in most Unix-like systems. It's useful when you need to edit files directly on the cluster.
Vim has two main modes: Normal mode and Insert mode.
When you first open a file with vim, you are in Normal mode. You can navigate and issue commands in this mode.
- To open a file: `vim filename`
- To enter Insert mode: Press `i`
- *To exit Insert mode*: Press `Esc`
- To save changes and exit: Type `:wq` in Normal mode and press `Enter`
- To exit without saving: Type `:q!` in Normal mode and press `Enter`
So remember, when you want to type or edit text, press `i` to enter Insert mode. When you want to issue commands, press `Esc` to go back to Normal mode.



== Basic Shell Commands <basiccmd>

- `pwd`: Show current directory.
- `ls`: List files, you can use `ls -l` for detailed info and `ls -a` to show hidden files. you can combine options like `ls -la` to show detailed info including hidden files.
- `cd`: Change directory: `cd /path/to/directory` to go to a specific directory, `cd ..` to go up one level, `cd ~` to go to your home directory. `cd -` to go back to the previous directory.
- `mkdir`: Create a new directory: `mkdir new_directory`, you can use `mkdir -p /path/to/new_directory` to create parent directories if they don't exist. it will first create `/path/to` if it does not exist, then create `new_directory` inside it.
- `cp`, `mv`, `rm`: Copy, move, remove files. `cp -r source_directory destination_directory` to copy directories recursively. `rm -r directory` to remove a directory and its contents.
- `touch`: Create an empty file: `touch newfile.txt`
- `cat`, `less`: View file contents, `cat file.txt` to display the whole file, `less file.txt` to view it page by page. When you are in `less`, you can use the `Up/Down` or `j/k` arrow keys to navigate, press `q` to quit.
- `nano`, `vim`: Edit files, see below for vim tips.



== VSCode <vscode>
vscode is a popular code editor that provides a user-friendly interface for writing and managing code. It has built-in support for many programming languages, including Python, and offers features like syntax highlighting, code completion, and debugging.

You can download and install VSCode from #link("https://code.visualstudio.com/")[VSCode Official Website].

you can install the python extension in VSCode to get better support for Python development. To do this, open VSCode, go to the Extensions view by clicking the square icon on the sidebar or pressing `Ctrl + Shift + X`, then search for "Python" and click "Install" on the extension provided by Microsoft.

you can also use the built-in terminal in VSCode to run commands. To open the terminal, go to the menu bar and select `View` > `Terminal`, or press `Ctrl + ``` (backtick). This will open a terminal panel at the bottom of the VSCode window, where you can run shell commands just like in a regular terminal.
