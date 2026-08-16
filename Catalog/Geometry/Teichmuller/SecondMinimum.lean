/-
# Successive minima: Minkowski's second theorem and a collar lemma for the moduli space of tori

`Geometry.Teichmuller.SystoleFunctional` constructs the systolic functional `sys` — the length of
the shortest closed geodesic of a marked torus, normalized by the area — and
`Geometry.Teichmuller.MahlerCompactness` shows that its superlevel sets are the compact parts of
the moduli space.  This file studies the *second* successive minimum, i.e. the shortest closed
geodesic that is not a power of the shortest one, and proves the two-sided sharp estimate

    1  ≤  sys τ · (second minimum)  ≤  4/3 ,

which is Minkowski's second theorem for unimodular planar lattices.  The lower bound is the
"collar lemma" for tori: a torus with a short geodesic has *all* its other geodesics long, with
the sharp reciprocal bound `1 / sys τ`.

Main results:

* `Teichmuller.one_le_latticeValue_mul` : for any two independent lattice vectors of a marked
  torus, the product of their normalized squared lengths is at least `1`.  This is the
  determinant (Lagrange/Hadamard) inequality for the unimodular lattice `ℤ + τ ℤ`.
* `Teichmuller.collar_lemma` : if `(m, n)` realizes the systole then every independent lattice
  vector `(p, q)` satisfies `1 / sys τ ≤ latticeValue τ p q`; in the thin part `sys τ < 1` this
  is a genuine gap `sys τ < 1 < 1 / sys τ`.
* `Teichmuller.shortest_unique_of_sys_lt_one` : consequently, on the thin part the shortest
  lattice vector is unique up to sign — the short closed geodesic of a thin torus is unique.
* `Teichmuller.exists_basis_second_le` : **Minkowski's second theorem.**  Every marked torus has
  a basis `(m, n), (p, q)` of its lattice (determinant `1`) whose first vector realizes the
  systole and whose product of normalized squared lengths is at most `4/3`.
* `Teichmuller.sys_mul_second_mem_Icc` : combining the two, the product of the two successive
  minima lies in `[1, 4/3]`.
* `Teichmuller.second_minimum_rho`, `Teichmuller.second_minimum_cusp` : both bounds are sharp —
  the value `4/3` is attained at the hexagonal torus `ρ` and the value `1` at every rectangular
  torus `i Y` with `Y ≥ 1`.

-- !-- Lab Notes -- !--
Hypothesizer (D6): the thick-thin decomposition of the moduli space of tori should be governed
by a *reciprocal* pair of successive minima, with the hexagonal torus as the unique maximizer of
their product.
Experimenter: writing `a = m + n τ`, `b = p + q τ`, the Lagrange identity
`|a|² |b|² = (Re (ā b))² + (Im (ā b))²` together with `Im (ā b) = (m q − n p) · Im τ` turns the
lower bound into the statement that a nonzero integer has square at least `1`; no geometry is
used.  The upper bound is *not* of this kind: it needs the reduction theory of the modular
group, and it is proved by transporting the pair `(1, 0), (0, 1)` from the standard fundamental
domain along `normSq_ratio_smul`, whose index change `(m, n) ↦ (m d + n b, m c + n a)` has
determinant `a d − b c = 1` and therefore preserves bases.
Analyst: the two bounds are of genuinely different depth, and the numerics confirm the
prediction: the product equals `4/3` exactly at `ρ` and equals `1` exactly on the imaginary
axis above `i`, so both are attained and the interval `[1, 4/3]` is optimal.
Critic: the uniqueness statement must exclude the boundary case `sys τ = 1` (the square torus
`i` has *four* shortest vectors `±1, ±i`, product of minima `1`), and it does: the hypothesis
is the strict inequality `sys τ < 1`, and the proof uses `sys τ ^ 2 < 1`.
-/
import Mathlib
import Geometry.Teichmuller.MahlerCompactness

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups

/-! ### The determinant inequality -/

/-- Expansion of the normalized squared length in real coordinates. -/
theorem normSq_lattice_eq (tau : ℍ) (m n : ℤ) :
    Complex.normSq ((m : ℂ) + (n : ℂ) * (tau : ℂ))
      = ((m : ℝ) + (n : ℝ) * tau.re) ^ 2 + ((n : ℝ) * tau.im) ^ 2 := by
  simp [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]
  ring

