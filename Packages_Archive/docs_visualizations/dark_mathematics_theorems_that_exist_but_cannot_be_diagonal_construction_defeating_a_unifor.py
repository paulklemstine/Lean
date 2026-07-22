from typing import Callable, List

def diagonal_disagreement(decider: Callable[[int, int], bool],
                          num_statements: int = 16) -> List[int]:
    """Return indices where a diagonal statement is forced to disagree with D."""
    def diagonal_instance(i: int) -> bool:
        return not decider(i, i)          # negate the decider's diagonal guess
    return [i for i in range(num_statements)
            if diagonal_instance(i) != decider(i, i)]   # always all of them

if __name__ == "__main__":
    D = lambda i, n: (i * 7 + n) % 2 == 0
    bad = diagonal_disagreement(D)
    print(f"decider wrong on {len(bad)} diagonal entries -> no uniform decider")
