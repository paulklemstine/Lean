import Mathlib
import Novelty.IndependenceRatioChromatic
import Novelty.IndependenceRatioLowerBound

/-!
# 1-sums (vertex amalgamations), the sharp pigeonhole bound, and its equality case

This file develops the *structure theory of 1-sums* for the colouring / independence-ratio
circle formalised in `Novelty.IndependenceRatioChromatic` and
`Novelty.IndependenceRatioLowerBound`.

A graph `G` is the **1-sum** (vertex amalgamation, clique-sum of order one) of `G₁` and `G₂`
along the cut vertex `v` if `G = G₁ ⊔ G₂`, all edges of `Gᵢ` live inside a side `A` resp. `B`,
the two sides cover the vertex set and meet exactly in `{v}`.  This is `SimpleGraph.IsOneSum`.

Main results.

* `SimpleGraph.IsOneSum.colorable` — **1-sum closure of colourability**: `k`-colourability is
  preserved by 1-sums.  The proof recolours the second side by the transposition that matches
  the two colours of the cut vertex.
* `SimpleGraph.IsOneSum.chromaticNumber_eq_max` — `χ(G) = max (χ G₁) (χ G₂)`.
* `SimpleGraph.IsOneSum.isClique_left_or_right`, `SimpleGraph.IsOneSum.cliqueNum_eq_max` —
  every clique of a 1-sum lies on one side, hence `ω(G) = max (ω G₁) (ω G₂)`.
* `SimpleGraph.IsOneSum.chromaticNumber_eq_cliqueNum` — **weak perfection (`χ = ω`) is closed
  under 1-sums**; the equality analysis is exactly the pair of `max` formulas above.
* `SimpleGraph.IsOneSum.card_add_indicator_eq` — the exact splitting identity for an arbitrary
  vertex set: `|s| + [v ∈ s] = |s ∩ A| + |s ∩ B|`.
* `SimpleGraph.card_eq_colors_mul_indepNum_iff` — **the equality analysis of the sharp
  pigeonhole bound** `n ≤ k·α(G)` of the catalog: equality holds for a `k`-colouring `C`
  precisely when *every* colour class of `C` is a maximum independent set.
* `SimpleGraph.indepRatio_eq_inv_iff` — consequently `i(G) = 1/k` iff all colour classes are
  maximum independent sets, and `SimpleGraph.IsOneSum.indepRatio_ge_quarter` /
  `SimpleGraph.IsOneSum.indepRatio_eq_quarter_iff` transport the sharp bound `i(G) ≥ 1/4`
  and its equality case across a 1-sum of two `4`-colourable graphs.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the two catalog ingredients — the sharp bound `n ≤ k·α` and the
closure of the colouring class under 1-sums — should combine into a *dictionary*: on the
colouring side a 1-sum is a `max`, so every `max`-stable invariant (`χ`, `ω`) is determined by
the pieces, and the conjecture "`i ≥ 1/4` is 1-sum stable" reduces to whether the *ratio* is
`max`-stable too.  Ratios are not `max`-stable (they are mediants), so the prediction is:
colouring closure survives, ratio closure fails.
Experiment (Experimenter): the colouring closure was proved by the transposition recolouring
`x ↦ if x ∈ A then C₁ x else (swap (C₁ v) (C₂ v)) (C₂ x)`; the only delicate case is an edge of
`G₂` incident to the cut vertex, where `swap` is used through `Equiv.swap_apply_left`.  The
clique statement needed the observation that a vertex of `A \ B` and a vertex of `B \ A` are
never adjacent, so a clique cannot straddle the cut.
Analysis (Analyst): the equality analysis of the pigeonhole bound is a `Finset.sum_lt_sum`
argument: `n = ∑_c |C⁻¹ c| ≤ ∑_c α = k·α`, with equality iff no fibre is strictly smaller than
`α`.  This makes "`i(G) = 1/k`" a *balancedness* statement, not a metric accident.
Critique (Critic): `A ∪ B = univ` is load-bearing for the clique and splitting statements
(otherwise a vertex outside both sides is isolated in `G` and joins every independent set but
no side); `A ∩ B = {v}` is load-bearing for the colouring proof (two shared vertices need a
simultaneous match, which a single transposition cannot deliver).  No statement here is
definitional: each `max` formula needs both inequalities and one of them uses the
recolouring.
Synthesis (PI): 1-sums act as `max` on `χ` and `ω` and as a *mediant with a defect `-1`* on
`(α, n)`.  The defect is exactly the cut vertex counted twice, which is what
`card_add_indicator_eq` isolates — and it is what the companion file
`Novelty.OneSumIndepRatioCounterexample` turns into a refutation of ratio closure.
-- !-- end Lab Notes -- !--
-/

