from itertools import product
from typing import Dict, Optional, Set, Tuple

Sentence = str

def trilemma_search(pairs: Tuple[Tuple[Sentence, Sentence], ...]
                    ) -> int:
    """
    Exhaustively verify the abstract incompleteness theorem on a finite
    syntax.  `pairs` lists negation-pairs (s, neg s).  Returns the number of
    provability predicates that are simultaneously consistent,
    negation-complete, and host a diagonal sentence g with
    (g provable) <-> (neg g provable).  The theorem asserts this count is 0.
    """
    neg: Dict[Sentence, Sentence] = {}
    for a, b in pairs:
        neg[a] = b
        neg[b] = a
    sentences = list(neg.keys())
    violations = 0
    for bits in product((0, 1), repeat=len(sentences)):
        prov: Set[Sentence] = {s for s, b in zip(sentences, bits) if b}
        consistent = all(not (s in prov and neg[s] in prov) for s in neg)
        complete = all((s in prov) or (neg[s] in prov) for s in neg)
        diagonal: Optional[Sentence] = next(
            (g for g in neg if (g in prov) == (neg[g] in prov)), None)
        if consistent and complete and diagonal is not None:
            violations += 1
    return violations
