import Mathlib

/-!
# A generalized multinomial convolution identity for Latin rectangle enumeration

This file establishes the identity

$$\sum_{i_1 + \cdots + i_m = d} \prod_{j=1}^{m} \binom{a + i_j}{a}
  = \binom{ma + d + m - 1}{d},$$

where the sum ranges over all `m`-tuples `(i_1, …, i_m)` of non-negative integers
summing to `d`.  For `m = 3` this is the convolution identity used to simplify the
Bogart–Longyear style counting of Latin rectangles; here it is proved in full
generality for arbitrary numbers of factors.

The proof factors through the theory of *multichoose* numbers
`Nat.multichoose r k = \binom{r + k - 1}{k}`, which count multisets and remove the
truncated subtraction from the intermediate steps.  The two structural ingredients
are:

* `multichoose_conv`: a Vandermonde–Chu convolution for multichoose numbers,
* `prod_multichoose_piAntidiag`: the multi-fold generalization over an arbitrary
  finite index set, proved by induction on the index set.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the `m = 3` binomial convolution used for Latin
rectangle counting is the shadow of an all-orders identity whose right-hand side
is a single multichoose number.

Experiment (Experimenter): reduce `\binom{a+i}{a}` to `multichoose (a+1) i`,
express the tuple sum as a sum over `Finset.piAntidiag univ d`, and induct on the
index finset, using a multichoose Vandermonde convolution at each cons step.

Analysis (Analyst): the truncated subtraction in `ma + d + m - 1` is the only
obstruction to a clean induction; passing to multichoose numbers removes it, since
`multichoose (m (a+1)) d = \binom{ma + m + d - 1}{d}` with no subtraction inside the
recursion.

Critique (Critic): the base case `m = 0` is genuinely covered (empty product `= 1`,
right-hand side `\binom{d-1}{d} = [d = 0]`); the statement is not vacuous and holds
for every `m, a, d`.

Synthesis (PI): the identity is a stars-and-bars convolution; the multichoose form
is the "right" generality and specializes to the classical binomial statement.
The same insertion induction further proves the heterogeneous convolution, where
each factor carries its own multiplicity, confirming that the right-hand side
sees the multiplicities only through their sum.
-/

open Finset

namespace MultinomialConvolutionLatin

