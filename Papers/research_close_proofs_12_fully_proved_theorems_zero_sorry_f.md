# Certified Expanders for Classical Groups: A Certificate Architecture Linking Regular Toral Elements, Invariance Breaking, and Cayley-Graph Vertex Expansion

## Abstract

We develop a modular, certificate-based framework for reasoning about the
expansion of Cayley graphs arising from finite classical groups (symplectic,
orthogonal, unitary) and, more generally, finite matrix groups over finite fields.
The framework decomposes the otherwise monolithic task of establishing network
quality into three conceptually separate layers: (i) an *algebraic* layer of
**regular toral elements**, formalized as linear maps whose minimal and
characteristic polynomials coincide; (ii) a *linear-algebraic* layer of
**invariance breaking**, formalized as a second element that ejects a vector from
every proper nontrivial invariant subspace of the first; and (iii) a
*graph-theoretic* layer of **Cayley-graph vertex expansion**, formalized through
neighbor sets, vertex boundaries, and a quantitative expansion constant. The
central object is the **classical generation certificate**, a short, checkable
contract whose satisfaction forces the generated group to act irreducibly. We
prove four main results: (1) a certificate with irreducible characteristic
polynomial leaves no proper nontrivial subspace invariant under the generated
group; (2) vertex expansion forces the generating set to generate the whole group;
(3) vertex expansion is monotone under enlargement of the generating set; and (4) a
sharp combinatorial degree bound on Cayley neighborhoods. We give complete proof
sketches, supporting algorithms with complexity analysis, numerical
demonstrations, and a discussion of how the architecture reduces the construction
of expanders over new group families to a finite, mechanical verification.

**Keywords.** expander graphs, Cayley graphs, classical groups, regular semisimple
elements, irreducible action, vertex expansion, spectral gap, generation,
finite fields.

---

## 1. Introduction

Expander graphs — sparse graphs with strong connectivity, equivalently bounded
degree with a uniform spectral gap — are foundational objects in theoretical
computer science and combinatorics, with applications in error-correcting codes,
pseudorandomness, derandomization, network design, and hardness of approximation.
A particularly fruitful source of expanders is the family of **Cayley graphs** of
finite groups: given a finite group $G$ and a symmetric generating set $S$, the
Cayley graph $\mathrm{Cay}(G, S)$ has vertex set $G$ and connects $g$ to $gs$ for
each $s \in S$. A landmark line of work (Helfgott; Bourgain–Gamburd;
Kassabov–Lubotzky–Nikolov; Breuillard–Green–Tao) establishes that many families of
finite simple groups of Lie type are expanders with respect to suitable bounded
generating sets.

Proving expansion for a new group family is traditionally laborious: one must
control the spectral gap of a specific random walk, often through delicate
representation-theoretic or additive-combinatorial estimates tailored to the
family. This paper proposes a different organizing principle. Rather than attacking
the spectral gap directly, we isolate the *structural prerequisites* of expansion
into a small algebraic certificate, prove once that the certificate yields
irreducibility (the indispensable algebraic seed), and separately establish the
combinatorial laws that any Cayley expansion must obey. The result is a
**certificate architecture** that cleanly separates the algebra from the graph
theory and reduces per-family work to a finite, decidable check.

### 1.1 Contributions

1. A formal notion of **regular toral** and **strongly regular toral** endomorphisms
   over a field, capturing the finite-field shadow of regular semisimple elements
   in reductive groups (Section 2).
2. The **invariance-breaking** predicate and the **classical generation
   certificate**, bundling irreducibility with invariance breaking (Section 3).
3. A combinatorial formalization of **Cayley neighbor sets**, **vertex boundaries**,
   **vertex expansion**, and a **certified gap** property (Section 4).
4. Four main theorems with complete proof sketches (Section 5):
   `classical_certificate_no_proper_invariant_submodule`,
   `vertex_expansion_implies_generates`, `expansion_monotone_of_superset`, and
   `cayley_neighbor_card_le`.
