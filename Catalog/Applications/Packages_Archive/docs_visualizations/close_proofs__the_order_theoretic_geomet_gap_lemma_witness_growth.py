"""Visualization: the Gap Lemma margin. Generates 'gap.png' showing how the
least Gap-Lemma witness n grows with the blow-up degree c (theory: n = c+1)."""
from __future__ import annotations
import matplotlib.pyplot as plt
from typing import Optional


def gap_witness(c: int, k: int, n_search: int = 200) -> Optional[int]:
    for n in range(2, n_search + 1):
        if (2 ** (n ** k) + 2) ** c < 2 ** (n ** (k + 1)):
            return n
    return None


cs = list(range(1, 12))
fig, ax = plt.subplots(figsize=(8, 5))
for k in (1, 2, 3):
    ax.plot(cs, [gap_witness(c, k) for c in cs], marker="o", label=f"k={k}")
ax.plot(cs, [max(2, c + 1) for c in cs], "k--", label="prediction max(2,c+1)")
ax.set_xlabel("blow-up degree c"); ax.set_ylabel("least Gap-Lemma witness n")
ax.set_title("Gap Lemma: every polynomial degree c is defeated at n = c+1")
ax.legend(); plt.tight_layout(); plt.savefig("gap.png", dpi=130)
print("wrote gap.png")
