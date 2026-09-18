# Synergy and Overlap in Batteries of Measurement Dials: An Exact Co-Information Calculus

**Author:** Aristotle
**Date:** 2026-09-18

---

## Abstract

We study the information-theoretic behaviour of *batteries*: finite collections of deterministic measurement instruments ("dials"), each applied to the same finite population, and each evaluated by how much it reveals about a hidden label. A natural and frequently assumed hypothesis — that dials built from structurally unrelated ingredients (for instance, residue readings at coprime conductors) contribute *additively* to the joint capacity of the battery — is false, and we show that it fails in both directions. We prove an exact identity governing the discrepancy: for two dials $f, g$ read against a label $L$ on a finite population,
$$\Delta(L; f, g) := I(L;(f,g)) - I(L;f) - I(L;g) = I(f;g\mid L) - I(f;g).$$
The failure of additivity is *precisely* the excess of the label-conditional dependence of the two readouts over their unconditional dependence. From this identity we derive: nonnegativity of the conditional dependence (from a data-processing argument, not assumed); the sharp overlap bound $-\Delta \le I(f;g)$; the marginal bound $-\Delta \le \min(I(L;f), I(L;g))$; the ceiling $\Delta \le \min(H(f), H(g))$; the corollary that unconditionally independent readouts are necessarily super-additive; a knife-edge characterisation of exact additivity as the equality of the two dependence terms; and the total-overlap theorem $\Delta = -I(L;g)$ when one dial is a post-processing of the other ("same subfield = same dial").

We exhibit a single three-dial battery on a four-element population whose rows realise $+1$, $0$, and $-1$ bit of discrepancy, establishing that the space of batteries is neither additive nor comonotone, and that both derived bounds are attained with equality. We then widen the law to arbitrary battery width $k$: with $\mathrm{TC}$ denoting total correlation of the readouts and $\mathrm{TC}(\cdot\mid L)$ its label-conditional counterpart,
$$I(L;\text{joint}) - \sum_{i\in S} I(L;f_i) = \mathrm{TC}(\text{readouts}\mid L) - \mathrm{TC}(\text{readouts}),$$
with both terms nonnegative, yielding the $k$-dial overlap bound $\Delta \ge -\mathrm{TC}$, its attainment at every width, and the super-additivity of independent batteries at every width. We give algorithms that compute all quantities exactly for finite populations, numerical demonstrations, and applications to feature selection, sensor fusion, and interaction analysis.

**Keywords:** co-information, synergy, redundancy, total correlation, mutual information, feature selection, conditional independence, data processing inequality.

---

## 1. Introduction

### 1.1 Motivating measurements

Consider a finite population $\Omega$ of arithmetic objects — say pairs $(p,q)$ of primes drawn from a fixed index range — carrying a hidden *label* $L(x)$ that one wishes to predict. A *dial* is a deterministic instrument: a function $f : \Omega \to \mathbb{Z}/m$ returning a residue, for instance the splitting behaviour of $p$ in a fixed number field of conductor $m$. Its *capacity* is the mutual information $I(L;f)$, measured here in bits.

Batteries of such dials were measured against a fixed population and a fixed label, with the following results (bits):

| battery | $I(\text{joint})$ | $I_1 + I_2$ | $\Delta$ |
|---|---|---|---|
| cubic dial at conductor $31$ $\times$ cubic dial at conductor $23$ | $2.1314$ | $2.0024$ | $+0.129$ (synergy) |
| quartic dial at $9$ $\times$ dihedral dial at $8$ | $1.9125$ | $1.9076$ | $+0.005$ (near-additive) |
| two cubic dials of shared discriminant $-23$ | $1.0104$ | $2.0024$ | $-0.992$ (overlap) |

The pre-registered hypothesis — *coprime conductors imply additive capacity* — is refuted at the first pair, and the refutation is two-sided: one battery exceeds the additive prediction and another falls almost a full bit short of it. Each individual marginal had been independently re-verified against earlier measurement campaigns ($1.0012$, $1.0012$, $0.4733$, $1.4342$ bits) *before* any joint measurement was taken, so the discrepancies cannot be attributed to drift in the marginals. A further diagnostic — a "which-factor wall" checking that no joint channel leaks information about which factor of the population an individual came from — stayed below $0.0016$ bits across every joint channel, so the synergised and overlapping content is symmetric and factor-blind.

### 1.2 The reasoning error and its correction

The additivity argument implicitly treats the two dial readouts as *independent draws*. They are not: both dials are evaluated at the same individual $x \in \Omega$. Consequently their readouts are correlated through the population, and moreover the joint readout can express *combinations* of residues — seeing $p \bmod m_1$ and $q \bmod m_2$ simultaneously — that neither marginal can express.

This paper shows that this informal mechanism is an exact theorem. The discrepancy $\Delta$ is the difference of two nonnegative dependence terms of opposite effect: the label-conditional dependence of the readouts (which produces synergy) and their unconditional dependence (which produces overlap). Additivity requires those two terms to cancel exactly — a codimension-one condition on the joint law, not a consequence of any structural coprimality.

### 1.3 Contributions

