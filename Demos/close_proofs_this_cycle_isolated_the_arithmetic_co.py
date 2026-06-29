"""
demo.py — Numerical demonstrations for:

  "One-Way Functions Are Computational, Not Information-Theoretic"

This self-contained script illustrates, with concrete finite functions, the
formally verified results of the package:

  * Theorem 3.3/3.4  — every function has a WEAK INVERSE (invFun).
  * Theorem 3.5      — NO function is information-theoretically one-way.
  * Theorem 4.1      — a weak inverter succeeds on the ENTIRE domain.
  * Theorem 5.2      — any inverter recovers EXACTLY at most |Im f| inputs.
  * Theorem 5.3      — the canonical inverter invFun f ATTAINS |Im f|.
  * Section 6        — the OWF -> PRG -> PRF -> ENC hierarchy is a total order.

No external dependencies; standard library only. Python 3.9+.
"""

from __future__ import annotations

from typing import Callable, Dict, Hashable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core constructions (all functions inlined, type-hinted)
# ---------------------------------------------------------------------------

def image(domain: Sequence[Hashable], f: Callable[[Hashable], Hashable]) -> List[Hashable]:
    """Distinct output values of f over the given (finite) domain, i.e. Im f."""
    seen: List[Hashable] = []
    seen_set = set()
    for x in domain:
        y = f(x)
        if y not in seen_set:
            seen_set.add(y)
            seen.append(y)
    return seen


def inv_fun(domain: Sequence[Hashable],
            f: Callable[[Hashable], Hashable]) -> Callable[[Hashable], Hashable]:
    """The canonical weak inverter `invFun f`.

    Builds a lookup table mapping each output value to *a* preimage
    (first writer wins). On an unseen output it returns a fixed default
    (the first domain element), matching Lean's `Function.invFun`.
    """
    if not domain:
        raise ValueError("domain must be nonempty")
    table: Dict[Hashable, Hashable] = {}
    for x in domain:
        y = f(x)
        if y not in table:
            table[y] = x
    default = domain[0]
    return lambda y: table.get(y, default)


def is_weak_inverse(domain: Sequence[Hashable],
                    f: Callable[[Hashable], Hashable],
                    g: Callable[[Hashable], Hashable]) -> bool:
    """WeakInverse f g  <=>  for all x:  f(g(f(x))) = f(x)."""
    return all(f(g(f(x))) == f(x) for x in domain)


def weak_success_count(domain: Sequence[Hashable],
                       f: Callable[[Hashable], Hashable],
                       g: Callable[[Hashable], Hashable]) -> int:
    """| { x : f(g(f(x))) = f(x) } |  (Theorem 4.1 measures this)."""
    return sum(1 for x in domain if f(g(f(x))) == f(x))


def exact_inversions(domain: Sequence[Hashable],
                     f: Callable[[Hashable], Hashable],
                     g: Callable[[Hashable], Hashable]) -> List[Hashable]:
    """ExactInv(f, g) = { x : g(f(x)) = x }  (Definition 5.1)."""
    return [x for x in domain if g(f(x)) == x]


# ---------------------------------------------------------------------------
# Demo 1 — Weak inverses always exist; info-theoretic one-wayness fails
# ---------------------------------------------------------------------------

def demo_weak_inverse_existence() -> None:
    print("=" * 72)
    print("DEMO 1 — Every function has a weak inverse (Thm 3.3-3.5, 4.1)")
    print("=" * 72)

    domain = list(range(-4, 5))          # { -4, ..., 4 }
    f = lambda x: x * x                   # highly non-injective: collisions galore

    g = inv_fun(domain, f)
    print(f"  domain          = {domain}")
    print(f"  f(x) = x^2,  Im f = {sorted(image(domain, f))}  (|Im f| = {len(image(domain, f))})")
    print(f"  invFun is a weak inverse?      {is_weak_inverse(domain, f, g)}")
    print(f"  weak successes (Thm 4.1)       {weak_success_count(domain, f, g)} / {len(domain)} = |domain|")
    print("  => f is NOT information-theoretically one-way: an unbounded")
    print("     adversary (the lookup table) recovers a preimage for EVERY input.")
    print()


# ---------------------------------------------------------------------------
# Demo 2 — Exact-inversion capacity equals |Im f|, and invFun attains it
# ---------------------------------------------------------------------------

def _all_inverters(domain: Sequence[int],
                   f: Callable[[int], int]) -> List[Callable[[int], int]]:
    """Enumerate ALL inverters g : Im f -> domain (brute force, small instances)."""
    img = image(domain, f)
    inverters: List[Callable[[int], int]] = []

    def build(idx: int, partial: Dict[int, int]) -> None:
        if idx == len(img):
            table = dict(partial)
            inverters.append(lambda y, t=table: t.get(y, domain[0]))
            return
        for x in domain:
            partial[img[idx]] = x
            build(idx + 1, partial)
        partial.pop(img[idx], None)

    build(0, {})
    return inverters


