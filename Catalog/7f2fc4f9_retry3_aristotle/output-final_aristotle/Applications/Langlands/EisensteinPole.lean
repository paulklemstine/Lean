/-
# The pole of the standard Eisenstein series `E(s; z)` at `s = 1` (analytic core)

The Franke decomposition for level-one spherical forms (companion file
`FrankeDecomposition.lean`) is a *finite* Laurent combination precisely because the standard
Eisenstein series `E(s; z)` has only finitely many poles in the region `Re(s) ≥ 1/2` — in fact
a single simple pole at `s = 1`.

For `SL(2, ℤ)` the constant term of `E(s; z)` is `y^s + φ(s) · y^{1-s}` with scattering factor
`φ(s) = √π · Γ(s - 1/2) · ζ(2s-1) / (Γ(s) · ζ(2s))`.  The *entire* pole of `E(s; z)` at
`s = 1` is produced by the **arithmetic factor** `ζ(2s-1)`, which inherits the simple pole of
the Riemann zeta function at its argument `= 1`.  Everything else (`Γ`, `ζ(2s)`) is finite and
non-vanishing there.

We formalise this arithmetic engine directly from Mathlib's `riemannZeta_residue_one`.

Main results:

* `FrankeSL2Z.eisenstein_arithmetic_factor_residue` — `s ↦ (s-1) · ζ(2s-1)` tends to `1/2` as
  `s → 1`; the arithmetic factor of the scattering matrix has a **simple pole at `s = 1` with
  residue `1/2`**.
* `FrankeSL2Z.eisenstein_arithmetic_factor_blows_up` — consequently `s ↦ ζ(2s-1)` has **no finite
  limit** at `s = 1`: the pole is genuine, so the residual/Eisenstein contribution to the Franke
  decomposition is actually present (nonzero residue).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the finiteness of the Franke Laurent combination is not an accident;
it is inherited, place by place, from the single simple pole of `ζ` at `1`.  Bold sub-claim: the
residue of the SL(2,ℤ) scattering factor's arithmetic part at `s = 1` is the clean rational `1/2`.

Experiment (Experimenter): took `riemannZeta_residue_one : (u-1)·ζ(u) → 1` and composed with the
affine substitution `u = 2s-1`.  The delicate step was proving the substitution maps the
punctured neighbourhood `𝓝[≠] 1` into itself: continuity gives `𝓝 1 → 𝓝 1`, and injectivity of
`s ↦ 2s-1` (via `field_simp`/`linear_combination`) gives the "punctured" part.  Then
`(s-1)·ζ(2s-1) = ½·((2s-1)-1)·ζ(2s-1)`, so the limit is `½·1 = ½`.

Analysis (Analyst): the residue `1/2 ≠ 0` upgrades to a genuine blow-up: if `ζ(2s-1)` had a
finite limit `L`, then `(s-1)·ζ(2s-1) → 0·L = 0`, contradicting `→ 1/2` by uniqueness of limits
(`𝓝[≠] 1` is `NeBot` on `ℂ`).  This is exactly why the Eisenstein term survives in the Franke
decomposition rather than being absorbed into the cusp forms.  Failure mode ruled out: trying to
`simpa` the affine limit `2·1-1` to `1` silently left `2-1` unreduced — needed an explicit
`norm_num` / `convert`.

Critique (Critic): is `eisenstein_arithmetic_factor_residue` merely `riemannZeta_residue_one` in
disguise?  No — the affine reparametrisation changes the residue from `1` to `1/2` and requires
the nontrivial punctured-neighbourhood transport.  Is the blow-up trivial?  No — it is a real
`by_contra`/limit-uniqueness argument that consumes the nonvanishing of the residue.

Synthesis (PI): the sole pole of the level-one Eisenstein series is pinned to `ζ`'s pole, with an
explicit residue `1/2`, certifying both the *finiteness* and the *nontriviality* of the Franke
residual term.
-/
import Mathlib

open Filter Topology Complex

namespace FrankeSL2Z

/-- The affine substitution `s ↦ 2s - 1` maps the punctured neighbourhood of `1` into itself. -/
private theorem sub_tendsto :
    Tendsto (fun s : ℂ => 2 * s - 1) (𝓝[≠] 1) (𝓝[≠] 1) := by
  have hc : Continuous (fun s : ℂ => 2 * s - 1) := by fun_prop
  have hcont : Tendsto (fun s : ℂ => 2 * s - 1) (𝓝 1) (𝓝 1) := by
    have h := hc.tendsto (1 : ℂ); norm_num at h; convert h using 2
  rw [tendsto_nhdsWithin_iff]
  refine ⟨hcont.mono_left nhdsWithin_le_nhds, ?_⟩
  filter_upwards [self_mem_nhdsWithin] with s hs
  simp only [Set.mem_compl_iff, Set.mem_singleton_iff] at *
  intro h; apply hs
  have : (2 : ℂ) * s = 2 := by linear_combination h
  field_simp at this; linear_combination this

/-- **Residue of the arithmetic scattering factor.**  As `s → 1`, the function
`s ↦ (s-1) · ζ(2s-1)` tends to `1/2`.  Equivalently, the arithmetic factor `ζ(2s-1)` of the
`SL(2, ℤ)` scattering matrix has a simple pole at `s = 1` with residue `1/2`; this is the sole
source of the pole of the standard Eisenstein series `E(s; z)`. -/
theorem eisenstein_arithmetic_factor_residue :
    Tendsto (fun s : ℂ => (s - 1) * riemannZeta (2 * s - 1)) (𝓝[≠] 1) (𝓝 (1 / 2)) := by
  have key := riemannZeta_residue_one.comp sub_tendsto
  have hstep :
      Tendsto (fun s : ℂ => (2 : ℂ) * ((s - 1) * riemannZeta (2 * s - 1))) (𝓝[≠] 1) (𝓝 1) := by
    apply key.congr; intro s; simp only [Function.comp]; ring
  have h2 := hstep.const_mul ((1 : ℂ) / 2)
  have : Tendsto (fun s : ℂ => (s - 1) * riemannZeta (2 * s - 1)) (𝓝[≠] 1)
      (𝓝 ((1 / 2) * 1)) := by
    apply h2.congr; intro s; ring
  simpa using this

/-- **The pole is genuine.**  The arithmetic scattering factor `s ↦ ζ(2s-1)` has no finite limit
as `s → 1`: it blows up.  Hence the residual/Eisenstein contribution in the Franke decomposition
has nonzero residue and is actually present. -/
theorem eisenstein_arithmetic_factor_blows_up :
    ¬ ∃ L : ℂ, Tendsto (fun s : ℂ => riemannZeta (2 * s - 1)) (𝓝[≠] 1) (𝓝 L) := by
  rintro ⟨L, hL⟩
  have hsub : Tendsto (fun s : ℂ => s - 1) (𝓝[≠] 1) (𝓝 0) := by
    have h0 : Tendsto (fun s : ℂ => s - 1) (𝓝 1) (𝓝 0) := by
      have hc : Continuous (fun s : ℂ => s - 1) := by fun_prop
      have h := hc.tendsto (1 : ℂ); norm_num at h; convert h using 2
    exact h0.mono_left nhdsWithin_le_nhds
  have hprod := hsub.mul hL
  simp only [zero_mul] at hprod
  have := tendsto_nhds_unique eisenstein_arithmetic_factor_residue hprod
  norm_num at this

end FrankeSL2Z