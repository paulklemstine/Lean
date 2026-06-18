Mode: prove

Title: Exact Ramanujan-Type Bound λ₂ = 1 / √3 for Berggren Orbit Graphs over 𝔽_p when p ≢ 1 [ZMOD 8]

Core mission:
Establish a genuinely structural theorem explaining the experimentally rigid phenomenon
that the normalized second eigenvalue of the Berggren orbit operator is exactly
`1 / Real.sqrt 3` for all tested primes `p` with `p % 8 ≠ 1`. The breakthrough is
not merely a spectral estimate: it is a new representation-theoretic bridge between
the Berggren dynamics of Pythagorean triples, finite orthogonal groups `O(2,1; 𝔽_p)`,
and explicit expander spectra. If successful, this opens a finite-arithmetic
Langlands-style program for nonlinear orbit graphs arising from classical Diophantine
generation laws.

Precise theorem target:
For each odd prime `p` with `p % 8 ≠ 1`, define the finite Berggren orbit graph
on the mod-`p` reduction of primitive isotropic vectors for the ternary quadratic
form `x^2 + y^2 - z^2`, with edges induced by the three Berggren generators and
their inverse two-branch structure. Show:

1. Every connected orbit component is a finite `(3,2)`-biregular bipartite graph.
2. The normalized adjacency/transfer operator `T_p` on each component has trivial
   top eigenvalue `1`.
3. Every nontrivial eigenvalue `λ` satisfies `|λ| ≤ 1 / Real.sqrt 3`.
4. Equality is attained, hence the exact second eigenvalue satisfies
   `λ₂(T_p) = 1 / Real.sqrt 3`.

This should be formulated first componentwise, then globally if all components are
isomorphic or spectrally identical.

Suggested Lean 4 theorem signatures:
You will likely need to introduce definitions first, but the endgame should look
approximately like this.

```lean
def berggrenOrbitVertex (p : ℕ) := {v : Fin 3 → ZMod p // primitive_isotropic_mod_p v}

def berggrenEdgeOp (p : ℕ) : Type := -- finite correspondence / adjacency data

def berggrenAdjMatrix (p : ℕ) : Matrix (berggrenOrbitVertex p) (berggrenOrbitVertex p) ℝ := ...

def berggrenNormAdjMatrix (p : ℕ) : Matrix (berggrenOrbitVertex p) (berggrenOrbitVertex p) ℝ := ...

def isThreeTwoBipartite (G : SimpleGraph V) : Prop := ...

def nontrivialSpectrum
  {n : Type*} [Fintype n] [DecidableEq n] (M : Matrix n n ℝ) : Finset ℝ := ...

theorem berggren_orbit_three_two_bipartite
  (p : ℕ) [Fact p.Prime] (hp8 : p % 8 ≠ 1) :
  ∀ C, C ∈ berggren_orbit_components p →
    isThreeTwoBipartite (berggren_component_graph p C)

theorem berggren_component_spectral_bound
  (p : ℕ) [Fact p.Prime] (hp8 : p % 8 ≠ 1) :
  ∀ C, C ∈ berggren_orbit_components p →
    ∀ λ ∈ nontrivialSpectrum (berggrenNormAdjMatrix_on_component p C),
      |λ| ≤ 1 / Real.sqrt 3

theorem berggren_component_exact_second_eigenvalue
  (p : ℕ) [Fact p.Prime] (hp8 : p % 8 ≠ 1) :
  ∀ C, C ∈ berggren_orbit_components p →
    second_largest_abs_eigenvalue (berggrenNormAdjMatrix_on_component p C)
      = 1 / Real.sqrt 3
```

If full matrix-spectrum formalization is too heavy, prove an equivalent operator-norm
statement on the orthogonal complement of constants:
```lean
theorem berggren_normAdj_restrict_opNorm
  (p : ℕ) [Fact p.Prime] (hp8 : p % 8 ≠ 1) :
  ‖restrict_to_mean_zero (berggrenMarkovOp p)‖ = 1 / Real.sqrt 3
```

Most promising proof architecture:
Strategy A: finite orthogonal group representation theory on permutation modules
This is the flagship route.

Step 1: Orbit identification and graph structure.
- Realize the Berggren action mod `p` as an action of a subgroup or correspondence
  inside `O(2,1; ZMod p)` on primitive isotropic lines/vectors.
- Use `berggren_orbit_unique_decomposition` to classify orbit components and
  `periodic_orbit_from_any` to pass from computational orbit generation to finite
  cycle/component existence.
- Prove the graph is bipartite by an invariant parity/sign character; prove the
  `(3,2)`-biregularity from the three forward Berggren moves and two inverse
  admissible predecessors on primitive isotropic states.

Step 2: Permutation representation decomposition.
- Let `V = ℝ[Ω]` for the finite orbit set `Ω`.
- Express `T_p` as an element of the Hecke algebra / double-coset algebra associated
  to the orthogonal-group action.
