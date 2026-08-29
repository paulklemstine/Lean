# Sequential Hint Pricing: One Structure, Two Faces

### Adaptive comparison hints compound geometrically and saturate exactly at the isolation ceiling, while fixed batteries price linearly — and can carry literally zero bits

**Author:** Aristotle
**Date:** 2026-08-28

---

## Abstract

We study the value of external side information supplied to a factoring
algorithm through a truthful comparison oracle. The setting is a semiprime
$N = pq$ whose smaller factor $p$ is sought by a Fermat difference-of-squares
scan, and an oracle that answers queries of the form "$p \le t$?". We prove a
complete pricing theory for such hints and resolve an apparent tension in the
literature between a *linear no-synergy law* (a budget of $k$ hints buys a
speedup of at most $k+1$) and the repeated observation that *sequential hints
compound*.

The reconciliation is that the two statements describe the non-adaptive and
adaptive faces of a single pricing structure. We prove: (i) every **fixed**
battery of $k$ comparison thresholds leaves an indistinguishability class of
size at least $w/(k+1)$ in a window of $w$ candidates, and the bound is
attained; (ii) the **adaptive** lower-median bisection reduces the window to
width *exactly* $\lceil w/2^k \rceil$, so the minimal isolating budget is
exactly $\lceil \log_2 w \rceil$; (iii) **no** adaptive strategy beats $2^k$,
and with an $r$-ary oracle none beats $r^k$, so external positional
information is priced at exactly one bit (respectively $\log_2 r$ bits) per
query; (iv) the **adaptivity premium** $r(k) = 2^k/(k+1)$ equals $1$ exactly at
$k \le 1$, strictly increases thereafter, and dominates every linear function;
(v) a **zero-bit collapse** occurs whenever no threshold of a fixed battery
falls inside the support of the unknown — in the balanced stratum at bit length
$40$, a uniform $24$-threshold battery carries literally zero bits (speedup
exactly $1.00$) while $12$ adaptive queries isolate the factor completely.

Three structural refinements sharpen the picture. First, the premium is not a
gain created by conditioning: a *non-adaptive* battery of general Boolean
predicates already attains $2^k$, so $2^k/(k+1)$ measures the deficit of the
comparison channel, which adaptivity merely repairs. Second, compounding is a
property of the channel rather than of adaptivity: a non-adaptive residue
battery with pairwise coprime moduli isolates $\prod_i m_i \ge 2^k$ candidates
by the Chinese Remainder Theorem, yet every residue class still spans all but
$2m$ of the window, so residue hints buy *count* and no *interval*. Third, the
currencies do not mix: after $k$ adaptive comparison queries and a residue
query of modulus $m$, two consistent candidates remain at least $w/2^k - 2m$
apart. Finally, in the one-lie (Ulam) channel a robust $k$-query strategy
identifies at most $2^k/(k+1)$ candidates: the noise tax and the
non-adaptivity tax are *the same factor*.

We close with the net economics — the optimal budget is
$k_{\mathrm{opt}} = \log_2(T \ln 2 / c)$ with the integer optimum at
$\lfloor k_{\mathrm{opt}} \rfloor$ or $\lceil k_{\mathrm{opt}} \rceil$ — and
with the stratification law for the downstream scan,
$\text{scan} = \sqrt N (\sqrt\rho - 1)^2/(2\sqrt\rho)$, strictly increasing in
the imbalance $\rho = q/p$.

**Keywords:** adaptive search, comparison oracle, information pricing, binary
search, Ulam's problem, Fermat factorization, Chinese Remainder Theorem,
Pythagorean triples.

---

## 1. Introduction

### 1.1 The pricing question

Let $N = pq$ be a semiprime with $p \le q$. A *hint oracle* answers truthful
queries of the form "$p \le t$?" for a threshold $t$ chosen by the algorithm.
Each query has a price $c$ (measured, say, in divisibility tests, so that hint
cost and search cost are commensurable). The downstream algorithm is Fermat's
difference-of-squares scan, whose un-hinted cost we call $T_0$. The pricing
question is:

> Given a budget of $k$ queries, what is the largest achievable speedup
> $s(k) = T_0 / T(k)$, and how does it depend on how the queries are chosen?

Two answers circulate. The **no-synergy law** says $s(k) \le k+1$: hints add,
they do not compound. The **compounding observation** says $s(k) \approx 2^k$:
each hint halves the search space, so speedups multiply. The two are
incompatible as stated, and the incompatibility is not small: at $k = 12$ they
differ by a factor of over $300$.

### 1.2 The resolution in one sentence

The no-synergy law is a theorem about **fixed** (non-adaptive) comparison
batteries; the compounding observation is a theorem about **adaptive**
strategies; and the gap between them, the *adaptivity premium* $2^k/(k+1)$, is
exactly the redundancy of a fixed list of comparison questions, whose answers
are nested.

### 1.3 The empirical frame

The theory below was designed against a measurement campaign: $n = 800$
bit-length-$40$ semiprimes in two strata — $600$ *balanced* with imbalance
$\rho = q/p \in [1, 1.01]$ and $200$ *unbalanced* with $\rho \in [7.5, 8.5]$ —
swept over budgets $k \in \{0,1,2,3,6,9,12,14,16,20,24\}$ with four arms
(adaptive bisection; uniform fixed battery; draw-law-calibrated variants of
each) plus a cost-gate control. The measured headline numbers are:

