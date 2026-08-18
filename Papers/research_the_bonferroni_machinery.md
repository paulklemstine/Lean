# Multiplicity Calculus for Finite Families: Exact Bonferroni Defects, Rigidity, Stability, and the Marginal-Order Threshold

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

We develop a complete second-order theory of finite set families organised
around a single object: the *coverage multiplicity* function
$d(x) = \#\{i \in I : x \in A_i\}$ of a family $A : I \to \mathcal{P}(\Omega)$
over a finite index set $I$ and a finite ground set $\Omega$. Two elementary
moment identities — $\sum_{x \in U} d(x) = \sum_i |A_i|$ and
$\sum_{x \in U} d(x)^2 = \sum_{i,j} |A_i \cap A_j|$, where
$U = \bigcup_i A_i$ — identify the first- and second-order *marginals* of the
family with the first two moments of $d$ on its cover. From these we derive the
entire Bonferroni machinery, but in a strictly stronger form: each inequality is
obtained by summing a pointwise polynomial inequality for $d$, and therefore
comes with an *exact defect identity* whose defect is a nonnegative irregularity
functional of $d$.

Our main results are: (i) the Bonferroni defect identity
$\sum_i |A_i| + \sum_{x \in U}(d(x)-1)^2 = |U| + \sum_{i \ne j}|A_i \cap A_j|$
and its sharp (unordered-pair) counterpart with defect
$\sum_{x \in U}(d(x)-1)(d(x)-2)$; (ii) exact rigidity theorems — the union bound
is tight iff the family is pairwise disjoint, the sharp Bonferroni and
double-collision bounds are tight iff the multiplicity never exceeds $2$, and
the Cauchy–Schwarz (Corrádi) bound is tight iff the cover is regular; (iii) a
quantitative stability theorem: the squared spread
$(d(x) - d(y))^2$ of the multiplicity is bounded by the Cauchy–Schwarz gap $g$,
and since $g$ is an integer, $g < 1$ forces exact regularity; (iv) Corrádi's
inequality $km^2 \le |U|(m + (k-1)t)$ and a Fisher-type counting bound
$k(m^2 - Nt) \le N(m-t)$, both shown to be attained at the two ends of the
correlation scale; and (v) a sharp *marginal-order threshold*: for every
$k \ge 1$ there exist two families of $k$ sets agreeing on all joint marginals
of order $< k$ whose unions differ, while marginals of all orders always
determine the union. The threshold for $k$ sets is exactly $k$.

The reading throughout is machine-learning-flavoured: $A_i$ is the failure set
of hypothesis $i$ over a finite sample space, $d$ counts how many ensemble
members fail at a sample, and the theory answers precisely what individual error
rates and pairwise co-failure rates do and do not determine about the ensemble's
total error support.

**Keywords:** Bonferroni inequalities, inclusion–exclusion, coverage
multiplicity, Corrádi's inequality, Fisher-type bounds, rigidity and stability,
ensemble error correlation, Möbius inversion.

---

## 1. Introduction

### 1.1 The problem

Let $\Omega$ be a finite set and let $A_1, \dots, A_k$ be subsets of $\Omega$.
The *first marginals* of this family are the numbers $|A_i|$; the *second
marginals* are the numbers $|A_i \cap A_j|$. More generally, for a subfamily
$T \subseteq \{1, \dots, k\}$ the *joint marginal of order $|T|$* is
$\bigl|\bigcap_{i \in T} A_i\bigr|$.

The quantity one usually wants is the size of the union,
$\bigl|\bigcup_i A_i\bigr|$. Inclusion–exclusion expresses it in terms of *all*
marginals, but the alternating sum has $2^k - 1$ terms and requires data of
every order. Truncating the alternating sum after the first order gives the
union bound $\sum_i |A_i| \ge |U|$; after the second order it gives the
classical Bonferroni inequality
$\sum_i |A_i| - \sum_{i<j}|A_i \cap A_j| \le |U|$.

Two questions organise this paper.

1. **How lossy are these truncations, exactly?** Not "how lossy in the worst
   case", but *exactly*: is there a closed-form expression for the defect, and
   which families make it vanish?
2. **Is the truncation to low order an artefact of the method, or a genuine
   information barrier?** In other words, could some non-linear function of the
   low-order marginals compute the union?

Question 1 has a complete answer, and the answer is unexpectedly clean: every
Bonferroni-type inequality in this family is an *identity minus an explicit
nonnegative functional*, and each functional is a moment of a single scalar
function. Question 2 has a complete answer too, and it is negative in the
strongest possible sense: for every $k$ there is a *proper* obstruction at every
order below $k$.

### 1.2 Motivation from ensemble learning

Fix a finite sample space $\Omega$ of size $N$ and a finite collection of
hypotheses (classifiers, predictors, hypothesis tests) indexed by $I$. Let $A_i$
be the set of samples on which hypothesis $i$ fails. Then:

- $|A_i|$ is the empirical error count of hypothesis $i$ (its first marginal);
- $|A_i \cap A_j|$ is the empirical co-failure count of the pair $(i,j)$ — the
  raw ingredient of every pairwise diversity metric used in ensemble design;
- $U = \bigcup_i A_i$ is the set of samples on which the ensemble is *not
  unanimously correct*;
- $d(x)$ is the number of ensemble members that fail at sample $x$;
- $D = \{x : d(x) \ge 2\}$ is the set of samples where failures are
  *correlated*, and $\{x : d(x) > |I|/2\}$ (not studied here) is where majority
  voting fails.

Ensemble diversity theory is almost entirely built from first- and second-order
marginals. The results below determine precisely the reach and the limits of
that data. In particular, Theorem 8.4 below constructs, for every $k$, two
ensembles indistinguishable by every marginal of order $< k$ whose total error
supports differ — a hard limit on the expressive power of pairwise diversity
metrics.

### 1.3 Overview of results

Section 2 fixes notation and proves the two moment identities. Section 3 derives
the exact Bonferroni defect identity and the second Bonferroni inequality.
Section 4 sharpens to the unordered-pair form and proves the double-collision
bound. Section 5 proves the Cauchy–Schwarz/Corrádi bound via a Lagrange
identity. Section 6 gives the three rigidity theorems. Section 7 gives the
quantitative stability theorem. Section 8 gives the marginal-order threshold.
Section 9 gives Corrádi's inequality and the Fisher-type bound with tightness at
both extremes. Section 10 collects worked numerical data. Sections 11–12 discuss
applications and open problems.

---

## 2. The multiplicity calculus

Throughout, $\Omega$ is a set with decidable equality, $I$ is a finite index set
of size $k = |I|$, and $A : I \to \mathcal{P}_{\mathrm{fin}}(\Omega)$ is a family
of finite subsets of $\Omega$.

