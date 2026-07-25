import Mathlib

/-!
# The octahedron graph `K_{2,2,2}` is not clique-Helly

This file gives a self-contained, minimal formalization of the fact that the
octahedron graph (the complete tripartite graph `K_{2,2,2}`) is **not**
clique-Helly.

The vertex set is `Fin 6`, split into three parts of size two according to
`i / 2`:

* part `0` = `{0, 1}`,
* part `1` = `{2, 3}`,
* part `2` = `{4, 5}`.

Two vertices are adjacent iff they are distinct and lie in different parts.

A graph is *clique-Helly* if every family of maximal cliques that pairwise
intersect has a common vertex.  We exhibit three maximal cliques
`{0,2,4}`, `{0,3,5}`, `{1,2,5}` that pairwise intersect but have empty total
intersection, witnessing the failure of the Helly property.
-/

open SimpleGraph

/-- The octahedron graph `K_{2,2,2}` on `Fin 6`, with parts `{0,1}`, `{2,3}`,
`{4,5}` determined by `i / 2`.  Two vertices are adjacent iff they are distinct
and lie in different parts. -/
def octahedron : SimpleGraph (Fin 6) where
  Adj i j := i ≠ j ∧ i.val / 2 ≠ j.val / 2
  symm := fun _ _ h => ⟨h.1.symm, fun e => h.2 e.symm⟩
  loopless := ⟨fun _ h => h.1 rfl⟩

/-- `S` is a maximal clique of `G`: it is a clique and no strictly larger set is
a clique. -/
def IsMaxClique {V : Type*} (G : SimpleGraph V) (S : Set V) : Prop :=
  G.IsClique S ∧ ∀ T, S ⊂ T → ¬ G.IsClique T

/-- `G` is clique-Helly: every family of maximal cliques that pairwise intersect
has a nonempty common intersection. -/
def CliqueHelly {V : Type*} (G : SimpleGraph V) : Prop :=
  ∀ Ss : Set (Set V), (∀ s ∈ Ss, IsMaxClique G s) →
    (∀ s₁ ∈ Ss, ∀ s₂ ∈ Ss, (s₁ ∩ s₂).Nonempty) → (⋂ s ∈ Ss, s).Nonempty

/-- `{0, 2, 4}` is a maximal clique: its three vertices lie in the three
different parts (`0/2 = 0`, `2/2 = 1`, `4/2 = 2`), and any strictly larger set
must contain a further vertex sharing a part with one of them, hence a
non-adjacent pair. -/
lemma octahedron_isMaxClique_024 : IsMaxClique octahedron {0, 2, 4} := by
  constructor
  · intro x hx y hy hxy
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx hy
    refine ⟨hxy, ?_⟩
    rcases hx with h|h|h <;> rcases hy with h'|h'|h' <;> subst h <;> subst h' <;> simp_all
  · intro T hT hcl
    obtain ⟨w, hwT, hw⟩ := Set.exists_of_ssubset hT
    have hsub := hT.subset
    have h0 : (0 : Fin 6) ∈ T := hsub (by simp)
    have h2 : (2 : Fin 6) ∈ T := hsub (by simp)
    have h4 : (4 : Fin 6) ∈ T := hsub (by simp)
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hw
    push_neg at hw
    obtain ⟨hw0, hw2, hw4⟩ := hw
    fin_cases w <;> simp_all
    · exact (hcl h0 hwT (by decide)).2 (by decide)
    · exact (hcl h2 hwT (by decide)).2 (by decide)
    · exact (hcl h4 hwT (by decide)).2 (by decide)

/-- `{0, 3, 5}` is a maximal clique (parts `0`, `1`, `2`). -/
lemma octahedron_isMaxClique_035 : IsMaxClique octahedron {0, 3, 5} := by
  constructor
  · intro x hx y hy hxy
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx hy
    refine ⟨hxy, ?_⟩
    rcases hx with h|h|h <;> rcases hy with h'|h'|h' <;> subst h <;> subst h' <;> simp_all
  · intro T hT hcl
    obtain ⟨w, hwT, hw⟩ := Set.exists_of_ssubset hT
    have hsub := hT.subset
    have h0 : (0 : Fin 6) ∈ T := hsub (by simp)
    have h3 : (3 : Fin 6) ∈ T := hsub (by simp)
    have h5 : (5 : Fin 6) ∈ T := hsub (by simp)
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hw
    push_neg at hw
    obtain ⟨hw0, hw3, hw5⟩ := hw
    fin_cases w <;> simp_all
    · exact (hcl h0 hwT (by decide)).2 (by decide)
    · exact (hcl h3 hwT (by decide)).2 (by decide)
    · exact (hcl h5 hwT (by decide)).2 (by decide)

