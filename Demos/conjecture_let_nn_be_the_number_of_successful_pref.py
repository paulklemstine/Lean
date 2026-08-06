#!/usr/bin/env python3
"""
Submultiplicative Search Entropy and the Perron Root
====================================================

Numerical demonstrations of the proof-search dimension theory.

The theory in one paragraph
---------------------------
Let N(n) count the "successful prefixes" of length n in a pruned search tree:
partial search paths of depth n that have not yet been killed.  Two hypotheses
suffice for everything:

    (P1)  N(n) >= 1                       (nondegeneracy)
    (P2)  N(m + n) <= N(m) * N(n)         (submultiplicativity)

Then the finite-scale rates log N(n) / n converge, and the limit -- the
ENTROPY RATE h -- equals the INFIMUM of those rates.  Normalizing by the
ambient branching factor b gives the PROOF-SEARCH DIMENSION

    dim = h / log b   in   [0, 1].

For finite-state pruning with nonnegative transition matrix A, the path counts
P(n) = sum of all entries of A^n are submultiplicative, and if A has an
eigenvector v with 0 < c <= v_i <= C for eigenvalue r > 0 then

    c * P(n)  <=  r^n * sum(v)  <=  C * P(n)          (Perron sandwich)

so h = log r and dim = log r / log b (the Bridge Theorem).  Running the
infimum characterization backwards gives, for every n,

    r^n <= sum_{i,j} (A^n)_{ij}                       (Perron domination)

which for the "no two consecutive expensive steps" automaton in the binary
tree specializes to  phi^n <= F(n+3),  with dim = log phi / log 2 ~ 0.6942.

This file is self-contained: standard library only, all helpers inlined.
Run with:   python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Iterable, List, Sequence, Tuple

Matrix = List[List[float]]
Vector = List[float]

SEP = "=" * 78
SUB = "-" * 78


# ----------------------------------------------------------------------------
# Basic linear algebra (pure Python, no dependencies)
# ----------------------------------------------------------------------------

def mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Ordinary matrix product.  Cost O(k^3) for k x k inputs."""
    n, m, p = len(A), len(B), len(B[0])
    return [[sum(A[i][t] * B[t][j] for t in range(m)) for j in range(p)]
            for i in range(n)]


def mat_vec(A: Matrix, v: Vector) -> Vector:
    """Matrix-vector product A v.  Cost O(k^2)."""
    return [sum(A[i][j] * v[j] for j in range(len(v))) for i in range(len(A))]


def identity(k: int) -> Matrix:
    return [[1.0 if i == j else 0.0 for j in range(k)] for i in range(k)]


def mat_pow(A: Matrix, n: int) -> Matrix:
    """A^n by binary exponentiation.  Cost O(k^3 log n)."""
    result = identity(len(A))
    base = [row[:] for row in A]
    while n > 0:
        if n & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        n >>= 1
    return result


def path_count(A: Matrix, n: int) -> float:
    """P(n) = sum of ALL entries of A^n: the number of accepted length-n paths."""
    return sum(sum(row) for row in mat_pow(A, n))


def path_counts_upto(A: Matrix, m: int) -> List[float]:
    """P(0), ..., P(m) in O(m k^2) by propagating the row-sum vector u = A^n 1."""
    k = len(A)
    u: Vector = [1.0] * k          # u = A^0 * 1
    out: List[float] = []
    for _ in range(m + 1):
        out.append(sum(u))
        u = mat_vec(A, u)
    return out


# ----------------------------------------------------------------------------
# The two headline constants
# ----------------------------------------------------------------------------

PHI: float = (1.0 + math.sqrt(5.0)) / 2.0          # golden ratio ~ 1.6180339887
FIB_MATRIX: Matrix = [[1.0, 1.0],
                      [1.0, 0.0]]                   # "no two expensive steps in a row"


def fibonacci(m: int) -> int:
    """F(1) = F(2) = 1, F(m+2) = F(m+1) + F(m); F(0) = 0."""
    a, b = 0, 1
    for _ in range(m):
        a, b = b, a + b
    return a


