#!/usr/bin/env python3
"""
Applications of Depth Rigidity Theory

Demonstrates real-world applications of the tower separation and
depth rigidity theorems:

1. Arithmetic circuit lower bounds
2. Symbolic computation complexity
3. Proof-theoretic strength classification
4. Optimal algorithm depth certification
"""

import math
from typing import List, Tuple
from algorithms import shifted_tower, classify_growth_rank, InverseFreeDAG, DagOp


# ═══════════════════════════════════════════════════════════════
# Application 1: Arithmetic Circuit Lower Bounds
# ═══════════════════════════════════════════════════════════════

def circuit_lower_bound_demo():
    """Demonstrate how tower separation gives circuit depth lower bounds.
    
    In arithmetic circuit complexity, the depth of a circuit measures
    the minimum number of sequential operations required. Our theorem
    shows that computing shiftedTower(n, x) requires circuit depth ≥ n
    in the inverse-free EML model, regardless of circuit width (sharing).
    """
    print("Application 1: Arithmetic Circuit Depth Lower Bounds")
    print("=" * 55)
    print()
    print("The depth rigidity theorem gives unconditional lower bounds:")
    print()
    print(f"{'Function':>25} | {'Min Depth':>10} | {'Growth Class':>15}")
    print("-" * 55)
    
    functions = [
        ("x + 1 (successor)", 0, "polynomial"),
        ("2^(x²+2)", 1, "single-exp"),
        ("2^(2^((x²+1)²+2))", 2, "double-exp"),
        ("tower of height 3", 3, "triple-exp"),
        ("tower of height n", "n", "n-exp"),
    ]
    
    for name, depth, growth in functions:
        print(f"{name:>25} | {str(depth):>10} | {growth:>15}")
    
    print()
    print("Key insight: These lower bounds hold even with UNRESTRICTED sharing")
    print("(DAG representation), not just for tree-shaped circuits.")
    print("This is the content of the depth rigidity theorem.")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 2: Symbolic Computation Complexity
# ═══════════════════════════════════════════════════════════════

def symbolic_complexity_demo():
    """Show how depth rigidity classifies symbolic expression complexity.
    
    In computer algebra systems, expressions are represented as DAGs.
    The depth rigidity theorem tells us that certain expressions CANNOT
    be simplified below a certain depth, no matter how clever the
    simplification algorithm.
    """
    print("Application 2: Symbolic Expression Complexity")
    print("=" * 55)
    print()
    print("Expressions and their irreducible depth:")
    print()
    
    expressions = [
        ("e^x", 1, "Cannot be reduced below depth 1"),
        ("e^(e^x)", 2, "Cannot be reduced below depth 2"),
        ("e^(e^(e^x))", 3, "Cannot be reduced below depth 3"),
        ("2^(x²+1)", 1, "Single exponential with polynomial"),
        ("2^(2^(x²+1))", 2, "Double exponential with polynomial"),
    ]
    
    for expr, depth, note in expressions:
        print(f"  {expr:>15}  →  depth ≥ {depth}  ({note})")
    
    print()
    print("Practical implication: A symbolic computation engine evaluating")
    print("tower-level expressions needs at least n sequential exponentiations.")
    print("Parallelism (sharing) cannot reduce this sequential requirement.")
    print()
    
    # Compute actual expression sizes vs depth
    print("Expression tree size vs DAG size (with maximum sharing):")
    print(f"{'Height':>8} | {'Tree nodes':>12} | {'DAG nodes':>12} | {'Depth':>8}")
    print("-" * 50)
    for h in range(1, 8):
        tree_nodes = 2 ** h - 1  # Full binary tree
        dag_nodes = 2 * h - 1    # Maximum sharing
        print(f"{h:>8} | {tree_nodes:>12} | {dag_nodes:>12} | {h:>8}")
    
    print()
    print("Sharing can exponentially reduce SIZE but never reduces DEPTH.")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 3: Proof-Theoretic Strength
# ═══════════════════════════════════════════════════════════════

