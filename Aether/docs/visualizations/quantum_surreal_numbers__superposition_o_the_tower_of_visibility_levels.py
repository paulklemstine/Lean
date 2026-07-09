"""Visibility tower: eps-valuation of the Born weight vs. amplitude order."""
import matplotlib.pyplot as plt

ORDER = 20
def mul(a, b):
    out = [0.0] * ORDER
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            if i + j < ORDER:
                out[i + j] += x * y
    return out
def valuation(a, tol=1e-12):
    for i, c in enumerate(a):
        if abs(c) > tol:
            return i
    return ORDER

ks = list(range(0, 8))
vals = []
for k in ks:
    amp = [1.0 if i == k else 0.0 for i in range(ORDER)]
    vals.append(valuation(mul(amp, amp)))

plt.figure(figsize=(7, 4.5))
plt.step(ks, vals, where="mid", linewidth=2)
plt.scatter(ks, vals, zorder=3)
plt.axhline(0.5, color="crimson", linestyle="--", label="ordinary standard-part resolution")
plt.xlabel("amplitude order  k   (amplitude ~ eps^k)")
plt.ylabel("Born-weight valuation  =  visibility level")
plt.title("A tower of visibility levels: deeper branches need finer lenses")
plt.legend()
plt.tight_layout()
plt.savefig("visibility_tower.png", dpi=150)
print("saved visibility_tower.png")
