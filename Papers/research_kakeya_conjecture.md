# Verified Incidence Bounds for Discrete Kakeya Configurations: A Formal Bridge to Additive Combinatorics

## Abstract

We present a formally verified development in Lean 4 establishing the foundational incidence-theoretic inequalities underlying discrete Kakeya theory. Our contributions include: (1) a formal definition of *discrete Kakeya configurations* capturing finite line families with prescribed carrier sets; (2) a machine-checked proof of the *Cauchy–Schwarz energy inequality* showing that $(|D| \cdot L)^2 \leq |\text{carrier}| \cdot E_K$ where $E_K$ is the sum of squared point multiplicities; (3) a verified *pairwise intersection bound* proving that bounded line crossings force carrier growth; and (4) a formal bridge to additive combinatorics via arithmetic-progression configurations. All proofs are fully verified with no axioms beyond the standard Lean foundations. Computational experiments for finite fields $\mathbb{F}_p^2$ with $p \leq 7$ reveal that carrier-minimizing configurations are *not* star-like (maximal concurrency) but rather achieve minimum carrier size $p(p+1)/2$ via maximally dispersed intersection patterns. This refutes a natural extremizer conjecture and opens new questions about the structure of optimal Kakeya compression.

## 1. Introduction

### 1.1 The Kakeya Problem

The Kakeya conjecture, one of the central open problems in geometric measure theory and harmonic analysis, asserts that every Besicovitch set in $\mathbb{R}^n$ — a set containing a unit line segment in every direction — must have Hausdorff dimension $n$. Despite major progress via the polynomial method (Dvir, 2009, for finite fields) and decoupling theory (Bourgain–Demeter, 2015), the conjecture remains open in dimensions $n \geq 3$.

### 1.2 The Discrete Framework

The finite/combinatorial approach to Kakeya replaces continuous sets with discrete configurations: a finite set of "points" carrying a family of "lines" indexed by "directions." The key statistics are:
- **Carrier size**: how many points are needed to support all lines.
- **Point multiplicity**: how many lines pass through each point.
- **Kakeya energy**: the sum of squared multiplicities, measuring overlap concentration.
- **Pairwise intersection parameter $T$**: the maximum number of points shared by two lines in distinct directions.

The fundamental principle of Kakeya theory is that many lines in many directions cannot all fit in a small carrier without forcing highly structured overlaps.

### 1.3 Contributions

Our work makes four main contributions:

1. **Formal definitions** (§2): We introduce `DiscreteKakeyaConfig`, a Lean 4 structure capturing the essential data of a discrete line family, together with `pointMultiplicity` and `kakeyaEnergy`.

2. **Cauchy–Schwarz energy inequality** (§3): We prove that if every line has $L$ points, then
   $$(|D| \cdot L)^2 \leq |\text{carrier}| \cdot E_K$$
   This is the fundamental gateway from incidence counting to carrier-size lower bounds.

3. **Pairwise intersection bounds** (§4): We prove that if any two distinct-direction lines share at most $T$ points, then
   $$E_K \leq |D| \cdot L + |D| \cdot (|D| - 1) \cdot T$$
   Combining with the Cauchy–Schwarz bound gives the *discrete Kakeya expansion theorem*:
   $$(|D| \cdot L)^2 \leq |\text{carrier}| \cdot (|D| \cdot L + |D| \cdot (|D| - 1) \cdot T)$$

4. **Additive combinatorics bridge** (§5): We construct `DiscreteKakeyaConfig` instances from families of arithmetic progressions in finite additive groups, proving that the energy inequality transfers to additive-combinatorial bounds.

5. **Computational experiments** (§6): Exhaustive search over $\mathbb{F}_p^2$ for small primes reveals unexpected extremizer structure.

## 2. Definitions and Notation

### 2.1 Discrete Kakeya Configuration

A **discrete Kakeya configuration** $K$ consists of:
- Finite types $\text{Point}$ and $\text{Dir}$ (with decidable equality).
- A function $\text{line} : \text{Dir} \to \text{Finset}(\text{Point})$.
- A carrier $\text{carrier} : \text{Finset}(\text{Point})$.
- Axioms: $\text{line}(d) \subseteq \text{carrier}$ for all $d$, and $\text{line}(d) \neq \emptyset$ for all $d$.

