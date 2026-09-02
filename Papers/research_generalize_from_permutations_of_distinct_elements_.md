# The Multinomial Erasure Ledger: Information, Entropy and Landauer Cost of Sorting Multisets

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

Sorting $n$ pairwise distinct items is a many-to-one map that collapses $n!$ inputs onto a single output, and therefore erases exactly $\log_2(n!)$ bits — the quantity underlying both the comparison-sort lower bound and, via Landauer's principle, the minimum heat dissipated by any physical sorter. We generalise this ledger from permutations to **multisets with repeated keys**. Modelling an input as a key word $w$ assigning to each of $n$ slots a key from a finite alphabet with multiplicities $m_1,\dots,m_r$, we prove by orbit–stabiliser over the Young subgroup the division-free identity $|\mathrm{Rearr}(w)|\cdot\prod_i m_i! = n!$, hence that the number of distinguishable inputs is the multinomial coefficient $n!/\prod_i m_i!$ and the erased information is its binary logarithm. This yields an exact conservation law $\log_2(n!) = \log_2\!\big(n!/\prod_i m_i!\big) + \sum_i \log_2(m_i!)$ splitting the classical baseline into the erasure a multiset sorter performs and the intra-block order it never observes, together with the corresponding Landauer identity and a strict discount whenever a key repeats. We then bound the ledger information-theoretically. A one-line argument — evaluate the multinomial theorem at the empirical distribution $p_i=m_i/n$ and retain a single term — gives the **Shannon ceiling** $\log_2\!\big(n!/\prod_i m_i!\big)\le nH(p)$ with no Stirling estimate, and the presence of a *second* positive term in the same expansion upgrades it to a strict inequality whenever two distinct keys occur. We complement this with the crude alphabet ceiling $n\log_2 r$, the classical binary-entropy corollary $\log_2\binom{a+b}{a}\le a\log_2\frac{a+b}{a}+b\log_2\frac{a+b}{b}$, a **data-processing law** showing that coarsening the key alphabet can only decrease erasure and heat, an exact **merge ledger** $E(A\sqcup B)=E(A)+E(B)+\log_2\binom{n+n'}{n}$ identifying the interleaving pattern as the sole extra cost of concatenation, and the refined decision-tree bound $d\ge\lceil\log_q(n!/\prod_i m_i!)\rceil$ together with its tightness and its reversible-history counterpart. We close with the one gap that resists the present method — the matching lower bound $nH(p)-O(r\log n)$, which reduces to a mode-rigidity statement for multinomial terms on the antidiagonal.

**Keywords:** multiset sorting, multinomial coefficient, Shannon entropy, Landauer's principle, orbit–stabiliser, data-processing inequality, comparison lower bounds, reversible computation.

---

## 1. Introduction

### 1.1 The factorial baseline

Let $f : X \to Y$ be a function between finite sets. The *erased information* of $f$ is

$$
E(f) \;=\; \log_2 \frac{|X|}{|f(X)|},
$$

the number of bits of input identity that cannot be recovered from the output. When $f$ has a single-point image this is simply $\log_2|X|$. Landauer's principle attaches a thermodynamic price: any physical realisation of $f$ operating at temperature $T$ must dissipate at least

$$
W(f) \;=\; kT\ln 2 \cdot E(f)
$$

joules of heat, where $k$ is Boltzmann's constant; equivalently, a *reversible* realisation must retain at least $|X|/|f(X)|$ distinguishable history states.

Applied to sorting $n$ pairwise distinct items, $X$ is the set of $n!$ input orders, $Y$ is a single point, and one obtains the familiar

$$
E = \log_2(n!), \qquad W = kT\ln(n!).
$$

The same count drives the classical comparison lower bound: a decision tree of depth $d$ with $q$-ary branching separates at most $q^d$ inputs, so $d \ge \lceil \log_q(n!)\rceil$.

### 1.2 The problem: ties

The factorial baseline presumes that all $n!$ input orders are *distinguishable*, i.e. that the items carry pairwise distinct keys. Practical sorting almost never satisfies this: keys repeat, often massively. Two items with equal keys are, from the point of view of the sorting task, the same item; interchanging them produces literally the same input. The correct count of distinguishable inputs is then not $n!$ but the number of *distinct arrangements of a multiset*, and every downstream quantity — erased information, Landauer work, comparison lower bound, reversible history size — must be recomputed.

