# Future Directions: Computable Nonstandard Arithmetic

## Hypothesis 1: Filter-Generalized Transfer

**Conjecture:** Replacing eventual equivalence (agreement on a cofinite set) by equivalence modulo any free ultrafilter on ℕ yields a `HyperNat` structure that supports transfer for *all* first-order sentences in the language of ordered semirings — not just quantifier-free identities.

**Test:** Implement the construction over Mathlib's `Filter` and `Ultrafilter` APIs. Define `UltraHyperNat F := Quotient (ultrafilterSetoid F)` for an ultrafilter `F`. Prove the quantifier-free transfer theorem generalizes (this should follow from the same pointwise argument). Then attempt to prove Łoś's theorem for existential sentences: if `∃ x, P(x)` holds in ℕ, does `∃ x, P(x)` hold in `UltraHyperNat F`? Failure to define a well-behaved total order (the cofinite filter version only gives a preorder, not a total order) would refute the conjecture in the eventual-equivalence setting but confirm it for genuine ultrafilters.

**Impact:** A full Łoś theorem in formal mathematics would be the first machine-verified model-theoretic transfer principle, opening nonstandard analysis proper inside a proof assistant.

## Hypothesis 2: Automatic Predicate Descent

**Conjecture:** Every eventually stable MSO-recognizable predicate on unary-coded naturals descends to a well-defined predicate on `HyperNat`. Specifically, if `P : ℕ → Prop` is recognized by a Büchi automaton on the binary representation, and `P` is eventually stable (there exists `N` such that `P(n)` depends only on bits above position `N`), then the induced predicate on sequences `(fun f => ∀ᶠ n, P(f n))` respects eventual equivalence.

**Test:** Formalize a class of MSO-recognizable predicates on natural numbers (e.g., "the binary representation contains an even number of 1s"). Show that for eventually stable predicates, the lifted predicate is invariant under eventual equivalence of input sequences. A counterexample automaton whose recognized set is not eventually stable (e.g., parity of the number itself) would refute the claim in full generality, clarifying the boundary.

**Impact:** This would connect formal nonstandard arithmetic to automata theory and decidability, potentially enabling automated reasoning about asymptotic properties of MSO-definable number-theoretic functions.

## Hypothesis 3: Polynomial Asymptotics as Hyperidentities

**Conjecture:** For all polynomials `p, q : Polynomial ℕ`, eventual inequality `p(n) ≤ q(n)` for all sufficiently large `n` is equivalent to `evalHyper p ω ≤ evalHyper q ω` in the eventual ordering on `HyperNat`.

**Test:** The forward direction (eventual inequality implies hyper-inequality) is already proved in our framework. For the reverse direction, prove: if `evalHyper p ω ≤ evalHyper q ω`, then `p(n) ≤ q(n)` for all sufficiently large `n`. This requires showing that the leading coefficient comparison determines the eventual ordering. A polynomial counterexample (if one exists) would identify a gap between the cofinite-filter quotient and a genuine ultrapower.

**Impact:** This would establish that polynomial growth comparisons are *exactly* captured by the hypernatural ordering, making `HyperNat` a complete decision procedure for polynomial asymptotic comparisons.

## Hypothesis 4: Hyper-Divisibility Completeness for Polynomial Sequences

**Conjecture:** Every divisibility relation between polynomial sequences that holds eventually is witnessed as divisibility in `HyperNat`, and conversely. That is, for polynomials `p, q : Polynomial ℕ`, `(∃ N, ∀ n ≥ N, p(n) ∣ q(n))` if and only if `hdvd (evalHyper p ω) (evalHyper q ω)`.

**Test:** The forward direction is proved. For the reverse, one must show that hyper-divisibility at omega implies eventual divisibility of the underlying polynomial sequences. Test with `p(n) = n`, `q(n) = n²` (should work), and `p(n) = n+1`, `q(n) = n` (should fail in both directions). A failure of the reverse direction for specific polynomial pairs would refute completeness and clarify what additional structure (e.g., ultrafilters) is needed.

**Impact:** Would establish `HyperNat` as a complete algebraic framework for reasoning about polynomial divisibility asymptotics, with applications to algebraic number theory and symbolic computation.

## Hypothesis 5: Nonstandard Complexity Witnesses

**Conjecture:** Asymptotic domination of computable functions `f = O(g)` — meaning `∃ C N, ∀ n ≥ N, f(n) ≤ C · g(n)` — can be represented as the existence of a standard constant `C` such that `mk f ≤ ofNat' C * mk g` in `HyperNat`'s eventual ordering. Moreover, this representation is functorial: if `f = O(g)` and `g = O(h)`, then the corresponding hypernatural inequalities compose.

**Test:** Formalize big-O notation via eventual inequalities. Prove that `f = O(g)` iff there exists `C : ℕ` with `le (mk f) (ofNat' C * mk g)`. Verify functoriality (transitivity of the representation). Test with concrete pairs: `f(n) = n`, `g(n) = n²` (should give `C = 1`); `f(n) = n log n`, `g(n) = n²` (requires encoding log). A mismatch between the standard big-O constant and the hypernatural witness constant would identify where the naive formulation breaks.

**Impact:** Would create a formal bridge between complexity theory and nonstandard arithmetic, enabling machine-verified reasoning about asymptotic resource bounds using algebraic methods rather than epsilon-delta arguments.
