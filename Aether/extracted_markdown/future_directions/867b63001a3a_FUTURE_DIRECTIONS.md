# Future Directions: Symmetry-Energy Calculus

## Breakthrough Opportunities (ranked by impact)

### 1. Cauchy–Schwarz Energy-Spectrum Inequality

**Theorem Statement**: For any `f : α → G` on a finite type into an additive group,
```
(Fintype.card α)⁴ ≤ additiveEnergyGroup f * (differenceSpectrum f).card
```
This is the discrete Cauchy–Schwarz inequality for additive energy: the energy is at least `n⁴ / |Δ(f)|` where `|Δ(f)|` is the size of the difference spectrum.

**Proof Strategy**:
1. Decompose the energy as `E(f) = Σ_d r(d)²` where `r(d)` counts pairs `(a,b)` with `f(a) - f(b) = d`.
2. Apply Cauchy–Schwarz to `(Σ r(d))² ≤ |Δ(f)| · Σ r(d)²`, noting `Σ r(d) = n²`.
3. Key lemmas: fiber decomposition of the product space, Finset.sum_sq_le_card_mul_sq_sum.

**Why This Is Revolutionary**: This connects the additive energy to the spectral width of a function, providing the core inequality in additive combinatorics that underlies the Balog–Szemerédi–Gowers theorem. Formalizing this in Lean would be a significant milestone.

**Catalog Leverage**: Build on `additiveEnergyGroup`, `differenceSpectrum`, `additive_energy_ge_card_sq`.

**Research Mode**: prove | **Estimated Depth**: 4

---

### 2. Quotient-Level Orbit Separation Equivalence

**Theorem Statement**: For a finite group `G` acting on a finite type `α`, an observation `obs : α → β` separates orbits if and only if the induced map on the quotient `α / G → β` is injective (when orbits are well-defined).

```lean
theorem orbit_separation_iff_quotient_injective
    {G α β : Type*} [Group G] [Fintype G] [DecidableEq G]
    [MulAction G α] [Fintype α] [DecidableEq α] [DecidableEq β]
    (obs : α → β) (hG_inv : ∀ g : G, ∀ x : α, obs (g • x) = obs x) :
    (∀ x y : α, (∀ g : G, obs (g • x) = obs (g • y)) → ∃ g : G, g • x = y) ↔
    Function.Injective (Quotient.lift obs (by ...)) := ...
```

**Proof Strategy**:
1. Define the quotient map via `MulAction.orbitRel`.
2. Show lift is well-defined using `hG_inv`.
3. Prove injectivity on quotient ↔ separation on representatives.

**Why This Is Revolutionary**: This connects the discrete Galois separation profile to the functorial quotient picture, bridging group theory and topology.

**Catalog Leverage**: Build on `GaloisSeparationProfile`, `galois_separation_yields_orbit_injective`.

**Research Mode**: formalize | **Estimated Depth**: 3

---

### 3. Finite-Field Lattice Collision Resistance

**Theorem Statement**: For a linear map `f : (ZMod p)ⁿ → (ZMod p)ᵐ` (with `m < n`), the collision count satisfies:
```
collisionCount f = Fintype.card ((ZMod p)ⁿ) * (Fintype.card (f.ker) - 1)
```
This gives an exact collision count in terms of the kernel dimension, directly connecting to lattice-based cryptographic security.

**Proof Strategy**:
1. Partition collision pairs by coset of the kernel.
2. Count: each kernel coset of size `k` contributes `k(k-1)` collision pairs.
3. Sum over `p^m` cosets, each of size `p^(n-m)`.

**Why This Is Revolutionary**: This provides an exact algebraic formula for collision complexity of linear maps over finite fields — the foundation of lattice-based post-quantum cryptography. It connects our `collisionCount` to linear algebra.

**Catalog Leverage**: Build on `collisionCount`, `collision_count_eq_zero_iff_injective`, `PostQuantumCollisionProfile`.

**Research Mode**: prove | **Estimated Depth**: 3

---

### 4. Certified Robustness for Equivariant Classifiers

**Theorem Statement**: If a classifier `f : M → α` is `L`-Lipschitz and equivariant under a group action `G` with action-Lipschitz bound `K`, then the certified robustness radius at each correctly classified point `x` is at least `gap(x) / (2 * L * K)` where `gap(x)` is the quantum-certified orbit gap.

