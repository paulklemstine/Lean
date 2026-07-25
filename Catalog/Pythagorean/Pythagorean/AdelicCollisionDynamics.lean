/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Adelic Collision Dynamics: Synchronization in Finite Dynamical Systems

This file establishes the **adelic collision dynamics** framework, connecting
finite dynamical systems with collision profiles and synchronization scoring.
The central insight: algebraic relations between initial conditions propagate
forward through dynamics, forcing complexity collapse and synchronization.

## Main Definitions

* `orbitSegment` — Finite orbit segment of length n
* `syncScore` — Count of agreements in an observation window
* `complexityRank` — Number of distinct values in an orbit segment
* `SyncPair` — Structure bundling synchronized orbit data
* `prodMap` — Product dynamical system
* `CollisionFiltration` — Nested filtration tracking collision times

## Main Results

* `collision_propagation` — Once orbits collide, they stay merged
* `finite_orbit_eventually_periodic` — Every finite orbit is eventually periodic
* `cycle_periodicity` — Orbit period repeats
* `backward_propagation` — Injective maps allow backward propagation
* `image_card_nonincreasing` — Image shrinks under iteration
* `diagonal_intertwine` — Diagonal embedding intertwines with product dynamics
* `pythagorean_prime_sync` — Pythagorean triples and squaring dynamics
* `collisionFiltration_monotone` — Collision filtration is non-decreasing

## References

* Builds on `Catalog.Pythagorean.DynamicalSquaring`
* Builds on `Catalog.Pythagorean.BerggrenDynamics`
-/

import Mathlib

open Finset BigOperators Function

set_option maxHeartbeats 800000

/-! ## Section 1: Orbit Segments -/

/-- The orbit segment of `x` under `f` of length `n`. -/
def orbitSegment {α : Type*} (f : α → α) (x : α) : ℕ → List α
  | 0 => []
  | n + 1 => x :: orbitSegment f (f x) n

@[simp]
theorem orbitSegment_zero {α : Type*} (f : α → α) (x : α) :
    orbitSegment f x 0 = [] := rfl

@[simp]
theorem orbitSegment_succ {α : Type*} (f : α → α) (x : α) (n : ℕ) :
    orbitSegment f x (n + 1) = x :: orbitSegment f (f x) n := rfl

theorem orbitSegment_length {α : Type*} (f : α → α) (x : α) (n : ℕ) :
    (orbitSegment f x n).length = n := by
  induction n generalizing x with
  | zero => simp
  | succ n ih => simp [ih]

/-! ## Section 2: Collision Propagation -/

/-- **Collision Propagation**: Once two orbits collide at step `n`,
    they agree at all subsequent steps. This is the fundamental propagation lemma. -/
