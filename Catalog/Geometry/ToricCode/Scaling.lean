import Geometry.ToricCode.Dual
import Geometry.ToricCode.Locality
/-!
# Correct asymptotics: distance in terms of block length, not genus

Future target 6 of the previous cycle asked to replace the unsupported
genus-only `O(√g)` slogan by statements in the *correct* variables.  For the
`M × N` torus family everything is exact, so no asymptotic notation is needed.

* `toric_BPT_bound` : `k · d² ≤ n` for every rectangular torus.  The
  Bravyi–Poulin–Terhal tradeoff `k d² = O(n)` for two-dimensional local codes
  holds here with constant one.
* `toric_BPT_saturation` : `k · d² = n` for the *square* torus — the bound above
  is saturated exactly, and (by `rectangular_BPT_strict`) only there.
* `toric_sqrt_scaling` : `2 d² = n` for the square torus, i.e. `d = √(n/2)`.
* `genus_one_distance_unbounded` : the *geometric* strengthening of the previous
  cycle's abstract counterexample.  For every `d > 0` there is a genuine
  cellulation of the **genus-one** surface, with all check weights `4` and all
  qubit degrees `2`, whose primal and dual distances both equal `d`.  So no
  distance bound can be a function of the genus (equivalently, of the homology
  rank) alone — even after imposing bounded local geometry.  The correct
  variable is the block length `n`.
* `aspect_ratio_distance_collapse` : keeping `n = 2MN` as large as one likes
  while fixing `M`, the distance stays `M`.  Block length alone does not bound
  the distance from below either; the aspect ratio matters.
-/

open Matrix

namespace ToricCode

/-- **The two-dimensional `k d² ≤ n` tradeoff for every rectangular torus.** -/
theorem toric_BPT_bound (M N : ℕ) [NeZero M] [NeZero N] :
    homologyRank M N * (distance M N) ^ 2 ≤ Fintype.card (Edge M N) := by
  rw [toric_homologyRank, toric_distance, card_edge]
  rcases min_cases M N with ⟨h, hle⟩ | ⟨h, hle⟩ <;> rw [h] <;> nlinarith [hle]

variable (L : ℕ) [NeZero L]

/-- **Exact saturation of the two-dimensional `k d² ≤ n` tradeoff.**  For the
`L × L` toric code, `k · d² = n` on the nose. -/
theorem toric_BPT_saturation :
    homologyRank L L * (distance L L) ^ 2 = Fintype.card (Edge L L) := by
  rw [toric_homologyRank, toric_distance, card_edge, min_self]
  ring

/-- **Square-root scaling in the block length.**  `d = √(n/2)`, stated
multiplicatively to stay inside `ℕ`. -/
theorem toric_sqrt_scaling : 2 * (distance L L) ^ 2 = Fintype.card (Edge L L) := by
  rw [toric_distance, card_edge, min_self]
  ring

/-- **Genus alone never bounds the distance, even with bounded local geometry.**
For every prescribed `d ≥ 2` the `d × d` torus cellulation has genus one
(first homology rank `2`), all `Z`- and `X`-checks of weight `4`, every qubit in
exactly two checks of each type, `2d²` physical qubits, and primal and dual
distance exactly `d`. -/
theorem genus_one_distance_unbounded (d : ℕ) (hd : 2 ≤ d) :
    haveI : NeZero d := ⟨by omega⟩
    homologyRank d d = 2 ∧ dualHomologyRank d d = 2 ∧
      distance d d = d ∧ dualDistance d d = d ∧
      Fintype.card (Edge d d) = 2 * (d * d) ∧
      (∀ v : Vert d d, (zSupport d d v).card = 4) ∧
      (∀ f : Face d d, (xSupport d d f).card = 4) ∧
      (∀ e : Edge d d, (zChecks d d e).card = 2) ∧
      (∀ e : Edge d d, (xChecks d d e).card = 2) := by
  haveI : NeZero d := ⟨by omega⟩
  refine ⟨toric_homologyRank d d, toric_dual_homologyRank d d, ?_, ?_, card_edge d d,
    vertex_degree_eq_four d d hd hd, face_size_eq_four d d hd hd,
    qubit_Z_degree_eq_two d d hd hd, qubit_X_degree_eq_two d d hd hd⟩
  · rw [toric_distance, min_self]
  · rw [toric_dualDistance, min_self]

/-- The distance of the square toric code is *strictly monotone* in `L`, while
the number of encoded qubits stays constant.  This is the precise sense in which
the previous cycle's "rank does not determine distance" is realised
geometrically. -/
theorem distance_strictMono {L₁ L₂ : ℕ} [NeZero L₁] [NeZero L₂] (h : L₁ < L₂) :
    homologyRank L₁ L₁ = homologyRank L₂ L₂ ∧ distance L₁ L₁ < distance L₂ L₂ := by
  refine ⟨by rw [toric_homologyRank, toric_homologyRank], ?_⟩
  rw [toric_distance, toric_distance, min_self, min_self]
  exact h

/-- **Block length does not bound the distance from below.**  Fix the short side
`M`; then as `N` grows the block length `n = 2MN` is unbounded while the
distance stays equal to `M`.  Together with `toric_BPT_saturation` this pins the
role of the aspect ratio: `d = Θ(√n)` needs a *balanced* cellulation. -/
theorem aspect_ratio_distance_collapse (M N : ℕ) [NeZero M] [NeZero N] (h : M ≤ N) :
    distance M N = M ∧ 2 * M * N = Fintype.card (Edge M N) := by
  refine ⟨by rw [toric_distance, min_eq_left h], ?_⟩
  rw [card_edge]; ring

end ToricCode