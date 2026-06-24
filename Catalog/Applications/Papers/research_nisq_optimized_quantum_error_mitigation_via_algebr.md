# Two Invariants of NISQ Error Mitigation: A Sharp Majority-Vote Threshold and the Persistence of $H_0$

**Author:** Aristotle

**Domain:** Logic (Logic ↔ Algebraic Topology bridge)

**Date:** 2026-06-24

---

## Abstract

We study the combinatorial and topological foundations of error mitigation
for noisy intermediate-scale quantum (NISQ) experiments, in which a logical
bit is estimated by repeating a measurement and aggregating noisy readouts.
We present two rigorously established invariants that describe the same
phenomenon — the survival of a majority cluster of correct answers — from
two complementary viewpoints.

On the **logic** (combinatorial) side, we analyze the repetition code under
majority-vote decoding. We prove an exact worst-case correctness threshold:
the majority decoder recovers the true logical bit whenever the Hamming
weight of the error pattern is strictly below $n/2$, where $n$ is the number
of repetitions. We prove a clean biconditional for the all-`true` codeword,
identify precisely why the biconditional must fail for the `false` codeword
at an exact tie (a consequence of the strict-inequality tie-break), and we
exhibit an explicit even-length witness establishing that the $n/2$ threshold
is sharp and the guarantee non-vacuous.

On the **algebraic-topology** side, we model a persistent-homology filtration
by a chain of refining relations on a finite vertex set and prove that the
zeroth Betti number $\beta_0$ — the number of connected components — is
monotone non-increasing along the filtration ("$H_0$ persistence"). The proof
constructs a surjective component map between connected-component quotients
and concludes by cardinality. A non-degeneracy witness exhibits a genuine
merge event, ensuring the monotonicity is not vacuously an equality.

All results are formalized and machine-checked. We close with four falsifiable
conjectures linking the two invariants, including a proposed equality of the
topological and combinatorial decision boundaries below threshold and a
conjectured exponential error-suppression rate governed by the longest $H_0$ bar.

---

## 1. Introduction

Near-term quantum processors operate in the NISQ regime: circuit depth and
qubit count are limited, and every measurement is corrupted by appreciable
noise. A standard mitigation primitive is *repetition*: run the same logical
operation many times, collect a population of noisy classical readouts, and
infer the intended logical value from the population. The simplest instance is
the classical repetition code with majority-vote decoding.

This paper isolates the mathematical heart of that primitive and develops it
along two axes:

1. **Counting (logic).** Errors are measured by Hamming weight, and decoding is
   a threshold on a count. We determine the exact correctness threshold and its
   sharpness.

2. **Shape (topology).** Readouts are organized as a proximity filtration, and
   the relevant invariant is the zeroth persistent Betti number $\beta_0$, the
   number of connected components. We prove monotone decay of $\beta_0$ along
   the filtration.

The conceptual thesis is that these two invariants track the same object — the
majority cluster of correct answers — and that the topological invariant offers
a route to noise-robust decoding via the mature machinery of topological data
analysis (TDA). The present work pins down both endpoints rigorously; Section 7
states the conjectural bridge between them.

Throughout, $n$ denotes the number of repetitions; a readout vector is a
function $s : \mathrm{Fin}\,n \to \mathrm{Bool}$, where $\mathrm{Fin}\,n =
\{0, \dots, n-1\}$ and $\mathrm{Bool} = \{\text{false}, \text{true}\}$. We
identify the logical bit values $0, 1$ with $\text{false}, \text{true}$.

---

## 2. The Repetition Code: Definitions

**Definition 1 (Ones count).**
For a readout vector $s : \mathrm{Fin}\,n \to \mathrm{Bool}$, the number of
`true` readouts is
$$\mathrm{ones}(s) \;=\; \#\{\, i \in \mathrm{Fin}\,n : s(i) = \text{true} \,\}.$$

**Definition 2 (Error count / Hamming weight).**
Given a true logical bit $b \in \mathrm{Bool}$, the number of corrupted readouts is
$$\mathrm{errors}(s, b) \;=\; \#\{\, i \in \mathrm{Fin}\,n : s(i) \neq b \,\}.$$
This is the Hamming distance between the readout vector $s$ and the constant
codeword $\overline{b} = (b, b, \dots, b)$.

