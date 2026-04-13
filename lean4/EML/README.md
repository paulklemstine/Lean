# EML: The Continuous Sheffer Stroke & OISCC Processor

## All Elementary Functions from a Single Operator

This directory contains a comprehensive research exploration of the **EML operator** `eml(x,y) = exp(x) - ln(y)`, discovered by Andrzej Odrzywolek (Jagiellonian University, 2025), and the **OISCC (One Instruction Set Continuous Computer)** — a stack-based processor that executes only this single instruction.

The EML operator, paired with the constant 1, generates **all elementary functions** — the continuous analogue of the NAND gate's universality for Boolean logic.

---

## Contents

### 📐 Lean 4 Formalized Theorems (`*.lean`)

Machine-verified proofs of core EML and OISCC properties:

- **`Basic.lean`** — Core EML definitions and identities
  - `eml_exp`: exp(x) = eml(x, 1) ✅
  - `eml_e`: e = eml(1, 1) ✅
  - `eml_noncommutative`: EML is non-commutative ✅
  - `emlR_log`: ln(z) recovery ✅
  - Arithmetic via exp/log ✅
  - `EMLExpr.leaf_eq_node_succ`: tree combinatorics ✅
  - Differentiability and derivatives ✅
  - Master formula parameter counts ✅

- **`OISCC.lean`** — ⭐ **The One Instruction Set Continuous Computer**
  - Stack machine definition (PUSH + EML only) ✅
  - **Arithmetic Completeness Theorem** (`oiscc_arithmetic_complete`) ✅
  - exp recovery: `eml_recovers_exp` ✅
  - ln recovery: `eml_recovers_ln` ✅
  - **Subtraction**: `eml_recovers_sub` — the key identity ✅
  - **Addition**: `eml_recovers_add` ✅
  - **Multiplication**: `eml_mul_final` ✅
  - **Division**: `eml_div_final` ✅
  - **Powers**: `rpow_via_eml` ✅
  - Stack program correctness proofs ✅
  - No positive fixed point theorem ✅
  - Program composition ✅
  - Instruction counting ✅
  - Involution property ✅
  - Constant generation (e, 0, 1, exp(e)) ✅
  - **23 theorems, 0 sorry's** ✅

- **`Universality.lean`** — EML closure and universality
- **`NewTheorems.lean`** — Novel mathematical contributions

**Total: 40+ formally verified theorems across all files.**

### 🐍 Python Demos (`Demos/`)

- **`oiscc_processor.py`** — ⭐ **Complete OISCC Processor Simulator**
  - Two-button calculator demo (PUSH + EML only)
  - All arithmetic operations from EML alone
  - Constant generation from seed value 1
  - Instruction cost analysis table
  - NAND vs EML comparison
  - Sensor node simulation
  - Computation chain visualization
  - Mini assembler

- **`eml_calculator.py`** — Two-button scientific calculator
- **`eml_symbolic_regression.py`** — Gradient-based symbolic regression
- **`eml_dynamics.py`** — Dynamical systems exploration
- **`eml_visualization_generator.py`** — Tree visualization
- **`eml_gradient_analysis.py`** — Gradient structure analysis

### 🎨 SVG Visuals (`Visuals/`)

- **`oiscc_architecture.svg`** — ⭐ OISCC processor architecture diagram
- **`oiscc_stack_operations.svg`** — ⭐ How arithmetic emerges from EML
- **`oiscc_universality_proof.svg`** — ⭐ The arithmetic reduction tower
- **`eml_tree_exp.svg`** — EML tree for exp(x)
- **`eml_tree_ln.svg`** — EML tree for ln(z)
- **`eml_nand_comparison.svg`** — NAND vs EML comparison
- **`eml_reduction_tower.svg`** — The primitive reduction tower
- **`eml_circuit_symbol.svg`** — EML circuit symbol
- **`eml_applications_map.svg`** — Applications map

### 📄 Research Papers (`Papers/`)

- **`oiscc_research_paper.md`** — ⭐ Full OISCC research paper with machine-verified proofs
- **`oiscc_scientific_american.md`** — ⭐ Popular science article: "The One-Button Computer"
- **`oiscc_future_research.md`** — ⭐ 35 research directions across 9 categories
- **`oiscc_applications.md`** — ⭐ 50 applications across 10 domains
- **`oiscc_important_questions.md`** — ⭐ 25 deep questions, answered
- **`research_paper.md`** — Original EML research paper
- **`scientific_american_article.md`** — Original popular article
- **`future_research_directions.md`** — Original research directions
- **`applications_brainstorm.md`** — Original applications brainstorm
- **`important_questions_answered.md`** — Original FAQ

---

## Key Results

### Machine-Verified in Lean 4 (OISCC.lean):

| # | Theorem | Statement |
|---|---------|-----------|
| 1 | `eml_recovers_exp` | exp(a) = EML(a, 1) |
| 2 | `eml_recovers_ln` | ln(b) = EML(0, exp(EML(0, b))) |
| 3 | `eml_recovers_sub` | a − b = EML(ln(a), exp(b)) |
| 4 | `eml_recovers_add` | a + b = EML(ln(a), exp(−b)) |
| 5 | `eml_mul_final` | a × b = EML(ln(a)+ln(b), 1) |
| 6 | `eml_div_final` | a / b = EML(ln(a)−ln(b), 1) |
| 7 | `rpow_via_eml` | aᵇ = exp(b·ln(a)) |
| 8 | `eml_no_positive_fixed_point` | No x > 0 satisfies EML(x,x) = x |
| 9 | `oiscc_arithmetic_complete` | Master completeness theorem |
| 10 | `oiscc_computes_exp` | Stack program correctness for exp |
| 11 | `oiscc_computes_ln` | Stack program correctness for ln |
| 12 | `eml_log_exp_involution` | EML involution identity |

### The Key Insight

The identity that makes everything work:

```
a − b = EML(ln(a), exp(b)) = exp(ln(a)) − ln(exp(b)) = a − b
```

Once you have **subtraction** from EML (plus exp and ln which are trivial), all arithmetic follows:
- Addition: `a + b = a − (−b)`
- Multiplication: `a × b = exp(ln(a) + ln(b))`
- Division: `a / b = exp(ln(a) − ln(b))`
- Powers: `aᵇ = exp(b · ln(a))`

### OISCC Instruction Costs

| Operation | Instructions | Max Stack |
|-----------|-------------|-----------|
| exp(x) | 3 | 2 |
| ln(x) | 7 | 3 |
| a − b | 11 | 4 |
| a + b | 11 | 4 |
| a × b | ~19-28 | ~5 |
| a / b | ~19-28 | ~5 |

---

## Quick Start

```bash
# Run the OISCC processor simulator
python3 EML/Demos/oiscc_processor.py

# Build the Lean proofs (zero sorry's)
lake build EML

# Verify axiom cleanliness
# In Lean: #print axioms oiscc_arithmetic_complete
```

---

## The Big Picture

| Discrete | Continuous |
|----------|-----------|
| NAND gate | EML operator |
| Boolean {0,1} | Real ℝ |
| Sheffer, 1913 | Odrzywolek, 2025 |
| All Boolean functions | All elementary functions |
| Digital computers | **OISCC** |

The OISCC is the **continuous analog of the NAND-based computer**: one operation, one circuit, infinite computational power.

---

## References

- Odrzywolek, A. "All elementary functions from a single operator." Preprint (2025).
- Sheffer, H.M. "A set of five independent postulates for Boolean algebras." Trans. AMS 14 (1913).
- Ritt, J.F. "Integration in Finite Terms." Columbia University Press (1948).
