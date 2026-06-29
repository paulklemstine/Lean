#!/usr/bin/env python3
"""
Algorithms for the Bourgain-Gamburd Machine

This module implements the core computational algorithms underlying
the Bourgain-Gamburd expansion machine for finite groups:

1. Spectral gap computation via eigenvalue analysis
2. Product growth estimation (triple product set)
3. Escape from subgroups (coset concentration)
4. L2 flattening iteration
5. Mixing time estimation from spectral gap

These algorithms support the theoretical framework formalized in Lean.
"""

import numpy as np
from typing import List, Tuple, Callable, Dict, Set, Optional
from itertools import permutations, product as iterproduct


class FiniteGroup:
    """Represents a finite group with explicit multiplication table.

    Attributes:
        elements: list of group elements
        op: binary operation (multiplication)
        inv: unary operation (inverse)
        identity: identity element
    """

    def __init__(self, elements, op, inv, identity):
        self.elements = elements
        self.n = len(elements)
        self.op = op
        self.inv = inv
        self.identity = identity
        self._index = {}
        for i, e in enumerate(elements):
            key = self._key(e)
            self._index[key] = i

    def _key(self, e):
        if isinstance(e, tuple):
            return e
        return (e,)

    def idx(self, e):
        return self._index[self._key(e)]

    def mult(self, a, b):
        return self.op(a, b)

    def inverse(self, a):
        return self.inv(a)


class CayleyGraph:
    """Cayley graph Cay(G, S) of a finite group G with generating set S.

    Provides adjacency matrix, averaging operator, and spectral analysis.
    """

    def __init__(self, group: FiniteGroup, generators: list):
        """
        Args:
            group: FiniteGroup instance
            generators: list of generators (should be symmetric: s in S => s^{-1} in S)
        """
        self.group = group
        self.generators = generators
        self.n = group.n
        self._build_adjacency()

    def _build_adjacency(self):
        """Build adjacency matrix and averaging operator."""
        n = self.n
        self.adjacency = np.zeros((n, n))
        for i, g in enumerate(self.group.elements):
            for s in self.generators:
                gs = self.group.mult(g, s)
                j = self.group.idx(gs)
                self.adjacency[i, j] += 1

        # Averaging operator T_S
        deg = len(self.generators)
        self.averaging_op = self.adjacency / deg

    def spectral_gap(self) -> Tuple[float, np.ndarray]:
        """Compute the spectral gap 1 - lambda_2.

        Returns:
            gap: spectral gap (float)
            eigenvalues: all eigenvalues sorted descending
        """
        eigenvalues = np.sort(np.real(np.linalg.eigvals(self.averaging_op)))[::-1]
        gap = 1.0 - eigenvalues[1]
        return gap, eigenvalues

    def dirichlet_form(self, f: np.ndarray) -> float:
        """Compute the Dirichlet form E_S(f).

        E_S(f) = (1/(2|S|)) sum_{s in S} sum_x (f(sx) - f(x))^2

        Args:
            f: function values on group elements

        Returns:
            Dirichlet energy (float)
        """
        total = 0.0
        for s in self.generators:
            for i, x in enumerate(self.group.elements):
                sx = self.group.mult(s, x)
                j = self.group.idx(sx)
                total += (f[j] - f[i]) ** 2
        return total / (2 * len(self.generators))

    def random_walk(self, start: int = 0, steps: int = 100) -> List[float]:
        """Simulate random walk and track L2 distance from uniform.

        Args:
            start: starting vertex index
            steps: number of steps

        Returns:
            List of L2 distances from uniform distribution
        """
        mu = np.zeros(self.n)
        mu[start] = 1.0
        uniform = np.ones(self.n) / self.n

        distances = []
        for _ in range(steps):
            distances.append(np.linalg.norm(mu - uniform))
            mu = mu @ self.averaging_op

        return distances

    def mixing_time(self, epsilon: float = 0.01) -> int:
        """Estimate mixing time: smallest t such that ||mu_t - uniform||_2 < epsilon.

        Uses spectral gap bound: t_mix <= log(n/epsilon^2) / (2 * gap)
        """
        gap, _ = self.spectral_gap()
        if gap <= 0:
            return float('inf')
        return int(np.ceil(np.log(self.n / epsilon ** 2) / (2 * gap)))


def product_growth_test(group: FiniteGroup, A_indices: Set[int]) -> Dict:
    """Test the product growth hypothesis: |AAA| >= |A|^{1+delta}.

    Args:
        group: FiniteGroup instance
        A_indices: set of indices of elements in A

    Returns:
        Dictionary with:
            - card_A: |A|
            - card_AAA: |AAA|
            - growth_ratio: |AAA|/|A|
            - delta: such that |AAA| = |A|^{1+delta}
    """
    A = [group.elements[i] for i in A_indices]

    # Compute A*A
    AA_indices = set()
    for a1 in A:
        for a2 in A:
            AA_indices.add(group.idx(group.mult(a1, a2)))

    # Compute A*A*A
    AAA_indices = set()
    AA = [group.elements[i] for i in AA_indices]
    for aa in AA:
        for a in A:
            AAA_indices.add(group.idx(group.mult(aa, a)))

    card_A = len(A_indices)
    card_AAA = len(AAA_indices)
    ratio = card_AAA / card_A if card_A > 0 else 0

    if card_A > 1:
        delta = np.log(card_AAA) / np.log(card_A) - 1
    else:
        delta = 0.0

    return {
        'card_A': card_A,
        'card_AA': len(AA_indices),
        'card_AAA': card_AAA,
        'growth_ratio': ratio,
        'delta': delta
    }


