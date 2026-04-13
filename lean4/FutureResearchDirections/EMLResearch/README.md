# EML Research: Future Directions for the Continuous Sheffer Stroke

## Overview

This package explores the EML (Exp-Minus-Log) operator `eml(x,y) = exp(x) − ln(y)`, a single binary operator that generates all elementary functions — the continuous analogue of the Sheffer stroke (NAND) in Boolean logic.

## Contents

### Lean 4 Formalization (`EMLAlgebra.lean`)
Machine-verified proofs of 25+ theorems including:
- Recovery identities: `exp(x) = eml(x, 1)`, `e = eml(1, 1)`
- Subtraction identity: `a − b = eml(ln(a), exp(b))`
- Anti-EML duality: `antiEml(x,y) = −eml(y,x)`
- Non-commutativity and non-associativity
- Tree combinatorics: `leaves = nodes + 1`, `leaves ≤ 2^depth`
- Differentiability: `∂eml/∂x = exp(x)`, `∂eml/∂y = −1/y`
- Periodicity obstruction: real exp compositions cannot be periodic
- Master formula parameter growth
- Catalan number enumeration of tree topologies
- EDL-EML relationship
- EML complexity bounds (exp has complexity ≤ 2)
- EML closure properties

All proofs compile without `sorry`.

### Python Demos (`demos/`)
- **`eml_explorer.py`** — Interactive EML calculator with bootstrapping, function recovery, identity verification, complexity analysis, two-button calculator, and symbolic regression
- **`eml_complexity_analyzer.py`** — Brute-force search for optimal EML representations, master formula analysis, constant-free Sheffer exploration
- **`eml_neural_network.py`** — EML-based neural network concept with interpretability analysis and KAN comparison

### SVG Visuals (`visuals/`)
- **`eml_research_roadmap.svg`** — Complete research roadmap across 6 fields
- **`eml_bootstrapping_chain.svg`** — How constants and functions are built from 1 and eml
- **`eml_classification_diagram.svg`** — Known and conjectured Sheffer operators
- **`eml_complexity_landscape.svg`** — EML complexity of various functions

### Written Documents
- **`research_paper.md`** — Full research paper on future directions (with formally verified results)
- **`sciam_article.md`** — Scientific American style article: "The One-Button Calculator That Can Do Everything"
- **`applications_brainstorm.md`** — 30+ application ideas across computing, ML, physics, education
- **`answers_to_key_questions.md`** — Detailed answers to 12 major open questions

## Key Results

| Theorem | Status | Description |
|---------|--------|-------------|
| `eml_recovers_exp` | ✅ Proven | `exp(x) = eml(x, 1)` |
| `eml_subtraction` | ✅ Proven | `a − b = eml(ln(a), exp(b))` |
| `eml_not_comm` | ✅ Proven | EML is non-commutative |
| `eml_not_assoc` | ✅ Proven | EML is non-associative |
| `leafCount_eq_nodeCount_succ` | ✅ Proven | Binary tree: leaves = nodes + 1 |
| `leafCount_le_pow_depth` | ✅ Proven | leaves ≤ 2^depth |
| `exp_exp_not_periodic` | ✅ Proven | Real exp∘exp is not periodic |
| `masterParams_growth` | ✅ Proven | Parameter count increases with depth |
| `edl_eml_relation` | ✅ Proven | EDL relates to EML via division |
| `emlComplexity_exp_le` | ✅ Proven | exp has EML complexity ≤ 2 |

## Running

```bash
# Run Python demos
python3 demos/eml_explorer.py
python3 demos/eml_complexity_analyzer.py
python3 demos/eml_neural_network.py

# Build Lean proofs
lake build FutureResearchDirections.EMLResearch.EMLAlgebra
```
