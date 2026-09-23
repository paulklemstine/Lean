/-
# The hinted view is blind too: the collision sandwich and the powerlessness of the null

The thread `Computation.FactorBlindnessWall` → `…Sharp` → `…Sparse` proved that a symmetric
(Galois-invariant) readout leaks *exactly* zero which-factor bits, that a zero plug-in reading
is exactly independence, and that in the **fully injective** sparse limit the plug-in reading
equals the label entropy and its permutation null is a point mass.

The experiment this file formalises tested the *strongest* view of the battery programme — the
factor-residue hint view, whose which-factor reading was flagged at `0.9663` bits — against a
200-shuffle permutation null, and found the null mean at `0.9648` with sd `0.0011`
(`z = +1.36`).  The verdict: the entire reading is sparse plug-in inflation.

What was missing from `…Sparse` is exactly the regime the real data lives in: views that are
*almost*, but not exactly, injective.  Its own Stage-4 critique says so — "with collisions the
reading is only bounded by `H(ℓ)`, and the null acquires a small spread".  This file closes
that gap quantitatively, for an arbitrary finite label alphabet (not just a binary
which-factor bit).

## Main results

Fix a sample of size `n`, a label `l : Fin n → L` and a view `c : Fin n → K`, and let
`ε = (collisionCount c / n) · log₂ |L|`, where `collisionCount c` counts the samples that
share their view value with some other sample.

* `hintedView_sandwich` — **the collision sandwich**:
  `H(ℓ) − ε ≤ Î(l, c) ≤ H(ℓ)`.
  The reading is pinned to the label entropy to within the collision fraction; it is *not* a
  measurement of dependence, it is a measurement of how sparse the view is.
* `injective_view_reading_eq_label_entropy` — at zero collisions the sandwich collapses:
  the reading **is** the label entropy, for any relationship whatsoever between `l` and `c`.
* `hintedView_null_band` — every label-permuted surrogate reads within `ε` of the observed
  value, because permutation preserves both the label counts and the view's fiber sizes.
* `hintedView_null_range` — hence the *whole permutation null* is contained in an interval of
  width `ε`: the null's spread, the observed-minus-null gap and therefore the numerator of
  any z-score are all bounded by the same `ε`.
* `hintedView_z_numerator_le` — the averaged statement: `|observed − null mean| ≤ ε`.
* `collisionCount_le_two_mul_excess` — `collisionCount c ≤ 2 · (n − d)` where `d` is the
  number of *distinct* view values realised, so `ε` is estimable straight from the data.
* `hintedView_test_is_powerless` — the capstone: for a view whose collision fraction is
  `≤ δ / log₂|L|`, observed reading, null mean and every surrogate all sit inside a common
  interval of width `δ`.  A permutation test on such a view cannot resolve *anything*: it is
  blind by construction, whatever the true leakage is.

Read against `battery4_zero_leakage` (true leakage exactly `0`) and
`mutualInfo_eq_zero_iff_product` (a zero reading is exactly independence), this says the
`0.9663`-bit hint-view reading was never evidence of leakage: the same sandwich holds for a
sample drawn from a population with exactly zero dependence.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the flagged hint-view reading is not merely *close* to its null mean by
  numerical accident; observed and null are *forced* into a common interval whose width is the
  view's collision fraction, so a near-injective view makes the permutation test vacuous.
Experiment (Stage 2, `ComputationalEvidence.md`): 3995 ordered prime pairs, 3597 distinct
  four-field codes; observed `0.8985` bits, null mean `0.8996`, sd `0.0046`.  The theorem
  predicts `collisionCount ≤ 2·(3995 − 3597) = 796`, i.e. every reading — observed and all 200
  surrogates — inside `[1 − 0.1993, 1]`; measured spread of the observed-null gap: `0.0011`,
  three orders of magnitude below the guaranteed band, as the bound is worst-case.
Analysis (Stage 3): the gap `H(ℓ) − Î` is the conditional entropy of the label given the view,
  and a *singleton fiber contributes exactly zero* to it.  Only colliding samples can produce
  a gap, and each contributes at most `log₂|L|` bits of its `1/n` weight.  Permutation moves
  labels but not fibers, so it moves the reading only inside that same band.