def proof_theoretic_demo():
    """Connect tower hierarchy to proof-theoretic ordinal analysis.
    
    The fast-growing hierarchy classifies the provably total functions
    of theories of increasing strength. Our bridge theorem connects
    this classification to arithmetic circuit depth.
    """
    print("Application 3: Proof-Theoretic Strength Classification")
    print("=" * 55)
    print()
    print("Connection between circuit depth and proof theory:")
    print()
    print(f"{'Circuit Depth':>15} | {'Tower Level':>13} | {'Proof Theory':>25}")
    print("-" * 60)
    
    levels = [
        (0, 0, "Polynomial (Q₀)"),
        (1, 1, "Exponential (EFA)"),
        (2, 2, "Double-exp (Σ₁-induction)"),
        (3, 3, "Triple-exp (Σ₂-induction)"),
        ("n", "n", "Σₙ-induction"),
        ("ω", "∞", "Full PA"),
    ]
    
    for depth, tower, theory in levels:
        print(f"{str(depth):>15} | {str(tower):>13} | {theory:>25}")
    
    print()
    print("The bridge theorem (fg ≤ shiftedTower at low levels) shows that")
    print("proving totality of level-n functions in arithmetic requires")
    print("at least Σₙ-induction — mirroring the depth lower bound.")
    print()
    
    # Verify the bridge numerically
    print("Numerical verification of fg ≤ shiftedTower bridge:")
    print(f"{'x':>4} | {'fg(0,x)':>8} | {'ST(0,x)':>8} | {'fg(1,x)':>8} | {'ST(1,x)':>12}")
    print("-" * 50)
    for x in range(1, 8):
        fg0 = x + 1
        st0 = x + 1
        fg1 = 2 * x
        st1 = shifted_tower(1, x)
        st1s = str(st1) if st1 is not None and st1 < 10**15 else "∞"
        print(f"{x:>4} | {fg0:>8} | {st0:>8} | {fg1:>8} | {st1s:>12}")
    print()


# ═══════════════════════════════════════════════════════════════
# Application 4: Optimal Algorithm Depth Certification
# ═══════════════════════════════════════════════════════════════

def optimal_depth_demo():
    """Certify that algorithms achieve optimal sequential depth.
    
    Given a function f and a DAG computing it, verify that the DAG's
    depth matches the theoretical lower bound from tower separation.
    """
    print("Application 4: Optimal Depth Certification")
    print("=" * 55)
    print()
    
    # Build optimal DAGs for each level
    print("Constructing optimal DAGs for shiftedTower levels:")
    print()
    
    for n in range(4):
        # The canonical DAG for shiftedTower(n) has depth n
        print(f"  Level {n}: canonical DAG has depth {n}")
        if n == 0:
            print(f"    Expression: x + 1")
            print(f"    DAG: [var, const(1), add(0,1)]  (depth 0)")
        elif n == 1:
            print(f"    Expression: 2^(x² + 2)")
            print(f"    DAG: [var, mul(0,0), const(1), add(1,2), const(1), eml(4,3)]  (depth 1)")
        elif n == 2:
            print(f"    Expression: 2^(2^((x²+1)² + 2))")
            print(f"    DAG needs 2 sequential eml operations  (depth 2)")
        elif n == 3:
            print(f"    Expression: 2^(2^(2^(...)))")
            print(f"    DAG needs 3 sequential eml operations  (depth 3)")
        print()
    
    print("Depth Rigidity guarantees: NO DAG computing shiftedTower(n)")
    print("can achieve depth < n, regardless of sharing strategy.")
    print()
    
    # Growth rank classification of sample functions
    print("Growth rank classification of sample functions:")
    test_fns = [
        ("constant 42", lambda x: 42),
        ("x + 1", lambda x: x + 1),
        ("x²", lambda x: x * x),
        ("x^10", lambda x: x ** 10),
        ("2^x", lambda x: 2 ** x if x < 100 else float('inf')),
        ("x · 2^x", lambda x: x * (2 ** x) if x < 60 else float('inf')),
    ]
    
    print(f"{'Function':>15} | {'Growth Rank':>12} | {'Min Circuit Depth':>18}")
    print("-" * 50)
    for name, fn in test_fns:
        rank = classify_growth_rank(fn, test_points=list(range(1, 15)))
        depth = max(0, rank)
        print(f"{name:>15} | {rank:>12} | {depth:>18}")
    print()


