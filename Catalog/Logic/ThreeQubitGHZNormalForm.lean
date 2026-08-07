import Mathlib

/-!
# The GHZ normal form: Cayley's hyperdeterminant detects the generic SLOCC orbit

This file continues the study of three-qubit amplitude tensors begun in
`Catalog/Combinatorics/ThreeQubitHyperdeterminant.lean`.  That file proved that Cayley's
`2 × 2 × 2` hyperdeterminant is a relative `SL(2)^{×3}` invariant and used it to *separate*
the GHZ state from the W state.  Here we prove the **converse**, the hard half of the
Dür–Vidal–Cirac classification of three-qubit SLOCC orbits:

> a three-qubit amplitude tensor `ψ` is SLOCC equivalent to the GHZ state **iff**
> `hyperdet ψ ≠ 0`.

The core definitions (`Amp`, `hyperdet`, `actA`, `actB`, `actC`, `localAct`, `c2`, `ghz`,
`wState`) are reproduced verbatim from the catalog file so that this file stays
self-contained; all new material lives in the namespace `ThreeQubitGHZ`.

## Method

Write `M₀`, `M₁ : Matrix (Fin 2) (Fin 2) ℂ` for the two *Alice slices* of `ψ`.  The pencil
determinant `det (x M₀ + y M₁)` is the binary quadratic form

`qform ψ x y = d₀ ψ · x² + pencilB ψ · x y + d₁ ψ · y²`,

and the key algebraic identity (`hyperdet_eq_discriminant`)

`hyperdet ψ = pencilB ψ ^ 2 - 4 · d₀ ψ · d₁ ψ`

says that the hyperdeterminant is exactly the **discriminant of the Alice pencil**.  Hence
`hyperdet ψ ≠ 0` means the pencil has two *distinct* singular members.  Moving those two
members onto the coordinate slices by an invertible `A` (`exists_diagonalizing_A`) makes
both slices rank one and nonzero; factoring each as `u ⊗ v` and `s ⊗ t`
(`exists_rank_one_factor`) and observing `pencilB = det[u s] · det[v t] ≠ 0`
(`pencilB_of_factored`) shows that `{u, s}` and `{v, t}` are bases, so a further invertible
`B ⊗ C` carries `ψ` onto `|000⟩ + |111⟩`.

## Main results

* `hyperdet_eq_discriminant` — the hyperdeterminant is the discriminant of the Alice pencil.
* `exists_diagonalizing_A` — a nondegenerate pencil has two independent singular members.
* `exists_rank_one_factor` — a singular `2 × 2` matrix is a rank-`≤ 1` tensor.
* `ghz_normal_form` — `hyperdet ψ ≠ 0 → ψ` is SLOCC equivalent to GHZ.
* `slocc_ghz_iff_hyperdet_ne_zero` — the full characterisation of the GHZ orbit.
* `slocc_of_hyperdet_ne_zero` — the tensors of nonvanishing hyperdeterminant form a
  *single* SLOCC orbit.
* `wState_not_slocc_ghz` — the W state is not in that orbit.
* `exists_double_root_A` — a degenerate pencil has a double root, movable to the first slice.
* `wState_normal_form` — a genuinely entangled tensor with `hyperdet ψ = 0` is SLOCC
  equivalent to the W state.
* `dvc_classification` — the complete Dür–Vidal–Cirac dichotomy: a genuinely entangled
  three-qubit pure state is SLOCC equivalent to exactly one of GHZ and W.
* `slocc_wState_iff`, `three_qubit_trichotomy` — unconditional descriptions of the three
  SLOCC classes (biseparable, W, GHZ), which partition all amplitude tensors.
* `wState_mem_closure_ghz_orbit` — the W state is a limit of GHZ-class tensors, so the W class
  lies on the boundary of the generic class.
* `rank_le_one_of_minors`, `isProductA/B/C_iff_minors`, `slocc_class_criterion` — an explicit
  polynomial criterion: the class of `ψ` is decided by the `2 × 2` minors of its three
  flattenings together with `hyperdet ψ`.
-/

open scoped ComplexConjugate
open Matrix Finset

noncomputable section

namespace ThreeQubitGHZ

/-! ## Definitions reproduced from the catalog file -/

/-- Amplitude tensor of a three-qubit pure state. -/
abbrev Amp := Fin 2 → Fin 2 → Fin 2 → ℂ

/-- Cayley's `2 × 2 × 2` hyperdeterminant of a three-qubit amplitude tensor. -/
def hyperdet (a : Amp) : ℂ :=
  (a 0 0 0) ^ 2 * (a 1 1 1) ^ 2 + (a 0 0 1) ^ 2 * (a 1 1 0) ^ 2
    + (a 0 1 0) ^ 2 * (a 1 0 1) ^ 2 + (a 1 0 0) ^ 2 * (a 0 1 1) ^ 2
  - 2 * (a 0 0 0 * a 0 0 1 * a 1 1 0 * a 1 1 1
       + a 0 0 0 * a 0 1 0 * a 1 0 1 * a 1 1 1
       + a 0 0 0 * a 1 0 0 * a 0 1 1 * a 1 1 1
       + a 0 0 1 * a 0 1 0 * a 1 0 1 * a 1 1 0
       + a 0 0 1 * a 1 0 0 * a 0 1 1 * a 1 1 0
       + a 0 1 0 * a 1 0 0 * a 0 1 1 * a 1 0 1)
  + 4 * (a 0 0 0 * a 0 1 1 * a 1 0 1 * a 1 1 0 + a 0 0 1 * a 0 1 0 * a 1 0 0 * a 1 1 1)

/-- Action of a `2 × 2` matrix on the first (Alice) tensor slot. -/
def actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) : Amp :=
  fun i j k => A i 0 * a 0 j k + A i 1 * a 1 j k

/-- Action of a `2 × 2` matrix on the second (Bob) tensor slot. -/
def actB (B : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) : Amp :=
  fun i j k => B j 0 * a i 0 k + B j 1 * a i 1 k

/-- Action of a `2 × 2` matrix on the third (Charlie) tensor slot. -/
def actC (C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) : Amp :=
  fun i j k => C k 0 * a i j 0 + C k 1 * a i j 1

/-- The full local action `(A ⊗ B ⊗ C) ψ`. -/
def localAct (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) : Amp :=
  fun i j k => ∑ l, ∑ m, ∑ n, A i l * B j m * C k n * a l m n

