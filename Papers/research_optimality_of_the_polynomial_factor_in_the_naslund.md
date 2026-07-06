# The Slice-Rank Bound for Sunflower-Free Families and the Optimality of Its Polynomial Factor

**Author:** Aristotle
**Date:** 2026-07-06

## Abstract

A family $\mathcal F$ of subsets of $[n]=\{1,\dots,n\}$ is *$3$-sunflower-free* if it contains no three distinct members $A,B,C$ with all pairwise intersections equal, $A\cap B = A\cap C = B\cap C$. Resolving a conjecture of Erdős and Szemerédi, Naslund and Sawin (2017) proved that every such family satisfies $|\mathcal F| \le K\sqrt{n}\,(3/2^{2/3})^n$ for an absolute constant $K$, with exponential base $3/2^{2/3}\approx 1.8899<2$. We present a fully self-contained development of this bound via the *slice rank method*: (i) the Slice Rank Lemma, which fixes the slice rank of a diagonal tensor at the size of its support; (ii) a polynomial over $\mathbb{F}_3=\mathbb{Z}/3\mathbb{Z}$ whose per-coordinate factor vanishes exactly when a coordinate lies in exactly two of three sets, turning a uniform sunflower-free family into a diagonal tensor; (iii) the Croot–Lev–Pach degree/pigeonhole bound on the slice rank of that tensor; and (iv) the entropy asymptotics of a partial binomial sum, which produce the base $2^{H(1/3)} = 3/2^{2/3}$. We give complete definitions, statements, and proof sketches, isolate the exponential base through the identities $(3/2^{2/3})^3 = 27/4$ and $\log_2(3/2^{2/3}) = H(1/3) = \log_2 3 - \tfrac23$, and formulate the central open problem: the conjecture that the optimal polynomial factor is $n^{1/6}$ rather than the $n^{1/2}$ delivered by the layered proof.

## 1. Introduction

### 1.1 The problem

A **$k$-sunflower** (or *$\Delta$-system*) is a collection of $k$ distinct sets $A_1,\dots,A_k$ whose pairwise intersections are all equal to a common set $Y$, the *core*; the sets $A_j\setminus Y$ are the *petals* and are pairwise disjoint. The classical sunflower lemma of Erdős and Rado guarantees that any family of more than $k!\,(m-1)^{m}$ sets, each of size at most $m$, contains a $k$-sunflower. Turning this around, Erdős and Szemerédi asked how large a family of subsets of $[n]$ can be while *avoiding* sunflowers, and conjectured an exponential saving over the trivial ceiling $2^n$.

We focus on $k=3$. A family $\mathcal F\subseteq 2^{[n]}$ is **$3$-sunflower-free** if no three distinct members $A,B,C\in\mathcal F$ satisfy
$$A\cap B \;=\; A\cap C \;=\; B\cap C. \tag{1}$$
When (1) holds, the common value equals the triple intersection $A\cap B\cap C$, and the three petals are pairwise disjoint.

**Theorem (Naslund–Sawin, 2017).** *There is an absolute constant $K>0$ such that every $3$-sunflower-free family $\mathcal F\subseteq 2^{[n]}$ satisfies*
$$|\mathcal F| \;\le\; K\,\sqrt{n}\,\left(\frac{3}{2^{2/3}}\right)^{n}.$$

Since $3/2^{2/3}\approx 1.8899 < 2$, this settles the Erdős–Szemerédi conjecture for $3$-sunflowers.

### 1.2 Contributions and organization

This paper is a self-contained exposition of the slice rank proof, organized into four independent layers so that each ingredient can be understood in isolation.

- **Section 2** develops slice rank and states the **Slice Rank Lemma** for diagonal tensors.
- **Section 3** constructs the mod-$3$ detection polynomial and proves the two structural facts: the tensor is $1$ on the diagonal, and it vanishes off the diagonal on a uniform sunflower-free family.
- **Section 4** states the **Croot–Lev–Pach** slice-rank bound and assembles the main inequality $|\mathcal F|\le (n+1)\cdot 3M(n)$.
- **Section 5** carries out the entropy asymptotics, isolating the base $3/2^{2/3}=2^{H(1/3)}$.
- **Section 6** formulates the optimality conjecture for the polynomial factor and related directions.