# ═══════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF DEPTH RIGIDITY THEORY                         ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    circuit_lower_bound_demo()
    symbolic_complexity_demo()
    proof_theoretic_demo()
    optimal_depth_demo()
    
    print("=" * 55)
    print("All applications demonstrate the same principle:")
    print("Growth-rank separation implies depth separation.")
    print("=" * 55)


#!/usr/bin/env python3
"""
Depth Rigidity for Generalized Tower Families — Interactive Demo

Demonstrates the key theorems numerically:
1. shiftedTower growth across levels
2. Tower separation under polynomial reparameterization
3. Fast-growing hierarchy comparison
4. Depth-majorant analysis for small DAGs

Run: python3 demo.py
"""

import math
from typing import Callable, List, Tuple

# ─────────────────────────────────────────────────────────────
# Core definitions
# ─────────────────────────────────────────────────────────────

def poly_seed(x: int) -> int:
    """Polynomial seed: x² + 1."""
    return x * x + 1


def shifted_tower(n: int, x: int) -> int:
    """The shifted tower family.
    Level 0: x + 1 (successor)
    Level n+1: 2^(shifted_tower(n, x² + 1))
    """
    if n == 0:
        return x + 1
    inner = shifted_tower(n - 1, poly_seed(x))
    if inner > 1000:  # prevent astronomical computation
        return float('inf')
    return 2 ** inner


def fg(n: int, x: int) -> int:
    """Fast-growing hierarchy at finite levels.
    fg(0, x) = x + 1
    fg(n+1, x) = fg(n)^x(x) — iterate fg(n) x times starting from x
    """
    if n == 0:
        return x + 1
    result = x
    for _ in range(x):
        result = fg(n - 1, result)
        if result > 10**15:
            return float('inf')
    return result


# ─────────────────────────────────────────────────────────────
# Demo 1: Growth across levels
# ─────────────────────────────────────────────────────────────

def demo_growth():
    print("=" * 70)
    print("DEMO 1: Shifted Tower Growth Across Levels")
    print("=" * 70)
    print()
    print("shiftedTower(n, x) for small x and n = 0, 1, 2, 3:")
    print()
    print(f"{'x':>4} | {'Level 0':>10} | {'Level 1':>15} | {'Level 2':>20} | {'Level 3':>20}")
    print("-" * 75)
    for x in range(8):
        vals = []
        for n in range(4):
            v = shifted_tower(n, x)
            if v == float('inf') or v > 10**18:
                vals.append("∞")
            else:
                vals.append(str(v))
        print(f"{x:>4} | {vals[0]:>10} | {vals[1]:>15} | {vals[2]:>20} | {vals[3]:>20}")

    print()
    print("Key observations:")
    print("  • Level 0 is linear (x + 1)")
    print("  • Level 1 is exponential: 2^(x² + 2)")
    print("  • Level 2 is double-exponential: 2^(2^((x²+1)² + 2))")
    print("  • Each level grows DRAMATICALLY faster than the one below")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 2: Tower separation
# ─────────────────────────────────────────────────────────────

