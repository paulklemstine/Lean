"""Standalone visualization: the incoherence-index spectrum and the forbidden
interval (N/2, N) for even electorates. Renders, for each even N, the set of
incoherence indices realizable by maximal frames, highlighting that nothing lands
strictly between N/2 and N. Requires matplotlib."""
from collections import deque
from itertools import combinations
from math import gcd
import matplotlib.pyplot as plt

def incoherence_index(frame, N):
    atoms = sorted({a % N for a in frame})
    if not atoms:
        return 0
    dist = [-1] * N
    dist[0] = 0
    q = deque([0])
    while q:
        r = q.popleft()
        for a in atoms:
            s = (r + a) % N
            if s == 0:
                return dist[r] + 1
            if dist[s] == -1:
                dist[s] = dist[r] + 1
                q.append(s)
    return 0

def is_maximal(frame, N):
    g = N
    for a in frame:
        g = gcd(g, a % N)
    return g == 1

def main():
    Ns = [4, 6, 8, 10, 12, 14]
    fig, ax = plt.subplots(figsize=(9, 5))
    for row, N in enumerate(Ns):
        realizable = set()
        for size in range(1, min(N, 5) + 1):
            for frame in combinations(range(N), size):
                if is_maximal(frame, N):
                    realizable.add(incoherence_index(frame, N))
        for v in realizable:
            ax.scatter(v, row, color="tab:blue", s=40, zorder=3)
        ax.axvspan(N / 2, N, ymin=(row + 0.1) / len(Ns),
                   ymax=(row + 0.9) / len(Ns), color="tab:red", alpha=0.12)
        ax.text(-0.5, row, f"N={N}", ha="right", va="center")
    ax.set_yticks([])
    ax.set_xlabel("incoherence index of maximal frames")
    ax.set_title("Realizable indices avoid the forbidden interval (N/2, N)")
    plt.tight_layout()
    plt.savefig("forbidden_interval.png", dpi=150)
    print("wrote forbidden_interval.png")

if __name__ == "__main__":
    main()
