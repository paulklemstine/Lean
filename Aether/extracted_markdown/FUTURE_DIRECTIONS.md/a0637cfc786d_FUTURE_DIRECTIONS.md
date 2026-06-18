# Future Directions: Tropical Gravitational Dynamics

## Overview

This document outlines five concrete breakthrough research directions opened by the formalization of tropical gravitational dynamics — a framework that unifies min-plus algebra, causal propagation, discrete geometry, and fixed-point horizon theory into a single certified mathematical structure.

---

## Direction 1: Tropical Causal Cones as Shortest-Path Balls on Finite Graphs

**Hypothesis:** The "light cone" of a point in a tropical spacetime is exactly the sublevel set of the min-plus distance function from that point. On a finite weighted digraph with n vertices and edge weights W, the set of points reachable within tropical action cost ≤ R from source s is {v : dist_W(s, v) ≤ R}, and this set can be computed by iterated tropical transfer in at most n steps.

**Proof Strategy:**
1. Define bounded-path cost `pathCost W t s d` recursively as the minimum weight over all paths of length ≤ t from s to d.
2. Prove by induction on t that `(tropTransfer W)^t (indicator d)` at s equals `pathCost W t s d`.
3. Show that pathCost stabilizes after n steps (by pigeonhole: any shortest path on n vertices has length < n).
4. Define the tropical causal cone as `{d | pathCost W n s d ≤ R}` and show it equals the R-ball of the stabilized tropical distance.

**Cross-Domain Connections:**
- Bellman–Ford algorithm: the iteration is exactly Bellman–Ford relaxation.
- Causal structure in Lorentzian geometry: light cones become shortest-path balls.
- Reachability in network science: tropical causal cones encode accessibility thresholds.

**Concrete Next Step:** Formalize `pathCost` and the bridge theorem `tropTransfer_eq_pathCost` for `Fin n`-indexed graphs in Lean 4.

---

## Direction 2: Tropical Stationary Black Holes as Min-Plus Eigenvectors

**Hypothesis:** A "stationary tropical spacetime" is a fixed point of the tropical transfer operator up to a global additive shift — i.e., a tropical eigenvector. The tropical Schwarzschild solution should emerge as the unique (up to additive constant) eigenvector of a radially symmetric tropical transfer matrix with a mass parameter.

**Proof Strategy:**
1. Define a radially symmetric tropical transfer matrix on `Fin (n+1)` with entries encoding gravitational potential.
2. Use `eigenpair_of_normalized_fixed_point` from the existing catalog to connect normalized fixed points to tropical eigenpairs.
3. Show that for a specific mass-dependent potential, the eigenvector has a "horizon" structure: it is flat (constant) inside r = 2m and linearly growing outside.
4. Prove uniqueness of the tropical eigenvector (up to additive constant) using the irreducibility of the transfer matrix.

**Cross-Domain Connections:**
- Tropical spectral theory: Perron–Frobenius theory in the min-plus semiring.
- Stationary spacetimes in GR: Killing vectors become tropical eigenvector stationarity.
- PageRank and Markov chains: tropical eigenvectors as steady-state distributions.

**Concrete Next Step:** Construct an explicit 5×5 or 10×10 radial tropical transfer matrix, compute its tropical eigenvector numerically, and verify the horizon structure.

---

## Direction 3: Discrete Tropical Curvature from Failure of Additive Path Composition

**Hypothesis:** Define "tropical curvature" at a vertex as the defect of the triangle equality: κ(i) = radialCost(w, i-1, i+1) - radialCost(w, i-1, i) - radialCost(w, i, i+1). In flat space (constant weights), κ = 0. Near a "mass concentration" (a spike in weights), κ < 0, mimicking negative curvature / gravitational attraction. This gives a discrete tropical Gauss–Bonnet theorem: the sum of curvatures over a closed path relates to the total angular defect.

**Proof Strategy:**
1. Define κ(i) as above and prove κ(i) = 0 for constant weights (flat space).
2. For a single mass perturbation w(i₀) = M, w(k) = 1 otherwise, compute κ(i₀) = -M + 1 and show κ is zero elsewhere.
3. Prove a discrete tropical Gauss–Bonnet: Σ κ(i) over a "triangle" equals the defect from triangle equality.
4. Connect to the radialCost_triangle theorem: strict inequality ↔ nonzero curvature ↔ "gravitational lensing."

**Cross-Domain Connections:**
- Discrete differential geometry: Regge calculus, angle defects.
- Comparison geometry: CAT(0) and Alexandrov spaces via triangle comparison.
- Network curvature: Ollivier–Ricci curvature on graphs.

