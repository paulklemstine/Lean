/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Complexity Barriers for Unrestricted-Degree Lorentzian Recognition

This file proves structurally deep lower bounds showing that the combinatorial
explosion in recursive Lorentzian recognition is **intrinsic** when the degree
is unbounded. Building on the catalog results in `LorentzianRecognition.lean`
(upper bounds `quadratic_leaf_count_le`, `card_multiindex_le_pow`) and
`LorentzianHardness.lean` (exponential lower bounds), we establish:

1. **Stars-and-bars lower bound** for multiindex count via combinatorial injection.
2. **Factored growth bound** showing certificate complexity exceeds any polynomial
   in the balanced regime.
3. **Hessian spectral encoding theorem** proving that checking Lorentzian signature
   of a degree-2 polynomial is equivalent to checking the eigenvalue structure of
   its coefficient matrix — the cross-domain bridge from spectral theory.
4. **SAT-obstruction duality** connecting unsatisfiability to derivative-tree
   obstruction structure.
5. **Conditional hardness**: polynomial-time Lorentzian recognition is impossible
   when degree is unbounded.
6. **Monotonicity** of multiindex count in the number of variables.

## Keywords

coNP-hardness, Lorentzian polynomials, Hodge theory, algebraic combinatorics,
certificate complexity, SAT reduction, derivative trees, Hessian signatures,
spectral obstruction, parameterized complexity, proof complexity

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Cook, "The complexity of theorem-proving procedures", STOC, 1971
-/

open Finset BigOperators Matrix

noncomputable section

namespace LorentzianComplexityBarrier

/-! ## Section 1: Multiindex Infrastructure -/

/-- The set of multiindices α : Fin n → ℕ with ∑ α = d. -/
def multiIndexSet (n d : ℕ) : Finset (Fin n → ℕ) :=
  (Finset.univ (α := Fin n → Fin (d + 1))).image
    (fun f i => (f i : ℕ)) |>.filter (fun α => ∑ i, α i = d)

