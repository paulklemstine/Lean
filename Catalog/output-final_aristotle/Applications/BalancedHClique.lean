import Mathlib

/-!
# A bridge between balanced clique matrices and clique-Helly graphs

This file develops, and formally proves, one direction of a conjectured
characterisation of *balanced* graphs.  The conjecture (which motivates this
file) states that for every finite simple graph `G` the following are
equivalent:

* **(i)** `G` is **balanced**: its clique–vertex incidence matrix contains no
  square submatrix of odd order having exactly two `1`'s in each row and each
  column;
* **(ii)** `G` is **hereditary clique-Helly**: every induced subgraph has the
  Helly property for its maximal cliques;
* **(iii)** `G` contains no induced copy of the complement of `3 K₂`
  (equivalently, no induced *octahedron* `K_{2,2,2}`).

The mathematical heart of this file is a genuine **cross-domain bridge**: a
single combinatorial configuration — a *bad triple* of maximal cliques — which
*simultaneously*

* obstructs the **graph-theoretic** Helly property (`not_cliqueHelly_of_badTriple`), and
* obstructs the **linear-algebraic / matrix** balancedness property (`not_balanced_of_badTriple`).

The octahedron `Oct = (3K₂)ᶜ` carries such a bad triple, which yields the
implications (i)→(iii) and (ii)→(iii) of the conjecture as concrete theorems:
a hereditary clique-Helly (or balanced) graph cannot contain an induced
octahedron.

## Main definitions

* `IsMaxClique G K` — `K` is a (`⊆`-)maximal clique of `G`.
* `CliqueHelly G` — the maximal cliques of `G` satisfy the Helly property.
* `GraphBalanced G` — the clique matrix of `G` has no odd "two-per-row-and-column"
  submatrix.
* `BadTriple G` — three maximal cliques meeting pairwise but with empty common
  intersection, in the `C₃` incidence pattern.
* `HereditaryCliqueHelly G` — every graph that induced-embeds into `G` is
  clique-Helly.
* `Oct`, `threeK2` — the octahedron `K_{2,2,2}` and the matching `3K₂`.

## Main results

* `not_cliqueHelly_of_badTriple` — a bad triple obstructs clique-Helly-ness.
* `not_balanced_of_badTriple` — a bad triple obstructs balancedness.
* `cliqueHelly_of_iso` — clique-Helly-ness is invariant under graph isomorphism.
* `oct_eq_compl_threeK2` — `Oct = (3K₂)ᶜ`.
* `oct_not_cliqueHelly`, `oct_not_balanced` — the octahedron is neither
  clique-Helly nor balanced.
* `hereditaryCliqueHelly_no_induced_octahedron` — implication (ii)→(iii).
* `hereditaryBalanced_no_induced_octahedron` — implication (i)→(iii) (matrix side).
* `octahedron_is_the_bridge` — the unified bridge statement.
-/

open SimpleGraph

namespace BalancedHClique

universe u

variable {V : Type u}

/-! ## Core definitions (general finite graphs) -/

/-- `K` is a maximal clique of `G`: it is a clique, and adding any outside
vertex destroys the clique property. -/
def IsMaxClique (G : SimpleGraph V) [DecidableEq V] (K : Finset V) : Prop :=
  G.IsClique (K : Set V) ∧
    ∀ v, v ∉ K → ¬ G.IsClique ((insert v K : Finset V) : Set V)

/-- The **clique-Helly** property: every finite family of maximal cliques that
is pairwise intersecting has a common vertex. -/
def CliqueHelly (G : SimpleGraph V) [DecidableEq V] : Prop :=
  ∀ 𝓕 : Finset (Finset V),
    (∀ K ∈ 𝓕, IsMaxClique G K) →
    (∀ K₁ ∈ 𝓕, ∀ K₂ ∈ 𝓕, (K₁ ∩ K₂).Nonempty) →
    ∃ v, ∀ K ∈ 𝓕, v ∈ K

/-- `G` is **balanced** when its clique matrix (rows = maximal cliques,
columns = vertices) contains no square submatrix of *odd* order with exactly
two `1`'s in each row and each column.  We phrase the forbidden configuration
directly: injective choices of `k` maximal cliques and `k` vertices whose
incidence has exactly two incidences in each row and each column, with `k` odd. -/
def GraphBalanced (G : SimpleGraph V) [DecidableEq V] : Prop :=
  ¬ ∃ (k : ℕ), Odd k ∧ ∃ (Ks : Fin k → Finset V) (vs : Fin k → V),
      Function.Injective Ks ∧ Function.Injective vs ∧
      (∀ i, IsMaxClique G (Ks i)) ∧
      (∀ i, (Finset.univ.filter (fun j => vs j ∈ Ks i)).card = 2) ∧
      (∀ j, (Finset.univ.filter (fun i => vs j ∈ Ks i)).card = 2)

