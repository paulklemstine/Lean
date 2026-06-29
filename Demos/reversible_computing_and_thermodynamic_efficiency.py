"""
Reversible Computing and Thermodynamic Efficiency — Numerical Demonstrations
===========================================================================

This self-contained script numerically demonstrates the results formalized in
`Catalog/Computation/LandauerLowerBound.lean` and the supporting catalog files:

  1. The deterministic data-processing inequality  H(f_*p) <= H(p).
  2. Equality H(f_*p) = H(p) exactly for injective (reversible) maps.
  3. Landauer's lower bound  W = k*T*(H(p) - H(f_*p)) >= 0.
  4. The exact erasure cost  k*T*n*log2  as the extremal collapse case.
  5. Universal reversible gates (CNOT, Toffoli, Fredkin): bijective, correct,
     and zero-dissipation on every input distribution.

Everything is inlined; only the Python standard library is used.

Run:  python demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

# Physical constants (SI).
BOLTZMANN_K: float = 1.380649e-23  # J / K
ROOM_T: float = 300.0              # K


# ----------------------------------------------------------------------------
# Core information-theoretic primitives (mirroring the Lean definitions)
# ----------------------------------------------------------------------------

def shannon_entropy(p: Sequence[float]) -> float:
    """Shannon entropy H(p) = -sum p_x log p_x (natural log), with 0 log 0 = 0."""
    total = 0.0
    for px in p:
        if px > 0.0:
            total -= px * math.log(px)
    return total


def pushforward(f: Callable[[Hashable], Hashable],
                support: Sequence[Hashable],
                p: Sequence[float]) -> Dict[Hashable, float]:
    """Image measure (f_*p)(y) = sum over the fiber {x : f(x) = y} of p(x)."""
    out: Dict[Hashable, float] = {}
    for x, px in zip(support, p):
        y = f(x)
        out[y] = out.get(y, 0.0) + px
    return out


def pushforward_entropy(f: Callable[[Hashable], Hashable],
                        support: Sequence[Hashable],
                        p: Sequence[float]) -> float:
    """H(f_*p): entropy of the pushforward distribution."""
    img = pushforward(f, support, p)
    return shannon_entropy(list(img.values()))


def landauer_work(f: Callable[[Hashable], Hashable],
                  support: Sequence[Hashable],
                  p: Sequence[float],
                  k: float = BOLTZMANN_K,
                  T: float = ROOM_T) -> float:
    """Dissipated work W = k*T*(H(p) - H(f_*p)) in joules."""
    return k * T * (shannon_entropy(p) - pushforward_entropy(f, support, p))


def is_injective(f: Callable[[Hashable], Hashable],
                 support: Sequence[Hashable]) -> bool:
    """Whether f is injective on the given support (reversible there)."""
    images = [f(x) for x in support]
    return len(set(images)) == len(images)


def random_distribution(n: int, rng: random.Random) -> List[float]:
    """A random probability vector of length n."""
    raw = [rng.random() + 1e-9 for _ in range(n)]
    s = sum(raw)
    return [r / s for r in raw]


# ----------------------------------------------------------------------------
# Demo 1: Data-processing inequality holds for arbitrary maps
# ----------------------------------------------------------------------------

def demo_data_processing_inequality(trials: int = 5) -> None:
    print("=" * 72)
    print("DEMO 1  Data-processing inequality:  H(f_*p) <= H(p)")
    print("=" * 72)
    rng = random.Random(2024)
    support = list(range(6))  # alpha = {0,...,5}

    # A non-injective map that merges fibers: x -> x mod 3.
    f = lambda x: x % 3
    print(f"Map f(x) = x mod 3 on support {support}  (non-injective).")
    print(f"{'p (random)':>10}   {'H(p)':>8}   {'H(f_*p)':>8}   {'gap>=0':>8}")
    for _ in range(trials):
        p = random_distribution(len(support), rng)
        hp = shannon_entropy(p)
        hfp = pushforward_entropy(f, support, p)
        gap = hp - hfp
        ok = "OK" if gap >= -1e-12 else "FAIL"
        print(f"{'':>10}   {hp:8.4f}   {hfp:8.4f}   {gap:8.4f} {ok}")
    print()


# ----------------------------------------------------------------------------
# Demo 2: Injective maps preserve entropy exactly (reversible => free)
# ----------------------------------------------------------------------------

def demo_injective_preserves_entropy(trials: int = 5) -> None:
    print("=" * 72)
    print("DEMO 2  Reversible (injective) maps preserve entropy exactly")
    print("=" * 72)
    rng = random.Random(7)
    support = list(range(6))

    # A bijection (relabeling): a fixed permutation.
    perm = [3, 0, 5, 1, 4, 2]
    g = lambda x: perm[x]
    print(f"Bijection g = {perm}  injective? {is_injective(g, support)}")
    print(f"{'H(p)':>10}   {'H(g_*p)':>10}   {'|diff|':>12}   {'work (J)':>14}")
    for _ in range(trials):
        p = random_distribution(len(support), rng)
        hp = shannon_entropy(p)
        hgp = pushforward_entropy(g, support, p)
        w = landauer_work(g, support, p)
        print(f"{hp:10.6f}   {hgp:10.6f}   {abs(hp-hgp):12.2e}   {w:14.2e}")
    print("  -> entropy identical to machine precision; dissipated work ~ 0.\n")


# ----------------------------------------------------------------------------
# Demo 3: Exact Landauer cost of erasing an n-bit register
# ----------------------------------------------------------------------------

def demo_exact_erasure_cost(max_bits: int = 6) -> None:
    print("=" * 72)
    print("DEMO 3  Exact Landauer cost of uniform n-bit erasure = k*T*n*log2")
    print("=" * 72)
    print(f"  (k = {BOLTZMANN_K:.6e} J/K, T = {ROOM_T} K)")
    print(f"{'n bits':>7}   {'H_uniform':>10}   {'predicted n*log2':>16}"
          f"   {'cost (J)':>14}   {'k*T*n*log2':>14}")
    for n in range(1, max_bits + 1):
        states = 2 ** n
        uniform = [1.0 / states] * states
        h = shannon_entropy(uniform)                 # = n * log 2
        predicted = n * math.log(2.0)
        # erasure collapses everything to a single point: H(f_*p) = 0.
        cost = BOLTZMANN_K * ROOM_T * (h - 0.0)
        cost_formula = BOLTZMANN_K * ROOM_T * n * math.log(2.0)
        print(f"{n:>7}   {h:10.6f}   {predicted:16.6f}"
              f"   {cost:14.4e}   {cost_formula:14.4e}")
    one_bit = BOLTZMANN_K * ROOM_T * math.log(2.0)
    print(f"\n  Single-bit limit at 300 K: k*T*log2 = {one_bit:.4e} J "
          f"= {one_bit / 1.602176634e-19:.4f} eV\n")


# ----------------------------------------------------------------------------
# Demo 4: Universal reversible gates - bijective, correct, zero dissipation
# ----------------------------------------------------------------------------

def cnot(a: int, b: int) -> Tuple[int, int]:
    """Controlled-NOT: (a, a XOR b)."""
    return (a, a ^ b)


def toffoli(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Controlled-controlled-NOT: (a, b, c XOR (a AND b))."""
    return (a, b, c ^ (a & b))


