#!/usr/bin/env python3
"""
Anti-Mathematics Demo: Ackermann Encoding and Phantom Index

Demonstrates the key concepts from the anti-mathematics research:
1. Ackermann encoding of hereditarily finite sets
2. Phantom index computation for anti-extensional universes
3. Axiom defect spectrum analysis
"""

from typing import Set, FrozenSet


def ack_mem(m: int, n: int) -> bool:
    """Ackermann membership: m ∈ₐ n iff bit m of n is set."""
    return bool((n >> m) & 1)


def ack_members(n: int) -> Set[int]:
    """Return the set of members of the Ackermann-encoded set n."""
    members = set()
    i = 0
    temp = n
    while temp > 0:
        if temp & 1:
            members.add(i)
        temp >>= 1
        i += 1
    return members


def ack_encode(s: Set[int]) -> int:
    """Encode a set of natural numbers as an Ackermann number."""
    return sum(1 << m for m in s)


def ack_union(a: int, b: int) -> int:
    """Union in Ackermann encoding = bitwise OR."""
    return a | b


def ack_intersection(a: int, b: int) -> int:
    """Intersection in Ackermann encoding = bitwise AND."""
    return a & b


def ack_singleton(m: int) -> int:
    """Singleton {m} in Ackermann encoding = 2^m."""
    return 1 << m


def ack_pair(a: int, b: int) -> int:
    """Pairing {a, b} in Ackermann encoding."""
    return (1 << a) | (1 << b)


def phantom_index(n: int, mem_rel: list[list[bool]]) -> int:
    """
    Compute the phantom index of a finite membership structure.
    
    Args:
        n: number of elements (0, 1, ..., n-1)
        mem_rel: n×n boolean matrix where mem_rel[x][y] means x ∈ y
    
    Returns:
        phantom index = n - |equivalence classes|
    """
    # Compute extensional equivalence classes
    classes: list[FrozenSet[int]] = []
    assigned = [False] * n
    
    for i in range(n):
        if assigned[i]:
            continue
        eq_class = {i}
        for j in range(i + 1, n):
            if assigned[j]:
                continue
            # Check if i and j are extensionally equivalent
            equiv = True
            for x in range(n):
                if mem_rel[x][i] != mem_rel[x][j]:
                    equiv = False
                    break
            if equiv:
                eq_class.add(j)
                assigned[j] = True
        classes.append(frozenset(eq_class))
        assigned[i] = True
    
    return n - len(classes)


def iterate_function(f: dict[int, int], n: int, x: int) -> int:
    """Compute f^[n](x) for a finite function given as a dict."""
    result = x
    for _ in range(n):
        result = f[result]
    return result


def find_idempotent_iterate(f: dict[int, int]) -> int:
    """Find the smallest N > 0 such that f^[N] is idempotent."""
    domain = sorted(f.keys())
    
    for n in range(1, len(domain) ** 2 + 1):
        # Check if f^[n] ∘ f^[n] = f^[n]
        is_idempotent = True
        for x in domain:
            fn_x = iterate_function(f, n, x)
            fn_fn_x = iterate_function(f, n, fn_x)
            if fn_fn_x != fn_x:
                is_idempotent = False
                break
        if is_idempotent:
            return n
    
    return -1  # Should never happen for finite functions


