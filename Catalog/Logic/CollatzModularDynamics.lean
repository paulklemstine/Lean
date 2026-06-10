import Mathlib

/-!
# Collatz Modular Dynamics: Structural Properties of the 3n+1 Map

This file formalizes key structural properties of the Collatz dynamical system
through the lens of modular arithmetic. We establish:

1. Powers of 2 always reach 1 (the "2-adic descent" property)
2. The Collatz map has no positive fixed points
3. No positive 2-cycles exist in the Collatz dynamics
4. The branching structure of the "shortcut" Collatz map is fully determined
   by residues modulo 4

These results connect discrete dynamics to modular-arithmetic structure,
providing a rigorous foundation for Collatz-adjacent research.
-/

namespace CollatzModular

-- !-- Lab Notebook: CollatzModular -- !--
-- !-- Hypothesis: The Collatz map's behavior on special inputs (powers of 2, fixed points, short cycles) can be fully characterized via elementary modular arithmetic -- !--
-- !-- Result: All four main theorems proved; the mod-4 branching theorem reveals the deterministic structure governing parity cascades -- !--
-- !-- Insight: The absence of fixed points and 2-cycles follows from simple linear algebra over ℤ; the key is that 3n+1 = n and (3n+1)/2 = n have no positive solutions -- !--
-- !-- Failure analysis: Initial attempt to prove pow2_reaches_one directly by omega failed; needed induction on k with explicit parity unfolding -- !--
-- !-- End Lab Notebook -- !--

/-- The standard Collatz step: n/2 if even, 3n+1 if odd. -/
def C (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else 3 * n + 1

@[simp] theorem C_zero : C 0 = 0 := by simp [C]

theorem C_even {n : ℕ} (h : n % 2 = 0) : C n = n / 2 := by simp [C, h]

theorem C_odd {n : ℕ} (h : n % 2 = 1) : C n = 3 * n + 1 := by simp [C, h]

/-- The "shortcut" or Syracuse map: applies 3n+1 then divides by 2 for odd inputs. -/
def syracuse (n : ℕ) : ℕ := if n % 2 = 0 then n / 2 else (3 * n + 1) / 2

/-!
## Theorem 1: Powers of Two Descent

Every power of 2 reaches 1 under iterated Collatz steps.
The number of steps equals the exponent.
-/

-- !-- comment: The proof proceeds by induction on k. At each step, 2^(k+1) is even,
-- so C(2^(k+1)) = 2^(k+1)/2 = 2^k, reducing the exponent by 1. -- !--

theorem C_pow2 (k : ℕ) (hk : 0 < k) : C (2 ^ k) = 2 ^ (k - 1) := by
  have heven : 2 ^ k % 2 = 0 := Nat.dvd_iff_mod_eq_zero.mp (dvd_pow_self 2 (by omega))
  rw [C_even heven]
  obtain ⟨j, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (by omega : k ≠ 0)
  simp [pow_succ, Nat.mul_div_cancel _ (by omega : 0 < 2)]

/-
Powers of 2 reach 1 in exactly k steps.
-/
theorem pow2_reaches_one (k : ℕ) : (C^[k]) (2 ^ k) = 1 := by
  induction' k with k ih;
  · rfl;
  · convert ih using 1;
    simp +zetaDelta at *;
    exact congr_arg _ ( by rw [ C_pow2 _ ( Nat.succ_pos _ ) ] ; rfl )

/-!
## Theorem 2: No Positive Fixed Points

The Collatz map has no positive fixed point: C(n) ≠ n for all n > 0.
-/

/-
!-- comment: If n is even and n > 0, then C(n) = n/2 < n. If n is odd, then
C(n) = 3n+1 > n. In neither case does C(n) = n. -- !--

The Collatz map has no positive fixed point.
-/
theorem collatz_no_positive_fixed_point (n : ℕ) (hn : 0 < n) : C n ≠ n := by
  unfold C;
  split_ifs <;> omega

/-!
## Theorem 3: No Positive Two-Cycles

There is no n > 0 with C(C(n)) = n. This eliminates the simplest
nontrivial periodic orbit from consideration.
-/

/-
!-- comment: Case split on parity of n. If n even, C(n) = n/2. Sub-case on
parity of n/2: if even, C(C(n)) = n/4 ≠ n for n > 0; if odd,
C(C(n)) = 3(n/2)+1 = n requires n = -2, impossible. If n odd,
C(n) = 3n+1 (even), so C(C(n)) = (3n+1)/2 = n requires n = -1, impossible. -- !--

No positive integer is a 2-cycle of the Collatz map.
-/
theorem collatz_no_positive_two_cycle (n : ℕ) (hn : 0 < n) : C (C n) ≠ n := by
  by_contra h;
  unfold C at h;
  split_ifs at h <;> omega

/-!
## Theorem 4: Shortcut Map Parity Determined by Residue mod 4

For odd n, the parity of (3n+1)/2 is fully determined by n mod 4:
- n ≡ 1 (mod 4) ⟹ (3n+1)/2 is even
- n ≡ 3 (mod 4) ⟹ (3n+1)/2 is odd

This reveals the branching structure of Collatz dynamics: the next
step after a "shortcut" application is deterministically governed by
a single additional bit of the input.
-/

/-
!-- comment: When n ≡ 1 (mod 4), write n = 4q+1, so 3n+1 = 12q+4, and
(3n+1)/2 = 6q+2 ≡ 0 (mod 2). When n ≡ 3 (mod 4), write n = 4q+3,
so 3n+1 = 12q+10, and (3n+1)/2 = 6q+5 ≡ 1 (mod 2). -- !--

If n ≡ 1 (mod 4) and n is odd, then (3n+1)/2 is even.
-/
theorem shortcut_mod4_case1 (n : ℕ) (hodd : n % 2 = 1) (hmod : n % 4 = 1) :
    (3 * n + 1) / 2 % 2 = 0 := by
  omega

/-
If n ≡ 3 (mod 4) and n is odd, then (3n+1)/2 is odd.
-/
theorem shortcut_mod4_case3 (n : ℕ) (hodd : n % 2 = 1) (hmod : n % 4 = 3) :
    (3 * n + 1) / 2 % 2 = 1 := by
  omega

/-!
## Generalization: Collatz mod-4 branching as a complete characterization

For odd n, n % 4 ∈ {1, 3}, and these two cases exhaust all possibilities.
Combined with the two theorems above, this gives a complete parity
prediction rule for the shortcut Collatz map on odd inputs.
-/

/-- Every odd number is congruent to 1 or 3 modulo 4. -/
theorem odd_mod4_cases (n : ℕ) (hodd : n % 2 = 1) : n % 4 = 1 ∨ n % 4 = 3 := by
  omega

end CollatzModular