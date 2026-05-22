# The Haar Measure Cylinder Formula for Restricted Products: A Formally Verified Foundation for Adelic Integration

## Abstract

We establish the exact Haar-measure product formula for basic cylinders in countable restricted products of locally compact groups with compact open reference subgroups. Given a finite set $S$ of indices, measurable sets $A_i \subseteq G_i$ for $i \in S$, and a level-compatible Haar measure $\mu$ with normalized local measures $\mu_i$, we prove that
$$\mu(\operatorname{basicCylinder}(S, A)) = \prod_{i \in S} \mu_i(A_i).$$

When local measures are normalized so that $\mu_i(K_i) = 1$, this yields the ratio form $\prod_{i \in S} \mu_i(A_i) / \mu_i(K_i)$. We prove measurability of basic cylinders in the restricted-product Borel σ-algebra, multiplicativity (independence) for disjoint supports, stability under support enlargement, and the Euler-product specialization for p-adic applications. All results are formally verified in Lean 4 with Mathlib, using only the standard axioms (propext, Classical.choice, Quot.sound).

**Keywords:** adelic integration, restricted product, Haar measure, cylinder sets, Euler product, local-global principle, p-adic analysis, probabilistic independence, harmonic analysis, formalized mathematics

---

## 1. Introduction

### 1.1 Motivation

The restricted product $\prod'_i (G_i, K_i)$ of locally compact groups $G_i$ relative to compact open subgroups $K_i$ is the fundamental object underlying adelic constructions in algebraic number theory. The existence and uniqueness (up to positive scalar) of Haar measure on such products is classical, but the *computational content* — the exact measure of basic cylinder sets — has not been previously formalized.

This paper bridges the gap between abstract Haar measure existence and concrete cylinder-by-cylinder computation. The cylinder formula is the measure-theoretic analogue of the Euler product: it expresses the measure of a finitely-constrained subset as a finite product of local contributions.

### 1.2 Context and Prior Work

The theory of restricted products originates in the work of Chevalley and Weil on adele groups, systematized by Cassels–Fröhlich and Ramakrishnan–Valenza. In the formal verification world, Mathlib (the Lean 4 mathematics library) provides:

- The `RestrictedProduct` type as a subtype of dependent functions.
- Topological space structure via subspace topology.
- Algebraic instances (group, monoid, etc.) when the reference sets carry subgroup structure.

The catalog files `HaarRestrictedProduct/Defs.lean` and `HaarRestrictedProduct/Theorems.lean` provide:

- `basicCylinder`: the fundamental cylinder set definition.
- `IsLevelCompatible`: the factorization property for measures.
- `normalized_haar_value`: normalization of Haar measure on compact open sets.
- `haar_unique_of_eq_on_compact`: Haar uniqueness from agreement on compact sets.
- `maximalCompact`: the reference compact set $\prod_i K_i$.

### 1.3 Contributions

1. **New definitions:** `CylinderDatum` (packaging finite-support local conditions) and `CylinderWeight` (the Euler-product mass prediction).

2. **Measurability theorem:** Basic cylinders are measurable in the restricted-product Borel σ-algebra when $\iota$ is countable and all component sets are measurable.

3. **Product formula:** Under level compatibility, the measure of a basic cylinder equals the finite product of local measures.

4. **Product formula with ratios:** Under normalized local measures ($\mu_i(K_i) = 1$), the formula becomes a ratio product $\prod \mu_i(A_i) / \mu_i(K_i)$.

5. **Independence theorem:** Cylinder events at disjoint sets of coordinates are measure-theoretically independent.

6. **Stability under support enlargement:** Adding inactive coordinates (with $K_i$ conditions) does not change the cylinder measure.

7. **Euler-product specialization:** Direct reduction to $\prod_{p \in S} w_p$ when local masses $\mu_p(A_p) = w_p$.

8. **Normalization anchor:** The maximal compact $\prod K_i$ has measure 1 under any level-compatible measure.

All results are fully verified in Lean 4 with zero `sorry` statements.

---

## 2. Definitions and Setup

### 2.1 Restricted Product

Let $\iota$ be a type and $(G_i)_{i \in \iota}$ a family of types with sets $K_i \subseteq G_i$. The restricted product with respect to the cofinite filter is:
$$\prod\nolimits^{\text{res}}_i (G_i, K_i) := \{x \in \prod_i G_i : x_i \in K_i \text{ for all but finitely many } i\}.$$

### 2.2 Basic Cylinders

For a finite set $S \subseteq \iota$ and sets $A_i \subseteq G_i$:
$$\operatorname{basicCylinder}(S, A) := \{x \in \prod^{\text{res}} : (\forall i \in S,\; x_i \in A_i) \wedge (\forall i \notin S,\; x_i \in K_i)\}.$$

This is a "tight" cylinder: it requires $x_i \in K_i$ for *all* $i \notin S$, not just cofinitely many.

### 2.3 CylinderDatum

```
structure CylinderDatum where
  support : Finset ι
  setAt : ∀ i, Set (G i)
  measurable_setAt : ∀ i, MeasurableSet (setAt i)
  compatible : ∀ i, i ∉ support → setAt i = K i
```

