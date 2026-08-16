# Sheaf-Theoretic Data Integration: Exact Laws, Threshold Parameters, and the Betti Number of the Overlap Nerve

**Aristotle**

---

## Abstract

We develop a complete sheaf-theoretic account of databases with missing entries. A table with $n$ columns and $k$ rows is regarded as a family of local sections of a sheaf on the column set, each row being a section over its observed support; the imputation question becomes the gluing question. We prove that gluing is equivalent to pairwise agreement on overlaps, that the space of completions of a gluable table has exactly $q^{u}$ elements where $u$ is the number of wholly unobserved columns and $q$ the alphabet size, and that column-mean imputation coincides identically with sheaf imputation on gluable real-valued data.

For the natural random model — cells independently missing with rate $r$, observed cells independent uniform on an alphabet of size $q$ — we compute the probability of the sheaf condition in closed form:
$$P(\mathrm{sheaf}) = \big(qA^{k} - (q-1)r^{k}\big)^{n}, \qquad A = r + \tfrac{1-r}{q}.$$
The law is exponential in the number of columns, is *increasing* in the missing rate, and admits no representation of the form $(1-r)^{C}$ for any exponent $C$. We compute the first two moments of the number $N$ of global sections, $\mathbb{E}[N] = (qA^{k})^{n}$ and $\mathbb{E}[N^{2}] = (qA^{k} + (q^{2}-q)r^{k})^{n}$, and derive matching first- and second-moment bounds $\mathbb{E}[N]^{2}/\mathbb{E}[N^{2}] \le P(\mathrm{sheaf}) \le \mathbb{E}[N]$, tight at $r \in \{0,1\}$ and strict inside.

We then identify the exact difficulty parameter. Writing $\mathrm{tail}(k,r) = \Pr[\mathrm{Bin}(k,1-r) \ge 2] = 1 - r^{k} - k(1-r)r^{k-1}$, we prove the weighted-tail identity $1 - \beta = \sum_{j\ge 2}\binom{k}{j}(1-r)^{j}r^{k-j}(1 - q^{1-j})$ and the two-sided sandwich $(1-1/q)\mathrm{tail} \le 1-\beta \le \mathrm{tail}$. Consequently $P(\mathrm{sheaf})$ has a genuine threshold at $n\cdot\mathrm{tail}(k,r) \asymp 1$, with $P \le e^{-n(1-1/q)\mathrm{tail}}$ and $P \ge 1 - n\,\mathrm{tail}$.

Finally we locate the cohomology. The data sheaf is flasque, hence acyclic: $H^{0} \cong \Bbbk^{n}$ and $H^{1} = 0$ for every cover, so no cohomological invariant can measure imputation difficulty for raw records. Genuine obstructions appear one level up, for the *calibration* sheaf of inter-source offsets, where we prove that for an arbitrary finite family of pairwise overlaps
$$\dim H^{1} + \#\text{sources} = \#\text{overlaps} + \#\text{components},$$
i.e. $\dim H^{1}$ equals the first Betti number of the overlap nerve, in every characteristic; $H^{1} = 0$ if and only if the nerve is a forest. Admitting triple overlaps refines this to $\dim H^{1} + \#\text{sources} + \operatorname{rank} d^{1} = \#\text{overlaps} + \#\text{components}$, so $\dim H^{1} \le b_1$: triple overlaps can only destroy obstructions, never create them.

**Keywords:** sheaf condition, missing data, imputation, Čech cohomology, nerve, first Betti number, binomial tail, phase transition, data integration.

---

## 1. Introduction

### 1.1 Motivation

Missing data is usually treated as an estimation problem: a blank cell is an unknown number, and imputation is the business of guessing it. This paper takes seriously an alternative framing suggested by geometry. A table with holes is a family of *partial* observations, each defined on its own subset of features, and the question of whether the holes can be filled consistently is the question of whether these partial observations *glue*.

Gluing is the defining property of a sheaf. A sheaf assigns data to open sets, restricts along inclusions, and satisfies: a family of local sections that agree on all pairwise overlaps determines a unique global section. Reading a database this way — the column set as the base space, the observed support of each row as an open set, the row itself as a local section — turns imputation into a local-to-global problem and raises three questions:

1. **Combinatorics.** When exactly does a table glue, and how many completions does it have?
2. **Probability.** For a randomly masked table, what is the probability of gluability, and what single parameter controls it?
3. **Topology.** Is there a cohomological obstruction to imputation, and if so, what does it measure?

We answer all three. The answers to (1) and (3) are, for raw records, deflationary: gluing is exactly pairwise consistency, and the relevant cohomology vanishes identically. The answer to (2) is an exact law with a clean threshold. And the pursuit of (3) past its first, negative answer produces the paper's most substantial theorem: an exact identification of the obstruction to *multi-source calibration* with the first Betti number of the overlap nerve.

### 1.2 Prior expectations and their fate

Three natural conjectures motivated this work.

- **(C1)** The probability that a random table with missing rate $r$ glues is $(1-r)^{C}$, where $C$ counts overlapping constraints; consistency degrades exponentially as the data gets denser in constraints.
- **(C2)** Sheaf imputation — filling blanks by finding the nearest global section — outperforms mean and nearest-neighbour imputation when $r < 1/2$ and the feature count is large.
- **(C3)** Data imputation is a sheaf cohomology problem.

Our findings: **(C1) is false** in functional form, in the location of its combinatorial factor, and in the *direction* of its monotonicity; it is replaced by an exact law (Theorem 4.3) and a sharp threshold (Theorem 5.6). **(C2) is false** for the constant data sheaf, because mean imputation and sheaf imputation are provably the same function on gluable data (Theorem 3.6); any advantage must come from nontrivial restriction maps. **(C3) is true only in degree zero** for raw records (Theorem 6.2), and becomes a genuine $H^{1}$ statement only for calibration coefficients — where the obstruction dimension is exactly a Betti number (Theorem 7.4).

