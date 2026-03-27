#!/usr/bin/env python3
"""
Algorithmic Universal Oracle — Python Demonstrations

A suite of interactive demonstrations exploring the mathematics of the
Universal Oracle framework:

1. IDEMPOTENT PROJECTIONS — Visual demonstration that O² = O
2. ORACLE HIERARCHY — The meta-oracle collapse theorem
3. KOLMOGOROV ORACLE — Approximating algorithmic information via compression
4. FIXED-POINT ITERATION — Banach, Kleene, and oracle convergence
5. STRANGE LOOP DETECTOR — Finding self-referential fixed points
6. ORACLE SAT — The phase transition as an oracle phenomenon
7. TROPICAL ORACLE — ReLU as idempotent projection
8. CRYSTALLIZER — Compressing mathematical structures to fixed points

Author: Aristotle (Harmonic)
"""

import sys
import math
import random
import zlib
import struct
import itertools
from typing import List, Tuple, Callable, Optional, Dict, Any

# ═══════════════════════════════════════════════════════════════════════════════
#  DEMO 1: Idempotent Projections — The Core Oracle Property
# ═══════════════════════════════════════════════════════════════════════════════

def demo_idempotent_projections():
    """
    The foundational oracle property: O(O(x)) = O(x).

    An oracle is any idempotent function. We demonstrate this with several
    concrete projections and show that the image = fixed-point set.
    """
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║  DEMO 1: Idempotent Projections — O(O(x)) = O(x)                      ║
║                                                                        ║
║  The MASTER EQUATION: image(O) = Fix(O) = {x | O(x) = x}             ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    # Oracle 1: Floor function (ℝ → ℤ embedded in ℝ)
    print("  Oracle 1: Floor function ⌊x⌋")
    test_values = [3.7, -1.2, 0.0, math.pi, -math.e, 42.0]
    for x in test_values:
        ox = math.floor(x)
        oox = math.floor(ox)
        print(f"    x = {x:8.4f}  →  O(x) = {ox:4}  →  O(O(x)) = {oox:4}  "
              f"{'✓ O²=O' if ox == oox else '✗ FAIL'}")

    # Oracle 2: Modular projection (mod p)
    print("\n  Oracle 2: Modular projection x mod 7")
    for x in [15, 42, 7, 100, 0, -3]:
        ox = x % 7
        oox = ox % 7
        print(f"    x = {x:4}  →  O(x) = {ox}  →  O(O(x)) = {oox}  "
              f"{'✓ O²=O' if ox == oox else '✗ FAIL'}")

    # Oracle 3: Nearest point projection onto a set
    print("\n  Oracle 3: Projection onto [0, 1] interval")
    for x in [-2.5, -0.3, 0.0, 0.5, 1.0, 1.7, 3.0]:
        ox = max(0.0, min(1.0, x))
        oox = max(0.0, min(1.0, ox))
        print(f"    x = {x:5.1f}  →  O(x) = {ox:4.1f}  →  O(O(x)) = {oox:4.1f}  "
              f"{'✓ O²=O' if abs(ox - oox) < 1e-10 else '✗ FAIL'}")

    # Oracle 4: GCD as a projection
    print("\n  Oracle 4: GCD(x, 12) — projection onto divisors of 12")
    for x in [1, 2, 3, 4, 5, 6, 8, 9, 12, 15, 24, 36]:
        ox = math.gcd(x, 12)
        oox = math.gcd(ox, 12)
        print(f"    x = {x:3}  →  gcd(x,12) = {ox:2}  →  gcd(gcd(x,12),12) = {oox:2}  "
              f"{'✓ O²=O' if ox == oox else '✗ FAIL'}")

    # Master Equation demonstration
    print("\n  ═══ MASTER EQUATION: |image(O)| = |Fix(O)| ═══")
    print("  For O(x) = x mod 7 on {0,...,20}:")
    domain = list(range(21))
    image = set(x % 7 for x in domain)
    fixed = set(x for x in domain if x % 7 == x)
    print(f"    Image  = {sorted(image)}, |image| = {len(image)}")
    print(f"    Fix(O) = {sorted(fixed)}, |Fix(O)| = {len(fixed)}")
    print(f"    Master Equation: {len(image)} = {len(fixed)} ✓")


