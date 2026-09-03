import Mathlib
import Shared.QSRelationPoolRandom
import Shared.SmoothCountSparsity

/-!
# The factor base the relations actually live in, and the `𝔽₂` dimension bound

The measurements of experiment 465 say that the *input statistics* of the
quadratic sieve are those of a random pool.  What is then left as the sieve's
genuine advantage is algorithmic, and this file formalises the two algebraic
facts that constitute it.

1. **The support of a relation is confined to the admissible primes.**  A
   `B`-smooth value `x^2 - N` factors only over primes `p ≤ B` for which `N` is a
   quadratic residue (`smooth_qsValue_support`).  So the exponent vectors of the
   relations do not live in `𝔽₂^{π(B)}` but in the much smaller subspace indexed
   by the admissible primes.

2. **A dimension count then produces a congruence of squares.**  Any family of
   more nonzero naturals than the size of their common support admits a nonempty
   sub-family whose product is a perfect square
   (`exists_nonempty_subset_prod_isSquare`), because their `𝔽₂` exponent vectors
   must be linearly dependent.

Combining the two gives `qs_congruence_of_squares`: `|A| + 1` smooth sieve values
suffice to build a square, where `A` is the set of *admissible* primes — half the
factor base — rather than the whole factor base.  This is the precise sense in
which the quadratic-character constraint, which costs nothing in smoothness
probability (see `Catalog.Shared.QSRelationPoolRandom`), is a *gain* in the
linear-algebra stage.

Main results:

* `isSquare_of_even_factorization` — even exponents means perfect square.
* `exists_nonempty_subset_prod_isSquare` — the `𝔽₂` dependency argument.
* `smooth_qsValue_support` — relations are supported on admissible primes.
* `qs_congruence_of_squares` — end-to-end: `|A| + 1` relations give a square.
-/

namespace QSDimension

open Finset

/-- A nonzero natural with all exponents even is a perfect square. -/
theorem isSquare_of_even_factorization {n : ℕ} (hn : n ≠ 0)
    (h : ∀ p, Even (n.factorization p)) : IsSquare n := by
  classical
  refine ⟨∏ p ∈ n.factorization.support, p ^ (n.factorization p / 2), ?_⟩
  have hself : ∏ p ∈ n.factorization.support, p ^ (n.factorization p) = n := by
    simpa [Finsupp.prod] using Nat.factorization_prod_pow_eq_self hn
  have hstep : ∏ p ∈ n.factorization.support,
      (p ^ (n.factorization p / 2) * p ^ (n.factorization p / 2))
      = ∏ p ∈ n.factorization.support, p ^ (n.factorization p) := by
    refine Finset.prod_congr rfl (fun p _ => ?_)
    rw [← pow_add]
    congr 1
    obtain ⟨k, hk⟩ := h p
    omega
  rw [← Finset.prod_mul_distrib, hstep, hself]

/-- **The dimension bound behind the sieve's linear-algebra step.**  If more than
`S.card` nonzero naturals all factor over the prime set `S`, then some nonempty
sub-family has a perfect-square product: their `𝔽₂`-exponent vectors live in a
space of dimension `S.card` and must be dependent. -/
theorem exists_nonempty_subset_prod_isSquare {ι : Type*} [Fintype ι] [DecidableEq ι]
    (S : Finset ℕ) (v : ι → ℕ) (hv : ∀ i, v i ≠ 0)
    (hsupp : ∀ i, ∀ p, (v i).factorization p ≠ 0 → p ∈ S)
    (hcard : S.card < Fintype.card ι) :
    ∃ T : Finset ι, T.Nonempty ∧ IsSquare (∏ i ∈ T, v i) := by
  classical
  set w : ι → (S → ZMod 2) := fun i p => (((v i).factorization p : ℕ) : ZMod 2) with hw
  have hnli : ¬ LinearIndependent (ZMod 2) w := by
    intro hli
    have hb := hli.fintype_card_le_finrank
    rw [Module.finrank_fintype_fun_eq_card, Fintype.card_coe] at hb
    omega
  obtain ⟨g, hgsum, i₀, hi₀⟩ := Fintype.not_linearIndependent_iff.1 hnli
  set T : Finset ι := Finset.univ.filter (fun i => g i ≠ 0) with hT
  have hTne : T.Nonempty := ⟨i₀, by simp [hT, hi₀]⟩
  have hg1 : ∀ i ∈ T, g i = 1 := by
    intro i hi
    have : g i ≠ 0 := (Finset.mem_filter.1 hi).2
    revert this
    generalize g i = a
    revert a
    decide
  have hprod_ne : (∏ i ∈ T, v i) ≠ 0 := by
    refine Finset.prod_ne_zero_iff.2 (fun i _ => hv i)
  refine ⟨T, hTne, isSquare_of_even_factorization hprod_ne (fun p => ?_)⟩
  have hfact : (∏ i ∈ T, v i).factorization p = ∑ i ∈ T, (v i).factorization p := by
    rw [Nat.factorization_prod (fun i _ => hv i)]
    simp
  by_cases hpS : p ∈ S
  · -- use the `𝔽₂` dependency at the coordinate `p`
    have hzero : ∑ i : ι, g i * w i ⟨p, hpS⟩ = 0 := by
      have h := congrFun hgsum ⟨p, hpS⟩
      simpa [Finset.sum_apply, Pi.smul_apply, smul_eq_mul] using h
    have hzeroout : ∀ i ∈ (Finset.univ : Finset ι), i ∉ T → g i * w i ⟨p, hpS⟩ = 0 := by
      intro i _ hiT
      have hgi : g i = 0 := by
        by_contra hc
        exact hiT (Finset.mem_filter.2 ⟨Finset.mem_univ i, hc⟩)
      simp [hgi]
    have hsub : ∑ i ∈ T, (g i * w i ⟨p, hpS⟩) = ∑ i : ι, g i * w i ⟨p, hpS⟩ :=
      Finset.sum_subset (Finset.filter_subset _ _) hzeroout
    have hone : ∑ i ∈ T, (g i * w i ⟨p, hpS⟩) = ∑ i ∈ T, w i ⟨p, hpS⟩ :=
      Finset.sum_congr rfl (fun i hi => by rw [hg1 i hi, one_mul])
    have hsum0 : ((∑ i ∈ T, (v i).factorization p : ℕ) : ZMod 2) = 0 := by
      have : ∑ i ∈ T, w i ⟨p, hpS⟩ = 0 := by rw [← hone, hsub, hzero]
      simpa [hw] using this
    rw [hfact, even_iff_two_dvd, ← ZMod.natCast_eq_zero_iff]
    exact hsum0
  · have : ∀ i ∈ T, (v i).factorization p = 0 := by
      intro i _
      by_contra hcon
      exact hpS (hsupp i p hcon)
    rw [hfact, Finset.sum_congr rfl this]
    simp

