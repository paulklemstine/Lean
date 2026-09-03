# Gradual, Not a Cliff: A Calculus of Notches for Two-Dial Rank-Correlation Grids, with Application to Capped Trailing-Zero Statistics on Binary Keys

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

A *dial* is a tunable statistic whose informativeness one probes by sweeping its parameters and recording a rank correlation against a target. When such a sweep shows a correlation falling from $0.79$ to $0.53$ across a $4 \times 3$ grid of two parameters — a bit length $b$ and a resolution cap $u$ — three competing explanations must be separated: (i) the decline is *gradual*, spread over many small steps; (ii) the decline is a *threshold* or *resolution* effect, an artifact of the statistic's own ceiling collapsing at some cell; (iii) the decline is a *convention artifact*, produced by an arbitrary bookkeeping choice about a single boundary input.

This paper develops the mathematics that separates these three, and settles all three for the *capped trailing-zero dial* $T_u(x) = \min(v_2(x), u)$ on $b$-bit keys, where $v_2$ is the $2$-adic valuation.

We first build a general *gradualness calculus* for grids $F : \mathbb{N} \times \mathbb{N} \to \mathbb{Q}$: a staircase decomposition writing any corner-to-corner decline as an exact sum of $m+n$ single-notch declines; a **spreading law** stating that a decline of size $R$ under a per-notch bound $\varepsilon$ must be carried by at least $R/\varepsilon$ strictly active notches, together with a matching sharpness example showing the bound is attained; a rank-one (separability) theory in which the two dials never interact; a **transfer theorem** showing that a grid uniformly $\delta$-close to an $\varepsilon$-gradual grid is $(\varepsilon + 2\delta)$-gradual, so approximate models already exclude cliffs; and geometric *no-sharp-edge* laws for descent toward a practical floor.

We then compute the exact tie ceiling of $T_u$. Writing $\rho^2(b,u)$ for the largest squared Spearman coefficient attainable by $T_u$ on $b$-bit keys, we prove the product law
$$\rho^2(b,u) \;=\; \underbrace{\tfrac{6}{7}\bigl(1 - 8^{-u}\bigr)}_{\text{cap factor}} \cdot \underbrace{\Bigl(1 + \tfrac{1}{4^{b}-1}\Bigr)}_{\text{bit factor}}, \qquad 1 \le u \le b,$$
which is *separable*, hence rank one: no cell of the grid can behave differently from what its row and column dictate. Its notches are exactly $\rho^2(b,u+1) - \rho^2(b,u) = \frac34 \, 8^{-u} \bigl(1 + \frac1{4^b-1}\bigr)$, geometric with ratio $1/8$ and always *positive*, and over the recorded envelope ($b \ge 32$, $u \ge 8$) the entire ceiling surface varies by less than $10^{-5}$. Since the recorded correlation *falls* by $0.26$ while the ceiling *rises*, the decline cannot be a resolution effect at all: it is pure attenuation, and we show the attenuation factor must drop by more than $0.4$ between the recorded corners.

