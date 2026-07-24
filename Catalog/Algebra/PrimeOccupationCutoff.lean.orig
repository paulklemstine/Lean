import Algebra.HolographicPrimes

/-!
# Quantitative occupation-cutoff errors for finite prime partitions

The finite holographic factorization has two independent limiting operations:
adding prime modes and increasing the occupation ceiling.  This chapter isolates
and bounds the second operation.  The resulting triangle inequality gives a
canonical split of every approximation error into a prime-tail term and a
geometric occupation-tail term.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The finite occupation defect should factor exactly as
a full finite Euler product times a product of local geometric defects.  Its
size should be bounded by the sum of the omitted local tails, independently of
how the prime cutoff is later removed.
Experiment (Experimenter): For weights `1/2, 1/3, 1/5`, occupation ceilings from
zero through five give a positive decreasing defect.  In every tested case the
normalized defect lies below the sum of the local omitted powers; the detailed
table is recorded in `ComputationalEvidence.md`.
Analysis (Analyst): The decisive structural step is the finite union bound
`1 - ∏ᵢ(1-aᵢ) ≤ ∑ᵢ aᵢ`.  Combined with the geometric-series identity, it turns
an interacting product error into an additive local-tail estimate.
Critique (Critic): The bound is finite and unconditional.  It does not estimate
the omitted-prime term, assert analytic continuation, or imply information
about zeta zeros.  The strict upper bound on every local weight is essential:
without it the completed local geometric factor need not be positive.
Synthesis (Principal Investigator): For arbitrary nonnegative subunit local
weights, the total approximation error admits an exact occupation factorization
and a robust two-source bound.  Prime weights are obtained by specializing the
local energies from the finite holographic model.
-- !-- end Lab Notes -- !--
-/

noncomputable section

open scoped BigOperators
open Finset Real

namespace PrimeOccupationCutoff

variable {I : Type*} [Fintype I]

/-- Product of local geometric sums through occupation level `N`. -/
def truncatedProduct (q : I → ℝ) (N : ℕ) : ℝ :=
  ∏ i, ∑ n : Fin (N + 1), (q i) ^ (n : ℕ)

/-- Product of the corresponding untruncated local geometric factors. -/
def completedProduct (q : I → ℝ) : ℝ :=
  ∏ i, (1 - q i)⁻¹

/-
A finite union bound in multiplicative form.
-/
lemma one_sub_prod_one_sub_le_sum (a : I → ℝ)
    (ha0 : ∀ i, 0 ≤ a i) (ha1 : ∀ i, a i ≤ 1) :
    1 - ∏ i, (1 - a i) ≤ ∑ i, a i := by
  by_contra h_contra;
  -- By the induction hypothesis, we have:
  have h_ind : ∀ J : Finset I, J.Nonempty → 1 - ∏ i ∈ J, (1 - a i) ≤ ∑ i ∈ J, a i := by
    intro J hJ_nonempty;
    induction' hJ_nonempty using Finset.Nonempty.cons_induction with i J hiJ ih;
    · simp +decide;
    · rw [ Finset.prod_cons, Finset.sum_cons ];
      nlinarith [ ha0 J, ha1 J, show ∏ i ∈ hiJ, ( 1 - a i ) ≤ 1 from Finset.prod_le_one ( fun _ _ => sub_nonneg.2 ( ha1 _ ) ) fun _ _ => sub_le_self _ ( ha0 _ ) ];
  exact h_contra ( if h : Finset.Nonempty Finset.univ then h_ind Finset.univ h else by aesop )

/-
The finite occupation cutoff has an exact multiplicative defect.
-/
lemma truncatedProduct_eq_completed_mul_defect (q : I → ℝ) (N : ℕ)
    (hq : ∀ i, q i < 1) :
    truncatedProduct q N =
      completedProduct q * ∏ i, (1 - (q i) ^ (N + 1)) := by
  have h_truncatedProduct : ∀ i ∈ Finset.univ, ∑ n : Fin (N + 1), q i ^ (n : ℕ) = (1 - q i)⁻¹ * (1 - q i ^ (N + 1)) := by
    intro i hi; rw [ inv_mul_eq_div, eq_div_iff ] <;> try linarith [ hq i ] ; ; erw [ Fin.sum_univ_eq_sum_range ] ; simp +decide [← geom_sum_mul_neg] ;
  convert Finset.prod_congr rfl h_truncatedProduct using 1;
  rw [ Finset.prod_mul_distrib, ← completedProduct ]