This paper carries out that recomputation and then studies its information-theoretic structure. Section 2 fixes the model. Section 3 proves the multinomial count and the exact conservation law. Section 4 develops the refined complexity and thermodynamic bounds. Section 5 establishes the Shannon ceiling and its strictness. Section 6 gives the coarsening (data-processing) law. Section 7 gives the merge ledger. Section 8 records worked instances. Section 9 discusses the outstanding lower bound and further directions.

---

## 2. The model

Throughout, $\alpha$ is a finite set of **slots** with $|\alpha| = n$, and $\iota$ is a finite set of **keys** with $|\iota| = r$.

**Definition 2.1 (Key word).** A *key word* is a function $w : \alpha \to \iota$; $w(a)$ is the key carried by slot $a$.

**Definition 2.2 (Multiplicity).** For a key $i \in \iota$, the *multiplicity* is $m_i := |w^{-1}(i)|$, the number of slots carrying key $i$.

Partitioning $\alpha$ into the fibres of $w$ gives at once:

**Lemma 2.3 (Multiplicities sum to $n$).** $\sum_{i \in \iota} m_i = n$.

**Definition 2.4 (Rearrangements).** The set of *distinguishable inputs* of $w$ is

$$
\mathrm{Rearr}(w) \;=\; \{\, w \circ \sigma \;:\; \sigma \in \mathfrak{S}_\alpha \,\} \subseteq \iota^\alpha ,
$$

the orbit of $w$ under the natural right action of the symmetric group on the slots.

The definition encodes the modelling decision precisely: two labellings of the slots by keys are the *same input* if and only if they are equal as functions. Permuting slots that carry equal keys does not produce a new input. Note $w \in \mathrm{Rearr}(w)$ (take $\sigma = \mathrm{id}$), so $\mathrm{Rearr}(w) \neq \emptyset$.

**Definition 2.5 (The multiset sorting map).** The *multiset sorting map* of $w$ is the constant map
$$
S_w : \mathrm{Rearr}(w) \longrightarrow \{\ast\},
$$
reflecting that all rearrangements of a fixed key multiset possess the same sorted output. Its erased information is $E(S_w) = \log_2 |\mathrm{Rearr}(w)|$ and its Landauer work is $W(S_w) = kT\ln 2\cdot E(S_w)$.

---

## 3. The multinomial count and the conservation law

### 3.1 Orbit–stabiliser over the Young subgroup

**Lemma 3.1 (Stabiliser count).** The set of permutations fixing $w$,
$$
\mathrm{Stab}(w) = \{\sigma \in \mathfrak{S}_\alpha : w\circ\sigma = w\},
$$
is the Young subgroup $\prod_{i\in\iota}\mathfrak{S}_{w^{-1}(i)}$, of order $\prod_i m_i!$.

*Proof sketch.* $w\circ\sigma = w$ says exactly that $\sigma$ preserves every fibre $w^{-1}(i)$ setwise. A permutation of $\alpha$ preserving each fibre is the same datum as an independent permutation of each fibre, whence the group is the direct product $\prod_i \mathfrak{S}_{w^{-1}(i)}$ and its order is $\prod_i m_i!$. $\square$

**Lemma 3.2 (Fibres are cosets).** For every $\tau\in\mathfrak{S}_\alpha$, the fibre $\{\sigma : w\circ\sigma = w\circ\tau\}$ has the same cardinality as $\mathrm{Stab}(w)$.

*Proof sketch.* The mutually inverse bijections $\sigma\mapsto\sigma\tau^{-1}$ and $\sigma\mapsto\sigma\tau$ exchange the two sets: $w\circ\sigma = w\circ\tau$ iff $w\circ(\sigma\tau^{-1}) = w$. $\square$

**Theorem 3.3 (Division-free orbit–stabiliser).**
$$
|\mathrm{Rearr}(w)| \cdot \prod_{i\in\iota} m_i! \;=\; n! .
$$

*Proof sketch.* Count the group $\mathfrak{S}_\alpha$, of order $n!$, by fibres of the surjection $\sigma \mapsto w\circ\sigma$ onto $\mathrm{Rearr}(w)$. By Lemmas 3.1 and 3.2 every fibre has exactly $\prod_i m_i!$ elements, so $n! = |\mathrm{Rearr}(w)|\cdot\prod_i m_i!$. $\square$

The division-free form is worth stating separately: it is an identity in the natural numbers, requires no positivity side conditions, and immediately yields the divisibility $\prod_i m_i! \mid n!$.

**Theorem 3.4 (The number of distinguishable inputs is the multinomial coefficient).**
$$
|\mathrm{Rearr}(w)| \;=\; \binom{n}{m_1,\dots,m_r} \;=\; \frac{n!}{m_1!\cdots m_r!}.
$$

