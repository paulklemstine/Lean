# A Semantic Cubical Interface in Lean 4: Path Algebra, Weak Univalence, and Higher Inductive Type Surrogates

## Abstract

We present a formalization of semantic cubical foundations within Lean 4's dependent type theory. Rather than extending the proof assistant's kernel with cubical judgmental equality, we define an abstract interval type class, path objects as interval-indexed functions with boundary conditions, and derive key results purely from these definitions. Our main contributions are: (1) a proof of **dependent function extensionality** at the path level, showing that pointwise paths between dependent functions induce paths between the functions themselves; (2) a **weak univalence theorem** for a concrete finite universe of type codes, establishing that equivalence of interpretations implies equality of normalized codes; and (3) **higher inductive type surrogates** for the circle, suspension, and torus, with verified recursion principles and uniqueness theorems. All results are fully machine-verified with no axioms beyond the standard `propext`, `Quot.sound`, and `Classical.choice`.

**Keywords:** homotopy type theory, cubical semantics, function extensionality, univalence, higher inductive types, formalization, Lean 4

---

## 1. Introduction

### 1.1 Motivation

Homotopy type theory (HoTT) enriches Martin-Löf type theory with a topological interpretation of types as spaces and identity types as path spaces. The **univalence axiom** of Voevodsky asserts that equivalent types are equal, and **higher inductive types** (HITs) provide constructors for types with prescribed path structure. Cubical type theory (Cohen–Coquand–Huber–Mörtberg, 2018) gives computational content to these principles via an interval type with De Morgan structure and Kan-style filling operations.

However, standard proof assistants like Lean 4 and Coq use intensional Martin-Löf type theory without native cubical operations. This raises the question: **how much of cubical reasoning can be recovered semantically**, by defining interval and path objects within the existing type theory and proving theorems from their definitions?

### 1.2 Contributions

We answer this question affirmatively for a significant fragment:

1. **Abstract path algebra** (§3): We define `CubicalInterval I` as a type class with endpoints `i0, i1 : I` and reversal `rev : I → I`, and `PathOver A a₀ a₁` as the subtype `{ p : I → A // p i0 = a₀ ∧ p i1 = a₁ }`. We prove path extensionality, eta, functoriality of `ap`, and reparametrization invariance.

2. **Function extensionality from paths** (§4): We prove that pointwise paths `h(x) : PathOver (β x) (f x) (g x)` induce a path `PathOver ((x : α) → β x) f g`. The construction is `⟨λ i x, (h x).val i, ...⟩`.

3. **Weak univalence** (§5): For a universe `UCode` of finite types with interpretation `El`, we define a normalization function to canonical forms and prove: (a) normalization is idempotent, (b) `El c ≃ El (normalize c)`, and (c) if two normalized codes have equivalent interpretations, they are equal.

4. **HIT surrogates** (§6): We define circle, suspension, and torus types via algebraic signatures, construct concrete models, and prove recursion principles with uniqueness.

### 1.3 Related Work

- **Cubical Agda** (Vezzosi–Mörtberg–Abel, 2019): Full cubical type theory with native interval, composition, and Glue types. Our work extracts a semantic fragment without kernel extensions.
- **HoTT Book** (Univalent Foundations Program, 2013): Axiomatizes univalence and HITs. We prove weak univalence computationally for a concrete universe.
- **Lean-HoTT** (van Doorn–von Raumer–Buchholtz, 2017): HoTT formalization in Lean 2. Our approach targets Lean 4 with Mathlib integration.
- **1lab** (Amelia, ongoing): Cubical Agda library for synthetic homotopy theory. Our work provides a bridge for Lean users.

---

## 2. Definitions and Notation

### 2.1 Cubical Interval

```
class CubicalInterval (I : Type u) where
  i0 : I                        -- left endpoint
  i1 : I                        -- right endpoint
  rev : I → I                   -- reversal
  rev_i0 : rev i0 = i1          -- reversal boundary
  rev_i1 : rev i1 = i0
```

**Instances.** `Bool` with `i0 = false, i1 = true, rev = (! ·)` and `Fin 2` with `i0 = 0, i1 = 1, rev i = 1 - i`.

### 2.2 Path Over

```
def PathOver (A : Type v) (a₀ a₁ : A) : Type (max u v) :=
  { p : I → A // p i0 = a₀ ∧ p i1 = a₁ }
```

This is the semantic analogue of the identity type `a₀ =_A a₁` in cubical type theory.

### 2.3 Universe Codes

```
inductive UCode : Type
  | zero | one | bool
  | sum  : UCode → UCode → UCode
  | prod : UCode → UCode → UCode

def El : UCode → Type           -- interpretation
def card : UCode → ℕ             -- cardinality
def canonical : ℕ → UCode        -- canonical form
def normalize (c : UCode) := canonical (card c)
```

---

## 3. Path Algebra

### 3.1 Basic Operations

**Reflexivity.** `reflPath a := ⟨λ _, a, rfl, rfl⟩`

