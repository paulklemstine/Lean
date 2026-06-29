"""Visualisation: orbit-piece dimension is constant under iteration."""
import math
import matplotlib.pyplot as plt

def cantor_points(depth: int):
    pts = [0.0]
    for _ in range(depth):
        pts = [p / 3 for p in pts] + [p / 3 + 2 / 3 for p in pts]
    return sorted(pts)

def box_dim(points, scales):
    import math
    xs = [math.log(1 / e) for e in scales]
    ys = [math.log(len({math.floor(p / e) for p in points})) for e in scales]
    n = len(xs); mx = sum(xs) / n; my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den

depth = 11
base = cantor_points(depth)
theo = math.log(2) / math.log(3)
ns, dims = [], []
for n in range(7):
    img = sorted(p / 3 ** n for p in base)
    span = 3.0 ** (-n)
    scales = [span / 3 ** k for k in range(1, depth)]
    ns.append(n); dims.append(box_dim(img, scales))

plt.figure(figsize=(8, 5))
plt.axhline(theo, color="crimson", ls="--", label=f"log2/log3 = {theo:.4f}")
plt.plot(ns, dims, "o-", color="navy", label="estimated dimH(f^[n](C))")
plt.xlabel("iterate n"); plt.ylabel("Hausdorff dimension estimate")
plt.title("dimH(f^[n] '' C) is constant under iteration (dimH_image_iterate_eq)")
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("iterate_invariance.png", dpi=150)
print("saved iterate_invariance.png")
