from typing import Iterable

def index_jump(value: int, factors: Iterable[int]) -> int:
    for factor in factors:
        if factor == 2:
            value = value*value - 2
        elif factor == 3:
            value = value**3 - 3*value
        else:
            raise ValueError("factors must be 2 or 3")
    return value

if __name__ == "__main__":
    print(index_jump(3, [2, 2, 3]))  # u_12(3)