**Definition 2.1 (Multiplicity).** The *coverage multiplicity* of a point
$x \in \Omega$ is
$$d(x) \;=\; \operatorname{mult}_{I,A}(x) \;=\; \#\{\, i \in I : x \in A_i \,\}.$$

**Definition 2.2 (Cover).** The *cover* of the family is
$U = \operatorname{cover}(I, A) = \bigcup_{i \in I} A_i$.

**Definition 2.3 (Double collision set).** The *double-collision set* is
$D = \{\, x \in U : d(x) \ge 2 \,\}$.

The following are immediate: $x \in U$ iff $d(x) > 0$; hence $d(x) \ge 1$ for
every $x \in U$, a fact used repeatedly below (in particular it makes truncated
integer subtractions like $d(x) - 1$ harmless). Also $A_i \subseteq U$ for each
$i \in I$.

**Lemma 2.4 (Indicator expansion).** For every $x \in \Omega$,
$$d(x) \;=\; \sum_{i \in I} \mathbf{1}[x \in A_i].$$

*Proof.* The cardinality of a filtered finite set is the sum of the indicator
of its predicate. $\square$

The two identities below are the engine of everything that follows. Both are
stated for an arbitrary finite $S \subseteq \Omega$ containing all the $A_i$;
the case $S = U$ is the one used.

**Theorem 2.5 (First moment identity).** Let $S$ be a finite set with
$A_i \subseteq S$ for every $i \in I$. Then
$$\sum_{x \in S} d(x) \;=\; \sum_{i \in I} |A_i|.$$
In particular $\sum_{x \in U} d(x) = \sum_{i \in I} |A_i|$.

*Proof sketch.* Expand $d$ by Lemma 2.4 and exchange the order of summation:
$\sum_{x \in S}\sum_{i \in I}\mathbf{1}[x\in A_i] = \sum_{i \in I}\sum_{x \in S}\mathbf{1}[x\in A_i]
= \sum_{i \in I} |A_i \cap S| = \sum_{i \in I}|A_i|$, the last step using
$A_i \subseteq S$. This is Fubini for the incidence relation
$\{(x,i) : x \in A_i\}$: counting incidences by point, then by set. $\square$

**Theorem 2.6 (Second moment identity).** Under the same hypotheses,
$$\sum_{x \in S} d(x)^2 \;=\; \sum_{(i,j) \in I \times I} |A_i \cap A_j|,$$
the sum on the right running over *ordered* pairs, diagonal included. In
particular $\sum_{x \in U} d(x)^2 = \sum_{i,j} |A_i \cap A_j|$.

*Proof sketch.* Squaring Lemma 2.4 and expanding the product of two sums gives
the pointwise identity
$$d(x)^2 = \sum_{(i,j) \in I \times I} \mathbf{1}[x \in A_i]\,\mathbf{1}[x\in A_j]
= \sum_{(i,j) \in I \times I} \mathbf{1}[x \in A_i \cap A_j],$$
verified by the four cases of $(x \in A_i?, x \in A_j?)$. Exchanging summation
and using $A_i \cap A_j \subseteq A_i \subseteq S$ gives the claim. This is
Fubini for the triple incidence relation $\{(x,i,j) : x \in A_i \cap A_j\}$.
$\square$

It is worth pausing on what Theorems 2.5 and 2.6 say. *The first- and
second-order marginal data of a family is exactly the pair of first two moments
of one scalar function on the cover.* Every statement provable from first- and
second-order marginals is therefore a statement about $(\mathbb{E}d,
\mathbb{E}d^2)$ with respect to the counting measure on $U$ — and conversely,
whatever those two moments cannot see, the marginals cannot see either. This
observation will be made precise (and shown to be a genuine obstruction) in
Section 8.

Splitting off the diagonal of the ordered pair sum is elementary but worth
recording, since the off-diagonal mass is the quantity appearing in every
Bonferroni statement.

**Lemma 2.7 (Diagonal splitting).**
$$\sum_{(i,j) \in I \times I} |A_i \cap A_j| \;=\; \sum_{i \in I} |A_i| \;+\; \sum_{\substack{(i,j) \in I \times I \\ i \ne j}} |A_i \cap A_j|.$$

*Proof.* The product $I \times I$ is the disjoint union of the diagonal and the
off-diagonal; on the diagonal $|A_i \cap A_i| = |A_i|$. $\square$

**Corollary 2.8 (Off-diagonal mass as a factorial moment).**
$$\Sigma_2 \;:=\; \sum_{i \ne j} |A_i \cap A_j| \;=\; \sum_{x \in U} d(x)\bigl(d(x) - 1\bigr).$$

*Proof sketch.* Combine Theorems 2.5 and 2.6 with Lemma 2.7 and the pointwise
identity $d^2 = d(d-1) + d$, which holds without truncation issues because
$d(x) \ge 1$ on $U$. $\square$

The right-hand side of Corollary 2.8 is the *second factorial moment* of $d$. It
has a direct combinatorial reading: $d(x)(d(x)-1)$ is the number of ordered
pairs of distinct family members both containing $x$, so $\Sigma_2$ counts
ordered "collisions". We will use the shorthand
$$\Sigma_1 := \sum_{i \in I}|A_i|, \qquad
\Sigma_2 := \sum_{i \ne j}|A_i \cap A_j|, \qquad
\Sigma_2^{\mathrm{tot}} := \sum_{i, j}|A_i \cap A_j| = \Sigma_1 + \Sigma_2 .$$

---

## 3. The Bonferroni defect identity

**Theorem 3.1 (Bonferroni defect identity).** For every finite family,
$$\Sigma_1 \;+\; \sum_{x \in U} \bigl(d(x) - 1\bigr)^2 \;=\; |U| \;+\; \Sigma_2 .$$

*Proof sketch.* By Corollary 2.8 and Theorem 2.5, the right-hand side equals
$\sum_{x \in U}\bigl(1 + d(x)(d(x)-1)\bigr)$ and the left-hand side equals
$\sum_{x \in U}\bigl(d(x) + (d(x)-1)^2\bigr)$. The two summands agree pointwise
because $1 + d^2 - d = d + d^2 - 2d + 1$. (Over the natural numbers, one first
writes $d(x) = 1 + c$ with $c \ge 0$, valid on the cover, so that the truncated
subtraction is genuine.) $\square$

**Definition 3.2 (Irregularity functional).** The *Bonferroni defect*, or
*irregularity*, of the family is
$$\operatorname{Irr}(I,A) \;=\; \sum_{x \in U}\bigl(d(x) - 1\bigr)^2 \;\ge\; 0 .$$

**Corollary 3.3 (Second Bonferroni inequality, off-diagonal form).**
$$\sum_{i \in I} |A_i| \;\le\; \Bigl|\bigcup_{i \in I} A_i\Bigr| \;+\; \sum_{i \ne j} |A_i \cap A_j| .$$

