"""
Numerical demonstrations of the transform uncertainty principle.

The uncertainty principle -- Delta(x) * Delta(k) >= 1/(4*pi) for a signal and its
Fourier transform -- is not a law of physics but a theorem about integral
transforms whose image is holomorphic.  This script demonstrates several
consequences numerically:

  1. The quantitative Heisenberg bound and the Gaussian as its equality case.
  2. The time-frequency trade-off: narrowing a signal broadens its transform.
  3. The infinite-support / null-zero-set behaviour of entire functions
     (sine, cosine) versus the nowhere-vanishing Gaussian.
  4. The discrete Donoho-Stark inequality |supp f| * |supp Fhat| >= N.

Only numpy is required.
"""

from __future__ import annotations

import numpy as np


# ---------------------------------------------------------------------------
# 1. Quantitative uncertainty: Delta(x) * Delta(k) >= 1/(4*pi)
# ---------------------------------------------------------------------------
def spreads(signal: np.ndarray, dt: float) -> tuple[float, float]:
    """Return (Delta_x, Delta_k), the RMS spreads of a signal and its FFT.

    The signal is normalised so that the discrete integral of |f|^2 is 1, then
    second central moments are taken in both the time and (ordinary) frequency
    domains.  The product is bounded below by 1/(4*pi).
    """
    n = signal.size
    t = (np.arange(n) - n / 2) * dt

    power = np.abs(signal) ** 2
    power = power / (power.sum() * dt)
    mu_t = np.sum(t * power) * dt
    var_x = np.sum((t - mu_t) ** 2 * power) * dt

    fhat = np.fft.fftshift(np.fft.fft(np.fft.ifftshift(signal))) * dt
    # ordinary frequency k (cycles per unit), not angular frequency
    k = np.fft.fftshift(np.fft.fftfreq(n, d=dt))
    pk = np.abs(fhat) ** 2
    pk = pk / (pk.sum() * (k[1] - k[0]))
    mu_k = np.sum(k * pk) * (k[1] - k[0])
    var_k = np.sum((k - mu_k) ** 2 * pk) * (k[1] - k[0])

    return float(np.sqrt(var_x)), float(np.sqrt(var_k))


def demo_heisenberg_bound() -> None:
    print("=" * 70)
    print("1. Quantitative uncertainty  Delta(x) * Delta(k) >= 1/(4*pi)")
    print("=" * 70)
    bound = 1.0 / (4.0 * np.pi)
    n = 4096
    dt = 0.01
    t = (np.arange(n) - n / 2) * dt
    print(f"Theoretical lower bound 1/(4*pi) = {bound:.6f}\n")
    print(f"{'signal':<28}{'Delta_x':>10}{'Delta_k':>10}{'product':>12}")
    for width in (0.5, 1.0, 2.0, 4.0):
        g = np.exp(-t ** 2 / (2 * width ** 2))
        dx, dk = spreads(g, dt)
        print(f"{'Gaussian sigma=' + str(width):<28}{dx:>10.4f}{dk:>10.4f}{dx * dk:>12.6f}")
    print("\nAll Gaussians saturate the bound (product ~ 1/(4*pi)); the Gaussian")
    print("is the extremal object of the uncertainty principle.\n")


# ---------------------------------------------------------------------------
# 2. Time-frequency trade-off for the box / sinc pair
# ---------------------------------------------------------------------------
def demo_box_sinc_tradeoff() -> None:
    print("=" * 70)
    print("2. Time-frequency trade-off: box_w  <->  w * sinc(w k)")
    print("=" * 70)
    print("A box of width w has Fourier transform w*sinc(w*k); the narrower the")
    print("box in time, the wider its transform in frequency.\n")
    print(f"{'box width w':>14}{'effective transform support':>32}")

    k = np.linspace(-200, 200, 400001)
    tau = 0.05  # threshold relative to peak
    for w in (4.0, 2.0, 1.0, 0.5, 0.25):
        # transform of indicator[-w/2, w/2] is w * sinc(w*k) = sin(pi w k)/(pi k)
        with np.errstate(divide="ignore", invalid="ignore"):
            trans = np.where(k == 0, w, np.sin(np.pi * w * k) / (np.pi * k))
        peak = np.abs(trans).max()
        eff = np.sum(np.abs(trans) > tau * peak) * (k[1] - k[0])
        print(f"{w:>14.3f}{eff:>32.2f}")
    print("\nEffective transform support grows without bound as w -> 0: a signal")
    print("of finite support cannot have a transform of finite support.\n")


