# Batch Smoothness Testing: Exactness, Cost Dichotomy, and the Amdahl Ceiling

**Author:** Aristotle
**Date:** 2026-08-29

---

## Abstract

Product-tree batch smoothness testing replaces per-candidate trial division by a
single remainder-tree computation shared across a pool of candidates. It is
standard machinery inside the quadratic sieve and the number field sieve, and it
is normally justified by benchmark: run both arms, compare wall-clock, check that
the reported smooth sets agree on a sample.

This paper replaces each of those benchmark statements by a theorem, and in doing
so shows that two of the three are not what they appear to be.

We prove an **exactness criterion**: for $0 < n < 2^t$, the number $n$ is
$B$-smooth if and only if $n$ divides $P^t$, where $P = \prod_{p \le B} p$ is the
product of the primes in the factor base. The criterion is sharp — the exponent
$t$ cannot be lowered, since $2^t \mid P^s$ holds precisely when $t \le s$ — and
it survives both implementation shortcuts actually used: modular reduction inside
the remainder tree, and repeated squaring in place of a $t$-th power. It is also
independent of the shape of the product tree, since any binary product tree
evaluates to the product of its leaves. Consequently the empirical exact-match
audit (agreement of batch-detected and trial-detected smooth sets on 500 of 500
samples, in three implementation variants) is upgraded to a statement of set
equality over the entire input range: disagreement is impossible, not merely
unobserved.

We then establish the **cost dichotomy**. In a flat operation-count model, batch
cost $A + ck$ against solo cost $sk$ gives a relative saving
$(s-c)/s - A/(sk)$, strictly increasing in the pool size $k$ and converging to
the ceiling $(s-c)/s$; when $A < s - c$ there is no crossover at any $k \ge 1$.
This reproduces the measured behaviour — batch ahead at every pool size
$k \in \{1,8,64,512\}$, best relative gain $+0.104$ at $k = 512$ — but it also
shows that "batch always wins" is *equivalent to the calibration inequality
$A < s - c$*, not a theorem about batching. In a word-operation model the sign
reverses: a balanced product tree over $2^L$ leaves of $w$ words costs
$w^2(4^L - 2^L)/2$ word operations, quadratic in the pool size, so batch loses
beyond an explicit threshold; in the continuous two-parameter model the crossover
is unique and equals $M^{*} = 1 + (s_1 - c_1)/q$, calibrated to the measured
$M^{*} \approx 1715$ candidates.

Both regimes are one formula. For a stream processed in blocks of size $k$, the
per-candidate cost $A/k + c + q(k-1)$ is strictly decreasing when $q = 0$ and has
a unique interior minimum $c - q + 2\sqrt{Aq}$ at $k^{*} = \sqrt{A/q}$ when
$q > 0$.

Finally we prove the **Amdahl ceiling**. Testing occupies a fraction
$f = S/(F+S) = 11.56\%$ of per-factor work, so no testing improvement can save
more than $f$ overall and the end-to-end speedup factor is at most $1/(1-f)$: a
constant, hence no movement of complexity class. Inverting the measurement, an
overall gain of $0.104$ against $f = 0.1156$ pins the residual testing cost to
exactly $29/289 \approx 10.03\%$ of its former value. We close with the
**relation quota**: any family of more than $\pi(B)$ positive $B$-smooth numbers
contains a nonempty sub-family with square product, so at $B = 100$ exactly $26$
relations suffice — which identifies the experiment's zero split count as a yield
failure rather than an algorithmic one.

**Keywords:** smooth numbers, batch smoothness testing, product trees, remainder
trees, quadratic sieve, Amdahl's law, amortized cost, pigeonhole over
$\mathbb{F}_2$.

---

## 1. Introduction

### 1.1 The setting

Let $B \ge 2$ be a bound. A positive integer $n$ is **$B$-smooth** if every prime
$p$ dividing $n$ satisfies $p \le B$. Smooth numbers are the currency of
subexponential factoring: the quadratic sieve and the number field sieve both
generate a stream of candidate integers, retain the $B$-smooth ones as
*relations*, and then solve a linear system over $\mathbb{F}_2$ on the exponent
vectors of those relations to produce a congruence of squares.

The retention step — deciding smoothness — is executed on every candidate, and is
therefore a first-order cost. The naive method is **solo trial division**: for
each candidate, divide by each prime in the factor base. Its cost is proportional
to $\pi(B)$ per candidate, and nothing computed for one candidate helps with
another.

Bernstein's **batch smoothness test** removes that isolation. It forms a single
large integer $P$, the product of the factor base, and processes an entire pool of
candidates against $P$ in one remainder-tree cascade. The batch arm therefore has
a fundamentally different cost shape: a setup that is paid once, plus a much
smaller per-candidate term.

### 1.2 What is claimed, and what is actually true

A controlled experiment compared the two arms at $B = 100$, candidate bit
length $40$, and pool sizes $k \in \{1, 8, 64, 512\}$, with a finding phase held
identical across arms by construction. Three headline claims emerged:

1. **Correctness.** The batch-detected smooth set matched per-item trial division
   on $500/500$ samples, in each of three variants (tree, direct, vectorized):
   zero mismatches.
2. **Performance.** In a flat operation-count model batch beat solo at *every*
   measured pool size, with best relative improvement $+0.104$ at $k = 512$; in a
   word-operation model the sign reversed at large pools (delta $-62.6$ at
   $k = 512$), with crossover against solo at $M^{*} \approx 1715$ candidates.
