/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Discrete Poincaré Lemma for Nerve Graphs, with Module Coefficients

This file generalises `SheafCohomologyRobustness.Cohomology` (path nerve and cyclic
nerve, real coefficients) to an **arbitrary nerve graph with coefficients in an
arbitrary abelian group**, and proves the exact obstruction theorem:

> `H¹(nerve, M) ∋ [c] = 0` **iff** every closed walk of the nerve has vanishing
> holonomy `∑ c`.

Concretely, for a symmetric adjacency relation `A` on a connected index type `ι`
of cover regions and an antisymmetric overlap discrepancy `c : ι → ι → M`
(a Čech `1`-cochain of the nerve):

* `cycleConsistent_of_isCoboundary` — a coboundary has zero holonomy on every
  closed walk (necessity);
* `isCoboundary_of_cycleConsistent` — conversely, zero holonomy on every closed
  walk produces an explicit **global potential** `f` with `c i j = f j - f i`
  (sufficiency, by transporting along chosen walks from a base region);
* `discrete_poincare_lemma` — the resulting iff, i.e. the exact computation of
  the vanishing locus of the first cohomology class of `c`.

The quantitative half turns this into certified robustness:

* `abs_wsum_le` — holonomy along a walk of length `k` with per-overlap
  discrepancy `≤ ε` is at most `k * ε`;
* `potential_spread_le` — the glued global certificate is `ε`-Lipschitz for the
  nerve graph distance;
* `glued_certified_radius_lower_bound` — if the nerve has diameter `≤ D` and all
  local certified radii agree up to `ε` on each overlap, then **every** region's
  certified radius is at least `r i₀ - D * ε`: a global certified `L∞` radius
  obtained purely from vanishing cohomology plus local data.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the cycle/path dichotomy of the previous cycle is a
  shadow of a single theorem — for *any* nerve graph, the coboundary obstruction
  is exactly the family of closed-walk holonomies, with coefficients in any
  abelian group (not just `ℝ`).
* Experiment (Experimenter): the walk formalism `wsum / endpt / IsWalk / revW`
  (walk = base point + list of successors) made the append and reversal lemmas
  one-line inductions; the standard `List.Chain` API forced awkward endpoint
  bookkeeping and was abandoned after two attempts.
* Analysis (Analyst): the key structural step is `wsum_revW`, the statement that
  reversing a walk negates its holonomy — this is exactly where antisymmetry of
  the `1`-cochain (the Čech alternating condition) enters; without it the
  theorem is false, and the surviving statement is only the "necessity" half.
* Critique (Critic): `isCoboundary_of_cycleConsistent` is not vacuous — the
  hypothesis `CycleConsistent` is satisfiable and nontrivial (it holds for every
  coboundary by `cycleConsistent_of_isCoboundary`, and fails for the loop nerve
  cochain of `Cohomology.cyclic_not_coboundary`).
* Synthesis (PI): one theorem now subsumes the path (`H¹ = 0`) and loop
  (`H¹ ≠ 0`) computations and upgrades them to quantitative certificates.
-/

import Mathlib

namespace SheafCohomologyRobustness
namespace GraphNerve

variable {ι : Type*} {M : Type*} [AddCommGroup M]

/-! ## §1. Walks in a nerve graph and holonomy of a `1`-cochain -/

/-- Holonomy of the `1`-cochain `c` along the walk that starts at `i` and visits
the vertices of `l` in order: `wsum c i [j, k] = c i j + c j k`. -/
def wsum (c : ι → ι → M) : ι → List ι → M
  | _, [] => 0
  | i, j :: t => c i j + wsum c j t

/-- Endpoint of the walk starting at `i` and visiting `l`. -/
def endpt : ι → List ι → ι
  | i, [] => i
  | _, j :: t => endpt j t

