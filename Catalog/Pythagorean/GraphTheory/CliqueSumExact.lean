/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Pythagorean.GraphTheory.CliqueSum

/-!
# Exact invariants of a clique sum

`CliqueSum.lean` proves the inequality `α(G) ≥ α₁ + α₂ - 2` and shows (in
`CliqueSumSharpness.lean`) that it is sharp but that the classical `-1` version is
false. This file explains *why*, by computing `α(G)` exactly, and by computing the
clique number of a clique sum.

The correct invariant is not the independence number of a side, but the
independence number of a side **refined by its trace on the glueing clique `K`**:

`indepNumOnTrace G s K T` is the largest independent set `A ⊆ s` of `G` with
`A ∩ K = T`.

## Main results

* `IsCliqueSum.indepNumOn_eq_sup_traces` :
  `α(G) = max_{T ⊆ K, |T| ≤ 1} (α₁(T) + α₂(T) - |T|)`,
  a complete decomposition of the independence number of a clique sum.
* `IsCliqueSum.indepNumOn_add_le_add_two'` : the `-2` bound re-derived from the exact
  formula (an independent set of a side loses at most one vertex when its trace is
  forced, and the shared trace is counted once).
* `IsCliqueSum.cliqueNumOn_eq_max` : `ω(G) = max (ω₁, ω₂)`; every clique of a clique
  sum lives entirely on one side.
* `IsCliqueSum.chromaticNumber_eq_cliqueNum` : clique sums preserve the equality
  `χ = ω`; combined with `IsCliqueSum.chromaticNumber_eq_max` this is the standard
  "perfection is preserved by clique sums" mechanism, in its numerical form.
-/

namespace Catalog.Pythagorean.CliqueSum

open Finset SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Traced independence numbers -/

open Classical in
/-- The largest independent set of `G` inside `s` whose intersection with `K` is exactly `T`. -/
noncomputable def indepNumOnTrace (G : SimpleGraph V) (s K T : Finset V) : ℕ :=
  ((s.powerset).filter (fun A => IsIndepFinset G A ∧ A ∩ K = T)).sup Finset.card

lemma card_le_indepNumOnTrace {G : SimpleGraph V} {s K T A : Finset V} (hAs : A ⊆ s)
    (hA : IsIndepFinset G A) (hT : A ∩ K = T) : A.card ≤ indepNumOnTrace G s K T := by
  classical
  refine Finset.le_sup (f := Finset.card) ?_
  simp only [Finset.mem_filter, Finset.mem_powerset]
  exact ⟨hAs, hA, hT⟩

lemma indepNumOnTrace_le {G : SimpleGraph V} {s K T : Finset V} {n : ℕ}
    (h : ∀ A ⊆ s, IsIndepFinset G A → A ∩ K = T → A.card ≤ n) :
    indepNumOnTrace G s K T ≤ n := by
  classical
  refine Finset.sup_le ?_
  intro A hA
  simp only [Finset.mem_filter, Finset.mem_powerset] at hA
  exact h A hA.1 hA.2.1 hA.2.2

omit [Fintype V] [DecidableEq V] in
/-- A set of size at most one is independent (there are no loops). -/
lemma isIndepFinset_of_card_le_one {G : SimpleGraph V} {T : Finset V} (hT : T.card ≤ 1) :
    IsIndepFinset G T := by
  intro a ha b hb
  have : a = b := Finset.card_le_one.1 hT a ha b hb
  subst this
  exact G.irrefl

/-- If `T ⊆ s` is an admissible trace then the traced independence number is attained. -/
lemma exists_indepNumOnTrace (G : SimpleGraph V) {s K T : Finset V} (hTs : T ⊆ s)
    (hTK : T ⊆ K) (hTcard : T.card ≤ 1) :
    ∃ A ⊆ s, IsIndepFinset G A ∧ A ∩ K = T ∧ A.card = indepNumOnTrace G s K T := by
  classical
  have hTtrace : T ∩ K = T := Finset.inter_eq_left.2 hTK
  have hne : ((s.powerset).filter (fun A => IsIndepFinset G A ∧ A ∩ K = T)).Nonempty := by
    refine ⟨T, ?_⟩
    simp only [Finset.mem_filter, Finset.mem_powerset]
    exact ⟨hTs, isIndepFinset_of_card_le_one hTcard, hTtrace⟩
  obtain ⟨A, hA, hAeq⟩ := Finset.exists_mem_eq_sup _ hne Finset.card
  simp only [Finset.mem_filter, Finset.mem_powerset] at hA
  exact ⟨A, hA.1, hA.2.1, hA.2.2, hAeq.symm⟩

