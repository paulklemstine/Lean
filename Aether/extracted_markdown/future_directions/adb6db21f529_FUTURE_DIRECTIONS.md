# Future Directions — Proof-Theoretic Bridge: Ordinal Analysis Across Systems

The file `Catalog/Logic/OrdinalCollapsingBridge.lean` formalizes a genuine
fragment of ordinal analysis inside Mathlib's Veblen hierarchy. It defines
ε₀ = `veblen 1 0` (the proof-theoretic ordinal of Peano Arithmetic) and
Γ₀ = `nfp (veblen · 0) 0`, which in Bachmann–Buchholz ordinal collapsing
notation is exactly ψ(Ω^ω) (the Feferman–Schütte ordinal). The headline result
`eps0_lt_psiOmegaOmega` proves ε₀ < ψ(Ω^ω); supporting theorems show ε₀ is the
least epsilon number, Γ₀ is the least strongly critical ordinal, and the diagonal
Veblen map `ptStrength : o ↦ veblen o 0` is a strictly monotone order-preserving
"bridge" whose values below Γ₀ stay below Γ₀. One strengthening,
`epsilon_numbers_unbounded_below_psi`, is left as an explicit open `sorry`.

The five directions below are concrete, falsifiable next steps. Each builds on the
exact definitions and lemmas already proven, so progress is measurable by whether
the corresponding Lean statement type-checks without `sorry`.

## 1. Close the unboundedness of epsilon numbers below Γ₀

Prove `epsilon_numbers_unbounded_below_psi`: for every `b < Γ₀` there is an epsilon
number `a` with `b < a < Γ₀`. The natural witness is `a := nfp (veblen 0) (Order.succ b)`,
which is a fixed point of `veblen 0` (hence `ω^a = a`) and exceeds `b`; the missing
piece is `a < Γ₀`. **The key insight is** that Γ₀, being strongly critical
(`psiOmegaOmega_fp`), is closed not just under the diagonal map `veblen · 0` but
under `veblen 1 = deriv (veblen 0)` applied to any argument below it, so the next
epsilon number after `b` cannot escape the ceiling. **Why now?** The closure lemma
`ptStrength_lt_psiOmegaOmega` already proven is the `a = 0` slice of exactly the
two-variable closure `veblen o c < Γ₀` for `o, c < Γ₀` needed here; generalizing
its one-line proof from `0` to arbitrary second argument is the whole task.

## 2. The Veblen-closure characterization of Γ₀

Prove the two-variable closure theorem `∀ o c, o < Γ₀ → c < Γ₀ → veblen o c < Γ₀`
and its converse, giving Γ₀ = least ordinal closed under binary Veblen. **The key
insight is** that strong criticality (`veblen Γ₀ 0 = Γ₀`) is equivalent to full
Veblen-closure, because `veblen o c` for `o < Γ₀` lies in the range of `veblen o`
whose fixed points are cofinal below Γ₀. **Why now?** Mathlib already supplies
`veblen_veblen_of_lt`, `veblen_lt_veblen_iff`, and `right_le_veblen`; combining them
with `psiOmegaOmega_fp` turns this into a finite case split rather than new theory.

## 3. A second rung of the bridge: ε₁ and the successor epsilon ordinals

Define `epsAt : Ordinal → Ordinal := veblen 1` so that `epsAt 0 = ε₀`, and prove
`epsAt` is a strictly monotone normal function whose values are all `< Γ₀`,
realizing the tower ε₀ < ε₁ < ε₂ < ⋯ of successive proof-theoretic ordinals.
**The key insight is** that `veblen 1 = deriv (veblen 0)` is normal by
`isNormal_deriv`, so the entire ε-tower is just the orbit of one normal function,
and each rung lands below Γ₀ by Direction 2. **Why now?** `veblen_succ` already
identifies `veblen 1` with `deriv (veblen 0)`, so the tower needs no new
definitions — only the normality and boundedness wrappers.

## 4. An order embedding `PA ↪ KP` of ordinal notations

Package `ptStrength` as a bundled `o ↪o veblen o 0` `OrderEmbedding` and prove it
restricts to an order isomorphism from `Set.Iio Γ₀` onto the strongly-critical-free
ordinals, formalizing the "explicit order-preserving map from the proof-theoretic
ordinals of one system into another." **The key insight is** that a strictly
monotone map on a linear order is automatically order-reflecting, so
`ptStrength_strictMono` already gives the embedding; only the surjectivity onto the
fixed-point-free segment is new. **Why now?** Mathlib's `StrictMono.orderEmbedding`
and `OrderIso` API make the bundling mechanical once the range is characterized by
Direction 2.

## 5. Connect ε₀ to PA's actual consistency strength via `Ordinal.CNF`

Bridge the abstract ordinal ε₀ to the *syntactic* side by proving that the Cantor
normal form `Ordinal.CNF ω` terminates exactly on ordinals `< ε₀`, i.e. ε₀ is the
least ordinal not reachable by finite ω-base CNF towers. **The key insight is** that
`ω^a = a` (our `omega_opow_eps0`) is precisely the failure of CNF to make progress,
so ε₀ is the supremum of the iterated-exponential ordinals that index PA proofs.
**Why now?** Mathlib's `Mathlib.SetTheory.Ordinal.CantorNormalForm` provides
`Ordinal.CNF` with completeness lemmas, and `omega_opow_eps0` / `eps0_least` give the
fixed-point boundary, so the statement reduces to an induction on CNF length.