1. **The pair co-information identity** (Theorem 3.1) and its complete consequence set: nonnegativity of conditional dependence (Theorem 4.3), the shared-channel overlap bound (Theorem 5.1), super-additivity of independent readouts (Theorem 5.2), the knife-edge characterisation of additivity (Theorem 5.3), the synergy ceiling (Theorem 5.4), the marginal overlap bound (Theorem 6.2), and the total-overlap theorem for refining dials (Theorem 7.1).
2. **A minimal witness** (Section 8): one three-dial battery on four individuals realising $+1$, $0$, $-1$ bits, proving that the battery space is neither additive nor comonotone and that both bounds are tight.
3. **The width-$k$ law** (Section 9): the total-correlation identity, nonnegativity of both terms by induction, the $k$-dial overlap bound, its sharpness at every width, and super-additivity of independent batteries at every width.
4. **Algorithms and numerics** (Sections 10–11): exact finite-population computation of every quantity, with worked examples reproducing the structural pattern of the measured table.

All results hold for arbitrary finite populations, arbitrary finite-valued labels, and arbitrary deterministic dials. Nothing is arithmetic-specific.

---

## 2. Setting and definitions

Throughout, $\Omega$ is a finite nonempty set, the **population**, equipped with the uniform distribution. (Uniformity is a convenience of presentation; every identity below is an identity of entropies and holds verbatim for any fixed distribution on $\Omega$.) All logarithms in definitions are natural; quantities reported in *bits* are the natural-log quantities divided by $\log 2$.

**Definition 2.1 (Statistic and entropy).** A *statistic* is any function $f : \Omega \to A$ into a set $A$. Its **entropy** is
$$H(f) = -\sum_{a \in f(\Omega)} \frac{|f^{-1}(a)|}{|\Omega|} \log \frac{|f^{-1}(a)|}{|\Omega|}.$$
Equivalently, $H(f)$ depends only on the partition of $\Omega$ into the fibres of $f$. We record this as the **fibre principle**: if $f$ and $f'$ induce the same partition — that is, $f(x) = f(y) \iff f'(x)=f'(y)$ for all $x,y$ — then $H(f) = H(f')$. The fibre principle is used constantly below to re-present a statistic in whatever encoding is convenient.

**Definition 2.2 (Pairing).** For statistics $f : \Omega \to A$, $g : \Omega \to B$, the **pair statistic** is $(f,g) : \Omega \to A\times B$, $x \mapsto (f(x), g(x))$. For a label $L$ and dials $f,g$ we also use the **triple statistic** $(L,f,g)$. By the fibre principle, entropies of pairs and triples are invariant under reordering and re-bracketing of components.

**Definition 2.3 (Mutual information).** $I(f;g) = H(f) + H(g) - H((f,g))$. It is symmetric and nonnegative, and $I(f;g) = 0$ exactly when the fibre partitions are stochastically independent.

**Definition 2.4 (Conditional entropy).** $H(g \mid L) = H((L,g)) - H(L)$. It satisfies $0 \le H(g\mid L) \le H(g)$.

**Definition 2.5 (Dial, battery, capacity).** A **dial** on $\Omega$ is a pair $(m, f)$ with $m \ge 1$ and $f : \Omega \to \{0,\dots,m-1\}$; we identify a dial with its readout $f$. A **battery** is a family $(f_i)_{i \in \iota}$ of dials indexed by a finite set, and for $S \subseteq \iota$ the **joint readout** of the sub-battery $S$ is the statistic $x \mapsto (f_i(x))_{i \in S}$. The **capacity** of the sub-battery $S$ against a label $L$ is
$$\mathrm{Cap}(S) = I\big(L; (f_i)_{i\in S}\big),$$
and the **measured synergy** of $S$, in bits, is
$$\mathrm{Syn}(S) = \frac{1}{\log 2}\Big( I\big(L; (f_i)_{i\in S}\big) - \sum_{i\in S} I(L;f_i)\Big).$$
These are exactly the quantities tabulated in §1.1: the joint column is $\mathrm{Cap}$, the additive column is $\sum_i I(L;f_i)$, and the $\Delta$ column is $\mathrm{Syn}$.

**Definition 2.6 (Pair synergy and overlap).** For a label $L$ and two dials $f,g$,
$$\Delta(L;f,g) = I(L;(f,g)) - I(L;f) - I(L;g), \qquad \mathrm{Ovl}(L;f,g) = -\Delta(L;f,g).$$
Positive $\Delta$ is **synergy**; positive $\mathrm{Ovl}$ is **overlap** (double counting by the additive prediction).

**Definition 2.7 (The two dependence terms).**
- The **unconditional readout dependence**, or *shared channel*: $\;\mathrm{Dep}(f,g) = I(f;g) = H(f)+H(g)-H((f,g))$.
- The **label-conditional dependence**:
$$\mathrm{Dep}_L(f,g) = H((L,f)) + H((L,g)) - H((L,f,g)) - H(L).$$
Equivalently $\mathrm{Dep}_L(f,g) = H(g\mid L) - H(g \mid (L,f))$: the drop in the residual uncertainty of the second readout, inside label classes, caused by learning the first.

For the arithmetic batteries of §1.1, $\mathrm{Dep}(f,g)$ has a concrete meaning: for two cubic fields of the same discriminant it is (at least) the information carried by their common quadratic character. That shared character is the channel through which the overlap flows.

---

## 3. The co-information identity

**Theorem 3.1 (Pair co-information identity).** *For any finite population $\Omega$, any label $L$, and any dials $f,g$,*
$$\Delta(L;f,g) \;=\; \mathrm{Dep}_L(f,g) \;-\; \mathrm{Dep}(f,g),$$
*that is, $I(L;(f,g)) - I(L;f) - I(L;g) = I(f;g\mid L) - I(f;g)$.*

