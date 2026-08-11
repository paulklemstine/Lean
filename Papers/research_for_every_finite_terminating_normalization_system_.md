# The Thermodynamics of Proof Normalization: Fiber Entropy, Bureaucratic Calculi, and Compositional Landauer Accounting

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Proof normalization is a many-to-one operation, and by Landauer's principle any physical
realization of a many-to-one map must dissipate heat proportional to the information it
destroys. This paper develops an exact information-theoretic accounting for that dissipation
on finite proof systems, and establishes four principal results.

First, the **Fiber-Entropy Law**: for a finite normalization map $f$ and an arbitrary
non-negative weight $p$ on proof terms, the Shannon entropy destroyed, $H(x \mid f x)$, is
bounded above by the expected logarithm of the normalization-fiber size,
$\mathbb{E}_p[\log_2 |f^{-1}(f x)|]$, with equality **if and only if** $p$ is constant on
each fiber; any fiberwise non-uniformity makes the bound strict. The law requires no
normalization of $p$ and treats zero weights and empty fibers as genuine instances rather
than exclusions. In energetic units it says that the fiber-counting heuristic is
thermodynamically exact on fiberwise-uniform laws and strictly wasteful otherwise.

Second, an **explicit strongly normalizing calculus with exponential fibers and short
conclusions**. For each $n$ we present a rewrite system with $n$ rules whose derivations
carry $n$-bit conclusions, which is strongly normalizing (well-founded, not merely weakly
terminating), whose normal forms are *characterized* as the irreducible terms, which has
unique normal forms, which normalizes in at most $n$ steps, and whose every normalization
fiber has cardinality exactly $2^n$. Consequently normalization destroys exactly $n$ bits
and dissipates exactly $n\,k_B T \ln 2$ of heat, an equality rather than a bound.

Third, **compositional Landauer accounting**: for two obligations verified by $f$ and $g$
under an arbitrary non-negative joint law, the difference between separate and joint
verification cost equals the *drop* in mutual information, $I(\text{in}) - I(\text{out})$.
The naive conjecture "saving $=$ mutual information" is false in general and correct exactly
when verification destroys all correlation. Additivity for independent obligations and
non-negativity of the saving (via a data-processing inequality for mutual information) follow.

Fourth, a **pipeline dichotomy**: conditional entropy is exactly additive along a composite
normalization $X \to Y \to Z$ for every non-negative law, while the fiber-counting estimate
is only subadditive for uniform laws — with an exact equality criterion — and fails to be
subadditive at all for skewed laws, as an explicit fully supported three-term counterexample
shows. Entropy composes; multiplicity does not.

**Keywords:** Landauer's principle, proof normalization, conditional entropy, rewriting
systems, strong normalization, mutual information, data-processing inequality.

---

## 1. Introduction

### 1.1 Erasure as the only thermodynamic cost of computation

Landauer's principle states that the erasure of one bit of information in a physical device
at temperature $T$ dissipates at least $k_B T \ln 2$ of heat, $k_B$ being Boltzmann's
constant. Its converse — that logically reversible computation has no unavoidable
thermodynamic cost — makes the principle a statement about *information destruction*
specifically, not about computation in general. Whenever a computational process implements
a non-injective map, the informational deficit is a lower bound on the entropy exported to
the environment.

Proof normalization is such a process, and conspicuously so. Cut elimination, $\beta$-normal
form computation, permutative (commuting) conversions, and every other proof-tidying
operation take many derivations to a single canonical one. The pre-images of a canonical
proof under normalization — its **normalization fiber** — record precisely the bookkeeping
that the normalizer throws away.

### 1.2 The counting heuristic and its failure

The first estimate anyone writes down for the cost of a normalization step is the logarithm
of the fiber size. If a normal proof has $N$ derivations collapsing onto it, one seems to
lose $\log_2 N$ bits. Averaged over the proof law $p$, this gives the *fiber-counting
estimate*
$$\mathbb{E}_p\big[\log_2 |f^{-1}(f x)|\big].$$
This quantity is purely combinatorial. The thermodynamically correct quantity is the
conditional entropy $H(x \mid f x)$, which is statistical. They coincide only under a
condition, and the first business of this paper is to identify that condition exactly and to
show that outside it the counting estimate is *strictly* pessimistic.

### 1.3 Contributions and organization

Section 2 fixes notation and the four functionals used throughout. Section 3 proves the
sharp maximum-entropy equality case for unnormalized weights and derives the Fiber-Entropy
Law together with its strict form and its Landauer reading, and gives a fully worked
numerical instance where the gap is $\tfrac54 - \tfrac34\log_2 3 \approx 0.0613$ bits.
Section 4 constructs the bureaucratic calculus and proves strong normalization,
characterization and uniqueness of normal forms, the linear normalization-length bound, and
the $2^n$ fiber count, and computes the exact Landauer cost. Section 5 develops compositional
accounting: the identity, additivity for independent obligations, the data-processing
inequality, the refutation of the naive form of the conjecture, and the one-bit shared-lemma
example. Section 6 establishes the pipeline dichotomy. Section 7 discusses algorithms and
applications, Section 8 records limitations, and Section 9 lists open directions.

---

## 2. Setting and basic functionals

