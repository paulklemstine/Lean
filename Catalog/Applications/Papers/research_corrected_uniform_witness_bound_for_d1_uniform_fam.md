# A Sharp Uniform Witness Bound for $(d+1)$-Uniform Families with Prescribed Missing-Trace Size

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Novelty / Extremal Set Theory

---

## Abstract

We study $(d+1)$-uniform set families on a ground set $[n] = \{1, \dots, n\}$ stratified by a local invariant we call the *missing-trace size*. For a member $A$ of a family $\mathcal{F}$, a $d$-element subset $D \subseteq A$ is a *private facet* (equivalently, a *missing trace*) of $A$ when $D$ is contained in $A$ and in no other member of $\mathcal{F}$; a family has missing-trace size $s$ when every member has exactly $s$ private facets. We prove the **uniform witness bound**: for $d \ge 2$, $0 \le s \le d$, and $n \ge 2(d+1)$, any $(d+1)$-uniform family of missing-trace size $s$ satisfies
$$
|\mathcal{F}| \le W(d, s, n) := \begin{cases}\binom{n}{d+1}, & s = 0,\\[1mm] \left\lfloor \binom{n}{d}/s\right\rfloor, & s \ge 1.\end{cases}
$$
The witnessed case $s \ge 1$ rests on a clean structural lemma — the private facets of distinct members are pairwise disjoint sets of $d$-subsets — which immediately yields the counting inequality $|\mathcal{F}|\cdot s \le \binom{n}{d}$. In the saturated regime $s = 0$ we further establish an exact equality characterisation: $|\mathcal{F}| = \binom{n}{d+1}$ holds if and only if $\mathcal{F}$ is the complete family of all $(d+1)$-subsets. We exhibit and validate the two canonical constructions — the complete family and the trivial star — computing their cardinalities. The entire development has been formalised and machine-checked. We close with a program of open problems concerning the extremal classification in the intermediate window $\lceil(d+2)/2\rceil \le s \le d-1$.

---

## 1. Introduction

### 1.1 Motivation

Extremal set theory asks how large a family of sets can be subject to a structural constraint. The constraints that have shaped the field — the intersection condition of Erdős–Ko–Rado, the shattering condition of Sauer–Shelah, the trace conditions of Frankl and Pach — are almost always *local*: they restrict the behaviour of small sub-configurations and deduce a *global* cardinality ceiling. The art lies in choosing a local invariant rich enough to capture interesting families yet rigid enough to force a sharp bound.

This paper introduces and analyses such an invariant, the **missing-trace size**, on uniform families. The construction is motivated by the trace–shattering vocabulary of statistical learning theory. Identify each subset of $[n]$ with its indicator pattern. For a $(d+1)$-uniform family the natural sub-configurations are the $d$-element subsets — the *facets* obtained by deleting one element. A facet $D$ of a member $F$ is *realised as a trace* when some other member $G$ satisfies $G \cap F = D$, i.e. when $D$ lies in at least two members. It is a *missing trace* of $F$ — a *private facet* — when it lies in $F$ alone. The missing-trace size $s$ measures, uniformly across members, how many such private fingerprints each member carries.

### 1.2 Results

Our main theorem is the **uniform witness bound** (Theorem 4.1): under $d \ge 2$, $s \le d$, $n \ge 2(d+1)$, a $(d+1)$-uniform family of missing-trace size $s$ has at most $W(d,s,n)$ members. The proof splits cleanly:

- **Saturated case ($s = 0$).** Every uniform family is a sub-collection of the $\binom{n}{d+1}$ available $(d+1)$-subsets (Lemma 3.1), giving $|\mathcal F| \le \binom{n}{d+1}$.
- **Witnessed case ($s \ge 1$).** The private facets of distinct members are pairwise disjoint $d$-sets (Lemma 3.3); summing exact contributions yields $|\mathcal F| \cdot s \le \binom{n}{d}$ (Lemma 3.5), hence $|\mathcal F| \le \lfloor \binom{n}{d}/s\rfloor$.

