/-
# The knot–number bridge X: an information-theoretic form of "the catch"

The original write-up notes informally that `A_N` has degree `N−1`, so "writing it down costs
`O(N) = exp(log N)`".  Cycle IV made the *size* precise (`A_N` has exactly `N` nonzero
coefficients).  This file makes the *locality* precise: no prefix of the coefficient sequence
of `A_N` carries any information about `N` at all.

* `Bridges.AlexanderTorus.alexander_coeff_eq_of_lt` : for `i < M` and `i < N`, the `i`-th
  coefficients of `A_M` and `A_N` agree — every Alexander polynomial of a `T(2,·)` torus knot
  starts `1 − X + X² − X³ + ⋯`;
* `Bridges.AlexanderTorus.alexander_first_difference` : for `M < N` the *first* index at which
  `A_M` and `A_N` differ is exactly `M`; reading the coefficients in order, an observer learns
  nothing until index `min(M,N)`;
* `Bridges.AlexanderTorus.alexander_injective_on_pos` : nevertheless `A_N` determines `N`
  (via its support), so the information is present — it is just located at the far end of an
  exponentially long expansion.

Together with `alexander_support_card` (cycle IV) and `degree_multiset_injective` (cycle IX)
this pins down where the factorization data lives: not in any bounded amount of local data,
but in the multiplicative structure of the whole degree-`N−1` polynomial.
-/
import Bridges.AlexanderKnotNumberBridgeIV

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-- Every `A_N` begins with the same alternating prefix: for `i < M` and `i < N` the `i`-th
coefficients agree. -/
theorem alexander_coeff_eq_of_lt {M N i : ℕ} (hiM : i < M) (hiN : i < N) :
    (alexander M).coeff i = (alexander N).coeff i := by
  rw [alexander_coeff, alexander_coeff, if_pos hiM, if_pos hiN]

/-- **First difference.** For `M < N`, the coefficient sequences of `A_M` and `A_N` agree at
every index `< M` and differ at index `M`.  So distinguishing the two knots from coefficient
data requires reading `M + 1 = min(M,N) + 1` coefficients. -/
theorem alexander_first_difference {M N : ℕ} (hMN : M < N) :
    (∀ i < M, (alexander M).coeff i = (alexander N).coeff i) ∧
      (alexander M).coeff M ≠ (alexander N).coeff M := by
  refine ⟨fun i hi => alexander_coeff_eq_of_lt hi (hi.trans hMN), ?_⟩
  rw [alexander_coeff, alexander_coeff, if_neg (lt_irrefl M), if_pos hMN]
  intro h
  have : ((-1 : ℤ) ^ M) ≠ 0 := by
    rcases Nat.even_or_odd M with he | ho
    · rw [he.neg_one_pow]; norm_num
    · rw [ho.neg_one_pow]; norm_num
  exact this h.symm

/-- `A_N` determines `N`: the map `N ↦ A_N` is injective. -/
theorem alexander_injective_on_pos : Function.Injective alexander := by
  intro M N h
  have hM := alexander_support_card M
  have hN := alexander_support_card N
  rw [h, hN] at hM
  exact hM.symm

/-- The knot-theoretic reading: two `T(2,·)` torus knots have the same Alexander polynomial
iff they are the same knot, yet any bounded prefix of the coefficient list is the same for
all of them. -/
theorem alexander_eq_iff (M N : ℕ) : alexander M = alexander N ↔ M = N :=
  ⟨fun h => alexander_injective_on_pos h, fun h => by rw [h]⟩

end Bridges.AlexanderTorus