### 1.3 Organization

Section 2 fixes the model. Section 3 proves the gluing and counting theorems and settles the imputation comparison. Section 4 computes the exact probability law and its moments. Section 5 identifies the binomial tail as the difficulty parameter and establishes the threshold. Section 6 computes the Čech cohomology of the data sheaf. Section 7 develops the calibration sheaf and proves the Betti number theorem, including the triple-overlap refinement. Section 8 gives algorithms, Section 9 applications and discussion, Section 10 future directions.

---

## 2. The model

### 2.1 Databases as partial sections

Fix $n, k \ge 0$ and an alphabet $\Sigma$ of size $q \ge 1$; we write $\Sigma = \{0, \dots, q-1\}$.

**Definition 2.1 (Partial database).** A *partial database* with $k$ rows and $n$ columns over $\Sigma$ is a map
$$D : \{1,\dots,k\} \times \{1,\dots,n\} \longrightarrow \Sigma \cup \{\bot\},$$
where $\bot$ denotes a missing entry. The *observed support* of row $j$ is $U_j = \{c : D(j,c) \ne \bot\}$.

**Definition 2.2 (Data sheaf).** The *data sheaf* $\mathcal{F}$ on the column set assigns to a subset $V$ of columns the set $\mathcal{F}(V) = \Sigma^{V}$ of records defined on $V$, with restriction maps given by forgetting columns. Row $j$ of $D$ is then a section $D_j \in \mathcal{F}(U_j)$, and $D$ is a family of local sections over the cover $\{U_1, \dots, U_k\}$ of $\bigcup_j U_j$.

**Definition 2.3 (Section, gluability).** A *global section* of $D$ is a complete record $g : \{1,\dots,n\} \to \Sigma$ such that $g(c) = D(j,c)$ whenever $D(j,c) \ne \bot$. The database is *gluable* if a global section exists. Write $\mathrm{Sec}(D)$ for the set of global sections.

