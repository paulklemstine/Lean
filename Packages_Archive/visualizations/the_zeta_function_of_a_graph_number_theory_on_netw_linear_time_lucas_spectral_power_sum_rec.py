from __future__ import annotations


def spectral_power_sums(lam: int, q: int, count: int) -> list[int]:
    if count < 0:
        raise ValueError("count must be nonnegative")
    if count == 0:
        return []
    values = [2]
    if count > 1:
        values.append(lam)
    while len(values) < count:
        values.append(lam * values[-1] - q * values[-2])
    return values


if __name__ == "__main__":
    print(spectral_power_sums(2, 2, 8))
