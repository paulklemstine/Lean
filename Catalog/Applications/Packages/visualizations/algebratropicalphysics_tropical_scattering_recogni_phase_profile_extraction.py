#!/usr/bin/env python3
"""
Tropical Scattering Recognition Duality — Core Algorithms

This module implements the key algorithms from the tropical scattering
recognition duality theory:

1. Phase profile extraction from tropical transfer representations
2. Canonical minimal reconstruction from phase profiles
3. Domination cell decomposition
4. Levinson bound verification
5. Tropical isomorphism detection
6. Channel map functoriality (pullback/pushforward)
"""

import numpy as np
from typing import List, Tuple, Dict, Optional, Set
from dataclasses import dataclass


# ─────────────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────────────

@dataclass
class PhaseProfile:
    """
    A tropical phase profile: observable scattering data at discrete channels.
    
    Attributes:
        values: Array of shape (m,) — the profile value at each channel
        m: Number of channels
    """
    values: np.ndarray
    
    @property
    def m(self) -> int:
        return len(self.values)
    
    def breakpoint_count(self) -> int:
        """Count the number of distinct values in the profile."""
        return len(set(self.values.round(10)))
    
    def __repr__(self):
        return f"PhaseProfile(m={self.m}, values={self.values})"


@dataclass
class ScatteringRep:
    """
    A tropical scattering representation.
    
    Attributes:
        weight: Array of shape (m, n) — weight[q][i] is weight of generator i at channel q
        n: Number of generators (bound states)
        m: Number of channels
    """
    weight: np.ndarray
    
    @property
    def n(self) -> int:
        return self.weight.shape[1] if self.weight.ndim == 2 else 0
    
    @property
    def m(self) -> int:
        return self.weight.shape[0]


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Phase Profile Extraction
# ─────────────────────────────────────────────────────────────────────

def extract_profile(rep: ScatteringRep) -> PhaseProfile:
    """
    Extract the phase profile from a scattering representation.
    
    Algorithm:
        For each channel q, compute φ(q) = max_{i=0..n-1} weight(q, i)
    
    Time complexity: O(m * n)
    Space complexity: O(m)
    
    Args:
        rep: A tropical scattering representation
        
    Returns:
        The induced phase profile
    """
    if rep.n == 0:
        return PhaseProfile(np.full(rep.m, -np.inf))
    return PhaseProfile(np.max(rep.weight, axis=1))


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Canonical Minimal Reconstruction
# ─────────────────────────────────────────────────────────────────────

def reconstruct_canonical(profile: PhaseProfile) -> ScatteringRep:
    """
    Canonical 1-generator reconstruction from a phase profile.
    
    Algorithm:
        Create a single generator whose weight at each channel equals the profile value.
        This is the unique minimal reconstruction (up to tropical isomorphism).
    
    Time complexity: O(m)
    Space complexity: O(m)
    
    Properties (formally verified):
        - Correct: extract_profile(reconstruct(φ)) = φ
        - Minimal: every generator strictly dominates somewhere
        - Causally convex: every generator weakly dominates somewhere
    
    Args:
        profile: A phase profile
        
    Returns:
        The canonical minimal scattering representation
    """
    return ScatteringRep(profile.values.reshape(-1, 1))


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Domination Cell Decomposition
# ─────────────────────────────────────────────────────────────────────

def compute_domination_cells(rep: ScatteringRep) -> Dict[int, List[int]]:
    """
    Compute the domination cell decomposition of a representation.
    
    Algorithm:
        For each channel q, find the generator with maximum weight.
        Group channels by their dominant generator.
    
    Time complexity: O(m * n)
    Space complexity: O(m)
    
    Args:
        rep: A scattering representation
        
    Returns:
        Dictionary mapping generator index to list of channels where it dominates
    """
    cells: Dict[int, List[int]] = {i: [] for i in range(rep.n)}
    for q in range(rep.m):
        dom = int(np.argmax(rep.weight[q]))
        cells[dom].append(q)
    return cells


