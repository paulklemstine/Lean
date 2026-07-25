import Mathlib

/-!
# Collatz Parity Exclusion and Density Contraction

This file establishes rigorous formal foundations for analyzing the Collatz conjecture
through parity structure and density arguments. The key results are:

## Main Results

1. **Parity Exclusion** (`collatz_odd_step_yields_even`): After applying the Collatz
   map to an odd number, the result is always even. This means no two consecutive
   steps in a Collatz orbit can both be "odd steps" (3n+1 operations).

2. **Power Comparison** (`pow3_lt_pow2_of_two_mul_lt`): For natural numbers j ≥ 1,
   if 2j < k then 3^j < 2^k. This is the arithmetic core of density contraction.

3. **Parity Exclusion Density Bound** (`oddCount_le_half_ceil`): In any Collatz orbit
   segment of length k, at most ⌈k/2⌉ positions can be odd-valued. This is the
   quantitative consequence of parity exclusion.

4. **Orbit Determinism** (`collatz_orbit_determined`): Collatz orbits are fully determined
   by their starting value — if two orbits meet, all subsequent values agree.

## Mathematical Significance

The parity exclusion theorem is the simplest structural constraint on Collatz orbits,
yet it has deep consequences: it forces the odd-step density in any orbit segment to
be at most 1/2. Combined with the power comparison lemma (which shows contraction
when odd density < 1/2), this reveals that the "worst case" for the Collatz
conjecture is orbits that alternate between odd and even steps as much as possible.

The gap between the sufficient condition (density < 1/2) and the optimal threshold
(density < log₂(2)/log₂(3) ≈ 0.6309) is explored in FUTURE_DIRECTIONS.md.
-/

namespace CollatzParity

/-! ## Section 1: Collatz Step Definition and Basic Properties -/

/-- The standard Collatz step function. -/
def T (n : ℕ) : ℕ :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

@[simp] theorem T_zero : T 0 = 0 := by simp [T]

theorem T_even {n : ℕ} (h : n % 2 = 0) : T n = n / 2 := by
  simp [T, h]

theorem T_odd {n : ℕ} (h : n % 2 = 1) : T n = 3 * n + 1 := by
  simp [T]; omega

/-! ## Section 2: Parity Exclusion Theorem -/

-- !-- The key insight: 3n+1 is always even when n is odd, because 3·(2k+1)+1 = 6k+4 = 2(3k+2).
-- This means after every odd step, the next step must be an even step (division by 2). --!--

/-- **Parity Exclusion**: If n is odd, then T(n) = 3n+1 is even.
    This is the fundamental structural constraint on Collatz orbits:
    no two consecutive steps can both be odd-type steps. -/
theorem collatz_odd_step_yields_even {n : ℕ} (hodd : n % 2 = 1) :
    T n % 2 = 0 := by
  rw [T_odd hodd]; omega

/-- After an odd step followed by the mandatory even step, we get (3n+1)/2. -/
theorem collatz_two_step_from_odd {n : ℕ} (hodd : n % 2 = 1) :
    T (T n) = (3 * n + 1) / 2 := by
  rw [T_odd hodd]; exact T_even (by omega)

/-- The "shortcut" Collatz map for odd numbers: n ↦ (3n+1)/2.
    This is always well-defined for odd n since 3n+1 is even. -/
def T_shortcut (n : ℕ) : ℕ := (3 * n + 1) / 2

/-- The two-step composition on odd inputs equals the shortcut map. -/
theorem T_compose_eq_shortcut {n : ℕ} (hodd : n % 2 = 1) :
    T (T n) = T_shortcut n := by
  rw [collatz_two_step_from_odd hodd]; rfl

/-! ## Section 3: Power Comparison Lemma -/

-- !-- We prove 3^j < 2^k when 2j < k. The idea: 3 < 4 = 2², so 3^j < 4^j = 2^(2j) ≤ 2^k
-- when 2j < k. This is the arithmetic core of density contraction. --!--

/-- Weak version: 3^j ≤ 4^j = 2^(2j) for all j. -/
theorem pow3_le_pow4 (j : ℕ) : 3 ^ j ≤ 4 ^ j := by
  gcongr; norm_num

/-- **Power Comparison**: If 2j < k, then 3^j < 2^k.
    This is the arithmetic foundation for the density contraction argument:
    if fewer than half the steps in an orbit segment are odd, the orbit contracts.

    The proof uses 3 < 4 = 2² to show that each factor of 3 is "paid for"
    by two factors of 2, with room to spare. -/