/-- `IsWalk A i l` says that every consecutive pair of `i :: l` is an edge of the
nerve graph `A` (i.e. the corresponding cover regions overlap). -/
def IsWalk (A : ι → ι → Prop) : ι → List ι → Prop
  | _, [] => True
  | i, j :: t => A i j ∧ IsWalk A j t

/-- The reversed walk: the successor list of the walk `i :: l` read backwards,
based at `endpt i l`. -/
def revW : ι → List ι → List ι
  | _, [] => []
  | i, j :: t => revW j t ++ [i]

@[simp] lemma wsum_nil (c : ι → ι → M) (i : ι) : wsum c i [] = 0 := rfl

@[simp] lemma wsum_cons (c : ι → ι → M) (i j : ι) (t : List ι) :
    wsum c i (j :: t) = c i j + wsum c j t := rfl

lemma endpt_append (i : ι) (l₁ l₂ : List ι) :
    endpt i (l₁ ++ l₂) = endpt (endpt i l₁) l₂ := by
  induction l₁ generalizing i with
  | nil => rfl
  | cons a t ih => simp [endpt, ih]

lemma wsum_append (c : ι → ι → M) (i : ι) (l₁ l₂ : List ι) :
    wsum c i (l₁ ++ l₂) = wsum c i l₁ + wsum c (endpt i l₁) l₂ := by
  induction l₁ generalizing i with
  | nil => simp [endpt]
  | cons a t ih => simp [endpt, ih, add_assoc]

lemma isWalk_append {A : ι → ι → Prop} (i : ι) (l₁ l₂ : List ι)
    (h₁ : IsWalk A i l₁) (h₂ : IsWalk A (endpt i l₁) l₂) : IsWalk A i (l₁ ++ l₂) := by
  induction l₁ generalizing i with
  | nil => simpa [endpt] using h₂
  | cons a t ih => exact ⟨h₁.1, ih a h₁.2 h₂⟩

/-- Reversing a walk returns to its starting vertex. -/
lemma endpt_revW (i : ι) (l : List ι) : endpt (endpt i l) (revW i l) = i := by
  induction l generalizing i with
  | nil => rfl
  | cons a t _ => simp [endpt, revW, endpt_append]

/-- **Reversal negates holonomy.**  This is where the alternating (antisymmetry)
condition on the Čech `1`-cochain is used. -/
lemma wsum_revW (c : ι → ι → M) (hanti : ∀ x y, c y x = - c x y) (i : ι) (l : List ι) :
    wsum c (endpt i l) (revW i l) = - wsum c i l := by
  induction l generalizing i with
  | nil => simp [endpt, revW]
  | cons a t ih =>
      simp only [endpt, revW]
      rw [wsum_append, ih, endpt_revW]
      simp [hanti a i]

lemma isWalk_revW {A : ι → ι → Prop} (hsym : ∀ x y, A x y → A y x) (i : ι) (l : List ι)
    (h : IsWalk A i l) : IsWalk A (endpt i l) (revW i l) := by
  induction l generalizing i with
  | nil => trivial
  | cons a t ih =>
      simp only [endpt, revW]
      refine isWalk_append _ _ _ (ih a h.2) ?_
      rw [endpt_revW]
      exact ⟨hsym _ _ h.1, trivial⟩

/-! ## §2. Cocycle conditions and the discrete Poincaré lemma -/

/-- **Vanishing holonomy.**  Every closed walk of the nerve has zero total
discrepancy.  This is the "no adversarial loop" condition. -/
def CycleConsistent (A : ι → ι → Prop) (c : ι → ι → M) : Prop :=
  ∀ i l, IsWalk A i l → endpt i l = i → wsum c i l = 0

/-- `c` is a Čech coboundary on the nerve: the overlap discrepancies come from a
single global section `f` (a global certificate). -/
def IsCoboundaryOn (A : ι → ι → Prop) (c : ι → ι → M) : Prop :=
  ∃ f : ι → M, ∀ i j, A i j → c i j = f j - f i

