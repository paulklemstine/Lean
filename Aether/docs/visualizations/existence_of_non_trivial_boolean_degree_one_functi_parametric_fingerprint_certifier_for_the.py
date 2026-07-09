from typing import Dict, Set

def bruen_drudge_parameter(q: int) -> int:
    """x = (q^2 + 1) // 2."""
    return (q * q + 1) // 2

def trivial_parameter_set(q: int) -> Set[int]:
    return {0, 1, 2, q * q - 1, q * q, q * q + 1}

def certify_non_trivial(q: int) -> Dict[str, bool]:
    """Verify the full parametric fingerprint of the Bruen-Drudge example."""
    x = bruen_drudge_parameter(q)
    q2 = q * q
    size = x * (q2 + q + 1)
    total = (q2 + 1) * (q2 + q + 1)
    return {
        "integrality_2x_eq_q2p1": 2 * x == q2 + 1,
        "self_complementary": x == (q2 + 1) - x,
        "gt_two": 2 < x,
        "lt_q2_minus_one": x < q2 - 1,
        "not_in_trivial_set": x not in trivial_parameter_set(q),
        "half_and_half": 2 * size == total,
    }
