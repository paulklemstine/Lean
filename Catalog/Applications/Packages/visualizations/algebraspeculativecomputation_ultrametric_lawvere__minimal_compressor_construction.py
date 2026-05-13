#!/usr/bin/env python3
"""
Algorithms for Ultrametric Proof Compression

Implements the core algorithms from the realization duality theory:
1. Ultrametric verification
2. Proof potential computation and validation
3. Observer distance computation
4. Minimal compressor construction via observational quotient
5. Extremal generator identification
6. Tropical semimodule operations
"""

import numpy as np
from typing import Optional


class UltrametricSpace:
    """A finite ultrametric space with optional compression operator.

    Attributes:
        n: Number of points
        dist: n×n distance matrix
        names: Optional point names
        compress: Optional compression map (as array of indices)
    """

    def __init__(self, dist: np.ndarray, names: list[str] = None,
                 compress: np.ndarray = None):
        self.n = dist.shape[0]
        self.dist = dist.astype(float)
        self.names = names or [str(i) for i in range(self.n)]
        self.compress = compress

    def verify_ultrametric(self) -> tuple[bool, str]:
        """Verify ultrametric axioms. Returns (valid, message)."""
        # Reflexivity
        for i in range(self.n):
            if self.dist[i, i] != 0:
                return False, f"Reflexivity failed: d({self.names[i]},{self.names[i]}) = {self.dist[i,i]}"

        # Symmetry
        if not np.allclose(self.dist, self.dist.T):
            return False, "Symmetry failed"

        # Strong triangle inequality
        for i in range(self.n):
            for j in range(self.n):
                for k in range(self.n):
                    if self.dist[i, k] > max(self.dist[i, j], self.dist[j, k]) + 1e-10:
                        return False, (f"Ultra failed: d({self.names[i]},{self.names[k]})={self.dist[i,k]} > "
                                      f"max(d({self.names[i]},{self.names[j]})={self.dist[i,j]}, "
                                      f"d({self.names[j]},{self.names[k]})={self.dist[j,k]})")

        return True, "Valid ultrametric"

    def is_separated(self) -> bool:
        """Check if d(x,y)=0 implies x=y."""
        for i in range(self.n):
            for j in range(i+1, self.n):
                if self.dist[i, j] == 0:
                    return False
        return True

    def verify_nonexpansive(self) -> tuple[bool, str]:
        """Verify compression map is nonexpansive."""
        if self.compress is None:
            return False, "No compression map"
        for x in range(self.n):
            for y in range(self.n):
                if self.dist[self.compress[x], self.compress[y]] > self.dist[x, y] + 1e-10:
                    return False, (f"Nonexpansive failed at ({self.names[x]},{self.names[y]}): "
                                  f"d(C({self.names[x]}),C({self.names[y]})) = "
                                  f"{self.dist[self.compress[x], self.compress[y]]} > "
                                  f"{self.dist[x,y]}")
        return True, "Nonexpansive verified"


class ProofPotentialSemimodule:
    """The tropical semimodule of proof potentials over an ultrametric space.

    Implements:
    - Representable potential computation
    - 1-Lipschitz validation
    - Tropical addition (pointwise min)
    - Tropical scalar action (cost shift)
    - Generation by representables verification
    - Observer distance computation
    """

    def __init__(self, space: UltrametricSpace):
        self.space = space
        self.representables = self._compute_representables()

    def _compute_representables(self) -> np.ndarray:
        """Compute representable potentials φ_p(x) = d(x,p)."""
        return np.array([self.space.dist[:, p] for p in range(self.space.n)])

    def is_potential(self, phi: np.ndarray) -> bool:
        """Check if φ is a proof potential (1-Lipschitz)."""
        for x in range(self.space.n):
            for y in range(self.space.n):
                if phi[x] > self.space.dist[x, y] + phi[y] + 1e-10:
                    return False
        return True

    def tropical_add(self, phi: np.ndarray, psi: np.ndarray) -> np.ndarray:
        """Tropical addition: pointwise minimum."""
        return np.minimum(phi, psi)

    def tropical_scalar(self, c: float, phi: np.ndarray) -> np.ndarray:
        """Tropical scalar action: φ + c."""
        return phi + c

    def pullback(self, phi: np.ndarray) -> np.ndarray:
        """Compression pullback: C*φ = φ ∘ C."""
        if self.space.compress is None:
            raise ValueError("No compression map defined")
        return phi[self.space.compress]

    def verify_generation(self, phi: np.ndarray) -> tuple[bool, np.ndarray]:
        """Verify φ(x) = inf_p (d(x,p) + φ(p)).

        Returns (matches, reconstructed_phi).
        """
        reconstructed = np.full(self.space.n, np.inf)
        for p in range(self.space.n):
            shifted = self.space.dist[:, p] + phi[p]
            reconstructed = np.minimum(reconstructed, shifted)
        matches = np.allclose(phi, reconstructed)
        return matches, reconstructed

    def observer_distance(self, x: int, y: int) -> float:
        """Compute observer distance between states x and y.

        d_obs(x,y) = sup_φ max(φ(x)-φ(y), φ(y)-φ(x))
        where the sup is over all representable potentials.
        """
        max_diff = 0.0
        for phi in self.representables:
            diff = max(phi[x] - phi[y], phi[y] - phi[x])
            max_diff = max(max_diff, diff)
        return max_diff

    def observer_distance_matrix(self) -> np.ndarray:
        """Compute full observer distance matrix."""
        obs = np.zeros((self.space.n, self.space.n))
        for x in range(self.space.n):
            for y in range(self.space.n):
                obs[x, y] = self.observer_distance(x, y)
        return obs

    def verify_observer_recovery(self) -> tuple[bool, float]:
        """Verify d_obs = d. Returns (matches, max_error)."""
        obs = self.observer_distance_matrix()
        max_err = np.max(np.abs(obs - self.space.dist))
        return max_err < 1e-10, max_err


