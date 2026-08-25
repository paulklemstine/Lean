# A Sharp Tensor-Product Certificate for Parallel Residual Blocks

**Aristotle**

**Date:** 2026-08-25

---

## Abstract

We develop the algebra of Lipschitz certificates for residual blocks — maps of the form $F(x) = x + r(x)$ on a real (semi)normed space, where the residual $r$ is $K$-Lipschitz — in the cartesian monoidal category of real normed spaces and Lipschitz maps. Our central result is that the monoidal (parallel) product of two residual blocks with certificates $K_1$ and $K_2$ is a residual block with certificate $\max(K_1,K_2)$, hence Lipschitz with constant $\max(1+K_1, 1+K_2)$ for the max product norm; and that this bound is *attained* for every pair $K_1,K_2 \ge 0$, in the strongest available sense: the set of valid Lipschitz constants of an explicit parallel pair of blocks has $\max(1+K_1,1+K_2)$ as its least element. We prove moreover that the max rule is *minimal* — any rule assigning valid parallel certificates dominates it pointwise — and that the sharp constant is *independent of the cartesian structure*, being simultaneously optimal in the $\ell^\infty$, $\ell^1$ and $\ell^2$ products.

Serial composition obeys $K_1 \ast K_2 = K_1 + K_2 + K_1K_2$, equivalently $1 + K_1\ast K_2 = (1+K_1)(1+K_2)$: the shift $K \mapsto 1+K$ is an order isomorphism of the certificate monoid $([0,\infty), \ast, 0)$ onto the multiplicative gain monoid $([1,\infty),\times,1)$, and $\ast$ distributes over $\max$. The resulting structure is the positive part of the max-times tropical semiring.

Finally, we quantify a phenomenon we call the **laxity defect**. The interchange law holds exactly at the level of maps — the cartesian product is a bifunctor — but the induced certificate calculus is only lax. For a width-two, depth-$d$ architecture with layer certificates $a_j, b_j$, the sharp gain $\max\big(\prod_j (1+a_j), \prod_j(1+b_j)\big)$ is dominated by the layerwise gain $\prod_j \max(1+a_j, 1+b_j)$, and for the alternating architecture at depth $2n$ the two are exactly $2^n$ and $4^n$. The defect is therefore unbounded in the depth even when all certificates lie in $\{0,1\}$. We close with the dual theory: certificates $K<1$ force bi-Lipschitz invertibility, and inverse certificates obey the same max rule, sharply.

**Keywords:** residual block, Lipschitz certificate, monoidal category, lax monoidal functor, product norm, tropical semiring, interchange law, bi-Lipschitz invertibility.

---

## 1. Introduction

### 1.1 Motivation

The residual parametrisation $F(x) = x + r(x)$ is the structural device that made very deep networks trainable, and it has a clean mathematical reading independent of any learning context: it is a *perturbation of the identity*. If the perturbation $r$ is $K$-Lipschitz, the perturbed map inherits stability guarantees from the identity, degraded by a controlled amount. Precisely,

$$\|F(x)-F(y)\| \le \|x-y\| + \|r(x)-r(y)\| \le (1+K)\|x-y\|,$$

so $F$ is $(1+K)$-Lipschitz. We call $K$ the block's **certificate** and $1+K$ its **gain**.

Lipschitz constants of composite maps are the currency of a great deal of applied analysis: robustness to input perturbation, well-posedness of inverse problems, stability of iterative schemes, contraction analysis of dynamical systems, and generalization bounds. In all these settings one begins with per-component constants and must assemble a constant for the whole. The assembly is governed by an algebra, and the purpose of this paper is to work out that algebra completely for residual blocks in the cartesian monoidal setting, with particular attention to (i) *sharpness* — is the assembled constant attained? — and (ii) *coherence* — does the assembled constant depend on the order in which one assembles?

### 1.2 Results

Write $\mathrm{Lip}(F)$ for the least Lipschitz constant of $F$ (an element of $[0,\infty]$).

1. **Gain bound.** A residual block with certificate $K$ is $(1+K)$-Lipschitz (Proposition 3.2).
2. **Serial rule.** The composite of blocks with certificates $K_1$ then $K_2$ is a residual block with certificate $K_1 \ast K_2 := K_1 + K_2 + K_1K_2$, i.e. gains multiply (Theorem 3.5).
3. **Parallel rule (upper bound).** The parallel product of blocks with certificates $K_1, K_2$ is a residual block on $X\times Y$ (max product norm) with certificate $\max(K_1,K_2)$, hence $\max(1+K_1,1+K_2)$-Lipschitz (Theorem 4.2).
4. **Attainment.** For every $K_1,K_2 \ge 0$ there exist blocks — the dilations of $\mathbb R$ — whose parallel product has *least* Lipschitz constant exactly $\max(1+K_1,1+K_2)$ (Theorem 4.5).
5. **Minimality.** Any function $c$ such that every parallel pair with certificates $K_1,K_2$ is $(1+c(K_1,K_2))$-Lipschitz satisfies $c(K_1,K_2)\ge\max(K_1,K_2)$ (Theorem 4.7).
6. **Metric independence.** The same number $\max(1+K_1,1+K_2)$ is the least Lipschitz constant in the $\ell^\infty$, $\ell^1$ and $\ell^2$ cartesian products (Theorem 5.4).
7. **Width and depth.** For a finite family, the sharp parallel gain is $\sup_i (1+K_i)$ (Theorems 6.2, 6.3); iterating a block $d$ times gives the sharp gain $(1+K)^d$ (Theorem 6.5); two parallel stacks give the sharp gain $\max((1+K_1)^{d_1},(1+K_2)^{d_2})$, relaxing to $\exp(\max(K_1d_1,K_2d_2))$ (Theorems 6.6, 6.7).
8. **Laxity.** The interchange law holds exactly on maps (Theorem 7.1) but only as an inequality on certificates (Theorem 7.2). For a width-two depth-$d$ architecture the layerwise certificate dominates the sharp one (Theorem 7.5), and for the alternating architecture at depth $2n$ they are exactly $2^n$ and $4^n$, so the defect is unbounded (Theorems 7.7, 7.8).
9. **Dual theory.** Certificates $K<1$ force bijectivity with $(1-K)^{-1}$-Lipschitz inverse (Theorem 8.3), and inverse certificates obey the same max rule, sharply (Theorems 8.5, 8.7).