Finally we quantify conventions. Moving one key between two tie classes changes the Kendall tie correction by exactly $3\bigl((m')^2 + m'\bigr) - 3\bigl(m^2 + m\bigr)$, and for a *balanced* profile (no block exceeding half the sample) it moves the ceiling by less than $4/N$; on the recorded envelope, by less than $10^{-9}$ — eight orders of magnitude below the observed decline. A **transition-width law** ($2\eta \le m\,d$) converts an earlier report of a "practical floor near bit length $54$" into a transition of provably positive width: at least two notches under the recorded per-notch bound, and at least three under a geometric retention of $7/8$.

**Keywords:** rank correlation, Spearman ceiling, tie correction, $2$-adic valuation, separable grids, monotone staircase, gradualness, threshold effects.

---

## 1. Introduction

### 1.1 The empirical situation

Consider a family of statistics indexed by two knobs. The first knob is the *bit length* $b$: the width of the integers being examined. The second is a *cap* $u$: a deliberate coarsening that refuses to distinguish resolutions finer than $u$. For each pair $(b,u)$ one records a single number, a Spearman rank correlation $\mathrm{sp}(T)$ between the statistic and some target of interest.

A comprehensive sweep over a $4 \times 3$ grid of $(b,u)$ pairs produces correlations ranging from $0.79$ at the most favourable corner to $0.53$ at the least favourable one, and the values decline *monotonically in both variables*: increasing either knob never increases the correlation. The total range is $R = 0.26$, and no adjacent pair of cells differs by more than $d = 0.09$.

The question is what those numbers mean. Three readings are on the table, and they have sharply different consequences:

1. **Gradual decline.** The statistic loses signal steadily as the knobs turn. Nothing special happens anywhere; a practitioner can trade parameters smoothly.
2. **Threshold / resolution effect.** At some particular cell the *statistic itself* runs out of room — its maximum attainable correlation collapses — and the observed drop merely reflects that ceiling. This would mean the decline says nothing about the underlying coupling and everything about the encoding.
3. **Convention artifact.** The statistic requires an arbitrary decision about one boundary input (the value $x = 0$, whose $2$-adic valuation is conventionally either $\infty$ or $b$). Perhaps the whole pattern is an artifact of that decision.

Reading (2) and reading (3) are the ones that would invalidate the experiment. Both are *falsifiable by exact computation*, because both concern the statistic's own combinatorics rather than the unknown data-generating process. That is the strategy of this paper: we compute the ceiling exactly, we compute the convention sensitivity exactly, and we show both are negligible at the recorded scale — leaving reading (1) as the only survivor, and quantifying it.

### 1.2 A methodological constraint

An important discipline governs everything below. We do **not** invent the ten interior cells of the recorded grid. Only four pieces of recorded information are ever used:

- the top corner value $0.79$;
- the bottom corner value $0.53$;
- monotonicity in both knobs (equivalently, non-negativity of every notch);
- the per-notch bound $0.09$.

Every theorem about the recorded data is therefore a statement about *any* dataset with that reported summary, not about fabricated numbers. Correspondingly, the results are robust: they cannot be broken by re-running the experiment with different seeds, only by a summary that violates one of these four inputs.

### 1.3 Contributions

- **A gradualness calculus** (§3) for arbitrary two-dial grids: staircase telescoping, the spreading law and its sharpness, rank-one structure, a perturbation transfer theorem, and geometric no-sharp-edge laws.
- **An exact product law** (§4) for the tie ceiling of the capped trailing-zero dial, and the resulting *flatness theorem*: the ceiling varies by less than $10^{-5}$ over the entire recorded envelope.
- **The attenuation verdict** (§5): since the ceiling rises with the cap while the correlation falls, the observed decline is entirely a coupling effect, and the attenuation factor must drop by more than $0.4$.
- **Convention stability** (§6): an exact formula for the effect of a one-key reassignment, a universal bound $4/N$ for balanced profiles, and $10^{-9}$ on the envelope.
- **A transition-width law** (§7) converting a reported "practical floor" into a transition of provably positive width.

---

## 2. Setting and basic objects

### 2.1 The capped trailing-zero dial

Fix a bit length $b \ge 1$ and let the key space be
$$\mathcal{K}_b = \{0, 1, \dots, 2^b - 1\}, \qquad N = |\mathcal{K}_b| = 2^b .$$

For $x \ne 0$ let $v_2(x)$ be the $2$-adic valuation of $x$: the number of trailing zero bits. For a *cap* $u$ with $1 \le u \le b$ the **capped trailing-zero dial** is
$$T_u(x) \;=\; \min\bigl(v_2(x),\, u\bigr) \;\in\; \{0, 1, \dots, u\},$$
with the boundary key $x = 0$ assigned to the top class (any of the usual conventions places it there; §6 shows the choice is immaterial).

The dial is deliberately coarse. It is a *rank* statistic with heavy ties: exactly half the keys have $T_u = 0$, a quarter have $T_u = 1$, and so on.

**Definition 2.1 (Tie profile).** The **tie profile** of $T_u$ on $\mathcal{K}_b$ is the multiset of tie-class sizes
$$\mathcal{B}(u,b) \;=\; \bigl(2^{b-1},\, 2^{b-2},\, \dots,\, 2^{b-u},\, 2^{b-u}\bigr),$$
where the $j$-th entry ($0 \le j \le u-1$) counts the keys with exactly $j$ trailing zeros, namely $2^{b-1-j}$ of them, and the final entry counts the keys with $v_2 \ge u$, namely $2^{b-u}$. The entries sum to $N = 2^b$.

Note the profile is **balanced**: every block satisfies $2m \le N$, the largest being exactly $N/2$. This innocuous fact is the engine of §6.

### 2.2 The tie ceiling

A rank statistic with ties cannot achieve correlation $1$ with anything, because ranks within a tie block are indistinguishable. The relevant classical quantity is the Spearman tie correction.

**Definition 2.2 (Tie correction and ceiling).** For a profile $L = (m_1, \dots, m_k)$ of block sizes with $N = \sum_i m_i \ge 2$, put
$$\mathrm{tc}(L) \;=\; \frac{1}{12}\sum_{i=1}^{k}\bigl(m_i^3 - m_i\bigr),
\qquad
\rho^2(L) \;=\; 1 \;-\; \frac{12\,\mathrm{tc}(L)}{N^3 - N} \;=\; 1 - \frac{\sum_i (m_i^3 - m_i)}{N^3-N} .$$
We call $\rho^2(L)$ the **tie ceiling** of the profile: it is the largest squared Spearman coefficient a variable with that tie structure can attain against a perfectly ordered target.

Two elementary but constantly-used facts: $\mathrm{tc}$ is *additive over concatenation of profiles*, $\mathrm{tc}(L_1 \frown L_2) = \mathrm{tc}(L_1) + \mathrm{tc}(L_2)$, and $\mathrm{tc}$ of a single block of size $m$ is $(m^3 - m)/12$. Additivity is what makes local edits of the profile (§6) exactly computable.

We write $\rho^2(b,u) := \rho^2\bigl(\mathcal{B}(u,b)\bigr)$.

### 2.3 Attenuation

The recorded number is an observed correlation $s = \mathrm{sp}(T)$, not the ceiling. We relate them in the standard multiplicative way.

**Definition 2.3 (Attenuation factor).** The **attenuation factor** of a cell is the number $a \in [0,1]$ with
$$s^2 \;=\; a \cdot \rho^2(b,u).$$
Thus $\rho^2$ measures how much room the encoding leaves, and $a$ measures how much of that room the underlying coupling actually fills. The entire question "is the decline a resolution effect?" is the question "does the decline live in $\rho^2$ or in $a$?"

---

## 3. A gradualness calculus for two-dial grids

Throughout this section $F : \mathbb{N} \times \mathbb{N} \to \mathbb{Q}$ is an arbitrary grid; think of $F(b,u)$ as the value recorded at row $b$, column $u$. Nothing here is specific to correlations.

### 3.1 Notches and the staircase decomposition

**Definition 3.1 (Notches).** The **row notch** and **column notch** of $F$ are
$$\mathrm{row}(F; b,u) = F(b,u) - F(b+1,u), \qquad \mathrm{col}(F; b,u) = F(b,u) - F(b,u+1).$$
A notch is *active* when it is strictly positive. A grid is **$\varepsilon$-gradual** on a region when every notch there is at most $\varepsilon$.

**Definition 3.2 (Staircase).** For a base corner $(b_0, u_0)$ and offsets $m, n$, the **staircase list** is
$$\mathrm{St}(F; b_0,u_0,m,n) = \bigl(\mathrm{row}(F; b_0+i,\,u_0)\bigr)_{i<m} \frown \bigl(\mathrm{col}(F; b_0+m,\,u_0+j)\bigr)_{j<n},$$
i.e. advance the row dial $m$ times along column $u_0$, then advance the column dial $n$ times along row $b_0+m$. It has exactly $m + n$ entries.

**Theorem 3.3 (Staircase decomposition).** For every grid $F$ and all $b_0,u_0,m,n$,
$$\sum \mathrm{St}(F; b_0,u_0,m,n) \;=\; F(b_0,u_0) - F(b_0+m,\, u_0+n).$$

*Proof sketch.* Two telescoping inductions. For the row run, induction on $m$: the sum over $i < m+1$ is the sum over $i<m$ plus $F(b_0+m,u_0) - F(b_0+m+1,u_0)$, which by the inductive hypothesis equals $F(b_0,u_0) - F(b_0+m+1,u_0)$. The column run is identical with the roles of the dials exchanged. Concatenating the two runs joins $(b_0,u_0)$ to $(b_0+m,u_0)$ to $(b_0+m,u_0+n)$. $\square$

The decomposition is *exact*, requires no monotonicity or regularity, and turns any statement about corner-to-corner change into a statement about a finite list of local differences. Every result below is an inequality applied to that list.

### 3.2 The spreading law

**Lemma 3.4 (Bounded entries need many positive ones).** Let $L$ be a finite list of rationals with $0 \le x \le \varepsilon$ for every $x \in L$. Then
$$\sum L \;\le\; \varepsilon \cdot \#\{x \in L : x > 0\}.$$

*Proof sketch.* Induction on $L$. A zero entry adds nothing to either side; a positive entry adds at most $\varepsilon$ to the left and exactly $\varepsilon$ to the right. Note the count is of *strictly positive* entries: vanishing notches must not be credited. $\square$

**Theorem 3.5 (Spreading law).** Suppose every notch of the staircase joining $(b_0,u_0)$ to $(b_0+m, u_0+n)$ is non-negative and at most $\varepsilon > 0$. Then the number of *active* notches satisfies
$$\#\{\text{active notches}\} \;\ge\; \frac{F(b_0,u_0) - F(b_0+m,\,u_0+n)}{\varepsilon}.$$

*Proof sketch.* Apply Lemma 3.4 to the staircase list and rewrite its sum by Theorem 3.3. $\square$

This is the formal meaning of "gradual, not a cliff": a large decline under a small per-notch bound *forces* many participating notches. Two corollaries make the contrapositive explicit.

**Corollary 3.6 (No notch carries the whole decline).** Write $R = F(b_0,u_0) - F(b_0+m,u_0+n)$. If every notch is at most $\varepsilon$ and $\varepsilon < R$, then every notch is strictly less than $R$. In particular no single step accounts for the observed change.

**Theorem 3.7 (Fraction form).** If $R > 0$ and no notch exceeds the fraction $c$ of $R$, then $1 \le c \cdot \#\{\text{active notches}\}$, i.e. the decline is spread over at least $1/c$ notches.

*Proof sketch.* Apply Lemma 3.4 with $\varepsilon = cR$, substitute the telescoped sum $R$, and cancel the positive factor $R$. $\square$

### 3.3 Sharpness: the bound is attained, and cliffs exist

Neither direction of the spreading law is vacuous.

**Definition 3.8 (Perfectly gradual grid).** For rationals $\mathrm{top}, \delta$ put $\Lambda_{\mathrm{top},\delta}(b,u) = \mathrm{top} - (b+u)\delta$. Every notch of $\Lambda$, of either kind, equals exactly $\delta$.

**Theorem 3.9 (Sharpness of the spreading law).** For every target decline $R > 0$ and every staircase shape with $m + n \ge 1$, the grid $\Lambda_{\mathrm{top},\delta}$ with $\delta = R/(m+n)$ satisfies: its corner-to-corner decline is exactly $R$; all of its $m+n$ notches equal $\delta$; and its number of active notches is exactly $m+n = R/\delta$. Hence the bound of Theorem 3.5 is attained.

*Proof sketch.* All notches are $\delta$ by direct computation, so the staircase sum is $(m+n)\delta = R$; since $\delta > 0$ every notch is active and the count is the list length $m+n$. $\square$

**Definition 3.10 (A cliff grid).** Let $\mathrm{Cl}(b,u) = 0.79$ if $b + u = 0$ and $0.53$ otherwise.

**Proposition 3.11.** $\mathrm{Cl}$ is monotone non-increasing in both dials, its corner-to-corner decline over a $4\times 3$ staircase is exactly $0.26$, and its very first row notch equals $0.26$ — a single notch carrying the entire decline.

So "no cliff" is a genuine restriction on data, not a theorem about all monotone grids. Any verdict of gradualness must therefore be earned from the recorded per-notch bound, and Proposition 3.11 shows exactly what violating that bound looks like.

### 3.4 Separable grids: no interaction term

**Definition 3.12 (Separability).** $F$ is **separable** (rank one) if $F(b,u) = f(b)\,g(u)$ for some $f, g : \mathbb{N} \to \mathbb{Q}$.

**Theorem 3.13 (Rank-one law).** If $F$ is separable then every $2 \times 2$ minor vanishes:
$$F(b,u)\,F(b',u') \;=\; F(b,u')\,F(b',u) \qquad \text{for all } b,b',u,u'.$$

*Proof sketch.* Substitute $f(b)g(u)$ four times; both sides become $f(b)f(b')g(u)g(u')$. $\square$

Vanishing minors are the exact absence of a *cell-specific* effect: no individual cell can deviate from the product of its row and column behaviour. That is precisely what a "threshold at a particular $(b,u)$" would require, so separability rules it out structurally rather than numerically.

Separable grids also inherit gradualness from their factors:

**Theorem 3.14 (Notch bounds for separable grids).** If $F(b,u) = f(b)g(u)$ with $0 \le f(b) - f(b+1) \le \delta$ and $|g(u)| \le M$, then $\mathrm{row}(F;b,u) = \bigl(f(b) - f(b+1)\bigr) g(u) \le M\delta$. Symmetrically, if $0 \le g(u) - g(u+1) \le \delta$ and $|f(b)| \le M$, then $\mathrm{col}(F;b,u) = f(b)\bigl(g(u)-g(u+1)\bigr) \le M\delta$.

*Proof sketch.* The two factorisation identities are one line of algebra each; the bounds follow by monotone multiplication. $\square$

### 3.5 The transfer theorem: approximate models suffice

Real data never matches a model exactly. The following says it does not have to.

**Theorem 3.15 (Perturbation of notches).** Let $F, G$ be grids with $|F(b,u) - G(b,u)| \le \delta$ for all cells. If $\mathrm{row}(G;b,u) \le \varepsilon$ then $\mathrm{row}(F;b,u) \le \varepsilon + 2\delta$, and likewise for column notches.

*Proof sketch.* $F(b,u) - F(b+1,u) \le \bigl(G(b,u) + \delta\bigr) - \bigl(G(b+1,u) - \delta\bigr) = \mathrm{row}(G;b,u) + 2\delta$. $\square$

**Theorem 3.16 (Transfer: approximate separability excludes cliffs).** Let $G$ be $\varepsilon$-gradual (all notches $\le \varepsilon$) and let $F$ be uniformly $\delta$-close to $G$. If $\varepsilon + 2\delta < R$, where $R = F(b_0,u_0) - F(b_0+m,u_0+n)$, then every notch of the $F$-staircase is strictly less than $R$: $F$ has no cliff.

*Proof sketch.* Each staircase entry is a row or column notch (by construction of the list), bounded by $\varepsilon + 2\delta$ via Theorem 3.15, which is $< R$. $\square$

The tolerance $\delta$ is the modelling budget. One may hold the model to be only approximately right and still deduce the qualitative verdict.

### 3.6 Geometric descent: no sharp edge at a floor

Practitioners often speak of a "practical floor": a parameter value below which the statistic is deemed useless. Is crossing the floor an event or a process?

**Theorem 3.17 (Geometric retention).** Let $s : \mathbb{N} \to \mathbb{Q}$ satisfy $r \cdot s(k) \le s(k+1)$ for all $k$, with $r \ge 0$. Then $r^j s(n) \le s(n+j)$ for all $n, j$.

*Proof sketch.* Induction on $j$, multiplying the inductive inequality by $r \ge 0$ and chaining with the one-step hypothesis. $\square$

**Corollary 3.18 (Slow descent).** Under the hypotheses of Theorem 3.17, if $\tau < r^j s(n)$ then $\tau < s(n+j)$: the dial cannot reach the floor $\tau$ within $j$ notches.

**Corollary 3.19 (Crossing has no jump).** If $\tau \le s(k)$ then $r\tau \le s(k+1)$. The first value below the floor is still at least $r$ times the floor — the dial cannot plunge through.

**Corollary 3.20 (Relative overshoot).** The single notch on which the dial crosses its floor moves it by at most $(1-r)\,s(k)$. For retention $r$ near $1$ the crossing is a gradual transition by definition of the words.

---

## 4. The exact ceiling of the capped trailing-zero dial

We now specialise. The point of this section is that the ceiling surface is not merely *estimated* but *computed in closed form*, which is what allows explanations (2) and (3) of §1.1 to be eliminated rather than argued about.

### 4.1 The product law

**Definition 4.1.** For $u \ge 0$ and $b \ge 1$ set
$$\mathrm{cap}(u) = \tfrac{6}{7}\bigl(1 - 8^{-u}\bigr), \qquad \mathrm{bit}(b) = 1 + \frac{1}{4^{b}-1}, \qquad \mathcal{C}(b,u) = \mathrm{cap}(u)\cdot \mathrm{bit}(b).$$

**Theorem 4.2 (Product law for the ceiling).** For $1 \le u \le b$,
$$\rho^2(b,u) \;=\; \mathcal{C}(b,u) \;=\; \frac{6}{7}\bigl(1 - 8^{-u}\bigr)\Bigl(1 + \frac{1}{4^{b}-1}\Bigr).$$

*Proof sketch.* Write $Y = N = 2^b$ and $X = N^3 = 2^{3b}$. The profile of Definition 2.1 gives
$$\sum_i m_i^3 = \sum_{j=0}^{u-1} 2^{3(b-1-j)} + 2^{3(b-u)} = X\Bigl(\tfrac17\bigl(1 - 8^{-u}\bigr) + 8^{-u}\Bigr) = X\Bigl(\tfrac17 + \tfrac67 8^{-u}\Bigr),$$
using the finite geometric sum $\sum_{j=0}^{u-1} 8^{-(j+1)} = \frac17(1-8^{-u})$, while $\sum_i m_i = Y$. Hence
$$\rho^2 = 1 - \frac{\sum_i m_i^3 - Y}{X - Y} = \frac{X - X\bigl(\tfrac17 + \tfrac67 8^{-u}\bigr)}{X-Y} = \frac{\tfrac67\bigl(1-8^{-u}\bigr) X}{X - Y} = \tfrac67\bigl(1-8^{-u}\bigr)\cdot \frac{4^{b}}{4^{b}-1},$$
and $4^b/(4^b-1) = 1 + 1/(4^b - 1)$. $\square$

Three consequences are immediate and worth naming.

**Corollary 4.3 (The ceiling grid is separable, hence rank one).** $\mathcal{C}(b,u) = \mathrm{bit}(b)\cdot\mathrm{cap}(u)$ is separable, so every $2\times 2$ minor vanishes:
$$\mathcal{C}(b,u)\,\mathcal{C}(b',u') = \mathcal{C}(b,u')\,\mathcal{C}(b',u).$$
There is no interaction term anywhere in the ceiling surface: no cell has a private threshold.

**Corollary 4.4 (Windows).** $\mathrm{cap}$ increases to its supremum $6/7$, with $\mathrm{cap}(u) \le 6/7$ always and $6/7 - 10^{-7} \le \mathrm{cap}(u)$ once $u \ge 8$. Likewise $1 < \mathrm{bit}(b) \le 1 + 10^{-7}$ once $b \ge 32$, and $\mathrm{bit}(b) \le 4/3$ for all $b \ge 1$.

*Proof sketch.* $8^{-u} \le 8^{-8} = 1/16777216$ for $u \ge 8$, and $4^b - 1 \ge 4^{32}-1 > 10^7$ for $b \ge 32$. $\square$

### 4.2 Exact notches, and their direction

**Theorem 4.5 (Exact cap notch).** For all $u \ge 0$,
$$\mathrm{cap}(u+1) - \mathrm{cap}(u) = \tfrac34\, 8^{-u},
\qquad\text{hence}\qquad
\rho^2(b,u+1) - \rho^2(b,u) = \tfrac34\, 8^{-u}\,\mathrm{bit}(b) \;>\; 0 .$$
Equivalently, in the notch notation of §3, $\mathrm{col}(\mathcal{C}; b,u) = -\tfrac34\,8^{-u}\,\mathrm{bit}(b)$.

*Proof sketch.* $\tfrac67\bigl(8^{-u} - 8^{-u-1}\bigr) = \tfrac67\cdot\tfrac78\cdot 8^{-u} = \tfrac34 8^{-u}$. $\square$

This single line carries the paper's sharpest point. **The ceiling rises with the cap, while the recorded correlation falls.** The two move in opposite directions; therefore no part of the recorded decline along the cap dial can be a ceiling phenomenon. Moreover the rise is geometric with ratio $1/8$ — a smooth exponential approach to $6/7$, never a jump.

**Theorem 4.6 (Both notches are exponentially small).** For $b \ge 1$:
$$\bigl|\mathrm{col}(\mathcal{C};b,u)\bigr| \le 8^{-u}, \qquad \bigl|\mathrm{row}(\mathcal{C};b,u)\bigr| \le 2\cdot 4^{-b}.$$

*Proof sketch.* For the cap notch, combine Theorem 4.5 with $\mathrm{bit}(b) \le 4/3$: the notch is at most $\frac34\cdot\frac43\cdot 8^{-u} = 8^{-u}$. For the bit notch, factor
$\mathrm{row}(\mathcal{C};b,u) = \mathrm{cap}(u)\bigl(\frac{1}{4^b-1} - \frac{1}{4^{b+1}-1}\bigr)$, bound $\mathrm{cap}(u) \le 6/7$, drop the (positive) subtracted term, and use $\frac{1}{4^b - 1} \le 2\cdot 4^{-b}$ (valid since $4^b \ge 4$). $\square$

### 4.3 The flatness theorem

**Theorem 4.7 (Ceiling window on the envelope).** For $b \ge 32$ and $u \ge 8$,
$$\tfrac67 - 10^{-6} \;\le\; \mathcal{C}(b,u) \;\le\; \tfrac67 + 10^{-6}.$$

*Proof sketch.* Multiply the two windows of Corollary 4.4: $\bigl(\frac67 - 10^{-7}\bigr)\cdot 1 \le \mathrm{cap}\cdot\mathrm{bit} \le \frac67\bigl(1 + 10^{-7}\bigr)$, and both endpoints lie inside the stated band. $\square$

**Theorem 4.8 (Flatness).** For any two envelope cells, $b, b' \ge 32$ and $u, u' \ge 8$,
$$\bigl|\mathcal{C}(b,u) - \mathcal{C}(b',u')\bigr| \;<\; 10^{-5}.$$

*Proof sketch.* Both values lie in the window of Theorem 4.7, whose width is $2\cdot 10^{-6} < 10^{-5}$. $\square$

The recorded decline is $0.26$. The total possible variation of the ceiling across the entire recorded envelope is below $10^{-5}$ — more than four orders of magnitude smaller, and it has the wrong sign along the cap dial anyway. **Explanation (2) of §1.1 is dead.** Whatever produces the recorded decline, it is not the encoding's resolution.

Numerically: at $(b,u) = (32,8)$ the ceiling is $0.857142806\ldots$; at $(64,12)$ it is $0.857142857\ldots$; the supremum $6/7 = 0.857142857\ldots$ is approached from below. The whole surface is, for practical purposes, the constant $6/7$.

---

## 5. The decline is attenuation

If the ceiling does not move, the observed movement must live in the attenuation factor of Definition 2.3.

**Theorem 5.1 (Attenuation must strictly decline).** Let two cells have observed correlations $s > s' > 0$, ceilings $r$ and $r'$ with $0 < r \le r'$, and attenuations defined by $a r = s^2$, $a' r' = (s')^2$. Then $a' < a$.

