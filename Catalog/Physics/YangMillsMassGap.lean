/-
Copyright (c) 2025. All rights reserved.

# Yang-Mills Mass Gap: Lattice-to-Continuum Spectral Architecture

This module establishes mathematical foundations for lattice Yang-Mills theory
and proves structural theorems about spectral gaps of transfer matrices,
connecting gauge theory, representation theory, and statistical mechanics.

## Main definitions

* `LatticeGaugeField` — A gauge field on a lattice: group elements on oriented edges
* `HasSpectralGap` — Spectral gap property for a family of eigenvalues
* `ExponentialCorrelationDecay` — Exponential decay of correlation functions

## Main results

* `plaquette_gauge_covariance` — Wilson plaquettes transform covariantly
* `class_fn_gauge_invariant` — Class functions of plaquettes are gauge-invariant
* `spectral_gap_of_positive_excitations` — Positive excitations yield a mass gap
* `spectral_gap_perturbation_stability` — Mass gap survives small perturbations
* `spectral_gap_implies_correlation_decay` — Cross-domain: gap → exponential decay
* `plaquette_transport` — Plaquette values transport under group isomorphisms
-/

import Mathlib

open Finset BigOperators

/-! ## Part I: Lattice Gauge Field Infrastructure -/

/-- A lattice gauge field on a graph with vertex set `V` and gauge group `G`
    assigns a group element to each oriented edge, satisfying the orientation
    reversal axiom: reversing an edge inverts the group element.

    This is the fundamental discretization of a connection on a principal
    G-bundle. -/
@[ext]
structure LatticeGaugeField (G : Type*) [Group G] (V : Type*) where
  edge : V → V → G
  edge_orient : ∀ x y, edge x y = (edge y x)⁻¹

namespace LatticeGaugeField

variable {V : Type*} {G : Type*} [Group G]

/-- Self-loops are involutions: `A(x,x)² = 1`. -/
theorem self_loop_sq_one (A : LatticeGaugeField G V) (x : V) :
    A.edge x x * A.edge x x = 1 := by
  have h := mul_inv_cancel (A.edge x x)
  rwa [← A.edge_orient x x] at h

/-- The trivial (flat) gauge field assigns `1` to every edge. -/
def flat : LatticeGaugeField G V where
  edge _ _ := 1
  edge_orient _ _ := by simp

/-- Apply a gauge transformation `g : V → G` to a gauge field. -/
def applyGauge (g : V → G) (A : LatticeGaugeField G V) :
    LatticeGaugeField G V where
  edge x y := g x * A.edge x y * (g y)⁻¹
  edge_orient x y := by simp [A.edge_orient x y]; group

/-- The Wilson plaquette: ordered product around four vertices. -/
def plaquette (A : LatticeGaugeField G V) (a b c d : V) : G :=
  A.edge a b * A.edge b c * A.edge c d * A.edge d a

@[simp]
theorem flat_plaquette (a b c d : V) :
    (flat : LatticeGaugeField G V).plaquette a b c d = 1 := by
  simp [plaquette, flat]

/-- **Gauge Covariance**: Plaquettes transform by conjugation. -/
theorem plaquette_gauge_covariance (g : V → G)
    (A : LatticeGaugeField G V) (a b c d : V) :
    (A.applyGauge g).plaquette a b c d =
    g a * A.plaquette a b c d * (g a)⁻¹ := by
  simp only [plaquette, applyGauge]; group

/-- **Gauge Invariance of Class Functions**: Conjugation-invariant functions
    of plaquettes are gauge-invariant observables. -/
theorem class_fn_gauge_invariant {R : Type*} (f : G → R)
    (hf : ∀ g h : G, f (g * h * g⁻¹) = f h)
    (g : V → G) (A : LatticeGaugeField G V) (a b c d : V) :
    f ((A.applyGauge g).plaquette a b c d) =
    f (A.plaquette a b c d) := by
  rw [plaquette_gauge_covariance]; exact hf _ _

