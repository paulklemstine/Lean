import Applications.AdjacentSumPolytopes.SecantSpectrum

/-!
# Discrete-sine orthogonality and the closed form for the open counts

The eigenvectors `v_t(j) = sin((s+1-j)θ_t)`, `θ_t = (2t+1)π/(2s+3)`, of the adjacent-sum
transfer matrix form a *discrete sine transform* of the "DST-III" type.  Here we prove
their orthogonality relation

`∑_{t=0}^{s} sin(a θ_t) sin(b θ_t) = (2s+3)/4 · [a = b]`  (`1 ≤ a, b ≤ s+1`)

and deduce

* `AdjSum.secEigmat_mul_transpose` : `B Bᵀ = ((2s+3)/4) • 1`, an explicit inverse for the
  eigenvector matrix;
* `AdjSum.card_openSet_eq_sum` : the number of *open* adjacent-sum lattice points of
  length `d + 1` equals `(1/(2s+3)) ∑_t λ_t^d cot²(θ_t/2)`.

-- !-- Lab Notes -- !--
* **Hypothesis.** `B Bᵀ` should be a scalar matrix (the discrete sine transform is, up to
  scaling, an involution), giving a *closed form* for the open counts as well as the
  cyclic ones.
* **Experiment.** `s = 1`, `d = 1`: `(1/5)(1.618 · cot²(π/10) − 0.618 · cot²(3π/10))
  = (1/5)(15.325 − 0.326) = 3`, matching `#openSet 1 1 = 3`
  (`(0,0), (0,1), (1,0)`).  `d = 0` gives `(1/5)(9.472 + 0.528) = 2 = s + 1`.
* **Analysis.** Everything reduces to one geometric identity, `∑_{t<n} cos((2t+1)φ)`,
  which telescopes against `2 sin φ`, exactly as the sine sum did for the eigenvectors.
  The quantisation `2(s+1)φ = mπ − φ` converts the telescoped boundary into the sign
  `−(−1)^m/2`; the two cases `a = b` and `a ≠ b` of the orthogonality relation are the
  cases `m ≡ 0` and `m ≢ 0` of that sign.
* **Critique.** The `a ≠ b` case genuinely needs `a + b` and `a − b` to have equal parity;
  without it the two cosine sums would not cancel, and the transform would not be
  orthogonal.  The hypotheses `1 ≤ a, b ≤ s+1` are sharp: for `a = 0` the "eigenvector"
  is zero.
-/

namespace AdjSum

open Finset Matrix

noncomputable section

/-- Two natural numbers of equal parity give the same power of `-1`. -/
lemma neg_one_pow_eq_of_even_add {m n : ℕ} (h : Even (m + n)) :
    ((-1 : ℝ)) ^ m = ((-1 : ℝ)) ^ n := by
  have hiff := Nat.even_add.mp h
  rcases Nat.even_or_odd m with hm | hm
  · rw [hm.neg_one_pow, (hiff.mp hm).neg_one_pow]
  · have hn : Odd n := by
      rw [← Nat.not_even_iff_odd] at hm ⊢
      exact fun hn => hm (hiff.mpr hn)
    rw [hm.neg_one_pow, hn.neg_one_pow]

/-! ### A telescoped sum of cosines -/

/-- Telescoping partial sums of cosines at odd multiples:
`2 sin φ ∑_{t<n} cos((2t+1)φ) = sin(2nφ)`. -/
theorem two_sin_mul_sum_cos (φ : ℝ) (n : ℕ) :
    2 * Real.sin φ * ∑ t ∈ Finset.range n, Real.cos ((2 * (t : ℝ) + 1) * φ)
      = Real.sin (2 * n * φ) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, mul_add, ih]
      have key : 2 * Real.sin φ * Real.cos ((2 * (n : ℝ) + 1) * φ)
          = Real.sin (2 * ((n : ℝ) + 1) * φ) - Real.sin (2 * (n : ℝ) * φ) := by
        rw [Real.sin_sub_sin]
        have h1 : (2 * ((n : ℝ) + 1) * φ - 2 * (n : ℝ) * φ) / 2 = φ := by ring
        have h2 : (2 * ((n : ℝ) + 1) * φ + 2 * (n : ℝ) * φ) / 2 = (2 * (n : ℝ) + 1) * φ := by ring
        rw [h1, h2]
      push_cast
      push_cast at key
      rw [key]
      ring