Throughout, $\mathbb F$ denotes a field, and for a finite ground type $X$ we consider $3$-tensors $T\colon X\times X\times X\to\mathbb F$.

## 2. Slice rank and the Slice Rank Lemma

### 2.1 Definitions

**Definition 2.1 (Slice).** A tensor $s\colon X\times X\times X\to\mathbb F$ is a **rank-one slice** if it is simple in one of its three coordinates, i.e. there exist $g\colon X\to\mathbb F$ and $h\colon X\times X\to\mathbb F$ with
$$s(x,y,z) = g(x)\,h(y,z),\quad\text{or}\quad s(x,y,z)=g(y)\,h(x,z),\quad\text{or}\quad s(x,y,z)=g(z)\,h(x,y).$$

**Definition 2.2 (Slice rank).** The tensor $f$ has **slice rank at most $r$**, written $\operatorname{srk}(f)\le r$, if $f$ is a sum of at most $r$ rank-one slices:
$$f(x,y,z) = \sum_{i=1}^{m} s_i(x,y,z),\qquad m\le r,\ \text{each }s_i\text{ a slice.}$$
The slice rank $\operatorname{srk}(f)$ is the least such $r$.

**Definition 2.3 (Diagonal tensor).** Given $c\colon X\to\mathbb F$, the **diagonal tensor** $D_c$ is
$$D_c(x,y,z) = \begin{cases} c(x), & x=y=z,\\ 0, & \text{otherwise.}\end{cases}$$
Its **support** is $\operatorname{supp}(c) = \{x\in X : c(x)\ne 0\}$.

### 2.2 Elementary properties

The following are immediate from the definitions and are used to assemble bounds compositionally.

**Lemma 2.4 (Zero and monotonicity).** $\operatorname{srk}(0)=0$, and if $\operatorname{srk}(f)\le r$ and $r\le r'$ then $\operatorname{srk}(f)\le r'$.

**Lemma 2.5 (Subadditivity).** For all tensors $f,g$, $\operatorname{srk}(f+g)\le \operatorname{srk}(f)+\operatorname{srk}(g)$.

*Proof sketch.* Concatenate the two lists of slices witnessing $\operatorname{srk}(f)$ and $\operatorname{srk}(g)$; their sum is $f+g$ and the total length is the sum of lengths. $\square$

### 2.3 The Slice Rank Lemma

**Theorem 2.6 (Slice Rank Lemma; Tao, 2016).** For any finite $X$ and $c\colon X\to\mathbb F$,
$$\operatorname{srk}(D_c) \;=\; |\operatorname{supp}(c)|.$$
In particular, if $\operatorname{srk}(D_c)\le r$ then $|\operatorname{supp}(c)|\le r$.

*Proof sketch.* The inequality $\operatorname{srk}(D_c)\le|\operatorname{supp}(c)|$ is immediate: writing $S=\operatorname{supp}(c)$,
$$D_c(x,y,z) = \sum_{u\in S} c(u)\,\mathbb 1[x=u]\cdot\mathbb 1[y=u\wedge z=u],$$
a sum of $|S|$ slices. The reverse inequality is the substantive direction. Restrict attention to $S$ (off-support coordinates contribute nothing) and suppose $D_c = \sum_i g_i(x)h_i(y,z) + \sum_j g_j(y)h_j(x,z) + \sum_k g_k(z)h_k(x,y)$ with a total of $r$ slices. One shows by induction on $|S|$ that $r\ge |S|$: if the first group of slices is nonempty, the functions $g_i(x)$ span a subspace of dimension $d\le(\text{number of first-group slices})$; choosing a nonzero linear functional vanishing on that span but supported on $S$ produces a diagonal tensor on a strictly smaller support that is expressible with strictly fewer slices, and induction closes the loop. The symmetric argument handles all three groups. Hence $\operatorname{srk}(D_c)\ge|S|$. $\square$

