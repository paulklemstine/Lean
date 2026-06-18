# Future Directions: Closure–Cosmology Duality

## 1. Tropical Entropy and Cosmological Arrow-of-Time Monotones

**Goal**: Define a tropical entropy functional on the causal profile semimodule and prove it is monotone along the epoch ordering — giving a discrete, algebraically certified arrow of time.

**Key Idea**: The max-plus rank of the truncated profile semimodule at epoch $n$ is non-decreasing. Define $S(n)$ as the log of the number of extremal generators visible up to epoch $n$. The closure axioms and causal exchange force $S(n) \leq S(n+1)$. This is a discrete second law.

**Impact**: A purely algebraic, finite, certifiable entropy monotone for discrete spacetimes — independent of continuous thermodynamic assumptions.

**Concrete Next Steps**:
- Define `tropicalEntropy : ClosureHorizonProfile → ℕ → ℕ` as the profile rank of the time-$n$ truncation.
- Prove `tropicalEntropy_mono : ∀ n, tropicalEntropy P n ≤ tropicalEntropy P (n+1)`.
- Connect to existing Gibbs reconstruction: show that the tropical entropy lower-bounds the boundary partition entropy at each time slice.

---

## 2. Sheaf-Valued and Stochastic Closure Cosmologies

**Goal**: Generalize the closure operator from set-valued to sheaf-valued (over a site of causal neighborhoods) and from deterministic to stochastic (probability-weighted closures). Prove that the representation and reconstruction theorems lift to this setting.

**Key Idea**: Replace `cl : Set X → Set X` by a sheaf of sections over a Grothendieck site whose objects are causal diamonds. The horizon-growth functional becomes a sheaf cohomology rank. Stochastic closure replaces `cl S` by a probability measure on closed supersets of `S`, modeling quantum or thermal uncertainty in cosmological observation.

**Impact**: Opens a route to quantum cosmology reconstruction: the observability algebra becomes a quantum observable algebra, and the FRW reconstruction produces a quantum state space.

**Concrete Next Steps**:
- Define `SheafClosureCosmology` with `cl : Presheaf (Set X) CausalSite`.
- Prove a sheaf-theoretic representation theorem: sections of the sheaf form a module over the max-plus semiring.
- For the stochastic case, define `StochasticClosure : Set X → MeasureTheory.Measure (Set X)` and prove an expected-value reconstruction theorem.

---

## 3. Infinite/Filtered Limits and Continuum FRW Approximation

**Goal**: Take the limit of finite EML cosmologies as the number of observables and epochs grows. Prove that the limit object recovers a piecewise-linear approximation to the classical FRW scale factor $a(t)$.

**Key Idea**: A directed system of finite cosmologies $(X_n, \mathrm{cl}_n, \tau_n, H_n)$ with compatible inclusions defines a pro-finite cosmology. The profile matrices form an inverse system; their limit is an infinite matrix whose diagonal encodes a function $a : [0,T] \to \mathbb{R}_{\geq 0}$. The reconstruction theorem lifts to the limit, producing a piecewise-linear scale factor.

**Impact**: Bridges discrete algebraic cosmology to classical general relativity. The piecewise-linear scale factor can be compared with observational Hubble data.

**Concrete Next Steps**:
- Define `DirectedCosmologySystem` as a functor from a directed poset to `FiniteEMLCosmology`.
- Prove that the inverse limit of profile matrices exists and defines a continuous profile function.
- Show that the limit profile's diagonal converges to a monotone function $a : [0,\infty) \to \mathbb{R}_{\geq 0}$.
- Prove a quantitative approximation theorem: the $n$-epoch discrete FRW model approximates the limit to within $O(1/n)$ in a suitable metric.

---

## 4. Quantum/Idempotent Duality for Causal Semimodules

**Goal**: Establish a duality between idempotent (tropical/max-plus) semimodules and quantum (min-plus or complex) semimodules over causal profiles, and prove that the reconstruction theorems have dual versions.

**Key Idea**: The Maslov dequantization sends $(\mathbb{R}, +, \times)$ to $(\mathbb{R}_{\max}, \max, +)$ in the limit $\hbar \to 0$. Reverse this: for each tropical causal semimodule, define a "quantized" semimodule over $(\mathbb{C}, +, \times)$ parameterized by $\hbar > 0$. The quantized profile encodes interference effects between causal paths. In the classical limit $\hbar \to 0$, the quantized FRW reconstruction degenerates to the tropical one.

**Impact**: A mathematically precise bridge between algebraic cosmology and quantum gravity path integrals. The tropical rank becomes a semiclassical approximation to a quantum dimension.

**Concrete Next Steps**:
- Define `QuantizedCausalProfile (ℏ : ℝ) := Fin T → ℂ` with deformed addition `a ⊕_ℏ b = ℏ * log(exp(a/ℏ) + exp(b/ℏ))`.
- Prove that `QuantizedCausalProfile ℏ → CausalProfileVec T` as `ℏ → 0`.
- State and prove a quantized reconstruction theorem: the quantum FRW model is a path integral over discrete epoch graphs, weighted by profile amplitudes.

---

## 5. Cosmological Persistence and Barcode Reconstruction Invariants

**Goal**: Define a persistent homology theory for closure cosmologies and prove that the persistence barcode is a complete invariant of the causal semimodule up to isomorphism.

**Key Idea**: The filtration by time layers $\{x \in X : \tau(x) \leq n\}$ defines a filtered simplicial complex (or filtered closure system). The persistence module of this filtration is a graded module over the max-plus semiring. The barcode — the collection of birth-death pairs — encodes exactly the extremal generators of the causal semimodule.

**Impact**: Unifies topological data analysis with algebraic cosmology. Cosmic observational data (redshift surveys, CMB maps) can be analyzed with persistent homology, and the barcode directly determines the minimal epoch structure.

**Concrete Next Steps**:
- Define `CausalFiltration (C : FiniteEMLCosmology X) : ℕ → Set X` as `{x | C.τ x ≤ n}`.
- Prove that the closure-restricted filtration defines a persistence module.
- Show that the persistence barcode birth-death pairs biject with extremal generators of the profile semimodule.
- Prove `barcode_determines_minimal_FRW`: two cosmologies with isomorphic barcodes have isomorphic minimal FRW realizations.
- Connect to `exists_minimal_graph_from_rank_data` from the tropical persistence file: the barcode rank data is exactly the input needed for graph realization.

---

## Summary Table

| Direction | Mathematical Core | Physical Payoff | Difficulty |
|---|---|---|---|
| Tropical Entropy | Rank monotonicity of truncated semimodules | Discrete arrow of time | ★★☆☆☆ |
| Sheaf/Stochastic | Sheaf cohomology + measure-valued closure | Quantum observation theory | ★★★★☆ |
| Continuum Limit | Inverse limits of finite cosmologies | Classical FRW recovery | ★★★☆☆ |
| Quantum Duality | Maslov dequantization of profiles | Path integral cosmology | ★★★★★ |
| Persistence Barcodes | Filtered homology of causal complexes | TDA for cosmological data | ★★★☆☆ |

Each direction builds directly on the certified reconstruction framework established in this work: the finite EML cosmology datum, the profile semimodule, the discrete FRW realization, and the minimality/uniqueness theorems. The key insight — that closure-visible expansion history is a rank invariant — generalizes naturally to all five settings.
