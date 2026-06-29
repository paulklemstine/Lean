from __future__ import annotations
from itertools import product
from typing import Dict, FrozenSet, List, Set
# (reuses LP, Form, eval_form, atoms_of, desig from the previous algorithms)


def entails_min(gamma: List[Form], a: Form) -> bool:
    """Minimally-inconsistent (LPm) consequence over a finite atom set.

    1. Enumerate all 3^k valuations of the occurring atoms.
    2. Keep the models M of gamma.
    3. For each model record its glut set {n : v[n] == bb}.
    4. Keep the SUBSET-minimal models M_min (no other model has a strictly
       smaller glut set).
    5. A is an LPm-consequence iff every model in M_min designates A.

    Minimality is a finite subset comparison, so entails_min is decidable.
    Complexity O(3^k * (|M| + |gamma| * formula_size)).
    """
    ids: List[int] = sorted(set().union(*[atoms_of(f) for f in gamma + [a]]))
    valuations: List[Dict[int, LP]] = [
        {i: val for i, val in zip(ids, combo)} for combo in product(LP, repeat=len(ids))
    ]
    models = [v for v in valuations if all(desig(eval_form(v, b)) for b in gamma)]
    glut_sets: List[FrozenSet[int]] = [
        frozenset(n for n in ids if v[n] == LP.bb) for v in models
    ]
    minimal = [
        v for v, g in zip(models, glut_sets)
        if not any(h < g for h in glut_sets)   # no strictly smaller glut set
    ]
    return all(desig(eval_form(v, a)) for v in minimal)
