/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Euler–Poincaré Principle for Decision-Surface Cellular Complexes

This file deepens the Hodge/Betti theory of piecewise-linear decision surfaces
`V(f) = {x : f(x) = 0}` of rectified-linear networks.  Earlier work in this
directory (`DecisionSurface.lean`, `RankFormula.lean`) established:

* the cellular chain complex `C₂ →[d₂] C₁ →[d₁] C₀` of the decision surface,
  with homology the subquotient `ker d₁ ⧸ im d₂`;
* the **cell-count bound** `dim H ≤ #cells ≤ ∏ᵢ 2^{wᵢ}` (width-driven Betti bound);
* the **exact middle identity** `dim H₁ = dim C₁ − rank d₁ − rank d₂`.

Here we go one step further and pin down *all three* homology groups of the
complex simultaneously, and combine them into the **Euler characteristic**, the
strongest numerical invariant of the surface.  The point is the classical
Euler–Poincaré principle: the alternating sum of Betti numbers depends only on
the *sizes of the chain groups*, not on the differentials — the topology is
rigid even though the individual homology groups are not.

## The chain of results

1. **Abstract Euler–Poincaré (`euler_poincare_defect`, `euler_poincare`).**
   For any numerical "homology profile" obeying the two rank–nullity relations
   `h₀ = a₀ − r₀` and `h_{n+1} = a_{n+1} − rₙ − r_{n+1}`, the alternating sums
   satisfy `Σ (−1)ⁿ hₙ = Σ (−1)ⁿ aₙ − (−1)ᴸ rᴸ`; when the top boundary vanishes
   (`rᴸ = 0`, i.e. the complex is bounded) the two alternating sums coincide.
   Proved by induction on `L`.

2. **The three homology dimensions.**  For the concrete three-term complex the
   bottom homology is a cokernel (`finrank_cokernelH`), the middle a subquotient
   (`finrank_middleH`), the top a kernel (`finrank_kernelH`); each dimension is
   read off by rank–nullity.

3. **Euler characteristic of the decision surface (`euler_char_three_term`).**
   Feeding the three homology dimensions into the abstract principle gives
   `dim H₀ − dim H₁ + dim H₂ = dim C₀ − dim C₁ + dim C₂`.

4. **Consequences.**  `euler_char_indep_of_differentials` (the invariant depends
   only on chain sizes), `euler_char_abs_le_total` (a total-dimension bound), and
   `euler_char_le_width` (the width-driven bound on the Euler characteristic of
   `V(f)`, the mission's quantitative "Hodge-number" shadow at the level of the
   Euler characteristic).

-- !-- Lab Notes -- !--
Hypothesis: the cell-count *inequality* and the middle *exact identity* are two
  facets of a single rigidity — the whole alternating sum of homology dimensions
  is a function of the chain-group dimensions alone.
Experiment: isolate the arithmetic in an abstract `euler_poincare_defect`
  (induction on length, telescoping the boundary ranks), then compute the three
  homology dimensions of the concrete complex by rank–nullity and instantiate.
Analysis: the defect identity `Σ(−1)ⁿhₙ = Σ(−1)ⁿaₙ − (−1)ᴸrᴸ` telescopes the
  boundary ranks exactly; the residual `(−1)ᴸrᴸ` is the single top-boundary term,
  which vanishes for a bounded complex, giving genuine Euler invariance.
Critique: nothing is definitional — the induction needs the parity identity
  `(−1)^{L+1} = −(−1)^L`, and the three dimension lemmas each use a distinct
  rank–nullity/comap-equivalence input; the synthesis is a real instantiation of
  the general theorem, not a restatement.
Synthesis: `χ(H) = χ(C)` for the decision-surface complex, hence a width bound
  `|χ| ≤ 3 · ∏ᵢ 2^{wᵢ}`.
-/

import Mathlib

open Module BigOperators

namespace HodgeCycles

/-! ## 1. The abstract Euler–Poincaré principle

A numerical model of a bounded chain complex: `a n` is the dimension of the
`n`-th chain group, `r n` the rank of the `n`-th boundary map `d n : C_{n+1} → C_n`,
and `h n` the dimension of the `n`-th homology.  Rank–nullity at the bottom gives
`h 0 = a 0 − r 0` (a cokernel) and at every interior spot
`h (n+1) = a (n+1) − r n − r (n+1)` (a subquotient). -/

