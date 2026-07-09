"""Visualize the strict darkness hierarchy as a descending ladder of provable
witness counts. Requires matplotlib."""
import matplotlib.pyplot as plt

def provable_level(k_true: int, k_query: int) -> bool:
    return k_query <= k_true  # 'at least k_query' provable iff k_query <= true count

max_k = 8
fig, ax = plt.subplots(figsize=(8, 5))
for k_true in range(max_k + 1):
    provable = [k for k in range(max_k + 2) if provable_level(k_true, k)]
    ax.plot(provable, [k_true] * len(provable), "o-", color="crimson")
    ax.plot([k_true + 1], [k_true], "x", color="black", markersize=9)
ax.set_xlabel("query count k in 'at least k witnesses'")
ax.set_ylabel("model: number of true atoms")
ax.set_title("Strict Darkness Hierarchy: provable (dots) vs first unprovable (x)")
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("darkness_ladder.png", dpi=150)
print("wrote darkness_ladder.png")
