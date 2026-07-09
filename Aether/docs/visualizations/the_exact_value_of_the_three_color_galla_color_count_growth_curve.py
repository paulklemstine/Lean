"""Log-scale plot of super-multiplicative lower bounds for G_r({0,2,5})."""
import matplotlib.pyplot as plt

def bounds(g3: int = 77, upto: int = 15):
    lb = {3: g3}
    for r in range(6, upto + 1, 3):
        lb[r] = (lb[3] - 1) * (lb[r - 3] - 1) + 1
    return lb

def visualize() -> None:
    lb = bounds()
    rs = sorted(lb)
    plt.figure(figsize=(8, 5))
    plt.semilogy(rs, [lb[r] for r in rs], "o-")
    plt.xlabel("number of colors r"); plt.ylabel("lower bound for G_r({0,2,5})")
    plt.title("Super-multiplicative growth from the anchor G_3 = 77")
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("growth.png", dpi=150)
    print("wrote growth.png")

if __name__ == "__main__":
    visualize()
