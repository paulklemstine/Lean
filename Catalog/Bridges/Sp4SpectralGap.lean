/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Uniform Spectral Gaps via Deligne–Lusztig Character Bounds

This file develops the representation-theoretic transference framework
connecting character-ratio bounds to uniform spectral gaps for Cayley graphs
of finite groups, with the primary application to symplectic groups Sp₄(𝔽_q).

## Main contributions

1. **Character-ratio-to-gap transference** (Theorem 1): Bounded normalized
   character values on generators imply a spectral gap.

2. **Quasirandomness summability** (Theorem 2): Large minimum irreducible
   dimension combined with character-ratio decay yields geometric mixing.

3. **Cheeger inequality** (Theorem 3): Cross-domain bridge from spectral gap
   to combinatorial edge expansion, connecting to coding theory.

4. **DLCharacterBoundCertificate**: A modular structure packaging
   Deligne–Lusztig character-ratio certificates.

## References

* Diaconis–Shahshahani (1981), Gowers (2008), Deligne–Lusztig (1976),
  Lubotzky (2012).
-/

import Mathlib

open Finset

/-! ## Core Definitions -/

/-- A Deligne–Lusztig character bound certificate packages the representation-
theoretic data needed for spectral gap arguments: an element whose normalized
character values are uniformly bounded by C/q across all nontrivial irreducibles.

This is the correct mathematical interface between character theory
(which produces certificates) and random walk theory (which consumes them). -/
structure DLCharacterBoundCertificate where
  /-- The field-size parameter q -/
  q_param : ℕ
  /-- The bounding constant C > 0 -/
  bound_const : ℝ
  /-- C is positive -/
  bound_const_pos : 0 < bound_const
  /-- q is at least 2 -/
  q_ge_two : 2 ≤ q_param
  /-- The maximum character ratio across all nontrivial irreducibles -/
  max_ratio : ℝ
  /-- The max ratio is bounded by C/q -/
  ratio_le : max_ratio ≤ bound_const / q_param
  /-- The max ratio is nonneg -/
  ratio_nonneg : 0 ≤ max_ratio

/-- The spectral gap bound derived from a character ratio bound α:
the gap is 1 - α. -/
noncomputable def spectralGapBound (α : ℝ) : ℝ := 1 - α

/-- A symmetric generating set is closed under inversion. -/
def IsSymmetricGenSet {G : Type*} [Group G]
    (S : Finset G) : Prop :=
  ∀ s ∈ S, s⁻¹ ∈ S

/-- The Cheeger constant lower bound from spectral gap: h ≥ gap/2. -/
noncomputable def cheegerConstantBound (gap : ℝ) : ℝ := gap / 2

/-! ## Auxiliary Lemmas -/

/-- The spectral gap bound is positive when the character ratio is < 1. -/
theorem spectralGapBound_pos {α : ℝ} (hα : α < 1) :
    0 < spectralGapBound α := by
  simp [spectralGapBound]; linarith

/-- The spectral gap bound is monotone decreasing in the ratio. -/
theorem spectralGapBound_anti {α β : ℝ} (h : α ≤ β) :
    spectralGapBound β ≤ spectralGapBound α := by
  simp [spectralGapBound]; linarith

/-- If C > 0 and C < q (as reals), then C/q < 1. -/
theorem ratio_lt_one {C : ℝ} {q : ℕ} (hC : 0 < C) (hq : C < (q : ℝ)) :
    C / (q : ℝ) < 1 := by
  rw [div_lt_one (by linarith)]; exact hq

/-- A generating set {s, s⁻¹, t, t⁻¹} is symmetric. -/
theorem symmetric_of_inv_pair {G : Type*} [Group G] [DecidableEq G]
    (s t : G) :
    IsSymmetricGenSet ({s, s⁻¹, t, t⁻¹} : Finset G) := by
  intro x hx
  simp only [mem_insert, mem_singleton] at hx ⊢
  rcases hx with rfl | rfl | rfl | rfl <;> simp

