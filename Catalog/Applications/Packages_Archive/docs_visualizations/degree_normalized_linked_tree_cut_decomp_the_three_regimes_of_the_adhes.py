import matplotlib.pyplot as plt

def plot_adhesion_dichotomy() -> None:
    """Plot the three adhesion-sequence regimes of the monotone dichotomy."""
    stab = [7, 6, 5, 4, 3, 2, 2, 2, 2, 2]        # finite degree d=2
    div  = [1, 1, 2, 3, 5, 8, 13, 21, 34]         # infinite degree
    osc  = [2 + (n % 2) for n in range(10)]        # un-linked counterexample
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(range(len(stab)), stab, "o-", label="finite degree -> stabilizes at d=2")
    ax.plot(range(len(div)), div, "s-", label="infinite degree -> diverges")
    ax.plot(range(len(osc)), osc, "^--", label="un-linked -> oscillates (a_n=d+n%2)")
    ax.axhline(2, color="grey", ls=":", lw=1)
    ax.set_xlabel("n  (depth along displaying ray)")
    ax.set_ylabel("adhesion  |F_{e_n}|")
    ax.set_title("Degree-normalization: the monotone dichotomy of adhesion sequences")
    ax.legend(); ax.grid(alpha=0.3)
    plt.tight_layout(); plt.savefig("adhesion_dichotomy.png", dpi=150)
    print("wrote adhesion_dichotomy.png")

if __name__ == "__main__":
    plot_adhesion_dichotomy()
