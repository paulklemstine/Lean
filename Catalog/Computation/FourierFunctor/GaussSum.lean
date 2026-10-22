import Computation.FourierFunctor.Rigidity

/-!
# Quadratic Gauss sums: the flat extreme of the uncertainty principle

`Rigidity.lean` classifies the functions that are *maximally concentrated*:
`|supp f| · |supp 𝓕f| = |G|` holds exactly for modulated coset indicators.  This
file exhibits the opposite extreme on `G = ZMod N` with `N` odd — a function
that is maximally *spread*, together with its transform:

* `quadPhase ψ x = ψ (x * x)`, the quadratic phase attached to a primitive
  additive character `ψ` of `ZMod N`;
* `quadratic_gauss_sum_normSq` — the classical evaluation
  `|∑_x ψ(x²)|² = N` of the quadratic Gauss sum;
* `norm_fourier_quadPhase_sq` — **flatness**: *every* Fourier coefficient of
  `quadPhase ψ` has modulus `√N`;
* `quadPhase_support_product` — consequently
  `|supp f| · |supp 𝓕f| = N²`, the largest value the product can take, so the
  quadratic phase saturates the uncertainty principle in the opposite direction
  from the coset indicators of `Sharpness.lean`.

This settles part (ii) of conjecture C4 of `FUTURE_DIRECTIONS.md` (the Gauss
sum evaluation) for every odd modulus, not only for primes.

-- !-- Lab Notes -- !--

* Hypothesizer: the equality case of Donoho–Stark is one endpoint of a spectrum;
  the other endpoint should be occupied by functions of constant modulus whose
  transforms also have constant modulus ("bi-unimodular" functions), and the
  quadratic phase is the standard candidate.
* Experimenter: `|S|² = N` was proved by expanding `S · conj S`, reindexing
  `x = y + t`, and observing that the inner sum `∑_y ψ(2ty)` vanishes unless
  `2t = 0`.  Oddness of `N` enters exactly once, to make `2` a unit of `ZMod N`
  (`Nat.coprime_two_left`); for even `N` the argument breaks down and indeed
  `∑_x ψ(x²)` can vanish (e.g. `N = 2` with the non-trivial character).
* Analyst: flatness for *all* characters follows from the same computation after
  completing the square, `x² + bx = (x + b/2)² − b²/4`, which again needs `2`
  invertible.  Surjectivity of `b ↦ mulShift ψ b` (injective by primitivity,
  hence bijective by counting characters) converts the statement "for all `b`"
  into "for all characters".
* Critic: the hypothesis that `ψ` is primitive is necessary — for the trivial
  character `∑_x ψ(x²) = N ≠ √N`.  Oddness of `N` is necessary as noted above.
-/

open AddChar Finset
open scoped Classical

namespace FourierFunctor

variable {N : ℕ} [NeZero N]

/-- The quadratic phase attached to an additive character: `x ↦ ψ (x²)`. -/
noncomputable def quadPhase (ψ : AddChar (ZMod N) ℂ) : ZMod N → ℂ := fun x => ψ (x * x)

omit [NeZero N] in
/-- `2` is invertible modulo an odd number. -/
lemma isUnit_two_of_odd (hN : Odd N) : IsUnit (2 : ZMod N) := by
  have h : IsUnit ((2 : ℕ) : ZMod N) :=
    (ZMod.isUnit_iff_coprime 2 N).2 (Nat.coprime_two_left.mpr hN)
  simpa using h

/-- A non-trivial character sums to zero: the orthogonality relation used
throughout, in the `mulShift` form supplied by primitivity. -/
lemma sum_mulShift_eq_zero {ψ : AddChar (ZMod N) ℂ} (hψ : ψ.IsPrimitive) {a : ZMod N}
    (ha : a ≠ 0) : (∑ y : ZMod N, ψ (a * y)) = 0 := by
  classical
  have h : (∑ y : ZMod N, (ψ.mulShift a) y)
      = if ψ.mulShift a = 0 then (Fintype.card (ZMod N) : ℂ) else 0 := AddChar.sum_eq_ite _
  simp only [AddChar.mulShift_apply] at h
  rw [h, if_neg]
  intro hzero
  exact hψ ha (by rw [hzero, AddChar.one_eq_zero])