lemma card_le_indepNumOnTrace_self {G : SimpleGraph V} {s K T : Finset V} (hTs : T ⊆ s)
    (hTK : T ⊆ K) (hTcard : T.card ≤ 1) : T.card ≤ indepNumOnTrace G s K T :=
  card_le_indepNumOnTrace hTs (isIndepFinset_of_card_le_one hTcard)
    (Finset.inter_eq_left.2 hTK)

/-- A traced independence number is at most the corresponding untraced one. -/
lemma indepNumOnTrace_le_indepNumOn (G : SimpleGraph V) (s K T : Finset V) :
    indepNumOnTrace G s K T ≤ indepNumOn G s :=
  indepNumOnTrace_le fun _A hAs hA _ => card_le_indepNumOn hAs hA

/-! ## The exact independence number of a clique sum -/

open Classical in
/-- **Exact formula for the independence number of a clique sum.**
`α(G)` is the maximum over the (at most `k + 1`) admissible traces `T ⊆ K` with
`|T| ≤ 1` of `α₁(T) + α₂(T) - |T|`. -/
theorem IsCliqueSum.indepNumOn_eq_sup_traces {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) :
    indepNumOn G Finset.univ =
      (K.powerset.filter (fun T => T.card ≤ 1)).sup
        (fun T => indepNumOnTrace G₁ s K T + indepNumOnTrace G₂ t K T - T.card) := by
  have hKs : K ⊆ s := by rw [← h.inter_eq]; exact Finset.inter_subset_left
  have hKt : K ⊆ t := by rw [← h.inter_eq]; exact Finset.inter_subset_right
  have hle₁ : G₁ ≤ G := by rw [h.sup_eq]; exact le_sup_left
  have hle₂ : G₂ ≤ G := by rw [h.sup_eq]; exact le_sup_right
  refine le_antisymm ?_ ?_
  · -- every independent set of `G` splits along its trace
    obtain ⟨A, -, hA, hAcard⟩ := exists_indepNumOn G Finset.univ
    set T := A ∩ K with hT
    have hTK : T ⊆ K := Finset.inter_subset_right
    have hTcard : T.card ≤ 1 := hA.card_inter_le_one h.toWeak.isClique
    have hmemT : T ∈ K.powerset.filter (fun T => T.card ≤ 1) := by
      simp only [Finset.mem_filter, Finset.mem_powerset]
      exact ⟨hTK, hTcard⟩
    -- the two halves
    have hA₁ : IsIndepFinset G₁ (A ∩ s) :=
      fun a ha b hb hab => hA a (Finset.mem_inter.1 ha).1 b (Finset.mem_inter.1 hb).1 (hle₁ hab)
    have hA₂ : IsIndepFinset G₂ (A ∩ t) :=
      fun a ha b hb hab => hA a (Finset.mem_inter.1 ha).1 b (Finset.mem_inter.1 hb).1 (hle₂ hab)
    have htr₁ : (A ∩ s) ∩ K = T := by
      rw [hT, Finset.inter_assoc, Finset.inter_eq_right.2 hKs]
    have htr₂ : (A ∩ t) ∩ K = T := by
      rw [hT, Finset.inter_assoc, Finset.inter_eq_right.2 hKt]
    have hunion : (A ∩ s) ∪ (A ∩ t) = A := by
      rw [← Finset.inter_union_distrib_left, h.union_eq, Finset.inter_univ]
    have hinter : (A ∩ s) ∩ (A ∩ t) = T := by
      rw [hT]
      rw [← h.inter_eq]
      ext x
      simp only [Finset.mem_inter]
      tauto
    have hcards : A.card + T.card = (A ∩ s).card + (A ∩ t).card := by
      have := Finset.card_union_add_card_inter (A ∩ s) (A ∩ t)
      rw [hunion, hinter] at this
      omega
    have hb₁ : (A ∩ s).card ≤ indepNumOnTrace G₁ s K T :=
      card_le_indepNumOnTrace Finset.inter_subset_right hA₁ htr₁
    have hb₂ : (A ∩ t).card ≤ indepNumOnTrace G₂ t K T :=
      card_le_indepNumOnTrace Finset.inter_subset_right hA₂ htr₂
    have hfT : A.card ≤ indepNumOnTrace G₁ s K T + indepNumOnTrace G₂ t K T - T.card := by
      omega
    calc indepNumOn G Finset.univ = A.card := hAcard.symm
      _ ≤ indepNumOnTrace G₁ s K T + indepNumOnTrace G₂ t K T - T.card := hfT
      _ ≤ _ := Finset.le_sup (f := fun T => indepNumOnTrace G₁ s K T +
        indepNumOnTrace G₂ t K T - T.card) hmemT
  · -- conversely, matching traces glue
    refine Finset.sup_le ?_
    intro T hTmem
    simp only [Finset.mem_filter, Finset.mem_powerset] at hTmem
    obtain ⟨hTK, hTcard⟩ := hTmem
    obtain ⟨A₁, hA₁s, hA₁, htr₁, hc₁⟩ :=
      exists_indepNumOnTrace G₁ (hTK.trans hKs) hTK hTcard
    obtain ⟨A₂, hA₂t, hA₂, htr₂, hc₂⟩ :=
      exists_indepNumOnTrace G₂ (hTK.trans hKt) hTK hTcard
    have hind := h.toWeak.isIndepFinset_union hA₁s hA₂t hA₁ hA₂ (by rw [htr₁, htr₂])
    have hcard := card_le_indepNumOn (Finset.subset_univ _) hind
    have hinter : A₁ ∩ A₂ = T := by
      have hsub : A₁ ∩ A₂ ⊆ K := by
        intro x hx
        rw [Finset.mem_inter] at hx
        rw [← h.inter_eq]
        exact Finset.mem_inter.2 ⟨hA₁s hx.1, hA₂t hx.2⟩
      ext x
      constructor
      · intro hx
        have hxK : x ∈ K := hsub hx
        have : x ∈ A₁ ∩ K := Finset.mem_inter.2 ⟨(Finset.mem_inter.1 hx).1, hxK⟩
        rwa [htr₁] at this
      · intro hx
        have hx₁ : x ∈ A₁ ∩ K := by rw [htr₁]; exact hx
        have hx₂ : x ∈ A₂ ∩ K := by rw [htr₂]; exact hx
        exact Finset.mem_inter.2 ⟨(Finset.mem_inter.1 hx₁).1, (Finset.mem_inter.1 hx₂).1⟩
    have hsum : (A₁ ∪ A₂).card + T.card = A₁.card + A₂.card := by
      have := Finset.card_union_add_card_inter A₁ A₂
      rw [hinter] at this
      omega
    omega

