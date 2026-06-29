from __future__ import annotations


def compose_antilipschitz_constants(constants: list[float]) -> float:
    """AntilipschitzOnWith.comp: composite constant is the product of stage constants."""
    out = 1.0
    for k in constants:
        out *= k
    return out
