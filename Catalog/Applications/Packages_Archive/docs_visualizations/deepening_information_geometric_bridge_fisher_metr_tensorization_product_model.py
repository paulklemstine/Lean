from typing import List, Sequence, Tuple

def product_model(pM: Sequence[float], sM: Sequence[Sequence[float]],
                  pN: Sequence[float], sN: Sequence[Sequence[float]]
                  ) -> Tuple[List[float], List[List[float]]]:
    """Independent product: p((x,y))=pM[x]*pN[y], score=sM[x]+sN[y]."""
    d = len(sM[0])
    p: List[float] = []
    score: List[List[float]] = []
    for x in range(len(pM)):
        for y in range(len(pN)):
            p.append(pM[x]*pN[y])
            score.append([sM[x][i] + sN[y][i] for i in range(d)])
    return p, score