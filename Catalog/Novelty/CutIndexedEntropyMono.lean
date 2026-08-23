import Novelty.CutIndexedEntropy

/-!
# Cut-indexed defects V: the entropy profile is a monotone cut datum

Files I–III bound the cut entropy from above.  This file establishes the missing
*structural* property of the profile `S ↦ cutEntropy C S`: it is **monotone**
along the lattice of cuts.  Together with `cutEntropy_le_card_mul_log` this says
that the entropy profile of a codebook is itself a (real-valued) cut datum in the
sense of file I: it starts at `0`, never decreases, and never exceeds `|S| log q`.

## Main results

* `Real.negMulLog_sum_le` : **superadditivity of `negMulLog`**,
  `negMulLog (∑ aᵢ) ≤ ∑ negMulLog aᵢ` for nonnegative `aᵢ` — the analytic engine;
* `cutProb_eq_sum_cutProb` : the marginal on a sub-cut is the coarse-graining of
  the marginal on the larger cut;
* `cutEntropy_mono` : **`S ⊆ T → cutEntropy C S ≤ cutEntropy C T`**;
* `cutEntropy_empty` : the entropy of the empty cut vanishes;
* `cutEntropy_nonneg'` : hence the profile is nonnegative even without invoking
  the probability-vector bound.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the classical cut-rank axioms of `CutData`
(`rank ∅ ≤ 1`, monotone, one-site growth `≤ q`) should have an exact entropic
mirror (`H ∅ = 0`, monotone, one-site growth `≤ log q`).  If all three mirror
axioms hold, the abstract Singleton argument of file I can be rerun verbatim in
the entropic category.

Experiment (Experimenter): axioms one and two are proved here.  Monotonicity is
*not* a formal consequence of the counting monotonicity `cutRank_mono`: entropy
can decrease under coarse-graining of the alphabet in general, and what saves the
day is that the coarse-graining here is *deterministic* — the marginal on `S` is
obtained by summing the fibres of the marginal on `T`, and `negMulLog` is
superadditive on nonnegatives.

Analysis (Analyst): the third mirror axiom, `H(S ∪ {a}) ≤ H(S) + log q`, is the
Shannon chain rule, and it is *not* derivable from the two axioms proved here;
formalising the conditional-entropy decomposition is the concrete next step
recorded as Direction 2 of `FUTURE_DIRECTIONS.md`.  Note the contrast with the
negative result `Examples.cutRank_not_submodular`: the entropic profile is
strictly better behaved than the rank profile, which is exactly why the entropy
version of the Singleton defect detects MDS at a single cut.
-/

open Finset

namespace CutIndexedSingleton

variable {n q : ℕ}

/-- **Superadditivity of `negMulLog`.**  For nonnegative summands,
`negMulLog (∑ aᵢ) ≤ ∑ negMulLog aᵢ`. -/
theorem Real.negMulLog_sum_le {ι : Type*} (s : Finset ι) (f : ι → ℝ)
    (hf : ∀ i ∈ s, 0 ≤ f i) :
    Real.negMulLog (∑ i ∈ s, f i) ≤ ∑ i ∈ s, Real.negMulLog (f i) := by
  classical
  have hA0 : 0 ≤ ∑ i ∈ s, f i := Finset.sum_nonneg hf
  rcases eq_or_lt_of_le hA0 with h | h
  · have hzero : ∀ i ∈ s, f i = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg hf).mp h.symm
    have hl : Real.negMulLog (∑ i ∈ s, f i) = 0 := by
      rw [← h, Real.negMulLog_zero]
    have hr : ∑ i ∈ s, Real.negMulLog (f i) = 0 := by
      refine Finset.sum_eq_zero fun i hi => ?_
      rw [hzero i hi, Real.negMulLog_zero]
    rw [hl, hr]
  · have key : ∀ i ∈ s, -f i * Real.log (∑ j ∈ s, f j) ≤ Real.negMulLog (f i) := by
      intro i hi
      rcases eq_or_lt_of_le (hf i hi) with h0 | h0
      · rw [← h0]
        simp
      · have hle : f i ≤ ∑ j ∈ s, f j := Finset.single_le_sum hf hi
        have hlog : Real.log (f i) ≤ Real.log (∑ j ∈ s, f j) := Real.log_le_log h0 hle
        simp only [Real.negMulLog_def]
        nlinarith
    have hsum : Real.negMulLog (∑ i ∈ s, f i)
        = ∑ i ∈ s, (-f i * Real.log (∑ j ∈ s, f j)) := by
      simp only [Real.negMulLog_def, ← Finset.sum_neg_distrib, ← Finset.sum_mul]
    rw [hsum]
    exact Finset.sum_le_sum key

