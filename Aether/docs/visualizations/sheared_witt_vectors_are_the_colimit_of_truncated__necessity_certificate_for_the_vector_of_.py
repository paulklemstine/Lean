from __future__ import annotations

def escaping_coordinate(stage: int) -> int:
    """Necessity witness: for the vector of all variables X = (x_0, x_1, ...)
    over K[x_0, x_1, ...] with stages S_i = K[x_0,...,x_{i-1}], return the index
    of a coordinate of X that is NOT contained in stage S_i.

    The coordinate x_i lies in S_{i+1} but not in S_i, so `stage` itself is the
    escaping coordinate index, certifying that no finite stage holds all of X.

    Args:
        stage: candidate stage index i.

    Returns:
        Index j such that x_j is in X but x_j not in S_stage (here j = stage).
    """
    return stage  # x_stage requires stage+1 > stage, so it escapes S_stage
