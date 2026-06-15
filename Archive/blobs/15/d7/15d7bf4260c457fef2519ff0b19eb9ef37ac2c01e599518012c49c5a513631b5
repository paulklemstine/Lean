/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Topological Order, Genus Degeneracy, and Modular Data for Abelian Anyons

## Bridge: Finite Abelian Groups → Topological Quantum Field Theory → Quantum Memory

For an *abelian* anyon theory whose anyon labels form a finite abelian group `A` with
quantum dimension `d = |A|`, this file proves two complementary halves of the
anyon–TQFT dictionary:

1. **Ground-state degeneracy (GSD).** On a genus-`g` surface the ground space has
   dimension `GSD A g = d ^ g`.  We prove the per-handle recursion
   `GSD A (g+1) = d · GSD A g`, the connected-sum multiplicativity
   `GSD A (g+h) = GSD A g · GSD A h`, and the identification of `GSD A g` with the
   complex dimension of the free ground-state Hilbert space `(Fin g → A) →₀ ℂ`.

2. **Modular S-matrix.** From a nondegenerate braiding bicharacter we build the
   modular S-matrix `S_{a,b} = (1/√d) · χ_a(b)` and prove it is **unitary**,
   `∑_c S_{a,c} · conj S_{b,c} = δ_{a,b}`, via character orthogonality on `A`.

3. **A fully worked example.** For the cyclic anyon model `A = ZMod n` we *construct*
   an explicit `ModularBraiding (ZMod n)` from `ZMod.stdAddChar`, turning the
   conditional unitarity theorem into an unconditional statement and exhibiting the
   discrete Fourier matrix `S_{a,b} = (1/√n) exp(2πi a b / n)`.

This extends the catalog result `ToricCode.ground_space_dim` (which fixes the `ℤ/2`
toric code at the single value `4` on the torus) to *all* abelian anyon theories and
*all* genera, and supplies the previously missing braiding / modular-data half.
-/

import Mathlib

open Finset
open scoped ComplexConjugate

namespace TopologicalOrderGenus

/-! ## Section 1: Ground-State Degeneracy on Genus-`g` Surfaces

For an abelian theory the genus-`g` ground space is `A^{⊗g}`, so its dimension is
`|A|^g`.  We package this as `GSD` and prove its structural laws. -/

/-- Ground-state degeneracy of an abelian anyon theory `A` on a genus-`g` surface. -/
def GSD (A : Type*) [Fintype A] (g : ℕ) : ℕ := Fintype.card A ^ g

variable {A : Type*}

-- !-- `GSD A g = d ^ g` by definition; the closed-form degeneracy law. -- !--
/-- **Closed form.** The genus-`g` degeneracy equals `d ^ g` with `d = |A|`. -/
theorem GSD_eq_pow [Fintype A] (g : ℕ) : GSD A g = Fintype.card A ^ g := rfl

-- !-- Each added handle multiplies the degeneracy by `d = |A|`; this is `pow_succ`. -- !--
/-- **Per-handle recursion.** Adding one handle multiplies degeneracy by `d`. -/
theorem GSD_handle [Fintype A] (g : ℕ) : GSD A (g + 1) = Fintype.card A * GSD A g := by
  rw [GSD, GSD, pow_succ, mul_comm]

-- !-- Genus is additive under connected sum, so degeneracy is multiplicative (`pow_add`). -- !--
/-- **Connected-sum multiplicativity.** `Σ_g # Σ_h` has degeneracy
    `GSD A g · GSD A h` since genus adds under connected sum. -/
theorem GSD_connected_sum [Fintype A] (g h : ℕ) :
    GSD A (g + h) = GSD A g * GSD A h := by
  rw [GSD, GSD, GSD, pow_add]

-- !-- The torus (`g = 1`) degeneracy is exactly `|A|`, the count of anyon types. -- !--
/-- **Torus.** On the torus the degeneracy is the number of anyon types. -/
theorem GSD_torus [Fintype A] : GSD A 1 = Fintype.card A := by
  rw [GSD, pow_one]

