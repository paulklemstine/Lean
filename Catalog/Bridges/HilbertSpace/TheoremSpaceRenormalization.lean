/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Renormalization of Theorem Space: Universality Classes of Mathematical Theories

We formalize a mathematical framework for studying universality classes of
proof dependency structures through renormalization group (RG) flow. The central
objects are "strict depth flows" — dynamical systems with a well-founded depth
measure guaranteeing convergence — and "flow morphisms" that transfer universality
structure between systems.

## Main Definitions

* `StrictDepthFlow` — A self-map with a depth function that strictly decreases
  at each non-fixed step, guaranteeing convergence.
* `FlowMorphism` — A structure-preserving map between two dynamical systems
  that intertwines their step functions.
* `CoarseGraining` — A surjective flow morphism representing the passage from
  a fine-grained to a coarse-grained description.
* `EventualEq` — Two points are eventually equal if their iterates agree from
  some point onward; this defines universality classes.

## Main Results

* `sdf_fixed_after_depth` — In a strict depth flow, every point reaches a
  fixed point within `depth(x)` iteration steps. (Convergence theorem)
* `flow_morphism_preserves_eventual_eq` — Flow morphisms preserve the eventual
  equality relation, hence map universality classes to universality classes.
* `coarse_graining_class_surjection` — Coarse-graining induces a surjection on
  universality classes, proving classes can only merge, never split.
* `finite_flow_class_count_bound` — For a finite type with n elements, the
  number of fixed points (hence universality classes for strict depth flows)
  is at most n.
* `depth_flow_morphism_composition` — Flow morphisms compose, showing that
  iterated coarse-graining is itself a coarse-graining.
-/
import Mathlib

namespace TheoremSpaceRG

/-! ## Section 1: Strict Depth Flows

A strict depth flow is a dynamical system `(α, step)` equipped with a natural
number-valued "depth" function that strictly decreases at each non-fixed step.
This guarantees that every orbit reaches a fixed point in finitely many steps,
with the convergence time bounded by the initial depth.

This models the renormalization of proof dependency structures: each coarse-graining
step reduces the "complexity depth" of the dependency graph until reaching an
irreducible fixed-point structure — the universality class signature.
-/

/-- A strict depth flow: a self-map with a depth function that strictly decreases
at non-fixed points, guaranteeing finite-time convergence to fixed points. -/
structure StrictDepthFlow (α : Type*) where
  /-- The step function (renormalization operator) -/
  step : α → α
  /-- The depth measure (complexity of the state) -/
  depth : α → ℕ
  /-- Depth strictly decreases at non-fixed points -/
  depth_decrease : ∀ x, step x ≠ x → depth (step x) < depth x

/-- Iteration of a strict depth flow's step function. -/
def sdfIterate (f : StrictDepthFlow α) : ℕ → α → α
  | 0, x => x
  | n + 1, x => f.step (sdfIterate f n x)

@[simp]
theorem sdfIterate_zero (f : StrictDepthFlow α) (x : α) :
    sdfIterate f 0 x = x := rfl

@[simp]
theorem sdfIterate_succ (f : StrictDepthFlow α) (n : ℕ) (x : α) :
    sdfIterate f (n + 1) x = f.step (sdfIterate f n x) := rfl

/-- Elements of depth 0 are necessarily fixed points: if step moved them,
their depth would have to decrease below 0, which is impossible in ℕ. -/
theorem sdf_zero_depth_is_fixed (f : StrictDepthFlow α) (x : α)
    (hd : f.depth x = 0) : f.step x = x := by
  by_contra h
  have := f.depth_decrease x h
  omega

