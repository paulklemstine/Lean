"""Visualization: the rank-nullity conservation laws of a chain complex.

Renders a stacked-bar 'dimension budget' showing how the ambient space F^n
splits as  n = dim(im d1) + dim Z_1  and how the cycle space splits as
dim Z_1 = dim B_1 + beta_1 (logical qubits).
"""
import matplotlib.pyplot as plt

# Example complex dimensions (n=8): rank(d1)=3 so dim Z_1=5; dim B_1=2 so beta_1=3.
n = 8
rank_d1 = 3
dim_Z1 = n - rank_d1     # 5
dim_B1 = 2
beta1 = dim_Z1 - dim_B1  # 3

fig, ax = plt.subplots(figsize=(7, 5))
ax.bar(["F^n = ambient"], [rank_d1], label="im(d1): syndromes", color="#d98880")
ax.bar(["F^n = ambient"], [dim_Z1], bottom=[rank_d1],
       label="Z_1: cycles", color="#85c1e9")
ax.bar(["Z_1 = cycles"], [dim_B1], label="B_1: boundaries", color="#82e0aa")
ax.bar(["Z_1 = cycles"], [beta1], bottom=[dim_B1],
       label="H_1: logical qubits (beta_1)", color="#bb8fce")
ax.set_ylabel("dimension")
ax.set_title(f"Dimension budget (n={n}): n=rank(d1)+dim Z_1, "
             f"dim Z_1=dim B_1+beta_1")
ax.legend(loc="upper right", fontsize=8)
plt.tight_layout()
plt.savefig("rank_nullity_budget.png", dpi=150)
print("saved rank_nullity_budget.png")
