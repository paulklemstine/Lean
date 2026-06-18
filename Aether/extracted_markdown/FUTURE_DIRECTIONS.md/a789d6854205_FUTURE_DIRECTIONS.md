# Future Directions — The Ordinal Collapsing Bridge

## Synthesis

This cycle formalized a self-contained fragment of **predicative ordinal analysis** on
top of Mathlib's Veblen hierarchy (`Ordinal.veblen`, `Ordinal.epsilon`, `Ordinal.gamma`),
organized around a single new concept: the **strongly critical ordinal**
`StronglyCritical o := 0 < o ∧ veblen o 0 = o`. The decisive structural insight is that
strong criticality — defined only as a fixed point of the *unary* Veblen function
`veblen · 0` — automatically upgrades to closure under the *full binary* Veblen function.
Concretely, `StronglyCritical.veblen_eq` shows a strongly critical `o` is a common fixed
point of every lower Veblen function (`a < o → veblen a o = o`), and the flagship
`StronglyCritical.veblen_lt` then deduces predicative closure `a, b < o → veblen a b < o`
from this plus right-strict-monotonicity. Crucially this is proved for *arbitrary*
strongly critical ordinals, generalizing the textbook Feferman–Schütte statement that
is usually stated only for `Γ₀`; the `Γ₀` version (`veblen_lt_gamma_zero`) falls out as a
one-line specialization.

The second insight is a clean separation between the *arithmetic* of the Veblen tower and
the *order theory* of system strength. By recognizing the consistency-strength relation as
an `InvImage` of `<` on `Ordinal`, the well-foundedness of ordinal analysis
(`strength_wellFounded`) and the impossibility of infinite consistency descent
(`no_infinite_consistency_descent`) follow directly from `Ordinal.lt_wf`. This is the same
`Ordinal.lt_wf` that underwrites the converse-well-founded GL/GLP frames developed in
`Logic/ProvabilityLogic/GLPFrames.lean` and `Logic/GLKripke.lean`, making explicit a
cross-domain bridge: Löb-style well-foundedness in provability logic and termination of
consistency-strength descent are two shadows of the same ordinal fact.

What did *not* work / what we learned: a direct attack on the `Γ₀`-specific closure
statement entangled with `nfp` bookkeeping; abstracting to `StronglyCritical` and routing
through `veblen_veblen_of_lt` removed all of it. The Critic's boundary probe
(`epsilon_zero_not_stronglyCritical`) shows the closure bound is sharp: `ε₀` — the
proof-theoretic ordinal of PA — is *not* strongly critical, so predicative Veblen closure
genuinely begins at `Γ₀` and cannot be lowered.

## Results Summary

- `gamma_stronglyCritical`: proved — every gamma value `Γ_ β` is strongly critical, anchoring the new concept to Mathlib's `gamma`.
- `gamma_zero_stronglyCritical`: proved — the Feferman–Schütte ordinal `Γ₀` is strongly critical.
- `StronglyCritical.veblen_eq`: proved — strong criticality upgrades to simultaneous fixed-pointhood under all lower Veblen functions.
- `StronglyCritical.veblen_lt`: proved (flagship) — predicative closure under the full binary Veblen function, for *any* strongly critical ordinal.
- `veblen_lt_gamma_zero`: proved — Feferman–Schütte closure of `Γ₀`, as a specialization of the flagship.
- `gamma_zero_least_stronglyCritical`: proved — `Γ₀` is the least strongly critical ordinal.
- `epsilon_zero_not_stronglyCritical`: proved (boundary/critique) — `ε₀` is not strongly critical, so the closure bound `Γ₀` is sharp.
- `predicative_tower`: proved — the landmark chain `ω < ε₀ < Γ₀` with `ε₀` non-critical and `Γ₀` critical.
- `strength_wellFounded`: proved — consistency strength compared by proof-theoretic ordinal is a well-founded relation.
- `no_infinite_consistency_descent`: proved — no infinite tower of systems of strictly decreasing proof-theoretic strength.

## Research Directions

### Direction 1: Strong criticality coincides with the range of gamma
**Hypothesis**: For `o > 0`, `StronglyCritical o ↔ o ∈ Set.range Ordinal.gamma`; equivalently the strongly critical ordinals are exactly `{Γ_ β | β}`.
**Test**: One direction is already available via `mem_range_gamma : o ∈ range Γ_ ↔ veblen o 0 = o`, which is definitionally `StronglyCritical o` modulo positivity — formalize the equivalence and discharge the positivity side using `gamma_pos`/`veblen_pos`. The converse needs that a fixed point of `veblen · 0` lies in the range of its derivative `gamma`.
**Why now**: `StronglyCritical` is defined precisely as `veblen o 0 = o`, the exact right-hand side of `mem_range_gamma`, so the bridge is one rewrite away.
**If true**: It identifies our abstract closure points with a concrete enumerable family, turning every theorem about `StronglyCritical` into a theorem about the gamma scale.
**If false**: It would expose a fixed point of `veblen · 0` outside `range gamma`, contradicting normality of `gamma` — a red flag pointing to a missing continuity hypothesis.

