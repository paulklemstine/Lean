/-
Copyright (c) 2025. All rights reserved.

# Dimension of Bounded-Degree Multivariate Polynomial Spaces

This file establishes the fundamental dimension formula for subspaces of multivariate
polynomials with bounded total degree, connecting algebra (polynomial rings, bases, finrank)
with combinatorics (stars-and-bars, weak compositions, binomial coefficients).

## Main results

* `card_exactMonomialExponents`: Stars-and-bars counting for exact-degree monomials.
* `card_boundedMonomialExponents`: Counting for bounded-degree monomials.
* `monomialBasisBoundedTotalDegree`: An explicit basis for the bounded-degree submodule.
* `finrank_boundedTotalDegreeSubmodule`: The dimension formula.

## Edge cases

Due to natural number subtraction, `Nat.choose (d + n - 1) n` and
`Nat.choose (m + n - 1) (n - 1)` can give incorrect values at boundary cases.
We use `Nat.multichoose` as the canonical counting function and derive `choose`
formulas with appropriate hypotheses.
-/

import Mathlib

open MvPolynomial BigOperators Module

noncomputable section

/-! ## Part 1: Counting Monomials for `Fin n` -/

/-- Fintype instance for finitely supported functions `Fin n →₀ ℕ` with exact sum `m`,
    via the equivalence with symmetric products `Sym (Fin n) m`. -/