/-- A **bad triple**: three distinct maximal cliques `K0, K1, K2` and three
distinct vertices `a, b, c` realising the `C₃` incidence pattern
(`a ∈ K1 ∩ K2 ∖ K0`, `b ∈ K0 ∩ K2 ∖ K1`, `c ∈ K0 ∩ K1 ∖ K2`), whose common
intersection is empty.  This is the shared obstruction to both balancedness and
clique-Helly-ness. -/
structure BadTriple (G : SimpleGraph V) [DecidableEq V] where
  K0 : Finset V
  K1 : Finset V
  K2 : Finset V
  a : V
  b : V
  c : V
  max0 : IsMaxClique G K0
  max1 : IsMaxClique G K1
  max2 : IsMaxClique G K2
  ne01 : K0 ≠ K1
  ne02 : K0 ≠ K2
  ne12 : K1 ≠ K2
  ha : a ∈ K1 ∧ a ∈ K2 ∧ a ∉ K0
  hb : b ∈ K0 ∧ b ∈ K2 ∧ b ∉ K1
  hc : c ∈ K0 ∧ c ∈ K1 ∧ c ∉ K2
  vab : a ≠ b
  vac : a ≠ c
  vbc : b ≠ c
  empty : ∀ x, ¬ (x ∈ K0 ∧ x ∈ K1 ∧ x ∈ K2)

/-! ## The bridge: a bad triple obstructs both properties -/

/-
**Graph-theoretic obstruction.** A bad triple witnesses failure of the
clique-Helly property: the family `{K0, K1, K2}` is pairwise intersecting yet
has no common vertex.
-/
theorem not_cliqueHelly_of_badTriple [DecidableEq V] {G : SimpleGraph V}
    (T : BadTriple G) : ¬ CliqueHelly G := by
  obtain ⟨K0, K1, K2, a, b, c, max0, max1, max2, ne01, ne02, ne12, ha, hb, hc, vab, vac, vbc, empty⟩ := T;
  intro hCH;
  have := hCH { K0, K1, K2 } ?_ ?_ <;> simp_all +decide [ IsMaxClique ];
  · grind +revert;
  · simp_all +decide [ Finset.Nonempty, Finset.inter_comm ];
    exact ⟨ ⟨ ⟨ b, hb.1 ⟩, ⟨ c, hc.1, hc.2.1 ⟩, ⟨ b, hb.1, hb.2.1 ⟩ ⟩, ⟨ ⟨ c, hc.1, hc.2.1 ⟩, ⟨ a, ha.1 ⟩, ⟨ a, ha.1, ha.2.1 ⟩ ⟩, ⟨ b, hb.1, hb.2.1 ⟩, ⟨ a, ha.1, ha.2.1 ⟩, ⟨ a, ha.2.1 ⟩ ⟩

/-
**Matrix-theoretic obstruction.** A bad triple witnesses failure of
balancedness: choosing rows `K0, K1, K2` and columns `a, b, c` gives an odd
(`3 × 3`) submatrix of the clique matrix with exactly two incidences per row
and per column.
-/
theorem not_balanced_of_badTriple [DecidableEq V] {G : SimpleGraph V}
    (T : BadTriple G) : ¬ GraphBalanced G := by
  obtain ⟨ K0, K1, K2, a, b, c, max0, max1, max2, ne01, ne02, ne12, ha, hb, hc, vab, vac, vbc, empty ⟩ := T;
  refine' fun h => h ⟨ 3, by decide, fun i => if i = 0 then K0 else if i = 1 then K1 else K2, fun i => if i = 0 then a else if i = 1 then b else c, _, _, _, _, _ ⟩ <;> simp +decide [ *, Fin.forall_fin_succ, Function.Injective ];
  · grind;
  · grind;
  · simp +decide [ Finset.card, * ];
    erw [ Multiset.coe_card, Multiset.coe_card, Multiset.coe_card ] ; simp +decide [ * ] ;
    simp +decide [ List.finRange, * ];
  · simp +decide [ Finset.card, * ];
    erw [ Multiset.coe_card, Multiset.coe_card, Multiset.coe_card ] ; simp +decide ;
    simp +decide [ List.finRange, ha, hb, hc ]

