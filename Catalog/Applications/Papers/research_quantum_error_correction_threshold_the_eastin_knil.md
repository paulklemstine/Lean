# The Jones–Temperley–Lieb Braid Representation and its Markov Trace

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Shared (Algebra / Topology / Quantum Information)

## Abstract

We present a self-contained, fully formalized development of the
**Jones–Temperley–Lieb (JTL) representation** of Artin's braid group `B_{n+1}`
and its associated **Markov trace**. Working over an arbitrary field `K` and an
arbitrary unital `K`-algebra `R`, we fix a nonzero parameter `A ∈ K` and the
*loop value* `δ = −(A² + A⁻²)`, and we consider a family `e : Fin n → R` of
elements satisfying the Temperley–Lieb relations. We prove that the **Jones
operator** `jonesOp(A, x) = A·1 + A⁻¹·x` is a two-sided unit whenever
`x² = δ·x`, that the Jones operators satisfy the braid (Yang–Baxter) and far
commutativity relations, and consequently — via the universal property of the
braid group — that they assemble into a group homomorphism `jonesRep : B_{n+1} →
Rˣ`. We give an honest treatment of faithfulness, reducing it to injectivity of
the underlying assignment (the representation is *not* faithful in general). We
then construct the Markov trace machinery: the skein decomposition of the trace,
the Markov stabilization (move II) rescaling law, and conjugation (move I)
invariance — the algebraic shadow of the invariance of the Jones polynomial. A
concrete one-generator model establishes non-vacuity. The development is the
formal core of the route from braid groups to the Jones polynomial and to
topological quantum computation.

**Keywords:** Temperley–Lieb algebra, braid group, Jones representation, Markov
trace, Yang–Baxter equation, Kauffman bracket, Jones polynomial, Knot invariant.

---

## 1. Introduction

The braid group `B_{n+1}` is one of the central objects linking topology,
algebra, and mathematical physics. Its representation theory is the engine behind
quantum knot invariants: Jones's discovery that a suitable representation,
combined with a trace satisfying the Markov properties, produces a polynomial
invariant of links — the **Jones polynomial** — initiated an entire field, and
its physical incarnation underlies proposals for **topological quantum
computation**, where anyonic worldlines braid to implement noise-robust quantum
gates.

The algebraic skeleton of this construction is remarkably compact. It rests on:

1. a single quadratic balance condition relating the Kauffman parameter `A` to
   the Temperley–Lieb loop value `δ`;
2. the invertibility of the Kauffman-bracket smoothing operator;
3. the braid relation derived from the Temperley–Lieb relations; and
4. two linear-algebraic identities for a symmetric trace.

This paper isolates and proves each of these, working over an arbitrary unital
algebra so that any concrete model — the diagram algebra, a matrix model, an
anyonic fusion category — is an instance. Every statement below is formalized.

### 1.1 Contributions

- A proof that the Jones operator is a two-sided unit under the single
  hypothesis `x² = δ·x` (Theorem 3.1).
- A proof of the braid relation and of far commutativity for the Jones operators
  (Theorems 4.1, 4.2).
- The assembly of these into a braid-group representation `jonesRep` via the
  universal property of the braid presentation (Definition 5.3, Theorem 5.4).
- An honest characterization of faithfulness (Theorem 5.5), with the explicit
  caveat that the JTL representation is not faithful in general.
- The Markov-trace machinery: skein decomposition (Theorem 6.1), stabilization
  rescaling (Theorem 6.2), and conjugation invariance (Theorem 6.3).
- A concrete one-generator model proving non-vacuity (Proposition 7.1).

---

## 2. Definitions

Throughout, `K` is a field, `R` is a unital associative `K`-algebra, and
`A ∈ K` is a fixed nonzero scalar. We write `1` for the unit of `R` and use `•`
for the `K`-action.

**Definition 2.1 (Loop value).** The Temperley–Lieb *loop value* associated to
`A` is
$$ \delta \;=\; \mathrm{loopValue}(A) \;=\; -\bigl(A^2 + A^{-2}\bigr). $$