Critique (Stage 4): the bound is one-sided worst case and cannot be improved without
  distributional assumptions — a view with a single fiber of size `n` achieves
  `collisionCount = n` and gap `H(ℓ)`, so `ε` cannot be shrunk in general
  (`collision_bound_is_attained`).  The `log₂|L|` factor is likewise attained at a balanced
  label margin.  We therefore state the sandwich, not a sharper asymptotic.
Synthesis (Stage 5): sparsity is a *hard ceiling on the resolution of a permutation test*, not
  a nuisance bias.  A view fine enough to be interesting is automatically fine enough to be
  untestable by shuffling, and the battery programme's factor-blindness survives on its
  strongest view for a structural reason rather than a numerical one.
-/
import Mathlib
import Computation.FactorBlindnessInformation
import Computation.FactorBlindnessSharp

namespace Computation.FactorBlindness

open Finset

variable {n : ℕ} {L K : Type*} [Fintype L] [DecidableEq L] [Fintype K] [DecidableEq K]

/-! ## Empirical counts of a labelled sample seen through a view -/

/-- Number of samples with label `a` and view value `k`. -/
def cellCount (l : Fin n → L) (c : Fin n → K) (a : L) (k : K) : ℕ :=
  (univ.filter (fun i => l i = a ∧ c i = k)).card

/-- Number of samples whose view value is `k` (the size of the fiber over `k`). -/
def fiberCount (c : Fin n → K) (k : K) : ℕ := (univ.filter (fun i => c i = k)).card

/-- Number of samples carrying label `a`. -/
def labelCard (l : Fin n → L) (a : L) : ℕ := (univ.filter (fun i => l i = a)).card

/-- The empirical (label, view) contingency table. -/
noncomputable def viewTable (l : Fin n → L) (c : Fin n → K) : L → K → ℝ :=
  fun a k => (cellCount l c a k : ℝ) / n

/-- The number of **colliding samples**: those sharing their view value with another sample. -/
def collisionCount (c : Fin n → K) : ℕ :=
  (univ.filter (fun i => 2 ≤ fiberCount c (c i))).card

omit [Fintype L] [Fintype K] in
lemma viewTable_nonneg (l : Fin n → L) (c : Fin n → K) (a : L) (k : K) :
    0 ≤ viewTable l c a k := by
  unfold viewTable; positivity

omit [Fintype L] in
lemma sum_cellCount_over_code (l : Fin n → L) (c : Fin n → K) (a : L) :
    ∑ k, cellCount l c a k = labelCard l a := by
  unfold cellCount labelCard
  rw [Finset.card_eq_sum_card_fiberwise
    (f := c) (s := univ.filter (fun i => l i = a)) (t := univ) (fun x _ => mem_univ (c x))]
  refine Finset.sum_congr rfl fun k _ => ?_
  congr 1
  rw [Finset.filter_filter]

omit [Fintype K] in
lemma sum_cellCount_over_label (l : Fin n → L) (c : Fin n → K) (k : K) :
    ∑ a, cellCount l c a k = fiberCount c k := by
  unfold cellCount fiberCount
  rw [Finset.card_eq_sum_card_fiberwise
    (f := l) (s := univ.filter (fun i => c i = k)) (t := univ) (fun x _ => mem_univ (l x))]
  refine Finset.sum_congr rfl fun a _ => ?_
  congr 1
  rw [Finset.filter_filter]
  exact Finset.filter_congr fun x _ => by constructor <;> (rintro ⟨h1, h2⟩; exact ⟨h2, h1⟩)

lemma sum_fiberCount (c : Fin n → K) : ∑ k, fiberCount c k = n := by
  unfold fiberCount
  rw [← Finset.card_eq_sum_card_fiberwise (f := c) (s := univ) (t := univ)
    (fun x _ => mem_univ (c x))]
  simp

omit [Fintype L] [Fintype K] in
lemma cellCount_le_fiberCount (l : Fin n → L) (c : Fin n → K) (a : L) (k : K) :
    cellCount l c a k ≤ fiberCount c k := by
  unfold cellCount fiberCount
  refine Finset.card_le_card fun x hx => ?_
  simp only [mem_filter, mem_univ, true_and] at hx ⊢
  exact hx.2

