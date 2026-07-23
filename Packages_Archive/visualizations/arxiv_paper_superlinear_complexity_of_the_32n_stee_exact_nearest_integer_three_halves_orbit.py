from typing import List, Tuple

def nearest_three_halves(n: int) -> int:
    if n < 0:
        raise ValueError("n must be nonnegative")
    if n == 0:
        return 1
    return (3**n + 2**(n-1)) // 2**n

def generate(length: int) -> Tuple[List[int], List[int]]:
    states = [nearest_three_halves(n) for n in range(length + 1)]
    symbols = [2*states[n+1] - 3*states[n] for n in range(length)]
    return states, symbols

if __name__ == "__main__":
    m, t = generate(30)
    print("states:", m)
    print("symbols:", t)
    print("alphabet:", sorted(set(t)))
