# Computational Evidence: The Oracle's Burden

This project is order-theoretic / recursion-theoretic rather than numerical, so the "evidence"
is a small-case sanity check of the structural claims that the formal proofs then establish.

## 1. The base of the hierarchy is non-trivial (counting argument)

The claim `∃ f, ¬ Nat.Partrec f` (`exists_not_partrec`) rests on a cardinality count:

| object | cardinality |
|---|---|
| partial-recursive functions `{f : ℕ →. ℕ | Nat.Partrec f}` | countable (`ℵ₀`) — they are the range of `Code.eval` over the countable type `Nat.Partrec.Code` |
| all partial functions `ℕ →. ℕ` | `2^{ℵ₀}` (contains a copy of `2^ℕ` via `s ↦ λ n, some (if s n then 0 else 1)`) |

Since `ℵ₀ < 2^{ℵ₀}` (Cantor), the inclusion is strict: some partial function is not computable.
This is exactly the seed that makes `0 <ᵀ 0'` hold, i.e. that the first jump `PA < PA^H`
genuinely increases power.

## 2. First levels of the jump hierarchy

Reinterpreting `PA^{H^{...}}` as the iterated Turing jump `0^{(n)}`:

```
level 0 : 0      = deg(∅)         (computable sets)
level 1 : 0'     = deg(halting problem K)
level 2 : 0''    = deg(K')        (halting problem relative to K)
level 3 : 0'''   ...
```

The abstract theorem `IsJump.hierarchy_strictMono` gives, for any jump operator `J`,
```
deg(J^[0] A) < deg(J^[1] A) < deg(J^[2] A) < ...
```
which for `A = 0` and `J = ·'` is the standard strictly increasing chain
`0 <ᵀ 0' <ᵀ 0'' <ᵀ ...`.

## 3. Counterexample hunt (contrarian mode)

Two natural-sounding conjectures were tested and **refuted**:

* *"Every oracle increases power."* — FALSE. A computable oracle `g` (i.e. `Nat.Partrec g`)
  leaves the class of computable functions unchanged: `RecursiveIn {g} f ↔ Nat.Partrec f`
  (`partrec_oracle_useless`). Only genuinely non-computable oracles (like `H`) help.
* *"The jump is idempotent"* (`J(J A) ≡ᵀ J A`). — FALSE for any abstract jump:
  `jump_not_idempotent`, since `J(JA)` is strictly above `JA`.

## 4. OEIS

No integer sequence is central to the statements; the relevant "sequence" is the ordinal-indexed
jump hierarchy `0^{(n)}`, whose degrees are pairwise incomparable-free (a chain) but not a
numerical sequence. No OEIS entry applies.
