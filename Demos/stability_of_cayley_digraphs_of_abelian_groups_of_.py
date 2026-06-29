"""Numerical demonstrations for:

    Stability of Cayley Digraphs of Abelian Groups of Odd Order

This self-contained script exercises the main theorems of the package on
small finite abelian groups Z/n and products thereof:

  * cayAdj / dcAdj            -- the Cayley and double-cover adjacency rules.
  * AutRel                    -- automorphism groups via brute-force enumeration.
  * expectedHom_injective     -- the expected automorphisms always embed; the
                                 double cover has at least 2*|Aut(X)| symmetries.
  * dcCayleyIso               -- the double cover IS a Cayley digraph over
                                 G x Z/2 with connection set S x {1}.
  * odd_no_involution         -- odd-order groups have no element g != 0 with
                                 g + g = 0; even-order groups do.
  * stability decision        -- stable  <=>  |Aut(X (x) K2)| = 2 * |Aut(X)|.

Run:  python demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

from itertools import permutations, product
from typing import Dict, FrozenSet, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Finite abelian groups as tuples of residues with componentwise addition.
# An element of Z/m1 x ... x Z/mk is a tuple; `moduli` records the (m_i).
# ---------------------------------------------------------------------------

Element = Tuple[int, ...]


def group_elements(moduli: Sequence[int]) -> List[Element]:
    """All elements of the abelian group Z/m1 x ... x Z/mk."""
    return [tuple(e) for e in product(*[range(m) for m in moduli])]


def add(a: Element, b: Element, moduli: Sequence[int]) -> Element:
    return tuple((x + y) % m for x, y, m in zip(a, b, moduli))


def sub(a: Element, b: Element, moduli: Sequence[int]) -> Element:
    return tuple((x - y) % m for x, y, m in zip(a, b, moduli))


# ---------------------------------------------------------------------------
# Adjacency relations.
# ---------------------------------------------------------------------------

def cay_adj(S: FrozenSet[Element], g: Element, h: Element,
            moduli: Sequence[int]) -> bool:
    """Arc g -> h in Cay(G, S) iff h - g in S."""
    return sub(h, g, moduli) in S


# Double-cover vertices are (group_element, layer) with layer in {0, 1}.
DCVertex = Tuple[Element, int]


def dc_adj(S: FrozenSet[Element], p: DCVertex, q: DCVertex,
           moduli: Sequence[int]) -> bool:
    """Arc (g,a) -> (h,b) in Cay(G,S) (x) K2 iff h - g in S and a != b."""
    (g, a), (h, b) = p, q
    return sub(h, g, moduli) in S and a != b


# ---------------------------------------------------------------------------
# AutRel via backtracking on the adjacency matrix (Algorithm A).
#
# Brute-forcing all n! permutations is infeasible once n grows (the double
# cover of a 7-vertex graph has 14 vertices, and 14! is astronomical).  We
# instead count adjacency-preserving permutations by a pruned backtracking
# search: extend a partial bijection one vertex at a time, checking that every
# already-assigned arc/non-arc is respected.  This scales comfortably to the
# double covers used here.
# ---------------------------------------------------------------------------

def _count_automorphisms(adj: List[List[bool]]) -> int:
    """Number of permutations p of {0..n-1} with adj[p[i]][p[j]] == adj[i][j]."""
    n = len(adj)
    image: List[int] = [-1] * n   # image[i] = where vertex i is sent
    used: List[bool] = [False] * n

    def consistent(i: int, target: int) -> bool:
        for j in range(i):
            tj = image[j]
            if adj[target][tj] != adj[i][j]:
                return False
            if adj[tj][target] != adj[j][i]:
                return False
        return True

    count = 0

    def backtrack(i: int) -> None:
        nonlocal count
        if i == n:
            count += 1
            return
        for target in range(n):
            if not used[target] and consistent(i, target):
                image[i] = target
                used[target] = True
                backtrack(i + 1)
                used[target] = False
        image[i] = -1

    backtrack(0)
    return count


def aut_cayley(S: FrozenSet[Element], moduli: Sequence[int]) -> List[Dict[Element, Element]]:
    """All permutations of G preserving cay_adj; returned as dicts."""
    verts = group_elements(moduli)
    out: List[Dict[Element, Element]] = []
    for perm in permutations(verts):
        sigma = dict(zip(verts, perm))
        if all(cay_adj(S, sigma[g], sigma[h], moduli) == cay_adj(S, g, h, moduli)
               for g in verts for h in verts):
            out.append(sigma)
    return out


def aut_double_cover(S: FrozenSet[Element], moduli: Sequence[int]) -> int:
    """Order of Aut(Cay(G,S) (x) K2) via backtracking on the adjacency matrix."""
    verts: List[DCVertex] = [(g, a) for g in group_elements(moduli) for a in (0, 1)]
    adj = [[dc_adj(S, p, q, moduli) for q in verts] for p in verts]
    return _count_automorphisms(adj)


# ---------------------------------------------------------------------------
# expectedHom and its injectivity (Theorem: expectedHom_injective).
# ---------------------------------------------------------------------------

def product_permutation(sigma: Dict[Element, Element], pi: Dict[int, int]
                        ) -> Dict[DCVertex, DCVertex]:
    """sigma x pi acting on G x {0,1}: (g,a) -> (sigma g, pi a)."""
    out: Dict[DCVertex, DCVertex] = {}
    for g in sigma:
        for a in (0, 1):
            out[(g, a)] = (sigma[g], pi[a])
    return out


def expected_hom_image(S: FrozenSet[Element], moduli: Sequence[int]
                       ) -> List[Dict[DCVertex, DCVertex]]:
    """Image of expectedHom: { sigma x pi : sigma in Aut(X), pi in Sym2 }."""
    sym2 = [{0: 0, 1: 1}, {0: 1, 1: 0}]
    return [product_permutation(sigma, pi)
            for sigma in aut_cayley(S, moduli) for pi in sym2]


def check_expected_hom_injective(S: FrozenSet[Element], moduli: Sequence[int]) -> bool:
    """Distinct (sigma, pi) give distinct sigma x pi (injectivity)."""
    images = expected_hom_image(S, moduli)
    frozen = {tuple(sorted(im.items())) for im in images}
    return len(frozen) == len(images)  # 2 * |Aut(X)| distinct elements


# ---------------------------------------------------------------------------
# dcCayleyIso: the double cover is a Cayley digraph over G x Z/2.
# ---------------------------------------------------------------------------

def check_dc_cayley_iso(S: FrozenSet[Element], moduli: Sequence[int]) -> bool:
    """dc_adj S p q  <=>  cay_adj (S x {1}) (f p) (f q), with f = id x beta."""
    ext_moduli = tuple(moduli) + (2,)
    dc_conn = frozenset(tuple(s) + (1,) for s in S)
    verts: List[DCVertex] = [(g, a) for g in group_elements(moduli) for a in (0, 1)]

    def f(p: DCVertex) -> Element:
        (g, a) = p
        return tuple(g) + (a % 2,)  # beta: false=0 -> 0, true=1 -> 1

    return all(
        dc_adj(S, p, q, moduli)
        == cay_adj(dc_conn, f(p), f(q), ext_moduli)
        for p in verts for q in verts
    )


# ---------------------------------------------------------------------------
# odd_no_involution.
# ---------------------------------------------------------------------------

def involutions(moduli: Sequence[int]) -> List[Element]:
    """Nonzero g with g + g = 0 (elements of order 2)."""
    zero = tuple(0 for _ in moduli)
    return [g for g in group_elements(moduli)
            if g != zero and add(g, g, moduli) == zero]


# ---------------------------------------------------------------------------
# Stability decision (Algorithm B): stable <=> |Aut(X (x) K2)| = 2|Aut(X)|.
# ---------------------------------------------------------------------------

def is_stable(S: FrozenSet[Element], moduli: Sequence[int]) -> Tuple[bool, int, int]:
    a = len(aut_cayley(S, moduli))
    b = aut_double_cover(S, moduli)
    return (b == 2 * a, a, b)


# ---------------------------------------------------------------------------
# Driver.
# ---------------------------------------------------------------------------

def banner(text: str) -> None:
    print("\n" + "=" * 70)
    print(text)
    print("=" * 70)


def main() -> None:
    banner("1. odd_no_involution : odd-order groups have NO involutions")
    for moduli in [(3,), (5,), (7,), (9,), (3, 3)]:  # odd order
        inv = involutions(moduli)
        print(f"  G = Z/{ 'x'.join(map(str, moduli)) :<7}  |G|={_order(moduli):>2}  "
              f"odd  -> involutions: {inv}  (expect none)")
        assert inv == []
    for moduli in [(2,), (4,), (6,), (2, 2)]:  # even order
        inv = involutions(moduli)
        print(f"  G = Z/{ 'x'.join(map(str, moduli)) :<7}  |G|={_order(moduli):>2}  "
              f"even -> involutions: {inv}  (expect some)")
        assert inv != []

    banner("2. expectedHom_injective + guaranteed doubling (|Aut(B)| >= 2|Aut(X)|)")
    examples = [
        ((3,), frozenset({(1,)})),            # directed triangle
        ((5,), frozenset({(1,)})),            # directed pentagon
        ((5,), frozenset({(1,), (4,)})),      # undirected 5-cycle
        ((7,), frozenset({(1,), (6,)})),      # undirected 7-cycle
    ]
    for moduli, S in examples:
        inj = check_expected_hom_injective(S, moduli)
        a = len(aut_cayley(S, moduli))
        b = aut_double_cover(S, moduli)
        print(f"  G=Z/{moduli[0]} S={set(S)}: injective={inj}, "
              f"|Aut(X)|={a}, |Aut(B)|={b}, 2|Aut(X)|={2*a}, "
              f"|Aut(B)|>=2|Aut(X)|: {b >= 2 * a}")
        assert inj and b >= 2 * a

    banner("3. dcCayleyIso : the double cover is itself a Cayley digraph")
    for moduli, S in examples:
        ok = check_dc_cayley_iso(S, moduli)
        print(f"  G=Z/{moduli[0]} S={set(S)}: "
              f"Cay(G,S)(x)K2 == Cay(G x Z/2, S x {{1}})  -> {ok}")
        assert ok

    banner("4. Stability decision (stable <=> |Aut(B)| = 2|Aut(X)|)")
    for moduli, S in examples:
        stable, a, b = is_stable(S, moduli)
        parity = "odd" if _order(moduli) % 2 else "even"
        print(f"  G=Z/{moduli[0]} ({parity}) S={set(S)}: "
              f"|Aut(X)|={a}, |Aut(B)|={b} -> stable={stable}")

    banner("5. Even-order instability witness (odd hypothesis is necessary)")
    # Z/6 with a symmetric connection set: harbours the involution 3.
    moduli, S = (6,), frozenset({(1,), (5,)})
    stable, a, b = is_stable(S, moduli)
    print(f"  G=Z/6 S={set(S)} contains involution {involutions(moduli)}")
    print(f"  |Aut(X)|={a}, |Aut(B)|={b}, 2|Aut(X)|={2*a} -> stable={stable}")
    print("  (b > 2a signals an unexpected, layer-mixing automorphism.)")

    print("\nAll assertions passed.")


def _order(moduli: Sequence[int]) -> int:
    o = 1
    for m in moduli:
        o *= m
    return o


if __name__ == "__main__":
    main()
