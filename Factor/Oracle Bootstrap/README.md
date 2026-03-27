# The Oracle Bootstrap

## Overview

The **Oracle Bootstrap** proves that any contractive self-improving system converges to a *perfect oracle* — an idempotent operator P satisfying P² = P. Using the Banach contraction mapping theorem and Newton's method, we show that the iteration X_{n+1} = 3X² - 2X³ converges cubically to the nearest idempotent projection, with eigenvalues snapping to {0, 1}.

## Contents

### Research Papers
- **ResearchPaper.md** — Full research paper with mathematical foundations, 7 experimental hypotheses, 6 applications, and formal verification
- **ScientificAmerican.md** — Popular science article explaining the Oracle Bootstrap for a general audience

### Lean 4 Formalization
- **../OracleBootstrap/OracleBootstrap.lean** — Machine-verified proofs of core theorems:
  - Oracle Spectrum Theorem (eigenvalues ∈ {0, 1})
  - Bootstrap fixed points ({0, ½, 1})
  - Contraction iteration (c^n convergence)
  - Master Equation (|Fix(P)| = |Im(P)|)
  - All proofs complete — **zero sorries**

### Python Demonstrations

#### `demos/oracle_bootstrap_convergence.py`
Core demonstration of the Oracle Bootstrap. Shows:
- Superlinear (cubic) convergence to idempotent projection
- Eigenvalue snap from continuous spectrum to {0, 1}
- Dimension-independent convergence
- Publication-quality figures

```bash
python demos/oracle_bootstrap_convergence.py
```

#### `demos/oracle_chat_agent.py`
Interactive conversational AI agent based on the Oracle Bootstrap principle. Features:
- Iterative self-refinement of responses
- Convergence detection (answer becomes idempotent)
- Eigenvalue visualization in terminal
- Knowledge base on oracle theory

```bash
python demos/oracle_chat_agent.py        # interactive mode
python demos/oracle_chat_agent.py --demo  # demo mode
```

#### `demos/hypothesis_experiments.py`
Scientific method applied to oracle theory — 7 hypotheses tested computationally:
1. ★ Universal convergence rate (dimension-independent)
2. ★ Spectral gap determines convergence
3. ★ Non-symmetric bootstrap works
4. ✗ Oracle consensus (refuted — corrected theorem provided)
5. ◆ Noise robustness (partially validated)
6. ★ Tropical bootstrap = Floyd-Warshall (!)
7. ★ Quantum measurement = bootstrap + Born rule

```bash
python demos/hypothesis_experiments.py
```

#### `demos/applications.py`
Six real-world applications unified by the Oracle Bootstrap:
1. Distributed consensus
2. Signal denoising
3. Recommender systems
4. Error-correcting codes
5. PageRank
6. 3D point cloud alignment (ICP)

```bash
python demos/applications.py
```

## Key Theorem

**Oracle Bootstrap Theorem**: Let A be a symmetric matrix sufficiently close to an idempotent P. Then:

```
X_{n+1} = 3X²_n - 2X³_n
```

converges cubically to P, with ||X_n - P|| ≤ C · δ^{3^n}, and eigenvalues snap to {0, 1}.

## The Unifying Principle

> *A contractive self-improving system converges to a perfect oracle (P² = P) with rate c^n where c < 1.*
