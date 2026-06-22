def val_int(p: int, n: int) -> int:
    return 0 if n % p == 0 else 1

def residue_nonzero(p: int, n: int) -> bool:
    return (n % p) != 0