*Proof.* Drop the nonnegative term $\operatorname{Irr}$ from Theorem 3.1. In
inequality form, the argument is the pointwise bound $2d \le 1 + d^2$ — the
"square completion" $(d-1)^2 \ge 0$ — summed over $U$ and combined with the two
moment identities. $\square$

Corollary 3.3 already refines the naive union bound $\Sigma_1 \ge |U|$ in a
useful direction, but its correction term double-counts each unordered pair. The
next section removes that factor of two.

---

## 4. The sharp Bonferroni inequality and the double-collision bound

The classical second Bonferroni inequality sums over unordered pairs and is a
factor $2$ stronger on the correction:
$\Sigma_1 - \sum_{i<j}|A_i \cap A_j| \le |U|$. Written index-order-free (so as
to avoid choosing a linear order on $I$), this reads
$2\Sigma_1 \le 2|U| + \Sigma_2$. It too has an exact defect, and the defect has
a different — and more informative — shape.

**Theorem 4.1 (Sharp Bonferroni defect identity).**
$$2\,\Sigma_1 \;+\; \sum_{x \in U} \bigl(d(x) - 1\bigr)\bigl(d(x) - 2\bigr) \;=\; 2\,|U| \;+\; \Sigma_2 .$$

*Proof sketch.* As in Theorem 3.1, reduce to a pointwise identity on the cover.
Writing $d = 1 + c$ with $c \ge 0$, the claim is
$2(1+c) + c\,(c-1) = 2 + (1+c)c$, which holds; the case $c = 0$ is checked
separately because of truncated subtraction ($d - 2 = 0$ when $d = 1$, and the
product $(d-1)(d-2)$ vanishes there anyway since $d - 1 = 0$). $\square$

**Corollary 4.2 (Sharp second Bonferroni inequality).**
$$2\sum_{i \in I}|A_i| \;\le\; 2\Bigl|\bigcup_i A_i\Bigr| \;+\; \sum_{i \ne j}|A_i \cap A_j|,
\qquad\text{equivalently}\qquad
\sum_i |A_i| - \sum_{i<j}|A_i\cap A_j| \;\le\; \Bigl|\bigcup_i A_i\Bigr| .$$

*Proof.* The defect $(d-1)(d-2)$ is nonnegative for every integer $d \ge 0$
(it is $\ge 0$ for $d \le 1$, zero at $d \in \{1,2\}$, positive for $d \ge 3$).
$\square$

**Proposition 4.3 (Sharp implies unsharp).** Corollary 4.2 implies Corollary
3.3: from $2\Sigma_1 \le 2|U| + \Sigma_2$ one gets
$2\Sigma_1 \le 2(|U| + \Sigma_2)$ since $\Sigma_2 \ge 0$, and dividing by $2$
recovers Corollary 3.3.

The change of defect from $(d-1)^2$ to $(d-1)(d-2)$ is the whole story of this
section. The first vanishes only at $d = 1$; the second vanishes on the interval
$\{1, 2\}$. So the extremal class widens from "pairwise disjoint" to "no point
covered three times", and — as the next result shows — this new class is
*shared* with a second, apparently different, inequality.

**Definition 4.4.** Recall $D = \{x \in U : d(x) \ge 2\}$, the double-collision
set.

**Theorem 4.5 (Double-collision bound).**
$$2\,|D| \;\le\; \sum_{i \ne j} |A_i \cap A_j| .$$

*Proof sketch.* By Corollary 2.8 the right side is
$\sum_{x \in U} d(x)(d(x)-1)$. Restrict the sum to $D$ (legitimate, since each
summand is nonnegative), and on $D$ use $d \ge 2$, hence $d - 1 \ge 1$, hence
$d(d-1) \ge 2 \cdot 1 = 2$. Summing the constant $2$ over $D$ gives $2|D|$.
$\square$

**Corollary 4.6 (Ensemble reading).** If every pair of hypotheses in an ensemble
co-fails on at most $t$ samples, and there are $k$ hypotheses, then the number
of samples on which at least two hypotheses fail is at most $k(k-1)t/2$.

*Proof.* Apply Theorem 4.5 with $\Sigma_2 \le k(k-1)t$. $\square$

Finally, a structural remark that will be used in Section 6: a covered point
that is *not* a double collision lies in exactly one member of the family, since
$1 \le d(x)$ and $d(x) < 2$ force $d(x) = 1$.

---

## 5. The Cauchy–Schwarz upgrade

The Bonferroni route compares $d$ pointwise to the constant $1$. When the family
is far from a partition — typical multiplicity much larger than $1$ — this is
wasteful. Comparing $d$ to its own mean instead yields a bound that is
incomparably better in that regime. The mechanism is a two-line identity.

**Lemma 5.1 (Lagrange identity).** For any finite set $S$ and any
$f : S \to \mathbb{Z}$,
$$2\Bigl(|S| \sum_{x \in S} f(x)^2 \;-\; \Bigl(\sum_{x \in S} f(x)\Bigr)^{\!2}\Bigr)
\;=\; \sum_{x \in S}\sum_{y \in S}\bigl(f(x) - f(y)\bigr)^{2} .$$

*Proof sketch.* Expand $(f(x) - f(y))^2 = f(x)^2 - 2f(x)f(y) + f(y)^2$ and sum
over $y$ first: the inner sum is
$|S| f(x)^2 - 2 f(x)\sum_y f(y) + \sum_y f(y)^2$. Summing over $x$ gives
$2|S|\sum f^2 - 2(\sum f)^2$. $\square$

**Theorem 5.2 (Second-moment / Cauchy–Schwarz bound).**
$$\Bigl(\sum_{i \in I}|A_i|\Bigr)^{\!2} \;\le\; \Bigl|\bigcup_{i} A_i\Bigr| \cdot \sum_{(i,j) \in I\times I} |A_i \cap A_j| ,
\qquad\text{i.e.}\qquad \Sigma_1^2 \le |U| \cdot \Sigma_2^{\mathrm{tot}} .$$

*Proof sketch.* Apply Lemma 5.1 with $S = U$ and $f = d$ (viewed in
$\mathbb{Z}$). The right-hand side of the Lagrange identity is a sum of squares,
hence nonnegative, so $(\sum_U d)^2 \le |U| \sum_U d^2$. Substitute the moment
identities of Theorems 2.5 and 2.6 and cast back to $\mathbb{N}$. $\square$

**Definition 5.3 (Cauchy–Schwarz gap).** The *gap* of a family is the integer
$$g \;=\; g(I,A) \;=\; |U| \cdot \sum_{x \in U} d(x)^2 \;-\; \Bigl(\sum_{x\in U} d(x)\Bigr)^{\!2}
\;=\; |U| \cdot \Sigma_2^{\mathrm{tot}} \;-\; \Sigma_1^2 \;\ge\; 0 .$$

