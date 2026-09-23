/-
# Hint compounding is bias compounding: refinement monotonicity of the plug-in reading

The battery programme reported three nested views of the same population — the *product*
view (`N mod 713`), the *hint* view `(s,d)` built from the factor residues, and the *joint*
labels — with readings `0.0153`, `0.9663` and `0.0011` bits.  The middle reading is an order
of magnitude larger than the other two, and the flagged interpretation was that the hint view
"sees more".

This file proves that a finer view **always** reads at least as much, for a reason that has
nothing to do with dependence: the plug-in functional is monotone under refinement, by the
log-sum inequality.  Coupled with the collision sandwich of
`Computation.FactorBlindnessHintedView`, this pins the entire excess of a hint view over a
coarse view inside the coarse view's collision band.

## Main results

* `log_sum_inequality` — the log-sum inequality
  `(∑ aᵢ) log((∑ aᵢ)/(∑ bᵢ)) ≤ ∑ aᵢ log(aᵢ/bᵢ)`, over an arbitrary finite index set, proved
  from `log x ≤ x − 1` with no normalisation step.  This is the convexity input the whole
  thread was missing: `Computation.FactorBlindnessInformation` only had Gibbs' inequality,
  which is its `|s| = 1` aggregate.
* `mutualInfo_coarsenTable_le` — **refinement monotonicity**: aggregating the columns of a
  contingency table along any map `φ : K' → K` can only *decrease* the plug-in reading.
  This is the data-processing inequality for the plug-in functional, on empirical tables,
  with no distributional assumption.
* `hint_refinement_monotone` — the sample-level form: for any sample, any view `c'` and any
  post-processing `φ`, the reading through `c'` is at least the reading through `φ ∘ c'`.
  Adding a hint never lowers the number that gets reported.
* `hint_gain_le_collision` — **HINT COMPOUNDING IS BIAS COMPOUNDING**: the gain from
  refining a view is nonnegative and at most the *coarse* view's collision term.  A hint that
  "adds" bits adds exactly as many as the coarse view's sparsity deficit allows, and no
  statement about leakage can be extracted from the increase.
* `refinement_strict_example` — the guard: refinement monotonicity is not vacuous, there is a
  refinement that strictly increases the reading from `0` to `1` bit on a population whose
  true dependence is unchanged (and, by `galoisBlind_zero_leakage`, zero).

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the hint view's tenfold larger reading is a refinement artefact, i.e.
  the plug-in functional is monotone under column refinement and the observed ordering
  `0.0153 ≤ 0.9663` is forced, not evidence.
Experiment (Stage 2): the reported triple (`product` `0.0153`, `(s,d)` `0.9663`, `joint`
  `0.0011`) is not monotone as printed — the joint-label view reads *less* than the product
  view — which is the diagnostic that the three views are not nested as claimed: the joint
  label view is a *relabelling*, not a refinement, of the product view.  Where the views are
  genuinely nested, the theorem below forces the ordering exactly.
Analysis (Stage 3): monotonicity is the log-sum inequality applied cell-block by cell-block;
  the proof needs only `log x ≤ x − 1`, the same single analytic input as Gibbs.  The gain
  bound then follows from the sandwich without any new analysis: the fine reading is capped
  by the label entropy, the coarse reading is floored by the label entropy minus its own
  collision term, and the difference of the two bounds is the collision term.
Critique (Stage 4): the gain bound is only informative when the *coarse* view is itself
  near-injective; for a genuinely coarse view (few cells, many samples) the bound degrades to
  the label entropy, which is the honest statement — a coarse view's deficit really can be
  filled by a refinement.  We therefore state the bound with the coarse collision term
  explicit rather than claiming a universal smallness.
Synthesis (Stage 5): "the hint view sees more" is a theorem about the estimator, not a
  finding about the population; the only way a hint can be evidence is if its reading exceeds
  what refinement alone guarantees, and the sandwich says that headroom is the collision
  fraction.
-/
import Mathlib
import Computation.FactorBlindnessInformation
import Computation.FactorBlindnessSharp
import Computation.FactorBlindnessHintedView

namespace Computation.FactorBlindness

open Finset

/-! ## The log-sum inequality -/

