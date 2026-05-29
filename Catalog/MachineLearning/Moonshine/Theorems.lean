/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Speculative.Moonshine.Defs

/-!
# Formal Spectral Moonshine: Main Theorems

This file proves the core theorems of the formal spectral moonshine framework:

1. **Reconstruction theorem**: Graded virtual G-modules are determined by their trace
   class functions — if two graded modules have the same graded traces, they have the
   same irreducible multiplicity profiles.

2. **Fourier inversion on class functions**: Class functions can be reconstructed
   from their inner products with an orthonormal basis, establishing the spectral
   decoding framework.

3. **Cross-domain theorem (statistical mechanics)**: The graded trace / partition function
   is additive under direct sums of graded representations.

4. **Spectral orthogonality**: Orthogonal class functions have orthogonal spectral
   weight vectors (Parseval-type theorem).

## Application Keywords

monstrous moonshine, McKay–Thompson series, class functions, irreducible characters,
Fourier inversion on finite groups, graded representations, q-series, spectral decoding,
harmonic analysis, representation theory, partition functions, information compression
-/

open Finset BigOperators Complex

noncomputable section

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-! ## Theorem 1: Reconstruction of multiplicities from traces

The key insight is that if two graded virtual G-modules produce the same trace class
functions in each degree, then they must have the same irreducible multiplicity profiles.
This is the rigorous core of "the q-series remembers the representation theory."
-/

/-
**Reconstruction uniqueness**: If two sequences of class functions have identical
values at every group element and every degree, then their inner products with any
class function χ agree in every degree.

This is the precise formal content of "McKay–Thompson data determines representation data":
if the graded traces agree, then the multiplicity of every irreducible character agrees.
-/
theorem graded_module_determined_by_traces
    (A B : ℕ → ClassFn G ℂ)
    (hEq : ∀ n, ∀ g : G, A n g = B n g)
    (χ : ClassFn G ℂ) :
    ∀ n, multiplicityOf (A n) χ = multiplicityOf (B n) χ := by
      intro n; congr; ext g; simp +decide [ Fintype.card_eq_zero_iff, hEq ] ;

/-
Equal class functions yield equal multiplicities — pointwise version.
-/
theorem multiplicityOf_eq_of_classFn_eq
    {f g : ClassFn G ℂ} (h : f = g) (χ : ClassFn G ℂ) :
    multiplicityOf f χ = multiplicityOf g χ := by
      rw [h]

/-
Equal class functions yield equal spectral weights.
-/
theorem spectralWeight_eq_of_classFn_eq
    {f g : ClassFn G ℂ} (h : f = g) (χ : ClassFn G ℂ) :
    spectralWeight f χ = spectralWeight g χ := by
      rw [ h ]

/-! ## Theorem 2: Fourier inversion on class functions

For a finite group G, class functions can be reconstructed from their inner products
with an orthonormal basis of irreducible characters. This recasts moonshine as
spectral decoding.
-/

/-- An orthonormal family of class functions: pairwise inner products are Kronecker deltas.
This captures the key property of irreducible characters. -/
def IsOrthonormal {ι : Type*} [Fintype ι] [DecidableEq ι]
    (basis : ι → ClassFn G ℂ) : Prop :=
  ∀ i j : ι, ClassFn.cfInner (basis i) (basis j) = if i = j then 1 else 0

/-- A complete orthonormal family: every class function is a sum of projections. -/
def IsCompleteOrthonormal {ι : Type*} [Fintype ι] [DecidableEq ι]
    (basis : ι → ClassFn G ℂ) : Prop :=
  IsOrthonormal basis ∧
  ∀ f : ClassFn G ℂ, ∀ g : G,
    f g = ∑ i : ι, ClassFn.cfInner f (basis i) * (basis i) g

/-
**Fourier inversion theorem for class functions**: Given a complete orthonormal basis
of class functions (i.e., the irreducible characters of G), any class function f can be
recovered from its Fourier coefficients:

  `f(g) = ∑_χ ⟨f, χ⟩ · χ(g)`

