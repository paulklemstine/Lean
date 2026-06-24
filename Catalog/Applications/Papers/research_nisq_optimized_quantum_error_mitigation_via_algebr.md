# A Topological Invariant for Repetition-Code Error Mitigation: The Agreement Complex and its Zeroth Betti Number

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Logic / Algebraic Topology (NISQ Quantum Error Mitigation)

## Abstract

We study a simple but rigorously verified mechanism by which an *algebraic-topological invariant* encodes and certifies the error structure of a quantum repetition-code readout. Given a noisy measurement $s : \{0,\dots,n-1\} \to \{0,1\}$ obtained by repeating a single logical bit $n$ times, we define the **agreement relation** $\mathrm{agree}(s)(i,j) \iff s_i = s_j$ and study the zeroth Betti number $\beta_0$ of its equivalence closure — the number of connected components of the *agreement complex*. We prove four principal facts. First, the invariant is bounded: $\beta_0(\mathrm{agree}(s)) \le 2$, because each component carries a distinct bit value and so injects into a two-element set. Second, on a nonempty block the invariant detects consensus exactly: $\beta_0 = 1$ if and only if all readouts agree. Third, it detects disagreement exactly: $\beta_0 = 2$ if and only if some pair of readouts differ. Fourth, and most importantly, the topological signal *implies* a metric guarantee: $\beta_0 = 1$ certifies the existence of a logical codeword against which the readout has zero Hamming errors. We connect this $\beta_0$ theory to the metric theory of majority-vote decoding (with its sharp $n/2$ correctness threshold) and to a monotonicity ($H_0$-persistence) law for filtrations of proximity relations, providing the foundation for a topological theory of error mitigation on near-term (NISQ) quantum hardware. All results have been formally verified.

---

## 1. Introduction

Near-term quantum computers — *Noisy Intermediate-Scale Quantum* (NISQ) devices — operate well below the fault-tolerance threshold. Among the simplest error-mitigation strategies is the **repetition code**: a logical bit $b \in \{0,1\}$ is prepared and measured $n$ times, producing a readout vector $s$, and the bit is recovered by a decoder that suppresses the noise. The standard decoder is **majority voting**, whose correctness is governed by the Hamming weight of the error pattern.

This paper develops a parallel, *topological* account of the same data. Rather than counting corrupted positions, we record the **shape** of the agreement structure among measurement sites and extract a single topological invariant, the zeroth Betti number $\beta_0$. Our central thesis — the *encode-errors-as-topology* mechanism — is that for the repetition code this invariant is a faithful and complete summary of the readout's consensus structure, and moreover that it *certifies* error-freeness rather than merely correlating with it.

The repetition code is the natural first case study because it is exactly where the topological and metric descriptions coincide. As we discuss in §6, the value of the framework is that it generalizes: richer codes produce error patterns whose detection requires *higher* Betti numbers, so the $\beta_0$ theory developed here is the first rung of a homological ladder.

### Contributions

1. A precise definition of the **agreement complex** of a repetition-code readout and its zeroth Betti number (§3).
2. A boundedness theorem $\beta_0 \le 2$ proved by a structural injection, not exhaustive search (Theorem 4.1).
3. Sharp consensus / disagreement characterizations: $\beta_0 = 1 \iff$ consensus and $\beta_0 = 2 \iff$ disagreement (Theorems 4.3, 4.5).
4. A **bridge theorem**: $\beta_0 = 1$ implies the existence of a zero-error codeword (Theorems 4.6, 4.7), connecting the topological invariant to the Hamming metric.
5. Integration with the metric theory of majority decoding (sharp $n/2$ threshold, §5.1) and with $H_0$-persistence monotonicity for proximity filtrations (§5.2).

---

## 2. Background and notation

Throughout, $n \in \mathbb{N}$ and a **readout** is a function $s : \mathrm{Fin}\,n \to \mathrm{Bool}$, where $\mathrm{Fin}\,n = \{0,1,\dots,n-1\}$ indexes the measurement sites and $\mathrm{Bool} = \{\mathtt{false}, \mathtt{true}\}$ encodes the bit value. We write $\mathrm{NeZero}\,n$ for the hypothesis $n \ne 0$ (at least one measurement was taken).

**Connected components via equivalence closure.** Given a binary relation $r$ on a type $V$, let $\mathrm{EqvGen}(r)$ denote the smallest equivalence relation containing $r$ (its reflexive–symmetric–transitive closure). The **quotient** $\mathrm{Quot}(\mathrm{EqvGen}(r))$ is the set of $r$-connected components. When this quotient is finite, its cardinality is the zeroth Betti number.

