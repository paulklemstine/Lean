import Mathlib

/-!
# The geometry of prediction agreement for layer transplants (NET-54)

This file formalises the *structural* content of the NET-54 measurement
**THE-TAIL-IS-LOAD-BEARING-BUT-UNPORTABLE**.

The empirical situation.  Two fine-tunes of one architecture (a `base` model `A`
and an `Instruct` model `B`) are compared on 12 held-out windows.  Their top-1
next-token predictions agree on a fraction `0.8327` of the positions (the
*cross-parent baseline*).  A causal transplant of two layers produces a hybrid
`H` (host `A`, donor block from `B`).  The measured agreements are

| arm | agree w/ base `A` | agree w/ instruct `B` |
|---|---|---|
| `A ← B` tail L22/23 | `0.5845` | `0.5443` |
| `A ← B` bulk L10/11 | `0.9635` | `0.8385` |
| `B ← A` tail L22/23 | `0.5887` | `0.6289` |
| `B ← A` bulk L10/11 | `0.8459` | `0.9495` |

The pre-registered hypothesis P1 ("the hybrid is pulled towards the donor") is
refuted: the tail-swapped hybrid agrees with *both* parents far below the
cross-parent baseline.  This file proves that this signature is not merely "low
numbers" but has a hard combinatorial consequence.

Main results (all statements are about arbitrary prediction functions on a
finite index set; the measured numbers enter only in the final instantiations):

* `agreeFrac_triangle` — normalised prediction agreement obeys the Hamming
  pseudometric triangle inequality `agr f g + agr g h ≤ 1 + agr f h`.  This is
  the *portability budget*: a hybrid cannot be close to two distant parents.
* `novelFrac_ge_baseline_sub_agree` — the **both-parents-collapse certificate**:
  the fraction of positions where the hybrid predicts a token that *neither*
  parent predicts is at least `agr A B − min (agr H A) (agr H B)`.  A hybrid
  that falls below the cross-parent baseline on either side is forced to invent
  genuinely new behaviour.
* `net54_tail_swap_novelty` / `net54_reverse_tail_swap_novelty` — the measured
  numbers give `≥ 0.2884` (resp. `≥ 0.2038`) of positions at which the hybrid is
  neither parent.  The transplanted tail carries no portable identity.
* `net54_hybrid_not_parent_selector` — consequently the tail-swapped hybrid is
  *not* a selector between the two parents: no assignment of positions to
  parents can explain it.
* `net54_bulk_swap_no_collapse` — the matched-width bulk control (L10/11) is
  consistent with a pure selector, so the collapse is specific to the tail.
* `novelty_bound_sharp` — the certificate is sharp: equality is attained.
-/

namespace Catalog.Probability.TailTransplantGeometry

open Finset

variable {Ω Y : Type*} [Fintype Ω] [DecidableEq Ω] [DecidableEq Y]

/-! ### 1. Agreement sets and their fractions -/

/-- The positions at which two prediction functions agree. -/
def agreeSet (f g : Ω → Y) : Finset Ω := Finset.univ.filter (fun x => f x = g x)

/-- The positions at which two prediction functions disagree. -/
def disagreeSet (f g : Ω → Y) : Finset Ω := Finset.univ.filter (fun x => f x ≠ g x)

/-- The positions at which the hybrid `h` predicts a token that **neither**
parent `a` nor parent `b` predicts. -/
def novelSet (h a b : Ω → Y) : Finset Ω :=
  Finset.univ.filter (fun x => h x ≠ a x ∧ h x ≠ b x)

/-- Normalised prediction agreement (the empirical "agree with" number). -/
noncomputable def agreeFrac (f g : Ω → Y) : ℝ :=
  ((agreeSet f g).card : ℝ) / (Fintype.card Ω : ℝ)

/-- The fraction of positions at which the hybrid is neither parent. -/
noncomputable def novelFrac (h a b : Ω → Y) : ℝ :=
  ((novelSet h a b).card : ℝ) / (Fintype.card Ω : ℝ)

