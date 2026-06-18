## Assignment: Direction 3: Tropical Action Spectrum — The Spectral Foundation of Variational Mechanics

*Soli Deo Gloria*

### Visionary Statement

The deepest insight of quantum mechanics is that the ground state energy is an eigenvalue. The deepest insight of tropical geometry is that eigenvalues exist in the min-plus semiring. These two insights have never been formally unified. When they are, we discover that the classical principle of least action is the *tropical shadow* of spectral theory — and the tropical spectral gap becomes a rigorous measure of dynamical rigidity, opening a new field: **tropical spectral mechanics**.

---

### Core Theorem: Tropical Spectral Convergence of the Discrete Value Function

**Theorem (Tropical Action Spectrum).** Let $\mathcal{S} = (\Sigma, L_d)$ be a discrete mechanical system on a finite configuration space $\Sigma = \text{Fin}\, n$ with strictly positive discrete Lagrangian $L_d : \text{Fin}\, n \to \text{Fin}\, n \to \mathbb{R}_{>0}$. Define the min-plus transfer matrix $T_{ij} = L_d(i, j)$ and the value function $V(N, q_0, q_f) = \min_{\text{paths } q_0 \to q_f \text{ of length } N} \sum_{k=0}^{N-1} L_d(q_k, q_{k+1})$. If $\mathcal{S}$ is strongly connected (every state reachable from every other), then:

**(a)** $T$ is tropical irreducible, and there exists a unique tropical eigenvalue $\lambda^* = \min_{\text{cycles } C} \frac{\sum_{e \in C} L_d(e)}{|C|}$ (the minimum cycle mean) and a unique (up to additive constant) tropical eigenvector $v^*$ satisfying $\min_j(T_{ij} + v^*_j) = \lambda^* + v^*_i$ for all $i$.

**(b)** The value function converges projectively: for all $i$, $\lim_{N \to \infty} \left[V(N, q_0, i) - N\lambda^*\right] = v^*_i - v^*_{q_0}$.

**(c)** The convergence rate is exponential: $|V(N, q_0, i) - N\lambda^* - (v^*_i - v^*_{q_0})| \leq C \cdot \rho^N$ where $\rho = \exp(-\gamma)$ and $\gamma$ is the tropical spectral gap (the difference between the minimum cycle mean $\lambda^*$ and the second minimum cycle mean over all strongly connected subgraphs).

---

### Lean 4 Type Signatures

