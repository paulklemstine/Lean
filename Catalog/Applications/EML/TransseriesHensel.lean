import Applications.EML.TransseriesNoAntiderivative
import Applications.EML.TransseriesOrderRigidity
import Applications.EML.PowerSeriesHensel

/-!
# Hensel's lemma in the transseries field: roots beyond radicals

`Applications/EML/TransseriesRoots.lean` produced roots of the equations `z ^ n = f`
(radicals).  This file produces roots of equations that are **not** solvable by radicals
over an ordered field, and thereby pushes the real-closedness programme past the
"root half".

The mechanism is Hensel's lemma for the parameter ring `ℝ⟦X⟧`
(`Applications/EML/PowerSeriesHensel.lean`) combined with the substitution of an
*infinitesimal transseries* for the parameter:

* `EMLTS.IsSmall t` says `t` is an infinitesimal: `|t| < r` for every positive real `r`.
  Infinitesimals abound (`EMLTS.isSmall_T`, e.g. `1/x`, `1/log x`, `exp (-x)`).
* `EMLTS.exists_root_of_residue_simple_root`: a monic polynomial over `ℝ⟦X⟧` whose
  specialisation at `X = 0` has a simple real root can be solved in the transseries field
  after substituting any infinitesimal for `X`.
* `EMLTS.exists_root_cubic_casus_irreducibilis`: for every infinitesimal `t` the cubic
  `z ^ 3 - 3 z + t` has a root in the transseries field, **although its Cardano
  discriminant is strictly negative** (`EMLTS.casus_irreducibilis_disc_neg`).  This is the
  classical *casus irreducibilis*: such a root cannot be produced from `t` by real
  radicals, so it lies outside the reach of the `n`-th-root theorems of
  `TransseriesRoots.lean`.
* By contrast `EMLTS.exists_root_depressed_cubic` and `EMLTS.exists_root_cubic` solve
  *every* cubic with nonnegative Cardano discriminant by Cardano's formula, using only
  square and cube roots, which the transseries field has.

Together the two families cover every cubic whose discriminant does not vanish
infinitesimally close to the boundary, and they delimit precisely where the remaining
difficulty in proving real closedness of the transseries field sits.
-/

noncomputable section

open HahnSeries PowerSeries Polynomial PowerSeriesHensel

namespace EMLTS

/-! ## Infinitesimals -/

/-- A transseries is *infinitesimal* when it is smaller in absolute value than every
positive real constant. -/
def IsSmall (t : TS) : Prop := ∀ r : ℝ, 0 < r → |t| < C r

theorem order_ofLex_abs (t : TS) : (ofLex |t|).order = (ofLex t).order := by
  rcases abs_cases t with ⟨h, -⟩ | ⟨h, -⟩ <;> rw [h]
  exact HahnSeries.order_neg

