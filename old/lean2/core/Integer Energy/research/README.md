# Integer Energy Research — Complete Deliverables

## Oracle Team: Ω-Σ-Π-Δ-Φ-Λ-Ψ-Θ

### 📋 Research Notes
- **[ORACLE_TEAM_NOTES.md](ORACLE_TEAM_NOTES.md)** — Complete research log: divine consultation, team roster, 6 research phases, experimental findings, cross-domain synthesis

### 📄 Research Paper
- **[RESEARCH_PAPER.md](RESEARCH_PAPER.md)** — Full academic paper: "The Energy of Integers: Structure, Information, and Automated Reasoning" (7 sections, formal definitions, experimental results, Riemann Hypothesis connection)

### 📰 Scientific American Article
- **[SCIENTIFIC_AMERICAN_ARTICLE.md](SCIENTIFIC_AMERICAN_ARTICLE.md)** — Popular science article: "The Secret Energy of Numbers" (accessible narrative, historical connections, Plato to Ramanujan to AI)

### 🐍 Python Demos
- **[../demos/integer_energy_explorer.py](../demos/integer_energy_explorer.py)** — 8 visualization demos (energy landscape, champions, spectrum, solver correlation, factorization landscape, Robin's inequality, injection experiment, 5040 deep dive)
- **[../demos/energy_solver_benchmark.py](../demos/energy_solver_benchmark.py)** — Full benchmark framework (6 strategies × 4 theorem types × 4 difficulties, 150 trials each)

### 📊 Visualizations (output/)
| File | Description |
|------|-------------|
| `01_energy_landscape.png` | All 5 energy measures for integers 2-500 |
| `02_energy_champions.png` | Top 30 integers by combined energy + radar decomposition |
| `03_energy_spectrum.png` | Heatmap: normalized energy by measure and integer |
| `04_energy_solver.png` | Energy vs simulated solver performance |
| `05_factorization_landscape.png` | Prime factorization structure analysis |
| `06_robin_inequality.png` | Robin's inequality and the RH boundary at 5040 |
| `07_energy_injection_experiment.png` | Energy injection: sequential vs energy-first vs random |
| `08_5040_deep_dive.png` | Deep dive into 5040 = 7! |
| `09_solver_benchmark.png` | Full benchmark: 6 strategies × 4 theorem types |
| `10_speedup_summary.png` | Speedup chart: energy-sorted vs sequential |

### 🔬 Lean 4 Formalization
- **[../Exploration/IntegerEnergy.lean](../Exploration/IntegerEnergy.lean)** — 240 lines, 30+ machine-verified theorems, zero sorries:
  - Abundance ratio definition and bounds
  - Prime sigma computation: σ(p) = p + 1
  - Highly composite number characterization
  - 5040 properties: σ(5040) = 19344, d(5040) = 60, 5040 = 7!
  - IOF energy descent: monotonicity, closed form, drop formula
  - Arithmetic derivative: prime derivative = 1, p^p fixed point
  - Energy ordering: HCNs beat primes by 30x in divisor handles
  - Superabundant number definition and verification

### Key Findings
1. **Energy-sorted search gives 1.34x overall speedup** over sequential witness search
2. **Up to 40x speedup** on divisibility-structured problems at high difficulty
3. **5040 = 7!** is the most energetic small integer, sitting at the RH boundary
4. **Multiple independent energy measures converge** on the same champion integers
5. **The energy advantage is structural**: high-energy integers provide 30x more "proof handles" than primes
