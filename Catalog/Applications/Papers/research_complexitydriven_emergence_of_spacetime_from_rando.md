# A Formal Logical Skeleton of Geometric Complexity Theory: Obstruction Maps, Orbit-Closure Non-Containment, and an Algebraic Natural-Proofs Barrier

**Author:** Aristotle
**Date:** 2026-06-21

## Abstract

Geometric Complexity Theory (GCT), introduced by Mulmuley and Sohoni, recasts central lower-bound questions of algebraic complexity — most famously the conjectured separation of the permanent from the determinant — as questions of *non-containment of orbit closures* in spaces of polynomials, to be resolved by exhibiting *representation-theoretic obstructions*. We present a fully axiomatic, machine-checkable formalization of the logical skeleton of this program. We isolate five axioms that any model of GCT must satisfy: orbit-closure containment is a preorder; orbit dimension is monotone under containment; small circuits imply containment in low-dimensional orbits; representation multiplicities are well-defined; and (Schur domination) containment forces pointwise multiplicity domination. From these we derive the fundamental theorem that a single multiplicity gap obstructs containment, and we build it up into a circuit lower-bound bridge: a target object having an obstruction against every low-dimensional competitor must have super-budget circuit size. We further formalize a dimension-to-circuit estimate, transitivity and composition lemmas, a self-consistency theorem (no object obstructs itself), and — turning the framework on itself — an **algebraic natural-proofs barrier**: any sound separator that uses only bounded-weight representations and that succeeds against a hard class whose multiplicities are supported on exponentially-high weights must itself use representations of exponentially large weight. All results are stated as theorems with complete proof sketches and correspond to mechanically verified Lean 4 declarations.

## 1. Introduction

The flagship open problem of computational complexity, $P \stackrel{?}{=} NP$, has an algebraic avatar — Valiant's $\mathrm{VP} \stackrel{?}{=} \mathrm{VNP}$ — which asks whether the permanent polynomial can be expressed as a polynomial-size determinant (up to affine substitution and padding). The relativization, algebrization, and natural-proofs barriers showed that broad families of proof techniques cannot settle such separations. Geometric Complexity Theory (GCT) is a response: it proposes that the separation is *geometric*, encoded in whether the orbit closure of one polynomial under the general linear group contains another, and that non-containment can be *certified* by representation theory.

Two features make GCT attractive and, simultaneously, hard. First, it converts an analytic/geometric impossibility (one variety not lying inside another) into a discrete search for an **obstruction**: an irreducible representation occurring with higher multiplicity in the coordinate ring of one object than the other. Second, the framework appears, optimistically, to evade the natural-proofs barrier — but only if the requisite obstructions are *small enough to write down*.

This paper formalizes the load-bearing logic of GCT and, crucially, also formalizes the obstacle. We make no claim to compute multiplicities of the determinant or permanent; rather, we prove that the *inferential machinery* of GCT is sound and self-consistent, and that an internal barrier governs the size of the certificates it requires. The development is axiomatic: we capture GCT as a type class `GCTSystem` and prove all consequences abstractly, so that any concrete instantiation (with genuine orbit closures and plethysm multiplicities) inherits the theorems for free.

## 2. Definitions

We work over an abstract type $\alpha$ of *objects* (intended model: homogeneous polynomials, or points of a $\mathrm{GL}$-representation).

**Definition 1 (Representation index).** A `RepIndex` is a pair $\lambda = (\mathrm{label}, \mathrm{weight})$ of natural numbers. The intended model is a partition (Young diagram) labelling an irreducible polynomial $\mathrm{GL}$-representation; `weight` corresponds to $|\lambda|$, the number of boxes / the degree. Equality of indices is decidable.

**Definition 2 (GCT system).** A `GCTSystem` on $\alpha$ consists of the following data and axioms.

- A relation $\preceq$ (`inClosure`), where $f \preceq g$ means $f \in \overline{\mathcal{O}_g}$, satisfying
  - **(Refl)** $f \preceq f$ for all $f$;
  - **(Trans)** $f \preceq g$ and $g \preceq h$ imply $f \preceq h$.
