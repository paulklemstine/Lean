Fill the partial proof-complexity development by producing a complete, compiling Lean file for ladder-density between consecutive power-system degrees. Do not switch topics. The goal is to formalize a precise theorem of the following shape: for every k ≥ 1, there exists an explicit system interPowSys k such that powSystem k < interPowSys k and interPowSys k < powSystem (k+1) in the simulation-degree order, hence there exists a degree strictly between consecutive ladder rungs.

Requirements:
1. Work in the proof-complexity/simulation-degree framework already developed in the catalog.
2. Use the strongest existing references from Catalog/FINAL/ when available; otherwise use the relevant upstream files that define simulation, degrees, and powSystem.
3. Repair the previous malformed submission: every declaration must have a complete statement and proof, and the final file must have zero sorrys.
4. Prefer a self-contained new file such as Catalog/Logic/ProofComplexity/LadderDensity.lean, importing only the needed prerequisites.
5. Make the main theorem suite explicit and checkable. At minimum aim for Lean theorems analogous to:
   - a strengthened growth-gap lemma allowing parity-controlled witnesses, if not already available;
   - powSystem_lt_interPow : for k ≥ 1, powSystem k < interPowSys k;
   - interPow_lt_powSystem_succ : for k ≥ 1, interPowSys k < powSystem (k+1);
   - exists_strictly_between_powSystem : for k ≥ 1, ∃ S, powSystem k < S ∧ S < powSystem (k+1).
6. The proof strategy should follow the original direction: define interPowSys k by parity gluing (upper growth on one residue class, lower growth on the other), then use simulates_sysOfSize_iff and the known asymptotic gap between n^k and n^(k+1) to prove strictness in both directions. If parity-specific witness extraction is the blocker, first prove a reusable lemma that from an eventual domination failure one can choose arbitrarily large even or odd n.
7. If the exact original statements are too brittle, refactor into equivalent lemmas with cleaner hypotheses, but preserve the mathematical content: strict intermediate degree between consecutive powSystem levels.
8. Return a clean formal artifact, not a sketch. The file should compile against the catalog, and theorem names/statements should be stable and readable.

Why now? The surrounding infrastructure for simulation preorder, degree lattice, and the ladder powSystem already exists, so this cycle should convert a plausible but partial density argument into a verified theorem package. The key insight is that parity gluing creates an explicit intermediate asymptotic profile whose two residue classes separately witness failure of simulation in opposite directions, turning a single growth-gap theorem into a full density result at every ladder rung.