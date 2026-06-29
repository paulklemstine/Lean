"""
demo.py — Numerical demonstrations for
"One-Way Functions: Existence, Inversion Capacity, and the Hardness Hierarchy"

This script empirically illustrates the formally verified theorems:

  1. exists_weakInverse / not_infoTheoreticOneWay
       Every function over a nonempty (finite) domain admits a weak inverse g
       with f(g(f(x))) = f(x) for all x. Hence no function is
       information-theoretically one-way: a resource-unbounded attacker
       (a precomputed lookup table) always recovers SOME preimage.

  2. weakInverse_inverts_all
       A weak inverter succeeds on every one of the |domain| inputs.

  3. exact_inversions_le_image  and  invFun_exact_inversions
       Any inverter recovers AT MOST |Im f| inputs EXACTLY (g(f(x)) = x);
       the canonical inverter attains exactly |Im f|.

  4. capacity-as-collision-deficit (Corollary 5.4)
       |Im f| = |domain| - sum_y (|fiber y| - 1).

  5. Order structure of the hierarchy OWF < PRG < PRF < ENC:
       rank injective, total order, OWF least, ENC greatest.

Everything is self-contained: pure standard-library Python, fully type hinted.
Run:  python demo.py
"""

from __future__ import annotations

from collections import defaultdict
from itertools import product
from typing import Callable, Dict, Hashable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core constructions over a finite domain
# ---------------------------------------------------------------------------

def image(domain: Sequence[Hashable], f: Callable[[Hashable], Hashable]) -> set:
    """The image (set of distinct outputs) of f over `domain`."""
    return {f(x) for x in domain}


def fibers(
    domain: Sequence[Hashable], f: Callable[[Hashable], Hashable]
) -> Dict[Hashable, List[Hashable]]:
    """Map each output value y to the list of inputs x with f(x) = y."""
    fib: Dict[Hashable, List[Hashable]] = defaultdict(list)
    for x in domain:
        fib[f(x)].append(x)
    return dict(fib)


def canonical_weak_inverse(
    domain: Sequence[Hashable], f: Callable[[Hashable], Hashable]
) -> Callable[[Hashable], Hashable]:
    """
    The canonical weak inverse (the analogue of Lean's `Function.invFun f`).

    Precompute, for each output y that f actually produces, ONE input mapping
    to it (the first encountered). The returned function looks up that input;
    for unseen outputs it falls back to a fixed default element of `domain`.
    """
    if len(domain) == 0:
        raise ValueError("domain must be nonempty (Nonempty alpha)")
    table: Dict[Hashable, Hashable] = {}
    for x in domain:
        y = f(x)
        if y not in table:
            table[y] = x  # first preimage wins
    default: Hashable = domain[0]
    return lambda y: table.get(y, default)


def is_weak_inverse(
    domain: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
    g: Callable[[Hashable], Hashable],
) -> bool:
    """Check the weak-inverse invariant f(g(f(x))) = f(x) for all x."""
    return all(f(g(f(x))) == f(x) for x in domain)


def weak_success_count(
    domain: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
    g: Callable[[Hashable], Hashable],
) -> int:
    """Number of inputs x on which weak inversion succeeds: f(g(f(x))) = f(x)."""
    return sum(1 for x in domain if f(g(f(x))) == f(x))


def exact_inversions(
    domain: Sequence[Hashable],
    f: Callable[[Hashable], Hashable],
    g: Callable[[Hashable], Hashable],
) -> List[Hashable]:
    """Inputs recovered EXACTLY by g: those x with g(f(x)) = x."""
    return [x for x in domain if g(f(x)) == x]


def collision_deficit(
    domain: Sequence[Hashable], f: Callable[[Hashable], Hashable]
) -> int:
    """sum_y (|fiber y| - 1) over the image: total excess of inputs over outputs."""
    return sum(len(xs) - 1 for xs in fibers(domain, f).values())


# ---------------------------------------------------------------------------
# The cryptographic hardness hierarchy as an order
# ---------------------------------------------------------------------------

CRYPTO_LEVELS: Tuple[str, str, str, str] = ("OWF", "PRG", "PRF", "ENC")
RANK: Dict[str, int] = {"OWF": 0, "PRG": 1, "PRF": 2, "ENC": 3}


def implies(a: str, b: str) -> bool:
    """`a` is implied by `b` (b at least as strong): rank a <= rank b.

    Matches the Lean convention `A <= B  <->  rank A <= rank B`."""
    return RANK[a] <= RANK[b]


def rank_injective() -> bool:
    """Distinct levels have distinct ranks."""
    return len({RANK[l] for l in CRYPTO_LEVELS}) == len(CRYPTO_LEVELS)


def order_is_total() -> bool:
    """For all pairs, a<=b or b<=a."""
    return all(implies(a, b) or implies(b, a) for a in CRYPTO_LEVELS for b in CRYPTO_LEVELS)


def least_element() -> str:
    return min(CRYPTO_LEVELS, key=lambda l: RANK[l])


def greatest_element() -> str:
    return max(CRYPTO_LEVELS, key=lambda l: RANK[l])