section Abstract

/-- **Euler–Poincaré defect identity.**  The alternating sum of homology
dimensions equals the alternating sum of chain dimensions, up to the single
top-boundary term `(−1)ᴸ · rᴸ`.  Proved by induction on `L`, telescoping the
boundary ranks. -/
theorem euler_poincare_defect (a r h : ℕ → ℤ)
    (h0 : h 0 = a 0 - r 0)
    (hstep : ∀ n, h (n + 1) = a (n + 1) - r n - r (n + 1)) (L : ℕ) :
    ∑ n ∈ Finset.range (L + 1), (-1 : ℤ) ^ n * h n
      = (∑ n ∈ Finset.range (L + 1), (-1 : ℤ) ^ n * a n) - (-1 : ℤ) ^ L * r L := by
  induction L with
  | zero => simp [h0]
  | succ k ih =>
    rw [Finset.sum_range_succ (fun n => (-1 : ℤ) ^ n * h n) (k + 1),
        Finset.sum_range_succ (fun n => (-1 : ℤ) ^ n * a n) (k + 1), ih, hstep k, pow_succ]
    ring

/-- **Euler–Poincaré principle.**  For a *bounded* complex — one whose top
boundary map has rank zero, `r L = 0` — the alternating sum of homology
dimensions equals the alternating sum of chain-group dimensions.  This is the
numerical rigidity: `χ(H) = χ(C)`. -/
theorem euler_poincare (a r h : ℕ → ℤ)
    (h0 : h 0 = a 0 - r 0)
    (hstep : ∀ n, h (n + 1) = a (n + 1) - r n - r (n + 1)) (L : ℕ) (hrL : r L = 0) :
    ∑ n ∈ Finset.range (L + 1), (-1 : ℤ) ^ n * h n
      = ∑ n ∈ Finset.range (L + 1), (-1 : ℤ) ^ n * a n := by
  rw [euler_poincare_defect a r h h0 hstep L, hrL]; ring

end Abstract

/-! ## 2. The three homology groups of the decision-surface complex

We fix a field `F` and three consecutive cellular chain groups
`C₂ →[d₂] C₁ →[d₁] C₀`, all finite-dimensional. -/

section HomologyDims

variable {F : Type*} [Field F]
variable {C₂ C₁ C₀ : Type*}
  [AddCommGroup C₂] [Module F C₂] [AddCommGroup C₁] [Module F C₁]
  [AddCommGroup C₀] [Module F C₀]
  [FiniteDimensional F C₂] [FiniteDimensional F C₁] [FiniteDimensional F C₀]
variable (d₂ : C₂ →ₗ[F] C₁) (d₁ : C₁ →ₗ[F] C₀)

/-- Bottom homology `H₀`: the cokernel `C₀ ⧸ im d₁` (classes not hit by a
boundary). -/
abbrev cokernelH : Type _ := C₀ ⧸ LinearMap.range d₁

/-- Middle homology `H₁`: the subquotient `ker d₁ ⧸ im d₂`. -/
abbrev middleH : Type _ :=
  (LinearMap.ker d₁) ⧸ ((LinearMap.range d₂).comap (LinearMap.ker d₁).subtype)

/-- Top homology `H₂`: the cycles `ker d₂` (nothing maps in). -/
abbrev kernelH : Submodule F C₂ := LinearMap.ker d₂

omit [FiniteDimensional F C₁] in
/-- **Bottom homology dimension.**  `dim H₀ = dim C₀ − rank d₁`. -/
theorem finrank_cokernelH :
    (finrank F (cokernelH d₁) : ℤ) = finrank F C₀ - finrank F (LinearMap.range d₁) := by
  have := Submodule.finrank_quotient_add_finrank (LinearMap.range d₁)
  simp only [cokernelH]
  omega

omit [FiniteDimensional F C₁] in
/-- **Top homology dimension.**  `dim H₂ = dim C₂ − rank d₂`. -/
theorem finrank_kernelH :
    (finrank F (kernelH d₂) : ℤ) = finrank F C₂ - finrank F (LinearMap.range d₂) := by
  have := LinearMap.finrank_range_add_finrank_ker d₂
  simp only [kernelH]
  omega

