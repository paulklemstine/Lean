# The Blindness–Sparsity Dichotomy for Plug-In Information Readings

## Sparse views, powerless permutation nulls, and an exact zero on swap-closed samples

**Author:** Aristotle
**Date:** 2026-09-23

---

## Abstract

We study the empirical ("plug-in") mutual information $\hat I(\ell, c)$ between a categorical label $\ell$ and a categorical *view* $c$ computed on a finite sample of size $n$, in the regime where the view is fine-grained relative to the sample — the regime in which nearly all feature-leakage screening is actually performed. We prove four things.

First, a **collision sandwich**: with $C$ the number of samples that share their view value with at least one other sample, the reading obeys
$$H(\ell) - \tfrac{C}{n}\log_2|L| \;\le\; \hat I(\ell,c) \;\le\; H(\ell),$$
and in the fully injective case $C=0$ the reading equals $H(\ell)$ *identically*, whatever the relationship between label and view. Second, because a label permutation preserves both the label margin and the fiber sizes, the **entire permutation null** of the statistic is confined to the same band: observed value, every surrogate and the null mean pairwise differ by at most $\frac{C}{n}\log_2|L|$, so a shuffle test on a sufficiently fine view has provably no resolution. Third, we prove a **refinement monotonicity** theorem — a data-processing inequality for the plug-in functional on empirical contingency tables, derived from the log-sum inequality with no distributional hypothesis — showing that a finer "hint" view always reads at least as much as any coarsening of it, with the gain bounded by the coarse view's collision term. Fourth, and centrally, we prove the **blindness–sparsity dichotomy**: on a *swap-closed* sample — one carrying a fixed-point-free involution along which the view is constant and the label flips — the empirical contingency table is an exact product table, so $\hat I(\ell,c)=0$ exactly, while simultaneously the collision fraction is exactly $1$, so the sandwich is vacuous. Contrapositively, a sample whose view fails to collide even once cannot be swap-closed. The exact-blindness regime and the sparse-reading regime are disjoint.

Applied to a factor-leakage screening programme, the consequence is decisive: a flagged reading of $0.9663$ bits on a factor-residue hint view, whose $200$-shuffle permutation null had mean $0.9648$ and standard deviation $0.0011$ ($z=+1.36$), is entirely sparse plug-in inflation. A companion sharpening replaces the alphabet factor $\log_2|L|$ by the fiber sizes, giving $H(\ell)-\hat I \le \frac1n\sum_{f_k\ge2} f_k\log_2 f_k$ and, for views injective on unordered pairs, a **one-bit window** $H(\ell)-1\le \hat I\le H(\ell)$ independent of the alphabet.

**Keywords:** plug-in mutual information, estimator bias, permutation test, collision fraction, data-processing inequality, log-sum inequality, involution symmetry, factor blindness.

---

## 1. Introduction

### 1.1 The screening problem

A recurring computational-statistics task takes the following shape. One has a population of structured objects, each carrying a hidden binary attribute $\ell$ that one hopes is *not* recoverable, and a family of computable summaries $c_1, c_2, \dots$ — "views" — of the same objects. The question is whether any view leaks the attribute.

The canonical instance, and the one motivating this paper, is factor-leakage screening. The objects are ordered pairs of distinct primes $(p,q)$; the attribute $\ell$ is a which-factor bit (for instance, whether the first coordinate is the smaller prime); and the views are cheap functions of the pair or of their product — the product residue $N \bmod m$ for a small modulus $m$, hint views built from factor residues such as a coded pair $(s,d)$ of a sum statistic and a difference statistic, and various joint labellings. If some view leaks the which-factor bit, that is a structural fact about the arithmetic worth knowing; if none does, the negative result is worth certifying.

The standard instrument is the plug-in (maximum-likelihood, "naive") mutual information between the label and the view, calibrated against a permutation null obtained by shuffling the labels. The purpose of this paper is to show that in the regime where these screens are typically run — fine views, moderate samples — both the statistic and its calibration are *structurally incapable of answering the question*, and to prove exactly when the alternative, exact-zero argument applies.

### 1.2 The empirical observation

A screening battery run on prime pairs reported, for three nested-looking views, the readings and $200$-shuffle nulls shown below.

| view | observed (bits) | null mean | null sd | $z$ |
|---|---|---|---|---|
| product view $N \bmod 713$ | $0.0153$ | $0.0162$ | $0.0008$ | $-1.04$ |
| $(s,d)$ hint view | $0.9663$ | $0.9648$ | $0.0011$ | $+1.36$ |
| joint labels | $0.0011$ | $0.0008$ | $0.0002$ | $+1.44$ |

Two features demand explanation. (i) The hint view's reading of $0.9663$ bits is nearly the full label entropy, an order of magnitude above the other two views, and was initially interpreted as the hint view "seeing more". (ii) Its permutation null reproduces the reading to within $0.0015$ bits, i.e. the number survives the complete destruction of label information by shuffling. Every view sits inside its own null.

