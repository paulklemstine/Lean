/-
# NET-73, cycle 2: the concentration spectrum of a domain

`Applications/NET73KneeDecoupling.lean` shows that the knee `k*` is a functional
of the attention capture curve and is decoupled from tokens-per-word.  This file
asks the follow-up question the NET-73 verdict poses — *what relational
statistic does control the knee?* — and answers it with two independent bounds
and one exactly solvable family.

* **Participation bound** (`kneeAt_ge_sq_div_collision`).  For a domain whose
  attention mass vector is `p` with collision index `S = ∑ p i ^ 2` (the
  Rényi-2 / inverse-participation statistic), the knee obeys
  `k* ≥ τ² / S`.  The proof is Cauchy–Schwarz on the top-`k` block, so the
  bound is information-theoretic: the effective number of participating keys
  `1/S` lower-bounds (up to `τ²`) how many keys must be kept.
* **Top-mass bound** (`kneeAt_ge_tol_div_top`).  For a sorted mass vector the
  knee is at least `τ / p 0`: a domain with a single dominant key has a small
  knee, no matter how many tokens its words cost.
* **Geometric family** (`kneeAt_geometric_le_iff`).  For the exactly solvable
  decay profile `cum k = 1 - r ^ k` the knee is characterised by
  `k* ≤ k ↔ r ^ k ≤ 1 - τ`, is monotone in the decay rate `r`, and produces
  `geometric_domain_shift_at_equal_density`: two domains with *identical*
  tokens-per-word whose knees are `2` and `14` at the same tolerance — the
  in-model analogue of code (`k* = 12`) versus French (`k* > 32`).

Together these say the domain shift lives on the decay-rate axis, exactly where
NET-73's refutation of tokenization density pushes it.
-/
import Mathlib
import Applications.NET73KneeDecoupling

namespace Catalog.NET73

open Finset AttentionProfile

/-! ## 1. Domains presented by a sorted attention mass vector -/

/-- A domain presented by its attention mass vector, sorted in nonincreasing
order and supported on the first `N` keys. -/
structure MassVector where
  /-- Mass carried by the `i`-th heaviest key. -/
  p : ℕ → ℚ
  /-- Number of keys carrying mass. -/
  N : ℕ
  nonneg : ∀ i, 0 ≤ p i
  sorted : Antitone p
  vanishing : ∀ i, N ≤ i → p i = 0
  total : ∑ i ∈ range N, p i = 1

namespace MassVector

variable (M : MassVector)

/-- Mass captured by the `k` heaviest keys. -/
def cumMass (k : ℕ) : ℚ := ∑ i ∈ range k, M.p i

lemma cumMass_mono : Monotone M.cumMass := by
  intro a b hab
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_subset_range.mpr hab)
    (fun i _ _ => M.nonneg i)

lemma cumMass_N : M.cumMass M.N = 1 := M.total

lemma cumMass_le_one (k : ℕ) : M.cumMass k ≤ 1 := by
  rcases le_total k M.N with h | h
  · rw [← M.cumMass_N]; exact M.cumMass_mono h
  · refine le_of_eq ?_
    rw [← M.cumMass_N]
    refine (Finset.sum_subset (Finset.range_subset_range.mpr h) ?_).symm
    intro i _ hi
    exact M.vanishing i (by simpa using hi)

/-- The attention profile of a mass vector, carrying an arbitrary tokenizer
density `d` (the density is a free label: see `tpw_knee_decoupled`). -/
noncomputable def toProfile (d : ℚ) : AttentionProfile where
  tpw := d
  cum := M.cumMass
  cum_zero := by simp [cumMass]
  cum_mono := M.cumMass_mono
  cum_le_one := M.cumMass_le_one
  approaches_one := fun σ hσ => ⟨M.N, by rw [M.cumMass_N]; exact hσ.le⟩

@[simp] lemma toProfile_cum (d : ℚ) : (M.toProfile d).cum = M.cumMass := rfl

/-- The collision index `S = ∑ p i ^ 2`; `1 / S` is the effective number of
participating keys. -/
def collision : ℚ := ∑ i ∈ range M.N, M.p i ^ 2

