import Mathlib
import MachineLearning.ZeroFitDialFade104
import MachineLearning.ZeroFitDialFadeDichotomy
import MachineLearning.ZeroFitDialNoisePrice

/-!
# The exact monotone noise price of an arbitrary ladder — and why the naive formula is wrong

## Research context (FACT round-68 #2, exp 541, `TDIAL-U104`; fifth cycle)

`MachineLearning.ZeroFitDialNoisePrice` computed, for the seven recorded rungs, the exact per-rung
measurement budget at which the ladder can be read as monotone: `0.0113`, half the bitlen-116
rebound.  The obvious generalisation — *the monotone price of any ladder is half its largest
increase between consecutive rungs* — was recorded as the next-cycle sub-conjecture.

**It is false.**  The obstruction to monotonisation is not local: it is the largest *drop-free
excursion* `r l − r k` over all pairs `k ≤ l`, which can exceed every single increment.  This file
proves the correct statement, exhibits the counterexample that kills the naive one, and recovers
the recorded-ladder price as a corollary of the general theorem.

## Main results

* `ladder_mono_price_necessary` — if some non-increasing `tau` matches `r` to within `eps` on
  `0 … n`, then `r l − r k ≤ 2 eps` for **every** pair `k ≤ l ≤ n`, not merely consecutive ones.
* `flatten` , `flatten_antitone`, `flatten_close` — the *suffix-maximum flattening*
  `tau k = max_{k ≤ j ≤ n} r j − eps`, which is non-increasing by construction and which matches
  `r` to within `eps` exactly when all pair gaps are within `2 eps`.
* `ladder_mono_price` — the resulting **exact characterisation**: a monotone `eps`-reading of a
  ladder exists iff `0 ≤ eps` and `r l − r k ≤ 2 eps` for all `k ≤ l ≤ n`.  The monotone noise
  price is therefore half the largest pairwise excursion.
* `consecutive_price_insufficient` — the counterexample: on `0, 0.01, 0.02` every consecutive
  increase is `0.01`, so the naive formula predicts a price of `0.005`, yet no non-increasing
  ladder comes within `0.005` of all three rungs.  The naive sub-conjecture is refuted.
* `recorded_pair_gaps` — for the recorded T-dial ladder the largest pairwise excursion *is* the
  single consecutive rebound `0.0226`, so the two formulas happen to agree there.
* `recorded_monotone_price_exact` — hence `0.0113` is the exact monotone price of the recorded
  ladder, re-derived from the general theorem rather than from the ad-hoc witness.
-/

open Finset

open Catalog.MachineLearning.ZeroFitDialFade104

open Catalog.MachineLearning.ZeroFitDialFadeDichotomy

namespace Catalog.MachineLearning.ZeroFitDialMonotonePrice

/-! ## 1. Monotone readings within a budget -/

/-- `tau` is non-increasing across the rungs `0 … n`. -/
def LadderMono (n : ℕ) (tau : ℕ → ℚ) : Prop := ∀ k < n, tau (k + 1) ≤ tau k

/-- `tau` matches the ladder `r` to within `eps` on the rungs `0 … n`. -/
def LadderClose (n : ℕ) (eps : ℚ) (r tau : ℕ → ℚ) : Prop := ∀ k ≤ n, |r k - tau k| ≤ eps