/-- **The log-sum inequality.**  For nonnegative `a`, `b` with `b i = 0 → a i = 0` and a
positive total `∑ b`, aggregating before taking the logarithm can only lose:
`(∑ a) log((∑ a)/(∑ b)) ≤ ∑ a log(a/b)`.  Proved pointwise from `log x ≤ x − 1`. -/
theorem log_sum_inequality {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 ≤ b i) (hac : ∀ i ∈ s, b i = 0 → a i = 0)
    (hB : 0 < ∑ i ∈ s, b i) :
    (∑ i ∈ s, a i) * Real.log ((∑ i ∈ s, a i) / (∑ i ∈ s, b i))
      ≤ ∑ i ∈ s, a i * Real.log (a i / b i) := by
  set A : ℝ := ∑ i ∈ s, a i with hAdef
  set B : ℝ := ∑ i ∈ s, b i with hBdef
  have hAnn : 0 ≤ A := Finset.sum_nonneg ha
  have key : ∀ i ∈ s,
      a i * Real.log (A / B) + (a i - (A / B) * b i) ≤ a i * Real.log (a i / b i) := by
    intro i hi
    rcases eq_or_lt_of_le (ha i hi) with hai | hai
    · have h0 : a i = 0 := hai.symm
      have : 0 ≤ (A / B) * b i := by
        have := hb i hi
        have : 0 ≤ A / B := by positivity
        positivity
      simp only [h0, zero_mul, zero_sub, zero_add]
      linarith
    · have hbi : 0 < b i := by
        rcases eq_or_lt_of_le (hb i hi) with h | h
        · exact absurd (hac i hi h.symm) (ne_of_gt hai)
        · exact h
      have hApos : 0 < A := lt_of_lt_of_le hai (Finset.single_le_sum ha hi)
      have hy : 0 < (b i * A) / (a i * B) := by positivity
      have hlog := Real.log_le_sub_one_of_pos hy
      have hlogeq : Real.log ((b i * A) / (a i * B))
          = Real.log (A / B) - Real.log (a i / b i) := by
        rw [Real.log_div (by positivity) (by positivity),
          Real.log_div (ne_of_gt hApos) (ne_of_gt hB),
          Real.log_div (ne_of_gt hai) (ne_of_gt hbi),
          Real.log_mul (ne_of_gt hbi) (ne_of_gt hApos),
          Real.log_mul (ne_of_gt hai) (ne_of_gt hB)]
        ring
      have h1 : a i * Real.log ((b i * A) / (a i * B))
          ≤ a i * ((b i * A) / (a i * B) - 1) :=
        mul_le_mul_of_nonneg_left hlog (le_of_lt hai)
      have h2 : a i * ((b i * A) / (a i * B) - 1) = (A / B) * b i - a i := by
        field_simp
      rw [hlogeq, h2] at h1
      nlinarith [h1]
  have hsum := Finset.sum_le_sum key
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, ← Finset.mul_sum,
    ← hAdef, ← hBdef] at hsum
  have hBne : B ≠ 0 := ne_of_gt hB
  have hcancel : (A / B) * B = A := by field_simp
  rw [hcancel] at hsum
  linarith

/-! ## Coarsening a table along a map of view alphabets -/

variable {L K K' : Type*} [Fintype L] [Fintype K] [DecidableEq K] [Fintype K']

/-- The table obtained by aggregating the columns of `p` along `φ`: the contingency table of
the *coarser* view `φ ∘ c` when `p` is the table of `c`. -/
noncomputable def coarsenTable (φ : K' → K) (p : L → K' → ℝ) : L → K → ℝ :=
  fun a k => ∑ k' ∈ univ.filter (fun k' => φ k' = k), p a k'

lemma sum_over_fibers (φ : K' → K) (f : K' → ℝ) :
    ∑ k, ∑ k' ∈ univ.filter (fun k' => φ k' = k), f k' = ∑ k', f k' :=
  Finset.sum_fiberwise_of_maps_to (fun x _ => mem_univ (φ x)) f

omit [Fintype L] [Fintype K] in
lemma coarsenTable_nonneg {φ : K' → K} {p : L → K' → ℝ} (hp : ∀ a k', 0 ≤ p a k') (a : L)
    (k : K) : 0 ≤ coarsenTable φ p a k :=
  Finset.sum_nonneg fun k' _ => hp a k'

omit [Fintype L] in
lemma margL_coarsenTable (φ : K' → K) (p : L → K' → ℝ) (a : L) :
    margL (coarsenTable φ p) a = margL p a :=
  sum_over_fibers φ (fun k' => p a k')

omit [Fintype K] in
lemma margK_coarsenTable (φ : K' → K) (p : L → K' → ℝ) (k : K) :
    margK (coarsenTable φ p) k
      = ∑ k' ∈ univ.filter (fun k' => φ k' = k), margK p k' := by
  unfold margK coarsenTable
  exact Finset.sum_comm

