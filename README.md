# sudoku-norvig-zig

> Sudoku solver in Zig

Down the [rabbit hole][rabbit-hole] we go, this time with Zig.
Zig was overall a very pleasant experience to program in, despite its youth.
Learning enough Zig to produce this was easy and took less hours compared to doing the same in Rust. 

I think I prefer Zig to Rust for its simplicity.
However, with my limited and basic testing, Rust produces a slightly more performant binary for this particular (weird) task.
Zig outperforms Golang by roughly 2x and blows Python out of the water.

## Build

Release:

```
zig build -Doptimize=ReleaseFast
```

Debug:

```
zig build
```

## Run

Execute the binary produced above.

```
./zig-out/bin/norvig-sudoku-zig
```

## Python

Compare with Python:

```
python3 sudoku.py
```

[rabbit-hole]: https://github.com/mlbright/sudoku-norvig-rs#the-rabbit-hole