# Differences, Signed Sums, and the Collapse of the $B_h$ Difference Tower

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We study finite sets of non-negative integers through the coincidences among their *signed* sums,
i.e. among expressions $\sum_{i} \varepsilon_i a_i$ with $\varepsilon_i \in \{+1, -1\}$, and in
particular through their $h$-fold differences $\sum s - \sum t$. Four groups of results are
established.

First, over $\mathbb{N}$ — where subtraction is not available — the Sidon property is equivalent to
injectivity of the integer difference map $(a,b) \mapsto a - b$ off the diagonal. Consequently the
greedy process that refuses a repeated difference and the greedy process that refuses a repeated
sum generate the same sequence, namely the Mian–Chowla sequence, here normalised to start at $0$.

Second, we isolate the exact obstruction to a greedy step. For a candidate $m$ above a Sidon set
$A$, adjunction fails precisely when $m \in \{c + d - b : b,c,d \in A\}$, a set of at most $|A|^3$
integers; for an *unordered* candidate a second, quadratic *halving* obstruction
$\{m : 2m = c+d,\ c,d \in A\}$ appears, and both together are necessary and sufficient. We show the
halving obstruction cannot be dropped, exhibiting a witness of every size $k \ge 2$. We then prove a
**chain rigidity** theorem: any value still admissible for the greedy set of size $n$ exceeds every
element already chosen. Rigidity replaces a per-step summation of windows by one global pigeonhole
and improves the growth bound for the greedy sequence $a(n)$ from $4a(n) \le (n+1)^4$ to
$a(n) \le n^3 + n^2 + n$; combined with the classical counting bound $n(n+1) \le 2a(n)$ this yields
a quadratic–cubic sandwich.

Third, we define, for each $h$, an $h$-fold **difference rigidity** condition $\mathrm{Diff}_h$,
stated additively so that it is meaningful over $\mathbb{N}$, and prove the sandwich
$B_{2h} \Rightarrow \mathrm{Diff}_h \Rightarrow B_h$. We then prove that the sandwich **collapses**:
$\mathrm{Diff}_h$ is *equivalent* to $B_{2h}$, the missing implication coming from the observation
that every $2h$-element multiset splits into two halves of size $h$. In particular
$\mathrm{Diff}_1 = B_2 = \text{Sidon}$, which explains why greedy difference avoidance produces
exactly Sidon sets. The $B_h$ tower is nevertheless strict at every level: the three-element set
$\{0, 1, h+1\}$ is $B_h$ and not $B_{h+1}$.

Fourth, we transport the whole greedy machine up the tower. The failure of a $B_h$ greedy step is a
weighted equation $d\,m + \Sigma_0 = \Sigma_1$ with $1 \le d \le h$; the resulting obstruction set
has at most $h\big((h+1)(|A|+1)^h\big)^2$ elements, chain rigidity holds verbatim at level $h$, and
the greedy $B_h$ sequence satisfies $\binom{n+1}{h} \le h\,a_h(n) + 1$ and
$a_h(n) \le n + h\big((h+1)(n+1)^h\big)^2$: a degree-$h$ lower bound and a degree-$2h$ upper bound.
Along the way we prove the counting bound $\binom{|A|}{h} \le h(N-1)+1$ for a $B_h$ set
$A \subseteq \{0,\dots,N-1\}$, equivalently $(|A|-h+1)^h \le h!\,(h(N-1)+1)$, which reproduces the
$\sqrt N$ order of magnitude at $h = 2$.

**Keywords.** Sidon set, $B_h$ set, Mian–Chowla sequence, greedy algorithm, difference set, signed
sums, additive combinatorics.

---

## 1. Introduction

A finite set of integers is *non-repetitive* if the elementary arithmetic combinations it supports
are all distinct. Which combinations one chooses to make distinct determines a whole family of
conditions. Demanding distinct pairwise sums gives Sidon sets; distinct $h$-fold sums gives $B_h$
sets; distinct pairwise differences gives perfect difference sets. These conditions govern
extremal questions of the form "how many elements can such a set have inside $\{0, \dots, N-1\}$?",
and they arise in applications ranging from radar waveform design and sparse antenna arrays to
error-correcting codes and sequences with prescribed autocorrelation.

This paper is organised around two threads that turn out to be one thread.

**Thread A: greedy construction by difference avoidance.** Grow a set one element at a time, always
adjoining the least value that does not repeat a difference already realised. This is the natural
"ruler" formulation of the Mian–Chowla construction. We show that it coincides with sum-avoidance,
identify the exact finite obstruction to a step, prove that the greedy chain never skips a usable
value, and use that rigidity to obtain a cubic upper bound and a matching-in-form quadratic lower
bound.

