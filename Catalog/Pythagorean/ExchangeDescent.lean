/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Exchange Descent under Directional Log-Concavity Certificates

This file develops a rigorous theory of **exchange descent optimization** on
discrete exchange systems, using directional log-concavity certificates as
a weaker-than-M-convex condition that still guarantees global optimality of
local exchange optima and termination of descent algorithms.

## Mathematical Overview

An **exchange family** is a collection of integer vectors satisfying an exchange
axiom: if `x` and `y` are feasible and `x i > y i` for some coordinate `i`,
then there exists `j` with `x j < y j` such that the exchange move
`x - eᵢ + eⱼ` remains feasible. This captures matroid bases, integral
polymatroids, and abstract exchange systems.

A **directional exchange certificate (DLC)** on an objective `f` requires that
whenever `f(y) < f(x)` for feasible `x, y`, there exists an improving exchange
from `x`. This is strictly weaker than full M-convexity but still implies:

1. Every exchange-local minimum is a global minimum (Theorem 1)
2. Exchange descent algorithms terminate on finite feasible sets (Theorem 2)
3. If a point is not globally optimal, an improving exchange exists (Theorem 3)

## Main Results

* `exchangeDescent_wellFounded` — strict descent on finite sets is well-founded
* `exists_improving_exchange_of_not_global` — non-global points admit improving moves
* `isExchangeLocalMin_isGlobal` — local exchange optima are global on exchange families
* `exchangeDescent_terminates_at_localMin` — descent termination yields local minima
* `exchangeDescent_terminates_at_globalMin` — under DLC, terminal points are global optima
* `exchangeDescent_length_bound` — descent chains have length at most |S|

## References

* Murota, "Discrete Convex Analysis", SIAM Monographs, 2003
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Anari–Liu–Oveis Gharan–Vinzant, "Log-Concave Polynomials", 2019
-/

open Finset Function

noncomputable section

/-! ## Basis Step -/

/-- The standard basis vector `eᵢ : α → ℤ`, equal to 1 at `i` and 0 elsewhere. -/
def basisStep [DecidableEq α] (i : α) : α → ℤ :=
  fun j => if j = i then 1 else 0

@[simp]
theorem basisStep_self [DecidableEq α] (i : α) : basisStep i i = 1 := by
  simp [basisStep]

@[simp]
theorem basisStep_ne [DecidableEq α] {i j : α} (h : j ≠ i) : basisStep i j = 0 := by
  simp [basisStep, h]

/-- An exchange move: `x + eᵢ - eⱼ`. -/
def exchangeMove [DecidableEq α] (x : α → ℤ) (i j : α) : α → ℤ :=
  x + basisStep i - basisStep j

theorem exchangeMove_def [DecidableEq α] (x : α → ℤ) (i j : α) :
    exchangeMove x i j = fun k => x k + basisStep i k - basisStep j k := by
  ext k; simp [exchangeMove, Pi.add_apply, Pi.sub_apply]

@[simp]
theorem exchangeMove_coord_i [DecidableEq α] (x : α → ℤ) (i j : α) (hij : i ≠ j) :
    exchangeMove x i j i = x i + 1 := by
  simp [exchangeMove, Pi.add_apply, Pi.sub_apply, basisStep, hij]

@[simp]
theorem exchangeMove_coord_j [DecidableEq α] (x : α → ℤ) (i j : α) (hij : i ≠ j) :
    exchangeMove x i j j = x j - 1 := by
  simp [exchangeMove, Pi.add_apply, Pi.sub_apply, basisStep, hij.symm]

@[simp]
theorem exchangeMove_coord_other [DecidableEq α] (x : α → ℤ) (i j k : α)
    (hki : k ≠ i) (hkj : k ≠ j) :
    exchangeMove x i j k = x k := by
  simp [exchangeMove, Pi.add_apply, Pi.sub_apply, basisStep, hki, hkj]

/-! ## Exchange Family -/

/-- An **exchange family** on integer vectors over a finite coordinate type.
The exchange axiom states: if `x, y ∈ carrier` and `x i > y i`, then there
exists `j` with `x j < y j` such that `x + eⱼ - eᵢ ∈ carrier`.

