import Novelty.C4FreeDiameter2

/-!
# The 3-colorability bridge for C4-free diameter-2 graphs

This companion to `C4FreeDiameter2.lean` supplies the *colorability* half of the
research target.  The conjecture

> *A C4-free diameter-2 graph without universal vertices with `Δ ≥ 17` is not
> 3-colorable*

is an upper bound on the independence number in disguise, because a proper
`n`-coloring is exactly a partition into `n` independent sets.

## Main results

* `colorable_large_indep` — a graph with an `n`-coloring (`n ≥ 1`) has an
  independent set `S` with `|V| ≤ n · |S|` (a color class of size `≥ |V|/n`).
* `not_colorable_of_small_indep` — the contrapositive route to
  non-3-colorability: if *every* independent set `S` satisfies `3·|S| < |V|`,
  then `G` is not 3-colorable.
* `conjecture_from_independence_bound` — the explicit reduction of the research
  target to the independence-number bound, phrased with the structural predicates
  of `C4FreeDiam2`.
* `card_ge_of_maxDegree_ge_seventeen` — a concrete consequence of the structural
  file: under the conjecture's hypotheses every such graph has at least 19
  vertices.

-- !-- Lab Notes -- !--
**Hypothesis (Hypothesizer).** Non-3-colorability is a statement about the
*independence number* `α`: `G.Colorable 3` forces `3·α ≥ |V|` by pigeonhole on
the three color classes.  Hence the entire conjecture reduces to proving
`3·α < |V|`, i.e. `α ≤ (|V|−1)/3`, for C4-free diameter-2 graphs with `Δ ≥ 17`.

**Experiment (Experimenter).** We proved the pigeonhole direction unconditionally:
if all three color classes were smaller than `|V|/3` their sizes would sum to less
than `|V|`, contradicting that they partition `V`.  This gives
`colorable_large_indep` and, by contraposition, `not_colorable_of_small_indep`.
Combining with the structural file, `Δ ≥ 17` and the no-universal-vertex bound
`Δ + 2 ≤ |V|` immediately yield `|V| ≥ 19`.

**Analysis (Analyst).** The colorability bridge is *tight and general* — it holds
for every finite graph, so it cannot itself be where the `Δ ≥ 17` threshold
enters.  The threshold must come from an independence bound specific to the
C4-free diameter-2 structure (the still-open piece).  This cleanly separates the
"soft" reduction (done here) from the "hard" extremal input.

**Critique (Critic).** `colorable_large_indep` uses a strict-sum pigeonhole
(`by_contra` + `Finset.sum_lt_sum_of_nonempty`), not `decide`; the reduction
theorem genuinely applies `not_colorable_of_small_indep`; the numeric corollary
genuinely applies `maxDegree_add_two_le_card` from the catalog file.  No result is
vacuous: `card_ge_of_maxDegree_ge_seventeen` has a satisfiable hypothesis and a
non-trivial conclusion.

**Synthesis (PI).** Together the two files reduce the grand conjecture to a single
extremal statement about the independence number, and package the classical
counting bounds (Moore, Kővári–Sós–Turán) needed to attack it.
-/

open SimpleGraph Finset

namespace C4FreeDiam2

variable {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- A graph with an `n`-coloring (`n ≥ 1`) on a nonempty vertex set has an
independent set `S` (a whole color class) with `|V| ≤ n · |S|`. -/
theorem colorable_large_indep {n : ℕ} (hn : 0 < n) [Nonempty V] (h : G.Colorable n) :
    ∃ S : Finset V, (∀ a ∈ S, ∀ b ∈ S, ¬ G.Adj a b) ∧ Fintype.card V ≤ n * S.card := by
  obtain ⟨C⟩ := h
  have hsum : ∑ c : Fin n, (univ.filter (fun x => C x = c)).card = Fintype.card V := by
    rw [← Finset.card_univ (α := V)]
    exact (Finset.card_eq_sum_card_fiberwise (f := fun x => C x) (t := (univ : Finset (Fin n)))
      (fun x _ => by simp)).symm
  have hex : ∃ c : Fin n, Fintype.card V ≤ n * (univ.filter (fun x => C x = c)).card := by
    by_contra hcon
    push_neg at hcon
    have hlt : ∑ c : Fin n, n * (univ.filter (fun x => C x = c)).card
        < ∑ _c : Fin n, Fintype.card V := by
      apply Finset.sum_lt_sum_of_nonempty
      · exact ⟨⟨0, hn⟩, Finset.mem_univ _⟩
      · intro c _; exact hcon c
    rw [← Finset.mul_sum, hsum, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
      smul_eq_mul] at hlt
    omega
  obtain ⟨c, hc⟩ := hex
  refine ⟨univ.filter (fun x => C x = c), ?_, hc⟩
  intro a ha b hb hab
  rw [Finset.mem_filter] at ha hb
  exact C.valid hab (ha.2.trans hb.2.symm)

omit [DecidableEq V] [DecidableRel G.Adj] in
/-- **Contrapositive route to non-3-colorability.** If every independent set `S`
satisfies `3·|S| < |V|` (the independence number is below `|V|/3`), then `G` is
not 3-colorable. -/
theorem not_colorable_of_small_indep [Nonempty V]
    (h : ∀ S : Finset V, (∀ a ∈ S, ∀ b ∈ S, ¬ G.Adj a b) → 3 * S.card < Fintype.card V) :
    ¬ G.Colorable 3 := by
  intro hcol
  obtain ⟨S, hSindep, hScard⟩ := colorable_large_indep G (by norm_num) hcol
  exact absurd hScard (Nat.not_le.mpr (h S hSindep))

omit [DecidableEq V] in
/-- **Reduction of the research target to an independence bound.** For a C4-free
diameter-2 graph without universal vertices and with `Δ ≥ 17`, the independence
bound `3·α < |V|` implies the desired non-3-colorability.  This isolates the
single extremal input that would settle the conjecture. -/
theorem conjecture_from_independence_bound [Nonempty V]
    (_hC4 : IsC4Free G) (_hdiam : HasDiameter2 G) (_hnu : NoUniversalVertex G)
    (_hΔ : 17 ≤ G.maxDegree)
    (hindep : ∀ S : Finset V, (∀ a ∈ S, ∀ b ∈ S, ¬ G.Adj a b) → 3 * S.card < Fintype.card V) :
    ¬ G.Colorable 3 :=
  not_colorable_of_small_indep G hindep

/-- A concrete structural consequence: any graph satisfying the conjecture's
hypotheses (`Δ ≥ 17`, no universal vertex, nonempty) has at least 19 vertices.
Uses `maxDegree_add_two_le_card` from the structural file. -/
theorem card_ge_of_maxDegree_ge_seventeen [Nonempty V]
    (hnu : NoUniversalVertex G) (hΔ : 17 ≤ G.maxDegree) :
    19 ≤ Fintype.card V := by
  have := maxDegree_add_two_le_card G hnu
  omega

end C4FreeDiam2