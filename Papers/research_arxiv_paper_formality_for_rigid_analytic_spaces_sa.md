# Purity Implies Formality: A Weight-Graded Mechanism, with Massey-Product Obstructions

**Author:** Aristotle
**Date:** 2026-08-09

---

## Abstract

We isolate and prove, in complete generality and with no geometric input, the algebraic mechanism underlying the theorem that the étale and de Rham cohomology algebras of a smooth proper rigid-analytic space over a finite extension of $\mathbf{Q}_p$ are formal whenever the space satisfies the weight-monodromy conjecture. The mechanism is the following statement about *weight-graded differential graded algebras*: a differential graded algebra whose underlying algebra is bigraded by (cohomological degree, weight), whose differential raises degree by one and preserves weight, and whose cohomology is **pure** — no cohomology in bidegree $(n,w)$ with $w \ne n$ — is formal.

Our formality statement is *strict*: we construct an explicit sub-differential-graded-algebra $A' \subseteq A$ and an explicit two-sided ideal $J \subseteq A'$ with $d(A') \subseteq J$, such that both maps in $A \supseteq A' \twoheadrightarrow A'/J$ are quasi-isomorphisms and $A'/J$ carries the zero differential. We refine this further: under purity the span $A^{\mathrm{diag}}$ of the *diagonal cocycles* (bihomogeneous of bidegree $(n,n)$, killed by $d$) is a unital subalgebra on which the differential vanishes identically and which surjects onto the cohomology algebra, so that $H(A)$ is a subquotient of $A$ realised by an honest subalgebra with zero differential.

We then prove two Massey-product theorems. First, strict formality forces every defined triple Massey product to contain $0$, because the primitives can be chosen inside the acyclic absorbing ideal $J$. Second, purity forces the same conclusion directly, by a *weight-excess count*: a triple Massey representative of degree $p+q+r-1$ has weight $p+q+r$, and purity annihilates every cocycle off the diagonal. The contrapositive is an obstruction theorem: a dga carrying a genuinely non-vanishing triple Massey product of diagonal classes admits no pure weight grading. This is the algebraic shadow of the existence of smooth proper rigid-analytic surfaces whose cohomology algebras are not formal.

Finally, we remove the normalisation: for any additive $\mathrm{wt} : \mathbf{Z} \to \mathbf{Z}$ with $\mathrm{wt}(1) = \alpha > 0$, purity along the line $w = \alpha n$ implies the same strict formality zig-zag and the same Massey vanishing. Two explicit group-algebra examples show the purity hypothesis is consistent (satisfied by objects with nonzero cohomology in every degree) and independent (not automatic).

**Keywords.** Formality, differential graded algebra, weight filtration, weight-monodromy conjecture, purity, Massey products, rigid-analytic geometry, canonical truncation.

---

## 1. Introduction

### 1.1 Formality

Let $k$ be a field. A *differential graded algebra* (dga) over $k$ is a graded $k$-algebra $A = \bigoplus_n A^n$ together with a $k$-linear map $d : A \to A$ of degree $+1$ with $d^2 = 0$ satisfying the graded Leibniz rule $d(ab) = (da)b + (-1)^{|a|} a (db)$ for homogeneous $a$. Its cohomology $H(A) = \ker d / \operatorname{im} d$ is again a graded $k$-algebra, and $(H(A), 0)$ is itself a dga.

A dga $A$ is **formal** if there is a chain of dga morphisms
$$A \;\longleftarrow\; \bullet \;\longrightarrow\; \cdots \;\longleftarrow\; \bullet \;\longrightarrow\; (H(A), 0)$$
each inducing an isomorphism on cohomology. Formality asserts that the cohomology *algebra* determines the whole homotopy type of the dga: all higher structure — the $A_\infty$-operations, the Massey products — is determined by, and may be normalised away in favour of, the ring structure.

Formality is rare and hard, and the known proofs are typically powered by an auxiliary grading. For compact Kähler manifolds the $\partial\bar\partial$-lemma splits the de Rham algebra and yields formality (Deligne–Griffiths–Morgan–Sullivan). In the $\ell$-adic setting, weights on cohomology have long been known to force degeneration and formality phenomena. The present work isolates the shared skeleton.

### 1.2 Weights and the arithmetic motivation

For a smooth proper rigid-analytic space $X$ over a finite extension $K/\mathbf{Q}_p$, the cohomology $H^n(X)$ — étale or de Rham — carries an additional *weight* structure coming from the monodromy filtration. The weight-monodromy conjecture of Deligne, in this setting, predicts that this structure is as tight as possible: $H^n$ is **pure of weight $n$**. Granting this, the cohomology algebras of $X$ are formal. Moreover, formality genuinely fails in general: there exist smooth proper rigid-analytic surfaces whose cohomology algebras are not formal, and these are therefore spaces for which the naive purity statement must fail in any weight-graded dga model.

The purpose of this paper is to extract, state and prove in maximal generality the *algebraic* theorem responsible: purity $\Rightarrow$ formality, together with the exact Massey-product mechanism that both makes purity sufficient and makes non-formality an obstruction to purity. No rigid-analytic geometry is used; the geometric input is precisely the sentence "weight-monodromy supplies purity", and everything downstream of that sentence is proved here.

### 1.3 Results

Throughout, $k$ is a field and $A$ a $k$-algebra with a decomposition $A = \bigoplus_{(n,w)\in\mathbf{Z}^2} A^{n,w}$ into bihomogeneous pieces satisfying $A^{n,w}A^{n',w'} \subseteq A^{n+n',w+w'}$ and $1 \in A^{0,0}$.

* **Theorem A (Purity implies strict formality).** If $(A,d)$ is a weight-graded dga (Definition 2.1) whose weight grading is pure (Definition 2.3), then there exist a subalgebra $A' \subseteq A$ with $1 \in A'$ and a two-sided ideal $J \subseteq A'$ with $d(A') \subseteq J$ such that $A \supseteq A'$ and $A' \twoheadrightarrow A'/J$ induce isomorphisms on cohomology and $A'/J$ has zero differential. Hence $A$ is formal.
* **Theorem B (Diagonal strict lift).** The span $A^{\mathrm{diag}}$ of the diagonal cocycles is a unital subalgebra of $A$ on which $d$ vanishes identically. If the weight grading is pure, every cohomology class of $A$ is represented by an element of $A^{\mathrm{diag}}$; the coboundaries inside $A^{\mathrm{diag}}$ form a two-sided ideal, and the quotient is the cohomology algebra.
* **Theorem C (Formality kills Massey products).** In a dga admitting a strict formality zig-zag as in Theorem A, every defined triple Massey product contains $0$: the primitives can be chosen inside $J$, which is acyclic and absorbing.
* **Theorem D (Purity kills Massey products).** If the weight grading is pure and $x,y,z$ are diagonal cocycles of degrees $p,q,r$ with $xy$, $yz$ exact, then bihomogeneous primitives $u,v$ can be chosen for which $\varepsilon(p)\,uz - xv$ is exact.
* **Theorem E (Non-formality obstructs purity).** If some triple Massey product of diagonal classes is genuinely non-vanishing, then no pure weight grading exists.
* **Theorem F (Arbitrary normalisation).** For additive $\mathrm{wt}$ with $\mathrm{wt}(1) = \alpha > 0$, purity along $w = \mathrm{wt}(n)$ implies the same strict formality zig-zag and the same Massey vanishing; for $\alpha=1$ this is Theorem A.
* **Propositions G, H (Consistency and independence).** The group algebra $k[\mathbf{Z}]$ bigraded diagonally with zero differential is pure and has nonzero cohomology in every degree. The group algebra $k[\mathbf{Z}^2]$ bigraded tautologically with zero differential is not pure.