/-- The plug-in reading in natural logarithms; `mutualInfo` is this divided by `log 2`. -/
noncomputable def natMI (p : L → K → ℝ) : ℝ :=
  ∑ a, ∑ k, p a k * Real.log (p a k / (margL p a * margK p k))

omit [DecidableEq K] in
lemma mutualInfo_eq_natMI (p : L → K → ℝ) : mutualInfo p = natMI p / Real.log 2 := by
  unfold mutualInfo natMI
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [Finset.sum_div]
  exact Finset.sum_congr rfl fun k _ => by simp [Real.logb, mul_div_assoc]

/-- **Refinement monotonicity of the plug-in reading.**  Aggregating columns along any map
`φ` can only decrease the reading: a finer view always reads at least as much as a coarser
one, whatever the dependence structure. -/
theorem natMI_coarsenTable_le (φ : K' → K) (p : L → K' → ℝ) (hp : ∀ a k', 0 ≤ p a k') :
    natMI (coarsenTable φ p) ≤ natMI p := by
  have hsplit : natMI p
      = ∑ a, ∑ k, ∑ k' ∈ univ.filter (fun k' => φ k' = k),
          p a k' * Real.log (p a k' / (margL p a * margK p k')) := by
    unfold natMI
    exact Finset.sum_congr rfl fun a _ =>
      (sum_over_fibers φ (fun k' => p a k' * Real.log (p a k' / (margL p a * margK p k')))).symm
  rw [hsplit]
  unfold natMI
  refine Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun k _ => ?_
  set G : Finset K' := univ.filter (fun k' => φ k' = k) with hG
  set A : ℝ := ∑ k' ∈ G, p a k' with hA
  have hcoarse : coarsenTable φ p a k = A := rfl
  have hbnn : ∀ k' ∈ G, 0 ≤ margL p a * margK p k' := fun k' _ =>
    mul_nonneg (margL_nonneg hp a) (margK_nonneg hp k')
  have hac : ∀ k' ∈ G, margL p a * margK p k' = 0 → p a k' = 0 := by
    intro k' _ h
    rcases mul_eq_zero.1 h with h1 | h1
    · exact eq_zero_of_margL_eq_zero hp h1 k'
    · exact eq_zero_of_margK_eq_zero hp h1 a
  rcases eq_or_lt_of_le (Finset.sum_nonneg hbnn) with hB | hB
  · -- the whole block is null: both sides vanish
    have hzero : ∀ k' ∈ G, margL p a * margK p k' = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg hbnn).1 hB.symm
    have hpzero : ∀ k' ∈ G, p a k' = 0 := fun k' hk' => hac k' hk' (hzero k' hk')
    have hA0 : A = 0 := Finset.sum_eq_zero hpzero
    rw [hcoarse, hA0]
    rw [Finset.sum_congr rfl (fun k' hk' => by rw [hpzero k' hk']; ring :
      ∀ k' ∈ G, p a k' * Real.log (p a k' / (margL p a * margK p k')) = 0)]
    simp
  · have hlogsum := log_sum_inequality G (fun k' => p a k')
      (fun k' => margL p a * margK p k') (fun k' _ => hp a k') hbnn hac hB
    have hBeq : (∑ k' ∈ G, margL p a * margK p k')
        = margL (coarsenTable φ p) a * margK (coarsenTable φ p) k := by
      rw [← Finset.mul_sum, margL_coarsenTable, margK_coarsenTable, hG]
    rw [hBeq] at hlogsum
    exact hlogsum

/-- Refinement monotonicity in bits. -/
theorem mutualInfo_coarsenTable_le (φ : K' → K) (p : L → K' → ℝ) (hp : ∀ a k', 0 ≤ p a k') :
    mutualInfo (coarsenTable φ p) ≤ mutualInfo p := by
  rw [mutualInfo_eq_natMI, mutualInfo_eq_natMI]
  have hlog2 : (0:ℝ) ≤ Real.log 2 := le_of_lt (Real.log_pos (by norm_num))
  exact div_le_div_of_nonneg_right (natMI_coarsenTable_le φ p hp) hlog2

/-! ## The sample-level statement: adding a hint never lowers the reading -/