**Definition 2.4 (Pairwise consistency).** $D$ is *pairwise consistent* if for all rows $j, j'$ and all columns $c$, $D(j,c) \ne \bot$ and $D(j',c) \ne \bot$ imply $D(j,c) = D(j',c)$.

Note that pairwise consistency is exactly the statement that the local sections $D_j$ and $D_{j'}$ agree on the overlap $U_j \cap U_{j'}$, i.e. the hypothesis of the sheaf axiom.

**Definition 2.5 (Observed columns).** $\mathrm{Obs}(D) = \{c : \exists j,\, D(j,c) \ne \bot\}$, and $u(D) = n - |\mathrm{Obs}(D)|$ is the number of wholly unobserved columns.

### 2.2 The random model

**Definition 2.6 (MCAR uniform model).** Each of the $nk$ cells is independently missing with probability $r \in [0,1]$; each non-missing cell independently carries a value uniform on $\Sigma$. We write $P_{n,k,q}(r)$ for the probability that the resulting database is gluable, and $N$ for the (random) number of global sections.

Two remarks. First, the masking is *missing completely at random* and cellwise independent; correlations between columns would break the factorization used in Section 4, though the factorization survives whenever columns are independent. Second, the values are uniform and independent, so the model describes gluing of *unrelated* records; the complementary situation, in which values come from masking a fixed ground truth, is Proposition 3.4.

---

## 3. Gluing, counting, and imputation

### 3.1 The gluing theorem

**Theorem 3.1 (Gluing = pairwise consistency).** *For $q \ge 1$, a partial database $D$ is gluable if and only if it is pairwise consistent.*

*Proof sketch.* ($\Rightarrow$) If $g$ is a global section and $D(j,c) = v$, $D(j',c) = v'$, then $v = g(c) = v'$. ($\Leftarrow$) Define $g(c)$ to be the common observed value in column $c$ if any row observes $c$, and an arbitrary alphabet element otherwise (possible since $q \ge 1$). Pairwise consistency makes this well defined, and $g$ is a section by construction. $\square$

The content is that no higher-order obstruction exists: agreement on pairwise overlaps suffices, with no condition on triples. This is the finite, combinatorial shadow of the fact (Theorem 6.2) that the data sheaf is acyclic.

A useful reformulation. For a column $c$, let
$$\mathrm{Val}(D,c) = \{v \in \Sigma : v = D(j,c) \text{ for every } j \text{ with } D(j,c) \ne \bot\}$$
be the set of values compatible with column $c$.

**Proposition 3.2.** *$D$ is gluable iff $\mathrm{Val}(D,c) \ne \varnothing$ for every $c$; moreover $\mathrm{Sec}(D) = \prod_{c} \mathrm{Val}(D,c)$ as a subset of $\Sigma^{n}$.*

The section set is a *product* set: gluability and the shape of the solution space are decided independently column by column. This is the structural reason every probabilistic statement below factorizes over columns.

### 3.2 Counting completions

**Theorem 3.3 (Section count).** *If $D$ is pairwise consistent then*
$$|\mathrm{Sec}(D)| = q^{\,u(D)},$$
*where $u(D)$ is the number of columns observed by no row.*

*Proof sketch.* By Proposition 3.2 the count is $\prod_c |\mathrm{Val}(D,c)|$. If $c$ is unobserved, $\mathrm{Val}(D,c) = \Sigma$, of size $q$. If $c$ is observed, pairwise consistency forces all observed entries equal to a single $v$, so $\mathrm{Val}(D,c) = \{v\}$, of size $1$. Splitting the product over $\mathrm{Obs}(D)$ and its complement gives $q^{u(D)}$. $\square$

The sheaf-theoretic degrees of freedom are located *precisely* at the wholly unobserved columns. A column observed once is as constrained as a column observed a thousand times; multiplicity of observation buys consistency risk, not information, in the constant sheaf.

### 3.3 Masking never breaks gluing

**Proposition 3.4 (Masked databases glue).** *Let $g : \{1,\dots,n\} \to \Sigma$ be a ground-truth record and let $M \subseteq \{1,\dots,k\}\times\{1,\dots,n\}$ be an arbitrary mask. Define $D(j,c) = g(c)$ if $(j,c) \in M$ and $\bot$ otherwise. Then $D$ is gluable, with $g$ a global section.*

This is immediate, and it is the first decisive blow against (C1) at the *deterministic* level: if the data-generating process is "mask a ground truth", the sheaf condition holds with probability one for every missing rate. Any law of the form $(1-r)^{C}$ with $C > 0$ is therefore already wrong before any probability is computed. The random model of Definition 2.6 — independent uniform values — is precisely the model in which the sheaf condition is nontrivial.

**Proposition 3.5 (Exact recovery).** *In the situation of Proposition 3.4, if every column is observed by at least one row, then $\mathrm{Sec}(D) = \{g\}$: sheaf imputation recovers the ground truth exactly.*

By Theorem 3.3, $u(D) = 0$ forces a unique section, which must be $g$.

### 3.4 Sheaf imputation equals mean imputation

Let now the entries be real numbers, $D(j,c) \in \mathbb{R} \cup \{\bot\}$, with pairwise consistency defined as before. Column-mean imputation returns
$$\widehat{\mu}(c) = \frac{1}{|O_c|}\sum_{j \in O_c} D(j,c), \qquad O_c = \{j : D(j,c) \ne \bot\}.$$

**Theorem 3.6 (Mean imputation = sheaf imputation).** *If $D$ is pairwise consistent and $D(j_0, c) = v$ for some row $j_0$, then $\widehat{\mu}(c) = v$; that is, column-mean imputation returns exactly the sheaf value.*

*Proof sketch.* Pairwise consistency makes every observed entry of column $c$ equal to $v$, so the sum is $|O_c| \cdot v$. $\square$

This refutes (C2) for the constant data sheaf, and it does so in the strongest possible way: not "mean imputation is competitive" but "mean imputation *is* sheaf imputation". Any claim of strict superiority for a sheaf-based method must come from a sheaf with nontrivial restriction maps — quotient sheaves, constraint sheaves, or the calibration sheaf of Section 7 — where a section over an overlap is not simply the common value of the records.

---

## 4. The exact probability law

### 4.1 Per-column agreement

**Lemma 4.1 (Agreement probability).** *Let $S$ be the set of rows observing a fixed column, $|S| = j$. Under the uniform value model, the probability that all rows in $S$ carry the same value is $q^{1-j}$ for $j \ge 1$, and $1$ for $j = 0$.*

*Proof sketch.* The number of $v \in \Sigma^{k}$ constant on $S$ is $q^{k - j + 1}$ for $j \ge 1$; dividing by $q^{k}$ gives $q^{1-j}$. Formally one proves the integral identity $\#\{v : v \text{ constant on } S\} \cdot q^{|S| - 1} = q^{k}$, which also covers $S = \varnothing$ under truncated subtraction. $\square$

### 4.2 Factorization and closed form

By Theorem 3.1, the database is gluable exactly when every column's observed entries agree. Cells being independent, the event decomposes into independent per-column events.

**Definition 4.2.** For a row set $S$, the *mask weight* is $w(S) = (1-r)^{|S|} r^{\,k-|S|}$, the probability that exactly the rows in $S$ observe a given column. The *per-column consistency probability* is
$$\beta_{\Sigma}(k,q,r) = \sum_{S \subseteq \{1,\dots,k\}} w(S)\, q^{\,1-|S|}\Big|_{\text{with } q^{1-|S|} \text{ read as } q^{-(|S|-1)_{+}}}.$$

**Theorem 4.3 (Exact law).** *For $q \ge 1$ and $r \in [0,1]$, put $A = r + \frac{1-r}{q}$ and*
$$\beta(k,q,r) = q A^{k} - (q-1)\, r^{k}.$$
*Then $\beta_\Sigma = \beta$ and*
$$P_{n,k,q}(r) = \beta(k,q,r)^{\,n}.$$

*Proof sketch.* Two steps. (i) *Factorization*: expanding the product over columns of the per-column sums, one obtains the sum over all mask configurations $M : \text{columns} \to 2^{\text{rows}}$ of $\prod_c w(M(c))q^{1-|M(c)|}$, which is precisely $P_{n,k,q}(r)$; hence $P = \beta_\Sigma^{n}$. (ii) *Closed form*: using $\sum_{S \subseteq [k]} a^{|S|} b^{k - |S|} = (a+b)^{k}$, the sum $\sum_S w(S) q^{-|S|+1}$ with $a = (1-r)/q$, $b = r$ evaluates to $q(r + \frac{1-r}{q})^{k}$; this over-counts the empty pattern, whose true weight is $r^{k}$ rather than $q\,r^{k}$, and correcting the single term $S = \varnothing$ subtracts $(q-1)r^{k}$. $\square$

Three immediate consequences.

**Corollary 4.4 (Wrong exponent).** *The exponent of the law is $n$, the number of columns. No binomial coefficient occurs anywhere in the formula.*

**Theorem 4.5 (Monotonicity in the missing rate).** *For $q \ge 1$ and $0 \le r_1 \le r_2 \le 1$, $\beta(k,q,r_1) \le \beta(k,q,r_2)$. Hence $P_{n,k,q}(r)$ is increasing in $r$.*

*Proof sketch.* A telescoping computation gives
$$\beta(k,q,r_2) - \beta(k,q,r_1) = (q-1)(r_2 - r_1)\Big(\textstyle\sum_{i<k} A_2^{\,i}A_1^{\,k-1-i} - \sum_{i<k} r_2^{\,i}r_1^{\,k-1-i}\Big),$$
where $A_i = r_i + (1-r_i)/q$; since $0 \le r_i \le A_i$ and the geometric sums are monotone in their arguments, the bracket is nonnegative. $\square$

Intuition: a missing cell deletes a consistency constraint. More missingness means fewer constraints, hence more gluability. The conjectured law $(1-r)^{C}$ has the monotonicity reversed.

**Theorem 4.6 (No missing-rate power law).** *There is no exponent $C$ with $P_{n,k,q}(r) = (1-r)^{C}$ for all $r \in [0,1]$, whenever $n \ge 1$, $k \ge 2$, $q \ge 2$.*

*Proof sketch.* At $r = 0$, $\beta(k,q,0) = q^{1-k} < 1$, so $P = q^{n(1-k)} < 1$, while $(1-r)^{C} = 1$ at $r = 0$ for every $C$ (with the convention $0^0 = 1$ irrelevant here). A single point kills every candidate. $\square$

**Proposition 4.7 (Strict decay).** *For $k \ge 2$, $q \ge 2$ and $r < 1$, $\beta(k,q,r) < 1$; hence $P_{n,k,q}(r)$ decays exponentially in the number of columns $n$.*

### 4.3 Moments of the number of sections

Let $N$ be the number of global sections, with $N = 0$ when the database fails to glue.

**Theorem 4.8 (First moment).** $\mathbb{E}[N] = (q A^{k})^{n}$, *and consequently the Markov bound $P_{n,k,q}(r) \le \mathbb{E}[N]$.*

The per-column expectation is $\sum_S w(S) \cdot \#\{\text{completions of that column}\}$; a column with $|S| \ge 1$ contributes $1$ when consistent and $0$ otherwise, a column with $S = \varnothing$ contributes $q$; the sum evaluates to $qA^{k}$ without the empty-pattern correction, which is exactly the difference between $\mathbb{E}[N]$ and $P$.

**Theorem 4.9 (Second moment).** $\mathbb{E}[N^{2}] = \big(qA^{k} + (q^{2}-q)\,r^{k}\big)^{n}$.

*Proof sketch.* For a column with at least one observation, $N$ restricted to that column is $\{0,1\}$-valued, so $N^{2} = N$ there; only the empty pattern differs, contributing $q^{2}$ instead of $q$. The per-column second-moment factor is thus $qA^{k} + (q^{2} - q)r^{k}$; independence across columns gives the $n$-th power. $\square$

Write $u = qA^{k}$ and $v = (q-1)r^{k}$, so that $P = (u - v)^{n}$, $\mathbb{E}[N] = u^{n}$, $\mathbb{E}[N^{2}] = (u + qv)^{n}$.

**Theorem 4.10 (Second-moment / Paley–Zygmund bound).** *For $q \ge 1$, $r \in [0,1]$,*
$$\frac{\mathbb{E}[N]^{2}}{\mathbb{E}[N^{2}]} \;\le\; P_{n,k,q}(r) \;\le\; \mathbb{E}[N].$$

*Proof sketch.* It suffices to prove the per-column inequality $u^{2} \le (u-v)(u+qv)$, i.e. $0 \le q(q-1)^{2} r^{k}\big(A^{k} - r^{k}\big)$, which holds because $r \le A$. Raising to the $n$-th power and dividing yields the claim. $\square$

**Theorem 4.11 (Tightness).** *The lower bound is an equality at $r = 0$ (for $k \ge 1$) and at $r = 1$, and is strict for $q \ge 2$, $k \ge 1$, $n \ge 1$ and $0 < r < 1$.*

Equality holds exactly when $v = 0$ (that is, $r = 0$) or $A^{k} = r^{k}$ (that is, $r = 1$ or $q = 1$). The sandwich $\mathbb{E}[N]^{2}/\mathbb{E}[N^{2}] \le P \le \mathbb{E}[N]$ therefore pins the law between two computable quantities and is exactly tight at both ends of the missing-rate range.

---

## 5. The difficulty parameter: a binomial tail

The exact law answers "how likely", but a threshold statement needs a single scalar. This section identifies it.

### 5.1 Where the binomial coefficient belongs

A column fails the sheaf condition exactly when *some pair* of its rows is observed with different values. A union bound over the $\binom{k}{2}$ pairs suggests a per-column failure probability at most $\binom{k}{2}(1-\frac1q)(1-r)^{2}$. This is a theorem.

**Theorem 5.1 (Pair union bound).** *For $q \ge 1$ and $r \in [0,1]$,*
$$1 - \beta(k,q,r) \;\le\; \binom{k}{2}\Big(1 - \frac1q\Big)(1-r)^{2}.$$

*Proof sketch.* Write $g(k) = 1 - \beta(k,q,r)$ and $a = 1 - 1/q$. The increment satisfies $g(k+1) - g(k) = (1-r)(q-1)(A^{k} - r^{k})$, and the elementary inequality $x^{k} - y^{k} \le k(x - y)$ for $0 \le y \le x \le 1$ with $x = A$, $y = r$, $A - r = (1-r)/q$ gives $g(k+1) - g(k) \le k\,a\,(1-r)^{2}$. Summing the arithmetic progression yields $\binom{k}{2}a(1-r)^{2}$. $\square$

**Theorem 5.2 (Two rows: exact).** *For $k = 2$ and $q \ge 1$,*
$$\beta(2,q,r) = 1 - \Big(1-\frac1q\Big)(1-r)^{2}, \qquad P_{n,2,q}(r) = \Big(1 - \big(1-\tfrac1q\big)(1-r)^{2}\Big)^{n}.$$

So the union bound is an equality at $k = 2$: the failure event is exactly "both rows observed and differing". This is the correct home of the binomial coefficient of conjecture (C1): it counts *pairs of rows*, it appears as a *linear factor* rather than an exponent, and it multiplies $(1-r)^{2}$ rather than $(1-r)$.

**Corollary 5.3.** $P_{n,k,q}(r) \ge 1 - n\binom{k}{2}(1-\frac1q)(1-r)^{2}$, *and, when the pair bound is at most $1$, the sharper $P_{n,k,q}(r) \ge \big(1 - \binom{k}{2}(1-\frac1q)(1-r)^{2}\big)^{n}$.*

Thus databases with many columns still glue with high probability as long as $n k^{2}(1-r)^{2} \to 0$: the row count enters quadratically and the missing rate through $(1-r)^{2}$.

### 5.2 The weighted tail identity

The pair bound is one-sided. To make it two-sided one must find the exact quantity being bounded.

**Definition 5.4 (Binomial tail).** With observation rate $p = 1-r$, set
$$\mathrm{tail}(k,r) = \sum_{j=2}^{k}\binom{k}{j} p^{\,j} r^{\,k-j} \;=\; \Pr\big[\mathrm{Bin}(k,p) \ge 2\big] \;=\; 1 - r^{k} - k(1-r)r^{\,k-1},$$
the probability that at least two of the $k$ rows observe a given column.

**Theorem 5.5 (Weighted tail identity).** *For every $k$ and $q \ge 1$,*
$$1 - \beta(k,q,r) \;=\; \sum_{j=2}^{k}\binom{k}{j}(1-r)^{j} r^{\,k-j}\big(1 - q^{\,1-j}\big).$$

*Proof sketch.* Expand $\beta$ binomially: $\beta = \sum_{j=0}^{k}\binom{k}{j}p^{j}r^{k-j}q^{1-j} - (q-1)r^{k}$, while $1 = \sum_{j}\binom{k}{j}p^{j}r^{k-j}$. Subtracting termwise, the $j = 1$ term cancels identically because $q \cdot q^{-1} = 1$, and the $j = 0$ term $r^{k}(1 - q)$ is cancelled exactly by the correction $+(q-1)r^{k}$. Only $j \ge 2$ survives, with weights $1 - q^{1-j}$. $\square$

Interpretation: only observation patterns with at least two observed rows can break the sheaf condition, and such a pattern breaks it with probability exactly $1 - q^{1-j}$.

### 5.3 The sandwich and the threshold

The weights $1 - q^{1-j}$ for $j \ge 2$ satisfy $1 - \frac1q \le 1 - q^{1-j} \le 1$, since $q^{1-j} = q \cdot q^{-j} \le q \cdot q^{-2} = 1/q$ and $q^{1-j} \ge 0$. Substituting into Theorem 5.5 gives the central estimate of this section.

**Theorem 5.6 (Tail sandwich).** *For $q \ge 1$ and $r \in [0,1]$,*
$$\Big(1 - \frac1q\Big)\,\mathrm{tail}(k,r) \;\le\; 1 - \beta(k,q,r) \;\le\; \mathrm{tail}(k,r).$$

The two bounds differ only by the factor $1 - 1/q$, which is $\ge 1/2$ for $q \ge 2$ and $\to 1$ for large alphabets. Hence the binomial tail determines the per-column failure probability up to an absolute constant, and *nothing finer than the tail is needed*.

**Corollary 5.7 (Two-sided law).**
$$\big(1 - \mathrm{tail}(k,r)\big)^{n} \;\le\; P_{n,k,q}(r) \;\le\; \Big(1 - \big(1 - \tfrac1q\big)\mathrm{tail}(k,r)\Big)^{n}.$$

**Corollary 5.8 (Threshold bounds).**
$$P_{n,k,q}(r) \;\le\; \exp\!\Big(-n\big(1-\tfrac1q\big)\mathrm{tail}(k,r)\Big), \qquad P_{n,k,q}(r) \;\ge\; 1 - n\,\mathrm{tail}(k,r).$$

The upper bound follows from $1 - x \le e^{-x}$; the lower from Bernoulli's inequality. Together they give a genuine phase transition:

> $P_{n,k,q}(r) \to 1$ when $n\cdot\mathrm{tail}(k,r) \to 0$, and $P_{n,k,q}(r) \to 0$ when $n \cdot \mathrm{tail}(k,r) \to \infty$.

**The difficulty parameter of a random database is $n\cdot\mathrm{tail}(k,r)$, and the transition occurs at $n\cdot\mathrm{tail}(k,r) \asymp 1$.**

### 5.4 Reconciliation with the pair bound

**Proposition 5.9.** *For $k \ge 2$ and $r \in [0,1]$,*
$$\binom{k}{2}(1-r)^{2} r^{\,k-2} \;\le\; \mathrm{tail}(k,r) \;\le\; \binom{k}{2}(1-r)^{2}.$$

The upper bound is the union bound; the lower bound is simply the $j = 2$ term of the defining sum. So in the *sparse* regime, where $r$ is close to $1$ and $r^{k-2} \approx 1$, the pair count $\binom{k}{2}$ is sharp to within the factor $r^{k-2}$, and the difficulty parameter really is $\asymp n k^{2}(1-r)^{2}$.

**Remark 5.10 (Why the truncation is essential).** In the *dense* regime — $k$ large, $r$ fixed in $(0,1)$ — the tail approaches $1$ while $k^{2}(1-r)^{2}$ diverges. A conjectured equivalence $1 - \beta \asymp \min\{1, k^{2}(1-r)^{2}\}$ therefore requires the truncation at $1$; the honest, uniformly valid statement is Theorem 5.6, in terms of the tail itself. This is the precise sense in which the tail, and not $k^{2}(1-r)^{2}$, is *the* free variable.

---

## 6. Čech cohomology of the data sheaf: acyclicity

We now ask whether cohomology can see imputation difficulty. Fix a field $\Bbbk$ and take the *linear* data sheaf $\mathcal{F}(V) = \{f : \text{columns} \to \Bbbk \mid f|_{V^{c}} = 0\}$, with restriction the obvious projection. Given a finite cover $U_{1}, \dots, U_{k}$ of the column set, the ordered Čech complex is
$$C^{0} = \bigoplus_{j} \mathcal{F}(U_{j}) \xrightarrow{\;d^{0}\;} C^{1} = \bigoplus_{j < j'} \mathcal{F}(U_{j} \cap U_{j'}) \xrightarrow{\;d^{1}\;} \cdots,$$
$(d^{0}s)_{jj'} = s_{j'}|_{U_j \cap U_{j'}} - s_{j}|_{U_j \cap U_{j'}}$.

**Theorem 6.1 (Degree zero).** *The kernel of $d^{0}$ is exactly the image of the map sending a complete record $f$ to the family $(f|_{U_{j}})_{j}$, and this map is injective when the $U_{j}$ cover; hence $H^{0} \cong \Bbbk^{n}$, of dimension the number of columns.*

**Theorem 6.2 (Acyclicity).** *For every finite cover, $H^{1} = 0$.*

*Proof sketch.* The data sheaf is *flasque*: every section over a subset extends to the whole space by zero. Concretely, choose for each column $c$ an index $\sigma(c)$ with $c \in U_{\sigma(c)}$. Given a cocycle $(t_{jj'})$ satisfying the cocycle condition, define $s_{j}(c) = t_{\sigma(c)\,j}(c)$ for $c \in U_j$ and $0$ otherwise. The cocycle relation gives $s_{j'} - s_{j} = t_{jj'}$ on overlaps, so every cocycle is a coboundary. $\square$

**Corollary 6.3.** *In the rank formalism $\dim H^{1} = \dim C^{1} - \operatorname{rank} d^{0} - \operatorname{rank} d^{1}$, the data sheaf gives a genuine rank identity with $\dim H^{1} = 0$ for every cover.*

**Discussion.** Together with Theorem 3.1 this closes the cohomological question for raw records. "Imputation is a sheaf cohomology problem" is true *only in degree zero*: $H^{0}$ is the space of complete databases, and $H^{1}$ vanishes identically, so no cohomological quantity can serve as a difficulty measure. The only obstruction is failure of pairwise consistency, which is not cohomological but combinatorial. A nonvanishing $H^{1}$ demands coefficients with nontrivial restriction maps — which is exactly what the next section supplies.

---

## 7. Calibration: where the obstruction actually lives

### 7.1 The calibration sheaf

In practice the hard part of integrating data sources is not blank cells but *systematic offsets*: unit conventions, instrument biases, baseline shifts. Model this as follows. There are $V$ data sources. On the overlap of two sources one does not observe records but the additive offset $t_{ab} \in \Bbbk$ needed to reconcile them. A *recalibration* is an assignment $s : V \to \Bbbk$ of a correction to each source, and it explains the observed offsets iff
$$s_{a} - s_{b} = t_{ab} \quad\text{for every recorded overlap } a\text{–}b.$$

This is precisely a degree-one Čech problem for the sheaf of offsets: $d^{0}$ is the map $s \mapsto (s_{a} - s_{b})_{\text{overlaps}}$, the observed offsets form a $1$-cochain, and the question "is the family realizable?" is "is it a coboundary?".

### 7.2 The three-source cycle

**Theorem 7.1 (Holonomy criterion).** *Let three sources $0,1,2$ overlap pairwise, with empty triple overlap. A family of offsets $(t_{01}, t_{12}, t_{20})$ is realizable by per-source recalibrations if and only if its holonomy vanishes:*
$$t_{01} + t_{12} + t_{20} = 0.$$

*Proof sketch.* Necessity: summing $s_{0} - s_{1}$, $s_{1} - s_{2}$, $s_{2} - s_{0}$ telescopes to $0$. Sufficiency: set $s_{0} = 0$, $s_{1} = -t_{01}$, $s_{2} = -t_{01} - t_{12}$; the third equation is exactly the holonomy condition. $\square$

**Corollary 7.2 (An unfixable inconsistency).** *The offset family $(1,0,0)$ is not realizable. Every pairwise comparison is individually consistent, yet no assignment of per-source corrections reconciles them.*

**Theorem 7.3.** *For the three-source cyclic nerve, $\dim H^{1} = 1$, over any field and in any characteristic — the first cohomology of a circle.*

### 7.3 The general nerve

Model the integration problem as a finite *multigraph* — the **nerve** — with vertex set $V$ (the sources) and an indexed family $E : \iota \to V \times V$ of oriented overlaps (multiple comparisons of the same pair are allowed). The calibration coboundary is $(d s)_{i} = s_{(E i)_{1}} - s_{(E i)_{2}}$.

**Theorem 7.4 (Nerve Betti theorem).** *Let $c$ be the number of connected components of the nerve. Then over any field, in any characteristic,*
$$\dim H^{1} + |V| = |\iota| + c, \qquad\text{i.e.}\qquad \dim H^{1} = b_{1}(\text{nerve}) = |\iota| - |V| + c.$$

*Proof sketch.* Two steps. (i) *Kernel.* $s \in \ker d$ iff $s$ is constant along every overlap, hence constant on every class of the equivalence relation generated by the overlaps; pulling back along the quotient map is an injective linear map from $\Bbbk^{c}$ onto $\ker d$, so $\dim \ker d = c$ and $\operatorname{rank} d^{0} = |V| - c$. (ii) *Rank–nullity.* $\dim H^{1} = \dim C^{1} - \operatorname{rank} d^{0} - \operatorname{rank} d^{1} = |\iota| - (|V| - c) - 0$. $\square$

**Corollary 7.5 (Connected case).** *For a connected nerve, $\dim H^{1} = |\iota| - |V| + 1$.*

**Corollary 7.6 (Forest criterion).** *The calibration problem is solvable for every prescribed family of offsets if and only if the nerve is a forest, i.e. $|\iota| + c = |V|$.*

**Examples.**
- **Cycle on $m$ sources.** $|\iota| = |V| = m$, $c = 1$, so $\dim H^{1} = 1$ for every $m \ge 1$ — independent of the number of sources, of the field, and of its characteristic. The explicit criterion is again holonomy: prescribed offsets around the cycle are realizable iff their total sum vanishes.
- **Star on $m+1$ sources.** A hub compared with every spoke, no spoke–spoke comparison: $|\iota| = m$, $|V| = m+1$, $c = 1$, so $\dim H^{1} = 0$. The star is a tree; calibration never obstructs. This is the design principle behind "reference standard" architectures.
- **Theta graph.** Two sources compared through three independent overlaps: $|\iota| = 3$, $|V| = 2$, $c = 1$, so $\dim H^{1} = 2$. **Redundant comparisons, not missing data, create obstructions.**

The moral is that the number of independent unfixable inconsistencies in a multi-source integration problem is a *topological invariant of the comparison pattern*: it is unaffected by the missing rate, by the number of features, and by the amount of data.

### 7.4 Triple overlaps lower the obstruction

Suppose some triples of sources genuinely share records. A triple overlap of $a, b, c$, compared through overlaps $i : a\text{–}b$, $j : b\text{–}c$, $l : a\text{–}c$, imposes the cocycle relation
$$t_{i} + t_{j} = t_{l},$$
the offset along the diagonal must equal the composite along the two sides. Collecting these relations defines a second coboundary $d^{1}$ on the space of offset families.

**Proposition 7.7 ($d^{1} \circ d^{0} = 0$).** *Genuine recalibrations automatically satisfy the triple-overlap relations, so the extended sequence is a complex.*

**Theorem 7.8 (Rank formula with triples).**
$$\dim H^{1} + |V| + \operatorname{rank} d^{1} = |\iota| + c.$$

**Corollary 7.9.** $\dim H^{1} \le b_{1}(\text{nerve graph})$, *with equality iff $\operatorname{rank} d^{1} = 0$. Adding triple overlaps can only destroy obstructions, never create them.*

*Proof sketch.* $\operatorname{rank} d^{0} = |V| - c$ is unchanged by the additional layer, so every unit of $\operatorname{rank} d^{1}$ removes one unit of $\dim H^{1}$; the graph formula of Theorem 7.4 is the special case $d^{1} = 0$. $\square$

**Theorem 7.10 (Filling a triangle kills the obstruction).** *For the three-source cyclic comparison, the open triangle has $\dim H^{1} = 1$ while the filled triangle (the same three comparisons together with the triple-overlap relation) has $\dim H^{1} = 0$.*

Indeed $|\iota| = |V| = 3$, $c = 1$, and $\operatorname{rank} d^{1} = 1$, so $\dim H^{1} = 3 + 1 - 3 - 1 = 0$. The relevant cohomology is that of the nerve *complex*, not of its $1$-skeleton. Operationally: one record shared by all three sources is worth more than any amount of pairwise reconciliation.

---

## 8. Algorithms

The theory yields four algorithms, all elementary and all with the complexity one would hope for.

**Algorithm A: gluability test and sheaf imputation.** Scan the table once, maintaining for each column the first observed value; report failure on the first disagreement. Otherwise output the completion using observed values where available and a default (or the marginal distribution) on wholly unobserved columns. **Complexity $O(nk)$**, one pass, $O(n)$ working memory. By Theorem 3.1 this is a complete decision procedure; by Theorem 3.3 the number of completions is $q^{u}$, computed in the same pass.

**Algorithm B: exact and asymptotic sheaf probability.** Evaluate $\beta = qA^{k} - (q-1)r^{k}$ and return $\beta^{n}$, together with the tail $1 - r^{k} - k(1-r)r^{k-1}$, the sandwich $(1-\mathrm{tail})^{n} \le P \le (1 - (1-1/q)\mathrm{tail})^{n}$, and the threshold statistic $n\cdot\mathrm{tail}$. **Complexity $O(\log k + \log n)$** with fast exponentiation. Numerically one works in log-space for large $n$.

**Algorithm C: nerve Betti number and obstruction dimension.** Given the list of sources and overlaps, compute connected components with a disjoint-set structure, then return $|\iota| - |V| + c$. **Complexity $O((|V| + |\iota|)\,\alpha(|V|))$** with union–find. If triple overlaps are supplied, compute $\operatorname{rank} d^{1}$ by Gaussian elimination on the $\#\text{triples} \times |\iota|$ relation matrix and subtract; total $O(|\iota|^{2}\cdot\#\text{triples})$ in the worst case.

**Algorithm D: calibration solving with holonomy certificate.** Build a spanning forest of the nerve; assign $s$ by propagating offsets along tree edges from an arbitrary root in each component (this is forced up to one constant per component). Then check every non-tree overlap: if $s_{a} - s_{b} \ne t_{ab}$, the fundamental cycle of that overlap is an explicit **holonomy certificate** of non-realizability. **Complexity $O(|V| + |\iota|)$.** By Theorem 7.4 the number of independent certificates is exactly $b_{1}$, and by Corollary 7.6 there are none precisely when the nerve is a forest.

---

## 9. Applications and discussion

**Do not expect sheaf imputation to beat mean imputation on a flat table.** Theorem 3.6 makes this precise: on gluable real-valued data the two coincide identically. There is no experiment to run. The value of the sheaf viewpoint on a single table lies elsewhere — in Theorem 3.3, which says the completion count is $q^{u}$ and thus locates all remaining uncertainty at the wholly unobserved columns, and in Theorem 3.1, which gives an $O(nk)$ certificate of consistency or an explicit witness of failure.

**Design your comparison graph as a tree.** Corollary 7.6 is actionable: if the graph of "which sources did we cross-validate against which" is a forest, then *any* pattern of observed offsets can be explained by per-source recalibrations. Every cycle you add is a potential unfixable inconsistency, and the theta example shows that comparing the same two sources three independent ways gives *two* independent obstructions. Reference-standard architectures (a star) are optimal from this point of view: $b_1 = 0$ by construction.

**When you must have cycles, look for triple overlaps.** Corollary 7.9 says triple overlaps can only reduce the obstruction, and Theorem 7.10 exhibits a case where a single triple overlap annihilates it entirely. In practice: a small set of records seen by three sources simultaneously is a disproportionately valuable calibration asset.

**The right sample-size heuristic.** The threshold statistic is $n \cdot \Pr[\mathrm{Bin}(k, 1-r) \ge 2]$, not the missing rate and not the feature count alone. In the sparse regime this reduces to $n k^{2}(1-r)^{2}$ up to constants (Proposition 5.9), but in the dense regime it saturates and the tail must be used directly (Remark 5.10).

**Beware the sign.** More missing data makes the sheaf condition *easier*, not harder (Theorem 4.5). Any diagnostic that treats consistency-checking as a proxy for data quality is measuring the wrong thing: a table that glues trivially may simply be empty. The informative statistic is not "does it glue" but "does it glue *given* how many pairwise overlaps it actually had", which is exactly the content of the weighted tail identity.

**Limitations.** The exact law of Theorem 4.3 assumes cellwise independent MCAR masking with independent uniform values; correlated columns or informative missingness change the per-column factor, though the factorization over columns survives whenever columns are independent. The acyclicity theorem concerns the constant (flasque) data sheaf; sheaves with nontrivial restriction maps — quotient sheaves, constraint sheaves, sheaves of consistency relations — are exactly where a genuinely cohomological imputation theory could live, and the calibration sheaf is one instance. The nerve results assume additive (torsor-like) offsets; multiplicative or affine calibration groups would give nonabelian $H^{1}$, a set rather than a vector space, with the Betti-number formula replaced by something subtler.

---

## 10. Future directions

**Nonabelian calibration.** Replace additive offsets by an arbitrary group $G$ of transformations (affine recalibrations, orthogonal frame changes). The obstruction becomes a nonabelian $H^{1}$, a pointed set; one wants the analogue of the forest criterion and a computable invariant replacing $b_{1}$.

**Higher nerves.** Theorem 7.8 handles triples. The full simplicial nerve should give $\dim H^{1}$ equal to the first Betti number of the *nerve complex*, and a hierarchy of higher obstructions $H^{2}, H^{3}$ measuring failures of consistency among quadruples of sources.

**Non-constant data sheaves.** Identify a class of sheaves — for example, sheaves of affine constraints among features — for which sheaf imputation provably improves on mean imputation, with a quantitative rate. Theorem 3.6 shows precisely where such a theorem cannot live, which is useful guidance.

**Correlated missingness.** Extend the exact law to masks with column correlations, or to missing-not-at-random mechanisms. The per-column factorization is the key structural assumption; determining exactly how much dependence it tolerates is open.

**Sharp threshold constant.** Corollaries 5.7 and 5.8 pin the transition to $n\cdot\mathrm{tail} \asymp 1$ with a constant gap of $1 - 1/q$. Is there a sharp threshold, i.e. a critical constant $\kappa(q)$ with $P \to 1$ below $\kappa$ and $P \to 0$ above? The exact law suggests the answer is $\beta^{n} = e^{n\log\beta}$ with $\log\beta \approx -(1-\beta)$, hence a threshold at $n(1-\beta) = 1$; making this uniform in $k, q, r$ is a limiting-regime question.

**Obstruction-aware pipeline design.** Given a budget of pairwise comparisons and triple-overlap acquisitions, minimize the expected obstruction dimension. Corollaries 7.6 and 7.9 make this a well-posed combinatorial optimization: it is a matroid problem on the cycle space of the nerve.

---

## 11. Conclusion

Reading a database as a sheaf is a clarifying move, but the clarification runs opposite to the direction one expects. For a single table with missing entries, the sheaf apparatus proves that there is nothing to gain: gluing is pairwise consistency, the completions are counted by the blank columns, mean imputation already returns the sheaf value, and the cohomology vanishes for every cover. These are theorems, not failures to find a method.

What the apparatus does yield is quantitative and topological. Quantitatively, the sheaf condition of a random table holds with probability exactly $(qA^{k} - (q-1)r^{k})^{n}$ — exponential in the number of features and increasing in the missing rate — and its difficulty is governed by the single parameter $n\cdot\Pr[\mathrm{Bin}(k,1-r)\ge 2]$, squeezed between two bounds a factor $1-1/q$ apart. Topologically, the obstruction to reconciling many data sources is neither statistical nor a function of missingness: it is the first Betti number of the graph of comparisons, reduced by the rank of the triple-overlap relations. Cycles in your integration pipeline, not holes in your table, are what cannot be repaired.
