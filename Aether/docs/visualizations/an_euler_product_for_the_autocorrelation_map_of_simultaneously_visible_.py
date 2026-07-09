"""Visualize simultaneously visible lattice points V_S for a chosen observer
set S, coloring visible points and marking observers. Requires matplotlib."""
from math import gcd
from functools import reduce
import matplotlib.pyplot as plt

def vec_gcd(w):
    return reduce(gcd, (abs(c) for c in w), 0)

def in_V_S(v, S):
    return all(vec_gcd((v[0]-x[0], v[1]-x[1])) == 1 for x in S)

def main():
    S = [(0, 0), (1, 0)]
    N = 40
    xs_vis, ys_vis, xs_hid, ys_hid = [], [], [], []
    for a in range(-N, N + 1):
        for b in range(-N, N + 1):
            if in_V_S((a, b), S):
                xs_vis.append(a); ys_vis.append(b)
            else:
                xs_hid.append(a); ys_hid.append(b)
    plt.figure(figsize=(7, 7))
    plt.scatter(xs_hid, ys_hid, s=4, c="#dddddd", label="obstructed")
    plt.scatter(xs_vis, ys_vis, s=6, c="#1f77b4", label="simultaneously visible")
    plt.scatter([p[0] for p in S], [p[1] for p in S], s=90, c="red",
                marker="*", label="observers S", zorder=5)
    plt.gca().set_aspect("equal")
    plt.title("Points simultaneously visible from S = {(0,0),(1,0)}")
    plt.legend(loc="upper right")
    plt.tight_layout()
    plt.savefig("visible_points.png", dpi=140)
    print("wrote visible_points.png")

if __name__ == "__main__":
    main()