Throughout, $X$ and $Y$ are finite non-empty sets, thought of as a set of proof terms and a
set of normal proofs (or of verification outcomes), and $f : X \to Y$ is a function, thought
of as the normalization or verification map. All logarithms written $\log_2$ are to base $2$
and all entropies are measured in bits. A **law** on $X$ is a function $p : X \to \mathbb{R}$
with $p(x) \ge 0$ for all $x$; we do **not** assume $\sum_x p(x) = 1$ unless stated, since
several results are needed for unnormalized multiplicity counts.

**Definition 2.1 (Fiber).** For $b \in Y$, the *fiber* of $f$ over $b$ is
$f^{-1}(b) = \{x \in X : f(x) = b\}$.

**Definition 2.2 (Pushforward).** The *pushforward* of a law $p$ along $f$ is
$$(f_*p)(b) \;=\; \sum_{x \in f^{-1}(b)} p(x), \qquad b \in Y.$$
It is again a law, and it has the same total mass as $p$.

**Definition 2.3 (Entropy).** The *unnormalized Shannon entropy* of a law $q$ on a finite set
$S$ is $H(q) = -\sum_{s \in S} q(s)\log_2 q(s)$, with the convention $0\log_2 0 = 0$.

**Definition 2.4 (Conditional entropy destroyed by $f$).** The entropy destroyed by $f$ under
the law $p$ is
$$H_p(x \mid f x) \;=\; -\sum_{x \in X} p(x)\,\log_2 \frac{p(x)}{(f_*p)(f x)} .$$
When $p$ is a probability law this is the usual conditional entropy of $x$ given $f(x)$.

**Definition 2.5 (Expected fiber logarithm).** The *fiber-counting estimate* is
$$L_p(f) \;=\; \sum_{x \in X} p(x)\, \log_2 \big|f^{-1}(f x)\big| .$$

**Definition 2.6 (Landauer cost).** The heat associated with erasing $B$ bits at temperature
$T$ is $\mathrm{Land}(B) = B \cdot k_B T \ln 2$. Since $k_B T \ln 2 > 0$, every identity or
inequality between bit counts transfers verbatim to energies.

**Definition 2.7 (Uniform law).** $u_X(x) = 1/|X|$ for all $x$.

Two elementary facts are used repeatedly.

**Lemma 2.8 (Fiberwise regrouping).** For any $h : Y \to \mathbb{R}$,
$\sum_{x \in X} p(x)\,h(f x) = \sum_{b \in Y} (f_*p)(b)\, h(b)$. In particular
$$L_p(f) = \sum_{b \in Y} (f_*p)(b)\,\log_2 |f^{-1}(b)|, \qquad
H_p(x \mid f x) = \sum_{b\in Y} \Big(-\!\!\sum_{x \in f^{-1}(b)}\!\! p(x)\log_2 \tfrac{p(x)}{(f_*p)(b)}\Big).$$
*Proof sketch.* Partition $X$ into the fibers of $f$ and note that $h(f x)$ is constant on
each. $\square$

**Lemma 2.9 (Chain rule).** For every non-negative law $p$,
$$H_p(x \mid f x) \;=\; H(p) - H(f_*p).$$
*Proof sketch.* Expand $\log_2 (p(x)/(f_*p)(f x))$ as a difference of logarithms and apply
Lemma 2.8 to the second term. $\square$

The chain rule is the workhorse of Sections 5 and 6: it converts every statement about
conditional entropy into a statement about ordinary entropies of a law and its pushforward.

---

## 3. The Fiber-Entropy Law

### 3.1 A sharp Gibbs estimate for unnormalized weights

The classical maximum-entropy statement — that among probability laws on a set of size $N$
the uniform one has the greatest entropy, $\log_2 N$ — is not quite what is needed here,
because fibers carry unnormalized mass and may contain terms of weight zero. The following
sharpening supplies both the inequality and its exact equality case in that generality.

**Lemma 3.1 (Pointwise Gibbs estimate).** For $t \ge 0$ and $c > 0$,
$$t\big(\ln c - \ln t\big) \;\le\; c - t,$$
with equality if and only if $t = c$. (At $t = 0$ the left side is $0$ and the right side is
$c > 0$, so the inequality is strict there.)

*Proof sketch.* For $t > 0$, divide by $t$ and substitute $r = c/t$: the claim becomes
$\ln r \le r - 1$, the standard concavity estimate for the logarithm, whose equality case is
$r = 1$. The case $t = 0$ is immediate. $\square$

The strictness at $t = 0$ is not a technicality; it is the correct behaviour. A proof term of
weight zero inside a fiber of positive mass is already a violation of fiberwise uniformity,
and the law below must — and does — report it as one.

**Theorem 3.2 (Sharp maximum entropy for unnormalized weights).** Let $S$ be a finite set,
$q : S \to \mathbb{R}$ with $q \ge 0$ on $S$, and write $Q = \sum_{s \in S} q(s)$. Then
$$-\sum_{s \in S} q(s)\log_2\frac{q(s)}{Q} \;\le\; Q \cdot \log_2 |S|,$$
and equality holds **if and only if** $q(s) = Q/|S|$ for every $s \in S$. No normalization,
positivity, or non-emptiness hypothesis is required: $S = \emptyset$ and $q \equiv 0$ are
genuine degenerate instances in which both sides vanish and the criterion holds vacuously.