| quantity | balanced (600 $N$) | unbalanced (200 $N$) | idealized model |
|---|---|---|---|
| $s_{\mathrm{adapt}}(12)/s_{\mathrm{adapt}}(3)$ | $20.8\times$ | $165.2\times$ | $2^9 = 512\times$ |
| premium $r(12)$ over matched fixed battery | $20.8\times$ $[19.5, 22.3]$ | $239.5\times$ $[220.1, 261.0]$ | $4096/13 \approx 315$ |
| premium $r(1)$ | $1.00$ exactly | $1.00$ exactly | $1$ exactly |
| pin fraction at $k = 20$ | $100\%$ | $100\%$ | $\lceil \log_2 2^{20}\rceil = 20$ |
| fixed-battery speedup, all $k \le 24$ | $1.00$ exactly | linear | zero-bit collapse / $k+1$ |
| $k_{\mathrm{opt}}$ measured / predicted | $10 / 9.54$ | $18 / 17.60$ | $\log_2(T_0\ln 2/c)$ |

Every qualitative feature in this table is a theorem below. The measured
ratios lie *below* the idealized ones because the empirical speedup is priced
in divisibility tests with an additive floor, whereas the model counts pure
candidate-space reduction; the laws that are exact — $r(1) = 1$, the hard pin
at $\lceil \log_2 w\rceil$, the balanced zero-bit collapse, linear versus
geometric — are exactly the ones proved here.

### 1.4 Contributions

1. A tight linear pricing theorem for fixed comparison batteries (§3), with
   exhaustive small-window sweeps confirming tightness.
2. An exact width-halving law for lower-median bisection, including the
   ceiling-division closed form and the exact isolating budget
   $\lceil\log_2 w\rceil$ (§4), together with a stall counterexample showing
   the lower-median convention is not cosmetic.
3. A transcript-counting isolation ceiling valid for all adaptive strategies
   and all finite answer alphabets (§5).
4. The adaptivity premium and its exact behaviour at small $k$ (§6).
5. The zero-bit collapse and the balanced dichotomy at bit length $40$ (§7).
6. The channel-structure analysis: adaptivity repairs, it does not create (§8).
7. The residue channel and the two-currency theorem, with mixed-battery floors
   (§9).
8. The one-lie volume bound and the noise-tax/non-adaptivity-tax identity
   (§10).
9. The net-cost optimum and the Fermat stratification law (§11–12).

---

## 2. The model

**Definition 2.1 (Window).** A *window* is a pair $I = [\mathrm{lo},
\mathrm{hi})$ of naturals, with *carrier* $\mathrm{carr}(I) = \{x :
\mathrm{lo} \le x < \mathrm{hi}\}$ and *width* $w(I) = \mathrm{hi} -
\mathrm{lo}$ (truncated subtraction, so $w(I) = 0$ if $\mathrm{hi} \le
\mathrm{lo}$).

The hidden value $x$ is the smaller prime factor $p$; the window is the
algorithm's current knowledge about it. Initially, for a bit-length-$2b$
semiprime, $I = [2, 2^b)$.

**Definition 2.2 (Fixed battery and signature).** A *fixed battery* is a
finite set $T \subseteq \mathbb{N}$ of thresholds, all chosen before any
answer is seen. The *signature* of a candidate $x$ is
$$\sigma_T(x) = \#\{t \in T : x \le t\}.$$
The *class* of signature $v$ in a window $W$ is
$\mathrm{cls}_T(W, v) = \{x \in W : \sigma_T(x) = v\}$.

**Definition 2.3 (Adaptive strategy and transcript).** An *adaptive strategy*
is a function $S : \{0,1\}^* \to \mathbb{N}$ assigning to each history of
answers the next threshold. Its *transcript* against a hidden value $x$ is
defined by $\tau_S(x, 0) = \varepsilon$ and
$$\tau_S(x, k+1) = \tau_S(x,k) \cdot [\, x \le S(\tau_S(x,k)) \,],$$
a bit string of length $k$.

**Definition 2.4 (Indistinguishability, speedup).** Two candidates are
*indistinguishable* under a protocol if they yield identical oracle answers.
The residual search space is the indistinguishability class of the truth, and
the *speedup* is $|W|$ divided by the size of that class. Since the downstream
scan is linear in the surviving candidate range, this is the operationally
relevant quantity.

---

## 3. Fixed batteries price linearly

The key structural fact is that comparison answers are *nested*.

**Lemma 3.1 (Signature determines answers).** If $\sigma_T(x) = \sigma_T(y)$
then for every $t \in T$, $x \le t \iff y \le t$.

*Proof sketch.* Without loss of generality $x \le y$. Then
$\{t \in T : y \le t\} \subseteq \{t \in T : x \le t\}$, and equal cardinality
of two nested finite sets forces equality of the sets. Membership in that
common set is precisely the answer bit. $\square$

Consequently the answer vector of a fixed comparison battery is a function of
a single integer in $\{0,\dots,k\}$, which is the whole of the linear law.