*Proof sketch.* The multinomial coefficient is characterised by $\binom{n}{m_1,\dots,m_r}\prod_i m_i! = (\sum_i m_i)!$, which by Lemma 2.3 is $n!$. Cancel the positive factor $\prod_i m_i!$ against Theorem 3.3. $\square$

### 3.2 The erasure ledger

**Theorem 3.5 (Erased information of multiset sorting).**
$$
E(S_w) \;=\; \log_2\!\left(\frac{n!}{\prod_i m_i!}\right).
$$

*Proof sketch.* The image of $S_w$ is a single point, so $E(S_w)=\log_2|\mathrm{Rearr}(w)|$; apply Theorem 3.4. $\square$

**Theorem 3.6 (Conservation of the erasure ledger).**
$$
\log_2(n!) \;=\; E(S_w) \;+\; \sum_{i\in\iota}\log_2(m_i!).
$$

*Proof sketch.* Take $\log_2$ of Theorem 3.3, using that logarithms convert the product $|\mathrm{Rearr}(w)|\cdot\prod_i m_i!$ into a sum; all factors are positive integers. $\square$

Interpretation: the distinct-key baseline splits *exactly* into (i) the information a multiset sorter genuinely destroys and (ii) the information contained in the orders *within* each block of equal keys, which such a sorter never acquires and hence never erases. Nothing is lost or invented in the split.

**Theorem 3.7 (Landauer conservation).** For every $kT$,
$$
kT\ln(n!) \;=\; W(S_w) \;+\; \sum_{i\in\iota} kT\ln(m_i!), \qquad W(S_w) = kT\ln\!\left(\frac{n!}{\prod_i m_i!}\right).
$$

### 3.3 Degenerate regimes and the strict discount

**Proposition 3.8 (Distinct keys).** If $w$ is injective then every $m_i\le 1$, so $|\mathrm{Rearr}(w)| = n!$ and $E(S_w) = \log_2(n!)$: the classical baseline is recovered exactly.

**Proposition 3.9 (One repeated key).** If $w$ is constant then $\mathrm{Rearr}(w) = \{w\}$ and $E(S_w) = 0$: sorting a constant multiset erases nothing and is thermodynamically free.

**Theorem 3.10 (Strict repetition discount).** If some key satisfies $m_{i_0}\ge 2$ then
$$
|\mathrm{Rearr}(w)| < n!, \qquad E(S_w) < \log_2(n!), \qquad W(S_w) < kT\ln(n!)\ \ (kT>0).
$$
More precisely, the guaranteed savings are quantified:
$$
E(S_w) + \log_2(m_{i_0}!) \;\le\; \log_2(n!).
$$

*Proof sketch.* $\prod_i m_i! \ge m_{i_0}! \ge 2$, so Theorem 3.3 forces $|\mathrm{Rearr}(w)| \le n!/2$; monotonicity and strict monotonicity of $\log_2$ give the two displayed inequalities. The quantified form isolates the $i_0$-term of the conservation law (Theorem 3.6) and discards the remaining non-negative terms. $\square$

In words: a key repeated $m_{i_0}$ times permanently removes $\log_2(m_{i_0}!)$ bits from the erasure account, and the corresponding heat $kT\ln(m_{i_0}!)$ is never dissipated by any sorter of that multiset.

---

## 4. Refined complexity and reversibility bounds

**Definition 4.1 (Radix-$q$ multiset sorter of depth $d$).** A *correct radix-$q$, depth-$d$ multiset sorter* for $w$ is a map
$$
\mathrm{tr} : \mathrm{Rearr}(w) \longrightarrow \{0,\dots,q-1\}^{d}
$$
assigning to each distinguishable input the transcript of its $d$ queries, such that $\mathrm{tr}$ is injective (the transcript determines the input).

Injectivity is exactly correctness: a sorter that cannot separate two distinguishable inputs from its transcript cannot in general produce the right output-with-provenance for both.

**Theorem 4.2 (Counting bound).** Any correct radix-$q$ depth-$d$ multiset sorter satisfies
$$
\frac{n!}{\prod_i m_i!} \;\le\; q^{d}.
$$

*Proof sketch.* Injectivity gives $|\mathrm{Rearr}(w)| \le |\{0,\dots,q-1\}^d| = q^d$; apply Theorem 3.4. $\square$

**Corollary 4.3 (Multiset comparison lower bound).** For $q\ge 2$,
$$
d \;\ge\; \left\lceil \log_q \frac{n!}{\prod_i m_i!} \right\rceil .
$$

