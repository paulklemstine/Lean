"""Visualize the phantom index across random finite membership structures."""
import random
from typing import Dict, Set, Hashable, Sequence, List
import matplotlib.pyplot as plt


def ext_equiv(rel: Dict[int, Set[int]], a: int, b: int, universe: Sequence[int]) -> bool:
    ma, mb = rel.get(a, set()), rel.get(b, set())
    return all((x in ma) == (x in mb) for x in universe)


def phantom_index(rel: Dict[int, Set[int]], universe: Sequence[int]) -> int:
    classes: List[int] = []
    for a in universe:
        if not any(ext_equiv(rel, a, r, universe) for r in classes):
            classes.append(a)
    return len(universe) - len(classes)


def random_structure(n: int, p: float) -> Dict[int, Set[int]]:
    return {y: {x for x in range(n) if random.random() < p} for y in range(n)}


def main() -> None:
    n = 8
    ps = [i / 20 for i in range(1, 20)]
    avg_index = []
    for p in ps:
        vals = [phantom_index(random_structure(n, p), list(range(n))) for _ in range(400)]
        avg_index.append(sum(vals) / len(vals))
    plt.figure(figsize=(8, 5))
    plt.plot(ps, avg_index, marker="o")
    plt.xlabel("membership density p")
    plt.ylabel(f"average phantom index (universe size {n})")
    plt.title("Phantoms vanish as membership becomes more discriminating")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("phantom_index.png", dpi=150)
    print("wrote phantom_index.png")


if __name__ == "__main__":
    main()
