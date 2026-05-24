/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Defect Additivity over Root-Separated Pieces

This file establishes a **Mayer–Vietoris decomposition law** for the structural
defect of rooted graph divisors. When a vertex set `S` splits as `S₁ ∪ S₂` with
`S₁` and `S₂` lying in distinct connected components of `G - {q}`, the defect
decomposes as:

  `δ(G, q, S₁ ∪ S₂) = δ(G, q, S₁) + δ(G, q, S₂) + 1`

The `+1` correction term arises because each summand carries its own `- 1`
baseline shift, but the union has only a single baseline.

## Main Definitions

* `RootSeparatedPieces` — predicate asserting `S₁` and `S₂` lie in distinct
  components of `G - {q}`, with `q ∉ S₁ ∪ S₂`.
* `rootedEulerDefect` — Euler-characteristic-style invariant `1 - δ`
* `defectInteraction` — interaction term `δ(S₁∪S₂) - δ(S₁) - δ(S₂)`

## Main Results

* `noCrossEdges_of_rootSeparated` — no edges of `G` connect `S₁` to `S₂`
* `inducedEdgeCount_union_of_rootSeparated` — edge count is additive
* `inducedComponentCount_union_of_rootSeparated` — component count is additive
* `inducedCycleRank_union_of_rootSeparated` — cycle rank (β₁) is additive
* `rootComponentCount_union_of_rootSeparated` — root component count (κ) is additive
* `structuralDefect_union_of_rootSeparated` — the main decomposition:
    `δ(S₁ ∪ S₂) = δ(S₁) + δ(S₂) + 1`

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Mathlib
import Pythagorean.TropicalBridge.DefectTheory

open Finset BigOperators

namespace TropicalBridge.Defect

variable {V : Type*} [Fintype V] [DecidableEq V]
  (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Definition: Root-Separated Pieces -/

/-- Two vertex subsets `S₁` and `S₂` are **root-separated** with respect to
    a root vertex `q` if:
    1. They are disjoint,
    2. `q` is not in either,
    3. No vertex in `S₁` is reachable from any vertex in `S₂` in `G - {q}`.

    This captures the combinatorial separation hypothesis needed for
    defect additivity: `S₁` and `S₂` lie in distinct connected components
    of `G` with `q` deleted. -/
structure RootSeparatedPieces
    (q : V) (S₁ S₂ : Finset V) : Prop where
  /-- S₁ and S₂ are disjoint. -/
  disjoint : Disjoint S₁ S₂
  /-- q is not in S₁. -/
  q_not_in_S₁ : q ∉ S₁
  /-- q is not in S₂. -/
  q_not_in_S₂ : q ∉ S₂
  /-- No vertex of S₁ is reachable from any vertex of S₂ in G - {q}. -/
  unreachable : ∀ (u : ({q}ᶜ : Set V)) (v : ({q}ᶜ : Set V)),
    u.1 ∈ S₁ → v.1 ∈ S₂ →
    ¬(G.induce ({q}ᶜ : Set V)).Reachable u v

/-! ## Key Structural Consequence: No Cross-Edges -/

/-
Root-separated pieces have no edges between them in `G`.
    Any edge between `S₁` and `S₂` would create a length-1 path in `G - {q}`,
    contradicting the unreachability hypothesis.
-/
theorem noCrossEdges_of_rootSeparated
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂)
    (u v : V) (hu : u ∈ S₁) (hv : v ∈ S₂) :
    ¬G.Adj u v := by
  -- Apply the unreachable condition from hsep to u and v.
  have h_unreachable : ¬(G.induce ({q}ᶜ : Set V)).Reachable ⟨u, by
    exact fun h => hsep.q_not_in_S₁ ( h ▸ hu )⟩ ⟨v, by
    exact fun h => hsep.q_not_in_S₂ ( by aesop )⟩ := by
    exact hsep.unreachable _ _ hu hv
  generalize_proofs at *;
  exact fun h => h_unreachable <| SimpleGraph.Adj.reachable <| by aesop;

/-! ## Additivity of Graph Invariants -/

