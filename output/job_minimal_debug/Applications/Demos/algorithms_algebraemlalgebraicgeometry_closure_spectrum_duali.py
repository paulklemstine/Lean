#!/usr/bin/env python3
"""
Closure Spectrum Duality — Core Algorithms

Implements:
1. Closure operator computation (from Horn clauses / implication bases)
2. Closed theory enumeration
3. Prime spectrum computation
4. Reconstruction via prime intersection
5. Basic open set computation
6. Specialization order computation
"""

from __future__ import annotations
from dataclasses import dataclass, field
from itertools import combinations
from typing import Callable, Optional
import time


@dataclass(frozen=True)
class HornClause:
    """A Horn clause: body → head.
    body is a frozenset of generators, head is a single generator."""
    body: frozenset
    head: str

    def __repr__(self):
        if not self.body:
            return f"⊤ → {self.head}"
        return f"{' ∧ '.join(sorted(self.body))} → {self.head}"


@dataclass
class ClosureSystem:
    """A finite closure system defined by Horn clauses on a finite set of generators."""
    generators: frozenset
    clauses: list[HornClause]
    _closed_cache: Optional[list[frozenset]] = field(default=None, repr=False)
    _prime_cache: Optional[list[frozenset]] = field(default=None, repr=False)

    def closure(self, S: frozenset) -> frozenset:
        """Compute Cl(S) by iterating Horn clause application until fixpoint.
        
        Time complexity: O(|clauses| × |G|) per iteration, O(|G|) iterations worst case.
        Total: O(|clauses| × |G|²).
        """
        result = set(S & self.generators)
        changed = True
        while changed:
            changed = False
            for clause in self.clauses:
                if clause.body <= result and clause.head not in result:
                    result.add(clause.head)
                    changed = True
        return frozenset(result)

    def is_closed(self, T: frozenset) -> bool:
        """Check if T is a closed theory."""
        return self.closure(T) == T

    def closed_theories(self) -> list[frozenset]:
        """Enumerate all closed theories.
        
        Time complexity: O(2^|G| × |clauses| × |G|²).
        """
        if self._closed_cache is not None:
            return self._closed_cache

        result = []
        for r in range(len(self.generators) + 1):
            for combo in combinations(sorted(self.generators), r):
                S = frozenset(combo)
                if self.closure(S) == S:
                    result.append(S)
        self._closed_cache = result
        return result

    def is_meet_irreducible(self, P: frozenset) -> bool:
        """Check if P is meet-irreducible among closed theories.
        
        Time complexity: O(k²) where k = number of closed theories.
        """
        if P == self.generators:
            return False
        closed = self.closed_theories()
        for A in closed:
            if A == P:
                continue
            for B in closed:
                if B == P:
                    continue
                if A & B == P:
                    return False
        return True

    def prime_spectrum(self) -> list[frozenset]:
        """Compute the prime spectrum: all meet-irreducible closed theories.
        
        Time complexity: O(k³) where k = number of closed theories.
        """
        if self._prime_cache is not None:
            return self._prime_cache

        closed = self.closed_theories()
        primes = [P for P in closed if self.is_meet_irreducible(P)]
        self._prime_cache = primes
        return primes

    def reconstruct(self, A: frozenset) -> frozenset:
        """Reconstruct Cl(A) as ∩{P prime | A ⊆ P}.
        
        Time complexity: O(|primes| × |G|).
        """
        primes = self.prime_spectrum()
        containing = [P for P in primes if A <= P]
        if not containing:
            return self.generators
        result = self.generators
        for P in containing:
            result = result & P
        return result

    def basic_open(self, F: frozenset) -> list[frozenset]:
        """Compute D(F) = {P prime | F ⊄ P}.
        
        Time complexity: O(|primes| × |F|).
        """
        return [P for P in self.prime_spectrum() if not F <= P]

    def specialization_order(self) -> list[tuple[frozenset, frozenset]]:
        """Compute the specialization preorder on the prime spectrum.
        P specializes to Q (P ⤳ Q) iff Q ⊆ P (containment reversal).
        
        Returns list of (P, Q) pairs where P specializes to Q.
        """
        primes = self.prime_spectrum()
        edges = []
        for P in primes:
            for Q in primes:
                if Q <= P and Q != P:
                    edges.append((P, Q))
        return edges

    def verify_reconstruction(self) -> bool:
        """Verify the reconstruction theorem for all subsets.
        
        Returns True if Cl(A) = ∩{P prime | A ⊆ P} for all A ⊆ G.
        """
        for r in range(len(self.generators) + 1):
            for combo in combinations(sorted(self.generators), r):
                A = frozenset(combo)
                if self.closure(A) != self.reconstruct(A):
                    return False
        return True

    def verify_basis_stability(self) -> bool:
        """Verify D(F1 ∪ F2) = D(F1) ∪ D(F2) for all finite F1, F2."""
        elems = sorted(self.generators)
        for r1 in range(len(elems) + 1):
            for combo1 in combinations(elems, r1):
                F1 = frozenset(combo1)
                for r2 in range(len(elems) + 1):
                    for combo2 in combinations(elems, r2):
                        F2 = frozenset(combo2)
                        lhs = set(map(id, self.basic_open(F1 | F2)))
                        d1 = self.basic_open(F1)
                        d2 = self.basic_open(F2)
                        rhs_list = list({id(p): p for p in d1 + d2}.values())
                        # Compare as sets of frozensets
                        if sorted(self.basic_open(F1 | F2), key=sorted) != \
                           sorted(list(set(d1) | set(d2)), key=sorted):
                            return False
        return True

    def summary(self) -> str:
        """Print a summary of the closure system and its spectrum."""
        lines = []
        lines.append(f"Generators: {sorted(self.generators)}")
        lines.append(f"Horn clauses ({len(self.clauses)}):")
        for c in self.clauses:
            lines.append(f"  {c}")
        
        closed = self.closed_theories()
        lines.append(f"\nClosed theories ({len(closed)}):")
        for T in sorted(closed, key=lambda s: (len(s), sorted(s))):
            lines.append(f"  {set(T) if T else '{}'}")
        
        primes = self.prime_spectrum()
        lines.append(f"\nPrime spectrum ({len(primes)} points):")
        for P in sorted(primes, key=lambda s: (len(s), sorted(s))):
            lines.append(f"  {set(P) if P else '{}'}")
        
        spec = self.specialization_order()
        if spec:
            lines.append(f"\nSpecialization order ({len(spec)} relations):")
            for P, Q in spec:
                lines.append(f"  {set(P)} ⤳ {set(Q)}")
        
        return "\n".join(lines)


