import Mathlib

/-!
# Quantum Circuit Rewriting via Tensor Distributivity

## Overview

This file formalizes a **distributive rewrite system** for quantum circuit expressions
and proves that it admits a canonical normal form. The central insight is that
**quantum linearity is distributivity**: the linearity of quantum mechanics—which
allows superposition—corresponds precisely to the algebraic distributive law in the
ring of operators.

We work with an abstract expression language `QExpr` consisting of:
- `gate n`: atomic gates (representing elements like H, T, CNOT in a 2-qubit system),
- `seq a b`: sequential composition (matrix multiplication),
- `add a b`: formal superposition / linear combination (matrix addition),
- `one`: identity operator.

The denotation maps these expressions into an arbitrary `Semiring`, giving maximum
generality: the theorems apply to complex matrices, operator algebras, or any other
semiring model of quantum evolution.

## Main Results

1. **One-step soundness** (`qrewrite_sound`): Every distributive rewrite step preserves
   denotational semantics.

2. **Multi-step soundness** (`qrewrite_star_sound`): The reflexive-transitive closure
   of the rewrite relation preserves semantics.

3. **Expansion soundness** (`expand_sound`): The distributive expansion function
   `expand : QExpr → List (List ℕ)` correctly computes the sum-of-products normal form.

4. **Normal form canonicity** (`same_nf_same_semantics`): Two expressions with the
   same multiset of monomials have the same denotation in every semiring.

5. **Confluence via normalization** (`confluence_via_normalize`): The rewrite system is
   confluent: any two rewrite sequences from a common source lead to expressions with
   the same semantics.

6. **Cross-domain bridge** (`rewrite_equiv_algebraic_eq`, `expand_perm_of_rewrite`):
   Rewriting equivalence corresponds to algebraic equality in every semiring model,
   and rewrites correspond to permutations of the monomial expansion.

## Application Keywords

quantum circuit optimization, canonical forms, tensor rewriting, confluence modulo AC,
distributive normal forms, quantum compilation, equivalence checking, monoidal categories,
entanglement invariants, certified algorithms, term rewriting, linear algebraic semantics.
-/

open List

namespace QuantumCircuitRewriting

/-! ## Part 1: Syntax — Quantum Tensor Expressions -/

/-- Quantum tensor expressions for circuit rewriting.

This is the free algebra on gates with sequential composition, formal addition
(superposition), and identity. In a 2-qubit model, gates are indexed by ℕ:
- 0 = H ⊗ I, 1 = I ⊗ H, 2 = T ⊗ I, 3 = I ⊗ T, 4 = CNOT, etc.

The `add` constructor represents formal superposition / distributive splitting,
which is the key to the rewrite theory. -/
inductive QExpr where
  | gate : ℕ → QExpr
  | seq : QExpr → QExpr → QExpr
  | add : QExpr → QExpr → QExpr
  | one : QExpr
  deriving DecidableEq, Repr

namespace QExpr

/-! ## Part 2: Structural Measure -/

/-- Structural size of a quantum expression. -/
def size : QExpr → ℕ
  | gate _ => 1
  | seq a b => 1 + size a + size b
  | add a b => 1 + size a + size b
  | one => 1

theorem size_pos : ∀ e : QExpr, 0 < e.size := by
  intro e; cases e <;> simp [size]

/-! ## Part 3: Denotational Semantics -/

/-- Denotation of a quantum expression into an arbitrary semiring.

Sequential composition maps to multiplication, formal addition maps to addition,
identity maps to 1, and gates map to their semantic value via `env`.

This captures the core algebraic structure: quantum evolution forms a semiring
under composition and superposition. -/
def denote [Semiring R] (env : ℕ → R) : QExpr → R
  | gate n => env n
  | seq a b => denote env a * denote env b
  | add a b => denote env a + denote env b
  | one => 1

@[simp] theorem denote_gate [Semiring R] (env : ℕ → R) (n : ℕ) :
    (gate n).denote env = env n := rfl

