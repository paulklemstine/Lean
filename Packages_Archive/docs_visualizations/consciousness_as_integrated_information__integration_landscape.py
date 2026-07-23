"""Plot the 'integration landscape': cross-information of every nontrivial
bipartition of a causal system, highlighting the Minimum Information Partition
(the MIP, whose value is Phi). Saves phi_landscape.png."""
from itertools import combinations
import matplotlib.pyplot as plt

weight = [[0, 1, 2, 0.2],
          [1.5, 0, 0.5, 1.0],
          [0.8, 1.2, 0, 0.3],
          [0.4, 0.1, 2.0, 0]]
n = len(weight)

cuts, vals = [], []
for k in range(1, n):
    for s in combinations(range(n), k):
        comp = [j for j in range(n) if j not in set(s)]
        cuts.append("{" + ",".join(map(str, s)) + "}")
        vals.append(sum(weight[i][j] for i in s for j in comp))

phi = min(vals)
colors = ["crimson" if v == phi else "steelblue" for v in vals]
plt.figure(figsize=(11, 5))
plt.bar(range(len(vals)), vals, color=colors)
plt.axhline(phi, color="crimson", ls="--", lw=1,
            label=f"Phi = {phi:g} (Minimum Information Partition)")
plt.xticks(range(len(cuts)), cuts, rotation=60, ha="right", fontsize=8)
plt.ylabel("cross-information across cut")
plt.title("Integration landscape: Phi is the system's weakest cut")
plt.legend()
plt.tight_layout()
plt.savefig("phi_landscape.png", dpi=150)
print("saved phi_landscape.png; Phi =", phi)
