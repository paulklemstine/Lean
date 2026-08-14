import MachineLearning.FreeWitnessTraceLemma

/-!
# The classification theorem for power-shaped free witnesses

Cycle 2.  `FreeWitnessTraceLemma.lean` isolated the abstract mechanism; this file proves
the two halves of the classification *simultaneously and in general*, for every witness
whose local weight has the affine-power shape `w x = a x^k + c`:

* **Factoring-completeness** (`SemiprimeWitness.affinePower_recovery`): the aggregate
  determines the power sum `p^k + q^k`, hence — through the three recovery channels
  below — the factorisation.

* **Non-polynomiality** (`powerWeight_not_polynomial`): for `k ≥ 1` and `c ≠ 0` no
  integer polynomial in `N` agrees with the aggregate on all odd semiprimes.  This is a
  rigidity theorem, proved from the infinitude of primes: fixing one prime `r` forces
  `P(r X) = (r^k + c)(X^k + c)` as an identity of polynomials, and the two evaluations
  `P(3 · 10) = P(5 · 6)` then collide, because `10^k + 3^k ≠ 6^k + 5^k` for `k ≥ 1`.
  So a *non-polynomial local weight forces a non-polynomial aggregate* — the exact
  implication asserted, but not proved, in the source paper.

* **The three recovery channels of the trace lemma** (§2 of the paper) are all shown to
  be complete: `two_mul_max_eq` (trace ⇒ `max(p,q)`), `factor_of_max` (`max` ⇒ the other
  factor), `residue_channel` (a residue vector modulo a large enough modulus ⇒ the
  factor).  Together with `pair_determined_of_sum_prod` this is the statement that the
  information content of a recoverable witness is exactly one factor-secret coordinate.

* `classification_of_powerWeight` packages both halves into a single statement.
-/

namespace FreeWitness

open Polynomial

/-! ## Affine-power local weights: recovery -/

namespace SemiprimeWitness

variable (F : SemiprimeWitness)

/-- **Recovery for an affine-power local weight** `w x = a x^k + c`:
`a c (p^k + q^k) = W(N) - a² N^k - c²`.  With `a = 1` this is
`SemiprimeWitness.powerSum_recovery`. -/
theorem affinePower_recovery {k : ℕ} {a c : ℤ} {p q : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q)
    (hwp : F.w p = a * (p : ℤ) ^ k + c) (hwq : F.w q = a * (q : ℤ) ^ k + c) :
    a * c * ((p : ℤ) ^ k + (q : ℤ) ^ k) = F.W (p * q) - a ^ 2 * ((p : ℤ) * q) ^ k - c ^ 2 := by
  rw [F.factorizes hp hq hp2 hq2 hpq, hwp, hwq, mul_pow]
  ring

end SemiprimeWitness

/-! ## The three recovery channels -/

