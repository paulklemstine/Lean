import Applications.LagrangeRatioSpectrum.Core

/-!
# Lagarias–Shallit lower ratio bound for diagonal dilations

For the diagonal matrix `M = ![![n, 0], ![0, 1]]` (with `n ≥ 1`), the induced
action on `x` is `x ↦ n·x` and `det M = n`.  The Lagarias–Shallit two-sided
bound predicts `|det M|⁻¹ ≤ k(Mx)/k(x) ≤ |det M|`, i.e. here
`Lc x / n ≤ Lc (n·x) ≤ n · Lc x`.

This file proves the **lower** half `Lc x / n ≤ Lc (n·x)` unconditionally
(for every real `x`).  This is the bound corresponding to the left endpoint
`|det M|⁻¹` of the conjectural ratio interval.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Restricting `q` to multiples of `n` can only
*increase* a `liminf` (subsequences have `liminf ≥` the full sequence), and the
exact identity `approx (n·x) q = approx x (n·q)/n` turns `Lc (n·x)` into a
`liminf` over the multiples-of-`n` subsequence, scaled by `1/n`.  Therefore
`Lc (n·x) = (liminf over multiples)/n ≥ Lc x / n`.

EXPERIMENT (Experimenter).  Proven below.  Three ingredients:
* `approx_dilation` (in Core) — the exact pointwise scaling.
* `liminf_div_const` — division by a finite nonzero constant commutes with
  `liminf` in `ENNReal`; proven via the order isomorphism `y ↦ y/c` (`divIso`)
  and `OrderIso.liminf_apply`.
* `Lc_le_liminf_subseq` — subsequence monotonicity of `liminf`, via
  `liminf_le_liminf_of_le` for the filter inequality `map (n·) atTop ≤ atTop`
  and `liminf_comp`.

ANALYSIS (Analyst).  Only the *lower* bound is unconditional and elementary.
The matching upper bound `Lc (n·x) ≤ n · Lc x` is **true but hard**: it is the
genuine Lagarias–Shallit content and requires controlling `q‖qx‖` along an
arithmetic progression (a three-distance / pigeonhole argument), which is not
attempted here.  Working in `ENNReal` was the decisive design choice — it makes the
`liminf` boundedness side conditions discharge automatically.

CRITIQUE (Critic).  The bound is sharp at `n = 1` (it becomes `Lc x ≤ Lc x`)
and is a strict, non-vacuous inequality of `liminf`s for `n ≥ 2`.  No
`native_decide`/`True`.
-/

open Filter Topology

namespace LagrangeSpectrum

/-- Division by a finite nonzero constant, as an order isomorphism of `ENNReal`. -/
noncomputable def divIso (c : ENNReal) (hc : c ≠ 0) (hc' : c ≠ ⊤) : ENNReal ≃o ENNReal where
  toFun y := y / c
  invFun y := y * c
  left_inv y := by simp only; rw [ENNReal.div_mul_cancel hc hc']
  right_inv y := by simp only; rw [ENNReal.mul_div_cancel_right hc hc']
  map_rel_iff' := by
    intro a b; simp only [Equiv.coe_fn_mk]
    rw [ENNReal.div_le_iff hc hc', ENNReal.div_mul_cancel hc hc']

/-- Division by a finite nonzero constant commutes with `liminf` in `ENNReal`. -/
theorem liminf_div_const (g : ℕ → ENNReal) (c : ENNReal) (hc : c ≠ 0) (hc' : c ≠ ⊤) :
    Filter.liminf (fun q => g q / c) atTop = (Filter.liminf g atTop) / c := by
  have := (divIso c hc hc').liminf_apply (u := g) (f := atTop)
  simpa [divIso] using this.symm

/-- Restricting to the multiples-of-`n` subsequence cannot decrease the `liminf`. -/
theorem Lc_le_liminf_subseq (x : ℝ) (n : ℕ) (hn : 1 ≤ n) :
    Lc x ≤ Filter.liminf (fun q => approx x (n * q)) atTop := by
  have htends : Tendsto (fun q => n * q) atTop atTop := by
    apply Filter.tendsto_atTop_mono (fun q => ?_) tendsto_id
    exact Nat.le_mul_of_pos_left q hn
  have h : map (fun q => n * q) atTop ≤ atTop := htends
  calc Lc x = Filter.liminf (approx x) atTop := rfl
    _ ≤ Filter.liminf (approx x) (map (fun q => n * q) atTop) := liminf_le_liminf_of_le h
    _ = Filter.liminf (fun q => approx x (n * q)) atTop := liminf_comp (approx x) _ atTop

/-- **Lagarias–Shallit lower ratio bound** for the diagonal dilation `x ↦ n·x`
(matrix `diag(n, 1)`, determinant `n`): `k(M x) / k(x) ≥ |det M|⁻¹`, i.e.
`Lc x / n ≤ Lc (n·x)`. -/
theorem Lc_dilation_lower (x : ℝ) (n : ℕ) (hn : 1 ≤ n) :
    Lc x / (n : ENNReal) ≤ Lc ((n : ℝ) * x) := by
  have hne : (n : ENNReal) ≠ 0 := by exact_mod_cast Nat.one_le_iff_ne_zero.mp hn
  have htop : (n : ENNReal) ≠ ⊤ := ENNReal.natCast_ne_top n
  have hstep : Lc ((n : ℝ) * x)
      = Filter.liminf (fun q => approx x (n * q)) atTop / (n : ENNReal) := by
    unfold Lc
    rw [show approx ((n : ℝ) * x) = (fun q => approx x (n * q) / (n : ENNReal)) from
      funext fun q => approx_dilation x n q hn]
    exact liminf_div_const _ _ hne htop
  rw [hstep]
  exact ENNReal.div_le_div_right (Lc_le_liminf_subseq x n hn) _

end LagrangeSpectrum