**Thread B: the $h$-fold difference hierarchy.** Since the Sidon condition has a difference
formulation, the higher floors $B_h$ should too. We define the $h$-fold rigidity condition
$\mathrm{Diff}_h$, prove that it is sandwiched between $B_{2h}$ and $B_h$, and then prove that the
sandwich is degenerate: $\mathrm{Diff}_h \Leftrightarrow B_{2h}$. Threads A and B meet at $h = 1$,
where the collapse reads $\mathrm{Diff}_1 = B_2$, i.e. exactly the statement that greedy difference
avoidance yields Sidon sets.

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, all sets are finite subsets of $\mathbb{N}$ unless
stated otherwise, $|A|$ denotes cardinality, and multisets are written additively: $s + t$ is the
multiset union, $\sum s$ the sum of the entries of $s$, and $\operatorname{card} s$ the number of
entries counted with multiplicity.

---

## 2. Sums versus differences over the natural numbers

**Definition 2.1 (Sidon set).** A finite set $A$ in a commutative cancellative additive monoid is a
**Sidon set** if for all $a,b,c,d \in A$,
$$a + b = c + d \quad\Longrightarrow\quad (a = c \text{ and } b = d)\ \text{ or }\ (a = d \text{ and } b = c).$$

**Theorem 2.2 (Sums $\Leftrightarrow$ differences).** *Let $A \subseteq \mathbb{N}$ be finite. Then
$A$ is a Sidon set if and only if the map*
$$\delta : A \times A \setminus \Delta \to \mathbb{Z}, \qquad \delta(a,b) = a - b,$$
*is injective, where $\Delta$ is the diagonal.*

*Proof sketch.* ($\Rightarrow$) If $a - b = c - d$ with $a \neq b$ and $c \neq d$, then
$a + d = c + b$; Sidon gives either $(a = c,\ d = b)$, which is the desired conclusion, or
$(a = b,\ d = c)$, which contradicts $a \neq b$.

($\Leftarrow$) Suppose $a + b = c + d$ with all four in $A$. If $a = c$ then $b = d$ and we are done.
Otherwise $a \neq c$ and, from the equation, $d \neq b$; the pairs $(a,c)$ and $(d,b)$ are both
off-diagonal and satisfy $a - c = d - b$, so injectivity forces $a = d$ and $c = b$. $\square$

The content of Theorem 2.2 is that it holds over $\mathbb{N}$, which is not a group: the differences
must be taken in $\mathbb{Z}$, but the Sidon condition is intrinsic to $\mathbb{N}$. The immediate
corollary is that the two greedy algorithms — avoid a repeated sum, avoid a repeated difference —
are the same algorithm.

---

## 3. The obstruction sets and the exact greedy step

**Definition 3.1 (Cubic obstruction).** For finite $A \subseteq \mathbb{N}$ put
$$\mathrm{Bad}(A) = \{\, c + d - b \ :\ b, c, d \in A \,\} \subseteq \mathbb{Z}.$$

**Lemma 3.2.** *An integer $m$ lies in $\mathrm{Bad}(A)$ if and only if adjoining $m$ repeats a
difference of $A$, i.e. there exist $b,c,d \in A$ with $m - c = d - b$. Moreover
$|\mathrm{Bad}(A)| \le |A|^3$.*

*Proof sketch.* The equation $m = c + d - b$ is the equation $m - c = d - b$ rearranged; the bound is
the image of $A^3$ under a map. $\square$

**Theorem 3.3 (Exact ordered step criterion).** *Let $A$ be finite and let $m$ satisfy $a < m$ for
all $a \in A$. Then $A \cup \{m\}$ is a Sidon set if and only if $A$ is a Sidon set and
$m \notin \mathrm{Bad}(A)$.*

*Proof sketch.* Sidon-ness passes to subsets, giving one half of the forward direction, and a
violation $m + b = c + d$ exhibits $m \in \mathrm{Bad}(A)$. Conversely, a violation of Sidon-ness in
$A \cup \{m\}$ must involve $m$ (else $A$ fails); counting occurrences of $m$ on the two sides, the
case where $m$ occurs twice on one side is impossible because $2m > c + d$ for all $c,d \in A$, and
the case where $m$ occurs once on each side cancels; the remaining case is exactly
$m \in \mathrm{Bad}(A)$. $\square$

Because $|\mathrm{Bad}(A)| \le |A|^3$, a valid greedy step always exists within a window of length
$|A|^3 + 1$ above $\max A$; summing these windows over stages gives the quartic bound
$4\,a(n) \le (n+1)^4$ for the greedy sequence defined in §4.