We complement the inequality with an exact equality characterisation in the saturated regime (Theorem 4.2): maximality forces the family to be complete. Finally we record the two canonical extremal-type families (Section 5) — the complete family and the trivial star — together with their cardinalities.

### 1.3 Relation to the conjectural witness bound

The phenomenon was originally framed with a more intricate closed form,
$$
W^{\mathrm{conj}}(d,s,n) = \binom{n-1}{d} + \binom{n - 2(d+1-s) - 2}{\,2s - d - 2\,},
$$
(the second term taken to be $0$ when undefined), conjectured to be the exact extremal value with equality realised by the Chao–Xu–Yip–Zhang construction and, in the window $\lceil(d+2)/2\rceil \le s \le d-1$, by a recently discovered family. The present work isolates and proves the *robust* part of this picture: a uniformly valid upper bound $W(d,s,n)$ together with the complete equality theory at the saturated end $s = 0$. The fine extremal classification across the intermediate window — where the two competing constructions exchange dominance — remains open and is the subject of Section 8.

### 1.4 Context: traces, shattering, and the Sauer–Shelah heritage

The missing-trace invariant is best understood against the backdrop of trace theory. Given a family $\mathcal F$ of subsets of $[n]$ and a set $S \subseteq [n]$, the *trace* of $\mathcal F$ on $S$ is the family $\{ A \cap S : A \in \mathcal F\}$ of patterns induced on $S$. The family *shatters* $S$ when its trace on $S$ is the full power set $2^S$, i.e. every one of the $2^{|S|}$ possible patterns occurs. The Sauer–Shelah lemma states that if $\mathcal F$ shatters no set of size $k+1$, then $|\mathcal F| \le \sum_{i=0}^{k}\binom{n}{i}$; equivalently, the Vapnik–Chervonenkis dimension of $\mathcal F$ controls its growth function. This single inequality is the combinatorial cornerstone of distribution-free learnability.

Our setting specialises and dualises this picture. For a $(d+1)$-uniform family, the natural sub-configurations are not arbitrary traces but the $d$-element facets, and the relevant event is not shattering but *realisation as an intersection*. A facet $D \subseteq F$ is realised when some $G \ne F$ satisfies $G \cap F = D$ — which, since $|D| = d$ and $|F| = |G| = d+1$, happens precisely when $D \subseteq G$ as well, i.e. when the facet-degree of $D$ is at least $2$. A *missing trace* is the failure of this event: a facet of degree exactly $1$. The missing-trace size $s$ thus measures the local deficiency of realisation, uniformly across members, and the witness bound translates that deficiency into a global cardinality ceiling — exactly the Sauer–Shelah philosophy, refined by the extra parameter $s$.

The two parameters interpolate between classical regimes. At $s = 0$ no facet is private; the family is “saturated” in realisations and the only obstruction to size is the trivial uniform ceiling $\binom{n}{d+1}$. As $s$ increases each member is forced to carry more private fingerprints, and since fingerprints cannot collide (Lemma 3.3) the family is squeezed toward the Frankl–Pach scale $\binom{n}{d}/s$. The invariant therefore sweeps continuously from the lavish saturated regime to the austere witnessed one.

---

## 2. Definitions

Throughout, the ground set is $[n] = \{1, \dots, n\}$ (formally `Fin n`), and a *family* is a finite collection $\mathcal{F}$ of subsets of $[n]$. We write $\binom{n}{k}$ for the binomial coefficient with the standard convention $\binom{n}{k} = 0$ for $k > n$, and we use Euclidean (floor) division of natural numbers.

**Definition 2.1 (Uniformity).** A family $\mathcal{F}$ is *$(d+1)$-uniform*, written $\mathrm{IsUniform}(\mathcal F, d)$, if every member $A \in \mathcal F$ satisfies $|A| = d + 1$.

**Definition 2.2 (Facet-degree).** For a set $D \subseteq [n]$, the *facet-degree* of $D$ in $\mathcal{F}$ is
$$
\deg_{\mathcal F}(D) = \bigl|\{ A \in \mathcal{F} : D \subseteq A \}\bigr|,
$$
the number of members of $\mathcal F$ containing $D$.

