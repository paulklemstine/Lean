import Mathlib
import Speculative.ExceptionalSet.Defs

/-!
# Exceptional Set Finiteness: Main Theorems

## Overview

This file proves the core structural theorems explaining why exceptional
parameters — those where Benford universality fails for the quadratic
dynamical system T_c(x) = x² + c — must belong to a rigid arithmetic locus.

## Main Results

1. **`eventuallyPeriodic_bounded`**: Eventually periodic integer sequences
   are bounded. This is the dynamical rigidity lemma.

2. **`eventuallyPeriodic_not_benfordUniversal`**: Eventually periodic orbits
   cannot be Benford-universal. This is the cross-domain bridge connecting
   arithmetic dynamics to digital statistics.

3. **`exceptional_implies_localObstruction`**: Every exceptional parameter
   must exhibit a local modular obstruction. This is a contrapositive
   structural reduction from analytic failure to arithmetic degeneracy.

4. **`finite_exceptional_of_finite_obstruction_support`**: If local obstructions
   are supported on finitely many primes, and each prime constrains only
   finitely many parameters, then the exceptional set is finite. This is
   the abstract finiteness mechanism.

5. **`no_exceptional_beyond_bound`**: Parameters beyond an explicit bound
   cannot be exceptional. This converts finiteness into effective computability.

6. **`admissible_is_benfordUniversal`**: Admissible parameters (those with
   no local obstruction) are Benford-universal, given the Benford criterion.

## Cross-Domain Connections

- **Arithmetic dynamics ↔ Information theory**: Theorem 2 shows that
  dynamical collapse (periodicity) implies information-theoretic anomaly
  (failure of Benford universality). Low-entropy orbits cannot produce
  the logarithmic digit distribution.

- **Arithmetic dynamics ↔ Computation**: The finite-depth obstruction
  and certified search algorithm make exceptional parameters algorithmically
  recognizable by finite-state scanning modulo primes.
-/

noncomputable section

open Finset Filter Set Nat

/-! ## Theorem 2 (Cross-Domain): Periodicity Forces Non-Universality -/

/-
**Eventually periodic integer sequences are bounded.**

If `f : ℕ → ℤ` satisfies `f(n + p) = f(n)` for all `n ≥ N` and some
period `p > 0`, then `|f(n)|` is bounded by the maximum of `|f(i)|` over
`i < N + p`.

The proof uses strong induction: for `n ≥ N + p`, we have
`f(n) = f(n - p)` (since `n - p ≥ N`), and `n - p < n`, so the
induction hypothesis applies.
-/
theorem eventuallyPeriodic_bounded (f : ℕ → ℤ) (hper : EventuallyPeriodic f) :
    ∃ M : ℕ, ∀ n : ℕ, (f n).natAbs ≤ M := by
  -- Let `M` be the maximum of `|f(i)|` over `i < N + p`.
  obtain ⟨N, p, hp_pos, h_periodic⟩ := hper
  set M := Finset.sup (Finset.range (N + p)) (fun i => (f i).natAbs) with hM_def;
  use M;
  intro n;
  induction' n using Nat.strongRecOn with n ih;
  by_cases hn : n < N + p;
  · exact Finset.le_sup ( f := fun i => Int.natAbs ( f i ) ) ( Finset.mem_range.mpr hn );
  · -- Since $n \geq N + p$, we can write $n = k + p$ for some $k \geq N$.
    obtain ⟨k, rfl⟩ : ∃ k, n = k + p := by
      exact ⟨ n - p, by rw [ Nat.sub_add_cancel ( by linarith ) ] ⟩;
    rw [ h_periodic k ( by linarith ) ] ; exact ih k ( by linarith )

/-
**Eventually periodic orbits cannot be Benford-universal.**

This is the cross-domain bridge: a dynamical rigidity property (periodicity)
implies a statistical anomaly (failure of Benford universality).

The argument is elementary but conceptually decisive:
1. Eventual periodicity implies the orbit takes only finitely many values.
2. Hence `|f(n)|` is bounded.
3. But Benford universality requires `|f(n)|` to be unbounded.
4. Contradiction.

This reframes Benford failure as a **low-entropy signature of dynamical collapse**.
-/
theorem eventuallyPeriodic_not_benfordUniversal
    (f : ℕ → ℤ) (hper : EventuallyPeriodic f) :
    ¬ BenfordUniversal f := by
  exact fun h => by obtain ⟨ M, hM ⟩ := eventuallyPeriodic_bounded f hper; obtain ⟨ n, hn ⟩ := h ( M + 1 ) ; linarith [ hM n ] ;

/-! ## Theorem 1: Exceptional Parameters Are Controlled by Local Obstructions -/

/-
**Exceptional parameters are controlled by local obstructions.**

If Benford universality fails for `T c`, then there must exist a prime `p`
such that the orbit is degenerate modulo `p`. This is a contrapositive
structural theorem: the proof assumes no local obstruction, applies the
abstract Benford criterion to deduce universality, and contradicts
exceptionality.

