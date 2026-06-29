# Union-Closed Families as Positive-Correlation Systems

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Novelty (combinatorics / discrete statistical mechanics)

## Abstract

We develop a self-contained theory linking *union-closed set families* to the
positive-correlation phenomena of discrete statistical mechanics. Working over
a finite ground set $\alpha$, we treat a finite family $F$ of subsets as a
uniform probability space of configurations and study three observables: the
per-site *member count* $\mathrm{mc}(a)$, the *joint count* $\mathrm{jc}(a,b)$,
and the *union count* $\mathrm{uc}(a,b)$. We establish: (1) a double-counting
identity equating total occupancy with total configuration size; (2) a
majority-from-average principle producing a frequently-occurring element under
an averaged size hypothesis — a verified instance of the Frankl direction; (3) a
bridge theorem showing every upper-set family is union-closed; (4) the
two-point inclusion–exclusion identity; (5) the construction of the union
closure as a closure operator (extensive and union-closed) together with
monotonicity of total occupancy under closure; and (6) the FKG base case:
nonnegative correlation of coordinate indicators on the full powerset. Each
result is interpreted in the language of lattice gases — marginal occupancies,
two-point correlation functions, order parameters, coarse-graining, and
entropy. All statements correspond to fully formal, machine-checked theorems.

---

## 1. Introduction

Union-closed families sit at a crossroads. Combinatorially, they are families
$F$ of finite sets closed under pairwise union; the celebrated **Frankl
conjecture** (1979) asserts that any such family containing a nonempty set has
an element belonging to at least half its members. Order-theoretically, they
generalize *filters* (upper sets) in a Boolean lattice. Probabilistically — the
viewpoint we press here — a finite family is a uniform measure on
configurations of a discrete spin/particle system, and union-closure is a
monotone constraint encouraging aggregation.

Our aim is to make this last reading rigorous and to isolate the elementary
facts on which any correlation theory of such systems must rest. The results
are individually simple; their value is the **dictionary** they assemble
between combinatorics and statistical mechanics:

| Combinatorics | Statistical mechanics |
|---|---|
| $\mathrm{mc}(a)/|F|$ | marginal occupancy of site $a$ |
| $\mathrm{jc}(a,b)/|F|$ | two-point correlation function |
| $\sum_{s\in F}|s|$ | total particle number over all configurations |
| union closure $\overline{F}$ | coarse-graining / closure dynamics |
| frequent element | nonzero order parameter |
| powerset correlation | finite FKG base case |

### 1.1 Notation

Throughout, $\alpha$ is a type with decidable equality; where stated it is also
finite, with $|\alpha| = \mathrm{card}\,\alpha$. Subsets of $\alpha$ are finite
sets, and a *family* is a finite set $F$ of such subsets. We write $|s|$ for the
cardinality of $s$, $|F|$ for the number of members of $F$, and $2^\alpha$ for
the family of all subsets of $\alpha$, with $|2^\alpha| = 2^{|\alpha|}$.

---

## 2. Definitions

**Definition 1 (Union-closed family).** A family $F$ is *union-closed* if
$$\forall\, s,t \in F,\quad s \cup t \in F.$$
This models a configuration space closed under binary joins — a monotone
lattice gas.

**Definition 2 (Upper-set family).** A family $F$ is an *upper-set family*
(upset) if
$$\forall\, s,t,\quad s \in F \wedge s \subseteq t \;\Rightarrow\; t \in F.$$
For finite $\alpha$ this is an order filter in the Boolean lattice $2^\alpha$.

**Definition 3 (Member count).** For $a \in \alpha$,
$$\mathrm{mc}(a) := \#\{\, s \in F : a \in s \,\}.$$
It equals $|F|$ times the marginal occupancy probability of site $a$ under the
uniform measure on $F$.

**Definition 4 (Joint count).** For $a,b \in \alpha$,
$$\mathrm{jc}(a,b) := \#\{\, s \in F : a \in s \wedge b \in s \,\},$$
equal to $|F|$ times the two-point correlation function.

