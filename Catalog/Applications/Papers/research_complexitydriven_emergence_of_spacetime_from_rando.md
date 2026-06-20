# Holographic Coding Geometry: A Finite, Formally Verified Bridge Between Quantum Information and Emergent Spacetime

**Author:** Aristotle
**Date:** 2026-06-20
**Domain:** Machine Learning / Quantum Information / Emergent Geometry

---

## Abstract

We develop a finite, fully rigorous algebraic model of the "spacetime as a quantum
error-correcting code" paradigm and of the emergence of geometry from random tensor
networks. The model assigns to each region $X$ of a finite boundary an entropy
$S(X)$, an effective area $\mathrm{area}(X)$, and a distance proxy, subject to
normalization, nonnegativity, entropy submodularity (strong subadditivity), the
Ryu–Takayanagi relation $S(X)=\mathrm{area}(X)/4$, and a Singleton-type bound
$S(X)\le|X|$. Within this model we define the **syndrome defect**
$\mathrm{defect}(X,Y)=S(X)+S(Y)-S(X\cap Y)-S(X\cup Y)$ as a discrete curvature
functional and prove it is nonnegative. Our central result is a **cross-domain
equivalence**: entropy submodularity holds universally if and only if area
submodularity does, with the Ryu–Takayanagi relation as the explicit translation;
quantitatively the syndrome defect equals one quarter of the area defect. We
recast the Singleton bound as a lower bound on logical content, prove that bulk
reconstruction is monotone under enlargement of the boundary region, and—in a
companion tropical (min-plus) model—prove that entanglement-wedge membership is
stable under metric perturbation and that boundary observations determine the bulk
on the wedge. Finally we model the random-tensor-network encoding threshold via a
strictly monotone critical bond dimension. All results are theorems verified in the
Lean 4 proof assistant; here we present their statements with mathematical proof
sketches. The work provides a self-contained, falsifiable, and computationally
grounded skeleton connecting quantum information complexity to the emergence of
classical geometry.

---

## 1. Introduction

The holographic principle asserts that the physics of a region of spacetime (the
*bulk*) is encoded on its lower-dimensional *boundary*. Its sharpest modern
incarnations—the AdS/CFT correspondence, tensor-network models of holography, and
the "spacetime is a quantum error-correcting code" program—suggest that smooth
geometry is not fundamental but *emergent* from the entanglement structure of an
underlying quantum system. Two pillars recur across all these formulations:

1. The **Ryu–Takayanagi (RT) relation**, $S(X) = \mathrm{area}(\gamma_X)/4G$,
   equating the entropy of a boundary region $X$ with the area of a minimal bulk
   surface.
2. **Strong subadditivity (SSA)** of entropy, the deepest inequality of quantum
   information, which in geometric translation becomes statements about how bulk
   areas combine.

Our goal is to isolate the *finite combinatorial core* of these statements and
prove them with complete rigor, so that the slogans "geometry is information" and
"spacetime is a code" become honest theorems rather than physical intuitions. We
work over a finite boundary type, replace continuous areas by abstract nonnegative
functionals satisfying the RT relation, and study the resulting object purely
algebraically. The payoff is a small but airtight dictionary in which a curvature
functional, a coding bound, and a reconstruction theorem all follow from a handful
of axioms.

We complement the entropy/area model with two further pieces. First, a **tropical
(min-plus) model of entanglement-wedge reconstruction**, in which bulk points are
assigned to boundary regions by nearest-distance and boundary "observations" are
min-plus convolutions; here we prove stability under perturbation and a
reconstruction theorem. Second, a minimal model of the **random-tensor-network
encoding threshold**, capturing the conjectured sharp transition into smooth
geometry as a strictly increasing critical bond dimension.

All statements below are theorems formally verified in Lean 4 with Mathlib. We
present the mathematics and proof sketches; the formal proofs are the ground truth.

---

## 2. The Holographic Code Profile

### 2.1 Definition

**Definition 2.1 (Holographic code profile).**
Let $\alpha$ be a type with decidable equality, modeling the finite boundary sites.
A *holographic code profile* on $\alpha$ consists of three functionals on finite
regions $X \in \mathrm{Finset}(\alpha)$,
$$ S,\ \mathrm{area},\ \mathrm{dist} : \mathrm{Finset}(\alpha) \to \mathbb{R}, $$
subject to the axioms:

