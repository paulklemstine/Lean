# Computational Evidence — Phantom Topologies over Ordered Observers

This note records the small-case checks that preceded the formal development in
`PhantomTopologyOrderGeneral.lean` and `PhantomTopologyOrderBridge.lean`.

## 1. The interval-split identity (the whole engine)

The metric-free proof reduces to a single order identity:

```
Ioo a b = Ioc a x ∪ Ico x b     whenever a < x < b.
```

Sample checks over ℚ (endpoints as ordered pairs):

| a | x | b | Ioc a x        | Ico x b        | union        | Ioo a b |
|---|---|---|----------------|----------------|--------------|---------|
| 0 | 1 | 2 | (0,1]          | [1,2)          | (0,2)        | (0,2) ✓ |
| -1| 0 | 1 | (-1,0]         | [0,1)          | (-1,1)       | (-1,1) ✓|
| 0 |1/2| 1 | (0,1/2]        | [1/2,1)        | (0,1)        | (0,1) ✓ |

The proof is a `le_total y x` case split, using no completeness or metric — so it
holds verbatim in ℚ, ℝ, and any linear order.

## 2. Density controls the phantom number

**Dense chains (ℚ, ℝ).** The ray `Ici x = [x,∞)` is open for the lower-limit
observer (take `b` any point `> y`), but it is *not* order-open: any `Ioo a b`
neighbourhood of `x` (with `a < x`) contains, by density, a point `c` with
`a < c < x`, and `c ∉ [x,∞)`. Sample over ℚ at `x = 0`:

- candidate neighbourhood `(-1/2, 1/2)`; density gives `c = -1/4 ∈ (-1/2,1/2)`
  but `-1/4 ∉ [0,∞)`. Escape confirmed.

Hence the lower observer is *strictly* finer than reality, and dually for the
upper observer, so **two** distinct observers are needed and suffice.

**Discrete chains (ℤ).** Here `Ico n (n+1) = {n}`, so *every* subset is
lower-open. Sample:

- `Ico 3 4 = {3}`, `Ico (-2) (-1) = {-2}`. Every singleton is lower-open ⇒ the
  lower topology is the discrete topology ⇒ it already equals the order topology.
  A single observer determines reality: **phantom number one**.

So the phantom number of an order chain measures *order density*, not size or
metrizability. This is the counter-intuitive finding of the cycle.

## 3. Counterexample hunt

- *"Every order topology (no endpoints) is a two-observer consensus."* — Searched
  ℤ, ℚ, ℝ. Holds for all three (`consensus_orderTop`). ℤ additionally collapses to
  one observer, which does **not** contradict the theorem (it is still a
  consensus of the two observers, they simply coincide).
- *"Two distinct strictly-finer observers exist for every order topology."* —
  **False** on ℤ (both observers equal reality). Guarded by adding
  `DenselyOrdered`; the ℤ collapse is retained as `lowerTopGen_int_eq_bot` to
  witness necessity.

## 4. No OEIS sequence

The invariants here are `1` (discrete) and `2` (dense), not an integer sequence,
so no OEIS lookup applies. Evidence is structural rather than enumerative.
