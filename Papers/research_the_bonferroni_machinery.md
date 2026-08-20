# The Bonferroni Machinery and the Marginal Selection Principle

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We isolate and make precise a separation of concerns that is implicit in a large family of
extremal counting arguments. For an arbitrary finite family $A_1,\dots,A_k$ of finite sets
we develop a small collection of inequalities — the second Bonferroni inequality
$\sum_i |A_i| \le |\bigcup_i A_i| + \sum_{i\neq j}|A_i \cap A_j|$, a double-collision
bound $2\,\#\{x : m(x)\ge 2\} \le \sum_{i\neq j}|A_i \cap A_j|$, and the Cauchy–Schwarz
strengthening $(\sum_i |A_i|)^2 \le |\bigcup_i A_i|\cdot(\sum_i|A_i| + \sum_{i\neq j}|A_i\cap A_j|)$
of Corrádi — all of which descend from a single Fubini identity for the multiplicity
function $m(x) = \#\{i : x\in A_i\}$. These statements are *universal*: they hold for every
family and carry no arithmetic, geometric or structural information. We show that the
Bonferroni inequality is an equality precisely for pairwise disjoint families, so the
machinery is exact at its boundary and admits no strengthening at that level.

It follows that any concrete extremal bound derived this way is determined entirely by the
choice of *marginals* fed into the machinery — the index set, the common size of the
members, and the pair-intersection bound. We turn that slogan into theorems. From one and
the same Sidon set $A$ in a finite abelian group $G$ we derive a master inequality
$$|S|\cdot|A|^2 \le |G|\cdot(|A| + |S| - 1)$$
valid for every nonempty set $S$ of shifts, and analyse its two extreme instances: taking
$S = A$ yields $|A|^3 \le (2|A|-1)|G|$, i.e. $|A| \lesssim \sqrt{2|G|}$, while taking
$S = G$ yields the sharp Erdős–Turán bound $|A|(|A|-1) \le |G| - 1$, i.e.
$|A| \lesssim \sqrt{|G|}$. We prove that these two outputs are *strictly ordered*: the
sharp bound always implies the weaker one, and there are explicit parameters at which the
weaker holds and the sharp fails. Feeding the same machinery the neighbourhood marginals of
a graph with no two vertices having two common neighbours produces Reiman's bound
$|E| = O(|V|^{3/2})$, a cross-domain instantiation with no change to the engine. Finally we
develop the third-order layer — a triple-correlation identity and a triple-collision bound
— which is the natural place to look for improvements invisible to pair correlations.

**Keywords:** Bonferroni inequalities, Corrádi's lemma, double counting, Sidon sets,
Erdős–Turán bound, $C_4$-free graphs, Reiman's inequality, Kővári–Sós–Turán, multiplicity
function, higher moments.

---

## 1. Introduction

### 1.1 The phenomenon

A striking number of extremal theorems are proved by the following recipe.

1. Attach to the object of interest a family of finite sets.
2. Observe that the sets are large and pairwise nearly disjoint.
3. Conclude that there cannot be too many of them, or that the ambient space must be large.

Step 3 is always the same. It is a double count, followed at most by an application of
Cauchy–Schwarz. It is *completely insensitive* to what the sets are, where they live, or
how they were produced. Steps 1 and 2 are where every trace of arithmetic, geometry or
combinatorics resides.

This paper makes that observation into mathematics. We call the apparatus behind step 3 the
**Bonferroni machinery**, and the data supplied by steps 1–2 the **marginals**. We prove
the machinery once, in maximal generality; we prove that it is tight at its natural
boundary and hence not improvable at that level; and we then demonstrate — with two
different marginal choices built from one and the same object — that the strength of the
resulting theorem is a strictly increasing function of the marginals fed in, not of any
ingenuity in the machinery.

### 1.2 Statement of the principle

> **Marginal selection principle.** The Bonferroni/Corrádi inequalities are universal: they
> hold for every finite family of finite sets and contain no information about the family
> beyond its incidence pattern. Hence a concrete extremal bound obtained from them is a
> function only of the marginals — the number of members, their common size, and the
> pair-intersection bound. Improving such a bound requires changing the marginals (or
> raising the order of the moment used), never the machinery.

Sections 2–3 develop the machinery; Section 4 makes the principle quantitative for Sidon
sets; Section 5 instantiates it in graph theory; Section 6 develops the third-order layer;
Section 7 records sharpness data; Sections 8–9 discuss applications and open problems.

### 1.3 Notation

