import Shared.GradedTransitivity.GSet

/-!
# The ring of series with poles only at `q = 1`, and the residue at `q = 1`

Two structural refinements of the main theorem.

1. **Algebra.** The power series admitting a denominator `(1-q)^k` form a
   subring `ratOneSubring` of `ℚ[[q]]` (it is the image of the localisation
   `ℚ[X]_{(1-X)}`).  Hilbert series of eventually `r`-transitive graded
   `G`-sets live in it, hence sums and Cauchy products of such Hilbert series
   are again rational with a pole only at `q = 1`.

2. **Residue.** For an eventually `r`-transitive graded `G`-set the pole at
   `q = 1` is *simple with residue `-1`*: if `(1-q)·H(q) = P(q)` then
   `P(1) = 1`.  This is a genuinely quantitative statement — it says the
   numerator of the Hilbert series always evaluates to the eventual number of
   orbits, which is `1` exactly because of transitivity.

## Main results

* `ratOneSubring` and `gen_hilbertSeq_mem_ratOneSubring`.
* `eval_one_numerator_of_eventually_const`, `hilbertSeq_residue_one`.
-/

namespace GradedTransitivity

open Polynomial

/-! ### The subring of series with denominator a power of `1-q` -/

/-- The set of power series `f` such that `(1-X)^k f` is a polynomial for some
`k`; equivalently the rational functions whose only pole is at `q = 1`. -/
noncomputable def ratOneSubring : Subring (PowerSeries ℚ) where
  carrier := {f | ∃ (k : ℕ) (P : ℚ[X]), (1 - PowerSeries.X) ^ k * f = (P : PowerSeries ℚ)}
  zero_mem' := ⟨0, 0, by simp⟩
  one_mem' := ⟨0, 1, by simp⟩
  add_mem' := by
    rintro f g ⟨k, P, hP⟩ ⟨l, Q, hQ⟩
    refine ⟨k + l, (1 - X) ^ l * P + (1 - X) ^ k * Q, ?_⟩
    have : (1 - PowerSeries.X) ^ (k + l) * (f + g)
        = (1 - PowerSeries.X) ^ l * ((1 - PowerSeries.X) ^ k * f)
          + (1 - PowerSeries.X) ^ k * ((1 - PowerSeries.X) ^ l * g) := by ring
    rw [this, hP, hQ]
    push_cast
    ring
  mul_mem' := by
    rintro f g ⟨k, P, hP⟩ ⟨l, Q, hQ⟩
    refine ⟨k + l, P * Q, ?_⟩
    have : (1 - PowerSeries.X) ^ (k + l) * (f * g)
        = ((1 - PowerSeries.X) ^ k * f) * ((1 - PowerSeries.X) ^ l * g) := by ring
    rw [this, hP, hQ]
    push_cast
    ring
  neg_mem' := by
    rintro f ⟨k, P, hP⟩
    exact ⟨k, -P, by rw [mul_neg, hP]; push_cast; ring⟩

lemma mem_ratOneSubring_iff (f : PowerSeries ℚ) :
    f ∈ ratOneSubring ↔
      ∃ (k : ℕ) (P : ℚ[X]), (1 - PowerSeries.X) ^ k * f = (P : PowerSeries ℚ) := Iff.rfl

/-- Membership in `ratOneSubring` is exactly eventual vanishing of some
iterated forward difference of the coefficient sequence. -/
theorem mem_ratOneSubring_iff_sdiff (a : ℕ → ℚ) :
    gen a ∈ ratOneSubring ↔ ∃ k : ℕ, EventuallyZero (sdiff^[k] a) := by
  constructor
  · rintro ⟨k, P, hP⟩
    exact ⟨k, (sdiff_iter_eventuallyZero_iff k a).1 ⟨P, hP⟩⟩
  · rintro ⟨k, hk⟩
    obtain ⟨P, hP⟩ := exists_poly_pow_mul_gen k a hk
    exact ⟨k, P, hP⟩

/-- Polynomials lie in the subring. -/
theorem poly_mem_ratOneSubring (P : ℚ[X]) : (P : PowerSeries ℚ) ∈ ratOneSubring :=
  ⟨0, P, by simp⟩

section GradedMembership

variable {G : ℕ → Type*} [∀ n, Group (G n)] {Y : ℕ → Type*} [∀ n, MulAction (G n) (Y n)]

/-- The Hilbert series of an eventually `r`-transitive graded `G`-set lies in
`ratOneSubring`. -/
theorem gen_hilbertSeq_mem_ratOneSubring (r N : ℕ)
    (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r) :
    gen (hilbertSeq G Y r) ∈ ratOneSubring := by
  obtain ⟨P, hP⟩ := gen_hilbertSeq_rational r N h
  exact ⟨1, P, by simpa using hP⟩