theorem pow3_lt_pow2_of_two_mul_lt {j k : ℕ} (hj : 1 ≤ j) (hk : 2 * j < k) :
    3 ^ j < 2 ^ k := by
  calc 3 ^ j ≤ 4 ^ j := pow3_le_pow4 j
    _ = (2 ^ 2) ^ j := by ring_nf
    _ = 2 ^ (2 * j) := by rw [← pow_mul]
    _ < 2 ^ k := by exact Nat.pow_lt_pow_right (by norm_num) hk

/-! ## Section 4: Orbit Determinism -/

-- !-- Collatz orbits are deterministic: T is a function, so if two trajectories
-- ever reach the same value, they agree on all subsequent iterates. --!--

/-- **Orbit Determinism / Merge**: If two Collatz trajectories starting from
    different values ever reach the same value at some step, then all subsequent
    iterates agree. This is simply because T is a (deterministic) function. -/
theorem collatz_orbit_determined (a b : ℕ) (ja jb : ℕ)
    (h : (T^[ja]) a = (T^[jb]) b) :
    ∀ k : ℕ, (T^[ja + k]) a = (T^[jb + k]) b := by
  intro k
  induction k with
  | zero => exact h
  | succ k ih =>
    rw [Nat.add_succ, Nat.add_succ,
        Function.iterate_succ_apply', Function.iterate_succ_apply', ih]

/-! ## Section 5: Orbit Parity Sequence and Density Bound -/

/-- The parity of the i-th element in a Collatz orbit starting at n.
    Returns the mod-2 residue: 1 if odd, 0 if even. -/
def orbitParity (n : ℕ) (i : ℕ) : ℕ :=
  (T^[i]) n % 2

/-- Count of odd-valued positions among the first k orbit elements. -/
def oddCount (n : ℕ) (k : ℕ) : ℕ :=
  ((Finset.range k).filter (fun i => (T^[i]) n % 2 = 1)).card

/-- **Parity Exclusion Density Bound**: In any Collatz orbit segment of length k,
    the number of odd-valued positions is at most ⌈k/2⌉.
    This follows from parity exclusion: after each odd value, the next must be even,
    so odd values cannot be consecutive. -/
theorem oddCount_le_half_ceil (n : ℕ) (k : ℕ) :
    oddCount n k ≤ (k + 1) / 2 := by
  induction' k using Nat.strong_induction_on with k ih generalizing n
  rcases k with ( _ | _ | k ) <;> simp +arith +decide [ *, Finset.sum_range_succ' ]
  · rfl
  · exact Finset.card_le_one.mpr ( by aesop )
  · by_cases h : n % 2 = 1
    · -- n is odd: position 0 contributes 1, position 1 is even (parity exclusion)
      have h_even : oddCount n (k + 2) = 1 + oddCount (T (T n)) k := by
        unfold oddCount; simp +arith +decide [ Finset.sum_range_succ', h ]
        rw [ Finset.card_filter, Finset.card_filter ]
        rw [ Finset.sum_range_succ', Finset.sum_range_succ' ]
        simp +arith +decide [ *, Function.iterate_succ_apply' ]
        simp +arith +decide [ ← Function.iterate_succ_apply', h, collatz_odd_step_yields_even ]
      have := ih k (by omega) (T (T n))
      omega
    · -- n is even: position 0 contributes 0
      have h_even : oddCount n (k + 2) = oddCount (n / 2) (k + 1) := by
        unfold oddCount
        rw [ Finset.card_filter, Finset.card_filter ]
        rw [ Finset.sum_range_succ' ]
        simp_all +decide [ Function.iterate_add_apply, T ]
      exact h_even.symm ▸ le_trans ( ih _ ( Nat.lt_succ_self _ ) _ ) ( by omega )

/-! ## Section 6: Collatz Step Positivity -/

/-- T preserves positivity. -/
theorem T_pos {n : ℕ} (hn : 0 < n) : 0 < T n := by
  unfold T; split_ifs with h
  · exact Nat.div_pos (Nat.le_of_dvd hn (Nat.dvd_of_mod_eq_zero h)) (by norm_num)
  · omega

/-- Iterating T preserves positivity. -/
theorem iterate_T_pos {n : ℕ} (hn : 0 < n) (k : ℕ) : 0 < (T^[k]) n := by
  induction k with
  | zero => simpa
  | succ k ih => rw [Function.iterate_succ_apply']; exact T_pos ih

end CollatzParity