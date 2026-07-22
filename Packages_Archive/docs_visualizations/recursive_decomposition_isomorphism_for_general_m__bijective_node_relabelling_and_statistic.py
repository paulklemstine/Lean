from typing import Callable, List, Tuple

def relabel(k: int) -> int:
    """Label bijection phi(k) = k + 1 realising the tree isomorphism."""
    return k + 1

def inv_relabel(k: int) -> int:
    """Inverse relabelling phi^{-1}(k) = k - 1."""
    return k - 1

def transport_statistic(sites_labels: List[int],
                        stat: Callable[[int], int]) -> Tuple[List[int], List[int]]:
    """Given the active-sites labels at a level and a statistic on labels,
    return (values on the sites side, values on the shifted side). The shifted
    labels are the +1 images, so applying the pulled-back statistic gives an
    identical multiset of values, demonstrating refined transport."""
    sites_vals = [stat(x) for x in sites_labels]
    shifted_labels = [relabel(x) for x in sites_labels]
    shifted_vals = [stat(inv_relabel(y)) for y in shifted_labels]
    return sites_vals, shifted_vals
