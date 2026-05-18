/-
# Continuous Iteration: A Bridge Theory for Discrete Dynamics

This module develops the formal theory of continuous iteration as a bridge between
topological dynamics, algebra (monoid actions of ℕ), and computation.

The main results package iteration of continuous self-maps as:
1. A family of continuous maps (each iterate is continuous)
2. A continuous map into finite product spaces (orbit vectors)
3. A functorial construction under semiconjugacy
4. A geometric-structure-preserving operation (compactness, connectedness)

Together these form a miniature formal theory of observable dynamics.
-/

import Mathlib

open Function Set Topology

/-! ## Part I: Continuity of Iterates and Orbit Maps -/

/-- Each iterate of a continuous self-map is continuous.
This wraps `Continuous.iterate` from Mathlib for the dynamics API. -/
theorem continuous_iterate_eval
    {α : Type*} [TopologicalSpace α]
    {f : α → α} (hf : Continuous f) :
    ∀ n : ℕ, Continuous fun x : α => (f^[n]) x :=
  fun n => hf.iterate n

/-
The orbit vector map `x ↦ (f^[0](x), f^[1](x), ..., f^[N-1](x))` is continuous.
This is the key bridge theorem: it converts a nonlinear dynamical process into
a single continuous feature map into a finite product space `Fin N → α`.
-/
theorem continuous_orbit_vector
    {α : Type*} [TopologicalSpace α]
    {N : ℕ} {f : α → α} (hf : Continuous f) :
    Continuous fun x : α => (fun k : Fin N => (f^[k.1]) x) := by
  exact continuous_pi fun i => hf.iterate _

/-! ## Part II: Geometric Structure Transport -/

/-
Iterates of a continuous map preserve compactness of images.
-/
theorem iterate_image_compact
    {α : Type*} [TopologicalSpace α]
    {f : α → α} (hf : Continuous f)
    {s : Set α} (hs : IsCompact s) :
    ∀ n : ℕ, IsCompact ((f^[n]) '' s) := by
  exact fun n => hs.image ( hf.iterate n )

/-
Iterates of a continuous map preserve connectedness of images.
-/
theorem iterate_image_connected
    {α : Type*} [TopologicalSpace α]
    {f : α → α} (hf : Continuous f)
    {s : Set α} (hs : IsConnected s) :
    ∀ n : ℕ, IsConnected ((f^[n]) '' s) := by
  exact fun n => hs.image _ ( hf.iterate n |> Continuous.continuousOn )

/-! ## Part III: Semiconjugacy and Commutation Transfer -/

/-
Semiconjugacy intertwines iterates at every time step.
If `h ∘ f = g ∘ h`, then `h ∘ f^[n] = g^[n] ∘ h` for all `n`.
This is the formal seed of orbit factorization.
-/
theorem semiconj_iterate
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) :
    ∀ n : ℕ, h ∘ (f^[n]) = (g^[n]) ∘ h := by
  intro n; ext x; induction n <;> simp_all +decide [ Function.iterate_succ_apply', Function.Semiconj ] ;
  erw [ Function.iterate_succ_apply', hsemi, ‹h ( f^[ _ ] x ) = _›, Function.iterate_succ_apply' ]

/-
Commuting maps transfer through iteration: if `f ∘ g = g ∘ f`,
then `g` commutes with every iterate of `f`.
-/
theorem commute_iterate_apply
    {α : Type*} {f g : α → α}
    (hcomm : Function.Commute f g) :
    ∀ n : ℕ, g ∘ (f^[n]) = (f^[n]) ∘ g := by
  intro n;
  induction n <;> simp_all +decide [ Function.iterate_succ, funext_iff, Function.Commute ];
  exact fun x => by rw [ ← hcomm.eq ] ;

/-
Image of iterated image under commuting map equals iterated image of image.
This is a set-level transfer principle for symmetries of dynamical systems.
-/
theorem image_iterate_of_commute
    {α : Type*} {f g : α → α}
    (hcomm : Function.Commute f g) (s : Set α) :
    ∀ n : ℕ, g '' ((f^[n]) '' s) = (f^[n]) '' (g '' s) := by
  intro n;
  rw [ ← Set.image_comp, ← Set.image_comp ];
  convert congr_arg ( · '' s ) ( commute_iterate_apply hcomm n ) using 1

/-! ## Part IV: Semiconjugacy with Topology -/

/-
Continuous semiconjugacy induces a continuous orbit map through the conjugacy.
This combines orbit-vector continuity with semiconjugate factorization:
the `g`-orbit of `h(x)` depends continuously on `x`.
-/
theorem continuous_semiconj_orbit_map
    {α β : Type*} [TopologicalSpace α] [TopologicalSpace β]
    {f : α → α} {g : β → β} {h : α → β}
    (hf : Continuous f) (hg : Continuous g)
    (hh : Continuous h) (hsemi : Function.Semiconj h f g)
    {N : ℕ} :
    Continuous fun x : α => (fun k : Fin N => (g^[k.1]) (h x)) := by
  exact continuous_pi_iff.mpr fun i => hg.iterate _ |> Continuous.comp <| hh

/-
Semiconjugacy maps orbit segments of `f` to orbit segments of `g`.
-/
theorem semiconj_orbit_image
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) (s : Set α) :
    ∀ n : ℕ, h '' ((f^[n]) '' s) = (g^[n]) '' (h '' s) := by
  simp +decide [ ← Set.image_comp, Set.image_image, hsemi.iterate_right ];
  exact fun n => congr_arg ( · '' s ) ( funext fun x => hsemi.iterate_right _ _ )