**Definition 2.1 (Zeroth Betti number).** For a relation $r : V \to V \to \mathrm{Prop}$ whose component quotient is finite,
$$\beta_0(r) := \big|\, \mathrm{Quot}(\mathrm{EqvGen}(r)) \,\big|.$$

This is the number of connected components of the graph whose edges are the related pairs. It is the simplest topological invariant of the associated simplicial/graph complex; higher Betti numbers $\beta_k$ count $k$-dimensional holes and do not enter the repetition-code analysis (see §6).

**The Hamming error metric.** For a candidate logical bit $b$, the **error count** of a readout is the Hamming distance to the constant-$b$ codeword:
$$\mathrm{errors}(s, b) := \big|\{\, i : s_i \ne b \,\}\big|.$$
We also write $\mathrm{ones}(s) := |\{ i : s_i = \mathtt{true}\}|$ for the number of `true` readouts.

---

## 3. The agreement complex

**Definition 3.1 (Agreement relation).** The *agreement relation* of a readout $s$ is
$$\mathrm{agree}(s)(i, j) \iff s_i = s_j.$$
Two measurement sites are linked precisely when they report the same bit.

Because equality of bits is already an equivalence relation, $\mathrm{agree}(s)$ is reflexive, symmetric, and transitive; its equivalence closure coincides with itself in spirit. We do not, however, need to prove relation equality; the following lemma — that the agreement *value* is a well-defined invariant of a component — is the only structural fact required downstream, and it follows by induction on the closure derivation.

**Lemma 3.2 (Component value is well defined; `eqvGen_agree_value`).** *If $\mathrm{EqvGen}(\mathrm{agree}(s))(i, j)$, then $s_i = s_j$.*

*Proof sketch.* Induct on the derivation of the equivalence closure. The base case is the defining relation $s_i = s_j$. Reflexivity gives $s_i = s_i$; symmetry and transitivity of $=$ close the symmetric and transitive cases. $\square$

The **agreement complex** is the graph on vertex set $\mathrm{Fin}\,n$ with these edges; its zeroth Betti number $\beta_0(\mathrm{agree}(s))$ counts its connected components. Lemma 3.2 says each component is *monochromatic*: all of its sites share one bit value.

---

## 4. Main results

### 4.1 Boundedness

**Theorem 4.1 (Boundedness; `betti0_agree_le_two`).** *For every readout $s$ (with finite component quotient),*
$$\beta_0(\mathrm{agree}(s)) \le 2.$$

*Proof sketch.* By Lemma 3.2 the assignment "component $\mapsto$ its common bit value" is well defined as a map $\mathrm{Quot}(\mathrm{EqvGen}(\mathrm{agree}(s))) \to \mathrm{Bool}$, realized as $\mathrm{Quot.lift}\,s$. This map is *injective*: if two components have equal bit value, then representatives $a, b$ satisfy $s_a = s_b$, hence $\mathrm{agree}(s)(a,b)$, so they are identified in the quotient. An injection into $\mathrm{Bool}$ forces cardinality $\le |\mathrm{Bool}| = 2$. $\square$

**Remark 4.2.** The bound is proved by *injectivity*, not by a finite `decide`. This is the topological content: two codewords force the agreement graph to be a disjoint union of at most two cliques, so it has at most two-dimensional $H_0$ and trivial higher homology.

### 4.2 Consensus and disagreement detection

**Theorem 4.3 (Consensus detection; `betti0_agree_eq_one`).** *Assume $\mathrm{NeZero}\,n$. Then*
$$\beta_0(\mathrm{agree}(s)) = 1 \iff \forall\, i\, j,\ s_i = s_j.$$

*Proof sketch.* ($\Rightarrow$) A cardinality-one finite type is a nonempty `Unique` type, so all of $\mathrm{Fin}\,n$ collapses to a single component; pushing two indices $i, j$ through the well-defined value map (Lemma 3.2) gives $s_i = s_j$. ($\Leftarrow$) If all sites agree, then any two representatives are related by $\mathrm{agree}(s)$, so the quotient is a `Subsingleton`; being nonempty (since $n \ne 0$) it is `Unique`, hence has cardinality $1$. $\square$

**Lemma 4.4 (Positivity; `betti0_agree_pos`).** *Assume $\mathrm{NeZero}\,n$. Then $1 \le \beta_0(\mathrm{agree}(s))$.* *(The quotient is nonempty because $\mathrm{Fin}\,n$ is, so its cardinality is positive.)*

**Theorem 4.5 (Disagreement detection; `betti0_agree_eq_two_iff`).** *Assume $\mathrm{NeZero}\,n$. Then*
$$\beta_0(\mathrm{agree}(s)) = 2 \iff \exists\, i\, j,\ s_i \ne s_j.$$