def fredkin(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Controlled-SWAP: swap (b, c) iff a = 1."""
    if a == 1:
        return (a, c, b)
    return (a, b, c)


def demo_reversible_gates() -> None:
    print("=" * 72)
    print("DEMO 4  Universal reversible gates: bijective + correct + free")
    print("=" * 72)

    # Verify each gate is an involution (hence a bijection).
    bits2 = list(itertools.product([0, 1], repeat=2))
    bits3 = list(itertools.product([0, 1], repeat=3))

    cnot_inv = all(cnot(*cnot(a, b)) == (a, b) for a, b in bits2)
    tof_inv = all(toffoli(*toffoli(a, b, c)) == (a, b, c) for a, b, c in bits3)
    fred_inv = all(fredkin(*fredkin(a, b, c)) == (a, b, c) for a, b, c in bits3)
    print(f"  CNOT    is an involution (self-inverse): {cnot_inv}")
    print(f"  Toffoli is an involution (self-inverse): {tof_inv}")
    print(f"  Fredkin is an involution (self-inverse): {fred_inv}")

    # Logical correctness.
    xor_ok = all(cnot(a, b)[1] == (a ^ b) for a, b in bits2)
    copy_ok = all(cnot(a, 0) == (a, a) for a in (0, 1))
    and_ok = all(toffoli(a, b, 0)[2] == (a & b) for a, b in bits2)
    not_ok = all(toffoli(1, 1, c)[2] == (1 - c) for c in (0, 1))
    swap_ok = all(fredkin(1, b, c) == (1, c, b) for b, c in bits2)
    print(f"  CNOT computes XOR:        {xor_ok}")
    print(f"  CNOT copies a bit (b=0):  {copy_ok}")
    print(f"  Toffoli computes AND:     {and_ok}")
    print(f"  Toffoli computes NOT:     {not_ok}")
    print(f"  Fredkin swaps on control: {swap_ok}")

    # Zero dissipation on a random input distribution.
    rng = random.Random(99)
    p2 = random_distribution(len(bits2), rng)
    p3 = random_distribution(len(bits3), rng)
    w_cnot = landauer_work(lambda x: cnot(*x), bits2, p2)
    w_tof = landauer_work(lambda x: toffoli(*x), bits3, p3)
    w_fred = landauer_work(lambda x: fredkin(*x), bits3, p3)
    print(f"  Dissipated work  CNOT:    {w_cnot:.3e} J")
    print(f"  Dissipated work  Toffoli: {w_tof:.3e} J")
    print(f"  Dissipated work  Fredkin: {w_fred:.3e} J")
    print("  -> all gates dissipate zero heat on every input distribution.\n")


# ----------------------------------------------------------------------------
# Demo 5: Erasure vs. reversal - the fiber picture
# ----------------------------------------------------------------------------

def demo_fiber_picture() -> None:
    print("=" * 72)
    print("DEMO 5  Fiber picture: fat fibers cost heat, thin fibers are free")
    print("=" * 72)
    support = list(range(8))
    p = [1.0 / 8] * 8  # uniform 3-bit register
    print(f"  Uniform 3-bit register, H(p) = {shannon_entropy(p):.4f} = 3*log2")
    print(f"{'map':>24}   {'max fiber':>10}   {'H(f_*p)':>9}   {'work (J)':>12}")
    maps = {
        "identity (reversible)": lambda x: x,
        "x -> x mod 4 (2->1)": lambda x: x % 4,
        "x -> x mod 2 (4->1)": lambda x: x % 2,
        "erase -> 0 (8->1)": lambda x: 0,
    }
    for name, f in maps.items():
        img = pushforward(f, support, p)
        # max fiber size:
        sizes: Dict[Hashable, int] = {}
        for x in support:
            y = f(x)
            sizes[y] = sizes.get(y, 0) + 1
        max_fiber = max(sizes.values())
        hfp = shannon_entropy(list(img.values()))
        w = landauer_work(f, support, p)
        print(f"{name:>24}   {max_fiber:>10}   {hfp:9.4f}   {w:12.3e}")
    print("  -> dissipation grows with fiber size; identity (thin) is free.\n")


def main() -> None:
    demo_data_processing_inequality()
    demo_injective_preserves_entropy()
    demo_exact_erasure_cost()
    demo_reversible_gates()
    demo_fiber_picture()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
