# Summary of changes
# Inverse Pythagorean Tree Factoring — Complete Research Package

I've created a comprehensive research package advancing the theory of inverse Pythagorean tree factoring, located in `Pythagorean/InverseTreeFactoring/`. Here's everything that was produced:

## 1. Oracle Council Research Notes (`OracleCouncil.md`)
A team of five oracles (Number Theory, Tree Dynamics, Algebraic Geometry, Cryptanalysis, Synthesis) brainstormed hypotheses, designed experiments, identified key theorems to formalize, and iterated on knowledge updates. Key findings include the depth-factor correspondence, Lorentz lattice interpretation, and complexity analysis.

## 2. Python Demo Scripts (`python/`)
- **`inverse_tree_factoring.py`** — Complete implementation with 5 demos:
  - Demo 1: The Parent Equation (computing parents of known triples)
  - Demo 2: The Recursive Chain f(d) (tracing ancestry paths to root)
  - Demo 3: Factoring via Depth (factoring 13 composites including 10403 = 101×103)
  - Demo 4: Depth Scanning (showing all depths where factors of 77 appear)
  - Demo 5: Integrality Test (connecting divisor pairs to integer roots)
  - Scaling Experiment (60+ semiprimes with depth vs. log₂N analysis)

- **`scg_visuals.py`** — 8 Scientific Computational Graphics:
  - SCG 1: Berggren Tree Structure (3 levels)
  - SCG 2: Inverse Tree Convergent Flow
  - SCG 3: Parent Chain Factoring (for N=77, 143, 221)
  - SCG 4: Depth vs. N ASCII Scatter Plot
  - SCG 5: Lorentz Light Cone Diagram
  - SCG 6: Algorithm Flowchart
  - SCG 7: Six Berggren Matrix Gallery
  - SCG 8: Comprehensive Factoring Results Table (30 semiprimes)

## 3. Research Paper (`ResearchPaper.md`)
Full academic paper with 9 sections covering: preliminaries, the parent equation (Theorem 3.1), recursive chain formula (Theorem 4.1), factoring via depth (Theorems 5.1-5.3), formal verification in Lean 4, computational experiments, and the Lorentz geometry interpretation.

## 4. Scientific American Article (`ScientificAmerican.md`)
Accessible popular science article: "Climbing the Pythagorean Tree: An Ancient Triangle Offers a New Way to Break Numbers Apart" — explaining the algorithm to a general audience.

## 5. Lean 4 Formal Proofs (`ChainFactoring.lean`) — **ALL THEOREMS PROVEN, ZERO SORRIES**
30+ formally verified theorems including:

**Core Parent Equation:**
- `invB1_preserves_pyth`, `invB2_preserves_pyth`, `invB3_preserves_pyth` — inverse maps preserve a²+b²=c²
- `fwdB1_invB1`, ..., `invB3_fwdB3` — 6 round-trip identities (B∘B⁻¹ = B⁻¹∘B = id)
- `parent_hyp_decrease` — hypotenuse strictly decreases
- `parent_hyp_pos` — parent hypotenuse stays positive
- `branch_exclusive_12`, `branch_exclusive_123` — at most one valid parent branch

**Recursive Chain:**
- `chainF` — the chain function f(d) = parent^d(t)
- `parent_preserves_pyth_any_branch` — parent preserves Pythagorean property regardless of branch
- `chain_zero`, `chain_succ` — f(0) = t, f(d+1) = parent(f(d))

**Factoring Connection:**
- `trivial_ppt_is_pyth` — trivial PPT of odd N satisfies Pythagorean equation
- `trivial_ppt_diff` — c-b=1, c+b=N² for trivial PPT
- `diff_of_squares_pyth` — (c-b)(c+b)=a² fundamental identity
- `divisor_pair_gives_triple_Z` — same-parity divisor pairs yield Pythagorean triples
- `composite_nontrivial_factorization` — composites have nontrivial factorizations

**Lorentz Form:**
- All 6 Lorentz form preservation theorems (3 inverse + 3 forward)

**Concrete Factoring Verification:**
- `factor_15`, `factor_21`, `factor_77`, `factor_143`, `factor_221` — machine-verified factoring at specific depths

**Key empirical finding:** The factoring depth scales as approximately (min(p,q)-1)/2 for semiprimes N=p×q, confirmed across 60+ test cases.

## Pre-generated Output (`visuals/`)
- `demo_output.txt` — Full output of all Python demos
- `scg_output.txt` — Full output of all 8 SCG visualizations