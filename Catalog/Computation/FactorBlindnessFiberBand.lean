/-
# The fiber band: a pair-collision view reads within one bit of the label entropy

`Computation.FactorBlindnessHintedView` bounds the deficit `H(ℓ) − Î` by
`(collisionCount / n) · log₂|L|`.  The `log₂|L|` factor is the worst case *inside* a fiber,
and it is badly pessimistic for the views the battery programme actually uses: a hint view
built from the factor traces is injective on unordered pairs, so its fibers have **two**
elements, and two samples cannot carry more than one bit of label entropy between them —
however large the label alphabet is.

This file replaces the alphabet factor by the fiber size.

## Main results

* `entropy_le_logb_support` — a mass function's entropy is at most `log₂` of the size of its
  *support*, sharpening `entropy_le_logb_card` (which uses the whole alphabet).  Proved from
  the same Gibbs inequality with the uniform measure on the support.
* `gap_le_fiber_log_sum` — the deficit is at most `(1/n) ∑_k f_k log₂ f_k` over the colliding
  fibers, where `f_k` is the fiber size.  No reference to the label alphabet at all.
* `pairwise_collisions_band` — for a view whose fibers have at most two elements the deficit
  is at most the collision fraction **in bits**: `H(ℓ) − Î ≤ collisionCount / n`.
* `pair_view_reading_within_one_bit` — **the quantitative form of the experimental table**:
  a view that is injective on unordered pairs reads within `1` bit of the label entropy,
  whatever the label alphabet and whatever the dependence.  A reading of `4.56` against a
  label entropy of `4.60` is therefore forced, not measured.
* `pair_view_null_band` — and so is every label-permuted surrogate: the whole permutation null
  of such a view lives in the same one-bit window.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the `log₂|L|` factor in the collision sandwich is an artefact of using
  the alphabet as the worst case; the true worst case is the fiber size, which for a
  trace-routed view is `2`.
Experiment (Stage 2, `ComputationalEvidence.md`): on 3906 ordered pairs of 63 primes the
  `(s,d)` view realises exactly 1953 distinct values — one per unordered pair — so every
  fiber has size exactly `2` and the one-bit window is attained exactly; the product view
  `N mod 713` realises 639 values with fibers of size up to 16, where the fiber-log bound
  gives `(1/n) ∑ f log₂ f = 2.766` bits, weaker than the binary alphabet bound but the only
  one of the two that survives a large label alphabet.
Analysis (Stage 3): inside a fiber of size `f` at most `f` distinct labels can occur, so the
  conditional entropy there is at most `log₂ f`; summing the fiber weights gives a bound that
  is *independent of the label alphabet* and tight at `f = 2`.  The support-entropy lemma is
  the only new analytic ingredient, and it is Gibbs again, with the uniform measure supported
  on the realised labels.
Critique (Stage 4): the bound degrades as fibers grow, and for a single fiber of size `n` it
  returns `log₂ n`, which is weaker than the alphabet bound when `|L| < n` — the two bounds
  are genuinely incomparable, so we keep both rather than replacing one by the other.
Synthesis (Stage 5): the only thing a pair-collision view can report is the label entropy,
  plus or minus one bit; a which-factor reading taken through such a view is a measurement of
  the label margin.
-/
import Mathlib
import Computation.FactorBlindnessInformation
import Computation.FactorBlindnessSharp
import Computation.FactorBlindnessHintedView

namespace Computation.FactorBlindness

open Finset

/-! ## Entropy is capped by the support, not by the alphabet -/