/-- **The determinant inequality for the lattice of a marked torus.**  Two lattice vectors that
are linearly independent (`m q − n p ≠ 0`) have product of normalized squared lengths at least
`1`.  Equivalently: the parallelogram they span has area at least the area of the torus. -/
theorem one_le_latticeValue_mul (tau : ℍ) {m n p q : ℤ} (h : m * q - n * p ≠ 0) :
    1 ≤ latticeValue tau m n * latticeValue tau p q := by
  have hy : 0 < tau.im := tau.im_pos
  have hdet : (1 : ℝ) ≤ (((m * q - n * p : ℤ) : ℝ)) ^ 2 := by
    have h1 : (1 : ℤ) ≤ (m * q - n * p) ^ 2 := by
      rcases lt_or_gt_of_ne h with h' | h' <;> nlinarith
    exact_mod_cast (by exact_mod_cast h1 : (1 : ℝ) ≤ (((m * q - n * p) ^ 2 : ℤ) : ℝ))
  have key :
      (((m : ℝ) + (n : ℝ) * tau.re) ^ 2 + ((n : ℝ) * tau.im) ^ 2)
        * (((p : ℝ) + (q : ℝ) * tau.re) ^ 2 + ((q : ℝ) * tau.im) ^ 2)
      = (((m : ℝ) + (n : ℝ) * tau.re) * ((p : ℝ) + (q : ℝ) * tau.re)
            + ((n : ℝ) * tau.im) * ((q : ℝ) * tau.im)) ^ 2
        + (tau.im * ((m : ℝ) * (q : ℝ) - (n : ℝ) * (p : ℝ))) ^ 2 := by
    ring
  have hprod :
      tau.im ^ 2 ≤ (((m : ℝ) + (n : ℝ) * tau.re) ^ 2 + ((n : ℝ) * tau.im) ^ 2)
        * (((p : ℝ) + (q : ℝ) * tau.re) ^ 2 + ((q : ℝ) * tau.im) ^ 2) := by
    rw [key]
    have hcast : ((m : ℝ) * (q : ℝ) - (n : ℝ) * (p : ℝ)) = (((m * q - n * p : ℤ) : ℝ)) := by
      push_cast; ring
    have hD : (1 : ℝ) ≤ ((m : ℝ) * (q : ℝ) - (n : ℝ) * (p : ℝ)) ^ 2 := by
      rw [hcast]; exact hdet
    have hmul : tau.im ^ 2 * 1 ≤ tau.im ^ 2 * ((m : ℝ) * (q : ℝ) - (n : ℝ) * (p : ℝ)) ^ 2 :=
      mul_le_mul_of_nonneg_left hD (sq_nonneg _)
    have hsq : (tau.im * ((m : ℝ) * (q : ℝ) - (n : ℝ) * (p : ℝ))) ^ 2
        = tau.im ^ 2 * ((m : ℝ) * (q : ℝ) - (n : ℝ) * (p : ℝ)) ^ 2 := by ring
    nlinarith [sq_nonneg (((m : ℝ) + (n : ℝ) * tau.re) * ((p : ℝ) + (q : ℝ) * tau.re)
        + ((n : ℝ) * tau.im) * ((q : ℝ) * tau.im)), hmul, hsq]
  rw [latticeValue, latticeValue, normSq_lattice_eq, normSq_lattice_eq, div_mul_div_comm,
    le_div_iff₀ (by positivity)]
  calc (1 : ℝ) * (tau.im * tau.im) = tau.im ^ 2 := by ring
    _ ≤ _ := hprod

/-- **The collar lemma for marked tori.**  If `(m, n)` realizes the systole, every independent
lattice vector is at least `1 / sys τ` long: a short closed geodesic forces every transverse
geodesic to be long, with the sharp reciprocal constant. -/
theorem collar_lemma (tau : ℍ) {m n p q : ℤ} (hmin : latticeValue tau m n = sys tau)
    (h : m * q - n * p ≠ 0) : 1 / sys tau ≤ latticeValue tau p q := by
  have hs : 0 < sys tau := sys_pos tau
  have h1 := one_le_latticeValue_mul tau h
  rw [hmin] at h1
  rw [div_le_iff₀ hs]
  linarith [h1]

