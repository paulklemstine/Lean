/-
# Robustness of the tropical median: equivariance and the breakdown theorem

`TropicalNormalForm` exhibits the median of `2k+1` samples as the tropical
(max, min)-polynomial `⨆_{|S| = k+1} ⨅_{i ∈ S} x i` and proves the two threshold
dualities.  Here we harvest those dualities to obtain the *quantitative* robustness
theory of that polynomial, at general `k` (the previous file only had the `k = 1`
statements).

## Main results

* `tropMedian_add_const` — tropical homogeneity of degree one at general `k`:
  the median commutes with translation of the whole sample.
* `tropMedian_neg` — self-duality under order reversal at general `k`.
* `tropMedian_nonexpansive` — the median of `2k+1` samples is `1`-Lipschitz for the
  sup-norm.
* `tropMedian_breakdown` — **the breakdown theorem**: if `k + 1` of the `2k + 1`
  samples are clean, the median stays inside the range of the clean samples, no
  matter how the remaining `k` samples are corrupted.  So the finite-sample
  breakdown point of the max-of-mins polynomial is `k / (2k+1) → 1/2`.
* `mean_has_no_breakdown` — the companion refutation: the arithmetic mean has
  breakdown point `0`; a single corrupted coordinate moves it arbitrarily far
  outside the range of the clean data.
* `net48_one_seed_breakdown` — the deployment reading for the NET-48 16× cell:
  whatever a fourth measurement of one seed produces, the three-seed knee median
  stays in `[224, 256]` as long as the other two seeds are the measured ones.

The pair (`tropMedian_breakdown`, `mean_has_no_breakdown`) is the structural reason
behind the empirical slogan of the thread: per-seed knees are noisy point
quantities, but the centre of their distribution is stable.
-/
import Tropical.KneeMedian.TropicalNormalForm

namespace Catalog.Tropical.KneeMedian

open Finset

variable {α : Type*} [LinearOrder α]

/-! ## Equivariance at general `k` -/

section Group

variable {G : Type*} [LinearOrder G] [AddCommGroup G] [IsOrderedAddMonoid G]

/-- **Tropical homogeneity of degree one at general `k`.**  Translating every sample by `t`
translates the median by `t`. -/
theorem tropMedian_add_const {k : ℕ} (x : Fin (2 * k + 1) → G) (t : G) :
    tropMedian (fun i => x i + t) = tropMedian x + t := by
  classical
  have key : ∀ v : G, v ≤ tropMedian (fun i => x i + t) ↔ v ≤ tropMedian x + t := by
    intro v
    rw [le_tropMedian_iff]
    have hiff : ∀ i, (v ≤ x i + t) ↔ (v - t ≤ x i) := fun _ => sub_le_iff_le_add.symm
    simp only [hiff]
    rw [← le_tropMedian_iff]
    exact sub_le_iff_le_add
  exact le_antisymm ((key _).mp le_rfl) ((key _).mpr le_rfl)

/-- **Self-duality under order reversal at general `k`.**  Negating the sample negates the
median: the max-of-mins polynomial and the min-of-maxes polynomial are exchanged by `x ↦ -x`. -/
theorem tropMedian_neg {k : ℕ} (x : Fin (2 * k + 1) → G) :
    tropMedian (fun i => -x i) = -tropMedian x := by
  classical
  have key : ∀ v : G, v ≤ tropMedian (fun i => -x i) ↔ v ≤ -tropMedian x := by
    intro v
    rw [le_tropMedian_iff, le_neg, tropMedian_le_iff]
    have : ∀ i, (v ≤ -x i) ↔ (x i ≤ -v) := fun i => le_neg
    simp only [this]
  exact le_antisymm ((key _).mp le_rfl) ((key _).mpr le_rfl)

/-- **Nonexpansiveness at general `k`.**  If every coordinate moves by at most `d`, the median
moves by at most `d`: the tropical median polynomial is `1`-Lipschitz for the sup-norm. -/
theorem tropMedian_nonexpansive {k : ℕ} (x y : Fin (2 * k + 1) → G) (d : G)
    (h : ∀ i, x i ≤ y i + d ∧ y i ≤ x i + d) :
    tropMedian x ≤ tropMedian y + d ∧ tropMedian y ≤ tropMedian x + d := by
  constructor
  · calc tropMedian x ≤ tropMedian (fun i => y i + d) :=
          tropMedian_mono (fun i => (h i).1)
    _ = tropMedian y + d := tropMedian_add_const _ _
  · calc tropMedian y ≤ tropMedian (fun i => x i + d) :=
          tropMedian_mono (fun i => (h i).2)
    _ = tropMedian x + d := tropMedian_add_const _ _

end Group

/-! ## The breakdown theorem -/

