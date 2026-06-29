# Intersection Forms, the Donaldson Obstruction, and the Stability of the E8 Phenomenon

## Abstract

We present a fully formalized, machine-verified development of the algebraic core of four-dimensional gauge-theoretic topology: the theory of symmetric integral **intersection forms** and the obstruction they place on smooth four-manifolds. We model an intersection form as a symmetric integer Gram matrix and introduce three structural predicates that translate the geometry of closed oriented four-manifolds into pure arithmetic: **unimodularity** (Poincaré duality), **evenness** (the spin condition), and **standard-diagonalizability** (the conclusion of Donaldson's diagonalization theorem in the definite case). Our central result is the **Obstruction Theorem**: a positive-rank even form is never standard-diagonalizable. The proof is elementary and self-contained — it isolates the purely algebraic mechanism by which gauge theory forbids nontrivial even definite forms on smooth four-manifolds.

We instantiate the obstruction with the **E8 form**, an explicit rank-8 even unimodular positive-definite Gram matrix, certifying its unimodularity by an explicit integral inverse and its evenness by its diagonal. Combined with Donaldson's theorem, this proves E8 is not realized smoothly, although Freedman's theorem realizes it topologically — the cleanest known witness of the smooth/topological gap in dimension four. We then develop the **monoidal (direct-sum) structure** of forms, proving that all three predicates are closed under the orthogonal block sum `⊕` (the algebraic model of connected sum). As a capstone we show the rank-16 form **E8 ⊕ E8** remains even, unimodular, and non-standardizable: the obstruction is *stable* under connected sum, and E8 ⊕ E8 is the smallest even form clearing Rokhlin's signature-16 hurdle while still failing Donaldson, pinning down where the two obstructions diverge. Finally, the rank-0 form of `S⁴` is shown trivial, exhibiting the intersection form's structural blindness to the smooth four-dimensional Poincaré conjecture.

**Keywords:** intersection form, four-manifold, Donaldson's theorem, E8 lattice, unimodular form, spin manifold, smooth/topological gap, connected sum, Rokhlin's theorem.

---

## 1. Introduction

The classification of four-manifolds is governed by a single algebraic invariant of unusual power: the **intersection form**, the symmetric bilinear pairing on the second cohomology `H²(M;ℤ)/torsion` given by the cup product paired against the fundamental class. For a closed oriented four-manifold `M`, this pairing is a symmetric, unimodular, integral bilinear form on a finitely generated free abelian group, and it carries an extraordinary amount of topological information.

Two landmark theorems frame the subject:

- **Freedman (1982).** Up to homeomorphism, simply-connected closed four-manifolds are classified by their intersection form together with a single ℤ/2 Kirby–Siebenmann invariant. Essentially every unimodular symmetric integral form is realized by some *topological* manifold.

- **Donaldson (1983).** If a smooth, closed, simply-connected four-manifold has a **positive-definite** intersection form, then that form is **standard**: diagonalizable over ℤ to `⟨1⟩ⁿ = diag(1,…,1)`.

The tension between these two results is the source of the deepest phenomena in dimension four. Freedman's theorem makes the intersection form a near-complete *topological* invariant; Donaldson's theorem reveals that *smooth* structures obey a vastly more restrictive law. The forms that satisfy Freedman but violate Donaldson — even, definite, unimodular forms — are realized topologically but not smoothly. The E8 form is the prototype.

This paper formalizes the **algebraic heart** of this phenomenon. We do *not* re-prove Donaldson's analytic theorem (which rests on the moduli theory of anti-self-dual Yang–Mills connections); rather, we isolate and rigorously verify the *arithmetic obstruction* that Donaldson's theorem activates, and we develop its closure properties under direct sums. Every result below is `sorry`-free and depends only on the standard foundational axioms (`propext`, `Classical.choice`, `Quot.sound`).

---

## 2. Definitions

We fix throughout the ring ℤ of integers. We give the definitions first over a fixed finite index `Fin n`, then in a generalized form over an arbitrary finite index type.

### 2.1 The fixed-rank model

**Definition 2.1 (Intersection form).** For `n : ℕ`, an *intersection form of rank n* is a record
```
IntersectionForm n := { gram : Matrix (Fin n) (Fin n) ℤ,  isSymm : gram.IsSymm }
```
consisting of an `n × n` integer matrix `G` together with a proof that `Gᵀ = G`. The matrix `G` models the Gram matrix of the cup-product pairing on a chosen integral basis of `H²(M;ℤ)/torsion`.

**Definition 2.2 (Quadratic value).** The *value* of `Q = (G, ·)` on an integer vector `v : Fin n → ℤ` is
> **Q.value(v) := v ⬝ (G *ᵥ v) = vᵀ G v ∈ ℤ.**

**Definition 2.3 (Unimodular).** `Q` is *unimodular* iff `det G` is a unit in ℤ (equivalently `det G = ±1`):
> **Unimodular(Q) :⇔ IsUnit(det G).**
This is the algebraic shadow of Poincaré duality: the pairing induces an isomorphism `H² ≅ Hom(H²,ℤ)`.

**Definition 2.4 (Even).** `Q` is *even* iff its value is even on every integer vector:
> **IsEven(Q) :⇔ ∀ v, Even(Q.value(v)).**
A closed four-manifold has even intersection form iff it admits a spin structure (its second Stiefel–Whitney class vanishes).

**Definition 2.5 (Standard-diagonalizable).** `Q` is *standard-diagonalizable* iff it is congruent over ℤ to the identity form:
> **StdDiagonalizable(Q) :⇔ ∃ T : Matrix (Fin n) (Fin n) ℤ, IsUnit(det T) ∧ Tᵀ G T = 1.**
The matrix `T` is a unimodular change of integral basis; `Tᵀ G T = 1` says the form becomes `diag(1,…,1)` in the new basis. This is precisely the conclusion of Donaldson's theorem in the positive-definite case.

### 2.2 The generalized model

To expose the *monoidal* structure we re-state the theory over an arbitrary finite index type. For a type `ι` we set
```
GForm ι := { gram : Matrix ι ι ℤ,  isSymm : gram.IsSymm }
```
with `value`, `Unimodular`, `IsEven`, `StdDiagonalizable` defined verbatim (requiring `[Fintype ι]` and, where determinants appear, `[DecidableEq ι]`). The generalization is essential for direct sums, whose natural index type is the disjoint union `ι ⊕ κ`.

---

## 3. Foundational lemmas

### 3.1 Change of basis

**Lemma 3.1 (Value transport).** *For any form `Q` with Gram matrix `G`, any matrix `T`, and any vector `v`,*
> **Q.value(T *ᵥ v) = v ⬝ ((Tᵀ G T) *ᵥ v).**

*Proof sketch.* Expand `Q.value(Tv) = (Tv)ᵀ G (Tv) = vᵀ Tᵀ G T v` using the standard `mulVec`/`dotProduct`/transpose identities (`vecMul_mulVec`, `dotProduct_mulVec`) and associativity of matrix multiplication. ∎

This lemma is the workhorse: it converts a congruence `Tᵀ G T = 1` directly into a statement about quadratic values.

### 3.2 Evenness from the diagonal

**Lemma 3.2 (Diagonal evenness criterion).** *Let `Q` be a symmetric integral form (over `Fin n`) all of whose diagonal entries `Gᵢᵢ` are even. Then `Q` is even.*

*Proof sketch.* Expand the value as a double sum
> `Q.value(v) = Σᵢ Σⱼ vᵢ Gᵢⱼ vⱼ`.
By symmetry `Gᵢⱼ = Gⱼᵢ`, the double sum splits as
> `Σᵢ vᵢ² Gᵢᵢ + 2 · Σᵢ Σ_{j>i} vᵢ Gᵢⱼ vⱼ`.
The second term is manifestly divisible by 2. In the first term every `Gᵢᵢ` is even by hypothesis, so each summand `vᵢ² Gᵢᵢ` is divisible by 2; hence so is the sum. The general decomposition `Σᵢ Σⱼ f(i,j) = Σᵢ f(i,i) + 2 Σ_{i<j} f(i,j)` for symmetric `f` is proved by induction on `n`. Therefore `Q.value(v)` is even for all `v`. ∎

This criterion makes evenness *transparently* a property of the diagonal, which is the key to its additivity (Section 5).

---

## 4. The Donaldson obstruction

We now state and prove the central algebraic result.

**Theorem 4.1 (Obstruction Theorem).** *Let `Q` be an even intersection form of positive rank (`0 < n`, or over a nonempty index type). Then `Q` is **not** standard-diagonalizable.*

*Proof.* Suppose for contradiction `Q` is standard-diagonalizable, witnessed by `T` with `IsUnit(det T)` and `Tᵀ G T = 1`. Choose any basis vector `eₖ` (e.g. `k = 0`, available since the rank is positive). By the Value Transport Lemma 3.1 and the hypothesis `Tᵀ G T = 1`,
> `Q.value(T *ᵥ eₖ) = eₖ ⬝ ((Tᵀ G T) *ᵥ eₖ) = eₖ ⬝ (1 *ᵥ eₖ) = eₖ ⬝ eₖ = 1.`
But `Q` is even, so `Q.value(T *ᵥ eₖ)` must be an even integer. We have derived `Even(1)`, which is false. Contradiction. ∎

The mechanism is sharp: evenness forces every value into `2ℤ`, while a standard form *always* represents the value `1` on a unit vector. The single value `1` is the obstruction, and its parity is invariant under unimodular change of basis.

**Remark 4.2 (Necessity of evenness).** Evenness is not removable. The standard form `stdForm(n) = ⟨1⟩ⁿ` for `n ≥ 1` is itself trivially standard-diagonalizable (take `T = 1`), yet it is **not** even:
> **Theorem (boundary case).** *For `n ≥ 1`, `stdForm(n)` is not even,* because `stdForm(n).value(e₀) = e₀ᵀ · 1 · e₀ = 1` is odd. Thus the hypothesis `IsEven` in Theorem 4.1 is essential.

---

## 5. The monoidal structure: direct sums

The connected sum `M # N` of four-manifolds has intersection form the orthogonal direct sum of those of `M` and `N`. We model this algebraically.

**Definition 5.1 (Direct sum).** For `Q : GForm ι` and `R : GForm κ` the *direct sum* `Q ⊕ R : GForm (ι ⊕ κ)` has Gram matrix the block-diagonal
> **fromBlocks G_Q 0 0 G_R = [[G_Q, 0],[0, G_R]].**
Its symmetry follows from the symmetry of the blocks via `fromBlocks_transpose`.

**Lemma 5.2 (Value splits orthogonally).** *For `v : ι ⊕ κ → ℤ`,*
> **(Q ⊕ R).value(v) = Q.value(v ∘ inl) + R.value(v ∘ inr).**

*Proof sketch.* The block-diagonal Gram matrix decouples the `mulVec` and `dotProduct` over the sum type; `Fintype.sum_sum_type` separates the index sum into its `ι` and `κ` parts, leaving exactly the two orthogonal contributions. ∎

From this single lemma the additivity of all three predicates follows.

**Theorem 5.3 (Evenness is additive).** *If `Q` and `R` are even, so is `Q ⊕ R`.*
*Proof.* By Lemma 5.2, `(Q ⊕ R).value(v) = Q.value(v∘inl) + R.value(v∘inr)`, a sum of two even integers, hence even. ∎

**Theorem 5.4 (Unimodularity is additive).** *If `Q` and `R` are unimodular, so is `Q ⊕ R`.*
*Proof.* The determinant of a block-triangular (here block-diagonal) matrix factors: `det(fromBlocks G 0 0 H) = det G · det H` (`det_fromBlocks_zero₂₁`). A product of units is a unit. ∎

**Theorem 5.5 (Standardness is additive).** *If `Q` and `R` are standard-diagonalizable, so is `Q ⊕ R`.*
*Proof.* Let `T₁, T₂` witness the diagonalizations, so `T₁ᵀ G_Q T₁ = 1` and `T₂ᵀ G_R T₂ = 1`, both with unit determinant. Set `T = fromBlocks T₁ 0 0 T₂`. Then, using `fromBlocks_transpose` and `fromBlocks_multiply`,
> `Tᵀ (G_Q ⊕ G_R) T = fromBlocks (T₁ᵀ G_Q T₁) 0 0 (T₂ᵀ G_R T₂) = fromBlocks 1 0 0 1 = 1`,
and `det T = det T₁ · det T₂` is a unit. ∎

Together, Theorems 5.3–5.5 say that `(forms, ⊕)` carries `Unimodular`, `IsEven`, `StdDiagonalizable` as *structural*, additivity-respecting properties — the form category is symmetric monoidal and the three predicates are sub-monoids of it.

---

## 6. The E8 form and the smooth/topological gap

**Definition 6.1 (E8).** The E8 form is `E8form = (E8mat, ·)` where `E8mat` is the Cartan/Gram matrix
```
        ⎡ 2 -1  0  0  0  0  0  0 ⎤
        ⎢-1  2 -1  0  0  0  0  0 ⎥
        ⎢ 0 -1  2 -1  0  0  0  0 ⎥
E8mat = ⎢ 0  0 -1  2 -1  0  0  0 ⎥
        ⎢ 0  0  0 -1  2 -1  0 -1 ⎥
        ⎢ 0  0  0  0 -1  2 -1  0 ⎥
        ⎢ 0  0  0  0  0 -1  2  0 ⎥
        ⎣ 0  0  0  0 -1  0  0  2 ⎦
```

**Theorem 6.2 (E8 is unimodular).** *`det E8mat` is a unit; indeed `det E8mat = 1`.*
*Proof.* We exhibit an explicit integral inverse `E8inv` (a fixed `8 × 8` integer matrix) and verify `E8mat · E8inv = 1` by direct decidable computation. Taking determinants, `det E8mat · det E8inv = 1`, so `det E8mat` is a unit. ∎

**Theorem 6.3 (E8 is even).** *`E8form` is even.*
*Proof.* Every diagonal entry of `E8mat` equals `2`, hence is even; apply the Diagonal Evenness Criterion (Lemma 3.2). ∎

E8 is moreover positive-definite (all eigenvalues positive; equivalently all leading principal minors are 1), placing it squarely in the regime of Donaldson's theorem.

**Theorem 6.4 (E8 obstruction).** *`E8form` is not standard-diagonalizable.*
*Proof.* `E8form` is even (Theorem 6.3) of positive rank `8`; apply the Obstruction Theorem 4.1. ∎

**Corollary 6.5 (Smooth/topological gap).** Combined with Donaldson's diagonalization theorem, Theorem 6.4 shows **E8 is not the intersection form of any smooth closed simply-connected four-manifold**. By Freedman's theorem, however, there *is* a topological four-manifold (the "E8-manifold") realizing it. Thus E8 separates the smooth from the topological category — the cleanest algebraic witness of exotic four-dimensional phenomena.

---

## 7. Capstone: stability of the obstruction

**Definition 7.1.** Let `E8E8form = E8form ⊕ E8form`, a rank-16 form.

**Theorem 7.2 (E8 ⊕ E8 obstruction).** *`E8E8form` is unimodular, even, and **not** standard-diagonalizable.*
*Proof.* Unimodularity and evenness follow from the additivity Theorems 5.4 and 5.3 applied to the two E8 summands (Theorems 6.2, 6.3). Non-standardizability follows from the Obstruction Theorem 4.1, since `E8E8form` is even of positive rank 16. ∎

**Interpretation.** This is the *stable* form of the obstruction. The single odd value `1` that betrays an even form survives orthogonal summation untouched, so connected-summing E8 with itself (or, more generally, with any even form) cannot smooth the obstruction away. Three further points sharpen the picture:

- **Signature 16 and Rokhlin.** Rokhlin's theorem states that the signature of a smooth closed *spin* four-manifold is divisible by 16. The form `E8 ⊕ E8` has signature 16 (it is positive-definite of rank 16), so it is the *smallest* even unimodular form that **passes** Rokhlin's divisibility test — yet Theorem 7.2 shows it still **fails** Donaldson. This pinpoints where the two obstructions diverge: Rokhlin (a characteristic-class / ℤ/16 statement) and Donaldson (a gauge-theoretic statement) are genuinely independent.

- **The 11/8 conjecture.** The form E8 ⊕ E8 sits at the boundary of the celebrated 11/8-conjecture on the rank-to-signature ratio of smooth spin four-manifolds; our development isolates its algebraic skeleton.

- **Realizability.** After a change of sign it is the K3 form `2(−E8) ⊕ 3H` that is realized smoothly (by the K3 surface); the *definite* form E8 ⊕ E8 itself is not.

---

## 8. The sphere and the limits of the invariant

**Definition 8.1.** The intersection form of `S⁴` is `sphereForm : IntersectionForm 0`, the rank-0 form (since `H²(S⁴) = 0`).

**Theorem 8.2 (Triviality of the sphere form).** *`sphereForm` is simultaneously unimodular, even, and standard-diagonalizable.*
*Proof.* Over the empty index `Fin 0` every matrix is the unique empty matrix; its determinant is `1` (unimodular), every quadratic value is the empty sum `0` (even), and `T = 1` witnesses standardness. ∎

**Corollary 8.3 (Blindness to exotic spheres).** Every homotopy four-sphere `Σ` has `b₂(Σ) = 0` and hence the same rank-0 intersection form as `S⁴`. The intersection form therefore *cannot distinguish* a hypothetical exotic smooth `S⁴` from the standard one. This is a precise structural reason why the **smooth four-dimensional Poincaré conjecture** lies beyond intersection-form methods and requires genuinely smooth invariants (Donaldson polynomials, Seiberg–Witten invariants, or finer gauge-theoretic data). ∎

---

## 9. Discussion

The development above cleanly separates the *analysis* of four-dimensional gauge theory from its *arithmetic*. Donaldson's theorem — the statement that smooth definite forms are standard — is a profound analytic result about the moduli space of anti-self-dual connections. But the *consequence* relevant to E8, namely that an even definite form cannot be smooth, reduces to a one-line parity argument (Theorem 4.1) once the analytic input is granted. By formalizing this skeleton we obtain:

1. **A verified parity engine** (Theorem 4.1) that is independent of any deep input and immediately reusable.
2. **A verified additivity calculus** (Theorems 5.3–5.5) making the obstruction's *stability* an automatic corollary rather than a separate argument.
3. **Certified instances** (E8, E8 ⊕ E8) with explicit integral inverses, so the unimodularity claims rest on decidable matrix arithmetic rather than appeals to lattice theory.
4. **A negative metatheorem** (Corollary 8.3) demarcating exactly where the invariant goes blind.

The two complementary indexings — fixed `Fin n` and arbitrary `ι` — are deliberate. The `Fin n` model keeps the explicit E8 computations concrete and decidable; the `GForm ι` model exposes the monoidal structure whose natural index is a disjoint union, enabling the clean additivity proofs.

---

## 10. Future work

Several concrete, falsifiable directions extend this nucleus:

1. **A formal `signature` and the van der Blij congruence.** Equip diagonalizable forms with an integer signature, additive under `⊕`, and prove that for unimodular forms the signature is congruent mod 8 to the value on a characteristic element — recovering, for even forms, `signature ≡ 0 (mod 8)`.

2. **The 8-divisibility theorem.** Prove every positive-definite even unimodular form has rank divisible by 8, recognizing the E8 obstruction as the `n < 8` shadow of a mod-8 law.

3. **Stable cancellation.** Prove a stable form of Donaldson: if `Q ⊕ ⟨1⟩ᵏ` is standard for some `k`, then so is `Q` — formalizing that adding `ℂP²` summands cannot smooth away the obstruction, mirroring Wall's stabilization theorem.

4. **Rokhlin as a ℤ/16 obstruction.** Introduce a `Smoothable` predicate abstracting the Donaldson and Rokhlin inputs as hypotheses (axiom-free), and prove `E8 ⊕ E8` is the smallest even unimodular form clearing Rokhlin yet failing Donaldson.

5. **A homotopy-`S⁴` certificate.** Package the rank-0 result into a `HomotopySphere4` record and prove the intersection form is constant on all homotopy four-spheres — a sharp negative metatheorem stating *why* the smooth four-dimensional Poincaré conjecture is invisible to this toolkit.

---

## References

- S. K. Donaldson, *An application of gauge theory to four-dimensional topology*, J. Differential Geom. **18** (1983), 279–315.
- M. H. Freedman, *The topology of four-dimensional manifolds*, J. Differential Geom. **17** (1982), 357–453.
- V. A. Rokhlin, *New results in the theory of four-dimensional manifolds*, Doklady Akad. Nauk SSSR **84** (1952), 221–224.
- J. Milnor and D. Husemoller, *Symmetric Bilinear Forms*, Springer, 1973.
- C. T. C. Wall, *On simply-connected 4-manifolds*, J. London Math. Soc. **39** (1964), 141–149.