The hypothesis `hBenfordCriterion` encodes the deep analytical content:
absence of modular degeneracy at every prime forces equidistribution of
logarithmic mantissae, hence Benford behavior. The theorem itself is a
clean structural reduction.
-/
theorem exceptional_implies_localObstruction
    (T : ℤ → ℕ → ℤ)
    (hBenfordCriterion :
      ∀ c, (¬ ∃ p : ℕ, Nat.Prime p ∧ DegenerateModPrime (T c) p) →
        BenfordUniversal (T c)) :
    ∀ c : ℤ, ExceptionalParameter T c → LocalObstruction T c := by
  exact fun c a => Classical.byContradiction fun a_1 => a (hBenfordCriterion c a_1)

/-
**Admissible parameters are Benford-universal.**

This is the positive counterpart of `exceptional_implies_localObstruction`:
if a parameter has no local obstruction at any prime, then the abstract
Benford criterion guarantees universality.

Together with the exceptional-implies-obstruction theorem, this establishes
a complete dichotomy:
  `AdmissibleParameter T c ↔ BenfordUniversal (T c)`
(modulo the Benford criterion hypothesis).
-/
theorem admissible_is_benfordUniversal
    (T : ℤ → ℕ → ℤ)
    (hBenfordCriterion :
      ∀ c, (¬ ∃ p : ℕ, Nat.Prime p ∧ DegenerateModPrime (T c) p) →
        BenfordUniversal (T c))
    (c : ℤ)
    (hadm : AdmissibleParameter T c) :
    BenfordUniversal (T c) := by
  exact hBenfordCriterion c hadm

/-! ## Theorem 3: Finite Obstruction Sets Yield Finite Exceptional Sets -/

/-
**Finite obstruction sets yield finite exceptional sets.**

This is the abstract finiteness mechanism. The proof constructs the
exceptional set as a subset of a finite union:

  E ⊆ ⋃_{p ∈ S} {c : ℤ | DegenerateModPrime (T c) p}

Since `S` is a finite set of primes and each fiber is finite by hypothesis,
the union is finite, hence `E` is finite.

This theorem is the formal skeleton of the entire finiteness conjecture:
once any future classification proves that local obstructions are supported
on finitely many primes with finite fibers, global finiteness follows
instantly.
-/
theorem finite_exceptional_of_finite_obstruction_support
    (T : ℤ → ℕ → ℤ)
    (S : Finset ℕ)
    (hcontrol :
      ∀ c : ℤ, ExceptionalParameter T c →
        ∃ p ∈ S, DegenerateModPrime (T c) p)
    (hfinite :
      ∀ p ∈ S, {c : ℤ | DegenerateModPrime (T c) p}.Finite) :
    {c : ℤ | ExceptionalParameter T c}.Finite := by
  exact Set.Finite.subset ( Set.Finite.biUnion ( Finset.finite_toSet S ) hfinite ) fun c hc => by aesop;

/-! ## Theorem 4: Effective Bound on Exceptional Parameters -/

/-
**No exceptional parameters beyond an explicit bound.**

If every parameter with `|c| > B` has no local obstruction, and the
Benford criterion holds, then every parameter with `|c| > B` is
non-exceptional.

This converts the finiteness conjecture into a **finite certification
problem**: to verify that the exceptional set is contained in `[-B, B]`,
one only needs to check local obstructions for finitely many primes
at finitely many parameter values.
-/
theorem no_exceptional_beyond_bound
    (T : ℤ → ℕ → ℤ) (B : ℕ)
    (hBenfordCriterion :
      ∀ c, (¬ ∃ p : ℕ, Nat.Prime p ∧ DegenerateModPrime (T c) p) →
        BenfordUniversal (T c))
    (hB : ∀ c : ℤ, B < Int.natAbs c → ¬ LocalObstruction T c) :
    ∀ c : ℤ, B < Int.natAbs c → ¬ ExceptionalParameter T c := by
  exact fun c a => Not.intro fun a_1 => a_1 (hBenfordCriterion c (hB c a))

/-! ## Corollary: Exceptional Set is Contained in Bounded Interval -/

/-
The exceptional set is contained in the set of integers with
`|c| ≤ B`, provided all parameters beyond `B` are non-exceptional.
-/
theorem exceptionalSet_subset_bounded
    (T : ℤ → ℕ → ℤ) (B : ℕ)
    (hBenfordCriterion :
      ∀ c, (¬ ∃ p : ℕ, Nat.Prime p ∧ DegenerateModPrime (T c) p) →
        BenfordUniversal (T c))
    (hB : ∀ c : ℤ, B < Int.natAbs c → ¬ LocalObstruction T c) :
    ExceptionalSet T ⊆ {c : ℤ | Int.natAbs c ≤ B} := by
  exact fun c hc => le_of_not_gt fun h => hc <| admissible_is_benfordUniversal T hBenfordCriterion c <| by aesop;

end