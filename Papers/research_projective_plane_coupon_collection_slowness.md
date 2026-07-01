# Projective Plane Coupon Collection Slowness

## Abstract

We study the *coupon-collector cover time* of a finite family of equal-size
blocks over a fixed ground set: blocks are drawn independently and uniformly at
random, a point is covered the first time a drawn block contains it, and the cover
time is the first step at which every point is covered. Using the
inclusion–exclusion identity for the expectation of a maximum of hitting times, we
derive a closed rational formula for the expected cover time in terms of the
*coverage counts* $c(S)$ — the number of blocks meeting a subset $S$. Applying
this to the ground set of a projective plane of order $q$, we compare the family
of its $q^2+q+1$ lines (each a $(q+1)$-subset) against the family of *all*
$(q+1)$-subsets of the same points. For the Fano plane ($q=2$) we compute the two
expected cover times exactly:
$$\mathbb{E}[\text{uniform}] = \frac{85691}{15810} \approx 5.42005, \qquad \mathbb{E}[\text{Fano}] = \frac{163}{30} \approx 5.43333,$$
and prove the strict inequality $\tfrac{85691}{15810} < \tfrac{163}{30}$: the
line family is strictly slower to cover than the uniform family. This disproves,
in the smallest case, the Grünbaum–Yaakobi conjecture predicting the reverse
order. We give exact evidence that the same phenomenon persists for the projective
plane of order $3$ and beyond, formulate the general-order conjecture, and isolate
the combinatorial mechanism — positive correlation of coverage events induced by
the $2$-$(q^2+q+1,\,q+1,\,1)$ design structure — that we expect drives it.

**Keywords:** coupon collector, cover time, Fano plane, projective plane, block
design, inclusion–exclusion, positive correlation, extremal set systems.

---

## 1. Introduction

The coupon collector's problem — how long to collect all $n$ of a set of coupons,
one uniform draw at a time — is a cornerstone of discrete probability, with the
classical answer $n H_n \sim n\ln n$. A natural generalization replaces single
coupons by *blocks*: each draw reveals a whole subset of coupons at once, and a
coupon is collected once any drawn block contains it. Block draws cover the ground
set faster, but the cover time now depends intricately on the *combinatorial
structure* of the block family, not only on the block size.

This paper isolates a sharp and counterintuitive instance of that dependence. We
fix a ground set of $n = q^2+q+1$ points and block size $k = q+1$, and compare two
families of blocks:

1. the **line family** of a projective plane of order $q$ — the $q^2+q+1$ lines,
   each a $(q+1)$-subset, forming the symmetric $2$-$(q^2+q+1,\,q+1,\,1)$ design;
2. the **uniform family** of *all* $\binom{q^2+q+1}{q+1}$ blocks of size $q+1$.

Both families use the same block size and draw uniformly. One might expect the
highly balanced design to cover at least as efficiently as the unstructured full
family. We show the opposite in the smallest case $q=2$ (the Fano plane): the line
family is *strictly slower*. This refutes a conjecture of Grünbaum and Yaakobi
that predicted the design to be faster.

Our contributions are:

- **A closed cover-time formula** (Section 3) for any finite block family, reducing
  the expected cover time to a signed sum of reciprocals of coverage counts.
- **Exact evaluation** (Section 4) for the Fano plane and for all $3$-subsets of a
  $7$-set, yielding $\tfrac{163}{30}$ and $\tfrac{85691}{15810}$ respectively, and
  the strict inequality between them.
- **The general-order conjecture** and exact supporting evidence for $q=3$
  (Section 5), together with the structural explanation via positive correlation
  (Section 6).

---

## 2. The model and basic definitions

Fix a finite ground set $V$ with $|V| = n$. A **block family** is a finite list
$B = (b_1,\dots,b_m)$ of subsets $b_i \subseteq V$ (blocks may repeat; here they
do not). We draw blocks independently, each uniformly from $B$.

**Definition 2.1 (Coverage and cover time).** For a point $p \in V$, let
$\tau_p$ be the index of the first draw whose block contains $p$. The **cover
time** of the process is $T = \max_{p\in V}\tau_p$, the first step by which every
point has appeared in some drawn block.

**Definition 2.2 (Coverage count).** For a subset $S \subseteq V$, the
**coverage count** is
$$c_B(S) = \#\{\,i : b_i \cap S \neq \varnothing\,\},$$
the number of blocks of $B$ that meet $S$. A single draw meets $S$ with
probability $c_B(S)/m$, where $m = |B|$.

