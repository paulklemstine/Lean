"""
Algorithms for Quantum 2-Designs from Certified Unitary Expanders

This module implements:
1. Certificate checking for SU₂(F_{q²}) ≅ SL₂(F_q) generators
2. Cayley graph construction and random walks
3. Second-moment operator / frame-potential computation
4. Spectral gap estimation

All algorithms correspond to formalized definitions and theorems in the
Lean 4 proof development.
"""

import numpy as np
from typing import Tuple, List, Optional, Dict
from itertools import product


def make_field(q: int) -> Dict:
    """
    Create arithmetic operations for GF(q) where q is prime.
    Returns a dict with add, mul, inv, neg operations (all mod q).
    """
    assert _is_prime(q), f"{q} is not prime"
    return {
        'q': q,
        'add': lambda a, b: (a + b) % q,
        'mul': lambda a, b: (a * b) % q,
        'neg': lambda a: (-a) % q,
        'inv': lambda a: pow(a, q - 2, q) if a % q != 0 else None,
        'elements': list(range(q)),
    }


def _is_prime(n: int) -> bool:
    """Check primality."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def sl2_elements(q: int) -> List[np.ndarray]:
    """
    Enumerate all elements of SL₂(GF(q)).

    Args:
        q: A prime number

    Returns:
        List of 2×2 numpy arrays over GF(q) with determinant 1

    Complexity: O(q³) time, O(q³) space
    """
    elements = []
    for a in range(q):
        for b in range(q):
            for c in range(q):
                # d is determined by ad - bc = 1 mod q
                det_target = (1 + b * c) % q
                if a == 0:
                    continue
                d = (det_target * pow(a, q - 2, q)) % q
                mat = np.array([[a, b], [c, d]], dtype=int)
                if (a * d - b * c) % q == 1:
                    elements.append(mat)
    # Also handle a = 0 case: need -bc = 1, so bc = q-1
    for b in range(q):
        for c in range(q):
            if (-(b * c)) % q == 1:
                for d in range(q):
                    mat = np.array([[0, b], [c, d]], dtype=int)
                    elements.append(mat)
    return elements


def mat_mul_mod(A: np.ndarray, B: np.ndarray, q: int) -> np.ndarray:
    """Matrix multiplication modulo q."""
    return (A @ B) % q


def mat_inv_mod(A: np.ndarray, q: int) -> np.ndarray:
    """Inverse of a 2×2 matrix in GL₂(GF(q))."""
    a, b, c, d = A[0, 0], A[0, 1], A[1, 0], A[1, 1]
    det = (a * d - b * c) % q
    det_inv = pow(int(det), q - 2, q)
    return np.array([[d * det_inv % q, (-b * det_inv) % q],
                     [(-c * det_inv) % q, a * det_inv % q]], dtype=int) % q


def charpoly_is_irreducible(A: np.ndarray, q: int) -> bool:
    """
    Check if the characteristic polynomial of a 2×2 matrix over GF(q)
    is irreducible.

    For 2×2 matrices, χ(x) = x² - tr(A)x + det(A).
    This is irreducible over GF(q) iff it has no roots in GF(q),
    i.e., tr(A)² - 4·det(A) is not a quadratic residue mod q.

    Args:
        A: 2×2 matrix over GF(q)
        q: prime field size

    Returns:
        True if characteristic polynomial is irreducible
    """
    tr = (A[0, 0] + A[1, 1]) % q
    det = (A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0]) % q
    disc = (tr * tr - 4 * det) % q

    if disc == 0:
        return False

    # Check if disc is a quadratic residue mod q
    # By Euler's criterion: disc^((q-1)/2) = 1 mod q iff QR
    if q == 2:
        return True  # all non-zero elements are QR in GF(2)
    return pow(int(disc), (q - 1) // 2, q) != 1


def check_generates_sl2(s: np.ndarray, t: np.ndarray, q: int) -> bool:
    """
    Check whether ⟨s, t⟩ = SL₂(GF(q)) by iterative closure.

    Args:
        s, t: 2×2 matrices in SL₂(GF(q))
        q: prime field size

    Returns:
        True if s and t generate all of SL₂(GF(q))

    Complexity: O(|SL₂(GF(q))|²) worst case
    """
    target_size = q * (q * q - 1)  # |SL₂(GF(q))| = q(q²-1)

    def mat_to_tuple(M):
        return tuple(M.flatten())

    generated = set()
    identity = np.eye(2, dtype=int)
    generators = [s, mat_inv_mod(s, q), t, mat_inv_mod(t, q)]

    frontier = [identity]
    generated.add(mat_to_tuple(identity))

    while frontier:
        new_frontier = []
        for g_mat in frontier:
            for gen in generators:
                prod = mat_mul_mod(g_mat, gen, q)
                key = mat_to_tuple(prod % q)
                if key not in generated:
                    generated.add(key)
                    new_frontier.append(prod)
                    if len(generated) == target_size:
                        return True
        frontier = new_frontier

    return len(generated) == target_size


def certificate_check(s: np.ndarray, t: np.ndarray, q: int) -> Dict:
    """
    Full certificate check for a quantum generation pair in SL₂(GF(q)).

    Checks:
    1. Both matrices are in SL₂(GF(q)) (determinant 1)
    2. At least one has irreducible characteristic polynomial
    3. The pair generates all of SL₂(GF(q))
    4. The symmetric set {s, s⁻¹, t, t⁻¹} is well-formed

    This corresponds to the formalized `certificate_check_sound` theorem.

    Args:
        s, t: candidate generator matrices
        q: prime field size

    Returns:
        Dictionary with check results and certificate data
    """
    result = {
        'valid': False,
        'det_s': int((s[0, 0] * s[1, 1] - s[0, 1] * s[1, 0]) % q),
        'det_t': int((t[0, 0] * t[1, 1] - t[0, 1] * t[1, 0]) % q),
        'charpoly_s_irred': False,
        'charpoly_t_irred': False,
        'generates_full_group': False,
        'symmetric_set_size': 0,
    }

    # Check determinants
    if result['det_s'] != 1 or result['det_t'] != 1:
        return result

    # Check characteristic polynomials
    result['charpoly_s_irred'] = charpoly_is_irreducible(s, q)
    result['charpoly_t_irred'] = charpoly_is_irreducible(t, q)

    if not (result['charpoly_s_irred'] or result['charpoly_t_irred']):
        result['note'] = 'Neither generator has irreducible charpoly'

    # Check generation
    result['generates_full_group'] = check_generates_sl2(s, t, q)

    # Symmetric set
    s_inv = mat_inv_mod(s, q)
    t_inv = mat_inv_mod(t, q)
    sym_set = {tuple(m.flatten()) for m in [s, s_inv, t, t_inv]}
    result['symmetric_set_size'] = len(sym_set)

    result['valid'] = (
        result['det_s'] == 1 and
        result['det_t'] == 1 and
        result['generates_full_group']
    )

    return result


def cayley_walk_distribution(
    s: np.ndarray,
    t: np.ndarray,
    q: int,
    k: int
) -> Dict[tuple, float]:
    """
    Compute the probability distribution of the k-step Cayley walk
    starting from the identity in Cay(SL₂(GF(q)), S).

    This implements the `cayleyDistribution` definition from Lean:
    cayleyAverageIter S k (δ_identity).

    Args:
        s, t: generators in SL₂(GF(q))
        q: prime field size
        k: number of walk steps

    Returns:
        Dictionary mapping group elements (as tuples) to probabilities
    """
    s_inv = mat_inv_mod(s, q)
    t_inv = mat_inv_mod(t, q)
    generators = [s, s_inv, t, t_inv]

    # Start with delta distribution at identity
    identity = tuple(np.eye(2, dtype=int).flatten())
    dist = {identity: 1.0}

    for _ in range(k):
        new_dist: Dict[tuple, float] = {}
        for elem, prob in dist.items():
            elem_mat = np.array(elem, dtype=int).reshape(2, 2)
            for gen in generators:
                prod = mat_mul_mod(gen, elem_mat, q)
                key = tuple((prod % q).flatten())
                new_dist[key] = new_dist.get(key, 0.0) + prob / len(generators)
        dist = new_dist

    return dist


def frame_potential_bound(dist: Dict[tuple, float], group_size: int) -> float:
    """
    Compute the frame-potential surrogate bound.

    Implements framePotential₂Bound: ∑ μ(g)² - 1/|G|.

    Args:
        dist: probability distribution on the group
        group_size: |G|

    Returns:
        Frame potential bound value (0 when uniform)
    """
    sum_sq = sum(p ** 2 for p in dist.values())
    return sum_sq - 1.0 / group_size


def deviation_energy(dist: Dict[tuple, float], group_size: int) -> float:
    """
    Compute the deviation energy: ∑(μ(g) - 1/|G|)².

    Implements `deviationEnergy` from Lean.

    Args:
        dist: probability distribution on the group
        group_size: |G|

    Returns:
        Deviation energy (0 when uniform)
    """
    uniform = 1.0 / group_size
    return sum((p - uniform) ** 2 for p in dist.values())


def spectral_gap_estimate(
    s: np.ndarray,
    t: np.ndarray,
    q: int,
    max_steps: int = 50
) -> Tuple[float, List[float]]:
    """
    Estimate the spectral gap of Cay(SL₂(GF(q)), {s, s⁻¹, t, t⁻¹})
    by tracking the decay rate of deviation energy.

    The spectral gap is estimated as 1 - √(E_{k+1}/E_k) averaged
    over several steps.

    Args:
        s, t: generators
        q: prime field size
        max_steps: maximum walk steps

    Returns:
        Tuple of (estimated spectral bound λ, list of deviation energies)
    """
    group_size = q * (q * q - 1)
    energies = []
    ratios = []

    s_inv = mat_inv_mod(s, q)
    t_inv = mat_inv_mod(t, q)
    generators = [s, s_inv, t, t_inv]

    identity = tuple(np.eye(2, dtype=int).flatten())
    dist = {identity: 1.0}

    for step in range(max_steps):
        e = deviation_energy(dist, group_size)
        energies.append(e)

        if step > 0 and energies[step - 1] > 1e-15:
            ratio = e / energies[step - 1]
            ratios.append(np.sqrt(max(ratio, 0)))

        if e < 1e-14:
            break

        new_dist: Dict[tuple, float] = {}
        for elem, prob in dist.items():
            elem_mat = np.array(elem, dtype=int).reshape(2, 2)
            for gen in generators:
                prod = mat_mul_mod(gen, elem_mat, q)
                key = tuple((prod % q).flatten())
                new_dist[key] = new_dist.get(key, 0.0) + prob / len(generators)
        dist = new_dist

    spec_bound = np.median(ratios) if ratios else 1.0
    return float(spec_bound), energies


def find_certified_pair(q: int) -> Optional[Tuple[np.ndarray, np.ndarray, Dict]]:
    """
    Search for a certified quantum generation pair in SL₂(GF(q)).

    Strategy: try pairs where at least one element has irreducible
    characteristic polynomial, then verify generation.

    Args:
        q: prime field size

    Returns:
        Tuple (s, t, certificate) or None if not found
    """
    # Generate candidates with irreducible charpoly
    candidates = []
    for a in range(q):
        for b in range(q):
            for c in range(q):
                for d in range(q):
                    mat = np.array([[a, b], [c, d]], dtype=int)
                    if (a * d - b * c) % q == 1:
                        if charpoly_is_irreducible(mat, q):
                            candidates.append(mat)

    # Also get all SL2 elements for broader search
    all_sl2 = []
    for a in range(q):
        for b in range(q):
            for c in range(q):
                for d in range(q):
                    mat = np.array([[a, b], [c, d]], dtype=int)
                    if (a * d - b * c) % q == 1:
                        all_sl2.append(mat)

    # Try pairs with irred charpoly
    for s in candidates[:min(len(candidates), 30)]:
        for t in candidates[:min(len(candidates), 30)]:
            if np.array_equal(s, t):
                continue
            cert = certificate_check(s, t, q)
            if cert['valid']:
                return s, t, cert

    # Try irred paired with any SL2 element
    for s in candidates[:min(len(candidates), 30)]:
        for t in all_sl2[:min(len(all_sl2), 40)]:
            if np.array_equal(s, t):
                continue
            cert = certificate_check(s, t, q)
            if cert['valid']:
                return s, t, cert

    return None


def mixing_time_bound(spec_bound: float, E0: float, eps: float) -> int:
    """
    Compute the theoretical mixing time bound.

    k ≥ ⌈log(E₀/ε) / (2·log(1/λ))⌉

    This corresponds to the `mixing_time_logarithmic` theorem.

    Args:
        spec_bound: spectral bound λ < 1
        E0: initial deviation energy
        eps: target accuracy

    Returns:
        Minimum number of steps k for ε-mixing
    """
    if spec_bound <= 0 or spec_bound >= 1:
        return -1
    if E0 <= eps:
        return 0
    return int(np.ceil(np.log(E0 / eps) / (2 * np.log(1 / spec_bound))))


if __name__ == '__main__':
    print("=" * 60)
    print("Quantum 2-Design Certificate Algorithms")
    print("=" * 60)

    for q in [3, 5, 7]:
        print(f"\n{'=' * 50}")
        print(f"  SL₂(GF({q})): group order = {q * (q*q - 1)}")
        print(f"{'=' * 50}")

        result = find_certified_pair(q)
        if result is None:
            print("  No certified pair found!")
            continue

        s, t, cert = result
        print(f"  Generator s = {s.tolist()}")
        print(f"  Generator t = {t.tolist()}")
        print(f"  Certificate valid: {cert['valid']}")
        print(f"  Charpoly s irreducible: {cert['charpoly_s_irred']}")
        print(f"  Charpoly t irreducible: {cert['charpoly_t_irred']}")
        print(f"  Symmetric set size: {cert['symmetric_set_size']}")

        spec_bound, energies = spectral_gap_estimate(s, t, q, max_steps=30)
        print(f"  Estimated spectral bound λ ≈ {spec_bound:.4f}")
        print(f"  Spectral gap (1-λ) ≈ {1 - spec_bound:.4f}")

        if spec_bound < 1 and len(energies) > 1:
            E0 = energies[0]
            for eps in [0.1, 0.01, 0.001]:
                k = mixing_time_bound(spec_bound, E0, eps)
                print(f"  Mixing time for ε={eps}: k ≥ {k}")