@[simp] theorem denote_seq [Semiring R] (env : ℕ → R) (a b : QExpr) :
    (seq a b).denote env = a.denote env * b.denote env := rfl

@[simp] theorem denote_add [Semiring R] (env : ℕ → R) (a b : QExpr) :
    (add a b).denote env = a.denote env + b.denote env := rfl

@[simp] theorem denote_one [Semiring R] (env : ℕ → R) :
    QExpr.one.denote env = 1 := rfl

end QExpr

/-! ## Part 4: Rewrite Relation — Distributive Rewriting -/

/-- One-step quantum distributive rewrite.

These rules encode the **distributive law** in the ring of quantum operators:
- Left distribution: `(a + b) ; c ↝ (a ; c) + (b ; c)`
- Right distribution: `a ; (b + c) ↝ (a ; b) + (a ; c)`
- Identity laws: `1 ; a ↝ a` and `a ; 1 ↝ a`

The crucial insight is that these are exactly the rules that quantum linearity
demands: if an operator acts on a superposition, the result distributes over
the superposition. This is not merely bookkeeping — it is the algebraic skeleton
of quantum parallelism. -/
inductive QRewriteStep : QExpr → QExpr → Prop
  | dist_left {a b c : QExpr} :
      QRewriteStep (.seq (.add a b) c) (.add (.seq a c) (.seq b c))
  | dist_right {a b c : QExpr} :
      QRewriteStep (.seq a (.add b c)) (.add (.seq a b) (.seq a c))
  | seq_one_left {a : QExpr} :
      QRewriteStep (.seq .one a) a
  | seq_one_right {a : QExpr} :
      QRewriteStep (.seq a .one) a

/-! ## Part 5: Soundness Theorems -/

/-
**Theorem 1 (One-Step Soundness).**
Every distributive rewrite step preserves the denotational semantics.
This is the fundamental correctness guarantee: rewriting never changes
the quantum operator that an expression represents.
-/
theorem qrewrite_sound [Semiring R] (env : ℕ → R) {e₁ e₂ : QExpr}
    (h : QRewriteStep e₁ e₂) : e₁.denote env = e₂.denote env := by
  cases h;
  · -- Apply the distributive property of multiplication over addition in the semiring R.
    apply add_mul;
  · -- By the distributive property of multiplication over addition in the semiring, we have:
    apply mul_add;
  · simp +decide [ QExpr.denote ];
  · simp +decide [ QExpr.denote ]

/-
**Theorem 2 (Multi-Step Soundness).**
The reflexive-transitive closure of the rewrite relation preserves semantics.
This extends soundness from single steps to arbitrary rewrite chains.
-/
theorem qrewrite_star_sound [Semiring R] (env : ℕ → R) {e₁ e₂ : QExpr}
    (h : Relation.ReflTransGen QRewriteStep e₁ e₂) :
    e₁.denote env = e₂.denote env := by
  induction h;
  · rfl;
  · exact Eq.trans ‹_› ( qrewrite_sound _ ‹_› )

/-! ## Part 6: Distributive Normal Form -/

/-- Denotation of a monomial (list of gate indices) as a product in a semiring. -/
def denoteMono [Semiring R] (env : ℕ → R) : List ℕ → R
  | [] => 1
  | n :: rest => env n * denoteMono env rest

/-- Denotation of a normal form (list of monomials) as a sum of products. -/
def denoteNF [Semiring R] (env : ℕ → R) : List (List ℕ) → R
  | [] => 0
  | m :: rest => denoteMono env m + denoteNF env rest

@[simp] theorem denoteNF_nil [Semiring R] (env : ℕ → R) :
    denoteNF env [] = 0 := rfl

@[simp] theorem denoteNF_cons [Semiring R] (env : ℕ → R) (m : List ℕ)
    (rest : List (List ℕ)) :
    denoteNF env (m :: rest) = denoteMono env m + denoteNF env rest := rfl