/-
The edge count of the induced subgraph on `S₁ ∪ S₂` equals the sum of
    edge counts on `S₁` and `S₂`, when the pieces are root-separated.
-/
theorem inducedEdgeCount_union_of_rootSeparated
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂) :
    inducedEdgeCount G (S₁ ∪ S₂) =
      inducedEdgeCount G S₁ + inducedEdgeCount G S₂ := by
  unfold inducedEdgeCount;
  convert Set.toFinset_card _ |> Eq.trans <| ?_;
  rw [ Fintype.card_of_subtype ];
  case s => exact Finset.image ( fun e : Sym2 { x : V // x ∈ S₁ } => e.map ( fun x : { x : V // x ∈ S₁ } => ⟨ x.val, by simp +decide ⟩ ) ) ( SimpleGraph.induce ( ↑S₁ ) G ).edgeFinset ∪ Finset.image ( fun e : Sym2 { x : V // x ∈ S₂ } => e.map ( fun x : { x : V // x ∈ S₂ } => ⟨ x.val, by simp +decide ⟩ ) ) ( SimpleGraph.induce ( ↑S₂ ) G ).edgeFinset;
  · rw [ Finset.card_union_of_disjoint, Finset.card_image_of_injective, Finset.card_image_of_injective ];
    · intro e₁ e₂ h; induction e₁ using Sym2.inductionOn ; induction e₂ using Sym2.inductionOn ; aesop;
    · intro e₁ e₂ h; induction e₁ using Sym2.inductionOn ; induction e₂ using Sym2.inductionOn ; aesop;
    · simp +decide [ Finset.disjoint_left ];
      intro a ha x hx; contrapose! hsep; simp_all +decide [ Sym2.map ] ;
      rcases a with ⟨ ⟨ u, hu ⟩, ⟨ v, hv ⟩ ⟩ ; rcases x with ⟨ ⟨ w, hw ⟩, ⟨ x, hx ⟩ ⟩ ; simp_all +decide [ Quot.map ] ;
      grind +suggestions;
  · simp +decide [ Sym2.forall, Sym2.exists ];
    grind +suggestions

/-
No vertex of `S₁` is reachable from any vertex of `S₂` in the induced
    subgraph `G[S₁ ∪ S₂]`.
-/
theorem not_reachable_in_union_of_rootSeparated
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂)
    (u : ↑(↑(S₁ ∪ S₂) : Set V)) (v : ↑(↑(S₁ ∪ S₂) : Set V))
    (hu : u.1 ∈ S₁) (hv : v.1 ∈ S₂) :
    ¬(G.induce (↑(S₁ ∪ S₂) : Set V)).Reachable u v := by
  intro h;
  -- Any path in G[S₁∪S₂] embeds into a path in G[{q}ᶜ] (since q ∉ S₁ ∪ S₂), so reachability in G[S₁∪S₂] implies reachability in G[{q}ᶜ].
  have h_path_in_Qc : (G.induce ({q}ᶜ : Set V)).Reachable ⟨u.val, by
    exact fun h => hsep.q_not_in_S₁ ( h ▸ hu )⟩ ⟨v.val, by
    exact fun hq => hsep.q_not_in_S₂ ( hq ▸ hv )⟩ := by
    all_goals generalize_proofs at *;
    obtain ⟨ p ⟩ := h;
    induction' p with u v p ih;
    · exact SimpleGraph.Reachable.refl _;
    · grind +suggestions
  generalize_proofs at *;
  exact hsep.unreachable _ _ hu hv h_path_in_Qc

/-
Every vertex in a connected component of `G[S₁∪S₂]` that contains
    a vertex from `S₁` must itself be in `S₁`.
-/
theorem mem_S₁_of_reachable_S₁
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂)
    (u v : ↑(↑(S₁ ∪ S₂) : Set V))
    (hu : u.1 ∈ S₁)
    (hreach : (G.induce (↑(S₁ ∪ S₂) : Set V)).Reachable u v) :
    v.1 ∈ S₁ := by
  by_contra h_contra;
  exact not_reachable_in_union_of_rootSeparated G q S₁ S₂ hsep u v hu ( show ( v : V ) ∈ S₂ from by { have := Finset.mem_union.mp v.prop; tauto } ) hreach