**Theorem 4.4 (Tightness).** For every $q\ge 2$ there exists a correct radix-$q$ multiset sorter of depth exactly $\lceil \log_q (n!/\prod_i m_i!)\rceil$.

*Proof sketch.* With $d = \lceil\log_q(n!/\prod_i m_i!)\rceil$ one has $|\mathrm{Rearr}(w)| \le q^d$, so an injection $\mathrm{Rearr}(w)\hookrightarrow\{0,\dots,q-1\}^d$ exists; any such injection is a correct sorter. $\square$

Corollary 4.3 with Theorem 4.4 says that the multinomial logarithm is not merely a lower bound but the *exact* information-theoretic query complexity of the abstract task. It strictly improves the classical $\lceil\log_q(n!)\rceil$ whenever a key repeats.

**Theorem 4.5 (Physical work lower bound for sorters).** If a correct radix-$q$ depth-$d$ sorter exists and each fully erased query register is charged $kT\ln q$, then for $kT\ge 0$,
$$
W(S_w) \;\le\; d\cdot kT\ln q .
$$

*Proof sketch.* Take logarithms in Theorem 4.2 and multiply by $kT$. $\square$

**Theorem 4.6 (Reversible history bound).** If a reversible implementation realises $S_w$ as a bijection $\mathrm{Rearr}(w)\;\simeq\;\{\ast\}\times \mathrm{Aux}$ onto output-plus-auxiliary states, then
$$
|\mathrm{Aux}| \;\ge\; \frac{n!}{\prod_i m_i!}.
$$

*Proof sketch.* The second projection of the bijection is injective on $\mathrm{Rearr}(w)$, so $|\mathrm{Rearr}(w)|\le|\mathrm{Aux}|$. $\square$

This is the multinomial refinement of Bennett's history bound: the ties you never resolve are exactly the history you never have to store.

---

## 5. The Shannon ceiling

We now bound the ledger by the *statistics* of the key word rather than its combinatorics.

**Definition 5.1 (Empirical key distribution).** $p_i := m_i/n$ for $i\in\iota$. By Lemma 2.3, $\sum_i p_i = 1$ and $p_i \ge 0$.

**Definition 5.2 (Shannon entropy and entropy budget).**
$$
H(p) \;=\; -\sum_{i} p_i\log_2 p_i, \qquad
B(w) \;=\; \sum_i m_i\log_2\frac{n}{m_i},
$$
with the usual convention that terms with $m_i = 0$ vanish.

**Lemma 5.3 (The budget is $n$ times the entropy).** $B(w) = n\,H(p)$.

*Proof sketch.* Termwise: for $m_i>0$, $m_i\log_2(n/m_i) = -n\cdot p_i\log_2 p_i$ since $p_i = m_i/n$; terms with $m_i=0$ vanish on both sides. $\square$

### 5.1 A single multinomial term is at most one

**Lemma 5.4 (Term bound).** Let $m$ be any multiplicity vector with $\sum_i m_i = n \ge 1$ and $p_i = m_i/n$. Then
$$
\binom{n}{m_1,\dots,m_r}\prod_{i} p_i^{\,m_i} \;\le\; 1 .
$$

*Proof sketch.* The multinomial theorem expands
$$
\Big(\sum_i p_i\Big)^{n} \;=\; \sum_{\substack{k:\ \sum_i k_i = n}} \binom{n}{k_1,\dots,k_r}\prod_i p_i^{\,k_i},
$$
the sum being over the antidiagonal of vectors of non-negative integers summing to $n$. Since $\sum_i p_i = 1$, the left-hand side equals $1$. Every summand is non-negative, and $m$ lies on the antidiagonal, so the single summand indexed by $k = m$ is at most the whole sum, namely at most $1$. $\square$

This is the entire analytic content of the ceiling. No Stirling formula and no asymptotic estimate is used; the inequality is exact for every finite $n$ and $r$.

**Theorem 5.5 (Entropy ceiling for the multinomial coefficient).** For $n\ge 1$ and $\sum_i m_i = n$,
$$
\ln \binom{n}{m_1,\dots,m_r} \;\le\; \sum_i m_i \ln\frac{n}{m_i},
\qquad\text{equivalently}\qquad
\log_2 \frac{n!}{\prod_i m_i!} \;\le\; \sum_i m_i \log_2\frac{n}{m_i}.
$$

*Proof sketch.* Take logarithms in Lemma 5.4. The left side becomes $\ln\binom{n}{m}+\sum_i m_i\ln(m_i/n)$, all factors being strictly positive (terms with $m_i=0$ contribute $\ln 1 = 0$), and $m_i\ln(m_i/n) = -m_i\ln(n/m_i)$. Rearranging against $\ln 1 = 0$ gives the claim. $\square$

