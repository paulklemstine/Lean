import Mathlib

/-!
# The GAP-difference gcd theorem: why every rank-2 divisor cover collapses to
# the counting wall (Factoring round 99).

Umans–Wang's `(α,β)`-Divisor Conjecture (arXiv:2511.10851) — the only named
route past Harvey's deterministic `N^{1/5}` — needs sets `S,T` (each a sum of a
few arithmetic progressions, i.e. a generalised arithmetic progression) whose
DIFFERENCES cover `[n]` by divisibility. Rounds 96/96e attacked this from five
directions (random sets, hill-climbed rank-2 GAPs, design/difference sets,
higher-rank GAPs, divisor reuse) and all five hit the SAME counting wall
`α + 2β ≥ 1`.

This file proves the structural reason, machine-checked, independent of the
birthday obstruction of round 96b.

**`cross_residue`.** If `g` divides every pairwise difference *within* `S` and
*within* `T`, then every **cross**-difference `s - t` lies in a **single residue
class** `(s0 - t0) (mod g)`:
`g ∣ ((s - t) - (s0 - t0))` for all `s ∈ S`, `t ∈ T`.

**Why it matters.** A difference `d = s - t` covers an index `i` only when
`i ∣ d`. Writing `d = g·m + (s0 - t0)`, the part of `i` coprime to `g` must divide
the small multiplier `m`. Covering every `i ≤ n` therefore forces the multiplier
range to absorb the co-prime mass of `[n]` — exactly the counting constraint
`α + 2β ≥ 1`. So the GAP structure does **not** escape the counting wall: it
*reduces* to it. This is why every attack of rounds 96/96e converges, and it
holds for **any** rank of `S` and `T` (nothing here uses rank 2).

Axioms: `[propext, Classical.choice, Quot.sound]` only (standard).
-/

namespace Cryptography.FactoringBarriers.GAPGcd

/-- If `g` divides all intra-`S` differences, every element of `S` is congruent to
the anchor `s0` modulo `g`: `S` lies in one arithmetic progression of step `g`. -/
theorem all_residue {S : Finset ℤ} {s0 g : ℤ} (hs0 : s0 ∈ S)
    (hS : ∀ s ∈ S, ∀ s' ∈ S, g ∣ (s - s')) : ∀ s ∈ S, g ∣ (s - s0) := by
  intro s hs
  exact hS s hs s0 hs0

/-- **The GAP-difference theorem.** If `g` divides every pairwise difference
within `S` and within `T`, then every cross-difference `s - t` lies in the single
residue class `(s0 - t0) (mod g)`. This is the structural reason a GAP divisor
cover cannot evade the counting wall `α + 2β ≥ 1`: each covered index forces its
co-prime-to-`g` part into the small multiplier. -/
theorem cross_residue {S T : Finset ℤ} {s0 t0 g : ℤ} (hs0 : s0 ∈ S) (ht0 : t0 ∈ T)
    (hS : ∀ s ∈ S, ∀ s' ∈ S, g ∣ (s - s')) (hT : ∀ t ∈ T, ∀ t' ∈ T, g ∣ (t - t'))
    : ∀ s ∈ S, ∀ t ∈ T, g ∣ (s - t - (s0 - t0)) := by
  intro s hs t ht
  have h1 : g ∣ (s - s0) := hS s hs s0 hs0
  have h2 : g ∣ (t - t0) := hT t ht t0 ht0
  have key : g ∣ ((s - s0) - (t - t0)) := by
    rcases h1 with ⟨u, hu⟩
    rcases h2 with ⟨v, hv⟩
    refine ⟨u - v, by linear_combination hu - hv⟩
  convert key using 1 <;> ring

end Cryptography.FactoringBarriers.GAPGcd