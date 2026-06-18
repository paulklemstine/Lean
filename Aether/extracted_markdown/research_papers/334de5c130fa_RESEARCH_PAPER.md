# A Finite Duality Between Closure-Stable Predicate Families and Seeded Extractors

## Abstract

We develop a finite, fully constructive duality theory connecting two notions of
*separating power*: families of dependency-respecting Boolean tests on the one
hand, and seed-indexed map families (in the style of seeded extractors) on the
other. The setting is a finite type $X$ equipped with a *closure operator*
$\operatorname{cl}$ — a monotone, extensive, idempotent map on subsets of $X$
abstracting span, deductive closure, convex hull, and the closure of attribute
sets under functional dependencies. We define the *deficiency*
$\operatorname{def}(A) = |\operatorname{cl}(A)| - |A|$ and an associated entropy
surrogate, and prove that deficiency vanishes on closed sets. We then introduce
*closure-stable predicates* (Boolean tests constant on closure-equivalence
classes) and the *encoding map* they induce, and define $k$-separation of large
closed sets for both predicate families and seed families. Our main results are:
(i) an **encoding–separation equivalence** identifying separation with
injectivity of the encoding on large closed sets; (ii) a two-directional
**closure–extractor duality** showing that closure-stable predicate families that
$k$-separate exist iff (closure-compatible) seed families that $k$-separate exist;
and (iii) a **certified reconstruction** theorem that converts a separating
evaluation matrix into an explicit separating seed family. Every result is stated
over finite types with no analytic assumptions, and each proof is a finite,
algorithmic construction. We discuss applications to database key theory,
universal hashing, and feature selection, and we situate the framework within a
broader program of cross-domain "semantic dictionaries."

**Keywords:** closure operators, matroids, seeded extractors, separation,
fingerprinting, functional dependencies, finite duality, formal verification.

---

## 1. Introduction

Closure operators and seeded extractors are central objects in two largely
disjoint research traditions. Closure operators formalize *dependency*: the
passage from a generating set to everything it forces. They are the abstract
backbone of linear span, affine and convex hulls, topological closure,
matroid theory, lattice theory, and the relational-database notion of attribute
closure under functional dependencies. Seeded extractors formalize *purification
of randomness*: a small public function that, aided by a short uniform seed,
maps a weak entropy source to near-uniform output. They are foundational in
cryptography, pseudorandomness, and differential privacy.

This paper exhibits a precise bridge between the two. The connecting concept is
**separation on large closed sets**: the ability to assign distinct labels to
distinct elements within the saturated (deficiency-zero) configurations of a
closure structure. We show that the resource "separating power" can be carried
equally well by a family of dependency-respecting Boolean tests or by a
seed-indexed family of maps, and that one representation can be converted into
the other by explicit, finite recipes. The development is entirely
combinatorial; all proofs are constructive and have been mechanically verified.

### 1.1 A semantic dictionary

The framework is organized around a deliberate dictionary between dependency
structures and extraction primitives:

| Dependency side | Extraction side |
|---|---|
| Closed sets | Entropy carriers (deficiency-zero subsets) |
| Closure-stable predicates | Seed tests respecting the source structure |
| Encoding (matrix) rows | Extractor output coordinates |
| Rank / separation defect | Entropy loss |
| Reconstruction from a matrix | Certified seed synthesis |

The dictionary is not a metaphor: each row corresponds to a defined object, and
the theorems below make the correspondences exact.

### 1.2 Contributions

1. A finite axiomatization of closure operators on subsets of a finite type, and
   the basic invariants *deficiency* and *entropy surrogate*, with the identity
   that deficiency vanishes precisely on closed sets (§3).
2. The notions of closure-equivalence, closure-stable predicate, and the encoding
   map; the definitions of $k$-separation for predicate families, seed families,
   and evaluation matrices (§4–5).
3. The **encoding–separation equivalence** (Theorem 6.1).
4. The **closure–extractor duality** in both directions (Theorems 7.1–7.3),
   including the closure-compatibility hypothesis necessary for the
   seeds-to-predicates direction.
