# One-Sidedness of Conditional-Independence Artifacts

**Aristotle**

**Date:** 2026-09-08

---

## Abstract

Empirical dependence tables are almost never computed on the true alphabet of
the explanatory variable. Label collisions — hash truncations, schema
rebuilds, coarse categorical encodings — pool distinct settings into a single
reported row. We determine the exact effect of such collisions on conditional
readings. Our starting point is a conditional data-processing inequality valid
for *arbitrary nonnegative weights*, not merely probability measures: for every
label map $f$ and every weight on $X \times Y \times Z$,
$I(f(X);Y \mid Z) \le I(X;Y \mid Z)$, with equality for injective $f$.
Consequently every collision artifact in a conditional dependence table is a
false negative; a reported conditional dependence is always genuine.

We then upgrade the inequality to an identity. The information destroyed by a
merge equals, exactly, the sum over conditioning contexts and over fibers of
the merge of the *marginal fiber deficit* minus the *sliced fiber deficits*. Every
discrepancy is thereby localised to a single (context, fiber) pair, and a
single positive local term already forces a strict global drop. Pursuing the
equality case yields a complete classification: a merged conditional reading is
exact if and only if each fiber of the merge is a product block in every context
of positive mass — equivalently, the pooled settings share a normalised response
profile — and is strictly smaller otherwise.

We supplement the sign guarantee with a computable magnitude guarantee. The
loss is bounded above by the label entropy the merge destroys, a functional of
the encoding and of the marginal dial counts alone; the bound is attained. In
particular a merge that destroys no label entropy in any context yields an
exact reading, a strict generalisation of the injective case. We further show
that merges compose, so the sign guarantee is stable under chaining; that
readings are capped by the conditional dial entropy $H(X \mid Z)$; and that a
chain rule $I(X;Y \mid Z) = I(X;(Y,Z)) - I(X;Z)$ reduces the audit of a
conditional column to two ordinary two-variable readings. Finally, explicit
$2 \times 2 \times 2$ witnesses delimit the theory: conditional and
unconditional readings are logically independent, and the sign guarantee fails
outright when the *conditioning* variable, rather than the explanatory
variable, is merged.

**Keywords.** conditional mutual information, data-processing inequality,
label merge, entropy deficit, one-sided error, collision artifact, Gibbs'
inequality, superadditivity.

---

## 1. Introduction

### 1.1 The problem

Consider a dependence table indexed by the settings of some explanatory
variable — a routing rule, a configuration dial, a treatment arm — reporting
for each context whether that variable influences an observed response. Such a
table is read as a source of claims of the form "in context $z$, the dial
influences the response" or "in context $z$, it does not."

In any realistic pipeline the dial alphabet reaching the table is a coarsening
of the true one. Identifiers are truncated to a fixed width; a hash collides;
a schema migration folds several old categories into one new one; a compound
key is logged only in part. Formally, the observed table is the pushforward of
the true joint weight along some label map $f$, and distinct true settings
$x_1 \ne x_2$ with $f(x_1) = f(x_2)$ have had their rows added together.

The question we answer is not whether the resulting table is correct — it
generally is not — but **in which direction it can be wrong**, by how much, and
under exactly which circumstances it is nonetheless right.

### 1.2 Results

Write $I(X;Y\mid Z)$ for the conditional mutual information of the dial and the
response given the context (Section 2 makes all definitions precise for
unnormalised weights). Our results are as follows.

1. **One-sidedness** (Theorem 3.1). $I(f(X);Y\mid Z) \le I(X;Y\mid Z)$ for
   every label map $f$ and every nonnegative weight, with equality for
   injective $f$. Hence a reported conditional dependence is never a false
   positive (Corollary 3.3), and conditional independence of the truth is
   inherited by every merged reading (Corollary 3.4).
2. **Exact accounting** (Theorem 4.2). The loss equals a double sum over
   contexts and fibers of marginal-minus-sliced deficits, localising every
   discrepancy; a single positive term forces a strict drop (Theorem 4.5).
3. **Classification of invisible collisions** (Theorem 5.4). Equality holds iff
   every fiber is a product block in every context of positive mass.
4. **Observable error bar** (Theorem 6.2). The loss is at most the label
   entropy destroyed by the merge, computable from the encoding and the
   marginal dial counts; the bound is attained (Section 8.3). Zero label loss
   implies exactness even for non-injective $f$ (Corollary 6.4).
5. **Chaining and structure** (Section 7). Merges compose, so readings are
   monotone along a chain; sub-dial readings are lower bounds; and
   $I(X;Y\mid Z) \le H(X\mid Z)$.
6. **Chain rule** (Theorem 7.7). $I(X;Y\mid Z) = I(X;(Y,Z)) - I(X;Z)$, an
   independent audit route through two ordinary tables.
7. **Sharpness and limits** (Section 8). Explicit witnesses show the
   conditional and unconditional readings are logically independent, the
   negative half of the guarantee is sharp, and merges of the *conditioning*
   variable are two-sided.

### 1.3 What is and is not standard

The unconditional data-processing inequality for mutual information is
classical. Three features distinguish the development below.

