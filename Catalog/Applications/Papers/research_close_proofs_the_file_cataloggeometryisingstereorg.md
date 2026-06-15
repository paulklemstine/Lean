# A Certificate Architecture for Expander Cayley Graphs from Classical Groups

## Abstract

Expander graphs are sparse networks of uniformly high connectivity, with pervasive applications in coding theory, derandomization, fault-tolerant networking, and analytic number theory. Constructing explicit bounded-degree expanders, and *certifying* the expansion of a concrete graph, are both notoriously delicate. We develop a **certificate architecture** that connects three layers — the algebraic structure of an element of a finite classical group, a linear-algebraic invariance-breaking condition, and the spectral/combinatorial expansion of the resulting Cayley graph — into a single, locally checkable criterion. The cornerstone is the notion of a **classical generation certificate**: a pair $(s,t)$ of endomorphisms of a finite-dimensional vector space such that $s$ has irreducible characteristic polynomial and $t$ maps a vector out of every proper nontrivial $s$-invariant subspace. We prove that any such pair acts irreducibly (no common invariant subspace). On the combinatorial side, we formalize vertex expansion for Cayley graphs and prove four structural theorems: positive expansion forces generation; expansion is monotone under enlargement of the generating set; expansion forces geometric growth of one-step neighborhoods (hence logarithmic diameter); and one-step neighborhoods are degree-bounded. We specialize the abstract certificate to $\mathrm{GL}_2(\mathbb{F}_p)$, where it reduces to the verifiable absence of a common eigenvector, and we frame the role of quasirandomness in delivering uniform expansion for higher-rank families. The program culminates in a precise, falsifiable conjecture of uniform certified expansion for $\mathrm{Sp}_4(\mathbb{F}_q)$. All structural theorems are stated with full mathematical content and proof sketches; the conjecture is isolated as the single open prediction.

**Keywords:** expander graphs, Cayley graphs, classical groups, regular semisimple elements, irreducible representations, vertex expansion, spectral gap, quasirandomness.

---

## 1. Introduction

A family of finite graphs $\{X_n\}$ with uniformly bounded degree $d$ is a family of **expanders** if there is a constant $\varepsilon > 0$, independent of $n$, such that every vertex subset $A$ with $|A| \le |X_n|/2$ has vertex boundary $|\partial A| \ge \varepsilon |A|$. Equivalently (up to constants), the second-largest eigenvalue of the normalized adjacency operator is bounded away from $1$ by a spectral gap. Expanders are simultaneously sparse and highly connected; their applications range from the error-correcting codes that protect storage media, to derandomization and pseudorandom generators, to robust interconnection networks, to sieve methods in number theory.

The most fruitful explicit constructions arise as **Cayley graphs** of finite groups. Given a group $G$ and a generating set $S \subseteq G$, the Cayley graph $\mathrm{Cay}(G,S)$ has vertex set $G$ and an edge $g \to gs$ for each $s \in S$. The degree is $|S|$, independent of $|G|$; thus a fixed-size $S$ that yields expansion across a family $\{G_n\}$ produces bounded-degree expanders for free. Deep results — Helfgott's growth theorem in $\mathrm{SL}_2(\mathbb{F}_p)$, the Bourgain–Gamburd machine, and Kassabov–Lubotzky–Nikolov's theorem that finite simple groups are expanders — establish exactly such families. However, these arguments are intricate, and *certifying* expansion for a concrete group with concrete generators remains hard: expansion quantifies over all exponentially many subsets.

This paper proposes and rigorously develops a **certificate-based** route. Rather than verify expansion directly, we (i) seed the group with two elements satisfying a short, locally checkable algebraic certificate that forces irreducible action — the representation-theoretic engine of every expansion proof for classical groups — and (ii) develop the combinatorial theory of vertex expansion as an independent, fully proved layer, including the converse fact that expansion *certifies* generation. The two layers meet in the classical-group setting, where the certificate's irreducibility is the structural input and quasirandomness supplies the uniformity.

### Contributions

