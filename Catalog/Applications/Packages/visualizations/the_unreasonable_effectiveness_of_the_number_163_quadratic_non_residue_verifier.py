def is_qnr(d: int, p: int) -> bool:
    qr = {(x * x) % p for x in range(p)}
    return (-d % p) not in qr