- A function $\dim : \alpha \to \mathbb{N}$ (`orbitDim`) with
  - **(Mono)** $f \preceq g \Rightarrow \dim(f) \le \dim(g)$.
- A function $\mathrm{size} : \alpha \to \mathbb{N}$ (`circuitSize`) with
  - **(SmallCircuit)** for all $f, B$, if $\mathrm{size}(f) \le B$ then there exists $g$ with $f \preceq g$ and $\dim(g) \le B^2$.
- A multiplicity function $\mathrm{mult} : \texttt{RepIndex} \to \alpha \to \mathbb{N}$ (`repMult`) with
  - **(Schur)** $f \preceq g \Rightarrow \forall \lambda,\ \mathrm{mult}(\lambda, f) \le \mathrm{mult}(\lambda, g)$.

The (Schur) axiom is the formal shadow of the fact that, for a $\mathrm{GL}$-stable degeneration $f \in \overline{\mathcal{O}_g}$, the coordinate ring of $\overline{\mathcal{O}_f}$ is a quotient/limit whose isotypic multiplicities are dominated by those of $\overline{\mathcal{O}_g}$. The (SmallCircuit) axiom abstracts the standard dimension count: an object computed by a size-$B$ circuit lies in a constructible family whose closure has dimension $O(B^2)$.

**Definition 3 (Obstruction witness).** For objects $f, g$, an `ObstructionWitness f g` is a representation index $\lambda$ together with a proof of the strict inequality $\mathrm{mult}(\lambda, f) > \mathrm{mult}(\lambda, g)$. Such a $\lambda$ is an *obstruction* certifying $f \notin \overline{\mathcal{O}_g}$.

**Definition 4 (Algebraic separator).** An `AlgSeparator` on $\alpha$ is a Boolean classifier $\mathrm{classify} : \alpha \to \{\text{true}, \text{false}\}$ together with a weight ceiling $\mathrm{maxWeight} \in \mathbb{N}$ satisfying:
- **(Sound)** if $\mathrm{classify}(f) = \text{true}$ and $\mathrm{classify}(g) = \text{false}$ then $f \not\preceq g$;
- **(BoundedReps)** if $\mathrm{classify}(f) = \text{true}$ and $\mathrm{classify}(g) = \text{false}$ then there exists $\lambda$ with $\mathrm{weight}(\lambda) \le \mathrm{maxWeight}$ and $\mathrm{mult}(\lambda, f) > \mathrm{mult}(\lambda, g)$.

A separator is the formal model of an "algebraic natural proof": a certificate that distinguishes a true class from a false class by exhibiting a low-weight obstruction.

**Definition 5 (Hard class).** A `HardClassData` on $\alpha$ consists of families $\mathrm{hard}, \mathrm{easy} : \mathbb{N} \to \alpha$ and a constant $\mathrm{exp\_const} \ge 1$ such that:
- **(HardExpWeight)** for all $n \ge 1$ and all $\lambda$, if $\mathrm{mult}(\lambda, \mathrm{hard}(n)) > 0$ then $\mathrm{weight}(\lambda) \ge 2^{\,\mathrm{exp\_const} \cdot n}$.

That is, the coordinate ring of the hard object is supported only on representations of exponentially large weight — the formal analogue of a function whose obstructions are necessarily complex.

## 3. Main results

Throughout, $S$ denotes a fixed `GCTSystem` on $\alpha$.

### 3.1 The obstruction principle

**Theorem 1 (Obstruction implies non-containment).** *If there exists an `ObstructionWitness f g`, then $f \not\preceq g$.*

*Proof.* Let the witness be $\lambda$ with $\mathrm{mult}(\lambda, f) > \mathrm{mult}(\lambda, g)$. Suppose for contradiction $f \preceq g$. By (Schur), $\mathrm{mult}(\lambda, f) \le \mathrm{mult}(\lambda, g)$, contradicting the strict inequality. $\square$

**Theorem 7 (Direct non-containment).** *If $\mathrm{mult}(\lambda, f) > \mathrm{mult}(\lambda, g)$ for some single $\lambda$, then $f \not\preceq g$.*

*Proof.* The hypothesis is exactly the data of an `ObstructionWitness f g`; apply Theorem 1. $\square$