/-
**Vandermonde–Chu convolution for multichoose numbers.**
For all `r t d`, summing the products of multichoose numbers over the splittings
`k + (d - k) = d` recovers a single multichoose number with added first argument.
-/
lemma multichoose_conv (r t d : ℕ) :
    ∑ k ∈ Finset.range (d + 1), Nat.multichoose r k * Nat.multichoose t (d - k)
      = Nat.multichoose (r + t) d := by
  induction' r with r ih generalizing d;
  · simp +decide [ Finset.sum_range_succ' ];
  · induction' d with d hd;
    · simp +decide;
    · simp_all +decide [ Finset.sum_range_succ', Nat.multichoose_succ_succ ];
      have := ih ( d + 1 ) ; simp_all +decide [ add_mul, Finset.sum_add_distrib ] ;
      simp_all +decide [ Finset.sum_range_succ' ];
      grind +suggestions

/-
**Multi-fold multichoose convolution over an arbitrary finite index set.**
Summing, over all functions `f : ι → ℕ` supported on `s` with `∑_{i∈s} f i = d`,
the product `∏_{i∈s} multichoose r (f i)` yields `multichoose (|s| · r) d`.
-/
lemma prod_multichoose_piAntidiag {ι : Type*} [DecidableEq ι]
    (s : Finset ι) (r d : ℕ) :
    ∑ f ∈ Finset.piAntidiag s d, ∏ i ∈ s, Nat.multichoose r (f i)
      = Nat.multichoose (s.card * r) d := by
  induction' s using Finset.cons_induction with i s hi ih generalizing d;
  · cases d <;> simp_all +arith +decide;
  · rw [ Finset.piAntidiag_cons ];
    simp +decide [ Finset.sum_disjiUnion ];
    convert multichoose_conv r ( s.card * r ) d using 1;
    · simp +decide [ ← ih, Finset.prod_insert hi, Finset.sum_range ];
      rw [ Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk ];
      simp +decide [ Finset.sum_range, Finset.mul_sum _ _ _ ];
      refine' Finset.sum_congr rfl fun x hx => Finset.sum_congr rfl fun y hy => _;
      by_cases hi : y i = 0 <;> simp_all +decide;
      exact Or.inl ( Finset.prod_congr rfl fun j hj => by aesop );
    · grind +qlia

/-
**Heterogeneous multi-fold multichoose convolution.**
The multiplicity is allowed to depend on the index: summing, over all functions
`f : ι → ℕ` supported on `s` with `∑_{i∈s} f i = d`, the product
`∏_{i∈s} multichoose (r i) (f i)` yields `multichoose (∑_{i∈s} r i) d`.  The
right-hand side depends on the multiplicities only through their sum, exactly as
`∏_i (1 - x)^{-r i} = (1 - x)^{-∑_i r i}` predicts.  This strictly generalizes
`prod_multichoose_piAntidiag`, which is the special case of a constant `r`.
-/
lemma prod_multichoose_piAntidiag_hetero {ι : Type*} [DecidableEq ι]
    (s : Finset ι) (r : ι → ℕ) (d : ℕ) :
    ∑ f ∈ Finset.piAntidiag s d, ∏ i ∈ s, Nat.multichoose (r i) (f i)
      = Nat.multichoose (∑ i ∈ s, r i) d := by
  induction' s using Finset.cons_induction with i s hi ih generalizing d;
  · cases d <;> simp_all +arith +decide;
  · rw [ Finset.piAntidiag_cons ];
    simp +decide [ Finset.sum_disjiUnion ];
    convert multichoose_conv (r i) (∑ j ∈ s, r j) d using 1;
    · simp +decide [ ← ih, Finset.prod_insert hi, Finset.sum_range ];
      rw [ Finset.Nat.sum_antidiagonal_eq_sum_range_succ_mk ];
      simp +decide [ Finset.sum_range, Finset.mul_sum _ _ _ ];
      refine' Finset.sum_congr rfl fun x hx => Finset.sum_congr rfl fun y hy => _;
      by_cases hz : y i = 0 <;> simp_all +decide;
      exact Or.inl ( Finset.prod_congr rfl fun j hj => by aesop );
    · rw [ Finset.sum_insert hi ]

/-
Auxiliary rewriting of a binomial coefficient as a multichoose number.
-/
lemma choose_eq_multichoose (a i : ℕ) :
    Nat.choose (a + i) a = Nat.multichoose (a + 1) i := by
  rw [ Nat.multichoose_eq ]
  have h : a + 1 + i - 1 = a + i := by omega
  rw [ h, Nat.choose_symm_add ]

/-
**Generalized multinomial convolution identity.**
For all natural numbers `m`, `a`, `d`, the sum over all `m`-tuples
`(i_1, …, i_m)` of non-negative integers with `i_1 + ⋯ + i_m = d` of the product
`∏_{j=1}^m \binom{a + i_j}{a}` equals `\binom{ma + d + m - 1}{d}`.
-/
theorem multinomial_binomial_identity (m a d : ℕ) :
    ∑ t ∈ Finset.Nat.antidiagonalTuple m d, ∏ j : Fin m, Nat.choose (a + t j) a
      = Nat.choose (m * a + d + m - 1) d := by
  rw [ Finset.sum_congr rfl fun x hx => Finset.prod_congr rfl fun y hy => choose_eq_multichoose _ _ ];
  convert prod_multichoose_piAntidiag _ _ _ using 1;
  convert rfl;
  ext;
  all_goals try infer_instance;
  · simp +decide [ Finset.mem_piAntidiag, Nat.mem_antidiagonalTuple ];
  · rw [ Nat.multichoose_eq, Finset.card_univ, Fintype.card_fin ] ; congr 1 ; rw [ Nat.mul_add ] ; omega

/-- The classical `m = 3` instance underlying the Latin rectangle simplification. -/
theorem multinomial_binomial_identity_three (a d : ℕ) :
    ∑ t ∈ Finset.Nat.antidiagonalTuple 3 d, ∏ j : Fin 3, Nat.choose (a + t j) a
      = Nat.choose (3 * a + d + 2) d := by
  have h := multinomial_binomial_identity 3 a d
  simpa using h

/--
**Heterogeneous binomial convolution identity.**
Each factor is allowed to carry its own upper parameter `a j`: the sum over all
`m`-tuples `(i_1, …, i_m)` summing to `d` of `∏_{j} \binom{a_j + i_j}{a_j}`
equals `\binom{(∑_j a_j) + d + m - 1}{d}`, depending on the parameters only
through their sum.  The uniform identity `multinomial_binomial_identity` is the
special case `a j = a`.
-/
theorem multinomial_binomial_identity_hetero (m : ℕ) (a : Fin m → ℕ) (d : ℕ) :
    ∑ t ∈ Finset.Nat.antidiagonalTuple m d, ∏ j : Fin m, Nat.choose (a j + t j) (a j)
      = Nat.choose ((∑ j : Fin m, a j) + d + m - 1) d := by
  rw [ Finset.sum_congr rfl fun x hx => Finset.prod_congr rfl fun y hy => choose_eq_multichoose _ _ ];
  convert prod_multichoose_piAntidiag_hetero _ _ _ using 1;
  convert rfl;
  ext;
  all_goals try infer_instance;
  · simp +decide [ Finset.mem_piAntidiag, Nat.mem_antidiagonalTuple ];
  · rw [ Nat.multichoose_eq ] ; congr 1 ;
    simp [ Finset.sum_add_distrib, Finset.card_univ, Fintype.card_fin ] ; omega

/-!
## Examples, generalizations, and boundaries (PEGB)

**Examples.** Concrete instantiations of the identity. -/

-- The full generalized identity, its `m = 3` specialization, and the
-- heterogeneous-parameter strengthening.
#check @multinomial_binomial_identity
#check @multinomial_binomial_identity_three
#check @multinomial_binomial_identity_hetero

-- Heterogeneous instance: `m = 2`, parameters `a = (1, 2)`, `d = 1`.  The tuples
-- are `(0,1),(1,0)` with products `C(1,1)·C(3,2) + C(2,1)·C(2,2) = 3 + 2 = 5`,
-- matching `C((1+2)+1+2-1, 1) = C(5,1) = 5`.
example :
    ∑ t ∈ Finset.Nat.antidiagonalTuple 2 1,
        ∏ j : Fin 2, Nat.choose (![1, 2] j + t j) (![1, 2] j)
      = Nat.choose 5 1 := by
  have h := multinomial_binomial_identity_hetero 2 ![1, 2] 1
  simpa using h

-- `m = 2`, `a = 1`, `d = 2`: the tuples are `(0,2),(1,1),(2,0)` with binomial
-- products `1·3 + 2·2 + 3·1 = 10 = \binom{5}{2}`.
example :
    ∑ t ∈ Finset.Nat.antidiagonalTuple 2 2, ∏ j : Fin 2, Nat.choose (1 + t j) 1
      = Nat.choose 5 2 := by
  have h := multinomial_binomial_identity 2 1 2
  simpa using h

-- The multichoose convolution collapses a double index to a single one.
example : ∑ k ∈ Finset.range 4, Nat.multichoose 2 k * Nat.multichoose 3 (3 - k)
    = Nat.multichoose 5 3 := multichoose_conv 2 3 3

/-!
**Generalization.** `prod_multichoose_piAntidiag` is the genuine extension: the
number of factors is replaced by an arbitrary finite index set `s`, and the
identity reads `∑_{f} ∏_{i∈s} multichoose r (f i) = multichoose (|s|·r) d`.  The
binomial statement is the special case `s = Fin m`, `r = a + 1`.  A further
generalization would allow the multiplicity `r` to vary with the index `i`,
yielding `multichoose (∑ r_i) d`; the present uniform version is the case needed
for Latin rectangle enumeration.

**Boundary cases.** The identity is not vacuous and holds at every corner:
* `m = 0`: the empty product is `1`, and the right-hand side is
  `\binom{d-1}{d}`, which is `1` when `d = 0` and `0` when `d ≥ 1` — exactly the
  count of empty tuples summing to `d`.
* `d = 0`: there is a unique all-zero tuple, the product is `1`, and
  `\binom{ma + m - 1}{0} = 1`.
* `a = 0`: every factor `\binom{i_j}{0} = 1`, so the sum counts the tuples
  themselves, `\binom{d + m - 1}{d}`, the classical stars-and-bars count.
The truncated subtraction `ma + d + m - 1` is the only delicate point; the
multichoose reformulation removes it, which is why the induction goes through. -/

example : ∑ t ∈ Finset.Nat.antidiagonalTuple 0 0, ∏ j : Fin 0, Nat.choose (5 + t j) 5
    = Nat.choose 0 0 := by simp

example (m a : ℕ) :
    ∑ t ∈ Finset.Nat.antidiagonalTuple m 0, ∏ j : Fin m, Nat.choose (a + t j) a = 1 := by
  simpa using multinomial_binomial_identity m a 0

end MultinomialConvolutionLatin