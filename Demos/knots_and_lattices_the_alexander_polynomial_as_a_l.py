"""
Knots and Lattices: numerical demonstrations.

Self-contained Python illustrating the main results:

  1. The unsigned area generating function has non-negative coefficients,
     so it can never equal the trefoil polynomial t - 1 + t^{-1}
     (its t^0 coefficient is -1).  [Refutation]
  2. The signed state sum reproduces the trefoil polynomial from three
     states of areas (1, 0, -1) and signs (+1, -1, +1).  [Rescue]
  3. An area-negating, sign-preserving involution makes a signed state
     sum palindromic, i.e. Delta(t) = Delta(t^{-1}).  [Reciprocity]
  4. Monotone lattice paths from (0,0) to (n,n) are the n-subsets of a
     2n-set; there are C(2n,n) of them, and a family's shadow obeys the
     Kruskal-Katona bound.  [Substrate]

No external dependencies.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from math import comb
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Coefficient functions (Laurent polynomials as dict: exponent -> coefficient)
# ---------------------------------------------------------------------------

Coeffs = Dict[int, int]


def is_nonneg(c: Coeffs) -> bool:
    """A coefficient map is non-negative if every coefficient is >= 0."""
    return all(v >= 0 for v in c.values())


def is_palindromic(c: Coeffs) -> bool:
    """Palindromic: coefficient of t^k equals coefficient of t^{-k}."""
    keys = set(c) | {-k for k in c}
    return all(c.get(k, 0) == c.get(-k, 0) for k in keys)


def poly_str(c: Coeffs) -> str:
    """Render a coefficient map as a readable Laurent polynomial."""
    terms: List[str] = []
    for k in sorted(c, reverse=True):
        v = c[k]
        if v == 0:
            continue
        power = "1" if k == 0 else (f"t^{{{k}}}")
        terms.append(f"{v:+d}*{power}")
    return " ".join(terms) if terms else "0"


# ---------------------------------------------------------------------------
# The trefoil polynomial  t - 1 + t^{-1}
# ---------------------------------------------------------------------------

TREFOIL: Coeffs = {1: 1, 0: -1, -1: 1}


# ---------------------------------------------------------------------------
# Enumeration models
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class State:
    """An abstract state with an integer area and a +/-1 sign."""
    label: int
    area: int
    sign: int  # +1 or -1


def area_gf(states: Sequence[State]) -> Coeffs:
    """Unsigned area generating function: count of states of each area."""
    out: Coeffs = {}
    for s in states:
        out[s.area] = out.get(s.area, 0) + 1
    return out


def signed_gf(states: Sequence[State]) -> Coeffs:
    """Signed state sum: sum of signs of states of each area."""
    out: Coeffs = {}
    for s in states:
        out[s.area] = out.get(s.area, 0) + s.sign
    return {k: v for k, v in out.items()}


# ---------------------------------------------------------------------------
# Result 1 & 2: refutation and rescue
# ---------------------------------------------------------------------------

def demo_refutation_and_rescue() -> None:
    print("=" * 70)
    print("Results 1 & 2: Refutation of the unsigned model, signed rescue")
    print("=" * 70)
    print(f"Trefoil polynomial:            {poly_str(TREFOIL)}")
    print(f"  coefficient of t^0:          {TREFOIL.get(0, 0)}")
    print(f"  is non-negative?             {is_nonneg(TREFOIL)}")
    print()
    print("Any unsigned area generating function has non-negative coefficients,")
    print("so it can NEVER equal the trefoil polynomial (t^0 coeff = -1).")
    print()

    # The three-state signed model of the rescue theorem.
    states = [
        State(label=0, area=1, sign=+1),
        State(label=1, area=0, sign=-1),
        State(label=2, area=-1, sign=+1),
    ]
    unsigned = area_gf(states)
    signed = signed_gf(states)
    print(f"Three states (area, sign): "
          f"{[(s.area, s.sign) for s in states]}")
    print(f"  unsigned area GF:            {poly_str(unsigned)}"
          f"   (non-neg={is_nonneg(unsigned)}, != trefoil)")
    print(f"  signed state sum:            {poly_str(signed)}")
    print(f"  signed sum == trefoil?       {signed == TREFOIL}")
    print()


# ---------------------------------------------------------------------------
# Result 3: reciprocity from an involution
# ---------------------------------------------------------------------------

def demo_reciprocity() -> None:
    print("=" * 70)
    print("Result 3: Reciprocity from an area-negating, sign-preserving")
    print("          involution  =>  palindromic signed state sum")
    print("=" * 70)
    states = [
        State(label=0, area=1, sign=+1),
        State(label=1, area=0, sign=-1),
        State(label=2, area=-1, sign=+1),
    ]
    # phi: swap the two outer states, fix the central one.
    phi: Dict[int, int] = {0: 2, 1: 1, 2: 0}
    by_label = {s.label: s for s in states}

    involution = all(phi[phi[s.label]] == s.label for s in states)
    area_neg = all(by_label[phi[s.label]].area == -s.area for s in states)
    sign_pres = all(by_label[phi[s.label]].sign == s.sign for s in states)
    signed = signed_gf(states)

    print(f"  phi is an involution?        {involution}")
    print(f"  phi negates area?            {area_neg}")
    print(f"  phi preserves sign?          {sign_pres}")
    print(f"  signed state sum:            {poly_str(signed)}")
    print(f"  is palindromic?              {is_palindromic(signed)}")
    print()


# ---------------------------------------------------------------------------
# Result 4: lattice-path substrate and Kruskal-Katona shadow
# ---------------------------------------------------------------------------

def lattice_paths(n: int) -> List[Tuple[int, ...]]:
    """Monotone paths (0,0)->(n,n) as n-subsets of {0,...,2n-1}."""
    return [tuple(c) for c in combinations(range(2 * n), n)]


def shadow(family: Iterable[Tuple[int, ...]]) -> List[Tuple[int, ...]]:
    """The shadow: all (n-1)-subsets obtained by deleting one element."""
    out = set()
    for s in family:
        for i in range(len(s)):
            out.add(s[:i] + s[i + 1:])
    return sorted(out)


def demo_lattice_paths() -> None:
    print("=" * 70)
    print("Result 4: Lattice paths, the count C(2n,n), and Kruskal-Katona")
    print("=" * 70)
    for n in range(1, 6):
        paths = lattice_paths(n)
        print(f"  n={n}: #paths = {len(paths):5d}   C(2n,n) = {comb(2 * n, n):5d}"
              f"   match={len(paths) == comb(2 * n, n)}")
    print()

    # Kruskal-Katona: a family of size >= C(k,n) has shadow >= C(k,n-1).
    n, k = 3, 4
    all_paths = lattice_paths(n)
    family = all_paths[: comb(k, n)]  # take exactly C(k,n) paths
    sh = shadow(family)
    print(f"  n={n}, k={k}: family size = {len(family)} = C(k,n) = {comb(k, n)}")
    print(f"    shadow size = {len(sh)},  bound C(k,n-1) = {comb(k, n - 1)}")
    print(f"    Kruskal-Katona bound holds? {len(sh) >= comb(k, n - 1)}")
    print()


# ---------------------------------------------------------------------------
# A tiny "signed realization" algorithm: build states for any target poly
# ---------------------------------------------------------------------------

def realize_as_signed_states(target: Coeffs) -> List[State]:
    """Emit |c_k| states of area k with sign(c_k) for each exponent k."""
    states: List[State] = []
    label = 0
    for k in sorted(target, reverse=True):
        v = target[k]
        s = 1 if v > 0 else -1
        for _ in range(abs(v)):
            states.append(State(label=label, area=k, sign=s))
            label += 1
    return states


def demo_signed_realization() -> None:
    print("=" * 70)
    print("Algorithm: realize an arbitrary Laurent polynomial as a signed sum")
    print("=" * 70)
    targets: List[Coeffs] = [
        TREFOIL,
        {2: 1, 1: -3, 0: 5, -1: -3, -2: 1},  # a palindromic example
    ]
    for t in targets:
        st = realize_as_signed_states(t)
        rebuilt = signed_gf(st)
        print(f"  target:   {poly_str(t)}")
        print(f"  #states:  {len(st)}   rebuilt == target? {rebuilt == t}")
        print(f"  palindromic target? {is_palindromic(t)}")
        print()


def main() -> None:
    demo_refutation_and_rescue()
    demo_reciprocity()
    demo_lattice_paths()
    demo_signed_realization()


if __name__ == "__main__":
    main()