5. The **certified reconstruction** theorem turning a separating matrix into an
   explicit separating seed family (Theorem 8.1), and a matrix–seed bridge
   (Theorem 8.2).

---

## 2. Preliminaries and Notation

Throughout, $X$ is a finite type with decidable equality, and $\operatorname{Fin}
n = \{0, \dots, n-1\}$. For a finite set $A \subseteq X$ we write $|A|$ for its
cardinality and $|X|$ for the cardinality of the whole type. Boolean values are
$\{\mathrm{tt}, \mathrm{ff}\}$. All quantities are finite; subtraction on natural
numbers is truncated (i.e. $a - b = 0$ when $b \geq a$), which is harmless here
because closures only grow sets.

---

## 3. Closure Operators and Deficiency

**Definition 3.1 (Closure operator).** A *closure operator* on $X$ is a map
$\operatorname{cl}$ on finite subsets of $X$ satisfying, for all $A, B$:

- *(Extensivity)* $A \subseteq \operatorname{cl}(A)$;
- *(Monotonicity)* $A \subseteq B \implies \operatorname{cl}(A) \subseteq
  \operatorname{cl}(B)$;
- *(Idempotence)* $\operatorname{cl}(\operatorname{cl}(A)) = \operatorname{cl}(A)$.

**Definition 3.2 (Closed set).** A finite set $C$ is *closed* if
$\operatorname{cl}(C) = C$.

**Proposition 3.3 (Closures are closed).** For every $A$, the set
$\operatorname{cl}(A)$ is closed.

*Proof.* Immediate from idempotence: $\operatorname{cl}(\operatorname{cl}(A)) =
\operatorname{cl}(A)$. $\qquad\blacksquare$

**Definition 3.4 (Deficiency, entropy surrogate).** The *deficiency* of $A$ is
$$
\operatorname{def}(A) \;=\; |\operatorname{cl}(A)| - |A| \quad(\in \mathbb{N}),
$$
and its *entropy surrogate* is $|X| - \operatorname{def}(A)$.

**Proposition 3.5 (Deficiency vanishes on closed sets).** If $C$ is closed then
$\operatorname{def}(C) = 0$, and consequently its entropy surrogate equals $|X|$.

*Proof.* If $\operatorname{cl}(C) = C$ then $|\operatorname{cl}(C)| = |C|$, so
$\operatorname{def}(C) = |C| - |C| = 0$; the entropy surrogate is then
$|X| - 0 = |X|$. $\qquad\blacksquare$

Closed sets are thus the deficiency-zero, maximal-entropy-surrogate
configurations: the "carriers of full dependency" in the dictionary of §1.1.

**Examples.** (a) *Span:* over a finite vector space, $\operatorname{cl}(A) =
\operatorname{span}(A)$; closed sets are subspaces. (b) *Partition closure:* given
a partition of $X$ into blocks, $\operatorname{cl}(A) =$ the union of all blocks
meeting $A$; closed sets are unions of blocks. (c) *Functional dependencies:*
$X$ is a set of attributes, $\operatorname{cl}(A)$ is the set of attributes
determined by $A$ under a set of FDs; closed sets are exactly the
dependency-closed attribute sets, and minimal sets with $\operatorname{cl}(A) =
X$ are candidate keys.

---

## 4. Closure-Stable Predicates and the Encoding Map

**Definition 4.1 (Closure-equivalence).** Elements $x, y \in X$ are
*closure-equivalent*, written $x \sim y$, if
$\operatorname{cl}(\{x\}) = \operatorname{cl}(\{y\})$.

This is an equivalence relation (reflexive, symmetric, transitive by equality of
sets). Its classes are the indistinguishable atoms of the dependency structure.

**Definition 4.2 (Closure-stable predicate).** A *closure-stable predicate* is a
pair $(\varphi, \text{stab})$ where $\varphi : X \to \mathrm{Bool}$ and
$\text{stab}$ witnesses that $x \sim y \implies \varphi(x) = \varphi(y)$.

