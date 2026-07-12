/-
# Chemical Reaction Networks: discrete mass-action semantics and a hard limit on molecular computing

This file formalizes the **discrete state-transition semantics** of a Chemical
Reaction Network (CRN) — the mathematical core of a "molecular computer" in which
a bag of molecules performs computation via chemical reactions.

We take the standard *population / Petri-net* view of a CRN:

* A **species** is an element of a type `S`. A **state** is a multiset of
  molecules, represented by a molecule-count vector `x : S → ℕ`.
* A **reaction** `r` has a `reactant` vector and a `product` vector.
  It is **enabled** at `x` when enough reactant molecules are present
  (`r.reactant ≤ x`, pointwise), and firing it consumes reactants and creates
  products: `r.fire x = x - reactant + product` (pointwise, truncated ℕ
  subtraction, which is exact on enabled states).
* A **CRN** is a finite list of reactions `rs`. `Step rs` is one reaction firing,
  and `Reach rs` is its reflexive–transitive closure (reachability).

We prove a coherent body of genuine facts:

* `Reaction.enabled_mono`, `Reaction.fire_add` — **strong monotonicity**: if a
  reaction is enabled at `x`, firing it at `x + d` produces `fire x + d`. Extra
  molecules simply ride along untouched.
* `step_shift`, `reach_shift` — the whole reachability relation is
  **translation-invariant**: `Reach rs x y → Reach rs (x+d) (y+d)`.
* `coverable_mono` — **coverability is upward monotone**, the classic feature
  distinguishing CRN/Petri-net dynamics.
* `mass_fire`, `mass_reach` — **conservation laws**: any linear functional
  `w : S → ℤ` that is balanced across every reaction is invariant along all
  reachable trajectories (mass / charge / atom conservation).
* `no_zero_test` — **the fundamental limit**: because enabledness is monotone, a
  reaction can *never* detect the *absence* of a species (`x s₀ = 0`). This is the
  precise reason the plain discrete mass-action model is **not** Turing-complete:
  it cannot perform the zero-test that a register / counter machine needs. Genuine
  Turing-completeness of CRNs requires extra power (unbounded time with vanishing
  error probability, à la Soloveichik–Cook–Winfree–Bruck), not available in the
  exact discrete dynamics.

Everything is proved from first principles; the file is self-contained.
-/
import Mathlib

open scoped BigOperators

namespace MolecularComputing

variable {S : Type*}

/-- A reaction: a `reactant` complex consumed and a `product` complex created. -/
structure Reaction (S : Type*) where
  reactant : S → ℕ
  product  : S → ℕ

/-- A reaction is enabled at a state when all reactant molecules are present. -/
def Reaction.enabled (r : Reaction S) (x : S → ℕ) : Prop := r.reactant ≤ x

/-- Firing a reaction: consume the reactants, create the products. On enabled
states the truncated ℕ subtraction is exact. -/
def Reaction.fire (r : Reaction S) (x : S → ℕ) : S → ℕ :=
  fun s => x s - r.reactant s + r.product s

/-- Enabledness is upward closed: more molecules keep a reaction enabled. -/
theorem Reaction.enabled_mono (r : Reaction S) {x y : S → ℕ}
    (h : r.enabled x) (hxy : x ≤ y) : r.enabled y := le_trans h hxy

/-- **Strong monotonicity.** If `r` is enabled at `x`, then firing it at `x + d`
gives `fire x + d`: the surplus `d` of molecules is untouched by the reaction. -/
theorem Reaction.fire_add (r : Reaction S) (x d : S → ℕ) (h : r.enabled x) :
    r.fire (x + d) = r.fire x + d := by
  funext s
  have : r.reactant s ≤ x s := h s
  simp only [Reaction.fire, Pi.add_apply]
  omega

/-- Firing is monotone in the state (a corollary of `fire_add`). -/
theorem Reaction.fire_mono (r : Reaction S) {x y : S → ℕ}
    (hx : r.enabled x) (hxy : x ≤ y) : r.fire x ≤ r.fire y := by
  intro s
  have h1 : x s ≤ y s := hxy s
  have h2 : r.reactant s ≤ x s := hx s
  simp only [Reaction.fire]
  omega

/-- One firing of some reaction of the CRN `rs`. -/
def Step (rs : List (Reaction S)) (x y : S → ℕ) : Prop :=
  ∃ r ∈ rs, r.enabled x ∧ y = r.fire x

/-- Reachability: the reflexive–transitive closure of `Step`. -/
def Reach (rs : List (Reaction S)) : (S → ℕ) → (S → ℕ) → Prop :=
  Relation.ReflTransGen (Step rs)

theorem Reach.refl (rs : List (Reaction S)) (x : S → ℕ) : Reach rs x x :=
  Relation.ReflTransGen.refl

theorem Reach.trans {rs : List (Reaction S)} {x y z : S → ℕ}
    (h₁ : Reach rs x y) (h₂ : Reach rs y z) : Reach rs x z :=
  Relation.ReflTransGen.trans h₁ h₂

