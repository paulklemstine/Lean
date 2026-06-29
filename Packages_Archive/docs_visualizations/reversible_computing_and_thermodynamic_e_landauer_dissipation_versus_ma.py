"""Visualization: dissipated Landauer work vs. maximum fiber size.

Generates a bar chart showing how the minimum dissipated heat grows as a
deterministic map merges more inputs per output (fatter fibers), with the
reversible (max-fiber = 1) map sitting exactly at zero dissipation. Saves
'landauer_dissipation.png'. Requires matplotlib.
"""
import math
import matplotlib.pyplot as plt

K, T = 1.380649e-23, 300.0

def shannon_entropy(p):
    return -sum(px * math.log(px) for px in p if px > 0.0)

# 3-bit uniform register collapsed by maps with increasing fiber size.
support = list(range(8))
p = [1.0 / 8] * 8
maps = {
    "identity\n(fiber 1)": lambda x: x,
    "x mod 4\n(fiber 2)": lambda x: x % 4,
    "x mod 2\n(fiber 4)": lambda x: x % 2,
    "erase\n(fiber 8)": lambda x: 0,
}
labels, works = [], []
for name, f in maps.items():
    img = {}
    for x in support:
        img[f(x)] = img.get(f(x), 0.0) + p[x]
    w = K * T * (shannon_entropy(p) - shannon_entropy(list(img.values())))
    labels.append(name)
    works.append(w * 1e21)  # zeptojoules

plt.figure(figsize=(8, 5))
bars = plt.bar(labels, works, color="#c0392b")
plt.ylabel("Minimum dissipated heat (zJ)")
plt.title("Landauer dissipation grows with fiber size (3-bit register, 300 K)")
for b, w in zip(bars, works):
    plt.text(b.get_x() + b.get_width() / 2, w + 0.05, f"{w:.2f}",
             ha="center", va="bottom")
plt.tight_layout()
plt.savefig("landauer_dissipation.png", dpi=150)
print("saved landauer_dissipation.png")
