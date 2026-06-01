#!/usr/bin/env python3
"""
Hypercomputation Algorithms: Type-Hinted Implementations

Core algorithms for:
1. Diagonal construction (Cantor/Turing)
2. Oracle hierarchy simulation
3. Convergent approximation analysis
4. Accidental correctness testing
"""

from dataclasses import dataclass, field
from typing import Callable, List, Optional, Set, Tuple, Dict


# Type aliases
BoolFunc = Callable[[int], int]  # ℕ → {0, 1}
BoolFunc2 = Callable[[int, int], int]  # ℕ × ℕ → {0, 1}


@dataclass
class ComputabilityModel:
    """Axiomatic computability model.
    
    Provides an enumeration of 'computable' functions with closure properties.
    """
    functions: List[BoolFunc]
    
    def phi(self, e: int, n: int) -> int:
        """Evaluate the e-th computable function at input n."""
        if 0 <= e < len(self.functions):
            return self.functions[e](n)
        return 0  # Default for out-of-range indices
    
    def antidiag(self, n: int) -> int:
        """Compute the anti-diagonal: d(n) = ¬φ(n, n)."""
        return 1 - self.phi(n, n)
    
    def is_computable(self, f: BoolFunc, domain_size: int) -> Optional[int]:
        """Check if f matches any enumerated function on [0, domain_size).
        Returns the index if found, None otherwise."""
        for e in range(len(self.functions)):
            if all(self.phi(e, n) == f(n) for n in range(domain_size)):
                return e
        return None
    
    def negate(self, e: int) -> BoolFunc:
        """Return the negation of the e-th function."""
        return lambda n, e=e: 1 - self.phi(e, n)


def cantor_diagonal(matrix: List[List[int]]) -> List[int]:
    """Compute the anti-diagonal of a Boolean matrix.
    
    Given an N×N matrix M, returns the vector v where v[i] = ¬M[i][i].
    Guaranteed to differ from every row at position i.
    
    Args:
        matrix: Square Boolean matrix (list of lists of 0/1)
    
    Returns:
        Anti-diagonal vector
    """
    n = len(matrix)
    return [1 - matrix[i][i] for i in range(n)]


def verify_diagonal_escape(matrix: List[List[int]], 
                           antidiag: List[int]) -> List[int]:
    """Verify that the anti-diagonal differs from every row.
    
    Returns list of positions where each row differs from antidiag.
    """
    n = len(matrix)
    witnesses: List[int] = []
    for i in range(n):
        # Position i itself is always a witness
        assert matrix[i][i] != antidiag[i], \
            f"Row {i} should differ at diagonal position {i}"
        witnesses.append(i)
    return witnesses


@dataclass
class OracleLevel:
    """A level in the oracle hierarchy."""
    model: ComputabilityModel
    level_index: int
    
    def jump(self) -> 'OracleLevel':
        """Construct the next oracle level by adding the anti-diagonal.
        
        The new level includes all functions from this level plus
        the anti-diagonal function.
        """
        new_functions = list(self.model.functions)
        antidiag_func = lambda n, m=self.model: m.antidiag(n)
        new_functions.append(antidiag_func)
        new_model = ComputabilityModel(functions=new_functions)
        return OracleLevel(model=new_model, level_index=self.level_index + 1)


def build_oracle_chain(base: ComputabilityModel, 
                       depth: int) -> List[OracleLevel]:
    """Build an oracle chain of given depth.
    
    Args:
        base: The base computability model (level 0)
        depth: Number of oracle jumps to perform
    
    Returns:
        List of OracleLevel objects from level 0 to level depth
    """
    chain: List[OracleLevel] = []
    current = OracleLevel(model=base, level_index=0)
    chain.append(current)
    
    for _ in range(depth):
        current = current.jump()
        chain.append(current)
    
    return chain


def verify_hierarchy_strictness(chain: List[OracleLevel], 
                                domain_size: int) -> List[Dict]:
    """Verify that each level strictly extends the previous.
    
    Returns a list of verification results for each transition.
    """
    results = []
    for k in range(len(chain) - 1):
        level_k = chain[k]
        level_k1 = chain[k + 1]
        
        # The anti-diagonal of level k should NOT be computable at level k
        antidiag_k = lambda n, m=level_k.model: m.antidiag(n)
        idx_at_k = level_k.model.is_computable(antidiag_k, domain_size)
        
        # The anti-diagonal of level k SHOULD be computable at level k+1
        idx_at_k1 = level_k1.model.is_computable(antidiag_k, domain_size)
        
        results.append({
            'level': k,
            'antidiag_computable_at_k': idx_at_k is not None,
            'antidiag_computable_at_k1': idx_at_k1 is not None,
            'strict': idx_at_k is None and idx_at_k1 is not None
        })
    
    return results


