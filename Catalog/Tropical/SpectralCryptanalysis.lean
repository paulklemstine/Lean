/-
# Tropical Spectral Cryptanalysis

This file formalizes the core theorems connecting tropical (min-plus) spectral
theory to exponent recovery, establishing the mathematical foundation for
**spectral cryptanalysis over idempotent semirings**.

## Main Results

* `tropical_scalar_diag_pow` — The n-th tropical power of a scalar diagonal matrix
  has diagonal entries `trop(n • λ)`, establishing exact affine diagonal growth.

* `tropical_pow_diag_recovers_exponent` — Equality of diagonal entries of tropical
  matrix powers forces equality of exponents when the tropical eigenvalue is nonzero.
  This is the core "eigenvalue attack" theorem.

* `tropical_diag_mul` — Tropical diagonal matrices multiply by adding entries.

* `eventual_affine_diag_determines_exponent` — Arithmetic shell: if an observed
  diagonal value satisfies d = a * λ + c with λ ≠ 0, the exponent a is uniquely
  determined.

## Tropical Convention

We use Mathlib's `Tropical` type, which follows the **min-plus** convention:
- Tropical addition: `trop a + trop b = trop (min a b)`
- Tropical multiplication: `trop a * trop b = trop (a + b)`
- Tropical zero (additive identity): `trop ⊤`
- Tropical one (multiplicative identity): `trop 0`

The base type is `WithTop ℝ`, giving `Tropical (WithTop ℝ)` the structure of a
commutative semiring. Matrix powers use the standard semiring matrix multiplication,
which over `Tropical (WithTop ℝ)` becomes tropical matrix multiplication.

## Cryptanalytic Interpretation

If a tropical matrix `G` has tropical eigenvalue `λ`, then observing a diagonal entry
`d = (G^a)_{ii}` constrains the secret exponent `a` via `a = (d - c) / λ`. For scalar
diagonal matrices, this constraint is exact: the exponent is uniquely determined.
-/

import Mathlib

open Matrix Tropical

noncomputable section

/-! ## Infrastructure: Tropical Diagonal Matrix Operations -/

/-- The tropical n-th power of a scalar value: `(trop r)^n = trop (n • r)`.
In the tropical semiring, multiplication is addition, so iterated multiplication
(powering) becomes iterated addition (scalar multiplication). -/
theorem tropical_trop_pow_eq_nsmul {R : Type*} [AddMonoid R] {r : R} {n : ℕ} :
    (Tropical.trop r) ^ n = Tropical.trop (n • r) := by
  induction n with
  | zero => simp [pow_zero]
  | succ n ih =>
    rw [pow_succ, ih, Tropical.trop_mul_def, untrop_trop, untrop_trop, _root_.succ_nsmul]

/-- Tropical diagonal matrix multiplication: multiplying two tropical diagonal matrices
adds their diagonal entries. This is the fundamental closure property of the
tropical diagonal semigroup. -/
theorem tropical_diag_mul (m : ℕ) (a b : WithTop ℝ) :
    (Matrix.diagonal fun _ : Fin m => Tropical.trop a) *
    (Matrix.diagonal fun _ : Fin m => Tropical.trop b) =
    (Matrix.diagonal fun _ : Fin m => Tropical.trop (a + b)) := by
  rw [Matrix.diagonal_mul_diagonal]; congr 1

/-! ## Core Theorem: Exact Affine Diagonal Growth -/

/-- **Tropical Scalar Diagonal Power Theorem.**
The n-th tropical power of a scalar diagonal matrix `diag(trop r)` has diagonal
entries `trop(n • r)`.

In the tropical semiring, multiplication is ordinary addition, so the
n-th power of `trop r` is `trop (n • r)` — the n-fold sum of r. For finite r,
this equals `trop (n * r)`, establishing exact affine growth of diagonal entries
as a function of the exponent n.

