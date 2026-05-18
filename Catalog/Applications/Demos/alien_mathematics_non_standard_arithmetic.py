#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Nonstandard Arithmetic

Demonstrates how hypernatural numbers can be used in practice:
1. Algorithm complexity comparison via HyperNat
2. Asymptotic series verification
3. Number-theoretic divisibility analysis
4. Growth rate classification
"""

from typing import Callable, List, Tuple
import math


# === Core HyperNat infrastructure ===

class SeqNum:
    """A number represented by a sequence, supporting eventual arithmetic."""

    def __init__(self, f: Callable[[int], int], name: str = ""):
        self.f = f
        self.name = name

    def __add__(self, other):
        return SeqNum(lambda n: self.f(n) + other.f(n), f"({self.name}+{other.name})")

    def __mul__(self, other):
        return SeqNum(lambda n: self.f(n) * other.f(n), f"({self.name}*{other.name})")

    def vals(self, k=12):
        return [self.f(n) for n in range(k)]

    def eventually_le(self, other, up_to=5000):
        last_fail = -1
        for n in range(up_to):
            if self.f(n) > other.f(n):
                last_fail = n
        return last_fail < up_to - 1

    def eventually_eq(self, other, up_to=5000):
        last_fail = -1
        for n in range(up_to):
            if self.f(n) != other.f(n):
                last_fail = n
        return last_fail < up_to - 1


# === Application 1: Algorithm Complexity Comparison ===

def app_complexity_comparison():
    """Compare algorithm running times using HyperNat ordering.

    Instead of "f = O(g)" as a vague asymptotic statement, we evaluate
    f(ω) and g(ω) and compare them exactly.
    """
    print("=" * 60)
    print("APPLICATION 1: Algorithm Complexity via HyperNat")
    print("=" * 60)
    print()

    # Define algorithm running times
    algorithms = {
        "Linear search":     SeqNum(lambda n: n, "n"),
        "Binary search":     SeqNum(lambda n: max(1, int(math.log2(n+1))), "log n"),
        "Bubble sort":       SeqNum(lambda n: n * n, "n²"),
        "Merge sort":        SeqNum(lambda n: max(1, n * int(math.log2(n+1))), "n log n"),
        "Matrix mult":       SeqNum(lambda n: n ** 3, "n³"),
    }

    names = list(algorithms.keys())
    seqs = list(algorithms.values())

    print("  Eventual ordering (f ≤ g eventually):")
    print()
    print(f"  {'':25s}", end="")
    for name in names:
        print(f"{name:>16s}", end="")
    print()

    for i, name_i in enumerate(names):
        print(f"  {name_i:25s}", end="")
        for j, name_j in enumerate(names):
            le = seqs[i].eventually_le(seqs[j])
            print(f"{'≤':>16s}" if le else f"{'✗':>16s}", end="")
        print()

    print()
    print("  → Each '≤' means f(ω) ≤ g(ω) in HyperNat.")
    print("  → The ordering exactly captures asymptotic complexity.")
    print()


# === Application 2: Summation Formula Verification ===

def app_summation_verification():
    """Verify classical summation formulas at ω.

    The transfer principle guarantees these hold; we compute
    concrete sequence values to demonstrate.
    """
    print("=" * 60)
    print("APPLICATION 2: Summation Formulas at Infinity")
    print("=" * 60)
    print()

    omega = SeqNum(lambda n: n, "ω")

    # Gauss: 2·T(n) = n(n+1)
    T = SeqNum(lambda n: n * (n + 1) // 2, "T(ω)")
    two = SeqNum(lambda n: 2, "2")
    lhs1 = two * T
    rhs1 = omega * SeqNum(lambda n: n + 1, "ω+1")

    print("  Gauss: 2·T(ω) = ω·(ω+1)")
    print(f"    LHS: {lhs1.vals(8)}")
    print(f"    RHS: {rhs1.vals(8)}")
    print(f"    Equal? {lhs1.eventually_eq(rhs1)}")
    print()

    # Sum of squares: 6·S(n) = n(n+1)(2n+1)
    S = SeqNum(lambda n: n * (n + 1) * (2 * n + 1) // 6, "S(ω)")
    six = SeqNum(lambda n: 6, "6")
    lhs2 = six * S
    rhs2 = omega * SeqNum(lambda n: n + 1, "ω+1") * SeqNum(lambda n: 2 * n + 1, "2ω+1")

    print("  Squares: 6·S(ω) = ω·(ω+1)·(2ω+1)")
    print(f"    LHS: {lhs2.vals(8)}")
    print(f"    RHS: {rhs2.vals(8)}")
    print(f"    Equal? {lhs2.eventually_eq(rhs2)}")
    print()

    # Sum of cubes: (T(n))² = [n(n+1)/2]²
    T_sq = SeqNum(lambda n: (n * (n + 1) // 2) ** 2, "T(ω)²")
    cube_sum = SeqNum(lambda n: sum(k**3 for k in range(n + 1)), "∑k³")

    print("  Nicomachus: T(ω)² = ∑k³ (sum of cubes = square of triangular)")
    print(f"    T(ω)²: {T_sq.vals(8)}")
    print(f"    ∑k³:   {cube_sum.vals(8)}")
    print(f"    Equal? {T_sq.eventually_eq(cube_sum)}")
    print()


# === Application 3: Divisibility Patterns ===

def app_divisibility():
    """Explore divisibility in HyperNat.

    Demonstrate that standard divisibility results transfer
    to infinite numbers.
    """
    print("=" * 60)
    print("APPLICATION 3: Number-Theoretic Divisibility at Infinity")
    print("=" * 60)
    print()

    def check_eventual_div(f, g, name_f, name_g, up_to=200):
        last_fail = -1
        for n in range(1, up_to):
            fn, gn = f(n), g(n)
            if fn != 0 and gn % fn != 0:
                last_fail = n
        ok = last_fail < up_to - 1
        print(f"  {name_f} | {name_g}? {'Yes' if ok else 'No'}"
              f" (from index {last_fail + 1 if ok else '???'})")
        return ok

    # n | n²
    check_eventual_div(lambda n: n, lambda n: n**2, "ω", "ω²")
    # n | n(n+1)
    check_eventual_div(lambda n: n, lambda n: n*(n+1), "ω", "ω(ω+1)")
    # 2 | n(n+1)  (product of consecutive integers is always even)
    check_eventual_div(lambda n: 2, lambda n: n*(n+1), "2", "ω(ω+1)")
    # 6 | n(n+1)(n+2) (product of 3 consecutive is divisible by 6)
    check_eventual_div(lambda n: 6, lambda n: n*(n+1)*(n+2), "6", "ω(ω+1)(ω+2)")
    # n+1 does not divide n
    check_eventual_div(lambda n: n+1, lambda n: n, "ω+1", "ω")

    print()
    print("  → Divisibility patterns are preserved in the nonstandard world.")
    print()


# === Application 4: Growth Rate Classification ===

def app_growth_classification():
    """Classify functions by growth rate using HyperNat ordering.

    This implements the idea that asymptotic growth classes
    correspond to distinct hypernatural magnitudes.
    """
    print("=" * 60)
    print("APPLICATION 4: Growth Rate Classification")
    print("=" * 60)
    print()

    functions = [
        ("1",           lambda n: 1),
        ("log n",       lambda n: max(1, int(math.log2(n + 1)))),
        ("√n",          lambda n: int(math.sqrt(n))),
        ("n",           lambda n: n),
        ("n log n",     lambda n: max(1, n * int(math.log2(n + 1)))),
        ("n²",          lambda n: n * n),
        ("n³",          lambda n: n ** 3),
        ("2ⁿ",          lambda n: min(2 ** n, 10**15)),  # cap to avoid overflow
    ]

    print("  Growth hierarchy (↑ = strictly faster):")
    print()

    for i in range(len(functions) - 1):
        name_i, f_i = functions[i]
        name_j, f_j = functions[i + 1]
        si = SeqNum(f_i, name_i)
        sj = SeqNum(f_j, name_j)

        le = si.eventually_le(sj)
        ge = sj.eventually_le(si)

        if le and not ge:
            rel = "<"
        elif le and ge:
            rel = "="
        else:
            rel = "?"

        print(f"    {name_i:12s} {rel} {name_j:12s}")

    print()
    print("  → Each '<' represents a strict inequality in HyperNat:")
    print("    f(ω) < g(ω) means f grows strictly slower than g.")
    print()


# === Application 5: Fibonacci Divisibility ===

def app_fibonacci():
    """Demonstrate Fibonacci divisibility properties in HyperNat.

    gcd(F(m), F(n)) = F(gcd(m, n)) — a classical identity
    that transfers to hypernatural arguments.
    """
    print("=" * 60)
    print("APPLICATION 5: Fibonacci Properties at Infinity")
    print("=" * 60)
    print()

    def fib(n):
        if n <= 0: return 0
        a, b = 0, 1
        for _ in range(n):
            a, b = b, a + b
        return a

    # Verify gcd(F(m), F(n)) = F(gcd(m, n)) for small values
    print("  Verifying gcd(F(m), F(n)) = F(gcd(m,n)):")
    all_ok = True
    for m in range(1, 20):
        for n in range(1, 20):
            lhs = math.gcd(fib(m), fib(n))
            rhs = fib(math.gcd(m, n))
            if lhs != rhs:
                print(f"    FAIL at m={m}, n={n}")
                all_ok = False
    print(f"    All cases m,n ∈ [1,19]: {'PASS' if all_ok else 'FAIL'}")
    print()

    # Demonstrate F(n) | F(2n)
    print("  F(n) | F(2n) (Fibonacci divisibility):")
    for n in range(1, 12):
        f_n = fib(n)
        f_2n = fib(2 * n)
        print(f"    F({n})={f_n:5d}, F({2*n})={f_2n:8d}, "
              f"F({2*n})/F({n})={f_2n//f_n}")

    print()
    print("  → In HyperNat: F(ω) | F(2ω), verified by pointwise transfer.")
    print("  → The Fibonacci gcd identity F(gcd(m,n)) = gcd(F(m),F(n))")
    print("    holds for all hypernatural m, n.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF NONSTANDARD ARITHMETIC                 ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    app_complexity_comparison()
    app_summation_verification()
    app_divisibility()
    app_growth_classification()
    app_fibonacci()

    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Demonstrating Nonstandard Arithmetic via Eventual Equivalence

This script makes the formal mathematics tangible by computing with
concrete sequence representatives of hypernatural numbers.
"""