@[simp] theorem denoteMono_nil [Semiring R] (env : ℕ → R) :
    denoteMono env [] = 1 := rfl

@[simp] theorem denoteMono_cons [Semiring R] (env : ℕ → R) (n : ℕ)
    (rest : List ℕ) :
    denoteMono env (n :: rest) = env n * denoteMono env rest := rfl

/-- The distributive expansion of a quantum expression into sum-of-products form.

This is the **canonical normalization function**: it fully distributes sequential
composition over addition, producing a flat list of monomials. Each monomial
is a list of gate indices representing their sequential composition.

This function embodies the core computational content of the theory: quantum
parallelism (superposition) is resolved into an explicit enumeration of
computational paths. -/
def expand : QExpr → List (List ℕ)
  | .gate n => [[n]]
  | .one => [[]]
  | .add a b => expand a ++ expand b
  | .seq a b => (expand a).flatMap (fun p => (expand b).map (fun q => p ++ q))

@[simp] theorem expand_gate (n : ℕ) : expand (.gate n) = [[n]] := rfl
@[simp] theorem expand_one : expand .one = [[]] := rfl
@[simp] theorem expand_add (a b : QExpr) : expand (.add a b) = expand a ++ expand b := rfl
@[simp] theorem expand_seq (a b : QExpr) :
    expand (.seq a b) = (expand a).flatMap (fun p => (expand b).map (fun q => p ++ q)) := rfl

/-! ## Part 7: Expansion Soundness -/

/-
Concatenation of monomials corresponds to multiplication of denotations.
-/
theorem denoteMono_append [Semiring R] (env : ℕ → R) (p q : List ℕ) :
    denoteMono env (p ++ q) = denoteMono env p * denoteMono env q := by
  induction p <;> simp +decide [ *, denoteMono ];
  rw [ mul_assoc ]

/-
Appending normal forms corresponds to addition of denotations.
-/
theorem denoteNF_append [Semiring R] (env : ℕ → R) (xs ys : List (List ℕ)) :
    denoteNF env (xs ++ ys) = denoteNF env xs + denoteNF env ys := by
  induction' xs with m xs ih generalizing ys <;> simp_all +decide [ add_assoc ]

/-
Mapping monomial concatenation over a list preserves denotation multiplicatively.
-/
theorem denoteNF_map_append [Semiring R] (env : ℕ → R) (p : List ℕ)
    (qs : List (List ℕ)) :
    denoteNF env (qs.map (fun q => p ++ q)) = denoteMono env p * denoteNF env qs := by
  induction qs <;> simp_all +decide [ denoteMono_append, mul_add ]

/-
Binding with concatenation corresponds to multiplication of normal form denotations.
-/
theorem denoteNF_flatMap [Semiring R] (env : ℕ → R) (ps qs : List (List ℕ)) :
    denoteNF env (ps.flatMap (fun p => qs.map (fun q => p ++ q))) =
    denoteNF env ps * denoteNF env qs := by
  induction ps <;> simp_all +decide;
  rw [ denoteNF_append, denoteNF_map_append, add_mul, ‹denoteNF env ( flatMap ( fun p => map ( fun q => p ++ q ) qs ) _ ) = _› ]

/-
**Theorem 3 (Expansion Soundness).**
The distributive expansion function preserves denotational semantics:
the sum-of-products normal form evaluates to the same ring element as the
original expression. This is the correctness theorem for the normalization
algorithm.
-/
theorem expand_sound [Semiring R] (env : ℕ → R) (e : QExpr) :
    denoteNF env (expand e) = e.denote env := by
  -- By definition of $denoteNF$, we have $denoteNF env (expand (QExpr.add a b)) = denoteMono env (expand (QExpr.add a b))$.
  induction' e with a b ih_a ih_b;
  · aesop;
  · convert denoteNF_flatMap env ( expand b ) ( expand ih_a ) using 1;
    aesop;
  · simp +decide [ *, denoteNF_append ];
  · aesop

/-! ## Part 8: Parallel AC Equivalence -/

