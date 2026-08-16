/-
# The second successive minimum as an invariant of the moduli space of tori

`Geometry.Teichmuller.SecondMinimum` proves the two bounds of Minkowski's second theorem in the
form "there exists a lattice basis with such and such lengths".  This file makes the second
successive minimum an honest *function* on Teichmüller space, in Minkowski's own formulation

    λ₂(τ) = inf { r : the vectors of normalized squared length ≤ r contain two independent ones },

proves that the infimum is attained, that `λ₂` is invariant under the mapping class group, and
that the pair `(sys, sys2)` satisfies the sharp two-sided estimate `1 ≤ sys · sys2 ≤ 4/3`.

Main results:

* `Teichmuller.exists_isLeast_independent` : for a fixed nonzero index vector, the shortest
  lattice vector independent of it exists (a second Mahler-type finiteness statement).
* `Teichmuller.sys2_isLeast`, `Teichmuller.exists_sys2_eq` : `sys2 τ` is attained, and it is
  attained *together with* the systole: there is a basis-like pair `(m, n)`, `(p, q)` of
  independent vectors realizing `sys τ` and `sys2 τ` simultaneously.
* `Teichmuller.sys_le_sys2` : the successive minima are ordered.
* `Teichmuller.sys2_smul` : `sys2` is a mapping class group invariant, hence a function on the
  moduli space.  The proof transports indices along the determinant-preserving substitution
  `(m, n) ↦ (m d + n b, m c + n a)` of `latticeValue_smul_index`, whose inverse is given by the
  same formula for `g⁻¹`.
* `Teichmuller.one_le_sys_mul_sys2`, `Teichmuller.sys_mul_sys2_le` : **Minkowski's second
  theorem for the invariant successive minima**, `1 ≤ sys τ · sys2 τ ≤ 4/3`.
* `Teichmuller.sys2_rho`, `Teichmuller.sys_mul_sys2_rho`, `Teichmuller.sys2_cusp` : the values
  at the hexagonal torus (`2/√3`, product `4/3`) and on the imaginary axis (`Y`, product `1`),
  so both bounds are attained by the invariant functionals as well.

-- !-- Lab Notes -- !--
Hypothesizer (E3): the product `sys · sys2` should be a second proper shape coordinate on the
moduli space, maximal exactly at the hexagonal point.
Experimenter: the delicate point is that Minkowski's definition of `λ₂` quantifies over *pairs*,
so a priori it need not be realized together with the systole.  It is: if `u₀` is a shortest
vector and `(a, b)` is any independent pair, then at least one of `a`, `b` is independent of
`u₀` — because `det(u₀, a) = det(u₀, b) = 0` forces `det(a, b) = 0` once `u₀ ≠ 0`.  This single
observation identifies `λ₂` with the shortest vector independent of `u₀` and makes
`1 ≤ λ₁ λ₂` a corollary of the determinant inequality.
Analyst: invariance is then formal but needs the *bijectivity* of the index substitution; the
inverse is exhibited explicitly (`exists_index_preimage`), and the determinant identity
`det (T u, T v) = det (u, v) · det g` is a polynomial identity in eight variables.
Critic: `sys2` is defined by an `sInf` over a set which must be shown nonempty and bounded below
for the infimum to mean anything — both are contained in `sys2_isLeast`, which exhibits the
infimum as a minimum.
-/
import Mathlib
import Geometry.Teichmuller.SecondMinimum

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups

/-! ### Independent vectors -/

/-- An index pair with nonvanishing determinant against `(m, n)` is nonzero. -/
theorem index_ne_zero_of_det {m n p q : ℤ} (h : m * q - n * p ≠ 0) : p ≠ 0 ∨ q ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  apply h
  rw [hcon.1, hcon.2]
  ring

/-- Every nonzero index vector admits an independent partner. -/
theorem exists_independent_index {m n : ℤ} (h : m ≠ 0 ∨ n ≠ 0) : ∃ p q : ℤ, m * q - n * p ≠ 0 := by
  rcases eq_or_ne m 0 with hm | hm
  · refine ⟨1, 0, ?_⟩
    rcases h with h' | h'
    · exact absurd hm h'
    · simpa [hm] using h'
  · exact ⟨0, 1, by simpa using hm⟩