/-! ## Part V: Concrete Instantiations -/

/-
Orbit vector of an affine map on ℝ is continuous.
This is the simplest concrete dynamical system: `x ↦ a * x + b`.
-/
theorem continuous_orbit_vector_affine
    {N : ℕ} {a b : ℝ} :
    Continuous fun x : ℝ => (fun k : Fin N => ((fun y : ℝ => a * y + b)^[k.1]) x) := by
  exact continuous_orbit_vector ( show Continuous fun y : ℝ => a * y + b from Continuous.add ( continuous_const.mul continuous_id' ) continuous_const )

/-! ## Part VI: Monotone Orbit Envelopes -/

/-
For a monotone continuous self-map of a linearly ordered space,
the orbit of a point is monotone (either non-decreasing or non-increasing)
after one step determines the direction.

More precisely: if `f` is monotone and `x ≤ f x`, then the orbit `f^[n] x`
is monotone non-decreasing in `n`.
-/
theorem monotone_orbit_of_le
    {α : Type*} [Preorder α]
    {f : α → α} (hf : Monotone f) {x : α} (hle : x ≤ f x) :
    Monotone (fun n : ℕ => (f^[n]) x) := by
  refine' monotone_nat_of_le_succ _;
  -- We can prove this by induction on $n$.
  intro n
  induction' n with n ih;
  · exact hle;
  · simpa only [ Function.iterate_succ_apply' ] using hf ih

/-! ## Part VII: Iteration as a Monoid Action -/

/-- Iteration satisfies the monoid action laws: `f^[0] = id` and `f^[m+n] = f^[m] ∘ f^[n]`.
This packages Function.iterate_add as a monoid homomorphism statement. -/
theorem iterate_action_zero {α : Type*} (f : α → α) :
    f^[0] = id := Function.iterate_zero f

theorem iterate_action_add {α : Type*} (f : α → α) (m n : ℕ) :
    f^[m + n] = f^[m] ∘ f^[n] := by
  exact iterate_add f m n

/-- The orbit map `n ↦ f^[n](x)` factors through the evaluation map,
giving a monoid-action perspective on dynamics. -/
theorem orbit_map_eq_eval_comp_iterate {α : Type*} (f : α → α) (x : α) :
    (fun n : ℕ => (f^[n]) x) = (fun g : α → α => g x) ∘ (fun n => f^[n]) :=
  rfl

/-! ## Part VIII: Fixed Point Persistence Under Semiconjugacy -/

/-
If `x` is a fixed point of `f` and `h` semiconjugates `f` to `g`,
then `h x` is a fixed point of `g`.
-/
theorem semiconj_fixed_point
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) {x : α} (hfx : f x = x) :
    g (h x) = h x := by
  rw [ ← hsemi x, hfx ]

/-
If `x` is a periodic point of `f` with period `n`, and `h` semiconjugates
`f` to `g`, then `h x` is a periodic point of `g` with period dividing `n`.
-/
theorem semiconj_periodic_point
    {α β : Type*} {f : α → α} {g : β → β} {h : α → β}
    (hsemi : Function.Semiconj h f g) {x : α} {n : ℕ}
    (hper : Function.IsPeriodicPt f n x) :
    Function.IsPeriodicPt g n (h x) := by
  exact IsPeriodicPt.map hper hsemi

/-! ## Part IX: Orbit Closure Properties -/

/-
The forward orbit of a point under a continuous map has closure
that is forward-invariant: `f` maps the closure of the orbit into itself.
-/
theorem mapsTo_closure_orbit
    {α : Type*} [TopologicalSpace α]
    {f : α → α} (hf : Continuous f) (x : α) :
    MapsTo f (closure (range (fun n : ℕ => (f^[n]) x)))
             (closure (range (fun n : ℕ => (f^[n]) x))) := by
  refine' fun y hy => _;
  rw [ mem_closure_iff_nhds ] at *;
  intro t ht;
  rcases hy _ ( hf.continuousAt.preimage_mem_nhds ht ) with ⟨ z, hz, ⟨ n, rfl ⟩ ⟩;
  exact ⟨ _, hz, ⟨ n + 1, by simp +decide [ *, Function.iterate_succ_apply' ] ⟩ ⟩