from typing import Sequence

def aggregate(sigs: Sequence[int], n: int) -> int:
    agg = 0
    for s in sigs:
        agg = (agg + s) % n
    return agg

def agg_verify(bls, hashes: Sequence[int], pubs: Sequence[int],
               agg: int) -> bool:
    prod = 1
    for h, X in zip(hashes, pubs):
        prod = (prod * bls.e(h, X)) % bls.p
    return bls.e(agg, bls.g) == prod
