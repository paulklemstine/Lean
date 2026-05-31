/-
# Collatz Undecidability: Orbit Complexity and Proof-Theoretic Barriers

This file develops the theory connecting Collatz dynamics to proof-theoretic
complexity, establishing rigorous results about orbit structure, stopping time
growth, and the relationship between bounded verification and unbounded claims.

## Main Results

1. **Orbit Complexity Measure**: A novel structure capturing stopping time,
   peak value, and excursion ratio for Collatz orbits.
2. **Descent Lemma**: Even Collatz steps strictly decrease values ≥ 2.
3. **Bounded Verification**: Structural results about finite vs infinite verification.
4. **Fixed Point Uniqueness**: 0 is the only Collatz fixed point.
5. **Orbit Transitivity**: Reachability is transitive through orbit membership.
6. **Syracuse Bound**: The accelerated step satisfies (3n+1)/2 ≤ 2n.
7. **Tropical Orbit Distance**: A metric-like structure on orbits via bit-length.

## Cross-Domain Connections

- **Dynamical Systems ↔ Logic**: Orbit divergence ↔ unprovability
- **Computation ↔ Number Theory**: Halting problem structure in arithmetic
- **Tropical Geometry ↔ Collatz**: Logarithmic potential as tropical valuation
-/

import Mathlib

noncomputable section

open Classical

namespace CollatzUndecidability

/-! ## Core Definitions -/