### 1.3 Conventions

$X, Y, Z$ denote real seminormed additive commutative groups (in particular, real normed spaces). Distances are $d(x,y)=\|x-y\|$. Certificates are elements of $[0,\infty)$, written $\mathbb{R}_{\ge 0}$. On a product $X\times Y$ the default metric is the **max product metric**

$$d\big((x,y),(x',y')\big) = \max\big(d(x,x'), d(y,y')\big),$$

which is the standard product-of-metric-spaces structure and the one induced by the $\ell^\infty$ combination of the two norms. Section 5 treats the $\ell^1$ and $\ell^2$ alternatives.

For maps $f : X \to X'$ and $g: Y \to Y'$ we write $f \times g$ for $(x,y)\mapsto (f(x),g(y))$.

---

## 2. The certificate semiring

Before speaking about maps at all, we isolate the arithmetic.

**Definition 2.1 (Certificate operations).** For $a,b \in \mathbb{R}_{\ge 0}$ define

$$a \ast b := a + b + ab \qquad\text{(serial)}, \qquad a \parallel b := \max(a,b) \qquad\text{(parallel)},$$

and the **gain** $\gamma(a) := 1 + a$.

**Proposition 2.2 (Gains multiply).** $\gamma(a\ast b) = \gamma(a)\gamma(b)$; equivalently $1 + (a+b+ab) = (1+a)(1+b)$.

*Proof.* Expand. $\square$

**Proposition 2.3 (Gains of parallel).** $\gamma(a\parallel b) = \max(\gamma(a),\gamma(b))$.

*Proof.* $1 + \max(a,b) = \max(1+a,1+b)$ because translation is order preserving. $\square$

**Theorem 2.4 (Structure).** $(\mathbb{R}_{\ge0}, \ast, 0)$ is a commutative monoid; $(\mathbb{R}_{\ge0}, \parallel, 0)$ is an idempotent commutative monoid; and $\ast$ distributes over $\parallel$:

$$(a \parallel b) \ast c = (a\ast c) \parallel (b \ast c).$$

Moreover $\gamma : a \mapsto 1+a$ is an order isomorphism of $\mathbb{R}_{\ge0}$ onto $[1,\infty)$ carrying $(\ast,\parallel)$ to $(\times, \max)$; it is in particular an injective monoid homomorphism $(\mathbb{R}_{\ge0},\ast,0)\to(\mathbb{R}_{\ge0},\times,1)$.

*Proof.* Associativity, commutativity and unitality of $\ast$ are polynomial identities (or follow from Proposition 2.2 and injectivity of $\gamma$). The corresponding facts for $\parallel$ are properties of $\max$. Distributivity: both $\ast$-multiplications are monotone in each argument, so if $a\le b$ then $a\ast c \le b\ast c$ and both sides equal $b \ast c$; the case $b\le a$ is symmetric. Finally $\gamma$ is a strictly increasing bijection onto $[1,\infty)$ with inverse $g \mapsto g-1$, and Propositions 2.2, 2.3 identify the transported operations. $\square$

Thus the certificate calculus is exactly the **positive part of the max-times tropical semiring**: gains in $[1,\infty)$, "addition" $=\max$, "multiplication" $=\times$. Every statement below can be read as a statement about that semiring; the analytic content lies in showing that the semiring computations are not merely valid but optimal.

**Remark 2.5.** Monotonicity is worth recording separately: $a\le b$ and $c \le d$ imply $a\ast c \le b \ast d$, and $\ast$ is strictly monotone in each argument. Consequently the certificate order is exactly the gain order, and comparisons of architectures can be made entirely in either.

---

## 3. Residual blocks

**Definition 3.1 (Residual block).** Let $X$ be a real seminormed space and $K \ge 0$. A **residual block on $X$ with certificate $K$** is a map $r : X \to X$ that is $K$-Lipschitz; the block **computes** the map

$$B(x) := x + r(x).$$

We write $B$ both for the block and for the map it computes when no confusion arises. The **identity block** has $r \equiv 0$ and certificate $0$.

**Proposition 3.2 (Gain bound).** A residual block with certificate $K$ computes a $(1+K)$-Lipschitz map.

*Proof.* The identity is $1$-Lipschitz, $r$ is $K$-Lipschitz, and a sum of Lipschitz maps into a seminormed group is Lipschitz with the sum of the constants. $\square$

**Definition 3.3 (Dilation block).** For $K \ge 0$ the **dilation block** on $\mathbb R$ is the residual block with $r(x) = Kx$. Its certificate is exactly $K$ (since $|Kx - Ky| = K|x-y|$), and it computes $x \mapsto (1+K)x$.

