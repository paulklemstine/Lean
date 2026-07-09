from __future__ import annotations


def bohr_energy(n: int) -> float:
    """Bohr energy E_n = -1/n^2 in Rydberg units."""
    return -1.0 / (n * n)


def rydberg_lines(n_max: int) -> dict[int, list[tuple[int, int, float]]]:
    """All emission lines n->m (m<n) up to n_max, grouped by lower level m."""
    series: dict[int, list[tuple[int, int, float]]] = {}
    for m in range(1, n_max):
        limit = 1.0 / (m * m)
        rows: list[tuple[int, int, float]] = []
        for n in range(m + 1, n_max + 1):
            dE = 1.0 / (m * m) - 1.0 / (n * n)
            assert 0.0 < dE < limit
            rows.append((n, m, dE))
        series[m] = rows
    return series