/-- The cosine sums entering the orthogonality relation. -/
theorem sum_cos_odd_secAngle (s m : ℕ) (hm1 : 1 ≤ m) (hm2 : m ≤ 2 * s + 2) :
    ∑ t ∈ Finset.range (s + 1),
        Real.cos ((2 * (t : ℝ) + 1) * ((m : ℝ) * Real.pi / (2 * s + 3)))
      = -(-1) ^ m / 2 := by
  have hpi := Real.pi_pos
  have hden : (0 : ℝ) < 2 * s + 3 := by positivity
  set φ : ℝ := (m : ℝ) * Real.pi / (2 * s + 3) with hφ
  have hm1' : (1 : ℝ) ≤ m := by exact_mod_cast hm1
  have hm2' : (m : ℝ) ≤ 2 * s + 2 := by exact_mod_cast hm2
  have hφpos : 0 < φ := by
    rw [hφ]
    positivity
  have hφlt : φ < Real.pi := by
    rw [hφ, div_lt_iff₀ hden]
    nlinarith
  have hsin : 0 < Real.sin φ := Real.sin_pos_of_pos_of_lt_pi hφpos hφlt
  have htel := two_sin_mul_sum_cos φ (s + 1)
  have harg : 2 * ((s : ℝ) + 1) * φ = (m : ℝ) * Real.pi - φ := by
    rw [hφ]
    field_simp
    ring
  have hcast : ((s + 1 : ℕ) : ℝ) = (s : ℝ) + 1 := by push_cast; ring
  rw [hcast, harg, Real.sin_sub, Real.sin_nat_mul_pi, Real.cos_nat_mul_pi] at htel
  have h2 : (2 : ℝ) * Real.sin φ ≠ 0 := by positivity
  apply mul_left_cancel₀ h2
  rw [htel]
  field_simp
  ring

/-! ### Orthogonality of the discrete sine transform -/

