from dataclasses import dataclass

@dataclass(frozen=True)
class Recipe:
    cook: int
    verify: int

def repeat_recipe(n: int, r: Recipe) -> Recipe:
    """Cook n servings in sequence. Both times scale linearly:
    C(R^n) = n*C(R), V(R^n) = n*V(R); the complexity class is preserved for n>=1."""
    assert n >= 0
    return Recipe(cook=n * r.cook, verify=n * r.verify)