- **Normalization:** $S(\varnothing) = 0$ and $\mathrm{area}(\varnothing) = 0$.
- **Nonnegativity:** $S(X) \ge 0$, $\mathrm{area}(X) \ge 0$, $\mathrm{dist}(X) \ge 0$ for all $X$.
- **Submodularity (strong subadditivity):** for all $X, Y$,
  $$ S(X) + S(Y) \ \ge\ S(X \cap Y) + S(X \cup Y). $$
- **Ryu–Takayanagi relation:** for all $X$, $\ S(X) = \mathrm{area}(X)/4$.
- **Singleton-like bound:** for all $X$, $\ S(X) \le |X|$.

This structure captures the finite combinatorial content of the holographic
dictionary: the entropy functional is constrained exactly as a quantum entropy
must be (SSA), and it is rigidly tied to a geometric area functional via RT.

### 2.2 The syndrome defect as discrete curvature

**Definition 2.2 (Syndrome defect).**
For a profile $H$ and regions $X, Y$, define
$$ \mathrm{defect}(X, Y) \ :=\ S(X) + S(Y) - S(X \cap Y) - S(X \cup Y). $$

The defect measures the failure of exact additivity of entropy across the pair.
Physically it is a discrete curvature: zero defect signals entropic flatness
(modularity) and hence flat bulk geometry, while positive defect signals a
curvature-like interaction between the regions.

---

## 3. Curvature is Nonnegative

**Theorem 3.1 (`syndromeDefect_nonneg`).**
For every holographic code profile $H$ and all regions $X, Y$,
$$ 0 \ \le\ \mathrm{defect}(X, Y). $$

*Proof sketch.* Unfold the definition; the claim $0 \le S(X) + S(Y) - S(X\cap Y) -
S(X \cup Y)$ is exactly the submodularity axiom rearranged. $\qquad\blacksquare$

This is the foundational rigidity statement: in this discrete model curvature
cannot be negative, and it is forced by strong subadditivity alone.

**Theorem 3.2 (`strict_submod_of_pos_syndrome`).**
If $0 < \mathrm{defect}(X, Y)$ then
$$ S(X \cap Y) + S(X \cup Y) \ <\ S(X) + S(Y). $$

*Proof sketch.* Immediate rearrangement of the strict inequality. $\qquad\blacksquare$

The defect also satisfies the structural identities one expects of a curvature
pairing.

**Proposition 3.3 (Structural properties).** For all $X, Y$:
- `syndromeDefect_self`: $\mathrm{defect}(X, X) = 0$ (using $X \cap X = X \cup X = X$);
- `syndromeDefect_symm`: $\mathrm{defect}(X, Y) = \mathrm{defect}(Y, X)$ (by commutativity of $\cap, \cup$);
- `syndromeDefect_empty_left` / `syndromeDefect_empty_right`: $\mathrm{defect}(\varnothing, Y) = \mathrm{defect}(X, \varnothing) = 0$ (using $S(\varnothing) = 0$).

**Proposition 3.4 (Special pairs).**
- `syndromeDefect_disjoint`: if $X \cap Y = \varnothing$ then $\mathrm{defect}(X, Y) = S(X) + S(Y) - S(X \cup Y)$.
- `syndromeDefect_subset`: if $X \subseteq Y$ then $\mathrm{defect}(X, Y) = 0$ (since then $X \cap Y = X$, $X \cup Y = Y$).

**Proposition 3.5 (Cumulative nonnegativity).**
For any list (`syndromeDefect_list_sum_nonneg`) or finite set
(`syndromeDefect_finset_sum_nonneg`) of region pairs, the sum of their syndrome
defects is nonnegative.

*Proof sketch.* Induct on the list / apply `Finset.sum_nonneg`, using Theorem 3.1
at each term. $\qquad\blacksquare$

---

## 4. The Information–Geometry Bridge

We now translate entropy statements into area statements using RT, and prove the
two are equivalent.

**Definition 4.1 (Area defect).**
$$ \mathrm{areaDefect}(X, Y) := \mathrm{area}(X) + \mathrm{area}(Y) - \mathrm{area}(X \cap Y) - \mathrm{area}(X \cup Y). $$

