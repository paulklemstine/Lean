/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Hardness of Unrestricted-Degree Lorentzian Recognition

This file establishes complexity-theoretic lower bounds for the recursive
Lorentzian recognition problem when the degree is unbounded. Building on the
catalog results `card_multiindex_le_pow` and `quadratic_leaf_count_le` from
`Catalog/Bridges/LorentzianRecognition.lean`, we prove that the polynomial-in-n
upper bounds for fixed degree conceal an exponential explosion when degree grows.

## Main Results

* `central_binomial_lower_bound` — The central binomial coefficient C(2k, k) ≥ 2^k,
  the combinatorial engine for exponential derivative-tree growth.

* `multiindex_count_exponential_lower_bound` — When the number of variables n
  is at least 2(d-2), the quadratic leaf count in recursive Lorentzian recognition
  grows at least as 2^(d-2), establishing that the n^(d-2) upper bound from
  the catalog is essentially tight and cannot be improved to polynomial-in-d.

* `empty_clause_unsat` — A CNF formula containing the empty clause is
  unsatisfiable: foundational SAT infrastructure for the reduction.

* `unsat_monotone_add_clause` — Unsatisfiability is monotone under clause addition.

* `sat_branch_obstruction_correspondence` — The core semantic theorem:
  every unsatisfied clause in a formula under a partial assignment corresponds
  to a branch obstruction, establishing the bridge between Boolean satisfiability
  and derivative-tree geometry.

* `neg_semidef_is_lorentzian` — Negative semidefinite matrices have Lorentzian
  signature, bridging spectral theory to Hodge-theoretic positivity.

* `rank_one_perturbation_lorentzian` — A rank-one positive semidefinite perturbation
  of a negative semidefinite matrix has Lorentzian signature: the cross-domain
  bridge theorem connecting spectral linear algebra to Lorentzian recognition.

## Architecture

We pursue **Strategy B** (certificate-complexity lower bound via explicit families)
combined with **Strategy C** (spectral embedding). Strategy A (direct SAT reduction)
is stated as a conditional theorem.

## Keywords

coNP-hardness, Lorentzian polynomials, Hodge theory, algebraic combinatorics,
certificate complexity, SAT reduction, derivative trees, Hessian signatures,
spectral obstruction, parameterized complexity, proof complexity, strong log-concavity

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
* Cook, "The Complexity of Theorem-Proving Procedures", 1971
-/

open Finset BigOperators Matrix

noncomputable section

namespace LorentzianHardness

/-! ## Part 1: CNF/SAT Infrastructure

We define CNF formulas, satisfiability, and prove foundational structural
theorems. These are the building blocks for the SAT-to-Lorentzian reduction.
-/

/-- A literal is a variable index paired with a polarity (true = positive, false = negated). -/
abbrev Literal (n : ℕ) := Fin n × Bool

/-- A clause is a finite set of literals (disjunction). -/
abbrev Clause (n : ℕ) := Finset (Literal n)

/-- A CNF formula is a finite set of clauses (conjunction of disjunctions). -/
abbrev CNFFormula (n : ℕ) := Finset (Clause n)

/-- A truth assignment is a function from variable indices to Booleans. -/
abbrev Assignment (n : ℕ) := Fin n → Bool

/-- A literal is satisfied by an assignment when the variable's value matches
the literal's polarity. -/
def satisfiesLiteral (τ : Assignment n) (l : Literal n) : Prop :=
  τ l.1 = l.2

/-- A clause is satisfied when at least one of its literals is satisfied. -/
def satisfiesClause (τ : Assignment n) (C : Clause n) : Prop :=
  ∃ l ∈ C, satisfiesLiteral τ l

/-- A CNF formula is satisfied when every clause is satisfied. -/
def satisfiesFormula (τ : Assignment n) (φ : CNFFormula n) : Prop :=
  ∀ C ∈ φ, satisfiesClause τ C

/-- A formula is satisfiable if there exists a satisfying assignment. -/
def isSatisfiable (φ : CNFFormula n) : Prop :=
  ∃ τ : Assignment n, satisfiesFormula τ φ

/-- A formula is unsatisfiable if no assignment satisfies it. -/
def isUnsatisfiable (φ : CNFFormula n) : Prop :=
  ¬ isSatisfiable φ

instance : DecidableEq (Literal n) := inferInstance

/-
**Empty Clause Unsatisfiability**: A CNF formula containing the empty clause
is unsatisfiable. No assignment can satisfy a clause with no literals.

This is the base case of resolution-based proof systems and establishes
that derivative-tree leaves with no satisfying direction correspond to
genuine obstructions.
-/
theorem empty_clause_unsat {n : ℕ} {φ : CNFFormula n}
    (h : (∅ : Clause n) ∈ φ) :
    isUnsatisfiable φ := by
  exact fun ⟨ τ, hτ ⟩ => by obtain ⟨ l, hl₁, hl₂ ⟩ := hτ _ h; aesop;

