from typing import Sequence

def encode(book: Sequence[int], q: int) -> int:
    if q < 2 or any(d < 0 or d >= q for d in book):
        raise ValueError("invalid base or digit")
    value = 0
    for digit in book:
        value = q * value + digit
    return value

def decode(address: int, q: int, n: int) -> tuple[int, ...]:
    if q < 2 or n < 0 or not 0 <= address < q ** n:
        raise ValueError("invalid parameters")
    out = [0] * n
    for i in range(n - 1, -1, -1):
        address, out[i] = divmod(address, q)
    return tuple(out)

if __name__ == "__main__":
    b = (3, 1, 0, 2)
    a = encode(b, 4)
    print(b, a, decode(a, 4, 4))