omit [Fintype L] in
lemma margL_viewTable (l : Fin n → L) (c : Fin n → K) (a : L) :
    margL (viewTable l c) a = (labelCard l a : ℝ) / n := by
  unfold margL viewTable
  rw [← Finset.sum_div, ← Nat.cast_sum, sum_cellCount_over_code]

omit [Fintype K] in
lemma margK_viewTable (l : Fin n → L) (c : Fin n → K) (k : K) :
    margK (viewTable l c) k = (fiberCount c k : ℝ) / n := by
  unfold margK viewTable
  rw [← Finset.sum_div, ← Nat.cast_sum, sum_cellCount_over_label]

/-! ## The per-fiber decomposition of the gap -/

omit [Fintype K] in
/-- Within one fiber the gap term is the fiber's weight times the entropy of the label
distribution inside that fiber. -/
lemma fiber_gap_eq (l : Fin n → L) (c : Fin n → K) {k : K} (hn : 0 < n)
    (hf : 0 < fiberCount c k) :
    ∑ a, -(viewTable l c a k *
        Real.logb 2 (viewTable l c a k / margK (viewTable l c) k))
      = ((fiberCount c k : ℝ) / n) *
          entropy (fun a => (cellCount l c a k : ℝ) / fiberCount c k) := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hfR : (0 : ℝ) < (fiberCount c k : ℝ) := by exact_mod_cast hf
  unfold entropy
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [margK_viewTable]
  have hdiv : viewTable l c a k / ((fiberCount c k : ℝ) / n)
      = (cellCount l c a k : ℝ) / fiberCount c k := by
    unfold viewTable
    field_simp
  rw [hdiv]
  have hp : viewTable l c a k
      = ((fiberCount c k : ℝ) / n) * ((cellCount l c a k : ℝ) / fiberCount c k) := by
    unfold viewTable
    field_simp
  rw [hp]
  ring

omit [DecidableEq L] in
/-- A `0/1`-valued mass function has zero entropy. -/
lemma entropy_eq_zero_of_indicator {r : L → ℝ} (h : ∀ a, r a = 0 ∨ r a = 1) :
    entropy r = 0 := by
  unfold entropy
  refine Finset.sum_eq_zero fun a _ => ?_
  rcases h a with h0 | h1
  · simp [h0]
  · simp [h1]

omit [Fintype K] in
/-- The label distribution inside a fiber is a probability vector. -/
lemma fiber_label_total (l : Fin n → L) (c : Fin n → K) {k : K} (hf : 0 < fiberCount c k) :
    ∑ a, ((cellCount l c a k : ℝ) / fiberCount c k) = 1 := by
  have hfR : (0 : ℝ) < (fiberCount c k : ℝ) := by exact_mod_cast hf
  rw [← Finset.sum_div, ← Nat.cast_sum, sum_cellCount_over_label]
  field_simp

omit [Fintype K] in
/-- **Singleton fibers contribute nothing.**  A sample that owns its view value alone adds
exactly `0` to the gap between the label entropy and the reading. -/
lemma fiber_gap_singleton (l : Fin n → L) (c : Fin n → K) {k : K} (hn : 0 < n)
    (hf : fiberCount c k = 1) :
    ∑ a, -(viewTable l c a k *
        Real.logb 2 (viewTable l c a k / margK (viewTable l c) k)) = 0 := by
  rw [fiber_gap_eq l c hn (by omega)]
  rw [entropy_eq_zero_of_indicator (r := fun a => (cellCount l c a k : ℝ) / fiberCount c k)
    (fun a => ?_), mul_zero]
  have hle := cellCount_le_fiberCount l c a k
  rw [hf] at hle ⊢
  interval_cases h : cellCount l c a k
  · left; simp [h]
  · right; simp [h]

omit [Fintype K] in
/-- An empty fiber contributes nothing. -/
lemma fiber_gap_empty (l : Fin n → L) (c : Fin n → K) {k : K} (hf : fiberCount c k = 0) :
    ∑ a, -(viewTable l c a k *
        Real.logb 2 (viewTable l c a k / margK (viewTable l c) k)) = 0 := by
  refine Finset.sum_eq_zero fun a _ => ?_
  have h0 : cellCount l c a k = 0 := Nat.le_zero.1 (hf ▸ cellCount_le_fiberCount l c a k)
  simp [viewTable, h0]