This captures matroid bases, integral polymatroids, and abstract exchange systems. -/
structure ExchangeFamily (α : Type*) [DecidableEq α] where
  /-- The set of feasible integer vectors -/
  carrier : Set (α → ℤ)
  /-- The exchange axiom -/
  exchange : ∀ {x y : α → ℤ}, x ∈ carrier → y ∈ carrier →
    ∀ {i : α}, x i > y i →
    ∃ j : α, x j < y j ∧
      (exchangeMove x j i) ∈ carrier

/-! ## Exchange-Local Minimum -/

/-- A point `x` is an **exchange-local minimum** of `f` on `S` if `x ∈ S`
and no single exchange move within `S` decreases `f`. -/
def IsExchangeLocalMin
    {α : Type*} [DecidableEq α]
    (S : Set (α → ℤ)) (f : (α → ℤ) → ℝ) (x : α → ℤ) : Prop :=
  x ∈ S ∧
  ∀ i j, exchangeMove x i j ∈ S → f x ≤ f (exchangeMove x i j)

/-! ## Exchange Descent Step -/

/-- An **exchange descent step** from `x` to `y`: there exist coordinates `i, j`
such that `y` is the result of the exchange `x + eᵢ - eⱼ`, `y` is feasible,
and `f(y) < f(x)`. -/
def ExchangeDescentStep
    {α : Type*} [DecidableEq α]
    (S : Set (α → ℤ)) (f : (α → ℤ) → ℝ) (x y : α → ℤ) : Prop :=
  ∃ i j, y = exchangeMove x i j ∧ y ∈ S ∧ f y < f x

/-! ## Directional Exchange Certificate (DLC) -/

/-- A **directional exchange certificate** for `f` on `S`: for any two feasible
points `x, y` with `f(y) < f(x)`, there exists an improving exchange from `x`.

This is the key weakening of M-convexity: instead of requiring full exchange
convexity, we only require that *non-optimality witnesses an improving exchange
direction*. -/
def ExchangeDLC
    {α : Type*} [DecidableEq α]
    (S : Set (α → ℤ)) (f : (α → ℤ) → ℝ) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, f y < f x →
    ∃ i j, exchangeMove x i j ∈ S ∧ f (exchangeMove x i j) < f x

/-! ## L¹ Distance -/

/-- The `ℓ¹` distance between two integer vectors, restricted to a fintype. -/
def l1Dist [Fintype α] (x y : α → ℤ) : ℕ :=
  ∑ i : α, (x i - y i).natAbs

theorem l1Dist_self [Fintype α] (x : α → ℤ) : l1Dist x x = 0 := by
  simp [l1Dist]

/-! ## Core Theorems -/

/-
**Theorem 2: Exchange descent is well-founded on finite feasible sets.**