/-- **Discrete sine orthogonality.**  For `1 ≤ a, b ≤ s + 1`,
`∑_t sin(a θ_t) sin(b θ_t)` is `(2s+3)/4` if `a = b` and `0` otherwise. -/
theorem sum_sin_mul_sin_secAngle (s a b : ℕ) (ha1 : 1 ≤ a) (ha2 : a ≤ s + 1)
    (hb1 : 1 ≤ b) (hb2 : b ≤ s + 1) :
    ∑ t ∈ Finset.range (s + 1),
        Real.sin ((a : ℝ) * secAngle s t) * Real.sin ((b : ℝ) * secAngle s t)
      = if a = b then ((2 * s + 3 : ℝ)) / 4 else 0 := by
  have hden : (0 : ℝ) < 2 * s + 3 := by positivity
  -- rewrite each product as a difference of cosines
  have hprod : ∀ t : ℕ,
      Real.sin ((a : ℝ) * secAngle s t) * Real.sin ((b : ℝ) * secAngle s t)
        = (Real.cos ((2 * (t : ℝ) + 1) * (((a : ℝ) - b) * Real.pi / (2 * s + 3)))
            - Real.cos ((2 * (t : ℝ) + 1) * (((a : ℝ) + b) * Real.pi / (2 * s + 3)))) / 2 := by
    intro t
    have hX : (a : ℝ) * secAngle s t - (b : ℝ) * secAngle s t
        = (2 * (t : ℝ) + 1) * (((a : ℝ) - b) * Real.pi / (2 * s + 3)) := by
      unfold secAngle
      field_simp
    have hY : (a : ℝ) * secAngle s t + (b : ℝ) * secAngle s t
        = (2 * (t : ℝ) + 1) * (((a : ℝ) + b) * Real.pi / (2 * s + 3)) := by
      unfold secAngle
      field_simp
    rw [← hX, ← hY, Real.cos_sub_cos]
    have h1 : ((a : ℝ) * secAngle s t - (b : ℝ) * secAngle s t
        + ((a : ℝ) * secAngle s t + (b : ℝ) * secAngle s t)) / 2 = (a : ℝ) * secAngle s t := by
      ring
    have h2 : ((a : ℝ) * secAngle s t - (b : ℝ) * secAngle s t
        - ((a : ℝ) * secAngle s t + (b : ℝ) * secAngle s t)) / 2 = -((b : ℝ) * secAngle s t) := by
      ring
    rw [h1, h2, Real.sin_neg]
    ring
  rw [Finset.sum_congr rfl (fun t _ => hprod t), ← Finset.sum_div, Finset.sum_sub_distrib]
  by_cases hab : a = b
  · subst hab
    have hzero : ∀ t : ℕ,
        Real.cos ((2 * (t : ℝ) + 1) * (((a : ℝ) - a) * Real.pi / (2 * s + 3))) = 1 := by
      intro t
      norm_num
    rw [Finset.sum_congr rfl (fun t _ => hzero t), Finset.sum_const, Finset.card_range,
      nsmul_eq_mul, mul_one]
    have hsum : ∑ t ∈ Finset.range (s + 1),
        Real.cos ((2 * (t : ℝ) + 1) * (((a : ℝ) + a) * Real.pi / (2 * s + 3)))
        = -(-1 : ℝ) ^ (2 * a) / 2 := by
      have := sum_cos_odd_secAngle s (2 * a) (by omega) (by omega)
      have hc : ((2 * a : ℕ) : ℝ) = (a : ℝ) + a := by push_cast; ring
      rw [hc] at this
      exact this
    rw [hsum, if_pos rfl, pow_mul]
    push_cast
    norm_num
    ring
  · -- `a ≠ b`: the two cosine sums coincide because `a - b` and `a + b` have equal parity
    rcases Nat.lt_or_ge a b with hlt | hge
    · have hdiff : ∀ t : ℕ,
          Real.cos ((2 * (t : ℝ) + 1) * (((a : ℝ) - b) * Real.pi / (2 * s + 3)))
            = Real.cos ((2 * (t : ℝ) + 1) * (((b : ℕ) - a : ℕ) * Real.pi / (2 * s + 3))) := by
        intro t
        have hc : (((b - a : ℕ) : ℝ)) = (b : ℝ) - a := by
          rw [Nat.cast_sub (le_of_lt hlt)]
        rw [hc]
        rw [show (2 * (t : ℝ) + 1) * (((a : ℝ) - b) * Real.pi / (2 * s + 3))
            = -((2 * (t : ℝ) + 1) * (((b : ℝ) - a) * Real.pi / (2 * s + 3))) by ring,
          Real.cos_neg]
      rw [Finset.sum_congr rfl (fun t _ => hdiff t)]
      have h1 := sum_cos_odd_secAngle s (b - a) (by omega) (by omega)
      have hsum2 : ∑ t ∈ Finset.range (s + 1),
          Real.cos ((2 * (t : ℝ) + 1) * (((a : ℝ) + b) * Real.pi / (2 * s + 3)))
          = -(-1 : ℝ) ^ (a + b) / 2 := by
        have := sum_cos_odd_secAngle s (a + b) (by omega) (by omega)
        have hc : ((a + b : ℕ) : ℝ) = (a : ℝ) + b := by push_cast; ring
        rw [hc] at this
        exact this
      rw [h1, hsum2, if_neg hab]
      have hpar : ((-1 : ℝ)) ^ (b - a) = ((-1 : ℝ)) ^ (a + b) :=
        neg_one_pow_eq_of_even_add ⟨b, by omega⟩
      rw [hpar]
      ring
    · have hgt : b < a := by omega
      have hdiff : ∀ t : ℕ,
          Real.cos ((2 * (t : ℝ) + 1) * (((a : ℝ) - b) * Real.pi / (2 * s + 3)))
            = Real.cos ((2 * (t : ℝ) + 1) * (((a - b : ℕ) : ℝ) * Real.pi / (2 * s + 3))) := by
        intro t
        rw [Nat.cast_sub (le_of_lt hgt)]
      rw [Finset.sum_congr rfl (fun t _ => hdiff t)]
      have h1 := sum_cos_odd_secAngle s (a - b) (by omega) (by omega)
      have hsum2 : ∑ t ∈ Finset.range (s + 1),
          Real.cos ((2 * (t : ℝ) + 1) * (((a : ℝ) + b) * Real.pi / (2 * s + 3)))
          = -(-1 : ℝ) ^ (a + b) / 2 := by
        have := sum_cos_odd_secAngle s (a + b) (by omega) (by omega)
        have hc : ((a + b : ℕ) : ℝ) = (a : ℝ) + b := by push_cast; ring
        rw [hc] at this
        exact this
      rw [h1, hsum2, if_neg hab]
      have hpar : ((-1 : ℝ)) ^ (a - b) = ((-1 : ℝ)) ^ (a + b) :=
        neg_one_pow_eq_of_even_add ⟨a, by omega⟩
      rw [hpar]
      ring

