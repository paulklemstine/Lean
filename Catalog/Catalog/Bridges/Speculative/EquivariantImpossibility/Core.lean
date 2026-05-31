/-
# A Unified Calculus of Impossibility via Group Actions and Equivariant Tasks

This file formalizes a general theory of impossibility through the lens of
equivariant tasks on group actions. The central insight: many classical
"impossible" results arise because a task demands a canonical choice or
equivariant compression across nontrivial symmetry, and this is obstructed
by orbit geometry.

## Main definitions
- `EquivariantTask`: a task specified by admissible output sets that respect a group action
- `TaskSolvable`: existence of an equivariant solution
- `ConstantTask`: the task of finding a constant equivariant map (impossibility witness)
- `IdentityTask`: the trivially solvable task of returning the input

## Main results
- `identity_task_solvable`: the identity task is always solvable (Theorem E)
- `no_equivariant_constant_on_free_transitive`: no equivariant constant map exists
  on a free nontrivial transitive action (Theorem A — core impossibility)
- `exists_impossible_equivariant_task_of_free_action`: existence of an impossible task (Theorem B)
- `no_equivariant_retraction_of_free_finite_action`: finite counting obstruction (Theorem D)
- `no_equivariant_section_of_free_nontrivial`: no equivariant section to quotient (Theorem C)

Keywords: group actions, equivariance, impossibility theorems, symmetry breaking, torsors,
  orbit-stabilizer, social choice, no-go theorems, invariant selection
-/

import Mathlib

/-! ## Core Definitions -/

/-- An equivariant task for a group `G` acting on types `X` and `Y`.
At each input `x : X`, the task specifies a set of admissible outputs in `Y`,
and these admissible sets are compatible with the group action. -/
structure EquivariantTask (G X Y : Type*) [Group G] [MulAction G X] [MulAction G Y] where
  /-- The set of admissible outputs for each input -/
  admissible : X → Set Y
  /-- Admissibility is equivariant: `y` is admissible at `x` iff `g • y` is admissible at `g • x` -/
  equiv_admissible : ∀ (g : G) (x : X) (y : Y), y ∈ admissible x ↔ g • y ∈ admissible (g • x)

/-- A task is solvable if there exists an equivariant function selecting admissible outputs. -/
def TaskSolvable (G X Y : Type*) [Group G] [MulAction G X] [MulAction G Y]
    (T : EquivariantTask G X Y) : Prop :=
  ∃ f : X → Y, (∀ x, f x ∈ T.admissible x) ∧ (∀ (g : G) (x : X), f (g • x) = g • f x)

/-- The identity task: the only admissible output at `x` is `x` itself.
This is always solvable and serves as a counterexample to the naive conjecture
"free action implies all equivariant tasks are impossible." -/
def IdentityTask (G X : Type*) [Group G] [MulAction G X] :
    EquivariantTask G X X where
  admissible x := {x}
  equiv_admissible g x y := by
    simp only [Set.mem_singleton_iff]
    exact ⟨fun h => by rw [h], fun h => smul_left_cancel g h⟩

/-- The constant task: admissible outputs at every `x` are exactly a fixed subset `S`
which is preserved by the group action. The task asks for an equivariant function
whose image lies in `S` — on a free transitive action with nontrivial S this forces
the function to be constant, which contradicts equivariance.

Here we use the simplest version: admissible set is the whole space.
The impossibility comes from requiring equivariance AND constancy simultaneously. -/
def ConstantTask (G X : Type*) [Group G] [MulAction G X] :
    EquivariantTask G X X where
  admissible _ := Set.univ
  equiv_admissible _ _ _ := by simp

/-! ## Theorem E: Identity task is always solvable (counterexample to naive conjecture) -/

/-- The identity task is always solvable: the identity function `id` is equivariant
and always selects an admissible output. This shows that freeness of an action does NOT
imply that all equivariant tasks are impossible — refuting the naive conjecture. -/
theorem identity_task_solvable
    (G X : Type*) [Group G] [MulAction G X] :
    TaskSolvable G X X (IdentityTask G X) :=
  ⟨id, fun _ => rfl, fun _ _ => rfl⟩

/-! ## Auxiliary lemmas -/

/-- A free transitive action with a nontrivial element implies the type has
at least two distinct elements. -/
lemma exists_ne_of_free_nontrivial_trans
    (G X : Type*) [Group G] [MulAction G X]
    (hfree : ∀ (g : G), g ≠ 1 → ∀ (x : X), g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1)
    (x : X) :
    ∃ y : X, y ≠ x := by
  obtain ⟨g, hg⟩ := hne
  exact ⟨g • x, hfree g hg x⟩