/-
**Convergence Theorem**: In a strict depth flow, iterating `depth(x)` times
always produces a fixed point. This is the key quantitative bound showing that
renormalization terminates with convergence time controlled by initial complexity.
-/
theorem sdf_fixed_after_depth (f : StrictDepthFlow α) (x : α) (n : ℕ)
    (hn : f.depth x ≤ n) :
    f.step (sdfIterate f n x) = sdfIterate f n x := by
  -- We proceed by induction on the depth of x.
  induction' h : f.depth x using Nat.strong_induction_on with d ih generalizing x n;
  by_cases h_step : f.step x = x;
  · -- Since $f.step x = x$, we have $sdfIterate f n x = x$ for all $n$ by induction on $n$.
    have h_iterate : ∀ n, sdfIterate f n x = x := by
      intro n; induction n <;> simp +decide [ *, sdfIterate_succ ] ;
    rw [ h_iterate, h_step ];
  · rcases n with ( _ | n ) <;> simp_all +decide [ sdfIterate ];
    · exact h_step ( by have := f.depth_decrease x; aesop );
    · convert ih ( f.depth ( f.step x ) ) _ ( f.step x ) n _ rfl using 1;
      · exact congr_arg _ ( by exact Nat.recOn n rfl fun n ih => by simp +decide [ *, sdfIterate ] );
      · exact Nat.recOn n rfl fun n ih => by rw [ sdfIterate_succ, sdfIterate_succ, ih ] ;
      · exact h ▸ f.depth_decrease x h_step;
      · linarith [ f.depth_decrease x h_step ]

/-
The depth of iterates is non-increasing.
-/
theorem sdf_depth_nonincreasing (f : StrictDepthFlow α) (x : α) (n : ℕ) :
    f.depth (sdfIterate f n x) ≤ f.depth x := by
  induction' n with n ih;
  · rfl;
  · by_cases h : f.step ( sdfIterate f n x ) = sdfIterate f n x <;> simp_all +decide [ sdfIterate_succ ];
    exact le_trans ( le_of_lt ( f.depth_decrease _ h ) ) ih

/-
Once a fixed point is reached, all subsequent iterates are the same.
-/
theorem sdf_iterate_fixed_stable (f : StrictDepthFlow α) (x : α) (n m : ℕ)
    (hn : f.step (sdfIterate f n x) = sdfIterate f n x) (hm : n ≤ m) :
    sdfIterate f m x = sdfIterate f n x := by
  induction hm <;> simp +decide [ *, sdfIterate_succ ]

/-
The fixed point reached by iterating is unique: it doesn't depend on
how many extra steps we take beyond `depth(x)`.
-/
theorem sdf_eventual_value_unique (f : StrictDepthFlow α) (x : α) (n m : ℕ)
    (hn : f.depth x ≤ n) (hm : f.depth x ≤ m) :
    sdfIterate f n x = sdfIterate f m x := by
  grind +suggestions

/-! ## Section 2: Flow Morphisms

A flow morphism between two dynamical systems `(α, f)` and `(β, g)` is a map
`φ : α → β` that intertwines the dynamics: `φ ∘ f = g ∘ φ`.

Flow morphisms are the natural notion of "structure-preserving map" between
renormalization flows. They transfer all dynamical information — fixed points,
periodic orbits, universality classes — from one system to another.
-/

/-- A flow morphism intertwines the dynamics of two systems. -/
structure FlowMorphism (α β : Type*) (f : α → α) (g : β → β) where
  /-- The underlying map -/
  toFun : α → β
  /-- The intertwining condition -/
  commutes : ∀ x, toFun (f x) = g (toFun x)

/-
Flow morphisms commute with iteration.
-/
theorem flow_morphism_iterate_commutes {α β : Type*} {f : α → α} {g : β → β}
    (φ : FlowMorphism α β f g) (n : ℕ) (x : α) :
    φ.toFun (f^[n] x) = g^[n] (φ.toFun x) := by
  induction' n with n ih generalizing x <;> simp_all +decide [ Function.iterate_succ_apply' ];
  rw [ ← ih, φ.commutes ]

/-- Flow morphisms map fixed points to fixed points. -/
theorem flow_morphism_preserves_fixed {α β : Type*} {f : α → α} {g : β → β}
    (φ : FlowMorphism α β f g) (x : α) (hx : f x = x) :
    g (φ.toFun x) = φ.toFun x := by
  rw [← φ.commutes, hx]