**Definition 4.3 (Encoding map).** Given a family $\Phi = (\varphi_i)_{i \in
\operatorname{Fin} n}$ of closure-stable predicates, the *encoding map*
$\operatorname{enc}_\Phi : X \to \mathrm{Bool}^{n}$ is
$$
\operatorname{enc}_\Phi(x) \;=\; \big(\varphi_0(x), \dots, \varphi_{n-1}(x)\big).
$$

The encoding map fingerprints each element by the vector of answers it gives to
the family of dependency-respecting tests.

---

## 5. Separation Notions

Fix a threshold $k \in \mathbb{N}$.

**Definition 5.1 ($k$-separating predicate family).** A predicate family $\Phi$
*$k$-separates* if for every closed set $C$ with $|C| \geq k$ and all distinct
$x, y \in C$ there is an index $i$ with $\varphi_i(x) \neq \varphi_i(y)$.

**Definition 5.2 ($k$-separating seed family).** For finite types $Y$ (with
decidable equality) and $\text{Seed}$, a map family $f : \text{Seed} \to X \to Y$
*$k$-separates on closed sets* if for every closed $C$ with $|C| \geq k$ and all
distinct $x, y \in C$ there is a seed $s$ with $f(s, x) \neq f(s, y)$.

**Definition 5.3 (Closure-compatible seed family).** $f$ is
*closure-compatible* if for every seed $s$, $x \sim y \implies f(s, x) = f(s,
y)$. (This is the seed-side analog of closure-stability.)

**Definition 5.4 (Separating evaluation matrix).** A Boolean matrix $M :
\operatorname{Fin} n \to X \to \mathrm{Bool}$ (rows = tests, columns = elements)
*$k$-separates closed sets* if for every closed $C$ with $|C| \geq k$ and all
distinct $x, y \in C$ there is a row $i$ with $M_i(x) \neq M_i(y)$.

**Definition 5.5 (Entropy-loss bound).** For finite $\text{Seed}, Y$, a seed
family $f$ satisfies the *entropy-loss bound* $e$ if $e \leq |\text{Seed}| \cdot
|Y|$, i.e. the seed–output product space is large enough to host $e$ distinct
labels. This is the combinatorial surrogate for "the extractor does not lose more
than $e$ units of separating capacity."

---

## 6. Encoding–Separation Equivalence

**Theorem 6.1 (Encoding–separation equivalence).** A predicate family $\Phi$
$k$-separates if and only if its encoding map is injective on every large closed
set: for every closed $C$ with $|C| \geq k$ and all distinct $x, y \in C$,
$\operatorname{enc}_\Phi(x) \neq \operatorname{enc}_\Phi(y)$.

*Proof.* ($\Rightarrow$) Suppose $\Phi$ $k$-separates and let $x \neq y$ lie in a
large closed $C$. Pick $i$ with $\varphi_i(x) \neq \varphi_i(y)$. If the encodings
were equal, then in particular their $i$-th coordinates would agree, i.e.
$\varphi_i(x) = \varphi_i(y)$, a contradiction; hence the encodings differ.

($\Leftarrow$) Suppose the encoding is injective on large closed sets and let
$x \neq y$ in such a $C$. If *every* coordinate agreed, then by extensionality the
two encoding vectors would be equal, contradicting injectivity; so some
coordinate $i$ disagrees, giving $\varphi_i(x) \neq \varphi_i(y)$.
$\qquad\blacksquare$

Theorem 6.1 reduces a quantified separation statement to a single injectivity
statement. Conceptually, *separation is injective fingerprinting*: the same
principle underlying perfect hashing and the distance property of codes, here
localized to the large closed sets of a closure structure.

---

## 7. The Closure–Extractor Duality

### 7.1 Predicates to seeds

**Theorem 7.1 (Backward direction).** If $\Phi$ is a closure-stable predicate
family that $k$-separates, then the single-seed family
$$
f(\ast, x) \;=\; \operatorname{enc}_\Phi(x), \qquad \text{Seed} = \{\ast\},\
Y = \mathrm{Bool}^n,
$$
$k$-separates on closed sets.

