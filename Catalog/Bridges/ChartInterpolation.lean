/-
# The chart grid is exactly a set of interpolation nodes

`Bridges.ChartDegreeExactness` and `Bridges.ChartMultidegree` show that a polynomial of
bounded degree is *determined* by its values on a box grid `S^n`.  This file proves the
complementary half — every function on the grid is *realised* — and hence that the
evaluation map

  `{p : degreeOf i p < #S for all i}  →  (functions on S^n)`

is a bijection: multivariate Lagrange interpolation on a box grid.

Main results:
* `ChartCalculus.lagIndicator` — the Lagrange indicator polynomial of a grid node;
* `ChartCalculus.eval_lagIndicator_self` / `eval_lagIndicator_of_ne` — it is a Kronecker
  delta on the grid;
* `ChartCalculus.degreeOf_lagIndicator_le` — it has degree `< #S` in every variable;
* `ChartCalculus.exists_unique_interpolant` — **existence and uniqueness** of the
  interpolating polynomial: the two halves of the theory combined.
-/
import Bridges.ChartMultidegree

open MvPolynomial

namespace ChartCalculus

/-! ## Degree bookkeeping for sums and products -/

theorem degreeOf_finset_prod_le {R σ ι : Type*} [CommSemiring R] (s : Finset ι)
    (f : ι → MvPolynomial σ R) (i : σ) :
    (∏ j ∈ s, f j).degreeOf i ≤ ∑ j ∈ s, (f j).degreeOf i := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.prod_insert ha, Finset.sum_insert ha]
      exact (MvPolynomial.degreeOf_mul_le i _ _).trans (Nat.add_le_add_left ih _)

theorem degreeOf_finset_sum_le {R σ ι : Type*} [CommSemiring R] (s : Finset ι)
    (f : ι → MvPolynomial σ R) (i : σ) (b : ℕ) (h : ∀ j ∈ s, (f j).degreeOf i ≤ b) :
    (∑ j ∈ s, f j).degreeOf i ≤ b := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.sum_insert ha]
      refine (MvPolynomial.degreeOf_add_le i _ _).trans (max_le (h a (by simp)) ?_)
      exact ih (fun j hj => h j (by simp [hj]))

/-! ## The Lagrange indicator of a grid node -/

variable {K : Type*} [Field K] [DecidableEq K]

/-- The Lagrange indicator polynomial of the node `s` in the box grid `S^n`. -/
noncomputable def lagIndicator (S : Finset K) (n : ℕ) (s : Fin n → K) :
    MvPolynomial (Fin n) K :=
  ∏ i, ∏ t ∈ S.erase (s i), C (s i - t)⁻¹ * (X i - C t)

/-- The indicator has degree at most `#S - 1` in every variable. -/
theorem degreeOf_lagIndicator_le (S : Finset K) (n : ℕ) (s : Fin n → K) (hs : ∀ i, s i ∈ S)
    (j : Fin n) :
    (lagIndicator S n s).degreeOf j ≤ S.card - 1 := by
  refine (degreeOf_finset_prod_le _ _ _).trans ?_
  have hinner : ∀ i : Fin n,
      (∏ t ∈ S.erase (s i), (C (s i - t)⁻¹ * (X i - C t) : MvPolynomial (Fin n) K)).degreeOf j
        ≤ if j = i then S.card - 1 else 0 := by
    intro i
    refine (degreeOf_finset_prod_le _ _ _).trans ?_
    have hterm : ∀ t ∈ S.erase (s i),
        (C (s i - t)⁻¹ * (X i - C t) : MvPolynomial (Fin n) K).degreeOf j
          ≤ if j = i then 1 else 0 := by
      intro t _
      refine (MvPolynomial.degreeOf_mul_le j _ _).trans ?_
      have h1 : (C (s i - t)⁻¹ : MvPolynomial (Fin n) K).degreeOf j = 0 :=
        MvPolynomial.degreeOf_C _ _
      have h2 : (X i - C t : MvPolynomial (Fin n) K).degreeOf j ≤ if j = i then 1 else 0 := by
        refine (MvPolynomial.degreeOf_sub_le j _ _).trans ?_
        simp [MvPolynomial.degreeOf_X, MvPolynomial.degreeOf_C]
      omega
    refine (Finset.sum_le_sum hterm).trans ?_
    rw [Finset.sum_const, smul_eq_mul]
    by_cases hji : j = i
    · subst hji
      simp [Finset.card_erase_of_mem (hs j)]
    · simp [hji]
  refine (Finset.sum_le_sum (fun i _ => hinner i)).trans ?_
  simp