*Proof sketch.* Expand every mutual information into entropies using Definition 2.3, and use the fibre principle to identify $(L,(f,g))$ with the triple $(L,f,g)$. The left side becomes
$$\big[H(L)+H((f,g))-H((L,f,g))\big] - \big[H(L)+H(f)-H((L,f))\big] - \big[H(L)+H(g)-H((L,g))\big],$$
and the right side becomes
$$\big[H((L,f))+H((L,g))-H((L,f,g))-H(L)\big] - \big[H(f)+H(g)-H((f,g))\big].$$
The two expressions are literally the same alternating sum
$$H((L,f)) + H((L,g)) + H((f,g)) - H(L) - H(f) - H(g) - H((L,f,g)),$$
so the identity is an algebraic rearrangement. $\square$

The symmetric expression displayed in the proof is the negative of the classical *co-information* of the triple $(L,f,g)$; Theorem 3.1 is the statement that the additivity defect of a two-dial battery **is** that co-information, read with the label distinguished.

**Remark 3.2 (Where the additivity argument goes wrong).** Additivity is the claim $\Delta = 0$. Theorem 3.1 shows this requires the *cancellation of two separate quantities*. The coprime-conductor argument reasons only about the second, $\mathrm{Dep}(f,g)$ — arguing, in effect, that transverse moduli make the readouts independent — and silently assumes the first vanishes as well. But a vanishing $\mathrm{Dep}$ makes $\Delta = \mathrm{Dep}_L \ge 0$, so the argument, corrected, predicts strict *super*-additivity in the generic case; see Theorem 5.2.

---

## 4. Nonnegativity of the conditional dependence

The first term is nonnegative, and this is *proved* rather than assumed, via a data-processing argument.

**Lemma 4.1 (Reshuffling).** $H\big(\,(g,(L,f))\,\big) = H\big((L,f,g)\big)$ and $H((g,L)) = H((L,g))$.

*Proof sketch.* Both are instances of the fibre principle: the two statistics on each side agree on a pair of individuals exactly when all the listed components agree, so they induce the same partition. $\square$

**Lemma 4.2 (Conditional dependence as an uncertainty drop).**
$$\mathrm{Dep}_L(f,g) = H(g\mid L) - H\big(g \mid (L,f)\big).$$

*Proof sketch.* Unfold both conditional entropies by Definition 2.4 and apply Lemma 4.1 to both composite statistics; the $H(L)$ and $H((L,f))$ terms cancel against those in Definition 2.7. $\square$

**Theorem 4.3 (Conditional dependence is nonnegative).** $\mathrm{Dep}_L(f,g) \ge 0$.

*Proof sketch.* Conditioning on a finer statistic cannot increase conditional entropy: if $u = \phi \circ v$ is a post-processing of $v$, then $H(g\mid v) \le H(g \mid u)$ — the data-processing inequality in conditional-entropy form. Apply this with $v = (L,f)$ and $u = L$, noting that $L$ is the first-coordinate post-processing of $(L,f)$. Then $H(g\mid(L,f)) \le H(g\mid L)$, and Lemma 4.2 concludes. $\square$

**Proposition 4.4 (Symmetry and ceilings).** $\mathrm{Dep}_L(f,g) = \mathrm{Dep}_L(g,f)$, and $\mathrm{Dep}_L(f,g) \le \min\{H(f), H(g)\}$.

*Proof sketch.* Symmetry follows from the fibre principle applied to $(L,f,g)$ versus $(L,g,f)$, since Definition 2.7 is otherwise symmetric. For the ceiling, Lemma 4.2 gives $\mathrm{Dep}_L(f,g) \le H(g\mid L) \le H(g)$, using nonnegativity of $H(g\mid(L,f))$ and monotonicity of conditional entropy; the bound by $H(f)$ follows by symmetry. $\square$

---

## 5. The two directions of the refutation

**Theorem 5.1 (Overlap is bounded by the shared channel).**
$$\mathrm{Ovl}(L;f,g) \;=\; I_1 + I_2 - I(\text{joint}) \;\le\; I(f;g).$$

*Proof sketch.* Negate Theorem 3.1 to get $\mathrm{Ovl} = \mathrm{Dep}(f,g) - \mathrm{Dep}_L(f,g)$ and apply Theorem 4.3. $\square$

This is the quantitative form of "shared conductor structure makes dials comonotone". Two cubic dials of discriminant $-23$ can overlap by $0.992$ bits only because their readouts share at least $0.992$ bits of information — in that case, essentially their entire common quadratic channel.

**Theorem 5.2 (Independent readouts can only synergize).** *If $I(f;g) = 0$ then $\Delta(L;f,g) \ge 0$.*

*Proof sketch.* Immediate from Theorem 3.1 and Theorem 4.3. $\square$

This is the strongest available form of the corrected coprime-conductor intuition. Transversality of the instruments does not yield additivity; it yields *super*-additivity, with the excess equal to the conditional dependence. The measured $+0.129$ bits is therefore the expected sign, and the interesting question becomes the *magnitude* of $\mathrm{Dep}_L$, which is structure-dependent: rich-type pairs synergize appreciably ($+0.129$), lossy-type pairs barely ($+0.005$).

**Theorem 5.3 (Additivity is a knife edge).** $\Delta(L;f,g) = 0$ *if and only if* $\mathrm{Dep}_L(f,g) = \mathrm{Dep}(f,g)$.

