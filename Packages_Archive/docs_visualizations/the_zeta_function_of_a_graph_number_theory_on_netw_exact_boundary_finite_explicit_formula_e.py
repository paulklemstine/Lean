from __future__ import annotations


def sums(lam: complex, q: complex, count: int) -> list[complex]:
    out = [2 + 0j, lam]
    while len(out) < count:
        out.append(lam * out[-1] - q * out[-2])
    return out[:count]


def residual(lam: complex, q: complex, n: int, u: complex) -> complex:
    s = sums(lam, q, n + 3)
    truncated = sum(s[k + 1] * u**k for k in range(n + 1))
    left = (1 - lam * u + q * u**2) * truncated
    right = lam - 2*q*u - s[n + 2]*u**(n + 1) + q*s[n + 1]*u**(n + 2)
    return left - right


if __name__ == "__main__":
    for n in range(8):
        print(n, abs(residual(2, 2, n, 0.1 + 0.2j)))