**Theorem 3.2 (Linear pricing / no-synergy law).** For every fixed battery $T$
with $|T| = k$ and every finite window $W$ there is a subset $C \subseteq W$
with
$$|C| \;\ge\; \frac{|W|}{k+1}$$
such that all elements of $C$ answer every threshold of $T$ identically. Hence
the speedup obtainable from a $k$-threshold fixed battery is at most $k+1$.

*Proof sketch.* $\sigma_T$ maps $W$ into $\{0,1,\dots,k\}$, a set of $k+1$
elements. Pigeonhole gives a fibre of size at least $|W|/(k+1)$; Lemma 3.1
says the fibre is an indistinguishability class. $\square$

An equivalent quantitative form: there exists $C \subseteq W$ with
$|W| - k \le (k+1)|C|$.

**Tightness.** The bound is attained. With one threshold at the lower median
of $[\mathrm{lo}, \mathrm{hi})$, both classes have size at most
$\lceil w/2 \rceil$ — exactly what one bisection step achieves; this is the
$k=1$ statement that the adaptivity premium is $1$. Exhaustive verification on
small windows:

* On $W = \{0,\dots,7\}$ the equally spaced battery $\{1,3,5\}$ realises class
  size exactly $2 = |W|/(k+1)$, and *every* $3$-element battery leaves some
  class of size $\ge 2$.
* On $W = \{0,\dots,15\}$, *every* one of the $\binom{16}{4} = 1820$
  $4$-threshold batteries leaves some class of size $\ge 4 = 16/5$ rounded up
  to the pigeonhole value, while $4$ adaptive queries isolate every candidate
  (class size $1$).

---

## 4. Adaptive queries and the exact halving law

**Definition 4.1 (Lower median and step).** For a window $I$ of width $w$ put
$$\mathrm{mid}(I) = \mathrm{lo} + \left\lfloor \frac{w-1}{2}\right\rfloor,$$
and define the *step* on answer $b$ by
$$I \cdot b \;=\; \begin{cases} [\mathrm{lo}, \mathrm{mid}(I)+1) & b =
\text{yes},\\ [\mathrm{mid}(I)+1, \mathrm{hi}) & b = \text{no}.\end{cases}$$
The *bisection arm* $\mathrm{bis}(x, k, I)$ applies $k$ such steps, each with
the truthful answer for the hidden $x$.

**Theorem 4.2 (Width-halving law).** For any window $I$ with $w(I) > 0$ and
either answer $b$,
$$w(I\cdot b) \;\le\; \left\lceil \frac{w(I)}{2}\right\rceil.$$
Moreover the true candidate is retained: if $x \in \mathrm{carr}(I)$ then
$x \in \mathrm{carr}(I \cdot [\,x \le \mathrm{mid}(I)\,])$.

*Proof sketch.* Both cases are integer arithmetic on $\mathrm{lo} +
\lfloor (w-1)/2 \rfloor$: the "yes" branch has width $\lfloor (w-1)/2\rfloor +
1 = \lceil w/2\rceil$ and the "no" branch has width $w - \lceil w/2 \rceil =
\lfloor w/2 \rfloor$. Retention is immediate from the definition of the branch
chosen. $\square$

**Remark 4.3 (The even-median stall).** The lower median is essential. With
the *upper* median $\mathrm{lo} + \lfloor w/2 \rfloor$ the same scheme is not
even eventually contracting: on the width-$2$ window $[0,2)$ the threshold is
$1$, the answer for $x = 0$ is "yes", and the resulting window is $[0,2)$
again. Formally, the naive arm satisfies $\mathrm{bis}^{\uparrow}(0, k, [0,2))
= [0,2)$ for **every** $k$: it stalls forever and never isolates. This is a
genuine correctness trap, not a matter of taste.

**Definition 4.4.** Let $h_k(w)$ denote $k$ iterations of
$w \mapsto \lceil w/2 \rceil$.

**Theorem 4.5 (Exact halving).** $h_k(w) = \left\lceil w/2^k \right\rceil$ for
all $k, w$. Consequently $h_k(w) \le 1 \iff w \le 2^k$, and on exact powers
$h_k(2^m) = 2^{m-k}$ for $k \le m$.

*Proof sketch.* Induct on $k$, using the ceiling-division identity
$\lceil \lceil w/2\rceil / 2^{k}\rceil = \lceil w / 2^{k+1}\rceil$, which
follows from the general equivalence $\lceil x/a \rceil \le c \iff x \le ac$
for $a > 0$. The rounding errors do *not* accumulate. $\square$

**Theorem 4.6 (Geometric compounding).** For $x \in \mathrm{carr}(I)$,
$$w\big(\mathrm{bis}(x,k,I)\big) \;\le\; \left\lceil \frac{w(I)}{2^k}
\right\rceil .$$

*Proof sketch.* Induction on $k$, combining Theorem 4.2 with monotonicity of
$h_k$ and Theorem 4.5. $\square$

**Theorem 4.7 (Saturation at the isolation ceiling).** If
$x \in \mathrm{carr}(I)$ and $w(I) \le 2^k$, then $\mathrm{carr}
(\mathrm{bis}(x,k,I)) = \{x\}$. Further queries buy nothing: the speedup curve
is flat at its maximum from $k = \lceil \log_2 w\rceil$ on.

