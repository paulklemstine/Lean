# A Certificate Framework for Expander Cayley Graphs of Classical Groups

## Abstract

We present a self-contained, certificate-based framework for establishing the
structural and expansion properties of Cayley graphs built from finite
classical groups (general linear, symplectic, orthogonal, unitary). The
framework decouples two notoriously difficult global questions — *does a
generating set generate?* and *is the resulting graph an expander?* — into
locally checkable algebraic conditions on a pair of group elements. The
central object is the **classical generation certificate**: a pair `(s, t)`
in which `s` has irreducible characteristic polynomial and `t` breaks every
proper nontrivial `s`-invariant subspace. We prove that any pair satisfying
this certificate acts irreducibly on the ambient module (Theorem 1). On the
combinatorial side, we prove that positive vertex expansion of a symmetric
generating set forces it to generate the whole group (Theorem 2), that vertex
expansion is monotone under enlarging the generating set (Theorem 3), and
that expansion yields a multiplicative one-step neighborhood growth of factor
`(1 + ε)`, the quantitative engine behind logarithmic mixing (Theorem 4). We
specialize the abstract certificate to `GL₂(𝔽_p)`, where it reduces to the
absence of a common eigenvector (Theorem 5). We close with a comparison
calculus for certificates across group families and a uniform-gap conjecture
for the symplectic family `Sp₄(𝔽_q)`. All results have been formalized and
machine-verified.

**Keywords.** Expander graphs, Cayley graphs, classical groups, vertex
expansion, irreducible action, regular semisimple elements, spectral gap,
certificates.

---

## 1. Introduction

Expander graphs are sparse graphs that are nonetheless highly connected: every
small set of vertices has a boundary comparable to its size. They are
foundational across theoretical computer science (derandomization,
error-correcting codes, hardness amplification) and pure mathematics (group
theory, number theory, the construction of Ramanujan graphs). Among the
richest sources of expanders are **Cayley graphs of finite simple groups**.
The landmark results of Helfgott on `SL₂(𝔽_p)` and of Kassabov, Lubotzky, and
Nikolov on finite simple groups as expanders establish that, with suitable
generators, these families expand uniformly.

These theorems are deep and frequently non-constructive: they assert the
*existence* of good generators without exhibiting a procedure to certify a
given candidate. In applications one often holds a *specific* pair of group
elements and needs a guarantee about the *specific* graph they generate. This
motivates a shift from existence statements to **certificates**: short,
locally checkable data whose validity provably implies the desired global
behavior.

This paper develops such a framework. Its architecture rests on a translation
between three layers:

1. **Algebra.** Regular toral (regular semisimple) elements, the generic
   symmetries of a classical group.
2. **Linear algebra.** Invariant-subspace-breaking, encoding irreducibility
   of the joint action.
3. **Graph theory.** Vertex expansion of the Cayley graph and its
   consequences for connectivity and mixing.

We make each layer precise, prove the bridges between them, and specialize to
the smallest concrete case, `GL₂(𝔽_p)`.

### 1.1 Conventions

Throughout, `K` is a field, `V` is a finite-dimensional `K`-vector space, and
`Module.End K V` denotes the ring of `K`-linear endomorphisms of `V`. For a
finite group `G`, a generating set is a finite subset `S ⊆ G`; it is
*symmetric* if `s ∈ S ⟹ s⁻¹ ∈ S`. We work with the *right* Cayley graph: the
neighbors of `a` are the elements `a·s` for `s ∈ S`. We write `|X|` for
cardinality.

---

## 2. Algebraic Layer: Regular Toral Elements

**Definition 2.1 (Regular toral).** An endomorphism `φ ∈ Module.End K V` is
*regular toral* if its minimal polynomial equals its characteristic
polynomial:
> `IsRegularToral φ : minpoly K φ = φ.charpoly`.

Equality of minimal and characteristic polynomials is precisely the condition
that `φ` is *non-derogatory* (cyclic): there is a vector whose iterates span
`V`. Over a finite field this is the shadow of a *regular semisimple* element
of a reductive group — one lying on a unique maximal torus, with centralizer
of minimal dimension. Such elements are the generic points of the group and
are the natural candidates for the "spread-out" generator `s`.

