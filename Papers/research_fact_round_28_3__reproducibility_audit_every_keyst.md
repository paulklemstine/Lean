# When Does a Rounded Record Certify an Exact Value?
### Certifiability, closed-form laws and invariance for the cyclic splitting-type channel

**Author:** Aristotle
**Date:** 2026-09-22

---

## Abstract

A reproducibility audit compares a recorded headline number with the output of a
fresh re-run of the same pipeline and declares the two "identical to four
decimals". We analyse the mathematical content of that practice for a concrete
family of arithmetic information quantities and show that it splits into two
disjoint regimes governed by the arithmetic of the recorded value itself.

Let $\mathbb{Z}/n$ carry the *splitting type* $T(a) = n/\gcd(n,a)$, the order of
a residue, and record two derived quantities: the type entropy $H_T(n)$, the
Shannon entropy in bits of $T$ under the uniform distribution, and the pair
capacity $I_{\mathrm{pair}}(n) = I(K;N)$, the mutual information between the
unordered type pair $K=\{T(x),T(y)\}$ of a uniform pair and its norm class
$N = x+y \bmod n$.

We prove: (i) a **separation theorem** — distinct rationals with denominators
$q,r$ differ by at least $1/qr$ — whence four-decimal agreement *proves*
bit-for-bit equality whenever both denominators are at most $70$, a threshold
that fails by $|1/100 - 1/101| = 1/10100 < 10^{-4}$; (ii) a **two-adic entropy
law** $H_T(2^k) = 2 - 2^{1-k}$, strictly increasing with a hard two-bit ceiling
and inter-row gap $H_T(2^k) - H_T(2^j) \ge 2^{-j}$ for $j<k$, which certifies
rows for all $k \le 13$ independently of denominator size; (iii) an
**irrationality obstruction** — $I_{\mathrm{pair}}(6) = \log_2 3 - 1/9$ is
irrational, so no finite decimal record can equal it, while the enclosure
$1.58496 < \log_2 3 < 1.58497$, certified by the integer inequalities
$2^{1054} < 3^{665}$ and $3^{306} < 2^{485}$, validates the stored value to the
claimed precision; (iv) a **rationality dichotomy**: on constructible orders —
those $n$ all of whose divisors have power-of-two totient, equivalently the
Gauss–Wantzel constructible $n$ — $H_T(n)$ is rational precisely when $n$ is a
power of two; and (v) an **invariance characterisation**: the record is
unchanged under every change of generator of the cyclic group, and a readout is
so invariant *if and only if* it factors through the splitting type, which is
therefore the universal reproducible observable of the channel.

The conclusion is a reframing of the audit practice: four-decimal agreement is a
theorem about bounded denominators, not a statement about pipelines, and a
record is reproducible by construction exactly when it is invariant under the
arbitrary choices in its own definition.

**Keywords.** reproducibility, Farey dissection, splitting type, Shannon
entropy, mutual information, Jacobsthal numbers, irrationality, constructible
polygons, Galois invariance.

---

## 1. Introduction

### 1.1 The practice and the question

Computational mathematics stores numbers. A pipeline is run, a value such as
$1.3125$ or $1.4738$ is written into a table, and the table is cited. Later the
pipeline is run again — with the same fixed seeds, on the same inputs — the two
printed values are compared digit by digit, and if they agree to the recorded
precision the entry is declared **reproduced**.

The practice is sound as an operational control: it detects code rot, changed
defaults, uncontrolled randomness, and platform drift. But taken literally the
verdict is a statement about two decimal strings, and it is worth asking what
mathematical statement, if any, it establishes about the two *numbers*.

Three questions organise this paper.

* **(Q1) Certifiability.** Under what hypotheses does agreement of two values to
  $k$ decimals force them to be *equal*?
* **(Q2) Stratification.** For a concrete family of recorded quantities, which
  entries satisfy those hypotheses and which provably cannot?
* **(Q3) Construction.** Is there a notion of reproducibility that does not
  depend on re-running anything — one where the record is forced by the
  definition of the observable rather than by the determinism of the code?

The answers turn out to be, respectively: a Farey-type separation bound; a clean
dichotomy indexed by classical constructibility of the regular $n$-gon; and a
universality theorem identifying the unique observable whose record survives
every arbitrary coordinate choice in the pipeline.

### 1.2 The recorded quantities

All quantities audited here come from a small arithmetic channel that models
the splitting behaviour of primes in a cyclic extension. Its definitions occupy
Section 2; informally, residues modulo $n$ play the role of Frobenius elements,
each residue is read out by the order it has in the group, and two entropies are
recorded: the entropy of that readout for a single residue, and the mutual
information between the pair of readouts of two residues and the readout of
their product.

### 1.3 Contributions

1. **Separation and the four-decimal certificate** (Section 3). Distinct
   rationals with denominators $q$ and $r$ are at least $1/qr$ apart; the bound
   is attained; the resulting certificate is valid for denominators up to $70$
   at four-decimal precision and fails at $100$.
2. **Closed-form laws for the two-adic tower** (Section 4). The recorded rows
   $H_T(2) = 1$, $H_T(4) = 3/2$, $H_T(8) = 7/4$, $H_T(16) = 15/8$ are the
   $k \le 4$ instances of $H_T(2^k) = 2 - 2^{1-k}$; monotonicity, the two-bit
   ceiling, a gap estimate and a structural certificate valid for $k \le 13$
   follow.
3. **The irrational stratum** (Section 5). $\log_2 3$ is irrational by unique
   factorisation; hence $I_{\mathrm{pair}}(6) = \log_2 3 - 1/9$ admits no exact
   decimal record; an explicit convergent-based enclosure nevertheless validates
   the stored value.