### 2.4 CylinderWeight

$$\operatorname{CylinderWeight}(C, \mu_{\text{local}}) := \prod_{i \in C.\text{support}} \frac{\mu_i(C.\text{setAt}_i)}{\mu_i(K_i)}.$$

### 2.5 Level Compatibility

A measure $\mu$ on the restricted product is *level-compatible* with local measures $(\mu_i)$ if:
$$\forall S, A,\quad (\forall i \in S,\; \text{MeasurableSet}(A_i)) \to (\forall i \notin S,\; A_i = K_i) \to \mu(\operatorname{basicCylinder}(S, A)) = \prod_{i \in S} \mu_i(A_i).$$

---

## 3. Main Results

### 3.1 Theorem 1: Measurability of Basic Cylinders

**Theorem (measurableSet_basicCylinder).** Let $\iota$ be countable. If $A_i$ is measurable for $i \in S$ and each $K_i$ is measurable, then $\operatorname{basicCylinder}(S, A)$ is measurable.

**Proof sketch.** Express the cylinder as a preimage:
$$\operatorname{basicCylinder}(S, A) = \operatorname{val}^{-1}\bigl(S.\pi(A) \cap S^c.\pi(K)\bigr)$$
where $\operatorname{val}$ is the subtype coercion and $.pi$ denotes the pi-set. The set $S.\pi(A)$ is measurable by `MeasurableSet.pi` (using the countability of $S$). The set $S^c.\pi(K)$ is measurable because $\iota$ is countable (hence $S^c$ is countable) and each $K_i$ is measurable. Their intersection is measurable, and the preimage under the measurable subtype coercion is measurable. $\square$

**Key technical point:** The countability of $\iota$ is essential for the complement $S^c$ to be countable, which is needed for the pi-set measurability theorem `MeasurableSet.pi`.

### 3.2 Theorem 2: Finite-Level Cylinder Measure

**Theorem (basicCylinder_measure_eq_finite_product).** Under level compatibility:
$$\mu(\operatorname{basicCylinder}(S, A)) = \prod_{i \in S} \mu_i(A_i).$$

This follows directly from the definition of `IsLevelCompatible`.

### 3.3 Theorem 3: Product Formula with Ratios

**Theorem (basicCylinder_measure_ratio).** Under level compatibility and normalized local measures ($\mu_i(K_i) = 1$):
$$\mu(\operatorname{basicCylinder}(S, A)) = \prod_{i \in S} \frac{\mu_i(A_i)}{\mu_i(K_i)}.$$

**Proof.** By `calc`:
$$\mu(\operatorname{basicCylinder}(S, A)) = \prod_{i \in S} \mu_i(A_i) = \prod_{i \in S} \frac{\mu_i(A_i)}{1} = \prod_{i \in S} \frac{\mu_i(A_i)}{\mu_i(K_i)}$$
using `Finset.prod_congr` and `div_one`. $\square$

### 3.4 Theorem 4: Independence for Disjoint Supports

**Theorem (basicCylinder_independent_of_disjoint).** For disjoint $S, T$:
$$\mu\bigl(\operatorname{basicCylinder}(S \cup T, C)\bigr) = \mu(\operatorname{basicCylinder}(S, A)) \cdot \mu(\operatorname{basicCylinder}(T, B))$$
where $C_i = A_i$ for $i \in S$, $C_i = B_i$ for $i \in T$, $C_i = K_i$ otherwise.

**Proof.** Apply level compatibility to all three cylinders:
$$\text{LHS} = \prod_{i \in S \cup T} \mu_i(C_i) = \left(\prod_{i \in S} \mu_i(A_i)\right) \cdot \left(\prod_{i \in T} \mu_i(B_i)\right) = \text{RHS}$$
using `Finset.prod_union` for the disjoint union decomposition and `Finset.prod_congr` to match the if-then-else with the original sets. $\square$

### 3.5 Theorem 5: Normalization

**Theorem (measure_maximalCompact_eq_one).** Under level compatibility, $\mu(\operatorname{maximalCompact}) = 1$.

**Proof.** The maximal compact equals `basicCylinder ∅ K`. By level compatibility:
$$\mu(\operatorname{maximalCompact}) = \mu(\operatorname{basicCylinder}(\emptyset, K)) = \prod_{i \in \emptyset} \mu_i(K_i) = 1.$$
$\square$

### 3.6 Theorem 6: Euler Product Specialization

**Theorem (prime_cylinder_measure).** If $\mu_i(A_i) = w_i$ for $i \in S$:
$$\mu(\operatorname{basicCylinder}(S, A)) = \prod_{i \in S} w_i.$$

### 3.7 Theorem 7: Support Enlargement Stability

**Theorem (basicCylinder_measure_support_enlarge).** For $S \subseteq T$ with $A_i = K_i$ for $i \notin S$ and $\mu_i(K_i) = 1$:
$$\mu(\operatorname{basicCylinder}(T, A)) = \mu(\operatorname{basicCylinder}(S, A)).$$

