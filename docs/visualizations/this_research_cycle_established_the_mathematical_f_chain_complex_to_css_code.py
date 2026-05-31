"""
Algorithms for Persistent Homological Quantum Error Correction.

This module implements the core algorithms connecting persistent homology
to CSS code construction and parameter estimation.
"""

from typing import List, Tuple, Optional
import numpy as np
from dataclasses import dataclass
import math


@dataclass
class PersistenceBar:
    """A bar in a persistence barcode."""
    birth: float
    death: float

    @property
    def persistence(self) -> float:
        return self.death - self.birth

    @property
    def ratio(self) -> float:
        if self.birth <= 0:
            return float('inf')
        return self.death / self.birth

    def predicted_distance(self) -> int:
        """Barcode Distance Conjecture: d >= ceil(death/birth)."""
        if self.birth <= 0:
            return 1
        return math.ceil(self.death / self.birth)


@dataclass
class CSSCode:
    """A CSS quantum error-correcting code over F2."""
    Hx: np.ndarray  # rx x n matrix over F2
    Hz: np.ndarray  # rz x n matrix over F2

    @property
    def n(self) -> int:
        return self.Hx.shape[1]

    @property
    def rx(self) -> int:
        return self.Hx.shape[0]

    @property
    def rz(self) -> int:
        return self.Hz.shape[0]

    def verify_css(self) -> bool:
        """Verify Hx * Hz^T = 0 mod 2."""
        product = (self.Hx @ self.Hz.T) % 2
        return np.all(product == 0)

    def encoding_rate(self, k: int) -> float:
        """k/n encoding rate."""
        return k / self.n if self.n > 0 else 0.0


def hamming_weight(v: np.ndarray) -> int:
    """Hamming weight of a binary vector."""
    return int(np.sum(v != 0))


def chain_complex_to_css(
    d1: np.ndarray,
    d2: np.ndarray
) -> CSSCode:
    """
    Construct CSS code from chain complex.

    Given boundary maps d1: C0 -> C1 and d2: C1 -> C2,
    set Hx = d1^T and Hz = d2.

    CSS orthogonality follows from d2 * d1 = 0.

    Parameters
    ----------
    d1 : np.ndarray
        Boundary map d1 (n x m matrix over F2)
    d2 : np.ndarray
        Boundary map d2 (p x n matrix over F2)

    Returns
    -------
    CSSCode
        The CSS code with Hx = d1^T, Hz = d2
    """
    assert np.all((d2 @ d1) % 2 == 0), "d2 * d1 != 0: not a chain complex"
    return CSSCode(Hx=d1.T % 2, Hz=d2 % 2)


def toric_code(L: int) -> Tuple[CSSCode, dict]:
    """
    Construct the L x L toric code.

    The toric code on an L x L grid has:
    - n = 2L^2 physical qubits (edges)
    - k = 2 logical qubits
    - d = L distance

    Returns
    -------
    code : CSSCode
    params : dict with n, k, d
    """
    n = 2 * L * L  # edges
    V = L * L       # vertices
    F = L * L       # faces

    # Label edges: first L^2 are horizontal, next L^2 are vertical
    # Vertex (i,j) has index i*L + j
    # Horizontal edge from (i,j) to (i,j+1 mod L): index i*L + j
    # Vertical edge from (i,j) to (i+1 mod L, j): index L^2 + i*L + j

    # d1: n x V (boundary of edges = vertices)
    d1 = np.zeros((n, V), dtype=int)
    for i in range(L):
        for j in range(L):
            # Horizontal edge (i,j) -> (i, (j+1)%L)
            e_h = i * L + j
            v_start = i * L + j
            v_end = i * L + (j + 1) % L
            d1[e_h, v_start] = (d1[e_h, v_start] + 1) % 2
            d1[e_h, v_end] = (d1[e_h, v_end] + 1) % 2

            # Vertical edge (i,j) -> ((i+1)%L, j)
            e_v = L * L + i * L + j
            v_start = i * L + j
            v_end = ((i + 1) % L) * L + j
            d1[e_v, v_start] = (d1[e_v, v_start] + 1) % 2
            d1[e_v, v_end] = (d1[e_v, v_end] + 1) % 2

    # d2: F x n (boundary of faces = edges)
    d2 = np.zeros((F, n), dtype=int)
    for i in range(L):
        for j in range(L):
            f = i * L + j
            # Face (i,j) has boundary: horiz(i,j), vert(i,j+1%L),
            # horiz(i+1%L,j), vert(i,j)
            d2[f, i * L + j] = (d2[f, i * L + j] + 1) % 2  # top horiz
            d2[f, L*L + i*L + ((j+1)%L)] = (d2[f, L*L + i*L + ((j+1)%L)] + 1) % 2  # right vert
            d2[f, ((i+1)%L)*L + j] = (d2[f, ((i+1)%L)*L + j] + 1) % 2  # bottom horiz
            d2[f, L*L + i*L + j] = (d2[f, L*L + i*L + j] + 1) % 2  # left vert

    d1 = d1 % 2
    d2 = d2 % 2

    code = chain_complex_to_css(d1, d2)
    params = {'n': n, 'k': 2, 'd': L, 'L': L}
    return code, params


def quantum_singleton_bound(n: int, k: int) -> int:
    """
    Maximum distance allowed by the quantum Singleton bound.

    2d + k <= n + 2  =>  d <= (n - k) // 2 + 1
    """
    return (n - k) // 2 + 1


