# Future Directions: Rota's Basis Conjecture

## 1. Rota's Basis Conjecture for Rank 3

The rank-2 case proved in this cycle uses a clean matching argument: four applications of the exchange property force one of two matchings to work, via a propositional pigeonhole argument (`matching_logic`). For rank 3, the analogous statement requires finding a system of three disjoint transversals across three bases, each forming a basis. The combinatorial complexity grows sharply — instead of 2 matchings, we have 6 possible column assignments (permutations of 3 elements), and the exchange constraints form a more intricate hypergraph.

**The key insight is:** the rank-3 case may reduce to a Hall's marriage theorem argument. Given three bases B₁, B₂, B₃ of a rank-3 matroid, define a bipartite graph where column indices are matched to elements, with edges representing "independence-compatible" assignments. If we can show Hall's condition holds for each column simultaneously (via iterated exchange), the conjecture follows. This would generalize the rank-2 matching logic to a Hall-type criterion.

**Why now?** The `ExchangeSystem` infrastructure and `matching_logic` template from this cycle provide the right abstraction level. The rank-3 case is the smallest open case of Rota's conjecture and would constitute a genuine advance.

## 2. Symmetric Exchange in Full Generality

We proved symmetric exchange for rank-2 exchange systems by reducing to `rota_two_matching`. The general symmetric exchange property — for any two bases B₁, B₂ of any rank and e ∈ B₁ \ B₂, there exists f ∈ B₂ \ B₁ such that both (B₁ - e + f) and (B₂ - f + e) are bases — is a classical theorem of matroid theory that holds for all ranks.

**The key insight is:** the general proof requires the theory of matroid circuits. For a base B and element e ∉ B, the set B ∪ {e} contains a unique circuit C(e, B). The symmetric exchange works by showing that for e ∈ B₁ \ B₂, any f ∈ C(e, B₁') ∩ (B₂ \ B₁) (where B₁' is obtained by a preliminary exchange) satisfies both exchange conditions simultaneously. Formalizing the circuit theory would unlock this and many other matroid results.

**Why now?** Mathlib's matroid library (`Matroid.IsBase`, `Matroid.Indep`) already exists but lacks circuit theory. Building `Matroid.Circuit` with the unique circuit lemma would bridge the gap and enable a wave of matroid formalizations.

## 3. Partial Rota Results via Latin Squares

Aharoni and Berger (2006) proved that for any n bases of a rank-n matroid, one can always find ⌊n/2⌋ disjoint independent transversals. This is the strongest known partial result toward the full conjecture.

**The key insight is:** the proof uses topological methods (the Meshulam lemma on simplicial complexes) to establish the existence of partial transversals. Formalizing this would require connecting matroid independence complexes with simplicial homology. The `ExchangeSystem` structure from this cycle already captures the matroid axioms; what's missing is the topological machinery.

**Why now?** Mathlib has growing support for simplicial complexes (`SimplicialComplex`) and homology. A formalization of the Aharoni-Berger result would bridge combinatorics and algebraic topology in a novel way.

## 4. Rota's Conjecture for Strongly Base-Orderable Matroids

A matroid is *strongly base-orderable* if for any two bases B₁, B₂, there exists a bijection σ : B₁ → B₂ such that for every subset S ⊆ B₁, both (B₁ \ S) ∪ σ(S) and (B₂ \ σ(S)) ∪ S are bases. For strongly base-orderable matroids, Rota's conjecture is known to hold (this is essentially by definition — the bijections compose to give the grid).

**The key insight is:** many natural matroid classes are strongly base-orderable, including all gammoids, transversal matroids, and matroids of rank ≤ 2 (which we proved). Formalizing the definition and proving that specific matroid classes satisfy it would give a systematic way to verify Rota's conjecture for broad families.

**Why now?** The `ExchangeSystem` structure can be extended with a `StronglyBaseOrderable` predicate. The rank-2 proof already implicitly establishes this property (the matching IS the bijection σ). Generalizing to gammoids would connect to network flow theory.

## 5. Computational Verification for Small Ranks

While the rank-2 case is proved for all matroids, ranks 3-5 can potentially be verified computationally for all matroids on small ground sets. A Lean formalization using `Decidable` instances and `native_decide` could verify Rota's conjecture for all matroids of rank n on ground sets of size ≤ m, for specific small (n, m).

**The key insight is:** matroids on small ground sets can be enumerated (Mayhew and Royle have catalogs up to 9 elements). For each matroid and each tuple of n bases, checking whether a valid Rota grid exists is a constraint satisfaction problem solvable by backtracking. A verified enumeration would give machine-checked proofs for millions of instances.

**Why now?** The `ExchangeSystem` definition is already `Decidable`-friendly (using `Finset`). Adding `DecidablePred M.IsBase` instances and a backtracking grid search algorithm would enable `native_decide` proofs for small cases, complementing the structural results for rank ≤ 2.