/-- A non-increasing ladder is non-increasing across arbitrary gaps, not just single steps. -/
lemma ladderMono_le {n : ℕ} {tau : ℕ → ℚ} (h : LadderMono n tau) :
    ∀ {k l : ℕ}, k ≤ l → l ≤ n → tau l ≤ tau k := by
  intro k l hkl hl
  induction l with
  | zero => simp_all
  | succ l ih =>
      rcases Nat.lt_or_ge k (l + 1) with hk | hk
      · have hkl' : k ≤ l := Nat.lt_succ_iff.1 hk
        have hstep : tau (l + 1) ≤ tau l := h l (by omega)
        exact hstep.trans (ih hkl' (by omega))
      · have : k = l + 1 := le_antisymm hkl hk
        simp [this]

/-- **Necessity, and it is global.**  A monotone `eps`-reading forces every pairwise excursion
`r l − r k` with `k ≤ l` to be at most `2 eps`: the earlier rung is pushed up by `eps` and the
later one pushed down by `eps` until they meet. -/
theorem ladder_mono_price_necessary {n : ℕ} {eps : ℚ} {r tau : ℕ → ℚ}
    (hmono : LadderMono n tau) (hclose : LadderClose n eps r tau)
    {k l : ℕ} (hkl : k ≤ l) (hl : l ≤ n) : r l - r k ≤ 2 * eps := by
  have hk : k ≤ n := hkl.trans hl
  have hbk := abs_le.1 (hclose k hk)
  have hbl := abs_le.1 (hclose l hl)
  have hmon := ladderMono_le hmono hkl hl
  linarith [hbk.1, hbk.2, hbl.1, hbl.2]

/-! ## 2. Sufficiency: the suffix-maximum flattening -/

/-- The suffix-maximum flattening of a ladder, lowered by the budget: the smallest non-increasing
ladder above `r` on `0 … n`, shifted down by `eps`. -/
noncomputable def flatten (n : ℕ) (r : ℕ → ℚ) (eps : ℚ) (k : ℕ) : ℚ :=
  (Finset.Icc (min k n) n).sup' (Finset.nonempty_Icc.2 (min_le_right k n)) r - eps

lemma flatten_antitone (n : ℕ) (r : ℕ → ℚ) (eps : ℚ) : LadderMono n (flatten n r eps) := by
  intro k hk
  have h1 : min k n = k := min_eq_left (le_of_lt hk)
  have h2 : min (k + 1) n = k + 1 := min_eq_left hk
  simp only [flatten, h1, h2]
  have hsub : Finset.Icc (k + 1) n ⊆ Finset.Icc k n := by
    intro x hx
    simp only [Finset.mem_Icc] at hx ⊢
    omega
  have := Finset.sup'_mono r hsub (Finset.nonempty_Icc.2 (by omega : k + 1 ≤ n))
  linarith

lemma flatten_close {n : ℕ} {eps : ℚ} {r : ℕ → ℚ}
    (hgap : ∀ k l : ℕ, k ≤ l → l ≤ n → r l - r k ≤ 2 * eps) :
    LadderClose n eps r (flatten n r eps) := by
  intro k hk
  have hmin : min k n = k := min_eq_left hk
  have hne : (Finset.Icc k n).Nonempty := Finset.nonempty_Icc.2 hk
  have hself : r k ≤ (Finset.Icc k n).sup' hne r :=
    Finset.le_sup' r (Finset.mem_Icc.2 ⟨le_refl k, hk⟩)
  obtain ⟨j, hj, hjeq⟩ := Finset.exists_mem_eq_sup' hne r
  rw [Finset.mem_Icc] at hj
  have hjgap : r j - r k ≤ 2 * eps := hgap k j hj.1 hj.2
  simp only [flatten, hmin]
  rw [abs_le]
  constructor
  · rw [hjeq]; linarith
  · rw [hjeq]; linarith

/-- **Exact characterisation of the monotone noise price.**  A ladder admits a non-increasing
reading within a per-rung budget `eps` if and only if every pairwise excursion is at most `2 eps`
(nonnegativity of `eps` is the diagonal case `k = l`).  The price is therefore half the largest
excursion `r l − r k` over pairs `k ≤ l ≤ n` — a global quantity, not a local one. -/
theorem ladder_mono_price (n : ℕ) (eps : ℚ) (r : ℕ → ℚ) :
    (∃ tau : ℕ → ℚ, LadderMono n tau ∧ LadderClose n eps r tau) ↔
      ∀ k l : ℕ, k ≤ l → l ≤ n → r l - r k ≤ 2 * eps := by
  constructor
  · rintro ⟨tau, hmono, hclose⟩ k l hkl hl
    exact ladder_mono_price_necessary hmono hclose hkl hl
  · intro hgap
    exact ⟨flatten n r eps, flatten_antitone n r eps, flatten_close hgap⟩

/-! ## 3. The naive sub-conjecture is false -/

/-- A three-rung ladder rising in two equal steps of `0.01`. -/
def ramp : ℕ → ℚ := fun k => (k : ℚ) / 100

/-- **Counterexample.**  Every consecutive increase of `ramp` is `0.01`, so the naive rule "price
= half the largest consecutive increase" predicts `0.005`; but no non-increasing ladder matches
all three rungs to within `0.005`, because the pairwise excursion from rung `0` to rung `2` is
`0.02`.  Monotonisation has a *global* obstruction. -/
theorem consecutive_price_insufficient :
    (∀ k < 2, ramp (k + 1) - ramp k = 2 * (1 / 200)) ∧
      ¬ ∃ tau : ℕ → ℚ, LadderMono 2 tau ∧ LadderClose 2 (1 / 200) ramp tau := by
  constructor
  · intro k hk
    interval_cases k <;> norm_num [ramp]
  · rintro ⟨tau, hmono, hclose⟩
    have h := ladder_mono_price_necessary hmono hclose (by norm_num : (0 : ℕ) ≤ 2)
      (le_refl 2)
    norm_num [ramp] at h

/-- The exact price of the ramp is `0.01`, twice what the naive rule predicts. -/
theorem ramp_price_is_one_hundredth :
    (∃ tau : ℕ → ℚ, LadderMono 2 tau ∧ LadderClose 2 (1 / 100) ramp tau) ∧
      ∀ eps : ℚ, (∃ tau : ℕ → ℚ, LadderMono 2 tau ∧ LadderClose 2 eps ramp tau) →
        1 / 100 ≤ eps := by
  constructor
  · refine (ladder_mono_price 2 (1 / 100) ramp).2 ?_
    intro k l hkl hl
    have hk : k ≤ 2 := hkl.trans hl
    interval_cases k <;> interval_cases l <;> norm_num [ramp]
  · intro eps hex
    have h := (ladder_mono_price 2 eps ramp).1 hex 0 2 (by norm_num) (le_refl 2)
    norm_num [ramp] at h
    linarith

/-! ## 4. The recorded ladder, re-derived from the general theorem -/

/-- For the recorded T-dial ladder the largest pairwise excursion is the single rebound
`0.4847 − 0.4621 = 0.0226`; the global and the naive local formula therefore coincide here, which
is why the cycle-4 computation was correct despite the general rule being false. -/
theorem recorded_pair_gaps :
    ∀ k l : ℕ, k ≤ l → l ≤ 6 → recRung l - recRung k ≤ 226 / 10000 := by
  intro k l hkl hl
  have hk : k ≤ 6 := hkl.trans hl
  interval_cases k <;> interval_cases l <;>
    simp only [recRung, rung96, rung100, rung104, rung108, rung112, rung116, rung120] <;>
    norm_num

/-- **The recorded price, from the general theorem.**  `0.0113` is exactly the monotone noise
price of the seven recorded rungs. -/
theorem recorded_monotone_price_exact :
    (∃ tau : ℕ → ℚ, LadderMono 6 tau ∧ LadderClose 6 (113 / 10000) recRung tau) ∧
      ∀ eps : ℚ, (∃ tau : ℕ → ℚ, LadderMono 6 tau ∧ LadderClose 6 eps recRung tau) →
        113 / 10000 ≤ eps := by
  constructor
  · refine (ladder_mono_price 6 (113 / 10000) recRung).2 ?_
    intro k l hkl hl
    have := recorded_pair_gaps k l hkl hl
    linarith
  · intro eps hex
    have h := (ladder_mono_price 6 eps recRung).1 hex 4 5 (by norm_num) (by norm_num)
    simp only [recRung, rung112, rung116] at h
    linarith

end Catalog.MachineLearning.ZeroFitDialMonotonePrice