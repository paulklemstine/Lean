# Hints Compound or Diminish, Not Both: A Scaling Calculus for Hint-Value Curves

**Aristotle**, 2026-10-01

---

## Abstract

An experiment on learning a hidden label from residue information about two prime factors reported the hint-value curve $V(0)=0$, $V(1)=0.52$, $V(2)=2.43$, $V(3)=3.19$ bits. Its authors summarised it as *hints compound with diminishing returns*. We make precise the two halves of this verdict as properties of an arbitrary curve $V:\mathbb N\to\mathbb R$: **compounding** (superadditivity) and **diminishing returns from step $a$** (marginal gains non-increasing for $k\ge a$). We then develop a small calculus for curves with these properties. The central result is the **Compounding Horizon Theorem**. If $V$ compounds and its marginal gains are non-increasing from $a$ on, then $V(b)\le b\,\Delta(k)$ for all $b$ and all $k\ge a$, where $\Delta(k)=V(k+1)-V(k)$. In other words, diminishing marginal gains can only decrease towards a slope that compounding has already locked in. Corollaries follow. A compounding curve with $V(0)=0$ whose gains are non-increasing from the start is exactly linear, so compounding and strictly diminishing returns are incompatible. A compounding curve under an affine ceiling $ck+b$ lies under $ck$, and a bounded compounding curve is nonpositive. Applied to the reported data, these results show the following. (i) The curve is not concave: its marginal gains $0.52, 1.91, 0.76$ rise before they fall. (ii) No curve through the four data points both compounds and has diminishing returns from $k=2$ on, and the failure is already forced at $k=4$, where compounding requires $V(4)\ge 4.86$ and diminishing returns requires $V(4)\le 3.95$. (iii) Every compounding continuation whose gains eventually diminish has all later gains $\ge 1.215$ bits. (iv) No continuation under a uniform information ceiling compounds. (v) Nevertheless, each half of the verdict separately has an explicit continuation consistent with the data. Finally, we connect the abstract calculus to the factor-residue model that produced the data. There the hint curve saturates at the second hint: it is monotone, diminishing from the first hint, and bounded by the label entropy, and so it compounds if and only if it vanishes identically. Any third hint computed from the residues has zero marginal value. The second marginal gain is at most one bit over a single odd prime field and at most $k$ bits over a product of $k$ odd prime fields, so the observed $1.91$-bit jump is impossible over one field and admissible over two. We propose replacing the verdict with *hints compound locally, saturate globally*.

---

## 1. Introduction

Scaling claims of the form "each additional unit of input is worth more (or less) than the last" are among the most common empirical summaries in the sciences. They are usually stated over a short window of measurements but read as laws. This paper studies one such claim in detail. The point is not the particular experiment, but how much can be deduced, using only elementary inequalities, about *every* curve consistent with a handful of measurements and a qualitative verdict.

The experiment concerns a population of instances, each carrying a hidden label and two hidden "factors" $p,q$ that live in a finite commutative ring, typically a prime field $\mathbb Z/p\mathbb Z$ or a product of such fields. A learner is given $k$ hints derived from the factors and its success is measured by the mutual information, in bits, between the label and the hints. The reported curve is shown in Table 1.

**Table 1.** Reported hint values.

| $k$ | $V(k)$ (bits) | $\Delta(k-1)=V(k)-V(k-1)$ |
|---|---|---|
| 0 | $0$ | — |
| 1 | $0.52$ | $0.52$ |
| 2 | $2.43$ | $1.91$ |
| 3 | $3.19$ | $0.76$ |

The verdict drawn from it was *hints compound with diminishing returns*. Over the measured window the curve is indeed superadditive: $V(1)+V(1)=1.04<2.43=V(2)$ and $V(1)+V(2)=2.95<3.19=V(3)$. Its last marginal gain, $0.76$, is smaller than the one before, $1.91$. The question is whether this pair of properties can describe the curve as a *law*, that is, for all $k$.