*Proof sketch.* Combine Theorem 4.1 ($\beta_0 \le 2$), Lemma 4.4 ($\beta_0 \ge 1$), and Theorem 4.3, so $\beta_0 \in \{1, 2\}$. If $\beta_0 = 2$ then $\beta_0 \ne 1$, so by the contrapositive of Theorem 4.3 consensus fails, i.e. some pair disagrees. Conversely, disagreement rules out $\beta_0 = 1$ (Theorem 4.3), and the squeeze $\beta_0 \in \{1,2\}$ forces $\beta_0 = 2$. $\square$

These three results show $\beta_0$ is a *perfect binary classifier* of the readout's consensus structure: it is squeezed into $\{1, 2\}$ and takes the value $1$ exactly on error-free consensus and $2$ exactly when noise has introduced disagreement.

### 4.3 The bridge to the error metric

The previous results are about the *internal* consensus structure of $s$. The following theorems connect $\beta_0$ to the external Hamming metric — the quantity error mitigation ultimately controls.

**Lemma 4.6 (Consensus is error-free; `consensus_zero_errors`).** *Assume $\mathrm{NeZero}\,n$ and that $s$ is in consensus ($\forall i\, j,\ s_i = s_j$). Let $b = s_0$ be the common value. Then $\mathrm{errors}(s, b) = 0$.*

*Proof sketch.* The error set $\{i : s_i \ne s_0\}$ is empty because consensus gives $s_i = s_0$ for all $i$; an empty filter has cardinality $0$. $\square$

**Theorem 4.7 (Topology certifies error-freeness; `betti0_one_certifies_errorless`).** *Assume $\mathrm{NeZero}\,n$. If $\beta_0(\mathrm{agree}(s)) = 1$, then there exists a logical bit $b$ with $\mathrm{errors}(s, b) = 0$.*

*Proof sketch.* By Theorem 4.3, $\beta_0 = 1$ yields consensus; take $b = s_0$ and apply Lemma 4.6. $\square$

This is the keystone. The topological feature "$\beta_0 = 1$" is not a re-encoding of the metric statement; it *implies* it. A connected agreement complex is a certificate of a perfectly clean codeword.

---

## 5. Integration with the surrounding theory

### 5.1 The metric baseline: majority decoding

The metric counterpart of the agreement complex is the majority-vote decoder, $\mathrm{majority}(s) := \mathrm{decide}(2\,\mathrm{ones}(s) > n)$.

**Theorem 5.1 (Repetition-code correctness; `majority_decode_correct`).** *If $2\,\mathrm{errors}(s, b) < n$, then $\mathrm{majority}(s) = b$.* That is, if strictly fewer than half the readouts are corrupted, majority voting recovers the true bit.

**Theorem 5.2 (Exact threshold for the `true` codeword; `majority_decode_correct_iff`).** $\mathrm{majority}(s) = \mathtt{true} \iff 2\,\mathrm{errors}(s, \mathtt{true}) < n.$ *(The strict tie-break $>$ means the clean biconditional holds for the all-`true` codeword; for `false` the converse fails exactly at the tie $2\,\mathrm{errors} = n$.)*

**Theorem 5.3 (Sharpness of the $n/2$ threshold; `majority_threshold_tight`).** *For every $k > 0$, on length $n = 2k$ there is a readout with exactly $k$ errors (half corrupted) on which the decoder fails.* The threshold is therefore tight and the correctness guarantee non-vacuous.

The relationship is clean: $\beta_0(\mathrm{agree}(s)) = 1$ is the *strongest possible* hypothesis (zero errors), under which majority voting trivially succeeds, whereas Theorems 5.1–5.3 quantify the full correctable range $\mathrm{errors} < n/2$. The topological invariant certifies the perfect case; the metric theory governs the imperfect-but-correctable regime.

### 5.2 Persistence: monotonicity along a filtration

In persistent homology one organizes data as a *filtration* of relations, $r_1 \subseteq r_2 \subseteq \cdots$, where increasing a proximity threshold links more pairs. The component count then decays monotonically.

**Theorem 5.4 ($H_0$ persistence; `betti0_persistence`).** *If $r_1 \subseteq r_2$ (every $r_1$-edge is an $r_2$-edge) and both component quotients are finite, then*
$$\beta_0(r_2) \le \beta_0(r_1).$$

*Proof sketch.* Monotonicity of $\mathrm{EqvGen}$ in its base relation induces a well-defined **component map** $\mathrm{Quot}(\mathrm{EqvGen}(r_1)) \to \mathrm{Quot}(\mathrm{EqvGen}(r_2))$ (the coarsening map), realized by $\mathrm{Quot.lift}$ with $\mathrm{EqvGen.mono}$. This map is *surjective* because the coarser $\mathrm{Quot.mk}$ is surjective and factors through it. A surjection between finite types cannot increase cardinality, giving $\beta_0(r_2) \le \beta_0(r_1)$. $\square$