open Finset

namespace SimpleGraph

variable {V : Type*} {G G₁ G₂ : SimpleGraph V} {A B : Set V} {v : V}

/-- `G` is the **1-sum** (vertex amalgamation) of `G₁` and `G₂` along the cut vertex `v`:
`G` is the union of the two parts, the part `Gᵢ` has all its edges inside its side (`A` resp.
`B`), the sides cover all vertices and meet exactly in `{v}`. -/
structure IsOneSum (G G₁ G₂ : SimpleGraph V) (A B : Set V) (v : V) : Prop where
  /-- `G` is the edge-union of the two parts. -/
  sup_eq : G = G₁ ⊔ G₂
  /-- All edges of the first part lie inside the side `A`. -/
  left_support : ∀ ⦃x y⦄, G₁.Adj x y → x ∈ A ∧ y ∈ A
  /-- All edges of the second part lie inside the side `B`. -/
  right_support : ∀ ⦃x y⦄, G₂.Adj x y → x ∈ B ∧ y ∈ B
  /-- The two sides meet exactly in the cut vertex. -/
  inter_eq : A ∩ B = {v}
  /-- The two sides cover the vertex set. -/
  union_eq : A ∪ B = Set.univ

namespace IsOneSum

variable (h : IsOneSum G G₁ G₂ A B v)
include h

theorem left_le : G₁ ≤ G := by rw [h.sup_eq]; exact le_sup_left

theorem right_le : G₂ ≤ G := by rw [h.sup_eq]; exact le_sup_right

theorem cut_mem_left : v ∈ A := by
  have : v ∈ A ∩ B := by rw [h.inter_eq]; rfl
  exact this.1

theorem cut_mem_right : v ∈ B := by
  have : v ∈ A ∩ B := by rw [h.inter_eq]; rfl
  exact this.2

/-- A vertex belonging to both sides is the cut vertex. -/
theorem eq_cut_of_mem_both {x : V} (hA : x ∈ A) (hB : x ∈ B) : x = v := by
  have : x ∈ A ∩ B := ⟨hA, hB⟩
  rwa [h.inter_eq, Set.mem_singleton_iff] at this

/-- Every vertex lies on one of the two sides. -/
theorem mem_left_or_right (x : V) : x ∈ A ∨ x ∈ B := by
  have : x ∈ A ∪ B := by rw [h.union_eq]; trivial
  exact this

