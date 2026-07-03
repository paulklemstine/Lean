# Computational Evidence: Phantom Rigidity and Splittability

This cycle studies *phantom topologies*: a family `T : ι → TopologicalSpace X` of
"observer" topologies whose **consensus** (real) topology is `⨆ i, T i`, the topology whose
opens are exactly the sets open in *every* observer. A representation is *genuine* when
every observer is strictly finer than the consensus. The central question addressed here is
qualitative: **which topologies can be split among two or more genuine observers?**

## 1. Small-case enumeration: topologies on `Bool`

There are exactly four topologies on a two-point set `{true, false}`, ordered by fineness
(`≤` = finer = more opens):

| topology            | opens                          | role                    |
|---------------------|--------------------------------|-------------------------|
| discrete `⊥`        | `∅, {t}, {f}, univ`            | finest (bottom)         |
| Sierpiński `S_t`    | `∅, {t}, univ`                 | between                 |
| Sierpiński `S_f`    | `∅, {f}, univ`                 | between                 |
| indiscrete `⊤`      | `∅, univ`                      | coarsest (top)          |

Covering relations: `⊥ < S_t < ⊤` and `⊥ < S_f < ⊤`, with `S_t`, `S_f` incomparable.

Join (consensus) table, where `a ⊔ b` has opens `opens(a) ∩ opens(b)`:

- `S_t ⊔ S_f = ⊤`   (common opens `{∅, univ}`)  → `⊤` is **splittable**.
- The only topology strictly finer than `S_t` is `⊥`; likewise for `S_f`. Hence
  `S_t = a ⊔ b` with `a, b < S_t` is impossible (both would be `⊥`, whose join is `⊥ ≠ S_t`).
  → `S_t` is **rigid** (join-irreducible).
- Nothing is strictly finer than `⊥`, so `⊥` is **rigid**.

**Observation.** Splittability is *not* monotone in fineness: the coarsest topology `⊤` is
splittable while the finer `S_t` sitting just below it is rigid. This motivated the
`extremal_phantom_dichotomy` / `bool_phantom_dichotomy` results.

## 2. Generalising the split of the indiscrete topology

For a set `X` with two distinct points `p ≠ q`, define the **co-excluded-point** topology
`coExcl a` with opens `{∅, univ, univ \ {a}}`. Checking the intersection of open families:

```
opens(coExcl p) ∩ opens(coExcl q)
  = {∅, univ, univ\{p}} ∩ {∅, univ, univ\{q}}
  = {∅, univ}                       (since univ\{p} ≠ univ\{q} when p ≠ q)
  = opens(⊤).
```

So `coExcl p ⊔ coExcl q = ⊤` for *every* `X` with `≥ 2` points — the Sierpiński split is a
special case (`coExcl` on `Bool` are the two Sierpiński topologies). This is
`coExcl_sup_eq_top` / `indiscrete_reducible`.

## 3. Counterexample hunt against the original "≥ 3 observers" conjecture

The proposed conjecture "every non-metrizable space requires at least 3 observers" was
tested and **falsified** already in the catalog (the indiscrete two-point space is
non-metrizable yet is a genuine two-observer consensus). The present cycle explains the
structural reason: splittability is exactly *join-reducibility*, and the number of
observers, when finite, always collapses to two (catalog `finite_collapses_to_two`). No
counterexample to the collapse was found; instead we found rigid topologies (Sierpiński,
discrete) that admit **no** finite genuine representation at all — the honest replacement
for the false "≥ 3" claim.

## 4. Summary of verified claims

- `phantom_reducible_iff`: genuine finite representation ⇔ join-reducibility.
- `sierpTrue_no_genuine_rep`: the Sierpiński topology is phantom-rigid.
- `coExcl_sup_eq_top`, `indiscrete_reducible`, `indiscrete_has_genuine_rep`: every ≥2-point
  indiscrete space splits into two genuine observers.
- `extremal_phantom_dichotomy`: `⊤` splits, `⊥` is rigid, on any ≥2-point space.

All claims above are machine-checked with no `sorry` and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).
