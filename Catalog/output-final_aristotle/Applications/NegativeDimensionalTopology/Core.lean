/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Negative-Dimensional Topology: What Lives in Dimension -1?

A rigorous, self-contained algebraic model of *negative-dimensional spaces* and a
proof that the Euler characteristic extends to negative dimensions.

## The model

We represent a (virtual) graded space by its **cellular Poincaré datum**: a finitely
supported function `ℤ → ℤ` recording, for each dimension `d ∈ ℤ` (allowed negative!),
the virtual number of `d`-dimensional cells.  Algebraically this is the group algebra
`ℤ[ℤ] = AddMonoidAlgebra ℤ ℤ`, i.e. the ring of Laurent polynomials `ℤ[t, t⁻¹]` where
`tᵈ = single d 1` is "one cell in dimension `d`".  Negative powers of `t` are exactly
the negative-dimensional cells.  This is the pro-spectrum / Spanier–Whitehead picture
made concrete: desuspension `·t⁻¹` produces negative dimensions.

The **Euler characteristic** is the ring homomorphism
`χ : ℤ[t,t⁻¹] → ℤ,  t ↦ -1`,
i.e. `χ(∑ b_d tᵈ) = ∑ (-1)ᵈ b_d`.  Being a ring homomorphism encodes at once:
* additivity under disjoint union / wedge (`χ(X ⊔ Y) = χ X + χ Y`), and
* multiplicativity under product (`χ(X × Y) = χ X · χ Y`, a Künneth formula),
and it makes perfect sense on *negative* degrees.

## Headline results

* `chi_pure_neg` : for a space of dimension `-n` with `k = |π₀|` components,
  `χ(X) = (-1)ⁿ · |π₀(X)|`  — the requested extension of Euler characteristic.
* `chi_dim_neg_one` : *what lives in dimension `-1`* — a `k`-component `(-1)`-space
  has `χ = -k`.
* `chi_susp` / `chi_desusp` : suspension and desuspension flip the sign of `χ`.
* `susp_desusp`, `desusp_susp` : suspension and desuspension are mutually inverse —
  the **stabilization map** identifying negative with positive dimensions.
* `stabilize_neg` : suspending a `(-n)`-space `n` times lands it in dimension `0`.
* `disproof_all_neg_chi`, `disproof_chi_not_injective` : two natural conjectures that
  turn out to be **false** (contrarian disproofs).
-/
import Mathlib

namespace NegDim

/-- Virtual graded space: `ℤ[t,t⁻¹]`.  The coefficient at degree `d ∈ ℤ` records the
virtual number of `d`-dimensional cells; `d` may be negative. -/
abbrev VSpace := AddMonoidAlgebra ℤ ℤ

/-- `cell d c`: `c` cells placed in dimension `d` (the monomial `c · tᵈ`). -/
noncomputable def cell (d : ℤ) (c : ℤ) : VSpace := AddMonoidAlgebra.single d c

/-- The empty 0-cell `t⁰` is the multiplicative unit (the one-point space). -/
theorem cell_zero_one : cell 0 1 = 1 := by rw [cell]; rfl

/-- The sign monoid homomorphism `n ↦ (-1)ⁿ` underlying the Euler characteristic. -/
noncomputable def euSignHom : Multiplicative ℤ →* ℤ where
  toFun n := (Int.negOnePow (Multiplicative.toAdd n) : ℤ)
  map_one' := by simp
  map_mul' a b := by
    show (Int.negOnePow (Multiplicative.toAdd a + Multiplicative.toAdd b) : ℤ) = _
    rw [Int.negOnePow_add]; push_cast; ring

/-- **Euler characteristic** as a ring homomorphism `χ : ℤ[t,t⁻¹] → ℤ`, `t ↦ -1`. -/
noncomputable def chi : VSpace →+* ℤ := (AddMonoidAlgebra.lift ℤ ℤ ℤ euSignHom).toRingHom

