/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Lucas-sequence identities: doubling, addition, and partial-sum laws

Domain: Applications (Number-Theoretic Sequences).

The catalog file `Catalog/Applications/FibonacciLucasBridge.lean` introduces the Lucas
numbers `FibLucasBridge.lucasNum` (`L 0 = 2`, `L 1 = 1`, `L (n+2) = L n + L (n+1)`) and
develops the *divisibility* half of the Fibonacci/Lucas story (the doubling bridge
`F (2n) = F n · L n`, the fundamental identity `L n² − 5 F n² = 4(−1)ⁿ`, coprimality, and
the prime-divides-Lucas rank theorem).

This file develops the complementary **algebraic** half: the closed-form *doubling*,
*addition*, *Cassini*, and *partial-sum* laws for the Lucas sequence, together with the two
mixed Fibonacci–Lucas convolution laws.  These are the Lucas analogues of the Fibonacci
identities mechanised by the `fib_ring` toolkit
(`Catalog/Applications/ProofAutomation/FibonacciTactics.lean`) and are new to the catalog.

To keep the file self-contained (the catalog is built file-by-file against Mathlib only) the
Lucas sequence is redefined locally as `lucasNum`, with the *same* recurrence as the bridge's
`FibLucasBridge.lucasNum`; the bridge lemma `L (n+1) = F n + F (n+2)` is reproved here as
`lucasNum_succ_eq`.

Results:

* `sum_lucasNum`          — `∑_{i ≤ n} L i = L (n+2) − 1` (telescoping partial sum, in ℕ).
* `sum_lucasNum_sq`       — `∑_{i ≤ n} (L i)² = L n · L (n+1) + 2` (sum of squares, in ℕ).
* `two_mul_fib_add`       — `2 F (m+n) = F m · L n + L m · F n` (Fibonacci addition via Lucas).
* `two_mul_lucas_add`     — `2 L (m+n) = L m · L n + 5 F m · F n` (Lucas addition via Fibonacci).
* `lucasNum_two_mul`      — `L (2n) = (L n)² − 2(−1)ⁿ` (doubling, in ℤ).
* `lucasNum_two_mul_add_one` — `L (2n+1) = L n · L (n+1) − (−1)ⁿ` (odd-index doubling, in ℤ).
* `lucas_cassini`         — `L n · L (n+2) − (L (n+1))² = 5(−1)ⁿ` (Lucas–Cassini, in ℤ).

## Catalog synthesis

The mixed convolution laws `two_mul_fib_add` / `two_mul_lucas_add` are the algebraic engines
from which the divisibility results of `FibonacciLucasBridge` can be re-derived (e.g. setting
`m = n` in `two_mul_fib_add` and using `F (2n) = F n · L n` recovers the doubling bridge),
closing the loop between the two files.

-- !-- Lab Notebook -- !--
-- Hypotheses tested computationally (all confirmed on `n, m < 8`) before formalisation:
--   ∑_{i≤n} L i = L(n+2)-1;  ∑_{i≤n} L i² = L n L(n+1)+2;
--   2 F(m+n) = F m L n + L m F n;  2 L(m+n) = L m L n + 5 F m F n;
--   L(2n) = L n² - 2(-1)ⁿ;  L(2n+1) = L n L(n+1) - (-1)ⁿ;
--   L n L(n+2) - L(n+1)² = 5(-1)ⁿ.
-- Failure analysis: the first hand-guessed Lucas–Cassini sign `-5(-1)ⁿ` was FALSE
-- (numerically `L0 L2 - L1² = 5`, not `-5`); corrected to `+5(-1)ⁿ` after a `#eval` sweep.
-- Proof strategy: ℕ identities by induction / telescoping; ℤ identities by two-step
-- induction using `lucasNum_succ_eq` and `Nat.fib_add_two`, closed by `ring`/`linarith`.
-- !-- End Lab Notebook -- !--
-/

namespace Catalog.Applications.LucasIdentities

open Finset

/-- The Lucas numbers: `L 0 = 2`, `L 1 = 1`, `L (n+2) = L n + L (n+1)`
(local copy of `FibLucasBridge.lucasNum`). -/
def lucasNum : ℕ → ℕ
  | 0 => 2
  | 1 => 1
  | (n + 2) => lucasNum n + lucasNum (n + 1)

@[simp] lemma lucasNum_zero : lucasNum 0 = 2 := rfl
@[simp] lemma lucasNum_one : lucasNum 1 = 1 := rfl
lemma lucasNum_add_two (n : ℕ) : lucasNum (n + 2) = lucasNum n + lucasNum (n + 1) := rfl

/-- `L (n+1) = F n + F (n+2)`: the Lucas number flanked by Fibonacci numbers. -/
lemma lucasNum_succ_eq (n : ℕ) : lucasNum (n + 1) = Nat.fib n + Nat.fib (n + 2) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  rw [ show lucasNum ( n + 3 ) = lucasNum ( n + 1 ) + lucasNum ( n + 2 ) from rfl ] ; rw [ ih _ <| by linarith, ih _ <| by linarith ] ; simp +arith +decide [ Nat.fib_add_two ] ;