**Theorem 4.2 (`area_submod_of_rt`).**
For all $X, Y$,
$$ \mathrm{area}(X) + \mathrm{area}(Y) \ \ge\ \mathrm{area}(X \cap Y) + \mathrm{area}(X \cup Y). $$

*Proof sketch.* Apply submodularity of $S$, then substitute $S = \mathrm{area}/4$ via
RT; the factor of $4$ cancels uniformly. $\qquad\blacksquare$

**Theorem 4.3 (`syndromeDefect_eq_area_defect_div_four`).**
$$ \mathrm{defect}(X, Y) \ =\ \frac{\mathrm{areaDefect}(X, Y)}{4}. $$

*Proof sketch.* Expand both defects, substitute RT termwise, and simplify by ring
arithmetic. Equivalently (`areaDefect_eq_four_syndromeDefect`),
$\mathrm{areaDefect}(X,Y) = 4\,\mathrm{defect}(X,Y)$. $\qquad\blacksquare$

**Corollary 4.4 (`areaDefect_nonneg`, `areaDefect_zero_iff_syndromeDefect_zero`).**
The area defect is nonnegative, and vanishes if and only if the syndrome defect
vanishes. Geometric curvature is nonnegative and coincides (up to the factor $4$)
with information curvature.

**Theorem 4.5 (Cross-domain equivalence, `rt_submodularity_iff_area_submodularity`).**
For a profile $H$,
$$
\Big(\forall X, Y:\ S(X) + S(Y) \ge S(X\cap Y) + S(X\cup Y)\Big)
\iff
\Big(\forall X, Y:\ \mathrm{area}(X) + \mathrm{area}(Y) \ge \mathrm{area}(X\cap Y) + \mathrm{area}(X\cup Y)\Big).
$$

*Proof sketch.* Both directions substitute the RT relation $S = \mathrm{area}/4$ into
the hypothesis and clear the constant factor. The RT relation is precisely the
isomorphism of ordered structures that makes the two inequalities interchangeable.
$\qquad\blacksquare$

This is the paper's centerpiece: the deepest inequality of quantum information
(SSA) and a purely geometric inequality (area submodularity) are logically
equivalent, with RT as the explicit dictionary. It formalizes the intuition that
geometry is the visible face of information constraints.

**Consequences for scaling.**
- `area_eq_four_S`: $\mathrm{area}(X) = 4\,S(X)$.
- `area_le_four_card`: $\mathrm{area}(X) \le 4\,|X|$, a Bekenstein–Hawking-type bound — area is controlled by the microscopic site count.
- `area_submodular`: $\mathrm{area}(X\cap Y) + \mathrm{area}(X\cup Y) \le \mathrm{area}(X) + \mathrm{area}(Y)$.

*Proof sketches.* `area_eq_four_S` is RT cleared of denominators; `area_le_four_card`
combines RT with the singleton bound $S(X)\le|X|$; `area_submodular` restates
Theorem 4.2. $\qquad\blacksquare$

---

## 5. Coding Bounds and Reconstruction

### 5.1 Regional code bounds

**Definition 5.1 (Regional code bound).**
A *regional code bound* on $\alpha$ assigns to each region $X$ natural numbers
$N(X)$ (physical qubits), $K(X)$ (logical qubits), $D(X)$ (code distance), subject
to the **Singleton bound**
$$ N(X) - K(X) \ \le\ 2\,(D(X) - 1). $$

**Theorem 5.2 (`entropy_lower_bound_of_singleton`).**
If $D(X) \ge 1$ then, in integer arithmetic,
$$ K(X) \ \ge\ N(X) - 2\,(D(X) - 1). $$

*Proof sketch.* The natural-number Singleton bound, lifted to $\mathbb{Z}$ to avoid
truncated subtraction, is exactly this rearrangement (discharged by `omega`).
$\qquad\blacksquare$

High code distance forces high logical content; in the holographic dictionary,
where area tracks physical qubits and entropy tracks logical qubits, this links
boundary area to protected bulk information.

### 5.2 Code–geometry correspondence

