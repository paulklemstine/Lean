"""
Numerical demonstrations for:

    A Fixed-Point Bridge for Intersecting Families of Permutations
    and a Large Extremal t-Intersecting Family

This self-contained script illustrates the main results:

  * The fixed-point bridge: the positions where two permutations agree are
    exactly the fixed points of the quotient sigma^{-1} tau.
  * The agreement-count identity: #agreements = n - |support(sigma^{-1} tau)|.
  * Intersecting  <=>  no pairwise quotient is a derangement.
  * The prefix stabilizer Fix_t is t-intersecting and has exactly (n-t)! = m!
    members.

Permutations are represented as tuples: perm[i] is the image of position i,
where positions and values range over {0, 1, ..., n-1}.
"""

from __future__ import annotations

from itertools import permutations
from math import factorial
from typing import Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]


# ---------------------------------------------------------------------------
# Basic permutation utilities
# ---------------------------------------------------------------------------
def identity(n: int) -> Perm:
    """The identity permutation of {0, ..., n-1}."""
    return tuple(range(n))


def compose(sigma: Perm, tau: Perm) -> Perm:
    """Function composition (sigma o tau)(i) = sigma(tau(i))."""
    return tuple(sigma[tau[i]] for i in range(len(sigma)))


def inverse(sigma: Perm) -> Perm:
    """The inverse permutation."""
    inv = [0] * len(sigma)
    for i, s in enumerate(sigma):
        inv[s] = i
    return tuple(inv)


def quotient(sigma: Perm, tau: Perm) -> Perm:
    """The quotient sigma^{-1} tau."""
    return compose(inverse(sigma), tau)


def support(pi: Perm) -> List[int]:
    """Points moved by pi (complement of its fixed points)."""
    return [i for i, p in enumerate(pi) if p != i]


def fixed_points(pi: Perm) -> List[int]:
    """Points fixed by pi."""
    return [i for i, p in enumerate(pi) if p == i]


def is_derangement(pi: Perm) -> bool:
    """A permutation with no fixed point."""
    return len(fixed_points(pi)) == 0


# ---------------------------------------------------------------------------
# Agreement sets and the fixed-point bridge
# ---------------------------------------------------------------------------
def agreements(sigma: Perm, tau: Perm) -> List[int]:
    """Positions where sigma and tau agree (direct comparison)."""
    return [i for i in range(len(sigma)) if sigma[i] == tau[i]]


def agreements_via_bridge(sigma: Perm, tau: Perm) -> List[int]:
    """Positions of agreement computed as fixed points of sigma^{-1} tau."""
    return fixed_points(quotient(sigma, tau))


def agreement_count_formula(sigma: Perm, tau: Perm) -> int:
    """n - |support(sigma^{-1} tau)|, by Corollary 3.3."""
    n = len(sigma)
    return n - len(support(quotient(sigma, tau)))


# ---------------------------------------------------------------------------
# Families: intersecting tests and the prefix stabilizer
# ---------------------------------------------------------------------------
def is_t_intersecting(family: Sequence[Perm], t: int) -> bool:
    """True iff every ordered pair agrees in at least t positions."""
    return all(len(agreements(s, u)) >= t for s in family for u in family)


def no_pairwise_derangement(family: Sequence[Perm]) -> bool:
    """True iff no pairwise quotient sigma^{-1} tau is a derangement."""
    return all(not is_derangement(quotient(s, u)) for s in family for u in family)


