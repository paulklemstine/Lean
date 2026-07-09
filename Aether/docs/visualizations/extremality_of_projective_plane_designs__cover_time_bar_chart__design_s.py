"""Bar chart: cover time of the Fano lines vs. the singleton collector."""
from fractions import Fraction
from itertools import combinations
import matplotlib.pyplot as plt

def cover_time(blocks, points):
    tot = Fraction(0)
    for k in range(1, len(points)+1):
        s = 1 if k % 2 else -1
        for c in combinations(points, k):
            cc = sum(1 for b in blocks if b & set(c))
            if cc: tot += Fraction(s*len(blocks), cc)
    return tot

pts = list(range(7))
singles = [frozenset({a}) for a in pts]
fano = [frozenset(x) for x in
        [(0,1,2),(0,3,4),(0,5,6),(1,3,5),(1,4,6),(2,3,6),(2,4,5)]]

vals = [float(cover_time(fano, pts)), float(cover_time(singles, pts))]
labels = ["Fano lines\n163/30", "Singletons\n363/20 = 7·H7"]
plt.figure(figsize=(6,4))
bars = plt.bar(labels, vals, color=["#2a9d8f", "#e76f51"])
for b, v in zip(bars, vals):
    plt.text(b.get_x()+b.get_width()/2, v+0.3, f"{v:.2f}", ha="center")
plt.ylabel("Expected cover time")
plt.title("A balanced design covers the 7 points 3.3x faster")
plt.tight_layout()
plt.savefig("cover_time_comparison.png", dpi=150)
print("wrote cover_time_comparison.png")