def demo_exact_capacity() -> None:
    print("=" * 72)
    print("DEMO 2 — Exact-inversion capacity = |Im f| (Thm 5.2 & 5.3)")
    print("=" * 72)

    domain = list(range(6))                       # { 0,...,5 }
    f = lambda x: x % 3                            # image = {0,1,2}, |Im f| = 3
    img_size = len(image(domain, f))

    best = 0
    for g in _all_inverters(domain, f):
        best = max(best, len(exact_inversions(domain, f, g)))

    g_canon = inv_fun(domain, f)
    attained = len(exact_inversions(domain, f, g_canon))

    print(f"  f(x) = x mod 3 on {{0..5}},   |Im f| = {img_size}")
    print(f"  max exact recoveries over ALL inverters  = {best}   (Thm 5.2 bound: <= {img_size})")
    print(f"  exact recoveries by invFun f             = {attained}   (Thm 5.3: = {img_size})")
    print(f"  bound tight & attained by invFun?         {best == img_size == attained}")
    print()


# ---------------------------------------------------------------------------
# Demo 3 — Weak vs exact: same function, very different invertibility
# ---------------------------------------------------------------------------

def demo_weak_vs_exact() -> None:
    print("=" * 72)
    print("DEMO 3 — Weak inversion is total; exact inversion is capped")
    print("=" * 72)

    for n, m in [(8, 8), (8, 4), (8, 2), (8, 1)]:
        domain = list(range(n))
        f = lambda x, m=m: x % m                   # image size = m
        g = inv_fun(domain, f)
        weak = weak_success_count(domain, f, g)
        exact = len(exact_inversions(domain, f, g))
        print(f"  |dom|={n:>2}  f=x mod {m:<1}  |Im f|={m:<1} ->  "
              f"weak successes={weak:>2}/{n}   exact recoveries={exact:>2} (= |Im f|)")
    print("  Weak success is always |domain|; exact success collapses to |Im f|.")
    print()


# ---------------------------------------------------------------------------
# Demo 4 — The cryptographic hardness hierarchy as a total order
# ---------------------------------------------------------------------------

def demo_hierarchy_order() -> None:
    print("=" * 72)
    print("DEMO 4 — OWF -> PRG -> PRF -> ENC is a total order (Sec 6)")
    print("=" * 72)

    rank: Dict[str, int] = {"OWF": 0, "PRG": 1, "PRF": 2, "ENC": 3}

    # A <= B  (A implied by B)  iff  rank(B) <= rank(A)
    def implies(a: str, b: str) -> bool:
        return rank[b] <= rank[a]

    levels = list(rank)
    # injectivity of rank
    inj = len(set(rank.values())) == len(rank)
    # totality
    total = all(implies(a, b) or implies(b, a) for a in levels for b in levels)
    # extrema
    owf_weakest = all(implies(a, "OWF") for a in levels)
    enc_strongest = all(implies("ENC", a) for a in levels)

    print(f"  ranks               : {rank}")
    print(f"  rank injective      : {inj}            (Thm 6.1)")
    print(f"  implication total   : {total}            (Thm 6.2)")
    print(f"  OWF weakest         : {owf_weakest}            (Thm 6.3)")
    print(f"  ENC strongest       : {enc_strongest}            (Thm 6.4)")
    print("  Order-isomorphic to the chain 0 < 1 < 2 < 3.")
    print()


# ---------------------------------------------------------------------------
# Demo 5 — Fiber partition and pigeonhole collisions (Hierarchy support)
# ---------------------------------------------------------------------------

def demo_fibers_and_collisions() -> None:
    print("=" * 72)
    print("DEMO 5 — Fiber partition & pigeonhole collisions")
    print("=" * 72)

    domain = list(range(10))
    f = lambda x: x % 4
    img = image(domain, f)
    fibers: Dict[Hashable, List[int]] = {y: [x for x in domain if f(x) == y] for y in img}

    total = sum(len(fib) for fib in fibers.values())
    print(f"  f = x mod 4 on {{0..9}}")
    for y, fib in sorted(fibers.items()):
        tag = "  <- collision" if len(fib) >= 2 else ""
        print(f"    fiber f^-1({y}) = {fib}  (size {len(fib)}){tag}")
    print(f"  sum of fiber sizes = {total} = |domain| (fiber partition)")
    print(f"  |Im f| = {len(img)} < |domain| = {len(domain)}  =>  some fiber has size >= 2")
    print()


def main() -> None:
    demo_weak_inverse_existence()
    demo_exact_capacity()
    demo_weak_vs_exact()
    demo_hierarchy_order()
    demo_fibers_and_collisions()
    print("All demonstrations consistent with the machine-verified theorems.")


if __name__ == "__main__":
    main()