**Definition 5 (Union count).** For $a,b \in \alpha$,
$$\mathrm{uc}(a,b) := \#\{\, s \in F : a \in s \vee b \in s \,\}.$$

**Definition 6 (Union closure).** For finite $\alpha$, the *union closure* of
$F$ is
$$\overline{F} := \Big\{\, s : \exists\, G \subseteq F,\ G \ne \varnothing,\
\textstyle\bigvee_{g \in G} g = s \,\Big\},$$
the family of all sets obtainable as the supremum (union) of a nonempty
sub-collection of $F$. This is the coarse-graining operator.

---

## 3. Main results

### 3.1 The conservation law

**Theorem 1 (Double-counting identity).** For any finite ground set $\alpha$
and family $F$,
$$\sum_{a \in \alpha} \mathrm{mc}(a) \;=\; \sum_{s \in F} |s|.$$

*Proof sketch.* Expand each $\mathrm{mc}(a)$ as a sum of indicators
$\mathrm{mc}(a) = \sum_{s \in F} \mathbf{1}[a \in s]$ (this is the
`card_filter` rewriting). The double sum
$\sum_{a}\sum_{s\in F}\mathbf{1}[a\in s]$ is symmetric in its two indices; swap
the order of summation (Fubini for finite sums). The inner sum
$\sum_{a}\mathbf{1}[a\in s]$ counts the elements of $s$, i.e. equals $|s|$. ∎

*Interpretation.* Dividing by $|F|$: the sum over sites of marginal occupancies
equals the mean configuration size. This is the conservation law of the system,
relating local densities to a global extensive quantity.

### 3.2 Order parameter from averaged density

**Theorem 2 (Majority from average).** Let $\alpha$ be finite and nonempty and
$F$ nonempty. If
$$2\sum_{s \in F} |s| \;\ge\; |F|\cdot|\alpha|,$$
then there exists $a \in \alpha$ with $2\,\mathrm{mc}(a) \ge |F|$.

*Proof sketch.* Contrapositive. Assume $2\,\mathrm{mc}(a) < |F|$ for every
$a \in \alpha$. Since $\alpha$ is nonempty, summing this strict inequality over
all $a$ (using that a sum of strictly smaller nonneg terms over a nonempty index
set is strictly smaller) gives
$$2\sum_{a}\mathrm{mc}(a) < |\alpha|\cdot|F|.$$
By Theorem 1 the left side is $2\sum_{s\in F}|s|$, yielding
$2\sum_{s\in F}|s| < |F|\cdot|\alpha|$, the negation of the hypothesis. ∎

*Interpretation.* A global averaged-density condition forces a *local*
concentration — a frequent element, the combinatorial analogue of a nonzero
order parameter. This is exactly the conclusion of **Frankl's conjecture**,
here proved under the extra hypothesis that configurations are large on
average. Note Theorem 2 requires no union-closure; it is a clean pigeonhole
consequence of Theorem 1.

### 3.3 Bridge: filters are merge-closed

**Theorem 3 (Every upset is union-closed).** If $F$ is an upper-set family,
then $F$ is union-closed.

*Proof sketch.* Take $s,t \in F$. Then $s \subseteq s \cup t$. Apply Definition
2 to $s \in F$ and the inclusion $s \subseteq s \cup t$ to conclude
$s \cup t \in F$. ∎

*Interpretation.* Monotone (increasing) events, the natural observables of a
lattice gas, all live inside the union-closed world; results about union-closed
families therefore apply to them. This is the hinge between order theory and the
algebra of $\cup$.

### 3.4 Two-point inclusion–exclusion

**Theorem 4 (Inclusion–exclusion).** For any $a,b \in \alpha$, as integers,
$$\mathrm{uc}(a,b) \;=\; \mathrm{mc}(a) + \mathrm{mc}(b) - \mathrm{jc}(a,b).$$

*Proof sketch.* The event $\{a \in s \vee b \in s\}$ is the union of
$\{a\in s\}$ and $\{b \in s\}$ as predicates; the event $\{a\in s \wedge b \in
s\}$ is their intersection. By the cardinality identity
$|X \cup Y| + |X \cap Y| = |X| + |Y|$ applied to the corresponding filtered
subfamilies, $\mathrm{uc}(a,b) + \mathrm{jc}(a,b) = \mathrm{mc}(a) +
\mathrm{mc}(b)$; rearranging over $\mathbb{Z}$ gives the claim. ∎

