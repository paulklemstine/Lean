from typing import Dict, FrozenSet, List, Tuple


def bracket_key(bits: Tuple[int, ...]) -> Tuple[int, ...]:
    """Canonical bottom of a subset's symmetric chain (unmatched bits zeroed)."""
    stack: List[int] = []
    matched: set = set()
    for i, b in enumerate(bits):
        if b == 1:
            stack.append(i)
        elif stack:
            matched.add(stack.pop())
            matched.add(i)
    return tuple(bits[i] if i in matched else 0 for i in range(len(bits)))


def symmetric_chain_decomposition(n: int) -> List[List[FrozenSet[int]]]:
    """Partition 2^[n] into exactly C(n, floor(n/2)) symmetric chains."""
    groups: Dict[Tuple[int, ...], List[Tuple[int, ...]]] = {}
    for x in range(2 ** n):
        bits = tuple((x >> i) & 1 for i in range(n))
        groups.setdefault(bracket_key(bits), []).append(bits)
    chains: List[List[FrozenSet[int]]] = []
    for members in groups.values():
        members.sort(key=sum)
        chains.append([frozenset(i for i, v in enumerate(b) if v) for b in members])
    return chains
