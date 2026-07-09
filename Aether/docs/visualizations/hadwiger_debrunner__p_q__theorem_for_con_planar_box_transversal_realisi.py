"""Visualization: transversal of a family of axis-aligned boxes in the plane,
illustrating the one-shot bound |T| <= |s| - q + 1. Requires matplotlib."""
from itertools import combinations
import matplotlib.pyplot as plt
import matplotlib.patches as patches

# A family of rectangles; the first q all overlap a common region near (5,5).
boxes = {
    "S1": (3, 3, 5, 5), "S2": (4, 2, 6, 6), "S3": (2, 4, 6, 5),
    "S4": (4, 4, 7, 7), "X": (0, 8, 2, 10), "Y": (8, 0, 10, 2),
}  # (x0, y0, x1, y1)


def overlap(bs):
    x0 = max(b[0] for b in bs); y0 = max(b[1] for b in bs)
    x1 = min(b[2] for b in bs); y1 = min(b[3] for b in bs)
    return (x0, y0, x1, y1) if x0 < x1 and y0 < y1 else None


def one_shot(boxes, q):
    keys = list(boxes)
    for B in combinations(keys, q):
        reg = overlap([boxes[i] for i in B])
        if reg:
            t0 = ((reg[0] + reg[2]) / 2, (reg[1] + reg[3]) / 2)
            T = [t0]
            for i in keys:
                if i not in B:
                    b = boxes[i]
                    T.append(((b[0] + b[2]) / 2, (b[1] + b[3]) / 2))
            return T, B
    return None, None


q = 4
T, B = one_shot(boxes, q)
fig, ax = plt.subplots(figsize=(7, 7))
for name, (x0, y0, x1, y1) in boxes.items():
    color = "tab:blue" if name in B else "tab:gray"
    ax.add_patch(patches.Rectangle((x0, y0), x1 - x0, y1 - y0,
                 fill=True, alpha=0.25, edgecolor=color, facecolor=color, lw=2))
    ax.text((x0 + x1) / 2, (x0 + x1) / 2 * 0 + (y0 + y1) / 2, name,
            ha="center", va="center")
for p in T:
    ax.plot(*p, "r*", markersize=18)
ax.set_xlim(-1, 11); ax.set_ylim(-1, 11); ax.set_aspect("equal")
ax.set_title(f"Transversal (red stars), |T|={len(T)} <= |s|-q+1={len(boxes)-q+1}")
plt.tight_layout(); plt.savefig("transversal.png", dpi=120)
print("Saved transversal.png; |T| =", len(T))