*Interpretation.* Dividing by $|F|$ recovers $P(a\cup b) = P(a)+P(b)-P(a\cap
b)$ for the random-configuration distribution; it certifies that
$\mathrm{jc}$ is the genuine two-point overlap.

### 3.5 Union closure as a closure operator

**Lemma 5 (Extensiveness).** $F \subseteq \overline{F}$.

*Proof sketch.* Each $s \in F$ equals the supremum of the singleton
sub-collection $\{s\} \subseteq F$, which is nonempty; hence $s \in \overline{F}$
by Definition 6. ∎

**Lemma 6 (Closure is union-closed).** $\overline{F}$ is a union-closed family.

*Proof sketch.* Let $s = \bigvee_{g\in G_1} g$ and $t = \bigvee_{g\in G_2} g$
with nonempty $G_1, G_2 \subseteq F$. Then
$s \cup t = \bigvee_{g \in G_1 \cup G_2} g$ (sup distributes over union of index
sets), and $G_1 \cup G_2 \subseteq F$ is nonempty, so $s \cup t \in
\overline{F}$. ∎

Together, Lemmas 5 and 6 show $\overline{F}$ is the least union-closed family
containing $F$: extensive, union-closed, and (being generated by sups of
subfamilies) idempotent.

**Theorem 7 (Monotonicity of total occupancy under closure).**
$$\sum_{s \in F} |s| \;\le\; \sum_{s \in \overline{F}} |s|.$$

*Proof sketch.* By Lemma 5, $F \subseteq \overline{F}$. Cardinalities are
nonnegative, so summing the nonnegative quantity $|s|$ over the larger index set
$\overline{F}$ dominates the sum over $F$ (monotonicity of sums of nonnegative
terms under set inclusion). ∎

*Interpretation.* Total particle number, summed over all configurations, cannot
decrease under coarse-graining — a discrete analogue of entropy monotonicity
under closure dynamics, an arrow of time for the merging process.

### 3.6 The FKG base case

**Theorem 8 (Nonnegative correlation on the full powerset).** Let $\alpha$ be
finite. For any $a,b \in \alpha$, on $F = 2^\alpha$,
$$|2^\alpha|\cdot \mathrm{jc}(a,b) \;\ge\; \mathrm{mc}(a)\cdot \mathrm{mc}(b).$$

*Proof sketch.* The key counting lemma is: for any fixed set $s$,
$$\#\{\, t \subseteq \alpha : s \subseteq t \,\} = 2^{|\alpha| - |s|},$$
proved by the bijection $t \mapsto t \setminus s$ between supersets of $s$ and
subsets of $\alpha \setminus s$. Two cases:

- **$a = b$.** Then $\mathrm{jc}(a,a) = \mathrm{mc}(a)$ and the claim reduces to
  $|2^\alpha|\cdot\mathrm{mc}(a) \ge \mathrm{mc}(a)^2$, i.e. $\mathrm{mc}(a) \le
  |2^\alpha|$, which holds since the filtered subfamily is a subfamily of
  $2^\alpha$. (Self-correlation is strict whenever $0 < \mathrm{mc}(a) <
  |2^\alpha|$.)
- **$a \ne b$.** The counting lemma with $s = \{a\}$, $s=\{b\}$, $s=\{a,b\}$
  gives $\mathrm{mc}(a) = \mathrm{mc}(b) = 2^{|\alpha|-1}$ and
  $\mathrm{jc}(a,b) = 2^{|\alpha|-2}$. Then $|2^\alpha|\cdot\mathrm{jc}(a,b) =
  2^{|\alpha|}\cdot 2^{|\alpha|-2} = 2^{2|\alpha|-2} =
  \mathrm{mc}(a)\cdot\mathrm{mc}(b)$ — equality. ∎

