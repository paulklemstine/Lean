import Mathlib

/-!
# Dream Logic V — Closed-Set Semantics over an Arbitrary Topological Space

The earlier topological development (`ClosedSetTopology.lean`) worked concretely over
`ℝ`.  This file **generalizes** the closed-set semantics of dream logic to an *arbitrary*
topological space `X`, isolating exactly which topological hypotheses each logical
phenomenon requires.

A proposition is a subset `A ⊆ X`; the paraconsistent negation is the closure of the
complement, `pneg A = closure Aᶜ`.

## Main results

* `isClosed_pneg` — `pneg A` is always a (closed) proposition.
* `lem_holds` — **excluded middle survives** in any space: `A ∪ pneg A = univ`.
* `glut_eq_frontier` — for a closed proposition, the coexistence points of `A` and its
  negation are exactly the frontier points.
* `pneg_pneg_subset` — **double-negation elimination** holds for closed propositions:
  `pneg (pneg A) ⊆ A`.
* `contradiction_iff_not_isOpen` — a closed proposition harbours a glut *iff it is not
  open*: paraconsistency is precisely the failure of `A` to be clopen.
* `glut_of_not_isolated` — in a `T1` space, every non-isolated point is an impossible
  object: the singleton `{p}` meets its own negation.
* `not_isClosed_iUnion_singleton_of_tendsto` — the structural root of paraconsistency in
  full generality: in a `T1` space, a sequence converging to a point outside its range
  gives a family of closed singletons whose union is **not** closed.
* `no_glut_iff_isOpen` — a closed proposition is glut-free iff it is open; and
  `no_glut_everywhere_iff` — the logic degenerates to classical logic (no closed
  proposition harbours a glut) exactly when every closed set is open.
-/

namespace DreamLogic.TopoGen

open Set Topology Filter

variable {X : Type*} [TopologicalSpace X]

/-- Paraconsistent (closed-set) negation: the closure of the complement. -/
def pneg (A : Set X) : Set X := closure Aᶜ

/-- The paraconsistent negation is always a genuine closed proposition. -/
theorem isClosed_pneg (A : Set X) : IsClosed (pneg A) := isClosed_closure

/-- **Excluded middle survives** in every space: a proposition together with its
paraconsistent negation covers everything. -/
theorem lem_holds (A : Set X) : A ∪ pneg A = univ := by
  refine eq_univ_of_forall (fun x => ?_)
  by_cases hx : x ∈ A
  · exact Or.inl hx
  · exact Or.inr (subset_closure hx)

/-- **Boundary points are gluts.** For a closed proposition, the coexistence points of `A`
and its paraconsistent negation are exactly the frontier points. -/
theorem glut_eq_frontier (A : Set X) (hA : IsClosed A) : A ∩ pneg A = frontier A := by
  rw [pneg, closure_compl, frontier, hA.closure_eq, diff_eq]

/-- **Double-negation elimination** holds for closed propositions. -/
theorem pneg_pneg_subset (A : Set X) (hA : IsClosed A) : pneg (pneg A) ⊆ A := by
  have h : pneg (pneg A) = closure (interior A) := by
    unfold pneg
    rw [← interior_compl, compl_compl]
  rw [h]
  calc closure (interior A) ⊆ closure A := closure_mono interior_subset
    _ = A := hA.closure_eq

/-- **Paraconsistency criterion.** A closed proposition harbours a coexisting contradiction
(a glut) if and only if it is not open — i.e. exactly when it is closed but not clopen. -/
theorem contradiction_iff_not_isOpen (A : Set X) (hA : IsClosed A) :
    (A ∩ pneg A).Nonempty ↔ ¬ IsOpen A := by
  rw [glut_eq_frontier A hA]
  constructor
  · rintro ⟨x, hx⟩ hopen
    have hclopen : IsClopen A := ⟨hA, hopen⟩
    rw [hclopen.frontier_eq] at hx
    exact hx
  · intro hnotopen
    by_contra hempty
    rw [not_nonempty_iff_eq_empty] at hempty
    exact hnotopen (isClopen_iff_frontier_eq_empty.mpr hempty).isOpen

/-- In a `T1` space, a non-isolated point is an **impossible object**: the closed
proposition `{p}` meets its own paraconsistent negation. -/
theorem glut_of_not_isolated [T1Space X] (p : X) (hp : ¬ IsOpen ({p} : Set X)) :
    ({p} ∩ pneg ({p} : Set X)).Nonempty :=
  (contradiction_iff_not_isOpen _ isClosed_singleton).mpr hp

/-- **The structural root of paraconsistency, in full generality.** In a `T1` space, a
sequence converging to a point outside its range yields a family of closed singletons whose
union is *not* closed. Logically: infinite disjunction of true propositions can fail to be
true, which is what blocks explosion. -/
theorem not_isClosed_iUnion_singleton_of_tendsto [T1Space X]
    (x : ℕ → X) (p : X)
    (hp : ∀ n, x n ≠ p) (htend : Tendsto x atTop (𝓝 p)) :
    (∀ n, IsClosed ({x n} : Set X)) ∧ ¬ IsClosed (⋃ n, ({x n} : Set X)) := by
  refine ⟨fun _ => isClosed_singleton, ?_⟩
  intro hclosed
  -- `p` is a limit of the sequence, hence in the closure of the union.
  have hmem : p ∈ closure (⋃ n, ({x n} : Set X)) := by
    apply mem_closure_of_tendsto htend
    filter_upwards with n
    exact mem_iUnion.mpr ⟨n, rfl⟩
  rw [hclosed.closure_eq] at hmem
  obtain ⟨n, hn⟩ := mem_iUnion.mp hmem
  exact hp n (mem_singleton_iff.mp hn).symm

/-- A closed proposition is **glut-free iff it is open** (i.e. clopen): the dual of the
paraconsistency criterion. -/
theorem no_glut_iff_isOpen (A : Set X) (hA : IsClosed A) :
    A ∩ pneg A = ∅ ↔ IsOpen A := by
  rw [← not_nonempty_iff_eq_empty, contradiction_iff_not_isOpen A hA, not_not]

/-- **Degeneration to classical logic.** The closed-set dream logic harbours no gluts at all
— every closed proposition is consistent — exactly when every closed set is open. (This is
weaker than discreteness: the two-point indiscrete space already has no gluts.) -/
theorem no_glut_everywhere_iff :
    (∀ A : Set X, IsClosed A → A ∩ pneg A = ∅) ↔ (∀ A : Set X, IsClosed A → IsOpen A) := by
  constructor
  · intro h A hA
    exact (no_glut_iff_isOpen A hA).mp (h A hA)
  · intro h A hA
    exact (no_glut_iff_isOpen A hA).mpr (h A hA)

end DreamLogic.TopoGen