4. **A rationality dichotomy** (Section 6). On constructible orders, $H_T(n)$ is
   rational iff $n$ is a power of two.
5. **Invariance and its converse** (Section 7). Every recorded quantity is
   invariant under the unit action (change of generator); conversely an
   invariant readout factors through the splitting type, whose fibres are
   exactly the orbits of that action.
6. **Algorithms and numerics** (Sections 8–9), and a synthesis of what an audit
   does and does not certify (Section 10).

---

## 2. The cyclic splitting-type channel

Throughout, $n \ge 1$ is an integer, $\mathbb{Z}/n = \{0,1,\dots,n-1\}$, all
entropies are in bits ($\log_2$), and $\varphi$ is Euler's totient.

**Definition 2.1 (Splitting type).** For $a \in \mathbb{Z}/n$ set
$$T(a) \;=\; \frac{n}{\gcd(n,a)} \in \mathbb{N}.$$
Equivalently $T(a)$ is the order of $a$ in the additive group $\mathbb{Z}/n$. In
the arithmetic reading, if $\mathbb{Z}/n \cong \operatorname{Gal}(L/\mathbb{Q})$
for a cyclic extension $L$ and $a$ is the Frobenius class of an unramified prime
$p$, then $T(a)$ is the residue degree of $p$ in $L$, so $p$ splits into
$n/T(a)$ primes of degree $T(a)$.

**Definition 2.2 (Type distribution and type entropy).** Draw $a$ uniformly from
$\mathbb{Z}/n$. Since $\#\{a : T(a) = d\} = \varphi(d)$ for each divisor
$d \mid n$, the law of $T$ is $\Pr[T=d] = \varphi(d)/n$, and the **type entropy**
is
$$H_T(n) \;=\; -\sum_{d \mid n} \frac{\varphi(d)}{n}\log_2\frac{\varphi(d)}{n}.$$

**Lemma 2.3 (Divisor formula).** For $n \ge 1$,
$$H_T(n) \;=\; \log_2 n \;-\; \frac{1}{n}\sum_{d \mid n} \varphi(d)\,\log_2 \varphi(d).$$

*Proof.* Expand the logarithm of the quotient and use $\sum_{d\mid n}\varphi(d)=n$.
$\square$

This formula is the workhorse of Sections 4 and 6: it exhibits $H_T(n)$ as
$\log_2 n$ minus a *weighted sum of logarithms of totients*, and the
arithmetic nature of that correction term decides the stratum of the record.

**Definition 2.4 (Semiprime pair channel).** Draw $(x,y)$ uniformly from
$\mathbb{Z}/n \times \mathbb{Z}/n$ and record
$$K = \{T(x), T(y)\} \quad\text{(unordered pair)}, \qquad N = x + y \bmod n .$$
$N$ is the *norm class*: the group element attached to the product, i.e. the
Frobenius of the semiprime. The **pair capacity** is the mutual information
$$I_{\mathrm{pair}}(n) \;=\; I(K;N) \;=\; H(K) + H(N) - H(K,N) \;=\; H(K) - H(K \mid N).$$

Operationally $I_{\mathrm{pair}}(n)$ is the number of bits about the joint
splitting behaviour of two hidden factors that leak through the observation of
their product. Because $N$ is uniform on $\mathbb{Z}/n$, one also has
$I_{\mathrm{pair}}(n) = H(K) - \frac1n\sum_{c \in \mathbb{Z}/n} H(K \mid N = c)$,
which is the form used computationally: build the conditional table of key
counts, one row per norm class, and average its row entropies.

**Example 2.5 (Recorded values).** Direct enumeration gives
$$H_T(2) = 1,\quad H_T(4) = \tfrac32,\quad H_T(8) = \tfrac74,\quad H_T(16) = \tfrac{15}{8},$$
$$I_{\mathrm{pair}}(4) = \tfrac54,\quad I_{\mathrm{pair}}(8) = \tfrac{21}{16},\quad I_{\mathrm{pair}}(16) = \tfrac{85}{64},\quad I_{\mathrm{pair}}(6) = \log_2 3 - \tfrac19 .$$
Rounded to four decimals these are the stored records
$1.0000,\ 1.5000,\ 1.7500,\ 1.8750$ and
$1.2500,\ 1.3125,\ 1.3281,\ 1.4738$. Sections 3–6 determine which of these
records can *certify* their values.

---

## 3. Certifiability: the separation theorem

### 3.1 The basic bound

**Theorem 3.1 (Separation of bounded-denominator rationals).** Let
$a, b \in \mathbb{Z}$ and $q, r \in \mathbb{N}_{>0}$. If
$$\left|\frac{a}{q} - \frac{b}{r}\right| < \frac{1}{qr},$$
then $a/q = b/r$.

*Proof sketch.* Multiply through: $(a/q - b/r)\,qr = ar - bq$ is an integer, and
the hypothesis makes its absolute value strictly less than $1$. An integer of
absolute value $<1$ is $0$, so $ar = bq$, i.e. $a/q = b/r$ since $q,r>0$.
$\square$

**Proposition 3.2 (The bound is attained).** For every $Q \ge 1$ the distinct
rationals $1/Q$ and $0/1$ satisfy $|1/Q - 0/1| = 1/(Q\cdot 1)$ exactly. Hence the
strict inequality in Theorem 3.1 cannot be relaxed to $\le$.