```lean
theorem equivariant_certified_robustness_radius
    {G M : Type*} [Group G] [Fintype G] [MulAction G M]
    [PseudoMetricSpace M] (α : Type*) [Fintype α] [DecidableEq α]
    (f : M → α) (L K : ℝ) (hL : ∀ x y, dist (f x) (f y) ≤ L * dist x y)
    (hK : ActionLipschitzProfile G M)
    (hequiv : ∀ g x, f (g • x) = f x)
    (x : M) (hgap : 0 < quantumCertifiedOrbitGap G f) :
    ∃ r > 0, ∀ y, dist x y < r → f y = f x
```

**Proof Strategy**:
1. Use the orbit gap to lower-bound the minimum distance between distinct classification regions.
2. Apply the action-Lipschitz bound to relate metric perturbations to orbit perturbations.
3. Use the triangle inequality to derive the explicit radius.

**Why This Is Revolutionary**: This provides the first formal connection between algebraic group equivariance and certified adversarial robustness — a key concern in trustworthy AI.

**Catalog Leverage**: Build on `ActionLipschitzProfile`, `quantumCertifiedOrbitGap`, `exists_certified_radius_of_finite_orbit_separation`.

**Research Mode**: prove | **Estimated Depth**: 4

---

### 5. Thermodynamic Entropy-Production Inequality for Iterated Group Actions

**Theorem Statement**: For a finite group `G` acting on `α` and a signal `f : α → V`, the entropy energy density under the "averaged" action satisfies a monotonicity principle: applying the group average can only reduce the collision count.

```lean
theorem entropy_production_under_group_averaging
    {G α V : Type*} [CommGroup G] [Fintype G] [DecidableEq G]
    [MulAction G α] [Fintype α] [DecidableEq α]
    [AddCommGroup V] [DecidableEq V]
    (f : α → V) :
    collisionCount (fun a => ∑ g : G, f (g • a)) ≤
      Fintype.card G ^ 2 * collisionCount f
```

**Proof Strategy**:
1. If `∑ g, f(g•a) = ∑ g, f(g•b)`, find a bound on how many (a,b) pairs can satisfy this.
2. Use the pigeonhole principle: each collision in the averaged signal comes from at most `|G|²` collisions in the original.
3. Formalize using Finset.sum properties and collision count algebra.

**Why This Is Revolutionary**: This is a discrete analogue of entropy production in thermodynamics — group averaging (thermal equilibration) cannot create more collision complexity than the product of group size and original complexity.

**Catalog Leverage**: Build on `collisionCount`, `entropyEnergyDensity`, `SymmetryEnergySystem`.

**Research Mode**: discover | **Estimated Depth**: 5

---

## Under-explored Territory

1. **Additive combinatorics in Lean**: Mathlib has basic Sidon set definitions but lacks formalized Plünnecke–Ruzsa inequalities, Balog–Szemerédi–Gowers, or even the basic energy-spectrum Cauchy–Schwarz. Our framework provides the definitions needed to build this.

2. **Certified robustness theory**: No formal Lean theory connects group equivariance to adversarial robustness. The `ActionLipschitzProfile` + `quantumCertifiedOrbitGap` framework is a natural starting point.

3. **Lattice cryptography abstractions**: The connection between kernel dimension and collision count for linear maps over finite fields is not formalized anywhere. Our `PostQuantumCollisionProfile` could anchor this development.

## Cross-Domain Bridges

- **Additive combinatorics ↔ Cryptography**: The `collisionCount`–`additiveEnergyGroup` hierarchy provides a formal pathway from Balog–Szemerédi–type results to lattice collision resistance bounds.

- **Galois theory ↔ ML robustness**: The `GaloisSeparationProfile` → `exists_certified_radius_of_finite_orbit_separation` chain formally bridges finite symmetry to certified classification robustness.

- **Thermodynamic entropy ↔ Algebraic collision complexity**: The `entropyEnergyDensity` normalization and its monotonicity under injective composition formalizes the connection between information-theoretic entropy and algebraic collision counts.

## Open Problems Encountered

1. **Sharp energy lower bound for injective functions**: What is the minimum additive energy of an injective function `f : Fin n → ℤ`? Our framework proves `E(f) ≥ n²` for all `f`, but the sharp bound for injective `f` involves Sidon set theory and is likely `Θ(n³)`.

2. **Constructive orbit gap computation**: The `quantumCertifiedOrbitGap` is defined as an infimum. Computing it efficiently (in polynomial time in `|α|` and `|G|`) is an open algorithmic question.

3. **Energy rigidity threshold**: For which groups and signal spaces does there exist a nontrivial `EnergyRigidFamily`? Characterizing when low energy forces difference injectivity connects to deep questions in additive combinatorics.