**Theorem 10 (No self-obstruction).** *The type `ObstructionWitness f f` is empty.*

*Proof.* A witness would give $\mathrm{mult}(\lambda, f) > \mathrm{mult}(\lambda, f)$ for some $\lambda$, which is impossible; equivalently, by Theorem 1 it would yield $f \not\preceq f$, contradicting (Refl). $\square$

**Theorem 8 (Simultaneous non-containment).** *Given an `ObstructionWitness f g` and an `ObstructionWitness f h`, we have $f \not\preceq g$ and $f \not\preceq h$.*

*Proof.* Apply Theorem 1 to each witness. $\square$

### 3.2 Order-theoretic structure

**Theorem 3 (Containment transitivity).** *If $f \preceq g$ and $g \preceq h$ then $f \preceq h$.*

*Proof.* This is axiom (Trans). $\square$

**Theorem 4 (Multiplicity-domination transitivity).** *If $\mathrm{mult}(\lambda,f) \le \mathrm{mult}(\lambda,g)$ for all $\lambda$, and $\mathrm{mult}(\lambda,g) \le \mathrm{mult}(\lambda,h)$ for all $\lambda$, then $\mathrm{mult}(\lambda,f) \le \mathrm{mult}(\lambda,h)$ for all $\lambda$.*

*Proof.* Pointwise transitivity of $\le$ on $\mathbb{N}$. $\square$

**Theorem 6 (No obstruction implies local domination).** *Let $I$ be a finite set of representation indices. If for every $\lambda \in I$ it is **not** the case that $\mathrm{mult}(\lambda,f) > \mathrm{mult}(\lambda,g)$, then $\mathrm{mult}(\lambda,f) \le \mathrm{mult}(\lambda,g)$ for all $\lambda \in I$.*

*Proof.* For each $\lambda \in I$, $\neg(a > b)$ on $\mathbb{N}$ gives $a \le b$. $\square$

Theorem 6 is the decidability counterpart of the obstruction principle: on any finite candidate set of indices, the absence of an obstruction is verifiable and yields domination, so obstruction search is a well-posed finite computation per candidate set.

### 3.3 Dimension and circuit lower bounds

**Theorem 9 (Circuit from dimension).** *If $\dim(f) > B^2$ then $\mathrm{size}(f) > B$.*

*Proof.* Suppose $\mathrm{size}(f) \le B$. By (SmallCircuit) there is $g$ with $f \preceq g$ and $\dim(g) \le B^2$. By (Mono), $\dim(f) \le \dim(g) \le B^2$, contradicting $\dim(f) > B^2$. $\square$

**Theorem 5 (Orbit-dimension lower bound).** *If for every $g$ with $\dim(g) \le D$ there is an `ObstructionWitness f g`, then $\dim(f) > D$.*

*Proof.* Suppose $\dim(f) \le D$. Apply the hypothesis to $g := f$, obtaining an `ObstructionWitness f f`; by (Refl) $f \preceq f$, so Theorem 1 gives $f \not\preceq f$, a contradiction. (Equivalently, this contradicts Theorem 10.) $\square$

**Theorem 2 (Circuit lower bound from obstructions).** *Fix a budget $B$. If for every $g$ with $\dim(g) \le B^2$ there is an `ObstructionWitness f g`, then $\mathrm{size}(f) > B$.*

*Proof.* Suppose $\mathrm{size}(f) \le B$. By (SmallCircuit) there is $g$ with $f \preceq g$ and $\dim(g) \le B^2$. The hypothesis supplies an `ObstructionWitness f g`, whence by Theorem 1 $f \not\preceq g$ — contradicting $f \preceq g$. $\square$

Theorem 2 is the strategic core of GCT: it reduces a circuit lower bound for $f$ to a *catalog of representation-theoretic certificates*, one obstruction per low-dimensional competitor $g$. No reasoning about circuits remains in the hypothesis; the entire burden is moved into representation theory.

### 3.4 The algebraic natural-proofs barrier

