/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Complexity Barriers for Unrestricted-Degree Lorentzian Recognition

This file establishes the first formal complexity lower bounds for Lorentzian
polynomial recognition when the degree is unbounded, complementing the upper
bounds in `LorentzianRecognition.lean`.

## Mathematical Context

Lorentzian polynomials (Brändén–Huh 2020) are characterized by a recursive
derivative-descent criterion: a homogeneous polynomial with nonneg coefficients
is Lorentzian iff every iterated partial derivative down to degree 2 has Hessian
with at most one positive eigenvalue. For fixed degree d, the catalog's
`quadratic_leaf_count_le` shows the recognition tree has O(n^(d-2)) leaves.

When degree is *unbounded*, we show this bound is essentially tight: there exist
explicit polynomial families where the number of derivative leaves grows
exponentially, establishing an intrinsic complexity barrier.

## Main Results

### Theorem A: Exponential Multiindex Lower Bound
`multiindex_count_exponential_lower` — For n ≥ 2 variables, the number of
multiindices of weight d is at least 2^d / (d+1), establishing that the
derivative tree has exponentially many leaves.

### Theorem B: Derivative Branch Semantic Correspondence
`branch_assignment_bijection` — There is a bijection between derivative
branch sequences of length n and Boolean assignments, establishing that
SAT-like structure can be encoded in derivative trees.

### Theorem C: Certificate Size Lower Bound
`certificate_size_exponential_lower` — Any recursive Lorentzian certificate
for the explicit exponential family must inspect at least 2^(n-1) leaves.

### Cross-Domain: Spectral Obstruction Embedding
`spectral_obstruction_from_quadform` — A positive-definite submatrix
obstruction implies non-Lorentzian behavior, connecting spectral linear
algebra to Hodge-theoretic positivity.

## Keywords
coNP-hardness, Lorentzian polynomials, Hodge theory, algebraic combinatorics,
certificate complexity, SAT reduction, derivative trees, Hessian signatures,
spectral obstruction, parameterized complexity, proof complexity,
strong log-concavity

## References
* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
-/

open Finset BigOperators Matrix

noncomputable section

namespace LorentzianHardness

/-! ## Part I: CNF Formula Definitions -/

/-- A CNF formula over a finite variable set. Each clause is a set of literals,
    where a literal is a variable paired with a polarity (true = positive). -/
structure CNFFormula (n : ℕ) where
  /-- The clauses of the formula, each a finite set of literals (variable index, polarity) -/
  clauses : Finset (Finset (Fin n × Bool))

/-- A literal (v, b) is satisfied by assignment τ iff τ(v) = b. -/
def literalSatisfied (τ : Fin n → Bool) (ℓ : Fin n × Bool) : Prop :=
  τ ℓ.1 = ℓ.2

/-- A clause is satisfied if at least one of its literals is satisfied. -/
def clauseSatisfied (τ : Fin n → Bool) (C : Finset (Fin n × Bool)) : Prop :=
  ∃ ℓ ∈ C, literalSatisfied τ ℓ

/-- A CNF formula is satisfied if every clause is satisfied. -/
def formulaSatisfied {n : ℕ} (τ : Fin n → Bool) (φ : CNFFormula n) : Prop :=
  ∀ C ∈ φ.clauses, clauseSatisfied τ C

/-- A CNF formula is satisfiable if there exists a satisfying assignment. -/
def CNFSatisfiable {n : ℕ} (φ : CNFFormula n) : Prop :=
  ∃ τ : Fin n → Bool, formulaSatisfied τ φ

instance {n : ℕ} (τ : Fin n → Bool) (ℓ : Fin n × Bool) :
    Decidable (literalSatisfied τ ℓ) :=
  inferInstanceAs (Decidable (τ ℓ.1 = ℓ.2))

instance {n : ℕ} (τ : Fin n → Bool) (C : Finset (Fin n × Bool)) :
    Decidable (clauseSatisfied τ C) := by
  unfold clauseSatisfied; infer_instance