The two expressions for $g$ agree by Theorems 2.5–2.6; the second shows that $g$
is *computable from the marginals alone*, and the first shows that it is
nonnegative and equals $\tfrac{1}{2}\sum_{x,y \in U}(d(x)-d(y))^2$ by Lemma 5.1.
This double description is what makes the stability theory of Section 7 work: a
statistic you can measure controls a structural quantity you cannot.

---

## 6. Rigidity: exactly which families are extremal

**Definition 6.1 (Regular cover).** The family is a *$d_0$-regular cover* if
$d(x) = d_0$ for every $x \in U$.

**Proposition 6.2.** If the family is a $d_0$-regular cover then
$\sum_i |A_i| = d_0 \cdot |U|$.

*Proof.* Immediate from Theorem 2.5. $\square$

The three rigidity theorems below are read straight off the corresponding defect
identities: an inequality obtained by discarding a nonnegative defect is an
equality exactly when the defect vanishes, and each defect is a sum of
nonnegative terms, so it vanishes exactly when every term does.

**Theorem 6.3 (Rigidity of the second Bonferroni inequality).** The following
are equivalent:
1. $\displaystyle \sum_{i}|A_i| = |U| + \sum_{i \ne j}|A_i \cap A_j|$;
2. $d(x) = 1$ for every $x \in U$;
3. the family is pairwise disjoint: $A_i \cap A_j = \emptyset$ for all
   $i \ne j$ in $I$.

*Proof sketch.* (1) $\Leftrightarrow$ (2): by Theorem 3.1, (1) holds iff
$\operatorname{Irr} = \sum_{x\in U}(d(x)-1)^2 = 0$ iff every summand vanishes
iff $d \equiv 1$ on $U$. (2) $\Rightarrow$ (3): if $x \in A_i \cap A_j$ with
$i \ne j$, then $x \in U$ and $d(x) \ge 2$, contradicting (2). (3)
$\Rightarrow$ (2): a covered point lies in some $A_i$; if it lay in a second
$A_j$ these would not be disjoint. $\square$

**Theorem 6.4 (Rigidity of the double-collision bound).** Equality
$2|D| = \sum_{i\ne j}|A_i \cap A_j|$ holds if and only if $d(x) \le 2$ for every
$x \in U$.

*Proof sketch.* Write the right side as $\sum_{x \in U} d(x)(d(x)-1)$
(Corollary 2.8) and split the sum over $D$ and $U \setminus D$. On
$U \setminus D$ we have $d = 1$, so those terms vanish. On $D$, the term
$d(d-1)$ equals $2$ iff $d = 2$ and exceeds $2$ iff $d \ge 3$. Hence the total
equals $2|D|$ iff no point has $d \ge 3$. $\square$

**Theorem 6.5 (Rigidity of the sharp Bonferroni inequality).** Equality
$2\Sigma_1 = 2|U| + \Sigma_2$ holds if and only if $d(x) \le 2$ for every
$x \in U$. Consequently the sharp Bonferroni inequality and the
double-collision bound have *the same* extremal class, and each is tight exactly
when the other is.

*Proof sketch.* By Theorem 4.1, equality holds iff
$\sum_{x \in U}(d(x)-1)(d(x)-2) = 0$; each summand is a nonnegative integer,
vanishing exactly when $d(x) \in \{1,2\}$, and $d(x) \ge 1$ on $U$. Combine with
Theorem 6.4. $\square$

**Theorem 6.6 (Rigidity of the second-moment bound).** Equality
$\Sigma_1^2 = |U| \cdot \Sigma_2^{\mathrm{tot}}$ holds if and only if the family
is a regular cover, i.e. iff $d$ is constant on $U$.

*Proof sketch.* By Lemma 5.1 and Definition 5.3, $2g = \sum_{x,y \in U}(d(x) -
d(y))^2$. Equality means $g = 0$, hence every squared difference vanishes, hence
$d$ is constant on $U$ (with the empty cover treated trivially). Conversely a
constant $d$ makes all differences zero. $\square$

The three theorems delineate a hierarchy of extremal classes:
$$\{\text{pairwise disjoint}\} \;\subsetneq\; \{d \le 2\}, \qquad
\{\text{pairwise disjoint}\} \;\subsetneq\; \{\text{regular}\},$$
with $\{d \le 2\}$ and $\{\text{regular}\}$ incomparable (a $2$-regular cover is
in both; a $3$-regular cover is regular but has $d = 3$; a family with
multiplicity profile $(1,2)$ has $d \le 2$ but is not regular). Choosing which
bound to apply to a given family is exactly the question of which extremal class
it is nearest.

---

## 7. Stability: near-tightness forces near-regularity

Exact rigidity statements are fragile: real families are never exactly extremal.
We now show that the rigidity of Theorem 6.6 is *stable* with an explicit and
optimal-order modulus, and that — because the gap is an integer — it is even
locally rigid.

**Theorem 7.1 (Spread bound).** For any two covered points $x, y \in U$,
$$\bigl(d(x) - d(y)\bigr)^{2} \;\le\; g ,$$
where $g$ is the Cauchy–Schwarz gap of Definition 5.3.

*Proof sketch.* By Lemma 5.1, $2g = \sum_{u \in U}\sum_{v \in U}(d(u)-d(v))^2$.
The double sum contains the two terms indexed by $(x,y)$ and $(y,x)$, each equal
to $(d(x)-d(y))^2$, and all other terms are nonnegative. Hence
$2(d(x)-d(y))^2 \le 2g$. $\square$

Thus the *entire spread* $\max_U d - \min_U d$ of the multiplicity function is
at most $\sqrt{g}$. Since $g$ is computable from the marginals, this is a
genuinely usable statement: a measured second-order profile close to the
extremal one certifies a structural conclusion about the unmeasured
multiplicity profile.

**Corollary 7.2 (Exact rigidity re-derived).** If $g = 0$ then the family is a
regular cover.

**Corollary 7.3 (Integrality gives a hard threshold).** If $g < 1$ then $d$ is
constant on $U$; that is, $g < 1$ already forces exact regularity. Equivalently,
either the family is exactly regular or $g \ge 1$.

*Proof.* $g$ is a nonnegative integer, so $g < 1$ means $g = 0$; apply Theorem
7.1 or Corollary 7.2. $\square$

**Theorem 7.4 (The Bonferroni defect is controlled by the gap).** Suppose the
family has average multiplicity $1$ on its cover, i.e.
$\sum_{x \in U} d(x) = |U|$ (equivalently $\Sigma_1 = |U|$). Then
$$|U| \cdot \operatorname{Irr}(I,A) \;=\; |U| \cdot \sum_{x \in U}\bigl(d(x)-1\bigr)^2 \;=\; g .$$

