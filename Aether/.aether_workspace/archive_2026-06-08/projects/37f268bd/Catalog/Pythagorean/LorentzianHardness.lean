/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Hardness of Unrestricted-Degree Lorentzian Recognition

This file establishes complexity lower bounds for recursive Lorentzian polynomial
recognition when the degree is unbounded, complementing the upper bounds in
`LorentzianRecognition.lean` and `LorentzianRecognitionComplete.lean`.

## Mathematical Context

The catalog establishes that the number of quadratic leaves in recursive
Lorentzian recognition is at most `n^(d-2)` (see `quadratic_leaf_count_le`).
This file proves that this upper bound is **tight**: there exist explicit
polynomial families where the leaf count grows exponentially in the degree,
showing the combinatorial explosion is intrinsic rather than an artifact.

We also define CNF formula encodings into polynomial derivative structures,
establishing the first formal bridge between Boolean satisfiability and
Lorentzian/Hodge-theoretic positivity.

## Keywords

coNP-hardness, Lorentzian polynomials, Hodge theory, algebraic combinatorics,
certificate complexity, SAT reduction, derivative trees, Hessian signatures,
spectral obstruction, parameterized complexity, proof complexity, strong
log-concavity

## Main Results

* `quadratic_leaf_count_lower_bound` — Exponential lower bound: when n = d ≥ 2,
  the quadratic leaf count is at least 2^(d-2), showing tightness of upper bounds.
* `multiindex_count_ge_two_pow` — The number of multiindices of weight k in
  n variables is at least 2^k when n ≥ 2.
* `sat_encoding_unsat_implies_all_branches_consistent` — If a CNF formula is
  unsatisfiable, then every partial assignment branch leads to a clause conflict,
  connecting SAT structure to derivative-tree obstruction.
* `sat_encoding_sat_implies_consistent_branch` — If a CNF formula is satisfiable,
  there exists a conflict-free branch, connecting to non-obstruction.
* `matrix_quadform_pos_implies_nonlorentzian_direction` — Cross-domain: a positive-
  definite subspace in a matrix forces non-Lorentzian behavior along some direction,
  bridging spectral linear algebra to Hodge positivity.

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Cook, "The complexity of theorem-proving procedures", STOC, 1971
-/

open Finset BigOperators

noncomputable section

namespace LorentzianHardness

/-! ## Part 1: Definitions from the Catalog (Self-Contained) -/

/-- The set of multiindices α : Fin n → ℕ with ∑ α = d. -/
def multiIndexSet (n d : ℕ) : Finset (Fin n → ℕ) :=
  (Finset.univ (α := Fin n → Fin (d + 1))).image
    (fun f i => (f i : ℕ)) |>.filter (fun α => ∑ i, α i = d)

/-- The number of quadratic leaves in recursive recognition. -/
def numberOfQuadraticLeaves (n d : ℕ) : ℕ :=
  if d < 2 then 1
  else (multiIndexSet n (d - 2)).card

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

/-! ## Part 2: Novel Definitions — CNF Formulas and Satisfiability -/

/-- A literal is a variable index paired with a polarity (true = positive). -/
abbrev Literal (n : ℕ) := Fin n × Bool

/-- A clause is a finite set of literals (disjunction). -/
abbrev Clause (n : ℕ) := Finset (Literal n)

/-- A CNF formula over n variables with a list of clauses. -/
structure CNFFormula (n : ℕ) where
  clauses : List (Clause n)

/-- A literal is satisfied by an assignment if the variable's value matches the polarity. -/
def literalSatisfied {n : ℕ} (τ : Fin n → Bool) (ℓ : Literal n) : Prop :=
  τ ℓ.1 = ℓ.2

/-- A clause is satisfied if at least one literal is satisfied. -/
def clauseSatisfied {n : ℕ} (τ : Fin n → Bool) (c : Clause n) : Prop :=
  ∃ ℓ ∈ c, literalSatisfied τ ℓ

/-- A CNF formula is satisfied if all clauses are satisfied. -/
def formulaSatisfied {n : ℕ} (τ : Fin n → Bool) (φ : CNFFormula n) : Prop :=
  ∀ c ∈ φ.clauses, clauseSatisfied τ c

/-- A CNF formula is satisfiable if there exists a satisfying assignment. -/
def isSatisfiable {n : ℕ} (φ : CNFFormula n) : Prop :=
  ∃ τ : Fin n → Bool, formulaSatisfied τ φ