# ----------------------------------------------------------------------------
# Search profiles: entropy rate and proof-search dimension
# ----------------------------------------------------------------------------

def finite_scale_rate(N: Callable[[int], float], n: int) -> float:
    """rate(n) = log N(n) / n, the average branching entropy out to depth n."""
    if n < 1:
        raise ValueError("finite-scale rates are defined for n >= 1")
    return math.log(N(n)) / n


def entropy_upper_bound(N: Callable[[int], float], depth: int) -> float:
    """
    CERTIFIED upper bound on the entropy rate: min over 1 <= n <= depth of
    log N(n) / n.  Because the Fekete limit is the INFIMUM of the finite-scale
    rates, this is not an estimate -- it is a proved bound on h, valid no
    matter how the profile behaves beyond `depth`.
    """
    return min(finite_scale_rate(N, n) for n in range(1, depth + 1))


def proof_search_dimension(entropy: float, b: float) -> float:
    """dim = h / log b, the ambient-normalized (fractal) dimension."""
    return entropy / math.log(b)


def check_submultiplicative(N: Callable[[int], float], bound: int) -> Tuple[bool, float]:
    """
    Verify N(m+n) <= N(m) N(n) for all 0 <= m, n <= bound and report the worst
    "defect ratio" N(m+n) / (N(m) N(n)) observed.  A ratio of 1 means the
    inequality is tight; smaller ratios measure how many (prefix, suffix)
    pairs fail to concatenate into a live path.
    """
    ok = True
    worst = 0.0
    for m in range(bound + 1):
        for n in range(bound + 1):
            lhs, rhs = N(m + n), N(m) * N(n)
            if lhs > rhs * (1 + 1e-12):
                ok = False
            worst = max(worst, lhs / rhs)
    return ok, worst


# ----------------------------------------------------------------------------
# Perron machinery
# ----------------------------------------------------------------------------

def perron_root_power_iteration(
    A: Matrix, iters: int = 400, tol: float = 1e-15
) -> Tuple[float, Vector]:
    """
    Scaled power iteration x <- A x / ||A x||_1 from a positive start.
    Returns (r, v) with v normalized so that min(v) = 1.
    Cost O(k^2) per iteration; geometric convergence at rate |lambda_2| / r.
    """
    k = len(A)
    x: Vector = [1.0 / k] * k
    r = 0.0
    for _ in range(iters):
        y = mat_vec(A, x)
        norm = sum(abs(t) for t in y)
        if norm == 0.0:
            return 0.0, x
        new_x = [t / norm for t in y]
        if max(abs(new_x[i] - x[i]) for i in range(k)) < tol:
            x, r = new_x, norm
            break
        x, r = new_x, norm
    lo = min(x)
    v = [t / lo for t in x] if lo > 0 else x
    return r, v


def collatz_wielandt_bracket(A: Matrix, v: Vector) -> Tuple[float, float]:
    """
    Rigorous bracket on the Perron root from any strictly positive v:
        min_i (Av)_i / v_i  <=  r  <=  max_i (Av)_i / v_i.
    This makes the power iteration self-certifying.
    """
    Av = mat_vec(A, v)
    ratios = [Av[i] / v[i] for i in range(len(v))]
    return min(ratios), max(ratios)


def perron_sandwich(A: Matrix, v: Vector, r: float, n: int) -> Tuple[float, float, float]:
    """
    Return (c * P(n), r^n * sum(v), C * P(n)) where c = min v, C = max v.
    The Perron sandwich asserts the middle term lies between the outer two.
    """
    c, C = min(v), max(v)
    P = path_count(A, n)
    return c * P, (r ** n) * sum(v), C * P


# ----------------------------------------------------------------------------
# Automaton synthesis from a local (sliding-window) pruning rule
# ----------------------------------------------------------------------------

