import matplotlib.pyplot as plt
from typing import Dict, List, Tuple


def main() -> None:
    n: int = 3
    fig, ax = plt.subplots(figsize=(9, 6))
    # positions: level by depth (y), horizontal spread by node index
    positions: Dict[Tuple[int, int], Tuple[float, float]] = {}
    for depth in range(n + 1):
        count: int = 2 ** depth
        for idx in range(count):
            x: float = (idx + 0.5) / count
            y: float = float(n - depth)
            positions[(depth, idx)] = (x, y)
    # draw edges with bit labels
    for depth in range(n):
        for idx in range(2 ** depth):
            x0, y0 = positions[(depth, idx)]
            for bit in (0, 1):
                child = 2 * idx + bit
                x1, y1 = positions[(depth + 1, child)]
                ax.plot([x0, x1], [y0, y1], "b-", lw=1)
                ax.text((x0 + x1) / 2, (y0 + y1) / 2, str(bit),
                        color="red", fontsize=9, ha="center")
    # draw nodes
    for (depth, idx), (x, y) in positions.items():
        leaf: bool = depth == n
        ax.scatter([x], [y], s=260,
                   color="seagreen" if leaf else "lightsteelblue",
                   edgecolor="black", zorder=3)
        if leaf:
            bits: str = format(idx, f"0{n}b")
            ax.text(x, y - 0.28, bits, ha="center", fontsize=8)
    ax.set_title("Adaptive decision tree (depth 3): 2^3 = 8 length-3 transcripts")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("decision_tree.png", dpi=150)
    print("wrote decision_tree.png")


if __name__ == "__main__":
    main()
