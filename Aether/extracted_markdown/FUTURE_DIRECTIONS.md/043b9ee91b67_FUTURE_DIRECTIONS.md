# Future Directions: Tropical SATB Chorale Optimization

## 1. Tropical Matrix/Automaton Equivalence for SATB DP

### Precise Theorem Statement
```
theorem satb_tropical_matrix_equiv
  (S : Finset Voice) (n : ℕ)
  (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
  (allow : ℕ → Voice → Prop) [∀ n v, Decidable (allow n v)]
  (hne : ∀ n, (S.filter (allow n)).Nonempty)
  (hunif : ∀ n m v, allow n v ↔ allow m v) :
  ∀ v w, v ∈ S → w ∈ S →
    valueFn S allow vert lead hne n v =
      tropMatPow (transitionMatrix S vert lead) n v w
```
where `transitionMatrix S vert lead` is the tropical (min-plus) transition matrix with entries `M[v,w] = lead(v,w) + vert(w)`, and `tropMatPow` is iterated tropical matrix multiplication.

### Why It Matters
This would establish a complete algebraic characterization of SATB optimization: the value function is literally a tropical matrix power. This connects chorale harmonization to the well-studied theory of weighted automata, where the behavior of a weighted finite automaton is described by tropical matrix products. It would also enable spectral methods: the tropical eigenvalue of the transition matrix controls the asymptotic growth rate of optimal costs.

### Proof Strategy
1. Define `transitionMatrix` as a `Matrix (Fin |S|) (Fin |S|) ℤ` with entries from `lead` and `vert`.
2. Define `tropMatMul` using `Finset.inf'` instead of sum.
3. Prove by induction on n that `valueFn` equals the appropriate entry of `tropMatPow`.
4. The key step is showing that the Bellman recursion unfolds to exactly the tropical matrix multiplication formula.

### Cross-Domain Implications
- **Weighted automata theory:** SATB as a weighted finite automaton with tropical semiring weights
- **Spectral theory:** tropical eigenvalues give asymptotic optimal cost growth rates
- **Algebraic geometry:** connections to tropical varieties and Newton polytopes

---

## 2. Counterpoint Invariants as Conserved Tropical Energies

### Precise Theorem Statement
```
theorem counterpoint_energy_monotone
  (S : Finset Voice) (vert : Voice → ℤ) (lead : Voice → Voice → ℤ)
  (allow : ℕ → Voice → Prop)
  (E : Voice → ℤ)  -- energy function
  (hE : ∀ v w, allow n v → allow (n+1) w →
    E w ≤ E v + lead v w - vert w) :
  -- energy is monotone along optimal paths
  ∀ x : Realization N, isOptimal x →
    ∀ k : Fin N, E (x k.succ) ≤ E (x k.castSucc) + lead (x k.castSucc) (x k.succ) - vert (x k.succ)
```

### Why It Matters
In physics, conservation laws (energy, momentum) constrain the evolution of dynamical systems. If analogous conserved or monotone quantities exist for voice-leading — "tropical energies" that don't increase along optimal paths — they would provide structural constraints on what good counterpoint can look like, independent of specific penalty functions. This could yield new music-theoretic insights about why certain voice-leading patterns are preferred.

### Proof Strategy
1. Define candidate energy functions: total voice separation, registral centroid, intervallic tension.
2. Prove monotonicity by combining the optimality condition with the Bellman equation.
3. Use the optimal suffix theorem to transfer local energy bounds to global ones.

### Cross-Domain Implications
- **Dynamical systems:** Lyapunov functions for voice-leading dynamics
- **Thermodynamics:** entropy-like quantities for polyphonic music
- **Control theory:** stability of optimal trajectories

---

## 3. Probabilistic/Tropical Bridge: Log-Semiring vs Min-Plus for Chorale Decoding

### Precise Theorem Statement
```
theorem tropical_as_zero_temperature_limit
  (S : Finset Voice) (vert : Voice → ℝ) (lead : Voice → Voice → ℝ)
  (β : ℝ) (hβ : 0 < β) :
  ∀ v, Tendsto (fun β => (-1/β) * log (Σ_{w ∈ S} exp(-β * (lead v w + valueFn_real ... n w))))
    atTop (𝓝 (inf_{w ∈ S} (lead v w + valueFn_real ... n w)))
```

### Why It Matters
The tropical semiring is the "zero-temperature" (β → ∞) limit of the log-probability semiring used in statistical models. This theorem would formally connect:
- **Optimal SATB** (tropical/min-plus): finding the single best harmonization
- **Bayesian SATB** (log-sum-exp): computing the posterior distribution over harmonizations