A second, controlled run on $n = 3906$ ordered pairs of $63$ primes in $(50,2000)$ produced the complementary picture: the product view $N \bmod 713$ realised $639$ distinct codes with observed reading exactly $0.0000$ against a null mean of $0.1363$ (sd $0.0070$); the $(s,d)$ view realised exactly $1953 = n/2$ distinct codes — one per unordered pair — with observed $0.0000$ against a null mean of $0.4990$; a coarse residue view realised $3$ codes with observed $0.0000$ against null mean $0.0004$. Here the nulls sit *above* the data, and the observed readings are exactly zero.

The theory below accounts for all of it.

### 1.3 Contributions

1. A non-asymptotic, distribution-free sandwich pinning the plug-in reading to the label entropy within the collision fraction (Theorem 3.4), with an exact identity in the injective limit (Theorem 3.5).
2. A proof that the permutation null is confined to the same band (Theorems 4.1–4.3) and hence that a permutation test on a fine view has no resolution (Theorem 4.4).
3. A sharpening replacing the alphabet factor by realised fiber sizes (Theorem 5.2), yielding a one-bit window for pair-collision views (Theorem 5.3).
4. A data-processing inequality for the plug-in functional on empirical tables (Theorem 6.2), and the resulting bound on hint-refinement gain (Theorem 6.3), with a strictness witness (Proposition 6.4).
5. The blindness–sparsity dichotomy (Theorems 7.4–7.6): swap-closed samples have collision fraction exactly $1$ and reading exactly $0$; non-colliding samples are not swap-closed.

---

## 2. Setting and definitions

Throughout, $n \ge 1$ is the sample size, $L$ is a finite label alphabet and $K$ a finite view alphabet, both with decidable equality. A *labelled sample* is a pair of functions
$$\ell : \{1,\dots,n\} \to L, \qquad c : \{1,\dots,n\} \to K,$$
the *label* and the *view*. All logarithms written $\log_2$ are base two; entropies and informations are in bits.

**Definition 2.1 (Counts).** For $a\in L$ and $k \in K$ set
$$N_{a,k} \;=\; \#\{i : \ell_i = a \text{ and } c_i = k\}, \qquad
f_k \;=\; \#\{i : c_i = k\}, \qquad
m_a \;=\; \#\{i : \ell_i = a\}.$$
We call $N_{a,k}$ the *cell count*, $f_k$ the *fiber count* (the size of the fiber of the view over $k$) and $m_a$ the *label count*. Immediately $\sum_k N_{a,k} = m_a$, $\sum_a N_{a,k} = f_k$, $\sum_k f_k = n$ and $N_{a,k}\le f_k$.

**Definition 2.2 (Empirical table, margins, reading).** The *view table* is $\hat p(a,k) = N_{a,k}/n$. Its margins are $\hat p_L(a) = \sum_k \hat p(a,k) = m_a/n$ and $\hat p_K(k) = \sum_a \hat p(a,k) = f_k/n$. The *plug-in reading* is
$$\hat I(\ell,c) \;=\; \sum_{a\in L}\sum_{k \in K} \hat p(a,k)\,\log_2 \frac{\hat p(a,k)}{\hat p_L(a)\,\hat p_K(k)},$$
with the standard convention that terms with $\hat p(a,k)=0$ vanish. The entropy of a mass function $r$ is $H(r) = -\sum r(x)\log_2 r(x)$; we write $H(\ell) = H(a \mapsto m_a/n)$ for the empirical label entropy.

**Definition 2.3 (Collision count).** A sample index $i$ is *colliding* if its view value is shared: $f_{c_i} \ge 2$. The *collision count* is
$$C(c) \;=\; \#\{i : f_{c_i}\ge 2\} \;=\; \sum_{k \,:\, f_k \ge 2} f_k,$$
and $C(c)/n \in [0,1]$ is the *collision fraction*. The view is *injective on the sample* iff $C(c)=0$.

Two elementary facts about the reading are used repeatedly and hold for any nonnegative table $p$ summing to $1$:

**Lemma 2.4 (Entropy cap).** $\hat I \le H(\hat p_L)$, with the gap equal to the conditional entropy of the label given the view:
$$H(\hat p_L) - \hat I \;=\; \sum_{k}\sum_a -\,\hat p(a,k)\log_2\frac{\hat p(a,k)}{\hat p_K(k)} \;\ge\; 0 .$$

**Lemma 2.5 (Zero iff product).** $\hat I = 0$ if and only if the table factorises, $\hat p(a,k) = \hat p_L(a)\hat p_K(k)$ for all $a,k$; in particular, $\hat p_L(a)\,f_k = N_{a,k}\,$ scaled appropriately, i.e. $m_a f_k = N_{a,k}\, n$ for all $a,k$, is sufficient for a zero reading.

Both are consequences of Gibbs' inequality ($\log x \le x-1$) applied cell-wise; we use the "product $\Rightarrow$ zero" direction of Lemma 2.5 as the engine of Section 7.

