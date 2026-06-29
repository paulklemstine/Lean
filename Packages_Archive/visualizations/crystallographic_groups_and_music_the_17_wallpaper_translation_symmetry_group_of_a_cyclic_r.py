from __future__ import annotations

def translation_sym_group(r: list[bool]) -> list[int]:
    p = len(r)
    return [k for k in range(p)
            if all(r[(n + k) % p] == r[n] for n in range(p))]
