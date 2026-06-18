# Future Directions: Modular Rigidity for Sparse Arithmetic Structures

This document outlines concrete next steps opened by the Sidon mod-3 rigidity theorems.
Each direction includes a precise theorem statement, motivation, proof strategies,
and cross-domain connections.

---

## 1. Generalize Mod-3 Rigidity to ZMod p for Odd Primes

### Theorem Statement
```
theorem sidon_modp_translation_rigidity
    (p : ℕ) (hp : Nat.Prime p) (hp_odd : p ≠ 2)
    (S : Finset ℤ) (hS : IsSidonSet S) :
    ∀ d : ℤ, d ≠ 0 → (d : ZMod p) ≠ 0 →
      ∀ a₁ ∈ S, ∀ a₂ ∈ S,
        a₁ + d ∈ S → a₂ + d ∈ S → a₁ = a₂
```

### Why It Matters
The mod-3 case is a prototype. The translation rigidity theorem holds for all nonzero d regardless of modular class, but the *classification* of which residues are quadratic residues mod p gives richer structure for odd primes. For p = 5, for example, the quadratic residues are {0, 1, 4}, and non-residues are {2, 3}. This creates a two-tier classification that could yield sharper counting bounds.

### Proof Strategies
1. **Direct generalization**: The Sidon uniqueness argument is independent of p; the modular classification is an independent layer that classifies the "type" of each unique translation.
2. **Quadratic reciprocity integration**: Use Legendre symbols to classify which differences fall in which residue class, then count constrained translations.

### Cross-Domain Connection
Connects to algebraic coding theory: the quadratic residue codes over GF(p) are among the best-studied error-correcting codes, and this direction would link their structure to sparse autocorrelation.

---

## 2. Arithmetic-Rigid Supports in Discrete Dynamical Systems

### Theorem Statement
```
def IsArithmeticRigid (S : Finset ℤ) (m : ℕ) : Prop :=
  ∀ d : ℤ, d ≠ 0 → (d : ZMod m) ≠ 0 →
    (S.filter (fun a => a + d ∈ S)).card ≤ 1

theorem sidon_implies_arithmetic_rigid
    (S : Finset ℤ) (hS : IsSidonSet S) (m : ℕ) (hm : m ≥ 2) :
    IsArithmeticRigid S m
```

### Why It Matters
Formalizing "arithmetic rigidity" as a first-class property creates a bridge to symbolic dynamics. A trajectory whose support is arithmetic-rigid has the property that each modularly classified step occurs at most once — this is a discrete analogue of aperiodicity in symbolic dynamics.

### Proof Strategies
1. **From Sidon**: The proof follows directly from `sidon_translation_at_most_one`, since the modular constraint is just a filter on the already-rigid translation map.
2. **Independent characterization**: Characterize arithmetic-rigid sets without the Sidon assumption. What other structural properties imply arithmetic rigidity?

### Cross-Domain Connection
Symbolic dynamics: rigid supports correspond to symbolic sequences with unique transition certificates. This could lead to formal verification of collision-freeness in robotic path planning.

---

## 3. Navigation Lower Bounds from Modularly Forbidden Steps

### Theorem Statement
```
theorem navigation_mod3_lower_bound
    (S : Finset ℤ) (hS : IsSidonSet S)
    (start goal : ℤ) (hstart : start ∈ S) (hgoal : goal ∈ S)
    (steps : List ℤ)
    (hsteps : ∀ s ∈ steps, ¬ (3 : ℤ) ∣ s)
    (hreach : start + steps.sum = goal) :
    steps.length ≥ 1
```

And the stronger:
```
theorem sidon_navigation_step_count
    (S : Finset ℤ) (hS : IsSidonSet S)
    (path : List ℤ) (hpath : ∀ i, path[i]? ∈ S)
    (hconsec : ∀ i, ∃ d, path[i+1]? = path[i]?.map (· + d)) :
    path.Nodup
```

### Why It Matters
If each step d in a navigation sequence is constrained to have d ≢ 0 mod 3, and the waypoints form a Sidon set, then each step's endpoint is uniquely determined. This gives a certified lower bound on the number of navigation moves needed to reach any target — a formal foundation for arithmetic motion planning.

