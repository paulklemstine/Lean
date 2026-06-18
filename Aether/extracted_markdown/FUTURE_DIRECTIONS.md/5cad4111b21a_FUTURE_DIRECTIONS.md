# Future Directions: Toward Formal Class Field Theory and Abelian Langlands

This document identifies five specific, testable scientific hypotheses that build directly on the formal infrastructure established in this work. Each conjecture is falsifiable and comes with a concrete test that can be carried out in subsequent research cycles.

---

## 1. Artin Map Surjectivity in Finite Unramified Abelian Extensions

**Conjecture**: For every number field `K` and every finite extension `L/K` that is Galois, abelian, and everywhere unramified, there exists a canonical surjective group homomorphism from `ClassGroup (𝓞 K)` onto `Gal(L/K)`, whose kernel corresponds to the ideal classes that capitulate in `L`.

**Test**: Starting from our `IsHilbertClassField` structure, weaken the axiom `artinIso` to require only a surjective homomorphism `ClassGroup (𝓞 K) →* (L ≃ₐ[K] L)`. Define the capitulation kernel as the set of classes that map to the identity. Prove that `Fintype.card (L ≃ₐ[K] L) ≤ Fintype.card (ClassGroup (𝓞 K))` for unramified abelian extensions (without the full isomorphism axiom). Verify in explicit cases: ℚ(√-5)/ℚ and the genus field of ℚ(√-23).

**Impact**: This would formalize the Artin reciprocity map in the unramified setting, providing the first machine-verified statement of class field theory beyond the abelian-over-ℚ case. It would enable formal proofs about the structure of unramified abelian extensions and open the door to ray class field theory.

---

## 2. Imaginary Quadratic CM Generator Formalization

**Conjecture**: For an imaginary quadratic field `K = ℚ(√d)` with `d < 0` squarefree, the minimal polynomial of any CM j-invariant `j(𝓞_K)` has degree exactly `Fintype.card (ClassGroup (𝓞 K))`, and the splitting field of this polynomial over `K` is an `IsHilbertClassField K L`.

**Test**: 
1. Define the Hilbert class polynomial `H_D(x)` as a formal object in Lean (initially as an axiomatized polynomial of specified degree).
2. Prove `natDegree H_D = Fintype.card (ClassGroup (𝓞 K))` for the five discriminants D = -4, -8, -3, -7, -11 where explicit formulas are known.
3. Verify that the splitting field satisfies all axioms of `IsHilbertClassField`.

**Impact**: This would be the first formal verification connecting class field theory to complex multiplication and modular functions. It directly addresses Hilbert's 12th problem in the one setting where the answer is classically known, creating a template for formal CM theory.

---

## 3. Capitulation Kernel Detection

**Conjecture**: For a finite Galois extension `L/K` of number fields, the extension-of-ideals map `ClassGroup (𝓞 K) → ClassGroup (𝓞 L)` is well-defined as a group homomorphism, and its kernel (the "capitulation kernel") is trivial whenever `L/K` is unramified, abelian, and linearly disjoint from the Hilbert class field of `K` over `K`.

**Test**: 
1. Define the capitulation map formally: for `I : Ideal (𝓞 K)`, send it to the class of `Ideal.map (algebraMap (𝓞 K) (𝓞 L)) I` in `ClassGroup (𝓞 L)`.
2. Prove this is a well-defined group homomorphism.
3. In the special case where `L` is the Hilbert class field itself, prove the kernel equals the entire class group (principal capitulation theorem).
4. Test triviality of the kernel for ℚ(√-5, √-1)/ℚ(√-5) computationally.

**Impact**: The capitulation map is the key homological invariant in class field theory. Formalizing it would enable statements about genus theory, Iwasawa theory, and the behavior of ideal classes under field extensions — all prerequisites for deeper arithmetic applications.

---

## 4. Abelian Langlands Shadow Theorem

**Conjecture**: Given `IsHilbertClassField K L`, the function `classGroup_character_to_galois_character` (defined in our formalization) is a bijection between characters `ClassGroup (𝓞 K) →* ℂˣ` and characters `(L ≃ₐ[K] L) →* ℂˣ`. Moreover, this bijection preserves L-functions: the Hecke L-function attached to a class group character equals the Artin L-function of the corresponding Galois character.

**Test**: 
1. Prove that `classGroup_character_to_galois_character` is injective (follows from the Artin iso being an isomorphism).
2. Prove surjectivity by constructing the inverse map.
3. For the simpler claim (without L-functions): show the set of characters has the same cardinality on both sides.
4. For L-function equality: define formal Dirichlet series and prove the Euler product identity for unramified primes in the quadratic case.

**Impact**: This would be the first formally verified instance of the Langlands correspondence, even in its simplest form. The character bijection is the abelian case of the local-global compatibility that underlies the entire Langlands program. Formalizing even the unramified case would create infrastructure for automorphic forms and Galois representations.

---

## 5. Class Number as Arithmetic Complexity Measure

**Conjecture**: For the ring of integers `𝓞_K` of a number field `K`, the minimum number of generators needed for any ideal `I ⊆ 𝓞_K` is bounded by `max(2, ω(Fintype.card (ClassGroup (𝓞 K))))` where `ω` is the number of distinct prime factors. In particular, every ideal in a Dedekind domain is 2-generated, and the class group controls the "difficulty" of finding these generators.

**Test**: 
1. Formalize the 2-generator theorem for Dedekind domains: every nonzero ideal `I` in a Dedekind domain can be written as `I = Ideal.span {a, b}` for suitable `a, b`.
2. Prove that when `Subsingleton (ClassGroup R)`, every ideal is 1-generated (this follows from our existing theorem).
3. Implement certified ideal arithmetic for ℤ[√-5] and measure proof-term sizes for ideal factorization as a function of the class number.
4. Compare computational complexity of ideal operations across number fields with different class numbers.

**Impact**: This connects formal algebraic number theory to computational complexity and certified algorithms. The 2-generator theorem is a classical result that should be formalizable with current Mathlib infrastructure, and it has direct applications to computational algebra systems that need verified ideal arithmetic.

---

## Cross-Cutting Theme

All five directions share a common structure: they extend the **quotient-first algebraic infrastructure** established in this work (class group as quotient → principality characterization → axiomatic Hilbert class field → character correspondence) toward deeper arithmetic content. The progression is:

1. **Structure** (capitulation map, Artin map) — Directions 1, 3
2. **Instantiation** (CM theory, explicit generators) — Direction 2
3. **Correspondence** (Langlands, characters) — Direction 4
4. **Computation** (certified algorithms, complexity) — Direction 5

Each direction is independently valuable and can be pursued in parallel, but together they form a coherent program toward formal class field theory and the abelian Langlands correspondence.