/-- **Trace channel ⇒ max channel.**  From the trace `s = p + q` and `N = p q` one gets
the larger factor: `2 max(p,q) = s + √(s² - 4N)`. -/
theorem two_mul_max_eq {p q : ℕ} (hpq : p ≤ q) :
    2 * q = (p + q) + Nat.sqrt ((p + q) ^ 2 - 4 * (p * q)) := by
  obtain ⟨d, rfl⟩ : ∃ d, q = p + d := ⟨q - p, by omega⟩
  have hsq : (p + (p + d)) ^ 2 - 4 * (p * (p + d)) = d ^ 2 := by
    have : (p + (p + d)) ^ 2 = d ^ 2 + 4 * (p * (p + d)) := by ring
    omega
  rw [hsq, Nat.sqrt_eq']
  omega

/-- **Max channel ⇒ complete factorisation.**  Knowing one factor gives the other. -/
theorem factor_of_max {p q N : ℕ} (hq : q ≠ 0) (hN : p * q = N) : p = N / q := by
  subst hN
  exact (Nat.mul_div_cancel (m := p) (Nat.pos_of_ne_zero hq)).symm

/-- **Residue channel.**  A residue vector pins the factor down as soon as its modulus
exceeds the factor: this is why "order/residue vector" witnesses are recoverable. -/
theorem residue_channel {p p' M : ℕ} (hp : p < M) (hp' : p' < M) (h : p % M = p' % M) :
    p = p' := by
  rwa [Nat.mod_eq_of_lt hp, Nat.mod_eq_of_lt hp'] at h

/-! ## Non-polynomiality of every power-shaped witness -/

/-- `2 · 6^k ≤ 10^k` for `k ≥ 2`. -/
lemma two_mul_six_pow_le (k : ℕ) (hk : 2 ≤ k) : 2 * 6 ^ k ≤ 10 ^ k := by
  induction k with
  | zero => omega
  | succ n ih =>
    rcases Nat.lt_or_ge n 2 with hn | hn
    · interval_cases n
      · omega
      · norm_num
    · have h := ih (by omega)
      calc 2 * 6 ^ (n + 1) = 6 * (2 * 6 ^ n) := by ring
        _ ≤ 6 * 10 ^ n := Nat.mul_le_mul_left 6 h
        _ ≤ 10 * 10 ^ n := Nat.mul_le_mul_right _ (by omega)
        _ = 10 ^ (n + 1) := by ring

/-- The arithmetic separation at the heart of the rigidity argument:
`6^k + 5^k < 10^k + 3^k` for every `k ≥ 1`. -/
lemma six_pow_add_five_pow_lt (k : ℕ) (hk : 1 ≤ k) : 6 ^ k + 5 ^ k < 10 ^ k + 3 ^ k := by
  rcases Nat.lt_or_ge k 2 with hk1 | hk2
  · interval_cases k
    · norm_num
  · have h5 : (5 : ℕ) ^ k ≤ 6 ^ k := Nat.pow_le_pow_left (by omega) k
    have h := two_mul_six_pow_le k hk2
    have h3 : 0 < (3 : ℕ) ^ k := Nat.pow_pos (by omega)
    omega

/-- **Rigidity.**  If some integer polynomial computes the aggregate on all odd
semiprimes, then fixing one odd prime `r` and letting the other prime run over the
infinitely many remaining primes forces the *polynomial identity*
`P(r X) = (r^k + c)(X^k + c)`. -/
lemma comp_eq_of_witness_poly (F : SemiprimeWitness) {k : ℕ} {c : ℤ}
    (hw : ∀ s : ℕ, s.Prime → s ≠ 2 → F.w s = (s : ℤ) ^ k + c)
    {P : Polynomial ℤ}
    (hP : ∀ p q : ℕ, p.Prime → q.Prime → p ≠ 2 → q ≠ 2 → p ≠ q →
      F.W (p * q) = P.eval ((p : ℤ) * q))
    {r : ℕ} (hr : r.Prime) (hr2 : r ≠ 2) :
    P.comp (C (r : ℤ) * X) = C ((r : ℤ) ^ k + c) * (X ^ k + C c) := by
  refine Polynomial.eq_of_infinite_eval_eq _ _ ?_
  have hS : ({q : ℕ | q.Prime} \ {r, 2}).Infinite :=
    Nat.infinite_setOf_prime.diff (Set.toFinite {r, 2})
  have hinj : Set.InjOn (fun n : ℕ => (n : ℤ)) ({q : ℕ | q.Prime} \ {r, 2}) := by
    intro a _ b _ hab
    simpa using hab
  refine (hS.image hinj).mono ?_
  rintro x ⟨q, hq, rfl⟩
  have hqp : q.Prime := hq.1
  have hq2 : q ≠ 2 := fun h => hq.2 (by simp [h])
  have hqr : r ≠ q := fun h => hq.2 (by simp [h])
  have hval : F.W (r * q) = P.eval ((r : ℤ) * q) := hP r q hr hqp hr2 hq2 hqr
  have hloc : F.W (r * q) = F.w r * F.w q := F.factorizes hr hqp hr2 hq2 hqr
  simp only [Set.mem_setOf_eq, eval_comp, eval_mul, eval_add, eval_pow, eval_C, eval_X]
  rw [← hval, hloc, hw r hr hr2, hw q hqp hq2]

/-- **The non-polynomial half of the classification, in general.**  A witness whose local
weight is `x^k + c` with `k ≥ 1` and `c ≠ 0` is *not* an integer polynomial in the
modulus: no `P ∈ ℤ[X]` satisfies `W(pq) = P(pq)` for all pairs of distinct odd primes.
The scalar therefore genuinely depends on `p` and `q` separately. -/
theorem powerWeight_not_polynomial (F : SemiprimeWitness) {k : ℕ} {c : ℤ}
    (hk : 1 ≤ k) (hc : c ≠ 0)
    (hw : ∀ s : ℕ, s.Prime → s ≠ 2 → F.w s = (s : ℤ) ^ k + c) :
    ∀ P : Polynomial ℤ, ¬ (∀ p q : ℕ, p.Prime → q.Prime → p ≠ 2 → q ≠ 2 → p ≠ q →
      F.W (p * q) = P.eval ((p : ℤ) * q)) := by
  intro P hP
  have h3 := comp_eq_of_witness_poly F hw hP (r := 3) (by norm_num) (by norm_num)
  have h5 := comp_eq_of_witness_poly F hw hP (r := 5) (by norm_num) (by norm_num)
  have e3 : P.eval 30 = ((3 : ℤ) ^ k + c) * (10 ^ k + c) := by
    have := congrArg (fun R => Polynomial.eval (10 : ℤ) R) h3
    simpa using this
  have e5 : P.eval 30 = ((5 : ℤ) ^ k + c) * (6 ^ k + c) := by
    have := congrArg (fun R => Polynomial.eval (6 : ℤ) R) h5
    simpa using this
  have h30 : ((3 : ℤ) ^ k + c) * (10 ^ k + c) = ((5 : ℤ) ^ k + c) * (6 ^ k + c) := by
    rw [← e3, ← e5]
  have hmul1 : (3 : ℤ) ^ k * 10 ^ k = 30 ^ k := by rw [← mul_pow]; norm_num
  have hmul2 : (5 : ℤ) ^ k * 6 ^ k = 30 ^ k := by rw [← mul_pow]; norm_num
  have hkey : c * ((10 : ℤ) ^ k + 3 ^ k) = c * (6 ^ k + 5 ^ k) := by nlinarith [h30, hmul1, hmul2]
  have key : (10 : ℤ) ^ k + 3 ^ k = 6 ^ k + 5 ^ k := mul_left_cancel₀ hc hkey
  have hnat : (6 : ℕ) ^ k + 5 ^ k < 10 ^ k + 3 ^ k := six_pow_add_five_pow_lt k hk
  have hZ : (6 : ℤ) ^ k + 5 ^ k < 10 ^ k + 3 ^ k := by exact_mod_cast hnat
  linarith [key, hZ]

/-- **The classification theorem for power-shaped witnesses.**  Both halves at once: a
CRT-multiplicative witness with local weight `x^k + c` (`k ≥ 1`, `c ≠ 0`) is
*factoring-complete* — its value at `N = pq` returns the power sum `p^k + q^k`, from
which the factors follow by the recovery channels — and *non-polynomial* in `N`. -/
theorem classification_of_powerWeight (F : SemiprimeWitness) {k : ℕ} {c : ℤ}
    (hk : 1 ≤ k) (hc : c ≠ 0)
    (hw : ∀ s : ℕ, s.Prime → s ≠ 2 → F.w s = (s : ℤ) ^ k + c) :
    (∀ p q : ℕ, p.Prime → q.Prime → p ≠ 2 → q ≠ 2 → p ≠ q →
        c * ((p : ℤ) ^ k + (q : ℤ) ^ k) = F.W (p * q) - ((p : ℤ) * q) ^ k - c ^ 2)
      ∧ (∀ P : Polynomial ℤ, ¬ (∀ p q : ℕ, p.Prime → q.Prime → p ≠ 2 → q ≠ 2 → p ≠ q →
        F.W (p * q) = P.eval ((p : ℤ) * q))) := by
  refine ⟨?_, powerWeight_not_polynomial F hk hc hw⟩
  intro p q hp hq hp2 hq2 hpq
  exact F.powerSum_recovery hp hq hp2 hq2 hpq (hw p hp hp2) (hw q hq hq2)

/-! ### Lab notes (cycle 2)

Rigidity evaluation table (the two candidate values of `P(30)`), for the local weight
`x^k + c`:

```
k :  1        2         3           c-coefficient identity forced
     (3+c)(10+c) = (5+c)(6+c)   →  13c = 11c   → c = 0
     (9+c)(100+c) = (25+c)(36+c) → 109c = 61c  → c = 0
     (27+c)(1000+c) = (125+c)(216+c) → 1027c = 341c → c = 0
```
In every case `10^k + 3^k > 6^k + 5^k`, so `c = 0`: a non-trivial constant term in the
local weight is incompatible with a polynomial closed form in `N`.
-/

example : (10 : ℕ) ^ 1 + 3 ^ 1 ≠ 6 ^ 1 + 5 ^ 1 := by norm_num

example : (10 : ℕ) ^ 3 + 3 ^ 3 ≠ 6 ^ 3 + 5 ^ 3 := by norm_num

end FreeWitness