/-! ## The quadratic-sieve specialisation -/

open Classical in
/-- The *admissible* part of the factor base for the modulus `N`: the primes
`p ≤ B` for which `N` is a quadratic residue.  Only these can occur in a
relation. -/
noncomputable def admissiblePrimes (N : ℤ) (B : ℕ) : Finset ℕ :=
  (SmoothSparsity.factorBase B).filter (fun p => IsSquare ((N : ZMod p)))

theorem admissiblePrimes_subset (N : ℤ) (B : ℕ) :
    admissiblePrimes N B ⊆ SmoothSparsity.factorBase B := by
  classical
  simp [admissiblePrimes, Finset.filter_subset]

/-- **Relations are supported on admissible primes.**  Every prime occurring in a
`B`-smooth sieve value `x^2 - N` lies in the admissible half of the factor
base. -/
theorem smooth_qsValue_support {B : ℕ} {N x : ℤ} {v : ℕ}
    (hval : (v : ℤ) = x ^ 2 - N)
    (hsm : ∀ p ∈ v.primeFactors, p ≤ B) :
    ∀ p, v.factorization p ≠ 0 → p ∈ admissiblePrimes N B := by
  classical
  intro p hp
  have hmem : p ∈ v.primeFactors := by
    rw [← Nat.support_factorization]
    exact Finsupp.mem_support_iff.2 hp
  have hprime : p.Prime := Nat.prime_of_mem_primeFactors hmem
  have hdvdn : p ∣ v := Nat.dvd_of_mem_primeFactors hmem
  have hdvd : (p : ℤ) ∣ QSRelationPool.qsValue N x := by
    rw [QSRelationPool.qsValue, ← hval]
    exact_mod_cast Int.natCast_dvd_natCast.2 hdvdn
  have hsq : IsSquare ((N : ZMod p)) := QSRelationPool.isSquare_of_dvd_qsValue hdvd
  refine Finset.mem_filter.2 ⟨SmoothSparsity.mem_factorBase.2 ⟨hprime, hsm p hmem⟩, hsq⟩

/-- **End-to-end: a congruence of squares from `|A| + 1` relations.**  Given more
`B`-smooth sieve values `x^2 - N` than there are *admissible* primes, some
nonempty subproduct of them is a perfect square.  The bound involves only the
admissible half of the factor base — the quadratic-character constraint, which
costs nothing in smoothness probability, halves the number of relations that must
be collected. -/
theorem qs_congruence_of_squares {B : ℕ} {N : ℤ} {n : ℕ} (X : Fin n → ℤ) (V : Fin n → ℕ)
    (hV0 : ∀ i, V i ≠ 0) (hval : ∀ i, (V i : ℤ) = (X i) ^ 2 - N)
    (hsm : ∀ i, ∀ p ∈ (V i).primeFactors, p ≤ B)
    (hcard : (admissiblePrimes N B).card < n) :
    ∃ T : Finset (Fin n), T.Nonempty ∧ IsSquare (∏ i ∈ T, V i) := by
  classical
  refine exists_nonempty_subset_prod_isSquare (admissiblePrimes N B) V hV0 ?_ ?_
  · intro i p hp
    exact smooth_qsValue_support (hval i) (hsm i) p hp
  · simpa using hcard

end QSDimension