**Corollary 3.3 (Precision certificate at level $Q$).** If $0 < q,r \le Q$ and
$|a/q - b/r| < 1/Q^2$, then $a/q = b/r$.

*Proof sketch.* $qr \le Q^2$, so $1/Q^2 \le 1/(qr)$; apply Theorem 3.1.
$\square$

The quantity $1/Q^2$ is the *Farey resolution* at level $Q$: the fractions of
denominator at most $Q$ form a discrete set whose consecutive gaps are exactly
$1/(qr) \ge 1/Q^2$. Certifiability of a record is therefore a statement about
where the recorded value sits in the Farey scaffold, and about nothing else.

### 3.2 The four-decimal certificate and its sharpness

**Theorem 3.4 (Four-decimal certificate).** Let $a/q$ and $b/r$ be rationals
with $0 < q, r \le 70$. If $|a/q - b/r| < 10^{-4}$ then $a/q = b/r$.

*Proof sketch.* $70^2 = 4900 \le 10^4$, so $10^{-4} \le 1/70^2$; apply
Corollary 3.3 with $Q = 70$. $\square$

**Theorem 3.5 (Sharpness).** $\left|\tfrac{1}{100} - \tfrac{1}{101}\right| =
\tfrac{1}{10100} < 10^{-4}$ while $\tfrac1{100} \ne \tfrac1{101}$. Hence no
four-decimal certificate can hold for denominators up to $101$.

The largest denominator bound that survives at precision $10^{-4}$ is $Q = 99$
(since $1/99^2 = 1.0203\ldots\times 10^{-4} > 10^{-4} \ge 1/100^2$); $70$ is the
conservative working bound used below, comfortably above every denominator that
occurs in the record and comfortably below the failure point.

**Corollary 3.6 (Certified keystones).** Suppose a re-run produces a rational
value $b/r$ with $0 < r \le 70$.

* If $|b/r - I_{\mathrm{pair}}(4)| < 10^{-4}$, then $b/r = I_{\mathrm{pair}}(4) = 5/4$.
* If $|b/r - I_{\mathrm{pair}}(8)| < 10^{-4}$, then $b/r = I_{\mathrm{pair}}(8) = 21/16$.
* If $|b/r - I_{\mathrm{pair}}(16)| < 10^{-4}$, then $b/r = I_{\mathrm{pair}}(16) = 85/64$.
* If $|b/r - H_T(4)| < 10^{-4}$, then $b/r = H_T(4) = 3/2$.

*Proof sketch.* Each recorded value is a fraction with denominator $4$, $16$,
$64$ or $2$, all at most $70$; apply Theorem 3.4. $\square$

Note what Corollary 3.6 does *not* assume: nothing about the algorithm, the
arithmetic precision, the seeds or the machine. The only hypotheses are that
both numbers are rationals of bounded denominator and that their difference is
small. In this stratum, reproduction is certified before the re-run happens; the
re-run only supplies the inequality.

---

## 4. From four rows to a law: the two-adic tower

### 4.1 The entropy law

**Lemma 4.1.** $\displaystyle\sum_{i<k} i\,2^i = (k-2)2^k + 2$ for all $k \ge 0$.

*Proof sketch.* Induction on $k$; the step is
$(k-2)2^k + 2 + k\,2^k = (k-1)2^{k+1} + 2$. $\square$

**Lemma 4.2.** $\displaystyle\sum_{d \mid 2^k} \varphi(d)\log_2\varphi(d) = (k-2)2^k + 2.$

*Proof sketch.* The divisors of $2^k$ are $2^0,\dots,2^k$. The term $d=1$
contributes $0$, and $\varphi(2^{i+1}) = 2^i$ gives
$\varphi(2^{i+1})\log_2\varphi(2^{i+1}) = i\,2^i$ for $0 \le i < k$. Sum with
Lemma 4.1. $\square$

**Theorem 4.3 (Two-adic entropy law).** For every $k \ge 0$,
$$H_T(2^k) \;=\; 2 - \frac{2}{2^k} \;=\; 2 - 2^{\,1-k},$$
and for $k \ge 1$ this is the fraction $(2^k-1)/2^{\,k-1}$.

*Proof sketch.* Apply Lemma 2.3 with $n = 2^k$: $\log_2 2^k = k$ and, by
Lemma 4.2, the correction term is $((k-2)2^k + 2)/2^k = k - 2 + 2^{1-k}$.
Subtracting gives $2 - 2^{1-k}$. $\square$

**Corollary 4.4 (Audit consistency).** The four recorded rows are exactly the
$k = 1,2,3,4$ instances:
$H_T(2) = 1$, $H_T(4) = 3/2$, $H_T(8) = 7/4$, $H_T(16) = 15/8$. The audit's
consistency check is thereby upgraded from a coincidence of digits to a
specialisation of a theorem.

**Proposition 4.5 (Monotonicity and the two-bit ceiling).** $H_T(2^k) <
H_T(2^{k+1})$ for every $k$; $H_T(2^k) < 2$ for every $k$; and
$H_T(2^k) \to 2$ as $k \to \infty$.

*Proof sketch.* Immediate from $H_T(2^k) = 2 - 2^{1-k}$: the subtracted term is
positive, halves at each step, and tends to $0$. $\square$

Interpretation: however large the cyclic $2$-group, the splitting type of a
uniform residue carries strictly fewer than two bits, and exactly two bits in
the limit. The channel has a hard information ceiling; no amount of extra group
structure buys a third bit.

### 4.2 Gap certification: structure beats denominator size

**Theorem 4.6 (Row gap).** If $j < k$ then
$$H_T(2^k) - H_T(2^j) \;\ge\; \frac{1}{2^{\,j}}.$$

