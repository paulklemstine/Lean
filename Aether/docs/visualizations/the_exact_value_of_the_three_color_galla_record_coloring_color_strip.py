"""Render the record 76-coloring as a color grid (matplotlib)."""
import matplotlib.pyplot as plt
import numpy as np

COL_VEC = [1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,2,0,1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,1,0,1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,0,0,1,0,2,0,1,1,1,0,0,2,0,1,2,2,1,2,2,0,0]

def visualize() -> None:
    data = np.array(COL_VEC).reshape(1, -1)
    fig, ax = plt.subplots(figsize=(14, 2))
    ax.imshow(data, aspect="auto", cmap="viridis")
    ax.set_yticks([])
    ax.set_xticks(range(0, 76, 5))
    ax.set_xticklabels(range(1, 77, 5))
    ax.set_title("Record copy-free 3-coloring of {1,...,76} for pattern {0,2,5}")
    plt.tight_layout()
    plt.savefig("record_coloring.png", dpi=150)
    print("wrote record_coloring.png")

if __name__ == "__main__":
    visualize()
