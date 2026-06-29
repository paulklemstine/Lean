from typing import Dict, List, Tuple

Value = Tuple[int, int]  # (t, f): t = asserted-true bit, f = asserted-false bit
TRUE: Value = (1, 0)
FALSE: Value = (0, 1)
BOTH: Value = (1, 1)
NEITHER: Value = (0, 0)
NAME: Dict[Value, str] = {TRUE: "true", FALSE: "false", BOTH: "both", NEITHER: "neither"}


def neg(x: Value) -> Value:
    """Belnap negation: swap evidence bits (fixes both/neither, swaps true/false)."""
    return (x[1], x[0])


def conj(x: Value, y: Value) -> Value:
    """Truth-order meet: AND the truth bits, OR the falsity bits."""
    return (x[0] & y[0], x[1] | y[1])


def disj(x: Value, y: Value) -> Value:
    """Truth-order join: OR the truth bits, AND the falsity bits."""
    return (x[0] | y[0], x[1] & y[1])


def designated(x: Value) -> bool:
    """Asserted/believed iff it carries truth (true or both)."""
    return x[0] == 1


def evaluate(formula: str, env: Dict[str, Value]) -> Value:
    """Evaluate a FOUR formula in reverse-Polish (postfix) over tokens.

    Tokens: variable names, 'N' (neg, unary), 'C' (conj), 'D' (disj).
    O(len(formula)) per assignment using a constant-space stack.
    """
    stack: List[Value] = []
    for tok in formula.split():
        if tok == "N":
            stack.append(neg(stack.pop()))
        elif tok == "C":
            b, a = stack.pop(), stack.pop()
            stack.append(conj(a, b))
        elif tok == "D":
            b, a = stack.pop(), stack.pop()
            stack.append(disj(a, b))
        else:
            stack.append(env[tok])
    return stack.pop()