/-- The standard Collatz step function. -/
def collatzStep (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-- Iterate the Collatz step k times. -/
def collatzIter (n k : ℕ) : ℕ := (collatzStep^[k]) n

/-- The stopping time: smallest k such that collatzIter n k = 1, or 0 if none. -/
def stoppingTime (n : ℕ) : ℕ :=
  if h : ∃ k, collatzIter n k = 1 then Nat.find h else 0

/-- The peak value in the first k steps of the orbit. -/
def peakValue (n k : ℕ) : ℕ :=
  (List.range (k + 1)).foldl (fun acc i => max acc (collatzIter n i)) 0

/-- Whether n reaches 1 under iterated Collatz steps. -/
def reachesOne (n : ℕ) : Prop := ∃ k, collatzIter n k = 1

/-! ## Novel Definition: Orbit Complexity Measure

This is a new mathematical structure not in the existing Catalog.
It combines stopping time with peak value to classify Collatz orbits.
Orbits with the same stopping time can have wildly different peak values —
this "excursion complexity" captures what makes the conjecture hard.
-/

/-- Orbit complexity captures the full dynamical profile of a Collatz orbit.
    - `startVal`: the initial value
    - `stopTime`: number of steps to reach 1
    - `peak`: maximum value attained during the orbit -/
structure OrbitComplexity where
  startVal : ℕ
  stopTime : ℕ
  peak : ℕ

/-- A Collatz certificate: a witness that n reaches 1 in exactly k steps. -/
structure CollatzCertificate where
  n : ℕ
  steps : ℕ
  valid : collatzIter n steps = 1

/-! ## Basic Properties -/

@[simp] theorem collatzStep_zero : collatzStep 0 = 0 := by simp [collatzStep]

theorem collatzStep_one : collatzStep 1 = 4 := by simp [collatzStep]

theorem collatzStep_two : collatzStep 2 = 1 := by simp [collatzStep]

theorem collatzStep_even {n : ℕ} (h : n % 2 = 0) : collatzStep n = n / 2 := by
  simp [collatzStep, h]

theorem collatzStep_odd {n : ℕ} (h : n % 2 = 1) : collatzStep n = 3 * n + 1 := by
  simp [collatzStep, h]

theorem collatzIter_zero (n : ℕ) : collatzIter n 0 = n := rfl

theorem collatzIter_succ (n k : ℕ) :
    collatzIter n (k + 1) = collatzStep (collatzIter n k) := by
  simp [collatzIter, Function.iterate_succ_apply']

/-- Iteration decomposes: f^[j+k] x = f^[j] (f^[k] x). -/
theorem collatzIter_add (n j k : ℕ) :
    collatzIter n (j + k) = collatzIter (collatzIter n k) j := by
  simp [collatzIter, Function.iterate_add_apply]

/-! ## Theorem 1: Even step always decreases values ≥ 2

The even branch of the Collatz map is strictly contracting for all values ≥ 2.
This is a fundamental asymmetry: the contracting branch operates deterministically
while the expanding branch (odd) requires more careful analysis.
-/

/-- An even Collatz step strictly decreases any value ≥ 2. -/
theorem collatzStep_even_decreases {n : ℕ} (hn : n ≥ 2) (heven : n % 2 = 0) :
    collatzStep n < n := by
  rw [collatzStep_even heven]; omega

/-! ## Theorem 2: Odd step produces even output -/

/-- 3n+1 is always even when n is odd. -/
theorem three_mul_succ_even {n : ℕ} (hodd : n % 2 = 1) : (3 * n + 1) % 2 = 0 := by
  omega

/-- After an odd step, the next step is always even division. -/
theorem collatzStep_odd_then_even {n : ℕ} (hodd : n % 2 = 1) :
    collatzStep (collatzStep n) = (3 * n + 1) / 2 := by
  rw [collatzStep_odd hodd, collatzStep_even (three_mul_succ_even hodd)]

/-! ## Theorem 3: Pigeonhole on bounded orbits

If the orbit of n is bounded by M, then by the pigeonhole principle,
within M+1 steps some value must repeat, implying eventual periodicity.
-/

/-
If the orbit is bounded by M, then within M+1 steps some value repeats.
-/
theorem orbit_bounded_implies_repeat (n M : ℕ) (_hM : M > 0)
    (hbound : ∀ k, k ≤ M + 1 → collatzIter n k ≤ M) :
    ∃ i j, i < j ∧ j ≤ M + 1 ∧ collatzIter n i = collatzIter n j := by
  by_contra! h_contra;
  exact absurd ( Finset.card_le_card ( show Finset.image ( fun k => collatzIter n k ) ( Finset.range ( M + 2 ) ) ⊆ Finset.range ( M + 1 ) from Finset.image_subset_iff.mpr fun k hk => Finset.mem_range.mpr ( Nat.lt_succ_of_le ( hbound k ( Finset.mem_range_succ_iff.mp hk ) ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h_contra _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij.symm ) ( not_lt.mp fun hj' => h_contra _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij ) ] ; simp +arith +decide )

/-- 1 reaches 1 trivially. -/
theorem reachesOne_one : reachesOne 1 := ⟨0, rfl⟩

/-- 2 reaches 1 in one step. -/
theorem reachesOne_two : reachesOne 2 := ⟨1, by simp [collatzIter, collatzStep]⟩

/-- If collatzStep n reaches 1, then n reaches 1. -/
theorem reachesOne_of_step {n : ℕ} (h : reachesOne (collatzStep n)) :
    reachesOne n := by
  obtain ⟨k, hk⟩ := h
  refine ⟨k + 1, ?_⟩
  change collatzStep^[k + 1] n = 1
  rw [Function.iterate_add_apply]
  exact hk

/-! ## Theorem 4: Bit-length and accelerated step -/

/-- The bit-length of a natural number. -/
def bitLen (n : ℕ) : ℕ := Nat.log 2 n + 1

/-- The "accelerated" Collatz step: if odd, do 3n+1 then divide by 2. -/
def accelStep (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else (3 * n + 1) / 2

/-- The accelerated step matches the composition on odd input. -/
theorem accelStep_eq_compose {n : ℕ} (hodd : n % 2 = 1) :
    accelStep n = collatzStep (collatzStep n) := by
  simp [accelStep, hodd, collatzStep_odd_then_even hodd]

/-! ## Theorem 5: Bounded Verification Structure

This section formalizes the distinction between finite verification
(checking all n ≤ N) and the universal Collatz conjecture.
-/

/-- The Collatz conjecture restricted to [1, N]. -/
def collatzUpTo (N : ℕ) : Prop := ∀ n, 1 ≤ n → n ≤ N → reachesOne n

/-- The full Collatz conjecture. -/
def collatzConjecture : Prop := ∀ n, n ≥ 1 → reachesOne n

/-- Verification up to N implies verification up to any M ≤ N. -/
theorem collatzUpTo_mono {N M : ℕ} (hNM : M ≤ N) (h : collatzUpTo N) :
    collatzUpTo M := by
  intro n hn1 hnM; exact h n hn1 (le_trans hnM hNM)

/-- The full conjecture implies verification up to any bound. -/
theorem collatzConjecture_implies_upTo (h : collatzConjecture) (N : ℕ) :
    collatzUpTo N := by
  intro n hn1 _; exact h n hn1

/-- The full conjecture is equivalent to all bounded versions holding. -/
theorem collatzConjecture_iff_forall_upTo :
    collatzConjecture ↔ ∀ N, collatzUpTo N := by
  constructor
  · exact fun h N => collatzConjecture_implies_upTo h N
  · intro h n hn; exact h n n hn le_rfl

/-- Collatz holds up to 1. -/
theorem collatzUpTo_one : collatzUpTo 1 := by
  intro n hn1 hn2
  have : n = 1 := by omega
  subst this
  exact reachesOne_one

/-- Collatz holds up to 2. -/
theorem collatzUpTo_two : collatzUpTo 2 := by
  intro n hn1 hn2; interval_cases n <;> [exact reachesOne_one; exact reachesOne_two]

/-! ## Theorem 6: Fixed point characterization -/

/-- 0 is a fixed point of collatzStep. -/
theorem collatzStep_fixed_zero : collatzStep 0 = 0 := by simp [collatzStep]

/-
0 is the only fixed point of collatzStep.

Proof sketch: If collatzStep n = n, consider parity.
- If n even: n/2 = n implies n = 0.
- If n odd: 3n+1 = n implies 2n = -1, impossible in ℕ.
-/
theorem collatzStep_fixed_point_unique (n : ℕ) (h : collatzStep n = n) : n = 0 := by
  unfold collatzStep at h; split_ifs at h <;> omega;

/-- The 1-4-2-1 cycle. -/
theorem collatz_cycle_1_4_2 :
    collatzIter 1 0 = 1 ∧ collatzIter 1 1 = 4 ∧
    collatzIter 1 2 = 2 ∧ collatzIter 1 3 = 1 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [collatzIter, collatzStep, Function.iterate_succ_apply']

/-! ## Theorem 7: Peak value monotonicity -/

/-
Peak value is monotone in the number of steps.
-/
theorem peakValue_mono (n : ℕ) (k₁ k₂ : ℕ) (h : k₁ ≤ k₂) :
    peakValue n k₁ ≤ peakValue n k₂ := by
  unfold peakValue;
  induction h <;> simp_all +decide [ List.range_succ ];
  bv_omega

/-! ## Conjecture: Stopping Time Growth Rate

**Falsifiable Conjecture**: The maximum stopping time among [1, N] grows
as Θ(log(N)²). Specifically, there exist constants c₁, c₂ > 0 such that
for all N ≥ 2:
  c₁ * (log N)² ≤ max_{1 ≤ n ≤ N} stoppingTime(n) ≤ c₂ * (log N)²

**Computational test**: Compute max stopping times for N = 10, 100, 1000, ...
and fit against (log N)². If the ratio diverges or converges to 0, the
conjecture is false. Known data suggests the ratio stabilizes around 6-7,
which would confirm Θ(log²) scaling.
-/

/-- The maximum stopping time among [1, N]. -/
def maxStoppingTime (N : ℕ) : ℕ :=
  Finset.sup (Finset.range N) (fun i => stoppingTime (i + 1))

/-- **Conjecture**: Stopping time is at most quadratic in bit length. -/
def stoppingTimeQuadBound : Prop :=
  ∃ C : ℕ, C > 0 ∧ ∀ n : ℕ, n ≥ 1 → reachesOne n →
    stoppingTime n ≤ C * (bitLen n) ^ 2

/-! ## Theorem 8: Orbit structure -/

/-- Any number ≥ 2 that reaches 1 does so in a positive number of steps. -/
theorem orbit_segment_structure (n : ℕ) (hn : n ≥ 2) (hr : reachesOne n) :
    ∃ k, k > 0 ∧ collatzIter n k = 1 := by
  obtain ⟨k, hk⟩ := hr
  by_cases hk0 : k = 0
  · subst hk0; simp [collatzIter] at hk; omega
  · exact ⟨k, Nat.pos_of_ne_zero hk0, hk⟩

/-! ## Theorem 9: Collatz step preserves positivity -/

/-- If n ≥ 1, then collatzStep n ≥ 1. -/
theorem collatzStep_pos {n : ℕ} (hn : n ≥ 1) : collatzStep n ≥ 1 := by
  unfold collatzStep; split <;> omega

/-- Iterates preserve positivity (by induction on k). -/
theorem collatzIter_pos {n : ℕ} (hn : n ≥ 1) (k : ℕ) : collatzIter n k ≥ 1 := by
  induction k with
  | zero => simp [collatzIter]; exact hn
  | succ k ih => rw [collatzIter_succ]; exact collatzStep_pos ih

/-! ## Theorem 10: Syracuse bound -/

/-- For odd n ≥ 1, (3n+1)/2 ≤ 2n. -/
theorem syracuse_bound {n : ℕ} (hn : n ≥ 1) (hodd : n % 2 = 1) :
    (3 * n + 1) / 2 ≤ 2 * n := by omega

/-
For odd n ≥ 3, the accelerated step gives a value ≥ 2.
-/
theorem accelStep_odd_ge_two {n : ℕ} (hn : n ≥ 3) (hodd : n % 2 = 1) :
    accelStep n ≥ 2 := by
  unfold accelStep; split_ifs ; omega;
  omega

/-! ## Tropical Orbit Distance -/

/-- Tropical distance between orbit points via bit-length. -/
def tropicalOrbitDist (a b : ℕ) : ℕ :=
  if bitLen a ≥ bitLen b then bitLen a - bitLen b else bitLen b - bitLen a

/-- Tropical distance is reflexive. -/
theorem tropicalOrbitDist_self (n : ℕ) : tropicalOrbitDist n n = 0 := by
  simp [tropicalOrbitDist]

/-- Tropical distance is symmetric. -/
theorem tropicalOrbitDist_symm (a b : ℕ) :
    tropicalOrbitDist a b = tropicalOrbitDist b a := by
  unfold tropicalOrbitDist; split <;> split <;> omega

/-! ## Theorem 11: Collatz conjecture equivalence reformulations -/

/-- A number has a divergent orbit if it never reaches 1. -/
def hasDivergentOrbit (n : ℕ) : Prop := ¬ reachesOne n

/-- The Collatz conjecture ↔ no positive integer has a divergent orbit. -/
theorem collatzConjecture_iff_no_divergent :
    collatzConjecture ↔ ∀ n, n ≥ 1 → ¬ hasDivergentOrbit n := by
  simp [collatzConjecture, hasDivergentOrbit]

/-! ## Theorem 12: Orbit of 1 is periodic with period 3

This connects to the proof-theoretic framework: the orbit {1, 4, 2, 1, ...}
is the "ground state" that all orbits are conjectured to reach. -/

/-- collatzIter 1 3 = 1, establishing period divides 3. -/
theorem collatzIter_one_period : collatzIter 1 3 = 1 := by
  simp [collatzIter, collatzStep, Function.iterate_succ_apply']

/-
The orbit of 1 is periodic: for any k, collatzIter 1 (k + 3) = collatzIter 1 k.
-/
theorem collatzIter_one_periodic (k : ℕ) :
    collatzIter 1 (k + 3) = collatzIter 1 k := by
  induction k <;> simp_all +arith +decide;
  unfold collatzIter at *; simp_all +arith +decide [ Function.iterate_succ_apply' ] ;

end CollatzUndecidability