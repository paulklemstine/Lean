import Mathlib

/-!
# Categorical tensor-network dynamics

This file develops a **research direction at the interface of category theory and the
dynamics of tensor networks**, carried out entirely through formal proofs rather than
informal analogy.  The guiding thesis is:

> *A tensor network is a morphism in a monoidal category; its contraction is a monoidal
> functor; and its dynamics is the orbit of a transfer endomorphism under composition.*

We make each clause of this slogan into theorems.

## The dictionary

| Tensor-network notion            | Categorical notion                              |
| -------------------------------- | ----------------------------------------------- |
| a tensor with in/out legs        | a morphism `m ⟶ n` in `Mat K`                   |
| sequential contraction of legs   | composition `≫` (matrix product)                |
| side-by-side (parallel) tensors  | monoidal product `⊗` (Kronecker product)        |
| contraction-order independence   | associativity + the interchange law             |
| 1-D network, periodic boundary   | the categorical trace, `tr (Tᵏ)`               |
| time / spatial evolution         | iterated composition `T ↦ Tᵏ` (the orbit)       |
| bond-index gauge freedom         | conjugation by a unit (similarity invariance)   |
| independent subsystems           | a strong monoidal functor to the ground field   |

## Main results

* `§1` — `Mat K` is a category: `tensor_comp_assoc`, `id_tensor_comp`, `tensor_comp_id`.
* `§2` — Kronecker product is a monoidal **bifunctor**: `tensor_interchange`,
  `tensor_unit`, exhibiting contraction order independence (`tensor_comp_interchange`).
* `§3` — the 1-D periodic partition function is the trace of a transfer-matrix power
  (`partitionFunction`), with `partitionFunction_zero`, the dynamical semigroup law
  `transfer_pow_add`, and cyclic (translation) invariance `partitionFunction_cyclic`.
* `§4` — **gauge invariance**: conjugating the bond index by any invertible gauge leaves
  every partition function unchanged (`partitionFunction_gauge_invariant`).
* `§5` — **spectral / thermodynamic** content: for a diagonalised transfer matrix the
  partition function is the power sum of eigenvalues (`partitionFunction_diagonal`), and
  it is bounded below by the dominant eigenvalue (`partitionFunction_dominant_le`).
* `§6` — the **decoupling** theorem: contraction is strong monoidal, so the partition
  function of a Kronecker (parallel) network factorises (`partitionFunction_kronecker`).
* `§7` — the **abstract categorical backbone**: in any monoidal category the interchange
  law governs parallel-vs-sequential contraction (`monoidal_interchange`,
  `monoidal_parallel_serial`).
-/

namespace Bridges.CategoricalTensorNetworks

open Matrix Finset
open scoped Kronecker

universe u

variable {K : Type*} [Field K]

/-! ## §1. Tensors as morphisms in the category `Mat K`

A tensor with input legs indexed by `n` and output legs indexed by `m` is a matrix
`Matrix m n K`.  Contracting a shared index is matrix multiplication; the bare wire is
the identity matrix.  We record the three category axioms. -/

/-- A tensor: a morphism `n ⟶ m` in the category `Mat K` of matrices over `K`. -/
abbrev Tensor (K : Type*) (m n : Type*) := Matrix m n K

/-
**Associativity of contraction** (category axiom): contracting `(A∘B)∘C` and
`A∘(B∘C)` give the same network, so contraction order does not matter.
-/
theorem tensor_comp_assoc {l m n p : Type*} [Fintype m] [Fintype n]
    (A : Tensor K l m) (B : Tensor K m n) (C : Tensor K n p) :
    (A * B) * C = A * (B * C) := by
  convert Matrix.mul_assoc _ _ _

/-
**Left identity** (category axiom): pre-composing with a bare wire changes nothing.
-/
theorem id_tensor_comp {m n : Type*} [Fintype m] [DecidableEq m]
    (A : Tensor K m n) : (1 : Matrix m m K) * A = A := by
  aesop ( simp_config := { singlePass := true } )

/-
**Right identity** (category axiom): post-composing with a bare wire changes nothing.
-/
theorem tensor_comp_id {m n : Type*} [Fintype n] [DecidableEq n]
    (A : Tensor K m n) : A * (1 : Matrix n n K) = A := by
  convert Matrix.mul_one A

/-! ## §2. The monoidal product: Kronecker bifunctoriality

Placing two tensors side by side is the Kronecker (tensor) product `A ⊗ₖ B`.  The
content of "`Mat K` is a *monoidal* category" is that `⊗ₖ` is a bifunctor: it preserves
identities and respects composition.  The latter is the **interchange law**, the precise
statement that a planar tensor network may be contracted column-by-column or
row-by-row with the same result. -/

