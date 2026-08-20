# Seed Fractions and Level Sets: An Exact Finite Calculus for Randomised Cryptographic Arguments

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

Randomised cryptographic arguments are routinely phrased in the language of
probability, but in the finite regime where they are actually instantiated they
are statements about the *fraction of a finite seed space* on which an event
occurs. We develop this bookkeeping layer exactly: for a finite seed space
$\Omega$ and a decidable event $A$ we study the rational-valued functional
$\operatorname{frac}_\Omega(A) = |\{s \in \Omega : A(s)\}| / |\Omega|$, establish
its measure-like calculus together with the precise non-emptiness guards under
which each normalisation law holds, and prove the structural result on which
everything else rests: the level sets of a cost function bounded by $B$ partition
the seed space, so their fractions sum to $1$. From this single identity we derive
the sublevel partial-sum identity, Markov's inequality in level-set form, and both
layer-cake identities for the average cost.

We then instantiate the calculus in three settings. (i) **Bounded witness
search:** we define the search cost, prove the guarding facts and an exactness
("honesty") statement, and show that Markov's inequality applied to a bounded
search yields the bound $B/t$, which is *provably vacuous* on its entire range;
we replace it with a distribution-sensitive *first-probe savings* bound
$\mathbb{E}[\mathrm{cost}] \le B - (B-1)p$, where $p$ is the fraction of seeds
solved on the first probe. We also prove that $k$-fold amplification is an exact
identity, $1 - (1-\varepsilon)^k$, on a finite seed space. (ii) **Sampled
monitoring:** we prove that a guarded, periodically healed system under constant
attack is compromised at time $n \ge 1$ exactly when $n$ is not a checkpoint, and
deduce the exact compromised fraction of the window $(0, N]$, namely
$\frac{k-1}{k} + \frac{N \bmod k}{kN}$; the folklore value $(k-1)/k$ is therefore
a strict lower bound attained *if and only if* $k \mid N$, with a uniform $1/N$
envelope; and we prove a dichotomy: period $k = 1$ gives compromised fraction $0$
while every $k \ge 2$ gives at least $1/2$. (iii) **Rewinding and knowledge
extraction:** we prove that the global accepting fraction of a two-move protocol
is the average of its row fractions, that an accepting fraction strictly above
$1/|C|$ forces a randomness accepting two distinct challenges (and that this
threshold is sharp, realised by an explicit configuration), and a general
heavy-row splitting lemma: for every $\alpha > 0$, at least a $(1-\alpha)e$
fraction of rows are $\alpha e$-heavy. Combining these gives a quantitative
rewinding theorem: accepting fraction above $2/|C|$ guarantees that an $e/2$
fraction of the prover's random tapes are individually extractable.

**Keywords:** seed fraction, level set, layer cake, bounded search, rewinding,
special soundness, sampled monitoring, amplification.

---

## 1. Introduction

### 1.1 Probability, or counting?

A typical claim in randomised cryptography reads: *with probability at least
$\varepsilon$ over the seed, the adversary is caught / the protocol accepts / the
extractor succeeds.* When the scheme is instantiated, the seed ranges over a
finite set: keys of a fixed length, challenges from a fixed set, a fixed number of
coin flips. The claim is then a statement about the cardinality of a subset of a
finite set, divided by the cardinality of that set. It is arithmetic in
$\mathbb{Q}$.

Treating it as arithmetic rather than as measure theory has three benefits.
First, every statement becomes *exact*: one obtains identities where the
probabilistic idiom offers estimates. Second, every statement becomes *decidable*
on concrete instances: a claimed bound can be checked by exhaustive enumeration on
a small seed space, which is an unusually effective way to find errors. Third — and
this is the recurring theme of the paper — the degenerate cases become visible.
A fraction with denominator $0$ is not a probability; it is a number that the
convention $x/0 = 0$ silently sets to zero, and any normalisation claim about it is
false.

### 1.2 What is developed here

The paper has a foundational part and three applications.

The foundational part (Section 2) develops the functional
$\operatorname{frac}_\Omega$ and the *level-set decomposition*: a bounded cost
function stratifies the seed space, and the fractions of the strata sum to $1$.
This one identity yields the sublevel identity, Markov's inequality, and both
layer-cake formulas for the average cost.

The applications are: bounded witness search stratified by probe count
(Section 3); the compromised fraction of a sampled-monitoring run (Section 4); and
heavy rows, the rewinding threshold and knowledge extraction (Section 5).
Section 6 collects the algorithmic content, Section 7 discusses the negative
results, and Section 8 lists open directions.

### 1.3 Three failure modes, and their remedies

A theme worth stating up front. Each application below exposes a distinct way in
which the informal idiom fails, and the finite calculus repairs it.

| Failure mode | Where it appears | Remedy |
|---|---|---|
| Vacuity on an empty seed space | Every normalisation law | Explicit non-emptiness guards (Section 2.2) |
| A correct but vacuous bound | Markov on a bounded search | Distribution-sensitive first-probe bound (Section 3.4) |
| A folklore constant that is only a limit | $(k-1)/k$ compromised fraction | Exact residue formula and alignment criterion (Section 4.3) |

---

## 2. The seed-fraction calculus

### 2.1 Definitions

