"""
The carry chain: a state-free local answer function cannot do it, a stateful cell can.

Self-contained numerical demonstrations of every result in the accompanying paper.
No third-party dependencies; run with `python3 demo.py`.

Conventions
-----------
* Base `b >= 2`. Digit streams are lists with index 0 = least significant column.
* carry[0] = 0 and carry[i+1] = 1 iff x[i] + y[i] + carry[i] >= b.
* digit[i] = (x[i] + y[i] + carry[i]) mod b.

Demonstrations
--------------
1. Column identity and length-general correctness of the carry cell.
2. The witness pair: two inputs differing in one column whose digits differ everywhere.
3. The Carry Wall: any radius-k state-free readout collides at column k+1.
4. Receptive field of a depth-D, radius-r layered local circuit is D*r, and the
   implied depth lower bound n <= D*r + 1.
5. The kill/propagate/generate monoid: associative, non-commutative, and the carry
   chain is its fold.
6. No order-blind pooling: swapping a generate column with a kill column.
7. The stateful cure: an abstract answer cell with a one-bit state, correct at
   lengths far beyond any training unroll.
8. Myhill-Nerode necessity: the zero-column probe reads the carry out of the state.
9. The carry 2-cocycle identity, checked exhaustively.
10. Worst case versus random case: why the obstruction must be measured exactly.
"""

from __future__ import annotations

import random
from itertools import product
from typing import Callable, Dict, Iterable, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------------
# 0. The carry chain
# ----------------------------------------------------------------------------


def carry_chain(b: int, x: Sequence[int], y: Sequence[int], n: int) -> List[int]:
    """Carries c_0, ..., c_n into columns 0..n (c_0 = 0). Length n + 1."""
    carries: List[int] = [0]
    for i in range(n):
        xi = x[i] if i < len(x) else 0
        yi = y[i] if i < len(y) else 0
        carries.append(1 if xi + yi + carries[i] >= b else 0)
    return carries


def digits(b: int, x: Sequence[int], y: Sequence[int], n: int) -> List[int]:
    """Output digits d_0, ..., d_{n-1} of base-b column addition."""
    c = carry_chain(b, x, y, n)
    out: List[int] = []
    for i in range(n):
        xi = x[i] if i < len(x) else 0
        yi = y[i] if i < len(y) else 0
        out.append((xi + yi + c[i]) % b)
    return out


def value(b: int, s: Sequence[int], n: int) -> int:
    """The integer with digit stream s truncated to n columns."""
    return sum(s[i] * b**i for i in range(n) if i < len(s))


def random_stream(b: int, n: int, rng: random.Random) -> List[int]:
    return [rng.randrange(b) for _ in range(n)]


def demo_correctness(trials: int = 2000, seed: int = 0) -> None:
    """1. Column identity, and val(d) + b^n c_n = val(x) + val(y) at every length."""
    print("=" * 78)
    print("1. Length-general correctness of the carry cell")
    print("=" * 78)
    rng = random.Random(seed)
    worst_n = 0
    for _ in range(trials):
        b = rng.randrange(2, 17)
        n = rng.randrange(0, 60)
        x, y = random_stream(b, n, rng), random_stream(b, n, rng)
        c = carry_chain(b, x, y, n)
        d = digits(b, x, y, n)
        # column identity, every column
        for i in range(n):
            assert d[i] + b * c[i + 1] == x[i] + y[i] + c[i]
        # full-sum identity
        assert value(b, d, n) + b**n * c[n] == value(b, x, n) + value(b, y, n)
        worst_n = max(worst_n, n)
    print(f"   verified column identity and the sum identity on {trials} random")
    print(f"   instances, bases 2..16, lengths up to {worst_n}: all exact.")
    b, x, y = 10, [9, 9, 9, 9, 9], [1, 0, 0, 0, 0]
    print(f"   example b=10: {value(b,x,5)} + {value(b,y,5)} = "
          f"{value(b,digits(b,x,y,5),5) + 10**5 * carry_chain(b,x,y,5)[5]}")
    print()


# ----------------------------------------------------------------------------
# 2. The witness pair
# ----------------------------------------------------------------------------


def witness_streams(b: int, n: int) -> Tuple[List[int], List[int], List[int]]:
    """x_hi = (1, b-1, ...), x_lo = (0, b-1, ...), y* = (b-1, 0, ...)."""
    x_hi = [1] + [b - 1] * (n - 1)
    x_lo = [0] + [b - 1] * (n - 1)
    y_st = [b - 1] + [0] * (n - 1)
    return x_hi, x_lo, y_st


