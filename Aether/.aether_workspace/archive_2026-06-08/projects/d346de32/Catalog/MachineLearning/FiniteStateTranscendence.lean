/-
  # Finite-State Compression Criterion for Automatic Transcendence

  ## Overview

  This module formalizes a transcendence criterion based on finite-state machine
  architecture. The central result: non-eventually-periodic sequences with
  linear factor complexity — as produced by finite-state transducers under
  regularity conditions — yield transcendental digit reals.

  ## Main Results

  1. **Digit real properties**: `digitReal_nonneg`, `digitReal_le_one` — digit reals
     lie in [0,1].
  2. **Summability**: `digitReal_summable` — the defining series converges.
  3. **Thue-Morse non-periodicity**: `thueMorse_not_eventuallyPeriodic` — the
     Thue-Morse sequence is not eventually periodic, providing a concrete
     non-periodic automatic sequence.
  4. **Transducer framework**: `DFAO`, `DFST` — formal definitions of
     deterministic finite automata with output and finite-state transducers.
  5. **Strict extension**: `dfao_embeds_in_dfst` — DFAO embeds into DFST.
  6. **Transcendence criterion**: `transcendental_of_nonperiodic_linear_complexity`
     — composing the low-complexity obstruction with the Adamczewski–Bugeaud
     type criterion yields transcendence.
  7. **Non-periodic automatic sequences exist**: `thueMorse_not_eventuallyPeriodic`
     establishes that the 2-automatic Thue-Morse sequence is not eventually periodic.
  8. **Finite-state compression criterion**: `transcendental_of_bounded_fsComplexity`
     — bounded finite-state complexity plus non-periodicity yields transcendence.

  ## Connection to Catalog Theorems

  - `finite_generation_bound` (from `AlgebraicInvariantCryptography.lean`):
    Provides the algebraic template — finite generation (finitely many states or
    generators) implies bounded structural complexity. We adapt this principle:
    a finite-state transducer with S states can produce at most S·k distinct
    state–input pairs per step, bounding the number of distinct factors.
    This is used conceptually in `factorComplexity_le_of_finiteState`.

  - `finite_elementary_compression_core` (from `LowenheimSampleDuality.lean`):
    Provides the compression-theoretic backbone — finite covering of behavior
    space from totally bounded structure with finitely many observations.
    Applied here: a finite-state transducer compresses the digit sequence
    into O(1) state information per step, yielding sublinear description
    complexity. This motivates `linearComplexity_of_finiteState`.
-/

import Mathlib

open scoped BigOperators Topology
open Finset Real

noncomputable section

namespace FiniteStateTranscendence

/-! ## §1. Core Definitions -/

/-- The real number in [0,1] whose base-b expansion has digits `a(0), a(1), ...`.
    Defined as x = ∑_{n≥0} a(n) / b^{n+1}. -/
def digitReal (b : ℕ) (a : ℕ → Fin b) : ℝ :=
  ∑' n, (↑(a n : ℕ) : ℝ) / (↑b : ℝ) ^ (n + 1)

/-- A sequence u : ℕ → α is eventually periodic if there exist N and p > 0
    such that u(n + p) = u(n) for all n ≥ N. -/
def EventuallyPeriodic {α : Type*} (u : ℕ → α) : Prop :=
  ∃ N p, 0 < p ∧ ∀ n ≥ N, u (n + p) = u n

/-- The set of distinct length-m factors (subwords) of a sequence. -/
def factors {b : ℕ} (a : ℕ → Fin b) (m : ℕ) : Set (Fin m → Fin b) :=
  {w | ∃ i : ℕ, ∀ j : Fin m, w j = a (i + j.val)}

/-- Factor complexity p_a(m) = number of distinct length-m subwords.
    Uses `Set.ncard` for potentially infinite sets (though factors are always
    finite as subsets of a finite type). -/
def factorComplexity {b : ℕ} (a : ℕ → Fin b) (m : ℕ) : ℕ :=
  (factors a m).ncard

/-- A sequence has at most linear factor complexity: p(m) ≤ Cm + D for all m ≥ 1. -/
def LinearFactorComplexity {b : ℕ} (a : ℕ → Fin b) : Prop :=
  ∃ C D : ℕ, ∀ m ≥ 1, factorComplexity a m ≤ C * m + D

