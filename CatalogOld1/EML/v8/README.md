# EML–Pythagorean Bridge v8: New Machine-Verified Theorems

## Files

### `BerggrenPellRecurrence.lean` (16 theorems)
- B₂-branch iteration and Pell recurrence verification
- Cayley-Hamilton theorem for B₂
- Near-isosceles property: |a-b| = 1 for all B₂-branch triples
- B₂ eigenvector (1,-1,0) with eigenvalue -1

### `BerggrenTreeCompleteness.lean` (22 theorems)
- Full parent descent infrastructure
- Parent hypotenuse positive and strictly decreasing
- Sign analysis (not both σ₁ ≤ 0 and σ₂ ≤ 0)
- Root classification (c = 5 ⟹ triple is (3,4,5) or (4,3,5))
- Forward-inverse cancellation for all branches
- Child hypotenuse growth

### `BerggrenUnipotentPowers.lean` (15 theorems)
- **Correction:** Nilpotency index of B₁ is 3, not 2
- (B₁-I)³ = 0, (B₁-I)² ≠ 0
- Explicit powers B₁², B₁³
- A-branch triples: (5,12,13), (7,24,25), (9,40,41)
- Conjugacy B₃ = S·B₁·S, S² = I

### `BerggrenLorentzGroup.lean` (18 theorems)
- All matrices preserve Lorentz form BᵀQB = Q
- Products also preserve: (B₁B₂)ᵀQ(B₁B₂) = Q, etc.
- Determinant structure: B₁,B₃ ∈ SO(2,1), B₂ ∈ O(2,1)\SO(2,1)
- Non-commutativity of all three pairs
- Trace classification (parabolic vs hyperbolic)
- Cayley-Hamilton for both B₁ and B₂

### `BerggrenSternBrocot.lean` (14 theorems)
- Euclid parametrization: triples are always Pythagorean
- 2×2 Berggren matrices: determinants ±1
- M₃ = T² (square of Stern-Brocot right step)
- M₃⁻¹·M₁ = S (modular group generator)
- Theta group connection to SL(2,ℤ)

## Total: 85+ theorems, 0 sorries