/-! ### Partial-sum laws (in ℕ) -/

/-- **Lucas partial sum:** `∑_{i ≤ n} L i = L (n+2) − 1`. -/
theorem sum_lucasNum (n : ℕ) :
    ∑ i ∈ Finset.range (n + 1), lucasNum i = lucasNum (n + 2) - 1 := by
  induction n <;> simp_all +decide [ Finset.sum_range_succ, lucasNum_add_two ];
  grind

/-- **Lucas sum of squares:** `∑_{i ≤ n} (L i)² = L n · L (n+1) + 2`. -/
theorem sum_lucasNum_sq (n : ℕ) :
    ∑ i ∈ Finset.range (n + 1), lucasNum i ^ 2 = lucasNum n * lucasNum (n + 1) + 2 := by
  induction n <;> simp_all +decide [ Finset.sum_range_succ, lucasNum_add_two ] ; ring

/-! ### Mixed Fibonacci–Lucas convolution laws (in ℕ) -/

/-- **Fibonacci addition via Lucas:** `2 F (m+n) = F m · L n + L m · F n`. -/
theorem two_mul_fib_add (m n : ℕ) :
    2 * Nat.fib (m + n) = Nat.fib m * lucasNum n + lucasNum m * Nat.fib n := by
  induction' m using Nat.strong_induction_on with m ih generalizing n;
  rcases m with ( _ | _ | m ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  · induction' n using Nat.strong_induction_on with n ih;
    rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
    have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; simp_all +arith +decide [ Nat.fib_add_two, lucasNum_add_two ] ;
    grind;
  · convert congr_arg₂ ( · + · ) ( ih m ( by linarith ) n ) ( ih ( m + 1 ) ( by linarith ) n ) using 1 ; ring;
    rw [ lucasNum_add_two ] ; ring

/-- **Lucas addition via Fibonacci:** `2 L (m+n) = L m · L n + 5 F m · F n`. -/
theorem two_mul_lucas_add (m n : ℕ) :
    2 * lucasNum (m + n) = lucasNum m * lucasNum n + 5 * Nat.fib m * Nat.fib n := by
  rcases n with ( _ | _ | n ) <;> simp +arith +decide [ * ];
  · grind +suggestions;
  · grind +suggestions

/-! ### Doubling and Cassini laws (in ℤ) -/

/-- **Lucas doubling:** `L (2n) = (L n)² − 2(−1)ⁿ`. -/
theorem lucasNum_two_mul (n : ℕ) :
    (lucasNum (2 * n) : ℤ) = (lucasNum n : ℤ) ^ 2 - 2 * (-1) ^ n := by
  convert two_mul_lucas_add n n using 1;
  -- Fundamental identity `L n² − 5 F n² = 4(−1)ⁿ` for `n ≥ 1`, by two-step induction.
  have h_lucas_fib : ∀ n ≥ 1, lucasNum n ^ 2 - 5 * Nat.fib n ^ 2 = 4 * (-1 : ℤ) ^ n := by
    intro n hn; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> norm_num [ Nat.fib_add_two, lucasNum_add_two ] at *;
    rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
    have := ih ( n + 1 ) ( by linarith ) ( by linarith ) ; have := ih ( n + 2 ) ( by linarith ) ( by linarith ) ; have := ih ( n + 3 ) ( by linarith ) ( by linarith ) ; norm_num [ Nat.fib_add_two, lucasNum_add_two ] at * ; ring_nf at * ; linarith;
  by_cases hn : 1 ≤ n <;> simp_all +decide [ ← two_mul ];
  constructor <;> intro <;> linarith [ h_lucas_fib n hn ]

/-- **Odd-index Lucas doubling:** `L (2n+1) = L n · L (n+1) − (−1)ⁿ`. -/
theorem lucasNum_two_mul_add_one (n : ℕ) :
    (lucasNum (2 * n + 1) : ℤ) = (lucasNum n : ℤ) * (lucasNum (n + 1) : ℤ) - (-1) ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +decide;
  have := ih n ( by linarith ) ; have := ih ( n + 1 ) ( by linarith ) ; simp_all +decide [ Nat.mul_succ, pow_succ, lucasNum_add_two ] ; ring;
  grind +suggestions

/-- **Lucas–Cassini identity:** `L n · L (n+2) − (L (n+1))² = 5(−1)ⁿ`. -/
theorem lucas_cassini (n : ℕ) :
    (lucasNum n : ℤ) * (lucasNum (n + 2) : ℤ) - (lucasNum (n + 1) : ℤ) ^ 2 = 5 * (-1) ^ n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> norm_num [ lucasNum ] at *;
  grind

end Catalog.Applications.LucasIdentities