*Proof sketch.* The difference is $2/2^j - 2/2^k$; since $k \ge j+1$ we have
$2/2^k \le 2/2^{j+1} = 1/2^j$, so the difference is at least
$2/2^j - 1/2^j = 1/2^j$. $\square$

**Corollary 4.7 (Isolation).** If $|H_T(2^j) - H_T(2^k)| < 2^{-k}$ then $j = k$.

**Corollary 4.8 (Four-decimal row identification).** If $k \le 13$ and
$|H_T(2^j) - H_T(2^k)| < 10^{-4}$, then $j = k$.

*Proof sketch.* $2^{13} = 8192 \le 10^4$, so $10^{-4} \le 2^{-k}$ for $k \le 13$;
apply Corollary 4.7. $\square$

Corollary 4.8 is a different kind of certificate from Theorem 3.4, and a
stronger one in its domain. Theorem 3.4 knows only that the values are rational
with small denominators. Corollary 4.8 knows that the value lies on a *sparse
ladder* and uses the ladder's minimum spacing; it identifies the row for
$k \le 13$, where the denominator $2^{k-1} = 4096$ is far outside the range
Theorem 3.4 can handle. Whenever the recorded family has a computable separation,
that separation is the better certificate.

### 4.3 The capacity law

The pair capacities of the two-adic tower obey their own closed form. Writing
$J_k = (4^k-1)/3$ for the $k$-th Jacobsthal number ($1, 5, 21, 85, 341, 1365,
5461,\dots$),
$$I_{\mathrm{pair}}(2^k) \;=\; \frac{4}{3}\left(1 - 4^{-k}\right) \;=\; \frac{J_k}{4^{\,k-1}},$$
so the recorded numerators $5, 21, 85$ at $k = 2,3,4$ are Jacobsthal numbers.
The values are established by evaluation for $1 \le k \le 4$ and confirmed by
exhaustive enumeration at $k = 5,6,7$, where the enumerated values
$341/256$, $1365/1024$, $5461/4096$ agree exactly with the formula. The
structural reason is a two-branch recursion: in $\mathbb{Z}/2^k$ the splitting
type is a function of the $2$-adic valuation alone, and the valuation of a sum
$x+y$ equals $\min(v(x),v(y))$ except on the diagonal $v(x) = v(y)$, which is
precisely the branching that generates the Jacobsthal recursion
$J_{k+1} = 4J_k + 1$. A complete proof of the capacity law for all $k$ is the
principal open problem left by this work (Section 11).

Each of these values is dyadic with denominator $4^{k-1}$; Theorem 3.4 certifies
them for $k \le 4$ (denominator $64 \le 70$), and a gap argument in the style of
Theorem 4.6 extends certification further.

---

## 5. The irrational stratum

### 5.1 Irrationality of $\log_2 3$

**Lemma 5.1 (Power comparison).** Let $p, q \in \mathbb{N}$ with $q > 0$. If
$2^p < 3^q$ then $p/q < \log_2 3$; if $3^q < 2^p$ then $\log_2 3 < p/q$.

*Proof sketch.* $\log_2$ is strictly increasing; $\log_2 2^p = p$ and
$\log_2 3^q = q\log_2 3$; divide by $q > 0$. $\square$

**Theorem 5.2.** $\log_2 3 \ne m/q$ for all $m, q \in \mathbb{N}$ with $q>0$;
consequently $\log_2 3$ is irrational.

*Proof sketch.* Suppose $\log_2 3 = m/q$. By Lemma 5.1 neither $2^m < 3^q$ nor
$3^q < 2^m$ can hold (either would contradict the equality), so $2^m = 3^q$. But
$3 \mid 3^q$ and $3 \nmid 2^m$, a contradiction. For the full irrationality
statement, a positive rational value $r$ can be written as a quotient of
naturals, since $\log_2 3 > 0$. $\square$

No transcendence theory is used: the obstruction is unique factorisation.

**Corollary 5.3.** $I_{\mathrm{pair}}(6) = \log_2 3 - 1/9$ is irrational, and
therefore $I_{\mathrm{pair}}(6) \ne a/q$ for every integer $a$ and natural $q$.

*Proof sketch.* Adding a rational to an irrational yields an irrational.
$\square$

**Consequence for auditing.** In this stratum, *no* recorded decimal — of any
length — is equal to the audited quantity. Agreement of digits is compatible
with the pipeline being deterministic and with the record being a correct
approximation, but it can never be evidence of exactness, because exactness is
impossible. Statements of the form "the re-run reproduced the value" must be
replaced by statements of the form "the re-run reproduced the derivation, and the
record encloses the value".

### 5.2 What the record does pin down

**Theorem 5.4 (Enclosure of $\log_2 3$).**
$$1.58496 \;<\; \log_2 3 \;<\; 1.58497 .$$

*Proof sketch.* The continued-fraction convergents $1054/665$ and $485/306$ of
$\log_2 3$ give, via Lemma 5.1, the bounds $1054/665 < \log_2 3 < 485/306$; each
is equivalent to a single integer inequality, namely $2^{1054} < 3^{665}$ and
$3^{306} < 2^{485}$, both verifiable by exact integer arithmetic. Finally
$1.58496 < 1054/665$ and $485/306 < 1.58497$. $\square$

**Corollary 5.5 (The record is valid).**
$\left|I_{\mathrm{pair}}(6) - 1.4738\right| < 10^{-4}$.