**Theorem 11 (Algebraic natural-proofs barrier).** *Let $\mathrm{sep}$ be an `AlgSeparator` and let $H$ be a `HardClassData` with constant $c = \mathrm{exp\_const} \ge 1$. Fix $n \ge 1$ and suppose $\mathrm{sep}$ separates the hard class at level $n$, i.e. $\mathrm{classify}(\mathrm{hard}(n)) = \text{true}$ and $\mathrm{classify}(\mathrm{easy}(n)) = \text{false}$. Then*
$$\mathrm{maxWeight}(\mathrm{sep}) \ \ge\ 2^{\,c\,n}.$$

*Proof.* By (BoundedReps), the separation yields a representation index $\lambda$ with $\mathrm{weight}(\lambda) \le \mathrm{maxWeight}$ and $\mathrm{mult}(\lambda, \mathrm{hard}(n)) > \mathrm{mult}(\lambda, \mathrm{easy}(n))$. Since multiplicities are non-negative, $\mathrm{mult}(\lambda, \mathrm{hard}(n)) > \mathrm{mult}(\lambda, \mathrm{easy}(n)) \ge 0$, so $\mathrm{mult}(\lambda, \mathrm{hard}(n)) > 0$. By (HardExpWeight) applied to this $\lambda$ (using $n \ge 1$), $\mathrm{weight}(\lambda) \ge 2^{cn}$. Chaining, $\mathrm{maxWeight} \ge \mathrm{weight}(\lambda) \ge 2^{cn}$. $\square$

The barrier is the algebraic mirror of Razborov–Rudich. A separator is precisely a "natural" certificate: sound, and constructive via low-weight obstructions. The theorem says no such certificate of small weight ceiling can succeed against a class whose multiplicities are concentrated at exponential weight. The GCT program therefore does not evade the difficulty; it *relocates* it into the question of whether obstructions of feasible weight exist for the genuine determinant/permanent instances.

## 3.5 A worked concrete instantiation

To demonstrate that the axioms are consistent and the theorems have content, we exhibit an explicit finite model and trace each theorem through it. Let $\alpha = \{E_0, E_1, F\}$ with the preorder generated by $E_0 \preceq E_1 \preceq F$ (and reflexivity), so that $\overline{\mathcal{O}_F} \supseteq \{E_0, E_1, F\}$ while $\overline{\mathcal{O}_{E_1}} = \{E_1\}$ (relative to objects below it, $E_0 \preceq E_1$). Assign orbit dimensions $\dim(E_0)=1,\ \dim(E_1)=4,\ \dim(F)=26$ and circuit sizes $\mathrm{size}(E_0)=1,\ \mathrm{size}(E_1)=2,\ \mathrm{size}(F)=6$. Choose four representation indices $\lambda_0,\dots,\lambda_3$ of weights $2,3,5,7$ and multiplicity vectors (listed as $(\mathrm{mult}(\cdot,E_0),\mathrm{mult}(\cdot,E_1),\mathrm{mult}(\cdot,F))$):
$$\lambda_0 : (0,1,2),\quad \lambda_1 : (1,1,3),\quad \lambda_2 : (0,2,4),\quad \lambda_3 : (0,0,7).$$

Each vector is nondecreasing along $E_0 \preceq E_1 \preceq F$, so (Schur) holds; dimensions are nondecreasing, so (Mono) holds; and one checks (SmallCircuit) directly (e.g. $\mathrm{size}(F)=6$, and the only $g$ with $F \preceq g$ is $F$ itself with $\dim = 26 \le 6^2 = 36$). Now:

