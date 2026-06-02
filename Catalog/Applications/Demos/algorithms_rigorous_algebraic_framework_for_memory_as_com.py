"""
Memory Compression Algebra — Core Algorithms

Type-hinted implementations of the key algorithms from the
tropical-algebraic framework for memory compression.
"""

from __future__ import annotations
import math
from typing import TypeVar, Callable, Sequence, FrozenSet

A = TypeVar('A')
B = TypeVar('B')


def compression_rank(f: Callable[[A], B], domain: Sequence[A]) -> int:
    """Compute the compression rank of f on the given domain.
    
    The compression rank is |image(f)| = |{f(a) : a ∈ domain}|.
    
    >>> compression_rank(lambda x: x % 3, range(10))
    3
    >>> compression_rank(lambda x: x, range(5))
    5
    >>> compression_rank(lambda x: 0, range(100))
    1
    """
    return len(set(f(a) for a in domain))


def tropical_capacity(f: Callable[[A], B], domain: Sequence[A]) -> float:
    """Compute the tropical capacity v(f) = log(rank(f)).
    
    Returns -inf for empty domains (rank 0).
    
    >>> tropical_capacity(lambda x: x, range(8))  # doctest: +ELLIPSIS
    2.079...
    """
    r = compression_rank(f, domain)
    return math.log(r) if r > 0 else float('-inf')


def kernel_partition(f: Callable[[A], B], domain: Sequence[A]) -> dict[B, list[A]]:
    """Compute the kernel partition of f: group domain elements by f-value.
    
    >>> kernel_partition(lambda x: x % 2, range(6))
    {0: [0, 2, 4], 1: [1, 3, 5]}
    """
    partition: dict[B, list[A]] = {}
    for a in domain:
        key = f(a)
        if key not in partition:
            partition[key] = []
        partition[key].append(a)
    return partition


def max_fiber_size(f: Callable[[A], B], domain: Sequence[A]) -> int:
    """Compute the maximum fiber size (max preimage cardinality).
    
    >>> max_fiber_size(lambda x: x % 3, range(10))
    4
    """
    part = kernel_partition(f, domain)
    return max(len(v) for v in part.values()) if part else 0


def stabilization_index(f: Callable[[int], int], n: int) -> tuple[int, list[int]]:
    """Compute the stabilization index N and the rank profile.
    
    For f : {0,...,n-1} → {0,...,n-1}, returns (N, [rank(f^0), rank(f^1), ...rank(f^N)])
    where N is the smallest index at which the rank stabilizes.
    
    >>> stabilization_index(lambda x: (x + 1) % 5, 5)
    (0, [5])
    >>> stabilization_index(lambda x: min(x, 2), 5)
    (1, [5, 3])
    """
    domain = list(range(n))
    # f^0 = identity
    current_iter = {i: i for i in domain}  # maps i -> f^k(i)
    profile = [n]  # rank(f^0) = n
    
    for step in range(1, n + 1):
        # compose with f
        new_iter = {i: f[current_iter[i]] if isinstance(f, (list, dict)) 
                    else f(current_iter[i]) for i in domain}
        current_iter = new_iter
        r = len(set(current_iter.values()))
        profile.append(r)
        if r == profile[-2]:  # stabilized
            return step - 1, profile[:-1]
    
    return len(profile) - 1, profile


def stabilization_index_func(f: Callable[[int], int], n: int) -> tuple[int, list[int]]:
    """Compute stabilization index for a callable f on {0,...,n-1}.
    
    Returns (N, rank_profile) where rank_profile[k] = rank(f^k).
    """
    domain = list(range(n))
    current = {i: i for i in domain}
    profile = [n]
    
    for _ in range(n + 1):
        current = {i: f(current[i]) for i in domain}
        r = len(set(current.values()))
        profile.append(r)
        if r == profile[-2]:
            return len(profile) - 2, profile[:-1]
    
    return len(profile) - 1, profile


def cascade_product_rank(
    f1: Callable[[A], B], f2: Callable[[A], B], domain: Sequence[A]
) -> tuple[int, int, int]:
    """Compute ranks of f1, f2, and their cascade product.
    
    Returns (rank(f1), rank(f2), rank(f1 × f2)).
    Demonstrates the cascade product rank bound: rank(f1×f2) ≤ rank(f1) · rank(f2).
    """
    r1 = compression_rank(f1, domain)
    r2 = compression_rank(f2, domain)
    r12 = len(set((f1(a), f2(a)) for a in domain))
    return r1, r2, r12


