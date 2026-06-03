"""
Algorithms for Collatz Orbit Analysis and Proof Resistance
==========================================================
Type-hinted implementations of the core algorithms formalized in Lean 4.
"""
from typing import Optional
from dataclasses import dataclass
import math


def collatz_step(n: int) -> int:
    """The standard Collatz step: n/2 if even, 3n+1 if odd.
    
    Matches the Lean definition:
      def collatzStep (n : ℕ) : ℕ :=
        if n % 2 = 0 then n / 2 else 3 * n + 1
    """
    if n % 2 == 0:
        return n // 2
    else:
        return 3 * n + 1


def syracuse_step(n: int) -> int:
    """The Syracuse (accelerated) step: (3n+1)/2 for odd n.
    
    Combines an odd step with its forced even successor.
    Satisfies: n+1 ≤ syracuse(n) ≤ 2n for odd n ≥ 1.
    """
    assert n % 2 == 1 and n >= 1, "Syracuse step requires odd n ≥ 1"
    return (3 * n + 1) // 2


def collatz_iter(n: int, k: int) -> int:
    """Iterate the Collatz step k times.
    
    Matches: def collatzIter (n k : ℕ) : ℕ := (collatzStep^[k]) n
    """
    for _ in range(k):
        n = collatz_step(n)
    return n


def collatz_orbit(n: int, max_steps: int = 100000) -> list[int]:
    """Compute the full Collatz orbit until reaching 1 or hitting max_steps."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = collatz_step(n)
        orbit.append(n)
    return orbit


def stopping_time(n: int, max_steps: int = 100000) -> Optional[int]:
    """Compute the stopping time: smallest k with collatzIter(n, k) = 1.
    
    Returns None if 1 is not reached within max_steps.
    Matches: def stoppingTime (n : ℕ) : ℕ :=
      if h : ∃ k, collatzIter n k = 1 then Nat.find h else 0
    """
    current = n
    for k in range(max_steps + 1):
        if current == 1:
            return k
        current = collatz_step(current)
    return None


@dataclass
class ProofResistance:
    """Proof resistance captures the verification difficulty of a Collatz input.
    
    Matches the Lean structure:
      structure ProofResistance where
        input : ℕ
        stopTime : ℕ
        peakVal : ℕ
        resistance : ℕ := stopTime * (Nat.log 2 peakVal + 1)
    """
    input: int
    stop_time: int
    peak_val: int
    resistance: int
    excursion_ratio: float

    @staticmethod
    def compute(n: int) -> 'ProofResistance':
        orbit = collatz_orbit(n)
        st = len(orbit) - 1
        peak = max(orbit)
        peak_bits = peak.bit_length()
        return ProofResistance(
            input=n,
            stop_time=st,
            peak_val=peak,
            resistance=st * peak_bits,
            excursion_ratio=peak / n if n > 0 else 0
        )


def parity_word(n: int, k: int) -> list[bool]:
    """Compute the parity word of the orbit of n for k steps.
    
    True = odd, False = even. By the Parity Exclusion Theorem,
    True is never followed by True.
    
    Matches: def parityWord (n : ℕ) (k : ℕ) : Bool := 
      (collatzIter n k) % 2 != 0
    """
    result: list[bool] = []
    current = n
    for _ in range(k):
        result.append(current % 2 == 1)
        current = collatz_step(current)
    return result


def verify_parity_exclusion(n: int) -> bool:
    """Verify the Parity Exclusion Theorem for input n.
    
    The theorem states: if collatzIter n k is odd, then
    collatzIter n (k+1) is even. Equivalently, the parity word
    never contains two consecutive True values.
    """
    orbit = collatz_orbit(n)
    for i in range(len(orbit) - 1):
        if orbit[i] % 2 == 1 and orbit[i + 1] % 2 == 1:
            return False
    return True


def bounded_verification(N: int) -> tuple[bool, Optional[int]]:
    """Verify Collatz for all n ∈ [1, N].
    
    Returns (True, None) if all reach 1, or (False, n) for first failure.
    Matches: def collatzUpTo (N : ℕ) : Prop := ∀ n, 1 ≤ n → n ≤ N → reachesOne n
    """
    for n in range(1, N + 1):
        if stopping_time(n) is None:
            return False, n
    return True, None


def find_even_preimage(m: int) -> int:
    """Find the even preimage of m under collatzStep.
    
    By even_preimage theorem, this is always 2m.
    """
    return 2 * m


def find_odd_preimage(m: int) -> Optional[int]:
    """Find the odd preimage of m under collatzStep, if it exists.
    
    An odd p maps to m iff 3p+1 = m, so p = (m-1)/3.
    This exists iff m ≡ 1 (mod 3) and (m-1)/3 is odd.
    """
    if m < 4 or (m - 1) % 3 != 0:
        return None
    p = (m - 1) // 3
    if p % 2 == 0:
        return None
    return p


def collatz_tree_preimages(m: int) -> list[int]:
    """Find all preimages of m under collatzStep.
    
    By the inverse image structure theorems:
    - Even preimage 2m always exists
    - Odd preimage (m-1)/3 exists iff m ≡ 1 mod 3 and (m-1)/3 is odd
    """
    preimages = [find_even_preimage(m)]
    odd_pre = find_odd_preimage(m)
    if odd_pre is not None:
        preimages.append(odd_pre)
    return preimages


def stopping_time_statistics(N: int) -> dict[str, float]:
    """Compute statistics about stopping times in [1, N].
    
    Tests the falsifiable conjecture: max stopping time ∝ (log₂ N)².
    """
    max_stop = 0
    total_stop = 0
    for n in range(1, N + 1):
        st = stopping_time(n)
        if st is not None:
            max_stop = max(max_stop, st)
            total_stop += st
    log_n = math.log2(N) if N > 1 else 1
    return {
        'N': N,
        'max_stopping_time': max_stop,
        'avg_stopping_time': total_stop / N,
        'log2_N': log_n,
        'log2_N_squared': log_n ** 2,
        'ratio_max_over_log2sq': max_stop / (log_n ** 2) if log_n > 0 else 0,
    }


if __name__ == '__main__':
    # Demo: compute proof resistance for "hard" inputs
    print("Top 10 highest proof resistance inputs in [1, 10000]:")
    resistances = [ProofResistance.compute(n) for n in range(1, 10001)]
    resistances.sort(key=lambda r: r.resistance, reverse=True)
    for pr in resistances[:10]:
        print(f"  n={pr.input:>6}, stop={pr.stop_time:>4}, "
              f"peak={pr.peak_val:>10}, resistance={pr.resistance:>8}")
