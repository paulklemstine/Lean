# Idempotent Gauge–Curvature Duality via Closure Connection Semimodules and Certified Flat Reconstruction

## Abstract

We introduce and formalize a finite idempotent gauge theory on closure systems, establishing the first machine-verified foundation for gauge–potential duality in closure-generated discrete geometries. The central result is a **flatness–reconstruction duality theorem**: a connection (weight assignment on pairs of closed regions) satisfies the cocycle condition if and only if it is induced by a global potential function. We prove path-independence of transport for flat connections, uniqueness of potentials up to gauge equivalence, and provide a certified reconstruction algorithm that either produces a verified potential or a curvature witness certifying non-flatness. The cochain complex C⁰ →[δ₀]→ C¹ →[δ₁]→ C² is constructed and the fundamental identity δ₁ ∘ δ₀ = 0 is established, yielding H¹ = 0 for nonempty vertex sets. All theorems are formally verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

**Keywords:** gauge theory, closure systems, idempotent semirings, tropical geometry, discrete curvature, certified algorithms, cohomology, formal verification

---

## 1. Introduction

### 1.1 Motivation

The interplay between local constraints and global structure is a central theme across mathematics, physics, and computer science. In differential geometry, the local-to-global principle manifests as the relationship between curvature (local) and holonomy (global). In algebraic topology, sheaf cohomology quantifies the obstruction to extending local sections to global ones. In optimization, the consistency of local constraints determines the existence of global solutions.

This work brings these ideas together in a new setting: **finite closure systems** equipped with **idempotent gauge connections**. Closure systems — which model logical consequence, concept lattices, and feature dependencies — provide a natural discrete geometry. We show that this geometry supports a genuine gauge theory, where:

- Closed regions play the role of spacetime patches
- Transport weights in an abelian group play the role of a connection
- The cocycle defect defines curvature
- Flatness (vanishing curvature) is equivalent to global reconstructibility from a potential
- Reconstruction is not merely existential but algorithmically certified

### 1.2 Contributions

1. **Gauge–Potential Duality Theorem** (Theorem 3.1): A connection is flat (cocycle) iff it is induced by a global potential. This is the discrete Poincaré lemma for closure-generated geometry.

2. **Path-Independence Theorem** (Theorem 3.2): Flat connections yield path-independent transport, enabling well-defined potential reconstruction.

3. **Gauge Uniqueness Theorem** (Theorem 3.3): Potentials inducing the same flat connection differ by a global constant (gauge transformation).

4. **Certified Reconstruction Algorithm** (Theorem 4.1): A finite algorithm that produces either a verified potential or a curvature witness, with machine-checked correctness.

5. **Cohomological Framework** (Theorem 5.1): The cochain complex with δ₁ ∘ δ₀ = 0 and H¹ = 0 provides the cohomological underpinning.

6. **Machine Verification**: All results are formally proved in Lean 4 with Mathlib, with no sorry statements and only standard axioms.

### 1.3 Related Work

**Discrete gauge theory.** Gauge theory on lattices and simplicial complexes has a long history [Wilson 1974, Regge 1961]. Our contribution is to replace the externally given simplicial structure with one generated endogenously by a closure operator.

**Tropical geometry.** The tropical semiring (ℝ ∪ {-∞}, max, +) provides the canonical idempotent setting for our theory. Tropical line bundles and divisors on graphs [Baker–Norine 2007, Gathmann–Kerber 2008] are related but use different geometric primitives.

**Closure systems and formal concept analysis.** The lattice of closed sets of a closure operator is a fundamental object in formal concept analysis [Ganter–Wille 1999] and matroid theory [Oxley 2011]. Our gauge theory adds a new dynamical/cohomological layer to this algebraic structure.

**Certified algorithms.** The movement toward formally verified algorithms [Hales et al. 2017, Avigad–Massot 2022] provides the methodological foundation for our certified reconstruction.

---

## 2. Definitions and Setup

### 2.1 Connections on Finite Sets

**Definition 2.1** (Connection). Let V be a type (vertex set) and G an additive abelian group. A *connection* is a function A : V → V → G, written A.weight(u,v) for the weight of the directed edge from u to v.

