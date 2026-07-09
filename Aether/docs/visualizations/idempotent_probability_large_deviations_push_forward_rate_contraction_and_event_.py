from typing import Callable, Dict, Hashable, List, Sequence

def pushforward_and_contract(
    weight: Dict[Hashable, float],
    T: Dict[Hashable, Hashable],
) -> Dict[Hashable, float]:
    """Compute the push-forward rate function I_Y(y) = min_{x : T(x)=y} I_X(x)
    of a tropical probability `weight` along a surjection `T : X -> Y`.

    Returns the observed-space rate function as a dict y -> I_Y(y).
    Runs in O(|X|): one pass to take fiber maxima, then negate.
    """
    # push-forward weight w_Y(y) = max over fiber of w(x)   (pushforwardMeasure)
    wY: Dict[Hashable, float] = {}
    for x, y in T.items():
        wY[y] = max(wY.get(y, float("-inf")), weight[x])
    # rate of push-forward = fiber-wise minimum of I_X       (pushforward_rate)
    return {y: -w for y, w in wY.items()}

def contraction_cost(
    weight: Dict[Hashable, float],
    T: Dict[Hashable, Hashable],
    B: Sequence[Hashable],
) -> float:
    """Deviation cost of an observed event B, computed two equivalent ways and
    asserted equal (idempotent_contraction):
        cost_Y(B) = min_{y in B} I_Y(y) = min_{x : T(x) in B} I_X(x) = cost_X(T^-1 B).
    """
    I_Y = pushforward_and_contract(weight, T)
    upstairs = min(I_Y[y] for y in B)
    Bset = set(B)
    downstairs = min(-weight[x] for x in weight if T[x] in Bset)
    assert abs(upstairs - downstairs) < 1e-9, "contraction principle violated"
    return upstairs