omit [Fintype K] in
/-- Each fiber contributes at most its weight times `log₂ |L|`, and only colliding fibers
contribute at all. -/
lemma fiber_gap_le (l : Fin n → L) (c : Fin n → K) (k : K) (hn : 0 < n) [Nonempty L] :
    ∑ a, -(viewTable l c a k *
        Real.logb 2 (viewTable l c a k / margK (viewTable l c) k))
      ≤ (if 2 ≤ fiberCount c k then ((fiberCount c k : ℝ) / n) *
            Real.logb 2 (Fintype.card L) else 0) := by
  rcases Nat.lt_or_ge (fiberCount c k) 2 with hlt | hge
  · interval_cases h : fiberCount c k
    · rw [if_neg (by omega), fiber_gap_empty l c h]
    · rw [if_neg (by omega), fiber_gap_singleton l c hn h]
  · rw [if_pos hge, fiber_gap_eq l c hn (by omega)]
    have hbound := entropy_le_logb_card
      (r := fun a => (cellCount l c a k : ℝ) / fiberCount c k)
      (fun a => by positivity) (fiber_label_total l c (by omega))
    have hw : (0:ℝ) ≤ (fiberCount c k : ℝ) / n := by positivity
    exact mul_le_mul_of_nonneg_left hbound hw

/-! ## The collision count and the total gap -/

lemma collisionCount_eq_sum (c : Fin n → K) :
    collisionCount c = ∑ k ∈ univ.filter (fun k => 2 ≤ fiberCount c k), fiberCount c k := by
  have hmem : ∀ x ∈ univ.filter (fun i => 2 ≤ fiberCount c (c i)),
      c x ∈ univ.filter (fun k => 2 ≤ fiberCount c k) := by
    intro x hx
    simp only [mem_filter, mem_univ, true_and] at hx ⊢
    exact hx
  unfold collisionCount
  rw [Finset.card_eq_sum_card_fiberwise (f := c)
    (s := univ.filter (fun i => 2 ≤ fiberCount c (c i)))
    (t := univ.filter (fun k => 2 ≤ fiberCount c k)) hmem]
  refine Finset.sum_congr rfl fun k hk => ?_
  simp only [mem_filter, mem_univ, true_and] at hk
  unfold fiberCount
  congr 1
  rw [Finset.filter_filter]
  exact Finset.filter_congr fun x _ => by
    constructor
    · rintro ⟨-, h⟩; exact h
    · rintro h; exact ⟨by rw [h]; exact hk, h⟩

/-- **The total gap is bounded by the collision fraction.**  The conditional entropy of the
label given the view — i.e. the amount by which the reading falls short of the label entropy —
is at most the fraction of colliding samples times `log₂ |L|`. -/
theorem gap_le_collision_fraction (l : Fin n → L) (c : Fin n → K) (hn : 0 < n) [Nonempty L] :
    entropy (margL (viewTable l c)) - mutualInfo (viewTable l c)
      ≤ ((collisionCount c : ℝ) / n) * Real.logb 2 (Fintype.card L) := by
  have hnn : ∀ a k, 0 ≤ viewTable l c a k := viewTable_nonneg l c
  have hgap := mutualInfo_sub_entropy_margL hnn
  have hswap : entropy (margL (viewTable l c)) - mutualInfo (viewTable l c)
      = ∑ k, ∑ a, -(viewTable l c a k *
          Real.logb 2 (viewTable l c a k / margK (viewTable l c) k)) := by
    have : ∑ k, ∑ a, -(viewTable l c a k *
        Real.logb 2 (viewTable l c a k / margK (viewTable l c) k))
        = -(∑ a, ∑ k, viewTable l c a k *
            Real.logb 2 (viewTable l c a k / margK (viewTable l c) k)) := by
      simp only [Finset.sum_neg_distrib]
      rw [Finset.sum_comm]
    rw [this, ← hgap]
    ring
  rw [hswap]
  have hle : ∑ k, ∑ a, -(viewTable l c a k *
      Real.logb 2 (viewTable l c a k / margK (viewTable l c) k))
      ≤ ∑ k, (if 2 ≤ fiberCount c k then ((fiberCount c k : ℝ) / n) *
            Real.logb 2 (Fintype.card L) else 0) :=
    Finset.sum_le_sum fun k _ => fiber_gap_le l c k hn
  refine hle.trans (le_of_eq ?_)
  rw [← Finset.sum_filter, ← Finset.sum_mul, ← Finset.sum_div, ← Nat.cast_sum,
    ← collisionCount_eq_sum]

