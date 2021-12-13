# opensmt-debugging
Miscellaneous shared tools for debugging/profiling opensmt

This README describes how to run following benchmarks.

### Before running benchmarks:

If you are a part of USI team, go through this steps first:

1. Write to `admin.cub@usi.ch` address and request an access to the ICS cluster.
2. After receiving a username and confirming the password connect to the remote server using ssh.

### Simple benchmark run

1. Install and save an executable of your version of [opensmt](https://github.com/usi-verification-and-security/opensmt).
2. Clone this repository to your computer
3. Create bin folder in your home directory and copy opensmt into it, it should look like this: `~/bin/opensmt`
4. Create folder with benchmark tests in your home directory called `~/benchmarks`
5. Open `cluster/bin` folder in this repository
6. Create empty file called `config.smt`
7. Before running benchmarks upload modules needed by openSMT:
```bash
module load readline
module load gmp
```
8. Run benchmarks using `make-and-run-scripts.sh`, add flags to it, so command looks like this:
```bash
./make-and-run-scripts.sh -b QF_LRA -c ./config.smt2
```
That's it, you'ver created and executed benchmark tests for QF_LRA

If you want to explore additional options, run
```bash
./make-and-run-scripts.sh -h
```

*IMPORTANT:* opensmt executables should be built on Linux operating system to be executed on remote server.

### Benchmark comparison



After you've executed the steps from the previous part you should've received 2 folders with scripts and their results.
Before running comparison upload required module:
```bash
module load gnuplot
```
If you have 2 benchmark execution results you may compare their result by using `compare.sh` in the `cluster/bin` folder.
To compare benchmarks run:
```sh
./compare.sh <result1-dir> <result2-dir> 
```
It will produce graph of comparison, which will be accessible at described location.