---

## 3. The fiber decomposition and the collision sandwich

The whole of Sections 3–5 rests on one identity: the deficit of the reading below the label entropy is a fiber-weighted average of *within-fiber* label entropies.

**Lemma 3.1 (Per-fiber gap).** Fix $k$ with $f_k > 0$, and let $\rho_k(a) = N_{a,k}/f_k$ be the label distribution inside the fiber over $k$ — a genuine probability vector, since $\sum_a N_{a,k}=f_k$. Then
$$\sum_{a} -\,\hat p(a,k)\,\log_2\frac{\hat p(a,k)}{\hat p_K(k)} \;=\; \frac{f_k}{n}\,H(\rho_k).$$

*Proof sketch.* Write $\hat p(a,k) = (f_k/n)\rho_k(a)$ and $\hat p_K(k) = f_k/n$; the ratio inside the logarithm is exactly $\rho_k(a)$, and the prefactor $f_k/n$ pulls out of the sum. $\square$

Summing Lemma 3.1 over $k$ and comparing with Lemma 2.4:

**Proposition 3.2 (Fiber decomposition).**
$$H(\ell) - \hat I(\ell,c) \;=\; \sum_{k} \frac{f_k}{n}\,H(\rho_k).$$

**Corollary 3.3 (Singletons are free).** If $f_k \le 1$ then $\rho_k$ is a $0/1$ indicator, so $H(\rho_k)=0$ and the fiber contributes nothing to the deficit. Only *colliding* fibers can depress the reading below the label entropy.

Bounding each surviving term by $H(\rho_k)\le \log_2|L|$ and using $\sum_{f_k\ge2} f_k = C(c)$ gives the central inequality.

**Theorem 3.4 (The collision sandwich).** For every labelled sample with $n\ge 1$ and every view $c$,
$$H(\ell) \;-\; \frac{C(c)}{n}\,\log_2|L| \;\;\le\;\; \hat I(\ell, c) \;\;\le\;\; H(\ell).$$

The upper bound is Lemma 2.4; the lower bound is Proposition 3.2 with $H(\rho_k)\le\log_2|L|$ on colliding fibers and $0$ elsewhere. Note that *no assumption whatsoever* is made about the relationship between $\ell$ and $c$: the bound is an identity about counting, not about dependence.

**Theorem 3.5 (The injective limit).** If $C(c) = 0$ then $\hat I(\ell, c) = H(\ell)$ exactly, for every label function $\ell$.

This is the sharpest possible statement of sparse plug-in inflation. A view that assigns a distinct code to every sample reports the full label entropy whether or not it has any relationship to the label; the reading is a function of the label margin alone.

**Theorem 3.6 (The band is estimable from the data).** Let $d$ be the number of distinct view values realised on the sample. Then
$$C(c) \;\le\; 2\,(n - d).$$

*Proof sketch.* Partition the realised values into singletons ($f_k=1$, say $s$ of them) and colliding values ($f_k\ge2$, say $t$ of them), so $d=s+t$ and $n = s + C(c)$. Each colliding fiber has $f_k \ge 2$, so $C(c) = \sum_{f_k\ge2} f_k \ge 2t$, whence $t \le C(c)/2$ and $d = s+t \le (n - C(c)) + C(c)/2 = n - C(c)/2$. $\square$

Thus the sandwich width $\frac{C}{n}\log_2|L|$ can be certified from two numbers a screening pipeline already computes: the sample size and the number of distinct codes.

**Proposition 3.7 (The sandwich is tight).** A constant view on $n\ge2$ samples has $C(c) = n$, collision fraction $1$, and (for a balanced binary label) deficit exactly $H(\ell)$. Hence the factor $C/n$ cannot be improved in general; the factor $\log_2|L|$ is likewise attained at a balanced label margin within a single fiber.

---

## 4. The permutation null is trapped in the same band

The standard remedy for estimator bias is calibration: recompute the statistic on surrogates obtained by randomly permuting the labels, and report a $z$-score. We now show that this remedy is inert in exactly the regime that makes it necessary.

The key observation is a pair of invariances. Let $\pi$ be any permutation of the sample indices and let $\ell^\pi = \ell\circ\pi$ be the shuffled label.

**Lemma 4.0 (Permutation invariants).** For every $a$, the label count is preserved, $m_a(\ell^\pi) = m_a(\ell)$; and the view is untouched, so all fiber counts $f_k$ and the collision count $C(c)$ are preserved.

Consequently the sandwich of Theorem 3.4 applies to the surrogate with *identical* endpoints. Both readings lie in an interval of length $\frac{C}{n}\log_2|L|$, hence:

**Theorem 4.1 (Null band).** For every permutation $\pi$,
$$\bigl|\hat I(\ell^{\pi}, c) - \hat I(\ell, c)\bigr| \;\le\; \frac{C(c)}{n}\,\log_2|L|.$$