/-- **1-sum closure of colourability.**  If both parts of a 1-sum are `k`-colourable then so is
the 1-sum.  The colouring of the second side is composed with the transposition matching the
two colours of the cut vertex. -/
theorem colorable {k : ℕ} (h1 : G₁.Colorable k) (h2 : G₂.Colorable k) : G.Colorable k := by
  classical
  obtain ⟨C₁⟩ := h1
  obtain ⟨C₂⟩ := h2
  set s : Fin k ≃ Fin k := Equiv.swap (C₁ v) (C₂ v) with hs
  have hsv : s (C₂ v) = C₁ v := by rw [hs, Equiv.swap_apply_right]
  have hs_eq : ∀ t : Fin k, s t = C₁ v ↔ t = C₂ v := by
    intro t
    constructor
    · intro ht
      have := congrArg s ht
      rwa [Equiv.swap_apply_self, hs, Equiv.swap_apply_left] at this
    · intro ht; rw [ht, hsv]
  refine ⟨SimpleGraph.Coloring.mk (fun x => if x ∈ A then C₁ x else s (C₂ x)) ?_⟩
  intro x y hxy
  have hxy' : G₁.Adj x y ∨ G₂.Adj x y := by rw [h.sup_eq] at hxy; exact hxy
  rcases hxy' with h1 | h2
  · have hx : x ∈ A := (h.left_support h1).1
    have hy : y ∈ A := (h.left_support h1).2
    simp only [hx, hy, if_pos]
    exact C₁.valid h1
  · have hx : x ∈ B := (h.right_support h2).1
    have hy : y ∈ B := (h.right_support h2).2
    have hne : C₂ x ≠ C₂ y := C₂.valid h2
    by_cases hxA : x ∈ A <;> by_cases hyA : y ∈ A
    · -- both sides: forces `x = y = v`, contradicting adjacency
      have hxv : x = v := h.eq_cut_of_mem_both hxA hx
      have hyv : y = v := h.eq_cut_of_mem_both hyA hy
      exact absurd (hxv.trans hyv.symm) h2.ne
    · have hxv : x = v := h.eq_cut_of_mem_both hxA hx
      simp only [hxA, hyA, if_pos, if_false]
      subst hxv
      intro hcon
      exact hne (((hs_eq (C₂ y)).1 hcon.symm).symm)
    · have hyv : y = v := h.eq_cut_of_mem_both hyA hy
      simp only [hxA, hyA, if_pos, if_false]
      subst hyv
      intro hcon
      exact hne ((hs_eq (C₂ x)).1 hcon)
    · simp only [hxA, hyA, if_false]
      exact fun hcon => hne (s.injective hcon)

/-- **The chromatic number of a 1-sum is the maximum of the chromatic numbers.** -/
theorem chromaticNumber_eq_max [Fintype V] :
    G.chromaticNumber = max G₁.chromaticNumber G₂.chromaticNumber := by
  refine le_antisymm ?_ (max_le (chromaticNumber_mono G h.left_le)
    (chromaticNumber_mono G h.right_le))
  have hfin : ∀ H : SimpleGraph V, H.chromaticNumber ≤ (Fintype.card V : ℕ∞) :=
    fun H => chromaticNumber_le_iff_colorable.2 H.colorable_of_fintype
  obtain ⟨n, hn⟩ : ∃ n : ℕ, max G₁.chromaticNumber G₂.chromaticNumber = (n : ℕ∞) := by
    obtain ⟨n1, hn1⟩ := ENat.ne_top_iff_exists.1
      (ne_top_of_le_ne_top (ENat.coe_ne_top _) (hfin G₁))
    obtain ⟨n2, hn2⟩ := ENat.ne_top_iff_exists.1
      (ne_top_of_le_ne_top (ENat.coe_ne_top _) (hfin G₂))
    refine ⟨max n1 n2, ?_⟩
    rw [← hn1, ← hn2]
    rcases le_total n1 n2 with hle | hle
    · rw [max_eq_right hle, max_eq_right (show (n1 : ℕ∞) ≤ n2 by exact_mod_cast hle)]
    · rw [max_eq_left hle, max_eq_left (show (n2 : ℕ∞) ≤ n1 by exact_mod_cast hle)]
  rw [hn]
  refine chromaticNumber_le_iff_colorable.2 (h.colorable ?_ ?_)
  · exact chromaticNumber_le_iff_colorable.1 (hn ▸ le_max_left _ _)
  · exact chromaticNumber_le_iff_colorable.1 (hn ▸ le_max_right _ _)