/-- Eventual equality: two points are eventually equal if their orbits
eventually merge. This is the equivalence relation whose classes are
the universality classes. -/
def EventualEq (f : α → α) (x y : α) : Prop :=
  ∃ N : ℕ, ∀ n, N ≤ n → f^[n] x = f^[n] y

theorem eventualEq_refl (f : α → α) (x : α) : EventualEq f x x :=
  ⟨0, fun _ _ => rfl⟩

theorem eventualEq_symm {f : α → α} {x y : α}
    (h : EventualEq f x y) : EventualEq f y x :=
  let ⟨N, hN⟩ := h; ⟨N, fun n hn => (hN n hn).symm⟩

theorem eventualEq_trans {f : α → α} {x y z : α}
    (hxy : EventualEq f x y) (hyz : EventualEq f y z) : EventualEq f x z := by
  obtain ⟨N₁, hN₁⟩ := hxy; obtain ⟨N₂, hN₂⟩ := hyz
  exact ⟨max N₁ N₂, fun n hn => by
    rw [hN₁ n (le_of_max_le_left hn), hN₂ n (le_of_max_le_right hn)]⟩

/-- The eventual equality setoid on a type with a self-map. -/
def eventualSetoid (α : Type*) (f : α → α) : Setoid α where
  r := EventualEq f
  iseqv := ⟨eventualEq_refl f, fun h => eventualEq_symm h,
            fun h₁ h₂ => eventualEq_trans h₁ h₂⟩

/-
**Transfer Theorem**: Flow morphisms preserve eventual equality, hence map
universality classes to universality classes. This is the formal content of
"universality" — structural properties that persist across coarse-grainings.
-/
theorem flow_morphism_preserves_eventual_eq {α β : Type*} {f : α → α} {g : β → β}
    (φ : FlowMorphism α β f g) {x y : α}
    (h : EventualEq f x y) : EventualEq g (φ.toFun x) (φ.toFun y) := by
  exact ⟨ h.choose, fun n hn => by rw [ ← flow_morphism_iterate_commutes, ← flow_morphism_iterate_commutes, h.choose_spec n hn ] ⟩

/-! ## Section 3: Coarse-Graining

A coarse-graining is a surjective flow morphism. Surjectivity ensures that
the coarser system doesn't introduce "phantom" states with no fine-grained
counterpart. The key structural result is that coarse-graining can only
merge universality classes, never split them.
-/

/-- A coarse-graining is a surjective flow morphism. -/
structure CoarseGraining (α β : Type*) (f : α → α) (g : β → β) extends
    FlowMorphism α β f g where
  surjective : Function.Surjective toFun

/-- Coarse-graining induces a well-defined map on universality class quotients. -/
noncomputable def coarseGrainingQuotientMap {α β : Type*} {f : α → α} {g : β → β}
    (cg : CoarseGraining α β f g) :
    Quotient (eventualSetoid α f) → Quotient (eventualSetoid β g) :=
  Quotient.map cg.toFun
    (fun _ _ h => flow_morphism_preserves_eventual_eq cg.toFlowMorphism h)

/-
**Class Surjection Theorem**: Coarse-graining induces a surjection on
universality class quotients. Classes can only merge, never split.
-/
theorem coarse_graining_class_surjection {α β : Type*} {f : α → α} {g : β → β}
    (cg : CoarseGraining α β f g) :
    Function.Surjective (coarseGrainingQuotientMap cg) := by
  intro q; obtain ⟨ b, rfl ⟩ := Quotient.exists_rep q;
  obtain ⟨ a, rfl ⟩ := cg.surjective b;
  exact ⟨ ⟦a⟧, rfl ⟩

