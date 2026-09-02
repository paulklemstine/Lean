# Separability, Floors and Ceilings for the Capped Trailing-Zero Dial

### An exact tie-attenuation theory for rank-correlation diagnostics on binary key spaces

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

We give an exact theory of the rank-correlation capacity of the *capped
trailing-zero statistic* $T_u(x) = \min(v_2(x), u)$ on $b$-bit key spaces,
where $v_2$ denotes the $2$-adic valuation. Rank correlation against a tied
predictor is bounded above by a *tie ceiling* determined entirely by the
predictor's tie profile; we compute this ceiling in closed form and derive its
structural consequences.

Our main result is a **separation law**: for $1 \le u \le b$,
$$\rho^2(b,u) = \frac{6}{7}\bigl(1-8^{-u}\bigr)\Bigl(1+\frac{1}{4^b-1}\Bigr),$$
so that the two experimental knobs — resolution $u$ and bit length $b$ — enter
as independent multiplicative factors. Consequently the entire
$\text{bitlen} \times \text{cap}$ ceiling table is **rank one**:
$\rho^2(b,u)\rho^2(b',u') = \rho^2(b,u')\rho^2(b',u)$ for all admissible
indices. There is no interaction term, which is the exact mathematical content
of the empirical verdict "no cell-specific cliff". We further show the ceiling
is strictly increasing in $u$, strictly decreasing in $b$, and that changing
$b$ moves the ceiling by less than $2\cdot 4^{-b}$ uniformly in $u$.

We then prove a **distribution-free floor law**: if no value of a tied
statistic carries more than a fraction $a < 1$ of the sample, its ceiling
satisfies $\rho^2 > 1 - a^2$; in particular a *balanced* statistic (no value
holding a majority) has $\rho^2 > 3/4$, i.e. $\rho > 0.866$. This bound is
independent of the arithmetic, the bit length, the cap and the draw law. It is
sharp in the sense that the two-block profile $[15,1]$, with modal mass
$93.75\%$, has $\rho^2 = 3/17$ and $\rho \approx 0.420$; together the two
results localise the failure of a $0.53$ floor to modal mass in
$[0.848, 0.8955]$, the upper end witnessed by the two-block profile
$[8955,1045]$.

Finally we prove a **coarsening law** (merging tie classes cannot raise the
ceiling; lowering the cap by one is exactly such a merge) and a **gap law**:
the tie-resolution advantage of $T_u$ ($u \ge 2$) over bare parity is at least
$3/32$ in $\rho^2$ but strictly below $0.07$ in $\rho$ at every cell, with
supremum $\sqrt{6/7}-\sqrt{3/4} = 0.059795\ldots$. An empirically recorded
advantage of $0.10$–$0.15$ therefore cannot be a granularity artefact: it
forces the bare-parity reading to sit at least $0.03$ below its own ceiling.

A second development treats *balanced* (fixed Hamming weight) key laws, whose
tie profile is binomial rather than dyadic. Via the identity
$b\binom{b-1}{w-1} = w\binom{b}{w}$ — the modal class is exactly a $w/b$
fraction — key balance $2w \le b$ transfers to tie balance, the same floor
applies, and at $w = b/2$ the ceiling is pinned from both sides. Changing the
draw law from uniform to balanced moves the ceiling by less than $0.07$ in
$\rho$.

**Keywords:** rank correlation, tie attenuation, $2$-adic valuation, trailing
zeros, key space statistics, rank-one matrices, distribution-free bounds,
binomial tie profiles.

---

## 1. Introduction

### 1.1 The diagnostic setting

A recurrent pattern in the empirical study of arithmetic algorithms is the
*dial*: a coarse integer-valued summary of an input, correlated against a
continuous response (a running time, an acceptance rate, a success frequency).
The dial we study is the trailing-zero count of a key,
$$v_2(x) = \max\{k : 2^k \mid x\},$$
capped at a design parameter $u$:
$$T_u(x) = \min(v_2(x), u), \qquad x \in \{0,1,\dots,2^b-1\}.$$
Capping is universal in practice — one truncates the statistic at a few levels
because deeper valuations are exponentially rare — and it introduces the second
knob. The two design knobs are therefore the *bit length* $b$ of the key space
and the *cap* $u$ (the resolution of the dial). Setting $u = 1$ degenerates the
dial to bare parity, which we call the **bare count**.

The empirical observation under analysis is a robustness claim recorded across
a two-dimensional sweep of $(b,u)$: at every cell of the grid the Spearman rank
correlation between $T_u$ and the response was at least $0.53$, and $T_u$
outperformed the bare count by $0.10$–$0.15$. No cell exhibited a breakdown.

The purpose of this paper is to replace that finite sweep with exact
mathematics. Two questions organise the work.

1. **Capacity.** How high *can* the correlation read at a given cell? A tied
   predictor cannot achieve $|\rho| = 1$ even against a perfectly aligned
   response; ties impose a hard ceiling. If the ceiling itself had a
   cell-specific structure, the absence of a cliff would be an accident of the
   tested grid.
