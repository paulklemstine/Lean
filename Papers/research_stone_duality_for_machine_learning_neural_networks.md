# Stone Duality for Neural Networks: Activation Patterns as a Finite Boolean Algebra

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

We develop, from first principles, the finite–Boolean–algebra core of *Stone
duality* for a single fully-connected (ReLU-type) neural-network layer evaluated
on a finite sample of inputs. Evaluating a layer of $n$ neurons at a point and
recording which neurons are active yields an *activation pattern*, an element of
the finite Boolean algebra $\{0,1\}^n$ — the *syntax*. The realized patterns are
the layer's *linear regions*, and every set of patterns determines a *decision
region*; the collection of decision regions forms the *decision algebra* — the
*semantics*. Our main theorem is an exact Stone-duality count: **if a layer
realizes $r$ linear regions on a sample, its decision algebra has exactly $2^r$
elements**, and the atoms of that algebra are precisely the linear regions. We
prove that the pattern-to-region map is a Boolean-algebra homomorphism, that
decision regions depend only on realized patterns, that the homomorphism is
injective on realized patterns, and we derive the region bounds
$\#\text{regions} \le \min(2^n, m)$ together with a VC-style capacity bound: a
layer of $n$ neurons shatters at most $2^n$ points. We also correct a natural
but false conjecture equating VC dimension with the number of linear regions.
All results are stated for an abstract activation map and then specialized to a
concrete real-weight ReLU layer. We include worked numerical examples,
algorithms for computing the decision algebra, and a discussion of extensions to
multilayer networks and hyperplane arrangements.

---

## 1. Introduction

Piecewise-linear neural networks — those built from rectified linear units
(ReLU) — partition their input space into convex cells, the *linear regions*, on
each of which the network is affine. The number of linear regions is a widely
used measure of a network's expressive power. This paper places that geometry
inside a classical algebraic frame: **Stone duality**.

Stone's representation theorem asserts that every Boolean algebra $B$ is
isomorphic to the algebra of clopen subsets of a topological space $S(B)$, its
*Stone space*. Abstract propositions (syntax) become concrete clopen regions
(semantics); *and*, *or*, *not* become intersection, union, complement. In the
*finite* case the statement is elementary and sharp: a finite Boolean algebra
with $r$ atoms is isomorphic to the powerset of an $r$-element set, hence has
$2^r$ elements, and its Stone space is the discrete space on those $r$ atoms.

We show that a single neural-network layer, evaluated on a finite sample,
carries exactly such a finite Boolean algebra. Its atoms are the linear regions;
its elements are the decision regions; and the finite Stone-duality count
applies verbatim. This gives a precise dictionary between the *syntax* of
activation patterns and the *semantics* of decision regions, and yields honest
capacity bounds while refuting an overreaching conjecture.

### Contributions

1. A clean formal model of a neural layer as an *activation-pattern map* into a
   finite Boolean algebra (Section 3).
2. Two complementary bounds on the number of linear regions, and their minimum
   (Section 4).
3. A proof that the pattern-to-region map is a Boolean-algebra homomorphism, and
   that it depends only on — and is injective on — the realized patterns
   (Sections 5–6).
4. The exact Stone-duality count $|B(f)| = 2^r$ and the identification of the
   atoms with the linear regions (Section 7).
5. Capacity consequences: $|B(f)| \le 2^m$ and the shattering bound $m \le 2^n$;
   plus an explicit refutation of the "VC dimension = number of linear regions"
   conjecture (Section 8).
6. Specialization to an explicit real-weight ReLU layer (Section 9).

---

## 2. Background: finite Stone duality

Let $B$ be a Boolean algebra with operations $\vee$ (join), $\wedge$ (meet), and
$\neg$ (complement), bottom $0$, and top $1$. An **atom** is a minimal nonzero
element. When $B$ is finite, every element is the join of the atoms below it, and
distinct sets of atoms yield distinct elements. Consequently:

