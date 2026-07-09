import matplotlib.pyplot as plt
import numpy as np

def visualize_necklace_growth(max_a: int = 8, p: int = 5) -> None:
    a_vals = np.arange(1, max_a + 1)
    strings = a_vals ** p
    nonconst = a_vals ** p - a_vals
    necklaces = nonconst // p
    fig, ax = plt.subplots(figsize=(8, 5))
    w = 0.27
    ax.bar(a_vals - w, strings, w, label="a^5 (all strings)")
    ax.bar(a_vals, nonconst, w, label="a^5 - a (non-constant)")
    ax.bar(a_vals + w, necklaces, w, label="(a^5 - a)/5 (necklaces)")
    ax.set_xlabel("alphabet size a"); ax.set_ylabel("count")
    ax.set_yscale("log"); ax.legend()
    ax.set_title("Strings vs. non-constant strings vs. aperiodic necklaces")
    plt.tight_layout(); plt.savefig("necklace_growth.png", dpi=150)

if __name__ == "__main__":
    visualize_necklace_growth()