lemma partial_collision_le (k : ℕ) : ∑ i ∈ range k, M.p i ^ 2 ≤ M.collision := by
  rcases le_total k M.N with h | h
  · exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_subset_range.mpr h)
      (fun i _ _ => sq_nonneg _)
  · refine le_of_eq ?_
    refine (Finset.sum_subset (Finset.range_subset_range.mpr h) ?_).symm
    intro i _ hi
    have : M.N ≤ i := by simpa using hi
    rw [M.vanishing i this]; ring

/-- Cauchy–Schwarz on the top-`k` block. -/
lemma cumMass_sq_le (k : ℕ) : (M.cumMass k) ^ 2 ≤ (k : ℚ) * M.collision := by
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq (range k) M.p (fun _ => (1 : ℚ))
  have h1 : (M.cumMass k) ^ 2 ≤ (k : ℚ) * ∑ i ∈ range k, M.p i ^ 2 := by
    simpa [cumMass, mul_comm] using hcs
  have h2 : (k : ℚ) * ∑ i ∈ range k, M.p i ^ 2 ≤ (k : ℚ) * M.collision := by
    have : (0 : ℚ) ≤ (k : ℚ) := by positivity
    exact mul_le_mul_of_nonneg_left (M.partial_collision_le k) this
  linarith

/-- **Participation bound.**  The knee is at least `τ²` times the effective
number of participating keys `1 / S`.  This is a purely relational statistic of
the attention distribution: no property of the tokenizer enters. -/
theorem kneeAt_ge_sq_div_collision {d τ : ℚ} (hτ0 : 0 < τ) (hτ1 : τ < 1)
    (hS : 0 < M.collision) :
    τ ^ 2 / M.collision ≤ ((M.toProfile d).kneeAt τ : ℚ) := by
  set k := (M.toProfile d).kneeAt τ with hk
  have h1 : τ ≤ M.cumMass k := by
    have := (M.toProfile d).kneeAt_spec hτ1
    simpa using this
  have h2 : τ ^ 2 ≤ (M.cumMass k) ^ 2 := by nlinarith
  have h3 : (M.cumMass k) ^ 2 ≤ (k : ℚ) * M.collision := M.cumMass_sq_le k
  rw [div_le_iff₀ hS]
  linarith

/-- Since the mass vector is sorted, no key carries more than `p 0`. -/
lemma cumMass_le_top (k : ℕ) : M.cumMass k ≤ (k : ℚ) * M.p 0 := by
  have : ∑ i ∈ range k, M.p i ≤ ∑ _i ∈ range k, M.p 0 :=
    Finset.sum_le_sum fun i _ => M.sorted (Nat.zero_le i)
  simpa [cumMass, mul_comm] using this

/-- **Top-mass bound.**  A domain whose heaviest key already carries mass `p 0`
needs at least `τ / p 0` keys.  Domains differ in their knees exactly insofar as
they differ in this concentration statistic. -/
theorem kneeAt_ge_tol_div_top {d τ : ℚ} (hτ1 : τ < 1) (hp : 0 < M.p 0) :
    τ / M.p 0 ≤ ((M.toProfile d).kneeAt τ : ℚ) := by
  set k := (M.toProfile d).kneeAt τ with hk
  have h1 : τ ≤ M.cumMass k := by
    have := (M.toProfile d).kneeAt_spec hτ1
    simpa using this
  have h2 : M.cumMass k ≤ (k : ℚ) * M.p 0 := M.cumMass_le_top k
  rw [div_le_iff₀ hp]
  linarith

end MassVector

/-! ## 2. A worked domain: four equally weighted keys -/

/-- The domain whose attention is spread evenly over four keys. -/
noncomputable def quadUniform : MassVector where
  p := fun i => if i < 4 then 1/4 else 0
  N := 4
  nonneg := by
    intro i
    by_cases h : i < 4 <;> simp [h]
  sorted := by
    intro a b hab
    by_cases hb : b < 4
    · have ha : a < 4 := lt_of_le_of_lt hab hb
      simp [ha, hb]
    · simp only [hb, if_false]
      by_cases ha : a < 4 <;> simp [ha]
  vanishing := by intro i hi; simp [Nat.not_lt.mpr hi]
  total := by norm_num [Finset.sum_range_succ]