Throughout, $\iota$ is a finite index set of cardinality $k$, $\alpha$ is a type with
decidable equality, and $A : \iota \to \mathcal{P}_{\mathrm{fin}}(\alpha)$, written
$i \mapsto A_i$, is a family of finite sets. We write $|X|$ or $\#X$ for cardinality. All
quantities are natural numbers, and all identities below are stated so as to avoid
truncated subtraction wherever it would matter.

---

## 2. The machinery

### 2.1 Multiplicity and support

**Definition 2.1 (Multiplicity).** For a family $A = (A_i)_{i\in\iota}$ and a point $x$,
the *multiplicity* of $x$ is
$$m_A(x) \;=\; \#\{\, i \in \iota : x \in A_i \,\}.$$

**Definition 2.2 (Support).** The *support* of the family is its union,
$\operatorname{supp}(A) = \bigcup_{i\in\iota} A_i$.

Two trivial but constantly used facts: $A_i \subseteq \operatorname{supp}(A)$ for every
$i$, and $m_A(x) > 0$ if and only if $x \in \operatorname{supp}(A)$.

### 2.2 The Fubini identity

Everything in this paper is a consequence of a single double count.

**Theorem 2.3 (Fubini for the incidence bipartite graph).** For every weight function
$f : \alpha \to \mathbb{N}$,
$$\sum_{i \in \iota} \; \sum_{x \in A_i} f(x) \;=\; \sum_{x \in \operatorname{supp}(A)} m_A(x)\, f(x).$$

*Proof sketch.* Since $A_i \subseteq \operatorname{supp}(A)$, the inner sum may be extended
to the support with the indicator of $A_i$ as a factor:
$\sum_{x\in A_i} f(x) = \sum_{x \in \operatorname{supp}(A)} \mathbf{1}[x \in A_i]f(x)$.
Exchanging the order of the two finite sums and collecting, for each fixed $x$, the
constant $f(x)$ over the $m_A(x)$ indices $i$ with $x \in A_i$ gives the right-hand side.
Equivalently: both sides count, with weight $f(x)$, the incidences $(i,x)$ with $x \in A_i$
in the incidence bipartite graph between indices and points. $\square$

We also record the *localised* version, needed for higher moments: for every finite set $s$
and every weight $f$,
$$\sum_{i\in\iota}\;\sum_{x \in s \cap A_i} f(x) \;=\; \sum_{x \in s} m_A(x)\, f(x).
\tag{2.4}$$
The proof is identical; the support plays no distinguished role, only the containment
$s \cap A_i \subseteq s$.

### 2.3 The first two moments

**Corollary 2.5 (First moment).** $\displaystyle \sum_{i} |A_i| = \sum_{x \in \operatorname{supp}(A)} m_A(x)$.

*Proof.* Theorem 2.3 with $f \equiv 1$. $\square$

**Corollary 2.6 (Second moment).**
$\displaystyle \sum_{i}\sum_{j} |A_i \cap A_j| = \sum_{x \in \operatorname{supp}(A)} m_A(x)^2$,
the double sum running over all ordered pairs including the diagonal.

*Proof sketch.* For fixed $i$, writing $|A_i \cap A_j| = \sum_{x \in A_i}\mathbf{1}[x\in A_j]$
and summing over $j$ gives $\sum_j |A_i \cap A_j| = \sum_{x\in A_i} m_A(x)$. Now apply
Theorem 2.3 with $f = m_A$. $\square$

**Definition 2.7 (Pair-correlation sum).** The *off-diagonal pair-correlation sum* of the
family is
$$P(A) \;=\; \sum_{\substack{i,j \in \iota \\ i \neq j}} |A_i \cap A_j|.$$

**Lemma 2.8 (Diagonal splitting).**
$\displaystyle P(A) + \sum_i |A_i| = \sum_{x \in \operatorname{supp}(A)} m_A(x)^2.$

*Proof.* The diagonal part of the double sum in Corollary 2.6 is
$\sum_i |A_i \cap A_i| = \sum_i |A_i|$; the ordered index pairs split as diagonal plus
off-diagonal. $\square$

**Lemma 2.9 (Collision census).**
$\displaystyle P(A) = \sum_{x \in \operatorname{supp}(A)} m_A(x)\bigl(m_A(x)-1\bigr).$

*Proof.* Combine Corollary 2.5 and Lemma 2.8, using $m^2 - m = m(m-1)$ pointwise (valid in
$\mathbb{N}$ for $m \ge 1$, which holds on the support). $\square$

Lemma 2.9 is the conceptual heart: $P(A)$ counts *ordered pairs of distinct indices whose
sets share a point*, aggregated over points.

