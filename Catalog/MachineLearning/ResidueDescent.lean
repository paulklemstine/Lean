import Mathlib
import Speculative.Collatz.Core

/-!
# Residue-Class Descent Implies Collatz Convergence

The main theorem of this file is `residue_class_descent_implies_collatz`:
if there exists a modulus `M` such that every residue class mod `2^M`
has a certified descent (an iterate that produces a strictly smaller value),
then the Collatz conjecture holds for all positive integers.

This converts the infinitary Collatz conjecture into a finite verification problem.
The proof is by strong induction: given any `n > 0`, we look at its residue class
mod `2^M`, apply the certified descent to get a strictly smaller value, and
apply the induction hypothesis.

## Mathematical significance

This is a *reduction theorem*: it does not prove the Collatz conjecture, but it
proves that a finite computational certificate would suffice to establish it.
The formal statement makes precise exactly what kind of certificate is needed.
-/

namespace Collatz

/-- A residue descent certificate for modulus `2^M`: every residue class `r` mod `2^M`
    admits some iterate count `k` such that for all `n > 0` in that class,
    the `k`-fold iterate of `collatzStep` is strictly less than `n`. -/
def descendsByResidueClass (M : ℕ) : Prop :=
  ∀ r < 2 ^ M, ∃ k : ℕ, ∀ n : ℕ, 0 < n →
    n % 2 ^ M = r → (collatzStep^[k]) n < n

/-
`collatzStep` preserves positivity: if `n > 0` then `collatzStep n > 0`.
-/
theorem collatzStep_pos {n : ℕ} (hn : 0 < n) : 0 < collatzStep n := by
  unfold collatzStep; split_ifs <;> omega;

/-
Iterating `collatzStep` preserves positivity.
-/
theorem iterate_collatzStep_pos {n : ℕ} (hn : 0 < n) (k : ℕ) :
    0 < (collatzStep^[k]) n := by
  exact Nat.recOn k hn fun n ih => by rw [ Function.iterate_succ_apply' ] ; exact collatzStep_pos ih;

/-
**Main Reduction Theorem**: If a residue descent certificate exists for some modulus `2^M`,
    then every positive integer eventually reaches 1 under iterated Collatz steps.

    This is proved by strong induction on `n`. For each `n`, we find its residue class
    mod `2^M`, use the certificate to get an iterate that produces a strictly smaller
    positive value, and apply the induction hypothesis.
-/
theorem residue_class_descent_implies_collatz
    (M : ℕ)
    (hM : descendsByResidueClass M) :
    ∀ n : ℕ, 0 < n → reachesOne n := by
  intro n hn;
  induction' n using Nat.strongRecOn with n ih;
  -- Apply the residue descent certificate to find such a k.
  obtain ⟨k, hk⟩ : ∃ k : ℕ, (collatzStep^[k]) n < n := by
    exact hM _ ( Nat.mod_lt _ ( by positivity ) ) |> fun ⟨ k, hk ⟩ => ⟨ k, hk _ hn rfl ⟩;
  exact reachesOne_of_iterate ( ih _ hk ( iterate_collatzStep_pos hn _ ) )

end Collatz