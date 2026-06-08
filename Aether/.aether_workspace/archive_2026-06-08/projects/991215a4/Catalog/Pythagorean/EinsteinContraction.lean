import Mathlib

/-!
# Universal Einstein Contraction Calculus for Order-Indexed Tensors

## Overview

This file constructs a **universal order-graded tensor contraction calculus** extending
the three-sorted system in `TensorSortedRewrite.lean` to tensors of arbitrary order `n : ℕ`.
We prove that contraction is a bilinear graded composition law, establish associativity
of iterated contraction, derive the quadratic energy identity for order-2 tensors, and
prove soundness of a symbolic rewrite system for Einstein summation.

## Mathematical Framework

An **order-n tensor** over a semiring `R` with dimension `d` is a function
`(Fin n → Fin d) → R`, assigning a scalar to each multi-index. This captures:
- Order 0: scalars
- Order 1: vectors
- Order 2: matrices
- Order n: general n-tensors

**Contraction** of an order-(j+k) tensor `T` with an order-k tensor `v` produces
an order-j tensor by summing over shared indices:
  `contract(T, v)(i) = Σ_c T(i ++ c) · v(c)`

This is the mathematical operation underlying Einstein summation notation.

## Main Results

1. `contract_add_left` — Left distributivity of contraction over addition
2. `contract_add_right` — Right distributivity of contraction over addition
3. `contract_assoc` — Associativity of iterated contraction
4. `energy_expansion` — Quadratic energy identity for order-2 tensors
5. `einsteinRewrite_sound` — Soundness of the Einstein rewrite system

## Cross-Domain Significance

The bilinearity and associativity of contraction form the algebraic backbone of:
- **Differential geometry**: metric contraction, curvature tensor identities
- **Continuum mechanics**: stress-strain energy functionals
- **Tensor networks**: legal reassociation of contraction schedules
- **Machine learning**: einsum optimization in deep learning frameworks
-/

open Finset BigOperators

namespace EinsteinContraction

/-! ## Part 1: Semantic Layer — Order-Graded Tensors -/

/-- An order-`n` tensor over semiring `R` with dimension `d` is a function
from multi-indices `(Fin n → Fin d)` to `R`. This captures scalars (n=0),
vectors (n=1), matrices (n=2), and higher-order tensors uniformly. -/
def GradedTensor (R : Type*) (d : ℕ) (n : ℕ) := (Fin n → Fin d) → R

variable {R : Type*} [CommSemiring R] {d : ℕ}

noncomputable instance : Zero (GradedTensor R d n) := ⟨fun _ => 0⟩
noncomputable instance : Add (GradedTensor R d n) := ⟨fun A B idx => A idx + B idx⟩

instance : Inhabited (GradedTensor R d n) := ⟨fun _ => 0⟩

@[simp] theorem GradedTensor.zero_apply (idx : Fin n → Fin d) :
    (0 : GradedTensor R d n) idx = 0 := rfl

@[simp] theorem GradedTensor.add_apply (A B : GradedTensor R d n) (idx : Fin n → Fin d) :
    (A + B) idx = A idx + B idx := rfl

/-! ## Part 2: Core Operations -/

/-- **Contraction**: the universal composition law of graded tensors.
Given an order-(j+k) tensor `T` and an order-k tensor `v`, produces an
order-j tensor by summing over the last `k` indices of `T` against `v`.
This is the formal version of Einstein summation. -/
noncomputable def contract {j k : ℕ}
    (T : GradedTensor R d (j + k)) (v : GradedTensor R d k) : GradedTensor R d j :=
  fun idx => ∑ cidx : (Fin k → Fin d), T (Fin.append idx cidx) * v cidx

/-- **Tensor product**: combines an order-j tensor and an order-k tensor
into an order-(j+k) tensor by pointwise multiplication along split indices. -/
noncomputable def tensorProd {j k : ℕ}
    (A : GradedTensor R d j) (B : GradedTensor R d k) : GradedTensor R d (j + k) :=
  fun idx => A (fun i => idx (Fin.castAdd k i)) * B (fun i => idx (Fin.natAdd j i))