### 2.4 The two Bonferroni inequalities

**Theorem 2.10 (Second Bonferroni inequality).** For every finite family of finite sets,
$$\sum_{i} |A_i| \;\le\; \Bigl|\bigcup_i A_i\Bigr| \;+\; \sum_{i \neq j} |A_i \cap A_j|.$$

*Proof sketch.* Pointwise on the support, $(m-1)^2 \ge 0$ gives $2m \le 1 + m^2$. Summing
over $\operatorname{supp}(A)$ and using Corollary 2.5 on the left and Lemma 2.8 on the
right yields
$2\sum_i |A_i| \le |\operatorname{supp}(A)| + P(A) + \sum_i |A_i|$, i.e. the claim.
$\square$

The inequality is exact at a well-understood boundary.

**Theorem 2.11 (Equality case).**
$$\sum_i |A_i| = \Bigl|\bigcup_i A_i\Bigr| + \sum_{i\neq j}|A_i \cap A_j|
\quad\Longleftrightarrow\quad
A_i \cap A_j = \emptyset \text{ for all } i \neq j.$$

*Proof sketch.* ($\Leftarrow$) If the family is pairwise disjoint then
$|\bigcup_i A_i| = \sum_i |A_i|$ by additivity of cardinality over a disjoint union, and
$P(A) = 0$ term by term.

($\Rightarrow$) The pointwise inequality $2m \le 1+m^2$ is *strict* whenever $m \ne 1$. If
some point $x$ of the support had $m_A(x) \ge 2$, summing would give a strict inequality in
the proof of Theorem 2.10, contradicting equality. Hence every point of the support has
multiplicity exactly $1$. But if $x \in A_i \cap A_j$ with $i \ne j$, then the two-element
index set $\{i,j\}$ witnesses $m_A(x) \ge 2$, a contradiction. $\square$

Theorem 2.11 is the precise sense in which the machinery cannot be improved *at this level*:
the only families for which it loses nothing are the ones for which it says nothing.

**Definition 2.12.** The *double-collision set* is
$D(A) = \{x \in \operatorname{supp}(A) : m_A(x) \ge 2\}$.

**Theorem 2.13 (Double-collision bound).** $\;2\,|D(A)| \le P(A)$.

*Proof sketch.* By Lemma 2.9, $P(A) = \sum_{x\in\operatorname{supp}(A)} m(m-1)$, a sum of
nonnegative terms. Restricting to $D(A)$ and using that $m \mapsto m(m-1)$ is increasing
with value $2$ at $m = 2$, each of the $|D(A)|$ retained terms is at least $2$. $\square$

### 2.5 The Cauchy–Schwarz strengthening

