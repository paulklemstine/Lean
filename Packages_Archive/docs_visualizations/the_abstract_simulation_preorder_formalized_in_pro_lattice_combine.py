from typing import Iterable, Optional

Proof = tuple[str, int]

def join_prov(p: Iterable[Proof], q: Iterable[Proof]) -> set[str]:
    return {c for c, _ in p} | {c for c, _ in q}

def _best(proofs: Iterable[Proof], f: str) -> Optional[int]:
    sizes = [s for c, s in proofs if c == f]
    return min(sizes) if sizes else None

def meet_prov_with_size(p: list[Proof], q: list[Proof]) -> dict[str, int]:
    shared = {c for c, _ in p} & {c for c, _ in q}
    out: dict[str, int] = {}
    for f in shared:
        sp, sq = _best(p, f), _best(q, f)
        assert sp is not None and sq is not None
        out[f] = sp + sq
    return out