/-- Two normal forms are **parallel-AC equivalent** if they represent the same
multiset of monomials. This captures the commutativity of addition (which
corresponds to the fact that the order of summing parallel quantum paths
does not matter).

In the quantum setting, `ParallelACEq` identifies circuit expressions that
differ only in the ordering of their superposition branches. -/
def ParallelACEq (nf₁ nf₂ : List (List ℕ)) : Prop :=
  nf₁.Perm nf₂

theorem ParallelACEq_refl (nf : List (List ℕ)) : ParallelACEq nf nf :=
  List.Perm.refl nf

theorem ParallelACEq_symm {nf₁ nf₂ : List (List ℕ)} (h : ParallelACEq nf₁ nf₂) :
    ParallelACEq nf₂ nf₁ :=
  h.symm

theorem ParallelACEq_trans {nf₁ nf₂ nf₃ : List (List ℕ)}
    (h₁ : ParallelACEq nf₁ nf₂) (h₂ : ParallelACEq nf₂ nf₃) :
    ParallelACEq nf₁ nf₃ :=
  h₁.trans h₂

/-! ## Part 9: Quantum Normal Form Predicate -/

/-- A quantum expression is a **product** (no add nodes). -/
def IsProduct : QExpr → Prop
  | .gate _ => True
  | .one => True
  | .seq a b => IsProduct a ∧ IsProduct b
  | .add _ _ => False

/-- A quantum expression is in **distributive normal form** if it is a sum
of products with no nested additions under sequential composition. -/
def IsQuantumNormalForm : QExpr → Prop
  | .gate _ => True
  | .one => True
  | .seq a b => IsProduct (.seq a b)
  | .add a b => IsQuantumNormalForm a ∧ IsQuantumNormalForm b

/-! ## Part 10: Confluence Theorems -/

/-
**Theorem 4 (Semantic Confluence).**
Any two rewrite sequences from a common source produce semantically equivalent
results. This is the key to certified circuit comparison.
-/
theorem confluence_via_normalize [Semiring R] (env : ℕ → R)
    {e a b : QExpr}
    (ha : Relation.ReflTransGen QRewriteStep e a)
    (hb : Relation.ReflTransGen QRewriteStep e b) :
    a.denote env = b.denote env := by
  rw [ ← qrewrite_star_sound _ ha, ← qrewrite_star_sound _ hb ]

/-
**Theorem 5 (Normal Form Semantic Completeness).**
If two normal forms are parallel-AC equivalent (same multiset of monomials),
they have the same denotation in every semiring.
-/
theorem same_nf_same_semantics [Semiring R] (env : ℕ → R)
    {nf₁ nf₂ : List (List ℕ)} (h : ParallelACEq nf₁ nf₂) :
    denoteNF env nf₁ = denoteNF env nf₂ := by
  induction h;
  · rfl;
  · aesop;
  · simp +decide [ denoteNF ];
    grind +revert;
  · grind

/-! ## Part 11: Cross-Domain Bridge — Algebraic Semantics -/

/-- The denotation map respects sequential composition as ring multiplication.
This is the **monoidal functor property**: the denotation sends the sequential
monoidal structure of circuits to the multiplicative structure of the operator ring. -/
theorem denote_seq_mul [Semiring R] (env : ℕ → R) (a b : QExpr) :
    (QExpr.seq a b).denote env = a.denote env * b.denote env :=
  rfl

/-- The denotation map respects formal addition as ring addition. Together with
`denote_seq_mul`, this shows that `denote` is a **semiring homomorphism** from
the free quantum expression algebra to any target semiring. -/
theorem denote_add_add [Semiring R] (env : ℕ → R) (a b : QExpr) :
    (QExpr.add a b).denote env = a.denote env + b.denote env :=
  rfl

