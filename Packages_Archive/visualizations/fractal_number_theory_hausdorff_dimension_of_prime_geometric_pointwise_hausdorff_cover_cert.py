from __future__ import annotations

def covering_certificate(n: int, s: float, delta: float) -> tuple[list[float], float]:
    if n < 0 or s <= 0 or delta <= 0:
        raise ValueError("require n >= 0, s > 0, delta > 0")
    diameters = [delta * 2.0 ** (-(k + 1) / s) for k in range(n)]
    return diameters, sum(d ** s for d in diameters)

if __name__ == "__main__":
    for s in (0.5, 1.0, 2.0):
        _, cost = covering_certificate(1000, s, 1e-4)
        print(f"s={s}: total cost={cost:.8g}")