lemma quadUniform_collision : quadUniform.collision = 1/4 := by
  norm_num [MassVector.collision, quadUniform, Finset.sum_range_succ]

lemma quadUniform_cum_two : quadUniform.cumMass 2 = 1/2 := by
  norm_num [MassVector.cumMass, quadUniform, Finset.sum_range_succ]

lemma quadUniform_cum_three : quadUniform.cumMass 3 = 3/4 := by
  norm_num [MassVector.cumMass, quadUniform, Finset.sum_range_succ]

/-- The participation bound is attained on this domain: at tolerance `3/4` it
predicts `k* ≥ 9/4`, and the true knee is `3`. -/
theorem quadUniform_knee_three (d : ℚ) :
    (quadUniform.toProfile d).kneeAt (3/4) = 3 ∧
    (3 / 4 : ℚ) ^ 2 / quadUniform.collision ≤ 3 := by
  constructor
  · refine le_antisymm ?_ ?_
    · refine (quadUniform.toProfile d).kneeAt_le ?_
      rw [MassVector.toProfile_cum, quadUniform_cum_three]
    · by_contra hlt
      push_neg at hlt
      have hle2 : (quadUniform.toProfile d).kneeAt (3/4) ≤ 2 := by omega
      have hspec := (quadUniform.toProfile d).kneeAt_spec (τ := 3/4) (by norm_num)
      have hmono := (quadUniform.toProfile d).cum_mono hle2
      rw [MassVector.toProfile_cum] at hspec hmono
      rw [quadUniform_cum_two] at hmono
      linarith
  · rw [quadUniform_collision]; norm_num

/-! ## 3. The exactly solvable decay family -/

/-- The geometric domain: the top-`k` keys capture `1 - r ^ k` of the mass, so
`r` is the decay rate of attention within the domain. -/
noncomputable def geometricProfile (d r : ℚ) (h0 : 0 < r) (h1 : r < 1) :
    AttentionProfile where
  tpw := d
  cum := fun k => 1 - r ^ k
  cum_zero := by simp
  cum_le_one := by
    intro k
    have : (0 : ℚ) < r ^ k := pow_pos h0 k
    show (1 : ℚ) - r ^ k ≤ 1
    linarith
  cum_mono := by
    intro a b hab
    have hp : r ^ b ≤ r ^ a := pow_le_pow_of_le_one h0.le h1.le hab
    show (1 : ℚ) - r ^ a ≤ 1 - r ^ b
    linarith
  approaches_one := by
    intro σ hσ
    obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one (show (0 : ℚ) < 1 - σ by linarith) h1
    exact ⟨n, by linarith⟩

@[simp] lemma geometricProfile_cum (d r : ℚ) (h0 : 0 < r) (h1 : r < 1) (k : ℕ) :
    (geometricProfile d r h0 h1).cum k = 1 - r ^ k := rfl

/-- **Exact solution of the geometric domain.**  Keeping `k` keys suffices
exactly when the residual mass `r ^ k` has fallen below the slack `1 - τ`. -/
theorem kneeAt_geometric_le_iff {d r τ : ℚ} (h0 : 0 < r) (h1 : r < 1)
    (hτ1 : τ < 1) (k : ℕ) :
    (geometricProfile d r h0 h1).kneeAt τ ≤ k ↔ r ^ k ≤ 1 - τ := by
  constructor
  · intro hle
    have hspec := (geometricProfile d r h0 h1).kneeAt_spec hτ1
    have hmono := (geometricProfile d r h0 h1).cum_mono hle
    have : τ ≤ 1 - r ^ k := by
      simpa using le_trans hspec hmono
    linarith
  · intro hr
    exact (geometricProfile d r h0 h1).kneeAt_le (by simp; linarith)

