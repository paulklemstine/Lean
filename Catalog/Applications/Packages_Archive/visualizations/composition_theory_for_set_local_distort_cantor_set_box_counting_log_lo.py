"""Log-log box-counting plot for the middle-thirds Cantor set. Requires matplotlib."""
import math
import matplotlib.pyplot as plt

def cantor_points(depth=12):
    pts = [0.0]
    for _ in range(depth):
        nxt = []
        for p in pts:
            nxt.append(p / 3.0)
            nxt.append(2.0 / 3.0 + p / 3.0)
        pts = nxt
    return pts

pts = cantor_points(12)
scales = [2 ** k for k in range(1, 10)]
xs, ys = [], []
for n in scales:
    occ = {min(int(p * n), n - 1) for p in pts}
    xs.append(math.log(n)); ys.append(math.log(len(occ)))

# slope
k = len(xs); mx = sum(xs)/k; my = sum(ys)/k
slope = sum((x-mx)*(y-my) for x,y in zip(xs,ys)) / sum((x-mx)**2 for x in xs)

plt.figure(figsize=(7,5))
plt.plot(xs, ys, "o-", color="#1f6f8b")
plt.title(f"Box counting of Cantor set: slope ~ {slope:.3f}  (log2/log3 = {math.log(2)/math.log(3):.3f})")
plt.xlabel("log(1/eps)"); plt.ylabel("log N(eps)")
plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("cantor_loglog.png", dpi=150)
print("saved cantor_loglog.png")