/-- **A clique of a 1-sum never straddles the cut**: it is a clique of one of the two parts. -/
theorem isClique_left_or_right {s : Set V} (hs : G.IsClique s) :
    G₁.IsClique s ∨ G₂.IsClique s := by
  have key : s ⊆ A ∨ s ⊆ B := by
    by_contra hcon
    push_neg at hcon
    obtain ⟨h1, h2⟩ := hcon
    obtain ⟨x, hxs, hxA⟩ := Set.not_subset.1 h1
    obtain ⟨y, hys, hyB⟩ := Set.not_subset.1 h2
    have hxB : x ∈ B := (h.mem_left_or_right x).resolve_left hxA
    have hyA : y ∈ A := (h.mem_left_or_right y).resolve_right hyB
    have hne : x ≠ y := fun hxy => hxA (hxy ▸ hyA)
    have hadj : G.Adj x y := hs hxs hys hne
    rw [h.sup_eq] at hadj
    rcases hadj with hadj | hadj
    · exact hxA (h.left_support hadj).1
    · exact hyB (h.right_support hadj).2
  rcases key with hA | hB
  · left
    intro x hx y hy hne
    have hadj : G.Adj x y := hs hx hy hne
    rw [h.sup_eq] at hadj
    rcases hadj with hadj | hadj
    · exact hadj
    · exact absurd ((h.eq_cut_of_mem_both (hA hx) (h.right_support hadj).1).trans
        (h.eq_cut_of_mem_both (hA hy) (h.right_support hadj).2).symm) hadj.ne
  · right
    intro x hx y hy hne
    have hadj : G.Adj x y := hs hx hy hne
    rw [h.sup_eq] at hadj
    rcases hadj with hadj | hadj
    · exact absurd ((h.eq_cut_of_mem_both (h.left_support hadj).1 (hB hx)).trans
        (h.eq_cut_of_mem_both (h.left_support hadj).2 (hB hy)).symm) hadj.ne
    · exact hadj

/-- **The clique number of a 1-sum is the maximum of the clique numbers.** -/
theorem cliqueNum_eq_max [Fintype V] :
    G.cliqueNum = max G₁.cliqueNum G₂.cliqueNum := by
  classical
  refine le_antisymm ?_ (max_le ?_ ?_)
  · obtain ⟨s, hs, hcard⟩ := G.exists_isNClique_cliqueNum
    rcases h.isClique_left_or_right hs with hs1 | hs1
    · exact hcard ▸ le_trans (IsClique.card_le_cliqueNum (tc := hs1)) (le_max_left _ _)
    · exact hcard ▸ le_trans (IsClique.card_le_cliqueNum (tc := hs1)) (le_max_right _ _)
  · obtain ⟨s, hs, hcard⟩ := G₁.exists_isNClique_cliqueNum
    exact hcard ▸ IsClique.card_le_cliqueNum (tc := hs.mono h.left_le)
  · obtain ⟨s, hs, hcard⟩ := G₂.exists_isNClique_cliqueNum
    exact hcard ▸ IsClique.card_le_cliqueNum (tc := hs.mono h.right_le)

/-- **Weak perfection is closed under 1-sums.**  If each part satisfies `χ = ω`, so does the
1-sum.  This is the equality analysis of the two `max` formulas. -/
theorem chromaticNumber_eq_cliqueNum [Fintype V]
    (h1 : G₁.chromaticNumber = (G₁.cliqueNum : ℕ∞))
    (h2 : G₂.chromaticNumber = (G₂.cliqueNum : ℕ∞)) :
    G.chromaticNumber = (G.cliqueNum : ℕ∞) := by
  rw [h.chromaticNumber_eq_max, h.cliqueNum_eq_max, h1, h2]
  rcases le_total G₁.cliqueNum G₂.cliqueNum with hle | hle
  · rw [max_eq_right hle, max_eq_right (by exact_mod_cast hle : (G₁.cliqueNum : ℕ∞) ≤ _)]
  · rw [max_eq_left hle, max_eq_left (by exact_mod_cast hle : (G₂.cliqueNum : ℕ∞) ≤ _)]

