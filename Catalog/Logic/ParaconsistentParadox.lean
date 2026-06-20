import Mathlib

/-!
# Dream Logic II — Topological Models of Paraconsistency

The Tarski–McKinsey duality models *intuitionistic* logic by the **open** sets of
a topological space (a Heyting algebra).  Dually, the **closed** sets carry a
*co-Heyting* (Brouwerian) algebra, which is the natural home of **paraconsistent**
negation: instead of "interior of the complement", one uses

  `pneg A := closure Aᶜ`   (the closure of the complement).

A point may then lie in `A` *and* in `pneg A` simultaneously — a topological
"impossible object".  The set of such points is the **contradiction set**
`contradiction A := A ∩ pneg A`.

## Main results

* `contradiction_eq_frontier` — for a closed set the contradiction set is exactly
  the topological **frontier** (boundary).  Frontier points are the dialetheias.
* `lnc_holds_iff_clopen` — the Law of Non-Contradiction holds for `A`
  (`contradiction A = ∅`) **iff** `A` is *clopen*.  Equivalently, the logic is
  classical exactly on the clopen sets; genuine paraconsistency appears precisely
  where closed sets are not also open — i.e. where the closed sets fail to be
  closed under the operations that would make them open (the "open sets not
  closed under arbitrary union/complement" phenomenon of the brief).
* `dream_object_real` / `contradiction_nonempty_real` — a *concrete* impossible
  object: in `ℝ`, the point `0` lies in `[0,1]` and in the closure of its
  complement; the interval is closed but not clopen, so its contradiction set
  (its frontier `{0,1}`) is nonempty.
* `connected_forces_paraconsistency` — on a (pre)connected space *any* proper
  nonempty closed set has a nonempty contradiction set: connectedness *forces*
  dream logic.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): "Paraconsistent negation = closure-of-complement; the only
  sets obeying classical Non-Contradiction are the clopen ones."  Surprising
  corollary: on a connected space *every* nontrivial belief is dialetheic.
Experiment (Stage 2): Identified `contradiction A` with `frontier A` for closed
  `A` via `closure_compl` + `IsClosed.frontier_eq`, then used
  `isClopen_iff_frontier_eq_empty`.  Concrete witness `[0,1] ⊆ ℝ`.
Analysis (Stage 3): Survived.  Initial wording of the brief ("open sets not
  closed under arbitrary union") is literally false for a topology; the correct
  dual reading is "closed sets need not be open", captured by clopen-ness.  This
  is the "needs a different definition" insight of the cycle.
Critique (Stage 4): Guarded the connectedness theorem with `Aᶜ.Nonempty` and
  `A.Nonempty`; without properness the frontier can be empty (whole space), so
  the hypotheses are load-bearing, not decoration.
Synthesis (Stage 5): `contradiction`/`pneg` are the topological semantics whose
  pointwise truth value (true/false/both) is the four-valued logic of the Logic
  domain — see `Logic/DreamLogic/Bridge.lean`.
-/

open Set Topology

namespace DreamTopo

variable {X : Type*} [TopologicalSpace X]

/-- Paraconsistent ("co-Heyting") negation on subsets: closure of the complement. -/
def pneg (A : Set X) : Set X := closure Aᶜ

/-- The **contradiction set** of `A`: points lying in both `A` and its
paraconsistent negation — the topological dialetheias / impossible objects. -/
def contradiction (A : Set X) : Set X := A ∩ pneg A

/-- For a **closed** set, the contradiction set is exactly the frontier (boundary). -/
theorem contradiction_eq_frontier {A : Set X} (h : IsClosed A) :
    contradiction A = frontier A := by
  unfold contradiction pneg
  rw [closure_compl, h.frontier_eq]
  ext x; simp [Set.diff_eq]

/-- **Non-Contradiction holds iff clopen.**  For a closed set `A`, the Law of
Non-Contradiction holds (`contradiction A = ∅`) precisely when `A` is clopen.
Paraconsistency is exactly the failure of closed sets to be open. -/
theorem lnc_holds_iff_clopen {A : Set X} (h : IsClosed A) :
    contradiction A = ∅ ↔ IsClopen A := by
  rw [contradiction_eq_frontier h, isClopen_iff_frontier_eq_empty]

/-- Contrapositive form: a closed set that is *not* clopen carries a genuine
(nonempty) contradiction — a dream object. -/
theorem not_clopen_contradiction {A : Set X} (h : IsClosed A)
    (hnc : ¬ IsClopen A) : (contradiction A).Nonempty := by
  rw [Set.nonempty_iff_ne_empty]
  intro he
  exact hnc ((lnc_holds_iff_clopen h).1 he)

/-! ### A concrete impossible object in `ℝ` -/

/-- The point `0` lies in `[0,1]` **and** in the closure of its complement:
a concrete dialetheia. -/
theorem dream_object_real :
    (0 : ℝ) ∈ contradiction (Set.Icc (0 : ℝ) 1) := by
  have h : IsClosed (Set.Icc (0 : ℝ) 1) := isClosed_Icc
  rw [contradiction_eq_frontier h, frontier_Icc (by norm_num : (0 : ℝ) ≤ 1)]
  simp

/-- The contradiction set of `[0,1] ⊆ ℝ` is nonempty: dream logic is realized. -/
theorem contradiction_nonempty_real :
    (contradiction (Set.Icc (0 : ℝ) 1)).Nonempty :=
  ⟨0, dream_object_real⟩

/-! ### Connectedness forces paraconsistency -/

/-- **Connectedness forces dream logic.**  On a preconnected space, *every*
proper nonempty closed set has a nonempty contradiction set: one cannot hold a
non-trivial belief without admitting an impossible object. -/
theorem connected_forces_paraconsistency [PreconnectedSpace X]
    {A : Set X} (hcl : IsClosed A) (hne : A.Nonempty) (hproper : Aᶜ.Nonempty) :
    (contradiction A).Nonempty := by
  apply not_clopen_contradiction hcl
  intro hclopen
  rcases (isClopen_iff.1 hclopen) with h | h
  · exact hne.ne_empty h
  · exact hproper.ne_empty (by rw [← compl_univ, h])

end DreamTopo