theorem localAct_eq (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    localAct A B C a = actA A (actB B (actC C a)) := by
  funext i j k
  simp only [localAct, actA, actB, actC, Fin.sum_univ_two]
  ring

theorem hyperdet_actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    hyperdet (actA A a) = A.det ^ 2 * hyperdet a := by
  simp only [hyperdet, actA, Matrix.det_fin_two]
  ring

theorem hyperdet_actB (B : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    hyperdet (actB B a) = B.det ^ 2 * hyperdet a := by
  simp only [hyperdet, actB, Matrix.det_fin_two]
  ring

theorem hyperdet_actC (C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    hyperdet (actC C a) = C.det ^ 2 * hyperdet a := by
  simp only [hyperdet, actC, Matrix.det_fin_two]
  ring

/-- **Relative invariance** (catalog result, reproved here for self-containedness). -/
theorem hyperdet_localAct (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    hyperdet (localAct A B C a) = (A.det * B.det * C.det) ^ 2 * hyperdet a := by
  rw [localAct_eq, hyperdet_actA, hyperdet_actB, hyperdet_actC]
  ring

/-- `1 / √2`. -/
def c2 : ℂ := ((Real.sqrt 2)⁻¹ : ℝ)

theorem c2_sq : c2 ^ 2 = (1 / 2 : ℂ) := by
  have h : (Real.sqrt 2) ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have h0 : (Real.sqrt 2 : ℝ) ≠ 0 := by positivity
  have hc : ((Real.sqrt 2 : ℝ) : ℂ) ≠ 0 := by exact_mod_cast h0
  simp only [c2]
  push_cast
  field_simp
  exact_mod_cast h.symm

theorem c2_ne_zero : c2 ≠ 0 := by
  intro h
  have h2 := c2_sq
  rw [h] at h2
  norm_num at h2

/-- The GHZ state `(|000⟩ + |111⟩)/√2`. -/
def ghz : Amp := ![![![c2, 0], ![0, 0]], ![![0, 0], ![0, c2]]]

/-- `1 / √3`. -/
def c3 : ℂ := ((Real.sqrt 3)⁻¹ : ℝ)

/-- The W state `(|001⟩ + |010⟩ + |100⟩)/√3`. -/
def wState : Amp := ![![![0, c3], ![c3, 0]], ![![c3, 0], ![0, 0]]]

theorem hyperdet_wState : hyperdet wState = 0 := by
  simp only [hyperdet, wState, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-! ## The Alice pencil and its discriminant -/

/-- Determinant of the first Alice slice `M₀`. -/
def d0 (a : Amp) : ℂ := a 0 0 0 * a 0 1 1 - a 0 0 1 * a 0 1 0

/-- Determinant of the second Alice slice `M₁`. -/
def d1 (a : Amp) : ℂ := a 1 0 0 * a 1 1 1 - a 1 0 1 * a 1 1 0

/-- The mixed (polarization) term of the pencil determinant. -/
def pencilB (a : Amp) : ℂ :=
  a 0 0 0 * a 1 1 1 - a 0 0 1 * a 1 1 0 - a 0 1 0 * a 1 0 1 + a 0 1 1 * a 1 0 0

/-- The binary quadratic form `det (x M₀ + y M₁)`. -/
def qform (a : Amp) (x y : ℂ) : ℂ := d0 a * x ^ 2 + pencilB a * (x * y) + d1 a * y ^ 2

/-- The quadratic form `qform` really is the determinant of the pencil `x M₀ + y M₁`. -/
theorem qform_eq_det_pencil (a : Amp) (x y : ℂ) :
    qform a x y =
      (x * a 0 0 0 + y * a 1 0 0) * (x * a 0 1 1 + y * a 1 1 1)
        - (x * a 0 0 1 + y * a 1 0 1) * (x * a 0 1 0 + y * a 1 1 0) := by
  simp only [qform, d0, d1, pencilB]
  ring

/-- **The hyperdeterminant is the discriminant of the Alice pencil.** -/
theorem hyperdet_eq_discriminant (a : Amp) :
    hyperdet a = pencilB a ^ 2 - 4 * d0 a * d1 a := by
  simp only [hyperdet, d0, d1, pencilB]
  ring

theorem d0_actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    d0 (actA A a) = qform a (A 0 0) (A 0 1) := by
  simp only [d0, actA, qform, d1, pencilB]
  ring

theorem d1_actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    d1 (actA A a) = qform a (A 1 0) (A 1 1) := by
  simp only [d1, actA, qform, d0, pencilB]
  ring

/-! ## Step 1: diagonalizing the pencil -/

/-- If the hyperdeterminant is nonzero then an invertible `A` makes **both** Alice slices
singular: the pencil has two distinct, hence linearly independent, singular members. -/
theorem exists_diagonalizing_A {a : Amp} (h : hyperdet a ≠ 0) :
    ∃ A : Matrix (Fin 2) (Fin 2) ℂ,
      A.det ≠ 0 ∧ d0 (actA A a) = 0 ∧ d1 (actA A a) = 0 := by
  obtain ⟨s, hs⟩ : ∃ s : ℂ, s ^ 2 = hyperdet a :=
    IsAlgClosed.exists_pow_nat_eq (hyperdet a) (n := 2) (by norm_num)
  have hs0 : s ≠ 0 := by
    intro hz; rw [hz] at hs; simp at hs; exact h hs.symm
  have hdisc : s ^ 2 = pencilB a ^ 2 - 4 * d0 a * d1 a := by
    rw [hs, hyperdet_eq_discriminant]
  by_cases hd0 : d0 a = 0
  · -- Degenerate case: `(1, 0)` is already a root; the other root is `(d₁, -b)`.
    have hb : pencilB a ≠ 0 := by
      intro hbz
      exact h (by rw [hyperdet_eq_discriminant, hbz, hd0]; ring)
    refine ⟨!![1, 0; d1 a, -(pencilB a)], ?_, ?_, ?_⟩
    · rw [Matrix.det_fin_two_of]
      simpa using hb
    · rw [d0_actA]
      simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, 
        Matrix.of_apply, qform, hd0]
      ring
    · rw [d1_actA]
      simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, 
        Matrix.of_apply, qform, hd0]
      ring
  · -- Generic case: the quadratic has two distinct roots.
    refine ⟨!![(-(pencilB a) + s) / (2 * d0 a), 1; (-(pencilB a) - s) / (2 * d0 a), 1], ?_, ?_, ?_⟩
    · rw [Matrix.det_fin_two_of]
      simp only [
        
        mul_one, one_mul]
      rw [div_sub_div_same, show (-(pencilB a) + s) - (-(pencilB a) - s) = 2 * s by ring]
      exact div_ne_zero (by simpa using hs0) (by simpa using hd0)
    · rw [d0_actA]
      simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, 
        Matrix.of_apply, qform]
      field_simp
      linear_combination hdisc
    · rw [d1_actA]
      simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, 
        Matrix.of_apply, qform]
      field_simp
      linear_combination hdisc

/-! ## Step 2: rank-one factorization of the slices -/

/-- Every `2 × 2` matrix of vanishing determinant is a rank-`≤ 1` tensor `u ⊗ v`.
(The hypothesis that `m` be nonzero turns out to be unnecessary: the zero matrix is the
rank-zero tensor `![0,1] ⊗ ![0,0]`.) -/
theorem exists_rank_one_factor (m : Fin 2 → Fin 2 → ℂ)
    (hdet : m 0 0 * m 1 1 - m 0 1 * m 1 0 = 0) :
    ∃ u v : Fin 2 → ℂ, ∀ j k, m j k = u j * v k := by
  by_cases h00 : m 0 0 = 0
  · by_cases h01 : m 0 1 = 0
    · by_cases h10 : m 1 0 = 0
      · refine ⟨![0, 1], ![0, m 1 1], ?_⟩
        intro j k
        fin_cases j <;> fin_cases k <;> simp [h00, h01, h10]
      · refine ⟨![0, m 1 0], ![1, m 1 1 / m 1 0], ?_⟩
        intro j k
        fin_cases j <;> fin_cases k <;> simp [h00, h01]; field_simp
    · refine ⟨![m 0 1, m 1 1], ![m 0 0 / m 0 1, 1], ?_⟩
      intro j k
      fin_cases j <;> fin_cases k <;> simp <;> field_simp; linear_combination -hdet
  · refine ⟨![m 0 0, m 1 0], ![1, m 0 1 / m 0 0], ?_⟩
    intro j k
    fin_cases j <;> fin_cases k <;> simp <;> field_simp; linear_combination hdet

/-- If both Alice slices are rank one, `pencilB` factors as the product of the two
`2 × 2` determinants of the factor pairs.  This is the mechanism that turns
`hyperdet ≠ 0` into linear independence of the factors. -/
theorem pencilB_of_factored {a : Amp} {u v s t : Fin 2 → ℂ}
    (h0 : ∀ j k, a 0 j k = u j * v k) (h1 : ∀ j k, a 1 j k = s j * t k) :
    pencilB a = (u 0 * s 1 - u 1 * s 0) * (v 0 * t 1 - v 1 * t 0) := by
  simp only [pencilB, h0, h1]
  ring

/-! ## Step 3: assembling the normal form -/

/-- The unnormalized GHZ tensor `|000⟩ + |111⟩`. -/
def ghzBare : Amp := ![![![1, 0], ![0, 0]], ![![0, 0], ![0, 1]]]

theorem ghz_apply (i j k : Fin 2) : ghz i j k = c2 * ghzBare i j k := by
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [ghz, ghzBare]

theorem localAct_smul_A (c : ℂ) (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    localAct (c • A) B C a = fun i j k => c * localAct A B C a i j k := by
  funext i j k
  simp only [localAct, Matrix.smul_apply, smul_eq_mul, Fin.sum_univ_two]
  ring

theorem localAct_eq' (A B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    localAct A B C a = actB B (actC C (actA A a)) := by
  funext i j k
  simp only [localAct, actA, actB, actC, Fin.sum_univ_two]
  ring

/-- **GHZ normal form.**  Every three-qubit amplitude tensor with nonvanishing
hyperdeterminant is SLOCC equivalent to the GHZ state. -/
theorem ghz_normal_form {a : Amp} (h : hyperdet a ≠ 0) :
    ∃ A B C : Matrix (Fin 2) (Fin 2) ℂ,
      A.det ≠ 0 ∧ B.det ≠ 0 ∧ C.det ≠ 0 ∧ localAct A B C a = ghz := by
  obtain ⟨A, hA, hA0, hA1⟩ := exists_diagonalizing_A h
  have h' : hyperdet (actA A a) ≠ 0 := by
    rw [hyperdet_actA]
    exact mul_ne_zero (pow_ne_zero _ hA) h
  have hb : pencilB (actA A a) ≠ 0 := by
    intro hbz
    exact h' (by rw [hyperdet_eq_discriminant, hbz, hA0]; ring)
  obtain ⟨u, v, huv⟩ :=
    exists_rank_one_factor (fun j k => actA A a 0 j k) (by simpa [d0] using hA0)
  obtain ⟨s, t, hst⟩ :=
    exists_rank_one_factor (fun j k => actA A a 1 j k) (by simpa [d1] using hA1)
  have hfac := pencilB_of_factored (a := actA A a) huv hst
  have hus : u 0 * s 1 - u 1 * s 0 ≠ 0 := by
    intro hz; exact hb (by rw [hfac, hz]; ring)
  have hvt : v 0 * t 1 - v 1 * t 0 ≠ 0 := by
    intro hz; exact hb (by rw [hfac, hz]; ring)
  have hD : (u 0 * s 1 - u 1 * s 0) * (v 0 * t 1 - v 1 * t 0) ≠ 0 := mul_ne_zero hus hvt
  refine ⟨(c2 / ((u 0 * s 1 - u 1 * s 0) * (v 0 * t 1 - v 1 * t 0))) • A,
    !![s 1, -(s 0); -(u 1), u 0], !![t 1, -(t 0); -(v 1), v 0], ?_, ?_, ?_, ?_⟩
  · rw [Matrix.det_smul]
    exact mul_ne_zero (pow_ne_zero _ (div_ne_zero c2_ne_zero hD)) hA
  · rw [Matrix.det_fin_two_of, show s 1 * u 0 - -(s 0) * -(u 1) = u 0 * s 1 - u 1 * s 0 by ring]
    exact hus
  · rw [Matrix.det_fin_two_of, show t 1 * v 0 - -(t 0) * -(v 1) = v 0 * t 1 - v 1 * t 0 by ring]
    exact hvt
  · have key : localAct A !![s 1, -(s 0); -(u 1), u 0] !![t 1, -(t 0); -(v 1), v 0] a =
        fun i j k => ((u 0 * s 1 - u 1 * s 0) * (v 0 * t 1 - v 1 * t 0)) * ghzBare i j k := by
      rw [localAct_eq']
      funext i j k
      fin_cases i <;> fin_cases j <;> fin_cases k <;>
        simp only [actB, actC, Fin.zero_eta, Fin.mk_one, Fin.isValue, huv, hst, ghzBare,
          Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
          Matrix.empty_val', Matrix.cons_val_fin_one, 
          Matrix.of_apply] <;>
        ring
    rw [localAct_smul_A, key]
    funext i j k
    rw [ghz_apply]
    field_simp

/-! ## SLOCC equivalence -/

/-- SLOCC (stochastic local operations and classical communication) equivalence: `a` can be
turned into `b` by an invertible local operation `A ⊗ B ⊗ C`. -/
def SLOCC (a b : Amp) : Prop :=
  ∃ A B C : Matrix (Fin 2) (Fin 2) ℂ,
    A.det ≠ 0 ∧ B.det ≠ 0 ∧ C.det ≠ 0 ∧ localAct A B C a = b

theorem localAct_one (a : Amp) : localAct 1 1 1 a = a := by
  funext i j k
  simp only [localAct, Fin.sum_univ_two]
  fin_cases i <;> fin_cases j <;> fin_cases k <;>
    simp [Matrix.one_apply]

theorem localAct_mul (A B C A' B' C' : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    localAct A B C (localAct A' B' C' a) = localAct (A * A') (B * B') (C * C') a := by
  funext i j k
  simp only [localAct, Matrix.mul_apply, Fin.sum_univ_two]
  ring

theorem SLOCC.refl (a : Amp) : SLOCC a a :=
  ⟨1, 1, 1, by simp, by simp, by simp, localAct_one a⟩

theorem SLOCC.trans {a b c : Amp} (hab : SLOCC a b) (hbc : SLOCC b c) : SLOCC a c := by
  obtain ⟨A, B, C, hA, hB, hC, hab⟩ := hab
  obtain ⟨A', B', C', hA', hB', hC', hbc⟩ := hbc
  refine ⟨A' * A, B' * B, C' * C, ?_, ?_, ?_, ?_⟩
  · rw [Matrix.det_mul]; exact mul_ne_zero hA' hA
  · rw [Matrix.det_mul]; exact mul_ne_zero hB' hB
  · rw [Matrix.det_mul]; exact mul_ne_zero hC' hC
  · rw [← localAct_mul, hab, hbc]

theorem SLOCC.symm {a b : Amp} (hab : SLOCC a b) : SLOCC b a := by
  obtain ⟨A, B, C, hA, hB, hC, hab⟩ := hab
  have hAu : IsUnit A.det := isUnit_iff_ne_zero.mpr hA
  have hBu : IsUnit B.det := isUnit_iff_ne_zero.mpr hB
  have hCu : IsUnit C.det := isUnit_iff_ne_zero.mpr hC
  refine ⟨A⁻¹, B⁻¹, C⁻¹, ?_, ?_, ?_, ?_⟩
  · rw [Matrix.det_nonsing_inv, Ring.inverse_eq_inv]
    exact inv_ne_zero hA
  · rw [Matrix.det_nonsing_inv, Ring.inverse_eq_inv]
    exact inv_ne_zero hB
  · rw [Matrix.det_nonsing_inv, Ring.inverse_eq_inv]
    exact inv_ne_zero hC
  · rw [← hab, localAct_mul, Matrix.nonsing_inv_mul _ hAu, Matrix.nonsing_inv_mul _ hBu,
      Matrix.nonsing_inv_mul _ hCu, localAct_one]

theorem hyperdet_ne_zero_of_slocc {a b : Amp} (hab : SLOCC a b) (hb : hyperdet b ≠ 0) :
    hyperdet a ≠ 0 := by
  obtain ⟨A, B, C, hA, hB, hC, hab⟩ := hab
  intro h
  apply hb
  rw [← hab, hyperdet_localAct, h, mul_zero]

theorem hyperdet_ghz : hyperdet ghz = 1 / 4 := by
  have h : c2 ^ 2 = (1 / 2 : ℂ) := c2_sq
  simp only [hyperdet, ghz, Matrix.cons_val_zero, Matrix.cons_val_one,
    mul_zero, zero_mul, add_zero, sub_zero]
  ring_nf
  rw [show c2 ^ 4 = (c2 ^ 2) ^ 2 by ring, h]
  norm_num

theorem hyperdet_ghz_ne_zero : hyperdet ghz ≠ 0 := by
  rw [hyperdet_ghz]; norm_num

/-- **The GHZ SLOCC orbit is exactly the nonvanishing locus of the hyperdeterminant.**
This is the complete characterisation of the generic three-qubit entanglement class. -/
theorem slocc_ghz_iff_hyperdet_ne_zero (a : Amp) : SLOCC a ghz ↔ hyperdet a ≠ 0 := by
  constructor
  · intro h
    exact hyperdet_ne_zero_of_slocc h hyperdet_ghz_ne_zero
  · intro h
    exact ghz_normal_form h

/-- **Single orbit.**  Any two three-qubit tensors of nonvanishing hyperdeterminant are
SLOCC equivalent to each other. -/
theorem slocc_of_hyperdet_ne_zero {a b : Amp} (ha : hyperdet a ≠ 0) (hb : hyperdet b ≠ 0) :
    SLOCC a b :=
  ((slocc_ghz_iff_hyperdet_ne_zero a).mpr ha).trans
    ((slocc_ghz_iff_hyperdet_ne_zero b).mpr hb).symm

/-- The W state is not in the GHZ orbit. -/
theorem wState_not_slocc_ghz : ¬ SLOCC wState ghz := by
  rw [slocc_ghz_iff_hyperdet_ne_zero]
  simp [hyperdet_wState]

/-! ## Biseparability and genuine entanglement -/

/-- `ψ` factorizes across the cut `A | BC`. -/
def IsProductA (a : Amp) : Prop := ∃ u : Fin 2 → ℂ, ∃ v : Fin 2 → Fin 2 → ℂ,
  ∀ i j k, a i j k = u i * v j k

/-- `ψ` factorizes across the cut `B | AC`. -/
def IsProductB (a : Amp) : Prop := ∃ u : Fin 2 → ℂ, ∃ v : Fin 2 → Fin 2 → ℂ,
  ∀ i j k, a i j k = u j * v i k

/-- `ψ` factorizes across the cut `C | AB`. -/
def IsProductC (a : Amp) : Prop := ∃ u : Fin 2 → ℂ, ∃ v : Fin 2 → Fin 2 → ℂ,
  ∀ i j k, a i j k = u k * v i j

/-- Genuine tripartite entanglement: biseparable across no cut. -/
def Genuine (a : Amp) : Prop := ¬ IsProductA a ∧ ¬ IsProductB a ∧ ¬ IsProductC a

theorem isProductA_localAct (A B C : Matrix (Fin 2) (Fin 2) ℂ) {a : Amp} (h : IsProductA a) :
    IsProductA (localAct A B C a) := by
  obtain ⟨u, w, hw⟩ := h
  refine ⟨fun i => ∑ l, A i l * u l, fun j k => ∑ m, ∑ n, B j m * C k n * w m n, ?_⟩
  intro i j k
  simp only [localAct, hw, Fin.sum_univ_two]
  ring

theorem isProductB_localAct (A B C : Matrix (Fin 2) (Fin 2) ℂ) {a : Amp} (h : IsProductB a) :
    IsProductB (localAct A B C a) := by
  obtain ⟨u, w, hw⟩ := h
  refine ⟨fun j => ∑ m, B j m * u m, fun i k => ∑ l, ∑ n, A i l * C k n * w l n, ?_⟩
  intro i j k
  simp only [localAct, hw, Fin.sum_univ_two]
  ring

theorem isProductC_localAct (A B C : Matrix (Fin 2) (Fin 2) ℂ) {a : Amp} (h : IsProductC a) :
    IsProductC (localAct A B C a) := by
  obtain ⟨u, w, hw⟩ := h
  refine ⟨fun k => ∑ n, C k n * u n, fun i j => ∑ l, ∑ m, A i l * B j m * w l m, ?_⟩
  intro i j k
  simp only [localAct, hw, Fin.sum_univ_two]
  ring

/-- Genuine tripartite entanglement is an SLOCC invariant. -/
theorem Genuine.of_slocc {a b : Amp} (h : SLOCC a b) (ha : Genuine a) : Genuine b := by
  obtain ⟨A, B, C, _, _, _, hab⟩ := h.symm
  refine ⟨fun hb => ha.1 ?_, fun hb => ha.2.1 ?_, fun hb => ha.2.2 ?_⟩
  · rw [← hab]; exact isProductA_localAct A B C hb
  · rw [← hab]; exact isProductB_localAct A B C hb
  · rw [← hab]; exact isProductC_localAct A B C hb

/-! ## Transformation rules for the pencil invariants -/

theorem pencilB_actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    pencilB (actA A a) =
      2 * A 0 0 * A 1 0 * d0 a + (A 0 0 * A 1 1 + A 0 1 * A 1 0) * pencilB a
        + 2 * A 0 1 * A 1 1 * d1 a := by
  simp only [pencilB, actA, d0, d1]
  ring

theorem pencilB_actB (B : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    pencilB (actB B a) = B.det * pencilB a := by
  simp only [pencilB, actB, Matrix.det_fin_two]
  ring

theorem pencilB_actC (C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    pencilB (actC C a) = C.det * pencilB a := by
  simp only [pencilB, actC, Matrix.det_fin_two]
  ring

/-! ## Elementary SLOCC moves -/

theorem localAct_actA (A : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    localAct A 1 1 a = actA A a := by
  funext i j k
  simp only [localAct, actA, Fin.sum_univ_two]
  fin_cases j <;> fin_cases k <;> simp [Matrix.one_apply]

theorem localAct_actBC (B C : Matrix (Fin 2) (Fin 2) ℂ) (a : Amp) :
    localAct 1 B C a = actB B (actC C a) := by
  funext i j k
  simp only [localAct, actB, actC, Fin.sum_univ_two]
  fin_cases i <;> simp [Matrix.one_apply] <;> ring

theorem slocc_actA {A : Matrix (Fin 2) (Fin 2) ℂ} (hA : A.det ≠ 0) (a : Amp) :
    SLOCC a (actA A a) :=
  ⟨A, 1, 1, hA, by simp, by simp, localAct_actA A a⟩

theorem slocc_actBC {B C : Matrix (Fin 2) (Fin 2) ℂ} (hB : B.det ≠ 0) (hC : C.det ≠ 0)
    (a : Amp) : SLOCC a (actB B (actC C a)) :=
  ⟨1, B, C, by simp, hB, hC, localAct_actBC B C a⟩

/-! ## Step 1 for the degenerate stratum: forcing a double root -/

/-- If the hyperdeterminant vanishes then the pencil has a *double* root, and an invertible
`A` moves it to the first slice: both `d₀` and the polarization `pencilB` vanish. -/
theorem exists_double_root_A {a : Amp} (h : hyperdet a = 0) :
    ∃ A : Matrix (Fin 2) (Fin 2) ℂ,
      A.det ≠ 0 ∧ d0 (actA A a) = 0 ∧ pencilB (actA A a) = 0 := by
  by_cases hd0 : d0 a = 0
  · have hb : pencilB a = 0 := by
      have : pencilB a ^ 2 = 0 := by
        rw [hyperdet_eq_discriminant, hd0] at h; linear_combination h
      exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
    refine ⟨1, by simp, ?_, ?_⟩
    · rw [d0_actA]
      simp only [qform, hd0, Matrix.one_apply, 
        hb]
      norm_num
    · rw [pencilB_actA, hd0, hb]
      simp []
  · refine ⟨!![-(pencilB a) / (2 * d0 a), 1; 1, 0], ?_, ?_, ?_⟩
    · rw [Matrix.det_fin_two_of]
      norm_num
    · rw [d0_actA]
      simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply, qform]
      rw [hyperdet_eq_discriminant] at h
      field_simp
      linear_combination -h
    · rw [pencilB_actA]
      simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply]
      field_simp
      ring

/-- Any nonzero vector in `ℂ²` can be moved to `e₀` by an invertible matrix. -/
theorem exists_normalizer (u : Fin 2 → ℂ) (hu : ¬ (u 0 = 0 ∧ u 1 = 0)) :
    ∃ B : Matrix (Fin 2) (Fin 2) ℂ, B.det ≠ 0 ∧
      B 0 0 * u 0 + B 0 1 * u 1 = 1 ∧ B 1 0 * u 0 + B 1 1 * u 1 = 0 := by
  by_cases h0 : u 0 = 0
  · have h1 : u 1 ≠ 0 := fun h => hu ⟨h0, h⟩
    refine ⟨!![0, (u 1)⁻¹; 1, 0], ?_, ?_, ?_⟩
    · rw [Matrix.det_fin_two_of]
      simp only [zero_mul, zero_sub, neg_ne_zero, mul_one]
      exact inv_ne_zero h1
    · simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply]
      field_simp
      ring
    · simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply]
      simp [h0]
  · refine ⟨!![(u 0)⁻¹, 0; -(u 1), u 0], ?_, ?_, ?_⟩
    · rw [Matrix.det_fin_two_of]
      simp only [
        zero_mul, sub_zero]
      rw [inv_mul_cancel₀ h0]
      norm_num
    · simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply]
      field_simp
      ring
    · simp only [Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply]
      ring

/-! ## The W normal form -/

theorem c3_sq : c3 ^ 2 = (1 / 3 : ℂ) := by
  have h : (Real.sqrt 3) ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h0 : (Real.sqrt 3 : ℝ) ≠ 0 := by positivity
  have hc : ((Real.sqrt 3 : ℝ) : ℂ) ≠ 0 := by exact_mod_cast h0
  simp only [c3]
  push_cast
  field_simp
  exact_mod_cast h.symm

theorem c3_ne_zero : c3 ≠ 0 := by
  intro h
  have h3 := c3_sq
  rw [h] at h3
  norm_num at h3

/-- A tensor in the shape `|000⟩ + q|101⟩ + r|110⟩` with `q ≠ 0 ≠ r` is SLOCC equivalent
to the W state. -/
theorem slocc_wState_of_normal {b : Amp}
    (h000 : b 0 0 0 = 1) (h001 : b 0 0 1 = 0) (h010 : b 0 1 0 = 0) (h011 : b 0 1 1 = 0)
    (h100 : b 1 0 0 = 0) (h111 : b 1 1 1 = 0)
    (hq : b 1 0 1 ≠ 0) (hr : b 1 1 0 ≠ 0) : SLOCC b wState := by
  refine ⟨!![0, 1; c3, 0], !![1, 0; 0, c3 / b 1 1 0], !![1, 0; 0, c3 / b 1 0 1], ?_, ?_, ?_, ?_⟩
  · rw [Matrix.det_fin_two_of]
    simpa using c3_ne_zero
  · rw [Matrix.det_fin_two_of]
    simpa using div_ne_zero c3_ne_zero hr
  · rw [Matrix.det_fin_two_of]
    simpa using div_ne_zero c3_ne_zero hq
  · funext i j k
    fin_cases i <;> fin_cases j <;> fin_cases k <;>
      simp only [localAct, wState, Fin.sum_univ_two, Fin.zero_eta, Fin.mk_one, Fin.isValue,
        Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one, 
        Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply, h000, h001, h010, h011,
        h100, h111] <;>
      field_simp <;> ring

theorem isProductC_of_shape {b : Amp} (h001 : b 0 0 1 = 0) (h011 : b 0 1 1 = 0)
    (h101 : b 1 0 1 = 0) (h111 : b 1 1 1 = 0) : IsProductC b := by
  refine ⟨![1, 0], fun i j => b i j 0, ?_⟩
  intro i j k
  fin_cases i <;> fin_cases j <;> fin_cases k <;>
    simp [h001, h011, h101, h111]

theorem isProductB_of_shape {b : Amp} (h010 : b 0 1 0 = 0) (h011 : b 0 1 1 = 0)
    (h110 : b 1 1 0 = 0) (h111 : b 1 1 1 = 0) : IsProductB b := by
  refine ⟨![1, 0], fun i k => b i 0 k, ?_⟩
  intro i j k
  fin_cases i <;> fin_cases j <;> fin_cases k <;>
    simp [h010, h011, h110, h111]

theorem isProductA_of_slice_zero {b : Amp} (h : ∀ j k, b 0 j k = 0) : IsProductA b := by
  refine ⟨![0, 1], fun j k => b 1 j k, ?_⟩
  intro i j k
  fin_cases i <;> simp [h]

/-- **W normal form.**  A genuinely entangled three-qubit tensor with vanishing
hyperdeterminant is SLOCC equivalent to the W state.  Together with `ghz_normal_form`
this is the complete Dür–Vidal–Cirac classification of genuinely entangled three-qubit
pure states into exactly two SLOCC classes. -/
theorem wState_normal_form {a : Amp} (hgen : Genuine a) (h : hyperdet a = 0) :
    SLOCC a wState := by
  obtain ⟨A, hA, hd0, hb⟩ := exists_double_root_A h
  set a1 : Amp := actA A a with ha1
  have hs1 : SLOCC a a1 := slocc_actA hA a
  have hg1 : Genuine a1 := hgen.of_slocc hs1
  -- the first slice is rank one and nonzero
  have hslice : ¬ (∀ j k, a1 0 j k = 0) := fun hz => hg1.1 (isProductA_of_slice_zero hz)
  obtain ⟨u, v, huv⟩ :=
    exists_rank_one_factor (fun j k => a1 0 j k) (by simpa [d0] using hd0)
  have hu : ¬ (u 0 = 0 ∧ u 1 = 0) := by
    rintro ⟨hu0, hu1⟩
    exact hslice (fun j k => by
      fin_cases j <;> simp [huv, hu0, hu1])
  have hv : ¬ (v 0 = 0 ∧ v 1 = 0) := by
    rintro ⟨hv0, hv1⟩
    exact hslice (fun j k => by
      fin_cases k <;> simp [huv, hv0, hv1])
  obtain ⟨B, hB, hB0, hB1⟩ := exists_normalizer u hu
  obtain ⟨C, hC, hC0, hC1⟩ := exists_normalizer v hv
  set a2 : Amp := actB B (actC C a1) with ha2
  have hs2 : SLOCC a1 a2 := slocc_actBC hB hC a1
  have hg2 : Genuine a2 := hg1.of_slocc hs2
  have e000 : a2 0 0 0 = 1 := by
    simp only [ha2, actB, actC, huv]
    linear_combination (C 0 0 * v 0 + C 0 1 * v 1) * hB0 + hC0
  have e001 : a2 0 0 1 = 0 := by
    simp only [ha2, actB, actC, huv]
    linear_combination (C 1 0 * v 0 + C 1 1 * v 1) * hB0 + hC1
  have e010 : a2 0 1 0 = 0 := by
    simp only [ha2, actB, actC, huv]
    linear_combination (C 0 0 * v 0 + C 0 1 * v 1) * hB1
  have e011 : a2 0 1 1 = 0 := by
    simp only [ha2, actB, actC, huv]
    linear_combination (C 1 0 * v 0 + C 1 1 * v 1) * hB1
  have hb2 : pencilB a2 = 0 := by
    rw [ha2, pencilB_actB, pencilB_actC, hb, mul_zero, mul_zero]
  have e111 : a2 1 1 1 = 0 := by
    have := hb2
    simp only [pencilB, e000, e001, e010, e011] at this
    linear_combination this
  -- clear the `|100⟩` amplitude
  set a3 : Amp := actA !![1, 0; -(a2 1 0 0), 1] a2 with ha3
  have hs3 : SLOCC a2 a3 := by
    refine slocc_actA ?_ a2
    rw [Matrix.det_fin_two_of]
    norm_num
  have hg3 : Genuine a3 := hg2.of_slocc hs3
  have f000 : a3 0 0 0 = 1 := by simp [ha3, actA, e000]
  have f001 : a3 0 0 1 = 0 := by simp [ha3, actA, e001]
  have f010 : a3 0 1 0 = 0 := by simp [ha3, actA, e010]
  have f011 : a3 0 1 1 = 0 := by simp [ha3, actA, e011]
  have f100 : a3 1 0 0 = 0 := by
    simp only [ha3, actA, Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply, e000]
    ring
  have f101 : a3 1 0 1 = a2 1 0 1 := by
    simp only [ha3, actA, Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply, e001]
    ring
  have f110 : a3 1 1 0 = a2 1 1 0 := by
    simp only [ha3, actA, Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply, e010]
    ring
  have f111 : a3 1 1 1 = 0 := by
    simp only [ha3, actA, Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.of_apply, e011, e111]
    ring
  have hq : a3 1 0 1 ≠ 0 := fun hz => hg3.2.2 (isProductC_of_shape f001 f011 hz f111)
  have hr : a3 1 1 0 ≠ 0 := fun hz => hg3.2.1 (isProductB_of_shape f010 f011 hz f111)
  exact (hs1.trans (hs2.trans hs3)).trans
    (slocc_wState_of_normal f000 f001 f010 f011 f100 f111 hq hr)

/-! ## Both classes are nonempty -/

theorem hyperdet_eq_zero_of_isProductA {a : Amp} (h : IsProductA a) : hyperdet a = 0 := by
  obtain ⟨u, v, hv⟩ := h
  simp only [hyperdet, hv]
  ring

theorem hyperdet_eq_zero_of_isProductB {a : Amp} (h : IsProductB a) : hyperdet a = 0 := by
  obtain ⟨u, v, hv⟩ := h
  simp only [hyperdet, hv]
  ring

theorem hyperdet_eq_zero_of_isProductC {a : Amp} (h : IsProductC a) : hyperdet a = 0 := by
  obtain ⟨u, v, hv⟩ := h
  simp only [hyperdet, hv]
  ring

/-- A nonvanishing hyperdeterminant certifies genuine tripartite entanglement. -/
theorem genuine_of_hyperdet_ne_zero {a : Amp} (h : hyperdet a ≠ 0) : Genuine a :=
  ⟨fun hp => h (hyperdet_eq_zero_of_isProductA hp),
   fun hp => h (hyperdet_eq_zero_of_isProductB hp),
   fun hp => h (hyperdet_eq_zero_of_isProductC hp)⟩

theorem ghz_genuine : Genuine ghz := genuine_of_hyperdet_ne_zero hyperdet_ghz_ne_zero

theorem wState_genuine : Genuine wState := by
  refine ⟨?_, ?_, ?_⟩
  · rintro ⟨u, v, h⟩
    have h001 : c3 = u 0 * v 0 1 := by simpa [wState] using h 0 0 1
    have h100 : c3 = u 1 * v 0 0 := by simpa [wState] using h 1 0 0
    have h101 : (0 : ℂ) = u 1 * v 0 1 := by simpa [wState] using h 1 0 1
    have hv01 : v 0 1 ≠ 0 := by
      intro hz; rw [hz, mul_zero] at h001; exact c3_ne_zero h001
    have hu1 : u 1 ≠ 0 := by
      intro hz; rw [hz, zero_mul] at h100; exact c3_ne_zero h100
    exact (mul_ne_zero hu1 hv01) h101.symm
  · rintro ⟨u, v, h⟩
    have h010 : c3 = u 1 * v 0 0 := by simpa [wState] using h 0 1 0
    have h100 : c3 = u 0 * v 1 0 := by simpa [wState] using h 1 0 0
    have h110 : (0 : ℂ) = u 1 * v 1 0 := by simpa [wState] using h 1 1 0
    have hu1 : u 1 ≠ 0 := by
      intro hz; rw [hz, zero_mul] at h010; exact c3_ne_zero h010
    have hv10 : v 1 0 ≠ 0 := by
      intro hz; rw [hz, mul_zero] at h100; exact c3_ne_zero h100
    exact (mul_ne_zero hu1 hv10) h110.symm
  · rintro ⟨u, v, h⟩
    have h001 : c3 = u 1 * v 0 0 := by simpa [wState] using h 0 0 1
    have h100 : c3 = u 0 * v 1 0 := by simpa [wState] using h 1 0 0
    have h101 : (0 : ℂ) = u 1 * v 1 0 := by simpa [wState] using h 1 0 1
    have hu1 : u 1 ≠ 0 := by
      intro hz; rw [hz, zero_mul] at h001; exact c3_ne_zero h001
    have hv10 : v 1 0 ≠ 0 := by
      intro hz; rw [hz, mul_zero] at h100; exact c3_ne_zero h100
    exact (mul_ne_zero hu1 hv10) h101.symm

/-- The W orbit inside the genuinely entangled locus is exactly the vanishing locus of the
hyperdeterminant. -/
theorem slocc_wState_iff_hyperdet_eq_zero {a : Amp} (hgen : Genuine a) :
    SLOCC a wState ↔ hyperdet a = 0 := by
  constructor
  · rintro ⟨A, B, C, hA, hB, hC, hAa⟩
    have hw : hyperdet wState = (A.det * B.det * C.det) ^ 2 * hyperdet a := by
      rw [← hAa, hyperdet_localAct]
    rw [hyperdet_wState] at hw
    rcases mul_eq_zero.mp hw.symm with h1 | h2
    · exact absurd h1 (pow_ne_zero _ (mul_ne_zero (mul_ne_zero hA hB) hC))
    · exact h2
  · exact wState_normal_form hgen

/-- **Dür–Vidal–Cirac trichotomy.**  Every genuinely entangled three-qubit pure state is
SLOCC equivalent to exactly one of GHZ and W, and the hyperdeterminant decides which. -/
theorem dvc_classification {a : Amp} (hgen : Genuine a) :
    (SLOCC a ghz ∧ ¬ SLOCC a wState) ∨ (SLOCC a wState ∧ ¬ SLOCC a ghz) := by
  by_cases h : hyperdet a = 0
  · exact Or.inr ⟨wState_normal_form hgen h,
      fun hg => (slocc_ghz_iff_hyperdet_ne_zero a).mp hg h⟩
  · exact Or.inl ⟨ghz_normal_form h,
      fun hw => h ((slocc_wState_iff_hyperdet_eq_zero hgen).mp hw)⟩

/-- Unconditional description of the W orbit. -/
theorem slocc_wState_iff (a : Amp) : SLOCC a wState ↔ (Genuine a ∧ hyperdet a = 0) := by
  constructor
  · intro h
    have hg : Genuine a := wState_genuine.of_slocc h.symm
    exact ⟨hg, (slocc_wState_iff_hyperdet_eq_zero hg).mp h⟩
  · rintro ⟨hg, h0⟩
    exact wState_normal_form hg h0

/-- **Trichotomy of three-qubit pure states.**  Every amplitude tensor is in exactly one of
three classes: biseparable across some cut, the W class, or the GHZ class. -/
theorem three_qubit_trichotomy (a : Amp) :
    (¬ Genuine a ∧ ¬ SLOCC a wState ∧ ¬ SLOCC a ghz)
      ∨ (Genuine a ∧ SLOCC a wState ∧ ¬ SLOCC a ghz)
      ∨ (Genuine a ∧ SLOCC a ghz ∧ ¬ SLOCC a wState) := by
  by_cases hg : Genuine a
  · rcases dvc_classification hg with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inr (Or.inr ⟨hg, h1, h2⟩)
    · exact Or.inr (Or.inl ⟨hg, h1, h2⟩)
  · refine Or.inl ⟨hg, fun hw => hg (wState_genuine.of_slocc hw.symm),
      fun hz => hg (ghz_genuine.of_slocc hz.symm)⟩

/-! ## The W class is a degeneration of the GHZ class -/

/-- A one-parameter perturbation of the W state by the `|111⟩` amplitude. -/
def wPert (t : ℂ) : Amp := ![![![0, c3], ![c3, 0]], ![![c3, 0], ![0, t]]]

theorem hyperdet_wPert (t : ℂ) : hyperdet (wPert t) = 4 * c3 ^ 3 * t := by
  simp only [hyperdet, wPert, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- **The W state lies in the closure of the GHZ orbit.**  Arbitrarily small perturbations of
the W state are SLOCC equivalent to GHZ, so the two classes are not separated by any
neighbourhood: the W class sits on the boundary of the generic class.  (The converse fails,
since `hyperdet` vanishes identically on the W orbit.) -/
theorem wState_mem_closure_ghz_orbit {ε : ℝ} (hε : 0 < ε) :
    ∃ b : Amp, (∀ i j k, ‖b i j k - wState i j k‖ < ε) ∧ SLOCC b ghz := by
  refine ⟨wPert ((ε / 2 : ℝ) : ℂ), ?_, ?_⟩
  · intro i j k
    have ht : ‖((ε / 2 : ℝ) : ℂ)‖ < ε := by
      rw [Complex.norm_real, Real.norm_eq_abs, abs_of_pos (by linarith)]
      linarith
    fin_cases i <;> fin_cases j <;> fin_cases k <;>
      simp only [wPert, wState, Fin.zero_eta, Fin.mk_one, Fin.isValue, Matrix.cons_val_zero,
        Matrix.cons_val_one, sub_self, norm_zero, sub_zero] <;>
      first
        | exact hε
        | exact ht
  · rw [slocc_ghz_iff_hyperdet_ne_zero, hyperdet_wPert]
    refine mul_ne_zero (mul_ne_zero (by norm_num) (pow_ne_zero _ c3_ne_zero)) ?_
    simp only [ne_eq, Complex.ofReal_eq_zero]
    positivity

/-! ## An explicit polynomial criterion for biseparability

The classification above is an existence statement about invertible matrices.  Here we make it
effective: each of the three biseparability predicates is equivalent to the vanishing of all
`2 × 2` minors of the corresponding flattening, so `Genuine` — and hence the whole trichotomy —
is decided by finitely many polynomial equations in the eight amplitudes. -/

/-- A two-row matrix (over an arbitrary index type) all of whose `2 × 2` minors vanish has
rank `≤ 1`. -/
theorem rank_le_one_of_minors {ι : Type*} (m : Fin 2 → ι → ℂ)
    (h : ∀ x y, m 0 x * m 1 y = m 0 y * m 1 x) :
    ∃ u : Fin 2 → ℂ, ∃ v : ι → ℂ, ∀ i x, m i x = u i * v x := by
  by_cases hz : ∀ x, m 0 x = 0
  · refine ⟨![0, 1], m 1, ?_⟩
    intro i x
    fin_cases i <;> simp [hz x]
  · push_neg at hz
    obtain ⟨x0, hx0⟩ := hz
    refine ⟨![m 0 x0, m 1 x0], fun x => m 0 x / m 0 x0, ?_⟩
    intro i x
    fin_cases i
    · show m 0 x = m 0 x0 * (m 0 x / m 0 x0)
      field_simp
    · show m 1 x = m 1 x0 * (m 0 x / m 0 x0)
      field_simp
      linear_combination h x0 x

/-- Biseparability across the `A | BC` cut is the vanishing of all `2 × 2` minors of the
`2 × 4` flattening of `ψ` along Alice. -/
theorem isProductA_iff_minors (a : Amp) :
    IsProductA a ↔ ∀ j k j' k', a 0 j k * a 1 j' k' = a 0 j' k' * a 1 j k := by
  constructor
  · rintro ⟨u, v, h⟩ j k j' k'
    simp only [h]; ring
  · intro h
    obtain ⟨u, v, hv⟩ :=
      rank_le_one_of_minors (ι := Fin 2 × Fin 2) (fun i x => a i x.1 x.2)
        (fun x y => h x.1 x.2 y.1 y.2)
    exact ⟨u, fun j k => v (j, k), fun i j k => hv i (j, k)⟩

/-- Biseparability across the `B | AC` cut, as a minor condition. -/
theorem isProductB_iff_minors (a : Amp) :
    IsProductB a ↔ ∀ i k i' k', a i 0 k * a i' 1 k' = a i' 0 k' * a i 1 k := by
  constructor
  · rintro ⟨u, v, h⟩ i k i' k'
    simp only [h]; ring
  · intro h
    obtain ⟨u, v, hv⟩ :=
      rank_le_one_of_minors (ι := Fin 2 × Fin 2) (fun j x => a x.1 j x.2)
        (fun x y => h x.1 x.2 y.1 y.2)
    exact ⟨u, fun i k => v (i, k), fun i j k => hv j (i, k)⟩

/-- Biseparability across the `C | AB` cut, as a minor condition. -/
theorem isProductC_iff_minors (a : Amp) :
    IsProductC a ↔ ∀ i j i' j', a i j 0 * a i' j' 1 = a i' j' 0 * a i j 1 := by
  constructor
  · rintro ⟨u, v, h⟩ i j i' j'
    simp only [h]; ring
  · intro h
    obtain ⟨u, v, hv⟩ :=
      rank_le_one_of_minors (ι := Fin 2 × Fin 2) (fun k x => a x.1 x.2 k)
        (fun x y => h x.1 x.2 y.1 y.2)
    exact ⟨u, fun i j => v (i, j), fun i j k => hv k (i, j)⟩

/-- **Effective form of the trichotomy.**  Membership in each SLOCC class is decided by
polynomial (in)equalities in the eight amplitudes: three families of `2 × 2` minors for genuine
entanglement, and Cayley's hyperdeterminant to separate GHZ from W. -/
theorem slocc_class_criterion (a : Amp) :
    (SLOCC a ghz ↔ hyperdet a ≠ 0) ∧
    (SLOCC a wState ↔
      ((¬ ∀ j k j' k', a 0 j k * a 1 j' k' = a 0 j' k' * a 1 j k) ∧
       (¬ ∀ i k i' k', a i 0 k * a i' 1 k' = a i' 0 k' * a i 1 k) ∧
       (¬ ∀ i j i' j', a i j 0 * a i' j' 1 = a i' j' 0 * a i j 1) ∧
       hyperdet a = 0)) := by
  refine ⟨slocc_ghz_iff_hyperdet_ne_zero a, ?_⟩
  rw [slocc_wState_iff, Genuine, isProductA_iff_minors, isProductB_iff_minors,
    isProductC_iff_minors]
  tauto

end ThreeQubitGHZ