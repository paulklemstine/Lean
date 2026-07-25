import Mathlib

/-!
# Continuous-Valued Cellular Automata, the Diffusion Threshold, and Rucker's "Gnarl"

This file develops a self-contained algebraic / analytic theory of a
**continuous-valued** (real-valued) one-dimensional cellular automaton (CA),
complementing the discrete `𝔽_p` additive theory in
`Catalog/Novelty/AdditiveCAPadicRenorm.lean`.

Where the additive `𝔽_p` automaton lives in a finite field and exhibits crisp
self-similar (Sierpiński) space-time diagrams, a *continuous-valued* automaton
takes states in `ℝ`.  Rudy Rucker's experimental work on continuous-valued CAs
(the "CAPOW" project) singles out the **gnarly zone** ("gnarl"): the narrow band
of rule parameters where the dynamics is neither frozen/laminar nor fully
turbulent, but lives on the *edge of chaos*.

We model the canonical *symmetric three-point linear* continuous CA — the
discrete diffusion / heat rule — acting on bi-infinite configurations
`c : ℤ → ℝ`:

  `step a c x = a · c(x-1) + (1 - 2a) · c(x) + a · c(x+1)`.

The single real parameter `a` is the diffusion coefficient.  This is the linear
core around which Rucker's nonlinear "Hodgepodge"/heat rules are built, and it
already exhibits a *sharp* phase boundary.

## Main results

* `step_add`, `step_smul` — the evolution operator is `ℝ`-linear.
* `step_const` — uniform (constant) configurations are fixed points
  (mass / DC-mode conservation, since the stencil weights sum to `1`).
* `step_shift` — translation equivariance (the rule is space-homogeneous).
* `step_alt`, `iter_alt` — the alternating configuration `alt x = (-1)^x`
  (the highest Fourier mode) is an **eigenvector** with eigenvalue `1 - 4a`,
  and after `n` steps the amplitude is `(1 - 4a)^n`.
* `step_geom`, `eigenvalue_one`, `eigenvalue_negOne` — the full real spectrum:
  every geometric mode `geom r x = r^x` (`r ≠ 0`) is an eigenvector with
  eigenvalue `(1-2a) + a(r + r⁻¹)`, unifying the constant (`r = 1`, eigenvalue
  `1`) and alternating (`r = -1`, eigenvalue `1 - 4a`) modes.
* `mass_conserved`, `mass_iter_conserved` — **conservation of total mass**
  (the discrete "heat content"): for finitely supported configurations the
  `finsum` `∑ᶠ x, c x` is invariant under the rule and all its iterates, because
  the stencil weights sum to `1`.
* `step_le`, `le_step`, `abs_step_le`, `abs_iter_le` — the **discrete maximum
  principle**: in the convex/diffusive regime `0 ≤ a ≤ 1/2` the rule is a
  sup-norm contraction, so no pattern can grow.  This is the *laminar* side.
* `unbounded_of_gt_half`, `unbounded_of_neg`, `unbounded_outside` — outside the
  convex regime (`a < 0` or `a > 1/2`) the eigenvalue exceeds `1` in modulus and
  the alternating mode blows up: the linear *instability onset* that seeds the
  gnarly zone.
* `stability_dichotomy` — a single statement packaging both phases: in `[0,1/2]`
  every bounded pattern stays bounded, while outside it the spectral radius is
  `> 1`.

## Catalog synthesis

This continues the `Novelty` line on cellular automata.  The `𝔽_p` file
(`AdditiveCAPadicRenorm`) studies the *operator-algebra* of a discrete additive
CA via Laurent polynomials; this file studies the *order/metric* structure of a
continuous CA via the maximum principle, and locates the linear-stability
threshold `a = 1/2` that bounds Rucker's gnarl from the laminar side.
-/

namespace ContinuousValuedCA

open scoped BigOperators
open Function

/-- One synchronous update of the symmetric three-point continuous CA with
diffusion coefficient `a`.  The stencil weights `(a, 1-2a, a)` sum to `1`. -/
def step (a : ℝ) (c : ℤ → ℝ) : ℤ → ℝ :=
  fun x => a * c (x - 1) + (1 - 2 * a) * c x + a * c (x + 1)

/-- The unit space-shift `(shift c)(x) = c(x+1)`. -/
def shift (c : ℤ → ℝ) : ℤ → ℝ := fun x => c (x + 1)

/-- The alternating configuration `alt x = (-1)^x`: the highest-frequency
Fourier mode on the integer lattice. -/
noncomputable def alt : ℤ → ℝ := fun x => (-1 : ℝ) ^ x