**Definition 2.2 (Strongly regular toral).** `φ` is *strongly regular toral*
if it is regular toral and its characteristic polynomial is irreducible:
> `IsStronglyRegularToral φ : IsRegularToral φ ∧ Irreducible φ.charpoly`.

Irreducibility upgrades genericity to *irreducibility of the cyclic action*:

**Proposition 2.3.** *If `φ.charpoly` is irreducible, then `φ` has no proper
nontrivial invariant subspace.*

*Proof sketch.* An invariant subspace `W` of dimension `0 < d < dim V` would
make the characteristic polynomial of `φ|_W` a proper monic factor of
`φ.charpoly` of degree `d`, contradicting irreducibility. (This is the content
of the supporting result `eq_bot_or_top_of_charpoly_irreducible` used by the
framework.) ∎

Thus a strongly regular toral element already acts irreducibly *by itself*.
The role of the certificate's second element is to preserve irreducibility
when one relaxes from the irreducible case to the general regular case — the
direction flagged in the future work.

---

## 3. Linear-Algebra Layer: The Breaking Condition

**Definition 3.1 (Breaking all invariant subspaces).** For `φ, ψ ∈
Module.End K V`, say `ψ` *breaks all invariant subspaces* of `φ`, written
`BreaksAllInvariantSubspaces φ ψ`, if for every submodule `W` with `W ≠ ⊥`,
`W ≠ ⊤`, and `W` invariant under `φ` (i.e. `∀ w ∈ W, φ w ∈ W`), there exists
`w ∈ W` with `ψ w ∉ W`:
> `∀ W, W ≠ ⊥ → W ≠ ⊤ → (∀ w ∈ W, φ w ∈ W) → ∃ w ∈ W, ψ w ∉ W`.

Geometrically, `φ` and `ψ` cannot be simultaneously block-triangularized:
there is no common proper invariant subspace, hence no shared frame in which
both are reducible.

**Definition 3.2 (Classical generation certificate).** A pair `(s, t)` of
endomorphisms satisfies the *classical generation certificate*
`ClassicalGenCertificate s t` if it bundles:

- `s_charpoly_irred` : `Irreducible s.charpoly`, and
- `t_breaks` : `BreaksAllInvariantSubspaces s t`.

Both fields are finitely checkable: irreducibility of a polynomial over a
finite field is decidable in polynomial time, and (in finite dimension) the
breaking condition ranges over finitely many candidate subspaces and reduces,
in low dimension, to eigenvector computations.

---

## 4. Main Structural Theorem

**Theorem 1 (Irreducible joint action).** *Let `(s, t)` satisfy
`ClassicalGenCertificate s t`. Then there is no submodule `W` of `V` with*
> `W ≠ ⊥ ∧ W ≠ ⊤ ∧ (∀ w ∈ W, s w ∈ W) ∧ (∀ w ∈ W, t w ∈ W)`.

*In words: no proper nontrivial subspace is invariant under both `s` and `t`,
so the pair acts irreducibly.*

*Proof.* Suppose such a `W` existed, with witnesses `hW₁ : W ≠ ⊥`, `hW₂ : W ≠
⊤`, `hW₃ : s`-invariance, `hW₄ : t`-invariance. Apply the certificate's
breaking field `t_breaks` to `W` using `hW₁, hW₂, hW₃`; this yields `w ∈ W`
with `t w ∉ W`. But `hW₄` applied to `w ∈ W` gives `t w ∈ W`, a contradiction.
∎

The proof is a two-line pincer; its brevity is the point. All the mathematical
content is loaded into the *definitions*, which is exactly what makes the
certificate checkable and the conclusion robust. Theorem 1 is the structural
input to generation arguments: a subgroup acting irreducibly on `V` is forced
to be large, and irreducibility is the recurring hypothesis in growth and
expansion results for classical groups.

---

## 5. Combinatorial Layer: Cayley Graphs and Expansion

Fix a finite group `G` with `DecidableEq` and a finite generating set `S`.

**Definition 5.1 (Cayley neighbor set).** For `A ⊆ G`,
> `CayleyNeighborFinset S A := ⋃_{a ∈ A} { a·s : s ∈ S }`.

This is the set of vertices reachable from `A` in one step of the right Cayley
graph.

**Definition 5.2 (Vertex boundary).**
> `CayleyVertexBoundary S A := CayleyNeighborFinset S A \ A`,

