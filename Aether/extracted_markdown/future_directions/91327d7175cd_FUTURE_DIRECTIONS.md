# Future Directions: Cognitive Dynamical Systems and Beyond

## Synthesis

This research cycle established a rigorous mathematical framework for déjà vu as periodic orbits in discrete dynamical systems. We proved 16 theorems spanning foundational dynamics (pigeonhole inevitability of periodicity, orbit structure, contagious periodicity), concrete analysis (logistic map fixed points and invariance), and cross-domain connections (orbit entropy monotonicity, period-3 implies fixed point via IVT). The most promising cross-domain discovery is the **entropy–periodicity bridge**: the strict monotonicity of orbit entropy (Theorem 13) connects dynamical systems directly to Shannon information theory, suggesting that the "information content" of a cognitive state can be measured by the period of the orbit it belongs to.

The results connect naturally to several existing catalog theorems. The fixed point existence results extend the pattern of `exists_fixed_point_on_orbit_with_bound` (Bridges/HolographicProofRenormalization.lean) into the continuous dynamics setting. The periodicity propagation theorems (Theorems 5, 12) generalize `fixed_point_iterate'` from idempotent collapse theory (Speculative/IdempotentCollapse/Core.lean). The entropy bounds create a bridge to `fixed_point_entropy_upper_bound` (Speculative/AutoResearch/ThermodynamicClosureCore.lean), suggesting a unified theory of entropy in fixed-point dynamics.

The highest breakthrough potential lies in **Direction 1** (full Sharkovsky theorem formalization), which would be a landmark result in formal mathematics — Sharkovsky's theorem has never been fully formalized in any modern proof assistant. This would unlock a cascade of results about the structure of one-dimensional dynamics and provide a foundation for formalizing Li-Yorke chaos theory.

---

### Direction 1: Full Sharkovsky's Theorem in Lean 4

**Conjecture**: For any continuous function $f : [a,b] \to [a,b]$ and any $m, n \in \mathbb{N}$ with $m \triangleleft n$ in the Sharkovsky ordering, if $f$ has a periodic point of minimal period $m$, then $f$ has a periodic point of minimal period $n$.

**Test**: Formalize the Sharkovsky ordering as a total order on $\mathbb{N}$ in Lean 4, then prove the theorem for the first non-trivial cases: period 3 implies period 2 (we already have period 3 implies period 1), period 3 implies period 5, and period 3 implies period $2^n$ for all $n$. Each case can be independently verified.

**Impact**: This would be the first complete formalization of Sharkovsky's theorem in a modern proof assistant. It would provide a foundation for formalizing the entire theory of one-dimensional dynamics, including the Li-Yorke chaos theorem and the Feigenbaum universality constants. A successful formalization would demonstrate that deep dynamical systems theory is within reach of formal methods.

**Catalog References**: `Speculative/DejaVu/Advanced.lean` (period3_implies_fixed_point), `Speculative/DejaVu/Core.lean` (periodic_orbit_all_periodic, period_multiple_is_deja_vu)

**Proof Strategy**: The standard proof of Sharkovsky's theorem uses *Štefan's approach*: construct a directed graph (the "Markov graph") from the orbit, where vertices are intervals between consecutive orbit points and edges represent covering relations ($I \to J$ if $f(I) \supseteq J$). The key lemma is that a cycle of length $n$ in the Markov graph implies a period-$n$ orbit of $f$. The Sharkovsky ordering then emerges from the structure of possible Markov graphs. Required lemmas: (1) Intermediate Value Theorem (available in Mathlib as `intermediate_value_Icc'`), (2) Covering relation transitivity, (3) Markov graph cycle detection, (4) Period extraction from graph cycles.

**Domain Bridges**: Dynamical Systems <-> Graph Theory <-> Combinatorics

**Lineage**: Builds on period3_implies_fixed_point (Theorem 15) from this cycle, extending from a single implication to the full ordering.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Geometry of Cognitive Dynamics