2. **Attribution.** Which of the recorded effects are *explained* by capacity,
   and which exceed what capacity can manufacture? The second kind are the
   scientifically informative ones.

### 1.2 Summary of contributions

* **§3, Separation law.** Closed form $\rho^2(b,u) = \frac67 (1-8^{-u})(1+\frac{1}{4^b-1})$
  for $1 \le u \le b$; the knobs do not interact.
* **§3.3, Rank-one law.** The ceiling table has all $2\times 2$ minors zero.
* **§3.4, Monotonicity and insensitivity.** Strict monotonicity in each knob;
  bit-length movement bounded by $2\cdot4^{-b}$ uniformly in $u$.
* **§4, Floor laws.** Mass-fraction floor $\rho^2 > 1-a^2$; balanced floor
  $\rho^2 > 3/4$; cliff-edge localisation to $a \in [0.848, 0.8955]$; sharpness
  via the $[15,1]$ counterexample.
* **§5, Coarsening and gap laws.** Merging tie classes lowers the ceiling;
  quantitative gap bounds; the slack-forcing corollary for the recorded
  advantage.
* **§6, Balanced key laws.** Binomial tie profile, hockey-stick normalisation,
  the $w/b$ modal fraction law, the two-sided pin at $w=b/2$, and the
  law-change capacity bound.

---

## 2. Preliminaries: tie profiles and the tie ceiling

### 2.1 Tie profiles

**Definition 2.1 (tie profile).** Let $S$ be an integer-valued statistic on a
finite sample of size $n$. The *tie profile* of $S$ is the multiset
$L = [m_1, \dots, m_r]$ of cardinalities of the level sets of $S$, so that
$\sum_i m_i = n$. We write $L.\mathrm{sum} = n$.

We treat tie profiles as finite lists of positive integers; all quantities below
depend only on the multiset.

**Definition 2.2 (Kendall tie correction).** For a tie profile $L$,
$$\mathcal{T}(L) \;=\; \frac{1}{12}\sum_{i}\bigl(m_i^3 - m_i\bigr).$$

This is the classical tie-correction term of rank statistics: it is exactly the
amount by which the variance of the midranks of $S$ falls short of the variance
of a full untied ranking.

**Definition 2.3 (tie ceiling).** For a profile $L$ with $n = L.\mathrm{sum} \ge 2$,
$$\rho^2(L) \;=\; 1 - \frac{12\,\mathcal{T}(L)}{n^3-n} \;=\; 1 - \frac{\sum_i (m_i^3-m_i)}{n^3-n},
\qquad \rho(L) = \sqrt{\rho^2(L)}.$$

**Proposition 2.4 (interpretation).** $\rho(L)$ is the maximum Spearman rank
correlation attainable between a statistic with tie profile $L$ and any
untied response.

*Proof sketch.* Spearman's $\rho$ is the Pearson correlation of midranks. If
$R$ denotes an untied ranking of the sample and $\bar R$ the midranks of the
tied statistic, then $\mathrm{Var}(R) = (n^3-n)/12$, while replacing each tied
block of size $m$ by its common midrank removes exactly $(m^3-m)/12$ of that
variance, giving $\mathrm{Var}(\bar R) = (n^3 - n - \sum_i(m_i^3-m_i))/12$.
Since $\bar R$ is a measurable function of the tied statistic and Pearson
correlation is bounded by the ratio of standard deviations when one variable is
a coarsening of the other, the maximum correlation is
$\sqrt{\mathrm{Var}(\bar R)/\mathrm{Var}(R)} = \rho(L)$, attained when the
response is monotone in the statistic and untied within blocks. $\square$

Two elementary consequences used throughout: $\rho^2(L) \in [0,1]$; and
$\rho^2([n]) = 0$ — a statistic with a single value carries no rank
information.

**Example 2.5.** $\rho^2([15,1]) = 1 - \frac{(3375-15)+(1-1)}{4096-16} = 1 - \frac{3360}{4080} = \frac{3}{17} \approx 0.1765$,
so $\rho \approx 0.4201$.

### 2.2 The two-knob family

**Definition 2.6 (capped profile).** For $0 \le u \le b$ let
$$C(u,b) = \bigl[\,2^{b-1},\, 2^{b-2},\, \dots,\, 2^{b-u},\, 2^{b-u}\,\bigr],$$
a list of $u+1$ entries when $u \ge 1$, and $C(0,b) = [2^b]$.

**Proposition 2.7 (arithmetic bridge).** For $u \le b$, $C(u,b)$ is exactly the
tie profile of $T_u$ on $\{0,1,\dots,2^b-1\}$: for $0 \le k < u$ the set
$\{x < 2^b : v_2(x) = k\}$ has $2^{b-1-k}$ elements, and the top class
$\{x < 2^b : 2^u \mid x\}$ has $2^{b-u}$ elements.

*Proof sketch.* The multiples of $2^k$ below $2^b$ number $2^{b-k}$; subtracting
the multiples of $2^{k+1}$ gives $2^{b-k}-2^{b-k-1} = 2^{b-1-k}$ elements of
exact valuation $k$. The top class is the multiples of $2^u$, of which there are
$2^{b-u}$ (this includes $x=0$, whose valuation is conventionally infinite; the
convention is immaterial, as $0$ lies in the top class under either reading).
$\square$