**Contributions.**

1. A precise formulation of compounding and diminishing returns for arbitrary real sequences (Section 2).
2. A calculus of such curves: the tangent cap, the secant floor, the Compounding Horizon Theorem, the Linearity Theorem, and the affine and bounded collapse theorems (Section 3).
3. A complete analysis of the reported data, quantified over *all* curves through the four points, so that no extrapolation choice is hidden (Section 4).
4. A bridge to the factor-residue model, explaining the saturation of the curve and the size of the second jump in terms of the number of prime fields (Section 5).

All statements about the data are universal over curves through the four reported points. Where we give existence statements we exhibit explicit continuations.

---

## 2. Definitions

Throughout, $V:\mathbb N\to\mathbb R$ is an arbitrary sequence, the *hint-value curve*. We write $V(k)$ for the value of $k$ hints.

**Definition 2.1 (Marginal gain).** The marginal gain of the $(k+1)$-st hint is
$$\Delta(k)=V(k+1)-V(k).$$

**Definition 2.2 (Compounding).** $V$ is *compounding* if it is superadditive:
$$V(m)+V(n)\le V(m+n)\qquad\text{for all } m,n\in\mathbb N.$$

**Definition 2.3 (Diminishing returns from $a$).** For $a\in\mathbb N$, $V$ has *diminishing returns from $a$* if
$$\Delta(k+1)\le\Delta(k)\qquad\text{for all } k\ge a.$$
Diminishing returns from $0$ is ordinary discrete concavity.

**Definition 2.4 (Matching the data).** A curve *matches the data* if
$$V(0)=0,\quad V(1)=0.52,\quad V(2)=2.43,\quad V(3)=3.19.$$

Two remarks. First, compounding forces $V(0)\le 0$, since $2V(0)\le V(0)$, so normalising $V(0)=0$ costs nothing. Second, we never assume monotonicity or boundedness in Sections 3–4 unless it is stated.

---

## 3. The scaling calculus

### 3.1 Tangent cap and secant floor

**Lemma 3.1 (Propagation of diminishing gains).** If $V$ has diminishing returns from $a$ and $k\ge a$, then $\Delta(k+j)\le\Delta(k)$ for every $j\ge 0$.

*Proof.* Induction on $j$. The step uses $\Delta(k+j+1)\le\Delta(k+j)$, which holds because $k+j\ge a$. $\square$

**Lemma 3.2 (Tangent cap).** If $V$ has diminishing returns from $a$ and $k\ge a$, then for all $j\ge 0$
$$V(k+j)\le V(k)+j\,\Delta(k).$$

*Proof.* Induction on $j$. We have $V(k+j+1)=V(k+j)+\Delta(k+j)\le V(k)+j\Delta(k)+\Delta(k)$ by the induction hypothesis and Lemma 3.1. $\square$

Geometrically, a curve with diminishing returns from $a$ lies under each of its tangent lines (forward chords of unit length) based at points $k\ge a$.

**Lemma 3.3 (Compounding forces $V(0)\le0$).** If $V$ compounds then $V(0)\le 0$.

*Proof.* Take $m=n=0$: $2V(0)\le V(0)$. $\square$

**Lemma 3.4 (Secant floor).** If $V$ compounds then for all $b,m\in\mathbb N$
$$(m+1)\,V(b)\le V\big((m+1)b\big).$$

*Proof.* Induction on $m$. We have $V((m+2)b)\ge V((m+1)b)+V(b)\ge (m+1)V(b)+V(b)$. $\square$

So a compounding curve dominates the multiples of each of its values. Any average rate $V(b)/b$ that is achieved once persists along the arithmetic progression $b,2b,3b,\dots$.

### 3.2 The Compounding Horizon Theorem