1. **Regular toral elements** (§2): a finite-field formalization of regular semisimple elements via the equality of minimal and characteristic polynomials, strengthened to *strongly regular toral* by irreducibility of the characteristic polynomial.
2. **The classical generation certificate** (§3): a bundled, checkable pair condition (irreducible charpoly $+$ invariance-breaking) with the proved consequence of irreducible action (Theorem 1).
3. **A combinatorial theory of Cayley vertex expansion** (§4): definitions of neighbor set, vertex boundary, and vertex expansion, with four proved theorems (Theorems 2–5 below and the degree bound).
4. **A concrete, hand-checkable specialization to $\mathrm{GL}_2(\mathbb{F}_p)$** (§5): the certificate reduces to absence of a common eigenvector (Theorem 6).
5. **Quasirandomness and the uniform-expansion conjecture** (§6): the role of representation dimension and a precise falsifiable prediction for $\mathrm{Sp}_4(\mathbb{F}_q)$.

Throughout, $K$ is a field, $V$ a finite-dimensional $K$-vector space, and $\mathrm{End}_K(V)$ its algebra of linear endomorphisms. For a finite group $G$, $\mathrm{Fintype}$-cardinality is $|G|$.

---

## 2. Regular Toral Elements

The algebraic seed of the certificate is an element whose linear action is as "generic" as possible.

**Definition 2.1 (Regular toral).** Let $\varphi \in \mathrm{End}_K(V)$ with $V$ finite-dimensional. We say $\varphi$ is *regular toral* if its minimal polynomial equals its characteristic polynomial:
$$\mathrm{minpoly}_K(\varphi) = \mathrm{charpoly}(\varphi).$$

Equality of minimal and characteristic polynomials is precisely the condition that $\varphi$ be a *cyclic* (non-derogatory) operator: there is a vector $v$ whose iterates $v, \varphi v, \varphi^2 v, \dots$ span $V$. Over a finite field, this is the shadow of a *regular semisimple* element of a reductive group — an element lying on a unique maximal torus with centralizer of minimal dimension, whence the name "toral."

**Definition 2.2 (Strongly regular toral).** $\varphi$ is *strongly regular toral* if it is regular toral and, in addition, $\mathrm{charpoly}(\varphi)$ is irreducible over $K$.

**Proposition 2.3 (No invariant subspace).** If $\varphi$ is strongly regular toral, then $V$ has no proper nontrivial $\varphi$-invariant subspace; equivalently, $K[\varphi]$ acts irreducibly on $V$ and $V \cong K[x]/(\mathrm{charpoly}(\varphi))$ as a $K[x]$-module, a field extension of $K$.

*Proof sketch.* Irreducibility of the characteristic polynomial $p = \mathrm{charpoly}(\varphi)$ means $K[x]/(p)$ is a field. Since $\varphi$ is cyclic, $V \cong K[x]/(p)$ as $K[x]$-modules with $x$ acting as $\varphi$. A $\varphi$-invariant subspace is a $K[x]$-submodule, i.e. an ideal of the field $K[x]/(p)$; a field has only the ideals $\{0\}$ and the whole ring. Hence the only $\varphi$-invariant subspaces are $\bot$ and $\top$. $\square$

Proposition 2.3 isolates the single algebraic fact the certificate exploits: an irreducible characteristic polynomial annihilates every internal "trap." The strengthening from regular toral to *strongly* regular toral is exactly what converts a genericity condition into the absence of invariant subspaces.

---

## 3. The Classical Generation Certificate

A single regular element acts irreducibly through $K[\varphi]$, but to generate a large subgroup we need a *second* element that prevents the pair from sharing any invariant structure.

**Definition 3.1 (Invariance-breaking).** For $\varphi, \psi \in \mathrm{End}_K(V)$, say $\psi$ *breaks all invariant subspaces of* $\varphi$, written $\mathrm{Breaks}(\varphi,\psi)$, if for every submodule $W$ with $W \ne \bot$, $W \ne \top$, and $\varphi(W) \subseteq W$, there exists $w \in W$ with $\psi(w) \notin W$:
$$\forall W,\ (W \neq \bot \wedge W \neq \top \wedge \varphi(W)\subseteq W) \;\Rightarrow\; \exists\, w \in W,\ \psi(w) \notin W.$$

Intuitively, $\psi$ is a "demolition crew": whatever proper wall $\varphi$ tolerates, $\psi$ punches a hole in it. This is exactly the obstruction to simultaneous block-triangularization of the pair.

**Definition 3.2 (Classical generation certificate).** A pair $(s,t) \in \mathrm{End}_K(V)^2$ satisfies the *classical generation certificate* if:
1. **Regularity:** $\mathrm{charpoly}(s)$ is irreducible over $K$ (so by Prop. 2.3, $s$ has no proper nontrivial invariant subspace); and
2. **Breaking:** $\mathrm{Breaks}(s,t)$ holds.

