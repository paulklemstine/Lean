import matplotlib.pyplot as plt
from typing import List

# Number of statements provable by each time stage (monotone, by Theorem 4.1).
times: List[int] = list(range(0, 8))
provable_count: List[int] = [0, 1, 1, 3, 4, 4, 6, 7]  # non-decreasing staircase

fig, ax = plt.subplots(figsize=(8, 5))
ax.step(times, provable_count, where="post", linewidth=2.5, color="#1f77b4")
ax.fill_between(times, provable_count, step="post", alpha=0.15, color="#1f77b4")

# A new theorem appears at t=3 ("tomorrow but not today" — allowed).
ax.annotate("new theorem appears\n(provable tomorrow, not today)",
            xy=(3, 3), xytext=(3.3, 1.4),
            arrowprops=dict(arrowstyle="->"), fontsize=9)
# Nothing ever drops ("today but not tomorrow" — forbidden).
ax.text(4.2, 6.4, "the curve can never go DOWN\n(today-not-tomorrow refuted)",
        fontsize=9, color="#d62728")

ax.set_xlabel("time stage t")
ax.set_ylabel("# statements provable by stage t")
ax.set_title("TGL: provability is a one-way ratchet")
ax.set_ylim(0, 8)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("one_way_ratchet.png", dpi=150)
print("wrote one_way_ratchet.png")