/-
**Interchange law / bifunctoriality of `⊗ₖ`.**  Contracting two parallel wires and
then juxtaposing equals juxtaposing and then contracting.  This is the categorical
heart of contraction-order independence for 2-D networks.
-/
theorem tensor_interchange {l m n l' m' n' : Type*} [Fintype m] [Fintype m']
    (A : Tensor K l m) (B : Tensor K m n) (A' : Tensor K l' m') (B' : Tensor K m' n') :
    (A * B) ⊗ₖ (A' * B') = (A ⊗ₖ A') * (B ⊗ₖ B') := by
  convert Matrix.mul_kronecker_mul A B A' B' using 1

/-
The monoidal product preserves identities: a pair of bare wires is a bare wire.
-/
theorem tensor_unit {m n : Type*} [DecidableEq m] [DecidableEq n] :
    (1 : Matrix m m K) ⊗ₖ (1 : Matrix n n K) = 1 := by
  aesop

/-
**Contraction-order independence** for a `2 × 2` block of a network: the two ways of
contracting a square of tensors (parallel-then-serial vs. serial-then-parallel) agree.
-/
theorem tensor_comp_interchange {a b c d : Type*} [Fintype b] [Fintype d]
    (f : Tensor K a b) (g : Tensor K b c) (h : Tensor K a d) (k : Tensor K d c) :
    (f ⊗ₖ h) * (g ⊗ₖ k) = (f * g) ⊗ₖ (h * k) := by
  convert ( Matrix.mul_kronecker_mul f g h k ).symm using 1

/-! ## §3. Transfer-matrix dynamics

For a translation-invariant 1-D network with periodic boundary conditions, the full
contraction (partition function) of `k` copies of a square local transfer tensor `T` is
the categorical **trace** of `Tᵏ`.  "Dynamics" is the orbit `k ↦ Tᵏ` under composition,
a one-parameter discrete semigroup. -/

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The partition function of the periodic 1-D network built from `k` copies of the
square transfer tensor `T`: the trace of the `k`-th composition power. -/
def partitionFunction (T : Matrix n n K) (k : ℕ) : K := (T ^ k).trace

/-
The empty (length-0) network evaluates to the dimension of the bond space: the trace
of the identity, i.e. the number of bond states.
-/
theorem partitionFunction_zero (T : Matrix n n K) :
    partitionFunction T 0 = (Fintype.card n : K) := by
  -- By definition of exponentiation, $T^0$ is the identity matrix.
  simp [partitionFunction]

/-
**Dynamical semigroup law.**  Composing a length-`a` and a length-`b` segment yields
the length-`(a+b)` transfer operator; iterating the transfer endomorphism is additive in
the exponent.
-/
theorem transfer_pow_add (T : Matrix n n K) (a b : ℕ) :
    T ^ (a + b) = T ^ a * T ^ b := by
  induction' b with b ih;
  · simp +decide;
  · rw [ Nat.add_succ, pow_succ, ih, mul_assoc, pow_succ ]

/-
**Translation (cyclic) invariance.**  Cutting the periodic chain between segments `a`
and `b` and reconnecting the other way leaves the partition function unchanged: this is
the cyclic invariance of the trace, i.e. the rotational symmetry of the network on the
circle.
-/
theorem partitionFunction_cyclic (T : Matrix n n K) (a b : ℕ) :
    (T ^ a * T ^ b).trace = (T ^ b * T ^ a).trace := by
  rw [ ← pow_add, add_comm, pow_add ]

/-! ## §4. Gauge invariance of the bond index

A tensor network has a *gauge freedom*: inserting `G⁻¹ G = 1` on any internal bond
(conjugating the transfer matrix by an invertible `G`) is physically invisible.  This is
similarity invariance of the trace of powers. -/

