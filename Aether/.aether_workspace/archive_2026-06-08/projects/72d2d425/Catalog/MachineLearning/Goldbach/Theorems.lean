/-
Copyright (c) 2025. All rights reserved.
Formal additive prime decomposition theory: structural theorems.
-/
import Speculative.Goldbach.Defs

/-!
# Goldbach-type Additive Prime Decompositions: Theorems

This file proves structural theorems about Goldbach-type decompositions,
including transfer theorems between binary and ternary Goldbach, parity
forcing, witness set equivalences, and Chen-type reductions.

## Main Results

* `goldbach_pair_symm` — symmetry of Goldbach pairs
* `mem_goldbachWitnesses_swap` — symmetry at the finset level
* `binary_goldbach_implies_ternary` — binary Goldbach implies ternary for odd > 5
* `hasGoldbachDecomposition_iff_witnesses_nonempty` — witness set equivalence
* `hasGoldbachDecomposition_decidable` — decidability of Goldbach decomposition
* `goldbach_pair_even_gt_four_both_odd` — parity forcing
* `goldbach_decomposition_of_even_gt_four_avoids_two` — no even prime in large decompositions
* `goldbach_implies_weakChen` — Goldbach implies weak Chen decomposition
* `goldbachCount_pos_iff` — positivity of representation count ↔ existence
-/

open Finset Nat Goldbach

namespace Goldbach

/-! ## Symmetry -/

/-
Goldbach pairs are symmetric: if `(p, q)` is a Goldbach pair for `n`,
then so is `(q, p)`.
-/
theorem goldbach_pair_symm {n p q : ℕ}
    (h : GoldbachPair n p q) : GoldbachPair n q p := by
  exact ⟨ h.2.1, h.1, by linarith [ h.2.2 ] ⟩

/-
Membership in the Goldbach witness finset is preserved under swapping.
-/
theorem mem_goldbachWitnesses_swap {n p q : ℕ}
    (h : (p, q) ∈ goldbachWitnesses n) : (q, p) ∈ goldbachWitnesses n := by
  unfold goldbachWitnesses at *; simp_all +decide [ add_comm ] ;

/-! ## Transfer theorems -/

/-
If binary Goldbach holds for all even numbers > 2, then the ternary
Goldbach conjecture holds for all odd numbers > 5. The key idea:
write `n = 3 + (n - 3)`, observe `n - 3` is even and > 2 for odd `n > 5`,
and apply binary Goldbach to get `n - 3 = p + q`.
-/
theorem binary_goldbach_implies_ternary
    (hG : ∀ n : ℕ, Even n → 2 < n → HasGoldbachDecomposition n) :
    ∀ n : ℕ, Odd n → 5 < n → HasOddVinogradovDecomposition n := by
  -- Given odd n > 5, write n = 3 + (n - 3). Since n is odd and > 5, n - 3 is even and > 2.
  intros n hn hn_gt
  have h_even : Even (n - 3) := by
    grind +extAll
  have h_gt : 2 < n - 3 := by
    omega;
  -- Apply the hypothesis `hG` to `n - 3`, obtaining primes `p` and `q` such that `p + q = n - 3`.
  obtain ⟨p, q, hpq⟩ : ∃ p q, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n - 3 := by
    exact hG _ h_even h_gt |> fun ⟨ p, q, hpq ⟩ => ⟨ p, q, hpq.1, hpq.2.1, hpq.2.2 ⟩;
  exact ⟨ 3, p, q, by norm_num, hpq.1, hpq.2.1, by omega ⟩

/-! ## Witness set equivalences -/