# ---------------------------------------------------------------------------
# Brute-force optimum over ALL inverters (validates the sharp bound)
# ---------------------------------------------------------------------------

def max_exact_inversions_bruteforce(
    domain: Sequence[Hashable], f: Callable[[Hashable], Hashable]
) -> int:
    """
    Exhaustively maximize |exact_inversions| over EVERY possible inverter
    g: codomain -> domain. Returns the optimum, which the theory predicts to
    equal |Im f|. (Feasible only for tiny domains; used as a sanity check.)
    """
    outs: List[Hashable] = sorted(image(domain, f), key=repr)
    dom: List[Hashable] = list(domain)
    best = 0
    # A g is a choice of a domain element for each output value in the image.
    for choice in product(dom, repeat=len(outs)):
        g_table = dict(zip(outs, choice))
        g = lambda y, _t=g_table, _d=dom[0]: _t.get(y, _d)
        best = max(best, len(exact_inversions(domain, f, g)))
    return best


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_weak_inverse() -> None:
    banner("DEMO 1 — Weak inverse always exists; no info-theoretic one-wayness")
    domain: List[int] = list(range(8))
    # A lossy function: collapses x to x mod 3  (image = {0,1,2}, many collisions)
    f: Callable[[int], int] = lambda x: x % 3
    g = canonical_weak_inverse(domain, f)
    print(f"domain = {domain}")
    print(f"f(x) = x mod 3 ; image = {sorted(image(domain, f))}")
    print("weak-inverse table (output -> chosen preimage):")
    for y in sorted(image(domain, f)):
        print(f"    g({y}) = {g(y)}   (check f(g({y})) = {f(g(y))})")
    ok = is_weak_inverse(domain, f, g)
    print(f"is_weak_inverse(f, g)?  {ok}   <-  invFun_weakInverse / exists_weakInverse")
    print(f"weak successes = {weak_success_count(domain, f, g)} of {len(domain)}"
          f"   <-  weakInverse_inverts_all (all inputs!)")
    assert ok and weak_success_count(domain, f, g) == len(domain)


def demo_exact_capacity() -> None:
    banner("DEMO 2 — Exact-inversion capacity = |Im f| (sharp upper bound)")
    domain: List[int] = list(range(6))
    f: Callable[[int], int] = lambda x: x % 4  # image {0,1,2,3}; collisions on 0,1
    g = canonical_weak_inverse(domain, f)
    im = len(image(domain, f))
    exact = exact_inversions(domain, f, g)
    print(f"domain = {domain}, f(x) = x mod 4")
    print(f"|Im f| = {im}")
    print(f"exact inversions by canonical inverter = {sorted(exact)} "
          f"(count {len(exact)})")
    print(f"  -> invFun_exact_inversions: count == |Im f|?  {len(exact) == im}")
    brute = max_exact_inversions_bruteforce(domain, f)
    print(f"  -> exact_inversions_le_image: brute-force max over ALL g = {brute}")
    print(f"     equals |Im f|?  {brute == im}  (bound is achieved and tight)")
    assert len(exact) == im == brute


def demo_collision_deficit() -> None:
    banner("DEMO 3 — Capacity as collision deficit:  |Im f| = |dom| - deficit")
    cases: List[Tuple[str, List[int], Callable[[int], int]]] = [
        ("injective  f(x)=x", list(range(5)), lambda x: x),
        ("mod 3      f(x)=x%3", list(range(9)), lambda x: x % 3),
        ("constant   f(x)=0", list(range(7)), lambda x: 0),
    ]
    for name, dom, f in cases:
        im = len(image(dom, f))
        deficit = collision_deficit(dom, f)
        rhs = len(dom) - deficit
        print(f"{name:22s}: |dom|={len(dom)}, |Im f|={im}, "
              f"deficit={deficit}, |dom|-deficit={rhs}  match={im == rhs}")
        assert im == rhs


def demo_hierarchy_order() -> None:
    banner("DEMO 4 — The hardness hierarchy is a total order with extrema")
    print("levels:", CRYPTO_LEVELS, " ranks:", [RANK[l] for l in CRYPTO_LEVELS])
    print(f"rank injective?      {rank_injective()}      <- rank_injective")
    print(f"order total?         {order_is_total()}      <- level_total")
    print(f"least element  = {least_element()}        <- owf_weakest")
    print(f"greatest element = {greatest_element()}      <- enc_strongest")
    print("implication matrix (row implied by col):")
    print("        " + "  ".join(f"{c:>3}" for c in CRYPTO_LEVELS))
    for a in CRYPTO_LEVELS:
        row = "  ".join(f"{'T' if implies(a, b) else '.':>3}" for b in CRYPTO_LEVELS)
        print(f"   {a:>3}  {row}")
    assert rank_injective() and order_is_total()
    assert least_element() == "OWF" and greatest_element() == "ENC"


def main() -> None:
    demo_weak_inverse()
    demo_exact_capacity()
    demo_collision_deficit()
    demo_hierarchy_order()
    banner("All demonstrations completed and assertions passed.")


if __name__ == "__main__":
    main()
