"""
Collatz One-Way Functions: Algorithms for Cryptographic Primitives

Type-hinted implementations of the core algorithms from the formalization.
"""

from typing import List, Tuple, Dict, Optional, Set
import hashlib


def collatz_step(n: int) -> int:
    """The Collatz map T(n): n/2 if even, 3n+1 if odd.
    
    >>> collatz_step(6)
    3
    >>> collatz_step(7)
    22
    """
    if n <= 0:
        return 0
    if n % 2 == 0:
        return n // 2
    return 3 * n + 1


def collatz_iter(k: int, n: int) -> int:
    """k-fold iteration of the Collatz step: T^k(n).
    
    >>> collatz_iter(0, 7)
    7
    >>> collatz_iter(1, 7)
    22
    >>> collatz_iter(2, 7)
    11
    """
    result = n
    for _ in range(k):
        result = collatz_step(result)
    return result


def collatz_trajectory(n: int, k: int) -> List[int]:
    """Full trajectory [n, T(n), T^2(n), ..., T^k(n)].
    
    >>> collatz_trajectory(7, 5)
    [7, 22, 11, 34, 17, 52]
    """
    traj = [n]
    current = n
    for _ in range(k):
        current = collatz_step(current)
        traj.append(current)
    return traj


def collatz_preimage(m: int) -> Set[int]:
    """Compute the preimage set T^{-1}(m) = {n : T(n) = m}.
    
    Every m > 0 has the even preimage 2m.
    An odd preimage exists iff (m-1) % 3 == 0 and (m-1)//3 is odd and positive.
    
    >>> sorted(collatz_preimage(4))
    [1, 8]
    >>> sorted(collatz_preimage(3))
    [6]
    """
    if m <= 0:
        return {0}
    preimages = {2 * m}
    # Check for odd preimage: need 3*n+1 = m, so n = (m-1)/3
    if (m - 1) % 3 == 0:
        candidate = (m - 1) // 3
        if candidate > 0 and candidate % 2 == 1:
            preimages.add(candidate)
    return preimages


def collatz_preimage_tree(m: int, depth: int) -> Dict[int, Set[int]]:
    """Build the preimage tree of m to given depth.
    
    Returns a dict mapping each depth level to the set of preimages.
    
    >>> tree = collatz_preimage_tree(1, 3)
    >>> sorted(tree[1])
    [2]
    >>> sorted(tree[2])
    [4]
    """
    tree: Dict[int, Set[int]] = {0: {m}}
    for d in range(1, depth + 1):
        tree[d] = set()
        for val in tree[d - 1]:
            tree[d] |= collatz_preimage(val)
    return tree


class CollatzHashConfig:
    """Configuration for a Collatz-based hash function.
    
    Uses multiple parallel Collatz chains with different depths and seeds.
    """
    
    def __init__(self, depths: List[int], seeds: List[int]):
        assert len(depths) == len(seeds)
        assert all(d > 0 for d in depths)
        assert all(s > 0 for s in seeds)
        self.num_chains = len(depths)
        self.depths = depths
        self.seeds = seeds
    
    def hash(self, x: int) -> Tuple[int, ...]:
        """Evaluate the Collatz hash on input x.
        
        Returns a tuple of chain outputs.
        """
        return tuple(
            collatz_iter(d, x + s)
            for d, s in zip(self.depths, self.seeds)
        )
    
    def find_collision(self, x_range: range) -> Optional[Tuple[int, int]]:
        """Brute-force search for a collision in the given range.
        
        Returns (x, y) with x != y and hash(x) == hash(y), or None.
        """
        seen: Dict[Tuple[int, ...], int] = {}
        for x in x_range:
            h = self.hash(x)
            if h in seen and seen[h] != x:
                return (seen[h], x)
            seen[h] = x
        return None


def forward_cost(k: int) -> int:
    """Forward computation cost: O(k) steps."""
    return k


def inverse_cost(k: int) -> int:
    """Naive inverse cost: O(2^k) steps (preimage tree search)."""
    return 2 ** k


def security_gap(k: int) -> float:
    """The exponential security gap: inverse_cost / forward_cost."""
    if k == 0:
        return 1.0
    return inverse_cost(k) / forward_cost(k)


def collatz_hash_fingerprint(n: int, depth: int = 20, num_chains: int = 4) -> str:
    """Create a hex fingerprint of n using Collatz iterations.
    
    Combines multiple chain outputs into a hash digest.
    
    >>> len(collatz_hash_fingerprint(42))
    64
    """
    outputs = []
    for i in range(num_chains):
        seed = 2 * i + 1  # Odd seeds
        val = collatz_iter(depth, n + seed)
        outputs.append(val)
    
    # Combine outputs into a hash
    combined = "|".join(str(v) for v in outputs)
    return hashlib.sha256(combined.encode()).hexdigest()


def verify_preimage_growth_conjecture(max_k: int = 30) -> Dict[int, int]:
    """Test the preimage growth conjecture: |T^{-k}(1)| ≥ k for k ≥ 10.
    
    Returns a dict mapping k to the preimage tree size at depth k.
    """
    results: Dict[int, int] = {}
    for k in range(1, max_k + 1):
        tree = collatz_preimage_tree(1, k)
        results[k] = len(tree[k])
    return results


if __name__ == "__main__":
    # Quick verification
    print("Collatz trajectory of 27:", collatz_trajectory(27, 20))
    print("Preimage of 4:", sorted(collatz_preimage(4)))
    print("Preimage of 16:", sorted(collatz_preimage(16)))
    
    # Security gap
    for k in range(1, 21):
        print(f"k={k:3d}: forward={forward_cost(k):3d}, inverse={inverse_cost(k):12d}, gap={security_gap(k):10.1f}")
    
    # Hash example
    cfg = CollatzHashConfig(depths=[10, 15, 20, 25], seeds=[1, 3, 5, 7])
    print(f"\nHash of 42: {cfg.hash(42)}")
    print(f"Hash of 43: {cfg.hash(43)}")
    
    # Fingerprint
    print(f"\nFingerprint of 42: {collatz_hash_fingerprint(42)}")
    print(f"Fingerprint of 43: {collatz_hash_fingerprint(43)}")
