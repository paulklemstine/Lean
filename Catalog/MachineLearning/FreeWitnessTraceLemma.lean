import MachineLearning.HalfPlaneClosedForm

/-!
# The CRT-multiplicative free-witness classification: the trace lemma

This file formalises the *abstract skeleton* of the free-witness classification of
`16_FreeWitness_Classification.md`.  The informal claim is:

> a counting aggregate over a CRT-separable domain whose local weights are
> non-polynomial and CRT-multiplicative is a "free witness": it determines the
> factorisation of a semiprime, and it is not a polynomial function of the modulus.

Both halves of that claim are made precise and proved here, in the only regime where
the claim has content, namely semiprimes `N = p q`:

* `SemiprimeWitness` — a value function `W : ℕ → ℤ` on moduli together with a *local
  weight* `w : ℕ → ℤ`, such that `W (p q) = w p * w q` for distinct odd primes.
  This is the "CRT-multiplicative" hypothesis, stripped of any particular model.

* `SemiprimeWitness.powerSum_recovery` — **the trace lemma in its general form.**
  If the local weight has the *power shape* `w x = x ^ k + c` with `c ≠ 0`, then
  `c * (p ^ k + q ^ k) = W (p q) - (p q) ^ k - c ^ 2`.
  The witness value therefore hands over one factor-secret coordinate, the power sum
  `p ^ k + q ^ k`, and nothing else is needed.

* `SemiprimeWitness.trace_recovery` — the case `k = 1`: the *trace* `s = p + q` is
  read off from `W (p q)`.

* `vieta_roots`, `pair_determined_of_sum_prod` — once the trace is known both factors
  are pinned down: they are the roots of `X ^ 2 - s X + N`, and no other pair of
  positive integers has that sum and that product.  This is the "information content
  of every witness is one factor-secret coordinate" statement.

* `not_polynomial_of_not_dvd` — **the polynomial barrier, in sharp form.**  For an
  integer polynomial `P` one always has `a - b ∣ P(a) - P(b)`.  So a single pair of
  moduli `N₁, N₂` with `N₁ - N₂ ∤ W N₁ - W N₂` *proves* that `W` agrees with no
  integer polynomial on any set containing `N₁, N₂`.  This is exactly the proof
  direction sketched in §5 of the paper (a congruence separation), and it is
  unconditional.

* `circleWitness`, `circleCount_not_polynomial` — the classification applied to the
  catalog's modular circle count `HalfPlane.circleCount`.  The local weight is
  `p - χ_p(-1)`; for Blum primes it has power shape `x + 1`, so the trace lemma
  reproves (and generalises) `HalfPlane.sum_of_primes_from_circleCount`, and the
  divisibility criterion shows `C` is not a polynomial in `N`.

Nothing here assumes anything about *how* `W` is computed; the classification is a
statement about the shape of the local weight only.
-/

namespace FreeWitness

open Finset

/-! ## The abstract witness -/

/-- A **CRT-multiplicative semiprime witness**: a global value `W N` attached to each
modulus, which on a product of two distinct odd primes factors as a product of local
weights `w p * w q`.  This is the abstract form of the "CRT decomposition + local
weight" layer of the free-witness mechanism. -/
structure SemiprimeWitness where
  /-- the aggregate, as a function of the modulus -/
  W : ℕ → ℤ
  /-- the local weight, a function of a single prime -/
  w : ℕ → ℤ
  /-- CRT-multiplicativity on semiprimes -/
  factorizes : ∀ {p q : ℕ}, p.Prime → q.Prime → p ≠ 2 → q ≠ 2 → p ≠ q →
    W (p * q) = w p * w q

namespace SemiprimeWitness

variable (F : SemiprimeWitness)

/-- **The trace lemma, general (power-weight) form.**  If the local weights of the two
primes have the shape `x ^ k + c` with `c ≠ 0`, then the aggregate determines the power
sum `p ^ k + q ^ k`:
`c * (p ^ k + q ^ k) = W (p q) - (p q) ^ k - c ^ 2`.

Only `c ≠ 0` is used to make the recovery an equality of the *scaled* power sum; see
`powerSum_recovery_one` for the (ubiquitous) case `c = 1`. -/
theorem powerSum_recovery {k : ℕ} {c : ℤ} {p q : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q)
    (hwp : F.w p = (p : ℤ) ^ k + c) (hwq : F.w q = (q : ℤ) ^ k + c) :
    c * ((p : ℤ) ^ k + (q : ℤ) ^ k) = F.W (p * q) - ((p : ℤ) * q) ^ k - c ^ 2 := by
  have h := F.factorizes hp hq hp2 hq2 hpq
  rw [h, hwp, hwq, mul_pow]
  ring