/-- The `-2` bound, re-derived from the exact trace formula: deleting the (at most one)
vertex of `K` from a maximum independent set of a side yields an independent set with
empty trace, and empty traces glue with no loss. -/
theorem IsCliqueSum.indepNumOn_add_le_add_two' {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) :
    indepNumOn G₁ s + indepNumOn G₂ t ≤ indepNumOn G Finset.univ + 2 := by
  classical
  obtain ⟨A₁, hA₁s, hA₁, hc₁⟩ := exists_indepNumOn G₁ s
  obtain ⟨A₂, hA₂t, hA₂, hc₂⟩ := exists_indepNumOn G₂ t
  have htr₁ : (A₁ \ K) ∩ K = ∅ := by
    ext x; simp only [Finset.mem_inter, Finset.mem_sdiff, Finset.notMem_empty, iff_false]; tauto
  have htr₂ : (A₂ \ K) ∩ K = ∅ := by
    ext x; simp only [Finset.mem_inter, Finset.mem_sdiff, Finset.notMem_empty, iff_false]; tauto
  have hb₁ : (A₁ \ K).card ≤ indepNumOnTrace G₁ s K ∅ :=
    card_le_indepNumOnTrace (Finset.sdiff_subset.trans hA₁s) (hA₁.mono Finset.sdiff_subset) htr₁
  have hb₂ : (A₂ \ K).card ≤ indepNumOnTrace G₂ t K ∅ :=
    card_le_indepNumOnTrace (Finset.sdiff_subset.trans hA₂t) (hA₂.mono Finset.sdiff_subset) htr₂
  have hmem : (∅ : Finset V) ∈ K.powerset.filter (fun T => T.card ≤ 1) := by
    simp
  have hsup : indepNumOnTrace G₁ s K ∅ + indepNumOnTrace G₂ t K ∅ - (∅ : Finset V).card ≤
      indepNumOn G Finset.univ := by
    rw [h.indepNumOn_eq_sup_traces]
    exact Finset.le_sup (f := fun T => indepNumOnTrace G₁ s K T +
      indepNumOnTrace G₂ t K T - T.card) hmem
  simp only [Finset.card_empty, Nat.sub_zero] at hsup
  have e₁ : (A₁ \ K).card + (A₁ ∩ K).card = A₁.card := Finset.card_sdiff_add_card_inter _ _
  have e₂ : (A₂ \ K).card + (A₂ ∩ K).card = A₂.card := Finset.card_sdiff_add_card_inter _ _
  have d₁ : (A₁ ∩ K).card ≤ 1 := hA₁.card_inter_le_one h.isClique_left
  have d₂ : (A₂ ∩ K).card ≤ 1 := hA₂.card_inter_le_one h.isClique_right
  omega

