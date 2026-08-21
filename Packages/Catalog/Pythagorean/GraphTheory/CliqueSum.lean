/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Clique sums: independence number and chromatic number

A *clique sum* of two graphs `G₁`, `G₂` glues them along a common clique `K`.
We model this on a single ambient (finite) vertex type `V`: the two *sides* are
finsets `s t : Finset V` with `s ∪ t = univ` and `s ∩ t = K`; the graph `G₁`
has all of its edges inside `s`, the graph `G₂` has all of its edges inside `t`,
and `G = G₁ ⊔ G₂`.

Two variants are isolated, because they behave very differently:

* `IsWeakCliqueSum` only asks that `K` be a clique **of the glued graph `G`**;
* `IsCliqueSum` asks that `K` be a clique **on each side** (`G₁` and `G₂`).

## Main results

* `IsIndepFinset.card_inter_le_one` : an independent set meets a clique at most once.
* `IsCliqueSum.indepNumOn_add_le_add_two` : `α(G) ≥ α₁ + α₂ - 2`.
* `IsCliqueSum.indepNumOn_add_le_add_one` : `α(G) ≥ α₁ + α₂ - 1` **provided `|K| ≤ 1`**.
  (The naive bound `α(G) ≥ α₁ + α₂ - 1` is *false* for `|K| ≥ 2`; see
  `CliqueSumSharpness.lean`.)
* `IsCliqueSum.colorable` : if both sides are `n`-colorable then so is `G`.
* `IsCliqueSum.chromaticNumber_eq_max` : `χ(G) = max (χ G₁) (χ G₂)`.
* `IsCliqueSum.card_le_of_colorable` : if a side is `n`-colorable then `k = |K| ≤ n`;
  i.e. the hypothesis "`n ≥ k`" is automatic for genuine clique sums, and it is
  exactly what fails in the weak setting (see `CliqueSumSharpness.lean`).
-/

namespace Catalog.Pythagorean.CliqueSum

open Finset SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Definitions -/

/-- `G` is a *weak clique sum* of `G₁` and `G₂` along `K`: the sides `s`, `t` cover the
vertex set and meet in `K`, all edges of `G₁` lie in `s`, all edges of `G₂` lie in `t`,
`G = G₁ ⊔ G₂`, and `K` is a clique of `G`. -/
structure IsWeakCliqueSum (G G₁ G₂ : SimpleGraph V) (s t K : Finset V) : Prop where
  sup_eq : G = G₁ ⊔ G₂
  union_eq : s ∪ t = Finset.univ
  inter_eq : s ∩ t = K
  mem_left : ∀ ⦃a b⦄, G₁.Adj a b → a ∈ s ∧ b ∈ s
  mem_right : ∀ ⦃a b⦄, G₂.Adj a b → a ∈ t ∧ b ∈ t
  isClique : G.IsClique (K : Set V)

/-- `G` is a *clique sum* of `G₁` and `G₂` along the clique `K`: as in
`IsWeakCliqueSum`, but `K` is required to be a clique on **each** side. -/
structure IsCliqueSum (G G₁ G₂ : SimpleGraph V) (s t K : Finset V) : Prop where
  sup_eq : G = G₁ ⊔ G₂
  union_eq : s ∪ t = Finset.univ
  inter_eq : s ∩ t = K
  mem_left : ∀ ⦃a b⦄, G₁.Adj a b → a ∈ s ∧ b ∈ s
  mem_right : ∀ ⦃a b⦄, G₂.Adj a b → a ∈ t ∧ b ∈ t
  isClique_left : G₁.IsClique (K : Set V)
  isClique_right : G₂.IsClique (K : Set V)

/-- A finset version of independence: no two (not necessarily distinct) members are adjacent. -/
def IsIndepFinset (G : SimpleGraph V) (A : Finset V) : Prop :=
  ∀ a ∈ A, ∀ b ∈ A, ¬ G.Adj a b

instance (G : SimpleGraph V) [DecidableRel G.Adj] : DecidablePred (IsIndepFinset G) :=
  fun A => inferInstanceAs (Decidable (∀ a ∈ A, ∀ b ∈ A, ¬ G.Adj a b))