def synthesize_automaton(b: int, window: int,
                         forbidden: Iterable[Sequence[int]]) -> Tuple[Matrix, List[Tuple[int, ...]]]:
    """
    Build the transition matrix of the pruning automaton for a rule of the form
    "the last `window` moves must never form a forbidden block", in a b-ary
    tree with alphabet {0, ..., b-1}.

    States are the legal words of length window-1; A[u][v] = 1 when v is
    obtained from u by appending a symbol and dropping the first, provided the
    resulting length-`window` block is not forbidden.  This is the standard
    sofic-subshift construction; the entropy of the resulting matrix is the
    topological entropy of the subshift.
    """
    forb = {tuple(f) for f in forbidden}

    def legal_word(w: Sequence[int]) -> bool:
        return all(tuple(w[i:i + window]) not in forb
                   for i in range(len(w) - window + 1))

    states: List[Tuple[int, ...]] = []
    def build(prefix: Tuple[int, ...]) -> None:
        if len(prefix) == window - 1:
            if legal_word(prefix):
                states.append(prefix)
            return
        for s in range(b):
            build(prefix + (s,))
    build(())

    index = {s: i for i, s in enumerate(states)}
    k = len(states)
    A: Matrix = [[0.0] * k for _ in range(k)]
    for u in states:
        for s in range(b):
            block = u + (s,)
            if tuple(block) in forb:
                continue
            nxt = block[1:]
            if nxt in index:
                A[index[u]][index[nxt]] += 1.0
    return A, states


# ----------------------------------------------------------------------------
# Demonstration 1: the Fibonacci pruning automaton
# ----------------------------------------------------------------------------

def demo_fibonacci_automaton() -> None:
    print(SEP)
    print("DEMO 1 -- The Fibonacci pruning automaton in the binary search tree")
    print(SEP)
    print("Rule: never use two 'expensive' inference steps in a row.")
    print("Transition matrix A = [[1,1],[1,0]]   (state 1 = last step cheap,")
    print("                                       state 2 = last step expensive)")
    print()
    print(f"{'n':>4} {'P(n)':>14} {'F(n+3)':>14} {'match':>7} {'rate(n)':>10} {'dim(n)':>9}")
    print(SUB)
    log2 = math.log(2.0)
    for n in range(0, 21):
        P = path_count(FIB_MATRIX, n)
        F = fibonacci(n + 3)
        if n == 0:
            print(f"{n:>4} {P:>14.0f} {F:>14d} {'yes' if abs(P-F)<1e-9 else 'NO':>7} "
                  f"{'--':>10} {'--':>9}")
        else:
            rate = math.log(P) / n
            print(f"{n:>4} {P:>14.0f} {F:>14d} {'yes' if abs(P-F)<1e-9 else 'NO':>7} "
                  f"{rate:>10.6f} {rate/log2:>9.6f}")
    print(SUB)
    print(f"Theoretical entropy   h = log(phi)        = {math.log(PHI):.9f}")
    print(f"Theoretical dimension d = log(phi)/log(2) = {math.log(PHI)/log2:.9f}")
    print()
    print("The finite-scale rates decrease monotonically toward log(phi) from above,")
    print("exactly as the infimum characterization of the entropy predicts.")
    print()


# ----------------------------------------------------------------------------
# Demonstration 2: certified entropy bracketing
# ----------------------------------------------------------------------------

