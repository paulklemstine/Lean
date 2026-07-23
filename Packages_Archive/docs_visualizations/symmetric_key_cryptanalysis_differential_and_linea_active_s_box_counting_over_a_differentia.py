from typing import List

State = List[List[int]]


def active_sbox_count(trail: List[State]) -> int:
    """
    Active-S-box counting.

    Given a differential/linear trail (a list of 4x4 states whose nonzero
    entries mark active byte positions), return the total number of active
    S-boxes summed over all states.  This is the quantity the wide-trail
    theorem lower-bounds by B^2.

    Complexity: O(R * r * c) for R states of size r x c (here O(R * 16)).
    """
    total = 0
    for state in trail:
        total += sum(1 for row in state for x in row if x != 0)
    return total
