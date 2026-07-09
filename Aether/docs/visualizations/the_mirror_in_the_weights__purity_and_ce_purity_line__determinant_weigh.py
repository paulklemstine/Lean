"""Visualization: determinant weight vs c*n/2 across polarized families (purity line)."""
import matplotlib.pyplot as plt

def build_polarized(half, c, central):
    W = list(half) + [c - a for a in half]
    if central:
        W.append(c // 2)
    return W

if __name__ == "__main__":
    cs = list(range(0, 22, 2))
    dets, preds = [], []
    for c in cs:
        W = build_polarized([1, 4], c, central=True)  # n = 5
        dets.append(sum(W))
        preds.append(c * len(W) / 2)
    plt.figure(figsize=(6, 5))
    plt.plot(cs, preds, "-", color="crimson", label="c*n/2 (purity)")
    plt.plot(cs, dets, "o", color="steelblue", label="det(W)")
    plt.xlabel("similitude weight c")
    plt.ylabel("determinant weight")
    plt.title("Purity: det(W) sits exactly on c*n/2")
    plt.legend()
    plt.tight_layout()
    plt.savefig("purity.png", dpi=150)
    print("wrote purity.png")
