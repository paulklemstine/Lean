# Computational Evidence — Conjecture 1 (complete extensions form a meet-semilattice)

The claim proved in `Catalog/Novelty/ArgumentationMeetSemilattice.lean` is
order-theoretic: for any argumentation framework `(A, R)`, every nonempty family
`𝒮` of complete extensions has a greatest lower bound `familyMeet 𝒮` which is
again a complete extension, and it is computed as the greatest fixed point of the
defense operator `charF` contained in `⋂₀ 𝒮`. Below we sanity-check the
statement on small frameworks by hand; each is easy to verify directly from the
definitions and matches the general theorem.

## Example 1 — mutual attack `0 ↔ 1` (symmetric, two arguments)

`R 0 1`, `R 1 0`, no self-attacks. The complete extensions are:

| extension | conflict-free | `charF` fixed | complete |
|-----------|:---:|:---:|:---:|
| `∅`       | ✓ | ✓ (`charF ∅ = ∅`, nobody is unattacked) | ✓ (grounded) |
| `{0}`     | ✓ | ✓ (`0` defends itself, `1` not defended) | ✓ |
| `{1}`     | ✓ | ✓ | ✓ |

So the complete-extension poset is `{∅ ⊆ {0}, ∅ ⊆ {1}}` with least element `∅`.

* Meet of `{{0}}`         → `{0}`  (a singleton family returns its member).
* Meet of `{{0}, {1}}`    → intersection `= ∅`; the largest complete set `⊆ ∅`
  is `∅`. Indeed `familyMeet {{0},{1}} = ∅`, matching that `∅` is the only common
  lower bound.
* Meet of all complete extensions `{∅, {0}, {1}}` → `∅ = grounded`. This is the
  content of `exists_least_complete`.

## Example 2 — odd 3-cycle `0 → 1 → 2 → 0`

The only admissible (hence only complete) extension is `∅` (see
`ArgumentationStableGap.cycle3_preferred_empty`). The family of all complete
extensions is `{∅}`, its meet is `∅`, and `∅` is trivially the least complete
extension. Consistent with the theorem.

## Example 3 — a defended pair `2 → 0`, `2 → 1`, `0 → 2`

Here `charF ∅ = {a | a unattacked}`. Argument `2` is attacked by `0`; `0` is
attacked by `2`; `1` is attacked by `2`. The grounded extension iterates: start
`∅`; `charF ∅ = ∅` (nobody unattacked), so grounded `= ∅`. Preferred/complete
extensions include `{0}` (0 defends itself against 2, since 0 attacks 2). The
meet of the single-element family `{{0}}` is `{0}`; the meet of the full family
of complete extensions collapses to the grounded extension `∅`.

## Why a heavier computational search is unnecessary

The theorem is a purely order-theoretic consequence of two structural facts that
hold at every framework, with **no finiteness assumption**:

1. `charF` is monotone and a complete extension is exactly a conflict-free fixed
   point of `charF`;
2. `charF` maps the intersection of complete extensions into itself
   (`charF_sInter_subset`), so a greatest fixed point below the intersection
   exists by a Knaster–Tarski union.

There is therefore no universally-quantified numeric claim that could fail on a
large instance — the small cases above already exhibit every qualitative
phenomenon (nonempty meet, meet dropping to the grounded extension, singleton
family returning its member). The formal Lean proof discharges the fully general
statement.