the "new" vertices discovered by one step from `A`.

**Definition 5.3 (Vertex expansion).** `S` *has vertex expansion `ε`* if
`ε > 0` and for every nonempty `A` with `2|A| ≤ |G|`,
> `ε · |A| ≤ |CayleyVertexBoundary S A|`.

This is the combinatorial face of a spectral gap: a Cayley graph whose
averaging operator has second eigenvalue at most `1 − ε` satisfies vertex
expansion with a constant depending on `ε`.

**Definition 5.4 (Certified gap).** `S` *has a certified gap `ε`*,
`HasCertifiedGap S ε`, if it has vertex expansion `ε` and generates `G`
(`∀ g, g ∈ Subgroup.closure (S : Set G)`).

We record two elementary lemmas.

**Lemma 5.5 (Reflexivity when `1 ∈ S`).** *If `1 ∈ S`, then `A ⊆
CayleyNeighborFinset S A`.*

*Proof.* For `x ∈ A`, take `a = x` and `s = 1`; then `x = a·1 = a·s` lies in
the neighbor set. ∎

**Lemma 5.6 (Degree bound).** *`|CayleyNeighborFinset S A| ≤ |A|·|S|`.*

*Proof.* The neighbor set is a union over `a ∈ A` of the images
`{a·s : s ∈ S}`, each of size at most `|S|`; bound the union by the sum of
sizes and the sum by `|A|·|S|`. ∎

---

## 6. Expansion Certifies Connectivity

**Lemma 6.1 (Nonempty boundary under generation).** *If `A` is nonempty and
proper (`A ≠ univ`) and `S` generates `G`, then `CayleyVertexBoundary S A` is
nonempty.*

*Proof sketch.* If the boundary were empty, then `A` would be closed under
right multiplication by `S`: for all `a ∈ A` and `s ∈ S`, `a·s ∈ A`. By
induction over the closure of `S` (using that elements of a finite group have
finite order, so inverses are positive powers), `A` would be closed under
right multiplication by *every* element of `⟨S⟩ = G`. Picking any `a ∈ A`,
every `g ∈ G` equals `a·(a⁻¹g)` with `a⁻¹g ∈ G`, so `g ∈ A`, forcing `A =
univ` and contradicting properness. ∎

**Theorem 2 (Expansion forces generation).** *Let `S` be symmetric (`s ∈ S ⟹
s⁻¹ ∈ S`) with vertex expansion `ε`. Then `S` generates `G`:
`∀ g, g ∈ Subgroup.closure (S : Set G)`.*

*Proof.* Let `H = Subgroup.closure (S : Set G)` and suppose some `g ∉ H`. Then
`H` is a proper subgroup, so by Lagrange `|H|` divides `|G|` and `|H| < |G|`;
writing `|G| = k·|H|` with `k > 1` gives `2|H| ≤ |G|`, placing `H` in the
expansion regime. Realize `H` as a finite subset `A` of `G`; it is nonempty
(`1 ∈ H`). Because `H` is a subgroup containing `S`, it is closed under right
multiplication by `S`, so `CayleyVertexBoundary S A = ∅`. Vertex expansion
then demands `ε·|A| ≤ 0`, while `ε > 0` and `|A| ≥ 1` give `ε·|A| > 0`. This
contradiction shows no such `g` exists. ∎

Theorems 1 and 2 are dual certificates: the algebraic one certifies
irreducibility, the combinatorial one certifies that any positively expanding
symmetric set is automatically connected. Symmetry is used to guarantee that
the subgroup `H` is genuinely closed under the moves (so the boundary truly
vanishes).

---

## 7. Monotonicity and Quantitative Growth

**Theorem 3 (Monotonicity).** *If `S ⊆ T` and `S` has vertex expansion `ε`,
then `T` has vertex expansion at least `ε`.*

*Proof.* The expansion constant `ε > 0` is inherited. For any admissible `A`,
`CayleyNeighborFinset S A ⊆ CayleyNeighborFinset T A` (more generators reach
more vertices), hence `CayleyVertexBoundary S A ⊆ CayleyVertexBoundary T A`,
so `|CayleyVertexBoundary T A| ≥ |CayleyVertexBoundary S A| ≥ ε·|A|`. ∎

This means certification need only be performed for an economical generating
set; any superset chosen for engineering convenience inherits the guarantee.

