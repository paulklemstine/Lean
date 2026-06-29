"""Visualize the rank stratification of a GL frame as horizontal layers,
with box^k(empty) and diamond^k(univ) shaded as complementary regions."""
import matplotlib.pyplot as plt
from typing import Dict, List, Set, Tuple

def build() -> Tuple[List[str], Dict[str, Set[str]], Dict[str, int]]:
    worlds = ["a", "b", "c", "d", "e"]
    succ = {"a": {"b","c","d","e"}, "b": {"d"}, "c": {"d","e"}, "d": set(), "e": set()}
    memo: Dict[str, int] = {}
    def r(w: str) -> int:
        if w in memo: return memo[w]
        memo[w] = 1 + max((r(v) for v in succ[w]), default=-1)
        return memo[w]
    return worlds, succ, {w: r(w) for w in worlds}

if __name__ == "__main__":
    worlds, succ, ranks = build()
    maxr = max(ranks.values())
    fig, ax = plt.subplots(figsize=(7, 5))
    for w in worlds:
        ax.scatter(hash(w) % 5, ranks[w], s=600, zorder=3)
        ax.annotate(w, (hash(w) % 5, ranks[w]), ha="center", va="center")
    for level in range(maxr + 1):
        ax.axhline(level + 0.5, ls="--", color="gray", alpha=0.5)
        ax.text(-0.8, level, f"rank {level}", va="center")
    ax.set_title("Rank stratification: box^k(empty)={rank<k}, diamond^k(univ)={rank>=k}")
    ax.set_ylabel("ordinal rank")
    ax.set_xticks([])
    plt.tight_layout()
    plt.savefig("rank_stratification.png", dpi=140)
    print("wrote rank_stratification.png")