**Symmetry.** `pathSymm p := ⟨p.val ∘ rev, ...⟩` with boundary conditions derived from `rev_i0` and `rev_i1`.

**Functorial action.** `ap f p := ⟨f ∘ p.val, ...⟩`

### 3.2 Main Theorems

**Theorem 3.1 (Path Extensionality).** If `∀ i, p.val i = q.val i`, then `p = q`.
*Proof.* By `Subtype.ext` and `funext`. □

**Theorem 3.2 (Functoriality of ap).** `ap (g ∘ f) p = ap g (ap f p)`.
*Proof.* By `Subtype.ext` with `rfl` (both sides have underlying function `g ∘ f ∘ p.val`). □

**Theorem 3.3 (ap preserves identity).** `ap id p = p`.
*Proof.* By `Subtype.ext` with `rfl`. □

**Theorem 3.4 (ap on constant paths).** `ap f (reflPath a) = reflPath (f a)`.
*Proof.* By `Subtype.ext` and `funext`. □

**Theorem 3.5 (Symmetry involution).** If `rev` is an involution, `pathSymm (pathSymm p) = p`.
*Proof.* By path extensionality: `(pathSymm (pathSymm p)).val i = p.val (rev (rev i)) = p.val i`. □

**Theorem 3.6 (Reparametrization).** For endpoint-preserving `φ, ψ`:
`pathReparam (pathReparam p φ) ψ = pathReparam p (φ ∘ ψ)`.
*Proof.* By path extensionality with `rfl` (composition is associative). □

---

## 4. Function Extensionality

### 4.1 The Construction

**Theorem 4.1 (Dependent funext from paths).** Given `h : ∀ x, PathOver (β x) (f x) (g x)`, there exists `PathOver ((x : α) → β x) f g`.

*Construction.* Define `p : I → (x : α) → β x` by `p i x := (h x).val i`. The boundary conditions are:
- `p i0 = f`: by `funext`, since `p i0 x = (h x).val i0 = f x`
- `p i1 = g`: by `funext`, since `p i1 x = (h x).val i1 = g x`

*Significance.* This theorem demonstrates that the path formalism has enough coherence to recover function extensionality—one of the central principles of extensional type theory—from the structural properties of interval-indexed maps.

### 4.2 Non-dependent Specialization

**Corollary 4.2.** The non-dependent version follows by specializing `β` to a constant family.

### 4.3 Discussion

The construction is natural from the cubical perspective: it simply swaps the order of quantification from `∀ x, (I → β x)` to `I → (∀ x, β x)`. The boundary conditions follow from the pointwise boundary conditions via `funext`. This works for **any** cubical interval `I`, not just `Bool`.

---

## 5. Weak Univalence

### 5.1 Universe Code Normalization

**Definition 5.1.** The canonical code for cardinality n is:
- `canonical 0 = .zero`
- `canonical 1 = .one`  
- `canonical (n+2) = .sum .one (canonical (n+1))`

**Theorem 5.2 (Cardinality correctness).** `card (canonical n) = n`.
*Proof.* By strong induction on n. □

**Theorem 5.3 (Idempotence).** `normalize (normalize c) = normalize c`.
*Proof.* `normalize (normalize c) = canonical (card (canonical (card c))) = canonical (card c) = normalize c`, using Theorem 5.2. □

**Theorem 5.4 (Injectivity).** `canonical` is injective.
*Proof.* If `canonical n = canonical m`, then `n = card (canonical n) = card (canonical m) = m`. □

### 5.2 Type-Theoretic Properties

**Instance 5.5.** `El c` has `Fintype` and `DecidableEq` instances for all codes `c`, defined by recursion on the code structure.

**Theorem 5.6.** `card c = Fintype.card (El c)`.
*Proof.* By induction, using `Fintype.card_sum` and `Fintype.card_prod`. □

**Theorem 5.7 (Equivalence preserves cardinality).** `Nonempty (El a ≃ El b) → card a = card b`.
*Proof.* By `Fintype.card_congr` and Theorem 5.6. □

### 5.3 Main Results

**Theorem 5.8 (El-normalize equivalence).** `El c ≃ El (normalize c)`.
*Proof.* By `Fintype.equivOfCardEq`, since both sides have cardinality `card c`. □

**Theorem 5.9 (Weak univalence).** If `Nonempty (El a ≃ El b)`, `normalize a = a`, and `normalize b = b`, then `a = b`.
*Proof.* From the hypotheses, `a = canonical (card a)` and `b = canonical (card b)`. By Theorem 5.7, `card a = card b`. Therefore `a = canonical (card a) = canonical (card b) = b`. □

**Theorem 5.10 (Path-level weak univalence).** `Nonempty (El a ≃ El b)` implies `PathOver UCode (normalize a) (normalize b)`.
*Proof.* Since `normalize a = normalize b` (both equal `canonical (card a) = canonical (card b)`), the reflexivity path suffices. □

### 5.4 Complexity Analysis