/-- Clique-Helly-ness is invariant under graph isomorphism.  This is the
transport tool that makes the hereditary property well behaved. -/
theorem cliqueHelly_of_iso {W : Type u} [DecidableEq V] [DecidableEq W]
    {G : SimpleGraph V} {H : SimpleGraph W} (e : G ≃g H)
    (h : CliqueHelly G) : CliqueHelly H := by
  intro 𝓕 h𝓕 h𝓕_inter
  obtain ⟨v, hv⟩ : ∃ v : V, ∀ K ∈ 𝓕, v ∈ (K.image e.symm) := by
    convert h (𝓕.image (Finset.image e.symm)) _ _ using 1;
    · grind;
    · simp +zetaDelta at *;
      intro K hK; specialize h𝓕 K hK; unfold IsMaxClique at *; simp_all +decide [ SimpleGraph.isClique_iff ] ;
      constructor;
      · intro x hx y hy hxy; simp_all +decide ;
        obtain ⟨ u, hu, rfl ⟩ := hx; obtain ⟨ v, hv, rfl ⟩ := hy; have := h𝓕.1 hu hv; simp_all +decide [ SimpleGraph.Iso.map_adj_iff ] ;
      · intro v hv hv'; specialize h𝓕; have := h𝓕.2 ( e v ) ; simp_all +decide [ SimpleGraph.adj_comm ] ;
        contrapose! this;
        exact ⟨ fun h => hv _ h ( by simp +decide ), fun x hx hx' => by simpa [ SimpleGraph.adj_comm ] using e.map_adj_iff.mpr ( this x hx ( Ne.symm <| by aesop ) ) ⟩;
    · simp_all +decide [ Finset.Nonempty ];
  simp_all +decide [ Finset.mem_image ];
  exact ⟨ e v, fun K hK => by obtain ⟨ a, ha₁, ha₂ ⟩ := hv K hK; have := e.apply_symm_apply a; aesop ⟩

/-! ## The octahedron `K_{2,2,2}` and its matching `3K₂` -/

/-- Adjacency of the octahedron on `Fin 6`: distinct vertices in different
"antipodal pairs" `{0,1}, {2,3}, {4,5}` are adjacent. -/
def octAdj (i j : Fin 6) : Prop := i ≠ j ∧ i.val / 2 ≠ j.val / 2

instance : DecidableRel octAdj := fun i j => by unfold octAdj; infer_instance

/-- The octahedron `K_{2,2,2}` as a simple graph on `Fin 6`. -/
def Oct : SimpleGraph (Fin 6) where
  Adj := octAdj
  symm := fun {_ _} h => ⟨h.1.symm, fun h2 => h.2 h2.symm⟩
  loopless := ⟨fun _ h => h.1 rfl⟩

instance : DecidableRel Oct.Adj := fun i j => (inferInstance : Decidable (octAdj i j))

/-- The perfect matching `3K₂` on `Fin 6`: the antipodal pairs are the edges. -/
def threeK2 : SimpleGraph (Fin 6) where
  Adj := fun i j => i ≠ j ∧ i.val / 2 = j.val / 2
  symm := fun {_ _} h => ⟨h.1.symm, h.2.symm⟩
  loopless := ⟨fun _ h => h.1 rfl⟩

/-- The octahedron is exactly the complement of `3K₂`, i.e. `σ̄2K₂`. -/
theorem oct_eq_compl_threeK2 : threeK2ᶜ = Oct := by
  ext i j
  simp only [SimpleGraph.compl_adj, threeK2, Oct, octAdj]
  constructor
  · rintro ⟨hne, hnadj⟩; exact ⟨hne, fun h => hnadj ⟨hne, h⟩⟩
  · rintro ⟨hne, h2⟩; exact ⟨hne, fun h => h2 h.2⟩

/-! ## The octahedron carries a bad triple -/

/-- The triangle `{0,2,4}` is a maximal clique of the octahedron. -/
theorem oct_maxClique_024 : IsMaxClique Oct {0, 2, 4} := by
  constructor
  · rw [SimpleGraph.isClique_iff]; decide
  · intro v hv; rw [SimpleGraph.isClique_iff]; revert hv; revert v; decide

