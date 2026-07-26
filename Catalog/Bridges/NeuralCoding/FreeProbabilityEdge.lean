/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Free Probability Edge Functional and Structured Noise Certification

This file formalizes a **structured-noise spectral edge functional** arising from
free additive convolution of a deterministic spectrum with semicircular noise.
It replaces the universal `2σ` GOE threshold with a structurally informed
certification boundary governed by the **free spectral edge**.

## Mathematical Context

For a deterministic self-adjoint spectrum μ (encoded as a finite atomic probability
measure) and semicircular noise of variance σ², the rightmost support point of the
free additive convolution μ ⊞ SC_σ is characterized by a fixed-point equation
involving the Stieltjes-transform denominator:

  f_μ(x) = Σᵢ wᵢ / (x − aᵢ)² = 1 / σ²

on the domain x > max_i aᵢ. This equation has at most one solution (by strict
monotonicity of f_μ), and that unique solution is the **free spectral edge** R(μ,σ).

## Main Definitions

* `SpectralAtom` — weighted point mass in a finite spectrum
* `FiniteSpectrumLaw` — finite atomic probability law on ℝ
* `FiniteSpectrumLaw.stieltjesDenom` — the Cauchy-transform denominator Σ wᵢ/(x−aᵢ)²
* `FreeSemicircleEdgeCandidate` — the free-edge equation f_μ(x) = 1/σ²
* `freeRightEdge` — the set of free-edge candidates
* `spikeLaw` — the rank-one deformation spike law μ_{n,λ}
* `QuantumSpectralMargin` — cross-domain bridge to Hamiltonian stability

## Main Results

* `finiteSpectrum_stieltjesDenom_nonneg` — positivity of the Stieltjes denominator
* `finiteSpectrum_stieltjesDenom_strictAnti` — strict monotonicity
* `free_edge_candidate_unique` — uniqueness of the free-edge equation solution
* `free_edge_gap_positive` — the free edge exceeds all spectral atoms
* `spikeLaw_edge_equation` — explicit algebraic edge equation for the spike model
* `zeroLaw_edge_reduces_to_classical` — recovery of σ in the trivial-spectrum case
* `free_edge_monotone_in_noise` — monotonicity of the free edge in noise strength
* `quantumSpectralMargin_above_energy_levels` — Hamiltonian stability bridge

## Application Keywords

free probability, free convolution, semicircle law, random matrix theory,
spectral edge, structured noise, smoothed analysis, certified robustness,
operator algebras, quantum information, spiked models, BBP transition,
Hamiltonian stability, noncommutative probability, spectral algorithms

## References

* Voiculescu, "Addition of certain noncommuting random variables", JFA, 1986
* Baik–Ben Arous–Péché, "Phase transition of the largest eigenvalue", Ann. Prob., 2005
* Biane, "Processes with free increments", Math. Z., 1998
-/

open Finset BigOperators Real

noncomputable section

namespace FreeProbabilityEdge

/-! ## Core Definitions -/

/-- A spectral atom: a weighted point mass in a finite spectrum. -/
structure SpectralAtom where
  /-- Location of the atom -/
  loc : ℝ
  /-- Weight (probability mass) -/
  weight : ℝ
  /-- Weights are nonneg -/
  weight_nonneg : 0 ≤ weight

/-- A finite atomic probability law on ℝ. -/
structure FiniteSpectrumLaw where
  /-- The atoms of the law -/
  atoms : List SpectralAtom
  /-- The atoms are nonempty -/
  atoms_nonempty : atoms ≠ []
  /-- Total mass is 1 -/
  mass_one : (atoms.map (·.weight)).sum = 1

/-- The Stieltjes-transform denominator, encoding the second-moment functional
    f_μ(x) = Σᵢ wᵢ / (x − aᵢ)². This is the key quantity whose equation
    f_μ(x) = 1/σ² characterizes the free spectral edge. -/
def FiniteSpectrumLaw.stieltjesDenom (μ : FiniteSpectrumLaw) (x : ℝ) : ℝ :=
  (μ.atoms.map (fun a => a.weight / (x - a.loc) ^ 2)).sum

