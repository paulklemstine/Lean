/-
  A Bonferroni Inequality for the Catalog `G(n,p)` Model, and a Sharper Lower
  Bound for the K₃-Minor Probability
  ==========================================================================

  `HadwigerRandomGraph.lean` bounds the probability that `G(n,p)` has a `K₃`
  minor from below by `p³`, using one fixed triangle.  Using `m` vertex-disjoint
  triangles the bound can be improved, but the events are not disjoint, so the
  union bound points the wrong way.  The right tool is the second Bonferroni
  inequality

      P(⋃ᵢ Aᵢ) ≥ ∑ᵢ P(Aᵢ) − ½ ∑_{i ≠ j} P(Aᵢ ∩ Aⱼ),

  which we prove here for the catalog model from scratch, by the standard
  counting argument: for a configuration lying in exactly `c` of the events, the
  contribution to the right-hand side is `c − (c² − c)/2 = (3c − c²)/2 ≤ 1`.

  Main results:

  * `ErdosRenyi.prob_eq_sum_indicator`
  * `ErdosRenyi.bonferroni_two`      : the inequality, for an arbitrary finite
                                       family of events.
  * `Hadwiger.RandomGraph.two_triangle_bound` : `2p³ − p⁶ ≤ P(K₃ ≼ G(n+6, p))`,
                                       strictly better than `p³` for `p < 1`.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): the single-triangle bound `p³` is lossy; disjoint
    triangles should give an inclusion–exclusion improvement, and the correct
    general statement is a Bonferroni inequality rather than a union bound.
  Experiment (Experimenter): the counting proof needs three rewritings of `Prob`
    as a sum of indicators over all configurations, after which everything is
    the pointwise inequality `(3c − c²)/2 ≤ [c ≥ 1]` on natural numbers `c`,
    discharged by `nlinarith` after splitting `c = 0` from `c ≥ 1`.
  Analysis (Analyst): the key structural point is that the count of events
    containing a configuration `s` is `(A.filter (s ∈ ev ·)).card`, and the
    off-diagonal pair count is the `offDiag` of exactly that filtered set —
    which is why `Finset.offDiag_card` gives `c² − c` with no extra work.
  Critique (Critic): the two-triangle application is stated for `n + 6`
    vertices, so it is not vacuous; `2p³ − p⁶ − p³ = p³(1 − p³) > 0` for
    `0 < p < 1`, so it strictly improves the previous bound in that range.
  Synthesis (PI): the catalog now has a genuine second-order inclusion–exclusion
    tool, applicable to any monotone event built from finitely many prescribed
    edge sets.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerRandomGraph

namespace ErdosRenyi

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- `Prob` written as a sum of indicators over all configurations. -/
theorem prob_eq_sum_indicator (p : ℝ) (E : Finset (Finset α)) :
    Prob p E = ∑ s : Finset α, if s ∈ E then mass p s else 0 := by
  classical
  rw [Prob, ← Finset.sum_filter, Finset.filter_univ_mem]