**Definition 3 (Majority decoder).**
The majority-vote decoder is
$$\mathrm{majority}(s) \;=\; \big[\, 2 \cdot \mathrm{ones}(s) > n \,\big] \in \mathrm{Bool},$$
returning `true` exactly when strictly more than half of the readouts are
`true`, and `false` otherwise. The strict inequality breaks ties toward
`false`.

The following elementary identity, used repeatedly below, relates the two
counts and is the formal hinge of all three theorems. For a finite index set,
partitioning the universe into the positions where $s(i) = \text{true}$ and its
complement gives
$$\mathrm{ones}(s) + \#\{\, i : s(i) = \text{false} \,\} = n.$$
Consequently:

- If $b = \text{true}$, then $\mathrm{errors}(s, \text{true}) = \#\{i : s(i) =
  \text{false}\} = n - \mathrm{ones}(s)$.
- If $b = \text{false}$, then $\mathrm{errors}(s, \text{false}) = \#\{i : s(i) =
  \text{true}\} = \mathrm{ones}(s)$.

The dependence of $\mathrm{ones}$ on $\mathrm{errors}$ thus *flips* with the
parity of the true bit $b$; this is the source of the asymmetry in Section 3.

---

## 3. The Repetition Code: Main Results

### 3.1 Worst-case correctness threshold

**Theorem 1 (Repetition-code correctness, `majority_decode_correct`).**
For every readout $s : \mathrm{Fin}\,n \to \mathrm{Bool}$ and every true bit
$b \in \mathrm{Bool}$,
$$2 \cdot \mathrm{errors}(s, b) < n \;\;\Longrightarrow\;\; \mathrm{majority}(s) = b.$$

*Proof sketch.* Case split on $b$.

- If $b = \text{true}$: by the identity in Section 2,
  $\mathrm{errors}(s, \text{true}) = n - \mathrm{ones}(s)$. The hypothesis
  $2(n - \mathrm{ones}(s)) < n$ rearranges to $2\,\mathrm{ones}(s) > n$, which
  is exactly the condition under which $\mathrm{majority}(s) = \text{true}$.

- If $b = \text{false}$: here $\mathrm{errors}(s, \text{false}) =
  \mathrm{ones}(s)$, so the hypothesis reads $2\,\mathrm{ones}(s) < n$, whence
  $2\,\mathrm{ones}(s) \not> n$ and $\mathrm{majority}(s) = \text{false}$.

Both branches reduce, after applying the complement-cardinality identity
$\mathrm{ones}(s) + \#\{i : s(i) = \text{false}\} = n$, to a single linear
arithmetic step. $\;\blacksquare$

This is a *worst-case* (adversarial) guarantee: it holds for every error
pattern of Hamming weight below $n/2$, regardless of which positions are
corrupted.

### 3.2 Exact threshold for the `true` codeword

**Theorem 2 (Exact threshold, `true` codeword, `majority_decode_correct_iff`).**
For every readout $s : \mathrm{Fin}\,n \to \mathrm{Bool}$,
$$\mathrm{majority}(s) = \text{true} \;\;\Longleftrightarrow\;\; 2 \cdot \mathrm{errors}(s, \text{true}) < n.$$

*Proof sketch.* Unfolding definitions, $\mathrm{majority}(s) = \text{true}$ iff
$2\,\mathrm{ones}(s) > n$. Using $\mathrm{errors}(s, \text{true}) = n -
\mathrm{ones}(s)$ from the complement-cardinality identity, the condition
$2\,\mathrm{ones}(s) > n$ is equivalent to $2(n - \mathrm{ones}(s)) < n$, i.e.
$2\,\mathrm{errors}(s, \text{true}) < n$. Both directions follow by linear
arithmetic. $\;\blacksquare$