omit [FiniteDimensional F C₂] [FiniteDimensional F C₀] in
/-- **Middle homology dimension.**  For a chain complex (`d₁ ∘ d₂ = 0`),
`dim H₁ = dim C₁ − rank d₁ − rank d₂`. -/
theorem finrank_middleH (hd : d₁.comp d₂ = 0) :
    (finrank F (middleH d₂ d₁) : ℤ)
      = finrank F C₁ - finrank F (LinearMap.range d₁) - finrank F (LinearMap.range d₂) := by
  have hle : LinearMap.range d₂ ≤ LinearMap.ker d₁ := LinearMap.range_le_ker_iff.mpr hd
  have hb : finrank F ((LinearMap.range d₂).comap (LinearMap.ker d₁).subtype)
      = finrank F (LinearMap.range d₂) :=
    LinearEquiv.finrank_eq (Submodule.comapSubtypeEquivOfLe hle)
  have he := Submodule.finrank_quotient_add_finrank
    ((LinearMap.range d₂).comap (LinearMap.ker d₁).subtype)
  have hk := LinearMap.finrank_range_add_finrank_ker d₁
  rw [hb] at he
  simp only [middleH]
  omega

end HomologyDims

/-! ## 3. The Euler characteristic of the decision surface -/

section Synthesis

variable {F : Type*} [Field F]
variable {C₂ C₁ C₀ : Type*}
  [AddCommGroup C₂] [Module F C₂] [AddCommGroup C₁] [Module F C₁]
  [AddCommGroup C₀] [Module F C₀]
  [FiniteDimensional F C₂] [FiniteDimensional F C₁] [FiniteDimensional F C₀]
variable (d₂ : C₂ →ₗ[F] C₁) (d₁ : C₁ →ₗ[F] C₀)

/-- **Euler characteristic of the decision-surface complex.**  For a chain
complex `C₂ →[d₂] C₁ →[d₁] C₀` the alternating sum of homology dimensions equals
the alternating sum of chain-group dimensions:
`dim H₀ − dim H₁ + dim H₂ = dim C₀ − dim C₁ + dim C₂`.
This is the Euler–Poincaré principle instantiated on the concrete complex, via
the abstract `euler_poincare` fed with the three rank–nullity dimensions. -/
theorem euler_char_three_term (hd : d₁.comp d₂ = 0) :
    (finrank F (cokernelH d₁) : ℤ) - finrank F (middleH d₂ d₁) + finrank F (kernelH d₂)
      = finrank F C₀ - finrank F C₁ + finrank F C₂ := by
  have hcok := finrank_cokernelH d₁
  have hmid := finrank_middleH d₂ d₁ hd
  have hker := finrank_kernelH d₂
  set a : ℕ → ℤ := fun n => match n with
    | 0 => (finrank F C₀ : ℤ) | 1 => (finrank F C₁ : ℤ) | 2 => (finrank F C₂ : ℤ) | _ => 0 with ha
  set r : ℕ → ℤ := fun n => match n with
    | 0 => (finrank F (LinearMap.range d₁) : ℤ)
    | 1 => (finrank F (LinearMap.range d₂) : ℤ) | _ => 0 with hr
  set h : ℕ → ℤ := fun n => match n with
    | 0 => (finrank F (cokernelH d₁) : ℤ) | 1 => (finrank F (middleH d₂ d₁) : ℤ)
    | 2 => (finrank F (kernelH d₂) : ℤ) | _ => 0 with hh
  have key := euler_poincare a r h (by simp [ha, hr, hh, hcok]) ?_ 2 (by simp [hr])
  · simp only [Finset.sum_range_succ, Finset.sum_range_zero, ha, hh] at key
    push_cast at key ⊢
    linarith [key]
  · intro n
    match n with
    | 0 => simp [ha, hr, hh, hmid]
    | 1 => simp [ha, hr, hh, hker]
    | (m + 2) => simp [ha, hr, hh]