This is the formal foundation of the tropical eigenvalue attack: the exponent `n`
appears linearly in the diagonal entries of `G^n`. -/
theorem tropical_scalar_diag_pow (m : ℕ) (r : WithTop ℝ) (n : ℕ) (i : Fin m) :
    ((Matrix.diagonal fun _ : Fin m => Tropical.trop r) ^ n) i i =
    Tropical.trop (n • r) := by
  rw [Matrix.diagonal_pow, Matrix.diagonal_apply_eq, Pi.pow_apply,
      tropical_trop_pow_eq_nsmul]

/-- Specialized version for finite values: the diagonal entry of the n-th tropical
power of `diag(trop(↑λ))` is `trop(↑(n * λ))`. -/
theorem tropical_scalar_diag_pow_real (m : ℕ) (lam : ℝ) (n : ℕ) (i : Fin m) :
    ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ n) i i =
    Tropical.trop (((n : ℝ) * lam : ℝ) : WithTop ℝ) := by
  rw [tropical_scalar_diag_pow]
  congr 1
  rw [← WithTop.coe_nsmul, nsmul_eq_mul]

/-! ## Exponent Recovery Theorems -/

/-- **Tropical Eigenvalue Attack Theorem (Exponent Recovery).**
If the tropical eigenvalue `λ` is nonzero (i.e., the underlying real value is nonzero),
then equality of diagonal entries in tropical matrix powers forces equality of exponents.

This is the central cryptanalytic result: observing `(G^a)_{ii} = (G^b)_{ii}` for a
scalar diagonal matrix with nonzero tropical eigenvalue implies `a = b`. The secret
exponent cannot be hidden. -/
theorem tropical_pow_diag_recovers_exponent
    {m : ℕ} [NeZero m] (lam : ℝ) (hlam : lam ≠ 0)
    {a b : ℕ}
    (hobs :
      ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ a) ⟨0, NeZero.pos m⟩
        ⟨0, NeZero.pos m⟩ =
      ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ b) ⟨0, NeZero.pos m⟩
        ⟨0, NeZero.pos m⟩) :
    a = b := by
  rw [tropical_scalar_diag_pow_real, tropical_scalar_diag_pow_real] at hobs
  have h := Tropical.trop_injective hobs
  have h2 : ((a : ℝ) * lam : ℝ) = ((b : ℝ) * lam : ℝ) := by exact_mod_cast h
  have h3 : (a : ℝ) = (b : ℝ) := by
    field_simp at h2
    linarith
  exact_mod_cast h3

/-- Variant using positive eigenvalue hypothesis. -/
theorem tropical_pow_diag_recovers_exponent_pos
    {m : ℕ} [NeZero m] (lam : ℝ) (hlam : 0 < lam)
    {a b : ℕ}
    (hobs :
      ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ a) ⟨0, NeZero.pos m⟩
        ⟨0, NeZero.pos m⟩ =
      ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ b) ⟨0, NeZero.pos m⟩
        ⟨0, NeZero.pos m⟩) :
    a = b :=
  tropical_pow_diag_recovers_exponent lam (ne_of_gt hlam) hobs

/-! ## Arithmetic Exponent Determination -/

/-- **Arithmetic shell for exponent recovery.**
If an observed diagonal value satisfies `d = a * λ + c` with `λ ≠ 0`, then
the exponent `a` equals `(d - c) / λ`. -/
theorem eventual_affine_diag_determines_exponent
    {a : ℕ} {lam c d : ℝ}
    (hlam : lam ≠ 0)
    (hdiag : d = (a : ℝ) * lam + c) :
    (a : ℝ) = (d - c) / lam := by
  field_simp
  linarith

/-- **Exponent uniqueness from affine diagonal law.**
If two exponents produce the same diagonal observation under the same affine law,
they must be equal. -/
theorem affine_diag_exponent_unique
    {a b : ℕ} {lam c : ℝ}
    (hlam : lam ≠ 0)
    (heq : (a : ℝ) * lam + c = (b : ℝ) * lam + c) :
    a = b := by
  have h1 : (a : ℝ) * lam = (b : ℝ) * lam := by linarith
  have h2 : (a : ℝ) = (b : ℝ) := by
    field_simp at h1; linarith
  exact_mod_cast h2

