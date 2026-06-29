"""Visualize winding numbers as points spiraling around the circle.
Requires matplotlib. Saves winding.png."""
import math
import matplotlib.pyplot as plt
from typing import List

def winding_number(word: List[bool]) -> int:
    acc = 0
    for b in word:
        acc = acc + 1 if b else acc - 1
    return acc

def trajectory(word: List[bool]):
    angle = 0.0
    xs, ys = [1.0], [0.0]
    for i, b in enumerate(word):
        angle += (1 if b else -1) * (2 * math.pi / 6)
        r = 1.0 + 0.06 * (i + 1)
        xs.append(r * math.cos(angle)); ys.append(r * math.sin(angle))
    return xs, ys

if __name__ == "__main__":
    word = [True, True, True, True, True, True, True, False, True]
    xs, ys = trajectory(word)
    fig, ax = plt.subplots(figsize=(6, 6))
    th = [i * 2 * math.pi / 200 for i in range(201)]
    ax.plot([math.cos(t) for t in th], [math.sin(t) for t in th], "k--", alpha=0.3)
    ax.plot(xs, ys, "-o", lw=2)
    ax.set_aspect("equal")
    ax.set_title(f"Loop trajectory on S^1, winding number = {winding_number(word)}")
    plt.savefig("winding.png", dpi=140)
    print("saved winding.png")
