#import "@preview/ilm:1.4.1": *

#set text(lang: "en")
#show link: underline
#show link: set text(fill: blue)
#show raw: block.with(
  fill: luma(240), // 灰色背景，数值越小越暗
  inset: 2pt, // 内边距
  // radius: 7pt            // 圆角
)
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

= Introduction

Welcome to the MTU MRI GPU Cluster Tutorial. This guide is designed for students who are new to concepts such as SSH, GPU computing, Python, PyTorch, and working with the MRI cluster at Michigan Tech. The tutorial is organized in a modular way, so you can easily find the information you need. For each topic, you will find links to detailed chapters.

First of all, We are going to go throught a quick example of writing a simple python program, testing it locally, browse the MTU MRI cluster to find available resources, finnaly submit the job to the cluster using SLURM.

Through this example, you can click any link to the detailed chapter if you want to learn more about a specific topic. Like #link(<ssh>)[SSH], #link(<python>)[Python], #link(<pytorch>)[PyTorch], #link(<slurm>)[SLURM], etc.

If you have any questions, please feel free to contact me (Jiangqiu Shen) at `jshen2@mtu.edu`
= A Step By Step Example
== Create your GPU application
You can first create a simple project folder on your local machine, and use your favorite IDE to open it. For example, you can use your favorite #link(<shell>)[terminal and shell] and run some #link(<basiccmd>)[commands] to create A folder named `my_mri_project` in your home directory, and open it with #link(<vscode>)[VSCode].


```bash
cd ~;
mkdir my_mri_project;
code my_mri_project;
```


== Browse the MRI cluster to find available resources
== Write a SLURM script to submit your job

= Basic Knowledge

== What is a Cluster?
A cluster is a group of computers (nodes) that work together to perform large-scale computations. The MRI cluster at Michigan Tech, named DeepBlizzard, consists of several types of nodes:

#table(
  columns: (auto, auto, auto, auto),
  align: horizon,
  table.header([*Type*], [*\# Nodes*], [*CPU*], [*Special Hardware*]),
  ["GPU Node"], ["7"], ["64 Cores, 512GB RAM"], ["4x NVIDIA A100 80GB"],
  ["Large Memory Node"], ["3"], ["64 Cores, 1TB RAM"], ["-"],
  ["Compute Node"], ["2"], ["64 Cores"], ["NVIDIA A30 24GB"],
)

== What is SSH?
SSH (Secure Shell) is a protocol for securely connecting to remote computers. You will use SSH to log in to the MRI cluster. See SSH@ssh for details.

== What is a GPU?
A GPU (Graphics Processing Unit) is a specialized processor for parallel computations, essential for deep learning and scientific computing. The MRI cluster provides powerful GPUs for your research.

== What is Python and PyTorch?
Python is a popular programming language for scientific computing. PyTorch is a Python library for deep learning, which can utilize GPUs for fast computation. See Python and Conda@python-conda and PyTorch and GPU for more.

== What is SLURM?
SLURM is a workload manager that schedules jobs on the cluster. You submit your programs to SLURM, which runs them on available nodes. See SLURM Chapter@slurm for more.

= Getting Access to the MRI Cluster

- The MRI cluster is available to students and researchers at Michigan Tech.
- To get an account, contact Dr. Zhang.
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

= SSH: Secure Shell <ssh>

See Appendix: SSH for Mac, Windows, Linux

- On Mac and Linux, use the Terminal.
- On Windows, use PowerShell or an SSH client (see appendix).

Example (replace `yourusername`):
```bash
ssh yourusername@login-mri.research.mtu.edu
```

= Transferring Files: SCP and GUI Tools <file-transfer>

You need to transfer scripts and data to your working directory. You can use `scp` (command line) or GUI tools like WinSCP (Windows) or Cyberduck (Mac).

See [Appendix: File Transfer Tools]

Example (command line):
```bash
scp myfile.py yourusername@login-mri.research.mtu.edu:/mnt/mridata/yourusername/
```

= Python, Conda, and PyTorch <python-conda>

- Use Conda to manage Python environments.
- Load Python modules on the cluster:

```bash
module use /mnt/it_software/easybuild/modules/all
module avail
module load Python/3.9.5-GCCcore-10.3.0
```

- To create a Conda environment:
```bash
conda create -n myenv python=3.9
conda activate myenv
conda install pytorch torchvision torchaudio -c pytorch
```

= Using the MRI Cluster <mri-cluster>

- *Never run programs directly on the login node!*
- Always submit jobs using SLURM.

== Useful Commands
- `sinfo`: Show available partitions and nodes.
- `module avail`: List available software modules.
- `module use /mnt/it_software/easybuild/modules/all`: Add more modules.
- `module load ...`: Load a module.
- `module list`: Show loaded modules.

= Submitting Jobs with SLURM <slurm>

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

== Partition Table
#table(
  columns: (auto, auto, auto, auto),
  align: horizon,
  table.header([*Partition*], [*\# Nodes*], [*Node List*], [*Description*]),
  ["mrigpu"], ["7"], ["compute-1-[0-6]"], ["For programs that use GPUs"],
  ["mrilargemem"], ["3"], ["compute-1-[7-9]"], ["Large memory jobs"],
  ["mrijobs"], ["2"], ["compute-1-[10-11]"], ["General jobs"],
)

== Checking Job Status
- `squeue -u yourusername`: Check your jobs.
- `sinfo`: Check partitions.

= Useful Tips
== Basic Shell Commands <basiccmd>

- `pwd`: Show current directory
- `ls`: List files
- `cd`: Change directory
- `cp`, `mv`, `rm`: Copy, move, remove files
- `cat`, `less`: View file contents
- `nano`, `vim`: Edit files
== Terminal and Shell <shell>
== VSCode <vscode>
== Python <python>
== PyTorch and GPU <pytorch>