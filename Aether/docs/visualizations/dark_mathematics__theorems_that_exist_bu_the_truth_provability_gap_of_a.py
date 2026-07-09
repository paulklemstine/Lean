"""Visualize the truth/provability gap of a dark statement: instances are true
(shaded) but none is provable (no marker). Requires matplotlib."""
import matplotlib.pyplot as plt

N = 20
true_instances = list(range(N))       # every atom true in the all-true model
provable_instances = []               # cautious model proves no atom

fig, ax = plt.subplots(figsize=(9, 3))
ax.bar(true_instances, [1] * len(true_instances), color="royalblue",
       label="genuinely true T(n)")
ax.scatter(provable_instances, [0.5] * len(provable_instances),
           color="orange", zorder=5, label="provable T(n) (none!)")
ax.axhline(1.15, color="green", ls="--")
ax.text(N / 2, 1.22, "existential closure: PROVABLE", ha="center", color="green")
ax.set_xlabel("instance index n")
ax.set_yticks([])
ax.set_title("Shadow Theorem: all instances true, none provable")
ax.legend(loc="lower right")
plt.tight_layout()
plt.savefig("shadow_gap.png", dpi=150)
print("wrote shadow_gap.png")
