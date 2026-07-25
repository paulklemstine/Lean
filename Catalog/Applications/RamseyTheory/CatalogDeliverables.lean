/-
Aggregator for the deliverable modules of this research cycle
(graph coloring / chromatic polynomial, and the cross-domain connectors).
Building this target compiles every deliverable file end-to-end.
-/

-- Chromatic polynomial / graph coloring core
import Combinatorics.RamseyTheory.ChromaticPolynomial
import Combinatorics.RamseyTheory.ChromaticPolynomialColorable
import Novelty.RamseyTheory.EmotionalChromaticNumber

-- Additional graph-coloring theorems
import Novelty.GraphTheory.GreedyDegreeColoring
import Novelty.RamseyTheory.IndependenceRatioChromatic
import Novelty.RamseyTheory.StrongChromaticBipartite
import Novelty.NumberTheory.UnitDistanceGraph
import Novelty.RamseyTheory.UnitDistanceChromaticBridge
import Novelty.RamseyTheory.C4FreeDiameter2
import Novelty.GraphTheory.C4FreeDiameter2Coloring

-- Cross-domain connector: factorial number system as an instance of mixed-radix
import Computation.NumberTheory.MixedRadixNumberSystem
import Computation.FactorialNumberSystem.FactorialNumberSystem
import Speculative.AutoResearch.MixedRadixFactorialBridge

-- Cross-domain connector: Fibonacci primitive divisors (Carmichael)
import Shared.NumberTheory.CarmichaelHelper
import Shared.NumberTheory.CarmichaelProof
import output-final_aristotle.Shared.CarmichaelComposite
import Speculative.NumberTheory.CarmichaelPrimitiveDivisor