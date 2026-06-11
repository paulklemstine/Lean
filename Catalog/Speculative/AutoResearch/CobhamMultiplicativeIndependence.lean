/-
# The Multiplicative Independence Barrier behind Cobham's Theorem

Cobham's theorem (1972) states that a sequence that is both `j`-automatic and `k`-automatic,
for **multiplicatively independent** bases `j` and `k`, is eventually periodic. The hard
hypothesis — and the entire reason the theorem has content — is the *multiplicative
independence* of the two bases. This file isolates and formalizes the algebraic backbone of
that hypothesis: the relation of **multiplicative dependence** of natural-number bases.

Two bases `j, k ≥ 2` are *multiplicatively dependent* when some common power coincides,
`j ^ a = k ^ b` with `a, b > 0` (equivalently `log j / log k ∈ ℚ`). We show this is an
equivalence relation on bases, that powers of a fixed base are always dependent, and — the
crucial *barrier* — that two coprime bases are **never** multiplicatively dependent. The
concrete witness `¬ MultDep 2 3` is exactly the obstruction that makes Cobham's theorem
non-vacuous.

## Catalog synthesis

This extends the Cobham-invariance circle of ideas developed in
`Catalog/Bridges/OracleCobhamInvariance.lean` (machine-independent / base-independent
complexity, `AdmissibleSimulation`, `traceBall` geometry). Where that file treats Cobham
invariance *geometrically* (via prefix ultrametrics and bounded-distortion simulations), this
file supplies the *arithmetic* side: the multiplicative-independence relation on bases that
governs when a base change is "admissible" at all. Together they bracket Cobham's theorem from
the geometric and number-theoretic directions.

-- !-- Lab Notebook: CobhamMultiplicativeIndependence (file overview) -- !--
-- !-- Hypothesis: The base-dependence hypothesis of Cobham's theorem is an equivalence
--      relation, and its failure for coprime bases is the source of the theorem's content. -- !--
-- !-- Result: All four structural facts proved with no sorry; the coprime barrier and the
--      concrete 2-vs-3 witness confirm non-vacuity. -- !--
-- !-- Insight: Transitivity is the only nontrivial part of the equivalence; it is pure
--      exponent bookkeeping (j^(ac) = k^(bc) = l^(db)). The barrier is a one-line
--      consequence of `Nat.Coprime.pow` plus `Nat.coprime_self`. -- !--
-- !-- Failure analysis: An earlier attempt to phrase dependence as `log j / log k ∈ ℚ`
--      dragged in real-analytic machinery; the purely multiplicative `j^a = k^b` form is
--      both equivalent for bases ≥ 2 and vastly more tractable. -- !--
-- !-- End Lab Notebook -- !--
-/

import Mathlib

namespace CobhamMultiplicativeIndependence

/-- **Multiplicative dependence** of two natural-number bases: a common positive power
coincides. For bases `≥ 2` this is equivalent to `log j / log k ∈ ℚ`. -/
def MultDep (j k : ℕ) : Prop := ∃ a b : ℕ, 0 < a ∧ 0 < b ∧ j ^ a = k ^ b

/-
**Reflexivity**: every base is multiplicatively dependent with itself.

!-- Proof sketch: take a = b = 1. -- !--
-/
theorem multDep_refl (j : ℕ) : MultDep j j := by
  exact ⟨ 1, 1, by norm_num ⟩

/-
**Symmetry**: multiplicative dependence is symmetric.

!-- Proof sketch: swap the witnesses a and b. -- !--
-/
theorem multDep_symm {j k : ℕ} (h : MultDep j k) : MultDep k j := by
  obtain ⟨ a, b, ha, hb, hab ⟩ := h; exact ⟨ b, a, hb, ha, hab.symm ⟩ ;

/-
**Transitivity**: multiplicative dependence is transitive.
This is the substantive part of the equivalence: from `j^a = k^b` and `k^c = l^d` we get
`j^(a*c) = k^(b*c) = (k^c)^b = (l^d)^b = l^(d*b)`.

