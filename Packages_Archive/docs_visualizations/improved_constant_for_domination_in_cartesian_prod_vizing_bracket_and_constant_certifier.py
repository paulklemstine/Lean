from math import sqrt
from typing import Dict

C: float = (19.0 - sqrt(73.0)) / 18.0


def vizing_bracket(gamma_g: int, gamma_h: int, order_h: int,
                   gamma_prod: int) -> Dict[str, float]:
    """Return the Vizing-type certificates for a pair of graphs G, H.

    Given gamma(G), gamma(H), |V(H)|, and gamma(G [] H), compute:
      - lower bracket  max(gamma G, gamma H),
      - upper bracket  gamma(G) * |V(H)|,
      - Vizing product gamma(G) * gamma(H),
      - improved-constant bound  c * gamma(G) * gamma(H) with c=(19-sqrt73)/18,
      - the applicability flag min(gamma G, gamma H) <= 1,
    and boolean pass flags for each inequality against gamma(G [] H).
    """
    lower: int = max(gamma_g, gamma_h)
    upper: int = gamma_g * order_h
    vizing: int = gamma_g * gamma_h
    const_bound: float = C * gamma_g * gamma_h
    return {
        "lower_bracket": lower,
        "upper_bracket": upper,
        "vizing_rhs": vizing,
        "const_rhs": const_bound,
        "constant_regime_applies": float(min(gamma_g, gamma_h) <= 1),
        "bracket_ok": float(lower <= gamma_prod <= upper),
        "vizing_ok": float(gamma_prod >= vizing),
        "constant_ok": float(gamma_prod >= const_bound - 1e-9),
    }