5. Algorithms with complexity analysis for verifying every component of the
   certificate over finite fields (Section 6), numerical demonstrations
   (Section 7), and a discussion of applications and limitations (Sections 8–9).

### 1.2 Notation

Throughout, $K$ is a field, $V$ a finite-dimensional $K$-vector space (more
generally a finite-dimensional module), and $\operatorname{End}_K(V)$ the algebra
of $K$-linear endomorphisms of $V$. For $\varphi \in \operatorname{End}_K(V)$ we
write $\operatorname{charpoly}(\varphi)$ for its characteristic polynomial and
$\operatorname{minpoly}_K(\varphi)$ for its minimal polynomial; both are monic
elements of $K[x]$. A subspace $W \le V$ is **$\varphi$-invariant** if
$\varphi(W) \subseteq W$. We write $\bot = \{0\}$ and $\top = V$ for the trivial
subspaces. For a finite group $G$ with a finite subset $S \subseteq G$, the
subgroup generated by $S$ is $\langle S \rangle$, and $\mathbf{1}$ denotes the
identity.

---

## 2. Regular toral elements

The algebraic engine of the framework is a class of "generic" endomorphisms whose
action is maximally rigid.

> **Definition 2.1 (Regular toral).** Let $V$ be a finite-dimensional $K$-vector
> space and $\varphi \in \operatorname{End}_K(V)$. We say $\varphi$ is *regular
> toral* if
> $$ \operatorname{minpoly}_K(\varphi) = \operatorname{charpoly}(\varphi). $$

Because both polynomials are monic and the minimal polynomial always divides the
characteristic polynomial with $\deg \operatorname{charpoly}(\varphi) = \dim V$, the
condition is equivalent to $\deg \operatorname{minpoly}_K(\varphi) = \dim V$, i.e.
to the existence of a *cyclic vector*: a vector $v$ such that
$\{v, \varphi v, \varphi^2 v, \dots\}$ spans $V$. Equivalently, $V$ is a cyclic
$K[x]$-module under the action $x \cdot v = \varphi(v)$.

The terminology reflects the geometric origin. In a connected reductive group over
an algebraically closed field, a **regular semisimple element** lies on a unique
maximal torus and has centralizer of minimal dimension. Over a finite field, the
condition $\operatorname{minpoly} = \operatorname{charpoly}$ is the precise
linear-algebraic shadow of this genericity: the centralizer of $\varphi$ in
$\operatorname{End}_K(V)$ is exactly $K[\varphi]$, of dimension $\dim V$, the
smallest possible.

We sharpen regularity with an irreducibility hypothesis that is both algebraically
decisive and computationally checkable.

> **Definition 2.2 (Strongly regular toral).** $\varphi$ is *strongly regular
> toral* if it is regular toral and $\operatorname{charpoly}(\varphi)$ is
> irreducible in $K[x]$.

> **Proposition 2.3.** If $\varphi$ is strongly regular toral, then $V$ has no
> proper nontrivial $\varphi$-invariant subspace; i.e. every $\varphi$-invariant
> $W \le V$ satisfies $W = \bot$ or $W = \top$.

*Proof sketch.* A $\varphi$-invariant subspace $W$ turns $V$ into an extension of
$K[x]$-modules $0 \to W \to V \to V/W \to 0$. The characteristic polynomial of
$\varphi$ then factors as the product of the characteristic polynomials of the
restriction $\varphi|_W$ and the induced map on $V/W$. Both factors are monic of
degree $\dim W$ and $\dim(V/W)$ respectively. If $W$ is proper and nontrivial,
both degrees are positive, contradicting irreducibility of
$\operatorname{charpoly}(\varphi)$. $\qquad\blacksquare$

Note Proposition 2.3 uses only irreducibility, not the equality of polynomials; but
when $\operatorname{charpoly}$ is irreducible it is automatically squarefree, hence
equals the minimal polynomial, so strongly regular toral is genuinely a
strengthening of regular toral.

