import matplotlib.pyplot as plt
import numpy as np

def plot_residue_obstruction() -> None:
    """Bar chart of which residues mod 9 are attainable as sums of three cubes."""
    cube_res = {(x ** 3) % 9 for x in range(9)}
    attainable = {(a + b + c) % 9 for a in cube_res for b in cube_res for c in cube_res}
    residues = list(range(9))
    colors = ["#2ca02c" if r in attainable else "#d62728" for r in residues]
    plt.figure(figsize=(8, 4))
    plt.bar(residues, [1] * 9, color=colors, edgecolor="black")
    plt.xticks(residues)
    plt.yticks([])
    plt.title("Residues mod 9: green = attainable, red = obstructed (4 and 5)")
    plt.xlabel("n mod 9")
    for r in residues:
        plt.text(r, 0.5, "yes" if r in attainable else "NO",
                 ha="center", va="center", color="white", fontweight="bold")
    plt.tight_layout()
    plt.savefig("residue_obstruction.png", dpi=150)
    print("Saved residue_obstruction.png")

if __name__ == "__main__":
    plot_residue_obstruction()