3. **Significance.** Solo testing is only $11.56\%$ of per-factor work, so the
   attainable saving is capped there.

This paper is an audit of all three. The outcomes are, respectively: claim 1 is
weaker than the truth and is here strengthened to a theorem over the whole input
range; claim 2 is a statement about calibration constants masquerading as a
statement about batching, and we identify exactly which inequality it is; claim 3
is correct and can moreover be inverted into a measuring instrument. As a
by-product we make precise what the smooth relations were for, and why zero
factorizations were obtained.

### 1.3 Honest placement

Batch smoothness testing is standard, well-understood machinery. Nothing here
moves an asymptotic boundary. What is offered is (i) a proof, rather than a
sample, of the algorithm's exactness on its full input range, including the exact
shortcuts implementations take; (ii) exact closed forms for both cost regimes and
their unification; and (iii) a theorem-level version of the Amdahl bound that
turns two aggregate percentages into a phase-level speedup.

---

## 2. The batch modulus and the exactness criterion

### 2.1 The modulus

**Definition 2.1 (Factor-base product).** For $B \in \mathbb{N}$ let
$$P_B \;=\; \prod_{\substack{p \le B \\ p \text{ prime}}} p$$
be the product of all primes at most $B$ — the *primorial up to $B$*, and the
value held at the root of the product tree over the factor base.

Immediately $P_B > 0$, being a product of positive integers, and in particular
$P_B \ne 0$, which is required for every factorization argument below.

**Lemma 2.2 (Squarefreeness of the modulus).** If $p$ is prime and $p \le B$,
then the exponent of $p$ in the factorization of $P_B$ is exactly $1$.

*Proof sketch.* The factorization of a product is the sum of the factorizations.
Every factor of $P_B$ is a prime $q \le B$, whose factorization is the indicator
of $q$. Summing over the factor base, the coefficient of $p$ picks up the single
term $q = p$, which is present because $p$ is prime and $p \le B$, and every other
term contributes $0$. $\square$

**Lemma 2.3 (Membership criterion).** For $p$ prime, $p \mid P_B$ if and only if
$p \le B$.

*Proof sketch.* ($\Leftarrow$) By Lemma 2.2 the exponent of $p$ in $P_B$ is
positive, hence $p \mid P_B$. ($\Rightarrow$) A prime dividing a finite product
divides one of the factors; that factor is a prime $q \le B$, and
$p \mid q$ with both prime forces $p = q \le B$. $\square$

Lemma 2.3 is the statement that the batch modulus *is* the factor base: it encodes
membership in the factor base as divisibility, which is precisely the property
that makes a single integer able to stand in for $\pi(B)$ separate divisions.

### 2.2 Smoothness

**Definition 2.4 (Smoothness).** $n$ is **$B$-smooth**, written
$\mathrm{Smooth}_B(n)$, if for every prime $p$ with $p \mid n$ we have $p \le B$.

**Lemma 2.5 (Decidable form).** For $n \ne 0$, $\mathrm{Smooth}_B(n)$ holds if and
only if every element of the finite set of prime factors of $n$ is at most $B$.

*Proof sketch.* Both directions are unfolding: membership in the prime-factor set
of a nonzero $n$ is exactly the conjunction "prime and divides". $\square$

Lemma 2.5 is what solo trial division decides. The point of the next theorem is
that a completely different computation decides the same predicate.

### 2.3 The criterion

**Theorem 2.6 (Batch Smoothness Criterion — exactness).** Let $B, t \in
\mathbb{N}$ and let $n$ satisfy $0 < n < 2^t$. Then
$$\mathrm{Smooth}_B(n) \quad\Longleftrightarrow\quad n \mid P_B^{\,t}.$$

*Proof sketch.* **Soundness ($\Leftarrow$).** Let $p$ be a prime with $p \mid n$.
Then $p \mid P_B^{\,t}$, and a prime dividing a power divides the base, so
$p \mid P_B$, whence $p \le B$ by Lemma 2.3. Note that soundness uses neither
positivity nor the size bound.

**Completeness ($\Rightarrow$).** Since $n > 0$ and $P_B^{\,t} \ne 0$,
divisibility is equivalent to a pointwise inequality of factorizations: it
suffices to show, for every prime $p$, that the exponent $v_p(n)$ is at most
$v_p(P_B^{\,t})$. If $p$ is not prime or $p \nmid n$, then $v_p(n) = 0$ and there
is nothing to prove. Otherwise $p \le B$ by smoothness, so by Lemma 2.2 and
multiplicativity of exponents under powers, $v_p(P_B^{\,t}) = t \cdot 1 = t$. It
remains to show $v_p(n) \le t$. Write $e = v_p(n)$. Then $p^{e} \mid n$, hence
$$2^{e} \;\le\; p^{e} \;\le\; n \;<\; 2^{t},$$
using $p \ge 2$ for the first inequality and $n > 0$ for the second. Strict
monotonicity of $x \mapsto 2^x$ gives $e < t$, so certainly $e \le t$. $\square$

Two remarks on the structure of this proof. First, the two directions have
genuinely different content: soundness is a statement about primes and is
essentially free, while completeness is a *quantitative* statement and is the only
place where the bit-length hypothesis is used. Second, the mechanism of
completeness is a conversion of size information into exponent information via the
minimality of $2$ among primes.