/-! ## The clique number of a clique sum -/

/-- Finset version of being a clique. -/
def IsCliqueFinset (G : SimpleGraph V) (C : Finset V) : Prop :=
  ∀ a ∈ C, ∀ b ∈ C, a ≠ b → G.Adj a b

open Classical in
/-- The clique number of `G` restricted to the vertex set `s`. -/
noncomputable def cliqueNumOn (G : SimpleGraph V) (s : Finset V) : ℕ :=
  ((s.powerset).filter (IsCliqueFinset G)).sup Finset.card

omit [Fintype V] [DecidableEq V] in
lemma card_le_cliqueNumOn {G : SimpleGraph V} {s C : Finset V} (hCs : C ⊆ s)
    (hC : IsCliqueFinset G C) : C.card ≤ cliqueNumOn G s := by
  classical
  refine Finset.le_sup (f := Finset.card) ?_
  simp only [Finset.mem_filter, Finset.mem_powerset]
  exact ⟨hCs, hC⟩

omit [Fintype V] [DecidableEq V] in
lemma cliqueNumOn_le {G : SimpleGraph V} {s : Finset V} {n : ℕ}
    (h : ∀ C ⊆ s, IsCliqueFinset G C → C.card ≤ n) : cliqueNumOn G s ≤ n := by
  classical
  refine Finset.sup_le ?_
  intro C hC
  simp only [Finset.mem_filter, Finset.mem_powerset] at hC
  exact h C hC.1 hC.2

