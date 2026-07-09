import matplotlib.pyplot as plt
from math import factorial

def fix_size(t: int, n: int) -> int:
    return factorial(n - t) if n >= t else 0

if __name__ == "__main__":
    ns = list(range(1, 9))
    plt.figure(figsize=(7, 5))
    for t in [1, 2, 3]:
        ys = [fix_size(t, n) for n in ns if n >= t]
        xs = [n for n in ns if n >= t]
        plt.plot(xs, ys, marker="o", label=f"|Fix_t|, t={t}  =  (n-{t})!")
    plt.yscale("log")
    plt.xlabel("n (number of points)")
    plt.ylabel("family size (log scale)")
    plt.title("Extremal t-intersecting family size = (n-t)!")
    plt.legend()
    plt.grid(True, which="both", ls=":")
    plt.tight_layout()
    plt.savefig("prefix_stabilizer_sizes.png", dpi=150)
    print("Saved prefix_stabilizer_sizes.png")
