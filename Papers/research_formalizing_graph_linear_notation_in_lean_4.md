# Graph Linear Notation: A Complete Numeric Invariant for Finite Simple Graphs

**Author:** Aristotle

**Date:** 2026-06-20

---

## Abstract

We introduce and rigorously establish *graph linear notation* ($\mathrm{gln}$), a single natural-number invariant attached to every finite simple graph on a labeled vertex set $\mathrm{Fin}\,n = \{0,1,\dots,n-1\}$. The construction proceeds in two stages. First, each *labeled* graph is encoded as a natural number $\mathrm{adjCode}(G)$ by reading its adjacency matrix as a base-$2$ integer with one bit per ordered cell. We prove this encoding is injective. Second, we define $\mathrm{gln}(G)$ to be the maximum of $\mathrm{adjCode}$ over all $n!$ relabelings of the vertices. Maximizing over the relabeling action quotients out the arbitrary choice of vertex names. Our central theorem is that $\mathrm{gln}$ is a **complete invariant** for graph isomorphism: $\mathrm{gln}(G) = \mathrm{gln}(H)$ if and only if $G$ and $H$ are isomorphic. We give the full definitions, the statements of all supporting lemmas, and detailed proof sketches, and we discuss the relationship of $\mathrm{gln}$ to canonical labeling, the enumeration of isomorphism classes, and probabilistic behavior under the Erdős–Rényi model. All results have been formally verified in the Lean 4 proof assistant; this paper presents the mathematics those formal proofs certify.

**Keywords:** graph isomorphism, complete invariant, canonical form, adjacency matrix, binary encoding, permutation action, finite simple graph.

---

## 1. Introduction

A *finite simple graph* is a finite set of vertices together with a symmetric, irreflexive adjacency relation. Two graphs are **isomorphic** when one can be transformed into the other by renaming vertices. The *graph isomorphism problem* — deciding whether two given graphs are isomorphic — is a celebrated computational problem whose precise complexity remains open; it is in $\mathsf{NP}$, is not known to be $\mathsf{NP}$-complete, and is solvable in quasipolynomial time by Babai's algorithm.

A powerful conceptual tool for reasoning about isomorphism is a **complete invariant**: a function $I$ from graphs to some value domain such that $I(G) = I(H)$ exactly when $G \cong H$. A complete invariant converts the relational question "are these isomorphic?" into the equality question "are these values equal?". The strongest form of a complete invariant is a **canonical form**: a rule selecting, from each isomorphism class, one distinguished representative.

This paper develops a complete *numeric* invariant valued in the natural numbers, obtained by the time-honored strategy of *canonicalization by optimization*. We encode each labeled graph as an integer and then take the maximum encoding over all relabelings. The maximizing relabeling yields a canonical adjacency matrix; the maximal integer is the canonical name. We call the resulting integer the **graph linear notation** of the graph.

The contribution is twofold. Mathematically, we give clean, self-contained proofs that this familiar recipe is correct in both directions (soundness and completeness). Foundationally, every statement below has been machine-checked in Lean 4 with Mathlib, so the invariant is certified, not merely argued.

---

## 2. Definitions

Throughout, fix $n \in \mathbb{N}$ and work with simple graphs on the vertex type $\mathrm{Fin}\,n = \{0,1,\dots,n-1\}$. We write $G.\mathrm{Adj}\,i\,j$ for the proposition that vertices $i$ and $j$ are adjacent in $G$; adjacency is symmetric and irreflexive.

### 2.1 Relabeling (the permutation action)

**Definition 2.1 (Permuted graph).** For a permutation $\sigma \in \mathrm{Sym}(\mathrm{Fin}\,n)$ and a graph $G$, define the *relabeled graph* $\mathrm{permuteGraph}(\sigma, G)$ by
$$\big(\mathrm{permuteGraph}(\sigma, G)\big).\mathrm{Adj}\,i\,j \;\;\Longleftrightarrow\;\; G.\mathrm{Adj}\,(\sigma i)\,(\sigma j).$$
Formally this is the comap of $G$ along $\sigma$. Two basic identities hold:

- **Identity:** $\mathrm{permuteGraph}(1, G) = G$ (`permuteGraph_one`).
- **Composition (contravariant):** $\mathrm{permuteGraph}(\tau, \mathrm{permuteGraph}(\sigma, G)) = \mathrm{permuteGraph}(\sigma\tau, G)$ (`permuteGraph_comp`).