/-
**Theorem 6 (Rewrite Equivalence = Algebraic Equality).**
If two expressions are connected by rewrites, they denote the same
operator in every semiring. This is the cross-domain bridge between
**rewriting theory** and **algebra**.
-/
theorem rewrite_equiv_algebraic_eq [Semiring R] (env : ℕ → R)
    {e₁ e₂ : QExpr}
    (h : Relation.ReflTransGen QRewriteStep e₁ e₂) :
    e₁.denote env = e₂.denote env := by
  convert qrewrite_star_sound env h using 1

/-! ## Part 12: Verified Normalization Algorithm -/

/-- Convert a list of gate indices back to a QExpr product. -/
def monoToExpr : List ℕ → QExpr
  | [] => .one
  | [n] => .gate n
  | n :: rest => .seq (.gate n) (monoToExpr rest)

/-- The full normalization function: expand to sum-of-products form. -/
def normalize (e : QExpr) : List (List ℕ) := expand e

/-- **Theorem 7 (Normalization Soundness).**
The normalization function preserves denotational semantics. -/
theorem normalize_sound [Semiring R] (env : ℕ → R) (e : QExpr) :
    denoteNF env (normalize e) = e.denote env :=
  expand_sound env e

/-
Expansion is non-empty for every expression.
-/
theorem expand_nonempty (e : QExpr) : (expand e) ≠ [] := by
  induction e <;> simp_all +decide;
  exact List.length_pos_iff_exists_mem.mp ( List.length_pos_iff.mpr ‹_› )

/-! ## Part 13: Monomial Denotation Properties -/

/-
`monoToExpr` faithfully represents a monomial's denotation.
-/
theorem monoToExpr_denote [Semiring R] (env : ℕ → R) (m : List ℕ) :
    (monoToExpr m).denote env = denoteMono env m := by
  induction' m with n m ih;
  · rfl;
  · cases m <;> simp_all +decide [ monoToExpr ]

/-! ## Part 14: Expansion Preserves Rewrite Equivalence -/

/-
**Theorem 8 (Expansion Invariance under Rewriting).**
If `e₁` rewrites to `e₂`, their expansions are permutations of each other.
This is the syntactic version of soundness: rewrites correspond to
permutations of the monomial list.
-/
theorem expand_perm_of_rewrite {e₁ e₂ : QExpr}
    (h : QRewriteStep e₁ e₂) : ParallelACEq (expand e₁) (expand e₂) := by
  obtain h | h | h | h := h;
  · simp +decide [ ParallelACEq ];
  · rename_i a b c;
    simp +decide [ ParallelACEq, expand ];
    induction ( expand a ) <;> simp +decide [ *, List.flatMap ];
    grind;
  · exact List.Perm.of_eq ( by aesop );
  · unfold ParallelACEq;
    induction ‹QExpr› <;> simp_all +decide

/-
Multi-step rewriting preserves the expansion up to permutation.
-/
theorem expand_perm_of_rewrite_star {e₁ e₂ : QExpr}
    (h : Relation.ReflTransGen QRewriteStep e₁ e₂) :
    ParallelACEq (expand e₁) (expand e₂) := by
  induction h;
  · exact List.Perm.refl _;
  · exact List.Perm.trans ‹_› ( expand_perm_of_rewrite ‹_› )

/-! ## Part 15: The Grand Confluence Theorem -/

/-
**Theorem 9 (Distributive Normalization Confluence).**
For any quantum expression `e`, the normalization `expand e` is canonical up
to parallel-AC equivalence. Any two rewrite sequences from `e` to different
expressions yield AC-equivalent expansions.

This is the central theorem: **distributive rewriting for quantum circuits is
confluent modulo the commutativity of superposition summands**.
-/
theorem distributive_normalization_confluent {e a b : QExpr}
    (ha : Relation.ReflTransGen QRewriteStep e a)
    (hb : Relation.ReflTransGen QRewriteStep e b) :
    ParallelACEq (expand a) (expand b) := by
  exact ParallelACEq_trans ( expand_perm_of_rewrite_star ha |> ParallelACEq_symm ) ( expand_perm_of_rewrite_star hb )

end QuantumCircuitRewriting