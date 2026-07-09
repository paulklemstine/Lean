from typing import List, Tuple

Letter = Tuple[int, int]  # (edge_index, sign in {+1,-1})
Word = List[Letter]


def free_reduce(word: Word) -> Word:
    """Return the unique freely-reduced form of a word in the free group.

    Cancels every adjacent inverse pair using a single left-to-right stack
    pass. Runs in O(n) time and O(n) space.
    """
    stack: Word = []
    for edge, sign in word:
        if stack and stack[-1][0] == edge and stack[-1][1] == -sign:
            stack.pop()
        else:
            stack.append((edge, sign))
    return stack