/-
Subunit nonnegative weights give a nonnegative completed product.
-/
lemma completedProduct_nonneg (q : I → ℝ) (hq1 : ∀ i, q i < 1) :
    0 ≤ completedProduct q := by
  exact Finset.prod_nonneg fun i _ => inv_nonneg.2 ( sub_nonneg.2 ( le_of_lt ( hq1 i ) ) )

/-
The occupation truncation error is bounded by the sum of the first omitted
local powers, multiplied by the completed finite Euler product.
-/
theorem occupation_tail_bound (q : I → ℝ) (N : ℕ)
    (hq0 : ∀ i, 0 ≤ q i) (hq1 : ∀ i, q i < 1) :
    0 ≤ completedProduct q - truncatedProduct q N ∧
    completedProduct q - truncatedProduct q N ≤
      completedProduct q * ∑ i, (q i) ^ (N + 1) := by
  constructor;
  · refine' sub_nonneg_of_le _;
    exact Finset.prod_le_prod ( fun _ _ => Finset.sum_nonneg fun _ _ => pow_nonneg ( hq0 _ ) _ ) fun _ _ => by rw [ ← tsum_geometric_of_lt_one ( hq0 _ ) ( hq1 _ ) ] ; exact Summable.sum_le_tsum ( Finset.range ( N + 1 ) ) ( fun _ _ => pow_nonneg ( hq0 _ ) _ ) ( summable_geometric_of_lt_one ( hq0 _ ) ( hq1 _ ) ) |> le_trans ( by simp +decide [ Finset.sum_range ] ) ;
  · convert mul_le_mul_of_nonneg_left ( one_sub_prod_one_sub_le_sum ( fun i => q i ^ ( N + 1 ) ) ?_ ?_ ) ( completedProduct_nonneg q hq1 ) using 1;
    · rw [ truncatedProduct_eq_completed_mul_defect q N hq1 ] ; ring;
    · exact fun i => pow_nonneg ( hq0 i ) _;
    · exact fun i => pow_le_one₀ ( hq0 i ) ( le_of_lt ( hq1 i ) )

/-
Every comparison target admits a canonical split into an external
(prime-cutoff) error and the explicit occupation-tail error.
-/
theorem two_cutoff_error_split (target : ℝ) (q : I → ℝ) (N : ℕ)
    (hq0 : ∀ i, 0 ≤ q i) (hq1 : ∀ i, q i < 1) :
    |target - truncatedProduct q N| ≤
      |target - completedProduct q| +
        completedProduct q * ∑ i, (q i) ^ (N + 1) := by
  rw [ abs_le ];
  constructor <;> cases abs_cases ( target - completedProduct q ) <;> linarith [ occupation_tail_bound q N hq0 hq1 ]

/-- Prime modes selected from the natural numbers below `x`. -/
abbrev PrimeBelow (x : ℕ) := {p : ℕ // p ∈ HolographicPrimes.primesIn (Finset.range x)}

/-- Boltzmann weights for the prime modes below `x`. -/
def primeWeight (x : ℕ) (β : ℝ) (p : PrimeBelow x) : ℝ :=
  Real.exp (-β * Real.log (p : ℝ))

/-
At positive inverse temperature every prime Boltzmann weight lies strictly
between zero and one.
-/
lemma primeWeight_nonneg_lt_one (x : ℕ) {β : ℝ} (hβ : 0 < β)
    (p : PrimeBelow x) :
    0 ≤ primeWeight x β p ∧ primeWeight x β p < 1 := by
  refine' ⟨ Real.exp_nonneg _, Real.exp_lt_one_iff.mpr _ ⟩;
  exact mul_neg_of_neg_of_pos ( neg_neg_of_pos hβ ) ( Real.log_pos ( mod_cast Nat.Prime.one_lt ( by
    exact Finset.mem_filter.mp p.2 |>.2 ) ) )

/-
Quantitative two-cutoff estimate for the finite prime occupation model.
The first summand is the error caused by omitting modes; the second is an
explicit sum of occupation tails over the retained prime modes.
-/
theorem prime_partition_two_cutoff_bound (target : ℝ) (x N : ℕ)
    {β : ℝ} (hβ : 0 < β) :
    |target - truncatedProduct (primeWeight x β) N| ≤
      |target - completedProduct (primeWeight x β)| +
        completedProduct (primeWeight x β) *
          ∑ p, (primeWeight x β p) ^ (N + 1) := by
  convert two_cutoff_error_split target ( primeWeight x β ) N ( fun p => ?_ ) ( fun p => ?_ ) using 1;
  · exact Real.exp_nonneg _;
  · exact primeWeight_nonneg_lt_one x hβ p |>.2

end PrimeOccupationCutoff