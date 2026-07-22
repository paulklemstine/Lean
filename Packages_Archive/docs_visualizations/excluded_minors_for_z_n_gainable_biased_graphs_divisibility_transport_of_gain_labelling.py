from typing import Dict

def embed_zmod(j: int, m: int, n: int) -> int:
    """Injective additive hom Z/m -> Z/n (requires m | n): j -> j*(n//m)."""
    if n % m != 0:
        raise ValueError("embedding Z/m -> Z/n requires m | n")
    return (j * (n // m)) % n

def transport_labelling(g_m: Dict[int, int], m: int, n: int) -> Dict[int, int]:
    """gainable_mono_of_dvd: transport a Z/m witness to a Z/n witness when m | n."""
    return {e: embed_zmod(v, m, n) for e, v in g_m.items()}
