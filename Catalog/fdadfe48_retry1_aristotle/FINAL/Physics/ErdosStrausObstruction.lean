import Catalog.FINAL.Physics.ErdosStraus

/-!
# The parity obstruction at `n ≡ 1 (mod 8)`

For `n ≡ 1 (mod 4)` the natural leading unit fraction is `1/b` with `b = (n+3)/4`,
which clears to the two-term identity

  `4/n = 1/b + 3/(b·n)`.

The remaining `3/(b·n)` can be split into **two** unit fractions by the *halving
scheme* `3/(2t) = 1/t + 1/(2t)` precisely when `b·n` is even.  This file isolates
that parity precondition and shows that it holds exactly for `n ≡ 5 (mod 8)` and
fails exactly for `n ≡ 1 (mod 8)`.

* `halving_solver`        — if `b·n` is even the halving scheme produces a solution;
* `halving_iff`           — for `n ≡ 1 (mod 4)`, `b·n` even `↔ n ≡ 5 (mod 8)`;
* `one_mod_eight_is_residual` — for `n ≡ 1 (mod 8)` the precondition `b·n` even fails.

Together these explain why `n ≡ 1 (mod 8)` is the sole residue class not settled by
the elementary halving family.
-/

namespace ErdosStraus

/-
**Halving solver.**  For `n ≡ 1 (mod 4)`, set `b = (n+3)/4`, so that
`4/n = 1/b + 3/(b·n)`.  If `b·n` is even then `3/(b·n)` splits via the halving scheme
`3/(2t) = 1/t + 1/(2t)`, yielding an explicit Erdős–Straus solution.
-/
theorem halving_solver (n : ℕ) (h4 : n % 4 = 1) (hpar : Even ((n + 3) / 4 * n)) :
    ErdosStrausSolution n := by
  convert ErdosStraus.es_five_mod_eight n _;
  rw [ Nat.even_mul, Nat.even_div ] at hpar;
  rw [ Nat.even_iff ] at hpar; omega;

/-
**Halving precondition.**  For `n ≡ 1 (mod 4)` the halving precondition `b·n` even
(where `b = (n+3)/4`) holds if and only if `n ≡ 5 (mod 8)`.
-/
theorem halving_iff (n : ℕ) (h4 : n % 4 = 1) :
    Even ((n + 3) / 4 * n) ↔ n % 8 = 5 := by
  rw [ Nat.even_mul, Nat.even_iff ];
  rw [ Nat.even_iff ] ; omega;

/-
**`n ≡ 1 (mod 8)` is residual.**  For `n ≡ 1 (mod 8)` the halving precondition
fails: with `b = (n+3)/4`, the product `b·n` is odd, so the elementary halving family
cannot produce a solution.
-/
theorem one_mod_eight_is_residual (n : ℕ) (h8 : n % 8 = 1) :
    ¬ Even ((n + 3) / 4 * n) := by
  norm_num [ Nat.even_div, Nat.add_mod, Nat.mul_mod, h8 ];
  exact Nat.odd_mul.mpr ⟨ Nat.odd_iff.mpr ( by omega ), Nat.odd_iff.mpr ( by omega ) ⟩

end ErdosStraus