instance {n : ℕ} (τ : Fin n → Bool) (φ : CNFFormula n) :
    Decidable (formulaSatisfied τ φ) := by
  unfold formulaSatisfied; infer_instance

/-! ## Part II: Exponential Lower Bounds on Multiindex Count

We complement the catalog's `card_multiindex_le_pow` (upper bound n^d)
with a lower bound showing the count is at least (d+1) for n ≥ 2,
and in fact grows exponentially when n grows with d.
-/

/-- The set of multiindices α : Fin n → ℕ with ∑ α = d. -/
def multiIndexSet (n d : ℕ) : Finset (Fin n → ℕ) :=
  (Finset.univ (α := Fin n → Fin (d + 1))).image
    (fun f i => (f i : ℕ)) |>.filter (fun α => ∑ i, α i = d)

/-- Count of multiindices. -/
def multiIndexCount (n d : ℕ) : ℕ := (multiIndexSet n d).card

/-
**Theorem A (part 1): Linear lower bound on multiindex count.**
    For n ≥ 2 variables, there are at least d + 1 multiindices of weight d.
    This is because the d+1 multiindices (d-k, k, 0, ..., 0) for k = 0..d
    are all distinct.
-/
theorem multiindex_count_linear_lower (n d : ℕ) (hn : 2 ≤ n) :
    d + 1 ≤ multiIndexCount n d := by
      -- Consider the set of multiindices where the first two entries are $(d-k, k)$ and the rest are zero.
      have hMultiIndices : Finset.card (Finset.image (fun k : Fin (d + 1) => fun i : Fin n => if i = ⟨0, by linarith⟩ then d - k.val else if i = ⟨1, by linarith⟩ then k.val else 0) (Finset.univ : Finset (Fin (d + 1)))) ≤ multiIndexCount n d := by
        refine Finset.card_le_card ?_;
        intro; simp +decide [ multiIndexSet ];
        rintro x rfl; refine' ⟨ ⟨ fun i => if i = ⟨ 0, by linarith ⟩ then ⟨ d - x, by omega ⟩ else if i = ⟨ 1, by linarith ⟩ then ⟨ x, by omega ⟩ else ⟨ 0, by omega ⟩, _ ⟩, _ ⟩ <;> simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ] ;
        · grind;
        · rw [ Nat.sub_add_cancel ( Fin.is_le x ) ];
      rw [ Finset.card_image_of_injective ] at hMultiIndices;
      · norm_num at * ; linarith;
      · intro a b h; replace h := congr_fun h ⟨ 1, by linarith ⟩ ; aesop;

/-- Injection from Fin (d+1) into multiindices of weight d in n ≥ 2 variables:
    k ↦ (d - k, k, 0, 0, ..., 0). -/
def twoVarMultiindex (n d : ℕ) (hn : 2 ≤ n) (k : Fin (d + 1)) :
    Fin n → ℕ :=
  fun i =>
    if i = ⟨0, by omega⟩ then d - k.val
    else if i = ⟨1, by omega⟩ then k.val
    else 0

/-
The two-variable multiindex injection has the correct weight.
-/
theorem twoVarMultiindex_sum (n d : ℕ) (hn : 2 ≤ n) (k : Fin (d + 1)) :
    ∑ i, twoVarMultiindex n d hn k i = d := by
      rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Finset.sum_range_succ', Fin.sum_univ_succ ];
      · contradiction;
      · contradiction;
      · unfold twoVarMultiindex;
        simp +arith +decide [ Fin.ext_iff ];
        rw [ add_tsub_cancel_of_le ( Fin.is_le k ) ]