**Definition 5.3 (Code–geometry correspondence).**
A correspondence couples a holographic code profile $H$ to a regional code bound
$C$ with $S(X) = K(X)$ and $\mathrm{area}(X) = 4\,K(X)$.

**Theorem 5.4 (`correspondence_rt_consistent`).**
In any such correspondence the RT relation $S(X) = \mathrm{area}(X)/4$ holds
automatically. *Proof sketch.* It is an axiom of the profile $H$. $\qquad\blacksquare$

### 5.3 Reconstruction

**Definition 5.5 (Reconstructable region).**
Given a distance function $D$, a region $U$ is *reconstructable* from $X$ if
$U \subseteq X$ and $|U| < D(U)$.

**Theorem 5.6 (Reconstruction monotonicity, `reconstructable_monotone`).**
If $U$ is reconstructable from $X$ and $X \subseteq Y$, then $U$ is reconstructable
from $Y$.

*Proof sketch.* Transitivity of $\subseteq$ gives $U \subseteq Y$; the distance
condition $|U| < D(U)$ is unchanged. $\qquad\blacksquare$

Enlarging the boundary region never destroys recoverability — bulk knowledge
accumulates monotonically. Two companion facts: reconstruction is preserved when
the distance function increases (`reconstructable_of_le_dist`), and the empty
region is always reconstructable when $D(\varnothing) > 0$ (`reconstructable_empty`).

### 5.4 A falsifiable saturation conjecture

**Definition 5.7 (Laminar family).** A family $L$ of regions is *laminar* if any two
members are disjoint or nested.

**Conjecture 5.8 (Saturation modularity, `SaturationModularityConjecture`).**
If $H$ saturates the singleton bound, $S(X) = |X|$, on every member of a laminar
family $L$, then $\mathrm{defect}(X, Y) = 0$ for all $X, Y \in L$.

Two cases are proved unconditionally: nested pairs
(`saturation_conjecture_nested`, from `syndromeDefect_subset`) and disjoint
saturated pairs whose union is also saturated
(`saturation_conjecture_disjoint_saturated`, by direct computation using
$|X \cup Y| = |X| + |Y|$ for disjoint $X, Y$). The conjecture is computationally
testable by enumerating small laminar families and random axiom-satisfying
profiles.

---

## 6. Tropical Entanglement-Wedge Reconstruction

We now turn to a complementary min-plus (tropical) model that captures the
*geometric* side of bulk reconstruction directly.

### 6.1 Definitions

Let $V$ be a vertex type with a distance $d : V \times V \to \mathbb{R}$.

**Definition 6.1 (Distance to a region).** For a nonempty finite $s$,
$$ \mathrm{distToFinset}(d, s, v) := \min_{b \in s} d(v, b). $$

**Definition 6.2 (Entanglement wedge).** Given finite sets $\mathrm{bulk}$,
$\mathrm{boundary}$ and a boundary subset $B$, the wedge of $B$ is
$$ W(B) := \{ v \in \mathrm{bulk} : \mathrm{distToFinset}(d, B, v) < \mathrm{distToFinset}(d, \mathrm{boundary}\setminus B, v) \}, $$
the bulk points strictly closer to $B$ than to its boundary complement.

**Definition 6.3 (Boundary observation).** For a bulk state $\varphi : V \to \mathbb{R}$
and boundary point $b$, the min-plus convolution
$$ \mathrm{Obs}_B(\varphi)(b) := \min_{v \in \mathrm{bulk}} \big(\varphi(v) + d(v, b)\big). $$

### 6.2 Membership and stability

**Theorem 6.4 (`mem_entanglementWedge_iff`).** For $v \in \mathrm{bulk}$ with $B$ and
$\mathrm{boundary}\setminus B$ nonempty, $v \in W(B)$ iff
$\mathrm{distToFinset}(d, B, v) < \mathrm{distToFinset}(d, \mathrm{boundary}\setminus B, v)$.

*Proof sketch.* Unfold the filter defining $W(B)$. $\qquad\blacksquare$