/-- In the thin part the collar lemma is a genuine gap: the systole is `< 1` and every
independent vector has normalized squared length `> 1`. -/
theorem collar_gap (tau : ℍ) (hthin : sys tau < 1) {m n p q : ℤ}
    (hmin : latticeValue tau m n = sys tau) (h : m * q - n * p ≠ 0) :
    sys tau < 1 ∧ 1 < latticeValue tau p q := by
  refine ⟨hthin, lt_of_lt_of_le ?_ (collar_lemma tau hmin h)⟩
  have hs : 0 < sys tau := sys_pos tau
  rw [lt_div_iff₀ hs]
  linarith

/-- **Uniqueness of the shortest geodesic on a thin torus.**  If `sys τ < 1` then the shortest
lattice vector is unique up to sign. -/
theorem shortest_unique_of_sys_lt_one (tau : ℍ) (hthin : sys tau < 1) {m n p q : ℤ}
    (hmn : m ≠ 0 ∨ n ≠ 0) (hpq : p ≠ 0 ∨ q ≠ 0)
    (hmin : latticeValue tau m n = sys tau) (hmin' : latticeValue tau p q = sys tau) :
    (p = m ∧ q = n) ∨ (p = -m ∧ q = -n) := by
  have hs : 0 < sys tau := sys_pos tau
  -- the two vectors cannot be independent
  have hdep : m * q - n * p = 0 := by
    by_contra hcon
    have h1 := one_le_latticeValue_mul tau hcon
    rw [hmin, hmin'] at h1
    nlinarith
  -- equality of the normalized squared lengths, in real coordinates
  have hlen : ((m : ℝ) + (n : ℝ) * tau.re) ^ 2 + ((n : ℝ) * tau.im) ^ 2
      = ((p : ℝ) + (q : ℝ) * tau.re) ^ 2 + ((q : ℝ) * tau.im) ^ 2 := by
    have h1 : latticeValue tau m n = latticeValue tau p q := by rw [hmin, hmin']
    rw [latticeValue, latticeValue, normSq_lattice_eq, normSq_lattice_eq] at h1
    have hy0 : tau.im ≠ 0 := ne_of_gt tau.im_pos
    have h2 := congrArg (fun t : ℝ => t * tau.im) h1
    simpa [div_mul_cancel₀, hy0] using h2
  have hy : (0:ℝ) < tau.im := tau.im_pos
  have hmq : m * q = n * p := by linarith [sub_eq_zero.mp hdep]
  rcases eq_or_ne n 0 with hn0 | hn0
  · -- horizontal case
    have hm0 : m ≠ 0 := by rcases hmn with h | h; · exact h
                           · exact absurd hn0 h
    have hq0 : q = 0 := by
      have : m * q = 0 := by rw [hmq, hn0]; ring
      rcases mul_eq_zero.mp this with h | h
      · exact absurd h hm0
      · exact h
    have hsq : (p : ℝ) ^ 2 = (m : ℝ) ^ 2 := by
      rw [hn0, hq0] at hlen
      push_cast at hlen ⊢
      nlinarith [hlen]
    have hsqz : p ^ 2 = m ^ 2 := by exact_mod_cast hsq
    have hfac : (p - m) * (p + m) = 0 := by linear_combination hsqz
    have : p = m ∨ p = -m := by
      rcases mul_eq_zero.mp hfac with h | h
      · exact Or.inl (by omega)
      · exact Or.inr (by omega)
    rcases this with h | h
    · exact Or.inl ⟨h, by rw [hq0, hn0]⟩
    · exact Or.inr ⟨h, by rw [hq0, hn0]; ring⟩
  · -- generic case: `q ≠ 0` and the two vectors are proportional with ratio `q / n`
    have hq0 : q ≠ 0 := by
      intro hq
      have : n * p = 0 := by rw [← hmq, hq]; ring
      rcases mul_eq_zero.mp this with h | h
      · exact hn0 h
      · rcases hpq with h' | h'
        · exact h' h
        · exact h' hq
    have hprop : ((p : ℝ) + (q : ℝ) * tau.re) * (n : ℝ)
        = (q : ℝ) * ((m : ℝ) + (n : ℝ) * tau.re) := by
      have : (m : ℝ) * (q : ℝ) = (n : ℝ) * (p : ℝ) := by exact_mod_cast hmq
      nlinarith [this]
    have hqn : (q : ℝ) ^ 2 = (n : ℝ) ^ 2 := by
      have hexp : ((p : ℝ) + (q : ℝ) * tau.re) ^ 2 * (n : ℝ) ^ 2
          = (q : ℝ) ^ 2 * ((m : ℝ) + (n : ℝ) * tau.re) ^ 2 := by
        linear_combination (((p : ℝ) + (q : ℝ) * tau.re) * (n : ℝ)
          + (q : ℝ) * ((m : ℝ) + (n : ℝ) * tau.re)) * hprop
      have h2 : (n : ℝ) ^ 2 * (((m : ℝ) + (n : ℝ) * tau.re) ^ 2 + ((n : ℝ) * tau.im) ^ 2)
          = (q : ℝ) ^ 2 * ((m : ℝ) + (n : ℝ) * tau.re) ^ 2
            + (n : ℝ) ^ 2 * ((q : ℝ) * tau.im) ^ 2 := by
        linear_combination (n : ℝ) ^ 2 * hlen + hexp
      have hnz : ((m : ℝ) + (n : ℝ) * tau.re) ^ 2 + ((n : ℝ) * tau.im) ^ 2 > 0 := by
        have hnn : ((n : ℝ) * tau.im) ^ 2 > 0 := by
          have : (n : ℝ) ≠ 0 := Int.cast_ne_zero.mpr hn0
          positivity
        nlinarith [sq_nonneg ((m : ℝ) + (n : ℝ) * tau.re)]
      have hfactor : ((n : ℝ) ^ 2 - (q : ℝ) ^ 2)
          * (((m : ℝ) + (n : ℝ) * tau.re) ^ 2 + ((n : ℝ) * tau.im) ^ 2) = 0 := by
        linear_combination h2
      have hzero : (n : ℝ) ^ 2 - (q : ℝ) ^ 2 = 0 := by
        rcases mul_eq_zero.mp hfactor with h | h
        · exact h
        · exact absurd h (ne_of_gt hnz)
      linarith
    have hqnz : q ^ 2 = n ^ 2 := by exact_mod_cast hqn
    have hfacq : (q - n) * (q + n) = 0 := by linear_combination hqnz
    have hcase : q = n ∨ q = -n := by
      rcases mul_eq_zero.mp hfacq with h | h
      · exact Or.inl (by omega)
      · exact Or.inr (by omega)
    rcases hcase with hc | hc
    · left
      constructor
      · have : m * q = n * p := hmq
        rw [hc] at this
        have hn' : n ≠ 0 := hn0
        have := mul_left_cancel₀ hn' (by linarith [this] : n * m = n * p)
        omega
      · exact hc
    · right
      constructor
      · have : m * q = n * p := hmq
        rw [hc] at this
        have hn' : n ≠ 0 := hn0
        have h2 : n * (-m) = n * p := by linarith [this]
        have := mul_left_cancel₀ hn' h2
        omega
      · omega

/-! ### Minkowski's second theorem -/

/-- Transport of the normalized squared length along the mapping class group, in the notation of
`latticeValue`. -/
theorem latticeValue_smul_index (g : SL(2, ℤ)) (tau : ℍ) (m n : ℤ) :
    latticeValue (g • tau) m n
      = latticeValue tau (m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1
            + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1)
          (m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0
            + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0) := by
  simpa [latticeValue] using normSq_ratio_smul g tau m n

/-- **Minkowski's second theorem for the lattice of a marked torus.**  Every marked torus has a
lattice basis whose first vector realizes the systole and whose two normalized squared lengths
have product at most `4/3`. -/
theorem exists_basis_second_le (tau : ℍ) :
    ∃ m n p q : ℤ, m * q - n * p = 1 ∧ latticeValue tau m n = sys tau ∧
      latticeValue tau m n * latticeValue tau p q ≤ 4 / 3 := by
  obtain ⟨g, hg⟩ := ModularGroup.exists_smul_mem_fd tau
  set w := g • tau with hw
  have hns : 1 ≤ Complex.normSq (w : ℂ) := hg.1
  have hre : |w.re| ≤ 1 / 2 := by simpa using hg.2
  have hy : 0 < w.im := w.im_pos
  have hy3 : Real.sqrt 3 / 2 ≤ w.im := sqrt_three_div_two_le_im_of_fd w hre hns
  have hy34 : 3 / 4 ≤ w.im ^ 2 := by
    have hs3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    nlinarith [Real.sqrt_nonneg 3]
  -- the two basis vectors of the fundamental domain
  set a := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 with ha
  set b := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 with hb
  set c := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 with hc
  set d := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 with hd
  have hdet : a * d - b * c = 1 := by
    have := g.property; rwa [Matrix.det_fin_two] at this
  have h10 : latticeValue tau d c = latticeValue w 1 0 := by
    have := latticeValue_smul_index g tau 1 0
    simpa [← ha, ← hb, ← hc, ← hd, hw] using this.symm
  have h01 : latticeValue tau b a = latticeValue w 0 1 := by
    have := latticeValue_smul_index g tau 0 1
    simpa [← ha, ← hb, ← hc, ← hd, hw] using this.symm
  have hsysw : sys w = 1 / w.im := sys_eq_one_div_im_of_fd w hre hns
  have hsystau : sys tau = 1 / w.im := by rw [← hsysw, hw, sys_smul]
  have hval10 : latticeValue w 1 0 = 1 / w.im := latticeValue_one_zero w
  have hval01 : latticeValue w 0 1 = Complex.normSq (w : ℂ) / w.im := by
    simp [latticeValue]
  refine ⟨d, c, b, a, by linarith [hdet], ?_, ?_⟩
  · rw [h10, hval10, hsystau]
  · rw [h10, h01, hval10, hval01]
    have hnsq : Complex.normSq (w : ℂ) = w.re ^ 2 + w.im ^ 2 := by
      rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
    have hre2 : w.re ^ 2 ≤ 1 / 4 := by
      nlinarith [abs_nonneg w.re, sq_abs w.re, hre]
    rw [hnsq, div_mul_div_comm, one_mul, div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith [hy34, hre2, hy]

/-- **The successive minima of a marked torus multiply into `[1, 4/3]`.** -/
theorem sys_mul_second_mem_Icc (tau : ℍ) :
    ∃ m n p q : ℤ, m * q - n * p = 1 ∧ latticeValue tau m n = sys tau ∧
      latticeValue tau m n * latticeValue tau p q ∈ Set.Icc (1 : ℝ) (4 / 3) := by
  obtain ⟨m, n, p, q, hbasis, hmin, hle⟩ := exists_basis_second_le tau
  refine ⟨m, n, p, q, hbasis, hmin, ?_, hle⟩
  exact one_le_latticeValue_mul tau (by rw [hbasis]; norm_num)

/-! ### Sharpness -/

/-- At the hexagonal torus the product of the successive minima is exactly `4/3`. -/
theorem second_minimum_rho :
    latticeValue rho 1 0 = sys rho ∧ latticeValue rho 1 0 * latticeValue rho 0 1 = 4 / 3 := by
  have hs3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs3pos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  have him : rho.im = Real.sqrt 3 / 2 := rho_im
  have hre : rho.re = -1 / 2 := rho_re
  have h10 : latticeValue rho 1 0 = 1 / rho.im := latticeValue_one_zero rho
  have h01 : latticeValue rho 0 1 = (rho.re ^ 2 + rho.im ^ 2) / rho.im := by
    rw [latticeValue, normSq_lattice_eq]
    norm_num
  constructor
  · rw [h10, him, sys_rho, one_div, inv_div]
  · rw [h10, h01, him, hre]
    field_simp
    nlinarith [hs3, hs3pos]

/-- On the imaginary axis above `i` the product of the successive minima is exactly `1`, so the
lower bound of Minkowski's second theorem is attained as well. -/
theorem second_minimum_cusp {Y : ℝ} (hY : 1 ≤ Y) :
    ∃ tau : ℍ, tau.im = Y ∧ latticeValue tau 1 0 = sys tau ∧
      latticeValue tau 1 0 * latticeValue tau 0 1 = 1 := by
  have hYpos : 0 < Y := lt_of_lt_of_le one_pos hY
  refine ⟨⟨⟨0, Y⟩, hYpos⟩, rfl, ?_, ?_⟩
  · have him : (⟨⟨0, Y⟩, hYpos⟩ : ℍ).im = Y := rfl
    rw [latticeValue_one_zero, sys_eq_one_div_im _ (by rw [him]; exact hY)]
  · have him : (⟨⟨0, Y⟩, hYpos⟩ : ℍ).im = Y := rfl
    have hre : (⟨⟨0, Y⟩, hYpos⟩ : ℍ).re = 0 := rfl
    rw [latticeValue_one_zero, latticeValue, normSq_lattice_eq, him, hre]
    norm_num
    field_simp

end Teichmuller