Dilation blocks are the extremal objects of the whole theory: every sharpness statement below is witnessed by them. Note that they are genuinely *residual* blocks — the residual $r(x)=Kx$ has least Lipschitz constant exactly $K$, so no slack is hidden in the hypothesis.

**Definition 3.4 (Serial composition).** Given blocks $B_1$ (certificate $K_1$, residual $r_1$) and $B_2$ (certificate $K_2$, residual $r_2$) on the same space $X$, define $B_2 \circ B_1$ to be the block with residual

$$r(x) := r_1(x) + r_2\big(x + r_1(x)\big).$$

**Theorem 3.5 (Serial rule).** $B_2\circ B_1$ is a residual block with certificate $K_1 \ast K_2 = K_1+K_2+K_1K_2$, and the map it computes is the composite of the maps computed by $B_1$ and $B_2$. Consequently gains multiply: the composite is $(1+K_1)(1+K_2)$-Lipschitz.

*Proof.* The residual $r$ is a sum of a $K_1$-Lipschitz map and the composite of a $K_2$-Lipschitz map with a $(1+K_1)$-Lipschitz map (Proposition 3.2), hence $K_1 + K_2(1+K_1) = K_1\ast K_2$-Lipschitz. For the computed map,

$$x + r(x) = \big(x + r_1(x)\big) + r_2\big(x+r_1(x)\big) = B_2(B_1(x)).$$

The gain statement is Proposition 2.2. $\square$

**Corollary 3.6 (Depth).** Iterating a block of certificate $K$ $d$ times computes a $(1+K)^d$-Lipschitz map. In particular the $d$-fold iterate of the dilation block is $x\mapsto (1+K)^d x$.

---

## 4. The tensor-product certificate

We now come to the main theorem. Throughout, $X \times Y$ carries the max product metric.

**Definition 4.1 (Parallel composition).** Given blocks $B_1$ on $X$ (certificate $K_1$, residual $r_1$) and $B_2$ on $Y$ (certificate $K_2$, residual $r_2$), their **parallel composition** is the block on $X\times Y$ with residual $r_1 \times r_2 : (x,y)\mapsto (r_1(x), r_2(y))$.

**Theorem 4.2 (Tensor-product certificate; upper bound).** The parallel composition of blocks with certificates $K_1, K_2$ is a residual block on $X\times Y$ with certificate $\max(K_1, K_2)$. Consequently the map it computes, namely $B_1 \times B_2$, satisfies

$$d\big((B_1\times B_2)(p), (B_1\times B_2)(q)\big) \le \max(1+K_1,\ 1+K_2)\, d(p,q) \qquad \text{for all } p,q \in X\times Y.$$

*Proof.* Write $M := \max(K_1,K_2)$ and let $p=(x,y)$, $q=(x',y')$. Then

$$d\big((r_1\times r_2)(p),(r_1\times r_2)(q)\big) = \max\big(d(r_1x, r_1x'),\ d(r_2y,r_2y')\big) \le \max\big(K_1 d(x,x'),\ K_2 d(y,y')\big).$$

Since $K_i \le M$ and distances are nonnegative, the right-hand side is at most $M \max(d(x,x'), d(y,y')) = M\, d(p,q)$. So $r_1\times r_2$ is $M$-Lipschitz and the parallel composition is a residual block with certificate $M$. Proposition 3.2 gives the gain $1+M$, which equals $\max(1+K_1,1+K_2)$ by Proposition 2.3. $\square$

The efficiency of the proof is the point: the max product metric is exactly the structure for which the *residual* of a parallel pair is controlled by the max of the residual constants, so the parallel rule for blocks reduces to the parallel rule for arbitrary Lipschitz maps. It is the sharpness that carries the content.

**Lemma 4.3 (Sharpness for linear dilations).** For $a, b\ge0$, the map $D_{a,b} : \mathbb{R}^2 \to \mathbb{R}^2$, $(x,y)\mapsto(ax, by)$, has least Lipschitz constant exactly $\max(a,b)$ in the max product metric. That is, $\max(a,b)$ is the least element of $\{L : D_{a,b}\ \text{is}\ L\text{-Lipschitz}\}$.

*Proof.* Membership: $x\mapsto ax$ is $a$-Lipschitz and $y\mapsto by$ is $b$-Lipschitz, so Theorem 4.2's underlying estimate gives that $D_{a,b}$ is $\max(a,b)$-Lipschitz. Lower bound: let $L$ be any valid constant. Taking $p=(1,0)$, $q=(0,0)$, we have $d(p,q) = \max(1,0)=1$ and $d(D_{a,b}p, D_{a,b}q) = \max(a, 0)=a$, so $a \le L$. Taking $p=(0,1)$, $q=(0,0)$ gives $b \le L$. Hence $\max(a,b)\le L$. $\square$

**Remark 4.4.** The two test pairs are the coordinate directions; the whole sharpness argument is the observation that in the max product metric a coordinate perturbation costs the same as it does in the factor. This is precisely the property that will survive the change of product metric in Section 5.

**Theorem 4.5 (Attainment).** For every $K_1, K_2 \ge 0$, the parallel composition of the dilation blocks with certificates $K_1$ and $K_2$ computes the map $(x,y)\mapsto\big((1+K_1)x,(1+K_2)y\big)$, whose least Lipschitz constant is exactly

