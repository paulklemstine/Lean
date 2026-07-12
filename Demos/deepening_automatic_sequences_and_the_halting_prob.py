"""
Numerical demonstrations of the finite-kernel criterion for automatic sequences.

This self-contained script illustrates the results of the accompanying paper:

  * decimations and the k-kernel of a sequence;
  * the decimation semigroup (composition) law;
  * the finite-kernel test for automaticity;
  * the exact two-element kernel of the Thue-Morse sequence;
  * closure of the automatic class under output codings and pointwise operations;
  * the parity <-> sign dictionary for Thue-Morse;
  * a contrasting non-automatic sequence with an unbounded kernel.

All functions are inlined and use only the Python standard library.
"""

from __future__ import annotations

from typing import Callable, Dict, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Core sequences
# ---------------------------------------------------------------------------

def thue_morse(n: int) -> int:
    """t_n = parity of the number of 1-bits in the binary expansion of n."""
    return bin(n).count("1") % 2


def thue_morse_sign(n: int) -> int:
    """epsilon_n = (-1)^{s_2(n)} in {+1, -1}, the multiplicative form."""
    return -1 if thue_morse(n) == 1 else 1


def rudin_shapiro(n: int) -> int:
    """Rudin-Shapiro: parity of the number of (overlapping) '11' blocks in n."""
    b = bin(n)[2:]
    count = sum(1 for i in range(len(b) - 1) if b[i] == "1" and b[i + 1] == "1")
    return count % 2


def paperfolding(n: int) -> int:
    """Regular paperfolding sequence, defined for n >= 1."""
    # n = m * 2^k with m odd; term is (m mod 4 == 1) -> 0 else 1, adjusted.
    m = n
    while m % 2 == 0:
        m //= 2
    return 0 if (m % 4) == 1 else 1


def identity_seq(n: int) -> int:
    """A_n = n : takes infinitely many values, hence NOT automatic."""
    return n


# ---------------------------------------------------------------------------
# Decimation and kernels
# ---------------------------------------------------------------------------

def decimate(a: Callable[[int], int], k: int, i: int, r: int) -> Callable[[int], int]:
    """The (i, r)-decimation of a in base k:  n |-> a(k^i * n + r)."""
    step = k ** i
    return lambda n: a(step * n + r)


def prefix(a: Callable[[int], int], length: int) -> Tuple[int, ...]:
    """Fingerprint a sequence by its first `length` terms."""
    return tuple(a(n) for n in range(length))


def kernel_prefixes(
    a: Callable[[int], int], k: int, max_depth: int, horizon: int
) -> Dict[Tuple[int, ...], List[Tuple[int, int]]]:
    """
    Enumerate distinct decimations a_{i,r} (0<=i<=max_depth, 0<=r<k^i) by their
    length-`horizon` prefixes.  Returns a map: prefix -> list of (i, r) that
    realize it.  The number of keys is the (probed) kernel size.
    """
    seen: Dict[Tuple[int, ...], List[Tuple[int, int]]] = {}
    for i in range(max_depth + 1):
        for r in range(k ** i):
            p = prefix(decimate(a, k, i, r), horizon)
            seen.setdefault(p, []).append((i, r))
    return seen


def kernel_size(a: Callable[[int], int], k: int, max_depth: int, horizon: int) -> int:
    return len(kernel_prefixes(a, k, max_depth, horizon))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_composition_law() -> None:
    """Verify (a_{i,r})_{j,s} = a_{i+j, k^i s + r} numerically."""
    print("=" * 70)
    print("Decimation semigroup law:  (a_{i,r})_{j,s} = a_{i+j, k^i s + r}")
    print("=" * 70)
    k = 3
    a = thue_morse
    for (i, r, j, s) in [(1, 2, 2, 5), (2, 1, 1, 0), (0, 0, 3, 7)]:
        lhs = decimate(decimate(a, k, i, r), k, j, s)
        rhs = decimate(a, k, i + j, k ** i * s + r)
        ok = prefix(lhs, 40) == prefix(rhs, 40)
        print(f"  k={k}  (i,r,j,s)=({i},{r},{j},{s})  ->  match: {ok}")
    print()


