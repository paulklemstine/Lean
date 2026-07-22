from __future__ import annotations

def cutoff_indices(N: int) -> list[int]:
    if N < 0:
        raise ValueError("N must be nonnegative")
    return list(range(-N, N + 1))

for N in range(6):
    indices = cutoff_indices(N)
    assert len(indices) == 2*N + 1
    print(f"N={N}: {len(indices)} points, indices={indices}")