### 1.4 Method in one paragraph

Everything is driven by a single numerical invariant. For a bihomogeneous element of bidegree $(n,w)$ define its **weight excess** $e = w - n$. Multiplication adds excess. The differential lowers excess by exactly one ($d$ raises degree, preserves weight). Purity says: *every cocycle of nonzero excess is a coboundary, and its primitive may be chosen of the same weight.* The region $e \ge 0$ is closed under multiplication and contains $1$; the canonical truncation of each weight strand at the diagonal $e = 0$ is exactly the subalgebra cut out by $e\ge 0$ (with cocycles only at $e = 0$). Massey products, in turn, are built by two applications of "take a primitive", so their representatives sit at excess $+1$ and are killed by purity. That is the whole argument; the rest is bookkeeping, which we carry out carefully because the Leibniz rule is only available for bihomogeneous left factors.

---

## 2. Weight-graded differential graded algebras

### 2.1 The bigraded setting

Let $k$ be a field and $A$ a (not necessarily commutative) $k$-algebra equipped with a family of $k$-submodules $\mathcal{A}(n,w) \subseteq A$, indexed by $(n,w) \in \mathbf{Z} \times \mathbf{Z}$, making $A$ a $\mathbf{Z}^2$-graded algebra: the natural map $\bigoplus_{(n,w)} \mathcal{A}(n,w) \to A$ is an isomorphism, $\mathcal{A}(n,w)\mathcal{A}(n',w') \subseteq \mathcal{A}(n+n',w+w')$, and $1 \in \mathcal{A}(0,0)$. We call $n$ the **cohomological degree** and $w$ the **weight**.

For $a \in A$ and $i \in \mathbf{Z}^2$ write $a_i \in \mathcal{A}(i)$ for the $i$-th bihomogeneous component; $a \mapsto a_i$ is $k$-linear, the support $\operatorname{supp}(a) = \{i : a_i \ne 0\}$ is finite, and $a = \sum_{i \in \operatorname{supp}(a)} a_i$. If $a \in \mathcal{A}(i)$ then $a_i = a$ and $a_j = 0$ for $j \ne i$.

**Definition 2.1 (Weight-graded dga).** A *weight-graded dga* structure on $\mathcal{A}$ consists of a $k$-linear map $d : A \to A$ and a function $\varepsilon : \mathbf{Z} \to k$ with $\varepsilon(n) \ne 0$ for all $n$, such that

1. *(bidegree)* $a \in \mathcal{A}(n,w) \Rightarrow da \in \mathcal{A}(n+1,w)$;
2. *(differential)* $d(da) = 0$ for all $a \in A$;
3. *(Leibniz)* for all $n,w \in \mathbf{Z}$, all $a \in \mathcal{A}(n,w)$ and all $b \in A$,
$$d(ab) = (da)\,b + \varepsilon(n)\,a\,(db).$$

The sign function is left arbitrary (subject to invertibility) so that graded-commutative conventions $\varepsilon(n) = (-1)^n$, sign-free conventions $\varepsilon \equiv 1$, and any twisted convention are all covered simultaneously. Note that Leibniz is postulated only when the *left* factor is bihomogeneous; every argument below must therefore decompose its left factors.

**Lemma 2.2 (Elementary consequences).** Let $(d,\varepsilon)$ be a weight-graded dga structure.

1. $d$ commutes with taking components up to shift: $(da)_{(n+1,w)} = d(a_{(n,w)})$.
2. Components of cocycles are cocycles: if $da = 0$ then $d(a_i) = 0$ for all $i$.
3. $d(1) = 0$.

*Proof sketch.* (1) Expand $a = \sum_i a_i$; by the bidegree axiom $d(a_i) \in \mathcal{A}(i_1+1, i_2)$, so taking the $(n+1,w)$-component of $da$ leaves only the summand $i = (n,w)$. (2) Immediate from (1). (3) Apply Leibniz to $a = b = 1 \in \mathcal{A}(0,0)$: $d1 = d1 + \varepsilon(0)\,d1$, so $\varepsilon(0)\,d1 = 0$ and $\varepsilon(0) \ne 0$. $\square$

### 2.2 Purity

**Definition 2.3 (Purity).** The weight grading is **pure** if for all $n \ne w$, every $a \in \mathcal{A}(n,w)$ with $da = 0$ admits $c \in \mathcal{A}(n-1,w)$ with $dc = a$.

Two features of this formulation matter. First, it asks for vanishing of cohomology in every bidegree off the diagonal $w = n$ — this is exactly what the weight-monodromy conjecture supplies in the rigid-analytic setting, where $H^n$ is pure of weight $n$. Second, it asks that the primitive be *of the same weight*. Since $d$ preserves weight this is automatic if one works weight-strand by weight-strand; stating it explicitly makes the hypothesis usable without first proving that the weight decomposition splits every subcomplex.