/-- Time-`n` evolution: iterate `step a` exactly `n` times. -/
noncomputable def iter (a : ℝ) (n : ℕ) (c : ℤ → ℝ) : ℤ → ℝ := (step a)^[n] c

/-! ### Linearity and symmetries -/

-- !-- Lab Notes -- !--
-- Hypothesis H1: the three-point rule is ℝ-linear and space-homogeneous, so its
-- spectrum is governed entirely by Fourier modes `x ↦ z^x`.  Confirmed below:
-- `step_add`/`step_smul` give linearity, `step_shift` gives translation
-- equivariance.  These reduce the whole stability question to the eigenvalues on
-- the modes — the crucial simplification that makes the threshold provable.

@[simp] theorem step_add (a : ℝ) (c d : ℤ → ℝ) :
    step a (c + d) = step a c + step a d := by
  funext x; simp only [step, Pi.add_apply]; ring

@[simp] theorem step_smul (a k : ℝ) (c : ℤ → ℝ) :
    step a (k • c) = k • step a c := by
  funext x; simp only [step, Pi.smul_apply, smul_eq_mul]; ring

/-- Constant configurations are fixed: the DC (zero-frequency) mode has
eigenvalue `1`, i.e. total "mass" is conserved because the weights sum to `1`. -/
@[simp] theorem step_const (a k : ℝ) : step a (fun _ => k) = fun _ => k := by
  funext x; simp only [step]; ring

/-- The rule commutes with the space shift: it is translation equivariant. -/
theorem step_shift (a : ℝ) (c : ℤ → ℝ) : step a (shift c) = shift (step a c) := by
  funext x; simp only [step, shift]; ring_nf

/-! ### The highest mode is an eigenvector: eigenvalue `1 - 4a` -/

-- !-- Lab Notes -- !--
-- Experiment E1: feed in the Nyquist mode `alt x = (-1)^x`.  Algebra gives
--   step a alt = a·(-(-1)^x) + (1-2a)(-1)^x + a·(-(-1)^x) = (1-4a)·(-1)^x.
-- So the per-step amplification of the spikiest possible pattern is exactly
-- `1 - 4a`.  This single number is the order parameter for the phase transition:
--   |1 - 4a| ≤ 1  ⇔  0 ≤ a ≤ 1/2  (laminar / contracting),
--   |1 - 4a| > 1  ⇔  a < 0 ∨ a > 1/2  (unstable / gnarl-seeding).

/-- **Eigenvector identity.** The alternating mode is an eigenvector of `step a`
with eigenvalue `1 - 4a`. -/
theorem step_alt (a : ℝ) : step a alt = (1 - 4 * a) • alt := by
  funext x
  simp only [step, alt, Pi.smul_apply, smul_eq_mul,
    zpow_sub_one₀ (by norm_num : (-1 : ℝ) ≠ 0),
    zpow_add_one₀ (by norm_num : (-1 : ℝ) ≠ 0)]
  ring

/-- After `n` steps the alternating amplitude is `(1 - 4a)^n`. -/
theorem iter_alt (a : ℝ) (n : ℕ) : iter a n alt = (1 - 4 * a) ^ n • alt := by
  induction n with
  | zero => simp [iter]
  | succ k ih =>
    rw [iter, Function.iterate_succ', Function.comp_apply, ← iter, ih, step_smul,
        step_alt, smul_smul, pow_succ]

/-- Pointwise value of the evolved alternating mode. -/
theorem iter_alt_apply (a : ℝ) (n : ℕ) (x : ℤ) :
    iter a n alt x = (1 - 4 * a) ^ n * (-1 : ℝ) ^ x := by
  rw [iter_alt]; simp [alt, Pi.smul_apply, smul_eq_mul]

/-! ### The full real spectrum: geometric modes -/

-- !-- Lab Notes -- !--
-- Synthesis S2 (unifying the spectrum): both the constant mode (`r = 1`) and the
-- alternating mode (`r = -1`) are special cases of the geometric mode
-- `geom r x = r^x`.  A one-line computation shows every nonzero `r` gives an
-- eigenvector with eigenvalue `λ(a,r) = (1-2a) + a·(r + r⁻¹)`.  Setting `r = 1`
-- recovers `λ = 1` (mass conservation) and `r = -1` recovers `λ = 1 - 4a` (the
-- Nyquist amplification).  Over ℝ the symmetric pair `{r, r⁻¹}` is the analogue
-- of a Fourier mode `e^{±iθ}`; this is the dispersion relation of the rule.

