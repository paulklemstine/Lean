"""Visualization: the Berggren ternary tree of Pythagorean triples,
drawn as nested points whose Farey fractions b/(a+c) fill [0,1]."""
import math
from fractions import Fraction
import matplotlib.pyplot as plt

BB = [((1, -2, 2), (2, -1, 2), (2, -2, 3)),
      ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
      ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3))]


def apply3(a, v):
    return tuple(sum(a[i][k] * v[k] for k in range(3)) for i in range(3))


fig, ax = plt.subplots(figsize=(11, 6))
frontier = [(3, 4, 5)]
for level in range(6):
    xs = [float(Fraction(b, a + c)) for (a, b, c) in frontier]
    ys = [level] * len(frontier)
    ax.scatter(xs, ys, s=18, color="steelblue")
    frontier = [apply3(B, t) for t in frontier for B in BB]
ax.set_xlabel("Farey fraction b/(a+c)")
ax.set_ylabel("tree depth")
ax.set_title("Berggren tree of Pythagorean triples -> Farey fractions in [0,1]")
ax.invert_yaxis()
plt.tight_layout()
plt.savefig("berggren_farey.png", dpi=150)
print("saved berggren_farey.png")
