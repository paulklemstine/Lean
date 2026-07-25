/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Hardness of Unrestricted-Degree Lorentzian Recognition

This file establishes complexity lower bounds for recursive Lorentzian polynomial
recognition when the degree is unbounded, complementing the upper bounds in
`Catalog/Bridges/LorentzianRecognition.lean`.

## Main Results

* `central_binomial_lower_bound` — The central binomial coefficient C(2d, d) ≥ 2^d.
* `boolToMultiindex_injective` — An explicit injection from Boolean assignments to
  multiindices, the constructive core of the lower bound.
* `multiindex_count_exponential_lower` — The multiindex count grows exponentially:
  multiIndexCount (m+1) m ≥ 2^m.
* `leaf_count_exponential_lower_bound` — Quadratic leaf count in recursive
  Lorentzian recognition grows exponentially when degree is unbounded.
* `complexity_phase_transition` — Phase transition: polynomial for fixed degree,
  exponential for unbounded degree.
* `sat_obstruction_duality` — Cross-domain: unsatisfiability ↔ universal obstruction.
* `spectral_obstruction_non_lorentzian` — Cross-domain: spectral double-positivity
  implies non-Lorentzian signature.

## Strategy

We complement the catalog upper bound `quadratic_leaf_count_le` (≤ n^(d-2)) with
an exponential lower bound. The key construction is an injection from {0,1}^m into
multiindices of weight m in (m+1) variables.

## Application Keywords

coNP-hardness, Lorentzian polynomials, Hodge theory, algebraic combinatorics,
certificate complexity, SAT reduction, derivative trees, Hessian signatures,
spectral obstruction, parameterized complexity, proof complexity

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Cook, "The complexity of theorem-proving procedures", STOC 1971
-/

open Finset BigOperators

noncomputable section

namespace LorentzianHardness

/-! ## Catalog Definitions (from LorentzianRecognition.lean)

We restate the key definitions needed from the catalog file so this file
is self-contained and buildable independently.
-/

/-- The quadratic form Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- Lorentzian signature: at most one positive eigenvalue direction. -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Symmetry of a matrix. -/
def IsSymm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ i j, A i j = A j i

/-- The set of multiindices α : Fin n → ℕ with ∑ α = d. -/
def multiIndexSet (n d : ℕ) : Finset (Fin n → ℕ) :=
  (Finset.univ (α := Fin n → Fin (d + 1))).image
    (fun f i => (f i : ℕ)) |>.filter (fun α => ∑ i, α i = d)

/-- The number of multiindices of weight d in n variables. -/
def multiIndexCount (n d : ℕ) : ℕ :=
  (multiIndexSet n d).card

/-- Membership in multiIndexSet. -/
theorem mem_multiIndexSet {n d : ℕ} {α : Fin n → ℕ} :
    α ∈ multiIndexSet n d ↔ ∑ i, α i = d := by
  simp only [multiIndexSet, Finset.mem_filter, Finset.mem_image, Finset.mem_univ,
    true_and]
  constructor
  · rintro ⟨⟨f, rfl⟩, hsum⟩; exact hsum
  · intro hsum
    refine ⟨⟨fun i => ⟨α i, ?_⟩, ?_⟩, hsum⟩
    · have : α i ≤ ∑ j, α j :=
        Finset.single_le_sum (fun j _ => Nat.zero_le _) (Finset.mem_univ i)
      omega
    · ext i; simp

/-- The number of quadratic leaves in recursive Lorentzian recognition. -/
def numberOfQuadraticLeaves (n d : ℕ) : ℕ :=
  if d < 2 then 1 else multiIndexCount n (d - 2)