*Proof sketch.* If $Q = 0$ then $q \equiv 0$ on $S$ and both sides are zero. Otherwise set
$c = Q/|S| > 0$ and apply Lemma 3.1 termwise with $t = q(s)$:
$$\sum_{s} q(s)\big(\ln c - \ln q(s)\big) \;\le\; \sum_s \big(c - q(s)\big) = |S|\,c - Q = 0 .$$
Rewriting the left-hand side using $\ln c = \ln Q - \ln|S|$ and dividing by $\ln 2$ turns
this inequality into the claimed one. Because the termwise inequalities all point the same
way, the sums are equal exactly when every term is, which by the equality case of Lemma 3.1
means $q(s) = c$ for all $s$. $\square$

### 3.2 The law

**Theorem 3.3 (Fiber-Entropy Law).** Let $f : X \to Y$ be a normalization map on finite sets
and $p$ any non-negative law on $X$. Then
$$H_p(x \mid f x) \;\le\; L_p(f),$$
and
$$H_p(x \mid f x) = L_p(f) \iff \big(\forall x, y \in X\big)\ \big[f(x) = f(y) \Rightarrow p(x) = p(y)\big].$$
That is, the entropy destroyed by normalization equals the expected logarithm of the
normalization-fiber size precisely when the conditional law is uniform on every fiber.

*Proof sketch.* By Lemma 2.8, both sides decompose as sums over $b \in Y$ of the two sides of
Theorem 3.2 applied to $S = f^{-1}(b)$ and $q = p|_S$, noting $Q = (f_*p)(b)$. Summing the
fiberwise inequalities gives the bound. For the equality case, a sum of termwise-dominated
terms is equal to its dominating sum exactly when each term is equal to its dominator, so
equality holds iff for every $b$ the law $p$ is constant on $f^{-1}(b)$ — which is exactly
the stated criterion, since $x$ and $y$ lie in a common fiber iff $f(x) = f(y)$. $\square$

**Corollary 3.4 (Strict form).** If there exist $x, y$ with $f(x) = f(y)$ and
$p(x) \ne p(y)$, then $H_p(x \mid f x) < L_p(f)$ strictly.

**Corollary 3.5 (Landauer form).** For $k_B, T > 0$,
$$\mathrm{Land}\big(H_p(x\mid f x)\big) = \mathrm{Land}\big(L_p(f)\big)
\iff p \text{ is fiberwise constant},$$
and otherwise the left side is strictly smaller. The fiber-counting heuristic never
under-charges a single normalization step, and it over-charges strictly except on
fiberwise-uniform laws.

**Corollary 3.6 (The uniform law is always exact).** For $p = u_X$ the criterion of
Theorem 3.3 holds trivially, so $H_{u_X}(x \mid f x) = L_{u_X}(f)$ for every $f$. This is the
structural reason that uniform-law theories of normalization cost, in which the fiber count
and the entropy are used interchangeably, are internally consistent: under a uniform law they
are literally the same number.

### 3.3 A worked strict instance

Let $X = \{x_0, x_1, x_2\}$, $Y = \{y_0, y_1\}$ and $f(x_0) = f(x_1) = y_0$, $f(x_2) = y_1$,
with the biased law $p = (\tfrac12, \tfrac14, \tfrac14)$.

The fibers are $f^{-1}(y_0) = \{x_0, x_1\}$ of size $2$ and $f^{-1}(y_1) = \{x_2\}$ of size
$1$, so
$$L_p(f) = \tfrac12 \cdot 1 + \tfrac14 \cdot 1 + \tfrac14 \cdot 0 = \tfrac34 .$$
The pushforward is $(f_*p)(y_0) = \tfrac34$, $(f_*p)(y_1) = \tfrac14$, so
$$H_p(x \mid f x) = -\tfrac12\log_2\tfrac{2}{3} - \tfrac14 \log_2 \tfrac13 - \tfrac14 \log_2 1
= \tfrac34 \log_2 3 - \tfrac12 \approx 0.68872 .$$
The gap is exactly $\tfrac54 - \tfrac34\log_2 3 \approx 0.06128$ bits, strictly positive
because $p$ is not constant on the two-element fiber $\{x_0, x_1\}$ — precisely as
Corollary 3.4 predicts, and obtainable either by this computation or with no numerics at all
straight from the criterion.

---

## 4. A strongly normalizing calculus with exponential fibers and short conclusions

The Fiber-Entropy Law is vacuous unless fibers can be large relative to the syntactic data.
This section supplies a rewrite system in which they are exponentially large while every
other parameter stays linear.

### 4.1 The bureaucratic calculus

**Definition 4.1.** Fix $n \in \mathbb{N}$. A **derivation** of the calculus $\mathsf{Bur}_n$
is a pair
$$d = (u, c) \in \{0,1\}^n \times \{0,1\}^n,$$
where $c$ is the **conclusion**, an $n$-bit statement, and $u$ is the **bookkeeping vector**:
$u_i = 1$ records that the derivation carried out the $i$-th of $n$ independent inference
blocks in the *bureaucratic* (permuted) order rather than the canonical one.

**Definition 4.2 (Rewrite relation).** $\mathsf{Bur}_n$ has exactly $n$ rules. Rule $i$
applies to $d = (u,c)$ when $u_i = 1$ and yields $(u[i \mapsto 0], c)$. We write
$d \to e$ when some rule applies and produces $e$, and $\to^*$ for the reflexive-transitive
closure.

