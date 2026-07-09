"""Bar chart of the head surcharge s(n) = a(n) - 2^n."""
import matplotlib.pyplot as plt

HEAD = {1: 6, 2: 8, 3: 12, 4: 24, 5: 40, 6: 80}


def good_count(n: int) -> int:
    return HEAD.get(n, 2 ** n)


def main() -> None:
    ns = list(range(1, 10))
    s = [good_count(n) - 2 ** n for n in ns]
    plt.figure(figsize=(8, 5))
    bars = plt.bar(ns, s, color=["crimson" if v else "seagreen" for v in s])
    plt.xlabel("n"); plt.ylabel("surcharge s(n) = a(n) - 2^n")
    plt.title("Surcharge: positive on the head, zero on the tail")
    for b, v in zip(bars, s):
        plt.text(b.get_x() + b.get_width() / 2, v + 0.2, str(v), ha="center")
    plt.tight_layout(); plt.savefig("surcharge.png", dpi=150)
    print("saved surcharge.png")


if __name__ == "__main__":
    main()