/-- **Every clique of a clique sum lies entirely inside one of the two sides.** -/
theorem IsCliqueSum.cliqueFinset_subset {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) {C : Finset V} (hC : IsCliqueFinset G C) :
    C ⊆ s ∨ C ⊆ t := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h₁, h₂⟩ := hcon
  obtain ⟨a, haC, has⟩ := Finset.not_subset.1 h₁
  obtain ⟨b, hbC, hbt⟩ := Finset.not_subset.1 h₂
  have hne : a ≠ b := by rintro rfl; exact has (by
    have : a ∈ s ∪ t := by rw [h.union_eq]; exact Finset.mem_univ a
    rcases Finset.mem_union.1 this with h' | h'
    · exact h'
    · exact absurd h' hbt)
  have hadj := hC a haC b hbC hne
  rw [h.sup_eq] at hadj
  rcases hadj with hadj | hadj
  · exact has (h.mem_left hadj).1
  · exact hbt (h.mem_right hadj).2

/-- **`ω(G) = max (ω₁, ω₂)` for a clique sum.** -/
theorem IsCliqueSum.cliqueNumOn_eq_max {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K) :
    cliqueNumOn G Finset.univ = max (cliqueNumOn G₁ s) (cliqueNumOn G₂ t) := by
  have hle₁ : G₁ ≤ G := by rw [h.sup_eq]; exact le_sup_left
  have hle₂ : G₂ ≤ G := by rw [h.sup_eq]; exact le_sup_right
  refine le_antisymm ?_ (max_le ?_ ?_)
  · refine cliqueNumOn_le ?_
    intro C _ hC
    rcases h.cliqueFinset_subset hC with hCs | hCt
    · -- a clique inside `s` is a clique of `G₁`
      have : IsCliqueFinset G₁ C := by
        intro a ha b hb hab
        have hadj := hC a ha b hb hab
        rw [h.sup_eq] at hadj
        rcases hadj with hadj | hadj
        · exact hadj
        · have haK : a ∈ K := by
            rw [← h.inter_eq]; exact Finset.mem_inter.2 ⟨hCs ha, (h.mem_right hadj).1⟩
          have hbK : b ∈ K := by
            rw [← h.inter_eq]; exact Finset.mem_inter.2 ⟨hCs hb, (h.mem_right hadj).2⟩
          exact h.isClique_left haK hbK hab
      exact le_trans (card_le_cliqueNumOn hCs this) (le_max_left _ _)
    · have : IsCliqueFinset G₂ C := by
        intro a ha b hb hab
        have hadj := hC a ha b hb hab
        rw [h.sup_eq] at hadj
        rcases hadj with hadj | hadj
        · have haK : a ∈ K := by
            rw [← h.inter_eq]; exact Finset.mem_inter.2 ⟨(h.mem_left hadj).1, hCt ha⟩
          have hbK : b ∈ K := by
            rw [← h.inter_eq]; exact Finset.mem_inter.2 ⟨(h.mem_left hadj).2, hCt hb⟩
          exact h.isClique_right haK hbK hab
        · exact hadj
      exact le_trans (card_le_cliqueNumOn hCt this) (le_max_right _ _)
  · refine cliqueNumOn_le ?_
    intro C _ hC
    exact card_le_cliqueNumOn (Finset.subset_univ _)
      (fun a ha b hb hab => hle₁ (hC a ha b hb hab))
  · refine cliqueNumOn_le ?_
    intro C _ hC
    exact card_le_cliqueNumOn (Finset.subset_univ _)
      (fun a ha b hb hab => hle₂ (hC a ha b hb hab))

/-- **Clique sums preserve `χ = ω`.** If each side has chromatic number equal to its
clique number, then so does the clique sum: this is the numerical core of the fact
that clique sums of perfect graphs are perfect. -/
theorem IsCliqueSum.chromaticNumber_eq_cliqueNum {G G₁ G₂ : SimpleGraph V} {s t K : Finset V}
    (h : IsCliqueSum G G₁ G₂ s t K)
    (h₁ : G₁.chromaticNumber = (cliqueNumOn G₁ s : ℕ∞))
    (h₂ : G₂.chromaticNumber = (cliqueNumOn G₂ t : ℕ∞)) :
    G.chromaticNumber = (cliqueNumOn G Finset.univ : ℕ∞) := by
  rw [h.chromaticNumber_eq_max, h₁, h₂, h.cliqueNumOn_eq_max]
  rcases le_total (cliqueNumOn G₁ s) (cliqueNumOn G₂ t) with hle | hle
  · rw [max_eq_right hle, max_eq_right (by exact_mod_cast hle :
      ((cliqueNumOn G₁ s : ℕ) : ℕ∞) ≤ ((cliqueNumOn G₂ t : ℕ) : ℕ∞))]
  · rw [max_eq_left hle, max_eq_left (by exact_mod_cast hle :
      ((cliqueNumOn G₂ t : ℕ) : ℕ∞) ≤ ((cliqueNumOn G₁ s : ℕ) : ℕ∞))]

end Catalog.Pythagorean.CliqueSum