def demo_witness(b: int = 10, n: int = 8) -> None:
    """2. One-coordinate perturbation flips every output coordinate."""
    print("=" * 78)
    print("2. The witness pair: maximal sensitivity of the carry chain")
    print("=" * 78)
    x_hi, x_lo, y_st = witness_streams(b, n)
    d_hi, d_lo = digits(b, x_hi, y_st, n), digits(b, x_lo, y_st, n)
    c_hi, c_lo = carry_chain(b, x_hi, y_st, n), carry_chain(b, x_lo, y_st, n)
    show = lambda s: "".join(str(v) for v in reversed(s))
    print(f"   base {b}, {n} columns (printed most-significant first)")
    print(f"   x_hi = {show(x_hi)}   x_lo = {show(x_lo)}   y*   = {show(y_st)}")
    print(f"   x_hi and x_lo differ ONLY in column 0.")
    print(f"   digits(x_hi + y*) = {show(d_hi)}")
    print(f"   digits(x_lo + y*) = {show(d_lo)}")
    agree = [i for i in range(1, n) if d_hi[i] == d_lo[i]]
    print(f"   columns >= 1 on which the two outputs agree: {agree} (none)")
    print(f"   carries   (x_hi): {c_hi}")
    print(f"   carries   (x_lo): {c_lo}")
    assert all(d_hi[i] != d_lo[i] for i in range(1, n))
    assert all(c_hi[i] == 1 for i in range(1, n + 1))
    assert all(v == 0 for v in c_lo)
    print()


# ----------------------------------------------------------------------------
# 3. The Carry Wall
# ----------------------------------------------------------------------------


def wall_collision(b: int, k: int) -> Tuple[int, List[int], List[int], List[int], int, int]:
    """A radius-k collision at column k+1: identical windows, different true digits.

    Returns (column, x_hi, x_lo, y*, true digit for x_hi, true digit for x_lo).
    """
    n = k + 3
    x_hi, x_lo, y_st = witness_streams(b, n)
    i = k + 1
    lo = max(0, i - k)
    assert x_hi[lo:i + 1] == x_lo[lo:i + 1], "windows must be identical"
    d_hi = digits(b, x_hi, y_st, n)[i]
    d_lo = digits(b, x_lo, y_st, n)[i]
    assert d_hi != d_lo
    return i, x_hi, x_lo, y_st, d_hi, d_lo


def demo_wall(b: int = 10, radii: Iterable[int] = (0, 1, 2, 3, 5, 8, 16, 64)) -> None:
    """3. For every radius k, correctness is impossible at column k+1."""
    print("=" * 78)
    print("3. The Carry Wall: no state-free readout of any bounded radius")
    print("=" * 78)
    print("   radius k | fails at column | window seen by the readout | true digits")
    print("   ---------+-----------------+----------------------------+------------")
    for k in radii:
        i, x_hi, x_lo, _, d_hi, d_lo = wall_collision(b, k)
        window = f"cols {max(0, i-k)}..{i}"
        print(f"   {k:8d} | {i:15d} | {window:26s} | {d_hi} vs {d_lo}")
    print("   In every row the two inputs are IDENTICAL on the window, so any")
    print("   state-free readout of that radius must return the same digit, while")
    print(f"   the correct digits are 0 and b-1 = {b-1}. Correctness is impossible.")
    print()


# ----------------------------------------------------------------------------
# 4. Layered local circuits: receptive field and depth bound
# ----------------------------------------------------------------------------


def receptive_field(depth: int, radius: int, column: int) -> Set[int]:
    """Simulate dependency propagation in a depth-D, radius-r layered circuit.

    Layer 0 at column i depends on input column i; each further layer unions the
    dependency sets of columns i-r..i.  Returns the set of input columns the
    depth-`depth` value at `column` can depend on.
    """
    deps: Dict[int, Set[int]] = {i: {i} for i in range(0, column + 1)}
    for _ in range(depth):
        new: Dict[int, Set[int]] = {}
        for i in range(0, column + 1):
            acc: Set[int] = set()
            for j in range(max(0, i - radius), i + 1):
                acc |= deps[j]
            new[i] = acc
        deps = new
    return deps[column]


