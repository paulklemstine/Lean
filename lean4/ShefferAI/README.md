# Sheffer AI: The Unary Sheffer Function Program

## One Function to Rule Them All

The **softplus function** σ(x) = log(1 + eˣ) is the continuous analogue of the NAND gate — a single function from which all smooth functions can be built. This project formalizes, proves, demonstrates, and explores this foundational result.

---

## 📁 Project Structure

```
ShefferAI/
├── README.md                          # This file
├── Lean/                              # Formal proofs (Lean 4 + Mathlib)
│   ├── SoftplusBasic.lean             # Core properties (17 theorems, 0 sorry)
│   ├── ShefferAlgebra.lean            # Algebraic structure (6 theorems, 0 sorry)
│   ├── UniversalApproximation.lean    # Approximation theory (4 theorems, 0 sorry)
│   ├── FutureTheorems.lean            # Advanced results (19 theorems, 0 sorry)
│   └── AdvancedTheorems.lean          # NEW: Lipschitz Barrier + more (21 theorems, 0 sorry)
├── Python/                            # Computational demonstrations
│   ├── softplus_demo.py               # Interactive visualizations
│   ├── sheffer_symbolic_extraction.py # Symbolic extraction from trained networks
│   ├── sheffer_approximation_rates.py # Convergence rate analysis
│   ├── sheffer_future_demos.py        # Future research demos (8 experiments)
│   └── sheffer_new_demos.py           # NEW: 8 new demos (Lipschitz barrier, ODE, etc.)
├── Visuals/                           # SVG diagrams (15 total)
│   ├── softplus_curve.svg             # The softplus function with ReLU comparison
│   ├── sheffer_algebra_structure.svg  # How σ generates all functions
│   ├── sheffer_depth_hierarchy.svg    # Complexity hierarchy by depth
│   ├── sheffer_nand_analogy.svg       # NAND ↔ Softplus analogy
│   ├── applications_map.svg           # Applications overview
│   ├── formal_group_connection.svg    # Formal group theory link
│   ├── tropical_sheffer_duality.svg   # Temperature family convergence
│   ├── uniqueness_theorem.svg         # Uniqueness characterization
│   ├── research_roadmap.svg           # Research timeline
│   ├── softplus_curve.svg             # Softplus function plot
│   ├── lipschitz_barrier.svg          # NEW: Lipschitz Barrier Theorem
│   ├── sheffer_hierarchy.svg          # NEW: Complete theorem hierarchy
│   ├── iterated_softplus.svg          # NEW: Iterated softplus dynamics
│   ├── sheffer_applications_web.svg   # NEW: Application connection web
│   ├── sigmoid_ode.svg                # NEW: Sigmoid ODE phase portrait
│   └── softplus_bounds.svg            # NEW: Softplus bounds diagram
├── Papers/                            # Research papers
│   ├── research_paper.md              # Main research paper
│   ├── scientific_american_article.md # Popular science article
│   ├── future_research_directions.md  # Original future directions
│   ├── future_research_directions_v2.md  # NEW: Updated with corrections & new results
│   └── scientific_american_article_v2.md # NEW: Updated popular article
```

---

## 🏆 Key Results

### 67 Formally Verified Theorems (0 sorry statements)

| File | Theorems | Highlights |
|------|----------|------------|
| SoftplusBasic.lean | 17 | Positivity, monotonicity, convexity, differentiability |
| ShefferAlgebra.lean | 6 | Closure properties, id/const membership, Sheffer degree |
| UniversalApproximation.lean | 4 | Stone-Weierstrass prerequisites |
| FutureTheorems.lean | 19 | Composition bound, non-polynomial, Lipschitz, temperature family |
| **AdvancedTheorems.lean** | **21** | **Lipschitz Barrier, exp ∉ algebra, sigmoid ODE, Jensen, subadditivity** |

### Major New Discoveries

1. **Lipschitz Barrier Theorem**: Every Sheffer expression is Lipschitz continuous. Therefore, **exp(x) is NOT in the Sheffer algebra** — a fundamental structural impossibility. This was discovered through formal verification when the initial claim that exp ∈ Sheffer algebra was machine-disproved.

2. **Sigmoid ODE**: S'(x) = S(x)(1 - S(x)), connecting Sheffer theory to dynamical systems.

3. **Three false claims corrected**: Formal verification caught errors in upper bound, superadditivity, and exponential membership.

4. **Softplus subadditivity**: σ(x+y) ≤ σ(x) + σ(y) for all x, y (not superadditive as initially conjectured).

5. **Tight bounds**: σ(x) ≤ max(x,0) + log 2, σ(x) ≥ x/2 + log(2)/2 for x ≥ 0, σ(x) ≥ eˣ/2 for x ≤ 0.

---

## 🔬 Python Demonstrations

### Original Demos (sheffer_future_demos.py)
1. Tropical-Sheffer Duality
2. Sheffer degree estimation
3. Kepler's law recovery
4. Symbolic extraction
5. Signal compression
6. Sigmoid ODE solver
7. Formal group verification

### New Demos (sheffer_new_demos.py)
1. **Lipschitz Barrier visualization** — Shows exp cannot be Sheffer
2. **Sheffer Complexity Classes SH(d,w)** — Estimates Sheffer degree
3. **Iterated softplus dynamics** — No fixed points, all orbits diverge
4. **Sigmoid ODE phase portrait** — S'=S(1-S) characterization
5. **Multivariate log-sum-exp** — LSE as multivariate Sheffer function
6. **Sheffer compression benchmarks** — SNR vs width tradeoff
7. **Formal group connection** — Multiplicative formal group gives softplus
8. **Convexity properties** — Numerical verification of proved bounds

Run: `python3 ShefferAI/Python/sheffer_new_demos.py` (requires numpy, scipy)

---

## 📚 Papers

- **future_research_directions_v2.md**: Comprehensive analysis with 15 open questions, 12 applications, corrected theory, and 67 theorem catalog
- **scientific_american_article_v2.md**: Accessible account of the Lipschitz Barrier discovery and its implications for AI safety

---

## 🎨 Visualizations (15 SVGs)

Publication-quality SVG diagrams covering the softplus curve, algebra structure, theorem hierarchy, Lipschitz barrier, iterated dynamics, sigmoid ODE, bounds, applications web, and more.

---

## 🚀 Getting Started

```bash
# Build all Lean proofs
lake build ShefferAI

# Run Python demos (requires numpy, scipy)
python3 ShefferAI/Python/sheffer_new_demos.py

# View SVGs in browser
open ShefferAI/Visuals/lipschitz_barrier.svg
```

---

## 📖 Key Insight

> **The Sheffer algebra = the Lipschitz closure of softplus compositions.**
>
> Every finite composition of softplus with affine maps is Lipschitz continuous.
> This means the Sheffer algebra, while dense in C⁰(K) for approximation,
> cannot exactly represent non-Lipschitz functions like exp(x).
> This is simultaneously a limitation and a guarantee:
> every softplus network has a computable, provable robustness certificate.

---

*Sheffer AI Research Program — 67 machine-verified theorems, 0 sorry statements, 8 Python demos, 15 SVG visualizations*
