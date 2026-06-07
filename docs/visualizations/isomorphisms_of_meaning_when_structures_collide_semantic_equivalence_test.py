def test_semantic_equivalence(c1, c2):
    from collections import Counter
    from itertools import permutations
    n = len(c1)
    if Counter(c1) != Counter(c2):
        return False, None
    for perm in permutations(range(n)):
        if all(c1[i] == c2[perm[i]] for i in range(n)):
            return True, list(perm)
    return False, None