/-- The restriction of a pattern on a cut to a sub-cut. -/
def restrictCut {S T : Finset (Fin n)} (h : S ⊆ T) (z : {i // i ∈ T} → Fin q) :
    {i // i ∈ S} → Fin q := fun i => z ⟨i.1, h i.2⟩

@[simp] lemma restrictCut_proj {S T : Finset (Fin n)} (h : S ⊆ T) (c : Word n q) :
    restrictCut h (proj T c) = proj S c := rfl

/-- The fibre of a sub-cut pattern is the disjoint union of the fibres of the
patterns above it. -/
lemma fiber_card_eq_sum {C : Finset (Word n q)} {S T : Finset (Fin n)} (h : S ⊆ T)
    (y : {i // i ∈ S} → Fin q) :
    (fiber C S y).card
      = ∑ z ∈ (Finset.univ : Finset ({i // i ∈ T} → Fin q)).filter
          (fun z => restrictCut h z = y), (fiber C T z).card := by
  classical
  have hmaps : Set.MapsTo (proj T) (fiber C S y : Set (Word n q))
      ((Finset.univ.filter (fun z : {i // i ∈ T} → Fin q => restrictCut h z = y) :
        Finset _) : Set _) := by
    intro c hc
    have hc' : proj S c = y := (Finset.mem_filter.mp hc).2
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and]
    rw [restrictCut_proj h c, hc']
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  refine Finset.sum_congr rfl fun z hz => ?_
  have hzy : restrictCut h z = y := (Finset.mem_filter.mp hz).2
  congr 1
  ext c
  simp only [fiber, Finset.mem_filter]
  constructor
  · rintro ⟨⟨hcC, -⟩, hcT⟩
    exact ⟨hcC, hcT⟩
  · rintro ⟨hcC, hcT⟩
    refine ⟨⟨hcC, ?_⟩, hcT⟩
    rw [← restrictCut_proj h c, hcT, hzy]

/-- The marginal on a sub-cut is the coarse-graining of the marginal above it. -/
lemma cutProb_eq_sum_cutProb {C : Finset (Word n q)} {S T : Finset (Fin n)} (h : S ⊆ T)
    (y : {i // i ∈ S} → Fin q) :
    cutProb C S y
      = ∑ z ∈ (Finset.univ : Finset ({i // i ∈ T} → Fin q)).filter
          (fun z => restrictCut h z = y), cutProb C T z := by
  classical
  unfold cutProb
  rw [← Finset.sum_div]
  congr 1
  rw [fiber_card_eq_sum h y]
  push_cast
  rfl

/-- **The entropy profile is monotone along cuts.**  Enlarging a cut cannot
decrease the entropy it sees. -/
theorem cutEntropy_mono (C : Finset (Word n q)) {S T : Finset (Fin n)} (h : S ⊆ T) :
    cutEntropy C S ≤ cutEntropy C T := by
  classical
  calc cutEntropy C S
      = ∑ y : {i // i ∈ S} → Fin q, Real.negMulLog
          (∑ z ∈ (Finset.univ : Finset ({i // i ∈ T} → Fin q)).filter
            (fun z => restrictCut h z = y), cutProb C T z) := by
        unfold cutEntropy
        exact Finset.sum_congr rfl fun y _ => by rw [cutProb_eq_sum_cutProb h y]
    _ ≤ ∑ y : {i // i ∈ S} → Fin q,
          ∑ z ∈ (Finset.univ : Finset ({i // i ∈ T} → Fin q)).filter
            (fun z => restrictCut h z = y), Real.negMulLog (cutProb C T z) := by
        refine Finset.sum_le_sum fun y _ => ?_
        exact Real.negMulLog_sum_le _ _ fun z _ => cutProb_nonneg C T z
    _ = cutEntropy C T := by
        unfold cutEntropy
        exact Finset.sum_fiberwise (Finset.univ : Finset ({i // i ∈ T} → Fin q))
          (fun z => restrictCut h z) (fun z => Real.negMulLog (cutProb C T z))

/-- The empty cut carries no entropy. -/
@[simp] theorem cutEntropy_empty {C : Finset (Word n q)} (hC : C.Nonempty) :
    cutEntropy C (∅ : Finset (Fin n)) = 0 := by
  classical
  have hsum := sum_cutProb hC (∅ : Finset (Fin n))
  have hsub : Subsingleton ({i // i ∈ (∅ : Finset (Fin n))} → Fin q) := by
    constructor
    intro f g
    funext i
    exact absurd i.2 (Finset.notMem_empty _)
  unfold cutEntropy
  have hcard : (Finset.univ : Finset ({i // i ∈ (∅ : Finset (Fin n))} → Fin q)).card = 1 := by
    rw [Finset.card_univ]
    exact Fintype.card_eq_one_iff_nonempty_unique.mpr
      ⟨⟨⟨fun i => absurd i.2 (Finset.notMem_empty _)⟩, fun f => hsub.allEq _ _⟩⟩
  obtain ⟨y, hy⟩ := Finset.card_eq_one.mp hcard
  rw [hy, Finset.sum_singleton] at hsum ⊢
  rw [hsum, Real.negMulLog_one]

/-- Monotonicity gives nonnegativity of the whole profile. -/
theorem cutEntropy_nonneg' {C : Finset (Word n q)} (hC : C.Nonempty) (S : Finset (Fin n)) :
    0 ≤ cutEntropy C S := by
  rw [← cutEntropy_empty hC]
  exact cutEntropy_mono C (Finset.empty_subset S)

end CutIndexedSingleton