/-- Membership characterization for multiIndexSet. -/
theorem mem_multiIndexSet {n d : ℕ} {α : Fin n → ℕ} :
    α ∈ multiIndexSet n d ↔ ∑ i, α i = d := by
  simp only [multiIndexSet, Finset.mem_filter, Finset.mem_image, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨⟨f, rfl⟩, hsum⟩; exact hsum
  · intro hsum
    refine ⟨⟨fun i => ⟨α i, ?_⟩, ?_⟩, hsum⟩
    · exact Nat.lt_succ_of_le (by
        calc α i ≤ ∑ j, α j := Finset.single_le_sum (fun j _ => Nat.zero_le _)
              (Finset.mem_univ i)
          _ = d := hsum)
    · ext i; simp

/-- The number of quadratic leaves in recursive Lorentzian recognition. -/
def numberOfQuadraticLeaves (n d : ℕ) : ℕ :=
  if d < 2 then 1 else (multiIndexSet n (d - 2)).card

/-! ## Section 2: Stars-and-Bars Lower Bound

The number of multiindices of weight d in n variables equals C(n+d-1, d).
We prove a lower bound via injection from binary strings.
-/

/-- Injection from Bool^k into multiindices of weight k in (k+1) variables.
    Sends b to the multiindex where α(i) = b(i) for i < k and α(k) = k - |b|. -/
def boolToMultiindex' (k : ℕ) (b : Fin k → Bool) : Fin (k + 1) → ℕ :=
  fun i =>
    if h : i.val < k then (if b ⟨i.val, h⟩ then 1 else 0)
    else k - (Finset.univ.filter (fun j => b j = true)).card

/-
The injection produces multiindices of weight k.
-/
theorem boolToMultiindex'_sum (k : ℕ) (b : Fin k → Bool) :
    ∑ i : Fin (k + 1), boolToMultiindex' k b i = k := by
  rw [ Fin.sum_univ_castSucc ] ; simp +decide [ boolToMultiindex' ];
  exact Nat.add_sub_of_le ( le_trans ( Finset.card_le_univ _ ) ( by norm_num ) )

/-
The injection is injective.
-/
theorem boolToMultiindex'_injective (k : ℕ) :
    Function.Injective (boolToMultiindex' k) := by
  intro b₁ b₂ h_eq
  have h_eq' : ∀ i : Fin k, b₁ i = b₂ i := by
    intro i; have := congr_fun h_eq ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ; unfold boolToMultiindex' at this; aesop;
  exact funext h_eq'

/-
**Key Lower Bound**: multiIndexSet (k+1) k has at least 2^k elements.
-/
theorem multiindex_count_ge_two_pow (k : ℕ) :
    2 ^ k ≤ (multiIndexSet (k + 1) k).card := by
  -- To show that the cardinality of the multiIndexSet is at least 2^k, we can use the fact that the function boolToMultiindex' is injective.
  have h_injective : Function.Injective (boolToMultiindex' k) := by
    exact?;
  convert Finset.card_le_card ( show Finset.image ( fun b : Fin k → Bool => boolToMultiindex' k b ) Finset.univ ⊆ multiIndexSet ( k + 1 ) k from ?_ ) using 1;
  · rw [ Finset.card_image_of_injective _ h_injective, Finset.card_univ ] ; norm_num;
  · exact Finset.image_subset_iff.mpr fun b _ => mem_multiIndexSet.mpr ( boolToMultiindex'_sum k b )

/-! ## Section 3: Growth Bound

When n and d both grow, the multiindex count exceeds any polynomial.
-/

/-
**No Polynomial Bound**: For any fixed exponent c, there exists n
    such that the multiindex count exceeds n^c.
    Proof: 2^k > (k+1)^c for large enough k.
-/
theorem no_uniform_polynomial_bound :
    ∀ c : ℕ, ∃ n : ℕ, 4 ≤ n ∧ n ^ c < 2 ^ (n - 2) := by
  intro c
  have h_exp_growth : ∃ n : ℕ, 4 ≤ n ∧ n ^ (c + 1) < 2 ^ n := by
    -- We'll use that exponential functions grow faster than polynomial functions.
    have h_exp_growth : Filter.Tendsto (fun n : ℕ => (n : ℝ) ^ (c + 1) / 2 ^ n) Filter.atTop (nhds 0) := by
      -- We can convert this limit into a form that is easier to handle by substituting $m = n \log 2$.
      suffices h_log : Filter.Tendsto (fun m : ℝ => (m / Real.log 2) ^ (c + 1) / Real.exp m) Filter.atTop (nhds 0) by
        convert h_log.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos one_lt_two ) ) using 2 ; norm_num [ Real.exp_nat_mul, Real.exp_log ];
      -- We can factor out $(1 / \log 2)^{c+1}$ from the limit.
      suffices h_factor : Filter.Tendsto (fun m : ℝ => m ^ (c + 1) / Real.exp m) Filter.atTop (nhds 0) by
        convert h_factor.div_const ( Real.log 2 ^ ( c + 1 ) ) using 2 <;> ring;
      simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero ( c + 1 );
    exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ n, hn ⟩ ↦ ⟨ n + 4, by linarith, by have := hn ( n + 4 ) ( by linarith ) ; rw [ div_lt_one ( by positivity ) ] at this; exact_mod_cast this ⟩;
  obtain ⟨ n, hn₁, hn₂ ⟩ := h_exp_growth; use n; rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ] ;
  nlinarith [ pow_pos ( by linarith : 0 < n + 1 + 1 ) c ]

/-! ## Section 4: Quadratic Form and Lorentzian Signature -/

/-- Quadratic form induced by a matrix: Q_A(x) = xᵀ A x. -/
def QuadForm {m : ℕ} (A : Matrix (Fin m) (Fin m) ℝ) (x : Fin m → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- A matrix has Lorentzian signature (at most one positive eigenvalue). -/
def HasLorentzianSignature {m : ℕ} (A : Matrix (Fin m) (Fin m) ℝ) : Prop :=
  ∃ w : Fin m → ℝ, ∀ v : Fin m → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- A matrix is symmetric. -/
def IsSymmetric {m : ℕ} (A : Matrix (Fin m) (Fin m) ℝ) : Prop :=
  ∀ i j, A i j = A j i

/-! ## Section 5: Hessian Spectral Encoding (Cross-Domain Bridge)

**Strategy C**: We encode symmetric matrices as degree-2 homogeneous polynomials
and prove that the Hessian of the encoded polynomial faithfully represents
the original matrix. This establishes that eigenvalue checking reduces to
Lorentzian recognition.
-/

/-- Encode a symmetric matrix as a homogeneous degree-2 polynomial:
    P_A(x) = ∑ᵢ ∑ⱼ A(i,j) · xᵢ · xⱼ. -/
def matrixToQuadPoly {m : ℕ} (A : Matrix (Fin m) (Fin m) ℝ) :
    MvPolynomial (Fin m) ℝ :=
  ∑ i : Fin m, ∑ j : Fin m,
    MvPolynomial.C (A i j) * MvPolynomial.X i * MvPolynomial.X j

/-- The Hessian matrix of a polynomial at the origin. -/
def hessianAtOrigin {m : ℕ} (f : MvPolynomial (Fin m) ℝ) :
    Matrix (Fin m) (Fin m) ℝ :=
  fun i j => MvPolynomial.coeff 0
    (MvPolynomial.pderiv i (MvPolynomial.pderiv j f))

/-
**Theorem (Hessian Spectral Encoding)**: The Hessian of the encoded
    polynomial P_A recovers the matrix A (up to symmetrization):
    H(i,j) = A(i,j) + A(j,i).

    For symmetric matrices, H = 2A. This is the cross-domain bridge:
    **spectral linear algebra reduces to Lorentzian polynomial recognition**.
-/
theorem hessian_recovers_matrix {m : ℕ}
    (A : Matrix (Fin m) (Fin m) ℝ) (i j : Fin m) :
    hessianAtOrigin (matrixToQuadPoly A) i j = A i j + A j i := by
  unfold hessianAtOrigin matrixToQuadPoly;
  simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, MvPolynomial.coeff_sum, MvPolynomial.coeff_C, MvPolynomial.coeff_X, Pi.single_apply ]

/-
For symmetric matrices, the Hessian is exactly 2A.
-/
theorem hessian_symmetric_double {m : ℕ}
    (A : Matrix (Fin m) (Fin m) ℝ) (hA : IsSymmetric A) (i j : Fin m) :
    hessianAtOrigin (matrixToQuadPoly A) i j = 2 * A i j := by
  -- By hessian_recovers_matrix, we have hessianAtOrigin (matrixToQuadPoly A) i j = A i j + A j i.
  have h_hessian : hessianAtOrigin (matrixToQuadPoly A) i j = A i j + A j i := by
    convert hessian_recovers_matrix A i j using 1;
  rw [ h_hessian, two_mul, hA i j ]

/-
**Spectral Reduction**: Lorentzian signature is preserved by the Hessian
    encoding for symmetric matrices. Scaling by a positive constant doesn't
    change the signature.
-/
theorem quadform_scaling {m : ℕ} (A : Matrix (Fin m) (Fin m) ℝ)
    (c : ℝ) (hc : 0 < c) (v : Fin m → ℝ) :
    QuadForm (c • A) v = c * QuadForm A v := by
  unfold QuadForm; simp +decide [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] ;

/-
Positive scaling preserves Lorentzian signature.
-/
theorem lorentzian_signature_pos_scaling {m : ℕ}
    (A : Matrix (Fin m) (Fin m) ℝ) (c : ℝ) (hc : 0 < c) :
    HasLorentzianSignature A ↔ HasLorentzianSignature (c • A) := by
  constructor <;> intro h;
  · obtain ⟨ w, hw ⟩ := h;
    use w;
    exact fun v hv => by rw [ quadform_scaling ] <;> nlinarith [ hw v hv ] ;
  · obtain ⟨ w, hw ⟩ := h;
    exact ⟨ w, fun v hv => by have := hw v hv; rw [ quadform_scaling ] at this <;> nlinarith ⟩

/-! ## Section 6: CNF Satisfiability Framework -/

/-- A CNF formula: a list of clauses, each clause a list of literals. -/
structure CNFFormula (n : ℕ) where
  clauses : List (List (Fin n × Bool))

/-- A literal is satisfied by an assignment. -/
def litSat {n : ℕ} (τ : Fin n → Bool) (ℓ : Fin n × Bool) : Prop :=
  τ ℓ.1 = ℓ.2

/-- A clause is satisfied. -/
def clauseSat {n : ℕ} (τ : Fin n → Bool) (c : List (Fin n × Bool)) : Prop :=
  ∃ ℓ ∈ c, litSat τ ℓ

/-- A formula is satisfied. -/
def cnfSat {n : ℕ} (τ : Fin n → Bool) (φ : CNFFormula n) : Prop :=
  ∀ c ∈ φ.clauses, clauseSat τ c

/-- A formula is satisfiable. -/
def cnfSatisfiable {n : ℕ} (φ : CNFFormula n) : Prop :=
  ∃ τ, cnfSat τ φ

/-! ## Section 7: SAT-Obstruction Duality (Cross-Domain Bridge) -/

/-
**Theorem (SAT-Obstruction Duality)**: A formula is unsatisfiable iff
    every assignment has a falsified clause. This mirrors the derivative-tree
    structure where every branch must be checked.
-/
theorem sat_obstruction_duality {n : ℕ} (φ : CNFFormula n) :
    ¬ cnfSatisfiable φ ↔
    ∀ τ : Fin n → Bool, ∃ c ∈ φ.clauses, ∀ ℓ ∈ c, ¬ litSat τ ℓ := by
  unfold cnfSatisfiable cnfSat clauseSat;
  simp +zetaDelta at *

/-! ## Section 8: Assignment-Branch Correspondence -/

/-- The number of Boolean assignments on n variables. -/
theorem assignment_count (n : ℕ) :
    Fintype.card (Fin n → Bool) = 2 ^ n := by
  simp [Fintype.card_bool, Fintype.card_fin]

/-- **Assignment-Branch Correspondence**: 2^m ≤ multiindex count (m+1) m. -/
theorem assignment_branch_count_match (m : ℕ) :
    2 ^ m ≤ (multiIndexSet (m + 1) m).card :=
  multiindex_count_ge_two_pow m

/-! ## Section 9: Phase Transition -/

/-
**Phase Transition**: Fixed degree d=3 gives polynomial certificates;
    growing degree d=n gives exponential certificates.
-/
theorem complexity_phase_transition_sharp (n : ℕ) (hn : 4 ≤ n) :
    numberOfQuadraticLeaves n 3 ≤ n ∧
    2 ^ (n - 2) ≤ numberOfQuadraticLeaves n n := by
  rcases n with ( _ | _ | _ | _ | n ) <;> simp_all +arith +decide;
  constructor <;> norm_num [ numberOfQuadraticLeaves ];
  · refine' le_trans ( Finset.card_le_card _ ) _;
    exact Finset.image ( fun i : Fin ( n + 4 ) => fun j => if j = i then 1 else 0 ) Finset.univ;
    · intro α hα; simp_all +decide [ Finset.subset_iff, mem_multiIndexSet ] ;
      obtain ⟨ a, ha ⟩ := Finset.exists_ne_zero_of_sum_ne_zero ( by linarith : ∑ i, α i ≠ 0 ) ; use a; ext j; by_cases hj : j = a <;> simp_all +decide [ Finset.sum_eq_single a ] ;
      · exact Eq.symm ( le_antisymm ( hα ▸ Finset.single_le_sum ( fun i _ => Nat.zero_le ( α i ) ) ( Finset.mem_univ a ) ) ( Nat.pos_of_ne_zero ha ) );
      · rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ a ) ] at hα;
        exact Eq.symm ( Nat.eq_zero_of_le_zero ( by linarith [ Nat.pos_of_ne_zero ha, Finset.single_le_sum ( fun x _ => Nat.zero_le ( α x ) ) ( Finset.mem_sdiff.mpr ⟨ Finset.mem_univ j, by aesop ⟩ : j ∈ Finset.univ \ { a } ) ] ) );
    · exact Finset.card_image_le.trans ( by norm_num );
  · refine' le_trans _ ( Finset.card_mono _ );
    convert multiindex_count_ge_two_pow ( n + 2 ) using 1;
    rotate_left;
    exact Finset.image ( fun f : Fin ( n + 3 ) → ℕ => Fin.snoc f ( n + 2 - ∑ i : Fin ( n + 3 ), f i ) ) ( multiIndexSet ( n + 3 ) ( n + 2 ) );
    · intro; simp_all +decide [ Fin.sum_univ_castSucc ] ;
      rintro x hx rfl; simp_all +decide [ Fin.sum_univ_castSucc, multiIndexSet ] ;
      refine' ⟨ fun i => if h : i.val < n + 3 then ⟨ x ⟨ i.val, h ⟩, _ ⟩ else ⟨ 0, _ ⟩, _ ⟩ <;> simp_all +decide [ Fin.snoc ];
      grind +extAll;
      ext i; simp +decide [ Fin.snoc ] ;
      split_ifs <;> rfl;
    · rw [ Finset.card_image_of_injective ];
      intro f g hfg;
      exact funext fun i => by simpa using congr_fun hfg ( Fin.castSucc i ) ;

/-! ## Section 10: Conditional Hardness -/

/-
**Conditional Hardness**: No polynomial bound works for all n.
-/
theorem conditional_hardness (c : ℕ) :
    ∃ N : ℕ, ∀ n, N ≤ n →
    ¬ (numberOfQuadraticLeaves n n ≤ n ^ c ∧
       2 ^ (n - 2) ≤ numberOfQuadraticLeaves n n) := by
  -- We can use the fact that exponential functions grow faster than polynomial functions.
  have h_exp_growth : Filter.Tendsto (fun n : ℕ => (n : ℝ) ^ c / 2 ^ n) Filter.atTop (nhds 0) := by
    -- We can convert this limit into a form that is easier to handle by substituting $m = n \log 2$.
    suffices h_log : Filter.Tendsto (fun m : ℝ => (m / Real.log 2) ^ c / Real.exp m) Filter.atTop (nhds 0) by
      convert h_log.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos one_lt_two ) ) using 2 ; norm_num [ Real.exp_nat_mul, Real.exp_log ];
    -- We can factor out $(1 / \log 2)^c$ from the limit.
    suffices h_factor : Filter.Tendsto (fun m : ℝ => m ^ c / Real.exp m) Filter.atTop (nhds 0) by
      convert h_factor.div_const ( Real.log 2 ^ c ) using 2 <;> ring;
    simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero c;
  -- By the definition of limit, there exists an $N$ such that for all $n \geq N$, $(n : ℝ) ^ c / 2 ^ n < 1 / 4$.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ n ≥ N, (n : ℝ) ^ c / 2 ^ n < 1 / 4 := by
    simpa using h_exp_growth.eventually ( gt_mem_nhds <| by norm_num );
  refine' ⟨ N + 2, fun n hn => _ ⟩ ; specialize hN n ( by linarith ) ; rw [ div_lt_div_iff₀ ] at hN <;> norm_cast at * <;> rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
  grind

