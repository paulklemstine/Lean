import Mathlib.NumberTheory.LegendreSymbol.JacobiSymbol

/-!
# The free-symbol lemma: the product is free, the factors are the hard data

For distinct odd primes `p`, `q` and an integer `a`, the Jacobi symbol of `a`
modulo `pq` factors into the two Legendre symbols modulo `p` and `q`:

`(a/pq) = (a/p) · (a/q)`.

The left-hand side is the **Jacobi symbol**, computable from `a` and the single
number `pq` alone.  Each factor on the right is a **Legendre symbol modulo one
prime** — it is only defined once you have isolated that prime.  So the *product*
is free while the *factors* are exactly the hard data.

This is the formalisable core of killed direction #5 in `NegativeResults.lean`
(the "genus-character" reduction).  It is deliberately small: Mathlib already
has it as `jacobiSym.mul_right`, and the whole content is that single lemma.  The
fact that the interesting half of the genus-character story reduces to a one-line
multiplicativity fact is itself the strongest evidence that the story is
classical repackaging (Gauss, *Disquisitiones Arithmeticae*, 1801) rather than new
mathematics.

**Why it matters for factoring.**  The quantum route (Shor) succeeds precisely
when the two local characters *disagree*: order-finding returns `a^{r/2}`
and the algorithm factors iff `a` is a quadratic nonresidue modulo exactly one
of `p, q` — i.e. iff the Jacobi symbol `(a/pq) = -1` while one factor is `+1`.
The genus theory of classical number theory cannot produce such an `a` without
already knowing the factorization.  Same quadratic-character data; the quantum
access route is what the classical one lacks.
-/

namespace FactoringBarriers.FreeSymbol

/-- **Free-symbol lemma.**  The Jacobi symbol of `a` modulo `p * q` splits into
the Legendre symbols of `a` modulo `p` and modulo `q`.  The left-hand side is
determined by `a` and `p * q`; each factor on the right needs one of the primes
in isolation.  -/
theorem jacobiSym_mul_eq (a : ℤ) (p q : ℕ) [NeZero p] [NeZero q] :
    jacobiSym a (p * q) = jacobiSym a p * jacobiSym a q :=
  jacobiSym.mul_right a p q

/-- The lemma applied to a semiprime modulus: the free symbol `J(a | 15)` is the
product of the two local symbols `J(a | 3)` and `J(a | 5)`. -/
theorem semiprime_split {a : ℤ} :
    jacobiSym a (3 * 5) = jacobiSym a 3 * jacobiSym a 5 :=
  jacobiSym.mul_right a 3 5

/-- **Shor's condition, symbolically.**  If the Jacobi symbol is `-1`, the two
local Legendre symbols are *opposite*, so `a` is a nonresidue modulo exactly one
of the two primes — the situation that yields a factor by order-finding.  From
`(a/p)·(a/q) = -1` and each factor in `{-1, 0, 1}`, they must be `1` and `-1`
in some order. -/
theorem jacobi_neg_one_disagrees {a : ℤ} (p q : ℕ) [NeZero p] [NeZero q]
    (ha : jacobiSym a (p * q) = -1) :
    jacobiSym a p = -1 ∧ jacobiSym a q = 1 ∨
      jacobiSym a p = 1 ∧ jacobiSym a q = -1 := by
  have hmul : jacobiSym a p * jacobiSym a q = -1 := by
    rw [← jacobiSym.mul_right a p q, ha]
  -- each factor is a unit of `ℤ` (its partner's negative is its inverse), and the
  -- only units of `ℤ` are `±1`.
  have hp : jacobiSym a p = 1 ∨ jacobiSym a p = -1 := by
    have hx : jacobiSym a p * -(jacobiSym a q) = 1 := by
      rw [mul_neg, hmul]; norm_num
    exact Int.isUnit_iff.mp ⟨Units.mkOfMulEqOne (jacobiSym a p) (-(jacobiSym a q)) hx, rfl⟩
  have hq : jacobiSym a q = 1 ∨ jacobiSym a q = -1 := by
    have hy : jacobiSym a q * -(jacobiSym a p) = 1 := by
      rw [mul_neg, mul_comm (jacobiSym a q) (jacobiSym a p), hmul, neg_neg]
    exact Int.isUnit_iff.mp ⟨Units.mkOfMulEqOne (jacobiSym a q) (-(jacobiSym a p)) hy, rfl⟩
  rcases hp with hp | hp <;> rcases hq with hq | hq
  · -- x = 1, y = 1 gives product 1, contradicting hmul
    simp_all
  · exact Or.inr ⟨hp, hq⟩
  · exact Or.inl ⟨hp, hq⟩
  · -- x = -1, y = -1 gives product 1, contradicting hmul
    simp_all

end FactoringBarriers.FreeSymbol
