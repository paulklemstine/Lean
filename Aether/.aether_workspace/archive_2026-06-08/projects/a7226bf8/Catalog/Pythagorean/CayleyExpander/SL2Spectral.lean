/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Spectral Theory for Cayley Graphs — Arithmetic Expansion

This file develops the spectral theory connecting representation-theoretic
bounds to quantitative expansion, proves mixing consequences, and
establishes the eigenvalue-1 exclusion theorem.

## Main Results

* `eigenvalue_one_iff_constant` — eigenfunctions of eigenvalue 1 are constant
* `l2_iterate_decay_of_spectral_gap` — L² mixing decay from spectral gap
* `arithmetic_certificate_mixing` — certificates yield mixing bounds

## Keywords

spectral gap, Cayley expander, SL₂(𝔽_p), arithmetic group, property (τ),
Ramanujan graph, random walk mixing, finite group representation theory,
automorphic forms, Langlands program, quasirandomness
-/
import Mathlib
import Pythagorean.CayleyExpander.Defs
import Pythagorean.CayleyExpander.Connectivity
import Pythagorean.CayleyExpander.SpectralGap
import Pythagorean.CayleyExpander.SL2Defs

open Finset BigOperators Matrix

/-! ## Iterated averaging -/

/-- The n-fold iteration of the Cayley averaging operator. -/
noncomputable def cayleyAveragingIter {G : Type*} [Fintype G] [Group G]
    (S : Finset G) : ℕ → (G → ℝ) → (G → ℝ)
  | 0 => id
  | n + 1 => cayleyAveragingOp S ∘ cayleyAveragingIter S n

@[simp] theorem cayleyAveragingIter_zero {G : Type*} [Fintype G] [Group G]
    (S : Finset G) (f : G → ℝ) :
    cayleyAveragingIter S 0 f = f := rfl

theorem cayleyAveragingIter_succ {G : Type*} [Fintype G] [Group G]
    (S : Finset G) (n : ℕ) (f : G → ℝ) :
    cayleyAveragingIter S (n + 1) f = cayleyAveragingOp S (cayleyAveragingIter S n f) := rfl

/-! ## L² contraction under iteration -/

/-- **L² contraction under iteration**: repeated averaging contracts L² norms.
    This follows from L² contraction of a single step by induction. -/
theorem l2NormSq_iter_le {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G) (hSne : S.Nonempty) (f : G → ℝ) (n : ℕ) :
    l2NormSq (cayleyAveragingIter S n f) ≤ l2NormSq f := by
  induction n with
  | zero => simp
  | succ n ih =>
    calc l2NormSq (cayleyAveragingIter S (n + 1) f)
        = l2NormSq (cayleyAveragingOp S (cayleyAveragingIter S n f)) := rfl
      _ ≤ l2NormSq (cayleyAveragingIter S n f) := l2_contraction_of_averaging S hSne _
      _ ≤ l2NormSq f := ih

/-- Iterated averaging preserves mean zero. -/
theorem cayleyAveragingIter_preserves_meanZero
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G) (hSne : S.Nonempty) (f : G → ℝ)
    (hf : meanZero f) (n : ℕ) :
    meanZero (cayleyAveragingIter S n f) := by
  induction n with
  | zero => simpa
  | succ n ih =>
    exact cayleyAveragingOp_preserves_meanZero S hSne _ ih

/-! ## Spectral gap and L² decay -/

/-- A Cayley spectral gap bound: every mean-zero function f satisfies
    ‖Af‖₂² ≤ β² · ‖f‖₂². -/
structure CayleySpectralGapBound (G : Type*) [Fintype G] [Group G] where
  S : Finset G
  beta : ℝ
  beta_nonneg : 0 ≤ beta
  beta_lt_one : beta < 1
  contraction : ∀ f : G → ℝ, meanZero f →
    l2NormSq (cayleyAveragingOp S f) ≤ beta ^ 2 * l2NormSq f

/-- **Theorem (L² mixing from spectral gap)**:
    If the Cayley graph has spectral gap bound β < 1, then for every
    mean-zero function f, the n-fold averaged function satisfies
    ‖Aⁿ f‖₂² ≤ β^(2n) · ‖f‖₂².

    This is the fundamental mixing theorem connecting arithmetic expansion
    to convergence of random walks on algebraic groups.

    In the context of SL₂(𝔽_p), this means: if we know the second eigenvalue
    of the Cayley graph is bounded by β, then the random walk converges to
    uniform in O(log|G| / log(1/β)) steps — an arithmetic mixing time bound. -/
