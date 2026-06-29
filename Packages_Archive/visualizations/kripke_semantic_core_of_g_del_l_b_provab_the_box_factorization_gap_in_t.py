"""Visualization: the synchronized product and the box-factorization gap.

Renders the 2x1 product of boolEdge x unitDead as a grid, marking the strict
witness (true, ()) that lies in box(A x B) but not in (box A) x (box B).
"""
from __future__ import annotations

def main() -> None:
    F = [True, False]           # boolEdge: true -> false
    G = ["()"]                  # unitDead: dead end
    FR = lambda x, y: x is True and y is False
    GR = lambda x, y: False
    A, B = {True}, {"()"}

    def box(W, R, S):
        return {w for w in W if all(v in S for v in W if R(w, v))}

    PW = [(a, b) for a in F for b in G]
    PR = lambda p, q: FR(p[0], q[0]) and GR(p[1], q[1])
    rect = {(a, b) for a in A for b in B}
    box_rect = box(PW, PR, rect)
    rb = {(a, b) for a in box(F, FR, A) for b in box(G, GR, B)}

    print("product worlds :", PW)
    print("box(A x B)     :", sorted(map(str, box_rect)))
    print("(boxA) x (boxB):", sorted(map(str, rb)))
    print("strict gap     :", sorted(map(str, box_rect - rb)))
    try:
        import matplotlib.pyplot as plt
        fig, ax = plt.subplots(figsize=(5,4))
        for i,(a,b) in enumerate(PW):
            inbr = (a,b) in box_rect; inrb = (a,b) in rb
            color = "tomato" if (inbr and not inrb) else ("seagreen" if inrb else "lightgray")
            ax.scatter([a is True], [0], s=2000, c=color)
            ax.text(int(a is True), 0, f"({a},{b})", ha="center", va="center")
        ax.set_title("Strict witness (red): box(A x B) but not box A x box B")
        ax.axis("off"); plt.tight_layout(); plt.savefig("gl_box_factor.png", dpi=120)
        print("wrote gl_box_factor.png")
    except Exception:
        pass

if __name__ == "__main__":
    main()