*Proof sketch.* Positivity of $a, a'$ is immediate from $s, s' > 0$. Then $a' = (s')^2/r' \le (s')^2/r < s^2/r = a$, using $r \le r'$ and $s' < s$. $\square$

The hypothesis $r \le r'$ is exactly what the cap dial does: by Theorem 4.5, advancing the cap *raises* the ceiling. So along the cap dial the observed fall must be an attenuation fall, with no possible ceiling contribution — indeed the attenuation must fall by slightly *more* than the observation suggests, since it is fighting a rising ceiling.

**Theorem 5.2 (Quantitative attenuation drop).** Let the top recorded cell have $s = 0.79$ at some envelope point $(b,u)$ with $b \ge 32$, $8 \le u \le b$, and the bottom cell have $s' = 0.53$ at $(b', u')$ with $b' \ge 32$, $8 \le u' \le b'$. Then the corresponding attenuation factors satisfy
$$a - a' \;>\; \frac{2}{5}.$$

*Proof sketch.* By Theorem 4.7 both ceilings lie in $\bigl[\frac67 - 10^{-6},\, \frac67 + 10^{-6}\bigr]$. Hence
$$a \;\ge\; \frac{0.79^2}{\frac67 + 10^{-6}}, \qquad a' \;\le\; \frac{0.53^2}{\frac67 - 10^{-6}} .$$
Numerically $a \ge 0.728116\ldots$ and $a' \le 0.327716\ldots$, so $a - a' \ge 0.400400\ldots > 2/5$. $\square$