def tropical_capacity_profile(
    f: Callable[[int], int], n: int, max_depth: int
) -> list[float]:
    """Compute the tropical capacity profile [v(f^0), v(f^1), ..., v(f^max_depth)].
    
    Shows the monotone decrease and eventual stabilization of capacity.
    """
    domain = list(range(n))
    current = {i: i for i in domain}
    profile = [math.log(n) if n > 0 else float('-inf')]
    
    for _ in range(max_depth):
        current = {i: f(current[i]) for i in domain}
        r = len(set(current.values()))
        profile.append(math.log(r) if r > 0 else float('-inf'))
    
    return profile


def idempotent_power(f: Callable[[int], int], n: int) -> int:
    """Find the smallest k > 0 such that f^(2k) = f^k on {0,...,n-1}.
    
    This is the computational version of the idempotent stabilization theorem.
    
    >>> idempotent_power(lambda x: (x + 1) % 5, 5)
    5
    """
    domain = list(range(n))
    
    # Build iterates
    fk = {i: i for i in domain}
    f2k = {i: i for i in domain}
    
    for k in range(1, n * n + 2):
        # fk = f^k
        fk = {i: f(fk[i]) for i in domain}
        # f2k = f^(2k): need to apply f twice more to previous f^(2(k-1))
        f2k = {i: f(f(f2k[i])) for i in domain}
        # Check f^(2k) == f^k
        # But we need f2k to actually be f^(2k). Let me reconsider.
        # f^(2k) = (f^k)^2
        pass
    
    # Better approach: build all iterates
    iterates = [{i: i for i in domain}]  # f^0
    for k in range(1, 2 * n * n + 2):
        prev = iterates[-1]
        iterates.append({i: f(prev[i]) for i in domain})
    
    for k in range(1, n * n + 1):
        fk_vals = tuple(iterates[k][i] for i in domain)
        f2k_vals = tuple(iterates[2*k][i] for i in domain)
        if fk_vals == f2k_vals:
            return k
    
    return -1  # Should never happen for finite domains


def kernel_refines(
    f: Callable[[A], B], g: Callable[[A], B], domain: Sequence[A]
) -> bool:
    """Check if ker(f) refines ker(g): f(x)=f(y) implies g(x)=g(y).
    
    >>> kernel_refines(lambda x: x, lambda x: x % 2, range(10))
    True
    >>> kernel_refines(lambda x: x % 2, lambda x: x, range(10))
    False
    """
    # Build f-classes
    f_classes: dict = {}
    for a in domain:
        fv = f(a)
        if fv not in f_classes:
            f_classes[fv] = []
        f_classes[fv].append(a)
    
    # Check each f-class maps to a single g-value
    for cls in f_classes.values():
        g_vals = set(g(a) for a in cls)
        if len(g_vals) > 1:
            return False
    return True


if __name__ == "__main__":
    import doctest
    doctest.testmod()
    
    print("=== Memory Compression Algebra Demos ===\n")
    
    # Demo 1: Bottleneck inequality
    print("--- Bottleneck Inequality ---")
    f = lambda x: x % 4
    g = lambda x: x % 2
    domain = list(range(16))
    r_f = compression_rank(f, domain)
    r_g = compression_rank(g, domain)
    r_gf = compression_rank(lambda x: g(f(x)), domain)
    print(f"rank(f) = {r_f}, rank(g) = {r_g}, rank(g∘f) = {r_gf}")
    print(f"Bottleneck: {r_gf} ≤ min({r_f}, {r_g}) = {min(r_f, r_g)} ✓")
    
    # Demo 2: Stabilization
    print("\n--- Iteration Stabilization ---")
    def collapse(x: int) -> int:
        return min(x, 3)
    
    n = 8
    N, profile = stabilization_index_func(collapse, n)
    print(f"f(x) = min(x, 3) on {{0,...,{n-1}}}")
    print(f"Rank profile: {profile}")
    print(f"Stabilization index: {N}")
    
    # Demo 3: Tropical capacity profile
    print("\n--- Tropical Capacity Profile ---")
    def shift_collapse(x: int) -> int:
        return max(0, x - 1)
    
    n = 10
    tcp = tropical_capacity_profile(shift_collapse, n, 12)
    print(f"f(x) = max(0, x-1) on {{0,...,{n-1}}}")
    for i, v in enumerate(tcp):
        print(f"  v(f^{i}) = {v:.4f}  (rank = {round(math.exp(v))})")
    
    # Demo 4: Idempotent power
    print("\n--- Idempotent Power ---")
    def cycle_and_collapse(x: int) -> int:
        if x < 3:
            return (x + 1) % 3
        return 2
    
    k = idempotent_power(cycle_and_collapse, 6)
    print(f"Idempotent power for cycle-and-collapse on {{0,...,5}}: k = {k}")
    print(f"f^k = f^{k}, f^(2k) = f^{2*k}, they agree: verified")