*Proof sketch.* Expand $\sum_U (d-1)^2 = \sum_U d^2 - 2\sum_U d + |U|$. Under
the hypothesis $\sum_U d = |U|$ this is $\sum_U d^2 - |U|$. Multiplying by $|U|$
gives $|U|\sum_U d^2 - |U|^2 = |U|\sum_U d^2 - (\sum_U d)^2 = g$. $\square$

So under the natural normalisation, the Bonferroni defect of Section 3 and the
Cauchy–Schwarz gap of Section 5 are the same quantity up to the factor $|U|$:
the two families of inequalities are not merely analogous but *quantitatively
linked*. In the ensemble reading, a committee whose second-order statistics are
within $g$ of the Corrádi-extremal profile has all coverage multiplicities
within $\sqrt{g}$ of each other; the failure mass is uniformly spread, with an
explicit modulus.

---

## 8. The marginal-order threshold

We now turn to the second organising question: is the restriction to
inequalities forced by the *information*, rather than by the method?

### 8.1 Second-order data is insufficient

**Definition 8.1 (The two witnesses).** On the ground set $\Omega = \{0,1,2,3\}$
define two families of three sets each:
$$\textbf{Triangle: } A_0 = \{0,1\},\; A_1 = \{1,2\},\; A_2 = \{2,0\};$$
$$\textbf{Sunflower: } B_0 = \{0,1\},\; B_1 = \{0,2\},\; B_2 = \{0,3\}.$$

**Proposition 8.2 (The witnesses are second-order indistinguishable).** For all
$i$, $|A_i| = |B_i| = 2$; for all $i \ne j$, $|A_i \cap A_j| = |B_i \cap B_j| = 1$
(and trivially $|A_i \cap A_i| = |B_i \cap B_i| = 2$). However
$$\Bigl|\bigcup_i A_i\Bigr| = 3, \qquad \Bigl|\bigcup_i B_i\Bigr| = 4 .$$
The third-order marginals do differ:
$|A_0 \cap A_1 \cap A_2| = 0$ while $|B_0 \cap B_1 \cap B_2| = 1$.

*Proof.* Direct enumeration. The triangle covers $\{0,1,2\}$ with each point in
exactly two of the three sets; the sunflower covers $\{0,1,2,3\}$ with $0$ in
all three and $1, 2, 3$ in one each. $\square$

**Theorem 8.3 (No second-order formula).** There is no function
$$F : (\text{first marginals}) \times (\text{second marginals}) \longrightarrow \mathbb{N}$$
such that $\bigl|\bigcup_{i} A_i\bigr| = F\bigl((|A_i|)_i, (|A_i\cap A_j|)_{i,j}\bigr)$
for all families of three subsets of a four-element set. Consequently every
statement relating the union to first- and second-order marginals must be an
inequality.

*Proof.* If such an $F$ existed, Proposition 8.2 would give
$3 = F(\text{data}) = 4$. $\square$

The witness pair also calibrates the theory of Sections 5–6 sharply. The
triangle has multiplicity profile $(2,2,2,0)$ over $\{0,1,2,3\}$: it is a
$2$-regular cover, so its gap is $g = 3\cdot 12 - 6^2 = 0$ and it attains
Corrádi's bound (Theorem 9.1 below) with equality, $3\cdot 2^2 = 12 = 3 \cdot (2 + 2\cdot 1)$.
The sunflower has profile $(3,1,1,1)$: gap $g = 4\cdot 12 - 6^2 = 12 > 0$,
Corrádi strict ($12 < 4 \cdot 4 = 16$), and its double-collision bound is slack
($2|D| = 2 < 6 = \Sigma_2$) — exactly as Theorem 6.4 predicts, since the
sunflower has a point of multiplicity $3$. *Both* the tightness and the
slackness are explained by the same structural invariant.

### 8.2 The positive direction: all orders suffice

**Theorem 8.4 (Complete marginal data determines the union).** Let $A, B :
I \to \mathcal{P}_{\mathrm{fin}}(\Omega)$ be two families over the same finite
index set $I$. If for every nonempty $T \subseteq I$ we have
$\bigl|\bigcap_{i \in T} A_i\bigr| = \bigl|\bigcap_{i \in T} B_i\bigr|$, then
$\bigl|\bigcup_{i \in I} A_i\bigr| = \bigl|\bigcup_{i\in I} B_i\bigr|$.

*Proof sketch.* Inclusion–exclusion:
$\bigl|\bigcup_{i \in I} A_i\bigr| = \sum_{\emptyset \ne T \subseteq I}
(-1)^{|T|+1}\bigl|\bigcap_{i \in T}A_i\bigr|$, and the right side depends only
on the hypothesised data. $\square$

For three sets, then, order $3$ suffices and order $2$ does not: the threshold
is sharp *on that example*. The remaining question is whether the threshold is
$3$ in general — perhaps triple intersections always suffice? They do not.

### 8.3 Every order below $k$ is insufficient

**Definition 8.5 (Joint marginals).** For a family $A : I \to
\mathcal{P}(\Omega)$ over a finite ambient $\Omega$, and $T \subseteq I$, write
$$J_A(T) \;=\; \bigcap_{i \in T} A_i \;=\; \{\, x \in \Omega : \forall\, i \in T,\; x \in A_i \,\},$$
with the convention $J_A(\emptyset) = \Omega$. The number $|J_A(T)|$ is the
joint marginal of order $|T|$.

**The construction.** Fix $k \ge 1$ and set
$$\Omega_k \;=\; \mathcal{P}\bigl(\{1,\dots,k\}\bigr) \times \{\texttt{first}, \texttt{second}\},$$
of size $2^{k+1}$: two labelled copies of every subset of the index set. Define
two families indexed by $i \in \{1,\dots,k\}$:
$$\mathrm{Plain}_i \;=\; \bigl\{ (S, \texttt{first}) : i \in S \bigr\},$$
$$\mathrm{Par}_i \;=\; \bigl\{ (S, b) : i \in S,\ |S| \equiv k \!\!\pmod 2 \bigr\}.$$
So the plain family takes one copy of each subset containing $i$, while the
parity family takes *both* copies of each such subset whose size has the same
parity as $k$.

The right way to see the construction is as a *weighted* family on
$\mathcal{P}(\{1,\dots,k\})$. Assign to each subset $S$ a weight $w(S)$ equal to
the number of ground points lying over $S$. Then
$$w_{\mathrm{Plain}}(S) = 1, \qquad w_{\mathrm{Par}}(S) = 1 + (-1)^{k - |S|},$$
so the two families differ by the perturbation $\delta(S) = (-1)^{k-|S|}$. In
this language the joint marginal of order $|T|$ is the *upper sum*
$$|J(T)| \;=\; \sum_{S \supseteq T} w(S) \qquad (T \ne \emptyset),$$
since a ground point over $S$ lies in $\bigcap_{i \in T}$ exactly when
$T \subseteq S$.