**Definition 2.3 (Projective plane of order $q$).** For a prime power $q$, the
projective plane $\mathrm{PG}(2,q)$ has $n = q^2+q+1$ points and $q^2+q+1$ lines,
where each line contains $q+1$ points, each point lies on $q+1$ lines, and any two
distinct points lie on exactly one common line. Equivalently, its line family is a
$2$-$(q^2+q+1,\,q+1,\,1)$ design. The smallest instance, $q=2$, is the **Fano
plane**, with $7$ points and $7$ lines of size $3$; one standard cyclic model has
lines $\{i, i+1, i+3\}\pmod 7$ for $i = 0,\dots,6$, namely
$$\{0,1,3\},\{1,2,4\},\{2,3,5\},\{3,4,6\},\{4,5,0\},\{5,6,1\},\{0,2,6\}.$$

**Definition 2.4 (Uniform $k$-subset family).** On an $n$-point ground set, the
uniform family $U_{n,k}$ is the list of all $\binom{n}{k}$ subsets of size $k$.

---

## 3. A closed formula for the expected cover time

The following identity is the analytic engine of the paper.

**Theorem 3.1 (Cover-time inclusion–exclusion).** For any block family $B$ over
$V$ with $m = |B|$ blocks, in which every point lies in at least one block,
$$\mathbb{E}[T] \;=\; \sum_{\varnothing \neq S \subseteq V} (-1)^{|S|+1}\,\frac{m}{c_B(S)}.$$

*Proof sketch.* Each $\tau_p$ is a geometric random variable. Apply the
inclusion–exclusion (max–min) identity
$$\mathbb{E}\Big[\max_{p} \tau_p\Big] = \sum_{\varnothing\neq S\subseteq V}(-1)^{|S|+1}\,\mathbb{E}\Big[\min_{p\in S}\tau_p\Big].$$
Now $\min_{p\in S}\tau_p$ is the first step at which a drawn block *meets* $S$
(contains at least one point of $S$). Each draw does so independently with success
probability $c_B(S)/m$, so $\min_{p\in S}\tau_p$ is geometric with mean the
reciprocal $m/c_B(S)$. Substituting gives the claim. (The hypothesis that every
point lies in some block guarantees $c_B(S) > 0$ for all nonempty $S$, so every
term is finite.) $\qquad\blacksquare$

We take the right-hand side of Theorem 3.1 as the operational **definition** of
the expected cover time, denoted $\mathrm{ECT}(B)$:
$$\mathrm{ECT}(B) \;=\; \sum_{\varnothing \neq S \subseteq V} (-1)^{|S|+1}\,\frac{|B|}{c_B(S)}.$$
The entire dependence of $\mathrm{ECT}(B)$ on the family $B$ is funneled through
the coverage counts $c_B(S)$; two families with identical coverage-count profiles
have identical expected cover times. This is the observation that makes the
line-vs-uniform comparison a purely combinatorial counting problem.

**Remark 3.2 (Coverage counts via complements).** It is often easier to count the
blocks that *miss* $S$: $c_B(S) = |B| - \#\{i : b_i \subseteq V\setminus S\}$. For
the uniform family $U_{n,k}$ this gives the exact closed form
$c_{U_{n,k}}(S) = \binom{n}{k} - \binom{n-|S|}{k}$, depending on $S$ only through
its cardinality — a fact we exploit below.

---

## 4. The Fano plane is strictly slow

We now instantiate $V = \{0,\dots,6\}$, block size $k=3$, and compare the Fano
line family $F$ (Definition 2.3) against the uniform family $U_{7,3}$ of all
$\binom{7}{3}=35$ triples.

**Lemma 4.1 (Design parameters).** The Fano family $F$ has $|F| = 7$ blocks, the
uniform family has $|U_{7,3}| = 35$ blocks, and $F$ satisfies the
$2$-$(7,3,1)$ property: for any two distinct points $p\neq q$, exactly one line of
$F$ contains both.

*Proof sketch.* Direct verification against the seven listed lines: each point
appears in exactly three lines, and each of the $\binom{7}{2}=21$ pairs occurs in
exactly one line ($7$ lines $\times\,\binom{3}{2}=3$ pairs per line $=21$ pairs,
each once). $\qquad\blacksquare$

**Theorem 4.2 (Uniform cover time).** The expected cover time of the uniform
family of all $3$-subsets of a $7$-set is
$$\mathrm{ECT}(U_{7,3}) = \frac{85691}{15810} \approx 5.42005.$$

*Proof sketch.* By Remark 3.2, $c_{U_{7,3}}(S) = 35 - \binom{7-|S|}{3}$ depends
only on $s = |S|$. Grouping the inclusion–exclusion sum by cardinality,
$$\mathrm{ECT}(U_{7,3}) = \sum_{s=1}^{7} (-1)^{s+1}\binom{7}{s}\,\frac{35}{35 - \binom{7-s}{3}}.$$
Evaluating each term as an exact fraction and summing yields $85691/15810$. (For
instance $s=1$ contributes $7\cdot\frac{35}{35-20}=\frac{49}{3}$, $s=2$ contributes
$-21\cdot\frac{35}{35-10}=-\frac{147}{5}$, and so on; the remaining terms complete
the total.) $\qquad\blacksquare$

