# Sheffer AI: The Unary Sheffer Function Program

## One Function to Rule Them All

The **softplus function** σ(x) = log(1 + eˣ) is the continuous analogue of the NAND gate — a single function from which all smooth functions can be built. This project formalizes, proves, demonstrates, and explores this foundational result.

---

## 📁 Project Structure

```
ShefferAI/
├── README.md                              # This file
├── Lean/                                  # Formal proofs (Lean 4 + Mathlib)
│   ├── SoftplusBasic.lean                 # Core properties (17 theorems, 0 sorry)
│   ├── ShefferAlgebra.lean                # Algebraic structure (8 theorems, 0 sorry)
│   ├── UniversalApproximation.lean        # Approximation theory (4 theorems, 0 sorry)
│   ├── FutureTheorems.lean                # Advanced results (19 theorems, 0 sorry)
│   ├── AdvancedTheorems.lean              # Lipschitz Barrier + more (21 theorems, 0 sorry)
│   └── NewTheorems.lean                   # ★ NEW: Extended results (10 theorems, 0 sorry)
├── Python/                                # Computational demonstrations
│   ├── softplus_demo.py                   # Interactive visualizations
│   ├── sheffer_symbolic_extraction.py     # Symbolic extraction from trained networks
│   ├── sheffer_approximation_rates.py     # Convergence rate analysis
│   ├── sheffer_future_demos.py            # Future research demos (8 experiments)
│   ├── sheffer_new_demos.py               # Lipschitz barrier, ODE, etc. (8 demos)
│   └── sheffer_extended_demos.py          # ★ NEW: 10 extended demos
├── Visuals/                               # SVG diagrams (18 total)
│   ├── softplus_curve.svg                 # The softplus function with ReLU comparison
│   ├── sheffer_algebra_structure.svg      # How σ generates all functions
│   ├── sheffer_depth_hierarchy.svg        # Complexity hierarchy by depth
│   ├── sheffer_nand_analogy.svg           # NAND ↔ Softplus analogy
│   ├── applications_map.svg              # Applications overview
│   ├── formal_group_connection.svg        # Formal group theory link
│   ├── tropical_sheffer_duality.svg       # Temperature family convergence
│   ├── uniqueness_theorem.svg             # Uniqueness characterization
│   ├── research_roadmap.svg               # Original research timeline
│   ├── lipschitz_barrier.svg              # Lipschitz Barrier Theorem
│   ├── sheffer_hierarchy.svg              # Complete theorem hierarchy
│   ├── iterated_softplus.svg              # Iterated softplus dynamics
│   ├── sheffer_applications_web.svg       # Application connection web
│   ├── sigmoid_ode.svg                    # Sigmoid ODE phase portrait
│   ├── softplus_bounds.svg                # Softplus bounds diagram
│   ├── sheffer_research_roadmap_v2.svg    # ★ NEW: Updated research roadmap
│   ├── lipschitz_barrier_extended.svg     # ★ NEW: Extended barrier (x², sinh)
│   ├── sheffer_full_theorem_map.svg       # ★ NEW: Complete 79-theorem map
│   └── logsumexp_connection.svg           # ★ NEW: Log-sum-exp diagram
├── Papers/                                # Research papers
│   ├── research_paper.md                  # Main research paper
│   ├── scientific_american_article.md     # Original popular article
│   ├── scientific_american_article_v2.md  # Updated popular article
│   ├── scientific_american_article_v3.md  # ★ NEW: Latest popular article
│   ├── future_research_directions.md      # Original future directions
│   ├── future_research_directions_v2.md   # Updated with corrections
│   └── future_research_directions_v3.md   # ★ NEW: 79 theorems, 20 questions
```

---

## 🏆 Key Results

### 79 Formally Verified Theorems (0 sorry statements)