*Proof sketch.* Subtract $1/9$ from the enclosure of Theorem 5.4:
$1.4738513 < I_{\mathrm{pair}}(6) < 1.4738562$, and $1.4738$ is within $10^{-4}$
of that interval. $\square$

Thus the audit of the irrational stratum is meaningful but of a different logical
type: it certifies a *rigorous enclosure* of a quantity known in closed form,
not an equality of records.

---

## 6. The rationality dichotomy on constructible orders

Which recorded entropies fall in which stratum? For a classical family the
answer is complete.

**Lemma 6.1.** Let $n \ge 1$, $b > 0$ and $a \ge 0$ with $b\log_2 n = a$. Then
$n^b = 2^a$.

*Proof sketch.* Exponentiate: both sides are positive and have equal logarithms.
$\square$

**Lemma 6.2.** If $n \ge 1$, $b > 0$ and $n^b = 2^a$, then $n$ is a power of
two.

*Proof sketch.* Any prime $p \mid n$ divides $n^b = 2^a$, hence $p = 2$; a
positive integer with $2$ as its only prime factor is a power of two. $\square$

**Theorem 6.3 (Rationality of binary logarithms).** For $n \ge 1$, $\log_2 n$ is
rational if and only if $n$ is a power of two.

*Proof sketch.* ($\Rightarrow$) Write $\log_2 n = a/b$ in lowest terms with
$b>0$; note $\log_2 n \ge 0$, so $a \ge 0$. Lemmas 6.1 and 6.2 give $n = 2^k$.
($\Leftarrow$) $\log_2 2^k = k \in \mathbb{Q}$. $\square$

**Definition 6.4 (Constructible order).** Call $n \ge 1$ *constructible* if
$\varphi(d)$ is a power of two for every divisor $d \mid n$. By the
Gauss–Wantzel theorem these are exactly the $n$ for which the regular $n$-gon is
constructible with straightedge and compass, i.e. $n = 2^a p_1\cdots p_s$ with
distinct Fermat primes $p_i \in \{3,5,17,257,65537,\dots\}$.

**Lemma 6.5.** If $n$ is constructible then
$\sum_{d\mid n}\varphi(d)\log_2\varphi(d) \in \mathbb{N}$.

*Proof sketch.* Each $\varphi(d) = 2^{j_d}$ contributes $2^{j_d} j_d$, an
integer. $\square$

**Theorem 6.6 (Dichotomy for the type channel).** Let $n \ge 1$ be constructible.
Then
$$H_T(n) \in \mathbb{Q} \iff n \text{ is a power of two},$$
and in the power-of-two case $H_T(2^k) = 2-2^{1-k}$ is dyadic, hence certifiable
by a four-decimal record; in every other case $H_T(n)$ is irrational and no
record of any precision can certify it.

*Proof sketch.* By Lemma 2.3 and Lemma 6.5, $H_T(n) = \log_2 n - c$ with
$c \in \mathbb{Q}$. So $H_T(n)$ is rational iff $\log_2 n$ is, which by
Theorem 6.3 happens iff $n = 2^k$. Theorem 4.3 supplies the closed form in that
case. $\square$

**Examples 6.7.** $H_T(3) = \log_2 3 - \tfrac23 \approx 0.9182958$,
$H_T(5) = \log_2 5 - \tfrac85 \approx 0.7219281$,
$H_T(15) = \log_2 15 - \tfrac{34}{15} \approx 1.6402239$,
$H_T(17) = \log_2 17 - \tfrac{64}{17} \approx 0.3227570$: all irrational, all
non-certifiable. By contrast every $H_T(2^k)$ is dyadic and certifiable.

The boundary between the certifiable and non-certifiable entropies of
constructible orders is thus drawn by an ancient geometric condition, refined by
a single arithmetic test: *is $n$ a power of two?*

---

## 7. Reproducibility by construction: invariance and its converse

### 7.1 The only arbitrary choice

Setting up the channel requires identifying an abstract cyclic Galois group with
$\mathbb{Z}/n$, i.e. choosing a generator. Two choices differ by an automorphism
$x \mapsto u\cdot x$ with $u$ a unit modulo $n$. Nothing else in the pipeline is
arbitrary. If the record is invariant under this action it is *reproducible by
construction*: a re-implementation that happens to pick another generator is
forced to the same numbers, independently of determinism of code.

**Definition 7.1 (Readout, histogram, entropy).** A *readout* is a function
$t : \mathbb{Z}/n \to \mathbb{N}$. Its *histogram* is the list of occupation
numbers $\#\{x : t(x) = d\}$ over the distinct realised values $d$, and its
entropy $H(t)$ is the Shannon entropy of the resulting distribution.

**Proposition 7.2 (Relabelling invariance in general).** For any readout $t$ and
any permutation $e$ of $\mathbb{Z}/n$: the histogram of $t \circ e$ is a
permutation of the histogram of $t$; occupation numbers always sum to $n$; and
$H(t\circ e) = H(t)$ exactly.

*Proof sketch.* A permutation is a bijection of fibres, so it preserves fibre
cardinalities and merely reorders bins; entropy depends on the multiset of
occupation numbers only. $\square$

### 7.2 The unit action

**Theorem 7.3 (The type is a class function).** If $\gcd(u,n)=1$ then
$T(u\cdot a) = T(a)$ for every $a$.

*Proof sketch.* $\gcd(n, ua) = \gcd(n,a)$ when $u$ is a unit, and $T$ depends on
$a$ only through that $\gcd$. $\square$

