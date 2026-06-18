## Mode: formalize + prove

Aristotle,

Do not treat this as a routine physics formalization. Treat it as the seed of a **machine-verified spectral theory of quantum matter**. The hydrogen atom is the unique place where analysis, representation theory, PDE, special functions, and quantum selection laws meet in a form rigid enough to formalize and rich enough to open a field. If you succeed, you will not merely formalize a textbook computation; you will create the first reusable Lean infrastructure for **exactly solvable quantum Hamiltonians**, and that infrastructure can propagate into scattering theory, atomic transitions, quantum information, and symmetry-driven spectral computation.

The catalog theorems listed are not directly on-point, but `hamiltonian_split` is a conceptual cue: the central idea is to **split the Hamiltonian into radial and angular pieces**, then certify each component formally. Use the existing symbolic notion of “Hamiltonian splitting” as inspiration for a mathematically serious operator decomposition theorem in Hilbert space.

---

# Primary Objective

Formalize a mathematically precise version of the hydrogen atom Hamiltonian and prove a certified spectral decomposition theorem strong enough to recover:

1. the discrete bound-state energies,
2. the angular eigenbasis via spherical harmonics,
3. the dipole transition selection rules.

Because the full self-adjoint spectral theorem for unbounded operators on `L²(ℝ³)` is heavy, you should choose the strongest theorem that is realistically formalizable in Lean 4 with Mathlib while still being genuinely nontrivial and field-opening.

The most promising path is to formalize the **separated eigenvalue problem** first, then package the spectral statement as a theorem about the point spectrum plus a conjectural/blueprint statement for the continuous spectrum if full operator-theoretic machinery is not yet available.

---

# Breakthrough Theorem Targets

## Theorem A: Angular momentum spectrum via spherical harmonics

Define the Laplace–Beltrami operator on the sphere, or an equivalent angular operator, and prove that spherical harmonics diagonalize it.

### Mathematical statement
For every `l : ℕ`, there exists a finite-dimensional subspace `Harm l` of functions on `S²` such that every `Y ∈ Harm l` satisfies
\[
\Delta_{S^2} Y = -\, l(l+1)\, Y,
\]
and
\[
\dim(Harm l) = 2l+1.
\]

If full manifold formalization is too ambitious, work with the classical associated Legendre/Fourier model:
\[
Y_l^m(\theta,\phi)=N_{l,m} P_l^{|m|}(\cos\theta)e^{im\phi}, \quad -l\le m\le l,
\]
and prove they satisfy the separated angular eigen-equations.

### Lean-oriented theorem signature
A realistic first formal target is:

```lean
theorem sphericalHarmonic_eigenvalue
  (l : ℕ) (m : ℤ) (hm1 : Int.natAbs m ≤ l) :
  angularOp (sphericalHarmonic l m)
    = (-(l : ℝ) * ((l : ℝ) + 1)) • (sphericalHarmonic l m)
```

A stronger finite-dimensionality target:

```lean
theorem sphericalHarmonic_orthogonal
  (l : ℕ) {m₁ m₂ : ℤ}
  (hm₁ : Int.natAbs m₁ ≤ l) (hm₂ : Int.natAbs m₂ ≤ l) :
  inner (sphericalHarmonic l m₁) (sphericalHarmonic l m₂)
    = if m₁ = m₂ then 1 else 0
```

And eventually:

```lean
theorem finrank_sphericalHarmonics (l : ℕ) :
  FiniteDimensional.finrank ℂ (HarmonicSubspace l) = 2 * l + 1
```

### Why this is a breakthrough
This creates a certified representation-theoretic bridge:
\[
\text{SO}(3)\text{-irreps} \leftrightarrow \text{quantum angular momentum eigenstates}.
\]
That is the reusable core needed not only for hydrogen, but for rigid rotor models, spin-orbit couplings, multipole expansions, and selection-rule automation.

---

## Theorem B: Radial hydrogen bound states and exact energy quantization

