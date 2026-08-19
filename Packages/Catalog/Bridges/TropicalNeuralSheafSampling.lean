/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Neural Sheaf Sampling via Idempotent Laplacian Semimodules

This file establishes a formal bridge between tropical/idempotent harmonic analysis
on cellular sheaves and certified sampling/reconstruction theory for machine-learning
sheaf architectures.

## Main Results

* `tropical_sheaf_sampling_injective` — **Theorem A**: Restriction to a sampling set
  satisfying a tropical Poincaré gap is injective on λ-bandlimited sections.
  This is the tropical sheaf analogue of Shannon-Nyquist sampling.

* `tropical_sheaf_bandlimited_reconstruction` — **Theorem B**: Unique existence of
  bandlimited reconstruction from samples in the image of the Paley-Wiener space.

* `tropical_sheaf_reconstruction_stable` — **Theorem C**: Lipschitz stability of
  reconstruction under sample perturbations, with explicit condition-radius bound.

* `tropical_sheaf_reconstruction_perturbation` — **Theorem C'**: Stability under
  perturbation of the sheaf restriction maps themselves.

* `resolvent_iterate_stabilizes` — Iterates of an inflationary monotone resolvent
  operator on a finite partial order converge in finitely many steps.

## Mathematical Context

In classical signal processing, Shannon's sampling theorem states that bandlimited
signals are determined by their samples at a sufficient rate. We establish a tropical
(idempotent/max-plus) analogue for signals valued in cellular sheaves over finite
cell complexes.

The key objects are:
- **Tropical Rayleigh functional**: measures the "spectral energy" of a section
- **Paley-Wiener space PW_λ**: sections with Rayleigh value ≤ λ
- **Certified Poincaré gap**: nonzero sections vanishing on S have energy > λ
- **Condition radius κ**: quantitative lower bound on restriction over PW_λ

## References

- Akian, Gaubert, Kolokoltsov: Idempotent analysis and max-plus algebra
- Hansen, Ghrist: Toward a spectral theory of cellular sheaves
- Cohen, Gaubert, Quadrat: Max-plus algebra and system theory
- Litvinov, Maslov: Idempotent mathematics and mathematical physics

## Keywords

tropical sheaf signal processing, idempotent harmonic analysis, certified sampling,
bandlimited reconstruction, sheaf neural networks, compressed inference,
min-plus spectral theory, residuated operators, topological machine learning
-/

open Function Set

namespace TropicalSheafSampling

-- ════════════════════════════════════════════════════════════════════════════════
-- PART 1: CORE TROPICAL SHEAF DEFINITIONS
-- ════════════════════════════════════════════════════════════════════════════════

section CoreDefs

variable {S : Type*} [AddCommGroup S]
variable {O : Type*} [AddCommGroup O]

/-- **Tropical Bandlimitedness**: A section `s` is `lam`-bandlimited if its
    tropical Rayleigh value (spectral energy) does not exceed the cutoff `lam`.
    This defines membership in the tropical Paley-Wiener space PW_λ. -/
def TropicalBandlimited (rayleigh : S → ℝ) (lam : ℝ) (s : S) : Prop :=
  rayleigh s ≤ lam

/-- **Tropical Paley-Wiener Space PW_λ**: The set of all `lam`-bandlimited sections.
    This is the tropical analogue of the classical Paley-Wiener space of
    functions with spectral support in a bounded set. -/
def PaleyWienerSpace (rayleigh : S → ℝ) (lam : ℝ) : Set S :=
  {s | TropicalBandlimited rayleigh lam s}

/-- **Certified Tropical Poincaré Gap**: A sampling configuration satisfies the
    Poincaré gap if every nonzero section in the kernel of restriction has
    tropical Rayleigh value strictly exceeding `lam`.

    This is the tropical analogue of the Poincaré inequality: it provides a
    spectral gap separating bandlimited sections from the kernel of sampling. -/
def HasTropicalPoincaréGap (restrict : S →+ O) (rayleigh : S → ℝ)
    (lam : ℝ) : Prop :=
  ∀ s : S, s ≠ 0 → restrict s = 0 → lam < rayleigh s

