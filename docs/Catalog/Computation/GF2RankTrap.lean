import Mathlib

/-!
# Round 42, item 6: the `𝔽₂`-rank trap, and which test matrices can catch it

Round 42 found that two library routines silently returned the rank over `ℚ`
when asked for the rank over `GF(2)` (returning `3` on a matrix of `𝔽₂`-rank `2`),
and that "validation passed" was unfalsifiable until a mutation test was added.
This file makes both observations exact.

* `rank_eq_card_iff_det_ne_zero` — over any field, a square matrix has full rank
  iff its determinant is nonzero.
* `rank_zmod2_full_iff_odd_det` / `rank_rat_full_iff_det_ne_zero` — for an
  integer matrix `A`, full `𝔽₂`-rank ⇔ `det A` odd; full `ℚ`-rank ⇔ `det A ≠ 0`.
* `full_rank_agree_iff` — **the discriminating-test criterion**: a square integer
  test matrix can distinguish a "rank over `ℚ`" instrument from a correct
  "rank over `𝔽₂`" one *on the full-rank question* iff `det A` is a **nonzero even**
  integer.  A validation suite built from matrices with odd (or zero) determinant
  is blind to the bug, which is why the bug survived inspection.
* `trap3_rank_rat` / `trap3_rank_zmod2` — the round-42 witness: the `3 × 3`
  cycle-incidence matrix has `ℚ`-rank `3` and `𝔽₂`-rank `2`.
* `rank_submatrix_le_of_field` — rank does not increase under taking an arbitrary
  submatrix (rows and columns), the tool used for the lower bound.
* `linearIndependent_int_of_zmod2` — independence mod 2 lifts to independence
  over `ℤ` (a 2-adic descent: a relation with all coefficients even halves).
* `rank_zmod2_le_rank_rat` — **one-sided error**: for every integer matrix,
  `rank_{𝔽₂} ≤ rank_ℚ`.  A `ℚ`-instrument can only *over*-report the `𝔽₂`-rank,
  hence only *under*-report the null space — exactly the failure mode in which a
  QS reports "no dependency yet" while one exists.
-/

namespace GF2RankTrap

open Matrix

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- Over a field, full rank is equivalent to a nonzero determinant. -/
theorem rank_eq_card_iff_det_ne_zero {F : Type*} [Field F] (A : Matrix n n F) :
    A.rank = Fintype.card n ↔ A.det ≠ 0 := by
  constructor
  · intro h hdet
    obtain ⟨v, hv0, hv⟩ := Matrix.exists_mulVec_eq_zero_iff.2 hdet
    have htop : LinearMap.range A.mulVecLin = ⊤ := by
      apply Submodule.eq_top_of_finrank_eq
      rw [Module.finrank_fintype_fun_eq_card]
      exact h
    have hsurj : Function.Surjective A.mulVecLin := LinearMap.range_eq_top.1 htop
    have hinj : Function.Injective A.mulVecLin :=
      LinearMap.injective_iff_surjective.2 hsurj
    apply hv0
    apply hinj
    simp [hv]
  · intro h
    exact A.rank_of_isUnit ((Matrix.isUnit_iff_isUnit_det A).2 (isUnit_iff_ne_zero.2 h))

/-- `𝔽₂`-full rank of an integer matrix is oddness of its determinant. -/
theorem rank_zmod2_full_iff_odd_det (A : Matrix n n ℤ) :
    (A.map (Int.castRingHom (ZMod 2))).rank = Fintype.card n ↔ Odd A.det := by
  have hdet : (A.map (Int.castRingHom (ZMod 2))).det = ((A.det : ℤ) : ZMod 2) := by
    rw [show A.map (Int.castRingHom (ZMod 2)) = (Int.castRingHom (ZMod 2)).mapMatrix A
      from rfl, ← RingHom.map_det]
    simp
  rw [rank_eq_card_iff_det_ne_zero, hdet, ← Int.not_even_iff_odd, Ne,
    ZMod.intCast_zmod_eq_zero_iff_dvd, even_iff_two_dvd]
  norm_num

/-- `ℚ`-full rank of an integer matrix is nonvanishing of its determinant. -/
theorem rank_rat_full_iff_det_ne_zero (A : Matrix n n ℤ) :
    (A.map (Int.castRingHom ℚ)).rank = Fintype.card n ↔ A.det ≠ 0 := by
  have hdet : (A.map (Int.castRingHom ℚ)).det = ((A.det : ℤ) : ℚ) := by
    rw [show A.map (Int.castRingHom ℚ) = (Int.castRingHom ℚ).mapMatrix A
      from rfl, ← RingHom.map_det]
    simp
  rw [rank_eq_card_iff_det_ne_zero, hdet]
  exact_mod_cast Iff.rfl

