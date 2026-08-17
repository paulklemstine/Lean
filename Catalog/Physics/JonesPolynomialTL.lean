/-
# The Reshetikhin–Turaev / Kauffman bracket invariant of the `(2,n)` torus links

Building on the Temperley–Lieb machinery of `Catalog/Physics/QuantumSL2Braiding.lean` we compute
the Reshetikhin–Turaev invariant produced by the representation theory of `U_q(sl₂)` for the
closures of the two-strand braids `σ₁ⁿ`, i.e. for the `(2,n)` torus links (unknot, Hopf link,
trefoil, ...).

## Method

Inside any `k`-algebra containing a Temperley–Lieb generator `e` with `e² = δ e`,
`δ = -A² - A⁻²`, the Kauffman braiding is `g = A·1 + A⁻¹·e`.  Expanding `gⁿ` gives
`gⁿ = Aⁿ·1 + bₙ·e` (`kauffman_pow`) with an explicit recursion for `bₙ`, whose closed form is
`δ·bₙ = (-1)ⁿ A^{-3n} - Aⁿ` (`loopValue_mul_bCoeff`).  Applying the Markov trace of the
Temperley–Lieb algebra `TL₂` (the closure of the diagram `1` is a two-component unlink, of value
`δ`; the closure of `e` is a single circle, of value `1`) gives the Kauffman bracket of the
closed braid, and multiplying by the writhe correction `(-A³)^{-n}` gives the Jones polynomial
in the variable `t = A⁻⁴`.

*What is and is not formalised.*  The Markov-trace formula is taken here as the **definition**
of the invariant of the closed braid `σ₁ⁿ`; the diagrammatic Reidemeister invariance is not
formalised.  What *is* proved is (i) the exact algebra of the Temperley–Lieb expansion, (ii) the
closed form of the bracket for every `n`, (iii) the classical normalisation check
`V(unknot) = 1`, and (iv) the value `V = t + t³ - t⁴` for the trefoil, which differs from the
unknot's.  The two algebraic Reidemeister moves themselves — R-II (`kauffman_mul_inv`) and R-III
(`kauffman_braid_relation`) — are proved in `QuantumSL2Braiding`.

## Main results

* `QuantumJones.kauffman_pow` — the Temperley–Lieb expansion of `gⁿ`.
* `QuantumJones.loopValue_mul_bCoeff` — closed form of the expansion coefficient.
* `QuantumJones.bracket_closed_form` — closed form of the bracket of the `(2,n)` torus link.
* `QuantumJones.jones_unknot` — normalisation: the closure of `σ₁` gives `V = 1`.
* `QuantumJones.bracket_hopf`, `QuantumJones.jones_trefoil` — the Hopf link and the trefoil.
* `QuantumJones.jones_trefoil_ne_unknot` — the trefoil value differs from the unknot value.
-/

import Mathlib
import Physics.QuantumSL2Braiding

namespace QuantumJones

open QuantumBraiding

section TL

variable {k : Type*} [Field k] {R : Type*} [Ring R] [Algebra k R]

/-- The coefficient of the Temperley–Lieb generator in `gⁿ`, where `g = A·1 + A⁻¹·e`. -/
noncomputable def bCoeff (A : k) : ℕ → k
  | 0 => 0
  | n + 1 => A * bCoeff A n + A⁻¹ * A ^ n + A⁻¹ * loopValue A * bCoeff A n

@[simp] theorem bCoeff_zero (A : k) : bCoeff A 0 = 0 := rfl

theorem bCoeff_succ (A : k) (n : ℕ) :
    bCoeff A (n + 1) = A * bCoeff A n + A⁻¹ * A ^ n + A⁻¹ * loopValue A * bCoeff A n := rfl

/-- **Temperley–Lieb expansion of a power of the braiding.** -/
theorem kauffman_pow {A : k} {e : R} (he : e * e = loopValue A • e) (n : ℕ) :
    (kauffman A e) ^ n = (A ^ n) • (1 : R) + bCoeff A n • e := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [pow_succ, ih, kauffman, bCoeff_succ]
      simp only [add_mul, mul_add, smul_mul_assoc, mul_smul_comm, one_mul, mul_one, smul_smul, he]
      match_scalars <;> ring

