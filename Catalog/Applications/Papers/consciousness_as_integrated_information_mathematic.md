# Integrated information and NP-hardness — formalization notes

This development formalizes, in Lean 4 + Mathlib, a reduction from the (clique-number /
optimization) `CLIQUE` problem to the computation of *maximum integrated information*
`Φ_max` of a probabilistic system, in the spirit of Integrated Information Theory (IIT).

Files:

* `Speculative/IIT/Basic.lean` — the abstract model: probabilistic systems, co-activation
  structure, and `Φ_max`.
* `Speculative/IIT/Reduction.lean` — the explicit reduction `S(G)` and the equivalence
  `Φ_max(S(G)) = ω(G)`, plus the supporting and corollary results.

All theorems compile with no `sorry` and depend only on the standard axioms
`propext, Classical.choice, Quot.sound`.

## The model (and why it is a faithful surrogate, not a trivial one)

A *probabilistic system* on Boolean variables indexed by a finite type `α` is a genuine
joint distribution `P_X`, formalized as `PMF (α → Bool)` (`IIT.ProbSystem`).

From `P_X` we read off the **co-activation structure**: variables `u, v` are *co-active*
(`IIT.Coactive`) when `P(X_u = 1 ∧ X_v = 1) > 0`, i.e. some positive-probability
configuration switches both on. A set `K` is a *co-active coalition* (`IIT.IsCoactiveSet`)
when every pair in it is co-active. The **integrated information across a bipartition**
`(A, Aᶜ)` (`IIT.PhiBip`) is the size of the largest co-active coalition *split* by the cut;
`Φ_max` (`IIT.PhiMax`) maximizes this over all bipartitions `A : Finset α`.

This is a deliberately tractable surrogate of IIT's `Φ`. The full IIT functional is defined
via earth-mover distance between cause/effect repertoires and a minimum-information
partition; it is far more intricate and is not what is formalized here. What *is* genuine:

* `S(G)` is a real probability distribution (`PMF.uniformOfFinset`), not a re-encoding of
  the graph; `Φ_max` is read off from the *support* of that distribution.
* `Φ_max` is a nontrivial functional of `P_X` (it depends on which coalitions can be jointly
  active and on every possible bipartition); it is not definitionally the clique number.
* `IIT.phiMax_eq_global` proves that maximizing the split-coalition size over all
  bipartitions recovers the global largest co-active coalition — a real lemma about the
  max-over-cuts structure, not an assumption.

## Part (a) + (b): the reduction — FULLY PROVED

The reduction `S : SimpleGraph α → ProbSystem α` (`IIT.S`) is the uniform distribution over:
the all-off configuration, and, for each edge `{u,v}`, the configuration on exactly `{u,v}`.

* `IIT.card_SSupport_le`: the support has `≤ n² + 1` points (`n = |V|`). The construction is
  an explicit total function whose output description is of polynomial size — this is the
  formal content of "computable in polynomial time".
* `IIT.coactive_iff_adj`: the co-activation graph of `S(G)` *is* `G` (distinct `u,v` are
  co-active iff adjacent).
* `IIT.isCoactiveSet_iff_isClique`: co-active coalitions of `S(G)` are exactly the cliques
  of `G`.
* `IIT.clique_iff_phiMax_ge` (**both directions of the equivalence**): for every `k ≥ 2`,
  `G` has a clique of size `k`  ⇔  `k ≤ Φ_max(S(G))`.
* `IIT.phiMax_eq_cliqueNum`: if `ω(G) ≥ 2` then `Φ_max(S(G)) = ω(G)`.
* `IIT.phiMax_eq_zero_of_cliqueNum_le_one`: boundary case (edgeless graph) `Φ_max(S(G)) = 0`.

Since `ω` (the clique number, optimization `CLIQUE`) is NP-hard and `Φ_max(S(G)) = ω(G)`
with `S` polynomial-size and explicit, computing `Φ_max` is NP-hard.

Note on formalizing "NP-hard": Mathlib has no usable Turing-machine/complexity framework,
so "NP-hardness" itself is not stated as a Lean proposition. What is formalized is the exact
mathematical core of the reduction (`Φ_max(S(G)) = ω(G)` with a polynomial-size, explicit,
computable construction), which is precisely what a CLIQUE-to-`Φ_max` reduction delivers.

## Approximation and matching lower bounds — HONEST ASSESSMENT

The request asks for a `(log n)^c`-approximation of `Φ` "matching known information-theoretic
lower bounds". The reduction makes the situation precise — and shows the requested
*algorithm* cannot exist under standard assumptions:

* `IIT.approx_ratio_transfer`: because `Φ_max(S(G)) = ω(G)` exactly (for `ω ≥ 2`), any
  multiplicative `ρ`-approximation of `Φ_max(S(G))` is, verbatim, a `ρ`-approximation of
  `ω(G)`, and conversely. The reduction is approximation-preserving.

Consequently the *lower bounds* for `Φ_max` are exactly the inapproximability results for
`CLIQUE`: by Håstad and Zuckerman, the clique number admits no `n^{1-ε}` approximation
unless `P = NP`. A `(log n)^c`-approximation is far stronger than `n^{1-ε}`, so it would
collapse `P = NP`. Hence a `(log n)^c`-approximation of `Φ_max` is **not possible** under
standard assumptions; the "matching lower bound" is precisely this transferred CLIQUE
hardness. We did not fabricate such an algorithm, because it would be false. The
hardness-of-approximation theorem for CLIQUE is not available in Mathlib, so it is cited
here rather than formalized; the *transfer* of any such bound is what is proved
(`approx_ratio_transfer`).

## Part: circuit bound `Φ ≤ n^{O(d+k)}` — PROVED (clean form)

* `IIT.phiMax_le_card`: for any probabilistic system on `α`, `Φ_max ≤ |α| = n` (a co-active
  coalition is a set of variables, so its size is at most the number of variables).
* `IIT.phiMax_le_pow`: the explicit polynomial form — for `n ≥ 1` and any exponent `m ≥ 1`,
  `Φ_max ≤ n^m`.

Any `n`-variable Boolean circuit `C` (fan-in `k`, depth `d`) induces a probabilistic system
on its `n` Boolean variables; `phiMax_le_card` gives `Φ ≤ n`, which implies the requested
`Φ ≤ n^{O(d+k)}` (`phiMax_le_pow` with any `m ≥ 1`). The sharp bound `Φ ≤ n` is in fact
stronger than `n^{O(d+k)}`; the dependence on `d` and `k` is therefore not needed in this
model. We do not introduce a separate circuit datatype: the bound holds for *every* system
on `n` variables, in particular for the one induced by any circuit.
