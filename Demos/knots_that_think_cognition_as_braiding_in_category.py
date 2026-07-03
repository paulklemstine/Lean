"""
Cognitive Braids: numerical demonstration of the writhe as an information
invariant that detects creativity but is blind to confusion.

A braid word is a sequence of signed generators. We represent a generator
sigma_i by the integer (i+1) and its inverse sigma_i^{-1} by -(i+1). Thus:
    sigma_0        ->  1
    sigma_0^{-1}   -> -1
    sigma_1        ->  2
    sigma_1^{-1}   -> -2

We compute two complementary invariants:
    * writhe(w)      = signed crossing count (a homomorphism into the integers),
    * permutation(w) = the underlying permutation of the strands (into S_{n+1}).

The three archetypal cognitive braids:
    trivial   = []                          (in B_2, one generator sigma_0)
    creative  = [1, 1, 1]  = sigma_0^3      (in B_2)
    confused  = [1, -2, 1, -2] = (sigma_0 sigma_1^{-1})^2   (in B_3)

Results reproduced numerically:
    writhe(creative) = 3,   writhe(trivial) = 0,   writhe(confused) = 0,
    yet the confused braid has a nontrivial underlying permutation (a 3-cycle),
    so it is a genuinely nontrivial braid that the writhe cannot see.
"""

from __future__ import annotations

from typing import List, Dict


def writhe(word: List[int]) -> int:
    """Signed crossing count (exponent sum) of a braid word.

    Each positive generator contributes +1, each inverse contributes -1.
    This is a homomorphism, so the value depends only on the braid, not the word.
    """
    return sum(1 if letter > 0 else -1 for letter in word)


def underlying_permutation(word: List[int], strands: int) -> List[int]:
    """Underlying permutation of a braid word on the given number of strands.

    Returns a list p of length `strands` with p[k] = image of strand k.
    Each letter +-(i+1) applies the adjacent transposition (i, i+1).
    """
    p: List[int] = list(range(strands))
    for letter in word:
        i = abs(letter) - 1  # generator index; sign is irrelevant for the permutation
        p[i], p[i + 1] = p[i + 1], p[i]
    return p


def is_identity_permutation(p: List[int]) -> bool:
    """True iff p is the identity permutation."""
    return all(p[k] == k for k in range(len(p)))


def cycle_type(p: List[int]) -> List[int]:
    """Return the sorted list of cycle lengths of a permutation p."""
    n = len(p)
    seen = [False] * n
    lengths: List[int] = []
    for start in range(n):
        if seen[start]:
            continue
        length = 0
        j = start
        while not seen[j]:
            seen[j] = True
            j = p[j]
            length += 1
        lengths.append(length)
    return sorted(lengths, reverse=True)


def analyze(name: str, word: List[int], strands: int) -> Dict[str, object]:
    """Compute both invariants for one cognitive braid and print a report."""
    w = writhe(word)
    perm = underlying_permutation(word, strands)
    nontrivial_perm = not is_identity_permutation(perm)
    report: Dict[str, object] = {
        "name": name,
        "word": word,
        "strands": strands,
        "writhe": w,
        "permutation": perm,
        "permutation_cycle_type": cycle_type(perm),
        "permutation_nontrivial": nontrivial_perm,
    }
    print(f"--- {name} ---")
    print(f"  braid word           : {word}")
    print(f"  strands (n+1)        : {strands}")
    print(f"  writhe (exponent sum): {w}")
    print(f"  underlying perm      : {perm}  cycle type {cycle_type(perm)}")
    print(f"  permutation != id    : {nontrivial_perm}")
    print()
    return report


def main() -> None:
    print("Cognitive Braids: writhe detects creativity but is blind to confusion")
    print("=" * 70)
    print()

    trivial = analyze("trivial  (linear reasoning)  1", [], 2)
    creative = analyze("creative (insight)  sigma_0^3", [1, 1, 1], 2)
    confused = analyze(
        "confused (deliberation)  (sigma_0 sigma_1^-1)^2", [1, -2, 1, -2], 3
    )

    print("Verification of the main results:")
    print("-" * 70)

    assert creative["writhe"] == 3, "creative braid should have writhe 3"
    assert trivial["writhe"] == 0, "trivial braid should have writhe 0"
    assert confused["writhe"] == 0, "confused braid should have writhe 0"
    print("  writhe(creative) = 3  != 0          -> creativity is DETECTED")
    print("  writhe(confused) = 0  = writhe(trivial) -> confusion is INVISIBLE to writhe")

    # But the confused braid is genuinely nontrivial: nontrivial permutation.
    assert confused["permutation_nontrivial"], "confused braid must be nontrivial"
    assert confused["permutation_cycle_type"] == [3], "confused perm is a 3-cycle"
    assert not creative["permutation_nontrivial"] is False  # sanity
    print("  confused underlying permutation is a 3-cycle -> confused braid != identity")
    print()
    print("Conclusion: the writhe cannot distinguish the confused braid from the")
    print("trivial braid, yet the confused braid is genuinely nontrivial.")
    print()

    # Bonus: the writhe is a homomorphism (additive over concatenation).
    a = [1, 1, -2]
    b = [2, -1, 1]
    assert writhe(a + b) == writhe(a) + writhe(b)
    print(f"Homomorphism check: writhe({a}+{b}) = writhe(a)+writhe(b) = "
          f"{writhe(a)}+{writhe(b)} = {writhe(a + b)}")


if __name__ == "__main__":
    main()