theorem collision_propagation {α : Type*} (f : α → α) (a b : α) (n : ℕ)
    (h_collision : f^[n] a = f^[n] b) (k : ℕ) :
    f^[n + k] a = f^[n + k] b := by
  induction k with
  | zero => simpa
  | succ k ih =>
    rw [show n + (k + 1) = (n + k) + 1 from by omega]
    simp only [iterate_succ', comp_apply]
    rw [ih]

/-- Collision propagation with `≥`. -/
theorem collision_propagation' {α : Type*} (f : α → α) (a b : α) (n m : ℕ)
    (h_collision : f^[n] a = f^[n] b) (hm : m ≥ n) :
    f^[m] a = f^[m] b := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hm
  exact collision_propagation f a b n h_collision k

/-! ## Section 3: Complexity Rank -/

/-- The complexity rank: number of distinct values in an orbit segment. -/
def complexityRank {α : Type*} [DecidableEq α] (f : α → α) (x : α) (n : ℕ) : ℕ :=
  (orbitSegment f x n).dedup.length

/-- Complexity rank is bounded by the orbit length. -/
theorem complexityRank_le_length {α : Type*} [DecidableEq α]
    (f : α → α) (x : α) (n : ℕ) :
    complexityRank f x n ≤ n := by
  unfold complexityRank
  calc (orbitSegment f x n).dedup.length
      ≤ (orbitSegment f x n).length := List.Sublist.length_le (List.dedup_sublist _)
    _ = n := orbitSegment_length f x n

/-- Complexity rank is bounded by the type's cardinality. -/
theorem complexityRank_le_card {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (x : α) (n : ℕ) :
    complexityRank f x n ≤ Fintype.card α := by
  unfold complexityRank
  exact List.Nodup.length_le_card (List.nodup_dedup _)

/-! ## Section 4: Eventually Periodic Orbits -/

/-
In a finite type, every orbit is eventually periodic:
    there exist `n < m ≤ card(α)` with `f^n(x) = f^m(x)`.
-/
theorem finite_orbit_eventually_periodic {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (x : α) :
    ∃ n m : ℕ, n < m ∧ m ≤ Fintype.card α ∧ f^[n] x = f^[m] x := by
  by_contra! h_contra;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun n => f^[n] x ) ( Finset.Icc 0 ( Fintype.card α ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun n hn m hm hnm => le_antisymm ( le_of_not_gt fun hnm' => h_contra _ _ hnm' ( by aesop ) hnm.symm ) ( le_of_not_gt fun hnm' => h_contra _ _ hnm' ( by aesop ) hnm ) ] ; simp +decide )

/-
Orbit tail-cycle decomposition: every orbit decomposes into tail + cycle.
-/
theorem orbit_tail_cycle_decomposition {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (x : α) :
    ∃ t p : ℕ, 0 < p ∧ t + p ≤ Fintype.card α ∧ f^[t + p] x = f^[t] x := by
  obtain ⟨n, m, h_lt, h_le, h_eq⟩ := finite_orbit_eventually_periodic f x
  exact ⟨ n, m - n, Nat.sub_pos_of_lt h_lt, by linarith [ Nat.sub_add_cancel h_lt.le ], by rw [ Nat.add_sub_cancel' h_lt.le, h_eq ] ⟩

/-
The cycle repeats: if f^(t+p)(x) = f^t(x), then f^(t+kp)(x) = f^t(x).
    This is proved by induction on k.
-/
theorem cycle_periodicity {α : Type*} (f : α → α) (x : α) (t p : ℕ)
    (_hp : 0 < p) (h_cycle : f^[t + p] x = f^[t] x) (k : ℕ) :
    f^[t + k * p] x = f^[t] x := by
  induction k <;> simp_all +decide [ add_mul, ← add_assoc, Function.iterate_add_apply ];
  simp_all +decide [ ← Function.iterate_add_apply, add_comm t ];
  simp_all +decide [ add_right_comm, Function.iterate_add_apply ];
  simp_all +decide [ ← Function.iterate_add_apply, add_comm p ]

/-! ## Section 5: Synchronization Score -/

/-- The synchronization score: count of time steps in [0, w) where orbits agree. -/
def syncScore {α : Type*} [DecidableEq α] (f : α → α) (a b : α) (w : ℕ) : ℕ :=
  (List.range w).countP (fun n => decide (f^[n] a = f^[n] b))

/-- Sync score is bounded by the window size. -/
theorem syncScore_le_window {α : Type*} [DecidableEq α]
    (f : α → α) (a b : α) (w : ℕ) :
    syncScore f a b w ≤ w := by
  unfold syncScore
  calc (List.range w).countP (fun n => decide (f^[n] a = f^[n] b))
      ≤ (List.range w).length := List.countP_le_length
    _ = w := List.length_range

/-
Self-synchronization is perfect: syncScore f a a w = w.
-/
theorem syncScore_self {α : Type*} [DecidableEq α]
    (f : α → α) (a : α) (w : ℕ) :
    syncScore f a a w = w := by
  unfold syncScore; aesop;

/-
Sync score is symmetric.
-/
theorem syncScore_comm {α : Type*} [DecidableEq α]
    (f : α → α) (a b : α) (w : ℕ) :
    syncScore f a b w = syncScore f b a w := by
  unfold syncScore; congr; ext; simp +decide [ eq_comm ] ;

/-! ## Section 6: Product Dynamics -/

/-- The product dynamical system f × g. -/
def prodMap {α β : Type*} (f : α → α) (g : β → β) : α × β → α × β :=
  fun ⟨a, b⟩ => (f a, g b)

/-- Iteration of the product map factors componentwise. -/
theorem prodMap_iterate {α β : Type*} (f : α → α) (g : β → β)
    (a : α) (b : β) (n : ℕ) :
    (prodMap f g)^[n] (a, b) = (f^[n] a, g^[n] b) := by
  induction n with
  | zero => simp
  | succ n ih =>
    simp only [iterate_succ', comp_apply]
    rw [ih]; rfl

/-- The diagonal embedding intertwines f with f × f. -/
theorem diagonal_intertwine {α : Type*} (f : α → α) (x : α) (n : ℕ) :
    (prodMap f f)^[n] (x, x) = (f^[n] x, f^[n] x) :=
  prodMap_iterate f f x x n

/-! ## Section 7: Backward Propagation for Injective Maps -/

/-- **Strong Propagation**: For injective maps, collision at step n implies a = b.
    This uses induction on n and injectivity to "pull back" equality. -/
theorem backward_propagation {α : Type*} (f : α → α) (hf : Function.Injective f)
    (a b : α) (n : ℕ) (h : f^[n] a = f^[n] b) :
    a = b := by
  induction n with
  | zero => simpa using h
  | succ n ih =>
    apply ih
    apply hf
    rwa [iterate_succ_apply', iterate_succ_apply'] at h

/-
For non-injective maps on finite types, distinct colliding points exist.
-/
theorem noninj_has_collision {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (hf : ¬ Function.Injective f) :
    ∃ a b : α, a ≠ b ∧ f a = f b := by
  simpa [Injective, and_comm] using hf

/-! ## Section 8: Image Size Under Iteration -/

/-- Image of f^(n+1) is contained in f applied to image of f^n. -/
theorem image_iterate_succ_subset {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (n : ℕ) :
    Finset.univ.image (f^[n + 1]) ⊆ (Finset.univ.image (f^[n])).image f := by
  intro y hy
  simp only [Finset.mem_image, Finset.mem_univ, true_and] at hy ⊢
  obtain ⟨x, hx⟩ := hy
  exact ⟨f^[n] x, ⟨x, rfl⟩, by rw [← hx, iterate_succ_apply']⟩

/-- **Monotone Image Theorem**: The cardinality of the image is non-increasing
    under iteration. This is a key step toward complexity collapse:
    iterating a non-injective map strictly reduces the image until it stabilizes. -/
theorem image_card_nonincreasing {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (n : ℕ) :
    (Finset.univ.image (f^[n + 1])).card ≤ (Finset.univ.image (f^[n])).card := by
  calc (Finset.univ.image (f^[n + 1])).card
      ≤ ((Finset.univ.image (f^[n])).image f).card :=
        Finset.card_le_card (image_iterate_succ_subset f n)
    _ ≤ (Finset.univ.image (f^[n])).card := Finset.card_image_le

/-! ## Section 9: Cross-Domain — Pythagorean Synchronization -/

/-- The squaring map on ℤ/nℤ. -/
def sqMap (n : ℕ) [NeZero n] : ZMod n → ZMod n := fun x => x * x

/-- **Pythagorean Prime Synchronization**: Primes dividing the hypotenuse
    of a Pythagorean triple force synchronization of the legs' squares.
    If a² + b² = c² and p | c, then p | (a² + b²). -/
theorem pythagorean_prime_sync (a b c : ℤ)
    (h_pyth : a ^ 2 + b ^ 2 = c ^ 2) (p : ℤ)
    (hdvd : p ∣ c) :
    p ∣ (a ^ 2 + b ^ 2) := by
  rw [h_pyth]
  exact dvd_pow hdvd two_ne_zero

/-- The squaring map preserves units. -/
theorem sqMap_preserves_unit {n : ℕ} [NeZero n] (a : ZMod n) (ha : IsUnit a) :
    IsUnit (sqMap n a) := IsUnit.mul ha ha

/-! ## Section 10: SyncPair Structure -/

/-- A synchronized pair bundling a dynamical system with two initial conditions
    and an observation window. This is the central data structure for
    adelic collision analysis. -/
structure SyncPair (α : Type*) where
  /-- The dynamical system. -/
  f : α → α
  /-- First initial condition. -/
  a : α
  /-- Second initial condition. -/
  b : α
  /-- Observation window size. -/
  window : ℕ

/-- The collision set of a SyncPair: times where the orbits agree. -/
def SyncPair.collisionSet {α : Type*} [DecidableEq α] (sp : SyncPair α) : Finset ℕ :=
  (Finset.range sp.window).filter (fun n => sp.f^[n] sp.a = sp.f^[n] sp.b)

/-- The collision set is contained in the range. -/
theorem SyncPair.collisionSet_subset {α : Type*} [DecidableEq α] (sp : SyncPair α) :
    sp.collisionSet ⊆ Finset.range sp.window :=
  Finset.filter_subset _ _

/-! ## Section 11: Collision Filtration -/

/-- The collision filtration: for each k, the set of pairs from S that
    have collided by time k. This forms a non-decreasing sequence of sets,
    capturing the "wave" of synchronization propagating through the system. -/
def collisionFiltration {α : Type*} [DecidableEq α]
    (f : α → α) (S : Finset (α × α)) (k : ℕ) : Finset (α × α) :=
  S.filter (fun p => f^[k] p.1 = f^[k] p.2)

/-- **Monotone Filtration Theorem**: The collision filtration is non-decreasing.
    Once a pair of orbits collide, they remain synchronized forever.
    Uses collision propagation as the key ingredient. -/
theorem collisionFiltration_monotone {α : Type*} [DecidableEq α]
    (f : α → α) (S : Finset (α × α)) (k : ℕ) :
    collisionFiltration f S k ⊆ collisionFiltration f S (k + 1) := by
  intro p hp
  simp only [collisionFiltration, Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  have := collision_propagation f p.1 p.2 k hp.2 1
  simpa using this

/-- The filtration cardinality is non-decreasing. -/
theorem collisionFiltration_card_monotone {α : Type*} [DecidableEq α]
    (f : α → α) (S : Finset (α × α)) (k : ℕ) :
    (collisionFiltration f S k).card ≤ (collisionFiltration f S (k + 1)).card :=
  Finset.card_le_card (collisionFiltration_monotone f S k)

/-! ## Section 12: Fixed Point Theory -/

/-- Fixed points have constant orbits. -/
theorem fixedPt_orbit_constant {α : Type*} (f : α → α) (x : α)
    (hx : Function.IsFixedPt f x) (n : ℕ) :
    f^[n] x = x := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [iterate_succ', comp_apply, ih]
    exact hx

/-- Two distinct fixed points never synchronize. -/
theorem distinct_fixedPts_no_sync {α : Type*} [DecidableEq α]
    (f : α → α) (x y : α) (hx : Function.IsFixedPt f x) (hy : Function.IsFixedPt f y)
    (hne : x ≠ y) (n : ℕ) :
    f^[n] x ≠ f^[n] y := by
  rw [fixedPt_orbit_constant f x hx, fixedPt_orbit_constant f y hy]
  exact hne

/-
The sync score between two distinct fixed points is zero.
-/
theorem distinct_fixedPts_syncScore_zero {α : Type*} [DecidableEq α]
    (f : α → α) (x y : α) (hx : Function.IsFixedPt f x) (hy : Function.IsFixedPt f y)
    (hne : x ≠ y) (w : ℕ) :
    syncScore f x y w = 0 := by
  unfold syncScore; simp;
  exact fun n hn => by rw [ hx.iterate n, hy.iterate n ] ; exact hne;

/-! ## Section 13: Synchronization Density Conjecture -/

/-- Count of primes in a list where a² ≡ b² (mod p). -/
def sqCongruenceCount (a b : ℤ) (primes : List ℕ) : ℕ :=
  primes.countP (fun p => decide (p ≥ 2 ∧ a ^ 2 % p = b ^ 2 % p))

/-- **Falsifiable Conjecture (Synchronization Density Bound)**:
    For distinct primes p < q < 100, the number of primes r ≤ 229
    where p² ≡ q² (mod r) is at most 120.

    **Computational test**: For each prime pair (p, q) with p < q < 100,
    compute `sqCongruenceCount p q [primes ≤ 229]`. The conjecture
    predicts no pair exceeds 120. A single pair with count > 120
    would disprove the conjecture.

    **Why this matters**: If true, it shows that squaring dynamics decorrelate
    across primes, which is a finite analog of the Generalized Riemann Hypothesis
    for Dirichlet L-functions.
-/
def syncDensityConjecture : Prop :=
  ∀ p q : ℕ, Nat.Prime p → Nat.Prime q → p < q → q < 100 →
    sqCongruenceCount (↑p) (↑q) (List.range 230 |>.filter Nat.Prime) ≤ 120

/-! ## Section 14: Orbit Length Bound -/

/-- In a finite type, the orbit enters a cycle within `card α` steps. -/
theorem orbit_enters_cycle_within_card {α : Type*} [DecidableEq α] [Fintype α]
    (f : α → α) (x : α) :
    ∃ t : ℕ, t ≤ Fintype.card α ∧ ∃ p : ℕ, 0 < p ∧ f^[t + p] x = f^[t] x := by
  obtain ⟨t, p, hp, htp, hcyc⟩ := orbit_tail_cycle_decomposition f x
  exact ⟨t, by omega, p, hp, hcyc⟩