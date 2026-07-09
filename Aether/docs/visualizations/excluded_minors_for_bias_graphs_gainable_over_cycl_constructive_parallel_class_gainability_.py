from typing import Dict, List, Optional, Sequence, Tuple

def parallel_class_gainability(classes: Sequence[int], p: int
                               ) -> Tuple[bool, Optional[Tuple[int, ...]],
                                          Optional[List[int]]]:
    """
    Decide Z/p-gainability of a parallel-class biased graph.

    `classes[i]` is the balanced-class label of edge i; a digon (i, j) is balanced
    iff classes[i] == classes[j]. Returns (gainable, labelling, certificate):
      * if gainable: (True, g, None) with g a realising Z/p-gain;
      * else:        (False, None, reps) with reps a list of p+1 edges in distinct
                     classes forming a (p+1)K_2 excluded-minor certificate.
    Complexity: O(m) after an O(m) class scan.
    """
    seen: Dict[int, int] = {}
    reps_by_class: Dict[int, int] = {}
    for i, c in enumerate(classes):
        if c not in seen:
            seen[c] = len(seen)
            reps_by_class[c] = i
    kappa = len(seen)
    if kappa > p:
        reps = list(reps_by_class.values())[: p + 1]
        return (False, None, reps)
    g = tuple(seen[c] for c in classes)
    return (True, g, None)