This is the cross-domain theorem connecting moonshine to harmonic analysis on finite groups.
The irreducible characters serve as frequency components, and the inner products are
the Fourier coefficients.
-/
theorem classFn_fourier_expansion
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (basis : ι → ClassFn G ℂ)
    (hBasis : IsCompleteOrthonormal basis)
    (f : ClassFn G ℂ) :
    ∀ g : G, f g = ∑ i : ι, ClassFn.cfInner f (basis i) * (basis i) g := by
      exact hBasis.2 f

/-
**Fourier coefficient extraction**: For an orthonormal basis, the Fourier coefficient
of a basis element with respect to another basis element is the Kronecker delta.
-/
theorem fourier_coeff_basis
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (basis : ι → ClassFn G ℂ)
    (hBasis : IsOrthonormal basis)
    (i j : ι) :
    ClassFn.cfInner (basis i) (basis j) = if i = j then 1 else 0 := by
      exact hBasis i j

/-
**Multiplicity recovery**: If a class function f is a virtual character (integer combination
of an orthonormal basis), then its inner product with each basis element recovers the
integer multiplicity.
-/
theorem multiplicity_eq_cfInner_of_virtual_character
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (basis : ι → ClassFn G ℂ)
    (hBasis : IsOrthonormal basis)
    (f : ClassFn G ℂ)
    (hf : IsVirtualCharacter basis f)
    (i : ι) :
    ClassFn.cfInner f (basis i) = ↑((hf.choose) i) := by
      have := hf.choose_spec;
      -- By linearity of the inner product, we can split the sum into individual terms.
      have h_split : f.cfInner (basis i) = ∑ j, (hf.choose j : ℂ) * (ClassFn.cfInner (basis j) (basis i)) := by
        unfold ClassFn.cfInner;
        simp +decide only [this, sum_mul, mul_sum _ _ _];
        exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring );
      rw [ h_split, Finset.sum_eq_single i ] <;> simp_all +decide [ IsOrthonormal ]

/-! ## Theorem 3: Cross-domain — partition function additivity

The graded trace (partition function) is additive under direct sums of representations.
This connects moonshine to statistical mechanics: the partition function of a combined
system is the sum of individual partition functions.

`Z_{V⊕W}(g,q) = Z_V(g,q) + Z_W(g,q)`
-/

/-- Direct sum of class functions: given two class functions, their sum is a class function
representing the trace of a direct sum representation. -/
def ClassFn.directSum (f g : ClassFn G R) [Add R] : ClassFn G R :=
  f + g

/-
**Partition function additivity (statistical mechanics bridge)**:
For graded representations, the trace class function of a direct sum is the sum of
the individual trace class functions. This is the fundamental additivity law for
partition functions in statistical mechanics.
-/
theorem gradedTrace_directSum_eq_add
    (A B : MoonshinePacket G ℂ) :
    ∀ n g, (A + B).coeff n g = A.coeff n g + B.coeff n g := by
      aesop

/-
The moonshine packet of a direct sum is the sum of moonshine packets.
-/
theorem moonshinePacket_add_eval
    (A B : MoonshinePacket G ℂ) (g : G) (n : ℕ) :
    (A + B).eval g n = A.eval g n + B.eval g n := by
      exact Complex.ext rfl rfl

/-! ## Theorem 4: Spectral orthogonality

Orthogonal class functions have orthogonal spectral fingerprints.
This is a Parseval-type theorem connecting the representation-theoretic
inner product to the spectral weight decomposition.
-/

/-
**Spectral Parseval theorem**: Given a complete orthonormal basis, the inner product
of two class functions equals the sum of products of their Fourier coefficients.

  `⟨f, g⟩ = ∑_χ ⟨f, χ⟩ * conj(⟨g, χ⟩)`