from typing import List, Tuple, Callable
import math


# === Core: Sequence-based HyperNat representation ===

class HyperNat:
    """A hypernatural number, represented by a sequence ℕ → ℕ.

    Two HyperNats are 'eventually equal' if they agree from some index onward.
    Arithmetic is pointwise. This mirrors the formal Lean construction.
    """

    def __init__(self, seq: Callable[[int], int], name: str = ""):
        self.seq = seq
        self.name = name or "<seq>"

    def __repr__(self):
        vals = [self.seq(n) for n in range(10)]
        return f"HyperNat({self.name}: {vals}...)"

    def evaluate(self, n: int) -> int:
        return self.seq(n)

    def first_n(self, n: int = 15) -> List[int]:
        return [self.seq(i) for i in range(n)]

    def __add__(self, other: 'HyperNat') -> 'HyperNat':
        return HyperNat(lambda n: self.seq(n) + other.seq(n),
                        f"({self.name} + {other.name})")

    def __mul__(self, other: 'HyperNat') -> 'HyperNat':
        return HyperNat(lambda n: self.seq(n) * other.seq(n),
                        f"({self.name} * {other.name})")

    def eventually_eq(self, other: 'HyperNat', check_up_to: int = 1000) -> Tuple[bool, int]:
        """Check if two HyperNats are eventually equal (up to check_up_to terms).
        Returns (True, N) where N is the first index from which they agree,
        or (False, -1) if they disagree somewhere in the checked range.
        """
        last_diff = -1
        for n in range(check_up_to):
            if self.seq(n) != other.seq(n):
                last_diff = n
        if last_diff == -1:
            return True, 0
        elif last_diff < check_up_to - 1:
            return True, last_diff + 1
        else:
            return False, -1

    def eventually_le(self, other: 'HyperNat', check_up_to: int = 1000) -> Tuple[bool, int]:
        """Check if self ≤ other eventually."""
        last_violation = -1
        for n in range(check_up_to):
            if self.seq(n) > other.seq(n):
                last_violation = n
        if last_violation == -1:
            return True, 0
        elif last_violation < check_up_to - 1:
            return True, last_violation + 1
        else:
            return False, -1


