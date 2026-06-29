"""
demo.py — Numerical demonstrations of the Finite Chain Semiring.

The finite chain semiring is the non-standard arithmetic on the ladder
{0, 1, ..., n} where:

    addition       x ⊕ y := max(x, y)      additive identity  0 = ⊥ (bottom)
    multiplication x ⊗ y := min(x, y)      multiplicative id. 1 = ⊤ (top = n)

This file verifies, by exhaustive enumeration over the finite chain, every
algebraic law proved in the accompanying Lean development, and illustrates the
"alien" features: idempotent addition, the inverted multiplicative unit, the
absence of subtraction, and the isomorphism with finite many-valued logic.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Iterator


# ---------------------------------------------------------------------------
# Core operations of the chain semiring on C_n = {0, 1, ..., n}
# ---------------------------------------------------------------------------

def chain_add(x: int, y: int) -> int:
    """Chain addition: the join (max). Climb to the higher rung."""
    return max(x, y)


def chain_mul(x: int, y: int) -> int:
    """Chain multiplication: the meet (min). Settle for the lower rung."""
    return min(x, y)


def chain_zero() -> int:
    """Additive identity: the bottom element ⊥ = 0."""
    return 0


def chain_one(n: int) -> int:
    """Multiplicative identity: the top element ⊤ = n (the LARGEST element)."""
    return n


def elements(n: int) -> Iterator[int]:
    """Enumerate the carrier C_n = {0, 1, ..., n}."""
    return iter(range(n + 1))


# ---------------------------------------------------------------------------
# Exhaustive verification of each Lean-proved law over C_n
# ---------------------------------------------------------------------------

def verify_add_assoc(n: int) -> bool:
    """max_assoc': (x ⊕ y) ⊕ z = x ⊕ (y ⊕ z)."""
    return all(
        chain_add(chain_add(x, y), z) == chain_add(x, chain_add(y, z))
        for x, y, z in product(range(n + 1), repeat=3)
    )


def verify_add_comm(n: int) -> bool:
    """max_comm': x ⊕ y = y ⊕ x."""
    return all(
        chain_add(x, y) == chain_add(y, x)
        for x, y in product(range(n + 1), repeat=2)
    )


def verify_mul_assoc(n: int) -> bool:
    """min_assoc': (x ⊗ y) ⊗ z = x ⊗ (y ⊗ z)."""
    return all(
        chain_mul(chain_mul(x, y), z) == chain_mul(x, chain_mul(y, z))
        for x, y, z in product(range(n + 1), repeat=3)
    )


def verify_mul_comm(n: int) -> bool:
    """min_comm': x ⊗ y = y ⊗ x."""
    return all(
        chain_mul(x, y) == chain_mul(y, x)
        for x, y in product(range(n + 1), repeat=2)
    )


def verify_left_distrib(n: int) -> bool:
    """min_max_distrib: x ⊗ (y ⊕ z) = (x ⊗ y) ⊕ (x ⊗ z)."""
    return all(
        chain_mul(x, chain_add(y, z))
        == chain_add(chain_mul(x, y), chain_mul(x, z))
        for x, y, z in product(range(n + 1), repeat=3)
    )


def verify_right_distrib(n: int) -> bool:
    """right_distrib: (x ⊕ y) ⊗ z = (x ⊗ z) ⊕ (y ⊗ z)."""
    return all(
        chain_mul(chain_add(x, y), z)
        == chain_add(chain_mul(x, z), chain_mul(y, z))
        for x, y, z in product(range(n + 1), repeat=3)
    )


def verify_max_min_distrib(n: int) -> bool:
    """max_min_distrib: x ⊕ (y ⊗ z) = (x ⊕ y) ⊗ (x ⊕ z) (dual distributivity)."""
    return all(
        chain_add(x, chain_mul(y, z))
        == chain_mul(chain_add(x, y), chain_add(x, z))
        for x, y, z in product(range(n + 1), repeat=3)
    )


def verify_zero_id(n: int) -> bool:
    """zero_is_add_id / add_id_zero: 0 ⊕ x = x = x ⊕ 0."""
    z = chain_zero()
    return all(
        chain_add(z, x) == x and chain_add(x, z) == x for x in range(n + 1)
    )


def verify_one_id(n: int) -> bool:
    """one_is_mul_id / mul_id_one: ⊤ ⊗ x = x = x ⊗ ⊤."""
    o = chain_one(n)
    return all(
        chain_mul(o, x) == x and chain_mul(x, o) == x for x in range(n + 1)
    )


def verify_zero_annihilates(n: int) -> bool:
    """zero_mul / mul_zero: 0 ⊗ x = 0 = x ⊗ 0."""
    z = chain_zero()
    return all(
        chain_mul(z, x) == z and chain_mul(x, z) == z for x in range(n + 1)
    )