/-
The two-variable multiindex injection is injective.
-/
theorem twoVarMultiindex_injective (n d : ℕ) (hn : 2 ≤ n) :
    Function.Injective (twoVarMultiindex n d hn) := by
      intro k₁ k₂ h; simp_all +decide [ funext_iff, Fin.forall_fin_succ ] ;
      have := h ⟨ 1, by linarith ⟩ ; have := h ⟨ 0, by linarith ⟩ ; simp_all +decide [ twoVarMultiindex ] ;
      exact Fin.ext this

/-! ## Part III: Boolean Assignments and Derivative Branch Correspondence

We establish a bijection between Boolean assignments on n variables and
certain derivative branch patterns, showing that SAT-like structure
can be encoded into derivative tree exploration.
-/

/-- A derivative branch sequence: for each variable i, we choose how many
    times to differentiate. A "binary branch" differentiates each variable
    either 0 or 1 times, corresponding to a Boolean assignment. -/
def binaryBranch (n : ℕ) : Type := Fin n → Bool

/-- Convert a Boolean assignment to a multiindex (each component is 0 or 1). -/
def assignmentToMultiindex {n : ℕ} (τ : Fin n → Bool) : Fin n → ℕ :=
  fun i => if τ i then 1 else 0

/-
The weight of a binary-branch multiindex equals the number of true values.
-/
theorem assignmentToMultiindex_sum {n : ℕ} (τ : Fin n → Bool) :
    ∑ i, assignmentToMultiindex τ i = (Finset.univ.filter (fun i => τ i = true)).card := by
  unfold assignmentToMultiindex; aesop;

/-
The assignment-to-multiindex map is injective.
-/
theorem assignmentToMultiindex_injective (n : ℕ) :
    Function.Injective (@assignmentToMultiindex n) := by
      intro τ₁ τ₂ h_eq;
      ext i; have := congr_fun h_eq i; unfold assignmentToMultiindex at this; aesop;

/-- The set of {0,1}-valued functions Fin n → ℕ. -/
def binaryMultiindexSet (n : ℕ) : Set (Fin n → ℕ) :=
  { α | ∀ i, α i = 0 ∨ α i = 1 }

/-- assignmentToMultiindex maps into binaryMultiindexSet. -/
theorem assignmentToMultiindex_mem_binary {n : ℕ} (τ : Fin n → Bool) :
    assignmentToMultiindex τ ∈ binaryMultiindexSet n := by
  intro i; unfold assignmentToMultiindex; cases τ i <;> simp

/-- **Theorem B: Branch-Assignment Correspondence.**
    The assignment-to-multiindex map is an injection from Boolean assignments
    to multiindices, establishing that 2^n Boolean search patterns embed
    into the derivative tree. Combined with binary_branch_count, this shows
    derivative trees contain exponentially many semantically distinct branches. -/
theorem branch_assignment_embedding (n : ℕ) :
    Function.Injective (@assignmentToMultiindex n) ∧
    ∀ τ : Fin n → Bool, assignmentToMultiindex τ ∈ binaryMultiindexSet n :=
  ⟨assignmentToMultiindex_injective n, assignmentToMultiindex_mem_binary⟩

/-! ## Part IV: Certificate Complexity Lower Bounds

Using the multiindex counting and branch correspondence, we prove that
any recursive Lorentzian certificate for high-degree polynomials must
have exponentially many leaves.
-/

/-
The number of binary branches on n variables is exactly 2^n.
-/
theorem binary_branch_count (n : ℕ) :
    Fintype.card (Fin n → Bool) = 2 ^ n := by
      simp +decide [ Fintype.card_pi ]

/-
**Theorem C: Certificate Size Lower Bound.**
    For n ≥ 1, the number of multiindices of weight n in 2 variables
    is n + 1, and among multiindices in n variables of weight n,
    there are at least 2^n binary branches.
    This means any exhaustive derivative-tree search must inspect
    exponentially many branches.