class MinimalCompressor:
    """Computes the minimal compressor via observational quotient.

    Algorithm:
    1. Compute representable potentials
    2. Identify observationally equivalent states
    3. Build quotient space
    4. Verify compression descends to quotient
    """

    def __init__(self, semimodule: ProofPotentialSemimodule):
        self.semimodule = semimodule
        self.space = semimodule.space
        self._compute_quotient()

    def _compute_quotient(self):
        """Compute observational equivalence classes."""
        n = self.space.n
        pots = self.semimodule.representables

        # Union-Find for equivalence classes
        parent = list(range(n))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x, y):
            px, py = find(x), find(y)
            if px != py:
                parent[px] = py

        # Merge observationally equivalent states
        for x in range(n):
            for y in range(x + 1, n):
                equiv = all(abs(phi[x] - phi[y]) < 1e-10 for phi in pots)
                if equiv:
                    union(x, y)

        # Build class map
        roots = sorted(set(find(i) for i in range(n)))
        self.class_map = {r: idx for idx, r in enumerate(roots)}
        self.labels = [self.class_map[find(i)] for i in range(n)]
        self.num_classes = len(roots)
        self.class_representatives = roots

    @property
    def state_count(self) -> int:
        """Number of states in minimal compressor."""
        return self.num_classes

    def quotient_distance(self) -> np.ndarray:
        """Distance matrix on quotient space."""
        d_q = np.zeros((self.num_classes, self.num_classes))
        for i in range(self.num_classes):
            for j in range(self.num_classes):
                ri = self.class_representatives[i]
                rj = self.class_representatives[j]
                d_q[i, j] = self.space.dist[ri, rj]
        return d_q

    def verify_compression_descends(self) -> bool:
        """Verify that C preserves equivalence classes."""
        if self.space.compress is None:
            return True
        for x in range(self.space.n):
            for y in range(self.space.n):
                if self.labels[x] == self.labels[y]:
                    cx, cy = self.space.compress[x], self.space.compress[y]
                    if self.labels[cx] != self.labels[cy]:
                        return False
        return True

    def generator_rank(self) -> int:
        """Extremal generator rank = number of minimal compressor states."""
        return self.num_classes


def build_dendrogram_ultrametric(tree: list[tuple]) -> np.ndarray:
    """Build an ultrametric distance matrix from a dendrogram specification.

    Args:
        tree: List of (set_of_leaves, merge_height) pairs, from finest to coarsest.
              Each merge groups subsets at the specified height.

    Returns:
        Distance matrix.
    """
    # Collect all leaves
    all_leaves = set()
    for leaves, _ in tree:
        all_leaves.update(leaves)
    leaves = sorted(all_leaves)
    n = len(leaves)
    leaf_idx = {l: i for i, l in enumerate(leaves)}

    d = np.zeros((n, n))
    # Start with infinite distance, then set merge heights
    d.fill(np.inf)
    np.fill_diagonal(d, 0)

    for merge_set, height in tree:
        indices = [leaf_idx[l] for l in merge_set]
        for i in indices:
            for j in indices:
                if d[i, j] > height:
                    d[i, j] = height

    return d


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    print("Ultrametric Proof Compression - Algorithm Suite\n")

    # Example 1: Build from dendrogram
    print("Building ultrametric from dendrogram...")
    d = build_dendrogram_ultrametric([
        ({0, 1}, 2),
        ({2, 3}, 1),
        ({0, 1, 2, 3}, 4),
    ])

    space = UltrametricSpace(d, names=["A", "B", "C", "D"],
                              compress=np.array([0, 0, 2, 2]))

    valid, msg = space.verify_ultrametric()
    print(f"  Ultrametric: {msg}")
    print(f"  Separated: {space.is_separated()}")

    nonexp_valid, nonexp_msg = space.verify_nonexpansive()
    print(f"  Nonexpansive: {nonexp_msg}")

    # Build semimodule
    semimodule = ProofPotentialSemimodule(space)

    # Observer distance recovery
    recovery, max_err = semimodule.verify_observer_recovery()
    print(f"  Observer recovery: d_obs = d? {recovery} (max error: {max_err})")

    # Minimal compressor
    mc = MinimalCompressor(semimodule)
    print(f"  Minimal compressor states: {mc.state_count}")
    print(f"  Generator rank: {mc.generator_rank()}")
    print(f"  Compression descends: {mc.verify_compression_descends()}")

    # Generation verification
    phi_test = np.array([1.0, 2.0, 3.0, 3.5])
    if semimodule.is_potential(phi_test):
        gen_ok, recon = semimodule.verify_generation(phi_test)
        print(f"\n  Generation test for φ={phi_test}:")
        print(f"    Is potential: True")
        print(f"    φ = inf_p(d(·,p)+φ(p))? {gen_ok}")
    else:
        print(f"\n  Test φ={phi_test} is not a potential")