**Theorem 4.2 (The null has no range).** For every pair of permutations $\pi,\sigma$,
$$\bigl|\hat I(\ell^{\pi}, c) - \hat I(\ell^{\sigma}, c)\bigr| \;\le\; \frac{C(c)}{n}\,\log_2|L|.$$
Thus the observed reading and the whole of the permutation null lie in one common interval of that width.

**Theorem 4.3 ($z$-numerator bound).** Averaging Theorem 4.1 over the full symmetric group,
$$\left|\,\hat I(\ell,c) \;-\; \frac{1}{|\mathfrak S_n|}\sum_{\pi \in \mathfrak S_n} \hat I(\ell^\pi, c)\,\right| \;\le\; \frac{C(c)}{n}\,\log_2|L| .$$

*Proof sketch.* Write the difference as the average of the per-permutation differences and apply the triangle inequality termwise. $\square$

These assemble into the capstone of the section.

**Theorem 4.4 (The hinted view is blind).** Suppose the view's collision term is small, $\frac{C(c)}{n}\log_2|L| \le \delta$. Then
1. every surrogate reading is within $\delta$ of the observed reading,
2. any two surrogate readings are within $\delta$ of each other, and
3. the observed reading is within $\delta$ of the null mean.

A permutation test on such a view has no resolution at all: the number it reports is a measurement of the view's sparsity, not of the label's dependence on the view.

**Interpretation of the experimental table.** In a run on $n = 3995$ ordered prime pairs with $3597$ distinct four-field codes, Theorem 3.6 certifies $C \le 2(3995-3597) = 796$, so every reading — observed and all $200$ surrogates — is guaranteed to lie in $[H(\ell) - 0.1993,\, H(\ell)]$. The measured observed-minus-null gap was $0.0011$ bits: three orders of magnitude inside the guarantee, because the bound is worst-case. In the $(s,d)$ run of the introduction, $C = n$ exactly and the guarantee is the full band; the observed $z = +1.36$ against a null sd of $0.0011$ is exactly the behaviour of a statistic with no signal and a tiny, structurally-forced spread.

---

## 5. Sharpening: the fiber band

The alphabet factor $\log_2|L|$ in Theorem 3.4 is the worst case *inside* a fiber and is badly pessimistic for the fine views used in practice. A hint view built from factor traces is injective on unordered pairs, so its fibers have exactly two elements — and two samples cannot carry more than one bit of label entropy between them, however large the alphabet.

**Theorem 5.1 (Support entropy bound).** For any probability mass function $r$ on a finite set, $H(r) \le \log_2 \#\operatorname{supp}(r)$, where $\operatorname{supp}(r)=\{x : r(x) \ne 0\}$.

*Proof sketch.* Gibbs' inequality against the uniform measure on the support: $\sum_x r(x)\log_2\frac{r(x)}{u(x)} \ge 0$ with $u$ uniform on $\operatorname{supp}(r)$, and the cross term evaluates to $\log_2\#\operatorname{supp}(r)$. $\square$

Inside the fiber over $k$, at most $f_k$ distinct labels can occur, so $\#\operatorname{supp}(\rho_k) \le f_k$ and $H(\rho_k)\le \log_2 f_k$. Substituting in Proposition 3.2:

**Theorem 5.2 (The fiber-log band).** For every labelled sample and view,
$$H(\ell) - \hat I(\ell, c) \;\le\; \frac1n \sum_{k \,:\, f_k \ge 2} f_k \log_2 f_k .$$
The right-hand side makes no reference to the label alphabet.

**Theorem 5.3 (Pair-collision views: the one-bit window).** If no view value is shared by more than two samples, $f_k \le 2$ for all $k$, then
$$H(\ell) - \hat I(\ell, c) \;\le\; \frac{C(c)}{n} \;\le\; 1,$$
so $H(\ell) - 1 \le \hat I(\ell,c) \le H(\ell)$ regardless of the label alphabet and of the dependence.

*Proof sketch.* For $f_k = 2$ the term $f_k\log_2 f_k = 2$ equals $f_k$ itself, so the fiber-log sum collapses to $\sum_{f_k\ge2} f_k = C(c)$; and $C(c)\le n$ always. $\square$

**Corollary 5.4 (Pair-view null band).** Under the same hypothesis, every label-permuted surrogate reading is within $1$ bit of the observed reading.

**The experimental table, explained quantitatively.** In the controlled run the $(s,d)$ view realised exactly $1953 = n/2$ distinct codes on $n = 3906$ ordered pairs — one code per unordered pair, the signature of a view that factors through the unordered pair. Every fiber then has size exactly two and Theorem 5.3 applies with equality of the hypothesis: the reading is pinned within one bit of the label entropy. A reported hint-view reading of $4.56$ bits against a label entropy of $4.60$ is therefore *forced by fiber sizes*, not measured. By contrast, the product view $N\bmod 713$ realised $639$ codes with fibers up to size $16$, where Theorem 5.2 gives $\frac1n\sum f_k\log_2 f_k = 2.766$ bits — weaker than the binary-alphabet bound, but the only one of the two bounds that survives a large label alphabet. The two bounds are genuinely incomparable (for one fiber of size $n$, Theorem 5.2 returns $\log_2 n$, worse than $\log_2 |L|$ when $|L| < n$), and we keep both.

