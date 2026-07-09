"""Scatter of admissible {0,2,5}-triples over (base b, ratio a), colored by
whether the record coloring makes them monochromatic (none are)."""
import matplotlib.pyplot as plt

COL_VEC = [1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,2,0,1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,1,0,1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,0,0,1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,0,0]
N = 76

def visualize() -> None:
    xs, ys, mono = [], [], []
    a = 1
    while 1 + 5 * a <= N:
        b = 1
        while b + 5 * a <= N:
            xs.append(b); ys.append(a)
            cols = {COL_VEC[b - 1], COL_VEC[b + 2 * a - 1], COL_VEC[b + 5 * a - 1]}
            mono.append(len(cols) == 1)
            b += 1
        a += 1
    plt.figure(figsize=(10, 4))
    plt.scatter(xs, ys, c=["red" if m else "lightgray" for m in mono], s=12)
    plt.xlabel("base b"); plt.ylabel("ratio a")
    plt.title(f"All {len(xs)} admissible triples: red = monochromatic (none exist)")
    plt.tight_layout()
    plt.savefig("triples.png", dpi=150)
    print(f"wrote triples.png; monochromatic triples: {sum(mono)}")

if __name__ == "__main__":
    visualize()
