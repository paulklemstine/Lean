"""Bar chart of Monte-Carlo cell mass estimates against the exact value 1/4."""
import random
import matplotlib.pyplot as plt
from typing import Dict


def estimate(samples: int = 300000, seed: int = 0) -> Dict[str, float]:
    rng = random.Random(seed)
    c = {"D1": 0, "D2": 0, "D3": 0, "D4": 0}
    for _ in range(samples):
        x, y = rng.random(), rng.random()
        if x < 0.5 and y < 0.5: c["D1"] += 1
        elif x < 0.5:           c["D2"] += 1
        elif y >= 0.5:          c["D3"] += 1
        else:                   c["D4"] += 1
    return {k: v / samples for k, v in c.items()}


def draw() -> None:
    m = estimate()
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.bar(list(m), list(m.values()), color="#219ebc")
    ax.axhline(0.25, color="red", ls="--", label="exact 1/4")
    ax.set_ylabel("estimated Lebesgue measure"); ax.legend()
    ax.set_title("Equal-mass decomposition of the natural extension")
    plt.savefig("masses.png", dpi=150, bbox_inches="tight")


if __name__ == "__main__":
    draw()
