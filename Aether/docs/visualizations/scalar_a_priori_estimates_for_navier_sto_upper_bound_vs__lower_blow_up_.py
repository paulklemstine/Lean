"""Visualize the 3D supercritical upper envelope and the lower blow-up rate.

Requires matplotlib. Saves navier_stokes_blowup.png."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt


def main() -> None:
    C: float = 0.05
    Z0: float = 2.0
    Tstar: float = 1.0 / (2.0 * C * Z0 ** 2)
    ts = [Tstar * k / 1000.0 for k in range(1, 999)]
    # Exact solution Z(t)^2 = 1/(2C(T*-t)) of Z' = C Z^3 (equality case).
    exact = [1.0 / (2.0 * C * (Tstar - t)) for t in ts]
    upper = [Z0 ** 2 / (1.0 - 2.0 * C * Z0 ** 2 * t) for t in ts]
    lower = [1.0 / (2.0 * C * (Tstar - t)) for t in ts]
    plt.figure(figsize=(8, 5))
    plt.plot(ts, exact, "k-", lw=2, label="exact Z(t)^2 (Z'=C Z^3)")
    plt.plot(ts, upper, "b--", label="upper a priori bound")
    plt.plot(ts, lower, "r:", label="lower blow-up rate 1/(2C(T*-t))")
    plt.axvline(Tstar, color="gray", ls="-.", label=f"T* = {Tstar:.2f}")
    plt.yscale("log")
    plt.xlabel("time t")
    plt.ylabel("enstrophy squared  Z(t)^2  (log scale)")
    plt.title("3D supercritical enstrophy: upper bound and lower blow-up rate")
    plt.legend()
    plt.tight_layout()
    plt.savefig("navier_stokes_blowup.png", dpi=150)
    print("saved navier_stokes_blowup.png")


if __name__ == "__main__":
    main()
