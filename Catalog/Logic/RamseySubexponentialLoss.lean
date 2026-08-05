import Mathlib
import Combinatorics.RamseyExponentialBounds

/-!
# Subexponentiality is exactly the closure threshold for multiplicative losses

This file settles conjecture **FD1** of the research thread on exponential bounds
for diagonal Ramsey numbers.

The catalog file `Combinatorics/RamseyExponentialBounds.lean` provides the two
equivalent predicates `RamseyBounds.HasSubFourUpperBound` (an eventual bound
`r k ≤ (4-ε)^k` with a fixed `ε > 0`) and `RamseyBounds.HasProportionalSaving`
(an eventual bound `r k ≤ (4q)^k` with a fixed `q ∈ (0,1)`), together with the
fact that a *polynomial* loss factor can always be absorbed into the saving.

Here we determine **exactly** which loss factors `L : ℕ → ℝ` can be absorbed.
Call `L` *absorbable* (`RamseyBounds.AbsorbableLoss`) when, for **every**
sequence `r : ℕ → ℕ`, an eventual estimate of the shape `r k ≤ L k · (4q)^k`
with a fixed `q ∈ (0,1)` already forces `HasSubFourUpperBound r`.

The main theorem `RamseyBounds.absorbableLoss_iff_subexponentialLoss` states, for
nonnegative `L`,

  `AbsorbableLoss L ↔ SubexponentialLoss L`,

where `SubexponentialLoss L` means `∀ δ > 0, L k ≤ exp (δ k)` eventually.

The forward (necessity) direction is proved by an explicit counterexample: if `L`
exceeds `exp (δ k)` along an infinite set of indices `k`, the sequence which
equals `4^k` on that set and `0` elsewhere satisfies the hypothesis for a
suitable `q < 1` but has no sub-four bound whatsoever.
-/

namespace RamseyBounds

open Filter

/-- A nonnegative loss factor is *subexponential* if it is eventually dominated
by `exp (δ k)` for every positive `δ`. -/
def SubexponentialLoss (L : ℕ → ℝ) : Prop :=
  ∀ δ : ℝ, 0 < δ → ∀ᶠ k : ℕ in atTop, L k ≤ Real.exp (δ * k)

/-- A loss factor `L` is *absorbable* if, for every sequence `r`, an eventual
bound `r k ≤ L k · (4q)^k` with some fixed proportional saving `q ∈ (0,1)`
already yields a genuine sub-four upper bound for `r`. -/
def AbsorbableLoss (L : ℕ → ℝ) : Prop :=
  ∀ r : ℕ → ℕ,
    (∃ q : ℝ, 0 < q ∧ q < 1 ∧ ∃ k₀ : ℕ, ∀ k ≥ k₀, (r k : ℝ) ≤ L k * (4 * q) ^ k) →
    HasSubFourUpperBound r

/-! ### Sufficiency: subexponential losses are absorbable -/