open Classical in
/-- The independence number of `G` *restricted to the vertex set `s`*: the largest size of
an independent set of `G` contained in `s`. -/
noncomputable def indepNumOn (G : SimpleGraph V) (s : Finset V) : ℕ :=
  ((s.powerset).filter (IsIndepFinset G)).sup Finset.card

/-! ## Basic lemmas -/

lemma IsCliqueSum.toWeak {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) : IsWeakCliqueSum G G₁ G₂ s t K where
  sup_eq := h.sup_eq
  union_eq := h.union_eq
  inter_eq := h.inter_eq
  mem_left := h.mem_left
  mem_right := h.mem_right
  isClique := by
    intro a ha b hb hab
    have := h.isClique_left ha hb hab
    rw [h.sup_eq]
    exact Or.inl this

omit [Fintype V] [DecidableEq V] in
lemma IsIndepFinset.mono {G : SimpleGraph V} {A B : Finset V} (h : IsIndepFinset G A)
    (hBA : B ⊆ A) : IsIndepFinset G B :=
  fun a ha b hb => h a (hBA ha) b (hBA hb)

omit [Fintype V] in
/-- **An independent set meets a clique at most once.** -/
lemma IsIndepFinset.card_inter_le_one {G : SimpleGraph V} {A K : Finset V}
    (hA : IsIndepFinset G A) (hK : G.IsClique (K : Set V)) : (A ∩ K).card ≤ 1 := by
  rw [Finset.card_le_one]
  intro a ha b hb
  by_contra hab
  simp only [Finset.mem_inter] at ha hb
  exact hA a ha.1 b hb.1 (hK ha.2 hb.2 hab)

lemma card_le_indepNumOn {G : SimpleGraph V} {s A : Finset V} (hAs : A ⊆ s)
    (hA : IsIndepFinset G A) : A.card ≤ indepNumOn G s := by
  classical
  refine Finset.le_sup (f := Finset.card) ?_
  simp only [Finset.mem_filter, Finset.mem_powerset]
  exact ⟨hAs, hA⟩

lemma indepNumOn_le {G : SimpleGraph V} {s : Finset V} {n : ℕ}
    (h : ∀ A ⊆ s, IsIndepFinset G A → A.card ≤ n) : indepNumOn G s ≤ n := by
  classical
  refine Finset.sup_le ?_
  intro A hA
  simp only [Finset.mem_filter, Finset.mem_powerset] at hA
  exact h A hA.1 hA.2

lemma exists_indepNumOn (G : SimpleGraph V) (s : Finset V) :
    ∃ A ⊆ s, IsIndepFinset G A ∧ A.card = indepNumOn G s := by
  classical
  have hne : ((s.powerset).filter (IsIndepFinset G)).Nonempty := by
    refine ⟨∅, ?_⟩
    simp only [Finset.mem_filter, Finset.mem_powerset, Finset.empty_subset, true_and]
    intro a ha
    simp at ha
  obtain ⟨A, hA, hAeq⟩ := Finset.exists_mem_eq_sup _ hne Finset.card
  simp only [Finset.mem_filter, Finset.mem_powerset] at hA
  exact ⟨A, hA.1, hA.2, hAeq.symm⟩

/-! ## The independence number of a clique sum -/

