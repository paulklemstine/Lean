# Future Directions — Worst-Case to Average-Case Hardness of LWE

## Synthesis

This cycle isolated the *constructive and algebraic skeleton* of the worst-case
to average-case reduction that underlies the Learning with Errors (LWE) problem,
and formalized it in `Catalog/Cryptography/LWE/WorstCaseToAverageCase.lean` with
`sorry = 0`. The new file deliberately complements the existing
`Catalog/Cryptography/LWE/SearchDecisionCore.lean` (which covers the
*average-case ↔ average-case* search/decision direction) by attacking the
*worst-case → average-case* direction (GapSVP/SIVP → LWE).

Three pillars were established and machine-checked:

1. **A concrete, computable lattice model.** Diagonal integer lattices
   `L_d = { v ∈ ℤⁿ : dᵢ ∣ vᵢ }` admit a closed-form first minimum
   `λ₁² = minᵢ dᵢ²`. We proved both the lower bound
   (`sqLen_ge_lambda1sq`: every nonzero point is at least this long) and the
   matching attaining axis-vector witness (`exists_attaining_lambda1sq`). This
   turns the otherwise abstract "shortest vector" into an effectively computable
   object — exactly the witness an LWE-to-lattice solver must produce.

2. **The gap-amplification algebra of GapSVP_γ.** The approximation factor `γ`
   behaves monotonically (`GapSVP.no_instance_factor_antitone`) and the
   YES/NO promise gap is genuinely disjoint for `γ ≥ 1`
   (`GapSVP.yes_no_disjoint`), so a correct decider is well-defined. Reduction
   steps compose with multiplicative factor loss (`Reduction.compose_factor`),
   mirroring `CryptoReduction.compose` from `HardnessHierarchy.lean`.

3. **Regev's parameter chain.** The constraint `α q ≥ 2√n` is feasible
   (`Regev.parameter_constraint_feasible`), and the worst-case approximation
   factor `γ = c·n/α` is antitone in the noise rate
   (`Regev.approx_factor_antitone_in_noise`): less noise ⇒ a smaller, harder
   approximation factor. This is the quantitative heart of "smaller `α` ⇒
   stronger worst-case hardness".

## Results Summary

| Theorem | Content |
|---|---|
| `sqLen_ge_lambda1sq` | Lower bound `λ₁² ≥ minᵢ dᵢ²` for diagonal lattices |
| `exists_attaining_lambda1sq` | The bound is attained — `λ₁²` is exact and computable |
| `GapSVP.no_instance_factor_antitone` | NO instances are inherited by smaller `γ` |
| `GapSVP.yes_no_disjoint` | The promise gap is genuinely disjoint for `γ ≥ 1` |
| `Reduction.compose_factor` | Approximation factors multiply under composition |
| `Regev.parameter_constraint_feasible` | `α q ≥ 2√n` is satisfiable |
| `Regev.approx_factor_antitone_in_noise` | `γ = c·n/α` shrinks as noise shrinks |

All proofs depend only on the standard kernel axioms (`propext`,
`Classical.choice`, `Quot.sound`); no `native_decide`, custom axioms, or
`@[implemented_by]` were used.

---

## Direction 1 — A computable GapSVP decider for diagonal lattices

**Conjecture.** For the diagonal-lattice family `L_d`, the promise problem
`GapSVP_γ` is decidable by a polynomial-time (indeed linear-time in `n`)
algorithm: compute `m = minᵢ dᵢ` and compare `m` against `r` and `γ·r`.

The key insight is that `exists_attaining_lambda1sq` already produces the exact
shortest vector as an axis vector, so the "search" version of SVP is solved in
one pass; the gap decision is then a single comparison. This gives a *certified*
`Decidable` instance and an `#eval`-able decider, turning the abstract promise
problem into running code.

Why now? The two `λ₁²` characterization theorems are already proved, so the
decider's correctness proof reduces to plumbing `sqLen_ge_lambda1sq` and
`exists_attaining_lambda1sq` into a `decide`-style wrapper — a short, fully
constructive next step with immediate computational payoff.

## Direction 2 — Sublattice monotonicity of the first minimum

**Conjecture.** If `d ∣ d'` coordinatewise (`dᵢ ∣ d'ᵢ` for all `i`), then
`L_{d'} ⊆ L_d` and consequently `λ₁²(L_d) ≤ λ₁²(L_{d'})`. More generally, the
first minimum is monotone with respect to lattice inclusion.

The key insight is that shrinking a lattice (passing to a sublattice) can only
lengthen its shortest vector, so the closed form `minᵢ dᵢ²` is monotone in the
coordinatewise divisibility order on scale vectors. This is the discrete shadow
of the general "denser lattice ⇒ shorter `λ₁`" principle.

Why now? Inclusion `L_{d'} ⊆ L_d` follows directly from transitivity of
divisibility, and the `λ₁` comparison is then immediate from the existing
characterization — a clean generalization that begins building an order-theoretic
API around `lambda1sq`.

## Direction 3 — Tensor/product lattices and factor multiplicativity

**Conjecture.** For the product of two diagonal lattices (concatenating scale
vectors `d` over `Fin n` and `e` over `Fin m` into `Fin (n+m)`),
`λ₁²(L_{d⊕e}) = min(λ₁²(L_d), λ₁²(L_e))`, and the GapSVP approximation factor of
the product equals the max of the components' factors.

The key insight is that the shortest vector of a direct-sum lattice lives
entirely in one block, so first minima combine by `min` while approximation
hardness combines by `max` — directly composing with the multiplicative
`Reduction.compose_factor` algebra to yield end-to-end factor bounds for layered
constructions.

Why now? The single-lattice `λ₁²` is settled and `Reduction.compose_factor` is
proved, so the product case is the natural inductive step toward reductions over
structured (e.g. module/ring) lattices used in Ring-LWE.

## Direction 4 — Discrete Gaussian tail bounds feeding the noise budget

**Conjecture.** For the discrete Gaussian weight `ρ_s(x) = exp(-π x²/s²)` on `ℤ`,
the tail mass beyond radius `t·s` decays as `O(exp(-π t²))`, and this tail bound
is exactly the quantity needed to instantiate the noise-accumulation budget
`B + n·δ < q/4` from `SearchDecisionCore.decryption_correct_after_switching`.

The key insight is that the analytic gap between the *abstracted* error bound `B`
in `SearchDecisionCore` and a *concrete* Gaussian sampler is a single tail
inequality; proving it closes the loop between the average-case noise model and a
sampleable distribution.

Why now? `SearchDecisionCore` already states correctness in terms of an abstract
`|e| ≤ B`; supplying a concrete `B` from a Gaussian tail bound upgrades those
theorems from conditional to unconditional for an explicit, computable error
distribution.

## Direction 5 — Composing the full pipeline `SIVP_γ → GapSVP_γ' → LWE`

**Conjecture.** Chaining a SIVP-to-GapSVP step with `Reduction.compose_factor`
yields a single composite reduction whose total approximation factor is the
product of the link factors, and whose feasibility region is exactly the
intersection of the per-link constraints (in particular still requiring
`α q ≥ 2√n`).

The key insight is that the entire worst-case-to-average-case pipeline is a
telescoping product in the `Reduction.Step` monoid, so end-to-end hardness is a
fold of `compose_factor` over the links — making the headline `γ = Õ(n/α)` a
mechanically derived corollary rather than a hand-waved claim.

Why now? `Reduction.Step.comp` and `compose_factor` are already proved and
associative-by-construction; formalizing one additional SIVP→GapSVP link is
enough to assemble the whole chain and state the master reduction theorem.