*Proof sketch.* Theorem 3.1 plus $a - b = 0 \iff a = b$. $\square$

Exact additivity is thus one scalar equation on the joint law of $(L,f,g)$ — a codimension-one, hence non-generic, condition. It is not implied by any structural transversality hypothesis, and a battery observed near additivity (the $+0.005$ row) should be read as a near-cancellation of two nonzero effects rather than as evidence for an additive law.

**Theorem 5.4 (Synergy ceiling).** $\Delta(L;f,g) \le \min\{H(f), H(g)\}$.

*Proof sketch.* $\Delta = \mathrm{Dep}_L - \mathrm{Dep} \le \mathrm{Dep}_L$ since $\mathrm{Dep} \ge 0$; now apply Proposition 4.4. $\square$

Synergy is funded by the *code capacity* of the instruments: you cannot extract more joint surplus than the readouts have room to encode. This has a practical reading — widening a dial's modulus raises its ceiling for synergy even when it does not raise its marginal capacity.

---

## 6. Monotonicity and the marginal overlap bound

**Lemma 6.1 (Joint dominance).** $I(L;f) \le I(L;(f,g))$ and $I(L;g) \le I(L;(f,g))$.

*Proof sketch.* $f$ is the first-coordinate post-processing of $(f,g)$, so the data-processing inequality for mutual information applies; likewise for $g$. $\square$

**Theorem 6.2 (Overlap never exceeds the smaller marginal).**
$$\mathrm{Ovl}(L;f,g) \le \min\{I(L;f),\, I(L;g)\}, \qquad \text{equivalently } \Delta \ge -\min\{I_1,I_2\}.$$

*Proof sketch.* Suppose $I_1 \le I_2$. By Lemma 6.1, $I(\text{joint}) \ge I_2$, so $\Delta = I(\text{joint}) - I_1 - I_2 \ge -I_1 = -\min\{I_1,I_2\}$. The other case is symmetric. $\square$

In the measured table the two $-23$ cubics have $I_1 = I_2 = 1.0012$ bits and overlap $0.992$ bits: they attain $99.1\%$ of this bound, i.e. they are within one percent of being literally the same instrument.

Combining Theorems 5.4 and 6.2 gives the **two-sided law for a two-dial battery**:
$$-\min\{I(L;f),\, I(L;g)\} \;\le\; \Delta(L;f,g) \;\le\; \min\{H(f),\, H(g)\}.$$

---

## 7. "Same subfield = same dial": total overlap

**Theorem 7.1 (A refining dial contributes nothing).** *If $g = u \circ f$ for some function $u$, then*
$$I(L;(f,g)) = I(L;f), \qquad \Delta(L;f,g) = -I(L;g).$$

*Proof sketch.* The fibres of $(f,g) = (f, u\circ f)$ coincide with the fibres of $f$: if $f(x)=f(y)$ then automatically $u(f(x))=u(f(y))$. By the fibre principle every entropy involving $(f,g)$ equals the corresponding entropy involving $f$, hence $I(L;(f,g)) = I(L;f)$ and $\Delta = I(L;f) - I(L;f) - I(L;g)$. $\square$

**Corollary 7.2 (The comonotone extreme).** $\mathrm{Ovl}(L;f,f) = I(L;f)$: a duplicated dial costs exactly a full marginal.

**Corollary 7.3 (Theorem 5.1 is sharp).** Taking $g = f$ and $L = f$ gives $\mathrm{Ovl}(f;f,f) = I(f;f) = H(f)$: the overlap bound by the shared channel is attained with equality, so no better universal bound of that form exists.

Theorem 7.1 is the exact form of the slogan *"same subfield = same dial"*. Two cubic fields sharing their quadratic resolvent are not literally in a post-processing relation, but they are close to one, and the measured $0.992/1.0012$ ratio quantifies how close.

---

## 8. A minimal witness: all three signs in one battery

Abstract two-sidedness is established by the theorems above; the following finite example shows that the *extreme* values are realised, and by a single battery.

**Construction 8.1.** Let $\Omega = \{0,1\}^2$ — four individuals, uniformly weighted. Define three dials of modulus $2$:
- dial $0$: $f_0(b_1,b_2) = b_1$ (the first bit);
- dial $1$: $f_1(b_1,b_2) = b_2$ (the second bit);
- dial $2$: $f_2 = f_0$, a deliberate duplicate — the "shared conductor" instrument.

Define two labels: the **parity** $L_\oplus(b_1,b_2) = b_1 \oplus b_2$ and the **first-bit** label $L_1(b_1,b_2) = b_1$.

**Lemma 8.2 (Marginals on four individuals).** $H(f_0)=H(f_1)=H(L_\oplus)=H(L_1)=1$ bit; each of the pairs $(L_\oplus,f_0)$, $(L_\oplus,f_1)$, $(L_1,f_1)$, $(f_0,f_1)$ separates all four individuals and hence has entropy $2$ bits.

*Proof sketch.* Each single statistic has two fibres of size two; each listed pair has four singleton fibres. Entropy of a uniform statistic with $n$ equal cells is $\log n$. $\square$

**Proposition 8.3 (Capacities).** $I(L_\oplus;f_0) = I(L_\oplus;f_1) = 0$; $I(L_1;f_1) = 0$; $I(L_1;f_0) = 1$; $I(L_\oplus;(f_0,f_1)) = 1$; $I(L_1;(f_0,f_1)) = 1$ (all in bits).