**Theorem 3.5 (Compounding Horizon).** Suppose $V$ compounds and has diminishing returns from $a$. Then for every $k\ge a$ and every $b\in\mathbb N$,
$$V(b)\le b\,\Delta(k).$$
Equivalently, for $b\ge1$: every marginal gain from step $a$ onward is at least the average rate $V(b)/b$, and therefore at least $\sup_{b\ge1}V(b)/b$.

*Proof.* If $b=0$ the claim is $V(0)\le 0$, which is Lemma 3.3. Let $b\ge1$ and suppose, for contradiction, that
$$c:=V(b)-b\,\Delta(k)>0.$$
Choose $N\in\mathbb N$ with $N c > V(k)-k\Delta(k)$ (Archimedean property), and set $M=k+N$. Then $(M+1)b\ge M+1>k$. By the secant floor (Lemma 3.4),
$$(M+1)V(b)\le V\big((M+1)b\big).$$
By the tangent cap (Lemma 3.2) applied with $j=(M+1)b-k\ge0$,
$$V\big((M+1)b\big)\le V(k)+\big((M+1)b-k\big)\Delta(k).$$
Combining, $(M+1)\big(V(b)-b\Delta(k)\big)\le V(k)-k\Delta(k)$, that is $(M+1)c\le V(k)-k\Delta(k)<Nc\le (M+1)c$. This is a contradiction. $\square$

*Interpretation.* Compounding pushes the curve up at average slope $V(b)/b$ along multiples of $b$. Diminishing returns holds it under a line of slope $\Delta(k)$. Lines of different slopes eventually cross, so the larger slope must be the tangent slope. The argument has the same flavour as Fekete's lemma, which says that for a superadditive sequence $V(n)/n$ converges to $\sup V(n)/n$. Here the conclusion is that, under eventual concavity, the marginal gains are bounded below by that supremum.

### 3.3 Linearity and the impossibility of strict diminishing returns

**Theorem 3.6 (Compounding + concavity = linearity).** If $V$ compounds, has diminishing returns from $0$, and $V(0)=0$, then
$$V(k)=k\,V(1)\qquad\text{for all }k.$$

*Proof.* The tangent cap at $k=0$ gives $V(k)\le V(0)+k\Delta(0)=kV(1)$. For $k=m+1\ge1$ the secant floor with $b=1$ gives $V(k)\ge kV(1)$. For $k=0$ both sides vanish. $\square$

**Corollary 3.7.** Under the hypotheses of Theorem 3.6, $\Delta(k)=V(1)$ for all $k$.

**Corollary 3.8 (No strict diminishing returns).** Under the hypotheses of Theorem 3.6, there is no $k$ with $\Delta(k+1)<\Delta(k)$. In particular, no curve with $V(0)=0$ is both compounding and strictly concave.

### 3.4 Ceilings cannot be compounded away

**Theorem 3.9 (Affine ceiling collapse).** If $V$ compounds and $V(k)\le ck+b$ for all $k$, with real constants $c,b$, then $V(a)\le ca$ for every $a$.

*Proof.* Suppose $e:=V(a)-ca>0$ and choose $N$ with $Ne>b$. By the secant floor and the ceiling, $(N+1)V(a)\le V((N+1)a)\le c(N+1)a+b$, so $(N+1)e\le b<Ne$, a contradiction. $\square$

**Corollary 3.10 (Bounded collapse).** If $V$ compounds and $V(k)\le B$ for all $k$, then $V(a)\le0$ for all $a$.

*Proof.* Theorem 3.9 with $c=0$, $b=B$. $\square$

Corollary 3.10 is the key interface with information theory. A hint-value curve measured in bits of mutual information about a label is bounded by the label entropy, so it can compound only if it is nonpositive. For a nonnegative curve, that means it is identically zero.

---

## 4. Analysis of the reported curve

Throughout this section $V$ is **any** curve that matches the data (Definition 2.4). No continuation beyond $k=3$ is assumed.

### 4.1 Shape on the window

