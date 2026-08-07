/-
  The sharp conjugate-point spacing, and the exact oscillation count.

  `SturmOscillation.exists_zero_of_long_interval` produces a conjugate point in every
  interval *strictly* longer than the Bonnet–Myers length `B = π √(m/ε)`, and
  `sturm_oscillation_count` therefore needs `T > n B` to produce `n` conjugate points.
  Both statements lose the boundary case, and with it the exact count: the model
  `sin(√(ε/m) t)` has its zeros spaced *exactly* `B` apart, so the honest statement should
  be that every interval of length `≥ B` already contains a conjugate point.

  This file proves that sharp form (the counting half of Conjecture C of
  `FUTURE_DIRECTIONS.md`) and deduces the exact floor count.

  * `nonpos_of_length_pi` — the Wronskian obstruction in its strongest form: if
    `y'' ≤ -(ε/m) y` on a closed interval of length exactly `B` and `y a ≥ 0`, then
    `y (a + B) ≤ 0`.  No positivity is assumed at the right endpoint, and the comparison
    interval is *closed*: this is what removes the strict inequality.
  * `exists_zero_Ioc_of_length_ge` — every interval `(a, c]` with `c - a ≥ B` contains a
    conjugate point of a Jacobi field with `k ≥ ε/m`.  The zero is produced in the
    half-open interval, which is exactly what makes consecutive zeros distinct.
  * `sturm_oscillation_count_sharp` / `sturm_zero_count_floor` — hence at least `n`
    distinct conjugate points as soon as `T ≥ n B`, i.e. at least `⌊T √(ε/m)/π⌋` of them.
  * `cos_model_positive_of_short_interval` — sharpness: on any interval of length `< B`
    the exact solution `cos(√(ε/m)(t - midpoint))` is everywhere positive, so no zero can
    be forced.  The threshold `B` in the previous three theorems is therefore optimal.
-/

import Physics.Spacetime.SturmOscillation

open Set

namespace Catalog.Physics.Spacetime

section SharpSturm

