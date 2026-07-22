from typing import List

def read_spectrum(energies: List[float]) -> float:
    d = len(energies)
    H = [[energies[i] if i == j else 0.0 for j in range(d)] for i in range(d)]
    assert all(H[i][j] == H[j][i] for i in range(d) for j in range(d))
    for j in range(d):
        e = [1.0 if i == j else 0.0 for i in range(d)]
        Hej = [sum(H[i][k] * e[k] for k in range(d)) for i in range(d)]
        assert Hej == [energies[j] * c for c in e]
    return sum(energies)
