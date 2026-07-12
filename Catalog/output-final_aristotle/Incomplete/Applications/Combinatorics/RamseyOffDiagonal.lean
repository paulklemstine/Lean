/-
# Off-diagonal structure of the two-colour arrow relation

Building on `Applications.Ramsey` (the arrow relation `Arrows n s t`, the
Erdős–Szekeres step `arrows_step`, the binomial bound `arrows_recursion`) and the
colour-swap symmetry `arrows_symm` from `Applications.RamseyFourFour`, this file
develops the *off-diagonal* structure of Ramsey numbers that the exact small
values do not isolate:

* `arrows_mono_red` / `arrows_mono_blue` — monotonicity of the arrow relation in
  the **clique sizes**: enlarging the demanded clique only makes the statement
  harder, shrinking it only easier.  (The existing `Arrows.mono` is monotonicity
  in the *vertex* threshold; this is the orthogonal monotonicity.)
* `arrows_two`        — `R(2, t) ≤ t`: every colouring of `K_t` has a red edge or
  is entirely blue (a blue `K_t`).
* `not_arrows_two`    — `R(2, t+1) > t`: the all-blue colouring of `K_t` witnesses
  it.
* `ramsey_two`        — the exact value `R(2, t+1) = t+1`.
* `arrows_recursion_general` — the Erdős–Szekeres recursion in the textbook
  inequality form `R(s+1, t+1) ≤ R(s, t+1) + R(s+1, t)` rephrased on `Arrows`.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib
import Applications.RamseyFourFour

open scoped Classical
open SimpleGraph Finset

namespace RamseyTheory

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the `Arrows` framework carries two *independent*
monotonicities — one in the number of vertices (already present as `Arrows.mono`)
and one in the requested clique sizes.  The second has been missing, yet it is
exactly what makes the trivial base values `R(1,t)=1`, `R(2,t)=t` fit into the
recursion and what justifies "it suffices to prove the bound for the largest
clique sizes".

EXPERIMENT (Experimenter): clique-size monotonicity should follow purely from the
fact that a sub-`Finset` of a clique is a clique (`SimpleGraph.IsNClique` is
hereditary in size via `Finset.exists_subset_card_eq`).  `R(2,t)=t` should be a
clean dichotomy: a colouring with a red edge gives a red `K_2`; one with no red
edge is the empty graph, whose complement is complete, giving a blue `K_t`.
-/

/-! ## Monotonicity in the clique sizes -/