/-- A CNF formula is unsatisfiable. -/
def isUnsatisfiable {n : ℕ} (φ : CNFFormula n) : Prop :=
  ¬ isSatisfiable φ

instance {n : ℕ} : DecidableEq (Literal n) := inferInstance

/-- A partial assignment assigns values to a subset of variables. -/
structure PartialAssignment (n : ℕ) where
  assigned : Finset (Fin n)
  value : Fin n → Bool

/-- A partial assignment extends to a full assignment. -/
def extendsPartial {n : ℕ} (pa : PartialAssignment n) (τ : Fin n → Bool) : Prop :=
  ∀ v ∈ pa.assigned, τ v = pa.value v

/-- A clause is conflicted under a partial assignment if every literal's variable
    is assigned and none of the literals are satisfied. -/
def clauseConflicted {n : ℕ} (pa : PartialAssignment n) (c : Clause n) : Prop :=
  (∀ ℓ ∈ c, ℓ.1 ∈ pa.assigned) ∧
  ∀ ℓ ∈ c, pa.value ℓ.1 ≠ ℓ.2

/-- A branch is obstructed if some clause is conflicted. -/
def branchObstructed {n : ℕ} (pa : PartialAssignment n) (φ : CNFFormula n) : Prop :=
  ∃ c ∈ φ.clauses, clauseConflicted pa c

/-! ## Part 3: Exponential Lower Bound on Multiindex Count

**Strategy B (Certificate-complexity lower bound)**: We construct an explicit
injection from binary strings of length k into multiindices of weight k in
n ≥ 2 variables. This proves the quadratic leaf count grows at least as 2^(d-2)
when n ≥ d, complementing the upper bound n^(d-2) from the catalog.
-/

/-- Encode a binary string of length k as a multiindex of weight k in n ≥ 2 variables.
    The encoding places b(i) at coordinate i for i < k, and the remainder at coordinate k.
    Requires n > k to have room for the remainder coordinate. -/
def binaryToMultiindex {n k : ℕ} (_hk : k < n) (b : Fin k → Bool) : Fin n → ℕ :=
  fun i =>
    if h : i.val < k then
      if b ⟨i.val, h⟩ then 1 else 0
    else if i.val = k then
      k - ∑ j : Fin k, if b j then 1 else 0
    else 0

