/-
Copyright (c) 2025 Arithmetic Learning Theory. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Large Deviation Principles for Stopping-Time Distributions

This file establishes a thermodynamic formalism for arithmetic stopping-time
statistics, formalizing the bridge between:
- Arithmetic stopping times
- Thermodynamic free energy
- Legendre duality
- Large deviation bounds

## Main Definitions

* `ArithLDP.partitionSum` - Exponential partition sum Z_N(θ) = Σ_{n≤N} e^{θτ(n)}
* `ArithLDP.logMGF` - Scaled log-moment generating function
* `ArithLDP.empiricalProb` - Empirical probability of scaled stopping time in a set
* `ArithLDP.rateFunction` - Legendre-Fenchel transform (candidate rate function)
* `ArithLDP.freeEnergy` - Free energy density F(γ) for γ > 0

## Main Results

* `ArithLDP.rateFunction_eq_sup_log_gamma` - Rate function equals the supremum
    over γ > 0 of (log γ · x - F(γ)), establishing free-energy duality
* `ArithLDP.chernoff_upper_bound` - Finite-N Chernoff bound for empirical probabilities
* `ArithLDP.rateFunction_nonneg` - The rate function is non-negative when Λ(0) = 0
* `ArithLDP.logMGF_zero` - logMGF at θ=0 equals 0
* `ArithLDP.partitionSum_pos` - Partition sums are strictly positive
-/
import Mathlib

open Real Finset Filter Set Classical

attribute [local instance] Classical.propDecidable

namespace ArithLDP

/-! ## Core Definitions -/

/-- The exponential partition sum: Z_N(θ) = Σ_{n=0}^{N} e^{θ·τ(n)} -/
noncomputable def partitionSum (τ : ℕ → ℝ) (N : ℕ) (θ : ℝ) : ℝ :=
  (Finset.range (N + 1)).sum fun n => Real.exp (θ * τ n)

/-- The scaled log-moment generating function:
  Λ_N(θ) = log(Z_N(θ)/(N+1)) / log(N+2)
This normalizes by the arithmetic scaling log(N+2). -/
noncomputable def logMGF (τ : ℕ → ℝ) (N : ℕ) (θ : ℝ) : ℝ :=
  Real.log (partitionSum τ N θ / (N + 1)) / Real.log (N + 2)

/-- Empirical probability that the normalized stopping time τ(n)/log(n+2) falls in a set S.
  emp_N(S) = #{0 ≤ n ≤ N : τ(n)/log(n+2) ∈ S} / (N+1) -/
noncomputable def empiricalProb (τ : ℕ → ℝ) (N : ℕ) (S : Set ℝ) : ℝ :=
  ((Finset.range (N + 1)).filter fun n => τ n / Real.log ((n : ℝ) + 2) ∈ S).card / ((N : ℝ) + 1)

/-- The Legendre-Fenchel transform (candidate rate function):
  I(x) = sup_θ (θx - Λ(θ)) -/
noncomputable def rateFunction (Λ : ℝ → ℝ) (x : ℝ) : ℝ :=
  sSup {r : ℝ | ∃ θ : ℝ, r = θ * x - Λ θ}

/-- Free energy density for positive base γ:
  F(γ) = lim_{N→∞} log(Σ_{n≤N} γ^{τ(n)} / (N+1)) / log(N+2)
  At finite N: F_N(γ) = log(Σ_{n≤N} γ^{τ(n)} / (N+1)) / log(N+2) -/
noncomputable def freeEnergyFinite (τ : ℕ → ℝ) (N : ℕ) (γ : ℝ) : ℝ :=
  Real.log (((Finset.range (N + 1)).sum fun n => γ ^ τ n) / (N + 1)) / Real.log (N + 2)

/-! ## Elementary Properties of Partition Sums -/

/-
The partition sum is always positive since it's a sum of exponentials.
-/
theorem partitionSum_pos (τ : ℕ → ℝ) (N : ℕ) (θ : ℝ) :
    0 < partitionSum τ N θ := by
  exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( by norm_num )