> **Finite Stone duality.** A finite Boolean algebra with atom set $A$ is
> isomorphic to the powerset $\mathcal{P}(A)$; in particular it has exactly
> $2^{|A|}$ elements. Its Stone space is the finite discrete space on $A$, and
> its clopen subsets are all subsets of $A$.

Our task is to exhibit, for a neural layer, a natural finite Boolean algebra
whose atoms are the linear regions, so that this counting theorem applies.

---

## 3. Model and definitions

Fix a finite input sample $X$ (a finite type with decidable equality) and a
layer of $n$ neurons.

**Definition 3.1 (Activation-pattern map).** An *activation-pattern map* is a
function
$$\mathrm{act} : X \to (\,\{1,\dots,n\} \to \mathbb{B}\,), \qquad \mathbb{B} = \{\text{false},\text{true}\},$$
assigning to each input point the Boolean vector of which neurons are active
(pre-activation $>0$). The codomain $\mathbb{B}^n$ is a finite Boolean algebra
with $2^n$ elements — the **pattern space** (the *syntax*).

**Definition 3.2 (Linear regions).** The **linear regions** realized by
$\mathrm{act}$ are the distinct patterns that occur:
$$\mathrm{linearRegions}(\mathrm{act}) = \{\, \mathrm{act}(x) : x \in X \,\} = \mathrm{image}(\mathrm{act}).$$
Its cardinality is the number of distinct cells cut on the sample.

**Definition 3.3 (Decision region).** For a set $S$ of patterns, the
**decision region** it selects is
$$\mathrm{region}(S) = \{\, x \in X : \mathrm{act}(x) \in S \,\}.$$
This is the *semantic* counterpart (a subset of $X$) of the *syntactic* object
$S$.

**Definition 3.4 (Decision algebra).** The **decision algebra** of the layer is
the family of all decision regions,
$$B(f) = \mathrm{decisionAlgebra}(\mathrm{act}) = \{\, \mathrm{region}(S) : S \subseteq \mathbb{B}^n \,\}.$$

**Definition 3.5 (Shattering).** The layer **shatters** $X$ if every subset of
$X$ is a decision region, i.e. $B(f) = \mathcal{P}(X)$.

---

## 4. Bounds on the number of linear regions

**Theorem 4.1 (Syntactic bound).**
$\;\#\mathrm{linearRegions}(\mathrm{act}) \le 2^n.$

*Proof sketch.* The realized patterns are a subset of the pattern space
$\mathbb{B}^n$, which has exactly $2^n$ elements; cardinality is monotone under
subsets. $\qquad\blacksquare$

**Theorem 4.2 (Sample bound).**
$\;\#\mathrm{linearRegions}(\mathrm{act}) \le |X|.$

*Proof sketch.* The linear regions are the image of $\mathrm{act}$, and the
image of a function has at most as many elements as its finite domain
$X$. $\qquad\blacksquare$

**Theorem 4.3 (Combined bound).**
$\;\#\mathrm{linearRegions}(\mathrm{act}) \le \min(2^n,\, |X|).$

*Proof sketch.* Immediate from Theorems 4.1 and 4.2: a quantity below two
ceilings is below their minimum. $\qquad\blacksquare$

The two bounds capture the tension between *expressivity* (the syntax can host
up to $2^n$ regions) and *observability* (a finite sample of size $|X|$ can
reveal at most $|X|$ of them).

---

## 5. The pattern-to-region map is a Boolean homomorphism

We show $\mathrm{region}(\cdot)$ translates the Boolean structure of the syntax
into set operations on the semantics — the operative half of Stone duality.