# ---------------------------------------------------------------------------
# 3. Entire functions: null zero set, infinite support, Gaussian nowhere zero
# ---------------------------------------------------------------------------
def demo_entire_zero_sets() -> None:
    print("=" * 70)
    print("3. Zero sets of entire functions on a complex grid")
    print("=" * 70)
    re = np.linspace(-10, 10, 2001)
    im = np.linspace(-10, 10, 2001)
    X, Y = np.meshgrid(re, im)
    Zc = X + 1j * Y
    cell = (re[1] - re[0]) * (im[1] - im[0])
    area = (re[-1] - re[0]) * (im[-1] - im[0])

    eps = 1e-3
    for name, f in (
        ("sin(z)", np.sin),
        ("cos(z)", np.cos),
        ("exp(-z^2) (Gaussian)", lambda z: np.exp(-z ** 2)),
    ):
        vals = f(Zc)
        exact_zero_area = np.sum(vals == 0) * cell
        small_area = np.sum(np.abs(vals) < eps) * cell
        print(f"{name:<24} |exact-zero area|={exact_zero_area:7.3f}   "
              f"|value<{eps} area|={small_area:8.3f}  (box area={area:.1f})")
    print("\nNone of these entire functions vanish on a set of positive area:")
    print("sin, cos vanish only at isolated points; the Gaussian never vanishes")
    print("at all (its 'small-value' region is rapid decay off the real axis,")
    print("not true zeros). Every nonzero entire function has a null zero set.\n")


# ---------------------------------------------------------------------------
# 4. Discrete Donoho-Stark uncertainty: |supp f| * |supp Fhat| >= N
# ---------------------------------------------------------------------------
def demo_donoho_stark() -> None:
    print("=" * 70)
    print("4. Discrete uncertainty (Donoho-Stark):  |supp f| * |supp Fhat| >= N")
    print("=" * 70)
    n = 60
    print(f"N = {n}\n")
    print(f"{'signal':<26}{'|supp f|':>10}{'|supp Fhat|':>14}{'product':>10}{'>=N?':>7}")
    rng = np.random.default_rng(0)

    def report(name: str, f: np.ndarray) -> None:
        fh = np.fft.fft(f)
        sf = int(np.sum(np.abs(f) > 1e-9))
        sh = int(np.sum(np.abs(fh) > 1e-9))
        prod = sf * sh
        print(f"{name:<26}{sf:>10}{sh:>14}{prod:>10}{'yes' if prod >= n else 'NO':>7}")

    # a single spike -> full spectrum
    delta = np.zeros(n, dtype=complex)
    delta[0] = 1.0
    report("delta (spike)", delta)

    # a Dirac comb of period sqrt(N)-ish divisor -> comb (equality case)
    comb = np.zeros(n, dtype=complex)
    comb[::6] = 1.0  # period 6 divides 60, spectrum is a comb of period 10
    report("Dirac comb (period 6)", comb)

    # a random sparse signal
    sparse = np.zeros(n, dtype=complex)
    idx = rng.choice(n, size=5, replace=False)
    sparse[idx] = rng.standard_normal(5)
    report("random 5-sparse", sparse)
    print("\nThe product of the two support sizes never drops below N.\n")


def main() -> None:
    demo_heisenberg_bound()
    demo_box_sinc_tradeoff()
    demo_entire_zero_sets()
    demo_donoho_stark()
    print("=" * 70)
    print("Conclusion: every invertible integral transform with a holomorphic")
    print("image carries its own uncertainty principle -- all instances of the")
    print("rigidity of analytic functions.")
    print("=" * 70)


if __name__ == "__main__":
    main()