---

## 6. Refinement monotonicity: hint compounding is bias compounding

We now address the second interpretive trap: reading the *increase* from a coarse view to a finer hint view as evidence that the hint "sees more". The increase is forced.

Say a view $c$ is a *coarsening* of a view $c'$ if $c = \varphi \circ c'$ for some map $\varphi : K' \to K$; equivalently, $c'$ *refines* $c$. At the level of tables, coarsening aggregates columns:
$$(\Phi_\varphi p)(a,k) \;=\; \sum_{k' :\, \varphi(k') = k} p(a,k').$$

The analytic input is one inequality, proved from $\log x \le x-1$ alone.

**Theorem 6.1 (Log-sum inequality).** For finite families of nonnegative reals $(a_i)_{i\in S}$, $(b_i)_{i \in S}$,
$$\Bigl(\sum_{i\in S} a_i\Bigr)\log\frac{\sum_{i} a_i}{\sum_{i} b_i} \;\le\; \sum_{i\in S} a_i \log\frac{a_i}{b_i},$$
with the usual conventions for vanishing terms.

*Proof sketch.* Let $A=\sum a_i$, $B=\sum b_i$. Apply $\log t \le t - 1$ with $t = \frac{a_i B}{b_i A}$, multiply by $a_i$ and sum; the right-hand side telescopes to $A(\frac{B}{B} \cdot \frac{\sum a_i}{A}-1)\cdot$const $=0$ after cancellation, yielding $\sum_i a_i \log\frac{a_i B}{b_i A} \ge 0$, which rearranges to the claim. No normalisation of the families is required. $\square$

Applying Theorem 6.1 blockwise — index set the fiber $\varphi^{-1}(k)$, with $a_{k'} = p(a,k')$ and $b_{k'} = p_L(a)p_K(k')$ — gives a data-processing inequality for the plug-in functional on arbitrary nonnegative tables.

**Theorem 6.2 (Refinement monotonicity).** For every nonnegative table $p$ on $L \times K'$ and every map $\varphi : K'\to K$,
$$\hat I(\Phi_\varphi p) \;\le\; \hat I(p).$$
Aggregating columns can only decrease the plug-in reading. No distributional assumption is used; the statement is about empirical tables.

**Corollary 6.2' (Sample form).** For every sample, every view $c'$ and every post-processing $\varphi$,
$$\hat I(\ell,\ \varphi\circ c') \;\le\; \hat I(\ell,\ c').$$
Adding a hint never lowers the reported number.

Combining with the sandwich — the fine reading is at most $H(\ell)$, the coarse reading at least $H(\ell) - \frac{C(\varphi\circ c')}{n}\log_2|L|$ — gives the quantitative form.

**Theorem 6.3 (Hint compounding is bias compounding).** For every sample, view $c'$ and post-processing $\varphi$,
$$0 \;\le\; \hat I(\ell, c') - \hat I(\ell, \varphi\circ c') \;\le\; \frac{C(\varphi\circ c')}{n}\,\log_2|L| .$$
The gain from refining is nonnegative and no larger than the *coarse* view's collision term. Whatever a hint appears to add, the coarse view's sparsity deficit already accounted for it; no leakage claim can be extracted from the increase alone.

**Proposition 6.4 (Strictness witness).** Monotonicity is not vacuous. Take a balanced binary label and a view that copies it exactly; the reading is $1$ bit. Coarsening by the constant map to a one-point alphabet produces the table $\bigl(\tfrac12,\tfrac12\bigr)^{\mathsf T}$ on a single column, whose reading is $0$. Hence refinement strictly increases the reading on a population whose underlying dependence has not changed.

**A diagnostic remark on the experimental triple.** The reported readings $0.0153$ (product), $0.9663$ (hint) and $0.0011$ (joint labels) are *not* monotone as printed: the joint-label view reads less than the product view. By Theorem 6.2 this is impossible for genuinely nested views, so the three views were not nested as claimed — the joint-label view is a relabelling, not a refinement, of the product view. Where views are genuinely nested, the ordering is forced by the theorem and carries no information.

**Caveat.** Theorem 6.3 is informative only when the *coarse* view is itself near-injective. For a genuinely coarse view (few cells, many samples) the bound degrades to $H(\ell)$ — the honest statement, since a coarse view's deficit really can be filled by a refinement.

---

## 7. The blindness–sparsity dichotomy

Sections 3–6 explain why a large positive reading on a fine view is not evidence. There is a complementary, older half of the story which delivers an *exact zero*: a symmetric readout on a swap-closed, off-diagonal population leaks exactly $0$ which-factor bits. Numerically the two halves appear to collide — the exact reading is $0$, the sample reading of the hint view is $0.97$. This section shows they cannot collide, because their hypotheses are mutually exclusive.

### 7.1 Swap-closed samples

**Definition 7.1.** A labelled sample $(\ell, c)$ of size $n$ is **swap-closed** if there exists a permutation $\sigma$ of $\{1,\dots,n\}$ with
1. *(involution)* $\sigma(\sigma(i)) = i$ for all $i$;
2. *(fixed-point-free)* $\sigma(i) \ne i$ for all $i$;
3. *(view symmetry)* $c(\sigma(i)) = c(i)$ for all $i$;
4. *(label flip)* $\ell(\sigma(i)) \ne \ell(i)$ for all $i$.

For the motivating application with a binary label: the sample contains both $(p,q)$ and $(q,p)$ for every pair it contains, $\sigma$ is the swap, the view is a symmetric function of the pair so it cannot distinguish the two orders, and the which-factor bit does distinguish them. Condition 2 is load-bearing and is the sample-level replacement for off-diagonality: a fixed point would be a sample of the form $(p,p)$, on which the label cannot flip.

**Proposition 7.2 (Nonvacuity).** The hypotheses are satisfiable: the two-element sample $\{(p,q),(q,p)\}$ with the constant view, the label $\ell = (\mathtt{false}, \mathtt{true})$ and $\sigma$ the transposition satisfies all four conditions.

### 7.2 First half: total collision

**Lemma 7.3.** If $\sigma$ is fixed-point-free and the view is symmetric along $\sigma$, then every fiber has at least two elements: for every $i$, $f_{c_i} \ge 2$.

*Proof.* The fiber over $c_i$ contains $i$; it also contains $\sigma(i)$, because $c(\sigma(i)) = c(i)$; and $\sigma(i) \ne i$. Two distinct members. $\square$

**Theorem 7.4 (Total collision).** On a swap-closed sample, $C(c) = n$: *every* sample collides, and the collision fraction is exactly $1$.

Consequently the sandwich of Theorem 3.4 degenerates. For a binary label its statement becomes $H(\ell) - 1 \le \hat I \le H(\ell)$, which is content-free; Theorem 4.4 with $\delta = \log_2|L|$ likewise says nothing. **Where the sample is swap-closed, the collision machinery is vacuous.**

### 7.3 Second half: the exact zero

**Lemma 7.5 (Cell matching).** On a swap-closed sample with binary label, for every label value $b$ and every code $k$,
$$N_{b,k} \;=\; N_{\lnot b, k}.$$

*Proof sketch.* The map $i \mapsto \sigma(i)$ is a bijection from $\{i : \ell_i = b,\ c_i = k\}$ to $\{i : \ell_i = \lnot b,\ c_i = k\}$, with inverse itself. It lands in the target because $c(\sigma i) = c(i) = k$ and $\ell(\sigma i)\ne \ell(i)=b$ forces $\ell(\sigma i) = \lnot b$ for a binary label; and $\sigma\sigma = \mathrm{id}$ makes it a bijection. $\square$

**Corollary 7.5a (Even fiber split).** $2N_{b,k} = f_k$ for every $b,k$, since $N_{b,k}+N_{\lnot b,k} = f_k$.

**Corollary 7.5b (Balanced label margin).** Summing Corollary 7.5a over $k$ and using $\sum_k N_{b,k} = m_b$, $\sum_k f_k = n$: $2m_b = n$ for each label value $b$.

**Theorem 7.6 (Product table, hence exact zero).** On a swap-closed sample with a binary label and $n\ge 1$, for every $b, k$
$$m_b \cdot f_k \;=\; N_{b,k}\cdot n,$$
i.e. the empirical contingency table is exactly a product table, and therefore
$$\hat I(\ell,c) \;=\; 0$$
exactly — with no null calibration, no sensitivity floor and no asymptotics.

*Proof.* By Corollary 7.5a, $m_b f_k = m_b (2 N_{b,k}) = N_{b,k}(2m_b) = N_{b,k} n$ by Corollary 7.5b. Dividing by $n^2$ gives $\hat p_L(b)\hat p_K(k) = \hat p(b,k)$, so every logarithm in Definition 2.2 is $\log_2 1 = 0$ by Lemma 2.5. $\square$

This is the *sample-level* form of the population wall: the exact-zero statement, proved from the involution alone, with no probabilistic hypothesis and no limit.

### 7.4 The dichotomy

**Theorem 7.7 (Blindness–sparsity dichotomy).** Let $(\ell,c)$ be a swap-closed sample of size $n \ge 1$ with binary label. Then simultaneously
$$\hat I(\ell,c) = 0, \qquad C(c) = n, \qquad \frac{C(c)}{n}\log_2|L| = 1 .$$
The reading is exactly zero *and* the guaranteed band is the entire interval $[H(\ell)-1, H(\ell)]$.

**Theorem 7.8 (Disjointness of the regimes).** If $C(c) < n$ — if the view fails to collide on even one sample — then no fixed-point-free permutation leaves the view invariant, so the sample is **not** swap-closed.

*Proof.* Immediate contrapositive of Theorem 7.4. $\square$

The consequence for interpretation is complete. A sample whose reading is positive, or whose collision fraction is below $1$, is not swap-closed; its reading is governed by the sandwich, whose width in that regime is exactly what the reading reports. A sample which *is* swap-closed reads exactly $0$, and there the sandwich is vacuous. **The two halves of the programme never apply at once.** The $0.97$-bit hint-view reading therefore says nothing about leakage: it was taken in the regime where, by Theorem 4.4, the statistic has no resolution, and the regime where the exact-zero theorem applies is precisely the regime where the collision fraction is $1$.

### 7.5 Why the nulls sat above the data

The dichotomy also explains the sign anomaly of the controlled run. The theorem is about the *sample*, so it transfers to a shuffled surrogate only if the surrogate preserves the involution — and a label shuffle does not: after shuffling, condition 4 (label flip along $\sigma$) generically fails, so the surrogate table is no longer a product table and its reading drifts upward by ordinary sampling fluctuation.

**Principle 7.9.** The permutation null of a symmetric view on a swap-closed sample is biased *upward*, away from an exactly-zero observation.

This is exactly what was measured: observed $0.0000$ against null means $0.1363$ (product view), $0.4990$ ($(s,d)$ view) and $0.0004$ (residue view). The flagged positive readings elsewhere in the programme are the null's own inflation seen from below. A screening rule of the form "flag when observed exceeds null" is, in this setting, guaranteed never to fire — not because there is no leakage to find, but because the calibration is structurally displaced.

---

## 8. Algorithms

The theory yields a small, exactly-computable audit suite. Each item below is finite, deterministic and cheap.

**Algorithm A (Collision audit).** Input: a view $c$ on $n$ samples. Compute the fiber sizes $f_k$ by a single hash pass ($O(n)$ time, $O(d)$ space with $d$ distinct codes); output $d$, $C(c)=\sum_{f_k\ge2} f_k$, the certified sandwich width $\frac{C}{n}\log_2|L|$, the fiber-log width $\frac1n\sum_{f_k\ge2}f_k\log_2 f_k$, and the maximum fiber size. This is the *resolution certificate* of any subsequent test: if the width is comparable to $H(\ell)$, the test is uninformative before it is run.

**Algorithm B (Plug-in reading).** Compute $N_{a,k}$, $m_a$, $f_k$ in one pass and evaluate $\hat I$ by summing over nonzero cells; $O(n + |{\rm cells}|)$.

**Algorithm C (Permutation null with a guarantee).** Draw $B$ label shuffles, recompute $\hat I$ for each, report mean, sd and $z$ — *together with* the Algorithm A width. By Theorem 4.4 the entire null and the observed value lie in an interval of that width, so a $z$-score computed inside it is uninformative by construction.

**Algorithm D (Swap-closure detector).** Given a sample of ordered pairs, attempt to build $\sigma$ by matching each index $i=(p,q)$ to the index of $(q,p)$. If the matching is total and fixed-point-free, verify $c\circ\sigma = c$ and $\ell\circ\sigma \ne \ell$ pointwise. On success Theorem 7.6 certifies $\hat I = 0$ exactly, without floating-point arithmetic; on failure Theorem 7.8 says the exact-zero route is unavailable and the sandwich governs. Cost $O(n)$ with a hash index.

**Algorithm E (Refinement-gain check).** Given a fine view $c'$ and a coarsening $\varphi$, compute both readings and the coarse collision term; Theorem 6.3 bounds the gain. Reporting the gain against its own ceiling separates "the hint genuinely exceeded what refinement guarantees" from "the hint refined".

---

## 9. Applications and discussion

### 9.1 For leakage screening

The immediate application is negative and sharp: a factor-residue hint view carrying $4.56$ of the $4.60$ bits of label entropy is factor-blind at the sensitivity of a permutation null ($\pm 0.001$ bits on this statistic). The chain of the programme — a capacity bound, a ceiling-saturation result, a hint-compounding result, and now verified blindness on every view including the strongest — is closed.

### 9.2 Beyond factoring

Nothing in Sections 2–7 is arithmetic. The same phenomena afflict any pipeline that scores a high-cardinality categorical feature by empirical mutual information against a label and calibrates by shuffling: leakage audits on hashed identifiers, "does this embedding encode the protected attribute?" probes, feature-importance screens on near-unique keys, and privacy audits of quasi-identifiers. In every such setting Theorem 3.5 says the score converges to the label entropy as the feature becomes a key, and Theorem 4.4 says the shuffle null cannot detect that it has.

The actionable recommendation is one line: **report the collision fraction next to every mutual-information score.** It costs one pass over the data and it is a certificate of the resolution the test had.

### 9.3 Relation to classical bias corrections

The Miller–Madow correction estimates the plug-in bias as $(\text{cells}-1)/(2n\ln 2)$ to first order and is asymptotic. Theorem 3.4 is a non-asymptotic statement of the same phenomenon with an explicit finite constant, and the two are comparable: for a view whose fibers have size at most two, Theorem 5.3 gives a deficit at most $C/n$, while Miller–Madow predicts approximately $(n-d)/n$, and Theorem 3.6 ($C\le2(n-d)$) places the sandwich within a factor two of the classical correction. Making that comparison a theorem is one of the open problems below.

### 9.4 Limitations

The sandwich is worst-case and one-sided; measured spreads run three orders of magnitude inside the guarantee. The two bounds of Sections 3 and 5 are incomparable and both are retained. The dichotomy is stated for a binary label (the label-flip condition presupposes two values) and for exact swap-closure; approximate versions — samples that are swap-closed up to a small fraction of unmatched indices — are not covered and would require a stability analysis of Theorem 7.6.

---

## 10. Future directions

This cycle closed the gap between two halves of the factor-blindness programme: the exact $0$-bit wall for symmetric readouts, and the near-$H(\ell)$ plug-in readings observed on sparse samples. Four results now carry the joint: the collision sandwich (the reading is pinned inside a band of width $\frac{C}{n}\log_2|L|$ around the label entropy); the powerlessness theorem (observed, surrogates and null mean all lie inside that band, so a permutation test on a fine view has no resolution); refinement monotonicity (a hint view's larger reading is forced by refinement, not by dependence); and the dichotomy (a swap-closed sample has collision fraction exactly $1$ and reading exactly $0$, so the wall regime and the sparse regime never overlap). The directions below are the open ends these leave.

### 10.1 A permutation-null variance law

The band bounds the *range* of the null but says nothing about its *shape*. Experimentally the null standard deviation was $0.0011$–$0.0116$ on bands of width $1$ — three orders of magnitude narrower than the guarantee. The key insight is that a label shuffle acts on the fiber partition as a sampling-without-replacement scheme, so the null variance should be a function of the fiber-size profile alone,
$$\mathrm{Var} \;\approx\; c\,\frac{\sum_k f_k(f_k-1)}{n^2},$$
with no dependence on the labels beyond their margin. Why now? Because the fiber decomposition (Proposition 3.2) already expresses the statistic as a weighted sum of per-fiber entropies, and per-fiber label counts under a shuffle are exactly multivariate hypergeometric; the variance calculation is now a finite combinatorial identity rather than an asymptotic claim.

### 10.2 Miller–Madow correction as an exact theorem

The plug-in estimator's bias is classically $(\text{cells}-1)/(2n\ln 2)$ to first order. The key insight is that the collision sandwich is a *non-asymptotic* version of the same statement, and the two should be comparable: for a view whose fibers all have size $\le 2$, the sandwich gives a deficit $\le C/n$ while Miller–Madow predicts $\approx (n-d)/n$, and $C \le 2(n-d)$ says the sandwich is within a factor two of it. Why now? Because both quantities are now exact finite objects in the same framework, so a theorem of the form $|\text{deficit} - \text{Miller–Madow}| \le g(\text{fiber profile})$ is stateable without probability theory.

### 10.3 Strict refinement gain

Refinement monotonicity is an inequality with a strictness witness but no equality criterion. The key insight is that the log-sum inequality is an equality exactly when the aggregated ratios are constant on each fiber of $\varphi$, so refinement gains nothing precisely when the label is conditionally independent of the fine view given the coarse one — a finite, checkable sufficiency condition that would turn the monotonicity into a *diagnostic*: a hint that gains more than the equality criterion permits is the only kind of hint that carries evidence.

### 10.4 Approximate swap-closure

Extend Theorem 7.6 to samples carrying a partial involution defined on a $(1-\eta)$ fraction of indices, with a deficit bound degrading gracefully in $\eta$. This would let the exact-zero route apply to real datasets that are symmetric up to boundary effects.

---

## 11. Conclusion

The plug-in mutual information of a label against a fine-grained view is not a measurement of dependence. Its deficit below the label entropy is a fiber-weighted sum of within-fiber label entropies, so a view with no collisions reads exactly the label entropy for every label function whatsoever; with collisions, the reading is pinned within $\frac{C}{n}\log_2|L|$ — or within $\frac1n\sum f_k\log_2 f_k$, or within one bit for pair-collision views — of a quantity that depends only on the label margin. The permutation null, which preserves both the label margin and the fibers, is confined to the same band and therefore cannot resolve anything the band conceals. Refinement monotonicity makes the apparent superiority of a finer "hint" view automatic.

Against this, the exact-zero side of the story is a theorem about symmetry, not about estimation: on a sample carrying a fixed-point-free involution along which the view is constant and the label flips, the contingency table is an exact product table and the reading is exactly zero. And the two sides can never be confused, because swap-closure forces the collision fraction to $1$ and total collision is exactly what makes the band vacuous.

A flagged reading of $0.9663$ bits, matched by its own shuffle null to within $0.0015$ bits, was therefore never evidence of anything but its own sparsity. The hinted view is blind.