**Theorem 5.1 (Homomorphism).** For all pattern sets $S, T$:
$$\mathrm{region}(S \cup T) = \mathrm{region}(S) \cup \mathrm{region}(T), \qquad
\mathrm{region}(S \cap T) = \mathrm{region}(S) \cap \mathrm{region}(T),$$
$$\mathrm{region}(\varnothing) = \varnothing, \qquad
\mathrm{region}(\mathbb{B}^n) = X,$$
and $S \subseteq T \implies \mathrm{region}(S) \subseteq \mathrm{region}(T)$.
Together with $\mathrm{region}(\mathbb{B}^n) = X$, these give
$\mathrm{region}(\neg S) = X \setminus \mathrm{region}(S)$ where $\neg S$ is the
complement within pattern space.

*Proof sketch.* Each identity is proved pointwise. For a point $x$, membership
$x \in \mathrm{region}(S)$ is by definition $\mathrm{act}(x) \in S$. Then
$x \in \mathrm{region}(S \cup T) \iff \mathrm{act}(x) \in S \cup T \iff
\mathrm{act}(x)\in S \text{ or } \mathrm{act}(x)\in T \iff x \in \mathrm{region}(S)\cup\mathrm{region}(T)$,
and similarly for the other operations. Emptiness and universality are the
$S=\varnothing$ and $S=\mathbb{B}^n$ cases; monotonicity follows from
membership preservation. $\qquad\blacksquare$

Thus $S \mapsto \mathrm{region}(S)$ is a homomorphism of Boolean algebras from
$\mathcal{P}(\mathbb{B}^n)$ into $\mathcal{P}(X)$: syntax to semantics.

---

## 6. Decision regions see only the realized patterns

The homomorphism of Section 5 is not injective on all of
$\mathcal{P}(\mathbb{B}^n)$ — unrealized patterns are invisible. We localize to
the realized patterns.

**Theorem 6.1 (Locality).** For every pattern set $S$,
$$\mathrm{region}\big(S \cap \mathrm{linearRegions}(\mathrm{act})\big) = \mathrm{region}(S).$$

*Proof sketch.* A point $x$ contributes only via its own pattern
$\mathrm{act}(x)$, which is always a realized pattern; intersecting $S$ with the
realized patterns therefore cannot change whether $\mathrm{act}(x) \in S$.
$\qquad\blacksquare$

**Theorem 6.2 (Reduction to realized patterns).** The decision algebra is the
image, under $\mathrm{region}$, of the powerset of the linear regions:
$$B(f) = \{\, \mathrm{region}(S) : S \subseteq \mathrm{linearRegions}(\mathrm{act}) \,\}.$$

*Proof sketch.* ($\supseteq$) Every $S \subseteq \mathrm{linearRegions}$ is in
particular a subset of $\mathbb{B}^n$, so its region is a decision region.
($\subseteq$) Given any decision region $\mathrm{region}(S)$, Theorem 6.1
rewrites it as $\mathrm{region}(S \cap \mathrm{linearRegions})$, and
$S \cap \mathrm{linearRegions}$ is a subset of the linear regions.
$\qquad\blacksquare$

**Theorem 6.3 (Faithfulness on realized patterns).** The map
$\mathrm{region}(\cdot)$ is injective on subsets of
$\mathrm{linearRegions}(\mathrm{act})$: if $S, T \subseteq \mathrm{linearRegions}$
and $\mathrm{region}(S) = \mathrm{region}(T)$, then $S = T$.

*Proof sketch.* Suppose $S \ne T$; without loss of generality some realized
pattern $p$ lies in $S \setminus T$. Because $p$ is realized, there is a sample
point $x$ with $\mathrm{act}(x) = p$. Then $x \in \mathrm{region}(S)$ (since
$p \in S$) but $x \notin \mathrm{region}(T)$ (since $p \notin T$), so the regions
differ — contradiction. Hence $S = T$. $\qquad\blacksquare$

Theorem 6.3 says the atoms of $B(f)$ are exactly the (nonempty) fibers
$\{x : \mathrm{act}(x) = p\}$ over realized patterns $p$: distinct realized
patterns produce distinct, indivisible cells.

---

## 7. Stone duality: the exact count

Combining reduction (6.2) with faithfulness (6.3) yields the main theorem.

