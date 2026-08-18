/-
# Which aggregator is the "centre of a seed distribution"?  An axiomatic classification

The seed-distribution thread summarises three per-seed knees by *some* aggregator and
observes a law about it.  This file asks the adversarial question: **what pins down the
median?**  We isolate five axioms for a ternary aggregator `F : ℝ³ → ℝ`:

* `AggMono`  — monotone in each argument (a better seed cannot lower the summary);
* `AggSymm`  — symmetric (seeds are exchangeable);
* `AggCons`  — conservative: the summary is one of the measured values;
* `AggTrans` — translation equivariant (tropical homogeneity of degree one: a unit change);
* `AggSelfDual` — self-dual under order reversal (`F(-x) = -F(x)`).

**Theorem** (`median_characterisation`): the five axioms force `F = tropMed3`, the median.

**Counterexample** (`sumSign_*`): dropping *only* `AggTrans` destroys the conclusion.  The
"sum-sign aggregator" — take the maximum if the seeds sum to a positive number, the minimum
if they sum to a negative one, and the median on the zero-sum wall — is monotone, symmetric,
conservative and self-dual, yet it is not the median (`sumSignAgg 0 0 1 = 1`).  So the
tropical axiom (translation equivariance) is *indispensable*: the median's status as the
canonical centre is a **tropical** fact, not merely an order-theoretic one.

The proof of the characterisation is a two-step tropical argument:
`F 0 0 d = d - F 0 d d` (self-duality + translation), monotonicity gives `F 0 0 d ≤ F 0 d d`,
and conservativity then forces the *majority* property `F 0 0 d = 0`; a squeeze between
`F a b b = b` and `F b b c = b` finishes the sorted case.
-/
import Tropical.KneeMedian.TropicalNormalForm

namespace Catalog.Tropical.KneeMedian

/-! ## The axioms -/

/-- Monotone in each argument. -/
def AggMono (F : ℝ → ℝ → ℝ → ℝ) : Prop :=
  ∀ a b c a' b' c' : ℝ, a ≤ a' → b ≤ b' → c ≤ c' → F a b c ≤ F a' b' c'

/-- Symmetric under the two generating transpositions (hence under all of `S₃`). -/
def AggSymm (F : ℝ → ℝ → ℝ → ℝ) : Prop :=
  (∀ a b c : ℝ, F a b c = F b a c) ∧ (∀ a b c : ℝ, F a b c = F a c b)

/-- Conservative: the output is one of the inputs. -/
def AggCons (F : ℝ → ℝ → ℝ → ℝ) : Prop :=
  ∀ a b c : ℝ, F a b c = a ∨ F a b c = b ∨ F a b c = c

/-- Translation equivariance — tropical homogeneity of degree one. -/
def AggTrans (F : ℝ → ℝ → ℝ → ℝ) : Prop :=
  ∀ a b c t : ℝ, F (a + t) (b + t) (c + t) = F a b c + t

/-- Self-duality under order reversal. -/
def AggSelfDual (F : ℝ → ℝ → ℝ → ℝ) : Prop :=
  ∀ a b c : ℝ, F (-a) (-b) (-c) = -F a b c

/-! ## Step 1: self-duality + translation + monotonicity + conservativity ⇒ majority -/

/-- The key identity: self-duality and translation equivariance tie the "two low votes"
configuration to the "two high votes" configuration. -/
theorem agg_dual_identity {F : ℝ → ℝ → ℝ → ℝ} (hsym : AggSymm F) (htr : AggTrans F)
    (hsd : AggSelfDual F) (d : ℝ) : F 0 0 d = d - F 0 d d := by
  have h1 : F 0 0 (-d) = -F 0 0 d := by
    have := hsd 0 0 d
    simpa using this
  have h2 : F (0 + d) (0 + d) (-d + d) = F 0 0 (-d) + d := htr 0 0 (-d) d
  simp only [zero_add, neg_add_cancel] at h2
  have h3 : F d d 0 = F 0 d d := by
    rw [hsym.2 d d 0, hsym.1 d 0 d]
  rw [h3, h1] at h2
  linarith