*Proof.* Let $x \neq y$ lie in a large closed set $C$. By Theorem 6.1,
$\operatorname{enc}_\Phi(x) \neq \operatorname{enc}_\Phi(y)$, i.e. $f(\ast, x)
\neq f(\ast, y)$. Thus the single seed $\ast$ already witnesses separation.
$\qquad\blacksquare$

The substance is purely the equivalence of §6: many Boolean tests bundle into one
vector-valued extractor with one seed.

**Corollary 7.2 (Duality, predicate $\Rightarrow$ seed form).** If there exists a
closure-stable predicate family that $k$-separates, then there exists a finite
output type $Y$ (with decidable equality) and a one-seed family $f : \{\ast\} \to
X \to Y$ that $k$-separates. (Take $Y = \mathrm{Bool}^n$ and $f$ as in Theorem
7.1.)

### 7.2 Seeds to predicates

**Theorem 7.3 (Forward direction / converse duality).** Let $Y$ and
$\text{Seed}$ be finite, $Y$ with decidable equality, and let $f : \text{Seed}
\to X \to Y$ be closure-compatible and $k$-separating. Then there exist $m \in
\mathbb{N}$ and closure-stable predicates $(\psi_j)_{j \in \operatorname{Fin} m}$
that $k$-separate.

*Proof (construction).* Take $m = |\text{Seed} \times Y|$ and index the new
predicates by pairs $(s, y) \in \text{Seed} \times Y$ via a fixed bijection with
$\operatorname{Fin} m$. Define the indicator predicate
$$
\psi_{(s,y)}(x) \;=\; \big[\, f(s, x) = y \,\big].
$$

*Stability.* For $x \sim u$, closure-compatibility gives $f(s, x) = f(s, u)$ for
every $s$, hence $[f(s,x)=y] = [f(s,u)=y]$; so each $\psi_{(s,y)}$ is
closure-stable.

*Separation.* Let $x \neq u$ lie in a large closed set $C$. Since $f$ separates,
there is a seed $s$ with $f(s, x) \neq f(s, u)$. Put $y^\star = f(s, x)$. Then
$\psi_{(s, y^\star)}(x) = [f(s,x) = y^\star] = \mathrm{tt}$, while
$\psi_{(s, y^\star)}(u) = [f(s,u) = y^\star] = \mathrm{ff}$ because $f(s, u) \neq
y^\star$. So the predicate indexed by $(s, y^\star)$ distinguishes $x$ from $u$.
$\qquad\blacksquare$

Theorems 7.1 and 7.3 together establish the equivalence advertised in the title:
over a finite closure structure, separating-by-predicates and separating-by-seeds
are interchangeable, with the seeds-to-predicates direction requiring (and
exactly using) closure-compatibility.

**Remark 7.4 (Why closure-compatibility is needed).** Without
closure-compatibility, the indicator predicates $\psi_{(s,y)}$ need not be
closure-stable: a seed could separate two closure-equivalent elements, producing
a predicate that violates Definition 4.2. Closure-compatibility is precisely the
hypothesis that imports the dependency-respecting discipline from the seed side
to the predicate side.

---

## 8. Certified Reconstruction

The duality above is constructive but phrased existentially. The following result
makes the construction algorithmic: it turns *observed* data — a separation matrix
— into a *certified* extractor.

**Theorem 8.1 (Certified reconstruction).** Let $M : \operatorname{Fin} n \to X
\to \mathrm{Bool}$ be a matrix that $k$-separates closed sets. Then there is an
explicit single-seed family $f : \{\ast\} \to X \to \mathrm{Bool}^n$ such that

1. $f$ $k$-separates on closed sets, and
2. for every $x$, $f(\ast, x) = (M_0(x), \dots, M_{n-1}(x))$ — the column of $x$.

*Proof.* Define $f(\ast, x)$ to be the $x$-column of $M$, i.e. $i \mapsto M_i(x)$;
clause 2 holds by definition. For clause 1, take distinct $x, y$ in a large closed
set; $M$ separates, so some row $i$ has $M_i(x) \neq M_i(y)$, whence the columns
differ in coordinate $i$ and $f(\ast, x) \neq f(\ast, y)$. $\qquad\blacksquare$