**Proposition 4.1 (Marginal gains).** $\Delta(0)=0.52$, $\Delta(1)=1.91$, $\Delta(2)=0.76$.

**Proposition 4.2 (S-shape).** All three gains are positive, $\Delta(0)<\Delta(1)$, and $\Delta(2)<\Delta(1)$. The curve accelerates and then decelerates.

**Corollary 4.3 (Not concave).** $V$ does not have diminishing returns from $0$, because $\Delta(1)>\Delta(0)$.

**Proposition 4.4 (Window compounding).** $V(1)+V(1)<V(2)$ and $V(1)+V(2)<V(3)$, with margins $1.39$ and $0.24$ bits.

So the most generous reading of "diminishing returns" that is consistent with the data is diminishing returns from $k=2$ on (or from $k=1$, which also holds on the window, since $\Delta(2)<\Delta(1)$).

### 4.2 The verdict refuted

**Theorem 4.5 (Asymptotic slope).** If $V$ matches the data, compounds, and has diminishing returns from some $a$, then $\Delta(k)\ge1.215$ for every $k\ge a$.

*Proof.* Theorem 3.5 with $b=2$ gives $2.43=V(2)\le2\Delta(k)$. $\square$

Among the observed values, $V(2)/2=1.215$ is the largest average rate. The others are $V(1)/1=0.52$ and $V(3)/3\approx1.063$.

**Theorem 4.6 (The verdict cannot hold as a law).** No curve matching the data both compounds and has diminishing returns from $k=2$ on.

*Proof.* Theorem 4.5 with $a=k=2$ would give $0.76=\Delta(2)\ge1.215$. $\square$

The same holds for diminishing returns from $k=1$, which is the stronger hypothesis.

**Theorem 4.7 (Sharp failure at $k=4$).** Let $V$ match the data. The two single inequalities
$$V(2)+V(2)\le V(4)\qquad\text{and}\qquad \Delta(3)\le\Delta(2)$$
are already incompatible.

*Proof.* The first gives $V(4)\ge4.86$. The second gives $V(4)\le V(3)+\Delta(2)=3.95$. $\square$

Thus the very next measurement must contradict one half of the verdict, by a margin of $0.91$ bits, whatever its value.

### 4.3 Ceilings

**Proposition 4.8 (No unit-rate ceiling).** If $V$ matches the data and compounds, then for no constant $b$ does $V(k)\le k+b$ hold for all $k$.

*Proof.* Theorem 3.9 with $c=1$ would give $2.43=V(2)\le2$. $\square$

**Theorem 4.9 (Information-bounded continuations do not compound).** If $V$ matches the data and $V(k)\le B$ for all $k$, then $V$ is not compounding.

*Proof.* Corollary 3.10 would give $0.52=V(1)\le0$. $\square$

### 4.4 Each half alone is consistent

**Proposition 4.10 (A diminishing continuation).** Define
$$D(0)=0,\quad D(1)=0.52,\quad D(k)=2.43+0.76\,(k-2)\ \ (k\ge2).$$
Then $D$ matches the data and has diminishing returns from $1$. Its marginal gains are $0.52,1.91,0.76,0.76,\dots$.

**Proposition 4.11 (A compounding continuation).** Define
$$C(0)=0,\ C(1)=0.52,\ C(2)=2.43,\ C(3)=3.19,\qquad C(k)=k^2\ \ (k\ge4).$$
Then $C$ matches the data and compounds.

*Proof sketch.* First, $C(k)\le k^2$ for all $k$: check $0.52\le1$, $2.43\le4$, $3.19\le9$. If $m+n\ge4$ then $C(m)+C(n)\le m^2+n^2\le(m+n)^2=C(m+n)$. If $m+n\le3$ there are finitely many cases, all covered by Proposition 4.4 and the identities $C(0)=0$, such as $C(0)+C(k)=C(k)$. $\square$

