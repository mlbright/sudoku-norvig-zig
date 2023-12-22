## Solve Every Sudoku Puzzle

## See http://norvig.com/sudoku.html

digits = "123456789"


def horizontal():
    units = []
    for i in range(9):
        units.append([(i * 9) + j for j in range(9)])
    return units


def vertical():
    units = []
    for i in range(9):
        units.append([i + (j * 9) for j in range(9)])
    return units


def box_units():
    units = []
    for r in [[0, 1, 2], [3, 4, 5], [6, 7, 8]]:
        for c in [[0, 1, 2], [3, 4, 5], [6, 7, 8]]:
            unit = [(i + 9 * j) for i in r for j in c]
            units.append(sorted(unit))

    return units


unitlist = horizontal()
unitlist.extend(vertical())
unitlist.extend(box_units())

units = []
for i in range(81):
    group = []
    for unit in unitlist:
        if i in unit:
            group.append(unit[:])
    units.append(group)

peers = []
for i in range(81):
    peer_set = set()
    for unit in units[i]:
        for s in unit:
            if i != s:
                peer_set.add(s)
    peers.append(peer_set)

################ Unit Tests ################


def test():
    "A set of tests that must pass."
    assert len(unitlist) == 27
    assert all(len(units[s]) == 3 for s in range(81))
    assert all(len(peers[s]) == 20 for s in range(81))
    assert units[19] == [
        [18, 19, 20, 21, 22, 23, 24, 25, 26],
        [1, 10, 19, 28, 37, 46, 55, 64, 73],
        [0, 1, 2, 9, 10, 11, 18, 19, 20],
    ]
    assert peers[19] == {
        0,
        1,
        2,
        9,
        10,
        11,
        18,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        28,
        37,
        46,
        55,
        64,
        73,
    }
    print("All tests pass.")


################ Parse a Grid ################


def parse_grid(grid):
    """Convert grid to a dict of possible values, [square: digits], or
    return False if a contradiction is detected."""
    ## To start, every square can be any digit; then assign values from the grid.
    values = [digits for s in range(81)]
    for s, d in enumerate(grid_values(grid)):
        if d in digits and not assign(values, s, d):
            return False  ## (Fail if we can't assign d to square s.)
    return values


def grid_values(grid):
    "Convert grid into a dict of {square: char} with '0' or '.' for empties."
    chars = [c for c in grid if c in digits or c in "0."]
    assert len(chars) == 81
    return chars


################ Constraint Propagation ################


def assign(values, s, d):
    """Eliminate all the other values (except d) from values[s] and propagate.
    Return values, except return False if a contradiction is detected."""
    other_values = values[s].replace(d, "")
    if all(eliminate(values, s, d2) for d2 in other_values):
        return values
    else:
        return False


def eliminate(values, s, d):
    """Eliminate d from values[s]; propagate when values or places <= 2.
    Return values, except return False if a contradiction is detected."""
    if d not in values[s]:
        return values  ## Already eliminated
    values[s] = values[s].replace(d, "")
    ## (1) If a square s is reduced to one value d2, then eliminate d2 from the peers.
    if len(values[s]) == 0:
        return False  ## Contradiction: removed last value
    elif len(values[s]) == 1:
        if not all(eliminate(values, s2, values[s]) for s2 in peers[s]):
            return False
    ## (2) If a unit u is reduced to only one place for a value d, then put it there.
    for u in units[s]:
        dplaces = [s for s in u if d in values[s]]
        if len(dplaces) == 0:
            return False  ## Contradiction: no place for this value
        elif len(dplaces) == 1:
            # d can only be in one place in unit; assign it there
            if not assign(values, dplaces[0], d):
                return False
    return values


################ Display as 2-D grid ################


def display(values):
    "Display these values as a 2-D grid."
    width = 2 + max([len(str(s)) for s in values])
    line = "+".join(["-" * (width * 3)] * 3)
    for r in [0, 9, 18, 27, 36, 45, 54, 63, 72]:
        print(
            "".join(
                values[c + r].center(width) + ("|" if c in [2, 5] else "")
                for c in [0, 1, 2, 3, 4, 5, 6, 7, 8]
            )
        )
        if r in [18, 45]:
            print(line)
    print()


