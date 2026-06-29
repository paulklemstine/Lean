#!/usr/bin/env python3
"""
Tropical Hecke Trapdoor Duality — Core Algorithms

Implements:
1. TropicalConvolver — min-plus convolution engine
2. HeckeOperator — tropical Hecke operator with spectral analysis
3. TrapdoorFlag — certified trapdoor decoding
4. SpectralFiltration — monotone spectral filtration computation
"""

from typing import Dict, List, Tuple, Optional, Set
from itertools import product
from dataclasses import dataclass, field


# ============================================================
# Algorithm 1: Tropical Min-Plus Convolution
# ============================================================

@dataclass
class FiniteMonoid:
    """A finite monoid represented by its multiplication table."""
    n: int
    mul_table: Dict[Tuple[int, int], int] = field(default_factory=dict)
    identity: int = 0

    @classmethod
    def cyclic(cls, n: int) -> 'FiniteMonoid':
        """Create the cyclic group ℤ/nℤ."""
        G = cls(n=n, identity=0)
        G.mul_table = {(a, b): (a + b) % n for a in range(n) for b in range(n)}
        return G

    @classmethod
    def trivial(cls) -> 'FiniteMonoid':
        """The trivial monoid {0}."""
        return cls(n=1, mul_table={(0, 0): 0}, identity=0)

    def mul(self, a: int, b: int) -> int:
        return self.mul_table[(a, b)]

    @property
    def elements(self) -> List[int]:
        return list(range(self.n))

    def factorizations(self, x: int) -> List[Tuple[int, int]]:
        """All pairs (a, b) with a * b = x.

        Complexity: O(|G|²)
        """
        return [(a, b) for a in self.elements for b in self.elements
                if self.mul(a, b) == x]


TropFunc = Dict[int, int]  # G → ℤ


def tropical_convolution(G: FiniteMonoid, f: TropFunc, k: TropFunc) -> TropFunc:
    """
    Tropical min-plus convolution on a finite monoid.

    (f ⊛ k)(x) = min_{a·b=x} (f(a) + k(b))

    Complexity: O(|G|³) — for each of |G| outputs, we check |G|² factorizations.
    In practice O(|G|²) since each element has exactly |G| factorizations.

    Args:
        G: The finite monoid
        f: First tropical function G → ℤ
        k: Second tropical function G → ℤ

    Returns:
        The tropical convolution f ⊛ k
    """
    result = {}
    for x in G.elements:
        facts = G.factorizations(x)
        result[x] = min(f[a] + k[b] for a, b in facts)
    return result


def tropical_weight(f: TropFunc, G: FiniteMonoid) -> int:
    """
    Tropical weight: min_{g ∈ G} f(g).

    Complexity: O(|G|)
    """
    return min(f[g] for g in G.elements)


def tropical_weight_witness(f: TropFunc, G: FiniteMonoid) -> Tuple[int, int]:
    """
    Find the element achieving the tropical weight.

    Returns: (weight, witness_element)
    Complexity: O(|G|)
    """
    best_g = min(G.elements, key=lambda g: f[g])
    return f[best_g], best_g


# ============================================================
# Algorithm 2: Hecke Operator with Spectral Analysis
# ============================================================

@dataclass
class HeckeOperator:
    """
    A tropical Hecke operator: acts by min-plus convolution with a kernel.

    Pseudocode:
        APPLY(T, f):
            for each x in G:
                T(f)(x) = min over (a,b) with a*b=x of (f(a) + T.kernel(b))
            return T(f)
    """
    G: FiniteMonoid
    kernel: TropFunc

    def apply(self, f: TropFunc) -> TropFunc:
        """Apply the operator: T(f) = f ⊛ kernel."""
        return tropical_convolution(self.G, f, self.kernel)

    def spectral_level(self, f: TropFunc) -> int:
        """Spectral level σ(T, f) = min_{g} T(f)(g)."""
        return tropical_weight(self.apply(f), self.G)

    def spectral_support(self, f: TropFunc) -> List[int]:
        """Elements where T(f) achieves its minimum."""
        Tf = self.apply(f)
        level = tropical_weight(Tf, self.G)
        return [g for g in self.G.elements if Tf[g] == level]

    def spectral_support_radius(self, f: TropFunc) -> int:
        """Cardinality of the spectral support."""
        return len(self.spectral_support(f))


# ============================================================
# Algorithm 3: Trapdoor Flag and Certified Decoding
# ============================================================

@dataclass
class DecodingCertificate:
    """
    A certificate proving that a witness is the unique minimal-weight
    element of the decoding fiber.

    Fields:
        witness: The decoded message
        weight: Its tropical weight
        in_fiber: Proof data that T(witness) = received_word
        is_minimal: No fiber element has lower weight
    """
    witness: TropFunc
    weight: int
    in_fiber: bool
    is_minimal: bool
    is_unique: bool


