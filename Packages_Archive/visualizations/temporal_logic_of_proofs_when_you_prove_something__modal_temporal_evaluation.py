from typing import Callable, Dict, List, Set, Tuple

World = int
Relation = Set[Tuple[World, World]]
Pred = Callable[[World], bool]

def box(worlds: List[World], R: Relation, A: Pred) -> Pred:
    return lambda w: all(A(v) for v in worlds if (w, v) in R)

def glob(worlds: List[World], T: Relation, A: Pred) -> Pred:
    return lambda w: all(A(v) for v in worlds if (w, v) in T)

def fut(worlds: List[World], T: Relation, A: Pred) -> Pred:
    return lambda w: any(A(v) for v in worlds if (w, v) in T)

def evaluate(formula: tuple, worlds: List[World], R: Relation,
             T: Relation, valuation: Dict[str, Pred]) -> Pred:
    head = formula[0]
    if head == "atom":
        return valuation[formula[1]]
    if head == "not":
        inner = evaluate(formula[1], worlds, R, T, valuation)
        return lambda w: not inner(w)
    if head == "and":
        a = evaluate(formula[1], worlds, R, T, valuation)
        b = evaluate(formula[2], worlds, R, T, valuation)
        return lambda w: a(w) and b(w)
    if head == "box":
        return box(worlds, R, evaluate(formula[1], worlds, R, T, valuation))
    if head == "glob":
        return glob(worlds, T, evaluate(formula[1], worlds, R, T, valuation))
    if head == "fut":
        return fut(worlds, T, evaluate(formula[1], worlds, R, T, valuation))
    raise ValueError(f"unknown connective {head}")
