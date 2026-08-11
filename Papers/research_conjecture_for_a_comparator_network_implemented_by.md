# The Thermodynamics of Comparison Sorting: Radix Independence, Reset Ledgers, Direct Sums, Fluctuation Penalties, and Prior Sensitivity

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We develop a rigorous transcript-based framework for the thermodynamic cost of
comparison sorting and use it to settle five questions about the interaction between
query complexity and Landauer erasure. Modelling an algorithm by the map sending each
input ordering to the sequence of query answers it observes, correctness is equivalent
to injectivity of that map, since the sorted output is constant across inputs. From
this single structural fact we obtain: (i) a **multiway depth bound**, that any correct
sorter of $n$ items using queries of radix at most $q$ requires depth at least
$\lceil\log_q(n!)\rceil$, together with achievability of that depth in the transcript
model; (ii) **radix independence of the work ledger**, namely that charging $kT\log q$
per fully erased query register yields a total at least $kT\log(n!)$ for every $q$, and
strictly less than $kT\log(n!) + kT\log q$ for the depth-optimal sorter, so that
changing the query radix trades depth against information per query without moving the
reversible information balance; (iii) a **reset-register theorem**, that the true
Landauer cost of clearing the transcript is $kT$ times the logarithm of the cardinality
of the transcript's image, hence exactly $kT\log(n!)$ for any correct sorter,
independent of depth and radix, and invariant under duplication of the register, so
that logically correlated queries are thermodynamically free; (iv) a **thermodynamic
direct-sum theorem** for independent blocks, in which the erased information is additive
while the reversible history space has cardinality at least the product $m!\,n!$, with
equality exactly when the history map is bijective — a precise characterisation of
garbage-free protocols; and (v) a **fluctuation penalty**, that a finite-time stochastic
protocol obeying the Jarzynski equality with baseline $F$ has $\langle W\rangle \ge F$,
with strict inequality whenever the work is nonconstant on the support, and with excess
exactly $kT\,D(p\,\|\,p^R)$, the relative entropy between the forward trajectory
distribution and the reverse-weighted one. Finally we prove a **prior-sensitive**
refinement: for any positive prior $p$ on orderings, every correct self-delimiting
comparison sorter has expected comparison count at least $H(p)$, this is achievable to
within one comparison uniformly in $n$, and $H(p)\le\log_2(n!)$ with equality exactly
at the uniform prior — identifying the classical factorial baseline as the
maximum-entropy special case.

**Keywords:** comparison sorting, Landauer's principle, Jarzynski equality, decision
tree depth, radix, Kraft inequality, Shannon entropy, reversible computation, relative
entropy, direct sum.

---

## 1. Introduction

### 1.1 Two costs of sorting

The classical information-theoretic lower bound for comparison sorting is a counting
argument. A deterministic algorithm using binary comparisons induces a binary decision
tree; correct behaviour requires a distinct leaf for each of the $n!$ input orderings;
a tree of depth $d$ has at most $2^d$ leaves; hence $d \ge \lceil\log_2(n!)\rceil$.
This is a statement about *time*.

There is a second, physically distinct cost. A machine that sorts must, at the end of
its run, be in a state that no longer distinguishes among the $n!$ possible input
orderings. Landauer's principle asserts that the logically irreversible destruction of
distinguishability requires a minimum work
$$W_{\min} = kT\,\log(\text{number of distinguishable states collapsed}),$$
so that sorting has an ideal thermodynamic price $kT\log(n!)$. This is a statement
about *heat*.

These two costs are frequently conflated, because both are logarithms of $n!$. The
purpose of this paper is to show that they are governed by different mathematical
objects and respond to different perturbations of the model. Time is controlled by the
*capacity* of the query tree; heat is controlled by the *cardinality of the image* of
the transcript map. The first depends on the query radix, the branching structure and
the adaptivity of the algorithm; the second depends on none of these.

### 1.2 The transcript model

Fix $n \in \mathbb{N}$. Let $S_n = \mathrm{Perm}(\{1,\dots,n\})$ denote the set of
input orderings, $|S_n| = n!$.

**Definition 1.1 (Transcript).** For $q, d \in \mathbb{N}$, a *transcript* of depth $d$
and radix $q$ is a function $\{1,\dots,d\} \to \{1,\dots,q\}$, i.e. a word of length
$d$ over a $q$-letter alphabet. The set of such transcripts is denoted
$\mathcal{T}(q,d)$; clearly $|\mathcal{T}(q,d)| = q^d$.

**Definition 1.2 (Correct radix-$q$, depth-$d$ sorter).** A *sorter* $S$ for $n$ items
consists of a map $T_S : S_n \to \mathcal{T}(q,d)$, the transcript of the $d$ queries
performed on a given input ordering, subject to the correctness condition that $T_S$ be
injective.