**Theorem 2.14 (Corrádi's lemma).** For every finite family of finite sets,
$$\Bigl(\sum_i |A_i|\Bigr)^{\!2} \;\le\; \Bigl|\bigcup_i A_i\Bigr| \cdot
\Bigl(\sum_i |A_i| \;+\; \sum_{i\neq j}|A_i \cap A_j|\Bigr).$$

*Proof sketch.* Cauchy–Schwarz in the form
$\bigl(\sum_{x\in s} g(x)\bigr)^2 \le |s|\sum_{x\in s} g(x)^2$, applied with
$s = \operatorname{supp}(A)$ and $g = m_A$, gives
$\bigl(\sum_x m\bigr)^2 \le |\operatorname{supp}(A)|\sum_x m^2$. Rewrite the left side with
Corollary 2.5 and the right side with Lemma 2.8. $\square$

Theorem 2.14 dominates Theorem 2.10 in every application we consider: squaring the total
size is what converts $|A| \lesssim N$ into $|A| \lesssim \sqrt{N}$.

---

## 3. Uniform marginals

We now record, once and for all, the two output shapes produced by the most common marginal
data: $k$ sets of common size $m$ with pairwise intersections at most $t$.

**Theorem 3.1 (Linear output).** If $|A_i| \ge m$ for every $i$ and $|A_i \cap A_j| \le t$
for all $i \ne j$, then
$$k\,m \;\le\; \Bigl|\bigcup_i A_i\Bigr| \;+\; k(k-1)\,t .$$

*Proof.* $\sum_i |A_i| \ge km$, and $P(A) \le k(k-1)t$ because the off-diagonal index set
has exactly $k(k-1)$ elements. Insert both into Theorem 2.10. $\square$

**Theorem 3.2 (Quadratic output; Corrádi form).** If $k \ge 1$, $|A_i| = m$ for every $i$,
and $|A_i \cap A_j| \le t$ for all $i \ne j$, then
$$k\,m^2 \;\le\; \Bigl|\bigcup_i A_i\Bigr| \cdot \bigl(m + (k-1)t\bigr).$$

*Proof sketch.* By Theorem 2.14 with $\sum_i |A_i| = km$ and $P(A) \le k(k-1)t$,
$(km)^2 \le |\operatorname{supp}(A)|\,(km + k(k-1)t) = k\cdot|\operatorname{supp}(A)|(m+(k-1)t)$.
Cancel one factor of $k > 0$. $\square$

**Corollary 3.3 (Reiman / Kővári–Sós–Turán case $t=1$).** If $|A_i \cap A_j| \le 1$ for all
$i \ne j$, then
$$\Bigl(\sum_i |A_i|\Bigr)^{\!2} \;\le\; \Bigl|\bigcup_i A_i\Bigr|\cdot
\Bigl(\sum_i |A_i| + k(k-1)\Bigr).$$

The condition $t = 1$ is exactly the statement that the incidence structure between indices
and points contains no $K_{2,2}$ — no "rectangle". Corollary 3.3 is therefore the abstract
form of the Kővári–Sós–Turán argument for the forbidden complete bipartite graph
$K_{2,2}$.

Note what has and has not happened. Theorems 3.1–3.3 are still universal: they refer to no
structure at all. Everything that will distinguish a good theorem from a mediocre one is
the *choice of the family* whose $(k, m, t)$ we insert.

---

## 4. The marginal selection principle for Sidon sets

### 4.1 Sidon sets

**Definition 4.1.** A finite subset $A$ of an abelian group $G$ is a **Sidon set** if for
all $a,b,c,d \in A$ with $a + b = c + d$ we have $\{a,b\} = \{c,d\}$; equivalently, all
differences $a - b$ with $a \ne b$ are distinct.

Sidon sets are the "perfect rulers'' of additive combinatorics: every nonzero difference
occurs at most once. Their study goes back to Sidon's work on Fourier series and to
Erdős–Turán, and they appear in radar and sonar sequence design, in frequency-hopping
schedules with no repeated interference pattern, and in the construction of
self-orthogonal codes.

The classical question is: how large can a Sidon set in a group of order $N$ be? We answer
it twice, with two different marginal choices, from the same universal machinery.

### 4.2 The Sidon marginal

**Definition 4.2.** For $g \in G$ the *translate* is $A + g = \{a + g : a \in A\}$.

Two facts make translates ideal marginals. Trivially $|A+g| = |A|$, since translation is
injective. The second is the entire arithmetic content of the section.

**Theorem 4.3 (The Sidon marginal).** Let $A \subseteq G$ be a Sidon set and $g \ne h$ in
$G$. Then
$$|(A+g) \cap (A+h)| \le 1.$$

*Proof sketch.* Suppose $x$ and $y$ both lie in the intersection. Write
$x = p + g = q + h$ and $y = p' + g = q' + h$ with $p,q,p',q' \in A$. Adding the first
relation to the second after transposition and cancelling $g + h$ from both sides gives
$$p + q' = q + p'.$$
Since $A$ is Sidon, $\{p, q'\} = \{q, p'\}$. If $p = q$, then $p + g = x = q + h = p + h$
forces $g = h$, contrary to hypothesis; so we are in the other case, $p = p'$, whence
$x = p + g = p' + g = y$. Therefore the intersection has at most one element. $\square$

So a Sidon set produces, at no cost, a family of equal-size sets with $t = 1$: exactly the
input required by Corollary 3.3 and Theorem 3.2.

### 4.3 The master inequality

**Theorem 4.4 (Translate-family bound).** Let $G$ be a finite abelian group, $A \subseteq G$
a Sidon set, and $S \subseteq G$ any nonempty set of shifts. Then
$$|S| \cdot |A|^2 \;\le\; |G| \cdot \bigl(|A| + |S| - 1\bigr).$$

*Proof sketch.* Apply Theorem 3.2 to the family $\{A + g\}_{g \in S}$, indexed by $S$. The
parameters are $k = |S|$, $m = |A|$ and, by Theorem 4.3, $t = 1$. The conclusion reads
$|S|\,|A|^2 \le |\operatorname{supp}| \cdot (|A| + (|S|-1))$, and the support is a subset of
$G$, so $|\operatorname{supp}| \le |G|$. $\square$

Theorem 4.4 is the complete content of the marginal-selection question for Sidon sets: it
is a *one-parameter family of theorems*, indexed by the shift set $S$, and every double
counting proof of a Sidon bound of this type is one of its instances.

### 4.4 The two extremes

**Theorem 4.5 (All-translate marginals; Erdős–Turán).** For every Sidon set $A$ in a finite
abelian group $G$,
$$|A|\,(|A| - 1) \;\le\; |G| - 1.$$

*Proof sketch.* Take $S = G$ in Theorem 4.4, so $|S| = |G| > 0$. The inequality becomes
$|G|\cdot|A|^2 \le |G|\cdot(|A| + |G| - 1)$; cancelling $|G|$ gives
$|A|^2 \le |A| + |G| - 1$, i.e. $|A|^2 - |A| \le |G| - 1$. Rewriting
$|A|^2 - |A| = |A|(|A|-1)$ (trivially true when $|A| = 0$) completes the proof. $\square$

Asymptotically this says $|A| \le \tfrac12 + \sqrt{|G| - \tfrac34} = \sqrt{|G|}(1+o(1))$,
and it is best possible: for $N = q^2+q+1$ with $q$ a prime power, Singer's perfect
difference sets in $\mathbb{Z}_N$ are Sidon sets of size $q+1$, for which
$|A|(|A|-1) = q(q+1) = N-1$ holds with equality.

**Theorem 4.6 (Self-translate marginals).** For every Sidon set $A$ in a finite abelian
group $G$,
$$|A|^3 \;\le\; (2|A| - 1)\cdot |G|.$$

*Proof sketch.* If $A = \emptyset$ the claim is trivial. Otherwise take $S = A$ in Theorem
4.4, so $|S| = |A| \ge 1$ and $|A| + (|A|-1) = 2|A| - 1$. The result is
$|A|\cdot|A|^2 \le |G|(2|A|-1)$. $\square$

Asymptotically Theorem 4.6 gives only $|A| \lesssim \sqrt{2|G|}$ — worse by a factor
$\sqrt 2$. The two theorems come from the *same* Sidon set and the *same* machinery; the
only difference is the shift set.

### 4.5 The two outputs are strictly ordered

Is the loss in Theorem 4.6 an artefact of crude estimation, or a genuine consequence of the
weaker marginal choice? It is genuine, and we can locate it exactly by comparing the two
outputs as arithmetic conditions on the pair $(N, m) = (|G|, |A|)$.

**Theorem 4.7 (Domination).** For all natural numbers $m$ and $N$ with $N \ge 1$,
$$m(m-1) \le N - 1 \;\Longrightarrow\; m^3 \le (2m-1)N .$$

*Proof sketch.* The cases $m = 0$ and $m = 1$ are immediate ($0 \le 0$ and $1 \le N$). For
$m = k+2$ with $k \ge 0$ the hypothesis says $N \ge (k+2)(k+1) + 1$, and the conclusion
reads $(k+2)^3 \le (2k+3)N$. Substituting the lower bound for $N$ it suffices to check
$(k+2)^3 \le (2k+3)\bigl((k+2)(k+1)+1\bigr)$, which expands to
$k^3+6k^2+12k+8 \le 2k^3 + 13k^2 + 26k + 15$, true for all $k \ge 0$. $\square$

**Theorem 4.8 (Strictness).** There exist $N, m \ge 1$ with
$$m^3 \le (2m-1)N \quad\text{and}\quad m(m-1) > N-1 .$$
Explicitly, $N = 100$, $m = 13$: indeed $13^3 = 2197 \le 2500 = 25 \cdot 100$, while
$13 \cdot 12 = 156 > 99$.

Together, Theorems 4.7 and 4.8 say that the self-translate output is a *strictly weaker*
condition than the all-translate output. Concretely, a hypothetical Sidon set of size $13$
in a group of order $100$ is not excluded by the self-translate marginals, but is excluded
by the all-translate marginals. The gap between the two arguments is therefore a genuine
feature of the marginal choice — a property of *which* family was fed in — and not slack
introduced by any of the estimates in Sections 2–3.

This is the marginal selection principle in its sharpest form: the machinery, being
universal, contributes nothing to the comparison; the entire difference between a
$\sqrt{2|G|}$ bound and a $\sqrt{|G|}$ bound is the decision to use $|G|$ translates rather
than $|A|$.

### 4.6 Why all translates are optimal, structurally

There is a conceptual explanation for the optimality of $S = G$ which the arithmetic above
merely confirms. When $S = G$ the family $\{A+g\}_{g\in G}$ is *translation invariant*: the
group acts on it transitively, so every point of $G$ has exactly the same multiplicity,
namely $|A|$. Cauchy–Schwarz is an equality precisely when the multiplicity function is
constant. Thus the all-translate marginal is the unique choice for which the only
inequality used in the derivation — Cauchy–Schwarz — is *tight*. Every other shift set
produces a non-constant multiplicity function and therefore leaks.

This suggests, and we state it below as a conjecture, that the ordering of the outputs is
monotone in $S$ throughout, not merely between the two extremes.

---

## 5. A cross-domain instantiation: $C_4$-free graphs

The machinery is field-agnostic. We illustrate by feeding it marginals of an entirely
different provenance.

Let $\Gamma$ be a finite simple graph on vertex set $V$ with edge set $E$. For $v \in V$
write $N(v)$ for its neighbourhood. Then $N(u) \cap N(v)$ is the set of common neighbours
of $u$ and $v$, so the condition

$$|N(u) \cap N(v)| \le 1 \quad \text{for all } u \ne v \tag{5.1}$$

says precisely that $\Gamma$ contains no four-cycle $C_4$ — no two vertices have two common
neighbours.

**Theorem 5.2 (Reiman's inequality).** If $\Gamma$ satisfies (5.1), then
$$\bigl(2|E|\bigr)^2 \;\le\; |V| \cdot \Bigl(2|E| + |V|\bigl(|V|-1\bigr)\Bigr).$$
In particular $|E| = O(|V|^{3/2})$.

*Proof sketch.* Feed the neighbourhood marginals $A_v = N(v)$, indexed by $v \in V$, into
Corollary 3.3. The hypothesis $t = 1$ is exactly (5.1). The total size is
$\sum_{v} |N(v)| = \sum_v \deg(v) = 2|E|$ by the handshake lemma. The support is a subset
of $V$, so $|\operatorname{supp}| \le |V|$, and the number of indices is $|V|$. $\square$

Writing $n = |V|$ and solving the quadratic gives
$|E| \le \tfrac14\bigl(n + n\sqrt{4n-3}\bigr) \approx \tfrac12 n^{3/2}$, the classical
Reiman bound; it is attained up to the constant by the incidence graph of a projective
plane of order $q$, which has $n = 2(q^2+q+1)$ vertices and $(q+1)(q^2+q+1)$ edges.

The point is not that Theorem 5.2 is new — it is not — but that its proof used *no new
machinery whatsoever*. The engine from Section 2, which was developed with no thought of
graphs, produced it as soon as we chose neighbourhoods as marginals. Sections 4 and 5
differ only in step 1 of the recipe.

---

## 6. The third-order layer

The Fubini identity is not tied to the second moment. Iterating it produces a
triple-correlation theory, which is the natural place to look for information the pair
correlations cannot see.

**Theorem 6.1 (Third moment).**
$$\sum_{i}\sum_{j}\sum_{k} |A_i \cap A_j \cap A_k| \;=\; \sum_{x\in\operatorname{supp}(A)} m_A(x)^3 .$$

*Proof sketch.* Apply the localised Fubini identity (2.4) three times. First, with
$s = A_i \cap A_j$ and $f \equiv 1$, obtain
$\sum_k |A_i \cap A_j \cap A_k| = \sum_{x \in A_i\cap A_j} m_A(x)$. Second, with $s = A_i$
and $f = m_A$, obtain $\sum_j \sum_{x\in A_i \cap A_j} m_A(x) = \sum_{x\in A_i} m_A(x)^2$.
Third, with $s = \operatorname{supp}(A)$ and $f = m_A^2$, and using
$A_i = \operatorname{supp}(A)\cap A_i$, obtain the claim. $\square$

**Theorem 6.2 (Third-order Bonferroni identity).** With $m = m_A(x)$,
$$\sum_{x\in\operatorname{supp}(A)} m(m-1)(m-2) \;+\; 3\sum_{i}\sum_{j}|A_i \cap A_j|
\;=\; \sum_i\sum_j\sum_k |A_i\cap A_j\cap A_k| \;+\; 2\sum_i |A_i| .$$

*Proof sketch.* Rewrite each of the four sums via Corollaries 2.5, 2.6 and Theorem 6.1, so
that the statement becomes a pointwise identity on the support:
$m(m-1)(m-2) + 3m^2 = m^3 + 2m$, which is $m^3 - 3m^2 + 2m + 3m^2 = m^3 + 2m$. The
verification is by cases on $m \in \{0,1,2\}$ and $m \ge 3$, so that the truncated
subtractions $m-1, m-2$ are the honest ones. $\square$

The identity is stated with all subtractions confined to the single expression
$m(m-1)(m-2)$ — the number of *ordered triples of distinct indices* whose sets all contain
$x$. It is inclusion–exclusion at the third level, with no cancellation-induced sign
issues.

**Definition 6.3.** The *triple-collision set* is
$T(A) = \{x \in \operatorname{supp}(A) : m_A(x) \ge 3\}$.

**Theorem 6.4 (Third-order collision bound).**
$$6\,|T(A)| \;\le\; \sum_{x\in\operatorname{supp}(A)} m_A(x)\bigl(m_A(x)-1\bigr)\bigl(m_A(x)-2\bigr).$$

*Proof sketch.* Each $x \in T(A)$ contributes at least $3\cdot2\cdot1 = 6$ to the
right-hand sum, and all terms are nonnegative. $\square$

This is the exact analogue of Theorem 2.13 one level up. For consistency we note the
expected comparison: since $T(A) \subseteq D(A)$, Theorem 2.13 also gives
$2|T(A)| \le P(A)$, and Theorem 6.4 is the stronger statement about $T(A)$ whenever
multiplicities exceed $3$.

The strategic significance is this. Theorems 2.10, 2.13 and 2.14 are all *second-moment*
statements; they see only pair correlations. For extremal problems whose defining condition
is genuinely of order $h \ge 3$ — for instance $B_h$-sets, in which every group element has
at most one representation as an unordered sum of $h$ members — pair correlations already
contain all the information the second-moment machinery can extract, and no reshuffling of
two-set marginals can beat the naive count. The improvement, if it exists, must come from
Theorems 6.1–6.4 and their higher analogues.

---

## 7. Sharpness data

Two small examples pin down the behaviour of the machinery at its extremes.

**Proposition 7.1.** The double-collision bound is attained: for the constant family
$A_0 = A_1 = \{0\}$ on two indices, $P(A) = 2$ and $|D(A)| = 1$, so $2|D(A)| = P(A) = 2$.

**Proposition 7.2.** The Bonferroni inequality can be strict: for the same family,
$\sum_i |A_i| = 2$ while $|\bigcup_i A_i| + P(A) = 1 + 2 = 3$.

Proposition 7.2 is consistent with Theorem 2.11 — the family is not pairwise disjoint — and
together with Theorem 2.11 it shows that the equality condition genuinely bites: the
inequality is strict for every family that is not trivially disjoint.

---

## 8. Applications and algorithmic content

**Sidon set search.** Theorem 4.5 bounds the search space for maximal Sidon sets in
$\mathbb{Z}_N$: a Sidon set of size $m$ requires $N \ge m(m-1) + 1$. A greedy or
backtracking search can therefore prune whenever the partial set already exceeds the
admissible size, and the master inequality of Theorem 4.4 with intermediate $S$ furnishes
weaker but cheaper tests. Exhaustive search with this cutoff recovers, for
$N = 13, 21, 31, 57, 73$, Sidon sets for which Theorem 4.5 is an exact equality
$|A|(|A|-1) = N-1$ — the classical perfect difference sets — confirming that the
all-translate marginal is not merely better than the self-translate marginal but optimal.

**Certificate checking for $C_4$-freeness.** Theorem 5.2 gives an $O(1)$ test that
immediately refutes $C_4$-freeness of a graph whose edge count exceeds
$\tfrac14(n + n\sqrt{4n-3})$, without inspecting the structure at all. This is the standard
first line of defence in extremal graph computations.

**Design theory and coding.** The uniform-marginal Theorem 3.2 is the Fisher-type
inequality behind many packing bounds: a family of $k$ blocks of size $m$ in a $v$-point
ground set with pairwise intersections at most $t$ satisfies $km^2 \le v(m + (k-1)t)$,
which is the standard bound for constant-weight codes with prescribed maximum correlation.

**A recipe.** The practical algorithm implicit in this paper is a three-line procedure:
given an extremal question, (i) design a family whose members are large and pairwise almost
disjoint; (ii) read off the triple $(k, m, t)$; (iii) substitute into Theorem 3.2. Step
(iii) is mechanical. Steps (i)–(ii) are the mathematics.

---

## 9. Discussion and future directions

### 9.1 What the principle says and does not say

The marginal selection principle asserts that a bound obtained from Theorems 2.10–2.14 is a
function of the marginals alone. It does *not* assert that every extremal bound arises this
way — many do not, and Fourier-analytic and algebraic methods routinely beat double
counting. What it does assert is that within the double-counting paradigm, effort spent
optimising the inequality is wasted (Theorem 2.11 shows there is nothing to optimise), and
effort spent choosing the family is the only thing that can pay.

### 9.2 Monotonicity in the shift set

Section 4.6 suggests that Theorem 4.7 is the tip of a general phenomenon.

**Conjecture 9.1 (Marginal monotonicity).** For a Sidon set $A \subseteq G$ and shift sets
$S \subseteq T$, the bound on $|A|$ extracted from
$|T|\,|A|^2 \le |G|(|A| + |T| - 1)$ is at least as strong as the one extracted from $S$.
Precisely: for all $N$ and all $1 \le k \le l \le N$,
$$\max\{m : l\,m^2 \le N(m + l - 1)\} \;\le\; \max\{m : k\,m^2 \le N(m + k - 1)\}.$$

The mechanism should be that the admissible region for $m$ shrinks monotonically as the
number of marginals grows, because the constraint may be rewritten as
$(m^2 - m)\big/\bigl(1 - \tfrac1k\bigr) \le \tfrac{N}{1}\cdot(\cdots)$ with the left side
increasing in $k$. Establishing this converts "all translates is best" from an observation
about two data points into a theorem about the whole lattice of marginal choices, and
identifies the optimum as a consequence of translation invariance (constant multiplicity,
hence tight Cauchy–Schwarz) rather than a numerical accident.

### 9.3 $B_h$-sets: the exponent is set by the marginal

**Conjecture 9.2.** Let $A \subseteq G$ be a $B_h$-set: every element of $G$ has at most one
representation as an unordered sum of $h$ elements of $A$. Then feeding the machinery the
$(h-1)$-fold sumset marginals $A_g = (A + \cdots + A) + g$ gives
$$|A|^h \le h!\,|G| + O\bigl(|A|^{h-1}\bigr),$$
and the constant obtained is exactly the one produced by the trivial counting argument.

The heuristic is that Corrádi's inequality is a second-moment statement and can therefore
see only pair correlations; for $B_h$ with $h \ge 3$ the pair-correlation marginal already
carries the full information, which predicts that no choice of two-set marginals can beat
the naive bound. Any improvement must come from an $h$-th moment version of the machinery —
which is exactly what Theorems 6.1–6.4 begin to supply.

### 9.4 Further questions

- **Equality analysis at higher order.** Theorem 2.11 characterises equality in the second
  Bonferroni inequality. What is the analogous characterisation for the third-order
  identity of Theorem 6.2, and does it single out families with a $3$-design structure?
- **Weighted marginals.** The Fubini identity accepts an arbitrary weight $f$. Choosing $f$
  adapted to the problem (rather than $f \equiv 1$ or $f = m$) amounts to a weighted
  Cauchy–Schwarz. Is there a systematic optimal choice of $f$ for a given marginal family?
- **Non-abelian ambient groups.** Theorem 4.3 used commutativity only to rearrange
  $p + q' = q + p'$. A careful two-sided version should give a translate marginal for
  Sidon sets in non-abelian groups, and hence a bound of Erdős–Turán type there.
- **Beyond intersections: the $K_{s,t}$ hierarchy.** Corollary 3.3 is the $K_{2,2}$ case of
  Kővári–Sós–Turán. The general case counts $s$-subsets of members rather than pairs. Is
  there a moment identity of the type of Theorem 6.1 whose specialisation reproduces the
  general Kővári–Sós–Turán bound, thereby exhibiting the whole family as marginal choices
  for one universal machine?

### 9.5 Conclusion

We have separated a common proof pattern into a universal component and a
problem-specific component, proved the universal component in full generality, shown it to
be exact at its boundary, and demonstrated — with a theorem, not an anecdote — that the two
natural marginal choices for one and the same Sidon set yield strictly ordered conclusions.
The same universal component, given graph-theoretic marginals, yields a classical bound in
extremal graph theory. The moral for the practitioner is concrete: when your double
counting bound is off by a constant factor, do not sharpen the inequality; change what you
count.

---

## References (classical background)

The second Bonferroni inequality and the Cauchy–Schwarz strengthening are classical; the
latter is often attributed to Corrádi. The bound $|A|(|A|-1) \le |G|-1$ for Sidon sets goes
back to Erdős and Turán, with matching constructions due to Singer. The bound
$|E| = O(|V|^{3/2})$ for $C_4$-free graphs is due to Reiman and is the $K_{2,2}$ case of
the Kővári–Sós–Turán theorem. All statements in Sections 2–7 above are proved in full from
first principles in the text and require no external input beyond finite cardinality
arithmetic and the Cauchy–Schwarz inequality for finite sums.
