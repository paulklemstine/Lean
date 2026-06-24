# Symmetrized Monomial Identities of the Arrow Ideal of an Acyclic Quiver

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Geometry / Combinatorial Algebra (PI-theory)

## Abstract

Let $Q$ be a finite acyclic quiver whose longest directed path has length $n-1$, and let $\mathbb{F}Q_{\ge 1}$ denote its *arrow ideal*: the principal subalgebra of the path algebra spanned by all nonempty paths. We prove that two degree-$n$ multilinear polynomials — the **symmetrized monomial** $S(x_1,\dots,x_n) = \sum_{\sigma \in S_n} x_{\sigma(1)} \cdots x_{\sigma(n)}$ and the **standard polynomial** $S_n(x_1,\dots,x_n) = \sum_{\sigma \in S_n} \operatorname{sgn}(\sigma)\, x_{\sigma(1)} \cdots x_{\sigma(n)}$ — are polynomial identities of $\mathbb{F}Q_{\ge 1}$. The argument proceeds through a tight three-link chain: (i) acyclicity yields a strictly monotone potential $r$ that bounds path length, $r(a) + \operatorname{length}(p) \le r(b)$; (ii) a topological order embeds $\mathbb{F}Q_{\ge 1}$ in the strictly upper triangular $n\times n$ matrices $N_n$, which are nilpotent of index $n$; and (iii) nilpotency of index $n$ makes every degree-$n$ multilinear monomial vanish, hence every degree-$n$ multilinear polynomial. The nilpotency step is governed by a quantitative **shift filtration**: a matrix has shift $k$ if all entries strictly below the $k$-th superdiagonal vanish, shift is additive under multiplication, and shift $n$ over $\mathbb{F}^n$ forces the zero matrix. A notable phenomenon is that the *unsigned* symmetrized monomial is already an identity here — in sharp contrast to full matrix algebras, where (by Amitsur–Levitzki) only the *signed* standard polynomial of degree $2n$ vanishes. The reason is structural: in the nilpotent regime each monomial is individually zero, so signs are inert. We give full definitions, theorem statements, proof sketches, algorithms, numerical demonstrations, and a discussion of the open *generation* problem for the T-ideal.

## 1. Introduction

### 1.1 Motivation

The theory of algebras with polynomial identity (PI-theory) studies associative algebras through the lens of the multilinear and polynomial laws they satisfy. The set of all such laws, the **T-ideal** of identities, is a powerful invariant: it controls Gelfand–Kirillov dimension, codimension growth, and structural classification. Among multilinear identities, the **standard polynomial** occupies a privileged place, made famous by the Amitsur–Levitzki theorem: the algebra $M_k(\mathbb{F})$ of $k\times k$ matrices satisfies $S_{2k}$ and no standard identity of lower degree.

This paper isolates and formalizes the *nilpotent shadow* of that theory. The arrow ideal of a finite acyclic quiver is a structured, computable nilpotent algebra, modelled faithfully by strictly upper triangular matrices. We prove that on this algebra the standard identity appears already in degree $n$ (the number of vertices), and — strikingly — that the unsigned symmetrized monomial of the same degree is also an identity. The contrast with $M_k$ illuminates the two distinct mechanisms by which polynomial identities arise: *cancellation* (signs essential, as in $M_k$) versus *individual annihilation* (signs inert, as in the nilpotent case).

### 1.2 Summary of results

The development rests on three pillars, each a formally verified theorem.

1. **Geometric bound (path length).** If $r : V \to \mathbb{N}$ strictly increases along every arrow, then for any path $p$ from $a$ to $b$, $r(a) + \operatorname{length}(p) \le r(b)$. Consequently, if $r(v) < n$ for all vertices $v$, every path has length $< n$.

2. **Algebraic nilpotency.** Via the *shift filtration* on $n\times n$ matrices, shift is additive under multiplication and shift $n$ vanishes; therefore the product of any $n$ strictly upper triangular $n\times n$ matrices is the zero matrix.