def demo_depth_bound() -> None:
    """4. Receptive field is depth*radius; hence n <= depth*radius + 1."""
    print("=" * 78)
    print("4. Fixed depth buys length only linearly")
    print("=" * 78)
    print("   depth D | radius r | reach = D*r | simulated span | max provably")
    print("           |          |             | at column 200  | correct length n")
    print("   --------+----------+-------------+----------------+-----------------")
    for depth, radius in [(1, 1), (2, 1), (4, 1), (6, 2), (8, 3), (12, 4), (24, 8)]:
        col = 200
        rf = receptive_field(depth, radius, col)
        span = col - min(rf)
        assert span == min(depth * radius, col)
        print(f"   {depth:7d} | {radius:8d} | {depth*radius:11d} | {span:14d} "
              f"| {depth*radius + 1:16d}")
    print("   The simulated span matches D*r exactly, so a circuit correct on all")
    print("   columns i < n needs n <= D*r + 1, i.e. D >= (n-1)/r: depth must grow")
    print("   LINEARLY in the number of digits.  A one-bit stateful cell has no")
    print("   such bound (see demonstration 7).")
    print()


# ----------------------------------------------------------------------------
# 5. The kill / propagate / generate monoid
# ----------------------------------------------------------------------------

KILL, PROP, GEN = "kill", "prop", "gen"
SIGNALS: Tuple[str, str, str] = (KILL, PROP, GEN)


def act(s: str, c: int) -> int:
    return 0 if s == KILL else (c if s == PROP else 1)


def comp(s: str, t: str) -> str:
    """Apply t, then s."""
    if s == KILL:
        return KILL
    if s == GEN:
        return GEN
    return t


def col_signal(b: int, xi: int, yi: int) -> str:
    if xi + yi >= b:
        return GEN
    if xi + yi == b - 1:
        return PROP
    return KILL


def chain_signal(b: int, x: Sequence[int], y: Sequence[int], n: int) -> str:
    s = PROP
    for i in range(n):
        s = comp(col_signal(b, x[i], y[i]), s)
    return s


def demo_monoid(seed: int = 1) -> None:
    """5. Associative, non-commutative, and the carry is its fold."""
    print("=" * 78)
    print("5. The kill / propagate / generate monoid")
    print("=" * 78)
    for s, t, u in product(SIGNALS, repeat=3):
        assert comp(comp(s, t), u) == comp(s, comp(t, u))
    for s, c in product(SIGNALS, (0, 1)):
        assert comp(PROP, s) == s and comp(s, PROP) == s
        for t in SIGNALS:
            assert act(comp(s, t), c) == act(s, act(t, c))
    print("   associativity: verified on all 27 triples")
    print("   identity     : prop, verified on all 3 elements")
    print(f"   kill o gen = {comp(KILL, GEN)},  gen o kill = {comp(GEN, KILL)}"
          "   ->  NOT commutative")
    print("   composition table (rows = s, cols = t, entry = s o t):")
    print("        " + "".join(f"{t:>6s}" for t in SIGNALS))
    for s in SIGNALS:
        print(f"   {s:>4s}" + "".join(f"{comp(s, t):>6s}" for t in SIGNALS))
    rng = random.Random(seed)
    for _ in range(500):
        b = rng.randrange(2, 13)
        n = rng.randrange(0, 40)
        x, y = random_stream(b, n, rng), random_stream(b, n, rng)
        assert act(chain_signal(b, x, y, n), 0) == carry_chain(b, x, y, n)[n]
    print("   carry_n = (fold of column signals) applied to 0: verified on 500")
    print("   random instances.")
    print()


# ----------------------------------------------------------------------------
# 6. No order-blind pooling
# ----------------------------------------------------------------------------


def demo_no_pooling(b: int = 10) -> None:
    """6. Swapping a generate column with a kill column flips the carry."""
    print("=" * 78)
    print("6. Order-blind pooling cannot carry")
    print("=" * 78)
    gk_x, gk_y = [b - 1, 0], [1, 0]     # generate then kill
    kg_x, kg_y = [0, b - 1], [0, 1]     # kill then generate
    c_gk = carry_chain(b, gk_x, gk_y, 2)[2]
    c_kg = carry_chain(b, kg_x, kg_y, 2)[2]
    print(f"   columns (as (x,y) pairs), low to high:")
    print(f"     A = [({gk_x[0]},{gk_y[0]}), ({gk_x[1]},{gk_y[1]})]  ->  carry out = {c_gk}")
    print(f"     B = [({kg_x[0]},{kg_y[0]}), ({kg_x[1]},{kg_y[1]})]  ->  carry out = {c_kg}")
    print("   A and B are the same MULTISET of columns in the opposite order.")
    print("   Any commutative pooling of position-blind column features (sum, mean,")
    print("   max, unordered attention) assigns them the same pooled value, so no")
    print("   threshold of that value can output both carries.")
    assert c_gk != c_kg
    print()


# ----------------------------------------------------------------------------
# 7. The stateful cure
# ----------------------------------------------------------------------------