**Definition 3.4 (Halving obstruction).**
$\mathrm{Half}(A) = \{\, m \in \mathbb{N} : 2m = c + d \text{ for some } c,d \in A \,\}$, so that
$|\mathrm{Half}(A)| \le |A|^2$.

**Theorem 3.5 (Exact unordered step criterion).** *Let $A$ be finite and $m \notin A$, with no
ordering hypothesis. Then $A \cup \{m\}$ is a Sidon set if and only if $A$ is a Sidon set,
$m \notin \mathrm{Bad}(A)$ and $m \notin \mathrm{Half}(A)$.*

**Proposition 3.6 (The halving obstruction is necessary, at every size).** *For every $k \ge 2$
there is a Sidon set $A$ with $|A| = k$ and an $m \notin A$ such that $m \notin \mathrm{Bad}(A)$,
$m \in \mathrm{Half}(A)$, and $A \cup \{m\}$ is not Sidon.*

*Proof sketch.* Take $A = 2 \cdot G_k$, the dilate by $2$ of the greedy Sidon set of size $k$, and
$m = 1$. Dilation preserves Sidon-ness. Every element of $\mathrm{Bad}(A)$ is even, so the odd $m$
avoids it; but $1 + 1 = 0 + 2 \in A + A$, so $m \in \mathrm{Half}(A)$ and the insertion fails. The
smallest case is $A = \{0,2\}$, $m = 1$. $\square$

---

## 4. The greedy sequence and chain rigidity

**Definition 4.1.** Let $G_0 = \emptyset$ and, inductively, let
$$a(n) = \min\{\, m \in \mathbb{N} \ :\ (\forall x \in G_n,\ x < m) \text{ and } G_n \cup \{m\} \text{ is Sidon} \,\},
\qquad G_{n+1} = G_n \cup \{a(n)\}.$$
Theorem 3.3 guarantees the minimum exists. Then $|G_n| = n$, each $G_n$ is Sidon, and $a$ is
strictly increasing. The first values are
$$a(0),\dots,a(13) = 0,\ 1,\ 3,\ 7,\ 12,\ 20,\ 30,\ 44,\ 65,\ 80,\ 96,\ 122,\ 147,\ 181,$$
i.e. the Mian–Chowla sequence shifted by one.

**Theorem 4.2 (Chain rigidity).** *For every $n$ and every $m \notin G_n$ such that
$G_n \cup \{m\}$ is a Sidon set, one has $x < m$ for all $x \in G_n$. Equivalently, the greedy
process never skips a usable value.*

*Proof sketch.* Induction on $n$. The case $n = 0$ is vacuous. For $G_{n+1} = G_n \cup \{a(n)\}$,
suppose $m \notin G_{n+1}$ with $G_{n+1} \cup \{m\}$ Sidon. Then $G_n \cup \{m\}$ is Sidon (subsets
of Sidon sets are Sidon), so by induction $m$ exceeds all of $G_n$; hence $m$ was a competitor in
the minimisation that produced $a(n)$, whence $a(n) \le m$, and $m \neq a(n)$ gives $a(n) < m$.
Thus $m$ exceeds every element of $G_{n+1}$. $\square$

**Theorem 4.3 (Global pigeonhole).** *If $A$ is a Sidon set with $|A| = n$, then there exists
$m \le n^3 + n^2 + n$ with $m \notin A$ and $A \cup \{m\}$ Sidon.*

*Proof sketch.* The forbidden values are the at most $n^3$ elements of $\mathrm{Bad}(A)$, the at most
$n^2$ elements of $\mathrm{Half}(A)$, and the $n$ elements of $A$ itself: at most $n^3 + n^2 + n$
values, so one of the $n^3 + n^2 + n + 1$ integers in $\{0, 1, \dots, n^3+n^2+n\}$ survives.
Theorem 3.5 makes any survivor admissible. $\square$

**Corollary 4.4 (Cubic upper bound).** $a(n) \le n^3 + n^2 + n$.

*Proof sketch.* Apply Theorem 4.3 to $G_n$ to get an admissible $m \le n^3 + n^2 + n$. By chain
rigidity $m$ exceeds all of $G_n$, so $m$ is a competitor in the minimisation defining $a(n)$, hence
$a(n) \le m$. $\square$

This is the point of rigidity: without it one must add a window per stage, giving degree $4$; with
it one pigeonhole over a single interval suffices, giving degree $3$.

**Theorem 4.5 (Quadratic lower bound).** $n(n+1) \le 2\,a(n)$.