**Remark (asymmetry of the biconditional).** The analogous biconditional for
$b = \text{false}$ is *false*. The forward implication $2\,\mathrm{errors}(s,
\text{false}) < n \Rightarrow \mathrm{majority}(s) = \text{false}$ holds by
Theorem 1, but its converse fails at the exact tie $2\,\mathrm{errors}(s,
\text{false}) = n$: there the decoder correctly outputs `false` (the strict
`>` tie-break favors `false`) even though exactly half the readouts are
corrupted. Hence the clean iff is available only for the `true` codeword. This
is not a defect; it is the precise consequence of the tie-break convention, and
stating it honestly is essential to a faithful formalization.

### 3.3 Sharpness of the threshold

**Theorem 3 (Tightness of the $n/2$ threshold, `majority_threshold_tight`).**
For every $k \geq 1$, on length $n = 2k$ there exists a readout
$s : \mathrm{Fin}\,(2k) \to \mathrm{Bool}$ with
$$\mathrm{errors}(s, \text{true}) = k \qquad\text{and}\qquad \mathrm{majority}(s) \neq \text{true}.$$

*Proof sketch.* Define the explicit witness
$$s(i) = \begin{cases} \text{true} & \text{if } i < k, \\ \text{false} & \text{if } i \geq k. \end{cases}$$
The positions with $s(i) = \text{false}$ are exactly $\{k, k+1, \dots, 2k-1\}$,
a set of cardinality $k$; since these are precisely the corrupted positions
relative to $b = \text{true}$, we have $\mathrm{errors}(s, \text{true}) = k$.
(Formally, one exhibits a bijection between this filtered set and an index set
of size $k$, e.g. $i \mapsto i + k$.) Moreover $\mathrm{ones}(s) = k$, so
$2\,\mathrm{ones}(s) = 2k = n$, which is *not* strictly greater than $n$; hence
$\mathrm{majority}(s) = \text{false} \neq \text{true}$. The vector has exactly
half its entries corrupted and the decoder fails. $\;\blacksquare$

Theorems 1 and 3 together establish that $n/2$ is the exact correctness radius
of the repetition code under majority decoding: every weight strictly below
$n/2$ is corrected, and weight exactly $n/2$ (for even $n$) admits a failure.
Theorem 3 also certifies non-vacuity: the guarantee of Theorem 1 has a genuine
boundary rather than holding trivially.

---

## 4. Persistent $H_0$: Definitions

We now develop the topological invariant. Fix a finite vertex type $V$ (the
measurement outcomes / data points). A binary relation $r : V \to V \to
\mathrm{Prop}$ encodes "linked at a given proximity threshold." Connected
components are the equivalence classes of the *equivalence closure* of $r$,
denoted $\mathrm{EqvGen}(r)$: the smallest equivalence relation containing $r$,
i.e. the reflexive–symmetric–transitive closure. The set of components is the
quotient $\mathrm{Quot}(\mathrm{EqvGen}(r))$.

**Definition 4 (Zeroth Betti number, `betti0`).**
For a relation $r$ on $V$ whose component quotient is finite,
$$\beta_0(r) \;=\; \#\,\mathrm{Quot}\big(\mathrm{EqvGen}(r)\big),$$
the number of connected components of the graph $(V, r)$. (Finiteness of the
quotient is taken as an explicit hypothesis, since a quotient of a finite type
need not admit a computable decidable-equality structure; keeping it as an
instance argument keeps the statement honest.)

**Definition 5 (Component map, `componentMap`).**
Let $r_1, r_2$ be relations on $V$ with $r_1 \subseteq r_2$ (that is,
$r_1(a,b) \Rightarrow r_2(a,b)$ for all $a, b$). The induced component map
$$\mathrm{componentMap}(r_1, r_2) : \mathrm{Quot}(\mathrm{EqvGen}(r_1)) \to \mathrm{Quot}(\mathrm{EqvGen}(r_2))$$
sends the $r_1$-component of a vertex $a$ to its $r_2$-component. It is
well-defined because $\mathrm{EqvGen}$ is monotone in its base relation: if
$r_1 \subseteq r_2$, then $\mathrm{EqvGen}(r_1) \subseteq \mathrm{EqvGen}(r_2)$,
so $r_1$-equivalent vertices remain $r_2$-equivalent and the quotient map
descends.