/-! ## The sandwich and the powerlessness of the permutation null -/

/-- **The collision sandwich.**  The plug-in reading of a labelled sample through any view is
pinned between the label entropy and the label entropy minus the collision fraction. -/
theorem hintedView_sandwich (l : Fin n → L) (c : Fin n → K) (hn : 0 < n) [Nonempty L] :
    entropy (fun a => (labelCard l a : ℝ) / n)
        - ((collisionCount c : ℝ) / n) * Real.logb 2 (Fintype.card L)
      ≤ mutualInfo (viewTable l c) ∧
    mutualInfo (viewTable l c) ≤ entropy (fun a => (labelCard l a : ℝ) / n) := by
  have hmarg : margL (viewTable l c) = fun a => (labelCard l a : ℝ) / n := by
    funext a; exact margL_viewTable l c a
  have hnn : ∀ a k, 0 ≤ viewTable l c a k := viewTable_nonneg l c
  have hup := mutualInfo_le_entropy_margL hnn
  have hlow := gap_le_collision_fraction l c hn
  rw [hmarg] at hup hlow
  exact ⟨by linarith, hup⟩

/-- **The injective limit.**  A view with no collisions reads exactly the label entropy,
whatever the relationship between labels and view values: the reading is a function of the
label counts alone and carries no information about dependence. -/
theorem injective_view_reading_eq_label_entropy (l : Fin n → L) (c : Fin n → K) (hn : 0 < n)
    [Nonempty L] (hcol : collisionCount c = 0) :
    mutualInfo (viewTable l c) = entropy (fun a => (labelCard l a : ℝ) / n) := by
  obtain ⟨hlow, hup⟩ := hintedView_sandwich l c hn
  rw [hcol] at hlow
  simp only [Nat.cast_zero, zero_div, zero_mul, sub_zero] at hlow
  linarith

/-! ### Permutation invariants -/

omit [Fintype L] in
lemma labelCard_comp_perm (l : Fin n → L) (π : Equiv.Perm (Fin n)) (a : L) :
    labelCard (l ∘ π) a = labelCard l a := by
  unfold labelCard
  refine Finset.card_bij' (fun i _ => π i) (fun i _ => π.symm i) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [mem_filter, mem_univ, true_and, Function.comp_apply] at hx ⊢
    exact hx
  · intro x hx
    simp only [mem_filter, mem_univ, true_and, Function.comp_apply] at hx ⊢
    simpa using hx
  · intro x _; simp
  · intro x _; simp

/-- **The null band.**  Every label-permuted surrogate reads within the collision fraction of
the observed reading: shuffling labels cannot move the statistic outside the band that
sparsity already fixes. -/
theorem hintedView_null_band (l : Fin n → L) (c : Fin n → K) (hn : 0 < n) [Nonempty L]
    (π : Equiv.Perm (Fin n)) :
    |mutualInfo (viewTable (l ∘ π) c) - mutualInfo (viewTable l c)|
      ≤ ((collisionCount c : ℝ) / n) * Real.logb 2 (Fintype.card L) := by
  obtain ⟨hlow, hup⟩ := hintedView_sandwich l c hn
  obtain ⟨hlowπ, hupπ⟩ := hintedView_sandwich (l ∘ π) c hn
  have hent : (fun a => (labelCard (l ∘ π) a : ℝ) / n) = (fun a => (labelCard l a : ℝ) / n) := by
    funext a; rw [labelCard_comp_perm]
  rw [hent] at hlowπ hupπ
  rw [abs_le]
  constructor <;> linarith