Propositions 4.10 and 4.11 show that the four data points cannot decide between the two halves of the verdict. Theorem 4.9 does decide, once one adds the outside information that hint values are bounded by an entropy: compounding must fail.

---

## 5. The factor-residue model

We now connect the calculus to the model that produced the data, and show that in this model the curve *must* have diminishing returns.

### 5.1 Setting

Let $\Omega$ be a finite, nonempty population of instances with the uniform distribution. Let $L:\Omega\to\Lambda$ be a label, and let $P,Q:\Omega\to R$ be two *factor residues* taking values in a finite commutative ring $R$ in which $2$ is invertible. For a function ("view") $f$ on $\Omega$, write $I(L;f)$ for the mutual information, in bits, between $L$ and $f$ under the uniform distribution on $\Omega$, and $H(L)$ for the label entropy. Standard facts:

- $0\le I(L;f)\le H(L)$.
- If $f$ and $g$ induce the same partition of $\Omega$, then $I(L;f)=I(L;g)$. Mutual information depends only on the fibres of the view.

We use three views:

- the **product view** $x\mapsto P(x)Q(x)$;
- the **sum dial**, which adds $P(x)+Q(x)$ to the product view (the *gap dial* $P(x)-Q(x)$ plays a symmetric role);
- the **joint residue view** $\rho(x)$, whose fibres are exactly the fibres of $x\mapsto(P(x),Q(x))$.

The **hint value** is the information carried by the joint residues beyond the product:
$$\mathrm{HV}=I(L;\rho)-I(L;PQ),$$
and the **sum hint** $\mathrm{SH}$ is the corresponding conditional gain of the sum dial over the product view. They satisfy
$$0\le\mathrm{SH}\le\mathrm{HV}\le H(L),$$
because the joint view refines the sum dial, which refines the product view.

**Definition 5.1 (Factor-residue hint curve).** The hint curve of the battery $(L,P,Q)$ is
$$W(0)=0,\qquad W(1)=\mathrm{SH},\qquad W(k)=\mathrm{HV}\ \ (k\ge2).$$

The definition reflects the fact that once the joint residues are known, no further hint computed from them can add information. We prove this next.

### 5.2 Saturation

**Theorem 5.2 (Third-hint saturation).** Let $h:R\times R\to\beta$ be any function. Then
$$I\big(L;\ x\mapsto(\rho(x),\,h(P(x),Q(x)))\big)=I(L;\rho).$$

*Proof.* The augmented view and $\rho$ have the same fibres. If two instances agree on $\rho$, they agree on $(P,Q)$, hence on $h(P,Q)$. The converse is trivial. Mutual information depends only on fibres. $\square$

So any residue-derived third hint has **zero** marginal value. The reported third gain of $0.76$ bits cannot come from the residue ring itself.

**Proposition 5.3 (Monotone, diminishing, bounded).** For every battery:

1. $\Delta_W(k)\ge0$ for all $k$, so $W$ is monotone;
2. $W$ has diminishing returns from $1$, since $\Delta_W(1)=\mathrm{HV}-\mathrm{SH}\ge0=\Delta_W(2)=\Delta_W(3)=\cdots$;
3. $W(k)\le H(L)$ for all $k$.

**Theorem 5.4 (Compounding iff zero).** $W$ compounds if and only if $W(k)=0$ for all $k$.

*Proof.* If $W$ compounds, Corollary 3.10 with $B=H(L)$ gives $W(k)\le0$, and monotonicity gives $W(k)\ge W(0)=0$. The converse is trivial. $\square$

In the factor-residue model, diminishing returns is therefore forced, and compounding as a law is available only for the trivial curve.

### 5.3 How large can the second jump be?

