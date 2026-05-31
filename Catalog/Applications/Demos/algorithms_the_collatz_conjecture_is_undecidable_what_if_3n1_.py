"""
Collatz Undecidability — Core Algorithms

Type-hinted implementations of the key algorithms used in the Collatz
undecidability research, including orbit computation, complexity measurement,
and stopping time analysis.
"""

from typing import List, Tuple, Optional, Dict
import math


def collatz_step(n: int) -> int:
    """Standard Collatz step: n/2 if even, 3n+1 if odd."""
    if n <= 0:
        raise ValueError(f"Collatz step undefined for n={n}")
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_orbit(n: int, max_steps: int = 10000) -> List[int]:
    """Compute the Collatz orbit of n until it reaches 1 or hits max_steps."""
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def stopping_time(n: int, max_steps: int = 10000) -> Optional[int]:
    """Compute the stopping time of n (steps to reach 1), or None if exceeds max_steps."""
    current = n
    for k in range(max_steps):
        if current == 1:
            return k
        current = collatz_step(current)
    return None


def peak_value(n: int, max_steps: int = 10000) -> int:
    """Compute the peak value in the Collatz orbit of n."""
    orbit = collatz_orbit(n, max_steps)
    return max(orbit)


class OrbitComplexity:
    """Orbit complexity measure for a Collatz orbit.
    
    Combines stopping time, peak value, and excursion ratio
    into a single complexity classification.
    """
    def __init__(self, start_val: int, stop_time: int, peak: int):
        self.start_val = start_val
        self.stop_time = stop_time
        self.peak = peak
        self.excursion = peak / start_val if start_val > 0 else 0
        self.bit_len = math.ceil(math.log2(start_val + 1)) if start_val > 0 else 0
        # Complexity score: stop_time * log2(excursion + 1)
        self.complexity = stop_time * math.log2(self.excursion + 1) if stop_time > 0 else 0

    def __repr__(self) -> str:
        return (f"OrbitComplexity(n={self.start_val}, σ={self.stop_time}, "
                f"peak={self.peak}, excursion={self.excursion:.2f}, "
                f"complexity={self.complexity:.2f})")


def compute_orbit_complexity(n: int) -> OrbitComplexity:
    """Compute the full orbit complexity for a starting value n."""
    orbit = collatz_orbit(n)
    st = len(orbit) - 1 if orbit[-1] == 1 else -1
    pk = max(orbit)
    return OrbitComplexity(n, st, pk)


def accel_step(n: int) -> int:
    """Accelerated Collatz step: if odd, do (3n+1)/2; if even, do n/2."""
    if n % 2 == 0:
        return n // 2
    else:
        return (3 * n + 1) // 2


def syracuse_orbit(n: int, max_steps: int = 1000) -> List[int]:
    """Compute the Syracuse (odd-only) orbit of n."""
    if n % 2 == 0:
        raise ValueError("Syracuse orbit requires odd starting value")
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current == 1:
            break
        # Apply 3n+1 then divide out all factors of 2
        m = 3 * current + 1
        while m % 2 == 0:
            m //= 2
        current = m
        orbit.append(current)
    return orbit


def tropical_orbit_distance(a: int, b: int) -> float:
    """Tropical distance between orbit points via bit-length.
    
    This is |⌈log₂(a)⌉ - ⌈log₂(b)⌉|, measuring the difference
    in the tropical valuation.
    """
    bit_a = math.ceil(math.log2(a + 1)) if a > 0 else 0
    bit_b = math.ceil(math.log2(b + 1)) if b > 0 else 0
    return abs(bit_a - bit_b)


def max_stopping_time(N: int) -> Tuple[int, int]:
    """Compute (max_stopping_time, argmax) for n in [1, N]."""
    best_time = 0
    best_n = 1
    for n in range(1, N + 1):
        st = stopping_time(n)
        if st is not None and st > best_time:
            best_time = st
            best_n = n
    return best_time, best_n


def stopping_time_growth_test(powers: List[int]) -> Dict[int, Dict[str, float]]:
    """Test the Θ(log²N) conjecture for stopping time growth.
    
    For each N = 2^k, compute max stopping time and the ratio
    max_σ(N) / (log₂N)². If the conjecture holds, this ratio
    should converge to a constant.
    """
    results = {}
    for k in powers:
        N = 2 ** k
        max_st, argmax = max_stopping_time(N)
        log_sq = k * k  # (log₂ N)² = k²
        ratio = max_st / log_sq if log_sq > 0 else float('inf')
        results[k] = {
            'N': N,
            'max_stopping_time': max_st,
            'argmax': argmax,
            'log2_N_squared': log_sq,
            'ratio': ratio
        }
    return results


def verify_collatz_up_to(N: int) -> bool:
    """Verify the Collatz conjecture for all n in [1, N]."""
    for n in range(1, N + 1):
        st = stopping_time(n)
        if st is None:
            return False
    return True


def parity_sequence(n: int, length: int) -> List[int]:
    """Compute the parity sequence of the Collatz orbit.
    
    Returns list of 0s (even) and 1s (odd) for the first `length` iterates.
    This encodes the orbit in a binary string.
    """
    seq = []
    current = n
    for _ in range(length):
        seq.append(current % 2)
        current = collatz_step(current)
    return seq


if __name__ == "__main__":
    # Quick demonstration
    print("=== Collatz Orbit Complexity Analysis ===\n")
    
    for n in [27, 97, 871, 6171]:
        oc = compute_orbit_complexity(n)
        print(oc)
    
    print("\n=== Stopping Time Growth Test ===\n")
    results = stopping_time_growth_test([3, 5, 7, 9, 11, 13])
    for k, data in results.items():
        print(f"N=2^{k}={data['N']:>8}: max_σ={data['max_stopping_time']:>4}, "
              f"(log₂N)²={data['log2_N_squared']:>4}, "
              f"ratio={data['ratio']:.3f}")