-- !-- The basis of the ground space is the set of flat configurations `Fin g → A`. -- !--
/-- **Combinatorial model.** `GSD A g` counts the configurations `Fin g → A`. -/
theorem GSD_eq_card_fun [Fintype A] (g : ℕ) :
    GSD A g = Fintype.card (Fin g → A) := by
  rw [GSD, Fintype.card_pi_const]

-- !-- The free ℂ-vector space on `Fin g → A` has finrank equal to its cardinality, `d^g`. -- !--
/-- **Hilbert-space dimension.** The free ground-state Hilbert space
    `(Fin g → A) →₀ ℂ` has complex dimension `GSD A g = d ^ g`. -/
theorem GSD_eq_finrank [Fintype A] (g : ℕ) :
    Module.finrank ℂ ((Fin g → A) →₀ ℂ) = GSD A g := by
  rw [Module.finrank_finsupp_self, GSD, Fintype.card_pi_const]

/-! ## Section 2: Modular Braiding and the Unitary S-matrix

A nondegenerate braiding on an abelian theory is a self-pairing of `A` by additive
characters, i.e. a group homomorphism `a ↦ χ_a` into `AddChar A ℂ` whose only element
pairing trivially with everything is `0`.  We encode this minimally. -/

/-- A **modular braiding** on a finite abelian group `A`: a family of additive
    characters `χ_a` depending homomorphically on `a` (`χ_{a+a'} = χ_a · χ_{a'}`) and
    *nondegenerate* (only `a = 0` gives the trivial character).  This is the abelian
    anyon braiding bicharacter `(a,b) ↦ χ_a(b)`. -/