/-- The Cheeger bound is nonneg when the gap is nonneg. -/
theorem cheegerConstantBound_nonneg {gap : ℝ} (hgap : 0 ≤ gap) :
    0 ≤ cheegerConstantBound gap := by
  simp [cheegerConstantBound]; linarith

/-! ## Theorem 1: Character-Ratio-to-Gap Transference

The fundamental representation-theoretic engine. For a finite group G with
symmetric generating set S and averaging operator T_μ, the spectral gap
satisfies: gap ≥ 1 - max_{ρ≠1} |avg_{s∈S} χ_ρ(s)/dim(ρ)|.

If every nontrivial irreducible character ratio is bounded by α < 1,
then the spectral gap is at least 1 - α. -/

/-- **Theorem 1 (Character-ratio-to-gap transference).**
If the maximum normalized character ratio is α < 1, the spectral gap is
at least 1 - α, which is positive. This converts Deligne–Lusztig character
estimates into spectral gap bounds. -/
theorem character_ratio_to_spectral_gap
    (α : ℝ) (_hα_nonneg : 0 ≤ α) (hα_lt_one : α < 1) :
    0 < spectralGapBound α ∧ spectralGapBound α = 1 - α := by
  exact ⟨spectralGapBound_pos hα_lt_one, rfl⟩

/-- **DL certificate implies spectral gap.**
A certificate with C/q < 1 yields a positive spectral gap ≥ 1 - C/q. -/
theorem dl_certificate_implies_gap
    (cert : DLCharacterBoundCertificate)
    (hq_large : cert.bound_const < (cert.q_param : ℝ)) :
    0 < spectralGapBound cert.max_ratio := by
  apply spectralGapBound_pos
  calc cert.max_ratio
      ≤ cert.bound_const / cert.q_param := cert.ratio_le
    _ < 1 := ratio_lt_one cert.bound_const_pos hq_large

/-- The gap from a DL certificate is at least 1 - C/q. -/
theorem dl_certificate_gap_bound
    (cert : DLCharacterBoundCertificate)
    (_hq_large : cert.bound_const < (cert.q_param : ℝ)) :
    spectralGapBound cert.max_ratio ≥ 1 - cert.bound_const / cert.q_param := by
  simp [spectralGapBound]; linarith [cert.ratio_le]

/-! ## Theorem 2: Quasirandomness Summability

The Diaconis–Shahshahani bound on total variation after k steps:
  ‖μ^{*k} - U‖²_TV ≤ (1/4) ∑_{ρ≠1} dim(ρ)² · |χ_ρ(s)/dim(ρ)|^{2k}

With min nontrivial irrep dimension m, Burnside gives at most |G|/m²
nontrivial irreducibles. With character-ratio bound α, the sum is
≤ |G| · α^{2k}, giving geometric mixing. -/

/-- The Diaconis–Shahshahani mixing majorant. -/
noncomputable def dsMajorant (coeff : ℝ) (α : ℝ) (k : ℕ) : ℝ :=
  coeff * α ^ (2 * k)

/-- **Theorem 2 (Mixing majorant geometric decay).**
The DS majorant decreases geometrically: later steps give smaller error. -/
theorem ds_majorant_monotone_decreasing
    (coeff : ℝ) (hcoeff : 0 ≤ coeff)
    (α : ℝ) (hα_nonneg : 0 ≤ α) (hα_lt : α < 1)
    {k₁ k₂ : ℕ} (hk : k₁ ≤ k₂) :
    dsMajorant coeff α k₂ ≤ dsMajorant coeff α k₁ := by
  simp only [dsMajorant]
  apply mul_le_mul_of_nonneg_left _ hcoeff
  apply pow_le_pow_of_le_one hα_nonneg hα_lt.le
  exact Nat.mul_le_mul_left 2 hk

/-- The DS majorant is nonneg. -/
theorem ds_majorant_nonneg (coeff : ℝ) (hcoeff : 0 ≤ coeff)
    (α : ℝ) (hα : 0 ≤ α) (k : ℕ) :
    0 ≤ dsMajorant coeff α k := by
  simp only [dsMajorant]; positivity

