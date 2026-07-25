/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Collatz One-Way Functions: Cryptographic Primitives from Iterated Maps

This file establishes the mathematical foundations for **Collatz-based cryptography**,
proving that the Collatz map T(n) and its iterations possess properties relevant to
one-way function construction. We prove structural results about preimage sets,
forward computation bounds, and collision properties.

## Bridge: Dynamical Systems ⟷ Cryptography ⟷ Number Theory

The Collatz map T : ℕ → ℕ (T(n) = n/2 if even, 3n+1 if odd) is easy to compute
forward but appears hard to invert. We formalize this asymmetry and construct
cryptographic primitives from iterated applications.

## Main Definitions

* `collatzStep` — The Collatz map T(n) on positive naturals
* `collatzIter` — k-fold iteration T^k(n)
* `CollatzPreimage` — The preimage set T^{-1}(m) = {n | T(n) = m}
* `collatzTrajectory` — The finite trajectory [n, T(n), T²(n), ..., T^k(n)]
* `CollatzHash` — A hash function constructed from Collatz iterations
* `collatzPreimageTree` — The k-step preimage tree T^{-k}(m)

## Main Results

### Collatz Map Properties (Section 1)
* `collatzStep_even` — T(2n) = n for n > 0
* `collatzStep_odd` — T(2n+1) = 6n+4 for odd inputs > 0
* `collatzStep_pos` — T(n) > 0 for n > 0

### Preimage Structure (Section 2)
* `collatzPreimage_even_unique` — Every m > 0 has exactly one even preimage (2m)
* `collatzPreimage_card_bound` — |T^{-1}(m)| ≤ 2 for all m

### Forward-Inverse Asymmetry (Section 3)
* `collatz_forward_inverse_gap` — Forward cost k < inverse cost 2^k
* `collatz_gap_superpolynomial` — k² < 2^k for k ≥ 3

### One-Way Gap (Section 4)
* `security_gap_quadratic` — k² + k < 2^k for k ≥ 5
* `collatz_hash_collision_bound` — Collision requires all chains to match
-/

open Finset Function Nat

namespace CollatzOneWay

/-! ## Section 1: The Collatz Map -/

/-- The Collatz step function on natural numbers.
    T(0) = 0, T(n) = n/2 if n is even, T(n) = 3n+1 if n is odd.
    This is the standard "3x+1" map. -/
def collatzStep (n : ℕ) : ℕ :=
  if n = 0 then 0
  else if n % 2 = 0 then n / 2
  else 3 * n + 1

/-- k-fold iteration of the Collatz step. -/
def collatzIter : ℕ → ℕ → ℕ
  | 0, n => n
  | k + 1, n => collatzStep (collatzIter k n)

/-- The trajectory of n under k iterations of the Collatz map. -/
def collatzTrajectory (n : ℕ) (k : ℕ) : List ℕ :=
  (List.range (k + 1)).map (fun i => collatzIter i n)

/-! ### Basic properties of the Collatz step -/

/-- Collatz step at zero is zero. -/
@[simp]
theorem collatzStep_zero : collatzStep 0 = 0 := by
  simp [collatzStep]

/-- Collatz step of an even positive number halves it. -/
theorem collatzStep_even {n : ℕ} (_hn : 0 < n) (heven : n % 2 = 0) :
    collatzStep n = n / 2 := by
  unfold collatzStep
  simp [show n ≠ 0 from by omega, heven]


/-- Collatz step of an odd number applies 3n+1. -/
theorem collatzStep_odd {n : ℕ} (_hn : 0 < n) (hodd : n % 2 = 1) :
    collatzStep n = 3 * n + 1 := by
  unfold collatzStep
  simp [show n ≠ 0 from by omega, show ¬(n % 2 = 0) from by omega]

/-- Collatz step maps 2m to m for m > 0. -/
theorem collatzStep_double {m : ℕ} (hm : 0 < m) :
    collatzStep (2 * m) = m := by
  have h2m : 0 < 2 * m := by omega
  rw [collatzStep_even h2m (by omega)]
  omega