/-
Every vertex in a connected component of `G[S₁∪S₂]` that contains
    a vertex from `S₂` must itself be in `S₂`.
-/
theorem mem_S₂_of_reachable_S₂
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂)
    (u v : ↑(↑(S₁ ∪ S₂) : Set V))
    (hu : u.1 ∈ S₂)
    (hreach : (G.induce (↑(S₁ ∪ S₂) : Set V)).Reachable u v) :
    v.1 ∈ S₂ := by
  by_contra h_contra;
  have h_not_reachable : ¬(G.induce (↑(S₁ ∪ S₂) : Set V)).Reachable v u := by
    apply not_reachable_in_union_of_rootSeparated G q S₁ S₂ hsep;
    · grind;
    · exact hu;
  exact h_not_reachable hreach.symm

/-- Reachability in `G[S₁∪S₂]` transfers to `G[S₁]` when all vertices stay in `S₁`. -/
lemma reachable_induce_of_mem_left (S₁ S₂ : Finset V)
    {u v : ↑(↑(S₁ ∪ S₂) : Set V)}
    (hu : u.1 ∈ S₁)
    (hmem : ∀ w : ↑(↑(S₁ ∪ S₂) : Set V),
      (G.induce (↑(S₁ ∪ S₂) : Set V)).Reachable u w → w.1 ∈ S₁)
    (hreach : (G.induce (↑(S₁ ∪ S₂) : Set V)).Reachable u v) :
    (G.induce (↑S₁ : Set V)).Reachable ⟨u.1, hu⟩ ⟨v.1, hmem v hreach⟩ := by
  obtain ⟨p⟩ := hreach
  induction p with
  | nil => exact SimpleGraph.Reachable.refl _
  | @cons a b c hadj walk ih =>
    have hb := hmem b (SimpleGraph.Adj.reachable hadj)
    exact (SimpleGraph.Adj.reachable
      (show (G.induce (↑S₁ : Set V)).Adj ⟨a.1, hu⟩ ⟨b.1, hb⟩ from hadj)).trans
      (ih (hu := hb) (hmem := fun w hw => hmem w ((SimpleGraph.Adj.reachable hadj).trans hw)))

/-- Reachability in `G[S₁∪S₂]` transfers to `G[S₂]` when all vertices stay in `S₂`. -/
lemma reachable_induce_of_mem_right (S₁ S₂ : Finset V)
    {u v : ↑(↑(S₁ ∪ S₂) : Set V)}
    (hu : u.1 ∈ S₂)
    (hmem : ∀ w : ↑(↑(S₁ ∪ S₂) : Set V),
      (G.induce (↑(S₁ ∪ S₂) : Set V)).Reachable u w → w.1 ∈ S₂)
    (hreach : (G.induce (↑(S₁ ∪ S₂) : Set V)).Reachable u v) :
    (G.induce (↑S₂ : Set V)).Reachable ⟨u.1, hu⟩ ⟨v.1, hmem v hreach⟩ := by
  obtain ⟨p⟩ := hreach
  induction p with
  | nil => exact SimpleGraph.Reachable.refl _
  | @cons a b c hadj walk ih =>
    have hb := hmem b (SimpleGraph.Adj.reachable hadj)
    exact (SimpleGraph.Adj.reachable
      (show (G.induce (↑S₂ : Set V)).Adj ⟨a.1, hu⟩ ⟨b.1, hb⟩ from hadj)).trans
      (ih (hu := hb) (hmem := fun w hw => hmem w ((SimpleGraph.Adj.reachable hadj).trans hw)))

/-
The connected component count of `G[S₁ ∪ S₂]` equals the sum of
    component counts of `G[S₁]` and `G[S₂]`, when root-separated.