/-- **Translation invariance of a single step.** -/
theorem step_shift {rs : List (Reaction S)} {x y : S → ℕ} (d : S → ℕ)
    (h : Step rs x y) : Step rs (x + d) (y + d) := by
  obtain ⟨r, hr, hen, hy⟩ := h
  refine ⟨r, hr, ?_, ?_⟩
  · intro s; have hs : r.reactant s ≤ x s := hen s
    simp only [Pi.add_apply]; omega
  · rw [hy, r.fire_add x d hen]

/-- **Translation invariance of reachability.** Adding a fixed molecule surplus
`d` to source and target preserves reachability. -/
theorem reach_shift {rs : List (Reaction S)} {x y : S → ℕ} (d : S → ℕ)
    (h : Reach rs x y) : Reach rs (x + d) (y + d) := by
  induction h with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hstep ih => exact ih.tail (step_shift d hstep)

/-- A target complex is **coverable** from `x` if some reachable state dominates
it (enough molecules of each species are eventually present). -/
def Coverable (rs : List (Reaction S)) (x target : S → ℕ) : Prop :=
  ∃ y, Reach rs x y ∧ target ≤ y

/-- **Coverability is upward monotone**: starting with more molecules can only
help. This monotonicity is the structural hallmark of CRN / Petri-net dynamics. -/
theorem coverable_mono {rs : List (Reaction S)} {x x' target : S → ℕ}
    (hx : x ≤ x') (h : Coverable rs x target) : Coverable rs x' target := by
  obtain ⟨y, hreach, hcov⟩ := h
  refine ⟨y + (x' - x), ?_, ?_⟩
  · have hxx' : x + (x' - x) = x' := by
      funext s; have h1 : x s ≤ x' s := hx s
      simp only [Pi.add_apply, Pi.sub_apply]; omega
    have hr := reach_shift (x' - x) hreach
    rwa [hxx'] at hr
  · intro s; have h1 : target s ≤ y s := hcov s
    simp only [Pi.add_apply]; omega

/-! ### Conservation laws (mass / charge / atom count) -/

/-- The value of a linear functional `w : S → ℤ` on a state. Think: total mass,
total charge, or the number of atoms of a given element. -/
noncomputable def mass [Fintype S] (w : S → ℤ) (x : S → ℕ) : ℤ :=
  ∑ s, w s * (x s : ℤ)

/-- `w` is **conserved** by a reaction if its value is the same on the reactant
and product complexes. -/
def Reaction.Conserves [Fintype S] (w : S → ℤ) (r : Reaction S) : Prop :=
  ∑ s, w s * (r.product s : ℤ) = ∑ s, w s * (r.reactant s : ℤ)

/-- A conserved functional is unchanged by firing an enabled reaction. -/
theorem mass_fire [Fintype S] (r : Reaction S) (w : S → ℤ) (x : S → ℕ)
    (hen : r.enabled x) (hcons : r.Conserves w) :
    mass w (r.fire x) = mass w x := by
  have hfire : ∀ s, (r.fire x s : ℤ) = (x s : ℤ) - r.reactant s + r.product s := by
    intro s; have hs : r.reactant s ≤ x s := hen s
    simp only [Reaction.fire]; omega
  unfold mass
  simp only [hfire]
  rw [Finset.sum_congr rfl (fun s _ => by ring : ∀ s ∈ Finset.univ,
      w s * ((x s : ℤ) - r.reactant s + r.product s)
        = w s * x s - w s * r.reactant s + w s * r.product s)]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, hcons]
  ring

/-- **Conservation along all trajectories.** If every reaction of the CRN
conserves `w`, then `w` is invariant on the entire reachable set. -/
theorem mass_reach [Fintype S] {rs : List (Reaction S)} (w : S → ℤ)
    (hcons : ∀ r ∈ rs, r.Conserves w) {x y : S → ℕ} (h : Reach rs x y) :
    mass w y = mass w x := by
  induction h with
  | refl => rfl
  | tail _ hstep ih =>
      obtain ⟨r, hr, hen, hy⟩ := hstep
      rw [hy, mass_fire r w _ hen (hcons r hr), ih]

/-! ### The fundamental limitation: no zero-test -/

/-- **No zero-test (absence detector).** Because enabledness is upward monotone,
no reaction can be enabled *exactly* when a given species `s₀` is absent. Formally
there is no reaction whose enabling condition is equivalent to `x s₀ = 0`.

This is the precise obstruction to Turing-completeness of the exact discrete
mass-action model: a register machine needs to test a counter for zero, but a
monotone reaction can never distinguish "0 molecules" from "1 molecule" as a
*negative* trigger. -/
theorem no_zero_test [DecidableEq S] (r : Reaction S) (s0 : S) :
    ¬ (∀ x : S → ℕ, r.enabled x ↔ x s0 = 0) := by
  intro h
  -- the reactant complex is always enabled, hence must satisfy the "= 0" test
  have h1 : r.enabled r.reactant := le_refl _
  have hr0 : r.reactant s0 = 0 := (h r.reactant).1 h1
  -- bump species `s₀` by one: still enabled by monotonicity, yet count is 1 ≠ 0
  set z : S → ℕ := fun s => if s = s0 then 1 else r.reactant s with hz
  have hze : r.enabled z := by
    intro s
    by_cases hs : s = s0
    · subst hs; simp [hz, hr0]
    · simp [hz, hs]
  have : z s0 = 0 := (h z).1 hze
  simp [hz] at this

end MolecularComputing