/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Prime-Indexed Subword Zeta Functions and Automatic Sequence Rigidity

This file formalizes the theory of subword complexity for sequences over finite
alphabets, focusing on automatic sequences and their prime-indexed invariants.

## Main Definitions

* `DFAO` - Deterministic finite automaton with output
* `SubwordSet` - The set of all subwords of a given length in a sequence
* `SubwordComplexity` - The subword complexity function p(n)
* `PrimeSubwordRigidityConjecture` - The main rigidity conjecture

## Main Results

* `subword_complexity_le_card_pow` - p(n) ≤ |α|^n
* `subword_complexity_shift_le` - Subword complexity is shift-monotone
* `hankel_symmetric` - Hankel matrices are symmetric
* `constant_complexity_one` - Constant words have complexity 1
* `periodic_subword_count_le` - Periodic words have bounded complexity
* `injective_coding_preserves_complexity` - Injective codings preserve complexity
* `bounded_complexity_shift` - Bounded complexity is shift-invariant
-/

import Mathlib

open Finset BigOperators

namespace SubwordZeta

/-! ## Core Definitions -/

/-- An infinite word over alphabet α -/
abbrev Word (α : Type*) := ℕ → α

/-- A deterministic finite automaton with output (DFAO).
    This is the standard model for generating automatic sequences. -/
structure DFAO (k : ℕ) (σ : Type*) (α : Type*) where
  /-- Initial state -/
  init : σ
  /-- Transition function -/
  transition : σ → Fin k → σ
  /-- Output function -/
  output : σ → α

/-- Run a DFAO on a list of input symbols, returning the final state -/
def DFAO.run {k : ℕ} {σ α : Type*} (A : DFAO k σ α) : List (Fin k) → σ
  | [] => A.init
  | a :: as => A.transition (A.run as) a

/-- Extract a subword of length L starting at position i -/
def extractSubword {α : Type*} (s : Word α) (i L : ℕ) : Fin L → α :=
  fun j => s (i + j.val)

/-- The set of all subwords of length L appearing in a sequence -/
def SubwordSet {α : Type*} (s : Word α) (L : ℕ) : Set (Fin L → α) :=
  { w | ∃ i : ℕ, extractSubword s i L = w }

