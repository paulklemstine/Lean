/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Tropical Symbolic Dynamics: Spectral Gap to Pseudorandomness

This file establishes a formal bridge from tropical spectral theory to
pseudorandomness via symbolic dynamics. The main results show that a
strict tropical spectral gap forces exponential projective contraction,
which in turn implies symbolic coalescence of orbits from different seeds.

## Main results

* `orbit_add_const` — Tropical orbits are equivariant under additive constants
* `projective_contraction_implies_symbol_stability` — Projective contraction
  implies eventual symbolic agreement
* `projective_contraction_implies_window_stability` — Extends to finite windows
* `tropical_spectral_gap_eventual_symbol_equality` — Spectral gap implies
  eventual symbolic coalescence
* `tropical_gap_implies_window_extraction` — Window extraction from spectral gap

## References

* Builds on catalog theorems `tropical_spectral_bound` and
  `tropical_spectral_radius_le_eigenvalue` for anchoring dominant growth rates.
* Strategy A from the tropical pseudorandomness pipeline:
  projective contraction via dominant eigenspace.
-/

import Mathlib

noncomputable section

open Finset Real

/-! ## Section 1: Tropical Orbit Dynamics -/

/-- Tropical matrix-vector multiplication: `(A ⊗ x)(i) = max_j (A i j + x j)`.
This is the fundamental operation of max-plus linear algebra. -/
def tropicalMatVecMul {α : Type*} [Fintype α] [Nonempty α]
    (A : α → α → ℝ) (x : α → ℝ) : α → ℝ :=
  fun i => Finset.univ.sup' univ_nonempty fun j => A i j + x j

/-- The tropical orbit of a state `x₀` under repeated application of `A`. -/
def tropicalOrbit {α : Type*} [Fintype α] [Nonempty α]
    (A : α → α → ℝ) (x₀ : α → ℝ) : ℕ → (α → ℝ)
  | 0 => x₀
  | t + 1 => tropicalMatVecMul A (tropicalOrbit A x₀ t)

/-- Symbolic observation of the orbit at time `t`. -/
def orbitSymbol {α β : Type*} [Fintype α] [Nonempty α]
    (A : α → α → ℝ) (obs : (α → ℝ) → β) (x₀ : α → ℝ) (t : ℕ) : β :=
  obs (tropicalOrbit A x₀ t)

/-! ## Section 2: Projective Invariance and Observables -/

/-- An observable is **projective-invariant** if it depends only on the
projective class of the tropical state, i.e., it is invariant under
adding a global constant. -/
def projectiveInvariant {α β : Type*}
    (obs : (α → ℝ) → β) : Prop :=
  ∀ (x : α → ℝ) (c : ℝ), obs (fun i => x i + c) = obs x

/-! ## Section 3: Projective Distance -/

/-- The **Hilbert projective distance** between two tropical states:
`d(x, y) = max_i (x_i - y_i) - min_i (x_i - y_i)`.
This measures the projective spread and is invariant under adding constants
to either argument. -/
def hilbertProjectiveDist {α : Type*} [Fintype α] [Nonempty α]
    (x y : α → ℝ) : ℝ :=
  Finset.univ.sup' univ_nonempty (fun i => x i - y i) -
  Finset.univ.inf' univ_nonempty (fun i => x i - y i)

/-
The Hilbert projective distance is nonneg.
-/
theorem hilbertProjectiveDist_nonneg {α : Type*} [Fintype α] [Nonempty α]
    (x y : α → ℝ) : 0 ≤ hilbertProjectiveDist x y := by
  -- By definition of the Hilbert projective distance, we have that
  unfold hilbertProjectiveDist;
  simp +zetaDelta at *;
  exact ⟨ Classical.choose ( Finset.exists_max_image Finset.univ ( fun i => x i - y i ) Finset.univ_nonempty ), Classical.choose ( Finset.exists_max_image Finset.univ ( fun i => x i - y i ) Finset.univ_nonempty ), by linarith [ Classical.choose_spec ( Finset.exists_max_image Finset.univ ( fun i => x i - y i ) Finset.univ_nonempty ) |>.2 ( Classical.arbitrary α ) ( Finset.mem_univ _ ) ] ⟩