/-- **Rigidity of the Euler characteristic.**  The alternating sum of homology
dimensions depends only on the dimensions of the chain groups — not on the
differentials.  Two decision-surface complexes with the same cell counts in each
degree have the same Euler characteristic, however their boundary maps differ. -/
theorem euler_char_indep_of_differentials
    {C₂' C₁' C₀' : Type*}
    [AddCommGroup C₂'] [Module F C₂'] [AddCommGroup C₁'] [Module F C₁']
    [AddCommGroup C₀'] [Module F C₀']
    [FiniteDimensional F C₂'] [FiniteDimensional F C₁'] [FiniteDimensional F C₀']
    (d₂' : C₂' →ₗ[F] C₁') (d₁' : C₁' →ₗ[F] C₀')
    (hd : d₁.comp d₂ = 0) (hd' : d₁'.comp d₂' = 0)
    (e₀ : finrank F C₀ = finrank F C₀') (e₁ : finrank F C₁ = finrank F C₁')
    (e₂ : finrank F C₂ = finrank F C₂') :
    (finrank F (cokernelH d₁) : ℤ) - finrank F (middleH d₂ d₁) + finrank F (kernelH d₂)
      = (finrank F (cokernelH d₁') : ℤ) - finrank F (middleH d₂' d₁') + finrank F (kernelH d₂') := by
  rw [euler_char_three_term d₂ d₁ hd, euler_char_three_term d₂' d₁' hd', e₀, e₁, e₂]

/-- **Total-dimension bound.**  The Euler characteristic of the decision surface
is bounded in absolute value by the total number of cells. -/
theorem euler_char_abs_le_total (hd : d₁.comp d₂ = 0) :
    |(finrank F (cokernelH d₁) : ℤ) - finrank F (middleH d₂ d₁) + finrank F (kernelH d₂)|
      ≤ (finrank F C₀ : ℤ) + finrank F C₁ + finrank F C₂ := by
  rw [euler_char_three_term d₂ d₁ hd, abs_le]
  have h0 : (0 : ℤ) ≤ finrank F C₀ := Int.natCast_nonneg _
  have h1 : (0 : ℤ) ≤ finrank F C₁ := Int.natCast_nonneg _
  have h2 : (0 : ℤ) ≤ finrank F C₂ := Int.natCast_nonneg _
  constructor <;> linarith

end Synthesis

/-! ## 4. Width-driven bound on the Euler characteristic

Tying back to the network's shape: the activation-pattern count
`P(w) = ∏ᵢ 2^{wᵢ}` bounds the number of cells in each degree, hence the Euler
characteristic of the decision surface. -/

section Width

/-- An **activation pattern** of a network with `L` hidden layers of widths
`w : Fin L → ℕ`. -/
abbrev ActivationPattern (L : ℕ) (w : Fin L → ℕ) : Type := (i : Fin L) → (Fin (w i) → Bool)

/-- The number of activation patterns of a network is `∏ᵢ 2^{wᵢ}`. -/
theorem card_activationPattern (L : ℕ) (w : Fin L → ℕ) :
    Fintype.card (ActivationPattern L w) = ∏ i, 2 ^ (w i) := by
  simp [ActivationPattern, Fintype.card_pi]

variable {F : Type*} [Field F]
variable {C₂ C₁ C₀ : Type*}
  [AddCommGroup C₂] [Module F C₂] [AddCommGroup C₁] [Module F C₁]
  [AddCommGroup C₀] [Module F C₀]
  [FiniteDimensional F C₂] [FiniteDimensional F C₁] [FiniteDimensional F C₀]
variable (d₂ : C₂ →ₗ[F] C₁) (d₁ : C₁ →ₗ[F] C₀)

/-- **Width-driven Euler-characteristic bound.**  If each cellular chain group of
the decision surface has at most `P = ∏ᵢ 2^{wᵢ}` cells (one per activation
region), then the Euler characteristic of `V(f)` is bounded in absolute value by
`3 · P`.  This is the mission's quantitative "Hodge-number" shadow at the level
of the Euler characteristic. -/
theorem euler_char_le_width {L : ℕ} {w : Fin L → ℕ} (hd : d₁.comp d₂ = 0)
    (h0 : (finrank F C₀ : ℤ) ≤ ∏ i, 2 ^ (w i))
    (h1 : (finrank F C₁ : ℤ) ≤ ∏ i, 2 ^ (w i))
    (h2 : (finrank F C₂ : ℤ) ≤ ∏ i, 2 ^ (w i)) :
    |(finrank F (cokernelH d₁) : ℤ) - finrank F (middleH d₂ d₁) + finrank F (kernelH d₂)|
      ≤ 3 * ∏ i, 2 ^ (w i) := by
  have hb := euler_char_abs_le_total d₂ d₁ hd
  have : (finrank F C₀ : ℤ) + finrank F C₁ + finrank F C₂ ≤ 3 * ∏ i, 2 ^ (w i) := by linarith
  linarith [hb, this]

end Width

end HodgeCycles