/-- Gauge transforms compose as a group action. -/
theorem applyGauge_comp (g₁ g₂ : V → G) (A : LatticeGaugeField G V) :
    (A.applyGauge g₁).applyGauge g₂ =
    A.applyGauge (fun v => g₂ v * g₁ v) := by
  ext x y; simp only [applyGauge]; group

/-- The identity gauge transform is the identity. -/
theorem applyGauge_id (A : LatticeGaugeField G V) :
    A.applyGauge (fun _ => (1 : G)) = A := by
  ext x y; simp [applyGauge]

/-- **Plaquette Transport**: Isomorphic groups give equal plaquette values. -/
theorem plaquette_transport {G₁ G₂ : Type*} [Group G₁] [Group G₂]
    (φ : G₁ ≃* G₂) (A : LatticeGaugeField G₁ V) (a b c d : V) :
    let A₂ : LatticeGaugeField G₂ V := {
      edge := fun x y => φ (A.edge x y)
      edge_orient := fun x y => by simp [A.edge_orient x y, map_inv] }
    A₂.plaquette a b c d = φ (A.plaquette a b c d) := by
  simp [plaquette, map_mul]

end LatticeGaugeField

/-! ## Part II: Spectral Gap Theory -/

/-- A spectrum `E : ι → ℝ` has a **spectral gap** of size `gap` if `gap > 0`
    and there exists a ground state separated from all excited states by at
    least `gap`. -/
def HasSpectralGap {ι : Type*} (E : ι → ℝ) (gap : ℝ) : Prop :=
  0 < gap ∧ ∃ i₀ : ι, ∀ i : ι, i ≠ i₀ → gap ≤ E i - E i₀

/-
**Spectral Gap from Positive Excitations**: A finite spectrum with a
    zero ground state and strictly positive excited energies has a mass gap.

    Uses the finite minimum principle: a positive function on a nonempty
    finite set achieves a positive minimum.
-/
theorem spectral_gap_of_positive_excitations {n : ℕ} (hn : 2 ≤ n)
    (E : Fin n → ℝ) (hE0 : E ⟨0, by omega⟩ = 0)
    (hpos : ∀ i : Fin n, i ≠ ⟨0, by omega⟩ → 0 < E i) :
    ∃ gap : ℝ, HasSpectralGap E gap := by
  -- By the finite minimum principle, there exists a minimum value $m$ among the excited states $E i$ for $i \neq 0$.
  obtain ⟨i₀, hi₀⟩ : ∃ i₀ : Fin n, i₀ ≠ ⟨0, by linarith⟩ ∧ ∀ i : Fin n, i ≠ ⟨0, by linarith⟩ → E i₀ ≤ E i := by
    have h_min : ∃ i₀ ∈ Finset.univ.erase ⟨0, by linarith⟩, ∀ i ∈ Finset.univ.erase ⟨0, by linarith⟩, E i₀ ≤ E i := by
      exact Finset.exists_min_image _ _ ⟨ ⟨ 1, by linarith ⟩, Finset.mem_erase_of_ne_of_mem ( by norm_num ) ( Finset.mem_univ _ ) ⟩;
    aesop;
  exact ⟨ E i₀, ⟨ hpos i₀ hi₀.1, ⟨ ⟨ 0, by linarith ⟩, fun i hi => by linarith [ hi₀.2 i hi ] ⟩ ⟩ ⟩

/-
**Spectral Gap = First Excitation**: For a monotone spectrum with zero
    ground state, the gap equals the first excited eigenvalue.
-/
theorem spectral_gap_eq_first_excitation {n : ℕ} (hn : 2 ≤ n)
    (E : Fin n → ℝ) (hE0 : E ⟨0, by omega⟩ = 0)
    (hmono : Monotone E) (hpos : 0 < E ⟨1, by omega⟩) :
    HasSpectralGap E (E ⟨1, by omega⟩) := by
  refine' ⟨ hpos, _, _ ⟩;
  exact ⟨ 0, by linarith ⟩;
  intro i hi; have := hmono ( show ⟨ 1, by linarith ⟩ ≤ i from Nat.succ_le_of_lt ( lt_of_le_of_ne ( Nat.zero_le _ ) ( Ne.symm ( by contrapose! hi; aesop ) ) ) ) ; aesop;