/-- **The quadratic Gauss sum has modulus `√N`** for every odd modulus `N` and
every primitive additive character. -/
theorem quadratic_gauss_sum_normSq (hN : Odd N) (ψ : AddChar (ZMod N) ℂ)
    (hψ : ψ.IsPrimitive) :
    ‖∑ x : ZMod N, ψ (x * x)‖ ^ 2 = N := by
  classical
  have hunit := isUnit_two_of_odd hN
  have hexpand : (∑ x : ZMod N, ψ (x * x)) * (starRingEnd ℂ) (∑ x : ZMod N, ψ (x * x))
      = ∑ t : ZMod N, (ψ (t * t) * ∑ y : ZMod N, ψ ((2 * t) * y)) := by
    rw [map_sum, Finset.sum_mul_sum, Finset.sum_comm]
    have hinner : ∀ y : ZMod N, (∑ x : ZMod N, ψ (x * x) * (starRingEnd ℂ) (ψ (y * y)))
        = ∑ t : ZMod N, ψ (t * t) * ψ ((2 * t) * y) := by
      intro y
      rw [← Fintype.sum_bijective (fun t : ZMod N => y + t) (Equiv.addLeft y).bijective
        (fun t => ψ (t * t) * ψ ((2 * t) * y)) (fun x => ψ (x * x) * (starRingEnd ℂ) (ψ (y * y)))]
      intro t
      rw [← AddChar.map_neg_eq_conj, ← ψ.map_add_eq_mul, ← ψ.map_add_eq_mul]
      congr 1
      ring
    rw [Finset.sum_congr rfl fun y _ => hinner y, Finset.sum_comm]
    exact Finset.sum_congr rfl fun t _ => (Finset.mul_sum _ _ _).symm
  have hcollapse : (∑ t : ZMod N, (ψ (t * t) * ∑ y : ZMod N, ψ ((2 * t) * y))) = (N : ℂ) := by
    rw [Finset.sum_eq_single (0 : ZMod N)]
    · simp [ZMod.card]
    · intro t _ ht
      have h2t : 2 * t ≠ 0 := fun h => ht (by simpa [hunit.mul_right_eq_zero] using h)
      rw [sum_mulShift_eq_zero hψ h2t, mul_zero]
    · intro h
      exact absurd (Finset.mem_univ (0 : ZMod N)) h
  have hkey : (Complex.normSq (∑ x : ZMod N, ψ (x * x)) : ℂ) = (N : ℂ) := by
    rw [← Complex.mul_conj, hexpand, hcollapse]
  have hreal : Complex.normSq (∑ x : ZMod N, ψ (x * x)) = (N : ℝ) := by exact_mod_cast hkey
  rw [Complex.sq_norm, hreal]

/-- Non-vacuity: the standard additive character of `ZMod N` is primitive, so
the Gauss sum evaluation applies to it. -/
theorem gauss_sum_stdAddChar_normSq (hN : Odd N) :
    ‖∑ x : ZMod N, ZMod.stdAddChar (x * x)‖ ^ 2 = N :=
  quadratic_gauss_sum_normSq hN _ (ZMod.isPrimitive_stdAddChar N)

/-- **Completing the square.**  Every additively shifted quadratic Gauss sum has
the same modulus `√N`. -/
theorem shifted_gauss_sum_normSq (hN : Odd N) (ψ : AddChar (ZMod N) ℂ)
    (hψ : ψ.IsPrimitive) (b : ZMod N) :
    ‖∑ x : ZMod N, ψ (x * x + b * x)‖ ^ 2 = N := by
  classical
  obtain ⟨u, hu⟩ := isUnit_two_of_odd hN
  -- `c = b / 2` satisfies `2 * c = b`
  set c : ZMod N := (↑u⁻¹ : ZMod N) * b with hc
  have h2c : 2 * c = b := by
    rw [hc, ← mul_assoc, ← hu]
    simp [← Units.val_mul]
  have hreindex : (∑ x : ZMod N, ψ (x * x + b * x))
      = ∑ z : ZMod N, ψ (z * z + (-(c * c)) ) := by
    refine (Fintype.sum_bijective (fun z : ZMod N => z - c) (Equiv.subRight c).bijective
      _ _ ?_).symm
    intro z
    congr 1
    have : b = 2 * c := h2c.symm
    rw [this]
    ring
  have hsplit : (∑ z : ZMod N, ψ (z * z + (-(c * c))))
      = ψ (-(c * c)) * ∑ z : ZMod N, ψ (z * z) := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun z _ => by rw [ψ.map_add_eq_mul]; ring
  rw [hreindex, hsplit, norm_mul, mul_pow, ψ.norm_apply, one_pow, one_mul]
  exact quadratic_gauss_sum_normSq hN ψ hψ