**Definition 2.1 (Seed space, good seeds, fraction).** A *seed space* is a finite
set $\Omega$ (of a possibly infinite ambient type). For a decidable event
$A$ on seeds, the *good seeds* are
$$G_\Omega(A) = \{s \in \Omega : A(s)\},$$
and the *seed fraction* is the rational number
$$\operatorname{frac}_\Omega(A) = \frac{|G_\Omega(A)|}{|\Omega|} \in \mathbb{Q},$$
with the convention $x/0 = 0$ when $\Omega = \emptyset$.

**Definition 2.2 (Cost function and level sets).** A *cost* is a function
$c : \Omega \to \mathbb{N}$; it is *bounded by $B$* if $c(s) \le B$ for all
$s \in \Omega$. The *level set* at $i$ is
$$L_i = \{s \in \Omega : c(s) = i\},$$
which is exactly $G_\Omega(c = i)$.

**Definition 2.3 (Average cost).** The *average cost* of $c$ on $\Omega$ is
$$\mathbb{E}_\Omega[c] = \frac{1}{|\Omega|}\sum_{s \in \Omega} c(s) \in \mathbb{Q}.$$

### 2.2 Elementary calculus, with guards

**Proposition 2.4 (Basic laws).** For every finite $\Omega$ and decidable events
$A, P, Q$:

1. $0 \le \operatorname{frac}_\Omega(A) \le 1$.
2. *(Monotonicity.)* If $P(s) \Rightarrow Q(s)$ for all $s \in \Omega$, then
   $\operatorname{frac}_\Omega(P) \le \operatorname{frac}_\Omega(Q)$.
3. *(Finite additivity.)* If no $s \in \Omega$ satisfies both $P$ and $Q$, then
   $\operatorname{frac}_\Omega(P \vee Q) = \operatorname{frac}_\Omega(P) + \operatorname{frac}_\Omega(Q)$.
4. *(Congruence.)* If $P(s) \leftrightarrow Q(s)$ for all $s \in \Omega$, then
   $\operatorname{frac}_\Omega(P) = \operatorname{frac}_\Omega(Q)$.

Moreover, **provided $\Omega \ne \emptyset$**:

5. $\operatorname{frac}_\Omega(A) = 1$ iff every $s \in \Omega$ satisfies $A$.
6. $\operatorname{frac}_\Omega(A) = 0$ iff no $s \in \Omega$ satisfies $A$.
7. *(Complementation.)* $\operatorname{frac}_\Omega(A) + \operatorname{frac}_\Omega(\neg A) = 1$.

*Proof sketch.* (1)–(4) are immediate from $G_\Omega(A) \subseteq \Omega$,
monotonicity of cardinality under inclusion, and the disjoint-union cardinality
law, each divided by $|\Omega| \ge 0$; none of them needs a nonzero denominator.
For (5)–(7) one divides by $|\Omega|$, which requires $|\Omega| > 0$: (5) is
$|G| = |\Omega|$ together with $G \subseteq \Omega$; (6) is $|G| = 0$; (7) is the
cardinality identity $|G_\Omega(A)| + |G_\Omega(\neg A)| = |\Omega|$. $\square$

**Remark 2.5 (The guards are load-bearing).** Items (5)–(7) *fail* for
$\Omega = \emptyset$: with the convention $x/0 = 0$ one gets
$\operatorname{frac}_\emptyset(\text{true}) = 0 \ne 1$, so the sure event has
fraction $0$ and complementation reads $0 + 0 = 1$. Every normalisation statement
in this paper therefore carries an explicit non-emptiness hypothesis. This is the
same guarding discipline that a bounded search applies to its budget, transplanted
to the counting layer.

**Remark 2.6 (What $\operatorname{frac}$ is not).** $\operatorname{frac}_\Omega$ is
not a measure; it is a rational-valued, finitely additive functional on the Boolean
algebra of decidable events. This is deliberate: it keeps every statement decidable
and exhaustively checkable on small instances, which is exactly what a concrete
soundness bound needs.

### 2.3 The level-set decomposition

**Theorem 2.7 (Level-Set Partition Theorem).** Let $c : \Omega \to \mathbb{N}$ be
bounded by $B$ on $\Omega$. Then
$$\sum_{i=0}^{B} |L_i| = |\Omega|,$$
and if in addition $\Omega \ne \emptyset$,
$$\sum_{i=0}^{B} \operatorname{frac}_\Omega(c = i) = 1.$$

*Proof sketch.* The map $c$ sends $\Omega$ into $\{0, 1, \dots, B\}$, so the fibres
$L_0, \dots, L_B$ are pairwise disjoint with union $\Omega$; counting fibrewise
gives the cardinality identity. Dividing by $|\Omega| > 0$ and using linearity of
division over a finite sum gives the fraction identity. $\square$

This is the structural heart of the paper: everything below is an application of
Theorem 2.7 to a specific cost function.

**Theorem 2.8 (Sublevel identity).** For every $t \in \mathbb{N}$ and every cost
$c$ (no boundedness needed),
$$\operatorname{frac}_\Omega(c \le t) = \sum_{i=0}^{t} \operatorname{frac}_\Omega(c = i).$$

*Proof sketch.* Apply fibrewise counting to the subset $\{c \le t\}$ with target
$\{0, \dots, t\}$, and observe that the fibre of $i \le t$ inside $\{c \le t\}$ is
the full level set $L_i$. Divide by $|\Omega|$. $\square$