def prefix_stabilizer(t: int, m: int) -> List[Perm]:
    """
    All permutations of {0, ..., t+m-1} fixing each of the first t points.

    Built by permuting the last m points freely and prepending the identity
    on the first t points.  By Theorem 4.5 this family is t-intersecting and
    has exactly m! = (n-t)! members.
    """
    family: List[Perm] = []
    for tail in permutations(range(t, t + m)):
        family.append(tuple(range(t)) + tail)
    return family


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_bridge() -> None:
    print("=" * 70)
    print("Fixed-point bridge: agreements(sigma, tau) = fixed points of "
          "sigma^{-1} tau")
    print("=" * 70)
    sigma = (1, 2, 0)  # the 3-cycle (0 1 2)
    tau = (0, 2, 1)    # the transposition (1 2)
    q = quotient(sigma, tau)
    print(f"sigma           = {sigma}")
    print(f"tau             = {tau}")
    print(f"sigma^-1 tau    = {q}")
    print(f"agreements (direct) = {agreements(sigma, tau)}")
    print(f"agreements (bridge) = {agreements_via_bridge(sigma, tau)}")
    assert agreements(sigma, tau) == agreements_via_bridge(sigma, tau)
    print(f"count            = {len(agreements(sigma, tau))}")
    print(f"n - |support(q)| = {agreement_count_formula(sigma, tau)}")
    assert len(agreements(sigma, tau)) == agreement_count_formula(sigma, tau)
    print("Bridge and count identity verified.\n")


def demo_derangement_disagreement() -> None:
    print("=" * 70)
    print("Two permutations disagree everywhere  <=>  quotient is a derangement")
    print("=" * 70)
    sigma = (1, 2, 0)  # (0 1 2)
    tau = (2, 0, 1)    # (0 2 1)
    q = quotient(sigma, tau)
    print(f"sigma = {sigma}, tau = {tau}, quotient = {q}")
    print(f"agreements = {agreements(sigma, tau)} (empty if disagree everywhere)")
    print(f"quotient is derangement: {is_derangement(q)}\n")


def demo_prefix_stabilizer_counts() -> None:
    print("=" * 70)
    print("Prefix stabilizer Fix_t : size = (n-t)! = m!, and t-intersecting")
    print("=" * 70)
    for t, m in [(1, 2), (2, 2), (3, 0), (0, 3), (1, 3), (2, 3)]:
        n = t + m
        fam = prefix_stabilizer(t, m)
        expected = factorial(m)
        t_int = is_t_intersecting(fam, t)
        no_der = no_pairwise_derangement(fam) if t >= 1 else True
        print(f"t={t}, m={m}, n={n}: |Fix_t|={len(fam)}  "
              f"expected m!={expected}  "
              f"t-intersecting={t_int}  no-derangement-quotient={no_der}")
        assert len(fam) == expected
        assert t_int
    print("All prefix-stabilizer counts and intersecting properties verified.\n")


def demo_deza_frankl() -> None:
    print("=" * 70)
    print("Deza-Frankl lower bound (t=1): intersecting family of size (n-1)!")
    print("=" * 70)
    for n in range(1, 6):
        fam = prefix_stabilizer(1, n - 1)
        print(f"n={n}: |family|={len(fam)}  (n-1)!={factorial(n - 1)}  "
              f"intersecting={is_t_intersecting(fam, 1)}")
        assert len(fam) == factorial(n - 1)
        assert is_t_intersecting(fam, 1)
    print("Deza-Frankl lower bound realized for n = 1..5.\n")


def demo_exhaustive_bridge_check(n: int = 4) -> None:
    print("=" * 70)
    print(f"Exhaustive verification of the bridge over all of Sym({n})")
    print("=" * 70)
    perms = list(permutations(range(n)))
    ok = 0
    for s in perms:
        for u in perms:
            assert agreements(s, u) == agreements_via_bridge(s, u)
            assert len(agreements(s, u)) == agreement_count_formula(s, u)
            ok += 1
    print(f"Checked {ok} ordered pairs in Sym({n}); bridge holds for all.\n")


if __name__ == "__main__":
    demo_bridge()
    demo_derangement_disagreement()
    demo_prefix_stabilizer_counts()
    demo_deza_frankl()
    demo_exhaustive_bridge_check(4)
    print("All demonstrations completed successfully.")
