# Summary of changes for run 74052fea-25e3-44ff-bdb7-864f4a94d22e
## Temporal Gödel-Löb Logic (TGL) — Lean 4 Formalization

### Deliverables

**`Logic/TemporalGL.lean`** — 341 lines, 0 sorries, all proofs verified.

**`FUTURE_DIRECTIONS.md`** — 5 research directions with falsifiable hypotheses.

### Theorem Declarations & Status

| # | Name | Statement | Status |
|---|------|-----------|--------|
| 1 | `löb_valid` | □(□A → A) → □A valid in all TGL frames | **proved** |
| 2 | `box_temporal_monotone` | □A → ■□A: provability persists through time | **proved** |
| 3 | `box_always_comm` | □■A → ■□A: forward commutativity | **proved** |
| 4 | `always_box_comm_fails` | ■□A → □■A is NOT valid (counterexample) | **proved** |

All 4 main theorems plus 5 supporting frame-condition lemmas are fully proved. The first three main theorems are **axiom-free** (fully constructive). The counterexample uses only standard axioms (propext, Classical.choice, Quot.sound).

### Key Mathematical Content

**TGL Framework**: A bimodal logic with provability (□) over transitive, converse well-founded frames and temporal persistence (■) over reflexive, transitive temporal order, connected by a persistence axiom: later temporal worlds access subsets of earlier worlds' R-successors.

**Central Discovery — Commutativity Asymmetry**: □■A → ■□A is valid but ■□A → □■A is NOT. The 3-world counterexample ({w, u, u'}, R: w→u, T: u→u') reveals the structural reason: persistence constrains R-successors across temporal transitions but says nothing about T-successors of R-successors. This asymmetry is the defining feature of TGL vs. simpler bimodal logics.

### Critique (Theorem 3: `box_always_comm`)

**Strongest assumption that could be weakened**: T-reflexivity. The proof uses T_refl to collapse ■A to A at the target world. Without T-reflexivity, □■A → ■□A would require a separate argument.

**Boundary case**: If T is irreflexive (strict temporal order), □■A → ■□A fails — a world u could satisfy ■A (everything strictly after u satisfies A) without satisfying A itself.

**Generalization conjecture**: Under the Church-Rosser condition (∀ w u u', R w u → T u u' → ∃ w', T w w' ∧ R w' u'), the REVERSE direction ■□A → □■A also becomes valid. This is Direction 1 in FUTURE_DIRECTIONS.md.