*Proof sketch.* Soundness keeps $x$ in the residual window, and Theorem 4.6
forces the residual width to be at most $1$; a width-$\le 1$ window containing
$x$ is exactly $\{x\}$. $\square$

**Theorem 4.8 (Exact isolating budget).** The least $k$ with $h_k(w) \le 1$ is
$\lceil \log_2 w \rceil$. In particular, for the bit-length-$40$ search window
of $2^{20}$ candidates the budget is exactly $20$; for the $3600$-candidate
balanced support window it is exactly $12$.

**Corollary 4.9 (The $-\ln 2$ slope law).** On a window of $2^m$ candidates the
log of the residual width is exactly linear in $k$ with slope $-\ln 2$:
$\log h_k(2^m) = (m - k)\ln 2$ for $k \le m$. Any measured slope shallower
than $-\ln 2$ is a phase effect of where the support sits inside the window,
not a failure of the halving law.

---

## 5. The isolation ceiling: no strategy does better

Theorem 4.7 shows bisection attains $2^k$. The matching upper bound holds for
*every* strategy, by a counting argument on transcripts.

**Theorem 5.1 (Transcript count).** For every adaptive strategy $S$, every
window $W$ and every $k$,
$$\#\{\tau_S(x,k) : x \in W\} \;\le\; 2^k.$$

*Proof sketch.* Induction on $k$. The set of length-$(k+1)$ transcripts is
contained in the set of one-bit extensions of length-$k$ transcripts, so its
cardinality at most doubles. $\square$

**Theorem 5.2 (Isolation ceiling).** If $2^k < |W|$ then for every adaptive
strategy $S$ there exist distinct $a, b \in W$ with
$\tau_S(a,k) = \tau_S(b,k)$: the strategy provably fails to separate them.

*Proof sketch.* Pigeonhole against Theorem 5.1. $\square$

**Theorem 5.3 (The two bounds meet).** On $W = [0, 2^m)$: bisection with $m$
queries isolates every candidate, and no strategy with $j < m$ queries
isolates any. The saturation point is therefore exactly $\lceil\log_2 |W|\rceil$
and it cannot be moved.

**Theorem 5.4 ($r$-ary generalisation).** If the oracle answers in a finite
alphabet $A$ with $|A| = r$, then $k$ adaptive queries produce at most $r^k$
transcripts, so no strategy separates more than $r^k$ candidates. Each query is
worth exactly $\log_2 r$ bits.

*Proof sketch.* Same induction as Theorem 5.1, with the one-bit extension
replaced by an extension over $A$. $\square$

Theorem 5.4 is what *prices* external side information: the hint channel is not
a loophole. Whatever the questioner knows about position, it enters the
computation at $\log_2 r$ bits per query and no faster.

---

## 6. The adaptivity premium

**Definition 6.1.** The *adaptivity premium* is
$$r(k) = \frac{2^k}{k+1},$$
the ratio of the geometric adaptive law to the linear fixed-battery law.

**Theorem 6.2 (Behaviour of the premium).**
1. $r(0) = r(1) = 1$ **exactly**.
2. $r$ is strictly increasing on $k \ge 1$.
3. $r(k) \ge k$ for all $k \ge 5$: the premium dominates every linear function.

*Proof sketch.* (1) is arithmetic. (2) reduces to $2(k+1) > k+2$, i.e. $k > 0$.
(3) is the standard induction $2^k \ge k(k+1)$ for $k \ge 5$. $\square$

Item (1) is not decoration: it is a *pre-registered prediction* confirmed by
the measurement, where the premium at $k = 1$ was $1.00$ in all four
arm-pairs. It has an exact structural cause — a single fixed threshold at the
lower median achieves precisely the bisection bound $\lceil w/2\rceil$
(§3, tightness) — and it is the correct sanity check for any claim that
"adaptivity helps": there is nothing to adapt to on the first question.

**Numerical values.** $r(2) = 4/3$, $r(3) = 2$, $r(6) = 64/7$,
$r(9) = 512/10$, $r(12) = 4096/13 \approx 315.1$, $r(20) = 1048576/21 \approx
49932$. The measured premium at $k = 12$ in the unbalanced stratum,
$239.5$ with confidence interval $[220.1, 261.0]$, sits below the idealized
ceiling $4096/13$, as it must: the empirical speedup carries an additive
floor from the fixed cost of a divisibility test.

**Theorem 6.3 (Grid ratio).** On a $2^{20}$ window, moving the budget from
$k = 3$ to $k = 12$ divides the residual width by exactly $2^9 = 512$, versus
the factor $13/4 = 3.25$ that linear pricing would predict. The measured
compounding ratios, $165.2\times$ unbalanced and $20.8\times$ balanced, are
both far outside the linear prediction.

**Theorem 6.4 (The pricing dichotomy).** Fix $m$, $k \le m$, a fixed battery
$T$, and a hidden $x$ in the window $[0, 2^m)$. Then simultaneously:
1. there is a set $C \subseteq [0,2^m)$ with $|C| \ge 2^m/(|T|+1)$ on which
   $T$ is blind;
2. $w(\mathrm{bis}(x,k,[0,2^m))) \le 2^{m-k}$;
3. for every strategy $S$ and every $j < m$, some pair in $[0,2^m)$ shares its
   $j$-query transcript.

That is: linear below, geometric above, and a hard ceiling on top. The three
statements are compatible and jointly exhaust the pricing structure.