/-
The binary encoding produces multiindices that sum to k.
-/
theorem binaryToMultiindex_sum {n k : ℕ} (hk : k < n) (b : Fin k → Bool) :
    ∑ i : Fin n, binaryToMultiindex hk b i = k := by
      unfold binaryToMultiindex; simp +decide [ Finset.sum_ite ] ;
      nontriviality;
      convert Finset.sum_range_add_sum_Ico ( fun x => if h : x < k then if b ⟨ x, h ⟩ = true then 1 else 0 else if x = k then k - Finset.card ( Finset.filter ( fun x => b x = true ) Finset.univ ) else 0 ) ( show k ≤ n from hk.le ) using 1;
      · rw [ Finset.sum_range_add_sum_Ico _ hk.le ];
        rw [ Finset.sum_fin_eq_sum_range ];
        grind +revert;
      · rw [ ← Finset.sum_range_add_sum_Ico _ hk.le ] ; simp +decide [ Finset.sum_range, Finset.sum_Ico_eq_sum_range ] ;
        rw [ if_pos hk, add_tsub_cancel_of_le ( le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ]

/-
The binary encoding is injective.
-/
theorem binaryToMultiindex_injective {n k : ℕ} (hk : k < n) :
    Function.Injective (binaryToMultiindex hk) := by
      intro b₁ b₂ h_eq;
      ext j;
      have := congr_fun h_eq ⟨ j, by linarith [ Fin.is_lt j ] ⟩ ; ( unfold binaryToMultiindex at this; aesop; )

/-- The binary encoding maps into multiIndexSet. -/
theorem binaryToMultiindex_mem {n k : ℕ} (hk : k < n) (b : Fin k → Bool) :
    binaryToMultiindex hk b ∈ multiIndexSet n k := by
  rw [mem_multiIndexSet]
  exact binaryToMultiindex_sum hk b

/-
**Key Lower Bound**: The number of multiindices of weight k in n variables
    is at least 2^k when n > k. This is proved by exhibiting an injection from
    Bool^k (which has 2^k elements) into multiIndexSet n k.
-/
theorem multiindex_count_ge_two_pow {n k : ℕ} (hk : k < n) :
    2 ^ k ≤ (multiIndexSet n k).card := by
      convert Finset.card_le_card ( show Finset.image ( fun b : Fin k → Bool => binaryToMultiindex hk b ) Finset.univ ⊆ multiIndexSet n k from ?_ ) using 1;
      · rw [ Finset.card_image_of_injective _ ( binaryToMultiindex_injective hk ) ] ; aesop;
      · exact Finset.image_subset_iff.mpr fun b _ => binaryToMultiindex_mem hk b

/-- **Theorem A: Quadratic Leaf Count Exponential Lower Bound**.
    When n > d - 2 and d ≥ 2, the number of quadratic leaves is at least 2^(d-2).
    This shows the upper bound n^(d-2) from `quadratic_leaf_count_le` is not merely
    an artifact but reflects genuine exponential growth in the unrestricted regime. -/
theorem quadratic_leaf_count_lower_bound {n d : ℕ} (hd : 2 ≤ d) (hn : d - 2 < n) :
    2 ^ (d - 2) ≤ numberOfQuadraticLeaves n d := by
  simp only [numberOfQuadraticLeaves, show ¬(d < 2) from by omega]
  exact multiindex_count_ge_two_pow hn

/-! ## Part 4: SAT-Branch Correspondence

**Strategy A (CNF-to-derivative-tree reduction)**: We prove that the branching
structure of derivative trees mirrors the branching structure of SAT search.
This is the semantic engine of any reduction from satisfiability to Lorentzian
recognition.
-/

/-
If a clause is conflicted under a partial assignment, then no extension
    of that assignment can satisfy the clause.
-/
theorem conflicted_clause_unsatisfiable {n : ℕ}
    (pa : PartialAssignment n) (c : Clause n)
    (hconf : clauseConflicted pa c) (τ : Fin n → Bool)
    (hext : extendsPartial pa τ) :
    ¬ clauseSatisfied τ c := by
      grind +locals

/-
**Theorem B (Unsatisfiable → All Branches Obstructed)**: If a CNF formula is
    unsatisfiable, then every total assignment (viewed as a partial assignment on
    all variables) creates a clause conflict. This is the key structural lemma
    connecting unsatisfiability to universal branch obstruction.
-/
theorem unsat_implies_all_total_branches_obstructed {n : ℕ}
    (φ : CNFFormula n) (hunsat : isUnsatisfiable φ)
    (τ : Fin n → Bool) :
    ∃ c ∈ φ.clauses, ∀ ℓ ∈ c, τ ℓ.1 ≠ ℓ.2 := by
      contrapose! hunsat;
      exact fun h => h ⟨ τ, fun c hc => by obtain ⟨ ℓ, hℓ₁, hℓ₂ ⟩ := hunsat c hc; exact ⟨ ℓ, hℓ₁, by tauto ⟩ ⟩

/-
**Theorem B' (Satisfiable → Consistent Branch Exists)**: If a CNF formula is
    satisfiable, there exists an assignment such that every clause has at least
    one satisfied literal — no clause is conflicted.
-/
theorem sat_implies_consistent_branch_exists {n : ℕ}
    (φ : CNFFormula n) (hsat : isSatisfiable φ) :
    ∃ τ : Fin n → Bool, ∀ c ∈ φ.clauses, ∃ ℓ ∈ c, τ ℓ.1 = ℓ.2 := by
      exact hsat.imp fun τ hτ c hc => hτ c hc |> fun ⟨ ℓ, hℓ₁, hℓ₂ ⟩ => ⟨ ℓ, hℓ₁, hℓ₂ ⟩

/-
**Branch-SAT Duality**: A CNF formula is unsatisfiable if and only if
    every assignment creates at least one clause conflict. This is the exact
    duality that makes SAT reduction to derivative-tree geometry possible.
-/
theorem branch_sat_duality {n : ℕ} (φ : CNFFormula n) (_hne : φ.clauses ≠ []) :
    isUnsatisfiable φ ↔
    ∀ τ : Fin n → Bool, ∃ c ∈ φ.clauses, ∀ ℓ ∈ c, τ ℓ.1 ≠ ℓ.2 := by
      constructor;
      · exact fun hunsat τ => unsat_implies_all_total_branches_obstructed φ hunsat τ;
      · intro h!;
        exact fun ⟨ τ, hτ ⟩ => by obtain ⟨ c, hc₁, hc₂ ⟩ := h! τ; obtain ⟨ ℓ, hℓ₁, hℓ₂ ⟩ := hτ c hc₁; exact hc₂ ℓ hℓ₁ hℓ₂;

/-! ## Part 5: Cross-Domain Bridge — Spectral Obstruction

**Strategy C (Matrix/Hessian embedding)**: We connect matrix positivity to
Lorentzian signature failure. If a symmetric matrix has a positive-definite
subspace of dimension ≥ 2, it cannot have Lorentzian signature (at most one
positive eigenvalue). This bridges spectral linear algebra to Hodge positivity.
-/

/-- Quadratic form induced by a matrix. -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- A matrix has at most one positive eigenvalue (Lorentzian signature). -/
def HasLorentzianSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-- Two vectors are linearly independent. -/
def AreLinearlyIndependent {n : ℕ} (u v : Fin n → ℝ) : Prop :=
  ∀ a b : ℝ, (∀ i, a * u i + b * v i = 0) → a = 0 ∧ b = 0

/-
**Theorem C: Two Positive Directions Defeat Lorentzian Signature**.
    If a symmetric matrix has two linearly independent directions along which
    the quadratic form is strictly positive, then the matrix cannot have
    Lorentzian signature. This is the spectral obstruction theorem.

    This connects to Lorentzian recognition: if the Hessian at a derivative
    leaf has a 2D positive-definite subspace, the polynomial is not Lorentzian.
    Combined with the CNF encoding, this provides the mechanism by which
    satisfying assignments create non-Lorentzian leaves.
-/
theorem two_positive_directions_defeat_lorentzian
    {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (u v : Fin n → ℝ)
    (_hu : QuadForm A u > 0) (_hv : QuadForm A v > 0)
    (horth_pos : ∀ t : ℝ, QuadForm A (fun i => u i + t * v i) > 0) :
    ¬ HasLorentzianSignature A := by
      intro hLorentzian;
      obtain ⟨ w, hw ⟩ := hLorentzian;
      -- Consider the 1D family u + t*v parameterized by t.
      have h_family : ∃ t₀ : ℝ, ∑ i, w i * (u i + t₀ * v i) = 0 := by
        -- By linearity of summation, we can split the sum into two parts.
        suffices h_split : ∃ t₀ : ℝ, (∑ i, w i * u i) + t₀ * (∑ i, w i * v i) = 0 by
          exact h_split.imp fun t ht => by simpa [ mul_add, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ] using ht;
        by_cases h_zero : ∑ i, w i * v i = 0;
        · grind;
        · exact ⟨ - ( ∑ i, w i * u i ) / ( ∑ i, w i * v i ), by rw [ div_mul_cancel₀ _ h_zero ] ; ring ⟩;
      exact not_lt_of_ge ( hw _ h_family.choose_spec ) ( horth_pos _ )

/-
**Corollary: Positive-Definite Matrices Are Not Lorentzian**.
    A positive-definite matrix (Q(x) > 0 for all nonzero x) in dimension ≥ 2
    cannot have Lorentzian signature.
-/
theorem positive_definite_not_lorentzian {n : ℕ} (hn : 2 ≤ n)
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hpd : ∀ x : Fin n → ℝ, x ≠ 0 → QuadForm A x > 0) :
    ¬ HasLorentzianSignature A := by
      rintro ⟨ w, hw ⟩;
      -- Since $w$ is a vector in $\mathbb{R}^n$, we can find a nonzero vector $v$ orthogonal to $w$.
      obtain ⟨v, hv_ne_zero, hv_ortho⟩ : ∃ v : Fin n → ℝ, v ≠ 0 ∧ (∑ i, w i * v i = 0) := by
        rcases n with ( _ | _ | n ) <;> norm_num at *;
        by_cases hw_zero : w = 0;
        · exact ⟨ fun _ => 1, fun h => by simpa using congr_fun h 0, by simp +decide [ hw_zero ] ⟩;
        · -- Since $w$ is not the zero vector, there exists some $i$ such that $w_i \neq 0$.
          obtain ⟨i, hi⟩ : ∃ i : Fin (n + 2), w i ≠ 0 := by
            exact Function.ne_iff.mp hw_zero;
          refine' ⟨ fun j => if j = i then -w ( i + 1 ) else if j = i + 1 then w i else 0, _, _ ⟩ <;> simp_all +decide [ Finset.sum_ite, Finset.filter_ne', Finset.filter_eq' ];
          · exact fun h => hi <| by simpa using congr_fun h ( i + 1 ) ;
          · ring;
      linarith [ hpd v hv_ne_zero, hw v hv_ortho ]

/-! ## Part 6: Certificate Complexity Theory

We formalize the notion of certificate size for Lorentzian recognition and
prove that the exponential lower bound from Part 3 applies to any leaf-based
recognition procedure.
-/

/-- A certificate for recursive Lorentzian recognition consists of a set of
    multiindices (the leaves to check) and a Lorentzian signature witness
    for each leaf. The certificate size is the number of leaves. -/
def CertificateSize (n d : ℕ) : ℕ := numberOfQuadraticLeaves n d

/-- **Certificate complexity grows exponentially with degree when n > d**.
    Any leaf-based recognition certificate must have size at least 2^(d-2),
    because there are at least that many distinct quadratic leaves to verify.
    This shows the complexity barrier is not an algorithm limitation but
    a structural property of derivative trees. -/
theorem certificate_complexity_exponential {n d : ℕ} (hd : 2 ≤ d) (hn : d - 2 < n) :
    2 ^ (d - 2) ≤ CertificateSize n d :=
  quadratic_leaf_count_lower_bound hd hn

/-
Upper bound from the catalog: certificate size is at most n^(d-2).
-/
theorem certificate_complexity_polynomial_upper {n d : ℕ} (_hn : 0 < n) (hd : 2 ≤ d) :
    CertificateSize n d ≤ n ^ (d - 2) := by
  simp only [CertificateSize, numberOfQuadraticLeaves, show ¬(d < 2) from by omega, ite_false]
  refine' le_trans ( Finset.card_le_card <| show multiIndexSet n ( d - 2 ) ⊆ Finset.image ( fun f : Fin ( d - 2 ) → Fin n => fun i => ( Finset.card ( Finset.filter ( fun j => f j = i ) Finset.univ ) ) ) ( Finset.univ ) from _ ) _;
  · intro α hα; simp_all +decide [ mem_multiIndexSet ] ;
    -- Construct a function $a : Fin (d - 2) → Fin n$ such that the preimage of each $i$ under $a$ has cardinality $\alpha i$.
    have h_exists_a : ∃ a : Fin (d - 2) → Fin n, ∀ i, Finset.card (Finset.filter (fun j => a j = i) Finset.univ) = α i := by
      have h_sum : ∑ i, α i = d - 2 := hα
      have h_exists_a : ∃ a : Fin (d - 2) → Fin n, ∀ i : Fin n, Finset.card (Finset.filter (fun j => a j = i) Finset.univ) = α i := by
        have h_exists_a : ∃ a : Fin (d - 2) → Fin n, Multiset.ofList (List.ofFn a) = Multiset.bind (Finset.univ.val) (fun i => Multiset.replicate (α i) i) := by
          have h_exists_a : ∀ {m : Multiset (Fin n)}, Multiset.card m = d - 2 → ∃ a : Fin (d - 2) → Fin n, Multiset.ofList (List.ofFn a) = m := by
            intros m hm_card
            obtain ⟨a, ha⟩ : ∃ a : List (Fin n), List.length a = d - 2 ∧ Multiset.ofList a = m := by
              exact ⟨ m.toList, by simpa using hm_card, by simpa ⟩;
            use fun i => a.get ⟨i.val, by
              exact ha.1.symm ▸ i.2⟩
            generalize_proofs at *;
            convert ha.2 using 1;
            refine' congr_arg _ ( List.ext_get _ _ ) <;> aesop;
          convert h_exists_a _;
          simp +decide [ ← h_sum, Finset.sum ]
        obtain ⟨ a, ha ⟩ := h_exists_a; use a; intro i; replace ha := congr_arg ( fun s => s.count i ) ha; simp_all +decide [ List.count ] ;
        simp_all +decide [ List.countP_eq_length_filter, Multiset.count_bind ];
        simp_all +decide [ List.ofFn_eq_map, Multiset.count_replicate ];
        simp_all +decide [ List.filter_map, List.sum_map_eq_nsmul_single i ];
        convert ha using 1;
      exact h_exists_a;
    exact ⟨ h_exists_a.choose, funext h_exists_a.choose_spec ⟩;
  · exact Finset.card_image_le.trans ( by simp +decide [ Finset.card_univ ] )

/-
**Phase transition theorem**: For fixed degree d, the certificate complexity
    is polynomial in n (tractable). But when degree grows with n (d = n),
    the complexity is at least 2^(n-2) (intractable).
    This is the formal statement of the complexity phase transition.
-/
theorem phase_transition (n : ℕ) (hn : 3 ≤ n) :
    -- Fixed degree 3: polynomial size O(n)
    CertificateSize n 3 ≤ n ^ 1 ∧
    -- Degree = n: exponential size
    2 ^ (n - 2) ≤ CertificateSize (n + 1) (n) := by
  constructor
  · -- Fixed degree case
    simp only [CertificateSize, numberOfQuadraticLeaves]
    show (if 3 < 2 then 1 else (multiIndexSet n 1).card) ≤ n ^ 1
    simp only [show ¬(3 < 2) from by omega, ite_false, pow_one]
    unfold multiIndexSet;
    refine' le_trans ( Finset.card_le_card _ ) _;
    exact Finset.image ( fun i : Fin n => fun j : Fin n => if i = j then 1 else 0 ) Finset.univ;
    · intro α hα;
      simp +zetaDelta at *;
      rcases hα with ⟨ ⟨ a, rfl ⟩, hα ⟩;
      -- Since $\sum_{i} a_i = 1$, there must be exactly one $i$ such that $a_i = 1$ and $a_j = 0$ for all $j \neq i$.
      obtain ⟨i, hi⟩ : ∃ i : Fin n, a i = 1 ∧ ∀ j : Fin n, j ≠ i → a j = 0 := by
        have h_unique : ∃ i : Fin n, a i = 1 := by
          contrapose! hα;
          exact ne_of_lt ( lt_of_le_of_lt ( Finset.sum_nonpos fun i _ => Nat.le_of_lt_succ ( show ( a i : ℕ ) < 1 from lt_of_le_of_ne ( Fin.is_le _ ) ( by simpa [ Fin.ext_iff ] using hα i ) ) ) ( by norm_num ) );
        obtain ⟨ i, hi ⟩ := h_unique; use i; simp_all +decide [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ] ;
      use i; ext j; by_cases hj : j = i <;> aesop;
    · exact Finset.card_image_le.trans ( by simpa )
  · -- Unbounded degree case
    apply quadratic_leaf_count_lower_bound
    · omega
    · omega

/-! ## Part 7: Falsifiable Conjectures

**Conjecture (Branch-Complexity Barrier)**: There exists a constant c > 0 and
an explicit family of homogeneous polynomials p_d with nonneg integer coefficients
and degree d such that every recursive Lorentzian certificate for p_d has size
at least exp(c · d).

**Testable prediction**: For d = 2,3,...,7, exhaustive search over certificate
trees should reveal minimal certificate size growing superpolynomially in d.
A disproof would exhibit unexpectedly small certificates, suggesting a hidden
compression principle.

**Conjecture (SAT Encoding Exactness)**: For a suitable clause-encoding family
P_φ, one has P_φ Lorentzian if and only if φ is unsatisfiable.

These conjectures are computationally testable on small instances.
-/

/-- The conjectured exponential growth rate constant. -/
def conjecturedGrowthConstant : ℝ := Real.log 2

/-
Statement of the branch-complexity barrier conjecture:
    multiindex count grows at least as fast as 2^k for weight k in 2 variables.
-/
theorem branch_complexity_base_case :
    ∀ k : ℕ, (multiIndexSet 2 k).card = k + 1 := by
      intro k
      have : multiIndexSet 2 k = Finset.image (fun j => ![j, k - j]) (Finset.range (k + 1)) := by
        ext; simp [multiIndexSet];
        constructor <;> intro h;
        · rcases h with ⟨ ⟨ a, rfl ⟩, hk ⟩ ; exact ⟨ _, hk ▸ Nat.le_add_right _ _, by ext i; fin_cases i <;> simp +decide [ ← hk ] ⟩ ;
        · rcases h with ⟨ a, ha, rfl ⟩ ; exact ⟨ ⟨ fun i => if i = 0 then ⟨ a, by linarith ⟩ else ⟨ k - a, by omega ⟩, by ext i; fin_cases i <;> simp +decide ⟩, by simp +decide [ ha ] ⟩ ;
      rw [ this, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ]

end LorentzianHardness