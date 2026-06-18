# Summary of changes for run 7e70bf8f-bdf7-430b-83fa-decc8df82797
# Berggren Tropical Rank: Formalization Complete

## Summary

I carefully analyzed the proposed conjecture that tropical rank of Berggren path products bounds ω(c) (the number of distinct prime factors of the hypotenuse), and **proved the conjecture is false** with a machine-verified counterexample in Lean 4.

## The Fatal Flaw

The conjecture claims tropRank(T(M)) ≥ ω(c) for 3×3 Berggren matrix products. But tropical rank of any n×n matrix is at most n **by definition** (it's the largest k such that some k×k submatrix is tropically non-singular). Since the Berggren matrices are 3×3, tropRank ≤ 3 always. Meanwhile, ω(c) is unbounded: every product of distinct primes ≡ 1 (mod 4) is a valid hypotenuse of a primitive Pythagorean triple, and the Berggren tree covers all such triples.

## The Counterexample

At depth 6, the Berggren path B⁴·A·B produces the primitive triple **(70623, 70664, 99905)** where:
- 70623² + 70664² = 99905² ✓
- gcd(70623, 70664) = 1 ✓ 
- 99905 = 5 · 13 · 29 · 53, so ω(99905) = 4 > 3 ≥ tropRank

## What IS Formally Verified (all sorry-free)

The file `Pythagorean/Berggren/BerggrenTropicalRank.lean` contains:

1. **Berggren matrix definitions** (A, B, C) and the word/path type
2. **Pythagorean preservation** — all three matrices preserve a² + b² = c² (proven by `nlinarith`)
3. **Determinants** — det(A) = 1, det(B) = -1, det(C) = 1 
4. **Lorentz form preservation** — Xᵀ·Q·X = Q for Q = diag(1,1,-1)
5. **Single-step computations** — A·(3,4,5) = (5,12,13), B·(3,4,5) = (21,20,29), C·(3,4,5) = (15,8,17), all with prime hypotenuses
6. **Tropical semiring definitions** — tropicalize, tropDet, tropNonsingular, tropRank
7. **The dimension bound** — tropRank ≤ n for n×n matrices
8. **The counterexample** — full verification that ω(99905) = 4 > 3, with the triple exhibited as a concrete Berggren path output
9. **`main_conjecture_false`** — the formal disproof

## Corrections to the Brief

- (7,24,25) is at depth **2** (path A²), not depth 1. Depth-1 triples are (5,12,13), (21,20,29), (15,8,17).
- The tropicalization map is NOT a semiring homomorphism from (ℤ,+,·) to the tropical semiring.
- The conjecture appeared to work only because ω(c) ≤ 3 happens to hold for all triples up to depth 5. It breaks at depth 6.

## Companion Document

`Pythagorean/Berggren/TROPICAL_RANK_ANALYSIS.md` contains a detailed mathematical analysis, including discussion of what modified conjectures might be salvageable.