from typing import Tuple
Perm = Tuple[int, ...]

def compose(a: Perm, b: Perm) -> Perm:
    """Composition (a after b): i -> a[b[i]]."""
    return tuple(a[b[i]] for i in range(len(a)))

def inverse(p: Perm) -> Perm:
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def is_single_cycle(p: Perm) -> bool:
    """True iff p has exactly one nontrivial cycle."""
    seen = [False] * len(p)
    nontrivial = 0
    for s in range(len(p)):
        if seen[s]:
            continue
        length = 0
        j = s
        while not seen[j]:
            seen[j] = True
            j = p[j]
            length += 1
        if length >= 2:
            nontrivial += 1
    return nontrivial == 1

def adjacent(sigma: Perm, tau: Perm) -> bool:
    """Brualdi-Gibson: P_sigma ~ P_tau iff sigma^{-1} tau is a single cycle."""
    if sigma == tau:
        return False
    return is_single_cycle(compose(inverse(sigma), tau))
