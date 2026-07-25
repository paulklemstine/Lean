import Mathlib

/-!
# Prime-base binomial congruences `C(qn, n) ≡ qⁿ (mod n)`

Fix a base `q`.  We study the natural numbers `n` for which the central-type
congruence
`  C(q·n, n) ≡ qⁿ (mod n)  `
holds.  This is the congruence underlying the Guedes–Machado (2023) circle of
questions on prime-base binomial coefficients (cf. the attached catalog
references `arXiv:2305.12345`, `OEIS:A080469`, `GuedesMachado2023`).

The headline result of this file is that **every prime is a solution**, for an
arbitrary base `q`.  The proof combines two classical ingredients:

* **Lucas' theorem** (`Choose.choose_modEq_choose_mod_mul_choose_div_nat`) to
  evaluate `C(q·p, p) mod p`, and
* **Fermat's little theorem** (via `ZMod.pow_card`) to evaluate `qᵖ mod p`.

Both sides reduce to `q (mod p)`, so the congruence holds.  Since there are
infinitely many primes, the solution set is infinite for every base — a fully
rigorous instance of the "infinitely many solutions" phenomenon that the
Guedes–Machado conjecture predicts (there for the sparser composite family
`n = qᵗ·p`).

## Main results

* `choose_prime_fibre`      : `C(q·p, p) ≡ q (mod p)` for every prime `p`.
* `pow_prime_fibre`         : `qᵖ ≡ q (mod p)` for every prime `p` (Fermat).
* `prime_solves`            : every prime `p` satisfies `Congruent q p`.
* `infinitely_many_solutions` : `{n | Congruent q n}` is infinite for every `q`.

-- !-- Lab Notes -- !--
Hypothesis log / experimental record.

H1 (Hypothesizer). The prime fibre `n = p` always solves `C(qn,n) ≡ qⁿ (mod n)`.
    EVIDENCE: `#eval` over `n < 40`, base `q = 2`, produced solutions
    `2,3,5,7,11,12,13,17,19,23,29,30,31,37` — every prime is present, plus a few
    composites (`12 = 2²·3`, `30`).  Base `q = 3` gave `2,3,5,7,11,13,…,36,37`.
    So *all* primes appear.  CONFIRMED → `prime_solves`.

H2 (Experimenter). Mechanism: Lucas gives `C(qp,p) ≡ C(0,0)·C(q,1) = q (mod p)`
    because `(qp) % p = 0`, `(qp)/p = q`, `p % p = 0`, `p/p = 1`; Fermat gives
    `qᵖ ≡ q (mod p)`.  Both sides equal `q`, independent of the size of `q`.

H3 (Analyst). The prime fibre already forces infinitude, so the *existence* of
    infinitely many `n` with `C(qn,n) ≡ qⁿ (mod n)` is unconditional.  What the
    Guedes–Machado conjecture really adds is infinitude within the *composite*
    family `n = qᵗ·p` (`t ≥ 2`); that sparser statement is genuinely open and is
    recorded in `FUTURE_DIRECTIONS.md`.

FAILURE ANALYSIS: an initial attempt required `q < p` to apply Lucas; inspecting
the recursion step showed the digit reduction `(qp)/p = q`, `(qp)%p = 0` needs no
size hypothesis, so the theorem holds for *all* bases `q`.
-/

namespace PrimeBaseBinomialCongruence

open Nat

/-- The base-`q` digit sum of `n` (used to phrase the Guedes–Machado condition
`s_q((q-1)p) ≥ (q-1)t`). -/
def digitSum (q n : ℕ) : ℕ := (Nat.digits q n).sum

/-- The prime-base binomial congruence: `C(q·n, n) ≡ qⁿ (mod n)`. -/
def Congruent (q n : ℕ) : Prop := Nat.choose (q * n) n ≡ q ^ n [MOD n]

/-
**Lucas fibre.** For every prime `p` and every base `q`,
`C(q·p, p) ≡ q (mod p)`.
-/
theorem choose_prime_fibre {q p : ℕ} (hp : p.Prime) :
    Nat.choose (q * p) p ≡ q [MOD p] := by
  convert Choose.choose_modEq_choose_mod_mul_choose_div_nat using 1;
  · norm_num [ hp.pos ];
  · exact ⟨ hp ⟩

/-
**Fermat fibre.** For every prime `p` and every base `q`, `qᵖ ≡ q (mod p)`.
-/
theorem pow_prime_fibre {q p : ℕ} (hp : p.Prime) :
    q ^ p ≡ q [MOD p] := by
  haveI := Fact.mk hp; simp +decide [ ← ZMod.natCast_eq_natCast_iff ] ;

/-
**Every prime is a solution.** For every base `q` and prime `p`,
`C(q·p, p) ≡ qᵖ (mod p)`.
-/
theorem prime_solves {q p : ℕ} (hp : p.Prime) : Congruent q p := by
  exact choose_prime_fibre hp |> Nat.ModEq.trans <| pow_prime_fibre hp |> Nat.ModEq.symm

/-
**Infinitely many solutions.** For every base `q`, the set of `n` satisfying
`C(q·n, n) ≡ qⁿ (mod n)` is infinite.
-/
theorem infinitely_many_solutions (q : ℕ) : {n | Congruent q n}.Infinite := by
  exact Set.infinite_of_forall_exists_gt fun n => by rcases Nat.exists_infinite_primes ( n + 1 ) with ⟨ p, hp ⟩ ; exact ⟨ p, prime_solves hp.2, hp.1 ⟩ ;

end PrimeBaseBinomialCongruence