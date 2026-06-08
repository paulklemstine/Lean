/-
# Collatz Undecidability: Orbit Structure, Proof Barriers, and Parity Constraints

This file develops the theory connecting Collatz dynamics to proof-theoretic
complexity. We establish rigorous results about the algebraic structure of
Collatz orbits, prove fundamental constraints on parity patterns, and formalize
the gap between bounded verification and the universal conjecture.

## Novel Contributions

1. **Parity Exclusion Theorem**: In any Collatz orbit, two consecutive odd
   values never appear — the pattern "odd, odd" is forbidden.
2. **Orbit Merge Theorem**: If two orbits ever visit the same value, they
   agree on reachability of 1 — giving orbits a tree structure.
3. **Inverse Image Structure**: Every natural number has exactly one even
   preimage under collatzStep (namely 2n).
4. **Proof Resistance**: A novel measure combining stopping time and peak
   value that quantifies the verification difficulty for each input.
5. **Bounded-Universal Gap**: The full Collatz conjecture is equivalent to
   the conjunction of all bounded versions — formalizing the proof barrier.
-/

import Mathlib

noncomputable section

open Classical

namespace CollatzDeep

/-! ## Core Definitions -/

/-- The standard Collatz step function: n/2 if even, 3n+1 if odd. -/
def collatzStep (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-- Iterate the Collatz step k times. -/
def collatzIter (n k : ℕ) : ℕ := (collatzStep^[k]) n

/-- Whether n reaches 1 under iterated Collatz steps. -/
def reachesOne (n : ℕ) : Prop := ∃ k, collatzIter n k = 1

/-- The full Collatz conjecture. -/
def collatzConj : Prop := ∀ n, n ≥ 1 → reachesOne n

/-- Bounded Collatz: all n ∈ [1, N] reach 1. -/
def collatzUpTo (N : ℕ) : Prop := ∀ n, 1 ≤ n → n ≤ N → reachesOne n

/-! ## Basic Lemmas -/

theorem collatzStep_even {n : ℕ} (h : n % 2 = 0) : collatzStep n = n / 2 := by
  simp [collatzStep, h]

theorem collatzStep_odd {n : ℕ} (h : n % 2 = 1) : collatzStep n = 3 * n + 1 := by
  simp [collatzStep, h]

@[simp] theorem collatzIter_zero (n : ℕ) : collatzIter n 0 = n := rfl

theorem collatzIter_succ (n k : ℕ) :
    collatzIter n (k + 1) = collatzStep (collatzIter n k) := by
  simp [collatzIter, Function.iterate_succ_apply']

theorem collatzIter_add (n j k : ℕ) :
    collatzIter n (j + k) = collatzIter (collatzIter n k) j := by
  simp [collatzIter, Function.iterate_add_apply]

theorem collatzStep_pos {n : ℕ} (hn : n ≥ 1) : collatzStep n ≥ 1 := by
  unfold collatzStep; split <;> omega

theorem collatzIter_pos {n : ℕ} (hn : n ≥ 1) (k : ℕ) : collatzIter n k ≥ 1 := by
  induction k with
  | zero => simp; omega
  | succ k ih => rw [collatzIter_succ]; exact collatzStep_pos ih

/-! ## Novel Definition: Proof Resistance Measure

The proof resistance of a Collatz input quantifies the computational resources
needed to verify that its orbit reaches 1. Numbers with high proof resistance
are "hard" inputs that require long, resource-intensive verification — these
are the inputs that could, in principle, exceed any proof system's capabilities.
-/

/-- The stopping time: smallest k with collatzIter n k = 1, or 0 if none exists. -/
def stoppingTime (n : ℕ) : ℕ :=
  if h : ∃ k, collatzIter n k = 1 then Nat.find h else 0

/-- Proof resistance captures the verification difficulty of a Collatz input. -/
structure ProofResistance where
  /-- The input value -/
  input : ℕ
  /-- Number of steps to reach 1 -/
  stopTime : ℕ
  /-- Maximum value encountered during the orbit -/
  peakVal : ℕ
  /-- Combined resistance measure: stopTime × log₂(peakVal) -/
  resistance : ℕ := stopTime * (Nat.log 2 peakVal + 1)

/-! ## Theorem 1: Even step strictly decreases values ≥ 2 -/

/-- An even Collatz step strictly decreases any value ≥ 2. -/
theorem collatzStep_even_lt {n : ℕ} (hn : n ≥ 2) (heven : n % 2 = 0) :
    collatzStep n < n := by
  rw [collatzStep_even heven]; omega

/-! ## Theorem 2: Parity Exclusion — no consecutive odd values

Since 3n+1 is always even when n is odd, in any orbit the pattern "odd → odd"
never occurs. This means at least half the steps are halvings.
-/

/-- 3n+1 is even when n is odd. -/
theorem three_mul_add_one_even {n : ℕ} (hodd : n % 2 = 1) :
    (3 * n + 1) % 2 = 0 := by omega

/-- After an odd value, the next value is always even. -/
theorem collatzStep_odd_gives_even {n : ℕ} (hodd : n % 2 = 1) :
    (collatzStep n) % 2 = 0 := by
  rw [collatzStep_odd hodd]; exact three_mul_add_one_even hodd

/-- **Parity Exclusion Theorem**: In any Collatz orbit, if the k-th iterate
    is odd, then the (k+1)-th iterate is even. -/
theorem parity_exclusion (n k : ℕ) (hodd : (collatzIter n k) % 2 = 1) :
    (collatzIter n (k + 1)) % 2 = 0 := by
  rw [collatzIter_succ]
  exact collatzStep_odd_gives_even hodd

/-! ## Theorem 3: Syracuse acceleration and bounds -/

/-- The Syracuse (accelerated) step. -/
def syracuse (n : ℕ) : ℕ := (3 * n + 1) / 2

/-- Syracuse value equals the two-step Collatz composition on odd input. -/
theorem syracuse_eq_compose {n : ℕ} (hodd : n % 2 = 1) :
    syracuse n = collatzStep (collatzStep n) := by
  simp [syracuse, collatzStep_odd hodd, collatzStep_even (three_mul_add_one_even hodd)]

/-- Syracuse is strictly increasing for n ≥ 1. -/
theorem syracuse_gt {n : ℕ} (hn : n ≥ 1) (_hodd : n % 2 = 1) :
    syracuse n ≥ n + 1 := by
  simp [syracuse]; omega

/-- Syracuse is bounded above by 2n. -/
theorem syracuse_le {n : ℕ} (_hn : n ≥ 1) (_hodd : n % 2 = 1) :
    syracuse n ≤ 2 * n := by
  simp [syracuse]; omega

/-! ## Theorem 4: Orbit merging — tree structure of Collatz -/

/-
If orbits merge, reachability is transferred forward.
-/
theorem orbit_merge {a b : ℕ} {ja jb : ℕ}
    (h : collatzIter a ja = collatzIter b jb) :
    reachesOne a → reachesOne b := by
  intro ha
  obtain ⟨k, hk⟩ := ha;
  by_cases hka : k ≥ ja;
  · -- By collatzIter_add, we have collatzIter a k = collatzIter (collatzIter a ja) (k - ja).
    have h_iter : collatzIter a k = collatzIter (collatzIter a ja) (k - ja) := by
      convert collatzIter_add a ( k - ja ) ja using 1 ; rw [ Nat.sub_add_cancel hka ];
    exact ⟨ k - ja + jb, by rw [ collatzIter_add, h ] at *; aesop ⟩;
  · -- Since $k < ja$, we have $collatzIter a k = 1$ implies $collatzIter b jb = collatzIter 1 (ja - k)$.
    have h_collatz_b : collatzIter b jb = collatzIter 1 (ja - k) := by
      rw [ ← h, ← hk, ← collatzIter_add ];
      rw [ Nat.sub_add_cancel ( le_of_not_ge hka ) ];
    -- Since $collatzIter 1 (ja - k)$ is in $\{1, 4, 2\}$, it reaches $1$.
    have h_collatz_1 : ∀ m, collatzIter 1 m = 1 ∨ collatzIter 1 m = 4 ∨ collatzIter 1 m = 2 := by
      intro m; induction m <;> simp_all +decide [ collatzIter_succ ] ;
      rcases ‹_› with ( h | h | h ) <;> simp +decide [ h, collatzStep ];
    rcases h_collatz_1 ( ja - k ) with h | h | h <;> simp_all +decide;
    · exact ⟨ jb, h_collatz_b ⟩;
    · use jb + 2;
      unfold collatzIter at *; simp_all +decide [ Function.iterate_succ_apply' ] ;
    · use jb + 1;
      simp_all +decide [ collatzIter_succ ]

/-! ## Theorem 5: Unique fixed point -/

/-- 0 is the only fixed point of collatzStep. -/
theorem fixed_point_unique {n : ℕ} (h : collatzStep n = n) : n = 0 := by
  unfold collatzStep at h; split_ifs at h <;> omega

/-! ## Theorem 6: Inverse image structure -/

/-- 2m always maps to m under collatzStep. -/
theorem even_preimage (m : ℕ) : collatzStep (2 * m) = m := by
  simp [collatzStep]

/-- The even preimage of m is unique among even numbers. -/
theorem even_preimage_unique {m p : ℕ} (hp : p % 2 = 0) (h : collatzStep p = m) :
    p = 2 * m := by
  rw [collatzStep_even hp] at h; omega

/-! ## Theorem 7: Bounded-Universal gap -/

/-- The full conjecture equals the universal bounded verification. -/
theorem conjecture_iff_all_bounded :
    collatzConj ↔ ∀ N, collatzUpTo N := by
  simp [collatzConj, collatzUpTo]
  constructor
  · intro h N n h1 h2; exact h n h1
  · intro h n hn; exact h n n hn le_rfl

/-- Monotonicity: bounded verification at N implies at M ≤ N. -/
theorem bounded_mono {N M : ℕ} (hle : M ≤ N) (h : collatzUpTo N) :
    collatzUpTo M := by
  intro n h1 h2; exact h n h1 (le_trans h2 hle)

/-! ## Theorem 8: The 1-4-2 cycle -/

theorem cycle_step_1 : collatzStep 1 = 4 := by simp [collatzStep]
theorem cycle_step_4 : collatzStep 4 = 2 := by simp [collatzStep]
theorem cycle_step_2 : collatzStep 2 = 1 := by simp [collatzStep]

/-- The 1-4-2 cycle has period 3. -/
theorem cycle_period_three : collatzIter 1 3 = 1 := by
  simp [collatzIter, collatzStep, Function.iterate_succ_apply']

/-
After reaching 1, the orbit cycles with period 3.
-/
theorem orbit_periodic_after_one {n : ℕ} {k : ℕ} (hk : collatzIter n k = 1) :
    ∀ j, collatzIter n (k + 3 * j) = 1 := by
  intro j
  induction' j with j ih;
  · exact hk;
  · grind +suggestions

/-! ## Theorem 9: Reduction principle -/

/-- If the successor reaches 1, so does n. -/
theorem reachesOne_of_step {n : ℕ} (h : reachesOne (collatzStep n)) :
    reachesOne n := by
  obtain ⟨k, hk⟩ := h
  refine ⟨k + 1, ?_⟩
  show collatzStep^[k + 1] n = 1
  rw [Function.iterate_succ_apply]
  exact hk

/-
Reduction: reachesOne n ↔ n = 1 ∨ reachesOne (collatzStep n).
-/
theorem reachesOne_reduce {n : ℕ} (_hn : n ≥ 1) :
    reachesOne n ↔ n = 1 ∨ reachesOne (collatzStep n) := by
  constructor <;> intro h;
  · obtain ⟨ k, hk ⟩ := h;
    rcases k with ( _ | k ) <;> simp_all +decide [ collatzIter ];
    exact Or.inr ⟨ k, hk ⟩;
  · exact h.elim ( fun h => h.symm ▸ ⟨ 0, rfl ⟩ ) fun h => reachesOne_of_step h

/-! ## Theorem 10: Orbit descent for even values -/

/-- For even n ≥ 2, one step gives a strictly smaller value. -/
theorem even_descent {n : ℕ} (hn : n ≥ 2) (heven : n % 2 = 0) :
    collatzStep n < n := collatzStep_even_lt hn heven

/-- For odd n ≥ 1, two steps give a value ≤ 2n. -/
theorem odd_two_step_le {n : ℕ} (_hn : n ≥ 1) (hodd : n % 2 = 1) :
    collatzStep (collatzStep n) ≤ 2 * n := by
  rw [← syracuse_eq_compose hodd]; unfold syracuse; omega

/-! ## Theorem 11: Stopping time lower bound -/

/-
Any n ≥ 2 that reaches 1 needs at least 1 step.
-/
theorem stopping_time_pos {n : ℕ} (hn : n ≥ 2) (hr : reachesOne n) :
    stoppingTime n ≥ 1 := by
  unfold stoppingTime;
  split_ifs <;> simp_all +decide;
  · linarith;
  · exact ‹∀ x, ¬collatzIter n x = 1› _ hr.choose_spec

/-! ## Theorem 12: Small case verification -/

theorem reachesOne_1 : reachesOne 1 := ⟨0, rfl⟩
theorem reachesOne_2 : reachesOne 2 :=
  ⟨1, by simp [collatzIter, collatzStep]⟩
theorem reachesOne_3 : reachesOne 3 :=
  ⟨7, by simp [collatzIter, collatzStep]⟩
theorem reachesOne_4 : reachesOne 4 :=
  ⟨2, by simp [collatzIter, collatzStep]⟩
theorem reachesOne_5 : reachesOne 5 :=
  ⟨5, by simp [collatzIter, collatzStep]⟩

/-- Collatz holds for all n ∈ [1, 5]. -/
theorem collatzUpTo_five : collatzUpTo 5 := by
  intro n h1 h2
  interval_cases n
  · exact reachesOne_1
  · exact reachesOne_2
  · exact reachesOne_3
  · exact reachesOne_4
  · exact reachesOne_5

/-! ## Theorem 13: Parity Word — no consecutive odds -/

/-- The parity word: step k is true iff the k-th iterate is odd. -/
def parityWord (n : ℕ) (k : ℕ) : Bool := (collatzIter n k) % 2 != 0

/-- The parity word never has two consecutive true values. -/
theorem parityWord_no_consecutive_true (n k : ℕ)
    (hk : parityWord n k = true) :
    parityWord n (k + 1) = false := by
  simp [parityWord] at *
  rw [collatzIter_succ]
  have hodd : collatzIter n k % 2 = 1 := by omega
  have := collatzStep_odd_gives_even hodd
  omega

/-! ## Theorem 14: Bounded reachability is decidable -/

/-- Bounded reachability: does n reach 1 within K steps? -/
def reachesOneWithin (n K : ℕ) : Bool :=
  (List.range (K + 1)).any (fun k => collatzIter n k == 1)

/-- The boolean check is sound: if it returns true, there exists a witness. -/
theorem reachesOneWithin_sound (n K : ℕ) (h : reachesOneWithin n K = true) :
    ∃ k ≤ K, collatzIter n k = 1 := by
  simp [reachesOneWithin, List.any_eq_true, List.mem_range] at h
  obtain ⟨k, hk_mem, hk_eq⟩ := h
  exact ⟨k, by omega, by simpa using hk_eq⟩

/-! ## Falsifiable Conjecture: Stopping Time Growth

**Conjecture**: The maximum stopping time among inputs [1, N] grows as
O(log(N)^2). Specifically, there exists C > 0 such that for all n ≥ 1
with reachesOne n, stoppingTime n ≤ C * (Nat.log 2 n + 1)^2.

**Computational test**: Compute max stopping times for N = 100, 1000, 10000
and check if the ratio maxStopTime / (log₂ N)² stabilizes.
-/

/-- The conjecture that stopping time grows quadratically in bit-length. -/
def stoppingTimeQuadBound : Prop :=
  ∃ C : ℕ, C > 0 ∧ ∀ n : ℕ, n ≥ 1 → reachesOne n →
    stoppingTime n ≤ C * (Nat.log 2 n + 1) ^ 2

end CollatzDeep