/-- **The null has no range.**  Any two surrogates — hence the observed value and the whole
200-shuffle null together — lie in a common interval of width the collision fraction. -/
theorem hintedView_null_range (l : Fin n → L) (c : Fin n → K) (hn : 0 < n) [Nonempty L]
    (π σ : Equiv.Perm (Fin n)) :
    |mutualInfo (viewTable (l ∘ π) c) - mutualInfo (viewTable (l ∘ σ) c)|
      ≤ ((collisionCount c : ℝ) / n) * Real.logb 2 (Fintype.card L) := by
  obtain ⟨hlow, hup⟩ := hintedView_sandwich (l ∘ σ) c hn
  obtain ⟨hlowπ, hupπ⟩ := hintedView_sandwich (l ∘ π) c hn
  have hent : (fun a => (labelCard (l ∘ π) a : ℝ) / n)
      = (fun a => (labelCard (l ∘ σ) a : ℝ) / n) := by
    funext a; rw [labelCard_comp_perm, labelCard_comp_perm]
  rw [hent] at hlowπ hupπ
  rw [abs_le]
  constructor <;> linarith

/-- **The z-score numerator is bounded by the collision fraction.**  Observed minus null mean
can never exceed the band that sparsity fixes, so a reading inside its null is the only
possible outcome for a sufficiently fine view. -/
theorem hintedView_z_numerator_le (l : Fin n → L) (c : Fin n → K) (hn : 0 < n) [Nonempty L] :
    |mutualInfo (viewTable l c)
        - (∑ π : Equiv.Perm (Fin n), mutualInfo (viewTable (l ∘ π) c))
            / (Fintype.card (Equiv.Perm (Fin n)))|
      ≤ ((collisionCount c : ℝ) / n) * Real.logb 2 (Fintype.card L) := by
  set ε : ℝ := ((collisionCount c : ℝ) / n) * Real.logb 2 (Fintype.card L) with hε
  set M : ℕ := Fintype.card (Equiv.Perm (Fin n)) with hM
  have hMpos : (0 : ℝ) < M := by
    have : 0 < M := Fintype.card_pos
    exact_mod_cast this
  have hsum : (∑ π : Equiv.Perm (Fin n),
        (mutualInfo (viewTable l c) - mutualInfo (viewTable (l ∘ π) c)))
      = (M : ℝ) * mutualInfo (viewTable l c)
          - ∑ π : Equiv.Perm (Fin n), mutualInfo (viewTable (l ∘ π) c) := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, ← hM, nsmul_eq_mul]
  have hrewrite : mutualInfo (viewTable l c)
      - (∑ π : Equiv.Perm (Fin n), mutualInfo (viewTable (l ∘ π) c)) / M
      = (∑ π : Equiv.Perm (Fin n),
          (mutualInfo (viewTable l c) - mutualInfo (viewTable (l ∘ π) c))) / M := by
    rw [hsum]
    field_simp
  rw [hrewrite, abs_div, abs_of_pos hMpos, div_le_iff₀ hMpos]
  calc |∑ π : Equiv.Perm (Fin n),
          (mutualInfo (viewTable l c) - mutualInfo (viewTable (l ∘ π) c))|
      ≤ ∑ π : Equiv.Perm (Fin n),
          |mutualInfo (viewTable l c) - mutualInfo (viewTable (l ∘ π) c)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _π : Equiv.Perm (Fin n), ε := by
        refine Finset.sum_le_sum fun π _ => ?_
        rw [abs_sub_comm]
        exact hintedView_null_band l c hn π
    _ = ε * M := by
        rw [Finset.sum_const, Finset.card_univ, ← hM, nsmul_eq_mul]; ring

/-! ## Estimating the collision fraction from the data -/

/-- The view values actually realised are exactly the nonempty fibers. -/
lemma image_eq_filter_fiberCount (c : Fin n → K) :
    Finset.image c univ = univ.filter (fun k => 0 < fiberCount c k) := by
  ext k
  simp only [mem_image, mem_univ, true_and, mem_filter, fiberCount, Finset.card_pos,
    Finset.filter_nonempty_iff]