The rules change no conclusion: they are permutative conversions, the archetype of pure
proof bureaucracy. Two independent inference steps were performed in one order; the rule
rewrites them into the canonical order; the mathematical content is unchanged.

**Definition 4.3.** $d = (u,c)$ is **normal** if $u_i = 0$ for all $i$. The **normalization
map** is $\mathrm{nf}(u,c) = (\mathbf{0}, c)$. The **weight** of $d$ is
$w(d) = |\{i : u_i = 1\}|$, the number of blocks still in bureaucratic order.

Note $w(d) \le n$ always, and $w(d) = 0$ iff $d$ is normal.

### 4.2 Strong normalization

**Lemma 4.4 (Weight decrease).** If $d \to e$ then $w(e) = w(d) - 1$; in particular
$w(e) < w(d)$.

*Proof sketch.* If rule $i$ applies then $u_i = 1$, so $i$ belongs to the support
$\{j : u_j = 1\}$, and the support of the result is that set with $i$ removed. Removing a
member of a finite set decreases its cardinality by exactly one. $\square$

**Theorem 4.5 (Strong normalization).** The relation $\to$ is well-founded: there is no
infinite reduction sequence $d_0 \to d_1 \to \cdots$, from any derivation, under any
reduction strategy.

*Proof sketch.* By Lemma 4.4 the relation $\to$ is a sub-relation of the inverse image of
$<$ on $\mathbb{N}$ along $w$. The inverse image of a well-founded relation along any map is
well-founded, and a sub-relation of a well-founded relation is well-founded. $\square$

This is genuine strong normalization — well-foundedness of the reduction relation itself —
and not the weaker claim that *some* reduction sequence terminates.

### 4.3 Normal forms: characterized and unique

**Theorem 4.6 (Characterization of normal forms).** $d$ is irreducible (no rule applies) if
and only if $d$ is normal in the sense of Definition 4.3.

*Proof sketch.* If every $u_i = 0$ no rule applies, since rule $i$ requires $u_i = 1$.
Conversely, if some $u_i = 1$ then rule $i$ applies. $\square$

Thus canonicity is a theorem about the rewrite relation, not a stipulation. The same is true
of uniqueness, which we obtain in the strongest available form.

**Lemma 4.7 (Conclusions are invariant).** If $d \to^* e$ then $e$ and $d$ have the same
conclusion.

*Proof sketch.* Each single rule preserves the second component; induct along the
reflexive-transitive closure. $\square$

**Theorem 4.8 (Unique normal forms).** If $d \to^* e$ and $e$ is normal, then
$e = \mathrm{nf}(d)$. In particular $\mathsf{Bur}_n$ is confluent, and the result of
normalization is independent of the reduction strategy.

*Proof sketch.* Normality forces the bookkeeping component of $e$ to be $\mathbf{0}$, and
Lemma 4.7 forces its conclusion to be that of $d$; these two facts determine $e$ completely
as $(\mathbf{0}, c) = \mathrm{nf}(d)$. $\square$

### 4.4 Normalization is linear-time

Write $\mathrm{Reach}_k(d, e)$ for "$e$ is reachable from $d$ in at most $k$ steps".

**Theorem 4.9 (Bounded-length normalization).** For every $d$,
$\mathrm{Reach}_{w(d)}(d, \mathrm{nf}(d))$; consequently there is $k \le n$ with
$\mathrm{Reach}_k(d, \mathrm{nf}(d))$.

*Proof sketch.* Strong induction on $w(d)$. If $w(d) = 0$ then $d$ is normal and
$d = \mathrm{nf}(d)$. Otherwise pick $i$ with $u_i = 1$, apply rule $i$ to obtain $d'$ with
$w(d') = w(d) - 1$ by Lemma 4.4, note $\mathrm{nf}(d') = \mathrm{nf}(d)$, and invoke the
induction hypothesis for $d'$. The bound $w(d) \le n$ gives the final claim. $\square$

So the conclusion has $n$ bits, the normal proof has $n$ bits, and the normalization runs in
at most $n$ steps.

### 4.5 Exponential fibers

**Lemma 4.10 (Fiber description).** For every $d = (u,c)$,
$$\mathrm{nf}^{-1}\big(\mathrm{nf}(d)\big) \;=\; \{0,1\}^n \times \{c\}.$$
*Proof sketch.* $\mathrm{nf}(e) = \mathrm{nf}(d)$ says exactly that $e$'s conclusion is $c$;
the bookkeeping component of $e$ is unconstrained. $\square$

**Theorem 4.11 (Exponential fibers with short conclusions).** For every derivation $d$,
$$\big|\mathrm{nf}^{-1}(\mathrm{nf}(d))\big| \;=\; 2^n,$$
and each of these $2^n$ preimages reaches $\mathrm{nf}(d)$ in at most $n$ rewrite steps,
while the conclusion and its normal proof are only $n$ bits long.

*Proof sketch.* Immediate from Lemma 4.10 and $|\{0,1\}^n| = 2^n$; the reachability claim is
Theorem 4.9 applied to each member of the fiber, whose normal form is $\mathrm{nf}(d)$ by
definition of the fiber. $\square$