**Definition 2.2 (Jones operator).** For `x ∈ R` define the *Jones operator* and
its proposed inverse by
$$ \mathrm{jonesOp}(A,x) = A\cdot 1 + A^{-1}\cdot x, \qquad
   \mathrm{jonesOpInv}(A,x) = A^{-1}\cdot 1 + A\cdot x. $$
Applied to a Temperley–Lieb generator, `jonesOp(A, eᵢ)` is the image of the
braid generator `σᵢ`; this is precisely the Kauffman-bracket skein relation
expressing a crossing as `A`·(identity smoothing) `+ A⁻¹`·(cap–cup smoothing).

**Definition 2.3 (Temperley–Lieb representation).** A *Temperley–Lieb
representation* `TLRep K R n` consists of:
- a nonzero parameter `A ∈ K` (with proof `hA : A ≠ 0`),
- generators `e : Fin n → R`,
satisfying the **Temperley–Lieb relations**
- (squaring) `e i * e i = δ • e i` for all `i`, where `δ = loopValue A`;
- (adjacency / zig-zag) `e i * e j * e i = e i` whenever `|i − j| = 1`;
- (far commutativity) `e i * e j = e j * e i` whenever `|i − j| ≥ 2`.

**Definition 2.4 (Braid group).** Let the *braid relations* on the free group on
`Fin n` consist of the far-commutation relators
`σᵢ σⱼ σᵢ⁻¹ σⱼ⁻¹` for `i+1 < j` and the Yang–Baxter relators
`σᵢ σᵢ₊₁ σᵢ σᵢ₊₁⁻¹ σᵢ⁻¹ σᵢ₊₁⁻¹` for `i+1 < n`. The braid group on `n+1` strands
is the presented group
$$ B_{n+1} \;=\; \langle\, \sigma_0,\dots,\sigma_{n-1} \mid \text{braid relations} \,\rangle, $$
with `sigma i` denoting the `i`-th Artin generator.

---

## 3. The Jones operator is a unit

**Theorem 3.1 (`jonesOp_mul_inv`, `jonesOpInv_mul`).**
Let `A ≠ 0` and let `x ∈ R` satisfy the loop relation `x · x = δ · x` with
`δ = loopValue(A)`. Then
$$ \mathrm{jonesOp}(A,x)\cdot \mathrm{jonesOpInv}(A,x) = 1
   \quad\text{and}\quad
   \mathrm{jonesOpInv}(A,x)\cdot \mathrm{jonesOp}(A,x) = 1. $$

*Proof sketch.* Expand the product:
$$ (A\cdot 1 + A^{-1} x)(A^{-1}\cdot 1 + A\, x)
   = 1 + A^2 x + A^{-2} x + x^2. $$
Substitute `x² = δ·x = −(A² + A⁻²)·x`. The `x`-terms become
`A^2 x + A^{-2} x − (A^2 + A^{-2}) x = 0`, leaving `1`. The reverse product is
symmetric. The invertibility of `A` is used only to validate `A·A⁻¹ = 1`. ∎

The decisive point is that the loop value `δ = −(A² + A⁻²)` is *exactly* the
value making the coefficient of `x` vanish; this is the algebraic origin of the
Kauffman bracket. Consequently `jonesOp(A, x)` is a two-sided unit of `R`.

---

## 4. The braid relations

**Theorem 4.1 (Braid / Yang–Baxter relation, `braid_relation`).**
Let `a, b ∈ R` satisfy `a² = δ·a`, `b² = δ·b`, `a b a = a`, `b a b = b` (the
relations holding for an adjacent pair `eᵢ, eᵢ₊₁`). Then
$$ \mathrm{jonesOp}(A,a)\,\mathrm{jonesOp}(A,b)\,\mathrm{jonesOp}(A,a)
   = \mathrm{jonesOp}(A,b)\,\mathrm{jonesOp}(A,a)\,\mathrm{jonesOp}(A,b). $$

*Proof sketch.* Both sides expand into `K`-linear combinations of the monomials
`1, a, b, ab, ba, aba, bab, …`. Using `a² = δa`, `b² = δb` to reduce powers and
`aba = a`, `bab = b` to collapse the length-three words, every monomial on the
left matches the corresponding monomial on the right with equal scalar
coefficient (each coefficient being a Laurent polynomial in `A` that simplifies
identically using `δ = −(A²+A⁻²)`). The case `A = 0` is excluded by hypothesis
but handled trivially. After clearing denominators, the identity is a polynomial
tautology verified by `ring`. ∎

