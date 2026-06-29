"""
Proof-Complexity Holography — Numerical Demonstrations
======================================================

A self-contained Python companion to the Lean development
`Catalog/Logic/ProofComplexity/Holography.lean`.

We model the abstract objects of the paper:

  * an *implicational theory* as a directed graph (atoms = vertices,
    axioms `a -> b` = edges);
  * length-graded derivability `DerivOfLen T a b k` as "there is a directed
    walk of length exactly k from a to b";
  * the *proof metric* `minDerivLen T a b` as the shortest directed path
    length (computed by BFS);
  * a *proof translation* as a vertex map together with a `stretch` constant
    and a per-axiom realization (a target derivation of length <= stretch).

We then demonstrate, on concrete theories, the four headline results:

  1. translate_deriv          -- holographic propagation: length k -> <= L*k
  2. minDerivLen_translate_le -- the proof metric is L-Lipschitz
  3. translate_comp_step      -- composing translations multiplies stretches
  4. chain_doubling_isometry  -- doubling scales chain distance by exactly 2

Everything is inlined; no third-party dependencies. Run with `python demo.py`.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass, field
from typing import Callable, Dict, Iterable, List, Optional, Tuple

Atom = object  # atoms can be ints, strings, tuples, ...


# ---------------------------------------------------------------------------
# Implicational theories as directed graphs
# ---------------------------------------------------------------------------
@dataclass
class Theory:
    """An implicational theory: a finite set of atoms with one-step axioms.

    `axioms[a]` is the list of atoms `b` with an axiom `a -> b`.
    """

    name: str
    axioms: Dict[Atom, List[Atom]] = field(default_factory=dict)

    def add_axiom(self, a: Atom, b: Atom) -> None:
        self.axioms.setdefault(a, []).append(b)
        self.axioms.setdefault(b, [])

    def step(self, a: Atom, b: Atom) -> bool:
        """Does the single axiom `a -> b` hold?  (T a b)"""
        return b in self.axioms.get(a, [])

    def atoms(self) -> Iterable[Atom]:
        return self.axioms.keys()


def deriv_of_len(theory: Theory, a: Atom, b: Atom, k: int) -> bool:
    """`DerivOfLen T a b k`: a directed walk of length exactly k from a to b."""
    if k == 0:
        return a == b
    # walks of length k from a: neighbours reachable in k-1 steps, then one step
    frontier = {a}
    for _ in range(k):
        nxt: set = set()
        for x in frontier:
            nxt.update(theory.axioms.get(x, []))
        frontier = nxt
    return b in frontier


def min_deriv_len(theory: Theory, a: Atom, b: Atom) -> Optional[int]:
    """`minDerivLen T a b`: shortest directed path length (BFS). None if a !|- b."""
    if a == b:
        return 0
    dist: Dict[Atom, int] = {a: 0}
    q: deque = deque([a])
    while q:
        x = q.popleft()
        for y in theory.axioms.get(x, []):
            if y not in dist:
                dist[y] = dist[x] + 1
                if y == b:
                    return dist[y]
                q.append(y)
    return None


def shortest_derivation(theory: Theory, a: Atom, b: Atom) -> Optional[List[Atom]]:
    """An explicit shortest derivation a = x0 -> ... -> xk = b (BFS path)."""
    if a == b:
        return [a]
    prev: Dict[Atom, Atom] = {}
    dist: Dict[Atom, int] = {a: 0}
    q: deque = deque([a])
    while q:
        x = q.popleft()
        for y in theory.axioms.get(x, []):
            if y not in dist:
                dist[y] = dist[x] + 1
                prev[y] = x
                if y == b:
                    path = [y]
                    while path[-1] != a:
                        path.append(prev[path[-1]])
                    return list(reversed(path))
                q.append(y)
    return None


# ---------------------------------------------------------------------------
# Proof translations
# ---------------------------------------------------------------------------
@dataclass
class Translation:
    """A proof translation T -> S.

    * `vmap`    : map on atoms  (phi.map)
    * `stretch` : per-axiom cost L
    * `realize` : for each source axiom (a -> b), a target derivation
                  [vmap(a), ..., vmap(b)] of length <= stretch.
    """

    source: Theory
    target: Theory
    vmap: Callable[[Atom], Atom]
    stretch: int
    realize: Callable[[Atom, Atom], List[Atom]]

    def check_certificate(self) -> bool:
        """Verify the one-step stretch certificate (Definition 3.1)."""
        for a in self.source.atoms():
            for b in self.source.axioms.get(a, []):
                path = self.realize(a, b)
                if path[0] != self.vmap(a) or path[-1] != self.vmap(b):
                    return False
                if len(path) - 1 > self.stretch:  # length = #edges
                    return False
                for x, y in zip(path, path[1:]):
                    if not self.target.step(x, y):
                        return False
        return True


def translate_derivation(tr: Translation, derivation: List[Atom]) -> List[Atom]:
    """Algorithm B: translate an explicit source derivation (Theorem 4.1).

    Concatenates the per-axiom realizations; output length <= stretch * k.
    """
    out: List[Atom] = [tr.vmap(derivation[0])]
    for a, b in zip(derivation, derivation[1:]):
        piece = tr.realize(a, b)  # vmap(a) -> ... -> vmap(b)
        out.extend(piece[1:])
    return out


# ---------------------------------------------------------------------------
# Concrete theories
# ---------------------------------------------------------------------------
def chain_theory(n: int) -> Theory:
    """chainT truncated to {0, ..., n}: axioms k -> k+1."""
    t = Theory(name=f"chain[0..{n}]")
    for k in range(n):
        t.add_axiom(k, k + 1)
    t.axioms.setdefault(n, [])
    return t


def doubling_translation(n: int) -> Translation:
    """The doubling translation n |-> 2n on the chain, stretch 2 (Def. 7.1)."""
    src = chain_theory(n)
    tgt = chain_theory(2 * n)

    def realize(a: Atom, b: Atom) -> List[Atom]:
        # axiom a -> a+1  becomes  2a -> 2a+1 -> 2a+2
        return [2 * a, 2 * a + 1, 2 * a + 2]

    return Translation(src, tgt, vmap=lambda k: 2 * k, stretch=2, realize=realize)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_propagation_and_lipschitz() -> None:
    print("=" * 70)
    print("1 & 2.  Holographic propagation + Lipschitz proof metric")
    print("=" * 70)
    n = 6
    tr = doubling_translation(n)
    assert tr.check_certificate(), "doubling certificate must hold (stretch = 2)"
    L = tr.stretch
    print(f"Translation: chain doubling, stretch L = {L}")
    print(f"{'a':>3} {'b':>3} | {'k=d_T(a,b)':>10} | {'len(translated)':>15} "
          f"| {'<= L*k?':>8} | {'d_S(2a,2b)':>11} | {'<= L*k?':>8}")
    for a in range(n + 1):
        for b in range(a, n + 1):
            k = min_deriv_len(tr.source, a, b)
            deriv = shortest_derivation(tr.source, a, b)
            tderiv = translate_derivation(tr, deriv)
            tlen = len(tderiv) - 1
            ds = min_deriv_len(tr.target, 2 * a, 2 * b)
            assert tlen <= L * k                          # Theorem 4.1
            assert ds is not None and ds <= L * k          # Theorem 5.1
            if b in (a, a + 2, n):  # print a representative subset
                print(f"{a:>3} {b:>3} | {k:>10} | {tlen:>15} "
                      f"| {str(tlen <= L*k):>8} | {ds:>11} | {str(ds <= L*k):>8}")
    print("All (a,b): len(translated) <= L*k  and  d_S(2a,2b) <= L*k  [OK]\n")


def demo_composition() -> None:
    print("=" * 70)
    print("3.  Composition law: stretches multiply")
    print("=" * 70)
    n = 4
    phi = doubling_translation(n)        # stretch L = 2 : chain[0..4] -> chain[0..8]
    psi = doubling_translation(2 * n)    # stretch M = 2 : chain[0..8] -> chain[0..16]
    L, M = phi.stretch, psi.stretch
    print(f"phi: stretch L = {L},  psi: stretch M = {M},  predicted composite <= M*L = {M*L}")
    print(f"{'axiom a->b':>12} | {'realized length in R':>20} | {'<= M*L?':>8}")
    for a in phi.source.atoms():
        for b in phi.source.axioms.get(a, []):
            # one source axiom -> phi -> derivation in S -> psi -> derivation in R
            s_piece = phi.realize(a, b)               # in S
            r_piece = translate_derivation(psi, s_piece)  # in R
            j = len(r_piece) - 1
            assert j <= M * L                           # Theorem 6.1
            print(f"{f'{a}->{b}':>12} | {j:>20} | {str(j <= M*L):>8}")
    print("Composite map (4n) realizes every source axiom in <= M*L steps  [OK]\n")


def demo_chain_doubling_isometry() -> None:
    print("=" * 70)
    print("4.  Holographic exactness: doubling scales distance by EXACTLY 2")
    print("=" * 70)
    n = 8
    chain = chain_theory(2 * n)
    print(f"{'a':>3} {'b':>3} | {'d(a,b)=b-a':>10} | {'d(2a,2b)':>9} | {'ratio':>6} | {'= 2 * d?':>9}")
    for a in range(n + 1):
        for b in range(a, n + 1):
            d = min_deriv_len(chain_theory(n), a, b)
            d2 = min_deriv_len(chain, 2 * a, 2 * b)
            assert d2 == 2 * d                          # Theorem 7.2 (EXACT)
            if b in (a, a + 1, n):
                ratio = "-" if d == 0 else f"{d2 / d:.1f}"
                print(f"{a:>3} {b:>3} | {d:>10} | {d2:>9} | {ratio:>6} | {str(d2 == 2*d):>9}")
    print("For ALL a <= b:  d(2a, 2b) = 2 * d(a, b)  exactly (zero slack)  [OK]\n")


def demo_nonchain_strict_triangle() -> None:
    """A theory with a shortcut: the triangle inequality becomes strict,
    illustrating that not every geometry is rigid like the chain."""
    print("=" * 70)
    print("Bonus.  A non-rigid theory: shortcuts give a STRICT triangle inequality")
    print("=" * 70)
    t = Theory(name="diamond+shortcut")
    for (a, b) in [("a", "b"), ("b", "c"), ("c", "d"), ("a", "d")]:
        t.add_axiom(a, b) if (a, b) != ("a", "d") else t.add_axiom("a", "d")
    d_ad = min_deriv_len(t, "a", "d")     # direct shortcut: 1
    d_abcd = (min_deriv_len(t, "a", "c") or 0) + (min_deriv_len(t, "c", "d") or 0)
    print(f"d(a,d) via shortcut         = {d_ad}")
    print(f"d(a,c) + d(c,d) via long way = {d_abcd}")
    print(f"strict triangle inequality (d(a,d) < detour)?  {d_ad < d_abcd}\n")


def main() -> None:
    demo_propagation_and_lipschitz()
    demo_composition()
    demo_chain_doubling_isometry()
    demo_nonchain_strict_triangle()
    print("All demonstrations passed: the four headline theorems hold numerically.")


if __name__ == "__main__":
    main()