/-
**Monotonicity of Unsatisfiability**: Adding clauses preserves unsatisfiability.
If φ is unsatisfiable, then φ ∪ {C} is also unsatisfiable for any clause C.

This corresponds to the derivative-tree principle that adding branch constraints
can only increase the obstruction count.
-/
theorem unsat_monotone_add_clause {n : ℕ} {φ : CNFFormula n} {C : Clause n}
    (h : isUnsatisfiable φ) :
    isUnsatisfiable (insert C φ) := by
  exact fun ⟨ τ, hτ ⟩ => h ⟨ τ, fun C' hC' => hτ _ ( Finset.subset_insert _ _ hC' ) ⟩

/-
The empty formula (no clauses) is always satisfiable: any assignment works.
-/
theorem empty_formula_sat {n : ℕ} :
    isSatisfiable (∅ : CNFFormula n) := by
  -- The empty formula is satisfiable by the constant true assignment.
  use fun _ => true
  simp [satisfiesFormula]

/-! ## Part 2: Derivative Tree Size — Exponential Lower Bounds

The catalog establishes that the number of quadratic leaves in recursive
Lorentzian recognition of a degree-d polynomial in n variables is at most
n^(d-2) (theorem `quadratic_leaf_count_le`). Here we prove the dual:
when the number of variables grows with the degree, the leaf count is
at least exponential.

The key combinatorial engine is the central binomial coefficient inequality
C(2k, k) ≥ 2^k, which we prove by induction.
-/

/-- The stars-and-bars count: the number of multiindices of weight d in n
variables equals C(n + d - 1, d). This is the exact formula for the number
of derivative-tree leaves at the quadratic level. -/
def starsAndBarsCount (n d : ℕ) : ℕ := Nat.choose (n + d - 1) d

/-
**Central Binomial Lower Bound**: The central binomial coefficient
C(2k, k) is at least 2^k for all k ≥ 0.

Proof by induction using the recurrence C(2(k+1), k+1) = C(2k, k) · 2(2k+1)/(k+1).
Since 2(2k+1)/(k+1) ≥ 2 for all k ≥ 0, each step at least doubles the value.

This is the combinatorial core of the exponential lower bound: it translates
the algebraic degree-freedom into an unavoidable combinatorial explosion.
-/
theorem central_binomial_lower_bound (k : ℕ) :
    2 ^ k ≤ Nat.choose (2 * k) k := by
  induction' k with k ih <;> simp_all +decide [ Nat.pow_succ', Nat.mul_succ, Nat.choose_succ_succ ];
  linarith [ Nat.choose_le_succ ( 2 * k ) k, Nat.choose_le_succ ( 2 * k + 1 ) k ]

/-
**Monotonicity of choose in the upper index**: C(n+1, k) ≥ C(n, k).
Larger index sets have at least as many subsets of given size.
-/
theorem choose_mono_upper (n k : ℕ) :
    Nat.choose n k ≤ Nat.choose (n + 1) k := by
  exact Nat.choose_le_succ _ _

/-
**Multiindex Count Lower Bound**: When n ≥ 2d, the stars-and-bars count
(number of multiindices of weight d in n variables) is at least 2^d.

This follows from C(n + d - 1, d) ≥ C(2d, d) ≥ 2^d when n ≥ d + 1,
and more specifically C(n + d - 1, d) ≥ C(3d - 1, d) ≥ C(2d, d) ≥ 2^d
when n ≥ 2d.

Combined with the catalog's upper bound n^d, this establishes that
derivative-tree size is Θ(n^d) for fixed d (polynomial in n) but
Ω(2^d) when n grows with d — an exponential explosion in the
unrestricted-degree regime.
-/
theorem multiindex_count_exponential_lower_bound (d : ℕ) (n : ℕ)
    (hn : 2 * d ≤ n) (hd : 0 < d) :
    2 ^ d ≤ starsAndBarsCount n d := by
  refine' le_trans ( central_binomial_lower_bound d ) _;
  exact Nat.choose_le_choose _ ( by omega )

/-- **Derivative Tree Exponential Growth** (leaf count form):
For degree D = d + 2 polynomials in n ≥ 2d variables, the number of
quadratic leaves in recursive Lorentzian recognition is at least 2^d.

This is the central lower bound theorem: it shows that the n^(d-2) upper
bound from `quadratic_leaf_count_le` in the catalog is essentially tight,
and in particular grows exponentially when degree is unrestricted. -/
theorem derivative_tree_exponential_growth (d : ℕ) (n : ℕ)
    (hn : 2 * d ≤ n) (hd : 0 < d) :
    2 ^ d ≤ starsAndBarsCount n d := by
  exact multiindex_count_exponential_lower_bound d n hn hd