/-- **Closed form of the Temperley–Lieb coefficient**: `δ·bₙ = (-1)ⁿ A^{-3n} - Aⁿ`. -/
theorem loopValue_mul_bCoeff {A : k} (hA : A ≠ 0) (n : ℕ) :
    loopValue A * bCoeff A n = (-1) ^ n * (A⁻¹) ^ (3 * n) - A ^ n := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [bCoeff_succ]
      have expand : loopValue A * (A * bCoeff A n + A⁻¹ * A ^ n + A⁻¹ * loopValue A * bCoeff A n)
          = A * (loopValue A * bCoeff A n) + A⁻¹ * A ^ n * loopValue A
            + A⁻¹ * loopValue A * (loopValue A * bCoeff A n) := by ring
      rw [expand, ih]
      simp only [loopValue, pow_succ, pow_mul]
      field_simp
      ring

/-! ### The Markov trace and the bracket of the `(2,n)` torus link -/

/-- The Kauffman bracket of the closure of the two-strand braid `σ₁ⁿ`, obtained from the Markov
trace on `TL₂`: the closure of `1` is a two-component unlink (value `δ`) and the closure of `e`
is a single circle (value `1`). -/
noncomputable def bracket (A : k) (n : ℕ) : k := A ^ n * loopValue A + bCoeff A n

/-- The writhe-corrected (Jones) invariant of the closure of `σ₁ⁿ`. -/
noncomputable def jones (A : k) (n : ℕ) : k := (-(A⁻¹) ^ 3) ^ n * bracket A n

/-- **Closed form of the bracket of the `(2,n)` torus link.** -/
theorem bracket_closed_form {A : k} (hA : A ≠ 0) (n : ℕ) :
    loopValue A * bracket A n
      = loopValue A ^ 2 * A ^ n + (-1) ^ n * (A⁻¹) ^ (3 * n) - A ^ n := by
  rw [bracket, mul_add, loopValue_mul_bCoeff hA n]
  ring

/-- Normalisation check: the closure of `σ₁` is the unknot and its invariant is `1`. -/
theorem jones_unknot {A : k} (hA : A ≠ 0) : jones A 1 = 1 := by
  simp only [jones, bracket, bCoeff_succ, bCoeff_zero, loopValue, pow_one, pow_zero]
  field_simp
  ring

/-- The Kauffman bracket of the Hopf link (the closure of `σ₁²`) is `-A⁴ - A⁻⁴`. -/
theorem bracket_hopf {A : k} (hA : A ≠ 0) : bracket A 2 = -A ^ 4 - (A⁻¹) ^ 4 := by
  simp only [bracket, bCoeff_succ, bCoeff_zero, loopValue]
  field_simp
  ring

/-- The Kauffman bracket of the trefoil (the closure of `σ₁³`) is `-A⁵ - A⁻³ + A⁻⁷`. -/
theorem bracket_trefoil {A : k} (hA : A ≠ 0) :
    bracket A 3 = -A ^ 5 - (A⁻¹) ^ 3 + (A⁻¹) ^ 7 := by
  simp only [bracket, bCoeff_succ, bCoeff_zero, loopValue]
  field_simp
  ring

/-- **The Jones polynomial of the trefoil**: `V = t + t³ - t⁴` in the variable `t = A⁻⁴`. -/
theorem jones_trefoil {A : k} (hA : A ≠ 0) :
    jones A 3 = (A⁻¹) ^ 4 + ((A⁻¹) ^ 4) ^ 3 - ((A⁻¹) ^ 4) ^ 4 := by
  rw [jones, bracket_trefoil hA]
  field_simp
  ring

end TL

/-- The invariant of the trefoil differs from that of the unknot.  (Combined with the
Reidemeister invariance of the bracket — proved algebraically in `QuantumSL2Braiding` as
`kauffman_mul_inv` and `kauffman_braid_relation` — this is the classical proof that the trefoil
is knotted.) -/
theorem jones_trefoil_ne_unknot : (fun A : ℝ => jones A 3) ≠ (fun A : ℝ => jones A 1) := by
  intro h
  have h2 := congrFun h 2
  rw [jones_trefoil (by norm_num : (2 : ℝ) ≠ 0), jones_unknot (by norm_num : (2 : ℝ) ≠ 0)] at h2
  norm_num at h2

end QuantumJones