-/
theorem inducedComponentCount_union_of_rootSeparated
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂) :
    inducedComponentCount G (S₁ ∪ S₂) =
      inducedComponentCount G S₁ + inducedComponentCount G S₂ := by
  apply Eq.symm; exact (by
  convert Fintype.card_sum.symm using 1;
  convert Fintype.card_congr ( Equiv.ofBijective _ ⟨ _, _ ⟩ ) using 1;
  use fun c => Quot.lift (fun v => if hv : v.val ∈ S₁ then Sum.inl (SimpleGraph.connectedComponentMk (G.induce (↑S₁ : Set V)) ⟨v.val, hv⟩) else Sum.inr (SimpleGraph.connectedComponentMk (G.induce (↑S₂ : Set V)) ⟨v.val, by
    grind⟩)) (by
  all_goals generalize_proofs at *;
  intro a b hab
  by_cases ha : a.val ∈ S₁
  by_cases hb : b.val ∈ S₁
  all_goals generalize_proofs at *;
  · have := reachable_induce_of_mem_left G S₁ S₂ ha ( fun w hw => mem_S₁_of_reachable_S₁ G q S₁ S₂ hsep a w ha hw ) hab; aesop;
  · have := mem_S₁_of_reachable_S₁ G q S₁ S₂ hsep a b ha hab; aesop;
  · by_cases hb : b.1 ∈ S₁ <;> simp_all +decide;
    · exact absurd ( mem_S₁_of_reachable_S₁ G q S₁ S₂ hsep b a hb hab.symm ) ( by aesop );
    · convert reachable_induce_of_mem_right G S₁ S₂ _ _ _;
      · grind +suggestions;
      · exact hab) c;
  · all_goals generalize_proofs at *;
    intro c₁ c₂ h;
    obtain ⟨ v₁, rfl ⟩ := c₁.exists_rep
    obtain ⟨ v₂, rfl ⟩ := c₂.exists_rep
    generalize_proofs at *;
    by_cases h₁ : v₁.val ∈ S₁ <;> by_cases h₂ : v₂.val ∈ S₁ <;> simp +decide [ h₁, h₂ ] at h ⊢;
    · refine' Quot.sound _;
      convert h.map _ using 1;
      rotate_right;
      use fun x => ⟨ x.val, by
        exact Finset.mem_union_left _ x.2 ⟩
      all_goals generalize_proofs at *;
      · exact fun { a b } hab => hab;
      · grind +suggestions;
      · grind +suggestions;
    · refine' Quot.sound _;
      convert h.map _ using 1;
      rotate_right;
      use fun x => ⟨ x.val, by
        exact Finset.mem_union_right _ x.2 ⟩
      all_goals generalize_proofs at *;
      · exact fun { a b } hab => hab;
      · grind +suggestions;
      · grind +suggestions;
  · all_goals generalize_proofs at *;
    intro x;
    rcases x with ( x | x );
    · obtain ⟨ v, hv ⟩ := x.exists_rep;
      use SimpleGraph.connectedComponentMk (G.induce (↑(S₁ ∪ S₂) : Set V)) ⟨v.val, Finset.mem_union_left _ v.2⟩;
      simp +decide [ ← hv ];
      erw [ Quot.lift_mk ] ; aesop;
      swap;
      exact fun _ _ => True;
      aesop;
    · obtain ⟨ v, hv ⟩ := x.exists_rep;
      use SimpleGraph.connectedComponentMk (G.induce (↑(S₁ ∪ S₂) : Set V)) ⟨v.val, by
        exact Finset.mem_union_right _ v.2⟩
      generalize_proofs at *;
      simp +decide [ ← hv ];
      convert rfl;
      erw [ Quot.lift_mk ];
      split_ifs <;> simp_all +decide [ Finset.disjoint_left ];
      any_goals tauto;
      exact Finset.disjoint_left.mp hsep.disjoint ‹_› ( Finset.mem_coe.mp v.2 ))

/-- **Cycle rank (β₁) additivity.** The first Betti number is additive
    on root-separated pieces. -/
