import Mathlib

/-!
# Monochromatic matchings in colored uniform hypergraphs — Basic theory

This file develops the rigorous combinatorial core behind the *Alon–Frankl–Lovász
(AFL) matching bound* for "random-like" (bounded-degree / pseudorandom) hypergraphs.

We model a hypergraph as its edge set `H : Finset (Finset V)`, a *matching* as a
collection of pairwise-disjoint edges, and an `r`-edge-colouring as a function
`c : Finset V → Fin r`.

The two foundational results proved here are:

* `IsMatching.exists_mono_of_card` — **pigeonhole on a matching**: every `r`-colouring
  of a matching `M` contains a monochromatic sub-matching `M'` with `r * #M' ≥ #M`.
* `MaximalMatching.isCover` — **maximal matchings are vertex covers**: the union of
  the edges of a maximal matching meets every edge of the host hypergraph.

These feed (in `Bounds.lean`) into a clean lower bound on the size of a guaranteed
monochromatic matching in terms of the number of edges and the maximum degree.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The classical AFL/Cockayne–Lorimer style monochromatic
matching guarantee for the *complete* hypergraph should already, in weak form, follow
from purely local data (edge count + maximum degree), with no completeness/pseudorandom
structure beyond bounded degree.  We test: "bounded degree alone forces a large
monochromatic matching".

Experiment (Experimenter): Formalize matchings, the maximal-matching-is-a-cover lemma,
and the colour pigeonhole.  Both are fully provable in Lean with no `sorry`.

Analysis (Analyst): The bounded-degree route yields the fraction `1/(r·t·Δ_norm)`,
i.e. asymptotically `n/(r·t)` for a `d`-regular-like host.  This is genuinely weaker
than the AFL target `n/(r+t-1)` — the gap `(r-1)(t-1) ≥ 0` (see `Bounds.lean`).  So
"bounded degree alone" is TRUE but NOT TIGHT; the AFL constant needs the global
LP/strip structure of the host.  Distinguishes "true but not the deep bound".

Critique (Critic): The cover lemma needs edges to be nonempty (else a maximal matching's
union could miss an empty edge); we carry `t`-uniformity / nonemptiness explicitly.

Synthesis (PI): Keep the two structural lemmas general (any vertex type, any matching),
defer the numeric assembly to `Bounds.lean`.
-/

namespace AFLMatching

open Finset

variable {V : Type*} [DecidableEq V]

/-- A finset of edges is a **matching** if its members are pairwise disjoint. -/
def IsMatching (M : Finset (Finset V)) : Prop :=
  ∀ ⦃e⦄, e ∈ M → ∀ ⦃f⦄, f ∈ M → e ≠ f → Disjoint e f

