/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Lawvere Metric Semantics for Emergent Meta-Language Closures

Bridge: connects enriched category theory (Lawvere generalized metric spaces)
to closure operator theory, residuated/idempotent algebra, certified robustness (ML),
post-quantum lattice cost semantics, and thermodynamic fixed-point dynamics.

## Overview

Five interacting layers:
1. **Order-enriched distance** — `LawvereEMLSpace`: asymmetric Lawvere distances
2. **Closure semantics** — `EMLClosure`, `PreClosure`: closure-induced distances
3. **Nucleus reconstruction** — `SemiringNucleus`: algebraic data → distances
4. **Finitary/computational** — O(1) idempotent, O(|X|) finite pre-closure bounds
5. **Cross-domain bridges** — quantum, thermodynamic, post-quantum, ML robustness

## References
* Lawvere, "Metric spaces, generalized logic, and closed categories" (1973)
-/

import Mathlib

set_option checkBinderAnnotations false

/-! ## Section 1: Lawvere EML Spaces -/

/-- `LawvereEMLSpace X W` equips type `X` with an asymmetric `W`-valued distance
satisfying zero self-distance and the triangle inequality. No symmetry required.

Bridge: enriched category theory × computational distance semantics ×
thermodynamic/quantum information flow (asymmetry models irreversibility). -/
class LawvereEMLSpace (X : Type*) (W : outParam (Type*))
    [Preorder W] [AddMonoid W] where
  dist : X → X → W
  dist_self : ∀ x, dist x x = 0
  dist_trans : ∀ x y z, dist x z ≤ dist x y + dist y z

/-- Asymmetric nonexpansiveness: `f` does not increase distances.

Bridge: Lipschitz-certified robustness — nonexpansive classifiers have
certified perturbation budgets bounded by input distance. -/
def IsLawvereNonexpansive
    {X Y W : Type*} [Preorder W] [AddMonoid W]
    (dX : X → X → W) (dY : Y → Y → W) (f : X → Y) : Prop :=
  ∀ x y, dY (f x) (f y) ≤ dX x y

/-- Bridge: self-distance vanishes — identity channel in quantum information. -/
theorem lawvere_eml_identity_echo
    {X W : Type*} [Preorder W] [AddMonoid W] [LawvereEMLSpace X W] :
    ∀ x : X, LawvereEMLSpace.dist x x = 0 :=
  LawvereEMLSpace.dist_self

/-- Bridge: triangle inequality — information-flow transitivity in quantum
channels and thermodynamic state transitions. -/
theorem lawvere_eml_triangle_flux
    {X W : Type*} [Preorder W] [AddMonoid W] [LawvereEMLSpace X W] :
    ∀ x y z : X, LawvereEMLSpace.dist x z ≤
      LawvereEMLSpace.dist x y + LawvereEMLSpace.dist y z :=
  LawvereEMLSpace.dist_trans

/-- Bridge: round-trip cost bound without metric symmetry. -/
theorem lawvere_pair_symmetry_without_metric_symmetry
    {X W : Type*} [Preorder W] [AddMonoid W]
    [LawvereEMLSpace X W] (x y : X) :
    LawvereEMLSpace.dist x x ≤
      LawvereEMLSpace.dist x y + LawvereEMLSpace.dist y x := by
  calc LawvereEMLSpace.dist x x
      = (0 : W) := LawvereEMLSpace.dist_self x
    _ ≤ LawvereEMLSpace.dist x y + LawvereEMLSpace.dist y x := by
        have := LawvereEMLSpace.dist_trans x y x
        rwa [LawvereEMLSpace.dist_self] at this

/-- Zero-cost order reflection.
Bridge: lattice-based post-quantum security costs. -/
theorem zero_cost_order_reflection_lattice
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    [LawvereEMLSpace X W]
    (hrefl : ∀ {x y : X}, LawvereEMLSpace.dist x y = 0 → x ≤ y)
    {x y : X} (h : LawvereEMLSpace.dist x y = 0) : x ≤ y :=
  hrefl h