class AnswerCell:
    """An abstract answer cell: init state, transition, readout.

    `step` and `out` are arbitrary functions of (state, x_i, y_i); the cell is
    length-independent by construction -- the same transition at every column.
    """

    def __init__(
        self,
        init: object,
        step: Callable[[object, int, int], object],
        out: Callable[[object, int, int], int],
    ) -> None:
        self.init = init
        self.step = step
        self.out = out

    def run(self, x: Sequence[int], y: Sequence[int], i: int) -> object:
        s = self.init
        for j in range(i):
            s = self.step(s, x[j], y[j])
        return s

    def answers(self, x: Sequence[int], y: Sequence[int], n: int) -> List[int]:
        s = self.init
        res: List[int] = []
        for i in range(n):
            res.append(self.out(s, x[i], y[i]))
            s = self.step(s, x[i], y[i])
        return res


def carry_cell(b: int) -> AnswerCell:
    """The one-bit cell: state in {0,1}, one length-independent transition."""
    return AnswerCell(
        init=0,
        step=lambda c, u, v: 1 if u + v + int(c) >= b else 0,
        out=lambda c, u, v: (u + v + int(c)) % b,
    )


def exotic_cell(b: int) -> AnswerCell:
    """A cell with a large, redundant state that merely SUMMARISES to the carry.

    State is a pair (running column count, carry).  The summary rho is the second
    component; the theorem's hypotheses hold, so correctness at all lengths is
    automatic even though the state type is infinite.
    """
    return AnswerCell(
        init=(0, 0),
        step=lambda s, u, v: (s[0] + 1, 1 if u + v + s[1] >= b else 0),  # type: ignore[index]
        out=lambda s, u, v: (u + v + s[1]) % b,  # type: ignore[index]
    )


def demo_stateful_cure(seed: int = 2) -> None:
    """7. One-column correctness => correctness at every length."""
    print("=" * 78)
    print("7. The stateful cure: one bit of state, correct at every length")
    print("=" * 78)
    rng = random.Random(seed)
    for b in (2, 3, 10, 16):
        cell, exotic = carry_cell(b), exotic_cell(b)
        for n in (1, 5, 6, 7, 8, 50, 500):
            for _ in range(20):
                x, y = random_stream(b, n, rng), random_stream(b, n, rng)
                assert cell.answers(x, y, n) == digits(b, x, y, n)
                assert exotic.answers(x, y, n) == digits(b, x, y, n)
        print(f"   base {b:2d}: one-bit cell exact at lengths 1,5,6,7,8,50,500 "
              "(and the redundant-state cell too)")
    # the worst case that breaks every local readout is handled exactly
    b, n = 10, 40
    x_hi, x_lo, y_st = witness_streams(b, n)
    cell = carry_cell(b)
    assert cell.answers(x_hi, y_st, n) == digits(b, x_hi, y_st, n)
    assert cell.answers(x_lo, y_st, n) == digits(b, x_lo, y_st, n)
    print(f"   the adversarial witness pair at {n} columns -- the input that defeats")
    print("   EVERY bounded-window state-free readout -- is handled exactly.")
    print("   Trained on 5 columns, correct on 500: nothing in the cell knows n.")
    print()


# ----------------------------------------------------------------------------
# 8. Myhill-Nerode: the state must contain the carry
# ----------------------------------------------------------------------------


def demo_nerode(b: int = 10, seed: int = 3) -> None:
    """8. Probing a correct cell with a zero column reads its carry."""
    print("=" * 78)
    print("8. Necessity: a correct cell's state determines the carry")
    print("=" * 78)
    rng = random.Random(seed)
    cell = exotic_cell(b)  # any correct cell, state type deliberately not {0,1}
    print("   probe: replace column i by (0,0); the emitted digit is then")
    print("   (0 + 0 + carry) mod b = carry, so the cell's own output reveals it.")
    hits = 0
    for _ in range(400):
        n = rng.randrange(1, 25)
        x, y = random_stream(b, n, rng), random_stream(b, n, rng)
        i = rng.randrange(n)
        s = cell.run(x, y, i)
        probe = cell.out(s, 0, 0)
        true_carry = carry_chain(b, x, y, n)[i]
        assert probe == true_carry
        hits += 1
    print(f"   {hits}/400 random histories: probe output == true carry, always.")
    print("   Hence two histories in the same state have the same carry: the carry")
    print("   bit factors through the reachable states.  One bit is not only")
    print("   sufficient -- it is forced.")
    print()


# ----------------------------------------------------------------------------
# 9. The carry 2-cocycle
# ----------------------------------------------------------------------------