/-- **The shortest independent vector exists.**  For a fixed nonzero index vector `(m, n)` the
set of normalized squared lengths of the lattice vectors independent of it has a least
element. -/
theorem exists_isLeast_independent (tau : ℍ) {m n : ℤ} (h : m ≠ 0 ∨ n ≠ 0) :
    ∃ p q : ℤ, m * q - n * p ≠ 0 ∧
      IsLeast {r : ℝ | ∃ p q : ℤ, m * q - n * p ≠ 0 ∧ r = latticeValue tau p q}
        (latticeValue tau p q) := by
  classical
  obtain ⟨p₀, q₀, hp₀⟩ := exists_independent_index h
  set C : ℝ := latticeValue tau p₀ q₀ * tau.im with hC
  set T : Set (ℤ × ℤ) :=
    {v : ℤ × ℤ | m * v.2 - n * v.1 ≠ 0 ∧ latticeValue tau v.1 v.2 ≤ latticeValue tau p₀ q₀}
    with hT
  have hTfin : T.Finite := by
    have hfin := finite_normSq_le tau C
    have hmap : (fun v : ℤ × ℤ => (![v.2, v.1] : Fin 2 → ℤ)) '' T ⊆
        {u : Fin 2 → ℤ | Complex.normSq ((u 0 : ℂ) * (tau : ℂ) + (u 1 : ℂ)) ≤ C} := by
      rintro _ ⟨⟨p, q⟩, hv, rfl⟩
      have hle : latticeValue tau p q ≤ latticeValue tau p₀ q₀ := hv.2
      have hnorm : Complex.normSq ((p : ℂ) + (q : ℂ) * (tau : ℂ)) ≤ C := by
        rw [latticeValue, div_le_iff₀ tau.im_pos] at hle
        exact hle
      simpa [Matrix.cons_val_zero, Matrix.cons_val_one, add_comm, mul_comm] using hnorm
    have hinj : Set.InjOn (fun v : ℤ × ℤ => (![v.2, v.1] : Fin 2 → ℤ)) T := by
      rintro ⟨p, q⟩ - ⟨p', q'⟩ - hfun
      have h0 : q = q' := by simpa using congrFun hfun 0
      have h1 : p = p' := by simpa using congrFun hfun 1
      simp [h0, h1]
    exact Set.Finite.of_finite_image (hfin.subset hmap) hinj
  have hTne : T.Nonempty := ⟨(p₀, q₀), ⟨hp₀, le_rfl⟩⟩
  obtain ⟨v₀, hv₀T, hv₀min⟩ :=
    Set.exists_min_image T (fun v : ℤ × ℤ => latticeValue tau v.1 v.2) hTfin hTne
  refine ⟨v₀.1, v₀.2, hv₀T.1, ⟨⟨v₀.1, v₀.2, hv₀T.1, rfl⟩, ?_⟩⟩
  rintro r ⟨p, q, hpq, rfl⟩
  by_cases hle : latticeValue tau p q ≤ latticeValue tau p₀ q₀
  · exact hv₀min (p, q) ⟨hpq, hle⟩
  · push_neg at hle
    exact le_trans hv₀T.2 hle.le

/-- If two vectors are independent of each other, at least one of them is independent of a given
nonzero vector. -/
theorem independent_of_pair {m n a b c d : ℤ} (hmn : m ≠ 0 ∨ n ≠ 0) (h : a * d - b * c ≠ 0) :
    m * b - n * a ≠ 0 ∨ m * d - n * c ≠ 0 := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨h1, h2⟩ := hcon
  apply h
  rcases hmn with hm | hn
  · have : m * (a * d - b * c) = 0 := by linear_combination a * h2 - c * h1
    rcases mul_eq_zero.mp this with h' | h'
    · exact absurd h' hm
    · exact h'
  · have : n * (a * d - b * c) = 0 := by linear_combination b * h2 - d * h1
    rcases mul_eq_zero.mp this with h' | h'
    · exact absurd h' hn
    · exact h'