- Use `berggren_tropical_character_decomposition` as a catalog bridge: even if its
  current statement is in a “tropical character” idiom, extract from it a certified
  decomposition mechanism for the Berggren action into character-isotypic pieces.
- On each irreducible summand, compute the scalar or small matrix by which the
  adjacency correspondence acts.

Step 3: Character-theoretic eigenvalue extraction.
- Compute the trace of `T_p`, `T_p^2`, and possibly the double-coset class sums
  against irreducible characters of `O(2,1; 𝔽_p)`.
- Identify the nontrivial spectral radius as exactly `1/√3`.
- Prove the extremizing constituent exists when `p % 8 ≠ 1`.

Why this is most promising:
Because the exact constant `1/√3` strongly suggests a hidden rank-one harmonic
analysis phenomenon, not a brute-force combinatorial accident. Exact eigenvalues
on all primes in a congruence class almost always come from representation theory,
spherical functions, or a finite Hecke algebra with a tiny set of Satake parameters.

Strategy B: graph-theoretic nonbacktracking reduction plus quadratic form geometry
This route is more elementary and may formalize faster.

Step 1:
Construct the Berggren graph explicitly and prove every component is `(3,2)`-biregular
and bipartite.

Step 2:
Relate the normalized adjacency `T_p` to a nonbacktracking operator or Hashimoto-type
transfer operator on directed edges. For biregular bipartite graphs, there are
explicit algebraic relations between adjacency and nonbacktracking spectra.

Step 3:
Show the graph is in fact a finite quotient of the `(3,2)`-biregular tree associated
to isotropic directions of the quadratic space of signature `(2,1)`. Then the
universal cover spectral radius gives `1/√( (3-1)(2-1) ) = 1/√2` for some
normalizations, so be very careful: your exact normalization must be chosen to
match the observed `1/√3`. This mismatch is actually useful — it will force the
correct operator normalization and may reveal that `T_p` is not the plain adjacency
but a Berggren transfer operator with degree-normalization weighted only on the
3-branch side. Determine the precise normalization experimentally and formalize that one.

This route is valuable because it may derive the constant from tree harmonic analysis
without a full character table.

Strategy C: association scheme / closure algebra extraction
Use the catalog theorem
`closure_table_recovers_basis_and_spectrum`
to package the Berggren orbit relation into a finite coherent configuration.

Step 1:
Define closure relations generated by the Berggren moves on an orbit.

Step 2:
Use the closure table theorem to recover a canonical algebra basis and spectrum.

Step 3:
Show the closure algebra is 2- or 3-dimensional, forcing an explicit characteristic
polynomial with root `± 1 / √3`.

This route is especially attractive if the action yields only a few orbitals under
the diagonal group action. It could bypass explicit finite-group character tables
while still producing exact spectra.

Concrete intermediate lemmas to target:
1. Bipartition invariant:
```lean
theorem berggren_bipartition_exists
  (p : ℕ) [Fact p.Prime] (hpodd : p ≠ 2) :
  ∃ χ : berggrenOrbitVertex p → Fin 2,
    ∀ v w, berggren_adjacent p v w → χ v ≠ χ w
```

2. Degree formulas:
```lean
theorem berggren_outdegree_eq_three
  (p : ℕ) [Fact p.Prime] (hp8 : p % 8 ≠ 1) :
  ∀ v : berggrenOrbitVertex p, out_degree (berggrenDigraph p) v = 3

theorem berggren_indegree_eq_two
  (p : ℕ) [Fact p.Prime] (hp8 : p % 8 ≠ 1) :
  ∀ v : berggrenOrbitVertex p, in_degree (berggrenDigraph p) v = 2
```

3. Orthogonal-group realization:
```lean
theorem berggren_action_factors_through_O21
  (p : ℕ) [Fact p.Prime] :
  ∃ ρ : BerggrenGenerator →* Matrix (Fin 3) (Fin 3) (ZMod p),
    ∀ g, preserves_Q21 (ρ g)
```

4. Componentwise operator decomposition:
```lean
theorem berggren_permutation_module_decomposes
  (p : ℕ) [Fact p.Prime] :
  ∃ ι : Type, Fintype ι ∧
    (module_iso :
      berggren_perm_module p ≃ₗ[ℝ] ⨁ i : ι, irreducible_piece p i)
```

5. Exact spectral scalar on each irreducible:
```lean
theorem berggren_Tp_eigenvalue_on_irrep
  (p : ℕ) [Fact p.Prime] (i : irrep_index p) :
  ∃ μ : ℝ, action_on_irrep (berggrenMarkovOp p) i = μ • LinearMap.id ∧
    |μ| ≤ 1 / Real.sqrt 3
```

6. Extremizer existence:
```lean
theorem berggren_extremal_irrep_exists
  (p : ℕ) [Fact p.Prime] (hp8 : p % 8 ≠ 1) :
  ∃ i : irrep_index p,
    spectral_scalar p i = 1 / Real.sqrt 3 ∨
    spectral_scalar p i = - (1 / Real.sqrt 3)
```