/-
**Perturbation Stability**: A spectral gap survives ε-perturbations.
-/
theorem spectral_gap_perturbation_stability {n : ℕ}
    (E₁ E₂ : Fin n → ℝ) (gap ε : ℝ)
    (hgap : HasSpectralGap E₁ gap)
    (_hε : 0 ≤ ε) (hε_small : 2 * ε < gap)
    (hclose : ∀ i : Fin n, |E₁ i - E₂ i| ≤ ε) :
    HasSpectralGap E₂ (gap - 2 * ε) := by
  rcases hgap with ⟨ hg₁, i₀, hi₀ ⟩;
  exact ⟨ by linarith, i₀, fun i hi => by linarith [ abs_le.mp ( hclose i ), abs_le.mp ( hclose i₀ ), hi₀ i hi ] ⟩

/-
**Monotone Coupling**: If the gap increases with coupling and is positive
    at the critical coupling, it stays positive.
-/
theorem gap_monotone_coupling (gap : ℝ → ℝ) (β_c : ℝ)
    (hmono : ∀ β₁ β₂, β_c ≤ β₁ → β₁ ≤ β₂ → gap β₁ ≤ gap β₂)
    (hgap_c : 0 < gap β_c) :
    ∀ β, β_c ≤ β → 0 < gap β := by
  exact fun β hβ => lt_of_lt_of_le hgap_c ( hmono _ _ le_rfl hβ )

/-! ## Part III: Cross-Domain — Spectral Gap ⇒ Correlation Decay -/

/-- Exponential correlation decay with rate `κ > 0`. -/
def ExponentialCorrelationDecay (corr : ℕ → ℝ) (κ : ℝ) : Prop :=
  0 < κ ∧ ∀ t : ℕ, |corr t| ≤ Real.exp (-κ * ↑t)

/-
**Spectral Gap ⇒ Correlation Decay** (Spectral Theory → Statistical
    Mechanics): A positive spectral gap implies exponential decay of
    connected correlation functions.

    In Yang-Mills theory, this means a mass gap implies confinement:
    Wilson loop correlators decay exponentially with Euclidean time.