/-- **Discriminating-test criterion.**  The `ℚ`-instrument and the `𝔽₂`-instrument
agree on whether a square integer matrix has full rank *unless and only unless*
its determinant is a nonzero even integer. -/
theorem full_rank_agree_iff (A : Matrix n n ℤ) :
    ((A.map (Int.castRingHom ℚ)).rank = Fintype.card n ↔
      (A.map (Int.castRingHom (ZMod 2))).rank = Fintype.card n) ↔
      ¬ (A.det ≠ 0 ∧ Even A.det) := by
  rw [rank_rat_full_iff_det_ne_zero, rank_zmod2_full_iff_odd_det, ← Int.not_even_iff_odd]
  by_cases h0 : A.det = 0
  · simp [h0]
  · by_cases he : Even A.det <;> simp [h0, he]

/-- The `𝔽₂`-rank of an integer matrix never exceeds the size, and is full only
when the `ℚ`-rank is full (a nonzero even determinant drops only the `𝔽₂`-rank). -/
theorem rat_full_of_zmod2_full (A : Matrix n n ℤ)
    (h : (A.map (Int.castRingHom (ZMod 2))).rank = Fintype.card n) :
    (A.map (Int.castRingHom ℚ)).rank = Fintype.card n := by
  rw [rank_zmod2_full_iff_odd_det] at h
  rw [rank_rat_full_iff_det_ne_zero]
  rintro h0; rw [h0] at h; exact absurd h (by decide)

/-- Rank does not increase under taking an arbitrary submatrix. -/
theorem rank_submatrix_le_of_field {F : Type*} [Field F] {m k r : Type*}
    [Fintype m] [Fintype k] [Fintype r] (A : Matrix m m F) (f : k → m) (g : r → m) :
    (A.submatrix f g).rank ≤ A.rank := by
  have h1 : (A.submatrix f (Equiv.refl m)).rank ≤ A.rank := rank_submatrix_le f _ A
  have h2 : ((A.submatrix f (Equiv.refl m))ᵀ.submatrix g (Equiv.refl k)).rank ≤
      (A.submatrix f (Equiv.refl m))ᵀ.rank := rank_submatrix_le g _ _
  have h3 : (A.submatrix f g) = ((A.submatrix f (Equiv.refl m))ᵀ.submatrix g
      (Equiv.refl k))ᵀ := by
    ext i j; rfl
  rw [h3, rank_transpose]
  rw [rank_transpose] at h2
  exact h2.trans h1

/-! ## The round-42 witness -/

/-- The `3 × 3` cycle-incidence matrix: rows are the edges of a triangle. -/
def trap3 : Matrix (Fin 3) (Fin 3) ℤ := !![1, 1, 0; 0, 1, 1; 1, 0, 1]

theorem trap3_det : trap3.det = 2 := by
  simp [trap3, Matrix.det_fin_three]

/-- Over `ℚ` the witness has rank `3`. -/
theorem trap3_rank_rat : (trap3.map (Int.castRingHom ℚ)).rank = 3 := by
  have := (rank_rat_full_iff_det_ne_zero trap3).2 (by rw [trap3_det]; norm_num)
  simpa using this

/-- Over `𝔽₂` the same witness has rank `2` — the value a correct instrument
must return and a `ℚ`-instrument does not. -/
theorem trap3_rank_zmod2 : (trap3.map (Int.castRingHom (ZMod 2))).rank = 2 := by
  set A := trap3.map (Int.castRingHom (ZMod 2)) with hA
  have hlt : A.rank ≠ 3 := by
    intro h
    have h' : A.rank = Fintype.card (Fin 3) := by simpa using h
    rw [hA, rank_zmod2_full_iff_odd_det, trap3_det] at h'
    exact absurd h' (by decide)
  have hle : A.rank ≤ 3 := by simpa using A.rank_le_card_width
  have hsub : (A.submatrix (fun i : Fin 2 => (Fin.castSucc i))
      (fun j : Fin 2 => (Fin.castSucc j))).rank = 2 := by
    have : (A.submatrix (fun i : Fin 2 => (Fin.castSucc i))
        (fun j : Fin 2 => (Fin.castSucc j))).det ≠ 0 := by
      rw [Matrix.det_fin_two]
      simp [hA, trap3]
    simpa using (rank_eq_card_iff_det_ne_zero _).2 this
  have hge := rank_submatrix_le_of_field A (fun i : Fin 2 => (Fin.castSucc i))
    (fun j : Fin 2 => (Fin.castSucc j))
  omega

/-- The witness is discriminating, as the criterion predicts (`det = 2`). -/
theorem trap3_discriminates :
    ¬ ((trap3.map (Int.castRingHom ℚ)).rank = Fintype.card (Fin 3) ↔
      (trap3.map (Int.castRingHom (ZMod 2))).rank = Fintype.card (Fin 3)) := by
  rw [full_rank_agree_iff, trap3_det]
  simp

