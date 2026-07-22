from typing import Dict, List, Tuple
Pair = Tuple[int, int]

def period(t: int, q: int) -> Tuple[int, List[Pair]]:
    if q <= 1:
        raise ValueError("q must exceed one")
    start = (2 % q, t % q)
    state = start
    seen: Dict[Pair, int] = {}
    states: List[Pair] = []
    while state not in seen:
        seen[state] = len(states)
        states.append(state)
        x, y = state
        state = (y, (t*y - x) % q)
    assert state == start
    return len(states), states

if __name__ == "__main__":
    for q in range(2, 21):
        print(q, period(3, q)[0])
