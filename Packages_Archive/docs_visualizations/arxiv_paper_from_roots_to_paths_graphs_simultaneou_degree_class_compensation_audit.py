from collections import defaultdict
from typing import DefaultDict, List, Tuple

def compensation_audit(degree: List[int], end: List[int]) -> List[Tuple[int,int]]:
    classes: DefaultDict[int,List[int]]=defaultdict(list)
    for v,d in enumerate(degree): classes[d].append(v)
    return [(v,w) for group in classes.values() for i,v in enumerate(group)
            for w in group[i+1:] if end[v]!=end[w]]
