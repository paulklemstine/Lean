import math
import matplotlib.pyplot as plt

def image_card(f, dom): return len({f(x) for x in dom})
def compose(fs):
    def g(x):
        for f in fs: x = f(x)
        return x
    return g

dom = list(range(16))
fs = [lambda x: x % 8, lambda x: x % 4, lambda x: x % 2, lambda x: 0]
drops = []
for i in range(len(fs)):
    b = image_card(compose(fs[:i]), dom)
    a = image_card(compose(fs[:i+1]), dom)
    drops.append(math.log2(b) - math.log2(a))

cum = [0.0]
for d in drops:
    cum.append(cum[-1] + d)

fig, ax = plt.subplots(figsize=(8, 5))
xs = range(1, len(drops) + 1)
ax.bar(xs, drops, bottom=cum[:-1], color="#c0392b", alpha=0.8,
       label="per-step production (bits)")
ax.step(range(len(cum)), cum, where="post", color="#2c3e50", lw=2,
        label="cumulative total erasure")
ax.set_xlabel("inference step")
ax.set_ylabel("entropy production (bits)")
ax.set_title("Clausius waterfall: productions accumulate to the total")
ax.legend()
ax.grid(True, axis="y", alpha=0.3)
plt.tight_layout()
plt.savefig("clausius_waterfall.png", dpi=150)
print("saved clausius_waterfall.png")