/-- **Majority property.**  Two votes at the same value win: `F 0 0 d = 0` for `d ≥ 0`.
This is where conservativity is essential — the mean satisfies every other axiom. -/
theorem agg_majority_low {F : ℝ → ℝ → ℝ → ℝ} (hmono : AggMono F) (hsym : AggSymm F)
    (hcons : AggCons F) (htr : AggTrans F) (hsd : AggSelfDual F) {d : ℝ} (hd : 0 ≤ d) :
    F 0 0 d = 0 := by
  have hid : F 0 0 d = d - F 0 d d := agg_dual_identity hsym htr hsd d
  have hle : F 0 0 d ≤ F 0 d d := hmono 0 0 d 0 d d le_rfl hd le_rfl
  have hhalf : 2 * F 0 0 d ≤ d := by linarith
  rcases hcons 0 0 d with h | h | h
  · exact h
  · exact h
  · rcases eq_or_lt_of_le hd with hd0 | hd0
    · rw [h, ← hd0]
    · exfalso; rw [h] at hhalf; linarith

/-- Two equal low votes beat a single high vote. -/
theorem agg_two_low {F : ℝ → ℝ → ℝ → ℝ} (hmono : AggMono F) (hsym : AggSymm F)
    (hcons : AggCons F) (htr : AggTrans F) (hsd : AggSelfDual F) {a c : ℝ} (h : a ≤ c) :
    F a a c = a := by
  have := htr 0 0 (c - a) a
  simp only [zero_add, sub_add_cancel] at this
  rw [this, agg_majority_low hmono hsym hcons htr hsd (by linarith), zero_add]

/-- Two equal high votes beat a single low vote. -/
theorem agg_two_high {F : ℝ → ℝ → ℝ → ℝ} (hmono : AggMono F) (hsym : AggSymm F)
    (hcons : AggCons F) (htr : AggTrans F) (hsd : AggSelfDual F) {a c : ℝ} (h : a ≤ c) :
    F a c c = c := by
  have hid : F 0 0 (c - a) = (c - a) - F 0 (c - a) (c - a) :=
    agg_dual_identity hsym htr hsd (c - a)
  have hmaj : F 0 0 (c - a) = 0 := agg_majority_low hmono hsym hcons htr hsd (by linarith)
  have hval : F 0 (c - a) (c - a) = c - a := by rw [hmaj] at hid; linarith
  have htrans := htr 0 (c - a) (c - a) a
  simp only [zero_add, sub_add_cancel] at htrans
  rw [htrans, hval]
  ring

/-! ## Step 2: the squeeze -/

/-- On a sorted triple the aggregator is squeezed onto the middle value. -/
theorem agg_sorted {F : ℝ → ℝ → ℝ → ℝ} (hmono : AggMono F) (hsym : AggSymm F)
    (hcons : AggCons F) (htr : AggTrans F) (hsd : AggSelfDual F) {a b c : ℝ}
    (hab : a ≤ b) (hbc : b ≤ c) : F a b c = b := by
  have hlow : F a b b = b := agg_two_high hmono hsym hcons htr hsd hab
  have hhigh : F b b c = b := agg_two_low hmono hsym hcons htr hsd hbc
  have h1 : F a b b ≤ F a b c := hmono a b b a b c le_rfl le_rfl hbc
  have h2 : F a b c ≤ F b b c := hmono a b c b b c hab le_rfl le_rfl
  rw [hlow] at h1
  rw [hhigh] at h2
  linarith

/-- **Axiomatic characterisation of the median.**  A monotone, symmetric, conservative,
translation-equivariant and self-dual ternary aggregator on `ℝ` *is* the median. -/
theorem median_characterisation {F : ℝ → ℝ → ℝ → ℝ} (hmono : AggMono F) (hsym : AggSymm F)
    (hcons : AggCons F) (htr : AggTrans F) (hsd : AggSelfDual F) (a b c : ℝ) :
    F a b c = tropMed3 a b c := by
  have hs : ∀ x y z : ℝ, x ≤ y → y ≤ z → F x y z = y := fun x y z h1 h2 =>
    agg_sorted hmono hsym hcons htr hsd h1 h2
  have h12 := hsym.1
  have h23 := hsym.2
  rcases le_total a b with hab | hab <;> rcases le_total b c with hbc | hbc <;>
      rcases le_total a c with hac | hac
  · rw [hs _ _ _ hab hbc]
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order
  · rw [hs _ _ _ hab hbc]
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order
  · rw [h23 a b c, hs _ _ _ hac hbc]
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order
  · rw [h23 a b c, h12 a c b, hs _ _ _ hac hab]
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order
  · rw [h12 a b c, hs _ _ _ hab hac]
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order
  · rw [h12 a b c, h23 b a c, hs _ _ _ hbc hac]
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order
  · rw [h23 a b c, h12 a c b, h23 c a b, hs _ _ _ hbc hab]
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order
  · rw [h23 a b c, h12 a c b, h23 c a b, hs _ _ _ hbc hab]
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order