/-- Every character of `ZMod N` is a multiplicative shift of a primitive one. -/
lemma exists_mulShift_eq (ψ : AddChar (ZMod N) ℂ) (hψ : ψ.IsPrimitive)
    (χ : AddChar (ZMod N) ℂ) : ∃ b : ZMod N, ψ.mulShift b = χ := by
  classical
  have hinj : Function.Injective ψ.mulShift := AddChar.to_mulShift_inj_of_isPrimitive hψ
  have hcard : Fintype.card (ZMod N) = Fintype.card (AddChar (ZMod N) ℂ) := by
    rw [AddChar.card_eq (α := ZMod N)]
  have hsurj : Function.Surjective ψ.mulShift :=
    (Fintype.bijective_iff_injective_and_card _).2 ⟨hinj, hcard⟩ |>.2
  exact hsurj χ

/-- **Flatness of the quadratic phase.**  Every Fourier coefficient of
`x ↦ ψ (x²)` has modulus `√N`: the transform is as spread out as it can be. -/
theorem norm_fourier_quadPhase_sq (hN : Odd N) (ψ : AddChar (ZMod N) ℂ)
    (hψ : ψ.IsPrimitive) (χ : AddChar (ZMod N) ℂ) :
    ‖fourier (quadPhase ψ) χ‖ ^ 2 = N := by
  classical
  obtain ⟨b, rfl⟩ := exists_mulShift_eq ψ hψ χ
  have hterm : ∀ x : ZMod N,
      quadPhase ψ x * (ψ.mulShift b) (-x) = ψ (x * x + (-b) * x) := by
    intro x
    rw [quadPhase, AddChar.mulShift_apply, ← ψ.map_add_eq_mul]
    congr 1
    ring
  rw [fourier_apply, Finset.sum_congr rfl fun x _ => hterm x]
  exact shifted_gauss_sum_normSq hN ψ hψ (-b)

/-- The transform of the quadratic phase never vanishes. -/
theorem fourier_quadPhase_ne_zero (hN : Odd N) (ψ : AddChar (ZMod N) ℂ)
    (hψ : ψ.IsPrimitive) (χ : AddChar (ZMod N) ℂ) : fourier (quadPhase ψ) χ ≠ 0 := by
  intro h
  have hz := norm_fourier_quadPhase_sq hN ψ hψ χ
  rw [h, norm_zero] at hz
  have hzero : (N : ℝ) = 0 := by simpa using hz.symm
  exact (NeZero.ne N) (by exact_mod_cast hzero)

/-- **The anti-extremal case.**  The quadratic phase and its transform are both
everywhere non-zero, so the uncertainty product takes its largest possible
value `N²` — the exact opposite of the modulated coset indicators, which attain
the minimum `N`. -/
theorem quadPhase_support_product (hN : Odd N) (ψ : AddChar (ZMod N) ℂ)
    (hψ : ψ.IsPrimitive) :
    (support (quadPhase ψ)).card * (support (fourier (quadPhase ψ))).card
      = Fintype.card (ZMod N) * Fintype.card (ZMod N) := by
  classical
  have h1 : support (quadPhase ψ) = Finset.univ := by
    refine Finset.eq_univ_iff_forall.2 fun x => mem_support.2 ?_
    exact addChar_apply_ne_zero ψ (x * x)
  have h2 : support (fourier (quadPhase ψ)) = Finset.univ := by
    refine Finset.eq_univ_iff_forall.2 fun χ => mem_support.2 ?_
    exact fourier_quadPhase_ne_zero hN ψ hψ χ
  rw [h1, h2, Finset.card_univ, Finset.card_univ, AddChar.card_eq (α := ZMod N)]

/-- Consequently the quadratic phase is **not** an extremal function for the
uncertainty principle as soon as `N > 1`: the Donoho–Stark inequality is strict
for it. -/
theorem quadPhase_not_extremal (hN : Odd N) (hN1 : 1 < N) (ψ : AddChar (ZMod N) ℂ)
    (hψ : ψ.IsPrimitive) :
    Fintype.card (ZMod N)
      < (support (quadPhase ψ)).card * (support (fourier (quadPhase ψ))).card := by
  rw [quadPhase_support_product hN ψ hψ, ZMod.card]
  exact lt_mul_left (by omega) hN1

end FourierFunctor