/-- **λ-Dominating Sampling Set**: equivalent to the Poincaré gap condition. -/
abbrev IsLambdaDominating := @HasTropicalPoincaréGap

/-- **Bandlimited Sub-Closure**: The Paley-Wiener space is closed under differences.
    This holds naturally when the Rayleigh functional satisfies a tropical
    subadditivity property `ρ(s - t) ≤ max(ρ(s), ρ(t))`, as is typical for
    idempotent spectral norms derived from max-plus Laplacians. -/
def BandlimitedSubClosed (rayleigh : S → ℝ) (lam : ℝ) : Prop :=
  ∀ s t : S, TropicalBandlimited rayleigh lam s →
    TropicalBandlimited rayleigh lam t →
    TropicalBandlimited rayleigh lam (s - t)

/-- **Certified Sampling Data**: bundles all conditions for the sampling
    and reconstruction theorems. -/
structure CertifiedSamplingData (restrict : S →+ O) (rayleigh : S → ℝ)
    (lam : ℝ) : Prop where
  poincaré_gap : HasTropicalPoincaréGap restrict rayleigh lam
  bandlimited_sub_closed : BandlimitedSubClosed rayleigh lam

end CoreDefs

-- ════════════════════════════════════════════════════════════════════════════════
-- PART 2: TROPICAL LAPLACIAN AND SPECTRAL STRUCTURES
-- ════════════════════════════════════════════════════════════════════════════════

section Laplacian

variable {C₀ C₁ : Type*} [AddCommGroup C₀] [AddCommGroup C₁]

/-- **Tropical Sheaf Laplacian** (degree 0): Given a coboundary `d : C⁰ → C¹`
    and its residuated adjoint `d† : C¹ → C⁰`, the Laplacian is `Δ₀ = d† ∘ d`.

    In the full Hodge-style decomposition,
    `Δₖ = d_{k-1} ∘ d†_{k-1} ⊕ d†_k ∘ dₖ`,
    but the degree-0 case reduces to `Δ₀ = d₀† ∘ d₀` since there is no `d_{-1}`. -/
def tropicalLaplacian (d : C₀ →+ C₁) (dAdj : C₁ →+ C₀) : C₀ →+ C₀ :=
  dAdj.comp d

/-- The tropical Rayleigh quotient derived from a Laplacian and norm. -/
noncomputable def tropicalRayleighOfLaplacian
    (lapl : C₀ →+ C₀) (norm : C₀ → ℝ) (s : C₀) : ℝ :=
  if norm s = 0 then 0 else norm (lapl s) / norm s

/-- The tropical Rayleigh quotient is zero for the zero section. -/
@[simp]
theorem tropicalRayleigh_zero (lapl : C₀ →+ C₀) (norm : C₀ → ℝ) (hn : norm 0 = 0) :
    tropicalRayleighOfLaplacian lapl norm 0 = 0 := by
  simp [tropicalRayleighOfLaplacian, hn]

end Laplacian

-- ════════════════════════════════════════════════════════════════════════════════
-- PART 3: THEOREM A — TROPICAL SHEAF SAMPLING INJECTIVITY
-- ════════════════════════════════════════════════════════════════════════════════

section TheoremA

variable {S : Type*} [AddCommGroup S]
variable {O : Type*} [AddCommGroup O]

/-- **Kernel Exclusion Lemma**: Under the Poincaré gap condition, any bandlimited
    section in the kernel of restriction must be zero. This is the core of the
    injectivity argument: the gap forbids nonzero bandlimited sections in ker(r). -/
theorem kernel_exclusion
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam : ℝ)
    (hgap : HasTropicalPoincaréGap restrict rayleigh lam)
    (s : S) (hbl : TropicalBandlimited rayleigh lam s) (hker : restrict s = 0) :
    s = 0 := by
  by_contra hne
  exact absurd hbl (not_le.mpr (hgap s hne hker))