/-- **Support form of the max-entropy bound.**  The entropy of a mass function is at most
`log₂` of the number of values it actually charges. -/
theorem entropy_le_logb_support {K : Type*} [Fintype K] [DecidableEq K] {r : K → ℝ}
    (hr : ∀ k, 0 ≤ r k) (htot : ∑ k, r k = 1) :
    entropy r ≤ Real.logb 2 ((univ.filter (fun k => r k ≠ 0)).card) := by
  set S : Finset K := univ.filter (fun k => r k ≠ 0) with hS
  have hSpos : 0 < S.card := by
    rcases Finset.eq_empty_or_nonempty S with h | h
    · exfalso
      have : ∑ k, r k = 0 := by
        refine Finset.sum_eq_zero fun k _ => ?_
        by_contra hk
        have : k ∈ S := by simp [hS, hk]
        simp [h] at this
      rw [htot] at this
      norm_num at this
    · exact Finset.card_pos.2 h
  set s : ℝ := (S.card : ℝ) with hs
  have hspos : (0:ℝ) < s := by rw [hs]; exact_mod_cast hSpos
  set q : K → ℝ := fun k => if r k = 0 then 0 else 1 / s with hq
  have hqnn : ∀ k, 0 ≤ q k := by
    intro k; rw [hq]; dsimp only; split <;> positivity
  have hac : ∀ k, q k = 0 → r k = 0 := by
    intro k hk
    by_contra hr0
    rw [hq] at hk
    simp only [hr0, if_false] at hk
    have : (1:ℝ)/s ≠ 0 := by positivity
    exact this hk
  have hq1 : ∑ k, q k ≤ 1 := by
    have : ∑ k, q k = ∑ _k ∈ S, (1:ℝ) / s := by
      rw [hq, hS]
      rw [Finset.sum_filter]
      refine Finset.sum_congr rfl fun k _ => ?_
      by_cases h : r k = 0 <;> simp [h]
    rw [this, Finset.sum_const, nsmul_eq_mul, ← hs]
    rw [mul_one_div, div_self (ne_of_gt hspos)]
  have hgibbs := sum_mul_log_div_nonneg r q hr hqnn hac htot hq1
  have hterm : ∀ k, r k * Real.log (r k / q k) = r k * Real.log (r k) + r k * Real.log s := by
    intro k
    by_cases h : r k = 0
    · simp [h]
    · have hrk : 0 < r k := lt_of_le_of_ne (hr k) (Ne.symm h)
      have hqk : q k = 1 / s := by rw [hq]; simp [h]
      rw [hqk, show r k / (1 / s) = r k * s by field_simp,
        Real.log_mul (ne_of_gt hrk) (ne_of_gt hspos)]
      ring
  rw [Finset.sum_congr rfl (fun k _ => hterm k), Finset.sum_add_distrib, ← Finset.sum_mul,
    htot, one_mul] at hgibbs
  have hentropy : entropy r = -(∑ k, r k * Real.log (r k)) / Real.log 2 := by
    unfold entropy
    rw [Finset.sum_congr rfl (fun k _ => by
      simp [Real.logb, mul_div_assoc, neg_div] : ∀ k ∈ univ,
        -(r k * Real.logb 2 (r k)) = -(r k * Real.log (r k)) / Real.log 2),
      ← Finset.sum_div]
    congr 1
    simp
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [hentropy, Real.logb]
  gcongr
  linarith

/-! ## The fiber-size band -/

variable {n : ℕ} {L K : Type*} [Fintype L] [DecidableEq L] [Fintype K] [DecidableEq K]

omit [Fintype K] in
/-- At most `f_k` distinct labels can occur inside a fiber of size `f_k`. -/
lemma support_card_le_fiberCount (l : Fin n → L) (c : Fin n → K) (k : K)
    (hf : 0 < fiberCount c k) :
    (univ.filter (fun a => ((cellCount l c a k : ℝ) / fiberCount c k) ≠ 0)).card
      ≤ fiberCount c k := by
  have hfR : (0:ℝ) < (fiberCount c k : ℝ) := by exact_mod_cast hf
  have hsub : (univ.filter (fun a => ((cellCount l c a k : ℝ) / fiberCount c k) ≠ 0))
      ⊆ univ.filter (fun a => 1 ≤ cellCount l c a k) := by
    intro a ha
    simp only [mem_filter, mem_univ, true_and, ne_eq, div_eq_zero_iff, not_or] at ha ⊢
    have : (cellCount l c a k : ℝ) ≠ 0 := ha.1
    have : cellCount l c a k ≠ 0 := by exact_mod_cast this
    omega
  refine le_trans (Finset.card_le_card hsub) ?_
  calc (univ.filter (fun a => 1 ≤ cellCount l c a k)).card
      = ∑ _a ∈ univ.filter (fun a => 1 ≤ cellCount l c a k), 1 := by
        rw [Finset.card_eq_sum_ones]
    _ ≤ ∑ a ∈ univ.filter (fun a => 1 ≤ cellCount l c a k), cellCount l c a k := by
        refine Finset.sum_le_sum fun a ha => ?_
        simp only [mem_filter, mem_univ, true_and] at ha
        exact ha
    _ ≤ ∑ a, cellCount l c a k :=
        Finset.sum_le_sum_of_subset (Finset.filter_subset _ _)
    _ = fiberCount c k := sum_cellCount_over_label l c k