### 2.4 Sharpness

**Theorem 2.7 (Sharpness of the exponent).** For $B \ge 2$ and all $t, s \in
\mathbb{N}$,
$$2^{t} \mid P_B^{\,s} \quad\Longleftrightarrow\quad t \le s .$$

*Proof sketch.* By Lemma 2.2 with $p = 2$ (legitimate since $2 \le B$), the
exponent of $2$ in $P_B$ is $1$, so the exponent of $2$ in $P_B^{\,s}$ is $s$. For
a prime power, $p^{t} \mid m$ with $m \ne 0$ iff $t \le v_p(m)$. $\square$

**Corollary 2.8 (The size bound is indispensable).** For every $B \ge 2$, the
number $4$ is $B$-smooth yet $4 \nmid P_B^{\,1}$.

*Proof sketch.* Smoothness of $4 = 2^2$: any prime dividing it equals $2 \le B$.
Failure of the criterion at exponent $1$: by Theorem 2.7, $2^2 \mid P_B^{\,1}$
would force $2 \le 1$. $\square$

Thus one cannot replace $t$ by any smaller function of the candidate without
losing completeness: the family $n = 2^t$ saturates the bound for every $t$. In
practice this means the exponent must track the *bit length* of the candidates,
not their number and not the factor base size.

### 2.5 The shortcuts implementations take

An implementation does not compute $P_B^{\,t}$, and does not divide by it. Two
reductions make the criterion cheap; both preserve it exactly.

**Theorem 2.9 (Repeated-squaring form).** If $0 < n < 2^t$ and $t \le 2^{e}$, then
$$\mathrm{Smooth}_B(n) \quad\Longleftrightarrow\quad n \mid P_B^{\,2^{e}} .$$

*Proof sketch.* From $t \le 2^e$ we get $2^t \le 2^{2^e}$, so $n < 2^{2^e}$;
apply Theorem 2.6 with $2^e$ in place of $t$. $\square$

That is: exponentiation to a power of two — $e$ squarings — is legal as soon as
$2^e$ dominates the bit length. For $t = 40$, $e = 6$ suffices: six squarings per
candidate.

**Theorem 2.10 (Remainder-tree form).** If $0 < n < 2^t$ then
$$\mathrm{Smooth}_B(n) \quad\Longleftrightarrow\quad \bigl(P_B \bmod n\bigr)^{t}
\bmod n \;=\; 0 .$$

*Proof sketch.* Combine Theorem 2.6 with the congruence
$(a \bmod n)^t \equiv a^t \pmod n$ and the equivalence between divisibility and
vanishing remainder. $\square$

Theorem 2.10 is the licence for the whole algorithm. The huge integer $P_B$ enters
each candidate only through its residue $P_B \bmod n$, which is smaller than $n$;
every subsequent operation is on operands of the candidate's own size. The
remainder tree computes all $k$ residues $P_B \bmod n_i$ in one cascade, and the
$e$ squarings are single-word or few-word operations.

### 2.6 Tree shape is irrelevant

**Definition 2.11 (Product tree).** A *product tree* is a finite binary tree with
natural numbers at the leaves. Its **value** is defined by
$\mathrm{val}(\mathrm{leaf}(n)) = n$ and
$\mathrm{val}(\mathrm{node}(L,R)) = \mathrm{val}(L)\cdot\mathrm{val}(R)$; its
**leaf list** is defined by $\mathrm{lv}(\mathrm{leaf}(n)) = [n]$ and
$\mathrm{lv}(\mathrm{node}(L,R)) = \mathrm{lv}(L) \mathbin{+\!\!+} \mathrm{lv}(R)$.

**Theorem 2.12 (Shape independence).** For every product tree $T$,
$\mathrm{val}(T)$ equals the product of the entries of $\mathrm{lv}(T)$.

*Proof sketch.* Structural induction. Leaves are immediate; at a node, the value is
the product of the two subtree values, which by induction are the products of the
two leaf sublists, and the product of a concatenation is the product of the
products. $\square$

**Corollary 2.13.** If the leaf list of $T$ is any permutation of the factor base
$\{p : p \le B\}$, then $\mathrm{val}(T) = P_B$.

*Proof sketch.* By Theorem 2.12 the value is the product over the leaf list, and a
product over a list is invariant under permutation (multiplication in $\mathbb{N}$
being commutative and associative), giving the product over the factor base.
$\square$

This is the formal reason the "tree" and "direct" arms of the audit could not
disagree: they test literally the same divisibility relation, since they compute
literally the same modulus. Any observed disagreement would have indicated an
implementation bug, never a difference of method.

### 2.7 The audit, as a theorem

**Theorem 2.14 (Exact-match audit).** Let $B, t \in \mathbb{N}$ and let $S$ be a
finite set of candidates with $0 < n < 2^t$ for every $n \in S$. Then
$$\{\, n \in S : n \mid P_B^{\,t} \,\} \;=\; \{\, n \in S : \text{every prime
factor of } n \text{ is} \le B \,\}.$$

*Proof sketch.* Filtering by two predicates gives the same set when the predicates
agree pointwise on the set. For $n \in S$ we have $0 < n < 2^t$, so Lemma 2.5 and
Theorem 2.6 give the agreement. $\square$