*Proof sketch.* $G_{n+1}$ is a Sidon set of $n+1$ elements contained in $\{0, \dots, a(n)\}$. Its
$(n+1)n$ ordered differences of distinct elements are pairwise distinct and non-zero, and all lie in
$[-a(n), a(n)]$, an interval containing $2a(n)$ non-zero integers; hence $n(n+1) \le 2a(n)$.
$\square$

**Corollary 4.6 (Sandwich).** $\tfrac{n(n+1)}{2} \le a(n) \le n^3 + n^2 + n$.

Numerically $a(13) = 181$ against bounds $91$ and $2379$, suggesting the upper side is closer to the
truth. The obstruction to improving the exponent is not the size of $\mathrm{Bad}(A)$ — which really
is of order $|A|^3$ — but its *dispersion*: one would need to show it covers an interval of length
$\asymp \max A$ rather than clustering.

**Proposition 4.7 (Perfection, briefly).** *$G_3 = \{0,1,3\}$ is a perfect difference set modulo
$7$: every non-zero residue mod $7$ is realised by a difference of two of its elements.
$G_4 = \{0,1,3,7\}$ is not a perfect difference set modulo $13$: the residue $5$ is not realised.*

Thus greedy matches the algebraic (Singer) construction for exactly one step.

---

## 5. The $B_h$ tower and its difference layers

Throughout this section $M$ is a commutative cancellative additive monoid (in the applications
$M = \mathbb{N}$) and $A \subseteq M$ is finite.

**Definition 5.1 ($B_h$ set).** $A$ is a **$B_h$ set** if for all multisets $s, t$ with entries in
$A$ and $\operatorname{card} s = \operatorname{card} t = h$,
$$\sum s = \sum t \quad\Longrightarrow\quad s = t .$$

**Definition 5.2 ($h$-fold difference rigidity).** $A$ satisfies $\mathrm{Diff}_h$ if for all
multisets $s, t, s', t'$ with entries in $A$, each of cardinality $h$,
$$\sum s + \sum t' = \sum s' + \sum t \quad\Longrightarrow\quad s + t' = s' + t .$$

The hypothesis is the additive rendering of $\sum s - \sum t = \sum s' - \sum t'$, and the
conclusion is the additive rendering of $s - t = s' - t'$ in the free abelian group on $A$; the
additive form makes the definition meaningful over $\mathbb{N}$, where subtraction is truncated. Over
a group the two forms are literally equivalent.

**Proposition 5.3 (Basic properties).**
1. Every $A$ is a $B_1$ set.
2. $B_h$-ness is inherited by subsets.
3. (*Antitonicity*) If $A$ is $B_h$ and $1 \le k \le h$, then $A$ is $B_k$.

*Proof sketch of (3).* Given $s, t$ of size $k$ with equal sums, pick any $a \in A$ (the multisets
supply one since $k \ge 1$) and pad both with $h-k$ copies of $a$. The padded multisets have size
$h$ and equal sums, so they are equal; cancelling the $h-k$ copies of $a$ gives $s = t$. $\square$

**Theorem 5.4 ($B_2$ is Sidon).** *$A$ is a $B_2$ set if and only if $A$ is a Sidon set.*

*Proof sketch.* A multiset of size $2$ is an unordered pair $\{a,b\}$, and equality of multisets
$\{a,b\} = \{c,d\}$ is exactly the disjunction in Definition 2.1. $\square$

**Theorem 5.5 ($\mathrm{Diff}_1$ is Sidon).** *$A$ satisfies $\mathrm{Diff}_1$ if and only if $A$ is
a Sidon set.* This is the abstract form of "all differences $a - b$ are distinct".

### 5.1 The sandwich

**Theorem 5.6 ($B_{2h} \Rightarrow \mathrm{Diff}_h$).** *If $A$ is a $B_{2h}$ set then $A$ satisfies
$\mathrm{Diff}_h$.*

*Proof sketch.* Given $s,t,s',t'$ of size $h$ with $\sum s + \sum t' = \sum s' + \sum t$, the
multisets $s + t'$ and $s' + t$ have entries in $A$, cardinality $2h$, and equal sums. $B_{2h}$
gives $s + t' = s' + t$. $\square$

**Theorem 5.7 ($\mathrm{Diff}_h \Rightarrow B_h$).** *If $A$ satisfies $\mathrm{Diff}_h$ then $A$ is
a $B_h$ set.*

*Proof sketch.* Let $s,t$ have size $h$ and $\sum s = \sum t$. Apply $\mathrm{Diff}_h$ to the
quadruple $(s, t, t, s)$: the hypothesis $\sum s + \sum s = \sum t + \sum t$ holds, so
$s + s = t + t$, and cancellation in the multiset monoid gives $s = t$. $\square$