This is the finite-group analogue of Parseval's theorem from harmonic analysis.
-/
theorem classFn_parseval
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (basis : ι → ClassFn G ℂ)
    (hBasis : IsCompleteOrthonormal basis)
    (f g : ClassFn G ℂ) :
    ClassFn.cfInner f g =
      ∑ i : ι, ClassFn.cfInner f (basis i) * starRingEnd ℂ (ClassFn.cfInner g (basis i)) := by
  -- By the linearity of the inner product and the orthonormality of the basis, we can express f as a linear combination of the basis elements.
  have hf : f = ∑ i, (f.cfInner (basis i)) • basis i := by
    ext x;
    convert hBasis.2 f x using 1;
    induction' ( Finset.univ : Finset ι ) using Finset.induction <;> aesop;
  conv_lhs => rw [ hf ];
  -- By linearity of the inner product, we can distribute the inner product over the sum.
  have h_inner_sum : ∀ (s : Finset ι) (c : ι → ℂ) (h : ι → ClassFn G ℂ), (∑ i ∈ s, c i • h i).cfInner g = ∑ i ∈ s, c i * (h i).cfInner g := by
    intro s c h;
    induction' s using Finset.induction with i s hi ih;
    · simp +decide [ ClassFn.cfInner ];
    · rw [ Finset.sum_insert hi, ClassFn.cfInner_add_left, ih, Finset.sum_insert hi ];
      rw [ ClassFn.cfInner_smul_left ];
  convert h_inner_sum Finset.univ ( fun i => f.cfInner ( basis i ) ) basis using 2;
  simp +decide [ ClassFn.cfInner, mul_comm ]

/-! ## Verified Algorithm: Multiplicity Decoder

The multiplicity decoding algorithm takes a class function and an orthonormal basis
and computes the Fourier/multiplicity coefficients. -/

/-- The multiplicity decoding function: extracts Fourier coefficients of a class function
with respect to a given basis. This is the computational core of the moonshine decoder. -/
def decodeMultiplicities {ι : Type*} [Fintype ι]
    (f : ClassFn G ℂ) (basis : ι → ClassFn G ℂ) : ι → ℂ :=
  fun i => ClassFn.cfInner f (basis i)

/-
**Correctness of the multiplicity decoder**: For a virtual character, the decoded
multiplicities are exactly the integer coefficients in the irreducible decomposition.
-/
theorem decodeMultiplicities_correct
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (basis : ι → ClassFn G ℂ)
    (hBasis : IsOrthonormal basis)
    (f : ClassFn G ℂ)
    (hf : IsVirtualCharacter basis f) :
    ∀ i, decodeMultiplicities f basis i = ↑((hf.choose) i) := by
      intro i;
      convert multiplicity_eq_cfInner_of_virtual_character basis hBasis f hf i using 1

/-
The decoder is linear in the input class function.
-/
theorem decodeMultiplicities_add
    {ι : Type*} [Fintype ι]
    (f g : ClassFn G ℂ) (basis : ι → ClassFn G ℂ) (i : ι) :
    decodeMultiplicities (f + g) basis i =
      decodeMultiplicities f basis i + decodeMultiplicities g basis i := by
        apply ClassFn.cfInner_add_left

/-
The decoder respects scalar multiplication.
-/
theorem decodeMultiplicities_smul
    {ι : Type*} [Fintype ι]
    (c : ℂ) (f : ClassFn G ℂ) (basis : ι → ClassFn G ℂ) (i : ι) :
    decodeMultiplicities (c • f) basis i =
      c * decodeMultiplicities f basis i := by
        convert ClassFn.cfInner_smul_left c f ( basis i ) using 1

/-! ## Falsifiable Conjecture: Spectral Sparsity

For a finite group G, define a natural graded packet from symmetric powers.
The following conjecture is computationally testable and could be false.

**Conjecture**: For G = A₅ and V its 3-dimensional irreducible representation,
the multiplicity sequence of each irreducible character inside Symⁿ(V) is eventually
log-concave in n.

This is stated as a definition (not a theorem) because it is a conjecture to be
tested computationally. See `demo.py` for the computational verification. -/

/-- A sequence is log-concave at index n if a(n)² ≥ a(n-1) * a(n+1). -/
def IsLogConcaveAt (a : ℕ → ℝ) (n : ℕ) : Prop :=
  a n ^ 2 ≥ a (n - 1) * a (n + 1)

/-- A sequence is eventually log-concave if there exists N such that it is
log-concave at all n ≥ N. -/
def IsEventuallyLogConcave (a : ℕ → ℝ) : Prop :=
  ∃ N, ∀ n, n ≥ N → IsLogConcaveAt a n

end