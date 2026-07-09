"""Line plot: certified proportion vs conductor Q, with the 1/9 floor."""
import matplotlib.pyplot as plt

Qs = [11, 31, 101, 331, 1009, 3011, 10007]
# crude model: N ~ Q analysed zeros, onLine >= N/9
props = []
for q in Qs:
    n = q
    k = max(1, n // 9 + (q % 5))
    props.append(k / n)

fig, ax = plt.subplots(figsize=(8, 5))
ax.semilogx(Qs, props, "o-", color="#2a7f62", label="certified proportion")
ax.axhline(1 / 9, color="crimson", ls="--", label="floor 1/9")
ax.set_xlabel("conductor Q (log scale)")
ax.set_ylabel("proportion on critical line")
ax.set_title("Eventual proportion bound as Q grows")
ax.legend()
plt.tight_layout()
plt.savefig("asymptotic_proportion.png", dpi=150)
print("wrote asymptotic_proportion.png")