omit [DecidableEq Ω] in
lemma mem_agreeSet {f g : Ω → Y} {x : Ω} : x ∈ agreeSet f g ↔ f x = g x := by
  simp [agreeSet]

omit [DecidableEq Ω] in
lemma mem_disagreeSet {f g : Ω → Y} {x : Ω} : x ∈ disagreeSet f g ↔ f x ≠ g x := by
  simp [disagreeSet]

omit [DecidableEq Ω] in
lemma mem_novelSet {h a b : Ω → Y} {x : Ω} :
    x ∈ novelSet h a b ↔ (h x ≠ a x ∧ h x ≠ b x) := by
  simp [novelSet]

omit [DecidableEq Ω] in
lemma agreeSet_comm (f g : Ω → Y) : agreeSet f g = agreeSet g f := by
  ext x; simp [mem_agreeSet, eq_comm]

omit [DecidableEq Ω] in
lemma novelSet_comm (h a b : Ω → Y) : novelSet h a b = novelSet h b a := by
  ext x; simp [mem_novelSet, and_comm]

omit [DecidableEq Ω] in
lemma agreeFrac_comm (f g : Ω → Y) : agreeFrac f g = agreeFrac g f := by
  simp [agreeFrac, agreeSet_comm f g]

omit [DecidableEq Ω] in
lemma novelFrac_comm (h a b : Ω → Y) : novelFrac h a b = novelFrac h b a := by
  rw [novelFrac, novelFrac, novelSet_comm]

omit [DecidableEq Ω] in
/-- Agreement and disagreement partition the index set. -/
lemma card_agree_add_card_disagree (f g : Ω → Y) :
    (agreeSet f g).card + (disagreeSet f g).card = Fintype.card Ω := by
  simpa [agreeSet, disagreeSet, Finset.card_univ] using
    (Finset.card_filter_add_card_filter_not
      (s := (Finset.univ : Finset Ω)) (p := fun x => f x = g x))

omit [DecidableEq Ω] in
lemma agreeFrac_nonneg (f g : Ω → Y) : 0 ≤ agreeFrac f g := by
  unfold agreeFrac; positivity

omit [DecidableEq Ω] in
lemma novelFrac_nonneg (h a b : Ω → Y) : 0 ≤ novelFrac h a b := by
  unfold novelFrac; positivity

omit [DecidableEq Ω] in
lemma agreeFrac_le_one (f g : Ω → Y) : agreeFrac f g ≤ 1 := by
  rcases Nat.eq_zero_or_pos (Fintype.card Ω) with hN | hN
  · simp [agreeFrac, hN]
  · have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
    rw [agreeFrac, div_le_one hNR]
    have hc : (agreeSet f g).card ≤ Fintype.card Ω := by
      simpa [Finset.card_univ] using
        Finset.card_le_card (Finset.filter_subset (fun x => f x = g x) Finset.univ)
    exact_mod_cast hc

/-! ### 2. The Hamming triangle inequality: the portability budget -/

/-- Disagreement is subadditive along a chain: the Hamming pseudometric
triangle inequality at the level of sets. -/
lemma disagreeSet_subset_union (f g h : Ω → Y) :
    disagreeSet f h ⊆ disagreeSet f g ∪ disagreeSet g h := by
  intro x hx
  rw [mem_disagreeSet] at hx
  by_cases hfg : f x = g x
  · have hgh : g x ≠ h x := by rw [← hfg]; exact hx
    exact Finset.mem_union_right _ (mem_disagreeSet.2 hgh)
  · exact Finset.mem_union_left _ (mem_disagreeSet.2 hfg)