/-
**Gauge invariance.**  Conjugating the transfer matrix by any invertible gauge `G`
leaves every partition function unchanged.
-/
theorem partitionFunction_gauge_invariant (T : Matrix n n K) (G : (Matrix n n K)ˣ)
    (k : ℕ) :
    partitionFunction ((↑G⁻¹ : Matrix n n K) * T * (↑G : Matrix n n K)) k
      = partitionFunction T k := by
  have h_similar : ∀ k : ℕ, (G⁻¹ * T * G : Matrix n n K) ^ k = G⁻¹ * T ^ k * G := by
    intro k; induction k <;> simp_all +decide [ pow_succ', mul_assoc ] ;
  unfold partitionFunction;
  rw [ h_similar, Matrix.trace_mul_comm ];
  simp +decide [ ← mul_assoc ]

/-! ## §5. Spectral and thermodynamic content

If the transfer matrix is diagonalised (its bonds are eigenmodes), the partition
function is the **power sum of eigenvalues** `∑ᵢ λᵢᵏ`.  In the thermodynamic limit the
sum is governed by the dominant eigenvalue; we record the corresponding lower bound over
the reals. -/

/-
For a diagonal transfer matrix, the partition function is the power sum of the
diagonal eigenvalues `∑ᵢ (dᵢ)ᵏ`.
-/
theorem partitionFunction_diagonal (d : n → K) (k : ℕ) :
    partitionFunction (Matrix.diagonal d) k = ∑ i, (d i) ^ k := by
  unfold partitionFunction; simp +decide [ Matrix.trace ] ;
  simp +decide [ diagonal_pow ]

/-
**Dominant-eigenvalue bound.**  With non-negative real eigenvalues, the partition
function is at least the `k`-th power of any single eigenvalue: the free energy is
controlled from below by the largest eigenvalue.
-/
theorem partitionFunction_dominant_le {n : Type*} [Fintype n] [DecidableEq n]
    (d : n → ℝ) (hd : ∀ i, 0 ≤ d i) (i₀ : n) (k : ℕ) :
    (d i₀) ^ k ≤ partitionFunction (Matrix.diagonal d) k := by
  convert Finset.single_le_sum ( fun i _ => pow_nonneg ( hd i ) k ) ( Finset.mem_univ i₀ ) using 1;
  convert partitionFunction_diagonal d k using 1

/-! ## §6. Decoupling: contraction is a strong monoidal functor

Evaluating (fully contracting) a network is a **strong monoidal functor** to the ground
field `K`.  Hence the partition function of a Kronecker (parallel/independent) network
*factorises* as the product of the partition functions of the factors — the categorical
form of statistical independence of decoupled subsystems. -/

/-
The composition power of a Kronecker product splits factorwise:
`(A ⊗ₖ B)ᵏ = Aᵏ ⊗ₖ Bᵏ`.  This is functoriality of `(·)ᵏ` through the monoidal product.
-/
theorem kronecker_pow {m n : Type*} [Fintype m] [DecidableEq m] [Fintype n] [DecidableEq n]
    (A : Matrix m m K) (B : Matrix n n K) (k : ℕ) :
    (A ⊗ₖ B) ^ k = (A ^ k) ⊗ₖ (B ^ k) := by
  induction' k with k ih;
  · convert tensor_unit;
    all_goals try infer_instance;
    · ext i j; simp +decide [ Matrix.one_apply ] ;
      grind;
    · convert tensor_unit;
  · simp +decide [ pow_succ, ← Matrix.mul_kronecker_mul, ih ]

/-
**Decoupling theorem.**  The partition function of a parallel (Kronecker) network is
the product of the partition functions of its independent factors.
-/
theorem partitionFunction_kronecker {m n : Type*} [Fintype m] [DecidableEq m]
    [Fintype n] [DecidableEq n]
    (A : Matrix m m K) (B : Matrix n n K) (k : ℕ) :
    partitionFunction (A ⊗ₖ B) k = partitionFunction A k * partitionFunction B k := by
  convert Matrix.trace_kronecker ( A ^ k ) ( B ^ k ) using 1;
  convert congr_arg Matrix.trace ( kronecker_pow A B k ) using 1

/-! ## §7. The abstract categorical backbone

Everything above is an instance of a single law in an arbitrary monoidal category: the
**interchange law**.  We state it abstractly to make explicit that contraction-order
independence is not special to matrices but is the defining coherence of a monoidal
category. -/

open CategoryTheory MonoidalCategory

/-
**Abstract interchange law.**  In any monoidal category, juxtaposing two composites
equals composing two juxtapositions.
-/
theorem monoidal_interchange {C : Type u} [Category.{u} C] [MonoidalCategory C]
    {X Y Z X' Y' Z' : C}
    (f : X ⟶ Y) (g : Y ⟶ Z) (f' : X' ⟶ Y') (g' : Y' ⟶ Z') :
    (f ≫ g) ⊗ₘ (f' ≫ g') = (f ⊗ₘ f') ≫ (g ⊗ₘ g') :=
  (tensorHom_comp_tensorHom f f' g g').symm

/-
**Parallel-vs-serial contraction**, abstractly: the two evaluation orders of a square
of morphisms coincide in every monoidal category.
-/
theorem monoidal_parallel_serial {C : Type u} [Category.{u} C] [MonoidalCategory C]
    {A B C₀ D : C} (f : A ⟶ B) (g : B ⟶ C₀) (h : A ⟶ D) (k : D ⟶ C₀) :
    (f ⊗ₘ h) ≫ (g ⊗ₘ k) = (f ≫ g) ⊗ₘ (h ≫ k) := by
  convert tensorHom_comp_tensorHom f h g k

end Bridges.CategoricalTensorNetworks