Formalize the radial Schrödinger equation for the Coulomb potential and prove existence of exact bound-state eigenfunctions with energies
\[
E_n = -\frac{1}{2n^2}
\quad \text{(in atomic units)}
\]
or equivalently a scaled variant depending on your Hamiltonian normalization.

The user prompt says `{-1/n²}`. That is fine if you normalize the Hamiltonian accordingly; be explicit and consistent.

### Mathematical statement
For each `n ≥ 1`, `0 ≤ l ≤ n-1`, and `-l ≤ m ≤ l`, there exists a nonzero eigenfunction
\[
\psi_{n,l,m}(r,\theta,\phi)=R_{n,l}(r)Y_l^m(\theta,\phi)
\]
such that
\[
H \psi_{n,l,m} = -\frac{1}{n^2}\psi_{n,l,m}
\]
for the chosen normalized hydrogen Hamiltonian.

### Lean-oriented theorem signature
A realistic formal target:

```lean
def hydrogenEnergy (n : ℕ+) : ℝ := -1 / ((n : ℝ)^2)

theorem hydrogen_bound_state_exists
  (n : ℕ+) (l : ℕ) (hl : l < n) (m : ℤ) (hm : Int.natAbs m ≤ l) :
  ∃ ψ : HydrogenState,
    ψ ≠ 0 ∧
    hydrogenHamiltonian ψ = (hydrogenEnergy n) • ψ
```

A more explicit separated-state version:

```lean
theorem hydrogen_separated_eigenstate
  (n : ℕ+) (l : ℕ) (hl : l < n) (m : ℤ) (hm : Int.natAbs m ≤ l) :
  let ψ := hydrogenEigenstate n l m
  hydrogenHamiltonian ψ = (hydrogenEnergy n) • ψ
```

Degeneracy theorem:

```lean
theorem hydrogen_energy_degeneracy
  (n : ℕ+) :
  FiniteDimensional.finrank ℂ (eigenspace hydrogenHamiltonian (hydrogenEnergy n))
    = (n : ℕ)^2
```

If full eigenspace formalization is too ambitious, prove the combinatorial degeneracy count from the separated family:

```lean
theorem hydrogen_degeneracy_count
  (n : ℕ+) :
  ∑ l in Finset.range n, (2 * l + 1) = (n : ℕ)^2
```

paired with linear independence of the corresponding eigenstates.

### Why this is a breakthrough
This turns exact quantum solvability into a formal algebra-analysis artifact. Once the Coulomb problem is certified, the path opens to perturbation theory, Stark/Zeeman splittings, and eventually certified symbolic quantum chemistry.

---

## Theorem C: Spectrum decomposition blueprint

The ambitious theorem is the full spectral statement:
\[
\sigma(H)=\{-1/n^2 : n\in \mathbb N_{>0}\}\cup [0,\infty).
\]

This is likely too large in one cycle unless unbounded self-adjoint operator theory is already available in your environment. So split it into a certified theorem and a blueprint theorem.

### Certified partial theorem
Prove that every `-1/n²` lies in the point spectrum, and that no positive number is an `L²` eigenvalue for the separated radial equation.

### Lean-oriented theorem signature
```lean
theorem hydrogen_discrete_spectrum_mem_pointSpectrum
  (n : ℕ+) :
  hydrogenEnergy n ∈ pointSpectrum hydrogenHamiltonian
```

and

```lean
theorem hydrogen_no_positive_L2_eigenvalue
  (E : ℝ) (hE : 0 < E) :
  E ∉ pointSpectrum hydrogenHamiltonian
```

If `pointSpectrum` for your operator model is unavailable, use an existential eigenvector formulation.

### Blueprint full theorem
```lean
theorem hydrogen_spectrum
  :
  spectrum ℂ hydrogenHamiltonian
    = {z : ℂ | (∃ n : ℕ+, z = hydrogenEnergy n) ∨ 0 ≤ z.re ∧ z.im = 0}
```

or in a real/self-adjoint encoding.

### Why this is revolutionary
The full theorem would be one of the first machine-checked exact spectral classifications for a physically fundamental PDE operator. That is not incremental formalization; it is a prototype for **verified mathematical physics**.

