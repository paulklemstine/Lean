# Summary of changes for run 5c06fbfb-e8de-46b6-9f16-0796abacbc16
## Completed: Galois Theory Beyond Abel–Ruffini

### Formally Verified Mathematics (Algebra/GaloisBeyondAbelRuffini.lean)

All 14 theorems are proven without `sorry`, using only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). Key results:

**Theorem 1 — Solvability Transfer (`radicalSolvable_of_mulEquiv`):**
Defines `RadicalSolvable G` (existence of n with derived series G^(n) = ⊥) and proves it is invariant under group isomorphism: `RadicalSolvable G ↔ RadicalSolvable H` given `G ≃* H`.

**Theorem 2 — S₅ Obstruction (`not_radicalSolvable_of_mulEquiv_S5`):**
Any group isomorphic to S₅ is not radical-solvable. Uses `Equiv.Perm.fin_5_not_solvable` from Mathlib. Generalized to `not_radicalSolvable_Sn_of_five_le` for all n ≥ 5.

**Theorem 3 — Polynomial Non-Solvability (`polynomial_not_solvable_of_galGroup_equiv_S5`):**
An irreducible polynomial over ℚ whose Galois group is isomorphic to S₅ is not solvable by radicals. Uses `solvableByRad.isSolvable'` from Mathlib's Abel-Ruffini formalization. Also proves the pointwise variant `no_root_solvable_of_galGroup_S5`.

**Theorem 4 — Galois Connection (`intermediateField_subgroup_galoisConnection`):**
For a finite Galois extension E/F, the fixingSubgroup/fixedField correspondence forms a `GaloisConnection` in the order-theoretic sense. Derives closure and anti-monotonicity properties.

**Novel Definitions:**
- `RadicalSolvable` — certificate-oriented group solvability
- `SolvableByRadicals` — polynomial solvability by radicals  
- `ResolventCertificate` — arithmetic evidence for Galois group identification
- `DerivedSeriesCertificate` — constructive witness for derived series termination

**Additional theorems:** `radicalSolvable_of_certificate`, `certificate_implies_derivedSeries_bot`, `radicalSolvable_derivedSeries_descending`, `radicalSolvable_of_surjective`, `radicalSolvable_subgroup`, `galoisConnection_closure_fixingSubgroup`, `fixingSubgroup_antitone'`.

### Other Deliverables

- **ARTICLE.md** — Popular science article (~2500 words) about the impossibility of solving quintic equations, with historical narrative and mathematical exposition. No mention of proof assistants or formal verification.
- **RESEARCH_PAPER.md** — Technical research paper with abstract, detailed proof sketches, algorithm descriptions, computational experiments, and references.
- **FUTURE_DIRECTIONS.md** — Five testable research directions with structured format, including grand challenges (formal modular Galois group computation, inverse Galois problem) and solid extensions (transitive subgroup classification, radical tower certificates).
- **demo.py** — Interactive demonstration analyzing quintic polynomials via modular factorization, computing discriminants, and detecting S₅ obstructions. Successfully certifies x⁵−x−1 and x⁵−6x+3 as non-solvable.
- **algorithms.py** — Implementations of derived series computation, resolvent certificate generation, and quintic Galois group analysis.
- **applications.py** — Educational demonstrations, statistical analysis of random quintics, and batch polynomial family analysis.
- **PACKAGE.json** — Complete JSON data package bundling all artifacts.