**Lemma 8.6 (The perturbation is invisible below the top).** For every
$T \subsetneq \{1,\dots,k\}$,
$$\sum_{S \supseteq T} \delta(S) \;=\; 0 .$$

*Proof sketch.* Supersets of $T$ correspond bijectively to subsets $U$ of the
complement $T^c$, via $S = T \cup U$, with $|S| = |T| + |U|$. Writing
$n = |T^c| = k - |T| \ge 1$,
$$\sum_{S \supseteq T}\delta(S) = \sum_{U \subseteq T^c} (-1)^{k - |T| - |U|}
= \pm\sum_{j=0}^{n} (-1)^{j}\binom{n}{j} = 0$$
by the alternating binomial identity, valid because $n \ge 1$. Concretely: among
the $2^n$ supersets of $T$, exactly $2^{n-1}$ have size of each parity, so the
number of supersets of $T$ of the correct parity is $2^{k - |T| - 1}$ — exactly
half — for every proper $T$. $\square$

**Theorem 8.7 (Marginals of order $< k$ never determine the union).** For every
$k \ge 1$, the two families $\mathrm{Plain}$ and $\mathrm{Par}$ on $\Omega_k$
satisfy:
1. $|J_{\mathrm{Plain}}(T)| = |J_{\mathrm{Par}}(T)|$ for every proper subfamily
   $T \subsetneq \{1,\dots,k\}$ — all joint marginals of order $< k$ agree;
2. $|J_{\mathrm{Plain}}(\{1,\dots,k\})| = 1 \ne 2 = |J_{\mathrm{Par}}(\{1,\dots,k\})|$
   — the top-order marginals differ;
3. $\bigl|\bigcup_i \mathrm{Plain}_i\bigr| \ne \bigl|\bigcup_i \mathrm{Par}_i\bigr|$
   — the unions differ.

Consequently, no functional of the joint marginals of order $< k$ computes the
union of $k$ sets. Combined with Theorem 8.4, the marginal-order threshold for a
family of $k$ sets is **exactly $k$**.

*Proof sketch.* (1) For nonempty proper $T$: by Lemma 8.6 the upper sums of the
two weight functions agree; explicitly $|J_{\mathrm{Plain}}(T)| = 2^{k-|T|}$
(all supersets of $T$, one copy each) and
$|J_{\mathrm{Par}}(T)| = 2 \cdot 2^{k - |T| - 1} = 2^{k-|T|}$ (half the
supersets, two copies each). For $T = \emptyset$ both equal $|\Omega_k|$.

(2) At $T = \{1,\dots,k\}$ the only superset is $S = \{1,\dots,k\}$ itself,
which has the right parity; so the plain family contributes one point and the
parity family two.

(3) The plain family covers $\{(S, \texttt{first}) : S \ne \emptyset\}$, of size
$2^k - 1$, an **odd** number. The parity family covers a set of the form
$X \times \{\texttt{first},\texttt{second}\}$, of size $2|X|$, an **even**
number. Odd $\ne$ even. $\square$

The proof is worth reading twice, because the mechanism is entirely
representation-theoretic in flavour: the perturbation $\delta(S) = (-1)^{k-|S|}$
is the *top Möbius eigenvector* of the Boolean lattice — the unique (up to
scale) function all of whose upper sums vanish except at the top. It is exactly
the signal that low-order marginals are blind to.

**Corollary 8.8 (Ensemble reading).** For every $k$ there are two ensembles of
$k$ hypotheses on a common finite sample space with identical individual error
rates, identical pairwise co-failure rates, and indeed identical $j$-wise
co-failure rates for every $j < k$, whose total error supports have different
sizes. Every diversity metric built from marginals of order $< k$ is blind to a
genuine, constructible mode of ensemble behaviour.

---

## 9. Feeding in design-theoretic marginals: Corrádi and Fisher

We now specialise the second-moment bound to the uniform hypotheses standard in
design theory and in ensemble analysis: a lower bound on the first marginals and
an upper bound on the second.