In Lean 4:
```lean
structure DiscreteKakeyaConfig where
  Point : Type*
  Dir : Type*
  [instPointFintype : Fintype Point]
  [instPointDecidableEq : DecidableEq Point]
  [instDirFintype : Fintype Dir]
  [instDirDecidableEq : DecidableEq Dir]
  line : Dir → Finset Point
  carrier : Finset Point
  line_subset_carrier : ∀ d, line d ⊆ carrier
  nonempty_line : ∀ d, (line d).Nonempty
```

### 2.2 Point Multiplicity and Energy

The **point multiplicity** of $p \in \text{carrier}$ is
$$\mu(p) = |\{d \in \text{Dir} : p \in \text{line}(d)\}|$$

The **Kakeya energy** is
$$E_K = \sum_{p \in \text{carrier}} \mu(p)^2$$

### 2.3 Euclidean Besicovitch Sets

For context and completeness, we also formalize:
$$\text{ContainsUnitSegmentInDirection}(E, v) \iff \exists x, \forall t \in [0,1], \; x + tv \in E$$
$$\text{IsBesicovitchSet}(E) \iff \forall v \text{ with } \|v\| = 1, \; \text{ContainsUnitSegmentInDirection}(E, v)$$

These definitions serve as formal anchors for future work connecting discrete bounds to Euclidean geometry.

## 3. Core Theorem 1: Cauchy–Schwarz Energy Inequality

### 3.1 The Double-Counting Identity

**Theorem (total_multiplicity_eq_sum_card_lines).** For any discrete Kakeya configuration $K$,
$$\sum_{p \in \text{carrier}} \mu(p) = \sum_{d \in \text{Dir}} |\text{line}(d)|$$

*Proof sketch.* Both sides count the number of incidence pairs $(p, d)$ with $p \in \text{line}(d)$. The left side groups by point; the right side groups by direction. The formal proof swaps the order of a double sum and uses the fact that $\text{line}(d) \subseteq \text{carrier}$ to simplify indicator sums.

### 3.2 The Main Inequality

**Theorem (sq_total_line_mass_le_card_mul_energy).** If every line has exactly $L$ points, then
$$(|D| \cdot L)^2 \leq |\text{carrier}| \cdot E_K$$

*Proof sketch.*
1. By the double-counting identity and the hypothesis $|\text{line}(d)| = L$:
$$\sum_{p \in \text{carrier}} \mu(p) = |D| \cdot L$$

2. By the Cauchy–Schwarz inequality for finite sums (Finset version):
$$\left(\sum_{p \in S} f(p)\right)^2 \leq |S| \cdot \sum_{p \in S} f(p)^2$$

3. Applying with $f = \mu$ and $S = \text{carrier}$ gives the result.

The formal proof casts to $\mathbb{R}$ to apply the standard Cauchy–Schwarz lemma `sq_sum_le_card_mul_sum_sq` from Mathlib, then transfers back to $\mathbb{N}$.

### 3.3 Interpretation

This theorem says: **if every direction contributes a line of $L$ points, then the carrier must have at least $(|D| \cdot L)^2 / E_K$ points.** When energy is small (overlaps are diffuse), the carrier must be large. This is the combinatorial skeleton of all Kakeya-type lower bounds.

## 4. Core Theorem 2: Pairwise Intersection Bounds

### 4.1 Energy from Pairwise Intersections

**Theorem (energy_le_of_pairwise_intersection_bound).** If each line has $L$ points and any two distinct-direction lines share at most $T$ points, then
$$E_K \leq |D| \cdot L + |D| \cdot (|D| - 1) \cdot T$$

*Proof sketch.* Expand the energy:
$$E_K = \sum_{p \in \text{carrier}} \mu(p)^2 = \sum_{d_1, d_2 \in \text{Dir}} |\text{line}(d_1) \cap \text{line}(d_2)|$$

