/-
Aggregator for the deliverable modules of this research cycle
(graph coloring / chromatic polynomial, and the cross-domain connectors).
Building this target compiles every deliverable file end-to-end.
-/

-- Chromatic polynomial / graph coloring core
import Combinatorics.ChromaticPolynomial
import Combinatorics.ChromaticPolynomialColorable
import Novelty.EmotionalChromaticNumber

-- Additional graph-coloring theorems
import Novelty.GreedyDegreeColoring
import Novelty.IndependenceRatioChromatic
import Novelty.StrongChromaticBipartite
import Novelty.UnitDistanceGraph
import Novelty.UnitDistanceChromaticBridge
import Novelty.C4FreeDiameter2
import Novelty.C4FreeDiameter2Coloring

-- Cross-domain connector: factorial number system as an instance of mixed-radix
import Computation.MixedRadixNumberSystem
import Computation.FactorialNumberSystem
import Speculative.AutoResearch.MixedRadixFactorialBridge

-- Cross-domain connector: Fibonacci primitive divisors (Carmichael)
import Shared.CarmichaelHelper
import Shared.CarmichaelProof
import Speculative.AutoResearch.CarmichaelComposite
import Speculative.CarmichaelPrimitiveDivisor