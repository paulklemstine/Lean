/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Nonabelian `H¹` of a Nerve: Multi-Class Decision Monodromy

For a binary classifier the decision sheaf takes values in `±1` and its
obstruction is the abelian class of `LoopCoefficients.parity_obstruction`.  For a
`k`-class classifier the local sections are *relabelings*, so the transition data
lives in a group that is **not** abelian, and the obstruction is a monodromy
representation rather than a sum.

This file proves the nonabelian discrete Poincaré lemma:

> On a connected nerve graph, a group-valued transition cochain `c` with
> `c j i = (c i j)⁻¹` is a coboundary (`c i j = (f i)⁻¹ * f j`) **iff** the
> product of transitions around every closed walk is the identity.

Main results.

* `wprod_revW` — reversing a walk inverts its holonomy (nonabelian analogue of
  `GraphNerve.wsum_revW`).
* `nonabelian_isCoboundary_of_trivial_monodromy`,
  `nonabelian_discrete_poincare` — the equivalence.
* `not_isCoboundary_of_monodromy_ne_one` — a single loop with nontrivial
  monodromy is a certificate that no global relabeling exists.
* `perm_monodromy_obstructs_global_labelling` — the multi-class specialisation:
  if transporting the predicted labels of a `k`-class classifier around a loop of
  overlapping regions permutes them nontrivially, no globally consistent labelling
  of the cover exists.  For `k = 2` this recovers the parity obstruction.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer, bold): binary robustness hides the nonabelian nature
  of the decision obstruction; for `k ≥ 3` classes, holonomies compose rather
  than add, and the vanishing condition is triviality of a homomorphism from the
  loop group of the nerve.
* Experiment (Experimenter): the abelian proof transports once sums become
  ordered products and the potential convention is fixed as `c i j = (f i)⁻¹ f j`
  (the opposite convention `f j (f i)⁻¹` also works but flips every telescoping
  step, and mixing the two was the source of the first failed attempt).
* Analysis (Analyst): the only structural input is that reversal inverts, which
  is the group-theoretic form of the alternating condition; commutativity is
  never used, so the abelian theorem was strictly weaker than necessary — "needed
  a different definition", not "false".
* Critique (Critic): the multi-class corollary is nonvacuous, since a
  transposition has order `2 ≠ 1`, and the statement is a strict non-existence
  claim about global labellings, witnessed by an explicit loop.
* Synthesis (PI): abelian coefficients measure *how much* certificates disagree;
  nonabelian coefficients measure *how* the class labels get permuted.
-/

import Mathlib
import MachineLearning.SheafCohomologyRobustness.GraphNervePoincare

namespace SheafCohomologyRobustness
namespace Nonabelian

open GraphNerve

variable {ι : Type*} {G : Type*} [Group G]

/-- Monodromy of a group-valued transition cochain along a walk: the ordered
product of the transitions crossed. -/
def wprod (c : ι → ι → G) : ι → List ι → G
  | _, [] => 1
  | i, j :: t => c i j * wprod c j t

@[simp] lemma wprod_nil (c : ι → ι → G) (i : ι) : wprod c i [] = 1 := rfl

@[simp] lemma wprod_cons (c : ι → ι → G) (i j : ι) (t : List ι) :
    wprod c i (j :: t) = c i j * wprod c j t := rfl

lemma wprod_append (c : ι → ι → G) (i : ι) (l₁ l₂ : List ι) :
    wprod c i (l₁ ++ l₂) = wprod c i l₁ * wprod c (endpt i l₁) l₂ := by
  induction l₁ generalizing i with
  | nil => simp [endpt]
  | cons a t ih => simp [endpt, ih, mul_assoc]

/-- **Reversal inverts monodromy.** -/
lemma wprod_revW (c : ι → ι → G) (hinv : ∀ x y, c y x = (c x y)⁻¹) (i : ι) (l : List ι) :
    wprod c (endpt i l) (revW i l) = (wprod c i l)⁻¹ := by
  induction l generalizing i with
  | nil => simp [endpt, revW]
  | cons a t ih =>
      simp only [endpt, revW]
      rw [wprod_append, ih, endpt_revW]
      simp [hinv a i]

/-- Trivial monodromy: the transition product around every closed walk is the
identity. -/
def TrivialMonodromy (A : ι → ι → Prop) (c : ι → ι → G) : Prop :=
  ∀ i l, IsWalk A i l → endpt i l = i → wprod c i l = 1

/-- `c` is a nonabelian coboundary: the transitions come from a single global
relabeling `f`. -/
def IsMulCoboundaryOn (A : ι → ι → Prop) (c : ι → ι → G) : Prop :=
  ∃ f : ι → G, ∀ i j, A i j → c i j = (f i)⁻¹ * f j

/-- Monodromy of a coboundary telescopes to the ratio of the potentials at the
endpoints. -/
lemma wprod_of_potential {A : ι → ι → Prop} {c : ι → ι → G} {f : ι → G}
    (h : ∀ i j, A i j → c i j = (f i)⁻¹ * f j) :
    ∀ (i : ι) (l : List ι), IsWalk A i l → wprod c i l = (f i)⁻¹ * f (endpt i l) := by
  intro i l
  induction l generalizing i with
  | nil => simp [endpt]
  | cons a t ih =>
      intro hw
      simp only [wprod_cons, endpt]
      rw [ih a hw.2, h i a hw.1]
      group