The key identity is obtained by swapping the order of summation: each squared multiplicity $\mu(p)^2$ counts ordered pairs $(d_1, d_2)$ with $p$ in both lines.

Split into diagonal ($d_1 = d_2$) and off-diagonal ($d_1 \neq d_2$):
- Diagonal: $\sum_d |\text{line}(d)| = |D| \cdot L$.
- Off-diagonal: at most $|D| \cdot (|D| - 1)$ pairs, each contributing $\leq T$.

### 4.2 The Expansion Theorem

**Theorem (card_lower_bound_of_pairwise_intersection_bound).** Under the same hypotheses:
$$(|D| \cdot L)^2 \leq |\text{carrier}| \cdot (|D| \cdot L + |D| \cdot (|D| - 1) \cdot T)$$

*Proof.* Immediate from combining Theorems 3.2 and 4.1: substitute the energy upper bound into the Cauchy–Schwarz inequality.

### 4.3 Corollary: Carrier Growth

When $T = 1$ (generic intersection), the bound gives:
$$|\text{carrier}| \geq \frac{|D| \cdot L^2}{L + |D| - 1}$$

For $|D| \approx L$ (as in finite-field Kakeya), this gives $|\text{carrier}| \gtrsim |D| \cdot L / 2$, exhibiting genuine quadratic growth. This captures the philosophical core of the Kakeya problem in the discrete setting.

## 5. Core Theorem 3: Bridge to Additive Combinatorics

### 5.1 Arithmetic Progression Configurations

Given a finite additive group $G$, a finite set $A \subseteq G$, a direction set $V \subseteq G$, and for each direction $v \in V$ an arithmetic progression $\{x_v + kv : k = 0, \ldots, m-1\} \subseteq A$, we construct a `DiscreteKakeyaConfig` with:
- $\text{Dir} = V$ (as a subtype of $G$).
- $\text{line}(v) = \{p \in A : \exists k < m, \; p = x_v + kv\}$.
- $\text{carrier} = A$.

### 5.2 The AP Energy Inequality

**Theorem (ap_sq_mass_le_card_mul_energy).** Under the above construction, if each AP contributes exactly $m$ distinct elements, then:
$$(|V| \cdot m)^2 \leq |A| \cdot E_K$$

*Proof.* Direct application of `sq_total_line_mass_le_card_mul_energy` to the AP configuration.

### 5.3 Significance

This theorem formalizes the meta-principle: **compressing many directional arithmetic progressions into a small set forces high overlap energy.** It connects:
- **Kakeya-type geometry** (many directions, small carrier) to
- **Additive structure** (high energy = additive quadruples).

This is the formal gateway to the Balog–Szemerédi–Gowers theorem and the sum-product phenomenon.

## 6. Computational Experiments

### 6.1 Setup

We implemented exhaustive search over all one-line-per-slope families in $\mathbb{F}_p^2$ for primes $p = 3, 5, 7$. For each of the $p^p$ choices of intercepts $(b_0, \ldots, b_{p-1})$, we computed:
- Carrier size $|A|$.
- Kakeya energy $E_K$.
- Maximum pairwise intersection $T$.
- Whether the configuration is "star-like" (has a point of multiplicity $p$).

### 6.2 Results

| $p$ | Min carrier | $p(p+1)/2$ | # Minimizers | All star-like? |
|-----|-------------|-------------|--------------|----------------|
| 3   | 6           | 6           | 18           | No             |
| 5   | 15          | 15          | 100          | No             |
| 7   | 28          | 28          | 294          | No             |

**Key finding:** The minimum carrier size is exactly $p(p+1)/2$, achieved by configurations where all $\binom{p}{2}$ pairwise line intersections are at distinct points. Star-like configurations (maximum concurrency) give strictly larger carriers of size $p^2 - p + 1$.

### 6.3 Extremizer Characterization

Every minimizing configuration satisfies:
1. All $\binom{p}{2}$ pairwise intersection points are distinct.
2. The carrier is exactly the union of $p$ lines minus $\binom{p}{2}$ overlaps: $p \cdot p - \binom{p}{2} = p(p+1)/2$.
3. No point has multiplicity greater than 2 (for $p \geq 3$).