**Theorem 8.2 (Matrix–seed bridge).** With $M$ and $k$ as above, the one-seed
family $f(\ast, x) = (i \mapsto M_i(x))$ $k$-separates on closed sets. (This is
the operational core of Theorem 8.1, stated as a standalone bridge from a
separating matrix to a separating seed family.)

*Proof.* Identical column-difference argument: for distinct $x, y$ in a large
closed set, a separating row of $M$ yields a coordinate on which the columns
differ. $\qquad\blacksquare$

Theorems 8.1–8.2 complete the pipeline *closed-set data $\to$ separation matrix
$\to$ certified extractor*: the matrix columns are themselves the extracted
fingerprints, and reading them off is the reconstruction algorithm.

---

## 9. Algorithms

We summarize the constructive content as three algorithms; all run in time
polynomial in $|X|$, $n$, $|\text{Seed}|$, and $|Y|$.

**Algorithm A — Encode.** *Input:* predicate family $\Phi = (\varphi_i)$.
*Output:* fingerprint table. For each $x \in X$, emit
$\operatorname{enc}_\Phi(x) = (\varphi_0(x), \dots, \varphi_{n-1}(x))$. By Theorem
6.1, checking injectivity of this table on large closed sets decides
$k$-separation.

**Algorithm B — Seeds-to-predicates.** *Input:* closure-compatible
$k$-separating $f$. *Output:* closure-stable $k$-separating predicate family. For
each $(s, y) \in \text{Seed} \times Y$, emit $\psi_{(s,y)}(x) = [f(s,x) = y]$
(Theorem 7.3). The output has $|\text{Seed}|\cdot|Y|$ predicates, matching the
entropy-loss bound of Definition 5.5.

**Algorithm C — Reconstruct.** *Input:* separating matrix $M$. *Output:* certified
seed family. Emit $f(\ast, x) = (i \mapsto M_i(x))$ (Theorem 8.1). Each object is
mapped to its column; separation is inherited from $M$ with no search.

---

## 10. Applications

**10.1 Database key theory.** With $X$ a set of attributes and
$\operatorname{cl}$ the attribute-closure under functional dependencies, closed
sets are the dependency-closed attribute sets and the size threshold $k$
isolates large schemas. Closure-stable predicates that $k$-separate are exactly
tuple-tests that respect the FDs while still distinguishing records of a large
schema; the duality repackages such a test suite as a seeded fingerprinting
scheme, and Theorem 8.1 reconstructs one from an empirically observed separation
table.

**10.2 Universal hashing and extractors.** Seed families are the natural model of
hash/extractor families. Theorem 6.1 shows separation is injective fingerprinting;
Theorem 7.1 packs a verified test suite into a single vector-valued hash; Theorem
7.3 unpacks a closure-compatible hash family into structural tests. The
entropy-loss bound (Definition 5.5) quantifies the seed×output budget.

**10.3 Feature selection in machine learning.** Features induce an equivalence on
samples; closure-equivalence is its structural counterpart, and closure-stable
predicates are features respecting a known dependency structure. The duality says
the discriminative power of a feature set and that of a randomized,
seed-selected feature are interchangeable, with explicit conversions.

---

## 10.4 A fully worked example

We illustrate the entire pipeline on a small concrete instance. Let $X =
\{1, \dots, 6\}$ and let $\operatorname{cl}$ be the *divisibility down-closure*:
$\operatorname{cl}(A) = A \cup \{ y : y \mid x \text{ for some } x \in A \}$. This
is extensive (every element divides itself), monotone, and idempotent (divisors
of divisors are divisors), so it is a genuine closure operator. Its closed sets
are the *divisor-closed* subsets (down-sets of the divisibility order); for
$X = \{1,\dots,6\}$ there are $17$ of them, ranging from $\varnothing$ up to all
of $X$.

