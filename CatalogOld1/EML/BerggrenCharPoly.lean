import Mathlib

/-!
# Berggren Characteristic Polynomial Classification (Direction #23)

We formalize the characteristic polynomial structure of the Berggren matrices:
- B₁ and B₃ share the characteristic polynomial (x-1)³
- B₂ has characteristic polynomial x³ - 5x² - 5x + 1 with roots {-1, 3±2√2}
- B₁ and B₃ are conjugate via the leg-swap permutation matrix S

This answers the open question: "Why do B₁ and B₃ have the same characteristic
polynomial despite being different matrices?"

## Answer: B₃ = S · B₁ · S⁻¹ where S swaps legs (a ↔ b), and S = S⁻¹.
-/

open Matrix

/-! ## §1. Matrix Definitions -/

def B₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def B₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def B₃ : Matrix (Fin 3) (Fin 3) ℤ := !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

/-- The leg-swap matrix S: (a,b,c) ↦ (b,a,c).
    Since the Pythagorean equation a²+b²=c² is symmetric in a,b,
    S is a symmetry of the null cone. -/
def S_swap : Matrix (Fin 3) (Fin 3) ℤ := !![0, 1, 0; 1, 0, 0; 0, 0, 1]

/-! ## §2. Determinant Structure -/

theorem det_B₁ : B₁.det = 1 := by native_decide
theorem det_B₂ : B₂.det = -1 := by native_decide
theorem det_B₃ : B₃.det = 1 := by native_decide

/-! ## §3. Trace Invariants -/

theorem trace_B₁ : B₁.trace = 3 := by native_decide
theorem trace_B₂ : B₂.trace = 5 := by native_decide
theorem trace_B₃ : B₃.trace = 3 := by native_decide

/-- B₁ and B₃ have identical trace invariants. -/
theorem B₁_B₃_same_invariants :
    B₁.trace = B₃.trace ∧ B₁.det = B₃.det := by
  exact ⟨by native_decide, by native_decide⟩

/-! ## §4. Conjugation: B₃ = S · B₁ · S

The answer to the open question: B₁ and B₃ are similar via the leg-swap
permutation matrix S = [[0,1,0],[1,0,0],[0,0,1]]. This simply swaps a ↔ b. -/

/-- S is an involution: S² = I -/
theorem S_swap_involution : S_swap * S_swap = (1 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

/-- **Main theorem:** B₃ = S · B₁ · S (since S = S⁻¹) -/
theorem B₃_conjugate_B₁ : S_swap * B₁ * S_swap = B₃ := by native_decide

/-- Equivalently: B₁ = S · B₃ · S -/
theorem B₁_conjugate_B₃ : S_swap * B₃ * S_swap = B₁ := by native_decide

/-- S preserves the Lorentz form (it's in O(2,1;ℤ)) -/
def Q_lor : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]

theorem S_lorentz : S_swapᵀ * Q_lor * S_swap = Q_lor := by native_decide

/-- det(S) = -1, so S is in O(2,1;ℤ) \ SO(2,1;ℤ) -/
theorem det_S : S_swap.det = -1 := by native_decide

/-- B₂ is NOT conjugate to B₁ via S (it maps to itself). -/
theorem B₂_self_conjugate : S_swap * B₂ * S_swap = B₂ := by native_decide

/-! ## §5. Nilpotency Structure

Since B₁ and B₃ have char poly (x-1)³, the matrix (B-I) is nilpotent of order 3. -/

/-- (B₁ - I)³ = 0 -/
theorem B₁_minus_I_cubed :
    (B₁ - 1) * (B₁ - 1) * (B₁ - 1) = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

/-- (B₁ - I)² ≠ 0, so nilpotency index is exactly 3 -/
theorem B₁_minus_I_sq_ne_zero :
    (B₁ - 1) * (B₁ - 1) ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

/-- (B₃ - I)³ = 0 -/
theorem B₃_minus_I_cubed :
    (B₃ - 1) * (B₃ - 1) * (B₃ - 1) = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

/-- (B₃ - I)² ≠ 0 -/
theorem B₃_minus_I_sq_ne_zero :
    (B₃ - 1) * (B₃ - 1) ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

/-! ## §6. B₂ Eigenvalue Structure

B₂ has eigenvalues -1, 3+2√2, 3-2√2. The char poly is x³ - 5x² - 5x + 1
= (x+1)(x² - 6x + 1), with the quadratic factor yielding the Pell roots. -/

/-- The Cayley-Hamilton theorem for B₂: B₂³ - 5B₂² - 5B₂ + I = 0 -/
theorem B₂_cayley_hamilton :
    B₂ * B₂ * B₂ - 5 • (B₂ * B₂) - 5 • B₂ + 1 = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide

/-! ## §7. Noncommutativity -/

/-- B₁ and B₃ do not commute -/
theorem B₁_B₃_noncommutative : B₁ * B₃ ≠ B₃ * B₁ := by native_decide

/-- B₁ and B₂ do not commute -/
theorem B₁_B₂_noncommutative : B₁ * B₂ ≠ B₂ * B₁ := by native_decide

/-- B₂ and B₃ do not commute -/
theorem B₂_B₃_noncommutative : B₂ * B₃ ≠ B₃ * B₂ := by native_decide

/-! ## §8. Lorentz Structure Verification -/

/-- All three matrices preserve the Lorentz form -/
theorem B₁_lorentz : B₁ᵀ * Q_lor * B₁ = Q_lor := by native_decide
theorem B₂_lorentz : B₂ᵀ * Q_lor * B₂ = Q_lor := by native_decide
theorem B₃_lorentz : B₃ᵀ * Q_lor * B₃ = Q_lor := by native_decide

/-! ## §9. B₂ is self-conjugate under S: it commutes with leg-swap

B₂ generates "balanced" triples where a ≈ b (near 45°). Swapping legs
leaves B₂ invariant, reflecting the fact that the B-branch produces
nearly-isosceles triangles. -/

/-! ## §10. Summary

### Answer to Direction #23:

B₁ and B₃ have the same characteristic polynomial (x-1)³ because they are
conjugate: B₃ = S·B₁·S where S is the leg-swap permutation (a,b,c) ↦ (b,a,c).

Geometrically, S exchanges the two legs of a right triangle, which corresponds
to reflecting across the 45° line in the (a,b) plane. Since the Pythagorean
equation a²+b²=c² is symmetric under a ↔ b, S is an isometry.

The A-branch generates triples leaning one way (b > a), the C-branch
generates their mirror images (a > b). They are literally reflections.

B₂ is fundamentally different: it is self-conjugate under S (commutes with
leg-swap), reflecting the fact that B-branch triples have nearly equal legs
(a ≈ b). Its eigenvalues {-1, 3±2√2} connect the tree to Pell equations.
-/