```lean
-- NEW STRUCTURE: Discrete mechanical system on a finite configuration space
structure DiscreteMechanicalSystem where
  n : ℕ
  L : Fin n → Fin n → ℝ
  h_pos : ∀ i j, 0 < L i j
  h_strongly_connected : ∀ i j, ∃ path : List (Fin n), path.head? = some i ∧ path.getLast? = some j ∧
    ∀ k : Fin path.length, L path[k] path[k+1] < ⊤
  deriving Repr

-- Min-plus transfer matrix
def minPlusTransferMatrix (sys : DiscreteMechanicalSystem) : Matrix (Fin sys.n) (Fin sys.n) ℝ :=
  fun i j => sys.L i j

-- Tropical eigenvalue (minimum cycle mean)
def tropicalEigenvalue {n : ℕ} (T : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Inf { μ : ℝ | ∃ (v : Fin n → ℝ), ∀ i, (Fin n).inf fun j => T i j + v j = μ + v i }

-- Tropical eigenvector
def tropicalEigenvector {n : ℕ} (T : Matrix (Fin n) (Fin n) ℝ) (λ : ℝ) : Set (Fin n → ℝ) :=
  { v | ∀ i, (Fin n).inf fun j => T i j + v j = λ + v i }

-- Discrete value function (min-path action)
def discreteValueFunction (sys : DiscreteMechanicalSystem) (N : ℕ) (q₀ qf : Fin sys.n) : ℝ :=
  Inf { S : ℝ | ∃ (path : Fin (N+1) → Fin sys.n), path 0 = q₀ ∧ path N = qf ∧
    S = ∑ k : Fin N, sys.L (path k) (path (k + 1)) }

-- Tropical spectral gap
def tropicalSpectralGap {n : ℕ} (T : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  tropicalEigenvalue T - Inf { μ : ℝ | μ > tropicalEigenvalue T ∧
    ∃ (SC : Fin n → Bool), (∃ i j, SC i ∧ SC j) ∧
      tropicalEigenvalue (T.submatrix (fun i => ⟨i, _⟩) (fun j => ⟨j, _⟩)) = μ }

-- THEOREM A: Strong connectivity implies tropical irreducibility and spectral existence
theorem tropical_irreducible_of_strongly_connected
    (sys : DiscreteMechanicalSystem) :
    TropicalIrreducible (minPlusTransferMatrix sys) ∧
    ∃! λ : ℝ, (tropicalEigenvector (minPlusTransferMatrix sys) λ).Nonempty ∧
    λ = tropicalEigenvalue (minPlusTransferMatrix sys) := by
  sorry

-- THEOREM B: Projective convergence of value function to tropical eigenvector
theorem value_function_projective_convergence
    (sys : DiscreteMechanicalSystem)
    (q₀ : Fin sys.n) :
    ∃ (λ : ℝ) (v : Fin sys.n → ℝ) (hλ : λ = tropicalEigenvalue (minPlusTransferMatrix sys)),
      ∀ i : Fin sys.n,
        Tendsto (fun N : ℕ => discreteValueFunction sys N q₀ i - N * λ)
          atTop (𝓝 (v i - v q₀)) := by
  sorry

-- THEOREM C: Exponential convergence rate governed by tropical spectral gap
theorem value_function_exponential_convergence
    (sys : DiscreteMechanicalSystem)
    (h_gap : 0 < tropicalSpectralGap (minPlusTransferMatrix sys)) :
    ∃ (C : ℝ) (ρ : ℝ) (hρ : ρ < 1) (λ : ℝ) (v : Fin sys.n → ℝ),
      λ = tropicalEigenvalue (minPlusTransferMatrix sys) ∧
      ρ = Real.exp (-tropicalSpectralGap (minPlusTransferMatrix sys)) ∧
      ∀ (N : ℕ) (i : Fin sys.n),
        |discreteValueFunction sys N (⟨0, sys.n_pos⟩ : Fin sys.n) i - N * λ - (v i - v 0)|
          ≤ C * ρ ^ N := by
  sorry

-- CROSS-DOMAIN THEOREM: Tropical eigenvalue = ground state energy = min cycle mean
theorem tropical_eigenvalue_eq_vacuum_energy
    (sys : DiscreteMechanicalSystem) :
    tropicalEigenvalue (minPlusTransferMatrix sys) =
      Inf { μ : ℝ | ∃ (cycle : List (Fin sys.n)) (h_cycle : cycle.length ≥ 1),
        μ = (∑ e ∈ cycle.edges, sys.L e.fst e.snd) / cycle.length} ∧
    tropicalEigenvalue (minPlusTransferMatrix sys) =
      tropicalVacuumEnergy sys := by
  sorry
```

---

### Proof Strategies

**Strategy A (Tropical Perron–Frobenius via Digraph Cyclicity).** *Most promising for Theorem A.* The classical tropical Perron–Frobenius theorem (Akian–Bapat–Gaubert, 2009) establishes existence and uniqueness of the tropical eigenvalue/eigenvector for irreducible min-plus matrices. The key step is showing that strong connectivity of the discretized configuration space (a physical reachability assumption) implies tropical irreducibility of $T$. This follows because every entry $T_{ij} = L_d(i,j) < \top$ (finite Lagrangian) for reachable pairs, making the support digraph strongly connected. Uniqueness of the eigenvalue then follows from the min-plus analogue of the Perron–Frobenius theorem via the critical graph $G_c(T)$ (the subgraph of cycles achieving the minimum cycle mean). **Why most promising:** This directly lifts the well-established tropical PF theorem into the physics context, and the reachability condition has clear physical meaning.