/-- Euler characteristic of a single stratum: `χ(c · tᵈ) = (-1)ᵈ · c`. -/
@[simp] theorem chi_cell (d c : ℤ) : chi (cell d c) = (Int.negOnePow d : ℤ) * c := by
  simp only [chi, cell, AlgHom.toRingHom_eq_coe, RingHom.coe_coe, AddMonoidAlgebra.lift_single]
  rw [zsmul_eq_mul]
  show (c : ℤ) * (Int.negOnePow d : ℤ) = (Int.negOnePow d : ℤ) * c
  ring

/-- **Multiplicativity (Künneth).** `χ(X × Y) = χ X · χ Y`. -/
theorem chi_mul (x y : VSpace) : chi (x * y) = chi x * chi y := map_mul _ _ _

/-- **Additivity.** `χ(X ⊔ Y) = χ X + χ Y`. -/
theorem chi_add (x y : VSpace) : chi (x + y) = chi x + chi y := map_add _ _ _

/-- The one-point space has Euler characteristic `1`. -/
theorem chi_one : chi 1 = 1 := map_one _

/-- **Suspension** `Σ`: raise every dimension by one (multiply by `t`). -/
noncomputable def susp (x : VSpace) : VSpace := cell 1 1 * x

/-- **Desuspension** `Σ⁻¹`: lower every dimension by one (multiply by `t⁻¹`).  This is
the operation that *creates* negative dimensions. -/
noncomputable def desusp (x : VSpace) : VSpace := cell (-1) 1 * x

theorem susp_cell (d c : ℤ) : susp (cell d c) = cell (d + 1) c := by
  simp only [susp, cell, AddMonoidAlgebra.single_mul_single]; rw [one_mul, add_comm]

theorem desusp_cell (d c : ℤ) : desusp (cell d c) = cell (d - 1) c := by
  simp only [desusp, cell, AddMonoidAlgebra.single_mul_single]; rw [one_mul]; ring_nf

/-- **Stabilization is invertible (I).** `Σ ∘ Σ⁻¹ = id`. -/
theorem susp_desusp (x : VSpace) : susp (desusp x) = x := by
  simp only [susp, desusp, cell, ← mul_assoc, AddMonoidAlgebra.single_mul_single, one_mul]
  norm_num

/-- **Stabilization is invertible (II).** `Σ⁻¹ ∘ Σ = id`. -/
theorem desusp_susp (x : VSpace) : desusp (susp x) = x := by
  simp only [susp, desusp, cell, ← mul_assoc, AddMonoidAlgebra.single_mul_single, one_mul]
  norm_num

/-- **Suspension flips the Euler characteristic.** `χ(ΣX) = -χ(X)`. -/
theorem chi_susp (x : VSpace) : chi (susp x) = - chi x := by simp [susp, chi_mul]

/-- **Desuspension flips the Euler characteristic.** `χ(Σ⁻¹X) = -χ(X)`. -/
theorem chi_desusp (x : VSpace) : chi (desusp x) = - chi x := by simp [desusp, chi_mul]

/-- Iterated suspension `Σⁿ`. -/
noncomputable def suspIter (n : ℕ) (x : VSpace) : VSpace := susp^[n] x

