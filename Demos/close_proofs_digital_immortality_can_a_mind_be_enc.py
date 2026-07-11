"""
Numerical demonstrations of the information-theoretic limits of mind encoding.

Self-contained: every helper is inlined; only the Python standard library is used.
Run with `python3 demo.py`.

The model treats a "mind" as a connectome on N neurons: a Boolean (or w-weighted,
or directed) assignment over the potential synapses among the neurons. We
demonstrate:

  1. Exact state counts    2^C(N,2), w^C(N,2), 2^(N(N-1)).
  2. Superadditivity       C(M+N,2) = C(M,2) + C(N,2) + M*N.
  3. Incompressibility     at most B minds get a codeword < B (pigeonhole).
  4. Bekenstein ceiling    N <= 1 + sqrt(2*I).
"""

from __future__ import annotations

import math
from typing import Iterable, List, Tuple


# --------------------------------------------------------------------------
# Core combinatorial quantities
# --------------------------------------------------------------------------
def synapse_slots(n: int) -> int:
    """Number of undirected synapse slots among n neurons: C(n, 2)."""
    return n * (n - 1) // 2


def directed_slots(n: int) -> int:
    """Number of directed synapse slots among n neurons: n(n-1) = 2*C(n,2)."""
    return n * (n - 1)


def connectome_count(n: int, weights: int = 2, directed: bool = False) -> int:
    """Exact number of distinguishable connectomes.

    Boolean:  2^C(n,2)          (weights=2, directed=False)
    Weighted: w^C(n,2)          (weights=w)
    Directed: (weights)^(n(n-1)) (directed=True); Boolean directed => (2^C(n,2))^2.
    """
    slots = directed_slots(n) if directed else synapse_slots(n)
    return weights ** slots


def description_bits(n: int, weights: int = 2, directed: bool = False) -> float:
    """Minimum description length in bits: slots * log2(weights)."""
    slots = directed_slots(n) if directed else synapse_slots(n)
    return slots * math.log2(weights)


# --------------------------------------------------------------------------
# Merging law
# --------------------------------------------------------------------------
def merge_breakdown(sizes: Iterable[int]) -> Tuple[int, int, int]:
    """Return (total_slots, internal_slots, cross_slots) for merged brains.

    Verifies C(sum N_i, 2) = sum C(N_i,2) + sum_{i<j} N_i N_j.
    """
    sizes = list(sizes)
    total = synapse_slots(sum(sizes))
    internal = sum(synapse_slots(n) for n in sizes)
    cross = (sum(sizes) ** 2 - sum(n * n for n in sizes)) // 2
    return total, internal, cross


# --------------------------------------------------------------------------
# Incompressibility (pigeonhole)
# --------------------------------------------------------------------------
def incompressible_count(n: int, threshold_bits: int) -> Tuple[int, int]:
    """Under any injective code, how many of the 2^C(n,2) minds must get a
    codeword of value >= B, where B = 2^threshold_bits?

    Returns (total_minds, guaranteed_incompressible) = (2^s, 2^s - B).
    """
    s = synapse_slots(n)
    total = 2 ** s
    b = 2 ** threshold_bits
    return total, max(total - b, 0)


# --------------------------------------------------------------------------
# Bekenstein physical ceiling
# --------------------------------------------------------------------------
def bekenstein_bits(radius: float, energy: float,
                    hbar: float = 1.054571817e-34,
                    c: float = 299792458.0) -> float:
    """Bekenstein information bound in bits: 2*pi*R*E / (hbar * c * ln 2)."""
    return 2 * math.pi * radius * energy / (hbar * c * math.log(2))


def neuron_ceiling(info_bits: float) -> float:
    """Closed-form upper bound on neuron count: 1 + sqrt(2 * I)."""
    return 1 + math.sqrt(2 * info_bits)


def max_storable_neurons(info_bits: float) -> int:
    """Largest integer N with C(N,2) <= info_bits (closed form + correction)."""
    n = int(neuron_ceiling(info_bits))
    while n > 0 and synapse_slots(n) > info_bits:
        n -= 1
    while synapse_slots(n + 1) <= info_bits:
        n += 1
    return n


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_state_counts() -> None:
    print("=" * 68)
    print("1. STATE COUNTS")
    print("=" * 68)
    for n in (5, 10, 20):
        s = synapse_slots(n)
        print(f"  N={n:3d}: slots C(N,2)={s:4d}, "
              f"Boolean minds 2^{s} = {connectome_count(n)}")
    print(f"  Weighted (w=4), N=5: 4^{synapse_slots(5)} = "
          f"{connectome_count(5, weights=4)}")
    # Directionality squares the count.
    n = 4
    undirected = connectome_count(n)
    directed = connectome_count(n, directed=True)
    print(f"  N={n}: directed {directed} = (undirected {undirected})^2 "
          f"-> {directed == undirected ** 2}")


def demo_merge() -> None:
    print("=" * 68)
    print("2. SUPERADDITIVITY OF MERGING")
    print("=" * 68)
    for sizes in [(3, 4), (10, 10), (5, 7, 9)]:
        total, internal, cross = merge_breakdown(sizes)
        print(f"  brains {sizes}: total slots={total} = internal {internal} "
              f"+ cross {cross}  (check {total == internal + cross})")


def demo_incompressible() -> None:
    print("=" * 68)
    print("3. INCOMPRESSIBILITY (pigeonhole)")
    print("=" * 68)
    for n in (5, 6):
        s = synapse_slots(n)
        total, incomp = incompressible_count(n, threshold_bits=s - 1)
        frac = incomp / total
        print(f"  N={n}: of {total} minds, >= {incomp} resist compression "
              f"below {s-1} bits  (fraction {frac:.3f})")


def demo_bekenstein() -> None:
    print("=" * 68)
    print("4. BEKENSTEIN NEURON CEILING")
    print("=" * 68)
    # Human-brain-scale region: radius ~0.1 m, energy ~ E=mc^2 for ~1.4 kg.
    radius = 0.1  # metres
    mass = 1.4    # kg
    c = 299792458.0
    energy = mass * c * c
    info = bekenstein_bits(radius, energy)
    print(f"  Region R={radius} m, mass={mass} kg -> I = {info:.3e} bits")
    print(f"  Closed-form ceiling N <= 1 + sqrt(2I) = {neuron_ceiling(info):.3e}")
    print(f"  Exact max integer N with C(N,2) <= I : {max_storable_neurons(info):,}")
    print("  (For comparison, the human brain has ~8.6e10 neurons.)")


def main() -> None:
    demo_state_counts()
    demo_merge()
    demo_incompressible()
    demo_bekenstein()


if __name__ == "__main__":
    main()