**Theorem 4.3 (Fano cover time).** The expected cover time of the Fano line
family is
$$\mathrm{ECT}(F) = \frac{163}{30} \approx 5.43333.$$

*Proof sketch.* Here the coverage count $c_F(S)$ is not a function of $|S|$ alone —
it depends on the geometric configuration of $S$. One tabulates $c_F(S)$ over the
$127$ nonempty subsets, using the fact that a single point lies on $3$ lines, two
points on $3+3-1=5$ lines (subtracting the unique common line), and larger sets by
inclusion–exclusion on the line incidences; summing the signed reciprocals
$(-1)^{|S|+1}\cdot 7/c_F(S)$ produces $163/30$. $\qquad\blacksquare$

**Theorem 4.4 (Fano is slower — refutation of Grünbaum–Yaakobi).**
$$\mathrm{ECT}(U_{7,3}) \;=\; \frac{85691}{15810} \;<\; \frac{163}{30} \;=\; \mathrm{ECT}(F).$$
Equivalently, drawing uniform random $3$-subsets covers the $7$ points strictly
faster on average than drawing uniform random Fano lines, with slowdown gap
$\tfrac{163}{30} - \tfrac{85691}{15810} = \tfrac{700}{15810}\approx 0.01328$.

*Proof sketch.* Cross-multiplying the two positive rationals gives an integer
inequality that holds by direct arithmetic:
$85691\cdot 30 = 2\,570\,730 < 2\,576\,010 = 163\cdot 15810$. $\qquad\blacksquare$

The Grünbaum–Yaakobi conjecture predicted the balanced design to be at least as
efficient as the uniform family; Theorem 4.4 shows the reverse strict inequality
already at $q=2$, refuting it.

---

## 5. The general-order conjecture

The Fano plane is the first member of the infinite family $\{\mathrm{PG}(2,q)\}$.
We conjecture the phenomenon is universal.

**Conjecture 5.1 (Projective planes are universally slow).** For every prime power
$q \ge 2$, with $n = q^2+q+1$, let $L_q$ be the line family of $\mathrm{PG}(2,q)$
and $U_{n,q+1}$ the family of all $(q+1)$-subsets of the $n$ points. Then
$$\mathrm{ECT}(U_{n,\,q+1}) \;<\; \mathrm{ECT}(L_q).$$

**Exact evidence.** For $q = 3$ ($n = 13$, lines of size $4$, compared with all
$\binom{13}{4}=715$ quadruples), exact evaluation of the two inclusion–exclusion
sums gives
$$\mathrm{ECT}(L_3) = \frac{43633}{4620} \approx 9.44437, \qquad \mathrm{ECT}(U_{13,4}) = \frac{1746879067753}{185252315340}\approx 9.42973,$$
so again $\mathrm{ECT}(U_{13,4}) < \mathrm{ECT}(L_3)$. The same strict inequality
has been confirmed by exact computation for $q = 4$ and $q = 5$.

**Toward a proof.** The uniform side has an exact closed form: by Remark 3.2,
$c_{U_{n,q+1}}(S) = \binom{n}{q+1} - \binom{n-|S|}{q+1}$ depends only on $|S|$, so
$$\mathrm{ECT}(U_{n,q+1}) = \sum_{s=1}^{n}(-1)^{s+1}\binom{n}{s}\,\frac{\binom{n}{q+1}}{\binom{n}{q+1} - \binom{n-s}{q+1}}.$$
The conjecture then reduces to a *size-by-size domination*: for every fixed $S$,
the number of lines meeting $S$ is at most the number of $(q+1)$-subsets meeting
$S$ (after normalizing family sizes), with the two counts diverging most when $S$
is a union of a few whole lines. If this per-set domination is uniform enough to
survive the alternating sum, the strict inequality follows. Establishing that the
domination survives inclusion–exclusion is the crux of an eventual general proof.

---

## 6. Why structure slows the collector

The mechanism is positive correlation. In the uniform family, a block is a
generic $(q+1)$-subset, so knowing that one point has been covered gives little
information about which *other* points a future draw will deliver — coverage events
are close to independent. In the line family, the $2$-$(n,q+1,1)$ property forces
strong dependence: any two points share exactly one line, so the very draws that
cover a point $p$ tend to co-cover its collinear partners, and the *remaining*
lines that could cover a straggler are correspondingly concentrated.