The second marginal gain $\Delta_W(1)=\mathrm{HV}-\mathrm{SH}$ measures what the full residues add once product and sum are known. Since $2$ is invertible, $(P+Q,PQ)$ determines the unordered pair $\{P,Q\}$ as the root set of $X^2-(P+Q)X+PQ$. What is left is an *orientation*: which root is $P$. More generally, call a map $s:R\to F$ to a finite set $F$ a *sign selector* if the residues are recovered from the sum dial together with $s$ evaluated on the difference $P-Q$ (in a field, $s$ records which of the two square roots $\pm(P-Q)$ occurs). We take the following inequality as given; it is a chain-rule bound:

**Proposition 5.5 (Sign-selector ceiling).** For any sign selector $s:R\to F$,
$$\mathrm{HV}\le\mathrm{SH}+\log_2|F|,$$
and hence $\Delta_W(1)\le\log_2|F|$.

*Proof sketch.* The joint residue view is a function of the sum-dial view and the selector value. By the chain rule, the additional information is at most the entropy of the selector value, which is at most $\log_2|F|$. $\square$

For an odd prime $p$ and $R=\mathbb Z/p\mathbb Z$ a two-valued selector exists: a fixed choice of representative of each pair $\{\pm d\}$. This gives the **one-orientation-bit law** $\mathrm{HV}\le\mathrm{SH}+1$, and the same bound holds with the gap dial in place of the sum dial. For $R=\prod_{i<k}\mathbb Z/p_i\mathbb Z$ with odd primes $p_i$, the coordinatewise selectors combine into a selector with values in $\{0,1\}^k$, of size $2^k$.

**Theorem 5.6 (One field cannot carry the jump).** Let $p$ be an odd prime and $R=\mathbb Z/p\mathbb Z$. No battery over $R$ has $\mathrm{SH}=0.52$ and $\mathrm{HV}=2.43$. The same holds with the gap hint in place of the sum hint.

*Proof.* $2.43\le0.52+1$ is false. $\square$

**Theorem 5.7 (One bit per field).** Over $\prod_{i<k}\mathbb Z/p_i\mathbb Z$ with odd primes $p_i$,
$$\mathrm{HV}-\mathrm{SH}\le k.$$

*Proof.* Proposition 5.5 with $|F|=2^k$ and $\log_2 2^k=k$. $\square$

The observed jump of $1.91$ bits is impossible over one field and admissible over two. The size of the jump is evidence of at least two independent prime channels.

---

## 6. Algorithms

The results above give simple, exact decision procedures for finite data.

**Algorithm A (Verdict audit).** Input: values $V(0),\dots,V(n)$ and a proposed onset $a$.

1. Compute marginal gains $\Delta(k)=V(k+1)-V(k)$ for $k<n$.
2. Report the window shape. Check concavity from $0$, and check whether $\Delta(k+1)\le\Delta(k)$ for $a\le k<n-1$.
3. Compute the locked-in rate $r=\max_{1\le b\le n}V(b)/b$.
4. For each observed $k\ge a$ with $k<n$, if $\Delta(k)<r$, report that compounding plus diminishing returns from $a$ is **refuted** (Theorem 3.5).
5. Search for the earliest forced contradiction. For $N=n+1,n+2,\dots$, compute the compounding lower bound $\mathrm{lo}(N)=\max_{m+m'=N}(\text{lower bounds of }V(m)+V(m'))$ and the tangent upper bound $\mathrm{hi}(N)=V(n)+(N-n)\Delta(n-1)$, propagating bounds forward. Stop at the first $N$ with $\mathrm{lo}(N)>\mathrm{hi}(N)$.

The cost is $O(n)$ for steps 1–4 and $O(N^2)$ for step 5 up to horizon $N$. On the reported data step 4 fires immediately ($0.76<1.215$), and step 5 stops at $N=4$ with $\mathrm{lo}=4.86>\mathrm{hi}=3.95$.

**Algorithm B (Superadditivity check).** For a curve given on $\{0,\dots,N\}$, check $V(m)+V(n)\le V(m+n)$ for all $m+n\le N$, in $O(N^2)$ time. This is used to confirm that the continuation $C$ of Proposition 4.11 compounds on any finite range.