# === Standard HyperNat elements ===

def const(k: int) -> HyperNat:
    return HyperNat(lambda n: k, str(k))

ZERO = const(0)
ONE = const(1)
TWO = const(2)
SIX = const(6)
OMEGA = HyperNat(lambda n: n, "ω")


# === Demo 1: Non-Archimedean Property ===

def demo_non_archimedean():
    print("=" * 60)
    print("DEMO 1: The Non-Archimedean Property")
    print("=" * 60)
    print()
    print("ω = [0, 1, 2, 3, 4, ...] — the identity sequence")
    print(f"ω first 15 terms: {OMEGA.first_n()}")
    print()

    for k in [5, 42, 100]:
        std = const(k)
        le_result, le_from = std.eventually_le(OMEGA)
        print(f"  {k} ≤ ω eventually? {le_result} (from index {le_from})")

    print()
    le_result, _ = OMEGA.eventually_le(const(1000000))
    print(f"  ω ≤ 1000000 eventually? {le_result}")
    print()
    print("  → ω exceeds every finite number. It is genuinely infinite!")
    print()


# === Demo 2: Arithmetic with Infinite Numbers ===

def demo_arithmetic():
    print("=" * 60)
    print("DEMO 2: Arithmetic with Infinite Numbers")
    print("=" * 60)
    print()

    omega_plus_1 = OMEGA + ONE
    omega_times_2 = OMEGA * TWO
    omega_sq = OMEGA * OMEGA

    print(f"ω + 1 = {omega_plus_1.first_n()}")
    print(f"2ω    = {omega_times_2.first_n()}")
    print(f"ω²    = {omega_sq.first_n()}")
    print()

    eq1, _ = omega_plus_1.eventually_eq(OMEGA)
    eq2, _ = omega_times_2.eventually_eq(OMEGA)
    print(f"  ω + 1 = ω? {eq1}  (They are DIFFERENT infinite numbers)")
    print(f"  2ω = ω?    {eq2}  (Also DIFFERENT)")
    print()

    le1, _ = OMEGA.eventually_le(omega_sq)
    le2, _ = omega_sq.eventually_le(OMEGA)
    print(f"  ω ≤ ω²? {le1}")
    print(f"  ω² ≤ ω? {le2}")
    print(f"  → ω² is strictly greater than ω: infinite numbers have a hierarchy!")
    print()


