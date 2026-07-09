# Computational Evidence — Self-Improving Proofs

We test the guiding conjecture on the complexity function
`C(P) = length(P) + depth(P) + #lemmas(P) ∈ ℕ` and the refinement relation
`P' ⤳ P  ⟺  valid(P') ∧ valid(P) ∧ C(P') < C(P)`.

## 1. Small-case calculations

### 1.1 Refinement chains of `√2`-proofs
Three candidate proofs of `Irrational (√2)` with complexities:

| candidate         | `C` |
|-------------------|-----|
| `byContradiction` | 10  |
| `viaValuation`    |  6  |
| `viaMathlib`      |  3  |

The chain `byContradiction ⤳ viaValuation ⤳ viaMathlib` has strictly decreasing
complexity `10 > 6 > 3`. Global minimum: `3` (`viaMathlib`).

### 1.2 A halting-but-suboptimal process
The process `sqrt2Process`:

```
n:            0    1    2    3    4  ...
proof:      byC  viaV viaV viaV viaV ...
C:           10    6    6    6    6  ...
```

is non-increasing and stabilises at `C = 6` from `n = 1` on, **yet the global
minimum is `3 < 6`.** This is a concrete counterexample to the sub-claim
"the limit of the refinement process is the simplest proof": a monotone,
halting process can freeze strictly above the Kolmogorov-minimal proof. Formalised as `refinement_limit_not_optimal`.

## 2. Chain-length bound (`nat_finite_strict_chain_bounded`)

A strictly decreasing complexity chain of `m` steps forces `C(P_0) ≥ m`.
Tabulating the maximal number of strict refinement steps from an initial
complexity `c`:

| initial `C(P_0)` | max #strict steps |
|------------------|-------------------|
| 0 | 0 |
| 1 | 1 |
| 3 | 3 |
| 10 | 10 |
| `c` | `c` |

So chains are always **finite** but can be **arbitrarily long** (linear in the
initial complexity). This matches the mission's remark that a proof might need
`10^100` refinements: with `C(P_0) = 10^100` there is room for `10^100` steps.

## 3. Counterexample hunt against the universal claims

* "There is no infinite strictly-simplifying chain" — searched for a strictly
  decreasing `ℕ`-sequence; none can exist (`nat_no_strict_descent`). No
  counterexample. **TRUE.**
* "Every non-increasing complexity process halts" — tested constant, eventually
  constant, and strictly decreasing prefixes; all stabilise
  (`nat_noninc_eventually_constant`). No counterexample. **TRUE.**
* "The halting limit equals the simplest proof" — **counterexample found**
  (§1.2): limit `6`, simplest `3`. **FALSE.**

## 4. Sequences

The chain-length bound `c ↦ c` is the identity sequence (OEIS A001477,
`0,1,2,3,...`); no deeper integer sequence is generated. This is expected: the
mathematics here is about well-foundedness and stabilisation of `ℕ`-valued
measures, not about producing a novel counting sequence.

## Summary
Two halves of the conjecture (well-founded termination and halting) are
**confirmed** and proved in Lean without `sorry`; the third half (limit =
simplest) is **refuted** by an explicit finite counterexample, also proved.