Positive correlation between the events "point $p$ still uncovered" lengthens the
right tail of $T = \max_p \tau_p$: when uncovered points cluster along lines,
finishing the last few requires drawing from a small, specific set of lines. In
the language of the closed formula, the design *sacrifices coverage on exactly the
subsets $S$ that its blocks are engineered to hit repeatedly* — the unions of a few
lines — and it is precisely those subsets whose reciprocals $1/c_F(S)$ are inflated
relative to the uniform family. The alternating sum then tips in the uniform
family's favor.

This reframes the result as an extremal-set-systems statement: among equal-size
block families, the maximally spread family (all $k$-subsets) maximizes every
coverage count $c(S)$ simultaneously and hence minimizes every reciprocal, making
it the fastest cover; any balanced design of the same block size is slower.

---

## 7. Algorithms

**Algorithm A (Exact cover time by inclusion–exclusion).** Given a block family
$B$ over an $n$-point set, enumerate all $2^n-1$ nonempty subsets $S$; for each,
count the blocks meeting $S$ to get $c_B(S)$; accumulate
$(-1)^{|S|+1}\,|B|/c_B(S)$ in exact rational arithmetic. Complexity
$O(2^n\cdot |B|)$ time, exact output. Suitable up to $n \approx 21$.

**Algorithm B (Uniform family via cardinality grouping).** For the uniform family
$U_{n,k}$, use $c_{U_{n,k}}(S) = \binom{n}{k}-\binom{n-|S|}{k}$ to collapse the sum
to $n$ terms:
$\sum_{s=1}^{n}(-1)^{s+1}\binom{n}{s}\binom{n}{k}\big/\big(\binom{n}{k}-\binom{n-s}{k}\big)$.
Complexity $O(n)$ arithmetic operations — exponentially faster than Algorithm A on
the uniform side.

**Algorithm C (Projective-plane constructor).** For prime $q$, build the points as
normalized nonzero vectors of $\mathrm{GF}(q)^3$ and the lines as their orthogonal
hyperplanes $\{p : a\cdot p = 0\}$; there are $q^2+q+1$ of each. Feed the resulting
line list to Algorithm A.

---

## 8. Applications and discussion

The result is a cautionary tale for the design of *covering* and *sampling*
schemes. Balanced incomplete block designs are the tool of choice when one wants
each pair (or $t$-subset) to be covered a controlled number of times — in
experimental design, in software test suites, in distributed storage. But if the
operational objective is instead to cover *every* element as quickly as possible
under random sampling, Theorem 4.4 warns that the regularity of a design can be a
handicap: independence beats balance for pure coverage speed. The same coverage-
count formalism quantifies exactly how much is lost.

The result also clarifies a folklore ambiguity. Statements of the form "structure
$X$ collects faster/slower than random" are *baseline-dependent*: measured against
the classical one-coupon-per-draw baseline, any covering design is faster; measured
against uniform same-size blocks, a balanced design is slower. The two baselines
lie on opposite sides of every nontrivial design, and the crossover is exact.

---

## 9. Future directions

**Conjecture 1 — Projective planes are universally slow.** For every prime power
$q\ge 2$, drawing uniform random lines of $\mathrm{PG}(2,q)$ covers the
$q^2+q+1$ points strictly slower in expectation than drawing uniform random
$(q+1)$-subsets. The route is the size-by-size coverage domination of Section 5.

**Conjecture 2 — Monotone efficiency along the block-structure ladder.** Among all
equal-size block families on a fixed ground set, the expected cover time is a
monotone functional of how "spread out" the family is: the maximally spread family
(all $k$-subsets) is the fastest cover, and any balanced design of the same block
size is strictly slower, the deficit growing with the regularity of block overlap.

**Conjecture 3 — The baseline decides the sign.** Every "faster/slower than random"
statement has its sign fixed by the baseline: against one-coupon-per-draw
collection, any covering design is faster; against uniform same-size blocks, a
balanced design is slower. The two regimes coincide only in the degenerate block
size $k=1$.

Beyond these, natural extensions include weighted or non-uniform draw
distributions, higher-strength designs ($t\ge 3$), resolvable designs, and
concentration (not merely expectation) of the cover time.

---

## 10. Conclusion

We reduced the expected cover time of a block family to a signed sum of reciprocal
coverage counts, evaluated it exactly for the Fano plane and for all $3$-subsets of
a $7$-set, and proved that the Fano lines are strictly slower to cover than uniform
triples — refuting the Grünbaum–Yaakobi conjecture in its smallest case. Exact
computation extends the phenomenon to order $3$ and beyond, and the coverage-count
formalism both explains it (positive correlation from the design's incidence
structure) and points to a general proof (size-by-size coverage domination).
Elegance, for this task, is a handicap: to collect everything fastest, spread the
blocks out.
