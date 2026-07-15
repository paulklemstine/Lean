/-
Aggregator for the deliverable modules of this research cycle
(graph coloring / chromatic polynomial, and the cross-domain connectors).
Building this target compiles every deliverable file end-to-end.
-/

-- Chromatic polynomial / graph coloring core
import Catalog.Combinatorics.ChromaticPolynomial
import Catalog.Combinatorics.ChromaticPolynomialColorable
import Catalog.Novelty.EmotionalChromaticNumber

-- Additional graph-coloring theorems
import Catalog.Novelty.GreedyDegreeColoring
import Catalog.Novelty.IndependenceRatioChromatic
import Catalog.Novelty.StrongChromaticBipartite
import Catalog.Novelty.UnitDistanceGraph
import Catalog.Novelty.UnitDistanceChromaticBridge
import Catalog.Novelty.C4FreeDiameter2
import Catalog.Novelty.C4FreeDiameter2Coloring

-- Cross-domain connector: factorial number system as an instance of mixed-radix
import Catalog.Computation.MixedRadixNumberSystem
import Catalog.Computation.FactorialNumberSystem
import Catalog.Speculative.AutoResearch.MixedRadixFactorialBridge

-- Cross-domain connector: Fibonacci primitive divisors (Carmichael)
import Catalog.Shared.CarmichaelHelper
import Catalog.Shared.CarmichaelProof
import Catalog.Speculative.AutoResearch.CarmichaelComposite
import Catalog.Speculative.CarmichaelPrimitiveDivisor