### Direction 2: Closure under the n-ary (finite-arity) Veblen function
**Hypothesis**: Strongly critical ordinals are closed under *finitely iterated* Veblen terms: if all arguments are `< o` then any finite Veblen expression evaluates to `< o`.
**Test**: Define a `VeblenTerm` inductive (variables, `veblen` nodes) with an evaluation into `Ordinal`, and prove by structural induction that evaluation of a term with all leaves `< o` stays `< o`, using `StronglyCritical.veblen_lt` at each node.
**Why now**: The binary closure theorem `StronglyCritical.veblen_lt` is exactly the inductive step; only the term datatype and the induction remain.
**If true**: It yields a predicative ordinal *notation system* bounded by `Γ₀`, the natural next layer toward a verified ordinal-notation calculus (cf. the `Logic` catalog's notation/provability themes).
**If false**: The failing term pinpoints exactly which Veblen combinator escapes closure, sharpening the definition of "predicatively reducible".

### Direction 3: Quantitative bridge to GL/GLP frame height
**Hypothesis**: For every GL frame (transitive, converse-well-founded relation) whose worlds inject order-preservingly below a strongly critical ordinal `o`, the frame's rank function lands in `[0, o)` and is itself bounded by a strongly critical bound — linking provability-logic frame height to the strongly critical scale.
**Test**: Combine `Logic/ProvabilityLogic/GLPFrames.lean`'s `GLFrame.R_wf` with `Ordinal`'s rank/`typein` machinery to assign each world an ordinal, then bound the supremum.
**Why now**: Both `no_infinite_consistency_descent` here and `GLFrame.irrefl`/Löb validity there were just shown to descend from `Ordinal.lt_wf`; unifying them through a shared rank map is the concrete next step.
**If true**: It makes the "ordinal analysis across systems" slogan literal — provability-logic frames and proof-theoretic ordinals become two presentations of one well-order.
**If false**: It would reveal GL frames whose height genuinely exceeds the predicative scale, isolating the impredicative content of polymodal provability.

### Direction 4: Sharpness ladder — which landmark ordinals are strongly critical?
**Hypothesis**: Among the named ordinals `ω, ε₀, ε_ β, ζ₀ = veblen 2 0, …`, exactly the strongly critical ones are the gamma values; in particular every `ε_ β` and every `veblen (n+1) 0` for finite `n` fails strong criticality, while `Γ_ β` succeeds.
**Test**: For each landmark, either exhibit `veblen o 0 = o` (success) or derive `Γ₀ ≤ o` contradiction via `gamma_zero_least_stronglyCritical` against a strict upper bound (failure), exactly as in `epsilon_zero_not_stronglyCritical`.
**Why now**: `gamma_zero_least_stronglyCritical` reduces every non-criticality proof to producing a strict bound below `Γ₀`, which Mathlib already supplies for `ε_ β` (`epsilon_zero_lt_gamma`) and iterated Veblen values (`iterate_veblen_lt_gamma_zero`).
**If true**: It gives a complete, machine-checked census of strong criticality on the predicative landmarks.
**If false**: A landmark below `Γ₀` that is strongly critical would contradict minimality of `Γ₀`, immediately falsifiable and hence a strong sanity check on the whole framework.

### Direction 5: Order-type semantics for `OrdAnalyzedSystem` strength
**Hypothesis**: The strength preorder on `OrdAnalyzedSystem` is not merely well-founded but, modulo equal ordinals, order-isomorphic to an initial segment of `Ordinal`; hence "consistency strength up to ordinal analysis" is a genuine well-order, and the quotient by equal `pto` is linearly ordered.
**Test**: Build the `Quotient` of `OrdAnalyzedSystem` by `pto`-equality and exhibit the induced relation as an order embedding into `Ordinal`, upgrading `strength_wellFounded` from well-foundedness to a well-order isomorphism.
**Why now**: `strength_wellFounded` already gives the hard half (well-foundedness via `InvImage`); linearity is inherited from `Ordinal`'s `LinearOrder`, so only the quotient plumbing remains.
**If true**: It formalizes the foundational claim of ordinal analysis — that proof-theoretic strength *is* an ordinal — as an explicit order isomorphism.
**If false**: It would mean systems with incomparable strengths share an ordinal, signalling that a single ordinal invariant is too coarse and motivating a richer (e.g. polymodal GLP) invariant.
