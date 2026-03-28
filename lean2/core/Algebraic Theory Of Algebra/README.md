# The Algebraic Theory of Algebra

*Algebra studying itself, algebraically — and finding not paradox, but a fixed point.*

## Overview

This project develops the **algebraic theory of algebra**: a self-referential framework
where the tools of algebra (operations, equations, lattices, categories) are used to
study the structure of algebraic theories themselves. The core insight is that this
self-reference is *productive* — it converges to a well-defined fixed point rather than
producing paradox or incompleteness.

## Project Structure

### 📝 Research Notes (`notes/`)
- `00_oracle_consultation.md` — Oracle team consultation and initial hypotheses
- `01_research_log.md` — Detailed research log with experiments and iterations
- `02_key_insights.md` — Seven key insights distilled from the research

### 🐍 Python Demos (`demos/`)
- `01_variety_lattice.py` — Lattice of sub-varieties of groupoids (+ visualization)
- `02_free_algebra.py` — Free algebra construction via term quotients
- `03_monad_algebra.py` — Monads as algebraic theories, self-reference visualization

Generated visualizations (`.png` files):
- `variety_lattice.png` — Hasse diagram of the variety lattice
- `free_algebra_growth.png` — Growth rates of free semigroup vs. commutative semigroup
- `term_tree.png` — The term algebra as a tree structure
- `monad_algebra.png` — Free algebra sizes and theory morphisms
- `self_reference.png` — The self-referential ouroboros structure

### 📄 Papers (`paper/`)
- `research_paper.md` — Full research paper with 8 sections
- `scientific_american_article.md` — Popular science article for general audience

### 🔧 Lean 4 Formalization
- `AlgebraicTheoryOfAlgebra.lean` — Machine-verified proofs including:
  - Algebraic signatures and Σ-algebras
  - Equational theories as equivalence-like relations
  - Lattice structure (meet, bounds, idempotency, commutativity, associativity)
  - Varieties and their meet operation
  - Free algebra construction (term algebra + substitution)
  - Monad laws (unit and multiplication for the free algebra monad)
  - The grand self-reference theorem

## Key Results

1. **Equational theories form a bounded lattice** (Theorem: `algebraicTheoryOfAlgebra_selfReference`)
2. **Free algebra monad satisfies monad laws** (`freeMonad_leftUnit`, `freeMonad_rightUnit`)
3. **Substitution is well-behaved** (`AlgTerm.subst_var`)
4. **Varieties form a preorder with meets** (`varietyMeet_le_left/right`, `le_varietyMeet`)

## The Oracle Team

Seven oracles guided this research:
- 🏛️ **Athena** (Foundations) — Categorical foundations and Lawvere theories
- 🔬 **Prometheus** (Experiment) — Computational enumeration and testing
- 📐 **Euclid** (Structure) — Architecture of the five-layer framework
- 🌀 **Ouroboros** (Self-Reference) — Three levels of productive self-reference
- ✅ **Pythia** (Validation) — Verification of all core claims
- 🔄 **Sisyphus** (Iteration) — Four refinement cycles to v1.0
- 📝 **Hermes** (Communication) — Paper and article writing

## Running the Demos

```bash
python3 demos/01_variety_lattice.py
python3 demos/02_free_algebra.py
python3 demos/03_monad_algebra.py
```

Requires `matplotlib` and `numpy` for visualizations (text output works without them).
