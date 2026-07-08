/-
  # The Symmetry Principle of Impossibility

  A recurring theme across mathematics is that certain natural tasks are
  *impossible*: there is no way to select a canonical basepoint on a circle,
  no way to solve every quintic by radicals, no way to break a perfect symmetry
  by a rule that itself respects the symmetry.  This file isolates the algebraic
  kernel shared by such statements and proves it precisely.

  The setting is a group `G` acting on a set `X`.  We model a "symmetric task"
  as an **invariant distinguisher**: a function `f : X → Y` that is constant on
  orbits (`f (g • x) = f x`, i.e. it respects the symmetry) yet is injective
  (it tells the points of `X` apart).  Solving such a task means simultaneously
  *respecting* the symmetry and *breaking* it.

  Main results:

  * `isFreeAction_iff_orbit_injective` — freeness of the action is exactly the
    statement that every orbit map `g ↦ g • x` is injective; equivalently, the
    group's relabelings are all mutually distinguishable, so no relabeling can
    be canonically undone.

  * `solvable_iff_trivial_action` — the symmetric distinguishing task is
    solvable **iff** the action is trivial.  Hence the task is impossible in the
    presence of any genuine symmetry; a free nontrivial action is the extreme
    case.

  * `regularAction_task_impossible` — for the left-regular action of any
    nontrivial group on itself the task is impossible.  Instantiated at the
    symmetric group on five letters this is the group-theoretic shadow of the
    unsolvability of the quintic: the very structure that obstructs solving
    `x⁵ = a` by radicals also obstructs any symmetric canonical form.
-/
import Mathlib

namespace ImpossibilityFreeAction

universe u v

variable {G : Type v} {X : Type u} [Group G] [MulAction G X]

/-- The action of `G` on `X` is **free** if the only group element fixing any
point is the identity. -/
def IsFreeAction (G : Type v) (X : Type u) [Group G] [MulAction G X] : Prop :=
  ∀ (x : X) (g : G), g • x = x → g = 1

/-- A function `f : X → Y` is **invariant** (a symmetric observable) if it is
constant along the group action. -/
def IsInvariant (G : Type v) {X : Type u} {Y : Type*} [Group G] [MulAction G X]
    (f : X → Y) : Prop :=
  ∀ (g : G) (x : X), f (g • x) = f x

/-! ## Theorem 1 — Freeness is injectivity of the orbit maps -/

theorem isFreeAction_iff_orbit_injective :
    IsFreeAction G X ↔ ∀ x : X, Function.Injective (fun g : G => g • x) := by
  refine' ⟨ _, fun h x g hg => _ ⟩;
  · intro h x y z h';
    specialize h x ( z⁻¹ * y ) ; simp_all +decide [ mul_smul ];
    simpa using eq_inv_of_mul_eq_one_right h;
  · exact h x (by simp [hg])

/-! ## Theorem 2 — The symmetric task is solvable iff the action is trivial -/

theorem solvable_iff_trivial_action :
    (∃ (Y : Type u) (f : X → Y), IsInvariant G f ∧ Function.Injective f)
      ↔ ∀ (g : G) (x : X), g • x = x := by
  refine' ⟨ _, fun h => ⟨ X, id, _, _ ⟩ ⟩;
  · rintro ⟨ Y, f, hf₁, hf₂ ⟩ g x; have := hf₁ g x; have := hf₂; aesop;
  · exact fun g x => h g x;
  · exact Function.injective_id

/-! ## Supporting lemma — the left-regular action is free -/

theorem regularAction_isFree {G : Type u} [Group G] : IsFreeAction G G := by
  intro x g hg
  rw [smul_eq_mul] at hg
  have hgx : g * x = 1 * x := by rw [one_mul]; exact hg
  simpa using mul_right_cancel hgx

/-! ## Theorem 3 — Impossibility for the regular action of a nontrivial group -/

