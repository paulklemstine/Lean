"""Bar chart: reduced Euler characteristic of base complexes vs. their cones.

Shows that arbitrary complexes have varied chi-tilde (detecting holes), while
EVERY cone collapses to chi-tilde = 0 (Theorem ASC.reducedEuler_cone).
"""
from itertools import combinations
from typing import FrozenSet, Iterable, Set
import matplotlib.pyplot as plt

Face = FrozenSet[int]
Complex = Set[Face]


def downward_closure(facets: Iterable[Iterable[int]]) -> Complex:
    faces: Complex = {frozenset()}
    for facet in facets:
        verts = tuple(facet)
        for k in range(len(verts) + 1):
            for sub in combinations(verts, k):
                faces.add(frozenset(sub))
    return faces


def reduced_euler(faces: Complex) -> int:
    return sum((-1) ** (len(F) + 1) for F in faces)


def cone(faces: Complex, v: int) -> Complex:
    return set(faces) | {F | {v} for F in faces}


bases = {
    "point": downward_closure([[0]]),
    "circle S^1": downward_closure([[0, 1], [1, 2], [0, 2]]),
    "disk": downward_closure([[0, 1, 2]]),
    "sphere S^2": downward_closure([[0, 1, 2], [0, 1, 3], [0, 2, 3], [1, 2, 3]]),
    "2 edges": downward_closure([[0, 1], [2, 3]]),
}
apex = 99
labels = list(bases)
base_chi = [reduced_euler(b) for b in bases.values()]
cone_chi = [reduced_euler(cone(b, apex)) for b in bases.values()]

x = range(len(labels))
fig, ax = plt.subplots(figsize=(9, 5))
ax.bar([i - 0.2 for i in x], base_chi, width=0.4, label="base complex", color="#3b82f6")
ax.bar([i + 0.2 for i in x], cone_chi, width=0.4, label="cone over it", color="#ef4444")
ax.axhline(0, color="black", linewidth=0.8)
ax.set_xticks(list(x))
ax.set_xticklabels(labels, rotation=20)
ax.set_ylabel(r"reduced Euler characteristic $\tilde\chi$")
ax.set_title("Cones collapse the reduced Euler characteristic to 0")
ax.legend()
plt.tight_layout()
plt.savefig("cone_euler_collapse.png", dpi=150)
print("wrote cone_euler_collapse.png")