**Theorem 1 (Certificate ⇒ irreducible joint action).** If $(s,t)$ satisfies the classical generation certificate, then there is no proper nontrivial submodule $W \subseteq V$ invariant under both $s$ and $t$:
$$\neg\,\exists W,\ \big(W \neq \bot \wedge W \neq \top \wedge s(W)\subseteq W \wedge t(W)\subseteq W\big).$$
Consequently, the subgroup $\langle s, t\rangle \le \mathrm{GL}(V)$ acts irreducibly on $V$.

*Proof.* Suppose toward a contradiction such a $W$ exists, with $W \ne \bot$, $W \ne \top$, $s(W) \subseteq W$, and $t(W) \subseteq W$. Because $W$ is a proper nontrivial $s$-invariant subspace, the breaking hypothesis $\mathrm{Breaks}(s,t)$ provides $w \in W$ with $t(w) \notin W$. But $t$-invariance of $W$ gives $t(w) \in W$, a contradiction. Hence no such $W$ exists. The final clause is the definition of irreducibility of the $\langle s,t\rangle$-action. $\square$

**Remark 3.3.** When $s$ is strongly regular toral, Proposition 2.3 already guarantees that $s$ has no proper nontrivial invariant subspace, so the breaking condition is vacuously satisfied (there are no walls to break) and Theorem 1 is immediate. The certificate's full strength is intended for the *relaxed* regime where $s$ has a few invariant subspaces and $t$ is required to break each — a setting central to higher-rank classical groups and flagged in §7. The value of stating the certificate in the general form is that the structural theorem (Theorem 1) holds verbatim in both regimes.

Irreducibility of the $\langle s,t\rangle$-action is the standard algebraic prerequisite in the Bourgain–Gamburd expansion machine: it rules out the trivial obstruction to a spectral gap, in which the random walk is confined to a subrepresentation. The certificate packages this prerequisite as two locally checkable conditions.

---

## 4. Vertex Expansion of Cayley Graphs

We now develop the combinatorial layer independently and in full. Fix a finite group $G$ with decidable equality and a generating-candidate set $S \subseteq G$ (a `Finset`). All graphs are right Cayley graphs.

**Definition 4.1 (Cayley neighbor set).** For $A \subseteq G$,
$$N_S(A) \;=\; \{\, a\,s : a \in A,\ s \in S \,\} \;=\; \bigcup_{a \in A} a\cdot S .$$
This is the set of vertices reachable in one step from $A$.

**Definition 4.2 (Vertex boundary).** $\partial_S(A) = N_S(A) \setminus A$, the genuinely new vertices.

**Definition 4.3 (Vertex expansion).** $S$ has *vertex expansion $\varepsilon$*, written $\mathrm{HasVertexExpansion}(S,\varepsilon)$, if $\varepsilon > 0$ and for every nonempty $A$ with $2|A| \le |G|$,
$$\varepsilon\,|A| \;\le\; |\partial_S(A)|.$$

**Definition 4.4 (Certified gap).** $S$ *has a certified gap $\varepsilon$* if it has vertex expansion $\varepsilon$ and additionally generates $G$ (every $g \in G$ lies in $\langle S\rangle$). This abstracts the two operational consequences of a spectral gap: no bottlenecks, and full connectivity.

### 4.1 Basic bounds

**Lemma 4.5 (Containment under identity).** If $1 \in S$, then $A \subseteq N_S(A)$.

*Proof.* For $x \in A$, take $a = x$, $s = 1$: then $x = x\cdot 1 \in a\cdot S \subseteq N_S(A)$. $\square$

**Lemma 4.6 (Degree bound).** $|N_S(A)| \le |A|\cdot|S|$.

*Proof.* $N_S(A) = \bigcup_{a\in A} a\cdot S$ is a union of $|A|$ sets, each of size at most $|S|$ (left multiplication by $a$ is injective, so $|a\cdot S| = |S|$). The union bound gives $|N_S(A)| \le \sum_{a \in A}|a\cdot S| \le |A|\cdot|S|$. $\square$

### 4.2 Connectivity from expansion