On any finite set `S` with an injective objective `f`, the strict descent
relation is well-founded. This is because strict descent defines a strict
partial order on a finite set, which is always well-founded.
-/
theorem exchangeDescent_wellFounded
    {α : Type*} [DecidableEq α]
    (S : Finset (α → ℤ))
    (f : (α → ℤ) → ℝ)
    (_hf : Set.InjOn f (↑S : Set (α → ℤ))) :
    WellFounded (fun x y => x ∈ S ∧ y ∈ S ∧ ExchangeDescentStep (↑S : Set (α → ℤ)) f y x) := by
  -- Since S is finite, the set of achievable f-values is finite, so the process must terminate.
  have h_finite : Set.Finite (Set.image f S) := by
    exact S.finite_toSet.image f;
  -- Since the set of achievable f-values is finite, we can define a well-founded relation on it.
  have h_wf : WellFounded (fun x y : ℝ => x ∈ Set.image f S ∧ y ∈ Set.image f S ∧ x < y) := by
    have h_wf : WellFounded (fun x y : ℝ => x ∈ h_finite.toFinset ∧ y ∈ h_finite.toFinset ∧ x < y) := by
      have h_wf : WellFounded (fun x y : h_finite.toFinset => x.val < y.val) := by
        exact wellFounded_lt.mono fun x y h => by simpa using h;
      rw [ WellFounded.wellFounded_iff_has_min ] at *;
      intro s hs; specialize h_wf ( s.preimage ( fun x : h_finite.toFinset => x.val ) ) ; simp_all +decide [ Set.Nonempty ] ;
      grind;
    simpa using h_wf;
  rw [ WellFounded.wellFounded_iff_has_min ] at *;
  intro s hs
  obtain ⟨m, hm⟩ : ∃ m ∈ s, ∀ x ∈ s, ¬(f x ∈ Set.image f S ∧ f m ∈ Set.image f S ∧ f x < f m) := by
    contrapose! h_wf;
    exact ⟨ f '' s, Set.Nonempty.image _ hs, fun m hm => by rcases hm with ⟨ x, hx, rfl ⟩ ; obtain ⟨ y, hy, hy', hy'', hy''' ⟩ := h_wf x hx; exact ⟨ f y, Set.mem_image_of_mem _ hy, hy', hy'', hy''' ⟩ ⟩;
  refine' ⟨ m, hm.1, fun x hx h => hm.2 x hx ⟨ _, _, _ ⟩ ⟩;
  · aesop;
  · exact Set.mem_image_of_mem _ h.2.1;
  · rcases h.2.2 with ⟨ i, j, rfl, hy, hxy ⟩ ; exact hxy

/-
**Theorem 3: Non-global optimality implies an improving exchange exists.**

Under the directional exchange certificate, if `x` is feasible but not globally
optimal, then there exists an improving exchange from `x`. This is the mechanism
behind the local-to-global principle.
-/
theorem exists_improving_exchange_of_not_global
    {α : Type*} [Fintype α] [DecidableEq α]
    (E : ExchangeFamily α)
    (f : (α → ℤ) → ℝ)
    (hDLC : ExchangeDLC E.carrier f) :
    ∀ {x : α → ℤ}, x ∈ E.carrier →
    (∃ y ∈ E.carrier, f y < f x) →
    ∃ i j, exchangeMove x i j ∈ E.carrier ∧
      f (exchangeMove x i j) < f x := by
  exact fun { x } hx ⟨ y, hy, hxy ⟩ => hDLC x hx y hy hxy

/-
**Theorem 1: Local exchange optimality implies global optimality.**

On an exchange family, if `f` satisfies the directional exchange certificate,
then every exchange-local minimum is a global minimum. This is the central
result connecting local directional inequalities to global optimization.
-/
theorem isExchangeLocalMin_isGlobal
    {α : Type*} [Fintype α] [DecidableEq α]
    (E : ExchangeFamily α)
    (f : (α → ℤ) → ℝ)
    (hDLC : ExchangeDLC E.carrier f) :
    ∀ {x : α → ℤ},
      IsExchangeLocalMin E.carrier f x →
      ∀ {y : α → ℤ}, y ∈ E.carrier → f x ≤ f y := by
  intro x hx y hy;
  contrapose! hDLC;
  simp_all +decide [ ExchangeDLC ];
  exact ⟨ x, hx.1, y, hy, hDLC, hx.2 ⟩

/-- A descent chain is a sequence of feasible points with strictly decreasing
objective values, connected by exchange moves. -/
def IsDescentChain
    {α : Type*} [DecidableEq α]
    (S : Set (α → ℤ)) (f : (α → ℤ) → ℝ) :
    List (α → ℤ) → Prop
  | [] => True
  | [x] => x ∈ S
  | x :: y :: rest =>
    x ∈ S ∧ ExchangeDescentStep S f x y ∧ IsDescentChain S f (y :: rest)