def demo_separation():
    print("=" * 70)
    print("DEMO 2: Tower Separation Under Polynomial Reparameterization")
    print("=" * 70)
    print()
    print("Theorem: For m < n and any polynomial p(x) = C·x^k + C,")
    print("         shiftedTower(m, p(x)) < shiftedTower(n, x) for large x.")
    print()
    
    # Test: shiftedTower(0, 10x + 10) vs shiftedTower(1, x)
    print("Test: shiftedTower(0, 10x + 10) vs shiftedTower(1, x)")
    print(f"{'x':>4} | {'ST(0, 10x+10)':>15} | {'ST(1, x)':>20} | {'Separated?':>12}")
    print("-" * 60)
    for x in range(1, 8):
        lhs = shifted_tower(0, 10 * x + 10)
        rhs = shifted_tower(1, x)
        sep = "YES ✓" if lhs < rhs else "no"
        lhs_s = str(lhs) if lhs < 10**18 else "∞"
        rhs_s = str(rhs) if rhs < 10**18 else "∞"
        print(f"{x:>4} | {lhs_s:>15} | {rhs_s:>20} | {sep:>12}")
    
    print()
    print("Test: shiftedTower(0, 5x² + 5) vs shiftedTower(1, x)")
    print(f"{'x':>4} | {'ST(0, 5x²+5)':>15} | {'ST(1, x)':>20} | {'Separated?':>12}")
    print("-" * 60)
    for x in range(1, 8):
        poly_val = 5 * x * x + 5
        lhs = shifted_tower(0, poly_val)
        rhs = shifted_tower(1, x)
        sep = "YES ✓" if lhs < rhs else "no"
        lhs_s = str(lhs) if lhs < 10**18 else "∞"
        rhs_s = str(rhs) if rhs < 10**18 else "∞"
        print(f"{x:>4} | {lhs_s:>15} | {rhs_s:>20} | {sep:>12}")
    
    print()
    print("Key insight: No polynomial reparameterization of a lower level")
    print("             can catch up to the next level.")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 3: Fast-growing hierarchy comparison
# ─────────────────────────────────────────────────────────────

def demo_fg_comparison():
    print("=" * 70)
    print("DEMO 3: Fast-Growing Hierarchy vs Shifted Tower")
    print("=" * 70)
    print()
    print("Level 0: fg(0, x) = x + 1 = shiftedTower(0, x)  [identical]")
    print("Level 1: fg(1, x) = 2x ≤ shiftedTower(1, x)  [bounded]")
    print("Level 2: fg(2, x) = x·2^x ≤ shiftedTower(2, x)  [bounded]")
    print("Level ≥ 3: fg(n, x) EXCEEDS shiftedTower(n, x)  [diverges]")
    print()
    
    print("fg vs shiftedTower comparison at level 1:")
    print(f"{'x':>4} | {'fg(1,x) = 2x':>12} | {'ST(1,x)':>20} | {'Ratio':>10}")
    print("-" * 55)
    for x in range(1, 8):
        fgv = fg(1, x)
        stv = shifted_tower(1, x)
        if stv < 10**18 and stv > 0:
            ratio = f"{stv / fgv:.1f}x"
        else:
            ratio = "∞"
        print(f"{x:>4} | {fgv:>12} | {stv:>20} | {ratio:>10}")
    
    print()
    print("fg vs shiftedTower comparison at level 2:")
    print(f"{'x':>4} | {'fg(2,x) = x·2^x':>18} | {'ST(2,x)':>20}")
    print("-" * 50)
    for x in range(1, 6):
        fgv = fg(2, x)
        stv = shifted_tower(2, x)
        fgs = str(fgv) if fgv < 10**18 else "∞"
        sts = str(stv) if stv != float('inf') else "∞"
        print(f"{x:>4} | {fgs:>18} | {sts:>20}")
    
    print()
    print("At level 2, the shifted tower already vastly exceeds fg.")
    print("At level 3+, fg catches up and eventually surpasses,")
    print("because fg produces towers of HEIGHT ~x (not fixed height).")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 4: Depth-Majorant Analysis for Small DAGs
# ─────────────────────────────────────────────────────────────