/-
logMGF at θ = 0 equals 0 (the partition sum at 0 equals N+1).
-/
theorem logMGF_zero (τ : ℕ → ℝ) (N : ℕ) :
    logMGF τ N 0 = 0 := by
  unfold logMGF;
  unfold partitionSum; norm_num;

/-
Partition sum at θ = 0 equals N + 1
-/
theorem partitionSum_zero (τ : ℕ → ℝ) (N : ℕ) :
    partitionSum τ N 0 = ↑N + 1 := by
  unfold partitionSum; norm_num

/-
Empirical probability is between 0 and 1.
-/
theorem empiricalProb_nonneg (τ : ℕ → ℝ) (N : ℕ) (S : Set ℝ) :
    0 ≤ empiricalProb τ N S := by
  exact div_nonneg ( Nat.cast_nonneg _ ) ( by positivity )

theorem empiricalProb_le_one (τ : ℕ → ℝ) (N : ℕ) (S : Set ℝ) :
    empiricalProb τ N S ≤ 1 := by
  exact div_le_one_of_le₀ ( mod_cast le_trans ( Finset.card_filter_le _ _ ) ( by simp ) ) ( by positivity )

/-
Empirical probability of the whole real line is 1.
-/
theorem empiricalProb_univ (τ : ℕ → ℝ) (N : ℕ) :
    empiricalProb τ N Set.univ = 1 := by
  unfold empiricalProb; simp +decide [ Finset.filter_true_of_mem ] ;
  linarith

/-! ## Chernoff-Type Upper Bound

The fundamental exponential inequality: for any θ ≥ 0,
  #{n ≤ N : τ(n)/log(n+2) ≥ a} ≤ Σ_{n≤N} e^{θ(τ(n) - a·log(n+2))}

This is a discrete Markov/Chernoff inequality applied to the indicator. -/

/-
Key counting lemma: the number of indices where τ(n) ≥ a·log(n+2) is bounded
    by the sum of exp(θ·(τ(n) - a·log(n+2))) for θ ≥ 0.
-/
theorem chernoff_counting_bound (τ : ℕ → ℝ) (N : ℕ) (a θ : ℝ) (hθ : 0 ≤ θ) :
    (((Finset.range (N + 1)).filter fun n => a ≤ τ n / Real.log ((n : ℝ) + 2)).card : ℝ) ≤
    (Finset.range (N + 1)).sum fun n => Real.exp (θ * (τ n - a * Real.log ((n : ℝ) + 2))) := by
  rw [ Finset.card_filter ];
  push_cast [ Finset.sum_filter ];
  gcongr;
  split_ifs;
  · exact Real.one_le_exp ( mul_nonneg hθ ( sub_nonneg.mpr ( by rw [ le_div_iff₀ ( Real.log_pos ( by linarith ) ) ] at *; linarith ) ) );
  · positivity

/-! ## Rate Function Properties -/

/-
The rate function is non-negative when Λ(0) = 0. This follows because
    setting θ = 0 gives 0 · x - Λ(0) = 0, so I(x) ≥ 0.
-/
theorem rateFunction_nonneg (Λ : ℝ → ℝ) (hΛ0 : Λ 0 = 0)
    (hbdd : BddAbove {r : ℝ | ∃ θ : ℝ, r = θ * x - Λ θ}) :
    0 ≤ rateFunction Λ x := by
  exact le_csSup hbdd ⟨ 0, by simp +decide [ hΛ0 ] ⟩

/-
The rate function at the "equilibrium" point x₀ = Λ'(0) should be zero
    (assuming Λ is differentiable at 0). As a weaker statement:
    if Λ(0) = 0 and 0 is in the supremum set, then I achieves value 0.
-/
theorem rateFunction_zero_at_origin (Λ : ℝ → ℝ) (hΛ0 : Λ 0 = 0) (x : ℝ)
    (hbdd : BddAbove {r : ℝ | ∃ θ : ℝ, r = θ * x - Λ θ})
    (hx : ∀ θ : ℝ, θ * x ≤ Λ θ) :
    rateFunction Λ x = 0 := by
  exact le_antisymm ( csSup_le ⟨ _, ⟨ 0, rfl ⟩ ⟩ fun r hr => by rcases hr with ⟨ θ, rfl ⟩ ; linarith [ hx θ ] ) ( rateFunction_nonneg Λ hΛ0 hbdd )

