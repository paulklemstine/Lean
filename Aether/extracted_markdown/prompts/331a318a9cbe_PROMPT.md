Formalize a precise bridge theorem between Vietoris–Rips graph filtrations and a tropical max valuation on edge birth times, staying as close as possible to existing verified APIs and avoiding unfinished categorical abstraction unless it is already supported by imported files.

Primary file to create: `Catalog/Bridges/RipsTropicalThreshold.lean`.

Mathematical goal:
For a finite pseudometric space `(α, dist)` with `[Fintype α] [DecidableEq α]`, define the tropical edge-birth threshold
`edgeBirthSup : WithBot ℝ := Finset.sup ...` 
from the set of all pairwise distances `dist x y` over ordered pairs with `x ≠ y` (or unordered pairs if that is substantially easier in Lean). Then prove that for any scale `ε`:
1. `ripsGraph α ε = ⊤` iff every distinct pair satisfies `dist x y ≤ ε`.
2. The latter is equivalent to `edgeBirthSup ≤ ε`.
3. Therefore `ripsGraph α ε = ⊤ ↔ edgeBirthSup ≤ ε`.
4. If `simplexCount α ε` is defined as the number of ordered distinct edges present in the Rips graph at scale `ε`, then prove monotonicity in `ε` and the saturation criterion
   `simplexCount α ε = Fintype.card α * (Fintype.card α - 1) ↔ edgeBirthSup ≤ ε`.

Key constraints:
- Do not leave theorem proofs incomplete.
- Prefer elementary, robust definitions over ambitious categorical bundling.
- If `WithBot ℝ` supremum machinery is awkward, you may instead first define a real-valued threshold as a `Finset.sup` over distances with a nonempty/default handling strategy appropriate for finite spaces, and only then state a lightweight tropical reformulation into `WithBot ℝ` if that part is straightforward.
- If the existing tropical valuation object in `Bridges/CategoricalTropicalUltrametric.lean` is cumbersome, use only the pieces that are actually needed; do not force a functor structure unless all laws can be proved cleanly.

Suggested theorem structure:
- `edgeMem_ripsGraph_iff`
- `ripsGraph_eq_top_iff`
- `edgeBirthSup_le_iff`
- `rips_complete_iff_edgeBirthSup_le`
- `simplexCount_monotone`
- `simplexCount_eq_max_iff`
- optional: a corollary phrased as a tropical threshold statement using `WithBot ℝ`

Implementation advice:
- Build on the exact `ripsGraph` and monotonicity lemmas already in the Applications file.
- Keep counting definitions simple: count filtered ordered pairs `(x,y)` with `x ≠ y` and `dist x y ≤ ε`.
- Prove finite counting bounds and saturation by extensional reasoning on filtered finsets, not by heavy graph theory.
- Only after the threshold theorem is complete should you add any lightweight bridge-to-tropical wrapper.

Deliverable requirements:
- A single compiling Lean file with complete proofs.
- Include short module docstrings explaining the bridge theorem.
- No `sorry`.

This is a formalization task, not an exploratory one: prioritize a small number of complete, mathematically meaningful theorems over broader but fragile abstractions.