Together: $B_{2h} \Rightarrow \mathrm{Diff}_h \Rightarrow B_h$, apparently placing a new layer
strictly between two floors of the tower.

### 5.2 The collapse

**Lemma 5.8 (Splitting).** *For every $k$ and every multiset $u$ with
$k \le \operatorname{card} u$ there exist multisets $s, t$ with $u = s + t$ and
$\operatorname{card} s = k$.*

*Proof sketch.* Induction on $k$: peel off one entry at a time. $\square$

**Theorem 5.9 (Collapse).** *$A$ satisfies $\mathrm{Diff}_h$ if and only if $A$ is a $B_{2h}$ set.*

*Proof sketch.* One direction is Theorem 5.6. Conversely, assume $\mathrm{Diff}_h$ and let $u, v$
have entries in $A$, cardinality $2h$, and $\sum u = \sum v$. By Lemma 5.8 write $u = s + t'$ and
$v = s' + t$ with $\operatorname{card} s = \operatorname{card} s' = h$; then automatically
$\operatorname{card} t = \operatorname{card} t' = h$. The hypothesis $\sum u = \sum v$ reads
$\sum s + \sum t' = \sum s' + \sum t$, so $\mathrm{Diff}_h$ gives $s + t' = s' + t$, i.e. $u = v$.
$\square$

The intermediate layer therefore does not exist: the difference hierarchy is the even part of the
sum hierarchy, with no new floors. Two consequences deserve emphasis.

*Explanatory.* At $h = 1$ the collapse says $\mathrm{Diff}_1 = B_2$, which is precisely why the
greedy difference process of §4 produces exactly Sidon sets — not a coincidence of small parameters
but an identity of conditions.

*Algorithmic.* To construct a $B_{2h}$ set greedily, it suffices to avoid repeated $h$-fold
differences rather than repeated $2h$-fold sums. The two tests are logically equivalent, but the
first inspects a strictly smaller family of coincidences: quadruples of size-$h$ multisets whose
signed sums collide, rather than all pairs of size-$2h$ multisets.

### 5.3 Strictness of the tower

**Theorem 5.10 (Three points separate consecutive floors).** *For every $h \ge 1$, the set
$T_h = \{0, 1, h+1\} \subseteq \mathbb{N}$ is a $B_h$ set and is not a $B_{h+1}$ set.*

*Proof sketch.* Write $N = h+1 \ge 2$. A multiset $s$ with entries in $\{0,1,N\}$ is determined by
the multiplicities $(c_0, c_1, c_N)$; its cardinality is $c_0 + c_1 + c_N$ and its sum is
$c_1 + N c_N$. If $\operatorname{card} s = h$ then $c_1 \le h < N$, so $c_1$ is a base-$N$ digit and
the equation $c_1 + N c_N = c_1' + N c_N'$ forces $c_1 = c_1'$ and $c_N = c_N'$; the cardinality
constraint then forces $c_0 = c_0'$, so $s = s'$. This proves $B_h$. For the failure at level
$h+1$, take
$$s = \underbrace{\{1, 1, \dots, 1\}}_{h+1}, \qquad t = \{h+1\} \cup \underbrace{\{0, \dots, 0\}}_{h},$$
two distinct multisets of size $h+1$ with the same sum $h+1$. $\square$

The example is minimal in two senses: it has three points, and the single failing relation at level
$h+1$ is the carry $1 + 1 + \dots + 1 = (h+1)$. Deleting either non-zero point leaves $\{0,1\}$ or
$\{0, h+1\}$, which are $B_k$ for every $k$.

**Corollary 5.11 (Strictness of both towers).** *For every $h \ge 1$ there is a set that is $B_h$ but
not $B_{h+1}$; and there is a set satisfying $\mathrm{Diff}_h$ but not $\mathrm{Diff}_{h+1}$ (take
$T_{2h}= \{0, 1, 2h+1\}$ and use Theorem 5.9 with antitonicity).*

At $h = 2$: $\{0,1,3\}$ is Sidon but not $B_3$, since $0 + 0 + 3 = 1 + 1 + 1$.

### 5.4 A counting bound for $B_h$ sets

**Theorem 5.12.** *Let $1 \le h$ and let $A \subseteq \{0, 1, \dots, N-1\}$ be a $B_h$ set. Then*
$$\binom{|A|}{h} \ \le\ h(N-1) + 1 .$$

*Proof sketch.* Map each $h$-element *subset* of $A$ to its sum. Distinct subsets are distinct
multisets of size $h$, so by $B_h$-ness their sums differ: the map is injective. Its image lies in
$\{0, 1, \dots, h(N-1)\}$, a set of $h(N-1)+1$ elements. Compare cardinalities. $\square$