################ Search ################


def solve(grid):
    return search(parse_grid(grid))


def search(values):
    "Using depth-first search and propagation, try all possible values."
    if values is False:
        return False  ## Failed earlier
    if all(len(values[s]) == 1 for s in range(81)):
        return values  ## Solved!
    ## Chose the unfilled square s with the fewest possibilities
    n, s = min((len(values[s]), s) for s in range(81) if len(values[s]) > 1)
    return some(search(assign(values.copy(), s, d)) for d in values[s])


################ Utilities ################


def some(seq):
    "Return some element of seq that is true."
    for e in seq:
        if e:
            return e
    return False


def from_file(filename, sep="\n"):
    "Parse a file into a list of strings, separated by sep."
    with open(filename) as f:
        return f.read().strip().split(sep)


def shuffled(seq):
    "Return a randomly shuffled copy of the input sequence."
    seq = list(seq)
    random.shuffle(seq)
    return seq


################ System test ################

import time, random


def solve_all(grids, name="", showif=None):
    """Attempt to solve a sequence of grids. Report results.
    When showif is a number of seconds, display puzzles that take longer.
    When showif is None, don't display any puzzles."""

    def time_solve(grid):
        start = time.time()
        values = solve(grid)
        t = time.time() - start
        ## Display puzzles that take long enough
        if showif is not None and t > showif:
            display(grid_values(grid))
            if values:
                display(values)
            print("(%.5f seconds)\n" % t)
        return (t, solved(values))

    times, results = zip(*[time_solve(grid) for grid in grids])
    N = len(grids)
    if N > 0:
        print(
            "Solved %d of %d %s puzzles (avg %.4f secs (%.2f Hz), max %.4f secs)."
            % (sum(results), N, name, sum(times) / N, N / sum(times), max(times))
        )


def solved(values):
    "A puzzle is solved if each unit is a permutation of the digits 1 to 9."

    def unitsolved(unit):
        return set(values[s] for s in unit) == set(digits)

    return values is not False and all(unitsolved(unit) for unit in unitlist)


def random_puzzle(N=17):
    """Make a random puzzle with N or more assignments. Restart on contradictions.
    Note the resulting puzzle is not guaranteed to be solvable, but empirically
    about 99.8% of them are solvable. Some have multiple solutions."""
    values = [digits for s in range(81)]
    for s in shuffled(range(81)):
        if not assign(values, s, random.choice(values[s])):
            break
        ds = [values[s] for s in range(81) if len(values[s]) == 1]
        if len(ds) >= N and len(set(ds)) >= 8:
            return "".join(values[s] if len(values[s]) == 1 else "." for s in range(81))
    return random_puzzle(N)  ## Give up and make a new puzzle


if __name__ == "__main__":
    test()
    solve_all(from_file("puzzles/one.txt"), "one", None)
    solve_all(from_file("puzzles/three.txt"), "three", 0.05)
    solve_all(from_file("puzzles/easy50.txt"), "easy", None)
    solve_all(from_file("puzzles/top95.txt"), "hard", 0.05)
    # solve_all(from_file("puzzles/hardest.txt"), "hardest", None)
    # solve_all(from_file("puzzles/hardest20.txt"), "hardest20", None)
    # solve_all(from_file("puzzles/hardest20x50.txt"), "hardest20x50", 0.05)
    # solve_all(from_file("puzzles/topn87.txt"), "topn87", 0.05)
    # solve_all([random_puzzle() for _ in range(100)], "random", 0.003)


# Reference:
# https://norvig.com/sudoku.html
# References from ^:
# http://www.scanraid.com/BasicStrategies.htm
# http://www.sudokudragon.com/sudokustrategy.htm
# http://www.krazydad.com/blog/2005/09/29/an-index-of-sudoku-strategies/
# http://www2.warwick.ac.uk/fac/sci/moac/currentstudents/peter_cock/python/sudoku/