omit [Fintype K] in
/-- Each fiber's contribution to the deficit is at most its weight times `log₂` of its size. -/
lemma fiber_gap_le_log (l : Fin n → L) (c : Fin n → K) (k : K) (hn : 0 < n) :
    ∑ a, -(viewTable l c a k *
        Real.logb 2 (viewTable l c a k / margK (viewTable l c) k))
      ≤ (if 2 ≤ fiberCount c k then ((fiberCount c k : ℝ) / n) *
            Real.logb 2 (fiberCount c k) else 0) := by
  rcases Nat.lt_or_ge (fiberCount c k) 2 with hlt | hge
  · interval_cases h : fiberCount c k
    · rw [if_neg (by omega), fiber_gap_empty l c h]
    · rw [if_neg (by omega), fiber_gap_singleton l c hn h]
  · have hf : 0 < fiberCount c k := by omega
    have hfR : (0:ℝ) < (fiberCount c k : ℝ) := by exact_mod_cast hf
    rw [if_pos hge, fiber_gap_eq l c hn hf]
    have hsupp := entropy_le_logb_support
      (r := fun a => (cellCount l c a k : ℝ) / fiberCount c k)
      (fun a => by positivity) (fiber_label_total l c hf)
    have hcard : ((univ.filter
        (fun a => ((cellCount l c a k : ℝ) / fiberCount c k) ≠ 0)).card : ℝ)
        ≤ (fiberCount c k : ℝ) := by
      exact_mod_cast support_card_le_fiberCount l c k hf
    have hmono : Real.logb 2 ((univ.filter
        (fun a => ((cellCount l c a k : ℝ) / fiberCount c k) ≠ 0)).card)
        ≤ Real.logb 2 (fiberCount c k) := by
      rcases Nat.eq_zero_or_pos (univ.filter
          (fun a => ((cellCount l c a k : ℝ) / fiberCount c k) ≠ 0)).card with h0 | h0
      · rw [h0]
        simp only [Nat.cast_zero, Real.logb_zero]
        exact Real.logb_nonneg (by norm_num) (by exact_mod_cast hf)
      · have h0R : (0:ℝ) < ((univ.filter
            (fun a => ((cellCount l c a k : ℝ) / fiberCount c k) ≠ 0)).card : ℝ) := by
          exact_mod_cast h0
        gcongr
        norm_num
    have hw : (0:ℝ) ≤ (fiberCount c k : ℝ) / n := by positivity
    exact mul_le_mul_of_nonneg_left (hsupp.trans hmono) hw

/-- **The fiber-log band.**  The deficit of the reading below the label entropy is at most
`(1/n) ∑ f_k log₂ f_k` over the colliding fibers — a bound with no reference to the size of
the label alphabet. -/
theorem gap_le_fiber_log_sum (l : Fin n → L) (c : Fin n → K) (hn : 0 < n) :
    entropy (margL (viewTable l c)) - mutualInfo (viewTable l c)
      ≤ (∑ k, if 2 ≤ fiberCount c k then (fiberCount c k : ℝ) *
            Real.logb 2 (fiberCount c k) else 0) / n := by
  have hnn : ∀ a k, 0 ≤ viewTable l c a k := viewTable_nonneg l c
  have hgap := mutualInfo_sub_entropy_margL hnn
  have hswap : entropy (margL (viewTable l c)) - mutualInfo (viewTable l c)
      = ∑ k, ∑ a, -(viewTable l c a k *
          Real.logb 2 (viewTable l c a k / margK (viewTable l c) k)) := by
    have h : ∑ k, ∑ a, -(viewTable l c a k *
        Real.logb 2 (viewTable l c a k / margK (viewTable l c) k))
        = -(∑ a, ∑ k, viewTable l c a k *
            Real.logb 2 (viewTable l c a k / margK (viewTable l c) k)) := by
      simp only [Finset.sum_neg_distrib]
      rw [Finset.sum_comm]
    rw [h, ← hgap]
    ring
  rw [hswap, Finset.sum_div]
  refine Finset.sum_le_sum fun k _ => ?_
  refine (fiber_gap_le_log l c k hn).trans (le_of_eq ?_)
  by_cases h : 2 ≤ fiberCount c k
  · rw [if_pos h, if_pos h]
    ring
  · rw [if_neg h, if_neg h, zero_div]