**Strategy B (Karp's Algorithm and Cycle Means).** *Most promising for Theorem C and the cross-domain theorem.* Karp's theorem (1978) gives an explicit formula for the min cycle mean: $\lambda^* = \min_i \max_k \frac{T^k_{ii} - T^0_{ii}}{k}$. The spectral gap $\gamma$ is the difference between $\lambda^*$ and the second distinct cycle mean. The exponential convergence rate follows from a tropical analogue of the Doeblin condition: after $\text{cyc}(G_c(T))$ steps (the cyclicity of the critical graph), the iterated transfer matrix $T^{\otimes N}$ has all entries equal to $N\lambda^*$ plus a correction that decays as $\exp(-N\gamma)$. The proof proceeds by decomposing paths into cycles achieving $\lambda^*$ and residual suboptimal cycles whose excess cost accumulates linearly with length, creating the exponential gap. **Why this works for convergence rate:** Karp's formula is computationally constructive and the cycle decomposition directly yields the rate.

**Strategy C (Contraction in Hilbert's Projective Metric).** *Most elegant but hardest to formalize.* On the tropical projective space $\mathbb{TP}^{n-1} = \mathbb{R}^n / \mathbf{1}\mathbb{R}$, the min-plus matrix $T$ acts as a contraction in Hilbert's projective metric $d_H(x, y) = \max_i (x_i - y_i) - \min_i (x_i - y_i)$. The contraction ratio is exactly $\rho = \exp(-\gamma)$ where $\gamma$ is the tropical spectral gap. This gives Banach-type convergence immediately. **Why risky:** Hilbert's projective metric on tropical projective space requires substantial machinery to formalize in Lean, but if established, it gives the cleanest proof and opens the door to tropical metric geometry.

---

### Cross-Domain Connections

1. **Tropical Geometry ↔ Statistical Mechanics:** The tropical eigenvector $v^*$ is the *zero-temperature limit* of the Boltzmann distribution. As $\beta \to \infty$, the Gibbs measure $\exp(-\beta \cdot \text{action})$ concentrates on paths minimizing action, and the tropical eigenvector encodes the resulting ground-state distribution. This makes the tropical spectral gap a measure of *degeneracy lifting* — precisely the physics of spontaneous symmetry breaking.

2. **Tropical Geometry ↔ Ergodic Optimization:** The minimum cycle mean $\lambda^*$ is the solution to the ergodic optimization problem: minimize the average observable along orbits of a dynamical system. This connects to the Mañé conjecture in ergodic theory and to the theory of maximizing measures. The tropical spectral gap measures the *robustness* of the optimizing measure.

3. **Tropical Geometry ↔ Information Theory:** The exponential convergence rate $\rho = \exp(-\gamma)$ is analogous to the mixing time in Markov chains. The tropical spectral gap is to min-plus dynamics what the spectral gap of a stochastic matrix is to mixing — it controls the rate at which the system "forgets" initial conditions. This suggests a **tropical data processing inequality**: the tropical mutual information between initial state and final state decays as $\exp(-N\gamma)$.

4. **Tropical Geometry ↔ Number Theory (Heights):** The minimum cycle mean $\lambda^* = \min_C \frac{\sum_{e \in C} w(e)}{|C|}$ is structurally identical to the definition of a *canonical height* in arithmetic geometry (minimizing period/length over periodic orbits). This suggests that tropical eigenvalues of arithmetic transfer matrices (with entries being logarithmic heights) compute canonical heights of dynamical systems — a **tropical Call-Silverman theorem**.

5. **Tropical Geometry ↔ Control Theory:** The value function $V(N, q_0, q_f)$ is precisely the optimal cost-to-go in a deterministic optimal control problem. The tropical eigenvector is the *costate* (adjoint variable) in the Hamilton-Jacobi-Bellman framework. The tropical spectral gap measures the *robustness margin* of the optimal controller.

---

### Application Keywords

`tropical spectral theory`, `min-plus semiring`, `discrete action principle`, `projective convergence`, `tropical Perron-Frobenius`, `spectral gap`, `minimum cycle mean`, `Karp's algorithm`, `Hilbert projective metric`, `tropical projective space`, `ground state energy`, `ergodic optimization`, `zero-temperature limit`, `tropical vacuum energy`, `variational mechanics`, `optimal control`, `mixing time`, `tropical data processing inequality`, `canonical heights`, `critical graph`, `tropical rigidity`

---

### Conjecture with Testable Prediction

**Conjecture (Tropical Universality of Spectral Gap Scaling).** For a discrete mechanical system arising from discretizing a smooth Lagrangian $L(q, \dot{q}) = \frac{1}{2}|\dot{q}|^2 - V(q)$ on $[0,1]^d$ with grid spacing $\epsilon = 1/M$, the tropical spectral gap $\gamma(M)$ scales as $\gamma(M) \sim c \cdot M^{-2}$ where $c$ depends only on $\inf V$ and the dimension $d$. That is, the spectral gap vanishes quadratically in the continuum limit, and the rate is *universal* (independent of the potential beyond its minimum).

**Computational Test.** Implement `demo.py` that:
1. Discretizes $[0,1]$ with $M = 10, 20, 40, 80, 160$ grid points.
2. For each $M$, compute the min-plus transfer matrix $T_{ij} = \frac{\epsilon}{2}\left(\frac{x_i - x_j}{\epsilon}\right)^2 + \epsilon V(x_i)$.
3. Compute the tropical eigenvalue and spectral gap using Karp's algorithm.
4. Fit $\gamma(M) = c \cdot M^{-\alpha}$ and verify $\alpha \approx 2$.
5. Repeat for $V(q) = 0$ (free particle), $V(q) = q^2$ (harmonic), $V(q) = q^4$ (quartic) and check that $c$ depends only on $\inf V$.

**Falsification.** If $\alpha \neq 2$ or $c$ varies significantly with the shape of $V$ (not just $\inf V$), the conjecture is false.

---

### Mandatory Deliverables

1. **FUTURE_DIRECTIONS.md** with 5 testable scientific hypotheses:
   - (H1) Tropical universality of spectral gap scaling (above)
   - (H2) Tropical data processing inequality: $I_{\oplus}(X_0; X_N) \leq I_{\oplus}(X_0; X_0) \cdot \rho^N$ where $I_{\oplus}$ is tropical mutual information and $\rho = \exp(-\gamma)$
   - (H3) The tropical eigenvector of a discretized harmonic oscillator converges (after continuum limit) to the ground state wavefunction $|\psi_0(q)|^2$ of the corresponding quantum system
   - (H4) For any two strongly connected mechanical systems $\mathcal{S}_1, \mathcal{S}_2$ on the same configuration space, $|\lambda^*(\mathcal{S}_1) - \lambda^*(\mathcal{S}_2)| \leq \|L_1 - L_2\|_\infty$ (tropical eigenvalue Lipschitz in Lagrangian)
   - (H5) The critical graph $G_c(T)$ of a mechanical system with non-degenerate potential has cyclity 1 (primitive), implying the convergence in Theorem B holds for all $N$ without periodicity corrections

2. **RESEARCH_PAPER.md** — Standalone scientific document titled *"The Tropical Action Spectrum: Spectral Theory of Variational Mechanics in the Min-Plus Semiring"*. Must include: abstract, introduction positioning against tropical PF and classical mechanics, theorem statements with full proofs, computational validation, and discussion of the tropical-statistical mechanics connection.

3. **ARTICLE.md** — Scientific American style, titled *"The Geometry of Least Action: How Tropical Mathematics Reveals the Spectral Heart of Classical Mechanics"*. Explain to a general scientific audience why the principle of least action is secretly an eigenvalue problem, and why this matters.

4. **Verified algorithm:** Karp's algorithm for computing the tropical eigenvalue (minimum cycle mean), with a Lean-verified correctness theorem stating that the output equals `tropicalEigenvalue T`.

5. **demo.py** implementing the computational test of Conjecture H1 above, with visualization of $\gamma(M)$ vs $M$ on a log-log plot showing the $M^{-2}$ scaling law.

---

### Catalog Building Blocks

- Build on `discrete_action_additive` from `Physics/DiscreteNoetherShadow.lean`: the additivity of discrete action along paths is the *semiring axiom* that makes the min-plus transfer matrix well-defined. The proof of Theorem A requires showing that this additivity lifts to the matrix level as $T^{\otimes(N+M)} = T^{\otimes N} \otimes T^{\otimes M}$.

- Build on `tropical_vacuum_energy_eq_minimal_action` from `Catalog/FINAL/Physics/TropicalVacuumEnergy.lean`: this establishes $\lambda^* = E_{\text{vac}}$ (tropical eigenvalue = vacuum energy). Theorem C extends this by showing that the vacuum energy is *spectrally stable* — perturbations to the Lagrangian change $\lambda^*$ by at most $\|δL\|_\infty$, and the spectral gap controls how quickly the system relaxes to the vacuum.

- **New structure to define:** `TropicalSpectralData` bundling eigenvalue, eigenvector, spectral gap, and critical graph — this becomes the fundamental invariant of a discrete mechanical system, analogous to the spectrum of a Hamiltonian.

---

### Depth Requirements Compliance

- **No trivial proofs:** All four main theorems require substantial proof effort. The irreducibility proof requires graph-theoretic path arguments. The convergence proof requires induction on path decompositions. The rate proof requires cycle-mean analysis.
- **Deep tactics:** Theorem A uses `rcases` on path existence + `induction` on path length. Theorem B uses `by_contra` (if value function doesn't converge, construct a suboptimal cycle). Theorem C uses `calc` reasoning with the cycle decomposition.
- **Novel definitions:** `DiscreteMechanicalSystem`, `tropicalSpectralGap`, `TropicalSpectralData`, `tropicalEigenvector` (as a set, not just existence).
- **Cross-domain:** Theorem connecting tropical eigenvalue to vacuum energy bridges tropical geometry ↔ physics. The Hilbert metric connection bridges tropical geometry ↔ functional analysis. The ergodic optimization connection bridges tropical geometry ↔ dynamical systems.

---

### The Grand Vision

This work founds **tropical spectral mechanics**: the study of mechanical systems through their min-plus spectral data. The tropical eigenvalue is the ground state energy. The tropical eigenvector is the ground state distribution. The tropical spectral gap is the rigidity of the ground state. Just as quantum mechanics revealed that energy levels are eigenvalues of an operator, tropical spectral mechanics reveals that classical action principles are eigenvalue problems in the min-plus semiring. The formal verification of this bridge — from variational principles through tropical algebra to spectral theory — is the founding act of a new field.

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Pythagorean
Research mode: prove