$$\max(1+K_1,\ 1+K_2).$$

*Proof.* The computed map is as stated by Definition 3.3, and Lemma 4.3 with $a=1+K_1$, $b=1+K_2$ gives the conclusion. $\square$

**Theorem 4.6 (The conjecture, assembled).** For all $K_1,K_2\ge0$: (i) *every* parallel pair of residual blocks with these certificates is $\max(1+K_1,1+K_2)$-Lipschitz for the max product norm; and (ii) there is such a pair whose least Lipschitz constant *equals* $\max(1+K_1,1+K_2)$.

*Proof.* Theorem 4.2 and Theorem 4.5. $\square$

**Theorem 4.7 (Minimality of the max rule).** Let $c : \mathbb{R}_{\ge0}\times\mathbb{R}_{\ge0}\to\mathbb{R}_{\ge0}$ be any rule with the property that for all $K_1,K_2$ and all residual blocks $B_1, B_2$ on $\mathbb R$ with those certificates, $B_1\times B_2$ is $\big(1 + c(K_1,K_2)\big)$-Lipschitz. Then

$$\max(K_1,K_2)\ \le\ c(K_1,K_2) \qquad \text{for all } K_1,K_2 \ge 0.$$

*Proof.* Apply the hypothesis to the dilation blocks. Then $1 + c(K_1,K_2)$ belongs to the set of valid Lipschitz constants of the map of Theorem 4.5, whose least element is $\max(1+K_1,1+K_2) = 1 + \max(K_1,K_2)$. Hence $1+\max(K_1,K_2) \le 1 + c(K_1,K_2)$ and we may cancel. $\square$

So $\parallel = \max$ is not merely a valid tensor-product certificate: it is the pointwise least one. Any other convention is strictly wasteful somewhere.

---

## 5. Independence of the cartesian structure

The max product metric is one of a family. For $p \in [1,\infty]$ let $X\times_p Y$ denote $X\times Y$ with

$$d_p\big((x,y),(x',y')\big) = \begin{cases} \big(d(x,x')^p + d(y,y')^p\big)^{1/p}, & 1\le p<\infty,\\ \max\big(d(x,x'),d(y,y')\big), & p=\infty.\end{cases}$$

Each of these is a legitimate cartesian monoidal structure on real normed spaces (all are bi-Lipschitz equivalent, with constants depending on $p$ but not on the spaces). A priori, the sharp constant of a parallel pair could depend on $p$: bi-Lipschitz equivalence preserves the *class* of Lipschitz maps but not their optimal constants.

It does not depend on $p$, and this is a genuine rigidity statement.

**Theorem 5.1 (Max rule in $\ell^1$).** If $f$ is $a$-Lipschitz on $X$ and $g$ is $b$-Lipschitz on $Y$, then $f\times g$ is $\max(a,b)$-Lipschitz on $X\times_1 Y$.

*Proof.* With $M=\max(a,b)$,
$$d_1\big((f\times g)p, (f\times g)q\big) = d(fx,fx') + d(gy,gy') \le a\,d(x,x') + b\,d(y,y') \le M\big(d(x,x')+d(y,y')\big) = M d_1(p,q).\ \square$$

**Theorem 5.2 (Max rule in $\ell^2$).** Under the same hypotheses, $f\times g$ is $\max(a,b)$-Lipschitz on $X\times_2 Y$.

*Proof.* Again with $M = \max(a,b)$, the coordinatewise bounds $d(fx,fx')\le M d(x,x')$ and $d(gy,gy')\le M d(y,y')$ give
$$d(fx,fx')^2 + d(gy,gy')^2 \le M^2\big(d(x,x')^2 + d(y,y')^2\big),$$
and taking square roots (monotone on $[0,\infty)$, with $\sqrt{M^2 t}=M\sqrt t$ for $M \ge 0$) yields $d_2((f\times g)p,(f\times g)q)\le M d_2(p,q)$. $\square$

**Theorem 5.3 (Attainment in $\ell^1$ and $\ell^2$).** For $a,b\ge0$, the map $(x,y)\mapsto(ax,by)$ on $\mathbb{R}\times_p\mathbb{R}$ has least Lipschitz constant exactly $\max(a,b)$, for $p \in \{1,2\}$.

*Proof.* Upper bounds are Theorems 5.1, 5.2. For the lower bound, test on the coordinate pairs $\big((1,0),(0,0)\big)$ and $\big((0,1),(0,0)\big)$. In each case exactly one coordinate difference is nonzero, so $d_p$ of the input pair equals $1$ and $d_p$ of the output pair equals $a$ (respectively $b$), for every $p$ — the $p$-combination of a single nonzero entry is that entry. Hence $a \le L$ and $b\le L$ for any valid $L$. $\square$

**Theorem 5.4 (Metric independence of the residual certificate).** For all certificates $K_1,K_2 \ge 0$, the number $\max(1+K_1,1+K_2)$ is simultaneously the least Lipschitz constant of the parallel pair of dilation blocks in $\mathbb{R}\times_\infty\mathbb{R}$, $\mathbb{R}\times_1\mathbb{R}$ and $\mathbb{R}\times_2\mathbb{R}$.

*Proof.* Theorem 4.5 for $p=\infty$; Theorem 5.3 with $a=1+K_1$, $b=1+K_2$ for $p\in\{1,2\}$. $\square$