*Proof sketch.* The vanishing ones follow from $1 + 1 - 2 = 0$ using Lemma 8.2. The nonvanishing ones follow because the relevant statistic *determines* the label — $(f_0,f_1)$ determines both labels and $f_0$ determines $L_1$ — and when a statistic determines the label the mutual information equals the label entropy, here $1$ bit. $\square$

**Theorem 8.4 (Three rows, three signs).**
- **Synergy row:** $\Delta(L_\oplus; f_0, f_1) = +1$ bit. Both dials are individually blind to parity; jointly they pin it. This attains the label-entropy ceiling.
- **Additive row:** $\Delta(L_1; f_0, f_1) = 0$. Dial $0$ carries the whole bit, dial $1$ carries nothing, the joint carries the bit.
- **Overlap row:** $\Delta(L_1; f_0, f_2) = -1$ bit. Dial $2$ duplicates dial $0$; the additive prediction double-counts a full bit.

*Proof sketch.* Substitute Proposition 8.3 into Definition 2.6 for the first two rows; the third is Theorem 7.1 with $u = \mathrm{id}$ together with $I(L_1;f_0)=1$. $\square$

**Theorem 8.5 (The identity accounts for both signs).** *In the synergy row, $I(f_0;f_1) = 0$ and $\mathrm{Dep}_{L_\oplus}(f_0,f_1) = 1$ bit. In the overlap row, $I(f_0;f_2) = 1$ bit and $\mathrm{Dep}_{L_1}(f_0,f_2) = 0$. Both rows satisfy $\Delta = \mathrm{Dep}_L - \mathrm{Dep}$.*

*Proof sketch.* $I(f_0;f_1) = 1+1-2 = 0$ by Lemma 8.2, and $I(f_0;f_0) = H(f_0) = 1$. Then Theorem 3.1, applied in reverse to the already-computed $\Delta$ values of Theorem 8.4, yields the two conditional dependences. $\square$

Thus the $+1$ is *pure conditional coupling with no shared channel*, and the $-1$ is *pure shared channel with no conditional coupling*: the two engines of Theorem 3.1 isolated one at a time.

**Theorem 8.6 (Neither additive nor comonotone).** *There is no valid universal inequality $\Delta \ge 0$ and no valid universal inequality $\Delta \le 0$ for two-dial batteries — not even after fixing the population and the dial family. Moreover the overlap row saturates both derived bounds simultaneously:*
$$\mathrm{Ovl}(L_1;f_0,f_2) = \min\{I(L_1;f_0), I(L_1;f_2)\} = I(f_0;f_2) = 1 \text{ bit}.$$

*Proof sketch.* Theorem 8.4 exhibits a strictly positive row and a strictly negative row within one battery; the saturation statement follows from Corollaries 7.2–7.3 specialised to this population. $\square$

Note the additional force of the example: the *same* pair of dials $\{0,1\}$ is strictly super-additive against one label and exactly additive against another. Whether a battery synergizes is therefore not a property of the instruments alone; it is a joint property of instruments and target.

---

## 9. The width-$k$ law

The measured table concerns pairs, but the operational claim — that $k$ dials give more than $k$ times a marginal for structurally rich families and less for shared-structure families — is a statement about arbitrary width. It generalises exactly.

**Definition 9.1 (Total correlation).** For a battery $(f_i)_{i\in\iota}$ and finite $S \subseteq \iota$, with $J_S$ denoting the joint readout of $S$,
$$\mathrm{TC}(S) = \sum_{i \in S} H(f_i) - H(J_S), \qquad \mathrm{TC}_L(S) = \sum_{i\in S} H(f_i \mid L) - H(J_S \mid L).$$
$\mathrm{TC}$ is the excess cost of transmitting the readouts separately over transmitting them jointly; it vanishes exactly when the readouts are jointly independent. $\mathrm{TC}_L$ is the same quantity measured inside label classes.

**Definition 9.2 (Width-$k$ synergy).** $\displaystyle \Delta(S) = I(L;J_S) - \sum_{i\in S} I(L;f_i)$.

For $|S| = 2$, Definitions 9.1–9.2 reduce to Definitions 2.6–2.7.

**Lemma 9.3 (Conditional subadditivity).** $H((u,v)\mid L) \le H(u\mid L) + H(v\mid L)$.

*Proof sketch.* Unfolding conditional entropies and applying the reshuffling Lemma 4.1, the claimed inequality is literally the statement $\mathrm{Dep}_L(u,v) \ge 0$, i.e. Theorem 4.3. $\square$

**Theorem 9.4 (Both correlation terms are nonnegative).** $\mathrm{TC}(S) \ge 0$ and $\mathrm{TC}_L(S) \ge 0$ for every finite $S$.

*Proof sketch.* Induction on $S$. For $S = \emptyset$ the joint readout is constant, so both terms are $0$. For the inductive step $S \to S \cup \{a\}$ with $a \notin S$: the joint readout of $S \cup \{a\}$ has the same fibres as the pair $(f_a, J_S)$ (this is the only genuinely combinatorial step: agreeing on all coordinates of $S\cup\{a\}$ is the same as agreeing on $f_a$ and on all coordinates of $S$). Then unconditional subadditivity $H((f_a,J_S)) \le H(f_a) + H(J_S)$ gives the step for $\mathrm{TC}$, and Lemma 9.3 gives it for $\mathrm{TC}_L$. $\square$