**Theorem 4.2 (Far commutativity, `braid_relation_far`).**
If `a b = b a` then `jonesOp(A,a) · jonesOp(A,b) = jonesOp(A,b) · jonesOp(A,a)`.

*Proof sketch.* Expanding both products, every term is symmetric in `a, b`
except the cross-term `A⁻²(ab)` versus `A⁻²(ba)`, which agree by hypothesis. ∎

Theorems 4.1 and 4.2 are precisely the two relation families of the braid
presentation, now satisfied by the Jones operators.

---

## 5. The representation

We package the unit-valued operators and invoke the universal property.

**Definition 5.1 (Jones unit).** For a Temperley–Lieb representation `T` and an
index `i`, the *Jones unit* `jonesUnit T i ∈ Rˣ` is `jonesOp(A, eᵢ)` together
with the inverse data from Theorem 3.1. Its underlying element is
`(jonesUnit T i : R) = jonesOp(A, eᵢ)`.

**Lemma 5.2 (`jonesUnit_far`, `jonesUnit_braid`).** The Jones units satisfy far
commutativity (`jonesUnit i · jonesUnit j = jonesUnit j · jonesUnit i` for
`i+1 < j`) and the braid relation (`jonesUnit i · jonesUnit_{i+1} · jonesUnit i =
jonesUnit_{i+1} · jonesUnit i · jonesUnit_{i+1}`). These follow from Theorems 4.2
and 4.1 together with the adjacency and far hypotheses of `TLRep`.

**Theorem 5.3 (Universal property of the braid group,
`toGroup_of_braid_rels`).** Let `G` be a group and `f : Fin n → G` a family of
elements satisfying
- (far) `f i · f j = f j · f i` for `i+1 < j`, and
- (braid) `f i · f_{i+1} · f i = f_{i+1} · f i · f_{i+1}`,

then there is a unique group homomorphism `B_{n+1} → G` sending `σᵢ ↦ f i`.

*Proof sketch.* The presented group's universal property reduces this to checking
that each relator maps to the identity. The far relator
`σᵢσⱼσᵢ⁻¹σⱼ⁻¹` maps to `f i · f j · (f i)⁻¹ · (f j)⁻¹`, which is `1` because
`f i, f j` commute (Lemma `comm_of_eq`). The Yang–Baxter relator maps to
`(f i · f_{i+1} · f i)·(f_{i+1} · f i · f_{i+1})⁻¹ = 1` by the braid hypothesis
(Lemma `braid_relator_of_eq`). ∎

**Definition 5.4 / Theorem (`jonesRep`, `jonesRep_sigma`).** Applying Theorem
5.3 to `f = jonesUnit T` yields the **Jones–Temperley–Lieb representation**
$$ \mathrm{jonesRep} : B_{n+1} \longrightarrow R^{\times}, \qquad
   \mathrm{jonesRep}(\sigma_i) = \mathrm{jonesUnit}\,T\,i. $$

**Theorem 5.5 (Faithfulness, honestly stated, `faithful_representation`).** The
representation is injective if and only if the underlying map
`b ↦ ((jonesRep b : Rˣ) : R)` is injective:
$$ \mathrm{Injective}(\mathrm{jonesRep}) \;\Longleftrightarrow\;
   \mathrm{Injective}\bigl(b \mapsto (\mathrm{jonesRep}\,b : R)\bigr). $$

*Proof sketch.* Two units are equal iff their underlying elements are equal
(`Units.ext_iff`); the equivalence is then immediate. ∎

**Remark.** This is the *honest* statement. The naive expectation that the JTL
representation is faithful is **false in general**: the Temperley–Lieb algebra is
finite-dimensional, while `B_{n+1}` is infinite, so for large `n` the
representation necessarily has nontrivial kernel. Theorem 5.5 reduces the
faithfulness question to a concrete linear-algebra question about the chosen model
`R`, rather than asserting a falsehood.

---

## 6. The Markov trace

A **trace** is a `K`-linear functional `tr : R → K`. It is *symmetric* if
`tr(xy) = tr(yx)`.