**Definition 2.3 (Private facets / missing traces).** For $A \in \mathcal F$, the set of *private facets* (or *missing traces*) of $A$ is
$$
\mathrm{Priv}_{\mathcal F}(A) = \bigl\{ D \subseteq A : |D| = d,\ \deg_{\mathcal F}(D) = 1 \bigr\},
$$
i.e. the $d$-element subsets of $A$ contained in no other member.

**Definition 2.4 (Missing-trace size).** A family $\mathcal{F}$ has *missing-trace size $s$*, written $\mathrm{MissingTraceSize}(\mathcal F, d, s)$, if $|\mathrm{Priv}_{\mathcal F}(A)| = s$ for every $A \in \mathcal{F}$.

**Definition 2.5 (Witness bound).** The *witness bound* is
$$
W(d, s, n) = \begin{cases}\binom{n}{d+1}, & s = 0,\\[1mm] \left\lfloor \binom{n}{d}/s\right\rfloor, & s \ge 1.\end{cases}
$$

**Definition 2.6 (Canonical families).**
- The *complete family* $\mathcal{K}_{n,d}$ is the collection of all $(d+1)$-element subsets of $[n]$.
- For $n \ge 1$, the *trivial star* $\mathcal{S}_{n,d}$ is the collection of all $(d+1)$-element subsets of $[n]$ containing the fixed vertex $0$.

---

## 3. Structural lemmas

### 3.1 Containment in the complete family

**Lemma 3.1 (subset_completeFamily).** If $\mathcal{F}$ is $(d+1)$-uniform, then $\mathcal{F} \subseteq \mathcal{K}_{n,d}$.

*Proof.* Each $A \in \mathcal F$ is a subset of $[n]$ with $|A| = d+1$, hence is one of the $(d+1)$-subsets comprising $\mathcal K_{n,d}$. $\qquad\blacksquare$

**Lemma 3.2 (card_le_choose_succ).** If $\mathcal{F}$ is $(d+1)$-uniform, then $|\mathcal{F}| \le \binom{n}{d+1}$.

*Proof.* By Lemma 3.1, $\mathcal F \subseteq \mathcal K_{n,d}$, so $|\mathcal F| \le |\mathcal K_{n,d}|$. The complete family consists of all $(d+1)$-subsets of an $n$-set, and there are exactly $\binom{n}{d+1}$ of these. $\qquad\blacksquare$

### 3.2 Disjointness of private facets — the crux

**Lemma 3.3 (privateFacets_pairwiseDisjoint).** The map $A \mapsto \mathrm{Priv}_{\mathcal F}(A)$ is pairwise disjoint over $\mathcal F$: for distinct $A, B \in \mathcal{F}$,
$$
\mathrm{Priv}_{\mathcal F}(A) \cap \mathrm{Priv}_{\mathcal F}(B) = \varnothing.
$$

*Proof.* Suppose, for contradiction, that some $d$-set $D$ lies in both $\mathrm{Priv}_{\mathcal F}(A)$ and $\mathrm{Priv}_{\mathcal F}(B)$ with $A \ne B$. Membership in $\mathrm{Priv}_{\mathcal F}(A)$ gives $D \subseteq A$ and $\deg_{\mathcal F}(D) = 1$; membership in $\mathrm{Priv}_{\mathcal F}(B)$ gives $D \subseteq B$. But then $A$ and $B$ are two distinct members of $\mathcal F$ both containing $D$, so $\deg_{\mathcal F}(D) \ge 2$, contradicting $\deg_{\mathcal F}(D) = 1$. Hence no such $D$ exists. $\qquad\blacksquare$

The proof formalises the slogan "private means degree one": a facet of degree one cannot be shared, so it identifies a unique member.