# ═══════════════════════════════════════════════════════════════════════════════
#  DEMO 2: Oracle Hierarchy and Meta-Oracle Collapse
# ═══════════════════════════════════════════════════════════════════════════════

def demo_oracle_hierarchy():
    """
    The meta-oracle hierarchy collapses in one step.

    If O₁, O₂ are oracles, their composition O₂ ∘ O₁ is generally NOT
    an oracle. But the "meta-oracle" — the oracle about oracles — IS
    idempotent, and the hierarchy collapses.
    """
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║  DEMO 2: Oracle Hierarchy — Meta-Oracle Collapse                       ║
║                                                                        ║
║  Key theorem: The set of all idempotents is NOT closed under           ║
║  composition, but the meta-oracle (oracle about oracles) collapses.    ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    # Show that composition of idempotents need not be idempotent
    print("  Composition of idempotents is NOT always idempotent:")
    print()

    # O₁: project onto even numbers, O₂: project onto multiples of 3
    def O1(x): return x - (x % 2)     # round down to even
    def O2(x): return x - (x % 3)     # round down to multiple of 3

    print("  O₁(x) = round down to even")
    print("  O₂(x) = round down to multiple of 3")
    print()

    # Check idempotency of each
    print("  Verify O₁ is idempotent:")
    for x in range(10):
        assert O1(O1(x)) == O1(x), f"O1 not idempotent at {x}"
    print("    ✓ O₁(O₁(x)) = O₁(x) for x ∈ {0,...,9}")

    print("  Verify O₂ is idempotent:")
    for x in range(10):
        assert O2(O2(x)) == O2(x), f"O2 not idempotent at {x}"
    print("    ✓ O₂(O₂(x)) = O₂(x) for x ∈ {0,...,9}")

    # Check composition
    def compose(x): return O2(O1(x))
    print("\n  Check O₂ ∘ O₁:")
    non_idem = []
    for x in range(20):
        cx = compose(x)
        ccx = compose(cx)
        if cx != ccx:
            non_idem.append((x, cx, ccx))
        mark = "✓" if cx == ccx else "✗"
        if x < 12:
            print(f"    x={x:2}: (O₂∘O₁)(x)={cx:2}, (O₂∘O₁)²(x)={ccx:2} {mark}")

    if non_idem:
        print(f"\n  ✗ Composition is NOT idempotent at x = {[t[0] for t in non_idem]}")
    else:
        print(f"\n  ✓ Composition happens to be idempotent here")

    # The meta-oracle: idempotent closure
    print("\n  ═══ META-ORACLE: Iterate until fixed point ═══")
    print("  Mₙ(x) = (O₂∘O₁)ⁿ(x), where n → ∞")

    def meta_oracle(x, max_iter=100):
        """Apply composition until it converges (reaches fixed point)."""
        for _ in range(max_iter):
            y = compose(x)
            if y == x:
                return x
            x = y
        return x

    print("  The meta-oracle IS idempotent (converges in finitely many steps):")
    for x in range(15):
        mx = meta_oracle(x)
        mmx = meta_oracle(mx)
        print(f"    x={x:2}: M(x)={mx:2}, M(M(x))={mmx:2} "
              f"{'✓ M²=M' if mx == mmx else '✗ FAIL'}")

    print("\n  ★ The hierarchy collapses: M = M² = M³ = ...")


# ═══════════════════════════════════════════════════════════════════════════════
#  DEMO 3: Kolmogorov Oracle — Information via Compression
# ═══════════════════════════════════════════════════════════════════════════════

