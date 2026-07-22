from typing import List, Tuple

Letter = Tuple[int, int]
Word = List[Letter]

TREE_EDGES = (0, 1, 2)
CLOSING_EDGE = 3


def free_reduce(word: Word) -> Word:
    stack: Word = []
    for edge, sign in word:
        if stack and stack[-1][0] == edge and stack[-1][1] == -sign:
            stack.pop()
        else:
            stack.append((edge, sign))
    return stack


def discrete_homotopic(u: Word, v: Word, filled: bool) -> bool:
    """Decide discrete homotopy of two loops in the one-square complex.

    Sets tree edges to the identity, then compares. If the square is filled the
    boundary relation forces the closing generator to the identity, so every
    loop is null-homotopic and all words are equal. If the square is hollow the
    group is free on the closing generator, so equality is decided by the
    winding number. Runs in O(n) time.
    """
    def wind(w: Word) -> int:
        return sum(s for e, s in w if e == CLOSING_EDGE)

    if filled:
        return True
    return wind(free_reduce(u)) == wind(free_reduce(v))