/-- An infinitesimal has positive `orderTop`, which is what makes the substitution of `t`
into a formal power series meaningful. -/
theorem IsSmall.orderTop_pos {t : TS} (h : IsSmall t) : 0 < (ofLex t).orderTop := by
  by_cases ht : t = 0
  · subst ht
    simp only [ofLex_zero, HahnSeries.orderTop_zero]
    exact WithTop.coe_lt_top (0 : Rank)
  · have ht' : (ofLex t) ≠ 0 := by simpa using ht
    rw [← HahnSeries.order_eq_orderTop_of_ne_zero ht']
    rw [show ((0 : WithTop Rank)) = ((0 : Rank) : WithTop Rank) from rfl, WithTop.coe_lt_coe]
    by_contra hle
    push_neg at hle
    have hu0 : 0 < |t| := abs_pos.mpr ht
    have hc : 0 < (ofLex |t|).leadingCoeff := leadingCoeff_pos_iff.mpr hu0
    set c : ℝ := (ofLex |t|).leadingCoeff with hcdef
    set g₀ : Rank := (ofLex |t|).order with hg₀def
    have hg₀ : g₀ ≤ 0 := by rw [hg₀def, order_ofLex_abs]; exact hle
    have hlt : C (c / 2) < |t| := by
      refine (HahnSeries.lt_iff _ _).mpr ⟨g₀, fun j hj => ?_, ?_⟩
      · have hj0 : j ≠ 0 := ne_of_lt (lt_of_lt_of_le hj hg₀)
        rw [C, ofLex_toLex, coeff_single_of_ne hj0,
          HahnSeries.coeff_eq_zero_of_lt_order hj]
      · have hcoeff : (ofLex |t|).coeff g₀ = c := (HahnSeries.leadingCoeff_eq).symm
        rw [C, ofLex_toLex, hcoeff]
        by_cases hg : g₀ = 0
        · rw [hg, HahnSeries.coeff_single_same]
          linarith
        · rw [coeff_single_of_ne hg]
          linarith
    exact absurd (h (c / 2) (by linarith)) (asymm hlt)

/-- Every transmonomial of positive rank — that is, every transmonomial below all real
constants — is an infinitesimal. -/
theorem isSmall_T {d a b c : ℝ} (h : (0 : Rank) < rk (-d) (-a) (-b) (-c)) :
    IsSmall (T d a b c) := by
  intro r hr
  rw [abs_of_pos (T_pos d a b c)]
  exact single_lt_single_of_lt hr h

/-- `1 / x` is an infinitesimal. -/
theorem isSmall_inv_Lx : IsSmall (Lx⁻¹) := by
  rw [Lx, T_inv]
  refine isSmall_T ?_
  rw [show (0 : Rank) = rk 0 0 0 0 from rfl, rk_lt_rk_iff]
  norm_num

/-- `1 / log x` is an infinitesimal. -/
theorem isSmall_inv_Llog : IsSmall (Llog⁻¹) := by
  rw [Llog, T_inv]
  refine isSmall_T ?_
  rw [show (0 : Rank) = rk 0 0 0 0 from rfl, rk_lt_rk_iff]
  norm_num

/-- `exp (-x)` is an infinitesimal. -/
theorem isSmall_inv_Lexp : IsSmall (Lexp⁻¹) := by
  rw [Lexp, T_inv]
  refine isSmall_T ?_
  rw [show (0 : Rank) = rk 0 0 0 0 from rfl, rk_lt_rk_iff]
  norm_num

/-! ## Hensel's lemma in the transseries field -/

/-- Substituting an infinitesimal for the power series variable returns the
infinitesimal. -/
theorem tsEval_X_self {t : TS} (ht : IsSmall t) :
    tsEval (ofLex t) (PowerSeries.X) = t :=
  PowerSeriesHensel.tsEval_X ht.orderTop_pos

/-- **Hensel's lemma for the transseries field.**  Let `F` be a monic polynomial whose
coefficients are formal power series in a parameter, and suppose that specialising the
parameter to `0` gives a real polynomial with a *simple* real root `a`.  Then, after
substituting any infinitesimal transseries `t` for the parameter, `F` has a root in the
transseries field, and that root has real part `a`. -/
theorem exists_root_of_residue_simple_root (t : TS) (F : Polynomial ℝ⟦X⟧)
    (hF : F.Monic) (a : ℝ)
    (h0 : (F.map (PowerSeries.constantCoeff (R := ℝ))).eval a = 0)
    (h1 : (F.map (PowerSeries.constantCoeff (R := ℝ))).derivative.eval a ≠ 0) :
    ∃ z : TS, (F.map (tsEval (ofLex t))).eval z = 0 ∧ (ofLex z).coeff 0 = a := by
  obtain ⟨y, hy, hya⟩ :=
    PowerSeriesHensel.exists_root_of_residue_simple_root F hF a h0 h1
  refine ⟨tsEval (ofLex t) y, eval_map_tsEval_eq_zero _ hy, ?_⟩
  rw [coeff_zero_tsEval, hya]

/-! ## Cubics solvable by radicals: Cardano's formula -/

theorem odd_three : Odd 3 := ⟨1, rfl⟩

/-- **Cardano's formula in the transseries field.**  A depressed cubic whose Cardano
discriminant `(q/2)² + (p/3)³` is nonnegative has a root, obtained from a square root and
a cube root — both of which the transseries field provides. -/
theorem exists_root_depressed_cubic {p q : TS} (h : 0 ≤ (q / 2) ^ 2 + (p / 3) ^ 3) :
    ∃ z : TS, z ^ 3 + p * z + q = 0 := by
  obtain ⟨s, hs⟩ := exists_sq_of_nonneg h
  by_cases hu : -q / 2 + s = 0
  · have hp3 : (p / 3) ^ 3 = 0 := by
      have hsq : s = q / 2 := by linarith [sub_eq_zero.mp (by linarith : s - q / 2 = 0)]
      rw [hsq] at hs
      linarith [hs]
    have hp : p = 0 := by
      have := pow_eq_zero_iff (n := 3) (by norm_num) |>.mp hp3
      linarith [this]
    obtain ⟨w, hw⟩ := exists_pow_eq_of_odd odd_three (-q)
    exact ⟨w, by rw [hp, hw]; ring⟩
  · obtain ⟨u, hu3⟩ := exists_pow_eq_of_odd odd_three (-q / 2 + s)
    have hune : u ≠ 0 := by
      intro h0
      apply hu
      rw [← hu3, h0]
      ring
    set v : TS := -p / (3 * u) with hvdef
    have h3u : (3 : TS) * u ≠ 0 := mul_ne_zero (by norm_num) hune
    have hvu : u * v = -p / 3 := by
      rw [hvdef]
      field_simp
    have hp' : p = -3 * (u * v) := by rw [hvu]; ring
    have hu3' : u ^ 3 = s - q / 2 := by rw [hu3]; ring
    have hv3 : v ^ 3 = -(s + q / 2) := by
      have hcube : (u * v) ^ 3 = -((s + q / 2) * u ^ 3) := by
        rw [hvu, hu3']
        linear_combination hs
      have hcube' : v ^ 3 * u ^ 3 = -(s + q / 2) * u ^ 3 := by
        rw [show v ^ 3 * u ^ 3 = (u * v) ^ 3 by ring, hcube]; ring
      have hu3ne : u ^ 3 ≠ 0 := pow_ne_zero _ hune
      exact mul_right_cancel₀ hu3ne hcube'
    refine ⟨u + v, ?_⟩
    calc (u + v) ^ 3 + p * (u + v) + q = u ^ 3 + v ^ 3 + q := by rw [hp']; ring
      _ = (s - q / 2) + -(s + q / 2) + q := by rw [hu3', hv3]
      _ = 0 := by ring

/-- **Every cubic with nonnegative Cardano discriminant has a root**, in Weierstrass
normal form: `p` and `q` are the coefficients of the depressed cubic associated with
`a z³ + b z² + c z + d`. -/
theorem exists_root_cubic {a b c d p q : TS} (ha : a ≠ 0)
    (hp : p = (3 * a * c - b ^ 2) / (3 * a ^ 2))
    (hq : q = (2 * b ^ 3 - 9 * a * b * c + 27 * a ^ 2 * d) / (27 * a ^ 3))
    (h : 0 ≤ (q / 2) ^ 2 + (p / 3) ^ 3) :
    ∃ z : TS, a * z ^ 3 + b * z ^ 2 + c * z + d = 0 := by
  obtain ⟨w, hw⟩ := exists_root_depressed_cubic h
  refine ⟨w - b / (3 * a), ?_⟩
  have ha3 : (3 : TS) * a ≠ 0 := mul_ne_zero (by norm_num) ha
  have key : a * (w - b / (3 * a)) ^ 3 + b * (w - b / (3 * a)) ^ 2 + c * (w - b / (3 * a)) + d
      = a * (w ^ 3 + p * w + q) := by
    subst hp
    subst hq
    field_simp
    ring
  rw [key, hw, mul_zero]

/-! ## Cubics *not* solvable by radicals: the casus irreducibilis -/

/-- The parametrised cubic `Y ³ - 3 Y + X` over the parameter ring `ℝ⟦X⟧`. -/
def cubicFamily : Polynomial ℝ⟦X⟧ :=
  Polynomial.X ^ 3 - 3 * Polynomial.X + Polynomial.C (PowerSeries.X)

theorem cubicFamily_monic : cubicFamily.Monic := by
  unfold cubicFamily
  monicity!

theorem cubicFamily_residue :
    cubicFamily.map (PowerSeries.constantCoeff (R := ℝ))
      = Polynomial.X ^ 3 - 3 * Polynomial.X := by
  simp [cubicFamily]

theorem cubicFamily_map_tsEval {t : TS} (ht : IsSmall t) :
    cubicFamily.map (tsEval (ofLex t))
      = Polynomial.X ^ 3 - 3 * Polynomial.X + Polynomial.C t := by
  simp [cubicFamily, tsEval_X_self ht]

/-- **The casus irreducibilis is solvable in the transseries field.**  For every
infinitesimal transseries `t` the cubic `z³ - 3z + t` has a root, even though (see
`EMLTS.casus_irreducibilis_disc_neg`) its Cardano discriminant is strictly negative, so
that no expression in real radicals of `t` can produce the root.  The root is obtained by
Henselian lifting of the simple real root `0` of `y³ - 3y`. -/
theorem exists_root_cubic_with_residue {t : TS} (ht : IsSmall t) (a : ℝ)
    (h0 : a ^ 3 - 3 * a = 0) (h1 : 3 * a ^ 2 - 3 ≠ 0) :
    ∃ z : TS, z ^ 3 - 3 * z + t = 0 ∧ (ofLex z).coeff 0 = a := by
  obtain ⟨z, hz, hres⟩ :=
    exists_root_of_residue_simple_root t cubicFamily cubicFamily_monic a
      (by rw [cubicFamily_residue]; simpa using h0)
      (by
        rw [cubicFamily_residue]
        have hd : Polynomial.derivative (Polynomial.X ^ 3 - 3 * Polynomial.X : ℝ[X])
            = 3 * Polynomial.X ^ 2 - 3 := by
          simp only [Polynomial.derivative_sub, Polynomial.derivative_pow,
            Polynomial.derivative_X, Polynomial.derivative_mul, Polynomial.derivative_ofNat]
          norm_num
          exact Polynomial.C_ofNat 3
        rw [hd]
        simp only [Polynomial.eval_sub, Polynomial.eval_mul, Polynomial.eval_pow,
          Polynomial.eval_X, Polynomial.eval_ofNat]
        exact h1)
  refine ⟨z, ?_, hres⟩
  rw [cubicFamily_map_tsEval ht] at hz
  simpa using hz

theorem exists_root_cubic_casus_irreducibilis {t : TS} (ht : IsSmall t) :
    ∃ z : TS, z ^ 3 - 3 * z + t = 0 := by
  obtain ⟨z, hz, -⟩ := exists_root_cubic_with_residue ht 0 (by ring) (by norm_num)
  exact ⟨z, hz⟩

/-- **Three distinct roots.**  For infinitesimal `t` the casus-irreducibilis cubic
`z³ - 3z + t` has three pairwise distinct roots in the transseries field, deforming the
three real roots `0, ±√3` of `y³ - 3y`. -/
theorem exists_three_roots_cubic_casus_irreducibilis {t : TS} (ht : IsSmall t) :
    ∃ z₁ z₂ z₃ : TS, z₁ ^ 3 - 3 * z₁ + t = 0 ∧ z₂ ^ 3 - 3 * z₂ + t = 0 ∧
      z₃ ^ 3 - 3 * z₃ + t = 0 ∧ z₁ ≠ z₂ ∧ z₁ ≠ z₃ ∧ z₂ ≠ z₃ := by
  have hs : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hspos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  obtain ⟨z₁, hz₁, hr₁⟩ := exists_root_cubic_with_residue ht 0 (by ring) (by norm_num)
  obtain ⟨z₂, hz₂, hr₂⟩ := exists_root_cubic_with_residue ht (Real.sqrt 3)
    (by nlinarith [hs]) (by nlinarith [hs])
  obtain ⟨z₃, hz₃, hr₃⟩ := exists_root_cubic_with_residue ht (-Real.sqrt 3)
    (by nlinarith [hs]) (by nlinarith [hs])
  refine ⟨z₁, z₂, z₃, hz₁, hz₂, hz₃, ?_, ?_, ?_⟩
  · intro hcon
    rw [hcon, hr₂] at hr₁
    exact hspos.ne' hr₁
  · intro hcon
    rw [hcon, hr₃] at hr₁
    exact hspos.ne' (by linarith)
  · intro hcon
    rw [hcon, hr₃] at hr₂
    exact hspos.ne' (by linarith)

/-- The Cardano discriminant of `z³ - 3z + t` is strictly negative for infinitesimal `t`:
the cubic of `EMLTS.exists_root_cubic_casus_irreducibilis` is genuinely in the casus
irreducibilis, so `EMLTS.exists_root_depressed_cubic` does not apply to it. -/
theorem casus_irreducibilis_disc_neg {t : TS} (ht : IsSmall t) :
    (t / 2) ^ 2 + ((-3 : TS) / 3) ^ 3 < 0 := by
  have h2 : |t| < C 2 := ht 2 (by norm_num)
  have hC2 : C (2 : ℝ) = (2 : TS) := by
    have := natCast_eq_C 2
    push_cast at this
    exact this.symm
  rw [hC2] at h2
  have habs := abs_lt.mp h2
  nlinarith [habs.1, habs.2]


/-! ## Infinitesimal deformations of an arbitrary real polynomial -/

/-- The real constants, as a ring homomorphism into the transseries field. -/
def Chom : ℝ →+* TS where
  toFun := C
  map_one' := C_one
  map_mul' := C_mul
  map_zero' := C_zero
  map_add' := C_add

@[simp] theorem Chom_apply (r : ℝ) : Chom r = C r := rfl

theorem tsEval_comp_C (t : TS) :
    (tsEval (ofLex t)).comp (PowerSeries.C (R := ℝ)) = Chom := by
  refine RingHom.ext fun r => ?_
  show tsEval (ofLex t) (PowerSeries.C r) = C r
  rw [tsEval_C]
  rfl

/-- **Hensel's lemma, deformation form.**  Let `f` be a monic real polynomial with a simple
real root `a`, and let `g` be a real polynomial of smaller degree.  Then for every
infinitesimal transseries `t` the deformed polynomial `f + t g` has a root in the
transseries field.  For `f = Y³ - 3Y`, `g = 1` this produces roots of cubics lying in the
casus irreducibilis, which are provably not obtainable from `t` by radicals. -/
theorem exists_root_perturbed_real_polynomial (f g : Polynomial ℝ) (hf : f.Monic)
    (hdeg : g.degree < f.degree) (a : ℝ) (h0 : f.eval a = 0) (h1 : f.derivative.eval a ≠ 0)
    {t : TS} (ht : IsSmall t) :
    ∃ z : TS, (f.map Chom).eval z + t * (g.map Chom).eval z = 0 := by
  set F : Polynomial ℝ⟦X⟧ :=
    f.map (PowerSeries.C (R := ℝ)) +
      Polynomial.C (PowerSeries.X : ℝ⟦X⟧) * g.map (PowerSeries.C (R := ℝ)) with hF
  have hCinj : Function.Injective (PowerSeries.C (R := ℝ)) := PowerSeries.C_injective
  have hFmonic : F.Monic := by
    refine (hf.map (PowerSeries.C (R := ℝ))).add_of_left ?_
    refine lt_of_le_of_lt (Polynomial.degree_mul_le _ _) ?_
    have hdeg' : (g.map (PowerSeries.C (R := ℝ))).degree < (f.map (PowerSeries.C (R := ℝ))).degree := by
      rwa [Polynomial.degree_map_eq_of_injective hCinj,
        Polynomial.degree_map_eq_of_injective hCinj]
    calc (Polynomial.C (PowerSeries.X : ℝ⟦X⟧)).degree + (g.map (PowerSeries.C (R := ℝ))).degree
        ≤ 0 + (g.map (PowerSeries.C (R := ℝ))).degree := by
          gcongr
          exact Polynomial.degree_C_le
      _ = (g.map (PowerSeries.C (R := ℝ))).degree := by rw [zero_add]
      _ < (f.map (PowerSeries.C (R := ℝ))).degree := hdeg'
  have hres : F.map (PowerSeries.constantCoeff (R := ℝ)) = f := by
    rw [hF]
    simp [Polynomial.map_map, Polynomial.map_mul]
  have himg : F.map (tsEval (ofLex t)) = f.map Chom + Polynomial.C t * g.map Chom := by
    rw [hF]
    simp only [Polynomial.map_add, Polynomial.map_mul, Polynomial.map_map, Polynomial.map_C,
      tsEval_comp_C, tsEval_X_self ht]
  obtain ⟨z, hz, -⟩ :=
    exists_root_of_residue_simple_root t F hFmonic a (by rw [hres]; exact h0)
      (by rw [hres]; exact h1)
  refine ⟨z, ?_⟩
  rw [himg] at hz
  simpa using hz

/-! ## A concrete casus-irreducibilis root -/

/-- A concrete cubic in the casus irreducibilis with an explicit infinitesimal
coefficient: `z³ - 3z + 1/x` has a transseries root. -/
theorem exists_root_cubic_inv_Lx : ∃ z : TS, z ^ 3 - 3 * z + Lx⁻¹ = 0 :=
  exists_root_cubic_casus_irreducibilis isSmall_inv_Lx

end EMLTS