/-- **Necessity.**  A nonabelian coboundary has trivial monodromy. -/
theorem trivialMonodromy_of_isMulCoboundary {A : ι → ι → Prop} {c : ι → ι → G}
    (hc : IsMulCoboundaryOn A c) : TrivialMonodromy A c := by
  obtain ⟨f, hf⟩ := hc
  intro i l hw hcl
  rw [wprod_of_potential hf i l hw, hcl, inv_mul_cancel]

/-- **Sufficiency: the nonabelian discrete Poincaré lemma.**  On a connected
nerve, a transition cochain whose monodromy is trivial around every closed walk
comes from a global relabeling. -/
theorem nonabelian_isCoboundary_of_trivial_monodromy [Nonempty ι]
    {A : ι → ι → Prop} {c : ι → ι → G}
    (hsym : ∀ x y, A x y → A y x) (hinv : ∀ x y, c y x = (c x y)⁻¹)
    (hconn : IsConnectedNerve A) (hmon : TrivialMonodromy A c) :
    IsMulCoboundaryOn A c := by
  classical
  obtain ⟨b⟩ := ‹Nonempty ι›
  refine ⟨fun i => wprod c b (Classical.choose (hconn b i)), ?_⟩
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
  have hone := hmon b _ hwalk hclosed
  rw [wprod_append, hp.2] at hone
  have hrs : wprod c j (revW b q) = (wprod c b q)⁻¹ := by
    have := wprod_revW c hinv b q
    rwa [hq.2] at this
  simp only [wprod_cons] at hone
  rw [hrs] at hone
  -- `hone : wprod c b p * (c i j * (wprod c b q)⁻¹) = 1`
  rw [← mul_assoc] at hone
  calc c i j
      = (wprod c b p)⁻¹ * (wprod c b p * c i j * (wprod c b q)⁻¹) * wprod c b q := by group
    _ = (wprod c b p)⁻¹ * 1 * wprod c b q := by rw [hone]
    _ = (wprod c b p)⁻¹ * wprod c b q := by group

/-- **The nonabelian obstruction theorem.** -/
theorem nonabelian_discrete_poincare [Nonempty ι] {A : ι → ι → Prop} {c : ι → ι → G}
    (hsym : ∀ x y, A x y → A y x) (hinv : ∀ x y, c y x = (c x y)⁻¹)
    (hconn : IsConnectedNerve A) :
    IsMulCoboundaryOn A c ↔ TrivialMonodromy A c :=
  ⟨trivialMonodromy_of_isMulCoboundary,
    nonabelian_isCoboundary_of_trivial_monodromy hsym hinv hconn⟩

/-- A single loop with nontrivial monodromy obstructs every global relabeling. -/
theorem not_isCoboundary_of_monodromy_ne_one {A : ι → ι → Prop} {c : ι → ι → G}
    {i : ι} {l : List ι} (hw : IsWalk A i l) (hcl : endpt i l = i)
    (hne : wprod c i l ≠ 1) : ¬ IsMulCoboundaryOn A c := fun hc =>
  hne (trivialMonodromy_of_isMulCoboundary hc i l hw hcl)

/-- **Multi-class decision monodromy.**  If transporting the class labels of a
`k`-class classifier around a loop of overlapping regions returns a nontrivial
permutation of the classes, then no globally consistent labelling of the cover
exists — a cohomological obstruction with values in `Equiv.Perm (Fin k)`. -/
theorem perm_monodromy_obstructs_global_labelling {k : ℕ} {A : ι → ι → Prop}
    {c : ι → ι → Equiv.Perm (Fin k)} {i : ι} {l : List ι}
    (hw : IsWalk A i l) (hcl : endpt i l = i) (hne : wprod c i l ≠ 1) :
    ¬ ∃ f : ι → Equiv.Perm (Fin k), ∀ u v, A u v → c u v = (f u)⁻¹ * f v :=
  not_isCoboundary_of_monodromy_ne_one hw hcl hne

/-! ## §3. A realised three-class obstruction -/

/-- An explicit transition cochain for a three-class classifier on three mutually
overlapping regions: crossing an overlap "upwards" applies the transposition of
classes `0` and `1`, crossing it downwards applies its inverse. -/
def exTransition : Fin 3 → Fin 3 → Equiv.Perm (Fin 3) := fun x y =>
  if x.val < y.val then Equiv.swap 0 1 else if y.val < x.val then (Equiv.swap 0 1)⁻¹ else 1

theorem exTransition_inv : ∀ x y, exTransition y x = (exTransition x y)⁻¹ := by decide

/-- Its monodromy around the loop `0 → 1 → 2 → 0` is the transposition `(0 1)`,
which is not the identity. -/
theorem exTransition_monodromy_ne_one : wprod exTransition 0 [1, 2, 0] ≠ 1 := by decide

/-- **The obstruction is realised.**  For this three-class cover no global
relabelling of the regions is compatible with the transitions: the multi-class
decision data cannot be glued, even though every pairwise overlap is consistent
by construction. -/
theorem exTransition_no_global_labelling :
    ¬ ∃ f : Fin 3 → Equiv.Perm (Fin 3),
        ∀ u v, (fun _ _ : Fin 3 => True) u v → exTransition u v = (f u)⁻¹ * f v :=
  perm_monodromy_obstructs_global_labelling (A := fun _ _ : Fin 3 => True)
    (by trivial) rfl exTransition_monodromy_ne_one

end Nonabelian
end SheafCohomologyRobustness