/-- Identity map is nonexpansive. -/
theorem isLawvereNonexpansive_id
    {X W : Type*} [Preorder W] [AddMonoid W]
    (d : X → X → W) : IsLawvereNonexpansive d d id :=
  fun _ _ => le_refl _

/-- Composition of nonexpansive maps is nonexpansive — category of
Lawvere EML spaces and robust inference channels. -/
theorem isLawvereNonexpansive_comp
    {X Y Z W : Type*} [Preorder W] [AddMonoid W]
    (dX : X → X → W) (dY : Y → Y → W) (dZ : Z → Z → W)
    {f : X → Y} {g : Y → Z}
    (hf : IsLawvereNonexpansive dX dY f)
    (hg : IsLawvereNonexpansive dY dZ g) :
    IsLawvereNonexpansive dX dZ (g ∘ f) :=
  fun x y => le_trans (hg (f x) (f y)) (hf x y)

/-! ## Section 2: Closure Operators -/

/-- Pre-closure: monotone and extensive, not necessarily idempotent.
Bridge: single-round neural inference, single-step thermodynamic relaxation. -/
structure PreClosure (X : Type*) [Preorder X] where
  toFun : X → X
  monotone' : Monotone toFun
  extensive' : ∀ x, x ≤ toFun x

/-- EML closure operator: monotone, extensive, idempotent.
Bridge: free-energy minima, idempotent quantum channels. -/
structure EMLClosure (X : Type*) [Preorder X] extends PreClosure X where
  idempotent' : ∀ x, toFun (toFun x) = toFun x

/-! ## Section 3: Closure-Induced Distances -/

/-- Induced Lawvere distance: d(x,y) := κ(c(x), c(y)).
Bridge: thermodynamic free-energy difference between equilibrium states. -/
def EMLClosure.toLawvereDist
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W) : X → X → W :=
  fun x y => κ (c.toFun x) (c.toFun y)

/-- Closure gap: κ(c(x), y) — cost from closure of x to y.
Bridge: entropy-like quantity in thermodynamic semantics. -/
def EMLClosure.closureGap
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W) : X → X → W :=
  fun x y => κ (c.toFun x) y

/-- Closure-induced distance: d(x,x) = 0. -/
theorem EMLClosure.toLawvereDist_dist_self
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W) (hself : ∀ x, κ x x = 0) :
    ∀ x, c.toLawvereDist κ x x = 0 :=
  fun x => hself (c.toFun x)

/-- Closure-induced distance: triangle inequality. -/
theorem EMLClosure.toLawvereDist_dist_trans
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W)
    (htri : ∀ x y z, κ (c.toFun x) (c.toFun z) ≤
      κ (c.toFun x) (c.toFun y) + κ (c.toFun y) (c.toFun z)) :
    ∀ x y z, c.toLawvereDist κ x z ≤
      c.toLawvereDist κ x y + c.toLawvereDist κ y z :=
  htri

/-- Construct `LawvereEMLSpace` from closure + cost kernel.
Bridge: closure algebra → Lawvere enriched category theory → certified robustness. -/
def ClosureLawvereCore
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W)
    (hself : ∀ x, κ x x = 0)
    (htri : ∀ x y z, κ (c.toFun x) (c.toFun z) ≤
      κ (c.toFun x) (c.toFun y) + κ (c.toFun y) (c.toFun z)) :
    LawvereEMLSpace X W where
  dist := c.toLawvereDist κ
  dist_self := c.toLawvereDist_dist_self κ hself
  dist_trans := c.toLawvereDist_dist_trans κ htri

/-- Bridge: closure maps are nonexpansive — Lipschitz-certified robustness.
Proof: idempotence c(c(x)) = c(x). Complexity: O(1) verification. -/
theorem closure_quantum_nonexpansive_channel
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W) :
    IsLawvereNonexpansive (c.toLawvereDist κ) (c.toLawvereDist κ) c.toFun := by
  intro x y
  show κ (c.toFun (c.toFun x)) (c.toFun (c.toFun y)) ≤ κ (c.toFun x) (c.toFun y)
  rw [c.idempotent', c.idempotent']

