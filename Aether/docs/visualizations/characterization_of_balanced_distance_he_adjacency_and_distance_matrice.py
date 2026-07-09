import matplotlib.pyplot as plt
from collections import deque
from itertools import combinations

def main() -> None:
    n = 6
    A = [[1 if (i != j and i // 2 != j // 2) else 0 for j in range(n)] for i in range(n)]
    adj = [set(j for j in range(n) if A[i][j]) for i in range(n)]
    D = [[0]*n for _ in range(n)]
    for s in range(n):
        seen = {s: 0}; q = deque([s])
        while q:
            u = q.popleft()
            for w in adj[u]:
                if w not in seen:
                    seen[w] = seen[u] + 1; q.append(w)
        for t in range(n):
            D[s][t] = seen[t]
    fig, axes = plt.subplots(1, 2, figsize=(10, 5))
    for ax, M, title in ((axes[0], A, "Adjacency"), (axes[1], D, "Distance")):
        im = ax.imshow(M, cmap="viridis")
        ax.set_title(f"{title} matrix of co(3K2)")
        ax.set_xticks(range(n)); ax.set_yticks(range(n))
        for i in range(n):
            for j in range(n):
                ax.text(j, i, str(M[i][j]), ha="center", va="center", color="white")
        fig.colorbar(im, ax=ax, fraction=0.046)
    plt.tight_layout(); plt.savefig("octahedron_matrices.png", dpi=150)
    print("saved octahedron_matrices.png")

if __name__ == "__main__":
    main()
