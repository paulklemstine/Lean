/-
  Oscillation counting: from a singularity theorem to a conjugate-point count.

  `JacobiConjugatePoints.sturm_length_bound` says that a *positive* solution of
  `y'' ≤ -(ε/m) y` lives on an interval of length at most `π √(m/ε)`.  Under the strict
  energy condition the transverse radius of a geodesic congruence solves the Jacobi
  equation `y'' = -(Ric/m) y` with `Ric ≥ ε`, and such a solution may be continued *through*
  its zeros — the zeros are exactly the conjugate (focal) points, where the Riccati
  variable `θ = m y'/y` blows up.  This file turns the length bound into a statement about
  how many conjugate points occur (Conjecture 4 of the previous cycle's
  `FUTURE_DIRECTIONS.md`):

  * `sturm_positive_interval_length` — the length bound on an arbitrary interval `[a, b)`,
    obtained from the `[0, L)` version by affine reparametrisation.
  * `exists_zero_of_long_interval` — **every** subinterval of length `> π √(m/ε)` contains a
    conjugate point; no sign or positivity hypothesis is needed, since a nonvanishing
    solution has a constant sign and `-y` solves the same equation.
  * `sturm_oscillation_count` — consequently a solution on `[0, T]` with
    `T > n · π √(m/ε)` has at least `n` distinct conjugate points, produced as a strictly
    increasing family; the affine parameter is exhausted by focusing at a definite rate.
-/

import Physics.Spacetime.JacobiConjugatePoints

open Set

namespace Catalog.Physics.Spacetime

section Oscillation

