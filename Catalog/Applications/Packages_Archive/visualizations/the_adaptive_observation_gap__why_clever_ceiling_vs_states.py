import matplotlib.pyplot as plt
from typing import List


def main() -> None:
    max_states: int = 64
    states: List[int] = list(range(1, max_states + 1))
    fig, ax = plt.subplots(figsize=(8, 5))
    for n in [2, 3, 4, 5]:
        ceiling: int = 2 ** n
        # distinguishable classes = min(#states, 2**n)
        classes: List[int] = [min(m, ceiling) for m in states]
        ax.plot(states, classes, label=f"n = {n}  (ceiling 2^n = {ceiling})")
        ax.axhline(ceiling, color="gray", ls=":", lw=0.8)
    ax.plot(states, states, "k--", lw=1, label="perfect separation (y = x)")
    ax.set_xlabel("number of states |alpha|")
    ax.set_ylabel("max distinguishable classes")
    ax.set_title("The Observation Gap: distinguishable classes saturate at 2^n")
    ax.legend()
    fig.tight_layout()
    fig.savefig("observation_ceiling.png", dpi=150)
    print("wrote observation_ceiling.png")


if __name__ == "__main__":
    main()
