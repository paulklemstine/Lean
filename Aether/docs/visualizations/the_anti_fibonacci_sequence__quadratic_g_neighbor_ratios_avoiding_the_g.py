"""Visualization: consecutive ratios A(n+1)/A(n) decaying to 1, never to
the golden ratio -- the defining contrast with the Fibonacci sequence."""
import matplotlib.pyplot as plt

def anti_fib_closed(n: int) -> int:
    return 1 + n * (n - 1) // 2

golden = (1 + 5 ** 0.5) / 2
ns = list(range(1, 120))
ratios = [anti_fib_closed(n + 1) / anti_fib_closed(n) for n in ns]

plt.figure(figsize=(9, 5))
plt.plot(ns, ratios, marker=".", label="A(n+1)/A(n)")
plt.axhline(1.0, ls="--", color="green", label="limit 1")
plt.axhline(golden, ls=":", color="goldenrod", label=f"golden ratio {golden:.4f} (never reached)")
plt.title("Anti-Fibonacci neighbor ratios avoid the golden ratio")
plt.xlabel("n"); plt.ylabel("ratio"); plt.legend()
plt.tight_layout()
plt.savefig("anti_fib_ratio.png", dpi=130)
print("saved anti_fib_ratio.png")