def quantum_hamming_volume(n: int, t: int) -> int:
    """
    Quantum Hamming volume: sum_{i=0}^{t} 3^i * C(n, i).

    This is the number of Pauli errors of weight <= t on n qubits.
    """
    total = 0
    for i in range(t + 1):
        total += (3 ** i) * math.comb(n, i)
    return total


def quantum_hamming_bound(n: int, k: int) -> int:
    """
    Maximum t such that 2^n >= 2^k * V(n, t).

    Returns the maximum number of correctable errors.
    """
    for t in range(n + 1):
        vol = quantum_hamming_volume(n, t)
        if vol * (2 ** k) > 2 ** n:
            return max(0, t - 1)
    return n


def persistence_rate_tradeoff(n: int, d: int) -> float:
    """
    Maximum encoding rate k/n given distance d and block length n.

    From quantum Singleton: k/n <= 1 - 2(d-1)/n + 2/n
    """
    if n == 0:
        return 0.0
    return 1.0 - 2.0 * (d - 1) / n + 2.0 / n


def barcode_to_code_params(
    barcode: List[PersistenceBar],
    n_physical: int
) -> dict:
    """
    Predict CSS code parameters from a persistence barcode.

    Parameters
    ----------
    barcode : list of PersistenceBar
        The H1 persistence barcode
    n_physical : int
        Number of physical qubits (edges in the simplicial complex)

    Returns
    -------
    dict with predicted k, d, rate
    """
    # Number of logical qubits = number of bars (at chosen scale)
    k = len(barcode)

    # Predicted distance = min predicted distance over all bars
    if k == 0:
        return {'k': 0, 'd': 0, 'rate': 0.0}

    d_predicted = min(bar.predicted_distance() for bar in barcode)

    # Singleton bound check
    d_singleton = quantum_singleton_bound(n_physical, k)
    d_effective = min(d_predicted, d_singleton)

    rate = k / n_physical if n_physical > 0 else 0.0

    return {
        'k': k,
        'd_predicted': d_predicted,
        'd_singleton': d_singleton,
        'd_effective': d_effective,
        'rate': rate,
        'total_persistence': sum(b.persistence for b in barcode),
        'max_persistence': max(b.persistence for b in barcode),
    }


def hypergraph_product_params(
    n1: int, k1: int, d1: int, r1: int,
    n2: int, k2: int, d2: int, r2: int
) -> dict:
    """
    Compute parameters of the hypergraph product code.

    Parameters
    ----------
    n1, k1, d1, r1 : int
        Parameters of the first classical code
    n2, k2, d2, r2 : int
        Parameters of the second classical code

    Returns
    -------
    dict with n, k, d for the quantum HGP code
    """
    n_hgp = n1 * r2 + r1 * n2
    k1_prime = n1 - r1 - k1  # transpose code dimension
    k2_prime = n2 - r2 - k2
    k_hgp = k1 * k2 + max(0, k1_prime) * max(0, k2_prime)
    d_hgp = min(d1, d2)

    return {
        'n': n_hgp,
        'k': k_hgp,
        'd_lower': d_hgp,
        'rate': k_hgp / n_hgp if n_hgp > 0 else 0.0,
    }


def euler_characteristic(V: int, E: int, F: int) -> int:
    """Euler characteristic chi = V - E + F."""
    return V - E + F


def genus_from_euler(chi: int) -> float:
    """Genus g from Euler characteristic: chi = 2 - 2g => g = (2 - chi) / 2."""
    return (2 - chi) / 2


def bpt_bound(n: int, d: int) -> int:
    """
    Maximum k from the BPT bound for 2D topological codes.

    k * d^2 <= c * n for some constant c.
    Using c = 1: k <= n / d^2.
    """
    if d == 0:
        return n
    return n // (d * d)


def optimal_scale_selection(
    barcode: List[PersistenceBar],
    n_at_scale: callable
) -> Tuple[float, dict]:
    """
    Select the optimal filtration scale for CSS code construction.

    Maximizes the predicted k * d product over all possible scales.

    Parameters
    ----------
    barcode : list of PersistenceBar
    n_at_scale : callable
        Function that returns the number of physical qubits at a given scale

    Returns
    -------
    optimal_scale : float
    params : dict with k, d, rate at the optimal scale
    """
    # Candidate scales are the birth and death times of all bars
    candidates = sorted(set(
        [b.birth for b in barcode] + [b.death for b in barcode]
    ))

    best_score = -1
    best_scale = 0.0
    best_params = {}

    for scale in candidates:
        alive_bars = [b for b in barcode if b.birth <= scale < b.death]
        if not alive_bars:
            continue

        k = len(alive_bars)
        d_pred = min(b.predicted_distance() for b in alive_bars)
        n = n_at_scale(scale)

        if n == 0:
            continue

        d_singleton = quantum_singleton_bound(n, k)
        d_eff = min(d_pred, d_singleton)
        score = k * d_eff

        if score > best_score:
            best_score = score
            best_scale = scale
            best_params = {
                'k': k,
                'd_predicted': d_pred,
                'd_singleton': d_singleton,
                'd_effective': d_eff,
                'n': n,
                'rate': k / n,
                'kd_product': score,
            }

    return best_scale, best_params