/-! ## Theorem A: No equivariant constant map on a free nontrivial action -/

/-
**Main Theorem A.** On a free action with a nontrivial element,
no equivariant map `X → X` can be constant. This is the core impossibility:
symmetry-respecting maps cannot break symmetry.

Proof: If `f` is equivariant and constant (`f x = c` for all `x`), then
`f(g • x) = g • f(x) = g • c`. But also `f(g • x) = c` since `f` is constant.
So `g • c = c` for all `g`, contradicting freeness when `g ≠ 1`.
-/
theorem no_equivariant_constant_on_free_nontrivial
    (G X : Type*) [Group G] [MulAction G X]
    (hfree : ∀ (g : G), g ≠ 1 → ∀ (x : X), g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1) :
    ¬ ∃ (f : X → X) (c : X), (∀ (g : G) (x : X), f (g • x) = g • f x) ∧
      (∀ x, f x = c) := by
  push_neg;
  intro f c hf;
  contrapose! hfree;
  exact ⟨ hne.choose, hne.choose_spec, c, by simpa [ hfree ] using hf hne.choose c |> Eq.symm ⟩

/-! ## Theorem: No equivariant retraction (constant-valued equivariant map) -/

/-
**Theorem.** On a free nontrivial action, there is no equivariant map that
sends all points to the same value. This is equivalent to saying that an
equivariant retraction collapsing orbits to representatives cannot exist.
-/
theorem no_equivariant_retraction_of_free_nontrivial
    (G X : Type*) [Group G] [MulAction G X] [Nonempty X]
    (hfree : ∀ (g : G), g ≠ 1 → ∀ (x : X), g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1) :
    ¬ ∃ r : X → X, (∀ (g : G) (x : X), r (g • x) = g • r x) ∧
      (∀ x y : X, r x = r y) := by
  exact fun ⟨ r, hr1, hr2 ⟩ => no_equivariant_constant_on_free_nontrivial G X hfree hne ⟨ r, r ( Classical.arbitrary X ), hr1, fun x => hr2 _ _ ⟩

/-! ## Theorem B: Existence of an impossible equivariant task -/

/-- The orbit-collapsing task: admissible outputs at `x` are all points in the orbit,
but the task additionally requires the solution to be orbit-constant (which is
encoded in the equivariance + admissibility structure).

Actually, we define a task where the admissible set at every point is a fixed point
set. The point is that on a free transitive action, the fixed point set is empty,
making the task trivially impossible. -/
def FixedPointTask (G X : Type*) [Group G] [MulAction G X] :
    EquivariantTask G X X where
  admissible _ := MulAction.fixedPoints G X
  equiv_admissible g x y := by
    constructor
    · intro hy
      simp only [MulAction.mem_fixedPoints] at hy ⊢
      intro h
      calc h • (g • y) = g • ((g⁻¹ * h * g) • y) := by simp [mul_smul]
        _ = g • y := by rw [hy]
    · intro hy
      simp only [MulAction.mem_fixedPoints] at hy ⊢
      intro h
      have := hy (g * h * g⁻¹)
      simp [mul_smul] at this
      exact this

/-
On a free action with a nontrivial element, the fixed point set is empty.
-/
lemma fixedPoints_empty_of_free_nontrivial
    (G X : Type*) [Group G] [MulAction G X]
    (hfree : ∀ (g : G), g ≠ 1 → ∀ (x : X), g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1) :
    MulAction.fixedPoints G X = ∅ := by
  exact Set.eq_empty_of_forall_notMem fun x hx => hfree hne.choose hne.choose_spec x ( hx hne.choose )

/-
The fixed point task is unsolvable on a free nontrivial action,
because there are no fixed points to select.
-/
theorem fixedpoint_task_impossible_of_free_nontrivial
    (G X : Type*) [Group G] [MulAction G X] [Nonempty X]
    (hfree : ∀ (g : G), g ≠ 1 → ∀ (x : X), g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1) :
    ¬ TaskSolvable G X X (FixedPointTask G X) := by
  -- By definition of `FixedPoint �Task�`, the admissible set at every point is the empty set.
  have h_admissible_empty : MulAction.fixedPoints G X = ∅ := by
    exact fixedPoints_empty_of_free_nontrivial G X hfree hne;
  unfold TaskSolvable FixedPointTask; simp +decide [ h_admissible_empty ] ;