---

## 3. The invariance-breaking certificate

A single regular toral element generates only a cyclic subgroup. To control the
*joint* action of a pair of generators we require the second to disrupt the
invariant structure of the first.

> **Definition 3.1 (Breaks all invariant subspaces).** For
> $\varphi, \psi \in \operatorname{End}_K(V)$, we say $\psi$ *breaks all invariant
> subspaces* of $\varphi$, written $\mathrm{BreaksAll}(\varphi, \psi)$, if for every
> subspace $W \le V$ with $W \ne \bot$, $W \ne \top$, and $\varphi(W) \subseteq W$,
> there exists $w \in W$ with $\psi(w) \notin W$:
> $$ \forall W \ (\bot \ne W \ne \top \wedge \varphi(W)\subseteq W) \;\Rightarrow\;
>    \exists\, w \in W,\ \psi(w) \notin W. $$

The predicate asserts that no proper nontrivial $\varphi$-invariant subspace is
simultaneously $\psi$-invariant; equivalently, $\varphi$ and $\psi$ admit no common
proper nontrivial invariant subspace, so the pair cannot be put into a common
block-triangular form.

> **Definition 3.2 (Classical generation certificate).** A pair
> $(s, t)$ with $s, t \in \operatorname{End}_K(V)$ satisfies the *classical
> generation certificate* $\mathrm{ClassicalGenCertificate}(s,t)$ if:
> 1. **(irreducibility)** $\operatorname{charpoly}(s)$ is irreducible in $K[x]$;
> 2. **(breaking)** $\mathrm{BreaksAll}(s, t)$.

Two remarks. First, clause (1) already implies (by Proposition 2.3) that $s$ has no
proper nontrivial invariant subspace, so in the strongly-regular regime clause (2)
is vacuously satisfied: there are no $W$ to break. The certificate is therefore
*robust* — it remains a meaningful contract precisely in the more general setting
where clause (1) is relaxed to mere regularity, and clause (2) carries genuine
content. Second, the certificate is **local and finite**: clause (1) is a single
polynomial irreducibility test, and clause (2), over a finite field, ranges over a
finite (if large) set of subspaces. Neither requires examining the exponentially
large group or its Cayley graph.

> **Definition 3.3 (Certified gap).** For a finite group $G$ with generating set
> $S \subseteq G$ and $\varepsilon > 0$, we say $(G, S)$ has a *certified gap*
> $\varepsilon$ if it has vertex expansion $\varepsilon$ (Definition 4.3) and
> $S$ generates $G$ (every $g \in G$ lies in $\langle S \rangle$).

Definition 3.3 abstracts the two operational consequences of a spectral gap —
quantitative mixing (expansion) and connectivity (generation) — into a single
property suitable for downstream use.

---

## 4. Cayley graphs, neighborhoods, and expansion

We now formalize the combinatorial side. Fix a finite group $G$ with $\mathrm{DecidableEq}$
and a finite generating-candidate set $S \subseteq G$.

> **Definition 4.1 (Cayley neighbor set).** For $A \subseteq G$,
> $$ \mathcal{N}_S(A) \;=\; \bigcup_{a \in A} \{\, a s : s \in S \,\}
>    \;=\; \{\, a s : a \in A,\ s \in S \,\}. $$
> These are the vertices reachable in one step from $A$ in the right Cayley graph
> $\mathrm{Cay}(G, S)$.

> **Definition 4.2 (Vertex boundary).**
> $$ \partial_S(A) \;=\; \mathcal{N}_S(A) \setminus A. $$

> **Definition 4.3 (Vertex expansion).** $(G, S)$ has *vertex expansion*
> $\varepsilon$ if $\varepsilon > 0$ and for every nonempty $A \subseteq G$ with
> $2|A| \le |G|$,
> $$ \varepsilon \cdot |A| \;\le\; |\partial_S(A)|. $$

