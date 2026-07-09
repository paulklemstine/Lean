"""Visualization: running intersection of an ascending chain stays at I_0."""
import matplotlib.pyplot as plt


def in_suppLt(f, n):
    return all(i < n for i in f)


def plot_loop_back(universe_bound: int = 8, N: int = 8) -> None:
    all_seqs = [
        frozenset(i for i in range(universe_bound) if (mask >> i) & 1)
        for mask in range(1 << universe_bound)
    ]
    sizes = []
    inter = set(all_seqs)
    for n in range(N + 1):
        inter &= {f for f in all_seqs if in_suppLt(f, n)}
        sizes.append(len(inter))
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(range(N + 1), sizes, "o-")
    ax.axhline(1, ls="--", color="gray", label="|I_0| = 1 (zero ideal)")
    ax.set_xlabel("number of ideals intersected")
    ax.set_ylabel("size of running intersection")
    ax.set_title("Loop-Back Lemma: intersection pinned at I_0 = {0}")
    ax.legend()
    plt.tight_layout()
    plt.savefig("loop_back.png", dpi=150)
    print("wrote loop_back.png")


if __name__ == "__main__":
    plot_loop_back()