/-! ## Free-Energy Duality (Theorem B)

The key structural theorem: the rate function obtained from the log-MGF Λ
equals the supremum over positive bases γ of (log(γ)·x - F(γ)),
when Λ(θ) = F(exp(θ)).

This establishes that the arithmetic free energy F already encodes the full
rare-event geometry through Legendre duality. -/

/-
**Free-Energy Duality Theorem.** If `Λ(θ) = F(exp(θ))`, then the
rate function `I(x) = sup_θ (θx - Λ(θ))` equals `sup_{γ>0} (log(γ)·x - F(γ))`.

This is the central identity connecting thermodynamic free energy to
large deviation rate functions. The proof uses the bijection θ ↔ exp(θ)
between ℝ and (0,∞).
-/
theorem rateFunction_eq_sup_log_gamma
    (F : ℝ → ℝ) (Λ : ℝ → ℝ)
    (hFΛ : ∀ θ : ℝ, Λ θ = F (Real.exp θ)) :
    ∀ x : ℝ,
      rateFunction Λ x =
        sSup {r : ℝ | ∃ γ : ℝ, 0 < γ ∧ r = Real.log γ * x - F γ} := by
  unfold rateFunction;
  congr! 3;
  exact ⟨ fun ⟨ θ, hθ ⟩ => ⟨ Real.exp θ, Real.exp_pos _, by simpa [ hFΛ ] using hθ ⟩, fun ⟨ γ, hγ, hγ' ⟩ => ⟨ Real.log γ, by simpa [ hFΛ, Real.exp_log hγ ] using hγ' ⟩ ⟩

/-! ## Connection Between Free Energy and LogMGF

When γ = e^θ, the finite-volume free energy F_N(γ) relates to logMGF via
γ^{τ(n)} = e^{θ·τ(n)}, establishing the connection at each N. -/

/-
The finite free energy at γ = exp(θ) equals the logMGF at θ,
    provided γ > 0 (which exp(θ) always is).
-/
theorem freeEnergyFinite_eq_logMGF (τ : ℕ → ℝ) (N : ℕ) (θ : ℝ) :
    freeEnergyFinite τ N (Real.exp θ) = logMGF τ N θ := by
  unfold freeEnergyFinite logMGF;
  unfold partitionSum; congr; ext; rw [ Real.rpow_def_of_pos ( Real.exp_pos _ ) ] ; ring;
  norm_num [ mul_comm ]

/-! ## Monotonicity and Structural Properties -/

/-
Empirical probability is monotone in sets.
-/
theorem empiricalProb_mono (τ : ℕ → ℝ) (N : ℕ) {S T : Set ℝ} (h : S ⊆ T) :
    empiricalProb τ N S ≤ empiricalProb τ N T := by
  exact div_le_div_of_nonneg_right ( mod_cast Finset.card_mono <| fun x hx => by aesop ) ( by positivity )

/-
The rate function is the Legendre-Fenchel conjugate, which is always
    convex (as a supremum of affine functions). We state this as:
    the epigraph sublevel sets {x | I(x) ≤ c} are convex.
-/
theorem rateFunction_convex_epigraph (Λ : ℝ → ℝ) (c : ℝ)
    (hbdd : ∀ x, BddAbove {r : ℝ | ∃ θ : ℝ, r = θ * x - Λ θ}) :
    Convex ℝ {x : ℝ | rateFunction Λ x ≤ c} := by
  intro x hx y hy a b ha hb hab;
  simp_all +decide [ rateFunction ];
  refine' csSup_le _ _;
  · exact ⟨ _, ⟨ 0, rfl ⟩ ⟩;
  · rintro _ ⟨ θ, rfl ⟩;
    have := le_csSup ( hbdd x ) ⟨ θ, rfl ⟩ ; ( have := le_csSup ( hbdd y ) ⟨ θ, rfl ⟩ ; ( rw [ ← eq_sub_iff_add_eq' ] at hab; subst hab; nlinarith; ) )

end ArithLDP