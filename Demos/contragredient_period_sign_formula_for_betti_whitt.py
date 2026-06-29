"""
demo.py — Numerical demonstration of the contragredient period sign formula
for Betti–Whittaker periods of GL(n).

Mathematics (all self-contained):

  Bottom cohomological degree of the locally symmetric space of GL(n)/F,
  where F is a number field with r1 real and r2 complex places:

        b(F, n) = r1 * floor(n^2 / 4) + r2 * n*(n-1)/2 .

  Contragredient period relation:

        p^b(pi_dual) = (-1)^{b(F,n)} * p^b(pi).

  Parity laws:
        floor(n^2/4) is odd   <=>  n ≡ 2 (mod 4)
        n(n-1)/2     is odd   <=>  n ≡ 2 or 3 (mod 4)

  Trichotomy for the sign (-1)^{b(F,n)}:
        n ≡ 0,1 (mod 4):  +1                  (every field)
        n ≡ 2   (mod 4):  (-1)^{r1 + r2}
        n ≡ 3   (mod 4):  (-1)^{r2}           (real places drop out)

This script verifies these facts numerically by brute force and prints tables.
Run:  python demo.py
"""

from __future__ import annotations


def floor_sq_div_four(n: int) -> int:
    """Return floor(n^2 / 4)."""
    return (n * n) // 4


def triangular(n: int) -> int:
    """Return the (n-1)-st triangular number n(n-1)/2 = C(n,2)."""
    return n * (n - 1) // 2


def bottom_degree(n: int, r1: int, r2: int) -> int:
    """Bottom cohomological degree b(F,n) = r1*floor(n^2/4) + r2*n(n-1)/2."""
    return r1 * floor_sq_div_four(n) + r2 * triangular(n)


def bottom_degree_floor_form(n: int, r1: int, r2: int) -> int:
    """b(F,n) in integer-floor form r1*(n//2)*((n+1)//2) + r2*n*(n-1)//2."""
    return r1 * (n // 2) * ((n + 1) // 2) + r2 * (n * (n - 1) // 2)


def contra_sign(n: int, r1: int, r2: int) -> int:
    """The explicit sign (-1)^{b(F,n)} via the closed bottom degree."""
    return -1 if bottom_degree(n, r1, r2) % 2 == 1 else 1


def contra_sign_trichotomy(n: int, r1: int, r2: int) -> int:
    """The sign predicted by the n mod 4 trichotomy (no big integer formed)."""
    m = n % 4
    if m in (0, 1):
        parity = 0
    elif m == 2:
        parity = (r1 + r2) % 2
    else:  # m == 3
        parity = r2 % 2
    return -1 if parity == 1 else 1


def self_dual_possible(n: int, r1: int, r2: int) -> bool:
    """A self-dual generic pi can exist only if the sign is +1, i.e. b even."""
    return contra_sign(n, r1, r2) == 1


def demo_parity_laws(n_max: int = 11) -> None:
    print("=" * 64)
    print("PARITY LAWS  (n = 0 .. %d)" % n_max)
    print("=" * 64)
    fs = [floor_sq_div_four(n) for n in range(n_max + 1)]
    tr = [triangular(n) for n in range(n_max + 1)]
    print("n            :", " ".join(f"{n:2d}" for n in range(n_max + 1)))
    print("floor(n^2/4) :", " ".join(f"{v:2d}" for v in fs))
    print("  parity     :", " ".join(f"{v % 2:2d}" for v in fs))
    print("n(n-1)/2     :", " ".join(f"{v:2d}" for v in tr))
    print("  parity     :", " ".join(f"{v % 2:2d}" for v in tr))
    # Verify the iff statements.
    for n in range(0, 400):
        assert (floor_sq_div_four(n) % 2 == 1) == (n % 4 == 2)
        assert (triangular(n) % 2 == 1) == (n % 4 in (2, 3))
    print("\nVerified for n = 0..399:")
    print("  floor(n^2/4) odd  <=>  n ≡ 2 (mod 4)")
    print("  n(n-1)/2     odd  <=>  n ≡ 2 or 3 (mod 4)")


def demo_trichotomy(n_max: int = 16, r_max: int = 4) -> None:
    print("\n" + "=" * 64)
    print("TRICHOTOMY CHECK: closed form sign == mod-4 prediction")
    print("=" * 64)
    mismatches = 0
    for n in range(2, n_max + 1):
        for r1 in range(r_max + 1):
            for r2 in range(r_max + 1):
                a = contra_sign(n, r1, r2)
                b = contra_sign_trichotomy(n, r1, r2)
                # Also check the floor-form equals the closed form.
                assert bottom_degree(n, r1, r2) == bottom_degree_floor_form(n, r1, r2)
                if a != b:
                    mismatches += 1
    print(f"n = 2..{n_max}, r1,r2 = 0..{r_max}: mismatches = {mismatches}")
    print("All signs match the n mod 4 trichotomy." if mismatches == 0 else "FAIL")


def demo_archimedean_rigidity() -> None:
    print("\n" + "=" * 64)
    print("ARCHIMEDEAN RIGIDITY: n ≡ 3 (mod 4) => real places invisible")
    print("=" * 64)
    print("Fix n = 3, r2 = 1; vary r1.  Sign should be (-1)^{r2} = -1 always.")
    for r1 in range(6):
        s = contra_sign(3, r1, 1)
        print(f"  r1 = {r1}:  sign = {s:+d}")
    print("\nFix n = 7, r2 = 0 (totally real); vary r1.  Sign should be +1.")
    for r1 in range(1, 6):
        s = contra_sign(7, r1, 0)
        print(f"  r1 = {r1}:  sign = {s:+d}")


def demo_self_duality_obstruction() -> None:
    print("\n" + "=" * 64)
    print("SELF-DUALITY OBSTRUCTION: self-dual pi needs b(F,n) even")
    print("=" * 64)
    examples = [
        ("Q,          GL(2)", 2, 1, 0),  # n=2, r1+r2=1 odd -> sign -1
        ("Q(i),       GL(2)", 2, 0, 1),  # n=2, r1+r2=1 odd -> sign -1
        ("Q,          GL(3)", 3, 1, 0),  # n=3, r2=0 even   -> sign +1
        ("Q(i),       GL(3)", 3, 0, 1),  # n=3, r2=1 odd    -> sign -1
        ("Q,          GL(4)", 4, 1, 0),  # n=4 -> sign +1
        ("Q(sqrt2),   GL(7)", 7, 2, 0),  # n=7 ≡3, r2=0     -> sign +1
    ]
    for name, n, r1, r2 in examples:
        s = contra_sign(n, r1, r2)
        ok = "self-dual possible" if self_dual_possible(n, r1, r2) else "NO self-dual pi"
        print(f"  {name}: (r1,r2)=({r1},{r2})  sign={s:+d}  ->  {ok}")


def demo_square_root_of_unity() -> None:
    print("\n" + "=" * 64)
    print("SQUARE ROOT OF UNITY: sign^2 == 1 always")
    print("=" * 64)
    ok = all(
        contra_sign(n, r1, r2) ** 2 == 1
        for n in range(2, 30)
        for r1 in range(5)
        for r2 in range(5)
    )
    print("sign^2 == 1 for all tested (n, r1, r2):", ok)


if __name__ == "__main__":
    demo_parity_laws()
    demo_trichotomy()
    demo_archimedean_rigidity()
    demo_self_duality_obstruction()
    demo_square_root_of_unity()
    print("\nAll demonstrations completed successfully.")