**Non-degeneracy (`componentMap_merges`).** On the two-point type $\mathrm{Bool}$, the empty relation keeps the two points in distinct components while the full relation merges them, so the inequality is strict in general and the persistence law is not vacuous.

Theorem 5.4 says components can only **merge**, never split, as a filtration grows — the birth/death structure of the $H_0$ barcode. The agreement complex is one snapshot in such a filtration; tracking *when* components merge (the death times) is the persistent refinement proposed in §6.

---

## 6. Discussion

The agreement complex demonstrates the *encode-errors-as-topology* mechanism in its cleanest form. For the repetition code:

- the error structure of a readout is faithfully summarized by one integer, $\beta_0(\mathrm{agree}(s)) \in \{1, 2\}$;
- that integer detects consensus and disagreement *exactly* (Theorems 4.3, 4.5);
- and, crucially, it *certifies* the metric statement of error-freeness rather than merely correlating with it (Theorem 4.7).

The honesty of the formalization is worth emphasizing. The $\mathrm{NeZero}\,n$ hypothesis is genuinely load-bearing: on the empty block the component quotient is empty, $\beta_0 = 0$, and the consensus/connectivity dictionary collapses. The boundedness theorem is proved by an explicit injection into $\mathrm{Bool}$, not by case exhaustion, so it reflects the structural fact that two codewords admit at most two cliques.

The deeper interpretation is that the repetition code is a *topological accident*: its agreement complex is contractible-on-components (a disjoint union of cliques) with vanishing higher homology, which is exactly why a $\beta_0$-only decoder is complete. The framework predicts where this breaks down — namely, codes whose proximity complexes carry nontrivial $H_1$.

---

## 7. Future directions

The following directions arise directly from the formalized $\beta_0$ theory and its companions.

**1. Higher-Betti barcodes detect correlated (burst) errors.** For repetition-style codes the agreement complex has $H_0$ dimension $\le 2$ (Theorem 4.1) and trivial higher homology, but for a 2D surface-code syndrome stream the *first* persistent Betti number $\beta_1$ of the syndrome–proximity filtration should be strictly positive exactly when a logical (non-correctable) error chain is present. A logical error is a non-contractible cycle of syndrome defects, so it must register in $H_1$ rather than $H_0$; the $\beta_0$ decoder is provably blind to it (it only ever distinguishes two components), which is precisely the failure mode one should see one dimension up. Extending the $\mathrm{Quot}(\mathrm{EqvGen}\,\cdot)$ machinery to a 1-skeleton with a boundary map is the minimal next increment, and surface-code syndrome data is the most-studied NISQ benchmark available.

**2. The merge-event conservation law gives a decoder confidence score.** The telescoping total $\sum_i (\beta_0(R_i) - \beta_0(R_{i+1})) = \beta_0(R_0) - \beta_0(R_N)$ should be monotone in the noise rate: the filtration index at which $\beta_0$ first reaches $1$ (the "consensus persistence") is conjectured to be a sufficient statistic for the posterior error probability, and thresholding on it should strictly dominate fixed-distance majority voting on biased channels. *When* components merge (the death times in the barcode), not merely *that* they merge, carries channel information that majority voting discards; the conservation law guarantees these death times are a complete, non-redundant accounting of the merging process.

**3. Nearest-codeword optimality is exactly the collapse of $H_1$.** Majority $=$ minimum-Hamming decoding should generalize: a linear code admits an exact $\beta_0$-only optimal decoder **iff** its Tanner-graph proximity complex is homotopy-equivalent to a discrete set (vanishing $H_1$). Codes with $\beta_1 > 0$ provably require higher-dimensional mitigation. The one-dimensional reduction in which "everything collapses onto the scalar $\mathrm{ones}(s)$" is a *topological* accident of the repetition code's contractible complex, not a generic feature of decoding.

---

## 8. Conclusion

We have established, with full formal rigor, that the zeroth Betti number of the agreement complex is a faithful, bounded, and *certifying* topological summary of a repetition-code readout: it equals $1$ exactly on error-free consensus, $2$ exactly under disagreement, never exceeds $2$, and a value of $1$ guarantees the existence of a zero-error codeword. Combined with the sharp metric theory of majority decoding and the monotonicity of $H_0$-persistence, this provides the foundational rung of a homological theory of NISQ error mitigation, whose higher rungs ($\beta_1$ and persistent barcodes) are poised to capture the correlated and logical errors that defeat naive voting.
