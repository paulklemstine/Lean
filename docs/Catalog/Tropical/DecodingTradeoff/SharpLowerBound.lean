/-
# Closing the polynomial gap: a Bonferroni lower bound on the failure probability

`Tropical.DecodingTradeoff.Environment` bounds the window-`b` failure probability from
above by `(n + 1 - b) (1 - p) ^ b` (union bound) and from below by `(1 - p) ^ b` (one
cylinder).  The two differ by the polynomial factor `n + 1 - b`, and it is exactly this
factor that separates the converse `window_lower_bound_of_reliable` from the achievability
result `window_upper_bound_sufficient`.

This file removes most of that gap.  The `⌊n/b⌋` windows starting at `0, b, 2b, …` are
pairwise *disjoint*, hence independent, and a second-order Bonferroni inequality turns
that independence into a lower bound that is **linear in the number of disjoint windows**.

## Main results

* `Prob_union_add_inter` — inclusion–exclusion for two events.
* `prob_biUnion_range_ge` — the second Bonferroni inequality
  `∑ P(Eᵢ) - ∑_{j<i} P(Eⱼ ∩ Eᵢ) ≤ P(⋃ Eᵢ)`, proved by induction.
* `prob_failSet_ge_disjoint` — `m (1-p)^b - (m(m-1)/2) (1-p)^{2b} ≤ Prob p (failSet n b)`
  for any `m` disjoint windows.
* `prob_failSet_ge_half` — the clean consequence: as soon as `m (1-p)^b ≤ 1`,
  `Prob p (failSet n b) ≥ (m/2) (1-p)^b`.
* `prob_failSet_ge_div` — with `m = ⌊n/b⌋`, the failure probability really is linear in
  `n/b`, so the union bound is tight up to a factor `≈ 2b`.
* `window_lower_bound_sharp` — the resulting sharpened converse: reliability `ε` forces
  `b · log(1/(1-p)) ≥ log(⌊n/b⌋ / (2ε))`, i.e. only `log (2b)` short of the
  achievability threshold `log(n/ε)` of `window_upper_bound_sufficient`.
-/

import Tropical.DecodingTradeoff.Environment

open Finset

namespace Tropical.DecodingTradeoff

variable {n : ℕ}

/-! ## §1. Inclusion–exclusion and Bonferroni -/

/-- Inclusion–exclusion for two events. -/
theorem Prob_union_add_inter (p : ℝ) (E F : Finset (Fin n → Bool)) :
    Prob p (E ∪ F) + Prob p (E ∩ F) = Prob p E + Prob p F :=
  Finset.sum_union_inter