/-! ### The second successive minimum -/

/-- The set of levels `r` at which the lattice vectors of normalized squared length at most `r`
already contain two independent vectors. -/
def secondSet (tau : ℍ) : Set ℝ :=
  {r : ℝ | ∃ m n p q : ℤ, m * q - n * p ≠ 0 ∧ latticeValue tau m n ≤ r ∧ latticeValue tau p q ≤ r}

/-- **The second successive minimum** of the lattice of a marked torus, in Minkowski's
formulation. -/
noncomputable def sys2 (tau : ℍ) : ℝ := sInf (secondSet tau)

/-- The second minimum is attained, and it is attained together with the systole: there are two
independent lattice vectors realizing `sys τ` and `sys2 τ`. -/
theorem exists_isLeast_sys2 (tau : ℍ) :
    ∃ m n p q : ℤ, m * q - n * p ≠ 0 ∧ latticeValue tau m n = sys tau ∧
      IsLeast (secondSet tau) (latticeValue tau p q) := by
  obtain ⟨m, n, hmn, hmin⟩ := exists_sys_eq tau
  obtain ⟨p, q, hpq, hleast⟩ := exists_isLeast_independent tau hmn
  refine ⟨m, n, p, q, hpq, hmin.symm, ⟨⟨m, n, p, q, hpq, ?_, le_rfl⟩, ?_⟩⟩
  · rw [← hmin]
    exact sys_le tau (index_ne_zero_of_det hpq)
  · rintro r ⟨a, b, c, d, hdet, hab, hcd⟩
    -- one of the two vectors of the pair is independent of `(m, n)`
    rcases independent_of_pair hmn hdet with hcase | hcase
    · exact le_trans (hleast.2 ⟨a, b, hcase, rfl⟩) hab
    · exact le_trans (hleast.2 ⟨c, d, hcase, rfl⟩) hcd

theorem sys2_isLeast (tau : ℍ) : IsLeast (secondSet tau) (sys2 tau) := by
  obtain ⟨m, n, p, q, hpq, hmin, hleast⟩ := exists_isLeast_sys2 tau
  rw [sys2, hleast.csInf_eq]
  exact hleast

/-- The systole and the second minimum are realized by two independent lattice vectors. -/
theorem exists_sys2_eq (tau : ℍ) :
    ∃ m n p q : ℤ, m * q - n * p ≠ 0 ∧ latticeValue tau m n = sys tau ∧
      latticeValue tau p q = sys2 tau := by
  obtain ⟨m, n, p, q, hpq, hmin, hleast⟩ := exists_isLeast_sys2 tau
  refine ⟨m, n, p, q, hpq, hmin, ?_⟩
  rw [sys2, hleast.csInf_eq]

theorem sys2_le {tau : ℍ} {r : ℝ} (h : r ∈ secondSet tau) : sys2 tau ≤ r :=
  (sys2_isLeast tau).2 h

/-- The successive minima are ordered: `sys τ ≤ sys2 τ`. -/
theorem sys_le_sys2 (tau : ℍ) : sys tau ≤ sys2 tau := by
  obtain ⟨m, n, p, q, hpq, hmin, hsecond⟩ := exists_sys2_eq tau
  rw [← hsecond]
  exact sys_le tau (index_ne_zero_of_det hpq)

theorem sys2_pos (tau : ℍ) : 0 < sys2 tau := lt_of_lt_of_le (sys_pos tau) (sys_le_sys2 tau)

/-! ### Minkowski's second theorem for the invariant minima -/

/-- **Lower bound.**  The product of the two successive minima of a unimodular planar lattice is
at least `1`. -/
theorem one_le_sys_mul_sys2 (tau : ℍ) : 1 ≤ sys tau * sys2 tau := by
  obtain ⟨m, n, p, q, hpq, hmin, hsecond⟩ := exists_sys2_eq tau
  rw [← hmin, ← hsecond]
  exact one_le_latticeValue_mul tau hpq