/-- The triangle `{1,2,5}` is a maximal clique of the octahedron. -/
theorem oct_maxClique_125 : IsMaxClique Oct {1, 2, 5} := by
  constructor
  · rw [SimpleGraph.isClique_iff]; decide
  · intro v hv; rw [SimpleGraph.isClique_iff]; revert hv; revert v; decide

/-- The triangle `{1,3,4}` is a maximal clique of the octahedron. -/
theorem oct_maxClique_134 : IsMaxClique Oct {1, 3, 4} := by
  constructor
  · rw [SimpleGraph.isClique_iff]; decide
  · intro v hv; rw [SimpleGraph.isClique_iff]; revert hv; revert v; decide

/-- The octahedron carries a bad triple: the three triangles
`{0,2,4}, {1,2,5}, {1,3,4}` meet pairwise (in `2, 4, 1`) but share no vertex. -/
def octBadTriple : BadTriple Oct where
  K0 := {0, 2, 4}
  K1 := {1, 2, 5}
  K2 := {1, 3, 4}
  a := 1
  b := 4
  c := 2
  max0 := oct_maxClique_024
  max1 := oct_maxClique_125
  max2 := oct_maxClique_134
  ne01 := by decide
  ne02 := by decide
  ne12 := by decide
  ha := by decide
  hb := by decide
  hc := by decide
  vab := by decide
  vac := by decide
  vbc := by decide
  empty := by decide

/-- The octahedron is **not** clique-Helly. -/
theorem oct_not_cliqueHelly : ¬ CliqueHelly Oct :=
  not_cliqueHelly_of_badTriple octBadTriple

/-- The octahedron is **not** balanced. -/
theorem oct_not_balanced : ¬ GraphBalanced Oct :=
  not_balanced_of_badTriple octBadTriple

/-! ## Hereditary clique-Helly graphs and the forbidden octahedron -/

/-- `G` is **hereditary clique-Helly** if every graph that induced-embeds into
`G` (equivalently, every induced subgraph of `G`, up to isomorphism) is
clique-Helly. -/
def HereditaryCliqueHelly [DecidableEq V] (G : SimpleGraph V) : Prop :=
  ∀ {W : Type} [DecidableEq W] (H : SimpleGraph W), (H ↪g G) → CliqueHelly H

/-- **Implication (ii) → (iii).** A hereditary clique-Helly graph contains no
induced octahedron. -/
theorem hereditaryCliqueHelly_no_induced_octahedron [DecidableEq V]
    {G : SimpleGraph V} (h : HereditaryCliqueHelly G) : IsEmpty (Oct ↪g G) := by
  refine ⟨fun f => ?_⟩
  exact oct_not_cliqueHelly (h Oct f)

/-- `G` is **hereditary balanced** if every graph that induced-embeds into `G`
(equivalently, every induced subgraph of `G`, up to isomorphism) is balanced. -/
def HereditaryBalanced [DecidableEq V] (G : SimpleGraph V) : Prop :=
  ∀ {W : Type} [DecidableEq W] (H : SimpleGraph W), (H ↪g G) → GraphBalanced H

/-- **Implication (i) → (iii), matrix side.** A hereditary balanced graph
contains no induced octahedron.  This is the exact matrix-theoretic twin of
`hereditaryCliqueHelly_no_induced_octahedron`, obtained from the *same*
combinatorial obstruction (`octBadTriple`) via `oct_not_balanced`. -/
theorem hereditaryBalanced_no_induced_octahedron [DecidableEq V]
    {G : SimpleGraph V} (h : HereditaryBalanced G) : IsEmpty (Oct ↪g G) := by
  refine ⟨fun f => ?_⟩
  exact oct_not_balanced (h Oct f)

/-- **The unified bridge, witnessed by the octahedron.**  The complement of
`3K₂` is *simultaneously*

* not balanced (a fact about `0/1` matrices — its clique matrix contains an odd
  `3 × 3` two-per-row-and-column submatrix), and
* not clique-Helly (a fact about the Helly property of set systems — three of its
  maximal cliques meet pairwise but share no vertex),

and both failures are witnessed by the *same* combinatorial object, the bad
triple `octBadTriple`.  This is the concrete cross-domain bridge underlying the
conjectured equivalence (i) ⟺ (ii) ⟺ (iii). -/
theorem octahedron_is_the_bridge :
    threeK2ᶜ = Oct ∧ ¬ GraphBalanced Oct ∧ ¬ CliqueHelly Oct :=
  ⟨oct_eq_compl_threeK2, oct_not_balanced, oct_not_cliqueHelly⟩

end BalancedHClique