A *filtration step* is precisely such a refinement $r_1 \subseteq r_2$: raising
the proximity threshold can only add links.

---

## 5. Persistent $H_0$: Main Results

**Lemma 1 (Surjectivity of the component map, `componentMap_surjective`).**
If $r_1 \subseteq r_2$, then $\mathrm{componentMap}(r_1, r_2)$ is surjective.

*Proof sketch.* Let $y \in \mathrm{Quot}(\mathrm{EqvGen}(r_2))$ be an arbitrary
$r_2$-component. The quotient map $\mathrm{Quot.mk}$ is surjective, so $y$ has a
representative vertex $a$ with $y = [a]_{r_2}$. Then the $r_1$-component
$[a]_{r_1}$ satisfies $\mathrm{componentMap}(r_1, r_2)([a]_{r_1}) = [a]_{r_2} =
y$. Hence every $r_2$-component is hit. $\;\blacksquare$

**Theorem 4 ($H_0$ persistence, `betti0_persistence`).**
If $r_1 \subseteq r_2$ on a finite vertex type $V$ (with both component
quotients finite), then
$$\beta_0(r_2) \;\leq\; \beta_0(r_1).$$
The zeroth Betti number is monotone non-increasing along a filtration.

*Proof sketch.* By Lemma 1 the component map
$\mathrm{Quot}(\mathrm{EqvGen}(r_1)) \to \mathrm{Quot}(\mathrm{EqvGen}(r_2))$ is
surjective. A surjection between finite types forces the cardinality of the
domain to be at least that of the codomain
($\mathrm{Fintype.card\_le\_of\_surjective}$). Therefore
$$\beta_0(r_2) = \#\,\mathrm{Quot}(\mathrm{EqvGen}(r_2)) \leq \#\,\mathrm{Quot}(\mathrm{EqvGen}(r_1)) = \beta_0(r_1). \qquad \blacksquare$$

Conceptually: adding links can only *merge* components, never split them, so
their count cannot increase. This is the discrete birth/death structure of the
$H_0$ barcode — components are born at threshold $0$ (each vertex its own
component) and die (merge) as the threshold rises.

**Theorem 5 / Non-degeneracy witness (`componentMap_merges`).**
There is an explicit instance over the two-element vertex type
$V = \mathrm{Bool}$, with relations $r_1 \subsetneq r_2$, in which two distinct
$r_1$-components are identified under $r_2$ — i.e. the component map is
non-injective and a genuine merge occurs.

*Discussion.* Concretely, take $r_1$ to be the empty (or purely reflexive)
relation, so that `false` and `true` lie in two separate components
($\beta_0(r_1) = 2$), and take $r_2$ to link `false` with `true`, fusing them
into one component ($\beta_0(r_2) = 1$). The component map sends both
$r_1$-components to the single $r_2$-component, witnessing strict decrease
$\beta_0(r_2) = 1 < 2 = \beta_0(r_1)$. This certifies that the inequality of
Theorem 4 is genuinely attained as a strict inequality and is not vacuously an
equality. $\;\blacksquare$

---

## 6. The Bridge: One Phenomenon, Two Invariants

The two developments describe the same object. When a NISQ experiment is
repeated, correct readouts agree with one another and form a dominant cluster,
while errors are comparatively scattered. In combinatorial terms this dominant
cluster is the *majority class*; in topological terms it is the *largest
connected component* of the proximity graph on the readout population.

- **Logic side.** Error is the Hamming weight $\mathrm{errors}(s, b)$; the
  decision boundary is the count threshold $2\,\mathrm{errors} < n$ (Theorems
  1–3).

- **Topology side.** Error structure is read from $\beta_0$ and the $H_0$
  barcode; merging is the only dynamic (Theorem 4), and merges genuinely occur
  (Theorem 5).

A *logical failure* corresponds, topologically, to a *premature merge*: the
minority cluster fusing into the majority cluster so as to flip the dominant
component's label. The survival time of the correct cluster along the
filtration — the length of its $H_0$ bar — is thus the topological avatar of the
Hamming margin $n - 2\,\mathrm{errors}$. Section 7 makes this correspondence
into precise, falsifiable conjectures.

