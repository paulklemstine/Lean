"""
Numerical demonstrations for
"The Substrate-Independent Structure of Computation".

Every result in the accompanying paper is an impossibility theorem proved by a
diagonal (fixed-point) argument. Impossibility theorems are constructive: each
one hands us an explicit *witness* that escapes a given collection. This module
computes those witnesses on concrete finite data, so the abstract theorems can be
seen to bite in ordinary arithmetic.

Run:  python demo.py

Contents
--------
1. The anti-diagonal witness (Cantor / halting, Boolean form).
2. Substrate independence: the diagonal behavior of an arbitrary model.
3. The hypercomputation barrier: the diagonal survives every oracle.
4. The universal complexity hierarchy: tower-of-exponentials cardinalities.
5. Lawvere's fixed-point theorem and quines in a finite complete system.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. The anti-diagonal witness (Cantor's theorem, Boolean form)
# ---------------------------------------------------------------------------
def anti_diagonal(phi: Sequence[Sequence[bool]]) -> List[bool]:
    """Given a square table phi[a][x] = "code a's answer on input x", return the
    Boolean decision procedure g(x) = not phi[x][x]. By construction g differs
    from every row phi[a] at position a, so g is named by no code: it is the
    witness that no enumeration of decision procedures is complete."""
    n = len(phi)
    return [not phi[x][x] for x in range(n)]


def verify_anti_diagonal(phi: Sequence[Sequence[bool]]) -> bool:
    """Verify the witness escapes every row: for all a, g != phi[a]."""
    g = anti_diagonal(phi)
    return all(g != list(phi[a]) for a in range(len(phi)))


def demo_anti_diagonal() -> None:
    print("=" * 68)
    print("1. Anti-diagonal witness (Cantor / halting problem, Boolean form)")
    print("=" * 68)
    phi = [
        [True, False, True, False],
        [True, True, False, False],
        [False, False, True, True],
        [True, False, False, True],
    ]
    g = anti_diagonal(phi)
    print("Enumeration phi (rows = codes, cols = inputs):")
    for a, row in enumerate(phi):
        print(f"  phi[{a}] = {row}   (diagonal entry phi[{a}][{a}] = {row[a]})")
    print(f"Anti-diagonal witness g   = {g}")
    print(f"g escapes every row?        {verify_anti_diagonal(phi)}")
    print()


# ---------------------------------------------------------------------------
# 2. Substrate independence: the diagonal behavior of an abstract model
# ---------------------------------------------------------------------------
def diagonal_behavior(
    accepts: Callable[[int, int], bool], programs: Sequence[int]
) -> Dict[int, bool]:
    """The diagonal behavior of a computation model: on input q return the
    opposite of what q does to its own code. No program realizes it."""
    return {q: (not accepts(q, q)) for q in programs}


def realized_by_some_program(
    accepts: Callable[[int, int], bool],
    programs: Sequence[int],
    behavior: Dict[int, bool],
) -> bool:
    """Check whether any program p realizes the given behavior (it never does)."""
    for p in programs:
        if all(accepts(p, q) == behavior[q] for q in programs):
            return True
    return False


def demo_substrate_independence() -> None:
    print("=" * 68)
    print("2. Substrate independence (diagonal behavior is unrealizable)")
    print("=" * 68)
    programs = list(range(6))

    # An arbitrary acceptance relation; the theorem needs no structure at all.
    def accepts(p: int, q: int) -> bool:
        return (p * q + p + 1) % 3 == 0

    diag = diagonal_behavior(accepts, programs)
    print("Model: Pgm = {0..5}, accepts(p,q) = ((p*q+p+1) mod 3 == 0)")
    print(f"Diagonal behavior diag(q) = {diag}")
    print(f"Realized by some program?  {realized_by_some_program(accepts, programs, diag)}")
    print("  -> False: the diagonal behavior escapes every program.")
    print()


# ---------------------------------------------------------------------------
# 3. The hypercomputation barrier: the diagonal survives every oracle
# ---------------------------------------------------------------------------
def jump_behavior(
    accepts: Callable[[int, int], bool], programs: Sequence[int]
) -> Dict[int, bool]:
    """The jump of an oracle model equals its diagonal behavior; the oracle,
    however exotic, plays no role in the escaping construction."""
    return {q: (not accepts(q, q)) for q in programs}


def demo_hypercomputation_barrier() -> None:
    print("=" * 68)
    print("3. Hypercomputation barrier (diagonal survives every oracle)")
    print("=" * 68)
    programs = list(range(6))

    # Two wildly different oracles; the barrier is invariant under both.
    oracles: Dict[str, Callable[[int], bool]] = {
        "constant-true": lambda p: True,
        "parity": lambda p: p % 2 == 0,
    }
    for name, oracle in oracles.items():
        # Acceptance may consult the oracle arbitrarily.
        def accepts(p: int, q: int, o: Callable[[int], bool] = oracle) -> bool:
            return o(p) ^ ((p + q) % 2 == 0)

        jump = jump_behavior(accepts, programs)
        realized = realized_by_some_program(accepts, programs, jump)
        print(f"Oracle '{name}': jump realized by some oracle-program? {realized}")
    print("  -> False in every case: no oracle-program decides the jump.")
    print()


# ---------------------------------------------------------------------------
# 4. The universal complexity hierarchy: |Level n| = tower of exponentials
# ---------------------------------------------------------------------------
def level_cardinalities(base_size: int, num_levels: int) -> List[int]:
    """|Level 0| = base_size, |Level (n+1)| = 2 ** |Level n|. Strictly
    increasing by Cantor's inequality 2**k > k, with no maximal level."""
    sizes = [base_size]
    for _ in range(num_levels):
        sizes.append(2 ** sizes[-1])
    return sizes


