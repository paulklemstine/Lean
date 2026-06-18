Formalize a conservative deepening of the neural pseudometric / proof-spectrum bridge, explicitly targeting the gaps identified in the previous attempt and avoiding any theorem whose proof requires unstated semantic assumptions.

Work in the exact setup of `Bridges.NeuralPseudometricProofSpectrumFunctor` and `Bridges.CoalgebraicNeuralMyhillNerode`. Do not introduce placeholders. Every theorem included must have a complete Lean proof.

Part I: depth-indexed separation and graded pseudometric.
1. Identify or define a predicate `SeparatesAtDepth : ℕ → α → α → Prop` capturing that some observation/context of depth at most or exactly `n` distinguishes two states. Use the notion already latent in the neural Myhill–Nerode development; do not invent a disconnected semantics.
2. Prove the structural lemmas actually needed for metric construction, preferably in the weakest form available from the catalog:
   - symmetry of separation,
   - monotonicity in depth,
   - the key ternary lemma: if `x` and `z` are separated by depth `n`, then `x` and `y` or `y` and `z` are separated by depth `n` (or an equivalent formulation on non-separation relations). If this exact statement is easier on the complementary equivalence relations `EqAtDepth n`, use that instead.
3. Define the least separating depth only when separation exists, e.g. via `Nat.find`, and define a dyadic distance
   - `0` when no separation exists,
   - `2^{-k}` or an equivalent order-valued encoding when `k` is the least separating depth.
   If real powers create unnecessary Lean overhead, replace the codomain by an order-isomorphic simpler type such as `WithTop ℕ`, `ℕ∞`, or a lexicographically ordered grade where smaller grade means closer. The goal is a rigorous graded pseudometric structure, not specifically real analysis.
4. Prove the core theorems only:
   - self-distance and symmetry,
   - `dist x y = 0 ↔` behavioral equivalence,
   - strong triangle inequality in the chosen codomain, derived from the depth lemma,
   - compatibility with the existing `obsDist` kernel if `obsDist` is already available.
5. If the real-valued dyadic version is easy after the order-valued version, add it as a corollary. Otherwise stop at the order-valued ultrametric and state clearly in comments why this is the robust formal core.

Part II: proof-spectrum bridge via evaluation pullback, not unconditional primality.
1. Inspect `Algebra.ProofSpectra.Core` and determine the exact data needed to build a point of the proof spectrum.
2. Given a fixed observation point `w₀`, define the evaluation map from the behavioral function algebra/construction to the output ring/domain used in the bridge.
3. Show that the behavior congruence associated to equality at `w₀` is the pullback of the equality/prime congruence on the codomain along evaluation.
4. Prove the spectrum-point result under explicit assumptions matching the library:
   - if the codomain equality congruence is prime, then the pulled-back congruence is prime;
   - if a faithful observation point identifies this pulled-back congruence with the global behavior congruence, conclude that the behavior congruence defines a spectrum point.
5. Do not claim that integral-domain output alone implies the global behavior congruence is prime unless the proof is fully formalized from existing lemmas. If needed, state the final theorem with the stronger but correct hypothesis that the codomain congruence at the chosen evaluation is prime and the point is faithful.

Deliverables:
- A single new Lean file with complete proofs and module docstring explaining the narrowed theorem package.
- The file should emphasize a reusable lemma schema: ultrametricity follows from nested finite-depth equivalences, and proof-spectrum points arise by congruence pullback along evaluation.
- Prefer small, solid theorems over ambitious incomplete ones.

Success criteria:
- No `sorry`, no placeholder theorem headers.
- The main statements compile.
- The resulting development clearly strengthens the existing bridge while correcting the previous overreach on primality.