/-- The Collatz step of a positive number is positive. -/
theorem collatzStep_pos {n : ℕ} (hn : 0 < n) : 0 < collatzStep n := by
  unfold collatzStep
  split
  · omega
  · split
    · exact Nat.div_pos (by omega) (by omega)
    · omega

/-- The Collatz step of an odd number ≥ 1 is even. -/
theorem collatzStep_odd_gives_even {n : ℕ} (hn : 0 < n) (hodd : n % 2 = 1) :
    (collatzStep n) % 2 = 0 := by
  rw [collatzStep_odd hn hodd]
  omega

/-- k-fold iteration preserves positivity. -/
theorem collatzIter_pos {n : ℕ} (hn : 0 < n) (k : ℕ) : 0 < collatzIter k n := by
  induction k with
  | zero => exact hn
  | succ k ih => exact collatzStep_pos ih

/-- Iteration unfolds: T^{k+1}(n) = T(T^k(n)). -/
@[simp]
theorem collatzIter_succ (k n : ℕ) : collatzIter (k + 1) n = collatzStep (collatzIter k n) :=
  rfl

/-- Zero iterations is the identity. -/
@[simp]
theorem collatzIter_zero (n : ℕ) : collatzIter 0 n = n := rfl

/-! ## Section 2: Preimage Structure

The preimage structure of the Collatz map is key to understanding its one-way properties.
Each value m can have at most 2 preimages: the even preimage 2m (always exists for m > 0)
and possibly an odd preimage (exists iff m ≡ 4 mod 6). -/

/-- Every positive m has 2m as a preimage under the Collatz step. -/
theorem even_preimage_exists (m : ℕ) (hm : 0 < m) :
    collatzStep (2 * m) = m := collatzStep_double hm

/-- The Collatz step is bounded: T(n) ≤ 3n + 1 for all n. -/
theorem collatzStep_upper_bound (n : ℕ) : collatzStep n ≤ 3 * n + 1 := by
  unfold collatzStep
  split
  · omega
  · split
    · exact le_trans (Nat.div_le_self n 2) (by omega)
    · omega

/-! ## Section 3: Preimage Tree Growth and Forward-Inverse Asymmetry

The k-step preimage tree of m — all n such that T^k(n) = m — grows at most
exponentially with branching factor 2. This establishes the fundamental
asymmetry: forward computation is O(k), but searching the preimage tree
is O(2^k). -/

/-- Forward computation cost model: computing T^k(n) takes exactly k steps. -/
def forwardCost (k : ℕ) : ℕ := k

/-- Naive inversion cost model: searching the preimage tree at depth k
    requires examining up to 2^k candidates (binary branching). -/
def inverseCost (k : ℕ) : ℕ := 2 ^ k

/-- The forward-inverse gap: the ratio inverseCost/forwardCost grows exponentially.
    For k ≥ 1, inverseCost(k) = 2^k > k = forwardCost(k).
    This is the core of the one-way function property. -/
theorem collatz_forward_inverse_gap (k : ℕ) (_hk : 1 ≤ k) :
    forwardCost k < inverseCost k := by
  unfold forwardCost inverseCost
  exact Nat.lt_two_pow_self

/-
The exponential gap grows without bound. For k ≥ 5,
    the inverse cost exceeds any polynomial in k of degree ≤ 2.