/-- **Second Bonferroni inequality** for the catalog `G(n,p)` model: the
probability of a finite union is at least the sum of the probabilities minus
half the sum of the pairwise intersection probabilities. -/
theorem bonferroni_two {ι : Type*} [DecidableEq ι] {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (A : Finset ι) (ev : ι → Finset (Finset α)) :
    ∑ i ∈ A, Prob p (ev i) - (∑ q ∈ A.offDiag, Prob p (ev q.1 ∩ ev q.2)) / 2
      ≤ Prob p (A.biUnion ev) := by
  classical
  set F : Finset α → Finset ι := fun s => A.filter (fun i => s ∈ ev i) with hF
  have h1 : ∑ i ∈ A, Prob p (ev i) = ∑ s : Finset α, mass p s * ((F s).card : ℝ) := by
    simp only [prob_eq_sum_indicator]
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun s _ => ?_
    rw [← Finset.sum_filter, Finset.sum_const, nsmul_eq_mul, mul_comm]
  have h2 : ∑ q ∈ A.offDiag, Prob p (ev q.1 ∩ ev q.2)
      = ∑ s : Finset α, mass p s * (((F s).card : ℝ) * (F s).card - (F s).card) := by
    simp only [prob_eq_sum_indicator]
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun s _ => ?_
    have hfil : A.offDiag.filter (fun q => s ∈ ev q.1 ∩ ev q.2) = (F s).offDiag := by
      ext q
      simp only [Finset.mem_filter, Finset.mem_offDiag, Finset.mem_inter, hF]
      tauto
    have hle : (F s).card ≤ (F s).card * (F s).card := by
      rcases Nat.eq_zero_or_pos (F s).card with h | h
      · simp [h]
      · exact Nat.le_mul_of_pos_left _ h
    rw [← Finset.sum_filter, hfil, Finset.sum_const, nsmul_eq_mul, mul_comm,
      Finset.offDiag_card, Nat.cast_sub hle, Nat.cast_mul]
  have h3 : Prob p (A.biUnion ev)
      = ∑ s : Finset α, if (F s).Nonempty then mass p s else 0 := by
    rw [prob_eq_sum_indicator]
    refine Finset.sum_congr rfl fun s _ => ?_
    congr 1
    simp only [Finset.mem_biUnion, Finset.Nonempty, hF, Finset.mem_filter]
  rw [h1, h2, h3, Finset.sum_div, ← Finset.sum_sub_distrib]
  refine Finset.sum_le_sum fun s _ => ?_
  have hm : 0 ≤ mass p s := mass_nonneg hp0 hp1 s
  rcases Nat.eq_zero_or_pos (F s).card with h0 | hpos
  · have hne : ¬ (F s).Nonempty :=
      Finset.not_nonempty_iff_eq_empty.mpr (Finset.card_eq_zero.mp h0)
    simp [hne, h0]
  · have hne : (F s).Nonempty := Finset.card_pos.mp hpos
    rw [if_pos hne]
    have hc1 : (1 : ℝ) ≤ ((F s).card : ℝ) := by exact_mod_cast hpos
    -- the pointwise inequality `(3c - c²)/2 ≤ 1` uses integrality of the count
    rcases Nat.lt_or_ge (F s).card 2 with hlt | hge
    · have hone : (F s).card = 1 := by omega
      rw [hone]
      norm_num
    · have hc2 : (2 : ℝ) ≤ ((F s).card : ℝ) := by exact_mod_cast hge
      nlinarith [mul_nonneg (mul_nonneg hm (sub_nonneg.mpr hc1)) (by linarith :
        (0 : ℝ) ≤ ((F s).card : ℝ) - 2)]

end ErdosRenyi

namespace Hadwiger.RandomGraph

open SimpleGraph ErdosRenyi Finset
open scoped Classical

variable {n : ℕ}

/-- The three edges of the triangle spanned by three distinct vertices. -/
noncomputable def triEdges {a b c : Fin n} (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    Finset (Edge n) :=
  {⟨s(a, b), by simpa using hab⟩, ⟨s(a, c), by simpa using hac⟩, ⟨s(b, c), by simpa using hbc⟩}

theorem card_triEdges {a b c : Fin n} (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    (triEdges hab hac hbc).card = 3 := by
  have h1 : (⟨s(a, b), by simpa using hab⟩ : Edge n) ≠ ⟨s(a, c), by simpa using hac⟩ := by
    simp [Subtype.ext_iff, hac, Ne.symm hab, hbc]
  have h2 : (⟨s(a, b), by simpa using hab⟩ : Edge n) ≠ ⟨s(b, c), by simpa using hbc⟩ := by
    simp [Subtype.ext_iff, hab, hac, hbc]
  have h3 : (⟨s(a, c), by simpa using hac⟩ : Edge n) ≠ ⟨s(b, c), by simpa using hbc⟩ := by
    simp [Subtype.ext_iff, hab, hac, Ne.symm hbc]
  simp [triEdges, Finset.card_insert_of_notMem, h1, h2, h3]

/-- A configuration containing all three edges of a triangle has a `K₃` minor. -/
theorem triEdges_subset_hasK3Minor {a b c : Fin n} (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c) :
    Finset.univ.filter (fun s => triEdges hab hac hbc ⊆ s) ⊆ hasK3Minor n := by
  intro s hs
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hs
  have hadj : ∀ (x y : Fin n) (hxy : x ≠ y),
      (⟨s(x, y), by simpa using hxy⟩ : Edge n) ∈ s → (graphOf s).Adj x y := by
    intro x y hxy hin
    simp only [graphOf, SimpleGraph.fromEdgeSet_adj]
    exact ⟨⟨⟨s(x, y), by simpa using hxy⟩, by simpa using hin, rfl⟩, hxy⟩
  have Aab : (graphOf s).Adj a b := hadj a b hab (hs (by simp [triEdges]))
  have Aac : (graphOf s).Adj a c := hadj a c hac (hs (by simp [triEdges]))
  have Abc : (graphOf s).Adj b c := hadj b c hbc (hs (by simp [triEdges]))
  simp only [hasK3Minor, Finset.mem_filter, Finset.mem_univ, true_and]
  exact completeMinor_three_of_triple (S0 := {a}) (S1 := {b}) (S2 := {c})
    ⟨a, rfl⟩ ⟨b, rfl⟩ ⟨c, rfl⟩ (by simpa using hab) (by simpa using hac) (by simpa using hbc)
    (setConnected_singleton a) (setConnected_singleton b) (setConnected_singleton c)
    ⟨a, rfl, b, rfl, Aab⟩ ⟨a, rfl, c, rfl, Aac⟩ ⟨b, rfl, c, rfl, Abc⟩

/-- **Two-triangle lower bound.**  On at least six vertices the probability that
`G(n,p)` has a `K₃` minor is at least `2p³ − p⁶`, which strictly improves the
one-triangle bound `p³` for every `0 < p < 1`. -/
theorem two_triangle_bound {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (n : ℕ) :
    2 * p ^ 3 - p ^ 6 ≤ Prob p (hasK3Minor (n + 6)) := by
  classical
  set vv : Fin 6 → Fin (n + 6) := fun i => ⟨(i : ℕ), by omega⟩ with hvv
  have hne : ∀ i j : Fin 6, i ≠ j → vv i ≠ vv j := by
    intro i j hij h
    exact hij (Fin.ext (by simpa [hvv, Fin.ext_iff] using h))
  set T1 : Finset (Edge (n + 6)) :=
    triEdges (hne 0 1 (by decide)) (hne 0 2 (by decide)) (hne 1 2 (by decide)) with hT1
  set T2 : Finset (Edge (n + 6)) :=
    triEdges (hne 3 4 (by decide)) (hne 3 5 (by decide)) (hne 4 5 (by decide)) with hT2
  set E1 : Finset (Finset (Edge (n + 6))) := Finset.univ.filter (fun s => T1 ⊆ s) with hE1
  set E2 : Finset (Finset (Edge (n + 6))) := Finset.univ.filter (fun s => T2 ⊆ s) with hE2
  set ev : Fin 2 → Finset (Finset (Edge (n + 6))) := ![E1, E2] with hev
  have hev0 : ev 0 = E1 := rfl
  have hev1 : ev 1 = E2 := rfl
  -- the union of the two triangle events is contained in the `K₃`-minor event
  have hsub : (Finset.univ : Finset (Fin 2)).biUnion ev ⊆ hasK3Minor (n + 6) := by
    intro s hs
    rw [Finset.mem_biUnion] at hs
    obtain ⟨i, -, hi⟩ := hs
    rcases (by decide : ∀ i : Fin 2, i = 0 ∨ i = 1) i with rfl | rfl
    · rw [hev0, hE1] at hi
      exact triEdges_subset_hasK3Minor _ _ _ hi
    · rw [hev1, hE2] at hi
      exact triEdges_subset_hasK3Minor _ _ _ hi
  -- the individual probabilities
  have hc1 : T1.card = 3 := card_triEdges _ _ _
  have hc2 : T2.card = 3 := card_triEdges _ _ _
  have hpr1 : Prob p (ev 0) = p ^ 3 := by rw [hev0, hE1, prob_contains_subset, hc1]
  have hpr2 : Prob p (ev 1) = p ^ 3 := by rw [hev1, hE2, prob_contains_subset, hc2]
  -- the two triangles are edge-disjoint, so the intersection probability is `p⁶`
  have hdisj : Disjoint T1 T2 := by
    rw [Finset.disjoint_left]
    intro e he1 he2
    simp only [hT1, hT2, triEdges, Finset.mem_insert, Finset.mem_singleton] at he1 he2
    rcases he1 with h1 | h1 | h1 <;> rcases he2 with h2 | h2 | h2 <;>
      · rw [h1] at h2
        simp [Subtype.ext_iff, hvv, Fin.ext_iff] at h2
  have hcU : (T1 ∪ T2).card = 6 := by
    rw [Finset.card_union_of_disjoint hdisj, hc1, hc2]
  have hI : E1 ∩ E2 = Finset.univ.filter (fun s => T1 ∪ T2 ⊆ s) := by
    ext s
    simp [hE1, hE2, Finset.union_subset_iff]
  have hInter : Prob p (E1 ∩ E2) = p ^ 6 := by rw [hI, prob_contains_subset, hcU]
  have hbon := bonferroni_two (α := Edge (n + 6)) hp0 hp1 (Finset.univ : Finset (Fin 2)) ev
  have hoff : ∑ q ∈ (Finset.univ : Finset (Fin 2)).offDiag, Prob p (ev q.1 ∩ ev q.2)
      = 2 * p ^ 6 := by
    have hod : (Finset.univ : Finset (Fin 2)).offDiag = {(0, 1), (1, 0)} := by decide
    rw [hod, Finset.sum_insert (by decide), Finset.sum_singleton, hev0, hev1,
      Finset.inter_comm E2 E1, hInter]
    ring
  rw [hoff, Fin.sum_univ_two, hpr1, hpr2] at hbon
  have hmono : Prob p ((Finset.univ : Finset (Fin 2)).biUnion ev) ≤ Prob p (hasK3Minor (n + 6)) :=
    prob_mono hp0 hp1 hsub
  linarith [hbon, hmono]

end Hadwiger.RandomGraph