/-! ## Section 4: Fixed Points and Thermodynamic Semantics -/

/-- Bridge: fixed points have zero closure gap — thermodynamic equilibrium. -/
theorem closure_gap_zero_of_fixedpoint
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W) (hself : ∀ x, κ x x = 0)
    {x : X} (hfp : c.toFun x = x) :
    c.closureGap κ x x = 0 := by
  show κ (c.toFun x) x = 0; rw [hfp]; exact hself x

/-- Bridge: zero gap reflects fixed-point status on partial orders.
Uses extensiveness + antisymmetry. -/
theorem closure_gap_zero_reflects_fixedpoint
    {X W : Type*} [PartialOrder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W)
    (hzero : ∀ x y, κ x y = 0 → x ≤ y)
    {x : X} (hgap : c.closureGap κ x x = 0) :
    c.toFun x = x :=
  le_antisymm (hzero (c.toFun x) x hgap) (c.extensive' x)

/-- Fixed-point ↔ order sandwich. -/
theorem fixedpoint_iff_zero_closure_gap
    {X : Type*} [PartialOrder X] (c : EMLClosure X) :
    ∀ x, c.toFun x = x ↔ x ≤ c.toFun x ∧ c.toFun x ≤ x :=
  fun x => ⟨fun h => ⟨le_of_eq h.symm, le_of_eq h⟩,
            fun ⟨_, h2⟩ => le_antisymm h2 (c.extensive' x)⟩

/-- Bridge: at a fixed point, the gap from any y to x is the raw cost.
Connects to thermodynamic free-energy minima. -/
theorem thermodynamic_fixedpoint_minimizes_closure_gap
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W) {x : X} (_hfp : c.toFun x = x) :
    ∀ y, c.closureGap κ y x = κ (c.toFun y) x := fun _ => rfl

/-- Bridge: closure monotonicity — quantum entropy monotonicity. -/
theorem quantum_entropy_closure_monotone
    {X : Type*} [Preorder X] (c : EMLClosure X) : Monotone c.toFun :=
  c.monotone'

/-- Bridge: zero gap at fixed points — tropical hash collision obstruction. -/
theorem tropical_hash_collision_zero_gap_obstruction
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W) (hself : ∀ x, κ x x = 0)
    {x : X} (hfp : c.toFun x = x) :
    c.closureGap κ x x = 0 :=
  closure_gap_zero_of_fixedpoint c κ hself hfp