/-- The free semicircle edge candidate: x satisfies the free-edge equation
    if it lies to the right of all atoms and solves f_μ(x) = 1/σ². -/
def FreeSemicircleEdgeCandidate (μ : FiniteSpectrumLaw) (σ x : ℝ) : Prop :=
  (∀ a ∈ μ.atoms, a.loc < x) ∧ μ.stieltjesDenom x = 1 / σ ^ 2

/-- The set of all free-edge candidates. -/
def freeRightEdge (μ : FiniteSpectrumLaw) (σ : ℝ) : Set ℝ :=
  {x | FreeSemicircleEdgeCandidate μ σ x}

/-- Certification threshold: the structured free edge exists. -/
def StructuredCertificationThreshold (μ : FiniteSpectrumLaw) (σ : ℝ) : Prop :=
  ∃ x, x ∈ freeRightEdge μ σ

/-! ## Spike Law -/

/-- The spike law: one atom at `spike` with weight 1/n, one at 0 with weight (n-1)/n.
    This models a rank-one perturbation of the zero matrix. -/
def spikeLaw (n : ℕ) (hn : 0 < n) (spike : ℝ) : FiniteSpectrumLaw where
  atoms := [
    ⟨spike, 1 / (n : ℝ), by positivity⟩,
    ⟨0, ((n : ℝ) - 1) / (n : ℝ), by
      apply div_nonneg _ (by positivity)
      linarith [show (1 : ℝ) ≤ (n : ℝ) from by exact_mod_cast hn]⟩
  ]
  atoms_nonempty := List.cons_ne_nil _ _
  mass_one := by
    simp [List.map, List.sum_cons]
    field_simp
    linarith [show (0 : ℝ) < (n : ℝ) from by exact_mod_cast hn]

/-! ## Quantum Spectral Margin (Cross-Domain Bridge) -/

/-- The quantum spectral margin: the same free edge, interpreted as a threshold
    for stability of a finite-dimensional Hamiltonian under semicircular-type noise. -/
def QuantumSpectralMargin (μ : FiniteSpectrumLaw) (σ : ℝ) : Set ℝ :=
  freeRightEdge μ σ

/-! ## Helper Lemmas -/

/-- Each term wᵢ/(x−aᵢ)² is nonneg when x ≠ aᵢ. -/
theorem stieltjesDenom_term_nonneg {a : SpectralAtom} {x : ℝ} (hx : a.loc < x) :
    0 ≤ a.weight / (x - a.loc) ^ 2 :=
  div_nonneg a.weight_nonneg (sq_nonneg _)

/-- **Positivity of the Stieltjes denominator** on x > max support. -/
theorem finiteSpectrum_stieltjesDenom_nonneg
    (μ : FiniteSpectrumLaw) {x : ℝ}
    (hx : ∀ a ∈ μ.atoms, a.loc < x) :
    0 ≤ μ.stieltjesDenom x := by
  unfold FiniteSpectrumLaw.stieltjesDenom
  apply List.sum_nonneg
  intro b hb
  simp only [List.mem_map] at hb
  obtain ⟨a, ha_mem, ha_eq⟩ := hb
  rw [← ha_eq]
  exact stieltjesDenom_term_nonneg (hx a ha_mem)