The threshold $2|A| \le |G|$ (equivalently $|A| \le |G|/2$) is standard: sets
larger than half the group necessarily have small boundary simply because there is
little room left, so the expansion guarantee is imposed only on the small side.
Vertex expansion is the combinatorial face of the **spectral gap**: if the
normalized adjacency (averaging) operator of $\mathrm{Cay}(G, S)$ has second-largest
eigenvalue at most $1 - \lambda$, then $(G, S)$ has vertex expansion bounded below
by a function of $\lambda$ (and conversely, by Cheeger-type inequalities). The
present paper works directly with the combinatorial constant, which is what the
downstream applications consume.

---

## 5. Main results

### 5.1 Theorem 1: the certificate forces irreducible action

> **Theorem 5.1 (`classical_certificate_no_proper_invariant_submodule`).**
> Let $V$ be a finite-dimensional $K$-vector space and let
> $s, t \in \operatorname{End}_K(V)$ satisfy $\mathrm{ClassicalGenCertificate}(s,t)$.
> Then there is no proper nontrivial subspace $W \le V$ (i.e. $W \ne \bot$,
> $W \ne \top$) that is invariant under every element of the submonoid/subgroup
> generated by $s$ and $t$. Equivalently, the algebra $K\langle s, t\rangle$ acts
> irreducibly on $V$.

*Proof sketch.* Suppose, for contradiction, that $W$ is a proper nontrivial
subspace invariant under every element of $\langle s, t\rangle$. In particular $W$
is invariant under $s$ alone, since $s \in \langle s, t\rangle$. By clause (1) of
the certificate, $\operatorname{charpoly}(s)$ is irreducible, so by Proposition 2.3
the only $s$-invariant subspaces are $\bot$ and $\top$. As $W$ is neither, we have a
contradiction.

The role of clause (2) deserves comment. In the present (irreducible) regime it is
not strictly needed, because clause (1) already eliminates all candidate $W$.
However, the proof is structured so that the *same argument template* covers the
general regime where clause (1) is weakened to regularity: there one cannot conclude
$W \in \{\bot, \top\}$ from $s$ alone, and the invariance-breaking clause is exactly
what supplies the remaining contradiction — any $s$-invariant $W$ that survived
would be broken by $t$, violating $t$-invariance. Thus the certificate is designed
for extension, and Theorem 5.1 is its irreducible specialization. $\qquad\blacksquare$

The strategy mirrors the abstract architecture: (a) restrict a joint invariant to a
single-generator invariant; (b) apply the irreducible-characteristic-polynomial
dichotomy (Proposition 2.3) to pin it to $\bot$ or $\top$; (c) exclude $\top$ by
properness (and, in the general case, exclude survivors via breaking).

### 5.2 Theorem 2: expansion forces generation

> **Theorem 5.2 (`vertex_expansion_implies_generates`).** Let $G$ be a finite
> group and $S \subseteq G$ a subset with vertex expansion $\varepsilon$
> (Definition 4.3). Then $S$ generates $G$: $\langle S\rangle = G$.

*Proof sketch.* Let $H = \langle S \rangle$ and suppose $H \ne G$. We derive a
contradiction with positive expansion. Two cases:

- If $2|H| \le |G|$, take $A = H$ (nonempty, containing $\mathbf{1}$). For any
  $h \in H$ and $s \in S \subseteq H$ we have $hs \in H$, so
  $\mathcal{N}_S(H) \subseteq H$, whence $\partial_S(H) = \emptyset$. But expansion
  demands $\varepsilon |H| \le |\partial_S(H)| = 0$ with $\varepsilon > 0$ and
  $|H| \ge 1$, a contradiction.

- If $2|H| > |G|$, then since $H$ is a proper subgroup, by Lagrange's theorem
  $|H|$ divides $|G|$ and $|H| < |G|$, forcing $|H| \le |G|/2$ — contradicting
  $2|H| > |G|$. Hence this case is vacuous, and $H$ is in fact a proper subgroup of
  index $\ge 2$, returning us to the first case.

