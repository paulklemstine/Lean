import Logic.BasicMonotoneCircuit.Basic

/-!
# The CLIQUE function and a monotone size lower bound

We model graphs on the vertex set `Fin m` by their edge-indicator
`g : Sym2 (Fin m) → Bool`, so the inputs of a monotone circuit are exactly the
(undirected) edge variables.  The `k`-CLIQUE function tests whether the graph
contains `k` mutually adjacent vertices.

* `cliqueFn` — the CLIQUE Boolean function;
* `cliqueFn_monotone` — CLIQUE is a *monotone* function (adding edges can only
  create cliques), so it is a legitimate target for monotone circuits;
* `cliqueFn_two_dependsOn` — for `k = 2`, every non-loop edge is *relevant*;
* `clique2_size_ge_choose` — **any monotone circuit computing 2-CLIQUE has size at
  least `m.choose 2`**, the number of potential edges.

The last theorem is the elementary "relevant-variable" lower bound specialised to
CLIQUE: it follows from `MCircuit.card_le_size_of_relevant` of `Basic.lean`.  It
is a genuine (quadratic) monotone lower bound; Razborov's *exponential* bound for
`k`-CLIQUE via the approximation method is the deep open formalization target
documented in `FUTURE_DIRECTIONS.md`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): CLIQUE is monotone, and for `k = 2` it depends on every
edge, so the relevant-variable method already yields a `C(m,2)` size bound.

EXPERIMENT (Experimenter): define `cliqueFn` via `decide` over the existence of a
`k`-subset that is mutually adjacent; prove monotonicity, edge-relevance for
`k = 2`, and the size bound through `card_le_size_of_relevant`.

ANALYSIS (Analyst): monotonicity is a direct transport of the witnessing clique.
For relevance, the empty graph (no edges) has no edge, hence no 2-clique, while
adding a single non-loop edge `{a,b}` creates the 2-clique `{a,b}`.  The exact
count `m.choose 2` comes from `Sym2.card_subtype_not_diag`.

CRITIQUE (Critic): the bound is only quadratic, far from Razborov's exponential
bound; we state this honestly.  The theorem is not vacuous: the hypothesis
`∀ g, C.eval g = cliqueFn m 2 g` is satisfiable (a circuit ORing all edge
variables computes 2-CLIQUE), so the conclusion is a real constraint.

SYNTHESIS (PI): CLIQUE is placed in the monotone-circuit framework with a fully
formal, non-trivial size lower bound, ready to be sharpened by the approximation
method in future cycles.
-/

namespace CircuitComplexity

open Finset

variable {m : ℕ}

/-- The `k`-CLIQUE Boolean function on graphs over `Fin m` (edges indexed by
`Sym2 (Fin m)`): true iff some `k`-element vertex set is mutually adjacent. -/
noncomputable def cliqueFn (m k : ℕ) (g : Sym2 (Fin m) → Bool) : Bool :=
  decide (∃ S : Finset (Fin m), S.card = k ∧
    ∀ u ∈ S, ∀ v ∈ S, u ≠ v → g (Sym2.mk (u, v)) = true)

/-
**CLIQUE is monotone.**  If every edge present in `g` is present in `g'`, then
any clique of `g` is a clique of `g'`.
-/
theorem cliqueFn_monotone (k : ℕ) {g g' : Sym2 (Fin m) → Bool}
    (h : ∀ e, g e = true → g' e = true) :
    cliqueFn m k g = true → cliqueFn m k g' = true := by
  unfold cliqueFn; aesop;

/-
For `k = 2`, every non-loop edge is a relevant variable of CLIQUE: the empty
graph has no 2-clique, but adding the single edge `{a,b}` (with `a ≠ b`) creates
one.
-/
theorem cliqueFn_two_dependsOn (e : Sym2 (Fin m)) (he : ¬ e.IsDiag) :
    MCircuit.DependsOn (cliqueFn m 2) e := by
  classical
  refine ⟨fun _ => false, ?_⟩
  obtain ⟨u, v⟩ := e
  have huv : u ≠ v := by
    intro h
    exact he (by simp [h])
  have hfalse : cliqueFn m 2 (Function.update (fun _ => false) (Sym2.mk (u, v)) false)
      = false := by
    have hconst : Function.update (fun _ : Sym2 (Fin m) => false) (Sym2.mk (u, v)) false
        = fun _ => false := Function.update_eq_self _ _
    rw [hconst]
    simp only [cliqueFn, decide_eq_false_iff_not]
    rintro ⟨S, hcard, hS⟩
    obtain ⟨a, b, hab, rfl⟩ := Finset.card_eq_two.mp hcard
    have := hS a (by simp) b (by simp) hab
    simp at this
  have htrue : cliqueFn m 2 (Function.update (fun _ => false) (Sym2.mk (u, v)) true)
      = true := by
    simp only [cliqueFn, decide_eq_true_eq]
    refine ⟨{u, v}, Finset.card_pair huv, ?_⟩
    intro a ha b hb hab
    simp only [Finset.mem_insert, Finset.mem_singleton] at ha hb
    have hedge : Sym2.mk (a, b) = Sym2.mk (u, v) := by
      rcases ha with rfl | rfl <;> rcases hb with rfl | rfl
      · exact absurd rfl hab
      · rfl
      · exact Sym2.eq_swap
      · exact absurd rfl hab
    rw [hedge]
    simp
  rw [hfalse, htrue]
  simp

/-
The number of non-loop edges on `Fin m` equals `m.choose 2`.
-/
theorem card_offDiag_eq_choose (m : ℕ) :
    (univ.filter (fun e : Sym2 (Fin m) => ¬ e.IsDiag)).card = m.choose 2 := by
  rw [ ← Fintype.card_subtype ];
  convert Sym2.card_subtype_not_diag;
  rw [ Fintype.card_fin ]

/-
**Quadratic monotone lower bound for 2-CLIQUE.**  Every monotone circuit that
computes the 2-CLIQUE function on `Fin m` has size at least `m.choose 2`.
-/
theorem clique2_size_ge_choose (C : MCircuit (Sym2 (Fin m)))
    (hC : ∀ g, C.eval g = cliqueFn m 2 g) :
    m.choose 2 ≤ C.size := by
  rw [← card_offDiag_eq_choose]
  refine MCircuit.card_le_size_of_relevant C (cliqueFn m 2) hC _ ?_
  intro e he
  exact cliqueFn_two_dependsOn e (by simpa using he)

end CircuitComplexity