/-- The key gluing lemma: if two independent sets (one on each side) meet `K` in the *same*
set, their union is independent in the clique sum. -/
lemma IsWeakCliqueSum.isIndepFinset_union {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsWeakCliqueSum G G₁ G₂ s t K) {A₁ A₂ : Finset V} (hA₁s : A₁ ⊆ s) (hA₂t : A₂ ⊆ t)
    (h₁ : IsIndepFinset G₁ A₁) (h₂ : IsIndepFinset G₂ A₂) (hK : A₁ ∩ K = A₂ ∩ K) :
    IsIndepFinset G (A₁ ∪ A₂) := by
  have hmemK : ∀ {x : V}, x ∈ s → x ∈ t → x ∈ K := by
    intro x hxs hxt
    rw [← h.inter_eq]
    exact Finset.mem_inter.2 ⟨hxs, hxt⟩
  -- membership in `K` transfers between the two independent sets
  have hK₁ : ∀ {x : V}, x ∈ A₁ → x ∈ K → x ∈ A₂ := by
    intro x hx hxK
    have : x ∈ A₁ ∩ K := Finset.mem_inter.2 ⟨hx, hxK⟩
    rw [hK] at this
    exact (Finset.mem_inter.1 this).1
  have hK₂ : ∀ {x : V}, x ∈ A₂ → x ∈ K → x ∈ A₁ := by
    intro x hx hxK
    have : x ∈ A₂ ∩ K := Finset.mem_inter.2 ⟨hx, hxK⟩
    rw [← hK] at this
    exact (Finset.mem_inter.1 this).1
  intro a ha b hb hab
  rw [h.sup_eq] at hab
  rcases Finset.mem_union.1 ha with ha1 | ha2 <;> rcases Finset.mem_union.1 hb with hb1 | hb2
  · rcases hab with hab | hab
    · exact h₁ a ha1 b hb1 hab
    · obtain ⟨hat, hbt⟩ := h.mem_right hab
      exact h₂ a (hK₁ ha1 (hmemK (hA₁s ha1) hat)) b (hK₁ hb1 (hmemK (hA₁s hb1) hbt)) hab
  · rcases hab with hab | hab
    · obtain ⟨_, hbs⟩ := h.mem_left hab
      exact h₁ a ha1 b (hK₂ hb2 (hmemK hbs (hA₂t hb2))) hab
    · obtain ⟨hat, _⟩ := h.mem_right hab
      exact h₂ a (hK₁ ha1 (hmemK (hA₁s ha1) hat)) b hb2 hab
  · rcases hab with hab | hab
    · obtain ⟨has, _⟩ := h.mem_left hab
      exact h₁ a (hK₂ ha2 (hmemK has (hA₂t ha2))) b hb1 hab
    · obtain ⟨_, hbt⟩ := h.mem_right hab
      exact h₂ a ha2 b (hK₁ hb1 (hmemK (hA₁s hb1) hbt)) hab
  · rcases hab with hab | hab
    · obtain ⟨has, hbs⟩ := h.mem_left hab
      exact h₁ a (hK₂ ha2 (hmemK has (hA₂t ha2))) b (hK₂ hb2 (hmemK hbs (hA₂t hb2))) hab
    · exact h₂ a ha2 b hb2 hab

/-- Removing `K` from both sides always produces an independent set of the clique sum. -/
lemma IsWeakCliqueSum.isIndepFinset_union_sdiff {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsWeakCliqueSum G G₁ G₂ s t K) {A₁ A₂ : Finset V} (hA₁s : A₁ ⊆ s) (hA₂t : A₂ ⊆ t)
    (h₁ : IsIndepFinset G₁ A₁) (h₂ : IsIndepFinset G₂ A₂) :
    IsIndepFinset G ((A₁ \ K) ∪ (A₂ \ K)) := by
  refine h.isIndepFinset_union (fun x hx => hA₁s (Finset.mem_sdiff.1 hx).1)
    (fun x hx => hA₂t (Finset.mem_sdiff.1 hx).1) (h₁.mono Finset.sdiff_subset)
    (h₂.mono Finset.sdiff_subset) ?_
  ext x
  simp only [Finset.mem_inter, Finset.mem_sdiff]
  tauto