**Corollary 5.13 (Usable form).** *If moreover $h \le |A|$, then*
$$(|A| - h + 1)^h \ \le\ h!\,\big(h(N-1) + 1\big), \qquad\text{i.e.}\qquad |A| \ \lesssim\ (h!\,h\,N)^{1/h} + h .$$

*Proof sketch.* $\binom{k}{h} = k^{\underline{h}}/h!$ where $k^{\underline{h}}$ is the falling
factorial, and $(k-h+1)^h \le k^{\underline{h}}$ for $h \le k$ by comparing factors term by term.
$\square$

For $h = 2$ this gives $|A| \lesssim \sqrt{2N}$, the classical Erdős–Turán order of magnitude.

---

## 6. Greedy $B_h$ sets: weighted obstructions and a degree-$2h$ bound

We now lift §§3–4 to arbitrary $h$. Fix $h \ge 1$ and $A \subseteq \mathbb{N}$ finite.

**Definition 6.1 (Bounded sumsets).** Let $kA$ denote the set of sums of exactly $k$ elements of $A$
(with repetition), and let $S_h(A) = \bigcup_{k \le h} kA$ be the set of all sums of at most $h$
elements. Then $|kA| \le |A|^k$ and
$$|S_h(A)| \ \le\ (h+1)\,(|A|+1)^h .$$

**Definition 6.2 (Weighted obstruction).**
$$\mathrm{Bad}_h(A) = \{\, m \in \mathbb{N} \ :\ \exists\, d \in \{1,\dots,h\},\ \exists\, x, y \in S_h(A),\ d\,m + x = y \,\}.$$
Since $m$ is determined by $(d, x, y)$ through $m = (y-x)/d$,
$$|\mathrm{Bad}_h(A)| \ \le\ h\,|S_h(A)|^2 \ \le\ h\big((h+1)(|A|+1)^h\big)^2 .$$

**Theorem 6.3 (Greedy step at level $h$).** *If $A$ is a $B_h$ set and $m \notin \mathrm{Bad}_h(A)$,
then $A \cup \{m\}$ is a $B_h$ set. No ordering hypothesis on $m$ is required.*

*Proof sketch.* Let $s, t$ be multisets of size $h$ over $A \cup \{m\}$ with equal sums. Split each
into its $m$-part and its $A$-part: $s = j\cdot\{m\} + s_0$ and $t = i\cdot\{m\} + t_0$ where
$j, i$ are the multiplicities of $m$ and $s_0, t_0$ are multisets over $A$ of sizes $h - j$,
$h - i$.
- If $j = i$, cancelling $j$ copies of $m$ leaves $\sum s_0 = \sum t_0$ with $s_0, t_0$ of the same
  size $h - j \le h$; if $h - j \ge 1$, antitonicity (Proposition 5.3) applied to $A$ gives
  $s_0 = t_0$ and hence $s = t$, while if $h = j$ both multisets are $h$ copies of $m$.
- If $j \neq i$, say $j > i$, cancelling $i$ copies of $m$ gives $d\,m + \sum s_0 = \sum t_0$ with
  $d = j - i \in \{1, \dots, h\}$ and $\sum s_0, \sum t_0 \in S_h(A)$ — exactly membership of $m$ in
  $\mathrm{Bad}_h(A)$, contrary to hypothesis. $\square$

The obstruction set is honestly an over-count: it is sufficient for safety, not necessary for
failure, since not every triple $(d,x,y)$ arises from multisets of admissible sizes. (For $h = 2$
and $m$ above $A$, the case $d = 2$ is impossible, which is why the ordered Sidon criterion of
Theorem 3.3 is an exact biconditional with a single cubic obstruction.)

**Definition 6.4 (Greedy $B_h$ sequence).** With $G^{(h)}_0 = \emptyset$, let $a_h(n)$ be the least
$m$ exceeding all elements of $G^{(h)}_n$ such that $G^{(h)}_n \cup \{m\}$ is $B_h$, and set
$G^{(h)}_{n+1} = G^{(h)}_n \cup \{a_h(n)\}$. Theorem 6.3 shows the minimum exists. Then
$|G^{(h)}_n| = n$, each $G^{(h)}_n$ is $B_h$, and $a_h$ is strictly increasing. Numerically,
$$a_3 : 0,\ 1,\ 4,\ 13,\ 32,\ 71,\ 124,\ 218,\ 375, \qquad a_4 : 0,\ 1,\ 5,\ 21,\ 55,\ 153,\ 368,\ 856,$$
the classical greedy $B_3$ and $B_4$ sequences shifted by one.

