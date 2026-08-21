# Computational evidence: clique sums, independence number, chromatic number

All formal claims of this project are proved in Lean (see
`Catalog/Pythagorean/GraphTheory/CliqueSum.lean`,
`CliqueSumExact.lean`, `CliqueSumSharpness.lean`). The exhaustive searches recorded
here were run in an ad-hoc script and are **exploratory evidence only** — they are
not machine-verified. Everything they suggested was subsequently turned into a Lean
theorem or a Lean-verified counterexample witness.

## Setup

A clique sum is modelled on a common vertex set `V` by finsets `s, t` with
`s ∪ t = V`, `s ∩ t = K`, graphs `G₁` (edges inside `s`), `G₂` (edges inside `t`),
`G = G₁ ⊔ G₂`, and `K` a clique of **each** side. Write `k = |K|`,
`α₁ = α(G₁[s])`, `α₂ = α(G₂[t])`, `α = α(G)`, similarly `χ`, `ω`.

## Exhaustive enumerations

For each shape below every pair `(G₁, G₂)` of side graphs containing all edges of `K`
was enumerated, and five statements were checked.

| shape (`s`, `t`, `K`) | #instances | `α₁+α₂ ≤ α+1` fails | `α₁+α₂ ≤ α+2` fails | trace formula fails | `χ = max` fails | `ω = max` fails | `α₁+α₂ = α+2` |
|---|---|---|---|---|---|---|---|
| `{0,1,2}`, `{0,3,4}`, `K={0}` (k=1) | 64 | 0 | 0 | 0 | 0 | 0 | 0 |
| `{0,1,2}`, `{0,1,3}`, `K={0,1}` (k=2) | 16 | **2** | 0 | 0 | 0 | 0 | 2 |
| `{0,1,2,3}`, `{0,1,4}`, `K={0,1}` (k=2) | 128 | **12** | 0 | 0 | 0 | 0 | 12 |
| `{0,1,2,3}`, `{0,1,2,4}`, `K={0,1,2}` (k=3) | 64 | **12** | 0 | 0 | 0 | 0 | 12 |

Here "trace formula" is
`α = max_{T ⊆ K, |T| ≤ 1} (α₁(T) + α₂(T) − |T|)`, where `α_i(T)` is the largest
independent set of side `i` meeting `K` exactly in `T`.

## Readings

1. **`α ≥ α₁ + α₂ − 1` is false as soon as `k ≥ 2`.** The first failure found is the
   smallest possible one and became Witness A of `CliqueSumSharpness.lean`:
   `V = {0,1,2,3}`, `G₁ = 2—1—0`, `G₂ = 1—0—3`, `K = {0,1}`; then
   `α₁ = α₂ = 2` while `α(G) = 2` (the glued graph is the path `2—1—0—3`).
   The naive argument ("two maximum independent sets overlap in at most one vertex,
   so their union has ≥ α₁+α₂−1 vertices") fails because the union need not be
   independent: an edge of `G₂` can join the `K`-vertex of `A₁` to a non-`K` vertex
   of `A₂`.
2. **`α ≥ α₁ + α₂ − 2` never failed, and is attained** in every `k ≥ 2` shape tested
   (rightmost column). Proved: `IsCliqueSum.indepNumOn_add_le_add_two`, sharpness
   `alpha_sub_two_sharp`.
3. **No failure at `k ≤ 1`**, matching the proved statements
   `IsCliqueSum.indepNumOn_add_le_add_one` (`k ≤ 1`) and
   `IsCliqueSum.indepNumOn_add_le_of_card_eq_zero` (`k = 0`), unified in
   `IsCliqueSum.indepNumOn_add_le_add_min`: `α₁ + α₂ ≤ α + min(k, 2)`, sharp in all
   three regimes.
4. **The trace formula was exact in all 272 instances**, which motivated the proved
   `IsCliqueSum.indepNumOn_eq_sup_traces`.
5. **`χ(G) = max(χ₁, χ₂)` and `ω(G) = max(ω₁, ω₂)` never failed** for genuine clique
   sums. Proved: `IsCliqueSum.chromaticNumber_eq_max`, `IsCliqueSum.cliqueNumOn_eq_max`.
6. **Dropping "K is a clique on each side" destroys both statements.** Searching
   *weak* clique sums (`K` only required to be a clique of `G`) on `V = {0,1,2}` with
   `s = t = K = V` produced the triangle split as `G₁ = 0—1`, `G₂ = 0—2, 1—2`:
   each side is `2`-colourable (`n = 2 < 3 = k`) while `χ(G) = 3`, and
   `α₁ = α₂ = 2` while `α(G) = 1`. This became Witness B, and the Lean theorems
   `chromaticNumber_max_fails_of_weak`, `alpha_sub_two_fails_of_weak`.

No OEIS sequence is involved: the data are boolean/extremal checks rather than a
counting sequence.