/-- Consequently the Cauchy product of two such Hilbert series (the generating
function of the graded product) is again rational with a pole only at `q=1`,
with denominator `(1-q)^2`. -/
theorem cauchy_product_rational
    {G' : ℕ → Type*} [∀ n, Group (G' n)] {Y' : ℕ → Type*} [∀ n, MulAction (G' n) (Y' n)]
    (r s N M : ℕ) (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r)
    (h' : ∀ n ≥ M, IsRTransitive (G' n) (Y' n) s) :
    ∃ P : ℚ[X],
      (1 - PowerSeries.X) ^ 2 * (gen (hilbertSeq G Y r) * gen (hilbertSeq G' Y' s))
        = (P : PowerSeries ℚ) := by
  obtain ⟨P, hP⟩ := gen_hilbertSeq_rational r N h
  obtain ⟨Q, hQ⟩ := gen_hilbertSeq_rational s M h'
  refine ⟨P * Q, ?_⟩
  have : (1 - PowerSeries.X) ^ 2 * (gen (hilbertSeq G Y r) * gen (hilbertSeq G' Y' s))
      = ((1 - PowerSeries.X) * gen (hilbertSeq G Y r))
        * ((1 - PowerSeries.X) * gen (hilbertSeq G' Y' s)) := by ring
  rw [this, hP, hQ]
  push_cast
  ring

end GradedMembership

/-! ### The residue at `q = 1` -/

/-- Coefficients of the numerator produced by multiplying by `1 - X`. -/
lemma coeff_numerator_zero {a : ℕ → ℚ} {P : ℚ[X]}
    (h : (1 - PowerSeries.X) * gen a = (P : PowerSeries ℚ)) : P.coeff 0 = a 0 := by
  have := congrArg (fun φ => (PowerSeries.coeff 0) φ) h
  simpa using this.symm

lemma coeff_numerator_succ {a : ℕ → ℚ} {P : ℚ[X]} (n : ℕ)
    (h : (1 - PowerSeries.X) * gen a = (P : PowerSeries ℚ)) :
    P.coeff (n + 1) = a (n + 1) - a n := by
  have := congrArg (fun φ => (PowerSeries.coeff (n + 1)) φ) h
  simp only [map_sub, PowerSeries.coeff_succ_X_mul, coeff_gen, Polynomial.coeff_coe,
    sub_mul, one_mul] at this
  simpa using this.symm

/-- **Residue theorem.**  If `a` is eventually equal to `c` and
`(1-q)·∑ a n qⁿ = P(q)`, then `P(1) = c`: the pole of the generating function
at `q = 1` is simple with residue `-c`. -/
theorem eval_one_numerator_of_eventually_const {a : ℕ → ℚ} {c : ℚ} {N : ℕ} {P : ℚ[X]}
    (hev : ∀ n ≥ N, a n = c) (h : (1 - PowerSeries.X) * gen a = (P : PowerSeries ℚ)) :
    P.eval 1 = c := by
  set m := max N (P.natDegree + 1) with hm
  have hdeg : P.natDegree < m + 1 := by
    have : P.natDegree + 1 ≤ m := le_max_right _ _
    omega
  have hN : N ≤ m := le_max_left _ _
  rw [Polynomial.eval_eq_sum_range' hdeg]
  have hsimp : ∀ i, P.coeff i * (1 : ℚ) ^ i = P.coeff i := by intro i; ring
  simp only [hsimp]
  rw [Finset.sum_range_succ']
  have hterms : ∀ i ∈ Finset.range m, P.coeff (i + 1) = a (i + 1) - a i := by
    intro i _
    exact coeff_numerator_succ i h
  rw [Finset.sum_congr rfl hterms, Finset.sum_range_sub (fun i => a i) m,
    coeff_numerator_zero h]
  have : a m = c := hev m hN
  rw [this]
  ring

section Residue

variable {G : ℕ → Type*} [∀ n, Group (G n)] {Y : ℕ → Type*} [∀ n, MulAction (G n) (Y n)]

/-- For an eventually `r`-transitive graded `G`-set the numerator of the
Hilbert series always satisfies `P(1) = 1`: the pole at `q = 1` is simple with
residue `-1`, reflecting the single orbit in high grades. -/
theorem hilbertSeq_residue_one (r N : ℕ) (h : ∀ n ≥ N, IsRTransitive (G n) (Y n) r)
    {P : ℚ[X]} (hP : (1 - PowerSeries.X) * gen (hilbertSeq G Y r) = (P : PowerSeries ℚ)) :
    P.eval 1 = 1 := by
  refine eval_one_numerator_of_eventually_const (c := 1) (N := N) (fun n hn => ?_) hP
  simp only [hilbertSeq]
  rw [(torbits_eq_one_iff r).2 (h n hn)]
  norm_num

end Residue

end GradedTransitivity