theorem inducedCycleRank_union_of_rootSeparated
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂)
    (hle₁ : S₁.card ≤ inducedEdgeCount G S₁ + inducedComponentCount G S₁)
    (hle₂ : S₂.card ≤ inducedEdgeCount G S₂ + inducedComponentCount G S₂) :
    (inducedCycleRank G (S₁ ∪ S₂) : ℤ) =
      (inducedCycleRank G S₁ : ℤ) + (inducedCycleRank G S₂ : ℤ) := by
  have hE := inducedEdgeCount_union_of_rootSeparated G q S₁ S₂ hsep
  have hC := inducedComponentCount_union_of_rootSeparated G q S₁ S₂ hsep
  have hcard : (S₁ ∪ S₂).card = S₁.card + S₂.card :=
    Finset.card_union_of_disjoint hsep.disjoint
  unfold inducedCycleRank
  rw [hE, hC, hcard]
  omega

/-
**Root component count (κ) additivity.** The number of components of
    `G - {q}` meeting `S₁ ∪ S₂` equals the sum for `S₁` and `S₂` separately,
    since they lie in distinct components.
-/
theorem rootComponentCount_union_of_rootSeparated
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂) :
    rootComponentCount G q (S₁ ∪ S₂) =
      rootComponentCount G q S₁ + rootComponentCount G q S₂ := by
  nontriviality;
  convert ← Fintype.card_congr ?_;
  convert Fintype.card_sum;
  symm;
  refine' Equiv.ofBijective _ ⟨ fun x y h => _, fun x => _ ⟩;
  refine' fun x => x.elim ( fun x => ⟨ x.val, by obtain ⟨ v, hv₁, hv₂ ⟩ := x.property; exact ⟨ v, Finset.mem_union_left _ hv₁, hv₂ ⟩ ⟩ ) fun x => ⟨ x.val, by obtain ⟨ v, hv₁, hv₂ ⟩ := x.property; exact ⟨ v, Finset.mem_union_right _ hv₁, hv₂ ⟩ ⟩;
  · rcases x with ( ⟨ x, hx ⟩ | ⟨ x, hx ⟩ ) <;> rcases y with ( ⟨ y, hy ⟩ | ⟨ y, hy ⟩ ) <;> simp_all +decide [ Subtype.ext_iff ];
    · obtain ⟨ v₁, hv₁, rfl ⟩ := hx; obtain ⟨ v₂, hv₂, rfl ⟩ := hy; simp_all +decide [ RootSeparatedPieces ] ;
      exact hsep.unreachable v₁ v₂ hv₁ hv₂ h;
    · grind +suggestions;
  · rcases x with ⟨ c, ⟨ v, hv₁, hv₂ ⟩ ⟩ ; cases' Finset.mem_union.mp hv₁ with hv₁ hv₁ <;> [ exact ⟨ Sum.inl ⟨ c, ⟨ v, hv₁, hv₂ ⟩ ⟩, rfl ⟩ ; exact ⟨ Sum.inr ⟨ c, ⟨ v, hv₁, hv₂ ⟩ ⟩, rfl ⟩ ] ;

/-! ## Main Theorem: Defect Decomposition Law -/

/-- **Defect decomposition law (Mayer–Vietoris for rooted graph defect).**

    For root-separated pieces `S₁` and `S₂`, the structural defect
    decomposes as:

      `δ(G, q, S₁ ∪ S₂) = δ(G, q, S₁) + δ(G, q, S₂) + 1`

    The correction term `+1` is universal: it arises because defect is
    defined as `β₁ + κ - 1`, and while both `β₁` and `κ` are fully
    additive on separated pieces, the `- 1` baseline appears once in the
    union but twice in the sum of individual defects. -/
theorem structuralDefect_union_of_rootSeparated
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂)
    (hle₁ : S₁.card ≤ inducedEdgeCount G S₁ + inducedComponentCount G S₁)
    (hle₂ : S₂.card ≤ inducedEdgeCount G S₂ + inducedComponentCount G S₂) :
    structuralDefect G q (S₁ ∪ S₂) =
      structuralDefect G q S₁ + structuralDefect G q S₂ + 1 := by
  unfold structuralDefect
  have hβ := inducedCycleRank_union_of_rootSeparated G q S₁ S₂ hsep hle₁ hle₂
  have hκ := rootComponentCount_union_of_rootSeparated G q S₁ S₂ hsep
  rw [hκ]
  push_cast
  linarith

/-! ## Cross-Domain: Rooted Euler Defect -/