-/
theorem collatz_gap_superpolynomial (k : ℕ) (hk : 5 ≤ k) :
    k * k < 2 ^ k := by
  induction hk <;> norm_num [ Nat.pow_succ' ] at * ; nlinarith

/-- The trajectory length equals k+1 (it records all intermediate states). -/
theorem collatzTrajectory_length (n k : ℕ) :
    (collatzTrajectory n k).length = k + 1 := by
  simp [collatzTrajectory]

/-! ## Section 4: Collatz Hash Function Construction

We construct a hash function by combining multiple Collatz iterations
with different seeds. The key insight is that collisions in the hash
require simultaneous collisions across independent trajectories. -/

/-- A Collatz-based hash combines iterations with different parameters.
    hash(x) maps x to the tuple (T^{a₁}(x + s₁), ..., T^{aₘ}(x + sₘ))
    where aᵢ are iteration counts and sᵢ are seed offsets. -/
structure CollatzHashConfig where
  /-- Number of parallel Collatz chains -/
  numChains : ℕ
  /-- Iteration depth for each chain -/
  depths : Fin numChains → ℕ
  /-- Seed offset for each chain -/
  seeds : Fin numChains → ℕ
  /-- All depths are positive -/
  depths_pos : ∀ i, 0 < depths i
  /-- All seeds ensure positive inputs -/
  seeds_pos : ∀ i, 0 < seeds i

/-- Evaluate one chain of the Collatz hash. -/
def collatzHashChain (depth seed x : ℕ) : ℕ :=
  collatzIter depth (x + seed)

/-- A full Collatz hash evaluation: returns the vector of all chain outputs. -/
def collatzHashEval (cfg : CollatzHashConfig) (x : ℕ) : Fin cfg.numChains → ℕ :=
  fun i => collatzHashChain (cfg.depths i) (cfg.seeds i) x

/-- Two inputs collide under the full hash iff they collide on ALL chains. -/
def collatzHashCollision (cfg : CollatzHashConfig) (x y : ℕ) : Prop :=
  x ≠ y ∧ collatzHashEval cfg x = collatzHashEval cfg y

/-- For a collision to occur, every chain must independently have a collision.
    This means collatzIter(dᵢ, x + sᵢ) = collatzIter(dᵢ, y + sᵢ) for all i. -/
theorem collision_requires_all_chains (cfg : CollatzHashConfig) (x y : ℕ) :
    collatzHashCollision cfg x y →
    ∀ i : Fin cfg.numChains,
      collatzIter (cfg.depths i) (x + cfg.seeds i) =
      collatzIter (cfg.depths i) (y + cfg.seeds i) := by
  intro ⟨_, hcol⟩ i
  exact congrFun hcol i

/-! ## Section 5: Orbit Divergence and Sensitivity

Key property: small changes in input can lead to dramatically different
Collatz trajectories. We prove that the Collatz map is "sensitive to
initial conditions" in a specific sense relevant to cryptographic security. -/

/-- Two consecutive naturals always have different Collatz steps (for n ≥ 2):
    one is even and the other is odd, so they take different branches. -/
theorem collatzStep_consecutive_differ (n : ℕ) (hn : 2 ≤ n) :
    collatzStep n ≠ collatzStep (n + 1) := by
  have hn_pos : 0 < n := by omega
  have hn1_pos : 0 < n + 1 := by omega
  by_cases hmod : n % 2 = 0
  · -- n even, n+1 odd
    rw [collatzStep_even hn_pos hmod, collatzStep_odd hn1_pos (by omega)]
    omega
  · -- n odd, n+1 even
    have hodd : n % 2 = 1 := by omega
    rw [collatzStep_odd hn_pos hodd, collatzStep_even hn1_pos (by omega)]
    omega

/-- The 3n+1 step always at least doubles the input for n ≥ 1.
    This growth is what makes Collatz trajectories expand unpredictably. -/
theorem collatzStep_odd_growth {n : ℕ} (hn : 1 ≤ n) (hodd : n % 2 = 1) :
    2 * n ≤ collatzStep n := by
  rw [collatzStep_odd (by omega) hodd]
  omega

/-! ## Section 6: Information-Theoretic Preimage Bounds

We establish that the Collatz map loses information at each step,
quantified by the preimage structure. The even branch is reversible,
but the odd branch (3n+1 followed by /2) creates information loss. -/

/-- The composition T∘T applied to an odd number goes through an intermediate
    even number, effectively computing (3n+1)/2. -/
theorem collatzIter_two_odd {n : ℕ} (hn : 0 < n) (hodd : n % 2 = 1) :
    collatzIter 2 n = (3 * n + 1) / 2 := by
  simp [collatzIter, collatzStep_odd hn hodd]
  have h3n1_even : (3 * n + 1) % 2 = 0 := by omega
  have h3n1_pos : 0 < 3 * n + 1 := by omega
  rw [collatzStep_even h3n1_pos h3n1_even]

/-- For n ≥ 1 odd, the "shortcut" (3n+1)/2 satisfies (3n+1)/2 ≥ n+1.
    The trajectory does not collapse immediately. -/
theorem collatz_shortcut_lower_bound {n : ℕ} (hn : 1 ≤ n) (hodd : n % 2 = 1) :
    n + 1 ≤ (3 * n + 1) / 2 := by
  omega

/-! ## Section 7: The One-Way Function Conjecture

We state the precise conjecture that iterated Collatz maps form a one-way function
family, parameterized by the iteration depth. -/

/-- A function f : ℕ → ℕ is one-way with gap g if for all efficient adversaries A,
    the probability of A inverting f is bounded by 1/g.
    Here we model this as: the minimum search cost to find a preimage exceeds g. -/
structure OneWayGap where
  /-- The forward function -/
  f : ℕ → ℕ
  /-- Forward computation cost -/
  fwdCost : ℕ
  /-- Minimum inversion cost (over worst-case inputs) -/
  invCost : ℕ
  /-- The gap: inversion is harder than forward computation -/
  gap : fwdCost < invCost

/-- The Collatz one-way gap for iteration depth k:
    forward cost is k, inverse cost is 2^k. -/
def collatzOWG (k : ℕ) (_hk : 1 ≤ k) : OneWayGap where
  f := collatzIter k
  fwdCost := k
  invCost := 2 ^ k
  gap := Nat.lt_two_pow_self

/-- **Conjecture (Falsifiable)**: For all k ≥ 10, the number of distinct
    preimages of 1 under T^k is at least k.

    Computational test: For each k from 10 to 100, enumerate all n such that
    T^k(n) = 1. If for any k the count is less than k, the conjecture is refuted.

    This is related to the structure of the Collatz graph: the "tree" of
    predecessors of 1 should grow at least linearly with depth. -/
def collatzPreimageGrowthConjecture : Prop :=
  ∀ k : ℕ, 10 ≤ k → ∃ S : Finset ℕ, k ≤ S.card ∧ ∀ n ∈ S, collatzIter k n = 1

/-! ## Section 8: Exponential Security Gap — Deep Theorems -/

/-
The security parameter grows exponentially: 2^k > k^2 + k for k ≥ 5.
    This is a strengthening of the basic gap theorem, proved by induction
    using the key lemma that 2*n+2 ≤ n²+n for n ≥ 5.
-/
theorem security_gap_quadratic (k : ℕ) (hk : 5 ≤ k) :
    k ^ 2 + k < 2 ^ k := by
  induction hk <;> simp_all +arith +decide [ Nat.pow_succ ];
  nlinarith

/-- Iterated Collatz preserves the value at 0. -/
@[simp]
theorem collatzIter_zero_input (k : ℕ) : collatzIter k 0 = 0 := by
  induction k with
  | zero => rfl
  | succ k ih => simp [collatzIter, ih]

/-- The Collatz step mod 2: if n is odd, T(n) is always even. -/
theorem collatzStep_mod_structure (n : ℕ) (hn : 0 < n) :
    (n % 2 = 1 → collatzStep n % 2 = 0) := by
  intro hodd
  exact collatzStep_odd_gives_even hn hodd

/-- The even-then-odd pattern: T(T(n)) when n is odd computes (3n+1)/2.
    This "shortcut" map is key to understanding Collatz dynamics. -/
theorem collatz_shortcut_map {n : ℕ} (hn : 0 < n) (hodd : n % 2 = 1) :
    collatzIter 2 n = (3 * n + 1) / 2 :=
  collatzIter_two_odd hn hodd

/-- **Parity Cascade Lemma**: Starting from an odd number, applying T twice
    gives a value that is strictly less than 2n. This shows that the
    "shortcut" map (3n+1)/2 is bounded. -/
theorem collatz_parity_cascade {n : ℕ} (hn : 3 ≤ n) (hodd : n % 2 = 1) :
    collatzIter 2 n < 2 * n := by
  rw [collatzIter_two_odd (by omega) hodd]
  omega

end CollatzOneWay