**Theorem 9.1 (Corrádi's inequality, division-free).** Let $|I| = k$, and
suppose $|A_i| \ge m$ for all $i \in I$ and $|A_i \cap A_j| \le t$ for all
$i \ne j$ in $I$. Then
$$k\,m^2 \;\le\; \Bigl|\bigcup_{i\in I} A_i\Bigr| \cdot \bigl(m + (k-1)\,t\bigr),
\qquad\text{i.e.}\qquad
\Bigl|\bigcup_{i \in I} A_i\Bigr| \;\ge\; \frac{k\,m^2}{m + (k-1)\,t} .$$

*Proof sketch.* Set $N = |U|$ and $\Sigma_1 = \sum_i |A_i| \ge km$. Theorem 5.2
gives $\Sigma_1^2 \le N \cdot \Sigma_2^{\mathrm{tot}} = N(\Sigma_1 + \Sigma_2)$,
and $\Sigma_2 \le k(k-1)t$. Hence with $c = k(k-1)t$ we have
$\Sigma_1^2 \le N(\Sigma_1 + c)$. The function $S \mapsto S^2/(S + c)$ is
nondecreasing, so the same inequality holds for any $u \le \Sigma_1$; taking
$u = km$ yields $k^2m^2 \le N(km + k(k-1)t) = kN(m + (k-1)t)$, and dividing by
$k$ gives the claim. (The monotonicity step is stated division-free: if
$S^2 \le N(S+c)$ and $u \le S$ then $u^2 \le N(u+c)$, proved by clearing
denominators over $\mathbb{Z}$.) $\square$

**Theorem 9.2 (Fisher-type counting bound).** Under the hypotheses of Theorem
9.1, with $t \le m$ and $N = |U|$,
$$k\,\bigl(m^2 - N t\bigr) \;\le\; N\,(m - t) .$$
In the *design regime* $Nt < m^2$ this reads $k \le N(m-t)/(m^2 - Nt)$: large,
nearly disjoint sets cannot be numerous.

*Proof sketch.* Expand $N(m + (k-1)t) + Nt = Nm + k(Nt)$ and combine with
Theorem 9.1 to obtain $km^2 + Nt \le Nm + k(Nt)$; rearranging gives
$k(m^2 - Nt) \le N(m-t)$ (over the integers, with the natural-number subtraction
handled by the hypothesis $t \le m$). $\square$

Theorem 9.2 is the counting principle behind Fisher's inequality in design
theory (blocks of a $2$-design meeting in $\lambda$ points cannot be too
numerous) and behind Plotkin-type bounds in coding theory (codewords with
bounded pairwise agreement cannot be too numerous).

### 9.1 Sharpness at both ends of the correlation scale

The next two results show that Theorem 9.1 cannot be improved as a function of
the data $(k, m, t)$ alone, because it is *attained* at the two extremes.

**Theorem 9.3 (Tightness at $t = 0$).** If $|A_i| = m$ exactly for every $i$ and
the family is pairwise disjoint, then $k m^2 = |U| \cdot (m + (k-1)\cdot 0)$.

*Proof.* $|U| = km$ by disjointness, so the right side is $km \cdot m = km^2$.
$\square$

**Theorem 9.4 (Tightness at $t = m$).** If $I$ is nonempty and $A_i = B$ for
every $i$, where $|B| = m$, then $k m^2 = |U| \cdot (m + (k-1)m)$.

*Proof.* $|U| = |B| = m$, so the right side is $m \cdot km = km^2$. $\square$

**Corollary 9.5.** No bound on $|U|$ expressible as a function of $(k, m, t)$
alone can improve on Theorem 9.1 at the endpoints $t \in \{0, m\}$. In the
interior, the triangle of Definition 8.1 shows tightness at
$(k,m,t) = (3,2,1)$ as well, while the sunflower — with the *same* $(k,m,t)$ —
is strictly above the bound. Thus the bound is exactly the pointwise minimum of
the union over its marginal class at those parameters.

**Theorem 9.6 (Ensemble coverage bound).** Let $H$ be a finite set of hypotheses
on a finite sample space, each failing on at least $m$ samples, with any two
failing simultaneously on at most $t$ samples. Then the set of samples on which
the ensemble is not unanimously correct has size at least
$|H| m^2 / (m + (|H|-1)t)$. In the uncorrelated case $t = 0$ (and $m > 0$) this
strengthens to $|H| \cdot m \le |U|$.

*Proof.* Theorem 9.1 applied to the failure sets; the case $t=0$ is Theorem 9.3's
inequality form. $\square$

---

## 10. Worked numerical data

Every constant quoted in the theory can be checked on small families. We record
three data sets.

### 10.1 The two three-set witnesses

| family | $|A_i|$ | $|A_i\cap A_j|$, $i \ne j$ | $|\bigcap_i A_i|$ | $|U|$ | multiplicity profile | $\Sigma_2$ | $2|D|$ | gap $g$ |
|---|---|---|---|---|---|---|---|---|
| triangle | $2,2,2$ | $1,1,1$ | $0$ | $3$ | $(2,2,2,0)$ | $6$ | $6$ | $0$ |
| sunflower | $2,2,2$ | $1,1,1$ | $1$ | $4$ | $(3,1,1,1)$ | $6$ | $2$ | $12$ |

Identical first and second marginals, different unions: this is Theorem 8.3. The
triangle has $g = 0$ (regular, Corrádi tight, by Theorem 6.6); the sunflower has
$g = 12 > 0$ and its double-collision bound is slack by $4$, precisely because
it carries a point of multiplicity $3$ (Theorem 6.4). Note also that the
Bonferroni defect identity holds in both cases: for the triangle,
$6 + 3 = 3 + 6$; for the sunflower, $6 + (4+0+0+0) = 4 + 6$.

### 10.2 The parity construction

For $k = 1, 2, 3$ the joint marginals of the plain and parity families agree on
every proper $T$ and differ at $T = \{1,\dots,k\}$ ($1$ versus $2$), while the
covers are:

| $k$ | $|U_{\mathrm{Plain}}|$ | $|U_{\mathrm{Par}}|$ |
|---|---|---|
| $1$ | $1$ | $2$ |
| $2$ | $3$ | $2$ |
| $3$ | $7$ | $8$ |

The plain cover is always $2^k - 1$, odd; the parity cover is always even.

### 10.3 A four-set family with mixed multiplicities

A non-regular family of four subsets of an eight-point space with multiplicity
profile $(3,1,3,1,3,1)$ on its six-point cover has $|U| = 6$,
$\Sigma_1 = 12$, $\Sigma_2 = 18$, $2|D| = 6$, gap $g = 6 \cdot 30 - 144 = 36$,
Bonferroni defect $\operatorname{Irr} = 4+0+4+0+4+0 = 12$. Every prediction
checks:

- Defect identity (Theorem 3.1): $12 + 12 = 24 = 6 + 18$. ✓
- Bonferroni (Corollary 3.3): $12 \le 6 + 18 = 24$, slack $12$. ✓
- Sharp Bonferroni (Corollary 4.2): $24 \le 12 + 18 = 30$; the sharp defect is
  $\sum(d-1)(d-2) = 2+0+2+0+2+0 = 6$, and $24 + 6 = 30$. ✓
- Double collision (Theorem 4.5): $6 \le 18$, slack because $d = 3$ occurs. ✓
- Cauchy–Schwarz (Theorem 5.2): $144 \le 6 \cdot 30 = 180$, gap $36$. ✓
- Spread bound (Theorem 7.1): $(3-1)^2 = 4 \le 36$. ✓
- Corrádi (Theorem 9.1) with $m = 3$, $t = 2$: $4\cdot 9 = 36 \le 6\cdot(3 + 3\cdot 2) = 54$. ✓

---

## 11. Applications

**Ensemble design and diversity metrics.** The rigidity theorems give sharp
operational meaning to three folklore heuristics. "Diverse errors are good"
becomes: the union bound is lossless iff errors never co-occur (Theorem 6.3).
"Pairwise diversity is not enough" becomes: pairwise data cannot determine the
error support (Theorem 8.3), and $j$-wise data cannot for any $j < k$ (Theorem
8.7). "Balanced ensembles are extremal" becomes: the second-moment bound is
lossless iff the failure mass is spread perfectly evenly (Theorem 6.6), and this
is stable under perturbation with modulus $\sqrt{g}$ (Theorem 7.1).

**Multiple hypothesis testing.** The classical Bonferroni correction is the
first-order truncation; Theorem 4.1 quantifies the second-order correction's
exact defect. In the regime where no sample triggers three or more rejections —
common when the tests are nearly disjoint in support — the second-order
correction is exactly lossless (Theorem 6.5), so no further refinement is
possible without higher-order data.

**Design theory and coding.** Theorems 9.1 and 9.2 are the standard Corrádi and
Fisher-type counting principles; the contribution here is that they are derived
from the same two moment identities as the Bonferroni machinery, and that
Theorem 6.6 identifies their extremal families as exactly the regular covers,
i.e. as $(k,m,t)$-designs.

**Coverage in randomised algorithms.** A family of "success sets" of $k$
randomised algorithms with individual success mass $\ge m$ and pairwise
correlation $\le t$ covers at least $km^2/(m + (k-1)t)$ inputs; the tightness
results say the estimate cannot be improved without further structural
information.

---

## 12. Discussion and future work

### 12.1 What is settled

Three things fix the starting point for any further work.

*First*, the Bonferroni machinery is an **identity minus an explicit
irregularity functional** — Theorems 3.1 and 4.1. This is a strict strengthening
of the inequalities: the defect is computable from the multiplicity profile, and
it converts "how much did I lose?" from a worst-case question into an exact one.

*Second*, the **extremal classes are exactly three**: pairwise disjoint (the
union bound, Theorem 6.3), multiplicity at most $2$ (the sharp Bonferroni and
double-collision bounds, Theorems 6.4 and 6.5), and regular covers (the
Cauchy–Schwarz/Corrádi bound, Theorem 6.6). Each characterisation is an
if-and-only-if.

*Third*, second-order marginals **never** determine the union (Theorem 8.3), and
more generally marginals of order $< k$ never determine the union of $k$ sets
(Theorem 8.7), while all orders do (Theorem 8.4). The threshold is exactly $k$.

### 12.2 Conjecture 1: marginal-order complexity of the union-bound gap

For every $k$ and every $2 \le r < k$ there should be a constant $c(r) > 0$ such
that two families of $k$ sets agreeing on all marginals of order $\le r$ can
have unions differing by a factor $\ge 1 + c(r)$, with $c(r) \to 0$ as
$r \to k$: the *quantitative* information content of marginal order $r$ should
degrade smoothly, not abruptly.

The key insight is that the perturbation $\delta(S) = (-1)^{k-|S|}$ of Section
8.3 is only the *top* Möbius eigenvector. The whole family of perturbations
supported on the levels above $r$ forms a cone whose extreme rays should control
the achievable ratio, turning the existence statement of Theorem 8.7 into an
extremal problem over the Boolean lattice. Since the construction and the exact
defect identities are already available, the only new ingredient is an
optimisation over a finite-dimensional cone — a computation that can be
evaluated for small $k$ and then proved in general.

### 12.3 Conjecture 2: Corrádi is the exact envelope of the $(k, m, t)$ data

For all $k, m, t$ with $t \le m$ there should exist a family of $k$ sets with
all first marginals exactly $m$ and all second marginals exactly $t$ whose union
has cardinality exactly $\lceil k m^2 / (m + (k-1)t)\rceil$. Consequently
Theorem 9.1 would be not merely a bound but the *pointwise minimum* of the union
over the marginal class.

The key insight is that Theorem 6.6 identifies the extremal families as regular
covers, i.e. as $(k,m,t)$-designs, so the conjecture is exactly an asymptotic
existence statement for such designs — the regime in which modern
design-existence theorems operate. The two extreme cases $t = 0$ and $t = m$ are
already proved tight (Theorems 9.3 and 9.4), and the rigidity theorem tells us
precisely which combinatorial object must be built for intermediate $t$; nothing
else in the argument is missing.

### 12.4 Conjecture 3: a stability dichotomy with an algebraic threshold

Theorem 7.1 bounds the multiplicity spread by $\sqrt{g}$, and Corollary 7.3
shows that $g < 1$ forces exact regularity. We conjecture a genuine *dichotomy*:
there is a function $\gamma(k, |U|)$, growing at most polynomially, such that
every family with $0 < g < \gamma(k, |U|)$ has multiplicity profile within
bounded Hamming distance of a constant profile — i.e. the gap cannot be small
unless the family is a bounded perturbation of a regular cover, with no
intermediate regime of "moderately irregular, moderately small gap" families.
The integrality argument of Corollary 7.3 is the $\gamma = 1$ case; the content
is to push the threshold up to a nontrivial function of the parameters.

### 12.5 Further directions

Several natural extensions suggest themselves.

- **Weighted and measure-theoretic versions.** All moment identities hold
  verbatim with counting measure replaced by an arbitrary finite measure; the
  rigidity statements should become almost-everywhere statements. The
  integrality argument of Corollary 7.3 is the only step that genuinely uses
  counting.
- **Higher factorial moments.** The pattern $(d-1)^2 \to (d-1)(d-2)$ suggests a
  hierarchy: the $r$-th Bonferroni truncation should have defect
  $\sum_x \binom{d(x)-1}{r}$ up to normalisation, tight exactly on families of
  multiplicity $\le r$. Establishing this hierarchy would unify all the
  truncations of inclusion–exclusion under one defect calculus.
- **Algorithmic estimation.** In practice, the multiplicity profile is estimable
  by sampling. Theorem 7.4 then converts profile estimates into certified bounds
  on the union. Quantifying the sample complexity of such a certification is an
  attractive statistical question with immediate ensemble-learning payoff.

---

## 13. Summary of main results

| Result | Statement |
|---|---|
| First moment identity | $\sum_{x \in U} d(x) = \sum_i \lvert A_i\rvert$ |
| Second moment identity | $\sum_{x \in U} d(x)^2 = \sum_{i,j} \lvert A_i \cap A_j\rvert$ |
| Off-diagonal identity | $\sum_{i \ne j}\lvert A_i \cap A_j\rvert = \sum_{x \in U} d(x)(d(x)-1)$ |
| Bonferroni defect identity | $\Sigma_1 + \sum_{x\in U}(d(x)-1)^2 = \lvert U\rvert + \Sigma_2$ |
| Second Bonferroni inequality | $\Sigma_1 \le \lvert U\rvert + \Sigma_2$ |
| Sharp Bonferroni defect identity | $2\Sigma_1 + \sum_{x\in U}(d(x)-1)(d(x)-2) = 2\lvert U\rvert + \Sigma_2$ |
| Sharp Bonferroni inequality | $\Sigma_1 - \sum_{i<j}\lvert A_i\cap A_j\rvert \le \lvert U\rvert$ |
| Double-collision bound | $2\lvert D\rvert \le \Sigma_2$ |
| Cauchy–Schwarz bound | $\Sigma_1^2 \le \lvert U\rvert \cdot \Sigma_2^{\mathrm{tot}}$ |
| Rigidity I | Bonferroni tight $\iff$ pairwise disjoint |
| Rigidity II | Sharp Bonferroni tight $\iff$ double collision tight $\iff$ $d \le 2$ |
| Rigidity III | Cauchy–Schwarz tight $\iff$ regular cover |
| Stability | $(d(x)-d(y))^2 \le g$; and $g < 1 \Rightarrow$ exactly regular |
| Defect–gap link | If $\Sigma_1 = \lvert U\rvert$ then $\lvert U\rvert \cdot \operatorname{Irr} = g$ |
| Corrádi | $km^2 \le \lvert U\rvert(m + (k-1)t)$, tight at $t = 0$ and $t = m$ |
| Fisher-type | $k(m^2 - Nt) \le N(m-t)$ |
| Second-order indeterminacy | No function of first/second marginals gives $\lvert U\rvert$ |
| Marginal-order threshold | Order $< k$ insufficient for $k$ sets; all orders sufficient |