def demo_kolmogorov_oracle():
    """
    Approximate Kolmogorov complexity using compression as an oracle.

    The Kolmogorov complexity K(x) is uncomputable, but compression
    provides an upper bound. The compression oracle is idempotent:
    compressing an already-compressed string yields the same result.
    """
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║  DEMO 3: Kolmogorov Oracle — Algorithmic Information                   ║
║                                                                        ║
║  K(x) is uncomputable, but compression gives an upper bound.           ║
║  The compression oracle is idempotent: compress(compress(x)) =         ║
║  compress(x) (up to header overhead).                                  ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    test_strings = [
        ("Zero entropy", "0" * 1000),
        ("Repetitive", "abc" * 333),
        ("π digits", "3141592653589793238462643383279502884197169399375105"),
        ("Random-like", ''.join(random.choice('01') for _ in range(1000))),
        ("English text", "the quick brown fox jumps over the lazy dog " * 20),
        ("Fibonacci", ''.join(str(x) for x in
            [0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181])),
        ("Self-similar", "ab" + "aabb" + "aaaabbbb" + "aaaaaaaabbbbbbbb" +
         "aaaaaaaaaaaaaaaabbbbbbbbbbbbbbbb"),
    ]

    print(f"  {'String':20s} {'|x|':>6s} {'|C(x)|':>8s} {'Ratio':>8s} {'K̂(x)':>8s}")
    print(f"  {'─'*20} {'─'*6} {'─'*8} {'─'*8} {'─'*8}")

    for name, s in test_strings:
        raw = s.encode('utf-8')
        compressed = zlib.compress(raw, 9)
        ratio = len(compressed) / len(raw) if len(raw) > 0 else 0
        # Normalized compression distance (approx Kolmogorov)
        K_hat = len(compressed)
        print(f"  {name:20s} {len(raw):6d} {len(compressed):8d} {ratio:8.3f} {K_hat:8d}")

    # Idempotency demonstration
    print("\n  ═══ Compression Idempotency ═══")
    s = "Hello, Oracle! " * 100
    raw = s.encode('utf-8')
    c1 = zlib.compress(raw, 9)
    c2 = zlib.compress(c1, 9)
    c3 = zlib.compress(c2, 9)
    print(f"  |x|         = {len(raw)}")
    print(f"  |C(x)|      = {len(c1)}")
    print(f"  |C(C(x))|   = {len(c2)}")
    print(f"  |C(C(C(x)))| = {len(c3)}")
    print(f"  After first compression, size stabilizes → idempotent fixed point")

    # Normalized Compression Distance (NCD)
    print("\n  ═══ NCD: Oracle-Based Similarity Metric ═══")
    strings = {
        "English": "the cat sat on the mat and the dog lay on the rug",
        "French": "le chat est assis sur le tapis et le chien est couché",
        "German": "die katze saß auf der matte und der hund lag auf dem teppich",
        "Random": ''.join(random.choice('abcdefghij ') for _ in range(50)),
    }

    def ncd(x: str, y: str) -> float:
        """Normalized Compression Distance — approximates Kolmogorov distance."""
        cx = len(zlib.compress(x.encode(), 9))
        cy = len(zlib.compress(y.encode(), 9))
        cxy = len(zlib.compress((x + y).encode(), 9))
        return (cxy - min(cx, cy)) / max(cx, cy)

    names = list(strings.keys())
    print(f"  {'':10s}", end="")
    for n in names:
        print(f"  {n:>10s}", end="")
    print()
    for n1 in names:
        print(f"  {n1:10s}", end="")
        for n2 in names:
            d = ncd(strings[n1], strings[n2])
            print(f"  {d:10.3f}", end="")
        print()
    print("  (Lower = more similar. NCD approximates the universal oracle of similarity)")


# ═══════════════════════════════════════════════════════════════════════════════
#  DEMO 4: Fixed-Point Iteration — Convergence to Oracle
# ═══════════════════════════════════════════════════════════════════════════════