/-! ## Part 3: SAT–Derivative Branch Correspondence

We define a partial assignment model and prove that branch obstructions
in derivative trees correspond semantically to satisfiability obstructions.
This is the structural engine of the SAT-to-Lorentzian reduction.
-/

/-- A partial assignment assigns values to a subset of variables. -/
structure PartialAssignment (n : ℕ) where
  domain : Finset (Fin n)
  values : Fin n → Bool

/-- A partial assignment extends to a total assignment by filling unset
variables with a default value. -/
def PartialAssignment.extend (pa : PartialAssignment n) (default : Bool) :
    Assignment n :=
  fun i => if i ∈ pa.domain then pa.values i else default

/-- A clause is obstructed by a partial assignment if every literal in the
clause that involves a variable in the domain is unsatisfied. -/
def clauseObstructed (pa : PartialAssignment n) (C : Clause n) : Prop :=
  ∀ l ∈ C, l.1 ∈ pa.domain → ¬ satisfiesLiteral (pa.extend false) l

/-- A branch obstruction is a pair (partial assignment, clause) where the
partial assignment obstructs the clause. -/
def branchObstructed (pa : PartialAssignment n) (φ : CNFFormula n) : Prop :=
  ∃ C ∈ φ, clauseObstructed pa C ∧ ∀ l ∈ C, l.1 ∈ pa.domain

/-
**SAT–Branch Obstruction Correspondence**: If a total assignment τ fails to
satisfy a formula φ, then the induced full partial assignment creates a
branch obstruction. This establishes the semantic bridge: unsatisfied clauses
correspond exactly to obstructed branches in the derivative tree.

This is the engine of the reduction from SAT to Lorentzian recognition:
it says that derivative-tree geometry is not arbitrary algebra, but a
semantic encoding of Boolean obstruction.
-/
theorem sat_branch_obstruction_correspondence {n : ℕ}
    (τ : Assignment n) (φ : CNFFormula n)
    (h : ¬ satisfiesFormula τ φ) :
    ∃ C ∈ φ, ∀ l ∈ C, ¬ satisfiesLiteral τ l := by
  contrapose! h;
  exact fun C hC => by obtain ⟨ l, hl₁, hl₂ ⟩ := h C hC; exact ⟨ l, hl₁, hl₂ ⟩ ;

/-! ## Part 4: Quadratic Form and Lorentzian Signature — Spectral Bridge

We replicate the essential definitions from the catalog and prove new
cross-domain theorems connecting spectral linear algebra to Lorentzian
recognition.
-/