/-- On its own node the indicator takes the value `1`. -/
theorem eval_lagIndicator_self (S : Finset K) (n : ℕ) (s : Fin n → K) :
    eval s (lagIndicator S n s) = 1 := by
  rw [lagIndicator, map_prod]
  refine Finset.prod_eq_one (fun i _ => ?_)
  rw [map_prod]
  refine Finset.prod_eq_one (fun t ht => ?_)
  have hne : s i - t ≠ 0 := sub_ne_zero.mpr (Ne.symm (Finset.ne_of_mem_erase ht))
  rw [map_mul, MvPolynomial.eval_C, map_sub, MvPolynomial.eval_X, MvPolynomial.eval_C,
    inv_mul_cancel₀ hne]

/-- On any other node of the grid the indicator vanishes. -/
theorem eval_lagIndicator_of_ne (S : Finset K) (n : ℕ) (s y : Fin n → K)
    (hy : ∀ i, y i ∈ S) (hne : y ≠ s) : eval y (lagIndicator S n s) = 0 := by
  obtain ⟨i, hi⟩ := Function.ne_iff.mp hne
  rw [lagIndicator, map_prod]
  refine Finset.prod_eq_zero (Finset.mem_univ i) ?_
  rw [map_prod]
  refine Finset.prod_eq_zero (Finset.mem_erase.mpr ⟨hi, hy i⟩) ?_
  simp

/-! ## Multivariate Lagrange interpolation -/

/-- The interpolating polynomial of a function on the grid `S^n`. -/
noncomputable def interpolant (S : Finset K) (n : ℕ) (f : (Fin n → K) → K) :
    MvPolynomial (Fin n) K :=
  ∑ s ∈ Fintype.piFinset (fun _ : Fin n => S), C (f s) * lagIndicator S n s

theorem degreeOf_interpolant_le (S : Finset K) (n : ℕ) (f : (Fin n → K) → K) (i : Fin n) :
    (interpolant S n f).degreeOf i ≤ S.card - 1 := by
  refine degreeOf_finset_sum_le _ _ _ _ (fun s hs => ?_)
  refine (MvPolynomial.degreeOf_mul_le i _ _).trans ?_
  rw [MvPolynomial.degreeOf_C, zero_add]
  exact degreeOf_lagIndicator_le S n s (Fintype.mem_piFinset.mp hs) i

theorem eval_interpolant (S : Finset K) (n : ℕ) (f : (Fin n → K) → K) (y : Fin n → K)
    (hy : ∀ i, y i ∈ S) : eval y (interpolant S n f) = f y := by
  rw [interpolant, map_sum, Finset.sum_eq_single y]
  · rw [map_mul, MvPolynomial.eval_C, eval_lagIndicator_self, mul_one]
  · intro s _ hsy
    rw [map_mul, eval_lagIndicator_of_ne S n s y hy (Ne.symm hsy), mul_zero]
  · intro hmem
    exact absurd (Fintype.mem_piFinset.mpr hy) hmem

/-- **Existence and uniqueness of the grid interpolant.**  For a nonempty finite set `S` of
nodes in a field, every function on the box grid `S^n` is the restriction of a unique
polynomial whose degree in each variable is smaller than `#S`.  Uniqueness is the exactness
theorem; existence is Lagrange interpolation. -/
theorem exists_unique_interpolant (S : Finset K) (hS : S.Nonempty) (n : ℕ)
    (f : (Fin n → K) → K) :
    ∃! p : MvPolynomial (Fin n) K,
      (∀ i, p.degreeOf i < S.card) ∧ ∀ y : Fin n → K, (∀ i, y i ∈ S) → eval y p = f y := by
  have hcard : 1 ≤ S.card := Finset.card_pos.mpr hS
  have hdeg : ∀ i : Fin n, (interpolant S n f).degreeOf i < S.card := by
    intro i
    have := degreeOf_interpolant_le S n f i
    omega
  refine ⟨interpolant S n f, ⟨hdeg, fun y hy => eval_interpolant S n f y hy⟩, fun q hq => ?_⟩
  obtain ⟨hqdeg, hqval⟩ := hq
  have hzero : q - interpolant S n f = 0 := by
    refine MvPolynomial.eq_zero_of_eval_zero_at_prod_finset _ (fun _ => S) (fun i => ?_)
      (fun x hx => ?_)
    · exact lt_of_le_of_lt (MvPolynomial.degreeOf_sub_le i _ _) (max_lt (hqdeg i) (hdeg i))
    · rw [map_sub, hqval x hx, eval_interpolant S n f x hx, sub_self]
  exact sub_eq_zero.mp hzero


/-! ## The evaluation isomorphism and the dimension formula