/-- **The splitting identity of a 1-sum.**  Any finite vertex set `s` splits along the two
sides, and the cut vertex is the only possible double count. -/
theorem card_add_indicator_eq [Fintype V] [DecidableEq V] (s : Finset V)
    [DecidablePred (· ∈ A)] [DecidablePred (· ∈ B)] :
    s.card + (if v ∈ s then 1 else 0)
      = (s.filter (· ∈ A)).card + (s.filter (· ∈ B)).card := by
  have hunion : s.filter (· ∈ A) ∪ s.filter (· ∈ B) = s := by
    ext x
    simp only [Finset.mem_union, Finset.mem_filter]
    constructor
    · rintro (⟨hx, _⟩ | ⟨hx, _⟩) <;> exact hx
    · intro hx
      rcases h.mem_left_or_right x with hA | hB
      · exact Or.inl ⟨hx, hA⟩
      · exact Or.inr ⟨hx, hB⟩
  have hinter : s.filter (· ∈ A) ∩ s.filter (· ∈ B) = s.filter (fun x => x = v) := by
    ext x
    simp only [Finset.mem_inter, Finset.mem_filter]
    constructor
    · rintro ⟨⟨hx, hA⟩, ⟨_, hB⟩⟩
      exact ⟨hx, h.eq_cut_of_mem_both hA hB⟩
    · rintro ⟨hx, rfl⟩
      exact ⟨⟨hx, h.cut_mem_left⟩, ⟨hx, h.cut_mem_right⟩⟩
  have hcard : (s.filter (fun x => x = v)).card = if v ∈ s then 1 else 0 := by
    by_cases hv : v ∈ s
    · rw [if_pos hv, Finset.card_eq_one]
      refine ⟨v, ?_⟩
      ext x
      simp only [Finset.mem_filter, Finset.mem_singleton]
      exact ⟨fun hx => hx.2, fun hx => ⟨hx ▸ hv, hx⟩⟩
    · rw [if_neg hv, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
      rintro x hx rfl
      exact hv hx
  have := Finset.card_union_add_card_inter (s.filter (· ∈ A)) (s.filter (· ∈ B))
  rw [hunion, hinter, hcard] at this
  exact this

end IsOneSum

section Equality

variable {V : Type*} [Fintype V] (G : SimpleGraph V)

/-- **Equality analysis of the sharp pigeonhole bound `n ≤ k·α(G)`.**  For a proper
`k`-colouring `C`, the catalog inequality `card_le_colors_mul_indepNum` is an equality exactly
when every colour class is a *maximum* independent set. -/
theorem card_eq_colors_mul_indepNum_iff {k : ℕ} (C : G.Coloring (Fin k)) :
    Fintype.card V = k * G.indepNum ↔
      ∀ c : Fin k, (Finset.univ.filter (fun x => C x = c)).card = G.indepNum := by
  classical
  have hsum : Fintype.card V
      = ∑ c : Fin k, (Finset.univ.filter (fun x => C x = c)).card := by
    rw [← Finset.card_univ]
    exact Finset.card_eq_sum_card_fiberwise (fun x _ => Finset.mem_univ (C x))
  have hle : ∀ c : Fin k, (Finset.univ.filter (fun x => C x = c)).card ≤ G.indepNum := by
    intro c
    refine IsIndepSet.card_le_indepNum ?_
    intro x hx y hy hne hadj
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hx hy
    exact absurd (hx.trans hy.symm) (C.valid hadj)
  constructor
  · intro heq c
    by_contra hne
    have hlt : (Finset.univ.filter (fun x => C x = c)).card < G.indepNum :=
      lt_of_le_of_ne (hle c) hne
    have : ∑ d : Fin k, (Finset.univ.filter (fun x => C x = d)).card
        < ∑ _d : Fin k, G.indepNum :=
      Finset.sum_lt_sum (fun d _ => hle d) ⟨c, Finset.mem_univ c, hlt⟩
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul] at this
    omega
  · intro hall
    rw [hsum]
    simp only [hall, Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul]