**Conjecture**: The logistic map $f(x) = rx(1-x)$ tropicalizes to the piecewise-linear map $f^{\text{trop}}(x) = \min(r + x, r + x + (0 \ominus x))$ in the max-plus semiring, and the periodic orbits of $f^{\text{trop}}$ are in bijection with the periodic orbits of $f$ for generic parameters $r$.

**Test**: Implement the tropicalization of the logistic map. Compute periodic orbits of both $f$ and $f^{\text{trop}}$ for $r \in \{2.5, 3.0, 3.5, 3.83, 4.0\}$. Verify that periods match and that the tropical version correctly predicts the bifurcation diagram's qualitative structure.

**Impact**: This would establish a bridge between tropical geometry and one-dimensional dynamics — a connection that, to our knowledge, has not been explored. Tropical methods often simplify complex algebraic geometry to combinatorics; if they similarly simplify dynamical systems, this could provide new computational tools for chaos analysis. The connection to the catalog's existing tropical semiring work (EML/EMLTropicalSemiring.lean) would create a bridge between machine learning theory and cognitive dynamics.

**Catalog References**: `EML/EMLTropicalSemiring.lean`, `Speculative/AutoResearch/Tropical/QuantumTropicalDynamics.lean` (exists_normalized_qtrop_fixed_point), `Tropical/` (general tropical theory)

