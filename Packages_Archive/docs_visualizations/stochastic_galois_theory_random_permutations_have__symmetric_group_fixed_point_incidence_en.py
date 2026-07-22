from itertools import permutations
from math import factorial
from typing import Dict

def fixed_distribution(n: int) -> Dict[int, int]:
    out: Dict[int, int] = {}
    for s in permutations(range(n)):
        k=sum(i==s[i] for i in range(n))
        out[k]=out.get(k,0)+1
    return dict(sorted(out.items()))

if __name__ == "__main__":
    for n in range(1,9):
        d=fixed_distribution(n)
        total=sum(k*v for k,v in d.items())
        print(n,d,total,"expected",factorial(n))