/-- The geometric configuration `geom r x = r^x`. -/
noncomputable def geom (r : ℝ) : ℤ → ℝ := fun x => r ^ x

/-- The eigenvalue (dispersion relation) attached to the geometric mode `geom r`. -/
noncomputable def eigenvalue (a r : ℝ) : ℝ := (1 - 2 * a) + a * (r + r⁻¹)

/-- **General eigenvector identity.** Every nonzero geometric mode is an
eigenvector of `step a`, with eigenvalue `eigenvalue a r = (1-2a) + a(r + r⁻¹)`. -/
theorem step_geom (a r : ℝ) (hr : r ≠ 0) :
    step a (geom r) = eigenvalue a r • geom r := by
  funext x
  simp only [step, geom, eigenvalue, Pi.smul_apply, smul_eq_mul,
    zpow_sub_one₀ hr, zpow_add_one₀ hr]
  field_simp; ring

/-- The constant mode is `geom 1`, with eigenvalue `1` (mass conservation). -/
theorem eigenvalue_one (a : ℝ) : eigenvalue a 1 = 1 := by
  simp only [eigenvalue]; ring

/-- The alternating mode is `geom (-1)`, with eigenvalue `1 - 4a`. -/
theorem eigenvalue_negOne (a : ℝ) : eigenvalue a (-1) = 1 - 4 * a := by
  simp only [eigenvalue]; norm_num; ring

/-! ### Maximum principle: the laminar (diffusive) regime `0 ≤ a ≤ 1/2` -/

-- !-- Lab Notes -- !--
-- Hypothesis H2 (discrete maximum principle): when the weights are a genuine
-- convex combination (a ≥ 0 and 1-2a ≥ 0, i.e. 0 ≤ a ≤ 1/2), one update is a
-- weighted average, hence cannot exceed the current max nor fall below the min.
-- Iterating, the sup-norm is non-increasing: every pattern is *damped*.  This is
-- the rigorous "no gnarl here" statement.  Proven by `nlinarith` from the convex
-- weight inequalities; iteration handled by `Function.iterate_succ'`.

/-- Upper maximum principle on one step (convex regime). -/
theorem step_le (a : ℝ) (ha0 : 0 ≤ a) (ha1 : a ≤ 1 / 2) (c : ℤ → ℝ) (M : ℝ)
    (h : ∀ x, c x ≤ M) (x : ℤ) : step a c x ≤ M := by
  have h1 := h (x - 1); have h2 := h x; have h3 := h (x + 1)
  simp only [step]; nlinarith

/-- Lower maximum principle on one step (convex regime). -/
theorem le_step (a : ℝ) (ha0 : 0 ≤ a) (ha1 : a ≤ 1 / 2) (c : ℤ → ℝ) (m : ℝ)
    (h : ∀ x, m ≤ c x) (x : ℤ) : m ≤ step a c x := by
  have h1 := h (x - 1); have h2 := h x; have h3 := h (x + 1)
  simp only [step]; nlinarith

/-- Sup-norm non-expansiveness of one step in the convex regime. -/
theorem abs_step_le (a : ℝ) (ha0 : 0 ≤ a) (ha1 : a ≤ 1 / 2) (c : ℤ → ℝ) (M : ℝ)
    (h : ∀ x, |c x| ≤ M) (x : ℤ) : |step a c x| ≤ M := by
  have h1 := abs_le.mp (h (x - 1)); have h2 := abs_le.mp (h x)
  have h3 := abs_le.mp (h (x + 1))
  rw [abs_le]; simp only [step]
  constructor <;> nlinarith [h1.1, h1.2, h2.1, h2.2, h3.1, h3.2]