**Corollary 2.15 (The measured audit instance).** With $B = 100$, $t = 9$ and
$S = \{1, \dots, 500\}$ — every candidate is below $2^9 = 512$ — the batch-detected
and trial-detected smooth sets coincide.

*Proof sketch.* Immediate from Theorem 2.14 once one notes $1 \le n \le 500 < 2^9$.
$\square$

The methodological point deserves emphasis. The observation "$500/500$ samples
agreed" is a statement about $500$ integers; there are on the order of $10^{12}$
candidates of bit length $40$. Theorem 2.14 says the agreement is a property of the
predicates, not of the sample: on *any* pool, of *any* size, in *any* bit-length
range compatible with the exponent, the two filters return the same set.

---

## 3. The cost dichotomy

Correctness is settled. The remaining claims are quantitative, and they are where
the interesting negative results live.

### 3.1 Product-tree operation counts

**Definition 3.1 (Flat op count).** Let $\mathrm{FlatOps}(L)$ be the number of
multiplications in a balanced product tree over $2^L$ leaves, one operation per
internal node: $\mathrm{FlatOps}(0) = 0$ and
$\mathrm{FlatOps}(L+1) = 2\,\mathrm{FlatOps}(L) + 1$.

**Proposition 3.2.** $\mathrm{FlatOps}(L) + 1 = 2^{L}$; i.e. the tree has
$2^L - 1$ internal nodes.

*Proof sketch.* Induction on $L$: the base case is $0 + 1 = 1$, and the step is
$2(2^L - 1) + 1 + 1 = 2^{L+1}$. $\square$

So in the flat model the tree is *linear* in the pool size. This is the model in
which batching looks unambiguously good.

**Definition 3.3 (Word cost).** With schoolbook multiplication, multiplying two
$m$-word integers costs $m^2$ word operations. Let $\mathrm{WordCost}(w, L)$ be the
word cost of a balanced product tree over $2^L$ leaves of $w$ words each:
$\mathrm{WordCost}(w, 0) = 0$ and
$$\mathrm{WordCost}(w, L+1) \;=\; 2\,\mathrm{WordCost}(w, L) + (2^{L}w)^{2},$$
the last term being the topmost multiplication of two operands of $2^{L}w$ words.

**Theorem 3.4 (Closed form).** For all $w, L$,
$$2\,\mathrm{WordCost}(w,L) + w^{2}2^{L} \;=\; w^{2}4^{L},
\qquad\text{i.e.}\qquad
\mathrm{WordCost}(w,L) = \frac{w^{2}\left(4^{L} - 2^{L}\right)}{2}.$$

*Proof sketch.* Induction on $L$. The base case is $0 + w^2 = w^2$. For the step,
write $4^{L+1} = 4\cdot 4^L$, $2^{L+1} = 2\cdot 2^L$, and
$(2^Lw)^2 = w^2 4^L$ (using $4^L = 2^L 2^L$); substituting the inductive identity
and simplifying gives the claim. The statement is phrased additively to avoid
truncated subtraction over $\mathbb{N}$. $\square$

**Corollary 3.5 (Lower bound).**
$w^{2}\,2^{L}\left(2^{L} - 1\right) \le 2\,\mathrm{WordCost}(w,L)$.

The essential content: **the same tree is linear in the flat model and quadratic
in the word model.** Every disagreement between the two accountings below descends
from this single fact.

### 3.2 The flat model: amortization without crossover

Throughout this subsection, $A$ is the one-off setup cost (building the factor-base
product tree), $c$ the per-candidate batch cost (a remainder-tree node plus the
squarings), and $s$ the per-candidate solo cost.

**Definition 3.6.** $\mathrm{Batch}(k) = A + ck$, $\mathrm{Solo}(k) = sk$, and the
relative saving on a pool of size $k$ is
$\sigma(k) = 1 - \mathrm{Batch}(k)/\mathrm{Solo}(k)$.

**Theorem 3.7 (Explicit saving).** For $s > 0$ and $k > 0$,
$$\sigma(k) \;=\; \frac{s-c}{s} \;-\; \frac{A}{sk}.$$

*Proof sketch.* Direct algebra: $1 - (A + ck)/(sk) = (sk - ck - A)/(sk)$. $\square$

The decomposition is the whole story: a **ceiling** $(s-c)/s$, which is what you
would obtain with free setup, minus an **amortized setup term** $A/(sk)$, which
decays like $1/k$.

**Theorem 3.8 (No crossover).** If $0 \le A < s - c$, then
$\mathrm{Batch}(k) < \mathrm{Solo}(k)$ for every $k \ge 1$.

*Proof sketch.* $\mathrm{Solo}(k) - \mathrm{Batch}(k) = (s-c)k - A =
(s-c) + (s-c)(k-1) - A > (s-c)(k-1) \ge 0$, using $A < s-c$ and $k \ge 1$.
$\square$

This is precisely the measured phenomenon "batch beats solo at every pool size,
no crossover below solo" — and Theorem 3.8 exhibits it as *equivalent* to a
calibration inequality relating three implementation constants. It is a fact about
one implementation on one machine, not a property of batching. Reverse the
inequality and batch loses at small $k$ and wins only after a crossover; the
algorithm is unchanged.

**Theorem 3.9 (Monotone amortization).** If $s > 0$, $A > 0$ and
$0 < k_1 < k_2$, then $\sigma(k_1) < \sigma(k_2)$.

