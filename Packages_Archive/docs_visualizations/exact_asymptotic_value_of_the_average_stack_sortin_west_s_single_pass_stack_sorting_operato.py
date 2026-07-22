from typing import List, Tuple


def pop_less(x: int, stack: List[int]) -> Tuple[List[int], List[int]]:
    """Pop every top element of `stack` (head = top) strictly smaller than x."""
    popped: List[int] = []
    rest: List[int] = list(stack)
    while rest and rest[0] < x:
        popped.append(rest.pop(0))
    return popped, rest


def sort_pass(xs: List[int], stack: List[int]) -> List[int]:
    """One left-to-right pass against `stack` (head = top)."""
    out: List[int] = []
    s: List[int] = list(stack)
    for x in xs:
        popped, s = pop_less(x, s)
        out.extend(popped)
        s = [x] + s
    out.extend(s)
    return out


def stack_sort(l: List[int]) -> List[int]:
    """West's stack-sorting map: one full pass from an empty stack. O(n) time/space."""
    return sort_pass(l, [])


if __name__ == "__main__":
    print(stack_sort([2, 3, 1]))   # -> [2, 1, 3]
    print(stack_sort([3, 1, 2]))   # -> [1, 2, 3]
