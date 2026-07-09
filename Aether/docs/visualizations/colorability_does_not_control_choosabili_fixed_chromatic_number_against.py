"""Visualization: chromatic number stays 2 while non-k-choosability grows."""
import matplotlib.pyplot as plt

def main() -> None:
    ks = [1, 2, 3, 4]
    chromatic = [2, 2, 2, 2]
    sizes = [k ** k for k in ks]  # large-side size of the witness K_{k,k^k}
    fig, ax1 = plt.subplots(figsize=(7, 5))
    ax1.bar([k - 0.15 for k in ks], chromatic, width=0.3,
            color="#55A868", label="chromatic number")
    ax1.set_xlabel("k")
    ax1.set_ylabel("chromatic number", color="#55A868")
    ax1.set_ylim(0, 6)
    ax2 = ax1.twinx()
    ax2.plot(ks, sizes, "o-", color="#C44E52", label="large side k^k of witness")
    ax2.set_ylabel("k^k (witness large-side size)", color="#C44E52")
    ax1.set_title("K_{k,k^k}: chromatic number fixed at 2, witness grows as k^k")
    plt.tight_layout()
    plt.savefig("gap_growth.png", dpi=150)
    print("wrote gap_growth.png")

if __name__ == "__main__":
    main()