**Remark 2.4.** Purity is equivalent to: for each fixed weight $w$, the complex $(\mathcal{A}(\bullet,w), d)$ is exact except possibly in degree $w$.

---

## 3. Cocycles, coboundaries and the multiplicative structure of cohomology

Because Leibniz is available only for bihomogeneous left factors, even the basic multiplicativity statements require the bigrading. We record them; they are what makes "the cohomology *algebra*" meaningful in this setting.

**Proposition 3.1 (Cocycles form a subalgebra).** If $da = 0$ and $db = 0$ then $d(ab) = 0$.

*Proof.* Write $a = \sum_{i} a_i$ over $\operatorname{supp}(a)$; then $ab = \sum_i a_i b$ and $d(ab) = \sum_i d(a_i b)$. For each $i = (n,w)$ the Leibniz rule applies with the bihomogeneous left factor $a_i$, giving $d(a_i b) = d(a_i)\,b + \varepsilon(n)\, a_i\, (db)$. Both terms vanish: $d(a_i) = 0$ by Lemma 2.2(2), and $db = 0$ by hypothesis. $\square$

**Proposition 3.2 (Cocycle $\cdot$ coboundary is a coboundary).** If $da = 0$ then for every $c \in A$ there is $e \in A$ with $a\,(dc) = d e$; explicitly one may take
$$e = \sum_{i \in \operatorname{supp}(a)} \varepsilon(i_1)^{-1}\, a_i\, c .$$

*Proof.* For each $i = (n,w)$, Leibniz gives $d(a_i c) = d(a_i)c + \varepsilon(n)\,a_i (dc) = \varepsilon(n)\,a_i(dc)$, since $d(a_i) = 0$. Multiply by $\varepsilon(n)^{-1}$, which exists because $\varepsilon$ is nowhere zero, and sum over $\operatorname{supp}(a)$, using $\sum_i a_i = a$. $\square$

**Proposition 3.3 (Coboundary $\cdot$ cocycle is a coboundary).** If $db = 0$ then $(dc)\,b = d(cb)$ for every $c \in A$.

*Proof.* Decompose $c = \sum_i c_i$. Leibniz on $c_i$ gives $d(c_i b) = d(c_i)b + \varepsilon(i_1) c_i (db) = d(c_i) b$. Summing over $\operatorname{supp}(c)$ and reassembling yields $d(cb) = (dc)b$. $\square$

Consequently the cocycles $Z = \ker d$ form a unital $k$-subalgebra of $A$, the coboundaries $B = \operatorname{im} d$ satisfy $Z\cdot B \subseteq B$ and $B \cdot Z \subseteq B$, and $H(A) = Z/(Z\cap B) = Z/B$ is a $k$-algebra. Everything below refers to this algebra structure.

---

## 4. The truncation construction and Theorem A

### 4.1 The subalgebra and the ideal

Fix a weight-graded dga $(A,d,\varepsilon)$ on $\mathcal{A}$.

**Definition 4.1.** For $i = (n,w) \in \mathbf{Z}^2$ set
$$P(i) = \begin{cases} \mathcal{A}(i), & n < w,\\ \mathcal{A}(i) \cap \ker d, & n = w,\\ 0, & n > w,\end{cases} \qquad Q(i) = \begin{cases} \mathcal{A}(i), & n < w,\\ d\big(\mathcal{A}(n-1,w)\big), & n = w,\\ 0, & n > w,\end{cases}$$
and let $A' = \sum_i P(i)$ and $J = \sum_i Q(i)$.

Weight strand by weight strand, $A'$ is the *canonical truncation* $\tau_{\le w}\big(\mathcal{A}(\bullet, w)\big)$: all of degrees $< w$, the cocycles in degree $w$, nothing above. And $J$ replaces the top cocycles by the top coboundaries, so that $A'/J$ has, in weight $w$, exactly $H^w$ of that strand in degree $w$ and nothing else.

**Lemma 4.2.** $Q(i) \subseteq P(i) \subseteq \mathcal{A}(i)$ for all $i$; hence $J \subseteq A'$. Moreover $P(i) = Q(i) = 0$ when $i_2 < i_1$.

*Proof.* The only nontrivial containment is on the diagonal: if $x = dc$ with $c \in \mathcal{A}(n-1,n)$ then $x \in \mathcal{A}(n,n)$ by the bidegree axiom and $dx = d(dc)= 0$. $\square$

**Lemma 4.3 (Componentwise detection).** If $a \in A'$ then $a_i \in P(i)$ for all $i$; if $a \in J$ then $a_i \in Q(i)$ for all $i$. In particular $a_i = 0$ whenever $i_2 < i_1$.

*Proof sketch.* $A'$ is a sum of submodules of the bihomogeneous pieces $\mathcal{A}(i)$; taking the $i$-th component of a sum of elements of the various $P(j) \subseteq \mathcal{A}(j)$ annihilates all $j \ne i$ and is the identity on $P(i)$. The same argument applies to $J$. $\square$

### 4.2 Multiplicativity

**Proposition 4.4.** $1 \in A'$; $A'$ is closed under multiplication; $J\cdot A' \subseteq J$ and $A' \cdot J \subseteq J$.

*Proof sketch.* All four statements reduce, by bilinearity and Lemma 4.3, to statements about products $P(i)P(j)$ and $Q(i)P(j)$, $P(i)Q(j)$ with $i=(n,w)$, $j=(n',w')$ and $n \le w$, $n' \le w'$. The product lands in $\mathcal{A}(n+n', w+w')$ and $n+n' \le w+w'$, so it lands in the closed region. There are three cases.

* If $n<w$ or $n'<w'$, then $n+n' < w+w'$ and $P(i)P(j) \subseteq \mathcal{A}(n+n',w+w') = P(n+n',w+w')$, and likewise for the ideal statements, since below the diagonal $Q$ and $P$ agree with $\mathcal{A}$.
* If $n=w$ and $n'=w'$, then the product lies on the diagonal and both factors are cocycles, so the product is a cocycle by Proposition 3.1; hence it lies in $P(n+n',w+w')$.
* For the ideal: if the left factor is a diagonal coboundary $dc$ and the right factor a diagonal cocycle $b$, then $(dc)b = d(cb)$ by Proposition 3.3, and $cb$ is bihomogeneous of the right bidegree, so the product lies in $Q$. Symmetrically, if the left factor $a$ is a diagonal cocycle and the right factor a diagonal coboundary $dc$, then $a\,(dc) = d(\varepsilon(n)^{-1} a c)$ by Proposition 3.2, again in $Q$. Finally $1 \in \mathcal{A}(0,0) \cap \ker d = P(0,0)$ by Lemma 2.2(3). $\square$