This is the phenomenon the construction was designed to isolate: **proof-term multiplicity is
not controlled by any syntactic size parameter.** Neither the length of the theorem, nor the
length of its canonical proof, nor the running time of the normalizer bounds the number of
derivations that collapse onto a normal form. All three are $n$; the multiplicity is $2^n$.

### 4.6 Exact thermodynamic cost

Since $\mathsf{Bur}_n$ has $2^n \cdot 2^n = 4^n$ derivations, the uniform law on derivations
is fiberwise uniform (trivially), so Theorem 3.3 applies in its equality case.

**Theorem 4.12 (Exact bit count).** Under the uniform law on derivations,
$$L_{u}(\mathrm{nf}) \;=\; H_{u}(d \mid \mathrm{nf}(d)) \;=\; n .$$

*Proof sketch.* Every fiber has size $2^n$, so every summand of $L_u$ contributes
$\tfrac{1}{4^n}\log_2 2^n = \tfrac{n}{4^n}$, and there are $4^n$ summands. The second
equality is Corollary 3.6. $\square$

The same count is obtained from a purely combinatorial functional. Writing
$\mathrm{erased}(f) = \log_2 |X| - \log_2 |f(X)|$ for the image-counting erasure of $f$, the
image of $\mathrm{nf}$ is the set of normal derivations, which is in bijection with the set
of conclusions and hence has $2^n$ elements, so
$$\mathrm{erased}(\mathrm{nf}) = \log_2 4^n - \log_2 2^n = n .$$

**Corollary 4.13 (Exact Landauer heat).** Normalizing $\mathsf{Bur}_n$ dissipates exactly
$$n \cdot k_B T \ln 2$$
of heat. This is an identity, not a bound, precisely because the uniform law is fiberwise
uniform.

**Theorem 4.14 (Packaged statement).** For every $n$, the calculus $\mathsf{Bur}_n$ is
finitely presented ($n$ rules), strongly normalizing, has $n$-bit conclusions, normalizes in
at most $n$ steps, has normalization fibers of cardinality exactly $2^n$, and destroys
exactly $n$ bits under the uniform law.

**Worked instance ($n = 3$).** $8$ conclusions; $64$ derivations; $8$ normal derivations;
every fiber of size $8$; $\log_2 8 = 3$ bits erased; at most $3$ rewrite steps from any
derivation. Every number is exact.

---

## 5. Compositional accounting: what sharing a lemma saves

### 5.1 Setup

Let two proof obligations be verified by $f : X_1 \to Y_1$ and $g : X_2 \to Y_2$, and let $p$
be a non-negative law on $X_1 \times X_2$ — the *joint* law of the two proofs, which need not
factor. Write $p_1(x) = \sum_y p(x,y)$ and $p_2(y) = \sum_x p(x,y)$ for the marginals, and
$$I(p) \;=\; H(p_1) + H(p_2) - H(p)$$
for the mutual information of the joint law. Let $f \times g$ denote the product map
$(x,y) \mapsto (f x, g y)$, and $P = (f\times g)_* p$ the pushed-forward joint law of the two
verification outcomes.

The **separate** cost of verification is $H_{p_1}(x \mid f x) + H_{p_2}(y \mid g y)$; the
**joint** cost is $H_p\big((x,y) \mid (f x, g y)\big)$.

### 5.2 Verification commutes with marginalization

**Lemma 5.1.** $\big((f\times g)_* p\big)_1 = f_*(p_1)$ and $\big((f\times g)_* p\big)_2 = g_*(p_2)$.

*Proof sketch.* The fiber of $f \times g$ over $(b_1, b_2)$ is the product
$f^{-1}(b_1) \times g^{-1}(b_2)$, so both sides expand to the same double sum; interchanging
the order of summation identifies them. $\square$

This combinatorial step is the only substantive ingredient in the identity below.

### 5.3 The accounting identity

**Theorem 5.2 (Compositional Landauer accounting).** For every non-negative joint law $p$,
$$\Big[H_{p_1}(x \mid f x) + H_{p_2}(y \mid g y)\Big] - H_p\big((x,y)\mid(fx,gy)\big)
\;=\; I(p) - I\big((f\times g)_* p\big).$$
In words: the saving realized by verifying two obligations jointly rather than separately is
exactly the amount of mutual information that verification destroys.

*Proof sketch.* Apply the chain rule (Lemma 2.9) three times, to $f$ under $p_1$, to $g$
under $p_2$, and to $f \times g$ under $p$. The left-hand side becomes
$$\big[H(p_1) - H(f_*p_1)\big] + \big[H(p_2) - H(g_*p_2)\big] - \big[H(p) - H(P)\big],$$
and regrouping gives $\big[H(p_1)+H(p_2)-H(p)\big] - \big[H(f_*p_1)+H(g_*p_2)-H(P)\big]$.
By Lemma 5.1 the second bracket is exactly $I(P)$ and the first is $I(p)$. $\square$

No normalization and no support hypothesis is used: $p \ge 0$ suffices.

### 5.4 The naive conjecture is false; the corrected one is sharp

The form of the conjecture one starts from — "shared lemmas reduce total work by exactly the
mutual information between the obligations' proof distributions" — asserts
$\text{saving} = I(p)$. Theorem 5.2 shows this is correct **iff** $I(P) = 0$, i.e. iff the
verifiers destroy all correlation between the two obligations. That is a real condition, not
an automatic one: any verifier pair whose outputs remain correlated leaves a residual $I(P)$
that must be subtracted. The invariant is the *drop* in mutual information, not the mutual
information.