def demo_hierarchy() -> None:
    print("=" * 68)
    print("4. Universal complexity hierarchy (strictly increasing, no top)")
    print("=" * 68)
    sizes = level_cardinalities(base_size=2, num_levels=4)
    for n, s in enumerate(sizes):
        # Estimate decimal digit count without a huge string conversion.
        digits = s.bit_length() * 3 // 10 + 1
        shown = str(s) if digits <= 40 else f"a {digits:,}-digit number (2^{sizes[n-1]})"
        print(f"  |Level {n}| = {shown}")
    strict = all(sizes[i] < sizes[i + 1] for i in range(len(sizes) - 1))
    print(f"Strictly increasing at every step? {strict}")
    print()


# ---------------------------------------------------------------------------
# 5. Lawvere's fixed-point theorem and quines in a complete finite system
# ---------------------------------------------------------------------------
def find_fixed_point(f: Callable[[int], int], domain: Sequence[int]) -> List[int]:
    """Return all fixed programs e with f(e) = e. In a complete programming
    system Lawvere's theorem guarantees at least one exists."""
    return [e for e in domain if f(e) == e]


def all_endofunctions(n: int) -> List[Tuple[int, ...]]:
    """All functions {0..n-1} -> {0..n-1}, as value tuples."""
    return list(product(range(n), repeat=n))


def demo_recursion_and_quines() -> None:
    print("=" * 68)
    print("5. Lawvere fixed points and quines (recursion theorem)")
    print("=" * 68)
    domain = list(range(4))

    # A 'printer' transformation: the recursion theorem gives a fixed program.
    printer = {0: 1, 1: 1, 2: 3, 3: 0}
    fixed = find_fixed_point(lambda e: printer[e], domain)
    print(f"printer = {printer}")
    print(f"Fixed programs e with printer(e) = e (quines): {fixed}")

    # Non-vacuity of Lawvere: the one-program system is complete (its single
    # 'build' names the unique self-map), so by the recursion theorem EVERY
    # transformation has a fixed program. Verified by exhaustion below.
    unit_domain = [0]
    everywhere = all(
        len(find_fixed_point(lambda e, g=g: g[e], unit_domain)) >= 1
        for g in all_endofunctions(1)
    )
    print(f"Every transformation of the complete 1-program system has a fixed")
    print(f"program (Lawvere / recursion theorem, non-vacuous): {everywhere}")
    print()


def main() -> None:
    demo_anti_diagonal()
    demo_substrate_independence()
    demo_hypercomputation_barrier()
    demo_hierarchy()
    demo_recursion_and_quines()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