@dataclass
class ConvergentApproximation:
    """A convergent approximation to a target function."""
    target: BoolFunc
    stages: List[BoolFunc]
    
    def convergence_time(self, n: int) -> int:
        """Find the first stage that's correct at input n and stays correct."""
        for k in range(len(self.stages)):
            if all(self.stages[j](n) == self.target(n) 
                   for j in range(k, len(self.stages))):
                return k
        return len(self.stages)  # Not converged yet
    
    def error_profile(self, domain_size: int) -> List[int]:
        """For each stage, count errors on [0, domain_size)."""
        return [
            sum(1 for n in range(domain_size) 
                if self.stages[k](n) != self.target(n))
            for k in range(len(self.stages))
        ]


def analyze_accidental_correctness(model: ComputabilityModel,
                                   target: BoolFunc,
                                   domain_size: int) -> Dict:
    """Analyze accidental vs. essential correctness.
    
    Returns:
        Dictionary with accidental correctness info per position
        and essential computability check.
    """
    results: Dict = {
        'domain_size': domain_size,
        'positions': {},
        'is_essentially_computable': False
    }
    
    # Check essential computability
    idx = model.is_computable(target, domain_size)
    results['is_essentially_computable'] = idx is not None
    if idx is not None:
        results['computable_index'] = idx
    
    # Check accidental correctness at each position
    for pos in range(domain_size):
        target_val = target(pos)
        # Find any computable function that agrees at this position
        for e in range(len(model.functions)):
            if model.phi(e, pos) == target_val:
                results['positions'][pos] = {
                    'target_value': target_val,
                    'witness_index': e,
                    'accidentally_correct': True
                }
                break
        else:
            results['positions'][pos] = {
                'target_value': target_val,
                'witness_index': None,
                'accidentally_correct': False
            }
    
    return results


def counting_argument(n: int, proc: BoolFunc) -> Tuple[int, int]:
    """Compute the number of targets matched and missed by a procedure.
    
    Among all 2^n Boolean functions on {0,...,n-1}, counts how many
    are fully matched by proc and how many are missed.
    
    Args:
        n: Domain size
        proc: The procedure to evaluate
    
    Returns:
        (matched, missed) counts
    """
    total = 2 ** n
    # Only one function can be fully matched: proc itself
    matched = 1
    missed = total - 1
    return matched, missed


if __name__ == "__main__":
    # Create a simple computability model
    base_functions = [
        lambda n: 0,                    # Always false
        lambda n: 1,                    # Always true
        lambda n: n % 2,               # Parity
        lambda n: 1 - n % 2,           # Anti-parity
        lambda n: 1 if n < 3 else 0,   # Finite support
        lambda n: 0 if n < 3 else 1,   # Cofinite support
        lambda n: n % 3 == 0,          # Divisible by 3
        lambda n: 1 - (n % 3 == 0),    # Not divisible by 3
    ]
    
    model = ComputabilityModel(functions=base_functions)
    
    print("Base model anti-diagonal (first 10 values):")
    print([model.antidiag(n) for n in range(10)])
    
    # Build oracle chain
    chain = build_oracle_chain(model, depth=4)
    print(f"\nOracle chain with {len(chain)} levels built.")
    
    # Verify strictness
    results = verify_hierarchy_strictness(chain, domain_size=8)
    for r in results:
        status = "STRICT ✓" if r['strict'] else "FAILED ✗"
        print(f"  Level {r['level']} → {r['level']+1}: {status}")
    
    # Analyze accidental correctness
    antidiag = lambda n, m=model: m.antidiag(n)
    acc_results = analyze_accidental_correctness(model, antidiag, 8)
    print(f"\nEssentially computable: {acc_results['is_essentially_computable']}")
    for pos, info in acc_results['positions'].items():
        status = "✓" if info['accidentally_correct'] else "✗"
        print(f"  Position {pos}: {status} (target={info['target_value']})")