### 2.2 Isomorphism

**Definition 2.2 (Explicit graph isomorphism).** Graphs $G$ and $H$ are *isomorphic*, written $\mathrm{IsGraphIso}(G,H)$, if there is a permutation $\sigma$ with
$$\forall\, i\,j,\quad G.\mathrm{Adj}\,i\,j \;\Longleftrightarrow\; H.\mathrm{Adj}\,(\sigma i)\,(\sigma j).$$

**Lemma 2.3 (Isomorphism as relabeling).** $\mathrm{IsGraphIso}(G,H)$ holds if and only if $G = \mathrm{permuteGraph}(\sigma, H)$ for some $\sigma$ (`isGraphIso_iff_eq_permute`).

*Proof.* Unfolding Definition 2.1, the condition $G.\mathrm{Adj}\,i\,j \Leftrightarrow H.\mathrm{Adj}\,(\sigma i)(\sigma j)$ for all $i,j$ is exactly the statement that the adjacency relations of $G$ and $\mathrm{permuteGraph}(\sigma, H)$ coincide, i.e. that the two graphs are equal by extensionality. $\square$

### 2.3 The adjacency code

**Definition 2.4 (Adjacency bit).** For a graph $G$ and vertices $i, j$, set
$$\mathrm{adjBit}(G, i, j) = \begin{cases} 1 & \text{if } G.\mathrm{Adj}\,i\,j,\\ 0 & \text{otherwise.}\end{cases}$$

**Definition 2.5 (Adjacency code).** The *adjacency code* of $G$ is the natural number
$$\mathrm{adjCode}(G) \;=\; \sum_{i \in \mathrm{Fin}\,n}\ \sum_{j \in \mathrm{Fin}\,n}\ \mathrm{adjBit}(G, i, j)\cdot 2^{\,i\cdot n + j}.$$
Equivalently, reading the $n\times n$ adjacency matrix in row-major order produces an $n^2$-bit binary numeral whose value is $\mathrm{adjCode}(G)$. The exponent function $(i,j)\mapsto i\cdot n + j$ assigns each ordered cell a distinct bit position.

### 2.4 Graph linear notation

The set of codes realized by all relabelings of $G$,
$$\mathrm{Orbit}(G) \;=\; \{\, \mathrm{adjCode}(\mathrm{permuteGraph}(\sigma, G)) \;:\; \sigma \in \mathrm{Sym}(\mathrm{Fin}\,n) \,\},$$
is a finite, nonempty subset of $\mathbb{N}$ (nonempty because the identity permutation always contributes; this is `orbitCodes_nonempty`).

**Definition 2.6 (Graph linear notation).** The *graph linear notation* of $G$ is
$$\mathrm{gln}(G) \;=\; \max\ \mathrm{Orbit}(G) \;=\; \max_{\sigma \in \mathrm{Sym}(\mathrm{Fin}\,n)}\ \mathrm{adjCode}(\mathrm{permuteGraph}(\sigma, G)).$$

---

## 3. The encoding is injective

The first pillar is that distinct labeled graphs receive distinct codes.

### 3.1 Distinct bit positions

**Lemma 3.1 (Cell positions are distinct).** The map $(i,j)\mapsto i\cdot n + j$ from $\mathrm{Fin}\,n \times \mathrm{Fin}\,n$ to $\mathbb{N}$ is injective (`pairEncode_injective`).

*Proof.* Suppose $a\cdot n + b = c\cdot n + d$ with $b, d < n$. Reducing modulo $n$ gives $b = d$ (since $(a n + b)\bmod n = b$ when $b<n$). Cancelling the equal remainders leaves $a\cdot n = c\cdot n$; as $n>0$ (it bounds $b$), we cancel to get $a = c$. Hence $(a,b)=(c,d)$. $\square$

This is the combinatorial heart: each ordered pair of vertices occupies its own power of two, so the $n^2$ bits never overlap.

### 3.2 Binary expansions are unique

**Lemma 3.2 (Bit-coefficient uniqueness).** Let $\iota$ be a finite index type, $e:\iota\to\mathbb{N}$ an injective exponent function, and $f, g : \iota \to \mathbb{N}$ coefficient functions with $f(i), g(i) \le 1$ for all $i$. If
$$\sum_{i} f(i)\,2^{e(i)} \;=\; \sum_{i} g(i)\,2^{e(i)},$$
then $f = g$ (`bit_coeff_injective`).