def demo_certified_bracketing() -> None:
    print(SEP)
    print("DEMO 2 -- Certified entropy bracketing from finite computations")
    print(SEP)
    print("Every finite prefix count is a PROVED upper bound on the entropy,")
    print("because the Fekete limit equals the infimum of the finite-scale rates.")
    print("The Perron sandwich supplies the matching lower bound, of width O(1/n).")
    print()

    def N(n: int) -> float:
        return path_count(FIB_MATRIX, n)

    v: Vector = [PHI, 1.0]
    c, C = min(v), max(v)
    S = sum(v)
    h_true = math.log(PHI)

    print(f"eigenvector v = (phi, 1),  c = {c:.6f},  C = {C:.6f},  "
          f"spread C/c = {C/c:.6f}")
    print()
    print(f"{'depth M':>8} {'upper bound':>14} {'lower bound':>14} "
          f"{'width':>10} {'contains h?':>12}")
    print(SUB)
    for M in (1, 2, 5, 10, 20, 50, 100, 200):
        upper = entropy_upper_bound(N, M)
        # From P(n) <= (S/c) r^n:  log P(n)/n <= log r + log(S/c)/n, so
        # lower bound  =  rate(M) - log(S/c)/M.
        lower = finite_scale_rate(N, M) - math.log(S / c) / M
        inside = "yes" if lower - 1e-12 <= h_true <= upper + 1e-12 else "NO"
        print(f"{M:>8} {upper:>14.9f} {lower:>14.9f} {upper-lower:>10.2e} {inside:>12}")
    print(SUB)
    print(f"true entropy h = log(phi) = {h_true:.9f}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 3: submultiplicativity and its defect
# ----------------------------------------------------------------------------

def demo_submultiplicativity() -> None:
    print(SEP)
    print("DEMO 3 -- Submultiplicativity of path counts, P(m+n) <= P(m) P(n)")
    print(SEP)
    print("Concatenation only works when the endpoint of the first path matches")
    print("the start of the second; the product pays for ALL pairings, so the")
    print("inequality is typically strict.  The 'defect ratio' measures the slack.")
    print()

    matrices = {
        "Fibonacci  [[1,1],[1,0]]": FIB_MATRIX,
        "Full binary [[2]]": [[2.0]],
        "3-state cycle+chord": [[0.0, 1.0, 1.0],
                                [1.0, 0.0, 1.0],
                                [1.0, 1.0, 0.0]],
        "Reducible  [[2,1],[0,1]]": [[2.0, 1.0], [0.0, 1.0]],
    }
    for name, A in matrices.items():
        def N(n: int, A: Matrix = A) -> float:
            return path_count(A, n)
        ok, worst = check_submultiplicative(N, 8)
        print(f"{name:<28}  holds: {str(ok):<6}  worst ratio "
              f"P(m+n)/(P(m)P(n)) = {worst:.6f}")
    print()
    print("Detailed defect table for the Fibonacci automaton:")
    print("m / n".rjust(5) + "".join(f"{n:>9}" for n in range(0, 7)))
    print(SUB)
    for m in range(0, 7):
        row = f"{m:>5}"
        for n in range(0, 7):
            ratio = path_count(FIB_MATRIX, m + n) / (
                path_count(FIB_MATRIX, m) * path_count(FIB_MATRIX, n))
            row += f"{ratio:>9.4f}"
        print(row)
    print()


# ----------------------------------------------------------------------------
# Demonstration 4: the Perron sandwich
# ----------------------------------------------------------------------------

def demo_perron_sandwich() -> None:
    print(SEP)
    print("DEMO 4 -- The Perron sandwich:  c P(n) <= r^n sum(v) <= C P(n)")
    print(SEP)
    print("A single positive eigenvector pins the path counts to a constant")
    print("multiple of r^n.  No spectral decomposition is used anywhere.")
    print()
    v: Vector = [PHI, 1.0]
    r = PHI
    print(f"{'n':>4} {'c*P(n)':>16} {'r^n*sum(v)':>16} {'C*P(n)':>16} {'valid':>7}")
    print(SUB)
    for n in range(0, 16):
        lo, mid, hi = perron_sandwich(FIB_MATRIX, v, r, n)
        valid = "yes" if lo <= mid * (1 + 1e-9) and mid <= hi * (1 + 1e-9) else "NO"
        print(f"{n:>4} {lo:>16.4f} {mid:>16.4f} {hi:>16.4f} {valid:>7}")
    print(SUB)
    S, c, C = sum(v), min(v), max(v)
    print(f"Equivalently  (S/C) r^n <= P(n) <= (S/c) r^n  with "
          f"S/C = {S/C:.6f}, S/c = {S/c:.6f}.")
    print("The observed ratio P(n)/r^n converges to phi^3/sqrt(5) = "
          f"{PHI**3/math.sqrt(5):.6f}, which indeed lies in that window.")
    print()
    print(f"{'n':>4} {'P(n)/r^n':>14}")
    print(SUB)
    for n in (1, 2, 5, 10, 20, 40, 80):
        print(f"{n:>4} {path_count(FIB_MATRIX, n)/(r**n):>14.9f}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 5: the Perron domination inequality
# ----------------------------------------------------------------------------

def demo_perron_domination() -> None:
    print(SEP)
    print("DEMO 5 -- Perron domination:  r^n <= sum_{i,j} (A^n)_{ij}, for EVERY n")
    print(SEP)
    print("A finite inequality with no asymptotics, obtained from an asymptotic")
    print("theorem -- because the Fekete limit is an infimum, it is simultaneously")
    print("a uniform lower bound on every finite-scale rate.")
    print()
    print("Specialized to the Fibonacci automaton:  phi^n <= F(n+3).")
    print()
    print(f"{'n':>4} {'phi^n':>22} {'F(n+3)':>22} {'ratio':>10} {'holds':>7}")
    print(SUB)
    for n in (0, 1, 2, 3, 5, 10, 15, 20, 30, 40, 60):
        lhs = PHI ** n
        rhs = float(fibonacci(n + 3))
        print(f"{n:>4} {lhs:>22.4f} {rhs:>22.4f} {rhs/lhs:>10.6f} "
              f"{'yes' if lhs <= rhs else 'NO':>7}")
    print(SUB)
    print(f"ratio F(n+3)/phi^n -> phi^3/sqrt(5) = {PHI**3/math.sqrt(5):.9f}")
    print()
    print("The same inequality for other Perron-controlled matrices:")
    print()
    tests = {
        "[[1,1],[1,0]]": FIB_MATRIX,
        "[[1,1,0],[0,1,1],[1,0,1]]": [[1.0, 1.0, 0.0], [0.0, 1.0, 1.0], [1.0, 0.0, 1.0]],
        "[[0,1],[2,1]]": [[0.0, 1.0], [2.0, 1.0]],
    }
    for name, A in tests.items():
        r, v = perron_root_power_iteration(A)
        ok = all(r ** n <= path_count(A, n) * (1 + 1e-9) for n in range(0, 25))
        print(f"  {name:<32} r = {r:.9f}   r^n <= P(n) for n<=24: {ok}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 6: dimension of the pruning, and what it buys you
# ----------------------------------------------------------------------------

def demo_dimension_savings() -> None:
    print(SEP)
    print("DEMO 6 -- What a dimension of 0.6942 actually buys")
    print(SEP)
    log2 = math.log(2.0)
    d = math.log(PHI) / log2
    print(f"proof-search dimension of the Fibonacci-pruned binary tree: {d:.6f}")
    print()
    print("Pruning does not make an exponential problem polynomial.  It lowers the")
    print("BASE of the exponential, and the dimension records by exactly how much:")
    print("the surviving fraction of the tree decays like 2^(-n(1-d)).")
    print()
    print(f"{'depth n':>8} {'2^n (unpruned)':>20} {'F(n+3) (pruned)':>20} "
          f"{'savings factor':>18}")
    print(SUB)
    for n in (10, 20, 40, 60, 80, 100, 200):
        unpruned = 2.0 ** n
        pruned = float(fibonacci(n + 3))
        print(f"{n:>8} {unpruned:>20.4e} {pruned:>20.4e} {unpruned/pruned:>18.4e}")
    print(SUB)
    print(f"predicted savings factor ~ 2^(n(1-d)) = 2^({1-d:.6f} n)")
    print(f"e.g. at n = 100:  2^{(1-d)*100:.4f} = {2.0**((1-d)*100):.4e}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 7: the whole dimension spectrum from synthesized automata
# ----------------------------------------------------------------------------

def demo_dimension_spectrum() -> None:
    print(SEP)
    print("DEMO 7 -- A spectrum of proof-search dimensions from local pruning rules")
    print(SEP)
    print("Each rule forbids certain length-w blocks of moves in a b-ary tree.")
    print("The automaton is synthesized automatically; its Perron root r gives")
    print("the dimension log r / log b.")
    print()
    rules = [
        ("binary, no rule at all", 2, 1, []),
        ("binary, forbid '11'", 2, 2, [(1, 1)]),
        ("binary, forbid '111'", 2, 3, [(1, 1, 1)]),
        ("binary, forbid '11' and '00'", 2, 2, [(1, 1), (0, 0)]),
        ("ternary, forbid '22'", 3, 2, [(2, 2)]),
        ("ternary, forbid '12' and '21'", 3, 2, [(1, 2), (2, 1)]),
        ("ternary, forbid all doubles", 3, 2, [(0, 0), (1, 1), (2, 2)]),
        ("4-ary, forbid '33' and '32'", 4, 2, [(3, 3), (3, 2)]),
    ]
    print(f"{'rule':<32} {'states':>7} {'r':>12} {'log r':>11} {'dimension':>11}")
    print(SUB)
    for name, b, w, forb in rules:
        A, states = synthesize_automaton(b, w, forb)
        if not states or all(all(x == 0 for x in row) for row in A):
            print(f"{name:<32} {'--':>7} {'degenerate':>12}")
            continue
        r, v = perron_root_power_iteration(A, iters=3000)
        lo, hi = collatz_wielandt_bracket(A, v)
        dim = math.log(r) / math.log(b) if r > 0 else 0.0
        print(f"{name:<32} {len(states):>7} {r:>12.8f} {math.log(r):>11.7f} "
              f"{dim:>11.8f}")
    print(SUB)
    print("Notes:")
    print(f"  'binary, forbid 11'  reproduces the golden ratio r = phi = {PHI:.8f}")
    print("     and the dimension log(phi)/log(2) = "
          f"{math.log(PHI)/math.log(2):.8f}.")
    print("  'binary, forbid 111' gives the tribonacci constant 1.83928675..., the")
    print("     real root of x^3 = x^2 + x + 1.")
    print("  'binary, forbid 11 and 00' leaves only the two alternating paths:")
    print("     r = 1, dimension 0 -- pruning has become deterministic.")
    print()


# ----------------------------------------------------------------------------
# Demonstration 8: the scalar case and the classical similarity dimension
# ----------------------------------------------------------------------------

def demo_similarity_dimension() -> None:
    print(SEP)
    print("DEMO 8 -- The scalar case recovers the classical similarity dimension")
    print(SEP)
    print("A 1x1 matrix [[s]] models a uniformly self-similar search keeping s of")
    print("the b branches at each level.  Then P(n) = s^n and dim = log s / log b.")
    print()
    print(f"{'s':>4} {'b':>4} {'P(5)':>10} {'dimension':>12}  interpretation")
    print(SUB)
    cases = [
        (2.0, 3.0, "middle-thirds Cantor set"),
        (2.0, 2.0, "no pruning at all: dimension 1"),
        (1.0, 2.0, "a single live path: dimension 0"),
        (3.0, 4.0, "keep 3 of 4 branches"),
        (2.0, 5.0, "aggressive pruning"),
        (PHI, 2.0, "matches the Fibonacci automaton exactly"),
    ]
    for s, b, note in cases:
        A: Matrix = [[s]]
        P5 = path_count(A, 5)
        dim = math.log(s) / math.log(b)
        print(f"{s:>4.2f} {b:>4.1f} {P5:>10.4f} {dim:>12.8f}  {note}")
    print(SUB)
    print("Verification that P(n) = s^n exactly, for s = 2.5:")
    for n in range(0, 7):
        print(f"   n = {n}:  P(n) = {path_count([[2.5]], n):.6f}   "
              f"s^n = {2.5**n:.6f}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 9: self-certifying Perron root computation
# ----------------------------------------------------------------------------

def demo_power_iteration() -> None:
    print(SEP)
    print("DEMO 9 -- Self-certifying Perron root via scaled power iteration")
    print(SEP)
    print("Power iteration returns (r, v); the Collatz-Wielandt inequalities")
    print("   min_i (Av)_i/v_i  <=  r  <=  max_i (Av)_i/v_i")
    print("then certify the answer from the computed eigenvector alone.")
    print()
    examples = {
        "Fibonacci [[1,1],[1,0]]": FIB_MATRIX,
        "[[2,1],[1,2]]": [[2.0, 1.0], [1.0, 2.0]],
        "[[0,1,1],[1,0,1],[1,1,0]]": [[0.0, 1.0, 1.0], [1.0, 0.0, 1.0], [1.0, 1.0, 0.0]],
        "[[1,2,0],[0,1,3],[1,0,1]]": [[1.0, 2.0, 0.0], [0.0, 1.0, 3.0], [1.0, 0.0, 1.0]],
    }
    print(f"{'matrix':<28} {'r (iterated)':>15} {'CW lower':>13} {'CW upper':>13} "
          f"{'spread C/c':>12}")
    print(SUB)
    for name, A in examples.items():
        r, v = perron_root_power_iteration(A, iters=5000)
        lo, hi = collatz_wielandt_bracket(A, v)
        print(f"{name:<28} {r:>15.10f} {lo:>13.10f} {hi:>13.10f} "
              f"{max(v)/min(v):>12.6f}")
    print(SUB)
    print(f"For the Fibonacci matrix the exact answer is phi = {PHI:.10f};")
    print("the certified bracket contains it.")
    print()
    print("Convergence of the iterate for the Fibonacci matrix:")
    A = FIB_MATRIX
    x: Vector = [0.5, 0.5]
    print(f"{'iter':>5} {'estimate of r':>18} {'error':>14}")
    print(SUB)
    for it in range(1, 26):
        y = mat_vec(A, x)
        nrm = sum(y)
        x = [t / nrm for t in y]
        if it % 3 == 0 or it <= 3:
            print(f"{it:>5} {nrm:>18.12f} {abs(nrm-PHI):>14.3e}")
    print()


# ----------------------------------------------------------------------------
# Demonstration 10: dimension is blind to traversal policy
# ----------------------------------------------------------------------------

def demo_policy_vs_geometry() -> None:
    print(SEP)
    print("DEMO 10 -- Dimension measures abundance, not search cost")
    print(SEP)
    print("Two search trees with IDENTICAL level counts N(n) -- hence identical")
    print("dimension -- can have wildly different depth-first discovery costs.")
    print("The counting function sees geometry; cost = geometry x policy.")
    print()

    depth = 14

    def live_words(depth: int) -> List[Tuple[int, ...]]:
        """All binary words of length `depth` with no two consecutive 1s."""
        out: List[Tuple[int, ...]] = []
        def rec(w: Tuple[int, ...]) -> None:
            if len(w) == depth:
                out.append(w)
                return
            for s in (0, 1):
                if s == 1 and w and w[-1] == 1:
                    continue
                rec(w + (s,))
        rec(())
        return out

    words = live_words(depth)
    print(f"live words of length {depth}: {len(words)}  "
          f"(= F({depth}+2) = {fibonacci(depth+2)})")

    # Policy A: the goal is the lexicographically first live word.
    # Policy B: the goal is the lexicographically last live word.
    # Both trees have exactly the same profile N(n); only the goal location moves.
    target_first = words[0]
    target_last = words[-1]

    def dfs_cost(target: Tuple[int, ...]) -> int:
        """Number of leaves inspected by lexicographic DFS before hitting target."""
        return words.index(target) + 1

    print(f"depth-first cost when the proof sits first  : {dfs_cost(target_first):>8}")
    print(f"depth-first cost when the proof sits last   : {dfs_cost(target_last):>8}")
    print(f"ratio                                       : "
          f"{dfs_cost(target_last)/dfs_cost(target_first):>8.1f}x")
    print()
    print("Both instances have entropy log(phi) and dimension "
          f"{math.log(PHI)/math.log(2):.6f}.")
    print("The dimension is exactly the part of the difficulty that no clever")
    print("reordering of the search can remove.")
    print()


# ----------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 78)
    print("#  SUBMULTIPLICATIVE SEARCH ENTROPY AND THE PERRON ROOT".ljust(77) + "#")
    print("#  Numerical demonstrations of the proof-search dimension".ljust(77) + "#")
    print("#" * 78)
    print()
    demo_fibonacci_automaton()
    demo_certified_bracketing()
    demo_submultiplicativity()
    demo_perron_sandwich()
    demo_perron_domination()
    demo_dimension_savings()
    demo_dimension_spectrum()
    demo_similarity_dimension()
    demo_power_iteration()
    demo_policy_vs_geometry()
    print(SEP)
    print("All demonstrations complete.")
    print(SEP)


if __name__ == "__main__":
    main()