**Theorem 7.1 (Stone-duality count).** Let
$r = \#\mathrm{linearRegions}(\mathrm{act})$. Then
$$|B(f)| = 2^{\,r}.$$

*Proof sketch.* By Theorem 6.2, $B(f)$ is the image of
$\mathcal{P}(\mathrm{linearRegions})$ under $\mathrm{region}$. By Theorem 6.3
this map is injective, so the image has the same cardinality as the domain. The
powerset of an $r$-element set has $2^r$ elements. Hence
$|B(f)| = 2^r$. $\qquad\blacksquare$

**Interpretation.** $B(f)$ is a finite Boolean algebra with $r$ atoms — the
linear regions. By finite Stone duality (Section 2) it is isomorphic to
$\mathcal{P}(\{\text{linear regions}\})$, its Stone space is the discrete space
on the $r$ linear regions, and its clopen subsets are exactly the decision
regions. The continuous geometry of the layer's decision surface on the sample
is thus captured, up to the Boolean structure of decisions, by the single
integer $r$.

---

## 8. Capacity consequences

**Theorem 8.1 (Algebra size bound).**
$\;|B(f)| \le 2^{|X|}.$

*Proof sketch.* By Theorem 7.1, $|B(f)| = 2^r$, and by Theorem 4.2,
$r \le |X|$; monotonicity of $t \mapsto 2^t$ finishes it. (Equivalently, $B(f)$
embeds into $\mathcal{P}(X)$.) $\qquad\blacksquare$

**Theorem 8.2 (Shattering bound).** If the layer shatters $X$, then
$$|X| \le 2^n.$$

*Proof sketch.* Shattering means $B(f) = \mathcal{P}(X)$, so
$|B(f)| = 2^{|X|}$. By Theorem 7.1 this equals $2^r$, hence $r = |X|$: every
sample point has its own realized pattern. But by Theorem 4.1 the number of
realized patterns is at most $2^n$, so $|X| = r \le 2^n$. $\qquad\blacksquare$

This is the correct VC-style statement: **a layer of $n$ neurons can shatter a
sample of at most $2^n$ points.**

### 8.1 A false conjecture, corrected

It is tempting to conjecture that the VC dimension of a network equals its
number of atoms, i.e. its number of linear regions. **This equality is false in
general.** A single affine neuron on $\mathbb{R}^d$ realizes a *half-space*
classifier; the VC dimension of half-spaces in $\mathbb{R}^d$ is $d+1$, governed
by the dimension of the ambient geometry, not by any count of regions (a single
neuron cuts the space into just two regions, yet its VC dimension grows linearly
with $d$). We therefore do **not** assert "VC dimension = number of linear
regions." What we prove are the correct structural facts: the atoms of the
decision algebra are the linear regions (Theorem 6.3), the algebra has exactly
$2^r$ elements (Theorem 7.1), and shattering $m$ points requires $m \le 2^n$
(Theorem 8.2).

---

## 9. A concrete ReLU layer

All results above are stated for an abstract $\mathrm{act}$; here we instantiate
it with explicit real weights.

**Definition 9.1 (Neuron activation).** For weight rows
$W : \{1,\dots,n\} \to \mathbb{R}^d$, biases $b : \{1,\dots,n\} \to \mathbb{R}$,
and input $x \in \mathbb{R}^d$, define
$$\mathrm{neuronActivation}(W,b,x)_i = [\, \langle W_i, x\rangle + b_i > 0 \,],$$
where $[\cdot]$ is the Iverson bracket (true iff the pre-activation is positive).

**Definition 9.2 (Sample activation).** For a sample $\mathrm{pts} : X \to \mathbb{R}^d$,
$$\mathrm{sampleActivation}(W,b,\mathrm{pts})(x) = \mathrm{neuronActivation}(W,b,\mathrm{pts}(x)).$$

Every abstract theorem specializes. In particular:

