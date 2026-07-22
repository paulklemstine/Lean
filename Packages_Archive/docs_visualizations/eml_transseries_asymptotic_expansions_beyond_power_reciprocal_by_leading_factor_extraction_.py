from typing import Dict, Tuple

Mono = Tuple[Tuple[int, float], ...]
TSeries = Dict[Mono, float]

def reciprocal(f: TSeries, mono_cmp, mono_mul, order: int = 8) -> TSeries:
    """Reciprocal of a nonzero transseries.  Factor out the valuation (orderTop)
    monomial mu with coefficient c, so f = c*mu*(1+eps) with eps infinitesimal
    (strictly larger valuation); then 1/f = c^-1 mu^-1 * sum_k (-eps)^k.  Each term
    of the geometric series has strictly larger valuation, so a finite truncation
    determines any fixed order.  Complexity O(order * |f|^2)."""
    if not f:
        raise ZeroDivisionError("0 has no reciprocal")
    mu, c = min(f.items(), key=__import__("functools").cmp_to_key(
        lambda p, q: mono_cmp(dict(p[0]), dict(q[0]))))
    inv_mu: Mono = tuple(sorted(((h, -a) for h, a in mu), reverse=True))
    lead_inv: TSeries = {inv_mu: 1.0 / c}

    def mul(a: TSeries, b: TSeries) -> TSeries:
        out: TSeries = {}
        for m1, c1 in a.items():
            for m2, c2 in b.items():
                m = mono_mul(m1, m2)
                out[m] = out.get(m, 0.0) + c1 * c2
        return {m: x for m, x in out.items() if x != 0.0}

    def add(a: TSeries, b: TSeries) -> TSeries:
        out = dict(a)
        for m, x in b.items():
            out[m] = out.get(m, 0.0) + x
        return {m: x for m, x in out.items() if x != 0.0}

    one: TSeries = {(): 1.0}
    eps = add(mul(f, lead_inv), {(): -1.0})       # infinitesimal tail
    neg_eps = {m: -x for m, x in eps.items()}
    result, powk = dict(one), dict(one)
    for _ in range(order):
        powk = mul(powk, neg_eps)
        result = add(result, powk)
    return mul(result, lead_inv)