/-- **Sufficiency.**  Every subexponential loss is absorbed by an arbitrarily
small enlargement of the proportional saving. -/
theorem absorbableLoss_of_subexponentialLoss {L : ℕ → ℝ}
    (hL : SubexponentialLoss L) : AbsorbableLoss L := by
  intro r ⟨q, hq_pos, hq_lt, k₀, hk₀⟩
  -- enlarge the saving from `q` to `q' = (q+1)/2 < 1`
  set q' : ℝ := (q + 1) / 2 with hq'def
  have hq'_pos : 0 < q' := by simp only [hq'def]; linarith
  have hq'_lt : q' < 1 := by simp only [hq'def]; linarith
  have hqq' : q < q' := by simp only [hq'def]; linarith
  -- the corresponding exponential slack
  set δ : ℝ := Real.log (q' / q) with hδdef
  have hratio : 1 < q' / q := (one_lt_div hq_pos).mpr hqq'
  have hδ_pos : 0 < δ := Real.log_pos hratio
  have hexp : Real.exp δ = q' / q := Real.exp_log (by positivity)
  have hev := hL δ hδ_pos
  rw [eventually_atTop] at hev
  obtain ⟨k₁, hk₁⟩ := hev
  refine hasSubFourUpperBound_of_proportionalSaving ⟨q', hq'_pos, hq'_lt,
    max k₀ k₁, ?_⟩
  intro k hk
  have hk0 : k₀ ≤ k := le_trans (le_max_left _ _) hk
  have hk1 : k₁ ≤ k := le_trans (le_max_right _ _) hk
  have hLk : L k ≤ (q' / q) ^ k := by
    have h := hk₁ k hk1
    have hrw : Real.exp (δ * (k : ℝ)) = (q' / q) ^ k := by
      rw [mul_comm, Real.exp_nat_mul, hexp]
    rwa [hrw] at h
  have hpow_nonneg : (0 : ℝ) ≤ (4 * q) ^ k := by positivity
  calc (r k : ℝ) ≤ L k * (4 * q) ^ k := hk₀ k hk0
    _ ≤ (q' / q) ^ k * (4 * q) ^ k := by gcongr
    _ = (4 * q') ^ k := by
        rw [← mul_pow]
        congr 1
        field_simp

/-! ### Necessity: a loss with exponential growth along a sparse set fails -/

open Classical in
/-- **Necessity.**  If a nonnegative loss factor is *not* subexponential, then it
is not absorbable: there is a sequence `r` obeying `r k ≤ L k · (4q)^k` for a
fixed `q < 1` which nevertheless has no sub-four upper bound.  The witness is
`r k = 4^k` on the sparse set where `L k > exp (δ k)` and `r k = 0` elsewhere. -/
theorem not_absorbableLoss_of_not_subexponentialLoss {L : ℕ → ℝ}
    (hL0 : ∀ k, 0 ≤ L k) (hL : ¬ SubexponentialLoss L) : ¬ AbsorbableLoss L := by
  -- extract the witnessing rate `δ` and the sparse set of bad indices
  simp only [SubexponentialLoss, not_forall] at hL
  obtain ⟨δ, hδ_pos, hbad⟩ := hL
  rw [not_eventually] at hbad
  simp only [not_le] at hbad
  -- the witness sequence
  set r : ℕ → ℕ := fun k => if Real.exp (δ * k) < L k then 4 ^ k else 0 with hrdef
  -- the saving used in the hypothesis
  set q : ℝ := (Real.exp (-δ) + 1) / 2 with hqdef
  have hexp_pos : 0 < Real.exp (-δ) := Real.exp_pos _
  have hexp_lt : Real.exp (-δ) < 1 := by
    rw [Real.exp_lt_one_iff]; linarith
  have hq_pos : 0 < q := by simp only [hqdef]; linarith
  have hq_lt : q < 1 := by simp only [hqdef]; linarith
  have hq_gt : Real.exp (-δ) < q := by simp only [hqdef]; linarith
  have hqexp : 1 < q * Real.exp δ := by
    have h1 : Real.exp (-δ) * Real.exp δ = 1 := by
      rw [← Real.exp_add]; simp
    have hpos : 0 < Real.exp δ := Real.exp_pos _
    calc (1 : ℝ) = Real.exp (-δ) * Real.exp δ := h1.symm
      _ < q * Real.exp δ := by exact mul_lt_mul_of_pos_right hq_gt hpos
  intro habs
  have hsub := habs r ⟨q, hq_pos, hq_lt, 0, ?_⟩
  · -- but `r` has no sub-four upper bound
    obtain ⟨ε, hε_pos, hε_lt, k₀, hk₀⟩ := hsub
    obtain ⟨k, hk_ge, hk_bad⟩ := (frequently_atTop.mp hbad) (max k₀ 1)
    have hk0 : k₀ ≤ k := le_trans (le_max_left _ _) hk_ge
    have hk1 : 1 ≤ k := le_trans (le_max_right _ _) hk_ge
    have hrk : (r k : ℝ) = 4 ^ k := by
      simp only [hrdef, if_pos hk_bad, Nat.cast_pow]
      norm_num
    have hlt : ((4 : ℝ) - ε) ^ k < 4 ^ k := by
      exact pow_lt_pow_left₀ (by linarith) (by linarith) (by omega)
    have := hk₀ k hk0
    rw [hrk] at this
    linarith
  · -- the hypothesis of absorbability holds for this `q`
    intro k _
    by_cases hk : Real.exp (δ * k) < L k
    · have hrk : (r k : ℝ) = 4 ^ k := by
        simp only [hrdef, if_pos hk, Nat.cast_pow]
        norm_num
      rw [hrk]
      have hexpk : Real.exp (δ * (k : ℝ)) = (Real.exp δ) ^ k := by
        rw [mul_comm, Real.exp_nat_mul]
      have h1 : (1 : ℝ) ≤ (q * Real.exp δ) ^ k := one_le_pow₀ (le_of_lt hqexp)
      have h4 : (0 : ℝ) < 4 ^ k := by positivity
      have key : (4 : ℝ) ^ k ≤ (Real.exp δ) ^ k * (4 * q) ^ k := by
        have : (Real.exp δ) ^ k * (4 * q) ^ k = 4 ^ k * (q * Real.exp δ) ^ k := by
          rw [mul_pow, mul_pow]; ring
        rw [this]
        nlinarith
      refine le_trans key ?_
      have hle : (Real.exp δ) ^ k ≤ L k := by
        rw [← hexpk]; exact le_of_lt hk
      have : (0 : ℝ) ≤ (4 * q) ^ k := by positivity
      exact mul_le_mul_of_nonneg_right hle this
    · have hrk : (r k : ℝ) = 0 := by
        simp only [hrdef, if_neg hk]
        norm_num
      rw [hrk]
      have : (0 : ℝ) ≤ (4 * q) ^ k := by positivity
      exact mul_nonneg (hL0 k) this

/-- **FD1.**  For a nonnegative loss factor, absorbability into a proportional
saving is *equivalent* to subexponentiality: the uniform subexponential bound
used in the catalog is not merely sufficient but necessary. -/
theorem absorbableLoss_iff_subexponentialLoss {L : ℕ → ℝ} (hL0 : ∀ k, 0 ≤ L k) :
    AbsorbableLoss L ↔ SubexponentialLoss L := by
  constructor
  · intro h
    by_contra hcon
    exact not_absorbableLoss_of_not_subexponentialLoss hL0 hcon h
  · exact absorbableLoss_of_subexponentialLoss

/-! ### The boundary case `L k = 2^k` -/

/-- The exponential loss `L k = 2^k` is not subexponential. -/
theorem not_subexponentialLoss_two_pow :
    ¬ SubexponentialLoss (fun k => (2 : ℝ) ^ k) := by
  intro h
  have hlog : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  obtain ⟨k₀, hk₀⟩ := eventually_atTop.mp (h (Real.log 2 / 2) (by linarith))
  have hk : (2 : ℝ) ^ (k₀ + 1) ≤ Real.exp (Real.log 2 / 2 * ((k₀ + 1 : ℕ) : ℝ)) :=
    hk₀ (k₀ + 1) (by omega)
  have h2 : (2 : ℝ) ^ (k₀ + 1) = Real.exp (Real.log 2 * ((k₀ + 1 : ℕ) : ℝ)) := by
    rw [mul_comm, Real.exp_nat_mul, Real.exp_log (by norm_num)]
  rw [h2, Real.exp_le_exp] at hk
  have hone : (1 : ℝ) ≤ ((k₀ + 1 : ℕ) : ℝ) := by
    exact_mod_cast Nat.succ_le_succ (Nat.zero_le k₀)
  nlinarith

/-- Consequently `L k = 2^k` is not absorbable: this recovers the catalog's
non-absorbability example as a special case of the characterization. -/
theorem not_absorbableLoss_two_pow :
    ¬ AbsorbableLoss (fun k => (2 : ℝ) ^ k) :=
  fun h => not_subexponentialLoss_two_pow
    ((absorbableLoss_iff_subexponentialLoss (fun k => by positivity)).mp h)

end RamseyBounds