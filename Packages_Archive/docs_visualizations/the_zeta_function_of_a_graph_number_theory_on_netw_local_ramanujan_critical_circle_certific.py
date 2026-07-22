from __future__ import annotations
import cmath


def local_zeros(lam: float, q: float) -> tuple[complex, complex]:
    if q <= 0:
        raise ValueError("q must be positive")
    disc = cmath.sqrt(complex(lam * lam - 4.0 * q))
    return (lam + disc) / (2.0 * q), (lam - disc) / (2.0 * q)


def report(lam: float, q: float) -> None:
    radius = 1.0 / q**0.5
    print("Ramanujan bound:", lam * lam <= 4.0 * q)
    print("critical radius:", radius)
    for z in local_zeros(lam, q):
        print(z, "modulus =", abs(z))


if __name__ == "__main__":
    report(2.0, 2.0)
    report(3.0, 2.0)
