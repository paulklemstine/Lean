from typing import Dict, Iterable, Optional, Set, Tuple

def find_nonexplosion_witness(
    universe: Iterable[str], derived: Set[str], negation: Dict[str, str]
) -> Optional[Tuple[str, str]]:
    underived = [sentence for sentence in universe if sentence not in derived]
    if not underived:
        return None
    for sentence in derived:
        if negation[sentence] in derived:
            return sentence, underived[0]
    return None