/-- **Upper bound.**  The product of the two successive minima is at most `4/3`, Hermite's
constant squared. -/
theorem sys_mul_sys2_le (tau : ℍ) : sys tau * sys2 tau ≤ 4 / 3 := by
  obtain ⟨m, n, p, q, hbasis, hmin, hle⟩ := exists_basis_second_le tau
  have hdet : m * q - n * p ≠ 0 := by rw [hbasis]; norm_num
  have hmem : latticeValue tau p q ∈ secondSet tau := by
    refine ⟨m, n, p, q, hdet, ?_, le_rfl⟩
    rw [hmin]
    exact sys_le tau (index_ne_zero_of_det hdet)
  have h2 : sys2 tau ≤ latticeValue tau p q := sys2_le hmem
  have hpos : 0 ≤ sys tau := (sys_pos tau).le
  calc sys tau * sys2 tau ≤ sys tau * latticeValue tau p q :=
        mul_le_mul_of_nonneg_left h2 hpos
    _ = latticeValue tau m n * latticeValue tau p q := by rw [hmin]
    _ ≤ 4 / 3 := hle

/-- **Minkowski's second theorem for the moduli space of tori.** -/
theorem sys_mul_sys2_mem_Icc (tau : ℍ) : sys tau * sys2 tau ∈ Set.Icc (1 : ℝ) (4 / 3) :=
  ⟨one_le_sys_mul_sys2 tau, sys_mul_sys2_le tau⟩

/-! ### Invariance under the mapping class group -/

/-- The index substitution induced by a mapping class is surjective: it is given by an integral
matrix of determinant one, with the inverse substitution written out explicitly. -/
theorem exists_index_preimage (g : SL(2, ℤ)) (M N : ℤ) :
    ∃ m n : ℤ, m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 = M
      ∧ m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0
          + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 = N := by
  set a := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 with ha
  set b := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 with hb
  set c := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 with hc
  set d := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 with hd
  have hdet : a * d - b * c = 1 := by
    have := g.property; rwa [Matrix.det_fin_two] at this
  refine ⟨a * M - b * N, d * N - c * M, ?_, ?_⟩
  · linear_combination M * hdet
  · linear_combination N * hdet