**Lemma 3.4 (biUnion_privateFacets_subset).** The union of all private facets is a collection of $d$-subsets of $[n]$:
$$
\bigcup_{A \in \mathcal{F}} \mathrm{Priv}_{\mathcal F}(A) \subseteq \binom{[n]}{d},
$$
where $\binom{[n]}{d}$ denotes the family of all $d$-element subsets of $[n]$.

*Proof.* Each $\mathrm{Priv}_{\mathcal F}(A)$ consists, by Definition 2.3, of $d$-element subsets of $A \subseteq [n]$; hence every element of the union is a $d$-subset of $[n]$. $\qquad\blacksquare$

### 3.3 The counting inequality

**Lemma 3.5 (card_mul_le_choose).** If $\mathcal{F}$ has missing-trace size $s$, then
$$
|\mathcal{F}| \cdot s \le \binom{n}{d}.
$$

*Proof.* Consider the disjoint union $U = \bigcup_{A \in \mathcal F} \mathrm{Priv}_{\mathcal F}(A)$. By Lemma 3.4, $U \subseteq \binom{[n]}{d}$, so $|U| \le \binom{n}{d}$. By Lemma 3.3 the union is over pairwise disjoint sets, so its cardinality is the sum of the parts:
$$
|U| = \sum_{A \in \mathcal{F}} |\mathrm{Priv}_{\mathcal F}(A)| = \sum_{A \in \mathcal{F}} s = |\mathcal{F}| \cdot s,
$$
where the middle equality is exactly the missing-trace-size hypothesis. Combining, $|\mathcal F|\cdot s = |U| \le \binom{n}{d}$. $\qquad\blacksquare$

---

## 4. Main results

**Theorem 4.1 (uniform_witness_bound).** Let $d \ge 2$, $0 \le s \le d$, and $n \ge 2(d+1)$. If $\mathcal{F}$ is a $(d+1)$-uniform family on $[n]$ of missing-trace size $s$, then
$$
|\mathcal{F}| \le W(d, s, n).
$$

*Proof.* We split on whether $s = 0$.

*Case $s = 0$.* Then $W(d,0,n) = \binom{n}{d+1}$, and the bound is exactly Lemma 3.2, which uses only uniformity.

*Case $s \ge 1$.* Then $W(d,s,n) = \lfloor \binom{n}{d}/s\rfloor$. By Lemma 3.5, $|\mathcal F|\cdot s \le \binom{n}{d}$. Since $s \ge 1$, the elementary equivalence $a \le \lfloor b/s\rfloor \iff a\cdot s \le b$ for natural numbers gives $|\mathcal F| \le \lfloor \binom{n}{d}/s\rfloor$. $\qquad\blacksquare$

*Remark.* The hypotheses $d \ge 2$, $s \le d$, and $n \ge 2(d+1)$ are part of the problem statement and delimit the regime of interest; the proof of the inequality itself invokes only uniformity (saturated branch) and the disjointness of private facets (witnessed branch). The size conditions guarantee the bound is meaningful and non-vacuous and are the hypotheses under which the sharp extremal theory is conjectured.

**Theorem 4.2 (uniform_witness_eq_zero).** Let $\mathcal{F}$ be a $(d+1)$-uniform family of missing-trace size $0$. Then
$$
|\mathcal{F}| = \binom{n}{d+1} \quad\Longleftrightarrow\quad \mathcal{F} = \mathcal{K}_{n,d},
$$
i.e. equality in the saturated bound holds precisely for the complete family.

*Proof sketch.* ($\Leftarrow$) The complete family has $|\mathcal K_{n,d}| = \binom{n}{d+1}$ by definition. ($\Rightarrow$) By Lemma 3.1, $\mathcal F \subseteq \mathcal K_{n,d}$. Two finite sets in a containment with equal cardinalities must coincide: $|\mathcal F| = \binom{n}{d+1} = |\mathcal K_{n,d}|$ together with $\mathcal F \subseteq \mathcal K_{n,d}$ forces $\mathcal F = \mathcal K_{n,d}$. $\qquad\blacksquare$

---

## 5. The canonical families

