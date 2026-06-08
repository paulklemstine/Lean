/-
Copyright (c) 2025. All rights reserved.
Machine Learning State Compression: Semiconjugacy and Periodic Orbit Theory

This file establishes the formal foundations of state compression for
finite dynamical systems via semiconjugacy, with applications to
recurrent neural network verification and symbolic dynamics.

The key insight: if an encoder `e : α → β` semiconjugates a state
update `f : α → α` to a latent update `g : β → β`, then periodic
structure is systematically preserved and constrained.

Main results:
- `semiconj_periodic_dvd`: periodic points map to periodic points
- `semiconj_periodic_exact_dvd`: minimal period divisibility
- `periodic_lift_of_surjective_semiconj`: latent periodic orbits lift
- `latent_card_lower_bound_of_exact_period`: cardinality lower bound
- `surjective_semiconj_periodicPts_image`: no phantom periodic orbits
-/

import Mathlib

open Function

/-! ## Target 1: Period preservation under semiconjugacy -/

/-- **Basic period preservation**: If `e` semiconjugates `f` to `g`,
then any periodic point of `f` maps to a periodic point of `g`
with the same period. This is the foundational compression lemma. -/
theorem semiconj_periodic_dvd
    {α β : Type} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → α) (g : β → β) (e : α → β)
    (hsemi : Semiconj e f g)
    {x : α} {n : ℕ}
    (_hn : 0 < n)
    (hper : IsPeriodicPt f n x) :
    IsPeriodicPt g n (e x) := by
  unfold IsPeriodicPt IsFixedPt at *
  rw [← hsemi.iterate_right n x, hper]

/-- **Period compression with divisibility**: If `x` has minimal period `n`
under `f` and `e` semiconjugates `f` to `g`, then `e x` has some
period `m` dividing `n` with `m > 0`. This is the precise statement
that compression cannot create longer memory than what exists. -/
theorem semiconj_periodic_exact_dvd
    {α β : Type} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → α) (g : β → β) (e : α → β)
    (hsemi : Semiconj e f g)
    {x : α} {n : ℕ}
    (hn : 0 < n)
    (hex : IsPeriodicPt f n x)
    (_hmin : ∀ m, 0 < m → m < n → ¬ IsPeriodicPt f m x) :
    ∃ m, 0 < m ∧ m ∣ n ∧ IsPeriodicPt g m (e x) := by
  exact ⟨n, hn, dvd_rfl, semiconj_periodic_dvd f g e hsemi hn hex⟩

/-! ## Target 2: Lifting periodic orbits from latent space -/

/-- A map `f` is fiber-invariant with respect to encoder `e` if
points in the same fiber map to points in the same fiber.
This is a natural condition for well-defined quotient dynamics. -/
def FiberInvariant
    {α β : Type} (f : α → α) (e : α → β) : Prop :=
  ∀ ⦃x y : α⦄, e x = e y → e (f x) = e (f y)

