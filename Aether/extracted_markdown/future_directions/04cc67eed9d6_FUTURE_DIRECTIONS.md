# Future Directions: Mod-12 Pareto Rigidity and Beyond

## Overview

The Pareto rigidity theorem for voice leadings on ℤ/12ℤ opens several breakthrough research avenues connecting algebraic combinatorics, optimal transport, tropical geometry, and information theory. Each direction below is specified with concrete hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Four-Voice Pareto Classification

### Hypothesis
All Pareto-optimal voice assignments between standard four-note chord types (seventh chords, added-sixth chords) in ℤ/12ℤ can be classified up to transposition and voice permutation, yielding a finite database of canonical voice-leading strategies.

### Proof Strategy
1. Extend all definitions to `Fin 4 → pc` (straightforward generalization).
2. The transposition invariance theorem generalizes immediately (same proof structure).
3. Normal-form reduction fixes the first voice at 0, reducing to (12²) × 4! cases.
4. Enumerate Pareto frontiers computationally; verify invariance formally.
5. Group results by chord-class pairs (e.g., dominant 7th → tonic, diminished 7th → minor).

### Key Challenge
The number of permutations grows to 4! = 24, making the Pareto dominance check O(24² · 4) per configuration pair. Still feasible for exhaustive computation.

### Cross-Domain Connections
- **Orbifold geometry:** The 4-voice configuration space modulo transposition is a 3-dimensional orbifold; classifying Pareto frontiers gives its "skeletal" structure.
- **Music theory:** Direct relevance to SATB voice leading taught in every conservatory.

### Concrete Lean Target
```
theorem pareto_optimal_transposition_invariant_4voice
    (t : pc) (source target : Fin 4 → pc) (τ : Equiv.Perm (Fin 4)) :
    AssignmentParetoOptimal 4 source target τ ↔
    AssignmentParetoOptimal 4 (fun i => source i + t) (fun i => target i + t) τ
```

---

## Direction 2: Optimal Transport on Chord Orbits