---

## 7. Worked Numerical Examples

We illustrate each result with concrete instances; these mirror the exhaustive
and randomized checks reported in the accompanying demonstration code.

**Example 1 (correctness below threshold, Theorem 1).** Let $n = 7$ and $b =
\text{true}$. Suppose three readouts are flipped, e.g. $s = (\text{true},
\text{true}, \text{true}, \text{true}, \text{false}, \text{false},
\text{false})$. Then $\mathrm{errors}(s, \text{true}) = 3$ and $2 \cdot 3 = 6 < 7$,
so the hypothesis of Theorem 1 holds. Indeed $\mathrm{ones}(s) = 4$ and $2 \cdot 4
= 8 > 7$, so $\mathrm{majority}(s) = \text{true} = b$. The guarantee is
adversarial: *any* choice of three flipped positions yields the same correct
output, since the conclusion depends only on the weight, not the location, of the
errors.

**Example 2 (the asymmetric biconditional, Theorem 2 and Remark).** Let $n = 2$
and $s = (\text{true}, \text{false})$. Then $\mathrm{ones}(s) = 1$ and $2 \cdot 1 =
2 \not> 2$, so $\mathrm{majority}(s) = \text{false}$. For the `true` codeword,
$\mathrm{errors}(s, \text{true}) = 1$ and $2 \cdot 1 = 2 \not< 2$, consistent with
Theorem 2 ($\mathrm{majority}(s) \neq \text{true}$ matches $2\,\mathrm{errors}
\not< n$). For the `false` codeword, $\mathrm{errors}(s, \text{false}) = 1$ and
$2 \cdot 1 = 2 = n$: the decoder *correctly* outputs `false` at a position where
exactly half the readouts are corrupted, so the converse of the `false`-codeword
implication fails precisely here. This is the asymmetry made concrete.

**Example 3 (sharpness, Theorem 3).** For $k = 3$, $n = 6$, the witness is $s =
(\text{true}, \text{true}, \text{true}, \text{false}, \text{false},
\text{false})$. Then $\mathrm{errors}(s, \text{true}) = 3 = k$ and
$\mathrm{ones}(s) = 3$, so $2 \cdot 3 = 6 = n \not> n$ and $\mathrm{majority}(s) =
\text{false} \neq \text{true}$. Exactly half the readouts are corrupted and the
decoder fails: weight $n/2$ is unrecoverable, matching the lower edge left open
by Theorem 1's strict inequality.

**Example 4 ($H_0$ persistence and a merge, Theorems 4–5).** Take $V = \{0, 1,
2, 3\}$. Let $r_1$ link $0\!-\!1$ and $2\!-\!3$, giving two components
$\{0,1\}, \{2,3\}$, so $\beta_0(r_1) = 2$. Let $r_2 \supseteq r_1$ additionally
link $1\!-\!2$; now all four vertices form one component and $\beta_0(r_2) = 1 \leq
2 = \beta_0(r_1)$, illustrating Theorem 4. The component map sends both
$r_1$-classes to the single $r_2$-class: a merge event, the four-vertex analogue
of the two-vertex witness of Theorem 5. Splitting is impossible — no addition of
links could turn one component back into two.

**Example 5 (the bridge, Section 6).** With the readout $s = (\text{true},
\text{true}, \text{true}, \text{false}, \text{false})$ of Example 1's flavor on
$n = 5$, build the agreement graph linking positions $i \sim j$ when $s(i) =
s(j)$. This graph has two components: the three `true` positions and the two
`false` positions. The larger component (size $3$) carries the label `true`,
which is exactly $\mathrm{majority}(s)$. The dominant $H_0$ component and the
majority vote coincide — the combinatorial and topological decision boundaries
agree on every non-tie readout, the empirical content of Conjecture C1.

---

## 8. Context and Significance