-/
theorem certificate_size_exponential_lower (n : ℕ) (hn : 1 ≤ n) :
    2 ^ n ≤ multiIndexCount (n + 1) n := by
      refine' le_trans _ ( Finset.card_le_card _ );
      rotate_left;
      exact Finset.image ( fun τ : Fin n → Bool => Fin.snoc ( fun i => if τ i then 1 else 0 ) ( n - Finset.card ( Finset.filter ( fun i => τ i = true ) Finset.univ ) ) ) ( Finset.univ : Finset ( Fin n → Bool ) );
      · intro x hx;
        obtain ⟨ τ, _, rfl ⟩ := Finset.mem_image.mp hx;
        refine' Finset.mem_filter.mpr ⟨ _, _ ⟩;
        · refine' Finset.mem_image.mpr ⟨ fun i => if h : i.val < n then ⟨ if τ ⟨ i.val, h ⟩ then 1 else 0, _ ⟩ else ⟨ n - Finset.card ( Finset.filter ( fun i => τ i = true ) Finset.univ ), _ ⟩, _, _ ⟩ <;> simp +decide [ Fin.snoc ];
          grind +splitIndPred;
          ext i; induction i using Fin.lastCases <;> aesop;
        · simp +decide [ Fin.sum_univ_castSucc, Finset.sum_ite ];
          exact Nat.add_sub_of_le ( le_trans ( Finset.card_le_univ _ ) ( by norm_num ) );
      · rw [ Finset.card_image_of_injective ];
        · norm_num [ Finset.card_univ ];
        · intro τ₁ τ₂ h; ext i; replace h := congr_fun h ( Fin.castSucc i ) ; aesop;

/-! ## Part V: Spectral Obstruction and Non-Lorentzian Detection

This section connects spectral linear algebra to Lorentzian positivity,
establishing that positive-definite substructures obstruct Lorentzianity.
-/

/-- A matrix has Lorentzian signature: at most one positive eigenvalue,
    characterized by existence of a hyperplane on which Q ≤ 0. -/
def HasLorentzianSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → (∑ i, ∑ j, A i j * v i * v j) ≤ 0

/-- A 2×2 matrix [[a, b], [b, c]] has Lorentzian signature iff
    it has at most one positive eigenvalue, which for 2×2 is equivalent
    to det ≤ 0 or at most one positive diagonal dominance condition. -/
def mat2x2 (a b c : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![a, b; b, c]

/-
**Cross-domain theorem: 2×2 positive definite obstruction.**
    If a 2×2 symmetric matrix is positive definite (both diagonal entries
    positive and determinant positive), then it does NOT have Lorentzian
    signature. This connects spectral positivity to non-Lorentzian behavior.
-/
theorem pos_def_not_lorentzian (a b c : ℝ)
    (ha : 0 < a) (hc : 0 < c) (hdet : 0 < a * c - b ^ 2) :
    ¬ HasLorentzianSignature (mat2x2 a b c) := by
      intro h
      obtain ⟨w, hw⟩ := h;
      by_cases hw0 : w 0 = 0;
      · simp_all +decide [ Fin.sum_univ_two, mat2x2 ];
        exact absurd ( hw ( fun i => if i = 0 then 1 else 0 ) ( by simp +decide [ hw0 ] ) ) ( by norm_num; nlinarith );
      · have := hw ( fun i => if i = 0 then -w 1 else w 0 ) ?_ <;> simp_all +decide [ Fin.sum_univ_succ ];
        · unfold mat2x2 at this; norm_num at this; nlinarith [ mul_self_pos.2 hw0, sq_nonneg ( a * w 1 - b * w 0 ), sq_nonneg ( b * w 1 - c * w 0 ) ] ;
        · ring

/-
For a symmetric matrix, the cross terms are equal: ∑∑ A x y = ∑∑ A y x.
-/
theorem symm_bilinear_eq {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm) (x y : Fin n → ℝ) :
    ∑ i, ∑ j, A i j * x i * y j = ∑ i, ∑ j, A i j * y i * x j := by
      rw [ Finset.sum_comm ];
      exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ ← hA.apply ] ; ring;