### Hypothesis
The Wasserstein-1 distance (Earth Mover's Distance) between pitch-class distributions, using cyclic distance as the ground metric, is invariant under transposition. This induces a well-defined metric on the quotient space of pitch-class distributions modulo transposition.

### Proof Strategy
1. Define pitch-class distributions as functions `pc → ℝ≥0` summing to 1.
2. Define the Wasserstein-1 distance using the Kantorovich dual formulation.
3. Prove translation invariance using the cycDist invariance lemma.
4. Show this descends to a metric on the orbit space.
5. Connect to the voice-leading cost via the Birkhoff-von Neumann theorem (optimal transport with equal masses = optimal assignment).

### Key Challenge
Formalization of the Kantorovich dual in Lean, or working with the primal (coupling) formulation for finite distributions.

### Cross-Domain Connections
- **Machine learning:** Wasserstein distances are fundamental in generative models (Wasserstein GANs) and domain adaptation.
- **Computational biology:** Earth Mover's Distance for comparing molecular distributions.
- **Economics:** Optimal allocation of resources on circular markets.

### Concrete Lean Target
```
theorem wasserstein_cyclic_transposition_invariant
    (t : pc) (μ ν : pc → ℝ) (hμ : ∑ x, μ x = 1) (hν : ∑ x, ν x = 1) :
    wasserstein_cyclic μ ν = wasserstein_cyclic (fun x => μ (x - t)) (fun x => ν (x - t))
```

---

## Direction 3: Mod-12 Rate-Distortion Theory

### Hypothesis
Define a source-coding problem where the source alphabet is the set of chord classes (triads modulo transposition), the reconstruction alphabet is ℤ/12ℤ configurations, and distortion is voice-leading cost. The rate-distortion function R(D) is well-defined and exhibits phase transitions at critical distortion levels corresponding to musical interval boundaries.

### Proof Strategy
1. Define the rate-distortion function for finite alphabets with cyclic distortion.
2. Prove R(D) is convex and non-increasing (standard information-theoretic arguments).
3. Show transposition invariance implies R(D) is the same for all representatives of a chord class.
4. Compute R(D) for small cases (e.g., {major, minor} alphabet) and identify phase transitions.

### Key Challenge
Formalizing mutual information and the rate-distortion optimization in Lean. May require developing finite information theory infrastructure.

### Cross-Domain Connections
- **Data compression:** Rate-distortion theory is the foundation of lossy compression (JPEG, MP3).
- **Neuroscience:** Efficient coding hypotheses in auditory perception.
- **Harmonic analysis:** The rate-distortion curve gives fundamental limits on how much harmonic information can be "compressed" while maintaining proximity to the original.

### Concrete Lean Target
```
theorem mod12_rate_distortion_convex
    (D : ℝ) (hD : 0 ≤ D) :
    ConvexOn ℝ (Set.Ici 0) rate_distortion_cyclic
```

---

## Direction 4: Tropical Spectral Theory of Harmonic Transitions

### Hypothesis
Encode chord-class transitions as a weighted graph G where vertices are chord classes (triads modulo transposition) and edge weights are optimal voice-leading costs. The tropical (min-plus) eigenvalues of the adjacency matrix of G capture the asymptotic behavior of optimal multi-step harmonic progressions.

### Proof Strategy
1. Construct the transition matrix M ∈ ℝ_min-plus^(k×k) where k is the number of chord classes.
2. Prove that transposition invariance implies M has circulant structure (or block-circulant for classes that break transposition symmetry differently).
3. Compute tropical eigenvalues using the min-plus characteristic polynomial.
4. Interpret eigenvalues as optimal "pressure" for repeated harmonic motion.
5. Connect to the subeigenvector bounds already in the catalog (subeigenvector_two_step_bound).

### Key Challenge
Tropical eigenvalue theory for finite matrices is well-developed but not yet in Mathlib. May need to build basic tropical linear algebra.

### Cross-Domain Connections
- **Scheduling theory:** Tropical eigenvalues govern the throughput of cyclic production systems.
- **Dynamical systems:** Min-plus spectral radius = Lyapunov exponent of piecewise-linear dynamics.
- **Network optimization:** Critical path analysis in project scheduling.

### Concrete Lean Target
```
theorem tropical_transition_matrix_circulant
    (classes : Finset (Fin k → pc))
    (h_orbit : ∀ c ∈ classes, ∀ t : pc, shift c t ∈ classes) :
    IsCirculant (tropicalTransitionMatrix classes)
```

---

## Direction 5: Categorical Quotient of Voice-Leading Groupoids

### Hypothesis
Voice leadings between chord classes form a groupoid (category where every morphism is invertible, up to identification of voice assignments). The transposition action makes this a G-groupoid for G = ℤ/12ℤ, and the quotient groupoid classifies all voice-leading types up to key equivalence.

### Proof Strategy
1. Define the voice-leading category: objects are n-voice configurations, morphisms are voice assignments (permutations) with associated costs.
2. Show the transposition action is a group action on this category (functor from Bℤ/12ℤ to Cat).
3. Define the quotient category (orbits of objects, equivariant morphisms).
4. Prove that cost-minimizing morphisms (optimal assignments) form a sub-groupoid that is preserved by the action.
5. Classify the quotient groupoid for n = 3 with standard triads.

### Key Challenge
Category theory in Lean/Mathlib is well-developed but the specific construction of groupoid quotients by group actions may need custom development.

### Cross-Domain Connections
- **Representation theory:** G-groupoids are closely related to representation categories of finite groups.
- **Topological quantum field theory:** Groupoid quotients appear in the Dijkgraaf-Witten TQFT.
- **Homotopy type theory:** Groupoids as ∞-groupoids truncated at level 1.

### Concrete Lean Target
```
def VoiceLeadingCategory (n : ℕ) : Category (Fin n → pc) where
  Hom x y := Equiv.Perm (Fin n)
  id _ := Equiv.refl _
  comp σ τ := σ.trans τ
```

---

## Summary Table

| Direction | Difficulty | Impact | Dependencies |
|---|---|---|---|
| 1. Four-voice classification | Medium | High (music theory) | Current results |
| 2. Optimal transport | Medium-Hard | Very High (ML, econ) | Wasserstein in Lean |
| 3. Rate-distortion | Hard | High (info theory) | Entropy in Lean |
| 4. Tropical spectral | Hard | High (scheduling) | Tropical algebra |
| 5. Categorical groupoid | Very Hard | Transformative | Groupoid quotients |

---

## Research Team Organization

### Phase 1 (Immediate, 1-2 weeks)
- **Team A:** Four-voice generalization (Direction 1). Extend all definitions, re-run proofs, compute database.
- **Team B:** Computational exploration. Enumerate all triad/seventh-chord transitions, visualize cost landscapes, identify patterns.

### Phase 2 (Short-term, 1-2 months)
- **Team C:** Optimal transport formulation (Direction 2). Formalize Wasserstein distance in Lean, prove invariance.
- **Team D:** Tropical foundations (Direction 4). Build min-plus matrix algebra, compute eigenvalues.

### Phase 3 (Medium-term, 3-6 months)
- **Team E:** Rate-distortion theory (Direction 3). Build finite information theory in Lean, compute R(D) curves.
- **Team F:** Categorical framework (Direction 5). Define voice-leading category, prove functoriality.

### Ongoing
- **Validation team:** Continuously verify all formal proofs against latest Mathlib. Maintain compatibility.
- **Application team:** Build practical tools (automatic voice-leading software, chord progression analyzers) using the theoretical results.