/-! ## The error is one-sided -/

/-- Independence mod 2 lifts to independence over `ℤ`. -/
theorem linearIndependent_int_of_zmod2 {ι m : Type*} [Fintype ι]
    (v : ι → m → ℤ)
    (h : LinearIndependent (ZMod 2) (fun i => fun k => ((v i k : ℤ) : ZMod 2))) :
    LinearIndependent ℤ v := by
  rw [Fintype.linearIndependent_iff] at h ⊢
  have key : ∀ e : ℕ, ∀ g : ι → ℤ, ∑ i, g i • v i = 0 → ∀ i, (2 : ℤ) ^ e ∣ g i := by
    intro e
    induction e with
    | zero => intro g _ i; simp
    | succ e ih =>
      intro g hg i
      have heven : ∀ j, (2 : ℤ) ∣ g j := by
        intro j
        have h2 := h (fun j => (g j : ZMod 2)) (by
          funext k
          have := congrFun hg k
          simp only [Finset.sum_apply, Pi.smul_apply, smul_eq_mul, Pi.zero_apply] at this ⊢
          have := congrArg (Int.cast : ℤ → ZMod 2) this
          push_cast at this
          exact this) j
        exact (ZMod.intCast_zmod_eq_zero_iff_dvd (g j) 2).1 h2
      choose g' hg' using heven
      have hrel : ∑ j, g' j • v j = 0 := by
        have h2 : (2 : ℤ) • ∑ j, g' j • v j = 0 := by
          rw [← hg, Finset.smul_sum]
          refine Finset.sum_congr rfl (fun j _ => ?_)
          rw [hg' j, SemigroupAction.mul_smul]
        funext k
        have := congrFun h2 k
        simp only [Pi.smul_apply, smul_eq_mul, Pi.zero_apply] at this ⊢
        omega
      obtain ⟨c, hc⟩ := ih g' hrel i
      exact ⟨c, by rw [hg' i, hc]; ring⟩
  intro g hg i
  have hd := key (g i).natAbs g hg i
  by_contra hne
  have hd' : 2 ^ (g i).natAbs ∣ (g i).natAbs := by
    have := Int.natAbs_dvd_natAbs.2 hd
    simpa [Int.natAbs_pow] using this
  have h1 := Nat.le_of_dvd (Int.natAbs_pos.2 hne) hd'
  have h2 : (g i).natAbs < 2 ^ (g i).natAbs := Nat.lt_two_pow_self
  omega

/-- **One-sided error.**  For every integer matrix, the `𝔽₂`-rank is at most the
`ℚ`-rank: an instrument that silently returns the `ℚ`-rank can only
*overestimate* the `𝔽₂`-rank. -/
theorem rank_zmod2_le_rank_rat {m n : Type*} [Fintype n] (A : Matrix m n ℤ) :
    (A.map (Int.castRingHom (ZMod 2))).rank ≤ (A.map (Int.castRingHom ℚ)).rank := by
  classical
  rw [rank_eq_finrank_span_cols, rank_eq_finrank_span_cols]
  obtain ⟨κ, a, ha, hspan, hli⟩ :=
    exists_linearIndependent' (ZMod 2) (A.map (Int.castRingHom (ZMod 2))).col
  have : Finite κ := Finite.of_injective a ha
  have : Fintype κ := Fintype.ofFinite κ
  rw [← hspan, finrank_span_eq_card hli]
  have hZ : LinearIndependent ℤ (fun k => A.col (a k)) :=
    linearIndependent_int_of_zmod2 _ hli
  set f : (m → ℤ) →ₗ[ℤ] (m → ℚ) := (Int.castAddHom ℚ).toIntLinearMap.compLeft m with hf
  have hfinj : LinearMap.ker f = ⊥ := by
    rw [LinearMap.ker_eq_bot]
    intro x y hxy
    funext i
    have := congrFun hxy i
    simpa [hf] using this
  have hZQ : LinearIndependent ℤ (f ∘ fun k => A.col (a k)) := hZ.map' f hfinj
  have hQ : LinearIndependent ℚ (fun k => (A.map (Int.castRingHom ℚ)).col (a k)) := by
    rw [← LinearIndependent.iff_fractionRing ℤ ℚ]
    exact hZQ
  rw [← finrank_span_eq_card hQ]
  haveI : FiniteDimensional ℚ
      (Submodule.span ℚ (Set.range (A.map (Int.castRingHom ℚ)).col)) :=
    FiniteDimensional.span_of_finite ℚ (Set.finite_range _)
  apply Submodule.finrank_mono
  apply Submodule.span_mono
  rintro _ ⟨k, rfl⟩
  exact ⟨a k, rfl⟩

end GF2RankTrap