/-
Aggregator for the deliverable modules of this research cycle
(graph coloring / chromatic polynomial, and the cross-domain connectors).
Building this target compiles every deliverable file end-to-end.
-/

-- Chromatic polynomial / graph coloring core
import Catalog.Combinatorics.RamseyTheory.ChromaticPolynomial
import Catalog.Combinatorics.RamseyTheory.ChromaticPolynomialColorable
import Catalog.Novelty.RamseyTheory.EmotionalChromaticNumber

-- Additional graph-coloring theorems
import Catalog.Novelty.GraphTheory.GreedyDegreeColoring
import Catalog.Novelty.RamseyTheory.IndependenceRatioChromatic
import Catalog.Novelty.RamseyTheory.StrongChromaticBipartite
import Catalog.Novelty.NumberTheory.UnitDistanceGraph
import Catalog.Novelty.RamseyTheory.UnitDistanceChromaticBridge
import Catalog.Novelty.RamseyTheory.C4FreeDiameter2
import Catalog.Novelty.GraphTheory.C4FreeDiameter2Coloring

-- Cross-domain connector: factorial number system as an instance of mixed-radix
import Catalog.Computation.NumberTheory.MixedRadixNumberSystem
import Catalog.Computation.FactorialNumberSystem.FactorialNumberSystem
import Catalog.Speculative.AutoResearch.MixedRadixFactorialBridge

-- Cross-domain connector: Fibonacci primitive divisors (Carmichael)
import Catalog.Shared.NumberTheory.CarmichaelHelper
import Catalog.Shared.NumberTheory.CarmichaelProof
import output-final_aristotle.Shared.CarmichaelComposite
import Catalog.Speculative.NumberTheory.CarmichaelPrimitiveDivisor