---

## Theorem D: Dipole transition selection rules

Formalize the electric dipole operator and prove the standard selection rules
\[
\Delta l = \pm 1,\qquad \Delta m \in \{0,\pm1\}
\]
for nonzero matrix elements.

### Mathematical statement
For hydrogen eigenstates `ψ_{n,l,m}`, the matrix element
\[
\langle \psi_{n',l',m'},\, x_i \psi_{n,l,m}\rangle
\]
vanishes unless the angular momentum quantum numbers satisfy the dipole selection constraints.

### Lean-oriented theorem signature
An implementable version:

```lean
theorem dipole_selection_rule
  (n n' : ℕ+) (l l' : ℕ)
  (hl : l < n) (hl' : l' < n')
  (m m' : ℤ)
  (hm : Int.natAbs m ≤ l) (hm' : Int.natAbs m' ≤ l') :
  dipoleMatrixElem n l m n' l' m' ≠ 0 →
    (l' = l + 1 ∨ l + 1 = l') ∧ (m' - m = 0 ∨ m' - m = 1 ∨ m' - m = -1)
```

A sharper vanishing theorem is better:

```lean
theorem dipole_matrixElem_eq_zero_of_forbidden
  (n n' : ℕ+) (l l' : ℕ)
  (m m' : ℤ) :
  ¬ ((l' = l + 1 ∨ l + 1 = l') ∧ (m' - m = 0 ∨ m' - m = 1 ∨ m' - m = -1)) →
  dipoleMatrixElem n l m n' l' m' = 0
```

### Why this matters
This is where spectral theory meets observable physics. A formal proof of selection rules is the first step toward certifying spectroscopy, radiative transition graphs, and symmetry-constrained quantum algorithms.

---

# Recommended Formalization Architecture

## Core definitions to create
You will likely need a staged architecture.

1. **Angular side**
   - `associatedLegendre : ℕ → ℕ → ℝ → ℝ`
   - `sphericalHarmonic : ℕ → ℤ → SphereFun ℂ`
   - `angularOp : SphereFun ℂ → SphereFun ℂ`

2. **Radial side**
   - `radialHydrogenOp : ℕ → (ℝ → ℂ) → (ℝ → ℂ)`
   - `radialHydrogenWF : ℕ+ → ℕ → ℝ → ℂ`
   - Laguerre-polynomial infrastructure if available, otherwise define enough recursively.

3. **Separated states**
   - `hydrogenEigenstate : ℕ+ → ℕ → ℤ → HydrogenState`

4. **Matrix elements**
   - `dipoleMatrixElem : ℕ+ → ℕ → ℤ → ℕ+ → ℕ → ℤ → ℂ`

5. **Spectral wrappers**
   - a bounded surrogate operator on finite truncations, or
   - a custom `Eigenpair` predicate if full operator theory is too heavy:
     ```lean
     def IsEigenpair (T : V → V) (μ : 𝕜) (v : V) : Prop :=
       v ≠ 0 ∧ T v = μ • v
     ```

This surrogate route is strongly recommended if unbounded operators are a bottleneck.

---

# Proof Strategy Options

## Strategy A: Separation-of-variables first, operator theory later
This is the most promising route.

### Step 1
Define the hydrogen Hamiltonian formally in spherical coordinates as a **split operator**
\[
H = H_{\mathrm{radial}} + \frac{1}{r^2}L^2
\]
or an equivalent separated expression on product-form test functions.

Use `hamiltonian_split` as a conceptual template: prove a new theorem of the form
```lean
theorem hydrogen_hamiltonian_split
  (R : RadialFun) (Y : SphereFun ℂ) :
  hydrogenHamiltonian (separatedState R Y)
    = separatedState (radialPart ... R) Y
      + separatedState (... R) (angularOp Y)
```

### Step 2
Prove the angular eigenvalue equation for `sphericalHarmonic l m`.

### Step 3
Prove the radial ODE solution theorem, likely via explicit Laguerre identities and direct substitution.

### Step 4
Assemble the separated eigenstate theorem.

### Why this is best
It minimizes dependence on hard functional analysis and maximizes explicit symbolic proof. Lean is much better at certifying recursive special-function identities and algebraic substitutions than at full general unbounded spectral theory.

---

## Strategy B: Representation theory of SO(3) / Lie algebra route
This is conceptually deeper and ideal for future generalization.

### Step 1
Define angular momentum operators `Lx Ly Lz` and prove the commutation relations
\[
[L_x,L_y]=iL_z,\quad [L_y,L_z]=iL_x,\quad [L_z,L_x]=iL_y.
\]

### Step 2
Construct highest-weight representations and derive the spectrum of `L²` and `Lz`.

### Step 3
Identify spherical harmonics as the coordinate realization of these irreducibles.

### Why it is powerful
This route gives the cleanest proof of degeneracy and selection rules, and it generalizes to spin and Clebsch–Gordan theory.

### Why it is less immediately promising
It requires a more substantial Lie-theoretic interface in Lean and a robust analytic realization theorem. Use it as a second-layer architecture after Strategy A or in parallel for the angular sector only.

---

## Strategy C: Sturm–Liouville / orthogonal polynomial route
This is ideal for the radial problem.

### Step 1
Convert the radial equation to a Sturm–Liouville problem with effective potential
\[
V_{\mathrm{eff}}(r)=\frac{l(l+1)}{r^2}-\frac{2}{r}
\]
up to normalization.

### Step 2
Show square-integrability forces polynomial truncation of the confluent hypergeometric solution.

### Step 3
Deduce quantization `E_n = -1/n²`.

### Why it matters
This is the mathematically canonical derivation of discrete spectrum and can connect to formalized orthogonal polynomial theory.

### Risk
It may demand more asymptotic analysis than explicit substitution into known Laguerre formulas.

---

# Cross-Domain Connections You Should Explicitly Exploit

## 1. Representation theory and quantum information
Spherical harmonics are not just PDE artifacts; they are irreducible `SO(3)` modes. Formalizing them gives a certified language for:
- angular momentum coupling,
- quantum circuit symmetry sectors,
- spin selection constraints,
- tensor operator decompositions.

Application keywords: `SO(3) representations`, `Wigner-Eckart`, `quantum information`, `symmetry sectors`.

## 2. Special functions and exact symbolic computation
The hydrogen atom is the meeting point of:
- associated Legendre polynomials,
- Laguerre polynomials,
- confluent hypergeometric equations.

A Lean library for these identities would immediately impact:
- orthogonal polynomial verification,
- certified asymptotics,
- symbolic ODE solving.

Application keywords: `special functions`, `orthogonal polynomials`, `symbolic PDE`, `certified ODE`.

## 3. Spectral geometry and scattering
The split into radial and angular parts is the prototype for:
- Schrödinger operators on manifolds,
- inverse spectral problems,
- scattering phase shifts,
- black-hole perturbation theory in GR.

Application keywords: `spectral geometry`, `scattering theory`, `inverse problems`, `mathematical physics`.

## 4. Formal chemistry and spectroscopy
Selection rules are the first certified bridge from pure spectral theory to observable transition lines.

Application keywords: `spectroscopy`, `quantum chemistry`, `atomic transitions`, `selection rules`, `certified physics`.

---

# Concrete Theorem Package to Aim for This Cycle

If the full spectral theorem is too large, do not dilute the project. Instead produce the following high-value package:

1. `hydrogen_hamiltonian_split`
2. `sphericalHarmonic_eigenvalue`
3. `hydrogen_separated_eigenstate`
4. `hydrogen_degeneracy_count`
5. `dipole_matrixElem_eq_zero_of_forbidden`

That package is already field-opening if done cleanly.

---

# Suggested Lean 4 Theorem Statements

Use these as anchors, adapting types to available Mathlib infrastructure.

```lean
def hydrogenEnergy (n : ℕ+) : ℝ := -1 / ((n : ℝ)^2)
```

```lean
theorem hydrogen_hamiltonian_split
  (R : RadialFun) (Y : SphereFun ℂ) :
  hydrogenHamiltonian (separatedState R Y)
    = separatedState (radialHydrogenPart R Y) Y
      + separatedState (angularCouplingPart R) (angularOp Y)
```

```lean
theorem sphericalHarmonic_eigenvalue
  (l : ℕ) (m : ℤ) (hm : Int.natAbs m ≤ l) :
  angularOp (sphericalHarmonic l m)
    = (-(l : ℝ) * ((l : ℝ) + 1)) • (sphericalHarmonic l m)
```

```lean
theorem hydrogen_separated_eigenstate
  (n : ℕ+) (l : ℕ) (hl : l < n) (m : ℤ) (hm : Int.natAbs m ≤ l) :
  let ψ := hydrogenEigenstate n l m
  hydrogenHamiltonian ψ = (hydrogenEnergy n) • ψ
```

```lean
theorem hydrogen_degeneracy_count
  (n : ℕ+) :
  ∑ l in Finset.range n, (2 * l + 1) = (n : ℕ)^2
```

```lean
theorem dipole_matrixElem_eq_zero_of_forbidden
  (n n' : ℕ+) (l l' : ℕ) (m m' : ℤ)
  (hforbidden :
    ¬ ((l' = l + 1 ∨ l + 1 = l') ∧
       (m' - m = 0 ∨ m' - m = 1 ∨ m' - m = -1))) :
  dipoleMatrixElem n l m n' l' m' = 0
```

Stretch theorem:

```lean
theorem hydrogen_discrete_spectrum_mem_pointSpectrum
  (n : ℕ+) :
  hydrogenEnergy n ∈ pointSpectrum hydrogenHamiltonian
```

---

# How to Build on the Catalog

The catalog is sparse here, but still use it strategically.

- `hamiltonian_split` should motivate a new rigorous theorem named something like `hydrogen_hamiltonian_split`. The conceptual inheritance matters: split dynamics into tractable components.
- `angular_momentum_345` is not mathematically reusable as-is, but it signals that “angular momentum” is already a recognized semantic object in the repository. Use that naming bridge to establish a serious `angularMomentumOp`.
- The remaining catalog theorems are distant, so do not force false dependencies. Instead create a new reusable physics namespace that future cycles can extend.

---

# Deliverables

## Lean files
Create a coherent cluster, e.g.
- `Physics/Quantum/Hydrogen/Angular.lean`
- `Physics/Quantum/Hydrogen/Radial.lean`
- `Physics/Quantum/Hydrogen/Spectrum.lean`
- `Physics/Quantum/Hydrogen/SelectionRules.lean`

## Required documentation
Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems, each including:
1. exact theorem statement,
2. proof strategy,
3. dependency map,
4. cross-domain significance.

This is mandatory.

Recommended future directions to include:
- full self-adjoint operator framework for Coulomb Hamiltonians on `L²(ℝ³)`,
- Wigner–Eckart theorem formalization,
- Zeeman and Stark perturbation splittings,
- scattering states and continuous spectrum `[0,∞)`,
- Clebsch–Gordan decomposition and many-electron symmetry sectors.

Optional:
- `ARTICLE.md` explaining the mathematical architecture,
- `RESEARCH_PAPER.md` with theorem statements and proof sketches.

---

# Final directive

Be bold about scope, but ruthless about formal tractability. If the full theorem
\[
\sigma(H)=\{-1/n^2\}\cup[0,\infty)
\]
is too large this cycle, do **not** retreat to toy lemmas. Instead prove the exact separated eigenstate theorems and the dipole selection rules. That alone establishes a new formal bridge between spectral analysis, representation theory, and observable quantum physics.

Application keywords: `spectral theory`, `hydrogen atom`, `spherical harmonics`, `angular momentum`, `selection rules`, `SO(3) representations`, `special functions`, `Laguerre polynomials`, `Legendre polynomials`, `quantum spectroscopy`, `mathematical physics`, `formal verification`, `quantum chemistry`, `scattering theory`.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Physics
Research mode: prove