The mechanism, as Remark 4.4 anticipated, is that the extremisers are supported in a single coordinate, and all $\ell^p$ combinations agree on single-coordinate vectors. The tensor-product certificate is thus an invariant of the *pair of blocks*, not of the gluing. (The argument in Theorem 5.3 is stated for $p\in\{1,2\}$, the two cases of practical interest, but the reader will see that only the single-coordinate normalisation $\|(t,0)\|_p = |t|$ is used, so it holds verbatim for every $p \in [1,\infty]$.)

---

## 6. Width and depth

The binary parallel rule extends to arbitrary finite width, with the supremum in place of the binary maximum.

**Theorem 6.1 (Wide parallel rule).** Let $I$ be a finite index set, let $X_i$ be seminormed spaces, and let $f_i : X_i \to X_i$ be $K_i$-Lipschitz. Then the product map $(x_i)_i \mapsto (f_i(x_i))_i$ is $\big(\sup_i K_i\big)$-Lipschitz for the sup product metric $d(x,y)=\sup_i d(x_i,y_i)$.

*Proof.* For each $i$, $d(f_ix_i, f_iy_i)\le K_i d(x_i,y_i) \le (\sup_j K_j)\, d(x,y)$; take the supremum over $i$. $\square$

**Theorem 6.2 (Wide certificate).** A family of residual blocks with certificates $K_i$ assembles into a residual block on $\prod_i X_i$ with certificate $\sup_i K_i$; for nonempty $I$ its gain is $\sup_i (1+K_i)$.

*Proof.* Apply Theorem 6.1 to the residuals; the gain identity $1+\sup_i K_i = \sup_i (1+K_i)$ holds on a nonempty finite index set by induction from $1+\max(a,b)=\max(1+a,1+b)$. $\square$

**Theorem 6.3 (Sharpness in every width).** For $a : I \to \mathbb{R}_{\ge0}$ with $I$ finite, the map $\mathbb{R}^I \to \mathbb{R}^I$, $x \mapsto (a_i x_i)_i$, has least Lipschitz constant exactly $\sup_i a_i$ in the sup metric.

*Proof.* Membership is Theorem 6.1. For the lower bound, fix $j$ and test on the $j$-th coordinate vector $e_j$ against $0$: $d(e_j,0)=1$ while $d(a\cdot e_j, 0) \ge a_j$. Hence $a_j\le L$ for every valid $L$ and every $j$; take the supremum. $\square$

**Theorem 6.4 (Depth bound).** The $d$-fold iterate of a residual block with certificate $K$ is $(1+K)^d$-Lipschitz.

*Proof.* Corollary 3.6, or directly: iterating a $(1+K)$-Lipschitz map $d$ times. $\square$

**Theorem 6.5 (Sharpness in depth).** The $d$-fold iterate of the dilation block with certificate $K$ is $x\mapsto (1+K)^dx$, whose least Lipschitz constant is exactly $(1+K)^d$.

*Proof.* The formula for the iterate is an induction using $B(x)=(1+K)x$. For the lower bound test on $x=1$, $y=0$. $\square$

**Theorem 6.6 (Parallel stacks).** For blocks with certificates $K_1, K_2$ and depths $d_1,d_2$, the parallel pair of stacks $B_1^{\circ d_1}\times B_2^{\circ d_2}$ is $\max\big((1+K_1)^{d_1},(1+K_2)^{d_2}\big)$-Lipschitz, and for dilation blocks this constant is least.