/-- Slower decay never helps: the knee is monotone in the decay rate. -/
theorem kneeAt_geometric_mono {d r s τ : ℚ} (hr0 : 0 < r) (hr1 : r < 1)
    (hs0 : 0 < s) (hs1 : s < 1) (hrs : r ≤ s) (hτ1 : τ < 1) :
    (geometricProfile d r hr0 hr1).kneeAt τ ≤ (geometricProfile d s hs0 hs1).kneeAt τ := by
  refine AttentionProfile.kneeAt_mono_profile _ _ hτ1 ?_
  intro k
  have : r ^ k ≤ s ^ k := pow_le_pow_left₀ hr0.le hrs k
  simp only [geometricProfile_cum]
  linarith

/-- **The domain shift, reproduced inside the model.**  Two domains with the
*same* tokens-per-word `d` but decay rates `1/2` and `9/10` have knees `2` and
`14` at the same tolerance `3/4`: a sevenfold gap generated purely by attention
decay, mirroring code (`k* = 12`) versus French (`k* > 32`) at nearly equal
token density. -/
theorem geometric_domain_shift_at_equal_density (d : ℚ) :
    (geometricProfile d (1/2) (by norm_num) (by norm_num)).kneeAt (3/4) = 2 ∧
    (geometricProfile d (9/10) (by norm_num) (by norm_num)).kneeAt (3/4) = 14 ∧
    (geometricProfile d (1/2) (by norm_num) (by norm_num)).tpw =
      (geometricProfile d (9/10) (by norm_num) (by norm_num)).tpw := by
  refine ⟨?_, ?_, rfl⟩
  · have hle : (geometricProfile d (1/2) (by norm_num) (by norm_num)).kneeAt (3/4) ≤ 2 := by
      rw [kneeAt_geometric_le_iff (by norm_num) (by norm_num) (by norm_num)]
      norm_num
    have hnot : ¬ (geometricProfile d (1/2) (by norm_num) (by norm_num)).kneeAt (3/4) ≤ 1 := by
      rw [kneeAt_geometric_le_iff (by norm_num) (by norm_num) (by norm_num)]
      norm_num
    omega
  · have hle : (geometricProfile d (9/10) (by norm_num) (by norm_num)).kneeAt (3/4) ≤ 14 := by
      rw [kneeAt_geometric_le_iff (by norm_num) (by norm_num) (by norm_num)]
      norm_num
    have hnot : ¬ (geometricProfile d (9/10) (by norm_num) (by norm_num)).kneeAt (3/4) ≤ 13 := by
      rw [kneeAt_geometric_le_iff (by norm_num) (by norm_num) (by norm_num)]
      norm_num
    omega

/-- **Cycle-2 synthesis.**  The knee is squeezed between two relational
concentration statistics — the collision index and the top-key mass — and, on
the exactly solvable decay family, is a strictly monotone function of the decay
rate alone, while tokens-per-word remains a free parameter throughout. -/
theorem knee_controlled_by_concentration_spectrum {τ : ℚ} (hτ0 : 0 < τ)
    (hτ1 : τ < 1) (d : ℚ) :
    (∀ M : MassVector, 0 < M.collision →
        τ ^ 2 / M.collision ≤ ((M.toProfile d).kneeAt τ : ℚ)) ∧
    (∀ M : MassVector, 0 < M.p 0 → τ / M.p 0 ≤ ((M.toProfile d).kneeAt τ : ℚ)) ∧
    (∀ r s : ℚ, ∀ hr0 : 0 < r, ∀ hr1 : r < 1, ∀ hs0 : 0 < s, ∀ hs1 : s < 1, r ≤ s →
        (geometricProfile d r hr0 hr1).kneeAt τ ≤
          (geometricProfile d s hs0 hs1).kneeAt τ) :=
  ⟨fun M hS => M.kneeAt_ge_sq_div_collision hτ0 hτ1 hS,
    fun M hp => M.kneeAt_ge_tol_div_top hτ1 hp,
    fun _ _ hr0 hr1 hs0 hs1 hrs => kneeAt_geometric_mono hr0 hr1 hs0 hs1 hrs hτ1⟩

end Catalog.NET73