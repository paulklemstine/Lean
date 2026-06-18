# Future Directions: Closure–Thermodynamic Computation Duality

## 1. Tropical Spectral Theory of Thermodynamic Schedulers

**Target theorem**: The dissipation profile matrix of a finite thermodynamic computation object admits a tropical eigenvalue decomposition, where tropical eigenvalues correspond to critical dissipation thresholds and tropical eigenvectors identify irreducible reversible subsystems.

**Concrete statement**:
```
For T : ThermoComp S n with D.numProfs closed sets, define
the (D.numProfs × n) tropical dissipation matrix M where
M[k][i] = T.dissip i (closedSet_k). Then the tropical rank
of M equals the number of irreducible reversible components,
and the tropical eigenvalues are the critical energy levels
separating reversible from irreversible dynamics.
```

**Proof strategy**: Build on the `reversible_irreversible_union` partition theorem. Define tropical rank as the maximum number of tropically linearly independent row vectors in M under min-plus. Show that reversible generators contribute zero rows, and irreversible generators contribute independent rows. Use the chain structure from `closure_chain_energy_bound` to bound the number of energy levels.

**Cross-domain connection**: This connects to tropical geometry (tropical Grassmannians), spectral graph theory (Laplacian eigenvalues as conductances), and quantum information (channel capacity via min-entropy).

---

## 2. Categorical Equivalence: Closure Thermodynamics ↔ Weighted Coalgebras

**Target theorem**: The category of finite separated thermodynamic computation objects with closure-compatible morphisms is equivalent to a full subcategory of weighted coalgebras over the min-plus semiring.

**Concrete statement**:
```
Define ThermoComp_cat with:
  Objects: Separated ThermoComp S n (varying S, fixed n)
  Morphisms: Functions f : S₁ → S₂ preserving closure and
             dissipation profiles

Then there exists a fully faithful functor
  F : ThermoComp_cat → WCoalg(ℕ_min-plus)
that identifies thermodynamic computation with weighted
coalgebraic behavior.
```

**Proof strategy**: Use `separated_realizations_equiv` as the key uniqueness engine — it shows that morphisms in ThermoComp_cat are determined by profile data. Map each ThermoComp to its profile coalgebra (states = closed sets, transition = profile map). Show fullness via the canonical realization theorem.

**Cross-domain connection**: Coalgebraic semantics (Rutten), weighted automata theory (Droste-Kuich-Vogler), and categorical systems theory (Spivak).

---

## 3. Learning Algorithm for Minimal Entropy Schedulers from Dissipation Queries

**Target theorem**: There exists a polynomial-time algorithm that, given oracle access to the dissipation function of an unknown separated ThermoComp, reconstructs the minimal realization using O(n · k²) queries, where k is the number of closed sets and n is the number of generators.

**Concrete algorithm**:
```
LEARN-THERMO-SCHEDULER(oracle D):
  1. Query D(i, ∅) for all i ∈ [n] → first profile p₀
  2. For each generator i, binary search for sets A where
     D(i, A) differs from p₀ → identify new closed sets
  3. Use closure structure: if A not closed, replace with cl(A)
  4. Repeat until no new profiles found
  5. Output: closed sets + profile matrix as the minimal realization
```

**Proof strategy**: Show correctness by proving the algorithm discovers all closed sets (using separation to ensure distinct profiles are found). Bound query complexity using the finite chain property from `closure_chain_energy_bound`. Prove optimality by information-theoretic lower bounds.

**Cross-domain connection**: Angluin's L* algorithm for DFA learning, exact learning from membership queries, active learning in ML, and system identification in control theory.

---

## 4. Finite Landauer Lower Bounds via Closure Rank

**Target theorem**: For any finite thermodynamic computation object T implementing a logical function f : Fin m → Fin m that is not a permutation, the minimum total dissipation satisfies:

```
∑_i dissip(i, S) ≥ log₂(m / |image(f)|)
```

where the bound is achieved by the minimal realization.

**Proof strategy**: Define the "closure rank" as the number of distinct non-trivial closed sets (excluding ∅ and univ). Show that each non-injective step in f forces a closure collapse, increasing energy by at least 1 (via `strict_closure_growth_implies_positive_energy`). The total dissipation lower bound follows from counting the number of information-destroying steps.

**Cross-domain connection**: Landauer's principle (kT ln 2 per bit erased), reversible computing (Bennett, Fredkin-Toffoli), thermodynamics of computation (Bennett 1973, Zurek 1989), and quantum error correction (stabilizer codes as closure systems).

---

## 5. Idempotent-Quantum Hybrid Dissipation Semantics

**Target theorem**: The closure-dissipation framework extends to quantum channels by replacing the min-plus semiring with the completely positive trace-preserving (CPTP) semiring, where:
- Closure = decoherence (quantum → classical coarse-graining)
- Zero-loss stratum = unitary (reversible) subgroup
- Dissipation profile = entropy production rate vector

**Concrete starting point**:
```
structure QuantumThermoComp (d n : ℕ) where
  cl : Matrix (Fin d) (Fin d) ℂ → Matrix (Fin d) (Fin d) ℂ  -- CPTP channel
  cl_idempotent : cl ∘ cl = cl
  dissip : Fin n → Matrix (Fin d) (Fin d) ℂ → ℝ
  -- von Neumann entropy production per generator
```

**Proof strategy**: Start with the qubit case (d=2) where the Bloch sphere provides geometric intuition. Show that the classical `ThermoComp` embeds faithfully into `QuantumThermoComp` via diagonal density matrices. Prove quantum separation implies classical separation, transferring all minimality results.

**Cross-domain connection**: Quantum thermodynamics (Goold et al. 2016), quantum channel discrimination, quantum error correction via stabilizer codes, and the resource theory of thermodynamics (Brandão et al. 2015).