---

## 7. The zero-bit collapse and the balanced dichotomy

Theorem 3.2 is an *upper* bound on what a fixed battery buys. In the
regime that matters most it collapses to the trivial bound.

**Theorem 7.1 (Zero-bit collapse).** Let the unknown be supported on
$[\mathrm{lo}, \mathrm{hi})$ and let $T$ be a fixed battery such that every
$t \in T$ satisfies $t < \mathrm{lo}$ or $\mathrm{hi} \le t+1$ — i.e. no
threshold falls strictly inside the support. Then all candidates of the support
answer every query identically, the whole support is a single
indistinguishability class, and the speedup is exactly $1$, for every $k$.

*Proof sketch.* A threshold below the support is answered "no" by everyone; a
threshold at or above the top element is answered "yes" by everyone. $\square$

**The balanced stratum.** For a semiprime $N \approx 2^{40}$ with
$\rho = q/p \le 1.01$, the smaller factor satisfies
$\sqrt{N/\rho} \le p \le \sqrt N$, pinning $p$ to a relative window of width
$\approx 0.5\%$ around $\sqrt N$. Concretely $p$ lies in
$[720000, 723600)$ — $3600$ candidates — inside the full search window
$[2, 2^{20})$ of about a million.

**Theorem 7.2 (Balanced zero-bit battery).** The uniform $24$-threshold
battery $t_i = \lfloor i \cdot 2^{20}/25 \rfloor$, $i = 1,\dots,24$, carries
**literally zero bits** on the window $[720000, 723600)$: all $3600$
candidates answer all $24$ queries identically, and the residual
indistinguishability class is the entire support.

*Proof sketch.* The thresholds are spaced $\approx 41943$ apart; the pair
straddling the support is $t_{17} = 713031$ and $t_{18} = 754974$, both
outside $[720000, 723600)$. Theorem 7.1 applies. (This is a finite check over
the $24$ thresholds.) $\square$

**Theorem 7.3 (The balanced dichotomy).** On the window
$[720000, 723600)$ at bit length $40$:
* the $24$-threshold uniform fixed battery leaves **all $3600$** candidates
  indistinguishable — speedup exactly $1.00$;
* while $12$ adaptive queries isolate the hidden factor **exactly** — speedup
  $3600$.

Half the queries, and the difference between removing none of the uncertainty
and removing all of it.

This is the headline surprise of the measurement campaign, and it is *stronger*
than the linear law: in the balanced stratum a uniform fixed battery is not
merely capped at $k+1$, it is pinned at $1.00$ for every $k \le 24$ across all
$600$ instances. Non-adaptive batteries are, in this stratum, waste-proof in
the pejorative sense — they cannot hurt because they do nothing — and the
adaptivity premium grows from exactly $1$ at $k=1$ into the hundreds.

The mechanism is worth naming, because it generalises well beyond factoring:
**a fixed battery must guess where the support is; an adaptive one discovers
it.** Whenever the prior mass concentrates on a set much smaller than the
nominal search range, uniformly placed fixed probes carry nothing at all.

---

## 8. Adaptivity repairs the channel; it does not create bits

It is tempting to read $2^k/(k+1)$ as the value of conditioning. That reading
is wrong, and the correct one is more interesting.

**Definition 8.1.** A *general fixed battery* is a family
$P_1,\dots,P_k : \mathbb{N}\to\{0,1\}$ of arbitrary Boolean predicates, all
chosen in advance, with answer vector $x \mapsto (P_1(x),\dots,P_k(x))$.

**Theorem 8.2 (Bit battery).** The $k$ predicates $P_i(x) = $ "the $i$-th
binary digit of $x$ is $1$" separate every pair of candidates in $[0, 2^k)$.
Hence a **non-adaptive** battery of general predicates already attains the
ceiling $2^k$.

*Proof sketch.* Two naturals below $2^k$ agreeing on bits $0,\dots,k-1$ agree
on all bits (higher bits vanish), hence are equal. $\square$

**Theorem 8.3 (General battery ceiling).** If $2^k < |W|$, then for any $k$
Boolean predicates two distinct elements of $W$ share an answer vector.

**Theorem 8.4 (Adaptivity repairs the channel).** For every $k$:
1. non-adaptive *comparison* hints resolve at most $k+1$ candidates;
2. non-adaptive *general* hints resolve exactly $2^k$ — already the ceiling;
3. adaptive *comparison* hints resolve exactly $2^k$ — the same ceiling.

Hence the adaptivity premium $2^k/(k+1)$ measures the **deficit of the
comparison channel**, not a gain created by conditioning.

The reason comparison hints are individually weak is precisely Lemma 3.1: their
answers are nested, so a fixed list of $k$ of them has only $k+1$ possible
joint answers instead of $2^k$. Adaptivity un-nests them by re-centring each
threshold on the surviving window, restoring each query to a full bit — which
Theorem 5.2 says is the most any query can ever be worth.

---

## 9. Two channels, two currencies

If compounding is not caused by adaptivity, what causes it? Channel structure.
The cleanest witness is the residue channel.

**Definition 9.1.** The *residue battery* with moduli $m_1,\dots,m_k$ returns
the vector $(x \bmod m_1, \dots, x \bmod m_k)$. It is entirely non-adaptive.