-/
theorem spectral_gap_implies_correlation_decay {n : ℕ} (hn : 2 ≤ n)
    (E : Fin n → ℝ) (gap : ℝ) (hgap : HasSpectralGap E gap)
    (hE0 : E ⟨0, by omega⟩ = 0)
    (hground : ∀ i : Fin n, E ⟨0, by omega⟩ ≤ E i)
    (c : Fin n → ℝ) (hc : ∀ i, |c i| ≤ 1)
    (hc0 : c ⟨0, by omega⟩ = 0)
    (corr : ℕ → ℝ)
    (hcorr : ∀ t : ℕ, corr t = ∑ i : Fin n,
      c i * Real.exp (-(E i) * ↑t)) :
    ∀ t : ℕ, |corr t| ≤ ↑(n - 1) * Real.exp (-gap * ↑t) := by
  -- By the definition of HasSpectralGap, let's obtain the index i₀ and the corresponding properties.
  obtain ⟨i₀, h_i₀⟩ := hgap
  generalize_proofs at *; (
  -- By the properties of the spectrum and the definition of the gap, we can show that for any $t$, $|corr(t)| \leq (n-1) \exp(-gap \cdot t)$.
  intros t
  have h_abs_sum : |corr t| ≤ ∑ i ∈ Finset.univ.erase ⟨0, by linarith⟩, |c i| * Real.exp (-gap * t) := by
    have h_abs_sum : ∀ i ∈ Finset.univ.erase ⟨0, by linarith⟩, |c i * Real.exp (-E i * t)| ≤ |c i| * Real.exp (-gap * t) := by
      intros i hi
      have h_exp : Real.exp (-E i * t) ≤ Real.exp (-gap * t) := by
        obtain ⟨ i₀, hi₀ ⟩ := h_i₀; have := hi₀ i; by_cases hi' : i = i₀ <;> simp_all +decide ;
        · grind +qlia;
        · exact mul_le_mul_of_nonneg_right ( by linarith [ hi₀ i hi', hground ‹_› ] ) ( Nat.cast_nonneg _ )
      generalize_proofs at *; (
      simpa only [ abs_mul, abs_of_nonneg ( Real.exp_pos _ |> LT.lt.le ) ] using mul_le_mul_of_nonneg_left h_exp ( abs_nonneg _ ))
    generalize_proofs at *; (
    rw [ hcorr, ← Finset.sum_erase_add _ _ ( Finset.mem_univ ⟨ 0, by linarith ⟩ ), hc0, MulZeroClass.zero_mul, add_zero ] ; exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum h_abs_sum ) ;)
  generalize_proofs at *; (
  exact h_abs_sum.trans ( le_trans ( Finset.sum_le_sum fun _ _ => mul_le_of_le_one_left ( Real.exp_nonneg _ ) ( hc _ ) ) ( by simp +decide [ Nat.cast_sub ( show 1 ≤ n by linarith ) ] ) ) ;))

/-! ## Part IV: Uniform Bounds and Continuum Limit -/

/-- Uniform lower bound on gaps implies positive infimum. -/
theorem uniform_gap_infimum_positive (gaps : ℕ → ℝ) (c : ℝ) (hc : 0 < c)
    (hgaps : ∀ n, c ≤ gaps n) : 0 < ⨅ n, gaps n :=
  lt_of_lt_of_le hc (le_ciInf hgaps)

/-- Uniform lower bound implies every gap is positive. -/
theorem gap_persistence_under_refinement (gaps : ℕ → ℝ) (c : ℝ)
    (hc : 0 < c) (hgaps : ∀ n, c ≤ gaps n) : ∀ n, 0 < gaps n :=
  fun n => lt_of_lt_of_le hc (hgaps n)

/-
Convergent sequence bounded below has positive limit.
-/
theorem gap_cauchy_limit_positive (gaps : ℕ → ℝ) (L : ℝ) (c : ℝ)
    (hc : 0 < c) (hgaps : ∀ n, c ≤ gaps n)
    (hlim : Filter.Tendsto gaps Filter.atTop (nhds L)) :
    0 < L := by
  exact lt_of_lt_of_le hc ( le_of_tendsto_of_tendsto' tendsto_const_nhds hlim hgaps )

/-! ## Part V: Representation Theory Connection -/

/-
**Casimir Spectral Gap**: A monotone Casimir spectrum with zero trivial
    eigenvalue and positive first excitation has a spectral gap.
-/
theorem casimir_spectral_gap {n : ℕ} (hn : 2 ≤ n)
    (casimir : Fin n → ℝ)
    (h_trivial : casimir ⟨0, by omega⟩ = 0)
    (h_ordered : Monotone casimir)
    (h_pos : 0 < casimir ⟨1, by omega⟩) :
    HasSpectralGap casimir (casimir ⟨1, by omega⟩) := by
  exact ⟨ h_pos, ⟨ ⟨ 0, by linarith ⟩, fun i hi => by have := h_ordered ( show ⟨ 0, by linarith ⟩ ≤ i from Nat.zero_le _ ) ; have := h_ordered ( show i ≥ ⟨ 1, by linarith ⟩ from Nat.succ_le_of_lt ( show i.1 > 0 from Nat.pos_of_ne_zero fun hi' => hi <| Fin.ext hi' ) ) ; aesop ⟩ ⟩

/-- Positive Casimir over positive volume is positive. -/
theorem rep_theoretic_gap_bound {n : ℕ} (hn : 2 ≤ n)
    (casimir : Fin n → ℝ) (vol : ℝ) (hvol : 0 < vol)
    (h_pos : 0 < casimir ⟨1, by omega⟩) :
    0 < casimir ⟨1, by omega⟩ / vol :=
  div_pos h_pos hvol

/-! ## Part VI: Gauge-Invariant Observables -/

/-- A gauge-invariant energy: non-negative and conjugation-invariant. -/
structure GaugeInvariantEnergy (G : Type*) [Group G] where
  energy : G → ℝ
  energy_nonneg : ∀ g, 0 ≤ energy g
  energy_conj_inv : ∀ g h : G, energy (g * h * g⁻¹) = energy h

/-
Total plaquette energy is gauge-invariant.
-/
theorem total_plaquette_energy_gauge_invariant
    {V : Type*} [Fintype V] [DecidableEq V] {G : Type*} [Group G]
    (E : GaugeInvariantEnergy G) (g : V → G) (A : LatticeGaugeField G V)
    (faces : Finset (V × V × V × V)) :
    ∑ f ∈ faces, E.energy
      ((A.applyGauge g).plaquette f.1 f.2.1 f.2.2.1 f.2.2.2) =
    ∑ f ∈ faces, E.energy
      (A.plaquette f.1 f.2.1 f.2.2.1 f.2.2.2) := by
  rw [ Finset.sum_congr rfl ];
  intro f hf;
  rw [ LatticeGaugeField.plaquette_gauge_covariance ];
  exact E.energy_conj_inv _ _

/-
Total plaquette energy is non-negative.
-/
theorem total_plaquette_energy_nonneg
    {V : Type*} [Fintype V] [DecidableEq V] {G : Type*} [Group G]
    (E : GaugeInvariantEnergy G) (A : LatticeGaugeField G V)
    (faces : Finset (V × V × V × V)) :
    0 ≤ ∑ f ∈ faces, E.energy
      (A.plaquette f.1 f.2.1 f.2.2.1 f.2.2.2) := by
  exact Finset.sum_nonneg fun _ _ => E.energy_nonneg _

/-! ## Part VII: Mass Gap Lower Bound -/

/-- Mass gap lower bound from a Casimir spectrum. -/
noncomputable def mass_gap_lower_bound {n : ℕ} (casimir : Fin n → ℝ) : ℝ :=
  if h : n < 2 then 0
  else casimir ⟨1, by omega⟩

/-
The mass gap lower bound is non-negative for non-negative spectra.
-/
theorem mass_gap_lower_bound_nonneg {n : ℕ} (casimir : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ casimir i) :
    0 ≤ mass_gap_lower_bound casimir := by
  unfold mass_gap_lower_bound;
  grind

/-
The lower bound certifies the spectral gap when positive.
-/
theorem mass_gap_lower_bound_certifies {n : ℕ} (hn : 2 ≤ n)
    (casimir : Fin n → ℝ)
    (h_trivial : casimir ⟨0, by omega⟩ = 0)
    (hmono : Monotone casimir)
    (h_pos : 0 < casimir ⟨1, by omega⟩) :
    0 < mass_gap_lower_bound casimir ∧
    HasSpectralGap casimir (mass_gap_lower_bound casimir) := by
  unfold mass_gap_lower_bound;
  split_ifs <;> simp_all +decide [ HasSpectralGap ];
  · linarith;
  · exact ⟨ ⟨ 0, by linarith ⟩, fun i hi => by linarith [ hmono ( show ⟨ 0, by linarith ⟩ ≤ i from Nat.zero_le _ ), show casimir i ≥ casimir ⟨ 1, by linarith ⟩ from hmono ( show ⟨ 1, by linarith ⟩ ≤ i from Nat.succ_le_of_lt ( lt_of_le_of_ne ( Nat.zero_le _ ) ( Ne.symm ( by contrapose! hi; aesop ) ) ) ) ] ⟩

/-! ## Part VIII: Bridge to Catalog -/

/-
Convert function-based spectral gap to list-based format.
-/
theorem spectral_gap_to_list {n : ℕ} (hn : 2 ≤ n)
    (E : Fin n → ℝ) (gap : ℝ) (hgap : HasSpectralGap E gap)
    (_hE0 : E ⟨0, by omega⟩ = 0)
    (hground : ∀ i : Fin n, E ⟨0, by omega⟩ ≤ E i) :
    ∃ g : ℝ, 0 < g ∧
      ∃ e0 e1,
        (List.ofFn E)[0]? = some e0 ∧
        (List.ofFn E)[1]? = some e1 ∧
        g ≤ e1 - e0 := by
  rcases hgap with ⟨ hg, ⟨ i₀, hi₀ ⟩ ⟩;
  grind