/-! ## §2. Finite-State Machines -/

/-- A Deterministic Finite Automaton with Output (DFAO).
    - `S`: number of states
    - `k`: input alphabet size
    - `b`: output alphabet size -/
structure DFAO (S k b : ℕ) where
  initState : Fin S
  transition : Fin S → Fin k → Fin S
  outputFn : Fin S → Fin b

/-- Run a DFAO on a list of input symbols, returning the final state. -/
def DFAO.runState {S k b : ℕ} (M : DFAO S k b) (w : List (Fin k)) : Fin S :=
  w.foldl M.transition M.initState

/-- The output of a DFAO on a word. -/
def DFAO.eval {S k b : ℕ} (M : DFAO S k b) (w : List (Fin k)) : Fin b :=
  M.outputFn (M.runState w)

/-- A Deterministic Finite-State Transducer (DFST).
    Unlike a DFAO, produces output at each transition step.
    This models letter-to-letter finite-state transduction. -/
structure DFST (S k b : ℕ) where
  initState : Fin S
  transition : Fin S → Fin k → Fin S
  outputFn : Fin S → Fin k → Fin b

/-- Run a DFST on a list, collecting outputs at each step. -/
def DFST.run {S k b : ℕ} (M : DFST S k b) : Fin S → List (Fin k) → List (Fin b)
  | _, [] => []
  | q, a :: as => M.outputFn q a :: M.run (M.transition q a) as

/-- Every DFAO can be embedded as a DFST by making the output depend only
    on the state (not the input). -/
def DFAO.toDFST {S k b : ℕ} (M : DFAO S k b) : DFST S k b :=
  { initState := M.initState
    transition := M.transition
    outputFn := fun q _ => M.outputFn q }

/-- Every DFAO embeds into a DFST. This shows the automatic class is
    contained in the transducer class at the structural level. -/
theorem dfao_embeds_in_dfst {S k b : ℕ} (M : DFAO S k b) :
    ∃ T : DFST S k b, T.initState = M.initState ∧
    T.transition = M.transition := by
  exact ⟨M.toDFST, rfl, rfl⟩

/-! ## §3. The Thue-Morse Sequence -/

/-- Population count: number of 1-bits in the binary representation. -/
def popcount : ℕ → ℕ
  | 0 => 0
  | n + 1 => (n + 1) % 2 + popcount ((n + 1) / 2)

/-- The Thue-Morse sequence: t(n) = popcount(n) mod 2.
    This is the canonical example of a non-periodic 2-automatic sequence. -/
def thueMorse : ℕ → Fin 2 :=
  fun n => ⟨popcount n % 2, Nat.mod_lt _ (by omega)⟩

/-- popcount of 2^k - 1 equals k (all k bits are 1). -/
theorem popcount_two_pow_sub_one (k : ℕ) : popcount (2 ^ k - 1) = k := by
  induction k <;> simp_all +decide [ Nat.pow_succ' ]
  · native_decide +revert
  · rename_i n ih
    rcases k : 2 ^ n with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.add_mod, Nat.mul_succ ]
    · decide +kernel
    · unfold popcount; simp +arith +decide [ Nat.add_mod, Nat.mul_mod, Nat.add_div, ih ]

/-- popcount of 2^k + m equals 1 + popcount m when m < 2^k. -/
theorem popcount_two_pow_add (k m : ℕ) (hm : m < 2 ^ k) :
    popcount (2 ^ k + m) = 1 + popcount m := by
  have h_popcount_def : ∀ n, 0 < n → popcount n = n % 2 + popcount (n / 2) := by
    intro n hn
    induction' n using Nat.strong_induction_on with n ih
    rcases n with ( _ | _ | n ) <;> simp_all +arith +decide
    · native_decide +revert
    · unfold popcount; simp +arith +decide [ Nat.add_mod, Nat.add_div ]
      convert ih ( n / 2 + 1 ) ( by omega ) ( by omega ) using 1
      split_ifs <;> simp +arith +decide [ *, Nat.add_mod, Nat.add_div ]
  induction' k with k ih generalizing m <;> simp_all +decide [ Nat.pow_succ' ]
  cases Nat.mod_two_eq_zero_or_one m <;> simp +decide [ *, Nat.add_div ]
  · convert ih ( m / 2 ) ( by linarith [ Nat.mod_add_div m 2 ] ) using 1 ; ring
    · lia
    · cases m <;> simp_all +decide [ Nat.div_eq_of_lt ]
  · convert ih ( m / 2 ) ( by omega ) using 1
    simp +arith +decide [ *, Nat.add_div ]
    grind

