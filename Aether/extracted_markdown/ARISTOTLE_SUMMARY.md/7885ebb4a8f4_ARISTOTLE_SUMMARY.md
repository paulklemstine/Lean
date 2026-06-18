# Summary of changes for run eb4b1575-a951-4089-933c-544154ef8f55
# EML Differential Equations: Wronskian Theory and Kovacic Classification

## Lean 4 Formalization (EML/DiffFieldBasic.lean)

A complete, sorry-free formalization (557 lines, 0 sorries) of the algebraic theory of second-order linear ODEs over abstract differential fields. All proofs verified with clean axioms (propext, Classical.choice, Quot.sound only).

### Novel Structure: Differential Companion System (DCS)
Introduced the `DiffCompanionSystem` structure that packages a second-order ODE with its EML complexity level and gauge parameter, along with:
- `EMLTowerStep` / `EMLExtType` — formal EML tower hierarchy
- `KovacicCase` — the four-case classification of differential Galois groups
- `AiryType` — Airy-type ODEs with their algebraic obstruction structure
- `RiccatiEq` — Riccati companion equations

### Key Theorems Proved (27 total, all sorry-free)

**Foundational** (8 lemmas): `D_zero`, `D_neg`, `D_sub`, `D_sq`, `D_mul_three`, `D_inv`, `IsConst.add/mul/neg/sub`

**Core ODE Theory** (5 theorems):
- `abel_identity` — Abel's Identity: W' = -p·W for solutions of y'' + py' + qy = 0
- `wronskian_const_of_p_zero` — Wronskian is constant when p = 0
- `solution_span_of_wronskian_ne_zero` — **Solution Space Theorem**: any solution = c₁y₁ + c₂y₂ with explicit constant formulas via Wronskian quotients
- `cramer_diff` — Cramer's lemma for differential fields
- `wronskian_three_term` — Key algebraic identity: W(y₃,y₂)·y₁ + W(y₁,y₃)·y₂ = y₃·W(y₁,y₂)

**Riccati Bridge** (3 theorems):
- `riccati_of_solution` — If y ≠ 0 solves the ODE, then r = y'/y solves the Riccati equation
- `solution_of_riccati` — Converse: Riccati solution + exponential recovery gives ODE solution
- `wronskian_riccati_bridge` — W(y₁,y₂) = y₁y₂(r₂ - r₁)

**Airy Obstructions** (2 theorems):
- `airy_no_const_solution` — Airy equation y'' = xy has no nonzero constant solutions
- `airy_riccati_not_const` — The Riccati variable of any nonzero Airy solution cannot be constant

**Structural** (2 theorems):
- `isConst_div_of_same_logderiv` — Quotients of "same-type exponentials" are constant
- `tower_height_decomp` — EML tower height = exponential depth + logarithmic depth

## Deliverables

- **ARTICLE.md** — Scientific American-style article on the hidden algebra of differential equations
- **RESEARCH_PAPER.md** — Full research paper with PEGB analysis for key theorems
- **FUTURE_DIRECTIONS.md** — 5 research directions including full Kovacic formalization and tropical Riccati equations
- **demo.py** — 6 numerical demonstrations verifying the theorems
- **algorithms.py** — Type-hinted implementations with self-tests
- **viz_wronskian.py**, **viz_airy.py**, **viz_kovacic.py** — Visualization scripts
- **PACKAGE.json** — Complete package with 3 interactive HTML demos (Wronskian Explorer, Kovacic Classifier, Riccati Visualizer)