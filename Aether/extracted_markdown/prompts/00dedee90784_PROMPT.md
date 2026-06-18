Formalize a small, self-contained Lean 4 file for Vietoris–Rips graph edge counts, but make it API-driven and conservative.

Target file: `Catalog/Applications/PoincareData/RipsFunctorialEdgeCount.lean`

Primary instruction: build only on the existing definitions and lemmas in `Catalog.Applications.PoincareData.MetricFiltration`, especially `ripsGraph` and any monotonicity lemma such as `ripsGraph_mono`. Do not introduce `Sym2`-based counting or `Set.ncard` unless absolutely forced by the imported API. Prefer finite graph combinatorics via `SimpleGraph.edgeFinset` and cardinalities of finsets.

Mathematical scope:
1. For `[Fintype α] [DecidableEq α] [PseudoMetricSpace α]`, define
   `edgeCount (α) (r : ℝ) : ℕ := (ripsGraph α r).edgeFinset.card`.
2. Define `ripsProfile (α) : ℝ → ℕ := fun r => edgeCount α r`.
3. Prove `edgeCount_mono`:
   if `h : r ≤ s`, then `edgeCount α r ≤ edgeCount α s`.
   Strategy: use `ripsGraph_mono h` or the imported threshold monotonicity result to get edge inclusion, then deduce a finset-cardinality inequality. Use whatever graph-subgraph API is already present; keep the proof short and library-aligned.
4. Prove `ripsProfile_monotone : Monotone (ripsProfile α)`.
5. For `[Fintype β] [DecidableEq β] [PseudoMetricSpace β]`, let `f : α → β` be injective and nonexpanding, i.e. assume
   `hf_inj : Function.Injective f` and `hf_nonexp : ∀ x y, dist (f x) (f y) ≤ dist x y`.
   Prove a concrete edge-image lemma saying that any edge of `ripsGraph α r` maps to an edge of `ripsGraph β r`. Choose the statement form that best matches the existing graph API (for example on adjacency, or on membership in `edgeFinset`).
6. Prove `edgeCount_le_of_injective_nonexpanding : edgeCount α r ≤ edgeCount β r`.
   Strategy: define the induced map on edges using the previous lemma, prove injectivity using `hf_inj`, and compare finite cardinalities.

Important constraints:
- Keep the theorem package minimal: only definitions and the four results above.
- Do not attempt step-function structure, critical radii, persistence-style statements, or any classification theorem.
- Do not leave placeholders, `admit`, `sorry`, or truncated declarations.
- If the exact `SimpleGraph` edge API differs from expectations, adapt the statements to the available API, but preserve the mathematical content: monotonicity in `r` and domination under injective nonexpanding maps.
- Include concise module documentation explaining the invariant and the four main results.

Deliverable: a complete Lean file that compiles cleanly against the current catalog imports.