The injectivity condition deserves comment, since it carries the whole argument. The
*output* of a sorting algorithm is the sorted list, which is the same for every input
ordering; the output therefore carries zero information about the input. Consequently
the only place the input's identity can reside, in a machine that behaved correctly
(i.e. applied the correct inverse permutation), is the sequence of answers it received.
Two distinct orderings producing an identical transcript would drive the algorithm
through identical states and produce identical behaviour, contradicting correctness for
at least one of them. Injectivity of the transcript map is thus a necessary condition
for correctness, and it is exactly the information that a physical implementation must
eventually reset.

We emphasise that Definition 1.2 is a *relaxation*: it makes no requirement that the
$k$-th query be one of the order queries actually available on $n$ items, nor that it
be a function of the previous answers. Lower bounds proved in this model therefore
apply a fortiori to genuine adaptive comparison algorithms; upper bounds (achievability
statements) hold in the abstract model and are discussed critically in §7.

### 1.3 Summary of results

- §2: multiway depth bound $\lceil\log_q(n!)\rceil \le d$, achievability, antitonicity
  in $q$, and a verified small-case table.
- §3: the naive work ledger $d\cdot kT\log q$, its radix-independent lower bound
  $kT\log(n!)$, and the one-query sandwich for optimal-depth sorters.
- §4: the reset-register theorem; reset cost is image entropy, invariant under
  duplication, equal to $kT\log(n!)$ for every correct sorter.
- §5: the thermodynamic direct-sum theorem with its equality case.
- §6: the fluctuation penalty and the exact divergence identity.
- §7: prior-sensitive sorting; entropy floor, achievability within one comparison,
  maximum-entropy characterisation of the uniform baseline.
- §8–9: algorithms, applications, discussion, and open problems.

Throughout, $\log$ denotes the natural logarithm and $\log_2$ the binary logarithm;
work is measured in energy units with $kT$ the thermal energy scale, so that one nat
of erasure costs $kT$ and one bit costs $kT\log 2$.

---

## 2. Multiway comparisons and optimal radix

### 2.1 The counting bound

**Lemma 2.1 (Transcript count).** $|\mathcal{T}(q,d)| = q^d$.

*Proof.* A transcript is a function from a $d$-element set to a $q$-element set. $\square$

**Proposition 2.2 (Counting bound).** If $S$ is a correct radix-$q$, depth-$d$ sorter
for $n$ items, then $n! \le q^d$.

*Proof.* $T_S : S_n \to \mathcal{T}(q,d)$ is injective between finite sets, so
$|S_n| \le |\mathcal{T}(q,d)|$; now apply $|S_n| = n!$ and Lemma 2.1. $\square$

**Theorem 2.3 (Multiway depth lower bound).** Let $q \ge 2$. Every correct radix-$q$
sorter for $n$ items has depth
$$d \;\ge\; \lceil \log_q(n!)\rceil .$$

*Proof.* For $q \ge 2$ the ceiling logarithm satisfies the adjunction
$\lceil\log_q m\rceil \le d \iff m \le q^d$. Apply this to $m = n!$ using
Proposition 2.2. $\square$

Specialising to $q = 2$ recovers the classical comparison bound
$d \ge \lceil\log_2(n!)\rceil = \Theta(n\log n)$.

### 2.2 Tightness

**Theorem 2.4 (Achievability).** For every $n$ and every $q \ge 2$ there exists a
correct radix-$q$ sorter of depth exactly $\lceil\log_q(n!)\rceil$.

*Proof.* By the defining property of the ceiling logarithm,
$n! \le q^{\lceil\log_q(n!)\rceil} = |\mathcal{T}(q,\lceil\log_q(n!)\rceil)|$. A map
between finite sets with $|A| \le |B|$ admits an injection $A \hookrightarrow B$; take
$T_S$ to be any such injection. $\square$

Thus in the transcript model the counting bound of Theorem 2.3 is exactly the optimal
depth. (Whether it is attained by *adaptive order queries* is a separate and subtler
question; see §9.1.)