**Theorem 9.5 (Width-$k$ co-information law).** *For every finite $S$,*
$$\Delta(S) = \mathrm{TC}_L(S) - \mathrm{TC}(S).$$

*Proof sketch.* Write each conditional entropy as $H(f_i\mid L) = H((L,f_i)) - H(L)$ and $H(J_S\mid L) = H((L,J_S)) - H(L)$, using the reshuffling lemma to order components. Write each mutual information as $I(L;f_i) = H(L) + H(f_i) - H((L,f_i))$ and similarly for $J_S$. Substituting into both sides, the $|S|$ copies of $H(L)$ arising from the sum cancel against the $|S|\cdot H(L)$ appearing in $\mathrm{TC}_L$, and the remaining terms match term by term. $\square$

**Theorem 9.6 ($k$-dial overlap bound).** $\Delta(S) \ge -\mathrm{TC}(S)$.

*Proof sketch.* Theorem 9.5 plus $\mathrm{TC}_L(S) \ge 0$. $\square$

**Theorem 9.7 (Independent batteries are super-additive at every width).** *If $\mathrm{TC}(S) = 0$ then $\Delta(S) \ge 0$.*

**Theorem 9.8 (Synergy ceiling at width $k$).** $\Delta(S) \le \mathrm{TC}_L(S)$: the joint readout can extract at most what the label classes still correlate.

**Theorem 9.9 (Sharpness at every width).** *Let every dial in $S$ read the same statistic $u$, with $S$ nonempty, and let the label be $u$ itself. Then*
$$\mathrm{TC}(S) = (|S| - 1)H(u), \qquad \Delta(S) = -(|S|-1)H(u) = -\mathrm{TC}(S).$$

*Proof sketch.* The joint readout of $S$ has the same fibres as $u$, so $H(J_S) = H(u)$ and $I(u;J_S) = H(u)$; each marginal capacity is $I(u;u)=H(u)$. Substituting into Definitions 9.1–9.2 gives both formulas. $\square$

So the overlap bound of Theorem 9.6 is attained with equality at every width, by a battery of $k$ copies of one instrument: the width-$k$ form of "same subfield = same dial", in which $k-1$ instruments are each wasted in full.

**Corollary 9.10 (The two-sided width-$k$ law).**
$$-\mathrm{TC}(S) \;\le\; \Delta(S) \;\le\; \mathrm{TC}_L(S),$$
*with the left inequality attained by duplicated batteries at every width and the right inequality attained whenever the readouts are jointly independent (Theorem 9.7 with equality when moreover $\mathrm{TC}_L$ is fully extracted, as in the parity witness).*

---

## 10. Algorithms

All quantities above are computable exactly on a finite population by fibre counting. We record the algorithms with their complexities; $n = |\Omega|$ and $k = |S|$.

### 10.1 Empirical entropy of a statistic

Group individuals by readout value and sum $-\hat p \log \hat p$ over the resulting cells.

```
ENTROPY(f, Omega):
  counts <- empty map
  for x in Omega:  counts[f(x)] += 1
  n <- |Omega|
  return - sum over c in counts.values of (c/n) * log(c/n)
```
Cost: $O(n)$ evaluations of $f$ plus $O(n)$ hashing; memory $O(|f(\Omega)|)$.

### 10.2 Pair synergy and its decomposition

Compute the five entropies $H(L), H(f), H(g), H((L,f)), H((L,g)), H((f,g)), H((L,f,g))$ and assemble.

```
PAIR_DECOMPOSITION(L, f, g, Omega):
  HL   <- ENTROPY(L);   Hf <- ENTROPY(f);    Hg <- ENTROPY(g)
  HLf  <- ENTROPY(x -> (L(x), f(x)))
  HLg  <- ENTROPY(x -> (L(x), g(x)))
  Hfg  <- ENTROPY(x -> (f(x), g(x)))
  HLfg <- ENTROPY(x -> (L(x), f(x), g(x)))
  I1   <- HL + Hf - HLf
  I2   <- HL + Hg - HLg
  Ijnt <- HL + Hfg - HLfg
  Delta   <- Ijnt - I1 - I2
  Dep     <- Hf + Hg - Hfg                      # unconditional dependence
  DepL    <- HLf + HLg - HLfg - HL              # conditional dependence
  assert Delta == DepL - Dep                    # co-information identity
  return (I1, I2, Ijnt, Delta, DepL, Dep)
```
Cost: $O(n)$ overall, seven linear passes. The assertion is an exact identity up to floating-point rounding and serves as a runtime check.

### 10.3 Width-$k$ decomposition

```
BATTERY_DECOMPOSITION(L, (f_1..f_k), Omega):
  J        <- x -> (f_1(x), ..., f_k(x))
  HL       <- ENTROPY(L)
  HJ       <- ENTROPY(J)
  HLJ      <- ENTROPY(x -> (L(x), J(x)))
  sumH     <- sum_i ENTROPY(f_i)
  sumHcond <- sum_i ( ENTROPY(x -> (L(x), f_i(x))) - HL )
  sumI     <- sum_i ( HL + ENTROPY(f_i) - ENTROPY(x -> (L(x), f_i(x))) )
  I_joint  <- HL + HJ - HLJ
  TC       <- sumH - HJ
  TC_L     <- sumHcond - (HLJ - HL)
  Delta    <- I_joint - sumI
  assert Delta == TC_L - TC
  return (I_joint, sumI, Delta, TC, TC_L)
```
Cost: $O(kn)$ time, dominated by the $k$ marginal passes and the joint pass; memory $O(n)$ for the joint fibre table in the worst case (the joint readout can have up to $n$ distinct values).