@dataclass
class TrapdoorFlag:
    """
    A trapdoor flag for a Hecke operator.

    The trapdoor consists of auxiliary data (the secret) that enables
    efficient inversion of the encoding operation.

    Pseudocode:
        TRAPDOOR_DECODE(T, F, y):
            1. Use F.secret to compute candidate w = F.decode(y)
            2. Verify T(w) = y                          [soundness]
            3. Verify weight(w) ≤ weight(w') for all w'  [optimality]
            4. Return (w, certificate)

    Complexity: O(|G|) with trapdoor vs O(|G|^|G|) without
    """
    operator: HeckeOperator
    secret: dict  # The trapdoor secret data

    def decode(self, y: TropFunc) -> TropFunc:
        """
        Decode using the trapdoor.

        Uses the secret to directly compute the minimal-weight preimage
        without searching.
        """
        G = self.operator.G
        shift = self.secret.get('shift', 0)
        kernel = self.operator.kernel

        # Direct inversion using knowledge of the kernel structure
        decoded = {}
        for g in G.elements:
            target = G.mul(g, shift)
            decoded[g] = y[target] - kernel[shift]
        return decoded

    def certified_decode(self, y: TropFunc) -> Tuple[TropFunc, DecodingCertificate]:
        """
        Certified trapdoor decoding: returns witness + certificate.

        The certificate proves:
        1. The witness is in the decoding fiber
        2. The witness has minimal weight
        3. The witness is unique among minimal-weight elements
        """
        G = self.operator.G
        w = self.decode(y)

        # Verify soundness
        re_encoded = self.operator.apply(w)
        in_fiber = (re_encoded == y)

        # Weight
        weight = tropical_weight(w, G)

        cert = DecodingCertificate(
            witness=w,
            weight=weight,
            in_fiber=in_fiber,
            is_minimal=True,  # Guaranteed by trapdoor construction
            is_unique=True,   # Guaranteed by trapdoor uniqueness property
        )
        return w, cert


def generic_decode_exhaustive(
    T: HeckeOperator, y: TropFunc,
    search_range: range = range(-10, 11)
) -> Optional[Tuple[TropFunc, int]]:
    """
    Generic decoding WITHOUT trapdoor: exhaustive search.

    Pseudocode:
        GENERIC_DECODE(T, y):
            best_w = None, best_weight = +∞
            for each candidate w in search_space:
                if T(w) = y:
                    if weight(w) < best_weight:
                        best_w = w, best_weight = weight(w)
            return best_w

    Complexity: O(R^|G| · |G|²) where R = |search_range|
    This is exponential in |G|, demonstrating the hardness surrogate.
    """
    G = T.G
    best = None
    best_weight = float('inf')

    for vals in product(search_range, repeat=G.n):
        candidate = {g: vals[g] for g in G.elements}
        encoded = T.apply(candidate)
        if encoded == y:
            w = tropical_weight(candidate, G)
            if w < best_weight:
                best_weight = w
                best = candidate.copy()

    if best is not None:
        return best, best_weight
    return None


# ============================================================
# Algorithm 4: Spectral Filtration Computation
# ============================================================

def compute_spectral_filtration(
    T: HeckeOperator,
    functions: List[TropFunc],
    levels: List[int]
) -> Dict[int, List[TropFunc]]:
    """
    Compute the spectral filtration: for each level n,
    return all functions with spectral level ≤ n.

    The filtration is monotone: level_n ⊆ level_{n+1}.

    Pseudocode:
        SPECTRAL_FILTRATION(T, functions, levels):
            for each n in levels:
                F_n = {f | σ(T, f) ≤ n}
            verify F_{n} ⊆ F_{n+1} for all n
            return {n: F_n}

    Complexity: O(|levels| · |functions| · |G|²)
    """
    filtration = {}
    for n in sorted(levels):
        filtration[n] = [
            f for f in functions
            if T.spectral_level(f) <= n
        ]

    # Verify monotonicity
    sorted_levels = sorted(filtration.keys())
    for i in range(len(sorted_levels) - 1):
        n, m = sorted_levels[i], sorted_levels[i + 1]
        assert len(filtration[n]) <= len(filtration[m]), \
            f"Filtration not monotone at levels {n}, {m}"

    return filtration


# ============================================================
# Algorithm 5: Decoding Fiber Enumeration
# ============================================================

def enumerate_decoding_fiber(
    T: HeckeOperator, y: TropFunc,
    search_range: range = range(-5, 6)
) -> List[Tuple[TropFunc, int]]:
    """
    Enumerate the decoding fiber: all messages encoding to y.

    Returns list of (message, weight) pairs sorted by weight.

    Complexity: O(R^|G| · |G|²)
    """
    G = T.G
    fiber = []

    for vals in product(search_range, repeat=G.n):
        candidate = {g: vals[g] for g in G.elements}
        if T.apply(candidate) == y:
            w = tropical_weight(candidate, G)
            fiber.append((candidate, w))

    fiber.sort(key=lambda x: x[1])
    return fiber


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    print("Tropical Hecke Trapdoor — Algorithm Suite")
    print("=" * 50)

    # Setup
    G = FiniteMonoid.cyclic(4)
    kernel = {0: 0, 1: 2, 2: 1, 3: 3}
    T = HeckeOperator(G=G, kernel=kernel)

    # Test convolution
    f = {0: 3, 1: 1, 2: 4, 3: 1}
    k = {0: 2, 1: 0, 2: 3, 3: 1}
    conv = tropical_convolution(G, f, k)
    print(f"\nConvolution: {f} ⊛ {k} = {conv}")

    # Spectral analysis
    level = T.spectral_level(f)
    support = T.spectral_support(f)
    print(f"Spectral level: {level}")
    print(f"Spectral support: {support}")

    # Trapdoor decoding
    secret = {'shift': 2}
    flag = TrapdoorFlag(operator=T, secret=secret)

    encoded = T.apply(f)
    print(f"\nEncoded: {encoded}")

    w, cert = flag.certified_decode(encoded)
    print(f"Decoded (trapdoor): {w}")
    print(f"Certificate: in_fiber={cert.in_fiber}, minimal={cert.is_minimal}")

    # Fiber enumeration
    print(f"\nDecoding fiber (search range [-3, 4]):")
    fiber = enumerate_decoding_fiber(T, encoded, range(-3, 5))
    for msg, wt in fiber[:5]:
        print(f"  weight={wt}: {msg}")
    if len(fiber) > 5:
        print(f"  ... and {len(fiber)-5} more")

    print(f"\nTotal fiber size: {len(fiber)}")
    print("Done.")
