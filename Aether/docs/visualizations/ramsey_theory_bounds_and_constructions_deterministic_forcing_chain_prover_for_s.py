from typing import Dict, List

def forcing_chain_five() -> List[str]:
    steps: List[str] = []
    col: Dict[int, str] = {1: 'a'}
    steps.append('Let a = c(1).')
    col[2] = 'not a'
    steps.append('1+1=2 forces c(2) = not a.')
    col[4] = 'a'
    steps.append('2+2=4 forces c(4) = a.')
    col[5] = 'not a'
    steps.append('1+4=5 forces c(5) = not a.')
    col[3] = 'a'
    steps.append('2+3=5 forces c(3) = a.')
    steps.append('1+3=4: c(1)=c(3)=c(4)=a -> contradiction.')
    return steps
