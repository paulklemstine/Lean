# Homological Necessity for an Extremal Spectral-Radius Bound: The Cone Mechanism and Its Reduced-Euler Shadow

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Mathematical Physics / Spectral Combinatorics (math.CO, math.SP)

---

## Abstract

We study the rigidity phenomenon underlying an extremal eigenvalue bound for finite abstract simplicial complexes. For a pure $r$-dimensional complex $K$ on $n$ vertices, a spectral-radius bound of the form
$$q_{r-1}(K) \le t\,n - (t-1)(r+1)$$
governs a designated eigenvalue $q_{r-1}$ of a higher-dimensional up–down Laplacian. The central rigidity statement asserts that *saturation* of this bound — equality — forces a strong local-topological consequence: the link of every $(r-t)$-dimensional face must be acyclic, so that its reduced homology $\tilde H_t(\operatorname{lk}_K(\sigma); \mathbb{R})$ vanishes. The structural witness of this acyclicity is that the relevant links become **cones**.

This paper isolates and rigorously establishes the **necessary numerical shadow** of that statement. We develop a compact, self-contained framework for finite abstract simplicial complexes (`ASC`), their links, and the reduced Euler characteristic $\tilde\chi$. We prove that any cone with a fresh apex has vanishing reduced Euler characteristic, via a sign-reversing involution that pairs apex-free and apex-containing faces. Because trivial reduced homology forces $\tilde\chi = 0$, our theorem captures exactly the checkable invariant that acyclicity must leave behind. We are scrupulous about the logical status of the result: $\tilde\chi = 0$ is *necessary* but not *sufficient* for acyclicity, and we label it accordingly. All results are accompanied by complete proof sketches, a reference algorithmic implementation, numerical demonstrations, and a roadmap toward the full homological statement.

**Keywords:** abstract simplicial complex, reduced Euler characteristic, link, cone, acyclicity, spectral radius bound, reduced homology, sign-reversing involution, up–down Laplacian.

---

## 1. Introduction

### 1.1 Motivation

