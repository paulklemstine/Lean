# Supplementary New Results: SPB Research Program

## Machine-Verified Theorems (Phase 2)

This supplement documents additional machine-verified results discovered and formalized during the second phase of the SPB research program.

---

## 1. Tropical SPB: Complete Structure Resolution

### Key Discovery: tropSPB(a,b) = −max(|a|, |b|)

**Theorem (tropSPB_eq_neg_max_abs, machine-verified):** For all a, b ∈ ℝ:

    tropSPB(a, b) = min(a, b) − max(0, a+b) = −max(|a|, |b|)

*Proof*: By exhaustive case analysis on the signs of a, b, and a+b, verified via `linarith` in Lean 4.

This dramatically simplifies the algebraic analysis of tropical SPB.

### Conjecture 14.4 Resolution

**Original Conjecture**: Tropical SPB is a quasigroup but not a group.

**Corrected Result**: Tropical SPB is a *commutative semigroup* — it IS associative (correcting the original conjecture), but has no identity element.

- **Commutative** ✓ (since max(|a|,|b|) = max(|b|,|a|))
- **Associative** ✓ (since max is associative: max(max(|a|,|b|), |c|) = max(|a|, max(|b|,|c|)))
- **No identity** ✓ (proved: no e exists with −max(|x|,|e|) = x for all x)
- **Idempotent on ℝ⁻**: tropSPB(x,x) = x for x ≤ 0
- **Anti-idempotent on ℝ⁺**: tropSPB(x,x) = −x for x > 0

The simplification to −max(|a|,|b|) reveals that tropical SPB extracts the "dominant magnitude" and negates it — a remarkably clean operation hiding in the tropicalization.

---

## 2. SPB Matrix Representation

### Matrix Encoding

**Definition**: M(a) = [[1, a], [−a, 1]] ∈ M₂(ℝ)

**Theorem (spbMatrix_mul, machine-verified)**:

    M(a) · M(b) = [[1−ab, a+b], [−(a+b), 1−ab]]

The SPB value spb(a,b) = (a+b)/(1−ab) is simply the ratio of entries (0,1)/(0,0).

### Invariants

| Property | Value | Significance |
|----------|-------|--------------|
| det(M(a)) | 1 + a² | Always positive |
| tr(M(a)) | 2 | Independent of a! |
| Eigenvalues | 1 ± ia | On the Gaussian integers |
| det(M(a)·M(b)) | (1+a²)(1+b²) | Multiplicative |

**Theorem (spbMatrix_trace, machine-verified)**: tr(M(a)) = 2 for all a ∈ ℝ.

This means all SPB matrices lie on the *trace-2 surface* in M₂(ℝ), which is a hyperboloid.

**Theorem (spbMatrix_mul_neg, machine-verified)**: M(a) · M(−a) = (1+a²) · I.

The inverse of M(a) is M(−a)/(1+a²), confirming that negation is the group inverse.

### Rotation Connection

The normalized matrix M(a)/√(1+a²) is the rotation matrix R(arctan(a)):

    R(θ) = [[cos θ, sin θ], [−sin θ, cos θ]]

This gives a direct proof that SPB composition corresponds to angle addition.

---

## 3. SPB Dynamics

### Fixed Point Theorem

**Theorem (spb_no_fixed_point, machine-verified)**: For a ≠ 0, the map T_a(x) = spb(x, a) has no fixed points.

*Proof*: spb(x,a) = x implies a(1+x²) = 0, which forces a = 0 since 1+x² > 0.

### Strict Monotonicity

**Theorem (spb_strict_mono_snd, machine-verified)**: When denominators are positive, spb(a, ·) is strictly increasing.

This follows from the difference identity:

    spb(a,b) − spb(a,c) = (b−c)(1+a²)/((1−ab)(1−ac))

### Orbit Structure

The orbit of T_a starting from 0 is {tan(n·arctan(a)) : n ∈ ℕ}. Key properties:

