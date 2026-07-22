from dataclasses import dataclass
from typing import Literal

@dataclass(frozen=True)
class Recipe:
    """A recipe modelled by cooking time C and verification time V."""
    cook: int
    verify: int

def classify_recipe(r: Recipe) -> Literal["quick", "traditional", "overhard"]:
    """Return the unique complexity class of a recipe by the trichotomy
    C == V (quick), V < C (traditional), C < V (overhard)."""
    if r.cook == r.verify:
        return "quick"
    if r.verify < r.cook:
        return "traditional"
    return "overhard"

def cooking_ratio(r: Recipe) -> float:
    """Dimensionless hardness index rho = C/V; 1 quick, >1 traditional, <1 overhard."""
    if r.verify == 0:
        return float("inf") if r.cook > 0 else 1.0
    return r.cook / r.verify