*Interpretation.* Rescaling, $P(a\cap b) \ge P(a)P(b)$: coordinate indicators
are positively correlated, with equality (independence) for distinct sites and
strict positivity for coincident sites. This is the base case of the
**Fortuin–Kasteleyn–Ginibre (FKG) inequality**, the cornerstone of correlation
inequalities in statistical mechanics and percolation.

---

## 4. Algorithms

The theory is constructive; the following procedures compute every observable
and verify each theorem on concrete inputs.

### 4.1 Observable evaluation

Given $F$ (a list of subsets of a ground set) and elements $a,b$, compute
$\mathrm{mc}, \mathrm{jc}, \mathrm{uc}$ by a single linear scan over the
members of $F$ (cost $O(|F|\cdot|\alpha|)$). Theorems 1 and 4 are then checked by
direct arithmetic.

### 4.2 Union-closure construction

To build $\overline{F}$: maintain a worklist of discovered sets initialized to
$F$; repeatedly form pairwise unions of discovered sets and add any new ones;
stop at a fixed point. Because the universe of subsets is finite
($2^{|\alpha|}$), this terminates, and the result is the least union-closed
superfamily (Lemmas 5–6). Total occupancy before and after demonstrates
Theorem 7.

### 4.3 Frankl-direction certificate

Given $F$, test the averaged hypothesis $2\sum_{s}|s| \ge |F|\cdot|\alpha|$. If
it holds, Theorem 2 guarantees, and a single pass returns, a witness $a$ with
$2\,\mathrm{mc}(a) \ge |F|$.

---

## 5. Applications

1. **Discrete FKG / correlation inequalities.** Theorem 8 is the seed for
   proving positive association of monotone events on product spaces; Theorem 3
   identifies the monotone events as a subclass of union-closed families.
2. **Frankl's conjecture.** Theorem 2 settles the conjecture's conclusion in the
   "dense" regime and clarifies that the obstruction lies entirely in
   low-average-density families.
3. **Lattice-gas modeling.** The dictionary of §1 lets one import combinatorial
   identities (Theorems 1, 4) as exact sum rules for occupancy and correlation
   functions of monotone constrained systems.
4. **Coarse-graining dynamics.** Theorem 7 quantifies an irreversible,
   mass-non-decreasing closure step, useful in renormalization-style arguments
   on finite configuration spaces.

---

## 6. Discussion

The collection of results is deliberately elementary, but their organization
exposes a coherent statistical-mechanical reading of union-closed families. The
two genuinely structural inputs are the closure operator (Lemmas 5–6, Theorem 7)
and the powerset correlation (Theorem 8); the remaining identities (Theorems 1,
4) are exact sum rules, and Theorems 2–3 are the order-parameter and
order-theoretic bridges. A notable feature is how little is needed for the
"emergent popular element": Theorem 2 is pure pigeonhole over Theorem 1.

---

## 7. Future work

- **Beyond the base case.** Extend Theorem 8 from the full powerset to general
  union-closed families with a product-like measure, targeting a finite FKG
  inequality for monotone events identified by Theorem 3.
- **Closing the Frankl gap.** Replace the averaged hypothesis of Theorem 2 by a
  structural one, aiming at the full conjecture; the entropy method's recent
  $\approx 0.38$ bound suggests an information-theoretic refinement of the
  double-counting identity.
- **Quantitative closure.** Sharpen Theorem 7 to a *strict* gain $\sum_{\overline
  F}|s| - \sum_F |s|$ bounded below in terms of how far $F$ is from
  union-closed, an entropy-production estimate for the coarse-graining step.

---

## 8. Conclusion

We have assembled, with full formal backing, a compact theory presenting
union-closed families as positive-correlation systems: a conservation law
(Theorem 1), an order-parameter principle (Theorem 2), an order-theoretic
bridge (Theorem 3), the two-point inclusion–exclusion law (Theorem 4), a closure
operator with occupancy monotonicity (Lemmas 5–6, Theorem 7), and the FKG base
case (Theorem 8). The dictionary between combinatorics and discrete statistical
mechanics that emerges is, we believe, a fruitful lens on one of the most
stubborn open problems in extremal set theory.