structure ModularBraiding (A : Type*) [AddCommGroup A] [Fintype A] where
  /-- The braiding character of anyon `a`. -/
  chi : A → AddChar A ℂ
  /-- The braiding is bilinear: `χ_{a+a'} = χ_a · χ_{a'}`. -/
  map_add' : ∀ a a', chi (a + a') = chi a * chi a'
  /-- Nondegeneracy: only the vacuum braids trivially with everything. -/
  nondeg : ∀ a, chi a = 0 → a = 0

namespace ModularBraiding

variable {A : Type*} [AddCommGroup A] [Fintype A] (M : ModularBraiding A)

-- !-- `χ_0 = χ_0 · χ_0` forces `χ_0 = 1`, the trivial character. -- !--
/-- The vacuum braids trivially: `χ_0` is the trivial character. -/
lemma map_zero : M.chi 0 = 0 := by
  have h := M.map_add' 0 0
  rw [add_zero] at h
  have h2 : M.chi 0 * M.chi 0 = 1 * M.chi 0 := by rw [one_mul]; exact h.symm
  rw [mul_right_cancel h2, AddChar.one_eq_zero]

-- !-- From `χ_a · χ_{-a} = χ_0 = 1` we read off `χ_{-a} = χ_a⁻¹`. -- !--
/-- Antipode: `χ_{-a} = χ_a⁻¹`. -/
lemma map_neg (a : A) : M.chi (-a) = (M.chi a)⁻¹ := by
  have h := M.map_add' a (-a)
  rw [add_neg_cancel, M.map_zero, ← AddChar.one_eq_zero] at h
  exact eq_inv_of_mul_eq_one_left (by rw [mul_comm]; exact h.symm)

-- !-- If `χ_a = χ_b` then `χ_{a-b} = 1`, so nondegeneracy gives `a = b`. -- !--
/-- Nondegeneracy makes the assignment `a ↦ χ_a` injective. -/
lemma chi_injective : Function.Injective M.chi := by
  intro a b hab
  have hz : M.chi (a - b) = 0 := by
    rw [sub_eq_add_neg, M.map_add', M.map_neg, hab, mul_inv_cancel, AddChar.one_eq_zero]
  exact sub_eq_zero.mp (M.nondeg _ hz)

/-- `χ_a · χ_b⁻¹` is the trivial character iff `a = b`. -/
lemma chi_diff_eq_zero_iff (a b : A) : M.chi a * (M.chi b)⁻¹ = 0 ↔ a = b := by
  rw [← AddChar.one_eq_zero, mul_inv_eq_one]
  exact ⟨fun h => M.chi_injective h, fun h => by rw [h]⟩

-- !-- `χ_a(c) · conj χ_b(c) = (χ_a · χ_b⁻¹)(c)`; summing and using `AddChar.sum_eq_ite`
--     (character orthogonality) gives `|A|` if `a = b` and `0` otherwise. -- !--
/-- **Character orthogonality.** The rows of the braiding character table are
    orthogonal: `∑_c χ_a(c) · conj χ_b(c) = |A| · δ_{a,b}`. -/
theorem chi_orthogonality [DecidableEq A] (a b : A) :
    ∑ c, M.chi a c * conj (M.chi b c) = if a = b then (Fintype.card A : ℂ) else 0 := by
  classical
  have key : ∀ c, M.chi a c * conj (M.chi b c) = (M.chi a * (M.chi b)⁻¹) c := by
    intro c
    rw [AddChar.coe_mul]
    simp only [Pi.mul_apply]
    rw [AddChar.inv_apply', ← AddChar.inv_apply_eq_conj]
  simp_rw [key]
  rw [AddChar.sum_eq_ite]
  exact if_congr (M.chi_diff_eq_zero_iff a b) rfl rfl

/-- The modular **S-matrix** entry `S_{a,b} = (1/√d) · χ_a(b)` with `d = |A|`. -/
noncomputable def Smatrix (a b : A) : ℂ := (1 / Real.sqrt (Fintype.card A)) * M.chi a b

-- !-- Pull out the constant `(1/√d)·conj(1/√d) = 1/d` from each summand and apply
--     `chi_orthogonality`; the `1/d · |A|` collapses to `1` on the diagonal. -- !--
/-- **Unitarity of the modular S-matrix.** `∑_c S_{a,c} · conj S_{b,c} = δ_{a,b}`,
    i.e. `S S† = 1`.  This is the central structural property of modular data. -/
theorem smatrix_unitary [DecidableEq A] (a b : A) :
    ∑ c, M.Smatrix a c * conj (M.Smatrix b c) = if a = b then (1 : ℂ) else 0 := by
  have hd : (0 : ℝ) < Fintype.card A := by exact_mod_cast Fintype.card_pos
  have hsq : (1 / (Real.sqrt (Fintype.card A) : ℂ)) * (1 / (Real.sqrt (Fintype.card A) : ℂ))
      = 1 / (Fintype.card A : ℂ) := by
    rw [div_mul_div_comm, one_mul, ← Complex.ofReal_mul, Real.mul_self_sqrt hd.le,
      Complex.ofReal_natCast]
  have hcr : conj (1 / (Real.sqrt (Fintype.card A) : ℂ)) = 1 / (Real.sqrt (Fintype.card A) : ℂ) := by
    rw [map_div₀, map_one, Complex.conj_ofReal]
  have step : ∀ c, M.Smatrix a c * conj (M.Smatrix b c)
      = (1 / (Fintype.card A : ℂ)) * (M.chi a c * conj (M.chi b c)) := by
    intro c
    rw [Smatrix, Smatrix, map_mul, hcr, mul_mul_mul_comm, hsq]
  simp_rw [step]
  rw [← Finset.mul_sum, M.chi_orthogonality a b]
  by_cases h : a = b
  · simp only [h, if_true]
    rw [div_mul_cancel₀]
    exact_mod_cast Fintype.card_ne_zero
  · simp only [h, if_false, mul_zero]

end ModularBraiding

/-! ## Section 3: The Cyclic Anyon Model `ZMod n` — a Fully Worked Example

We now *construct* a modular braiding on `A = ZMod n` from the standard additive
character `j ↦ exp(2πi j / n)`, realizing the discrete Fourier matrix and upgrading
the abstract unitarity theorem to an unconditional statement. -/

-- !-- Take `χ_a = mulShift stdAddChar a` (so `χ_a(b) = exp(2πi a b / n)`); bilinearity is
--     `AddChar.mulShift_mul` and nondegeneracy is primitivity of `stdAddChar`. -- !--
/-- The **cyclic anyon braiding** on `ZMod n`: `χ_a(b) = exp(2πi a b / n)`, built from
    `ZMod.stdAddChar`.  Bilinearity is `mulShift_mul`; nondegeneracy is primitivity. -/
noncomputable def cyclicBraiding (n : ℕ) [NeZero n] : ModularBraiding (ZMod n) where
  chi a := (ZMod.stdAddChar (N := n)).mulShift a
  map_add' a a' := (AddChar.mulShift_mul _ a a').symm
  nondeg a h := by
    by_contra ha
    rw [← AddChar.one_eq_zero] at h
    exact ZMod.isPrimitive_stdAddChar n ha h

-- !-- Unfold `Smatrix` and `mulShift_apply`: the braiding entry is `exp(2πi a b / n)`. -- !--
/-- The cyclic S-matrix is the **discrete Fourier matrix**
    `S_{a,b} = (1/√n) · exp(2πi a b / n)`. -/
theorem cyclicBraiding_Smatrix (n : ℕ) [NeZero n] (a b : ZMod n) :
    (cyclicBraiding n).Smatrix a b
      = (1 / Real.sqrt (Fintype.card (ZMod n))) * ZMod.stdAddChar (a * b) := by
  rw [ModularBraiding.Smatrix]
  rfl

-- !-- Direct corollary of `smatrix_unitary` applied to the constructed `cyclicBraiding`. -- !--
/-- **Unconditional unitarity** of the cyclic (discrete-Fourier) S-matrix. -/
theorem cyclic_smatrix_unitary (n : ℕ) [NeZero n] (a b : ZMod n) :
    ∑ c, (cyclicBraiding n).Smatrix a c * conj ((cyclicBraiding n).Smatrix b c)
      = if a = b then (1 : ℂ) else 0 :=
  (cyclicBraiding n).smatrix_unitary a b

-- !-- Toric-code matching: with `A = ZMod 2 × ZMod 2` we recover `GSD = 4^g`, and `4`
--     on the torus, matching `ToricCode.ground_space_dim`. -- !--
/-- **Bridge to the toric code.** The four-anyon theory `(ZMod 2)²` has genus-`g`
    degeneracy `4^g`; on the torus this is `4`, matching `ToricCode.ground_space_dim`. -/
theorem toricCode_GSD (g : ℕ) : GSD (ZMod 2 × ZMod 2) g = 4 ^ g := by
  rw [GSD]
  norm_num

/-- On the torus the `(ZMod 2)²` toric code has the expected `4`-fold degeneracy. -/
theorem toricCode_torus_GSD : GSD (ZMod 2 × ZMod 2) 1 = 4 := by
  rw [toricCode_GSD]; norm_num

/-! ## Section 4: Examples and a Boundary Case -/

example (g : ℕ) : GSD (ZMod 5) g = 5 ^ g := by rw [GSD]; norm_num

example : GSD (ZMod 3) 2 = 9 := by rw [GSD]; norm_num

-- !-- Boundary: on the sphere (`g = 0`) every abelian theory has a unique ground state. -- !--
/-- **Boundary case.** On the sphere (`g = 0`) the ground state is *unique*
    (`GSD = 1`) for every abelian theory — there is no topological degeneracy. -/
example [Fintype A] : GSD A 0 = 1 := by rw [GSD, pow_zero]

end TopologicalOrderGenus