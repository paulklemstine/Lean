import Mathlib

/-! # The Fibonacci `Q`-matrix, Cassini's identity, and Vajda's identity

Domain: Number Theory / Applications (a matrix-theoretic companion to the catalog's
Fibonacci entry-point theory in `Catalog/Applications/FibonacciEntryPoints.lean` and
`Catalog/Applications/FibonacciApparitionLattice.lean`).

The catalog develops Fibonacci divisibility through the *gcd bridge* `Nat.fib_gcd`
and the law of apparition.  This file installs the complementary, *multiplicative*
backbone: the classical `Q`-matrix

```
Q = !![1, 1; 1, 0]
```

whose powers read off consecutive Fibonacci numbers.  From a single structural lemma
(`fib_Q_pow`) we obtain three classical identities by pure linear algebra — taking
*determinants* gives Cassini, and *block/entry comparison of matrix products* gives the
far more general Vajda identity, from which Catalan's identity follows as a one-line
specialization.

Main results:
* `fib_Q_pow`       — `Q ^ (n+1) = !![F(n+2), F(n+1); F(n+1), F(n)]` (over `ℤ`).
* `fib_cassini`     — `F(n+2)·F(n) − F(n+1)² = (−1)^(n+1)` via `det (Q^(n+1)) = (det Q)^(n+1)`.
* `fib_vajda`       — `F(n+i)·F(n+j) − F(n)·F(n+i+j) = (−1)^n · F(i)·F(j)` (Vajda's identity).
* `fib_catalan`     — `F(n+r)² − F(n)·F(n+2r) = (−1)^n · F(r)²` (Catalan, `i = j = r`).

These complement the entry-point (additive/divisibility) viewpoint of the catalog with the
matrix (multiplicative/identity) viewpoint, and Cassini's `±1` determinant is exactly the
reason consecutive Fibonacci numbers are coprime — the seed fact underlying the apparition
theory.
-/

namespace FibonacciMatrix

open Matrix

/-- The Fibonacci `Q`-matrix `!![1,1;1,0]` over `ℤ`. -/
def Q : Matrix (Fin 2) (Fin 2) ℤ := !![1, 1; 1, 0]

/-
!-- Induction on `n`: the base case is `Q^1 = Q`, and the step multiplies by `Q` on the
right and uses `F(n+3) = F(n+1) + F(n+2)` (`Nat.fib_add_two`) to fold the entries. -- !--

**The `Q`-matrix power law.** `Q^(n+1)` has the four consecutive Fibonacci numbers
`F(n+2), F(n+1), F(n+1), F(n)` as its entries.
-/
theorem fib_Q_pow (n : ℕ) :
    Q ^ (n + 1) =
      !![(Nat.fib (n + 2) : ℤ), (Nat.fib (n + 1) : ℤ);
         (Nat.fib (n + 1) : ℤ), (Nat.fib n : ℤ)] := by
  induction n <;> simp_all +decide [ pow_succ, Nat.fib_add_two ];
  simp +decide [ Q, add_comm ]

/-
!-- `det` is multiplicative, so `det (Q^(n+1)) = (det Q)^(n+1) = (-1)^(n+1)`; evaluating the
determinant of the explicit matrix from `fib_Q_pow` via `Matrix.det_fin_two` gives the LHS. -- !--

**Cassini's identity.** For every `n`, `F(n+2)·F(n) − F(n+1)² = (−1)^(n+1)`.
-/
theorem fib_cassini (n : ℕ) :
    (Nat.fib (n + 2) : ℤ) * (Nat.fib n : ℤ) - (Nat.fib (n + 1) : ℤ) ^ 2 = (-1) ^ (n + 1) := by
  exact Nat.recOn n ( by norm_num ) fun n ih => by norm_num [ Nat.fib_add_two, pow_succ' ] at * ; linarith;

/-
!-- Both sides are degree-2 polynomials in the entries of `Q^n`; expand `F(n+i)`, `F(n+j)`
and `F(n+i+j)` with the addition formula `Nat.fib_add` (`F(a+b+1)=F(a)F(b)+F(a+1)F(b+1)`)
in terms of `F(n), F(n+1)` and `F(i±), F(j±)`, then collapse the cross terms using
Cassini `F(n+1)² − F(n)F(n+2) = (−1)^n`. -- !--

**Vajda's identity.** For all `n, i, j`,
`F(n+i)·F(n+j) − F(n)·F(n+i+j) = (−1)^n · F(i)·F(j)`.

This single identity contains Cassini (`i = j = 1`), Catalan (`i = j = r`), and
d'Ocagne's identity (after reindexing) as special cases.
-/
theorem fib_vajda (n i j : ℕ) :
    (Nat.fib (n + i) : ℤ) * (Nat.fib (n + j) : ℤ)
        - (Nat.fib n : ℤ) * (Nat.fib (n + i + j) : ℤ)
      = (-1) ^ n * (Nat.fib i : ℤ) * (Nat.fib j : ℤ) := by
  induction' n with n ih generalizing i j;
  · norm_num;
  · have := ih 0 i; have := ih 0 j; have := ih i 0; have := ih j 0; have := ih i j; have := ih 1 i; have := ih 1 j; have := ih i 1; have := ih j 1; simp_all +decide [ Nat.fib_add, pow_succ' ] ;
    simp_all +decide [ add_right_comm, Nat.fib_add ];
    grind

/-
!-- Specialize Vajda's identity at `i = j = r` and simplify `n + r + r = n + 2r`. -- !--

**Catalan's identity.** For all `n, r`,
`F(n+r)² − F(n)·F(n+2r) = (−1)^n · F(r)²`.
-/
theorem fib_catalan (n r : ℕ) :
    (Nat.fib (n + r) : ℤ) ^ 2 - (Nat.fib n : ℤ) * (Nat.fib (n + 2 * r) : ℤ)
      = (-1) ^ n * (Nat.fib r : ℤ) ^ 2 := by
  have h := fib_vajda n r r
  rw [show n + 2 * r = n + r + r by ring, pow_two, pow_two]
  linear_combination h

/-- Sanity check for Cassini at `n = 5`: `F(7)·F(5) − F(6)² = 13·5 − 8² = 65 − 64 = 1 = (−1)⁶`. -/
example : (Nat.fib 7 : ℤ) * (Nat.fib 5 : ℤ) - (Nat.fib 6 : ℤ) ^ 2 = (-1) ^ 6 := by
  decide

/-- Sanity check for Vajda at `n=2, i=3, j=4`:
`F(5)·F(6) − F(2)·F(9) = 5·8 − 1·34 = 40 − 34 = 6 = (−1)²·F(3)·F(4) = 2·3`. -/
example :
    (Nat.fib 5 : ℤ) * (Nat.fib 6 : ℤ) - (Nat.fib 2 : ℤ) * (Nat.fib 9 : ℤ)
      = (-1) ^ 2 * (Nat.fib 3 : ℤ) * (Nat.fib 4 : ℤ) := by
  decide

end FibonacciMatrix