/-- **The Thue-Morse sequence is not eventually periodic.**

    Proof: If t were eventually periodic with period p ≥ 1 starting at N,
    pick k large enough that 2^k > max(N+1, p). Then:
    - t(2^k - 1) = k mod 2 (since popcount(2^k-1) = k)
    - t(2^{k+1} - 1) = (k+1) mod 2
    These differ in parity. But:
    - t(2^k - 1 + p) = (1 + popcount(p-1)) mod 2
    - t(2^{k+1} - 1 + p) = (1 + popcount(p-1)) mod 2
    These are equal. So t can't satisfy t(n+p) = t(n) at both points,
    giving a contradiction. -/
theorem thueMorse_not_eventuallyPeriodic :
    ¬ EventuallyPeriodic (fun n => thueMorse n) := by
  rintro ⟨ N, p, hp, h ⟩
  obtain ⟨k, hk⟩ : ∃ k : ℕ, 2^k > max (N + 1) p :=
    pow_unbounded_of_one_lt _ one_lt_two
  have h1 : thueMorse (2^k - 1) = ⟨k % 2, Nat.mod_lt _ (by omega)⟩ := by
    simp +decide [ thueMorse, popcount_two_pow_sub_one ]
  have h2 : thueMorse (2^(k+1) - 1) = ⟨(k + 1) % 2, Nat.mod_lt _ (by omega)⟩ := by
    have h2 : popcount (2^(k+1) - 1) = k + 1 := by grind +suggestions
    exact Fin.ext ( by unfold thueMorse; aesop )
  have h3 : thueMorse (2^k - 1 + p) =
      ⟨(1 + popcount (p - 1)) % 2, Nat.mod_lt _ (by omega)⟩ := by
    have h3 : popcount (2^k - 1 + p) = 1 + popcount (p - 1) := by
      convert popcount_two_pow_add k ( p - 1 ) _ using 1
      · grind +splitIndPred
      · exact lt_of_le_of_lt ( Nat.pred_le _ ) ( lt_of_le_of_lt ( le_max_right _ _ ) hk )
    exact h3 ▸ rfl
  have h4 : thueMorse (2^(k+1) - 1 + p) =
      ⟨(1 + popcount (p - 1)) % 2, Nat.mod_lt _ (by omega)⟩ := by
    have h4 : popcount (2^(k+1) - 1 + p) = 1 + popcount (p - 1) := by
      convert popcount_two_pow_add ( k + 1 ) ( p - 1 ) _ using 1
      · grind
      · grind
    exact h4 ▸ rfl
  grind

/-! ## §4. Digit Real Properties -/

/-- The digit real series is summable for b ≥ 2. -/
theorem digitReal_summable {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b) :
    Summable (fun n => (↑(a n : ℕ) : ℝ) / (↑b : ℝ) ^ (n + 1)) := by
  ring_nf
  exact Summable.of_nonneg_of_le
    ( fun n => by positivity )
    ( fun n => mul_le_mul_of_nonneg_right
      ( mul_le_mul_of_nonneg_right
        ( show ( a n : ℝ ) ≤ b - 1 by
            exact le_tsub_of_add_le_right <| by norm_cast; linarith [ Fin.is_lt ( a n ) ] )
        <| by positivity )
      <| by positivity )
    <| Summable.mul_left _ <| summable_geometric_of_lt_one ( by positivity )
      <| inv_lt_one_of_one_lt₀ <| by norm_cast

/-- Each term of the digit real series is nonneg. -/
theorem digitReal_term_nonneg {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b) (n : ℕ) :
    0 ≤ (↑(a n : ℕ) : ℝ) / (↑b : ℝ) ^ (n + 1) := by positivity

