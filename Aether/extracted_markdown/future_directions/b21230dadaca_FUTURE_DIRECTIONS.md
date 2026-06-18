# Future Directions — Proof-Theoretic Bridge: Ordinal Analysis A

## Synthesis

This cycle opened a constructive bridge between three faces of ordinal analysis,
all stated over Mathlib's *computable* notation system `ONote` / `NONote` (Cantor
normal forms below `ε₀`):

* the **well-ordering** of the notation system (a proof-theoretic invariant),
* the **termination** of any algorithm carrying an `ε₀`-valued monovariant (an
  algorithmic invariant), and
* the **fast-growing hierarchy** `ONote.fastGrowing : ONote → ℕ → ℕ`, an
  effective, `native_decide`-evaluable family of number-theoretic functions.

The connective tissue is the single theorem `terminates_of_measure`: a state
space `α` equipped with a step map and an `ε₀`-valued quantity that strictly
decreases until it bottoms out provably reaches the bottom in finitely many
steps. The well-ordering theorem `nonote_no_infinite_descent` is its engine, and
the self-measured corollary `terminates_of_self_descent` is its most directly
executable face.

This work descends from the *abstract* `Ordinal`-valued strength order studied in
`Catalog/Logic/StronglyCriticalOrdinals.lean` (`no_infinite_consistency_descent`,
`strength_wellFounded`) and `Catalog/Pythagorean/ProofTheoreticOrdinalsEpsilon.lean`
(the `ε₀` closure barrier) to the *computable* `NONote` representation, turning
well-ordering from a structural fact into an executable termination certificate.

## Results Summary (`Catalog/Geometry/OrdinalAnalysisBridge.lean`, 0 `sorry`)

1. `fastGrowing_zero_eq_succ` — the base function of the hierarchy is `(· + 1)`.
2. `fastGrowing_one_three`, `fastGrowing_two_two` — concrete kernel-checked values
   (`F₁(3) = 6`, `F₂(2) = 8`) witnessing that the hierarchy is genuinely effective.
3. `nonote_no_infinite_descent` — no strictly `<`-decreasing sequence of notations
   below `ε₀` exists (well-ordering of the notation system).
4. `terminates_of_measure` — ordinal-measure termination: an `ε₀`-monovariant
   certifies that a deterministic process halts.
5. `terminates_of_self_descent` — the `μ = id` specialisation: a self-decreasing
   step on `NONote` reaches `0`.

All results depend only on the permitted axioms (`propext`, `Classical.choice`,
`Quot.sound`, plus `Lean.ofReduceBool` / `Lean.trustCompiler` for the
`native_decide` computations).

---

## Direction 1 — Goodstein sequences as an `ε₀`-monovariant instance

State and prove termination of Goodstein sequences by exhibiting the standard
hereditary-base ordinal assignment `g : ℕ → NONote` and feeding it to
`terminates_of_measure`. The falsifiable claim: the Goodstein step strictly
decreases the assigned `NONote` while the value is nonzero, so every Goodstein
sequence reaches `0`. **The key insight is** that Goodstein termination is not a
new theorem but a *single application* of `terminates_of_measure` once the
hereditary-base map is shown to be a strict monovariant. **Why now?** We already
have the abstract termination engine and a computable target type; the only
missing piece is the explicit, `#eval`-checkable hereditary-base encoding, which
is finite combinatorics rather than ordinal theory.

## Direction 2 — Hydra games and the same engine

Encode Kirby–Paris hydras as finite rooted trees, define the head-chopping step,
and assign each hydra an element of `NONote` so that chopping strictly decreases
it. The falsifiable conjecture: this assignment is a strict monovariant, hence
`terminates_of_self_descent` / `terminates_of_measure` yields that Hercules always
wins. **The key insight is** that the hydra's ordinal rank is literally a `NONote`
descent measure, making the win a corollary rather than a bespoke induction.
**Why now?** The tree-to-`ONote` rank is computable and testable on small hydras
with `#eval`, so the strict-decrease hypothesis can be empirically stress-tested
before the full proof.

## Direction 3 — Closed forms for the low fast-growing levels

Prove `∀ n, ONote.fastGrowing 1 n = 2 * n` and a closed form for level two (the
data suggests `F₂(n) = n · 2ⁿ`). The falsifiable claim is exactly these two
identities, checkable against `native_decide` for many `n` before proving. **The
key insight is** that the `fundamentalSequence` of `1` and `ω` has a regular shape
that lets the recursion collapse to elementary arithmetic by induction on `n`.
**Why now?** We have computed enough sample values (`F₁(3)=6`, `F₂(2)=8`) to pin
the conjectured closed forms; the remaining work is a clean induction using
`ONote.fastGrowing_succ`.

## Direction 4 — A verified ordinal-bounded `while`-loop combinator

Package `terminates_of_measure` into a dependently typed, executable loop
combinator `whileDescending : (μ : α → NONote) → (step : α → α) → … → α` that runs
`step` until `μ` hits `0`, returning the final state together with a proof of
termination. The falsifiable deliverable: a combinator that both `#eval`s on
concrete inputs and carries a total-correctness certificate. **The key insight is**
that ordinal monovariants give *general recursion for free* — the `NONote`
well-order can serve as the decreasing measure in Lean's `termination_by`. **Why
now?** The termination theorem is in hand; turning it into a reusable, runnable
combinator is engineering that immediately yields verified algorithms across the
catalog (e.g. normalization / rewriting loops).

## Direction 5 — Quantitative descent: step counts vs. fast-growing rate

For a self-descending step on `NONote` with start `a`, conjecture that the number
of steps to reach `0` is bounded below by a fast-growing function of the
"unfolding parameter" when the descent follows fundamental sequences (Hardy-style
descent). The falsifiable claim ties `terminates_of_self_descent`'s existential
`n` to `ONote.fastGrowing` lower bounds. **The key insight is** that
fundamental-sequence descent realizes the Hardy hierarchy, so step counts are not
arbitrary but governed by the very hierarchy we already evaluate. **Why now?** With
both the descent engine and the computable hierarchy in the same file, the
correspondence can be probed numerically (compare measured step counts against
`fastGrowing` values) before committing to the analytic bound.