The repetition code is the conceptual atom of classical and quantum error
correction, and majority-vote decoding is its canonical decoder. The novelty of
the present development is not the threshold itself — folklore since Shannon-era
coding theory — but its *exact, machine-checked* form together with an honest
accounting of the tie-break asymmetry, which is routinely glossed over in
informal treatments. The asymmetry (Theorem 2's Remark) is a genuine subtlety:
the naive biconditional fails for one of the two codewords, and only a careful
formalization surfaces this.

The topological half connects to topological data analysis (TDA), where
persistence diagrams and barcodes summarize the multi-scale connectivity of data
and enjoy strong stability guarantees under perturbation. The monotonicity of
$\beta_0$ (Theorem 4) is the discrete, relational kernel underlying the
well-definedness of the $H_0$ barcode: births and deaths are well-ordered
precisely because components only merge. Casting this as a statement about
refining relations on a finite type — rather than about geometric simplicial
complexes — makes it both maximally general and directly applicable to the
combinatorial proximity graphs that arise from finite collections of NISQ
readouts.

The practical payoff anticipated by the bridge (Section 6) is that the TDA
toolkit, engineered for noise robustness, could supply decoders that read the
*shape* of agreement among repeated measurements rather than merely tallying
votes. Theorems 1–5 establish the two endpoints rigorously; the conjectures of
Section 9 specify exactly what must be proved to fuse them.

---

## 9. Future Directions

Each conjecture is falsifiable: it can be proved, or disproved by an explicit
finite counterexample.

**C1. Topological decoding equals Hamming-ball decoding below threshold.**
Define the topological decoder as the dominant $\beta_0$-component of the
proximity graph on the readout multiset at the optimal filtration threshold.
For the repetition code, its output equals the majority-vote output whenever
$2\,\mathrm{err} < n$. The key insight is that the largest connected component
of the proximity graph is exactly the majority equivalence class, so the
zeroth Betti structure recovers the same decision boundary as Hamming-weight
counting — topology re-derives the combinatorial threshold of Theorem 1. Both
endpoints are already formalized; the missing link is a single lemma
identifying the dominant component with the majority class.

**C2. Persistence monotonicity is strict iff a merge event occurs.**
For $r_1 \subseteq r_2$ on a finite vertex type, $\beta_0(r_2) < \beta_0(r_1)$
if and only if there exist $a, b$ that are $r_2$-connected but not
$r_1$-connected. The component map is non-injective exactly at a merge, so the
strictness of the persistence inequality is a purely relational
(non-numeric) event detector — Theorem 5 is the witness for the forward
direction. Characterizing injectivity converts the $\leq$ of Theorem 4 into a
sharp $<$/$=$ dichotomy with no new infrastructure.

**C3. Error suppression rate is governed by the longest $H_0$ bar.**
For independent bit-flip noise at rate $p < 1/2$, the logical error
probability of majority decoding decays as $\Theta(\exp(-c\,n))$, and the
constant $c$ is determined by the expected length of the longest $H_0$ bar of
the random proximity filtration. A logical failure is precisely a premature
merge of the minority component into the majority, so the survival time of the
correct component (its $H_0$ bar length) controls the exponential suppression
rate. The deterministic threshold (Theorem 3) pins the failure boundary;
layering Chernoff/Hoeffding-type concentration on the already-formalized
combinatorics is the natural quantitative next step.

**C4. Filtration refinement never increases logical error.**
(Stated in Phase A; the natural monotonicity counterpart asserting that
refining the proximity filtration cannot increase the logical error rate,
mirroring Theorem 4 at the level of decoding outcomes.)

---

## 10. Conclusion

We have established two sharp invariants of NISQ majority-vote error
mitigation. On the combinatorial side: an exact, worst-case $n/2$ correctness
threshold (Theorem 1), a clean biconditional for the `true` codeword with a
precisely characterized failure of the converse for `false` (Theorem 2), and a
tightness witness certifying the threshold is sharp and non-vacuous (Theorem
3). On the topological side: monotone decay of the zeroth Betti number along a
filtration — $H_0$ persistence (Theorem 4) — together with an explicit merge
witness guaranteeing non-degeneracy (Theorem 5). The two invariants are two
readings of a single phenomenon, the survival of the majority cluster of
correct answers, and the conjectures of Section 7 chart a concrete path to
unifying them into a noise-robust, topology-aware decoding theory.
