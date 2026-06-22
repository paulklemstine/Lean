from typing import Tuple

def encode_volume(volume: Tuple[int, ...], b: int) -> int:
    address = 0
    for i, symbol in enumerate(volume):
        address += symbol * (b ** i)
    return address

def decode_address(address: int, b: int, length: int) -> Tuple[int, ...]:
    digits = []
    for _ in range(length):
        digits.append(address % b)
        address //= b
    return tuple(digits)
