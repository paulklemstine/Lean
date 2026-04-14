# Sheffer AI: The Unary Sheffer Function Program

## σ(x) = log(1 + eˣ) — The NAND Gate of Calculus

The softplus function, together with affine operations and composition, generates a dense subalgebra of continuous functions on any compact set. This project formally verifies the theory in Lean 4, explores its implications for AI safety and mathematics, and proposes 25 open research questions.

---

## Project Structure

### Lean 4 Formal Proofs (`Lean/`)
**112 theorem/lemma declarations, ZERO sorry statements** — all machine-verified.

| File | Theorems | Key Results |
|------|----------|-------------|
| `SoftplusBasic.lean` | 17 | Positivity, monotonicity, differentiability, convexity, σ'=S, reflection |
| `ShefferAlgebra.lean` | 6 | Algebra definition, closure properties, id/const membership, Sheffer degree |
| `UniversalApproximation.lean` | 5 | Separates points, nonvanishing, continuity (Stone-Weierstrass prereqs) |
| `FutureTheorems.lean` | 21 | Composition bounds, non-polynomial, 1-Lipschitz, sigmoid properties, temperature family |
| `AdvancedTheorems.lean` | 23 | **Lipschitz Barrier**, exp ∉ Sheffer, sigmoid ODE, Jensen, strict convexity |
| `NewTheorems.lean` | 20 | Full subadditivity, x²/sinh ∉ Sheffer, Lipschitz bounds, log-sum-exp, sigmoid integral |
| `ExtendedTheorems.lean` | 20 | **Smoothness Barrier**, ReLU/\|x\| ∉ Sheffer, NOT closed under ×, surjectivity, logit |

### Research Papers (`Papers/`)
| File | Description |
|------|-------------|
| `future_research_directions_v4.md` | **Latest**: 25 open questions, 20 application domains |
| `scientific_american_article_v4.md` | **Latest**: Popular account of the Sheffer program |
| `research_paper.md` | Original research paper |
| Earlier versions (v1–v3) | Historical progression |

### Python Demonstrations (`Python/`)
| File | Description |
|------|-------------|
| `sheffer_v4_demos.py` | **Latest**: 10 demos including smoothness barrier, closure properties, attention |
| `softplus_demo.py` | Core softplus demonstrations |
| `sheffer_new_demos.py` | Lipschitz barrier, iterated dynamics, ODE phase portrait |
| `sheffer_extended_demos.py` | Extended experiments |
| `sheffer_future_demos.py` | Future research demonstrations |
| `sheffer_approximation_rates.py` | Approximation quality analysis |
| `sheffer_symbolic_extraction.py` | Symbolic formula extraction |

### SVG Visualizations (`Visuals/`)
22+ publication-quality SVG diagrams including:
- `smoothness_barrier.svg` — The smoothness barrier (new)
- `two_barrier_system.svg` — Two-barrier exclusion classification (new)
- `sheffer_closure_diagram.svg` — Closure properties (new)
- `sheffer_function_hierarchy.svg` — Function space hierarchy (new)
- `softplus_relu_comparison.svg` — Softplus vs ReLU (new)
- `lipschitz_barrier.svg` — The Lipschitz barrier
- `logsumexp_connection.svg` — Log-sum-exp = chained softplus
- `sheffer_nand_analogy.svg` — NAND gate analogy
- And 14 more...

---

## Key Results

### The Two-Barrier Exclusion System
1. **Lipschitz Barrier**: Every Sheffer expression is globally Lipschitz → excludes exp, x², sinh
2. **Smoothness Barrier**: Every Sheffer expression is differentiable → excludes ReLU, |x|, sign
3. Combined: ShefferAlg ⊆ C∞(ℝ) ∩ Lip(ℝ)

### Algebraic Structure
- ✓ Closed under: +, −, scalar ×, composition, negation
- ✗ NOT closed under: pointwise multiplication (x·x = x² violates Lipschitz)
- Contains: σ, identity, all constants, all affine functions

### Key Identities
- **Reflection**: σ(x) − x = σ(−x)
- **Subadditivity**: σ(x+y) ≤ σ(x) + σ(y)
- **Log-sum-exp**: log(eˣ + eʸ) = x + σ(y − x)
- **Sigmoid ODE**: S'(x) = S(x)(1 − S(x))
- **Sigmoid integral**: ∫ₐᵇ S(t) dt = σ(b) − σ(a)

### Bijections
- σ : ℝ → (0, ∞), inverse σ⁻¹(y) = log(eʸ − 1)
- S : ℝ → (0, 1), inverse logit(y) = log(y/(1−y))

---

## Quick Start

### Verify Lean Proofs
```bash
lake build ShefferAI
```

### Run Python Demos
```bash
pip install numpy scipy
python Python/sheffer_v4_demos.py
```

---

## Open Questions (25)

See `Papers/future_research_directions_v4.md` for the full list, including:
- Q21: Is sin(x) in the Sheffer algebra?
- Q22: What is the ring completion of ShefferAlg?
- Q23: Can we prove C∞ (not just C¹)?
- Q24: What is the growth rate of iterated softplus?
- Q25: What are the automorphisms of the algebra?