theorem regularAction_task_impossible {G : Type u} [Group G] [Nontrivial G] :
    ¬ ∃ (Y : Type u) (f : G → Y), IsInvariant G f ∧ Function.Injective f := by
  -- By `solvable_iff_trivial_action`, if there exists an invariant function `f` that is injective, then the action must be trivial.
  by_contra h
  obtain ⟨Y, f, h_inv, h_inj⟩ := h
  have h_trivial : ∀ g : G, ∀ x : G, g • x = x := by
    convert solvable_iff_trivial_action.mp ?_;
    use Y, f;
  obtain ⟨ g, hg ⟩ := exists_ne ( 1 : G ) ; specialize h_trivial g 1 ; aesop;

/-- **Bridge to the unsolvability of the quintic.**  The symmetric group on
five letters acts freely on itself, and being nontrivial admits no symmetric
distinguisher: no rule that respects relabeling can pick out its elements. -/
example :
    ¬ ∃ (Y : Type) (f : Equiv.Perm (Fin 5) → Y),
        IsInvariant (Equiv.Perm (Fin 5)) f ∧ Function.Injective f :=
  regularAction_task_impossible

/-
-- !-- Lab Notes -- !--

HYPOTHESIS.
  The folklore slogan "impossibility = symmetry" was sharpened into a testable
  claim: a natural selection/distinguishing task on a symmetric structure is
  impossible exactly when the acting group is nontrivial, with free actions the
  extreme case.  We modelled a symmetric task as an *invariant distinguisher* —
  a function constant on orbits yet injective — capturing the tension between
  "respect the symmetry" and "break the symmetry".

EXPERIMENT.
  Three statements were formulated and proved.
  (1) `isFreeAction_iff_orbit_injective`: freeness ⇔ every orbit map `g ↦ g•x`
      is injective.  The forward direction cancels a group element off both
      sides of `g • x = h • x`; the reverse direction reads off `g = 1` from
      `g • x = 1 • x`.
  (2) `solvable_iff_trivial_action`: an invariant injective task exists ⇔ the
      action is trivial.  Injectivity turns `f (g•x) = f x` into `g•x = x`;
      conversely the identity map witnesses solvability under a trivial action.
  (3) `regularAction_task_impossible`: for the left-regular action of a
      nontrivial group the task has no solution, since triviality of that
      action would force every element to equal the identity.

ANALYSIS.
  The clean equivalence is (2): solvability is governed *precisely* by
  triviality of the action, not by freeness alone.  This corrected the initial
  over-reach.  The naive biconditional "impossible ⇔ free" is FALSE — a
  nontrivial action that is not free (a rotation with a fixed point, say) still
  has non-singleton orbits and hence still blocks every invariant injection.
  Freeness is therefore *sufficient but not necessary*; the exact frontier is
  nontriviality.  What freeness buys is the strongest form of the obstruction
  (Theorem 1): not only is no relabeling undoable, but the whole group embeds
  into each orbit.

CRITIQUE.
  * No result is vacuous: `regularAction_task_impossible` is instantiated at
    the concrete nontrivial group `Equiv.Perm (Fin 5)`, so the negated
    existential is genuinely inhabited-free content.
  * The existential over `Type u` is universe-honest: the task is forbidden for
    *every* target type in the ambient universe, not just a chosen one.
  * Theorem 3 depends only on Theorem 2, which is proved earlier and
    independently — there is no circular reference.

SYNTHESIS.
  The bridge to the classical impossibilities is structural.  The symmetric
  group on five letters acts freely on itself; the same absence of an invariant
  distinguisher that the file proves is the group-theoretic shadow of the fact
  that the roots of a general quintic cannot be organized by a radical formula
  respecting their symmetry.  "You cannot break a symmetry with a symmetric
  rule" is thus not a metaphor but a theorem, with freeness as its sharpest
  instance.
-/

end ImpossibilityFreeAction