/-- **Scalar multiplication** of a tensor by a ring element. -/
noncomputable def smul (r : R) {n : ℕ} (T : GradedTensor R d n) : GradedTensor R d n :=
  fun idx => r * T idx

/-- **Reindexing** a tensor along a natural number equality.
Maps an order-n tensor to an order-m tensor when n = m, preserving values. -/
noncomputable def reindex {n m : ℕ} (h : n = m) (T : GradedTensor R d n) : GradedTensor R d m :=
  fun idx => T (fun i => idx (Fin.cast h i))

/-! ## Part 3: Bilinearity of Contraction (Theorems 1 & 2)

These two theorems establish that contraction is a bilinear operation:
it distributes over addition in both arguments. Together, they make
contraction a bilinear graded composition law — the algebraic heart
of tensor calculus, tensor networks, and multilinear numerical analysis. -/

/-
**Theorem 1: Universal Left Distributivity of Contraction.**
Contraction distributes over addition in the left (higher-order) argument.
This is the first universal schema behind Einstein summation rewrite rules:
`contract(A + B, v) = contract(A, v) + contract(B, v)`.
-/
theorem contract_add_left {j k : ℕ}
    (A B : GradedTensor R d (j + k)) (v : GradedTensor R d k) :
    contract (A + B) v = contract A v + contract B v := by
  funext idx
  simp [contract, add_mul];
  rw [ Finset.sum_add_distrib ]

/-
**Theorem 2: Universal Right Distributivity of Contraction.**
Contraction distributes over addition in the right (contracting) argument:
`contract(T, u + v) = contract(T, u) + contract(T, v)`.
-/
theorem contract_add_right {j k : ℕ}
    (T : GradedTensor R d (j + k)) (u v : GradedTensor R d k) :
    contract T (u + v) = contract T u + contract T v := by
  exact funext fun x => by simp +decide [ contract, Finset.sum_add_distrib, mul_add ] ;

/-
Contraction with zero on the right yields zero.
-/
theorem contract_zero_right {j k : ℕ}
    (T : GradedTensor R d (j + k)) :
    contract T (0 : GradedTensor R d k) = 0 := by
  unfold contract; aesop

/-
Contraction with zero on the left yields zero.
-/
theorem contract_zero_left {j k : ℕ}
    (v : GradedTensor R d k) :
    contract (0 : GradedTensor R d (j + k)) v = 0 := by
  unfold contract;
  simp +zetaDelta at *;
  rfl

/-
Scalar multiplication commutes with contraction (left).
-/
theorem contract_smul_left {j k : ℕ}
    (r : R) (T : GradedTensor R d (j + k)) (v : GradedTensor R d k) :
    contract (smul r T) v = smul r (contract T v) := by
  funext idx
  simp [contract, smul];
  simp +decide only [mul_assoc, Finset.mul_sum _ _ _]

/-
Scalar multiplication commutes with contraction (right).
-/
theorem contract_smul_right {j k : ℕ}
    (r : R) (T : GradedTensor R d (j + k)) (v : GradedTensor R d k) :
    contract T (smul r v) = smul r (contract T v) := by
  unfold contract smul; simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ] ;

/-! ## Part 4: Associativity of Iterated Contraction (Theorem 3) -/

/-
**Theorem 3: Associativity of Iterated Contraction.**
If `T` has order `(a+b)+c`, `u` has order `c`, and `v` has order `b`,
then contracting `T` first with `u` then with `v` equals contracting
the reindexed `T` with the tensor product `tensorProd v u`.

This is the algebraic principle behind contraction scheduling in tensor networks:
it guarantees that reordering contractions does not change the result.