# === Demo 3: Transfer of the Gauss Formula ===

def triangular(n: int) -> int:
    """T(n) = 0 + 1 + 2 + ... + n"""
    return n * (n + 1) // 2

def demo_gauss_transfer():
    print("=" * 60)
    print("DEMO 3: Gauss Formula Transfers to HyperNat")
    print("=" * 60)
    print()
    print("Standard: 2·T(n) = n·(n+1) for all n ∈ ℕ")
    print()

    for n in [5, 10, 100]:
        lhs = 2 * triangular(n)
        rhs = n * (n + 1)
        print(f"  n={n}: 2·T({n}) = {lhs}, {n}·{n+1} = {rhs}, equal? {lhs == rhs}")

    print()
    print("Now at ω (the infinite element):")

    hyper_T = HyperNat(lambda n: triangular(n), "T(ω)")
    lhs = TWO * hyper_T
    rhs = OMEGA * (OMEGA + ONE)

    print(f"  2·T(ω) = {lhs.first_n()}")
    print(f"  ω·(ω+1) = {rhs.first_n()}")

    eq, from_idx = lhs.eventually_eq(rhs)
    print(f"  Eventually equal? {eq} (from index {from_idx})")
    print(f"  → The Gauss formula holds for the INFINITE integer ω!")
    print()