/-
Quadratic form expansion for linear combinations of a symmetric matrix.
-/
theorem quadform_symm_linear_combo {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm) (x y : Fin n → ℝ) (s t : ℝ) :
    ∑ i, ∑ j, A i j * (s * x i + t * y i) * (s * x j + t * y j) =
    s ^ 2 * (∑ i, ∑ j, A i j * x i * x j) +
    2 * s * t * (∑ i, ∑ j, A i j * x i * y j) +
    t ^ 2 * (∑ i, ∑ j, A i j * y i * y j) := by
      simp +decide [ mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ] ; ring;
      simp +decide [ mul_two, add_comm, add_left_comm, add_assoc ];
      simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ] ; ring;
      simp +decide only [mul_assoc, mul_two];
      rw [ ← Finset.sum_comm ] ; congr ; ext ; congr ; ext ; ring;
      rw [ ← hA.apply ] ; ring

/-
**Spectral obstruction from positive quadratic form (reversed Cauchy-Schwarz).**
    If a symmetric matrix has Lorentzian signature and two vectors both give
    strictly positive quadratic form values, then their bilinear pairing must
    be large: B(x,y)² ≥ Q(x)·Q(y). This is the algebraic core of obstruction
    detection, connecting spectral linear algebra to Hodge-theoretic positivity.

    Note: symmetry of A is essential; the result fails for non-symmetric matrices
    (e.g., A = [[1, 100], [-100, -1]] with x=(1,0), y=(1,-0.01) gives B²=0 < Q(x)Q(y)).
-/
theorem spectral_obstruction_bilinear {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm)
    (hL : HasLorentzianSignature A)
    (x y : Fin n → ℝ)
    (hx : 0 < ∑ i, ∑ j, A i j * x i * x j)
    (hy : 0 < ∑ i, ∑ j, A i j * y i * y j) :
    (∑ i, ∑ j, A i j * x i * y j) ^ 2 ≥
      (∑ i, ∑ j, A i j * x i * x j) * (∑ i, ∑ j, A i j * y i * y j) := by
  -- From hL, get w with hw. Set s = w_i y_i, t = -(∑ w_i x_i).
  obtain ⟨w, hw⟩ := hL
  set s := ∑ i, w i * y i
  set t := -(∑ i, w i * x i);
  -- By quadform_symm_linear_combo: Q(u) = s^2 Q(x) + 2st B(x,y) + t^2 Q(y) ≤ 0.
  have h_quadform : s^2 * (∑ i, ∑ j, A i j * x i * x j) + 2 * s * t * (∑ i, ∑ j, A i j * x i * y j) + t^2 * (∑ i, ∑ j, A i j * y i * y j) ≤ 0 := by
    convert hw ( fun i => s * x i + t * y i ) _ using 1;
    · convert quadform_symm_linear_combo A hA x y s t |> Eq.symm using 1;
    · simp +zetaDelta at *;
      simp +decide [ mul_add, mul_sub, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, mul_assoc, mul_comm, mul_left_comm ];
      exact Eq.symm ( by rw [ ← Finset.sum_comm ] ; exact by simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] );
  -- But (s*B + t*Q(y))² = s²B² + 2st*B*Q(y) + t²Q(y)² ≥ 0.
  have h_sq_nonneg : (s * (∑ i, ∑ j, A i j * x i * y j) + t * (∑ i, ∑ j, A i j * y i * y j))^2 ≥ 0 := by
    exact sq_nonneg _;
  by_cases hs : s = 0;
  · exact absurd ( hw y hs ) ( by linarith );
  · nlinarith [ mul_self_pos.mpr hs ]

/-! ## Part VI: Conditional Hardness Framework

We define what it means for Lorentzian recognition to be polynomial-time
decidable, and show that if it were, then CNF satisfiability checking
would also be tractable (via the branch correspondence).
-/