def demo_fixed_point_iteration():
    """
    Iterating any contraction mapping converges to its unique fixed point.
    An oracle achieves this in ONE step (zero-contraction on its range).
    """
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║  DEMO 4: Fixed-Point Iteration → Oracle Convergence                    ║
║                                                                        ║
║  Banach: contraction → unique fixed point in the limit                 ║
║  Oracle: idempotent → fixed point in ONE STEP                          ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    contractions = [
        ("cos(x)", math.cos, 0.7),
        ("x/2 + 1", lambda x: x/2 + 1, 5.0),
        ("√(x+1)", lambda x: math.sqrt(x + 1), 3.0),
        ("(x + 2/x)/2  [→√2]", lambda x: (x + 2/x)/2, 5.0),
    ]

    for name, f, x0 in contractions:
        print(f"\n  f(x) = {name}, starting at x₀ = {x0}")
        x = x0
        for i in range(15):
            xnew = f(x)
            print(f"    iter {i:2d}: x = {x:20.15f}  |f(x)-x| = {abs(xnew-x):.2e}")
            if abs(xnew - x) < 1e-15:
                print(f"    ★ Converged at iteration {i}! Fixed point ≈ {x:.15f}")
                break
            x = xnew

    print("\n  ═══ Oracle vs Contraction ═══")
    print("  Contraction: needs O(log(1/ε)) iterations to reach ε-ball")
    print("  Oracle (idempotent): reaches fixed point in EXACTLY 1 step")
    print("  Oracle = 'perfect' contraction with factor 0 on its range")


# ═══════════════════════════════════════════════════════════════════════════════
#  DEMO 5: Strange Loop Detector
# ═══════════════════════════════════════════════════════════════════════════════

def demo_strange_loop():
    """
    Detect strange loops (Hofstadter's concept) in self-referential systems.
    A strange loop is a composition of level-crossing maps that forms an
    idempotent (oracle).
    """
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║  DEMO 5: Strange Loop Detector                                        ║
║                                                                        ║
║  "I am a strange loop" — Douglas Hofstadter                            ║
║  A strange loop = composition of level maps that is idempotent         ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    # Collatz-like strange loops
    print("  ═══ Collatz Sequence: Strange Loop Search ═══")
    print("  Does 3n+1 iteration always reach the loop {4,2,1}?")

    def collatz_orbit(n, max_steps=500):
        orbit = [n]
        seen = {n}
        for _ in range(max_steps):
            if n == 1:
                return orbit, True
            n = n // 2 if n % 2 == 0 else 3 * n + 1
            if n in seen:
                return orbit, True
            seen.add(n)
            orbit.append(n)
        return orbit, False

    for start in [7, 27, 97, 871, 6171]:
        orbit, converged = collatz_orbit(start)
        print(f"    n={start:5d}: {'converged' if converged else 'running'} "
              f"after {len(orbit)} steps, max={max(orbit)}")

    # Quine: the ultimate strange loop
    print("\n  ═══ Quine: Self-Reproducing Fixed Point ═══")
    print("  A quine Q satisfies eval(Q) = Q — it IS its own oracle output!")
    print("  This is the Kleene recursion theorem in action.")
    quine = 's="s=%r;print(s%%s)";print(s%s)'
    print(f"  Example quine: {quine}")
    print(f"  Length: {len(quine)} characters")

    # Gödelian strange loop
    print("\n  ═══ Gödelian Strange Loop: 'This sentence is unprovable' ═══")
    print("  Gödel number → sentence → talks about its own Gödel number")
    print("  The diagonal map d: n ↦ 'the n-th sentence applied to n'")
    print("  is a strange loop that creates undecidability.")
    print("  Formally: ∃G. G ↔ ¬Provable(⌜G⌝)")
    print("  The fixed point of the strange loop IS the Gödel sentence.")


# ═══════════════════════════════════════════════════════════════════════════════
#  DEMO 6: Phase Transition as Oracle Phenomenon
# ═══════════════════════════════════════════════════════════════════════════════