/-- The nerve graph is connected: every region is reachable from every other
through a chain of overlaps. -/
def IsConnectedNerve (A : ι → ι → Prop) : Prop := ∀ i j, ∃ l, IsWalk A i l ∧ endpt i l = j

/-- Holonomy of a coboundary along any walk telescopes to the potential
difference between endpoints (discrete fundamental theorem of calculus). -/
lemma wsum_of_potential {A : ι → ι → Prop} {c : ι → ι → M} {f : ι → M}
    (h : ∀ i j, A i j → c i j = f j - f i) :
    ∀ (i : ι) (l : List ι), IsWalk A i l → wsum c i l = f (endpt i l) - f i := by
  intro i l
  induction l generalizing i with
  | nil => simp [endpt]
  | cons a t ih =>
      intro hw
      simp only [wsum_cons, endpt]
      rw [ih a hw.2, h i a hw.1]
      abel

/-- **Necessity.**  A cochain that glues (is a coboundary) has vanishing holonomy
around every loop of the nerve. -/
theorem cycleConsistent_of_isCoboundary {A : ι → ι → Prop} {c : ι → ι → M}
    (hc : IsCoboundaryOn A c) : CycleConsistent A c := by
  obtain ⟨f, hf⟩ := hc
  intro i l hw hcl
  rw [wsum_of_potential hf i l hw, hcl, sub_self]

/-- **Sufficiency: the discrete Poincaré lemma.**  On a connected nerve graph, an
antisymmetric overlap discrepancy whose holonomy vanishes around every closed
walk is a coboundary: the local certificates glue to a global potential.  The
potential is built explicitly by transporting `c` along chosen walks from a base
region. -/
theorem isCoboundary_of_cycleConsistent [Nonempty ι] {A : ι → ι → Prop} {c : ι → ι → M}
    (hsym : ∀ x y, A x y → A y x) (hanti : ∀ x y, c y x = - c x y)
    (hconn : IsConnectedNerve A) (hcyc : CycleConsistent A c) : IsCoboundaryOn A c := by
  classical
  obtain ⟨b⟩ := ‹Nonempty ι›
  refine ⟨fun i => wsum c b (Classical.choose (hconn b i)), ?_⟩
  intro i j hA
  set p := Classical.choose (hconn b i) with hpdef
  have hp := Classical.choose_spec (hconn b i)
  set q := Classical.choose (hconn b j) with hqdef
  have hq := Classical.choose_spec (hconn b j)
  have hrev : IsWalk A j (revW b q) := by
    have := isWalk_revW hsym b q hq.1
    rwa [hq.2] at this
  have hwalk : IsWalk A b (p ++ (j :: revW b q)) := by
    refine isWalk_append _ _ _ hp.1 ?_
    rw [hp.2]
    exact ⟨hA, hrev⟩
  have hclosed : endpt b (p ++ (j :: revW b q)) = b := by
    rw [endpt_append, hp.2]
    show endpt j (revW b q) = b
    have := endpt_revW b q
    rwa [hq.2] at this
  have hzero := hcyc b _ hwalk hclosed
  rw [wsum_append, hp.2] at hzero
  have hrs : wsum c j (revW b q) = - wsum c b q := by
    have := wsum_revW c hanti b q
    rwa [hq.2] at this
  simp only [wsum_cons] at hzero
  rw [hrs] at hzero
  apply eq_of_sub_eq_zero
  have e : c i j - (wsum c b q - wsum c b p) = wsum c b p + (c i j + -wsum c b q) := by abel
  rw [e, hzero]