**Theorem 5.3 (Additivity for independent obligations).** If $p = p_1 \otimes p_2$ is a
product of probability laws, then
$$H_p\big((x,y)\mid(fx,gy)\big) = H_{p_1}(x \mid f x) + H_{p_2}(y \mid g y).$$

*Proof sketch.* For a product law the marginals are $p_1$ and $p_2$ and $I(p) = 0$; the
pushforward of a product law is the product of the pushforwards, whose mutual information is
likewise $0$. Theorem 5.2 then forces the saving to vanish. $\square$

**Theorem 5.4 (Data-processing inequality for mutual information).** For a strictly positive
joint law $p$,
$$I\big((f\times g)_*p\big) \;\le\; I(p) .$$
Deterministic verification cannot manufacture statistical dependence between obligations.

*Proof sketch.* Write $m(x,y) = p_1(x)p_2(y)$ for the product reference law, so that
$I(p) = D(p \Vert m)$ is a relative entropy (an identity that holds with no normalization
hypothesis, zero weights included). Relative entropy is monotone under pushforward along any
deterministic map — the *log-sum inequality*
$$\Big(\sum_i a_i\Big)\log_2\frac{\sum_i a_i}{\sum_i b_i} \;\le\; \sum_i a_i \log_2 \frac{a_i}{b_i}
\qquad (a_i \ge 0,\ b_i > 0),$$
itself a consequence of the pointwise Gibbs estimate of Lemma 3.1, applied fiberwise and
summed. Finally $(f\times g)_* m$ is the product of the pushed marginals by Lemma 5.1, so the
pushed relative entropy is exactly $I((f\times g)_*p)$. $\square$

**Corollary 5.5 (Sharing never costs).** For a strictly positive joint law,
$$H_p\big((x,y)\mid(fx,gy)\big) \;\le\; H_{p_1}(x \mid f x) + H_{p_2}(y \mid g y).$$
Joint verification is never more expensive than separate verification, and the saving is
exactly the mutual-information drop.

The positivity hypothesis in Theorem 5.4 and Corollary 5.5 is genuinely needed and is stated
explicitly: a joint law assigning weight zero to some pair makes the product reference law
degenerate. The identity of Theorem 5.2 itself has no such restriction.

### 5.5 The shared-lemma ledger

Let $X_1 = X_2 = \{0,1\}$ and let the joint law be supported on the diagonal,
$p(0,0) = p(1,1) = \tfrac12$, $p(0,1) = p(1,0) = 0$: "the same lemma twice", each obligation
determining the other. Let both verifiers be the total collapse to a one-element set (a
verifier that returns only "verified").

Then $p_1 = p_2 = (\tfrac12,\tfrac12)$, so $H(p_1) = H(p_2) = 1$ and $H(p) = 1$, giving
$I(p) = 1 + 1 - 1 = 1$ bit. The pushforward $P$ lives on a one-point set, so $I(P) = 0$.
Separately the two verifications destroy $1 + 1 = 2$ bits; jointly they destroy $1$ bit; the
saving is $2 - 1 = 1 = I(p) - I(P)$. The prediction is realized exactly, and this is the
regime — outputs fully decorrelated — in which the naive form of the conjecture happens to be
right.

---

## 6. Pipelines: entropy composes, multiplicity does not

Normalization is rarely a single step. Let $f : X \to Y$ and $g : Y \to Z$, so that
$g \circ f$ is a two-stage pipeline.

**Lemma 6.1 (Pushforwards compose).** $(g\circ f)_* p = g_*(f_* p)$.

*Proof sketch.* The fiber of $g \circ f$ over $c$ is the disjoint union over
$b \in g^{-1}(c)$ of the fibers $f^{-1}(b)$; summing $p$ over the union and regrouping gives
the claim. $\square$

**Theorem 6.2 (Pipeline chain rule).** For every non-negative law $p$,
$$H_p\big(x \mid g(f(x))\big) \;=\; H_p\big(x \mid f(x)\big) + H_{f_*p}\big(y \mid g(y)\big).$$
There is no correction term, at any law.

*Proof sketch.* Apply Lemma 2.9 to $g\circ f$ under $p$, to $f$ under $p$, and to $g$ under
$f_*p$; the three right-hand sides telescope, using Lemma 6.1 to identify
$(g\circ f)_*p = g_*(f_*p)$. $\square$

The fiber-counting estimate behaves far worse.

**Theorem 6.3 (Subadditivity under a uniform law).** For $p = u_X$,
$$L_{u_X}(g\circ f) \;\le\; L_{u_X}(f) + L_{f_*u_X}(g).$$

*Proof sketch.* Under the uniform law both $f$ and $g\circ f$ satisfy the equality case of
Theorem 3.3, so their fiber counts *are* their conditional entropies; the second stage is
only bounded, $H_{f_*u}(y\mid gy) \le L_{f_*u}(g)$. Combining with the chain rule
(Theorem 6.2) gives the inequality. $\square$

