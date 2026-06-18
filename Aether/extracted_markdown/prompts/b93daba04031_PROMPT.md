Formalize a concrete no-sorry theorem in the proof-complexity simulation preorder, staying strictly within the existing size-function framework from the catalog.

Target file: `Catalog/Logic/ProofComplexity/LadderDensity.lean`

Primary goal:
Define an explicit intermediate system between consecutive ladder systems and prove the three core simulation facts on systems.

Precise task:
1. Import the most relevant existing files for the simulation preorder and the ladder systems.
2. Define
   `interPowSize (k : ℕ) : ℕ → ℕ := fun n => if Even n then 2 ^ (n ^ (k+1)) else 2 ^ (n ^ k)`
   and
   `interPowSys (k : ℕ) := sysOfSize (interPowSize k)`
   using exactly the existing API style in the catalog.
3. For `k ≥ 1`, prove:
   - `powSystem k ≼ interPowSys k`
   - `¬ interPowSys k ≼ powSystem k`
   - `¬ powSystem (k+1) ≼ interPowSys k`
4. If and only if these are completed cleanly, derive a corollary expressing that `interPowSys k` is strictly between the two consecutive rungs in the preorder sense.

Proof strategy to follow:
- Use the existing theorem characterizing `sysOfSize` simulation in terms of eventual polynomial domination.
- For the easy lower simulation `powSystem k ≼ interPowSys k`, use pointwise comparison: on odd `n` they are equal, on even `n` the intermediate system is larger.
- For `¬ interPowSys k ≼ powSystem k`, argue by contradiction from the domination characterization. Restrict to infinitely many even `n`; there the intermediate system equals `2^(n^(k+1))`, so the assumed simulation would force the known impossible domination of the upper rung by the lower rung.
- For `¬ powSystem (k+1) ≼ interPowSys k`, again argue by contradiction and restrict to infinitely many odd `n`; there the intermediate system drops to `2^(n^k)`, so one again contradicts the established gap theorem.
- Reuse any existing lemmas giving large even and odd numbers, or prove tiny helper lemmas locally if needed.

Important scope control:
- Do not attempt broad degree-lattice packaging, order-type statements, or a generalized existential theorem unless the three system-level results are already complete.
- Do not delete working imports or supporting comments until the final theorem compiles.
- Avoid `simp` brittleness around parity by proving small explicit lemmas for `interPowSize` on even and odd inputs.
- If the exact existing gap theorem is named differently, adapt to the catalog’s actual theorem names, but keep the proof architecture unchanged.

Deliverable:
A complete Lean file with no `sorry`, centered on the concrete definitions and the three theorems above. Add a short module docstring explaining that this file proves a parity-glued intermediate system between `powSystem k` and `powSystem (k+1)` for `k ≥ 1`.