import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations

def generated_closure(rules, seed, universe):
    closed = set(seed)
    changed = True
    while changed:
        changed = False
        for premises, conclusion in rules:
            if premises <= closed and conclusion not in closed:
                closed.add(conclusion)
                changed = True
    return closed

universe = {"a", "b", "c", "d"}
rules = [
    (frozenset({"a"}), "b"),
    (frozenset({"b"}), "c"),
    (frozenset({"c", "d"}), "a"),
]
cl = lambda s: generated_closure(rules, s, universe)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 8))

# Left: Closure lattice
closed_sets = []
elems = sorted(universe)
for r in range(len(elems) + 1):
    for combo in combinations(elems, r):
        s = set(combo)
        if cl(s) == s:
            closed_sets.append(frozenset(s))

closed_sets.sort(key=lambda s: (len(s), sorted(s)))
positions = {}
by_size = {}
for cs in closed_sets:
    sz = len(cs)
    by_size.setdefault(sz, []).append(cs)

for sz, sets in by_size.items():
    for i, cs in enumerate(sets):
        x = (i - (len(sets) - 1) / 2) * 2
        positions[cs] = (x, sz * 1.5)

for cs in closed_sets:
    x, y = positions[cs]
    label = "{" + ",".join(sorted(cs)) + "}" if cs else "∅"
    ax1.annotate(label, (x, y), ha="center", va="center",
                fontsize=9, bbox=dict(boxstyle="round,pad=0.3", facecolor="lightblue"))
    for cs2 in closed_sets:
        if cs < cs2 and len(cs2) == len(cs) + 1:
            if not any(cs < cs3 < cs2 for cs3 in closed_sets):
                x2, y2 = positions[cs2]
                ax1.plot([x, x2], [y, y2], "k-", alpha=0.3)

ax1.set_title("Closed Sets (Lattice)", fontsize=14)
ax1.set_xlim(-4, 4)
ax1.set_ylim(-0.5, 7)
ax1.axis("off")

# Right: Circuit structure
ax2.text(0.5, 0.95, "Reconstructed DNF Circuits", ha="center", va="top",
         fontsize=14, transform=ax2.transAxes)

circuit_text = [
    "a: Input(a) ∨ (Input(c) ∧ Input(d))",
    "b: Input(a) ∨ Input(b) ∨ (Input(c) ∧ Input(d))",
    "c: Input(a) ∨ Input(b) ∨ Input(c)",
    "d: Input(d)",
]
for i, line in enumerate(circuit_text):
    y = 0.75 - i * 0.15
    ax2.text(0.1, y, line, ha="left", va="center",
             fontsize=11, transform=ax2.transAxes, family="monospace")

ax2.axis("off")
plt.tight_layout()
plt.savefig("closure_lattice_circuit.png", dpi=150, bbox_inches="tight")
print("Saved closure_lattice_circuit.png")