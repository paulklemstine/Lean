from typing import Hashable, Optional, Tuple, TypeVar
L = TypeVar("L", bound=Hashable)
Address = Tuple[int, ...]

def unary_value(address: Address, label: L) -> Optional[L]:
    return label if all(i == 0 for i in address) else None

def truncated_value(address: Address, cutoff: int, label: L) -> Optional[L]:
    return unary_value(address, label) if len(address) <= cutoff else None