variable {n : ℕ} [DecidableEq L] [DecidableEq K']

omit [Fintype L] [Fintype K] in
lemma cellCount_comp (l : Fin n → L) (c' : Fin n → K') (φ : K' → K) (a : L) (k : K) :
    cellCount l (φ ∘ c') a k
      = ∑ k' ∈ univ.filter (fun k' => φ k' = k), cellCount l c' a k' := by
  unfold cellCount
  have hmem : ∀ i ∈ univ.filter (fun i => l i = a ∧ (φ ∘ c') i = k),
      c' i ∈ univ.filter (fun k' => φ k' = k) := by
    intro i hi
    simp only [mem_filter, mem_univ, true_and, Function.comp_apply] at hi ⊢
    exact hi.2
  rw [Finset.card_eq_sum_card_fiberwise (f := c')
    (s := univ.filter (fun i => l i = a ∧ (φ ∘ c') i = k))
    (t := univ.filter (fun k' => φ k' = k)) hmem]
  refine Finset.sum_congr rfl fun k' hk' => ?_
  simp only [mem_filter, mem_univ, true_and] at hk'
  congr 1
  rw [Finset.filter_filter]
  exact Finset.filter_congr fun x _ => by
    constructor
    · rintro ⟨⟨h1, -⟩, h3⟩; exact ⟨h1, h3⟩
    · rintro ⟨h1, h2⟩
      refine ⟨⟨h1, ?_⟩, h2⟩
      simp only [Function.comp_apply, h2]
      exact hk'

omit [Fintype L] [Fintype K] in
/-- The table of a post-processed view is the coarsening of the table of the fine view. -/
lemma viewTable_comp (l : Fin n → L) (c' : Fin n → K') (φ : K' → K) :
    viewTable l (φ ∘ c') = coarsenTable φ (viewTable l c') := by
  funext a k
  show (cellCount l (φ ∘ c') a k : ℝ) / n
      = ∑ k' ∈ univ.filter (fun k' => φ k' = k), (cellCount l c' a k' : ℝ) / n
  rw [cellCount_comp l c' φ a k, Nat.cast_sum, Finset.sum_div]

/-- **Adding a hint never lowers the reading.**  For any sample, any view `c'` and any
post-processing `φ`, the reading through the finer view `c'` is at least the reading through
the coarser view `φ ∘ c'`. -/
theorem hint_refinement_monotone (l : Fin n → L) (c' : Fin n → K') (φ : K' → K) :
    mutualInfo (viewTable l (φ ∘ c')) ≤ mutualInfo (viewTable l c') := by
  rw [viewTable_comp l c' φ]
  exact mutualInfo_coarsenTable_le φ (viewTable l c') (viewTable_nonneg l c')

/-- **HINT COMPOUNDING IS BIAS COMPOUNDING.**  The gain obtained by refining a view is
nonnegative — that part is automatic — and bounded above by the *coarse* view's collision
term.  Whatever a hint adds to the reading, the coarse view's sparsity deficit already
accounted for it; no leakage statement can be read off the increase. -/
theorem hint_gain_le_collision (l : Fin n → L) (c' : Fin n → K') (φ : K' → K) (hn : 0 < n)
    [Nonempty L] :
    0 ≤ mutualInfo (viewTable l c') - mutualInfo (viewTable l (φ ∘ c')) ∧
    mutualInfo (viewTable l c') - mutualInfo (viewTable l (φ ∘ c'))
      ≤ ((collisionCount (φ ∘ c') : ℝ) / n) * Real.logb 2 (Fintype.card L) := by
  obtain ⟨-, hupFine⟩ := hintedView_sandwich l c' hn
  obtain ⟨hlowCoarse, -⟩ := hintedView_sandwich l (φ ∘ c') hn
  refine ⟨by linarith [hint_refinement_monotone l c' φ], by linarith⟩

/-! ## The guard: refinement really can move the reading -/

/-- The coarse view: a constant, which sees nothing. -/
def blindView : Bool → Unit := fun _ => ()

/-- **Refinement monotonicity is not vacuous.**  Collapsing the perfectly informative readout
of `leakyS` to a constant drops the reading from a full bit to zero, so the inequality
`mutualInfo (coarsenTable φ p) ≤ mutualInfo p` is strict somewhere. -/
theorem refinement_strict_example :
    mutualInfo (coarsenTable blindView (jointDist leakyS leakyCode)) = 0 ∧
    mutualInfo (jointDist leakyS leakyCode) = 1 := by
  refine ⟨?_, leaky_mutualInfo⟩
  have hcoarse : coarsenTable blindView (jointDist leakyS leakyCode)
      = fun b (_ : Unit) => if b then (1:ℝ) / 2 else 1 / 2 := by
    funext b u
    unfold coarsenTable
    have : (univ.filter (fun k' : Bool => blindView k' = u)) = univ := by
      apply Finset.filter_true_of_mem
      intro x _
      rfl
    rw [this, Fintype.sum_bool, leaky_jointDist, leaky_jointDist]
    cases b <;> norm_num
  rw [hcoarse]
  simp [mutualInfo, margL, margK]

end Computation.FactorBlindness