Injectivity (exactness) and surjectivity (interpolation) combine into a linear isomorphism
between the space of polynomials of degree `≤ b` in each variable and the space of all
functions on a grid `S^n` with `#S = b + 1`; in particular that space has dimension
`(b+1)^n`. -/

/-- The space of polynomials whose degree in each variable is at most `b`. -/
def boundedDegree (b : ℕ) (n : ℕ) : Submodule K (MvPolynomial (Fin n) K) where
  carrier := {p | ∀ i, p.degreeOf i ≤ b}
  add_mem' {p q} hp hq i :=
    (MvPolynomial.degreeOf_add_le i p q).trans (max_le (hp i) (hq i))
  zero_mem' i := by simp [MvPolynomial.degreeOf_zero]
  smul_mem' a p hp i := by
    rw [smul_eq_C_mul]
    refine (MvPolynomial.degreeOf_mul_le i _ _).trans ?_
    rw [MvPolynomial.degreeOf_C, zero_add]
    exact hp i

omit [DecidableEq K] in
theorem mem_boundedDegree {b n : ℕ} {p : MvPolynomial (Fin n) K} :
    p ∈ boundedDegree b n ↔ ∀ i, p.degreeOf i ≤ b := Iff.rfl

/-- Restriction of a bounded-degree polynomial to the grid `S^n`. -/
noncomputable def gridEval (b : ℕ) (S : Finset K) (n : ℕ) :
    boundedDegree (K := K) b n →ₗ[K] (↥(Fintype.piFinset fun _ : Fin n => S) → K) where
  toFun p := fun y => eval ((y : Fin n → K)) (p : MvPolynomial (Fin n) K)
  map_add' p q := by funext y; simp
  map_smul' a p := by funext y; simp

omit [DecidableEq K] in
theorem gridEval_injective (b : ℕ) (S : Finset K) (hS : b < S.card) (n : ℕ) :
    Function.Injective (gridEval b S n) := by
  intro p q hpq
  refine Subtype.ext (sub_eq_zero.mp ?_)
  refine MvPolynomial.eq_zero_of_eval_zero_at_prod_finset _ (fun _ => S) (fun i => ?_)
    (fun x hx => ?_)
  · exact lt_of_le_of_lt ((MvPolynomial.degreeOf_sub_le i _ _).trans
      (max_le (p.2 i) (q.2 i))) hS
  · have := congrFun hpq ⟨x, Fintype.mem_piFinset.mpr hx⟩
    simpa [gridEval, sub_eq_zero] using this

theorem gridEval_surjective (b : ℕ) (S : Finset K) (hS : S.card = b + 1) (n : ℕ) :
    Function.Surjective (gridEval b S n) := by
  classical
  intro f
  set F : (Fin n → K) → K := fun y =>
    if h : ∀ i, y i ∈ S then f ⟨y, Fintype.mem_piFinset.mpr h⟩ else 0 with hF
  have hmem : interpolant S n F ∈ boundedDegree (K := K) b n := by
    intro i
    have := degreeOf_interpolant_le S n F i
    omega
  refine ⟨⟨interpolant S n F, hmem⟩, ?_⟩
  funext y
  have hy : ∀ i, (y : Fin n → K) i ∈ S := Fintype.mem_piFinset.mp y.2
  simp only [gridEval, LinearMap.coe_mk, AddHom.coe_mk]
  rw [eval_interpolant S n F _ hy, hF]
  simp [hy]

/-- **The evaluation isomorphism.**  Polynomials of degree `≤ b` in each variable are the
same thing as arbitrary functions on a grid `S^n` with `#S = b + 1`. -/
noncomputable def gridEvalEquiv (b : ℕ) (S : Finset K) (hS : S.card = b + 1) (n : ℕ) :
    boundedDegree (K := K) b n ≃ₗ[K] (↥(Fintype.piFinset fun _ : Fin n => S) → K) :=
  LinearEquiv.ofBijective (gridEval b S n)
    ⟨gridEval_injective b S (by omega) n, gridEval_surjective b S hS n⟩

/-- **Dimension formula.**  The space of polynomials in `n` variables of degree `≤ b` in
each variable has dimension `(b+1)^n` over any field with at least `b+1` elements. -/
theorem finrank_boundedDegree (b : ℕ) (S : Finset K) (hS : S.card = b + 1) (n : ℕ) :
    Module.finrank K (boundedDegree (K := K) b n) = (b + 1) ^ n := by
  rw [(gridEvalEquiv b S hS n).finrank_eq, Module.finrank_pi, Fintype.card_coe,
    Fintype.card_piFinset]
  simp [hS]

end ChartCalculus