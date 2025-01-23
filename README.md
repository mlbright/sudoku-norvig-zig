# sudoku-norvig-zig

> Sudoku solver in Zig

Down the [rabbit hole][rabbit-hole] we go, this time with Zig.
Zig was overall a very pleasant experience to program in, despite its youth.
Learning enough Zig to produce this was easy and took less time compared to doing [the same in Rust][sudoku-rust].
I think I prefer Zig to Rust for its simplicity.

However, with my limited and basic testing, Rust produces a 20-30% more performant binary for this particular (weird) task.
Zig easily outperforms Golang (by roughly 2x) and blows Python out of the water.
Interestingly, this Zig version uses significantly less memory (~300K) than both the Rust (1.7MB) and Go (6MB) versions.

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

## Profile

Profile the programs:

```bash
hyperfine --warmup 3 './sudoku-ffi-rosetta.lua' --export-markdown lua.md
hyperfine --warmup 3 './zig-out/bin/norvig-sudoku-zig' --export-markdown zig.md
hyperfine --warmup 3 './sudoku.py' --export-markdown python3.md
```

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `./sudoku-ffi-rosetta.lua` | 7.0 ± 0.7 | 5.3 | 8.4 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `./zig-out/bin/norvig-sudoku-zig` | 2.7 ± 0.3 | 2.2 | 4.6 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `./sudoku.py` | 38.4 ± 1.0 | 34.9 | 39.6 | 1.00 |

## Better algorithm

In theory, there's a a better algorithm for solving Sudoku puzzles, see:

- [Exact Cover Dancing Links][exact-cover-dancing-links] and the [matrix](exact-cover-matrix).
- C++ implementation: [sudoku-dlx][sudoku-dlx]
- [wikipedia article][wiki-sudoku-algorithms]

I might try to implement this in Zig or Lua next.


[rabbit-hole]: https://github.com/mlbright/sudoku-norvig-rs#the-rabbit-hole
[exact-cover-dancing-links]: https://cs.indstate.edu/~bdhome/SUDOKU.pdf
[exact-cover-matrix]: https://www.stolaf.edu/people/hansonr/sudoku/exactcovermatrix.htm
[sudoku-dlx]: https://gieseanw.wordpress.com/2011/06/16/solving-sudoku-revisited/
[wiki-sudoku-algorithms]: https://en.wikipedia.org/wiki/Exact_cover#Sudoku
[sudoku-rust]: https://github.com/mlbright/sudoku-norvig-rs
