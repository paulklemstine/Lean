"""Visualize term-by-term telescoping: plot the partial products of the
Beta-moment product against the constant endpoint value they converge to at the
final index (they coincide exactly once the full chain is multiplied)."""
import math
import matplotlib.pyplot as plt


def beta_moment(a, b, p):
    return (math.gamma(a + p) * math.gamma(a + b)) / (
        math.gamma(a) * math.gamma(a + b + p))


def main():
    a0, betas, p = 1.3, [0.7, 1.1, 0.5, 0.9, 1.4], 2.0
    alpha = [a0]
    for b in betas:
        alpha.append(alpha[-1] + b)
    partial, running = [], 1.0
    for j, b in enumerate(betas):
        running *= beta_moment(alpha[j], b, p)
        partial.append(running)
    an = alpha[-1]
    endpoint = (math.gamma(a0 + p) * math.gamma(an)) / (
        math.gamma(a0) * math.gamma(an + p))
    plt.figure(figsize=(7, 4))
    plt.plot(range(1, len(partial) + 1), partial, "o-", label="partial product")
    plt.axhline(endpoint, color="crimson", ls="--", label="endpoint formula")
    plt.xlabel("number of factors included")
    plt.ylabel(f"p-th moment (p={p})")
    plt.title("Telescoping of a chained Beta-moment product")
    plt.legend(); plt.tight_layout(); plt.savefig("telescoping.png", dpi=150)


if __name__ == "__main__":
    main()