**Proposition 2.5 (Depth is antitone in the radix).** For $2 \le q \le q'$,
$$\lceil\log_{q'}(n!)\rceil \le \lceil\log_q(n!)\rceil.$$

*Proof.* Monotonicity of $m \mapsto q^m$ in the base: if $n! \le q^{d}$ and $q\le q'$
then $n! \le q'^{\,d}$, so the ceiling logarithm to base $q'$ is no larger. $\square$

**Example 2.6 (Verified table, $n=5$, $5! = 120$).**

| $q$ | 2 | 3 | 4 | 5 | 10 |
|---|---|---|---|---|---|
| $\lceil\log_q 120\rceil$ | 7 | 5 | 4 | 3 | 3 |
| $d\log q$ (nats) | 4.852 | 5.493 | 5.545 | 4.828 | 6.908 |

with $\log 120 = 4.787$. Every ledger entry lies in $[\log 120,\ \log 120 + \log q)$,
as guaranteed by Theorem 3.3 below.

---

## 3. The physical work ledger

**Definition 3.1 (Naive transcript work).** A radix-$q$ query register holds $\log q$
nats. Charging every query register in full, a depth-$d$ run costs
$$W_{\text{naive}}(kT, q, d) \;=\; d\cdot kT\log q.$$

**Theorem 3.2 (Radix independence of the work lower bound).** Let $kT \ge 0$ and let
$S$ be a correct radix-$q$, depth-$d$ sorter. Then
$$kT\log(n!) \;\le\; W_{\text{naive}}(kT,q,d).$$

*Proof.* By Proposition 2.2, $n! \le q^d$; since $n! > 0$ and $\log$ is monotone,
$\log(n!) \le \log(q^d) = d\log q$. Multiply by $kT \ge 0$. $\square$

The theorem holds for *every* radix simultaneously and with no reference to the
optimality of the sorter. The information balance of sorting is thus indifferent to the
query radix: a larger $q$ reduces $d$ but inflates the per-register charge $\log q$ by
exactly the compensating factor.

**Theorem 3.3 (Optimal-radix sandwich).** Let $q\ge 2$, $n \ge 2$, $kT > 0$, and let
$d^\star = \lceil\log_q(n!)\rceil$. Then
$$kT\log(n!) \;\le\; W_{\text{naive}}(kT,q,d^\star) \;<\; kT\log(n!) + kT\log q .$$

*Proof.* The left inequality is Theorem 3.2 applied to a sorter of depth $d^\star$
(which exists by Theorem 2.4). For the right inequality, note $n! \ge n \ge 2 > 1$, so
$d^\star \ge 1$ and the ceiling logarithm satisfies the strict defining property
$q^{\,d^\star - 1} < n!$. Taking logarithms, $(d^\star - 1)\log q < \log(n!)$, i.e.
$d^\star\log q < \log(n!) + \log q$. Multiply by $kT > 0$. $\square$

**Interpretation.** The optimal-depth ledger is pinned to a window of width exactly one
query register above the Landauer baseline, for every radix. Increasing $q$ moves you
along a curve of (depth, register width) pairs whose product is always in
$[\log(n!),\ \log(n!)+\log q)$. This is the precise sense in which *changing the query
radix does not alter the reversible information balance of sorting*.

---

## 4. Reset registers: cost is image entropy, not transcript length

The naive ledger of §3 is an upper model: it charges for register *capacity*. Landauer's
principle charges for *distinguishability*. We now make the distinction precise and show
that the gap is exactly the redundancy in the transcript.

**Definition 4.1 (Reset work).** Let $A$ be a finite set of inputs and $T : A \to \tau$
a register-valued observable with $\tau$ having decidable equality. The work required to
reset the register to a fixed blank state is
$$W_{\text{reset}}(kT, T) \;=\; kT\,\log\big|\,T(A)\,\big|,$$
$kT$ times the logarithm of the number of distinct values the register actually takes.

Because the sorted output is constant, $|T(A)|$ is precisely the number of transcript
values consistent with the output; $\log|T(A)|$ is therefore the *conditional entropy of
the transcript given the output* in the uniform, deterministic setting. This is the
quantity that a Landauer accounting must charge.

**Theorem 4.2 (Correlated registers are free).** For any $T : A \to \tau$,
$$W_{\text{reset}}\big(kT,\ a \mapsto (T(a), T(a))\big) \;=\; W_{\text{reset}}(kT, T).$$

*Proof.* The image of $a \mapsto (T(a),T(a))$ is the image of $T(A)$ under the diagonal
$t\mapsto(t,t)$, which is injective; hence the two images have equal cardinality. $\square$

Duplicating the transcript doubles its length and doubles the naive charge, but leaves
the reset bill untouched. The same argument applies to any register whose contents are a
deterministic function of information already retained: **logically correlated registers
carry no incremental Landauer cost**.

**Proposition 4.3 (The naive charge dominates).** For every $T : S_n \to \mathcal{T}(q,d)$
and $kT \ge 0$,
$$W_{\text{reset}}(kT, T) \;\le\; W_{\text{naive}}(kT, q, d).$$

*Proof.* $T(S_n) \subseteq \mathcal{T}(q,d)$, so $|T(S_n)| \le q^d$; the image is
nonempty, so take logarithms and multiply by $kT$. $\square$

**Lemma 4.4 (Image of a correct sorter).** If $S$ is a correct radix-$q$, depth-$d$
sorter then $|T_S(S_n)| = n!$.

*Proof.* $T_S$ is injective, so the image has the cardinality of the domain, $n!$. $\square$

**Theorem 4.5 (Reset-register theorem).** For every correct radix-$q$, depth-$d$ sorter
$S$ and every $kT$,
$$W_{\text{reset}}(kT, T_S) \;=\; kT\log(n!),$$
which is exactly the Landauer gap of the sorting task. In particular the reset cost is
independent of the depth $d$ and of the radix $q$.

*Proof.* Combine Definition 4.1 with Lemma 4.4. $\square$

**Corollary 4.6 (Synthesis for the reset conjecture).** For a correct radix-$q$,
depth-$d$ sorter and $kT>0$:
1. $\lceil\log_q(n!)\rceil \le d$ (Theorem 2.3);
2. $kT\log(n!) \le W_{\text{naive}}(kT,q,d)$ (Theorem 3.2);
3. $W_{\text{reset}}(kT, T_S) = kT\log(n!)$ exactly, independent of $d$ and $q$
   (Theorem 4.5);
4. duplicating the transcript register changes nothing (Theorem 4.2).

This resolves the original conjecture that the dissipated work of a comparator network
is governed by the conditional entropy of the comparison transcript given the sorted
output, rather than by the transcript length: items 3 and 4 are exactly that statement,
and item 2 shows that the length-based accounting is a valid but generally loose upper
model. Redundant padding of a comparison network — the natural counterexample to any
length-based law — is precisely the case in which the two accountings diverge without
bound while the true cost is constant.

---

## 5. A thermodynamic direct-sum theorem

Consider sorting two independent blocks, of sizes $m$ and $n$. The joint task is the
constant map on $S_m \times S_n$.

**Theorem 5.1 (Additivity of erased information).** For finite nonempty sets $A, B$,
the information erased by collapsing $A \times B$ to a point is the sum of the
information erased by collapsing $A$ and by collapsing $B$. Consequently for block
sorting,
$$I_{\text{erased}}(m\oplus n) = \log_2(m!) + \log_2(n!),$$
and for the corresponding minimum work,
$$W_{\min}(m\oplus n) \;=\; kT\log(m!) \;+\; kT\log(n!).$$

*Proof.* Erased information is $\log_2|A\times B| - \log_2|\{\ast\}| = \log_2(|A||B|)$,
and $\log_2$ is additive on products of positive reals. Specialise
$A = S_m$, $B = S_n$ and convert to work units. $\square$

Now consider a *reversible* implementation: a bijection
$$e : S_m \times S_n \;\xrightarrow{\ \sim\ }\; \{\ast\} \times \mathrm{Aux}$$
repackaging the input as (constant output, retained history) with $\mathrm{Aux}$ finite.

**Definition 5.2 (History map).** $h_e : S_m\times S_n \to \mathrm{Aux}$,
$h_e(p) = \pi_2(e(p))$.

**Lemma 5.3.** $h_e$ is injective.

*Proof.* If $h_e(p_1) = h_e(p_2)$ then $e(p_1) = (\ast, h_e(p_1)) = (\ast, h_e(p_2)) = e(p_2)$,
and $e$ is injective. $\square$

**Theorem 5.4 (History states multiply).** Any reversible implementation of the
two-block sorting task satisfies
$$|\mathrm{Aux}| \;\ge\; m!\cdot n! .$$

*Proof.* Immediate from Lemma 5.3 and $|S_m\times S_n| = m!\,n!$. $\square$

**Theorem 5.5 (Equality case: no cross-block garbage).**
$$|\mathrm{Aux}| = m!\,n! \quad\Longleftrightarrow\quad h_e \text{ is a bijection.}$$

*Proof.* ($\Rightarrow$) $h_e$ is injective between finite sets of equal cardinality,
hence bijective. ($\Leftarrow$) A bijection between finite sets forces equal
cardinalities. $\square$

**Corollary 5.6 (Strict garbage bound).** If $h_e$ fails to be surjective then
$m!\,n! < |\mathrm{Aux}|$ strictly.

**Interpretation.** Entropy adds while reversible state counts multiply — the same fact
seen on the two sides of a logarithm, but with different physical roles: the additive
quantity is a *cost* (in joules) and the multiplicative one is a *resource* (a state
space). Theorem 5.5 makes "garbage-free" a checkable property: the retained history is
exactly the pair of block orderings if and only if the state count is exactly the
product. Any unused history state is, by Corollary 5.6, evidence of cross-block
bookkeeping.

**Theorem 5.7 (Depth direct sum).** Let $S$ be a joint radix-$q$, depth-$d$ sorter for
two independent blocks (i.e. an injective transcript map on $S_m\times S_n$), and
$kT \ge 0$. Then
$$kT\log(m!) + kT\log(n!) \;\le\; W_{\text{naive}}(kT,q,d).$$

*Proof.* Injectivity gives $m!\,n! \le q^d$; take logarithms, use additivity of $\log$
on the left, and multiply by $kT$. $\square$

---

## 6. The fluctuation penalty above the sorting baseline

Sections 2–5 concern quasistatic minima. We now quantify the surcharge for finite-time
operation.

**Definition 6.1 (Work ensemble).** Let $\Omega$ be a finite set of trajectories. A
*work ensemble* is a pair of functions $p : \Omega \to \mathbb{R}$, $W:\Omega\to\mathbb{R}$
with $p_i > 0$ for all $i$ (so $\Omega$ *is* the support) and $\sum_i p_i = 1$. Its
expected work is $\langle W\rangle = \sum_i p_i W_i$.

**Definition 6.2 (Jarzynski equality).** The ensemble satisfies the Jarzynski equality
with baseline $F$ at temperature $kT \ne 0$ if
$$\sum_i p_i\, e^{-W_i/kT} \;=\; e^{-F/kT}.$$

**Definition 6.3 (Reverse weights and relative entropy).**
$$p_i^R \;=\; p_i\, e^{-(W_i - F)/kT},\qquad
D(p\,\|\,p^R) \;=\; \sum_i p_i \log\frac{p_i}{p_i^R}.$$

**Lemma 6.4 (Jarzynski = normalisation of the reverse process).** If the ensemble
satisfies the Jarzynski equality with baseline $F$, then $\sum_i p_i^R = 1$; the reverse
weights are a genuine probability distribution.

*Proof.* $p_i^R = \big(p_i e^{-W_i/kT}\big)\,e^{F/kT}$, so
$\sum_i p_i^R = e^{-F/kT}e^{F/kT} = 1$. $\square$

**Lemma 6.5 (Log-ratio identity).** $\displaystyle \log\frac{p_i}{p_i^R} = \frac{W_i - F}{kT}$.

*Proof.* $p_i/p_i^R = e^{(W_i-F)/kT}$. $\square$

**Theorem 6.6 (Second law for the ensemble).** If $kT>0$ and the ensemble satisfies the
Jarzynski equality with baseline $F$, then $F \le \langle W\rangle$.

*Proof.* Set $x_i = e^{-(W_i - F)/kT} > 0$. Pointwise $\log x_i \le x_i - 1$; weight by
$p_i > 0$ and sum. The right-hand side is $\sum_i p_i x_i - \sum_i p_i = \sum_i p_i^R - 1 = 0$
by Lemma 6.4. The left-hand side is $\sum_i p_i \cdot \frac{F - W_i}{kT} = \frac{F - \langle W\rangle}{kT}$.
Hence $F - \langle W\rangle \le 0$. $\square$

**Theorem 6.7 (Strict fluctuation penalty).** Under the hypotheses of Theorem 6.6, if
some trajectory in the support has $W_j \ne F$ — in particular if the work distribution
is nonconstant on the support — then $F < \langle W\rangle$ strictly.

*Proof.* The inequality $\log x \le x-1$ is strict for $x \ne 1$, and $x_j \ne 1$ iff
$W_j \ne F$ (using $kT>0$). A single strict term in a sum of weighted inequalities with
positive weights makes the sum strict. For the nonconstant case: if all $W_i = F$ the
work is constant, so nonconstancy supplies the required $j$. $\square$

**Theorem 6.8 (Dissipation is exactly a divergence).** For $kT>0$ and any baseline $F$,
$$\langle W\rangle - F \;=\; kT\, D\big(p\,\|\,p^R\big).$$

*Proof.* By Lemma 6.5,
$D(p\|p^R) = \sum_i p_i (W_i - F)/kT = (\langle W\rangle - F)/kT$. $\square$

Note the identity of Theorem 6.8 holds for any $F$ and any ensemble; the Jarzynski
equality is what makes $p^R$ normalised and hence makes $D$ a genuine relative entropy,
and therefore nonnegative — recovering Theorem 6.6 a second way.

**Theorem 6.9 (Fluctuation penalty for sorting).** Let $kT>0$ and let a finite-time
stochastic implementation of sorting $n$ items satisfy the Jarzynski equality with the
exact Landauer baseline $F = kT\log(n!)$. If the work distribution is nonconstant on
its support, then
$$\langle W\rangle \;>\; kT\log(n!), \qquad
\langle W\rangle - kT\log(n!) \;=\; kT\,D\big(p\,\|\,p^R\big).$$

*Proof.* Theorems 6.7 and 6.8 with $F = kT\log(n!)$. $\square$

**Example 6.10.** Take $n=3$, $kT=1$, $F = \log 6 = 1.7918$, and $\Omega = \{1,2\}$ with
$p = (\tfrac12,\tfrac12)$. Choose $W_1 = \log 6 - 0.5 = 1.2917$, so
$e^{-W_1} = 0.27473$; Jarzynski requires
$\tfrac12 e^{-W_1} + \tfrac12 e^{-W_2} = \tfrac16$, giving
$e^{-W_2} = \tfrac13 - 0.27473 = 0.05860$, $W_2 = 2.8379$. Then
$\langle W\rangle = 2.0648$, an excess of $0.2731$. The reverse distribution is
$p^R = (0.8242, 0.1758)$, and
$D(p\|p^R) = \tfrac12\log\frac{0.5}{0.8242} + \tfrac12\log\frac{0.5}{0.1758} = 0.2731$.
The identity is exact, not asymptotic.

**Remark 6.11.** Positivity of $p$ is load-bearing: it encodes "nonconstant *on the
support*". A deterministic protocol satisfying Jarzynski must have $W \equiv F$, and
then equality holds — the quasistatic limit.

---

## 7. Prior-sensitive sorting

The bound $kT\log(n!)$ is a *worst-case*, equivalently *uniform-prior*, statement. We
now show it is the maximum-entropy case of a strictly finer theory.

### 7.1 Self-delimiting sorters

**Definition 7.1 (Prior-sensitive comparison sorter).** A *prior sorter* for $n$ items
is a map $c : S_n \to \{0,1\}^*$ assigning to each input ordering the binary transcript
of the comparisons performed, such that

1. $c$ is injective (correctness, as in §1.2), and
2. the image $c(S_n)$ is **prefix-free**: no transcript is a proper prefix of another.

Condition 2 is not a technicality. It is exactly the statement that the algorithm can
tell from the answers alone that it has finished — it halts on its own transcript,
without an external clock or length marker. An algorithm allowed to consult an external
clock is not prefix-constrained; for such models only the fixed-depth bound
$\lceil\log_2(n!)\rceil$ of Theorem 2.3 applies.

Its expected comparison count under a prior $p$ on $S_n$ is
$\mathbb{E}_p[\,|c(\sigma)|\,] = \sum_\sigma p_\sigma |c(\sigma)|$.

### 7.2 The entropy floor and its attainment

**Theorem 7.2 (Entropy lower bound).** Let $p$ be a prior on $S_n$ with $p_\sigma > 0$
for all $\sigma$ and $\sum_\sigma p_\sigma = 1$. Then every prior sorter $c$ satisfies
$$H(p) \;\le\; \mathbb{E}_p\big[\,|c(\sigma)|\,\big],
\qquad H(p) = -\sum_\sigma p_\sigma \log_2 p_\sigma .$$

*Proof sketch.* Injectivity plus prefix-freeness of $c(S_n)$ gives Kraft's inequality
$\sum_\sigma 2^{-|c(\sigma)|} \le 1$; Shannon's source coding lower bound then yields
$H(p) \le \mathbb{E}_p[|c|]$ via the Gibbs inequality applied to $p$ and the sub-normalised
distribution $2^{-|c(\sigma)|}$. $\square$

**Theorem 7.3 (Achievability within one comparison).** For every such prior there exists
a prior sorter $c$ with
$$H(p) \;\le\; \mathbb{E}_p\big[\,|c(\sigma)|\,\big] \;<\; H(p) + 1 .$$
Moreover its transcript *is* its retained reversible history, so the history is
compressed to the same $H(p)$ scale.

*Proof sketch.* Shannon–Fano lengths $\ell_\sigma = \lceil -\log_2 p_\sigma\rceil$
satisfy Kraft's inequality; the converse to Kraft's inequality produces an injective
prefix-free code with exactly these lengths, and
$\mathbb{E}_p[\ell] < \sum_\sigma p_\sigma(-\log_2 p_\sigma + 1) = H(p)+1$. $\square$

The additive slack is a *single comparison*, uniformly in $n$ — substantially sharper
than the $O(n)$ slack that a naive argument suggests.

### 7.3 The factorial baseline as maximum entropy

**Lemma 7.4 (Gibbs pointwise estimate).** For $a,b>0$, $a(\log b - \log a) \le b - a$,
with strict inequality when $a \ne b$.

*Proof.* $\log(b/a) \le b/a - 1$ with strictness for $b/a \ne 1$; multiply by $a>0$. $\square$

**Theorem 7.5 (Maximum entropy).** For any positive normalised $p$ on a finite set of
size $N$, $H(p) \le \log_2 N$, with equality iff $p$ is uniform. Explicitly, if some
$p_j \ne 1/N$ then $H(p) < \log_2 N$; and $H(\text{uniform}) = \log_2 N$.

*Proof sketch.* Apply Lemma 7.4 with $a = p_i$, $b = 1/N$ and sum over $i$: the
right-hand side telescopes to $\sum_i(1/N - p_i) = 0$, while the left-hand side equals
$-\log N - \sum_i p_i\log p_i$. Hence $-\sum_i p_i\log p_i \le \log N$; divide by
$\log 2$. Strictness at a single index propagates to the sum. The uniform case is a
direct computation. $\square$

**Corollary 7.6.** For any positive prior on the $n!$ orderings, $H(p) \le \log_2(n!)$,
with equality precisely at the uniform prior.

**Theorem 7.7 (Prior-sensitive work below the uniform baseline).** Let $kT>0$. For
every positive prior $p$ on $S_n$ there is a prior sorter whose expected comparison
count is within one comparison of $H(p)$ and whose expected reset work
$kT\log 2 \cdot \mathbb{E}_p[|c|]$ satisfies
$$kT\log 2\cdot\mathbb{E}_p[|c|] \;<\; kT\log(n!) \;+\; kT\log 2 .$$

*Proof sketch.* Combine Theorem 7.3 with Corollary 7.6:
$\mathbb{E}_p[|c|] < H(p) + 1 \le \log_2(n!) + 1$; multiply by $kT\log 2$ and use
$\log 2\cdot\log_2(n!) = \log(n!)$. $\square$

**Theorem 7.8 (Biased priors are strictly cheaper).** If $p$ is not the uniform prior
on $S_n$ (i.e. $p_\tau \ne 1/n!$ for some $\tau$) and $kT>0$, then the entropy floor is
strictly below the uniform baseline:
$$kT\log 2 \cdot H(p) \;<\; kT\log(n!).$$

*Proof.* Theorem 7.5 gives $H(p) < \log_2(n!)$ strictly; multiply by $kT\log 2>0$. $\square$

**Example 7.9.** For $n=3$ ($3!=6$) with the dyadic prior
$(\tfrac12,\tfrac14,\tfrac18,\tfrac1{16},\tfrac1{32},\tfrac1{32})$,
$H(p) = \tfrac12 + \tfrac12 + \tfrac38 + \tfrac14 + \tfrac5{16}+\tfrac5{16} = 1.9375$
bits, against the uniform $\log_2 6 = 2.585$ bits: a saving of $0.647$ bits. Since all
probabilities are dyadic, the optimal prefix code attains $1.9375$ comparisons on
average with zero overshoot.

**Synthesis 7.10.** For every positive prior $p$ on the $n!$ orderings: (i) $H(p)$ is a
hard floor on the expected comparison count of every correct self-delimiting sorter;
(ii) the floor is attained to within one comparison by a sorter whose expected reset
work stays below the uniform Landauer baseline plus one bit; (iii) $H(p) \le \log_2(n!)$,
with equality exactly at the uniform prior.

---

## 8. Algorithms

Three algorithmic kernels are implicit in the results above; we state them explicitly.

### 8.1 Optimal multiway depth

Computing $\lceil\log_q(m)\rceil$ exactly for large $m$ (such as $m = n!$, which has
$\Theta(n\log n)$ digits) is done by repeated squaring or, more simply for moderate $n$,
by iterated multiplication: find the least $d$ with $q^d \ge m$. With exact integer
arithmetic this uses $O(d)$ big-integer multiplications, each on numbers of at most
$\log_2 m$ bits, hence $O(d\,M(\log m))$ time, where $M$ is the multiplication cost.
The output is the exact optimal depth of Theorems 2.3–2.4.

### 8.2 The work ledger and the sandwich certificate

Given $n$ and a list of radices, the ledger algorithm returns for each $q$ the triple
$$\Big(d^\star = \lceil\log_q(n!)\rceil,\quad d^\star\log q,\quad
[\log(n!),\ \log(n!) + \log q)\Big),$$
and certifies membership of the middle term in the interval — a computational witness
for Theorem 3.3. To avoid overflow one computes $\log(n!) = \sum_{k=2}^{n}\log k$ in
floating point while doing all comparisons that decide $d^\star$ in exact integer
arithmetic.

### 8.3 Jarzynski-consistent ensemble construction

To exhibit fluctuation penalties one must construct ensembles satisfying
$\sum_i p_i e^{-W_i/kT} = e^{-F/kT}$ exactly. Given $p$, $F$, $kT$ and free choices
$W_1,\dots,W_{r-1}$, solve for the last work value:
$$e^{-W_r/kT} = \frac{1}{p_r}\Big(e^{-F/kT} - \sum_{i<r} p_i e^{-W_i/kT}\Big),$$
which is admissible precisely when the bracket is positive. The construction is $O(r)$
and produces, for each admissible choice, a certificate of Theorem 6.9: it reports
$\langle W\rangle - F$ and $kT\,D(p\|p^R)$ and confirms they agree to machine precision.

---

## 9. Discussion, limitations, and open problems

### 9.1 The comparison-availability gap

Theorem 2.4 is proved in the abstract transcript model: it produces an injection from
orderings to transcripts, not an algorithm built from genuine order queries. Realisable
transcripts satisfy an extra *consistency* condition: the fibre of any prefix is an
order ideal cut out by the queries asked so far, and a multiway order query cannot split
a set of permutations into $q$ arbitrary pieces. It is therefore expected that the
minimal *adaptive* depth exceeds the counting bound $\lceil\log_q(n!)\rceil$ for
infinitely many $(n,q)$ — the classical binary phenomenon (e.g. the counting bound is
not attained for $n=12$ in the binary comparison model) should persist and worsen at
higher radix. Note that all lower bounds in this paper are unaffected: they use only
injectivity, which realisable algorithms certainly satisfy.

### 9.2 What the reset theorem does and does not say

Theorem 4.5 identifies the reset cost with the image entropy of the transcript. It is a
statement about the *retained* register at the moment of erasure; it does not model
which comparisons are physically available at each step, nor the cost of *performing* a
comparison (which can in principle be made reversible and arbitrarily cheap), nor
transient garbage that is later uncomputed. Its force is precisely in ruling out
length-based accounting: any law of the form "work $\propto$ number of comparisons" is
falsified by transcript duplication (Theorem 4.2).

### 9.3 Stability of the equality case

Theorem 5.5 is an all-or-nothing pigeonhole statement, whereas Corollary 5.6 shows the
failure mode is a cardinality *defect* which ought to carry a metric. A natural
quantitative refinement defines the *garbage index* $|\mathrm{Aux}|/(m!\,n!) \ge 1$ and
asks whether protocols within a factor $1+\varepsilon$ of the minimum have history maps
surjective onto a $(1-\varepsilon)$-fraction of $\mathrm{Aux}$, and whether the number of
elementary uncomputation steps needed to reach the garbage-free case is
$\Theta(\log(\text{garbage index}))$. Both endpoints are established here; the
interpolating stability statement is open and falsifiable by exhaustive search already
at $(m,n) = (3,2)$.

### 9.4 Toward a fluctuation–depth uncertainty relation

Theorem 6.8 gives the dissipation exactly, but says nothing about how the divergence
$D(p\|p^R)$ scales with the *speed* of the protocol. For a protocol executing $d$
comparisons with per-comparison relaxation time $\tau$, one expects a trade-off of the
form (excess work) $\times$ (total time) $\gtrsim$ (a constant depending on $d$), an
uncertainty relation between dissipation and depth. The exact baseline $kT\log(n!)$ makes
such a relation cleanly testable, since there is no ambiguity in the equilibrium term.

### 9.5 Applications

*Reversible and adiabatic hardware.* The reset theorem says the designer's target is the
image of the retained register, not the length of the log. Concretely: keep whatever
intermediate results you like, provided they are deterministic functions of a small
retained core; only the core is charged.

*Radix selection in comparator networks.* Theorems 3.2–3.3 say that choosing a higher
comparator radix is a pure latency optimisation with no thermodynamic penalty or bonus
beyond one query register. This decouples two design axes that are often assumed to
trade off.

*Data-aware sorting.* Theorems 7.2–7.8 quantify exactly how much a good prior is worth:
$\log_2(n!) - H(p)$ bits of comparison and $kT(\log(n!) - \log 2\cdot H(p))$ joules of
heat, achievable up to one comparison. For nearly-sorted data, where $H(p) \ll \log_2 n!$,
the saving is the bulk of the bill.

*Parallel and blocked sorting.* Theorems 5.1–5.7 govern block-decomposed sorts: the heat
adds across blocks, but the reversible state space multiplies, and any cross-block
bookkeeping shows up as a strictly larger history space.

### 9.6 Summary

The unifying moral is a separation of two logarithms of $n!$. The depth
$\lceil\log_q(n!)\rceil$ is a statement about *tree capacity* and is sensitive to the
query model. The work $kT\log(n!)$ is a statement about *image cardinality* and is
insensitive to depth, radix, and redundancy — but sensitive to the prior, to
independence structure, and to speed. Every result above is an instance of one of these
two logarithms, and every apparent paradox in the folklore of "the energy cost of
sorting" dissolves once they are kept apart.
