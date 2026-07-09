"""Visualization: exhaustive scatter of antipodality vs opposite-semicube isometry over subsets of Q_3."""
import matplotlib.pyplot as plt
from itertools import combinations, product

def antipode(v): return tuple(1 - b for b in v)
def semicube(S, i, b): return frozenset(v for v in S if v[i] == b)
def is_antipodal(S): return all(antipode(v) in S for v in S)
def iso(S, n): return all(frozenset(antipode(v) for v in semicube(S,i,0))==semicube(S,i,1) for i in range(n))

def main() -> None:
    n = 3
    verts = [tuple(b) for b in product((0,1), repeat=n)]
    xs, ys = [], []
    for k in range(len(verts)+1):
        for combo in combinations(verts, k):
            S = frozenset(combo)
            xs.append(int(is_antipodal(S))); ys.append(int(iso(S, n)))
    fig, ax = plt.subplots(figsize=(5,5))
    ax.scatter([x+0.05*(i%7) for i,x in enumerate(xs)],
               [y+0.05*(i%7) for i,y in enumerate(ys)], alpha=0.3, s=10)
    ax.set_xticks([0,1]); ax.set_yticks([0,1])
    ax.set_xlabel("antipodal?"); ax.set_ylabel("opposite semicubes isometric?")
    ax.set_title("Every subset of Q_3 lies on the diagonal (biconditional holds)")
    plt.tight_layout(); plt.savefig("biconditional_scatter.png", dpi=140)
    print("saved biconditional_scatter.png")

if __name__ == "__main__":
    main()