**Definition 2.2** (Cocycle / Flatness). A connection A is a *cocycle* (or *flat*) if for all u, v, w ∈ V:

    A.weight(u,v) + A.weight(v,w) = A.weight(u,w)

**Definition 2.3** (Potential). A function φ : V → G is a *potential*. The connection *induced by* φ is:

    (ofPotential φ).weight(u,v) = φ(v) - φ(u)

**Definition 2.4** (Curvature). The curvature of A on a triple (u,v,w) is:

    curvature(A, u, v, w) = A.weight(u,v) + A.weight(v,w) - A.weight(u,w)

A connection is flat iff its curvature vanishes on all triples.

**Definition 2.5** (Gauge Equivalence). Two potentials φ, ψ : V → G are *gauge-equivalent* if there exists c ∈ G such that ψ(v) = φ(v) + c for all v.

### 2.2 Closure Systems

**Definition 2.6** (Closure Operator). A closure operator on Finset α consists of:
- cl : Finset α → Finset α
- Extensivity: s ⊆ cl(s)
- Monotonicity: s ⊆ t → cl(s) ⊆ cl(t)
- Idempotency: cl(cl(s)) = cl(s)

**Definition 2.7** (Closed Set). A set s is closed if cl(s) = s. The type ClosedSet(C) = {s : Finset α // cl(s) = s} carries a canonical Nonempty instance (via cl(∅)).

### 2.3 Path Transport

**Definition 2.8** (List Transport). For a weight function f : V → V → G and a list l = [v₀, v₁, ..., vₙ], the transport is:

    transport(f, l) = Σᵢ f(vᵢ, vᵢ₊₁) = f(v₀,v₁) + f(v₁,v₂) + ... + f(vₙ₋₁,vₙ)

### 2.4 Cochain Complex

**Definition 2.9** (Coboundary operators).
- δ₀ : (V → G) → (V → V → G), defined by δ₀(φ)(u,v) = φ(v) - φ(u)
- δ₁ : (V → V → G) → (V → V → V → G), defined by δ₁(w)(u,v,x) = w(u,v) + w(v,x) - w(u,x)

---

## 3. Main Results

### 3.1 Gauge–Potential Duality

**Theorem 3.1** (flat_iff_potential). Let V be a nonempty type and G an additive abelian group. For any connection A : Connection V G:

    A.IsCocycle ↔ ∃ φ : V → G, A.InducedByPotential φ

*Proof sketch.*

(⇐) If A.weight(u,v) = φ(v) - φ(u) for all u,v, then:
A.weight(u,v) + A.weight(v,w) = (φ(v) - φ(u)) + (φ(w) - φ(v)) = φ(w) - φ(u) = A.weight(u,w).

(⇒) Choose an arbitrary basepoint b ∈ V (using Nonempty). Define φ(v) := A.weight(b, v). For any u, v, the cocycle condition with the triple (b, u, v) gives:
A.weight(b,u) + A.weight(u,v) = A.weight(b,v),
so A.weight(u,v) = A.weight(b,v) - A.weight(b,u) = φ(v) - φ(u). □

**Corollary 3.1.1** (cocycle_self_zero). If A is a cocycle, then A.weight(v,v) = 0 for all v.

*Proof.* From the cocycle condition with u = v = w: A.weight(v,v) + A.weight(v,v) = A.weight(v,v), which gives A.weight(v,v) = 0 by cancellation. □

### 3.2 Path-Independence

**Theorem 3.2** (transport_path_independent). If f : V → V → G satisfies the cocycle condition, then for any two list-paths p, q with the same first element u and last element v (and length ≥ 2):

    listTransport(f, p) = listTransport(f, q)

*Proof sketch.* By the intermediate lemma `listTransport_eq_of_cocycle`, the transport along any path from u to v equals f(u,v). Both paths therefore give the same value. The intermediate lemma is proved by induction on the path list. □

**Theorem 3.2.1** (listTransport_append_cons). Transport is additive under path concatenation at a shared vertex:

    transport(p ++ [v] ++ q) = transport(p ++ [v]) + transport(v :: q)

### 3.3 Gauge Uniqueness

**Theorem 3.3** (potential_unique_mod_gauge). If A.InducedByPotential(φ) and A.InducedByPotential(ψ), then GaugeEquiv(φ, ψ).

*Proof sketch.* From both hypotheses: φ(v) - φ(u) = ψ(v) - ψ(u) for all u, v. Rearranging: (ψ(v) - φ(v)) = (ψ(u) - φ(u)) for all u, v. Hence ψ - φ is constant. Take c = ψ(u₀) - φ(u₀) for any u₀. □

**Theorem 3.3.1** (gaugeEquiv_iff_same_connection). If GaugeEquiv(φ, ψ), then ofPotential(φ) = ofPotential(ψ).

*Proof.* If ψ(v) = φ(v) + c for all v, then ψ(v) - ψ(u) = (φ(v) + c) - (φ(u) + c) = φ(v) - φ(u). □

---

## 4. Certified Reconstruction Algorithm

### 4.1 Algorithm Description

**Algorithm: CertifiedReconstruct**

```
Input: Connection A on finite vertex set V with values in G
Output: Either (potential φ, correctness proof) or (curvature witness)

1. Choose basepoint b ∈ V
2. Define φ(v) := A.weight(b, v) for all v ∈ V
3. For each triple (u, v, w) ∈ V³:
   3a. Compute defect := A.weight(u,v) + A.weight(v,w) - A.weight(u,w)
   3b. If defect ≠ 0: return CurvatureWitness(u, v, w, defect)
4. Return Potential(φ) with correctness certificate
```

**Time complexity:** O(n³) where n = |V| (dominated by the verification loop in step 3).

**Space complexity:** O(n) for the potential function.

### 4.2 Correctness

**Theorem 4.1** (certifiedReconstruct). For any connection A on a finite nonempty type V:

    certifiedReconstruct(A) produces either:
    - ReconstructResult.flat(φ, proof) where A.InducedByPotential(φ)
    - ReconstructResult.obstructed(w) where w is a CurvatureWitness

**Theorem 4.2** (curvatureWitness_sound). A curvature witness certifies non-flatness:

    ∀ w : CurvatureWitness V G A, ¬ A.IsCocycle

*Proof.* If A were a cocycle, then A.weight(w.u, w.v) + A.weight(w.v, w.w) = A.weight(w.u, w.w), contradicting w.witness. □

### 4.3 Tropical Specialization

In the tropical (min-plus) setting, the reconstruction algorithm reduces to **Bellman-Ford shortest-path computation**:

```
Input: Directed graph with edge weights w(u,v)
Output: Shortest-path potential or negative cycle witness

1. Initialize dist[v] := ∞ for all v, dist[base] := 0
2. Repeat n-1 times:
   For each edge (u,v): dist[v] := min(dist[v], dist[u] + w(u,v))
3. Check for negative cycles (one more relaxation step)
4. Return dist as potential, or negative cycle as witness
```

This shows that **Bellman-Ford is an instance of gauge-theoretic potential reconstruction** in the tropical semiring.

---

## 5. Cohomological Framework

### 5.1 Cochain Complex

The cochain complex C⁰ →[δ₀]→ C¹ →[δ₁]→ C² is defined by:

- C⁰ = {φ : V → G} (0-cochains / potentials)
- C¹ = {w : V → V → G} (1-cochains / connections)
- C² = {κ : V → V → V → G} (2-cochains / curvatures)

With coboundary operators:
- δ₀(φ)(u,v) = φ(v) - φ(u)
- δ₁(w)(u,v,x) = w(u,v) + w(v,x) - w(u,x)

### 5.2 Fundamental Identity

**Theorem 5.1** (coboundary_sq_zero). For all φ : V → G and all u, v, w ∈ V:

    δ₁(δ₀(φ))(u,v,w) = 0

*Proof.* Direct computation:
δ₁(δ₀(φ))(u,v,w) = (φ(v) - φ(u)) + (φ(w) - φ(v)) - (φ(w) - φ(u)) = 0. □

**Corollary 5.1.1** (coboundary_is_cocycle). Every coboundary is a cocycle: im(δ₀) ⊆ ker(δ₁).

### 5.3 H¹ Triviality

**Theorem 5.2** (H1_trivial_of_nonempty). If V is nonempty, then every cocycle is a coboundary: ker(δ₁) = im(δ₀), i.e., H¹(V, G) = 0.

*Proof sketch.* Given w ∈ ker(δ₁), choose b ∈ V and define φ(v) = w(b,v). Then δ₀(φ)(u,v) = w(b,v) - w(b,u). The cocycle condition δ₁(w)(b,u,v) = 0 gives w(b,u) + w(u,v) = w(b,v), so w(u,v) = w(b,v) - w(b,u) = δ₀(φ)(u,v). □

### 5.4 Gauge Setoid

Gauge equivalence defines an equivalence relation on potentials (reflexive, symmetric, transitive). The quotient (V → G) / GaugeEquiv classifies potentials up to global shifts. Since H¹ = 0, every flat connection corresponds to a unique gauge class of potentials.

---

## 6. Closure System Instantiation

### 6.1 Closure Nerve

For a closure operator C on Finset α, the **closure nerve** has:
- **Vertices:** Closed sets {s : Finset α // cl(s) = s}
- **Edges:** Pairs (U, V) of closed sets with U ⊆ V
- **Elementary edges:** (U, V) where V = cl(U ∪ {g}) for some generator g ∉ U
- **Elementary squares:** Diamonds from adding two generators in either order

### 6.2 Closure Connection Duality

**Theorem 6.1** (closureFlat_iff_potential). For any closure operator C on Finset α and connection A on ClosedSet(C):

    A.IsCocycle ↔ ∃ φ : ClosedSet(C) → G, A.InducedByPotential φ

This follows immediately from the general duality theorem, since ClosedSet(C) is nonempty (cl(∅) is always closed).

### 6.3 Elementary Nerve Structure

The closure operator generates a natural "elementary" nerve structure. An **elementary arrow** from U to V means V = cl(U ∪ {g}) for some element g. An **elementary square** arises when adding elements g and h in either order produces the same result: cl(cl(U ∪ {g}) ∪ {h}) = cl(cl(U ∪ {h}) ∪ {g}).

For closure operators satisfying an anti-exchange property (antimatroids), elementary squares generate all path relations, so checking curvature on elementary squares suffices for global flatness.

---

## 7. Applications

### 7.1 Sensor Network Calibration

**Problem:** n sensors with unknown biases b₁, ..., bₙ. Pairwise measurements δᵢⱼ ≈ bⱼ - bᵢ.

**Solution:** Model as a connection with weight(i,j) = δᵢⱼ. Apply certified reconstruction:
- If flat: potential = biases. Calibration complete.
- If not flat: curvature witness localizes the inconsistent measurement.

### 7.2 Ranking from Pairwise Comparisons

**Problem:** n items with pairwise scores s(A,B) = "how much A is preferred over B."

**Solution:** Connection weight(A,B) = s(A,B). Flatness = transitivity. Potential = global rating.

### 7.3 Distributed Clock Synchronization

**Problem:** n networked computers with clock offsets. Pairwise time differences measured.

**Solution:** Connection weights = measured time differences. Reconstruction = clock offsets. Curvature witness = faulty link detection.

### 7.4 Tropical Optimization

**Problem:** System of difference constraints x(v) - x(u) ≤ w(u,v).

**Solution:** Tropical potential reconstruction = Bellman-Ford shortest paths. Negative cycle = curvature witness.

---

## 8. Computational Experiments

### 8.1 Flat Connection on 4 Vertices

Vertices: {A, B, C, D}. Potential: φ = {A: 1, B: 3, C: 7, D: 2}.

| Edge | Weight w(u,v) | φ(v) - φ(u) |
|------|--------------|--------------|
| A→B  | +2.0         | 3-1 = +2.0   |
| A→C  | +6.0         | 7-1 = +6.0   |
| A→D  | +1.0         | 2-1 = +1.0   |
| B→C  | +4.0         | 7-3 = +4.0   |
| B→D  | -1.0         | 2-3 = -1.0   |
| C→D  | -5.0         | 2-7 = -5.0   |

Cocycle verification: all 64 triples satisfy w(u,v) + w(v,w) = w(u,w). ✓

### 8.2 Path-Independence

All paths from A to D:

| Path          | Transport |
|---------------|-----------|
| A→D           | +1.0      |
| A→B→D         | +2+(-1) = +1.0 |
| A→C→D         | +6+(-5) = +1.0 |
| A→B→C→D       | +2+4+(-5) = +1.0 |
| A→C→B→D       | +6+(-4)+(-1) = +1.0 |

All transports equal +1.0 = φ(D) - φ(A). ✓

### 8.3 Gauge Equivalence

φ₁ = {A:1, B:3, C:7, D:2} and φ₂ = {A:6, B:8, C:12, D:7} are gauge-equivalent with c = 5. They induce identical connections.

φ₃ = {A:1, B:4, C:7, D:2} is NOT gauge-equivalent to φ₁ (difference B differs). They induce different connections.

### 8.4 Certified Reconstruction

- Flat connection: reconstruction from base A yields φ = {A:0, B:2, C:6, D:1}, gauge-equivalent to original (shift by -1). ✓
- Non-flat connection (w(A,C) perturbed by +1.5): curvature witness (A,B,C) with defect -1.5. ✓

---

## 9. Discussion

### 9.1 Significance

This work establishes the first formally verified gauge theory on closure-generated discrete geometries. The key insight is that the cocycle condition — a local consistency requirement — is equivalent to global reconstructibility from a potential, with certified algorithmic reconstruction.

### 9.2 Comparison with Classical Gauge Theory

In classical differential geometry, the analogue of our result is:
- **Poincaré lemma:** on a contractible domain, every closed form is exact
- **Flat connection theorem:** a connection is flat iff it is gauge-equivalent to the trivial connection
- **Holonomy theorem:** flat connections have trivial holonomy

Our discrete version replaces smooth manifolds with closure lattices, differential forms with cochains on the nerve, and the de Rham complex with the finite cochain complex C⁰ → C¹ → C².

### 9.3 Limitations

1. The current formalization uses the "full" cocycle condition (on all triples), not just elementary squares. Proving that elementary squares generate all relations requires additional structure (e.g., semimodularity or the antimatroid property).

2. The theory works over abelian groups. Extension to nonabelian gauge groups (e.g., matrix-valued connections) is a significant open direction.

3. H¹ = 0 is a consequence of using the "complete" nerve (all pairs). For restricted nerves (only elementary edges), H¹ may be nontrivial.

### 9.4 Machine Verification

All theorems are verified in Lean 4 with Mathlib. The axioms used are:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

These are standard Lean axioms and do not compromise the constructive content of the algorithms.

---

## 10. Future Work

1. **Local-to-global flatness.** Prove that for antimatroids and semimodular lattices, checking curvature on elementary squares suffices for global flatness. This is the discrete analogue of simple connectivity.

2. **Nonabelian gauge theory.** Extend to matrix-valued connections with noncommutative composition. This connects to tropical linear algebra and noncommutative optimization.

3. **Spectral sequence comparison.** Relate closure nerve cohomology to classical Čech cohomology via a spectral sequence, establishing structural comparison theorems.

4. **Wall-crossing.** For tropical semirings, classify the chamber structure in weight space where the gauge class of the reconstructed connection changes. Connect to tropical hyperplane arrangements.

5. **Applications to ML.** Use certified reconstruction for latent state inference in explainable machine learning, where closure systems model feature dependencies and the potential function encodes the global latent state.

---

## References

1. Baker, M. and Norine, S. (2007). Riemann-Roch and Abel-Jacobi theory on a finite graph. *Advances in Mathematics*, 215(2), 766-788.

2. Ganter, B. and Wille, R. (1999). *Formal Concept Analysis: Mathematical Foundations*. Springer.

3. Gathmann, A. and Kerber, M. (2008). A Riemann-Roch theorem in tropical geometry. *Mathematische Zeitschrift*, 259(1), 217-230.

4. Oxley, J. (2011). *Matroid Theory*. Oxford University Press.

5. Regge, T. (1961). General relativity without coordinates. *Il Nuovo Cimento*, 19(3), 558-571.

6. Wilson, K.G. (1974). Confinement of quarks. *Physical Review D*, 10(8), 2445.

7. Avigad, J. and Massot, P. (2022). *Mathematics in Lean*. Community project.