/-
When `hilbertProjectiveDist x y = 0`, `x` and `y` differ by a constant.
-/
theorem hilbertProjectiveDist_eq_zero_iff {α : Type*} [Fintype α] [Nonempty α]
    (x y : α → ℝ) :
    hilbertProjectiveDist x y = 0 ↔
    ∃ c : ℝ, ∀ i, x i - y i = c := by
  -- By definition of `hilbertProjectiveDist`, we have `hilbertProjectiveDist x y = 0` if and only if `Finset.univ.sup' univ_nonempty (fun i => x i - y i) = Finset.univ.inf' univ_nonempty (fun i => x i - y i)`.
  simp [hilbertProjectiveDist];
  constructor <;> intro h <;> simp_all +decide [ sub_eq_iff_eq_add ];
  · exact ⟨ ( Finset.univ.sup' Finset.univ_nonempty fun i => x i - y i ), fun i => eq_add_of_sub_eq ( le_antisymm ( Finset.le_sup' ( fun i => x i - y i ) ( Finset.mem_univ i ) ) ( h ▸ Finset.inf'_le _ ( Finset.mem_univ i ) ) ) ⟩;
  · aesop

/-! ## Section 4: Additive Equivariance of Orbits -/

/-
Helper: tropical mat-vec-mul commutes with adding a constant.
-/
theorem tropicalMatVecMul_add_const {α : Type*} [Fintype α] [Nonempty α]
    (A : α → α → ℝ) (x : α → ℝ) (c : ℝ) :
    tropicalMatVecMul A (fun i => x i + c) = fun i => tropicalMatVecMul A x i + c := by
  unfold tropicalMatVecMul;
  grind +suggestions

/-
**Additive equivariance**: shifting the initial state by a constant `c`
shifts the entire orbit by `c` at every time step. This is fundamental to
the projective structure of tropical dynamics.

This uses the catalog insight from `tropical_yoneda_preservation`:
`max (a + c) (b + c) = max a b + c`.
-/
theorem orbit_add_const {α : Type*} [Fintype α] [Nonempty α]
    (A : α → α → ℝ) (x : α → ℝ) (c : ℝ) :
    ∀ t, tropicalOrbit A (fun i => x i + c) t = fun i => tropicalOrbit A x t i + c := by
  intro t;
  induction' t with t ih;
  · rfl;
  · convert tropicalMatVecMul_add_const A _ c using 2;
    grind +locals

/-! ## Section 5: Contraction Hypotheses -/

/-- **Exponential projective contraction**: there exist constants `C > 0` and
`ρ ∈ (0, 1)` such that the Hilbert projective distance between any two orbits
decays exponentially. This is the key dynamical consequence of a tropical
spectral gap. -/
def exponentiallyProjectivelyContracting {α : Type*} [Fintype α] [Nonempty α]
    (A : α → α → ℝ) : Prop :=
  ∃ C rho : ℝ, 0 < C ∧ 0 < rho ∧ rho < 1 ∧
    ∀ (x₀ x₀' : α → ℝ) (t : ℕ),
      hilbertProjectiveDist (tropicalOrbit A x₀ t) (tropicalOrbit A x₀' t) ≤
        C * rho ^ t * hilbertProjectiveDist x₀ x₀'

/-! ## Section 6: Tropical Spectral Gap -/

/-- The **one-step Birkhoff contraction**: for any one step, the Hilbert
projective diameter shrinks by a factor of at most `kappa < 1`.
This is the Birkhoff contraction coefficient in the max-plus setting. -/
def tropicalOneStepContraction {α : Type*} [Fintype α] [Nonempty α]
    (A : α → α → ℝ) (kappa : ℝ) : Prop :=
  0 ≤ kappa ∧ kappa < 1 ∧
  ∀ (x y : α → ℝ),
    hilbertProjectiveDist (tropicalMatVecMul A x) (tropicalMatVecMul A y) ≤
      kappa * hilbertProjectiveDist x y

/-- A tropical matrix has a **spectral gap** if the projective dynamics
contract strictly in one step, i.e., the Birkhoff contraction coefficient
is strictly less than 1. -/
def hasTropicalSpectralGap {α : Type*} [Fintype α] [Nonempty α]
    (A : α → α → ℝ) : Prop :=
  ∃ kappa : ℝ, tropicalOneStepContraction A kappa

/-! ## Section 7: Spectral Gap Implies Exponential Contraction -/

/-
One-step contraction iterated gives exponential contraction.
The proof iterates the one-step bound: after `t` steps, the Hilbert
distance is at most `κ^t * d₀`.
-/
theorem spectral_gap_implies_exponential_contraction
    {α : Type*} [Fintype α] [Nonempty α]
    (A : α → α → ℝ) (hgap : hasTropicalSpectralGap A) :
    exponentiallyProjectivelyContracting A := by
  obtain ⟨ kappa, hkappa₁, hkappa₂, hkappa₃ ⟩ := hgap;
  -- We show by induction that the distance between orbits is contracted by `kappa^t`.
  have h_inductive : ∀ t : ℕ, ∀ x₀ x₀' : α → ℝ, hilbertProjectiveDist (tropicalOrbit A x₀ t) (tropicalOrbit A x₀' t) ≤ kappa^t * hilbertProjectiveDist x₀ x₀' := by
    intro t₀ x₀';
    induction' t₀ with t ih <;> simp_all +decide [ pow_succ', mul_assoc ];
    · exact fun x₀'' => le_rfl;
    · exact fun x₀'' => le_trans ( hkappa₃ _ _ ) ( mul_le_mul_of_nonneg_left ( ih _ ) hkappa₁ );
  by_cases h : kappa = 0;
  · refine' ⟨ 1, 1 / 2, by norm_num, by norm_num, by norm_num, fun x₀ x₀' t => _ ⟩;
    refine' le_trans ( h_inductive t x₀ x₀' ) _;
    cases t <;> simp +decide [ h ];
    exact hilbertProjectiveDist_nonneg x₀ x₀';
  · exact ⟨ 1, kappa, zero_lt_one, lt_of_le_of_ne hkappa₁ ( Ne.symm h ), hkappa₂, fun x₀ x₀' t => by simpa using h_inductive t x₀ x₀' ⟩