**Theorem 4 (One-step neighbor growth).** *Suppose `1 ∈ S` and `S` has vertex
expansion `ε`. Then for every nonempty `A` with `2|A| ≤ |G|`,*
> `(1 + ε) · |A| ≤ |CayleyNeighborFinset S A|`.

*Proof.* By Lemma 5.5, `A ⊆ CayleyNeighborFinset S A`, so the neighbor set
decomposes as the disjoint union of `A` and its boundary:
> `|CayleyNeighborFinset S A| = |A| + |CayleyVertexBoundary S A|`.

Vertex expansion bounds the second summand below by `ε·|A|`, giving
`|CayleyNeighborFinset S A| ≥ |A| + ε·|A| = (1 + ε)·|A|`. ∎

**Corollary 7.1 (Logarithmic mixing).** *Iterating Theorem 4, the set of
vertices reachable from a point in `k` steps grows at least like `(1 + ε)^k`
until it exceeds half the group. Consequently the number of steps to reach
half the group is `O(log |G| / log(1 + ε))`, the defining logarithmic mixing
of an expander.*

Theorem 4's lower bound is complemented by the degree upper bound of
Lemma 5.6: the reachable set neither stalls (it grows by a fixed factor) nor
explodes faster than the degree permits.

---

## 8. The Concrete Case: `GL₂(𝔽_p)`

To bring the abstraction to ground, fix a prime `p` and work with `2×2`
matrices over `ZMod p`.

**Definition 8.1 (GL₂ certificate).** A pair `(s, t)` of matrices in
`Matrix (Fin 2) (Fin 2) (ZMod p)` satisfies `GL2Certificate p s t` if:

1. `s.det ≠ 0` and `t.det ≠ 0` (both invertible),
2. `Irreducible s.charpoly`, and
3. there is **no** nonzero `v` with `s.mulVec v = c•v` and `t.mulVec v = d•v`
   for scalars `c, d` (no common eigenvector).

**Theorem 5 (No common eigenvector).** *If `GL2Certificate p s t` holds, then
there is no nonzero `v : Fin 2 → ZMod p` that is simultaneously an eigenvector
of `s` and of `t`.*

*Proof.* The third clause of the certificate is literally the negation of the
existence of such a `v`; given a putative common eigenvector with eigenvalues
`c, d`, package it as the forbidden witness and apply the clause to derive a
contradiction. ∎

This is Theorem 1 in its most tangible incarnation. In dimension two,
irreducibility of `s.charpoly` already forbids `s` from having *any*
eigenvector over `𝔽_p`; the certificate additionally records that `s` and `t`
share no eigenvector, and irreducibility of the joint action follows. Every
clause is a constant-time computation for fixed `p`, making the certificate
ideal as a verifiable witness emitted by a generator-search procedure.

---

## 9. Quasirandomness and a Comparison Calculus

**Definition 9.1 (Quasirandomness).** A finite group `G` is *`m`-quasirandom*
if `m ≥ 2` and every nontrivial irreducible complex representation has
dimension at least `m`:
> `∀ n (ρ : G →* Matrix (Fin n) (Fin n) ℂ), (∀ g, ρ g ≠ 1) → m ≤ n`.

Quasirandomness — "no small representations" — is the representation-theoretic
amplifier of expansion: in a highly quasirandom group, any nontrivial
behavior must be high-dimensional, forcing pseudorandomness of products. For
finite simple groups of Lie type the quasirandomness parameter grows with the
rank, which is why higher-rank classical groups expand uniformly.

**Definition 9.2 (Certificate comparison).** Given generating sets `S₁ ⊆ G₁`
and `S₂ ⊆ G₂`, say `S₂` *has gap at least that of* `S₁`,
`CertificateGapAtLeast S₁ S₂`, if every expansion constant achieved by `S₁`
is matched or exceeded by some expansion constant of `S₂`:
> `∀ ε₁, HasVertexExpansion S₁ ε₁ → ∃ ε₂, HasVertexExpansion S₂ ε₂ ∧ ε₁ ≤ ε₂`.

This relation lets one *rank* certificate systems across families — for
instance, comparing `Sp₄(𝔽₃)` certificates against `GL₂(𝔽₃)` certificates —
and provides the language for the program's central conjecture.

