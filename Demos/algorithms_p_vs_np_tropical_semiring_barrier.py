#!/usr/bin/env python3
"""
Tropical Semiring Barrier Theorems — Algorithms

Implements core algorithms for tropical circuit analysis:
1. Tropical expression evaluation and monotonicity verification
2. Exhaustive representation search
3. Non-monotonicity witness finding
4. Piecewise-linear region estimation
5. Random tropical expression generation

Usage:
    python algorithms.py
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, Optional
from itertools import product
import random
import time


# ─── Tropical Expression AST ───────────────────────────────────────────

@dataclass(frozen=True)
class Const:
    value: int

@dataclass(frozen=True)
class Var:
    index: int

@dataclass(frozen=True)
class TMin:
    left: 'TropExpr'
    right: 'TropExpr'

@dataclass(frozen=True)
class TAdd:
    left: 'TropExpr'
    right: 'TropExpr'

TropExpr = Const | Var | TMin | TAdd


def eval_trop(expr: TropExpr, v: list[int]) -> int:
    """Evaluate a tropical expression. O(size(expr)) time."""
    match expr:
        case Const(c): return c
        case Var(i): return v[i]
        case TMin(e1, e2): return min(eval_trop(e1, v), eval_trop(e2, v))
        case TAdd(e1, e2): return eval_trop(e1, v) + eval_trop(e2, v)


def expr_size(expr: TropExpr) -> int:
    """Count nodes in expression tree. O(size) time."""
    match expr:
        case Const(_) | Var(_): return 1
        case TMin(e1, e2) | TAdd(e1, e2): return 1 + expr_size(e1) + expr_size(e2)


def expr_depth(expr: TropExpr) -> int:
    """Compute depth of expression tree. O(size) time."""
    match expr:
        case Const(_) | Var(_): return 0
        case TMin(e1, e2) | TAdd(e1, e2):
            return 1 + max(expr_depth(e1), expr_depth(e2))


def min_gate_count(expr: TropExpr) -> int:
    """Count the number of min gates. O(size) time."""
    match expr:
        case Const(_) | Var(_): return 0
        case TMin(e1, e2): return 1 + min_gate_count(e1) + min_gate_count(e2)
        case TAdd(e1, e2): return min_gate_count(e1) + min_gate_count(e2)


def expr_to_string(expr: TropExpr) -> str:
    """Pretty-print a tropical expression."""
    match expr:
        case Const(c): return str(c)
        case Var(i): return f"x{i}"
        case TMin(e1, e2):
            return f"min({expr_to_string(e1)}, {expr_to_string(e2)})"
        case TAdd(e1, e2):
            return f"({expr_to_string(e1)} + {expr_to_string(e2)})"


# ─── Algorithm 1: Monotonicity Verification ────────────────────────────

def verify_monotonicity_exhaustive(
    expr: TropExpr, n: int, max_val: int = 3
) -> tuple[bool, Optional[tuple[list[int], list[int]]]]:
    """
    Exhaustively verify monotonicity of a tropical expression
    over assignments with values in {0, ..., max_val}.

    Returns (is_monotone, counterexample_or_None).

    Time complexity: O(max_val^(2n) * size(expr))
    Space complexity: O(n)
    """
    for u_tuple in product(range(max_val + 1), repeat=n):
        u = list(u_tuple)
        eu = eval_trop(expr, u)
        for v_tuple in product(range(max_val + 1), repeat=n):
            v = list(v_tuple)
            if all(u[i] <= v[i] for i in range(n)):
                ev = eval_trop(expr, v)
                if eu > ev:
                    return False, (u, v)
    return True, None


def verify_monotonicity_random(
    expr: TropExpr, n: int, trials: int = 10000, max_val: int = 20
) -> tuple[bool, Optional[tuple[list[int], list[int]]]]:
    """
    Probabilistically test monotonicity using random samples.

    Time complexity: O(trials * size(expr))
    """
    for _ in range(trials):
        u = [random.randint(0, max_val) for _ in range(n)]
        delta = [random.randint(0, max_val // 2) for _ in range(n)]
        v = [u[i] + delta[i] for i in range(n)]
        if eval_trop(expr, u) > eval_trop(expr, v):
            return False, (u, v)
    return True, None


# ─── Algorithm 2: Non-Monotonicity Witness Search ──────────────────────

def find_nonmonotonicity_witness(
    f: Callable[[list[bool]], int], n: int
) -> Optional[tuple[list[bool], list[bool]]]:
    """
    Find a witness pair (u, v) demonstrating that f is not tropically
    monotone: boolEnc(u) ≤ boolEnc(v) pointwise but f(u) > f(v).

    Time complexity: O(4^n) worst case
    """
    bool_enc = lambda b: 0 if b else 1

    for u_bits in product([False, True], repeat=n):
        u = list(u_bits)
        fu = f(u)
        for v_bits in product([False, True], repeat=n):
            v = list(v_bits)
            if all(bool_enc(u[i]) <= bool_enc(v[i]) for i in range(n)):
                if fu > f(v):
                    return (u, v)
    return None


def count_nonmonotonicity_witnesses(
    f: Callable[[list[bool]], int], n: int
) -> int:
    """Count all monotonicity-violating pairs."""
    bool_enc = lambda b: 0 if b else 1
    count = 0
    for u_bits in product([False, True], repeat=n):
        u = list(u_bits)
        for v_bits in product([False, True], repeat=n):
            v = list(v_bits)
            if all(bool_enc(u[i]) <= bool_enc(v[i]) for i in range(n)):
                if f(u) > f(v):
                    count += 1
    return count


# ─── Algorithm 3: Exhaustive Representation Search ─────────────────────

def search_representation(
    f: Callable[[list[bool]], int], n: int, max_size: int = 7,
    const_range: int = 3
) -> Optional[TropExpr]:
    """
    Exhaustively search for a tropical expression representing f.

    Pseudocode:
        for s = 1, 2, ..., max_size:
            for each expression e of size s:
                if eval(e, boolEnc(v)) == f(v) for all v in {0,1}^n:
                    return e
        return None

    Time complexity: O(C(max_size) * 2^n) where C(s) ~ 4^s
    """
    bool_enc = lambda b: 0 if b else 1
    all_assignments = list(product([False, True], repeat=n))

    # Generate expressions by size
    by_size: dict[int, list[TropExpr]] = {1: []}
    for c in range(const_range):
        by_size[1].append(Const(c))
    for i in range(n):
        by_size[1].append(Var(i))

    def check(expr: TropExpr) -> bool:
        for v_bits in all_assignments:
            v = list(v_bits)
            enc = [bool_enc(b) for b in v]
            if eval_trop(expr, enc) != f(v):
                return False
        return True

    # Check size 1
    for e in by_size[1]:
        if check(e):
            return e

    for s in range(2, max_size + 1):
        by_size[s] = []
        for s1 in range(1, s):
            s2 = s - 1 - s1
            if s2 < 1:
                continue
            for e1 in by_size[s1]:
                for e2 in by_size[s2]:
                    for constructor in [TMin, TAdd]:
                        e = constructor(e1, e2)
                        by_size[s].append(e)
                        if check(e):
                            return e
    return None


# ─── Algorithm 4: Region Count Estimation ──────────────────────────────

def estimate_region_count(
    expr: TropExpr, n: int, samples: int = 100000, grid_size: int = 100
) -> int:
    """
    Estimate the number of linear regions of a tropical expression
    by sampling random points and detecting changes in the
    "active min branch" pattern.

    Each min gate selects either its left or right argument.
    The pattern of selections defines a linear region.

    Time complexity: O(samples * size(expr))
    """
    def get_selection_pattern(expr: TropExpr, v: list[float]) -> tuple:
        """Get the pattern of min-gate selections."""
        match expr:
            case Const(_) | Var(_):
                return ()
            case TMin(e1, e2):
                v1 = eval_trop_float(e1, v)
                v2 = eval_trop_float(e2, v)
                sel = 0 if v1 <= v2 else 1
                p1 = get_selection_pattern(e1, v)
                p2 = get_selection_pattern(e2, v)
                return (sel,) + p1 + p2
            case TAdd(e1, e2):
                p1 = get_selection_pattern(e1, v)
                p2 = get_selection_pattern(e2, v)
                return p1 + p2

    def eval_trop_float(expr: TropExpr, v: list[float]) -> float:
        match expr:
            case Const(c): return float(c)
            case Var(i): return v[i]
            case TMin(e1, e2):
                return min(eval_trop_float(e1, v), eval_trop_float(e2, v))
            case TAdd(e1, e2):
                return eval_trop_float(e1, v) + eval_trop_float(e2, v)

    patterns = set()
    for _ in range(samples):
        v = [random.uniform(0, grid_size) for _ in range(n)]
        pat = get_selection_pattern(expr, v)
        patterns.add(pat)

    return len(patterns)


# ─── Algorithm 5: Random Expression Generation ─────────────────────────

def random_tropical_expr(n: int, target_size: int) -> TropExpr:
    """
    Generate a random tropical expression of approximately the given size.

    Time complexity: O(target_size)
    """
    if target_size <= 1 or random.random() < 0.3:
        if random.random() < 0.4:
            return Const(random.randint(0, 5))
        else:
            return Var(random.randint(0, n - 1))

    s1 = random.randint(1, max(1, target_size - 2))
    s2 = target_size - 1 - s1
    e1 = random_tropical_expr(n, s1)
    e2 = random_tropical_expr(n, max(1, s2))

    if random.random() < 0.5:
        return TMin(e1, e2)
    else:
        return TAdd(e1, e2)


# ─── Main: Algorithm Demonstrations ────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("Tropical Barrier Theorems — Algorithm Demonstrations")
    print("=" * 70)

    # Demo 1: Monotonicity verification
    print("\n--- Algorithm 1: Monotonicity Verification ---")
    expr = TMin(TAdd(Var(0), Var(1)), TAdd(Var(1), Const(2)))
    print(f"Expression: {expr_to_string(expr)}")
    print(f"Size: {expr_size(expr)}, Depth: {expr_depth(expr)}, Min gates: {min_gate_count(expr)}")

    is_mono, cex = verify_monotonicity_exhaustive(expr, 2, max_val=5)
    print(f"Exhaustive check (values 0-5): Monotone = {is_mono}")

    is_mono_r, _ = verify_monotonicity_random(expr, 2, trials=50000)
    print(f"Random check (50000 trials): Monotone = {is_mono_r}")

    # Demo 2: Non-monotonicity witnesses
    print("\n--- Algorithm 2: Non-Monotonicity Witness Search ---")
    predicates = {
        "Parity(n=3)": (lambda v: 0 if sum(v) % 2 == 1 else 1, 3),
        "XOR(n=2)": (lambda v: 0 if (v[0] ^ v[1]) else 1, 2),
        "ExactOne(n=3)": (lambda v: 0 if sum(v) == 1 else 1, 3),
        "Mod3(n=3)": (lambda v: 0 if sum(v) % 3 == 0 else 1, 3),
        "AND(n=2)": (lambda v: 0 if all(v) else 1, 2),
        "OR(n=2)": (lambda v: 0 if any(v) else 1, 2),
    }
    for name, (f, n) in predicates.items():
        w = find_nonmonotonicity_witness(f, n)
        count = count_nonmonotonicity_witnesses(f, n) if w else 0
        if w:
            print(f"  {name}: NOT monotone (witness: u={w[0]}, v={w[1]}, total violations: {count})")
        else:
            print(f"  {name}: Monotone ✓")

    # Demo 3: Representation search
    print("\n--- Algorithm 3: Representation Search ---")
    search_targets = {
        "AND(n=2)": (lambda v: 0 if all(v) else 1, 2),
        "OR(n=2)": (lambda v: 0 if any(v) else 1, 2),
        "XOR(n=2)": (lambda v: 0 if (v[0] ^ v[1]) else 1, 2),
    }
    for name, (f, n) in search_targets.items():
        t0 = time.time()
        result = search_representation(f, n, max_size=5)
        dt = time.time() - t0
        if result:
            print(f"  {name}: Found {expr_to_string(result)} (size={expr_size(result)}, {dt:.3f}s)")
        else:
            print(f"  {name}: No representation found (size≤5, {dt:.3f}s)")

    # Demo 4: Region count estimation
    print("\n--- Algorithm 4: Region Count Estimation ---")
    for target_size in [5, 10, 15, 20]:
        n_vars = 3
        expr = random_tropical_expr(n_vars, target_size)
        actual_size = expr_size(expr)
        mg = min_gate_count(expr)
        regions = estimate_region_count(expr, n_vars, samples=50000)
        bound = 2 ** mg
        print(f"  Size={actual_size}, min_gates={mg}: ~{regions} regions (bound: 2^{mg}={bound})")

    print("\n" + "=" * 70)
    print("All algorithm demonstrations completed.")
    print("=" * 70)