*Unnormalised weights.* Everything is stated for arbitrary nonnegative weights
on a finite product set, with no assumption that the total mass equals $1$. This
matters in practice, where tables hold counts rather than probabilities, and it
forces an explicit mass-correction term $-\mathrm{nlp}(\text{mass})$ in the
definition of the conditional reading. All identities and inequalities below
hold with that correction and without normalisation, with exactly one exception
(Proposition 7.8), which we flag.

*Exactness rather than inequality.* The centre of gravity is the identity of
Theorem 4.2 and the classification of Theorem 5.4, not the inequality itself.
The inequality is the corollary that the localised terms are nonnegative.

*Audit orientation.* The error bar of Theorem 6.2 is deliberately expressed in
a quantity an auditor can compute *without access to the true joint table*,
which is the operational point.

---

## 2. Setting and definitions

Throughout, $X$, $Y$, $Z$ denote finite sets: the **dial** alphabet, the
**response** alphabet, and the **context** alphabet. All logarithms are base
$2$ and all information quantities are in bits.

**Definition 2.1 (Shannon term).** For $w \ge 0$ set
$$\mathrm{nlp}(w) = -w\log_2 w, \qquad \mathrm{nlp}(0) = 0 .$$

**Definition 2.2 (Entropy of a weight).** For a finite set $S$ and a function
$w : S \to \mathbb{R}$,
$$H(S, w) = \sum_{x \in S} \mathrm{nlp}(w(x)).$$
No normalisation is assumed. For a probability vector this is the ordinary
Shannon entropy; for a general nonnegative weight of total mass $M$ one has the
useful relation $H(S,w) = M \cdot H(S, w/M) + \mathrm{nlp}(M)$.

**Definition 2.3 (Fiber deficit).** For $S$ finite and $w : S \to
\mathbb{R}_{\ge 0}$,
$$D(S, w) \;=\; H(S,w) \;-\; \mathrm{nlp}\!\Big(\sum_{x\in S} w(x)\Big)
\;=\; \sum_{x\in S} w(x)\,\log_2\frac{\sum_{x'\in S} w(x')}{w(x)} .$$
This is the entropy destroyed by pooling the block $S$ into a single label. By
Gibbs' inequality $D(S,w) \ge 0$, with equality iff at most one element of $S$
carries positive weight.

**Definition 2.4 (Two-way tables).** For $q : X \times Y \to \mathbb{R}$ put
$$q_1(x) = \sum_{y} q(x,y), \qquad q_2(y) = \sum_x q(x,y), \qquad
\mathrm{mass}(q) = \sum_{x,y} q(x,y),$$
$$I(q) \;=\; H(X, q_1) + H(Y, q_2) - H(X\times Y, q).$$
For a probability weight $I(q)$ is the ordinary mutual information $I(X;Y)$.

**Definition 2.5 (Slices, conditional reading).** For $p : X\times Y\times Z
\to \mathbb{R}$ and $z \in Z$ the **slice** is $p_z(x,y) = p(x,y,z)$. The
**conditional reading** is
$$\boxed{\;I(X;Y\mid Z) \;:=\; \sum_{z\in Z}\Big[\,I(p_z) \;-\;
\mathrm{nlp}\big(\mathrm{mass}(p_z)\big)\Big].\;}$$
Expanding, this equals $\sum_z\big[H(p_{z,1}) + H(p_{z,2}) - H(p_z) -
\mathrm{nlp}(\mathrm{mass}(p_z))\big]$; for a probability weight it reduces to
the textbook
$$\sum_{x,y,z} p(x,y,z)\,\log_2\frac{p(x,y,z)\,p(z)}{p(x,z)\,p(y,z)} .$$

**Definition 2.6 (Label merges).** A **label map** is any function
$f : X \to X'$ into a finite set. Its **fiber** over $u \in X'$ is
$f^{-1}(u) = \{x \in X : f(x) = u\}$. The **merge** of a three-way weight is the
pushforward in the first coordinate,
$$(f_* p)(u, y, z) \;=\; \sum_{x \in f^{-1}(u)} p(x, y, z),$$
and analogously $(f_*q)(u,y) = \sum_{x \in f^{-1}(u)} q(x,y)$ for two-way
tables. We write $\mathrm{push}_f w(u) = \sum_{x \in f^{-1}(u)} w(x)$ for
one-way weights.

Two elementary compatibilities are used constantly and we record them.

**Lemma 2.7.** For all $f$, $p$, $z$: (i) slicing commutes with merging,
$(f_*p)_z = f_*(p_z)$; (ii) merging preserves slice mass,
$\mathrm{mass}(f_*q) = \mathrm{mass}(q)$; (iii) merging leaves the response
marginal alone, $(f_*q)_2 = q_2$, and pushes the dial marginal forward,
$(f_*q)_1 = \mathrm{push}_f(q_1)$.

*Proof.* All three are Fubini for finite sums together with the fact that the
fibers of $f$ partition $X$. $\square$