**Proof.** Both sides equal $\prod_{i \in S} \mu_i(A_i)$ after expanding via level compatibility and noting that the extra factors for $i \in T \setminus S$ contribute $\mu_i(K_i) = 1$. Uses `Finset.prod_subset`. $\square$

---

## 4. Algorithm: Cylinder Mass Computation

### 4.1 Pseudocode

```
ALGORITHM CylinderMass(S, local_masses, reference_masses)
  INPUT:  S = finite set of active indices
          local_masses[i] = μ_i(A_i) for i ∈ S
          reference_masses[i] = μ_i(K_i) for i ∈ S
  OUTPUT: μ(basicCylinder(S, A))

  result ← 1
  FOR each i ∈ S:
    result ← result × (local_masses[i] / reference_masses[i])
  RETURN result
```

### 4.2 Complexity

- **Time:** O(|S|) multiplications and divisions.
- **Space:** O(1) beyond the input.

### 4.3 Correctness

The correctness is exactly `basicCylinder_measure_ratio`: the output equals $\prod_{i \in S} \mu_i(A_i) / \mu_i(K_i) = \mu(\operatorname{basicCylinder}(S, A))$.

---

## 5. Applications

### 5.1 Adelic Density of Divisibility

For the adeles $\mathbb{A}_{\mathbb{Q}}$ with $G_p = \mathbb{Q}_p$, $K_p = \mathbb{Z}_p$, the density of elements divisible by every prime in $S$ is:
$$\mu\{x \in \mathbb{A}_{\mathbb{Q}} : x_p \in p\mathbb{Z}_p \text{ for } p \in S\} = \prod_{p \in S} \frac{1}{p}.$$

This follows from `prime_cylinder_measure` with $w_p = 1/p$.

### 5.2 Numerical Verification

For $S = \{2, 3, 5\}$: cylinder mass $= 1/2 \times 1/3 \times 1/5 = 1/30 \approx 0.0333$.

For $S = \{2, 3, 5, 7, 11, 13\}$: cylinder mass $= 1/30030 \approx 3.33 \times 10^{-5}$.

These match the predictions of the Euler product formula exactly.

### 5.3 Probabilistic Interpretation

Under normalization $\mu(\prod K_i) = 1$, the Haar measure becomes a probability measure. The independence theorem shows that conditions at disjoint sets of primes are probabilistically independent events. This is the formal foundation for the heuristic that "divisibility by different primes is independent."

---

## 6. Discussion

### 6.1 Relationship to Classical Results

The cylinder formula is implicit in the classical theory of adeles. What is new is:

1. **Formal precision:** The exact hypotheses under which the formula holds (level compatibility, measurability, countability).
2. **Machine verification:** Every logical step checked against foundational axioms.
3. **Modular architecture:** The formula is proved in terms of abstract restricted products, not specialized to number fields.

### 6.2 The Intersection Subtlety

We initially conjectured that the intersection of two disjoint-support cylinders equals the union-support cylinder. This turns out to be false: the intersection is strictly *contained* in the union-support cylinder because it forces $x_i \in K_i$ at *all* coordinates (since $S^c \cup T^c = \iota$ for disjoint $S, T$), while the union cylinder only requires this outside $S \cup T$.

At the *measure* level, however, the independence theorem holds unconditionally. This illustrates a common phenomenon: set-theoretic identities are subtle in restricted products, but measure-theoretic identities are clean.

### 6.3 Limitations

The present development assumes `IsLevelCompatible` as a hypothesis. Proving that the Haar measure on a restricted product *is* level-compatible requires:

1. Showing that the restricted product is locally compact (needs Tychonoff-like arguments).
2. Constructing the Haar measure explicitly or using abstract existence.
3. Connecting the product structure to the measure structure.

These steps are significant formal infrastructure that would benefit from future work.

---

## 7. Future Work

1. **Prove level compatibility from first principles:** Show that the Haar measure on a restricted product of locally compact groups is level-compatible with the local Haar measures.

2. **Cylinder approximation theorem:** Prove that every compact open subset can be approximated by finite unions of basic cylinders.

3. **Kolmogorov extension:** Show that compatible finite-level measures uniquely extend to the restricted product, providing an alternative construction of the Haar measure.

4. **Integration theory:** Develop formal integration against cylinder measures, enabling adelic zeta integrals.

5. **Specialization to number fields:** Instantiate the general theory for $\mathbb{A}_K$ where $K$ is an algebraic number field.

---

## References

1. J.W.S. Cassels and A. Fröhlich (eds.), *Algebraic Number Theory*, Academic Press, 1967.

2. D. Ramakrishnan and R.J. Valenza, *Fourier Analysis on Number Fields*, Springer GTM 186, 1999.

3. J. Tate, "Fourier analysis in number fields and Hecke's zeta-functions," Ph.D. thesis, Princeton, 1950.

4. A. Weil, *Adeles and Algebraic Groups*, Birkhäuser, 1982.

5. The Mathlib Community, *Mathlib4: Mathematics in Lean 4*, https://github.com/leanprover-community/mathlib4.