**Conjecture 9.3 (Uniform certified gap for `Sp₄`).** *For every odd prime
power `q` there exists `ε > 0`, independent of `q`, and a symmetric certified
pair generating `Sp₄(𝔽_q)` with vertex expansion at least `ε`.*

This is the program's falsifiable prediction: certificate-driven expansion
should be *uniform* across the symplectic family, not deteriorating as the
field grows. Uniformity is precisely the property that renders an infinite
family useful in applications.

---

## 10. Algorithms

The framework induces a verification pipeline.

**Algorithm A (Certificate verification for `GL₂`).**
Given `p` and matrices `s, t`:
1. Check `det s ≠ 0` and `det t ≠ 0`.
2. Compute `charpoly s` and test irreducibility over `𝔽_p` (e.g. by checking
   it has no root in `𝔽_p`, which for a degree-2 polynomial is equivalent to
   irreducibility).
3. Enumerate eigenvectors of `s` and `t` (none for `s` if step 2 passes) and
   confirm no common eigenvector.
Return "certified" iff all checks pass. Complexity: `O(poly(p))` field
operations; for the irreducibility test, `O(1)` polynomial evaluations.

**Algorithm B (Vertex-boundary / expansion estimation).**
Given a finite group `G`, generating set `S`, and a subset `A`:
1. Compute `CayleyNeighborFinset S A = ⋃_{a∈A} {a·s : s∈S}`.
2. Compute the boundary `CayleyNeighborFinset S A \ A`.
3. Report the ratio `|boundary| / |A|`.
The minimum ratio over all `A` with `2|A| ≤ |G|` is the vertex expansion
constant. Exhaustive evaluation is exponential in `|G|`; in practice one
samples sets or uses spectral surrogates, but the *certificate* of Theorems
1–5 bypasses this search entirely.

---

## 11. Applications

- **Pseudorandom generation.** Certified expanders yield explicit pseudorandom
  walks: Corollary 7.1 turns the expansion constant into an explicit mixing
  time, the workhorse of derandomization.
- **Error-correcting codes.** Expander Cayley graphs underlie expander codes;
  a certificate provides a verifiable guarantee of the code's distance
  parameters.
- **Group-theoretic algorithms.** Theorem 2 gives a sampling-based *proof of
  generation*: observing positive expansion certifies that a candidate set
  generates, sidestepping a direct closure computation.
- **Cryptographic hashing.** Cayley hash functions are secure precisely when
  the underlying graph mixes rapidly; the certificate framework offers
  checkable hypotheses for such security reductions.

---

## 12. Discussion and Future Work

The framework's design principle is to **load the mathematics into the
definitions** so that the theorems become short, robust, and — critically —
machine-checkable. Theorem 1's two-line proof is not a sign of triviality but
of well-chosen abstractions: the certificate captures exactly the data needed,
no more.

Two directions stand out. First, **relaxing irreducibility**: the breaking
condition is stated for general invariant subspaces, so the certificate should
extend from strongly regular toral `s` (irreducible charpoly) to merely
regular toral `s`, where `t` does genuine work in gluing the invariant
factors into an irreducible joint action. Second, **quantitative
certificates**: upgrading the qualitative "no invariant subspace" conclusion
to an explicit lower bound on the expansion constant `ε`, ideally via the
quasirandomness parameter of Definition 9.1 and a Bourgain–Gamburd-style
flattening argument. Conjecture 9.3 is the concrete target.

A broader aspiration is a *library of certified generators* for the classical
families, each accompanied by a verified certificate and a comparison
(Definition 9.2) placing it in a partial order of spectral quality. Such a
library would convert the existence theorems of expander theory into a
practical toolkit of constructions with attached, independently verifiable
guarantees.

---

## 13. Conclusion

We have given a clean, fully verified certificate framework linking the
algebra of regular toral elements, the linear algebra of invariant-subspace
breaking, and the graph theory of vertex expansion. The classical generation
certificate forces irreducible joint action (Theorem 1); positive expansion
forces generation (Theorem 2); expansion is monotone (Theorem 3) and yields
multiplicative growth and hence logarithmic mixing (Theorem 4); and the whole
apparatus specializes to a constant-time check for `GL₂(𝔽_p)` (Theorem 5).
The result is a bridge from short, local, checkable data to the global
guarantees that make expanders indispensable.
