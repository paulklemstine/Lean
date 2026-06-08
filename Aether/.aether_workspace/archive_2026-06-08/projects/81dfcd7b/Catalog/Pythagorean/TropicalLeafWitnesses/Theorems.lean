/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Pythagorean.TropicalLeafWitnesses.Defs

/-!
# Tropical Leaf Witnesses: Main Theorems

This file proves the main theorems of the tropical leaf witness theory,
establishing the bridge between tropical/valuative invariants and spectral
witnesses of derivative leaves.

## Main Results

* `derivativeLeaf_univ` — Derivative leaf over full variable set is the original polynomial
* `derivativeLeaf_zero` — Derivative leaf of zero is zero
* `derivativeLeaf_add` — Derivative leaf distributes over addition
* `coeffAbsSum_nonneg` — The L¹ coefficient norm is nonneg
* `tropicalLeafWitness_nonneg` — The tropical leaf witness is nonneg
* `leafWitness_nonneg` — The spectral witness is nonneg
* `abs_eval_one_le_coeffAbsSum` — Evaluation at 1 bounded by L¹ norm
* `hessian_entry_le_tropicalMixedHessian` — Each Hessian entry bounded by tropical Hessian
* `leafWitness_le_tropicalLeafWitness` — **Main theorem**: spectral witness ≤ tropical witness
* `derivativeLeaf_insert` — Derivative leaf relates to pderiv and larger subsystem

## Cross-Domain Connections

The main theorem `leafWitness_le_tropicalLeafWitness` bridges:
- **Spectral theory** (eigenvalue-based witnesses) ↔ **Tropical geometry** (coefficient valuations)
- **Algebraic geometry** (Newton polytopes) ↔ **Combinatorial optimization** (polyhedral bounds)
- **Lorentzian polynomials** ↔ **Discrete convex analysis** (submodular functions)
-/

open Finset BigOperators Matrix MvPolynomial Finsupp

noncomputable section

/-! ## §1. Basic Properties of Derivative Leaves -/

/-- The derivative leaf over the full variable set is the original polynomial:
    no variables are differentiated out. -/
theorem derivativeLeaf_univ {n : ℕ} (p : MvPolynomial (Fin n) ℝ) :
    derivativeLeaf p Finset.univ = p := by
  unfold derivativeLeaf
  simp

/-- The derivative leaf of the zero polynomial is zero, for any subsystem. -/
theorem derivativeLeaf_zero {n : ℕ} (s : Finset (Fin n)) :
    derivativeLeaf (0 : MvPolynomial (Fin n) ℝ) s = 0 := by
  unfold derivativeLeaf
  induction (Finset.univ \ s).toList with
  | nil => simp
  | cons x xs ih => simp [ih]

/-- The derivative leaf distributes over polynomial addition:
    `L_A(p + q) = L_A(p) + L_A(q)`.
    This follows from linearity of partial differentiation. -/
theorem derivativeLeaf_add {n : ℕ}
    (p q : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) :
    derivativeLeaf (p + q) s = derivativeLeaf p s + derivativeLeaf q s := by
  unfold derivativeLeaf
  induction (Finset.univ \ s).toList with
  | nil => simp
  | cons x xs ih => simp [map_add, ih]

/-- The derivative leaf distributes over scalar multiplication:
    `L_A(c • p) = c • L_A(p)`. -/
theorem derivativeLeaf_smul {n : ℕ}
    (c : ℝ) (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) :
    derivativeLeaf (MvPolynomial.C c * p) s =
    MvPolynomial.C c * derivativeLeaf p s := by
  unfold derivativeLeaf
  induction (Finset.univ \ s).toList with
  | nil => simp
  | cons x xs ih => simp [ih]

/-! ## §2. Coefficient Norm Properties -/

/-- The L¹ coefficient norm is always nonneg. -/
theorem coeffAbsSum_nonneg {σ : Type*} [DecidableEq σ]
    (p : MvPolynomial σ ℝ) : 0 ≤ coeffAbsSum p := by
  unfold coeffAbsSum
  apply Finset.sum_nonneg
  intros
  exact abs_nonneg _

/-- The L¹ coefficient norm of zero is zero. -/
theorem coeffAbsSum_zero {σ : Type*} [DecidableEq σ] :
    coeffAbsSum (0 : MvPolynomial σ ℝ) = 0 := by
  unfold coeffAbsSum
  simp

