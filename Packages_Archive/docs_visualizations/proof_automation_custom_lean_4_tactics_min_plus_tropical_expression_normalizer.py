from typing import Sequence, Tuple

def scalar_foldr_min(c: float, terms: Sequence[float], init: float) -> bool:
    """Distributive scalar-fold lemma: c + min(a_i, init) == min(c + a_i, c + init)."""
    left = c + min(list(terms) + [init])
    right = min([c + a for a in terms] + [c + init])
    return abs(left - right) < 1e-12

def tropical_normal_form(terms: Sequence[float]) -> Tuple[float, ...]:
    """AC-normal form: value is independent of grouping/order of min."""
    return tuple(sorted(terms))

def main() -> None:
    print("scalar_foldr_min:", scalar_foldr_min(3.0, [7.0, 2.0, 5.0], 9.0))
    print("normal form:", tropical_normal_form([7, 2, 5, 9]))

if __name__ == "__main__":
    main()