**Algorithm C (Field-count lower bound).** Given $\mathrm{SH}$ and $\mathrm{HV}$, the number of odd prime fields must satisfy $k\ge\lceil\mathrm{HV}-\mathrm{SH}\rceil$ (Theorem 5.7). For the data, $k\ge\lceil1.91\rceil=2$.

---

## 7. Discussion

**What the verdict gets right.** On the measured window the curve is superadditive and its final gain is smaller than the previous one. As a description of four points, "compounding with diminishing returns" is accurate.

**What it gets wrong.** As a law it is self-contradictory (Theorem 4.6), and the contradiction appears at the next measurement (Theorem 4.7). The underlying obstruction is the Compounding Horizon. Compounding fixes a floor $\sup_b V(b)/b$ for all future marginal gains once returns start to diminish, and the data violate that floor at their own last step.

**Which half survives.** The data alone do not decide (Propositions 4.10, 4.11). Information-theoretic boundedness decides in favour of diminishing returns (Theorem 4.9), and in the factor-residue model diminishing returns is forced outright (Proposition 5.3, Theorem 5.4).

**The S-curve.** The reported curve rises in slope, then falls. This is the familiar sigmoid profile of bounded growth processes. We propose the replacement verdict **hints compound locally, saturate globally**.

**Structural readings.** Two features of the data look anomalous from the residue model's point of view. The positive third gain conflicts with Theorem 5.2, which says residue-derived third hints carry zero information, so the third hint must use information from outside the residues. The second jump of $1.91$ bits conflicts with the one-bit law over a single field (Theorem 5.6), so the experiment must involve at least two fields, or more generally a sign group of size at least $2^{1.91}$.

**Robustness.** All refutations have margins large compared with plausible measurement noise: $0.91$ bits at $k=4$, a gap of $1.215-0.76=0.455$ bits in the asymptotic slope, and $1.91-1=0.91$ bits over the one-field ceiling.

---

## 8. Future work

1. **Sigmoid inflection bound.** For a monotone curve bounded by $B$ with $V(0)=0$ and unimodal marginal gains peaking at $k^*$, we conjecture $k^*\le\lceil B/\Delta(0)\rceil$. The heuristic is that a rising phase must pay for itself linearly against the ceiling.
2. **Exact $k$-field ceiling.** We conjecture that the supremum of $\mathrm{HV}-\mathrm{SH}$ over batteries on $\prod_{i<k}\mathbb Z/p_i\mathbb Z$ is exactly $k$. It should be attained by products of single-field orientation batteries, via additivity of entropy over product populations. The case $k=2$ is attained by an explicit two-field example.
3. **Extra-residue third hints.** We conjecture that any battery reproducing a positive third gain uses a hint that is not a function of the residues modulo the working modulus, for instance a second modulus combined through the Chinese remainder theorem. The next step is to construct such a battery explicitly.
4. **Finite-horizon versions of the horizon theorem.** The data here are finite. A quantitative version of Theorem 3.5 would bound how long a curve can compound with diminishing gains before contradiction, in terms of $V(b)/b-\Delta(k)$ and $V(k)-k\Delta(k)$. The proof already contains such a bound: contradiction occurs by $N\approx (V(k)-k\Delta(k))/c$ copies.

---

## 9. Conclusion

Two common words in scaling discussions, *compounding* and *diminishing returns*, have exact meanings, and those meanings limit each other. A compounding curve locks in its best average rate, and a curve with diminishing returns stays under its tangent. Together they force all late marginal gains to be at least the best average rate, force exact linearity when concavity starts at the first hint, and force collapse under any finite ceiling. Applied to the reported hint-value curve, these facts show that the verdict *hints compound with diminishing returns* cannot be a law, that compounding is the half that information-theoretic bounds rule out, and that the shape of the curve (a jump larger than one bit, followed by a positive third gain) points to an experiment richer than a single prime field and its residues.