/-- The median itself satisfies all five axioms, so the characterisation is not vacuous. -/
theorem tropMed3_isAggregator :
    AggMono (tropMed3 : ℝ → ℝ → ℝ → ℝ) ∧ AggSymm (tropMed3 : ℝ → ℝ → ℝ → ℝ) ∧
      AggCons (tropMed3 : ℝ → ℝ → ℝ → ℝ) ∧ AggTrans (tropMed3 : ℝ → ℝ → ℝ → ℝ) ∧
      AggSelfDual (tropMed3 : ℝ → ℝ → ℝ → ℝ) := by
  refine ⟨?_, ⟨?_, ?_⟩, ?_, ?_, ?_⟩
  · intro a b c a' b' c' ha hb hc; exact tropMed3_mono ha hb hc
  · intro a b c
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order
  · intro a b c
    simp only [tropMed3, min_def, max_def]; split_ifs <;> order
  · intro a b c; exact tropMed3_eq_or a b c
  · intro a b c t; exact tropMed3_add_const a b c t
  · intro a b c; exact tropMed3_neg a b c

/-! ## Independence of the tropical axiom: the sum-sign aggregator -/

/-- The **sum-sign aggregator**: take the maximum when the seeds sum to a positive number,
the minimum when they sum to a negative one, and the median on the zero-sum wall.  It is
monotone, symmetric, conservative and self-dual, but *not* translation equivariant — and it
is not the median. -/
noncomputable def sumSignAgg (a b c : ℝ) : ℝ :=
  if 0 < a + b + c then max a (max b c)
  else if a + b + c < 0 then min a (min b c) else tropMed3 a b c

theorem sumSignAgg_ge_min (a b c : ℝ) : min a (min b c) ≤ sumSignAgg a b c := by
  unfold sumSignAgg
  split_ifs
  · exact le_trans (min_le_left _ _) (le_max_left _ _)
  · exact le_rfl
  · exact min_le_tropMed3 a b c

theorem sumSignAgg_le_max (a b c : ℝ) : sumSignAgg a b c ≤ max a (max b c) := by
  unfold sumSignAgg
  split_ifs
  · exact le_rfl
  · exact le_trans (min_le_left _ _) (le_max_left _ _)
  · exact tropMed3_le_max a b c