**Corollary 7.4 (Generator independence of the record).** For every unit $u$:
the type histogram, the type entropy $H_T(n)$, and the unordered semiprime type
pair $K$ are all *literally unchanged* by the relabelling $x \mapsto u\cdot x$.
Moreover the conditional table computing $I_{\mathrm{pair}}$ has its rows
permuted by any relabelling of the norm classes, leaving the averaged
conditional entropy — hence $I_{\mathrm{pair}}(n)$ — unchanged.

Every headline number in the record is therefore an invariant of the field, not
an artefact of coordinates.

### 7.3 The converse: universality of the splitting type

Invariance alone would be a happy accident. The converse turns it into a
characterisation.

**Theorem 7.5 (Orbits are $\gcd$ classes).** Let $n > 0$ and
$a,b \in \mathbb{Z}/n$ with $\gcd(n,a) = \gcd(n,b)$. Then there is a unit $u$
modulo $n$ with $u\cdot a \equiv b \pmod n$.

*Proof sketch.* Let $g = \gcd(n,a) = \gcd(n,b)$ and write $n = gm$, $a = ga_1$,
$b = gb_1$. Cancelling $g$ from the $\gcd$ identities shows $a_1$ and $b_1$ are
coprime to $m$, hence units of $\mathbb{Z}/m$. The unit $w = b_1a_1^{-1}$ of
$\mathbb{Z}/m$ lifts to a unit $u$ of $\mathbb{Z}/n$ along the surjection
$(\mathbb{Z}/n)^\times \twoheadrightarrow (\mathbb{Z}/m)^\times$ (valid since
$m \mid n$). Then $ua_1 \equiv b_1 \pmod m$, and multiplying the congruence by
$g$ gives $ua \equiv b \pmod{gm}$, i.e. modulo $n$. $\square$

**Lemma 7.6.** For $n>0$, $T(x) = T(y)$ if and only if $\gcd(n,x)=\gcd(n,y)$.

*Proof sketch.* $T = n/\gcd(n,\cdot)$ and $d \mapsto n/d$ is an involution on
the divisors of $n$. $\square$

Hence the orbits of the unit action are exactly the fibres of $T$.

**Theorem 7.7 (Invariance $\iff$ factorisation).** A readout
$t:\mathbb{Z}/n \to \mathbb{N}$ satisfies $t(u\cdot x) = t(x)$ for every unit $u$
and every $x$ **iff** $t$ is constant on the fibres of $T$, i.e. iff
$t = f\circ T$ for some $f : \mathbb{N}\to\mathbb{N}$.

*Proof sketch.* ($\Leftarrow$) Theorem 7.3. ($\Rightarrow$) If $T(x)=T(y)$ then
by Lemma 7.6 and Theorem 7.5 some unit $u$ carries $x$ to $y$, so
$t(x) = t(u\cdot x) = t(y)$; define $f$ on realised types by choosing a
representative fibre-wise (and arbitrarily elsewhere). $\square$

**Corollary 7.8 (Universality).** The splitting type is invariant, and every
invariant readout factors through it. Consequently every invariant readout has
the same histogram and entropy as the induced function of the type, and $T$ is —
up to relabelling of its values — the **finest reproducible observable** of a
single residue. Anything strictly finer than $T$ distinguishes elements within a
$\gcd$ class and is therefore an artefact of the coordinate choice.

This is the strongest sense in which the record "reproduces by construction":
there is no other answer available to a correct re-implementation.

---

## 8. Algorithms

Four algorithms implement the results; all are elementary but their cost
profiles differ sharply.

**A. Farey certificate.** *Input:* recorded $a/q$, re-run $b/r$, tolerance
$\varepsilon$. *Output:* CERTIFIED / INCONCLUSIVE. Test $\varepsilon \le 1/(qr)$
(exact integer comparison $\varepsilon\, qr \le 1$), then test
$|ar - bq| < qr\varepsilon$ in exact integer arithmetic. Cost $O(1)$ big-integer
operations. Soundness is Theorem 3.1; incompleteness is unavoidable by
Theorem 3.5.