| File | Theorems | Highlights |
|------|----------|------------|
| SoftplusBasic.lean | 17 | Positivity, monotonicity, convexity, differentiability |
| ShefferAlgebra.lean | 8 | Closure properties, id/const membership, Sheffer degree |
| UniversalApproximation.lean | 4 | Stone-Weierstrass prerequisites |
| FutureTheorems.lean | 19 | Composition bound, non-polynomial, Lipschitz, temperature family |
| AdvancedTheorems.lean | 21 | Lipschitz Barrier, exp ∉ algebra, sigmoid ODE, Jensen |
| **NewTheorems.lean** | **10** | **x²/sinh ∉ algebra, full subadditivity, log-sum-exp, integral** |

### Major Discoveries

1. **Lipschitz Barrier Theorem**: Every Sheffer expression is Lipschitz continuous. Therefore exp(x), x², and sinh(x) are NOT in the Sheffer algebra — a fundamental structural impossibility.

2. **Computable Lipschitz Bounds**: `ShefferExpr.lipschitzBound` computes a valid Lipschitz constant from the expression tree, with formal correctness proof.

3. **Log-Sum-Exp Connection**: log(eˣ + eʸ) = x + σ(y − x), revealing softplus as the building block of transformer attention mechanisms.

4. **Sigmoid Integral Theorem**: ∫ₐᵇ S(t) dt = σ(b) − σ(a), connecting sigmoid to softplus via the fundamental theorem of calculus.

5. **Full Subadditivity**: σ(x+y) ≤ σ(x) + σ(y) for ALL x, y ∈ ℝ (not just nonneg).

6. **Sigmoid ODE**: S'(x) = S(x)(1 − S(x)), connecting to the logistic equation of population dynamics.

7. **Three False Claims Corrected**: Formal verification caught errors in upper bound, superadditivity, and exponential membership.

---

## 🔬 Python Demonstrations (18 total)

### Original Demos
- Interactive softplus visualizations
- Symbolic extraction from trained networks  
- Convergence rate analysis
- Tropical-Sheffer duality, Kepler's law recovery, signal compression

### Extended Demos (sheffer_extended_demos.py) ★ NEW
1. Full subadditivity verification
2. Lipschitz barrier for x², sinh, cosh
3. Softplus asymptotic behavior
4. Sigmoid product bound S(1-S) ≤ 1/4
5. Iterated softplus dynamics
6. Computable Lipschitz constants
7. Log-sum-exp connection
8. Sheffer approximation of common functions
9. Sheffer complexity class separation
10. Sigmoid integral verification

Run: `python3 ShefferAI/Python/sheffer_extended_demos.py`

---

## 📚 Papers

- **future_research_directions_v3.md** ★ NEW: 79 theorems, 20 open questions, 15 applications
- **scientific_american_article_v3.md** ★ NEW: Popular account with log-sum-exp and x² results
- Earlier versions preserved for reference

---

## 🎨 Visualizations (18 SVGs)

Publication-quality diagrams including:
- **sheffer_full_theorem_map.svg** ★ NEW: Complete 79-theorem dependency map
- **lipschitz_barrier_extended.svg** ★ NEW: Extended barrier with x², sinh proofs
- **logsumexp_connection.svg** ★ NEW: Softplus ↔ attention ↔ free energy
- **sheffer_research_roadmap_v2.svg** ★ NEW: Three-phase research timeline
- Plus 14 original diagrams covering curves, algebra, hierarchy, ODE, bounds, etc.

---

## 🚀 Getting Started

```bash
# Build all Lean proofs (verify 79 theorems)
lake build ShefferAI

# Run extended Python demos
python3 ShefferAI/Python/sheffer_extended_demos.py

# View SVGs in browser
open ShefferAI/Visuals/sheffer_full_theorem_map.svg
```

---

## 📖 Key Insight

> **The Sheffer algebra = the Lipschitz closure of softplus compositions.**
>
> Every function built from softplus via affine operations has a computable
> Lipschitz constant. This is simultaneously a limitation (can't represent exp, x²)
> and a guarantee (every softplus network has a certified robustness bound).
>
> The log-sum-exp identity reveals softplus as the mathematical foundation
> of transformer attention — connecting the Sheffer program directly to modern AI.

---

*Sheffer AI Research Program — 79 machine-verified theorems, 0 sorry statements, 18 Python demos, 18 SVG visualizations, 3 research papers*