The single consequence we need downstream is the contrapositive-style bound: *a diagonal tensor of small slice rank has small support.*

## 3. The Naslund–Sawin detection polynomial

We now specialize $X$ to be the collection of subsets of $[n]$ and work over the field $\mathbb F_3 = \mathbb{Z}/3\mathbb{Z}$.

### 3.1 Indicators and the per-coordinate factor

**Definition 3.1 (Indicator).** For $A\subseteq[n]$ and $i\in[n]$, set $a_i := \mathbb 1[i\in A]\in\mathbb F_3$, i.e. $a_i=1$ if $i\in A$ and $a_i=0$ otherwise. Since $a_i\in\{0,1\}$ we have the idempotence $a_i^2 = a_i$.

**Definition 3.2 (Core tensor).** For $A,B,C\subseteq[n]$ define, over $\mathbb F_3$,
$$T_0(A,B,C) \;=\; \prod_{i=1}^{n}\Bigl(1 - (a_i b_i + b_i c_i + c_i a_i)\Bigr).$$

The next lemma is the arithmetic heart of the method.

**Lemma 3.3 (Per-coordinate dichotomy).** For each $i$, the factor $1-(a_ib_i+b_ic_i+c_ia_i)$ equals $0$ if $i$ lies in exactly two of $A,B,C$, and equals $1$ otherwise.

*Proof.* The quantity $a_ib_i+b_ic_i+c_ia_i$ counts (in $\mathbb Z$) the number of the three pairs $\{A,B\},\{B,C\},\{C,A\}$ both of whose members contain $i$. If $i$ is in $0$ or $1$ of the sets, this count is $0$; if in exactly $2$, it is $1$; if in all $3$, it is $3$. Reducing mod $3$: the value is $0,1,0$ respectively, so the factor is $1,0,1$. $\square$

**Corollary 3.4 (Global characterization).** $T_0(A,B,C)=1$ if no coordinate $i\in[n]$ lies in exactly two of $A,B,C$, and $T_0(A,B,C)=0$ otherwise.

*Proof.* A product over $\mathbb F_3$ of terms each in $\{0,1\}$ is $1$ iff every term is $1$, and $0$ as soon as one term is $0$; apply Lemma 3.3. $\square$

### 3.2 Diagonal value

**Lemma 3.5 (Diagonal is one).** For every $A\subseteq[n]$, $T_0(A,A,A)=1$.

*Proof.* With $B=C=A$ each factor is $1-(a_i^2+a_i^2+a_i^2)=1-3a_i^2 = 1$ in $\mathbb F_3$, using $a_i^2=a_i$ and $3=0$. The product of $1$'s is $1$. $\square$

### 3.3 Sunflowers and the off-diagonal vanishing

**Lemma 3.6 (Sunflower = no "exactly two" coordinate).** Three distinct sets $A,B,C$ satisfy the sunflower condition (1) if and only if no coordinate $i\in[n]$ lies in exactly two of them.

*Proof.* Condition (1) says every element common to two of the sets is common to all three. Equivalently, no element lies in exactly two of them (an element in exactly two would belong to one pairwise intersection but not another, violating equality of the three pairwise intersections). Conversely, if no element lies in exactly two, then each pairwise intersection equals the set of elements lying in all three, so all three pairwise intersections coincide. $\square$

Now restrict the tensor to a family. Let $\mathcal F\subseteq 2^{[n]}$.

**Definition 3.7 (Restricted tensor).** Define $T_{\mathcal F}\colon (2^{[n]})^3\to\mathbb F_3$ by
$$T_{\mathcal F}(A,B,C) = \begin{cases} T_0(A,B,C), & A,B,C\in\mathcal F,\\ 0, & \text{otherwise.}\end{cases}$$

Recall that a family is an **antichain** if no member contains another; every *uniform* family (all sets of equal size) is an antichain.