/-- **The obstruction theorem.**  On a connected nerve graph with an
antisymmetric overlap discrepancy, gluing of local sections is *exactly*
equivalent to the vanishing of all closed-walk holonomies.  Coefficients lie in
an arbitrary abelian group. -/
theorem discrete_poincare_lemma [Nonempty ι] {A : ι → ι → Prop} {c : ι → ι → M}
    (hsym : ∀ x y, A x y → A y x) (hanti : ∀ x y, c y x = - c x y)
    (hconn : IsConnectedNerve A) :
    IsCoboundaryOn A c ↔ CycleConsistent A c :=
  ⟨cycleConsistent_of_isCoboundary,
    isCoboundary_of_cycleConsistent hsym hanti hconn⟩

/-- **Contrapositive: a nonzero loop holonomy is a certified obstruction.**
A single closed walk with nonzero total discrepancy proves that no global
certificate exists — a cohomological witness of adversarial vulnerability. -/
theorem not_isCoboundary_of_holonomy_ne_zero {A : ι → ι → Prop} {c : ι → ι → M}
    {i : ι} {l : List ι} (hw : IsWalk A i l) (hcl : endpt i l = i)
    (hne : wsum c i l ≠ 0) : ¬ IsCoboundaryOn A c := fun hc =>
  hne (cycleConsistent_of_isCoboundary hc i l hw hcl)

/-! ## §3. Quantitative gluing: certified `L∞` radii from vanishing cohomology -/

/-- Holonomy along a walk of length `k` whose overlap discrepancies are bounded
by `ε` is at most `k * ε` in absolute value. -/
lemma abs_wsum_le {A : ι → ι → Prop} {c : ι → ι → ℝ} {ε : ℝ}
    (hb : ∀ x y, A x y → |c x y| ≤ ε) :
    ∀ (i : ι) (l : List ι), IsWalk A i l → |wsum c i l| ≤ l.length * ε := by
  intro i l
  induction l generalizing i with
  | nil => simp
  | cons a t ih =>
      intro hw
      have h1 : |c i a| ≤ ε := hb _ _ hw.1
      have h2 : |wsum c a t| ≤ t.length * ε := ih a hw.2
      simp only [wsum_cons, List.length_cons, Nat.cast_add, Nat.cast_one]
      calc |c i a + wsum c a t| ≤ |c i a| + |wsum c a t| := abs_add_le _ _
        _ ≤ ε + t.length * ε := by linarith
        _ = (t.length + 1) * ε := by ring

/-- **The glued global certificate is Lipschitz for the nerve distance.**  If the
overlap discrepancies of a coboundary are bounded by `ε` and `j` is reachable
from `i` by a walk of length `k`, then the potentials differ by at most
`k * ε`. -/
theorem potential_spread_le {A : ι → ι → Prop} {c : ι → ι → ℝ} {f : ι → ℝ} {ε : ℝ}
    (hf : ∀ i j, A i j → c i j = f j - f i) (hb : ∀ x y, A x y → |c x y| ≤ ε)
    {i j : ι} {l : List ι} (hw : IsWalk A i l) (hj : endpt i l = j) :
    |f j - f i| ≤ l.length * ε := by
  have h := wsum_of_potential hf i l hw
  rw [hj] at h
  rw [← h]
  exact abs_wsum_le hb i l hw

/-- **Certified radius transfer.**  Suppose the local certified radii `r : ι → ℝ`
form a global section of the nerve (their differences are the overlap
discrepancies `c`), every overlap discrepancy is at most `ε`, and every region is
reachable from `i₀` in at most `D` steps.  Then every region carries certified
radius at least `r i₀ - D * ε`; in particular the *uniform* certified `L∞`
radius of the whole cover is bounded below by an explicit constant. -/
theorem glued_certified_radius_lower_bound {A : ι → ι → Prop} {c : ι → ι → ℝ}
    {r : ι → ℝ} {ε : ℝ} {D : ℕ} {i₀ : ι}
    (hf : ∀ i j, A i j → c i j = r j - r i) (hb : ∀ x y, A x y → |c x y| ≤ ε)
    (hε : 0 ≤ ε)
    (hreach : ∀ j, ∃ l, IsWalk A i₀ l ∧ endpt i₀ l = j ∧ l.length ≤ D) :
    ∀ j, r i₀ - D * ε ≤ r j := by
  intro j
  obtain ⟨l, hw, hj, hlen⟩ := hreach j
  have h := potential_spread_le hf hb hw hj
  have h1 : r i₀ - r j ≤ l.length * ε := by
    have := abs_le.mp h
    linarith [this.1]
  have h2 : (l.length : ℝ) * ε ≤ D * ε := by
    have : (l.length : ℝ) ≤ D := by exact_mod_cast hlen
    nlinarith
  linarith