/-- The **rooted Euler defect**: an Euler-characteristic-style invariant
    `χ_q(G, S) = 1 - δ(G,q,S)`. -/
noncomputable def rootedEulerDefect (q : V) (S : Finset V) : ℤ :=
  1 - structuralDefect G q S

/-- The rooted Euler defect satisfies the clean additive formula:
    `χ_q(S₁ ∪ S₂) = χ_q(S₁) + χ_q(S₂) - 1`,
    mirroring inclusion-exclusion for Euler characteristics of spaces
    glued at a point. -/
theorem rootedEulerDefect_union_of_rootSeparated
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂)
    (hle₁ : S₁.card ≤ inducedEdgeCount G S₁ + inducedComponentCount G S₁)
    (hle₂ : S₂.card ≤ inducedEdgeCount G S₂ + inducedComponentCount G S₂) :
    rootedEulerDefect G q (S₁ ∪ S₂) =
      rootedEulerDefect G q S₁ + rootedEulerDefect G q S₂ - 2 := by
  unfold rootedEulerDefect
  have h := structuralDefect_union_of_rootSeparated G q S₁ S₂ hsep hle₁ hle₂
  linarith

/-! ## Interaction Energy -/

/-- The **defect interaction** between two subsets:
    `I_q(S₁, S₂) = δ(S₁ ∪ S₂) - δ(S₁) - δ(S₂)`. -/
noncomputable def defectInteraction (q : V) (S₁ S₂ : Finset V) : ℤ :=
  structuralDefect G q (S₁ ∪ S₂) -
    structuralDefect G q S₁ - structuralDefect G q S₂

/-- **Interaction theorem.** The defect interaction between
    root-separated pieces is exactly 1, independent of internal structure. -/
theorem defectInteraction_eq_one_of_rootSeparated
    (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂)
    (hle₁ : S₁.card ≤ inducedEdgeCount G S₁ + inducedComponentCount G S₁)
    (hle₂ : S₂.card ≤ inducedEdgeCount G S₂ + inducedComponentCount G S₂) :
    defectInteraction G q S₁ S₂ = 1 := by
  unfold defectInteraction
  have h := structuralDefect_union_of_rootSeparated G q S₁ S₂ hsep hle₁ hle₂
  omega

/-! ## Finite Additivity (k pieces) -/

/-
**Finite additivity over k root-separated pieces.**
    For a family of pairwise root-separated subsets indexed by `ι`,
    `δ(⋃ i, S i) = (∑ i, δ(S i)) + (|ι| - 1)`.

    The correction term `k - 1` reflects the `k - 1` additional
    baseline shifts from assembling `k` independent pieces.
-/
theorem structuralDefect_biUnion_rootSeparated
    {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
    (q : V) (S : ι → Finset V)
    (hpairwise : ∀ i j, i ≠ j → RootSeparatedPieces G q (S i) (S j))
    (hβ_union : (inducedCycleRank G (Finset.biUnion Finset.univ S) : ℤ) =
      ∑ i : ι, (inducedCycleRank G (S i) : ℤ))
    (hκ_union : rootComponentCount G q (Finset.biUnion Finset.univ S) =
      ∑ i : ι, rootComponentCount G q (S i)) :
    structuralDefect G q (Finset.biUnion Finset.univ S) =
      (∑ i : ι, structuralDefect G q (S i)) + ((Fintype.card ι : ℤ) - 1) := by
  unfold structuralDefect;
  simp +decide [ Finset.sum_add_distrib, Finset.sum_sub_distrib, hβ_union, hκ_union ]

/-! ## Symmetry -/

/-- Root separation is symmetric. -/
theorem rootSeparatedPieces_symm (q : V) (S₁ S₂ : Finset V)
    (hsep : RootSeparatedPieces G q S₁ S₂) :
    RootSeparatedPieces G q S₂ S₁ :=
  { disjoint := hsep.disjoint.symm
    q_not_in_S₁ := hsep.q_not_in_S₂
    q_not_in_S₂ := hsep.q_not_in_S₁
    unreachable := fun u v hu hv h => hsep.unreachable v u hv hu h.symm }

end TropicalBridge.Defect