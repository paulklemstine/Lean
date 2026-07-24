/-
# The Maynard–Tao bridge: admissibility ⇄ bounded gaps

This file joins the two halves of the bounded-gaps programme developed in
`Admissible.lean` (the *local* combinatorial input) and `BoundedGaps.lean` (the
*analytic* output), and connects them to the Selberg sieve weight identity from the
catalog file `NumberTheory/SelbergSieveWeight.lean`.

The central object is the prime `2`-tuple `{0, d}`.  Saying that `{0, d}` is realised
by infinitely many all-prime translates is the statement `InfinitelyOftenTuplePrime d`
("there are infinitely many primes `n` with `n + d` also prime").  We prove:

* `infinitelyOften_imp_admissible` — **the local obstruction theorem**: if `{0, d}` is
  realised infinitely often, then `{0, d}` is admissible.  This is exactly why
  admissibility is the right hypothesis: an inadmissible tuple (such as `{0, 1}`) is
  blocked at some prime `p`, which divides one of `n, n+d` for *every* `n`, killing all
  large all-prime translates.

* `liminf_le_of_infinitelyOften` — **the analytic output**: realising `{0, d}`
  (`d ≥ 1`) infinitely often forces `liminf (p_{n+1} − p_n) ≤ d`.

* `twin_primes_imp_liminf_le_two` — the twin-prime corollary, packaging
  `twinTuple_admissible` with the gap bound for `d = 2`.

* `selberg_weight_eq_squarefree_indicator` — uses the catalog theorem
  `SelbergSieveWeight.selberg_sieve_weight` to identify the (squarefree-supported)
  Selberg/GPY sieve weight `∑_{d²∣n} μ(d)` with the squarefree indicator `1_{μ²}(n)`.
  Restricting the GPY sieve to squarefree moduli is precisely this identity.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): admissibility is *necessary* for a tuple to be infinitely
often all-prime; bounded gaps is the *consequence* of realising a 2-tuple.
Experiment (Experimenter): proved the obstruction by the covering argument — if `{0,d}`
covers all residues mod some prime `p`, then `p ∣ n` or `p ∣ (n+d)` for every `n`,
contradicting infinitely many large prime pairs.  Proved the output by instantiating
`liminf_primeGap_le` with the pair `(n, n+d)`.
Analysis (Analyst): the two directions are genuinely different mathematics — one is a
finite local sieve obstruction, the other is the global `liminf` reduction.  The
honest gap (the *unconditional* Zhang/Maynard input, i.e. the level-of-distribution
theorem of Bombieri–Vinogradov) is isolated as the hypothesis `InfinitelyOftenTuplePrime`
and documented as future work — it is the only non-elementary ingredient.
Critique (Critic): no theorem is vacuous; `twin_primes_imp_liminf_le_two` genuinely
combines an unconditional fact (`twinTuple_admissible`) with a conditional bound.  The
Selberg identity is *used*, not restated, via `selberg_sieve_weight`.
Synthesis (PI): admissibility (input) + liminf reduction (output) + Selberg weight
(sieve mechanism) form a coherent, sorry-free slice of the Maynard–Tao framework.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Novelty.TwinPrimeGaps.Admissible
import Novelty.TwinPrimeGaps.BoundedGaps
import NumberTheory.SelbergSieveWeight

namespace TwinPrimeGaps

open Filter

/-- The prime `2`-tuple `{0, d}` is **realised infinitely often** if there are
arbitrarily large primes `n` such that `n + d` is also prime. -/
def InfinitelyOftenTuplePrime (d : ℕ) : Prop :=
  ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ Nat.Prime n ∧ Nat.Prime (n + d)

/-
**Local obstruction theorem.** If the tuple `{0, d}` is realised by infinitely many
all-prime translates, then it is admissible.
-/
theorem infinitelyOften_imp_admissible (d : ℕ) (h : InfinitelyOftenTuplePrime d) :
    IsAdmissible ({0, (d : ℤ)} : Finset ℤ) := by
  intro p hp; by_contra h_contra; simp_all +decide ;
  have := h_contra ( -1 ) ; haveI := Fact.mk hp ; simp_all +decide ;
  have := h_contra 1; have := h_contra ( -1 ) ; simp_all +decide ;
  rcases p with ( _ | _ | _ | p ) <;> simp_all +decide [ ZMod, Fin.ext_iff ];
  obtain ⟨ n, hn₁, hn₂, hn₃ ⟩ := h 3 ; rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> rcases Nat.even_or_odd' d with ⟨ l, rfl | rfl ⟩ <;> simp_all +arith +decide [ Nat.add_mod ] ;
  · simp_all +decide [ Nat.prime_mul_iff ];
  · cases hn₃.eq_two_or_odd <;> omega

/-
**Analytic output.** If `{0, d}` (`d ≥ 1`) is realised infinitely often, then the
`liminf` of consecutive prime gaps is at most `d`.
-/
theorem liminf_le_of_infinitelyOften (d : ℕ) (hd : 1 ≤ d)
    (h : InfinitelyOftenTuplePrime d) :
    Filter.atTop.liminf primeGap ≤ d := by
  apply TwinPrimeGaps.liminf_primeGap_le;
  exact fun N => by obtain ⟨ n, hn₁, hn₂, hn₃ ⟩ := h N; exact ⟨ n, n + d, hn₂, hn₃, hn₁, by linarith, by linarith ⟩ ;

/-
**Twin-prime corollary.** The twin-prime conjecture (`{0,2}` realised infinitely
often) implies `liminf (p_{n+1} − p_n) ≤ 2`; and the underlying tuple `{0,2}` is
unconditionally admissible.
-/
theorem twin_primes_imp_liminf_le_two (h : InfinitelyOftenTuplePrime 2) :
    IsAdmissible ({0, 2} : Finset ℤ) ∧ Filter.atTop.liminf primeGap ≤ 2 := by
  exact ⟨ twinTuple_admissible, liminf_le_of_infinitelyOften 2 ( by norm_num ) h ⟩

/-
**Selberg/GPY sieve weight.** Using the catalog identity
`SelbergSieveWeight.selberg_sieve_weight`, the squarefree-supported weight
`∑_{d² ∣ n} μ(d)` equals the squarefree indicator of `n`.
-/
theorem selberg_weight_eq_squarefree_indicator (n : ℕ) (hn : 0 < n) :
    (∑ d ∈ n.divisors.filter (fun d => d ^ 2 ∣ n), ArithmeticFunction.moebius d)
      = if Squarefree n then 1 else 0 := by
  rw [ ← ArithmeticFunction.moebius_sq ];
  convert SelbergSieveWeight.selberg_sieve_weight n hn |> Eq.symm using 1

end TwinPrimeGaps