### 10.4 Greedy battery construction under the overlap bound

A practical consequence: when assembling a battery from a catalogue of candidate dials, the marginal capacity of a candidate is an upper bound on its *contribution* only after subtracting its overlap with what is already installed. The following greedy selection uses the exact increment rather than the marginal score.

```
GREEDY_BATTERY(L, candidates, k, Omega):
  S <- empty; J <- constant statistic
  repeat k times:
    best <- argmax over f in candidates \ S of  [ I(L; (J,f)) - I(L; J) ]
    S <- S + {best}; J <- (J, best)
  return S
```
Each increment $I(L;(J,f)) - I(L;J)$ is the *conditional* capacity of $f$ given the installed battery; by Theorem 3.1 applied with the installed joint readout in place of $f$, it equals $I(L;f) + \mathrm{Dep}_L(J,f) - \mathrm{Dep}(J,f)$, i.e. the marginal score corrected by the two dependence terms. Cost: $O(k \cdot |\text{candidates}| \cdot n)$.

---

## 11. Numerical demonstrations

The following exact computations on small populations reproduce, in miniature, each structural phenomenon of the measured table. (Full code accompanies this work; the values below are exact rationals in bits.)

**11.1 Pure synergy (parity).** $\Omega = \{0,1\}^2$, $f_0 = b_1$, $f_1 = b_2$, $L = b_1\oplus b_2$:
$$I_1 = I_2 = 0, \quad I(\text{joint}) = 1, \quad \Delta = +1, \quad \mathrm{Dep} = 0, \quad \mathrm{Dep}_L = 1.$$

**11.2 Exact additivity.** Same population and dials, $L = b_1$:
$$I_1 = 1,\ I_2 = 0,\ I(\text{joint}) = 1,\ \Delta = 0, \quad \mathrm{Dep} = \mathrm{Dep}_L = 0.$$

**11.3 Total overlap.** Same population, $L = b_1$, dials $f_0$ and its duplicate:
$$I_1 = I_2 = 1,\ I(\text{joint}) = 1,\ \Delta = -1, \quad \mathrm{Dep} = 1,\ \mathrm{Dep}_L = 0.$$

**11.4 Partial overlap, continuously tunable.** Let $\Omega$ consist of triples of bits with $f_0 = (b_1,b_2)$ and $f_1 = (b_2,b_3)$ sharing the middle bit, and $L = b_1 \oplus b_3$. Then the shared channel is exactly one bit while the conditional dependence is also positive, and $\Delta$ interpolates: this is the generic regime of the measured $+0.129$ and $+0.005$ rows, where both engines are active and the sign is decided by their difference.

**11.5 Width-$k$ duplication.** For $k$ copies of a fair bit read against that bit, $\mathrm{TC} = k-1$ and $\Delta = -(k-1)$ exactly, matching Theorem 9.9 for every $k$ tested.

**11.6 Random batteries.** Sampling random dials on random populations and computing $\Delta$: the distribution of $\Delta$ is supported on both signs, with exact zeros occurring only on measure-zero coincidences, in agreement with Theorem 5.3. This is the statistical sense in which "additivity is a knife edge".

---

## 12. Discussion

### 12.1 What the identity decides

The pre-registered additivity hypothesis was not merely falsified; it was *replaced* by an exact law with sharp two-sided bounds. Three specific consequences follow for the measurement programme that produced the table.

1. **Product batteries are covered with their synergy excesses included.** The width-$k$ law shows that a battery of $k$ dials delivers more than $k$ times a marginal for structurally rich families and less for shared-structure families, and that both deviations are computable by exactly the same joint machinery used for a single dial. No new instrument class is needed to account for the excesses.
2. **Overlap is always auditable.** Theorems 5.1 and 9.6 bound the double-counting by an observable quantity — the mutual information (respectively total correlation) of the raw readouts, which does not involve the label at all. One can therefore certify, before ever computing a joint capacity, how large the overlap *could* be.
3. **Redundancy has an exact signature.** Theorem 7.1 makes "same subfield = same dial" a theorem rather than a slogan: post-processing relations cost exactly a full marginal. The observed $0.992$ against a bound of $1.0012$ locates the two $-23$ cubics at $99.1\%$ of that extreme.

### 12.2 Relation to classical information theory

The quantity $\mathrm{Dep}_L - \mathrm{Dep}$ is, up to sign conventions, the *interaction information* or *co-information* of a triple, known since the mid twentieth century, and total correlation is likewise classical. The contribution here is not the invention of those functionals but the identification of the additivity defect of a measurement battery *with* them, the derivation of the complete set of two-sided bounds in that language, the demonstration that all extreme values are simultaneously realisable in a four-element population, and the exact extension to arbitrary width with attainment at every width. In particular, Theorem 4.3 is derived from a data-processing argument rather than posited, which matters because the nonnegativity of *unconditional* mutual information and the nonnegativity of *conditional* mutual information are logically distinct facts, and conflating them is exactly the error in the additivity argument.

We stress the asymmetry that makes the subject non-trivial: $\mathrm{Dep} \ge 0$ and $\mathrm{Dep}_L \ge 0$, but their difference is unsigned. Information does not decompose into a lattice of nonnegative atoms in any way that respects both terms — the failure of nonnegativity for co-information is precisely the phenomenon measured in the table.