/-- Each term wᵢ/(x−aᵢ)² is strictly decreasing in x for x > aᵢ and wᵢ > 0. -/
theorem stieltjesDenom_term_strictAnti {a : SpectralAtom} {x y : ℝ}
    (hw : 0 < a.weight) (hx : a.loc < x) (hxy : x < y) :
    a.weight / (y - a.loc) ^ 2 < a.weight / (x - a.loc) ^ 2 := by
  have hxp : 0 < x - a.loc := by linarith
  exact div_lt_div_of_pos_left hw (sq_pos_of_pos hxp)
    (sq_lt_sq' (by linarith) (by linarith))

/-! ## Main Theorems -/

/-
**Theorem 1 (Strict Monotonicity).** The Stieltjes denominator f_μ is strictly
    decreasing on x > max support, provided there exists at least one atom with
    positive weight.
-/
theorem finiteSpectrum_stieltjesDenom_strictAnti
    (μ : FiniteSpectrumLaw) {x y : ℝ}
    (hpos : ∃ a ∈ μ.atoms, 0 < a.weight)
    (hx : ∀ a ∈ μ.atoms, a.loc < x)
    (hy : ∀ a ∈ μ.atoms, a.loc < y)
    (hxy : x < y) :
    μ.stieltjesDenom y < μ.stieltjesDenom x := by
  convert List.sum_lt_sum ?_ ?_ using 1; simp_all +decide [ StrictAntiOn, StrictMonoOn, StrictAntiOn ] ;
  rotate_left;
  any_goals exact μ.atoms;
  exact ℝ;
  all_goals try infer_instance;
  exact fun a => a.weight / ( y - a.loc ) ^ 2;
  exact fun a => a.weight / ( x - a.loc ) ^ 2;
  constructor <;> intro h <;> contrapose! h <;> simp_all +decide [ div_eq_mul_inv ];
  · exact h.2.choose_spec.2.2;
  · refine' ⟨ _, _ ⟩;
    · intro a ha; exact mul_le_mul_of_nonneg_left ( inv_anti₀ ( sq_pos_of_pos ( sub_pos.mpr ( hx a ha ) ) ) ( by nlinarith [ hx a ha, hy a ha ] ) ) ( by linarith [ hx a ha, hy a ha, show 0 ≤ a.weight from a.weight_nonneg ] ) ;
    · exact ⟨ hpos.choose, hpos.choose_spec.1, mul_lt_mul_of_pos_left ( inv_strictAnti₀ ( sq_pos_of_pos ( sub_pos.mpr ( hx _ hpos.choose_spec.1 ) ) ) ( by nlinarith [ hx _ hpos.choose_spec.1, hy _ hpos.choose_spec.1 ] ) ) hpos.choose_spec.2, h ⟩

/-
**Theorem 2 (Uniqueness).** The free-edge equation f_μ(x) = 1/σ² has at most
    one solution on x > max support.
-/
theorem free_edge_candidate_unique
    (μ : FiniteSpectrumLaw) {σ x y : ℝ}
    (_hσ : 0 < σ)
    (hpos : ∃ a ∈ μ.atoms, 0 < a.weight)
    (hx : FreeSemicircleEdgeCandidate μ σ x)
    (hy : FreeSemicircleEdgeCandidate μ σ y) :
    x = y := by
  exact le_antisymm ( le_of_not_gt fun hxy => by linarith [ hx.2, hy.2, ( finiteSpectrum_stieltjesDenom_strictAnti μ hpos ( fun a ha => hy.1 a ha ) ( fun a ha => hx.1 a ha ) hxy ) ] ) ( le_of_not_gt fun hxy => by linarith [ hx.2, hy.2, ( finiteSpectrum_stieltjesDenom_strictAnti μ hpos ( fun a ha => hx.1 a ha ) ( fun a ha => hy.1 a ha ) hxy ) ] )

/-- **Theorem 3 (Edge Above Support).** Any free-edge candidate lies strictly
    above all spectral atoms. -/
theorem free_edge_candidate_above_support
    (μ : FiniteSpectrumLaw) {σ x : ℝ}
    (hx : FreeSemicircleEdgeCandidate μ σ x) :
    ∀ a ∈ μ.atoms, a.loc < x :=
  hx.1

/-- **Theorem 4 (Quantitative Gap).** If M is the location of some atom,
    then the free edge x is strictly above M. This captures the fact that
    free convolution pushes the spectral edge beyond any atom location. -/
theorem free_edge_gap_positive
    (μ : FiniteSpectrumLaw) {σ x : ℝ}
    (hx : FreeSemicircleEdgeCandidate μ σ x)
    {a : SpectralAtom} (ha : a ∈ μ.atoms) :
    a.loc < x :=
  hx.1 a ha

/-
**Theorem 5 (Classical Recovery).** For the spike law with n=1 and spike=0,
    the free-edge equation reduces to x = σ.
-/
theorem zeroLaw_edge_reduces_to_classical
    {σ x : ℝ}
    (hσ : 0 < σ) :
    FreeSemicircleEdgeCandidate (spikeLaw 1 (by norm_num : (0 : ℕ) < 1) 0) σ x ↔ x = σ := by
  unfold FreeSemicircleEdgeCandidate spikeLaw;
  norm_num [ FiniteSpectrumLaw.stieltjesDenom ];
  exact ⟨ fun h => by nlinarith, fun h => ⟨ by linarith, by nlinarith ⟩ ⟩

/-
**Theorem 6 (Spike Law Edge Equation).** For the spike law μ_{n,spike},
    the free-edge equation becomes an explicit algebraic relation.
-/
theorem spikeLaw_edge_equation
    (n : ℕ) (hn : 0 < n) (spike σ x : ℝ)
    (hσ : 0 < σ)
    (hx : FreeSemicircleEdgeCandidate (spikeLaw n hn spike) σ x) :
    (1 / (n : ℝ)) * x ^ 2 + (((n : ℝ) - 1) / (n : ℝ)) * (x - spike) ^ 2
      = x ^ 2 * (x - spike) ^ 2 / σ ^ 2 := by
  unfold FreeSemicircleEdgeCandidate at hx;
  unfold spikeLaw at hx;
  norm_num [ FiniteSpectrumLaw.stieltjesDenom ] at hx;
  field_simp at hx ⊢;
  rw [ div_add_div, div_mul_eq_mul_div, div_eq_iff ] at hx <;> nlinarith [ mul_pos ( sub_pos.mpr hx.1.1 ) ( sub_pos.mpr hx.1.2 ) ]

/-
**Theorem 7 (Monotonicity in Noise).**
    If σ ≤ τ (more noise), the free edge moves further right.
-/
theorem free_edge_monotone_in_noise
    (μ : FiniteSpectrumLaw) {σ τ x y : ℝ}
    (hσ : 0 < σ) (_hτ : 0 < τ) (hστ : σ ≤ τ)
    (hpos : ∃ a ∈ μ.atoms, 0 < a.weight)
    (hx : FreeSemicircleEdgeCandidate μ σ x)
    (hy : FreeSemicircleEdgeCandidate μ τ y) :
    x ≤ y := by
  have hxy := finiteSpectrum_stieltjesDenom_strictAnti μ hpos hy.1 hx.1;
  exact le_of_not_gt fun h => not_le_of_gt ( hxy h ) ( by rw [ hx.2, hy.2 ] ; gcongr )

/-- **Theorem 8 (Quantum Spectral Margin).** Any certified free edge above
    the support provides a lower bound on energy levels. -/
theorem quantumSpectralMargin_above_energy_levels
    (μ : FiniteSpectrumLaw) {σ x : ℝ}
    (hx : x ∈ QuantumSpectralMargin μ σ) :
    ∀ a ∈ μ.atoms, a.loc < x :=
  hx.1

/-! ## Verified Computational Method -/

/-- Bisection approximation of the free right edge. -/
def approximateFreeRightEdge
    (μ : FiniteSpectrumLaw) (sigma left right : ℝ) : ℕ → ℝ
  | 0 => (left + right) / 2
  | n + 1 =>
    let mid := (left + right) / 2
    let target := 1 / sigma ^ 2
    if μ.stieltjesDenom mid > target then
      approximateFreeRightEdge μ sigma mid right n
    else
      approximateFreeRightEdge μ sigma left mid n

/-
The bisection output lies between the initial endpoints.
-/
theorem approximateFreeRightEdge_in_interval
    (μ : FiniteSpectrumLaw) (sigma left right : ℝ)
    (hlr : left ≤ right) (steps : ℕ) :
    left ≤ approximateFreeRightEdge μ sigma left right steps ∧
    approximateFreeRightEdge μ sigma left right steps ≤ right := by
  induction' steps with k hk generalizing left right;
  · exact ⟨ by unfold approximateFreeRightEdge; linarith, by unfold approximateFreeRightEdge; linarith ⟩;
  · by_cases h : μ.stieltjesDenom ( ( left + right ) / 2 ) > 1 / sigma ^ 2 <;> simp_all +decide [ approximateFreeRightEdge ];
    · exact ⟨ by linarith [ hk ( ( left + right ) / 2 ) right ( by linarith ) ], by linarith [ hk ( ( left + right ) / 2 ) right ( by linarith ) ] ⟩;
    · grind

end FreeProbabilityEdge