/-- **`α(G) ≥ α₁ + α₂ - 2` for a clique sum.** (Stated without truncated subtraction.)
This is sharp: see `CliqueSumSharpness.lean`. -/
theorem IsCliqueSum.indepNumOn_add_le_add_two {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) :
    indepNumOn G₁ s + indepNumOn G₂ t ≤ indepNumOn G Finset.univ + 2 := by
  obtain ⟨A₁, hA₁s, h₁, hc₁⟩ := exists_indepNumOn G₁ s
  obtain ⟨A₂, hA₂t, h₂, hc₂⟩ := exists_indepNumOn G₂ t
  have hind := h.toWeak.isIndepFinset_union_sdiff hA₁s hA₂t h₁ h₂
  have hcard := card_le_indepNumOn (Finset.subset_univ _) hind
  -- the two pieces are disjoint
  have hdisj : Disjoint (A₁ \ K) (A₂ \ K) := by
    rw [Finset.disjoint_left]
    intro x hx hx'
    rw [Finset.mem_sdiff] at hx hx'
    have : x ∈ s ∩ t := Finset.mem_inter.2 ⟨hA₁s hx.1, hA₂t hx'.1⟩
    rw [h.inter_eq] at this
    exact hx.2 this
  rw [Finset.card_union_of_disjoint hdisj] at hcard
  have e₁ : (A₁ \ K).card + (A₁ ∩ K).card = A₁.card := Finset.card_sdiff_add_card_inter _ _
  have e₂ : (A₂ \ K).card + (A₂ ∩ K).card = A₂.card := Finset.card_sdiff_add_card_inter _ _
  have b₁ : (A₁ ∩ K).card ≤ 1 := h₁.card_inter_le_one h.isClique_left
  have b₂ : (A₂ ∩ K).card ≤ 1 := h₂.card_inter_le_one h.isClique_right
  omega

/-- **`α(G) ≥ α₁ + α₂ - 1` for a clique sum along a clique with at most one vertex**
(`k ≤ 1`).  For `k ≥ 2` this fails; see `CliqueSumSharpness.lean`. -/
theorem IsCliqueSum.indepNumOn_add_le_add_one {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) (hk : K.card ≤ 1) :
    indepNumOn G₁ s + indepNumOn G₂ t ≤ indepNumOn G Finset.univ + 1 := by
  obtain ⟨A₁, hA₁s, h₁, hc₁⟩ := exists_indepNumOn G₁ s
  obtain ⟨A₂, hA₂t, h₂, hc₂⟩ := exists_indepNumOn G₂ t
  have hsub₁ : A₁ ∩ K ⊆ K := Finset.inter_subset_right
  have hsub₂ : A₂ ∩ K ⊆ K := Finset.inter_subset_right
  by_cases hEq : A₁ ∩ K = A₂ ∩ K
  · have hind := h.toWeak.isIndepFinset_union hA₁s hA₂t h₁ h₂ hEq
    have hcard := card_le_indepNumOn (Finset.subset_univ _) hind
    have hun : (A₁ ∪ A₂).card + (A₁ ∩ A₂).card = A₁.card + A₂.card :=
      Finset.card_union_add_card_inter _ _
    have hinter : A₁ ∩ A₂ ⊆ K := by
      intro x hx
      rw [Finset.mem_inter] at hx
      rw [← h.inter_eq]
      exact Finset.mem_inter.2 ⟨hA₁s hx.1, hA₂t hx.2⟩
    have : (A₁ ∩ A₂).card ≤ 1 := le_trans (Finset.card_le_card hinter) hk
    omega
  · -- the intersections differ, hence (as `|K| ≤ 1`) one of them is empty
    have hone : A₁ ∩ K = ∅ ∨ A₂ ∩ K = ∅ := by
      by_contra hcon
      push_neg at hcon
      obtain ⟨hne₁, hne₂⟩ := hcon
      obtain ⟨x, hx⟩ := hne₁
      obtain ⟨y, hy⟩ := hne₂
      have hxy : x = y := by
        have hx' : x ∈ K := hsub₁ hx
        have hy' : y ∈ K := hsub₂ hy
        exact Finset.card_le_one.1 hk x hx' y hy'
      apply hEq
      apply Finset.Subset.antisymm
      · intro z hz
        have : z = x := Finset.card_le_one.1 (le_trans (Finset.card_le_card hsub₁) hk) z hz x hx
        rw [this, hxy]; exact hy
      · intro z hz
        have : z = y := Finset.card_le_one.1 (le_trans (Finset.card_le_card hsub₂) hk) z hz y hy
        rw [this, ← hxy]; exact hx
    rcases hone with hz | hz
    · -- `A₁` misses `K`: glue `A₁` with `A₂ \ K`
      have hEq' : A₁ ∩ K = (A₂ \ K) ∩ K := by
        rw [hz]
        ext x
        simp only [Finset.mem_inter, Finset.mem_sdiff, Finset.notMem_empty]
        tauto
      have hind := h.toWeak.isIndepFinset_union hA₁s
        (fun x hx => hA₂t (Finset.mem_sdiff.1 hx).1) h₁ (h₂.mono Finset.sdiff_subset) hEq'
      have hcard := card_le_indepNumOn (Finset.subset_univ _) hind
      have hun : (A₁ ∪ (A₂ \ K)).card + (A₁ ∩ (A₂ \ K)).card = A₁.card + (A₂ \ K).card :=
        Finset.card_union_add_card_inter _ _
      have hinter : A₁ ∩ (A₂ \ K) = ∅ := by
        ext x
        simp only [Finset.mem_inter, Finset.mem_sdiff, Finset.notMem_empty, iff_false]
        rintro ⟨hx1, hx2, hx3⟩
        apply hx3
        rw [← h.inter_eq]
        exact Finset.mem_inter.2 ⟨hA₁s hx1, hA₂t hx2⟩
      rw [hinter] at hun
      have e₂ : (A₂ \ K).card + (A₂ ∩ K).card = A₂.card := Finset.card_sdiff_add_card_inter _ _
      have b₂ : (A₂ ∩ K).card ≤ 1 := le_trans (Finset.card_le_card hsub₂) hk
      simp only [Finset.card_empty] at hun
      omega
    · -- `A₂` misses `K`: glue `A₁ \ K` with `A₂`
      have hEq' : (A₁ \ K) ∩ K = A₂ ∩ K := by
        rw [hz]
        ext x
        simp only [Finset.mem_inter, Finset.mem_sdiff, Finset.notMem_empty]
        tauto
      have hind := h.toWeak.isIndepFinset_union
        (fun x hx => hA₁s (Finset.mem_sdiff.1 hx).1) hA₂t (h₁.mono Finset.sdiff_subset) h₂ hEq'
      have hcard := card_le_indepNumOn (Finset.subset_univ _) hind
      have hun : ((A₁ \ K) ∪ A₂).card + ((A₁ \ K) ∩ A₂).card = (A₁ \ K).card + A₂.card :=
        Finset.card_union_add_card_inter _ _
      have hinter : (A₁ \ K) ∩ A₂ = ∅ := by
        ext x
        simp only [Finset.mem_inter, Finset.mem_sdiff, Finset.notMem_empty, iff_false]
        rintro ⟨⟨hx1, hx3⟩, hx2⟩
        apply hx3
        rw [← h.inter_eq]
        exact Finset.mem_inter.2 ⟨hA₁s hx1, hA₂t hx2⟩
      rw [hinter] at hun
      have e₁ : (A₁ \ K).card + (A₁ ∩ K).card = A₁.card := Finset.card_sdiff_add_card_inter _ _
      have b₁ : (A₁ ∩ K).card ≤ 1 := le_trans (Finset.card_le_card hsub₁) hk
      simp only [Finset.card_empty] at hun
      omega