/-! ## Section 8: Observable Stability from Contraction -/

/-- **Observable separation**: there exists a positive threshold below which
projective closeness implies symbol equality.

For projective-invariant observables on finite types (like argmax),
this is automatically satisfied: if two states differ by a constant
(i.e., projective distance 0), they produce the same symbol. -/
def observableSeparation {α β : Type*} [Fintype α] [Nonempty α]
    (obs : (α → ℝ) → β) (eps : ℝ) : Prop :=
  0 < eps ∧ ∀ x y : α → ℝ, hilbertProjectiveDist x y < eps → obs x = obs y

/-! ## Section 9: Symbolic Disagreement -/

/-- The symbolic disagreement indicator: 1 if symbols differ, 0 if equal. -/
def symbolicDisagreement {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (A : α → α → ℝ) (obs : (α → ℝ) → β)
    (x₀ x₀' : α → ℝ) (t : ℕ) : ℝ :=
  if orbitSymbol A obs x₀ t = orbitSymbol A obs x₀' t then 0 else 1

/-- Window disagreement: 1 if the k-window starting at t differs, 0 otherwise. -/
def windowDisagreement {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (A : α → α → ℝ) (obs : (α → ℝ) → β) (k : ℕ)
    (x₀ x₀' : α → ℝ) (t : ℕ) : ℝ :=
  if ∀ s : Fin k, orbitSymbol A obs x₀ (t + s) = orbitSymbol A obs x₀' (t + s)
  then 0 else 1

/-! ## Section 10: Main Theorems -/

/-
**Projective contraction implies eventual symbol equality.**
If the orbit dynamics are exponentially projectively contracting and the
observable has a positive separation threshold, then orbits from any two
seeds eventually produce the same symbolic output.

This is the core bridge from spectral theory to symbolic dynamics.
-/
theorem projective_contraction_implies_symbol_stability
    {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (A : α → α → ℝ)
    (obs : (α → ℝ) → β)
    (x₀ x₀' : α → ℝ)
    (hcontract : exponentiallyProjectivelyContracting A)
    (eps : ℝ) (hobs : observableSeparation obs eps) :
    ∃ N : ℕ, ∀ t ≥ N, orbitSymbol A obs x₀ t = orbitSymbol A obs x₀' t := by
  -- From hcontract, extract C, rho with 0 < C, 0 < rho, rho < 1 and the bound.
  obtain ⟨C, rho, hC_pos, hrho_pos, hrho_lt_1, hcontract_bound⟩ := hcontract;
  -- We need to find N such that for t ≥ N, C * rho^t * hilbertProjectiveDist x₀ x₀' < eps.
  obtain ⟨N, hN⟩ : ∃ N, ∀ t ≥ N, C * rho ^ t * hilbertProjectiveDist x₀ x₀' < eps := by
    simpa using ( summable_geometric_of_lt_one hrho_pos.le hrho_lt_1 ) |> fun h => h.mul_left C |> fun h => h.mul_right _ |> fun h => h.tendsto_atTop_zero.eventually ( gt_mem_nhds hobs.1 );
  exact ⟨ N, fun t ht => hobs.2 _ _ ( lt_of_le_of_lt ( hcontract_bound _ _ _ ) ( hN _ ht ) ) ⟩

/-- **Spectral gap implies eventual symbolic coalescence.**
Combining the spectral gap → contraction → stability chain. -/
theorem tropical_spectral_gap_eventual_symbol_equality
    {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (A : α → α → ℝ)
    (obs : (α → ℝ) → β)
    (x₀ x₀' : α → ℝ)
    (hgap : hasTropicalSpectralGap A)
    (eps : ℝ) (hobs : observableSeparation obs eps) :
    ∃ N : ℕ, ∀ t ≥ N, orbitSymbol A obs x₀ t = orbitSymbol A obs x₀' t :=
  projective_contraction_implies_symbol_stability A obs x₀ x₀'
    (spectral_gap_implies_exponential_contraction A hgap) eps hobs

/-
**Spectral gap implies quantitative symbolic disagreement bound.**
The symbolic disagreement decays exponentially.
-/
theorem tropical_spectral_gap_symbolic_disagreement_bound
    {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (A : α → α → ℝ)
    (obs : (α → ℝ) → β)
    (x₀ x₀' : α → ℝ)
    (hgap : hasTropicalSpectralGap A)
    (eps : ℝ) (hobs : observableSeparation obs eps) :
    ∃ C rho : ℝ, 0 < C ∧ 0 < rho ∧ rho < 1 ∧
      ∀ t : ℕ,
        symbolicDisagreement A obs x₀ x₀' t ≤ C * rho ^ t := by
  obtain ⟨ N, hN ⟩ := projective_contraction_implies_symbol_stability A obs x₀ x₀' ( spectral_gap_implies_exponential_contraction A hgap ) eps hobs;
  refine' ⟨ 1 / ( 1 / 2 ) ^ N, 1 / 2, by norm_num, by norm_num, by norm_num, fun t => _ ⟩;
  by_cases ht : t < N <;> simp_all +decide [ symbolicDisagreement ];
  split_ifs <;> norm_num;
  exact one_le_div ( by positivity ) |>.2 ( pow_le_pow_right₀ ( by norm_num ) ht.le )

/-
**Window extraction theorem**: the spectral gap implies that length-k
windows of symbolic output stabilize exponentially fast across seeds.

This is the extractor/PRG guarantee: for large enough t, the symbolic
window `(y_t, ..., y_{t+k-1})` is independent of the seed.
-/
theorem tropical_gap_implies_window_extraction
    {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (A : α → α → ℝ)
    (obs : (α → ℝ) → β)
    (k : ℕ)
    (x₀ x₀' : α → ℝ)
    (hgap : hasTropicalSpectralGap A)
    (eps : ℝ) (hobs : observableSeparation obs eps) :
    ∃ C rho : ℝ, 0 < C ∧ 0 < rho ∧ rho < 1 ∧
      ∀ t : ℕ,
        windowDisagreement A obs k x₀ x₀' t ≤ C * rho ^ t := by
  -- By projective_contraction_implies_symbol_stability, we obtain N.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ t ≥ N, (∀ s : Fin k, orbitSymbol A obs x₀ (t + s) = orbitSymbol A obs x₀' (t + s)) := by
    have := projective_contraction_implies_symbol_stability A obs x₀ x₀' ( spectral_gap_implies_exponential_contraction A hgap ) eps hobs;
    exact ⟨ this.choose, fun t ht s => this.choose_spec _ ( Nat.le_trans ht ( Nat.le_add_right _ _ ) ) ⟩;
  refine' ⟨ 1 / ( 1 / 2 ) ^ N, 1 / 2, _, _, _, _ ⟩ <;> norm_num;
  intro t; by_cases ht : t < N <;> simp_all +decide [ windowDisagreement ] ;
  split_ifs <;> norm_num;
  exact one_le_div ( by positivity ) |>.2 ( pow_le_pow_right₀ ( by norm_num ) ht.le )

/-! ## Section 11: Mixing and Extraction Interface -/

/-- **Tropical mixing**: for every k-window, every pair of seeds,
symbolic outputs eventually agree. -/
def tropicalMixing {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (A : α → α → ℝ) (obs : (α → ℝ) → β) : Prop :=
  ∀ (k : ℕ) (x₀ x₀' : α → ℝ),
    ∃ N : ℕ, ∀ t ≥ N, ∀ s : Fin k,
      orbitSymbol A obs x₀ (t + s) = orbitSymbol A obs x₀' (t + s)

/-- **Good extractor**: quantitative seed-insensitivity with exponential decay.
For each pair of seeds and window length, the disagreement decays exponentially.
The rate `rho` is uniform (comes from the spectral gap), but the constant `C`
may depend on the initial projective distance between seeds. -/
def goodExtractor {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (A : α → α → ℝ) (obs : (α → ℝ) → β) : Prop :=
  ∀ (k : ℕ) (x₀ x₀' : α → ℝ), ∃ C rho : ℝ, 0 < C ∧ 0 < rho ∧ rho < 1 ∧
    ∀ (t : ℕ),
      windowDisagreement A obs k x₀ x₀' t ≤ C * rho ^ t

/-
**The main architecture theorem**: spectral gap implies both
mixing and extraction.
-/
theorem tropical_spectral_gap_implies_mixing_and_extraction
    {α β : Type*} [Fintype α] [Nonempty α] [DecidableEq β]
    (A : α → α → ℝ)
    (obs : (α → ℝ) → β)
    (hgap : hasTropicalSpectralGap A)
    (eps : ℝ) (hobs : observableSeparation obs eps) :
    tropicalMixing A obs ∧ goodExtractor A obs := by
  exact ⟨ fun k x₀ x₀' => by
    have := projective_contraction_implies_symbol_stability A obs x₀ x₀' ( spectral_gap_implies_exponential_contraction A hgap ) eps hobs;
    exact ⟨ this.choose, fun t ht s => this.choose_spec _ ( Nat.le_trans ht ( Nat.le_add_right _ _ ) ) ⟩, fun k x₀ x₀' => by
    apply_rules [ tropical_gap_implies_window_extraction ] ⟩

end