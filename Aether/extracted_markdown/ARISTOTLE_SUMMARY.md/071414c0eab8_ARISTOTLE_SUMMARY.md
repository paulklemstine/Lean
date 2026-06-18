# Summary of changes for run 2faf23b2-9b53-40ca-af9a-baa838240c6e
## Completed: Width Predicts Learnability Regime — Phase Transition

### Formally Verified Mathematics (19 theorems, 0 sorries)

**File:** `Catalog/Pythagorean/CDCLPathwidth/PhaseTransition.lean`

Built on the existing catalog infrastructure (`ClauseInteractionPathwidth/Theorems.lean` and `ConfigGraph/Theorems.lean`), introducing new mathematical structures and proving substantive theorems:

**New Definitions:**
- `RetainedProfile` — abstractly records retained clause counts at each decomposition stage
- `WidthControlledPolicy` — decomposition-guided retention strategy with soundness, completeness, and memory bound fields
- `memoryThresholdOfDecomp` — memory threshold for a decomposition (= width + 1)
- `worstCaseThreshold` — worst-case threshold over all CNFs of given pathwidth
- `BoundaryState` — Boolean labeling of frontier elements (transfer-matrix states)

**Key Theorems (all fully proven, verified with `lean_build`, clean axioms):**

1. **Structural Memory Envelope** (`retainAtCut_card_le_width_succ`): The retained clause set at any cut is bounded by `width + 1`. Proven via chain: `retainAtCut ⊆ bag → |retainAtCut| ≤ |bag| ≤ maxBagSize ≤ width + 1`.

2. **Width-Controlled Complete Policy** (`exists_widthControlledPolicy`): For any path decomposition of width ≤ k, there exists a sound, frontier-complete, memory-bounded policy with bound `k + 1`.

3. **Phase Transition Control Law** (`worstCaseThreshold_le_linear`, `worstCaseThreshold_mono`, `worstCaseThreshold_subadditive`): The worst-case threshold T*(k) = k + 1 is monotone and subadditive.

4. **Boundary State Count** (`card_boundaryState`, `boundaryStateCount_le_pow_of_width`, `card_labelings_le_pow`): The number of boundary states is exactly 2^n, bounded by 2^(k+1) for width k.

5. **Exponential Separation** (`exponential_separation`): T*(k) = k + 1 < 2^(k+1) for all k, proven by induction.

6. **Supporting theorems:** `retainAtCut_subset_bag`, `retainAtCut_subset_formula`, `frontier_bounded_state_space`, `frontier_captures_interactions`, `width_memory_duality`, plus more.

### Other Deliverables

- **ARTICLE.md** — Popular science article (~2300 words) on how structural bottlenecks govern the memory of reasoning. No mentions of formal verification or proof assistants.
- **RESEARCH_PAPER.md** — Full research paper with abstract, definitions, theorem statements with proof sketches, algorithm pseudocode, complexity analysis, computational experiments, and references.
- **FUTURE_DIRECTIONS.md** — 5 directions including 2 grand challenges (random CSP phase transition alignment, quantum transfer matrix / entanglement width bridge) and 3 solid extensions (treewidth generalization, runtime certification, optimality proof).
- **demo.py** — Interactive demo generating bounded-pathwidth CNFs, measuring memory thresholds, visualizing phase transitions with ASCII charts, showing exponential separation and monotonicity/subadditivity.
- **algorithms.py** — Implementation of `PathDecomposition`, `WidthControlledPolicy`, `BoundaryStateEnumerator`, and `BoundedMemorySolver` with docstrings and verification methods.
- **applications.py** — Cross-domain applications: pipeline circuit verification, job-shop scheduling, Bayesian network inference, network reliability, DNA sequence analysis.
- **PACKAGE.json** — JSON data package bundling all content for web templating.