/-
Any subset of a matching is a matching.
-/
omit [DecidableEq V] in
theorem IsMatching.subset {M M' : Finset (Finset V)} (hM : IsMatching M)
    (h : M' ⊆ M) : IsMatching M' := by
  exact fun e he f hf hef => hM ( h he ) ( h hf ) hef

/-
The empty collection is a matching.
-/
omit [DecidableEq V] in
theorem isMatching_empty : IsMatching (∅ : Finset (Finset V)) := by
  tauto

/-
**Pigeonhole on a matching.** Any `r`-colouring `c` of the edges of a matching `M`
admits a colour `i` whose colour class is a (mono-coloured) matching `M'` with
`r * #M' ≥ #M`.  Equivalently `M` contains a monochromatic matching of size at least
`#M / r`.
-/
theorem IsMatching.exists_mono_of_card (M : Finset (Finset V)) (hM : IsMatching M)
    {r : ℕ} (hr : 0 < r) (c : Finset V → Fin r) :
    ∃ i : Fin r,
      IsMatching (M.filter (fun e => c e = i)) ∧
      (∀ e ∈ M.filter (fun e => c e = i), c e = i) ∧
      r * (M.filter (fun e => c e = i)).card ≥ M.card := by
  -- By definition of $IsMatching$, the set $\{e \in M \mid c(e) = i\}$ is a matching for any $i$.
  have h_matching : ∀ i : Fin r, IsMatching ({e ∈ M | c e = i}) := by
    exact fun i => IsMatching.subset hM ( Finset.filter_subset _ _ );
  -- By the pigeonhole principle, there exists a color $i$ such that the number of edges in $M$ colored $i$ is at least $\frac{|M|}{r}$.
  obtain ⟨i, hi⟩ : ∃ i : Fin r, ∑ j : Fin r, (M.filter (fun e => c e = j)).card ≤ r * (M.filter (fun e => c e = i)).card := by
    obtain ⟨ i, hi ⟩ := Finset.exists_max_image Finset.univ ( fun j => Finset.card ( Finset.filter ( fun e => c e = j ) M ) ) ⟨ ⟨ 0, hr ⟩, Finset.mem_univ _ ⟩ ; use i; simp_all +decide ;
    exact le_trans ( Finset.sum_le_sum fun _ _ => hi _ ) ( by simp +decide );
  refine' ⟨ i, h_matching i, fun e he => Finset.mem_filter.mp he |>.2, hi.trans' _ ⟩;
  rw [ ← Finset.card_biUnion ];
  · exact Finset.card_le_card fun x hx => by aesop;
  · exact fun i _ j _ hij => Finset.disjoint_left.mpr fun x => by aesop;

/-- The set of vertices covered by a collection of edges. -/
def support (M : Finset (Finset V)) : Finset V := M.biUnion id

/-- A matching `M ⊆ H` is **maximal** in `H` if every edge of `H` that is disjoint from
all edges of `M` already belongs to `M` (so no further edge can be added). -/
def MaximalMatching (H M : Finset (Finset V)) : Prop :=
  M ⊆ H ∧ IsMatching M ∧ ∀ e ∈ H, (∀ f ∈ M, Disjoint e f) → e ∈ M

/-
**Maximal matchings are vertex covers.** If `M` is a maximal matching of `H` and all
edges of `H` are nonempty, then every edge of `H` shares a vertex with `support M`.
-/
theorem MaximalMatching.isCover {H M : Finset (Finset V)} (hmax : MaximalMatching H M)
    (hne : ∀ e ∈ H, e.Nonempty) :
    ∀ e ∈ H, ∃ v ∈ support M, v ∈ e := by
  intro e he;
  -- By cases on whether e is disjoint from every f ∈ M.
  by_cases h_disjoint : ∀ f ∈ M, Disjoint e f;
  · exact Exists.elim ( hne e he ) fun x hx => ⟨ x, Finset.mem_biUnion.mpr ⟨ e, hmax.2.2 e he h_disjoint, hx ⟩, hx ⟩;
  · simp_all +decide [ Finset.disjoint_left ];
    obtain ⟨ x, hx, y, hy, hyx ⟩ := h_disjoint; exact ⟨ y, Finset.mem_biUnion.2 ⟨ x, hx, hyx ⟩, hy ⟩ ;

/-
A matching of maximum cardinality among sub-matchings of `H` is a maximal matching.
-/
theorem exists_maximalMatching (H : Finset (Finset V)) :
    ∃ M, MaximalMatching H M := by
  obtain ⟨M, hM⟩ : ∃ M : Finset (Finset V), M ⊆ H ∧ IsMatching M ∧ ∀ N : Finset (Finset V), N ⊆ H → IsMatching N → M.card ≥ N.card := by
    -- The set of matchings in H is nonempty since it contains the empty matching.
    have h_nonempty : ∃ M : Finset (Finset V), M ⊆ H ∧ IsMatching M := by
      exact ⟨ ∅, Finset.empty_subset _, isMatching_empty ⟩;
    have h_finite : Set.Finite {M : Finset (Finset V) | M ⊆ H ∧ IsMatching M} := by
      exact Set.finite_iff_bddAbove.mpr ⟨ H, fun M hM => hM.1 ⟩;
    have := h_finite.toFinset.exists_max_image ( fun M => Finset.card M ) ⟨ h_nonempty.choose, h_finite.mem_toFinset.mpr h_nonempty.choose_spec ⟩ ; aesop;
  refine' ⟨ M, hM.1, hM.2.1, _ ⟩;
  intro e he hdisj;
  contrapose! hM;
  refine' fun hM₁ hM₂ => ⟨ Insert.insert e M, _, _, _ ⟩ <;> simp_all +decide [ Finset.subset_iff ];
  intro f hf g hg hfg; by_cases hf' : f = e <;> by_cases hg' : g = e <;> simp_all +decide [ IsMatching ] ;
  exact Disjoint.symm ( hdisj f hf )

end AFLMatching