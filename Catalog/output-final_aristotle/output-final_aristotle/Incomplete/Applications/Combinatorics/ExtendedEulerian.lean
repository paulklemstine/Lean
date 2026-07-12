import Mathlib
import FINAL.CombFoundations

/-!
# The extended Eulerian number recurrence

We study the **extended Eulerian numbers** `A n k s` depending on a natural "size" `n`,
a natural "descent count" `k`, and a real shift parameter `s`.  They are defined here by
the explicit *closed form*

  `A n k s = ∑_{i ≤ k} (-1)^i * C(n+1, i) * (k + 1 - i - s)^n`,

which for `s = 0` is the classical closed form for the Eulerian numbers `⟨n, k⟩`.

The goal of this file is a **rigorous, non-circular** proof of the recurrence

  `A (n+1) (k+1) s = (k + 2 - s) * A n (k+1) s + (n - k + s) * A n k s`.

Crucially, the recurrence is **not** assumed anywhere: `A` is defined by the closed form
above, and the recurrence is *derived* purely from the combinatorial identities collected
in `Catalog/FINAL/CombFoundations.lean` (Pascal's rule and the absorption identity) together
with elementary arithmetic.  This rules out any circular dependency.

The proof structure is:

* **Base cases** (`A_zero_zero`, `A_zero_succ`, `A_at_zero`): the values of `A` on the
  boundary, established directly from the definition.
* **Inductive step** (`A_recurrence`): the main recurrence, derived from the three
  `CombFoundations` identities `alt_binom_pascal_split`, `alt_binom_absorb_sum`,
  `alt_binom_pascal_recombine`.
-/

namespace ExtendedEulerian

open Finset CombFoundations

/-- The **extended Eulerian numbers**, defined by their closed form.
For `s = 0` this is the standard closed form for the Eulerian numbers. -/
noncomputable def A (n k : ℕ) (s : ℝ) : ℝ :=
  ∑ i ∈ Finset.range (k + 1),
    (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * ((k : ℝ) + 1 - i - s) ^ n

/-- Unfolding lemma: `A n k s` written as an alternating binomial sum with the base
`(k+1-s) - i`. Convenient for matching the `CombFoundations` identities. -/
theorem A_eq (n k : ℕ) (s : ℝ) :
    A n k s = ∑ i ∈ Finset.range (k + 1),
      (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * (((k : ℝ) + 1 - s) - i) ^ n := by
  unfold A
  refine Finset.sum_congr rfl (fun i _ => by ring_nf)

/-! ### Base cases -/

/-
Base case: `A 0 0 s = 1`.
-/
theorem A_zero_zero (s : ℝ) : A 0 0 s = 1 := by
  unfold A; norm_num;

/-
Base case: `A 0 (k+1) s = 0` for every `k`.
-/
theorem A_zero_succ (k : ℕ) (s : ℝ) : A 0 (k + 1) s = 0 := by
  unfold A; induction' k with k hk <;> simp_all +decide [ Finset.sum_range_succ ] ;

/-
Base case: at `k = 0`, `A n 0 s = (1 - s)^n`.
-/
theorem A_at_zero (n : ℕ) (s : ℝ) : A n 0 s = (1 - s) ^ n := by
  simp [A]

/-! ### The recurrence (inductive step) -/

/-
**The extended Eulerian recurrence.**

`A (n+1) (k+1) s = (k + 2 - s) * A n (k+1) s + (n - k + s) * A n k s`.

This is proved with no appeal to the recurrence itself: starting from the closed-form
definition of `A`, it follows from Pascal's rule and the absorption identity, packaged as
the three alternating–binomial–sum identities in `CombFoundations`.
-/
theorem A_recurrence (n k : ℕ) (s : ℝ) :
    A (n + 1) (k + 1) s
      = ((k : ℝ) + 2 - s) * A n (k + 1) s + ((n : ℝ) - k + s) * A n k s := by
  -- Apply the recurrence relation to the expanded sum
  have h_recurrence : ∑ i ∈ Finset.range (k + 2), (-1 : ℝ) ^ i * (Nat.choose (n + 2) i : ℝ) * ((k + 2 - s) - i) ^ (n + 1) =
    (∑ i ∈ Finset.range (k + 2), (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * ((k + 2 - s) - i) ^ (n + 1)) -
    (∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * (Nat.choose (n + 1) j : ℝ) * ((k + 1 - s) - j) ^ (n + 1)) := by
      convert alt_binom_pascal_split n k ( n + 1 ) ( k + 2 - s ) using 1 ; ring;
      grind;
  -- Apply the absorption identity to the first sum
  have h_absorb1 : ∑ i ∈ Finset.range (k + 2), (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * ((k + 2 - s) - i) ^ (n + 1) =
    (k + 2 - s) * ∑ i ∈ Finset.range (k + 2), (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * ((k + 2 - s) - i) ^ n +
    (n + 1) * ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * (Nat.choose n j : ℝ) * ((k + 1 - s) - j) ^ n := by
      have h_absorb1 : ∑ i ∈ Finset.range (k + 2), (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * ((k + 2 - s) - i) ^ (n + 1) =
        (k + 2 - s) * ∑ i ∈ Finset.range (k + 2), (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * ((k + 2 - s) - i) ^ n -
        ∑ i ∈ Finset.range (k + 2), (-1 : ℝ) ^ i * (Nat.choose (n + 1) i : ℝ) * (i : ℝ) * ((k + 2 - s) - i) ^ n := by
          rw [ Finset.mul_sum _ _ _ ];
          rw [ ← Finset.sum_sub_distrib ] ; congr ; ext ; ring;
      rw [ h_absorb1, alt_binom_absorb_sum ] ; ring;
  -- Apply the absorption identity to the second sum
  have h_absorb2 : ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * (Nat.choose (n + 1) j : ℝ) * ((k + 1 - s) - j) ^ (n + 1) =
    (k + 1 - s) * ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * (Nat.choose (n + 1) j : ℝ) * ((k + 1 - s) - j) ^ n +
    (n + 1) * ∑ j ∈ Finset.range k, (-1 : ℝ) ^ j * (Nat.choose n j : ℝ) * ((k - s) - j) ^ n := by
      have h_absorb2 : ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * (Nat.choose (n + 1) j : ℝ) * ((k + 1 - s) - j) ^ (n + 1) =
        (k + 1 - s) * ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * (Nat.choose (n + 1) j : ℝ) * ((k + 1 - s) - j) ^ n -
        ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * (Nat.choose (n + 1) j : ℝ) * (j : ℝ) * ((k + 1 - s) - j) ^ n := by
          rw [ Finset.mul_sum _ _ _ ];
          rw [ ← Finset.sum_sub_distrib ] ; congr ; ext ; ring;
      rw [ h_absorb2, alt_binom_absorb_sum ] ; ring;
  -- Apply the recombination identity to the sums
  have h_recombine : ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * (Nat.choose n j : ℝ) * ((k + 1 - s) - j) ^ n -
      ∑ j ∈ Finset.range k, (-1 : ℝ) ^ j * (Nat.choose n j : ℝ) * ((k - s) - j) ^ n =
      ∑ j ∈ Finset.range (k + 1), (-1 : ℝ) ^ j * (Nat.choose (n + 1) j : ℝ) * ((k + 1 - s) - j) ^ n := by
        convert alt_binom_pascal_recombine n k n ( k + 1 - s ) using 1 ; ring;
  simp_all +decide [ A_eq ];
  grind

end ExtendedEulerian