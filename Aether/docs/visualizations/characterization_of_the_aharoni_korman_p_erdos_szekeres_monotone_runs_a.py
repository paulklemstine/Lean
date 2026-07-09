"""Visualize the Erdos-Szekeres dichotomy: a scrambled window of labels with
its longest ascending run and longest descending run highlighted, illustrating
why an infinite co-wellfounded chain must contain an unbounded descending run."""
import matplotlib.pyplot as plt
from typing import List, Sequence


def longest_monotone(seq: Sequence[float], increasing: bool) -> List[int]:
    n = len(seq)
    length = [1] * n; prev = [-1] * n
    for i in range(n):
        for j in range(i):
            better = seq[j] < seq[i] if increasing else seq[j] > seq[i]
            if better and length[j] + 1 > length[i]:
                length[i] = length[j] + 1; prev[i] = j
    end = max(range(n), key=lambda i: length[i]); out = []
    while end != -1:
        out.append(end); end = prev[end]
    return out[::-1]


def main() -> None:
    seq = [7, 2, 9, 1, 8, 3, 6, 0, 5, 4]
    inc = longest_monotone(seq, True); dec = longest_monotone(seq, False)
    xs = list(range(len(seq)))
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.plot(xs, seq, "o-", color="gray", alpha=0.5, label="labels")
    ax.plot([xs[i] for i in inc], [seq[i] for i in inc], "o-", color="green",
            lw=2, label=f"ascending run (len {len(inc)})")
    ax.plot([xs[i] for i in dec], [seq[i] for i in dec], "o-", color="crimson",
            lw=2, label=f"descending run (len {len(dec)})")
    ax.set_title("Erdos-Szekeres: monotone runs inside a window")
    ax.set_xlabel("position"); ax.set_ylabel("N^op label"); ax.legend()
    plt.tight_layout(); plt.savefig("viz_runs.png", dpi=150)
    print("wrote viz_runs.png")


if __name__ == "__main__":
    main()