**B. Channel evaluation by enumeration.** *Input:* $n$. *Output:* $H_T(n)$ and
$I_{\mathrm{pair}}(n)$. Compute $T(a)$ for all $a$ ($O(n\log n)$ with Euclid),
accumulate the type histogram, then loop over all $(x,y)$ accumulating the joint
table of $(K,N)$. Cost $O(n^2)$ time, $O(n\cdot\#\text{keys})$ memory; feasible
to $n \approx 2^{13}$. The $O(n^2)$ loop can be replaced by a convolution over
$\gcd$ classes, giving $O(d(n)^2 n)$ where $d(n)$ is the number of divisors.

**C. Closed-form evaluation.** *Input:* $k$. *Output:* exact rationals
$H_T(2^k) = (2^k-1)/2^{k-1}$ and $I_{\mathrm{pair}}(2^k) = J_k/4^{k-1}$. Cost
$O(k)$ bit operations — an exponential speed-up over enumeration, and it returns
*exact* fractions, which is what the Farey certificate consumes.

**D. Stratum classifier.** *Input:* $n$. *Output:* RATIONAL-CERTIFIABLE,
IRRATIONAL-NONCERTIFIABLE, or UNDECIDED-BY-THIS-TEST. Factor $n$; if $n$ is a
power of two return RATIONAL-CERTIFIABLE (Theorem 4.3); else if every divisor
has power-of-two totient, return IRRATIONAL-NONCERTIFIABLE (Theorem 6.6); else
UNDECIDED. Cost is dominated by factorisation plus $O(d(n))$ totient
evaluations.

**E. Enclosure certificate for the irrational stratum.** *Input:* target
precision $\varepsilon$. *Output:* a pair of rationals bracketing $\log_2 3$
within $\varepsilon$, each justified by one integer inequality. Generate
continued-fraction convergents $p/q$ of $\log_2 3$ and accept $p/q$ as a lower
(resp. upper) bound when $2^p < 3^q$ (resp. $3^q < 2^p$) verifies. The witnesses
used here are $2^{1054} < 3^{665}$ and $3^{306} < 2^{485}$; verifying them costs
a few big-integer multiplications.

---

## 9. Numerical demonstration

Exhaustive enumeration of the channel confirms every closed form.

| $k$ | $n=2^k$ | $H_T$ enumerated | $2-2^{1-k}$ | $I_{\mathrm{pair}}$ enumerated | $\tfrac43(1-4^{-k})$ | $J_k$ |
|---|---|---|---|---|---|---|
| 1 | 2 | 1.0000000000 | 1.0000000000 | 1.0000000000 | 1.0000000000 | 1 |
| 2 | 4 | 1.5000000000 | 1.5000000000 | 1.2500000000 | 1.2500000000 | 5 |
| 3 | 8 | 1.7500000000 | 1.7500000000 | 1.3125000000 | 1.3125000000 | 21 |
| 4 | 16 | 1.8750000000 | 1.8750000000 | 1.3281250000 | 1.3281250000 | 85 |
| 5 | 32 | 1.9375000000 | 1.9375000000 | 1.3320312500 | 1.3320312500 | 341 |
| 6 | 64 | 1.9687500000 | 1.9687500000 | 1.3330078125 | 1.3330078125 | 1365 |
| 7 | 128 | 1.9843750000 | 1.9843750000 | 1.3332519531 | 1.3332519531 | 5461 |

The irrational stratum:
$I_{\mathrm{pair}}(6)$ enumerates to $1.4738513896$, while
$\log_2 3 - 1/9 = 1.4738513896\ldots$; the enclosure of Theorem 5.4 gives
$1.47385129 < I_{\mathrm{pair}}(6) < 1.47385621$ and the stored record $1.4738$
differs from the true value by $5.14\times10^{-5} < 10^{-4}$.

The dichotomy, sampled on constructible orders:

| $n$ | constructible | power of two | $H_T(n)$ | stratum |
|---|---|---|---|---|
| 2 | yes | yes | 1.0000000000 | rational |
| 3 | yes | no | 0.9182958341 | irrational |
| 4 | yes | yes | 1.5000000000 | rational |
| 5 | yes | no | 0.7219280949 | irrational |
| 15 | yes | no | 1.6402239289 | irrational |
| 16 | yes | yes | 1.8750000000 | rational |
| 17 | yes | no | 0.3227569589 | irrational |
| 51 | yes | no | 1.2410527930 | irrational |

Invariance, sampled at $n = 15$: the eight units $1,2,4,7,8,11,13,14$ each
relabel $\mathbb{Z}/15$, and all eight reproduce the type histogram
$\{1\!:\!1,\ 3\!:\!2,\ 5\!:\!4,\ 15\!:\!8\}$ and the entropy
$1.6402239289$ exactly. The orbits of the unit action,
$\{0\},\{5,10\},\{3,6,9,12\},\{1,2,4,7,8,11,13,14\}$, coincide with the $\gcd$
classes and with the fibres of $T$, as Theorem 7.5 requires. Testing candidate
readouts at $n=12$ confirms Theorem 7.7 on every case examined: $T$ itself,
$\gcd(n,\cdot)$ and the indicator of $T = n$ are invariant and factor through
$T$; the identity readout and $a \mapsto a \bmod 5$ are neither.

---

## 10. Discussion

### 10.1 A taxonomy of audit verdicts

The results yield three logically distinct verdicts, and conflating them is the
error the practice invites.

1. **Certified equality.** The recorded quantity is rational with denominator
   below the Farey threshold for the stated precision. Then digit agreement is a
   *proof* of bit-for-bit equality. The proof does not depend on the pipeline and
   would hold for a re-run by different software on different hardware.
2. **Validated enclosure.** The recorded quantity is a closed-form irrational.
   Then no record equals it. Digit agreement establishes that the record is a
   correct approximation at the stated precision — provided an independent
   enclosure like Theorem 5.4 is available — and that the pipeline is
   deterministic. It never establishes exactness.
3. **Structural reproduction.** The recorded quantity is invariant under all
   arbitrary choices in its own definition. Then it reproduces even under
   re-implementation, because no other value is available. This is the only
   verdict that survives a complete rewrite of the software.

### 10.2 Design consequences

*Record small-denominator rationals when you can.* Certifiability is a property
you choose when you choose the observable. A quantity reported as a dyadic
rational is auditable by theorem; the same quantity reported as a floating-point
approximation of an irrational is not.

*Prefer separation to precision.* Corollary 4.8 certifies rows of the two-adic
ladder with denominators up to $4096$ because the family is sparse; the generic
bound stops at $70$. When the recorded family has a computable minimum spacing,
publish that spacing — it is a stronger certificate than extra digits.

*Report closed forms, not decimals, in the irrational stratum.* "$\log_2 3 -
1/9$" is reproducible in a way "$1.4738$" can never be, and it comes with an
error bound whenever one is needed.

*Audit invariance, not just determinism.* Fixed seeds reproduce your choices
along with your results. Invariance under the choices is the stronger property,
and Theorem 7.7 shows it can be characterised exactly rather than hoped for.

### 10.3 Scope and limitations

Theorem 6.6 assumes constructibility, which is used only to make the totient
correction term rational; the general statement (Section 11, Direction 2) needs
$\mathbb{Q}$-linear independence of $\{\log p\}$. The capacity law for
$I_{\mathrm{pair}}(2^k)$ is proved by evaluation for $k \le 4$ and confirmed by
enumeration for $k \le 7$; the general proof is open. The Farey certificate is
sound but incomplete: it never wrongly certifies, but records with large
denominators are simply not certifiable at four decimals, as Theorem 3.5 shows.

---

## 11. Future directions

**From "the numbers reproduce" to "the numbers are theorems".** This work
replaced the *audit* reading of reproducibility (re-run the script, compare
digits) by a *structural* one: a recorded number is reproducible when it is
either (i) a bounded-denominator rational, in which case a rounded record
provably determines it, or (ii) a closed-form irrational, in which case only the
derivation reproduces it — and the record is invariant under the arbitrary
choices in the pipeline.

Four structural patterns emerged.

1. **Certifiability is a denominator statement.** Four-decimal agreement
   certifies equality exactly when the two rationals have denominators below the
   Farey threshold; the resolution is $1/Q^2$, and it is attained.
2. **The dyadic family is a law, not a table.** The four recorded rows of the
   2-adic tower are the $k \le 4$ instances of $H_T(2^k) = 2 - 2^{1-k}$.
3. **Constructibility controls the stratum.** On orders whose divisor lattice
   has only 2-power totients — the Gauss–Wantzel constructible orders — $H_T$ is
   $\log_2 n$ minus a rational, hence rational iff $n$ is a power of two.
4. **Invariance is not just a property of the record, it characterises it.** The
   orbits of the unit action on $\mathbb{Z}/n$ are exactly the $\gcd$ classes, so
   the splitting type is the *universal* generator-invariant readout: every
   reproducible observable of a single residue factors through it.

**Direction 1 — Jacobsthal capacity law for the 2-adic pair channel.** We have
$I_{\mathrm{pair}}(2^k) = \tfrac43(1-4^{-k})$ for $1 \le k \le 4$ by evaluation,
and enumeration confirms it at $k = 5,6,7$, where the numerators are the
Jacobsthal numbers $(4^k-1)/3$. The key insight is that in $\mathbb{Z}/2^k$ the
splitting type is a function of the 2-adic valuation alone, and the valuation of
a sum $x+y$ is determined by $\min(v(x),v(y))$ except on the diagonal
$v(x) = v(y)$, so the conditional type-pair distribution given the norm class is
a two-branch recursion in $k$ — exactly the recursion that produces the
Jacobsthal numbers. The closed form for $H_T(2^k)$ supplies the marginal half of
the computation; only the conditional half is missing.

**Direction 2 — Rationality dichotomy for every cyclic type entropy.** We proved
that on constructible orders $H_T(n)$ is rational iff $n$ is a power of two. The
general conjecture drops the constructibility hypothesis. The key insight is
that
$$H_T(n) = \log_2 n - \frac1n\sum_{d\mid n}\varphi(d)\log_2\varphi(d)$$
is a $\mathbb{Q}$-linear combination of logarithms of integers, so its
rationality is governed by $\mathbb{Q}$-linear independence of
$\{\log p : p \text{ prime}\}$ — a consequence of unique factorisation rather
than of transcendence theory. The constructible case shows the mechanism in a
setting where the correction term is visibly rational.

**Direction 3 — Optimal certificates from separation data.** Corollary 4.8
outperforms the generic Farey bound by using the ladder gap. Formulate the
general principle: for a recorded family $\{v_i\}$ with known minimum separation
$\delta$, a record at precision $\varepsilon < \delta/2$ identifies the member
uniquely, whatever the denominators. Determining $\delta$ for the pair-capacity
family, and for mixed-order families $\{H_T(n) : n \le N\}$, would give
certificates far beyond what denominator bounds allow.

**Direction 4 — Invariance beyond a single residue.** Universality of the
splitting type is proved for readouts of one residue. The semiprime channel
reads out *pairs*, where the relevant group action is the diagonal unit action
on $\mathbb{Z}/n \times \mathbb{Z}/n$. Characterising the invariants of that
action — presumably functions of the pair $(\gcd(n,x),\gcd(n,y))$ together with
the norm class — would extend "reproducible by construction" from the marginal
record to the full conditional table.

---

## 12. Conclusion

A reproducibility audit that compares decimals is doing arithmetic, not
software engineering, and the arithmetic has a precise reach. Distinct rationals
of denominator at most $70$ cannot agree to four decimals, so within that stratum
a matching record is a theorem of exact equality; past denominator $100$ the
guarantee fails, as $1/100$ and $1/101$ witness. For the cyclic splitting-type
channel this cleanly partitions the record: the two-power entropies
$H_T(2^k) = 2-2^{1-k}$ and capacities $I_{\mathrm{pair}}(2^k) = \tfrac43(1-4^{-k})$
are dyadic and certifiable — indeed the four audited entropy rows are just the
first four instances of a law with a two-bit ceiling and a $2^{-k}$ row gap —
whereas $I_{\mathrm{pair}}(6) = \log_2 3 - 1/9$ and, more generally, $H_T(n)$ for
every constructible non-two-power $n$, are irrational and beyond the reach of any
decimal record. There the audit certifies an enclosure, not a value. Finally,
the whole record is invariant under the single arbitrary choice the pipeline
makes — the generator of the cyclic group — and invariance characterises exactly
the observables that factor through the splitting type. The strongest form of
reproducibility available is therefore not "the same code gives the same digits"
but "no correct implementation could have produced anything else".
