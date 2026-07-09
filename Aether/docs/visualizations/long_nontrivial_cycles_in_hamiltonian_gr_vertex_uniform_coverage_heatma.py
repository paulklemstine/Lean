import matplotlib.pyplot as plt
import numpy as np
from typing import Dict, List, Set, Tuple

def build(n: int, chords: List[Tuple[int, int]]) -> Dict[int, Set[int]]:
    adj = {v: set() for v in range(n)}
    for v in range(n):
        adj[v].add((v + 1) % n); adj[(v + 1) % n].add(v)
    for a, b in chords:
        adj[a].add(b); adj[b].add(a)
    return adj

def arc(n: int, a: int, b: int) -> List[int]:
    return [(a + j) % n for j in range((b - a) % n + 1)]

def visualize_coverage(n: int = 16) -> None:
    adj = build(n, [(v, (v + 5) % n) for v in range(n)])
    M = np.zeros((n, n))
    for v in range(n):
        for w in adj[v]:
            if w not in {(v + 1) % n, (v - 1) % n}:
                for u in arc(n, v, w):
                    M[v, u] = 1
                break
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.imshow(M, cmap="Blues")
    ax.set_xlabel("vertex on cycle"); ax.set_ylabel("anchor vertex")
    ax.set_title(f"Second-cycle coverage matrix (n = {n})")
    plt.tight_layout(); plt.savefig("coverage_heatmap.png", dpi=150)

if __name__ == "__main__":
    visualize_coverage()