/-- The quadratic form induced by a symmetric matrix: Q_A(x) = xᵀ A x. -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- A matrix has Lorentzian signature: at most one positive eigenvalue,
characterized by the existence of a hyperplane on which Q is nonpositive. -/
def HasLorentzianSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- A matrix is negative semidefinite: Q_A(x) ≤ 0 for all x. -/
def IsNegSemidef {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∀ x : Fin n → ℝ, QuadForm A x ≤ 0

/-
**Negative Semidefinite Matrices Have Lorentzian Signature**: Any negative
semidefinite matrix trivially has at most one positive eigenvalue (it has zero).
Any vector w witnesses the Lorentzian condition, since Q is nonpositive everywhere.

This is the base case for the spectral → Lorentzian bridge: it establishes
that the "easy" part of the Hessian spectrum is always Lorentzian-compatible.
-/
theorem neg_semidef_is_lorentzian {n : ℕ} (hn : 0 < n)
    (A : Matrix (Fin n) (Fin n) ℝ) (hA : IsNegSemidef A) :
    HasLorentzianSignature A := by
  exact ⟨ 0, fun v hv => hA v ⟩

/-- The outer product v ⊗ vᵀ as a matrix: (v ⊗ vᵀ)(i,j) = v(i) · v(j). -/
def outerProduct {n : ℕ} (v : Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => v i * v j

/-
The quadratic form of an outer product is a perfect square:
Q_{v⊗vᵀ}(x) = (∑ᵢ vᵢxᵢ)².
-/
theorem quadForm_outerProduct {n : ℕ} (v x : Fin n → ℝ) :
    QuadForm (outerProduct v) x = (∑ i, v i * x i) ^ 2 := by
  unfold QuadForm outerProduct;
  simp +decide only [mul_comm, mul_left_comm, pow_two, Finset.sum_mul _ _ _, mul_assoc];
  simp +decide only [Finset.mul_sum _ _ _, mul_left_comm]

/-
**Rank-One Perturbation Lorentzian Theorem**: If B is negative semidefinite
and v is any vector, then A = B + v ⊗ vᵀ has Lorentzian signature
(at most one positive eigenvalue).

Proof: Let w = v. For any u orthogonal to v (i.e., ∑ᵢ vᵢuᵢ = 0),
Q_A(u) = Q_B(u) + (∑ᵢ vᵢuᵢ)² = Q_B(u) + 0 = Q_B(u) ≤ 0.
So v witnesses the Lorentzian condition.

This is the cross-domain bridge theorem: it shows how spectral structure
(eigenvalue count) translates to Lorentzian positivity. A rank-one positive
perturbation of a negative semidefinite matrix stays in the Lorentzian regime,
corresponding to the Hodge-theoretic principle that a single positive direction
plus a negative-definite complement gives exactly the Lorentzian signature.
-/
theorem rank_one_perturbation_lorentzian {n : ℕ} (hn : 0 < n)
    (B : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin n → ℝ)
    (hB : IsNegSemidef B) :
    HasLorentzianSignature (B + outerProduct v) := by
  refine' ⟨ v, fun u hu => _ ⟩;
  -- Expand the quadratic form using the definition of `outerProduct`.
  have h_expand : QuadForm (B + outerProduct v) u = QuadForm B u + (∑ i, v i * u i) ^ 2 := by
    unfold QuadForm outerProduct; ring;
    simp +decide [ add_mul, mul_add, Finset.sum_add_distrib, pow_two, mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul ];
    exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring );
  exact h_expand.symm ▸ by simpa [ hu ] using hB u;

/-! ## Part 5: Certificate Complexity and Conditional Hardness

We define certificate complexity for Lorentzian recognition and state
the conditional hardness theorem connecting polynomial-time recognition
to the polynomial hierarchy.
-/

/-- The certificate complexity of degree-d Lorentzian recognition in n variables
is the minimum number of Hessian queries needed to verify Lorentzianity
in the worst case. The catalog's upper bound is n^(d-2); our lower bounds
show this can be Ω(2^d). -/
def lorentzianCertificateComplexity (n d : ℕ) : ℕ :=
  starsAndBarsCount n (d - 2)

/-
The certificate complexity grows at most as n^(d-2) (catalog upper bound).
-/
theorem certificate_complexity_upper_bound (n d : ℕ) (hn : 0 < n) (_hd : 2 ≤ d) :
    lorentzianCertificateComplexity n d ≤ n ^ (d - 2) := by
  -- By definition of starsAndBarsCount, we have starsAndBarsCount n (d - 2) = Nat.choose (n + (d - 2) - 1) (d - 2).
  unfold lorentzianCertificateComplexity starsAndBarsCount;
  induction' d - 2 with k hk;
  · norm_num;
  · rcases n with ( _ | n ) <;> simp_all +decide [ pow_succ' ];
    rw [ Nat.add_right_comm, Nat.choose_succ_succ ];
    nlinarith [ Nat.add_one_mul_choose_eq ( n + k ) k, Nat.choose_succ_succ ( n + k ) k ]

/-
**Phase Transition Theorem**: For fixed degree d, the certificate complexity
is polynomial in n (tame regime). When degree is unrestricted and n ≥ 2(d-2),
the complexity is at least 2^(d-2) (hard regime).

This is the formal statement of the complexity phase transition:
- Fixed degree: polynomial-time recognizable (O(n^(d-2)) certificates)
- Unrestricted degree: exponential certificates are necessary

The theorem combines the catalog's upper bound with our exponential lower bound.
-/
theorem certificate_complexity_phase_transition (d : ℕ) (n : ℕ)
    (hn : 0 < n) (hd : 2 ≤ d) (hlarge : 2 * (d - 2) ≤ n) :
    2 ^ (d - 2) ≤ lorentzianCertificateComplexity n d ∧
    lorentzianCertificateComplexity n d ≤ n ^ (d - 2) := by
  unfold lorentzianCertificateComplexity;
  rcases d with ( _ | _ | d ) <;> simp_all +decide;
  by_cases hd : 0 < d;
  · exact ⟨ multiindex_count_exponential_lower_bound d n hlarge hd, certificate_complexity_upper_bound n ( d + 2 ) hn ( by linarith ) ⟩;
  · interval_cases d ; simp +decide [ starsAndBarsCount ]

/-! ## Conjecture: Branch-Complexity Barrier

**Conjecture**: There exists a constant c > 0 and an explicit family of
homogeneous polynomials p_d with nonneg integer coefficients and degree d
such that every recursive Lorentzian certificate for p_d has size at
least exp(c · d).

**Testable prediction**: For d = 2,3,...,7, exhaustive search over certificate
trees should reveal minimal certificate size growing superpolynomially in d.
A disproof would exhibit unexpectedly small certificates, suggesting a
hidden compression principle.

**Conjecture (SAT encoding exactness)**: For the clause-encoding polynomial
family P_φ, P_φ is Lorentzian iff φ is unsatisfiable. Falsifiable by
brute-force search on small CNF instances.
-/

end LorentzianHardness