/-- **Sup-norm contraction under iteration.** In the convex regime, a uniformly
bounded pattern stays bounded by the same constant forever: no gnarl. -/
theorem abs_iter_le (a : ℝ) (ha0 : 0 ≤ a) (ha1 : a ≤ 1 / 2) (c : ℤ → ℝ) (M : ℝ)
    (h : ∀ x, |c x| ≤ M) (n : ℕ) : ∀ x, |iter a n c x| ≤ M := by
  induction n with
  | zero => simpa [iter] using h
  | succ k ih =>
    intro x
    rw [iter, Function.iterate_succ', Function.comp_apply, ← iter]
    exact abs_step_le a ha0 ha1 _ M ih x

/-! ### Instability: the gnarl-seeding regime outside `[0, 1/2]` -/

-- !-- Lab Notes -- !--
-- Experiment E2 (instability onset): when |1-4a| > 1 the alternating amplitude
-- (1-4a)^n is unbounded, so a *bounded* initial pattern (the ±1 checkerboard,
-- sup-norm 1) is amplified without bound.  This is the linear precursor of
-- Rucker's gnarl: above the diffusion threshold a = 1/2 the smooth, laminar
-- behaviour breaks and high-frequency structure explodes.  Below a = 0 the rule
-- is "anti-diffusive" and the same instability appears with positive eigenvalue.
-- Failure analysis: `pow_unbounded_of_one_lt` is the right Archimedean lemma;
-- an earlier attempt with `abs_pow` in the wrong orientation failed (pattern
-- `|?a|^?n` absent) and was fixed by rewriting `|x^n| = |x|^n` first.

/-- The spectral radius (here the modulus of the top eigenvalue) exceeds `1`
above the diffusion threshold. -/
theorem spectralRadius_gt_one_of_gt_half (a : ℝ) (ha : 1 / 2 < a) :
    1 < |1 - 4 * a| := by
  rw [abs_of_neg (by linarith)]; linarith

/-- The spectral radius exceeds `1` in the anti-diffusive regime `a < 0`. -/
theorem spectralRadius_gt_one_of_neg (a : ℝ) (ha : a < 0) : 1 < |1 - 4 * a| := by
  rw [abs_of_pos (by linarith)]; linarith

/-- **Instability above the diffusion threshold.** For `a > 1/2`, the bounded
checkerboard pattern is amplified beyond every bound. -/
theorem unbounded_of_gt_half (a : ℝ) (ha : 1 / 2 < a) (M : ℝ) :
    ∃ n, M < |iter a n alt 0| := by
  have hlt : 1 < |1 - 4 * a| := spectralRadius_gt_one_of_gt_half a ha
  obtain ⟨n, hn⟩ := pow_unbounded_of_one_lt M hlt
  refine ⟨n, ?_⟩
  rw [iter_alt_apply]; rw [abs_mul, abs_pow]; simpa using hn

/-- **Instability in the anti-diffusive regime.** Same blow-up for `a < 0`. -/
theorem unbounded_of_neg (a : ℝ) (ha : a < 0) (M : ℝ) :
    ∃ n, M < |iter a n alt 0| := by
  have hlt : 1 < |1 - 4 * a| := spectralRadius_gt_one_of_neg a ha
  obtain ⟨n, hn⟩ := pow_unbounded_of_one_lt M hlt
  refine ⟨n, ?_⟩
  rw [iter_alt_apply]; rw [abs_mul, abs_pow]; simpa using hn

/-- The checkerboard blows up for *any* parameter outside the convex window. -/
theorem unbounded_outside (a : ℝ) (ha : a < 0 ∨ 1 / 2 < a) (M : ℝ) :
    ∃ n, M < |iter a n alt 0| := by
  rcases ha with h | h
  · exact unbounded_of_neg a h M
  · exact unbounded_of_gt_half a h M

/-! ### Conservation of total mass (the discrete heat content) -/

-- !-- Lab Notes -- !--
-- Experiment E3 (integral invariant): the continuous diffusion PDE conserves
-- total heat `∫ u`.  The discrete analogue should conserve `∑ c(x)`.  Because the
-- three weights sum to 1, summing `step a c` over all `x` and reindexing the two
-- shifted copies (`x ↦ x±1`, bijections of ℤ) recombines to `(a + (1-2a) + a)·∑ c
-- = ∑ c`.  Formalized with `finsum` over the finite support: `finsum_comp_equiv`
-- handles the shift-reindexing, `finsum_add_distrib` the additive split (needs
-- finite support of each summand), and `mul_finsum` the scalar factors.  This
-- holds for *every* `a` — conservation is independent of stability, exactly as for
-- the heat equation.

/-- One step preserves finiteness of the support. -/
theorem step_support_finite (a : ℝ) (c : ℤ → ℝ) (hc : (support c).Finite) :
    (support (step a c)).Finite := by
  have hcm1 : (support fun x => c (x - 1)).Finite :=
    hc.preimage ((Equiv.subRight (1 : ℤ)).injective.injOn)
  have hcp1 : (support fun x => c (x + 1)).Finite :=
    hc.preimage ((Equiv.addRight (1 : ℤ)).injective.injOn)
  apply ((hcm1.union hc).union hcp1).subset
  intro x hx
  simp only [step, mem_support, Set.mem_union] at hx ⊢
  by_contra h; push_neg at h
  obtain ⟨⟨h1, h2⟩, h3⟩ := h
  simp [h1, h2, h3] at hx

/-- All iterates preserve finiteness of the support. -/
theorem iter_support_finite (a : ℝ) (c : ℤ → ℝ) (hc : (support c).Finite) (n : ℕ) :
    (support (iter a n c)).Finite := by
  induction n with
  | zero => simpa [iter] using hc
  | succ k ih =>
      rw [iter, Function.iterate_succ', Function.comp_apply, ← iter]
      exact step_support_finite a _ ih

/-- **Total mass is conserved** by one step, for every diffusion coefficient `a`
(the discrete analogue of conservation of heat content). -/
theorem mass_conserved (a : ℝ) (c : ℤ → ℝ) (hc : (support c).Finite) :
    (∑ᶠ x, step a c x) = ∑ᶠ x, c x := by
  have hcm1 : (support fun x => c (x - 1)).Finite :=
    hc.preimage ((Equiv.subRight (1 : ℤ)).injective.injOn)
  have hcp1 : (support fun x => c (x + 1)).Finite :=
    hc.preimage ((Equiv.addRight (1 : ℤ)).injective.injOn)
  have fa : ∀ (b : ℝ) (g : ℤ → ℝ), (support g).Finite → (support fun x => b * g x).Finite :=
    fun b g hg => hg.subset (fun x hx => by
      simp only [mem_support] at hx ⊢
      exact fun h => hx (by rw [h, mul_zero]))
  have e1 : (∑ᶠ x, c (x - 1)) = ∑ᶠ x, c x := finsum_comp_equiv (Equiv.subRight (1 : ℤ))
  have e2 : (∑ᶠ x, c (x + 1)) = ∑ᶠ x, c x := finsum_comp_equiv (Equiv.addRight (1 : ℤ))
  have hAB : (support fun x => a * c (x - 1) + (1 - 2 * a) * c x).Finite :=
    ((fa a _ hcm1).union (fa (1 - 2 * a) _ hc)).subset (Function.support_add _ _)
  have split : (∑ᶠ x, step a c x)
      = (∑ᶠ x, a * c (x - 1)) + (∑ᶠ x, (1 - 2 * a) * c x) + (∑ᶠ x, a * c (x + 1)) := by
    simp only [step]
    rw [finsum_add_distrib hAB (fa a _ hcp1),
        finsum_add_distrib (fa a _ hcm1) (fa (1 - 2 * a) _ hc)]
  rw [split, ← mul_finsum, ← mul_finsum, ← mul_finsum, e1, e2]
  ring

/-- **Total mass is conserved by every iterate.** -/
theorem mass_iter_conserved (a : ℝ) (c : ℤ → ℝ) (hc : (support c).Finite) (n : ℕ) :
    (∑ᶠ x, iter a n c x) = ∑ᶠ x, c x := by
  induction n with
  | zero => simp [iter]
  | succ k ih =>
      rw [iter, Function.iterate_succ', Function.comp_apply, ← iter,
          mass_conserved a _ (iter_support_finite a c hc k), ih]

/-! ### The stability dichotomy -/

-- !-- Lab Notes -- !--
-- Synthesis S1: the boundary of the convex window, a = 1/2 (and a = 0), is the
-- exact linear-stability threshold.  Inside, the maximum principle forbids
-- growth (laminar Class-1/2 behaviour).  Outside, the highest mode is linearly
-- unstable.  Rucker's *gnarl* is therefore confined, on the laminar side, by
-- a = 1/2: any genuinely gnarly continuous CA must either operate exactly at the
-- threshold or break linearity (the nonlinear "Hodgepodge" rules).  This is a
-- precise, testable localisation of the edge of chaos for this family.

/-- **Stability dichotomy** for the symmetric three-point continuous CA.
Inside the convex window `0 ≤ a ≤ 1/2` the dynamics is a sup-norm contraction
(every bounded pattern stays bounded forever); outside it (`a < 0 ∨ 1/2 < a`)
the top eigenvalue has modulus `> 1`, so the checkerboard pattern grows without
bound. -/
theorem stability_dichotomy (a : ℝ) :
    (0 ≤ a ∧ a ≤ 1 / 2 →
      ∀ (c : ℤ → ℝ) (M : ℝ), (∀ x, |c x| ≤ M) → ∀ n x, |iter a n c x| ≤ M)
    ∧ ((a < 0 ∨ 1 / 2 < a) → 1 < |1 - 4 * a|) := by
  constructor
  · rintro ⟨ha0, ha1⟩ c M h n x
    exact abs_iter_le a ha0 ha1 c M h n x
  · rintro (h | h)
    · exact spectralRadius_gt_one_of_neg a h
    · exact spectralRadius_gt_one_of_gt_half a h

end ContinuousValuedCA