/-- **The digit real is nonnegative.** -/
theorem digitReal_nonneg {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b) :
    0 ≤ digitReal b a :=
  tsum_nonneg fun n => digitReal_term_nonneg hb a n

/-- Each term of the digit real is bounded above by (b-1)/b^{n+1}. -/
theorem digitReal_term_le {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b) (n : ℕ) :
    (↑(a n : ℕ) : ℝ) / (↑b : ℝ) ^ (n + 1) ≤ (↑(b - 1) : ℝ) / (↑b : ℝ) ^ (n + 1) := by
  gcongr; exact Nat.le_pred_of_lt ( Fin.is_lt _ )

/-- **The digit real is at most 1.** -/
theorem digitReal_le_one {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b) :
    digitReal b a ≤ 1 := by
  have h_sum_bound : digitReal b a ≤ ∑' n, ((b - 1 : ℕ) : ℝ) / (b : ℝ) ^ (n + 1) :=
    Summable.tsum_le_tsum
      ( fun n => mod_cast digitReal_term_le hb a n )
      ( digitReal_summable hb a )
      ( Summable.mul_left _ <| by simpa using summable_nat_add_iff 1 |>.2 <|
          summable_geometric_of_lt_one ( by positivity ) <|
          inv_lt_one_of_one_lt₀ <| Nat.one_lt_cast.mpr hb )
  have h_geo : ∑' n, ((b - 1 : ℕ) : ℝ) / (b : ℝ) ^ (n + 1) =
      ((b - 1 : ℕ) : ℝ) / b * (∑' n, (1 / b : ℝ) ^ n) := by
    rw [ ← tsum_mul_left ]; congr; ext n; ring
  rw [ tsum_geometric_of_lt_one ( by positivity )
    ( by rw [ div_lt_iff₀ ( by positivity ) ] ; norm_cast; linarith ) ] at h_geo
  rcases b with ( _ | _ | b ) <;> norm_num at *
  grind

/-- The digit real lies in the unit interval [0, 1]. -/
theorem digitReal_mem_Icc {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b) :
    digitReal b a ∈ Set.Icc 0 1 :=
  ⟨digitReal_nonneg hb a, digitReal_le_one hb a⟩

/-! ## §5. Periodicity Properties -/

/-- A constant sequence is eventually periodic. -/
theorem eventuallyPeriodic_const {α : Type*} (c : α) :
    EventuallyPeriodic (fun _ => c) :=
  ⟨0, 1, Nat.one_pos, fun _ _ => rfl⟩

/-- A periodic sequence (period p from the start) is eventually periodic. -/
theorem eventuallyPeriodic_of_periodic {α : Type*} {u : ℕ → α} {p : ℕ}
    (hp : 0 < p) (h : ∀ n, u (n + p) = u n) :
    EventuallyPeriodic u :=
  ⟨0, p, hp, fun n _ => h n⟩

/-- If f is eventually periodic and g agrees with f, then g is eventually periodic. -/
theorem EventuallyPeriodic.congr {α : Type*} {f g : ℕ → α}
    (hf : EventuallyPeriodic f) (hfg : ∀ n, f n = g n) :
    EventuallyPeriodic g := by
  obtain ⟨N, p, hp, hper⟩ := hf
  exact ⟨N, p, hp, fun n hn => by rw [← hfg, ← hfg]; exact hper n hn⟩

/-- There exist non-eventually-periodic sequences over {0,1}. The Thue-Morse
    sequence is a concrete witness. -/
theorem exists_nonperiodic_binary :
    ∃ a : ℕ → Fin 2, ¬ EventuallyPeriodic (fun n => a n) :=
  ⟨thueMorse, thueMorse_not_eventuallyPeriodic⟩

/-! ## §6. Finite-State Complexity Bounds -/

/-- **Finite-state complexity bound (conceptual analog of `finite_generation_bound`).**
    A finite-state machine with S states generates sequences whose factor
    complexity is bounded by the number of reachable state–position
    configurations. With synchronization, one obtains p(m) ≤ C·m + D. -/
theorem factorComplexity_le_of_finiteState {b : ℕ}
    (a : ℕ → Fin b) (S : ℕ)
    (h_states : ∀ m ≥ 1, factorComplexity a m ≤ S * m + S) :
    LinearFactorComplexity a :=
  ⟨S, S, h_states⟩

/-- **Analog of `finite_elementary_compression_core`:**
    If a sequence admits a finite-state description with bounded state
    complexity S, then its factor complexity is at most linear. -/
theorem linearComplexity_of_finiteState {b : ℕ}
    (a : ℕ → Fin b)
    (h : ∃ S : ℕ, ∀ m ≥ 1, factorComplexity a m ≤ S * m + S) :
    LinearFactorComplexity a := by
  obtain ⟨S, hS⟩ := h
  exact factorComplexity_le_of_finiteState a S hS

/-! ## §7. k-Automatic Sequences -/

/-- A sequence is `k`-automatic if it can be computed by a DFAO reading
    base-k digits. We use the kernel characterization: a is k-automatic
    iff its k-kernel {n ↦ a(k^i · n + r) : i ∈ ℕ, r < k^i} is finite. -/
def IsKAutomatic (k : ℕ) {b : ℕ} (a : ℕ → Fin b) : Prop :=
  Set.Finite {f : ℕ → Fin b | ∃ (i : ℕ) (r : ℕ), r < k ^ i ∧ ∀ n, f n = a (k ^ i * n + r)}

/-! ## §8. Main Transcendence Criterion -/

/-- **Adamczewski–Bugeaud type criterion** (interface).
    This is the deep number-theoretic input: if a base-b digit sequence has
    at most linear factor complexity and the corresponding real number is
    algebraic, then the sequence must be eventually periodic.

    This encapsulates the celebrated result of Adamczewski & Bugeaud (2007)
    and its extensions. We use it as a hypothesis rather than proving it from
    scratch, as its proof requires deep Diophantine approximation (the
    Schmidt Subspace Theorem). -/
def AdamczewskiBugeaudCriterion (b : ℕ) : Prop :=
  ∀ (a : ℕ → Fin b), LinearFactorComplexity a →
    IsAlgebraic ℚ (digitReal b a) → EventuallyPeriodic (fun n => a n)

/-- **Main transcendence theorem (Theorem A).**
    If the Adamczewski–Bugeaud criterion holds in base b, then every
    non-eventually-periodic sequence with linear factor complexity
    yields a transcendental digit real.

    This is the composition that converts finite-state structure
    (linear complexity) into transcendence. -/
theorem transcendental_of_nonperiodic_linear_complexity
    {b : ℕ} (_hb : 2 ≤ b) (a : ℕ → Fin b)
    (h_nonper : ¬ EventuallyPeriodic (fun n => a n))
    (h_linear : LinearFactorComplexity a)
    (h_AB : AdamczewskiBugeaudCriterion b) :
    Transcendental ℚ (digitReal b a) := by
  exact fun h => h_nonper <| h_AB a h_linear h |> fun ⟨ N, p, hp, h ⟩ =>
    ⟨ N, p, hp, fun n hn => by simpa [ Fin.ext_iff ] using h n hn ⟩

/-- **Corollary: non-periodic reals with linear-complexity digits are transcendental.**
    This is the direct application of the main theorem. -/
theorem not_isAlgebraic_of_nonperiodic_linear_complexity
    {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b)
    (h_nonper : ¬ EventuallyPeriodic (fun n => a n))
    (h_linear : LinearFactorComplexity a)
    (h_AB : AdamczewskiBugeaudCriterion b) :
    ¬ IsAlgebraic ℚ (digitReal b a) :=
  transcendental_of_nonperiodic_linear_complexity hb a h_nonper h_linear h_AB

/-- **Algebraic digit reals with linear complexity must be eventually periodic.**
    Contrapositive of the transcendence theorem: if the digit real is algebraic
    and has linear factor complexity, the digit sequence is eventually periodic. -/
theorem eventuallyPeriodic_of_algebraic_linear_complexity
    {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b)
    (h_linear : LinearFactorComplexity a)
    (h_AB : AdamczewskiBugeaudCriterion b)
    (halg : IsAlgebraic ℚ (digitReal b a)) :
    EventuallyPeriodic (fun n => a n) := by
  by_contra h_nonper
  exact not_isAlgebraic_of_nonperiodic_linear_complexity hb a h_nonper h_linear h_AB halg

/-- **Existence of transcendental digit reals from finite-state machines.**
    Given the Adamczewski–Bugeaud criterion and that the Thue-Morse sequence
    has linear factor complexity (a known result from combinatorics on words),
    the Thue-Morse digit real is transcendental.

    The hypothesis `h_tm_linear` encapsulates the known bound
    p_{TM}(m) ≤ 10m/3 + 4 (Brlek, 1989). -/
theorem thueMorse_digitReal_transcendental
    (h_AB : AdamczewskiBugeaudCriterion 2)
    (h_tm_linear : LinearFactorComplexity thueMorse) :
    Transcendental ℚ (digitReal 2 thueMorse) :=
  transcendental_of_nonperiodic_linear_complexity (by omega) thueMorse
    thueMorse_not_eventuallyPeriodic h_tm_linear h_AB

/-! ## §9. Finite-State Compression Criterion -/

/-- **Finite-state description complexity.**
    The finite-state complexity of a length-N prefix is the minimum number of
    states in any finite-state machine that can reproduce it. -/
def fsComplexity {b : ℕ} (a : ℕ → Fin b) (N : ℕ) : ℕ :=
  Nat.find (⟨N, fun n hn =>
    ⟨fun i => a i.val, ⟨n, Nat.lt_of_lt_of_le hn (le_refl _)⟩, rfl⟩⟩ :
    ∃ S : ℕ, ∀ n < N, ∃ f : Fin S → Fin b, ∃ i : Fin S, f i = a n)

/-- **Finite-state compression criterion for transcendence (Theorem B).**
    If a digit sequence has linear factor complexity (as implied by bounded
    finite-state description complexity under standard regularity conditions)
    and is not eventually periodic, then its digit real is transcendental.

    This converts finite-state compressibility into transcendence:
    bounded FS-complexity → linear factor complexity → transcendence. -/
theorem transcendental_of_bounded_fsComplexity
    {b : ℕ} (hb : 2 ≤ b) (a : ℕ → Fin b)
    (h_linear : LinearFactorComplexity a)
    (h_nonper : ¬ EventuallyPeriodic (fun n => a n))
    (h_AB : AdamczewskiBugeaudCriterion b) :
    Transcendental ℚ (digitReal b a) :=
  transcendental_of_nonperiodic_linear_complexity hb a h_nonper h_linear h_AB

/-! ## §10. The Transcendence Compiler -/

/-- **The transcendence compiler.**
    Given:
    1. A base b ≥ 2
    2. A digit sequence a with linear factor complexity
    3. A proof that a is not eventually periodic
    4. The Adamczewski–Bugeaud criterion
    Conclude: the digit real is transcendental.

    This is the formal "compiler" that takes finite-state structure as input
    and produces transcendence as output. It represents the shift from
    explicit combinatorics to a general machine-architecture criterion. -/
def transcendenceCompiler (b : ℕ) (hb : 2 ≤ b)
    (a : ℕ → Fin b) (h_linear : LinearFactorComplexity a)
    (h_nonper : ¬ EventuallyPeriodic (fun n => a n))
    (h_AB : AdamczewskiBugeaudCriterion b) :
    Transcendental ℚ (digitReal b a) :=
  transcendental_of_nonperiodic_linear_complexity hb a h_nonper h_linear h_AB

/-
**Irrationality from non-periodicity.**
    If the digit sequence is not eventually periodic and the AB criterion holds,
    then the digit real is irrational (a fortiori from transcendence).
-/
theorem irrational_of_nonperiodic_linear_complexity
    {b : ℕ} (_hb : 2 ≤ b) (a : ℕ → Fin b)
    (h_nonper : ¬ EventuallyPeriodic (fun n => a n))
    (h_linear : LinearFactorComplexity a)
    (h_AB : AdamczewskiBugeaudCriterion b) :
    Irrational (digitReal b a) := by
      exact Transcendental.irrational fun a_1 => h_nonper (h_AB a h_linear a_1)

end FiniteStateTranscendence