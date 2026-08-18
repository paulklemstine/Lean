/-
# The Bernoulli environment: the probabilistic endpoint of the decoding trade-off

This file builds, from scratch and with no measure theory, the finite Bernoulli product
measure on environments `ω : Fin n → Bool`.  Here `ω i = true` means "step `i` of the
tropical chain is *informative*" (its transfer matrix has small diameter), and
`ω i = false` means the step is *uninformative*.

The decoder of `Tropical.DecodingTradeoff.Tradeoff` with window length `b` fails at a
position only if an entire window of `b` consecutive steps is uninformative.  This file
computes the probability of that event exactly and bounds it from both sides.

## Main results

* `Prob_univ` — the weights `wt p` form a probability distribution (total mass `1`).
* `Prob_badWindow` — the probability that a whole window of length `b` is uninformative
  is **exactly** `(1 - p) ^ b`.
* `prob_failSet_le` — union bound: `Prob p (failSet b) ≤ (n + 1 - b) * (1 - p) ^ b`.
* `prob_failSet_ge` — matching lower bound: `(1 - p) ^ b ≤ Prob p (failSet b)`.

The upper and lower bounds differ only by the polynomial factor `n + 1 - b`; this is
what makes the converse (cost lower bound) of the trade-off possible.
-/

import Mathlib

open Finset

namespace Tropical.DecodingTradeoff

/-! ## §0. Two elementary facts about sums of nonnegative terms -/

theorem sum_union_le_of_nonneg {ι : Type*} [DecidableEq ι] (E F : Finset ι) (w : ι → ℝ)
    (hw : ∀ x, 0 ≤ w x) : ∑ x ∈ E ∪ F, w x ≤ ∑ x ∈ E, w x + ∑ x ∈ F, w x := by
  have h := Finset.sum_union_inter (s₁ := E) (s₂ := F) (f := w)
  have h2 : (0 : ℝ) ≤ ∑ x ∈ E ∩ F, w x := Finset.sum_nonneg fun x _ => hw x
  linarith

theorem sum_biUnion_le_of_nonneg {ι κ : Type*} [DecidableEq ι] [DecidableEq κ]
    (B : Finset ι) (f : ι → Finset κ) (w : κ → ℝ) (hw : ∀ x, 0 ≤ w x) :
    ∑ x ∈ B.biUnion f, w x ≤ ∑ i ∈ B, ∑ x ∈ f i, w x := by
  classical
  induction B using Finset.induction with
  | empty => simp
  | insert a B ha ih =>
      rw [Finset.biUnion_insert, Finset.sum_insert ha]
      exact le_trans (sum_union_le_of_nonneg _ _ w hw) (by linarith)

/-! ## §1. Environments and the Bernoulli product weight -/

variable {n : ℕ}

/-- The Bernoulli weight of an environment: each step is informative with probability `p`. -/
def wt (p : ℝ) (ω : Fin n → Bool) : ℝ := ∏ i, (if ω i then p else 1 - p)

/-- The probability of a finite set of environments. -/
def Prob (p : ℝ) (E : Finset (Fin n → Bool)) : ℝ := ∑ ω ∈ E, wt p ω

lemma wt_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (ω : Fin n → Bool) : 0 ≤ wt p ω :=
  Finset.prod_nonneg fun i _ => by by_cases h : ω i <;> simp [h] <;> linarith

lemma Prob_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (E : Finset (Fin n → Bool)) :
    0 ≤ Prob p E :=
  Finset.sum_nonneg fun ω _ => wt_nonneg hp0 hp1 ω

