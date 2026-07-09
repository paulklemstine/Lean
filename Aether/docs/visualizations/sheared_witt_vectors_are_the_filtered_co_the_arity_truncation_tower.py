"""Visualization: the arity truncation tower and where a sheared vector lands.
Generates a bar/step figure showing truncated-set membership vs. level n."""
from __future__ import annotations
import matplotlib.pyplot as plt

def support_bound(seq, basepoint=0):
    last = -1
    for k, v in enumerate(seq):
        if v != basepoint:
            last = k
    return last + 1

def is_truncated_at(seq, n, basepoint=0):
    return all(seq[k] == basepoint for k in range(n, len(seq)))

def main() -> None:
    seq = [3, 0, 5, 0, 0, 0, 0, 0]
    N = support_bound(seq)
    levels = list(range(len(seq) + 1))
    member = [1 if is_truncated_at(seq, n) else 0 for n in levels]
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.step(levels, member, where="post", linewidth=2, color="#2b6cb0")
    ax.axvline(N, color="#c53030", linestyle="--", label=f"support bound N={N}")
    ax.set_xlabel("truncation level n")
    ax.set_ylabel("in level-n truncated set?")
    ax.set_yticks([0, 1]); ax.set_yticklabels(["no", "yes"])
    ax.set_title("Sheared vector as colimit of truncations")
    ax.legend()
    fig.tight_layout()
    fig.savefig("tower.png", dpi=150)
    print("wrote tower.png")

if __name__ == "__main__":
    main()