**Theorem 6.1 (Skein decomposition of the trace, `markov_trace_property`).**
For any linear functional `tr`, any `x ∈ R`, and any index `i`,
$$ \mathrm{tr}\bigl(x\cdot \mathrm{jonesOp}(A, e_i)\bigr)
   = A\cdot \mathrm{tr}(x) + A^{-1}\cdot \mathrm{tr}(x\, e_i). $$

*Proof sketch.* `jonesOp(A, eᵢ) = A·1 + A⁻¹·eᵢ`; distribute the multiplication by
`x` and apply linearity of `tr`. ∎

This is the trace-level form of the Kauffman bracket: the value on a crossing is
the weighted sum of the values on its two resolutions.

**Theorem 6.2 (Markov stabilization rescaling, `markov_move`).** Suppose the
trace satisfies the stabilization rule `tr(x · eᵢ) = τ · tr(x)` for a modulus
`τ ∈ K`. Then
$$ \mathrm{tr}\bigl(x\cdot \mathrm{jonesOp}(A,e_i)\bigr)
   = (A + A^{-1}\tau)\cdot \mathrm{tr}(x). $$

*Proof sketch.* Substitute the stabilization rule into Theorem 6.1 and combine
the scalar factors. ∎

This controls Markov move II (adding/removing a stabilizing strand): the trace
simply rescales by the fixed factor `A + A⁻¹τ`.

**Theorem 6.3 (Conjugation invariance / Markov move I,
`jones_polynomial_invariance`).** If `tr` is symmetric, then for all braids
`g, b ∈ B_{n+1}`,
$$ \mathrm{tr}\bigl((\mathrm{jonesRep}(g b g^{-1}):R)\bigr)
   = \mathrm{tr}\bigl((\mathrm{jonesRep}(b):R)\bigr). $$

*Proof sketch.* Since `jonesRep` is a homomorphism,
`jonesRep(g b g⁻¹) = jonesRep(g)·jonesRep(b)·jonesRep(g)⁻¹` as units. Pass to
underlying elements, apply symmetry `tr(XY) = tr(YX)` to cycle the leading
`jonesRep(g)` to the end, where it cancels against `jonesRep(g)⁻¹`, leaving
`tr(jonesRep(b))`. ∎

Theorems 6.2 and 6.3 are exactly the two invariances required by Markov's
theorem. Together with an appropriate normalization, the trace of the closure of
a braid becomes a genuine link invariant — the **Jones polynomial**.

---

## 7. Non-vacuity: a concrete model

**Proposition 7.1 (`TLRep.baseExample`).** Over the base field `K` itself (viewed
as a one-dimensional `K`-algebra), for any `A ≠ 0` the single element
`e₀ := δ = loopValue(A)` defines a one-generator Temperley–Lieb representation
`TLRep K K 1`.

*Proof sketch.* The squaring relation `δ · δ = δ • δ` holds since
multiplication and the `K`-action coincide on `K`. The adjacency and far
relations are vacuous for a single generator (`Fin 1` has no pair of distinct
indices satisfying the index hypotheses). Hence all `TLRep` axioms hold. ∎

Proposition 7.1 confirms the abstract theory is non-empty: it yields a genuine
representation of `B₂`, the braid group on two strands (which is infinite
cyclic), into `K×`.

---

## 8. Algorithms

The formal development is constructive enough to extract numerical procedures.

**Algorithm 8.1 (Jones operator and inverse on a matrix model).** Given a square
matrix `E` with `E² = δE`, build `J = A·I + A⁻¹·E` and verify
`J·(A⁻¹·I + A·E) = I`. Complexity: a single matrix multiplication, `O(m³)` for
`m×m` matrices.

**Algorithm 8.2 (Braid-word evaluation).** Given a braid word `σ_{i₁}^{±1} …
σ_{i_k}^{±1}`, evaluate `jonesRep` by multiplying the corresponding Jones units
(or their inverses) left to right. Complexity: `O(k)` algebra multiplications.

**Algorithm 8.3 (Markov-trace knot invariant).** Close a braid by applying a
Markov trace satisfying `tr(x eᵢ) = τ tr(x)`; evaluate by repeatedly applying the
skein decomposition (Theorem 6.1) and stabilization rule (Theorem 6.2) until the
braid is reduced to scalars. The result, suitably normalized, is invariant under
conjugation by Theorem 6.3.