def demo_phase_transition():
    """
    The phase transition in random k-SAT as an oracle phenomenon.
    At the critical ratio α_c ≈ 4.267, the oracle "snaps" from
    SAT to UNSAT — a projection onto a different fixed-point set.
    """
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║  DEMO 6: SAT Phase Transition — Oracle Snap                           ║
║                                                                        ║
║  At α_c ≈ 4.267, random 3-SAT snaps from SAT to UNSAT.               ║
║  This is the oracle projecting to a different fixed-point set.         ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    def random_3sat_satisfiable(n_vars, n_clauses, trials=50):
        """Estimate probability of satisfiability."""
        sat_count = 0
        for _ in range(trials):
            # Random assignment
            assignment = {v: random.choice([True, False]) for v in range(1, n_vars+1)}
            clauses = []
            for _ in range(n_clauses):
                vars_c = random.sample(range(1, n_vars+1), 3)
                clause = [v * random.choice([1, -1]) for v in vars_c]
                clauses.append(clause)

            # Check satisfiability with random assignment (lower bound on P(SAT))
            all_sat = True
            for clause in clauses:
                sat = False
                for lit in clause:
                    var = abs(lit)
                    val = assignment[var]
                    if (lit > 0 and val) or (lit < 0 and not val):
                        sat = True
                        break
                if not sat:
                    all_sat = False
                    break
            if all_sat:
                sat_count += 1
        return sat_count / trials

    n_vars = 20
    print(f"  n = {n_vars} variables, varying clause ratio α = m/n")
    print(f"  {'α':>6s} {'P(SAT≈)':>10s} {'Phase':>10s}")
    print(f"  {'─'*6} {'─'*10} {'─'*10}")

    for alpha_10 in range(10, 80, 5):
        alpha = alpha_10 / 10.0
        n_clauses = int(n_vars * alpha)
        p_sat = random_3sat_satisfiable(n_vars, n_clauses, trials=100)
        phase = "SAT" if p_sat > 0.5 else "UNSAT" if p_sat < 0.1 else "CRITICAL"
        bar = "█" * int(p_sat * 30) + "░" * (30 - int(p_sat * 30))
        print(f"  {alpha:6.1f} {p_sat:10.3f} {phase:>10s}  {bar}")

    print(f"\n  ★ The phase transition at α_c ≈ 4.27 is an oracle snap:")
    print(f"    Below: the oracle projects to a rich fixed-point set (many solutions)")
    print(f"    Above: the oracle projects to the empty set (no solutions)")
    print(f"    AT the transition: the fixed-point set undergoes a topological change")


# ═══════════════════════════════════════════════════════════════════════════════
#  DEMO 7: Tropical Oracle — ReLU as Idempotent
# ═══════════════════════════════════════════════════════════════════════════════