def compute_strict_domination_cells(rep: ScatteringRep) -> Dict[int, List[int]]:
    """
    Compute strict domination cells (where a generator is the unique maximum).
    
    Time complexity: O(m * n)
    """
    cells: Dict[int, List[int]] = {i: [] for i in range(rep.n)}
    for q in range(rep.m):
        max_val = np.max(rep.weight[q])
        max_indices = np.where(np.isclose(rep.weight[q], max_val))[0]
        if len(max_indices) == 1:
            cells[int(max_indices[0])].append(q)
    return cells


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Minimality and Levinson Bound Verification
# ─────────────────────────────────────────────────────────────────────

def check_minimality(rep: ScatteringRep) -> Tuple[bool, Optional[int]]:
    """
    Check if a representation is minimal (every generator strictly dominates somewhere).
    
    Algorithm:
        For each generator i, search for a channel where it uniquely achieves the max.
        If no such channel exists for some generator, return False and the redundant generator.
    
    Time complexity: O(m * n^2) worst case, O(m * n) typical
    
    Returns:
        (is_minimal, first_redundant_generator_or_None)
    """
    for i in range(rep.n):
        found_strict = False
        for q in range(rep.m):
            is_strict = True
            for j in range(rep.n):
                if j != i and rep.weight[q, j] >= rep.weight[q, i]:
                    is_strict = False
                    break
            if is_strict:
                found_strict = True
                break
        if not found_strict:
            return False, i
    return True, None


def verify_levinson_bound(rep: ScatteringRep) -> Tuple[bool, str]:
    """
    Verify the tropical Levinson bound: n ≤ m for minimal representations.
    
    The bound states that the number of generators (bound states) in any
    minimal representation cannot exceed the number of channels. This is
    because each generator needs a distinct witnessing channel.
    
    Time complexity: O(m * n^2)
    
    Returns:
        (bound_satisfied, explanation_string)
    """
    is_min, redundant = check_minimality(rep)
    
    if not is_min:
        return True, f"Not minimal (generator {redundant} is redundant), bound vacuously satisfied"
    
    satisfied = rep.n <= rep.m
    explanation = (
        f"n={rep.n}, m={rep.m}: "
        f"{'SATISFIED' if satisfied else 'VIOLATED'} (n ≤ m)"
    )
    return satisfied, explanation


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Tropical Isomorphism Detection
# ─────────────────────────────────────────────────────────────────────

def find_tropical_isomorphism(
    M1: ScatteringRep, M2: ScatteringRep, tol: float = 1e-10
) -> Optional[np.ndarray]:
    """
    Find a tropical isomorphism between two representations, if one exists.
    
    Algorithm:
        A tropical isomorphism is a permutation σ of generators such that
        M1.weight[q][i] = M2.weight[q][σ(i)] for all q, i.
        
        We use a canonical sorting approach: sort generators by their weight
        vectors lexicographically and compare.
    
    Time complexity: O(n! * m * n) worst case for brute force;
                     O(m * n * log(n)) for the canonical sorting approach
    
    Args:
        M1, M2: Two scattering representations
        tol: Numerical tolerance for floating point comparison
    
    Returns:
        Permutation array if isomorphic, None otherwise
    """
    if M1.n != M2.n or M1.m != M2.m:
        return None
    
    if M1.n == 0:
        return np.array([], dtype=int)
    
    # Canonical sorting approach
    # Sort columns of each weight matrix lexicographically
    def sort_key(col_idx, W):
        return tuple(W[:, col_idx])
    
    perm1 = sorted(range(M1.n), key=lambda i: sort_key(i, M1.weight))
    perm2 = sorted(range(M2.n), key=lambda i: sort_key(i, M2.weight))
    
    # Check if sorted weight matrices match
    W1_sorted = M1.weight[:, perm1]
    W2_sorted = M2.weight[:, perm2]
    
    if not np.allclose(W1_sorted, W2_sorted, atol=tol):
        return None
    
    # Construct the permutation: perm1[k] in M1 maps to perm2[k] in M2
    sigma = np.zeros(M1.n, dtype=int)
    for k in range(M1.n):
        sigma[perm1[k]] = perm2[k]
    
    return sigma


# ─────────────────────────────────────────────────────────────────────
# Algorithm 6: Channel Map Functoriality
# ─────────────────────────────────────────────────────────────────────