**Theorem 6.5 (Chain rigidity at level $h$).** *If $m \notin G^{(h)}_n$ and $G^{(h)}_n \cup \{m\}$ is
$B_h$, then $m$ exceeds every element of $G^{(h)}_n$.*

*Proof sketch.* Verbatim the induction of Theorem 4.2, with "subsets of $B_h$ sets are $B_h$" in
place of the corresponding fact for Sidon sets. The argument uses only (i) closure of the property
under subsets, (ii) minimality of each earlier choice; it is therefore a general principle about
greedy chains. $\square$

**Theorem 6.6 (Degree-$2h$ upper bound).**
$$a_h(n) \ \le\ n + h\big((h+1)(n+1)^h\big)^2 .$$

*Proof sketch.* Among the $n + h((h+1)(n+1)^h)^2 + 1$ integers in
$\{0, \dots, n + h((h+1)(n+1)^h)^2\}$, at most $n$ lie in $G^{(h)}_n$ and at most
$h((h+1)(n+1)^h)^2$ lie in $\mathrm{Bad}_h(G^{(h)}_n)$; a survivor $m$ exists and is admissible by
Theorem 6.3. By rigidity (Theorem 6.5) $m$ exceeds all of $G^{(h)}_n$, so it competes in the
minimisation defining $a_h(n)$. $\square$

Without rigidity one accumulates one window per stage and obtains
$a_h(n) \le (n+1)\big(h((h+1)(n+1)^h)^2 + 1\big)$, of degree $2h+1$; the degree recovered is exactly
the one lost to per-step accumulation. For $h = 2$ the generic bound specialises to
$a_2(n) \le n + 18(n+1)^4$, weaker than the dedicated cubic bound of Corollary 4.4 — a quantitative
measure of what the Sidon-specific analysis buys.

**Theorem 6.7 (Degree-$h$ lower bound).** $\displaystyle \binom{n+1}{h} \le h\,a_h(n) + 1$.

*Proof sketch.* $G^{(h)}_{n+1}$ is a $B_h$ set of $n+1$ elements contained in
$\{0, \dots, a_h(n)\}$; apply Theorem 5.12 with $N = a_h(n)+1$. $\square$

**Corollary 6.8 (Sharp sandwich).**
$$\binom{n+1}{h} - 1 \ \le\ h\,a_h(n) \qquad\text{and}\qquad a_h(n) \ \le\ n + h\big((h+1)(n+1)^h\big)^2 .$$

The gap in exponent is a factor of roughly two. Numerically the truth appears to sit near degree
$2h-1$; for $h = 2$ this is consistent with the empirical $n^3$ behaviour of the Mian–Chowla
sequence.

---

## 7. Algorithms

Three algorithms follow directly from the theory.

**A1. Greedy Sidon set by difference avoidance.** Maintain a set $A$ and the set $D$ of realised
differences. For $m = 0, 1, 2, \dots$: accept $m$ if $\{m - a : a \in A\} \cup \{a - m : a \in A\}$
is disjoint from $D$ and has no internal repetition; on acceptance, add $m$ to $A$ and the new
differences to $D$. Testing a candidate costs $O(|A|)$ hash operations, and by Corollary 4.4 the
$n$-th element is found after $O(n^3)$ candidates, so producing $n$ terms costs
$O(n^4)$ operations. By Theorem 2.2 the identical output is obtained by tracking sums instead.

**A2. Obstruction-set greedy step.** Given a Sidon set $A$ with $|A| = n$, form
$\mathrm{Bad}(A)$ ($O(n^3)$) and $\mathrm{Half}(A)$ ($O(n^2)$) and return the least
$m \in \{0, \dots, n^3+n^2+n\}$ avoiding both and not in $A$. Theorem 4.3 guarantees success, and
Theorem 3.5 guarantees correctness. This variant makes the pigeonhole explicit and is the direct
computational shadow of the cubic bound.

**A3. Collapse verifier.** To decide $\mathrm{Diff}_h$ for a finite $A$, note that $s + t' = s' + t$
is equivalent to equality of the *formal differences* $s - t$ and $s' - t'$ in the free abelian
group on $A$. Hence $\mathrm{Diff}_h$ holds iff the map $(s,t) \mapsto \sum s - \sum t$, defined on
pairs of size-$h$ multisets, is injective on formal differences. Building a hash table keyed by
$\sum s - \sum t$ and valued by the canonical form of $s - t$ decides the condition in
$O\!\big(\binom{|A|+h-1}{h}^2 \cdot h\big)$ time, and comparing the outcome with a direct $B_{2h}$
test is a complete numerical audit of Theorem 5.9 on small inputs.