*Deficiency.* Take $A = \{4\}$. Then $\operatorname{cl}(A) = \{1, 2, 4\}$, so
$\operatorname{def}(A) = 3 - 1 = 2$ (the closure dragged in the proper divisors
$1$ and $2$) and the entropy surrogate is $6 - 2 = 4$. For the closed set $C =
\{1, 2, 3, 6\}$ we have $\operatorname{cl}(C) = C$, hence $\operatorname{def}(C)
= 0$ and entropy surrogate $6$, confirming Proposition 3.5.

*Separation and encoding.* Each singleton closure $\operatorname{cl}(\{x\})$ is
the set of divisors of $x$, and these are pairwise distinct for distinct
$x \in \{1,\dots,6\}$; therefore closure-equivalence is trivial and *every*
Boolean predicate is closure-stable. Choosing the three-bit family $\varphi_b(x)
= \text{bit}_b(x)$ for $b \in \{0,1,2\}$ gives fingerprints
$\operatorname{enc}(1) = (1,0,0)$, $\operatorname{enc}(2) = (0,1,0)$, $\dots$,
$\operatorname{enc}(6) = (0,1,1)$, which are pairwise distinct. By Theorem 6.1
the family $1$-separates, and by Theorem 7.1 the single seed $\ast \mapsto
\operatorname{enc}(\cdot)$ separates as well.

*Necessity of compatibility.* If we instead add a duplicate element whose
singleton closure coincides with that of an existing element, the two become
closure-equivalent; any closed set containing both then cannot be separated by
*any* closure-stable predicate or closure-compatible seed, exactly as Remark 7.4
predicts. This degenerate case is the precise boundary of the theory and is
handled correctly by the framework.

## 11. Discussion

The framework isolates *separation on large closed sets* as a conserved resource
and shows it admits two equivalent encodings — structural (predicates) and
stochastic (seeds) — with explicit, finite translations and a certified
reconstruction from raw matrices. Three features are worth emphasizing.

*Finiteness and constructivity.* All objects are finite and every proof is an
algorithm; there are no limiting or analytic arguments. This makes the results
directly implementable (see the accompanying numerical demonstrations) and
keeps the entropy-loss accounting exact.

*The role of closure-compatibility.* The asymmetry between Theorems 7.1 and 7.3 —
the backward direction is free, the forward direction needs compatibility — is
not a defect but the precise locus where dependency discipline crosses the
bridge. Remark 7.4 shows it cannot be dropped.

*Encoding as the hinge.* Theorem 6.1 is the technical pivot: once separation is
recognized as injective encoding, both directions of the duality become natural
operations on encodings (bundling into one seed; expanding seed×output into
indicators).

---

## 12. Future Work

- **Quantitative entropy loss.** Strengthen Definition 5.5 to a tight loss law
  relating the minimal number of separating predicates to a rank/defect invariant
  of the encoding matrix, and prove optimality of Algorithm B's
  $|\text{Seed}|\cdot|Y|$ output size.
- **Matroidal specialization.** Instantiate the closure operator as a matroid
  closure and relate $k$-separation thresholds to rank and to the existence of
  small identifying codes / test covers.
- **Approximate separation.** Relax exact separation to $\varepsilon$-separation
  (a small fraction of pairs may collide) and recover genuine extractor-style
  statistical guarantees, bringing the framework closer to classical seeded
  extractors.
- **Algebraic outputs.** Replace Boolean predicates by functionals valued in an
  idempotent semiring (min-plus / tropical), connecting separation to tropical
  rank and to polynomial-time cycle-mean computations.
- **Lattice of closed sets.** Study the duality fiberwise over the lattice of
  closed sets, relating separation thresholds to the height and width of that
  lattice.

---

## 13. Conclusion

We have established a finite, constructive, and fully verified duality between
closure-stable predicate families and seeded map families, organized by the
notion of separation on large closed sets. The encoding–separation equivalence
identifies separation with injective fingerprinting; the duality theorems exchange
structural and stochastic representations of separating power; and the certified
reconstruction promotes a separation matrix to an explicit extractor. The result
is a small but sturdy bridge along which results in the theory of dependency and
the theory of extraction can travel in both directions.