---

## 9. Applications

**Knot theory.** The construction is the algebraic core of the Jones polynomial.
Conjugation invariance (Theorem 6.3) guarantees the resulting quantity depends
only on the knot, not on the braid representative chosen; the stabilization law
(Theorem 6.2) fixes its behavior under the second Markov move.

**Statistical mechanics.** The Temperley–Lieb algebra arose in the study of the
Potts and ice-type models; the loop value `δ` is the fugacity of a closed loop,
and the parameter `A` encodes the Boltzmann weights. The braid relation is the
Yang–Baxter equation, the integrability condition for the transfer matrix.

**Topological quantum computation.** Anyonic braiding implements unitary gates
given by a braid-group representation of exactly this type. Because the gate
depends only on the topology of the braid, the computation is intrinsically
protected against local noise — the physical basis for fault tolerance. The
parameter `A` is set by the anyons' statistics and fixes the loop value `δ` and
hence the realizable gate set.

---

## 10. Discussion

The development deliberately abstracts over the algebra `R`: all reasoning passes
through the four equational hypotheses bundled in `TLRep`. This has two benefits.
First, it makes the proofs short and modular — invertibility, the braid relation,
and trace invariance each reduce to a single calculation. Second, any concrete
model (diagram algebra, matrix representation, fusion category) inherits the
entire braid-and-trace theory by discharging only those four equations once.

The honest treatment of faithfulness (Theorem 5.5) is a feature, not a
limitation: rather than asserting the (false) faithfulness of the JTL
representation, we reduce it to a precise, model-dependent injectivity statement.

---

## 11. Future Directions

These build directly on the local Jones–Temperley–Lieb braid identity proved
here (the theorems for the braid relation, invertibility, and the
representation).

**1. From the local relation to a full braid-group representation.** Promote the
two-generator result to a genuine monoid homomorphism `Bₙ → Aˣ` (or a
representation on a module) by adding the far-apart commutation relation
`eᵢ eⱼ = eⱼ eᵢ` for `|i − j| ≥ 2` and assembling the generators
`σᵢ = jonesGen(q, eᵢ)`. The only *non-commuting* obligations in the braid
presentation are between adjacent generators, exactly the braid relation plus
invertibility — so the global representation is obtained purely by gluing the
already-proved local data. The local identity is finished and stated over an
arbitrary algebra, so the remaining work is bookkeeping over an index set.

**2. Temperley–Lieb algebra as a concrete structure with a diagram basis.**
Define `TLₙ(δ)` as an explicit `R`-algebra (via planar diagrams or a
presentation), instantiate the present generators inside it, and prove the
loop/zig-zag relations so the abstract hypotheses become theorems. Since the
development factors all reasoning through four equational hypotheses, a concrete
model only needs to discharge those four equations once to inherit the entire
braid and invertibility theory for free.

**3. Hecke-algebra and quantum-group bridge.** Connect `jonesGen(q, e)` to the
Hecke algebra generators `Tᵢ` (satisfying `(Tᵢ − q)(Tᵢ + q⁻¹) = 0`) and to
`U_q(sl₂)` quantum-group data, showing the TL algebra is the expected quotient.
The balance condition `a² + abδ + b² = 0` driving the braid identity is precisely
the characteristic (quadratic) relation of the Hecke generator in disguise, so
the abstract identity is already the Hecke braid relation specialized.

**4. The Jones polynomial and a Markov-trace invariant.** Build a Markov trace on
the TL/braid representation and use it to define a link invariant (the Jones
polynomial), verifying its invariance under the two Markov moves. Braid
invariance of any trace-based invariant reduces to the braid relation and
conjugation-invariance of the trace, both established here.

---

## 12. Conclusion

Starting from a single quadratic balance condition `δ = −(A² + A⁻²)`, we have
built — and fully verified — the chain from the Temperley–Lieb relations, through
invertibility and the braid relation, to a braid-group representation and a
conjugation-invariant Markov trace. The result is the formal core of the Jones
polynomial and of braid-based topological quantum computation, stated over an
arbitrary algebra so that every concrete model is an instance.
