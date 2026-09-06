import Algebra.SmoothWindows.ScaleSpace

/-!
# Metaplectic extension of the Gabor window action I: the chirp generator

`Algebra.SmoothWindows.GaborOperators` builds the two generators of the Gabor window action —
translation `T_a` and modulation `M_b` — and the Heisenberg group `Heis` they generate through
the Weyl cocycle `χ(b a')`.  This file adds the **third** generator, the chirp

  `(C_c f)(t) = e^{2πi c t²} f(t)`,

and shows that the Weyl cocycle extends: the chirp normalises `Heis`, so `Heis` sits as a normal
subgroup of a semidirect product `Heis ⋊ ℝ` on which the window action is still a genuine group
representation.  The parameter `c` is the shear (unipotent) direction of `SL₂(ℝ)`; the geometry
is developed in `Geometry.MetaplecticChirpedGaussian`.

## Main results

* `chirpOp_transOp` — **the chirp/translation relation** `C_c T_a = χ(-ca²) M_{2ac} T_a C_c`:
  conjugating a translation by a chirp creates a modulation.  This is the phase-space shear
  `(a,b) ↦ (a, b + 2ca)`.
* `chirpShear_mul` — **the Weyl cocycle extends**: `(a,b,z) ↦ (a, b+2ca, z·χ(ca²))` is a group
  automorphism of `Heis`, i.e. the cocycle identity survives the shear after the correction
  `χ(ca²)`, which is forced by `c(a+a')² = ca² + 2caa' + ca'²`.
* `chirpAutHom` — the resulting one-parameter group `ℝ →* MulAut Heis`, and `MetaHeis`, the
  semidirect product `Heis ⋊[chirp] ℝ`.
* `heis_normal_in_metaHeis` — **`Heis` is normal** in the extension.
* `gaborAct_chirpShear` — the chirp operator *implements* the automorphism on windows:
  `C_c ∘ ρ(g) = ρ(σ_c g) ∘ C_c`.
* `metaRep` — the representation of `Heis ⋊ ℝ` by permutations of window space, and
  `metaRep_injective` — it is **faithful**: a Gabor shift composed with a chirp acts trivially
  only if both are trivial.  The chirp is therefore a genuinely new generator.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).** The Heisenberg group of the catalog should not be the full
  symmetry of the window: the quadratic phases (chirps) should act on it by outer automorphisms,
  producing a semidirect product with the shear subgroup of `SL₂(ℝ)`.
* **Experiment (Experimenter).** Every operator identity reduced, after `chi_add`, to a
  polynomial identity in `t, a, b, c`; the group law needed the extra phase `χ(ca²)` — without it
  `chirpShear` is not multiplicative.  Faithfulness required a new rigidity input: a quadratic
  character `χ(bt + ct²)` that is identically `1` forces `b = c = 0`, proved by bounding
  `|bt + ct²| < 1` on a small interval and using integrality.
* **Analysis (Analyst).** The correction phase `χ(ca²)` is exactly the coboundary needed to keep
  the Weyl cocycle in its class, which is why the shear lifts to an honest automorphism (and,
  later, to an honest operator action) while the Fourier rotation does not (see
  `Geometry.MetaplecticAnomaly`).
* **Critique (Critic).** Nothing here is definitional: `chirpShear_not_inner`
  (in `Geometry.MetaplecticAnomaly`) shows the automorphism is outer, and `metaRep_injective`
  shows the extension is not a quotient of `Heis`.
-/

namespace SmoothWindows

open Complex Real MeasureTheory FourierTransform

/-! ## The chirp operator -/

/-- The **chirp operator** `(C_c f)(t) = e^{2πi c t²} f(t)`. -/
noncomputable def chirpOp (c : ℝ) (f : ℝ → ℂ) : ℝ → ℂ := fun t => chi (c * t ^ 2) * f t

@[simp] theorem chirpOp_zero (f : ℝ → ℂ) : chirpOp 0 f = f := by
  funext t; simp [chirpOp]