/-- The index substitution preserves the determinant of a pair of index vectors. -/
theorem index_det_smul (g : SL(2, ℤ)) (m n p q : ℤ) :
    (m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1)
        * (p * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 + q * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0)
      - (m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0)
        * (p * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 + q * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1)
      = m * q - n * p := by
  set a := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0 with ha
  set b := (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1 with hb
  set c := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 with hc
  set d := (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 with hd
  have hdet : a * d - b * c = 1 := by
    have := g.property; rwa [Matrix.det_fin_two] at this
  linear_combination (m * q - n * p) * hdet

theorem secondSet_smul (g : SL(2, ℤ)) (tau : ℍ) : secondSet (g • tau) = secondSet tau := by
  ext r
  constructor
  · rintro ⟨m, n, p, q, hdet, h1, h2⟩
    refine ⟨m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1,
      m * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 + n * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0,
      p * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 1 + q * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 1,
      p * (g : Matrix (Fin 2) (Fin 2) ℤ) 1 0 + q * (g : Matrix (Fin 2) (Fin 2) ℤ) 0 0,
      ?_, ?_, ?_⟩
    · rw [index_det_smul g m n p q]; exact hdet
    · rw [← latticeValue_smul_index g tau m n]; exact h1
    · rw [← latticeValue_smul_index g tau p q]; exact h2
  · rintro ⟨M, N, P, Q, hdet, h1, h2⟩
    obtain ⟨m, n, hm, hn⟩ := exists_index_preimage g M N
    obtain ⟨p, q, hp, hq⟩ := exists_index_preimage g P Q
    refine ⟨m, n, p, q, ?_, ?_, ?_⟩
    · rw [← index_det_smul g m n p q, hm, hn, hp, hq]; exact hdet
    · rw [latticeValue_smul_index g tau m n, hm, hn]; exact h1
    · rw [latticeValue_smul_index g tau p q, hp, hq]; exact h2

/-- **The second successive minimum is a function on the moduli space.** -/
theorem sys2_smul (g : SL(2, ℤ)) (tau : ℍ) : sys2 (g • tau) = sys2 tau := by
  rw [sys2, sys2, secondSet_smul g tau]

/-! ### Values, and sharpness of both bounds -/

/-- At the hexagonal torus the second minimum equals the systole, `2/√3`. -/
theorem sys2_rho : sys2 rho = 2 / Real.sqrt 3 := by
  have hs3pos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  obtain ⟨hmin, hprod⟩ := second_minimum_rho
  have hlow : 2 / Real.sqrt 3 ≤ sys2 rho := by
    have := sys_le_sys2 rho
    rwa [sys_rho] at this
  refine le_antisymm ?_ hlow
  have hmem : latticeValue rho 0 1 ∈ secondSet rho := by
    refine ⟨1, 0, 0, 1, by norm_num, ?_, le_rfl⟩
    rw [hmin]
    exact sys_le rho (Or.inr one_ne_zero)
  have hval : latticeValue rho 0 1 = 2 / Real.sqrt 3 := by
    have hs : latticeValue rho 1 0 = 2 / Real.sqrt 3 := by rw [hmin, sys_rho]
    rw [hs] at hprod
    field_simp at hprod ⊢
    nlinarith [hprod, hs3pos, Real.sq_sqrt (show (0:ℝ) ≤ 3 by norm_num)]
  rw [← hval]
  exact sys2_le hmem

/-- The product of the successive minima attains the upper bound `4/3` at the hexagonal
torus. -/
theorem sys_mul_sys2_rho : sys rho * sys2 rho = 4 / 3 := by
  have hs3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs3pos : 0 < Real.sqrt 3 := Real.sqrt_pos.mpr (by norm_num)
  rw [sys_rho, sys2_rho]
  field_simp
  nlinarith [hs3, hs3pos]

/-- On the imaginary axis above `i` the second minimum equals `Im τ`, so the product of the
successive minima attains the lower bound `1`. -/
theorem sys2_cusp {Y : ℝ} (hY : 1 ≤ Y) (hYpos : 0 < Y) :
    sys2 (⟨⟨0, Y⟩, hYpos⟩ : ℍ) = Y ∧
      sys (⟨⟨0, Y⟩, hYpos⟩ : ℍ) * sys2 (⟨⟨0, Y⟩, hYpos⟩ : ℍ) = 1 := by
  set tau : ℍ := ⟨⟨0, Y⟩, hYpos⟩ with htau
  have him : tau.im = Y := rfl
  have hre : tau.re = 0 := rfl
  have hsys : sys tau = 1 / Y := by
    rw [sys_eq_one_div_im tau (by rw [him]; exact hY), him]
  have hval01 : latticeValue tau 0 1 = Y := by
    rw [latticeValue, normSq_lattice_eq, him, hre]
    norm_num
    field_simp
  have hval10 : latticeValue tau 1 0 = 1 / Y := by
    rw [latticeValue_one_zero, him]
  have hupper : sys2 tau ≤ Y := by
    have hmem : latticeValue tau 0 1 ∈ secondSet tau := by
      refine ⟨1, 0, 0, 1, by norm_num, ?_, le_rfl⟩
      rw [hval10, hval01]
      rw [div_le_iff₀ hYpos]
      nlinarith
    rw [← hval01]
    exact sys2_le hmem
  have hlower : Y ≤ sys2 tau := by
    have h1 := one_le_sys_mul_sys2 tau
    rw [hsys] at h1
    have h2 : Y * 1 ≤ Y * (1 / Y * sys2 tau) := mul_le_mul_of_nonneg_left h1 hYpos.le
    have h3 : Y * (1 / Y * sys2 tau) = sys2 tau := by field_simp
    linarith [h2, h3]
  refine ⟨le_antisymm hupper hlower, ?_⟩
  rw [hsys, le_antisymm hupper hlower]
  field_simp

/-! ### The hexagonal torus is the unique maximizer of the successive minima -/

/-- Inside the standard fundamental domain, every lattice vector with nonzero second index is at
least as long as the vector `τ` itself. -/
theorem latticeValue_ge_of_snd_ne_zero (w : ℍ) (hre : |w.re| ≤ 1 / 2)
    (hns : 1 ≤ Complex.normSq (w : ℂ)) {p q : ℤ} (hq : q ≠ 0) :
    Complex.normSq (w : ℂ) / w.im ≤ latticeValue w p q := by
  have hy : 0 < w.im := w.im_pos
  have hy3 : Real.sqrt 3 / 2 ≤ w.im := sqrt_three_div_two_le_im_of_fd w hre hns
  have hy34 : 3 / 4 ≤ w.im ^ 2 := by
    have hs3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    nlinarith [Real.sqrt_nonneg 3]
  have hnsq : Complex.normSq (w : ℂ) = w.re ^ 2 + w.im ^ 2 := by
    rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
  have hx2 : w.re ^ 2 ≤ 1 / 4 := by
    nlinarith [abs_nonneg w.re, sq_abs w.re]
  rw [latticeValue, normSq_lattice_eq, hnsq]
  have hnum : w.re ^ 2 + w.im ^ 2
      ≤ ((p : ℝ) + (q : ℝ) * w.re) ^ 2 + ((q : ℝ) * w.im) ^ 2 := by
    have habs : (1 : ℤ) ≤ |q| := Int.one_le_abs hq
    rcases eq_or_lt_of_le habs with h1 | h2
    · -- `|q| = 1`
      have hq2 : (q : ℝ) ^ 2 = 1 := by
        have : q ^ 2 = 1 := by rw [← sq_abs, ← h1]; ring
        exact_mod_cast congrArg (fun t : ℤ => (t : ℝ)) this
      have hqabs : |(q : ℝ)| = 1 := by
        have h0 : (0 : ℝ) ≤ |(q : ℝ)| := abs_nonneg _
        nlinarith [sq_abs ((q : ℝ)), hq2, h0]
      rcases eq_or_ne p 0 with hp | hp
      · rw [hp]
        push_cast
        nlinarith [hq2]
      · have hp1 : (1 : ℤ) ≤ |p| := Int.one_le_abs hp
        have hp1R : (1 : ℝ) ≤ |(p : ℝ)| := by
          have := (Int.cast_le (R := ℝ)).mpr hp1
          rwa [Int.cast_abs, Int.cast_one] at this
        have hcross : -(|(p : ℝ)|) ≤ 2 * (p : ℝ) * (q : ℝ) * w.re := by
          have hb : |2 * (p : ℝ) * (q : ℝ) * w.re| ≤ |(p : ℝ)| := by
            have he : |2 * (p : ℝ) * (q : ℝ) * w.re|
                = 2 * (|(p : ℝ)| * |(q : ℝ)|) * |w.re| := by
              rw [abs_mul, abs_mul, abs_mul, abs_two]; ring
            rw [he, hqabs, mul_one]
            nlinarith [abs_nonneg ((p : ℝ)), abs_nonneg w.re, hre]
          linarith [neg_abs_le (2 * (p : ℝ) * (q : ℝ) * w.re)]
        nlinarith [hq2, hp1R, sq_abs ((p : ℝ)), abs_nonneg ((p : ℝ)), hcross]
    · -- `|q| ≥ 2`
      have hq4 : (4 : ℝ) ≤ (q : ℝ) ^ 2 := by
        have h4 : (4 : ℤ) ≤ q ^ 2 := by
          have h2' : (2 : ℤ) ≤ |q| := h2
          nlinarith [sq_abs q]
        exact_mod_cast (Int.cast_le (R := ℝ)).mpr h4
      nlinarith [sq_nonneg ((p : ℝ) + (q : ℝ) * w.re), hq4, hx2, hy34, hy]
  gcongr

/-- **The second minimum in the fundamental domain.**  For `w ∈ 𝒟` the shortest lattice vector
independent of the horizontal one is `w` itself, so `sys2 w = |w|² / Im w`. -/
theorem sys2_eq_of_fd (w : ℍ) (hre : |w.re| ≤ 1 / 2) (hns : 1 ≤ Complex.normSq (w : ℂ)) :
    sys2 w = Complex.normSq (w : ℂ) / w.im := by
  have hy : 0 < w.im := w.im_pos
  have hval01 : latticeValue w 0 1 = Complex.normSq (w : ℂ) / w.im := by
    simp [latticeValue]
  have hval10 : latticeValue w 1 0 = 1 / w.im := latticeValue_one_zero w
  refine le_antisymm ?_ ?_
  · have hmem : Complex.normSq (w : ℂ) / w.im ∈ secondSet w := by
      refine ⟨1, 0, 0, 1, by norm_num, ?_, le_of_eq hval01⟩
      rw [hval10]
      exact div_le_div_of_nonneg_right hns hy.le
    exact sys2_le hmem
  · refine le_csInf ⟨_, (sys2_isLeast w).1⟩ ?_
    rintro r ⟨m, n, p, q, hdet, h1, h2⟩
    rcases eq_or_ne n 0 with hn | hn
    · have hq : q ≠ 0 := by
        intro hq0
        apply hdet
        rw [hn, hq0]; ring
      exact le_trans (latticeValue_ge_of_snd_ne_zero w hre hns hq) h2
    · exact le_trans (latticeValue_ge_of_snd_ne_zero w hre hns hn) h1

/-- **E3a.**  In the fundamental domain the product of the successive minima is
`|w|² / (Im w)²`. -/
theorem sys_mul_sys2_of_fd (w : ℍ) (hre : |w.re| ≤ 1 / 2) (hns : 1 ≤ Complex.normSq (w : ℂ)) :
    sys w * sys2 w = Complex.normSq (w : ℂ) / w.im ^ 2 := by
  have hy : 0 < w.im := w.im_pos
  rw [sys_eq_one_div_im_of_fd w hre hns, sys2_eq_of_fd w hre hns]
  field_simp

/-- **The hexagonal torus is the unique maximizer.**  The product of the successive minima equals
`4/3` exactly on the mapping class group orbit of `ρ`. -/
theorem sys_mul_sys2_eq_four_thirds_iff (tau : ℍ) :
    sys tau * sys2 tau = 4 / 3 ↔ ∃ g : SL(2, ℤ), g • tau = rho := by
  constructor
  · intro hprod
    obtain ⟨g, hg⟩ := ModularGroup.exists_smul_mem_fd tau
    set w := g • tau with hw
    have hns : 1 ≤ Complex.normSq (w : ℂ) := hg.1
    have hre : |w.re| ≤ 1 / 2 := by simpa using hg.2
    have hy : 0 < w.im := w.im_pos
    have hinv : sys w * sys2 w = 4 / 3 := by
      rw [hw, sys_smul, sys2_smul]; exact hprod
    rw [sys_mul_sys2_of_fd w hre hns] at hinv
    have hnsq : Complex.normSq (w : ℂ) = w.re ^ 2 + w.im ^ 2 := by
      rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
    rw [hnsq, div_eq_iff (by positivity)] at hinv
    have hx2 : w.re ^ 2 ≤ 1 / 4 := by nlinarith [abs_nonneg w.re, sq_abs w.re]
    have hnsq1 : 1 ≤ w.re ^ 2 + w.im ^ 2 := by rw [← hnsq]; exact hns
    have hy2 : w.im ^ 2 = 3 / 4 := by nlinarith
    have hx2' : w.re ^ 2 = 1 / 4 := by nlinarith
    have hs3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    have hyval : w.im = Real.sqrt 3 / 2 := by
      have h1 : (Real.sqrt 3 / 2) ^ 2 = w.im ^ 2 := by rw [hy2]; nlinarith
      have h2 : 0 < Real.sqrt 3 / 2 := by positivity
      nlinarith [h1, h2, hy]
    have hxval : w.re = 1 / 2 ∨ w.re = -1 / 2 := by
      have : (w.re - 1 / 2) * (w.re + 1 / 2) = 0 := by nlinarith
      rcases mul_eq_zero.mp this with h | h
      · exact Or.inl (by linarith)
      · exact Or.inr (by linarith)
    rcases hxval with hx | hx
    · -- `w = ρ + 1 = T • ρ`
      refine ⟨ModularGroup.T⁻¹ * g, ?_⟩
      have hwT : w = ModularGroup.T • rho := by
        apply UpperHalfPlane.ext
        rw [UpperHalfPlane.modular_T_smul]
        have h1 : (((1 : ℝ) +ᵥ rho : ℍ) : ℂ) = (rho : ℂ) + 1 := by
          simp [UpperHalfPlane.coe_vadd]; ring
        rw [h1]
        apply Complex.ext
        · simp
          rw [rho_re, hx]; norm_num
        · simp
          rw [rho_im, hyval]
      rw [SemigroupAction.mul_smul, ← hw, hwT, inv_smul_smul]
    · -- `w = ρ`
      refine ⟨g, ?_⟩
      rw [← hw]
      apply UpperHalfPlane.ext
      apply Complex.ext
      · simpa [rho_re] using hx
      · simpa [rho_im] using hyval
  · rintro ⟨g, hg⟩
    have h1 : sys tau = sys rho := by rw [← hg, sys_smul]
    have h2 : sys2 tau = sys2 rho := by rw [← hg, sys2_smul]
    rw [h1, h2]
    exact sys_mul_sys2_rho

/-- **The rectangular locus is exactly the minimum locus.**  The product of the successive minima
equals `1` precisely for the tori that are equivalent to a rectangular one `i Y` with `Y ≥ 1`. -/
theorem sys_mul_sys2_eq_one_iff (tau : ℍ) :
    sys tau * sys2 tau = 1 ↔ ∃ g : SL(2, ℤ), (g • tau).re = 0 ∧ 1 ≤ (g • tau).im := by
  constructor
  · intro hprod
    obtain ⟨g, hg⟩ := ModularGroup.exists_smul_mem_fd tau
    set w := g • tau with hw
    have hns : 1 ≤ Complex.normSq (w : ℂ) := hg.1
    have hre : |w.re| ≤ 1 / 2 := by simpa using hg.2
    have hy : 0 < w.im := w.im_pos
    have hinv : sys w * sys2 w = 1 := by
      rw [hw, sys_smul, sys2_smul]; exact hprod
    rw [sys_mul_sys2_of_fd w hre hns] at hinv
    have hnsq : Complex.normSq (w : ℂ) = w.re ^ 2 + w.im ^ 2 := by
      rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
    rw [hnsq, div_eq_iff (by positivity)] at hinv
    have hx0 : w.re = 0 := by nlinarith [sq_nonneg w.re]
    refine ⟨g, hx0, ?_⟩
    have h1 : 1 ≤ w.im ^ 2 := by
      rw [hnsq, hx0] at hns; nlinarith
    nlinarith
  · rintro ⟨g, hx0, hy1⟩
    set w := g • tau with hw
    have hy : 0 < w.im := w.im_pos
    have hns : 1 ≤ Complex.normSq (w : ℂ) := by
      have hnsq : Complex.normSq (w : ℂ) = w.re ^ 2 + w.im ^ 2 := by
        rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
      rw [hnsq, hx0]
      nlinarith
    have hre : |w.re| ≤ 1 / 2 := by rw [hx0]; norm_num
    have hinv : sys w * sys2 w = 1 := by
      rw [sys_mul_sys2_of_fd w hre hns]
      have hnsq : Complex.normSq (w : ℂ) = w.re ^ 2 + w.im ^ 2 := by
        rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
      rw [hnsq, hx0]
      rw [div_eq_one_iff_eq (by positivity)]
      ring
    rw [hw, sys_smul, sys2_smul] at hinv
    exact hinv

end Teichmuller