**Proposition 3.8 (Diagonalization).** If $\mathcal F$ is a $3$-sunflower-free antichain, then
$$T_{\mathcal F} = D_c \quad\text{with}\quad c(A)=\mathbb 1[A\in\mathcal F],$$
i.e. $T_{\mathcal F}$ is the diagonal tensor with support exactly $\mathcal F$.

*Proof.* On the diagonal $A=B=C\in\mathcal F$, Lemma 3.5 gives $T_{\mathcal F}(A,A,A)=1=c(A)$; for $A\notin\mathcal F$ the value is $0=c(A)$. Off the diagonal, we must show $T_{\mathcal F}(A,B,C)=0$ whenever $(A,B,C)$ is not a constant triple. If any of $A,B,C\notin\mathcal F$ the value is $0$ by definition. Otherwise all three lie in $\mathcal F$ but they are not all equal. Two subcases:

*All three distinct.* By Corollary 3.4, $T_0(A,B,C)=1$ would force no coordinate in exactly two, i.e. by Lemma 3.6 a sunflower — contradicting sunflower-freeness. So $T_0=0$.

*Exactly two equal*, say $A=B\ne C$. An element of $A=B$ not in $C$ lies in exactly two of the triple, giving a $0$ factor by Lemma 3.3, unless $A\subseteq C$; but $A\subseteq C$ with $A\ne C$ violates the antichain property. Hence some coordinate lies in exactly two, and $T_0=0$ by Corollary 3.4.

In all off-diagonal cases $T_{\mathcal F}=0$, as claimed. $\square$

Combining Proposition 3.8 with the Slice Rank Lemma yields the key exact identity for uniform families:

**Corollary 3.9.** If $\mathcal F$ is a uniform $3$-sunflower-free family, then $\operatorname{srk}(T_{\mathcal F}) = |\mathcal F|$.

## 4. The Croot–Lev–Pach bound and the main inequality

The remaining ingredient bounds the slice rank of $T_{\mathcal F}$ *from above* using its polynomial structure.

**Definition 4.1 (Monomial count).** Let
$$M(n) \;=\; \#\{S\subseteq[n] : |S|\le n/3\} \;=\; \sum_{k=0}^{\lfloor n/3\rfloor}\binom{n}{k}.$$

**Theorem 4.2 (Croot–Lev–Pach slice-rank bound).** For every family $\mathcal F\subseteq 2^{[n]}$,
$$\operatorname{srk}(T_{\mathcal F}) \;\le\; 3\,M(n).$$

*Proof sketch.* Extend $T_0$ to a polynomial in the $3n$ Boolean variables $(a_i),(b_i),(c_i)$; because each $a_i^2=a_i$ etc., we may take it multilinear (squarefree) in each block. Each of the $n$ factors of $T_0$ contributes total degree $2$, and every monomial has the form $\prod_i a_i^{\alpha_i}b_i^{\beta_i}c_i^{\gamma_i}$ with $\alpha,\beta,\gamma\in\{0,1\}^n$. A pigeonhole on the three block-degrees $|\alpha|,|\beta|,|\gamma|$ shows that in each monomial at least one block carries degree at most $n/3$ (the shares cannot all exceed a third of the balanced budget). Sort the monomials by a cheapest block. Those with $|\alpha|\le n/3$ are gathered as $\sum_{|\alpha|\le n/3} a^{\alpha}\cdot h_\alpha(b,c)$, i.e. at most $M(n)$ slices of the first type; symmetrically for the $b$- and $c$-blocks. Restricting the polynomial to $\mathcal F^3$ only decreases or preserves slice rank, so $\operatorname{srk}(T_{\mathcal F})\le 3M(n)$. $\square$

**Theorem 4.3 (Main inequality).**
1. *(Uniform families.)* If $\mathcal F$ is a uniform $3$-sunflower-free family, then $|\mathcal F|\le 3\,M(n)$.
2. *(General families.)* If $\mathcal F$ is any $3$-sunflower-free family, then $|\mathcal F|\le (n+1)\cdot 3\,M(n)$.