noncomputable instance fintypeExactDegreeFinsupp (n m : ℕ) :
    Fintype {s : Fin n →₀ ℕ // Finsupp.degree s = m} :=
  Fintype.ofEquiv (Sym (Fin n) m) (Sym.equivNatSum (Fin n) m)

/-
The cardinality of exact-degree finsupp on `Fin n` equals `Nat.multichoose n m`,
    the stars-and-bars count of weak compositions of `m` into `n` parts.
-/
theorem card_exactDegreeFinsupp_fin (n m : ℕ) :
    Fintype.card {s : Fin n →₀ ℕ // Finsupp.degree s = m} =
      Nat.multichoose n m := by
  -- To prove the equality of the cardinalities, it suffices to show that the set of exact-degree finsupp on `Fin n` is equivalent to the set of symmetric products `Sym (Fin n) m`.
  suffices h_equiv : {s : Fin n →₀ ℕ // s.degree = m} ≃ Sym (Fin n) m by
    rw [ Fintype.card_congr h_equiv, Sym.card_sym_fin_eq_multichoose ];
  -- Apply the equivalence between symmetric products and finsupp with exact sum.
  apply (Sym.equivNatSum (Fin n) m).symm

/-
Equivalence between bounded-sum finsupp and a sigma type over exact sums.
-/
def boundedFinsuppEquivSigma (n d : ℕ) :
    {s : Fin n →₀ ℕ // Finsupp.degree s < d} ≃
    (Σ m : Fin d, {s : Fin n →₀ ℕ // Finsupp.degree s = m.val}) where
  toFun := fun ⟨s, hs⟩ => ⟨⟨Finsupp.degree s, hs⟩, s, rfl⟩
  invFun := fun ⟨m, s, hs⟩ => ⟨s, hs ▸ m.isLt⟩
  left_inv := fun ⟨_, _⟩ => rfl
  right_inv := by
    grind +extAll

/-- Fintype instance for bounded-sum finsupp on `Fin n`. -/
noncomputable instance fintypeBoundedDegreeFinsupp (n d : ℕ) :
    Fintype {s : Fin n →₀ ℕ // Finsupp.degree s < d} :=
  Fintype.ofEquiv _ (boundedFinsuppEquivSigma n d).symm

/-- The hockey-stick identity for `Nat.multichoose`:
    `∑ m ∈ range (d+1), multichoose n m = multichoose (n+1) d`. -/
theorem sum_multichoose_eq (n d : ℕ) :
    ∑ m ∈ Finset.range (d + 1), Nat.multichoose n m = Nat.multichoose (n + 1) d := by
  induction d with
  | zero => simp [Nat.multichoose_zero_right]
  | succ d ih =>
    rw [Finset.sum_range_succ, ih, Nat.multichoose_succ_succ]
    omega

/-
The cardinality of bounded-degree finsupp on `Fin n` via sigma decomposition.
-/
theorem card_boundedDegreeFinsupp_fin_sum (n d : ℕ) :
    Fintype.card {s : Fin n →₀ ℕ // Finsupp.degree s < d} =
      ∑ m ∈ Finset.range d, Nat.multichoose n m := by
  -- We use the equivalence between bounded-degree finsupp over `Fin n` and a sigma type combining `Fin d` with exact-degree finsupp.
  have h_equiv : Fintype.card { s : Fin n →₀ ℕ // Finsupp.degree s < d } = Fintype.card ( Σ m : Fin d, { s : Fin n →₀ ℕ // Finsupp.degree s = m.val } ) := by
    convert Fintype.card_congr ( boundedFinsuppEquivSigma n d ) using 1;
  rw [ h_equiv, Fintype.card_sigma ];
  simp +decide only [card_exactDegreeFinsupp_fin, Finset.sum_range]

/-- The number of `Fin n →₀ ℕ` with sum `< d+1` equals `Nat.multichoose (n+1) d`. -/
theorem card_boundedDegreeFinsupp_fin_multichoose (n d : ℕ) :
    Fintype.card {s : Fin n →₀ ℕ // Finsupp.degree s < d + 1} =
      Nat.multichoose (n + 1) d := by
  rw [card_boundedDegreeFinsupp_fin_sum, sum_multichoose_eq]

/-
The number of `Fin n →₀ ℕ` with sum `< d` equals `Nat.choose (d + n - 1) n`,
    provided `d + n > 0` (excludes the degenerate case `d = n = 0`).
-/
theorem card_boundedDegreeFinsupp_fin (n d : ℕ) (h : 0 < d + n) :
    Fintype.card {s : Fin n →₀ ℕ // Finsupp.degree s < d} =
      Nat.choose (d + n - 1) n := by
  convert card_boundedDegreeFinsupp_fin_sum n d using 1;
  -- By the properties of binomial coefficients, we know that $\sum_{m=0}^{d-1} \binom{n+m-1}{m} = \binom{n+d-1}{n}$.
  have h_sum : ∑ m ∈ Finset.range d, Nat.choose (n + m - 1) m = Nat.choose (n + d - 1) n := by
    induction' d with d ih;
    · cases n <;> aesop;
    · rcases n with ( _ | n ) <;> simp_all +arith +decide [ Nat.choose_succ_succ, Finset.sum_range_succ ];
      · cases d <;> simp_all +arith +decide;
      · rw [ Nat.choose_symm_add ];
  convert h_sum.symm using 1;
  · rw [ add_comm ];
  · exact Finset.sum_congr rfl fun x hx => by rw [ Nat.multichoose_eq ] ;

/-! ## Part 2: Transport to general finite types -/

/-
The degree of a finsupp is invariant under `equivCongrLeft`.
-/
theorem Finsupp.degree_equivCongrLeft' {σ τ : Type*} [DecidableEq σ] [DecidableEq τ]
    (e : σ ≃ τ) (s : σ →₀ ℕ) :
    Finsupp.degree (Finsupp.equivCongrLeft e s) = Finsupp.degree s := by
  -- Apply the fact that the support of $(equivCongrLeft e) s$ is the image of the support of $s$ under $e$.
  have h_support : (equivCongrLeft e s).support = Finset.image e s.support := by
    ext; simp [equivCongrLeft];
    exact ⟨ fun h => ⟨ _, h, e.apply_symm_apply _ ⟩, by rintro ⟨ a, ha, rfl ⟩ ; simpa using ha ⟩;
  unfold Finsupp.degree;
  simp_all +decide [ Finset.sum_image ]

/-- The exponent vectors of exact degree `m` over `σ`. -/
def exactMonomialExponents (σ : Type*) [DecidableEq σ] (m : ℕ) :=
  {s : σ →₀ ℕ // Finsupp.degree s = m}

/-- The exponent vectors of total degree `< d` over `σ`. -/
def boundedMonomialExponents (σ : Type*) [DecidableEq σ] (d : ℕ) :=
  {s : σ →₀ ℕ // Finsupp.degree s < d}

/-- Equivalence between exact-degree exponent vectors over `σ` and over `Fin n`. -/
def exactMonomialExponentsEquivFin (σ : Type*) [Fintype σ] [DecidableEq σ] (m : ℕ) :
    exactMonomialExponents σ m ≃
    {s : Fin (Fintype.card σ) →₀ ℕ // Finsupp.degree s = m} :=
  Equiv.subtypeEquiv (Finsupp.equivCongrLeft (Fintype.equivFin σ)) (by
    intro s
    constructor <;> intro h
    · rw [Finsupp.degree_equivCongrLeft', h]
    · rwa [Finsupp.degree_equivCongrLeft'] at h)

/-- Equivalence between bounded-degree exponent vectors over `σ` and over `Fin n`. -/
def boundedMonomialExponentsEquivFin (σ : Type*) [Fintype σ] [DecidableEq σ] (d : ℕ) :
    boundedMonomialExponents σ d ≃
    {s : Fin (Fintype.card σ) →₀ ℕ // Finsupp.degree s < d} :=
  Equiv.subtypeEquiv (Finsupp.equivCongrLeft (Fintype.equivFin σ)) (by
    intro s
    constructor <;> intro h
    · rw [Finsupp.degree_equivCongrLeft']; exact h
    · rwa [Finsupp.degree_equivCongrLeft'] at h)

/-- Fintype instance for exact-degree exponent vectors over a general finite type. -/
noncomputable instance instFintypeExactMonomialExponents
    (σ : Type*) [Fintype σ] [DecidableEq σ] (m : ℕ) :
    Fintype (exactMonomialExponents σ m) :=
  Fintype.ofEquiv _ (exactMonomialExponentsEquivFin σ m).symm

/-- Fintype instance for bounded-degree exponent vectors over a general finite type. -/
noncomputable instance instFintypeBoundedMonomialExponents
    (σ : Type*) [Fintype σ] [DecidableEq σ] (d : ℕ) :
    Fintype (boundedMonomialExponents σ d) :=
  Fintype.ofEquiv _ (boundedMonomialExponentsEquivFin σ d).symm

/-
Stars-and-bars (multichoose form): the number of monomials of exact degree `m`
    in `n` variables equals `Nat.multichoose n m`.
-/
theorem card_exactMonomialExponents_multichoose
    (σ : Type*) [Fintype σ] [DecidableEq σ] (m : ℕ) :
    Fintype.card (exactMonomialExponents σ m) =
      Nat.multichoose (Fintype.card σ) m := by
  convert card_exactDegreeFinsupp_fin ( Fintype.card σ ) m using 1;
  convert Fintype.card_congr ( exactMonomialExponentsEquivFin σ m )

/-
Stars-and-bars (choose form): the number of monomials of exact degree `m`
    in `n ≥ 1` variables is `choose (m + n - 1) (n - 1)`.
-/
theorem card_exactMonomialExponents
    (σ : Type*) [Fintype σ] [DecidableEq σ] [Nonempty σ] (m : ℕ) :
    Fintype.card (exactMonomialExponents σ m) =
      Nat.choose (m + Fintype.card σ - 1) (Fintype.card σ - 1) := by
  convert card_exactMonomialExponents_multichoose σ m using 1;
  rw [ Nat.multichoose_eq, add_comm ];
  convert Nat.choose_symm ?_ using 2 ; omega;
  exact Nat.le_sub_one_of_lt ( Nat.lt_add_of_pos_left ( Fintype.card_pos ) )

/-
The number of monomials of total degree `< d` in `n` variables
    is `choose (d + n - 1) n`, provided `d + n > 0`.
-/
theorem card_boundedMonomialExponents (σ : Type*) [Fintype σ] [DecidableEq σ] (d : ℕ)
    (h : 0 < d + Fintype.card σ) :
    Fintype.card (boundedMonomialExponents σ d) =
      Nat.choose (d + Fintype.card σ - 1) (Fintype.card σ) := by
  convert card_boundedDegreeFinsupp_fin ( Fintype.card σ ) d ?h
  generalize_proofs at *;
  · convert Fintype.card_congr ( boundedMonomialExponentsEquivFin σ d ) using 1;
  · exact h

/-! ## Part 3: Submodule and Basis -/

/-- The submodule of multivariate polynomials whose support consists of monomials
    with exponent sum `< d`. -/
def boundedTotalDegreeSubmodule (K : Type*) [CommSemiring K]
    (σ : Type*) [DecidableEq σ] (d : ℕ) : Submodule K (MvPolynomial σ K) :=
  Finsupp.supported K K {s : σ →₀ ℕ | Finsupp.degree s < d}

/-
Membership in the bounded-degree submodule is characterized by the support condition.
-/
theorem mem_boundedTotalDegreeSubmodule_iff {K : Type*} [CommSemiring K]
    {σ : Type*} [DecidableEq σ] {d : ℕ} (p : MvPolynomial σ K) :
    p ∈ boundedTotalDegreeSubmodule K σ d ↔
      ∀ s ∈ p.support, Finsupp.degree s < d := by
  exact Iff.symm (Eq.to_iff rfl)

/-
For `0 < d`, membership in the bounded-degree submodule is equivalent to
    `totalDegree < d`.
-/
theorem mem_boundedTotalDegreeSubmodule_iff_totalDegree {K : Type*} [CommSemiring K]
    {σ : Type*} [DecidableEq σ] {d : ℕ} (hd : 0 < d) (p : MvPolynomial σ K) :
    p ∈ boundedTotalDegreeSubmodule K σ d ↔ p.totalDegree < d := by
  constructor;
  · intro hp;
    simp_all +decide [ MvPolynomial.totalDegree ];
    exact fun s hs => mem_boundedTotalDegreeSubmodule_iff p |>.1 hp s ( by simp [ hs ] );
  · intro h s hs;
    exact lt_of_le_of_lt ( Finset.le_sup hs ) h

/-- An explicit basis for the bounded-degree submodule. -/
def monomialBasisBoundedTotalDegree (K : Type*) [CommSemiring K] [Nontrivial K]
    (σ : Type*) [DecidableEq σ] [Fintype σ] (d : ℕ) :
    Basis (boundedMonomialExponents σ d) K (boundedTotalDegreeSubmodule K σ d) :=
  (Finsupp.basisSingleOne (R := K)).map (Finsupp.supportedEquivFinsupp _).symm

/-! ## Part 4: Dimension Formula -/

/-- **Main theorem**: The dimension of the bounded-degree polynomial subspace equals
    `choose (d + n - 1) n` where `n = Fintype.card σ`, provided `d + n > 0`. -/
theorem finrank_boundedTotalDegreeSubmodule
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ]
    (d : ℕ) (h : 0 < d + Fintype.card σ) :
    Module.finrank K (boundedTotalDegreeSubmodule K σ d) =
      Nat.choose (d + Fintype.card σ - 1) (Fintype.card σ) := by
  rw [Module.finrank_eq_card_basis (monomialBasisBoundedTotalDegree K σ d)]
  exact card_boundedMonomialExponents σ d h

/-- Corollary: When `σ` is nonempty, the dimension formula holds for all `d`. -/
theorem finrank_boundedTotalDegreeSubmodule_nonempty
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ] [Nonempty σ]
    (d : ℕ) :
    Module.finrank K (boundedTotalDegreeSubmodule K σ d) =
      Nat.choose (d + Fintype.card σ - 1) (Fintype.card σ) :=
  finrank_boundedTotalDegreeSubmodule K σ d
    (Nat.pos_of_ne_zero (by simp [Fintype.card_pos.ne']))

/-! ## Part 5: Homogeneous Components -/

/-- The submodule of multivariate polynomials with exponent sum exactly `m`. -/
def homogeneousComponent' (K : Type*) [CommSemiring K]
    (σ : Type*) [DecidableEq σ] (m : ℕ) : Submodule K (MvPolynomial σ K) :=
  Finsupp.supported K K {s : σ →₀ ℕ | Finsupp.degree s = m}

/-- An explicit basis for the homogeneous component. -/
def monomialBasisHomogeneous (K : Type*) [CommSemiring K] [Nontrivial K]
    (σ : Type*) [DecidableEq σ] [Fintype σ] (m : ℕ) :
    Basis (exactMonomialExponents σ m) K (homogeneousComponent' K σ m) :=
  (Finsupp.basisSingleOne (R := K)).map (Finsupp.supportedEquivFinsupp _).symm

/-- The dimension of the homogeneous component of degree `m` is
    `choose (m + n - 1) (n - 1)` where `n = Fintype.card σ ≥ 1`. -/
theorem finrank_homogeneousComponent
    (K : Type*) [Field K]
    (σ : Type*) [Fintype σ] [DecidableEq σ] [Nonempty σ]
    (m : ℕ) :
    Module.finrank K (homogeneousComponent' K σ m) =
      Nat.choose (m + Fintype.card σ - 1) (Fintype.card σ - 1) := by
  rw [Module.finrank_eq_card_basis (monomialBasisHomogeneous K σ m)]
  exact card_exactMonomialExponents σ m

end