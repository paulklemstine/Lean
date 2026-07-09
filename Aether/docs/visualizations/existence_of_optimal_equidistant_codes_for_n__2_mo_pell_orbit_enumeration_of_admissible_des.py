from math import isqrt

def admissible_indices(U: int) -> list[int]:
    """All u in [0, U] with order u(3u+2) a perfect square, via the Pell step."""
    orbit: list[int] = [0]
    u, m = 2, 4                       # (3u+1)^2 - 3 m^2 = 1  at (u,m)=(2,4)
    while u <= U:
        orbit.append(u)
        u, m = 7 * u + 4 * m + 2, 12 * u + 7 * m + 4
    return orbit

def order(u: int) -> int:
    return u * (3 * u + 2)

if __name__ == "__main__":
    for u in admissible_indices(10 ** 6):
        r = isqrt(order(u))
        assert r * r == order(u)
        print(f"u={u:>10}  order={order(u):>16}  sqrt={r}")
