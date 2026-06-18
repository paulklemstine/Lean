# Future Directions: Tropical Feedback Spectral Theory

Building on the formally verified equivalence between guarded feedback existence and
tropical cycle-mean conditions (see `Bridges/TropicalFeedback.lean`), we identify
five concrete next theorems at the same level of ambition.

---

## 1. Certified Karp Algorithm for Semantic Guardedness (Algorithmic Extraction)

**Statement**: Formalize Karp's O(n³) algorithm for computing the maximum cycle mean
of a weighted digraph, and prove its correctness relative to the
`AllClosedWalkWeightsNonpos` predicate.

```
theorem karp_computes_max_cycle_mean
    {n : ℕ} (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) :
    karpMaxCycleMean hn W ≤ 0 ↔ AllClosedWalkWeightsNonpos W
```

**Why it matters**: This turns the semantic guardedness check into a *certified
polynomial-time algorithm*. The proof extracts a verified decision procedure:
given a weight matrix, compute the max cycle mean and return a certificate
(either a positive cycle witness or a proof of nonpositivity).

**Approach**: Define Karp's formula `λ* = min_i max_{0≤k<n} (D_n(i) - D_k(i))/(n-k)`
where `D_k(i)` is the max-weight k-step walk from a source. Prove this equals
the true max cycle mean via the characterization through tropical matrix powers.

---

## 2. Traced Monoidal Functorial Dequantization (Categorical Generalization)

**Statement**: Lift the finite-matrix results to a functor between traced monoidal
categories, showing that the Maslov dequantization map preserves trace structure.

```
theorem dequantize_preserves_trace
    (C : Type*) [Category C] [MonoidalCategory C] [TracedMonoidalCategory C]
    (D : Type*) [Category D] [MonoidalCategory D] [TracedMonoidalCategory D]
    (F : C ⥤ D) [MonoidalFunctor F] :
    ∀ (f : X ⊗ U ⟶ Y ⊗ U), F.map (Tr f) = Tr (F.map f)
```

**Why it matters**: This would establish that dequantization is not merely an
entrywise operation on matrices but a *natural transformation* between semantic
frameworks. It connects finite combinatorics to the abstract categorical
infrastructure for feedback in programming language semantics.

**Approach**: Define the tropical traced monoidal category (objects = ℕ, morphisms =
real matrices, trace = tropical feedback operator). Show the log map is a
traced monoidal functor from the positive-reals category.

---

## 3. Tropical Feedback in Weighted Automata (Automata Theory Connection)

**Statement**: Show that the guardedness condition for the tropical feedback operator
coincides with the *convergence condition* for the star (Kleene closure) of a
weighted automaton over the max-plus semiring.

```
theorem weighted_automaton_convergence_iff_guarded
    {n : ℕ} (A : WeightedAutomaton (Fin n) ℝ) :
    A.starConverges ↔ AllClosedWalkWeightsNonpos A.transitionMatrix
```

**Why it matters**: Weighted automata over the tropical semiring are fundamental in
formal language theory, speech recognition, and optimization. This theorem would
provide a *uniform guardedness certificate* for all these applications: the
tropical spectral radius governs both semantic feedback and automaton convergence.

**Approach**: Define weighted automata over an arbitrary semiring, specialize to
max-plus, define the star operation via iterative closure. The convergence
condition is exactly that the transition matrix has nonpositive cycle mean.

---

## 4. Entropy Production Bound via Tropical Spectral Gap (Statistical Physics)

**Statement**: For a reversible Markov chain with transition matrix P, prove that
the entropy production rate is bounded below by the tropical spectral gap
of the log-transition matrix.

```
theorem entropy_production_ge_tropical_gap
    {n : ℕ} (P : Matrix (Fin n) (Fin n) ℝ)
    (hP : StochasticMatrix P) (hRev : DetailedBalance P π) :
    entropyProductionRate P π ≥ -cycleMean (fun i j => Real.log (P i j))
```

**Why it matters**: This connects the tropical spectral theory to thermodynamic
irreversibility. The cycle mean of log-transition probabilities measures how
far the system is from equilibrium in a tropical-geometric sense. A negative
cycle mean corresponds to positive entropy production (Second Law), while a
zero cycle mean characterizes reversible (equilibrium) dynamics.

**Approach**: Use the Donsker-Varadhan variational formula for entropy production,
combined with the dequantization inequality `trop(log P) ≤ log(P)`. The tropical
spectral radius provides a computable lower bound on the variational problem.

---

## 5. Tropical Lyapunov Functions for Discrete Control Systems (Control Theory)

**Statement**: For a max-plus linear dynamical system x(t+1) = W ⊗ x(t), prove
that the system is asymptotically stable iff the tropical spectral radius
(max cycle mean) is strictly negative, and construct an explicit tropical
Lyapunov function.

```
theorem tropical_stability_iff_spectral_radius
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ) :
    TropicalAsymptoticallyStable W ↔ AllClosedWalkWeightsNeg W

theorem tropical_lyapunov_exists
    {n : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (hW : AllClosedWalkWeightsNeg W) :
    ∃ V : (Fin n → ℝ) → ℝ, TropicalLyapunov V W
```

**Why it matters**: Max-plus linear systems arise in scheduling, manufacturing,
and transportation networks. The stability condition is precisely the uniqueness
condition for our feedback operator. This theorem would provide *certified
stability analysis* for discrete-event systems, with the Lyapunov function
constructible from the Kleene star potential.

**Approach**: Define the tropical Lyapunov function as `V(x) = max_i (x_i - x*_i)`
where x* is the unique fixed point from our uniqueness theorem. Show
`V(W ⊗ x) < V(x)` when `AllClosedWalkWeightsNeg W`, using the contraction
argument from `fixedPoint_eq_of_allClosedWalkWeightsNeg`.

---

## Cross-cutting themes

All five directions share a common structure: **the tropical spectral radius
(max cycle mean) serves as a universal certificate** for qualitative properties
across different mathematical domains. The formally verified core theorems in
`TropicalFeedback.lean` provide the foundational bridge that makes all five
connections precise and machine-checkable.