/-
The L¹ coefficient norm is subadditive:
    `‖p + q‖₁ ≤ ‖p‖₁ + ‖q‖₁`.
-/
theorem coeffAbsSum_add_le {σ : Type*} [DecidableEq σ]
    (p q : MvPolynomial σ ℝ) :
    coeffAbsSum (p + q) ≤ coeffAbsSum p + coeffAbsSum q := by
  unfold coeffAbsSum;
  rw [ Finset.sum_subset ( show ( p + q |> MvPolynomial.support ) ⊆ p.support ∪ q.support from ?_ ) ];
  · refine' le_trans ( Finset.sum_le_sum fun x hx => _ ) _;
    exact fun x => |MvPolynomial.coeff x p| + |MvPolynomial.coeff x q|;
    · simp +zetaDelta at *;
      grind;
    · rw [ Finset.sum_add_distrib ];
      rw [ ← Finset.sum_subset ( Finset.subset_union_left ), ← Finset.sum_subset ( Finset.subset_union_right ) ] <;> aesop;
  · aesop;
  · intro d hd; contrapose! hd; aesop;

/-! ## §3. Tropical Leaf Witness Properties -/

/-- The tropical leaf witness is always nonneg. -/
theorem tropicalLeafWitness_nonneg {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) :
    0 ≤ tropicalLeafWitness p A := by
  unfold tropicalLeafWitness
  apply Finset.sum_nonneg
  intro a _
  exact coeffAbsSum_nonneg _

/-- The spectral (leaf) witness is always nonneg, by definition. -/
theorem leafWitness_nonneg {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) :
    0 ≤ leafWitness p A := by
  unfold leafWitness positiveSpectralWitnessProxy
  exact le_max_right _ _

/-! ## §4. Evaluation Bounds via Coefficient Norms -/

/-
**Key lemma**: Evaluating a polynomial at the all-ones point is bounded
    (in absolute value) by the L¹ coefficient norm.

    For `p = ∑ cₐ x^α`, evaluating at `x = 1` gives `∑ cₐ`, and
    `|∑ cₐ| ≤ ∑ |cₐ| = ‖p‖₁`.

    This is the bridge between evaluation-based spectral witnesses and
    coefficient-based tropical witnesses.
