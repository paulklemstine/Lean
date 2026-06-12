import matplotlib.pyplot as plt
from typing import Callable, List

Compress = Callable[[int, int], int]

def states(f: Compress, iv: int, msg: List[int]) -> List[int]:
    seq = [iv]
    s = iv
    for b in msg:
        s = f(s, b)
        seq.append(s)
    return seq

def main() -> None:
    n = 3
    f: Compress = lambda a, b: (a * n + b) % 97   # mixing compression
    iv = 0
    m1 = [1, 2, 0, 2]
    m2 = [1, 2, 1, 2]
    s1, s2 = states(f, iv, m1), states(f, iv, m2)
    x = list(range(len(s1)))
    plt.figure(figsize=(8, 4))
    plt.plot(x, s1, "o-", label=f"message {m1}")
    plt.plot(x, s2, "s--", label=f"message {m2}")
    plt.xlabel("block index (conveyor station)")
    plt.ylabel("chaining state")
    plt.title("Merkle-Damgard chaining-state flow")
    plt.legend()
    plt.tight_layout()
    plt.savefig("conveyor_belt_state_flow.png", dpi=130)
    print("saved conveyor_belt_state_flow.png")

if __name__ == "__main__":
    main()
