"""
Algorithms for Digital Immortality: Information-Theoretic Bounds on Mind Encoding

Type-hinted implementations of the key algorithms from the formalization.
"""

from typing import List, Tuple, Set, Optional
import math


def connectome_space_size(n: int) -> int:
    """
    Compute the number of distinct directed connectomes on n neurons.
    Each ordered pair (i, j) of neurons can have or not have a synapse.
    
    Returns 2^(n^2).
    """
    return 2 ** (n * n)


def mind_encoding_bound(n: int) -> int:
    """
    Minimum number of bits needed to encode all distinct connectomes on n neurons.
    This is log2 of the connectome space size = n^2.
    """
    return n * n


def bekenstein_capacity(radius: float, energy: float, 
                         hbar: float = 1.0546e-34,
                         c: float = 3e8,
                         ln2: float = 0.6931) -> float:
    """
    Bekenstein bound: maximum information (in bits) storable in a sphere
    of given radius and energy.
    
    S_max = 2 * pi * R * E / (hbar * c * ln2)
    """
    return 2 * math.pi * radius * energy / (hbar * c * ln2)


def max_neurons_for_capacity(capacity_bits: float) -> int:
    """
    Given a storage capacity in bits, compute the maximum number of neurons
    whose full connectome can be faithfully encoded.
    
    Since encoding requires n^2 bits, max neurons = floor(sqrt(capacity)).
    """
    return int(math.sqrt(capacity_bits))


def compression_ratio(n: int, target_bits: int) -> float:
    """
    Compute the compression ratio: target_bits / mind_encoding_bound(n).
    A ratio < 1 means lossy compression (some connectomes will be lost).
    """
    bound = mind_encoding_bound(n)
    if bound == 0:
        return float('inf')
    return target_bits / bound


def synapse_count(connectome: List[List[bool]]) -> int:
    """
    Count the number of synapses (True entries) in a connectome matrix.
    """
    return sum(1 for row in connectome for val in row if val)


def simulation_fidelity(mapping: dict) -> int:
    """
    Compute simulation fidelity: the number of distinct output values.
    This is |image(mapping)|.
    """
    return len(set(mapping.values()))


def composition_fidelity(f: dict, g: dict) -> Tuple[int, int]:
    """
    Compute fidelity of f and g∘f, demonstrating the data processing inequality.
    Returns (fidelity_f, fidelity_gf).
    """
    fid_f = len(set(f.values()))
    gf = {k: g.get(v) for k, v in f.items() if v in g}
    fid_gf = len(set(gf.values()))
    return fid_f, fid_gf


def incompressible_fraction(n: int, k: int) -> float:
    """
    Fraction of n-neuron connectomes that are k-incompressible
    (require at least n^2 - k bits to describe).
    
    At most 2^(n^2 - k) - 1 programs of length < n^2 - k exist,
    so at least 1 - 2^(-k) / (1 - 2^(-n^2)) fraction are incompressible.
    
    For large n, this approaches 1 - 2^(-k).
    """
    total = 2 ** (n * n)
    short_programs = 2 ** (n * n - k) - 1
    if total == 0:
        return 0.0
    return 1.0 - short_programs / total


def neuron_scaling_cost(n: int) -> int:
    """
    Additional bits needed when going from n to n+1 neurons.
    This is 2n + 1 (the marginal cost of one extra neuron).
    """
    return 2 * n + 1


def digital_immortality_gap(n: int, capacity_bits: int) -> int:
    """
    The gap between required encoding bits and available capacity.
    Positive means faithful encoding is impossible.
    """
    return mind_encoding_bound(n) - capacity_bits


# Human brain parameters
HUMAN_NEURONS = 86_000_000_000  # ~86 billion neurons
HUMAN_SYNAPSES = 150_000_000_000_000  # ~150 trillion synapses
BRAIN_RADIUS = 0.075  # meters (7.5 cm radius)
BRAIN_ENERGY = 20.0  # watts (average power consumption)
BRAIN_REST_MASS_ENERGY = 1.4 * 9e16  # ~1.4 kg * c^2 in joules


if __name__ == "__main__":
    print("=== Digital Immortality: Key Computations ===\n")
    
    # Small examples
    for n in [2, 3, 4, 5, 10]:
        size = connectome_space_size(n)
        bits = mind_encoding_bound(n)
        print(f"n={n}: {size:,} connectomes, {bits} bits needed")
    
    print(f"\n=== Human Brain Scale ===")
    n = HUMAN_NEURONS
    bits = mind_encoding_bound(n)
    print(f"Neurons: {n:,}")
    print(f"Bits needed for full connectome: ~10^{math.log10(bits):.1f}")
    print(f"  (= {n}^2 = {bits:.2e} bits)")
    
    # Bekenstein bound for the brain
    bek = bekenstein_capacity(BRAIN_RADIUS, BRAIN_REST_MASS_ENERGY)
    print(f"\nBekenstein capacity of brain: ~{bek:.2e} bits")
    max_n = max_neurons_for_capacity(bek)
    print(f"Max neurons for faithful connectome encoding: ~{max_n:.2e}")
    
    print(f"\n=== Scaling Law ===")
    for n in range(1, 11):
        cost = neuron_scaling_cost(n)
        print(f"  n={n} → n={n+1}: +{cost} bits")