lemma Prob_mono {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {E F : Finset (Fin n → Bool)}
    (h : E ⊆ F) : Prob p E ≤ Prob p F :=
  Finset.sum_le_sum_of_subset_of_nonneg h fun ω _ _ => wt_nonneg hp0 hp1 ω

/-- The Bernoulli weights form a probability distribution. -/
theorem Prob_univ (p : ℝ) : Prob p (Finset.univ : Finset (Fin n → Bool)) = 1 := by
  classical
  have h := Finset.prod_univ_sum (ι := Fin n) (κ := fun _ => Bool)
      (fun _ => (Finset.univ : Finset Bool)) (fun _ b => if b then p else 1 - p)
  rw [Fintype.piFinset_univ] at h
  have hleft : (∏ _i : Fin n, ∑ b : Bool, if b then p else 1 - p) = 1 := by
    simp
  rw [hleft] at h
  simpa [Prob, wt] using h.symm

/-- Complementary events. -/
theorem Prob_compl (p : ℝ) (E : Finset (Fin n → Bool)) : Prob p Eᶜ = 1 - Prob p E := by
  classical
  have h := Finset.sum_add_sum_compl (ι := Fin n → Bool) E (wt p)
  have h2 : Prob p (Finset.univ : Finset (Fin n → Bool)) = 1 := Prob_univ p
  simp only [Prob] at h2 ⊢
  linarith [h, h2]

/-! ## §2. Uninformative windows -/

/-- The set of positions covered by the window of length `b` starting at `i`. -/
def winSet (n i b : ℕ) : Finset (Fin n) :=
  Finset.univ.filter (fun x : Fin n => i ≤ (x : ℕ) ∧ (x : ℕ) < i + b)

lemma mem_winSet {n i b : ℕ} (x : Fin n) :
    x ∈ winSet n i b ↔ i ≤ (x : ℕ) ∧ (x : ℕ) < i + b := by
  simp [winSet]

/-- A window that fits inside `Fin n` has exactly `b` positions. -/
theorem card_winSet {n i b : ℕ} (h : i + b ≤ n) : (winSet n i b).card = b := by
  classical
  have hlt : ∀ m ∈ Finset.Ico i (i + b), m < n := by
    intro m hm; rw [Finset.mem_Ico] at hm; omega
  have hEq : winSet n i b = (Finset.Ico i (i + b)).attachFin hlt := by
    ext x
    simp [mem_winSet, Finset.mem_attachFin, Finset.mem_Ico]
  rw [hEq, Finset.card_attachFin, Nat.card_Ico]
  omega

/-- The cylinder event "every position in `W` is uninformative". -/
def badSet (n : ℕ) (W : Finset (Fin n)) : Finset (Fin n → Bool) :=
  Fintype.piFinset (fun x : Fin n => if x ∈ W then {false} else Finset.univ)

lemma mem_badSet {n : ℕ} {W : Finset (Fin n)} (ω : Fin n → Bool) :
    ω ∈ badSet n W ↔ ∀ x ∈ W, ω x = false := by
  classical
  simp only [badSet, Fintype.mem_piFinset]
  constructor
  · intro h x hx
    have := h x
    rw [if_pos hx] at this
    simpa using this
  · intro h x
    by_cases hx : x ∈ W
    · rw [if_pos hx]; simp [h x hx]
    · rw [if_neg hx]; exact Finset.mem_univ _

/-- **Exact cylinder probability.**  An uninformative set of `c` positions has probability
exactly `(1 - p) ^ c`. -/
theorem Prob_badSet (p : ℝ) {n : ℕ} (W : Finset (Fin n)) :
    Prob p (badSet n W) = (1 - p) ^ W.card := by
  classical
  have h := Finset.prod_univ_sum (ι := Fin n) (κ := fun _ => Bool)
      (fun x : Fin n => if x ∈ W then ({false} : Finset Bool) else Finset.univ)
      (fun _ b => if b then p else 1 - p)
  have hfac : ∀ x : Fin n,
      (∑ c ∈ (if x ∈ W then ({false} : Finset Bool) else Finset.univ),
        (if c then p else 1 - p)) = if x ∈ W then 1 - p else 1 := by
    intro x
    by_cases hx : x ∈ W
    · simp [hx]
    · simp [hx]
  simp only [hfac] at h
  have hfilter : (Finset.univ.filter (fun x : Fin n => x ∈ W)) = W := by
    ext x; simp
  have hprod : (∏ x : Fin n, if x ∈ W then 1 - p else 1) = (1 - p) ^ W.card := by
    rw [← Finset.prod_filter, hfilter, Finset.prod_const]
  rw [hprod] at h
  simpa [Prob, wt, badSet] using h.symm

/-- Cylinders intersect to cylinders: this is where independence of disjoint coordinate
blocks enters. -/
theorem badSet_inter {n : ℕ} (W₁ W₂ : Finset (Fin n)) :
    badSet n W₁ ∩ badSet n W₂ = badSet n (W₁ ∪ W₂) := by
  classical
  ext ω
  simp only [Finset.mem_inter, mem_badSet, Finset.mem_union]
  constructor
  · rintro ⟨h1, h2⟩ x hx
    rcases hx with hx | hx
    · exact h1 x hx
    · exact h2 x hx
  · intro h
    exact ⟨fun x hx => h x (Or.inl hx), fun x hx => h x (Or.inr hx)⟩

/-- The event "every step in the window of length `b` starting at `i` is uninformative". -/
def badWindow (n i b : ℕ) : Finset (Fin n → Bool) := badSet n (winSet n i b)

lemma mem_badWindow {n i b : ℕ} (ω : Fin n → Bool) :
    ω ∈ badWindow n i b ↔ ∀ x ∈ winSet n i b, ω x = false := mem_badSet ω

/-- An uninformative window of `c` positions has probability exactly `(1 - p) ^ c`. -/
theorem Prob_badWindow (p : ℝ) (n i b : ℕ) :
    Prob p (badWindow n i b) = (1 - p) ^ (winSet n i b).card := Prob_badSet p _

/-- Two windows that do not overlap are disjoint as coordinate sets. -/
theorem winSet_disjoint {n i j b : ℕ} (h : i + b ≤ j) :
    Disjoint (winSet n i b) (winSet n j b) := by
  classical
  rw [Finset.disjoint_left]
  intro x hx hx'
  rw [mem_winSet] at hx hx'
  omega

/-- **Independence of disjoint windows.**  Two nonoverlapping uninformative windows have
probability exactly `(1 - p) ^ (2 * b)`. -/
theorem Prob_badWindow_inter (p : ℝ) {n i j b : ℕ} (hij : i + b ≤ j) (hj : j + b ≤ n) :
    Prob p (badWindow n i b ∩ badWindow n j b) = (1 - p) ^ (2 * b) := by
  classical
  rw [badWindow, badWindow, badSet_inter, Prob_badSet,
    Finset.card_union_of_disjoint (winSet_disjoint hij),
    card_winSet (by omega : i + b ≤ n), card_winSet hj]
  ring_nf

/-- The window-`b` failure event: some window of `b` consecutive steps is uninformative. -/
def failSet (n b : ℕ) : Finset (Fin n → Bool) :=
  (Finset.range (n + 1 - b)).biUnion (fun i => badWindow n i b)

/-- **Union bound.**  The failure probability decays exponentially in the window length. -/
theorem prob_failSet_le {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {n b : ℕ} (hbn : b ≤ n) :
    Prob p (failSet n b) ≤ (n + 1 - b : ℕ) * (1 - p) ^ b := by
  classical
  have hb : Prob p (failSet n b) ≤ ∑ i ∈ Finset.range (n + 1 - b), Prob p (badWindow n i b) :=
    sum_biUnion_le_of_nonneg _ _ _ (wt_nonneg hp0 hp1)
  have hEach : ∀ i ∈ Finset.range (n + 1 - b), Prob p (badWindow n i b) = (1 - p) ^ b := by
    intro i hi
    rw [Finset.mem_range] at hi
    rw [Prob_badWindow, card_winSet (by omega)]
  calc Prob p (failSet n b) ≤ ∑ i ∈ Finset.range (n + 1 - b), Prob p (badWindow n i b) := hb
    _ = ∑ _i ∈ Finset.range (n + 1 - b), (1 - p) ^ b := Finset.sum_congr rfl hEach
    _ = (n + 1 - b : ℕ) * (1 - p) ^ b := by rw [Finset.sum_const, Finset.card_range]; ring

/-- **Matching lower bound.**  A single window already contributes `(1 - p) ^ b`. -/
theorem prob_failSet_ge {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {n b : ℕ} (hbn : b ≤ n) :
    (1 - p) ^ b ≤ Prob p (failSet n b) := by
  classical
  have hsub : badWindow n 0 b ⊆ failSet n b := by
    intro ω hω
    exact Finset.mem_biUnion.mpr ⟨0, Finset.mem_range.mpr (by omega), hω⟩
  have := Prob_mono hp0 hp1 hsub
  rwa [Prob_badWindow, card_winSet (by omega : 0 + b ≤ n)] at this

end Tropical.DecodingTradeoff