The margin is thin by design: the theorem is stated with the crude bound $2/5$ precisely so that it depends only on the two recorded corner values and the flatness theorem, with no further modelling. The interpretation is unambiguous. Over the recorded envelope the encoding's capacity is constant to within $10^{-5}$, and the fraction of that capacity actually used collapses from about $73\%$ to about $33\%$. The dial's decline is a statement about the *coupling* between the statistic and its target, not about the statistic's arithmetic resolution.

---

## 6. No convention artifact

There remains explanation (3). The dial's definition contains one arbitrary choice: where to put the boundary key $x = 0$, whose $2$-adic valuation is conventionally either $\infty$ or $b$. A convention change moves **one key** from one tie block to another, leaving the sample size $N$ fixed. Could such a move manufacture a $0.26$ decline?

### 6.1 The exact response of the ceiling to a profile edit

**Theorem 6.1 (Exact response).** Let $L, L'$ be profiles with the same total $N = \sum L = \sum L' \ge 2$. Then
$$\rho^2(L) - \rho^2(L') \;=\; \frac{12\,\mathrm{tc}(L') - 12\,\mathrm{tc}(L)}{N^3 - N}.$$

*Proof sketch.* Substitute the definition $\rho^2(L) = 1 - 12\,\mathrm{tc}(L)/(N^3-N)$ twice; the constants cancel and the common denominator $N^3 - N$ is positive because $N \ge 2$. $\square$