-/
theorem abs_eval_one_le_coeffAbsSum {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) :
    |MvPolynomial.eval (fun _ => (1 : ℝ)) p| ≤ coeffAbsSum p := by
  convert Finset.abs_sum_le_sum_abs _ _ using 2 ; simp +decide [ MvPolynomial.eval_eq' ];
  · rfl;
  · infer_instance

/-- Each entry of the mixed Hessian at ones is bounded (in absolute value)
    by the corresponding entry of the tropical Hessian matrix. -/
theorem hessian_entry_le_tropicalMixedHessian {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (i j : Fin n) :
    |MvPolynomial.eval (fun _ => (1 : ℝ))
      (MvPolynomial.pderiv i (MvPolynomial.pderiv j p))| ≤
    tropicalMixedHessian p i j := by
  unfold tropicalMixedHessian
  exact abs_eval_one_le_coeffAbsSum _

/-! ## §5. The Main Theorem: Spectral ≤ Tropical -/

/-
**Trace of the Hessian at ones bounded by sum of tropical Hessian diagonal**.
    This extends the pointwise bound to the matrix trace level.

    The proof uses:
    1. `le_abs_self`: each diagonal entry is ≤ its absolute value
    2. `abs_eval_one_le_coeffAbsSum`: each |entry| is ≤ its tropical counterpart
    Combined via `Finset.sum_le_sum`.
-/
theorem trace_hessian_le_sum_tropicalHessian {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) :
    (mixedHessianAtOnes p A).trace ≤
    ∑ a : A, tropicalMixedHessian p (a : Fin n) (a : Fin n) := by
  convert Finset.sum_le_sum fun i _ => le_trans ( le_abs_self _ ) ( hessian_entry_le_tropicalMixedHessian p i i ) using 1;
  any_goals exact A;
  · convert Finset.sum_attach A fun i => ( eval fun x => 1 ) ( ( pderiv i ) ( ( pderiv i ) p ) ) using 1;
  · refine' Finset.sum_bij ( fun x hx => x ) _ _ _ _ <;> aesop

/-- **Main Theorem (Tropical-Spectral Bridge)**:
    The leaf spectral witness is bounded above by the tropical leaf witness.

    `leafWitness(p, A) ≤ tropicalLeafWitness(p, A)`

    This is the flagship result: it shows that the analytic/spectral certification
    problem (computing eigenvalues of the mixed Hessian) can be replaced by the
    purely combinatorial computation of summing absolute coefficient norms of
    second partial derivatives.

    **Proof**: The leaf witness is `max(tr(H), 0)` where `H` is the mixed
    Hessian of `L_A` at ones. By `trace_hessian_le_sum_tropicalHessian`,
    the trace is bounded by the sum of tropical Hessian diagonal entries,
    which is exactly the tropical leaf witness. Since the tropical witness
    is nonneg, the `max(·, 0)` is absorbed.

    **Cross-domain significance**: This theorem replaces an eigenvalue computation
    (spectral theory) with a coefficient-sum computation (tropical geometry),
    bridging analysis and combinatorics. -/
theorem leafWitness_le_tropicalLeafWitness {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) :
    leafWitness p A ≤ tropicalLeafWitness p A := by
  unfold leafWitness positiveSpectralWitnessProxy tropicalLeafWitness
  apply max_le _ (Finset.sum_nonneg (fun a _ => coeffAbsSum_nonneg _))
  exact trace_hessian_le_sum_tropicalHessian _ _

/-- The valuative leaf upper bound holds for all polynomials and subsystems.
    This instantiates the central definition `ValuativeLeafUpperBound`. -/
theorem valuativeLeafUpperBound_holds {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) :
    ValuativeLeafUpperBound p A :=
  leafWitness_le_tropicalLeafWitness p A

/-! ## §6. Derivative Leaf Structure Theorems -/

/-
Appending a differentiation to the leaf: if `j ∉ A`, then
    the derivative leaf over `A` equals `pderiv j` applied to the
    derivative leaf over `A ∪ {j}`, since differentiating in `j`
    is one of the operations that produces `L_A` from `p`.

    This is the key structural theorem connecting derivative leaves
    at different subsystem levels.
-/
theorem derivativeLeaf_insert {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) (j : Fin n) (hj : j ∉ A) :
    ∃ q : MvPolynomial (Fin n) ℝ,
      derivativeLeaf p A = MvPolynomial.pderiv j q ∧
      q = derivativeLeaf p (insert j A) := by
  refine' ⟨ _, _, rfl ⟩;
  have h_foldr : ∀ (l : List (Fin n)), j ∈ l → List.foldr (fun i q => MvPolynomial.pderiv i q) p l = MvPolynomial.pderiv j (List.foldr (fun i q => MvPolynomial.pderiv i q) p (List.erase l j)) := by
    intro l hj; induction' l with hd tl ih <;> simp_all +decide [ List.erase_cons ] ;
    cases hj <;> simp_all +decide [ List.erase_cons ];
    split_ifs <;> simp_all +decide [ List.foldr ];
    -- By definition of $pderiv$, we know that $pderiv hd$ and $pderiv j$ commute.
    have h_comm : ∀ (q : MvPolynomial (Fin n) ℝ), (pderiv hd) ((pderiv j) q) = (pderiv j) ((pderiv hd) q) := by
      intro q; induction q using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_X ] ;
      simp_all +decide [ Pi.single_apply, mul_comm ];
      split_ifs <;> simp_all +decide [ MvPolynomial.pderiv_X ]; all_goals ring;
    exact h_comm _;
  convert h_foldr _ _;
  · have h_perm : List.Perm (Finset.toList (Finset.univ \ insert j A)) (List.erase (Finset.toList (Finset.univ \ A)) j) := by
      rw [ ← Multiset.coe_eq_coe ];
      simp +decide [ Finset.ext_iff, hj ];
      ext i; by_cases hi : i = j <;> simp +decide [ hi, hj ] ;
      · rw [ List.count_eq_one_of_mem ];
        · norm_num;
        · exact Finset.nodup_toList _;
        · simp +decide [ hj ];
      · rw [ ← Multiset.coe_count ] ; aesop;
    have h_foldr_perm : ∀ (l1 l2 : List (Fin n)), List.Perm l1 l2 → List.foldr (fun i q => MvPolynomial.pderiv i q) p l1 = List.foldr (fun i q => MvPolynomial.pderiv i q) p l2 := by
      intros l1 l2 h_perm; induction' h_perm with l1 l2 h_perm ih <;> simp_all +decide [ List.foldr ] ;
      -- By definition of $pderiv$, we know that $pderiv i$ and $pderiv j$ commute.
      have h_comm : ∀ (i j : Fin n) (q : MvPolynomial (Fin n) ℝ), MvPolynomial.pderiv i (MvPolynomial.pderiv j q) = MvPolynomial.pderiv j (MvPolynomial.pderiv i q) := by
        intros i j q; exact (by
        induction q using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_X ];
        simp +decide [ Pi.single_apply, mul_comm ] ; ring;
        aesop);
      exact h_comm _ _ _;
    exact h_foldr_perm _ _ h_perm;
  · aesop