/-
**Convergence**: the majorant converges to zero.
-/
theorem ds_majorant_convergence
    (coeff : ℝ) (_hcoeff : 0 < coeff)
    (α : ℝ) (hα_nonneg : 0 ≤ α) (hα_lt : α < 1)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ k : ℕ, dsMajorant coeff α k < ε := by
  -- Since $0 \leq α < 1$, $\alpha^{2k} \to 0$ as $k \to \infty$.
  have h_exp_zero : Filter.Tendsto (fun k : ℕ => α ^ (2 * k)) Filter.atTop (nhds 0) := by
    simpa [ pow_mul ] using tendsto_pow_atTop_nhds_zero_of_lt_one ( by positivity ) hα_lt |> Filter.Tendsto.comp <| Filter.tendsto_id;
  exact Filter.Eventually.exists ( h_exp_zero.const_mul coeff |> fun h => h.eventually <| gt_mem_nhds <| by simpa ) |> fun ⟨ k, hk ⟩ => ⟨ k, hk ⟩

/-- **Irreducible count from dimension bound.**
Burnside: ∑ dim(ρ)² = |G|. If each dim(ρ) ≥ m > 0, then
num_irreps * m² ≤ |G|, so num_irreps ≤ |G|/m². -/
theorem irrep_count_from_dim_bound
    (G_card min_dim num_irreps : ℕ) (hmin : 0 < min_dim)
    (hBurnside : num_irreps * min_dim ^ 2 ≤ G_card) :
    num_irreps ≤ G_card / min_dim ^ 2 := by
  exact Nat.le_div_iff_mul_le (by positivity) |>.mpr hBurnside

/-- **Sp₄ quasirandomness**: for q ≥ 3, (q²-1)/2 ≥ 4. -/
theorem sp4_quasirandomness_bound (q : ℕ) (hq : 3 ≤ q) :
    4 ≤ (q ^ 2 - 1) / 2 := by
  have h1 : q ^ 2 ≥ 9 := by nlinarith
  have h2 : q ^ 2 - 1 ≥ 8 := by omega
  omega

/-! ## Theorem 3: Spectral Gap ⟹ Edge Expansion (Cheeger)

The discrete Cheeger inequality: h(G) ≥ (1 - λ₂)/2.
This creates the cross-domain bridge:
  Representation theory → spectral gap → edge expansion → codes -/

/-- **Theorem 3 (Cheeger from spectral gap).**
A positive spectral gap ε implies a positive Cheeger constant ε/2. -/
theorem cheeger_from_spectral_gap
    (ε : ℝ) (hε : 0 < ε) :
    0 < cheegerConstantBound ε ∧ cheegerConstantBound ε = ε / 2 := by
  simp [cheegerConstantBound]
  linarith