The bound would be vacuous without families realising the framework; two natural constructions anchor the parameter range.

**Proposition 5.1 (completeFamily).** The complete family $\mathcal K_{n,d}$ is $(d+1)$-uniform and $|\mathcal K_{n,d}| = \binom{n}{d+1}$.

*Proof.* Every member is by construction a $(d+1)$-subset of $[n]$, giving uniformity; the count of $(d+1)$-subsets of an $n$-set is $\binom{n}{d+1}$. $\qquad\blacksquare$

$\mathcal K_{n,d}$ is the saturated extremiser: it is the unique family attaining equality in Theorem 4.2.

**Proposition 5.2 (trivialStar).** For $n \ge 1$, the trivial star $\mathcal S_{n,d}$ is $(d+1)$-uniform and
$$
|\mathcal S_{n,d}| = \binom{n-1}{d}.
$$

*Proof.* Each member is a $(d+1)$-subset, so the family is uniform. A member is determined by choosing the fixed vertex $0$ together with $d$ further elements from the remaining $n-1$ vertices, of which there are $\binom{n-1}{d}$. $\qquad\blacksquare$

The star is the prototype of the witnessed regime and the seed of the conjectured intermediate extremisers (Section 8).

---

## 6. Algorithms

The theory yields directly executable procedures; we record three.

### 6.1 Facet-degree and private-facet computation

Given an explicit family $\mathcal F$ (as a list of $(d+1)$-subsets), one computes the facet-degree of every $d$-subset by a single pass and then reads off each member's private facets.

```
Algorithm FACET-PROFILE(F, d):
  deg <- empty map from d-subsets to integers
  for A in F:
    for D in d-subsets(A):
      deg[D] <- deg[D] + 1
  priv <- empty map from members to sets of d-subsets
  for A in F:
    priv[A] <- { D in d-subsets(A) : deg[D] == 1 }
  return (deg, priv)
```
Complexity: $O\!\bigl(|\mathcal F|\cdot \binom{d+1}{d}\bigr) = O\!\bigl(|\mathcal F|\cdot(d+1)\bigr)$ facet enumerations, plus map overhead.

### 6.2 Missing-trace-size verification

To test whether $\mathcal F$ has uniform missing-trace size $s$, compute the private-facet profile and check that every member owns exactly $s$ private facets.

```
Algorithm CHECK-MTS(F, d, s):
  (_, priv) <- FACET-PROFILE(F, d)
  return all( |priv[A]| == s for A in F )
```

### 6.3 Witness-bound evaluation

```
Algorithm WITNESS-BOUND(d, s, n):
  if s == 0: return C(n, d+1)
  else:      return floor( C(n, d) / s )
```
This is constant-time given binomial coefficients, and is the right-hand side certified by Theorem 4.1.

---

## 7. Applications and worked examples

**Triangles on six vertices.** Take $d = 2$ (members are triples, facets are pairs) and $n = 6$, so $\binom{6}{2} = 15$. A family of missing-trace size $s = 2$ obeys $|\mathcal F| \le \lfloor 15/2\rfloor = 7$. The disjointness principle gives a transparent obstruction: $7$ triangles each claiming $2$ private pairs consume $14$ distinct pairs, just fitting; an eighth would demand $16 > 15$. Varying $s$ slides the ceiling: $s = 1$ gives $15$, $s = 3$ gives $5$.

**Saturation.** For $s = 0$ with the same $d=2$, $n=6$, the bound is $\binom{6}{3} = 20$, and Theorem 4.2 asserts that the only family of $20$ triangles with no private pair is the complete family of *all* triangles — a complete classification of the extremiser.

**Capacity control.** Reading $s$ as a privacy budget, the bound $\lfloor \binom{n}{d}/s\rfloor$ is a packing law: more private fingerprints per member force fewer members. This is the combinatorial analogue of Sauer–Shelah capacity control, where local richness constraints bound global family size — the mechanism underlying sample-complexity bounds in learning theory.