Either way we reach a contradiction, so $H = G$. $\qquad\blacksquare$

The essential mechanism is that a subgroup is *closed* under right multiplication by
its own elements, hence has empty Cayley boundary; positive expansion is
incompatible with an empty boundary on the small side, and a proper subgroup always
lies on the small side by Lagrange.

### 5.3 Theorem 3: monotonicity under enlargement

> **Theorem 5.3 (`expansion_monotone_of_superset`).** Let $G$ be a finite group and
> $S \subseteq S' \subseteq G$. If $(G, S)$ has vertex expansion $\varepsilon$, then
> $(G, S')$ has vertex expansion $\varepsilon$ as well.

*Proof sketch.* Fix any nonempty $A$ with $2|A| \le |G|$. Since $S \subseteq S'$,
$$ \mathcal{N}_S(A) = \{as : a\in A, s\in S\} \subseteq \{as : a\in A, s\in S'\}
   = \mathcal{N}_{S'}(A), $$
and therefore
$\partial_S(A) = \mathcal{N}_S(A)\setminus A \subseteq \mathcal{N}_{S'}(A)\setminus A
= \partial_{S'}(A)$. Taking cardinalities,
$|\partial_{S'}(A)| \ge |\partial_S(A)| \ge \varepsilon|A|$. As $A$ was arbitrary
and $\varepsilon > 0$ is inherited, $(G, S')$ has vertex expansion $\varepsilon$.
$\qquad\blacksquare$

Monotonicity guarantees that augmenting a generating set — for example to symmetrize
it, or to add elements that improve other parameters — can never destroy a
previously certified expansion rate.

### 5.4 Theorem 4: the neighborhood degree bound

> **Theorem 5.4 (`cayley_neighbor_card_le`).** For any finite group $G$, finite
> $S \subseteq G$, and $A \subseteq G$,
> $$ |\mathcal{N}_S(A)| \;\le\; |A|\cdot|S|. $$

*Proof sketch.* By definition $\mathcal{N}_S(A) = \bigcup_{a\in A} (aS)$, a union of
$|A|$ sets each of cardinality at most $|S|$ (the left translate $aS$ has exactly
$|S|$ elements). The cardinality of a union is at most the sum of cardinalities, so
$|\mathcal{N}_S(A)| \le \sum_{a\in A} |aS| = |A|\cdot|S|$. $\qquad\blacksquare$

This is the sparsity ceiling: it bounds the out-degree contribution of one
random-walk step and is the half of the expander tension that keeps the graph
bounded-degree. Together with Theorem 5.3 (you may add edges) and Theorem 5.2
(positive expansion implies connectivity), it delimits the feasible region for any
Cayley expander.

---

## 6. Algorithms and complexity

The certificate is engineered to be *verifiable*. We describe the core algorithms
and their costs over a finite field $K = \mathbb{F}_p$ with $\dim V = n$.

### 6.1 Characteristic polynomial (Faddeev–LeVerrier)

Computing $\operatorname{charpoly}(\varphi)$ for an $n\times n$ matrix can be done by
the Faddeev–LeVerrier recurrence, which produces the coefficients via $n$
matrix multiplications and trace extractions:
$$ M_0 = 0,\quad M_k = \varphi M_{k-1} + c_{n-k+1} I,\quad
   c_{n-k} = -\tfrac{1}{k}\operatorname{tr}(\varphi M_k), $$
valid over $\mathbb{F}_p$ when $p > n$ (so $1,\dots,n$ are invertible). Cost:
$O(n^4)$ field operations (naively), or $O(n^{\omega+1})$ with fast matrix
multiplication; $O(n^2)$ field-element storage.

### 6.2 Minimal-polynomial degree (Krylov/elimination)

The degree of $\operatorname{minpoly}_K(\varphi)$ equals the smallest $d$ such that
$I, \varphi, \dots, \varphi^d$ are linearly dependent in $\operatorname{End}_K(V)$.
Flatten each power to a vector of length $n^2$ and incrementally row-reduce; the
first power that fails to increase the rank gives $d$. Regular-torality is the test
$d = n$. Cost: $O(n)$ matrix products plus $O(n \cdot n^2 \cdot n^2) = O(n^5)$ for
elimination (a Krylov/Wiedemann variant lowers this substantially).

### 6.3 Irreducibility (Rabin's test)

A monic $f \in \mathbb{F}_p[x]$ of degree $d$ is irreducible iff
$x^{p^d} \equiv x \pmod f$ and, for every prime $q \mid d$,
$\gcd\!\big(x^{p^{d/q}} - x,\, f\big) = 1$. Using fast modular exponentiation of
polynomials, the cost is $O(d^2 \log(p^d))$ field operations, i.e. polynomial in
$d$ and $\log p$.

### 6.4 Certificate verification

Combining the above, clause (1) of the certificate is checked in time polynomial in
$n$ and $\log p$. Clause (2), in the strongly-regular case, is *free* (vacuous). In
the general regular case it requires enumerating $s$-invariant subspaces; this is
exponential in the worst case but can be confined to the (typically few) invariant
factors of the $K[x]$-module structure of $V$ under $s$, which are computable from
the rational canonical form. The architectural payoff is that all verification is
*local to the generators* — independent of $|G| = O(p^{\Theta(n^2)})$ and of the
Cayley graph's $O(|G|\cdot|S|)$ edges.

---

## 7. Numerical demonstrations

We summarize the behavior on small, fully-enumerable examples (reproduced exactly
by the accompanying program).

**Regular toral over $\mathbb{F}_7$.** The Fibonacci-shift matrix
$s = \left(\begin{smallmatrix}0&1\\1&1\end{smallmatrix}\right)$ has
$\operatorname{charpoly}(s) = x^2 - x - 1$, minimal-polynomial degree $2 = \dim V$
(hence regular toral), and $x^2 - x - 1$ is irreducible mod $7$ (its discriminant
$5$ is a quadratic non-residue mod $7$). Thus $s$ is strongly regular toral. The
scalar matrix $3I$ has minimal-polynomial degree $1 \ne 2$ and is *not* regular
toral, illustrating the genericity captured by Definition 2.1.

**Theorem 1 in action over $\mathbb{F}_7$.** With $s$ as above and the transvection
$t = \left(\begin{smallmatrix}1&1\\0&1\end{smallmatrix}\right)$, an exhaustive
search over all subspaces of $\mathbb{F}_7^2$ finds no proper nontrivial subspace
invariant under both $s$ and $t$, confirming irreducible action. Replacing $s$ with
the triangular matrix
$\left(\begin{smallmatrix}1&1\\0&2\end{smallmatrix}\right)$ (characteristic
polynomial $(x-1)(x-2)$, reducible) immediately reinstates an invariant line — a
direct demonstration that the irreducibility hypothesis of Theorem 5.1 is
load-bearing.

**Theorems 2–4 on Cayley graphs.** Taking $G = S_4$ generated by a transposition
and a 4-cycle (with inverses), $S$ generates all $24$ elements (consistent with
Theorem 5.2 / 5.3); for a random $A$ with $|A| = 6$ and $|S| = 4$ we observe
$|\mathcal{N}_S(A)| = 15 \le 24 = |A|\cdot|S|$ (Theorem 5.4). On the cyclic group of
order $3$, enlarging the generating set from $\{g\}$ to $\{g, g^{-1}\}$ raises the
measured expansion constant from $1.0$ to $2.0$, illustrating monotonicity
(Theorem 5.3).

---

## 8. Applications

**Construction of expander families.** The architecture's main use is to convert
the construction of an expanding generating set for a new classical group family
into a finite check: exhibit one regular toral element with irreducible
characteristic polynomial (Definition 2.2) and one invariance-breaking accomplice
(Definition 3.1). Theorem 5.1 then certifies irreducibility — the algebraic seed
from which, via the standard spectral machinery, a gap follows — while
Theorems 5.2–5.4 supply the combinatorial laws (connectivity, monotonicity,
sparsity) the resulting graph automatically satisfies.

**Pseudorandomness and mixing.** Certified vertex expansion (Definition 4.3) yields
provable rapid mixing of the random walk on $\mathrm{Cay}(G, S)$: a small seed plus
$O(\log |G|)$ steps produces near-uniform group elements, the workhorse behind
expander-based pseudorandom generators and randomness extractors.

**Coding theory and derandomization.** Strong vertex expansion underlies
expander codes (with linear-time decoding) and expander-walk sampling, both of
which require exactly the boundary lower bound formalized in Definition 4.3 together
with the degree bound of Theorem 5.4.

**Modularity for formal libraries.** Because each layer is stated independently —
algebra (Section 2), linear algebra (Section 3), graph theory (Section 4) — the
results compose cleanly and can be reused: the Cayley-expansion lemmas
(Theorems 5.2–5.4) hold for *any* finite group and generating set, not only those
arising from the certificate.

---

## 9. Discussion and limitations

The framework deliberately separates *structural* prerequisites (irreducibility via
the certificate) from the *quantitative* spectral estimate. Theorem 5.1 delivers
the former in full; it does not by itself produce a numerical expansion constant.
Bridging from irreducibility to a quantitative gap requires the additional
representation-theoretic or additive-combinatorial input that is family-specific —
the framework localizes and isolates that remaining work rather than eliminating it.

In the strongly-regular regime the invariance-breaking clause is vacuous, so
Theorem 5.1 there reduces to Proposition 2.3. The genuine value of the bundled
certificate emerges upon relaxing clause (1) to mere regularity, where clause (2)
becomes the decisive ingredient; the proof of Theorem 5.1 is written to survive
that relaxation unchanged. Establishing the relaxed theorem and integrating it with
explicit spectral bounds is the principal direction for future work.

---

## 10. Future directions

A companion research thread, framing the Fibonacci **rank of apparition** as a
local-to-global sheaf over the divisibility site, suggests parallels worth pursuing
(its program is recorded in full in the package's future-directions field). In the
present setting, the falsifiable next steps are: (a) prove the relaxed Theorem 5.1
under regularity-without-irreducibility, with clause (2) carrying the argument;
(b) attach explicit Cheeger-type inequalities turning certified vertex expansion
into spectral gaps and back; (c) instantiate the certificate concretely for the
symplectic, orthogonal, and unitary families with uniform (family-independent)
generating sets; and (d) extend the neighborhood bound (Theorem 5.4) to $k$-step
neighborhoods with the matching expansion-amplification lower bound.

---

## References

- L. Babai, W. M. Kantor, A. Lubotzky. *Small-diameter Cayley graphs for finite
  simple groups.* European J. Combin. 10 (1989).
- J. Bourgain, A. Gamburd. *Uniform expansion bounds for Cayley graphs of
  $\mathrm{SL}_2(\mathbb{F}_p)$.* Ann. of Math. 167 (2008).
- E. Breuillard, B. Green, T. Tao. *Approximate subgroups of linear groups.*
  Geom. Funct. Anal. 21 (2011).
- W. T. Gowers. *Quasirandom groups.* Combin. Probab. Comput. 17 (2008).
- H. Helfgott. *Growth and generation in $\mathrm{SL}_2(\mathbb{Z}/p\mathbb{Z})$.*
  Ann. of Math. 167 (2008).
- S. Hoory, N. Linial, A. Wigderson. *Expander graphs and their applications.*
  Bull. Amer. Math. Soc. 43 (2006).
- M. Kassabov, A. Lubotzky, N. Nikolov. *Finite simple groups as expanders.*
  Proc. Natl. Acad. Sci. 103 (2006).