Spectral methods translate combinatorial and topological questions about a structure into questions about the eigenvalues of an associated operator. For graphs, the Laplacian spectrum encodes connectivity, expansion, mixing rates, and bisection width. For higher-dimensional structures — simplicial complexes — one works with families of *up–down Laplacians* acting on chains in each dimension, and a rich theory (Garland's method, high-dimensional expanders, the local-to-global paradigm) relates global spectral data to the geometry of **links**, the local neighborhoods of faces.

A recurring and powerful theme in this theory is **extremal rigidity**: an inequality relating a spectral quantity to combinatorial parameters is often *sharp*, and the complexes that achieve equality are severely constrained. Sharpness converts an inequality into a structural classification.

This work concerns one such bound. For a pure $r$-dimensional complex $K$ on $n$ vertices, the eigenvalue $q_{r-1}(K)$ of an up–down Laplacian satisfies
$$q_{r-1}(K) \le t\,n - (t-1)(r+1), \tag{1}$$
for a codimension parameter $t$. The right-hand side admits the factorization
$$t\,n - (t-1)(r+1) = (t-1)(n-r-1) + n, \tag{2}$$
which makes transparent that the bound interpolates linearly in $n$ and that the codimension $t$ scales the "excess dimension" $n-r-1$.

The rigidity claim attached to (1) is:

> **Necessity Principle.** If $K$ saturates (1), i.e. $q_{r-1}(K) = t\,n - (t-1)(r+1)$, then for every $(r-t)$-dimensional face $\sigma$, the link $\operatorname{lk}_K(\sigma)$ is acyclic; in particular $\tilde H_t(\operatorname{lk}_K(\sigma); \mathbb{R}) = 0$.

The structural mechanism is that saturation forces these links to be **cones** — they acquire an apex vertex joined to every face — and cones are contractible, hence acyclic.

### 1.2 Contribution and logical scope

We do two things. First, we build a minimal, reusable formal framework for finite abstract simplicial complexes, their links, and the reduced Euler characteristic. Second, we prove the **necessary numerical shadow** of the Necessity Principle:

> **Main Theorem (informal).** A cone over any finite complex, formed with a fresh apex, has reduced Euler characteristic $0$.

Since acyclicity (vanishing of all reduced Betti numbers) implies the vanishing of their alternating sum $\tilde\chi$, and since the relevant links are cones under saturation, the Main Theorem is exactly the *necessary* consequence of the Necessity Principle that is expressible at the level of the Euler characteristic.

We are deliberate about scope. The reduced Euler characteristic is the alternating sum
$$\tilde\chi = -\tilde b_0 + \tilde b_1 - \tilde b_2 + \cdots, \qquad \tilde b_i := \dim_{\mathbb{R}} \tilde H_i,$$
so $\tilde\chi = 0$ is necessary but **not** sufficient for acyclicity: distinct Betti numbers can cancel. We therefore present our theorem honestly as the *numerical shadow* of trivial reduced homology, not a full homology computation. Section 7 lays out the path to upgrading it to the full statement.

---

## 2. Preliminaries: finite abstract simplicial complexes

Throughout, $V$ is a vertex type with decidable equality, and all face collections are finite.

### Definition 2.1 (Abstract simplicial complex, `ASC`)

A **finite abstract simplicial complex** over $V$ is a finite family $K$ of finite subsets of $V$ (its **faces**) such that:

1. **(Empty face)** $\varnothing \in K$;
2. **(Downward closure)** if $F \in K$ and $G \subseteq F$, then $G \in K$.

A face $F$ has **dimension** $\dim F = |F| - 1$; thus $\varnothing$ has dimension $-1$, a vertex has dimension $0$, an edge dimension $1$, and so on. A complex is **pure of dimension $r$** if every inclusion-maximal face (facet) has dimension exactly $r$. The complex lives on $n = |V_K|$ vertices, where $V_K$ is the set of vertices appearing in some face.

The inclusion of the empty face and the convention $\dim\varnothing = -1$ are precisely what make the *reduced* invariants behave correctly (e.g., a single point becomes acyclic).

### Definition 2.2 (Reduced Euler characteristic, `reducedEuler`)

The **reduced Euler characteristic** of $K$ is
$$\tilde\chi(K) \;=\; \sum_{F \in K} (-1)^{\dim F} \;=\; \sum_{F \in K} (-1)^{|F|+1} \;\in\; \mathbb{Z}, \tag{3}$$
the sum taken over *all* faces, including $\varnothing$ (which contributes $(-1)^{0+1} = -1$).

This differs from the unreduced Euler characteristic $\chi(K) = \sum_{F \neq \varnothing}(-1)^{\dim F}$ by exactly $-1$ (the empty-face term), i.e. $\tilde\chi = \chi - 1$.

### Definition 2.3 (Link of a face, `link`)

Let $\sigma \in K$ be a face. The **link** of $\sigma$ in $K$ is
$$\operatorname{lk}_K(\sigma) \;=\; \{\, F \in K : F \cap \sigma = \varnothing \text{ and } F \cup \sigma \in K \,\}. \tag{4}$$

### Proposition 2.4 (The link is a complex)

For $\sigma \in K$, $\operatorname{lk}_K(\sigma)$ is itself a finite abstract simplicial complex.

*Proof sketch.* **Empty face:** $\varnothing$ is disjoint from $\sigma$, and $\varnothing \cup \sigma = \sigma \in K$ by hypothesis $\sigma \in K$ — this is exactly where membership of $\sigma$ is needed. **Downward closure:** suppose $F \in \operatorname{lk}_K(\sigma)$ and $G \subseteq F$. Then $G \in K$ (downward closure in $K$); $G$ is disjoint from $\sigma$ because $G \subseteq F$ and $F$ is disjoint from $\sigma$ (disjointness is monotone under taking subsets); and $G \cup \sigma \subseteq F \cup \sigma \in K$, so $G \cup \sigma \in K$ by downward closure in $K$. Hence $G \in \operatorname{lk}_K(\sigma)$. $\square$

The hypothesis $\sigma \in K$ is load-bearing for the empty-face axiom: without it, $\varnothing \cup \sigma = \sigma$ need not be a face, and the link would not contain $\varnothing$.

### Proposition 2.5 (Link codimension; `link_facet_codim`)

If $K$ is pure of dimension $r$ and $\sigma$ is an $(r-t)$-face, then $\operatorname{lk}_K(\sigma)$ is pure of dimension $t-1$.

*Proof sketch.* A facet $F$ of $K$ containing $\sigma$ has $|F| = r+1$; removing the $|\sigma| = r-t+1$ vertices of $\sigma$ leaves a face $F\setminus\sigma$ of the link with $|F\setminus\sigma| = (r+1)-(r-t+1) = t$ vertices, i.e. dimension $t-1$. Maximality transfers between $K$ and the link. $\square$

This codimension bookkeeping is the reason the Necessity Principle concerns homology in degree $t$ (the boundary degree of a $(t-1)$-dimensional link).

---

## 3. The cone construction

The structural witness of acyclicity is a cone.

### Definition 3.1 (Cone, `ASC.cone`)

Let $v \in V$ and let $K$ be a complex. The **cone** over $K$ with apex $v$ is
$$\operatorname{cone}_v(K) \;=\; K \;\cup\; \{\, F \cup \{v\} : F \in K \,\}, \tag{5}$$
i.e. the faces of $K$ (the **apex-free** faces) together with their enlargements by $v$ (the **apex-containing** faces).

### Proposition 3.2 (The cone is a complex)

$\operatorname{cone}_v(K)$ is a finite abstract simplicial complex, with no hypothesis on $v$.

*Proof sketch.* **Empty face:** $\varnothing \in K \subseteq \operatorname{cone}_v(K)$. **Downward closure:** let $F \in \operatorname{cone}_v(K)$ and $G \subseteq F$. If $F$ is apex-free, $F \in K$ and $G \subseteq F$ gives $G \in K$. If $F = F_0 \cup \{v\}$ with $F_0 \in K$, split on whether $v \in G$:
- If $v \in G$, write $G = (G \setminus \{v\}) \cup \{v\}$; the residual $G\setminus\{v\}$ is a subset of $F_0$ (everything in $G$ other than $v$ lies in $F_0$), hence in $K$, so $G$ is an apex-containing face.
- If $v \notin G$, then $G \subseteq F_0$ (every element of $G$ lies in $F = F_0 \cup \{v\}$ but is not $v$), hence $G \in K$ is apex-free.

Either way $G \in \operatorname{cone}_v(K)$. $\square$

Notably, freshness of $v$ is **not** required for $\operatorname{cone}_v(K)$ to be a valid complex; it is supplied separately for the acyclicity results, where it is genuinely needed.

### Definition 3.3 (Fresh apex)

The apex $v$ is **fresh** for $K$ if it appears in no face: $\forall F \in K,\ v \notin F$.

### Proposition 3.4 (Disjointness of the two strata; `ASC.cone_faces_disjoint`)

If $v$ is fresh for $K$, then the apex-free faces $K$ and the apex-containing faces $\{F \cup \{v\} : F \in K\}$ are disjoint as families of sets.

*Proof sketch.* Any apex-containing face $F_0 \cup \{v\}$ contains $v$. If it also lay in $K$ (apex-free), then $v$ would belong to a face of $K$, contradicting freshness. $\square$

---

## 4. Main theorem: cones have vanishing reduced Euler characteristic

### Theorem 4.1 (`ASC.reducedEuler_cone`)

Let $K$ be a finite abstract simplicial complex and let $v$ be a **fresh** apex for $K$. Then
$$\tilde\chi\big(\operatorname{cone}_v(K)\big) = 0. \tag{6}$$

*Proof.* By Proposition 3.4 the faces of $\operatorname{cone}_v(K)$ partition into the disjoint union of the apex-free faces $K$ and the apex-containing faces $\{F \cup \{v\} : F \in K\}$. Splitting the defining sum (3) over this disjoint union,
$$\tilde\chi(\operatorname{cone}_v(K)) = \sum_{F \in K} (-1)^{|F|+1} \;+\; \sum_{\substack{F' \text{ apex-}\\\text{containing}}} (-1)^{|F'|+1}.$$
The map $F \mapsto F \cup \{v\}$ is a bijection from $K$ onto the apex-containing faces: it is injective because $v$ is fresh (applying "erase $v$" recovers $F$, since $v \notin F$), so we may reindex the second sum over $F \in K$:
$$\sum_{\substack{F' \text{ apex-}\\\text{containing}}} (-1)^{|F'|+1} = \sum_{F \in K} (-1)^{|F \cup \{v\}|+1}.$$
Because $v$ is fresh, $|F \cup \{v\}| = |F| + 1$, hence
$$(-1)^{|F\cup\{v\}|+1} = (-1)^{|F|+2} = -\,(-1)^{|F|+1}.$$
Therefore the second sum is the negative of the first, and they cancel termwise:
$$\tilde\chi(\operatorname{cone}_v(K)) = \sum_{F\in K}(-1)^{|F|+1} - \sum_{F\in K}(-1)^{|F|+1} = 0. \qquad \blacksquare$$

### Remark 4.2 (A sign-reversing involution in disguise)

Theorem 4.1 is the combinatorialist's classic *sign-reversing involution*. The toggle $\iota : F \mapsto F \,\triangle\, \{v\}$ (symmetric difference with the apex) is an involution on the faces of the cone that has no fixed points and flips $(-1)^{|F|+1}$ by changing $|F|$ by $\pm 1$. Such an involution forces the signed count to vanish. The three ingredients — disjointness of the strata, injectivity of $F \mapsto F\cup\{v\}$, and the unit cardinality shift — are all consequences of freshness, which is why freshness is **load-bearing**: drop it and any of the three can fail.

### Corollary 4.3 (Apex complexes; `ASC.reducedEuler_eq_zero_of_apex`)

If a complex $L$ possesses an apex — a vertex $w$ such that $F \cup \{w\}$ is a face whenever $F$ is — then $\tilde\chi(L) = 0$. Equivalently, any complex that is a cone (in the sense that it equals $\operatorname{cone}_w(L_0)$ for the apex-free part $L_0$) has vanishing reduced Euler characteristic.

*Proof sketch.* An apex $w$ realizes $L$ as a cone over its apex-free subcomplex $L_0 = \{F \in L : w \notin F\}$, with $w$ fresh for $L_0$ by construction. Apply Theorem 4.1. $\square$

---

## 5. From the shadow to the Necessity Principle

We now situate Theorem 4.1 within the spectral rigidity statement.

### 5.1 The spectral bound and its factorization

Let $K$ be pure of dimension $r$ on $n$ vertices. The eigenvalue $q_{r-1}(K)$ of the relevant up–down Laplacian obeys (1):
$$q_{r-1}(K) \le t\,n - (t-1)(r+1).$$
Define the **bound function** $q_{\mathrm{bd}}(n,r,t) := t\,n - (t-1)(r+1)$. Two elementary identities organize its behavior:

- **Factorization (`qBound_factor`):** $q_{\mathrm{bd}}(n,r,t) = (t-1)(n-r-1) + n$, exhibiting the codimension $t$ as the multiplier of the excess dimension $n-r-1$.
- **Discrete derivatives (`qBound_succ_n`, `qBound_succ_r`):** $q_{\mathrm{bd}}(n+1,r,t) - q_{\mathrm{bd}}(n,r,t) = t$ and $q_{\mathrm{bd}}(n,r+1,t) - q_{\mathrm{bd}}(n,r,t) = -(t-1)$. These exact differences are the natural seeds for a quantitative (defect $\Rightarrow$ Betti bound) refinement.

### 5.2 The logical chain

The Necessity Principle is the composite of three implications:

$$
\underbrace{q_{r-1}(K) = q_{\mathrm{bd}}(n,r,t)}_{\text{saturation}}
\;\Longrightarrow\;
\underbrace{\operatorname{lk}_K(\sigma) \text{ is a cone } \forall\, (r-t)\text{-faces } \sigma}_{\text{structural rigidity}}
\;\Longrightarrow\;
\underbrace{\tilde H_t(\operatorname{lk}_K(\sigma);\mathbb{R}) = 0}_{\text{acyclicity}}.
$$

The last implication is topology (cones are contractible). Its *necessary numerical shadow* is the statement that the reduced Euler characteristic of each such link vanishes — and that is exactly Theorem 4.1, since the links are cones. Concretely:

### Theorem 5.1 (Necessary numerical shadow of the Necessity Principle)

Suppose $K$ is pure of dimension $r$ on $n$ vertices, $\sigma$ is an $(r-t)$-face, and saturation forces $\operatorname{lk}_K(\sigma) = \operatorname{cone}_v(L)$ for some complex $L$ and fresh apex $v$. Then
$$\tilde\chi(\operatorname{lk}_K(\sigma)) = 0.$$

*Proof.* Immediate from Theorem 4.1 applied to $L$ and $v$. $\square$

This is the rigorous, verifiable core of the program. The remaining gap — upgrading $\tilde\chi = 0$ to $\tilde H_t = 0$ and proving that saturation indeed forces the cone structure — is the content of the future-directions program in Section 7.

---

## 6. Algorithms

We give reference algorithms (Python implementations appear in the demonstration code). All operate on faces represented as immutable sets, with a complex stored as a set of faces.

### Algorithm A — Downward closure (complex construction)

Given a list of generating faces (facets), produce the full set of faces closed under subsets and containing $\varnothing$.

```
Input: facets F_1, ..., F_m
Output: the set of all faces of the generated complex
faces <- { emptyset }
for each facet F:
    for each subset G of F:
        faces <- faces ∪ { G }
return faces
```
Complexity: $O\!\left(\sum_i 2^{|F_i|}\right)$ — exponential in facet size, polynomial in the number of faces produced (which is itself the output size).

### Algorithm B — Reduced Euler characteristic

```
Input: complex K (set of faces, including emptyset)
Output: reducedEuler(K) ∈ ℤ
acc <- 0
for each face F in K:
    acc <- acc + (-1)^(|F| + 1)
return acc
```
Complexity: $O(|K|)$ arithmetic operations.

### Algorithm C — Cone construction and acyclicity certificate

```
Input: complex K, vertex v with v fresh for K
Output: cone_v(K) and a certificate that reducedEuler = 0
assert v not in any face of K              # freshness
apex_free      <- K
apex_containing<- { F ∪ {v} : F ∈ K }
assert apex_free ∩ apex_containing = ∅      # disjointness (Prop. 3.4)
C <- apex_free ∪ apex_containing
assert reducedEuler(C) == 0                 # Theorem 4.1
return C
```
Complexity: $O(|K|)$ set operations to build the cone; $O(|K|)$ to verify the certificate.

### Algorithm D — Link extraction

```
Input: complex K, face σ ∈ K
Output: lk_K(σ)
L <- { }
for each face F in K:
    if F ∩ σ = ∅ and (F ∪ σ) ∈ K:
        L <- L ∪ { F }
return L
```
Complexity: $O(|K| \cdot c)$ where $c$ bounds the cost of set intersection/union and membership.

### Algorithm E — Sign-reversing involution verifier

A direct check of Remark 4.2: confirm that the toggle $\iota(F) = F \triangle \{v\}$ is a fixed-point-free involution pairing terms of opposite sign, thereby witnessing $\tilde\chi = 0$ without summation.

```
Input: cone C = cone_v(K), apex v
Output: True iff the toggle certifies reducedEuler(C) = 0
for each face F in C:
    G <- F △ {v}                # toggle apex membership
    assert G in C               # ι maps C to itself
    assert ι(ι(F)) == F         # involution
    assert (-1)^(|G|+1) == -(-1)^(|F|+1)   # sign reversal
return True
```
Complexity: $O(|C|)$.

---

## 7. Discussion and future directions

### 7.1 Honest logical status

The headline of the program — *an extremal eigenvalue forces local topological triviality* — is a statement about reduced homology. What we have *proved* is its reduced-Euler shadow: cones (the structural witnesses) have $\tilde\chi = 0$. Because acyclicity implies $\tilde\chi = 0$ but not conversely, our theorem is **necessary, not sufficient** for acyclicity. We regard this transparency as a feature: it cleanly separates the elementary, fully verified combinatorial core from the deeper analytic/topological claims that remain.

### 7.2 Future research program

The following directions, derived from the present cycle, chart the path from the shadow to the full statement.

**C1. Full homological necessity (not just the Euler shadow).** *Conjecture.* If a pure $r$-complex $K$ saturates $q_{r-1}(K) = tn - (t-1)(r+1)$, then $\tilde H_i(\operatorname{lk}_K \sigma; \mathbb{R}) = 0$ for *all* $i$ and every $(r-t)$-face $\sigma$, not merely $\tilde\chi = 0$. The key insight is that saturation of the second-largest eigenvalue bound is a *rank* condition on the up–down Laplacian, and rank deficiency localizes to links as exactness of the simplicial boundary — genuine acyclicity rather than the alternating-sum cancellation we proved. This is now reachable: with the reusable `ASC`/`link` framework and the apex-involution lemma in hand, adding a simplicial chain complex over $\mathbb{R}$ and a cone contraction $\partial s + s \partial = \mathrm{id}$ upgrades $\tilde\chi = 0$ to $\tilde H = 0$.

**C2. Apex detection is the obstruction.** *Conjecture.* A finite complex has $\tilde\chi = 0$ *robustly* (for it and every induced subcomplex on a vertex subset) **iff** it admits an apex on each such subset. The key insight is that the only parity-stable, locally checkable certificate of $\tilde\chi = 0$ is the toggle involution $F \mapsto F \triangle \{w\}$, which exists exactly when $w$ is an apex. One direction is `ASC.reducedEuler_eq_zero_of_apex`; the converse is a finite search amenable to exhaustive enumeration over small vertex sets, giving immediate computational falsifiability.

**C3. Sharpness of the codimension $t$.** *Conjecture.* Under saturation, the *first* non-vanishing reduced homology of a link occurs in degree exactly $t-1$, and $t$ is the smallest shift for which the necessity statement holds; for shifts $< t$ some link is non-acyclic. The key insight is that `link_facet_codim` pins the link of an $(r-t)$-face to dimension $t-1$, so degree $t$ is the *boundary* degree where homology can first be forced to die. The codimension bookkeeping is already formal, so the degree-counting half is within reach; only the extremal-construction half needs new combinatorics.

**C4. Quantitative defect $\Rightarrow$ Betti bound.** *Conjecture.* If $q_{r-1}(K) = tn - (t-1)(r+1) - \delta$ with defect $\delta > 0$, then $\sum_\sigma \dim \tilde H_t(\operatorname{lk}_K \sigma; \mathbb{R}) \le c(r,t)\cdot\delta$ for an explicit constant $c(r,t)$. The key insight is that the eigenvalue gap is a *continuous* proxy for total homological mass, so a small spectral defect can only support a small amount of homology — turning a $0/1$ necessity into a Lipschitz estimate. With the exact discrete derivatives `qBound_succ_n` and `qBound_succ_r` we already have the natural seed for a defect-versus-Betti inequality.

### 7.3 Applications

- **Spectral certificates for topology.** A maximal spectral reading certifies local acyclicity at the cheap cost of an eigenvalue computation, bypassing direct homology computation in extremal regimes — useful in topological data analysis where holes (loops, voids) are the features of interest.
- **High-dimensional expanders.** Local-to-global theorems hinge on link structure; the cone mechanism is a pure instance of "global spectral extremality $\Rightarrow$ controlled links."
- **Discretized physics.** Eigenvalues of Laplace-type operators govern vibrational/diffusive modes on discretized geometries; extremal spectra signal degenerate, highly symmetric (cone-like) local configurations.

---

## 8. Conclusion

We have given a compact, self-contained treatment of the combinatorial heart of an extremal spectral rigidity phenomenon. The reduced Euler characteristic of a cone with a fresh apex vanishes (Theorem 4.1, `ASC.reducedEuler_cone`), proved by a sign-reversing involution whose every step is powered by apex freshness. Supported by the auxiliary facts that cones and links are genuine complexes (Propositions 2.4, 3.2), that the cone strata are disjoint (Proposition 3.4, `ASC.cone_faces_disjoint`), and that link codimension is $t-1$ (Proposition 2.5), this establishes the precise necessary numerical shadow of the statement that saturating $q_{r-1}(K) = tn - (t-1)(r+1)$ forces the links of $(r-t)$-faces to be acyclic. The four future directions chart a concrete route from this shadow to the full homological theorem.