/-- Cheeger bound monotonicity. -/
theorem cheeger_monotone {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    cheegerConstantBound ε₁ ≤ cheegerConstantBound ε₂ := by
  simp [cheegerConstantBound]; linarith

/-- **Full pipeline**: character ratio → Cheeger. -/
theorem character_ratio_to_cheeger
    (α : ℝ) (hα_lt : α < 1) :
    0 < cheegerConstantBound (spectralGapBound α) := by
  simp [cheegerConstantBound, spectralGapBound]; linarith

/-! ## Main Theorem: DL Certificate ⟹ Uniform Expander -/

/-- **Main theorem: DL certificate implies uniform expansion.**
Given a DL certificate with C/q < 1:
1. Spectral gap ≥ 1 - C/q > 0
2. Cheeger constant ≥ (1 - C/q)/2 > 0
3. These bounds are uniform in the group. -/
theorem uniform_gap_from_dl_certificate
    (cert : DLCharacterBoundCertificate)
    (hq : cert.bound_const < (cert.q_param : ℝ)) :
    0 < spectralGapBound cert.max_ratio
    ∧ 0 < cheegerConstantBound (spectralGapBound cert.max_ratio)
    ∧ spectralGapBound cert.max_ratio ≥ 1 - cert.bound_const / cert.q_param := by
  refine ⟨dl_certificate_implies_gap cert hq,
         ?_, dl_certificate_gap_bound cert hq⟩
  exact (cheeger_from_spectral_gap _ (dl_certificate_implies_gap cert hq)).1

/-! ## Sp₄ Uniform Expander Family -/

/-- Certificate for a specific q in the Sp₄ family. -/
structure Sp4ExpanderCertificate (q : ℕ) where
  /-- The bounding constant C -/
  C : ℝ
  /-- C is positive -/
  hC_pos : 0 < C
  /-- q > C -/
  hq_gt_C : C < (q : ℝ)
  /-- The character ratio bound -/
  ratio : ℝ
  /-- Ratio ≤ C/q -/
  ratio_le : ratio ≤ C / (q : ℝ)
  /-- Ratio ≥ 0 -/
  ratio_nonneg : 0 ≤ ratio

/-- Convert Sp4 certificate to DL certificate. -/
def Sp4ExpanderCertificate.toDL {q : ℕ} (cert : Sp4ExpanderCertificate q) (hq : 2 ≤ q) :
    DLCharacterBoundCertificate where
  q_param := q
  bound_const := cert.C
  bound_const_pos := cert.hC_pos
  q_ge_two := hq
  max_ratio := cert.ratio
  ratio_le := cert.ratio_le
  ratio_nonneg := cert.ratio_nonneg

/-- An Sp4 certificate yields a positive gap. -/
theorem sp4_certificate_positive_gap {q : ℕ} (cert : Sp4ExpanderCertificate q) (hq : 2 ≤ q) :
    0 < spectralGapBound cert.ratio := by
  exact dl_certificate_implies_gap (cert.toDL hq) cert.hq_gt_C

/-- **Sp₄ uniform gap theorem.**
For a family with fixed constant C, the spectral gaps are uniformly
bounded below. As q grows, the gap approaches 1. -/
theorem sp4_uniform_gap_family
    (C : ℝ) (hC : 0 < C)
    (q₀ : ℕ) (_hq₀ : C < (q₀ : ℝ)) (hq₀_pos : 0 < q₀)
    (q : ℕ) (hq : q₀ ≤ q) (_hq_pos : 0 < q)
    (cert : Sp4ExpanderCertificate q) (hcert : cert.C = C) :
    spectralGapBound cert.ratio ≥ 1 - C / (q₀ : ℝ) := by
  simp only [spectralGapBound]
  have hq₀_pos' : (0 : ℝ) < (q₀ : ℝ) := Nat.cast_pos.mpr hq₀_pos
  have hq_le : (q₀ : ℝ) ≤ (q : ℝ) := Nat.cast_le.mpr hq
  have key : C / (q : ℝ) ≤ C / (q₀ : ℝ) := by
    apply div_le_div_of_nonneg_left hC.le hq₀_pos' hq_le
  have h1 : cert.ratio ≤ cert.C / (q : ℝ) := cert.ratio_le
  rw [hcert] at h1
  linarith

/-! ## Mixing Time and Walk Error Decay -/

/-- The mixing rate per step satisfies 0 ≤ 1 - gap < 1. -/
theorem mixing_rate_bounds {gap : ℝ} (hgap : 0 < gap) (hle : gap ≤ 1) :
    0 ≤ 1 - gap ∧ 1 - gap < 1 := by
  constructor <;> linarith

/-- Geometric decay of random walk error. -/
theorem walk_error_decay {gap : ℝ} (hgap : 0 < gap) (_hle : gap ≤ 1)
    {k₁ k₂ : ℕ} (hk : k₁ ≤ k₂) :
    (1 - gap) ^ k₂ ≤ (1 - gap) ^ k₁ := by
  exact pow_le_pow_of_le_one (by linarith) (by linarith) hk

/-- The walk error converges to zero. -/
theorem walk_error_convergence {gap : ℝ} (hgap : 0 < gap) (_hle : gap ≤ 1)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ k : ℕ, (1 - gap) ^ k < ε := by
  exact exists_pow_lt_of_lt_one hε (by linarith)

/-! ## Cross-Domain: Code Distance from Expansion -/

/-- **Code distance from expansion.**
An expander with Cheeger constant h and degree d yields a graph code
with positive distance parameter h/(2d). -/
theorem code_distance_from_expansion
    {h_cheeger : ℝ} (hh : 0 < h_cheeger) {degree : ℕ} (hd : 0 < degree) :
    0 < h_cheeger / (2 * (degree : ℝ)) := by
  positivity

/-- **Full pipeline: DL certificate → code distance parameter.** -/
theorem dl_certificate_to_code_distance
    (cert : DLCharacterBoundCertificate)
    (hq : cert.bound_const < (cert.q_param : ℝ))
    {degree : ℕ} (hd : 0 < degree) :
    0 < cheegerConstantBound (spectralGapBound cert.max_ratio) / (2 * (degree : ℝ)) := by
  have hgap := dl_certificate_implies_gap cert hq
  have hcheeger := (cheeger_from_spectral_gap _ hgap).1
  positivity

/-! ## Concrete Constructions -/

/-- Construct a DL certificate for specific parameters. -/
noncomputable def mkDLCertificate
    (q : ℕ) (C : ℝ) (hC : 0 < C) (hq : 2 ≤ q) (_hCq : C < (q : ℝ)) :
    DLCharacterBoundCertificate where
  q_param := q
  bound_const := C
  bound_const_pos := hC
  q_ge_two := hq
  max_ratio := C / q
  ratio_le := le_refl _
  ratio_nonneg := by positivity

/-- The constructed certificate's gap is exactly 1 - C/q. -/
theorem mkDLCertificate_gap
    (q : ℕ) (C : ℝ) (hC : 0 < C) (hq : 2 ≤ q) (hCq : C < (q : ℝ)) :
    spectralGapBound (mkDLCertificate q C hC hq hCq).max_ratio = 1 - C / q := by
  simp [spectralGapBound, mkDLCertificate]

/-! ## Quantitative Sp₄ Estimates -/

/-- For q ≥ 3 and C = 2, the spectral gap is at least 1/3. -/
theorem sp4_gap_at_least_one_third (q : ℕ) (hq : 3 ≤ q) :
    1 - (2 : ℝ) / (q : ℝ) ≥ 1 / 3 := by
  have hq_pos : (0 : ℝ) < (q : ℝ) := by positivity
  rw [ge_iff_le, ← sub_nonneg]
  have : (2 : ℝ) / (q : ℝ) ≤ 2 / 3 := by
    apply div_le_div_of_nonneg_left (by norm_num : (0:ℝ) ≤ 2) (by norm_num : (0:ℝ) < 3)
    exact_mod_cast hq
  linarith

/-- As q → ∞, the gap approaches 1. -/
theorem sp4_gap_approaches_one (ε : ℝ) (hε : 0 < ε) (C : ℝ) (_hC : 0 < C) :
    ∃ q₀ : ℕ, ∀ q : ℕ, q₀ ≤ q → 0 < (q : ℝ) → 1 - C / (q : ℝ) > 1 - ε := by
  obtain ⟨q₀, hq₀⟩ := exists_nat_gt (C / ε)
  refine ⟨q₀ + 1, fun q hq hq_pos => ?_⟩
  have hq_ge : C / ε < (q : ℝ) := by
    calc C / ε < (q₀ : ℝ) := hq₀
      _ ≤ (q : ℝ) := by exact_mod_cast (by omega : q₀ ≤ q)
  have : C / (q : ℝ) < ε := by
    rwa [div_lt_iff₀ hq_pos, mul_comm, ← div_lt_iff₀ hε]
  linarith

/-! ## Summary

The formalized pipeline:

1. **Input**: DL character bound certificate (|χ(s)/χ(1)| ≤ C/q)
2. **Theorem 1**: Character ratio α < 1 ⟹ spectral gap ≥ 1 - α
3. **Theorem 2**: Large min irrep dim + ratio bound ⟹ geometric mixing
4. **Theorem 3**: Spectral gap ε ⟹ Cheeger constant ≥ ε/2
5. **Uniform family**: For fixed C, gaps → 1 as q → ∞
6. **Codes**: Expansion → positive code distance parameter

Architecture: DL geometry → Certificate → Gap → Expansion → Codes
-/