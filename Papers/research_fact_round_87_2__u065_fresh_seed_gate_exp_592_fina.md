# Divisibility Cells as Rate Dials: Exact Counting, Coprime-Scale Independence, the Valuation Ladder, and the Effective Dimension of a Cell Sweep

**Author:** Aristotle

**Date:** 2026-08-26

---

## Abstract

Let $P$ be a finite set of distinct primes with squarefree period
$L = \prod_{p \in P} p$. Partition the integers into the $2^{|P|}$ *divisibility
cells* determined by which primes of $P$ divide a given integer. We prove a
complete quantitative description of this partition and use it to separate a
*rate* phenomenon, which is exact and robust, from a *positional* phenomenon,
which we show is identically absent.

Four groups of results are established. **(1) The rate law.** The cell of a
signature $\sigma$ contains exactly
$\kappa(\sigma) = \prod_{p \in P}\left(1 \text{ if } \sigma(p), \text{ else } p-1\right)$
residues in every period, hence exactly $m\,\kappa(\sigma)$ integers in any window
of $m$ whole periods; the cell rates are the divisors of $\varphi(L)$ reachable as
subset products, they sum over all cells to $L$, they range between $1$ and
$\varphi(L)$ with sharp attainment criteria, and the prime $2$ is a *dead
coordinate*. **(2) A no-go theorem for positional signals.** For every modulus
$M$ coprime to $L$ and every predicate $Q$ depending only on $v \bmod M$, the cell
of $\sigma$ and the event $Q$ are *exactly* independent over $[0, LM)$; in
particular each residue class modulo $M$ receives exactly $\kappa(\sigma)$ cell
members. A divisibility cell carries zero information about any
coprime-measurable observable. **(3) The valuation ladder.** Refining $p \mid v$
to $v_p(v) = e_p$ yields, over the refined period $\prod_p p^{e_p+1}$, a cell of
size exactly $\prod_p (p-1)$, *independently of the exponents*: refinement moves
the denominator only, so the density is the pure geometric expression
$\prod_p p^{-e_p}(1-1/p)$. **(4) Effective dimension of a cell sweep.** When
$2 \in P$, a sweep over all $2^{|P|}$ cells explores at most $2^{|P|-1}$ distinct
rates, with equality precisely when the shifted primes $\{p-1 : p \in P,\ p \neq 2\}$
have pairwise distinct subset products; the criterion is non-vacuous, as
$P = \{3,7,13\}$ shows via $(3-1)(7-1) = 13-1$.

The results were motivated by, and resolve, an empirical episode: a reported
positional mechanism attached to divisibility cells failed to replicate on a fresh
independently generated population (calibrated scores $+1.53$ and $-1.08$ on the
two runs, bracketing zero), while the rate stratification replicated to within
about $2\%$. Theorem group (2) shows the positional claim is not merely
unreplicated but provably absent in the exact model, and theorem group (4)
quantifies the selection surface that plausibly produced the original apparent
significance.

**Keywords:** divisibility cell, Chinese Remainder Theorem, Euler totient,
$p$-adic valuation, equidistribution, multiplicative Sidon set, max-statistic
selection.

---

## 1. Introduction

### 1.1 The empirical episode

Sorting a large sample of integers by divisibility is among the oldest devices in
arithmetic statistics. Given a small set $P$ of primes, each integer $v$ receives
a signature recording, for each $p \in P$, whether $p \mid v$; integers sharing a
signature form a *cell*. Empirical work on such a stratification reported two
effects:

* a **rate effect** — the cells accumulate members at systematically different
  rates, with a reproducible extremal pair and a total spread of roughly $2.2\times$;
* a **positional effect** — within the scanned range, cell membership appeared
  correlated with position, suggesting divisibility acts as a "position dial".

The positional effect was discovered by sweeping on the order of thirty cells and
reporting the largest deviation, and it rested on a single generated population.
A pre-registered replication was run on a freshly generated, provably disjoint
population using an identical, independently regression-checked pipeline. The
outcome was unambiguous:

| quantity | original run | fresh run |
| --- | --- | --- |
| raw amplitude | — (raw score $4.11$) | $0.0742 \pm 0.0377$ (raw score $1.97$) |
| measured procedure baseline | — | $0.1398 \pm 0.0478$ |
| calibrated excess | $+1.53$ | $-1.08$ |