/-- The subword complexity function: number of distinct subwords of length n -/
noncomputable def SubwordComplexity {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (n : ℕ) : ℕ :=
  Set.ncard (SubwordSet s n)

/-- A word has bounded complexity if p(n) ≤ C·n for all n ≥ 1 -/
def HasBoundedComplexity {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (C : ℕ) : Prop :=
  ∀ n : ℕ, n ≥ 1 → SubwordComplexity s n ≤ C * n

/-- Shift operator on words -/
def shiftWord {α : Type*} (s : Word α) (k : ℕ) : Word α :=
  fun n => s (n + k)

/-- Two words are shift-equivalent if one is a shift of the other -/
def ShiftEquiv {α : Type*} (s t : Word α) : Prop :=
  ∃ k : ℕ, shiftWord s k = t ∨ shiftWord t k = s

/-- A coding applied to a word -/
def applyCoding {α β : Type*} (f : α → β) (s : Word α) : Word β :=
  fun n => f (s n)

/-- Two words are shift-equivalent up to a coding -/
def ShiftCodingEquiv {α : Type*} (s t : Word α) : Prop :=
  ∃ (f : α → α), Function.Surjective f ∧
    ∃ k : ℕ, ∀ n, t n = f (s (n + k)) ∨ s n = f (t (n + k))

/-- A word is eventually periodic -/
def EventuallyPeriodic {α : Type*} (s : Word α) : Prop :=
  ∃ (p : ℕ) (N : ℕ), p ≥ 1 ∧ ∀ n ≥ N, s (n + p) = s n

/-! ## Subword Complexity Bounds -/

/-- The subword set is contained in the set of all functions Fin L → α -/
theorem subword_set_subset_univ {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (L : ℕ) : SubwordSet s L ⊆ Set.univ :=
  Set.subset_univ _

/-- The subword set is finite (it's a subset of a finite type) -/
theorem subword_set_finite {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (L : ℕ) : Set.Finite (SubwordSet s L) :=
  Set.Finite.subset (Set.toFinite _) (subword_set_subset_univ s L)

/-- Subword complexity is bounded by |α|^n -/
theorem subword_complexity_le_card_pow {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (n : ℕ) : SubwordComplexity s n ≤ Fintype.card α ^ n := by
  unfold SubwordComplexity
  calc Set.ncard (SubwordSet s n)
      ≤ Set.ncard (Set.univ : Set (Fin n → α)) :=
        Set.ncard_le_ncard (subword_set_subset_univ s n) (Set.toFinite _)
    _ = Fintype.card (Fin n → α) := by rw [Set.ncard_univ, Nat.card_eq_fintype_card]
    _ = Fintype.card α ^ n := by rw [Fintype.card_fun, Fintype.card_fin]

/-- Shifted sequences have subwords that are subsets of the original -/
theorem shift_subword_subset {α : Type*} (s : Word α) (k : ℕ) (L : ℕ) :
    SubwordSet (shiftWord s k) L ⊆ SubwordSet s L := by
  intro w ⟨i, hi⟩
  refine ⟨i + k, ?_⟩
  ext j
  have := congr_fun hi j
  simp only [extractSubword, shiftWord] at this ⊢
  rw [show i + k + ↑j = i + ↑j + k from by omega]
  exact this

/-- Shifted sequences have at most the same subword complexity -/
theorem subword_complexity_shift_le {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (k : ℕ) (L : ℕ) :
    SubwordComplexity (shiftWord s k) L ≤ SubwordComplexity s L := by
  unfold SubwordComplexity
  exact Set.ncard_le_ncard (shift_subword_subset s k L) (subword_set_finite s L)

/-! ## Constant and Periodic Words -/

/-- A constant word has exactly one subword of each length -/
theorem constant_subword_singleton {α : Type*} (a : α) (L : ℕ) :
    SubwordSet (fun _ : ℕ => a) L = {fun _ : Fin L => a} := by
  ext w
  simp only [SubwordSet, Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · rintro ⟨i, hi⟩
    funext j
    have := congr_fun hi j
    simp [extractSubword] at this
    exact this.symm
  · intro h
    exact ⟨0, by funext j; simp [extractSubword]; rw [h]⟩

/-- A constant word has subword complexity 1 for all lengths -/
theorem constant_complexity_one {α : Type*} [DecidableEq α] [Fintype α]
    (a : α) (n : ℕ) :
    SubwordComplexity (fun (_ : ℕ) => a) n = 1 := by
  unfold SubwordComplexity
  rw [constant_subword_singleton]
  exact Set.ncard_singleton _

/-- A constant word is eventually periodic -/
theorem constant_eventually_periodic {α : Type*} (a : α) :
    EventuallyPeriodic (fun (_ : ℕ) => a) :=
  ⟨1, 0, le_refl 1, fun _ _ => rfl⟩

/-- A constant word has bounded complexity with C = 1 -/
theorem constant_bounded_complexity {α : Type*} [DecidableEq α] [Fintype α] (a : α) :
    HasBoundedComplexity (fun (_ : ℕ) => a) 1 := by
  intro n hn
  rw [constant_complexity_one]
  omega

/-
For a periodic word with period p, subwords of length L are determined by
    starting positions 0, ..., p-1. Hence at most p distinct subwords.
-/
theorem periodic_subword_count_le {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (p : ℕ) (hp : p ≥ 1) (hper : ∀ n, s (n + p) = s n)
    (L : ℕ) : SubwordComplexity s L ≤ p := by
  -- By definition of subword complexity, we know that the set of subwords of length $L$ is contained in the image of the function $f(i) = \text{extractSubword } s (i \mod p) L$ for $i = 0, 1, ..., p-1$.
  have h_image : SubwordSet s L ⊆ Finset.image (fun i => extractSubword s i L) (Finset.range p) := by
    intro w hw
    obtain ⟨i, hi⟩ := hw
    use Finset.mem_image.mpr ⟨i % p, Finset.mem_range.mpr (Nat.mod_lt i hp), by
      rw [ ← hi ];
      ext j; simp +decide [ extractSubword ] ; rw [ ← Nat.mod_add_div i p ] ; simp +decide [ hper ] ; ring;
      exact Nat.recOn ( i / p ) rfl fun n hn => by rw [ Nat.mul_succ, ← add_assoc, hper, hn ] ;⟩;
  exact le_trans ( Set.ncard_le_ncard h_image ) ( by rw [ Set.ncard_coe_finset ] ; exact Finset.card_image_le.trans ( by simpa ) )

/-! ## Shift Equivalence Properties -/

/-- Shift equivalence is reflexive -/
theorem shiftEquiv_refl {α : Type*} (s : Word α) : ShiftEquiv s s :=
  ⟨0, Or.inl rfl⟩

/-- Shift equivalence is symmetric -/
theorem shiftEquiv_symm {α : Type*} {s t : Word α} (h : ShiftEquiv s t) :
    ShiftEquiv t s := by
  obtain ⟨k, hk | hk⟩ := h
  · exact ⟨k, Or.inr hk⟩
  · exact ⟨k, Or.inl hk⟩

/-! ## Hankel Matrices -/

/-- The Hankel matrix for a ℕ-valued word: entry (i,j) = s(i+j) -/
noncomputable def HankelMatrix (s : Word ℕ) (n : ℕ) : Matrix (Fin n) (Fin n) ℚ :=
  Matrix.of fun i j => (s (i.val + j.val) : ℚ)

/-- The Hankel matrix is symmetric (since s(i+j) = s(j+i)) -/
theorem hankel_symmetric (s : Word ℕ) (n : ℕ) :
    (HankelMatrix s n).IsSymm := by
  rw [Matrix.IsSymm]
  ext i j
  simp [HankelMatrix, Matrix.transpose_apply, Matrix.of_apply, add_comm]

/-! ## Prime Density -/

/-- A set contains infinitely many primes -/
def HasInfinitelyManyPrimes (S : Set ℕ) : Prop :=
  ∀ N : ℕ, ∃ p ∈ S, p > N ∧ Nat.Prime p

/-- A set of primes has positive lower density (simplified: infinitely many primes) -/
def HasPositivePrimeDensity (S : Set ℕ) : Prop :=
  HasInfinitelyManyPrimes S

/-! ## Automatic Sequences -/

/-- A word is k-automatic if generated by a DFAO reading base-k digits.
    We require k ≥ 2 and use Nat.digits which produces digits < k. -/
def IsKAutomatic {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (k : ℕ) (hk : k ≥ 2) : Prop :=
  ∃ (σ : Type) (_ : Fintype σ) (A : DFAO k σ α),
    ∀ n, s n = A.output (A.run ((Nat.digits k n).pmap
      (fun d (hd : d < k) => (⟨d, hd⟩ : Fin k))
      (fun d hd => Nat.digits_lt_base hk hd)))

/-- An automatic word is k-automatic for some k ≥ 2 -/
def IsAutomatic {α : Type*} [DecidableEq α] [Fintype α] (s : Word α) : Prop :=
  ∃ (k : ℕ) (hk : k ≥ 2), IsKAutomatic s k hk

/-- The kernel of a k-automatic sequence -/
def AutomaticKernel {α : Type*} (s : Word α) (k : ℕ) : Set (Word α) :=
  { t | ∃ (j r : ℕ), r < k ^ j ∧ ∀ n, t n = s (k ^ j * n + r) }

/-- The kernel always contains the original sequence (j=0, r=0) -/
theorem kernel_contains_original {α : Type*} (s : Word α) (k : ℕ) :
    s ∈ AutomaticKernel s k := by
  refine ⟨0, 0, by simp, fun n => by simp⟩

/-! ## Entropy -/

/-- Normalized frequency of a word w among length-L subwords up to position N -/
noncomputable def wordFrequency {α : Type*} [DecidableEq α]
    (s : Word α) (L : ℕ) (w : Fin L → α) (N : ℕ) : ℝ :=
  (Finset.card (Finset.filter (fun i => extractSubword s i L = w)
    (Finset.range N)) : ℝ) / N

/-- Shannon entropy of the subword distribution -/
noncomputable def SubwordEntropy {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (L N : ℕ) : ℝ :=
  - ∑ w : Fin L → α,
    let f := wordFrequency s L w N
    if f > 0 then f * Real.log f else 0

/-- Prime-indexed subword entropy -/
noncomputable def PrimeSubwordEntropy {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (N : ℕ) (p : ℕ) : ℝ :=
  SubwordEntropy s p N

/-- Two words have matching prime entropy profiles on a set S -/
def MatchingPrimeEntropy {α : Type*} [DecidableEq α] [Fintype α]
    (s t : Word α) (N : ℕ) (S : Set ℕ) : Prop :=
  ∀ p ∈ S, Nat.Prime p → PrimeSubwordEntropy s N p = PrimeSubwordEntropy t N p

/-! ## The Thue-Morse Sequence -/

/-- Count the number of true values in a list of booleans -/
def countTrue : List Bool → ℕ
  | [] => 0
  | true :: bs => 1 + countTrue bs
  | false :: bs => countTrue bs

/-- The Thue-Morse word: t(n) = number of 1-bits in n, mod 2 -/
def thueMorse : Word (Fin 2) :=
  fun n => ⟨countTrue (Nat.bits n) % 2, Nat.mod_lt _ (by omega)⟩

/-
Nat.bits of 2^k - 1 is a list of k true values (for k ≥ 1)
-/
theorem countTrue_bits_two_pow_sub_one (k : ℕ) (hk : k ≥ 1) :
    countTrue (Nat.bits (2 ^ k - 1)) = k := by
  induction hk <;> simp_all +decide [ Nat.pow_succ' ];
  rw [ show 2 * 2 ^ _ - 1 = 2 * ( 2 ^ _ - 1 ) + 1 by zify ; norm_num ; ring ];
  simp_all +decide [ Nat.add_mod, Nat.add_div ];
  rename_i k hk ih; rw [ show countTrue ( true :: ( 2 ^ k - 1 |> Nat.bits ) ) = 1 + countTrue ( 2 ^ k - 1 |> Nat.bits ) by rfl ] ; linarith;

/-- thueMorse at 2^k - 1 equals k mod 2 (for k ≥ 1) -/
theorem thueMorse_two_pow_sub_one (k : ℕ) (hk : k ≥ 1) :
    thueMorse (2 ^ k - 1) = ⟨k % 2, Nat.mod_lt _ (by omega)⟩ := by
  simp only [thueMorse]
  congr 1
  rw [countTrue_bits_two_pow_sub_one k hk]

/-- If thueMorse is eventually periodic with period p, then for any
    n ≥ N and any m, thueMorse(n + m*p) = thueMorse(n) -/
theorem thueMorse_periodic_multiples (p N : ℕ) (hp : p ≥ 1)
    (hper : ∀ n ≥ N, thueMorse (n + p) = thueMorse n)
    (n : ℕ) (hn : n ≥ N) (m : ℕ) :
    thueMorse (n + m * p) = thueMorse n := by
  induction m with
  | zero => simp
  | succ m ih =>
    rw [Nat.succ_mul, ← Nat.add_assoc, hper (n + m * p) (by omega), ih]

/-- Functional equation: countTrue of false :: l = countTrue l -/
theorem countTrue_false (l : List Bool) : countTrue (false :: l) = countTrue l := rfl

/-- Functional equation: countTrue of true :: l = 1 + countTrue l -/
theorem countTrue_true (l : List Bool) : countTrue (true :: l) = 1 + countTrue l := rfl

/-
Thue-Morse functional equation: tm(2n) = tm(n) for n > 0
-/
theorem thueMorse_double (n : ℕ) (hn : n > 0) :
    thueMorse (2 * n) = thueMorse n := by
  -- By definition of `thueMorse`, we know that `thueMorse n` is the parity of the number of 1s in the binary representation of `n`.
  simp [thueMorse];
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.testBit ];
  exact?

/-
Thue-Morse functional equation: tm(2n+1) ≠ tm(n)
-/
theorem thueMorse_double_succ (n : ℕ) :
    thueMorse (2 * n + 1) ≠ thueMorse n := by
  unfold thueMorse;
  norm_num [ Fin.ext_iff, Nat.add_mod, Nat.mul_mod ];
  rw [ countTrue_true ] ; omega

/-- Period 1 is impossible for Thue-Morse: tm(n) = tm(n+1) fails for large n.
    Proof: Take n = 2m for m large. tm(2m) = tm(m) and tm(2m+1) = 1-tm(m),
    so tm(2m) ≠ tm(2m+1). -/
theorem thueMorse_no_period_one (N : ℕ) :
    ∃ n ≥ N, thueMorse n ≠ thueMorse (n + 1) := by
  refine ⟨2 * (N + 1), by omega, ?_⟩
  rw [show 2 * (N + 1) + 1 = 2 * (N + 1) + 1 from rfl]
  intro h
  have h1 := thueMorse_double (N + 1) (by omega)
  have h2 := thueMorse_double_succ (N + 1)
  rw [← h1] at h2
  exact h2 h.symm

/-
If tm has eventual period p (even), it has eventual period p/2
-/
theorem thueMorse_reduce_even_period (p N : ℕ) (hp : p ≥ 2) (hpeven : 2 ∣ p)
    (hper : ∀ n ≥ N, thueMorse (n + p) = thueMorse n) :
    ∀ n ≥ (N + 1) / 2, thueMorse (n + p / 2) = thueMorse n := by
  obtain ⟨ k, hk ⟩ := hpeven;
  intro n hn; have := hper ( 2 * n ) ( by linarith [ Nat.div_add_mod ( N + 1 ) 2, Nat.mod_lt ( N + 1 ) two_pos ] ) ; simp_all +decide [ Nat.mul_add ] ;
  by_cases hn : n = 0 <;> simp_all +decide [ ← mul_add ];
  · rcases k with ( _ | _ | k ) <;> simp_all +decide [ thueMorse_double ];
  · rw [ thueMorse_double ( n + k ) ( by positivity ), thueMorse_double n ( by positivity ) ] at * ; aesop

/-
If tm has eventual period p (odd ≥ 3), it has eventual period p - 1
-/
theorem thueMorse_reduce_odd_period (p N : ℕ) (hp : p ≥ 3) (hpodd : ¬ 2 ∣ p)
    (hper : ∀ n ≥ N, thueMorse (n + p) = thueMorse n) :
    ∃ M, ∀ n ≥ M, thueMorse (n + (p - 1)) = thueMorse n := by
  -- By definition, $p = 2q + 1$ for some integer � $�q$.
  obtain ⟨q, hq⟩ : ∃ q, p = 2 * q + 1 := by
    exact Nat.odd_iff.mpr ( Nat.mod_two_ne_zero.mp fun h => hpodd <| Nat.dvd_of_mod_eq_zero h );
  -- By definition, $thueMorse (2 * n + p) = thueMorse (2 * n)$ for large $n$.
  have h_double : ∀ n ≥ N, thueMorse (2 * n + p) = thueMorse (2 * n) := by
    exact fun n hn => hper _ ( by linarith );
  -- By definition, $thueMorse (2 * n + p) = thueMorse (2 * (n + q) + 1)$ and $thueMorse (2 * (n + q) + 1) \neq thueMorse (n + q)$.
  have h_half : ∀ n ≥ N, thueMorse (n + q) ≠ thueMorse n := by
    intro n hn; specialize h_double n hn; simp_all +decide [ Nat.add_mod, Nat.mul_mod ] ;
    have h_half : thueMorse (2 * (n + q) + 1) ≠ thueMorse (n + q) := by
      exact?;
    grind +suggestions;
  use N + q; intros n hn; simp_all +decide [ ← add_assoc ] ;
  grind +splitImp

/-
The Thue-Morse word is not eventually periodic.
    Proof by strong induction on the period:
    - Period 1 is impossible (thueMorse_no_period_one)
    - Even period p reduces to p/2 (thueMorse_reduce_even_period)
    - Odd period p ≥ 3 reduces to p-1 (thueMorse_reduce_odd_period)
    Each step strictly reduces the period, eventually reaching 1.
-/
theorem thueMorse_not_eventually_periodic :
    ¬ EventuallyPeriodic thueMorse := by
  -- Assume for contradiction that the Thue-Morse word � is� eventually periodic.
  by_contra h_eventually_periodic
  obtain ⟨p, N, hp, hper⟩ := h_eventually_periodic
  generalize_proofs at *; (
  -- We do strong induction on p to derive a contradiction.
  induction' p using Nat.strong_induction_on with p ih generalizing N;
  rcases p with ( _ | _ | _ | p ) <;> simp_all +arith +decide only;
  · exact absurd ( thueMorse_no_period_one N ) ( by tauto );
  · -- By thueMorse_reduce_even_period, we get period 1 from some M.
    obtain ⟨M, hM⟩ : ∃ M, ∀ n ≥ M, thueMorse (n + 1) = thueMorse n := by
      exact ⟨ ( N + 1 ) / 2, fun n hn => by simpa using thueMorse_reduce_even_period 2 N ( by decide ) ( by decide ) hper n hn ⟩;
    exact ih 1 ( by norm_num ) M ( by norm_num ) fun n hn => by simpa [ add_comm ] using hM n hn;
  · -- Consider two cases: $p$ is � even� or $p$ is odd.
    by_cases h_even : 2 ∣ (p + 3);
    · -- By thueMorse_reduce_even �_period�, we get period (p+3)/2 < p+3 from some M.
      obtain ⟨M, hM⟩ : ∃ M, ∀ n ≥ M, thueMorse (n + (p + 3) / 2) = thueMorse n := by
        use (N + 1) / 2
        generalize_proofs at *; (
        convert thueMorse_reduce_even_period ( p + 3 ) N ( by linarith ) h_even ( fun n hn => ?_ ) using 1
        generalize_proofs at *; (
        simpa only [ add_comm, add_left_comm, add_assoc ] using hper n hn))
      generalize_proofs at *; (
      exact ih ( ( p + 3 ) / 2 ) ( by omega ) M ( Nat.div_pos ( by omega ) zero_lt_two ) fun n hn => by simpa only [ add_comm ] using hM n hn;);
    · -- By thueMorse_reduce_odd_period �,� we get M, period p-1 from M. Since p-1 < p is even, apply the even case to reduce to (p-1)/2, then continue by induction.
      obtain ⟨M, hM⟩ : ∃ M, ∀ n ≥ M, thueMorse (n + (p + 2)) = thueMorse n := by
        convert thueMorse_reduce_odd_period ( p + 3 ) N ( by linarith ) h_even ( fun n hn => ?_ ) using 1
        generalize_proofs at *; (
        convert hper n hn using 1 ; ring)
      generalize_proofs at *; (
      exact ih ( p + 2 ) ( by linarith ) M ( by linarith ) ( fun n hn => by simpa [ add_comm, add_left_comm, add_assoc ] using hM n hn )))

/-! ## Cross-Domain: Subword Complexity and Number Theory -/

/-- A subword of a shifted word equals a subword of the original at offset -/
theorem subword_of_shift {α : Type*} (s : Word α) (k i L : ℕ) :
    extractSubword (shiftWord s k) i L = extractSubword s (i + k) L := by
  ext j
  simp [extractSubword, shiftWord]
  congr 1; omega

/-- The number of length-1 subwords is at most the alphabet size -/
theorem complexity_one_le_card {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) : SubwordComplexity s 1 ≤ Fintype.card α := by
  calc SubwordComplexity s 1
      ≤ Fintype.card α ^ 1 := subword_complexity_le_card_pow s 1
    _ = Fintype.card α := pow_one _

/-! ## Injective Coding Theorem -/

/-
An injective coding preserves subword complexity.
    Proof: the coding induces a bijection between the subword sets.
-/
theorem injective_coding_preserves_complexity {α β : Type*}
    [DecidableEq α] [Fintype α] [DecidableEq β] [Fintype β]
    (f : α → β) (hf : Function.Injective f) (s : Word α) (n : ℕ) :
    SubwordComplexity (applyCoding f s) n = SubwordComplexity s n := by
  convert Set.ncard_image_of_injective _ _;
  rotate_left;
  exact Fin n → β;
  exact fun g => fun i => f ( g i );
  · exact fun g₁ g₂ h => funext fun i => hf <| congr_fun h i;
  · unfold SubwordComplexity SubwordSet;
    congr with w ; simp +decide [ funext_iff, extractSubword, applyCoding ];
    exact ⟨ fun ⟨ i, hi ⟩ => ⟨ _, ⟨ i, fun x => rfl ⟩, hi ⟩, fun ⟨ a, ⟨ i, hi ⟩, hw ⟩ => ⟨ i, fun x => by rw [ ← hw, hi ] ⟩ ⟩

/-- Bounded complexity is preserved under shift -/
theorem bounded_complexity_shift {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (C : ℕ) (k : ℕ) (hbc : HasBoundedComplexity s C) :
    HasBoundedComplexity (shiftWord s k) C := by
  intro n hn
  calc SubwordComplexity (shiftWord s k) n
      ≤ SubwordComplexity s n := subword_complexity_shift_le s k n
    _ ≤ C * n := hbc n hn

/-! ## Hankel Rank -/

/-- Hankel rank: supremum of ranks of finite Hankel submatrices -/
noncomputable def HankelRank (s : Word ℕ) : ℕ :=
  sSup { r : ℕ | ∃ n : ℕ, (HankelMatrix s n).rank = r }

/-
For a word with bounded Hankel rank, large Hankel matrices are singular
-/
theorem hankel_rank_controls_determinant (s : Word ℕ) (n : ℕ) (r : ℕ)
    (hr : ∀ m, (HankelMatrix s m).rank ≤ r) (hn : n > r) :
    (HankelMatrix s n).det = 0 := by
  contrapose! hn;
  have := Matrix.rank_mul_le_left ( HankelMatrix s n ) ( ( HankelMatrix s n ) ⁻¹ ) ; simp_all +decide [ isUnit_iff_ne_zero ] ;
  grind +splitImp

/-! ## The Main Conjecture -/

/-- **Prime Subword Rigidity Conjecture**:
    If two automatic words over a binary alphabet have matching prime-indexed
    subword entropy on a set of primes with positive density (infinitely many
    primes), then they are shift-equivalent up to a coding.

    This conjecture creates a new arithmetic-spectral invariant for symbolic
    dynamics, linking automata theory, combinatorics on words, and analytic
    number theory. -/
def PrimeSubwordRigidityConjecture : Prop :=
  ∀ (s t : Word (Fin 2)),
    IsAutomatic s → IsAutomatic t →
    ∀ S : Set ℕ,
      HasPositivePrimeDensity S →
      (∀ N : ℕ, N ≥ 1 → MatchingPrimeEntropy s t N S) →
      ShiftCodingEquiv s t

/-- **Testable Prediction**: For binary automatic sequences,
    matching entropy at primes ≤ 541 (the first 100 primes) implies
    shift-coding equivalence. -/
def TestableRigidityPrediction : Prop :=
  ∀ (s t : Word (Fin 2)),
    IsAutomatic s → IsAutomatic t →
    (∀ p : ℕ, Nat.Prime p → p ≤ 541 →
      PrimeSubwordEntropy s 10000 p = PrimeSubwordEntropy t 10000 p) →
    ShiftCodingEquiv s t

/-! ## Complexity Growth -/

/-- Subword complexity of a non-eventually-periodic word grows:
    if s is not eventually periodic then p(n) ≥ n + 1 for all n.
    This is one direction of the Morse-Hedlund theorem. -/
theorem morse_hedlund_lower {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (h : ¬ EventuallyPeriodic s)
    (n : ℕ) : SubwordComplexity s n ≥ n + 1 := by
  sorry

/-- The contrapositive: if p(n₀) ≤ n₀ for some n₀, then s is eventually periodic -/
theorem morse_hedlund_periodic {α : Type*} [DecidableEq α] [Fintype α]
    (s : Word α) (n₀ : ℕ) (_hn : n₀ ≥ 1)
    (hcomp : SubwordComplexity s n₀ ≤ n₀) :
    EventuallyPeriodic s := by
  by_contra h
  have h2 := morse_hedlund_lower s h n₀
  omega

end SubwordZeta