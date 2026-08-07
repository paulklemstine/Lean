/-
  # Colour-critical subgraphs and the minimum-degree reduction for Hadwiger's conjecture

  This file closes the first structural step of Conjecture 1 of `FUTURE_DIRECTIONS.md`
  ("Dirac's shape"): it reduces Hadwiger's conjecture for a parameter `k` to the
  *minimum-degree* statement

      every finite graph of minimum degree at least `k` has a `K_{k+1}` minor.

  The reduction proceeds through a colour-critical subgraph:

  1. `ColorableOn` — proper `k`-colourability of a vertex subset;
  2. `exists_critical_subset` — every graph that is not `k`-colourable contains a
     *vertex-minimal* non-`k`-colourable subset;
  3. `exists_subset_minDegree_of_not_colorable` — in that minimal subset **every**
     vertex has at least `k` neighbours inside the subset (the classical
     "critical graphs have large minimum degree" lemma, proved by a greedy
     re-colouring of the deleted vertex);
  4. `hadwigerProperty_of_minDegree_forces` — hence the minimum-degree statement
     implies `HadwigerProperty k`, using `isMinor_of_isMinor_induce` from
     `HadwigerCore.lean` to lift the minor from the induced subgraph.

  As applications we obtain

  * `completeMinor_three_of_two_le_degree` — the case `k = 2` of the minimum-degree
    statement (minimum degree `2` forces a `K₃` minor), proved from the sharp
    extremal bound of `HadwigerDensity.lean` together with the handshake lemma;
  * `hadwiger_two_via_min_degree` — an independent, degeneracy-flavoured proof of
    `HadwigerProperty 2`;
  * `hadwiger_three_of_dirac` — the `k = 3` instance of the reduction: Dirac's
    theorem "minimum degree `3` forces a `K₄` minor" implies `HadwigerProperty 3`.

  Note that the minimum-degree statement is *strictly stronger* than Hadwiger's
  conjecture for large `k` (it fails for `k` large, by Kostochka's bound), so the
  reduction is genuinely one-directional; for `k ≤ 3` the stronger statement is
  the classical route.

  -- !-- Lab Notes -- !--
  * The greedy re-colouring in step 3 needs `k ≥ 1`; the degenerate case `k = 0`
    is handled separately (`S = univ` works, the degree condition being vacuous).
  * Passing from the `Finset`-level degree `(S.filter (G.Adj v)).card` to
    `Nat.card ((G.induce ↑S).neighborSet ⟨v, hv⟩)` is done through the injective
    image under `Subtype.val`; this is `card_neighborSet_induce`.
-/
import Mathlib
import Probability.HadwigerDensity
import Probability.HadwigerSmallCases

namespace Hadwiger

open SimpleGraph Finset

variable {V : Type*} {G : SimpleGraph V} [DecidableRel G.Adj] {k : ℕ}

/-! ## 1.  Colourability of a vertex subset -/

/-- `ColorableOn G S k` : the vertices of `S` can be coloured with `k` colours so
that adjacent vertices of `S` get different colours. -/
def ColorableOn (G : SimpleGraph V) (S : Finset V) (k : ℕ) : Prop :=
  ∃ c : V → Fin k, ∀ x ∈ S, ∀ y ∈ S, G.Adj x y → c x ≠ c y

omit [DecidableRel G.Adj] in
/-- Colouring all vertices is the same as colouring the graph. -/
theorem colorableOn_univ_iff [Fintype V] :
    ColorableOn G Finset.univ k ↔ G.Colorable k := by
  constructor
  · rintro ⟨c, hc⟩
    exact ⟨Coloring.mk c fun {x y} hxy => hc x (mem_univ x) y (mem_univ y) hxy⟩
  · rintro ⟨C⟩
    exact ⟨C, fun x _ y _ hxy => C.valid hxy⟩

omit [DecidableRel G.Adj] in
/-- The empty set is colourable as soon as at least one colour is available. -/
theorem colorableOn_empty (hk : 0 < k) : ColorableOn G ∅ k :=
  ⟨fun _ => ⟨0, hk⟩, by simp⟩

/-! ## 2.  A vertex-minimal non-colourable subset -/

omit [DecidableRel G.Adj] in
/-- **Existence of a colour-critical subset.**  If `G` is not `k`-colourable,
there is a vertex subset `S` that is not `k`-colourable while every subset with
fewer vertices is. -/
theorem exists_critical_subset [Fintype V] [DecidableEq V] (h : ¬ G.Colorable k) :
    ∃ S : Finset V, ¬ ColorableOn G S k ∧
      ∀ T : Finset V, ¬ ColorableOn G T k → S.card ≤ T.card := by
  classical
  have hex : (Finset.univ.filter (fun S : Finset V => ¬ ColorableOn G S k)).Nonempty := by
    refine ⟨Finset.univ, ?_⟩
    simp only [mem_filter, mem_univ, true_and]
    exact fun hcon => h (colorableOn_univ_iff.mp hcon)
  obtain ⟨S, hS, hmin⟩ := Finset.exists_min_image _ Finset.card hex
  rw [mem_filter] at hS
  exact ⟨S, hS.2, fun T hT => hmin T (by simp [hT])⟩

/-! ## 3.  Critical subsets have large minimum degree -/

/-- **Colour-critical subsets have minimum degree at least `k`.**  If `G` is not
`k`-colourable then some non-empty vertex subset `S` is itself not
`k`-colourable and has the property that every vertex of `S` has at least `k`
neighbours inside `S`. -/
theorem exists_subset_minDegree_of_not_colorable [Fintype V] [DecidableEq V]
    (h : ¬ G.Colorable k) :
    ∃ S : Finset V, S.Nonempty ∧ ¬ ColorableOn G S k ∧
      ∀ v ∈ S, k ≤ (S.filter (fun w => G.Adj v w)).card := by
  classical
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · -- with no colours available the degree condition is vacuous
    have hne : (Finset.univ : Finset V).Nonempty := by
      rw [Finset.univ_nonempty_iff]
      by_contra hcon
      rw [not_nonempty_iff] at hcon
      exact h (G.colorable_zero_iff.mpr hcon)
    exact ⟨Finset.univ, hne, fun hcon => h (colorableOn_univ_iff.mp hcon),
      fun v _ => Nat.zero_le _⟩
  obtain ⟨S, hS, hmin⟩ := exists_critical_subset h
  have hne : S.Nonempty := by
    rcases S.eq_empty_or_nonempty with rfl | hne
    · exact absurd (colorableOn_empty hk) hS
    · exact hne
  refine ⟨S, hne, hS, fun v hv => ?_⟩
  by_contra hcon
  push_neg at hcon
  -- the graph minus `v` is colourable, by minimality
  have hlt : (S.erase v).card < S.card := by
    rw [Finset.card_erase_of_mem hv]
    exact Nat.sub_lt (Finset.card_pos.mpr ⟨v, hv⟩) one_pos
  have hcol : ColorableOn G (S.erase v) k := by
    by_contra hc
    exact absurd (hmin _ hc) (not_le.mpr hlt)
  obtain ⟨c', hc'⟩ := hcol
  -- a colour missed by the (fewer than `k`) neighbours of `v` inside `S`
  set F : Finset (Fin k) := (S.filter (fun w => G.Adj v w)).image c' with hF
  have hFlt : F.card < Fintype.card (Fin k) := by
    refine lt_of_le_of_lt Finset.card_image_le ?_
    simpa using hcon
  have hss : F ⊂ Finset.univ :=
    Finset.ssubset_univ_iff.mpr fun hcon' => by
      rw [hcon'] at hFlt; simp at hFlt
  obtain ⟨col, -, hcol'⟩ := Finset.exists_of_ssubset hss
  refine hS ⟨Function.update c' v col, ?_⟩
  intro x hx y hy hxy
  by_cases hxv : x = v
  · subst hxv
    have hyv : y ≠ x := hxy.ne'
    rw [Function.update_self, Function.update_of_ne hyv]
    intro heq
    exact hcol' (by
      rw [hF, heq]
      exact Finset.mem_image_of_mem c' (Finset.mem_filter.mpr ⟨hy, hxy⟩))
  · by_cases hyv : y = v
    · subst hyv
      rw [Function.update_self, Function.update_of_ne hxv]
      intro heq
      exact hcol' (by
        rw [hF, ← heq]
        exact Finset.mem_image_of_mem c' (Finset.mem_filter.mpr ⟨hx, hxy.symm⟩))
    · rw [Function.update_of_ne hxv, Function.update_of_ne hyv]
      exact hc' x (Finset.mem_erase.mpr ⟨hxv, hx⟩) y (Finset.mem_erase.mpr ⟨hyv, hy⟩) hxy

/-! ## 4.  From `Finset` degrees to degrees of the induced subgraph -/

/-- The degree of a vertex in an induced subgraph counts its neighbours inside
the subset. -/
theorem card_neighborSet_induce [Fintype V] [DecidableEq V] {S : Finset V} {v : V}
    (hv : v ∈ S) :
    Nat.card ((G.induce (↑S : Set V)).neighborSet ⟨v, hv⟩)
      = (S.filter (fun w => G.Adj v w)).card := by
  classical
  have himg : Subtype.val '' ((G.induce (↑S : Set V)).neighborSet ⟨v, hv⟩)
      = ↑(S.filter (fun w => G.Adj v w)) := by
    ext w
    constructor
    · rintro ⟨⟨w, hwS⟩, hw, rfl⟩
      simp only [Finset.coe_filter, Set.mem_setOf_eq]
      exact ⟨hwS, hw⟩
    · intro hw
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at hw
      exact ⟨⟨w, hw.1⟩, hw.2, rfl⟩
  have h1 : Nat.card ((G.induce (↑S : Set V)).neighborSet ⟨v, hv⟩)
      = ((G.induce (↑S : Set V)).neighborSet ⟨v, hv⟩).ncard := (Nat.card_coe_set_eq _).symm
  rw [h1, ← Set.ncard_image_of_injective _ Subtype.val_injective, himg,
    Set.ncard_coe_finset]

/-! ## 5.  The reduction -/

/-- **Minimum degree reduction.**  If every finite graph of minimum degree at
least `k` has a `K_{k+1}` minor, then Hadwiger's conjecture holds for `k`.

This is one-directional on purpose: the hypothesis is strictly stronger than
Hadwiger's conjecture for large `k`, but it is the classical route for `k ≤ 3`. -/
theorem hadwigerProperty_of_minDegree_forces
    (H : ∀ (W : Type) [Finite W] [Nonempty W] (K : SimpleGraph W),
        (∀ w : W, k ≤ Nat.card (K.neighborSet w)) → CompleteMinor (k + 1) K) :
    HadwigerProperty k := by
  classical
  intro V _ G hcol
  have : Fintype V := Fintype.ofFinite V
  obtain ⟨S, hne, -, hdeg⟩ := exists_subset_minDegree_of_not_colorable hcol
  have hminor : CompleteMinor (k + 1) (G.induce (↑S : Set V)) := by
    have hnonempty : Nonempty (↥(↑S : Set V)) := by
      obtain ⟨v, hv⟩ := hne
      exact ⟨⟨v, by simpa using hv⟩⟩
    refine H (↥(↑S : Set V)) _ (fun w => ?_)
    obtain ⟨w, hw⟩ := w
    rw [card_neighborSet_induce (S := S) (v := w) (by simpa using hw)]
    exact hdeg w (by simpa using hw)
  exact isMinor_of_isMinor_induce hminor

/-! ## 6.  The case `k = 2`: minimum degree two forces a `K₃` minor -/

/-- **Dirac's statement for `k = 2`.**  A finite graph in which every vertex has
at least two neighbours contains `K₃` as a minor.  Proved from the sharp extremal
bound for `K₃`-minor-free graphs (`|E| ≤ |V| − 1`) together with the handshake
lemma `∑ deg = 2|E|`. -/
theorem completeMinor_three_of_two_le_degree {W : Type} [Finite W] [Nonempty W]
    (K : SimpleGraph W)
    (hdeg : ∀ w : W, 2 ≤ Nat.card (K.neighborSet w)) : CompleteMinor 3 K := by
  classical
  have : Fintype W := Fintype.ofFinite W
  have : DecidableRel K.Adj := Classical.decRel _
  by_contra hcon
  have hbound : Nat.card K.edgeSet + 1 ≤ Nat.card W :=
    card_edgeSet_add_one_le_of_no_K3_minor hcon
  have hdeg' : ∀ w : W, 2 ≤ K.degree w := by
    intro w
    have : Nat.card (K.neighborSet w) = K.degree w := by
      rw [Nat.card_eq_fintype_card, K.card_neighborSet_eq_degree]
    exact this ▸ hdeg w
  have hsum : ∑ w : W, K.degree w = 2 * K.edgeFinset.card :=
    K.sum_degrees_eq_twice_card_edges
  have hge : 2 * Fintype.card W ≤ ∑ w : W, K.degree w := by
    calc 2 * Fintype.card W = ∑ _w : W, 2 := by
          rw [Finset.sum_const, Finset.card_univ]; ring
      _ ≤ ∑ w : W, K.degree w := Finset.sum_le_sum fun w _ => hdeg' w
  have hcardE : Nat.card K.edgeSet = K.edgeFinset.card := by
    rw [Nat.card_eq_fintype_card, SimpleGraph.edgeFinset, Set.toFinset_card]
  have hcardV : Nat.card W = Fintype.card W := Nat.card_eq_fintype_card
  omega

/-- **`HadwigerProperty 2`, obtained from the minimum-degree reduction.**  An
independent proof of Hadwiger's conjecture for `k = 2`, routed through colour
criticality instead of through acyclicity. -/
theorem hadwiger_two_via_min_degree : HadwigerProperty 2 :=
  hadwigerProperty_of_minDegree_forces
    (fun _ _ _ K hdeg => completeMinor_three_of_two_le_degree K hdeg)

/-! ## 7.  The case `k = 3`: Hadwiger follows from Dirac's theorem -/

/-- **Dirac's theorem implies Hadwiger's conjecture for `k = 3`.**  The
hypothesis is exactly Dirac's 1963 theorem ("minimum degree `3` forces a `K₄`
minor"), which is thereby isolated as the single remaining input for `k = 3`. -/
theorem hadwiger_three_of_dirac
    (dirac : ∀ (W : Type) [Finite W] [Nonempty W] (K : SimpleGraph W),
        (∀ w : W, 3 ≤ Nat.card (K.neighborSet w)) → CompleteMinor 4 K) :
    HadwigerProperty 3 :=
  hadwigerProperty_of_minDegree_forces dirac

/-! ## 8.  A lower bound on the number of edges of a `(k+1)`-chromatic graph -/

/-- An embedding of graphs injects edges, hence bounds edge counts. -/
theorem card_edgeFinset_le_of_embedding {W : Type*} [Fintype V] [Fintype W] [DecidableEq V]
    [DecidableEq W] {H : SimpleGraph W} [DecidableRel H.Adj] (f : H ↪g G) :
    H.edgeFinset.card ≤ G.edgeFinset.card := by
  classical
  refine Finset.card_le_card_of_injOn (fun e => Sym2.map f e) ?_ ?_
  · intro e he
    induction e with
    | _ x y =>
      simp only [Finset.mem_coe, SimpleGraph.mem_edgeFinset, Sym2.map_pair_eq,
        SimpleGraph.mem_edgeSet] at *
      exact f.map_adj_iff.mpr he
  · intro a _ b _ hab
    exact Sym2.map.injective f.injective hab

/-- A vertex subset of minimum degree at least `k` has at least `k + 1` vertices. -/
theorem card_le_card_of_minDegree [Fintype V] [DecidableEq V] {S : Finset V} (hne : S.Nonempty)
    (hdeg : ∀ v ∈ S, k ≤ (S.filter (fun w => G.Adj v w)).card) : k + 1 ≤ S.card := by
  obtain ⟨v, hv⟩ := hne
  have hsub : S.filter (fun w => G.Adj v w) ⊆ S.erase v := by
    intro w hw
    rw [Finset.mem_filter] at hw
    exact Finset.mem_erase.mpr ⟨(G.ne_of_adj hw.2).symm, hw.1⟩
  have h1 : k ≤ (S.erase v).card := le_trans (hdeg v hv) (Finset.card_le_card hsub)
  rw [Finset.card_erase_of_mem hv] at h1
  have h2 : 0 < S.card := Finset.card_pos.mpr ⟨v, hv⟩
  omega

/-- **Critical graphs are dense.**  A finite graph that is not `k`-colourable has
at least `k (k + 1) / 2` edges — stated in doubled form to stay inside `ℕ`.  This
is the classical edge bound for `(k+1)`-chromatic graphs, obtained here from the
colour-critical subgraph of minimum degree `k` via the handshake lemma. -/
theorem mul_succ_le_two_mul_card_edgeFinset_of_not_colorable [Fintype V] [DecidableEq V]
    (h : ¬ G.Colorable k) : k * (k + 1) ≤ 2 * G.edgeFinset.card := by
  classical
  obtain ⟨S, hne, -, hdeg⟩ := exists_subset_minDegree_of_not_colorable h
  set K : SimpleGraph (↑S : Set V) := G.induce (↑S : Set V) with hK
  have hdegK : ∀ w : (↑S : Set V), k ≤ K.degree w := by
    rintro ⟨v, hv⟩
    have hvS : v ∈ S := Finset.mem_coe.mp hv
    have hcard : Nat.card (K.neighborSet ⟨v, hv⟩) = (S.filter (fun w => G.Adj v w)).card :=
      card_neighborSet_induce hvS
    have hdeg' : Nat.card (K.neighborSet ⟨v, hv⟩) = K.degree ⟨v, hv⟩ := by
      rw [Nat.card_eq_fintype_card, K.card_neighborSet_eq_degree]
    rw [← hdeg', hcard]
    exact hdeg v hvS
  have hsum : ∑ w : (↑S : Set V), K.degree w = 2 * K.edgeFinset.card :=
    K.sum_degrees_eq_twice_card_edges
  have hge : k * Fintype.card (↑S : Set V) ≤ ∑ w : (↑S : Set V), K.degree w := by
    calc k * Fintype.card (↑S : Set V) = ∑ _w : (↑S : Set V), k := by
          rw [Finset.sum_const, Finset.card_univ]; ring
      _ ≤ ∑ w : (↑S : Set V), K.degree w := Finset.sum_le_sum fun w _ => hdegK w
  have hcardcoe : Fintype.card (↑S : Set V) = S.card := by
    simp
  have hcardS : k + 1 ≤ S.card := card_le_card_of_minDegree hne hdeg
  have hedge : K.edgeFinset.card ≤ G.edgeFinset.card :=
    card_edgeFinset_le_of_embedding (Embedding.induce (↑S : Set V))
  have hstep : k * (k + 1) ≤ k * S.card := Nat.mul_le_mul_left k hcardS
  rw [hcardcoe] at hge
  omega

end Hadwiger

#print axioms Hadwiger.exists_critical_subset
#print axioms Hadwiger.exists_subset_minDegree_of_not_colorable
#print axioms Hadwiger.hadwigerProperty_of_minDegree_forces
#print axioms Hadwiger.completeMinor_three_of_two_le_degree
#print axioms Hadwiger.hadwiger_two_via_min_degree
#print axioms Hadwiger.hadwiger_three_of_dirac
#print axioms Hadwiger.mul_succ_le_two_mul_card_edgeFinset_of_not_colorable