/-- For a clique sum along the empty clique (a disjoint union) the independence numbers
simply add. -/
theorem IsCliqueSum.indepNumOn_add_le_of_card_eq_zero {G G₁ G₂ : SimpleGraph V}
    {s t K : Finset V} (h : IsCliqueSum G G₁ G₂ s t K) (hk : K.card = 0) :
    indepNumOn G₁ s + indepNumOn G₂ t ≤ indepNumOn G Finset.univ := by
  have hK : K = ∅ := Finset.card_eq_zero.1 hk
  obtain ⟨A₁, hA₁s, h₁, hc₁⟩ := exists_indepNumOn G₁ s
  obtain ⟨A₂, hA₂t, h₂, hc₂⟩ := exists_indepNumOn G₂ t
  have hEq : A₁ ∩ K = A₂ ∩ K := by rw [hK, Finset.inter_empty, Finset.inter_empty]
  have hind := h.toWeak.isIndepFinset_union hA₁s hA₂t h₁ h₂ hEq
  have hcard := card_le_indepNumOn (Finset.subset_univ _) hind
  have hun : (A₁ ∪ A₂).card + (A₁ ∩ A₂).card = A₁.card + A₂.card :=
    Finset.card_union_add_card_inter _ _
  have hinter : A₁ ∩ A₂ = ∅ := by
    rw [← Finset.subset_empty, ← hK, ← h.inter_eq]
    intro x hx
    rw [Finset.mem_inter] at hx
    exact Finset.mem_inter.2 ⟨hA₁s hx.1, hA₂t hx.2⟩
  rw [hinter, Finset.card_empty] at hun
  omega