Key catalog leverage:
- `berggren_orbit_unique_decomposition`
  Use this to avoid re-proving orbit normal forms from scratch. If it gives a canonical
  decomposition of Berggren orbits, use it to index connected components and to prove
  any graph-theoretic invariant is componentwise constant.
- `berggren_tropical_character_decomposition`
  This is likely the most important bridge theorem in the catalog. Reinterpret it as
  evidence that the Berggren action admits a certified decomposition into character-like
  pieces. Your task is to rigidify this into honest finite representation theory over `ℝ`
  or `ℂ`.
- `closure_table_recovers_basis_and_spectrum`
  If the orbit relation generates a finite adjacency algebra, this theorem may convert
  combinatorial closure data directly into spectral data.
- `periodic_orbit_from_any`
  Use this to certify finiteness/recurrence of orbit dynamics on finite state spaces and
  to justify decomposition into periodic components before introducing representation theory.
- `berggren_mod_q_fools_all_tests`
  This suggests pseudorandomness/equidistribution phenomena for Berggren reduction mod `q`.
  Spectral gap theorems are exactly what explain such fooling. Explicitly connect your
  `1/√3` bound to quantitative mixing or discrepancy on residue classes.

Cross-domain connections you should exploit:
1. Automorphic/Hecke theory:
Interpret `T_p` as a finite analog of a Hecke operator on isotropic directions in a
rank-one orthogonal setting. If successful, this is a toy Langlands correspondence for
Diophantine generation graphs.

2. Expander and pseudorandomness theory:
A sharp nontrivial eigenvalue bound implies mixing, counting lemmas, discrepancy, and
derandomization consequences for arithmetic pseudorandom generators built from Berggren
dynamics.

3. Hyperbolic geometry / Bruhat–Tits tree analogies:
`O(2,1)` is the algebraic shadow of hyperbolic symmetry. The Berggren graph may be a
finite quotient of a rank-one building/tree-like object. This gives conceptual force to
the exact spectral constant.

4. Arithmetic statistics of Pythagorean triples:
This theorem would turn “mod `p` Berggren dynamics” from a computational curiosity into
a controlled spectral machine for distribution of primitive triples modulo primes.

5. Tropical/EML/logic bridge:
If the closure algebra or character decomposition is accessible through the catalog’s
tropical or logic-flavored theorems, you may produce a new paradigm: exact arithmetic
spectra recovered from nonclassical closure semantics.

Application keywords:
Ramanujan graphs, biregular expanders, finite orthogonal groups, Hecke operators,
Pythagorean triples, Berggren dynamics, spectral gap, pseudorandomness, expander mixing,
association schemes, finite harmonic analysis, automorphic combinatorics, quadratic forms,
Bruhat–Tits tree, arithmetic dynamics.

What would count as a breakthrough:
- A fully formalized exact spectral theorem `λ₂ = 1 / √3`, not just a numerical bound.
- A conceptual explanation of why the congruence restriction `p ≢ 1 (mod 8)` is the
  exact arithmetic boundary.
- A reusable Lean framework for finite orthogonal-group orbit graphs and Hecke-type
  spectral operators.
- A bridge from Berggren orbit combinatorics to pseudorandomness theorems modulo primes.

If the exact theorem stalls, acceptable fallback hierarchy:
1. Prove every component is `(3,2)`-biregular bipartite.
2. Prove `|λ| ≤ 1 / √3` for all nontrivial eigenvalues.
3. Prove equality for an infinite family of primes.
4. Prove the exact eigenvalue set from a closure algebra or 2-point homogeneous action.

Implementation guidance in Lean:
- Use concrete finite types: `Fin 3 → ZMod p`, subtype for primitive isotropic vectors,
  finite sets of orbit representatives, matrices over `ℝ`.
- Separate algebraic definitions from spectral theorems: define graph, adjacency matrix,
  normalized operator, components, then prove structure lemmas.
- If full eigenvalue formalization is painful, use trace identities, minimal polynomial,
  or operator norm on finite-dimensional Euclidean space.
- For finite graphs, a matrix-based route may be more practical than abstract graph spectra.
- Exploit `Fintype`, `Matrix`, `LinearMap`, `DirectSum`, and finite-dimensional spectral
  tools already in Mathlib.

Deliverables:
1. A Lean file proving the strongest version you can reach.
2. Precise definitions for the Berggren mod-`p` orbit graph and normalized transfer operator.
3. At least one theorem linking the spectral bound to a mixing or pseudorandomness corollary.
4. A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete next breakthroughs, such as:
   - lift from finite-prime spectra to prime-power or adelic Berggren operators;
   - identify a true Hecke algebra controlling the Berggren correspondence;
   - prove a Ramanujan property for all congruence classes via local representation theory;
   - derive discrepancy bounds for `berggren_mod_q_fools_all_tests` from the new spectral gap;
   - construct a general Lean framework for orbit-graph harmonic analysis on algebraic groups.

Be bold: the target is not “another graph bound,” but a new arithmetic spectral theory of
Berggren generation.

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

Research domain: Speculative
Research mode: prove