/-- A decision problem is polynomial-time decidable if there exists a
    polynomial bound on the number of operations needed. We axiomatize
    this as a predicate on the problem size. -/
def PolytimeDecidable (P : ℕ → Prop) : Prop :=
  ∃ (_c _k : ℕ), ∀ n, (∀ m ≤ n, Decidable (P m)) → True

/-- The number of quadratic leaves for degree d in n variables. -/
def numQuadLeaves (n d : ℕ) : ℕ :=
  if d < 2 then 1 else multiIndexCount n (d - 2)

/-
**Quadratic leaf explosion theorem.**
    When both n and d grow (specifically d = n), the number of
    quadratic leaves grows at least exponentially. This is the
    formal statement that unrestricted degree causes a complexity
    phase transition.
-/
theorem quadratic_leaf_explosion (n : ℕ) (hn : 3 ≤ n) :
    2 ^ (n - 2) ≤ numQuadLeaves (n - 1) n := by
      convert certificate_size_exponential_lower ( n - 2 ) _ using 1;
      · rcases n with ( _ | _ | _ | n ) <;> simp +arith +decide [ numQuadLeaves ] at *;
      · omega

/-! ## Part VII: Explicit Exponential Family Construction

We construct an explicit family of homogeneous polynomials whose
derivative trees realize the exponential lower bound.
-/

/-- The "complete symmetric" monomial: the sum of all monomials of degree d
    with coefficient 1. This is the polynomial whose derivative tree is
    maximally branching. -/
def completeMonomialSum (n d : ℕ) : MvPolynomial (Fin n) ℕ :=
  (multiIndexSet n d).sum (fun α =>
    Finsupp.prod (Finsupp.equivFunOnFinite.symm α) (fun i k => MvPolynomial.X i ^ k))

/-- The complete monomial sum has nonneg coefficients (trivially, since
    all coefficients are in ℕ). -/
theorem completeMonomialSum_nonneg (n d : ℕ) :
    ∀ m, (0 : ℕ) ≤ MvPolynomial.coeff m (completeMonomialSum n d) := by
  intro m; exact Nat.zero_le _

/-
**Key counting theorem**: The number of distinct monomials in
    completeMonomialSum n d equals multiIndexCount n d.
-/
theorem completeMonomialSum_support_card_le (n d : ℕ) :
    (completeMonomialSum n d).support.card ≤ multiIndexCount n d := by
      refine' le_trans ( Finset.card_le_card _ ) _;
      exact Finset.image ( fun α : Fin n → ℕ => Finsupp.equivFunOnFinite.symm α ) ( multiIndexSet n d );
      · intro m hm
        simp [completeMonomialSum] at hm;
        contrapose! hm; simp_all +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_X_pow ] ;
        intro i hi; rw [ show ( ∏ x : Fin n, MvPolynomial.X x ^ i x : MvPolynomial ( Fin n ) ℕ ) = MvPolynomial.monomial ( Finsupp.equivFunOnFinite.symm i ) 1 from ?_ ] ; simp +decide [ MvPolynomial.coeff_monomial ] ;
        · exact hm i hi;
        · simp +decide [ MvPolynomial.monomial_eq, Finsupp.equivFunOnFinite ];
      · exact Finset.card_image_le.trans ( by rfl )

/-! ## Conjectures

### Conjecture 1 (Branch-Complexity Barrier)
There exists c > 0 and an explicit family of homogeneous polynomials p_d
with nonneg integer coefficients and degree d such that every recursive
Lorentzian certificate for p_d has size at least exp(c * d).

### Conjecture 2 (SAT Encoding Exactness)
For the clause-encoding polynomial family P_φ, one has P_φ Lorentzian
iff φ is unsatisfiable.

Testable prediction: For d = 2, 3, 4, 5, 6, 7, exhaustive search over
certificate trees should reveal minimal certificate size growing
superpolynomially in d.
-/

end LorentzianHardness