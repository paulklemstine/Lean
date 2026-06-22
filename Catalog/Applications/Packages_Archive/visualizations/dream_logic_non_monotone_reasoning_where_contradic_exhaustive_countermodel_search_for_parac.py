from itertools import product
from typing import Callable, Dict, List, Optional, Tuple

Value = Tuple[int, int]
FOUR: List[Value] = [(1, 0), (0, 1), (1, 1), (0, 0)]
NAME: Dict[Value, str] = {(1, 0): "true", (0, 1): "false", (1, 1): "both", (0, 0): "neither"}


def designated(x: Value) -> bool:
    return x[0] == 1


def find_countermodel(
    variables: List[str],
    premises: List[Callable[[Dict[str, Value]], Value]],
    conclusion: Callable[[Dict[str, Value]], Value],
) -> Optional[Dict[str, str]]:
    """Brute-force search of all 4**n assignments for a countermodel.

    Returns an assignment making every premise designated and the conclusion
    undesignated (witnessing invalidity), or None if the entailment is valid.
    Complexity O(4**n * cost-of-formulas). For P, ~P |- Q this returns the
    explosion countermodel P=both, Q=false.
    """
    n = len(variables)
    for combo in product(FOUR, repeat=n):
        env = dict(zip(variables, combo))
        if all(designated(p(env)) for p in premises) and not designated(conclusion(env)):
            return {v: NAME[env[v]] for v in variables}
    return None