/-- `{1, 2, 5}` is a maximal clique (parts `0`, `1`, `2`). -/
lemma octahedron_isMaxClique_125 : IsMaxClique octahedron {1, 2, 5} := by
  constructor
  · intro x hx y hy hxy
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx hy
    refine ⟨hxy, ?_⟩
    rcases hx with h|h|h <;> rcases hy with h'|h'|h' <;> subst h <;> subst h' <;> simp_all
  · intro T hT hcl
    obtain ⟨w, hwT, hw⟩ := Set.exists_of_ssubset hT
    have hsub := hT.subset
    have h1 : (1 : Fin 6) ∈ T := hsub (by simp)
    have h2 : (2 : Fin 6) ∈ T := hsub (by simp)
    have h5 : (5 : Fin 6) ∈ T := hsub (by simp)
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hw
    push_neg at hw
    obtain ⟨hw1, hw2, hw5⟩ := hw
    fin_cases w <;> simp_all
    · exact (hcl h1 hwT (by decide)).2 (by decide)
    · exact (hcl h2 hwT (by decide)).2 (by decide)
    · exact (hcl h5 hwT (by decide)).2 (by decide)

/-- The three maximal cliques pairwise intersect: `0 ∈ {0,2,4} ∩ {0,3,5}`,
`2 ∈ {0,2,4} ∩ {1,2,5}`, and `5 ∈ {0,3,5} ∩ {1,2,5}`. -/
lemma pairwise_intersect :
    ({0,2,4} : Set (Fin 6)) ∩ {0,3,5} ≠ ∅ ∧
    ({0,2,4} : Set (Fin 6)) ∩ {1,2,5} ≠ ∅ ∧
    ({0,3,5} : Set (Fin 6)) ∩ {1,2,5} ≠ ∅ :=
  ⟨Set.nonempty_iff_ne_empty.mp ⟨0, by simp⟩,
   Set.nonempty_iff_ne_empty.mp ⟨2, by simp⟩,
   Set.nonempty_iff_ne_empty.mp ⟨5, by simp⟩⟩

/-- The three maximal cliques have empty common intersection:
`{0,2,4} ∩ {0,3,5} = {0}` and `0 ∉ {1,2,5}`. -/
lemma total_intersection_empty :
    ({0,2,4} : Set (Fin 6)) ∩ ({0,3,5} ∩ {1,2,5}) = ∅ := by
  ext x
  simp only [Set.mem_inter_iff, Set.mem_insert_iff, Set.mem_singleton_iff,
    Set.mem_empty_iff_false, iff_false]
  rintro ⟨h1, h2, h3⟩
  fin_cases x <;> simp_all

/-- The octahedron graph `K_{2,2,2}` is **not** clique-Helly.

The family `{{0,2,4}, {0,3,5}, {1,2,5}}` consists of maximal cliques that
pairwise intersect (`pairwise_intersect`) yet have empty total intersection
(`total_intersection_empty`), contradicting the Helly property. -/
theorem octahedron_not_cliqueHelly : ¬ CliqueHelly octahedron := by
  intro h
  obtain ⟨p1, p2, p3⟩ := pairwise_intersect
  have n1 : (({0,2,4} : Set (Fin 6)) ∩ {0,3,5}).Nonempty := Set.nonempty_iff_ne_empty.mpr p1
  have n2 : (({0,2,4} : Set (Fin 6)) ∩ {1,2,5}).Nonempty := Set.nonempty_iff_ne_empty.mpr p2
  have n3 : (({0,3,5} : Set (Fin 6)) ∩ {1,2,5}).Nonempty := Set.nonempty_iff_ne_empty.mpr p3
  have hmax : ∀ s ∈ ({{0,2,4}, {0,3,5}, {1,2,5}} : Set (Set (Fin 6))),
      IsMaxClique octahedron s := by
    intro s hs
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hs
    rcases hs with rfl|rfl|rfl
    · exact octahedron_isMaxClique_024
    · exact octahedron_isMaxClique_035
    · exact octahedron_isMaxClique_125
  have hpair : ∀ s₁ ∈ ({{0,2,4}, {0,3,5}, {1,2,5}} : Set (Set (Fin 6))),
      ∀ s₂ ∈ ({{0,2,4}, {0,3,5}, {1,2,5}} : Set (Set (Fin 6))), (s₁ ∩ s₂).Nonempty := by
    intro s1 hs1 s2 hs2
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hs1 hs2
    rcases hs1 with rfl|rfl|rfl <;> rcases hs2 with rfl|rfl|rfl
    · exact ⟨0, by simp⟩
    · exact n1
    · exact n2
    · exact Set.inter_comm _ _ ▸ n1
    · exact ⟨0, by simp⟩
    · exact n3
    · exact Set.inter_comm _ _ ▸ n2
    · exact Set.inter_comm _ _ ▸ n3
    · exact ⟨1, by simp⟩
  obtain ⟨x, hx⟩ := h _ hmax hpair
  rw [Set.mem_iInter₂] at hx
  have hA := hx {0,2,4} (by simp)
  have hB := hx {0,3,5} (by simp)
  have hC := hx {1,2,5} (by simp)
  have hmem : x ∈ ({0,2,4} : Set (Fin 6)) ∩ ({0,3,5} ∩ {1,2,5}) := ⟨hA, hB, hC⟩
  rw [total_intersection_empty] at hmem
  exact hmem