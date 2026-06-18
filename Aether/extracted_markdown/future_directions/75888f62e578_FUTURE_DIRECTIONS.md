# Future Directions: Reverse Mathematics of Ramsey's Theorem

## 1. Formalize Seetapun's Cone Avoidance Theorem

Seetapun's theorem (1995) states that for every non-computable set C, every computable 2-coloring of pairs admits an infinite homogeneous set H that does not compute C. This is the key result separating RT²₂ from ACA₀. A formalization would require defining Turing reducibility and computable colorings in Lean 4, then proving that the Erdős–Rado iterative construction can be performed while avoiding a given Turing cone.

The key insight is that at each stage of the construction, we have two infinite sets to choose from (one for each color), and a priority argument shows we can always pick the one that doesn't compute C. This is a forcing argument disguised as a finite extension construction.

Why now? The Defs.lean framework already provides the `SymPairColoring` and `IsHomogeneous` infrastructure. Mathlib's computability library (`Mathlib.Computability.*`) provides Turing machines and reducibility, though the oracle computation model may need extension.

## 2. Formalize the Cholak–Jockusch–Slaman Decomposition Constructively

Our `CJS_decomposition` theorem (SRT²₂ + COH → RT²₂) currently uses the direct proof of RT²₂. A more informative formalization would give the *constructive reduction*: given an infinite homogeneous set for the stable part and a cohesive set, explicitly construct a homogeneous set for the original coloring. This would involve defining the stable part of a coloring (using the cohesive set to stabilize it), applying SRT²₂ to the stable part, and then using cohesiveness to transfer back.

The key insight is that any coloring c, when restricted to a cohesive set C for the sequence of sets R_i = {j : c(i,j) = true}, becomes stable. The CJS decomposition is thus an equivalence between RT²₂ and the conjunction SRT²₂ ∧ COH.

Why now? The definitions of `IsStable`, `IsCohesive`, and `SRT2_2` are already in place. The missing piece is the explicit construction of the stable part, which is a moderate formalization effort building on existing infrastructure.

## 3. Liu's Separation of RT²₂ from WKL₀

Liu (2012) proved that RT²₂ does not imply WKL₀ over RCA₀, completing the classification of RT²₂ in the Big Five. Formalizing this would require defining WKL₀ (every infinite binary tree has an infinite path) as a combinatorial principle, then constructing an ω-model satisfying RT²₂ but not WKL₀. This is significantly harder than the Seetapun separation.

The key insight is that Liu constructs a model where every set is low₂ (its double jump is computable from 0''), and shows RT²₂ can be satisfied within this class while WKL₀ requires sets that are not low₂.

Why now? The framework supports stating WKL₀ as a combinatorial principle about infinite binary trees (definable using `ℕ → Bool` sequences). The model construction, however, requires substantial computability infrastructure beyond what Mathlib currently provides.

## 4. Ramsey's Theorem for Higher Exponents: RT^n_k

Our formalization covers RT²₂ (pairs with 2 colors). The natural generalization is RT^n_k: every k-coloring of n-element subsets of ℕ has an infinite homogeneous set. The finite version (with explicit Ramsey numbers) is partially in the existing catalog (`Catalog/Algebra/Ramsey/Defs.lean`). Bridging the finite and infinite versions, and proving the Erdős–Rado generalization to higher arities, would be a significant formalization milestone.

The key insight is that the induction for RT^n_k proceeds by reducing to RT^{n-1}_{R(k)} — a coloring of (n-1)-sets with a potentially much larger number of colors — making the bound tower-exponential in n. This iterated pigeonhole structure directly generalizes our proof of `rt2_2_proof`.

Why now? The `SymPairColoring` structure naturally generalizes to n-uniform hypergraph colorings. The existing `RamseyProp` in the catalog provides the finite base case. Connecting these two frameworks is the immediate next step.

## 5. The Reverse Mathematics Zoo: Formalizing the Full Hierarchy

Beyond RT²₂, the reverse mathematics landscape includes dozens of principles (CAC, ADS, SADS, EM, COH, DNR, WWKL₀, etc.) with a rich web of implications and separations — the "reverse mathematics zoo" catalogued by Damir Dzhafarov and others. Formalizing even a fragment of this zoo in Lean 4 would be a landmark in formal mathematics. Each principle can be stated as a Prop about ℕ, sets, and sequences, using the framework established here.

The key insight is that many of these principles (CAC = chain-antichain, ADS = ascending-descending sequence) are natural combinatorial statements that fit the `Set ℕ` / `ℕ → ℕ` framework already established. The separations between them often require elaborate priority constructions, but the implications are typically short combinatorial arguments amenable to automated proving.

Why now? The `Defs.lean` module provides a reusable vocabulary (`Set.Infinite`, symmetric colorings, cohesiveness) that most zoo principles can be stated in. Each new principle and implication is a self-contained formal contribution, making this highly parallelizable across research cycles.