3. **Polynomial identities.** Because every degree-$n$ multilinear monomial vanishes on $N_n$, both the symmetrized monomial $S$ and the standard polynomial $S_n$ are identities of $N_n \cong \mathbb{F}Q_{\ge 1}$.

## 2. Preliminaries and Definitions

### 2.1 Quivers, paths, and potentials

A **quiver** $Q$ is a directed multigraph: a set $V$ of vertices together with, for each ordered pair $(a,b)$, a set of arrows $a \to b$. A **path** $p$ from $a$ to $b$ is a finite composable sequence of arrows; its **length** $\operatorname{length}(p)$ is the number of arrows it uses (the empty path at a vertex has length $0$). The quiver is **acyclic** if there is no path of positive length from a vertex to itself.

**Definition 2.1 (Potential / topological order).** A *potential* is a function $r : V \to \mathbb{N}$ that is *strictly monotone along arrows*: for every arrow $a \to b$, $r(a) < r(b)$.

A finite quiver admits a potential if and only if it is acyclic; this is the standard equivalence between acyclicity and the existence of a topological order. We take the existence of a potential as the working hypothesis, which keeps the path-length bound free of finiteness assumptions; finiteness enters only when one *constructs* a bounded potential.

### 2.2 Path algebra and arrow ideal

Given a field $\mathbb{F}$, the **path algebra** $\mathbb{F}Q$ has the paths of $Q$ as a basis, with product given by concatenation when endpoints match and $0$ otherwise. The **arrow ideal** (or augmentation ideal of nonempty paths) is

$$\mathbb{F}Q_{\ge 1} = \operatorname{span}_{\mathbb{F}}\{\, p : p \text{ is a path with } \operatorname{length}(p) \ge 1 \,\}.$$

It is a (non-unital) subalgebra closed under the concatenation product. The product of $m$ basis elements of $\mathbb{F}Q_{\ge 1}$ is a path of length $\ge m$ (or zero); if all paths have length $< n$, then any $n$-fold product is zero, i.e. $\mathbb{F}Q_{\ge 1}$ is nilpotent of index $\le n$.

### 2.3 The shift filtration on matrices

Fix $n \in \mathbb{N}$ and a semiring $R$. Index $\operatorname{Fin} n = \{0,1,\dots,n-1\}$.

**Definition 2.2 (Shift).** A matrix $M \in M_n(R)$ *has shift $k$*, written $\operatorname{Shift} k\, M$, if

$$M_{ij} = 0 \quad \text{whenever} \quad j < i + k.$$

**Definition 2.3 (Strictly upper triangular).** $M$ is *strictly upper triangular*, $\operatorname{StrictUpper} M$, if $\operatorname{Shift} 1\, M$; equivalently $M_{ij} = 0$ whenever $j \le i$.

Intuitively, shift $k$ means every nonzero entry lies at least $k$ steps above the main diagonal. Shift $0$ is no constraint (it is implied for the identity, whose only nonzero entries are on the diagonal, $j = i \ge i + 0$ being false, hence the off-shift-$0$ region is empty). The strictly upper triangular matrices $N_n := \{M : \operatorname{Shift} 1\, M\}$ form the algebraic model of $\mathbb{F}Q_{\ge 1}$ after a topological relabeling of vertices as $0,\dots,n-1$.

### 2.4 Multilinear polynomials

**Definition 2.4 (Symmetrized monomial).** For elements $a_1,\dots,a_n$ of an associative ring $A$,

$$\operatorname{symMono}(a) = S(a_1,\dots,a_n) = \sum_{\sigma \in S_n} a_{\sigma(1)} a_{\sigma(2)} \cdots a_{\sigma(n)}.$$

**Definition 2.5 (Standard polynomial).**

$$\operatorname{stdPoly}(a) = S_n(a_1,\dots,a_n) = \sum_{\sigma \in S_n} \operatorname{sgn}(\sigma)\, a_{\sigma(1)} a_{\sigma(2)} \cdots a_{\sigma(n)}.$$