theorem suspIter_cell (n : ℕ) (d c : ℤ) : suspIter n (cell d c) = cell (d + n) c := by
  induction n with
  | zero => simp [suspIter]
  | succ m ih =>
    rw [suspIter, Function.iterate_succ', Function.comp_apply, ← suspIter, ih, susp_cell]
    push_cast; ring_nf

/-- `χ(ΣⁿX) = (-1)ⁿ · χ(X)`. -/
theorem chi_suspIter (n : ℕ) (x : VSpace) : chi (suspIter n x) = (-1) ^ n * chi x := by
  induction n with
  | zero => simp [suspIter]
  | succ m ih =>
    rw [suspIter, Function.iterate_succ', Function.comp_apply, ← suspIter, chi_susp, ih]; ring

/-- A **pure negative-dimensional space**: `components` points concentrated in
dimension `dim`.  Its set of path components `π₀` is a discrete set of size
`components`. -/
structure PureSpace where
  dim : ℤ
  components : ℕ

/-- Realization of a pure space inside `ℤ[t,t⁻¹]`. -/
noncomputable def PureSpace.toV (P : PureSpace) : VSpace := cell P.dim (P.components : ℤ)

/-- `|π₀(X)|`, the number of connected components. -/
def PureSpace.pi0card (P : PureSpace) : ℕ := P.components

/-- **Main theorem: Euler characteristic in negative dimensions.**
For a space `X` of dimension `-n` with `k = |π₀(X)|` components,
`χ(X) = (-1)ⁿ · |π₀(X)|`. -/
theorem chi_pure_neg (P : PureSpace) (n : ℕ) (h : P.dim = -(n : ℤ)) :
    chi P.toV = (-1) ^ n * (P.pi0card : ℤ) := by
  rw [PureSpace.toV, PureSpace.pi0card, h, chi_cell, Int.negOnePow_neg, Int.coe_negOnePow_natCast]

/-- Unbundled form of the main theorem. -/
theorem chi_neg_dim (n : ℕ) (k : ℤ) : chi (cell (-(n : ℤ)) k) = (-1) ^ n * k := by
  rw [chi_cell, Int.negOnePow_neg, Int.coe_negOnePow_natCast]

/-- **What lives in dimension `-1`.** A `k`-component `(-1)`-dimensional space has
Euler characteristic `-k`.  (In particular, the "`(-1)`-sphere" — one point in
dimension `-1` — has `χ = -1`.) -/
theorem chi_dim_neg_one (k : ℕ) : chi (cell (-1) (k : ℤ)) = -(k : ℤ) := by
  have h : (-1 : ℤ) = -((1 : ℕ) : ℤ) := by norm_num
  rw [h, chi_cell, Int.negOnePow_neg, Int.coe_negOnePow_natCast]; ring

/-- **The stabilization map from negative to positive dimensions.**
Suspending a `(-n)`-dimensional space exactly `n` times yields a genuine
0-dimensional space with the same components — realizing the negative-dimensional
space as a stable desuspension of an honest space. -/
theorem stabilize_neg (n : ℕ) (k : ℤ) : suspIter n (cell (-(n : ℤ)) k) = cell 0 k := by
  rw [suspIter_cell]; ring_nf

/-- Consistency of the stabilization: after suspending a `(-n)`-space `n` times it sits
in dimension `0` with `χ = k`, matching `χ(ΣⁿX) = (-1)ⁿ χ(X) = (-1)ⁿ · (-1)ⁿ k = k`. -/
theorem stabilize_chi (n : ℕ) (k : ℤ) : chi (suspIter n (cell (-(n : ℤ)) k)) = k := by
  rw [stabilize_neg, chi_cell]; simp

/-! ## Contrarian conjectures: two natural guesses that are FALSE -/

/-- **Disproof 1.**  *Conjecture:* every negative-dimensional space (dimension `-n`,
`n ≥ 1`, with `k ≥ 1` components) has **negative** Euler characteristic.
*False:* even dimensions give a positive sign.  A `1`-component `(-2)`-dimensional
space has `χ = +1 > 0`. -/
theorem disproof_all_neg_chi :
    ¬ (∀ (n k : ℕ), 1 ≤ n → 1 ≤ k → chi (cell (-(n : ℤ)) (k : ℤ)) < 0) := by
  intro h
  have H := h 2 1 (by norm_num) (by norm_num)
  rw [chi_cell] at H
  revert H
  decide

/-- **Disproof 2.**  *Conjecture:* the Euler characteristic is injective, i.e. it
remembers the dimension.  *False:* `χ` only sees the parity of the dimension, so a
0-dimensional point and a 2-dimensional cell are distinct spaces with the same
`χ = 1`. -/
theorem disproof_chi_not_injective : ∃ x y : VSpace, x ≠ y ∧ chi x = chi y := by
  refine ⟨cell 0 1, cell 2 1, ?_, ?_⟩
  · intro h
    have h0 : (cell 0 1) 0 = (cell 2 1) 0 := by rw [h]
    rw [cell, cell, Finsupp.single_eq_same, Finsupp.single_eq_of_ne (by norm_num)] at h0
    exact one_ne_zero h0
  · rw [chi_cell, chi_cell]; decide

end NegDim