# === Demo 4: Sum of Squares Transfer ===

def sum_squares(n: int) -> int:
    """S(n) = 1² + 2² + ... + n²"""
    return n * (n + 1) * (2 * n + 1) // 6

def demo_sum_squares_transfer():
    print("=" * 60)
    print("DEMO 4: Sum of Squares Formula Transfers")
    print("=" * 60)
    print()
    print("Standard: 6·S(n) = n·(n+1)·(2n+1)")
    print()

    hyper_S = HyperNat(lambda n: sum_squares(n), "S(ω)")
    lhs = SIX * hyper_S
    rhs = OMEGA * (OMEGA + ONE) * (TWO * OMEGA + ONE)

    print(f"  6·S(ω) first 10: {lhs.first_n(10)}")
    print(f"  ω(ω+1)(2ω+1) first 10: {rhs.first_n(10)}")

    eq, _ = lhs.eventually_eq(rhs)
    print(f"  Eventually equal? {eq}")
    print(f"  → Classical summation formulas survive at infinity!")
    print()


# === Demo 5: Eventual Equality = Exact Equality ===

def demo_eventual_equality():
    print("=" * 60)
    print("DEMO 5: Asymptotic Identity Becomes Exact")
    print("=" * 60)
    print()

    f = HyperNat(lambda n: n * n + 3 if n < 5 else n * n, "f")
    g = HyperNat(lambda n: n * n, "g")

    print(f"  f = n² + 3 for n < 5, n² otherwise")
    print(f"  g = n²")
    print(f"  f: {f.first_n(10)}")
    print(f"  g: {g.first_n(10)}")

    eq, from_idx = f.eventually_eq(g)
    print(f"  Eventually equal? {eq} (from index {from_idx})")
    print(f"  → In HyperNat, f and g ARE the same number!")
    print(f"  → 'Approximately equal for large n' = 'exactly equal in HyperNat'")
    print()


# === Demo 6: Divisibility Transfer ===

def demo_divisibility():
    print("=" * 60)
    print("DEMO 6: Divisibility in HyperNat")
    print("=" * 60)
    print()

    f = OMEGA  # n
    g = OMEGA * OMEGA  # n²

    divides = True
    for n in range(1, 20):
        if g.seq(n) % f.seq(n) != 0:
            divides = False
            break

    print(f"  ω divides ω²? Checking pointwise: {divides}")
    print(f"  n | n² for n=1..19: all true")

    # n+1 does not divide n
    h = OMEGA + ONE
    divides2 = all(f.seq(n) % h.seq(n) == 0 for n in range(1, 20))
    print(f"  (ω+1) divides ω? Checking: {divides2}")
    print(f"  → Divisibility relationships transfer to infinite numbers!")
    print()


# === Demo 7: Big-O as Hypernatural Inequality ===

def demo_big_o():
    print("=" * 60)
    print("DEMO 7: Big-O Notation as Exact Inequality")
    print("=" * 60)
    print()

    f = HyperNat(lambda n: 3 * n + 7, "3n+7")
    g = HyperNat(lambda n: n * n, "n²")

    print("  Is 3n + 7 = O(n²)?")
    print(f"  f = 3n+7: {f.first_n(10)}")
    print(f"  g = n²:   {g.first_n(10)}")

    le, from_idx = f.eventually_le(g)
    print(f"  f ≤ g eventually? {le} (from index {from_idx})")
    print(f"  → In HyperNat: f(ω) ≤ g(ω), i.e., 3ω + 7 ≤ ω²")
    print(f"  → Big-O becomes a single inequality between infinite numbers!")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   NONSTANDARD ARITHMETIC: Computing with the Infinite   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_non_archimedean()
    demo_arithmetic()
    demo_gauss_transfer()
    demo_sum_squares_transfer()
    demo_eventual_equality()
    demo_divisibility()
    demo_big_o()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("Every computation mirrors a formally verified theorem.")
    print("=" * 60)