def demo_thue_morse_kernel() -> None:
    """Show the 2-kernel of Thue-Morse stabilizes at exactly 2 elements."""
    print("=" * 70)
    print("Thue-Morse 2-kernel is exactly {t, t+1}  (two states)")
    print("=" * 70)
    for depth in range(0, 8):
        size = kernel_size(thue_morse, k=2, max_depth=depth, horizon=64)
        print(f"  max depth {depth}:  distinct decimations = {size}")
    # Identify the two decimations explicitly.
    t = prefix(thue_morse, 16)
    t_plus_1 = tuple((1 - x) for x in t)  # complement in Z/2
    print(f"  t       (first 16): {t}")
    print(f"  t + 1   (first 16): {t_plus_1}")
    print()


def demo_other_sequences() -> None:
    """Kernel sizes for several classical automatic sequences."""
    print("=" * 70)
    print("Probed 2-kernel sizes of classical automatic sequences")
    print("=" * 70)
    seqs = {
        "Thue-Morse": thue_morse,
        "Rudin-Shapiro": rudin_shapiro,
        "Paperfolding": lambda n: paperfolding(n + 1),  # shift to start at 1
    }
    for name, a in seqs.items():
        sizes = [kernel_size(a, 2, d, 64) for d in range(2, 8)]
        print(f"  {name:16s} kernel sizes (depth 2..7): {sizes}")
    print()


def demo_non_automatic() -> None:
    """A_n = n has an unbounded kernel: not automatic."""
    print("=" * 70)
    print("Non-automatic witness:  A_n = n  (kernel keeps growing)")
    print("=" * 70)
    for depth in range(0, 6):
        size = kernel_size(identity_seq, k=2, max_depth=depth, horizon=32)
        print(f"  max depth {depth}:  distinct decimations = {size}")
    print("  (Finite-range theorem: an automatic sequence takes finitely many")
    print("   values, but A_n = n takes infinitely many -> not automatic.)")
    print()


def demo_closure() -> None:
    """Output coding and pointwise product preserve small kernels."""
    print("=" * 70)
    print("Closure: output coding and pointwise product stay finite-kernel")
    print("=" * 70)
    # Output coding: t -> (-1)^t  (parity to sign)
    sign_from_t = lambda n: -1 if thue_morse(n) == 1 else 1
    assert prefix(sign_from_t, 32) == prefix(thue_morse_sign, 32)
    print(f"  parity->sign coding kernel size: "
          f"{kernel_size(thue_morse_sign, 2, 6, 64)}  (matches Thue-Morse)")
    # Pointwise product of Thue-Morse and Rudin-Shapiro (values in {0,1}).
    prod = lambda n: thue_morse(n) * rudin_shapiro(n)
    print(f"  (Thue-Morse * Rudin-Shapiro) kernel size: "
          f"{kernel_size(prod, 2, 7, 64)}  (finite)")
    print()


def demo_parity_sign_dictionary() -> None:
    """Verify t_n = 0 <=> eps_n = +1 and t_n = 1 <=> eps_n = -1."""
    print("=" * 70)
    print("Parity <-> sign dictionary")
    print("=" * 70)
    ok = all(
        (thue_morse(n) == 0) == (thue_morse_sign(n) == 1)
        and (thue_morse(n) == 1) == (thue_morse_sign(n) == -1)
        for n in range(1000)
    )
    print(f"  dictionary holds for n in [0, 1000): {ok}")
    print(f"  n:      {[n for n in range(12)]}")
    print(f"  t_n:    {[thue_morse(n) for n in range(12)]}")
    print(f"  eps_n:  {[thue_morse_sign(n) for n in range(12)]}")
    print()


def main() -> None:
    demo_composition_law()
    demo_thue_morse_kernel()
    demo_other_sequences()
    demo_non_automatic()
    demo_closure()
    demo_parity_sign_dictionary()


if __name__ == "__main__":
    main()
