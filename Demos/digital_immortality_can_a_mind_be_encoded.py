"""
Digital Immortality: Information-Theoretic Bounds on Mind Uploading
==================================================================

Self-contained numerical demonstrations of the main results:

  1. synapse_slots(N) = C(N, 2) = N(N-1)/2               (slot count)
  2. connectome_state_count(N) = 2 ** C(N, 2)            (state space size)
  3. The quadratic sandwich   (N-1)^2 <= 2*slots <= N^2
  4. Minimum-description-length / incompressibility (pigeonhole)
  5. The Bekenstein energy-radius lower bound and its quadratic form

Everything is inlined; no third-party dependencies are required.
Run with:  python demo.py
"""

from __future__ import annotations

import math

# --- Physical constants (SI units) -----------------------------------------
HBAR: float = 1.054_571_817e-34   # reduced Planck constant, J*s
C: float = 2.997_924_58e8         # speed of light, m/s
LN2: float = math.log(2.0)
PI: float = math.pi


# --- Combinatorial core -----------------------------------------------------
def synapse_slots(n: int) -> int:
    """Number of potential undirected synapses among n neurons: C(n, 2)."""
    return n * (n - 1) // 2


def connectome_state_count(n: int) -> int:
    """Exact number of distinct connectomes on n neurons: 2 ** C(n, 2)."""
    return 1 << synapse_slots(n)  # 2 ** slots, exact big-integer


def quadratic_sandwich(n: int) -> tuple[int, int, int]:
    """Return ((n-1)^2, 2*slots, n^2); the identity (n-1)^2 <= 2*slots <= n^2."""
    slots = synapse_slots(n)
    lower = max(n - 1, 0) ** 2  # truncated (natural-number) subtraction
    upper = n ** 2
    return lower, 2 * slots, upper


# --- Minimum description length / incompressibility -------------------------
def min_description_bits(n: int) -> int:
    """Worst-case minimum lossless description length of an n-neuron mind, in bits.

    By the pigeonhole principle any injective code assigns some connectome a
    codeword of at least C(n, 2) bits.
    """
    return synapse_slots(n)


def max_compressible_codewords(n: int) -> int:
    """Largest codeword-set size that is provably too small for lossless coding.

    No injective encoding exists into fewer than 2 ** C(n, 2) codewords.
    """
    return connectome_state_count(n) - 1


# --- Physics: the Bekenstein bound -----------------------------------------
def bekenstein_bits(radius: float, energy: float,
                    hbar: float = HBAR, c: float = C) -> float:
    """Bekenstein information capacity (bits) of a region of given radius/energy."""
    return 2.0 * PI * radius * energy / (hbar * c * LN2)


def energy_radius_lower_bound(n: int) -> float:
    """Lower bound on R*E (J*m) required to store an n-neuron mind.

    (hbar * c * ln2 / (2*pi)) * slots  <=  R * E
    """
    return HBAR * C * LN2 / (2.0 * PI) * synapse_slots(n)


def energy_radius_quadratic_bound(n: int) -> float:
    """Quadratic form of the physical lower bound on R*E.

    (hbar * c * ln2 / (4*pi)) * (n-1)^2  <=  R * E    (for n >= 1)
    """
    return HBAR * C * LN2 / (4.0 * PI) * (n - 1) ** 2


# --- Demonstrations ---------------------------------------------------------
def demo_state_counts() -> None:
    print("=" * 68)
    print("State counts: slots = C(N,2), states = 2 ** slots")
    print("=" * 68)
    for n in (2, 5, 10, 100, 1000):
        slots = synapse_slots(n)
        # number of decimal digits of 2**slots, without building the integer
        digits = int(slots * math.log10(2.0)) + 1
        print(f"  N={n:>5}: slots={slots:>10}   states=2^{slots} "
              f"(~{digits} decimal digits)")
    print()


def demo_sandwich() -> None:
    print("=" * 68)
    print("Quadratic sandwich:  (N-1)^2 <= 2*slots <= N^2")
    print("=" * 68)
    for n in range(0, 8):
        lo, mid, hi = quadratic_sandwich(n)
        ok = lo <= mid <= hi
        print(f"  N={n}: {lo:>3} <= {mid:>3} <= {hi:>3}   [{'OK' if ok else 'FAIL'}]")
    print()


def demo_incompressibility() -> None:
    print("=" * 68)
    print("Incompressibility: some mind needs the full slot-count of bits")
    print("=" * 68)
    for n in (5, 50, 500):
        bits = min_description_bits(n)
        digits = int(bits * math.log10(2.0)) + 1
        print(f"  N={n:>4}: >= {bits} bits required; no code fits in "
              f"2^{bits}-1 = (a ~{digits}-digit number) codewords")
    print()


def demo_physics() -> None:
    print("=" * 68)
    print("Bekenstein energy-radius lower bound on any storage device")
    print("=" * 68)
    for n in (1000, 10 ** 6, 86_000_000_000):
        re_lin = energy_radius_lower_bound(n)
        re_quad = energy_radius_quadratic_bound(n)
        print(f"  N={n:>14}: R*E >= {re_lin:.3e} J*m  "
              f"(quadratic form: {re_quad:.3e} J*m)")
    print()
    # Sanity check: a 1 m region holding 1 kg of energy-equivalent mass.
    energy = 1.0 * C ** 2  # E = m c^2 for m = 1 kg
    cap = bekenstein_bits(radius=1.0, energy=energy)
    print(f"  A 1 m sphere with 1 kg rest-energy can hold ~{cap:.3e} bits,")
    print(f"  enough for a connectome of up to N ~ "
          f"{int(math.isqrt(int(2 * cap)))} neurons (presence/absence model).")
    print()


def main() -> None:
    demo_state_counts()
    demo_sandwich()
    demo_incompressibility()
    demo_physics()


if __name__ == "__main__":
    main()