def from_implication_basis(generators: set, implications: list[tuple[set, str]]) -> ClosureSystem:
    """Create a closure system from an implication basis.
    
    Args:
        generators: set of generator names
        implications: list of (body, head) pairs where body is a set and head is a string
    """
    clauses = [HornClause(frozenset(body), head) for body, head in implications]
    return ClosureSystem(frozenset(generators), clauses)


def benchmark(system: ClosureSystem) -> dict:
    """Benchmark the closure system algorithms."""
    results = {}

    t0 = time.time()
    closed = system.closed_theories()
    results['closed_theories_time'] = time.time() - t0
    results['num_closed'] = len(closed)

    t0 = time.time()
    primes = system.prime_spectrum()
    results['prime_spectrum_time'] = time.time() - t0
    results['num_primes'] = len(primes)

    t0 = time.time()
    ok = system.verify_reconstruction()
    results['reconstruction_verify_time'] = time.time() - t0
    results['reconstruction_ok'] = ok

    return results


if __name__ == "__main__":
    # Example: Database functional dependencies
    print("=== Database Functional Dependencies ===")
    db = from_implication_basis(
        {'A', 'B', 'C', 'D', 'E'},
        [
            ({'A'}, 'B'),
            ({'B', 'C'}, 'D'),
            ({'D'}, 'E'),
        ]
    )
    print(db.summary())
    print(f"\nReconstruction verified: {db.verify_reconstruction()}")

    print("\n=== Benchmark ===")
    results = benchmark(db)
    for k, v in results.items():
        if isinstance(v, float):
            print(f"  {k}: {v:.4f}s")
        else:
            print(f"  {k}: {v}")