**Corollary 9.3.** A ReLU layer of $n$ neurons realizes at most
$\min(2^n, |X|)$ linear regions on any finite sample (from Theorem 4.3).

**Corollary 9.4.** Its decision algebra has exactly $2^{r}$ elements, where $r$
is the number of linear regions it realizes on the sample (from Theorem 7.1).

The boundary between two adjacent linear regions is a subset of the hyperplane
$\{x : \langle W_i, x\rangle + b_i = 0\}$ of the neuron whose activation flips
across it — recovering the familiar picture of a ReLU decision surface as an
arrangement of $n$ hyperplanes.

---

## 10. Algorithms

**Algorithm A (Decision-algebra construction).** Given weights, biases, and a
sample, compute the activation patterns; take their distinct values (the linear
regions $R$, $|R| = r$); enumerate the $2^r$ subsets of $R$; map each subset to
its decision region. By Theorems 6.2–6.3 this enumerates $B(f)$ exactly once
each. Complexity: $O(|X|\,n\,d)$ for the patterns plus $O(2^r \cdot r)$ for the
enumeration; the exponential factor is intrinsic — $|B(f)| = 2^r$.

**Algorithm B (Region counting and bound verification).** Compute
$r = |R|$ and check $r \le \min(2^n, |X|)$; report $|B(f)| = 2^r$.

**Algorithm C (Shattering test).** The layer shatters $X$ iff the $|X|$
patterns are pairwise distinct (equivalently $r = |X|$); this both tests
shattering and certifies the necessary condition $|X| \le 2^n$.

Pseudocode and reference implementations accompany this paper.

---

## 11. Related ideas and discussion

The count of linear regions is a classical proxy for the expressive power of
piecewise-linear networks, and single-layer region counts are governed by
hyperplane-arrangement combinatorics. Our contribution is to recast this count
*algebraically*: the linear regions are the atoms of a finite Boolean algebra,
the decision regions are its elements, and finite Stone duality supplies the
exact count $2^r$. This reframing connects region counting to the toolkit of
logic and combinatorics — atoms, homomorphisms, shattering, and growth
functions — and cleanly separates the two ceilings on region count (the
syntactic $2^n$ and the observational $|X|$).

The refutation in Section 8.1 is a cautionary note: expressivity measured by
*region count* and capacity measured by *VC dimension* are genuinely different
invariants. Stone duality relates region count to the *size of the decision
algebra*, not to VC dimension; the honest capacity statement is the shattering
bound $m \le 2^n$.

---

## 12. Future directions

- **Stone space as a topological object.** Package the decision algebra as a
  concrete Boolean algebra and build its Stone space via profinite / Boolean-
  spectrum machinery, proving it is the finite discrete space on the linear
  regions and that clopen sets correspond to decision regions.
- **Multilayer composition.** Extend the activation map to $L$ layers with
  widths $w_1,\dots,w_L$; show the layerwise pattern map factors and bound the
  total regions by $2^{w_1+\cdots+w_L}$.
- **Sauer–Shelah / growth function.** Relate the size of the decision algebra
  restricted to subsamples to the growth function and derive the true VC bound
  for halfspace-based classes.
- **Geometric linear regions.** Replace the finite sample by an arrangement of
  hyperplanes in $\mathbb{R}^d$ and connect the region count to Zaslavsky's
  region-counting formula.

---

## 13. Conclusion

A single neural-network layer, evaluated on a finite sample, carries a finite
Boolean algebra whose atoms are its linear regions and whose elements are its
decision regions. The pattern-to-region map is a Boolean homomorphism, faithful
on realized patterns, giving an exact Stone-duality count: a layer with $r$
linear regions has a decision algebra of size $2^r$. From this follow honest
capacity bounds — including the shattering bound $m \le 2^n$ — and a correction
to the tempting but false identification of VC dimension with region count.
Syntax (activation patterns) and semantics (decision regions) are two faces of
one finite Boolean algebra, exactly as Stone duality predicts.