/-
A number has a Goldbach decomposition if and only if its
witness finset is nonempty.
-/
theorem hasGoldbachDecomposition_iff_witnesses_nonempty
    (n : ℕ) :
    HasGoldbachDecomposition n ↔ (goldbachWitnesses n).Nonempty := by
  unfold HasGoldbachDecomposition goldbachWitnesses;
  constructor <;> intro h;
  · obtain ⟨ p, q, hp, hq, hpq ⟩ := h; exact ⟨ ( p, q ), Finset.mem_filter.mpr ⟨ Finset.mem_product.mpr ⟨ Finset.mem_range.mpr ( by linarith ), Finset.mem_range.mpr ( by linarith ) ⟩, hp, hq, hpq ⟩ ⟩ ;
  · obtain ⟨ pq, hpq ⟩ := h; use pq.1, pq.2; unfold GoldbachPair; aesop;

/-- `HasGoldbachDecomposition` is decidable for any natural number,
since it reduces to a bounded search over primes up to `n`. -/
instance hasGoldbachDecomposition_decidable (n : ℕ) :
    Decidable (HasGoldbachDecomposition n) := by
  rw [hasGoldbachDecomposition_iff_witnesses_nonempty]
  exact inferInstance

/-! ## Parity forcing -/

/-
In any Goldbach decomposition of an even number greater than 4,
both primes must be odd. This follows because `2` is the only even prime,
and if one summand were `2`, the other would be `n - 2`, which can be checked
to force `n ≤ 4`.
-/
theorem goldbach_pair_even_gt_four_both_odd
    {n p q : ℕ}
    (hn_even : Even n)
    (hn_gt : 4 < n)
    (h : GoldbachPair n p q) :
    Odd p ∧ Odd q := by
  -- Since $p$ and $q$ are primes and their sum is even, both must be odd primes.
  have h_pq_odd : Odd p := by
    cases h.1.eq_two_or_odd' <;> simp_all +decide [ parity_simps ];
    cases h ; simp_all +arith +decide [ Nat.even_iff ];
    cases Nat.Prime.eq_two_or_odd ( by tauto : Nat.Prime q ) <;> omega
  have h_q_odd : Odd q := by
    cases h.2.1.eq_two_or_odd' <;> simp_all +decide [ parity_simps ];
    cases h ; simp_all +decide;
    subst_vars; obtain ⟨ k, hk ⟩ := hn_even; obtain ⟨ m, hm ⟩ := h_pq_odd; omega;
  exact ⟨h_pq_odd, h_q_odd⟩

/-
Corollary: in Goldbach decompositions of even numbers above 4,
neither prime is 2.
-/
theorem goldbach_decomposition_of_even_gt_four_avoids_two
    {n p q : ℕ}
    (hn_even : Even n)
    (hn_gt : 4 < n)
    (h : GoldbachPair n p q) :
    p ≠ 2 ∧ q ≠ 2 := by
  constructor <;> intro H <;> have := goldbach_pair_even_gt_four_both_odd hn_even hn_gt h <;> simp_all +decide [ Nat.even_iff ]

/-! ## Chen-type reductions -/

/-- Every prime is prime-or-semiprime. -/
theorem prime_is_primeOrSemiprime {p : ℕ} (hp : Nat.Prime p) :
    PrimeOrSemiprime p :=
  Or.inl hp

/-
Any Goldbach decomposition yields a weak Chen decomposition,
since primes are a special case of prime-or-semiprime numbers.
-/
theorem goldbach_implies_weakChen
    {n : ℕ}
    (h : HasGoldbachDecomposition n) :
    HasWeakChenDecomposition n := by
  exact ⟨ _, _, h.choose_spec.choose_spec.1, Or.inl h.choose_spec.choose_spec.2.1, h.choose_spec.choose_spec.2.2 ⟩

/-! ## Representation count -/

/-
The Goldbach representation count is positive if and only if
a Goldbach decomposition exists. This reframes Goldbach as a
positivity problem on convolution coefficients.
-/
theorem goldbachCount_pos_iff
    (n : ℕ) :
    0 < goldbachCount n ↔ HasGoldbachDecomposition n := by
  unfold goldbachCount
  rw [hasGoldbachDecomposition_iff_witnesses_nonempty]
  exact Finset.card_pos

end Goldbach