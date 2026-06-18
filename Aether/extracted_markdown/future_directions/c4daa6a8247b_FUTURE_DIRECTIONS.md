# Future Directions: Tensor Invariants and Mumford–Tate Groups

## Conjecture 1: Degree-4 Detection of the CM Dichotomy

**Precise statement.** For every 2-dimensional weight-1 rational Hodge structure $H$, the finite-level tensor-invariant stabilizer at degree 4 already separates the CM and non-CM cases:

$$\mathrm{MT}_{\leq 4}(H) = \begin{cases} \mathrm{GL}_2 & \text{if } H \text{ is non-CM}, \\ \text{a proper subgroup} & \text{if } H \text{ has CM}. \end{cases}$$

**Test.** Enumerate all Hodge classes in $W^{\otimes p} \otimes (W^\vee)^{\otimes q}$ for $p + q \leq 4$ for both CM and non-CM structures in dimension 2. Verify computationally that every non-CM structure has Hodge classes generated entirely by contractions, while every CM structure produces at least one additional independent class at degree $(1,1)$.

**Refutation criterion.** The conjecture fails if either: (a) a CM structure exists where all Hodge classes up to degree 4 are contraction-generated, or (b) a non-CM structure produces extra independent Hodge classes at degree ≤ 4.

**Impact.** If true, this gives a finite algorithm for CM detection: compute finitely many tensor invariants and check dimensions. This would be the first verified finite test for CM, replacing the current reliance on transcendence-theoretic arguments.

---

## Conjecture 2: Symplectic Recovery from Polarized Hodge Structures

**Precise statement.** For a polarized weight-1 Hodge structure $(W, \psi)$ of dimension 2 without CM, the degree-4 tensor-invariant stabilizer recovers exactly the group of symplectic similitudes:

$$\mathrm{MT}_{\leq 4}(W, \psi) = \mathrm{GSp}(W, \psi)$$

In particular, including the polarization form $\psi \in \Lambda^2 W^\vee$ as an additional tensor invariant cuts the stabilizer from $\mathrm{GL}_2$ down to $\mathrm{GSp}_2 = \mathrm{GL}_2$ (which happens to coincide in dimension 2, but differs in higher dimensions).

**Test.** Formalize the polarized Hodge structure in Lean, including the alternating form $\psi$ as an element of $W^\vee \otimes W^\vee$. Compute the stabilizer of $\{\mathrm{Id}, \psi\}$ and verify it equals $\mathrm{GSp}_2$.

**Refutation criterion.** The conjecture fails if the stabilizer of the polarization and identity is strictly larger or smaller than $\mathrm{GSp}_2$.

**Impact.** This would extend the tensor-invariant framework to polarized abelian varieties, connecting to the theory of Shimura varieties and the André–Oort conjecture.

---

## Conjecture 3: Higher-Dimensional Generalization ($g = 2$)

**Precise statement.** For a generic 4-dimensional weight-1 polarized Hodge structure (corresponding to a genus-2 curve), the degree-6 tensor-invariant stabilizer recovers $\mathrm{GSp}_4$:

$$\mathrm{MT}_{\leq 6}(H) = \mathrm{GSp}_4$$

For a CM abelian surface with $\mathrm{End}(A) \otimes \mathbb{Q} = K$ (a CM field of degree 4), the stabilizer shrinks to $\mathrm{Res}_{K_0/\mathbb{Q}} \mathbb{G}_m$ where $K_0$ is the maximal totally real subfield.

**Test.** Implement the 4-dimensional analogue of the tensor invariant enumerator. Compute Hodge endomorphism algebras for: (a) generic genus-2 curves, (b) products of elliptic curves, (c) simple abelian surfaces with quaternionic multiplication.

**Refutation criterion.** Any of these three cases yielding an unexpected stabilizer dimension would refute the conjecture. In particular, degree 6 might not suffice for full recovery in genus 2.

**Impact.** Extending the formalization to $g = 2$ would cover the Mumford–Tate classification for all abelian surfaces, a key open target in formalized arithmetic geometry.

---

## Conjecture 4: Commutant Detection from Finite Tensor Data

**Precise statement.** For any finite-dimensional $\mathbb{Q}$-algebra $A \subseteq \mathrm{End}(W)$ and any $N \geq 2 \dim(W)$, the centralizer of $A$ in $\mathrm{GL}(W)$ equals the pointwise stabilizer of Hodge classes up to degree $N$:

$$\{g \in \mathrm{GL}(W) \mid g a = a g \text{ for all } a \in A\} = \mathrm{MT}_{\leq N}(W)$$

where the Hodge endomorphism algebra is $A$.

**Test.** For $W = \mathbb{Q}^n$ with $n = 2, 3, 4$ and various subalgebras $A$ (scalars, split semisimple, non-split quadratic extensions, matrix subalgebras), compute both sides and compare.

**Refutation criterion.** Find $A$ and $N = 2\dim(W)$ where the centralizer of $A$ in $\mathrm{GL}(W)$ differs from the pointwise tensor stabilizer.

**Impact.** This would establish that the tensor-invariant framework is computationally complete: any symmetry detectable by commutant theory is also detectable by finite tensor inspection. This bridges invariant theory and Tannakian reconstruction.

---

## Conjecture 5: Algorithmic Period Classification via Tensor Invariants

**Precise statement.** There exists an algorithm that, given a period matrix $\Omega$ of an abelian variety $A$ to precision $\epsilon$, determines the Mumford–Tate group $\mathrm{MT}(A)$ in time polynomial in $\log(1/\epsilon)$ and $\dim(A)$.

The algorithm works by:
1. Computing candidate Hodge-compatible endomorphisms from $\Omega$
2. Testing commutation relations to build the endomorphism algebra
3. Computing the centralizer to determine the Mumford–Tate group

**Test.** Implement the algorithm for dimension 2 (elliptic curves) and validate against known CM classifications from the LMFDB database. Measure the precision $\epsilon$ required for reliable detection.

**Refutation criterion.** If the required precision grows exponentially with discriminant magnitude, the polynomial-time claim fails for practical inputs.

**Impact.** An efficient period-based Mumford–Tate detector would transform computational arithmetic geometry, enabling automated classification of abelian varieties from their analytic data. Combined with formal verification, this would provide machine-certified symmetry classifications.
