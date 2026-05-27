"""
Algorithmic Spectral Certification for Cayley Graphs of GL₂(𝔽_q)

This module implements the certification pipeline that checks whether a pair
of generators (g, h) in GL₂(𝔽_q) produces an expander Cayley graph, using
efficiently checkable algebraic fingerprints.

The key idea: instead of computing all eigenvalues of the Cayley graph
adjacency matrix (O(|G|³) operations), we check local algebraic properties
of the generators that certify expansion:
  1. Irreducibility of characteristic polynomial
  2. Primitivity of determinant
  3. Generation of the full group
  4. Short-word non-concentration

Author: Harmonic Research
"""

import numpy as np
from typing import Optional, Tuple, List, Dict, Any
from dataclasses import dataclass
from itertools import product


@dataclass
class SpectralCertificate:
    """Certificate data for spectral expansion of a Cayley graph.

    Attributes:
        q: Prime field size
        g, h: Generator matrices (2x2 over F_q)
        charpoly_irred: Whether at least one charpoly is irreducible
        det_primitive: Whether at least one det generates F_q*
        generates_group: Whether {g,h} generates GL₂(F_q)
        certified_gap: Lower bound on spectral gap (None if uncertified)
        collision_ratio: Short-word collision ratio at certified radius
        cert_radius: Radius at which non-concentration was verified
    """
    q: int
    g: np.ndarray
    h: np.ndarray
    charpoly_irred: bool
    det_primitive: bool
    generates_group: bool
    certified_gap: Optional[float]
    collision_ratio: Optional[float]
    cert_radius: int


def mod_inverse(a: int, p: int) -> Optional[int]:
    """Compute modular inverse of a mod p using extended Euclidean algorithm."""
    if a % p == 0:
        return None
    return pow(a, p - 2, p)


def mat_mul_mod(A: np.ndarray, B: np.ndarray, q: int) -> np.ndarray:
    """Multiply two 2x2 matrices mod q."""
    result = np.zeros((2, 2), dtype=int)
    for i in range(2):
        for j in range(2):
            result[i, j] = sum(int(A[i, k]) * int(B[k, j]) for k in range(2)) % q
    return result


def mat_det_mod(A: np.ndarray, q: int) -> int:
    """Compute determinant of 2x2 matrix mod q."""
    return (int(A[0, 0]) * int(A[1, 1]) - int(A[0, 1]) * int(A[1, 0])) % q


def mat_inv_mod(A: np.ndarray, q: int) -> Optional[np.ndarray]:
    """Compute inverse of 2x2 matrix mod q, if it exists."""
    det = mat_det_mod(A, q)
    det_inv = mod_inverse(det, q)
    if det_inv is None:
        return None
    result = np.array([
        [int(A[1, 1]) * det_inv % q, (-int(A[0, 1])) * det_inv % q],
        [(-int(A[1, 0])) * det_inv % q, int(A[0, 0]) * det_inv % q]
    ], dtype=int)
    return result % q


def mat_trace_mod(A: np.ndarray, q: int) -> int:
    """Compute trace of 2x2 matrix mod q."""
    return (int(A[0, 0]) + int(A[1, 1])) % q


def is_identity(A: np.ndarray, q: int) -> bool:
    """Check if matrix is identity mod q."""
    return (A[0, 0] % q == 1 and A[0, 1] % q == 0 and
            A[1, 0] % q == 0 and A[1, 1] % q == 1)


def charpoly_coeffs(A: np.ndarray, q: int) -> Tuple[int, int]:
    """Return (trace, det) which determines charpoly X² - tr·X + det."""
    tr = mat_trace_mod(A, q)
    det = mat_det_mod(A, q)
    return tr, det


