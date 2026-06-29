"""Visualization: the interleaving distance as the worst birth-time gap.

Plots two filtrations' weights across simplices and highlights the single
simplex realizing the interleaving distance (the attained supremum).
Requires matplotlib.  Run:  python visualize_isometry.py
"""
from itertools import combinations
import matplotlib.pyplot as plt


def all_simplices(vs):
    return [frozenset(c) for r in range(len(vs) + 1) for c in combinations(vs, r)]


def main() -> None:
    V = ["a", "b", "c"]
    S = [s for s in all_simplices(V) if s]  # drop empty for readability
    base = {frozenset("a"): 0.0, frozenset("b"): 0.0, frozenset("c"): 0.0,
            frozenset("ab"): 1.0, frozenset("ac"): 2.0, frozenset("bc"): 3.0,
            frozenset("abc"): 3.0}
    pert = dict(base); pert[frozenset("ac")] = 2.7; pert[frozenset("bc")] = 2.5
    labels = ["".join(sorted(s)) for s in S]
    wf = [base[s] for s in S]
    wg = [pert[s] for s in S]
    gaps = [abs(a - b) for a, b in zip(wf, wg)]
    dstar = max(gaps); arg = gaps.index(dstar)

    x = range(len(S))
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(9, 7), sharex=True)
    ax1.plot(x, wf, "o-", label="w_F (filtration F)")
    ax1.plot(x, wg, "s-", label="w_G (perturbed G)")
    ax1.set_ylabel("birth scale"); ax1.legend(); ax1.set_title(
        "Two filtrations and their birth-time gaps")
    ax2.bar(x, gaps, color="#bbb")
    ax2.bar([arg], [dstar], color="#d62728",
            label=f"interleaving distance = {dstar:.2f}")
    ax2.set_xticks(list(x)); ax2.set_xticklabels(labels)
    ax2.set_ylabel("|w_F - w_G|"); ax2.set_xlabel("simplex"); ax2.legend()
    ax2.set_title("d(F,G) = max gap, attained at the highlighted simplex")
    fig.tight_layout(); fig.savefig("isometry.png", dpi=130)
    print("wrote isometry.png")


if __name__ == "__main__":
    main()