**Proposition 2.8 (normalisation).** For $u \le b$, $\sum C(u,b) = 2^b$.

*Proof sketch.* Induction on $u$: $C(u+1,b+1) = 2^b :: C(u,b)$ and
$2^b + 2^b = 2^{b+1}$. $\square$

At the maximal cap $u = b$ the profile is the full dyadic one
$[2^{b-1}, 2^{b-2}, \dots, 2, 1, 1]$, recovering the uncapped trailing-zero
statistic on the key space.

---

## 3. The separation law and the rank-one ceiling table

### 3.1 The exact tie correction

**Theorem 3.1 (Kendall correction of the capped profile).** For $u, r \ge 0$
and $b = u+r$,
$$12\,\mathcal{T}\bigl(C(u,b)\bigr) \;=\; \frac{8^{b} + 6\cdot 8^{\,b-u}}{7} \;-\; 2^{b}.$$

*Proof sketch.* Induction on $u$. For $u=0$ the profile is $[2^b]$ and the
correction is $8^b - 2^b$, matching. For the step, $C(u+1,b+1)$ prepends a
block of size $2^{b}$, contributing $8^{b} - 2^{b}$; the geometric bookkeeping
$8^{b+1} = 8\cdot 8^b$, $2^{b+1} = 2\cdot 2^b$ closes the recursion. $\square$

Equivalently, writing $n = 2^b$: $\sum_i m_i^3 = \frac{8^b(1-8^{-u})}{7} + 8^{b-u}$,
a finite geometric sum with ratio $1/8$ plus the cube of the top block.

### 3.2 The separation law

**Theorem 3.2 (Separation law).** For $1 \le b$ and $u \le b$,
$$\boxed{\;\rho^2(b,u) \;:=\; \rho^2\bigl(C(u,b)\bigr) \;=\; \frac{6}{7}\Bigl(1-\Bigl(\tfrac18\Bigr)^{u}\Bigr)\Bigl(1+\frac{1}{4^{b}-1}\Bigr).\;}$$

*Proof sketch.* Put $n = 2^b$, so $n^3 = 8^b$ and $n^2 = 4^b$. By Theorem 3.1,
$$\rho^2 = 1 - \frac{\frac{8^b+6\cdot8^{b-u}}{7}-2^b}{8^b - 2^b}
= \frac{\frac{6}{7}\bigl(8^b - 8^{b-u}\bigr)}{8^b-2^b}
= \frac{6}{7}\cdot\frac{1-8^{-u}}{1-4^{-b}},$$
and $\frac{1}{1-4^{-b}} = \frac{4^b}{4^b-1} = 1 + \frac{1}{4^b-1}$. $\square$

We name the two factors
$$\mathrm{cap}(u) = \tfrac67\bigl(1-8^{-u}\bigr), \qquad
\mathrm{bit}(b) = 1 + \tfrac{1}{4^b-1},$$
so $\rho^2(b,u) = \mathrm{cap}(u)\,\mathrm{bit}(b)$, with $0 < \mathrm{cap}(u) \le 6/7$
for $u \ge 1$ and $\mathrm{bit}(b) > 1$ for $b \ge 1$.

**Corollary 3.3 (consistency at full cap).** At $u=b$ the formula reduces to the
uncapped dyadic ceiling $\frac67(1-8^{-b})(1+\frac{1}{4^b-1})$, which tends to
$6/7$ from above as $b \to \infty$; hence $\rho \to \sqrt{6/7} = 0.925820\ldots$.

### 3.3 No interaction: the table is rank one

**Theorem 3.4 (Rank-one law).** For all $b, b' \ge 1$ and $u \le b$, $u' \le b'$,
$$\rho^2(b,u)\,\rho^2(b',u') \;=\; \rho^2(b,u')\,\rho^2(b',u),$$
whenever all four cells are admissible.

*Proof sketch.* Both sides equal
$\mathrm{cap}(u)\mathrm{cap}(u')\mathrm{bit}(b)\mathrm{bit}(b')$ by Theorem 3.2
and commutativity. $\square$

The content is structural rather than numerical: a matrix all of whose
$2\times2$ minors vanish has rank one, i.e. is an outer product of a row vector
and a column vector. Every row of the ceiling table is a scalar multiple of
every other row, and likewise for columns. Whatever explains a low reading at a
given cell, it cannot be a cell-specific capacity deficit — there is no
cell-specific term to appeal to. This is the precise sense in which the
instrument admits *no cliff*.

### 3.4 Monotonicity and bit-length insensitivity