**Proposition 4.5.** $d(A') \subseteq J$.

*Proof sketch.* By Lemma 4.3 it suffices to treat $a \in P(i)$. If $i = (n,w)$ with $n=w$ then $da = 0 \in J$. If $n < w$ then $da \in \mathcal{A}(n+1,w)$; if $n+1 < w$ this is $Q(n+1,w)$, and if $n+1 = w$ then $da = d(a)$ with $a \in \mathcal{A}(w-1,w)$, which is precisely the definition of $Q(w,w)$. $\square$

Thus $A'/J$ is a $k$-algebra carrying the induced zero differential.

### 4.3 The two quasi-isomorphisms

**Proposition 4.6 (Surjectivity on cohomology).** Assume purity. Every cocycle $a \in A$ can be written $a = z + dc$ with $z \in A'$ a cocycle and $c \in A$.

*Proof sketch.* Decompose $a = \sum_{i \in \operatorname{supp}(a)} a_i$; each $a_i$ is a cocycle (Lemma 2.2(2)). Split the support into the part $S_{\le} = \{i : i_1 \le i_2\}$ and the part $S_{>} = \{i: i_1 > i_2\}$. The sum over $S_\le$ lies in $A'$ (it lies in $P(i)$ in each case: below the diagonal by definition, on the diagonal because the components are cocycles) and is a cocycle. Each component indexed by $S_>$ is off-diagonal and a cocycle, so by purity it equals $dc_i$ for some $c_i$ of the same weight. A finite sum of coboundaries is a coboundary, $\sum_{i\in S_>} a_i = d\big(\sum_i c_i\big)$. $\square$

**Proposition 4.7 (Injectivity on cohomology).** Assume purity. If $z \in A'$ and $z = dc$ for some $c \in A$, then $z = dc'$ for some $c' \in A'$.

*Proof sketch.* Since $z \in A'$, all components of $z$ vanish above the diagonal. Fix a component $z_i$, $i = (n,w)$ with $n \le w$; it is a coboundary, indeed $z_i = d(c_{(n-1,w)})$ by Lemma 2.2(1). If $n-1 < w$ then $c_{(n-1,w)} \in \mathcal{A}(n-1,w) = P(n-1,w) \subseteq A'$ and we are done for that component. The remaining case $n - 1 = w$, i.e. $n = w+1 > w$, does not occur. Summing the chosen primitives over the finite support gives $c' \in A'$ with $dc' = z$. $\square$

**Proposition 4.8 (Acyclicity of the ideal).** Assume purity. If $j \in J$ and $dj = 0$ then $j = dj'$ for some $j' \in J$.

*Proof sketch.* Work componentwise (Lemma 4.3), so let $j_i \in Q(i)$ be a cocycle, $i = (n,w)$, $n \le w$. If $n = w$ then $j_i = dc$ with $c \in \mathcal{A}(w-1,w)$, and $\mathcal{A}(w-1,w) = Q(w-1,w)$ because $w-1 < w$; so $j_i$ is the differential of an element of $J$. If $n < w$ then $j_i$ is an off-diagonal cocycle, so purity gives a primitive $c \in \mathcal{A}(n-1,w) = Q(n-1,w) \subseteq J$ (again $n-1 < w$). Reassemble the finitely many primitives. $\square$

Propositions 4.4–4.8 assemble into:

**Theorem A (Purity implies strict formality).** *Let $(A,d,\varepsilon)$ be a weight-graded dga whose weight grading is pure. Then, with $A'$ and $J$ as in Definition 4.1:*

1. *$A'$ is a unital subalgebra of $A$ and $J \subseteq A'$ is a two-sided ideal of $A'$;*
2. *$d(A') \subseteq J$, so $A'/J$ carries the zero differential;*
3. *every cocycle of $A$ is cohomologous to a cocycle of $A'$, and a cocycle of $A'$ bounding in $A$ already bounds in $A'$ — the inclusion $A' \hookrightarrow A$ is a quasi-isomorphism;*
4. *$J$ is acyclic, so the projection $A' \twoheadrightarrow A'/J$ is a quasi-isomorphism.*

*Therefore $A \supseteq A' \twoheadrightarrow A'/J$ is a strict zig-zag of quasi-isomorphisms of dgas onto an algebra with zero differential, and $A$ is formal with $A'/J \cong H(A)$ as $k$-algebras.*

We record the two consequences that make "$A'/J$ is the cohomology algebra" precise, and which are used again in §6: for $z \in A'$ with $dz = 0$, one has $z \in J$ if and only if $z$ is a coboundary in $A$; and every element of $A'$ is congruent modulo $J$ to a cocycle. The first follows from Propositions 4.7 and the definition of $Q$; the second from $d(A') \subseteq J$ together with acyclicity.

---

## 5. The diagonal subalgebra: a strict multiplicative lift

Theorem A produces a *subquotient* model. Under purity one can do better and exhibit a model that is a subalgebra of $A$ on the nose.

**Definition 5.1.** The **diagonal subalgebra** is
$$A^{\mathrm{diag}} = \sum_{n \in \mathbf{Z}} \big( \mathcal{A}(n,n) \cap \ker d \big) \subseteq A,$$
the span of all bihomogeneous cocycles whose weight equals their degree.

**Proposition 5.2.** $A^{\mathrm{diag}}$ is a unital $k$-subalgebra of $A$, and $d$ vanishes identically on it.

*Proof.* Vanishing of $d$: each generator lies in $\ker d$, and $\ker d$ is a submodule. Unitality: $1 \in \mathcal{A}(0,0)$ and $d1 = 0$ (Lemma 2.2(3)). Multiplicativity: for generators $x \in \mathcal{A}(n,n)\cap \ker d$ and $y \in \mathcal{A}(m,m)\cap\ker d$, the product lies in $\mathcal{A}(n+m, n+m)$ and is a cocycle by Proposition 3.1, hence lies in the summand indexed by $n+m$. Bilinearity extends this to all of $A^{\mathrm{diag}}$. $\square$

**Definition 5.3 (Strict section).** A *strict multiplicative lift* of $H(A)$ is a $k$-submodule $S \subseteq A$ such that $1 \in S$, $S\cdot S \subseteq S$, $d|_S = 0$, and every cocycle $a$ of $A$ can be written $a = z + dc$ with $z \in S$, $c \in A$.

Given such an $S$, the coboundaries lying in $S$ form a two-sided ideal of $S$: if $a \in S$ and $dc \in S$ then $a\,(dc) \in S$ is a coboundary by Proposition 3.2 (using $da = 0$), and if $dc \in S$, $b \in S$ then $(dc)b = d(cb) \in S$ is a coboundary by Proposition 3.3. So $S / (S \cap \operatorname{im} d) \cong H(A)$ as $k$-algebras.

**Theorem B (Diagonal strict lift).** *If the weight grading is pure, then $A^{\mathrm{diag}}$ is a strict multiplicative lift of $H(A)$. Consequently the cohomology algebra of $A$ is the quotient of the honest subalgebra $A^{\mathrm{diag}} \subseteq A$ — on which the differential is identically zero — by its intersection with the coboundaries.*

*Proof sketch.* By Proposition 5.2 only the lifting property remains. Let $a$ be a cocycle and decompose $a = \sum_{i \in \operatorname{supp}(a)} a_i$. Split the sum into the diagonal part $z = \sum_{i_1 = i_2} a_i$ and the off-diagonal part. Each diagonal component is a bihomogeneous cocycle of bidegree $(i_1,i_1)$, hence lies in $A^{\mathrm{diag}}$; so $z \in A^{\mathrm{diag}}$. Each off-diagonal component is a cocycle in bidegree $(i_1,i_2)$ with $i_1 \ne i_2$, hence a coboundary by purity; a finite sum of coboundaries is the coboundary of the sum of the primitives, giving $c$ with $a = z + dc$. $\square$

Theorem B is the sharpest available strict form of formality: not merely a zig-zag, but an *inclusion* $A^{\mathrm{diag}}\subseteq A$ with zero differential surjecting onto cohomology.

---

## 6. Massey products

### 6.1 Definition

Let $x,y,z$ be cocycles with $xy$ and $yz$ exact, and choose $u, v$ with $du = xy$, $dv = yz$. For a scalar $s\in k$ (which in the graded-commutative convention is the Koszul sign $\varepsilon(|x|)$) set
$$m(u,v) = s\,(u z) - x v .$$
Assuming $x,z$ are cocycles, a Leibniz computation gives $d(uz) = (du)z = xyz$ and $d(xv) = \varepsilon(|x|)\,x(dv) = \varepsilon(|x|)\,x(yz)$, so with $s = \varepsilon(|x|)$ we get $d\,m(u,v) = 0$: $m(u,v)$ is a cocycle of degree $|x|+|y|+|z|-1$. The set of classes $[m(u,v)]$ over all admissible $(u,v)$ is the **triple Massey product** $\langle x,y,z\rangle$; we say it *contains $0$* if some choice makes $m(u,v)$ exact.

### 6.2 Formality kills Massey products

**Theorem C.** *Let $(A,d)$ admit a strict formality zig-zag $A \supseteq A' \twoheadrightarrow A'/J$ as in Theorem A (only the structural properties are needed: $A'$ a subalgebra, $J$ a two-sided ideal of $A'$, $J$ acyclic, and a cocycle of $A'$ is exact in $A$ iff it lies in $J$). Let $x,z \in A'$ be cocycles and suppose $xy, yz \in A'$ are exact cocycles of $A$. Then there exist $u,v$ with $du = xy$, $dv = yz$ and $w$ with*
$$s\,(uz) - xv = dw ,$$
*provided the representative $s(uz)-xv$ is a cocycle (automatic in the graded situation). In particular $\langle x,y,z\rangle \ni 0$.*

*Proof.* Since $xy \in A'$ is a cocycle exact in $A$, it lies in $J$; by acyclicity of $J$ there is $u \in J$ with $du = xy$. Likewise $v \in J$ with $dv = yz$. Now $J$ is a two-sided ideal of $A'$, so $uz \in J$ and $xv \in J$, whence the representative $s(uz)-xv$ lies in $J$. It is a cocycle, so acyclicity of $J$ produces $w \in J$ with $dw = s(uz)-xv$. $\square$

The mechanism deserves emphasis: formality in the strict sense supplies an *absorbing acyclic ideal*, and Massey representatives are trapped inside it.

### 6.3 Purity kills Massey products: the weight-excess count

Purity gives the same conclusion directly and quantitatively.

**Theorem D.** *Assume the weight grading is pure. Let $p,q,r \in \mathbf{Z}$ and let $x \in \mathcal{A}(p,p)$, $y \in \mathcal{A}(q,q)$, $z \in \mathcal{A}(r,r)$ with $dx = dz = 0$, and suppose there exist $u_0, v_0 \in A$ with $du_0 = xy$ and $dv_0 = yz$. Then there exist $u,v,c \in A$ with*
$$du = xy, \qquad dv = yz, \qquad \varepsilon(p)\,(uz) - xv = dc .$$

*Proof.* First make the primitives bihomogeneous. Since $x \in \mathcal{A}(p,p)$ and $y\in\mathcal{A}(q,q)$ we have $xy \in \mathcal{A}(p+q,p+q)$; set $u = (u_0)_{(p+q-1,\,p+q)}$. By Lemma 2.2(1), $du = (du_0)_{(p+q,\,p+q)} = (xy)_{(p+q,p+q)} = xy$. Similarly $v = (v_0)_{(q+r-1,\,q+r)}$ satisfies $dv = yz$ and $v \in \mathcal{A}(q+r-1, q+r)$.

Now count bidegrees:
$$uz \in \mathcal{A}(p+q-1+r,\; p+q+r) = \mathcal{A}(p+q+r-1,\; p+q+r),$$
$$xv \in \mathcal{A}(p+q+r-1,\; p+q+r),$$
so the representative $m = \varepsilon(p)(uz) - xv$ is bihomogeneous of bidegree $(p+q+r-1,\, p+q+r)$: its weight exceeds its degree by exactly one.

It is a cocycle: Leibniz with the bihomogeneous left factor $u$ gives $d(uz) = (du)z + \varepsilon(p+q-1)u(dz) = xyz$; Leibniz with left factor $x$ gives $d(xv) = (dx)v + \varepsilon(p)x(dv) = \varepsilon(p)\,x(yz)$. By associativity $dm = \varepsilon(p)(xy)z - \varepsilon(p)x(yz) = 0$.

Finally purity applies, because $p+q+r-1 \ne p+q+r$: there is $c \in \mathcal{A}(p+q+r-2, p+q+r)$ with $dc = m$. $\square$

**Remark 6.1 (Excess bookkeeping).** Define $e(a) = w - n$ for $a$ bihomogeneous of bidegree $(n,w)$. Then $e(ab) = e(a)+e(b)$ and, if $du = a$ with $u$ bihomogeneous, $e(u) = e(a)+1$. Diagonal cocycles have $e = 0$; the two Massey primitives each have $e = 1$; each of the two products $uz$, $xv$ therefore has $e = 1$, and so does their difference. Purity kills everything with $e \ne 0$. The excess is a monotone defect counter: taking primitives only ever raises it.

**Remark 6.2.** The bihomogeneous primitives produced in the proof of Theorem D lie in the ideal $J$ of Theorem A: they sit in bidegree $(N-1,N)$, strictly below the diagonal, where $Q$ agrees with the full bihomogeneous piece. Theorems C and D therefore agree not only in conclusion but in the objects they produce.

### 6.4 The obstruction

**Theorem E (Non-formality obstructs purity).** *Let $x \in \mathcal{A}(p,p)$, $y\in\mathcal{A}(q,q)$, $z\in\mathcal{A}(r,r)$ be as in Theorem D, with $xy$ and $yz$ exact. If the Massey product is genuinely non-vanishing — that is, for all $u,v,c$ with $du = xy$ and $dv = yz$ one has $\varepsilon(p)(uz) - xv \ne dc$ — then the weight grading is not pure.*

*Proof.* Immediate contraposition of Theorem D. $\square$

This is the algebraic form of the second half of the geometric picture. There exist smooth proper rigid-analytic surfaces whose cohomology algebras are not formal; their non-formality is witnessed by a non-vanishing triple Massey product; Theorem E then says that no weight-graded model of such a space can have a pure weight grading. Formality is thus not a universal feature of rigid-analytic geometry but precisely a feature of the weight-monodromy régime.

---

## 7. Arbitrary weight normalisations

Weights come with conventions. Tate twists rescale them; a comparison isomorphism may multiply all weights by a fixed positive integer; in some normalisations $H^n$ is pure of weight $2n$. We now show none of this matters.

Fix an additive map $\mathrm{wt} : \mathbf{Z}\to\mathbf{Z}$, so $\mathrm{wt}(m) = \alpha m$ with $\alpha = \mathrm{wt}(1)$, and assume $\alpha > 0$. Then $\mathrm{wt}$ is strictly increasing, hence injective.

**Definition 7.1.** The weight grading is **pure along $\mathrm{wt}$** if for all $n, w$ with $w \ne \mathrm{wt}(n)$, every cocycle $a \in \mathcal{A}(n,w)$ has a primitive $c \in \mathcal{A}(n-1,w)$.

For $\mathrm{wt} = \mathrm{id}$ this is Definition 2.3.

**Theorem F.** *Assume $\alpha = \mathrm{wt}(1) > 0$ and that the weight grading is pure along $\mathrm{wt}$. Then $A$ is strictly formal: with*
$$P^{\mathrm{wt}}(n,m) = \begin{cases}\mathcal{A}(n, \mathrm{wt}\,m), & n<m,\\ \mathcal{A}(n,\mathrm{wt}\,m)\cap\ker d, & n=m,\\ 0,& n>m,\end{cases}\qquad Q^{\mathrm{wt}}(n,m) = \begin{cases}\mathcal{A}(n,\mathrm{wt}\,m), & n<m,\\ d\,\mathcal{A}(n-1,\mathrm{wt}\,m), & n=m,\\ 0,& n>m,\end{cases}$$
*and $A' = \sum P^{\mathrm{wt}}$, $J = \sum Q^{\mathrm{wt}}$, the zig-zag $A \supseteq A' \twoheadrightarrow A'/J$ consists of quasi-isomorphisms and $A'/J$ carries the zero differential. Moreover, for diagonal classes $x \in \mathcal{A}(p,\mathrm{wt}\,p)$, $y \in \mathcal{A}(q,\mathrm{wt}\,q)$, $z\in\mathcal{A}(r,\mathrm{wt}\,r)$ with $xy$, $yz$ exact, the triple Massey product contains $0$.*

*Proof sketch.* The construction and all verifications of §4 go through with the diagonal $\{(n,n)\}$ replaced by the line $\{(n,\mathrm{wt}\, n)\}$. Two points require care.

First, the *indexing*. When $\alpha > 1$ the line misses most weights: if $w \notin \mathrm{wt}(\mathbf{Z})$ then the entire weight-$w$ strand is acyclic by purity and must be discarded. Accordingly the pieces are indexed by pairs (degree, position $m$ along the line) rather than by bidegrees, and one checks that components of elements of $A'$ (resp. $J$) vanish in every bidegree not of the form $(n,\mathrm{wt}\, m)$. Injectivity of $\mathrm{wt}$ — which is where $\alpha>0$, rather than merely $\alpha \ne 0$, is used, together with monotonicity for the inequalities $n<m$ — guarantees that the index $m$ is recoverable from the bidegree, so the componentwise arguments of Lemma 4.3 survive.

Second, the *multiplicativity*: additivity of $\mathrm{wt}$ gives $\mathrm{wt}(m)+\mathrm{wt}(m') = \mathrm{wt}(m+m')$, and monotonicity gives that $n \le m$, $n'\le m'$ imply $n+n' \le m+m'$, so the truncated region is again closed under multiplication and the three-case analysis of Proposition 4.4 is unchanged.

For the Massey statement, repeat the proof of Theorem D: the primitives are taken in bidegrees $(p+q-1, \mathrm{wt}(p+q))$ and $(q+r-1, \mathrm{wt}(q+r))$, the representative lies in bidegree $(p+q+r-1, \mathrm{wt}(p+q+r))$, and $\mathrm{wt}(p+q+r) \ne \mathrm{wt}(p+q+r-1)$ by injectivity, so purity along $\mathrm{wt}$ applies. $\square$

---

## 8. Consistency and independence of purity

A conditional theorem is only as good as the consistency of its hypothesis. Two group-algebra examples settle the matter.

**Proposition G (Consistency).** *Let $k[\mathbf{Z}]$ be the group algebra of $\mathbf{Z}$, bigraded by placing the basis element $X^n$ in bidegree $(n,n)$ — formally, by grading along the diagonal homomorphism $\mathbf{Z}\to\mathbf{Z}^2$, $n \mapsto (n,n)$ — and equipped with the zero differential and $\varepsilon\equiv 1$. Then:*

1. *this is a weight-graded dga;*
2. *its weight grading is pure;*
3. *for every $n$, the element $X^n$ is a nonzero diagonal cocycle which is not a coboundary.*

*Proof.* (1) The grading is multiplicative since $n\mapsto (n,n)$ is additive, and the zero differential trivially satisfies all axioms. (2) The bihomogeneous piece in bidegree $(n,w)$ with $n \ne w$ is $0$: an element of it is supported on group elements $x$ with $(x,x) = (n,w)$, an empty condition. So every off-diagonal cocycle is $0 = d0$. (3) $X^n$ lies in bidegree $(n,n)$, is nonzero, is a cocycle since $d = 0$, and is not a coboundary since $\operatorname{im} d = 0$. $\square$

Thus purity is satisfiable by objects with nonzero cohomology in every degree — the formality theorem is not vacuous.

**Proposition H (Independence).** *Let $k[\mathbf{Z}^2]$ be bigraded tautologically, the basis element indexed by $(n,w)$ lying in bidegree $(n,w)$, with zero differential. Then this is a weight-graded dga whose weight grading is **not** pure.*

*Proof.* The basis element indexed by $(0,1)$ is a nonzero element of $\mathcal{A}(0,1)$, is a cocycle ($d=0$), and is not a coboundary ($\operatorname{im} d = 0$); its bidegree is off the diagonal. $\square$

Thus purity is a genuine restriction, and Theorem A is not secretly unconditional.

**Remark 8.1.** The classical non-formal example fits Theorem E. Take the exterior algebra on generators $x,y,z$ of degree $1$ with $dx=dy=0$ and $dz = xy$ — the model of a three-dimensional nilmanifold. Then $[x][y] = 0 = [y][y]$, and $\langle x,y,y\rangle$ is represented by $\pm zy$, which is closed and not exact. By Theorem E, no bigrading of this algebra placing $x, y$ on the diagonal and satisfying the axioms can be pure.

---

## 9. Algorithms

The theory is effective for finite-dimensional models over a computable field, and the algorithms below are exactly the constructive content of §§4–6. Let $A$ be finite-dimensional with a bihomogeneous basis, and let $d$ be given by its matrix.

### 9.1 Bigraded cohomology and the purity test

For each bidegree $(n,w)$ let $D_{n,w} : \mathcal{A}(n,w) \to \mathcal{A}(n+1,w)$ be the restriction of $d$. Then
$$\dim H^{n,w} = \dim\ker D_{n,w} - \operatorname{rank} D_{n-1,w},$$
computed by Gaussian elimination. Purity along $\mathrm{wt}$ holds iff $\dim H^{n,w} = 0$ for every $(n,w)$ with $w \ne \mathrm{wt}(n)$. Over a field with exact arithmetic (e.g. $\mathbf{Q}$) this is a decision procedure. Complexity: $O(\sum_{n,w} \dim\mathcal{A}(n,w)^3)$ field operations, i.e. cubic in the dimension, and in practice far less because the computation is block-diagonal in $w$.

### 9.2 The truncation model

Given purity, build $A'$ and $J$ by taking, in each weight strand: the full pieces below the diagonal, $\ker D_{w,w}$ on the diagonal for $A'$, and $\operatorname{im} D_{w-1,w}$ on the diagonal for $J$. The quotient $A'/J$ has, in each weight $w$, dimension $\dim H^{w,w}$, and its multiplication table is read off from that of $A$. The output is a presentation of $H(A)$ as an algebra with zero differential, verified against the direct computation of §9.1.

### 9.3 Massey products and the excess certificate

Given cocycles $x,y,z$ with $[xy]=[yz]=0$: solve the linear systems $du = xy$, $dv = yz$ (consistent by hypothesis), form $m = \varepsilon(|x|)uz - xv$, verify $dm = 0$, and test whether $m \in \operatorname{im} d$. To decide whether the *whole* Massey product contains $0$, note that the indeterminacy is the subspace $[Z\!\cdot\! z] + [x\!\cdot\! Z]$ spanned by classes $[c\,z]$ and $[x\,c']$ for cocycles $c,c'$ of the appropriate degrees; the Massey product contains $0$ iff $[m]$ lies in that subspace. All steps are rank computations.

When the algebra is bigraded, one may instead compute the *excess certificate*: read off the bidegree of $m$, and if its weight exceeds its degree, Theorem D guarantees exactness with no further computation. Conversely, if $[m] \ne 0$ modulo indeterminacy, Theorem E certifies that no pure bigrading exists.

---

## 10. Applications and discussion

### 10.1 Rigid-analytic spaces

The intended application is as follows. Let $X$ be a smooth proper rigid-analytic space over a finite extension of $\mathbf{Q}_p$. Étale and de Rham cohomology of $X$ are computed by dga models carrying a weight grading induced by the monodromy filtration; the weight-monodromy conjecture asserts purity, that $H^n$ has weight $n$ (in the normalisation of §2, or weight $\alpha n$ in a twisted normalisation, covered by §7). Theorem A then yields formality of the cohomology algebras, in the strict sense of an explicit zig-zag through a canonical truncation, and Theorem B exhibits the cohomology algebra as a quotient of the honest subalgebra of diagonal cocycles.

Conversely, the existence of smooth proper rigid-analytic surfaces with non-formal cohomology algebras is, via Theorem E, exactly the statement that these spaces cannot carry a pure weight structure of the kind weight-monodromy provides — and the obstruction is concrete and finite-dimensional: a single non-vanishing triple Massey product.

### 10.2 Relation to the Kähler picture

The complex-geometric analogue is instructive. For a compact Kähler manifold the $\partial\bar\partial$-lemma provides a zig-zag $\Omega^\bullet \supseteq \ker\partial \twoheadrightarrow \ker\partial/\operatorname{im}\partial\bar\partial$ of quasi-isomorphisms, giving formality. Structurally this is the same shape as Theorem A: a subalgebra, an acyclic absorbing ideal, a quotient with zero differential. What replaces the analytic input in our setting is the arithmetic of the weight grading, and what the present paper shows is that *only* the numerical purity is needed: no positivity, no metric, no Hodge theory.

### 10.3 Scope and limitations

Three limitations are worth stating precisely.

* The theorems concern *strict* formality of a weight-graded model. Passing from a geometric object to such a model — the construction of a bigraded dga computing étale or de Rham cohomology with the monodromy weights — is genuine geometry and is not part of the present development.
* Purity is required in the strong pointwise form of Definition 2.3, including the requirement that the primitive have the same weight. This is harmless when the weight decomposition is a decomposition of complexes, which it is here.
* The Massey results proved are for *triple* products. The excess bookkeeping of Remark 6.1 strongly suggests the same for $n$-fold products, with excess $\alpha(n-2)$; the combinatorics of defining systems and Koszul signs is the remaining ingredient. See §11.

### 10.4 What the excess invariant buys

The single most portable idea here is the weight excess $e = w - n$: additive under multiplication, raised by exactly one by each primitive, and forced to vanish on cohomology by purity. It converts homotopy-theoretic questions — does this higher operation vanish? — into arithmetic ones — is this integer zero? Any construction built from finitely many multiplications and primitives has a computable excess, and purity kills it whenever the count is nonzero. This is why the proof of Theorem D is four lines of bookkeeping rather than an obstruction-theoretic induction.

---

## 11. Future directions

Derived from the development above — purity of a weight grading (weight $= \alpha\cdot$ degree, $\alpha > 0$) implies strict formality $A \supseteq A' \twoheadrightarrow A'/J$ with zero differential on the quotient; formality and purity each force triple Massey products to contain $0$; a genuinely non-vanishing Massey product obstructs purity; and two explicit bigraded group-algebra examples show the purity hypothesis is satisfiable and not automatic — the following problems are natural, falsifiable, and not implied by what is proved.

**C1. Higher Massey products are killed by purity, with an exact excess formula.**
*Conjecture.* Let $A$ be a weight-graded dga which is pure with $\mathrm{wt}(1) = \alpha > 0$. Then for every $n \ge 3$ and every defining system for an $n$-fold Massey product of diagonal cocycles $x_1,\dots,x_n$, the resulting representative is a coboundary; more precisely, every entry $a_{i,j}$ of a bihomogeneous defining system has weight excess $w - \deg = \alpha(j-i)$, and the final representative has excess $\alpha(n-2) > 0$.
*Key insight.* The weight excess is an additive defect counter: products add it and each primitive raises it by exactly $\alpha$, so the excess of a Massey representative counts the number of primitives used and can never return to $0$.
*Why now.* The case $n=3$ is fully established and its proof is exactly this excess count; what remains is the combinatorics of defining systems and Koszul signs. Falsifiable by exhibiting a pure weight-graded dga with a nonzero $4$-fold Massey product.

**C2. Purity is detected by the diagonal subalgebra alone.**
*Conjecture.* A weight-graded dga is pure if and only if the inclusion of the diagonal cocycle subalgebra $A^{\mathrm{diag}} \subseteq A$ (with zero differential) induces a surjection on cohomology in every degree **and** the off-diagonal part of $A$ is exact as a complex in each fixed weight. In particular purity is equivalent to a statement about a single strict subalgebra, with no reference to truncations.
*Key insight.* The map $A^{\mathrm{diag}} \to H(A)$ is always multiplicative, and its surjectivity is the only place purity was used in the construction of the strict diagonal section; the converse should recover weight-wise acyclicity from surjectivity plus a dimension or graded-Nakayama argument.
*Why now.* Surjectivity under purity is already established verbatim; the converse is finite bookkeeping about the same objects. Falsifiable by an example where $A^{\mathrm{diag}}$ surjects on cohomology but some off-diagonal weight-complex has cohomology.

**C3. Non-formality of rigid-analytic surfaces has an explicit finite-dimensional witness.**
*Conjecture.* For each known non-formal smooth proper rigid-analytic surface there is a finite-dimensional bigraded dga model, of dimension bounded by an explicit function of the Betti numbers, in which a single triple Massey product of diagonal classes is non-vanishing — thereby exhibiting the obstruction of Theorem E concretely, and giving a finite certificate of the failure of purity.

Beyond these: quantify formality failure by the minimal excess at which purity breaks; extend the truncation construction to $A_\infty$-algebras and to filtered rather than graded weight structures, where the excess becomes a filtration jump; and investigate whether the weight-excess invariant detects higher-order operations in the complex-geometric setting where the second grading comes from Hodge type.

---

## 12. Conclusion

We have proved that purity of a weight grading forces formality, in the strongest strict sense: a canonical weight-wise truncation $A'$ and an acyclic absorbing ideal $J$ realise $H(A)$ as $A'/J$ with zero differential, and under purity the diagonal cocycles form an honest subalgebra with zero differential surjecting onto $H(A)$. We have shown that both formality and purity annihilate triple Massey products — the former because the primitives are trapped in an acyclic ideal, the latter by a weight-excess count that places every Massey representative exactly one unit off the diagonal — and that, contrapositively, a non-vanishing Massey product obstructs purity. The results are independent of the weight normalisation, holding along any line $w = \alpha n$ with $\alpha > 0$, and the purity hypothesis is shown to be both consistent and non-automatic by explicit group-algebra examples.

Stated arithmetically: for a smooth proper rigid-analytic space over a finite extension of $\mathbf{Q}_p$, the weight-monodromy conjecture supplies exactly the purity needed, and formality of the étale and de Rham cohomology algebras follows; where formality fails — as it does for certain surfaces — purity must fail too, and a Massey product says so.
