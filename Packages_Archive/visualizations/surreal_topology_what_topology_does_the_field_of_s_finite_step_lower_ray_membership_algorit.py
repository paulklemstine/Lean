from __future__ import annotations

def in_truncated_ray(z: float, x: float, epsilon: float, cutoff: int) -> bool:
    return any(z < x + n * epsilon for n in range(cutoff + 1))

if __name__ == "__main__":
    x, y, cutoff = 2.0, 5.0, 10
    epsilon = (y-x)/(cutoff+1)
    for z in (1.5, x, 3.0, y, 5.5): print(z, in_truncated_ray(z,x,epsilon,cutoff))
