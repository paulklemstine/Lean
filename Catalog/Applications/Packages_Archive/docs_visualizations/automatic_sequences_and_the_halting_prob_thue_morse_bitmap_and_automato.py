"""Visualize the Thue-Morse sequence as a self-similar bitmap and its
running-parity automaton trajectory. Requires matplotlib."""
from typing import List
import matplotlib.pyplot as plt

def thue_morse_bits(n: int) -> List[int]:
    return [bin(i).count("1") & 1 for i in range(n)]

def main() -> None:
    n = 256
    bits = thue_morse_bits(n)
    side = 16
    grid = [[bits[r * side + c] for c in range(side)] for r in range(side)]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 5))
    ax1.imshow(grid, cmap="binary", interpolation="nearest")
    ax1.set_title("Thue-Morse t(n) as a 16x16 bitmap")
    ax1.set_xticks([]); ax1.set_yticks([])

    ax2.step(range(64), bits[:64], where="mid")
    ax2.set_title("Thue-Morse t(n), n = 0..63 (DFAO parity output)")
    ax2.set_xlabel("n"); ax2.set_ylabel("t(n)")
    ax2.set_ylim(-0.2, 1.2)

    fig.tight_layout()
    fig.savefig("thue_morse.png", dpi=120)
    print("wrote thue_morse.png")

if __name__ == "__main__":
    main()