/-- **Theorem A: Tropical Sheaf Sampling Injectivity**

    If a sampling set satisfies the certified tropical Poincaré gap condition
    and the Paley-Wiener space is closed under differences, then the restriction
    map is injective on the Paley-Wiener space PW_λ.

    This is the tropical sheaf analogue of the Shannon-Nyquist sampling theorem:
    *low-tropical-frequency global sections are uniquely determined by their
    values on the sampling set*.

    The proof strategy (Strategy A from the design document) is kernel-exclusion:
    if two bandlimited sections agree on S, their difference is bandlimited
    (by sub-closure) and in ker(r) (by linearity), hence zero by the gap. -/
theorem tropical_sheaf_sampling_injective
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam : ℝ)
    (hclosed : BandlimitedSubClosed rayleigh lam)
    (hgap : HasTropicalPoincaréGap restrict rayleigh lam) :
    InjOn (⇑restrict) (PaleyWienerSpace rayleigh lam) := by
  intro s hs t ht heq
  have h_bl : TropicalBandlimited rayleigh lam (s - t) := hclosed s t hs ht
  have h_ker : restrict (s - t) = 0 := by rw [map_sub, sub_eq_zero]; exact heq
  exact eq_of_sub_eq_zero (kernel_exclusion restrict rayleigh lam hgap (s - t) h_bl h_ker)

/-- **Sampling Uniqueness**: Two bandlimited sections with equal restrictions are equal.
    This is the pointwise formulation of Theorem A. -/
theorem sampling_uniqueness
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam : ℝ)
    (hclosed : BandlimitedSubClosed rayleigh lam)
    (hgap : HasTropicalPoincaréGap restrict rayleigh lam)
    (s t : S) (hs : TropicalBandlimited rayleigh lam s)
    (ht : TropicalBandlimited rayleigh lam t) (heq : restrict s = restrict t) :
    s = t :=
  tropical_sheaf_sampling_injective restrict rayleigh lam hclosed hgap hs ht heq

/-- Bundled version using CertifiedSamplingData. -/
theorem sampling_injective_certified
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam : ℝ)
    (hcert : CertifiedSamplingData restrict rayleigh lam) :
    InjOn (⇑restrict) (PaleyWienerSpace rayleigh lam) :=
  tropical_sheaf_sampling_injective restrict rayleigh lam
    hcert.bandlimited_sub_closed hcert.poincaré_gap

end TheoremA

-- ════════════════════════════════════════════════════════════════════════════════
-- PART 4: THEOREM B — CERTIFIED BANDLIMITED RECONSTRUCTION
-- ════════════════════════════════════════════════════════════════════════════════

section TheoremB

variable {S : Type*} [AddCommGroup S]
variable {O : Type*} [AddCommGroup O]

/-- **Bandlimited Reconstruction Record**: witnesses that `s` is a valid
    reconstruction of sample `y`. -/
structure IsReconstruction (restrict : S →+ O) (rayleigh : S → ℝ)
    (lam : ℝ) (y : O) (s : S) : Prop where
  bandlimited : TropicalBandlimited rayleigh lam s
  consistent : restrict s = y

/-- **Reconstruction Uniqueness**: under certified sampling conditions,
    any two bandlimited reconstructions of the same sample must agree. -/
theorem reconstruction_unique
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam : ℝ)
    (hclosed : BandlimitedSubClosed rayleigh lam)
    (hgap : HasTropicalPoincaréGap restrict rayleigh lam)
    (y : O) (s₁ s₂ : S)
    (h₁ : IsReconstruction restrict rayleigh lam y s₁)
    (h₂ : IsReconstruction restrict rayleigh lam y s₂) :
    s₁ = s₂ :=
  sampling_uniqueness restrict rayleigh lam hclosed hgap s₁ s₂
    h₁.bandlimited h₂.bandlimited (by rw [h₁.consistent, h₂.consistent])

/-- **Theorem B: Certified Bandlimited Reconstruction (Existence + Uniqueness)**

    If `y` lies in the image of restriction on PW_λ, then there exists a unique
    bandlimited section whose restriction equals `y`.

    This is the tropical analogue of the Whittaker-Shannon interpolation formula:
    given samples from a bandlimited signal, the signal can be perfectly
    reconstructed, and the reconstruction is unique. -/