/-- **The sharp uniform bound**: `α₁ + α₂ ≤ α(G) + min(k, 2)`, where `k = |K|`.
All three regimes `k = 0`, `k = 1`, `k ≥ 2` are attained (see `CliqueSumSharpness.lean`). -/
theorem IsCliqueSum.indepNumOn_add_le_add_min {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) :
    indepNumOn G₁ s + indepNumOn G₂ t ≤ indepNumOn G Finset.univ + min K.card 2 := by
  rcases Nat.lt_or_ge K.card 2 with hk | hk
  · interval_cases hK : K.card
    · simpa using h.indepNumOn_add_le_of_card_eq_zero hK
    · simpa using h.indepNumOn_add_le_add_one (le_of_eq hK)
  · have := h.indepNumOn_add_le_add_two
    rw [min_eq_right hk]
    exact this

/-! ## The chromatic number of a clique sum -/

/-- In a genuine clique sum, the number of colours available on either side is at least
`k = |K|`: the hypothesis `n ≥ k` is automatic. -/
theorem IsCliqueSum.card_le_of_colorable {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) {n : ℕ} (h₁ : G₁.Colorable n) : K.card ≤ n := by
  obtain ⟨c⟩ := h₁
  classical
  have hinj : Set.InjOn c (K : Set V) := by
    intro a ha b hb hab
    by_contra hne
    exact c.valid (h.isClique_left ha hb hne) hab
  have : (K.image c).card = K.card := Finset.card_image_of_injOn hinj
  calc K.card = (K.image c).card := this.symm
    _ ≤ Fintype.card (Fin n) := Finset.card_le_univ _
    _ = n := Fintype.card_fin n