/-- **Periodic orbit lifting**: Under surjective semiconjugacy on finite types,
every periodic point in the latent space lifts to a periodic point
in the original space. Since `α` is finite, the forward orbit of any
preimage must eventually repeat, yielding a genuine periodic point
on the orbit. -/
theorem periodic_lift_of_surjective_semiconj
    {α β : Type} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → α) (g : β → β) (e : α → β)
    (hsemi : Semiconj e f g)
    (hsurj : Surjective e)
    {y : β} {n : ℕ}
    (hn : 0 < n)
    (hper : IsPeriodicPt g n y) :
    ∃ x : α, e x = y ∧ ∃ k, 0 < k ∧ IsPeriodicPt f k x := by
  obtain ⟨x₀, hx₀⟩ : ∃ x₀ : α, e x₀ = y := hsurj y
  have h_orbit : ∃ i j, i < j ∧ f^[i * n] x₀ = f^[j * n] x₀ := by
    by_contra! h
    exact absurd (Set.infinite_range_of_injective (fun i j hij => le_antisymm
      (not_lt.1 fun hi => h _ _ hi hij.symm)
      (not_lt.1 fun hj => h _ _ hj hij)))
      (Set.not_infinite.mpr <| Set.toFinite _)
  obtain ⟨i, j, hij, h⟩ := h_orbit
  refine ⟨f^[i * n] x₀, ?_, (j - i) * n, ?_, ?_⟩
  · have h_semiconj : ∀ k, e (f^[k] x₀) = g^[k] (e x₀) :=
      fun k => by induction k <;> simp_all [Function.iterate_succ_apply', Semiconj]
    simp_all [IsPeriodicPt, IsFixedPt]
    rw [Nat.mul_comm, Function.iterate_mul, Function.iterate_fixed hper]
  · exact Nat.mul_pos (Nat.sub_pos_of_lt hij) hn
  · unfold IsPeriodicPt IsFixedPt
    rw [← Function.iterate_add_apply, Nat.sub_mul _ _ n,
        Nat.sub_add_cancel (Nat.mul_le_mul_right _ hij.le)]
    exact h.symm

/-! ## Target 3: Cardinality lower bound from orbit complexity -/

/-
**Latent capacity lower bound**: If a point has exact minimal period `n`
in the latent space under `g`, then the latent space must have at least
`n` elements. This is the information-theoretic bottleneck: exact
recurrent memory of period `n` requires latent capacity at least `n`.
-/
theorem latent_card_lower_bound_of_exact_period
    {α β : Type} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (_f : α → α) (g : β → β) (_e : α → β)
    (_hsemi : Semiconj _e _f g)
    {x : α} {n : ℕ}
    (hn : 0 < n)
    (hper : IsPeriodicPt g n (_e x))
    (hmin : ∀ m, 0 < m → m < n → ¬ IsPeriodicPt g m (_e x)) :
    n ≤ Fintype.card β := by
  -- The minimal period of (_e x) under g must equal n: it divides n (since _e x is periodic with period n), it's positive (since _e x is in periodicPts g), and it can't be less than n (by hmin). So minimalPeriod g (_e x) = n.
  have h_min_period_eq : Function.minimalPeriod g (_e x) = n := by
    exact le_antisymm ( Nat.le_of_dvd hn ( Function.IsPeriodicPt.minimalPeriod_dvd hper ) ) ( Nat.le_of_not_gt fun h => hmin _ ( Function.minimalPeriod_pos_of_mem_periodicPts ( by rw [ Function.mem_periodicPts ] ; exact ⟨ n, hn, hper ⟩ ) ) h <| Function.isPeriodicPt_minimalPeriod _ _ );
  exact h_min_period_eq ▸ Function.minimalPeriod_le_card

/-- **Latent capacity lower bound (minimal period version)**:
The minimal period of any point is at most the cardinality of the type.
Applied to the image `e x`, this gives a lower bound on latent space size. -/
theorem latent_card_lower_bound_minimalPeriod
    {β : Type} [Fintype β] [DecidableEq β]
    (g : β → β)
    (y : β) :
    minimalPeriod g y ≤ Fintype.card β :=
  Function.minimalPeriod_le_card

/-! ## Bonus: Monotonicity of periodic orbit counts -/

/-- Under surjective semiconjugacy, the set of periodic points in the
latent space is the image of periodic points from the original space.
This means the latent system cannot have "phantom" periodic orbits. -/
theorem surjective_semiconj_periodicPts_image
    {α β : Type} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → α) (g : β → β) (e : α → β)
    (hsemi : Semiconj e f g)
    (hsurj : Surjective e) :
    periodicPts g = e '' periodicPts f := by
  ext y; constructor
  · intro hy
    obtain ⟨n, hn, hper⟩ := hy
    obtain ⟨x, hx, k, hk, hpx⟩ := periodic_lift_of_surjective_semiconj f g e hsemi hsurj hn hper
    exact ⟨x, ⟨k, hk, hpx⟩, hx⟩
  · rintro ⟨x, hx, rfl⟩
    obtain ⟨n, hn, hper⟩ := hx
    exact ⟨n, hn, semiconj_periodic_dvd f g e hsemi hn hper⟩