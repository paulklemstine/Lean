from decimal import Decimal, getcontext
from typing import List
getcontext().prec = 90
PI = Decimal("3.141592653589793238462643383279502884197169399375105820974944592307816406286")

def biases(target: Decimal, depth: int) -> List[int]:
    prefixes = [int(target * (2 ** n)) for n in range(depth + 1)]
    result = [prefixes[n + 1] - 2 * prefixes[n] for n in range(depth)]
    assert all(bit in (0, 1) for bit in result)
    return result

def execute(target: Decimal, depth: int) -> int:
    state = int(target)
    for bit in biases(target, depth):
        state = max(2 * state + bit, 0)
    assert state == int(target * (2 ** depth))
    return state

if __name__ == "__main__":
    bits = biases(PI, 40)
    print("biases:", "".join(map(str, bits)))
    print("depth-40 state:", execute(PI, 40))