variable {m eps : ℝ} {y y' y'' k : ℝ → ℝ}

/-- **Length bound on an arbitrary interval.**  A positive solution of `y'' ≤ -(ε/m) y` on
`[a, b)` forces `b - a ≤ π √(m/ε)`.  This is `sturm_length_bound` transported by the
affine reparametrisation `t ↦ a + t`. -/
theorem sturm_positive_interval_length (hm : 0 < m) (he : 0 < eps) {a b : ℝ}
    (hd : ∀ x ∈ Ico a b, HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Ico a b, HasDerivAt y' (y'' x) x)
    (hpos : ∀ x ∈ Ico a b, 0 < y x)
    (hcomp : ∀ x ∈ Ico a b, y'' x ≤ -(eps / m) * y x) :
    b - a ≤ Real.pi * Real.sqrt (m / eps) := by
  have hmem : ∀ x ∈ Ico (0 : ℝ) (b - a), a + x ∈ Ico a b := by
    intro x hx
    exact ⟨by linarith [hx.1], by linarith [hx.2]⟩
  refine sturm_length_bound (y := fun t => y (a + t)) (y' := fun t => y' (a + t))
    (y'' := fun t => y'' (a + t)) hm he ?_ ?_ ?_ ?_
  · intro x hx
    simpa using (hd (a + x) (hmem x hx)).comp x ((hasDerivAt_id x).const_add a)
  · intro x hx
    simpa using (hd' (a + x) (hmem x hx)).comp x ((hasDerivAt_id x).const_add a)
  · exact fun x hx => hpos (a + x) (hmem x hx)
  · exact fun x hx => hcomp (a + x) (hmem x hx)

/-- **A conjugate point in every long interval.**  Let `y` solve the Jacobi equation
`y'' = -k y` with `k ≥ ε/m > 0` on `[a, b]`.  If the interval is longer than the
Bonnet–Myers length `π √(m/ε)`, then `y` vanishes somewhere on it.  Unlike
`sturm_length_bound` this needs no positivity assumption: a nonvanishing solution has a
constant sign by the intermediate value theorem, and `-y` solves the same equation. -/
theorem exists_zero_of_long_interval (hm : 0 < m) (he : 0 < eps) {a b : ℝ}
    (hd : ∀ x ∈ Icc a b, HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Icc a b, HasDerivAt y' (y'' x) x)
    (heq : ∀ x ∈ Icc a b, y'' x = -(k x) * y x)
    (hk : ∀ x ∈ Icc a b, eps / m ≤ k x)
    (hlong : Real.pi * Real.sqrt (m / eps) < b - a) :
    ∃ t ∈ Icc a b, y t = 0 := by
  by_contra hcon
  push_neg at hcon
  have hB : (0 : ℝ) ≤ Real.pi * Real.sqrt (m / eps) := by positivity
  have hab : a ≤ b := by linarith
  have hcont : ContinuousOn y (Icc a b) := fun x hx =>
    (hd x hx).continuousAt.continuousWithinAt
  have hane : y a ≠ 0 := hcon a (left_mem_Icc.2 hab)
  have hIco : Ico a b ⊆ Icc a b := Ico_subset_Icc_self
  -- A nonvanishing continuous function on `[a, b]` has a constant sign.
  have hsign : (∀ t ∈ Icc a b, 0 < y t) ∨ (∀ t ∈ Icc a b, y t < 0) := by
    rcases lt_or_gt_of_ne hane with hneg | hpos
    · right
      intro t ht
      rcases lt_trichotomy (y t) 0 with h | h | h
      · exact h
      · exact absurd h (hcon t ht)
      · exfalso
        have hsub : Icc (min a t) (max a t) ⊆ Icc a b := by
          rw [min_eq_left ht.1, max_eq_right ht.1]
          exact Icc_subset_Icc le_rfl ht.2
        have hmem : (0 : ℝ) ∈ Icc (min (y a) (y t)) (max (y a) (y t)) :=
          ⟨le_of_lt (lt_of_le_of_lt (min_le_left _ _) hneg),
            le_of_lt (lt_of_lt_of_le h (le_max_right _ _))⟩
        obtain ⟨c, hc, hc0⟩ :=
          intermediate_value_uIcc (a := a) (b := t) (f := y)
            (hcont.mono hsub) hmem
        exact hcon c (hsub hc) hc0
    · left
      intro t ht
      rcases lt_trichotomy (y t) 0 with h | h | h
      · exfalso
        have hsub : Icc (min a t) (max a t) ⊆ Icc a b := by
          rw [min_eq_left ht.1, max_eq_right ht.1]
          exact Icc_subset_Icc le_rfl ht.2
        have hmem : (0 : ℝ) ∈ Icc (min (y a) (y t)) (max (y a) (y t)) :=
          ⟨le_of_lt (lt_of_le_of_lt (min_le_right _ _) h),
            le_of_lt (lt_of_lt_of_le hpos (le_max_left _ _))⟩
        obtain ⟨c, hc, hc0⟩ :=
          intermediate_value_uIcc (a := a) (b := t) (f := y)
            (hcont.mono hsub) hmem
        exact hcon c (hsub hc) hc0
      · exact absurd h (hcon t ht)
      · exact h
  rcases hsign with hpos | hneg
  · -- positive solution: the interval cannot be longer than the Myers length
    have hlen : b - a ≤ Real.pi * Real.sqrt (m / eps) := by
      refine sturm_positive_interval_length hm he
        (fun x hx => hd x (hIco hx)) (fun x hx => hd' x (hIco hx))
        (fun x hx => hpos x (hIco hx)) ?_
      intro x hx
      have hx' : x ∈ Icc a b := hIco hx
      rw [heq x hx']
      have h1 : -(k x) ≤ -(eps / m) := neg_le_neg (hk x hx')
      exact mul_le_mul_of_nonneg_right h1 (hpos x hx').le
    linarith
  · -- negative solution: apply the same bound to `-y`
    have hlen : b - a ≤ Real.pi * Real.sqrt (m / eps) := by
      refine sturm_positive_interval_length (y := fun t => -y t) (y' := fun t => -y' t)
        (y'' := fun t => -y'' t) hm he
        (fun x hx => (hd x (hIco hx)).neg) (fun x hx => (hd' x (hIco hx)).neg)
        (fun x hx => by simpa using hneg x (hIco hx)) ?_
      intro x hx
      have hx' : x ∈ Icc a b := hIco hx
      have hposy : 0 < -y x := by simpa using hneg x hx'
      have h1 : -(k x) ≤ -(eps / m) := neg_le_neg (hk x hx')
      have h2 : -(k x) * (-y x) ≤ -(eps / m) * (-y x) :=
        mul_le_mul_of_nonneg_right h1 hposy.le
      have h3 : -y'' x = -(k x) * (-y x) := by rw [heq x hx']; ring
      show -y'' x ≤ -(eps / m) * (-y x)
      rw [h3]
      exact h2
    linarith

/-- **Conjugate point counting.**  A solution of the Jacobi equation `y'' = -k y` with
`k ≥ ε/m > 0` on `[0, T]` has at least `n` distinct conjugate points as soon as
`T > n · π √(m/ε)`: the zeros are produced as a strictly increasing family in `[0, T]`.
Equivalently, the total Prüfer phase accumulated over `[0, T]` is at least
`T √(ε/m)`, and each `π` of phase costs one focal point.  This upgrades the singularity
theorem (`n = 1`, existence of one conjugate point) to an oscillation statement. -/
theorem sturm_oscillation_count (hm : 0 < m) (he : 0 < eps) {T : ℝ} {n : ℕ}
    (hd : ∀ x ∈ Icc (0 : ℝ) T, HasDerivAt y (y' x) x)
    (hd' : ∀ x ∈ Icc (0 : ℝ) T, HasDerivAt y' (y'' x) x)
    (heq : ∀ x ∈ Icc (0 : ℝ) T, y'' x = -(k x) * y x)
    (hk : ∀ x ∈ Icc (0 : ℝ) T, eps / m ≤ k x)
    (hT : (n : ℝ) * (Real.pi * Real.sqrt (m / eps)) < T) :
    ∃ z : Fin n → ℝ, StrictMono z ∧ ∀ i, z i ∈ Icc (0 : ℝ) T ∧ y (z i) = 0 := by
  set B : ℝ := Real.pi * Real.sqrt (m / eps) with hBdef
  have hB : 0 < B := by
    have : 0 < Real.sqrt (m / eps) := Real.sqrt_pos.2 (div_pos hm he)
    positivity
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn
    exact ⟨fun i => i.elim0, fun i => i.elim0, fun i => i.elim0⟩
  have hnpos : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  set c : ℝ := T / n with hc
  have hcB : B < c := by
    rw [hc, lt_div_iff₀ hnpos]
    linarith [hT]
  have hTc : (n : ℝ) * c = T := by
    rw [hc]
    field_simp
  -- in the `i`-th slot `[i c, i c + (c + B)/2]`, which has length `> B`, there is a zero
  have hslot : ∀ i : Fin n, ∃ t ∈ Icc ((i : ℝ) * c) ((i : ℝ) * c + (c + B) / 2), y t = 0 := by
    intro i
    have hi : (i : ℝ) + 1 ≤ (n : ℝ) := by
      have : (i : ℕ) + 1 ≤ n := i.2
      exact_mod_cast this
    have hi0 : (0 : ℝ) ≤ (i : ℝ) := Nat.cast_nonneg _
    have hcpos : 0 < c := lt_trans hB hcB
    have hsub : Icc ((i : ℝ) * c) ((i : ℝ) * c + (c + B) / 2) ⊆ Icc (0 : ℝ) T := by
      refine Icc_subset_Icc (by positivity) ?_
      have h1 : (c + B) / 2 ≤ c := by linarith
      have h2 : ((i : ℝ) + 1) * c ≤ (n : ℝ) * c :=
        mul_le_mul_of_nonneg_right hi hcpos.le
      rw [← hTc]
      nlinarith
    refine exists_zero_of_long_interval hm he
      (fun x hx => hd x (hsub hx)) (fun x hx => hd' x (hsub hx))
      (fun x hx => heq x (hsub hx)) (fun x hx => hk x (hsub hx)) ?_
    have : (i : ℝ) * c + (c + B) / 2 - (i : ℝ) * c = (c + B) / 2 := by ring
    rw [this]
    linarith
  choose z hz hz0 using hslot
  refine ⟨z, ?_, ?_⟩
  · intro i j hij
    have hcpos : 0 < c := lt_trans hB hcB
    have h1 : z i ≤ (i : ℝ) * c + (c + B) / 2 := (hz i).2
    have h2 : (j : ℝ) * c ≤ z j := (hz j).1
    have h3 : (i : ℝ) + 1 ≤ (j : ℝ) := by
      have : (i : ℕ) + 1 ≤ (j : ℕ) := hij
      exact_mod_cast this
    have h4 : ((i : ℝ) + 1) * c ≤ (j : ℝ) * c := mul_le_mul_of_nonneg_right h3 hcpos.le
    nlinarith
  · intro i
    have hi : (i : ℝ) + 1 ≤ (n : ℝ) := by
      have : (i : ℕ) + 1 ≤ n := i.2
      exact_mod_cast this
    have hi0 : (0 : ℝ) ≤ (i : ℝ) := Nat.cast_nonneg _
    have hcpos : 0 < c := lt_trans hB hcB
    refine ⟨⟨?_, ?_⟩, hz0 i⟩
    · have := (hz i).1
      nlinarith
    · have h1 : z i ≤ (i : ℝ) * c + (c + B) / 2 := (hz i).2
      have h2 : (c + B) / 2 ≤ c := by linarith
      have h3 : ((i : ℝ) + 1) * c ≤ (n : ℝ) * c :=
        mul_le_mul_of_nonneg_right hi hcpos.le
      rw [← hTc]
      nlinarith

/-- **Non-vacuity of the counting theorem.**  The constant-curvature model
`y(t) = sin(√(ε/m) t)`, which solves the Jacobi equation with `Ric(k,k) ≡ ε` exactly,
satisfies all hypotheses of `sturm_oscillation_count`; the conclusion therefore produces
genuine conjugate points (the zeros `j π √(m/ε)` of the sine). -/
theorem sturm_oscillation_count_model (hm : 0 < m) (he : 0 < eps) {T : ℝ} {n : ℕ}
    (hT : (n : ℝ) * (Real.pi * Real.sqrt (m / eps)) < T) :
    ∃ z : Fin n → ℝ, StrictMono z ∧ ∀ i, z i ∈ Icc (0 : ℝ) T ∧
      Real.sin (Real.sqrt (eps / m) * z i) = 0 := by
  set b : ℝ := Real.sqrt (eps / m) with hb
  have hbsq : b ^ 2 = eps / m := Real.sq_sqrt (div_pos he hm).le
  refine sturm_oscillation_count (y := fun t => Real.sin (b * t))
    (y' := fun t => b * Real.cos (b * t))
    (y'' := fun t => -(b ^ 2) * Real.sin (b * t))
    (k := fun _ => eps / m) hm he ?_ ?_ ?_ (fun x _ => le_rfl) hT
  · intro x _
    have h := (Real.hasDerivAt_sin (b * x)).comp x ((hasDerivAt_id x).const_mul b)
    convert h using 1
    ring
  · intro x _
    have h := ((Real.hasDerivAt_cos (b * x)).comp x ((hasDerivAt_id x).const_mul b)).const_mul b
    convert h using 1
    ring
  · intro x _
    rw [hbsq]

end Oscillation

end Catalog.Physics.Spacetime