- **Periodic** iff arctan(a)/π ∈ ℚ
- **Dense in ℝ** (modulo poles) iff arctan(a)/π ∉ ℚ
- **Lyapunov exponent = 0** always (no chaos, since T_a conjugates to a rotation)

---

## 4. SPB and the Weierstrass Substitution

### Fundamental Connections

**Theorem (weierstrass_sin, machine-verified)**:

    spbH(t, t) = 2t/(1+t²) = sin(θ) where t = tan(θ/2)

**Theorem (spb_double_angle, machine-verified)**:

    spb(x, x) = 2x/(1−x²) = tan(2·arctan(x))

**Theorem (spb_triple_angle, machine-verified)**:

    spb(2x/(1−x²), x) = (3x − x³)/(1 − 3x²) = tan(3·arctan(x))

### Norm Composition Law

**Theorem (spb_norm_composition, machine-verified)**:

    (1 + spb(a,b)²) · (1−ab)² = (1+a²) · (1+b²)

This is the norm-multiplicativity of Gaussian integers in disguise: (1+ai)(1+bi) = (1−ab) + (a+b)i.

---

## 5. SPB over Integers

### Classification Results

For a, b ∈ ℤ, spb(a,b) ∈ ℤ iff (1−ab) | (a+b).

**Theorem (spb_one_integer_iff, machine-verified)**: spb(1, b) ∈ ℤ iff (1−b) | 2, giving b ∈ {−1, 0, 2, 3}.

| a | b | spb(a,b) | Integer? |
|---|---|----------|----------|
| 0 | b | b | Always ✓ |
| a | −a | 0 | Always ✓ |
| 1 | 2 | −3 | ✓ |
| 2 | 3 | −1 | ✓ |
| 1 | 3 | −2 | ✓ |
| 2 | −3 | −1/7 | ✗ |
| 3 | 5 | 8/−14 | ✗ |

### Machin Identity Verification

The integer arithmetic behind Machin's formula was fully verified:

- tan(2·arctan(1/5)) = 5/12 (verified: 12²−5² = 119)
- tan(4·arctan(1/5)) = 120/119 (verified: 119²−120² = −239)
- spb(120/119, −1/239) = 1 (verified: 120·239 − 119 = 119·239 + 120)

---

## 6. Finite Fields: The p±1 Law

### Quadratic Residue Connection

**Theorem (neg_one_qr_iff_mod4, machine-verified)**: −1 is a quadratic residue mod p iff p ≡ 1 (mod 4).

This is the algebraic key to the p±1 law:

- When p ≡ 1 (mod 4): i = √(−1) ∈ 𝔽_p, so Cayley transform stays in 𝔽_p*, giving SPB group order p−1
- When p ≡ 3 (mod 4): i ∉ 𝔽_p, so Cayley transform maps to 𝔽_{p²}* norm-1 subgroup, giving order p+1

Computationally verified for all 45 odd primes < 200 with 100% match.

---

## Summary of New Machine-Verified Results

| File | Theorems | Key Result |
|------|----------|------------|
| SPBTropicalAlgebra.lean | 8 | tropSPB = −max(\|a\|, \|b\|) |
| SPBMoebius.lean | 10 | Matrix representation, trace = 2 |
| SPBDynamics.lean | 9 | No fixed points, strict monotonicity |
| SPBWeierstrass.lean | 9 | Norm composition, Brahmagupta-Fibonacci |
| SPBIntegers.lean | 15 | Integer classification, Machin arithmetic |
| SPBGroupTheory.lean | 10 | Difference identity, Lipschitz bounds |
| SPBAnalysis.lean | 5 | Continuity, Cayley unitarity |
| SPBFiniteFields.lean | 6 | QR criterion, χ₋₄ values |

**Total new theorems: 72**
**Sorry statements: 0**

---

*All theorems formalized in Lean 4 with Mathlib v4.28.0.*
*Files located in `EML/StereographicBridge/Research/NewResults/`.*