/-- The trace lemma with unit local constant, `w x = x ^ k + 1`:
`p ^ k + q ^ k = W (p q) - N ^ k - 1`. -/
theorem powerSum_recovery_one {k : ℕ} {p q : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q)
    (hwp : F.w p = (p : ℤ) ^ k + 1) (hwq : F.w q = (q : ℤ) ^ k + 1) :
    (p : ℤ) ^ k + (q : ℤ) ^ k = F.W (p * q) - ((p : ℤ) * q) ^ k - 1 := by
  have := F.powerSum_recovery hp hq hp2 hq2 hpq hwp hwq
  linarith

/-- **The trace lemma** (`k = 1`): a witness whose local weight is `x + 1` returns the
trace `s = p + q`. -/
theorem trace_recovery {p q : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q)
    (hwp : F.w p = (p : ℤ) + 1) (hwq : F.w q = (q : ℤ) + 1) :
    (p : ℤ) + q = F.W (p * q) - ((p : ℤ) * q) - 1 := by
  have := F.powerSum_recovery_one (k := 1) hp hq hp2 hq2 hpq (by simpa using hwp)
    (by simpa using hwq)
  simpa using this

/-- The `k = 2` witness (the SIGK shape) returns `p ^ 2 + q ^ 2`, hence the *square of
the trace*, since `(p + q) ^ 2 = p ^ 2 + q ^ 2 + 2 N`. -/
theorem trace_sq_recovery {p q : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q)
    (hwp : F.w p = (p : ℤ) ^ 2 + 1) (hwq : F.w q = (q : ℤ) ^ 2 + 1) :
    ((p : ℤ) + q) ^ 2 = F.W (p * q) - ((p : ℤ) * q) ^ 2 + 2 * ((p : ℤ) * q) - 1 := by
  have := F.powerSum_recovery_one (k := 2) hp hq hp2 hq2 hpq hwp hwq
  nlinarith [this]

end SemiprimeWitness

/-! ## From the trace to the factors -/

/-- **Vieta.**  Both factors are roots of `X ^ 2 - s X + N` with `s = p + q`, `N = p q`,
coefficients that the trace lemma computes from the witness value. -/
theorem vieta_roots {p q : ℕ} (X : ℤ) (hX : X = p ∨ X = q) :
    X ^ 2 - ((p : ℤ) + q) * X + (p : ℤ) * q = 0 := by
  rcases hX with rfl | rfl <;> ring