*Proof sketch.* This is uniqueness of binary representation. Suppose for contradiction that $f$ and $g$ differ somewhere, and let $A = \{ i : f(i) \ne g(i)\}$ be nonempty. Form the integer identity $\sum_{i\in A}(f(i)-g(i))\,2^{e(i)} = 0$ (the terms outside $A$ cancel pairwise). Let $m \in A$ minimize $e$ over $A$. Factor out $2^{e(m)}$, which is nonzero, to obtain $\sum_{i\in A}(f(i)-g(i))\,2^{\,e(i)-e(m)} = 0$. Reduce this identity modulo $2$: every term with $i \ne m$ has $e(i) - e(m) \ge 1$ (here injectivity of $e$ guarantees strict inequality, since $e(i)\ne e(m)$ and $e(i)\ge e(m)$), so those terms vanish mod $2$, leaving $(f(m) - g(m)) \equiv 0 \pmod 2$. But $f(m), g(m) \in \{0,1\}$ with $f(m)\ne g(m)$ forces $f(m)-g(m) = \pm 1$, which is odd — a contradiction. Hence $A = \varnothing$ and $f = g$. $\square$

### 3.3 Code injectivity

**Theorem 3.3 (Adjacency code is injective).** The map $\mathrm{adjCode} : \mathrm{SimpleGraph}(\mathrm{Fin}\,n) \to \mathbb{N}$ is injective (`adjCode_injective`).

*Proof.* Suppose $\mathrm{adjCode}(G) = \mathrm{adjCode}(H)$. Re-index the double sum of Definition 2.5 as a single sum over pairs $p = (i,j) \in \mathrm{Fin}\,n\times\mathrm{Fin}\,n$, with exponent $e(p) = p_1\cdot n + p_2$ (injective by Lemma 3.1) and coefficients $f(p) = \mathrm{adjBit}(G, p_1, p_2)$, $g(p) = \mathrm{adjBit}(H, p_1, p_2)$, each $\le 1$. The hypothesis says $\sum_p f(p)2^{e(p)} = \sum_p g(p)2^{e(p)}$, so Lemma 3.2 yields $f = g$, i.e. $\mathrm{adjBit}(G,i,j) = \mathrm{adjBit}(H,i,j)$ for all $i,j$. Since the bit equals $1$ exactly when its vertices are adjacent, $G.\mathrm{Adj}\,i\,j \Leftrightarrow H.\mathrm{Adj}\,i\,j$ for all $i,j$, and by extensionality $G = H$. $\square$

---

## 4. Graph linear notation is a complete invariant

### 4.1 The maximum is attained

**Theorem 4.1 (Attainment).** For every $G$ there exists $\sigma$ with $\mathrm{gln}(G) = \mathrm{adjCode}(\mathrm{permuteGraph}(\sigma, G))$ (`gln_attained`).

*Proof.* $\mathrm{gln}(G)$ is the maximum of the finite nonempty set $\mathrm{Orbit}(G)$, hence is an element of that set. By definition of $\mathrm{Orbit}(G)$ as an image, any element equals $\mathrm{adjCode}(\mathrm{permuteGraph}(\sigma, G))$ for some witnessing $\sigma$. $\square$

The witnessing $\sigma$ defines a *canonical labeling*; the relabeled graph $\mathrm{permuteGraph}(\sigma, G)$ is the *canonical form*, and its code is the maximal one.

### 4.2 Invariance

**Theorem 4.2 (Isomorphism invariance).** If $\mathrm{IsGraphIso}(G,H)$ then $\mathrm{gln}(G) = \mathrm{gln}(H)$ (`gln_iso_invariant`).

*Proof sketch.* By Lemma 2.3, $G = \mathrm{permuteGraph}(\rho, H)$ for some $\rho$. Using the composition law `permuteGraph_comp`, for any $\sigma$ we have $\mathrm{permuteGraph}(\sigma, G) = \mathrm{permuteGraph}(\rho\sigma, H)$. As $\sigma$ ranges over all permutations, so does $\rho\sigma$ (left multiplication by $\rho$ is a bijection of the symmetric group). Therefore the two orbit sets coincide,
$$\mathrm{Orbit}(G) = \{\mathrm{adjCode}(\mathrm{permuteGraph}(\rho\sigma, H)) : \sigma\} = \mathrm{Orbit}(H),$$
and equal finite sets have equal maxima: $\mathrm{gln}(G) = \mathrm{gln}(H)$. $\square$