/-! ## §4. Tree nerves have vanishing `H¹`, for arbitrary coefficients -/

/-- A rooted-tree structure on the index type of a cover: every region has a
parent region it overlaps, and the parent is strictly closer to the root. -/
structure RootedTree (ι : Type*) where
  /-- The base region. -/
  root : ι
  /-- The parent region of each region. -/
  parent : ι → ι
  /-- Distance to the root. -/
  rank : ι → ℕ
  /-- Non-root regions are strictly further from the root than their parent. -/
  rank_parent : ∀ i, i ≠ root → rank (parent i) < rank i

/-- The nerve graph of a rooted tree of regions: `i` and `j` overlap when one is
the parent of the other. -/
def TreeAdj {ι : Type*} (T : RootedTree ι) (i j : ι) : Prop :=
  (T.parent i = j ∧ i ≠ T.root) ∨ (T.parent j = i ∧ j ≠ T.root)

/-- The potential obtained by integrating the overlap discrepancies from the root
down to each region along the unique tree path. -/
noncomputable def treePotential [DecidableEq ι] (T : RootedTree ι) (c : ι → ι → M)
    (i : ι) : M :=
  if _hne : i = T.root then 0 else treePotential T c (T.parent i) + c (T.parent i) i
termination_by T.rank i
decreasing_by exact T.rank_parent i ‹i ≠ T.root›

lemma treePotential_step [DecidableEq ι] (T : RootedTree ι) (c : ι → ι → M) {i : ι}
    (h : i ≠ T.root) :
    treePotential T c i = treePotential T c (T.parent i) + c (T.parent i) i := by
  rw [treePotential]
  simp [h]

/-- **`H¹ = 0` on every tree nerve, with arbitrary coefficients.**  On a
tree-shaped cover *every* antisymmetric overlap discrepancy is a coboundary — no
cycle-consistency hypothesis is needed, because there are no cycles.  This
generalises the path computation of `SheafCohomologyRobustness.Cohomology` to
arbitrary trees and arbitrary abelian coefficient groups. -/
theorem tree_H1_vanishes [DecidableEq ι] (T : RootedTree ι) (c : ι → ι → M)
    (hanti : ∀ x y, c y x = - c x y) :
    IsCoboundaryOn (TreeAdj T) c := by
  refine ⟨treePotential T c, ?_⟩
  rintro i j (⟨hp, hne⟩ | ⟨hp, hne⟩)
  · have hstep := treePotential_step T c hne
    rw [hp] at hstep
    rw [hstep, hanti j i]
    abel
  · have hstep := treePotential_step T c hne
    rw [hp] at hstep
    rw [hstep]
    abel

/-- **No adversarial holonomy on a tree cover.**  Every closed walk in a tree
nerve has vanishing holonomy, for every antisymmetric discrepancy: tree-shaped
covers cannot host a cohomological obstruction. -/
theorem tree_cycleConsistent [DecidableEq ι] (T : RootedTree ι) (c : ι → ι → M)
    (hanti : ∀ x y, c y x = - c x y) :
    CycleConsistent (TreeAdj T) c :=
  cycleConsistent_of_isCoboundary (tree_H1_vanishes T c hanti)

end GraphNerve
end SheafCohomologyRobustness