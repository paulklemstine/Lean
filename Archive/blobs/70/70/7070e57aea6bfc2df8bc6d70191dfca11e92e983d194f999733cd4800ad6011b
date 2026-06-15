Repair the partial development by treating it as a proof-complexity formalization task, not as physics. Create or reconstruct a complete Lean file around the theorem that the p-degree height ladder is dense between consecutive rungs.

Primary goal:
Formalize and prove a theorem of the following shape: for every k >= 1, there exists an explicit system interPowSys k such that powSystem k < interPowSys k and interPowSys k < powSystem (k+1).

Required mathematical content:
1. Work in the existing simulation-preorder / degree-lattice framework from the catalog.
2. Use an explicit witness interPowSys k built from a parity-split size function:
   - on even n, the size behaves like 2^(n^(k+1))
   - on odd n, the size behaves like 2^(n^k)
   Realize this as a sysOfSize-style construction compatible with existing definitions.
3. Prove the lower strictness powSystem k < interPowSys k by showing:
   - powSystem k simulates interPowSys k (or the appropriate non-strict comparison in the catalog ordering), and
   - the converse fails via infinitely many even indices where the upper growth dominates every polynomial overhead.
4. Prove the upper strictness interPowSys k < powSystem (k+1) by showing:
   - interPowSys k is simulated by powSystem (k+1), and
   - the converse fails via infinitely many odd indices where the glued system drops to the lower growth rate.
5. Use the existing theorem simulates_sysOfSize_iff if available; otherwise derive the exact comparison criterion already used elsewhere in FINAL/ files.
6. If the proof needs a stronger asymptotic lemma, add a clean auxiliary result of the form “for k >= 1 and every polynomial overhead, 2^(n^(k+1)) eventually dominates 2^(n^k * polylog/poly/polynomial term)” or whatever exact inequality the current framework requires. Also add parity-aware extraction lemmas so eventual bounds can be witnessed on infinitely many even or odd n.

Implementation guidance:
- First inspect the referenced FINAL files and reconstruct the exact names, hypotheses, and order conventions for simulates, lt, and sysOfSize.
- Prefer minimal new definitions and reuse existing ladder objects and gap lemmas.
- If the previous LadderDensity file is truncated, rewrite it cleanly from scratch rather than patching corrupted declarations.
- Keep theorem statements concrete and compiler-checkable; avoid speculative generalizations beyond consecutive-rung density.
- End product must compile with no sorrys.

Deliverables:
1. A complete Lean file, likely Catalog/Logic/ProofComplexity/LadderDensity.lean.
2. The main theorem(s) with explicit witness interPowSys.
3. Any necessary helper lemmas on parity and asymptotic gaps.
4. Brief module documentation explaining the local-to-global parity-gluing idea.

If the exact strict-order theorem is not expressible with current definitions, then formalize the strongest precise substitute already supported by the catalog: existence of a system incomparable in one direction plus separate non-equivalence corollaries sufficient to conclude a strict intermediate degree.