This suggests that optimal Kakeya compression in $\mathbb{F}_p^2$ is achieved by *maximally dispersed* intersection patterns, not by concentrating intersections.

### 6.4 Bound Verification

For all tested configurations:
- The Cauchy–Schwarz bound $|\text{carrier}| \geq (|D| \cdot L)^2 / E_K$ is always satisfied.
- The pairwise bound $|\text{carrier}| \geq (|D| \cdot L)^2 / (|D| \cdot L + |D|(|D|-1) \cdot T)$ is always satisfied.
- The bounds are typically not tight: there is room for improvement via higher-moment methods.

## 7. Discussion

### 7.1 Relationship to the Full Kakeya Conjecture

The discrete bounds we prove are the finite-combinatorial skeletons of the continuous Kakeya problem. The missing bridge is a *discretization theorem*: showing that a Euclidean Besicovitch set, when sampled at scale $\delta$, produces a discrete configuration satisfying the hypotheses of our theorems with controlled parameters.

Such a discretization would immediately yield Hausdorff dimension lower bounds from our carrier-size inequalities. Specifically:
- If $T(\delta) \leq C\delta^{-\alpha}$, the pairwise bound gives $\dim_H(E) \geq n - \alpha$.
- The trivial bound $T \leq \delta^{-(n-1)}$ gives $\dim_H(E) \geq 1$, which is the known lower bound.

### 7.2 Connections to Additive Combinatorics

Our AP bridge theorem is the first step toward formally connecting:
- Kakeya compression → high overlap energy → additive structure.
- In reverse: sum-product bounds → energy control → Kakeya lower bounds.

The key missing piece is a formal Balog–Szemerédi–Gowers theorem, which converts high additive energy into structured subsets amenable to sum-product analysis.

### 7.3 Limitations

1. Our results apply to discrete configurations with constant line size $L$. Variable line sizes require weighted versions of the Cauchy–Schwarz bound.
2. The bounds are first-moment (Cauchy–Schwarz) bounds. Higher-moment or polynomial-method bounds would be stronger.
3. We do not yet formalize the discretization step from Euclidean to finite geometry.

## 8. Future Work

1. **Formal discretization theorem**: Connect Euclidean Besicovitch sets to discrete configurations via $\delta$-tubes and scale parameters.
2. **Polynomial method bounds**: Formalize Dvir's finite-field Kakeya theorem using the polynomial method, giving the sharp lower bound $\binom{q+n-1}{n}$.
3. **Higher-moment bounds**: Prove energy bounds using 4th moments (Wolff's hairbrush argument) instead of 2nd moments.
4. **Formal Balog–Szemerédi–Gowers**: Establish the bridge from additive energy to structured subsets, completing the additive combinatorics connection.
5. **Restriction estimates**: Formalize the heuristic that restriction estimates imply Kakeya bounds via the formal energy framework.

## 9. References

1. Dvir, Z. (2009). On the size of Kakeya sets in finite fields. *J. Amer. Math. Soc.*, 22(4), 1093–1097.
2. Wolff, T. (1999). Recent work connected with the Kakeya problem. In *Prospects in Mathematics*, AMS.
3. Bourgain, J. (1991). Besicovitch type maximal operators and applications to Fourier analysis. *Geom. Funct. Anal.*, 1, 147–187.
4. Tao, T. (2001). From rotating needles to stability of waves: emerging connections between combinatorics, analysis, and PDE. *Notices AMS*, 48(3), 294–303.
5. Guth, L. (2016). Polynomial partitioning for a set of varieties. *Math. Proc. Cambridge Philos. Soc.*, 159(3), 459–469.
6. Bourgain, J., & Demeter, C. (2015). The proof of the $l^2$ decoupling conjecture. *Ann. of Math.*, 182(1), 351–389.
7. Katz, N., & Tao, T. (2002). New bounds for Kakeya problems. *J. Anal. Math.*, 87, 231–263.
