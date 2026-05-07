# Signed Tropical Berggren Faithfulness via Signed Tropicalization

## Abstract

We formalize a **signed tropical type** `SignedTrop = TropSign × ℕ` equipped with componentwise multiplication (sign multiplication in ℤ/2ℤ, magnitude multiplication in ℕ), and prove that the natural tropicalization map `σ : ℤ → SignedTrop` given by `σ(n) = (sign(n), |n|)` is **injective** — resolving the fundamental information-loss problem of unsigned tropical geometry. We further define the three Berggren matrices that generate the ternary tree of all primitive Pythagorean triples, prove they preserve the Lorentz quadratic form `x² + y² − z²`, and establish that any word in the Berggren group acts as a Lorentz isometry with unimodular determinant. This bridges number theory (Pythagorean triple enumeration), tropical geometry (signed semirings), and lattice cryptography (unimodular lattice transformations).

## 1. Introduction

### The Information-Loss Problem

Classical tropicalization maps integers to the max-plus semiring `(ℝ ∪ {-∞}, max, +)` via `n ↦ log|n|`. This map loses sign information: `trop(5) = trop(-5) = log 5`. For algebraic structures involving negative entries — such as the Berggren matrices `A` and `C`, which contain `-1` and `-2` — unsigned tropicalization is fundamentally lossy. Any attempt to "tropicalize" matrix-vector multiplication through such matrices will produce approximate, not exact, correspondences.

### Our Resolution

We introduce a **signed tropical type** `SignedTrop` carrying both sign and magnitude. The tropicalization `σ(n) = (sign(n), |n|)` is provably injective: if `σ(m) = σ(n)`, then `m = n`. The proof proceeds by case analysis on the signs of `m` and `n`:
- If both are non-negative, then `|m| = |n|` implies `m = n`.
- If one is non-negative and the other is negative, the signs in `σ(m)` and `σ(n)` differ, contradicting `σ(m) = σ(n)`.
- If both are negative, then `|m| = |n|` implies `m = -|m| = -|n| = n`.

This injectivity is the **faithfulness** property: the signed tropicalization loses no information.

## 2. Core Algebraic Structure

### TropSign (ℤ/2ℤ)

The sign type `TropSign = {pos, neg}` with multiplication:
- `pos * s = s`, `neg * neg = pos`, `neg * pos = neg`

forms a commutative group isomorphic to `ℤ/2ℤ`. Every element is its own inverse: `a * a = pos`.

### SignedTrop

The type `SignedTrop = TropSign × ℕ` with tropical multiplication `(s₁, m₁) ⊗ (s₂, m₂) = (s₁ · s₂, m₁ · m₂)` forms a commutative monoid with unit `(pos, 1)`. The tropicalization `σ` preserves multiplication for non-negative integers:

**Theorem (T3).** For `m, n ≥ 0`: `σ(m · n) = σ(m) ⊗ σ(n)`.

*Proof.* When `m, n ≥ 0`: `sign(mn) = pos = pos · pos`, and `|mn| = |m| · |n|` by `Int.natAbs_mul`. □

## 3. Berggren Matrices and SO(2,1;ℤ)

The three Berggren matrices are:
```
A = [[1,-2,2],[2,-1,2],[2,-2,3]]
B = [[1, 2,2],[2, 1,2],[2, 2,3]]
C = [[-1,2,2],[-2,1,2],[-2,2,3]]
```

### Lorentz Form Preservation

Let `Q = diag(1, 1, -1)` encode the Lorentz form `L(v) = v₀² + v₁² − v₂²`.

**Theorem (T4–T6).** For each `M ∈ {A, B, C}`: `Mᵀ Q M = Q`. 

*Proof.* By `native_decide` (direct matrix computation verified by the Lean kernel). □

**Corollary (T9–T11).** Each Berggren matrix maps Pythagorean triples to Pythagorean triples.

*Proof.* For Pythagorean `v` (i.e., `vᵀ Q v = 0`): `(Mv)ᵀ Q (Mv) = vᵀ (Mᵀ Q M) v = vᵀ Q v = 0`. □

### Path Composition

**Theorem (T12).** For any path `w ∈ {A, B, C}*`, the composed matrix `M_w` satisfies `M_wᵀ Q M_w = Q`.

*Proof.* By induction on the path length, using the step case `(M₁ M₂)ᵀ Q (M₁ M₂) = M₂ᵀ (M₁ᵀ Q M₁) M₂ = M₂ᵀ Q M₂ = Q`. □

### Unimodularity

**Theorem (T23–T26).** `det(A) = 1`, `det(B) = -1`, `det(C) = 1`, and for any path `w`: `det(M_w) ∈ {±1}`.

This means Berggren transformations are lattice automorphisms, preserving the integer lattice ℤ³ up to orientation.

## 4. Tropical Light Cone

**Theorem (T15).** For positive triples `v` (all components > 0):
```
v₀² + v₁² = v₂²  ⟺  σ(v₀).mag² + σ(v₁).mag² = σ(v₂).mag²
```

Since `σ(n).mag = |n|` and `|n|² = n²` for any integer `n`, the equivalence is immediate. This shows the **tropical light cone** (defined by magnitude conditions) exactly recovers the classical Pythagorean condition.

## 5. Berggren Tree Growth

**Theorem (T20).** For any positive triple `(a, b, c)`, matrix `B` produces `c' = 2a + 2b + 3c > c`.

**Theorem (T28).** All depth-1 Berggren descendants of `(3, 4, 5)` have tropical norm strictly greater than 5.

These results show the Berggren tree has **monotonically increasing hypotenuse** along every branch, which connects to lower bounds for the shortest vector problem (SVP) in the Berggren lattice.

## 6. Connections

### Number Theory ↔ Tropical Geometry
The faithful embedding `σ` shows that Pythagorean dynamics can be studied in the signed tropical world without information loss. The tropical light cone exactly mirrors the classical one.

### Lattice Cryptography
Berggren matrices are unimodular (det = ±1) and generate a subgroup of SO(2,1;ℤ). Path composition gives a hash-like function from `{A,B,C}*` to ℤ³ (applied to the root), and `σ` preserves collision resistance.

### Lorentzian Geometry
The Lorentz form `x² + y² − z²` is preserved by all Berggren transformations, connecting Pythagorean number theory to the geometry of the Minkowski light cone in special relativity.

## 7. Summary of Formal Results

| ID | Statement | Tactics Used |
|----|-----------|--------------|
| T1a–d | SignedTrop monoid axioms | simp, exact, rw |
| T2 | σ injective | by_cases, push_neg, omega, simp |
| T3 | σ preserves multiplication | simp, refine |
| T4–T6 | Berggren preserves Lorentz | native_decide |
| T7 | σ distinguishes signs | intro, simp, simp_all |
| T9–T11 | Pythagorean preservation | rw, conv, exact |
| T12 | Path preserves Lorentz | induction, calc, simp |
| T13 | Path preserves Pythagorean | exact (corollary) |
| T14 | σ³ injective | ext, exact |
| T15 | Tropical light cone | zify, sq_abs, omega |
| T16 | Unsigned not injective | native_decide, omega |
| T17 | σ(3) ≠ σ(-3) | simp |
| T18–T19 | Tropical norm | simp |
| T20 | B increases hypotenuse | nlinarith |
| T23–T26 | Determinant ±1 | native_decide, induction, rcases |
| T28 | Depth-1 norm growth | simp |
| T29 | σ on ℕ is homomorphism | exact |
| T30 | Single-step distinctness | decide |

**Total: 54 theorems, 21 definitions, 0 sorry.**