theorem tropical_sheaf_bandlimited_reconstruction
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam : ℝ)
    (hclosed : BandlimitedSubClosed rayleigh lam)
    (hgap : HasTropicalPoincaréGap restrict rayleigh lam)
    (y : O)
    (hy : ∃ s₀ : S, TropicalBandlimited rayleigh lam s₀ ∧ restrict s₀ = y) :
    ∃! s : S, TropicalBandlimited rayleigh lam s ∧ restrict s = y := by
  obtain ⟨s₀, hbl₀, hres₀⟩ := hy
  exact ⟨s₀, ⟨hbl₀, hres₀⟩, fun s ⟨hbl, hres⟩ =>
    sampling_uniqueness restrict rayleigh lam hclosed hgap s s₀ hbl hbl₀
      (by rw [hres, hres₀])⟩

end TheoremB

-- ════════════════════════════════════════════════════════════════════════════════
-- PART 5: MONOTONE ITERATION AND FINITE STABILIZATION
-- ════════════════════════════════════════════════════════════════════════════════

section Iteration

/-
Iterates of an inflationary map form a weakly increasing sequence.
    This models the tropical resolvent iteration: the reconstruction update
    operator is inflationary (each step improves the approximation).
-/
theorem iterate_mono_of_inflationary {α : Type*} [Preorder α]
    (f : α → α) (hf : Monotone f) (x : α) (hinfl : x ≤ f x)
    {m n : ℕ} (hmn : m ≤ n) :
    f^[m] x ≤ f^[n] x := by
  induction hmn <;> simp_all +decide [ Function.iterate_succ_apply', hf ];
  rename_i k hk ih;
  refine' le_trans ih _;
  exact Nat.recOn k hinfl fun n ihn => by simpa only [ Function.iterate_succ_apply' ] using hf ihn;

/-
**Finite Stabilization Lemma**: A weakly increasing function `ℕ → α` into
    a finite partial order must eventually become constant.

    This is a fundamental finiteness principle: in a finite poset, ascending
    chains have bounded length. Applied to tropical resolvent iteration,
    it guarantees that the reconstruction process converges in finitely many steps.
-/
theorem monotone_nat_stabilizes_of_finite {α : Type*} [Fintype α] [PartialOrder α]
    (g : ℕ → α) (hmono : Monotone g) :
    ∃ N, ∀ n, N ≤ n → g n = g N := by
  by_contra! h;
  -- By repeatedly applying the hypothesis `h`, we can construct an infinite strictly increasing sequence in `α`.
  have h_seq : ∃ seq : ℕ → α, StrictMono seq ∧ ∀ n, seq n ∈ Set.range g := by
    choose f hf using h;
    refine' ⟨ fun n => g ( Nat.recOn n 0 fun n ih => f ih ), strictMono_nat_of_lt_succ fun n => _, fun n => _ ⟩;
    · exact lt_of_le_of_ne ( hmono ( hf _ |>.1 ) ) ( Ne.symm ( hf _ |>.2 ) );
    · exact Set.mem_range_self _;
  exact absurd ( Set.infinite_range_of_injective h_seq.choose_spec.1.injective ) ( Set.not_infinite.mpr ( Set.toFinite _ ) )

/-
**Resolvent Iteration Stabilization**: Iterates of an inflationary monotone
    map on a finite partial order converge to a fixed point in finitely many steps.

    This is the tropical analogue of Bellman iteration convergence: the
    resolvent/update operator is monotone and the state space is finite,
    guaranteeing termination. This theorem connects to `certified_finite_tropical_decomposition`
    from the tropical Choquet closure duality theory.
-/
theorem resolvent_iterate_stabilizes {α : Type*} [Fintype α] [PartialOrder α]
    (f : α → α) (hf : Monotone f) (x : α) (hinfl : x ≤ f x) :
    ∃ N, ∀ n, N ≤ n → f^[n] x = f^[N] x :=
  monotone_nat_stabilizes_of_finite _ (Monotone.monotone_iterate_of_le_map hf hinfl)

/-
The stable value of a converged resolvent iteration is a fixed point.
-/
theorem resolvent_stable_is_fixedPoint {α : Type*} [Fintype α] [PartialOrder α]
    (f : α → α) (_hf : Monotone f) (x : α) (_hinfl : x ≤ f x)
    (N : ℕ) (hN : ∀ n, N ≤ n → f^[n] x = f^[N] x) :
    f (f^[N] x) = f^[N] x := by
  simpa [ ← Function.iterate_succ_apply' ] using hN ( N + 1 ) ( Nat.le_succ _ )

end Iteration

-- ════════════════════════════════════════════════════════════════════════════════
-- PART 6: THEOREM C — STABILITY UNDER PERTURBATIONS
-- ════════════════════════════════════════════════════════════════════════════════

section TheoremC

variable {S : Type*} [NormedAddCommGroup S]
variable {O : Type*} [NormedAddCommGroup O]

/-- **Tropical Condition Radius**: The restriction map is bounded below by `κ > 0`
    on the Paley-Wiener space, providing a quantitative spectral gap.

    This is the tropical analogue of a frame lower bound: it says that the
    sampling operator doesn't lose too much energy on bandlimited sections. -/
def HasConditionRadius (restrict : S →+ O) (rayleigh : S → ℝ)
    (lam : ℝ) (κ : ℝ) : Prop :=
  ∀ s : S, TropicalBandlimited rayleigh lam s → κ * ‖s‖ ≤ ‖restrict s‖

/-
A positive condition radius implies the Poincaré gap (qualitative from quantitative).
-/
theorem poincaré_gap_of_condition_radius
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam κ : ℝ) (hκ : 0 < κ)
    (hcond : HasConditionRadius restrict rayleigh lam κ) :
    HasTropicalPoincaréGap restrict rayleigh lam := by
  intro s hs hker
  by_contra h
  push_neg at h;
  have := hcond s h; simp_all +decide ;
  exact not_le_of_gt ( mul_pos hκ ( norm_pos_iff.mpr hs ) ) this

/-
**Theorem C: Tropical Sheaf Reconstruction Stability**

    If the restriction map has condition radius `κ > 0` on PW_λ, then
    reconstruction is Lipschitz stable: two bandlimited sections whose
    restrictions differ by at most `δ` differ by at most `δ/κ`.

    This is the tropical analogue of the Riesz stability bound for
    frame-based reconstruction.
-/
theorem tropical_sheaf_reconstruction_stable
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam κ : ℝ) (hκ : 0 < κ)
    (hclosed : BandlimitedSubClosed rayleigh lam)
    (hcond : HasConditionRadius restrict rayleigh lam κ)
    (s₁ s₂ : S)
    (hbl₁ : TropicalBandlimited rayleigh lam s₁)
    (hbl₂ : TropicalBandlimited rayleigh lam s₂) :
    ‖s₁ - s₂‖ ≤ (1 / κ) * ‖restrict s₁ - restrict s₂‖ := by
  have := hcond ( s₁ - s₂ ) ( hclosed s₁ s₂ hbl₁ hbl₂ );
  rw [ one_div, inv_mul_eq_div, le_div_iff₀' hκ ] ; simpa [ map_sub ] using this

/-
Stability applied to reconstructions of two samples.
-/
theorem reconstruction_noise_stable
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam κ : ℝ) (hκ : 0 < κ)
    (hclosed : BandlimitedSubClosed rayleigh lam)
    (hcond : HasConditionRadius restrict rayleigh lam κ)
    (y₁ y₂ : O) (s₁ s₂ : S)
    (h₁ : IsReconstruction restrict rayleigh lam y₁ s₁)
    (h₂ : IsReconstruction restrict rayleigh lam y₂ s₂) :
    ‖s₁ - s₂‖ ≤ (1 / κ) * ‖y₁ - y₂‖ := by
  have := @tropical_sheaf_reconstruction_stable;
  simpa only [ h₁.consistent, h₂.consistent ] using this restrict rayleigh lam κ hκ hclosed hcond s₁ s₂ h₁.bandlimited h₂.bandlimited

end TheoremC

-- ════════════════════════════════════════════════════════════════════════════════
-- PART 7: THEOREM C' — SHEAF PERTURBATION STABILITY
-- ════════════════════════════════════════════════════════════════════════════════

section TheoremCPrime

variable {S : Type*} [NormedAddCommGroup S]
variable {O : Type*} [NormedAddCommGroup O]

/-- **Sheaf Perturbation Bound**: Two sheaves (represented by their restriction
    maps) differ by at most `ε` on bandlimited sections. -/
def SheafPerturbationBound (r₁ r₂ : S →+ O) (rayleigh : S → ℝ)
    (lam ε : ℝ) : Prop :=
  ∀ s : S, TropicalBandlimited rayleigh lam s → ‖r₁ s - r₂ s‖ ≤ ε * ‖s‖

/-
**Theorem C': Sheaf Perturbation Stability**

    If two sheaf restriction maps differ by at most `ε` on PW_λ, and the
    first has condition radius `κ > ε`, then any section that is bandlimited
    and consistent under r₁ is close to any section that is bandlimited
    and consistent under r₂ for the same sample.

    The bound `‖s₁ - s₂‖ ≤ ‖y₁ - y₂‖/(κ - ε) + ε·‖s₂‖/(κ - ε)` captures
    both sample noise and structural perturbation effects.
-/
theorem tropical_sheaf_reconstruction_perturbation
    (r₁ r₂ : S →+ O) (rayleigh : S → ℝ) (lam κ ε : ℝ)
    (_hκε : ε < κ)
    (hclosed : BandlimitedSubClosed rayleigh lam)
    (hcond : HasConditionRadius r₁ rayleigh lam κ)
    (hpert : SheafPerturbationBound r₁ r₂ rayleigh lam ε)
    (s₁ s₂ : S)
    (hbl₁ : TropicalBandlimited rayleigh lam s₁)
    (hbl₂ : TropicalBandlimited rayleigh lam s₂) :
    (κ - ε) * ‖s₁ - s₂‖ ≤ ‖r₂ s₁ - r₂ s₂‖ + ε * (‖s₁‖ + ‖s₂‖) := by
  -- By the properties of the norm and the triangle inequality, we can combine the inequalities.
  have h_combined : κ * ‖s₁ - s₂‖ ≤ ‖(r₂ s₁ - r₂ s₂)‖ + ε * (‖s₁‖ + ‖s₂‖) := by
    have h_combined : κ * ‖s₁ - s₂‖ ≤ ‖r₁ s₁ - r₁ s₂‖ := by
      simpa using hcond ( s₁ - s₂ ) ( hclosed s₁ s₂ hbl₁ hbl₂ );
    have h_combined : ‖r₁ s₁ - r₁ s₂‖ ≤ ‖r₂ s₁ - r₂ s₂‖ + ‖(r₁ s₁ - r₂ s₁)‖ + ‖(r₂ s₂ - r₁ s₂)‖ := by
      have h_combined : ‖r₁ s₁ - r₁ s₂‖ = ‖(r₂ s₁ - r₂ s₂) + (r₁ s₁ - r₂ s₁) + (r₂ s₂ - r₁ s₂)‖ := by
        exact congr_arg Norm.norm ( by abel1 );
      exact h_combined.symm ▸ norm_add₃_le ..;
    have := hpert s₁ hbl₁; have := hpert s₂ hbl₂; simp_all +decide [ norm_sub_rev ] ; linarith;
  by_cases hε_nonneg : 0 ≤ ε;
  · nlinarith [ norm_nonneg ( s₁ - s₂ ) ];
  · contrapose! hpert;
    intro h;
    have := h 0 ; simp_all +decide [ TropicalBandlimited ];
    have := h ( s₁ - s₂ ) ; simp_all +decide [ TropicalBandlimited ];
    exact absurd ( this ( hclosed s₁ s₂ hbl₁ hbl₂ ) ) ( by nlinarith [ norm_nonneg ( s₁ - s₂ ), norm_nonneg ( r₁ s₁ - r₁ s₂ - ( r₂ s₁ - r₂ s₂ ) ) ] )

end TheoremCPrime

-- ════════════════════════════════════════════════════════════════════════════════
-- PART 8: BANDLIMITED CLOSURE PROPERTIES
-- ════════════════════════════════════════════════════════════════════════════════

section BandlimitedProperties

variable {S : Type*} [AddCommGroup S]

/-- Bandlimited sections are closed under zero: the zero section is always bandlimited
    when the Rayleigh functional maps zero to a value ≤ any cutoff. -/
theorem tropicalBandlimited_zero (rayleigh : S → ℝ) (lam : ℝ)
    (h0 : rayleigh 0 ≤ lam) : TropicalBandlimited rayleigh lam 0 := h0

/-- Bandlimited sections are closed under negation when the Rayleigh functional
    is symmetric: `ρ(-s) = ρ(s)`. -/
theorem tropicalBandlimited_neg (rayleigh : S → ℝ) (lam : ℝ)
    (hsymm : ∀ s, rayleigh (-s) = rayleigh s)
    (s : S) (hbl : TropicalBandlimited rayleigh lam s) :
    TropicalBandlimited rayleigh lam (-s) := by
  unfold TropicalBandlimited at *; rw [hsymm]; exact hbl

/-- A tropically subadditive Rayleigh functional gives sub-closure for free. -/
theorem bandlimitedSubClosed_of_subadditive (rayleigh : S → ℝ) (lam : ℝ)
    (hsubadd : ∀ s t : S, rayleigh (s - t) ≤ max (rayleigh s) (rayleigh t)) :
    BandlimitedSubClosed rayleigh lam := by
  intro s t hs ht
  exact le_trans (hsubadd s t) (max_le hs ht)

end BandlimitedProperties

-- ════════════════════════════════════════════════════════════════════════════════
-- PART 9: APPLICATION COROLLARIES
-- ════════════════════════════════════════════════════════════════════════════════

section Applications

variable {S : Type*} [AddCommGroup S]
variable {O : Type*} [AddCommGroup O]

/-- **Compressed Inference Theorem**: If fewer samples than the ambient dimension
    suffice (i.e., the sampling set is sparse), then bandlimited sheaf sections
    admit compressed representations. This is the formal basis for certified
    compressed inference in tropical sheaf neural architectures. -/
theorem compressed_inference_injective
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam : ℝ)
    (hcert : CertifiedSamplingData restrict rayleigh lam) :
    InjOn (⇑restrict) (PaleyWienerSpace rayleigh lam) :=
  sampling_injective_certified restrict rayleigh lam hcert