*Proof sketch.* By Theorem 3.7 the only $k$-dependence is $-A/(sk)$, and
$A/(sk_2) < A/(sk_1)$ since $A > 0$ and $sk_1 < sk_2$. $\square$

**Theorem 3.10 (Strict ceiling and limit).** For $s > 0$, $A > 0$, $k > 0$ one has
$\sigma(k) < (s-c)/s$, and $\sigma(k) \to (s-c)/s$ as $k \to \infty$.

*Proof sketch.* The gap is exactly $A/(sk) > 0$, which tends to $0$. $\square$

Interpretation: **amortization can eliminate setup cost entirely, and can never
touch per-candidate cost.** The measured $+0.104$ at $k = 512$ therefore sits below
a hard model ceiling $(s-c)/s$ that no increase in pool size can breach.

### 3.3 The word model: the sign reverses

**Theorem 3.11 (Word-model reversal).** If $2s + w^{2} < w^{2}2^{L}$, then
$$s\,2^{L} \;<\; \mathrm{WordCost}(w, L),$$
i.e. the factor-base tree *alone* costs more word operations than all of solo
trial division on the same pool.

*Proof sketch.* Multiply the hypothesis by $2^L > 0$ to obtain
$2s\,2^L + w^2 2^L < w^2 4^L$, and compare with the closed form
$w^2 4^L = 2\,\mathrm{WordCost}(w,L) + w^2 2^L$; cancelling $w^2 2^L$ gives
$2s\,2^L < 2\,\mathrm{WordCost}(w,L)$. $\square$

Since the threshold depends only on the ratio $s/w^2$, the reversal is unavoidable
for schoolbook big-integer arithmetic: it is not a tuning artefact. Concretely, at
$w = 8$ words (a $512$-bit intermediate unit) against a solo cost of $s = 1000$
word operations per candidate, pools of $2^6 = 64$ candidates already lose:
$1000 \cdot 64 < \mathrm{WordCost}(8, 6)$.

**Definition 3.12 (Continuous word model).**
$\mathrm{BatchW}(k) = qk(k-1) + c_1 k$ and $\mathrm{SoloW}(k) = s_1 k$, where $q >
0$ is the quadratic big-integer coefficient (product and remainder trees) and
$c_1$ the linear per-candidate term.

**Theorem 3.13 (Unique crossover, closed form).** For $q > 0$ and $k > 0$,
$$\mathrm{BatchW}(k) \le \mathrm{SoloW}(k) \quad\Longleftrightarrow\quad
k \;\le\; 1 + \frac{s_1 - c_1}{q}.$$

*Proof sketch.* Divide by $k > 0$: the inequality becomes
$q(k-1) + c_1 \le s_1$, i.e. $q k \le q + s_1 - c_1$, i.e.
$k \le (q + s_1 - c_1)/q = 1 + (s_1-c_1)/q$. $\square$

So the comparison changes sign exactly once, and $M^{*} = 1 + (s_1-c_1)/q$ is the
crossover.

**Corollary 3.14 (Calibration to the measurement).** The reported crossover
$M^{*} \approx 1715$ is exactly the calibration $s_1 - c_1 = 1714\,q$; under it,
$\mathrm{BatchW}(k) \le \mathrm{SoloW}(k)$ if and only if $k \le 1715$.

**Corollary 3.15 (Sign change inside deployment range).** Under the same
calibration, batch is favourable at $k = 512$ and unfavourable at $k = 4096$.

The practical consequence is a deployment caveat rather than a mathematical one:
whether batching helps depends on which operations are charged, and the answer
flips inside the range of pool sizes one would actually use. In particular the
flat-model conclusion "always better" and the word-model measurement
"$-62.6$ at $k = 512$" are not contradictory reports; they are two cost functionals
evaluated on the same algorithm.

### 3.4 Unification: one formula, both regimes

**Definition 3.16 (Block cost).** For a long stream of candidates processed in
blocks of size $k$, the per-candidate cost is
$$\mathrm{cost}(k) \;=\; \frac{A}{k} \;+\; c \;+\; q(k-1),$$
where $A$ is the per-block setup, $c$ the flat per-candidate cost and $q \ge 0$ the
quadratic big-integer penalty.

**Theorem 3.17 (Degenerate case $q = 0$).** If $A > 0$ and $0 < k_1 < k_2$ then
$\mathrm{cost}(k_2) < \mathrm{cost}(k_1)$.

*Proof sketch.* With $q = 0$ the cost is $A/k + c$, and $A/k$ is strictly
decreasing for $A > 0$. $\square$

So in the flat model there is **no optimal pool size**: bigger is always better,
matching the measured monotone improvement across $k = 1, 8, 64, 512$.

**Theorem 3.18 (AM–GM lower bound).** If $A, q > 0$ and $k > 0$ then
$$\mathrm{cost}(k) \;\ge\; c - q + 2\sqrt{Aq}.$$

*Proof sketch.* Apply $(\sqrt{A/k} - \sqrt{qk})^2 \ge 0$, i.e.
$A/k + qk \ge 2\sqrt{(A/k)(qk)} = 2\sqrt{Aq}$, and add $c - q$. $\square$

