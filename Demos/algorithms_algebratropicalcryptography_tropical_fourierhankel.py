#!/usr/bin/env python3
"""
Tropical Hankel Duality — Algorithms

Implements the core algorithms from the formalization:
1. Tropical Hankel factorization extraction
2. Collision reconstruction from factorization
3. Fiber enumeration
4. One-wayness diagnostic

Author: Harmonic Research
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass
import itertools


# ============================================================
# Data Structures
# ============================================================

@dataclass
class CollisionWitness:
    """A certified collision witness: two distinct inputs with equal outputs."""
    x1: List[int]
    x2: List[int]
    output: float
    
    def __str__(self):
        w1 = ''.join(map(str, self.x1)) if self.x1 else 'ε'
        w2 = ''.join(map(str, self.x2)) if self.x2 else 'ε'
        return f"Collision: f({w1}) = f({w2}) = {self.output:.6f}"


@dataclass
class TropicalHankelFactorization:
    """
    A tropical Hankel factorization of rank n.
    
    Satisfies: f(u ++ v) = min_i (phi(u)[i] + psi(v)[i])
    for all words u, v.
    """
    rank: int
    phi: dict  # word -> np.ndarray (prefix summary)
    psi: dict  # word -> np.ndarray (suffix summary)
    
    def reconstruct(self, prefix: tuple, suffix: tuple) -> float:
        """Reconstruct f(prefix ++ suffix) from the factorization."""
        a = self.phi.get(prefix)
        b = self.psi.get(suffix)
        if a is None or b is None:
            raise KeyError(f"Word not in factorization domain")
        return float(np.min(a + b))


class MinPlusAutomaton:
    """Min-plus weighted automaton with n states."""
    
    def __init__(self, n_states: int, alphabet_size: int,
                 init: np.ndarray, transitions: List[np.ndarray],
                 final: np.ndarray):
        self.n = n_states
        self.sigma = alphabet_size
        self.init = init.copy()
        self.transitions = [t.copy() for t in transitions]
        self.final = final.copy()
    
    def state_summary(self, word: List[int]) -> np.ndarray:
        """Compute state summary after reading word."""
        vec = self.init.copy().reshape(1, -1)
        for a in word:
            n = self.n
            new_vec = np.full((1, n), np.inf)
            for j in range(n):
                for k in range(n):
                    new_vec[0, j] = min(new_vec[0, j], 
                                        vec[0, k] + self.transitions[a][k, j])
            vec = new_vec
        return vec.flatten()
    
    def suffix_cost(self, word: List[int]) -> np.ndarray:
        """Compute suffix cost vector for reading word then stopping."""
        vec = self.final.copy().reshape(-1, 1)
        for a in reversed(word):
            n = self.n
            new_vec = np.full((n, 1), np.inf)
            for i in range(n):
                for j in range(n):
                    new_vec[i, 0] = min(new_vec[i, 0],
                                        self.transitions[a][i, j] + vec[j, 0])
            vec = new_vec
        return vec.flatten()
    
    def evaluate(self, word: List[int]) -> float:
        """Compute f(word)."""
        summary = self.state_summary(word)
        return float(np.min(summary + self.final))
    
    def extract_factorization(self, max_length: int) -> TropicalHankelFactorization:
        """
        Extract a tropical Hankel factorization from this automaton.
        
        Algorithm:
        1. For each word u up to max_length, compute φ(u) = state_summary(u)
        2. For each word v up to max_length, compute ψ(v) = suffix_cost(v)
        3. Return the factorization of rank n (number of states)
        
        Complexity: O(|Σ|^L * n^2) where L = max_length
        
        Correctness follows from the theorem:
        f(u ++ v) = min_i (state_summary(u)[i] + suffix_cost(v)[i])
        """
        phi = {}
        psi = {}
        
        words = [[]]
        for length in range(1, max_length + 1):
            for w in itertools.product(range(self.sigma), repeat=length):
                words.append(list(w))
        
        for w in words:
            key = tuple(w)
            phi[key] = self.state_summary(w)
            psi[key] = self.suffix_cost(w)
        
        return TropicalHankelFactorization(
            rank=self.n,
            phi=phi,
            psi=psi
        )


# ============================================================
# Algorithm 1: Collision Reconstruction
# ============================================================

def reconstruct_collisions(
    aut: MinPlusAutomaton,
    max_length: int,
    tol: float = 1e-8
) -> List[CollisionWitness]:
    """
    Reconstruct all collision witnesses up to given word length.
    
    Algorithm:
    1. Compute state summaries for all words
    2. Group words by (rounded) state summary
    3. For each group with ≥2 members, emit collision witnesses
    
    Complexity: O(|Σ|^L * n) where L = max_length, n = states
    
    Correctness: By Theorem 3.6 (State Collision Propagation),
    equal state summaries guarantee equal outputs.
    """
    # Phase 1: Compute all state summaries
    summary_groups: Dict[tuple, List[List[int]]] = {}
    
    words = [[]]
    for length in range(1, max_length + 1):
        for w in itertools.product(range(aut.sigma), repeat=length):
            words.append(list(w))
    
    for w in words:
        summary = tuple(np.round(aut.state_summary(w), decimals=8))
        if summary not in summary_groups:
            summary_groups[summary] = []
        summary_groups[summary].append(w)
    
    # Phase 2: Extract collision witnesses
    collisions = []
    for summary, members in summary_groups.items():
        if len(members) >= 2:
            output = aut.evaluate(members[0])
            for i in range(1, len(members)):
                collisions.append(CollisionWitness(
                    x1=members[0],
                    x2=members[i],
                    output=output
                ))
    
    return collisions


# ============================================================
# Algorithm 2: Fiber Enumeration
# ============================================================

def enumerate_fiber(
    aut: MinPlusAutomaton,
    target_output: float,
    max_length: int,
    tol: float = 1e-6
) -> List[List[int]]:
    """
    Enumerate all preimages of a target output value up to given length.
    
    Algorithm:
    1. Compute f(w) for all words w up to max_length
    2. Filter to those with |f(w) - target| < tol
    
    Complexity: O(|Σ|^L * n) where L = max_length
    
    The factorization theorem (Theorem 6.4) shows this can be
    optimized by searching state summaries instead of words.
    """
    preimages = []
    
    words = [[]]
    for length in range(1, max_length + 1):
        for w in itertools.product(range(aut.sigma), repeat=length):
            words.append(list(w))
    
    for w in words:
        if abs(aut.evaluate(w) - target_output) < tol:
            preimages.append(w)
    
    return preimages


def enumerate_fiber_via_factorization(
    factorization: TropicalHankelFactorization,
    target_output: float,
    tol: float = 1e-6
) -> List[tuple]:
    """
    Enumerate fiber using the factorization structure.
    
    More efficient: groups words by state summary first,
    then checks only representative outputs.
    """
    # Group words by phi value
    phi_groups: Dict[tuple, List[tuple]] = {}
    for word, phi_val in factorization.phi.items():
        key = tuple(np.round(phi_val, 8))
        if key not in phi_groups:
            phi_groups[key] = []
        phi_groups[key].append(word)
    
    # For each phi class, check if it maps to target
    empty_psi = factorization.psi.get((), None)
    if empty_psi is None:
        return []
    
    preimages = []
    for phi_key, members in phi_groups.items():
        phi_val = factorization.phi[members[0]]
        output = float(np.min(phi_val + empty_psi))
        if abs(output - target_output) < tol:
            preimages.extend(members)
    
    return preimages


# ============================================================
# Algorithm 3: One-Wayness Diagnostic
# ============================================================

def diagnose_one_wayness(
    aut: MinPlusAutomaton,
    max_length: int = 8
) -> Dict:
    """
    Diagnose whether an automaton-based hash function exhibits
    one-wayness properties.
    
    Returns a diagnostic report including:
    - Number of states (Hankel rank upper bound)
    - Collision density at each input length
    - Estimated one-wayness score
    
    A low score indicates the function is NOT one-way.
    """
    report = {
        'n_states': aut.n,
        'alphabet_size': aut.sigma,
        'rank_upper_bound': aut.n,
        'length_analysis': [],
        'verdict': ''
    }
    
    cumulative_words = []
    for max_len in range(1, max_length + 1):
        new_words = list(itertools.product(range(aut.sigma), repeat=max_len))
        cumulative_words.extend([list(w) for w in new_words])
        
        # Count distinct summaries and outputs
        summaries = set()
        outputs = set()
        for w in cumulative_words:
            summaries.add(tuple(np.round(aut.state_summary(w), 6)))
            outputs.add(round(aut.evaluate(w), 6))
        
        n_words = len(cumulative_words)
        n_summaries = len(summaries)
        n_outputs = len(outputs)
        collision_ratio = 1.0 - n_outputs / n_words if n_words > 0 else 0
        
        report['length_analysis'].append({
            'max_length': max_len,
            'n_words': n_words,
            'n_distinct_summaries': n_summaries,
            'n_distinct_outputs': n_outputs,
            'collision_ratio': collision_ratio,
            'pigeonhole_bound': max(0, n_words - n_summaries)
        })
    
    # Verdict
    last = report['length_analysis'][-1]
    if last['collision_ratio'] > 0.5:
        report['verdict'] = 'DEFINITELY NOT ONE-WAY: >50% collision density'
    elif last['collision_ratio'] > 0.1:
        report['verdict'] = 'LIKELY NOT ONE-WAY: significant collision density'
    elif last['n_distinct_summaries'] < last['n_words'] * 0.9:
        report['verdict'] = 'STRUCTURALLY WEAK: state space saturation detected'
    else:
        report['verdict'] = 'INCONCLUSIVE: rank may still be bounded at larger scales'
    
    return report


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("Tropical Hankel Duality — Algorithm Demonstrations")
    print("=" * 60)
    
    # Create a test automaton
    rng = np.random.RandomState(42)
    n_states = 3
    aut = MinPlusAutomaton(
        n_states=n_states,
        alphabet_size=2,
        init=rng.uniform(0, 10, n_states),
        transitions=[rng.uniform(0, 10, (n_states, n_states)) for _ in range(2)],
        final=rng.uniform(0, 10, n_states)
    )
    
    # Algorithm 1: Collision Reconstruction
    print("\n--- Algorithm 1: Collision Reconstruction ---")
    collisions = reconstruct_collisions(aut, max_length=5)
    print(f"Found {len(collisions)} collision witnesses (words up to length 5)")
    for c in collisions[:5]:
        print(f"  {c}")
    
    # Algorithm 2: Fiber Enumeration
    print("\n--- Algorithm 2: Fiber Enumeration ---")
    test_output = aut.evaluate([0, 1, 0])
    fiber = enumerate_fiber(aut, test_output, max_length=5)
    print(f"Target output: {test_output:.6f}")
    print(f"Preimages found (up to length 5): {len(fiber)}")
    for w in fiber[:5]:
        word_str = ''.join(map(str, w)) if w else 'ε'
        print(f"  f({word_str}) = {aut.evaluate(w):.6f}")
    
    # Algorithm 2b: Fiber via factorization
    print("\n--- Algorithm 2b: Fiber via Factorization ---")
    fact = aut.extract_factorization(max_length=5)
    fiber_fact = enumerate_fiber_via_factorization(fact, test_output)
    print(f"Preimages via factorization: {len(fiber_fact)}")
    
    # Algorithm 3: One-Wayness Diagnostic
    print("\n--- Algorithm 3: One-Wayness Diagnostic ---")
    report = diagnose_one_wayness(aut, max_length=7)
    print(f"States: {report['n_states']}")
    print(f"Rank upper bound: {report['rank_upper_bound']}")
    print(f"\nLength analysis:")
    print(f"{'Len':>4} {'Words':>8} {'States':>8} {'Outputs':>8} {'Collision%':>10}")
    for entry in report['length_analysis']:
        print(f"{entry['max_length']:>4} {entry['n_words']:>8} "
              f"{entry['n_distinct_summaries']:>8} "
              f"{entry['n_distinct_outputs']:>8} "
              f"{entry['collision_ratio']*100:>9.1f}%")
    print(f"\nVerdict: {report['verdict']}")