| Operation | Time | Space |
|-----------|------|-------|
| `card c` | O(|c|) | O(depth(c)) |
| `canonical n` | O(n) | O(n) |
| `normalize c` | O(|c| + card(c)) | O(card(c)) |
| `are_equivalent a b` | O(|a| + |b|) | O(depth) |

---

## 6. Higher Inductive Type Surrogates

### 6.1 Suspension

**Construction.** `Susp A := Quot (SuspRel A)` where `SuspRel A` identifies `SuspPre.north` with `SuspPre.south` for each `a : A`.

**Theorem 6.1 (Recursion).** Given `n, s : X` and `m : A → n = s`, there exists a unique `f : Susp A → X` with `f north = n` and `f south = s`.
*Proof.* Existence by `Quot.lift`; uniqueness by `Quot.ind` on both constructors. □

**Theorem 6.2.** `Susp Empty ≃ Bool`.
*Proof.* When `A = Empty`, no meridians exist, so `Quot.mk .north ≠ Quot.mk .south`, giving a bijection with `Bool`. □

**Theorem 6.3.** When `A` is nonempty, `Susp A` has exactly one element.
*Proof.* For any `a : A`, `north = south` by `merid_eq a`. All elements reduce to `north` or `south` by `Quot.ind`. □

### 6.2 Circle

**Model.** `S1 := Unit` (0-truncation). Recursion: `S1.rec' x₀ ℓ := λ _, x₀`.

**Theorem 6.4 (Recursion uniqueness).** Any `f : S1 → X` with `f base = x₀` equals `S1.rec' x₀ ℓ`.

### 6.3 Torus

**Model.** `T2 := Unit` with commuting loops `p, q : base = base`.

**Theorem 6.5 (Recursion uniqueness).** Any `f : T2 → X` with `f base = x₀` equals `T2.rec' x₀ p q comm`.

### 6.4 Circle and Torus Algebra

We define `CircleAlgebra I` and `TorusAlgebra` as structures packaging the type, base point, loops, and (for the torus) commutation witness. We prove that S1 and T2 are initial objects in their respective categories of algebras, with unique morphisms to any other algebra.

---

## 7. Applications

### 7.1 Schema Migration

Universe code normalization provides certified schema migration for finite data types. Two type representations are safely interchangeable iff they normalize to the same canonical form.

### 7.2 Verified Refactoring

The weak univalence theorem certifies algebraic data type refactoring: `(A + Empty) × B` can be safely replaced by `A × B` since they have equal cardinalities and thus equal normal forms.

### 7.3 Path-Based Function Transformation

Function extensionality from paths provides a framework for continuous function transformation: given pointwise interpolations between functions, the funext construction produces a global transformation path.

---

## 8. Discussion

### 8.1 Limitations

1. **0-truncation.** In Lean 4's intensional type theory, all types are 0-truncated: the only structure on identity types is reflexivity. This means the circle and torus surrogates are contractible. Full homotopical content requires a higher-dimensional type theory.

2. **No composition.** Full cubical type theory includes composition and filling operations that enable path concatenation and transport. Our semantic interface has reversal but not general composition.

3. **Finite universe.** The weak univalence theorem applies only to a fixed finite universe of codes. Extension to function types, dependent types, or infinite types requires significantly more machinery.

### 8.2 Strengths

1. **No kernel modifications.** The entire development works within standard Lean 4 + Mathlib.

2. **Generality.** The path algebra theorems hold for any cubical interval, not just Bool.

3. **Computability.** All constructions are computable (modulo `Classical.choice` for some equivalences).

4. **Extensibility.** The `CubicalInterval` type class can be extended with additional structure (connections, composition, filling) to capture richer cubical semantics.

---

## 9. Future Work

See FUTURE_DIRECTIONS.md for detailed research targets. Key directions include:

1. Adding composition/filling operations to recover path concatenation
2. Extending weak univalence to function types and dependent sums
3. Synthetic fundamental group calculations for circle-like types
4. Connections to categorical semantics via path objects in model categories

---

## 10. References

1. Cohen, C., Coquand, T., Huber, S., Mörtberg, A. (2018). Cubical Type Theory: a constructive interpretation of the univalence axiom. *TYPES 2015*, LIPIcs 69.

2. Univalent Foundations Program (2013). *Homotopy Type Theory: Univalent Foundations of Mathematics*. Institute for Advanced Study.

3. Voevodsky, V. (2006). A very short note on homotopy λ-calculus. Unpublished note.

4. Vezzosi, A., Mörtberg, A., Abel, A. (2019). Cubical Agda: A Dependently Typed Programming Language with Univalence and Higher Inductive Types. *ICFP 2019*.

5. van Doorn, F., von Raumer, J., Buchholtz, U. (2017). Homotopy Type Theory in Lean. *ITP 2017*, Springer LNCS 10499.

6. Awodey, S., Warren, M.A. (2009). Homotopy theoretic models of identity types. *Mathematical Proceedings of the Cambridge Philosophical Society* 146(1), 45–55.

7. Licata, D.R., Shulman, M. (2013). Calculating the fundamental group of the circle in homotopy type theory. *LICS 2013*, IEEE.