### Proof Strategies
1. **Induction on path length**: At each step, the translation rigidity theorem guarantees the next waypoint is unique. Since the Sidon set is finite, the path cannot revisit waypoints, giving a length bound.
2. **Counting argument**: Each step "uses up" a unique pair from S × S, and the total number of such pairs is bounded by |S|² - |S|.

### Cross-Domain Connection
Robotics and autonomous systems: certified collision-free motion primitives. The formal proof that each step is uniquely determined translates directly to a safety guarantee for discrete planners.

---

## 4. Sparse-Spectral Principle: Unique Differences and Simulation Bounds

### Theorem Statement
```
theorem simulation_step_lower_bound
    (S : Finset ℤ) (hS : IsSidonSet S)
    (T : ℕ) (trajectory : Fin T → ℤ)
    (htraj : ∀ i, trajectory i ∈ S)
    (hdistinct : Function.Injective trajectory) :
    T ≤ S.card
```

### Why It Matters
This formalizes the principle that a Hamiltonian-like simulation on a Sidon support cannot revisit states. Combined with the translation rigidity theorem, each transition step is uniquely realized, meaning the simulation is maximally efficient (no redundant transitions). This is a discrete analogue of spectral exclusion in quantum simulation.

### Proof Strategies
1. **Pigeonhole**: If the trajectory visits |S| + 1 states, some state is visited twice. But the trajectory visits only elements of S, so T ≤ |S|.
2. **Translate to graph theory**: The "transition graph" on S has at most one edge per nonzero difference. The number of edges is at most |S|(|S|-1)/2, which bounds the simulation complexity.

### Cross-Domain Connection
Quantum simulation: the number of distinct Hamiltonian evolution steps on a sparse support is bounded by the autocorrelation structure. This could lead to formal lower bounds on Trotterization step counts.

---

## 5. Tropical Autocorrelation Rigidity

### Theorem Statement
```
def tropicalAutocorrelation (S : Finset ℤ) (d : ℤ) : WithTop ℤ :=
  if ∃ a ∈ S, a + d ∈ S
  then (S.filter (fun a => a + d ∈ S)).sup' sorry (fun a => (a : WithTop ℤ))
  else ⊤

theorem sidon_tropical_rigidity
    (S : Finset ℤ) (hS : IsSidonSet S) (d : ℤ) (hd : d ≠ 0) :
    (S.filter (fun a => a + d ∈ S)).card ≤ 1
```

### Why It Matters
Tropical geometry replaces addition with min and multiplication with addition. The tropical autocorrelation of a set replaces "count of pairs with difference d" with "min/max of elements with difference d." For Sidon sets, this tropical autocorrelation is trivially sharp (each difference is realized by at most one element), creating a "rigid one-skeleton" under tropical translation.

### Proof Strategies
1. **Direct from Sidon**: The filtered set has cardinality ≤ 1 by `sidon_translation_at_most_one`.
2. **Tropical geometry framework**: Develop a general theory of tropical autocorrelation for finite point sets, and show that Sidon sets are the unique minimizers of tropical autocorrelation energy.

### Cross-Domain Connection
Tropical geometry and optimization: Sidon sets as tropical rigid bodies. This could connect to tropical convexity and the theory of tropical linear spaces, offering a new perspective on sparsity in optimization.

---

## Summary Table

| Direction | Key Tool | Difficulty | Impact |
|-----------|----------|------------|--------|
| ZMod p generalization | Quadratic residues | Medium | High — unifies all primes |
| Arithmetic rigidity | Symbolic dynamics | Medium | High — new definition |
| Navigation bounds | Path combinatorics | Hard | Very high — applications |
| Simulation bounds | Graph theory | Medium | High — quantum simulation |
| Tropical rigidity | Tropical geometry | Hard | Very high — new framework |

Each direction builds on the formalized infrastructure of Sidon difference uniqueness
and modular classification, extending the certified rigidity philosophy to new domains.
