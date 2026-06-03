def hamming_distance(A: frozenset, B: frozenset) -> int:
    return len(A.symmetric_difference(B))