**Theorem 3.19 (Attainment and uniqueness).** For $A, q > 0$ and $k > 0$,
$$\mathrm{cost}(k) = c - q + 2\sqrt{Aq} \quad\Longleftrightarrow\quad
k = k^{*} := \sqrt{A/q},$$
and $\mathrm{cost}(k^*) = c - q + 2\sqrt{Aq}$.

*Proof sketch.* ($\Leftarrow$) Substitute $k = \sqrt{A/q}$: then
$A/k = q\sqrt{A/q} = \sqrt{Aq} = qk$, so the cost is $2\sqrt{Aq} + c - q$.
($\Rightarrow$) Equality in the AM–GM step forces
$(\sqrt{A/k} - \sqrt{qk})^2 = 0$, hence $A/k = qk$, hence $k^2 = A/q$, hence
$k = \sqrt{A/q}$ as $k > 0$. $\square$

This is the structural statement of the paper's quantitative half. The two
"phenomena" — unbounded amortization and quadratic blow-up — are the two branches
$q = 0$ and $q > 0$ of a single curve. Moreover the optimal batch size is a
**square root of a cost ratio**, not a function of the tree depth or the factor
base. A numerical shadow: with $A = 1000$ operations and $q = 1/1000$ one gets
$k^{*} = \sqrt{10^6} = 1000$ candidates, the same order of magnitude as the
measured word-model crossover $M^{*} \approx 1715$.

---

## 4. The Amdahl ceiling on a testing-phase improvement

Even a perfect testing algorithm is only as valuable as the share of the work that
testing represents. Let per-factor work split into a finding phase of cost $F \ge
0$ and a testing phase of cost $S > 0$, with testing share
$$f \;=\; \frac{S}{F+S}.$$
The measured value is $f = 0.1156$.

