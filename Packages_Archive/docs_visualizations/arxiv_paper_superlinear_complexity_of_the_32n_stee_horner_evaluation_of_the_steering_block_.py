from typing import Sequence

def block_weight(symbols: Sequence[int], start: int, length: int) -> int:
    weight = 0
    two_power = 1
    for j in range(length):
        weight = 3*weight + two_power*symbols[start+j]
        two_power *= 2
    return weight

def verify(states: Sequence[int], symbols: Sequence[int], start: int, length: int) -> bool:
    return 2**length*states[start+length] == 3**length*states[start] + block_weight(symbols,start,length)

if __name__ == "__main__":
    states=[1,2,2,3,5,8,11,17]
    symbols=[1,-2,0,1,1,-2,1]
    for k in range(8):
        print(k, block_weight(symbols,0,k), verify(states,symbols,0,k))