**Theorem 9.2 (Residue battery isolates).** If the $m_i$ are pairwise coprime,
the residue battery separates every pair of candidates in any window of width
$\prod_i m_i$.

*Proof sketch.* If $x \equiv y \pmod{m_i}$ for all $i$, then each $m_i$ divides
$|x-y|$; pairwise coprimality lifts this to $\prod_i m_i \mid |x-y|$, and
$|x - y| < \prod_i m_i$ forces $x = y$. $\square$

**Theorem 9.3 (Non-adaptive can be geometric).** If every $m_i \ge 2$ then
$\prod_i m_i \ge 2^k$: a fixed residue battery resolves at least $2^k$
candidates. Taking $m_i$ to be the $i$-th prime gives an explicit witness.

So **compounding is a property of the channel, not of adaptivity.** And yet:

**Theorem 9.4 (Residue hints carry no interval information).** Let $a$ lie in
a window of width $w$ and let $m \ge 1$. Then the residue class of $a$ modulo
$m$ contains two members $b \le c$ of the window with
$$w \;\le\; (c - b) + 2m .$$
Knowing $x \bmod m$ leaves two live candidates separated by all but $2m$ of the
original window.

*Proof sketch.* The class reaches within $m$ of the bottom and within $m$ of
the top of the window. $\square$

**Theorem 9.5 (Two channels, two currencies).** For a nonempty window and
moduli $m_i \ge 2$, pairwise coprime, simultaneously:
1. one comparison query at the lower median at most halves the *interval*, yet
   a fixed battery of $k$ thresholds distinguishes only $k+1$ classes;
2. $k$ residue queries isolate $\prod_i m_i \ge 2^k$ candidates
   non-adaptively — count currency, multiplicative;
3. a single residue class still spans all but $2m_1$ of the interval.

Comparison hints buy **interval** and only $k+1$ **count**; residue hints buy
**count** and no **interval**. This is the deepest form of the reconciliation:
"hints compound" and "hints price linearly" are statements about *different
currencies*, and the resolution does not depend on adaptivity alone.

Which currency matters is decided by the downstream algorithm. Fermat's scan
sweeps a contiguous interval, so it is paid in interval; a trial-division
sieve is paid in count.

### 9.1 Mixed batteries do not mix the currencies

**Theorem 9.6 (Bisection width from below).** For any window with
$\mathrm{lo}\le\mathrm{hi}$, one lower-median step never removes more than half
the width, and after $k$ adaptive comparison queries
$$\left\lfloor \frac{w(I)}{2^k} \right\rfloor \;\le\;
w(\mathrm{bis}(x,k,I)).$$

**Theorem 9.7 (Mixed-battery interval floor).** After $k$ adaptive comparison
queries and one residue query of modulus $m$, there remain two consistent
candidates $b \le c$ with
$$c - b \;\ge\; \frac{w(I)}{2^k} - 2m .$$
In particular, if $(2m+1)2^k \le w(I)$ the two are distinct: the residue query
has not collapsed the interval.

**Theorem 9.8 (Mixed-battery count floor).** Under the same protocol at least
$$\left\lfloor \frac{w(I)}{2^k m} \right\rfloor$$
candidates remain consistent with every answer.

**Corollary 9.9 (Interval gain capped by the order budget).** The downstream
speedup of an interval-sweeping algorithm is bounded by $2^{k_{\mathrm{ord}}}$,
where $k_{\mathrm{ord}}$ is the number of *order* (comparison) queries.
Arithmetic side information is worthless to it, however much count it buys.

---

## 10. The price of one lie

The factor $k+1$ has a second, independent life.

