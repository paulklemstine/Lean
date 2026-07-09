"""Visualize the squeeze (a,x] U [x,b) = (a,b) that powers the two-observer theorem."""
import matplotlib.pyplot as plt

def main() -> None:
    a, x, b = 0.0, 1.0, 2.5
    fig, ax = plt.subplots(figsize=(8, 2.5))
    ax.hlines(2, a, x, color="tab:blue", lw=6, label="backward observer (a, x]")
    ax.plot([x], [2], "o", color="tab:blue")           # closed at x
    ax.plot([a], [2], "o", mfc="white", color="tab:blue")  # open at a
    ax.hlines(1, x, b, color="tab:red", lw=6, label="forward observer [x, b)")
    ax.plot([x], [1], "o", color="tab:red")            # closed at x
    ax.plot([b], [1], "o", mfc="white", color="tab:red")   # open at b
    ax.hlines(0, a, b, color="black", lw=6, label="consensus (a, b)")
    ax.plot([a], [0], "o", mfc="white", color="black")
    ax.plot([b], [0], "o", mfc="white", color="black")
    ax.set_yticks([0, 1, 2]); ax.set_yticklabels(["consensus", "forward", "backward"])
    ax.set_title("(a, x] U [x, b) = (a, b): reality is the handshake of two half-visions")
    ax.legend(loc="upper right"); ax.set_xlim(a - 0.3, b + 0.3)
    plt.tight_layout(); plt.savefig("squeeze.png", dpi=150)

if __name__ == "__main__":
    main()