**Theorem 5.6 (The Shannon ceiling).** For a non-empty slot set,
$$
E(S_w) \;\le\; B(w) \;=\; n\,H(p)\ \text{ bits.}
$$

**Corollary 5.7 (Landauer form).** For $kT\ge 0$,
$$
W(S_w) \;\le\; kT\ln 2\cdot n\,H(p).
$$

Physically: the heat that sorting a multiset must dissipate is bounded by the Shannon entropy of the data's own key statistics, times the number of items, times $kT\ln 2$ per bit.

### 5.2 Strictness

The same expansion that gives the ceiling also shows it is never attained by genuinely mixed data.

**Definition 5.8 (Unit shift).** For $i\ne j$ with $m_i>0$, let $m^{i\to j}$ be $m$ with one unit moved from $i$ to $j$: $(m^{i\to j})_i = m_i-1$, $(m^{i\to j})_j = m_j+1$, and $(m^{i\to j})_l = m_l$ otherwise.

**Lemma 5.9.** If $i\ne j$ and $m_i>0$ then $m^{i\to j}$ has the same total $n$ and $m^{i\to j}\ne m$.

**Theorem 5.10 (Strict Shannon ceiling).** If two *distinct* keys $i\ne j$ both occur ($m_i>0$ and $m_j>0$), then
$$
\ln\binom{n}{m_1,\dots,m_r} \;<\; \sum_l m_l\ln\frac{n}{m_l}, \qquad\text{hence}\qquad E(S_w) \;<\; n\,H(p),
$$
and for $kT>0$, $W(S_w) < kT\ln 2 \cdot nH(p)$.

*Proof sketch.* In the expansion of $1 = (\sum_i p_i)^n$ used in Lemma 5.4, consider two distinct summands: the one at $k=m$ and the one at $k = m^{i\to j}$. Both indices lie on the antidiagonal (Lemma 5.9) and are distinct. Because $m_i>0$ and $m_j>0$, both $p_i$ and $p_j$ are strictly positive; every coordinate $l$ with $k_l>0$ in either index has $p_l>0$, so both terms are *strictly* positive (multinomial coefficients are always positive). A sum of non-negative terms equal to $1$ containing two strictly positive terms forces each of them to be strictly less than $1$. Applying this to the term at $k=m$ and taking logarithms as in Theorem 5.5 gives the strict inequality. $\square$

Thus the ceiling is an honest, never-tight bound for any multiset with at least two distinct keys present. The size of the gap is, asymptotically, the $O(r\log n)$ Stirling correction; making that quantitative is the open problem of §9.

### 5.3 Two secondary ceilings

**Theorem 5.11 (Alphabet ceiling).** $|\mathrm{Rearr}(w)| \le r^{\,n}$, hence $E(S_w)\le n\log_2 r$.

*Proof sketch.* $\mathrm{Rearr}(w)\subseteq \iota^\alpha$, a set of size $r^n$; apply monotonicity of $\log_2$. $\square$

Since $H(p)\le\log_2 r$ with equality only for the uniform distribution, the Shannon ceiling always dominates the alphabet ceiling; the two are consistent bounds on the same quantity, with the entropy version strictly better for non-uniform key statistics.

**Corollary 5.12 (Binary entropy bound).** For $a,b\ge 0$ with $a+b>0$,
$$
\log_2\binom{a+b}{a} \;\le\; a\log_2\frac{a+b}{a} + b\log_2\frac{a+b}{b}
\;=\; (a+b)\,h\!\left(\frac{a}{a+b}\right),
$$
where $h(x) = -x\log_2 x-(1-x)\log_2(1-x)$ is the binary entropy function.

*Proof sketch.* Specialise Theorem 5.5 to $r=2$, $m = (a,b)$, using $\binom{a+b}{a,b} = \binom{a+b}{a}$. $\square$

This recovers, with an entirely elementary proof, the standard estimate underpinning type counting, Chernoff-style bounds and the source-coding heuristic $\binom{n}{pn}\approx 2^{nh(p)}$.

---

## 6. Coarsening: a data-processing law for keys

Let $\kappa$ be a second finite key alphabet, $w' : \alpha\to\kappa$ a key word, and $g : \kappa\to\iota$ an arbitrary map — a *coarsening*, merging keys of $\kappa$ that $g$ identifies. The coarsened word is $g\circ w'$.