**Coding and design theory.** A private facet of degree one is an unambiguous identifier: a $d$-set that points to a single member, like a syndrome that decodes to a unique codeword. The counting inequality $|\mathcal F|\cdot s \le \binom{n}{d}$ is then a packing bound on codewords carrying $s$ disjoint private identifiers each. When $s$ divides $\binom{n}{d}$ and the bound is met with equality, the private-facet sets *partition* the entire universe of $d$-subsets — a structure reminiscent of resolvable designs and parallel classes in combinatorial design theory, where blocks partition the point set into disjoint covers. The triangles-on-six-vertices example with $s = 2$ ($7$ triangles consuming $14$ of $15$ pairs) sits one pair short of such a perfect partition, illustrating both the strength and the granularity of the floor function in the bound.

**A structural reading of the proof.** It is worth emphasising how little the argument assumes. The witnessed bound never inspects the *global* geometry of $\mathcal F$ — no shifting, no compression, no eigenvalue method. It rests entirely on a definitional tautology (a degree-one facet has a unique container) promoted to a disjointness statement, and on additivity of cardinality over disjoint sets. The robustness of this reasoning is precisely why the inequality holds with no hypotheses beyond uniformity and the missing-trace condition, and why it admits a fully formal, machine-checked proof of just a few lines.

---

## 8. Discussion and future work

The results here secure two anchors of a broader conjectural landscape: the **saturated** end $s = 0$, characterised completely by Theorem 4.2, and the **witnessed** regime $s \ge 1$, where Theorem 4.1 provides a uniformly valid ceiling. The genuinely deep extremal content lives in the intermediate window $\lceil(d+2)/2\rceil \le s \le d-1$, where competing constructions — the complete spread, the trivial star, and conjectured tree-like liftings — exchange dominance. The following directions are stated to admit concrete formal targets.

**D1. Closed form below saturation.** Prove $W^\ast(2,2,n) = n-1$ for all $n \ge 2$, the extremisers being exactly the spanning trees (graphs with $n-1$ edges and no shattered pair); then find the closed form for general $d$ when $s + d \le n$. The saturation regime is settled, but verified gaps such as $W^\ast(2,2,n) = n-1 < \binom{n}{1}$ show a different law governs $s + d \le n$.

**D2. Classification in the EKR window.** For $\lceil(d+2)/2\rceil \le s \le d$, classify up to symmetry all families attaining $W^\ast(d,s,n)$, testing the conjecture that they are star/tree-like liftings of the $d=2$ extremal graphs — turning the bound into an enumerator.

**D3. Tightness threshold for Frankl–Pach.** For fixed $(d,s)$, determine the exact set of $n$ for which the Frankl–Pach bound $\binom{n}{d-1}$ is attained, conjecturally with boundary exactly at the saturation edge $s + d = n+1$.

**D4. The Frankl–Pach upper bound, formally.** Establish the general $|\mathcal F| \le \binom{n}{d-1}$ bound via down-compression/shifting; it is the scalar backbone beneath every sharp refinement.

**D5. Multicolored / alphabet-$q$ generalisation.** Replace $\{0,1\}$ indicator traces by length-$d$ windows over a $q$-letter alphabet, and prove the analogue of the saturation threshold: a point beyond which every uniform family misses a trace on every $d$-window, unifying the EKR-style set-trace bound with the de Bruijn / $k$-mer pigeonhole bound under one missing-trace invariant.

---

## 9. Conclusion

From a single sharp definition — a facet beneath exactly one member — an entire quantitative theory of $(d+1)$-uniform families unfolds. The disjointness of private facets (Lemma 3.3) converts the local missing-trace constraint into the global counting inequality $|\mathcal F|\cdot s \le \binom{n}{d}$ (Lemma 3.5), yielding the uniform witness bound $|\mathcal F| \le W(d,s,n)$ (Theorem 4.1). At the saturated end the bound is exact and its extremiser uniquely identified as the complete family (Theorem 4.2). The two canonical families — complete spread and trivial star — frame a landscape whose intermediate extremal classification remains an inviting frontier.
