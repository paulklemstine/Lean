from typing import Iterable

def prov(proofs: Iterable[tuple[str, int]]) -> set[str]:
    """Provable set = range of the conclusion map."""
    return {concl for concl, _size in proofs}

def simulates(q: Iterable[tuple[str, int]],
              p: Iterable[tuple[str, int]]) -> bool:
    """Simulates q p  <->  Prov p subset Prov q."""
    return prov(p) <= prov(q)

def sim_equiv(p: Iterable[tuple[str, int]],
              q: Iterable[tuple[str, int]]) -> bool:
    return simulates(p, q) and simulates(q, p)