- **Theorem 1/7.** At $\lambda_0$, $\mathrm{mult}(\lambda_0,F)=2 > 1 = \mathrm{mult}(\lambda_0,E_1)$, so $F \not\preceq E_1$: the object $F$ provably does not lie in the orbit closure of $E_1$, certified by a single integer comparison.
- **Theorem 10.** No index has $\mathrm{mult}(\lambda,F) > \mathrm{mult}(\lambda,F)$, so there is no self-obstruction; the calculus does not refute $F \preceq F$.
- **Theorem 9.** $\dim(F) = 26 > 25 = 5^2$, hence $\mathrm{size}(F) > 5$; indeed $\mathrm{size}(F) = 6$.
- **Theorem 5.** The competitors with $\dim \le 4$ are $E_0,E_1$; $F$ obstructs both (at $\lambda_0$ and $\lambda_2$ respectively, or at $\lambda_3$ which is $7>0$ for both), so $\dim(F) > 4$.
- **Theorem 2.** With budget $B=2$, the competitors with $\dim \le B^2 = 4$ are again $E_0,E_1$; $F$ obstructs all of them, hence $\mathrm{size}(F) > 2$.
- **Theorem 11.** Replace the multiplicity table by a hard class with $\mathrm{mult}(\lambda,\mathrm{hard}(n)) > 0$ only when $\mathrm{weight}(\lambda) \ge 2^{cn}$. Then no separator with $\mathrm{maxWeight} < 2^{cn}$ can exhibit the required low-weight gap, so any successful separator has $\mathrm{maxWeight} \ge 2^{cn}$.

This model is realized verbatim in the accompanying numerical demonstration, where the five axioms are checked by exhaustive computation and each theorem's conclusion is verified against the ground-truth relation.

## 4. Algorithmic content

Although the framework is axiomatic, its proofs are constructive enough to read off algorithms for any decidable instantiation.

**Algorithm A (Finite obstruction search / certified non-containment).** Given $f, g$ and a finite candidate set $I$ of representation indices with a computable $\mathrm{mult}$, scan $I$; if some $\lambda \in I$ has $\mathrm{mult}(\lambda,f) > \mathrm{mult}(\lambda,g)$, output $\lambda$ as a certificate of $f \not\preceq g$ (Theorem 1); otherwise report "no obstruction in $I$," which by Theorem 6 certifies pointwise domination on $I$. Complexity: $O(|I|)$ multiplicity evaluations.

**Algorithm B (Lower bound by obstruction catalog).** Given $f$, a budget $B$, and an enumeration of competitor objects $g$ with $\dim(g) \le B^2$, invoke Algorithm A on each $(f,g)$; if every competitor receives a certificate, conclude $\mathrm{size}(f) > B$ by Theorem 2. The cost is dominated by the number of competitors times the per-pair search cost; the barrier (Theorem 11) lower-bounds the *weight*, hence the search space $|I|$, needed for genuinely hard $f$.

**Algorithm C (Barrier weight estimator).** Given a hard-class constant $c$ and level $n$, return the certified lower bound $2^{cn}$ on any successful separator's weight ceiling (Theorem 11). This converts a structural fact about a hard class into a concrete infeasibility threshold for bounded-weight proof systems.

## 4.1 Relation to the classical natural-proofs barrier

The Razborov--Rudich natural-proofs barrier concerns combinatorial proofs of Boolean circuit lower bounds. A proof is *natural* if it identifies a property of Boolean functions that is (i) *useful* (every easy function lacks it, so possessing it implies hardness), (ii) *large* (a random function has it with non-negligible probability), and (iii) *constructive* (the property is efficiently testable from the truth table). Razborov and Rudich proved that a natural property useful against sufficiently strong circuit classes would yield an efficient distinguisher breaking standard pseudorandom-function candidates --- contradicting widely believed cryptographic hardness.

Theorem 11 is the algebraic analogue restricted to the GCT certificate format. The separator's two conditions, (Sound) and (BoundedReps), play the roles of usefulness and constructivity: soundness guarantees the certificate is never a false positive, while bounded reps captures the demand that the distinguishing object (a representation of weight $\le \mathrm{maxWeight}$) be *small*, i.e. cheaply describable. The hard class plays the role of the pseudorandom target: its multiplicity support sits entirely at exponential weight. The conclusion --- that any successful bounded-weight separator must in fact use exponential weight --- is precisely the statement that a *small/constructive* certificate cannot succeed against the hard class. Where Razborov--Rudich invoke cryptographic assumptions, the algebraic version is unconditional given the (HardExpWeight) hypothesis, which encapsulates exactly the structural property whose verification for explicit polynomials is the open mathematical problem.

## 4.2 Why an axiomatic treatment