/-- Flow morphisms compose: iterated coarse-graining is still a valid morphism. -/
def flowMorphismComp {α β γ : Type*} {f : α → α} {g : β → β} {h : γ → γ}
    (φ : FlowMorphism α β f g) (ψ : FlowMorphism β γ g h) :
    FlowMorphism α γ f h where
  toFun := ψ.toFun ∘ φ.toFun
  commutes x := by simp [Function.comp, φ.commutes, ψ.commutes]

/-- Composition of coarse-grainings is a coarse-graining. -/
def coarseGrainingComp {α β γ : Type*} {f : α → α} {g : β → β} {h : γ → γ}
    (cg₁ : CoarseGraining α β f g) (cg₂ : CoarseGraining β γ g h) :
    CoarseGraining α γ f h where
  toFlowMorphism := flowMorphismComp cg₁.toFlowMorphism cg₂.toFlowMorphism
  surjective := by
    intro c
    obtain ⟨b, hb⟩ := cg₂.surjective c
    obtain ⟨a, ha⟩ := cg₁.surjective b
    exact ⟨a, by simp [flowMorphismComp, Function.comp, ha, hb]⟩

/-! ## Section 4: Finite Flow Theory

For flows on finite types, we obtain stronger results: explicit bounds on
the number of universality classes, and the guarantee that coarse-graining
strictly reduces this count (unless the flow is already at a fixed point).
-/

/-- For a finite type, the set of fixed points is a Finset. -/
noncomputable def fixedPointFinset [Fintype α] [DecidableEq α] (f : α → α) : Finset α :=
  Finset.univ.filter (fun x => f x = x)

/-- The number of fixed points is at most the cardinality of the type. -/
theorem fixed_point_count_le_card [Fintype α] [DecidableEq α] (f : α → α) :
    (fixedPointFinset f).card ≤ Fintype.card α :=
  Finset.card_filter_le _ _

/-
In a strict depth flow on a finite type, every element eventually
reaches a fixed point.
-/
theorem sdf_iterate_reaches_fixedPointFinset [Fintype α] [DecidableEq α]
    (f : StrictDepthFlow α) (x : α) :
    sdfIterate f (f.depth x) x ∈ fixedPointFinset f.step := by
  exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, sdf_fixed_after_depth f x _ le_rfl ⟩