def carry_of(b: int, u: int, v: int) -> int:
    return (u + v) // b


def demo_cocycle(bases: Iterable[int] = (2, 3, 5, 10)) -> None:
    """9. c(u,v) + c((u+v) mod b, w) = c(v,w) + c(u, (v+w) mod b)."""
    print("=" * 78)
    print("9. The carry is a 2-cocycle")
    print("=" * 78)
    for b in bases:
        checked = 0
        for u, v, w in product(range(b), repeat=3):
            lhs = carry_of(b, u, v) + carry_of(b, (u + v) % b, w)
            rhs = carry_of(b, v, w) + carry_of(b, u, (v + w) % b)
            assert lhs == rhs == (u + v + w) // b
            checked += 1
        # symmetry and normalisation
        for u, v in product(range(b), repeat=2):
            assert carry_of(b, u, v) == carry_of(b, v, u) <= 1
            assert carry_of(b, u, v) == (1 if u + v >= b else 0)
        for v in range(b):
            assert carry_of(b, 0, v) == 0
        print(f"   base {b:2d}: cocycle identity verified on all {checked} triples; "
              "both sides equal floor((u+v+w)/b);")
        print(f"            c is symmetric, normalised (c(0,v)=0) and takes values in "
              "{0,1}.")
    print("   c presents the extension 0 -> Z/b -> Z/b^2 -> Z/b -> 0, whose class is")
    print("   nonzero exactly because carrying occurs.  The COLUMN is order-free;")
    print("   order-sensitivity is created by COMPOSITION (demonstration 5).")
    print()


# ----------------------------------------------------------------------------
# 10. Worst case versus random case
# ----------------------------------------------------------------------------


def oracle_local_digit(b: int, x: Sequence[int], y: Sequence[int], i: int, k: int) -> int:
    """The best a radius-k state-free readout can do: assume carry 0 into i-k.

    It sees columns i-k..i only, so it guesses the carry into column i-k (here: 0)
    and then runs the chain forward inside the window.
    """
    lo = max(0, i - k)
    c = 0
    for j in range(lo, i):
        c = 1 if x[j] + y[j] + c >= b else 0
    return (x[i] + y[i] + c) % b


def demo_worst_vs_random(b: int = 10, k: int = 2, n: int = 8, trials: int = 20000,
                         seed: int = 4) -> None:
    """10. Random inputs hide an obstruction that is exact and worst-case."""
    print("=" * 78)
    print("10. Worst case versus random case")
    print("=" * 78)
    rng = random.Random(seed)
    per_col_err = 0
    seq_err = 0
    total_cols = 0
    for _ in range(trials):
        x, y = random_stream(b, n, rng), random_stream(b, n, rng)
        truth = digits(b, x, y, n)
        pred = [oracle_local_digit(b, x, y, i, k) for i in range(n)]
        bad = sum(1 for i in range(n) if pred[i] != truth[i])
        per_col_err += bad
        seq_err += 1 if bad else 0
        total_cols += n
    print(f"   base {b}, radius k={k}, {n} columns, {trials} uniform random problems:")
    print(f"     per-column accuracy of the best radius-{k} readout : "
          f"{1 - per_col_err/total_cols:.4f}")
    print(f"     full-sequence accuracy                            : "
          f"{1 - seq_err/trials:.4f}")
    x_hi, x_lo, y_st = witness_streams(b, n)
    for name, x in (("x_hi", x_hi), ("x_lo", x_lo)):
        truth = digits(b, x, y_st, n)
        pred = [oracle_local_digit(b, x, y_st, i, k) for i in range(n)]
        bad = [i for i in range(n) if pred[i] != truth[i]]
        print(f"   adversarial witness {name}: wrong at columns {bad}")
    print("   Uniform random digits make a long run of propagate columns rare, so a")
    print("   local readout looks almost perfect on average.  The obstruction is a")
    print("   statement about EXACT correctness on ALL inputs, and the witness pair")
    print("   realises it at the very first column beyond the window.")
    print()


# ----------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE CARRY CHAIN: A STATE-FREE LOCAL ANSWER FUNCTION CANNOT DO IT,")
    print("#  A STATEFUL CELL CAN.")
    print("#" * 78)
    print()
    demo_correctness()
    demo_witness()
    demo_wall()
    demo_depth_bound()
    demo_monoid()
    demo_no_pooling()
    demo_stateful_cure()
    demo_nerode()
    demo_cocycle()
    demo_worst_vs_random()
    print("=" * 78)
    print("All demonstrations completed; every assertion held.")
    print("=" * 78)


if __name__ == "__main__":
    main()
