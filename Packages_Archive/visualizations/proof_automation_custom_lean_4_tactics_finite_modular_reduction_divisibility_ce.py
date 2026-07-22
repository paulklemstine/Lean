from typing import Callable, Sequence

def divides_for_all_residues(modulus: int, poly: Callable[[int], int]) -> bool:
    """Finite check behind the ZMod reduction: modulus | poly(x) for every
    residue x = 0..modulus-1 certifies modulus | poly(n) for ALL integers n."""
    return all(poly(x) % modulus == 0 for x in range(modulus))

def main() -> None:
    cases = [
        (5, lambda n: n ** 5 - n, "5 | n^5 - n   (fermat_little_five)"),
        (7, lambda n: n ** 7 - n, "7 | n^7 - n   (fermat_little_seven)"),
        (6, lambda n: n ** 3 - n, "6 | n^3 - n   (cube_sub_self_six)"),
    ]
    for m, f, label in cases:
        ok = divides_for_all_residues(m, f)
        spot: Sequence[int] = range(-10, 11)
        spot_ok = all(f(n) % m == 0 for n in spot)
        print(f"{label}: finite check={ok}, spot-check={spot_ok}")

if __name__ == "__main__":
    main()
