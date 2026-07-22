from typing import List, Set

def greedy_sidon(n: int) -> List[int]:
    """Greedy (Mian-Chowla-type) construction of a Sidon set inside {1,...,n}.
    Admits each candidate x whose new differences x - s avoid all realized
    differences. Runs in O(n * |S|) time."""
    chosen: List[int] = []
    realized: Set[int] = set()
    for x in range(1, n + 1):
        new = {x - s for s in chosen}
        if new.isdisjoint(realized):
            chosen.append(x)
            realized |= new
            realized |= {-d for d in new}
    return chosen