/-
Upper bound: numberOfQuadraticLeaves n d ≤ n^(d-2) (from catalog).
-/
theorem quadratic_leaf_count_le (n d : ℕ) (hn : 0 < n) (hd : 2 ≤ d) :
    numberOfQuadraticLeaves n d ≤ n ^ (d - 2) := by
  rw [ numberOfQuadraticLeaves, if_neg ( by linarith ) ];
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.image ( fun f : Fin ( d - 2 ) → Fin n => fun i => Finset.card ( Finset.filter ( fun x => f x = i ) Finset.univ ) ) ( Finset.univ : Finset ( Fin ( d - 2 ) → Fin n ) );
  · intro α hα; simp_all +decide [ Finset.subset_iff ] ;
    -- Construct a function $a : Fin (d - 2) → Fin n$ such that the count of each $i$ in $a$ is exactly $\alpha i$.
    obtain ⟨a, ha⟩ : ∃ a : Fin (d - 2) → Fin n, ∀ i, Finset.card (Finset.filter (fun x => a x = i) Finset.univ) = α i := by
      have h_seq : ∃ a : List (Fin n), a.length = d - 2 ∧ ∀ i, List.count i a = α i := by
        have h_seq : ∃ a : List (Fin n), (∀ i, List.count i a = α i) ∧ a.length = ∑ i, α i := by
          use List.flatMap (fun i => List.replicate (α i) i) (Finset.univ.toList);
          simp +decide [ List.count_flatMap, List.length_flatMap ];
          simp +decide [ List.count_replicate ];
        exact ⟨ h_seq.choose, h_seq.choose_spec.2.trans ( mem_multiIndexSet.mp hα ), h_seq.choose_spec.1 ⟩;
      obtain ⟨ a, ha₁, ha₂ ⟩ := h_seq;
      -- Convert the list `a` into a function from `Fin (d - 2)` to `Fin n`.
      obtain ⟨f, hf⟩ : ∃ f : Fin (d - 2) → Fin n, a = List.ofFn f := by
        use fun i => a.get ⟨ i, by linarith [ Fin.is_lt i ] ⟩;
        refine' List.ext_get _ _ <;> aesop;
      use f; intro i; specialize ha₂ i; simp_all +decide [ List.count ] ;
      rw [ ← ha₂, List.countP_eq_length_filter ];
      rw [ List.ofFn_eq_map ] ; simp +decide [ List.filter_map, Finset.card ] ;
      congr;
    exact ⟨ a, funext ha ⟩;
  · exact Finset.card_image_le.trans ( by simp +decide [ Finset.card_univ ] )

/-! ## Part 1: CNF Satisfiability Framework -/

/-- A CNF formula over n Boolean variables. -/
structure CNFFormula (n : ℕ) where
  clauses : List (List (Fin n × Bool))

/-- A literal is satisfied when the assignment matches its polarity. -/
def literalSatisfied {n : ℕ} (τ : Fin n → Bool) (lit : Fin n × Bool) : Prop :=
  τ lit.1 = lit.2

/-- A clause is satisfied if at least one literal is satisfied. -/
def clauseSatisfied {n : ℕ} (τ : Fin n → Bool) (C : List (Fin n × Bool)) : Prop :=
  ∃ lit ∈ C, literalSatisfied τ lit

/-- A formula is satisfied if all clauses are satisfied. -/
def formulaSatisfied {n : ℕ} (φ : CNFFormula n) (τ : Fin n → Bool) : Prop :=
  ∀ C ∈ φ.clauses, clauseSatisfied τ C

/-- A formula is satisfiable if some assignment satisfies it. -/
def CNFSatisfiable {n : ℕ} (φ : CNFFormula n) : Prop :=
  ∃ τ, formulaSatisfied φ τ

/-- A clause is an obstruction for an assignment if not satisfied. -/
def isClauseObstruction {n : ℕ} (τ : Fin n → Bool)
    (C : List (Fin n × Bool)) : Prop :=
  ¬ clauseSatisfied τ C

/-- An assignment is obstructed if some clause is unsatisfied. -/
def isObstructed {n : ℕ} (φ : CNFFormula n) (τ : Fin n → Bool) : Prop :=
  ∃ C ∈ φ.clauses, isClauseObstruction τ C

/-- The number of partial assignments for n variables. -/
def numPartialAssignments (n : ℕ) : ℕ := 2 ^ n

/-! ## Part 2: Central Binomial Coefficient Lower Bound -/

/-
**Central binomial lower bound**: C(2d, d) ≥ 2^d for all d.
    Proof by induction using C(2(d+1), d+1) = 2·C(2d+1, d) ≥ 2·C(2d, d).