**Lemma 6.1 (Rearrangements commute with coarsening).**
$$
\{\, g\circ v \;:\; v\in\mathrm{Rearr}(w')\,\} \;=\; \mathrm{Rearr}(g\circ w').
$$

*Proof sketch.* Both sides are the set of words $g\circ w'\circ\sigma$ for $\sigma$ ranging over $\mathfrak{S}_\alpha$: for "$\subseteq$", a rearrangement $v = w'\circ\sigma$ maps to $g\circ w'\circ \sigma$; for "$\supseteq$", $(g\circ w')\circ\sigma = g\circ(w'\circ\sigma)$ with $w'\circ\sigma\in\mathrm{Rearr}(w')$. $\square$

**Theorem 6.2 (Data-processing inequality for keys).**
$$
|\mathrm{Rearr}(g\circ w')| \;\le\; |\mathrm{Rearr}(w')|,
$$
hence
$$
E(S_{g\circ w'}) \;\le\; E(S_{w'}) \qquad\text{and}\qquad W(S_{g\circ w'}) \le W(S_{w'})\ \ (kT\ge 0).
$$

*Proof sketch.* By Lemma 6.1 the left set is an image of the right set under $v\mapsto g\circ v$, and images do not increase cardinality; monotonicity of $\log_2$ transfers the inequality to erased information and, scaling by $kT\ln 2$, to Landauer work. $\square$

The result deserves its name. In information theory, the data-processing inequality says post-processing cannot increase information about a source. Here, post-processing the *keys* — deliberately refusing to distinguish some of them — cannot increase the number of distinguishable inputs, hence cannot increase the erasure or the heat. Distinguishability is never manufactured by forgetting.

Note the direction is genuinely one-sided and can be strict: the word $AABBC$ over three keys has $5!/(2!2!1!) = 30$ rearrangements, while merging $C$ into $B$ yields $AABBB$ with $5!/(2!3!) = 10$: the coarsening removes $\log_2 3 \approx 1.585$ bits of erasure.

---

## 7. The merge ledger

Concatenation is the operation dual to coarsening. Let $w:\alpha\to\iota$ and $w':\beta\to\kappa$ be key words over **disjoint** slot sets and **disjoint** key alphabets, with $|\alpha| = n$ and $|\beta| = n'$. Their *union word* $w\sqcup w' : \alpha\amalg\beta \to \iota\amalg\kappa$ sends slots of $\alpha$ to keys of $\iota$ via $w$ and slots of $\beta$ to keys of $\kappa$ via $w'$.

**Lemma 7.1 (Multiplicities of the union word).** The multiplicity vector of $w\sqcup w'$ is the concatenation $m\oplus m'$: keys of $\iota$ keep their multiplicities in $w$, keys of $\kappa$ keep theirs in $w'$.

**Lemma 7.2 (Merge identity for multinomial coefficients).**
$$
\binom{n+n'}{m\oplus m'} \;=\; \binom{n+n'}{n}\binom{n}{m}\binom{n'}{m'} ,
$$
where $\binom{n}{m}$ denotes $\binom{n}{m_1,\dots,m_r}$.

*Proof sketch.* Both sides equal $(n+n')!/\big(\prod_i m_i!\prod_j m'_j!\big)$: expand $\binom{n+n'}{n} = (n+n')!/(n!\,n'!)$ and cancel $n!$ and $n'!$ against the two block multinomials. $\square$

**Theorem 7.3 (Merge count).**
$$
|\mathrm{Rearr}(w\sqcup w')| \;=\; \binom{n+n'}{n}\cdot|\mathrm{Rearr}(w)|\cdot|\mathrm{Rearr}(w')| .
$$

**Theorem 7.4 (Merge ledger).**
$$
E(S_{w\sqcup w'}) \;=\; E(S_w) + E(S_{w'}) + \log_2\binom{n+n'}{n},
$$
and correspondingly
$$
W(S_{w\sqcup w'}) \;=\; W(S_w) + W(S_{w'}) + kT\ln\binom{n+n'}{n}.
$$

*Proof sketch.* Combine Theorem 3.4, Lemma 7.1 and Lemma 7.2 to get the count (Theorem 7.3), then take logarithms of the three positive factors. $\square$

**Corollary 7.5 (Superadditivity).** $\log_2\binom{n+n'}{n}\ge 0$, hence
$$
E(S_w) + E(S_{w'}) \;\le\; E(S_{w\sqcup w'}).
$$

The extra term has a clean reading: it is exactly the information in the **interleaving pattern**, i.e. which of the $\binom{n+n'}{n}$ ways the two blocks are shuffled together. This is the information-theoretic content of the classical fact that merging two sorted lists of lengths $n$ and $n'$ requires about $\log_2\binom{n+n'}{n}$ comparisons — here obtained not as an algorithmic estimate but as an exact term in a conservation law. Together with §6 the picture is symmetric: merging *keys* strictly decreases erasure; merging *lists* increases it by exactly the interleaving entropy.

---

## 8. Worked instances

**8.1 The word $AABB$** ($n=4$, $r=2$, $m = (2,2)$).

- Distinguishable inputs: $4!/(2!\,2!) = 6$.
- Orbit–stabiliser: $6\cdot(2!\cdot 2!) = 24 = 4!$. ✓
- Erased information: $\log_2 6 \approx 2.5850$ bits, versus baseline $\log_2 24\approx 4.5850$ bits.
- Conservation: $\log_2 24 = \log_2 6 + \log_2 2! + \log_2 2! = 2.5850 + 1 + 1$. ✓
- Entropy budget: $p = (1/2,1/2)$, $H(p) = 1$, so $nH(p) = 4$ bits.
- Strict ceiling: $2.5850 < 4$. ✓ (Gap $1.415$ bits.)
- Alphabet ceiling: $n\log_2 r = 4$ bits, here equal to the entropy ceiling because $p$ is uniform.
- Comparison bound: $\lceil\log_2 6\rceil = 3$ comparisons, versus $\lceil\log_2 24\rceil = 5$ for four distinct items.

**8.2 Coarsening $AABBC \to AABBB$** ($n=5$).

- $AABBC$: $m = (2,2,1)$, $5!/(2!2!1!) = 30$ inputs, $E = \log_2 30\approx 4.9069$ bits.
- Merge the third key into the second: $m = (2,3)$, $5!/(2!3!) = 10$ inputs, $E = \log_2 10\approx 3.3219$ bits.
- $10 \le 30$: the data-processing inequality, here strict, with a saving of $\log_2 3\approx 1.585$ bits.

**8.3 Merge ledger.** Take $A$ with $n=2$ and one repeated key ($|\mathrm{Rearr}| = 1$, $E=0$) and $B$ with $n'=3$ distinct keys ($|\mathrm{Rearr}| = 6$, $E = \log_2 6$). Concatenating gives $\binom{5}{2}\cdot 1\cdot 6 = 60$ inputs and $E = \log_2 60 = 0 + \log_2 6 + \log_2 10$. ✓

**8.4 The extremes.** Five distinct keys: $5!/1 = 120$ inputs, $E = \log_2 120\approx 6.9069$, matching the classical baseline. Five equal keys: $5!/5! = 1$ input, $E = 0$, and the Landauer cost vanishes identically.

---

## 9. Discussion and future directions

### 9.1 What the ledger buys

Three consequences are worth isolating.

1. **A sharper classical bound with matching achievability.** The $\lceil\log_q(n!)\rceil$ comparison bound is replaced by $\lceil\log_q(n!/\prod_i m_i!)\rceil$, which is *attained* by an abstract sorter (Theorem 4.4). Algorithms that outperform $n\log n$ on repetitive data — counting sort, radix sort, three-way partitioning quicksort variants — are not violating an information bound; they are living beneath a smaller one, and the multinomial logarithm says exactly how much smaller.

2. **Thermodynamics of low-entropy data.** Corollary 5.7 states that the unavoidable heat of a multiset sort is at most $kT\ln 2\cdot nH(p)$ and, by Theorem 5.10, strictly below that ceiling. Sorting data whose keys have low empirical entropy is not merely faster — it is physically cooler, with a bound depending only on the key statistics and not on the algorithm.

3. **A structural calculus.** Erasure is monotone under key coarsening (Theorem 6.2) and exactly additive-plus-interleaving under concatenation (Theorem 7.4). This makes the erasure function a well-behaved invariant of the *coarseness* of the data, not just of its size.

### 9.2 The missing floor

The Shannon ceiling is proved and proved strict, but its matching lower bound,
$$
n\,H(p) - O(r\log n) \;\le\; \log_2\frac{n!}{\prod_i m_i!},
$$
does not follow from the present single-term argument. The obstruction is precise. The expansion $1 = \sum_{k} T(k)$ with $T(k)=\binom{n}{k}\prod_i p_i^{k_i}$ over the antidiagonal has at most $\binom{n+r-1}{r-1}\le (n+1)^{r}$ terms; if one knew that $T(m)$ is the *largest* of them, then $T(m)\ge 1/(n+1)^{r}$ and taking logarithms would give exactly the desired floor with the $r\log_2(n+1)$ correction. So the entire missing ingredient is a mode-rigidity statement.

**Conjecture 9.1 (Antidiagonal mode rigidity).** For $p_i = m_i/n$, the term $T(k) = \binom{n}{k}\prod_i p_i^{k_i}$ is maximised over all $k$ with $\sum_i k_i = n$ precisely at $k=m$; consequently
$$
n\,H(p) - r\log_2(n+1) \;\le\; \log_2\frac{n!}{\prod_i m_i!} \;\le\; n\,H(p).
$$

The route is a local exchange argument: moving one unit of multiplicity from coordinate $i$ to coordinate $j$ multiplies the term by
$$
\frac{T(k^{i\to j})}{T(k)} \;=\; \frac{k_i\, p_j}{(k_j+1)\, p_i},
$$
a ratio that is $\ge 1$ exactly when $k_i/p_i \ge (k_j+1)/p_j$. Maximality at $m$ therefore reduces to a finite, purely local comparison, and can be propagated along a shortest exchange path from an arbitrary $k$ to $m$. Establishing this converts the ceiling into a two-sided asymptotic identity and turns the Landauer bound into an equality up to $O(r\log n)$ bits: *the heat of sorting is the entropy of the data*.

### 9.3 The coarsening lattice

Theorem 6.2 is the order-preservation half of what looks like a much richer structure.

**Conjecture 9.2 (Polymatroidality of erasure).** For fixed $n$, the assignment sending a set partition $P$ of the slot set to the erasure value $E(P) = \log_2(n!/\prod_{B\in P}|B|!)$ is a strictly monotone map from the refinement lattice of partitions into the reals — refinement strictly increases erased information except for splits off singletons — and satisfies the submodularity inequality
$$
E(P\vee Q) + E(P\wedge Q) \;\le\; E(P) + E(Q).
$$

If true, $E$ is the rank function of a polymatroid on the partition lattice, and submodularity would follow structurally rather than by direct computation. Submodularity itself is a finite inequality among multinomial coefficients and is attackable directly.

### 9.4 Further directions

- **Streaming and adaptive settings.** If the multiplicities are unknown in advance, the erasure ledger becomes a random variable; the natural question is whether the expected erasure over a random key word from a source of entropy $H$ concentrates around $nH$ with $O(r\log n)$ fluctuation.
- **Stable versus unstable sorting.** A *stable* sorter preserves the relative order of equal keys, so it must in fact retain the $\sum_i\log_2(m_i!)$ bits that the multiset ledger refunds. The conservation law (Theorem 3.6) is exactly the statement that stability costs precisely the intra-block entropy — a clean quantitative account of the folklore trade-off.
- **Beyond total orders.** Rearrangement counts under groups other than the full symmetric group (e.g. sorting networks with restricted connectivity, or partially ordered key alphabets) would replace the Young subgroup by other stabilisers, and the multinomial coefficient by other orbit counts, with the conservation law surviving verbatim as orbit–stabiliser.

---

## 10. Summary of results

| Result | Statement |
|---|---|
| Orbit–stabiliser | $\lvert\mathrm{Rearr}(w)\rvert\cdot\prod_i m_i! = n!$ |
| Multinomial count | $\lvert\mathrm{Rearr}(w)\rvert = n!/\prod_i m_i!$ |
| Erasure | $E(S_w) = \log_2\big(n!/\prod_i m_i!\big)$ |
| Conservation | $\log_2(n!) = E(S_w) + \sum_i\log_2(m_i!)$ |
| Strict discount | $m_{i_0}\ge2 \Rightarrow E(S_w) + \log_2(m_{i_0}!)\le\log_2(n!)$, strictly below baseline |
| Query complexity | $d\ge\lceil\log_q(n!/\prod_i m_i!)\rceil$, attained |
| History bound | any reversible realisation retains $\ge n!/\prod_i m_i!$ states |
| Shannon ceiling | $E(S_w)\le nH(p)$; $W \le kT\ln2\cdot nH(p)$ |
| Strictness | two distinct keys present $\Rightarrow E(S_w) < nH(p)$ |
| Alphabet ceiling | $E(S_w)\le n\log_2 r$ |
| Binary corollary | $\log_2\binom{a+b}{a}\le a\log_2\frac{a+b}{a}+b\log_2\frac{a+b}{b}$ |
| Coarsening | $E(S_{g\circ w'})\le E(S_{w'})$ |
| Merge ledger | $E(S_{w\sqcup w'}) = E(S_w)+E(S_{w'})+\log_2\binom{n+n'}{n}$ |