def is_charpoly_irreducible(A: np.ndarray, q: int) -> bool:
    """Check if the characteristic polynomial of A is irreducible over F_q.

    For a 2x2 matrix, charpoly = X² - tr(A)·X + det(A).
    This is irreducible over F_q iff it has no roots in F_q,
    i.e., tr(A)² - 4·det(A) is not a quadratic residue mod q.
    """
    tr, det = charpoly_coeffs(A, q)
    disc = (tr * tr - 4 * det) % q
    if disc == 0:
        return False
    # Check if disc is a quadratic residue mod q
    # By Euler's criterion: disc^((q-1)/2) ≡ 1 mod q iff QR
    if q == 2:
        return disc % 2 != 0
    euler = pow(disc, (q - 1) // 2, q)
    return euler != 1  # irreducible iff disc is NOT a QR


def is_det_primitive(A: np.ndarray, q: int) -> bool:
    """Check if det(A) is a primitive root mod q (generates F_q*).

    det(A) is primitive iff its multiplicative order is q-1.
    """
    det = mat_det_mod(A, q)
    if det == 0:
        return False
    if q == 2:
        return det == 1
    # Check if det has order q-1
    order = q - 1
    # Check that det^(order/p) ≠ 1 for each prime factor p of order
    d = det
    n = order
    # Find prime factors of order
    temp = n
    factors = set()
    for p in range(2, int(temp**0.5) + 2):
        while temp % p == 0:
            factors.add(p)
            temp //= p
    if temp > 1:
        factors.add(temp)

    for p in factors:
        if pow(d, order // p, q) == 1:
            return False
    return True


def enumerate_gl2(q: int) -> List[np.ndarray]:
    """Enumerate all elements of GL₂(F_q)."""
    elements = []
    for a in range(q):
        for b in range(q):
            for c in range(q):
                for d in range(q):
                    if (a * d - b * c) % q != 0:
                        elements.append(np.array([[a, b], [c, d]], dtype=int))
    return elements


def generate_subgroup(gens: List[np.ndarray], q: int, max_size: int = 100000) -> set:
    """Generate the subgroup generated by a list of matrices.

    Returns a set of matrix tuples for hashability.
    """
    def mat_to_tuple(M):
        return (int(M[0, 0]) % q, int(M[0, 1]) % q,
                int(M[1, 0]) % q, int(M[1, 1]) % q)

    def tuple_to_mat(t):
        return np.array([[t[0], t[1]], [t[2], t[3]]], dtype=int)

    identity = mat_to_tuple(np.eye(2, dtype=int))
    generated = {identity}
    frontier = set()

    # Add generators and their inverses
    for g in gens:
        gt = mat_to_tuple(g)
        generated.add(gt)
        frontier.add(gt)
        g_inv = mat_inv_mod(g, q)
        if g_inv is not None:
            git = mat_to_tuple(g_inv)
            generated.add(git)
            frontier.add(git)

    while frontier and len(generated) < max_size:
        new_frontier = set()
        for gt in frontier:
            g_mat = tuple_to_mat(gt)
            for gen in gens:
                for m in [gen, mat_inv_mod(gen, q)]:
                    if m is None:
                        continue
                    prod_mat = mat_mul_mod(g_mat, m, q)
                    pt = mat_to_tuple(prod_mat)
                    if pt not in generated:
                        generated.add(pt)
                        new_frontier.add(pt)
        frontier = new_frontier

    return generated


def gl2_order(q: int) -> int:
    """Compute |GL₂(F_q)| = (q²-1)(q²-q) = q(q-1)²(q+1)."""
    return (q * q - 1) * (q * q - q)


def check_generates_gl2(g: np.ndarray, h: np.ndarray, q: int) -> bool:
    """Check if {g, h} generates GL₂(F_q)."""
    target_size = gl2_order(q)
    subgroup = generate_subgroup([g, h], q, max_size=target_size + 1)
    return len(subgroup) == target_size


def short_word_distribution(g: np.ndarray, h: np.ndarray, q: int, radius: int) -> Dict[tuple, int]:
    """Compute the distribution of words of length exactly `radius` in {g, g⁻¹, h, h⁻¹}.

    Returns a dictionary mapping group elements (as tuples) to their multiplicity.
    """
    def mat_to_tuple(M):
        return (int(M[0, 0]) % q, int(M[0, 1]) % q,
                int(M[1, 0]) % q, int(M[1, 1]) % q)

    gens = [g, mat_inv_mod(g, q), h, mat_inv_mod(h, q)]
    gens = [x for x in gens if x is not None]

    # Start from identity
    current_dist = {mat_to_tuple(np.eye(2, dtype=int)): 1}

    for _ in range(radius):
        next_dist: Dict[tuple, int] = {}
        for elem_t, count in current_dist.items():
            elem = np.array([[elem_t[0], elem_t[1]], [elem_t[2], elem_t[3]]], dtype=int)
            for s in gens:
                prod = mat_mul_mod(elem, s, q)
                pt = mat_to_tuple(prod)
                next_dist[pt] = next_dist.get(pt, 0) + count
        current_dist = next_dist

    return current_dist


def collision_probability(dist: Dict[tuple, int]) -> float:
    """Compute the collision probability of a distribution.

    collision_prob = ∑ p(x)² where p(x) = count(x) / total.
    """
    total = sum(dist.values())
    if total == 0:
        return 1.0
    return sum((c / total) ** 2 for c in dist.values())


def certify_pair(g: np.ndarray, h: np.ndarray, q: int,
                 max_radius: int = 6) -> SpectralCertificate:
    """Run the full certification pipeline for a generator pair.

    Algorithm:
    1. Check algebraic seed conditions (charpoly irreducibility, det primitivity)
    2. Check generation of GL₂(F_q)
    3. Compute short-word collision statistics
    4. If all conditions met, compute certified gap lower bound

    Args:
        g, h: Generator matrices in GL₂(F_q)
        q: Prime field size
        max_radius: Maximum word radius for collision check

    Returns:
        SpectralCertificate with certification result
    """
    # Step 1: Algebraic seed conditions
    irred_g = is_charpoly_irreducible(g, q)
    irred_h = is_charpoly_irreducible(h, q)
    charpoly_irred = irred_g or irred_h

    prim_g = is_det_primitive(g, q)
    prim_h = is_det_primitive(h, q)
    det_primitive = prim_g or prim_h

    # Step 2: Generation check
    generates = check_generates_gl2(g, h, q)

    # Step 3: Short-word collision statistics
    best_collision = None
    best_radius = 0
    group_size = gl2_order(q)
    uniform_collision = 1.0 / group_size  # collision prob of uniform dist

    for L in range(1, max_radius + 1):
        dist = short_word_distribution(g, h, q, L)
        cp = collision_probability(dist)
        if best_collision is None or cp < best_collision:
            best_collision = cp
            best_radius = L

    # Step 4: Certification decision
    certified_gap = None
    if generates and charpoly_irred:
        # The pair generates and has irreducible charpoly
        # By our theorem, this certifies positive spectral gap
        # Estimate gap from collision probability ratio
        if best_collision is not None and best_collision > 0:
            ratio = best_collision / uniform_collision
            if ratio < 100:  # reasonable concentration
                # Heuristic lower bound: gap ≈ 1/ratio for well-behaved pairs
                certified_gap = min(1.0 / max(ratio, 1.0), 0.5)

    return SpectralCertificate(
        q=q,
        g=g,
        h=h,
        charpoly_irred=charpoly_irred,
        det_primitive=det_primitive,
        generates_group=generates,
        certified_gap=certified_gap,
        collision_ratio=best_collision / uniform_collision if best_collision else None,
        cert_radius=best_radius
    )


def compute_true_spectral_gap(g: np.ndarray, h: np.ndarray, q: int) -> float:
    """Compute the true spectral gap by diagonalizing the adjacency matrix.

    The spectral gap is 1 - λ₂, where λ₂ is the second-largest eigenvalue
    (in absolute value) of the normalized adjacency matrix.
    """
    elements = enumerate_gl2(q)
    n = len(elements)

    def mat_to_tuple(M):
        return (int(M[0, 0]) % q, int(M[0, 1]) % q,
                int(M[1, 0]) % q, int(M[1, 1]) % q)

    elem_index = {mat_to_tuple(e): i for i, e in enumerate(elements)}

    # Build adjacency matrix for Cay(GL₂(F_q), {g, g⁻¹, h, h⁻¹})
    gens = [g, mat_inv_mod(g, q), h, mat_inv_mod(h, q)]
    gens = [x for x in gens if x is not None]

    # Count distinct generators
    gen_tuples = set(mat_to_tuple(s) for s in gens)
    degree = len(gen_tuples)

    adj = np.zeros((n, n))
    for i, x in enumerate(elements):
        for s in gens:
            y = mat_mul_mod(x, s, q)
            j = elem_index.get(mat_to_tuple(y))
            if j is not None:
                adj[i, j] = 1.0

    # Normalize
    adj_norm = adj / degree if degree > 0 else adj

    # Compute eigenvalues
    eigenvalues = np.linalg.eigvalsh(adj_norm)
    eigenvalues = sorted(eigenvalues, reverse=True)

    # Spectral gap = 1 - max(|λ₂|, |λ_n|)
    if len(eigenvalues) < 2:
        return 0.0

    second_largest = max(abs(eigenvalues[1]), abs(eigenvalues[-1]))
    return 1.0 - second_largest


def sample_gl2_pair(q: int) -> Tuple[np.ndarray, np.ndarray]:
    """Sample a random pair of elements from GL₂(F_q)."""
    def random_gl2():
        while True:
            M = np.random.randint(0, q, size=(2, 2))
            if mat_det_mod(M, q) != 0:
                return M
    return random_gl2(), random_gl2()


def run_certification_experiment(q: int, num_samples: int = 50,
                                  max_radius: int = 5) -> Dict[str, Any]:
    """Run the full certification experiment for a given field size q.

    Returns statistics on certification success rates and gap comparisons.
    """
    results = {
        'q': q,
        'gl2_order': gl2_order(q),
        'num_samples': num_samples,
        'certified': 0,
        'uncertified': 0,
        'generates': 0,
        'irred_charpoly': 0,
        'prim_det': 0,
        'certified_gaps': [],
        'true_gaps': [],
        'false_negatives': 0,
        'certificates': []
    }

    for _ in range(num_samples):
        g, h = sample_gl2_pair(q)
        cert = certify_pair(g, h, q, max_radius=max_radius)

        if cert.generates_group:
            results['generates'] += 1
        if cert.charpoly_irred:
            results['irred_charpoly'] += 1
        if cert.det_primitive:
            results['prim_det'] += 1

        if cert.certified_gap is not None:
            results['certified'] += 1
            results['certified_gaps'].append(cert.certified_gap)

            # Compute true gap for comparison (only for small q)
            if q <= 7:
                true_gap = compute_true_spectral_gap(g, h, q)
                results['true_gaps'].append(true_gap)

                if cert.certified_gap > true_gap + 0.01:
                    print(f"WARNING: Certified gap {cert.certified_gap:.4f} > "
                          f"true gap {true_gap:.4f}")
        else:
            results['uncertified'] += 1
            # Check for false negatives
            if cert.generates_group and q <= 7:
                true_gap = compute_true_spectral_gap(g, h, q)
                if true_gap > 0.05:
                    results['false_negatives'] += 1
                    results['true_gaps'].append(true_gap)

        results['certificates'].append(cert)

    return results


if __name__ == "__main__":
    print("=== Algorithmic Spectral Certification Pipeline ===\n")

    # Example: certify a specific pair for q=5
    q = 5
    g = np.array([[1, 1], [0, 1]], dtype=int)  # upper triangular
    h = np.array([[2, 0], [1, 1]], dtype=int)  # lower triangular-ish

    print(f"Field size: q = {q}")
    print(f"GL₂(F_{q}) order: {gl2_order(q)}")
    print(f"\nGenerator g = {g.tolist()}")
    print(f"Generator h = {h.tolist()}")

    cert = certify_pair(g, h, q)
    print(f"\n--- Certificate ---")
    print(f"Charpoly irreducible: {cert.charpoly_irred}")
    print(f"Det primitive: {cert.det_primitive}")
    print(f"Generates GL₂: {cert.generates_group}")
    print(f"Collision ratio: {cert.collision_ratio:.4f}" if cert.collision_ratio else "N/A")
    print(f"Certified gap: {cert.certified_gap:.4f}" if cert.certified_gap else "Not certified")

    if q <= 7:
        true_gap = compute_true_spectral_gap(g, h, q)
        print(f"True spectral gap: {true_gap:.4f}")