**Theorem 4.1 (Amdahl cap).** For $F \ge 0$, $S > 0$, and any replacement testing
cost $S' \ge 0$, the overall relative saving satisfies
$$\frac{(F+S) - (F+S')}{F+S} \;\le\; \frac{S}{F+S} \;=\; f.$$

*Proof sketch.* The numerator is $S - S' \le S$ since $S' \ge 0$, and the
denominator $F + S$ is positive. $\square$

**Theorem 4.2 (Bounded speedup factor).** For $F, S > 0$ and $S' \ge 0$,
$$\frac{F+S}{F+S'} \;\le\; \frac{F+S}{F} \;=\; \frac{1}{1-f}.$$

*Proof sketch.* $F + S' \ge F > 0$, and $x \mapsto (F+S)/x$ is decreasing on the
positives. The identity $(F+S)/F = 1/(1-f)$ follows from $1 - f = F/(F+S)$.
$\square$

At $f = 0.1156$ the ceiling is $1/(1-f) \approx 1.131$. This is a **constant**
factor: no improvement to the testing phase — not even an infinitely fast one —
can change the asymptotic class of the factoring pipeline. The measured overall
gain $+0.104 < 0.1156$ therefore lies below the cap by necessity rather than by
coincidence, and even the ideal arm cannot reach $+0.12$.

The bound also runs backwards, which is more interesting.

**Theorem 4.3 (Phase residual).** With $S > 0$, $F + S > 0$, and overall saving
$$d \;=\; \frac{(F+S)-(F+S')}{F+S},$$
the surviving testing cost satisfies
$$\frac{S'}{S} \;=\; 1 - d\cdot\frac{F+S}{S} \;=\; 1 - \frac{d}{f}.$$

*Proof sketch.* The definition of $d$ gives $S - S' = d(F+S)$, so
$S' = S - d(F+S)$; divide by $S$. $\square$

**Corollary 4.4 (Inverting the measurement).** With $f = 1156/10000$ and
$d = 104/1000$,
$$\frac{S'}{S} \;=\; 1 - \frac{0.104}{0.1156} \;=\; \frac{29}{289} \;\approx\;
10.03\%,$$
i.e. the batch testing phase costs $\approx 10.03\%$ of the solo testing phase —
a phase-level speedup of $\approx 9.97\times$.

This is a genuine measuring instrument: two aggregate numbers, the testing share
and the end-to-end saving, determine the phase-level speedup *exactly*, with no
instrumentation of the phase itself. It also reframes the headline. The result is
not "a $10\%$ faster factorization"; it is "a $10\times$ faster testing phase,
inside a pipeline where testing is one part in nine".

---

## 5. What the smooth relations are for: the relation quota

The experiment produced zero successful sieve splits at bit length $40$ with
$B = 100$. This section shows that the requirement for a split is a clean counting
condition, and hence that the zero is a *yield* deficit, not an algorithmic fault.

**Theorem 5.1 (Subset pigeonhole over $\mathbb{F}_2$).** Let $\iota$ and $\kappa$
be finite index sets with $|\kappa| < |\iota|$, and let
$v : \iota \to \mathbb{F}_2^{\kappa}$ be any family of vectors. Then there is a
nonempty $S \subseteq \iota$ with $\sum_{i \in S} v_i = 0$.

*Proof sketch.* The number of subsets of $\iota$ is $2^{|\iota|}$, while the number
of possible values of a subset sum is $|\mathbb{F}_2^{\kappa}| = 2^{|\kappa|} <
2^{|\iota|}$. By pigeonhole two distinct subsets $S \ne T$ have equal sums. Put
$U = (S \setminus T) \cup (T \setminus S)$, which is nonempty since $S \ne T$.
Splitting each of $S$ and $T$ into its intersection with the other and its
difference, and cancelling the common intersection sum, gives
$\sum_{S \setminus T} v = \sum_{T \setminus S} v$; adding these two equal sums over
the disjoint union $U$ yields $0$ in characteristic $2$. $\square$

Note what is *not* assumed: the family $v$ need not be injective. Repeated
relations are permitted, which matters because a real smoothness batch produces
duplicates, and the usual linear-dependence formulation would not apply.

**Theorem 5.2 (Even exponents give squares).** If $n \ne 0$ and $v_p(n)$ is even
for every prime $p$, then $n$ is a perfect square.

*Proof sketch.* Take $m = \prod_p p^{v_p(n)/2}$ over the (finite) support of the
factorization. Then $m \cdot m = \prod_p p^{v_p(n)/2 + v_p(n)/2} = \prod_p
p^{v_p(n)} = n$, using evenness for the exponent identity and the
factorization-reconstruction identity for the last step. $\square$

**Theorem 5.3 (Relation quota).** Let $n_1, \dots, n_m$ be positive $B$-smooth
integers with $m > \pi(B)$, where $\pi(B)$ is the number of primes at most $B$.
Then there is a nonempty subset $S \subseteq \{1, \dots, m\}$ such that
$\prod_{i \in S} n_i$ is a perfect square.

*Proof sketch.* Index coordinates by the factor base
$\kappa = \{p : p \le B\}$, and send each relation to its exponent vector modulo
$2$:
$$v_i(p) \;=\; v_p(n_i) \bmod 2 \;\in\; \mathbb{F}_2 .$$
Since $m > \pi(B) = |\kappa|$, Theorem 5.1 supplies a nonempty $S$ with
$\sum_{i \in S} v_i = 0$. Set $N = \prod_{i \in S} n_i \ne 0$. For any prime $p$,
additivity of exponents over products gives
$v_p(N) = \sum_{i \in S} v_p(n_i)$. If $p \le B$ is prime, the vanishing
coordinate says this sum is even. If $p > B$ is prime, each $v_p(n_i) = 0$ by
smoothness. If $p$ is not prime, each term is $0$. In all cases $v_p(N)$ is even,
so $N$ is a square by Theorem 5.2. $\square$

**Corollary 5.4 (Quota at $B = 100$).** $\pi(100) = 25$, so any $26$ positive
$100$-smooth relations contain a nonempty sub-family with square product.

Theorem 5.3 is the guarantee that the linear-algebra stage of the quadratic sieve
*cannot fail* once the quota is met; conversely, no amount of speed in the testing
stage produces a split before the quota is met. The experiment's zero split count
at bit length $40$ / $B = 100$ is therefore explained: the pipeline never
accumulated $26$ relations, the smooth density at those parameters being on the
order of $10^{-4}$.

A caveat on yield, stated honestly. An elementary upper bound on the count
$\Psi(x, B)$ of $B$-smooth numbers below $x$ by counting admissible exponent
vectors gives, at $x = 2^{40}$ and $B = 100$,
$$\Psi(2^{40}, 100) \;\le\; \prod_{p \le 100}\left(1 + \frac{40}{\log_2 p}\right)
\;\approx\; 10^{22},$$
which exceeds $2^{40} \approx 10^{12}$ and is therefore vacuous. A non-trivial
yield statement requires Dickman-type input; the observed density $\approx
10^{-4}$ is empirical, and we do not claim it as proved.

---

## 6. Algorithms

### 6.1 Factor-base product tree

Build $P_B$ from the primes $p_1 < \cdots < p_r \le B$ by pairwise multiplication:
place the primes at the leaves, and repeatedly replace consecutive pairs by their
product until one value remains. By Theorem 2.12 the result is $P_B$ regardless of
pairing order. Flat cost: $r - 1$ multiplications (Proposition 3.2). Word cost with
schoolbook multiplication and $w$-word leaves: $w^2(4^L - 2^L)/2$ for $r = 2^L$
(Theorem 3.4). This step is executed once per run.

### 6.2 Remainder tree

Given candidates $n_1, \dots, n_k$, build their product tree, then descend from the
root carrying residues: at the root store $P_B \bmod \mathrm{val}(\text{root})$,
and at each child store the parent's stored value reduced modulo that child's
value. The leaves then hold $P_B \bmod n_i$ for all $i$. The invariant maintained
is that each stored value is congruent to $P_B$ modulo the subtree's product, which
is preserved by reduction because the child's value divides the parent's.

### 6.3 Batch smoothness filter

Choose $e$ with $2^e \ge t$ where $t$ is the candidate bit length (for $t = 40$,
$e = 6$). For each leaf residue $r_i = P_B \bmod n_i$, square $e$ times modulo
$n_i$ and report $n_i$ as smooth exactly when the result is $0$. Correctness is
Theorem 2.9 together with Theorem 2.10; exactness against trial division on the
whole pool is Theorem 2.14.

### 6.4 Cost-model selection

Given calibration constants $A$ (setup), $c$ (per-candidate batch), $s$ (per
candidate solo) and $q$ (quadratic penalty): if $q = 0$, choose the largest
feasible pool (Theorem 3.17); if $q > 0$, choose $k^{*} = \sqrt{A/q}$ (Theorem
3.19) and check the crossover $M^{*} = 1 + (s-c)/q$ (Theorem 3.13). Report the
achievable overall gain as $\min\{\text{phase gain}\} \cdot f$ capped by $f$
(Theorem 4.1).

---

## 7. Discussion

Three conclusions, in decreasing order of durability.

**The exactness result is a theorem and stays one.** The batch criterion decides
$B$-smoothness on the nose for all $0 < n < 2^t$; the exponent $t$ is minimal;
the modular and squaring shortcuts are exact; tree shape is immaterial; and the
batch filter equals the trial-division filter on every pool. Nothing in this
depends on hardware, model, or calibration. It converts an empirical audit into a
guarantee, and it identifies exactly which hypothesis (the bit-length bound) is
load-bearing, with a saturating family ($n = 2^t$) showing it cannot be relaxed.

**The performance result is a calibration, and should be reported as one.** "Batch
wins at every pool size" is *equivalent* to $A < s - c$ in the flat model. The
word-level accounting, which charges big-integer intermediates honestly, reverses
the conclusion past $M^{*} \approx 1715$ candidates. The correct summary is not
"batching wins" or "batching loses" but: the per-candidate cost is
$A/k + c + q(k-1)$, and everything follows from whether $q$ is zero — which is a
statement about the multiplication routine, not about the algorithm.

**The significance was capped before the experiment ran.** With testing at
$11.56\%$ of per-factor work, the ceiling on any testing improvement is $11.56\%$
overall and $1.131\times$ end-to-end. This is constant-shaving on a known method:
useful engineering, zero class movement. The consolation, and it is a real one, is
the inversion: the pair (share $= 11.56\%$, gain $= 10.4\%$) determines the
phase-level residual to be exactly $29/289$, so the experiment did in fact measure
a $\approx 9.97\times$ testing speedup — it simply could not translate into more
than $10.4\%$ overall.

Finally, the relation quota tells us where to look next. The bottleneck in the
measured configuration was not testing speed but smooth *yield*: $26$ relations
suffice at $B = 100$, and the run never got them. Effort spent enlarging the
factor base, raising the candidate supply, or improving the sieve's finding phase
dominates any further constant on the testing side — which is exactly what the
Amdahl cap said in advance.

---

## 8. Future work

- **Sub-quadratic multiplication.** With a multiplication exponent
  $\mu \in (1,2]$ the block cost should become $A/k + c + q k^{\mu - 1}$, giving
  an optimum $k^{*} \propto (A/q)^{1/\mu}$; the square-root law of Theorem 3.19 is
  the case $\mu = 2$. Verifying that the crossover scales as predicted under
  Karatsuba ($\mu = \log_2 3$) and FFT-based multiplication ($\mu \to 1$) is a
  direct, testable prediction — and $\mu \to 1$ predicts the disappearance of the
  interior optimum, restoring the flat regime.
- **Provable yield.** The elementary exponent-vector bound on $\Psi(x, B)$ is
  vacuous at the relevant parameters. A usable statement needs Dickman-type input;
  proving even a weak effective version would turn the observed $10^{-4}$
  density into a theorem and let the relation quota be converted into a candidate
  budget.
- **Calibration as a first-class object.** Since "batch wins" reduces to
  $A < s - c$, a systematic measurement of $(A, c, s, q)$ across architectures and
  bignum libraries would replace anecdote with a phase diagram in the
  $(k, \mu)$ plane.
- **Beyond the testing phase.** The Amdahl analysis applies verbatim to any phase
  of the sieve; applying it to the finding phase (which holds the remaining
  $88.44\%$) is where an end-to-end improvement would have to come from.

---

## 9. Summary of results

| Result | Statement |
|---|---|
| Batch Smoothness Criterion | For $0 < n < 2^t$: $n$ is $B$-smooth $\iff n \mid P_B^t$ |
| Sharpness | $2^t \mid P_B^s \iff t \le s$; the exponent $t$ is minimal |
| Repeated-squaring form | $t \le 2^e \Rightarrow$ criterion holds with exponent $2^e$ |
| Remainder-tree form | $n$ smooth $\iff (P_B \bmod n)^t \bmod n = 0$ |
| Shape independence | Every product tree over the factor base evaluates to $P_B$ |
| Exact-match audit | Batch filter $=$ trial-division filter on every valid pool |
| Flat saving | $\sigma(k) = (s-c)/s - A/(sk)$; strictly increasing, ceiling $(s-c)/s$ |
| No crossover | $A < s - c \Rightarrow$ batch cheaper for all $k \ge 1$ |
| Tree word cost | $w^2(4^L - 2^L)/2$: quadratic in the pool size |
| Word crossover | $\mathrm{BatchW}(k) \le \mathrm{SoloW}(k) \iff k \le 1 + (s_1-c_1)/q$ |
| Optimal block size | $\mathrm{cost}(k) \ge c - q + 2\sqrt{Aq}$, equality iff $k = \sqrt{A/q}$ |
| Flat degeneracy | $q = 0 \Rightarrow$ cost strictly decreasing: no optimum |
| Amdahl cap | Overall saving $\le f$; speedup factor $\le 1/(1-f)$ |
| Phase residual | $S'/S = 1 - d/f$; at $(0.104, 0.1156)$ this is $29/289$ |
| Relation quota | $> \pi(B)$ smooth relations force a square sub-product; $\pi(100) = 25$ |
