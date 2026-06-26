# Computational Evidence — Monotone Circuit Complexity

Concise numerical checks supporting the formal claims. All counts are computable
and several are discharged by `decide` inside the Lean sources.

## 1. Off-diagonal edge count = `m.choose 2`

The size lower bound `clique2_size_ge_choose` asserts `m.choose 2 ≤ size C`.
Number of non-loop edges `{e : Sym2 (Fin m) // ¬ e.IsDiag}`:

| m | off-diagonal edges | `m.choose 2` |
|---|--------------------|--------------|
| 2 | 1                  | 1            |
| 3 | 3                  | 3            |
| 4 | 6                  | 6            |
| 5 | 10                 | 10           |

Verified in Lean: `example : (Finset.univ.filter (fun e : Sym2 (Fin 4) => ¬ e.IsDiag)).card = Nat.choose 4 2 := by decide` succeeds. The general statement is proved as `card_offDiag_eq_choose`. This sequence is OEIS A000217-shifted (triangular numbers `C(m,2)`: 0,0,1,3,6,10,...).

## 2. Monotone separator (KW) on a small circuit

Take `C = or (var e1) (and (var e2) (var e3))` over three edge variables.
For `x = (1,1,1)` (`eval = true`) and `y = (0,1,0)` (`eval = false`):
`kwFind` descends the OR (left child true), reaches `var e1`, returns `e1`, and
indeed `x e1 = true`, `y e1 = false`. Cost = 1 ≤ depth = 2, matching
`kwCost_le_depth`. The correctness invariant in `kwFind_spec` is exactly this
behaviour generalized.

## 3. Relevant-variable bound is non-vacuous

For 2-CLIQUE on `Fin m`, the empty graph has no 2-clique (`cliqueFn = false`),
while adding any single edge `{a,b}` (a ≠ b) creates the 2-clique `{a,b}`
(`cliqueFn = true`). Hence every one of the `m.choose 2` edges is relevant, and a
circuit ORing all edges (size `2·C(m,2)-1`) does compute 2-CLIQUE — so the
hypothesis of `clique2_size_ge_choose` is satisfiable and the bound is tight up to
a constant factor for `k = 2`.

## 4. Scope note (counterexample hunt)

We deliberately did **not** claim the exponential Razborov bound: for `k = 2` the
true monotone complexity is `Θ(m^2)`, so any "exponential in `m`" claim for fixed
small `k` is *false*. The exponential regime requires `k` growing with `m` and the
approximation method (Conjecture 3 in `FUTURE_DIRECTIONS.md`). The formalized
bound `m.choose 2` is the honest, fully verified statement for this cycle.