/-- **Pair collisions cost one bit each.**  If no view value is shared by more than two
samples, the deficit is at most the collision fraction — in bits, independent of the label
alphabet. -/
theorem pairwise_collisions_band (l : Fin n → L) (c : Fin n → K) (hn : 0 < n)
    (hpair : ∀ k, fiberCount c k ≤ 2) :
    entropy (margL (viewTable l c)) - mutualInfo (viewTable l c)
      ≤ (collisionCount c : ℝ) / n := by
  refine (gap_le_fiber_log_sum l c hn).trans ?_
  have hterm : ∀ k : K, (if 2 ≤ fiberCount c k then (fiberCount c k : ℝ) *
      Real.logb 2 (fiberCount c k) else 0)
      = (if 2 ≤ fiberCount c k then (fiberCount c k : ℝ) else 0) := by
    intro k
    by_cases h : 2 ≤ fiberCount c k
    · have hf : fiberCount c k = 2 := le_antisymm (hpair k) h
      rw [if_pos h, if_pos h, hf]
      norm_num
    · rw [if_neg h, if_neg h]
  rw [Finset.sum_congr rfl (fun k _ => hterm k), ← Finset.sum_filter, ← Nat.cast_sum,
    ← collisionCount_eq_sum]

/-- **A pair-collision view reads within one bit of the label entropy.**  Whatever the label
alphabet and whatever the dependence between label and view, a view that is injective on
unordered pairs cannot report anything except the label entropy, to within one bit. -/
theorem pair_view_reading_within_one_bit (l : Fin n → L) (c : Fin n → K) (hn : 0 < n)
    (hpair : ∀ k, fiberCount c k ≤ 2) :
    entropy (fun a => (labelCard l a : ℝ) / n) - 1 ≤ mutualInfo (viewTable l c) ∧
    mutualInfo (viewTable l c) ≤ entropy (fun a => (labelCard l a : ℝ) / n) := by
  have hmarg : margL (viewTable l c) = fun a => (labelCard l a : ℝ) / n := by
    funext a; exact margL_viewTable l c a
  have hnR : (0:ℝ) < n := by exact_mod_cast hn
  have hup := mutualInfo_le_entropy_margL (viewTable_nonneg l c)
  have hlow := pairwise_collisions_band l c hn hpair
  rw [hmarg] at hup hlow
  have hcol : (collisionCount c : ℝ) / n ≤ 1 := by
    have : collisionCount c ≤ n := by
      unfold collisionCount
      simpa using Finset.card_filter_le (univ : Finset (Fin n))
        (fun i => 2 ≤ fiberCount c (c i))
    rw [div_le_one hnR]
    exact_mod_cast this
  exact ⟨by linarith, hup⟩

/-- **The whole permutation null of a pair-collision view lives in the same one-bit window.**
Observed and surrogate readings are separated by at most one bit, so no shuffle test on such
a view can resolve more than a bit — whatever the label alphabet. -/
theorem pair_view_null_band (l : Fin n → L) (c : Fin n → K) (hn : 0 < n)
    (hpair : ∀ k, fiberCount c k ≤ 2) (π : Equiv.Perm (Fin n)) :
    |mutualInfo (viewTable (l ∘ π) c) - mutualInfo (viewTable l c)| ≤ 1 := by
  obtain ⟨hlow, hup⟩ := pair_view_reading_within_one_bit l c hn hpair
  obtain ⟨hlowπ, hupπ⟩ := pair_view_reading_within_one_bit (l ∘ π) c hn hpair
  have hent : (fun a => (labelCard (l ∘ π) a : ℝ) / n) = (fun a => (labelCard l a : ℝ) / n) := by
    funext a; rw [labelCard_comp_perm]
  rw [hent] at hlowπ hupπ
  rw [abs_le]
  constructor <;> linarith

end Computation.FactorBlindness