!-- Proof sketch: combine exponents — j^(ac) = (j^a)^c = (k^b)^c = (k^c)^b = (l^d)^b = l^(db). -- !--
-/
theorem multDep_trans {j k l : ℕ} (h₁ : MultDep j k) (h₂ : MultDep k l) :
    MultDep j l := by
      obtain ⟨ a, b, ha, hb, hab ⟩ := h₁;
      obtain ⟨ c, d, hc, hd, hcd ⟩ := h₂;
      use a * c, d * b;
      simp_all +decide [ pow_mul ];
      rw [ ← hcd, pow_right_comm ]

/-
**Powers of a fixed base are dependent**: `j^m` and `j^n` are multiplicatively dependent
whenever `m, n > 0`, via `(j^m)^n = j^(mn) = (j^n)^m`.

!-- Proof sketch: witnesses a = n, b = m; both sides equal j^(m*n). -- !--
-/
theorem multDep_pow_self (j : ℕ) {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    MultDep (j ^ m) (j ^ n) := by
      exact ⟨ n, m, hn, hm, by ring ⟩

-- !-- **The multiplicative independence barrier**: a base `j ≥ 2` coprime to `k` is *never* -- !--
-- !-- multiplicatively dependent on `k`. This is precisely the obstruction that gives -- !--
-- !-- Cobham's theorem its content — a base change between coprime (hence multiplicatively -- !--
-- !-- independent) bases cannot be an "admissible simulation" in the sense of -- !--
-- !-- `OracleCobhamInvariance`. Note `2 ≤ k` is unnecessary, so the barrier is stated in its -- !--
-- !-- sharper one-sided form (it even rules out `k = 1`). -- !--
-- !-- Proof sketch: if j^a = k^b then a prime p ∣ j divides k, contradicting coprimality. -- !--
theorem coprime_not_multDep {j k : ℕ} (hj : 2 ≤ j)
    (hco : Nat.Coprime j k) : ¬ MultDep j k := by
      contrapose! hco; rcases hco with ⟨ a, b, ha, hb, hab ⟩ ; have := congr_arg ( fun x => x.factorization ) hab ; norm_num [ ha.ne', hb.ne', Nat.factorization_mul ] at this;
      obtain ⟨ p, hp ⟩ := Nat.exists_prime_and_dvd ( by linarith : j ≠ 1 ) ; replace this := congr_arg ( fun x => x p ) this ; simp_all +decide ;
      exact fun h => hp.1.not_dvd_one <| h ▸ Nat.dvd_gcd hp.2 ( show p ∣ k from hp.1.dvd_of_dvd_pow <| hab ▸ dvd_pow hp.2 ha.ne' )

-- !-- **Concrete witness**: bases 2 and 3 are multiplicatively independent. This single fact -- !--
-- !-- is what prevents Cobham's theorem from being vacuous. -- !--
-- !-- Proof sketch: reduce j^a = k^b mod 2 — 2^a is even, 3^b is odd, contradiction. -- !--
theorem not_multDep_two_three : ¬ MultDep 2 3 := by
  exact fun ⟨ a, b, ha, hb, h ⟩ => by have := congr_arg ( · % 2 ) h; norm_num [ Nat.pow_mod, ha.ne', hb.ne' ] at this;

/-- **Generalization / boundary (conjecture)**: for bases `≥ 2`, multiplicative dependence is
equivalent to sharing the *same set of prime divisors with proportional exponents*, i.e. there
is a common base `g ≥ 2` with `j = g^p` and `k = g^q`. We leave this stronger structural
characterization as a conjecture; the forward direction needs the radical / prime-factorization
of `j` and `k`. -/
-- !-- Proof sketch (deferred): radical(j) = radical(k) and exponent vectors proportional. -- !--
theorem multDep_iff_common_root {j k : ℕ} (hj : 2 ≤ j) (hk : 2 ≤ k) :
    MultDep j k ↔ ∃ g p q : ℕ, 2 ≤ g ∧ 0 < p ∧ 0 < q ∧ j = g ^ p ∧ k = g ^ q := by
  sorry

end CobhamMultiplicativeIndependence