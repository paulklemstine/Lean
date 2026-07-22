from typing import Dict, List, Tuple

def num_balance_classes(edge_class: Dict[int, int]) -> int:
    """Number of distinct balance classes of a parallel class."""
    return len(set(edge_class.values()))

def is_digon_gainable(edge_class: Dict[int, int], n: int) -> bool:
    """digon_gainable_iff_card: gainable over Z/n  <=>  #classes <= n."""
    return num_balance_classes(edge_class) <= n

def contains_parallel_minor(edge_class: Dict[int, int], n: int) -> bool:
    """digon_isMinor_iff_card: contains (n+1)K2 minor  <=>  #classes >= n+1."""
    return num_balance_classes(edge_class) >= n + 1