**Corollary 6.2 (Bounded response).** If $\bigl|12\,\mathrm{tc}(L') - 12\,\mathrm{tc}(L)\bigr| \le \Delta$ then $\bigl|\rho^2(L) - \rho^2(L')\bigr| \le \Delta/(N^3 - N)$.

The cubic denominator is the whole story: any edit whose tie-correction effect grows slower than $N^3$ is invisible at large $N$.

### 6.2 A one-key move

**Theorem 6.3 (Exact Kendall change of a one-key move).** Let a profile contain two adjacent blocks of sizes $m+1$ and $m'$, and let the convention change move one key from the first into the second, producing blocks $m$ and $m'+1$ with all other blocks unchanged. Then
$$12\,\mathrm{tc}\bigl(\dots, m,\, m'+1, \dots\bigr) - 12\,\mathrm{tc}\bigl(\dots, m+1,\, m', \dots\bigr) \;=\; 3\bigl((m')^2 + m'\bigr) - 3\bigl(m^2 + m\bigr).$$

*Proof sketch.* By additivity of $\mathrm{tc}$ over concatenation, all unchanged blocks cancel. For a single block, $12\,\mathrm{tc} = m^3 - m$, and $\bigl((m'+1)^3 - (m'+1)\bigr) - \bigl((m')^3 - m'\bigr) = 3(m')^2 + 3m'$, and symmetrically for $m$. Subtracting gives the claim. $\square$

The formula is exact and pleasantly interpretable: a one-key move costs $3(m^2+m)$ in the block it leaves and gains $3((m')^2+m')$ in the block it enters. It is quadratic in block size, hence *quadratic* against a *cubic* denominator.

**Theorem 6.4 (Convention bound for balanced profiles).** Suppose the profile is balanced at the two edited blocks: $2(m+1) \le N$ and $2m' \le N$, with $N \ge 2$. Then a one-key move changes the ceiling by less than $4/N$:
$$\bigl|\rho^2(\dots,m+1,m',\dots) - \rho^2(\dots,m,m'+1,\dots)\bigr| \;<\; \frac{4}{N}.$$

*Proof sketch.* Balance gives $m, m' \le N/2$, so by Theorem 6.3 the Kendall change is at most $3\bigl(\frac{N^2}{4} + \frac{N}{2}\bigr)$ in absolute value. Corollary 6.2 turns this into the ceiling bound $3\bigl(\frac{N^2}{4}+\frac N2\bigr)/(N^3-N)$, and a cross-multiplication shows this is strictly below $4/N$ for $N \ge 2$. $\square$

Balance is not a technicality one hopes for: by Definition 2.1 the profile of $T_u$ is balanced, its largest block being exactly $N/2$.

**Theorem 6.5 (No convention artifact on the envelope).** Let $1 \le u \le b$ with $b \ge 32$. Then *any* one-key convention change in the tie profile of $T_u$ on $\mathcal{K}_b$ changes the ceiling by less than
$$10^{-9}.$$

*Proof sketch.* Here $N = 2^b \ge 2^{32} = 4294967296$, and the profile is balanced, so Theorem 6.4 gives a bound of $4/N \le 4/2^{32} = 9.3132\ldots \times 10^{-10} < 10^{-9}$. $\square$

Eight orders of magnitude below the recorded $0.26$. **Explanation (3) is dead.** Conventions about the boundary key are, at cryptographic bit lengths, mathematically inaudible; one would need to reassign on the order of $10^{8}$ keys before the ceiling budged at the recorded scale.

---

## 7. The practical floor is a transition of positive width

An earlier empirical study reported a "practical floor" near bit length $b \approx 54$: below it the dial is usable, above it not. The phrase invites the picture of an edge. The following converts the recorded per-notch bound into a lower bound on the *width* of the crossing.

**Theorem 7.1 (Transition-width law).** Let $s : \mathbb{N} \to \mathbb{Q}$ be a one-dial trace with $s(j) - s(j+1) \le d$ for every $j$. Fix a floor $\tau$ and a band half-width $\eta$. If $s(k) \ge \tau + \eta$ and $s(k+m) \le \tau - \eta$, then
$$2\eta \;\le\; m\,d, \qquad\text{i.e.}\qquad m \;\ge\; \frac{2\eta}{d}.$$

*Proof sketch.* By the row telescoping identity of Theorem 3.3 applied to the one-dial grid $(b,u)\mapsto s(b)$, the $m$ notches between $k$ and $k+m$ sum to $s(k) - s(k+m) \ge 2\eta$. Since each is at most $d$, the sum is at most $md$. $\square$

**Corollary 7.2 (The reported floor is not an edge).** With the recorded per-notch bound $d = 0.09$ and a band of half-width $\eta = 0.05$ around the floor, at least $m \ge 2$ bit-length notches are required to cross the band.

*Proof sketch.* $2\eta = 0.1 > 0.09 = d$, so $m = 1$ is impossible; $m = 0$ contradicts $\tau + \eta \le s(k)$ and $s(k) \le \tau - \eta$. $\square$

A second, independent argument gives a stronger count under a mild geometric assumption.

**Theorem 7.3 (Geometric descent needs three notches).** Suppose each bit-length notch retains at least $7/8$ of the correlation, $\tfrac78 s(k) \le s(k+1)$ for all $k$. If $s(n) = 0.79$, then $s(n+2) > 0.53$.

*Proof sketch.* By Theorem 3.17, $s(n+2) \ge (7/8)^2 \cdot 0.79 = 0.6048\ldots > 0.53$. $\square$

Together: the drop from the recorded top to the recorded bottom cannot occur in two bit-length steps, and the crossing of the reported floor occupies at least two notches. The floor is a *region*, not a boundary. Practically, this means a practitioner who is one notch on the wrong side of the reported floor has not fallen off anything: by Corollary 3.19 the value there is still at least $r$ times the floor, and by Corollary 3.20 the notch on which the crossing happens moves the dial by at most $(1-r)$ of its current value.

---

## 8. The recorded grid: assembling the verdict

We now apply the calculus to the four recorded facts of §1.2. Write $\mathrm{top} = 0.79$, $\mathrm{bot} = 0.53$, $R = 0.26$, $d = 0.09$, and let $F$ be *any* grid with $F(0,0) = \mathrm{top}$, $F(3,2) = \mathrm{bot}$, all staircase notches non-negative and all at most $d$. The staircase joining the corners has $3 + 2 = 5$ notches, explicitly
$$\bigl(\mathrm{row}(F;0,0),\ \mathrm{row}(F;1,0),\ \mathrm{row}(F;2,0),\ \mathrm{col}(F;3,0),\ \mathrm{col}(F;3,1)\bigr).$$

**Theorem 8.1 (Mixed-zone verdict).** Under these hypotheses:

1. **Exact budget.** The five notches sum to exactly $R = 0.26$.
2. **The decline is real.** Some notch is at least $R/5 = 0.052$.
3. **No cliff.** Every notch is strictly less than $R$.
4. **Gradual.** At least three of the five notches are strictly active.
5. **Not a resolution effect.** The underlying tie ceiling varies by less than $10^{-5}$ across the whole envelope $b,b' \ge 32$, $u,u' \ge 8$.

*Proof sketch.* (1) is Theorem 3.3 with the corner values substituted. (2) is a pigeonhole on (1): if all five were below $0.052$ the sum would be below $0.26$. (3) is Corollary 3.6 with $\varepsilon = 0.09 < 0.26 = R$. (4) is the spreading law, Theorem 3.5: the active count is at least $R/d = 26/9 = 2.888\ldots$, hence at least $3$ since it is an integer. (5) is the flatness theorem, Theorem 4.8. $\square$

Two sanity checks confirm the verdict has content on both sides.

**Proposition 8.2 (Realisable).** The hypotheses are consistent: the perfectly gradual grid $\Lambda_{0.79,\,0.052}$ of Definition 3.8 has exactly the recorded corners, is monotone in both dials, and all five of its notches equal $0.052 \le 0.09$.

**Proposition 8.3 (Violable).** The cliff grid $\mathrm{Cl}$ of Definition 3.10 has the same two corners and the same total decline $0.26$, but its first notch is $0.26 > 0.09$: it violates precisely the recorded notch bound.

So the recorded gradualness bound is exactly the hypothesis that does the work, and it is exactly the hypothesis a cliff would break. The verdict is neither vacuous nor automatic — it is earned by the data.

---

## 9. Algorithms

Three computations underlie everything and all are cheap.

**(A) Exact ceiling evaluation.** Given $(b,u)$, return $\rho^2(b,u)$ as an exact rational, either by summing $\sum_i (m_i^3 - m_i)$ over the $u+1$ blocks ($O(u)$ big-integer operations on numbers of $O(b)$ bits) or by the closed form of Theorem 4.2 ($O(1)$ rational operations, up to the cost of $8^{-u}$ and $4^{-b}$). Agreement between the two is a strong correctness check and holds identically.

**(B) Gradualness audit.** Given a recorded grid and a base corner, build the staircase list of $m+n$ notches (Definition 3.2), verify the telescoping identity against the corner difference, check the per-notch bound, and emit the spreading-law certificate $\lceil R/\varepsilon\rceil$ as a lower bound on the number of active notches. Cost $O(m+n)$.

**(C) Convention-sensitivity bound.** Given a tie profile and a pair of blocks, compute the exact Kendall change $3((m')^2+m') - 3(m^2+m)$ of Theorem 6.3, divide by $N^3 - N$ for the exact ceiling shift, and compare with the universal balanced bound $4/N$. Cost $O(1)$ after $N$ is known.

---

## 10. Discussion

### 10.1 What the argument buys

The pattern of reasoning generalises beyond this dial. Whenever a statistic has a *computable* capacity — here the tie ceiling — one can split any observed sweep into a capacity part and a coupling part, and the capacity part can be settled exactly rather than estimated. In this case the capacity turned out to be essentially constant ($6/7$ to within $10^{-5}$) and, along one dial, moving in the *opposite* direction to the observation. That single sign fact is more informative than any amount of numerical agreement: it makes the "resolution effect" hypothesis not merely improbable but arithmetically impossible.

The complementary tool is the notch calculus. Its content is that "gradual" and "cliff" are not vague adjectives but a bookkeeping dichotomy: a decline of size $R$ with per-notch bound $\varepsilon$ *must* occupy at least $R/\varepsilon$ notches, and the bound is attained. Once a study reports its per-notch bound, the gradualness verdict follows without access to the interior data. This is a useful reporting discipline: corners, monotonicity, and a per-notch bound are enough to certify a shape.

### 10.2 What had to be restated

One expectation did not survive. It is tempting to read a declining correlation as the statistic "running out of resolution". Here the opposite holds: the cap dial *increases* the ceiling geometrically ($\frac34 8^{-u}$ per notch, toward $6/7$), so a cap increase can only ever make the encoding more capable. The decline had to be relocated, from the ceiling to the attenuation, and the relocation is quantitative: the attenuation drops by more than $0.4$ on an interval where the ceiling moves by less than $10^{-5}$.

### 10.3 Limitations

The results about the recorded grid are conditional on the four reported summary facts, deliberately so. If the reported per-notch bound $0.09$ were wrong, clause (4) of Theorem 8.1 would fail — and Proposition 8.3 shows exactly how. The attenuation model $s^2 = a\rho^2$ is the standard multiplicative one; a different error model would change the constants in Theorem 5.2, though not the flatness theorem on which it rests. Finally, the ceiling is a bound on the *achievable* correlation given ties; it does not by itself predict the observed value.

### 10.4 Interpretation for practice

Three practical conclusions. First, capping the trailing-zero statistic costs almost nothing in capacity beyond $u = 8$: the cap factor is within $10^{-7}$ of its supremum. Second, bit length is essentially irrelevant to capacity beyond $b = 32$: the bit factor is within $10^{-7}$ of $1$. Third, the conventional treatment of the boundary key is irrelevant to nine decimal places. Any decline observed in this regime is a statement about the world, not about the instrument.

---

## 11. Future directions

**Attenuation is itself rank one.** The ceiling grid is *exactly* rank one. If an observed grid is also numerically rank one, then the attenuation grid — being a cellwise quotient of the two — is rank one as well, and a rank-one attenuation means the bit-length coupling and the cap coupling are statistically independent channels. The machinery is already available: vanishing $2\times2$ minors give a rank-one test, and the transfer theorem (Theorem 3.16) lets that test be run up to a tolerance $\delta$ rather than exactly. Only the twelve recorded cells are needed to carry it out.

**A universal spreading constant.** Theorem 3.9 shows the spreading bound $R/\varepsilon$ is attained by the perfectly gradual grid, so $R/\varepsilon$ active notches is optimal. It is natural to ask for the analogous sharp constant when the per-notch bound is replaced by a moment condition (e.g. bounded $\ell^2$ norm of the notch vector), which would let studies report a variance of notches rather than a maximum.

**Beyond two dials.** The staircase decomposition generalises verbatim to $k$ dials along any monotone lattice path, with $\sum_i m_i$ notches. The interesting question is whether the *choice* of path can be exploited: a grid that looks gradual along one staircase and cliff-like along another would be a genuinely new phenomenon, and rank-one grids provably cannot exhibit it.

**Other capacity laws.** The product structure $\mathrm{cap}(u)\mathrm{bit}(b)$ arose because the tie profile is a geometric sequence truncated by the cap. Other coarsened statistics — modular residues, popcount buckets, leading-digit classes — have their own profiles and their own capacity laws, some of which will not be separable. Locating the boundary between separable and genuinely interacting capacity surfaces would tell us when cell-specific threshold effects are even *possible*.

---

## 12. Conclusion

A $4 \times 3$ sweep recorded a rank correlation declining from $0.79$ to $0.53$. We have shown that the decline is gradual, spread over at least three of the five staircase notches, with no single notch approaching the total; that it is not a resolution or threshold effect, because the exact capacity of the statistic — computed in closed form as $\frac67(1-8^{-u})(1 + \frac1{4^b-1})$ — varies by less than $10^{-5}$ across the entire recorded envelope and moves *upward* along the very dial on which the correlation falls; and that it is not a convention artifact, because reassigning a single boundary key shifts the capacity by less than $10^{-9}$. The decline is therefore attenuation, and it is large: the attenuation factor must drop by more than $0.4$. Finally, the reported "practical floor" is a transition of provably positive width — at least two notches, and at least three under a geometric retention of $7/8$. There is no edge to fall off.
