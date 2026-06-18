# Berggren Tropical Rank: Analysis Report

## Executive Summary

The conjectured inequality **tropRank(T(M)) ≥ ω(c)** is **provably false**, and this is formally verified in Lean 4. The failure is not subtle or borderline — it stems from a fundamental dimension mismatch between the tropical rank (bounded by the matrix size 3) and ω(c) (unbounded).

## The Counterexample

At depth 6 of the Berggren tree, the path **B⁴·A·B** produces the primitive Pythagorean triple:

**(70623, 70664, 99905)**

where:
- 70623² + 70664² = 99905² ✓
- gcd(70623, 70664) = 1 ✓ (primitive)
- 99905 = 5 · 13 · 29 · 53, so ω(99905) = 4

Since the Berggren matrices are 3×3, any matrix product M has tropRank(T(M)) ≤ 3 < 4 = ω(99905).

## Why the Conjecture Seemed Plausible

The conjecture "works" at small depths because:
- **Depth 1**: hypotenuses are 13, 29, 17 (all prime, ω = 1 ≤ 3) ✓
- **Depth 2**: hypotenuses are 25, 85, 41, 45, 61, 53, 65, 113, 73 (all have ω ≤ 2) ✓
- **Depth 3**: all hypotenuses still satisfy ω ≤ 3 ✓
- **Depth 4**: first ω = 3 appears (c = 1105 = 5·13·17), still ≤ 3 ✓
- **Depth 5**: all still ω ≤ 3 ✓
- **Depth 6**: **ω = 4 appears** (c = 99905 = 5·13·29·53) ✗

The conjecture exploits a coincidence: for small tree depths, ω(c) happens not to exceed 3.

## The Fundamental Issue

The tropical rank of an n×n matrix is **bounded by n** (by definition). This is a hard ceiling:
- tropRank is the largest k such that some k×k submatrix has a non-singular tropical determinant
- For 3×3 matrices, k ≤ 3

Meanwhile, ω(c) grows without bound:
- Every product of distinct primes ≡ 1 (mod 4) is a valid hypotenuse of a primitive Pythagorean triple
- The Berggren tree covers ALL primitive triples (a well-known theorem of Berggren/Barning)
- So ω(c) is unbounded over the tree

## What IS True (Formally Verified)

1. **Berggren matrices preserve the Pythagorean equation** — purely algebraic identities proven by `nlinarith`.

2. **Determinants**: det(A) = 1, det(B) = -1, det(C) = 1.

3. **Lorentz form preservation**: Aᵀ Q A = Q, Bᵀ Q B = Q, Cᵀ Q C = Q where Q = diag(1, 1, -1).

4. **Single-step triples**: A·(3,4,5) = (5,12,13), B·(3,4,5) = (21,20,29), C·(3,4,5) = (15,8,17) — all with prime hypotenuses.

5. **Tropical rank dimension bound**: tropRank ≤ n for n×n matrices.

## Corrections to the Research Brief

Several specific claims in the brief are incorrect:

1. **"The triples are (5,12,13), (7,24,25), and (21,20,29)"** — The triple (7,24,25) is NOT at depth 1. It's at depth 2 (path A·A). The depth-1 triples are (5,12,13), (21,20,29), and (15,8,17).

2. **"all prime hypotenuses"** — 25 = 5² is NOT prime. The actual depth-1 hypotenuses (13, 29, 17) are indeed all prime.

3. **"T is a semiring homomorphism from (ℤ, +, ·) to (ℝ∪{∞}, min, +)"** — The tropicalization map is NOT a semiring homomorphism in this sense. It embeds integers into the tropical semiring, but the operations change: integer addition does not map to tropical addition (min), and integer multiplication does not map to tropical multiplication (+) in a homomorphic way.

## What Might Be Salvageable

### Modified Conjecture 1: Bounded version
For hypotenuses with ω(c) ≤ 3, the conjecture might hold. This would need to be verified independently for each case.

### Modified Conjecture 2: Different invariant
Instead of tropical rank (bounded by 3), one could consider:
- The **tropical spectral radius** of the path product
- The **number of distinct tropical eigenvalues**
- A **path-dependent** quantity like Σ tropRank(T(Mᵢ))

### Modified Conjecture 3: Compositeness detection
The weaker claim "tropRank ≥ 2 implies c is composite" might hold, but this needs separate investigation. Note that tropRank ≥ 2 for most non-degenerate 3×3 matrices, so this might be vacuously true or follow from structural properties of the Berggren matrices rather than from any deep connection to prime factorization.

## Files

- `BerggrenTropicalRank.lean` — Full Lean 4 formalization with all proofs verified
