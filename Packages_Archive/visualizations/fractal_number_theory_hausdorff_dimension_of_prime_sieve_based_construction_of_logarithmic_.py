from __future__ import annotations
import math

def primes_up_to(limit: int) -> list[int]:
    if limit < 2:
        return []
    sieve = bytearray(b"\x01") * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, math.isqrt(limit) + 1):
        if sieve[p]:
            sieve[p*p:limit+1:p] = b"\x00" * (((limit-p*p)//p)+1)
    return [n for n, flag in enumerate(sieve) if flag]

def coordinates(limit: int) -> list[float]:
    return [1.0 / math.log(p) for p in primes_up_to(limit)]

if __name__ == "__main__":
    ps = primes_up_to(100_000)
    xs = coordinates(100_000)
    print(f"{len(ps)} primes; coordinate range {min(xs):.8g} to {max(xs):.8g}")
