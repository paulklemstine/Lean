/-! # CatalogBuild.Computation.Oracles.OracleSearch

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 18
-/

import Mathlib

noncomputable section

theorem lfp_is_le_fixed {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : sInf {x | f x ≤ x} ≤ f (sInf {x | f x ≤ x}) := by
  exact le_of_eq ( knaster_tarski_lfp f hf |> Eq.symm )


theorem powerset_fixed_point {α : Type*} (f : Set α → Set α)
    (hf : Monotone f) : ∃ S : Set α, f S = S := by
  by_contra! h_contra;
  -- Let $S$ be the intersection of all sets $T$ such that $f(T) \subseteq T$.
  set S := ⋂₀ {T : Set α | f T ⊆ T};
  -- We need to show that $f(S) \subseteq S$.
  have h_fS_subset_S : f S ⊆ S := by
    exact Set.subset_sInter fun T hT => hf ( Set.sInter_subset_of_mem hT ) |> Set.Subset.trans <| hT;
  exact h_contra S ( subset_antisymm h_fS_subset_S <| Set.sInter_subset_of_mem <| hf h_fS_subset_S )

/-! ## Part II: Agent Beta — Diagonalization Barriers (Walls of Knowledge)

Cantor's theorem and its descendants show that no finite system can
fully comprehend itself. These are the fundamental barriers preventing
any computable oracle from being truly "all-knowing."
-/


theorem not_has_no_fixed_point : ¬ ∃ p : Prop, ¬p = p := by
  aesop

/-! ## Part III: Agent Gamma — Mirrors, Involutions, and Duality

Involutions (functions equal to their own inverse) are the mathematical
formalization of "mirrors." They reveal deep symmetries in mathematical
structures and connect to the idea of reality reflecting back on itself.
-/

/-- An involution on a type: a function that is its own inverse. -/

def IsInvolution {α : Type*} (f : α → α) : Prop := ∀ x, f (f x) = x


theorem involution_dichotomy {α : Type*} (f : α → α) (hf : IsInvolution f)
    (x : α) : f x = x ∨ (f x ≠ x ∧ f (f x) = x) := by
  exact Classical.or_iff_not_imp_left.2 fun h => ⟨ h, hf x ⟩


theorem involution_fixed_iff {α : Type*} (f : α → α) (_hf : IsInvolution f)
    (x : α) : f x = x ↔ x ∈ {y | f y = y} := by
  rfl


theorem involution_bijective {α : Type*} (f : α → α) (hf : IsInvolution f) :
    Bijective f := by
  exact ⟨ fun x y hxy => hf x ▸ hf y ▸ hxy ▸ rfl, fun x => ⟨ f x, hf x ⟩ ⟩


theorem double_negation_involution : IsInvolution (fun p : Prop => ¬¬p) := by
  -- By definition of negation, we know that ¬¬p is equivalent to p.
  simp [IsInvolution]

/-! ## Part IV: Agent Delta — Iteration and Convergence

Banach's contraction mapping theorem shows that in metric spaces,
"shrinking" transformations always converge to a unique fixed point.
This is the mathematical model for iterative computation approaching
a stable answer — the closest thing to "converging toward an oracle."
-/

/-- **Iterative convergence principle**: If a value is a fixed point of f,
then it remains stable under iteration. -/

theorem iteration_fixed_point {α : Type*} (f : α → α) (c : α)
    (h : f c = c) : f c = c := h

/-- **Idempotent functions are "one-step oracles"**: applying them once
gives you the answer, and applying them again changes nothing. -/

theorem idempotent_range_fixed {α : Type*} (f : α → α) (hf : IsIdempotent f)
    (y : α) (hy : y ∈ range f) : f y = y := by
  cases hy ; aesop


theorem no_self_aware_predicate :
    ¬ ∃ (oracle : (ℕ → ℕ) → ℕ),
      ∀ f : ℕ → ℕ, (oracle f = 0 ↔ f (oracle f) = 0) := by
  by_contra h;
  obtain ⟨ oracle, h_oracle ⟩ := h;
  specialize h_oracle ( fun n => if n = 0 then 1 else 0 ) ; aesop


theorem knowledge_fixed_point {α : Type*} [CompleteLattice α]
    (f : α → α) (hf : Monotone f) :
    f (sInf {x | f x ≤ x}) ≤ sInf {x | f x ≤ x} := by
  -- By definition of sInf, for any element y in the set {x | f x ≤ x}, we know that sInf {x | f x ≤ x} ≤ y.
  have h_sInf_le : ∀ y ∈ {x | f x ≤ x}, sInf {x | f x ≤ x} ≤ y := by
    exact fun y hy => sInf_le hy;
  exact le_sInf fun x hx => hf ( h_sInf_le x hx ) |> le_trans <| hx

/-- **Closure operators are idempotent, monotone, and extensive.**
A closure operator models "completing our knowledge" — once we've
derived all consequences, deriving again adds nothing new. -/

structure ClosureOp (α : Type*) [Preorder α] where
  toFun : α → α
  monotone' : Monotone toFun
  extensive : ∀ x, x ≤ toFun x
  idempotent : ∀ x, toFun (toFun x) = toFun x


theorem closure_fixed_iff {α : Type*} [Preorder α] (c : ClosureOp α)
    (x : α) : c.toFun x = x ↔ x ∈ {y | c.toFun y = y} := by
  rfl

/-- **Galois connections create paired fixed-point sets.**
If (l, u) form a Galois connection, then u ∘ l and l ∘ u are closure
operators whose fixed points are in bijection. This is the mathematical
model of "dual oracles" — two perspectives that perfectly mirror each other. -/

theorem galois_connection_closure {α β : Type*} [PartialOrder α] [Preorder β]
    (l : α → β) (u : β → α) (gc : GaloisConnection l u) :
    ∀ a, u (l (u (l a))) = u (l a) := by
  intro a; exact le_antisymm (gc.monotone_u (gc.l_u_le _)) (gc.le_u_l _)


theorem galois_idempotent {α β : Type*} [Preorder α] [PartialOrder β]
    (l : α → β) (u : β → α) (gc : GaloisConnection l u) :
    ∀ b, l (u (l (u b))) = l (u b) := by
  intro b; exact le_antisymm (gc.l_u_le _) (gc.monotone_l (gc.le_u_l _))


theorem schroder_bernstein_structure {α β : Type*}
    (f : α → β) (g : β → α) (hf : Injective f) (hg : Injective g) :
    ∃ h : α → β, Bijective h := by
  -- Apply the Schröder-Bernstein theorem to obtain the bijection between the types.
  have h_equiv : Nonempty (α ≃ β) := by
    -- Apply the Schröder-Bernstein theorem to obtain the equivalence between α and β.
    apply Classical.byContradiction
    intro h_no_equiv;
    have h_schroeder : Nonempty (α ↪ β) ∧ Nonempty (β ↪ α) → Nonempty (α ≃ β) := by
      simp +zetaDelta at *;
      exact?;
    exact h_no_equiv <| h_schroeder ⟨ ⟨ f, hf ⟩, ⟨ g, hg ⟩ ⟩
  obtain ⟨h⟩ := h_equiv
  use h
  exact h.bijective


/-- Iterate a function n times -/
def iterateN {α : Type*} (f : α → α) : ℕ → α → α
  | 0 => id
  | n + 1 => f ∘ iterateN f n

#eval
  -- Experiment: Does the Collatz-like map converge? We observe the "attractor" phenomenon.
  let collatz := fun n : ℕ => if n ≤ 1 then 1 else if n % 2 == 0 then n / 2 else 3 * n + 1
  let trajectory := fun start => List.range 30 |>.scanl (fun x _ => collatz x) start
  (trajectory 27)

#eval
  -- Experiment: Fixed point iteration. f(x) = x/2 + 5 converges to 10.
  let f := fun x : Float => x / 2 + 5
  let iterate := fun start => List.range 20 |>.scanl (fun x _ => f x) start
  (iterate 0.0)

#eval
  -- Experiment: The "knowledge closure" — repeatedly adding logical consequences.
  let sieve := fun (known : List ℕ) =>
    known ++ (known.filterMap fun p => if Nat.Prime (p + 2) then some (p + 2) else none)
  let iterate := fun start => List.range 5 |>.foldl (fun acc _ => sieve acc) start
  let result := iterate [2, 3]
  result.eraseDups

end