/-! ### The eigenvector matrix is orthogonal up to scale -/

/-- **Orthogonality of the eigenvector matrix.**  `B Bᵀ = ((2s+3)/4) • 1`. -/
theorem secEigmat_mul_transpose (s : ℕ) :
    secEigmat s * (secEigmat s)ᵀ = ((2 * (s : ℝ) + 3) / 4) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ) := by
  ext j j'
  have hj : (j : ℕ) ≤ s := Nat.lt_succ_iff.mp j.isLt
  have hj' : (j' : ℕ) ≤ s := Nat.lt_succ_iff.mp j'.isLt
  have hcast : ∀ k : Fin (s + 1), ((s + 1 - (k : ℕ) : ℕ) : ℝ) = (s : ℝ) + 1 - (k : ℕ) := by
    intro k
    have hk : (k : ℕ) ≤ s + 1 := le_of_lt k.isLt
    push_cast [Nat.cast_sub hk]
    ring
  have hentry : (secEigmat s * (secEigmat s)ᵀ) j j'
      = ∑ t ∈ Finset.range (s + 1),
          Real.sin (((s + 1 - (j : ℕ) : ℕ) : ℝ) * secAngle s t)
            * Real.sin (((s + 1 - (j' : ℕ) : ℕ) : ℝ) * secAngle s t) := by
    rw [Matrix.mul_apply]
    rw [← Fin.sum_univ_eq_sum_range (fun t => Real.sin (((s + 1 - (j : ℕ) : ℕ) : ℝ) * secAngle s t)
      * Real.sin (((s + 1 - (j' : ℕ) : ℕ) : ℝ) * secAngle s t)) (s + 1)]
    refine Finset.sum_congr rfl (fun t _ => ?_)
    rw [hcast j, hcast j']
    rfl
  rw [hentry, sum_sin_mul_sin_secAngle s (s + 1 - (j : ℕ)) (s + 1 - (j' : ℕ))
    (by omega) (by omega) (by omega) (by omega)]
  by_cases hjj : j = j'
  · subst hjj
    rw [if_pos rfl, Matrix.smul_apply, Matrix.one_apply_eq, smul_eq_mul, mul_one]
  · have hne : s + 1 - (j : ℕ) ≠ s + 1 - (j' : ℕ) := by
      intro hc
      exact hjj (Fin.ext (by omega))
    rw [if_neg hne, Matrix.smul_apply, Matrix.one_apply_ne hjj, smul_eq_mul, mul_zero]

/-! ### Sums of eigenvector entries -/

/-- The entries of an eigenvector sum to `½ cot(θ_t/2)`. -/
theorem sum_secEigvec (s t : ℕ) (ht : t ≤ s) :
    ∑ j : Fin (s + 1), secEigvec s t j
      = Real.cos (secAngle s t / 2) / (2 * Real.sin (secAngle s t / 2)) := by
  have hrow := congrFun (adjMatR_mulVec_secEigvec (s := s) (t := t) ht) 0
  have hone : ∀ b : Fin (s + 1), adjMatR s 0 b = 1 := by
    intro b
    have hb : (b : ℕ) ≤ s := Nat.lt_succ_iff.mp b.isLt
    rw [adjMatR_apply, if_pos (by simpa using hb)]
  have hlhs : (adjMatR s *ᵥ secEigvec s t) 0 = ∑ j : Fin (s + 1), secEigvec s t j := by
    show ∑ j : Fin (s + 1), adjMatR s 0 j * secEigvec s t j = _
    exact Finset.sum_congr rfl (fun j _ => by rw [hone j, one_mul])
  rw [hlhs] at hrow
  rw [hrow]
  have hzero : secEigvec s t 0 = Real.sin (((s : ℝ) + 1 - (0 : ℕ)) * secAngle s t) := rfl
  have hrefl := sin_secAngle_reflect s t 0
  simp only [Pi.smul_apply, smul_eq_mul, hzero]
  rw [hrefl]
  unfold secEigval
  push_cast
  have hsq : ((-1 : ℝ)) ^ t * ((-1 : ℝ)) ^ t = 1 := by
    rw [← mul_pow]
    norm_num
  rw [show ((0 : ℝ) + 1 / 2) * secAngle s t = secAngle s t / 2 from by ring,
    show ((-1 : ℝ)) ^ t / (2 * Real.sin (secAngle s t / 2))
        * (((-1 : ℝ)) ^ t * Real.cos (secAngle s t / 2))
      = (((-1 : ℝ)) ^ t * ((-1 : ℝ)) ^ t) * Real.cos (secAngle s t / 2)
        / (2 * Real.sin (secAngle s t / 2)) from by ring, hsq, one_mul]

/-! ### The closed form for the open counts -/

lemma adjMatR_pow_apply (s m : ℕ) (a b : Fin (s + 1)) :
    (adjMatR s ^ m) a b = ((adjMat s ^ m) a b : ℝ) := by
  have hmap : (adjMatR s) ^ m = ((adjMat s) ^ m).map (fun n : ℕ => (n : ℝ)) := by
    rw [adjMatR_eq_map]
    exact (map_pow ((Nat.castRingHom ℝ).mapMatrix) (adjMat s) m).symm
  rw [hmap]
  rfl

/-- The spectral decomposition of the powers of the transfer matrix. -/
theorem smul_adjMatR_pow (s d : ℕ) :
    ((2 * (s : ℝ) + 3) / 4) • (adjMatR s ^ d)
      = secEigmat s * secDiagMat s ^ d * (secEigmat s)ᵀ := by
  symm
  calc secEigmat s * secDiagMat s ^ d * (secEigmat s)ᵀ
      = (adjMatR s ^ d * secEigmat s) * (secEigmat s)ᵀ := by
        rw [adjMatR_pow_mul_secEigmat]
    _ = adjMatR s ^ d * (secEigmat s * (secEigmat s)ᵀ) := Matrix.mul_assoc _ _ _
    _ = adjMatR s ^ d * (((2 * (s : ℝ) + 3) / 4) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℝ)) := by
        rw [secEigmat_mul_transpose]
    _ = ((2 * (s : ℝ) + 3) / 4) • (adjMatR s ^ d) := by
        rw [Matrix.mul_smul, Matrix.mul_one]

/-- The entries of `A^d` in spectral form. -/
theorem adjMatR_pow_entry (s d : ℕ) (a b : Fin (s + 1)) :
    (adjMatR s ^ d) a b
      = (4 / (2 * (s : ℝ) + 3)) * ∑ t : Fin (s + 1),
          secEigvec s (t : ℕ) a * (secEigval s (t : ℕ)) ^ d * secEigvec s (t : ℕ) b := by
  have hc : (0 : ℝ) < (2 * (s : ℝ) + 3) / 4 := by positivity
  have hD : secDiagMat s ^ d
      = Matrix.diagonal (fun t : Fin (s + 1) => (secEigval s (t : ℕ)) ^ d) := by
    rw [secDiagMat, Matrix.diagonal_pow]
    rfl
  have hentry := congrFun (congrFun (smul_adjMatR_pow s d) a) b
  rw [Matrix.smul_apply, smul_eq_mul, Matrix.mul_apply] at hentry
  have hrhs : ∑ t : Fin (s + 1), (secEigmat s * secDiagMat s ^ d) a t * (secEigmat s)ᵀ t b
      = ∑ t : Fin (s + 1),
          secEigvec s (t : ℕ) a * (secEigval s (t : ℕ)) ^ d * secEigvec s (t : ℕ) b := by
    refine Finset.sum_congr rfl (fun t _ => ?_)
    rw [hD, Matrix.mul_diagonal]
    rfl
  rw [hrhs] at hentry
  rw [← hentry]
  field_simp

/-- **Closed form for the open counts.**  The number of open adjacent-sum lattice points
of length `d + 1` equals `(1/(2s+3)) ∑_t λ_t^d cot²(θ_t/2)`. -/
theorem card_openSet_eq_sum (s d : ℕ) :
    ((openSet s d).card : ℝ)
      = (1 / (2 * (s : ℝ) + 3)) * ∑ t : Fin (s + 1),
          (secEigval s (t : ℕ)) ^ d
            * (Real.cos (secAngle s (t : ℕ) / 2) / Real.sin (secAngle s (t : ℕ) / 2)) ^ 2 := by
  have hcard : ((openSet s d).card : ℝ)
      = ∑ a : Fin (s + 1), ∑ b : Fin (s + 1), (adjMatR s ^ d) a b := by
    rw [card_openSet]
    push_cast
    exact Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl
      (fun b _ => (adjMatR_pow_apply s d a b).symm))
  have hswap : ∑ a : Fin (s + 1), ∑ b : Fin (s + 1), (adjMatR s ^ d) a b
      = (4 / (2 * (s : ℝ) + 3)) * ∑ t : Fin (s + 1),
          (∑ a : Fin (s + 1), secEigvec s (t : ℕ) a) * (secEigval s (t : ℕ)) ^ d
            * (∑ b : Fin (s + 1), secEigvec s (t : ℕ) b) := by
    have hfactor : ∀ t : Fin (s + 1),
        ∑ a : Fin (s + 1), ∑ b : Fin (s + 1),
            secEigvec s (t : ℕ) a * (secEigval s (t : ℕ)) ^ d * secEigvec s (t : ℕ) b
          = (∑ a : Fin (s + 1), secEigvec s (t : ℕ) a) * (secEigval s (t : ℕ)) ^ d
            * (∑ b : Fin (s + 1), secEigvec s (t : ℕ) b) := by
      intro t
      rw [Finset.sum_mul, Finset.sum_mul]
      refine Finset.sum_congr rfl (fun a _ => ?_)
      rw [Finset.mul_sum]
    calc ∑ a : Fin (s + 1), ∑ b : Fin (s + 1), (adjMatR s ^ d) a b
        = ∑ a : Fin (s + 1), ∑ b : Fin (s + 1), (4 / (2 * (s : ℝ) + 3)) *
            ∑ t : Fin (s + 1),
              secEigvec s (t : ℕ) a * (secEigval s (t : ℕ)) ^ d * secEigvec s (t : ℕ) b := by
          simp only [adjMatR_pow_entry]
      _ = (4 / (2 * (s : ℝ) + 3)) * ∑ a : Fin (s + 1), ∑ b : Fin (s + 1), ∑ t : Fin (s + 1),
              secEigvec s (t : ℕ) a * (secEigval s (t : ℕ)) ^ d * secEigvec s (t : ℕ) b := by
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl (fun a _ => (Finset.mul_sum _ _ _).symm)
      _ = (4 / (2 * (s : ℝ) + 3)) * ∑ t : Fin (s + 1), ∑ a : Fin (s + 1), ∑ b : Fin (s + 1),
              secEigvec s (t : ℕ) a * (secEigval s (t : ℕ)) ^ d * secEigvec s (t : ℕ) b := by
          congr 1
          rw [Finset.sum_congr rfl (fun a (_ : a ∈ Finset.univ) =>
            Finset.sum_comm (s := (Finset.univ : Finset (Fin (s + 1))))
              (t := (Finset.univ : Finset (Fin (s + 1))))
              (f := fun b t => secEigvec s (t : ℕ) a * (secEigval s (t : ℕ)) ^ d
                * secEigvec s (t : ℕ) b)), Finset.sum_comm]
      _ = (4 / (2 * (s : ℝ) + 3)) * ∑ t : Fin (s + 1),
            (∑ a : Fin (s + 1), secEigvec s (t : ℕ) a) * (secEigval s (t : ℕ)) ^ d
              * (∑ b : Fin (s + 1), secEigvec s (t : ℕ) b) := by
          congr 1
          exact Finset.sum_congr rfl (fun t _ => hfactor t)
  rw [hcard, hswap]
  have hsum : ∀ t : Fin (s + 1), (∑ a : Fin (s + 1), secEigvec s (t : ℕ) a)
      = Real.cos (secAngle s (t : ℕ) / 2) / (2 * Real.sin (secAngle s (t : ℕ) / 2)) :=
    fun t => sum_secEigvec s (t : ℕ) (Nat.lt_succ_iff.mp t.isLt)
  have hden : (0 : ℝ) < 2 * (s : ℝ) + 3 := by positivity
  rw [Finset.mul_sum, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun t _ => ?_)
  have hsinpos : 0 < Real.sin (secAngle s (t : ℕ) / 2) :=
    sin_secAngle_half_pos (Nat.lt_succ_iff.mp t.isLt)
  rw [hsum t]
  field_simp
  ring

end

end AdjSum