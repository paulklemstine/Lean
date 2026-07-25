import Mathlib

/-!
# The mod-3 sign law for Ramanujan's third-order mock theta function `ρ(q)`

Ramanujan's third-order mock theta function is
`ρ(q) = ∑_{m≥0} q^{2m(m+1)} / ∏_{j=0}^{m} (1 + q^{2j+1} + q^{4j+2})`.
Writing `ρ(q) = ∑_n r(n) qⁿ`, the coefficients obey the **mod-3 sign law**

* `r(3n)   > 0`,
* `r(3n+1) ≤ 0`,
* `r(3n+2) ≤ 0`.

This file formalises the sign law on a verified finite range, following a strict
anti-circularity discipline:

* **Layer 0 (pure computation).**  We implement truncated power-series arithmetic
  (`padd`, `pmul`, `pinv`, `monomial`) on `Vector ℤ prec`, build the truncated
  product `factor m`, the truncated series `rho`, and extract coefficients
  `r : ℕ → ℤ`.  The definition of `r` is *purely computational*: it mentions no
  inequality, no sign property, and no theorem.

* **Layer 2 (bounded sign law).**  Each of the three sign statements is proved
  **independently** by `native_decide` over the bounded range `n < B`.  Each
  proof checks finitely many concrete integers; there is no induction and no
  appeal to any other sign-law theorem, so circularity is impossible.

* **Layer 3 (combined theorem).**  `sign_law` merely conjoins the three
  independent results; it introduces no new proof content.

The companion algebraic identity (Layer 1) lives in the *separate* file
`Computation.RamanujanRhoCyclotomic`, which is independent of this file.

The bound `B = 100` satisfies `3 * B < prec`, so every coefficient referenced
below lies inside the truncation window.
-/

namespace RamanujanRho

/-! ## Layer 0: Pure computation -/

/-- Truncation precision: we work modulo `q^prec`. -/
abbrev prec : ℕ := 301

/-- Coefficient of `qʲ` in a truncated series, returning `0` outside the window. -/
def vget (a : Vector ℤ prec) (j : ℕ) : ℤ := a.toArray.getD j 0

/-- The zero series. -/
def pzero : Vector ℤ prec := .ofFn (fun _ => 0)

/-- The monomial `qᵏ` (truncated to the window). -/
def monomial (k : ℕ) : Vector ℤ prec :=
  .ofFn (fun i : Fin prec => if (i : ℕ) = k then 1 else 0)

/-- Truncated addition of power series. -/
def padd (a b : Vector ℤ prec) : Vector ℤ prec :=
  .ofFn (fun i : Fin prec => vget a i + vget b i)

/-- Truncated (Cauchy) product of power series. -/
def pmul (a b : Vector ℤ prec) : Vector ℤ prec :=
  .ofFn (fun i : Fin prec => ∑ j ∈ Finset.range (i.1 + 1), vget a j * vget b (i.1 - j))

/-- Coefficient list of the multiplicative inverse of a series with constant
term `1`.  Uses the recurrence `b₀ = 1`, `bᵢ = -∑_{k=1}^{i} aₖ b_{i-k}`. -/
def pinvList (a : Vector ℤ prec) : List ℤ :=
  (List.range prec).foldl (fun acc i =>
    if i = 0 then acc ++ [1]
    else
      let s := (List.range i).foldl (fun t j => t + vget a (i - j) * acc.getD j 0) 0
      acc ++ [-s]) []

/-- Truncated multiplicative inverse of a power series with constant term `1`. -/
def pinv (a : Vector ℤ prec) : Vector ℤ prec :=
  .ofFn (fun i : Fin prec => (pinvList a).getD i 0)

/-- The truncated finite product `∏_{j=0}^{m} (1 + q^{2j+1} + q^{4j+2})`. -/
def factor (m : ℕ) : Vector ℤ prec :=
  (List.range (m + 1)).foldl
    (fun acc j => pmul acc (padd (padd (monomial 0) (monomial (2 * j + 1))) (monomial (4 * j + 2))))
    (monomial 0)

/-- Number of summands of `ρ` that can contribute below degree `prec`.
Since `2·12·13 = 312 ≥ prec`, summands with `m ≥ 13` contribute nothing in the
window, so `13` terms suffice. -/
def numTerms : ℕ := 13

/-- The truncated power series of `ρ(q) = ∑_m q^{2m(m+1)} / ∏_{j=0}^{m}(1+q^{2j+1}+q^{4j+2})`. -/
def rho : Vector ℤ prec :=
  (List.range numTerms).foldl
    (fun acc m => padd acc (pmul (monomial (2 * m * (m + 1))) (pinv (factor m)))) pzero

/-- The coefficient `r(n)` of `qⁿ` in `ρ(q)`.  Purely computational: no sign
property, no inequality, no reference to any theorem. -/
def r (n : ℕ) : ℤ := vget rho n

/-! ## Layer 2: Bounded sign law (each proved independently by `native_decide`)

The bound is fixed here; note `3 * B = 300 < prec = 301`. -/

/-- The verified bound for the sign law. -/
abbrev B : ℕ := 100

/-- `3 * B < prec`, so all referenced coefficients lie inside the window. -/
theorem three_B_lt_prec : 3 * B < prec := by decide

/-- Sign law, residue `0`: `r(3n) > 0` for all `n < B`. -/
theorem r_three_mul_pos : ∀ n : ℕ, n < B → r (3 * n) > 0 := by native_decide

/-- Sign law, residue `1`: `r(3n+1) ≤ 0` for all `n < B`. -/
theorem r_three_mul_add_one_nonpos : ∀ n : ℕ, n < B → r (3 * n + 1) ≤ 0 := by native_decide

/-- Sign law, residue `2`: `r(3n+2) ≤ 0` for all `n < B`. -/
theorem r_three_mul_add_two_nonpos : ∀ n : ℕ, n < B → r (3 * n + 2) ≤ 0 := by native_decide

/-! ## Layer 3: Combined theorem -/

/-- The mod-3 sign law on the verified range `n < B`.  This merely conjoins the
three independent `native_decide` results above. -/
theorem sign_law (n : ℕ) (hn : n < B) :
    r (3 * n) > 0 ∧ r (3 * n + 1) ≤ 0 ∧ r (3 * n + 2) ≤ 0 :=
  ⟨r_three_mul_pos n hn, r_three_mul_add_one_nonpos n hn, r_three_mul_add_two_nonpos n hn⟩

/-! ## Zero set

Within the verified window the vanishing coefficients are exactly
`{2, 4, 8, 11, 20}`. -/

/-- The coefficients that vanish in the range `n < 3 * B` are exactly
`{2, 4, 8, 11, 20}`. -/
theorem zero_set :
    (List.range (3 * B)).filter (fun n => decide (r n = 0)) = [2, 4, 8, 11, 20] := by
  native_decide

end RamanujanRho