/-- **The collision count is estimable from the number of distinct view values.**  If the
sample of size `n` realises `d` distinct view values, then at most `2·(n − d)` samples
collide. -/
theorem collisionCount_le_two_mul_excess (c : Fin n → K) :
    collisionCount c ≤ 2 * (n - (Finset.image c univ).card) := by
  classical
  set T : Finset K := univ.filter (fun k => 0 < fiberCount c k) with hT
  set A : Finset K := univ.filter (fun k => 2 ≤ fiberCount c k) with hA
  have hAT : A ⊆ T := by
    intro k hk
    simp only [hA, hT, mem_filter, mem_univ, true_and] at hk ⊢
    omega
  have hd : (Finset.image c univ).card = T.card := by rw [image_eq_filter_fiberCount, hT]
  have hn : ∑ k ∈ T, fiberCount c k = n :=
    (Finset.sum_subset (Finset.subset_univ T) (by
      intro k _ hk
      simp only [hT, mem_filter, mem_univ, true_and, not_lt, Nat.le_zero] at hk
      exact hk)).trans (sum_fiberCount c)
  have hcol : collisionCount c = ∑ k ∈ A, fiberCount c k := collisionCount_eq_sum c
  -- split the total over `A` and `T \ A`
  have hsplit : ∑ k ∈ T, fiberCount c k
      = (∑ k ∈ T \ A, fiberCount c k) + ∑ k ∈ A, fiberCount c k :=
    (Finset.sum_sdiff hAT).symm
  have hone : ∑ k ∈ T \ A, fiberCount c k = (T \ A).card := by
    rw [Finset.card_eq_sum_ones]
    refine Finset.sum_congr rfl fun k hk => ?_
    simp only [Finset.mem_sdiff, hT, hA, mem_filter, mem_univ, true_and, not_le] at hk
    omega
  have hAcard : 2 * A.card ≤ ∑ k ∈ A, fiberCount c k := by
    rw [Finset.card_eq_sum_ones, Finset.mul_sum]
    refine Finset.sum_le_sum fun k hk => ?_
    simp only [hA, mem_filter, mem_univ, true_and] at hk
    omega
  have hTcard : T.card = A.card + (T \ A).card := by
    rw [← Finset.card_union_of_disjoint (Finset.disjoint_sdiff)]
    congr 1
    rw [Finset.union_sdiff_of_subset hAT]
  have hdle : T.card ≤ n := by
    rw [← hn, hTcard, hsplit, hone]
    omega
  rw [hd, hcol]
  omega

omit [Fintype K] in
/-- **The bound is attained.**  A constant view collapses every sample into one fiber: the
collision count is the whole sample and the reading loses the entire label entropy.  The
sandwich cannot be tightened without assumptions on the view. -/
theorem collision_bound_is_attained (k₀ : K) :
    collisionCount (fun _ : Fin n => k₀) = (if 2 ≤ n then n else 0) := by
  have hfib : ∀ k, fiberCount (fun _ : Fin n => k₀) k = if k = k₀ then n else 0 := by
    intro k
    unfold fiberCount
    by_cases h : k = k₀
    · subst h; simp
    · rw [if_neg h]
      simp [Ne.symm h]
  unfold collisionCount
  simp only [hfib]
  by_cases h2 : 2 ≤ n
  · simp [h2]
  · simp [h2]

/-- **THE HINTED VIEW IS BLIND.**  If the view's collision fraction is below `δ / log₂|L|`,
then the observed reading, every permuted surrogate and the null mean all lie inside one
interval of width `δ`.  A permutation test on such a view has no resolution at all: the
reading it reports is a measurement of the view's sparsity, not of the label's dependence on
the view. -/
theorem hintedView_test_is_powerless (l : Fin n → L) (c : Fin n → K) (hn : 0 < n) [Nonempty L]
    {δ : ℝ} (hδ : ((collisionCount c : ℝ) / n) * Real.logb 2 (Fintype.card L) ≤ δ) :
    (∀ π : Equiv.Perm (Fin n),
        |mutualInfo (viewTable (l ∘ π) c) - mutualInfo (viewTable l c)| ≤ δ) ∧
    (∀ π σ : Equiv.Perm (Fin n),
        |mutualInfo (viewTable (l ∘ π) c) - mutualInfo (viewTable (l ∘ σ) c)| ≤ δ) ∧
    |mutualInfo (viewTable l c)
        - (∑ π : Equiv.Perm (Fin n), mutualInfo (viewTable (l ∘ π) c))
            / (Fintype.card (Equiv.Perm (Fin n)))| ≤ δ :=
  ⟨fun π => (hintedView_null_band l c hn π).trans hδ,
   fun π σ => (hintedView_null_range l c hn π σ).trans hδ,
   (hintedView_z_numerator_le l c hn).trans hδ⟩

end Computation.FactorBlindness