/-- **Second Bonferroni inequality.**  The probability of a union is at least the sum of
the individual probabilities minus the sum of the pairwise intersections. -/
theorem prob_biUnion_range_ge {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (E : ℕ → Finset (Fin n → Bool)) (m : ℕ) :
    (∑ i ∈ Finset.range m, Prob p (E i))
        - ∑ i ∈ Finset.range m, ∑ j ∈ Finset.range i, Prob p (E j ∩ E i)
      ≤ Prob p ((Finset.range m).biUnion E) := by
  classical
  induction m with
  | zero => simp [Prob]
  | succ m ih =>
      have hX : (Finset.range (m + 1)).biUnion E = E m ∪ (Finset.range m).biUnion E := by
        rw [Finset.range_add_one, Finset.biUnion_insert]
      have hinter : E m ∩ (Finset.range m).biUnion E
          = (Finset.range m).biUnion (fun j => E j ∩ E m) := by
        ext ω
        simp only [Finset.mem_inter, Finset.mem_biUnion]
        constructor
        · rintro ⟨hm, j, hj, hEj⟩; exact ⟨j, hj, hEj, hm⟩
        · rintro ⟨j, hj, hEj, hm⟩; exact ⟨hm, j, hj, hEj⟩
      have hIE := Prob_union_add_inter p (E m) ((Finset.range m).biUnion E)
      have hbound : Prob p (E m ∩ (Finset.range m).biUnion E)
          ≤ ∑ j ∈ Finset.range m, Prob p (E j ∩ E m) := by
        rw [hinter]
        exact sum_biUnion_le_of_nonneg _ _ _ (wt_nonneg hp0 hp1)
      rw [hX]
      rw [Finset.sum_range_succ, Finset.sum_range_succ (f := fun i =>
        ∑ j ∈ Finset.range i, Prob p (E j ∩ E i))]
      linarith [ih, hIE, hbound]

/-! ## §2. Disjoint windows give a linear lower bound -/

private lemma sum_range_cast (m : ℕ) : ∑ i ∈ Finset.range m, (i : ℝ) = m * (m - 1) / 2 := by
  induction m with
  | zero => simp
  | succ m ih =>
      rw [Finset.sum_range_succ, ih]
      push_cast
      ring

/-- **Bonferroni lower bound for the decoder failure probability.**  Using the `m`
pairwise disjoint windows starting at `0, b, 2b, …, (m-1)b`. -/
theorem prob_failSet_ge_disjoint {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {b m : ℕ}
    (hm : m * b ≤ n) :
    (m : ℝ) * (1 - p) ^ b - ((m : ℝ) * (m - 1) / 2) * (1 - p) ^ (2 * b)
      ≤ Prob p (failSet n b) := by
  classical
  set E : ℕ → Finset (Fin n → Bool) := fun t => badWindow n (t * b) b with hE
  have hfit : ∀ t, t < m → t * b + b ≤ n := by
    intro t ht
    calc t * b + b = (t + 1) * b := by ring
      _ ≤ m * b := Nat.mul_le_mul_right b (by omega)
      _ ≤ n := hm
  -- each disjoint window has probability exactly `(1-p)^b`
  have hsingle : ∀ t ∈ Finset.range m, Prob p (E t) = (1 - p) ^ b := by
    intro t ht
    rw [Finset.mem_range] at ht
    rw [hE, Prob_badWindow, card_winSet (hfit t ht)]
  -- pairwise intersections have probability exactly `(1-p)^(2b)`
  have hpair : ∀ i ∈ Finset.range m, ∀ j ∈ Finset.range i,
      Prob p (E j ∩ E i) = (1 - p) ^ (2 * b) := by
    intro i hi j hj
    rw [Finset.mem_range] at hi hj
    have hij : j * b + b ≤ i * b := by
      calc j * b + b = (j + 1) * b := by ring
        _ ≤ i * b := Nat.mul_le_mul_right b (by omega)
    exact Prob_badWindow_inter p hij (hfit i hi)
  have hsum1 : (∑ i ∈ Finset.range m, Prob p (E i)) = (m : ℝ) * (1 - p) ^ b := by
    rw [Finset.sum_congr rfl hsingle, Finset.sum_const, Finset.card_range]
    ring
  have hsum2 : (∑ i ∈ Finset.range m, ∑ j ∈ Finset.range i, Prob p (E j ∩ E i))
      = ((m : ℝ) * (m - 1) / 2) * (1 - p) ^ (2 * b) := by
    have : ∀ i ∈ Finset.range m, (∑ j ∈ Finset.range i, Prob p (E j ∩ E i))
        = (i : ℝ) * (1 - p) ^ (2 * b) := by
      intro i hi
      rw [Finset.sum_congr rfl (hpair i hi), Finset.sum_const, Finset.card_range]
      ring
    rw [Finset.sum_congr rfl this, ← Finset.sum_mul, sum_range_cast]
  have hsub : (Finset.range m).biUnion E ⊆ failSet n b := by
    intro ω hω
    rw [Finset.mem_biUnion] at hω
    obtain ⟨t, ht, hωt⟩ := hω
    rw [Finset.mem_range] at ht
    exact Finset.mem_biUnion.mpr ⟨t * b, Finset.mem_range.mpr (by have := hfit t ht; omega), hωt⟩
  have hmono : Prob p ((Finset.range m).biUnion E) ≤ Prob p (failSet n b) :=
    Prob_mono hp0 hp1 hsub
  have hbonf := prob_biUnion_range_ge hp0 hp1 E m
  rw [hsum1, hsum2] at hbonf
  linarith

/-- **The failure probability is linear in the number of disjoint windows.**  As soon as
`m (1-p)^b ≤ 1`, half of the first-order term survives. -/
theorem prob_failSet_ge_half {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {b m : ℕ}
    (hm : m * b ≤ n) (hsmall : (m : ℝ) * (1 - p) ^ b ≤ 1) :
    ((m : ℝ) / 2) * (1 - p) ^ b ≤ Prob p (failSet n b) := by
  have hq : (0 : ℝ) ≤ 1 - p := by linarith
  have hpow : (0 : ℝ) ≤ (1 - p) ^ b := by positivity
  have hmnn : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
  have hsq : (1 - p) ^ (2 * b) = ((1 - p) ^ b) * ((1 - p) ^ b) := by
    rw [two_mul, pow_add]
  have hkey : ((m : ℝ) * (m - 1) / 2) * (1 - p) ^ (2 * b) ≤ ((m : ℝ) / 2) * (1 - p) ^ b := by
    rw [hsq]
    have h1 : ((m : ℝ) * (m - 1) / 2) * ((1 - p) ^ b * (1 - p) ^ b)
        ≤ ((m : ℝ) / 2) * ((m : ℝ) * (1 - p) ^ b) * (1 - p) ^ b := by
      have : (m : ℝ) * (m - 1) / 2 ≤ ((m : ℝ) / 2) * (m : ℝ) := by nlinarith
      nlinarith [mul_nonneg hpow hpow]
    have h2 : ((m : ℝ) / 2) * ((m : ℝ) * (1 - p) ^ b) * (1 - p) ^ b
        ≤ ((m : ℝ) / 2) * 1 * (1 - p) ^ b := by
      have hhalf : (0 : ℝ) ≤ (m : ℝ) / 2 := by linarith
      nlinarith [mul_nonneg hhalf hpow]
    linarith
  have := prob_failSet_ge_disjoint (n := n) hp0 hp1 hm
  linarith

/-- With the maximal number `⌊n/b⌋` of disjoint windows: the union bound
`(n + 1 - b) (1-p)^b` is tight up to a factor `≈ 2b`. -/
theorem prob_failSet_ge_div {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {b : ℕ}
    (hsmall : ((n / b : ℕ) : ℝ) * (1 - p) ^ b ≤ 1) :
    (((n / b : ℕ) : ℝ) / 2) * (1 - p) ^ b ≤ Prob p (failSet n b) :=
  prob_failSet_ge_half hp0 hp1 (Nat.div_mul_le_self n b) hsmall

/-- **Sharpened converse.**  Achieving failure probability `≤ ε` forces
`b · log(1/(1-p)) ≥ log(⌊n/b⌋ / (2ε))`.  Compared with the achievability threshold
`log(n/ε)` of `window_upper_bound_sufficient`, only an additive `log(2b)` remains. -/
theorem window_lower_bound_sharp {p ε : ℝ} (hp0 : 0 ≤ p) (hp1 : p < 1) {b : ℕ}
    (hn : 1 ≤ n / b) (hsmall : ((n / b : ℕ) : ℝ) * (1 - p) ^ b ≤ 1)
    (hfail : Prob p (failSet n b) ≤ ε) :
    Real.log (((n / b : ℕ) : ℝ) / (2 * ε)) ≤ b * Real.log (1 / (1 - p)) := by
  have hq : (0 : ℝ) < 1 - p := by linarith
  have hmpos : (0 : ℝ) < ((n / b : ℕ) : ℝ) := by exact_mod_cast hn
  have hpow : (0 : ℝ) < (1 - p) ^ b := by positivity
  have hge := prob_failSet_ge_div (n := n) hp0 (le_of_lt hp1) hsmall
  have hεpos : 0 < ε := by
    have : (0 : ℝ) < (((n / b : ℕ) : ℝ) / 2) * (1 - p) ^ b := by positivity
    linarith
  have hkey : ((n / b : ℕ) : ℝ) / (2 * ε) ≤ 1 / (1 - p) ^ b := by
    rw [div_le_div_iff₀ (by linarith) hpow]
    have h2 : (((n / b : ℕ) : ℝ) / 2) * (1 - p) ^ b ≤ ε := le_trans hge hfail
    nlinarith
  have hlog := Real.log_le_log (by positivity) hkey
  rw [one_div, Real.log_inv, Real.log_pow] at hlog
  rw [one_div, Real.log_inv]
  linarith

end Tropical.DecodingTradeoff