/-- **Equality analysis of the sharp bound `i(G) ≥ 1/k`.**  Given a proper `k`-colouring of a
graph on a nonempty vertex set, the independence ratio attains its lower bound `1/k` exactly
when all `k` colour classes are maximum independent sets. -/
theorem indepRatio_eq_inv_iff {k : ℕ} (C : G.Coloring (Fin k)) (hpos : 0 < Fintype.card V) :
    G.indepRatio = (1 : ℚ) / k ↔
      ∀ c : Fin k, (Finset.univ.filter (fun x => C x = c)).card = G.indepNum := by
  rw [← card_eq_colors_mul_indepNum_iff G C]
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with hk | hk
    · subst hk
      exact absurd (Fintype.card_eq_zero_iff.2 ⟨fun x => Fin.elim0 (C x)⟩) hpos.ne'
    · exact hk
  have hn : (Fintype.card V : ℚ) ≠ 0 := by positivity
  rw [SimpleGraph.indepRatio, div_eq_div_iff hn (by positivity)]
  constructor
  · intro heq
    have : (Fintype.card V : ℚ) = (k : ℚ) * (G.indepNum : ℚ) := by linarith [heq]
    exact_mod_cast this
  · intro heq
    have : (Fintype.card V : ℚ) = (k : ℚ) * (G.indepNum : ℚ) := by exact_mod_cast heq
    linarith [this]

end Equality

namespace IsOneSum

variable {V : Type*} [Fintype V] {G G₁ G₂ : SimpleGraph V} {A B : Set V} {v : V}
variable (h : IsOneSum G G₁ G₂ A B v)
include h

omit [Fintype V] in
/-- **Union lemma for a 1-sum.**  Independent sets of the two parts, each living on its own
side and agreeing about whether they contain the cut vertex, glue to an independent set of the
1-sum. -/
theorem isIndepSet_union [DecidableEq V] {t₁ t₂ : Finset V}
    (ht₁ : ↑t₁ ⊆ A) (ht₂ : ↑t₂ ⊆ B)
    (hi₁ : G₁.IsIndepSet ↑t₁) (hi₂ : G₂.IsIndepSet ↑t₂)
    (hv : v ∈ t₁ ↔ v ∈ t₂) : G.IsIndepSet ↑(t₁ ∪ t₂) := by
  intro x hx y hy hne
  simp only [Finset.coe_union, Set.mem_union, Finset.mem_coe] at hx hy
  rw [h.sup_eq]
  rintro (hadj | hadj)
  · have hxA : x ∈ A := (h.left_support hadj).1
    have hyA : y ∈ A := (h.left_support hadj).2
    have hx1 : x ∈ t₁ := by
      rcases hx with hx | hx
      · exact hx
      · have hxv : x = v := h.eq_cut_of_mem_both hxA (ht₂ hx)
        exact hxv ▸ hv.2 (hxv ▸ hx)
    have hy1 : y ∈ t₁ := by
      rcases hy with hy | hy
      · exact hy
      · have hyv : y = v := h.eq_cut_of_mem_both hyA (ht₂ hy)
        exact hyv ▸ hv.2 (hyv ▸ hy)
    exact hi₁ (Finset.mem_coe.2 hx1) (Finset.mem_coe.2 hy1) hne hadj
  · have hxB : x ∈ B := (h.right_support hadj).1
    have hyB : y ∈ B := (h.right_support hadj).2
    have hx2 : x ∈ t₂ := by
      rcases hx with hx | hx
      · have hxv : x = v := h.eq_cut_of_mem_both (ht₁ hx) hxB
        exact hxv ▸ hv.1 (hxv ▸ hx)
      · exact hx
    have hy2 : y ∈ t₂ := by
      rcases hy with hy | hy
      · have hyv : y = v := h.eq_cut_of_mem_both (ht₁ hy) hyB
        exact hyv ▸ hv.1 (hyv ▸ hy)
      · exact hy
    exact hi₂ (Finset.mem_coe.2 hx2) (Finset.mem_coe.2 hy2) hne hadj

