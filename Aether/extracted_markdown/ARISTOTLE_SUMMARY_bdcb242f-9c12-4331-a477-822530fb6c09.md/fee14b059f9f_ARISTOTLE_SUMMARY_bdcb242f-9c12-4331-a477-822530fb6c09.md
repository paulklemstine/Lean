# Summary of changes
I created a comprehensive Integer Orbit Factoring project in `Cryptography/OrbitFactoring/` with the following deliverables:

## Lean 4 Formalization (17 theorems, all machine-verified, zero sorries)

**`Basic.lean`** — Core definitions and 10 fundamental theorems:
- `orbitSeq` definition and properties (iterate equivalence, base/step cases)
- `pollardMap` definition and commutation with ring reduction homomorphisms
- **Factor-from-Collision Theorem**: shadow orbit collisions yield nontrivial gcd (both 1 < gcd and gcd < n)
- **Pigeonhole Collision**: guaranteed collision within |α| steps
- **Eventual Periodicity**: every orbit on a finite type is eventually periodic
- **Floyd's Detection Guarantee**: ∃k ≤ |α|, f^[k](x₀) = f^[2k](x₀)
- **Orbit Map Commutation**: homomorphisms commute with iteration

**`Advanced.lean`** — 7 advanced results:
- **Brent's Detection Guarantee**: cycle detection within 3|α| steps
- **Period-LCM Decomposition**: product orbit period = lcm of component periods (CRT foundation)
- **Multi-Polynomial Amplification**: k independent trials give exponentially decaying failure probability
- **Order-Period Connection**: orderOf divides d implies a^d = 1
- **Period Divisibility**: reduction maps preserve periodicity

## Documentation (`docs/`)
- **`research_paper.md`**: Full research paper with 7 sections covering definitions, core theorems, novel results (orbit density, multi-polynomial amplification, hierarchical decomposition), and applications
- **`scientific_american_article.md`**: Popular science article explaining orbit factoring for a general audience
- **`applications.md`**: 8 new application areas including post-quantum analysis, PRNG testing, distributed factoring, ECM enhancement, blockchain security, and ML-guided polynomial selection
- **`research_team_brainstorm.md`**: Research team brainstorming document with 5 new hypotheses, 4 experimental plans, 4 knowledge upgrades, and 5 open questions

## Python Demos (`demos/`)
- **`pollard_rho.py`**: Interactive demonstrations of Floyd's rho, Brent's rho, multi-polynomial factoring, shadow orbit analysis, and birthday bound verification. All run successfully.
- **`orbit_experiments.py`**: Experimental validation scripts for polynomial degree comparison, multi-polynomial speedup verification, hierarchical factor discovery, and autocorrelation analysis.

## SVG Visuals (`visuals/`)
- **`orbit_rho.svg`**: The ρ-shaped orbit with labeled tail and cycle
- **`shadow_orbits.svg`**: How the full orbit projects onto shadow orbits mod p and mod q, showing collision-based factor discovery
- **`hierarchical_lattice.svg`**: Divisor lattice showing how orbit projections at every level encode factor information
- **`floyd_vs_brent.svg`**: Side-by-side comparison of Floyd's and Brent's cycle detection algorithms