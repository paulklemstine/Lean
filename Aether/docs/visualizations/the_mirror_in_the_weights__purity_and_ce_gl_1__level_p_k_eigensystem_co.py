"""Visualization: GL(1) level-p^k eigensystem counts phi(p^k) = p^{k-1}(p-1)."""
import matplotlib.pyplot as plt

def phi_pk(p, k):
    return p ** (k - 1) * (p - 1)

if __name__ == "__main__":
    ks = list(range(1, 6))
    plt.figure(figsize=(6, 5))
    for p in (2, 3, 5, 7):
        plt.plot(ks, [phi_pk(p, k) for k in ks], "o-", label=f"p={p}")
    plt.yscale("log")
    plt.xlabel("exponent k")
    plt.ylabel("number of level-p^k eigensystems (log)")
    plt.title("Maximal torsion eigensystem counts for GL(1)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("counts.png", dpi=150)
    print("wrote counts.png")