/-- **Colour transfer**: an `n`-colouring of each side of a clique sum yields an
`n`-colouring of the clique sum. -/
theorem IsCliqueSum.colorable {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) {n : ℕ} (h₁ : G₁.Colorable n) (h₂ : G₂.Colorable n) :
    G.Colorable n := by
  classical
  obtain ⟨c₁⟩ := h₁
  obtain ⟨c₂⟩ := h₂
  set f₁ : {v // v ∈ K} → Fin n := fun v => c₁ v.1 with hf₁def
  set f₂ : {v // v ∈ K} → Fin n := fun v => c₂ v.1 with hf₂def
  have hf₁ : Function.Injective f₁ := by
    rintro ⟨a, ha⟩ ⟨b, hb⟩ hab
    by_contra hne
    have hne' : a ≠ b := fun h' => hne (by simp [h'])
    exact c₁.valid (h.isClique_left ha hb hne') hab
  have hf₂ : Function.Injective f₂ := by
    rintro ⟨a, ha⟩ ⟨b, hb⟩ hab
    by_contra hne
    have hne' : a ≠ b := fun h' => hne (by simp [h'])
    exact c₂.valid (h.isClique_right ha hb hne') hab
  -- the bijection `c₂ v ↦ c₁ v` on `K`, extended to a permutation of the colours
  let e : Set.range f₂ ≃ Set.range f₁ :=
    (Equiv.ofInjective f₂ hf₂).symm.trans (Equiv.ofInjective f₁ hf₁)
  let σ : Equiv.Perm (Fin n) := Equiv.extendSubtype e
  have hσ : ∀ v ∈ K, σ (c₂ v) = c₁ v := by
    intro v hv
    have hmem : c₂ v ∈ Set.range f₂ := ⟨⟨v, hv⟩, rfl⟩
    have := Equiv.extendSubtype_apply_of_mem e (c₂ v) hmem
    rw [show σ (c₂ v) = Equiv.extendSubtype e (c₂ v) from rfl, this]
    have hsymm : (Equiv.ofInjective f₂ hf₂).symm ⟨c₂ v, hmem⟩ = ⟨v, hv⟩ := by
      rw [Equiv.symm_apply_eq]
      rfl
    show ((e ⟨c₂ v, hmem⟩ : Set.range f₁) : Fin n) = c₁ v
    simp only [e, Equiv.trans_apply, hsymm]
    rfl
  -- the glued colouring
  refine ⟨SimpleGraph.Coloring.mk (fun v => if v ∈ s then c₁ v else σ (c₂ v)) ?_⟩
  intro a b hab
  have hab' : G₁.Adj a b ∨ G₂.Adj a b := by rw [h.sup_eq] at hab; exact hab
  rcases hab' with hadj | hadj
  · obtain ⟨has, hbs⟩ := h.mem_left hadj
    simp only [if_pos has, if_pos hbs]
    exact c₁.valid hadj
  · obtain ⟨hat, hbt⟩ := h.mem_right hadj
    have key : ∀ x ∈ t, (if x ∈ s then c₁ x else σ (c₂ x)) = σ (c₂ x) := by
      intro x hx
      by_cases hxs : x ∈ s
      · have hxK : x ∈ K := by
          rw [← h.inter_eq]; exact Finset.mem_inter.2 ⟨hxs, hx⟩
        simp only [if_pos hxs, hσ x hxK]
      · simp only [if_neg hxs]
    show ¬ ((if a ∈ s then c₁ a else σ (c₂ a)) = (if b ∈ s then c₁ b else σ (c₂ b)))
    rw [key a hat, key b hbt]
    intro hcon
    exact c₂.valid hadj (σ.injective hcon)

/-- **`χ(G) = max (χ G₁) (χ G₂)` for a clique sum.** -/
theorem IsCliqueSum.chromaticNumber_eq_max {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) :
    G.chromaticNumber = max G₁.chromaticNumber G₂.chromaticNumber := by
  classical
  have hle₁ : G₁ ≤ G := by rw [h.sup_eq]; exact le_sup_left
  have hle₂ : G₂ ≤ G := by rw [h.sup_eq]; exact le_sup_right
  refine le_antisymm ?_ ?_
  · -- upper bound: colour both sides with `max` colours and glue
    set n₁ := ENat.toNat G₁.chromaticNumber with hn₁
    set n₂ := ENat.toNat G₂.chromaticNumber with hn₂
    have hc₁ : G₁.Colorable n₁ := SimpleGraph.colorable_chromaticNumber_of_fintype G₁
    have hc₂ : G₂.Colorable n₂ := SimpleGraph.colorable_chromaticNumber_of_fintype G₂
    have hG : G.Colorable (max n₁ n₂) :=
      h.colorable (hc₁.mono (le_max_left _ _)) (hc₂.mono (le_max_right _ _))
    have hne₁ : G₁.chromaticNumber ≠ ⊤ :=
      ne_top_of_le_ne_top (by simp) (SimpleGraph.Colorable.chromaticNumber_le hc₁)
    have hne₂ : G₂.chromaticNumber ≠ ⊤ :=
      ne_top_of_le_ne_top (by simp) (SimpleGraph.Colorable.chromaticNumber_le hc₂)
    have hfin₁ : G₁.chromaticNumber = (n₁ : ℕ∞) := by rw [hn₁, ENat.coe_toNat hne₁]
    have hfin₂ : G₂.chromaticNumber = (n₂ : ℕ∞) := by rw [hn₂, ENat.coe_toNat hne₂]
    have hmax : ((max n₁ n₂ : ℕ) : ℕ∞) = max (n₁ : ℕ∞) (n₂ : ℕ∞) := by
      rcases le_total n₁ n₂ with h' | h'
      · rw [max_eq_right h', max_eq_right (by exact_mod_cast h' : (n₁ : ℕ∞) ≤ n₂)]
      · rw [max_eq_left h', max_eq_left (by exact_mod_cast h' : (n₂ : ℕ∞) ≤ n₁)]
    rw [hfin₁, hfin₂, ← hmax]
    exact SimpleGraph.Colorable.chromaticNumber_le hG
  · exact max_le (SimpleGraph.chromaticNumber_mono G hle₁) (SimpleGraph.chromaticNumber_mono G hle₂)

end Catalog.Pythagorean.CliqueSum