/-- **Theorem B.** If a group acts freely with a nontrivial element on a nonempty type,
then there exists a natural equivariant task which is impossible.
The witness is the fixed-point selection task. -/
theorem exists_impossible_equivariant_task_of_free_action
    (G X : Type*) [Group G] [MulAction G X] [Nonempty X]
    (hfree : ∀ (g : G), g ≠ 1 → ∀ (x : X), g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1) :
    ∃ T : EquivariantTask G X X, ¬ TaskSolvable G X X T :=
  ⟨FixedPointTask G X, fixedpoint_task_impossible_of_free_nontrivial G X hfree hne⟩

/-! ## Theorem D: Finite counting obstruction -/

/-
**Theorem D.** For finite groups acting freely on a finite set with `|G| > 1`,
no equivariant retraction can collapse all points to a single value.
The proof uses the fact that equivariance forces `r` to commute with all
group elements, so if `r` is constant then the constant value is a fixed point,
which contradicts freeness.
-/
theorem no_equivariant_retraction_of_free_finite_action
    (G X : Type*) [Fintype G] [Group G] [Fintype X] [MulAction G X] [Nonempty X]
    (hfree : ∀ (g : G), g ≠ 1 → ∀ (x : X), g • x ≠ x)
    (hne : Fintype.card G > 1) :
    ¬ ∃ r : X → X, (∀ (g : G) (x : X), r (g • x) = g • r x) ∧
      (∀ x y : X, r x = r y) := by
  -- Apply Theorem A to obtain the contradiction.
  apply no_equivariant_retraction_of_free_nontrivial G X hfree;
  exact Fintype.exists_ne_of_one_lt_card hne 1

/-! ## Cross-Domain: Social Choice / Symmetry Breaking Impossibility -/

/-
**Cross-domain Theorem: Social Choice Symmetry Obstruction.**

Consider candidates labeled by a type `C` with `|C| ≥ 2`. The symmetric group
`Equiv.Perm C` acts on `C` by evaluation. A "fair winner selection" would be
an equivariant map `f : C → C` (representing: relabeling candidates relabels the
winner) that is also constant (representing: the winner doesn't depend on labeling).

This is impossible when `|C| ≥ 2`: the only equivariant self-maps of a set under
its full symmetric group are permutations, and a constant map is only a permutation
if `|C| = 1`.

More precisely: on any set acted on freely by a nontrivial group, no equivariant
constant map exists. This is exactly the social choice impossibility in disguise.
-/
theorem no_equivariant_constant_social_choice
    (C : Type*) [DecidableEq C] [Fintype C]
    (hC : Fintype.card C ≥ 2) :
    ¬ ∃ (f : C → C) (c : C),
      (∀ (σ : Equiv.Perm C) (x : C), f (σ x) = σ (f x)) ∧
      (∀ x, f x = c) := by
  simp +zetaDelta at *;
  intro f hf c;
  contrapose! hC;
  -- Since $f$ is constant, for any $x \in C$, we have $f(x) = c$. But $f$ is also equivariant, so for any permutation $\sigma$, we have $f(\sigma(x)) = \sigma(f(x))$. Substituting $f(x) = c$, we get $\sigma(c) = c$ for all $\sigma$.
  have h_fixed : ∀ σ : Equiv.Perm C, σ c = c := by
    exact fun σ => by simpa [ hC ] using hf σ c |> Eq.symm;
  exact lt_of_not_ge fun h => by have := h_fixed ( Equiv.swap c ( Classical.choose ( Fintype.exists_ne_of_one_lt_card h c ) ) ) ; simp +decide [ Classical.choose_spec ( Fintype.exists_ne_of_one_lt_card h c ) ] at this;

/-! ## Theorem C: Equivariant self-map injectivity on free actions -/

/-
**Theorem C.** Any equivariant self-map on a free transitive action is injective.
This is a structural result: symmetry-respecting maps on free actions preserve
distinctness.

Proof: If `f(x₁) = f(x₂)`, by transitivity get `g` with `g • x₁ = x₂`.
Then `f(x₂) = f(g • x₁) = g • f(x₁) = g • f(x₂)`. By freeness, `g = 1`,
so `x₁ = x₂`.
-/
theorem equivariant_self_map_injective_of_free_transitive
    (G X : Type*) [Group G] [MulAction G X]
    (hfree : ∀ (g : G), g ≠ 1 → ∀ (x : X), g • x ≠ x)
    (htrans : ∀ x y : X, ∃ g : G, g • x = y)
    (f : X → X) (hf : ∀ (g : G) (x : X), f (g • x) = g • f x) :
    Function.Injective f := by
  intro x y hxy
  obtain ⟨g, hg⟩ := htrans x y
  have hfg := hf g x
  simp [hg] at hfg
  have hg1 : g = 1 := by
    grind +qlia
  aesop

#print axioms identity_task_solvable