/-! ## §7. Tropical Mixed Hessian Properties -/

/-
The tropical mixed Hessian is symmetric:
    `tropicalMixedHessian p i j = tropicalMixedHessian p j i`.
    This follows from the commutativity of mixed partial derivatives
    for polynomials over a commutative ring.
-/
theorem tropicalMixedHessian_comm {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (i j : Fin n) :
    tropicalMixedHessian p i j = tropicalMixedHessian p j i := by
  -- By induction on the polynomial, we can show that the mixed partial derivatives commute.
  have h_comm : ∀ (p : MvPolynomial (Fin n) ℝ) (i j : Fin n), MvPolynomial.pderiv i (MvPolynomial.pderiv j p) = MvPolynomial.pderiv j (MvPolynomial.pderiv i p) := by
    -- By definition of polynomial differentiation, we can apply the product rule to show that the mixed partial derivatives are equal.
    have h_comm : ∀ (p : MvPolynomial (Fin n) ℝ) (i j : Fin n), MvPolynomial.pderiv i (MvPolynomial.pderiv j p) = MvPolynomial.pderiv j (MvPolynomial.pderiv i p) := by
      intro p i j
      have h_comm : ∀ (m : (Fin n) →₀ ℕ), MvPolynomial.pderiv i (MvPolynomial.pderiv j (MvPolynomial.monomial m 1)) = MvPolynomial.pderiv j (MvPolynomial.pderiv i (MvPolynomial.monomial m 1)) := by
        simp +decide [ MvPolynomial.pderiv_monomial ];
        intro m; by_cases hi : i = j <;> simp +decide [ hi, mul_comm, tsub_tsub ] ;
        rw [ add_comm ]
      induction' p using MvPolynomial.induction_on with m p q hp hq;
      · simp +decide;
      · simp +decide [ hp, hq ];
      · simp +decide [*];
        simp +decide [ Pi.single_apply, mul_comm ] ; ring;
        aesop;
    assumption;
  unfold tropicalMixedHessian; aesop;

/-- The tropical mixed Hessian is nonneg. -/
theorem tropicalMixedHessian_nonneg {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (i j : Fin n) :
    0 ≤ tropicalMixedHessian p i j := by
  unfold tropicalMixedHessian
  exact coeffAbsSum_nonneg _

/-- The tropical Hessian matrix has nonneg entries. -/
theorem tropicalHessianMatrix_nonneg {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (i j : Fin n) :
    0 ≤ tropicalHessianMatrix p i j :=
  tropicalMixedHessian_nonneg p i j

/-! ## §8. Cross-Domain: DPP Tropical Witnesses -/

/-- For a DPP kernel matrix `K`, the DPP tropical leaf witness is nonneg. -/
theorem dppTropicalLeafWitness_nonneg {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (A : Finset (Fin n)) :
    0 ≤ dppTropicalLeafWitness K A :=
  tropicalLeafWitness_nonneg _ _

/-- The DPP spectral witness is bounded by the DPP tropical witness.
    This is the DPP specialization of the main theorem. -/
theorem dpp_leafWitness_le_tropicalLeafWitness {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (A : Finset (Fin n)) :
    leafWitness
      (Matrix.det (1 + Matrix.diagonal (fun i => (MvPolynomial.X i : MvPolynomial (Fin n) ℝ)) *
        K.map MvPolynomial.C)) A ≤
    dppTropicalLeafWitness K A := by
  unfold dppTropicalLeafWitness
  exact leafWitness_le_tropicalLeafWitness _ _

end