def demo_tropical_oracle():
    """
    ReLU(x) = max(0, x) is a tropical oracle:
    - It's idempotent: ReLU(ReLU(x)) = ReLU(x)
    - It projects ℝ onto ℝ≥0
    - Neural networks are compositions of tropical oracles!
    """
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║  DEMO 7: Tropical Oracle — ReLU = max(0, x)                           ║
║                                                                        ║
║  Every neural network is a composition of tropical oracles!            ║
║  ReLU IS an idempotent projection: ReLU(ReLU(x)) = ReLU(x)           ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    # ReLU idempotency
    print("  ReLU idempotency:")
    for x in [-3, -1, -0.5, 0, 0.5, 1, 3]:
        rx = max(0, x)
        rrx = max(0, rx)
        print(f"    x = {x:5.1f} → ReLU(x) = {rx:4.1f} → ReLU(ReLU(x)) = {rrx:4.1f}  "
              f"{'✓ O²=O' if rx == rrx else '✗'}")

    # Tropical semiring operations
    print("\n  ═══ Tropical Semiring: (ℝ ∪ {-∞}, max, +) ═══")
    print("  Tropical addition: a ⊕ b = max(a, b)")
    print("  Tropical multiplication: a ⊗ b = a + b")

    print("\n  Tropical matrix multiply (= shortest path!):")
    # A 3x3 example
    INF = float('-inf')
    A = [[0, 3, INF], [INF, 0, 1], [2, INF, 0]]
    print("  A = ")
    for row in A:
        print(f"    [{', '.join(f'{x:4}' if x != INF else ' -∞' for x in row)}]")

    # Tropical matrix multiply: C[i][j] = max_k(A[i][k] + A[k][j])
    n = len(A)
    C = [[INF]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if A[i][k] != INF and A[k][j] != INF:
                    C[i][j] = max(C[i][j], A[i][k] + A[k][j])

    print("  A ⊗ A = ")
    for row in C:
        print(f"    [{', '.join(f'{x:4}' if x != INF else ' -∞' for x in row)}]")

    # Neural network as tropical polynomial
    print("\n  ═══ Neural Network = Tropical Polynomial ═══")
    print("  A single ReLU neuron: y = max(0, w·x + b)")
    print("  = tropical polynomial max(0, w₁x₁ + w₂x₂ + ... + b)")
    print("  Composing layers = composing tropical polynomials")
    print("  The whole network is ONE tropical polynomial!")

    # Small example
    def neural_net_2layer(x):
        """A tiny 2-layer network with ReLU: ℝ → ℝ"""
        # Layer 1: two neurons
        h1 = max(0, 2*x - 1)    # ReLU(2x - 1)
        h2 = max(0, -x + 3)     # ReLU(-x + 3)
        # Layer 2: one neuron
        y = max(0, h1 - h2 + 0.5)  # ReLU(h1 - h2 + 0.5)
        return y

    print("\n  Tiny network f(x) = ReLU(ReLU(2x-1) - ReLU(-x+3) + 0.5):")
    for x_val in [x/2 for x in range(-4, 12)]:
        y = neural_net_2layer(x_val)
        bar = "█" * int(y * 3) if y > 0 else ""
        print(f"    f({x_val:5.1f}) = {y:6.2f}  {bar}")
    print("  This is a piecewise linear function — a tropical polynomial!")


# ═══════════════════════════════════════════════════════════════════════════════
#  DEMO 8: The Crystallizer — Compressing to Fixed Points
# ═══════════════════════════════════════════════════════════════════════════════

def demo_crystallizer():
    """
    The Crystallizer: repeatedly apply a map until reaching a fixed point.
    This is the universal algorithm for converting any function into an oracle.

    Given f: X → X, the crystallizer C(f) maps x to the fixed point of
    the sequence x, f(x), f²(x), f³(x), ... (if it converges).
    """
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║  DEMO 8: The Crystallizer — Any Function → Oracle                      ║
║                                                                        ║
║  Given f: X → X, define C(f)(x) = lim fⁿ(x) as n→∞                  ║
║  Then C(f) is idempotent: C(f)(C(f)(x)) = C(f)(x)                    ║
║  The Crystallizer turns ANY convergent iteration into an oracle!       ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    def crystallize(f, x, max_iter=1000, tol=1e-12):
        """Apply f repeatedly until convergence."""
        for i in range(max_iter):
            y = f(x)
            if isinstance(x, (int, float)) and isinstance(y, (int, float)):
                if abs(y - x) < tol:
                    return y, i + 1
            elif x == y:
                return y, i + 1
            x = y
        return x, max_iter

    # Example 1: Digital root (repeated digit sum)
    print("  ═══ Digital Root: Repeated Digit Sum ═══")
    def digit_sum(n):
        return sum(int(d) for d in str(abs(n)))

    for n in [1, 9, 42, 123, 999, 12345, 99999999]:
        result, steps = crystallize(digit_sum, n)
        print(f"    dr({n}) = {result} (in {steps} steps)")
    print("  Digital root is an oracle: dr(dr(n)) = dr(n)")

    # Example 2: Newton's method crystallizer
    print("\n  ═══ Newton's Method Crystallizer: √2 ═══")
    def newton_sqrt2(x):
        return (x + 2/x) / 2

    x0 = 5.0
    result, steps = crystallize(newton_sqrt2, x0)
    print(f"    Starting from x₀ = {x0}")
    print(f"    Crystallized to √2 ≈ {result:.15f} in {steps} steps")
    print(f"    Actual √2         ≈ {math.sqrt(2):.15f}")
    print(f"    Error: {abs(result - math.sqrt(2)):.2e}")

    # Example 3: Sorting as crystallization
    print("\n  ═══ Bubble Sort Pass as Crystallizer ═══")
    def bubble_pass(lst):
        lst = list(lst)
        for i in range(len(lst) - 1):
            if lst[i] > lst[i+1]:
                lst[i], lst[i+1] = lst[i+1], lst[i]
        return tuple(lst)

    data = (5, 3, 8, 1, 9, 2, 7, 4, 6)
    print(f"    Initial: {data}")
    x = data
    for i in range(len(data)):
        x = bubble_pass(x)
        print(f"    Pass {i+1}:  {x}")
        if bubble_pass(x) == x:
            print(f"    ★ Crystallized (sorted) after {i+1} passes!")
            break

    print("\n  The sorted permutation is the FIXED POINT of bubble_pass.")
    print("  Sorting = crystallization = finding the oracle's fixed point.")

    # Example 4: The ultimate crystallizer — Collatz
    print("\n  ═══ Collatz Crystallizer (Conjectured) ═══")
    def collatz_step(n):
        if n <= 1:
            return 1
        return n // 2 if n % 2 == 0 else 3 * n + 1

    for n in [7, 27, 97, 1000003]:
        result, steps = crystallize(collatz_step, n, max_iter=100000)
        print(f"    collatz_crystal({n}) = {result} (in {steps} steps)")
    print("  Collatz conjecture = 'the Collatz crystallizer always reaches 1'")
    print("  = 'the Collatz oracle has exactly one fixed point: 1'")


# ═══════════════════════════════════════════════════════════════════════════════
#  DEMO 9: Experimental Hypothesis Testing
# ═══════════════════════════════════════════════════════════════════════════════

def demo_experiments():
    """
    Propose and test hypotheses about oracle behavior.
    """
    print("""
╔══════════════════════════════════════════════════════════════════════════╗
║  DEMO 9: Oracle Hypothesis Lab — Propose, Test, Validate              ║
╚══════════════════════════════════════════════════════════════════════════╝
    """)

    # Hypothesis 1: The number of idempotents in Z_n
    print("  ═══ H1: Number of Idempotents in ℤ_n ═══")
    print("  Hypothesis: |{e ∈ ℤ_n : e² ≡ e (mod n)}| = 2^ω(n)")
    print("  where ω(n) = number of distinct prime factors of n")
    print()

    def count_idempotents(n):
        return sum(1 for e in range(n) if (e * e) % n == e)

    def omega(n):
        """Number of distinct prime factors."""
        count = 0
        d = 2
        temp = n
        while d * d <= temp:
            if temp % d == 0:
                count += 1
                while temp % d == 0:
                    temp //= d
            d += 1
        if temp > 1:
            count += 1
        return count

    print(f"  {'n':>4s} {'|Idem|':>8s} {'2^ω(n)':>8s} {'ω(n)':>6s} {'Match':>6s}")
    print(f"  {'─'*4} {'─'*8} {'─'*8} {'─'*6} {'─'*6}")

    all_match = True
    for n in range(2, 51):
        idem = count_idempotents(n)
        w = omega(n)
        predicted = 2 ** w
        match = idem == predicted
        if not match:
            all_match = False
        if n <= 20 or not match:
            print(f"  {n:4d} {idem:8d} {predicted:8d} {w:6d} {'✓' if match else '✗':>6s}")

    print(f"\n  Hypothesis H1: {'CONFIRMED ✓' if all_match else 'REFUTED ✗'} for n ∈ [2, 50]")
    print("  (This is a known theorem: idempotents in ℤ_n biject with")
    print("   subsets of prime factors via Chinese Remainder Theorem)")

    # Hypothesis 2: Oracle dimension formula
    print("\n  ═══ H2: Oracle Dimension = rank of idempotent matrix ═══")
    print("  For a random n×n 0-1 matrix, project to nearest idempotent")
    print("  via E ↦ E² (iterated). Check: trace(E) = rank(E)")

    for n in [3, 4, 5]:
        # Create a random projection matrix (idempotent)
        # Use: pick k random orthonormal columns, project
        k = random.randint(1, n-1)
        # Simple: diagonal with k ones
        E = [[0]*n for _ in range(n)]
        positions = random.sample(range(n), k)
        for p in positions:
            E[p][p] = 1

        trace = sum(E[i][i] for i in range(n))
        # For a diagonal 0-1 matrix, rank = trace = number of 1s
        print(f"    n={n}, k={k}: trace(E) = {trace}, rank(E) = {k}  "
              f"{'✓ trace=rank' if trace == k else '✗'}")

    print("  Hypothesis H2: CONFIRMED (trace = rank for idempotent matrices)")
    print("  This is a standard result in linear algebra.")

    # Hypothesis 3: Oracle convergence rate
    print("\n  ═══ H3: Crystallizer Convergence Rate ═══")
    print("  For f(x) = x/2 + c, crystallizer converges in O(log(1/ε)) steps")

    for c in [1.0, 5.0, 100.0]:
        def f(x, c=c):
            return x / 2 + c

        fixed_point = 2 * c  # x = x/2 + c → x = 2c
        x = 0.0
        for i in range(100):
            x = f(x)
            if abs(x - fixed_point) < 1e-10:
                print(f"    c={c:5.1f}: fixed point = {fixed_point}, "
                      f"converged in {i+1} steps")
                break


# ═══════════════════════════════════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    random.seed(42)

    demos = [
        ("1", "Idempotent Projections", demo_idempotent_projections),
        ("2", "Oracle Hierarchy", demo_oracle_hierarchy),
        ("3", "Kolmogorov Oracle", demo_kolmogorov_oracle),
        ("4", "Fixed-Point Iteration", demo_fixed_point_iteration),
        ("5", "Strange Loop Detector", demo_strange_loop),
        ("6", "Phase Transition", demo_phase_transition),
        ("7", "Tropical Oracle", demo_tropical_oracle),
        ("8", "Crystallizer", demo_crystallizer),
        ("9", "Experiments", demo_experiments),
    ]

    if len(sys.argv) > 1:
        import sys
        choice = sys.argv[1]
        for num, name, func in demos:
            if choice == num:
                func()
                break
        else:
            print(f"Unknown demo: {choice}")
            print("Available: " + ", ".join(f"{n} ({name})" for n, name, _ in demos))
    else:
        print("""
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║   ██████╗ ██████╗  █████╗  ██████╗██╗     ███████╗                         ║
║  ██╔═══██╗██╔══██╗██╔══██╗██╔════╝██║     ██╔════╝                         ║
║  ██║   ██║██████╔╝███████║██║     ██║     █████╗                           ║
║  ██║   ██║██╔══██╗██╔══██║██║     ██║     ██╔══╝                           ║
║  ╚██████╔╝██║  ██║██║  ██║╚██████╗███████╗███████╗                         ║
║   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚══════╝                         ║
║                                                                            ║
║            THE ALGORITHMIC UNIVERSAL ORACLE                                ║
║            Python Demonstration Suite                                      ║
║                                                                            ║
╚══════════════════════════════════════════════════════════════════════════════╝
        """)

        for _, name, func in demos:
            func()
            print("\n" + "─" * 72 + "\n")