---

## 8. Discussion

**What collapses and why.** The reason the difference tower is not new is structural rather than
computational: a signed condition becomes an unsigned condition by moving negative terms to the
other side of the equation, and the only invariant that survives the move is the total positive
mass. In the case at hand, $s - t = s' - t'$ and $s + t' = s' + t$ are the same statement, and the
sizes add: $h + h = 2h$. The interesting content is that the converse direction is available too,
which requires the elementary but essential fact that a $2h$-element multiset can always be cut
into two halves of size $h$.

**What rigidity is.** Chain rigidity is not a fact about Sidon sets. Its proof uses only that the
property is inherited by subsets and that each greedy choice is a minimum; it therefore holds for
any downward-closed property and any greedy chain built by least-admissible extension. Its
consequence — replacing a sum of per-step windows by a single pigeonhole — costs nothing and buys a
full degree in every growth bound we considered.

**Where the remaining slack is.** For $h = 2$, the cubic upper bound is precisely the strength of
*counting* $\mathrm{Bad}(A)$; the empirical growth of the Mian–Chowla sequence is also close to
cubic, so the counting is not obviously wasteful, but a matching lower bound would need a dispersion
statement: that $\mathrm{Bad}(A)$ spreads over an interval of length $\asymp \max A$ instead of
clustering. For general $h$ the situation is the reverse: the degree-$h$ counting lower bound is the
sharp side and the degree-$2h$ upper bound is far off.

**Applications.** Sidon and $B_h$ sets are the combinatorial backbone of several engineering
constructions: sparse antenna and sonar arrays (where distinct pairwise distances mean unambiguous
direction finding), optical orthogonal codes and frequency-hopping patterns (where distinct
differences control cross-correlation), and Golomb rulers in radio astronomy. The collapse theorem
has a practical reading in this setting: certifying that a design has no repeated $h$-fold
difference is exactly certifying the $B_{2h}$ property, so a designer may choose whichever of the two
tests is cheaper — and the difference test inspects a strictly smaller family of coincidences.

---

## 9. Future work

1. **Dispersion barrier for greedy Sidon growth.** Conjecture: $a(n) = \Theta(n^3)$, i.e. there is
   $c > 0$ with $a(n) \ge c\,n^3$ for large $n$, so the cubic bound is tight in order of magnitude.
   Since the cubic upper bound is exactly the strength of counting $\mathrm{Bad}(A)$, a matching
   lower bound must be a dispersion statement: the obstruction set must be shown to spread over an
   interval of length $\asymp \max A$ rather than cluster, and the greedy rule should force the
   spreading because each new element is chosen minimal. The unordered criterion of Theorem 3.5
   makes the obstruction a genuine subset of an interval, so the question reduces to counting
   collisions $c + d - b = c' + d' - b'$, itself a Sidon-type condition.

2. **A collapse dictionary for general weights.** Conjecture: the collapse
   $\mathrm{Diff}_h \Leftrightarrow B_{2h}$ is the only collapse. For an integer weight vector $w$,
   consider the class of sets on which $\sum_i w_i x_i$ has no non-trivial coincidence. The
   conjecture is that this class depends on $w$ only through the multiset $\{|w_i|\}$ together with
   $\sum_{w_i > 0} w_i$, and that every such class either equals some $B_k$ class or lies strictly
   between two consecutive ones. The heuristic is again that a signed condition is an unsigned
   condition after moving negative terms across, so the total positive mass is the only surviving
   invariant; $\mathrm{Diff}_h \Leftrightarrow B_{2h}$ is the case
   $w = (1,\dots,1,-1,\dots,-1)$.

3. **Closing the exponent gap up the tower.** Between the degree-$h$ counting lower bound and the
   degree-$2h$ pigeonhole upper bound, the data for $h = 3, 4$ suggest degree $2h-1$. Identifying
   the correct exponent — even conjecturally, with a heuristic for the constant — would clarify
   whether greedy $B_h$ sets are asymptotically optimal or lose a polynomial factor.

4. **Sharper step criteria at level $h$.** The weighted obstruction $\mathrm{Bad}_h$ is sufficient
   but not necessary: not every triple $(d, x, y)$ comes from multisets of admissible sizes.
   Determining the exact obstruction — the analogue of the biconditional Theorem 3.5 — would tighten
   the pigeonhole and possibly the exponent.

5. **Perfection beyond the first step.** The greedy set is a perfect difference set modulo $7$ at
   size $3$ and fails modulo $13$ at size $4$. Is there any larger size at which the greedy set is
   perfect, or is size $3$ the last?