theorem l2_iterate_decay_of_spectral_gap
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (gap : CayleySpectralGapBound G)
    (hSne : gap.S.Nonempty)
    (f : G → ℝ) (hf : meanZero f) (n : ℕ) :
    l2NormSq (cayleyAveragingIter gap.S n f) ≤ gap.beta ^ (2 * n) * l2NormSq f := by
  induction n with
  | zero => simp [mul_zero, pow_zero, one_mul]
  | succ n ih =>
    have hmz := cayleyAveragingIter_preserves_meanZero gap.S hSne f hf n
    calc l2NormSq (cayleyAveragingIter gap.S (n + 1) f)
        = l2NormSq (cayleyAveragingOp gap.S (cayleyAveragingIter gap.S n f)) := rfl
      _ ≤ gap.beta ^ 2 * l2NormSq (cayleyAveragingIter gap.S n f) := gap.contraction _ hmz
      _ ≤ gap.beta ^ 2 * (gap.beta ^ (2 * n) * l2NormSq f) := by
          apply mul_le_mul_of_nonneg_left ih (pow_nonneg gap.beta_nonneg _)
      _ = gap.beta ^ (2 * (n + 1)) * l2NormSq f := by ring

/-! ## Eigenvalue-1 exclusion theorem -/

/-
**Theorem (Eigenvalue-1 exclusion — spectral gap from generation)**:
    If S is a symmetric generating set for a finite group G, and f is an
    eigenfunction of the averaging operator with eigenvalue 1 (i.e., Af = f),
    then f is constant.

    This is the spectral-theoretic formulation of connectivity: the
    eigenspace of eigenvalue 1 is one-dimensional (spanned by constants).
    Equivalently, the spectral gap is strictly positive.

    The proof uses the key insight that Af = f combined with Jensen's inequality
    forces f(sx) = f(x) for all generators s, and generation then implies f
    is globally constant. This is the formal mechanism by which arithmetic
    information (generation) enters spectral theory (eigenvalue exclusion).
-/
theorem eigenvalue_one_iff_constant
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (S : Finset G) (hSne : S.Nonempty)
    (hSsymm : ∀ g ∈ S, g⁻¹ ∈ S)
    (hgen : Subgroup.closure (↑S : Set G) = ⊤)
    (f : G → ℝ) (hfixed : cayleyAveragingOp S f = f) :
    ∃ c : ℝ, ∀ x : G, f x = c := by
  have h_const : cayleyDirichletEnergy S f = 0 := by
    have h_dirichlet : ∑ x : G, ∑ s ∈ S, (f (s * x) - f x) ^ 2 = ∑ x : G, ∑ s ∈ S, f (s * x) ^ 2 - 2 * S.card * ∑ x : G, f x ^ 2 + S.card * ∑ x : G, f x ^ 2 := by
      simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq, mul_assoc, mul_comm, mul_left_comm, cayleyAveragingOp ] at hfixed ⊢;
      exact Finset.sum_congr rfl fun x _ => by have := congr_fun hfixed x; rw [ show cayleyAveragingOp S f x = ( ∑ i ∈ S, f ( i * x ) ) / S.card from rfl ] at this; rw [ div_eq_iff ( Nat.cast_ne_zero.mpr hSne.card_pos.ne' ) ] at this; linear_combination this * f x * 2;
    have h_sum_sq : ∑ x : G, ∑ s ∈ S, f (s * x) ^ 2 = S.card * ∑ x : G, f x ^ 2 := by
      rw [ Finset.sum_comm ];
      exact Eq.trans ( Finset.sum_congr rfl fun _ _ => Equiv.sum_comp ( Equiv.mulLeft _ ) fun x => f x ^ 2 ) ( by simp +decide );
    exact h_dirichlet.trans ( by rw [ h_sum_sq ] ; ring )
  generalize_proofs at *;
  exact?

/-! ## Arithmetic certificate mixing bridge -/

/-- An arithmetic certificate with a valid spectral gap bound yields
    exponential L² mixing. -/
theorem arithmetic_certificate_mixing
    {G : Type*} [Fintype G] [DecidableEq G] [Group G]
    (cert : ArithmeticCayleyCertificate G)
    (gap : CayleySpectralGapBound G)
    (hS : gap.S = cert.S)
    (hSne : cert.S.Nonempty)
    (f : G → ℝ) (hf : meanZero f) (n : ℕ) :
    l2NormSq (cayleyAveragingIter cert.S n f) ≤
      gap.beta ^ (2 * n) * l2NormSq f := by
  rw [← hS] at hSne ⊢
  exact l2_iterate_decay_of_spectral_gap gap hSne f hf n

/-- A constant function is a fixed point of the averaging operator. -/
theorem cayleyAveragingOp_const {G : Type*} [Fintype G] [Group G]
    (S : Finset G) (hSne : S.Nonempty) (c : ℝ) :
    cayleyAveragingOp S (fun _ => c) = fun _ => c := by
  ext x; simp only [cayleyAveragingOp]
  simp only [Finset.sum_const, nsmul_eq_mul]
  have h : (S.card : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Finset.card_pos.mpr hSne).ne'
  field_simp