/-- **Superadditivity of independence across a 1-sum**, with the cut vertex as the only
defect: for independent sets `s₁ ⊆ A` of `G₁` and `s₂ ⊆ B` of `G₂` one has
`|s₁| + |s₂| ≤ α(G) + 1`.  Both the bound and the defect `1` are attained. -/
theorem card_add_card_le_indepNum_succ [DecidableEq V] {s₁ s₂ : Finset V}
    (hs₁ : ↑s₁ ⊆ A) (hs₂ : ↑s₂ ⊆ B)
    (hi₁ : G₁.IsIndepSet ↑s₁) (hi₂ : G₂.IsIndepSet ↑s₂) :
    s₁.card + s₂.card ≤ G.indepNum + 1 := by
  by_cases hv1 : v ∈ s₁
  · by_cases hv2 : v ∈ s₂
    · -- both contain the cut vertex: their union is independent and loses exactly one vertex
      have hindep : G.IsIndepSet ↑(s₁ ∪ s₂) :=
        h.isIndepSet_union hs₁ hs₂ hi₁ hi₂ ⟨fun _ => hv2, fun _ => hv1⟩
      have hinter : s₁ ∩ s₂ = {v} := by
        ext x
        simp only [Finset.mem_inter, Finset.mem_singleton]
        exact ⟨fun hx => h.eq_cut_of_mem_both (hs₁ hx.1) (hs₂ hx.2),
          fun hx => hx ▸ ⟨hv1, hv2⟩⟩
      have hcard := Finset.card_union_add_card_inter s₁ s₂
      rw [hinter, Finset.card_singleton] at hcard
      have := hindep.card_le_indepNum
      omega
    · -- only the first contains the cut vertex: erase it there
      have hindep : G.IsIndepSet ↑(s₁.erase v ∪ s₂) := by
        refine h.isIndepSet_union
          (fun x hx => hs₁ (Finset.mem_coe.2 (Finset.mem_of_mem_erase (Finset.mem_coe.1 hx))))
          hs₂
          (hi₁.mono (by simp)) hi₂ ?_
        simp [hv2]
      have hdisj : Disjoint (s₁.erase v) s₂ := by
        refine Finset.disjoint_left.2 fun x hx hx2 => ?_
        have hxv : x = v :=
          h.eq_cut_of_mem_both (hs₁ (Finset.mem_coe.2 (Finset.mem_of_mem_erase hx))) (hs₂ hx2)
        exact (Finset.ne_of_mem_erase hx) hxv
      have hcard := Finset.card_union_of_disjoint hdisj
      have herase := Finset.card_erase_of_mem hv1
      have hpos : 1 ≤ s₁.card := Finset.card_pos.2 ⟨v, hv1⟩
      have := hindep.card_le_indepNum
      omega
  · -- the first avoids the cut vertex: erase it from the second
    have hindep : G.IsIndepSet ↑(s₁ ∪ s₂.erase v) := by
      refine h.isIndepSet_union hs₁
        (fun x hx => hs₂ (Finset.mem_coe.2 (Finset.mem_of_mem_erase (Finset.mem_coe.1 hx)))) hi₁
        (hi₂.mono (by simp)) ?_
      simp [hv1]
    have hdisj : Disjoint s₁ (s₂.erase v) := by
      refine Finset.disjoint_left.2 fun x hx hx2 => ?_
      have hxv : x = v :=
        h.eq_cut_of_mem_both (hs₁ hx) (hs₂ (Finset.mem_coe.2 (Finset.mem_of_mem_erase hx2)))
      exact (Finset.ne_of_mem_erase hx2) hxv
    have hcard := Finset.card_union_of_disjoint hdisj
    have herase : s₂.card ≤ (s₂.erase v).card + 1 := by
      by_cases hv2 : v ∈ s₂
      · rw [Finset.card_erase_of_mem hv2]
        have : 1 ≤ s₂.card := Finset.card_pos.2 ⟨v, hv2⟩
        omega
      · rw [Finset.erase_eq_of_notMem hv2]; omega
    have := hindep.card_le_indepNum
    omega

