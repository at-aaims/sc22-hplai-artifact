# sc22-hplai-artifact
# HPL-AI: OLCF Mixed Precision Benchmark
- [HPL-AI: OLCF Mixed Precision Benchmark](#hpl-ai-olcf-mixed-precision-benchmark)
  - [Build instructions ( Frontier/Crusher ) for rocm/4.5.2](#build-instructions--frontiercrusher--for-rocm452)
  - [Running instructions ( Frontier/Crusher )](#running-instructions--frontiercrusher-)
    - [Comments](#comments)
  - [Build instruction (Summit)](#build-instruction-summit)
  - [Example Runs](#example-runs)
  - [New Options](#new-options)
  - [Contributors](#contributors)

## Build instructions ( Frontier/Crusher ) for rocm/4.5.2

```sh
cd hpl-ai
mkdir build
cd build
cp ../doc/build_hpl.ai_frontier.sh .
```

That script runs `../doc/load_hpl_modules_frontier.sh` which may need to be modified for different rocm versions.

```sh
./build_hpl.ai_frontier.sh
```
You should now have a driver.x86_64 binary.


## Running instructions ( Frontier/Crusher )

```sh
mkdir jobs
cd jobs
cp ../doc/job_example.slurm
```
Change this script to meet your needs.

```sh
sbatch job_example.slurm
```
The output from crusher is in `crusher_example_32x32.out`.

One can see that on 128 nodes ( 1024 GCD ) that HPL-AI achieved 96.67 PF.
That translates to an effective 94.4 TF/GCD and means that the gemms were
running faster.


### Comments

HPL-AI is designed to run at scale.   When it is run at a few number of nodes,
the performance will suffer due to the Iterative Refinement (IR) which is done
on cpu.  At larger scales, this time becomes insignificant in the run.

There are requirements between N, B, PxQ ( process grid ), and the local grid.
Some are enforced while others are not.  It is usually easier to run square
( PxQ ) that are multiples of 8.  The best B tends to be 3072 and the best
performing local N (LN) tends to be 119808.   So this will give a N of P*LN.

Things to do still - the intent was to instrument this for code events.
That work was never completed.  The timer files can provide some guidance but
can be inaccurate due to routines returning and asynchronous operations.

Rocm/5.0.2 can be made to compile/run but in early testing seems to provide
inferior results.  The first 50% of the run seems faster but performance
drops off quickly in the last 50% of the run.  This needs to be investigated
further.

The change to a GPU variant of IR has been discussed.  It currently works on
CPU with a far amount of communications and mostly operations that may not
be advantageous on a GPU.

## Example Runs

please refer to tests/summit/README.md for up to date information.

Spock SLURM example
```sh
srun -N 25 -n 100 -c 8 --ntasks-per-node=4 \
      --gpus-per-task=1 --gpu-bind=closest ../../build/driver.x86_64 \
      N b P -log 0 -comm <comm> --numa 2 -sys "Frontier"
```

## New Options

The following description assume to use `Makefile.legacy`, which generate
`driver2.out`.

```
./driver2.out n b P
```

Here n is the target - the real n will be computed based on the target and constraints caused by b, P&Q so that there are full blocks

```
-log 1 ( print rank 0 messages )

-solv 0 ( use cublas )
      1 ( use cusolver ) # default (fastest)
      Current only switches on ibcast - bcast is cusolver

-comm 0 ( use ibcast )
      1 ( use bcast )    # default (typically fastest)
      2 ( use 1ring )
      3 ( use 1ringM )
      4 ( use 2ringM )

--numa 0 ( Row major )
       1 ( Column major ) 
       2 ( 2x2 Frontier specific )

-gdirect (GPU awared MPI)

-sys "Frontier"          # system name

-sync ( enable cuda device sync after sgemm - currently only for bcast )
```
