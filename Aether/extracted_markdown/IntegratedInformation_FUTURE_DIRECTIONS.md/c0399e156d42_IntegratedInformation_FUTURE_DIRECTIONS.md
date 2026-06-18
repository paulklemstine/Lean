# Future Directions: Integrated Information Theory in Lean 4

The file `Speculative/IntegratedInformation.lean` lays a verified foundation for
Tononi's Integrated Information Theory (IIT). Its mathematical core is **Gibbs'
inequality** (`klDiv_nonneg`), from which we derive that integrated information
`Φ` is nonnegative (`Phi_nonneg`) and vanishes on *reducible* systems
(`Phi_eq_zero_of_reducible`). The following conjectures extend this skeleton into
a genuine theory of consciousness measures. Each is testable: it can be settled
by a complete Lean proof or refuted by a counterexample `System`.

## Direction 1 — Gibbs equality characterization (`klDiv_eq_zero_iff`)

**Conjecture.** For distributions with `p ≥ 0`, `q > 0`, and equal total mass,
`klDiv p q = 0` if and only if `p = q` pointwise.

The current development proves only one direction implicitly (`klDiv_self`). A
full characterization would let us replace the existential hypothesis of
`Phi_eq_zero_of_reducible` with a sharp structural statement: `Φ = 0` exactly
when the global distribution literally equals one of its factorizations.

**The key insight is** that the tangent-line bound `log x ≥ 1 − 1/x` underlying
`klDiv_term_ge` is an *equality* iff `x = 1`; strict convexity of `−log` forces
every per-state term to be tight simultaneously, which pins `p i = q i`.

**Why now?** The pointwise bound `klDiv_term_ge` is already proven, and
Mathlib's `Real.log_le_sub_one_of_pos` has a companion strict form; the equality
case is a routine but valuable strengthening that immediately upgrades the IIT
reducibility theorem from sufficient to necessary-and-sufficient.

## Direction 2 — Subadditivity of integrated information under independent composition

**Conjecture.** If two IIT systems `S₁` and `S₂` are composed into a product
system whose distribution factorizes as `p₁ ⊗ p₂` and whose partition family is
the product family, then `Φ(S₁ ⊗ S₂) = Φ(S₁) + Φ(S₂)`, and in particular the
composite of two reducible systems is reducible.

**The key insight is** that relative entropy is *additive* over product
distributions: `klDiv (p₁⊗p₂) (q₁⊗q₂) = klDiv p₁ q₁ + klDiv p₂ q₂`, so the
minimum over a product partition family splits as a sum of minima.

**Why now?** Additivity of KL over products is a finite Fubini computation well
within reach of the existing `Finset.sum` API, and it gives IIT its first
*compositional* law — the precise sense in which integrated information is an
extensive quantity.

## Direction 3 — Data-processing / monotonicity under coarse-graining

**Conjecture.** Applying a stochastic coarse-graining map (a column-stochastic
matrix `T`) to both `p` and every partition distribution can only decrease
relative entropy: `klDiv (T·p) (T·q) ≤ klDiv p q`, hence coarse-graining cannot
increase `Φ`.

**The key insight is** the log-sum inequality / joint convexity of relative
entropy: merging states is an averaging operation, and `−log` is convex, so each
merge contracts divergence (the classical data-processing inequality).

**Why now?** This is the IIT analogue of the second law and the foundation of
IIT's "exclusion postulate" (consciousness lives at the spatiotemporal grain that
maximizes `Φ`). The log-sum inequality is provable from `klDiv_term_ge`-style
tangent bounds without measure theory, making a finite proof feasible.

## Direction 4 — Existence and uniqueness of the minimum information partition

**Conjecture.** For every `System` the infimum defining `Φ` is attained at some
partition `k*` (the "minimum information partition", MIP), and when the partition
family is in "general position" the minimizer is unique.

**The key insight is** that `Φ` is defined via `Finset.inf'` over a *finite*
nonempty family, so attainment is automatic (`Finset.exists_mem_eq_inf'`); the
substantive content is uniqueness, which follows from strict convexity of `klDiv`
in the partition parameter once Direction 1 is in place.

**Why now?** Naming the MIP as a first-class object (`mip : System → K`) turns
the qualitative `Phi_eq_zero_of_reducible` into the quantitative core of IIT and
lets later work reason about *which* cut a conscious system minimizes — the step
from "how much" integration to "where".

## Direction 5 — A continuity/stability bound for Φ (Pinsker-type robustness)

**Conjecture.** Integrated information is Lipschitz-stable under perturbation of
the distribution: small changes in `p` (in total-variation distance) produce
bounded changes in `Φ`, via a Pinsker-type inequality relating `klDiv` to the
squared total-variation distance.

**The key insight is** that Pinsker's inequality `klDiv p q ≥ 2‖p − q‖²_TV`
controls divergence *from below* by a metric, so combined with an upper Lipschitz
bound it sandwiches `Φ` and certifies that consciousness measures do not jump
discontinuously under noise.

**Why now?** Robustness is the property critics most often demand of any proposed
consciousness measure. A finite-state Pinsker inequality is a known target for
formalization and would make IIT's central quantity provably noise-tolerant,
closing the loop from foundational inequality (`klDiv_nonneg`) to applied
stability.
