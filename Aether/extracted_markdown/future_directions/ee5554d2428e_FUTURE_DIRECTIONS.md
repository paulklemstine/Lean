# Future Directions — Dream Logic (Tropical, paraconsistent, non-monotone)

This cycle built a tropical model of paraconsistent, non-monotone reasoning
(`Tropical.DreamLogic.{Core, Paraconsistency, NonMonotone}`): a Belnap–Ginsberg
bilattice on pairs of tropical reals whose knowledge-merge is the max-plus
operation `kjoin`. We proved the algebraic laws, the failure of explosion
(`explosion_fails`), coexistence of contradictions (`coexist`), and
non-monotonicity of defeasible support driven by tropical merge
(`nonmonotone_support`), together with the exact monotone fragment
(`support_preserved_of_no_new_against`, `support_merge_of_both`).

Below are concrete, falsifiable conjectures for follow-up cycles.

## C1. Tropical Galois connection between truth and knowledge orders
**Conjecture.** The conflation map `conf (p, n) = (-n, -p)` is an order
anti-isomorphism for the *knowledge* order `kle` and an order *isomorphism* for
the *truth* order `tle`, and the pair `(tneg, conf)` generates a Klein
four-group acting on `DreamVal` with `tneg ∘ conf = conf ∘ tneg` equal to the
negation of both coordinates. Moreover `conf` is a `kjoin`–`kmeet` De Morgan
duality (`conf (kjoin x y) = kmeet (conf x) (conf y)` once `kmeet = (min,min)` is
added). *Testable*: state each identity as an equation on `ℝ × ℝ` and prove or
find a counterexample.

## C2. Fixed-point semantics for stratified defeasible closure
**Conjecture.** Define a one-step revision operator
`T_R(s) a = kjoin (s a) (ruleSupport R s a)` for a finite rule base `R` of
tropical Horn rules. Then `T_R` is monotone for `kleState` and Scott-continuous,
so it has a least fixed point `lfp T_R` reachable in `≤ |R|` steps from the
initial state, and `lfp T_R` is the unique minimal-information state closed under
`R`. *Testable*: formalize `T_R`, prove monotonicity + a bounded-iteration
fixed-point theorem; the bound `|R|` is the falsifiable quantitative claim.

## C3. A quantitative non-monotonicity / stability margin
**Conjecture.** Define the *support margin* `μ(s,a) = (s a).1 - (s a).2`. Then a
conclusion `a` survives merging with `t` **iff** the incoming counter-margin is
smaller than the current margin in the sense
`max (t a).2 (s a).2 - max (t a).1 (s a).1 < 0`, and the sharp threshold is:
`a` is retracted by `t` exactly when `(t a).2 ≥ max (s a).1 (t a).1` and
`(t a).2 > (s a).2`. *Testable*: prove the biconditional characterizing exactly
which `t` retract `a`, giving a decision procedure for defeasible stability.

## C4. Tropical valuation collapse to classical logic
**Conjecture.** Restricting assignments to the "consistent cone"
`C = { x : DreamVal | x.2 ≤ 0 ∨ x.1 ≤ 0 }` (no atom is glutty) makes the base
consequence relation `⊨d` *coincide* with classical two-valued entailment under
the map `x ↦ (0 < x.1)`: for premises and conclusions evaluated in `C`,
explosion **holds** and `⊨d` is exactly classical. *Testable*: prove
`{A, ¬A} ⊨d B` for all `B` once every atom is restricted to `C`, and prove the
soundness/completeness bridge to `Prop`. This pins paraconsistency to the glut
region precisely.

## C5. Compositional bound: tropical degree controls belief drift
**Conjecture.** For a formula `φ` with `k` atoms, evaluated under two states
`s, s'` with pointwise `‖s a - s' a‖∞ ≤ ε`, the evaluations satisfy
`‖eval s φ - eval s' φ‖∞ ≤ ε` (1-Lipschitz in the sup-norm, *independent* of
formula size). Consequently defeasible support is stable under `ε`-perturbations
whenever the margin `μ` exceeds `2ε`. *Testable*: prove the 1-Lipschitz bound by
structural induction (each connective is `max`/`min`/swap, all 1-Lipschitz) and
derive the `μ > 2ε` robustness corollary. The size-independence is the bold,
falsifiable part.
