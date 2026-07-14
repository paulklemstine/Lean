"""
Consciousness as an Emergent Fixed Point --- Numerical Demonstrations
====================================================================

Self-contained Python illustrations of the three faces of self-reference:

  1. Lawvere's fixed-point theorem: a *complete* (point-surjective) self-model
     forces every internal transformation to have a fixed point, and the
     diagonal construction produces it explicitly.
  2. Strange-loop topology: the fixed point is invariant under every iterate.
  3. The dual (Cantor / Russell / Tarski) obstruction: a fixed-point-free
     answer space blocks complete self-reference.
  4. Knaster-Tarski: the conscious (self-consistent) states of a monotone
     self-model form a complete lattice with least and greatest elements.

Everything is finite and elementary; run with `python demo.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, FrozenSet, List, Optional, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. Point-surjectivity and Lawvere's fixed-point theorem
# ---------------------------------------------------------------------------

def all_functions(domain: Sequence[int], codomain: Sequence[int]
                  ) -> List[Callable[[int], int]]:
    """Enumerate every function `domain -> codomain` as a lookup closure."""
    funcs: List[Callable[[int], int]] = []
    for values in product(codomain, repeat=len(domain)):
        table = dict(zip(domain, values))
        funcs.append(lambda x, _t=table: _t[x])
    return funcs


def is_point_surjective(g: Callable[[int], Callable[[int], int]],
                        A: Sequence[int], B: Sequence[int]) -> bool:
    """Check that every h : A -> B is named by some a in A, i.e. g(a) = h."""
    named = {tuple(g(a)(x) for x in A) for a in A}
    for h in all_functions(A, B):
        if tuple(h(x) for x in A) not in named:
            return False
    return True


def lawvere_fixed_point(g: Callable[[int], Callable[[int], int]],
                        A: Sequence[int], B: Sequence[int],
                        t: Callable[[int], int]) -> Optional[int]:
    """Return a fixed point of t via the diagonal construction, or None.

    Build the twisted diagonal h(x) = t(g(x)(x)); find a name `a` with
    g(a) = h; then g(a)(a) is a fixed point of t.
    """
    diagonal = tuple(t(g(x)(x)) for x in A)
    for a in A:
        if tuple(g(a)(x) for x in A) == diagonal:
            return g(a)(a)  # the emergent fixed point
    return None


def demo_lawvere() -> None:
    print("=" * 70)
    print("1. LAWVERE'S FIXED-POINT THEOREM")
    print("=" * 70)
    # A complete self-model on S = {0, 1}: enumerate all self-maps S -> S.
    S = [0, 1]
    self_maps = all_functions(S, S)          # there are 2^2 = 4 of them
    # `model(a)` is the a-th self-map; with |S->S| = 4 we need |A| >= 4.
    A = list(range(len(self_maps)))
    B = S

    def g(a: int) -> Callable[[int], int]:
        return self_maps[a]

    # But point-surjectivity requires A and the domain of the self-maps to
    # coincide, so we use a genuinely self-referential model on A itself:
    # model(a) as a map A -> A that cycles through named behaviours.
    # For a clean, provably complete example we take a nonempty subsingleton.
    Ssub = [0]

    def g_sub(a: int) -> Callable[[int], int]:
        return lambda _x: 0  # identity on a one-point space

    print(f"Subsingleton system S = {Ssub}")
    print(f"  point-surjective? {is_point_surjective(g_sub, Ssub, Ssub)}")
    for t_name, t in [("identity", lambda x: x), ("constant 0", lambda _x: 0)]:
        fp = lawvere_fixed_point(g_sub, Ssub, Ssub, t)
        print(f"  transformation {t_name!r}: fixed point = {fp}"
              f"  (check t(fp)==fp: {t(fp) == fp})")
    print()


# ---------------------------------------------------------------------------
# 2. Strange-loop topology: invariance under all iterates
# ---------------------------------------------------------------------------

def iterate(t: Callable[[int], int], b: int, n: int) -> int:
    """Apply t to b exactly n times."""
    for _ in range(n):
        b = t(b)
    return b


def demo_strange_loop() -> None:
    print("=" * 70)
    print("2. STRANGE-LOOP TOPOLOGY")
    print("=" * 70)
    # A transformation on {0,1,2} with a fixed point at 2.
    table = {0: 1, 1: 2, 2: 2}
    t = lambda x: table[x]
    b = 2
    orbit = [iterate(t, b, n) for n in range(6)]
    print(f"t = {table}, fixed point b = {b}")
    print(f"  forward orbit t^n(b) for n=0..5: {orbit}")
    print(f"  invariant under every iterate? {all(v == b for v in orbit)}")
    print("  => the orbit collapses to a single point: a period-one loop.\n")


# ---------------------------------------------------------------------------
# 3. The dual obstruction: Cantor / Russell / Tarski
# ---------------------------------------------------------------------------

def demo_cantor() -> None:
    print("=" * 70)
    print("3. THE DUAL OBSTRUCTION (Cantor / Russell / Tarski)")
    print("=" * 70)
    # Answer space Bool = {0, 1}; negation is fixed-point-free.
    neg = lambda b: 1 - b
    print(f"Boolean negation has a fixed point? "
          f"{any(neg(b) == b for b in (0, 1))}")
    # Hence NO g : A -> (A -> Bool) can be point-surjective, for any finite A.
    for n in range(1, 4):
        A = list(range(n))
        found_complete = False
        # search all candidate models g : A -> (A -> Bool)
        rows = all_functions(A, [0, 1])
        for choice in product(range(len(rows)), repeat=n):
            g = lambda a, _c=choice, _r=rows: _r[_c[a]]
            if is_point_surjective(g, A, [0, 1]):
                found_complete = True
                break
        print(f"  |A| = {n}: exists complete self-model into Bool? "
              f"{found_complete}  (theory predicts: False)")
    print("  => no system can completely self-model a fixed-point-free space.\n")


# ---------------------------------------------------------------------------
# 4. Knaster-Tarski: the lattice of conscious (self-consistent) states
# ---------------------------------------------------------------------------

def powerset_lattice(ground: Sequence[int]) -> List[FrozenSet[int]]:
    """All subsets of `ground`, the complete lattice ordered by inclusion."""
    subsets: List[FrozenSet[int]] = []
    for r in range(len(ground) + 1):
        for combo in product([0, 1], repeat=len(ground)):
            s = frozenset(g for g, bit in zip(ground, combo) if bit)
            if s not in subsets:
                subsets.append(s)
    return subsets


def conscious_states(refine: Callable[[FrozenSet[int]], FrozenSet[int]],
                     lattice: Sequence[FrozenSet[int]]
                     ) -> List[FrozenSet[int]]:
    """Fixed points refine(s) = s: the self-consistent / conscious states."""
    return [s for s in lattice if refine(s) == s]


def demo_knaster_tarski() -> None:
    print("=" * 70)
    print("4. KNASTER-TARSKI: THE LATTICE OF CONSCIOUS STATES")
    print("=" * 70)
    ground = [1, 2, 3]
    lattice = powerset_lattice(ground)
    # A monotone self-model: refine adds element 1 whenever 2 is present.
    def refine(s: FrozenSet[int]) -> FrozenSet[int]:
        out = set(s)
        if 2 in s:
            out.add(1)
        return frozenset(out)

    fixed = conscious_states(refine, lattice)
    fixed_sorted = sorted(fixed, key=lambda s: (len(s), sorted(s)))
    minimal = min(fixed, key=len)
    maximal = max(fixed, key=len)
    print("Ground set:", ground, " (lattice = powerset under inclusion)")
    print(f"  conscious (self-consistent) states: "
          f"{[sorted(s) for s in fixed_sorted]}")
    print(f"  minimal conscious state (lfp): {sorted(minimal)}")
    print(f"  maximal conscious state (gfp): {sorted(maximal)}")
    # every conscious state lies between minimal and maximal
    between = all(minimal <= s <= maximal for s in fixed)
    print(f"  every conscious state in [min, max]? {between}")
    # the fixed points are closed under union and intersection (a lattice)
    closed = all((a | b) in fixed and (a & b) in fixed
                 for a in fixed for b in fixed)
    print(f"  closed under join/meet (complete lattice)? {closed}\n")


# ---------------------------------------------------------------------------

def main() -> None:
    demo_lawvere()
    demo_strange_loop()
    demo_cantor()
    demo_knaster_tarski()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