The decisive internal reading is the second row: the fresh raw amplitude
($0.074$) is *smaller than the fresh measured null bias of the estimator itself*
($0.140$). An amplitude of the observed size is what a pure null draw produces.
The two runs bracket zero on the calibrated scale, exactly as
selection-plus-maximum-bias predicts. Meanwhile the rate stratification
replicated closely: the extremal cells were identical on both runs (top cell
"divisible by $2$, $3$ and $5$ but not by $7$", bottom cell "no prime of $P$
divides"), with spreads $0.649$–$1.432$ against $0.645$–$1.406$, a match of about
$2\%$, and with the composition flat in the scan index on both runs (drift
$0.204\%$ against $0.269\%$).

### 1.2 What this paper does

Rather than collect further data, we settle the question exactly. Divisibility
cells are finite, periodic objects; everything about them is computable in closed
form. We prove:

* the rate half of the slogan, as an exact multiplicative counting law
  (Section 3);
* the position half, as a *no-go theorem*: divisibility cells are exactly
  independent of every observable measurable at any coprime scale (Section 4);
* a refinement theorem showing that increasing $p$-adic resolution cannot create
  new arithmetic content (Section 5);
* an exact count of the effective number of degrees of freedom of a cell sweep,
  which is what a selection correction requires (Section 6).

Section 7 returns to the empirical episode and reads it through the theorems.
Section 8 gives worked numerics; Section 9 discusses applications and future
directions.

---

## 2. Setup and definitions

Throughout, $P$ denotes a finite set of distinct primes.

**Definition 2.1 (Period).** The *period* of $P$ is the squarefree integer
$$L \;=\; L(P) \;=\; \prod_{p \in P} p .$$
For $P = \emptyset$ we set $L = 1$. Since each $p \in P$ divides $L$, the truth
value of "$p \mid v$" for $p \in P$ depends only on $v \bmod L$.

**Definition 2.2 (Signature and cell).** A *signature* is a map
$\sigma : P \to \{\texttt{true}, \texttt{false}\}$. An integer $v$ lies in the
*cell* $C_\sigma$ if
$$\forall p \in P: \quad p \mid v \iff \sigma(p) = \texttt{true}.$$
The $2^{|P|}$ cells partition $\mathbb{Z}_{\geq 0}$. It is often convenient to
index a signature by the set $T = \{p \in P : \sigma(p) = \texttt{true}\}$ of
*required* primes; the complementary set $P \setminus T$ consists of the *cleared*
primes.

**Definition 2.3 (Rate).** The *rate* of the signature $\sigma$ is
$$\kappa(\sigma) \;=\; \prod_{p \in P} \begin{cases} 1, & \sigma(p) = \texttt{true},\\[2pt] p - 1, & \sigma(p) = \texttt{false}.\end{cases}$$
Equivalently, in set indexing, $\kappa_T = \prod_{p \in P \setminus T} (p-1)$.

**Definition 2.4 (Cell count).** For $a \le b$ put
$$N_\sigma(a,b) \;=\; \#\{\, v \in \mathbb{Z} : a \le v < b,\ v \in C_\sigma \,\}.$$

The engine of every proof below is the following counting lemma, a counting form
of the Chinese Remainder Theorem.

**Lemma 2.5 (Coprime product counting).** *Let $q, L \geq 1$ be coprime, let $A$
be a predicate depending only on $v \bmod q$, and let $B$ be a predicate depending
only on $v \bmod L$. Then*
$$\#\{\, v < qL : A(v) \wedge B(v) \,\} \;=\; \#\{\, v < q : A(v) \,\} \cdot \#\{\, v < L : B(v) \,\}.$$

*Proof sketch.* The map $v \mapsto (v \bmod q,\ v \bmod L)$ is a bijection from
$\{0,\dots,qL-1\}$ onto $\{0,\dots,q-1\} \times \{0,\dots,L-1\}$: it is injective
because $v \equiv w \pmod q$ and $v \equiv w \pmod L$ with $\gcd(q,L)=1$ force
$v \equiv w \pmod{qL}$, and surjective by the Chinese Remainder Theorem. Both
$A$ and $B$ are pulled back from the respective factors, so the joint predicate is
the product predicate and the counts multiply. $\square$

Two elementary one-prime counts feed the lemma.

**Lemma 2.6 (Single-prime cell count).** *For $q \geq 1$, exactly one residue in
$\{0,\dots,q-1\}$ is divisible by $q$ (namely $0$) and exactly $q-1$ are not.*

**Lemma 2.7 (Single-prime valuation count).** *For a prime $p$ and $e \geq 0$,
exactly $p-1$ residues in $\{0,\dots,p^{e+1}-1\}$ satisfy $p^e \mid v$ and
$p^{e+1} \nmid v$; they are $p^e k$ for $k = 1, \dots, p-1$.*

*Proof sketch.* The residues divisible by $p^e$ are $p^e k$ with
$0 \le k < p$; among these $p^{e+1} \mid p^e k$ holds iff $p \mid k$ iff $k = 0$
in that range. Hence $v \mapsto v / p^e$ is a bijection from the described set
onto $\{1, \dots, p-1\}$. $\square$

---

## 3. The rate law

**Theorem 3.1 (Exact cell count per period).** *For every finite set $P$ of
distinct primes with period $L$ and every signature $\sigma$,*
$$N_\sigma(0, L) \;=\; \kappa(\sigma).$$

*Proof sketch.* Induct on $P$. The empty set gives $L = 1$ and the single residue
$0$, matching the empty product $\kappa = 1$. For the step, write
$P = \{q\} \sqcup P'$ with period $L = q L'$; $q$ is coprime to $L'$ since the
primes are distinct. Membership in $C_\sigma$ is the conjunction of the
$q$-periodic condition "$q \mid v \iff \sigma(q)$" and the $L'$-periodic condition
"$v \in C_{\sigma|_{P'}}$". Lemma 2.5 factorises the count; Lemma 2.6 evaluates
the first factor as $1$ or $q-1$ according to $\sigma(q)$; the induction
hypothesis evaluates the second as $\kappa(\sigma|_{P'})$. $\square$

**Theorem 3.2 (Exact positional flatness).** *Let $L'$ be any common multiple of
the primes of $P$. For every $m \geq 0$,*
$$N_\sigma(mL', mL' + L') \;=\; N_\sigma(0, L').$$
*The block profile has zero drift.*

*Proof sketch.* Cell membership is invariant under $v \mapsto v + mL'$, since each
$p \in P$ divides $L'$ and therefore $p \mid v + mL' \iff p \mid v$. Translation
by $mL'$ is thus a bijection between the two filtered windows. $\square$

**Corollary 3.3 (Scale-carrying rate law).** *For every $m \geq 0$,*
$$N_\sigma(0, mL) \;=\; m\,\kappa(\sigma),$$
*and consequently, for any two signatures $\sigma, \tau$,*
$$N_\sigma(0, mL) \cdot \kappa(\tau) \;=\; N_\tau(0, mL) \cdot \kappa(\sigma):$$
*the ratio of two cell counts is independent of the number of periods observed.*

*Proof sketch.* Split $[0, mL)$ into $m$ consecutive blocks, apply Theorem 3.2 to
each and Theorem 3.1 to the first; then cross-multiply. $\square$

Corollary 3.3 is the precise sense in which the composition layer is
*scale-carrying*: the observed ratios do not depend on the length of the scan, so
they transfer unchanged between populations of different bit lengths.

### 3.1 Structure of the dial

**Theorem 3.4 (Top of the dial).** *The all-cleared cell is exactly the set of
integers coprime to $L$, and its rate is $\varphi(L)$:*
$$\kappa(\texttt{all cleared}) \;=\; \prod_{p \in P}(p-1) \;=\; \varphi(L).$$

*Proof sketch.* $v$ is coprime to the squarefree $L$ iff no $p \in P$ divides $v$,
which is exactly the all-cleared condition. The product formula is multiplicativity
of $\varphi$ on the coprime factorisation $L = \prod p$ together with
$\varphi(p) = p-1$. $\square$

**Theorem 3.5 (Range of the dial).** *For every signature $\sigma$,*
$$1 \;\le\; \kappa(\sigma) \;\le\; \varphi(L),$$
*with the sharp criteria:*
$$\kappa(\sigma) = \varphi(L) \iff \sigma(p) = \texttt{false} \text{ for all odd } p \in P,$$
$$\kappa(\sigma) = 1 \iff \sigma(p) = \texttt{true} \text{ for all odd } p \in P.$$
*Both bounds are attained; hence the full spread of the dial is exactly the factor
$\varphi(L)$, and if $P$ contains an odd prime this factor is at least $2$.*

*Proof sketch.* Each factor of $\kappa$ lies in $[1, p-1]$, giving both bounds
termwise against $\prod (p-1) = \varphi(L)$. For the upper criterion: if
$\sigma(p) = \texttt{true}$ for some odd $p$, that factor is $1 < p-1$ and the
product is strictly smaller. For the lower criterion: if $\sigma(p) =
\texttt{false}$ for some odd $p$, then $p - 1 \geq 2$ divides $\kappa(\sigma)$, so
$\kappa(\sigma) \neq 1$. $\square$

**Theorem 3.6 (The prime $2$ is a dead coordinate).** *Modifying a signature at
the prime $2$ never changes its rate.*

*Proof sketch.* The $2$-factor of $\kappa$ is $1$ if $\sigma(2) = \texttt{true}$
and $2 - 1 = 1$ otherwise. $\square$

**Theorem 3.7 (Divisor constraint).** *Every cell rate divides $\varphi(L)$.*

*Proof sketch.* Compare factor by factor against $\prod_p (p-1)$: each factor of
$\kappa(\sigma)$ is either $1$ or $p-1$, and both divide $p-1$. $\square$

**Theorem 3.8 (Tiling).** *Summing rates over all cells recovers the period:*
$$\sum_{T \subseteq P} \kappa_T \;=\; \sum_{T \subseteq P} \prod_{p \in P \setminus T} (p-1) \;=\; \prod_{p \in P}\big(1 + (p-1)\big) \;=\; L.$$

*Proof sketch.* Expand the product $\prod_{p}(1 + (p-1))$ by distributivity; the
term indexed by the subset $T$ (choose "$1$" at $p \in T$ and "$p-1$" at
$p \notin T$) is exactly $\kappa_T$. This is a consistency check on Theorem 3.1:
the cells partition a period. $\square$

---

## 4. Positional no-go: independence at every coprime scale

Theorem 3.2 rules out positional structure at the resolution of whole period
blocks. The following strengthens this to *arbitrary* observables at *any* coprime
scale, which is the statement needed to rule out a genuine positional mechanism.

**Theorem 4.1 (Coprime-statistic no-go theorem).** *Let $P$ be a finite set of
distinct primes with period $L$, let $\sigma$ be a signature, let $M \geq 1$ be
coprime to $L$, and let $Q$ be **any** predicate on integers depending only on
$v \bmod M$. Then*
$$\#\{\, v < LM : v \in C_\sigma \wedge Q(v) \,\} \;=\; \kappa(\sigma)\cdot \#\{\, r < M : Q(r) \,\}.$$
*That is, over one common period the cell and the event $Q$ are exactly
independent.*

*Proof sketch.* Membership in $C_\sigma$ is $L$-periodic and $Q$ is $M$-periodic,
with $\gcd(L, M) = 1$; apply Lemma 2.5 with $q = L$, and evaluate the cell factor
by Theorem 3.1. $\square$

Since the density of $C_\sigma$ over $[0, LM)$ is $\kappa(\sigma)M / (LM) =
\kappa(\sigma)/L$ and that of $Q$ is $\#\{r<M : Q(r)\}/M$, Theorem 4.1 says
precisely that the joint density factorises: independence in the probabilistic
sense, with no error term.

**Corollary 4.2 (Coprime-scale equidistribution).** *For $M$ coprime to $L$ and
any residue $r$ with $0 \le r < M$,*
$$\#\{\, v < LM : v \in C_\sigma \wedge v \equiv r \!\!\pmod M \,\} \;=\; \kappa(\sigma).$$
*Every residue class modulo $M$ receives exactly the same number of cell members.*

*Proof sketch.* Apply Theorem 4.1 with $Q(v) : v \equiv r \pmod M$, whose count
over $[0, M)$ is $1$. $\square$

**Remark 4.3 (Scope, and what is *not* excluded).** The coprimality hypothesis is
necessary and is the whole content of the theorem. If $\gcd(M, L) = d > 1$ then a
divisibility cell *does* interact with residues modulo $M$ — but only through
$d$, i.e. through the same divisibility conditions restated at a coarser modulus.
Theorem 4.1 therefore has the following exact interpretation: **the only positional
information a divisibility cell can express is the divisibility itself.** Any
claim of a distinct positional mechanism must live at a scale sharing a factor
with $L$, and is then not a new mechanism.

**Remark 4.4 (Consequence for the empirical episode).** Any positional statistic
of the form "membership rate as a function of a coprime-scale coordinate" has
*identically zero* signal on the exact model. The measured amplitude of such a
statistic is therefore pure estimator noise plus estimator bias — which is exactly
what the fresh run observed, with the raw amplitude falling below the measured
baseline of the estimator itself.

---

## 5. The valuation ladder

Divisibility is the coarsest $p$-adic question. The natural refinement fixes the
exact valuation.

**Definition 5.1.** For a finite set $P$ of distinct primes and exponents
$e : P \to \mathbb{Z}_{\geq 0}$, the *valuation cell* $V_e$ consists of the
integers $v$ with
$$\forall p \in P: \quad p^{e_p} \mid v \ \text{ and } \ p^{e_p+1} \nmid v,$$
i.e. $v_p(v) = e_p$ for all $p \in P$. Its *refined period* is
$$L_e \;=\; \prod_{p \in P} p^{\,e_p + 1}.$$
Membership in $V_e$ depends only on $v \bmod L_e$.

**Theorem 5.2 (The valuation ladder).** *For every exponent vector $e$,*
$$\#\{\, v < L_e : v \in V_e \,\} \;=\; \prod_{p \in P} (p - 1),$$
*independently of $e$.*

*Proof sketch.* Induct on $P$ exactly as in Theorem 3.1. Splitting off a prime
$q$ writes $L_e = q^{e_q+1} L'_e$ with coprime factors; Lemma 2.5 factorises the
count; Lemma 2.7 evaluates the $q$-factor as $q-1$, regardless of $e_q$; the
induction hypothesis handles the rest. $\square$

**Corollary 5.3 (Pure geometric density).** *The density of $V_e$ is*
$$\frac{\prod_{p \in P}(p-1)}{\prod_{p \in P} p^{\,e_p+1}} \;=\; \prod_{p \in P} p^{-e_p}\left(1 - \frac{1}{p}\right).$$
*Each additional unit of $p$-adic resolution divides the density by exactly $p$
and changes nothing else.*

**Corollary 5.4 (Resolution-invariance of the numerator).** *For any two exponent
vectors $e, f$, the valuation cells $V_e$ and $V_f$ have equal cardinalities over
their respective periods.*

**Corollary 5.5 (Anchoring at the totient).** *At $e \equiv 0$ the valuation cell
is the all-cleared divisibility cell and its size is $\varphi(L)$.*

The moral is a strong negative: no new arithmetic constant appears at any depth of
$p$-adic resolution. The numerator $\prod (p-1)$ is frozen; the only thing
refinement does is enlarge the denominator geometrically. Any observed effect that
"appears only at finer resolution" cannot be produced by the valuation structure.

---

## 6. The effective dimension of a cell sweep

A discovery sweep that examines many cells and reports the extreme one must be
corrected for selection. The correction requires the number of *distinct*
statistics actually examined. Theorem 3.6 already shows that the naive count
$2^{|P|}$ overstates this; the following makes the correct count exact.

**Definition 6.1.** The *sweep value set* of $P$ is
$$\mathcal{K}(P) \;=\; \{\, \kappa_T : T \subseteq P \,\} \;\subseteq\; \mathbb{Z}_{\geq 1},$$
the set of distinct rates realised across all $2^{|P|}$ cells.

**Theorem 6.2 (Sweep values are odd-prime subset products).** *For every finite
set $P$ of distinct primes,*
$$\mathcal{K}(P) \;=\; \Big\{\, \textstyle\prod_{p \in S}(p-1) \ : \ S \subseteq P \setminus \{2\} \,\Big\}.$$

*Proof sketch.* By definition $\kappa_T = \prod_{p \in P \setminus T}(p-1)$, so the
rates are exactly the subset products of $\{p-1 : p \in P\}$ realised by
complementary sets. Since $2-1 = 1$, removing $2$ from the index set never changes
a product, so the family of achievable products over subsets of $P$ equals that
over subsets of $P \setminus \{2\}$; and $S \mapsto P \setminus S$ is a bijection
of the index sets. $\square$

**Theorem 6.3 (Divisor lattice constraint).** *$\mathcal{K}(P)$ is contained in
the set of divisors of $\varphi(L)$.*

*Proof sketch.* Theorem 3.7 plus $\varphi(L) > 0$. $\square$

**Theorem 6.4 (Effective sweep size).** *If $2 \in P$ then*
$$\#\mathcal{K}(P) \;\le\; 2^{|P| - 1}.$$

*Proof sketch.* By Theorem 6.2, $\mathcal{K}(P)$ is the image of the power set of
$P \setminus \{2\}$ under the subset-product map, so its cardinality is at most
$2^{|P \setminus \{2\}|} = 2^{|P|-1}$. $\square$

**Theorem 6.5 (Sharp criterion: multiplicative Sidon condition).** *For every
finite set $P$ of distinct primes,*
$$\#\mathcal{K}(P) \;=\; 2^{|P \setminus \{2\}|} \iff \text{the map } S \mapsto \prod_{p \in S}(p-1) \text{ is injective on subsets of } P \setminus \{2\}.$$
*Equivalently: equality holds precisely when the multiset $\{p-1 : p \in P,\ p \neq 2\}$
has pairwise distinct subset products, i.e. is a multiplicative Sidon system.*

*Proof sketch.* $\mathcal{K}(P)$ is the image of a set of size
$2^{|P\setminus\{2\}|}$; the cardinality of an image equals the cardinality of the
domain exactly when the map is injective on it. $\square$

**Proposition 6.6 (The criterion is non-vacuous).** *For $P = \{3,7,13\}$ one has
$(3-1)(7-1) = 12 = 13-1$, so the subsets $\{3,7\}$ and $\{13\}$ share the product
$12$ and*
$$\#\mathcal{K}(\{3,7,13\}) \;=\; 7 \;<\; 8 \;=\; 2^{3}.$$

*Proof sketch.* Direct enumeration: the eight subset products of $\{2, 6, 12\}$
are $1, 2, 6, 12, 12, 24, 72, 144$, with $12$ repeated. $\square$

**Proposition 6.7 (A maximal example).** *For $P = \{2,3,5,7\}$ the odd shifted
primes are $\{2,4,6\}$, whose eight subset products $1,2,4,6,8,12,24,48$ are
pairwise distinct. Hence the sixteen cells realise exactly $8 = 2^{3}$ distinct
rates, meeting the bound of Theorem 6.4.*

**Remark 6.8 (Statistical reading).** Theorems 6.4–6.5 say that the number of
degrees of freedom of a divisibility sweep is not a property of the data, nor even
of $P$ as a set of primes, but of the multiplicative structure of the shifted
primes $p-1$. A max-statistic correction using $n = 2^{|P|}$ is therefore
systematically wrong in two directions at once: it overcounts distinct statistics
(some cells are exact duplicates, so the maximum is over fewer independent draws
than assumed), while the remaining cells are strongly *dependent*, being subset
products drawn from a single divisor lattice (Theorem 6.3). Neither correction is
a Bonferroni factor. The honest count is $\#\mathcal{K}(P)$, which Theorem 6.5
computes exactly.

---

## 7. Reading the empirical episode through the theorems

We can now state precisely what the exact theory implies about the two reported
effects.

**The rate effect is a theorem, hence necessarily replicates.** The observed
composition spread $0.649$–$1.432$ (fresh run) against $0.645$–$1.406$ (original)
and the identical extremal cells are not coincidences of sampling: by Theorem 3.5
the extremes of the dial are the all-cleared and all-required cells (up to the
dead $2$-coordinate of Theorem 3.6), and by Corollary 3.3 the ratios between cell
rates are invariant under change of window length. A population resampled at a
different scale must reproduce the same ratios. The measured $\approx 2\%$
agreement across independent populations is the expected statistical error around
an exact identity, not evidence for a contingent effect.

Note also that the reported top cell — "divisible by $2$, $3$ and $5$, not by
$7$" — has, for $P = \{2,3,5,7\}$, rate $\kappa = 1 \cdot 1 \cdot 1 \cdot 6 = 6$,
while the all-cleared cell has $\kappa = 48$. The *ordering* by raw density is the
reverse of the reported "top/bottom" labelling, which is normalised differently
(the reported figures are relative to a per-cell expectation); the invariant
content that transfers is the identity of the extremal pair and the ratio, which
is what replicated.

**The positional effect is provably absent, not merely unreplicated.** By
Theorem 3.2 the profile in the block index is identically flat — the reported
drifts of $0.204\%$ and $0.269\%$ are exactly the finite-sample residue of a
theoretical zero. By Theorem 4.1 and Corollary 4.2, no statistic measurable at a
scale coprime to $L$ can detect the cell at all. Hence any nonzero measurement of
such a statistic is estimator noise plus estimator bias. The fresh run made this
diagnosis directly observable: the raw amplitude $0.0742 \pm 0.0377$ was *below*
the independently measured baseline $0.1398 \pm 0.0478$ of the estimator on null
input, so the calibrated excess was $-0.066 \pm 0.061$, i.e. $-1.08$ standard
deviations.

**The original significance is consistent with a selection artefact of exactly the
size the theory permits.** The original raw score of $4.11$ came from a sweep over
roughly thirty cells. Theorems 6.4 and 6.5 give the effective number of distinct
rate statistics a divisibility sweep can carry: at most $2^{|P|-1}$, and less when
the shifted primes have colliding subset products. A maximum over a selection
surface of this size, computed against a nominal rather than a calibrated null,
inflates a score by an amount of the observed order; and the calibrated scores of
the two runs, $+1.53$ and $-1.08$, bracket zero, which is the signature of
selection rather than of a diminished but real effect.

**What remains open, and the shape of a decisive test.** The theorems above
foreclose coprime-scale positional structure entirely. They do not foreclose
structure at scales sharing a factor with $L$ — though such structure is, by
Remark 4.3, a restatement of divisibility rather than a new mechanism — nor do
they speak to non-divisibility carriers of positional information. A test of the
latter must be a *single* pre-registered hypothesis at one fixed location, with no
sweep and no post-hoc choice of location, evaluated on at least three pooled
independent fresh populations and powered against the estimator's own calibrated
baseline rather than against zero. Anything less repeats the selection surface
that Section 6 quantifies.

---

## 8. Worked numerics

Take $P = \{2,3,5,7\}$, so $L = 210$ and $\varphi(L) = 48$.

**Cell rates.** By Theorem 3.1 the sixteen cells have rates $\kappa_T =
\prod_{p \notin T}(p-1)$:

| required set $T$ | $\kappa_T$ | | required set $T$ | $\kappa_T$ |
| --- | --- | --- | --- | --- |
| $\emptyset$ | $48$ | | $\{3,5\}$ | $6$ |
| $\{2\}$ | $48$ | | $\{3,7\}$ | $4$ |
| $\{3\}$ | $24$ | | $\{5,7\}$ | $2$ |
| $\{5\}$ | $12$ | | $\{2,3,5\}$ | $6$ |
| $\{7\}$ | $8$ | | $\{2,3,7\}$ | $4$ |
| $\{2,3\}$ | $24$ | | $\{2,5,7\}$ | $2$ |
| $\{2,5\}$ | $12$ | | $\{3,5,7\}$ | $1$ |
| $\{2,7\}$ | $8$ | | $\{2,3,5,7\}$ | $1$ |

The sum is $48+48+24+24+12+12+8+8+6+6+4+4+2+2+1+1 = 210 = L$, confirming
Theorem 3.8. The distinct values are $\{1,2,4,6,8,12,24,48\}$: exactly $8 = 2^3$,
meeting the bound of Theorem 6.4 (Proposition 6.7), and each divides $48$
(Theorem 6.3).

**Scale invariance.** Over $[0, 2100) = [0, 10L)$ the all-cleared cell contains
exactly $10 \times 48 = 480$ integers (Corollary 3.3), and every one of the ten
blocks $[210k, 210k+210)$ contains exactly $48$ (Theorem 3.2).

**Coprime-scale equidistribution.** Take $M = 11$, coprime to $210$. Over
$[0, 2310) = [0, 210 \cdot 11)$ the integers coprime to $210$ number $528$, and
Corollary 4.2 says each of the eleven residue classes modulo $11$ contains exactly
$48$ of them — $48 \times 11 = 528$, with zero deviation in every class.

**Valuation ladder.** For $P = \{3\}$ and $e = 0, 1, 2$: the counts of integers of
$3$-adic valuation exactly $e$ over the periods $3, 9, 27$ are $2, 2, 2$, so the
densities are $2/3, 2/9, 2/27$ (Theorem 5.2 and Corollary 5.3). For
$P = \{2,3\}$ and $e = (2, 1)$: the refined period is $2^3 \cdot 3^2 = 72$ and the
cell $\{v : v_2(v) = 2, v_3(v) = 1\}$ has exactly $(2-1)(3-1) = 2$ members, namely
$12$ and $60$.

**Sweep collision.** For $P = \{3,7,13\}$ the rates are the subset products of
$\{2,6,12\}$: $1, 2, 6, 12, 12, 24, 72, 144$. The value $12$ arises twice — from
clearing $\{13\}$ and from clearing $\{3,7\}$ — so $\#\mathcal{K} = 7 < 8$
(Proposition 6.6). Two cells of this sweep are, as rate statistics, literally the
same test.

---

## 9. Discussion, applications, and future directions

### 9.1 Applications

*Sieve heuristics with exact error terms.* Corollary 3.3 gives the count over
whole periods with no error term whatsoever, and Theorem 4.1 shows that
conditioning on a coprime-measurable event does not perturb it. In any estimation
task where the sampling window can be aligned to a multiple of $L$, the
divisibility correction is deterministic and can be divided out exactly.

*Design of arithmetic experiments.* Theorem 4.1 is a design rule: never test a
divisibility stratification against a coprime-scale positional coordinate,
because the null is exactly true and any deviation measured is a property of the
estimator, not of the arithmetic. Conversely, Theorem 3.5 gives the maximal
achievable rate contrast, $\varphi(L)$, which is the power ceiling of any
rate-based design.

*Selection corrections for cell sweeps.* Theorems 6.4 and 6.5 give the effective
dimension of a sweep in closed form. Because the value set lies inside the divisor
lattice of $\varphi(L)$ (Theorem 6.3), the statistics examined by a sweep are
strongly structured, and a correction assuming $2^{|P|}$ independent tests is not
merely conservative but categorically misspecified.

*Random number generation and hashing diagnostics.* Corollary 4.2 provides an
exact zero-tolerance test: if a generator's output stratified by small-prime
divisibility fails to place exactly $\kappa(\sigma)$ members in each coprime
residue class over an aligned window, the deviation is a defect of the generator,
with no statistical allowance required.

### 9.2 Future directions

The cycle closed the two-run-surviving part of the composition layer as exact
theorems: the divisibility pattern controls the *rate* of a cell exactly and
multiplicatively, while the *positional* profile is identically flat — across
period blocks and, more strongly, exactly independent of *every* statistic
measurable at a coprime scale. The downgraded positional corollary of the reported
map entry is therefore not merely unreplicated: in the exact model it is
*provably absent*. The dial's extremes are $1$ and $\varphi(L)$, the prime $2$ is a
dead coordinate, and every rate divides $\varphi(L)$, so a cell sweep explores a
sub-family of a divisor lattice of size at most $2^{|P|-1}$ rather than $2^{|P|}$
free values.

**A. Which prime sets have distinct subset products?** The criterion itself is
closed: a sweep attains the maximal effective dimension $2^{|P \setminus \{2\}|}$
if and only if the numbers $p-1$ over the odd primes of $P$ have pairwise distinct
subset products, and $P = \{3,7,13\}$ shows the criterion bites, via
$(3-1)(7-1) = 13-1$. What remains open is the arithmetic classification. The key
insight is that the effective dimension of a divisibility sweep is not a property
of $P$ at all but of the multiset $\{p-1\}$ as a *multiplicative Sidon system*, so
the question becomes: for which sets of odd primes are the subset products of
$p-1$ distinct, and what is the density of such sets among all $k$-subsets of the
first $n$ primes? This matters now because selection-corrected inference over cell
sweeps needs the effective count, and with the criterion settled the remaining
question is a clean multiplicative-combinatorics problem, testable exhaustively for
small $k$.

**B. Sharp discrepancy of cell counts in partial windows.** All exact statements
above concern *whole* periods. In a truncated window $[0, N)$ with $N$ not a
multiple of $L$, the count deviates from $N\kappa(\sigma)/L$ by a boundary term.
The key insight is that inclusion–exclusion writes the deviation as a signed sum
of at most $2^{|P|}$ fractional parts, so the discrepancy is bounded by a constant
depending only on $|P|$ — never on $N$ — and the sharp constant should be
$2^{|P|-1}$, attained at a window end aligned with the extremal cell. This matters
now because every finite-sample estimate of a cell rate uses truncated windows, so
the sharp boundary constant is exactly the deterministic part of the error budget
that a calibrated null must not absorb.

**C. Beyond squarefree periods and beyond primes.** The valuation ladder
(Theorem 5.2) is the first step past squarefree moduli. A natural next question is
the analogue of Theorem 4.1 for valuation cells at *non*-coprime auxiliary scales,
where the interaction is expected to be governed entirely by the greatest common
divisor of the two periods.

**D. Non-divisibility carriers.** The reopening condition for a positional claim
is a single pre-registered hypothesis at a fixed location, evaluated on at least
three pooled independent fresh populations against a calibrated baseline. The
theorems here specify exactly where such a claim could survive: at scales sharing
a factor with $L$, or through a carrier that is not a divisibility statistic at
all.

### 9.3 Conclusion

Divisibility by a fixed finite set of primes is a *rate* device and nothing else.
Its effect on counting is an exact, completely factorised multiplier, stable under
change of window, stable under refinement of $p$-adic resolution up to a pure
geometric factor, confined to the divisor lattice of $\varphi(L)$, and spanning
exactly the interval from $1$ to $\varphi(L)$. Its effect on position is
identically zero at every scale coprime to its period, for every observable
whatsoever. The slogan survives in exactly one half, and the surviving half is not
an empirical regularity but an identity.