Mathematically: `contract(contract(T, u), v) = contract(reindex T, tensorProd(v, u))`
where the reindexing accounts for the canonical isomorphism `(a+b)+c ≅ a+(b+c)`.
-/
theorem contract_assoc {a b c : ℕ}
    (T : GradedTensor R d ((a + b) + c))
    (u : GradedTensor R d c)
    (v : GradedTensor R d b) :
    contract (contract T u) v =
      contract (reindex (Nat.add_assoc a b c) T) (tensorProd v u) := by
  unfold contract reindex tensorProd;
  simp +decide only [Fin.append, mul_comm, mul_assoc];
  refine' funext fun idx => _;
  simp +decide only [Finset.mul_sum _ _ _];
  rw [ ← Finset.sum_product' ];
  refine' Finset.sum_bij ( fun x _ => Fin.append x.1 x.2 ) _ _ _ _ <;> simp +decide [ Fin.append ];
  · intro a b c d h; have := congr_fun h; simp_all +decide [ Fin.addCases ] ;
    exact ⟨ funext fun i => by simpa using this ( Fin.castAdd _ i ), funext fun i => by simpa using this ( Fin.natAdd _ i ) ⟩;
  · intro f; use fun i => f ( Fin.castAdd c i ), fun i => f ( Fin.natAdd b i ) ; ext i; simp +decide [ Fin.addCases ] ;
  · congr! 3;
    ext i; simp +decide [ Fin.addCases ] ;
    split_ifs <;> simp_all +decide [ Fin.castLT, Fin.subNat ];
    · omega;
    · linarith;
    · omega;
    · simp +decide [ Nat.sub_sub ]

/-! ## Part 5: Quadratic Energy Identity (Theorem 4)

The quadratic energy functional `E(T, v) = contract(v, contract(T, v))` for an
order-2 tensor `T` and vector `v` is the bridge from abstract tensor contraction
to physics. For matrices, this computes `vᵀ T v`, the fundamental building block
of metric contraction in differential geometry, stress-strain energy in continuum
mechanics, and quadratic forms in variational calculus. -/

/-- The **quadratic energy functional** for an order-2 tensor `T` and
an order-1 tensor (vector) `v`. Computes `E(T,v) = contract(v, contract(T, v))`,
which for matrices corresponds to `vᵀ T v`. -/
noncomputable def quadEnergy
    (T : GradedTensor R d 2) (v : GradedTensor R d 1) : GradedTensor R d 0 :=
  contract v (contract T v)

/-
**Theorem 4: Quadratic Energy Expansion (Polarization Identity).**
`E(T, u+v) = E(T,u) + contract(u, contract(T,v)) + contract(v, contract(T,u)) + E(T,v)`.

This identity encodes how energies, quadratic forms, and variational derivatives
decompose under superposition of field configurations. It is the exact abstraction
that connects tensor contraction to physics: the cross terms
`contract(u, contract(T,v))` and `contract(v, contract(T,u))` represent the
interaction energy between configurations `u` and `v`.
-/
theorem energy_expansion
    (T : GradedTensor R d 2) (u v : GradedTensor R d 1) :
    quadEnergy T (u + v) =
      quadEnergy T u + contract u (contract T v) +
      contract v (contract T u) + quadEnergy T v := by
  funext; simp [quadEnergy, contract]; (
  simp +decide only [mul_add, sum_add_distrib, mul_sum, add_mul] ; ring;)

/-! ## Part 6: Einstein Term Language (Syntax Layer) -/

/-- **Einstein Term**: the syntax of order-indexed tensor expressions.
This inductive type represents the symbolic language of tensor calculus,
with constructors for constants, variables, addition, tensor product,
and contraction. The type is indexed by order `n : ℕ`. -/
inductive EinsteinTerm (R : Type*) : ℕ → Type _
  | var   : ∀ {n}, ℕ → EinsteinTerm R n
  | zero  : ∀ {n}, EinsteinTerm R n
  | add   : ∀ {n}, EinsteinTerm R n → EinsteinTerm R n → EinsteinTerm R n
  | smul  : ∀ {n}, R → EinsteinTerm R n → EinsteinTerm R n
  | tensorProd : ∀ {j k}, EinsteinTerm R j → EinsteinTerm R k → EinsteinTerm R (j + k)
  | contract : ∀ {j k}, EinsteinTerm R (j + k) → EinsteinTerm R k → EinsteinTerm R j

/-- An environment assigns semantic tensors to variable indices at each order. -/
def EinsteinEnv (R : Type*) (d : ℕ) := (n : ℕ) → ℕ → GradedTensor R d n

/-- **Denotational semantics** for Einstein terms.
Maps each syntactic term to its semantic value as a `GradedTensor`. -/
noncomputable def EinsteinTerm.denote {d : ℕ}
    (env : EinsteinEnv R d) : {n : ℕ} → EinsteinTerm R n → GradedTensor R d n
  | _, .var i => env _ i
  | _, .zero => 0
  | _, .add t₁ t₂ => t₁.denote env + t₂.denote env
  | _, .smul r t => EinsteinContraction.smul r (t.denote env)
  | _, .tensorProd t₁ t₂ => EinsteinContraction.tensorProd (t₁.denote env) (t₂.denote env)
  | _, .contract t v => EinsteinContraction.contract (t.denote env) (v.denote env)

/-! ## Part 7: Einstein Rewrite System -/

/-- **Einstein Rewrite Relation**: captures the algebraic laws of tensor contraction
as oriented rewrite rules. Each constructor corresponds to one direction of a
distributivity, associativity, or zero-elimination law. -/
inductive EinsteinRewrite : {n : ℕ} → EinsteinTerm R n → EinsteinTerm R n → Prop
  | contract_add_left {j k : ℕ}
      (A B : EinsteinTerm R (j + k)) (v : EinsteinTerm R k) :
      EinsteinRewrite (.contract (.add A B) v)
        (.add (.contract A v) (.contract B v))
  | contract_add_right {j k : ℕ}
      (T : EinsteinTerm R (j + k)) (u v : EinsteinTerm R k) :
      EinsteinRewrite (.contract T (.add u v))
        (.add (.contract T u) (.contract T v))
  | contract_zero_left {j k : ℕ}
      (v : EinsteinTerm R k) :
      EinsteinRewrite (.contract (.zero (n := j + k)) v)
        .zero
  | contract_zero_right {j k : ℕ}
      (T : EinsteinTerm R (j + k)) :
      EinsteinRewrite (.contract T (.zero (n := k)))
        .zero
  | contract_smul_left {j k : ℕ}
      (r : R) (T : EinsteinTerm R (j + k)) (v : EinsteinTerm R k) :
      EinsteinRewrite (.contract (.smul r T) v)
        (.smul r (.contract T v))
  | contract_smul_right {j k : ℕ}
      (r : R) (T : EinsteinTerm R (j + k)) (v : EinsteinTerm R k) :
      EinsteinRewrite (.contract T (.smul r v))
        (.smul r (.contract T v))
  | add_zero_left {n : ℕ} (t : EinsteinTerm R n) :
      EinsteinRewrite (.add .zero t) t
  | add_zero_right {n : ℕ} (t : EinsteinTerm R n) :
      EinsteinRewrite (.add t .zero) t

/-
**Theorem 5: Soundness of the Einstein Rewrite System.**
Every rewrite step preserves the denotational semantics of tensor expressions.
This is the theorem that turns symbolic manipulation into certified mathematics.
-/
theorem einsteinRewrite_sound {d : ℕ}
    (env : EinsteinEnv R d)
    {n : ℕ} {t₁ t₂ : EinsteinTerm R n}
    (h : @EinsteinRewrite R n t₁ t₂) :
    t₁.denote env = t₂.denote env := by
  induction h <;> simp_all +decide [ GradedTensor ];
  all_goals apply_rules [ contract_add_left, contract_add_right, contract_zero_left, contract_zero_right, contract_smul_left, contract_smul_right, zero_add, add_zero ]

/-
Multi-step rewriting preserves denotation via reflexive-transitive closure.
-/
theorem einsteinRewrites_sound {d : ℕ}
    (env : EinsteinEnv R d)
    {n : ℕ} {t₁ t₂ : EinsteinTerm R n}
    (h : Relation.ReflTransGen (@EinsteinRewrite R n) t₁ t₂) :
    t₁.denote env = t₂.denote env := by
  induction h;
  · rfl;
  · rw [ ‹EinsteinTerm.denote env t₁ = EinsteinTerm.denote env _›, einsteinRewrite_sound env ‹_› ]

/-! ## Part 8: Contraction System (Organizing Structure) -/

/-- A **ContractionSystem** packages the data and laws of a universal
tensor contraction calculus. This is the central organizing definition:
any model satisfying these axioms supports certified Einstein summation.

This structure captures the minimal algebraic interface for tensor contraction:
a graded family of types with addition and a bilinear contraction that
respects zero. It is the abstract backbone shared by finite-dimensional
tensors, formal power series, and tensor network representations. -/
structure ContractionSystem (R : Type*) [CommSemiring R] where
  /-- The type of tensors at each order. -/
  Tensor : ℕ → Type*
  /-- Zero tensor at each order. -/
  zero : ∀ n, Tensor n
  /-- Addition of same-order tensors. -/
  add : ∀ {n}, Tensor n → Tensor n → Tensor n
  /-- Contraction: the universal graded composition law. -/
  contr : ∀ {j k}, Tensor (j + k) → Tensor k → Tensor j
  /-- Left distributivity of contraction. -/
  contr_add_left : ∀ {j k} (A B : Tensor (j + k)) (v : Tensor k),
    contr (add A B) v = add (contr A v) (contr B v)
  /-- Right distributivity of contraction. -/
  contr_add_right : ∀ {j k} (T : Tensor (j + k)) (u v : Tensor k),
    contr T (add u v) = add (contr T u) (contr T v)
  /-- Contraction with zero on the right. -/
  contr_zero_right : ∀ {j k} (T : Tensor (j + k)),
    contr T (zero k) = zero j
  /-- Contraction with zero on the left. -/
  contr_zero_left : ∀ {j k} (v : Tensor k),
    contr (zero (j + k)) v = zero j

/-- The canonical `ContractionSystem` instance for `GradedTensor R d`.
This demonstrates that finite-dimensional tensors form a concrete model
of the abstract contraction axioms. -/
noncomputable def gradedContractionSystem (R : Type*) [CommSemiring R] (d : ℕ) :
    ContractionSystem R where
  Tensor n := GradedTensor R d n
  zero _ := 0
  add := (· + ·)
  contr := contract
  contr_add_left := contract_add_left
  contr_add_right := contract_add_right
  contr_zero_right := contract_zero_right
  contr_zero_left := contract_zero_left

/-! ## Part 9: Verified Normalizer -/

/-- **Normalization**: pushes contraction through addition, producing
a sum of atomic contractions. This is the computational core of a
certified Einstein summation simplifier. -/
noncomputable def EinsteinTerm.normalize : {n : ℕ} → EinsteinTerm R n → EinsteinTerm R n
  | _, .contract (.add A B) v => .add (.contract (A.normalize) (v.normalize))
                                       (.contract (B.normalize) (v.normalize))
  | _, .contract T (.add u v) => .add (.contract (T.normalize) (u.normalize))
                                       (.contract (T.normalize) (v.normalize))
  | _, .add t₁ t₂ => .add t₁.normalize t₂.normalize
  | _, .contract T v => .contract T.normalize v.normalize
  | _, .smul r t => .smul r t.normalize
  | _, .tensorProd t₁ t₂ => .tensorProd t₁.normalize t₂.normalize
  | _, t => t

/-
**Theorem 6: Soundness of Normalization.**
The normalizer preserves denotational semantics.
-/
theorem normalize_sound {d : ℕ}
    (env : EinsteinEnv R d)
    {n : ℕ} (t : EinsteinTerm R n) :
    t.normalize.denote env = t.denote env := by
  induction' t using EinsteinTerm.rec with t₁ t₂ ih₁ ih₂;
  all_goals norm_num [ EinsteinTerm.normalize ];
  · rename_i k hk₁ hk₂;
    convert congr_arg₂ ( · + · ) hk₁ hk₂ using 1;
  · simp_all +decide [ EinsteinTerm.denote ];
  · rename_i k l a b ha hb;
    exact congr_arg₂ _ ha hb;
  · rename_i j k A B hA hB;
    -- By definition of `normalize`, we know that `normalize (contract A B)` is either `contract (normalize A) (normalize B)` or `add (contract (normalize A) (normalize B)) (contract (normalize A) (normalize B))`.
    by_cases hA_add : ∃ A1 A2, A = EinsteinTerm.add A1 A2;
    · obtain ⟨ A1, A2, rfl ⟩ := hA_add; simp_all +decide [ EinsteinTerm.normalize ] ;
      convert congr_arg ( fun x => EinsteinContraction.contract x ( EinsteinTerm.denote env B ) ) hA using 11;
      simp +decide [ EinsteinTerm.denote, contract_add_left ];
      rw [ hB ];
    · by_cases hB_add : ∃ B1 B2, B = EinsteinTerm.add B1 B2;
      · obtain ⟨ B1, B2, rfl ⟩ := hB_add;
        nontriviality;
        convert einsteinRewrite_sound env ( EinsteinRewrite.contract_add_right A B1 B2 ) using 1;
        · nontriviality;
          convert congr_arg₂ ( fun x y => EinsteinContraction.contract x y ) hA hB using 1;
          simp +decide [ EinsteinTerm.normalize ];
          rw [ EinsteinTerm.normalize ];
          · simp +decide [ EinsteinTerm.denote ];
            exact Eq.symm (contract_add_right (EinsteinTerm.denote env A.normalize) (EinsteinTerm.denote env B1.normalize) (EinsteinTerm.denote env B2.normalize));
          · grind +splitIndPred;
        · exact einsteinRewrite_sound env ( EinsteinRewrite.contract_add_right A B1 B2 );
      · nontriviality;
        convert congr_arg₂ ( fun x y => EinsteinContraction.contract x y ) hA hB using 1;
        rw [ EinsteinTerm.normalize ];
        · exact ((fun a => a) ∘ fun a => a) rfl;
        · exact fun u v h => hB_add ⟨ u, v, h ⟩;
        · exact fun A B h => hA_add ⟨ A, B, h ⟩

/-! ## Part 10: Structural Weight -/

/-- Structural weight of an Einstein term, used for complexity analysis. -/
def EinsteinTerm.weight : {n : ℕ} → EinsteinTerm R n → ℕ
  | _, .var _ => 1
  | _, .zero => 1
  | _, .add t₁ t₂ => 1 + t₁.weight + t₂.weight
  | _, .smul _ t => 1 + t.weight
  | _, .tensorProd t₁ t₂ => 1 + t₁.weight + t₂.weight
  | _, .contract T v => 1 + T.weight + v.weight

omit [CommSemiring R] in
theorem EinsteinTerm.weight_pos : ∀ {n : ℕ} (t : EinsteinTerm R n), 0 < t.weight := by
  intro n t; cases t <;> simp [weight]

/-! ## Part 11: Conjecture — Confluence of Bilinear Einstein Normalization

**Conjecture**: For the fragment generated by addition, tensor product, and contraction
over orders 0..3, the rewrite system oriented by distributivity toward a right-associated
additive normal form is confluent on well-typed terms up to semantic equivalence.

**Computational prediction**: For randomly generated well-typed terms of size ≤ 12 over
orders 0..3, every pair of rewrite sequences from the same starting term evaluates to
the same normal form denotation. A single counterexample refutes the conjecture. -/

/-- A term is in **normal form** if no contraction-distribution rewrites apply. -/
def EinsteinTerm.isNormalForm : {n : ℕ} → EinsteinTerm R n → Prop
  | _, .contract (.add _ _) _ => False
  | _, .contract _ (.add _ _) => False
  | _, .add t₁ t₂ => t₁.isNormalForm ∧ t₂.isNormalForm
  | _, .contract t v => t.isNormalForm ∧ v.isNormalForm
  | _, .smul _ t => t.isNormalForm
  | _, .tensorProd t₁ t₂ => t₁.isNormalForm ∧ t₂.isNormalForm
  | _, _ => True

end EinsteinContraction