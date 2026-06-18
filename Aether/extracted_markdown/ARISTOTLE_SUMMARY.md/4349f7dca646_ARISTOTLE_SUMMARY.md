# Summary of changes for run 8e72bd6b-610a-4c94-992a-b3149d4eb7d8
# Tropical One-Way Functions from Matrix Powering — Complete

## Deliverable 1: Formally Verified Mathematics

**File**: `Catalog/Tropical/OneWayFunctions/Theorems.lean` (239 lines, 0 sorries)

All theorems are fully proved with only standard axioms (propext, Classical.choice, Quot.sound). The formalization contains:

### Core Definitions
- `TropMat n` — n×n matrices over `WithTop ℤ` (the min-plus semiring)
- `tropMatMul` — min-plus matrix multiplication via `Finset.inf`
- `tropMatId` — tropical identity (0 on diagonal, ⊤ off diagonal)
- `tropMatPow` — iterated tropical power
- `StrictlySeparated` / `DiagSeparated` — unique minimizer conditions
- `IsTropPowerImage`, `TropPowerInverter`, `InvertsTropPower` — inversion framework
- `orbitHash` — orbit hash generator

### Proved Theorems (10 total, all sorry-free)

**Layer 1 — Structural Semantics:**
- `tropMatMul_id_left/right` — tropical identity laws
- `tropMatPow_one` — G¹ = G
- `tropMatPow_two_entry` — G²(i,j) = inf_m (G(i,m) + G(m,j)) — the path semantics theorem
- `tropMatMul_assoc` — associativity of tropical multiplication
- `tropMatPow_add` — power addition law: G^(a+b) = G^a ⊗ G^b

**Layer 2 — Structural Recovery:**
- `tropical_square_diag_determines_diag` — diagonal entries of G are uniquely determined by G² when G is diagonal-separated
- `midpoint_sum_lower_bound` — the unique midpoint sum provides a lower bound for any preimage
- `exact_inverter_recovers_midpoints` — any correct inverter returns valid preimages

**Layer 3 — Security Transfer:**
- `inverter_from_correct_inverter` — the framework is non-vacuous
- `orbit_hash_consistency_from_inverter` — orbit hash outputs are verifiable via inversion

### Important Discovery
During formalization, I discovered and proved that the originally proposed "tropical square injectivity on strictly separated instances" theorem is **false**. A concrete counterexample: G = [[1,3,7],[5,2,4],[8,6,3]] and H = [[1,3,100],[5,2,4],[8,6,3]] satisfy G² = H² despite G ≠ H, even though G is strictly separated. The issue is "invisible edges" — edges that never appear on any shortest two-hop path. This is documented in the research paper and demonstrated in the Python code.

## Deliverable 2: Popular Science Article
**File**: `ARTICLE.md` (~2000 words)

## Deliverable 3: Research Paper
**File**: `RESEARCH_PAPER.md` (~4000 words, with full theorem statements, proof sketches, algorithms, and references)

## Deliverable 4: Python Code
- `demo.py` — 7 demonstrations covering path semantics, separation analysis, counterexamples, power addition, orbit hashing, and midpoint bounds
- `algorithms.py` — Core algorithms (trop_mul, trop_pow, separation_gap, naive_inversion_attack) with docstrings and complexity analysis
- `applications.py` — 4 applications (shortest paths, job scheduling, key exchange concept, network resilience)
- `visualizations.py` — 4 publication-quality figures saved as PNG

## Deliverable 5: Future Directions
**File**: `FUTURE_DIRECTIONS.md` — 5 concrete research directions:
1. Average-case hardness for random tropical matrices
2. Tropical trapdoor functions
3. Min-plus PRG from orbit iteration
4. Reductions to control-system identification
5. Formal complexity classes for semiring computation

## Deliverable 6: JSON Package
**File**: `PACKAGE.json` — Complete bundle with all content, base64-embedded visualizations, and self-contained Python demos.