/-- **Portability budget (triangle inequality).**  For any three prediction
functions, `agr f g + agr g h ≤ 1 + agr f h`.  A hybrid cannot agree strongly
with two parents that disagree with each other. -/
theorem agreeFrac_triangle (f g h : Ω → Y) :
    agreeFrac f g + agreeFrac g h ≤ 1 + agreeFrac f h := by
  rcases Nat.eq_zero_or_pos (Fintype.card Ω) with hN | hN
  · simp [agreeFrac, hN]
  have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  have hcard : (disagreeSet f h).card ≤ (disagreeSet f g).card + (disagreeSet g h).card :=
    le_trans (Finset.card_le_card (disagreeSet_subset_union f g h))
      (Finset.card_union_le _ _)
  have e₁ := card_agree_add_card_disagree f g
  have e₂ := card_agree_add_card_disagree g h
  have e₃ := card_agree_add_card_disagree f h
  have key : ((agreeSet f g).card : ℝ) + ((agreeSet g h).card : ℝ)
      ≤ (Fintype.card Ω : ℝ) + ((agreeSet f h).card : ℝ) := by
    have hnat : (agreeSet f g).card + (agreeSet g h).card
        ≤ Fintype.card Ω + (agreeSet f h).card := by omega
    exact_mod_cast hnat
  calc agreeFrac f g + agreeFrac g h
      = (((agreeSet f g).card : ℝ) + ((agreeSet g h).card : ℝ)) / (Fintype.card Ω : ℝ) := by
        rw [agreeFrac, agreeFrac, add_div]
    _ ≤ ((Fintype.card Ω : ℝ) + ((agreeSet f h).card : ℝ)) / (Fintype.card Ω : ℝ) := by
        gcongr
    _ = 1 + agreeFrac f h := by rw [add_div, div_self hNR.ne', agreeFrac]

/-! ### 3. The both-parents-collapse certificate -/

/-- On a position where the two parents agree, the hybrid either follows them or
is novel. -/
lemma agreeSet_parents_subset (h a b : Ω → Y) :
    agreeSet a b ⊆ novelSet h a b ∪ agreeSet h a := by
  intro x hx
  rw [mem_agreeSet] at hx
  by_cases hha : h x = a x
  · exact Finset.mem_union_right _ (mem_agreeSet.2 hha)
  · have hhb : h x ≠ b x := by rw [← hx]; exact hha
    exact Finset.mem_union_left _ (mem_novelSet.2 ⟨hha, hhb⟩)

/-- Cardinality form of the collapse certificate. -/
lemma card_agree_parents_le (h a b : Ω → Y) :
    (agreeSet a b).card ≤ (novelSet h a b).card + (agreeSet h a).card :=
  le_trans (Finset.card_le_card (agreeSet_parents_subset h a b)) (Finset.card_union_le _ _)

/-- **Collapse certificate, host side.**  If the hybrid agrees with parent `a`
less often than the two parents agree with each other, the difference is a
lower bound on the fraction of positions where the hybrid predicts something
*neither* parent predicts. -/
theorem novelFrac_ge_sub_agree_left (h a b : Ω → Y) :
    agreeFrac a b - agreeFrac h a ≤ novelFrac h a b := by
  rcases Nat.eq_zero_or_pos (Fintype.card Ω) with hN | hN
  · simp [agreeFrac, novelFrac, hN]
  have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  have hcard := card_agree_parents_le h a b
  have hR : ((agreeSet a b).card : ℝ)
      ≤ ((novelSet h a b).card : ℝ) + ((agreeSet h a).card : ℝ) := by exact_mod_cast hcard
  have step : ((agreeSet a b).card : ℝ) / (Fintype.card Ω : ℝ)
      ≤ (((novelSet h a b).card : ℝ) + ((agreeSet h a).card : ℝ))
        / (Fintype.card Ω : ℝ) := by
    gcongr
  rw [add_div] at step
  rw [agreeFrac, agreeFrac, novelFrac, sub_le_iff_le_add]
  exact step

/-- **Collapse certificate, donor side.** -/
theorem novelFrac_ge_sub_agree_right (h a b : Ω → Y) :
    agreeFrac a b - agreeFrac h b ≤ novelFrac h a b := by
  have hstep := novelFrac_ge_sub_agree_left h b a
  rwa [agreeFrac_comm b a, novelFrac_comm h b a] at hstep

/-- **The both-parents-collapse certificate.**  The novelty of the hybrid is at
least the cross-parent baseline minus the *better* of its two agreements. -/
theorem novelFrac_ge_baseline_sub_agree (h a b : Ω → Y) :
    agreeFrac a b - min (agreeFrac h a) (agreeFrac h b) ≤ novelFrac h a b := by
  rcases le_total (agreeFrac h a) (agreeFrac h b) with hle | hle
  · rw [min_eq_left hle]; exact novelFrac_ge_sub_agree_left h a b
  · rw [min_eq_right hle]; exact novelFrac_ge_sub_agree_right h a b

/-! ### 4. Selector hybrids -/

/-- A hybrid is a *parent selector* if at every position it reproduces one of the
two parents' predictions.  This is the model implicitly assumed by hypothesis P1
("the hybrid is pulled towards the donor"): the swap only decides *which*
parent's behaviour is inherited where. -/
def IsParentSelector (h a b : Ω → Y) : Prop := ∀ x, h x = a x ∨ h x = b x

omit [DecidableEq Ω] in
lemma novelFrac_eq_zero_of_selector {h a b : Ω → Y} (hs : IsParentSelector h a b) :
    novelFrac h a b = 0 := by
  have hzero : (novelSet h a b).card = 0 := by
    rw [Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
    intro x hx
    rcases mem_novelSet.1 hx with ⟨h1, h2⟩
    rcases hs x with h3 | h3
    · exact h1 h3
    · exact h2 h3
  simp [novelFrac, hzero]

/-- A selector hybrid saturates the portability budget from below: it must agree
with at least one parent as often as the parents agree with each other. -/
theorem selector_agrees_with_a_parent {h a b : Ω → Y} (hs : IsParentSelector h a b) :
    agreeFrac a b ≤ max (agreeFrac h a) (agreeFrac h b) := by
  have h1 := novelFrac_ge_baseline_sub_agree h a b
  rw [novelFrac_eq_zero_of_selector hs] at h1
  rcases le_total (agreeFrac h a) (agreeFrac h b) with hle | hle
  · rw [min_eq_left hle] at h1; rw [max_eq_right hle]; linarith
  · rw [min_eq_right hle] at h1; rw [max_eq_left hle]; linarith

/-! ### 5. The NET-54 instantiations -/

section NET54

variable (H A B : Ω → Y)

/-- **NET-54, arm `base ← instruct`, tail L22/23.**  With the measured
cross-parent baseline `0.8327` and hybrid agreements `0.5845` (base) and
`0.5443` (instruct): at least `28.84 %` of the held-out positions carry a hybrid
prediction that *neither* parent makes, and the hybrid's better agreement still
sits `0.2482` below the cross-parent baseline.  The transplanted tail does not
import the donor's identity; it creates a third behaviour. -/
theorem net54_tail_swap_novelty
    (hbase : (0.8327 : ℝ) ≤ agreeFrac A B)
    (hHA : agreeFrac H A ≤ 0.5845) (hHB : agreeFrac H B ≤ 0.5443) :
    (0.2884 : ℝ) ≤ novelFrac H A B ∧
      max (agreeFrac H A) (agreeFrac H B) + 0.2482 ≤ agreeFrac A B := by
  refine ⟨?_, ?_⟩
  · have h := novelFrac_ge_sub_agree_right H A B
    linarith
  · rcases le_total (agreeFrac H A) (agreeFrac H B) with hle | hle
    · rw [max_eq_right hle]; linarith
    · rw [max_eq_left hle]; linarith

/-- **NET-54, arm `instruct ← base`, tail L22/23** (measured `0.5887` with base,
`0.6289` with instruct): at least `20.38 %` of positions are novel, and the
better agreement is still `0.2038` below the cross-parent baseline.  The
asymmetry between the two directions (P2) does not change the verdict. -/
theorem net54_reverse_tail_swap_novelty
    (hbase : (0.8327 : ℝ) ≤ agreeFrac A B)
    (hHA : agreeFrac H A ≤ 0.5887) (hHB : agreeFrac H B ≤ 0.6289) :
    (0.2038 : ℝ) ≤ novelFrac H A B ∧
      max (agreeFrac H A) (agreeFrac H B) + 0.2038 ≤ agreeFrac A B := by
  refine ⟨?_, ?_⟩
  · have h := novelFrac_ge_sub_agree_right H A B
    linarith
  · rcases le_total (agreeFrac H A) (agreeFrac H B) with hle | hle
    · rw [max_eq_right hle]; linarith
    · rw [max_eq_left hle]; linarith

/-- **The tail-swapped hybrid is not a parent selector.**  No assignment of
positions to parents can reproduce the measured agreement profile: the hybrid's
behaviour is genuinely off-manifold with respect to its two parents.  This is
the sharp form of "P1 refuted". -/
theorem net54_hybrid_not_parent_selector
    (hbase : (0.8327 : ℝ) ≤ agreeFrac A B)
    (hHA : agreeFrac H A ≤ 0.5845) (hHB : agreeFrac H B ≤ 0.5443) :
    ¬ IsParentSelector H A B := by
  intro hs
  have h := selector_agrees_with_a_parent hs
  rcases le_total (agreeFrac H A) (agreeFrac H B) with hle | hle
  · rw [max_eq_right hle] at h; linarith
  · rw [max_eq_left hle] at h; linarith

omit [DecidableEq Ω] in
/-- **The matched-width bulk control does not collapse.**  With the measured
L10/11 numbers (`0.9635` with the host) the collapse certificate is vacuous:
`agr A B − max(...) < 0`, so a selector explanation remains available.  The
certificate therefore separates the two swap sites: the collapse is a property
of the tail, not of transplanting per se. -/
theorem net54_bulk_swap_no_collapse
    (hbase : agreeFrac A B ≤ 0.8327) (hHA : (0.9635 : ℝ) ≤ agreeFrac H A) :
    agreeFrac A B - max (agreeFrac H A) (agreeFrac H B) < 0 := by
  have hmax : agreeFrac H A ≤ max (agreeFrac H A) (agreeFrac H B) := le_max_left _ _
  linarith

omit [DecidableEq Ω] in
/-- The measured tail-swap profile sits far *inside* the portability budget: the
triangle inequality allows an agreement sum of `1 + 0.8327`, and the measurement
delivers at most `1.1288`, a slack of `0.7039`.  So the collapse is not an
arithmetic necessity — the numbers had room to look like a donor transfer and
did not. -/
theorem net54_profile_budget_slack
    (hbase : (0.8327 : ℝ) ≤ agreeFrac A B)
    (hHA : agreeFrac H A ≤ 0.5845) (hHB : agreeFrac H B ≤ 0.5443) :
    agreeFrac H A + agreeFrac H B + 0.7039 ≤ 1 + agreeFrac A B := by
  linarith

end NET54

/-! ### 6. Sharpness -/

/-- The collapse certificate is attained: there are prediction functions on a
two-point index set for which the novelty fraction equals exactly
`agr A B − agr H A`.  Hence the bound of `novelFrac_ge_sub_agree_left` cannot be
improved. -/
theorem novelty_bound_sharp :
    ∃ (H A B : Fin 2 → Fin 3),
      agreeFrac A B - agreeFrac H A = novelFrac H A B ∧ novelFrac H A B = 1 / 2 := by
  have h1 : (agreeSet (![0, 0] : Fin 2 → Fin 3) ![0, 0]).card = 2 := by decide
  have h2 : (agreeSet (![1, 0] : Fin 2 → Fin 3) ![0, 0]).card = 1 := by decide
  have h3 : (novelSet (![1, 0] : Fin 2 → Fin 3) ![0, 0] ![0, 0]).card = 1 := by decide
  refine ⟨![1, 0], ![0, 0], ![0, 0], ?_, ?_⟩
  · simp [agreeFrac, novelFrac, h1, h2, h3, Fintype.card_fin]
    norm_num
  · simp [novelFrac, h3, Fintype.card_fin]

end Catalog.Probability.TailTransplantGeometry