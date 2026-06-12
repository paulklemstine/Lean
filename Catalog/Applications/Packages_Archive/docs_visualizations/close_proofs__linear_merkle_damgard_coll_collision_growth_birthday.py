import matplotlib.pyplot as plt
from itertools import product
from typing import Callable, Dict, List

Compress = Callable[[int, int], int]

def merkle_damgard(f: Compress, iv: int, msg: List[int]) -> int:
    s = iv
    for b in msg:
        s = f(s, b)
    return s

def distinct_digests(f: Compress, blocks: List[int], length: int) -> int:
    seen: Dict[int, bool] = {}
    for combo in product(blocks, repeat=length):
        seen[merkle_damgard(f, 0, list(combo))] = True
    return len(seen)

def main() -> None:
    blocks = [0, 1, 2, 3]
    lengths = [1, 2, 3, 4, 5]
    inj: Compress = lambda a, b: a * 4 + b           # injective
    lossy: Compress = lambda a, b: (a + b) % 8       # lossy
    total = [len(blocks) ** L for L in lengths]
    di = [distinct_digests(inj, blocks, L) for L in lengths]
    dl = [distinct_digests(lossy, blocks, L) for L in lengths]
    plt.figure(figsize=(8, 4))
    plt.plot(lengths, [a / b for a, b in zip(di, total)], "o-",
             label="injective f (no collisions)")
    plt.plot(lengths, [a / b for a, b in zip(dl, total)], "s--",
             label="lossy f (collisions)")
    plt.xlabel("message length (blocks)")
    plt.ylabel("distinct digests / total messages")
    plt.title("Collision-freeness vs. compression injectivity")
    plt.ylim(0, 1.05)
    plt.legend()
    plt.tight_layout()
    plt.savefig("collision_growth_birthday.png", dpi=130)
    print("saved collision_growth_birthday.png")

if __name__ == "__main__":
    main()
