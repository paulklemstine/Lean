"""Visualize the universal height-leaf sandwich band for random trees."""
import random
import matplotlib.pyplot as plt
from math import ceil, log2
from dataclasses import dataclass
from typing import Union


@dataclass
class Leaf:
    value: int


@dataclass
class Node:
    left: "OpTree"
    right: "OpTree"


OpTree = Union[Leaf, Node]


def random_tree(m: int) -> OpTree:
    if m <= 1:
        return Leaf(0)
    split = random.randint(1, m - 1)
    return Node(random_tree(split), random_tree(m - split))


def height(t: OpTree) -> int:
    return 0 if isinstance(t, Leaf) else max(height(t.left), height(t.right)) + 1


def num_leaves(t: OpTree) -> int:
    return 1 if isinstance(t, Leaf) else num_leaves(t.left) + num_leaves(t.right)


ms = list(range(1, 40))
lows = [0 if m <= 1 else ceil(log2(m)) for m in ms]
highs = [m - 1 for m in ms]
samples_x, samples_y = [], []
for m in ms:
    for _ in range(8):
        t = random_tree(m)
        samples_x.append(m)
        samples_y.append(height(t))

fig, ax = plt.subplots(figsize=(8, 5))
ax.fill_between(ms, lows, highs, alpha=0.2, label="allowed band [ceil log2 m, m-1]")
ax.plot(ms, lows, "-", label="floor: balanced")
ax.plot(ms, highs, "-", label="ceiling: caterpillar")
ax.scatter(samples_x, samples_y, s=10, alpha=0.5, label="random trees")
ax.set_xlabel("number of leaves m")
ax.set_ylabel("height")
ax.set_title("Every tree's height lies in the universal sandwich")
ax.legend()
fig.tight_layout()
fig.savefig("height_sandwich.png", dpi=150)
print("wrote height_sandwich.png")