**Proof Strategy**: (1) Define tropicalization of polynomial maps using the valuation approach: replace multiplication with addition and addition with min/max. (2) Prove that fixed points of the tropical map correspond to valuations of fixed points of the algebraic map (Kapranov's theorem). (3) Extend to periodic orbits by iterating the tropicalization. (4) Handle the bifurcation structure by analyzing the piecewise-linear geometry of $f^{\text{trop}}$.

**Domain Bridges**: Dynamical Systems <-> Tropical Geometry <-> Machine Learning (via EML)

**Lineage**: Builds on logistic map results (Theorems 8-10) from this cycle, connecting to the existing tropical catalog.

**Ambition**: grand_challenge

---

### Direction 3: Stochastic Periodicity and Random Dynamical Systems

**Conjecture**: For the stochastic logistic map $x_{n+1} = r \cdot x_n \cdot (1 - x_n) + \sigma \cdot \xi_n$ where $\xi_n \sim \mathcal{N}(0,1)$, the expected recurrence time $\mathbb{E}[\min\{n \geq 1 : |x_n - x_0| < \varepsilon\}]$ scales as $\varepsilon^{-d}$ where $d$ is the correlation dimension of the attractor, for $\sigma$ sufficiently small.

**Test**: Simulate the stochastic logistic map for $r = 3.83$ (period-3 window) and $r = 4.0$ (chaos) with noise levels $\sigma \in \{10^{-6}, 10^{-5}, 10^{-4}, 10^{-3}\}$. Compute recurrence times for $\varepsilon \in \{10^{-4}, 10^{-3}, 10^{-2}, 10^{-1}\}$. Fit the scaling exponent $d$ and compare to the known correlation dimension.

**Impact**: Real cognitive dynamics are noisy. Understanding how noise affects periodicity detection is essential for any empirical application of the theory. If the scaling law holds, it provides a method to estimate the dimensionality of cognitive state spaces from EEG recurrence data — a tool of practical value in neuroscience.

**Catalog References**: `Speculative/DejaVu/Core.lean` (finite_implies_eventually_periodic), `Speculative/DejaVu/Advanced.lean` (logistic_maps_unit_interval)

**Proof Strategy**: (1) Formalize random dynamical systems using Mathlib's measure theory. (2) Prove that the invariant measure of the stochastic system converges to the deterministic invariant measure as $\sigma \to 0$ (structural stability). (3) Use the Poincaré recurrence theorem to bound recurrence times. (4) Connect to correlation dimension via the Grassberger-Procaccia algorithm.

**Domain Bridges**: Dynamical Systems <-> Probability Theory <-> Neuroscience

**Lineage**: Extends the deterministic results from this cycle to the stochastic setting.

**Ambition**: extension

---

### Direction 4: Cognitive Fixed Points in Neural Network Architectures

**Conjecture**: A feedforward neural network with ReLU activations and $n$ neurons has at most $O(2^n)$ fixed points under the self-map $x \mapsto \text{Net}(x)$ when input and output dimensions match, and this bound is tight. Recurrent neural networks (RNNs) with $n$ hidden units have periodic orbits whose maximal period grows exponentially in $n$.

**Test**: Construct explicit ReLU networks with 5, 10, 15, 20 neurons and count fixed points of the self-map. Verify the exponential bound. For RNNs, train on simple sequence tasks and detect periodic orbits in the hidden state dynamics using the period detection algorithm from this cycle.

**Impact**: This would connect formal dynamical systems theory to practical machine learning. Understanding the periodic orbit structure of neural networks could explain training oscillations (a well-known pathology), provide new initialization strategies (start near stable fixed points), and establish theoretical limits on the "creative capacity" of finite neural architectures. The bridge to the ML catalog (MachineLearning/) would be direct and novel.

**Catalog References**: `MachineLearning/` (general ML theory), `EML/TrainingDynamics.lean`, `Speculative/DejaVu/Core.lean` (finite_implies_eventually_periodic)

**Proof Strategy**: (1) For ReLU networks, use the piecewise-linear structure: each linear region can have at most one fixed point, and the number of linear regions is $O(2^n)$ (Montúfar et al., 2014). Formalize this counting argument in Lean 4. (2) For RNNs, apply the finite inevitability theorem (Theorem 7) with $S$ being the quantized hidden state space. (3) Prove the tightness of the bound by constructing explicit networks achieving $\Omega(2^n)$ fixed points.

**Domain Bridges**: Dynamical Systems <-> Machine Learning <-> Algebra

**Lineage**: Directly extends the finite inevitability theorem (Theorem 7) and orbit structure results from this cycle.

**Ambition**: extension

---

### Direction 5: Formal Feigenbaum Universality

**Conjecture**: The Feigenbaum constants $\delta \approx 4.669$ and $\alpha \approx 2.502$ can be characterized as fixed points of a functional renormalization group operator $\mathcal{R}$, and the first several digits can be formally verified by computing $\mathcal{R}^n$ applied to the logistic map and extracting the ratios of successive period-doubling bifurcation points.

**Test**: Compute the bifurcation points $r_n$ for period-$2^n$ orbits of the logistic map for $n = 1, \ldots, 15$. Compute the ratios $(r_{n-1} - r_{n-2}) / (r_n - r_{n-1})$ and verify convergence to $\delta$. Formally verify the first 3 decimal places by interval arithmetic in Lean 4.

**Impact**: Feigenbaum universality is one of the most remarkable discoveries in nonlinear dynamics: the constants $\delta$ and $\alpha$ are universal across all one-dimensional maps undergoing period-doubling cascades. A formal verification would be a significant milestone, connecting to the renormalization group ideas in `Bridges/HolographicProofRenormalization.lean` and establishing a bridge between formal methods and mathematical physics.

**Catalog References**: `Bridges/HolographicProofRenormalization.lean` (exists_fixed_point_on_orbit_with_bound), `Speculative/DejaVu/Advanced.lean` (logistic_maps_unit_interval, logistic_nontrivial_fixed_point)

**Proof Strategy**: (1) Define the period-doubling renormalization operator $\mathcal{R}[f](x) = \alpha f(f(x/\alpha))$ in Lean 4. (2) Prove that the logistic map's bifurcation sequence $r_n$ is monotone increasing and bounded (hence convergent). (3) Use interval arithmetic (Mathlib's `Interval` type or verified floating-point bounds) to compute rigorous bounds on $r_n$ for small $n$. (4) Extract the Feigenbaum ratio and verify 3 decimal places.

**Domain Bridges**: Dynamical Systems <-> Physics (Renormalization Group) <-> Number Theory

**Lineage**: Builds on the logistic map results (Theorems 8-10) and connects to the renormalization bridge theorems in the catalog.

**Ambition**: extension