def coset_concentration(group: FiniteGroup, mu: np.ndarray,
                         subgroup_indices: Set[int]) -> float:
    """Compute maximum coset concentration of a measure.

    max_g sum_{h in H} mu(g*h)

    Args:
        group: FiniteGroup instance
        mu: probability measure (array of length |G|)
        subgroup_indices: indices of elements in subgroup H

    Returns:
        Maximum concentration on any left coset of H
    """
    max_conc = 0.0
    H = [group.elements[i] for i in subgroup_indices]

    for g in group.elements:
        conc = sum(mu[group.idx(group.mult(g, h))] for h in H)
        max_conc = max(max_conc, conc)

    return max_conc


def l2_flattening_iteration(cayley: CayleyGraph, steps: int = 20) -> Dict:
    """Track L2 norm decay under iterated convolution.

    Starting from the generator measure mu_S, compute
    mu_S^{(k)} and track ||mu_S^{(k)}||_2^2.

    Args:
        cayley: CayleyGraph instance
        steps: number of convolution steps

    Returns:
        Dictionary with l2_norms, contraction_ratios, uniform_l2
    """
    mu = np.zeros(cayley.n)
    for s in cayley.generators:
        idx = cayley.group.idx(s)
        mu[idx] += 1.0 / len(cayley.generators)

    uniform_l2 = 1.0 / cayley.n

    l2_norms = [np.sum(mu ** 2)]
    contraction_ratios = []

    for _ in range(steps):
        mu = mu @ cayley.averaging_op
        new_l2 = np.sum(mu ** 2)
        if l2_norms[-1] > 0:
            contraction_ratios.append(new_l2 / l2_norms[-1])
        l2_norms.append(new_l2)

    return {
        'l2_norms': l2_norms,
        'contraction_ratios': contraction_ratios,
        'uniform_l2': uniform_l2,
        'final_ratio': l2_norms[-1] / uniform_l2
    }


def spectral_gap_from_dirichlet(cayley: CayleyGraph, num_samples: int = 100) -> float:
    """Estimate spectral gap via Dirichlet form / Rayleigh quotient.

    gap = min_{f: mean-zero} E_S(f) / ||f||_2^2

    Uses random sampling of mean-zero functions to estimate.

    Args:
        cayley: CayleyGraph instance
        num_samples: number of random test functions

    Returns:
        Estimated lower bound on spectral gap
    """
    min_ratio = float('inf')

    for _ in range(num_samples):
        # Random mean-zero function
        f = np.random.randn(cayley.n)
        f -= f.mean()

        l2_sq = np.sum(f ** 2)
        if l2_sq < 1e-12:
            continue

        dirichlet = cayley.dirichlet_form(f)
        ratio = dirichlet / l2_sq
        min_ratio = min(min_ratio, ratio)

    return min_ratio


def build_hyperoctahedral_group(n: int) -> Tuple[FiniteGroup, list]:
    """Build the hyperoctahedral group B_n with standard generators.

    Args:
        n: dimension

    Returns:
        group: FiniteGroup instance
        generators: symmetric generating set
    """
    elements = []
    for perm in permutations(range(n)):
        for signs in iterproduct([1, -1], repeat=n):
            elements.append((perm, signs))

    def op(a, b):
        pa, sa = a
        pb, sb = b
        new_perm = tuple(pa[pb[i]] for i in range(n))
        new_signs = tuple(sa[pb[i]] * sb[i] for i in range(n))
        return (new_perm, new_signs)

    def inv(a):
        pa, sa = a
        inv_perm = [0] * n
        for i in range(n):
            inv_perm[pa[i]] = i
        inv_signs = tuple(sa[inv_perm[i]] for i in range(n))
        return (tuple(inv_perm), inv_signs)

    identity = (tuple(range(n)), tuple([1] * n))
    group = FiniteGroup(elements, op, inv, identity)

    # Standard generators
    gens = []
    for i in range(n - 1):
        perm = list(range(n))
        perm[i], perm[i + 1] = perm[i + 1], perm[i]
        gens.append((tuple(perm), tuple([1] * n)))
    signs_list = [1] * n
    signs_list[0] = -1
    gens.append((tuple(range(n)), tuple(signs_list)))

    # Make symmetric
    sym_gens = list(set(gens + [inv(g) for g in gens]))

    return group, sym_gens


if __name__ == '__main__':
    print("Bourgain-Gamburd Machine: Algorithm Demonstrations")
    print("=" * 55)

    for n in [2, 3]:
        print(f"\n{'=' * 55}")
        print(f"Hyperoctahedral Group B_{n}")
        print(f"{'=' * 55}")

        group, gens = build_hyperoctahedral_group(n)
        cayley = CayleyGraph(group, gens)

        # Spectral gap
        gap, evals = cayley.spectral_gap()
        print(f"  Spectral gap (eigenvalue): {gap:.6f}")

        # Dirichlet estimate
        np.random.seed(42)
        dirichlet_gap = spectral_gap_from_dirichlet(cayley, 500)
        print(f"  Spectral gap (Dirichlet):  {dirichlet_gap:.6f}")

        # Mixing time
        t_mix = cayley.mixing_time(epsilon=0.01)
        print(f"  Mixing time (eps=0.01):    {t_mix}")

        # L2 flattening
        flat = l2_flattening_iteration(cayley, steps=15)
        print(f"  L2 contraction ratios: {[f'{r:.4f}' for r in flat['contraction_ratios'][:5]]}")

        # Product growth test
        # Take a random subset
        np.random.seed(42)
        subset_size = max(2, group.n // 4)
        A = set(np.random.choice(group.n, subset_size, replace=False))
        growth = product_growth_test(group, A)
        print(f"  Product growth: |A|={growth['card_A']}, |AAA|={growth['card_AAA']}, "
              f"delta={growth['delta']:.4f}")