/-! ## Exponent Bounds -/

/-- **Exact exponent recovery from observed diagonal entry.**
If `d = a * λ` with `λ > 0`, then `a = ⌊d / λ⌋`. -/
theorem exponent_exact_from_observed_diag
    {a : ℕ} {lam d : ℝ}
    (hlam : 0 < lam)
    (hdiag : d = (a : ℝ) * lam) :
    a = Nat.floor (d / lam) := by
  rw [hdiag, mul_div_cancel_right₀ _ (ne_of_gt hlam)]
  exact (Nat.floor_natCast a).symm

/-! ## Monotonicity of Tropical Powers -/

/-- Tropical diagonal entries are distinct for different exponents when `λ ≠ 0`.
Higher exponents produce different diagonal values, making
the exponent observable from any single diagonal entry. -/
theorem tropical_diag_pow_strict_mono
    {m : ℕ} [NeZero m] (lam : ℝ) (hlam : lam ≠ 0) (i : Fin m)
    {a b : ℕ} (hab : a ≠ b) :
    ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ a) i i ≠
    ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ b) i i := by
  rw [tropical_scalar_diag_pow_real, tropical_scalar_diag_pow_real]
  intro h
  apply hab
  have h2 := Tropical.trop_injective h
  have h3 : ((a : ℝ) * lam : ℝ) = ((b : ℝ) * lam : ℝ) := by exact_mod_cast h2
  have h4 : (a : ℝ) = (b : ℝ) := by field_simp at h3; linarith
  exact_mod_cast h4

/-- The map `n ↦ (G^n)_{ii}` is injective for scalar diagonal tropical matrices
with nonzero eigenvalue. This is the function-level statement of the eigenvalue attack. -/
theorem tropical_diag_pow_injective
    {m : ℕ} [NeZero m] (lam : ℝ) (hlam : lam ≠ 0) (i : Fin m) :
    Function.Injective (fun n : ℕ =>
      ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ n) i i) := by
  intro a b hab
  by_contra h
  exact tropical_diag_pow_strict_mono lam hlam i h hab

/-! ## Bridge to Cryptanalysis -/

/-- **Exponent determination theorem (set-theoretic).**
Given a known positive eigenvalue `λ`, for any observed diagonal value `d`,
there exists at most one exponent producing `d`. This is the set-theoretic
formulation of the eigenvalue attack. -/
theorem tropical_exponent_at_most_one
    {m : ℕ} [NeZero m] (lam : ℝ) (hlam : lam ≠ 0)
    (d : Tropical (WithTop ℝ)) :
    Set.Subsingleton
      {n : ℕ | ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ n)
        ⟨0, NeZero.pos m⟩ ⟨0, NeZero.pos m⟩ = d} := by
  intro a ha b hb
  simp only [Set.mem_setOf_eq] at ha hb
  by_contra h
  exact tropical_diag_pow_strict_mono lam hlam ⟨0, NeZero.pos m⟩ h (ha.trans hb.symm)

/-- **Tropical spectral fingerprint: the exponent is linearly encoded.**
For any two distinct exponents, the diagonal entries of their tropical powers
are distinct. Combined with the affine formula `(G^n)_{ii} = trop(n * λ)`,
this shows the exponent `n` is a linear invariant of the observable diagonal. -/
theorem tropical_spectral_fingerprint_injective
    {m : ℕ} [NeZero m] (lam : ℝ) (hlam : lam ≠ 0) :
    Function.Injective (fun n : ℕ =>
      ((Matrix.diagonal fun _ : Fin m => Tropical.trop (lam : WithTop ℝ)) ^ n)
        ⟨0, NeZero.pos m⟩ ⟨0, NeZero.pos m⟩) :=
  tropical_diag_pow_injective lam hlam ⟨0, NeZero.pos m⟩

/-- **Tropical mirror theorem** (from catalog): `max a a = a`. -/
theorem tropical_mirror_theorem (a : ℝ) : max a a = a := max_self a

end