/-- **Breakdown theorem for the tropical median.**  Suppose `k + 1` of the `2k + 1` samples are
clean, i.e. `x` and `y` agree on a set `T` with `k + 1 ≤ T.card`.  Then the median of the
*corrupted* sample `y` still lies between the smallest and the largest clean value — however
wildly the remaining (at most `k`) coordinates are perturbed.

Consequently the finite-sample breakdown point of the max-of-mins polynomial is
`k / (2 * k + 1)`, which tends to `1/2`: no aggregator can do better, since with `k + 1`
corruptions the adversary controls a majority. -/
theorem tropMedian_breakdown {k : ℕ} (x y : Fin (2 * k + 1) → α) (T : Finset (Fin (2 * k + 1)))
    (hT : k + 1 ≤ T.card) (hne : T.Nonempty) (hagree : ∀ i ∈ T, x i = y i) :
    T.inf' hne x ≤ tropMedian y ∧ tropMedian y ≤ T.sup' hne x := by
  classical
  constructor
  · rw [le_tropMedian_iff]
    refine le_trans hT (Finset.card_le_card ?_)
    intro i hi
    refine Finset.mem_filter.mpr ⟨Finset.mem_univ i, ?_⟩
    rw [← hagree i hi]
    exact Finset.inf'_le _ hi
  · rw [tropMedian_le_iff]
    refine le_trans hT (Finset.card_le_card ?_)
    intro i hi
    refine Finset.mem_filter.mpr ⟨Finset.mem_univ i, ?_⟩
    rw [← hagree i hi]
    exact Finset.le_sup' _ hi

/-- The three-seed instance of the breakdown theorem: if two of three seeds are clean, the
median of the three reported knees lies between them. -/
theorem tropMed3_breakdown (a b c' : α) :
    min a b ≤ tropMed3 a b c' ∧ tropMed3 a b c' ≤ max a b := by
  constructor
  · exact le_max_left _ _
  · refine max_le (le_trans (min_le_left a b) (le_max_left _ _)) (max_le ?_ ?_)
    · exact le_trans (min_le_left b c') (le_max_right _ _)
    · exact le_trans (min_le_left a c') (le_max_left _ _)

/-- **The mean has breakdown point zero.**  With the same clean data (`x = 0` on a majority
`{0, 1}` of the three coordinates), the arithmetic mean of the corrupted sample exceeds any
prescribed bound, while by `tropMedian_breakdown` the median cannot leave `{0}`.  This is the
sharp companion to `tropMedian_breakdown`: robustness is a property of the *tropical*
aggregator, not of centrality per se. -/
theorem mean_has_no_breakdown (B : ℝ) :
    ∃ y : Fin 3 → ℝ, (∀ i ∈ ({0, 1} : Finset (Fin 3)), y i = 0) ∧
      tropMedian (k := 1) y = 0 ∧ B < (y 0 + y 1 + y 2) / 3 := by
  refine ⟨![0, 0, 3 * (|B| + 1)], ?_, ?_, ?_⟩
  · intro i hi
    fin_cases hi <;> simp
  · have hM : (0 : ℝ) ≤ 3 * (|B| + 1) := by positivity
    rw [show (![0, 0, 3 * (|B| + 1)] : Fin 3 → ℝ) = ![(0 : ℝ), 0, 3 * (|B| + 1)] from rfl,
      tropMedian_three]
    simp [tropMed3, hM]
  · have h1 : B ≤ |B| := le_abs_self B
    have h0 : (![0, 0, 3 * (|B| + 1)] : Fin 3 → ℝ) 0 = 0 := rfl
    have h1' : (![0, 0, 3 * (|B| + 1)] : Fin 3 → ℝ) 1 = 0 := rfl
    have h2 : (![0, 0, 3 * (|B| + 1)] : Fin 3 → ℝ) 2 = 3 * (|B| + 1) := rfl
    rw [h0, h1', h2]
    linarith

/-! ## The NET-48 deployment reading -/

/-- **One-seed breakdown at the 16× cell.**  The measured 16× knees are `{256, 224, 160}`.
If a re-run replaces the third seed's knee by an arbitrary value `t`, the three-seed median
still lies in `[224, 256]` — the range of the two seeds that were left alone.  So no single
seed, however anomalous, can move the reported centre outside the interval spanned by the
other two: the `7/8` median law is protected against one-seed failure. -/
theorem net48_one_seed_breakdown (t : ℚ) :
    (224 : ℚ) ≤ tropMedian (k := 1) ![256, 224, t] ∧
      tropMedian (k := 1) ![256, 224, t] ≤ 256 := by
  have h := tropMed3_breakdown (α := ℚ) 256 224 t
  rw [show (![256, 224, t] : Fin 3 → ℚ) = ![(256 : ℚ), 224, t] from rfl, tropMedian_three]
  constructor
  · exact le_trans (by norm_num) h.1
  · exact le_trans h.2 (by norm_num)

end Catalog.Tropical.KneeMedian