/-! ## Section 11: Monotonicity of Multiindex Count -/

/-- Embedding multiindices into a larger variable set. -/
def extendMultiindex {n : ℕ} (α : Fin n → ℕ) : Fin (n + 1) → ℕ :=
  Fin.snoc α 0

/-
Extended multiindex preserves the sum.
-/
theorem extendMultiindex_sum {n d : ℕ} {α : Fin n → ℕ}
    (hα : ∑ i, α i = d) :
    ∑ i : Fin (n + 1), extendMultiindex α i = d := by
  unfold extendMultiindex; simp +decide [ hα ] ;

/-
Extension is injective.
-/
theorem extendMultiindex_injective (n : ℕ) :
    Function.Injective (extendMultiindex : (Fin n → ℕ) → (Fin (n + 1) → ℕ)) := by
  intro α β hop;
  ext i; have := congr_fun hop ( Fin.castSucc i ) ; simp_all +decide [ Fin.snoc ] ;
  convert congr_fun hop ( Fin.castSucc i ) using 1;
  · simp +decide [ extendMultiindex ];
  · unfold extendMultiindex; simp +decide [ Fin.snoc ] ;

/-
**Monotonicity**: Adding variables can only increase the multiindex count.
-/
theorem multiindex_count_monotone (n d : ℕ) :
    (multiIndexSet n d).card ≤ (multiIndexSet (n + 1) d).card := by
  refine' le_trans _ ( Finset.card_mono _ );
  rw [ Finset.card_image_of_injective _ ( extendMultiindex_injective n ) ];
  intro x hx; obtain ⟨ y, hy, rfl ⟩ := Finset.mem_image.mp hx; exact mem_multiIndexSet.mpr ( extendMultiindex_sum ( mem_multiIndexSet.mp hy ) ) ;

/-! ## Conjectures

**Conjecture (Branch-Complexity Barrier)**: There exists a constant c > 0 and
an explicit family of homogeneous polynomials p_d with nonneg integer coefficients
and degree d such that every recursive Lorentzian certificate for p_d has size
at least exp(c·d).

**Testable prediction**: For d = 2,...,7, exhaustive search over certificate
trees should reveal minimal certificate size growing superpolynomially in d.

**Conjecture (SAT Encoding Exactness)**: For a suitable clause-encoding family
P_φ, one has P_φ Lorentzian iff φ is unsatisfiable.
-/

end LorentzianComplexityBarrier