/-
A red `s`-clique contains a red `s'`-clique for every `s' ≤ s`: cliques are
hereditary in size.
-/
lemma exists_subclique_red {V : Type} [DecidableEq V] (G : SimpleGraph V)
    {S : Finset V} {s s' : ℕ} (hS : G.IsNClique s S) (hs : s' ≤ s) :
    ∃ S' : Finset V, S' ⊆ S ∧ G.IsNClique s' S' := by
  obtain ⟨ T, hT ⟩ := Finset.exists_subset_card_eq ( show s' ≤ S.card from by linarith [ hS.2 ] );
  exact ⟨ T, hT.1, ⟨ hS.1.subset hT.1, hT.2 ⟩ ⟩

/-
**Clique-size monotonicity (red).** If `n → (s, t)` and `s' ≤ s`, then
`n → (s', t)`: demanding a smaller red clique is easier.
-/
theorem arrows_mono_red {n s s' t : ℕ} (h : Arrows n s t) (hs : s' ≤ s) :
    Arrows n s' t := by
  intro V _ G W hn
  specialize h G W hn;
  obtain ⟨ S, hS₁, hS₂ ⟩ | ⟨ S, hS₁, hS₂ ⟩ := h <;> [ exact Or.inl ⟨ ( exists_subclique_red G hS₂ hs ) |> Classical.choose, ( exists_subclique_red G hS₂ hs ) |> Classical.choose_spec |> And.left |> Finset.Subset.trans <| hS₁, ( exists_subclique_red G hS₂ hs ) |> Classical.choose_spec |> And.right ⟩ ; exact Or.inr ⟨ S, hS₁, hS₂ ⟩ ]

/-
**Clique-size monotonicity (blue).** If `n → (s, t)` and `t' ≤ t`, then
`n → (s, t')`.
-/
theorem arrows_mono_blue {n s t t' : ℕ} (h : Arrows n s t) (ht : t' ≤ t) :
    Arrows n s t' := by
  intro V hV G W hW
  have h_symm : Arrows n t s := arrows_symm h
  obtain ⟨ S, hS₁, hS₂ ⟩ | ⟨ S, hS₁, hS₂ ⟩ := h_symm Gᶜ W hW;
  · exact Or.inr ( by rcases exists_subclique_red Gᶜ hS₂ ht with ⟨ S', hS'₁, hS'₂ ⟩ ; exact ⟨ S', hS'₁.trans hS₁, hS'₂ ⟩ );
  · exact Or.inl ⟨ S, hS₁, by simpa using hS₂ ⟩

/-! ## The value `R(2, t) = t` -/

/-
**Upper bound `R(2, t) ≤ t`.** Every red/blue colouring of `K_t` either has a
red edge (a red `K_2`) or is entirely blue, in which case the whole vertex set is
a blue `K_t`.
-/
theorem arrows_two (t : ℕ) : Arrows t 2 t := by
  intro V _ G W hW;
  by_cases h : ∃ u v : V, u ∈ W ∧ v ∈ W ∧ u ≠ v ∧ G.Adj u v;
  · obtain ⟨ u, v, hu, hv, hne, hadj ⟩ := h;
    refine Or.inl ⟨ { u, v }, ?_, ?_ ⟩ <;> simp_all +decide [ SimpleGraph.isNClique_iff ];
    grind;
  · obtain ⟨ S, hS ⟩ := Finset.exists_subset_card_eq hW;
    refine Or.inr ⟨ S, hS.1, ?_ ⟩;
    simp_all +decide [ SimpleGraph.isNClique_iff ];
    exact fun x hx y hy hxy => by have := h x ( hS.1 hx ) y ( hS.1 hy ) hxy; tauto;

/-
**Lower bound `R(2, t+1) > t`.** The all-blue colouring (empty red graph) on
`K_t` has no red edge and its complement `K_t` has no blue `K_{t+1}` (only `t`
vertices), so `¬ Arrows t 2 (t+1)`.
-/
theorem not_arrows_two (t : ℕ) : ¬ Arrows t 2 (t + 1) := by
  intro h
  specialize h ⊥ (Finset.univ : Finset (Fin t))
  simp_all +decide;
  obtain ⟨ S, hS ⟩ := h; have := Finset.card_le_univ S; simp_all +decide [ SimpleGraph.isNClique_iff ] ;

/-- **The exact value `R(2, t+1) = t+1`.** -/
theorem ramsey_two (t : ℕ) : Arrows (t + 1) 2 (t + 1) ∧ ¬ Arrows t 2 (t + 1) :=
  ⟨arrows_two (t + 1), not_arrows_two t⟩

/-! ## The Erdős–Szekeres recursion in inequality form -/

/-- **Erdős–Szekeres recursion, inequality form.** If `R(s+1, t+2) ≤ m` and
`R(s+2, t+1) ≤ n` (encoded as `Arrows m (s+1) (t+2)` and `Arrows n (s+2) (t+1)`),
then `R(s+2, t+2) ≤ m + n`.  This is `arrows_step` with the clique indices shifted
so that both feeds are non-trivial (`≥ 2`), matching the classical statement
`R(s, t) ≤ R(s-1, t) + R(s, t-1)`. -/
theorem arrows_recursion_general {m n s t : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hfeed1 : Arrows m (s + 1) (t + 2)) (hfeed2 : Arrows n (s + 2) (t + 1)) :
    Arrows (m + n) (s + 2) (t + 2) :=
  arrows_step hm hn hfeed1 hfeed2

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst): clique-size monotonicity is the structurally "obvious" fact
that was nonetheless absent from the catalog; it is the precise statement that the
arrow relation is *antitone* in `(s,t)` (harder to satisfy as the cliques grow)
while `Arrows.mono` records that it is *monotone* in the vertex count.  Together
they make `Arrows` a genuine two-parameter monotone family.

`R(2,t)=t` is the first exact off-diagonal value and the base of the recursion;
the lower bound is a one-line empty-graph witness, conceptually distinct from the
algebraic (Paley) and parity (handshake) witnesses used for the larger values.

CRITIQUE (Critic): none of these are `decide`/`simp`-only.  `arrows_mono_red`
uses the hereditary-clique lemma and `rcases`; `arrows_two` is a genuine dichotomy
proof; `not_arrows_two` exhibits an explicit extremal colouring.  All hypotheses
are satisfiable and the conclusions are non-vacuous for every `t`.

SYNTHESIS (PI): the `Arrows` framework now records both monotonicities and the
full off-diagonal base case `R(2,t)=t`, completing the structural scaffolding
around the exact values `R(3,3)=6`, `R(3,4)=9`, `R(4,4)=18`.
-/

end RamseyTheory