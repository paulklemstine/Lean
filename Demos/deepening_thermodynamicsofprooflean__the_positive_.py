"""
demo.py -- The Kernel Law: an exact thermodynamics of structure-preserving inference.

This self-contained script numerically demonstrates the main results:

  * erasedBits(f) = log2(|domain|) - log2(|image f|)              (definition)
  * |image f| * |ker f| = |G|                                     (counting identity)
  * erasedBits(f) = log2(|ker f|)  for homomorphisms              (the Kernel Law)
  * erasedBits(f) = 0  iff  ker f trivial  iff  f injective       (reversibility)
  * erasedBits(G -> G/N) = log2(|N|)                              (quotient cost)
  * Landauer heat = erasedBits * kB * T * ln 2                    (physical cost)
  * erasedBits(g o f) = erasedBits(f) + erasedBits(g)  if f onto  (exact additivity)

Groups are represented concretely as finite lists of elements together with a
binary operation, so every quantity is computed by direct enumeration -- no
external libraries beyond the standard library.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Callable, Hashable, List, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)
C = TypeVar("C", bound=Hashable)

# Boltzmann constant (J/K) and a room-temperature reference.
K_B: float = 1.380649e-23
ROOM_T: float = 300.0


@dataclass(frozen=True)
class FiniteGroup:
    """A finite group given by its element list, operation, and identity."""

    elements: Sequence[A]
    op: Callable[[A, A], A]
    identity: A

    def order(self) -> int:
        return len(self.elements)


# --------------------------------------------------------------------------- #
# Core quantities
# --------------------------------------------------------------------------- #
def image_card(f: Callable[[A], B], domain: Sequence[A]) -> int:
    """Number of distinct outputs of f on the given (finite) domain."""
    return len({f(x) for x in domain})


def erased_bits(f: Callable[[A], B], domain: Sequence[A]) -> float:
    """Information erased by f: log2(|domain|) - log2(|image f|)."""
    n = len(domain)
    if n == 0:
        raise ValueError("domain must be nonempty")
    return math.log2(n) - math.log2(image_card(f, domain))


def landauer_cost(bits: float, k_b: float = K_B, temperature: float = ROOM_T) -> float:
    """Minimum heat (joules) dissipated to erase `bits` bits at temperature T."""
    return bits * k_b * temperature * math.log(2.0)


def kernel(f: Callable[[A], B], G: FiniteGroup, target_identity: B) -> List[A]:
    """Elements of G mapped to the target identity: ker f = f^{-1}(1)."""
    return [g for g in G.elements if f(g) == target_identity]


# --------------------------------------------------------------------------- #
# Concrete groups
# --------------------------------------------------------------------------- #
def cyclic_group(n: int) -> FiniteGroup:
    """Z/n under addition modulo n."""
    return FiniteGroup(
        elements=tuple(range(n)),
        op=lambda a, b: (a + b) % n,
        identity=0,
    )


def symmetric_group(n: int) -> FiniteGroup:
    """S_n as tuples that are permutations of (0,...,n-1); op is composition."""
    from itertools import permutations

    perms = tuple(permutations(range(n)))

    def compose(p: tuple, q: tuple) -> tuple:
        # (p . q)(i) = p[q[i]]
        return tuple(p[q[i]] for i in range(n))

    return FiniteGroup(elements=perms, op=compose, identity=tuple(range(n)))


def permutation_sign(p: Sequence[int]) -> int:
    """Sign of a permutation given in one-line notation: +1 (even) / -1 (odd)."""
    n = len(p)
    seen = [False] * n
    parity = 0
    for i in range(n):
        if seen[i]:
            continue
        length = 0
        j = i
        while not seen[j]:
            seen[j] = True
            j = p[j]
            length += 1
        parity += length - 1
    return -1 if parity % 2 else 1


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_counting_identity() -> None:
    print("=" * 70)
    print("1. Counting identity  |image f| * |ker f| = |G|")
    print("=" * 70)
    G = cyclic_group(12)
    f = lambda x: x % 4  # Z/12 -> Z/4 (reduction), a homomorphism
    img = image_card(f, G.elements)
    ker = kernel(f, G, target_identity=0)
    print(f"  G = Z/12,  f(x) = x mod 4")
    print(f"  |image f| = {img},  |ker f| = {len(ker)},  |G| = {G.order()}")
    print(f"  product   = {img * len(ker)}  (should equal |G| = {G.order()})")
    assert img * len(ker) == G.order()
    print("  OK\n")


def demo_kernel_law() -> None:
    print("=" * 70)
    print("2. The Kernel Law  erasedBits(f) = log2(|ker f|)")
    print("=" * 70)
    G = cyclic_group(12)
    f = lambda x: x % 4
    lhs = erased_bits(f, G.elements)
    rhs = math.log2(len(kernel(f, G, 0)))
    print(f"  erasedBits(f)   = {lhs:.6f} bits")
    print(f"  log2(|ker f|)   = {rhs:.6f} bits")
    assert math.isclose(lhs, rhs, rel_tol=1e-12)
    print(f"  Landauer heat   = {landauer_cost(lhs):.3e} J at T = {ROOM_T} K")
    print("  OK\n")


def demo_sign_homomorphism() -> None:
    print("=" * 70)
    print("3. A parity check erases almost everything  (sign: S_n -> {+-1})")
    print("=" * 70)
    for n in (3, 4):
        G = symmetric_group(n)
        f = permutation_sign
        bits = erased_bits(f, G.elements)
        ker = kernel(f, G, target_identity=1)  # A_n
        predicted = math.log2(len(ker))
        print(f"  n = {n}:  |S_n| = {G.order()},  |A_n| = |ker| = {len(ker)}")
        print(f"          erasedBits = {bits:.4f} = log2(|A_n|) = {predicted:.4f}")
        assert math.isclose(bits, predicted, rel_tol=1e-12)
    print("  OK\n")


def demo_reversibility() -> None:
    print("=" * 70)
    print("4. Reversibility:  erasedBits = 0  iff  kernel trivial  iff  injective")
    print("=" * 70)
    G = cyclic_group(5)
    iso = lambda x: (2 * x) % 5  # multiplication by a unit: an automorphism
    proj = lambda x: x % 1 if False else 0  # constant map (extreme collapse)
    b_iso = erased_bits(iso, G.elements)
    print(f"  automorphism x -> 2x mod 5:  erasedBits = {b_iso:.6f}  (reversible)")
    assert math.isclose(b_iso, 0.0, abs_tol=1e-12)
    G12 = cyclic_group(12)
    f = lambda x: x % 4
    print(f"  reduction  x -> x mod 4:     erasedBits = {erased_bits(f, G12.elements):.4f}  (lossy)")
    print("  OK\n")


def demo_quotient_cost() -> None:
    print("=" * 70)
    print("5. Quotient cost  erasedBits(G -> G/N) = log2(|N|)")
    print("=" * 70)
    # Z/12 -> Z/12 / <6>, where N = <6> = {0, 6} has order 2.
    G = cyclic_group(12)
    # Project onto cosets of N = {0,6}: represent a coset by x mod 6.
    proj = lambda x: x % 6
    ker = kernel(proj, G, target_identity=0)  # {0, 6}
    bits = erased_bits(proj, G.elements)
    print(f"  N = <6> = {sorted(ker)},  |N| = {len(ker)}")
    print(f"  erasedBits(pi) = {bits:.6f} = log2(|N|) = {math.log2(len(ker)):.6f}")
    assert math.isclose(bits, math.log2(len(ker)), rel_tol=1e-12)
    print("  OK\n")


def demo_exact_additivity() -> None:
    print("=" * 70)
    print("6. Exact additivity along a surjective pipeline")
    print("=" * 70)
    # f: Z/12 ->> Z/6 (reduction mod 6, surjective);  g: Z/6 -> Z/3 (mod 3).
    G = cyclic_group(12)
    f = lambda x: x % 6
    g = lambda y: y % 3
    gf = lambda x: g(f(x))
    b_f = erased_bits(f, G.elements)
    b_g = erased_bits(g, cyclic_group(6).elements)
    b_gf = erased_bits(gf, G.elements)
    print(f"  f: Z/12 -> Z/6  (surjective):  erasedBits(f)      = {b_f:.4f}")
    print(f"  g: Z/6  -> Z/3               :  erasedBits(g)      = {b_g:.4f}")
    print(f"  g o f                        :  erasedBits(g o f)  = {b_gf:.4f}")
    print(f"  sum of parts                 :  {b_f + b_g:.4f}")
    assert math.isclose(b_gf, b_f + b_g, rel_tol=1e-12)
    print("  exact additivity holds (surjective first stage)\n")

    # Contrast: when the first stage is NOT surjective, the second stage can
    # "re-lose" information that is invisible downstream, so erasure is only
    # sub-additive and the sum of parts strictly exceeds the composite.
    f2 = lambda x: (2 * x) % 12          # image = evens: not surjective onto Z/12
    # h collapses all ODD inputs (which f2 never produces) to 0, and is the
    # identity on evens; it therefore "charges" for erasing the odd half that
    # the composite never encounters.
    h = lambda y: 0 if y % 2 == 1 else y
    hf = lambda x: h(f2(x))
    b_f2 = erased_bits(f2, G.elements)
    b_h = erased_bits(h, cyclic_group(12).elements)
    b_hf = erased_bits(hf, G.elements)
    print(f"  NON-surjective first stage: erasedBits(h o f2) = {b_hf:.4f}")
    print(f"                              sum of parts       = {b_f2 + b_h:.4f}")
    print(f"  deficit (strict sub-additivity) = {b_f2 + b_h - b_hf:.4f} > 0\n")


def main() -> None:
    demo_counting_identity()
    demo_kernel_law()
    demo_sign_homomorphism()
    demo_reversibility()
    demo_quotient_cost()
    demo_exact_additivity()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