**Concrete Next Step:** Formalize the curvature defect κ and prove the flat-space vanishing theorem and the single-mass perturbation formula.

---

## Direction 4: Tropical Hawking Radiation as Boundary Fixed-Point Instability

**Hypothesis:** The tropical horizon fixed point `tropRadiusUpdate m (2m) = 2m` is stable under the absorbing dynamics (any r ≥ 2m collapses to 2m), but is *unstable* under perturbation of the mass parameter. Specifically, if m → m - ε, the fixed point shifts to 2(m-ε), and the "released" region [2(m-ε), 2m] escapes the horizon. This is the tropical analogue of Hawking radiation: evaporation of the horizon under mass loss.

**Proof Strategy:**
1. Prove that `tropRadiusUpdate (m-ε) r = 2(m-ε)` for r ∈ [2(m-ε), 2m] when ε > 0 — i.e., points that were previously absorbed now escape.
2. Define a "radiation flux" as the measure (length) of the escaping interval: flux = 2ε.
3. Show that flux is proportional to the mass change, giving a tropical Stefan–Boltzmann law.
4. Iterate: define a discrete evaporation sequence m_t = m - t·ε and show the horizon shrinks to zero in finite time.

**Cross-Domain Connections:**
- Black hole thermodynamics: Hawking temperature and evaporation.
- Bifurcation theory: parameter-dependent fixed points and their stability.
- Control theory: reachable set expansion under parameter perturbation.

**Concrete Next Step:** Formalize the escape interval theorem and the linear flux formula.

---

## Direction 5: Sheaf-Theoretic Tropical Spacetime Gluing

**Hypothesis:** Different "patches" of a tropical spacetime (e.g., interior, exterior, horizon) can be formalized as sections of a sheaf of tropical semirings over a topological space (or a finite poset approximating it). The gluing axiom ensures that locally consistent tropical metrics patch together into a global tropical geometry. The horizon becomes the sheaf-theoretic boundary where the restriction maps change character.

**Proof Strategy:**
1. Define a presheaf of tropical function spaces on a finite poset (e.g., {interior, horizon, exterior} with the obvious ordering).
2. Assign to each open set the space of tropical functions (ℕ → ℝ or Fin n → ℝ) satisfying local evolution equations.
3. Prove the gluing axiom: if sections agree on overlaps (e.g., the horizon value matches between interior and exterior), they extend to a unique global section.
4. Show that the tropical Schwarzschild solution is a global section of this sheaf, with the horizon as the unique gluing point.

**Cross-Domain Connections:**
- Algebraic geometry: structure sheaves and schemes.
- Tropical geometry: tropical varieties as limits of algebraic varieties.
- Topological data analysis: sheaves on simplicial complexes for data fusion.

**Concrete Next Step:** Formalize the finite presheaf on a 3-element poset and prove the gluing axiom for tropical radial functions.

---

## Research Team Workflow

Each direction should be pursued by a team with the following roles:

- **Geometry Lead:** Defines the tropical metric/curvature objects and proves structural theorems (triangle inequalities, curvature defects, sheaf axioms).
- **Dynamics Lead:** Proves monotonicity, stability, and convergence of evolution operators. Handles the iterated dynamics and fixed-point analysis.
- **Spectral Lead:** Explores tropical eigenpairs, transfer operators, and their connection to stationary spacetimes. Connects to existing `eigenpair_of_normalized_fixed_point`.
- **Physics Lead:** Ensures all formal theorems have meaningful physical interpretations. Guards against empty metaphors. Proposes new theorem targets based on physical intuition.

**Validation Protocol:** Before formalizing any theorem, test it computationally on 3–5 explicit examples (constant potential, step potential, random weights, Fin 3/4/5 graphs). Use `#eval` in Lean or Python scripts to discover sharper statements.

---

## Priority Ordering

1. **Direction 1** (Causal cones = shortest paths): Most immediately formalizable, builds directly on existing `tropTransfer` and `graphEvolve`. High impact as the crown jewel bridge theorem.
2. **Direction 3** (Tropical curvature): Novel and conceptually deep, with clear formalization path via `radialCost`.
3. **Direction 2** (Stationary black holes as eigenvectors): Connects to existing spectral infrastructure, but requires more Mathlib machinery for irreducibility.
4. **Direction 4** (Tropical Hawking radiation): Elegant and physically suggestive, relatively easy to formalize.
5. **Direction 5** (Sheaf-theoretic gluing): Most ambitious, requires category-theoretic infrastructure, but opens the door to tropical algebraic geometry of spacetimes.
