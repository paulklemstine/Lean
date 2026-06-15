from typing import Callable, List, TypeVar
A = TypeVar('A'); B = TypeVar('B')

def merkle_damgard(f: Callable[[A, B], A], iv: A, msg: List[B]) -> A:
    """merkleDamgard f iv msg = msg.foldl f iv (Definition 3.1)."""
    acc: A = iv
    for block in msg:
        acc = f(acc, block)
    return acc