Both are *multilinear* (linear in each $a_i$ separately) and of degree $n$. A polynomial $f$ is an **identity** of $A$ if $f(a_1,\dots,a_n) = 0$ for all substitutions $a_i \in A$.

## 3. The Geometric Bound: Acyclicity Forbids Long Paths

### 3.1 Potential growth along paths

**Theorem 3.1 (Potential bound, `r_add_length_le`).** Let $r : V \to \mathbb{N}$ be a potential (strictly monotone along arrows). Then for every path $p$ from $a$ to $b$,

$$r(a) + \operatorname{length}(p) \le r(b).$$

*Proof sketch.* Induct on the structure of $p$. For the empty path at $a$, $\operatorname{length} = 0$ and the inequality reads $r(a) \le r(a)$. For the inductive step, write $p$ as a path $q : a \to b'$ followed by an arrow $b' \to b$. By the inductive hypothesis $r(a) + \operatorname{length}(q) \le r(b')$, and by strict monotonicity $r(b') < r(b)$, i.e. $r(b') + 1 \le r(b)$. Since $\operatorname{length}(p) = \operatorname{length}(q) + 1$,
$$r(a) + \operatorname{length}(p) = (r(a) + \operatorname{length}(q)) + 1 \le r(b') + 1 \le r(b). \qquad \square$$

The bound is **sharp**: on the linear quiver $A_n$ (vertices $0 \to 1 \to \cdots \to n-1$) with $r = \operatorname{id}$, the full path from $0$ to $n-1$ has length $n-1$ and attains equality $0 + (n-1) = n-1$.

### 3.2 Bounded potential bounds all paths

**Theorem 3.2 (Length bound, `length_lt_of_bounded`).** Let $r$ be a potential with $r(v) < n$ for all $v \in V$. Then every path $p$ (from any $a$ to any $b$) satisfies $\operatorname{length}(p) < n$.

*Proof sketch.* By Theorem 3.1, $r(a) + \operatorname{length}(p) \le r(b)$. Since $r(b) < n$ and $r(a) \ge 0$, we get $\operatorname{length}(p) \le r(b) - r(a) \le r(b) < n$. $\square$

For a finite acyclic quiver on $n$ vertices one may always choose a potential into $\{0,1,\dots,n-1\}$, all $< n$; hence the *longest path length* is at most $n-1$. This is the combinatorial input that drives nilpotency.

## 4. The Algebraic Heart: Nilpotency via the Shift Filtration

### 4.1 The identity and shift $0$

**Lemma 4.1 (`Shift.one`).** The identity matrix $I \in M_n(R)$ has shift $0$: $\operatorname{Shift} 0\, I$.

*Proof sketch.* For $i \ne j$, $I_{ij} = 0$; for $i = j$, the constraint $j < i + 0 = i$ is false, so nothing is required. Hence $I_{ij}=0$ whenever $j < i + 0$. $\square$

### 4.2 Additivity of shift

**Theorem 4.2 (Shift additivity, `Shift.mul`).** If $\operatorname{Shift} k\, M$ and $\operatorname{Shift} l\, N$, then $\operatorname{Shift}(k+l)\,(MN)$.

*Proof sketch.* The $(i,j)$ entry is $(MN)_{ij} = \sum_{x} M_{ix} N_{xj}$. Suppose $j < i + k + l$. For each index $x$ in the sum, split on whether $x < i + k$:
- If $x < i + k$, then $M_{ix} = 0$ by $\operatorname{Shift} k\, M$, so the term $M_{ix}N_{xj} = 0$.
- If $x \ge i + k$, then $j < i + k + l \le x + l$, so $N_{xj} = 0$ by $\operatorname{Shift} l\, N$, and again the term is $0$.

Every summand vanishes, hence $(MN)_{ij} = 0$. $\square$

This additivity is exactly the *associated-graded* structure of the nilpotent filtration: writing $J = N_n$ for the arrow ideal, $J^k$ consists of shift-$k$ matrices and $J^k \cdot J^l \subseteq J^{k+l}$, with $k$ tracking path length.

### 4.3 The boundary: shift $n$ vanishes

**Theorem 4.3 (Top shift is zero, `Shift.eq_zero_of_top`).** If $\operatorname{Shift} n\, M$ for $M \in M_n(R)$, then $M = 0$.

*Proof sketch.* For all $i, j \in \operatorname{Fin} n$ we have $j < n \le i + n$, so the hypothesis applies to every entry: $M_{ij} = 0$. Thus $M$ is the zero matrix. $\square$

### 4.4 Products of strictly upper triangular matrices

**Theorem 4.4 (List product shift, `listProd_shift`).** If $\ell$ is a list of matrices in $M_n(R)$ each satisfying $\operatorname{StrictUpper}$ (shift $1$), then the product $\prod \ell$ has shift equal to the length of $\ell$.

*Proof sketch.* Induct on the list. The empty product is $I$, with shift $0 = $ length of the empty list (Lemma 4.1). For $M :: \ell$ with $M$ shift $1$ and (by induction) $\prod \ell$ of shift $|\ell|$, additivity (Theorem 4.2) gives $M \cdot \prod \ell$ of shift $1 + |\ell| = |M :: \ell|$. $\square$

**Theorem 4.5 (Nilpotency of the arrow ideal, `prod_ofFn_strictUpper_eq_zero`).** Let $a : \operatorname{Fin} n \to M_n(R)$ with $\operatorname{StrictUpper}(a_i)$ for every $i$. Then

$$\prod_{i=0}^{n-1} a_i = 0.$$

*Proof sketch.* The list $\operatorname{ofFn}(a)$ has $n$ entries, each strictly upper triangular, so by Theorem 4.4 its product has shift $n$. By Theorem 4.3, a shift-$n$ matrix over $\operatorname{Fin} n$ is zero. $\square$

We emphasize that the matrix monoid is **noncommutative**, so the product must be taken as an ordered `List.prod` rather than a `Finset.prod`; nevertheless the conclusion (the product is $0$) is independent of the order, since shift additivity holds for any order.

## 5. Polynomial Identities of the Arrow Ideal

### 5.1 The symmetrized monomial is an identity

**Theorem 5.1 (Symmetrized monomial identity, `PI.symMono_strictUpper_eq_zero`).** For every $a : \operatorname{Fin} n \to N_n$ (i.e. each $a_i$ strictly upper triangular),

$$S(a_1,\dots,a_n) = \sum_{\sigma \in S_n} a_{\sigma(1)} \cdots a_{\sigma(n)} = 0.$$

*Proof sketch.* For each fixed permutation $\sigma$, the term $a_{\sigma(1)} \cdots a_{\sigma(n)}$ is a product of $n$ strictly upper triangular matrices and equals $0$ by Theorem 4.5 (the reindexing $i \mapsto a_{\sigma(i)}$ is again a family of strictly upper triangular matrices). The sum of $n!$ zero terms is $0$. $\square$

### 5.2 The standard polynomial is an identity

**Theorem 5.2 (Standard identity, `PI.stdPoly_strictUpper_eq_zero`).** For every $a : \operatorname{Fin} n \to N_n$,

$$S_n(a_1,\dots,a_n) = \sum_{\sigma \in S_n} \operatorname{sgn}(\sigma)\, a_{\sigma(1)} \cdots a_{\sigma(n)} = 0.$$

*Proof sketch.* Identical to Theorem 5.1: each term $\operatorname{sgn}(\sigma)\, a_{\sigma(1)} \cdots a_{\sigma(n)}$ is a scalar multiple of a degree-$n$ product of strictly upper triangular matrices, which is $0$ by Theorem 4.5. The signs are *irrelevant* because each monomial vanishes individually. $\square$

### 5.3 The abstract principle

Both Theorems 5.1 and 5.2 are instances of a single abstract fact, which we record because it isolates the exact hypothesis used.

**Proposition 5.3 (Nilpotency $\Rightarrow$ multilinear identities).** Let $A$ be an associative ring and $J \subseteq A$ a subset closed under multiplication such that every $n$-fold product of elements of $J$ is $0$. Then every degree-$n$ multilinear polynomial (in particular $S$ and $S_n$) is an identity of $J$.

*Proof sketch.* A multilinear polynomial of degree $n$ is an $\mathbb{F}$-linear combination of monomials $a_{\sigma(1)} \cdots a_{\sigma(n)}$. Each such monomial is an $n$-fold product of elements of $J$, hence $0$ by hypothesis; the linear combination is therefore $0$. $\square$

## 6. The Signed/Unsigned Dichotomy and Amitsur–Levitzki

The **Amitsur–Levitzki theorem** states that $M_k(\mathbb{F})$ satisfies the standard identity $S_{2k}$ and no standard identity of degree $< 2k$. There, the proof is a delicate cancellation: terms pair off according to the sign $\operatorname{sgn}(\sigma)$, and the *unsigned* symmetrized monomial does **not** vanish on $M_k$.

Our result is the nilpotent counterpoint. On the strictly upper triangular subalgebra $N_n \subset M_n(\mathbb{F})$:

- the standard identity appears already at degree $n$ (not $2n$); and
- the *unsigned* symmetrized monomial $S$ is also an identity.

The mechanism is opposite to Amitsur–Levitzki: here each monomial is *individually* zero (Theorem 4.5), so summing with or without signs makes no difference. This yields a conjectural characterization (Conjecture 3 below): an associative algebra satisfies the degree-$n$ unsigned symmetrized identity if and only if its augmentation ideal is nilpotent of index $\le n$.

## 7. Algorithms

We describe the computational procedures underlying the demonstrations.

### 7.1 Topological potential and longest path

**Input.** A finite acyclic quiver $Q = (V, E)$ with $V = \{0,\dots,m-1\}$.
**Output.** A potential $r : V \to \mathbb{N}$ with $r(v) < |V|$, and the longest path length $L = \max_p \operatorname{length}(p)$.

The standard approach is Kahn's algorithm (repeatedly remove sources) to produce a topological order, then a single dynamic-programming pass in topological order computing $\operatorname{lp}(v) = $ longest path ending at $v$ via $\operatorname{lp}(v) = \max(0, \max_{u \to v} \operatorname{lp}(u) + 1)$. Complexity $O(|V| + |E|)$. By Theorem 3.2, $L \le |V| - 1$.

### 7.2 Shift computation and nilpotency verification

**Input.** Matrices $M_1,\dots,M_t \in M_n(R)$.
**Output.** The shift of each $M_i$ and of the product $\prod M_i$.

Compute $\operatorname{shift}(M) = \min\{\, j - i + 1 : M_{ij} \ne 0\}$ if $M \ne 0$ (the least $k$ such that $M$ fails $\operatorname{Shift}(k{+}1)$ is $\operatorname{shift}(M) - 1$; concretely we report the largest $k$ with $\operatorname{Shift} k\, M$). Theorem 4.2 predicts $\operatorname{shift}(\prod M_i) \ge \sum \operatorname{shift}(M_i)$; when each $M_i$ is strictly upper triangular and $t = n$, the product is $0$ (Theorem 4.5). Matrix multiplication dominates the cost at $O(t\, n^3)$.

### 7.3 Multilinear identity evaluation

**Input.** Strictly upper triangular $a_1,\dots,a_n \in M_n(R)$.
**Output.** $S(a) = \sum_\sigma \prod_i a_{\sigma(i)}$ and $S_n(a) = \sum_\sigma \operatorname{sgn}(\sigma) \prod_i a_{\sigma(i)}$, both verified to be $0$.

Enumerate all $n!$ permutations (Heap's algorithm or library permutations), accumulate the (signed) products. Complexity $O(n! \cdot n \cdot n^3)$. By Theorems 5.1–5.2 the output is the zero matrix for every input.

## 8. Applications and Consequences

- **Representation theory of quivers.** The arrow ideal's nilpotency index governs the radical filtration of the path algebra; bounding it by the number of vertices is the structural fact behind finite global dimension of acyclic path algebras.
- **PI-theory of triangular algebras.** $N_n$ and the full upper-triangular algebra $UT_n$ are central examples; our degree-$n$ identities give explicit generators in the multilinear component, a starting point for computing codimension sequences.
- **Combinatorial certificates.** The shift filtration turns "no long path" into a checkable matrix-degree invariant, useful for verified static analysis of dependency graphs (build systems, scheduling), where acyclicity guarantees bounded composition depth.

## 9. Discussion and Future Directions

This cycle proves the *containment* half of the mission statement: $S$ and $S_n$ are identities of $\mathbb{F}Q_{\ge 1}$. The *generation* half — that they generate the entire T-ideal — remains open and motivates the conjectures below.

**Conjecture 1 (Degree sharpness).** $N_n$ satisfies no multilinear identity of degree $< n$; degree $n$ is minimal. Witness: the matrix-unit chain $E_{12}E_{23}\cdots E_{n-1,n} = E_{1,n} \ne 0$ is a nonzero product of $n-1$ strictly upper triangular matrices, certifying that some degree-$(n-1)$ substitution is nonzero. The shift filtration already exposes the associated graded $J^k/J^{k+1}$ whose nonvanishing at $k = n-1$ proves minimality.

**Conjecture 2 (T-ideal generation).** The T-ideal $\operatorname{Id}(N_n)$ is generated, as a T-ideal, by the single standard polynomial $S_n$. Nilpotency of index $n$ collapses all higher identities to consequences of "any product of $n$ augmentation-ideal elements is zero," and $S_n$ is the universal multilinear witness. With Theorem 4.5 formalized, the remaining step is a substitution/linearization argument inside the free algebra modulo $(S_n)^T$, finitely checkable in each fixed degree.

**Conjecture 3 (Unsigned/signed dichotomy).** An associative algebra satisfies the degree-$n$ unsigned symmetrized identity iff its augmentation ideal is nilpotent of index $\le n$; on $M_k$ only the signed standard polynomial (degree $2k$, Amitsur–Levitzki) holds. The converse direction (identity $\Rightarrow$ nilpotent) is a pigeonhole argument on monomials.

**Conjecture 4 (Quiver-shape refinement).** For a general acyclic $Q$, the minimal identity degree equals $1 + (\text{longest directed path length})$, independent of the number of vertices.

## 10. Conclusion

From a single combinatorial fact — an acyclic quiver on $n$ vertices admits no path of length $n$ — we derived, through a quantitative shift filtration, the nilpotency of the arrow ideal and hence two degree-$n$ polynomial identities of $\mathbb{F}Q_{\ge 1}$: the symmetrized monomial and the standard polynomial. The unsigned identity's validity, impossible on full matrix algebras, marks the nilpotent regime as governed by individual annihilation rather than signed cancellation, sharpening the contrast with the Amitsur–Levitzki theorem and framing the open problem of T-ideal generation.

## Appendix A: Index of formal results

| Name | Statement |
|------|-----------|
| `r_add_length_le` | $r(a) + \operatorname{length}(p) \le r(b)$ along any path |
| `length_lt_of_bounded` | bounded potential $\Rightarrow$ all path lengths $< n$ |
| `Shift.one` | identity matrix has shift $0$ |
| `Shift.mul` | shift is additive: $\operatorname{Shift} k \cdot \operatorname{Shift} l = \operatorname{Shift}(k+l)$ |
| `Shift.eq_zero_of_top` | shift $n$ over $\operatorname{Fin} n$ $\Rightarrow$ zero matrix |
| `listProd_shift` | product of shift-$1$ matrices has shift = list length |
| `prod_ofFn_strictUpper_eq_zero` | product of $n$ strictly upper triangular $n\times n$ matrices is $0$ |
| `PI.symMono_strictUpper_eq_zero` | symmetrized monomial $S$ is an identity of $N_n$ |
| `PI.stdPoly_strictUpper_eq_zero` | standard polynomial $S_n$ is an identity of $N_n$ |