**Lemma 2.8 (Deficit identities).** Let $w : X \to \mathbb{R}_{\ge 0}$ and
$q : X\times Y \to \mathbb{R}_{\ge 0}$. Then
$$H(X, w) - H(X', \mathrm{push}_f w) \;=\; \sum_{u \in X'} D\big(f^{-1}(u), w\big),$$
$$H(X\times Y, q) - H(X'\times Y, f_*q)
\;=\; \sum_{u\in X'}\sum_{y \in Y} D\big(f^{-1}(u),\ q(\cdot,y)\big).$$

*Proof.* Both are the observation that $H$ over a set partitioned into fibers
splits as the entropy of the pooled weights plus the within-fiber deficits, the
second applied column by column. $\square$

**Lemma 2.9 (Superadditivity of the deficit).** For $v : Y \to (X \to
\mathbb{R}_{\ge 0})$ and any block $S \subseteq X$,
$$\sum_{y\in Y} D\big(S, v_y\big) \;\le\; D\Big(S,\ \sum_{y\in Y} v_y\Big).$$

*Proof.* Rewrite $D(S,w) = M\,\mathrm{KL}$-type expression and apply concavity of
$w \mapsto H(S,w)$; equivalently, apply the log-sum inequality columnwise.
$\square$

---

## 3. One-sidedness

We first record that the conditional reading is well signed.

**Proposition 3.0 (Nonnegativity).** For every nonnegative $p$,
$I(X;Y\mid Z) \ge 0$, and per slice $I(q) - \mathrm{nlp}(\mathrm{mass}(q)) \ge 0$
for every nonnegative $q$.

*Proof sketch.* Fix a slice $q$ with mass $M$. If $M = 0$ every term vanishes.
Otherwise apply Gibbs' inequality to $q$ against the product comparison weight
$b(x,y) = q_1(x)q_2(y)/M$, which is nonnegative, absolutely continuous with
respect to $q$ (if $b(x,y)=0$ then a marginal vanishes and hence so does
$q(x,y)$, since $q(x,y) \le \min(q_1(x), q_2(y))$), and has total mass exactly
$M$. Expanding $\log_2 b(x,y) = \log_2 q_1(x) + \log_2 q_2(y) - \log_2 M$ and
resumming turns the relative entropy into precisely
$I(q) - \mathrm{nlp}(M)$. Summing over $z$ gives the conditional statement.
$\square$

The mass correction is not cosmetic: without it the slice terms would be
$M\log_2 M$ off, and for slices of mass $\ne 1$ the sum could be negative.

**Theorem 3.1 (Conditional data-processing inequality).** For every label map
$f : X \to X'$ and every nonnegative weight $p$ on $X\times Y\times Z$,
$$I(f(X);Y\mid Z) \;\le\; I(X;Y\mid Z).$$

*Proof.* By Lemma 2.7 the $z$-slice of the merged table is the merge of the
$z$-slice and has the same mass, so the mass corrections on both sides agree
slice by slice; it suffices to show $I(f_*q) \le I(q)$ for a single slice.
Using Lemma 2.7(iii),
$$I(q) - I(f_*q) = \big[H(q_1) - H(\mathrm{push}_f q_1)\big]
- \big[H(q) - H(f_*q)\big],$$
and by Lemma 2.8 this is
$\sum_u D(f^{-1}(u), q_1) - \sum_u \sum_y D(f^{-1}(u), q(\cdot,y))$, which is
nonnegative term by term by Lemma 2.9 applied with $v_y = q(\cdot,y)$, since
$\sum_y q(\cdot,y) = q_1$. $\square$

**Theorem 3.2 (Encoding invariance).** If $f$ is injective then
$I(f(X);Y\mid Z) = I(X;Y\mid Z)$.

*Proof.* Every fiber is a singleton, so every deficit in the display above
vanishes. $\square$

**Corollary 3.3 (Reconciliation of two encodings).** If $f$ is injective and
$g$ is arbitrary then $I(g(X);Y\mid Z) \le I(f(X);Y\mid Z)$: on one and the
same population, a width-valid encoding reports the true conditional value and
any other encoding reports at most that value.

**Corollary 3.4 (One-sided error).**
(i) *Dependence is never a false positive:* if $I(f(X);Y\mid Z) > 0$ then
$I(X;Y\mid Z) > 0$.
(ii) *Independence is inherited:* if $I(X;Y\mid Z) = 0$ then
$I(f(X);Y\mid Z) = 0$ for every $f$.

*Proof.* (i) is immediate from Theorem 3.1; (ii) combines Theorem 3.1 with
Proposition 3.0 applied to the merged table. $\square$

Every collision artifact in a conditional dependence table is therefore a false
negative. The converse failure is real and can be total: see Section 8.

---

## 4. Exact accounting

The proof of Theorem 3.1 in fact establishes an identity, which we now isolate
because it carries strictly more information than the inequality.

**Theorem 4.1 (Unconditional loss identity).** For every label map $f$ and
every weight $q$ on $X\times Y$,
$$I(q) - I(f_*q)
= \sum_{u\in X'} D\big(f^{-1}(u), q_1\big)
- \sum_{u\in X'}\sum_{y\in Y} D\big(f^{-1}(u), q(\cdot,y)\big).$$

*Proof.* Combine Lemma 2.8 (both parts) with Lemma 2.7(iii): the response
marginal contributes identically to $I(q)$ and $I(f_*q)$ and cancels. $\square$

**Theorem 4.2 (Conditional loss identity).** For every $f$ and every weight
$p$ on $X\times Y\times Z$,
$$I(X;Y\mid Z) - I(f(X);Y\mid Z)
= \sum_{z\in Z}\sum_{u\in X'} \Delta(z,u), \qquad
\Delta(z,u) := D\big(f^{-1}(u),\, p_{z,1}\big)
- \sum_{y\in Y} D\big(f^{-1}(u),\, p_z(\cdot,y)\big).$$

*Proof.* Apply Theorem 4.1 to each slice $p_z$ and sum; the mass corrections
cancel by Lemma 2.7(ii). $\square$

**Corollary 4.3.** $\sum_{z}\sum_u \Delta(z,u) \ge 0$, which is Theorem 3.1
restated. Moreover each individual $\Delta(z,u) \ge 0$ by Lemma 2.9.

Thus the loss is not an aggregate defect but a sum of **local, individually
nonnegative** contributions, one per (context, fiber) pair. This is what makes
the artifact diagnosable: a reported discrepancy has a return address.

**Theorem 4.4 (Fiberwise exactness criterion).** $I(f(X);Y\mid Z) =
I(X;Y\mid Z)$ if and only if $\Delta(z,u) = 0$ for every context $z$ and every
fiber $u$; that is, iff in every context and on every fiber, slicing the fiber
over the response loses no deficit.

*Proof.* A sum of nonnegative terms vanishes iff each term does; combine with
Theorem 4.2. $\square$

**Theorem 4.5 (Local strictness).** If $\Delta(z_0,u_0) > 0$ for a single pair
$(z_0,u_0)$, then $I(f(X);Y\mid Z) < I(X;Y\mid Z)$ strictly.

*Proof.* By Theorem 3.1 the reading cannot exceed the truth; equality would
force $\Delta(z_0,u_0) = 0$ by Theorem 4.4. $\square$

---

## 5. Classification of invisible collisions

Theorem 4.4 reduces exactness to the equality case of superadditivity. We now
resolve that equality case, which requires the strict form of Gibbs'
inequality.

**Lemma 5.1 (Strict Gibbs, per term).** Let $a, b \ge 0$ with $b = 0
\Rightarrow a = 0$, and $a \ne b$. Then
$$\frac{a-b}{\ln 2} \;<\; a\big(\log_2 a - \log_2 b\big).$$

*Proof sketch.* If $a = 0$ then $b>0$ and the left side is strictly negative
while the right side is $0$. If $a>0$ then $b>0$, and the claim is the strict
form of $\ln t \le t - 1$ at $t = b/a \ne 1$, multiplied by $a/\ln 2$.
$\square$

**Lemma 5.2 (Strict Gibbs).** If $a, b : S \to \mathbb{R}_{\ge 0}$ have equal
total mass, $b$ is absolutely continuous for $a$, and $a \ne b$ at some point,
then $\sum_{x\in S} a(x)\big(\log_2 a(x) - \log_2 b(x)\big) > 0$.

*Proof.* Sum Lemma 5.1 over $S$, strictly at the point of difference and weakly
elsewhere; the linear terms sum to $(\sum a - \sum b)/\ln 2 = 0$. $\square$

**Theorem 5.3 (Strict superadditivity).** Let $v_y : S \to \mathbb{R}_{\ge 0}$
for $y \in Y$, write $w = \sum_y v_y$ and $W = \sum_{x\in S} w(x) > 0$. If for
some $y_0 \in Y$ and $x_0 \in S$
$$v_{y_0}(x_0) \;\ne\; \frac{w(x_0)\cdot \sum_{x\in S} v_{y_0}(x)}{W}$$
then $\sum_y D(S, v_y) < D(S, w)$ strictly. Conversely, if every cell equals
its rank-one prediction, $v_y(x) = w(x)\,\big(\sum_{x'} v_y(x')\big)/W$ for all
$y, x$, then $\sum_y D(S,v_y) = D(S,w)$.

*Proof sketch.* Expand $D(S,v_y) = \sum_x v_y(x)\big(\log_2 \sum_{x'} v_y(x') -
\log_2 v_y(x)\big)$ and likewise for $w$. The difference $D(S,w) - \sum_y
D(S,v_y)$ is a sum over $y$ of relative entropies of the column $v_y$ against
the rank-one prediction $x \mapsto w(x)\sum_{x'}v_y(x')/W$, which has the same
column mass. Lemma 5.2 gives strict positivity as soon as one cell deviates;
the converse is a direct cancellation of logarithms after substituting the
product form. $\square$

Combining Theorems 4.4, 4.5 and 5.3 yields the classification.

**Theorem 5.4 (Classification of invisible collisions).** Let $p \ge 0$ and let
$f$ be a label map. Then
$$I(f(X);Y\mid Z) = I(X;Y\mid Z)$$
**if and only if** for every context $z$ and every fiber $u$ with positive mass
$W_{z,u} := \sum_{x\in f^{-1}(u)} p_{z,1}(x) > 0$, and for all $y\in Y$ and
$x \in f^{-1}(u)$,
$$p_z(x,y) \;=\; \frac{p_{z,1}(x)\cdot \sum_{x'\in f^{-1}(u)} p_z(x',y)}{W_{z,u}} .$$
Otherwise $I(f(X);Y\mid Z) < I(X;Y\mid Z)$ strictly.

*Proof.* ($\Leftarrow$) Fibers of zero mass contribute zero deficit on both
sides; fibers of positive mass satisfy the equality case of Theorem 5.3, so
$\Delta(z,u)=0$ throughout and Theorem 4.4 applies. ($\Rightarrow$) A violated
cell gives $\Delta(z,u)>0$ by the strict half of Theorem 5.3, whence a strict
drop by Theorem 4.5, contradicting equality. $\square$

**Interpretation (profile form).** The displayed condition says that inside a
fiber, in a given context, the joint table is rank one: every pooled dial
setting has the *same normalised response profile*, namely the fiber-average
profile $y \mapsto \sum_{x'\in f^{-1}(u)}p_z(x',y)/W_{z,u}$. So:

> A collision is invisible to the conditional reading precisely when it pools
> dial settings that are **conditionally exchangeable** — indistinguishable by
> the response in that context. Otherwise the reading strictly under-reports.

There is no intermediate regime in which two sources of error cancel.

---

## 6. An observable error bar

The sign guarantee alone leaves the magnitude of the artifact unknown. We now
bound it by a quantity computable from the label scheme and the marginal dial
counts, with no access to the joint table.

**Definition 6.1 (Label entropy destroyed).** For a label map $f$, a weight $p$
and a context $z$,
$$L_f(p,z) \;=\; H\big(X,\, p_{z,1}\big) - H\big(X',\, \mathrm{push}_f\, p_{z,1}\big)
\;=\; \sum_{u\in X'} D\big(f^{-1}(u),\, p_{z,1}\big) \;\ge\; 0,$$
the second equality being Lemma 2.8 and the nonnegativity being that of $D$.

$L_f(p,z)$ depends only on the encoding $f$ and on the **dial histogram**
$p_{z,1}$ within context $z$. It never inspects how the dial and the response
co-vary, which is exactly the data an auditor lacks.

**Theorem 6.2 (Error bar).** For every nonnegative $p$ and every $f$,
$$0 \;\le\; I(X;Y\mid Z) - I(f(X);Y\mid Z) \;\le\; \sum_{z\in Z} L_f(p,z).$$

*Proof.* The lower bound is Theorem 3.1. For the upper bound apply Theorem 4.2
and discard the (nonnegative) sliced deficits:
$\sum_{z,u}\Delta(z,u) \le \sum_z \sum_u D(f^{-1}(u), p_{z,1}) = \sum_z
L_f(p,z)$. $\square$

**Corollary 6.3 (Two-sided bracket).** The true conditional value is bracketed
by two computable numbers:
$$I(f(X);Y\mid Z) \;\le\; I(X;Y\mid Z) \;\le\; I(f(X);Y\mid Z) + \sum_z L_f(p,z).$$

**Corollary 6.4 (Exactness without injectivity).** If $L_f(p,z) = 0$ for every
context $z$ — i.e. $f$ never pools two dial settings that both occur with
positive mass in the same context — then $I(f(X);Y\mid Z) = I(X;Y\mid Z)$
exactly, even though $f$ may be wildly non-injective.

*Proof.* Immediate from Corollary 6.3. $\square$

This strictly generalises Theorem 3.2: injectivity is a global hypothesis on
$f$, whereas Corollary 6.4 only requires the collisions to be *contextually
inactive*. In practice this is the common case — a hash collision between two
rules deployed in disjoint regions costs nothing.

**Corollary 6.5 (Budget aggregation).** If $L_f(p,z) \le c$ for every context,
then the total loss is at most $|Z|\cdot c$. A per-slice error budget integrates
to a global one.

The bound of Theorem 6.2 is attained; see Section 8.3.

---

## 7. Structural properties: chaining, sub-dials, capacity, chain rule

### 7.1 Merges compose

**Lemma 7.1.** For $f : X \to X'$ and $g : X' \to X''$ and $w \in X''$,
$$\{x \in (g\circ f)^{-1}(w) : f(x) = u\} = f^{-1}(u) \quad\text{whenever } g(u) = w,$$
and this family partitions $(g\circ f)^{-1}(w)$ as $u$ ranges over $g^{-1}(w)$.

**Theorem 7.2 (Composition).** $g_*(f_* p) = (g\circ f)_* p$ for every weight
$p$.

*Proof.* Both sides evaluated at $(w,y,z)$ sum $p(\cdot, y, z)$ over
$(g\circ f)^{-1}(w)$; the left side does so by first grouping along the fibers
of $f$, which is legitimate by Lemma 7.1 (a fiberwise regrouping of a finite
sum). $\square$

**Theorem 7.3 (Chained bugs are still one-sided).** For all $f, g$ and
nonnegative $p$,
$$I\big(g(f(X));Y\mid Z\big) \;\le\; I\big(f(X);Y\mid Z\big) \;\le\; I(X;Y\mid Z).$$

*Proof.* Rewrite the left term via Theorem 7.2 as the reading of $g_*(f_*p)$
and apply Theorem 3.1 to the nonnegative weight $f_*p$; the right inequality is
Theorem 3.1 again. $\square$

Chaining is thus not a new phenomenon requiring new hypotheses: it is the same
operation with a composite label map. Errors accumulate monotonically; a second
defect can never cancel a first and push a reading above the truth.

### 7.2 Sub-dials

**Theorem 7.4.** Let the dial be compound, $X = X_1\times X_2$, and suppose only
the first coordinate is reported. Then
$$I(X_1;Y\mid Z) \;\le\; I\big((X_1,X_2);Y\mid Z\big).$$

*Proof.* The projection $\mathrm{pr}_1 : X_1\times X_2 \to X_1$ is a label map;
apply Theorem 3.1. $\square$

Reporting part of a compound key is a merge, and so inherits the guarantee: a
sub-dial reading is a lower bound for the full-dial reading.

### 7.3 The capacity cap

**Lemma 7.5.** For a nonnegative two-way weight $q$, $H(Y,q_2) \le H(X\times
Y,q)$: a marginal never carries more entropy than the joint weight it came
from. Consequently $I(q) \le H(X, q_1)$.

*Proof.* Write $H(X\times Y,q) = \sum_y \sum_x \mathrm{nlp}(q(x,y))$ and use
$\mathrm{nlp}\big(\sum_x q(x,y)\big) \le \sum_x \mathrm{nlp}(q(x,y))$ columnwise
(subadditivity of $\mathrm{nlp}$ on nonnegative summands, i.e. nonnegativity of
the deficit). $\square$

**Theorem 7.6 (Capacity cap).** For nonnegative $p$,
$$I(X;Y\mid Z) \;\le\; \sum_{z}\Big[H\big(X,p_{z,1}\big) -
\mathrm{nlp}\big(\mathrm{mass}(p_z)\big)\Big] \;=\; H(X\mid Z).$$

*Proof.* Apply Lemma 7.5 slice by slice and subtract the mass corrections.
$\square$

Since a merge also lowers $H(X\mid Z)$ (Lemma 2.8), a merged table can never
report more dependence than the label entropy that survives the merge. Coarse
tables are not merely biased downward; they are capped.

### 7.4 The chain rule

The slice-wise definition needs the full three-way table. The following
identity replaces it by two ordinary two-variable readings, providing an
independent audit route. Write $p_{XZ}(x,z) = \sum_y p(x,y,z)$ for the context
channel, and read $p$ itself as the two-way table of $X$ against the pair
$(Y,Z)$.

**Theorem 7.7 (Entropy balance and chain rule).** For every weight $p$ (no
normalisation needed),
$$I(X;Y\mid Z) = H(X,Z) + H(Y,Z) - H(X,Y,Z) - H(Z),$$
and consequently
$$I(X;Y\mid Z) \;=\; I\big(X;(Y,Z)\big) \;-\; I(X;Z).$$

*Proof sketch.* Summing the four slice-wise terms of Definition 2.5 over $z$
identifies each with a global entropy: $\sum_z H(X, p_{z,1}) = H(X\times Z,
p_{XZ})$, $\sum_z H(Y, p_{z,2}) = H(Y\times Z, p_2)$, $\sum_z H(X\times Y, p_z)
= H(X\times Y\times Z, p)$, and $\sum_z \mathrm{nlp}(\mathrm{mass}(p_z)) =
H(Z, (p_{XZ})_2)$. That is the balance. For the second display note that
$I(X;(Y,Z)) = H(X, p_1) + H(Y\times Z, p_2) - H(p)$ and $I(X;Z) = H(X,
(p_{XZ})_1) + H(Z,(p_{XZ})_2) - H(X\times Z, p_{XZ})$, and that $(p_{XZ})_1 =
p_1$; subtracting cancels the dial marginal. $\square$

**Proposition 7.8 (A guarded comparison).** If $p \ge 0$ and
$\sum p \le 1$, then $I(X;Y\mid Z) \le I(X;(Y,Z))$.

*Proof.* By Theorem 7.7 the difference is $I(X;Z)$, and by Proposition 3.0
$I(p_{XZ}) \ge \mathrm{nlp}(\mathrm{mass}(p_{XZ}))$; the mass hypothesis makes
$\mathrm{nlp}(\mathrm{mass}) \ge 0$. $\square$

The hypothesis is necessary and marks a genuine boundary of the unnormalised
theory. For total mass exceeding $1$, $\mathrm{nlp}(\mathrm{mass})$ turns
negative and the context reading $I(p_{XZ})$ can dip below zero, breaking the
comparison. This is a normalisation defect, not a failure of the underlying
mathematics: all the results of Sections 3–7.3 are normalisation-free, and only
this comparison between a conditional and an unconditional reading requires the
weight to be a subprobability.

**Diagnostic reading.** The identity $I(X;(Y,Z)) = I(X;Y\mid Z) + I(X;Z)$ says
that a loud pair channel is explained *either* by genuine conditional
dependence *or* by dial/context coupling, and never by both being small. If the
pair channel is large while the conditional column is quiet, the dial is
entangled with the context — typically a statement about data collection rather
than about the system.

---

## 8. Sharpness, witnesses, and the boundary of the guarantee

All witnesses live on $X = Y = Z = \{0,1\}$ and are exhibited as explicit
weights.

### 8.1 Conditional and unconditional readings are logically independent

**The parity population.** Put weight $1/4$ on each of the four cells with
$z = x \oplus y$ and $0$ elsewhere. Its $X,Y$-marginal is uniform on all four
cells, so
$$I(X;Y) = 0 \text{ bits}.$$
Each of its two slices has mass $1/2$ and is supported on two diagonal cells of
weight $1/4$; a direct computation gives slice reading $1 - 1/2 = 1/2$ bits,
hence
$$I(X;Y\mid Z) = 1 \text{ bit}.$$

**The copy population.** Put weight $1/2$ on each of the two cells with
$x = y = z$. Its $X,Y$-marginal is the diagonal with weights $1/2$, so
$I(X;Y) = 1$ bit; each slice is a single cell, so every slice reading is $0$
and $I(X;Y\mid Z) = 0$.

Together: neither reading bounds the other. A guarantee about conditional
columns cannot be deduced from the single-dial tables, and vice versa. In
particular, the one-sidedness theorem proved here is *per-dial and conditional*;
the corresponding claim about unconditional tables requires a separate argument.

### 8.2 The negative half is sharp

Let $\mathrm{c} : \{0,1\}\to\{*\}$ be the collapsing merge. Applied to the
parity population it yields a one-row table, whose reading is $0$ bits, whereas
the truth is $1$ bit:
$$I(\mathrm{c}(X);Y\mid Z) = 0 < 1 = I(X;Y\mid Z).$$
A reported conditional independence can therefore be a *pure artifact*: the
merged table retains no trace of a maximal dependence.

### 8.3 The error bar is attained

For the same pair, the collapsing merge destroys exactly $1/2$ bit of label
entropy in each of the two contexts ($H$ of the uniform dial histogram of mass
$1/2$ on two settings, minus $H$ of the pooled mass $1/2$, equals $1 - 1/2$),
so $\sum_z L_{\mathrm{c}}(p,z) = 1$ bit, matching the loss exactly. The
inequality of Theorem 6.2 is therefore tight and cannot be improved in general.

### 8.4 Detection criterion fires

In the context $z = 1$ of the parity population, the fiber $\{0,1\}$ of the
collapsing merge is not a product block: the cell $(x,y)=(0,1)$ carries $1/4$
while the rank-one prediction from its row and column sums is
$(1/4)(1/4)/(1/2) = 1/8$. Theorem 5.4 therefore predicts a strict drop
independently of the numerical evaluation, and indeed the drop is a full bit.

### 8.5 The chain rule, numerically

For the parity population, $I(X;(Y,Z)) = 1$ bit and $I(X;Z) = 0$ bits, whose
difference $1$ agrees with the direct conditional computation. For the copy
population, $I(X;(Y,Z)) = 1$ and $I(X;Z) = 1$, whose difference $0$ agrees.
Both are independent confirmations of Theorem 7.7.

### 8.6 The guarantee is specific to the dial axis

Define the merge of the **conditioning** variable by
$(f^{\sharp}p)(x,y,w) = \sum_{z : f(z)=w} p(x,y,z)$, and apply the collapsing
merge $\mathrm{c}$ to the context.

* On the parity population, the reading falls from $1$ bit to $0$: collapsing
  contexts *destroys* dependence.
* On the copy population, the reading rises from $0$ to $1$ bit: collapsing
  contexts *manufactures* dependence.

**Theorem 8.1 (Two-sidedness of context merges).** There exist nonnegative
weights $p, p'$ and a context merge $\mathrm{c}$ with
$$I_{\mathrm{c}}(p) < I(p) \qquad\text{and}\qquad I_{\mathrm{c}}(p') > I(p'),$$
where $I_{\mathrm{c}}$ denotes the reading after collapsing the context. Hence
no analogue of Theorem 3.1 holds on the conditioning axis.

**Why the axes differ.** The asymmetry is legible in Theorem 4.2. A dial merge
subtracts sliced deficits from marginal deficits *inside a fixed slice*, and the
sign is fixed by superadditivity (Lemma 2.9), i.e. by concavity of entropy. A
context merge instead *recombines* slices, replacing several slice readings by
the reading of their sum; no convexity constrains the direction of that
recombination. Everything one-sided in this theory happens on the dial axis;
everything two-sided happens on the context axis.

---

## 9. Algorithms and audit procedures

The theory yields four concrete procedures. Let $n = |X|$, $m = |Y|$,
$k = |Z|$, $n' = |X'|$.

**A. Reading computation.** Compute $I(X;Y\mid Z)$ from a three-way table in
$O(nmk)$ time and $O(nm)$ working space: for each of the $k$ contexts, form the
two marginals and the joint entropy in one pass over the slice.

**B. Artifact localisation.** Given the true table and a merge $f$, compute all
$\Delta(z,u)$ of Theorem 4.2 in $O(nmk)$ time, and report the (context, fiber)
pairs sorted by contribution. Because the terms are individually nonnegative
and sum exactly to the loss, this is a complete attribution: the top few pairs
account for a stated fraction of the discrepancy.

**C. Audit bracket.** Given only the merged table and the per-context dial
histograms, compute the bracket of Corollary 6.3 in $O(nk + n'mk)$ time. Flag
each conditional cell as *certified dependent* (merged reading $>0$),
*inconclusive with bound $b$* (merged reading $0$, label loss $b > 0$), or
*certified exact* (label loss $0$, so Corollary 6.4 applies).

**D. Exchangeability test.** For each context and fiber, test the rank-one
condition of Theorem 5.4 to within numerical tolerance in $O(nmk)$ total time.
A failure is a certificate that the reading is strictly low; a global pass is a
certificate that it is exact.

Procedure C is the operationally significant one, because it needs no access to
the true joint table — only to the encoding and to marginal counts.

---

## 10. Discussion

### 10.1 The shape of the guarantee

The result is best understood not as an accuracy statement but as a **sign**
statement, and sign statements have different robustness properties from
accuracy statements. An accuracy bound degrades when its modelling assumptions
fail, often silently. The guarantee here survives arbitrary coarsening,
arbitrary chaining (Theorem 7.3), arbitrarily bad encodings, and unnormalised
count data, because it does not depend on how bad any of these are. Its
practical analogue is a diagnostic test with no false positives: possibly
insensitive, of unknown sensitivity, but a positive result is proof.

The three layers fit together as follows: Theorem 3.1 fixes the *sign*;
Theorem 6.2 fixes the *size* in observable terms; Theorem 5.4 fixes the
*condition* under which the error is zero. Together they say a merged table
supports the inference "dependent" unconditionally, supports the inference
"exact" whenever the fiberwise exchangeability test passes, and otherwise
supports the inference "at least this dependent, and at most this much more."

### 10.2 Scope

The theory is finite and combinatorial: finite alphabets, finite nonnegative
weights. Nothing assumes normalisation except Proposition 7.8, which is flagged
and whose failure mode is understood. Nothing assumes the weight arises from a
probability model at all, which is what makes the statements directly
applicable to raw count tables.

The guarantee is **per-dial and conditional**. Section 8.1 shows this is not a
limitation of the proof but of the truth: the conditional and unconditional
readings are logically independent, so the corresponding claim for single-dial
tables is a genuinely separate proposition requiring its own argument. Likewise
Theorem 8.1 shows the guarantee cannot be extended to merges of the
conditioning variable.

### 10.3 Relation to classical information theory

Theorem 3.1 is a data-processing inequality, and in the normalised case with
$f$ deterministic it specialises to a statement that is standard. The
contributions here are the extension to unnormalised weights with the correct
mass correction; the promotion of the inequality to the exact local identity of
Theorem 4.2; the complete equality classification of Theorem 5.4; and the
observable error bar of Theorem 6.2, which appears to have no classical
counterpart because classical treatments do not distinguish quantities the
auditor can and cannot compute.

---

## 11. Future directions

**1. Profile form of the detection criterion.** The product condition of
Theorem 5.4 should be equivalent to the purely operational statement that all
dial settings inside a fiber have the *same normalised response profile* in that
context; consequently $I(f(X);Y\mid Z) < I(X;Y\mid Z)$ exactly when some fiber
contains two positive-mass settings whose profiles differ. The rank-one
prediction $w(x)\cdot V_y/W$ is precisely the assertion "profile of $x$ equals
the fiber-average profile", so the classification already proved should yield
this as a corollary, and it is the form an implementer would test directly.

**2. Quantitative detection.** Theorem 5.4 is a dichotomy; a quantitative
version bounding the drop from below in terms of a distance between profiles
(total variation, or $\chi^2$) would convert the qualitative certificate of
procedure D into a lower bound on the missing information, complementing the
upper bound of Theorem 6.2 and closing the bracket from the other side.

**3. Sharper error bars.** The bound of Theorem 6.2 discards all sliced
deficits, which is lossy in typical cases (empirically the slack is large). A
bound that retains a computable proxy for the sliced deficits — for example one
based on the merged table's own column structure — would tighten the audit
bracket substantially while remaining computable without the true table.

**4. Normalisation.** Proposition 7.8 fails for total mass exceeding $1$ because
$\mathrm{nlp}(\mathrm{mass})$ changes sign. A systematically normalised variant
of the whole theory, or a reformulation in which the mass correction is
absorbed, would remove the one hypothesis that is not intrinsic.

**5. Context-axis structure.** Theorem 8.1 rules out a sign guarantee for
context merges, but does not rule out a *bounded* guarantee: a two-sided bound
on how much a context merge can move a reading, in terms of an observable of the
context encoding, would extend the audit framework to the remaining axis.

**6. Randomised label maps.** Merges here are deterministic functions. Extending
the exact accounting of Theorem 4.2 to stochastic label maps (noisy or
probabilistic encodings) would cover sampling and privacy mechanisms; the
expected form of the answer is that the fiber deficits are replaced by
conditional deficits of the channel.

---

## 12. Summary of results

| Result | Statement |
|---|---|
| Nonnegativity | $I(X;Y\mid Z) \ge 0$ for every nonnegative weight |
| Conditional data-processing inequality | $I(f(X);Y\mid Z) \le I(X;Y\mid Z)$ |
| Encoding invariance | equality for injective $f$ |
| One-sided error | reported dependence is never a false positive |
| Exact accounting | loss $=\sum_{z,u}\big[$marginal deficit $-$ sliced deficits$\big]$ |
| Local strictness | one positive local term forces a strict drop |
| Classification | exact $\iff$ every fiber is a product block in every context of positive mass |
| Observable error bar | loss $\le$ label entropy destroyed; attained |
| Exactness without injectivity | zero label loss $\Rightarrow$ exact reading |
| Composition | $g_*(f_*p) = (g\circ f)_*p$; readings monotone along a chain |
| Sub-dial bound | reporting one coordinate of a compound dial is a lower bound |
| Capacity cap | $I(X;Y\mid Z)\le H(X\mid Z)$ |
| Chain rule | $I(X;Y\mid Z) = I(X;(Y,Z)) - I(X;Z)$ |
| Logical independence | witnesses with $I(X;Y)=0, I(X;Y\mid Z)=1$ and $I(X;Y)=1, I(X;Y\mid Z)=0$ |
| Two-sidedness on the context axis | context merges can both destroy and manufacture dependence |