### 4.3 Completeness

**Theorem 4.3 (Completeness).** If $\mathrm{gln}(G) = \mathrm{gln}(H)$ then $\mathrm{IsGraphIso}(G,H)$ (`gln_complete`).

*Proof sketch.* By Theorem 4.1, choose $\sigma$ and $\tau$ attaining the maxima:
$$\mathrm{gln}(G) = \mathrm{adjCode}(\mathrm{permuteGraph}(\sigma, G)), \qquad \mathrm{gln}(H) = \mathrm{adjCode}(\mathrm{permuteGraph}(\tau, H)).$$
The hypothesis equates the two right-hand sides, so by injectivity (Theorem 3.3),
$$\mathrm{permuteGraph}(\sigma, G) = \mathrm{permuteGraph}(\tau, H).$$
Both sides are relabelings of $G$ and $H$ respectively; composing the relabelings (via `permuteGraph_comp` and inverting $\sigma$) exhibits $G$ as a relabeling of $H$. Concretely, applying $\mathrm{permuteGraph}(\sigma^{-1}, -)$ to both sides and simplifying with the composition and identity laws gives $G = \mathrm{permuteGraph}(\tau\sigma^{-1}, H)$, so by Lemma 2.3, $\mathrm{IsGraphIso}(G,H)$. $\square$

### 4.4 The main theorem

**Theorem 4.4 (Complete invariant).** For all graphs $G, H$ on $\mathrm{Fin}\,n$,
$$\mathrm{gln}(G) = \mathrm{gln}(H) \quad\Longleftrightarrow\quad \mathrm{IsGraphIso}(G,H). \qquad (\texttt{gln\_eq\_iff\_iso})$$

*Proof.* Combine Theorem 4.2 (forward via invariance, contrapositive supplies one direction) and Theorem 4.3 (completeness gives the other). The "if" direction is Theorem 4.2; the "only if" direction is Theorem 4.3. $\square$

This is the principal result: graph linear notation is a complete numeric invariant for finite simple graphs, with both soundness (isomorphic graphs share a notation) and completeness (a shared notation forces isomorphism).

---

## 5. Algorithms

### 5.1 Computing the adjacency code

Given the adjacency matrix of $G$, the code is computed directly from Definition 2.5. Reading $n^2$ cells and accumulating powers of two costs $O(n^2)$ bit operations on an integer of $O(n^2)$ bits.

```
function ADJCODE(A: n×n boolean matrix) -> integer:
    code <- 0
    for i in 0..n-1:
        for j in 0..n-1:
            if A[i][j]:
                code <- code + 2^(i*n + j)
    return code
```

### 5.2 Computing graph linear notation (brute force)

By Definition 2.6, $\mathrm{gln}(G)$ enumerates all $n!$ permutations, relabels, codes, and takes the maximum. This realizes the canonical labeling explicitly.

```
function GLN(A: n×n boolean matrix) -> integer:
    best <- -infinity
    for sigma in all permutations of {0,...,n-1}:
        B[i][j] <- A[sigma(i)][sigma(j)]   for all i, j
        c <- ADJCODE(B)
        if c > best: best <- c
    return best
```

The complexity is $O(n! \cdot n^2)$ integer operations — exponential, and intended as a *definitionally faithful* reference rather than a practical canonizer. It mirrors the structure of the proof: the maximum over the orbit is exactly $\mathrm{gln}$.

### 5.3 Isomorphism testing via notation

Theorem 4.4 reduces isomorphism testing to integer comparison:

```
function ARE_ISOMORPHIC(A, B) -> bool:
    return GLN(A) == GLN(B)
```

Correctness is precisely `gln_eq_iff_iso`. While not asymptotically faster than direct search, it cleanly separates the *invariant* (a number) from the *decision* (equality), which is the conceptual payoff.

---

## 6. Applications and consequences

**Counting isomorphism classes.** Because $\mathrm{gln}$ is a complete invariant, the number of distinct values it takes on $\mathrm{SimpleGraph}(\mathrm{Fin}\,n)$ equals the number of isomorphism classes of graphs on $n$ vertices. For $n = 0,1,2,3,4,5,6,\dots$ this is $1,1,2,4,11,34,156,\dots$ (the sequence A000088). Each fiber of $\mathrm{gln}$ is exactly one isomorphism class, so $|\mathrm{image}(\mathrm{gln})| = A000088(n)$.