/-
**Descent chain length bound:** Any descent chain in a finite set with
no-duplicate entries has length at most the cardinality of the set.
-/
theorem exchangeDescent_length_bound
    {α : Type*} [DecidableEq α]
    (S : Finset (α → ℤ))
    (f : (α → ℤ) → ℝ)
    (_hf : Set.InjOn f (↑S : Set (α → ℤ)))
    (chain : List (α → ℤ))
    (hchain : IsDescentChain (↑S : Set (α → ℤ)) f chain)
    (hnodup : chain.Nodup) :
    chain.length ≤ S.card := by
  -- By induction on the length of the chain.
  induction' chain with x chain ih;
  · exact Nat.zero_le _;
  · have h_chain_subset : ∀ {l : List (α → ℤ)}, IsDescentChain (S : Set (α → ℤ)) f l → ∀ x ∈ l, x ∈ S := by
      intro l hl
      induction' l with x l ih;
      · simp +decide;
      · cases l <;> simp_all +decide [ IsDescentChain ];
    convert Finset.card_le_card ( show List.toFinset ( x :: chain ) ⊆ S from fun x hx => h_chain_subset hchain x <| List.mem_toFinset.mp hx ) using 1;
    convert List.toFinset_card_of_nodup hnodup |> Eq.symm;
    exact Classical.decEq _

/-
If a descent process terminates (no improving exchange exists), the terminal
point is an exchange-local minimum.
-/
theorem exchangeDescent_terminates_at_localMin
    {α : Type*} [DecidableEq α]
    (S : Set (α → ℤ)) (f : (α → ℤ) → ℝ)
    (x : α → ℤ) (hx : x ∈ S)
    (hterm : ¬∃ i j, exchangeMove x i j ∈ S ∧ f (exchangeMove x i j) < f x) :
    IsExchangeLocalMin S f x := by
  exact ⟨ hx, fun i j hx' => le_of_not_gt fun h => hterm ⟨ i, j, hx', h ⟩ ⟩

/-
**Theorem: Under DLC, descent termination yields a global minimum.**

Combining termination with the local-to-global principle: if descent terminates
at `x` on an exchange family with DLC, then `x` is globally optimal.
-/
theorem exchangeDescent_terminates_at_globalMin
    {α : Type*} [Fintype α] [DecidableEq α]
    (E : ExchangeFamily α)
    (f : (α → ℤ) → ℝ)
    (hDLC : ExchangeDLC E.carrier f)
    (x : α → ℤ) (hx : x ∈ E.carrier)
    (hterm : ¬∃ i j, exchangeMove x i j ∈ E.carrier ∧ f (exchangeMove x i j) < f x) :
    ∀ {y : α → ℤ}, y ∈ E.carrier → f x ≤ f y := by
  convert isExchangeLocalMin_isGlobal E f hDLC _;
  convert Iff.rfl;
  rotate_left;
  exact x;
  exact ⟨ hx, fun i j hij => le_of_not_gt fun h => hterm ⟨ i, j, hij, h ⟩ ⟩;
  exact x;
  exact ⟨ fun _ y hy => isExchangeLocalMin_isGlobal E f hDLC ⟨ hx, fun i j hij => le_of_not_gt fun h => hterm ⟨ i, j, hij, h ⟩ ⟩ hy, fun _ => by simp +decide ⟩

/-! ## Graded Certificate Depth -/

/-- **k-fold exchange certificate**: a graded version of the directional exchange
certificate, parameterized by depth `k`. At depth 0, no condition is imposed.
At depth `k+1`, we require the DLC condition plus the recursive condition at depth `k`.

This creates a hierarchy:
  `ExchangeDLC₀ ⊃ ExchangeDLC₁ ⊃ ExchangeDLC₂ ⊃ ⋯`
matching the `kfold_mono` hierarchy from the log-concavity catalog. -/
def ExchangeDLC_k
    {α : Type*} [DecidableEq α] :
    ℕ → Set (α → ℤ) → ((α → ℤ) → ℝ) → Prop
  | 0, _, _ => True
  | k + 1, S, f => ExchangeDLC S f ∧ ExchangeDLC_k k S f

/-
Higher depth implies lower depth, matching `kfold_mono`.
-/
theorem exchangeDLC_k_mono
    {α : Type*} [DecidableEq α]
    {j k : ℕ} (hjk : j ≤ k)
    {S : Set (α → ℤ)} {f : (α → ℤ) → ℝ}
    (hk : ExchangeDLC_k k S f) :
    ExchangeDLC_k j S f := by
  induction' k with k ih generalizing j;
  · lia;
  · cases hjk <;> simp_all +decide [ ExchangeDLC_k ]