theorem chirpOp_chirpOp (c c' : ℝ) (f : ℝ → ℂ) :
    chirpOp c (chirpOp c' f) = chirpOp (c + c') f := by
  funext t
  simp only [chirpOp, ← mul_assoc, ← chi_add]
  ring_nf

theorem chirpOp_add (c : ℝ) (f g : ℝ → ℂ) :
    chirpOp c (f + g) = chirpOp c f + chirpOp c g := by
  funext t; simp [chirpOp, mul_add]

/-- The chirp operator commutes with modulation: both are multiplication operators. -/
theorem chirpOp_modOp (c b : ℝ) (f : ℝ → ℂ) :
    chirpOp c (modOp b f) = modOp b (chirpOp c f) := by
  funext t; simp only [chirpOp, modOp]; ring

/-- **The chirp/translation relation.**  Conjugating a translation by a chirp produces a
translation *and* a modulation: `C_c T_a = χ(-ca²) M_{2ac} T_a C_c`.  This is the shear
`(a,b) ↦ (a, b + 2ca)` of phase space. -/
theorem chirpOp_transOp (c a : ℝ) (f : ℝ → ℂ) :
    chirpOp c (transOp a f) =
      fun t => chi (-(c * a ^ 2)) * modOp (2 * a * c) (transOp a (chirpOp c f)) t := by
  funext t
  simp only [chirpOp, modOp, transOp, ← mul_assoc, ← chi_add]
  ring_nf

/-! ## The chirp automorphism of the Heisenberg group -/

/-- The **chirp shear** of the Heisenberg group: `(a,b,z) ↦ (a, b + 2ca, z·χ(ca²))`. -/
noncomputable def chirpShear (c : ℝ) (g : Heis) : Heis :=
  ⟨g.a, g.b + 2 * c * g.a, g.z * Circle.exp (2 * π * (c * g.a ^ 2))⟩

@[simp] theorem chirpShear_a (c : ℝ) (g : Heis) : (chirpShear c g).a = g.a := rfl
@[simp] theorem chirpShear_b (c : ℝ) (g : Heis) : (chirpShear c g).b = g.b + 2 * c * g.a := rfl
@[simp] theorem chirpShear_z (c : ℝ) (g : Heis) :
    (chirpShear c g).z = g.z * Circle.exp (2 * π * (c * g.a ^ 2)) := rfl

theorem chirpShear_zero (g : Heis) : chirpShear 0 g = g := by
  refine Heis.ext rfl (by simp) ?_
  simp

theorem chirpShear_chirpShear (c c' : ℝ) (g : Heis) :
    chirpShear c (chirpShear c' g) = chirpShear (c + c') g := by
  refine Heis.ext rfl (by simp; ring) ?_
  simp only [chirpShear_z, chirpShear_a, mul_assoc]
  rw [← Circle.exp_add]
  congr 2
  ring

/-- **The chirp shear is a group automorphism of `Heis`** — this is the verification that the
Weyl cocycle `χ(b a')` extends to the semidirect product. -/
theorem chirpShear_mul (c : ℝ) (g h : Heis) :
    chirpShear c (g * h) = chirpShear c g * chirpShear c h := by
  refine Heis.ext rfl (by simp; ring) ?_
  simp only [chirpShear_z, chirpShear_a, chirpShear_b, Heis.mul_z, Heis.mul_a]
  have e1 : Circle.exp (2 * π * (c * (g.a + h.a) ^ 2))
      = Circle.exp (2 * π * (c * g.a ^ 2)) * Circle.exp (2 * π * (c * h.a ^ 2))
        * Circle.exp (2 * π * (2 * c * g.a * h.a)) := by
    rw [← Circle.exp_add, ← Circle.exp_add]; ring_nf
  have e2 : Circle.exp (2 * π * ((g.b + 2 * c * g.a) * h.a))
      = Circle.exp (2 * π * (g.b * h.a)) * Circle.exp (2 * π * (2 * c * g.a * h.a)) := by
    rw [← Circle.exp_add]; ring_nf
  rw [e1, e2]
  simp [mul_comm, mul_left_comm, mul_assoc]

/-- The chirp shear packaged as an automorphism of the Heisenberg group. -/
@[simps! apply]
noncomputable def chirpAut (c : ℝ) : MulAut Heis where
  toFun := chirpShear c
  invFun := chirpShear (-c)
  left_inv g := by rw [chirpShear_chirpShear]; simpa using chirpShear_zero g
  right_inv g := by rw [chirpShear_chirpShear]; simpa using chirpShear_zero g
  map_mul' := chirpShear_mul c

/-- The one-parameter group of chirp automorphisms, `ℝ →* MulAut Heis`. -/
noncomputable def chirpAutHom : Multiplicative ℝ →* MulAut Heis where
  toFun c := chirpAut (Multiplicative.toAdd c)
  map_one' := by ext g <;> simp [chirpAut, chirpShear_zero]
  map_mul' c c' := by
    ext g <;>
      simp [chirpAut, ← chirpShear_chirpShear, add_comm]

/-! ## The metaplectic intertwining relation and the semidirect product -/

/-- **The chirp operator implements the chirp automorphism.**  Conjugating a Gabor shift by the
chirp operator is the Gabor shift of the sheared Heisenberg element:
`C_c ∘ ρ(g) = ρ(σ_c g) ∘ C_c`. -/
theorem gaborAct_chirpShear (c : ℝ) (g : Heis) (f : ℝ → ℂ) :
    gaborAct (chirpShear c g) (chirpOp c f) = chirpOp c (gaborAct g f) := by
  funext t
  simp only [gaborAct_apply, chirpOp, chirpShear_a, chirpShear_b, chirpShear_z, Circle.coe_mul,
    coe_circleExp]
  have key : chi (c * g.a ^ 2) * chi ((g.b + 2 * c * g.a) * (t - g.a)) * chi (c * (t - g.a) ^ 2)
      = chi (c * t ^ 2) * chi (g.b * (t - g.a)) := by
    rw [← chi_add, ← chi_add, ← chi_add]
    congr 1
    ring
  linear_combination ((g.z : ℂ) * f (t - g.a)) * key

/-- The Gabor action as a permutation of the space of windows. -/
noncomputable def gaborPerm (g : Heis) : Equiv.Perm (ℝ → ℂ) where
  toFun := gaborAct g
  invFun := gaborAct g⁻¹
  left_inv f := gaborAct_leftInverse g f
  right_inv f := by simpa using gaborAct_leftInverse g⁻¹ f

@[simp] theorem gaborPerm_apply (g : Heis) (f : ℝ → ℂ) : gaborPerm g f = gaborAct g f := rfl

@[simp] theorem gaborPerm_symm_apply (g : Heis) (f : ℝ → ℂ) :
    (gaborPerm g).symm f = gaborAct g⁻¹ f := rfl

/-- The Schrödinger representation valued in the *group* of permutations of window space. -/
noncomputable def gaborPermHom : Heis →* Equiv.Perm (ℝ → ℂ) where
  toFun := gaborPerm
  map_one' := by ext f; simp
  map_mul' g h := by ext f; simp [gaborAct_mul]

/-- The chirp operator as a permutation of the space of windows. -/
noncomputable def chirpPerm (c : ℝ) : Equiv.Perm (ℝ → ℂ) where
  toFun := chirpOp c
  invFun := chirpOp (-c)
  left_inv f := by rw [chirpOp_chirpOp]; simp
  right_inv f := by rw [chirpOp_chirpOp]; simp

@[simp] theorem chirpPerm_apply (c : ℝ) (f : ℝ → ℂ) : chirpPerm c f = chirpOp c f := rfl

@[simp] theorem chirpPerm_symm_apply (c : ℝ) (f : ℝ → ℂ) :
    (chirpPerm c).symm f = chirpOp (-c) f := rfl

/-- The chirp one-parameter group of window permutations. -/
noncomputable def chirpPermHom : Multiplicative ℝ →* Equiv.Perm (ℝ → ℂ) where
  toFun c := chirpPerm (Multiplicative.toAdd c)
  map_one' := by ext f; simp
  map_mul' c c' := by
    ext f
    simp only [Equiv.Perm.mul_apply, chirpPerm_apply, chirpOp_chirpOp, toAdd_mul]

/-- **The metaplectic shear extension** `Heis ⋊ ℝ`: the Heisenberg group extended by the
one-parameter group of chirps, i.e. by the unipotent (shear) subgroup of `SL₂(ℝ)`. -/
abbrev MetaHeis := Heis ⋊[chirpAutHom] Multiplicative ℝ

/-- **`Heis` is normal in the metaplectic shear extension.** -/
theorem heis_normal_in_metaHeis :
    (SemidirectProduct.inl : Heis →* MetaHeis).range.Normal := by
  rw [SemidirectProduct.range_inl_eq_ker_rightHom]
  infer_instance

/-- The compatibility condition making the pair (Gabor action, chirp action) a representation of
the semidirect product: conjugation by the chirp operator realises the chirp automorphism. -/
theorem gaborPermHom_comp_chirpAut (c : Multiplicative ℝ) :
    gaborPermHom.comp (chirpAutHom c).toMonoidHom
      = ((MulAut.conj (chirpPermHom c)).toMonoidHom).comp gaborPermHom := by
  refine MonoidHom.ext fun g => Equiv.ext fun f => ?_
  have h := gaborAct_chirpShear (Multiplicative.toAdd c) g (chirpOp (-Multiplicative.toAdd c) f)
  rw [chirpOp_chirpOp, add_neg_cancel, chirpOp_zero] at h
  simpa [chirpAutHom, chirpAut, chirpPermHom, chirpPerm, gaborPermHom, gaborPerm, MulAut.conj]
    using h

/-- **The metaplectic (shear) representation**: a genuine group homomorphism from the semidirect
product `Heis ⋊ ℝ` to the permutations of window space, restricting to the Schrödinger
representation on `Heis` and to chirp multiplication on `ℝ`. -/
noncomputable def metaRep : MetaHeis →* Equiv.Perm (ℝ → ℂ) :=
  SemidirectProduct.lift gaborPermHom chirpPermHom gaborPermHom_comp_chirpAut

@[simp] theorem metaRep_inl (g : Heis) (f : ℝ → ℂ) :
    metaRep (SemidirectProduct.inl g) f = gaborAct g f := by
  simp [metaRep, gaborPermHom]

@[simp] theorem metaRep_inr (c : ℝ) (f : ℝ → ℂ) :
    metaRep (SemidirectProduct.inr (Multiplicative.ofAdd c)) f = chirpOp c f := by
  simp [metaRep, chirpPermHom]

theorem metaRep_apply (x : MetaHeis) (f : ℝ → ℂ) :
    metaRep x f = gaborAct x.left (chirpOp (Multiplicative.toAdd x.right) f) := by
  simp [metaRep, SemidirectProduct.lift, gaborPermHom, chirpPermHom]

/-! ## Faithfulness of the metaplectic extension -/

/-- A quadratic phase that is identically trivial has vanishing coefficients. -/
theorem coeff_eq_zero_of_chi_quadratic {b c : ℝ} (h : ∀ t : ℝ, chi (b * t + c * t ^ 2) = 1) :
    b = 0 ∧ c = 0 := by
  set M : ℝ := 1 + |b| + |c| with hMdef
  have hM1 : 1 ≤ M := by
    have hb := abs_nonneg b
    have hc := abs_nonneg c
    simp only [hMdef]; linarith
  have hM0 : 0 < M := lt_of_lt_of_le one_pos hM1
  set T : ℝ := 1 / (2 * M) with hTdef
  have hT0 : 0 < T := by positivity
  have hT1 : T ≤ 1 / 2 := by
    rw [hTdef, div_le_div_iff₀ (by positivity) (by norm_num)]
    linarith
  have key : ∀ t : ℝ, |t| ≤ T → b * t + c * t ^ 2 = 0 := by
    intro t ht
    obtain ⟨n, hn⟩ := (chi_eq_one_iff _).1 (h t)
    have habs : |b * t + c * t ^ 2| < 1 := by
      have h1 : |b * t| = |b| * |t| := abs_mul _ _
      have h2 : |c * t ^ 2| = |c| * |t| ^ 2 := by rw [abs_mul, abs_pow]
      have h3 : |t| ^ 2 ≤ |t| := by nlinarith [abs_nonneg t, hT1]
      have h4 : |b * t + c * t ^ 2| ≤ |b * t| + |c * t ^ 2| := abs_add_le _ _
      have h5 : |b| * |t| ≤ |b| * T := mul_le_mul_of_nonneg_left ht (abs_nonneg b)
      have h6 : |c| * |t| ^ 2 ≤ |c| * T := mul_le_mul_of_nonneg_left (le_trans h3 ht) (abs_nonneg c)
      have h7 : (|b| + |c|) * T < 1 := by
        have hle : (|b| + |c|) * T ≤ M * T := by
          apply mul_le_mul_of_nonneg_right _ hT0.le
          simp only [hMdef]; linarith
        have hMT : M * T = 1 / 2 := by rw [hTdef]; field_simp
        linarith
      rw [h1, h2] at h4
      linarith
    have hn0 : n = 0 := by
      have hlt : |(n : ℝ)| < 1 := by rw [← hn]; exact habs
      have hcast : |n| < (1 : ℤ) := by exact_mod_cast (by simpa using hlt : ((|n| : ℤ) : ℝ) < 1)
      have := abs_lt.mp hcast
      omega
    rw [hn, hn0]
    simp
  have e1 := key T (by rw [abs_of_pos hT0])
  have e2 := key (T / 2) (by rw [abs_of_pos (by positivity)]; linarith)
  have hc : c = 0 := by
    have hT2 : T ^ 2 ≠ 0 := by positivity
    have hcT : c * T ^ 2 = 0 := by nlinarith [e1, e2]
    rcases mul_eq_zero.1 hcT with h | h
    · exact h
    · exact absurd h hT2
  refine ⟨?_, hc⟩
  rw [hc] at e1
  simp only [add_zero, zero_mul] at e1
  rcases mul_eq_zero.1 e1 with h | h
  · exact h
  · exact absurd h hT0.ne'

/-- **The metaplectic shear representation is faithful.**  If a Gabor shift composed with a chirp
acts trivially on all windows then both are trivial: the chirp direction is a genuinely new
generator, not absorbed by the Heisenberg group. -/
theorem metaRep_injective : Function.Injective metaRep := by
  rw [injective_iff_map_eq_one]
  intro x hx
  set g : Heis := x.left with hg
  set c : ℝ := Multiplicative.toAdd x.right with hc
  have hfun : ∀ f : ℝ → ℂ, gaborAct g (chirpOp c f) = f := by
    intro f
    have hxf : metaRep x f = f := by simp [hx]
    rw [metaRep_apply] at hxf
    exact hxf
  have hgauss := hfun (gaussC 1)
  -- Step 1: the translation parameter vanishes (a chirp has modulus one).
  have hnorm : ∀ t : ℝ, gaussWin 1 (t - g.a) = gaussWin 1 t := by
    intro t
    have h := congrFun hgauss t
    rw [gaborAct_apply] at h
    have h' := congrArg (‖·‖) h
    simpa [chirpOp, norm_chi, Complex.norm_mul, Circle.norm_coe, norm_gaussC] using h'
  have ha : g.a = 0 := by
    have h0 := hnorm 0
    rw [zero_sub, gaussWin_even, gaussWin_zero, gaussWin, Real.exp_eq_one_iff] at h0
    have hsq : g.a ^ 2 = 0 := by
      have hpi := Real.pi_pos
      have h1 : -π * g.a ^ 2 = 0 := by
        rw [div_eq_zero_iff] at h0
        rcases h0 with h | h
        · exact h
        · norm_num at h
      nlinarith
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hsq
  -- Step 2: the remaining phase is an identically trivial quadratic character.
  have hphase : ∀ t : ℝ, (g.z : ℂ) * chi (g.b * t + c * t ^ 2) = 1 := by
    intro t
    have h := congrFun hgauss t
    rw [gaborAct_apply, ha, sub_zero] at h
    have hne : gaussC 1 t ≠ 0 := gaussC_ne_zero 1 t
    have hstep : (g.z : ℂ) * chi (g.b * t + c * t ^ 2) * gaussC 1 t = 1 * gaussC 1 t :=
      calc (g.z : ℂ) * chi (g.b * t + c * t ^ 2) * gaussC 1 t
          = (g.z : ℂ) * chi (g.b * t) * (chi (c * t ^ 2) * gaussC 1 t) := by
            rw [chi_add]; ring
        _ = (g.z : ℂ) * chi (g.b * t) * chirpOp c (gaussC 1) t := rfl
        _ = gaussC 1 t := h
        _ = 1 * gaussC 1 t := (one_mul _).symm
    exact mul_right_cancel₀ hne hstep
  have hz : (g.z : ℂ) = 1 := by simpa using hphase 0
  have hquad : ∀ t : ℝ, chi (g.b * t + c * t ^ 2) = 1 := by
    intro t
    have hp := hphase t
    rw [hz, one_mul] at hp
    exact hp
  obtain ⟨hb, hc0⟩ := coeff_eq_zero_of_chi_quadratic hquad
  have hgone : x.left = 1 := Heis.ext ha hb (by ext; simpa using hz)
  have hrone : x.right = 1 := by
    have h0 : Multiplicative.toAdd x.right = 0 := hc0
    exact Multiplicative.toAdd.injective (by simpa using h0)
  exact SemidirectProduct.ext hgone hrone

end SmoothWindows