*Proof.* (1) By Corollary 3.9 and Theorem 4.2, $|\mathcal F| = \operatorname{srk}(T_{\mathcal F})\le 3M(n)$. (2) Partition $\mathcal F$ into the $n+1$ layers $\mathcal F_k=\{A\in\mathcal F:|A|=k\}$, $k=0,\dots,n$. Each layer is uniform and, as a subfamily of a sunflower-free family, is itself sunflower-free; apply (1) to each and sum. $\square$

## 5. Asymptotics: the base $3/2^{2/3}$ and the polynomial factor

### 5.1 The binary entropy asymptotic

Let $H(p) = -p\log_2 p - (1-p)\log_2(1-p)$ be the binary entropy function.

**Lemma 5.1 (Partial binomial sum).** For fixed $\alpha\in(0,\tfrac12)$,
$$\sum_{k=0}^{\lfloor \alpha n\rfloor}\binom{n}{k} \;=\; \Theta\!\left(\frac{1}{\sqrt n}\,2^{n H(\alpha)}\right).$$

*Proof sketch.* The sum is dominated by its largest term $\binom{n}{\lfloor\alpha n\rfloor}$, since consecutive ratios $\binom{n}{k-1}/\binom{n}{k}=k/(n-k+1)$ are bounded away from $1$ for $k\le\alpha n<n/2$, making the sum a convergent geometric-type series times the top term (up to the constant factor $\tfrac{1-\alpha}{1-2\alpha}$). Stirling's formula gives $\binom{n}{\lfloor\alpha n\rfloor}=\Theta(n^{-1/2}2^{nH(\alpha)})$. $\square$

**Corollary 5.2.** With $\alpha=1/3$,
$$M(n) = \Theta\!\left(\frac{1}{\sqrt n}\,2^{nH(1/3)}\right) = \Theta\!\left(\frac{1}{\sqrt n}\left(\frac{3}{2^{2/3}}\right)^{n}\right).$$

### 5.2 Identifying the constant

**Lemma 5.3 (Constant identities).**
$$2^{H(1/3)} = \frac{3}{2^{2/3}},\qquad \log_2\!\frac{3}{2^{2/3}} = \log_2 3 - \tfrac23 = H(1/3),\qquad \left(\frac{3}{2^{2/3}}\right)^{3} = \frac{27}{4}.$$

*Proof.* $H(1/3) = \tfrac13\log_2 3 + \tfrac23\log_2\tfrac32 = \tfrac13\log_2 3 + \tfrac23(\log_2 3 - 1) = \log_2 3 - \tfrac23$. Exponentiating base $2$ gives $2^{H(1/3)} = 3\cdot 2^{-2/3} = 3/2^{2/3}$. Cubing, $(3/2^{2/3})^3 = 27/2^2 = 27/4$. Numerically $3/2^{2/3}\approx 1.8899$. $\square$

### 5.3 The proven bound

**Theorem 5.4 (Naslund–Sawin bound).** There is an absolute constant $K>0$ such that every $3$-sunflower-free family $\mathcal F\subseteq 2^{[n]}$ satisfies
$$|\mathcal F| \;\le\; K\,\sqrt{n}\,\left(\frac{3}{2^{2/3}}\right)^{n}.$$

*Proof.* By Theorem 4.3(2), $|\mathcal F|\le (n+1)\cdot 3M(n)$. By Corollary 5.2, $M(n) = O(n^{-1/2}(3/2^{2/3})^n)$. Hence $|\mathcal F| = O(n\cdot n^{-1/2}(3/2^{2/3})^n) = O(\sqrt n\,(3/2^{2/3})^n)$. $\square$

The exponential base $3/2^{2/3}<2$ resolves the Erdős–Szemerédi conjecture. The polynomial prefactor $\sqrt n$, however, is an artifact of the layering step (Theorem 4.3(2)), where the $n+1$ uniform layers each contributed. This is the source of the open problem below.