This bridge is exactly the relationship between Viterbi decoding (finding the most likely path in an HMM) and forward-backward computation (computing marginal probabilities). Formalizing it would unify deterministic and probabilistic approaches to chorale harmonization.

### Proof Strategy
1. Use the Laplace method / Varadhan's lemma for finite sums.
2. Show that `-1/β · log(Σ exp(-β·aᵢ))` converges to `min(aᵢ)` as β → ∞.
3. Lift to the recursive value function by induction.

### Cross-Domain Implications
- **Statistical physics:** partition functions and free energy
- **Machine learning:** softmax as smooth approximation to argmax
- **Information theory:** rate-distortion as tropical information bottleneck

---

## 4. Complexity Theorem: NP-Hardness and Tractable Subclasses

### Precise Theorem Statement
```
theorem satb_with_forbidden_intervals_is_NP_hard :
  ∃ (reduction : 3SAT_instance → SATB_instance),
    polynomial_time reduction ∧
    (∀ φ, satisfiable φ ↔ ∃ x, admissible x ∧ pathCost x ≤ 0)
```

And conversely:
```
theorem satb_with_decomposable_penalties_is_polynomial :
  ∀ (vert : Voice → ℤ) (lead : Voice → Voice → ℤ),
    is_decomposable vert → is_decomposable lead →
    ∃ (alg : Realization N), polynomial_time alg ∧ isOptimal alg
```

### Why It Matters
Understanding which SATB constraint structures make optimization easy vs hard would clarify the computational complexity landscape of music theory. If general SATB with forbidden intervals is NP-hard (as we conjecture), but practical constraints (range-bounded, pairwise decomposable) are polynomial, this would explain why Bach-style harmonization is tractable in practice: the structure of real musical constraints falls within a tractable subclass.

### Proof Strategy
1. For NP-hardness: reduce 3-SAT to SATB by encoding variables as voice choices and clauses as forbidden interval patterns.
2. For tractability: show that decomposable penalties (penalties that factor over pairs of voices) yield a polynomial-sized DP state space.
3. Characterize the boundary: identify the minimal constraint structure that makes optimization NP-hard.

### Cross-Domain Implications
- **Computational complexity:** new NP-hard problems from music theory
- **Constraint satisfaction:** structural tractability results
- **Algorithm design:** fixed-parameter tractable algorithms for bounded-treewidth constraint graphs

---

## 5. Categorical Formulation: SATB Transitions as Morphisms in a Weighted Category

### Precise Theorem Statement
```
def SATBCategory : Category where
  Obj := Voice
  Hom v w := ℤ  -- morphism = transition cost
  id v := vert v  -- identity = vertical penalty
  comp f g := f + g  -- composition = tropical multiplication (= addition)
  -- The tropicalized Bellman equation becomes:
  -- optimal n-step path = n-fold composition in SATBCategory
```

```
theorem satb_functor_preserves_optimality :
  ∀ (F : SATBCategory ⥤ MinPlusCategory),
    F.map (optimal_morphism v w n) = optimal_entry (tropMatPow M n) v w
```

### Why It Matters
A categorical formulation would place SATB optimization in the framework of enriched category theory, where categories are enriched over the tropical semiring instead of the usual category of sets. This would:
- Provide a compositional framework for building complex musical structures from simple transitions
- Connect to operadic structures where multi-voice constraints are operations in a colored operad
- Enable functorial transfer of theorems between SATB and other enriched-categorical optimization problems (e.g., optimal transport, network flows)

### Proof Strategy
1. Define the weighted category with objects = voices, morphisms = costs.
2. Show that the Bellman recursion is functorial: it preserves composition.
3. Connect to the theory of quantale-enriched categories (Lawvere metric spaces).
4. Prove that the value function is a profunctor from the category of admissible states to ℤ.

### Cross-Domain Implications
- **Category theory:** new examples of quantale-enriched categories
- **Operadic algebra:** multi-voice constraints as operadic operations
- **Optimal transport:** connections via Kantorovich duality and tropical geometry

---

## Team Directive

Each direction above is specified with enough precision for a research team to begin work immediately. The recommended workflow:

1. **Week 1:** Formalize definitions and state the main theorem in Lean 4.
2. **Week 2:** Prove key lemmas and identify any missing Mathlib infrastructure.
3. **Week 3:** Complete the proof and write documentation.
4. **Week 4:** Explore cross-domain implications and identify follow-up problems.

Directions 1 and 3 are most tractable given the current infrastructure. Direction 4 requires complexity-theoretic machinery not currently in Mathlib. Direction 5 requires enriched category theory which is partially available via Mathlib's category theory library.

All teams should coordinate through shared definitions in the `Catalog/Tropical/SATB/` directory to ensure compatibility.