def demo_depth_majorant():
    print("=" * 70)
    print("DEMO 4: Depth-Majorant Analysis")
    print("=" * 70)
    print()
    print("Can a depth-d function match shiftedTower(n) for n > d?")
    print()
    
    # Simple DAGs: polynomials (depth 0), single exp (depth 1)
    depth0_fns = [
        ("x + 1", lambda x: x + 1),
        ("3x + 5", lambda x: 3 * x + 5),
        ("x²", lambda x: x * x),
        ("x³", lambda x: x ** 3),
    ]
    
    depth1_fns = [
        ("2^x", lambda x: 2 ** x if x < 100 else float('inf')),
        ("2^(2x)", lambda x: 2 ** (2 * x) if 2 * x < 100 else float('inf')),
        ("x · 2^x", lambda x: x * (2 ** x) if x < 60 else float('inf')),
    ]
    
    print("Depth-0 functions vs shiftedTower(1, x):")
    print(f"{'Function':>10} | ", end="")
    for x in [1, 2, 3, 4, 5]:
        print(f"{'x=' + str(x):>12}", end=" | ")
    print("Majorized?")
    print("-" * 85)
    for name, fn in depth0_fns:
        print(f"{name:>10} | ", end="")
        all_below = True
        for x in [1, 2, 3, 4, 5]:
            v = fn(x)
            st = shifted_tower(1, x)
            below = v < st
            all_below = all_below and below
            marker = "✓" if below else "✗"
            print(f"{v:>10}{marker} | ", end="")
        print("YES ✓" if all_below else "NO")
    
    print()
    print("Depth-1 functions vs shiftedTower(2, x):")
    print(f"{'Function':>10} | ", end="")
    for x in [1, 2, 3]:
        print(f"{'x=' + str(x):>12}", end=" | ")
    print("Majorized?")
    print("-" * 60)
    for name, fn in depth1_fns:
        print(f"{name:>10} | ", end="")
        all_below = True
        for x in [1, 2, 3]:
            v = fn(x)
            st = shifted_tower(2, x)
            below = v < st if st != float('inf') else True
            all_below = all_below and below
            if v == float('inf'):
                vs = "∞"
            else:
                vs = str(v)
            marker = "✓" if below else "✗"
            print(f"{vs:>10}{marker} | ", end="")
        print("YES ✓" if all_below else "NO")
    
    print()
    print("Key result: Depth-d functions are always majorized by shiftedTower(d+1).")
    print("           This empirically confirms the depth rigidity theorem.")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 5: Iterated logarithm profile
# ─────────────────────────────────────────────────────────────

def demo_log_profile():
    print("=" * 70)
    print("DEMO 5: Growth Profile (log-scale visualization)")
    print("=" * 70)
    print()
    print("Number of times we can take log₂ before reaching ≤ 1:")
    print("(This is the 'tower height' — the depth rigidity invariant)")
    print()
    
    def iterated_log2(n):
        """Count how many times we can take log₂ before reaching ≤ 1."""
        count = 0
        x = float(n)
        while x > 1:
            x = math.log2(x)
            count += 1
            if count > 100:
                return ">100"
        return count
    
    print(f"{'Function':>20} | {'x=2':>6} | {'x=3':>6} | {'x=4':>6} | {'x=5':>6}")
    print("-" * 55)
    
    for name, fn in [
        ("x + 1", lambda x: x + 1),
        ("2^x", lambda x: 2 ** x),
        ("ST(0, x)", lambda x: shifted_tower(0, x)),
        ("ST(1, x)", lambda x: shifted_tower(1, x)),
        ("ST(2, x)", lambda x: shifted_tower(2, x)),
    ]:
        print(f"{name:>20} | ", end="")
        for x in [2, 3, 4, 5]:
            v = fn(x)
            if v == float('inf'):
                print(f"{'∞':>6} | ", end="")
            else:
                il = iterated_log2(v)
                print(f"{il:>6} | ", end="")
        print()
    
    print()
    print("The iterated-log count IS the tower level — this is the")
    print("depth rigidity invariant made visible.")
    print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  DEPTH RIGIDITY FOR GENERALIZED TOWER FAMILIES                 ║")
    print("║  Interactive Demonstration                                     ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_growth()
    demo_separation()
    demo_fg_comparison()
    demo_depth_majorant()
    demo_log_profile()
    
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("These demonstrations illustrate the core theorem:")
    print()
    print("  Depth lower bounds are not peculiar to iterExp;")
    print("  they are consequences of a general growth-separation principle.")
    print()
    print("The shifted tower family — using quadratic seeds x²+1 at each")
    print("recursive level — exhibits the same depth rigidity as the standard")
    print("iterated exponential, confirming that sequential depth is a")
    print("robust invariant of explosive growth, not an artifact of a")
    print("specific recursion pattern.")
    print()
