from __future__ import annotations


def subshell_size(l: int) -> int:
    """Magnetic substates m in {-l,...,l}: 2l+1."""
    return 2 * l + 1


def shell_degeneracy(n: int) -> int:
    """Total orbital states in shell n: sum_{l<n}(2l+1) = n^2."""
    total = sum(subshell_size(l) for l in range(n))
    assert total == n * n
    return total
