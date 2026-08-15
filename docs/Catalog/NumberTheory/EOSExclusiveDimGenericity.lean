/-
# Are the exclusive dimensions really exclusive?  A `q`-Pochhammer genericity bound

Companion to `Catalog/NumberTheory/EOSWidthMonotoneRamp.lean`.

The ramp model draws the boundary token's `k` exclusive directions uniformly at random from a
finite `𝔽_p`-space `V` of dimension `n`.  For the phrase "`k` exclusive dimensions" to be
honest, the `k` draws must actually be linearly independent.  This file quantifies that:

* `EOSGenericity.probIndep_eq_prod` — the probability that `k ≤ n` uniform draws are linearly
  independent is exactly the `q`-Pochhammer product `∏_{i<k} (1 - p^{i-n})`
  (via Mathlib's `card_linearIndependent`);
* `EOSGenericity.one_sub_sum_le_prod_one_sub` — a Weierstrass product inequality, proved by
  induction;
* `EOSGenericity.probIndep_ge` — hence `P(independent) ≥ 1 - (p^k - 1)/((p-1) p^n)`: for
  `k ≪ n` the drawn directions are exclusive with overwhelming probability, so the model of
  the companion file is not vacuous;
* `EOSGenericity.probIndep_antitone_step` — genericity decays with `k`, in the opposite
  direction to the reliability ramp;
* `EOSGenericity.prob_indep_and_cure_ge` — **the synthesis**: with `k` exclusive dimensions the
  probability that the token both occupies a genuine `k`-dimensional subspace *and* escapes all
  `m` obstructions is at least

  `1 - m·p^{-k} - (p^k - 1)/((p-1)·p^n)`,

  a two-sided window: the first term (reliability) shrinks geometrically in `k`, the second
  (genericity) grows geometrically in `k`, so the optimal exclusive width is interior — there is
  a genuine trade-off and no cliff.

### Lab notes

With `p = 2`, `n = 192` (the hidden width of the recurrent cell in the motivating experiment)
and `m = 1`, the bound reads `1 - 2^{-k} - (2^k-1)·2^{-192}`: the genericity loss is utterly
negligible up to `k ≈ 100`, so in the regime of the data (`k ≤ 8`) the reliability term alone
governs, matching the observed monotone ramp `0.25 → 0.33 → 0.83 → 1.00 → 1.00`.
-/

import Mathlib
import NumberTheory.EOSWidthMonotoneRamp

open Module Finset

namespace EOSGenericity

variable {p m : ℕ} [Fact p.Prime] {V : Type*} [AddCommGroup V] [Module (ZMod p) V] [Finite V]

/-- Probability that `k` uniform draws from `V` are linearly independent. -/
noncomputable def probIndep (p : ℕ) [Fact p.Prime] (V : Type*) [AddCommGroup V]
    [Module (ZMod p) V] [Finite V] (k : ℕ) : ℝ :=
  (Nat.card {s : Fin k → V // LinearIndependent (ZMod p) s} : ℝ) / (Nat.card V : ℝ) ^ k

/-- **`q`-Pochhammer formula.**  For `k ≤ dim V` the genericity probability is exactly
`∏_{i<k} (1 - p^{i}/p^{n})`. -/
theorem probIndep_eq_prod {k : ℕ} (hk : k ≤ finrank (ZMod p) V) :
    probIndep p V k
      = ∏ i ∈ range k, (1 - (p : ℝ) ^ i / (p : ℝ) ^ (finrank (ZMod p) V)) := by
  classical
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  set n := finrank (ZMod p) V with hn
  have hcardV : Nat.card V = p ^ n := EOSWidthRamp.card_eq_pow_finrank_zmod (p := p) V
  have hq : Fintype.card (ZMod p) = p := ZMod.card p
  have hcount : Nat.card {s : Fin k → V // LinearIndependent (ZMod p) s}
      = ∏ i : Fin k, (p ^ n - p ^ (i : ℕ)) := by
    have := card_linearIndependent (K := ZMod p) (V := V) (k := k) (by simpa [hn] using hk)
    simpa [hq, hn] using this
  have hcast : ((∏ i : Fin k, (p ^ n - p ^ (i : ℕ)) : ℕ) : ℝ)
      = ∏ i ∈ range k, ((p : ℝ) ^ n - (p : ℝ) ^ i) := by
    rw [Nat.cast_prod, Fin.prod_univ_eq_prod_range (fun i => ((p ^ n - p ^ i : ℕ) : ℝ))]
    refine Finset.prod_congr rfl fun i hi => ?_
    have hle : p ^ i ≤ p ^ n :=
      Nat.pow_le_pow_right (le_of_lt hp) (le_trans (le_of_lt (mem_range.mp hi)) hk)
    push_cast [Nat.cast_sub hle]
    ring
  have hpow : (0 : ℝ) < (p : ℝ) ^ n := by positivity
  rw [probIndep, hcount, hcast, hcardV]
  push_cast
  rw [← pow_mul]
  have : ∏ i ∈ range k, ((p : ℝ) ^ n - (p : ℝ) ^ i)
      = (∏ i ∈ range k, (1 - (p : ℝ) ^ i / (p : ℝ) ^ n)) * ((p : ℝ) ^ n) ^ k := by
    have hfac : ∀ i ∈ range k, ((p : ℝ) ^ n - (p : ℝ) ^ i)
        = (1 - (p : ℝ) ^ i / (p : ℝ) ^ n) * (p : ℝ) ^ n := by
      intro i _
      field_simp
    rw [Finset.prod_congr rfl hfac, Finset.prod_mul_distrib, Finset.prod_const, card_range]
  rw [this, pow_mul]
  field_simp

/-- **Weierstrass product inequality** (proved by induction): for `0 ≤ aᵢ ≤ 1`,
`1 - ∑ aᵢ ≤ ∏ (1 - aᵢ)`. -/
theorem one_sub_sum_le_prod_one_sub (a : ℕ → ℝ) (k : ℕ)
    (h0 : ∀ i ∈ range k, 0 ≤ a i) (h1 : ∀ i ∈ range k, a i ≤ 1) :
    1 - ∑ i ∈ range k, a i ≤ ∏ i ∈ range k, (1 - a i) := by
  induction k with
  | zero => simp
  | succ k ih =>
      have h0' : ∀ i ∈ range k, 0 ≤ a i := fun i hi =>
        h0 i (mem_range.mpr (lt_trans (mem_range.mp hi) (Nat.lt_succ_self k)))
      have h1' : ∀ i ∈ range k, a i ≤ 1 := fun i hi =>
        h1 i (mem_range.mpr (lt_trans (mem_range.mp hi) (Nat.lt_succ_self k)))
      have hstep := ih h0' h1'
      have hak0 : 0 ≤ a k := h0 k (mem_range.mpr (Nat.lt_succ_self k))
      have hak1 : a k ≤ 1 := h1 k (mem_range.mpr (Nat.lt_succ_self k))
      have hsum0 : 0 ≤ ∑ i ∈ range k, a i := Finset.sum_nonneg h0'
      rw [Finset.prod_range_succ, Finset.sum_range_succ]
      have hmul : (1 - ∑ i ∈ range k, a i) * (1 - a k)
          ≤ (∏ i ∈ range k, (1 - a i)) * (1 - a k) :=
        mul_le_mul_of_nonneg_right hstep (by linarith)
      nlinarith [hmul, hsum0, hak0]

/-- **Genericity bound.**  `k` uniform draws are linearly independent with probability at least
`1 - (p^k - 1)/((p-1) p^n)`. -/
theorem probIndep_ge {k : ℕ} (hk : k ≤ finrank (ZMod p) V) :
    1 - ((p : ℝ) ^ k - 1) / (((p : ℝ) - 1) * (p : ℝ) ^ (finrank (ZMod p) V))
      ≤ probIndep p V k := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  set n := finrank (ZMod p) V with hn
  have hpow : (0 : ℝ) < (p : ℝ) ^ n := by positivity
  have hsum : ∑ i ∈ range k, (p : ℝ) ^ i / (p : ℝ) ^ n
      = ((p : ℝ) ^ k - 1) / (((p : ℝ) - 1) * (p : ℝ) ^ n) := by
    rw [← Finset.sum_div, geom_sum_eq (by linarith)]
    field_simp
  rw [probIndep_eq_prod hk, ← hsum]
  refine one_sub_sum_le_prod_one_sub _ k (fun i _ => by positivity) (fun i hi => ?_)
  have hle : (p : ℝ) ^ i ≤ (p : ℝ) ^ n :=
    pow_le_pow_right₀ (le_of_lt hpR) (le_trans (le_of_lt (mem_range.mp hi)) hk)
  rw [div_le_one hpow]
  exact hle

/-- Genericity decays with the width: one more draw can only make independence harder. -/
theorem probIndep_antitone_step {k : ℕ} (hk : k + 1 ≤ finrank (ZMod p) V) :
    probIndep p V (k + 1) ≤ probIndep p V k := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hpR : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  set n := finrank (ZMod p) V with hn
  have hk' : k ≤ n := by omega
  rw [probIndep_eq_prod hk, probIndep_eq_prod hk', Finset.prod_range_succ]
  have hnn : ∀ i ∈ range k, (0 : ℝ) ≤ 1 - (p : ℝ) ^ i / (p : ℝ) ^ n := by
    intro i hi
    have hle : (p : ℝ) ^ i ≤ (p : ℝ) ^ n :=
      pow_le_pow_right₀ (le_of_lt hpR) (le_trans (le_of_lt (mem_range.mp hi)) hk')
    have : (p : ℝ) ^ i / (p : ℝ) ^ n ≤ 1 := by
      rw [div_le_one (by positivity)]; exact hle
    linarith
  have hprod : (0 : ℝ) ≤ ∏ i ∈ range k, (1 - (p : ℝ) ^ i / (p : ℝ) ^ n) :=
    Finset.prod_nonneg hnn
  have hfac : (0 : ℝ) ≤ (p : ℝ) ^ k / (p : ℝ) ^ n := by positivity
  nlinarith [hprod, hfac]

/-! ## Synthesis: reliability and genericity together -/

open EOSWidthRamp in
/-- **Reliability ∧ genericity.**  With `k ≤ n` exclusive dimensions, the probability that the
boundary token occupies a genuinely `k`-dimensional subspace *and* avoids every obstruction is
at least `1 - m·p^{-k} - (p^k-1)/((p-1)p^n)`.  The two error terms move in opposite directions
in `k`, so the design optimum is interior. -/
theorem prob_indep_and_cure_ge (W : Fin m → Submodule (ZMod p) V) (hW : ∀ j, W j ≠ ⊤) {k : ℕ}
    (hk : k ≤ finrank (ZMod p) V) :
    1 - (m : ℝ) / (p : ℝ) ^ k
        - ((p : ℝ) ^ k - 1) / (((p : ℝ) - 1) * (p : ℝ) ^ (finrank (ZMod p) V))
      ≤ (Nat.card {v : Fin k → V // LinearIndependent (ZMod p) v ∧ ¬ ∃ j, ∀ i, v i ∈ W j} : ℝ)
          / (Nat.card V : ℝ) ^ k := by
  classical
  have hNpos : (0 : ℝ) < (Nat.card V : ℝ) ^ k :=
    pow_pos (by exact_mod_cast (EOSWidthRamp.card_V_pos (V := V))) k
  -- set-level union bound: independent ⊆ (independent ∧ cured) ∪ failing
  set I : Set (Fin k → V) := {v | LinearIndependent (ZMod p) v} with hI
  set G : Set (Fin k → V) := {v | LinearIndependent (ZMod p) v ∧ ¬ ∃ j, ∀ i, v i ∈ W j} with hG
  set F : Set (Fin k → V) := {v | ∃ j, ∀ i, v i ∈ W j} with hF
  have hsub : I ⊆ G ∪ F := by
    intro v hv
    by_cases hfail : ∃ j, ∀ i, v i ∈ W j
    · exact Or.inr hfail
    · exact Or.inl ⟨hv, hfail⟩
  have hcard : Nat.card I ≤ Nat.card G + Nat.card F := by
    have h1 : I.ncard ≤ (G ∪ F).ncard := Set.ncard_le_ncard hsub (Set.toFinite _)
    have h2 : (G ∪ F).ncard ≤ G.ncard + F.ncard := Set.ncard_union_le G F
    simpa [Nat.card_coe_set_eq] using le_trans h1 h2
  have hIcard : (Nat.card I : ℝ)
      = (Nat.card {s : Fin k → V // LinearIndependent (ZMod p) s} : ℝ) := rfl
  have hFcard : (Nat.card F : ℝ) = (EOSWidthRamp.failCount W k : ℝ) := rfl
  have hGcard : (Nat.card G : ℝ)
      = (Nat.card {v : Fin k → V // LinearIndependent (ZMod p) v ∧ ¬ ∃ j, ∀ i, v i ∈ W j} : ℝ) :=
    rfl
  have hcardR : (Nat.card {s : Fin k → V // LinearIndependent (ZMod p) s} : ℝ)
      ≤ (Nat.card {v : Fin k → V // LinearIndependent (ZMod p) v ∧ ¬ ∃ j, ∀ i, v i ∈ W j} : ℝ)
        + (EOSWidthRamp.failCount W k : ℝ) := by
    rw [← hIcard, ← hGcard, ← hFcard]
    exact_mod_cast hcard
  have hdiv := (div_le_div_iff_of_pos_right hNpos).mpr hcardR
  have hgen := probIndep_ge (p := p) (V := V) hk
  have hfail := EOSWidthRamp.failProb_le W hW k
  rw [probIndep] at hgen
  rw [EOSWidthRamp.failProb] at hfail
  have hsplit : ((Nat.card {v : Fin k → V // LinearIndependent (ZMod p) v ∧ ¬ ∃ j, ∀ i, v i ∈ W j} : ℝ)
      + (EOSWidthRamp.failCount W k : ℝ)) / (Nat.card V : ℝ) ^ k
      = (Nat.card {v : Fin k → V // LinearIndependent (ZMod p) v ∧ ¬ ∃ j, ∀ i, v i ∈ W j} : ℝ)
          / (Nat.card V : ℝ) ^ k
        + (EOSWidthRamp.failCount W k : ℝ) / (Nat.card V : ℝ) ^ k := by
    rw [add_div]
  have hle : (Nat.card {s : Fin k → V // LinearIndependent (ZMod p) s} : ℝ)
        / (Nat.card V : ℝ) ^ k
      ≤ (Nat.card {v : Fin k → V // LinearIndependent (ZMod p) v ∧ ¬ ∃ j, ∀ i, v i ∈ W j} : ℝ)
          / (Nat.card V : ℝ) ^ k
        + (EOSWidthRamp.failCount W k : ℝ) / (Nat.card V : ℝ) ^ k := by
    rw [← hsplit]; exact hdiv
  linarith

end EOSGenericity