*Proof.* Combine Theorem 6.4 with the parallel rule (Theorem 4.2's underlying estimate for arbitrary Lipschitz maps), and Lemma 4.3 with $a = (1+K_1)^{d_1}$, $b=(1+K_2)^{d_2}$ together with Theorem 6.5's formula for the iterated dilation. $\square$

**Theorem 6.7 (Exponential relaxation).** $\max\big((1+K_1)^{d_1},(1+K_2)^{d_2}\big) \le \exp\big(\max(K_1d_1,\ K_2d_2)\big)$.

*Proof.* From $1+t \le e^t$ for $t\ge0$ we get $(1+K)^d \le e^{Kd}$; then bound each argument of the max by the max and use monotonicity of $\exp$. $\square$

Theorem 6.7 is the bridge to the estimates most often quoted in practice: a residual tower of depth $d$ whose per-layer certificates are $O(1/d)$ has gain bounded independently of $d$. Theorems 6.5 and 6.6 say that nothing better than $(1+K)^d$ is available in general — the exponential is not an artefact of the estimate but of the architecture.

---

## 7. Laxity: the same map, two certificates

We now analyse the coherence of the calculus. A rectangular architecture of width $w$ and depth $d$ assigns a certificate $K_{ij}$ to the block in stream $i \in \{1,\dots,w\}$ at layer $j \in \{1,\dots,d\}$. The computed map is unambiguous, but there are two natural ways to certify it.

**Theorem 7.1 (Interchange law on maps).** For blocks $B_1, C_1$ on $X$ and $B_2, C_2$ on $Y$,

$$(B_1 \times B_2)\circ(C_1\times C_2) = (B_1\circ C_1)\times(B_2\circ C_2)$$

as maps $X\times Y \to X\times Y$ — including as residual blocks, i.e. the two constructions produce the *same* residual.

*Proof.* Evaluate both sides at $(x,y)$: each gives $\big(B_1(C_1(x)),\ B_2(C_2(y))\big)$. $\square$

This is the statement that the cartesian product is a bifunctor: the two bracketings of a $2\times2$ grid of blocks agree on the nose. The certificates, however, do not.

**Theorem 7.2 (Interchange inequality on certificates).** For all $a,b,c,d \ge 0$,

$$(a\ast c) \parallel (b\ast d) \ \le\ (a\parallel b)\ast(c\parallel d),$$

and the inequality can be strict.

*Proof.* Both $a\ast c$ and $b\ast d$ are $\le (a\parallel b)\ast(c\parallel d)$ by monotonicity of $\ast$ (Remark 2.5), so their max is. For strictness take $a=0, b=1, c=1, d=0$: the left side is $\max(0\ast1, 1\ast0) = \max(1,1) = 1$, while the right side is $(0\parallel1)\ast(1\parallel0) = 1\ast 1 = 3$. In gains, $2$ versus $4$. $\square$

**Theorem 7.3 (Equality when the second stage is shared).** $(a \ast c)\parallel(b\ast c) = (a\parallel b)\ast c$.

*Proof.* This is the distributivity of Theorem 2.4. $\square$

So the defect is entirely a phenomenon of *heterogeneous* layers: if every stream's layer $j$ has the same certificate, layerwise and streamwise bookkeeping agree exactly.

**Theorem 7.4 (Laxity realised by genuine maps).** Take, in stream one, the identity block followed by the dilation block of certificate $1$; in stream two, the dilation block of certificate $1$ followed by the identity block. The composite map is $(x,y)\mapsto(2x,2y)$, whose least Lipschitz constant is $2$. The layerwise (parallel-first) calculus certifies $(0\parallel 1)\ast(1\parallel 0) = 3$, i.e. gain $4$.

*Proof.* Both streams compute $t\mapsto 2t$ by Theorem 3.5, and Lemma 4.3 with $a=b=2$ gives least constant $2$. The certificate computation is Theorem 7.2's witness. $\square$

Thus the certificate assignment is a **lax** monoidal functor from the category of blocks to the certificate semiring: structure-preserving up to inequality, with the inequality genuinely strict. The next results show that the strictness compounds.

**Definition 7.5 (Sharp and coarse gains).** For width-two branch certificates $a_j, b_j$, $j=0,\dots,d-1$, define

$$\mathrm{sharp}(d) := \max\Big(\prod_{j<d}(1+a_j),\ \prod_{j<d}(1+b_j)\Big), \qquad \mathrm{coarse}(d) := \prod_{j<d}\max\big(1+a_j,\ 1+b_j\big).$$

The first is depth-first bookkeeping (multiply along each stream, then take the max); the second is width-first bookkeeping (certify each layer by the max rule, then multiply).

**Theorem 7.6 (Both are valid; sharp is the truth).** Both $\mathrm{sharp}(d)$ and $\mathrm{coarse}(d)$ are valid Lipschitz constants for the parallel pair of stacks, and

$$\mathrm{sharp}(d) \le \mathrm{coarse}(d).$$

Moreover, for the parallel pair of dilation stacks — stream one composed of dilation blocks with certificates $a_j$, stream two with certificates $b_j$ — the least Lipschitz constant is exactly $\mathrm{sharp}(d)$.

*Proof.* Validity of $\mathrm{sharp}$: each stream's stack is a composition of blocks, hence has gain $\prod_j(1+a_j)$ (Theorem 3.5), and the parallel rule takes the max. Validity of $\mathrm{coarse}$: certify layer $j$ as a parallel block with certificate $a_j\parallel b_j$ (Theorem 4.2) and compose serially (Theorem 3.5), giving the product of the layer gains. The inequality is termwise: $\prod_j (1+a_j) \le \prod_j \max(1+a_j,1+b_j)$ and likewise for $b$, so the max of the two products is at most the product of the maxima. Sharpness: the stack of dilation blocks with certificates $a_j$ computes $x\mapsto \big(\prod_j (1+a_j)\big)x$ by induction, so Lemma 4.3 applies. $\square$

**Theorem 7.7 (The alternating architecture).** Let $a_j = 1$ for even $j$ and $0$ for odd $j$; let $b_j = 0$ for even $j$ and $1$ for odd $j$. Then at depth $2n$,

$$\mathrm{sharp}(2n) = 2^n, \qquad \mathrm{coarse}(2n) = 4^n.$$

*Proof.* By induction on $n$. Over each consecutive pair of layers $\{2m, 2m+1\}$, stream one contributes gains $2$ and $1$ and stream two contributes $1$ and $2$; each product therefore doubles, giving $\prod_{j<2n}(1+a_j) = \prod_{j<2n}(1+b_j) = 2^n$ and hence $\mathrm{sharp}(2n)=2^n$. Each layer, however, has $\max(1+a_j,1+b_j)=2$, so $\mathrm{coarse}(2n) = 2^{2n}=4^n$. $\square$

**Theorem 7.8 (The laxity defect is unbounded).** For every $M \ge 0$ there is a depth $2n$ at which $M\cdot \mathrm{sharp}(2n) \le \mathrm{coarse}(2n)$ for the alternating architecture. Equivalently, the over-estimation ratio $\mathrm{coarse}/\mathrm{sharp}=2^n$ tends to infinity, even though every layer certificate lies in $\{0,1\}$.

*Proof.* Choose $n$ with $2^n \ge M$ (possible since $2>1$). Then $M\cdot 2^n \le 2^n\cdot 2^n = 4^n$, and Theorem 7.7 identifies the two sides. $\square$

**Theorem 7.9 (Assembled defect statement).** At depth $2n$ the alternating width-two architecture computes a map whose least Lipschitz constant is exactly $2^n$, while layerwise max-then-compose certification returns exactly $4^n$.

*Proof.* Theorems 7.6 and 7.7. $\square$

### 7.1 A tropical reading

Arrange the gains $g_{ij} = 1+K_{ij}$ in a $w\times d$ matrix. Then

$$\mathrm{sharp} = \bigoplus_i \bigotimes_j g_{ij} = \max_i \prod_j g_{ij}, \qquad \mathrm{coarse} = \bigotimes_j \bigoplus_i g_{ij} = \prod_j \max_i g_{ij},$$

where $\oplus = \max$ and $\otimes = \times$ are the operations of the max-times tropical semiring. The laxity defect is precisely the failure of $\oplus$ and $\otimes$ to commute past one another when contracted in different orders — a tropical analogue of the difference between a permanent-style row expansion and a naive column bound. This viewpoint predicts the extremal configurations: the defect is maximised by *permutation-like* supports, in which each layer's largest certificate sits in a different stream, so that the maxima being charged layer by layer are never all collected by any single stream. The alternating architecture is exactly the width-two case of that pattern, and the general phenomenon is the subject of Conjecture 9.1 below.

### 7.2 Practical consequence

The two bookkeeping schemes have identical cost, and the depth-first one is exponentially tighter. Any stability analysis of a multi-stream architecture that certifies layer by layer — the default in most treatments — is therefore leaking a factor that grows with depth. The fix is free: accumulate along streams and take the maximum once, at the end.

---

## 8. The dual theory: contractive blocks and inverses

If the residual is a genuine contraction, the block is invertible and the whole calculus acquires a mirror image.

**Theorem 8.1 (Antilipschitz).** Let $B$ be a residual block on a normed space $X$ with certificate $K<1$. Then $B$ is antilipschitz with constant $(1-K)^{-1}$: $\|x - y\| \le (1-K)^{-1}\|B(x)-B(y)\|$. In particular $B$ is injective.

*Proof.* $\|B(x)-B(y)\| \ge \|x-y\| - \|r(x)-r(y)\| \ge (1-K)\|x-y\|$; divide. $\square$

**Theorem 8.2 (Surjectivity).** If $X$ is complete and $K<1$, then $B$ is surjective.

*Proof.* Fix $y \in X$. The map $\Phi(x) := y - r(x)$ is $K$-Lipschitz with $K<1$, hence a contraction on a nonempty complete space; by the Banach fixed point theorem it has a fixed point $x^\ast$. Then $x^\ast = y - r(x^\ast)$, i.e. $B(x^\ast) = x^\ast + r(x^\ast) = y$. $\square$

**Theorem 8.3 (Bi-Lipschitz invertibility).** On a complete space, a residual block with certificate $K<1$ computes a bijection whose inverse is $(1-K)^{-1}$-Lipschitz.

*Proof.* Bijectivity is Theorems 8.1 and 8.2. For the inverse bound apply the antilipschitz estimate at $x = B^{-1}(u)$, $y = B^{-1}(v)$: $\|B^{-1}(u)-B^{-1}(v)\| \le (1-K)^{-1}\|u-v\|$. $\square$

**Lemma 8.4 (Arithmetic of inverse certificates).** For $a,b <1$, $\ \big(1-\max(a,b)\big)^{-1} = \max\big((1-a)^{-1},(1-b)^{-1}\big)$.

*Proof.* $t\mapsto (1-t)^{-1}$ is increasing on $[0,1)$, and increasing maps commute with $\max$. $\square$

**Theorem 8.5 (Dual max rule).** Let $X, Y$ be complete and let $B_1, B_2$ be residual blocks with certificates $K_1, K_2 < 1$. Then $B_1\times B_2$ is a bijection of $X\times Y$ and its inverse is Lipschitz with constant

$$\big(1-\max(K_1,K_2)\big)^{-1} = \max\big((1-K_1)^{-1},\ (1-K_2)^{-1}\big).$$

*Proof.* The parallel composition is a residual block with certificate $\max(K_1,K_2)<1$ (Theorem 4.2), so Theorem 8.3 applies; rewrite the constant by Lemma 8.4. $\square$

**Definition 8.6 (Inward dilation).** For $0\le K<1$ the **inward dilation block** on $\mathbb R$ has residual $r(x) = -Kx$; its certificate is exactly $K$ and it computes the contraction $x\mapsto(1-K)x$, whose inverse is $y\mapsto(1-K)^{-1}y$.

**Theorem 8.7 (Sharpness of the dual rule).** For $K_1,K_2<1$, the inverse of the parallel product of the inward dilation blocks is $(u,v)\mapsto\big((1-K_1)^{-1}u,\ (1-K_2)^{-1}v\big)$, whose least Lipschitz constant is exactly $\max\big((1-K_1)^{-1},(1-K_2)^{-1}\big)$.

*Proof.* The inverse formula is immediate from Definition 8.6, and Lemma 4.3 with $a=(1-K_1)^{-1}$, $b=(1-K_2)^{-1}$ gives least constant $\max(a,b)$. $\square$

So on the contractive regime — the regime of reversible architectures and normalizing flows, where invertibility is the design goal — forward and inverse certificates are governed by the identical max rule, each attained. The parallel product restricted to contractive blocks is thus a monoidal structure on a *groupoid*, and the certificate calculus is strictly monoidal in both directions on a single layer. (Laxity, as Section 7 shows, is a phenomenon of depth, not of parallelism.)

---

## 9. Discussion and future directions

### 9.1 What is rigid and what is not

Three of our results say the theory is rigid. The max rule is **valid** (Theorem 4.2), **attained** (Theorem 4.5), and **minimal among all rules** (Theorem 4.7); and it is **independent of the product metric** (Theorem 5.4). Together these leave no room for improvement in the single-layer parallel setting, in any of the standard cartesian structures.

One result says the theory is *not* rigid, and it is the most consequential: the calculus is **lax**, and the laxity compounds exponentially with depth (Theorem 7.8). The upshot is a rule of thumb with real bite: *contract along depth first, take maxima last*.

### 9.2 Algorithmic content

The certificate calculus is directly executable. Given a $w\times d$ matrix of certificates:

- computing $\mathrm{sharp}$ costs $O(wd)$ multiplications and $w-1$ comparisons;
- computing $\mathrm{coarse}$ costs $O(wd)$ comparisons and $d-1$ multiplications;
- both are numerically delicate in the same way — products of gains overflow quickly — and should be evaluated in log space, where $\log\mathrm{sharp} = \max_i \sum_j \log g_{ij}$ and $\log\mathrm{coarse} = \sum_j \max_i \log g_{ij}$ become a max-plus (classical tropical) computation.

In log coordinates the whole theory becomes the max-plus semiring, and the laxity defect is the difference $\sum_j \max_i \ell_{ij} - \max_i \sum_j \ell_{ij} \ge 0$ with $\ell_{ij} = \log(1+K_{ij})$ — manifestly nonnegative, and manifestly maximised when the row-argmaxima are spread across distinct rows.

### 9.3 Open problems

**Conjecture 9.1 (Extremal laxity defect at arbitrary width).** For a rectangular architecture of width $w$ and depth $d$ with certificates $K_{ij} \in [0,C]$, the laxity defect

$$\frac{\prod_j \max_i (1+K_{ij})}{\max_i \prod_j (1+K_{ij})}$$

is maximised by the *cyclic* architecture $K_{ij} = C\cdot[\,j \equiv i \ (\mathrm{mod}\ w)\,]$, with extremal value $(1+C)^{d(1-1/w)}$. In particular the defect grows to $(1+C)^d$ as the width grows.

The width-two case is settled by Theorems 7.6–7.8, which give the inequality, the exact alternating values $2^n$ versus $4^n$, and unboundedness. What remains is the combinatorial optimisation over supports, in the tropical formulation of §7.1: the extremal configurations should be exactly the permutation-like supports that make every layer's maximum occur in a different stream.

**Conjecture 9.2 (Groupoid of contractive residual blocks).** The contractive residual blocks ($K<1$) on a fixed Banach space form a groupoid under serial composition; one would like to identify its structure — in particular, to determine the least certificate of a composite in terms of the certificates of the factors and their inverses, and to decide whether the inverse operation admits a sharp certificate rule beyond the bound $(1-K)^{-1}$ of Theorem 8.3.

Further directions suggested by the present results:

- **Beyond dilations.** All our extremisers are linear. Are there *nonlinear* extremisers, and is the set of blocks attaining a given sharp constant classifiable?
- **Other monoidal structures.** We work in cartesian products. What is the analogous certificate for genuinely tensorial products of normed spaces (projective or injective tensor norms), where the identity is not a coordinatewise object?
- **Stochastic and averaged blocks.** Replace the max product norm by an $L^p$ average over a distribution of streams; the certificate should interpolate between $\max$ and a genuinely $p$-dependent quantity, and the invariance of Theorem 5.4 should break in a controlled way.
- **Sharpness under constrained residuals.** In practice residuals are not arbitrary $K$-Lipschitz maps but, say, compositions of linear maps with fixed nonlinearities. Which sharp constants remain attainable within such a class?

---

## 10. Summary of results

| Statement | Content |
|---|---|
| Gain bound | A block with certificate $K$ is $(1+K)$-Lipschitz |
| Serial rule | Certificates compose by $K_1\ast K_2 = K_1+K_2+K_1K_2$; gains multiply |
| Certificate structure | $([0,\infty),\ast,\max)\cong$ positive part of the max-times tropical semiring, via $K\mapsto 1+K$ |
| Parallel upper bound | Parallel product has certificate $\max(K_1,K_2)$, gain $\max(1+K_1,1+K_2)$ |
| Attainment | Least Lipschitz constant of the parallel dilation pair equals $\max(1+K_1,1+K_2)$ |
| Minimality | Any valid parallel rule $c$ satisfies $c \ge \max$ pointwise |
| Metric independence | The same sharp constant in $\ell^\infty$, $\ell^1$, $\ell^2$ products |
| Width | Sharp gain $\sup_i(1+K_i)$ for a finite parallel family |
| Depth | Sharp gain $(1+K)^d$ for a $d$-fold stack; $\le \exp(Kd)$ |
| Interchange on maps | Exact: the cartesian product is a bifunctor |
| Interchange on certificates | Lax: $2$ versus $4$ in the smallest witness |
| Laxity defect | Alternating width-two architecture: sharp $2^n$, coarse $4^n$ at depth $2n$; unbounded |
| Invertibility | $K<1$ gives a bijection with $(1-K)^{-1}$-Lipschitz inverse |
| Dual max rule | Inverse certificates obey $\max$, attained by inward dilations |
