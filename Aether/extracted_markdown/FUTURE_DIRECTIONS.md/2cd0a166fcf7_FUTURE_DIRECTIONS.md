# Future Directions — Tropical–Ultrametric Myhill–Nerode Compression

## Synthesis

This cycle fused three previously disconnected catalog frameworks into a single
quantitative theory of neural state compression:

* the coalgebraic neural Myhill–Nerode machinery
  (`Bridges/CoalgebraicNeuralMyhillNerode.lean`): `NeuralObservationSystem`,
  `neural_behavior`, `neural_equiv`, the behavioral setoid and its quotient
  `quotient_neural_system`, and the word enumerators `wordsUpTo`/`wordsOfLength`;
* the tropical "addition = max" idempotent principle from
  `Bridges/CategoricalTropicalUltrametric.lean`;
* the non-Archimedean "max not sum" depth law motivating `vdepth_sum_le` in
  `Computation/PadicValuationDepth.lean`.

The new file `Bridges/ValuatedNeuralMyhillNerode.lean` introduces a
`ValuatedNeuralObservationSystem` — a neural observation system equipped with a
valuation `val : β → ℕ` — and develops a depth-indexed *valuation signature*
`vsig` together with a tropical *signature weight* `vweight` (the `max` over the
signature). The central message: **the valuation is a sound, one-sided
refinement of behavioral equivalence whose finite-depth truncations are
computable, monotone, quotient-stable, and grow by `max` rather than by sum.**

## Results Summary (all proved, `sorry = 0`, only standard axioms)

1. `behaviorally_equiv_imp_same_signature` — behavioral equivalence implies equal
   valuation signatures at *every* depth (soundness of the valuation invariant);
   `behaviorally_equiv_imp_val_equiv` is the pointwise form.
2. `signature_separation` — distinct depth-`n` signatures *certify* behavioral
   inequivalence; this is the falsifiable, one-sided separation principle.
3. `sig_equiv_succ_imp` — monotonicity: depth-`(n+1)` signature equality refines
   to depth-`n` equality (deeper observation only splits classes), via the
   append decomposition `vsig_succ_append` and prefix injectivity.
4. `quotient_vsig_preserved` (and `quotient_vbehavior_preserved`) — the
   behavioral quotient is a *sound compression*: compressed states carry exactly
   the original valuation signatures.
5. `vweight_succ_eq_max`, `vweight_mono`, `vweight_behaviorally_invariant` — the
   tropical signature weight obeys the ultrametric growth law
   `vweight (n+1) = max (vweight n) (new layer)`, hence is monotone in depth and
   a behavioral invariant. The supporting `foldr_max_append` is the idempotent
   distributivity lemma.

A deliberate negative boundary result frames the work: the **converse**
("equal signatures ⇒ behaviorally equivalent") is *false* in general — collapsing
`val` to a constant equalizes all signatures while leaving behavior arbitrary.
This is exactly why the sound, one-sided separation theorem is the correct,
testable form rather than a full completeness claim.

## Research Directions

### 1. A quantitative completeness threshold via injective valuations

The converse of soundness fails for arbitrary `val`, but it should hold under an
*injectivity/faithfulness* hypothesis on the valuation. **The key insight is**
that completeness is not a property of the system but of the valuation: if
`val` is injective on the reachable observation set, then equal signatures at all
depths must force `neural_equiv`, recovering a genuine Myhill–Nerode
*characterization* rather than a one-sided certificate. Conjecture: for a
`ValuatedNeuralObservationSystem` whose `val` is injective on the image of
`neural_behavior`, `(∀ n, sig_equiv V A n s t)` over a generating alphabet `A`
implies `neural_equiv`. **Why now?** The soundness direction and the explicit
counterexample to naive completeness are already in place, so the remaining task
is to isolate the exact faithfulness hypothesis that closes the gap — a sharp,
falsifiable statement with a known failure mode to test against.

### 2. Finite stabilization depth bounds (effective minimization)

For finite state spaces, partition refinement stabilizes after finitely many
rounds. **The key insight is** that the valuation weight `vweight`, being
monotone and bounded by the maximum valuation, gives a numerical Lyapunov
function whose stabilization certifies that no deeper observation can refine the
quotient. Conjecture: if `σ` is finite with `|σ| = m`, then
`sig_equiv V A m s t → neural_equiv V.toNeuralObservationSystem s t`, i.e. depth
`m` suffices, yielding an `O(|A|^m)` minimization procedure. **Why now?** The
catalog already proves the `O(|A|^k)` budget bound (`wordsUpTo_length_bound`) and
this file adds the monotone weight; combining them turns the abstract refinement
into an effective, terminating algorithm with an explicit depth certificate.

### 3. Lipschitz / robustness transfer through the valuation functor

`CategoricalTropicalUltrametric` advertises *functorial bound transfer* from the
tropical world to ultrametric certified bounds. **The key insight is** that
`vweight` is a tropical seminorm on states, so a Lipschitz bound on `step`
(in valuation) should yield an ultrametric `vweight (n+1) ≤ vweight n + L`-style
contraction — but with `max`, giving a *carry-free* certified robustness radius
for the compressed system. Conjecture: under an ultrametric Lipschitz hypothesis
on `val ∘ observe ∘ step`, `vweight` satisfies a depth-uniform bound independent
of `n`. **Why now?** The robustness vocabulary (`behaviorally_robust`,
`lipschitz_certified_robustness_behavior_invariant_under_quotient`) is already in
the coalgebraic file, and this cycle supplies the missing tropical size functional
to make the transfer quantitative.

### 4. Weighted (semiring-valued) valuation signatures

The coalgebraic file already has `WeightedNeuralObservationSystem` with
semiring-valued outputs. **The key insight is** that replacing `ℕ`-valued `val`
by a valuation into an ordered idempotent semiring (a genuine `TropObj`) unifies
weighted automata minimization with tropical valuation: `vweight` becomes the
tropical trace and `vsig` the tropical behavior matrix. Conjecture: the weighted
behavioral equivalence `weighted_neural_equiv` coincides with equality of all
tropical valuation signatures when the semiring is cancellative. **Why now?** Both
ingredients (`WeightedNeuralObservationSystem` and `TropicalValuationObject`) sit
in the catalog unconnected; this file is the first bridge, and generalizing `ℕ`
to `TropObj` is the natural next structural step.

### 5. Compression ratio lower bounds from signature entropy

**The key insight is** that the number of distinct depth-`n` signatures lower
bounds the size of *any* faithful realization, turning signatures into an
information-theoretic compression certificate. Conjecture: the cardinality of
`{ vsig V A n s | s }` is a monotone lower bound for the quotient state count, and
its limit equals the minimal realization size when valuations are faithful
(direction 1). **Why now?** The minimality theorems
(`quotient_state_count_le_original`, the injective-morphism bound) already exist
for the unvalued quotient; pairing them with the now-available signature sets
yields concrete, computable compression-ratio bounds — a falsifiable claim
testable on small explicit systems.