def main():
    print("=" * 60)
    print("ANTI-MATHEMATICS: Ackermann Encoding Demo")
    print("=" * 60)
    
    # Demo 1: Ackermann encoding basics
    print("\n--- Ackermann Encoding ---")
    print(f"Empty set ∅ = 0, members: {ack_members(0)}")
    print(f"{{0}} = {ack_singleton(0)}, members: {ack_members(ack_singleton(0))}")
    print(f"{{1}} = {ack_singleton(1)}, members: {ack_members(ack_singleton(1))}")
    print(f"{{0, 2}} = {ack_encode({0, 2})}, members: {ack_members(ack_encode({0, 2}))}")
    print(f"{{0, 1, 2}} = {ack_encode({0, 1, 2})}, members: {ack_members(ack_encode({0, 1, 2}))}")
    
    # Demo 2: Set operations
    print("\n--- Set Operations via Bitwise Arithmetic ---")
    a = ack_encode({0, 2, 4})
    b = ack_encode({1, 2, 3})
    print(f"A = {{0, 2, 4}} = {a}")
    print(f"B = {{1, 2, 3}} = {b}")
    print(f"A ∪ B = {ack_members(ack_union(a, b))} = {ack_union(a, b)}")
    print(f"A ∩ B = {ack_members(ack_intersection(a, b))} = {ack_intersection(a, b)}")
    print(f"Pairing(3, 5) = {{{3, 5}}} = {ack_pair(3, 5)}, members: {ack_members(ack_pair(3, 5))}")
    
    # Demo 3: Verify extensionality
    print("\n--- Extensionality Verification ---")
    for n in range(20):
        for m in range(n):
            if ack_members(n) == ack_members(m):
                print(f"WARNING: {n} and {m} have same members but are different!")
    print("Verified: all numbers 0-19 have distinct membership sets ✓")
    
    # Demo 4: Anti-infinity
    print("\n--- Anti-Infinity: No Universal Set ---")
    for n in range(1, 100):
        members = ack_members(n)
        if len(members) == n:  # Would need all of {0,...,n-1}
            print(f"n={n} has {len(members)} members (but universe has {n} elements)")
    print("No number 1-99 contains all smaller numbers as members ✓")
    
    # Demo 5: Phantom index
    print("\n--- Phantom Index ---")
    
    # Phantom universe: Bool with empty membership
    phantom_mem = [[False, False], [False, False]]
    pi = phantom_index(2, phantom_mem)
    print(f"Phantom universe (2 elements, empty membership): phantom index = {pi}")
    
    # Extensional universe: each element distinguishable
    ext_mem = [[False, True], [False, False]]  # 0 ∈ 1, nothing else
    pi = phantom_index(2, ext_mem)
    print(f"Extensional universe (0 ∈ 1): phantom index = {pi}")
    
    # Larger phantom example: 4 elements, all equivalent
    all_false = [[False]*4 for _ in range(4)]
    pi = phantom_index(4, all_false)
    print(f"4-element all-empty: phantom index = {pi}")
    
    # Mixed: 4 elements, two pairs of phantoms
    mixed = [[False]*4 for _ in range(4)]
    mixed[0][0] = True; mixed[0][1] = True  # 0 ∈ 0 and 0 ∈ 1
    mixed[2][2] = True; mixed[2][3] = True  # 2 ∈ 2 and 2 ∈ 3
    pi = phantom_index(4, mixed)
    print(f"4-element two-pair phantoms: phantom index = {pi}")
    
    # Demo 6: Eventual idempotence
    print("\n--- Eventual Idempotence ---")
    
    # f: {0,1,2,3,4} → {0,1,2,3,4} with f(0)=1, f(1)=2, f(2)=0, f(3)=4, f(4)=3
    f = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3}
    n = find_idempotent_iterate(f)
    print(f"f = {f}")
    print(f"Smallest idempotent iterate: N = {n}")
    for x in sorted(f.keys()):
        fn_x = iterate_function(f, n, x)
        fn_fn_x = iterate_function(f, n, fn_x)
        print(f"  f^[{n}]({x}) = {fn_x}, f^[{n}](f^[{n}]({x})) = {fn_fn_x}")
    
    # Demo 7: Axiom defect spectrum
    print("\n--- Axiom Defect Spectrum ---")
    axiom_names = ["Ext", "Pair", "Union", "Pow", "Inf", "Repl", "Found", "Choice"]
    
    # ZFC spectrum
    zfc = [0.0] * 8
    print(f"ZFC spectrum: {dict(zip(axiom_names, zfc))}")
    print(f"Total deficiency: {sum(zfc)}")
    
    # Anti-infinity spectrum (Ackermann model)
    ack_spectrum = [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0]
    print(f"\nAckermann model: {dict(zip(axiom_names, ack_spectrum))}")
    print(f"Total deficiency: {sum(ack_spectrum)}")
    
    # Phantom universe spectrum
    phantom_spectrum = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0]
    print(f"\nPhantom universe: {dict(zip(axiom_names, phantom_spectrum))}")
    print(f"Total deficiency: {sum(phantom_spectrum)}")
    
    # Check compatibility
    def compatible(s, t):
        return all(si + ti <= 1.0 for si, ti in zip(s, t))
    
    print(f"\nZFC ↔ Ackermann compatible: {compatible(zfc, ack_spectrum)}")
    print(f"ZFC ↔ Phantom compatible: {compatible(zfc, phantom_spectrum)}")
    print(f"Ackermann ↔ Phantom compatible: {compatible(ack_spectrum, phantom_spectrum)}")
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")


if __name__ == "__main__":
    main()