## 6. The optimality conjecture and future directions

### 6.1 The central conjecture

The uniform bound (Theorem 4.3(1)) already gives $|\mathcal F| = O(n^{-1/2}(3/2^{2/3})^n)$ *without* any polynomial loss; the $\sqrt n$ appears only when one reassembles the layers. It is natural to ask what the true polynomial factor is for arbitrary families.

**Conjecture 6.1 (Optimality of the polynomial factor).** There is an absolute constant $K>0$ such that every $3$-sunflower-free family $\mathcal F\subseteq 2^{[n]}$ satisfies
$$|\mathcal F| \;\le\; K\,n^{1/6}\,\left(\frac{3}{2^{2/3}}\right)^{n}.$$

The heuristic behind the exponent $1/6$ is a *chain-cover* picture: an extremal family behaves like a near-minimal union of inclusion-chains (each automatically sunflower-free and of size at most $n+1$), and the polynomial gap between the crude count and the true ceiling measures how few chains suffice to cover the family. Such covers are cheapest on the middle-third layer near size $n/3$, exactly where the constant $3/2^{2/3}=2^{H(1/3)}$ lives. Conjecture 6.1 asserts this measurable combinatorial parameter equals $n^{1/6}$.

### 6.2 Further directions

We record additional falsifiable conjectures emerging from this study.

**Chain-cover complexity.** The largest sunflower-free family over $[n]$ that can be covered by $n^{o(1)}$ inclusion-chains has size at most $K\,n^{1/6}(3/2^{2/3})^n$, with the $n^{1/6}$ factor achieved. The point is that the entire polynomial gap is a statement about chain-cover economy, cheapest on the middle-third layer.

**Matching-freeness nearly reaches the ceiling.** Any family over $[n]$ with no three pairwise-disjoint members has size at most $c^n$ for some $c$ strictly between $3/2^{2/3}$ and $2$: three pairwise-disjoint sets form a sunflower with empty core, so the global condition contains a purely local disjointness constraint attackable in isolation by set-pair inequalities.

**Explicit middle-third constructions.** There exist sunflower-free families concentrated near the $n/3$-layer of size $2^{cn}$ with $c$ arbitrarily close to $H(1/3)=\log_2 3 - \tfrac23$, matching the exponential base of the upper bound — since $H(1/3)$ is exactly the exponential rate of the binomial mass below $n/3$.

**A universal entropy law across petal counts.** For every $k\ge 3$, the maximum size of a family avoiding a $k$-petal constant-intersection sunflower has exponential base $2^{H(1/k)}$, recovering $3/2^{2/3}$ at $k=3$ and tending to $2$ as $k\to\infty$.

## 7. Conclusion

The slice rank method reduces a hard extremal question to three transparent facts: diagonal tensors are slice-rank rigid (Theorem 2.6); a mod-$3$ product polynomial converts a uniform sunflower-free family into such a diagonal tensor (Proposition 3.8); and the polynomial's degree bounds its slice rank by a partial binomial sum (Theorem 4.2), whose entropy asymptotics produce the base $3/2^{2/3}=2^{H(1/3)}$ (Corollary 5.2). The exponential base is now pinned down exactly, both algebraically ($(3/2^{2/3})^3=27/4$) and information-theoretically ($=2^{H(1/3)}$). What remains is the polynomial factor: the proof gives $\sqrt n$, while the chain-cover heuristic predicts the sharp $n^{1/6}$ of Conjecture 6.1. Deciding this exponent is the natural next milestone.

## References (selected, widely known)

- P. Erdős and R. Rado, *Intersection theorems for systems of sets* (1960).
- E. Croot, V. Lev, P. Pach, *Progression-free sets in $\mathbb{Z}_4^n$ are exponentially small* (2017).
- T. Tao, *A symmetric formulation of the Croot–Lev–Pach–Ellenberg–Gijswijt capset bound* (2016).
- E. Naslund and W. Sawin, *Upper bounds for sunflower-free sets* (2017).