/-- **The trace is a complete factor-secret coordinate.**  A pair of positive integers
is determined, as an unordered pair, by its sum and its product.  Together with
`SemiprimeWitness.trace_recovery` this says: the witness value *is* the factorisation.
-/
theorem pair_determined_of_sum_prod {p q p' q' : ℕ} (hp' : p' ≠ 0)
    (hprod : p * q = p' * q') (hsum : p + q = p' + q') :
    (p' = p ∧ q' = q) ∨ (p' = q ∧ q' = p) := by
  have hprodZ : (p' : ℤ) * q' = (p : ℤ) * q := by exact_mod_cast hprod.symm
  have hsumZ : (p' : ℤ) + q' = (p : ℤ) + q := by exact_mod_cast hsum.symm
  have key : ((p' : ℤ) - p) * ((p' : ℤ) - q) = 0 := by nlinarith [hprodZ, hsumZ]
  have hp'Z : (p' : ℤ) ≠ 0 := Int.natCast_ne_zero.mpr hp'
  rcases mul_eq_zero.mp key with h | h
  · have hpp : p' = p := by exact_mod_cast sub_eq_zero.mp h
    subst hpp
    have : (q' : ℤ) = q := mul_left_cancel₀ hp'Z hprodZ
    exact Or.inl ⟨rfl, by exact_mod_cast this⟩
  · have hpq : p' = q := by exact_mod_cast sub_eq_zero.mp h
    subst hpq
    have : (q' : ℤ) = p := by linarith [hsumZ]
    exact Or.inr ⟨rfl, by exact_mod_cast this⟩

/-! ## The polynomial barrier -/

/-- **No integer polynomial can reproduce a witness that violates the difference
divisibility.**  For `P ∈ ℤ[X]` one always has `a - b ∣ P a - P b`; so a single pair of
moduli where the witness difference is not divisible by the modulus difference rules out
*every* polynomial formula.  (This is the sharp, unconditional form of the congruence
separation proposed in §5 of the paper.) -/
theorem not_polynomial_of_not_dvd {W : ℕ → ℤ} {S : Set ℕ} {N₁ N₂ : ℕ}
    (h₁ : N₁ ∈ S) (h₂ : N₂ ∈ S)
    (hdvd : ¬ ((N₁ : ℤ) - N₂ ∣ W N₁ - W N₂)) :
    ∀ P : Polynomial ℤ, ¬ (∀ n ∈ S, W n = P.eval (n : ℤ)) := by
  intro P hP
  apply hdvd
  rw [hP N₁ h₁, hP N₂ h₂]
  exact Polynomial.sub_dvd_eval_sub _ _ P

/-- A convenient congruence form: if `W` were a polynomial in `N`, then `N₁ ≡ N₂ [ZMOD m]`
would force `W N₁ ≡ W N₂ [ZMOD m]`.  Failure of the latter is the "mod `2 ^ k`
separation" of §5. -/
theorem modEq_of_polynomial {W : ℕ → ℤ} {S : Set ℕ} {P : Polynomial ℤ}
    (hP : ∀ n ∈ S, W n = P.eval (n : ℤ)) {N₁ N₂ : ℕ} (h₁ : N₁ ∈ S) (h₂ : N₂ ∈ S)
    {m : ℤ} (hm : m ∣ (N₁ : ℤ) - N₂) : m ∣ W N₁ - W N₂ := by
  rw [hP N₁ h₁, hP N₂ h₂]
  exact hm.trans (Polynomial.sub_dvd_eval_sub _ _ P)

/-! ## Instance: the modular circle count (CIRC) -/

open HalfPlane

/-- The catalog's modular circle count `C(N) = #{(x,y) : x² + y² ≡ 1 mod N}`, packaged as
a CRT-multiplicative semiprime witness with local weight `p - χ_p(-1)`. -/
def circleWitness : SemiprimeWitness where
  W N := (circleCount N : ℤ)
  w p := if p % 4 = 1 then (p : ℤ) - 1 else (p : ℤ) + 1
  factorizes := by
    intro p q hp hq hp2 hq2 hpq
    have h := circleCount_semiprime hp hq hp2 hq2 hpq
    have hp1 : 1 ≤ p := hp.one_lt.le.trans' (by norm_num)
    have hq1 : 1 ≤ q := hq.one_lt.le.trans' (by norm_num)
    rw [h]
    by_cases h4p : p % 4 = 1 <;> by_cases h4q : q % 4 = 1 <;>
      simp only [h4p, h4q, if_true, if_false] <;> push_cast [Nat.cast_sub hp1, Nat.cast_sub hq1] <;>
      ring

@[simp] lemma circleWitness_W (N : ℕ) : circleWitness.W N = (circleCount N : ℤ) := rfl

lemma circleWitness_w_three_mod_four {p : ℕ} (h : p % 4 = 3) :
    circleWitness.w p = (p : ℤ) + 1 := by
  have : ¬ (p % 4 = 1) := by omega
  simp [circleWitness, this]

/-- **The trace lemma for CIRC.**  For Blum-type semiprimes the circle count returns the
trace, `p + q = C(N) - N - 1`.  (Integer form of the catalog's
`HalfPlane.sum_of_primes_from_circleCount`, obtained here as an instance of the abstract
trace lemma.) -/
theorem circle_trace {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h3p : p % 4 = 3) (h3q : q % 4 = 3) (hpq : p ≠ q) :
    (p : ℤ) + q = (circleCount (p * q) : ℤ) - ((p : ℤ) * q) - 1 :=
  circleWitness.trace_recovery hp hq (by omega) (by omega) hpq
    (circleWitness_w_three_mod_four h3p) (circleWitness_w_three_mod_four h3q)

/-- **The circle count is not a polynomial in the modulus.**  Witness pair:
`C(21) = 32`, `C(15) = 16`, and `21 - 15 = 6` does not divide `32 - 16 = 16`.
Hence no `P ∈ ℤ[X]` satisfies `C(N) = P(N)` on the set of odd squarefree semiprimes —
the "non-polynomial" half of the classification, unconditionally. -/
theorem circleCount_not_polynomial :
    ∀ P : Polynomial ℤ, ¬ (∀ n ∈ ({15, 21} : Set ℕ), (circleCount n : ℤ) = P.eval (n : ℤ)) := by
  refine not_polynomial_of_not_dvd (W := fun n => (circleCount n : ℤ)) (S := ({15, 21} : Set ℕ))
    (N₁ := 21) (N₂ := 15) (by simp) (by simp) ?_
  have h21 : circleCount 21 = 32 := by decide
  have h15 : circleCount 15 = 16 := by decide
  simp only [h21, h15]
  norm_num

/-! ### Lab notes (cycle 1)

```
N = p·q   C(N)   local weights        trace   C(N) - N - 1
21 = 3·7    32   (3+1)(7+1)             10        10   ✓
33 = 3·11   48   (3+1)(11+1)            14        14   ✓
57 = 3·19   80   (3+1)(19+1)            22        22   ✓
15 = 3·5    16   (3+1)(5-1)      (5 ≡ 1 mod 4: not a Blum pair)
```
Difference test for the polynomial barrier:
`21 - 15 = 6`, `C(21) - C(15) = 16`, and `6 ∤ 16`.
-/

example : circleCount 21 - circleCount 15 = 16 := by decide

end FreeWitness