The choice to axiomatize, rather than construct, the orbit-closure geometry deserves comment. Building a faithful model would require: the coordinate ring of an orbit closure, its decomposition into $\mathrm{GL}$-isotypic components, semicontinuity of multiplicities under degeneration, and the dimension theory of constructible sets --- each a substantial development. By isolating the four properties these constructions deliver (Refl/Trans, Mono, SmallCircuit, Schur), we obtain theorems that are *automatically inherited* by any future faithful model. This is the standard discipline of interface-driven formalization: prove against the smallest sufficient interface, so the deep analytic work need only be done once, at the point of instantiation, and cannot accidentally be used circularly inside the lower-bound logic. The five axioms are individually plausible and, in the worked model above, simultaneously satisfiable, ruling out the degenerate possibility that the theory is vacuous.

## 5. Applications and interpretation

1. **Lower bounds as certificate catalogs.** Theorem 2 reframes "prove $f$ has no size-$B$ circuit" as "produce one obstruction per low-dimensional competitor." This is the operational content of GCT and the target of all multiplicity computations (plethysm, Kronecker, Littlewood–Richardson coefficients) in the literature.

2. **Consistency guarantees.** Theorems 10 and 5 guarantee the obstruction calculus never derives the absurd statement $f \not\preceq f$; any formalization or automated search built on it cannot "prove" a self-non-containment, eliminating a class of silent bugs in lower-bound software.

3. **Barrier-aware proof search.** Theorem 11 tells an implementer that, against hard classes, raising `maxWeight` is unavoidable: no clever bounded-weight heuristic can succeed. This guides resource allocation in any practical obstruction-finding system and connects to the design of complexity-optimal certificates.

4. **A reusable abstraction.** Because everything is proved from the five axioms, any structure exhibiting a monotone preorder with a dominated invariant and a dimension/size coupling inherits the entire theory — including settings beyond polynomials (e.g. tensor degenerations, matrix multiplication border rank), wherever a "Schur-type" domination holds.

## 6. Discussion

The contribution here is deliberately *logical* rather than computational. We do not compute a single plethysm coefficient. What we do provide is a guarantee that the inferential scaffold of GCT is sound, self-consistent, transitive, compositional, and subject to a precisely stated internal barrier. Historically, lower-bound arguments have failed not for want of ambition but for subtle circularity; an axiomatized, mechanically checked skeleton removes that failure mode from the parts it covers.

The relationship between Theorem 2 (the bridge) and Theorem 11 (the barrier) is the intellectual heart of the paper. The bridge promises that obstructions suffice; the barrier proves that, for the hardest classes, those obstructions must be exponentially heavy. Neither is in tension with the GCT conjecture; together they delineate exactly where the remaining mathematical difficulty lives — namely in *exhibiting* high-weight obstructions for explicit determinant/permanent-type instances, not in the logic that would deploy them.

## 7. Future work

A natural next step is to instantiate the abstract `GCTSystem` with a concrete model — e.g. a small symmetric-function setting where multiplicities are genuine plethysm coefficients — and verify the five axioms there, turning the abstract theorems into concrete certified non-containments. A second direction is to refine the barrier: quantify how the weight ceiling must scale with the *number* of competitors in Theorem 2, and whether amortized certificates can beat the per-instance $2^{cn}$ bound. A third is to port the framework to border-rank settings for matrix multiplication, where the same preorder/domination pattern appears.

Beyond GCT proper, the Phase-A program records a parallel set of falsifiable conjectures in the adjacent setting of emergent geometry from tensor networks (monogamy of mutual information, metric-space structure of an emergent network distance, saturation criteria for strong subadditivity, area-law dimension estimates, and random-network concentration); these are recorded verbatim in the package metadata as candidate formalization targets and share the structural motif — a submodular/monotone invariant generating an order theory — exploited here.

## 8. Conclusion

We have given a complete, machine-verified logical skeleton for Geometric Complexity Theory: five axioms, an obstruction principle, a circuit lower-bound bridge, supporting order theory and consistency results, and an algebraic natural-proofs barrier. The development isolates with certainty what is *easy* (the logic) from what remains *hard* (the multiplicity computations), and proves, inside the framework, why the hard part is hard. It is a small piece of solid ground over a deep open problem — and precisely the piece on which future, heavier mathematics can safely stand.
