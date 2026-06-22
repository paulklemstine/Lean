from itertools import product
from typing import Dict

FF, BB, TT = 0, 1, 2


def collapse_plus(val: Dict[int, int]) -> Dict[int, int]:
    """The asymmetric classical collapse v+ : bb |-> tt, fixing ff and tt.

    This is the constructive core of Priest's characterization. The Collapsing Lemma
    states: for every formula A,
        eval(v+, A) = tt  =>  eval(v, A) is designated, and
        eval(v+, A) = ff  =>  eval(v, A) = ff.
    Because v+ is classical, a classically valid A forces eval(v+, A) = tt for every
    v, whence eval(v, A) is designated -- i.e. A is LP-valid.
    """
    return {n: (TT if x in (BB, TT) else FF) for n, x in val.items()}


def is_classically_valid(a: dict, evaluate, atoms_of) -> bool:
    """Validity over glut-free (two-valued) valuations only. Theta(2^k * |A|)."""
    atoms = sorted(atoms_of(a))
    for assign in product((FF, TT), repeat=len(atoms)):
        val = dict(zip(atoms, assign))
        if evaluate(val, a) < BB:
            return False
    return True