**Theorem 6.4 (Exact equality criterion).** Equality holds in Theorem 6.3 **iff** all
$f$-fibers lying over a common $g$-fiber have the same cardinality:
$$L_{u_X}(g \circ f) = L_{u_X}(f) + L_{f_*u_X}(g)
\iff \forall b, b' \in Y:\ g(b) = g(b') \Rightarrow |f^{-1}(b)| = |f^{-1}(b')| .$$

*Proof sketch.* By the argument of Theorem 6.3, equality holds iff the second stage attains
its bound, i.e. iff $f_* u_X$ is constant on each $g$-fiber by Theorem 3.3. But
$(f_*u_X)(b) = |f^{-1}(b)|/|X|$, so constancy of the pushed law on a $g$-fiber is exactly
equality of the corresponding $f$-fiber sizes. $\square$

**Theorem 6.5 (Failure of subadditivity for skewed laws).** There is a pipeline of finite
sets and a *fully supported* law for which
$$L_p(f) + L_{f_*p}(g) \;<\; L_p(g\circ f),$$
so the two-stage fiber count strictly under-reports the honest one-stage count.

*Proof sketch (explicit counterexample).* Take $X = \{x_0,x_1,x_2\}$, $Y = \{y_0,y_1\}$,
$Z$ a single point, with $f(x_0) = y_0$, $f(x_1) = f(x_2) = y_1$, $g$ the total collapse, and
the skewed law $p = (\tfrac45, \tfrac1{10}, \tfrac1{10})$. Then $|f^{-1}(y_0)| = 1$ and
$|f^{-1}(y_1)| = 2$, so
$$L_p(f) = \tfrac45 \cdot 0 + \tfrac1{10}\cdot 1 + \tfrac1{10}\cdot 1 = \tfrac15 .$$
The pushforward is $f_*p = (\tfrac45, \tfrac15)$ on $Y$, and $g$ has the single fiber $Y$ of
size $2$, so $L_{f_*p}(g) = 1$. The two-stage total is $\tfrac65 = 1.2$. But $g \circ f$ has
the single fiber $X$ of size $3$, so
$$L_p(g\circ f) = \log_2 3 \approx 1.58496 > 1.2 . \qquad \square$$

**Theorem 6.6 (Pipeline dichotomy).** On this very pipeline and this very law, the entropy
accounting is exactly additive (Theorem 6.2) while the fiber-counting accounting is not even
subadditive (Theorem 6.5).

**Why it fails.** The composite fiber size is the *sum* $\sum_{b \in g^{-1}(c)} |f^{-1}(b)|$,
an $\ell^1$ quantity, while the two-stage estimate is a weighted *geometric* mean of the same
fiber sizes plus $\log_2$ of the $g$-fiber size. Under a uniform law the weights are exactly
proportional to the fiber sizes and the two effects cancel; under a law concentrating on a
small fiber that sits next to a large one they do not. Numerically, with $f$-fiber sizes
$(1,2)$ over a $g$-fiber of size $m = 2$ and pushed weights $(\tfrac45,\tfrac15)$, the
required inequality reads $\log_2 3 \le \tfrac15 + 1$, i.e. $1.58496 \le 1.2$, false by
$0.385$ bits. The failure is structural, not an artefact of degenerate weights: the law is
strictly positive on all three terms.

---

## 7. Algorithms and applications

### 7.1 Computing the accounting

All the functionals above are computable in time linear in $|X|$ once the fibers of $f$ are
known.

**Fiber census.** One pass over $X$ evaluating $f$ and accumulating counts and masses in a
dictionary keyed by $Y$ produces both $|f^{-1}(b)|$ and $(f_*p)(b)$ for all $b$ in
$O(|X|)$ time and $O(|Y|)$ space.

**Cost report.** Given the census, $L_p(f)$ and $H_p(x \mid f x)$ each require one further
pass, and the fiberwise-uniformity test — "is $p$ constant on every fiber?" — is a third
pass. The Fiber-Entropy Law then predicts, before the numbers are compared, whether the gap
will be zero or strictly positive, giving a cheap consistency check on any implementation.

**Defect profile.** Reporting the per-fiber defects $\log_2|f^{-1}(b)| - H(q_b)$, where $q_b$
is the conditional law inside the fiber $b$, localizes the over-charge to the individual
fibers responsible for it. By Theorem 3.3 the total defect vanishes exactly when every
per-fiber defect does.

### 7.2 What the results say to a designer of proof pipelines

- **Do not size your energy budget by counting derivations.** For a single step, the count is
  an upper bound and is tight only when all derivations of a theorem are equally likely — a
  strong and rarely realistic assumption. Under a realistic skewed law (most theorems are
  proved in one canonical way, with rare exotic variants) the count over-charges, sometimes
  substantially.
- **Do not compose fiber counts.** Theorem 6.5 shows the composite estimate can be strictly
  larger than the sum of stagewise estimates, so stagewise counting is not even conservative.
  Compose entropies instead: Theorem 6.2 is exact and unconditional.
- **Share lemmas, and measure the sharing correctly.** Corollary 5.5 guarantees sharing never
  hurts; Theorem 5.2 says the benefit is the correlation destroyed, which is strictly less
  than the correlation present whenever the verification outputs remain correlated.
- **Expect multiplicity blowup even for small theorems.** Section 4 shows $n$-bit theorems
  with $n$-bit canonical proofs, normalizing in $n$ steps, that nevertheless have $2^n$
  derivations. Any data structure that enumerates derivations of a normal form must be
  prepared for exponential blowup that no syntactic size parameter predicts.

### 7.3 Reading the numbers physically

At room temperature, $k_B T \ln 2 \approx 2.87 \times 10^{-21}\,\mathrm{J}$ per bit. The
bureaucratic calculus at $n = 40$ therefore has fibers of about $10^{12}$ derivations and a
normalization cost of about $1.15\times 10^{-19}\,\mathrm{J}$ per proof — negligible in
absolute terms, which is exactly why the interest here is in the *identities* rather than in
the joules. Landauer accounting is being used as an invariant that constrains proof
transformations, not as an engineering constraint.

---

## 8. Discussion and limitations

**Finiteness.** Everything is stated for finite sets of proof terms. This is the natural
setting for exact fiber cardinalities and for a well-defined Shannon entropy, and it is not a
serious restriction for the applications, where one works at a bounded derivation depth. An
asymptotic theory over unbounded proof size would require care with the choice of
universal coding and is not attempted here.

**Presentation of the calculus.** The system $\mathsf{Bur}_n$ is finitely presented *for each
$n$*, with $n$ rules — which is what the target statement asks for. It is a family, not a
single infinite calculus, and no claim is made that it is one. Its rules are permutative
conversions on independent blocks, so it is a genuine, if deliberately minimal, model of
proof bureaucracy rather than a representation of full cut elimination.

**Strength of the normalization claim.** Theorem 4.5 asserts well-foundedness of the rewrite
relation, hence termination of *every* strategy, not merely the existence of a terminating
strategy. Theorems 4.6 and 4.8 likewise characterize and identify normal forms rather than
postulating them.

**Hypotheses of the compositional results.** The accounting identity of Theorem 5.2 needs
only $p \ge 0$. The non-negativity of the saving (Theorem 5.4, Corollary 5.5) genuinely needs
strict positivity, since a law that already assigns zero weight to some pair makes the
product reference law degenerate; the boundary is therefore stated explicitly rather than
elided.

**Scope of the counterexample.** Theorem 6.5 uses a fully supported law on three terms, so
the failure of subadditivity is not an artefact of point masses. The uniform-law equality
criterion in Theorem 6.4 is an *iff*, so the boundary between the good and bad regimes is
exact.

---

## 9. Future directions

**A. The fiber-entropy defect as a Bregman divergence.** The defect
$D(f,p) = L_p(f) - H_p(x\mid fx)$ should equal $\sum_b P(b)\, D_{\mathrm{KL}}(q_b \Vert
\mathrm{unif}_{f^{-1}(b)})$, where $P = f_*p$ and $q_b$ is the conditional law inside the
fiber. This would upgrade Theorem 3.3 from "the gap is positive off the uniform locus" to
"the gap is a *distance* to that locus", with joint convexity in $p$ and a Pinsker-type
stability bound
$$D(f,p) \;\ge\; \frac{1}{2\ln 2}\sum_b P(b)\,\big\|q_b - \mathrm{unif}_{f^{-1}(b)}\big\|_1^2 .$$
Thermodynamic sub-optimality of fiber counting would then be measurable, not merely
detectable.

**B. Bennett tradeoffs for verification.** Reversible verification that retains a transcript
avoids erasure but forces a pebbling tradeoff between retained checkpoints and recomputation.
The conjecture is a family of finite proof systems for which reversible verification in
subexponential auxiliary space necessarily incurs superlinear recomputation time, while
irreversible linear-time verification destroys linearly many transcript bits.

**C. Incompressible proof families.** For infinitely many lengths $n$, some valid proof object
of length $n$ should have prefix-free description complexity at least $n - O(1)$; and every
universal verifier reconstructing such a proof from a shorter certificate must acquire the
missing information either through its input transcript or through irreversible state
changes. Strict finite compression is already excluded at each fixed depth; what is wanted is
a machine-invariant asymptotic form with explicit additive constants.

**D. Beyond permutative conversions.** $\mathsf{Bur}_n$ realizes exponential multiplicity by
independent commuting blocks. A natural next target is a calculus in which the exponential
fiber arises from genuine cut elimination, where normalization can *grow* proofs, so that the
normalization time is no longer linear and the interplay between reduction length and fiber
size becomes non-trivial.

**E. Multi-stage pipelines and the geometry of the failure.** The obstruction in Theorem 6.5
is a mismatch between an $\ell^1$ aggregate and a weighted geometric mean. Quantifying the
worst-case ratio over $k$-stage pipelines, and identifying the laws that maximize it, would
give a sharp measure of how badly multiplicity accounting can mislead.

---

## 10. Conclusion

Normalization is forgetting, and forgetting has a price. This paper fixes that price exactly.
The Fiber-Entropy Law says that the naive practice of counting normalization preimages is
thermodynamically exact precisely on fiberwise-uniform laws and strictly over-charges
otherwise. The bureaucratic calculus shows that the regime where this matters is not exotic:
$n$-bit theorems with $n$-bit canonical proofs and $n$-step normalization can carry $2^n$
derivations, at an exact cost of $n$ bits, or $n\,k_B T\ln 2$ of heat. Compositional
accounting shows that sharing a lemma saves exactly the mutual information that verification
destroys — never negative, but generally less than the correlation present, refuting the
naive form of the conjecture. And the pipeline dichotomy shows that of the two candidate
accountings, only the entropic one survives composition: entropy composes, multiplicity does
not.
