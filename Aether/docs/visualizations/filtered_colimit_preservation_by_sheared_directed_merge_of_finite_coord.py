"""Visualization: directed merge of finitely many coordinate witnesses."""
from __future__ import annotations
import matplotlib.pyplot as plt


def main() -> None:
    witnesses = [3, 7, 2, 6]  # per-coordinate stages c(k)
    M = max(witnesses)
    fig, ax = plt.subplots(figsize=(8, 5))
    for k, c in enumerate(witnesses):
        ax.plot([k, k], [0, c], color="steelblue", lw=3)
        ax.plot(k, c, "o", color="steelblue")
        ax.annotate(f"c({k})={c}", (k, c), textcoords="offset points",
                    xytext=(5, 5), fontsize=9)
    ax.axhline(M, color="crimson", ls="--", lw=2, label=f"merged stage M={M}")
    ax.set_xticks(range(len(witnesses)))
    ax.set_xlabel("coordinate k"); ax.set_ylabel("stage index")
    ax.set_title("Directedness merges finitely many witnesses into one stage M")
    ax.legend(); fig.tight_layout(); fig.savefig("merge.png", dpi=130)
    print("wrote merge.png")


if __name__ == "__main__":
    main()