**Lemma 4.7 (Nonempty boundary in a connected graph).** If $A$ is nonempty and proper ($A \ne G$) and $S$ generates $G$, then $\partial_S(A) \ne \varnothing$.

*Proof sketch.* Suppose $\partial_S(A) = \varnothing$. Then $N_S(A) \subseteq A$, i.e. $A\cdot S \subseteq A$: the set $A$ is closed under right multiplication by every generator $s \in S$. By induction on the word length of an element of $\langle S\rangle$ — using that for each $x \in S$ some power $x^n = 1$, so $x^{-1} = x^{n-1}$ is also obtained by repeated right-multiplication by $x$ — one shows $A\cdot g \subseteq A$ for all $g \in \langle S\rangle = G$. Picking any $a \in A$ and any $g\in G$, the element $a^{-1}g \in G$ satisfies $a\cdot(a^{-1}g) = g \in A$, whence $A = G$, contradicting properness. $\square$

**Theorem 2 (Expansion forces generation).** Let $S$ be symmetric ($s \in S \Rightarrow s^{-1} \in S$) and suppose $\mathrm{HasVertexExpansion}(S,\varepsilon)$ for some $\varepsilon > 0$. Then $S$ generates $G$: every $g \in G$ lies in $\langle S\rangle$.

*Proof sketch.* Let $H = \langle S\rangle$ and suppose for contradiction some $g \notin H$, so $H$ is a proper subgroup. By Lagrange's theorem $|H|$ divides $|G|$, and since $H$ is proper, $|H| \le |G|/2$; also $|H| \ge 1$ (it contains $1$). Thus $H$, viewed as a vertex set, is nonempty and satisfies $2|H| \le |G|$, so it is a legitimate test set for Definition 4.3. But $H$ is a subgroup, hence closed under right multiplication by $S \subseteq H$: $N_S(H) \subseteq H$, so $\partial_S(H) = \varnothing$ and $|\partial_S(H)| = 0$. Expansion would force $0 = |\partial_S(H)| \ge \varepsilon|H| > 0$, a contradiction. Hence $H = G$. $\square$

This converse is conceptually important: expansion is not merely *implied by* good generation; positive expansion *certifies* connectivity on its own.

### 4.3 Monotonicity and growth

**Theorem 3 (Monotonicity under enlargement).** If $S \subseteq T$ and $\mathrm{HasVertexExpansion}(S,\varepsilon)$, then $\mathrm{HasVertexExpansion}(T,\varepsilon)$.

*Proof.* The positivity $\varepsilon > 0$ is inherited. For any test set $A$, $S \subseteq T$ gives $N_S(A) \subseteq N_T(A)$, hence $\partial_S(A) = N_S(A)\setminus A \subseteq N_T(A)\setminus A = \partial_T(A)$, so $|\partial_T(A)| \ge |\partial_S(A)| \ge \varepsilon|A|$. $\square$

Adding generators can only help. Operationally: certify a small clean generating set, and every superset inherits the bound.

**Theorem 4 (Geometric neighborhood growth).** Suppose $\mathrm{HasVertexExpansion}(S,\varepsilon)$ and $1 \in S$. Then for every nonempty $A$ with $2|A| \le |G|$,
$$(1+\varepsilon)\,|A| \;\le\; |N_S(A)|.$$

*Proof.* Since $1 \in S$, Lemma 4.5 gives $A \subseteq N_S(A)$, so $N_S(A)$ is the disjoint union of $A$ and $\partial_S(A) = N_S(A)\setminus A$:
$$|N_S(A)| = |A| + |\partial_S(A)| \ge |A| + \varepsilon|A| = (1+\varepsilon)|A|,$$
using the expansion bound on $\partial_S(A)$. $\square$

**Corollary 4.8 (Logarithmic diameter).** Under the hypotheses of Theorem 4, iterating the growth bound, the $k$-step reachable set from any vertex has size at least $\min\big((1+\varepsilon)^k,\ |G|/2\big)$. Hence after $k = O\!\big(\tfrac{1}{\varepsilon}\log|G|\big)$ steps the reachable set exceeds $|G|/2$, and (using symmetry of $S$) any two vertices are joined by a path of length $O\!\big(\tfrac{1}{\varepsilon}\log|G|\big)$: the Cayley graph has logarithmic diameter and rapidly mixing random walk.

The formal development provides the recursion $\mathrm{CayleyReachableInSteps}(S, k, a)$ — the set reachable from $a$ in at most $k$ steps — as the substrate for this iteration; Theorem 4 is the per-step engine.