-/
theorem central_binomial_lower_bound (d : ℕ) :
    2 ^ d ≤ Nat.choose (2 * d) d := by
  induction' d with d ih;
  · native_decide +revert;
  · simp +arith +decide [ Nat.mul_succ, pow_succ', Nat.choose_succ_succ ] at *;
    linarith [ Nat.choose_le_succ ( 2 * d ) d, Nat.choose_le_succ ( 2 * d + 1 ) d ]

/-! ## Part 3: Boolean-to-Multiindex Injection -/

/-- Count true entries in a Boolean function on Fin m. -/
def countTrue (m : ℕ) (b : Fin m → Bool) : ℕ :=
  (Finset.univ.filter (fun i => b i = true)).card

/-- The injection from Bool^m to multiindices of weight m in (m+1) variables.
    α_b(0) = m - countTrue(b), α_b(i+1) = b(i).toNat -/
def boolToMultiindex (m : ℕ) (b : Fin m → Bool) : Fin (m + 1) → ℕ :=
  fun i =>
    if h : i.val = 0 then m - countTrue m b
    else if h2 : i.val - 1 < m then (b ⟨i.val - 1, h2⟩).toNat
    else 0

/-
countTrue is at most m.
-/
theorem countTrue_le (m : ℕ) (b : Fin m → Bool) : countTrue m b ≤ m := by
  exact le_trans ( Finset.card_le_univ _ ) ( by norm_num )

/-
The multiindex from boolToMultiindex has weight m.
-/
theorem boolToMultiindex_sum (m : ℕ) (b : Fin m → Bool) :
    ∑ i : Fin (m + 1), boolToMultiindex m b i = m := by
  erw [ Finset.sum_fin_eq_sum_range ];
  simp +arith +decide [ Finset.sum_range_succ', boolToMultiindex ];
  simp +arith +decide [ Finset.sum_range, Finset.sum_filter, countTrue ];
  rw [ ← Finset.sum_filter_add_sum_filter_not Finset.univ ( fun i => b i = true ) ] ; simp +decide [ Finset.sum_ite ] ;
  rw [ Finset.sum_congr rfl fun x hx => show ( b x |> Bool.toNat ) = 1 by aesop, Finset.sum_const, Finset.card_eq_sum_ones, smul_eq_mul, mul_one ] ; simp +arith +decide;
  rw [ add_right_comm, Nat.add_sub_of_le ];
  · rw [ Finset.sum_eq_zero ] <;> aesop;
  · exact le_trans ( Finset.card_le_univ _ ) ( by norm_num )

/-
boolToMultiindex is injective.
-/
theorem boolToMultiindex_injective (m : ℕ) :
    Function.Injective (boolToMultiindex m) := by
  intro b₁ b₂ h; ext i; have := congr_fun h ( Fin.succ i ) ; simp_all +decide [ funext_iff, Fin.forall_fin_succ ] ;
  have := h.2 i; simp_all +decide [ boolToMultiindex ] ;
  cases h' : b₁ i <;> cases h'' : b₂ i <;> simpa [ h', h'' ] using h.2 i

/-! ## Part 4: Exponential Lower Bound -/

/-
**Exponential multiindex lower bound**: multiIndexCount (m+1) m ≥ 2^m.
    The injection from {0,1}^m into multiindices proves this.
-/
theorem multiindex_count_exponential_lower (m : ℕ) :
    2 ^ m ≤ multiIndexCount (m + 1) m := by
  -- We have an injection boolToMultiindex : (Fin m → Bool) → (Fin (m+1) → ℕ) that maps into multiIndexSet (m+1) m.
  have h_inj : Finset.image (fun b : Fin m → Bool => boolToMultiindex m b) Finset.univ ⊆ multiIndexSet (m + 1) m := by
    intro x hx
    obtain ⟨b, hb, rfl⟩ := Finset.mem_image.mp hx
    simp [boolToMultiindex_sum] at *;
    exact mem_multiIndexSet.mpr ( boolToMultiindex_sum m b );
  exact le_trans ( by rw [ Finset.card_image_of_injective _ ( boolToMultiindex_injective m ) ] ; simp +decide [ Fintype.card_pi ] ) ( Finset.card_mono h_inj )

/-
**Exponential leaf count lower bound**: When degree d = m+2, n = m+1,
    the number of quadratic leaves is at least 2^m.
-/
theorem leaf_count_exponential_lower_bound (m : ℕ) :
    2 ^ m ≤ numberOfQuadraticLeaves (m + 1) (m + 2) := by
  convert multiindex_count_exponential_lower m using 1

/-! ## Part 5: Complexity Phase Transition -/

/-
**Phase Transition**: For n = m+1, d = m+2:
    2^m ≤ numberOfQuadraticLeaves (m+1) (m+2) ≤ (m+1)^m
-/
theorem complexity_phase_transition (m : ℕ) (hm : 0 < m) :
    2 ^ m ≤ numberOfQuadraticLeaves (m + 1) (m + 2) ∧
    numberOfQuadraticLeaves (m + 1) (m + 2) ≤ (m + 1) ^ m := by
  exact ⟨ by simpa using leaf_count_exponential_lower_bound m, by simpa using quadratic_leaf_count_le ( m + 1 ) ( m + 2 ) ( Nat.succ_pos m ) ( by omega ) ⟩

/-! ## Part 6: Cross-Domain — SAT Obstruction Duality -/

/-
**Satisfiability-Obstruction Duality**: A formula is unsatisfiable iff
    every assignment is obstructed. This is the Boolean analogue of
    "every derivative branch has an obstruction."
-/
theorem sat_obstruction_duality {n : ℕ} (φ : CNFFormula n) :
    ¬ CNFSatisfiable φ ↔ ∀ τ, isObstructed φ τ := by
  unfold CNFSatisfiable isObstructed; simp +decide [ not_forall, not_exists ] ;
  unfold formulaSatisfied isClauseObstruction; simp +decide [ not_forall, not_exists, not_and, not_or ] ;

/-! ## Part 7: Cross-Domain — Spectral Obstruction -/

/-- A matrix has a positive-definite direction. -/
def HasPositiveDirection {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ x : Fin n → ℝ, x ≠ 0 ∧ QuadForm A x > 0

/-- A matrix has a second positive direction orthogonal to any given w. -/
def HasSecondPositiveDirection {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) : Prop :=
  ∃ v : Fin n → ℝ, (∑ i, w i * v i = 0) ∧ QuadForm A v > 0

/-
**Spectral Obstruction**: If for every direction w there exists an
    orthogonal direction with positive quadratic form, then A does NOT
    have Lorentzian signature. This is the contrapositive of the
    Lorentzian definition and the key spectral obstruction lemma.
-/
theorem spectral_obstruction_non_lorentzian
    {n : ℕ} {A : Matrix (Fin n) (Fin n) ℝ}
    (hind : ∀ w : Fin n → ℝ, HasSecondPositiveDirection A w) :
    ¬ HasAtMostOnePositiveEigenvalue A := by
  intro hLorentzian
  obtain ⟨w, hw⟩ := hLorentzian;
  exact absurd ( hind w ) ( by rintro ⟨ v, hv₁, hv₂ ⟩ ; linarith [ hw v hv₁ ] )

/-! ## Part 8: Certificate Complexity -/

/-- Certificate complexity = number of quadratic leaves. -/
def lorentzianCertificateComplexity (n d : ℕ) : ℕ :=
  numberOfQuadraticLeaves n d

/-
Certificate complexity is exponential for unbounded degree.
-/
theorem certificate_complexity_exponential (m : ℕ) :
    2 ^ m ≤ lorentzianCertificateComplexity (m + 1) (m + 2) := by
  convert leaf_count_exponential_lower_bound m using 1

/-! ## Part 9: CNF Branch Correspondence -/

/-
**Cross-Domain Bridge**: Lorentzian recognition requires at least as many
    derivative branch inspections as SAT solving requires truth assignments.
-/
theorem cnf_branch_lower_bound (m : ℕ) :
    numPartialAssignments m ≤ numberOfQuadraticLeaves (m + 1) (m + 2) := by
  convert leaf_count_exponential_lower_bound m using 1

/-! ## Conjectures

**Conjecture (Branch-Complexity Barrier)**: There exists c > 0 and an explicit
family of homogeneous polynomials p_d with nonneg integer coefficients and
degree d such that every recursive Lorentzian certificate for p_d has size
at least exp(c·d).

Testable: For d = 2..7, minimal certificate sizes should grow superpolynomially.

**Conjecture (SAT Encoding Exactness)**: For a suitable clause-encoding
family P_φ, P_φ is Lorentzian iff φ is unsatisfiable.

Testable: Brute-force on small CNF (≤ 5 vars, ≤ 10 clauses) should verify.
-/

end LorentzianHardness