### 12.3 Limitations

The results are stated for finite populations and deterministic dials under a fixed distribution, and all are exact identities and inequalities about empirical entropies. Nothing here addresses *estimation*: for a sampled population, the plug-in estimators of $H$ are biased downward, and the bias in $\Delta$ is a difference of biases of different orders (the joint term has the largest alphabet and the largest bias). A measured small positive $\Delta$ — such as the $+0.005$ row — is therefore not by itself evidence of genuine synergy without a bias analysis; the $+0.129$ and $-0.992$ rows are far outside any plausible bias scale. Second, the bounds are *universal*: they hold for every battery and are attained, but they are not predictions for a particular arithmetic family. Predicting the magnitude of $\mathrm{Dep}_L$ from the Galois-theoretic type of the dials remains open (§13).

### 12.4 Applications

- **Feature selection.** Ranking features by marginal mutual information and keeping the top $k$ is unsound in both directions: it double-counts redundant features and discards individually-uninformative but jointly-decisive ones. The parity witness is the minimal counterexample, and Theorem 5.3 shows that the additive assumption underlying such ranking is non-generic. The greedy algorithm of §10.4, which scores conditional increments, is the corrected procedure.
- **Sensor fusion and experimental design.** Theorem 5.1 gives a label-free pre-audit of redundancy: measure $I(f;g)$ on raw readouts to cap possible double-counting. Theorem 9.6 extends this to whole sensor arrays via total correlation.
- **Interaction and epistasis analysis.** "Neither factor alone, both together" is $\Delta > 0$, and Theorem 3.1 localises it as conditional dependence exceeding unconditional dependence — an operational test that distinguishes genuine interaction from shared confounding.
- **Ensemble design.** The folklore preference for "diverse" ensemble members is $\mathrm{TC} \approx 0$, and Theorem 9.7 states what diversity guarantees: super-additivity at every width.
- **Privacy and leakage auditing.** The same calculus bounds how much a collection of released statistics can jointly reveal beyond the sum of individual releases; Theorem 9.8 caps the excess by the conditional total correlation.

---

## 13. Future directions

### 13.1 Overlap–capacity duality on the battery lattice

**Conjecture.** For a fixed population and label, the map $S \mapsto I(L; J_S)$ on sub-batteries is *submodular*, and the failure of modularity at a pair $\{i,j\}$ is exactly the pair co-information of that pair conditioned on the rest of the battery.

The key insight is that the width-$k$ identity proved here is the telescoping of pairwise co-informations along any ordering of the battery, so modularity defects must localise at pairs conditioned on their predecessors. The chain-rule machinery used for the width-$k$ induction is now in place, so the telescoping argument is a short step from the nonnegativity of conditional total correlation.

**Caution.** A three-dial parity battery already refutes naive submodularity: two of its pairs carry zero capacity while the full triple carries one bit. The sharp form to test is therefore submodularity of $S \mapsto H(J_S)$, together with a *supermodularity* regime for capacity on batteries whose readouts are pairwise independent.

### 13.2 A synergy ceiling in terms of unused code capacity

**Conjecture.** At width $k$,
$$\Delta(S) \;\le\; \sum_{i\in S}\big(H(f_i) - I(L;f_i)\big) \;-\; (k-1)\big(H(L) - I(L;J_S)\big),$$
i.e. synergy is funded by unused per-dial code capacity and further taxed by residual label uncertainty.

The key insight is that $\Delta \le \mathrm{TC}_L$ is already proved, and $\mathrm{TC}_L$ is itself bounded by the conditional entropies of the readouts, which are exactly the unused code capacities. The remaining half is the tax term.

### 13.3 Further directions

- **Predicting $\mathrm{Dep}_L$ from structure.** The measured rows suggest that synergy magnitude tracks the "richness" of the dial types ($+0.129$ for rich-type pairs, $+0.005$ for lossy-type pairs). A predictive formula for $\mathrm{Dep}_L$ in terms of the Galois-theoretic type of the underlying fields would upgrade the law from descriptive to predictive.
- **Estimation theory for $\Delta$.** Bias-corrected estimators for the additivity defect, with confidence intervals valid under the small-sample regimes in which batteries are usually measured.
- **Continuous and infinite populations.** All identities are entropy algebra and should survive verbatim for differential entropies under mild regularity; the data-processing argument behind nonnegativity of the conditional dependence generalises directly.
- **Optimal battery assembly.** Given a catalogue of dials and a budget $k$, characterise the optimal battery. Theorem 9.6 bounds the loss from redundancy and Theorem 9.8 the gain from synergy; the gap between these is a concrete optimisation target.

---

## 14. Conclusion

The additivity of measurement capacity is not a law. It is a coincidence, and the exact conditions for that coincidence are now known: two instruments read against a common label are additive precisely when their label-conditional dependence equals their unconditional dependence. The defect from additivity equals the difference of these two nonnegative quantities, which is why it is unsigned; it is bounded below by the shared structure of the readouts and above by their coding capacity; it equals a full marginal in the redundant extreme and the full label entropy in the maximally synergistic extreme; and every one of these statements survives verbatim to arbitrary battery width with total correlation replacing pairwise dependence, sharp at every width.

Two instruments pointed at the same world are never two independent instruments. The exact amount by which they fail to be independent, split into the part that duplicates and the part that combines, is the content of the theory developed here.