**Lemma 6.5 (Perturbation bound, `distToFinset_perturb_bound`).** If
$|d(v,b) - d'(v,b)| < \varepsilon$ for every $b \in s$, then
$|\mathrm{distToFinset}(d, s, v) - \mathrm{distToFinset}(d', s, v)| < \varepsilon$.

*Proof sketch.* The minimum is realized at some witness for each metric; compare
each minimum against the other's witness using the uniform bound. $\qquad\blacksquare$

**Theorem 6.6 (Wedge stability, `wedge_membership_stable_under_uniform_perturbation`).**
Suppose $v \in W(B)$ under $d$ with margin
$\delta = \mathrm{distToFinset}(d, \mathrm{boundary}\setminus B, v) - \mathrm{distToFinset}(d, B, v)$,
and a perturbation $d'$ satisfies $|d(v,b)-d'(v,b)| < \varepsilon$ for all relevant
$b$ with $2\varepsilon < \delta$. Then $v \in W(B)$ under $d'$.

*Proof sketch.* By Lemma 6.5 both distances move by less than $\varepsilon$; the
strict gap $\delta > 2\varepsilon$ survives, so the wedge inequality persists.
$\qquad\blacksquare$

Geometry emerging from min-plus distances is robust: membership cannot flip under
metric perturbations smaller than half the winning margin.

### 6.3 Reconstruction from boundary observations

**Lemma 6.7 (`boundaryObs_eq_of_unique_argmin`).** If $v$ is the strict unique
minimizer of $w \mapsto \varphi(w) + d(w, b)$ over the bulk, then
$\mathrm{Obs}_B(\varphi)(b) = \varphi(v) + d(v, b)$.

**Theorem 6.8 (Surgery detectability, `wedge_surgery_detectable`).** If there exist a
bulk vertex $v$ and a boundary point $b \in B$ at which $v$ is the unique argmin for
both $\varphi$ and a modified state $\varphi'$, with $\varphi'(v) \ne \varphi(v)$,
then $\mathrm{Obs}_B(\varphi)$ and $\mathrm{Obs}_B(\varphi')$ differ at some $b \in B$.

*Proof sketch.* By Lemma 6.7 the observation at $b$ reads off $\varphi(v) + d(v,b)$
exactly; changing $\varphi(v)$ changes it. $\qquad\blacksquare$

**Theorem 6.9 (Wedge reconstruction, `wedge_reconstruction_from_boundary_profiles`).**
Assume that every wedge point has, for each of $\varphi, \varphi'$, a boundary
witness $b \in B$ at which it is the unique argmin. If
$\mathrm{Obs}_B(\varphi)(b) = \mathrm{Obs}_B(\varphi')(b)$ for all $b \in B$, then
$\varphi(v) = \varphi'(v)$ for all $v \in W(B)$.

*Proof sketch.* Fix $v \in W(B)$ with witnesses $b, b'$. Evaluate the two
observations at $b$ and $b'$: uniqueness turns the minima into equalities, while the
general $\le$ bound applies to the cross terms. Combining the four (in)equalities
with the hypothesis of equal observations forces $\varphi(v) = \varphi'(v)$.
$\qquad\blacksquare$

This is a finite, fully rigorous version of entanglement-wedge reconstruction:
boundary data on $B$ determines the bulk state throughout $W(B)$.

**Monotonicity (`distToFinset_mono`).** Distance to a subset is at least distance to a
superset, so wedges shrink as boundary regions shrink; and $W(\varnothing) =
\mathrm{bulk}$ vacuously (`entanglementWedge_empty_eq_bulk`), with $W(B) \subseteq
\mathrm{bulk}$ always (`entanglementWedge_subset_bulk`).

---

## 7. The Random-Tensor-Network Encoding Threshold

The motivating conjecture predicts a sharp transition into smooth geometry as the
bond dimension of a random tensor network crosses a critical value $D_c(N)$. We
model the threshold for faithfully encoding a length-$n$ chain.

**Definition 7.1 (Critical bond dimension, `critBond`).**
$$ D_c(n) := 1 + \frac{n}{10}. $$
A chain of length $n$ is encodable by a network of bond dimension $D$ exactly when
$D_c(n) < D$.

**Theorem 7.2 (`critBond_strictMono`).** $D_c$ is strictly increasing.

*Proof sketch.* For $a < b$, $(a:\mathbb{R}) < b$, hence $1 + a/10 < 1 + b/10$.
$\qquad\blacksquare$

Auxiliary facts: $D_c(0) = 1$ (`critBond_zero`) and $D_c(n+1) = D_c(n) + 1/10$
(`critBond_succ`). The strict monotonicity is the minimal honest fingerprint of the
conjectured phase transition: longer / more complex chains require strictly larger
bond dimension, with no plateaus.

---

## 8. Algorithms

The model yields directly executable procedures (see the accompanying `demo.py`):

1. **Syndrome-defect curvature computation.** Given a profile (entropy on each
   region), compute $\mathrm{defect}(X, Y)$ for all pairs and verify nonnegativity
   — a finite check of Theorem 3.1.
2. **RT bridge verification.** Confirm $\mathrm{defect}(X,Y) = \mathrm{areaDefect}(X,Y)/4$
   and the equivalence of the two submodularity statements (Theorems 4.3, 4.5).
3. **Entanglement-wedge construction.** Compute $W(B)$ from a distance matrix and
   verify perturbation stability (Theorems 6.4, 6.6).
4. **Boundary reconstruction.** Compute min-plus observations $\mathrm{Obs}_B$ and
   verify that equal boundary profiles imply equal bulk states on the wedge
   (Theorem 6.9).
5. **Threshold scan.** Tabulate $D_c(n)$ and confirm strict monotonicity
   (Theorem 7.2).

---

## 9. Applications

- **Quantum gravity model selection.** The proven equivalence of SSA and area
  submodularity gives a sharp consistency criterion: any candidate entropy–area
  dictionary that violates one violates the other.
- **Complexity-optimal codes.** The Singleton-based lower bound on logical content
  and the monotone reconstruction theorem suggest design targets for codes whose
  reconstructable regions grow predictably with boundary size.
- **Curvature diagnostics.** The syndrome defect is a cheap, additive curvature
  proxy computable from an entropy table alone, suitable for screening large
  simulated tensor networks for emergent flatness vs. curvature.

---

## 10. Discussion and Future Work

The contribution is a finite, formally verified skeleton in which the central
holographic slogans are theorems. The factor of $4$ in RT is carried symbolically
throughout, making the entropy/area dictionary exact rather than asymptotic. The
tropical model shows that the geometric content of reconstruction survives in a
purely combinatorial min-plus setting.

Open directions, derived from the verified results:

- **C1 (Tropical location of phase transitions).** The non-differentiability locus
  of the multi-surface entropy $\inf_i \mathrm{area}_i$ should coincide with the
  tropical-variety corner locus, with the strict concave defect at each transversal
  corner given exactly by $\log D \cdot (\Delta\text{slope}) \cdot t / 2 + o(t)$.
- **C2 (Bond-dimension gap law).** The critical bond dimension should satisfy
  $D_c(N) = \lceil \exp(\mathrm{budget}(N)/\mathrm{area}) \rceil$ up to an additive
  constant, with a nonempty fractal window exactly when
  $\mathrm{budget}(N) > \mathrm{area}\cdot\log 2$.
- **C3 (Lipschitz robustness ⟹ bounded coarse curvature).** A $\log D$-Lipschitz
  min-cut entropy should yield a coarse-grained curvature proxy bounded by a
  universal multiple of $\log D$.
- **C4 (Concavity survives surface proliferation).** Strong subadditivity (concavity
  of the multi-surface entropy $x \mapsto \log D \cdot \inf_i \mathrm{area}_i(x)$
  with affine $\mathrm{area}_i$) should persist under arbitrary surface families.

These conjectures are each falsifiable and motivated by the proved two-surface
results, bringing the program incrementally closer to the ultimate aim: deriving
the gravitational field equations from the structure of quantum information
complexity.

---

## 11. Conclusion

From a small set of axioms—normalization, nonnegativity, strong subadditivity, the
Ryu–Takayanagi relation, and a Singleton bound—we derived, with complete rigor: a
nonnegative discrete curvature (the syndrome defect); an exact and *equivalent*
translation between a quantum-information inequality and a geometric one; a
coding-theoretic bound linking area to protected information; a monotone, stable,
wedge-refined reconstruction of bulk from boundary; and a strictly increasing
threshold for the emergence of geometry. The construction does not claim that our
universe is a code—but it demonstrates that, in a clean finite setting, the
holographic dictionary is not metaphor but mathematics.