def pullback_rep(rep: ScatteringRep, channel_map: List[int]) -> ScatteringRep:
    """
    Pull back a representation along a channel map.
    
    Given f: Q' → Q (channel_map[q'] = f(q')),
    the pullback has weight'[q'][i] = weight[f(q')][i].
    
    Time complexity: O(|Q'| * n)
    
    Args:
        rep: Original representation over Q
        channel_map: List of indices mapping Q' -> Q
        
    Returns:
        Pullback representation over Q'
    """
    return ScatteringRep(rep.weight[channel_map])


def verify_functoriality(
    rep: ScatteringRep, channel_map: List[int]
) -> bool:
    """
    Verify that profile extraction commutes with pullback:
    profile(comap(M, f)) = profile(M) ∘ f
    
    Time complexity: O(m' * n)
    """
    pullback = pullback_rep(rep, channel_map)
    profile_of_pullback = extract_profile(pullback).values
    profile_composed = extract_profile(rep).values[channel_map]
    return np.allclose(profile_of_pullback, profile_composed)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 7: Multi-Generator Reconstruction from Cell Data
# ─────────────────────────────────────────────────────────────────────

def reconstruct_from_cells(
    profile: PhaseProfile,
    cells: Dict[int, List[int]],
    background: float = -np.inf
) -> ScatteringRep:
    """
    Reconstruct a multi-generator representation from a profile and cell partition.
    
    Each cell becomes a generator. The generator's weight at channels in its cell
    equals the profile value; at other channels, it gets the background value.
    
    Time complexity: O(m * k) where k = number of cells
    
    Args:
        profile: The target phase profile
        cells: Cell partition (generator_id -> list of channels)
        background: Weight value for non-dominant channels
        
    Returns:
        A scattering representation with one generator per cell
    """
    n = len(cells)
    m = profile.m
    W = np.full((m, n), background)
    
    for gen_idx, (_, channels) in enumerate(sorted(cells.items())):
        for q in channels:
            W[q, gen_idx] = profile.values[q]
    
    return ScatteringRep(W)


# ─────────────────────────────────────────────────────────────────────
# Example Usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Scattering Recognition Duality — Algorithm Demonstrations")
    print("=" * 70)
    
    # Example 1: Full pipeline
    print("\n--- Example 1: Full Reconstruction Pipeline ---")
    W = np.array([
        [3, 7, 2],
        [5, 4, 6],
        [8, 1, 3],
        [2, 9, 4],
        [1, 3, 10],
    ], dtype=float)
    
    M = ScatteringRep(W)
    phi = extract_profile(M)
    M_recon = reconstruct_canonical(phi)
    phi_recon = extract_profile(M_recon)
    
    print(f"Original: {M.n} generators, {M.m} channels")
    print(f"Profile: {phi.values}")
    print(f"Reconstruction: {M_recon.n} generator")
    print(f"Profile preserved: {np.allclose(phi.values, phi_recon.values)}")
    
    # Example 2: Levinson bound
    print("\n--- Example 2: Levinson Bound Verification ---")
    is_min, redundant = check_minimality(M)
    print(f"Original rep minimal: {is_min}")
    satisfied, explanation = verify_levinson_bound(M)
    print(f"Levinson bound: {explanation}")
    
    # Example 3: Isomorphism detection
    print("\n--- Example 3: Isomorphism Detection ---")
    perm = np.array([2, 0, 1])
    M2 = ScatteringRep(M.weight[:, perm])
    sigma = find_tropical_isomorphism(M, M2)
    print(f"Isomorphism found: {sigma}")
    print(f"Original permutation: {perm}")
    
    # Example 4: Functoriality
    print("\n--- Example 4: Functoriality Verification ---")
    f = [0, 2, 4]
    valid = verify_functoriality(M, f)
    print(f"Channel map f = {f}")
    print(f"Functoriality holds: {valid}")
    
    # Example 5: Cell-based reconstruction
    print("\n--- Example 5: Cell-Based Reconstruction ---")
    cells = compute_domination_cells(M)
    print(f"Domination cells: {cells}")
    M_cell = reconstruct_from_cells(phi, cells)
    phi_cell = extract_profile(M_cell)
    print(f"Cell reconstruction preserves profile: {np.allclose(phi.values, phi_cell.values)}")