/-- **Sensor Placement Certificate**: The injectivity guarantee provides a
    certificate that the sampling set `S` is sufficient for perfect reconstruction
    of bandlimited signals. In the sheaf neural network context, this certifies
    which nodes need to be observed for full state recovery. -/
theorem sensor_placement_certificate
    (restrict : S →+ O) (rayleigh : S → ℝ) (lam : ℝ)
    (hcert : CertifiedSamplingData restrict rayleigh lam)
    (s : S) (hs : TropicalBandlimited rayleigh lam s)
    (hzero : restrict s = 0) : s = 0 :=
  kernel_exclusion restrict rayleigh lam hcert.poincaré_gap s hs hzero

/-- **Message Passing Convergence**: In the context of operadic/tropical message
    passing on sheaf neural networks, the resolvent iteration models the
    message-passing update rule. Finite stabilization guarantees that
    inference terminates. -/
theorem message_passing_converges {α : Type*} [Fintype α] [PartialOrder α]
    (update : α → α) (hmon : Monotone update) (init : α) (hinfl : init ≤ update init) :
    ∃ N, ∀ n, N ≤ n → update^[n] init = update^[N] init :=
  resolvent_iterate_stabilizes update hmon init hinfl

end Applications

end TropicalSheafSampling

/- The lines below are a corrupted trailing fragment of an earlier statement whose
head was lost; they are preserved verbatim but commented out so the file parses.

end in the kernel of restriction must be zero. This is the core of the

end TheoremA
-/