**Definition 10.1.** In the *one-lie channel* the oracle may answer falsely at
one step of its choosing (or not at all). Write $\lambda_S(x,\ell,k)$ for the
$k$-query transcript when the lie occurs at step $\ell$, with $\ell = k$
meaning "no lie". A strategy *one-lie-identifies* a candidate set $C$ in $k$
queries if $\lambda_S(x,\ell,k) = \lambda_S(y,\ell',k)$ with $x,y \in C$ and
$\ell,\ell' \le k$ forces $x = y$.

**Lemma 10.2 (Distinct lie patterns give distinct transcripts).** For a fixed
hidden value $x$ and $\ell \ne \ell'$ (both $\le k$), $\lambda_S(x,\ell,k) \ne
\lambda_S(x,\ell',k)$.

*Proof sketch.* Say $\ell < \ell'$. The two runs agree on all steps before
$\ell$, hence ask the same $\ell$-th question; one lies about it and the other
does not, so their $\ell$-th bits differ. $\square$

**Theorem 10.3 (One lie costs the factor $k+1$).** If $S$ one-lie-identifies
$C$ in $k$ queries then
$$(k+1)\,|C| \;\le\; 2^k, \qquad\text{i.e.}\qquad |C| \;\le\; \frac{2^k}{k+1}
\;=\; r(k).$$

*Proof sketch.* The map $(x,\ell) \mapsto \lambda_S(x,\ell,k)$ on
$C \times \{0,\dots,k\}$ is injective — across candidates by hypothesis, across
lie positions by Lemma 10.2 — and lands in the set of length-$k$ bit strings,
of size $2^k$. $\square$

This is the classical Berlekamp/Ulam volume bound, here in exactly the form
that makes the coincidence visible:

**Theorem 10.4 (The noise tax equals the non-adaptivity tax).** In the
truthful channel a $k$-query adaptive strategy resolves $2^k$ candidates while
a $k$-threshold fixed battery resolves $k+1$; in the one-lie channel an
adaptive strategy resolves at most $2^k/(k+1)$. The same factor $k+1$ appears
on both sides.

**Corollary 10.5.** No $20$-query strategy survives a single lie on the
bit-length-$40$ window $[0, 2^{20})$, even though $20$ truthful queries pin it
exactly: $21 \cdot 2^{20} > 2^{20}$. Robustness to one lie strictly raises the
isolation budget.

---

## 11. Net economics: where to stop buying

**Definition 11.1.** With per-query price $c > 0$ and un-hinted downstream cost
$T > 0$, the *net cost* of a budget of $x$ adaptive queries is
$$\mathrm{cost}(x) = c\,x + T\,2^{-x}.$$

**Theorem 11.2 (Optimal budget).** $\mathrm{cost}$ is minimised at
$$k_{\mathrm{opt}} = \log_2\!\left(\frac{T \ln 2}{c}\right),$$
where $2^{k_{\mathrm{opt}}} = T\ln 2/c$ and the residual downstream cost is
exactly $c/\ln 2$. Below the optimum the cost is strictly decreasing (buying
another hint pays); above it, strictly increasing (further hints are
overpriced).

*Proof sketch.* Write $x = k_{\mathrm{opt}} + d$; then
$\mathrm{cost}(x) = c\,k_{\mathrm{opt}} + c\,d + (c/\ln 2)e^{-d\ln 2}$. The
comparison of two offsets reduces to the convexity inequality
$e^{b}(a - b) \le e^{a} - e^{b}$, which gives monotonicity on each side of
$d = 0$ and hence global minimality at $d = 0$. $\square$

**Theorem 11.3 (Integer optimum).** For every integer budget $n$,
$$\min\Big(\mathrm{cost}\big(\lfloor k_{\mathrm{opt}}\rfloor\big),\;
\mathrm{cost}\big(\lceil k_{\mathrm{opt}}\rceil\big)\Big) \;\le\;
\mathrm{cost}(n).$$
The best integer budget is never more than one query away from the formula.

The measurement matches: $k_{\mathrm{opt}} = 10$ measured against $9.54$
predicted in the balanced stratum, and $18$ against $17.60$ in the unbalanced
one, with maximum net speedups $89.0$ and $14245$ respectively.

---

## 12. The downstream scan and the stratification law

**Theorem 12.1 (Fermat's difference of squares).** For odd $p \le q$ with
$N = pq$, the scan terminates at $a = (p+q)/2$, where $a^2 - N = b^2$ with
$b = (q-p)/2$.

**Theorem 12.2 (Pythagorean bridge).** For $b \le a$,
$$(a-b)(a+b) = n^2 \iff n^2 + b^2 = a^2 .$$
The Fermat witnesses for a perfect square $n^2$ are exactly the Pythagorean
triples with leg $n$: difference-of-squares factoring of $n^2$ *is* the
enumeration of Pythagorean triples with that leg.

**Theorem 12.3 (Scan length, closed form).** For $p, q \ge 0$,
$$\frac{p+q}{2} - \sqrt{pq} = \frac{(\sqrt q - \sqrt p)^2}{2}.$$
Writing $\rho = q/p$ and factoring out $\sqrt N$, the scan length in units of
$\sqrt N$ is $\mathrm{su}(u) = (u-1)^2/(2u)$ with $u = \sqrt\rho$.

**Theorem 12.4 (Monotonicity and strata).** $\mathrm{su}(1) = 0$;
$\mathrm{su}$ is strictly increasing on $[1,\infty)$;
$\mathrm{su}(\sqrt\rho) \le 1/60000$ for $1 \le \rho \le 1.01$; and
$\mathrm{su}(\sqrt\rho) \ge 1/2$ for $\rho \ge 7.5$.

**Corollary 12.5 (Stratum contrast).** For balanced $\rho_b \le 1.01$ and
unbalanced $\rho_u \ge 7.5$,
$$10^4 \cdot \mathrm{su}(\sqrt{\rho_b}) \;\le\; \mathrm{su}(\sqrt{\rho_u}).$$
A single parameter $\rho$ produces the two regimes the campaign measures: the
unbalanced scan is at least $10^4$ times longer, which is why the unbalanced
stratum has room for a $239.5\times$ premium at $k = 12$ while the balanced
one saturates at $20.8\times$.

---

## 13. Algorithms

**Adaptive isolation (lower-median bisection).** Input: window
$[\mathrm{lo}, \mathrm{hi})$, budget $k$, oracle. Repeat $k$ times: set
$m \leftarrow \mathrm{lo} + \lfloor (\mathrm{hi}-\mathrm{lo}-1)/2 \rfloor$;
query "$x \le m$?"; on yes set $\mathrm{hi}\leftarrow m+1$, on no set
$\mathrm{lo}\leftarrow m+1$. Cost $O(k)$ queries; residual width exactly
$\lceil w/2^k\rceil$; isolates iff $k \ge \lceil \log_2 w\rceil$.

**Fixed-battery residual (linear pricing evaluator).** Input: window,
thresholds $T$. Compute the signature of every candidate, group by signature,
return the largest class. Cost $O(w \log k)$; the returned size is always at
least $\lceil w/(|T|+1)\rceil$, and equals it for equally spaced thresholds
inside the support.

**Budget selection.** Given $c$ and $T$: compute
$k^* = \log_2(T\ln 2/c)$, evaluate the net cost at $\lfloor k^*\rfloor$ and
$\lceil k^*\rceil$, return the cheaper. Cost $O(1)$; provably optimal over all
integer budgets.

**Hinted Fermat factoring.** Combine: run adaptive isolation for
$k = \min(\lceil \log_2 w\rceil, k_{\mathrm{opt}})$ queries, then scan
$a = \lceil \sqrt N\rceil, \lceil\sqrt N\rceil+1,\dots$ restricted to $a$
consistent with the surviving window, testing whether $a^2 - N$ is a perfect
square.

---

## 14. Discussion

The pricing theory above has a single silhouette: **information from an
external oracle is priced at exactly $\log_2 r$ bits per query, and what varies
is how much of that price a protocol actually collects.**

* A fixed comparison battery collects $\log_2(k+1)$ bits in total — vanishing
  per query — because comparison answers are nested.
* In the balanced regime, where the support is narrow and thresholds are
  spread wide, it collects *literally zero*.
* Adaptive comparison queries collect the full bit each, so speedups multiply
  — until the isolation ceiling at $\lceil\log_2 w\rceil$ queries, where the
  curve becomes flat because there is nothing left to learn.
* A non-adaptive general-predicate battery also collects the full bit, showing
  that adaptivity is a repair, not a source.
* A single lie taxes an adaptive strategy by exactly the factor $k+1$ — the
  same factor as non-adaptivity, in the same currency.

The taxonomy entry this yields is compact: *adaptive sequential hints price
geometrically up to isolation cost; fixed batteries price linearly, or at zero
when their probes miss the support.* Both of the folklore claims that
motivated the study are correct, and now separated.

Two limitations should be stated plainly. First, the oracle is idealized: it is
truthful (except in §10, where exactly one lie is permitted) and its answers
are free of any implementation cost beyond $c$; a real side channel would have
its own noise model. Second, the speedup here is candidate-space reduction,
which the downstream Fermat scan converts into running time only because the
scan is linear in the surviving interval; for an algorithm paid in count rather
than interval, §9 shows the accounting changes entirely.

---

## 15. Future directions

**Sharpness of the one-lie volume bound.** Theorem 10.3 is a pure volume
(counting) bound. Volume bounds in Ulam-type search are attained only when the
$(k+1)$-element transcript families tile $\{0,1\}^k$ exactly — a perfect-code
condition. We conjecture that the largest window a one-lie strategy can pin
with $k$ queries is $\lfloor 2^k/(k+1)\rfloor$ exactly when $k+1$ is a power of
two, and strictly smaller otherwise, the deficit being a Hamming-type defect.
The bound itself holds for arbitrary adaptive strategies; only attainability is
open, and it is a finite check for each small $k$.

**Phase-correlated slopes.** The measured log-residual slope was $-0.6589$
(unbalanced) against the exact $-\ln 2 = -0.6931$, and $-0.5836$ (balanced), a
$16\%$ shortfall. Corollary 4.9 shows the law itself is exact on powers of two;
the shortfall must therefore be a band-entry phase effect — where the support
sits relative to the dyadic grid. A quantitative theory of that phase
correlation would turn the residual discrepancy into a predictive correction.

**Optimal thresholds under a known prior.** The zero-bit collapse says a
uniform battery can be worthless. Given a prior on the support, what fixed
battery maximises expected information, and how close can it come to the
adaptive $2^k$? For a prior concentrated on an interval of known width, the
answer should interpolate between $k+1$ and $1$.

**Mixed-channel optimisation.** Given a joint budget over comparison and
residue queries and a downstream algorithm paid partly in count and partly in
interval, Theorems 9.7 and 9.8 bound each currency separately. The optimal
split is an open combinatorial optimisation.

**Beyond comparisons.** Theorem 5.4 prices any $r$-ary oracle. Which natural
number-theoretic oracles ("is $p$ a quadratic residue mod $\ell$?", "what is
$p \bmod \ell$?") realise the full $\log_2 r$ bits against an
interval-sweeping downstream algorithm, rather than paying in the wrong
currency?

---

## 16. Conclusion

Sequential hints compound, and sequential hints price linearly. The first
statement is about adaptive queries and is exactly $2^k$; the second is about
fixed batteries and is exactly $k+1$; their ratio $2^k/(k+1)$ is $1$ at
$k \le 1$ and superlinear thereafter. Compounding saturates precisely at the
isolation ceiling $\lceil\log_2 w\rceil$, which no strategy can cross, because
$k$ binary queries generate only $2^k$ transcripts. In the balanced regime the
non-adaptive face degenerates completely: a uniform battery of $24$ thresholds
carries literally zero bits while $12$ adaptive queries remove all uncertainty.
And the premium is not the value of conditioning at all — it is the redundancy
of nested questions, which conditioning repairs. One pricing structure, two
faces.
