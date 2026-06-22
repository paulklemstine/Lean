from __future__ import annotations

def jacobian_dim(v0: int, vp: int, e: int) -> int:
    """First Betti number b1 = e - v + 1 = dim of the tropical Jacobian."""
    return e - (v0 + vp) + 1

def verify_dimension_theory(g: int, types: list[tuple[int, int, int, int]]) -> dict:
    """Verify the vertex bound, edge bound, and Jacobian identity on all types,
    returning the certified dimension max e = 3g - 3."""
    max_e = max(e for (_, _, e, _) in types)
    max_v = max(v0 + vp for (v0, vp, _, _) in types)
    for (v0, vp, e, w) in types:
        v = v0 + vp
        b1 = jacobian_dim(v0, vp, e)
        assert v + 2 <= 2 * g            # vertex_bound
        assert e + 3 <= 3 * g            # edge_bound
        assert b1 == g - w               # jacobianDim_eq
        assert b1 >= 0                   # jacobianDim_nonneg
        assert w <= g                    # weight_le_genus
    assert max_e == 3 * g - 3
    assert max_v == 2 * g - 2
    return {"dimension": max_e, "max_vertices": max_v, "num_types": len(types)}