---

## 5. A Concrete Certificate in $\mathrm{GL}_2(\mathbb{F}_p)$

To demonstrate checkability we descend to the smallest interesting classical group, the invertible $2\times 2$ matrices over $\mathbb{F}_p = \mathbb{Z}/p\mathbb{Z}$.

**Definition 5.1 ($\mathrm{GL}_2$ certificate).** For a prime $p$ and $s, t \in M_2(\mathbb{F}_p)$, the pair satisfies the *$\mathrm{GL}_2$ certificate* if:
1. $\det s \neq 0$ and $\det t \neq 0$ (both invertible);
2. $\mathrm{charpoly}(s)$ is irreducible over $\mathbb{F}_p$; and
3. $s$ and $t$ have no common eigenvector: there is no nonzero $v \in \mathbb{F}_p^2$ with $s\,v = c\,v$ and $t\,v = d\,v$ for scalars $c,d \in \mathbb{F}_p$.

Each clause is a finite computation: two determinants in $\mathbb{F}_p$, factoring one quadratic over $\mathbb{F}_p$, and a finite eigenvector search.

**Theorem 6 ($\mathrm{GL}_2$ certificate ⇒ no common eigenvector).** If $(s,t)$ satisfies the $\mathrm{GL}_2$ certificate, then there is no nonzero $v \in \mathbb{F}_p^2$ that is simultaneously an eigenvector of $s$ and of $t$.

*Proof.* Immediate from clause 3 of Definition 5.1, which is exactly the negation of the existence of such a $v$. $\square$

**Interpretation.** In dimension two, a proper nontrivial invariant subspace is a line, and a line $\langle v\rangle$ is invariant under a matrix iff $v$ is an eigenvector. Thus "no common eigenvector" is precisely "no common invariant subspace," i.e. irreducibility of the $\langle s,t\rangle$-action on $\mathbb{F}_p^2$, recovering the conclusion of Theorem 1 in this concrete case. Clause 2 already guarantees $s$ alone has no invariant line (its eigenvalues live in $\mathbb{F}_{p^2}\setminus\mathbb{F}_p$); clause 3 ensures $t$ does not happen to preserve any line $s$ *could* otherwise share — operationalizing the breaking condition. The certificate thereby becomes a hand-executable recipe: choose $s$ with irreducible quadratic charpoly, and any $t$ avoiding $s$'s (non-existent over $\mathbb{F}_p$) eigendirections; for the relaxed regime, choose $t$ moving each of $s$'s eigenlines.

---

## 6. Quasirandomness and Uniform Expansion

Irreducibility removes the *obstruction* to a spectral gap; *quasirandomness* supplies the positive uniform lower bound for higher-rank families.

**Definition 6.1 (Quasirandomness).** A finite group $G$ is *$m$-quasirandom* ($m \ge 2$) if every nontrivial complex representation $\rho : G \to \mathrm{GL}_n(\mathbb{C})$ — i.e. one with $\rho(g) \ne 1$ for some $g$ — has dimension $n \ge m$. Equivalently, the minimal dimension of a nontrivial irreducible representation is at least $m$.

Following Gowers, $m$-quasirandom groups are "pseudorandom": products $ABC$ of three large subsets cover essentially all of $G$ uniformly, with error governed by $1/\sqrt{m}$. Large quasirandomness leaves no low-dimensional structure in which Cayley walks could stall. For finite simple groups of Lie type, the minimal nontrivial representation dimension grows polynomially with the rank and the field size: e.g. $\mathrm{PSL}_2(\mathbb{F}_q)$ is $\tfrac{q-1}{2}$-quasirandom, and symplectic/orthogonal/unitary families are increasingly quasirandom with rank. This monotone growth is the structural reason the certificate program is expected to deliver expansion *uniformly* across a family rather than degrading as $q \to \infty$.

**Definition 6.2 (Certificate comparison).** For generating sets $S_1 \subseteq G_1$, $S_2 \subseteq G_2$, say the second has *gap at least* the first if every expansion constant achieved by $S_1$ is matched or exceeded by some expansion constant of $S_2$. This furnishes a formal partial order for comparing group families (e.g. $\mathrm{Sp}_4(\mathbb{F}_3)$ against $\mathrm{GL}_2(\mathbb{F}_3)$).