variable {m eps : ℝ} {y y' y'' k : ℝ → ℝ}

/-- The Bonnet–Myers length expressed through `b = √(ε/m)`: `π √(m/ε) = π / b`. -/
theorem myersLength_eq_pi_div (hm : 0 < m) (he : 0 < eps) :
    Real.pi * Real.sqrt (m / eps) = Real.pi / Real.sqrt (eps / m) := by
  have hbpos : 0 < Real.sqrt (eps / m) := Real.sqrt_pos.2 (div_pos he hm)
  have h1 : Real.sqrt (m / eps) * Real.sqrt (eps / m) = 1 := by
    rw [← Real.sqrt_mul (by positivity)]
    rw [show m / eps * (eps / m) = 1 by field_simp]
    exact Real.sqrt_one
  field_simp
  nlinarith [h1]

/-- **The closed-interval Wronskian obstruction.**  Let `y'' ≤ -(ε/m) y` on the closed
interval `[a, a + B]` of length exactly the Bonnet–Myers length `B = π √(m/ε)`, and
suppose `y a ≥ 0`.  Then `y (a + B) ≤ 0`.

Comparing the Wronskian `W = y' s - y s'` against `s(t) = sin(b (t - a))` on the *closed*
interval — where `s` vanishes at both endpoints — is what upgrades the usual strict
length bound to the sharp one. -/
theorem nonpos_of_length_pi (hm : 0 < m) (he : 0 < eps) {a : ℝ}
    (hd : ∀ x ∈ Icc a (a + Real.pi * Real.sqrt (m / eps)), HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Icc a (a + Real.pi * Real.sqrt (m / eps)), HasDerivAt y' (y'' x) x)
    (hcomp : ∀ x ∈ Icc a (a + Real.pi * Real.sqrt (m / eps)), y'' x ≤ -(eps / m) * y x)
    (h0 : 0 ≤ y a) :
    y (a + Real.pi * Real.sqrt (m / eps)) ≤ 0 := by
  set b : ℝ := Real.sqrt (eps / m) with hb
  have hbpos : 0 < b := Real.sqrt_pos.2 (div_pos he hm)
  have hbsq : b ^ 2 = eps / m := Real.sq_sqrt (div_pos he hm).le
  set B : ℝ := Real.pi * Real.sqrt (m / eps) with hBdef
  have hBb : B = Real.pi / b := by rw [hBdef, hb, myersLength_eq_pi_div hm he]
  have hBpos : 0 < B := by
    rw [hBb]
    exact div_pos Real.pi_pos hbpos
  have hbB : b * B = Real.pi := by
    rw [hBb]
    field_simp
  -- the comparison solution `s(t) = sin (b (t - a))`
  set s : ℝ → ℝ := fun t => Real.sin (b * (t - a)) with hs
  set s' : ℝ → ℝ := fun t => b * Real.cos (b * (t - a)) with hs'
  have hds : ∀ x : ℝ, HasDerivAt s (s' x) x := by
    intro x
    have h1 : HasDerivAt (fun t : ℝ => b * (t - a)) b x := by
      simpa using ((hasDerivAt_id x).sub_const a).const_mul b
    have h2 := (Real.hasDerivAt_sin (b * (x - a))).comp x h1
    simp only [hs, hs', Function.comp_def] at *
    convert h2 using 1
    ring
  have hds' : ∀ x : ℝ, HasDerivAt s' (-(b ^ 2) * Real.sin (b * (x - a))) x := by
    intro x
    have h1 : HasDerivAt (fun t : ℝ => b * (t - a)) b x := by
      simpa using ((hasDerivAt_id x).sub_const a).const_mul b
    have h2 := ((Real.hasDerivAt_cos (b * (x - a))).comp x h1).const_mul b
    convert h2 using 1
    ring
  set W : ℝ → ℝ := fun t => y' t * s t - y t * s' t with hW
  set W' : ℝ → ℝ := fun t => y'' t * s t + y t * (b ^ 2) * Real.sin (b * (t - a)) with hW'
  have hIco : Ico a (a + B) ⊆ Icc a (a + B) := Ico_subset_Icc_self
  have hdW : ∀ x ∈ Ico a (a + B), HasDerivAt W (W' x) x := by
    intro x hx
    have h1 := ((hd' x (hIco hx)).mul (hds x)).sub ((hd x (hIco hx)).mul (hds' x))
    convert h1 using 1
    simp only [hW', hs, hs']
    ring
  have hsin_nonneg : ∀ x ∈ Icc a (a + B), 0 ≤ Real.sin (b * (x - a)) := by
    intro x hx
    refine Real.sin_nonneg_of_nonneg_of_le_pi (by nlinarith [hx.1, hbpos]) ?_
    have h : x - a ≤ B := by linarith [hx.2]
    calc b * (x - a) ≤ b * B := by nlinarith [hbpos]
      _ = Real.pi := hbB
  have hW'_nonpos : ∀ x ∈ Ico a (a + B), W' x ≤ 0 := by
    intro x hx
    have hx' := hIco hx
    have h1 : y'' x ≤ -(eps / m) * y x := hcomp x hx'
    have h2 : 0 ≤ Real.sin (b * (x - a)) := hsin_nonneg x hx'
    have h3 : y'' x * Real.sin (b * (x - a)) ≤ (-(eps / m) * y x) * Real.sin (b * (x - a)) :=
      mul_le_mul_of_nonneg_right h1 h2
    simp only [hW', hs]
    rw [hbsq]
    nlinarith [h3]
  -- the Wronskian is non-increasing on the closed comparison interval
  have hWmono : ∀ t ∈ Icc a (a + B), W t ≤ W a := by
    intro t ht
    refine image_le_of_deriv_right_le_deriv_boundary (f := W) (f' := W')
      (B := fun _ => W a) (B' := fun _ => 0) ?_ ?_ le_rfl ?_ ?_ ?_ ht
    · intro x hx
      exact (((hd' x hx).mul (hds x)).sub
        ((hd x hx).mul (hds' x))).continuousAt.continuousWithinAt
    · exact fun x hx => (hdW x hx).hasDerivWithinAt
    · exact fun x _ => continuousWithinAt_const
    · exact fun x _ => (hasDerivAt_const x _).hasDerivWithinAt
    · exact hW'_nonpos
  -- endpoint values: `W a = -b y a ≤ 0` and `W (a + B) = b y (a + B)`
  have hWa : W a = -(y a * b) := by simp [hW, hs, hs']
  have hWend : W (a + B) = y (a + B) * b := by
    have h1 : b * (a + B - a) = Real.pi := by
      rw [show a + B - a = B by ring]; exact hbB
    have h2 : Real.sin (b * (a + B - a)) = 0 := by rw [h1]; exact Real.sin_pi
    have h3 : Real.cos (b * (a + B - a)) = -1 := by rw [h1]; exact Real.cos_pi
    simp only [hW, hs, hs', h2, h3]
    ring
  have hfin := hWmono (a + B) (right_mem_Icc.2 (by linarith))
  rw [hWa, hWend] at hfin
  nlinarith [mul_nonneg h0 hbpos.le]

/-- Auxiliary form of the sharp existence statement: a Jacobi field with `k ≥ ε/m` that is
positive at the right endpoint of an interval of length at least `B = π √(m/ε)` must
vanish somewhere in the half-open interval. -/
theorem exists_zero_Ioc_aux (hm : 0 < m) (he : 0 < eps) {a c : ℝ}
    (hd : ∀ x ∈ Icc a c, HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Icc a c, HasDerivAt y' (y'' x) x)
    (heq : ∀ x ∈ Icc a c, y'' x = -(k x) * y x)
    (hk : ∀ x ∈ Icc a c, eps / m ≤ k x)
    (hlong : Real.pi * Real.sqrt (m / eps) ≤ c - a)
    (hpos : 0 < y c) (hnz : ∀ t ∈ Ioc a c, y t ≠ 0) : False := by
  set B : ℝ := Real.pi * Real.sqrt (m / eps) with hBdef
  have hBpos : 0 < B := by
    have : 0 < Real.sqrt (m / eps) := Real.sqrt_pos.2 (div_pos hm he)
    rw [hBdef]
    positivity
  have hac : a < c := by linarith
  have hcont : ContinuousOn y (Icc a c) := fun x hx =>
    (hd x hx).continuousAt.continuousWithinAt
  -- Step 1: `y` is non-negative on the whole interval
  have hynn : ∀ t ∈ Icc a c, 0 ≤ y t := by
    intro t ht
    by_contra hcon
    push_neg at hcon
    have hsub : Icc (min t c) (max t c) ⊆ Icc a c := by
      rw [min_eq_left ht.2, max_eq_right ht.2]
      exact Icc_subset_Icc ht.1 le_rfl
    have hmem : (0 : ℝ) ∈ Icc (min (y t) (y c)) (max (y t) (y c)) :=
      ⟨le_of_lt (lt_of_le_of_lt (min_le_left _ _) hcon),
        le_of_lt (lt_of_lt_of_le hpos (le_max_right _ _))⟩
    obtain ⟨z, hz, hz0⟩ :=
      intermediate_value_uIcc (a := t) (b := c) (f := y) (hcont.mono hsub) hmem
    have hzmem : z ∈ Icc t c := by
      rw [uIcc_of_le ht.2] at hz
      exact hz
    have hza : a < z := by
      rcases lt_or_eq_of_le ht.1 with h | h
      · linarith [hzmem.1]
      · -- `t = a`, and `y a < 0 ≠ 0 = y z` forces `z ≠ a`
        rcases lt_or_eq_of_le hzmem.1 with h2 | h2
        · linarith
        · exfalso
          rw [h2, hz0] at hcon
          linarith
    exact hnz z ⟨hza, hzmem.2⟩ hz0
  -- Step 2: on `[a, a + B]` the Jacobi equation gives the comparison inequality
  have hsubB : Icc a (a + B) ⊆ Icc a c := Icc_subset_Icc le_rfl (by linarith)
  have hcomp : ∀ x ∈ Icc a (a + B), y'' x ≤ -(eps / m) * y x := by
    intro x hx
    have hx' := hsubB hx
    rw [heq x hx']
    have h1 : eps / m ≤ k x := hk x hx'
    have h2 : 0 ≤ y x := hynn x hx'
    nlinarith
  -- Step 3: the Wronskian obstruction contradicts positivity at `a + B`
  have hend : y (a + B) ≤ 0 :=
    nonpos_of_length_pi hm he (fun x hx => hd x (hsubB hx)) (fun x hx => hd' x (hsubB hx))
      hcomp (hynn a (left_mem_Icc.2 hac.le))
  have hmemB : a + B ∈ Ioc a c := ⟨by linarith, by linarith⟩
  have hnn : 0 ≤ y (a + B) := hynn _ (hsubB (right_mem_Icc.2 (by linarith)))
  exact hnz _ hmemB (le_antisymm hend hnn)

/-- **Sharp conjugate-point existence.**  A Jacobi field `y'' = -k y` with `k ≥ ε/m > 0`
has a zero in the half-open interval `(a, c]` as soon as `c - a ≥ π √(m/ε)`.

Two features make this the optimal statement: the length hypothesis is non-strict (the
model `sin(√(ε/m)(t-a))` has consecutive zeros exactly `π √(m/ε)` apart), and the zero is
located in `(a, c]`, so applying the theorem to consecutive blocks yields *distinct*
conjugate points. -/
theorem exists_zero_Ioc_of_length_ge (hm : 0 < m) (he : 0 < eps) {a c : ℝ}
    (hd : ∀ x ∈ Icc a c, HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Icc a c, HasDerivAt y' (y'' x) x)
    (heq : ∀ x ∈ Icc a c, y'' x = -(k x) * y x)
    (hk : ∀ x ∈ Icc a c, eps / m ≤ k x)
    (hlong : Real.pi * Real.sqrt (m / eps) ≤ c - a) :
    ∃ t ∈ Ioc a c, y t = 0 := by
  by_contra hcon
  push_neg at hcon
  have hBpos : 0 < Real.pi * Real.sqrt (m / eps) := by
    have : 0 < Real.sqrt (m / eps) := Real.sqrt_pos.2 (div_pos hm he)
    positivity
  have hac : a < c := by linarith
  have hcne : y c ≠ 0 := hcon c ⟨hac, le_rfl⟩
  rcases lt_or_gt_of_ne hcne with hneg | hpos
  · -- apply the auxiliary statement to `-y`, which solves the same equation
    refine exists_zero_Ioc_aux (y := fun t => -y t) (y' := fun t => -y' t)
      (y'' := fun t => -y'' t) (k := k) hm he (fun x hx => (hd x hx).neg)
      (fun x hx => (hd' x hx).neg) ?_ hk hlong (by simpa using hneg) ?_
    · intro x hx
      show -y'' x = -(k x) * -(y x)
      rw [heq x hx]
      ring
    · intro t ht
      simpa using hcon t ht
  · exact exists_zero_Ioc_aux hm he hd hd' heq hk hlong hpos hcon

/-- **Sharp oscillation count.**  A Jacobi field with `k ≥ ε/m > 0` on `[0, T]` has at
least `n` distinct conjugate points as soon as `T ≥ n · π √(m/ε)` — the non-strict
inequality, in contrast with `sturm_oscillation_count`.  The zeros are produced one per
block `(iB, (i+1)B]`, hence automatically distinct and strictly increasing. -/
theorem sturm_oscillation_count_sharp (hm : 0 < m) (he : 0 < eps) {T : ℝ} {n : ℕ}
    (hd : ∀ x ∈ Icc (0 : ℝ) T, HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Icc (0 : ℝ) T, HasDerivAt y' (y'' x) x)
    (heq : ∀ x ∈ Icc (0 : ℝ) T, y'' x = -(k x) * y x)
    (hk : ∀ x ∈ Icc (0 : ℝ) T, eps / m ≤ k x)
    (hT : (n : ℝ) * (Real.pi * Real.sqrt (m / eps)) ≤ T) :
    ∃ z : Fin n → ℝ, StrictMono z ∧ ∀ i, z i ∈ Ioc (0 : ℝ) T ∧ y (z i) = 0 := by
  set B : ℝ := Real.pi * Real.sqrt (m / eps) with hBdef
  have hBpos : 0 < B := by
    have : 0 < Real.sqrt (m / eps) := Real.sqrt_pos.2 (div_pos hm he)
    rw [hBdef]
    positivity
  have hslot : ∀ i : Fin n, ∃ t ∈ Ioc ((i : ℝ) * B) (((i : ℝ) + 1) * B), y t = 0 := by
    intro i
    have hi : (i : ℝ) + 1 ≤ (n : ℝ) := by
      have : (i : ℕ) + 1 ≤ n := i.2
      exact_mod_cast this
    have hi0 : (0 : ℝ) ≤ (i : ℝ) := Nat.cast_nonneg _
    have hsub : Icc ((i : ℝ) * B) (((i : ℝ) + 1) * B) ⊆ Icc (0 : ℝ) T := by
      refine Icc_subset_Icc (by positivity) ?_
      have h2 : ((i : ℝ) + 1) * B ≤ (n : ℝ) * B :=
        mul_le_mul_of_nonneg_right hi hBpos.le
      linarith
    refine exists_zero_Ioc_of_length_ge hm he (fun x hx => hd x (hsub hx))
      (fun x hx => hd' x (hsub hx)) (fun x hx => heq x (hsub hx))
      (fun x hx => hk x (hsub hx)) ?_
    have : ((i : ℝ) + 1) * B - (i : ℝ) * B = B := by ring
    rw [this]
  choose z hz hz0 using hslot
  refine ⟨z, ?_, ?_⟩
  · intro i j hij
    have h1 : z i ≤ ((i : ℝ) + 1) * B := (hz i).2
    have h2 : (j : ℝ) * B < z j := (hz j).1
    have h3 : (i : ℝ) + 1 ≤ (j : ℝ) := by
      have : (i : ℕ) + 1 ≤ (j : ℕ) := hij
      exact_mod_cast this
    have h4 : ((i : ℝ) + 1) * B ≤ (j : ℝ) * B := mul_le_mul_of_nonneg_right h3 hBpos.le
    linarith
  · intro i
    have hi : (i : ℝ) + 1 ≤ (n : ℝ) := by
      have : (i : ℕ) + 1 ≤ n := i.2
      exact_mod_cast this
    have hi0 : (0 : ℝ) ≤ (i : ℝ) := Nat.cast_nonneg _
    refine ⟨⟨?_, ?_⟩, hz0 i⟩
    · have h1 : (i : ℝ) * B < z i := (hz i).1
      nlinarith
    · have h1 : z i ≤ ((i : ℝ) + 1) * B := (hz i).2
      have h2 : ((i : ℝ) + 1) * B ≤ (n : ℝ) * B :=
        mul_le_mul_of_nonneg_right hi hBpos.le
      linarith

/-- **The exact floor count.**  On `[0, T]` a Jacobi field with `k ≥ ε/m > 0` has at least
`⌊T √(ε/m) / π⌋ = ⌊T / (π √(m/ε))⌋` distinct conjugate points.  This is the sharp
oscillation statement: for the model `sin(√(ε/m) t)` the count is attained exactly. -/
theorem sturm_zero_count_floor (hm : 0 < m) (he : 0 < eps) {T : ℝ} (hT : 0 ≤ T)
    (hd : ∀ x ∈ Icc (0 : ℝ) T, HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Icc (0 : ℝ) T, HasDerivAt y' (y'' x) x)
    (heq : ∀ x ∈ Icc (0 : ℝ) T, y'' x = -(k x) * y x)
    (hk : ∀ x ∈ Icc (0 : ℝ) T, eps / m ≤ k x) :
    ∃ z : Fin ⌊T / (Real.pi * Real.sqrt (m / eps))⌋₊ → ℝ, StrictMono z ∧
      ∀ i, z i ∈ Ioc (0 : ℝ) T ∧ y (z i) = 0 := by
  set B : ℝ := Real.pi * Real.sqrt (m / eps) with hBdef
  have hBpos : 0 < B := by
    have : 0 < Real.sqrt (m / eps) := Real.sqrt_pos.2 (div_pos hm he)
    rw [hBdef]
    positivity
  refine sturm_oscillation_count_sharp hm he hd hd' heq hk ?_
  have hfloor : ((⌊T / B⌋₊ : ℕ) : ℝ) ≤ T / B := Nat.floor_le (by positivity)
  rw [le_div_iff₀ hBpos] at hfloor
  exact hfloor

/-- **Sharpness of the threshold.**  On any interval of length *strictly less* than
`π √(m/ε)` there is an exact solution of the Jacobi equation with `k ≡ ε/m` that is
everywhere positive, namely `cos(√(ε/m)(t - midpoint))`.  Hence no conjugate point can be
forced on a shorter interval, and the constant in `exists_zero_Ioc_of_length_ge`,
`sturm_oscillation_count_sharp` and `sturm_zero_count_floor` is optimal. -/
theorem cos_model_positive_of_short_interval (hm : 0 < m) (he : 0 < eps) {a c : ℝ}
    (hshort : c - a < Real.pi * Real.sqrt (m / eps)) :
    ∃ y y' y'' : ℝ → ℝ,
      (∀ x : ℝ, HasDerivAt y (y' x) x) ∧
      (∀ x : ℝ, HasDerivAt y' (y'' x) x) ∧
      (∀ x : ℝ, y'' x = -(eps / m) * y x) ∧
      (∀ t ∈ Icc a c, 0 < y t) := by
  set b : ℝ := Real.sqrt (eps / m) with hb
  have hbpos : 0 < b := Real.sqrt_pos.2 (div_pos he hm)
  have hbsq : b ^ 2 = eps / m := Real.sq_sqrt (div_pos he hm).le
  set mid : ℝ := (a + c) / 2 with hmid
  refine ⟨fun t => Real.cos (b * (t - mid)), fun t => -b * Real.sin (b * (t - mid)),
    fun t => -(b ^ 2) * Real.cos (b * (t - mid)), ?_, ?_, ?_, ?_⟩
  · intro x
    have h1 : HasDerivAt (fun t : ℝ => b * (t - mid)) b x := by
      simpa using ((hasDerivAt_id x).sub_const mid).const_mul b
    have h2 := (Real.hasDerivAt_cos (b * (x - mid))).comp x h1
    convert h2 using 1
    ring
  · intro x
    have h1 : HasDerivAt (fun t : ℝ => b * (t - mid)) b x := by
      simpa using ((hasDerivAt_id x).sub_const mid).const_mul b
    have h2 := ((Real.hasDerivAt_sin (b * (x - mid))).comp x h1).const_mul (-b)
    convert h2 using 1
    ring
  · intro x
    rw [hbsq]
  · intro t ht
    -- the phase stays strictly inside `(-π/2, π/2)`
    have hhalf : b * (c - a) < Real.pi := by
      have h1 : b * (c - a) < b * (Real.pi * Real.sqrt (m / eps)) := by
        exact (mul_lt_mul_iff_of_pos_left hbpos).2 hshort
      have h3 : b * Real.sqrt (m / eps) = 1 := by
        rw [hb, ← Real.sqrt_mul (by positivity),
          show eps / m * (m / eps) = 1 by field_simp]
        exact Real.sqrt_one
      have h2 : b * (Real.pi * Real.sqrt (m / eps)) = Real.pi := by
        rw [show b * (Real.pi * Real.sqrt (m / eps))
          = Real.pi * (b * Real.sqrt (m / eps)) by ring, h3, mul_one]
      linarith
    have hupper : b * (t - mid) < Real.pi / 2 := by
      have h1 : t - mid ≤ (c - a) / 2 := by
        rw [hmid]
        linarith [ht.2]
      have h2 : b * (t - mid) ≤ b * ((c - a) / 2) := mul_le_mul_of_nonneg_left h1 hbpos.le
      have h3 : b * ((c - a) / 2) < Real.pi / 2 := by
        have h4 : b * ((c - a) / 2) = b * (c - a) / 2 := by ring
        rw [h4]
        linarith
      linarith
    have hlower : -(Real.pi / 2) < b * (t - mid) := by
      have h1 : -((c - a) / 2) ≤ t - mid := by
        rw [hmid]
        linarith [ht.1]
      have h2 : b * (-((c - a) / 2)) ≤ b * (t - mid) := mul_le_mul_of_nonneg_left h1 hbpos.le
      have h3 : -(Real.pi / 2) < b * (-((c - a) / 2)) := by
        have h4 : b * (-((c - a) / 2)) = -(b * (c - a) / 2) := by ring
        rw [h4]
        linarith
      linarith
    exact Real.cos_pos_of_mem_Ioo ⟨hlower, hupper⟩

end SharpSturm

end Catalog.Physics.Spacetime