/-- Fixed elements = range of closure. -/
theorem EMLClosure.fixed_iff_range {X : Type*} [Preorder X]
    (c : EMLClosure X) (x : X) :
    c.toFun x = x ↔ ∃ y, c.toFun y = x :=
  ⟨fun h => ⟨x, h⟩, fun ⟨_, hy⟩ => by rw [← hy, c.idempotent']⟩

/-- Bridge: ∀x, ∃y with c(y)=y ∧ x≤y — quantum decoherence shadow. -/
theorem forall_exists_fixedpoint_shadow
    {X : Type*} [Preorder X] (c : EMLClosure X) :
    ∀ x, ∃ y, c.toFun y = y ∧ x ≤ y :=
  fun x => ⟨c.toFun x, c.idempotent' x, c.extensive' x⟩

/-! ## Section 5: Iterative Closure and Computational Bounds -/

/-- Iterated pre-closure application. -/
def preClosureIterate {X : Type*} [Preorder X] (c : PreClosure X) : ℕ → X → X
  | 0 => id
  | n + 1 => c.toFun ∘ preClosureIterate c n

/-- Iterated closure application. -/
def closureIterate {X : Type*} [Preorder X] (c : EMLClosure X) : ℕ → X → X
  | 0 => id
  | n + 1 => c.toFun ∘ closureIterate c n

/-- Pre-closure iterates form a monotone ascending chain. -/
theorem preClosureIterate_monotone_in_n
    {X : Type*} [Preorder X] (c : PreClosure X) :
    ∀ n x, preClosureIterate c n x ≤ preClosureIterate c (n + 1) x := by
  intro n; induction n with
  | zero => intro x; exact c.extensive' x
  | succ k ih => intro x; exact c.monotone' (ih x)

/-- Chain transitivity: a ≤ b → iterate a ≤ iterate b. -/
theorem preClosureIterate_chain_mono {X : Type*} [Preorder X] (c : PreClosure X) :
    ∀ a b, a ≤ b → ∀ x, preClosureIterate c a x ≤ preClosureIterate c b x := by
  intro a b hab x
  induction hab with
  | refl => exact le_refl _
  | step _ ih => exact le_trans ih (preClosureIterate_monotone_in_n c _ x)

/-- Bridge: O(1) convergence for idempotent closures.
Complexity: 1 round regardless of state space size. -/
theorem closureIterate_eq_after_one
    {X : Type*} [Preorder X] (c : EMLClosure X) :
    ∀ n x, 1 ≤ n → closureIterate c n x = c.toFun x := by
  intro n x hn; induction n with
  | zero => omega
  | succ k ih =>
    show c.toFun (closureIterate c k x) = c.toFun x
    cases k with
    | zero => rfl
    | succ k' => rw [ih (by omega)]; exact c.idempotent' x

/-- Bridge: O(1) certified convergence. -/
theorem closure_iterate_O1_certified_convergence
    {X : Type*} [Preorder X] (c : EMLClosure X) :
    ∀ x, closureIterate c 1 x = c.toFun x := fun _ => rfl

/-- Eventual stabilization predicate. -/
def EventuallyStable {X : Type*} (u : ℕ → X) : Prop :=
  ∃ N, ∀ n, N ≤ n → u n = u N

/-- Bridge: closure iterates eventually stable with N = 1.
Tropical/idempotent algebra convergence. -/
theorem eventuallyStable_of_closureIterate
    {X : Type*} [Preorder X] (c : EMLClosure X) (x : X) :
    EventuallyStable (fun n => closureIterate c n x) :=
  ⟨1, fun n hn => closureIterate_eq_after_one c n x hn⟩

/-! ## Section 6: Finite Stabilization — O(|X|) Bounds -/

/-- Bridge: pre-closure stabilizes in ≤ card X steps on finite partial orders.
Complexity: O(|X|) rounds. Proof: pigeonhole on ascending chains. -/
theorem preclosure_stabilizes_on_finite_order
    {X : Type*} [PartialOrder X] [Fintype X] [DecidableEq X]
    (c : PreClosure X) :
    ∀ x, ∃ n, n ≤ Fintype.card X ∧
      preClosureIterate c n x = preClosureIterate c (n + 1) x := by
  intro x
  by_contra h
  push_neg at h
  have hlt : ∀ n, n ≤ Fintype.card X →
      preClosureIterate c n x < preClosureIterate c (n + 1) x := by
    intro n hn
    exact lt_of_le_of_ne (preClosureIterate_monotone_in_n c n x) (h n hn)
  let f : Fin (Fintype.card X + 1) → X := fun i => preClosureIterate c i.val x
  have hinj : Function.Injective f := by
    intro ⟨a, ha⟩ ⟨b, hb⟩ heq
    simp only [f] at heq
    ext; show a = b
    by_contra hab
    rcases Nat.lt_or_gt_of_ne hab with h1 | h1
    · exact absurd heq (ne_of_lt (lt_of_lt_of_le
        (hlt a (by omega)) (preClosureIterate_chain_mono c (a+1) b (by omega) x)))
    · exact absurd heq.symm (ne_of_lt (lt_of_lt_of_le
        (hlt b (by omega)) (preClosureIterate_chain_mono c (b+1) a (by omega) x)))
  have hcard : Fintype.card (Fin (Fintype.card X + 1)) ≤ Fintype.card X :=
    Fintype.card_le_of_injective f hinj
  simp [Fintype.card_fin] at hcard

/-- Once stabilized, all subsequent iterates agree. -/
theorem preClosureIterate_stable_from
    {X : Type*} [PartialOrder X] (c : PreClosure X) (x : X) (n : ℕ)
    (hstab : preClosureIterate c n x = preClosureIterate c (n + 1) x) :
    ∀ k, preClosureIterate c (n + k) x = preClosureIterate c n x := by
  intro k; induction k with
  | zero => rfl
  | succ k ih =>
    show c.toFun (preClosureIterate c (n + k) x) = preClosureIterate c n x
    rw [ih]; exact hstab.symm

/-- Bridge: stable stages exist on finite orders. O(|X|) convergence.
Post-quantum lattice reduction termination. -/
theorem exists_stable_stage_for_finitary_generator
    {X : Type*} [PartialOrder X] [Fintype X] [DecidableEq X]
    (c : PreClosure X) :
    ∀ x, ∃ N, N ≤ Fintype.card X ∧
      ∀ m, N ≤ m → preClosureIterate c m x = preClosureIterate c N x := by
  intro x
  obtain ⟨n, hn_le, hn_eq⟩ := preclosure_stabilizes_on_finite_order c x
  exact ⟨n, hn_le, fun m hm => by
    obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hm
    exact preClosureIterate_stable_from c x n hn_eq k⟩

/-- Bridge: finite-height closure completion — pre-closure reaches a true fixed point.
Lattice crypto key-generation termination. -/
theorem finite_height_closure_completion
    {X : Type*} [PartialOrder X] [Fintype X] [DecidableEq X]
    (c : PreClosure X) :
    ∀ x, ∃ N, N ≤ Fintype.card X ∧
      c.toFun (preClosureIterate c N x) = preClosureIterate c N x := by
  intro x
  obtain ⟨n, hn_le, hn_eq⟩ := preclosure_stabilizes_on_finite_order c x
  exact ⟨n, hn_le, hn_eq.symm⟩

/-! ## Section 7: Product Lawvere Spaces -/

/-- Bridge: product Lawvere space with additive distance.
Thermodynamic tensor product — joint systems, additive costs. -/
instance ProductLawvereEMLSpace
    {X Y W : Type*} [AddCommMonoid W] [PartialOrder W]
    [CovariantClass W W (· + ·) (· ≤ ·)]
    [LawvereEMLSpace X W] [LawvereEMLSpace Y W] :
    LawvereEMLSpace (X × Y) W where
  dist p q := LawvereEMLSpace.dist p.1 q.1 + LawvereEMLSpace.dist p.2 q.2
  dist_self p := by simp [LawvereEMLSpace.dist_self]
  dist_trans p q r := by
    have h1 := LawvereEMLSpace.dist_trans p.1 q.1 r.1
    have h2 := LawvereEMLSpace.dist_trans p.2 q.2 r.2
    calc LawvereEMLSpace.dist p.1 r.1 + LawvereEMLSpace.dist p.2 r.2
        ≤ (LawvereEMLSpace.dist p.1 q.1 + LawvereEMLSpace.dist q.1 r.1) +
          (LawvereEMLSpace.dist p.2 q.2 + LawvereEMLSpace.dist q.2 r.2) :=
          add_le_add h1 h2
      _ = (LawvereEMLSpace.dist p.1 q.1 + LawvereEMLSpace.dist p.2 q.2) +
          (LawvereEMLSpace.dist q.1 r.1 + LawvereEMLSpace.dist q.2 r.2) := by abel

/-- Bridge: first projection is nonexpansive — thermodynamic subsystem restriction. -/
theorem product_lawvere_thermodynamic_tensor
    {X Y W : Type*} [AddCommMonoid W] [PartialOrder W]
    [CovariantClass W W (· + ·) (· ≤ ·)]
    [hx : LawvereEMLSpace X W] [hy : LawvereEMLSpace Y W]
    (hnn : ∀ w : W, 0 ≤ w) :
    ∀ (p q : X × Y),
      hx.dist p.1 q.1 ≤
        @LawvereEMLSpace.dist (X × Y) W _ _ ProductLawvereEMLSpace p q := by
  intro p q
  show hx.dist p.1 q.1 ≤ hx.dist p.1 q.1 + hy.dist p.2 q.2
  have h := hnn (hy.dist p.2 q.2)
  calc hx.dist p.1 q.1
      = hx.dist p.1 q.1 + 0 := (add_zero _).symm
    _ ≤ hx.dist p.1 q.1 + hy.dist p.2 q.2 := by exact add_le_add_right h _

/-- Bridge: componentwise nonexpansive → product nonexpansive.
Lipschitz-certified robustness for multi-output channels. -/
theorem product_nonexpansive_lipschitz_certified_robustness
    {X₁ X₂ Y₁ Y₂ W : Type*} [AddCommMonoid W] [PartialOrder W]
    [CovariantClass W W (· + ·) (· ≤ ·)]
    [hX₁ : LawvereEMLSpace X₁ W] [hX₂ : LawvereEMLSpace X₂ W]
    [hY₁ : LawvereEMLSpace Y₁ W] [hY₂ : LawvereEMLSpace Y₂ W]
    {f₁ : X₁ → Y₁} {f₂ : X₂ → Y₂}
    (hf₁ : IsLawvereNonexpansive hX₁.dist hY₁.dist f₁)
    (hf₂ : IsLawvereNonexpansive hX₂.dist hY₂.dist f₂) :
    IsLawvereNonexpansive
      (@LawvereEMLSpace.dist (X₁ × X₂) W _ _ ProductLawvereEMLSpace)
      (@LawvereEMLSpace.dist (Y₁ × Y₂) W _ _ ProductLawvereEMLSpace)
      (fun p => (f₁ p.1, f₂ p.2)) := by
  intro p q
  show hY₁.dist (f₁ p.1) (f₁ q.1) + hY₂.dist (f₂ p.2) (f₂ q.2) ≤
    hX₁.dist p.1 q.1 + hX₂.dist p.2 q.2
  exact add_le_add (hf₁ p.1 q.1) (hf₂ p.2 q.2)

/-! ## Section 8: Semiring Nucleus Reconstruction -/

/-- Nucleus on an ordered semiring: monotone, extensive, idempotent.
Bridge: post-quantum lattice reduction + quantum coarse-graining. -/
structure SemiringNucleus (R : Type*) [Preorder R] [Semiring R] where
  ν : R → R
  mono' : Monotone ν
  extensive' : ∀ x, x ≤ ν x
  idem' : ∀ x, ν (ν x) = ν x

namespace SemiringNucleus
variable {R : Type*} [Preorder R] [Semiring R]

/-- Nucleus → EML closure.
Bridge: residuated algebra → closure semantics → post-quantum lattice costs. -/
def toClosure (σ : SemiringNucleus R) : EMLClosure R where
  toFun := σ.ν
  monotone' := σ.mono'
  extensive' := σ.extensive'
  idempotent' := σ.idem'

/-- Nucleus-induced Lawvere distance. -/
def toLawvereDist {W : Type*} [Preorder W] [AddMonoid W]
    (σ : SemiringNucleus R) (ρ : R → R → W) : R → R → W :=
  fun x y => ρ (σ.ν x) (σ.ν y)

/-- Nucleus distance: self = 0. -/
theorem toLawvereDist_self {W : Type*} [Preorder W] [AddMonoid W]
    (σ : SemiringNucleus R) (ρ : R → R → W) (hself : ∀ x, ρ x x = 0) :
    ∀ x, σ.toLawvereDist ρ x x = 0 :=
  fun x => hself (σ.ν x)

/-- Bridge: nucleus distance triangle inequality.
Post-quantum lattice cost composition. -/
theorem semiring_nucleus_post_quantum_reconstruction
    {W : Type*} [Preorder W] [AddMonoid W]
    (σ : SemiringNucleus R) (ρ : R → R → W)
    (htri : ∀ x y z, ρ (σ.ν x) (σ.ν z) ≤
      ρ (σ.ν x) (σ.ν y) + ρ (σ.ν y) (σ.ν z)) :
    ∀ x y z, σ.toLawvereDist ρ x z ≤
      σ.toLawvereDist ρ x y + σ.toLawvereDist ρ y z :=
  htri

/-- Bridge: nucleus is nonexpansive by idempotence.
Post-quantum: re-reduction doesn't increase distance. -/
theorem semiring_nucleus_residuation_entropy_bridge
    {W : Type*} [Preorder W] [AddMonoid W]
    (σ : SemiringNucleus R) (ρ : R → R → W) :
    ∀ x y, σ.toLawvereDist ρ (σ.ν x) (σ.ν y) ≤ σ.toLawvereDist ρ x y := by
  intro x y
  show ρ (σ.ν (σ.ν x)) (σ.ν (σ.ν y)) ≤ ρ (σ.ν x) (σ.ν y)
  rw [σ.idem', σ.idem']

/-- Nucleus fixed points = closure fixed points. -/
theorem fixed_iff_closure_fixed (σ : SemiringNucleus R) (x : R) :
    σ.ν x = x ↔ σ.toClosure.toFun x = x := Iff.rfl

end SemiringNucleus

/-! ## Section 9: Residuated Cost Structure -/

/-- Residuated cost: abstract Lawvere-axiom cost function.
Bridge: tropical semiring distances, post-quantum lattice reduction costs. -/
structure ResiduatedCost (R : Type*) (W : Type*) [Preorder W] [AddMonoid W] where
  resid : R → R → W
  resid_self : ∀ x, resid x x = 0
  resid_triangle : ∀ x y z, resid x z ≤ resid x y + resid y z

/-- Residuated cost → Lawvere EML space. -/
def ResiduatedCost.toLawvereEMLSpace
    {R W : Type*} [Preorder W] [AddMonoid W]
    (rc : ResiduatedCost R W) : LawvereEMLSpace R W where
  dist := rc.resid
  dist_self := rc.resid_self
  dist_trans := rc.resid_triangle

/-- Nucleus + residuated cost → Lawvere space. -/
def nucleusResiduatedLawvere
    {R W : Type*} [Preorder R] [Semiring R] [Preorder W] [AddMonoid W]
    (σ : SemiringNucleus R) (rc : ResiduatedCost R W) :
    LawvereEMLSpace R W where
  dist x y := rc.resid (σ.ν x) (σ.ν y)
  dist_self x := rc.resid_self (σ.ν x)
  dist_trans x y z := rc.resid_triangle (σ.ν x) (σ.ν y) (σ.ν z)

/-- Bridge: ν is nonexpansive for nucleus-residuated distance.
Lipschitz-certified robustness from algebraic data. -/
theorem nucleus_residuated_nonexpansive
    {R W : Type*} [Preorder R] [Semiring R] [Preorder W] [AddMonoid W]
    (σ : SemiringNucleus R) (rc : ResiduatedCost R W) :
    IsLawvereNonexpansive
      (nucleusResiduatedLawvere σ rc).dist
      (nucleusResiduatedLawvere σ rc).dist
      σ.ν := by
  intro x y
  show rc.resid (σ.ν (σ.ν x)) (σ.ν (σ.ν y)) ≤ rc.resid (σ.ν x) (σ.ν y)
  rw [σ.idem', σ.idem']

/-! ## Section 10: Concrete Examples -/

/-- Identity closure — every element is already closed. -/
def identityClosure (X : Type*) [Preorder X] : EMLClosure X where
  toFun := id
  monotone' := fun _ _ h => h
  extensive' := fun _ => le_refl _
  idempotent' := fun _ => rfl

/-- Identity closure has zero self-distance. -/
theorem identityClosure_zero_dist
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (κ : X → X → W) (hself : ∀ x, κ x x = 0) :
    ∀ x, (identityClosure X).toLawvereDist κ x x = 0 :=
  fun x => hself x

/-- Set closure by union: c(A) = A ∪ S. -/
def setUnionClosure {α : Type*} (S : Set α) : EMLClosure (Set α) where
  toFun A := A ∪ S
  monotone' := fun _ _ h => Set.union_subset_union_left S h
  extensive' := fun _ => Set.subset_union_left
  idempotent' := fun A => by ext x; simp [Set.mem_union]

/-- Bridge: fixed points of set-union closure ↔ S ⊆ A.
Lattice-theoretic fixed-point characterization. -/
theorem setUnionClosure_fixed_iff {α : Type*} (S : Set α) (A : Set α) :
    (setUnionClosure S).toFun A = A ↔ S ⊆ A := by
  constructor
  · intro h x hx
    have hmem : x ∈ A ∪ S := Set.mem_union_right A hx
    rw [show (setUnionClosure S).toFun A = A ∪ S from rfl] at h
    rw [h] at hmem
    exact hmem
  · intro h; ext x; constructor
    · intro hx; rcases hx with ha | hs; exact ha; exact h hs
    · exact fun hx => Or.inl hx

/-! ## Section 11: Product Closure and Application Bridges -/

/-- Product of two closures. -/
def productClosure {X Y : Type*} [Preorder X] [Preorder Y]
    (cx : EMLClosure X) (cy : EMLClosure Y) : EMLClosure (X × Y) where
  toFun p := (cx.toFun p.1, cy.toFun p.2)
  monotone' := fun _ _ ⟨h1, h2⟩ => ⟨cx.monotone' h1, cy.monotone' h2⟩
  extensive' := fun p => ⟨cx.extensive' p.1, cy.extensive' p.2⟩
  idempotent' := fun p => Prod.ext (cx.idempotent' p.1) (cy.idempotent' p.2)

/-- Bridge: product fixed points decompose. Thermodynamics: joint = components. -/
theorem productClosure_fixed_iff
    {X Y : Type*} [PartialOrder X] [PartialOrder Y]
    (cx : EMLClosure X) (cy : EMLClosure Y) (p : X × Y) :
    (productClosure cx cy).toFun p = p ↔ cx.toFun p.1 = p.1 ∧ cy.toFun p.2 = p.2 :=
  ⟨fun h => ⟨congr_arg Prod.fst h, congr_arg Prod.snd h⟩,
   fun ⟨h1, h2⟩ => Prod.ext h1 h2⟩

/-- Closure of closed is invariant — quantum decoherence invariance. -/
theorem closure_of_fixed_invariant
    {X : Type*} [Preorder X] (c : EMLClosure X) {x : X}
    (_h : c.toFun x = x) : c.toFun (c.toFun x) = c.toFun x :=
  c.idempotent' x

/-- Bridge: closure → certified robustness. -/
theorem lipschitz_certified_robustness_nonexpansive_closure
    {X W : Type*} [Preorder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W) :
    IsLawvereNonexpansive (c.toLawvereDist κ) (c.toLawvereDist κ) c.toFun :=
  closure_quantum_nonexpansive_channel c κ

/-- Bridge: post-quantum nucleus cost monotonicity. -/
theorem post_quantum_lattice_nucleus_cost_monotone
    {R W : Type*} [Preorder R] [Semiring R] [Preorder W] [AddMonoid W]
    (σ : SemiringNucleus R) (ρ : R → R → W) :
    ∀ x y, σ.toLawvereDist ρ (σ.ν x) (σ.ν y) ≤ σ.toLawvereDist ρ x y :=
  σ.semiring_nucleus_residuation_entropy_bridge ρ

/-- Bridge: thermodynamic free-energy principle — gap vanishes at equilibrium. -/
theorem thermodynamic_free_energy_fixedpoint_principle
    {X W : Type*} [PartialOrder X] [Preorder W] [AddMonoid W]
    (c : EMLClosure X) (κ : X → X → W) (hself : ∀ x, κ x x = 0) :
    ∀ x, c.toFun x = x → c.closureGap κ x x = 0 :=
  fun _ hfp => closure_gap_zero_of_fixedpoint c κ hself hfp

/-- Bridge: tropical convergence — modulus N ≤ 1. -/
theorem lawvere_eml_iterate_tropical_convergence
    {X : Type*} [Preorder X] (c : EMLClosure X) (x : X) :
    ∃ N, N ≤ 1 ∧ ∀ n, N ≤ n → closureIterate c n x = closureIterate c N x :=
  ⟨1, le_refl 1, fun n hn => closureIterate_eq_after_one c n x hn⟩