**Conjecture 6.3 (Uniform certified expansion for $\mathrm{Sp}_4$).** There exists $\varepsilon > 0$, independent of $q$, such that for every odd prime power $q$ the symplectic group $\mathrm{Sp}_4(\mathbb{F}_q)$ admits a pair $(s,t)$ satisfying the classical generation certificate whose symmetric generating set $S = \{s, s^{-1}, t, t^{-1}\}$ has vertex expansion at least $\varepsilon$.

Uniformity in $q$ is the decisive content: it upgrades a sequence of individually well-connected graphs into a bona fide expander family. The conjecture is falsifiable — a single $q$ admitting no certified pair with expansion $\ge \varepsilon$ (for the relevant $\varepsilon$) refutes it.

---

## 7. Discussion

The architecture cleanly separates two concerns that are usually entangled. The **algebraic** layer (§§2–3, 5) reduces "the generated group acts irreducibly" — the qualitative prerequisite of every modern expansion proof — to two short, decidable conditions, with the implication proved unconditionally (Theorem 1, Theorem 6). The **combinatorial** layer (§4) develops vertex expansion as a self-contained theory whose internal logic (generation $\Leftrightarrow$ connectivity, monotonicity, geometric growth, degree bounds) is proved outright. The bridge between them is exactly the classical-group setting, where irreducibility plus quasirandomness (§6) is conjectured to yield a uniform quantitative gap.

A notable feature is the *converse* Theorem 2: expansion certifies generation. In the certificate workflow this means a numerically observed expansion bound for a candidate $S$ is itself a proof of connectivity, with no separate generation argument required. Combined with monotonicity (Theorem 3), this yields a robust pipeline: certify a minimal symmetric $S$, then freely enlarge.

The framework's chief limitation is that the quantitative uniform bound (Conjecture 6.3) is not derived from the certificate alone; the certificate guarantees irreducibility, but turning irreducibility into a uniform spectral gap requires the analytic Bourgain–Gamburd machinery together with the quasirandomness growth of the family. Theorem 1 supplies the algebraic input to that machine in a packaged, checkable form.

---

## 8. Future Work

1. **Relaxed (non-irreducible) regime.** State and prove a version of Theorem 1 where $s$ has a small, explicit set of invariant subspaces and $t$ breaks each; this is the form needed for higher-rank classical groups, where genuinely regular semisimple elements may still leave structured invariant flags.
2. **Quantitative breaking ⇒ spectral gap.** Quantify the breaking condition (e.g. by how far $t$ moves vectors out of each wall) and connect it to an explicit lower bound on the spectral gap via the Bourgain–Gamburd flattening lemma.
3. **Symplectic, orthogonal, unitary certificates.** Instantiate Definition 3.2 for $\mathrm{Sp}_{2n}$, $\mathrm{O}_n$, $\mathrm{U}_n$ over $\mathbb{F}_q$, exhibiting explicit regular toral elements via irreducible characteristic polynomials of the appropriate degree and form-compatibility.
4. **Toward Conjecture 6.3.** Combine an explicit $\mathrm{Sp}_4$ certificate with the known quasirandomness growth of $\mathrm{Sp}_4(\mathbb{F}_q)$ to attempt a uniform $\varepsilon$.
5. **Algorithmic certification.** Develop and analyze the complexity of an algorithm that, given $(s,t)$, decides the certificate (irreducibility test for charpoly; common-eigenvector test), and outputs the certified expansion constant.

---

## References

- Helfgott, H. A. (2008). *Growth and generation in $\mathrm{SL}_2(\mathbb{Z}/p\mathbb{Z})$.* Annals of Mathematics.
- Bourgain, J., & Gamburd, A. (2008). *Uniform expansion bounds for Cayley graphs of $\mathrm{SL}_2(\mathbb{F}_p)$.* Annals of Mathematics.
- Kassabov, M., Lubotzky, A., & Nikolov, N. (2006). *Finite simple groups as expanders.* PNAS.
- Babai, L., Kantor, W. M., & Lubotzky, A. (1989). *Small-diameter Cayley graphs for finite simple groups.* European Journal of Combinatorics.
- Gowers, W. T. (2008). *Quasirandom groups.* Combinatorics, Probability and Computing.
- Hoory, S., Linial, N., & Wigderson, A. (2006). *Expander graphs and their applications.* Bulletin of the AMS.