/-- **The sharp "mediant with defect" bound for the independence ratio of a 1-sum.**  If both
sides carry independent sets of relative density at least `r`, then the 1-sum has independence
ratio at least `r - (1 - r)/n`.  The subtracted term is exactly the cut-vertex defect, and the
companion file `Novelty.OneSumIndepRatioCounterexample` exhibits a 1-sum attaining it. -/
theorem indepRatio_ge_of_sides [DecidableEq V] [DecidablePred (· ∈ A)] [DecidablePred (· ∈ B)]
    {s₁ s₂ : Finset V} (hs₁ : ↑s₁ ⊆ A) (hs₂ : ↑s₂ ⊆ B)
    (hi₁ : G₁.IsIndepSet ↑s₁) (hi₂ : G₂.IsIndepSet ↑s₂) {r : ℚ}
    (hr₁ : r * ((Finset.univ.filter (· ∈ A)).card : ℚ) ≤ (s₁.card : ℚ))
    (hr₂ : r * ((Finset.univ.filter (· ∈ B)).card : ℚ) ≤ (s₂.card : ℚ))
    (hpos : 0 < Fintype.card V) :
    r - (1 - r) / (Fintype.card V : ℚ) ≤ G.indepRatio := by
  have hn : (0 : ℚ) < (Fintype.card V : ℚ) := by exact_mod_cast hpos
  have hsplit := h.card_add_indicator_eq (Finset.univ : Finset V)
  rw [if_pos (Finset.mem_univ v), Finset.card_univ] at hsplit
  have hsplitQ : ((Fintype.card V : ℚ)) + 1
      = ((Finset.univ.filter (· ∈ A)).card : ℚ) + ((Finset.univ.filter (· ∈ B)).card : ℚ) := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℚ)) hsplit
  have hα : (s₁.card : ℚ) + (s₂.card : ℚ) ≤ (G.indepNum : ℚ) + 1 := by
    exact_mod_cast h.card_add_card_le_indepNum_succ hs₁ hs₂ hi₁ hi₂
  have hkey : r * ((Fintype.card V : ℚ) + 1) - 1 ≤ (G.indepNum : ℚ) := by
    rw [hsplitQ, mul_add]
    linarith
  rw [SimpleGraph.indepRatio, le_div_iff₀ hn, sub_mul, div_mul_cancel₀ _ (ne_of_gt hn)]
  nlinarith [hkey]

/-- **The sharp independence-ratio bound transported across a 1-sum.**  A 1-sum of two
`4`-colourable graphs has independence ratio at least `1/4`. -/
theorem indepRatio_ge_quarter (hpos : 0 < Fintype.card V)
    (h1 : G₁.Colorable 4) (h2 : G₂.Colorable 4) : (1 : ℚ) / 4 ≤ G.indepRatio :=
  G.indepRatio_ge_quarter_of_colorable_four hpos (h.colorable h1 h2)

/-- **Equality case for a 1-sum of `4`-colourable graphs.**  The amalgamated graph meets the
sharp bound `i(G) = 1/4` exactly when the four classes of the amalgamated colouring are all
maximum independent sets. -/
theorem indepRatio_eq_quarter_iff (hpos : 0 < Fintype.card V)
    (h1 : G₁.Colorable 4) (h2 : G₂.Colorable 4) :
    G.indepRatio = (1 : ℚ) / 4 ↔
      ∀ C : G.Coloring (Fin 4), ∀ c : Fin 4,
        (Finset.univ.filter (fun x => C x = c)).card = G.indepNum := by
  obtain ⟨C₀⟩ := h.colorable h1 h2
  constructor
  · intro heq C c
    exact (indepRatio_eq_inv_iff G C hpos).1 (by simpa using heq) c
  · intro hall
    have := (indepRatio_eq_inv_iff G C₀ hpos).2 (hall C₀)
    simpa using this

end IsOneSum

end SimpleGraph