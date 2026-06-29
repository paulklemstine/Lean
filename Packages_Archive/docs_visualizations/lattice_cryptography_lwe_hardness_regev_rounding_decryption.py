from typing import Sequence

def regev_decrypt_bit(v: int, u: Sequence[int], s: Sequence[int], q: int) -> int:
    """Decrypt one Regev/Dual-Regev ciphertext bit.
    Compute the residual r = v - <u, s> mod q, fold it into the centered
    representative in (-q/2, q/2], and round: bit 0 if |r| < q/4 else bit 1.
    Verified correct (regev_rounding_bit0/bit1) whenever total noise |e| < q/4."""
    r = (v - sum(ui * si for ui, si in zip(u, s))) % q
    centered = r if r <= q // 2 else r - q
    return 0 if abs(centered) < q / 4 else 1
