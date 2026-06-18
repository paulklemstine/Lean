# Lean File Organization

## AllLeanFiles/ (677 files)
All 677 `.lean` files collected into a single flat directory. Files are named using their
original path with `/` replaced by `__` to avoid collisions. For example,
`Oracle/GodOracle/SelfReference.lean` becomes `Oracle__GodOracle__SelfReference.lean`.

## Categorized/ (677 files in 17 categories)

All files sorted into thematic subdirectories:

| Category | Files | Source Directories |
|---|---|---|
| **Algebra** | 24 | `Algebra/`, `AlgebraicTheoryOfAlgebra/` |
| **Analysis** | 12 | `Analysis/` |
| **CategoryTheory** | 8 | `CategoryTheory/`, `LanglandsProgram/` |
| **Combinatorics** | 8 | `Combinatorics/` |
| **Computation_and_Oracles** | 95 | `Oracle/`, `OracleCouncil/`, `OracleResearchLab/`, `AStarFactoring/`, `Factoring/`, `FibonacciFactoring/`, `QuaternionFactoring/`, `OctonionGateComputation/` |
| **Cryptography** | 16 | `QuantumCryptoAttacks/`, `ZeroKnowledge/`, `Ethereum/` |
| **Geometry** | 27 | `Stereographic/`, `SphericalUniverse/` |
| **InformationTheory** | 15 | `Information/` |
| **Logic_and_Foundations** | 70 | `Logic/`, `Foundations/`, `Bootstrapping/`, `FormalizingTheUnformalizable/` |
| **MachineLearning_and_AI** | 35 | `Neural/`, `MachineConsciousness/`, `QuantumTransformer/`, `Prediction/` |
| **NumberTheory** | 25 | `NumberTheory/`, `Diophantine/`, `RiemannHypothesis/`, `IntegerEnergy/` |
| **Physics** | 83 | `Physics/`, `AlgebraicPhysics/`, `AlgebraicNuclearPhysics/`, `AlgebraicSpacetime/`, `AlgebraicTime/`, `Electricity/`, `Quantum/`, `Photon/`, `ArithmeticPhotons/`, `AlgebraicReality/`, `AlgebraicSpaceTheory/`, `TheoryOfEverything/`, `ArchitectureOfMathematicalReality/`, `AlgebraicMagnetism/`, `AlgebraicMirror/` |
| **Probability** | 7 | `Probability/`, `RandomMatrix/` |
| **Pythagorean** | 65 | `Pythagorean/` |
| **Speculative_and_Exploratory** | 143 | `SciFiMath/`, `SciFiMathematics/`, `RudyRucker/`, `Forbidden/`, `GazingPool/`, `RosettaStone/`, `Duality/`, `CrossDomainUnification/`, `CrossExamination/`, `Exploration/`, `FiveFrontiers/`, `Frontier/`, `RoadAhead/`, `GoalPlanning/`, `OptimalPlanning/`, `IdempotentCollapse1/`, `IdempotentCollapse2/`, `OmegaTower/`, `ArithmeticUniverse/`, `Music/`, `Millennium/` |
| **Topology** | 11 | `Topology/` |
| **Tropical** | 33 | `Tropical/` |

## Notes
- The original project directories and `lakefile.toml` are preserved unchanged.
- Files in `AllLeanFiles/` and `Categorized/` are **copies** — the originals remain in place.
- File names in both new directories encode the original path using `__` as a separator.