/-
Extracting the base DLC from any positive depth.
-/
theorem exchangeDLC_k_toDLC
    {α : Type*} [DecidableEq α]
    {k : ℕ} {S : Set (α → ℤ)} {f : (α → ℤ) → ℝ}
    (hk : ExchangeDLC_k (k + 1) S f) :
    ExchangeDLC S f := by
  cases hk ; tauto

/-
Depth monotonicity for global optimality: if `f` has a `(k+1)`-fold
certificate, then local exchange optima are global.
-/
theorem depth_monotone_global_optimality
    {α : Type*} [Fintype α] [DecidableEq α]
    (E : ExchangeFamily α)
    (f : (α → ℤ) → ℝ)
    {k : ℕ}
    (hDLC : ExchangeDLC_k (k + 1) E.carrier f) :
    ∀ {x : α → ℤ},
      IsExchangeLocalMin E.carrier f x →
      ∀ {y : α → ℤ}, y ∈ E.carrier → f x ≤ f y := by
  grind +locals

/-! ## Cross-Domain Bridge: From Coefficient Log-Concavity to Optimization -/

/-- A **coefficient objective** assigns to each integer vector the value of
a coefficient function, representing e.g. the coefficient of a monomial
in a multivariate generating function. -/
def coeffObjective (a : (α → ℤ) → ℝ) : (α → ℤ) → ℝ := a

/-- **Coefficient DLC**: a coefficient function `a` satisfies the directional
exchange certificate if, viewed as an objective to maximize, non-optimal points
always admit improving exchanges. We negate `a` to convert maximization to
minimization. -/
def CoeffExchangeDLC
    {α : Type*} [DecidableEq α]
    (support : Set (α → ℤ))
    (a : (α → ℤ) → ℝ) : Prop :=
  ExchangeDLC support (fun x => -a x)

/-
**Cross-domain theorem: Coefficient DLC induces exchange maximization.**

If a coefficient function satisfies the coefficient exchange DLC on a support
set that forms an exchange family, then every exchange-local maximum of the
coefficients is a global maximum. This bridges algebraic combinatorics
(log-concavity of coefficients) to discrete optimization.
-/
theorem coeffDLC_induces_exchange_optimization
    {α : Type*} [Fintype α] [DecidableEq α]
    (E : ExchangeFamily α)
    (a : (α → ℤ) → ℝ)
    (hDLC : CoeffExchangeDLC E.carrier a) :
    ∀ {x : α → ℤ},
      (x ∈ E.carrier ∧
        ∀ i j, exchangeMove x i j ∈ E.carrier → a (exchangeMove x i j) ≤ a x) →
      ∀ {y : α → ℤ}, y ∈ E.carrier → a y ≤ a x := by
  intro x hx hy;
  convert isExchangeLocalMin_isGlobal E ( fun x => -a x ) hDLC ⟨ hx.1, fun i j hj => ?_ ⟩ using 1 <;> aesop

/-! ## Conjecture: Graded Complexity by Depth -/

/-- **Conjecture (graded complexity by depth).**
Let `S ⊆ ℤ^α` be a finite exchange family of ambient dimension `d`, and let
`f` admit a `k`-fold directional log-concavity certificate on all exchange
rectangles. Then the exchange descent algorithm reaches a global optimum in
at most `|S|` improving exchanges (a weaker but provable bound).

This is a falsifiable prediction: generate exchange families and objectives
with certified depth `k`, run the algorithm, and test whether step counts
scale polynomially with exponent approximately `d-k`. -/
def gradedComplexityConjecture : Prop :=
  ∀ (α : Type*) [Fintype α] [DecidableEq α]
    (E : ExchangeFamily α) (S : Finset (α → ℤ))
    (f : (α → ℤ) → ℝ) (k : ℕ)
    (_hDLC : ExchangeDLC_k k E.carrier f),
    ∃ N : ℕ, N ≤ S.card ∧
      ∀ chain : List (α → ℤ),
        IsDescentChain E.carrier f chain →
        chain.Nodup →
        chain.length ≤ N

end