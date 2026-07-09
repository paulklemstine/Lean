from typing import List


def stack_sort(l: List[int]) -> List[int]:
    out: List[int] = []
    s: List[int] = []
    for x in l:
        while s and s[0] < x:
            out.append(s.pop(0))
        s = [x] + s
    out.extend(s)
    return out


def depth(l: List[int]) -> int:
    """Least number of stack_sort passes turning l into its ascending sort.

    Bounded by n-1 (West), so the loop terminates; O(n^2) worst case.
    """
    cur: List[int] = list(l)
    target: List[int] = sorted(l)
    steps: int = 0
    fuel: int = len(l)
    while cur != target and fuel > 0:
        cur = stack_sort(cur)
        steps += 1
        fuel -= 1
    return steps


if __name__ == "__main__":
    print(depth([2, 3, 1]))        # -> 2
    print(depth([1, 2, 3, 4]))     # -> 0