**Theorem 3.5 (strict monotonicity in the cap).** If $u < u' \le b$ and $b\ge1$
then $\rho^2(b,u) < \rho^2(b,u')$.

*Proof sketch.* $\mathrm{cap}$ is strictly increasing since $8^{-u}$ is strictly
decreasing, and $\mathrm{bit}(b) > 0$. $\square$

**Theorem 3.6 (strict antitonicity in the bit length).** If $1 \le u$, $b < b'$
and $u \le b$ then $\rho^2(b',u) < \rho^2(b,u)$.

*Proof sketch.* $\mathrm{bit}$ is strictly decreasing in $b$ and
$\mathrm{cap}(u) > 0$ for $u \ge 1$. $\square$

The direction is worth a remark: enlarging the key space *lowers* the ceiling,
because the top tie class grows relative to nothing — more precisely, the finite
correction $1/(4^b-1)$ to the asymptotic value shrinks. The effect is
minuscule:

**Theorem 3.7 (uniform bit-length insensitivity).** For $1 \le b \le b'$ and
$u \le b$,
$$0 \;\le\; \rho^2(b,u) - \rho^2(b',u) \;<\; 2\cdot 4^{-b},$$
uniformly in $u$.

*Proof sketch.* The difference equals
$\mathrm{cap}(u)\bigl(\mathrm{bit}(b)-\mathrm{bit}(b')\bigr) \le \frac67\bigl(\frac{1}{4^b-1}-\frac{1}{4^{b'}-1}\bigr) < \frac{6}{7}\cdot\frac{1}{4^b-1} < 2\cdot 4^{-b}$
for $b\ge1$. $\square$

Numerically the ceilings are

| $b \backslash u$ | $1$ | $2$ | $3$ | $4$ | $6$ | $8$ |
|---|---|---|---|---|---|---|
| $8$  | 0.866032 | 0.918566 | 0.924923 | 0.925714 | 0.925825 | 0.925827 |
| $16$ | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| $32$ | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| $64$ | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |

(values of $\rho(b,u)$, computed in exact rational arithmetic and rounded). The
bit-length axis is invisible past $b = 16$ at six decimal places; the cap axis
saturates by $u = 4$.

---

## 4. Floor laws: why no cell can break down

The results of §3 are specific to the dyadic profile. The floor below is not
specific to anything.

### 4.1 The mass-fraction floor

**Theorem 4.1 (Mass-fraction floor law).** Let $L$ be a tie profile with
$n = L.\mathrm{sum} \ge 2$, and let $0 \le a < 1$ be such that every block
satisfies $m_i \le a\,n$. Then
$$\rho^2(L) \;>\; 1 - a^2.$$

*Proof sketch.* Since $0 \le m_i \le an$ for all $i$, we have
$m_i^3 \le (an)^2 m_i$, so $\sum_i m_i^3 \le a^2n^2 \sum_i m_i = a^2 n^3$.
Therefore
$$\frac{\sum_i(m_i^3-m_i)}{n^3-n} \le \frac{a^2n^3-n}{n^3-n} < a^2,$$
the last inequality because $a^2 n^3 - n < a^2(n^3-n)$ is equivalent to
$a^2 n < n$, true as $a^2<1$ and $n>0$. Subtracting from $1$ gives the claim.
$\square$

Note what the proof does *not* use: the number of blocks, their arithmetic
origin, the underlying probability law, or the value set of the statistic. The
only input is the modal mass.

### 4.2 The balanced floor

**Definition 4.2 (balanced statistic).** A tie profile $L$ is *balanced* if
$2m_i \le L.\mathrm{sum}$ for every block, i.e. no value carries a strict
majority of the sample.

**Theorem 4.3 (Distribution-free floor law).** If $L$ is balanced with
$L.\mathrm{sum} \ge 2$, then
$$\rho^2(L) > \tfrac34, \qquad\text{hence}\qquad \rho(L) > 0.866 \;>\; 0.53 .$$

*Proof sketch.* Apply Theorem 4.1 with $a = 1/2$. $\square$

**Proposition 4.4 (every cell is balanced).** For $1 \le u \le b$ the profile
$C(u,b)$ is balanced: its largest block is $2^{b-1} = \tfrac12 \sum C(u,b)$.

*Proof sketch.* Blocks are $2^{b-1} \ge 2^{b-2} \ge \dots \ge 2^{b-u}$ and the
duplicated top block $2^{b-u}$, all at most $2^{b-1}$, while the sum is $2^b$
by Proposition 2.8. $\square$

**Corollary 4.5 (universal cell floor).** For every $1 \le u \le b$,
$\rho(b,u) > 0.866 > 0.53$. Every cell of the recorded envelope clears the
recorded floor with margin at least $0.33$, and a reading below $0.53$ can
never be attributed to tie granularity.

This is the strongest form of the "no cliff" statement: it does not depend on
the dyadic structure at all, so it survives *any* change of key law, statistic,
or arithmetic that preserves balance.

### 4.3 Where the cliff actually is

**Theorem 4.6 (Cliff edge).** If every block of $L$ satisfies
$m_i \le a\,n$ with $0 \le a \le 0.847$ and $n\ge2$, then $\rho(L) > 0.53$.

*Proof sketch.* Theorem 4.1 gives $\rho^2 > 1 - 0.847^2 = 0.282591$, while
$0.53^2 = 0.2809$. $\square$

**Theorem 4.7 (Sharpness).** The two-block profile $[15,1]$, whose modal class
carries $15/16 = 93.75\%$ of the sample, has
$$\rho^2 = \tfrac{3}{17} \approx 0.1765, \qquad \rho \approx 0.4201 < 0.53 .$$
Hence the balance hypothesis of Theorem 4.3 cannot be dropped.

*Proof sketch.* Direct evaluation as in Example 2.5. $\square$

Together, Theorems 4.6 and 4.7 localise the failure of the $0.53$ floor to
modal mass $a \in [0.848, 0.938]$; Proposition 4.8 below tightens the upper
end to $0.8955$. The tested envelope has modal mass exactly
$1/2$ everywhere, i.e. it sits at the extreme safe end of the admissible range.

**Proposition 4.8 (sharpening the bracket).** For the two-block family
$[\lfloor an \rfloor, n - \lfloor an \rfloor]$ one has, exactly,
$$\rho^2 = 1 - \frac{(an)^3+((1-a)n)^3-n}{n^3-n} \;\xrightarrow[n\to\infty]{}\; 3a(1-a),$$
which crosses $0.53^2 = 0.2809$ at $a = \tfrac12\bigl(1+\sqrt{1-4\cdot0.2809/3}\bigr) = 0.89543\ldots$
The explicit profile $[8955, 1045]$ has $\rho^2 = 0.280739\ldots < 0.2809$.
Hence the critical modal mass for the $0.53$ floor lies in $[0.848, 0.8955]$.

*Proof sketch.* Direct substitution in Definition 2.3; the limit drops the
linear terms, leaving $1-a^3-(1-a)^3 = 3a(1-a)$. The explicit profile is an
exact rational evaluation. $\square$

**Remark 4.9 (the exact constant).** Determining the critical mass exactly
requires knowing that two-block profiles are extremal at fixed modal mass — for
fixed $a$ and $n$, splitting the non-modal mass into more classes only *raises*
the ceiling, by the coarsening law of §5, so two blocks is indeed the worst
case and the constant $0.89543\ldots$ should be exact in the limit. Making this
uniform in $n$ is the remaining step.

---

## 5. Coarsening, and how much resolution can be worth

### 5.1 The coarsening law

**Lemma 5.1 (additivity).** $\mathcal{T}(X \mathbin{+\!\!+} Y) = \mathcal{T}(X)+\mathcal{T}(Y)$
for concatenation of profiles.

**Lemma 5.2 (merging increases the correction).** For $m, m' \ge 0$,
$$(m^3-m) + (m'^3-m') \;\le\; \bigl((m+m')^3 - (m+m')\bigr),$$
with strict inequality unless $mm' = 0$.

*Proof sketch.* Expand: the difference is $3mm'(m+m') \ge 0$. $\square$

**Theorem 5.3 (Coarsening law).** Let $L = A \mathbin{+\!\!+} [m, m'] \mathbin{+\!\!+} B$
and let $L'$ be obtained by merging the two displayed classes, i.e.
$L' = A \mathbin{+\!\!+} [m+m'] \mathbin{+\!\!+} B$. Then $L$ and $L'$ have the same sum
and
$$\rho^2(L') \;\le\; \rho^2(L).$$
Merging tie classes never raises the ceiling.

*Proof sketch.* Same sum by Lemma 5.1's counterpart for sums; larger correction
by Lemma 5.2; the ceiling is a decreasing affine function of the correction at
fixed $n$. $\square$

**Theorem 5.4 (lowering the cap is a merge).** For $u, r \ge 0$ and
$b = u+1+r$, $C(u,b)$ is obtained from $C(u+1,b)$ by merging its last two
classes (both of size $2^{r}$). Consequently
$$\rho^2\bigl(C(u,b)\bigr) \le \rho^2\bigl(C(u+1,b)\bigr).$$

*Proof sketch.* $C(u+1,b)$ ends in $[2^{r}, 2^{r}]$ — the keys of exact
valuation $u$ and the keys of valuation $\ge u+1$ — whose merge is the single
class $[2^{r+1}]$ of keys of valuation $\ge u$, which is the tail of $C(u,b)$.
$\square$

Theorem 5.4 re-derives Theorem 3.5 without the closed form, and explains *why*
the finer dial dominates: not because of any arithmetic accident, but because
coarsening a partition is a cubic-loss operation.

### 5.2 The gap law

Write $G_{\rho^2}(b,u) = \rho^2(b,u) - \rho^2(b,1)$ and
$G_\rho(b,u) = \rho(b,u)-\rho(b,1)$ for the advantage of the capped dial over
the bare count.

**Theorem 5.5 (Gap law, lower half).** For $2 \le u \le b$,
$$G_{\rho^2}(b,u) \;\ge\; \tfrac{3}{32} = 0.09375 .$$

*Proof sketch.* $\mathrm{cap}(u)-\mathrm{cap}(1) = \frac67(8^{-1}-8^{-u}) \ge \frac67\bigl(\frac18-\frac1{64}\bigr) = \frac67\cdot\frac{7}{64} = \frac{3}{32}$,
and $\mathrm{bit}(b) \ge 1$. $\square$

**Theorem 5.6 (Gap law, upper half).** For $1 \le u \le b$,
$$G_{\rho}(b,u) \;<\; 0.07 ,$$
with supremum over the whole envelope equal to
$\sqrt{6/7}-\sqrt{3/4} = 0.925820\ldots - 0.866025\ldots = 0.059795\ldots$

*Proof sketch.* Both ceilings lie in $[3/4, 6/7 + \varepsilon_b]$ with
$\varepsilon_b = \frac{6}{7}\cdot\frac{1}{4^b-1}$ small. Setting
$X = \rho^2(b,u)$ and $Y = \rho^2(b,1) \ge 3/4$, it suffices to check
$X < (\sqrt Y + 0.07)^2 = Y + 0.14\sqrt Y + 0.0049$; since $\sqrt Y \ge 0.866$
this holds as soon as $X - Y \le 6/7 + \varepsilon_b - 3/4 < 0.1213$, which is
implied by $X \le \frac67\mathrm{bit}(b)$ and $Y \ge \frac34$. The degenerate
cell $b = u = 1$ has gap $0$. The stated supremum is the limiting difference
$\sqrt{6/7}-\sqrt{3/4}$. $\square$

The mismatch between Theorems 5.5 and 5.6 is not a contradiction but a
consequence of working near the top of the correlation range, where the square
root compresses differences by a factor $\approx 1/(2\rho) \approx 0.56$:
$0.09375$ in $\rho^2$ is worth about $0.052$ in $\rho$.

**Theorem 5.7 (Recorded advantage forces slack).** Suppose at some cell
$1 \le u \le b$ the capped dial reads $r_T \le \rho(b,u)$ and the bare count
reads $r_C$ with $r_T - r_C \ge 0.10$. Then
$$\rho(b,1) - r_C \;\ge\; 0.03 .$$

*Proof sketch.* $\rho(b,1) - r_C = (\rho(b,1)-\rho(b,u)) + (\rho(b,u)-r_T) + (r_T-r_C) > -0.07 + 0 + 0.10 = 0.03$
using Theorem 5.6 and $r_T \le \rho(b,u)$. $\square$

**Interpretation.** The recorded advantage band $[0.10, 0.15]$ lies strictly
above the tie-resolution capacity of the family, at every cell. So the observed
superiority of $T_u$ over parity is *not* a granularity artefact of having more
distinct values. Arithmetic converts the experimental claim into a structural
obligation on the other statistic: bare parity must be leaving at least $0.03$
of its own available correlation on the table, i.e. it must be failing to track
response variation that the deeper valuations $v_2 \ge 2$ do track.

---

## 6. Balanced key laws: fixed Hamming weight

The uniform key law is not the only one of interest; *balanced* keys — drawn
uniformly among $b$-bit strings of fixed Hamming weight $w$ — are standard in
several cryptographic settings. This changes the tie profile from dyadic to
binomial, and none of §3's closed forms survive. The floor laws of §4, being
distribution-free, do.

### 6.1 The binomial tie profile

**Definition 6.1.** For $1 \le w \le b$ set
$$W(b,w) = \Bigl[\;\binom{b-1-k}{\,w-1\,}\;\Bigr]_{k=0}^{\,b-w}.$$

**Theorem 6.2 (combinatorial bridge).** $W(b,w)$ is the tie profile of the
trailing-zero statistic on weight-$w$ $b$-bit keys: modelling such a key as a
$w$-element subset $S \subseteq \{0,\dots,b-1\}$ of set-bit positions, the
number of $S$ with $\min S = k$ is $\binom{b-1-k}{w-1}$.

*Proof sketch.* Fixing the minimum at $k$ leaves $w-1$ further positions to
choose freely from the $b-1-k$ positions strictly above $k$. $\square$

**Theorem 6.3 (hockey-stick normalisation).** For $1 \le w \le b$,
$$\sum_{k=0}^{b-w}\binom{b-1-k}{w-1} = \binom{b}{w}.$$

*Proof sketch.* Reindex $j = b-w-k$ to obtain $\sum_{j=0}^{b-w}\binom{w-1+j}{w-1}$
and apply the hockey-stick identity. $\square$

### 6.2 The modal fraction law and balance transfer

**Theorem 6.4 (Modal fraction law).** For $1 \le w \le b$,
$$b\binom{b-1}{w-1} = w \binom{b}{w}.$$
Equivalently: the modal tie class of the trailing-zero statistic on weight-$w$
keys is the class of odd keys ($k=0$), and it carries exactly the fraction
$w/b$ of them.

*Proof sketch.* The absorption identity $\binom{b}{w} = \frac{b}{w}\binom{b-1}{w-1}$.
Modality follows since $\binom{b-1-k}{w-1}$ is decreasing in $k$. $\square$

**Theorem 6.5 (Balance transfer).** If $1 \le w$ and $2w \le b$, then $W(b,w)$
is balanced: every block is at most half of $\binom{b}{w}$.

*Proof sketch.* The largest block is $\binom{b-1}{w-1}$, and by Theorem 6.4
$b\cdot 2\binom{b-1}{w-1} = 2w\binom{b}{w} \le b\binom{b}{w}$; divide by $b>0$.
$\square$

**Corollary 6.6 (Balanced floor).** For $1 \le w$ with $2w \le b$,
$$\rho^2\bigl(W(b,w)\bigr) > \tfrac34, \qquad \rho\bigl(W(b,w)\bigr) > 0.866 > 0.53 .$$

Thus every balanced-key cell clears the recorded floor with the same margin as
every uniform-key cell. Key balance in the Hamming sense implies tie balance in
the statistical sense; that is the whole mechanism.

### 6.3 The two-sided pin at $w = b/2$

**Theorem 6.7 (exact half at the balanced weight).** For $v \ge 1$,
$$2\binom{2v-1}{v-1} = \binom{2v}{v}.$$
So at $w = b/2$ the modal class is *exactly* half the sample.

*Proof sketch.* Theorem 6.4 with $b = 2v$, $w = v$. $\square$

**Theorem 6.8 (Two-sided pin).** For $v \ge 1$, writing
$n = \binom{2v}{v} = \sum W(2v,v)$,
$$\tfrac34 \;<\; \rho^2\bigl(W(2v,v)\bigr) \;\le\; \tfrac78 + \frac{7}{8(n^2-1)} .$$

*Proof sketch.* The lower bound is Corollary 6.6. For the upper bound, a single
block of size $m \ge n/2$ contributes at least $n^3/8 - n/2$ to
$\sum_i (m_i^3-m_i)$, giving
$\rho^2 \le 1 - \frac{n^3/8-n/2}{n^3-n} = \frac{7}{8} + \frac{3}{8(n^2-1)}$,
which the stated (slightly weaker) bound dominates. $\square$

The balanced ceiling is therefore trapped in $(0.75, 0.875+o(1))$ in $\rho^2$,
i.e. in roughly $(0.866, 0.936)$ in $\rho$ — the same band as the dyadic
ceilings.

### 6.4 Law-change capacity

**Theorem 6.9 (Law-change capacity).** For $v \ge 2$, i.e. bit length
$b = 2v \ge 4$,
$$\bigl|\,\rho\bigl(W(2v,v)\bigr) - \rho\bigl(C(2v,2v)\bigr)\,\bigr| \;<\; 0.07 .$$

*Proof sketch.* By Theorem 6.8 the balanced ceiling lies in $(3/4, 15/16]$ in
$\rho^2$ (using $n \ge 4$); by Theorem 3.2 the dyadic ceiling lies in
$(6/7, 6/7 + 1/256]$. Both intervals lie inside $[3/4, 0.9375]$ in $\rho^2$,
i.e. inside $[0.866, 0.9682]$ in $\rho$; the crude bound on the spread of that
interval combined with the actual endpoints yields a difference below $0.07$.
$\square$

**Interpretation.** Switching from uniform keys to balanced keys cannot move
the dial's capacity by more than $0.07$ in $\rho$. Hence a recorded
balanced-versus-uniform difference exceeding $0.07$ is a statement about the
response, not about tie structure — the same attribution logic as Theorem 5.7,
applied along a third axis.

---

## 7. Algorithms

All quantities above are exactly computable in rational arithmetic; the
following primitives suffice.

**Algorithm A (exact tie ceiling from a profile).** Input a profile
$[m_1,\dots,m_r]$; compute $n = \sum m_i$ and $S = \sum (m_i^3-m_i)$; return
$1 - S/(n^3-n)$ as an exact rational. Cost $O(r)$ big-integer operations. For
the dyadic family $r = u+1 \le b+1$, so a full $b \times u$ table costs
$O(b^2)$ per bit length in the naive form, or $O(1)$ per cell using the closed
form of Theorem 3.2.

**Algorithm B (capped profile construction / census verification).** Build
$C(u,b) = [2^{b-1},\dots,2^{b-u},2^{b-u}]$ directly, or, for verification,
enumerate $x < 2^b$ and bucket by $\min(v_2(x),u)$. The direct build is
$O(u)$; the census is $O(2^b)$ and is used only as an audit for small $b$.

**Algorithm C (rank-one certification).** Given a numeric ceiling table
$M \in \mathbb{Q}^{p\times q}$, verify rank one by checking
$M_{ij}M_{kl} = M_{il}M_{kj}$ for all $i<k$, $j<l$: $O(p^2q^2)$ exact
comparisons, or $O(pq)$ by checking each row against the first.

**Algorithm D (modal-mass floor certificate).** Given any tie profile, compute
$a = \max_i m_i / n$ and return the certified lower bound $\sqrt{1-a^2}$ for
the ceiling, together with the verdict "clears $0.53$" whenever
$a \le 0.847$. Cost $O(r)$; requires no knowledge of the generating law.

**Algorithm E (attribution audit).** Given measured correlations $r_T$ (capped
dial) and $r_C$ (bare count) at a cell $(b,u)$: compute the capacity gap
$\rho(b,u)-\rho(b,1)$; if $r_T - r_C$ exceeds it, report the forced slack
$\rho(b,1)-r_C \ge (r_T-r_C) - (\rho(b,u)-\rho(b,1))$ in the bare-count
reading. Cost $O(1)$.

---

## 8. Discussion

### 8.1 What "robustness" should mean

The empirical verdict was a conjunction of negatives: no cliff, no breakdown,
no convention artefact. Negatives over a finite grid are weak evidence; the
same grid with two more cells might have found one. The mathematics replaces
each negative with a positive structural statement.

* *No cliff* becomes **separability**: the capacity function factorises over
  the knobs (Theorem 3.2), hence the capacity table is rank one (Theorem 3.4),
  hence there is no cell-specific term in which a cliff could reside. This
  extends to every untested cell for free.
* *No breakdown* becomes the **distribution-free floor** (Theorem 4.3): the
  guarantee does not come from the dyadic law but from balance, a property that
  is stable under changes of law (Corollary 6.6), of arithmetic, and of
  statistic.
* *No convention artefact* becomes the **arithmetic bridge** (Proposition 2.7):
  the profile used in the analysis is literally the valuation census, and the
  only convention in sight — the valuation of $0$ — places $0$ in the top class
  either way.

### 8.2 Capacity as an auditing tool

The most useful by-product is negative in a productive way. Because the
capacity is known exactly, any recorded effect can be compared against what
capacity could possibly manufacture. Here the recorded floor is far below
capacity (so it says nothing about the instrument), while the recorded
advantage of the capped dial over parity is far *above* what tie resolution can
supply — and therefore must be substantive. The exact statement, Theorem 5.7,
is a constraint that a future measurement must satisfy: the bare-count reading
has to be at least $0.03$ below its own ceiling of $\approx 0.866$.

This inverts the usual role of a null model. Instead of asking whether an
effect could be noise, one asks whether it could be *instrument granularity* —
and when it could not, the residual becomes a target for the next experiment.

### 8.3 Scope and limitations

Three limitations should be stated plainly.

1. The ceiling is an upper bound on the *attainable* correlation, achieved only
   when the response is monotone in the statistic and untied within blocks.
   Nothing here predicts an actual reading; the theory constrains, it does not
   forecast.
2. The separation law is a property of geometric block structure. Profiles that
   are not geometric — the binomial ones of §6, for instance — need not
   factorise, and indeed §6 obtains only two-sided bounds, not a closed form.
3. Theorem 5.6's constant $0.07$ is a convenient rational bound; the true
   supremum is $\sqrt{6/7}-\sqrt{3/4} = 0.0597954\ldots$, and the sharper
   constant would strengthen Theorem 5.7's slack from $0.03$ to $0.0402\ldots$

### 8.4 Future work

Three directions follow directly.

**Rank-one as the signature of statistic composition.** The factorisation arose
because the two knobs act on disjoint parts of the profile: the cap truncates
the tail, the bit length rescales the whole space. We conjecture that whenever
a family of statistics is obtained by composing an independent *resolution*
operation with an independent *scaling* operation, the capacity table is rank
one; and conversely that a rank-two table certifies genuine interaction between
knobs. What is missing is the abstract characterisation of which families of
profiles have this property.

**The exact cliff constant.** Theorems 4.6 and 4.7 bracket the critical modal
mass into $[0.848, 0.8955]$, the upper end witnessed by the two-block profile
$[8955,1045]$. Along two-block profiles the ceiling tends to $3a(1-a)$, which
crosses $0.53^2$ at $a^\star = 0.89543\ldots$; we conjecture that two-block
profiles are extremal at fixed modal mass, uniformly in $n$, so that $a^\star$
is the exact critical constant. The remaining step is that uniformity.

**Slack accounting.** Theorem 5.7 says the bare count must lose at least $0.03$
of non-tie information. We conjecture this missing $0.03$ is precisely the
response's dependence on the event $v_2 \ge 2$, isolable by measuring the dial
with the response conditioned on parity. The theory now supplies the numerical
target such a measurement must hit.

---

## 9. Conclusion

For the capped trailing-zero dial on binary key spaces we have computed the
rank-correlation capacity exactly and found it to factorise:
$\rho^2(b,u) = \frac67(1-8^{-u})(1+\frac{1}{4^b-1})$. The consequences are that
the capacity table over the two design knobs is rank one — the exact meaning of
"no cell-specific cliff" — that the capacity varies by less than $2 \cdot 4^{-b}$
along the bit-length axis, and that it is monotone in each knob for a
structural reason (coarsening a partition costs a cubic term).

Underneath the closed form sits a stronger, distribution-free statement: any
statistic whose modal class holds no majority has capacity above $0.866$, a
bound that ignores arithmetic, bit length, cap and draw law alike, and that
degrades gracefully to $\sqrt{1-a^2}$ at modal mass $a$, failing only in the
narrow window $a \in [0.848,0.8955]$. Balanced (fixed-weight) key laws inherit
the bound through the modal fraction identity $b\binom{b-1}{w-1} = w\binom{b}{w}$.

Finally, exact capacity turns measurement into audit. The recorded advantage of
the capped dial over bare parity, $0.10$–$0.15$, exceeds the at most $0.0598$
that tie resolution can supply; the excess is therefore real, and it forces the
parity reading to sit at least $0.03$ below its own ceiling. That is a
prediction, not a rationalisation — and it is the right kind of thing for a
robustness study to leave behind.