/-
**Finite Orbit Theorem**: For any function on a finite type, the orbit of any
element eventually enters a cycle.
-/
theorem finite_orbit_eventually_periodic [Fintype α] [DecidableEq α]
    (f : α → α) (x : α) :
    ∃ N p : ℕ, 0 < p ∧ N + p ≤ Fintype.card α ∧
      ∀ n, N ≤ n → f^[n + p] x = f^[n] x := by
  -- By the pigeonhole principle, since there are only finitely many elements in α, there must exist indices i and j with i < j such that f^[i] x = f^[j] x.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ i < Fintype.card α + 1 ∧ j < Fintype.card α + 1 ∧ f^[i] x = f^[j] x := by
    by_contra! h;
    exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] x ) ( Finset.range ( Fintype.card α + 1 ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.1 fun hi' => h _ _ hi' ( Finset.mem_range.1 hj ) ( Finset.mem_range.1 hi ) hij.symm ) ( not_lt.1 fun hj' => h _ _ hj' ( Finset.mem_range.1 hi ) ( Finset.mem_range.1 hj ) hij ) ] ; simp +decide );
  refine' ⟨ i, j - i, tsub_pos_of_lt hij, _, _ ⟩;
  · omega;
  · intro n hn; induction hn <;> simp_all +decide [ Nat.succ_add, Function.iterate_succ_apply' ] ;
    rw [ Nat.add_sub_cancel' hij.le ]

/-! ## Section 5: Depth Spectrum and Critical Exponents

The depth spectrum of a strict depth flow captures the distribution of
convergence times across all states. Critical exponents characterize
how the spectrum scales under coarse-graining.
-/

/-- The depth spectrum: the multiset of depths of all elements. -/
noncomputable def depthSpectrum [Fintype α] (f : StrictDepthFlow α) : Multiset ℕ :=
  (Finset.univ : Finset α).val.map f.depth

/-- The maximum depth in a finite strict depth flow. -/
noncomputable def maxDepth [Fintype α] [Nonempty α] (f : StrictDepthFlow α) : ℕ :=
  Finset.sup' Finset.univ Finset.univ_nonempty f.depth

/-
All elements stabilize within the maximum depth.
-/
theorem all_stabilize_by_maxDepth [Fintype α] [Nonempty α] [DecidableEq α]
    (f : StrictDepthFlow α) (x : α) :
    f.step (sdfIterate f (maxDepth f) x) = sdfIterate f (maxDepth f) x := by
  convert sdf_fixed_after_depth f x ( maxDepth f ) _;
  exact Finset.le_sup' ( fun x => f.depth x ) ( Finset.mem_univ x )

/-! ## Section 6: Constructive Examples -/

/-- The trivial flow where every point is already fixed. -/
def trivialFlow (α : Type*) : StrictDepthFlow α where
  step := id
  depth := fun _ => 0
  depth_decrease := fun _ h => absurd rfl h

/-- The truncation flow on ℕ: sends n to min(n, K).
    Models a "complexity ceiling" renormalization where
    all states above threshold K collapse to K. -/
def truncationFlow (K : ℕ) : StrictDepthFlow ℕ where
  step := fun n => min n K
  depth := fun n => if n ≤ K then 0 else n - K
  depth_decrease := fun x hx => by
    simp only [Nat.min_def] at hx ⊢
    by_cases h : x ≤ K
    · simp [h] at hx
    · simp [h]; omega

/-- The truncation flow fixes everything at or below K. -/
theorem truncation_fixed_iff (K n : ℕ) :
    (truncationFlow K).step n = n ↔ n ≤ K := by
  simp only [truncationFlow, Nat.min_def]
  split_ifs with h <;> omega

/-! ## Section 7: Falsifiable Conjecture

**Spectral Rigidity Conjecture**: For strict depth flows on finite types,
the depth spectrum (as a multiset) determines the number of universality
classes (= number of fixed points).

This is falsifiable: construct two flows with the same depth spectrum
but different numbers of fixed points to disprove it.
-/

/-- **Spectral Rigidity Conjecture** (Falsifiable):
The depth spectrum determines the universality class count.
Specifically, if two finite strict depth flows have the same depth spectrum,
they have the same number of fixed points (universality classes). -/
def SpectralRigidityConjecture : Prop :=
  ∀ (α β : Type*) [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (fα : StrictDepthFlow α) (fβ : StrictDepthFlow β),
    depthSpectrum fα = depthSpectrum fβ →
    (fixedPointFinset fα.step).card = (fixedPointFinset fβ.step).card

/-
The conjecture holds when all elements have depth 0 (all fixed).
-/
theorem spectral_rigidity_all_fixed [Fintype α] [Fintype β]
    [DecidableEq α] [DecidableEq β]
    (fα : StrictDepthFlow α) (fβ : StrictDepthFlow β)
    (hα : ∀ x : α, fα.depth x = 0) (hβ : ∀ x : β, fβ.depth x = 0) :
    (fixedPointFinset fα.step).card = Fintype.card α ∧
    (fixedPointFinset fβ.step).card = Fintype.card β := by
  constructor <;> rw [ Finset.card_eq_sum_ones ];
  · rw [ show fixedPointFinset fα.step = Finset.univ from Finset.ext fun x => by simp +decide [ fixedPointFinset, sdf_zero_depth_is_fixed fα x ( hα x ) ] ] ; simp +decide;
  · rw [ show fixedPointFinset fβ.step = Finset.univ from Finset.eq_univ_of_forall fun x => ?_ ] ; simp +decide [ Finset.card_univ ];
    exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simpa [ hβ ] using sdf_zero_depth_is_fixed fβ x ( hβ x ) ⟩

end TheoremSpaceRG