def verify_idempotence(n: int) -> bool:
    """max_idem / min_idem: x ⊕ x = x and x ⊗ x = x."""
    return all(
        chain_add(x, x) == x and chain_mul(x, x) == x for x in range(n + 1)
    )


def verify_absorption(n: int) -> bool:
    """max_absorb / min_absorb: x ⊕ (x ⊗ y) = x and x ⊗ (x ⊕ y) = x."""
    return all(
        chain_add(x, chain_mul(x, y)) == x
        and chain_mul(x, chain_add(x, y)) == x
        for x, y in product(range(n + 1), repeat=2)
    )


def top_has_no_additive_inverse(n: int) -> bool:
    """top_no_add_inverse: for n >= 1 there is no z with ⊤ ⊕ z = 0."""
    if n < 1:
        return False  # theorem requires n >= 1
    top = chain_one(n)
    return not any(chain_add(top, z) == chain_zero() for z in range(n + 1))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_alien_addition_table(n: int) -> None:
    """Print the 'alien' addition (max) and multiplication (min) tables."""
    print(f"\n=== Chain C_{n} = {{0, ..., {n}}}: addition ⊕ = max ===")
    header = "  ⊕ |" + "".join(f"{j:3d}" for j in range(n + 1))
    print(header)
    print("  " + "-" * (len(header) - 2))
    for i in range(n + 1):
        row = "".join(f"{chain_add(i, j):3d}" for j in range(n + 1))
        print(f"{i:4d} |{row}")

    print(f"\n=== Chain C_{n}: multiplication ⊗ = min ===")
    print(header.replace("⊕", "⊗"))
    print("  " + "-" * (len(header) - 2))
    for i in range(n + 1):
        row = "".join(f"{chain_mul(i, j):3d}" for j in range(n + 1))
        print(f"{i:4d} |{row}")

    print(f"\n  additive identity 0 = ⊥ = 0")
    print(f"  multiplicative identity 1 = ⊤ = {n}  (the LARGEST element!)")
    print(f"  surprising sums:  2 ⊕ 3 = {chain_add(2, 3)},  "
          f"2 ⊕ 2 = {chain_add(2, 2)},  {n} ⊕ 0 = {chain_add(n, 0)}")


def demo_logic_isomorphism() -> None:
    """Show that C_1 = {0,1} is the Boolean semiring (OR, AND)."""
    print("\n=== Logical reading on C_1 = {0,1}: ⊕ = OR, ⊗ = AND ===")
    names = {0: "false", 1: "true "}
    print("  p     q     p OR q   p AND q")
    for p, q in product((0, 1), repeat=2):
        print(f"  {names[p]} {names[q]}  {names[chain_add(p, q)]}    "
              f"{names[chain_mul(p, q)]}")
    print("  => the two-element chain semiring IS classical Boolean logic.")


def demo_no_subtraction(n: int) -> None:
    """Illustrate that subtraction is impossible: ⊤ has no additive inverse."""
    print(f"\n=== No subtraction on C_{n}: ⊤ = {n} has no additive inverse ===")
    top = chain_one(n)
    for z in range(n + 1):
        s = chain_add(top, z)
        print(f"  ⊤ ⊕ {z} = max({top},{z}) = {s}"
              f"{'   <- equals 0?  NO' if s != 0 else ''}")
    ok = top_has_no_additive_inverse(n)
    print(f"  no z gives ⊤ ⊕ z = 0  =>  no additive inverse: {ok}")


def run_all_verifications(max_n: int = 9) -> None:
    """Exhaustively verify every law for chains C_1, ..., C_{max_n}."""
    checks = {
        "add_assoc (max_assoc')":        verify_add_assoc,
        "add_comm  (max_comm')":         verify_add_comm,
        "mul_assoc (min_assoc')":        verify_mul_assoc,
        "mul_comm  (min_comm')":         verify_mul_comm,
        "left_distrib (min_max_distrib)": verify_left_distrib,
        "right_distrib":                  verify_right_distrib,
        "max_min_distrib (dual)":         verify_max_min_distrib,
        "zero identity":                  verify_zero_id,
        "one identity":                   verify_one_id,
        "zero annihilates":               verify_zero_annihilates,
        "idempotence":                    verify_idempotence,
        "absorption":                     verify_absorption,
        "top_no_add_inverse":             top_has_no_additive_inverse,
    }
    print("\n=== Exhaustive verification over chains C_1 .. C_{} ===".format(max_n))
    all_ok = True
    for name, fn in checks.items():
        results = [fn(n) for n in range(1, max_n + 1)]
        ok = all(results)
        all_ok = all_ok and ok
        print(f"  [{'PASS' if ok else 'FAIL'}] {name}")
    print(f"\n  ALL LAWS VERIFIED: {all_ok}")


def main() -> None:
    demo_alien_addition_table(5)
    demo_logic_isomorphism()
    demo_no_subtraction(5)
    run_all_verifications(max_n=9)


if __name__ == "__main__":
    main()