theorem sumSignAgg_mono : AggMono sumSignAgg := by
  intro a b c a' b' c' ha hb hc
  have hmaxmono : max a (max b c) ≤ max a' (max b' c') :=
    max_le_max ha (max_le_max hb hc)
  have hminmono : min a (min b c) ≤ min a' (min b' c') :=
    min_le_min ha (min_le_min hb hc)
  have hsum : a + b + c ≤ a' + b' + c' := by linarith
  by_cases h' : 0 < a' + b' + c'
  · have : sumSignAgg a' b' c' = max a' (max b' c') := by simp [sumSignAgg, h']
    rw [this]
    exact le_trans (sumSignAgg_le_max a b c) hmaxmono
  · by_cases h'' : a' + b' + c' < 0
    · have hlt : a + b + c < 0 := lt_of_le_of_lt hsum h''
      have e1 : sumSignAgg a b c = min a (min b c) := by
        simp [sumSignAgg, not_lt.mpr hlt.le, hlt]
      have e2 : sumSignAgg a' b' c' = min a' (min b' c') := by
        simp [sumSignAgg, h', h'']
      rw [e1, e2]; exact hminmono
    · have hzero : a' + b' + c' = 0 := by
        rcases lt_trichotomy (a' + b' + c') 0 with h | h | h
        · exact absurd h h''
        · exact h
        · exact absurd h h'
      have e2 : sumSignAgg a' b' c' = tropMed3 a' b' c' := by simp [sumSignAgg, h', h'']
      rw [e2]
      by_cases hlt : a + b + c < 0
      · have e1 : sumSignAgg a b c = min a (min b c) := by
          simp [sumSignAgg, not_lt.mpr hlt.le, hlt]
        rw [e1]
        exact le_trans hminmono (min_le_tropMed3 a' b' c')
      · have hz : a + b + c = 0 := by
          rcases lt_trichotomy (a + b + c) 0 with h | h | h
          · exact absurd h hlt
          · exact h
          · exfalso; linarith
        have e1 : sumSignAgg a b c = tropMed3 a b c := by
          simp [sumSignAgg, hz]
        rw [e1]
        exact tropMed3_mono ha hb hc

theorem sumSignAgg_symm : AggSymm sumSignAgg := by
  constructor
  · intro a b c
    unfold sumSignAgg
    have h : a + b + c = b + a + c := by ring
    rw [h]
    congr 1
    · rw [max_left_comm]
    · congr 1
      · rw [min_left_comm]
      · exact tropMed3_swap12 a b c
  · intro a b c
    unfold sumSignAgg
    have h : a + b + c = a + c + b := by ring
    rw [h]
    congr 1
    · rw [max_comm b c]
    · congr 1
      · rw [min_comm b c]
      · exact tropMed3_swap23 a b c

theorem sumSignAgg_cons : AggCons sumSignAgg := by
  intro a b c
  unfold sumSignAgg
  split_ifs
  · rcases max_choice a (max b c) with h | h
    · exact Or.inl h
    · rcases max_choice b c with h' | h'
      · exact Or.inr (Or.inl (by rw [h, h']))
      · exact Or.inr (Or.inr (by rw [h, h']))
  · rcases min_choice a (min b c) with h | h
    · exact Or.inl h
    · rcases min_choice b c with h' | h'
      · exact Or.inr (Or.inl (by rw [h, h']))
      · exact Or.inr (Or.inr (by rw [h, h']))
  · exact tropMed3_eq_or a b c

theorem sumSignAgg_selfDual : AggSelfDual sumSignAgg := by
  intro a b c
  unfold sumSignAgg
  have hsum : -a + -b + -c = -(a + b + c) := by ring
  rw [hsum]
  by_cases h : 0 < a + b + c
  · rw [if_neg (by linarith), if_pos (by linarith), if_pos h]
    simp [neg_sup]
  · by_cases h' : a + b + c < 0
    · rw [if_pos (by linarith), if_neg h, if_pos h']
      simp [neg_inf]
    · have hz : a + b + c = 0 := by
        rcases lt_trichotomy (a + b + c) 0 with hh | hh | hh
        · exact absurd hh h'
        · exact hh
        · exact absurd hh h
      rw [hz]
      simp only [neg_zero, lt_irrefl, if_false]
      exact tropMed3_neg a b c

/-- The sum-sign aggregator is **not** the median. -/
theorem sumSignAgg_ne_median : sumSignAgg 0 0 1 ≠ tropMed3 (0 : ℝ) 0 1 := by
  have h1 : sumSignAgg 0 0 1 = 1 := by norm_num [sumSignAgg]
  have h2 : tropMed3 (0 : ℝ) 0 1 = 0 := by norm_num [tropMed3]
  rw [h1, h2]
  norm_num

/-- **Independence of the tropical axiom.**  Monotonicity, symmetry, conservativity and
self-duality do *not* characterise the median: without translation equivariance the sum-sign
aggregator satisfies all four axioms and differs from the median.  Hence in
`median_characterisation` the hypothesis `AggTrans` cannot be dropped. -/
theorem aggTrans_indispensable :
    ∃ F : ℝ → ℝ → ℝ → ℝ, AggMono F ∧ AggSymm F ∧ AggCons F ∧ AggSelfDual F ∧
      ∃ a b c : ℝ, F a b c ≠ tropMed3 a b c :=
  ⟨sumSignAgg, sumSignAgg_mono, sumSignAgg_symm, sumSignAgg_cons, sumSignAgg_selfDual,
    0, 0, 1, sumSignAgg_ne_median⟩

end Catalog.Tropical.KneeMedian