**Canonical labeling.** The attaining permutation of Theorem 4.1 is a canonical labeling, and the relabeled graph is a canonical representative. This underlies practical deduplication: databases of molecular graphs, program call graphs, and combinatorial structures can store one canonical form per class.

**Dictionary order and notations.** Since the highest set bit dominates the integer order, $\mathrm{gln}$ realizes a lexicographic maximization of the adjacency bit-string, connecting the invariant to standard canonical-form definitions used in nauty/Traces-style canonicalization.

---

## 7. Discussion and limitations

Graph linear notation provides a mathematically airtight *definition* of a canonical name and a *certified* proof of completeness. It does not, by itself, accelerate isomorphism testing: the reference computation is exponential in $n$. The value of the result is foundational — it pins down precisely what a numeric canonical invariant should satisfy and verifies that the maximize-over-relabelings recipe meets the specification in both directions.

Two design choices deserve comment. First, encoding *both* off-diagonal cells $(i,j)$ and $(j,i)$ (rather than only the upper triangle) is harmless: symmetry of simple graphs means the two bits always agree, and injectivity holds regardless. Second, working over $\mathrm{Fin}\,n$ with the symmetric group action is what makes "isomorphism = relabeling" a clean, formalizable statement (Lemma 2.3).

---

## 8. Future directions

The following research directions extend the formalized core (injectivity of the code, attainment of the maximum, and the completeness equivalence $\mathrm{gln}(G) = \mathrm{gln}(H) \Leftrightarrow G \cong H$).

**Conjecture 1 — The image of $\mathrm{gln}$ enumerates A000088.** For every $N$, the number of distinct values of $\mathrm{gln}$ over $\mathrm{SimpleGraph}(\mathrm{Fin}\,N)$ equals $A000088(N)$: $1, 1, 2, 4, 11, 34, 156, \dots$. Completeness turns the fiber structure of $\mathrm{gln}$ into a bijection between its image and the set of isomorphism classes, so counting notations *is* counting graphs. With the equivalence formalized, the remaining step is a finite, decidable cardinality computation of $|\mathrm{image}(\mathrm{gln})|$.

**Conjecture 2 — Order-faithful canonical labelings exist but are not unique.** The maximizing *graph* (canonical form) is unique, yet the set of maximizing *permutations* has cardinality exactly $|\mathrm{Aut}(G)|$ for every $G$. The maximizing permutations form a coset of the automorphism group: if $\sigma, \tau$ both maximize, then $\sigma\tau^{-1}$ fixes the canonical matrix, i.e. is an automorphism. Pairing uniqueness of the canonical graph with the symmetric-group action makes this an orbit–stabilizer count.

**Conjecture 3 — Notation is monotone under edge addition only up to relabeling.** Adding an edge to $G$ can *decrease* $\mathrm{gln}$ (because the maximizing ordering may change), but the per-ordering code restricted to a fixed labeling is monotone. The separation between per-ordering code (monotone) and the maximized $\mathrm{gln}$ (not monotone) can be probed with explicit $4$-vertex examples; maximization over orderings breaks naive monotonicity because the bit an edge contributes depends on where the optimizer places its endpoints.

**Conjecture 4 — A probabilistic concentration of notations.** For the Erdős–Rényi model $G(n, 1/2)$, the normalized notation $\log_2(\mathrm{gln}(G)) / n^2$ concentrates around $1/2$ with fluctuations $o(1)$ in probability, reflecting that roughly half of the $n^2$ ordered cells are set in the maximizing ordering. Since the code is a sum of $2^{\mathrm{idx}}$ over set cells, its logarithm is governed by the highest set bit — the largest index the optimizer can occupy with an edge, a max-type extremal quantity. This connects the deterministic invariant to the probabilistic domain.

---

## 9. Conclusion

We defined graph linear notation $\mathrm{gln}(G)$ as the maximum binary adjacency code over all vertex relabelings, and established that it is a complete invariant for graph isomorphism: $\mathrm{gln}(G) = \mathrm{gln}(H) \Leftrightarrow G \cong H$. The proof rests on three certified facts — distinct bit positions (Lemma 3.1), uniqueness of binary expansions (Lemma 3.2), and injectivity of the code (Theorem 3.3) — together with attainment of the maximum (Theorem 4.1) and the symmetric-group orbit argument (Theorems 4.2–4.3). The construction is a clean, fully verified instance of canonicalization by optimization.