**Theorem 2.9 (Markov's inequality, level-set form).** For $t \ge 1$,
$$\operatorname{frac}_\Omega(c \ge t) \;\le\; \frac{\sum_{s\in\Omega} c(s)}{t\,|\Omega|} \;=\; \frac{\mathbb{E}_\Omega[c]}{t}.$$

*Proof sketch.* Write $G = G_\Omega(c \ge t)$. Each $s \in G$ contributes at least
$t$ to $\sum_{s \in \Omega} c(s)$, and the remaining terms are nonnegative, so
$t\,|G| \le \sum_{s \in \Omega} c(s)$. Divide by $t\,|\Omega|$. The case
$\Omega = \emptyset$ is trivial as both sides are $0$. $\square$

### 2.4 Layer cake

**Theorem 2.10 (Weighted layer cake).** If $c$ is bounded by $B$ on a nonempty
$\Omega$, then
$$\mathbb{E}_\Omega[c] = \sum_{i=0}^{B} i \cdot \operatorname{frac}_\Omega(c = i).$$

**Theorem 2.11 (Tail layer cake).** Under the same hypotheses,
$$\mathbb{E}_\Omega[c] = \sum_{t=1}^{B} \operatorname{frac}_\Omega(c \ge t).$$

*Proof sketch.* For Theorem 2.10, group the sum $\sum_{s} c(s)$ by fibres of $c$;
on $L_i$ each term equals $i$, so the total is $\sum_i i |L_i|$; divide by
$|\Omega|$. For Theorem 2.11, exchange the order of summation in
$$\sum_{s \in \Omega} c(s) = \sum_{s \in \Omega} \big|\{t : 1 \le t \le c(s)\}\big| = \sum_{t=1}^{B} \big|\{s \in \Omega : c(s) \ge t\}\big|,$$
using $c(s) \le B$ to see that the inner index set is exactly
$\{1, \dots, c(s)\}$, of cardinality $c(s)$; divide by $|\Omega|$. $\square$

Theorem 2.11 is the workhorse: it converts an average into a sum of tail
fractions, each of which is a counting quantity that the level-set machinery can
bound directly.

### 2.5 Independent repetition

**Theorem 2.12 (Product law).** Let $\Omega$ be a finite seed space, $A$ a
decidable event, and $k \in \mathbb{N}$. Over the product seed space $\Omega^k$,
$$\operatorname{frac}_{\Omega^k}\big(\forall i,\; A(s_i)\big) = \big(\operatorname{frac}_\Omega(A)\big)^k.$$
No non-emptiness guard is needed: for $k = 0$ both sides are $1$.

*Proof sketch.* The subset of $\Omega^k$ on which all coordinates are good is
exactly $G_\Omega(A)^k$, so its cardinality is $|G_\Omega(A)|^k$, while
$|\Omega^k| = |\Omega|^k$; the quotient is the $k$-th power of the quotient. $\square$

---

## 3. Bounded witness search

### 3.1 The model

**Definition 3.1.** Let $f : \Omega \times \mathbb{N} \to \{\text{true},\text{false}\}$
be a decidable *witness predicate* and $B \in \mathbb{N}$ a *budget*. For a seed
$s$ set
$$W(s) = \{w < B : f(s, w)\},$$
the set of successful probes below the budget. The search *succeeds* on $s$ —
written $\mathrm{Found}(s)$ — if $W(s) \ne \emptyset$. The *search cost* is
$$\mathrm{cost}(s) = \begin{cases} \min W(s) + 1, & W(s) \ne \emptyset,\\ B, & W(s) = \emptyset.\end{cases}$$

This models the standard "probe $0, 1, 2, \dots$ and stop at the first success"
loop: the cost is the number of probes actually performed.

### 3.2 Guarding facts and honesty

**Proposition 3.2.** For all $f, B, s$:

1. $\mathrm{cost}(s) \le B$ (the search never exceeds its budget);
2. if $\mathrm{cost}(s) < B$ then $\mathrm{Found}(s)$ (early termination certifies
   success);
3. if $\neg\mathrm{Found}(s)$ then $\mathrm{cost}(s) = B$ (failure costs the full
   budget);
4. if $B \ge 1$ and $f(s, 0)$ holds then $\mathrm{cost}(s) = 1$.

*Proof sketch.* (1) If $W(s)$ is nonempty its minimum is $< B$, so the cost is
$\le B$; otherwise the cost is $B$ by definition. (3) is the definition and (2) is
its contrapositive. (4) $0 \in W(s)$, so $\min W(s) = 0$. $\square$

**Theorem 3.3 (Honesty).** If $\Omega \ne \emptyset$ and every seed $s \in \Omega$
carries a witness below the budget — i.e. there is $w < B$ with $f(s,w)$ — then
$$\operatorname{frac}_\Omega(\mathrm{Found}) = 1.$$

*Proof sketch.* The hypothesis says every seed is good, so Proposition 2.4(5)
applies. $\square$

The statement is an equality, not an asymptotic: an exhaustive guarantee at the
level of seeds becomes an exhaustive guarantee at the level of fractions.

### 3.3 Cost stratification

Since $\mathrm{cost}$ is bounded by $B$ (Proposition 3.2(1)), Theorems 2.7, 2.8 and
2.11 apply verbatim.

**Corollary 3.4.** For $\Omega \ne \emptyset$,
$$\sum_{i=0}^{B} \operatorname{frac}_\Omega(\mathrm{cost} = i) = 1,$$
and for every $t$,
$$\operatorname{frac}_\Omega(\mathrm{cost} \le t) = \sum_{i=0}^{t} \operatorname{frac}_\Omega(\mathrm{cost} = i),$$
and
$$\mathbb{E}_\Omega[\mathrm{cost}] = \sum_{t=1}^{B} \operatorname{frac}_\Omega(\mathrm{cost} \ge t).$$

The middle identity — the fraction of seeds solved within $t$ probes is the partial
sum of the level fractions — is the *practical* statement: it converts a
performance profile into a cumulative distribution with no probabilistic
scaffolding.

### 3.4 A negative result, recorded rather than hidden

**Proposition 3.5 (Markov tail bound for a bounded search).** For every witness
predicate $f$, every budget $B$ and every $t \ge 1$,
$$\operatorname{frac}_\Omega(\mathrm{cost} \ge t) \;\le\; \frac{B}{t}.$$

*Proof sketch.* Apply Theorem 2.9 and bound the numerator using
$\sum_{s\in\Omega}\mathrm{cost}(s) \le |\Omega| \cdot B$. $\square$

This bound is true, requires no hypothesis whatsoever on $f$, and is **vacuous on
its entire range**. For $t \le B$ the right-hand side is $\ge 1$ and so is implied
by $\operatorname{frac} \le 1$. For $t > B$ the left-hand side is already $0$
because $\mathrm{cost} \le B$. The honest reading: Markov's inequality sees only
the mean, and for a bounded search the mean is capped by the same constant that
caps the cost pointwise. What the level-set machinery *does* provide for a bounded
search is the exact sublevel identity of Corollary 3.4, not a tail estimate.

We state Proposition 3.5 anyway, together with the reason it is weak, because a
recorded negative result prevents the same estimate from being reached for again.

### 3.5 First-probe savings: a shape-sensitive bound

**Theorem 3.6 (First-Probe Savings Bound).** Let $B \ge 1$ and $\Omega \ne \emptyset$,
and let $p = \operatorname{frac}_\Omega(f(\cdot,0))$ be the fraction of seeds solved
by the very first probe. Then
$$\mathbb{E}_\Omega[\mathrm{cost}] \;\le\; B - (B-1)\,p.$$

*Proof sketch.* Pointwise, $\mathrm{cost}(s) \le B - (B-1)\mathbb{1}[f(s,0)]$: if
$f(s,0)$ holds the cost is exactly $1 = B - (B-1)$ by Proposition 3.2(4), and
otherwise the cost is at most $B$. Summing over $\Omega$, the indicator sum is
$|G_\Omega(f(\cdot,0))|$, giving
$\sum_s \mathrm{cost}(s) \le |\Omega| B - (B-1)|G_\Omega(f(\cdot,0))|$; divide by
$|\Omega|$. $\square$

Theorem 3.6 is strictly stronger than the trivial bound $\mathbb{E} \le B$
whenever $p > 0$ and $B > 1$, and, unlike Markov, it is sensitive to the *shape* of
the cost distribution rather than only its mean. Numerically: with $B = 100$ and
$p = 1/2$, the bound gives $\mathbb{E} \le 50.5$, while Proposition 3.5 gives
nothing at any threshold.

The same argument generalises: if a $p_j$ fraction of seeds is solved on probe
$j+1$ exactly, then $\mathbb{E}[\mathrm{cost}] = \sum_j (j+1) p_j + B \cdot p_\perp$
with $p_\perp$ the failure fraction — which is just Theorem 2.10 for this cost.
Theorem 3.6 is the one-term truncation of that identity, and it is the term that
matters when the first probe is cheap and often decisive.

### 3.6 Exact amplification

**Theorem 3.7 (Exact Amplification Theorem).** Let $\Omega \ne \emptyset$ be a
finite seed space, $A$ a decidable event with one-shot fraction
$\varepsilon = \operatorname{frac}_\Omega(A)$, and $k \in \mathbb{N}$. Then over the
product seed space $\Omega^k$,
$$\operatorname{frac}_{\Omega^k}\big(\exists i,\; A(s_i)\big) = 1 - (1-\varepsilon)^k.$$

*Proof sketch.* The complement of "$\exists i, A(s_i)$" is "$\forall i, \neg A(s_i)$".
By the product law (Theorem 2.12) applied to $\neg A$, the latter has fraction
$(\operatorname{frac}_\Omega(\neg A))^k = (1-\varepsilon)^k$, using complementation
(Proposition 2.4(7)) on $\Omega$. Complementation on $\Omega^k$ — legitimate since
$\Omega^k$ is nonempty when $\Omega$ is — finishes. $\square$

**Remark 3.8.** The non-emptiness guard is load-bearing in the argument, not
decoration: the proof complements twice, once on $\Omega$ and once on $\Omega^k$,
and complementation (Proposition 2.4(7)) is exactly the law that fails on an empty
base space, where the convention $x/0=0$ assigns the sure event fraction $0$. On an
empty $\Omega$ the two sides of the identity happen to coincide (both are $0$,
since $\varepsilon = 0$ forces $1 - 1^k = 0$), but they do so by numerical accident
rather than for any structural reason, and no complementation-based proof reaches
them.

**Corollary 3.9 (Monotone amplification).** For $k \ge 1$,
$$\operatorname{frac}_\Omega(A) \;\le\; \operatorname{frac}_{\Omega^k}\big(\exists i,\;A(s_i)\big),$$
and the shortfall from $1$ decays geometrically like $(1-\varepsilon)^k$.

*Proof sketch.* Since $0 \le 1-\varepsilon \le 1$, we have
$(1-\varepsilon)^k \le (1-\varepsilon)$ for $k \ge 1$, so
$1 - (1-\varepsilon)^k \ge \varepsilon$. $\square$

Thus *any* positive one-shot advantage can be amplified arbitrarily close to $1$,
and the rate is exactly geometric — not bounded by a geometric, equal to one.

---

## 4. The compromised fraction of a sampled-monitoring run

### 4.1 The setting

Consider a guarded system executing a program that an adversary attempts to
subvert at every time step, together with a monitor that inspects and *heals* the
system at every multiple of a period $k \ge 1$ (the *checkpoints*). Healing
restores the system to a *sanctioned variant*: an element of a fixed finite
whitelist $S$ containing a base program $b$.

The security-relevant statistic is the fraction of the run during which the system
is in a malicious state. Fix an observation window
$$\mathrm{win}(N) = \{1, 2, \dots, N\},\qquad |\mathrm{win}(N)| = N.$$

Two hypotheses are in force throughout, and both matter:

- **(G1) Base membership:** $b \in S$.
- **(G2) Honesty of the whitelist:** no element of $S$ is malicious.

### 4.2 Compromised exactly off the checkpoints

**Theorem 4.1 (Characterisation of compromised times).** Assume (G1) and (G2).
Under a constant-attack adversary with monitoring period $k$, for every $n \ge 1$
the system is malicious at time $n$ **if and only if** $k \nmid n$.

*Proof sketch.* Write $n = p+1$. If $k \mid n$, the monitor heals at time $n$ and
the resulting state is a sanctioned variant, hence by (G2) not malicious. If
$k \nmid n$, no healing occurs at time $n$ and the accumulated attack leaves the
state malicious; this is the "attack window" direction. $\square$

Both directions are needed. The forward direction (healing genuinely disinfects) is
what converts a lower bound on the compromised fraction into an exact count, and it
is exactly where (G2) is used: if a sanctioned variant could itself be malicious,
the compromised set would be all of $\mathrm{win}(N)$ and the equivalence would be
false.

### 4.3 The exact compromised fraction

**Lemma 4.2 (Checkpoint count).** $|\{n \in \mathrm{win}(N) : k \mid n\}| = \lfloor N/k \rfloor$,
hence $\operatorname{frac}_{\mathrm{win}(N)}(k \mid \cdot) = \lfloor N/k \rfloor / N$.

**Theorem 4.3 (Compromised fraction, closed form).** Assume (G1), (G2) and
$N \ge 1$. Then
$$\operatorname{frac}_{\mathrm{win}(N)}(\text{compromised}) = \frac{N - \lfloor N/k\rfloor}{N}.$$

*Proof sketch.* By Theorem 4.1 and congruence (Proposition 2.4(4)), the
compromised event coincides on the window with $k \nmid n$; complement using
Proposition 2.4(7) and substitute Lemma 4.2. $\square$

**Theorem 4.4 (Monitoring-Window Residue Formula).** Assume (G1), (G2),
$N \ge 1$, $k \ge 1$. Then
$$\operatorname{frac}_{\mathrm{win}(N)}(\text{compromised}) = \frac{k-1}{k} + \frac{N \bmod k}{kN}.$$

*Proof sketch.* Substitute $N = k\lfloor N/k\rfloor + (N \bmod k)$ into
Theorem 4.3 and simplify: the leading term $(N - N/k)/N$ becomes $(k-1)/k$ and the
truncation remainder contributes $\frac{N \bmod k}{kN}$. $\square$

**Corollary 4.5 (Period alignment).** Under the same hypotheses,
$$\operatorname{frac}_{\mathrm{win}(N)}(\text{compromised}) = \frac{k-1}{k} \iff k \mid N .$$
In particular, over a whole number $m \ge 1$ of periods ($N = km$) the compromised
fraction is exactly $(k-1)/k$.

*Proof sketch.* The correction term $\frac{N \bmod k}{kN}$ is nonnegative and
vanishes iff $N \bmod k = 0$. $\square$

**Corollary 4.6 (Sharp two-sided bounds).** For $N, k \ge 1$,
$$\frac{k-1}{k} \;\le\; \operatorname{frac}_{\mathrm{win}(N)}(\text{compromised}) \;\le\; \frac{k-1}{k} + \frac{k-1}{kN},$$
and the fraction is $< 1$ as soon as $k \le N$ (i.e. as soon as the window contains
at least one checkpoint).

*Proof sketch.* Lower bound: the correction is nonnegative. Upper bound:
$N \bmod k \le k-1$. Strict inequality below $1$: the window then contains at least
one checkpoint, so at least one time is not compromised. $\square$

Thus the folklore value $(k-1)/k$ is a *lower bound*, never an upper bound, and it
is the uniform $N \to \infty$ limit with an explicit $O(1/N)$ envelope.

**Example 4.7.** With $k = 3$: for $N = 3$ the fraction is $2/3$; for $N = 4$ it is
$3/4$; for $N = 5$ it is $4/5$; for $N = 6$ it is $2/3$ again. The overshoot at
$N = 5$ is $4/5 - 2/3 = 2/15 = \frac{5 \bmod 3}{3 \cdot 5}$, exactly as
Theorem 4.4 predicts.

### 4.4 A dichotomy at $k = 1$

**Theorem 4.8 (Monitoring Dichotomy).** Assume (G1), (G2) and $N \ge 1$. Then
continuous monitoring gives
$$\operatorname{frac}_{\mathrm{win}(N)}(\text{compromised at period } 1) = 0,$$
while for every $k \ge 2$,
$$\operatorname{frac}_{\mathrm{win}(N)}(\text{compromised at period } k) \;\ge\; \tfrac12 .$$

*Proof sketch.* For $k=1$ every time is a checkpoint, so $\lfloor N/1\rfloor = N$
and Theorem 4.3 gives $0$. For $k \ge 2$, Corollary 4.6 gives the lower bound
$(k-1)/k \ge 1/2$. $\square$

There is no gentle degradation. The very first relaxation away from checking every
tick surrenders half the run, and the loss then increases monotonically toward $1$.

**Non-vacuity.** The guards (G1)–(G2) are satisfiable — a singleton whitelist
consisting of a constant program is honest — and the formula is realised: with
period $k=3$ over two full periods ($N = 6$), the compromised fraction is exactly
$2/3$.

---

## 5. Rewinding, heavy rows and knowledge extraction

### 5.1 The product seed space of a two-move protocol

In a two-move (sigma-style) protocol the prover picks randomness $r$ from a finite
set $R$, the verifier picks a challenge $c$ from a finite set $C$, and a decidable
predicate $\mathrm{acc}(r,c)$ says whether the transcript is accepting. The seed
space is the product grid $R \times C$; the accepting configuration is a subset of
it. Write
$$e = \operatorname{frac}_{R \times C}(\mathrm{acc})$$
for the *global accepting fraction* and, for each $r$,
$$e_r = \operatorname{frac}_{C}(\mathrm{acc}(r,\cdot))$$
for the *row fraction*.

**Theorem 5.1 (Row decomposition and averaging).** $|G_{R\times C}(\mathrm{acc})| = \sum_{r \in R} |G_C(\mathrm{acc}(r,\cdot))|$,
and if $R \ne \emptyset$,
$$e = \frac{1}{|R|}\sum_{r \in R} e_r .$$

*Proof sketch.* The first identity is the level-set decomposition of the grid along
the cost function $(r,c) \mapsto r$ — i.e. counting the accepting cells row by row.
Dividing by $|R\times C| = |R||C|$ and recognising each $|G_C(\mathrm{acc}(r,\cdot))|/|C|$
as $e_r$ gives the average. $\square$

*The global accepting fraction is the average of the row fractions.* This single
sentence is what makes the rest of the section possible.

### 5.2 The rewinding threshold, and its sharpness

An extractor for a two-move protocol needs a *collision*: one randomness $r$
accepting on two **distinct** challenges. Two accepting transcripts sharing a
commitment but differing in the challenge are exactly the data from which special
soundness computes a witness.

**Lemma 5.2.** If no two distinct challenges are accepted by $r$, then
$|G_C(\mathrm{acc}(r,\cdot))| \le 1$.

**Theorem 5.3 (Rewinding Threshold Theorem).** Let $R, C \ne \emptyset$. If
$$e > \frac{1}{|C|},$$
then there exist $r \in R$ and distinct $c_1, c_2 \in C$ with $\mathrm{acc}(r,c_1)$
and $\mathrm{acc}(r,c_2)$.

*Proof sketch.* Suppose not. By Lemma 5.2 every row has at most one accepting
cell, so by Theorem 5.1 the accepting set has cardinality at most $|R|$, whence
$e \le |R|/(|R||C|) = 1/|C|$ — contradicting the hypothesis. $\square$

**Theorem 5.4 (Sharpness of the threshold).** Let $R, C \ne \emptyset$ and let
$\varphi : R \to C$ be arbitrary with $\varphi(r) \in C$ for all $r \in R$. For the
accepting configuration $\mathrm{acc}(r,c) \iff c = \varphi(r)$ we have
$$e = \frac{1}{|C|},$$
and no randomness accepts two distinct challenges.

*Proof sketch.* Each row has exactly one accepting cell, so the accepting set has
cardinality $|R|$ and $e = |R|/(|R||C|) = 1/|C|$; uniqueness of the accepting
challenge per row is immediate. $\square$

Together, Theorems 5.3 and 5.4 form a dichotomy at the exact threshold $1/|C|$:
*at or below it*, an adversarial configuration with no extractable row exists;
*strictly above it*, extraction is forced. The strict inequality cannot be
weakened.

### 5.3 The heavy-row splitting lemma

Existence of a single extractable row is a weak guarantee: an extractor that must
locate one specific row among $|R|$ is not an algorithm. One wants *many* rows to
be good.

**Definition 5.5.** For $\alpha > 0$, call a randomness $r$ *$\alpha e$-heavy* if
$e_r \ge \alpha e$.

**Theorem 5.6 (Heavy-Row Splitting Lemma, general form).** Let $R, C \ne \emptyset$,
let $e$ be the global accepting fraction and let $\alpha > 0$. Then
$$\operatorname{frac}_R(r \text{ is } \alpha e\text{-heavy}) \;\ge\; (1-\alpha)\,e .$$

*Proof sketch.* By Theorem 5.1, $e|R| = \sum_{r \in R} e_r$. Split the sum into
heavy rows $H$ and light rows. Each heavy row contributes at most $1$ (the trivial
bound $e_r \le 1$), so the heavy part is at most $|H|$. Each light row contributes
less than $\alpha e$ by definition, so the light part is at most
$\alpha e |R|$. Therefore $e|R| \le |H| + \alpha e |R|$, i.e.
$(1-\alpha)e|R| \le |H|$; divide by $|R| > 0$. $\square$

**Corollary 5.7 (Classical heavy-row lemma).** Taking $\alpha = 1/2$: at least an
$e/2$ fraction of the randomnesses are $e/2$-heavy.

Note where the two estimates are used: the trivial bound $e_r \le 1$ on heavy rows,
and the definitional bound $e_r < \alpha e$ on light rows. A configuration making
both tight simultaneously would show the constant $(1-\alpha)$ optimal; the natural
candidate is the *two-level* configuration in which a $(1-\alpha)e$ fraction of
rows are entirely accepting and every other row accepts on an $\alpha e$-minus-one
slice.

### 5.4 Quantitative rewinding

**Theorem 5.8 (Quantitative Rewinding).** Let $R, C \ne \emptyset$ and suppose the
global accepting fraction satisfies
$$e > \frac{2}{|C|}.$$
Then there exist $r \in R$ and distinct $c_1, c_2 \in C$ accepted by $r$; moreover
an $e/2$ fraction of the randomnesses is $e/2$-heavy, and every $e/2$-heavy row
admits such a pair.

*Proof sketch.* By Corollary 5.7 the heavy-row fraction is at least $e/2 > 0$, so
some heavy row $r$ exists. For that row, $e_r \ge e/2 > 1/|C|$ (this is exactly the
hypothesis $e > 2/|C|$ rearranged), hence $|G_C(\mathrm{acc}(r,\cdot))| > 1$, hence
two distinct accepting challenges exist in that row. $\square$

The upgrade from Theorem 5.3 to Theorem 5.8 is what makes an extractor
*implementable*: instead of "some row works", one has "a $\ge e/2$ share of rows
works", so sampling random tapes finds an extractable one after $O(1/e)$ trials in
expectation.

---

## 6. Algorithms

All four algorithms below operate on explicitly enumerated finite seed spaces and
compute exact rational values; each is a direct transcription of a theorem above,
so each doubles as a check of that theorem on concrete instances.

**A1. Level-set profile of a bounded cost.** Given $\Omega$, a cost $c$ and a bound
$B$, compute the vector $(\operatorname{frac}(c=i))_{i=0}^{B}$, the cumulative
sublevel vector, the tail vector, and the average by both layer-cake formulas.
Complexity: $O(|\Omega| + B)$ arithmetic operations on rationals. Checks
Theorems 2.7, 2.8, 2.10, 2.11 simultaneously by comparing the two computed
averages against the direct one.

**A2. Bounded witness search with cost instrumentation.** For each seed, probe
$0,\dots,B-1$ until success; return the success flag and the probe count. Worst
case $O(|\Omega| \cdot B)$ predicate evaluations. Feeds A1 and instantiates
Theorem 3.6.

**A3. Exact compromised-fraction evaluator.** Given $N, k$, count checkpoints as
$\lfloor N/k\rfloor$ and return $(N - \lfloor N/k\rfloor)/N$; compare with the
residue form $(k-1)/k + (N \bmod k)/(kN)$ and with a brute-force enumeration of the
window. $O(N)$ for the brute force, $O(1)$ for the formulas.

**A4. Heavy-row and rewinding analyser.** Given an accepting predicate on a grid
$R \times C$, compute all row fractions, the global fraction (both directly and by
averaging rows), the heavy-row fraction at parameter $\alpha$, and locate an
extractable row when one exists. $O(|R||C|)$.

---

## 7. Discussion

### 7.1 Exactness as a design choice

Nearly every result above is an *equality*: the level-set partition, both layer-cake
identities, the amplification law, the compromised-fraction formula, the row
averaging identity, the sharpness configuration. Only four statements are genuine
inequalities: Markov (Theorem 2.9), the first-probe bound (Theorem 3.6), the
heavy-row lemma (Theorem 5.6), and the rewinding threshold (Theorem 5.3, an
implication). This is not an accident of presentation. On a finite seed space,
counting arguments *want* to be identities; estimates enter only when one deliberately
discards structure — the shape of a distribution (Markov), the interaction between
rows (heavy rows), or the identity of the good row (rewinding).

Knowing which of your steps are lossy is operationally useful, because it tells you
where an improvement is possible at all.

### 7.2 On recording weak bounds

Proposition 3.5 is a bound that says nothing. It would have been easy to omit. We
state it, with a proof and an explanation of *why* it is weak, for the same reason a
laboratory records a failed experiment: the alternative is that the next reader
attempts the same estimate and rediscovers its emptiness. The pattern generalises —
a tail bound derived from a mean is worthless whenever the pointwise bound that
controls the mean is the same constant that appears in the tail.

### 7.3 Guards as a discipline

Three separate results above needed a non-emptiness guard, and in each case the
guard is load-bearing rather than cosmetic: normalisation (Proposition 2.4(5)–(7)),
the level-set partition (Theorem 2.7), and amplification (Theorem 3.7). The
underlying reason is uniform: on an empty seed space the denominator vanishes and
the functional degenerates. Making the guard explicit at every normalisation
statement is cheap and it removes an entire class of vacuous security claims.

The analogous discipline in the monitoring application is honesty of the whitelist
(G2). Without it, Theorem 4.1 becomes false in the forward direction, and every
downstream count silently changes.

### 7.4 Relation to the probabilistic idiom

Everything here can be read as the uniform-measure special case of standard
probability. The point of writing it in counting form is not novelty of content but
*exactness of content*: an identity between rationals is checkable, transferable to
a concrete instantiation without an approximation step, and immune to the class of
error where a limit statement is quoted for a finite window.

---

## 8. Future directions

Five falsifiable conjectures, each stated so that a single focused development
could confirm or refute it against the apparatus above.

**C1′. The compromised-fraction functional is a complete invariant of a monitoring
schedule.** Replace the periodic checkpoint set $\{n : k \mid n\}$ by an arbitrary
decidable schedule $T \subseteq \mathbb{N}$. Conjecture: the compromised fraction of
the window $(0,N]$ is $1 - |T \cap (0,N]|/N$ for every $N$, and two schedules
$T_1, T_2$ give the same compromised fraction for **every** $N \ge 1$ if and only if
$T_1 \cap (0,\infty) = T_2 \cap (0,\infty)$. *Key insight:* the compromised-fraction
sequence is, up to the affine change $N \mapsto N(1 - f(N))$, the counting function
of the schedule, and a counting function determines a subset of $\mathbb{N}$ by
first differences — so the security-relevant statistic loses no information about the
schedule at all. *Why now:* Theorem 4.1 never uses periodicity; only the counting
step (Lemma 4.2) does, and replacing that one step by a general counting function is
the whole of the generalisation.

**C2. The heavy-row constant is optimal at every split point.** Theorem 5.6 gives,
for $0 < \alpha < 1$, that at least a $(1-\alpha)e$ fraction of rows are
$\alpha e$-heavy. Conjecture: for every rational $\alpha \in (0,1)$ and every
$\epsilon > 0$ there are finite $R, C$ and an accepting set with global fraction $e$
whose heavy-row fraction is $< (1-\alpha)e + \epsilon$; in particular no constant
better than $(1-\alpha)$ is available. *Key insight:* the extremal configuration
should be the two-level one — a $(1-\alpha)e$ fraction of rows entirely accepting,
and all remaining rows accepting on exactly an $\alpha e$-minus-one-challenge slice —
which saturates both inequalities used in the splitting argument simultaneously.
*Why now:* the proof of Theorem 5.6 uses exactly two estimates ($e_r \le 1$ on heavy
rows, $e_r < \alpha e$ on light rows); a configuration making both tight is a finite
object that can be built explicitly and checked exhaustively for small $|R|, |C|$
before being generalised.

**C3. Level-set fractions characterise the seed space up to relabelling.** Let
$c_1, c_2 : \Omega \to \mathbb{N}$ be bounded by $B$ on a finite $\Omega$.
Conjecture: if $\operatorname{frac}_\Omega(c_1 = i) = \operatorname{frac}_\Omega(c_2 = i)$
for every $i$, then there is a permutation $\pi$ of $\Omega$ with $c_2 = c_1 \circ \pi$;
equivalently, the level-fraction vector is a complete invariant of a bounded cost
function up to relabelling of seeds. *Key insight:* equality of fractions on a fixed
denominator $|\Omega|$ forces equality of level-set cardinalities, and a bijection can
be assembled level by level.

**C4. The first-probe bound is the first term of a complete expansion.** Conjecture:
for every $j$, $\mathbb{E}[\mathrm{cost}] \le B - \sum_{i<j}(B - i - 1)\,q_i$, where
$q_i$ is the fraction of seeds whose first witness is exactly $i$, and this family of
bounds is exhaustive in the sense that the $j = B$ member is an identity. *Key
insight:* the weighted layer cake (Theorem 2.10) applied to the search cost has
exactly these terms; the question is whether each truncation is individually
provable without the boundedness bookkeeping of the full sum.

**C5. Amplification is optimal among all seed-space couplings.** The exact
identity $1-(1-\varepsilon)^k$ (Theorem 3.7) assumes independent coordinates.
Conjecture: over all subsets $D \subseteq \Omega^k$ whose one-dimensional marginals
each have fraction $\varepsilon$, the fraction of $k$-tuples containing a good
coordinate is at least $\varepsilon$ and at most $\min(1, k\varepsilon)$, and both
extremes are attained by explicit finite configurations; the independent case sits
strictly inside for $k \ge 2$, $0 < \varepsilon < 1$. *Key insight:* the lower
extreme should be the "all coordinates equal" diagonal coupling and the upper extreme
a maximally spread-out one, both of which are finite objects constructible from a
partition of $\Omega$.
