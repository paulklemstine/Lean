import Bridges.FourierFunctorUncertainty

/-!
# Subgroup indicators are the extremals of the Donoho–Stark bound

The previous file proved the Donoho–Stark uncertainty principle
`N ≤ |supp Φ| * |supp 𝓕Φ|` on `ZMod N`, showed it is attained by delta functions, and exhibited
one composite counterexample (`N = 4`) to the additive prime bound. This file proves the general
structural statement behind that counterexample.

For every factorisation `N = d * m` the indicator function of the subgroup of multiples of `d`
has support of size `m`, and its discrete Fourier transform is the indicator of the subgroup of
multiples of `m` scaled by `m`, hence has support of size `d`. Consequently:

* `SubgroupExtremals.donoho_stark_extremal` : the Donoho–Stark bound is attained with equality by
  the whole family of subgroup indicators, `|supp Φ| * |supp 𝓕Φ| = N`;
* `SubgroupExtremals.additive_bound_le_divisor_sum` : the additive support sum equals `d + m`,
  so the prime (Tao) bound `N + 1` fails for every composite `N`;
* `SubgroupExtremals.tao_bound_fails_of_composite` : an explicit statement of that failure.

The proof is a genuine finite Fourier computation: the transform of the indicator is a geometric
sum of a root of unity, which vanishes off the annihilator subgroup.
-/

open Finset ZMod FourierUncertainty

namespace SubgroupExtremals

/-! ## Counting the multiples of `a` in `ZMod (a * b)` -/

section Counting

variable {N a b : ℕ} [NeZero N]

/-- Membership in the set of multiples of `a` is divisibility of the representative. -/
theorem mem_image_mul_iff (ha : a ≠ 0) (hN : N = a * b) (j : ZMod N) :
    j ∈ (Finset.range b).image (fun t => ((a * t : ℕ) : ZMod N)) ↔ a ∣ j.val := by
  constructor
  · intro h
    simp only [Finset.mem_image, Finset.mem_range] at h
    obtain ⟨t, ht, rfl⟩ := h
    have hlt : a * t < N := by
      rw [hN]; exact (Nat.mul_lt_mul_left (Nat.pos_of_ne_zero ha)).2 ht
    rw [ZMod.val_natCast_of_lt hlt]
    exact Dvd.intro t rfl
  · intro h
    obtain ⟨t, ht⟩ := h
    have hval : j.val < N := ZMod.val_lt j
    have htb : t < b := by
      rw [ht, hN] at hval
      exact lt_of_mul_lt_mul_left hval (Nat.zero_le a)
    simp only [Finset.mem_image, Finset.mem_range]
    exact ⟨t, htb, by rw [← ht]; simp⟩

omit [NeZero N] in
/-- There are exactly `b` multiples of `a` in `ZMod (a * b)`. -/
theorem card_image_mul (ha : a ≠ 0) (hN : N = a * b) :
    ((Finset.range b).image (fun t => ((a * t : ℕ) : ZMod N))).card = b := by
  rw [Finset.card_image_of_injOn, Finset.card_range]
  intro x hx y hy hxy
  simp only [Finset.mem_coe, Finset.mem_range] at hx hy
  have h : (a * x) ≡ (a * y) [MOD N] := (ZMod.natCast_eq_natCast_iff _ _ _).1 hxy
  rw [hN] at h
  exact Nat.ModEq.eq_of_lt_of_lt (Nat.ModEq.mul_left_cancel' ha h) hx hy

end Counting

/-! ## The indicator of a subgroup and its Fourier transform -/

section Indicator

variable (d m : ℕ) [NeZero d] [NeZero m]

instance neZero_mul : NeZero (d * m) := ⟨Nat.mul_ne_zero (NeZero.ne d) (NeZero.ne m)⟩

/-- The subgroup of multiples of `d` inside `ZMod (d * m)`; it has `m` elements. -/
noncomputable def multiples : Finset (ZMod (d * m)) :=
  (Finset.range m).image (fun t => ((d * t : ℕ) : ZMod (d * m)))

open scoped Classical in
/-- The indicator function of the subgroup of multiples of `d`. -/
noncomputable def indicator : ZMod (d * m) → ℂ :=
  fun j => if j ∈ multiples d m then 1 else 0

variable {d m}

omit [NeZero m] in
theorem card_multiples : (multiples d m).card = m :=
  card_image_mul (NeZero.ne d) rfl

theorem fsupport_indicator : fsupport (indicator d m) = multiples d m := by
  classical
  ext j
  simp only [mem_fsupport, indicator]
  by_cases h : j ∈ multiples d m <;> simp [h]

theorem card_fsupport_indicator : (fsupport (indicator d m)).card = m := by
  rw [fsupport_indicator, card_multiples]

/-- The Fourier transform of the subgroup indicator is a geometric sum of a root of unity. -/
theorem dft_indicator_eq_geom (k : ZMod (d * m)) :
    𝓕 (indicator d m) k
      = ∑ t ∈ Finset.range m, (stdAddChar (-((d : ZMod (d * m)) * k))) ^ t := by
  classical
  rw [ZMod.dft_apply]
  have hsum : ∑ j : ZMod (d * m), stdAddChar (-(j * k)) • indicator d m j
      = ∑ j ∈ multiples d m, stdAddChar (-(j * k)) • indicator d m j := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    simp [indicator, hx]
  rw [hsum, multiples, Finset.sum_image]
  · refine Finset.sum_congr rfl fun t ht => ?_
    have hmem : ((d * t : ℕ) : ZMod (d * m)) ∈ multiples d m := by
      simp only [multiples, Finset.mem_image]
      exact ⟨t, ht, rfl⟩
    rw [show indicator d m ((d * t : ℕ) : ZMod (d * m)) = 1 from if_pos hmem]
    rw [smul_eq_mul, mul_one]
    rw [← AddChar.map_nsmul_eq_pow]
    congr 1
    push_cast
    ring
  · intro x hx y hy hxy
    simp only [Finset.mem_coe, Finset.mem_range] at hx hy
    have h : (d * x) ≡ (d * y) [MOD d * m] := (ZMod.natCast_eq_natCast_iff _ _ _).1 hxy
    exact Nat.ModEq.eq_of_lt_of_lt (Nat.ModEq.mul_left_cancel' (NeZero.ne d) h) hx hy

/-- The `m`-th power of the relevant root of unity is one. -/
theorem char_pow_eq_one (k : ZMod (d * m)) :
    (stdAddChar (-((d : ZMod (d * m)) * k))) ^ m = 1 := by
  rw [← AddChar.map_nsmul_eq_pow]
  have : (m : ℕ) • (-((d : ZMod (d * m)) * k)) = 0 := by
    rw [nsmul_eq_mul,
      show ((m : ZMod (d * m)) * -((d : ZMod (d * m)) * k))
        = -(((d * m : ℕ) : ZMod (d * m)) * k) by push_cast; ring,
      ZMod.natCast_self, zero_mul, neg_zero]
  rw [this, AddChar.map_zero_eq_one]

/-- Explicit evaluation: the transform is `m` on the annihilator subgroup and `0` elsewhere. -/
theorem dft_indicator_apply (k : ZMod (d * m)) :
    𝓕 (indicator d m) k = if (d : ZMod (d * m)) * k = 0 then (m : ℂ) else 0 := by
  classical
  rw [dft_indicator_eq_geom]
  set z : ℂ := stdAddChar (-((d : ZMod (d * m)) * k)) with hz
  by_cases hk : (d : ZMod (d * m)) * k = 0
  · have hz1 : z = 1 := by rw [hz, hk, neg_zero, AddChar.map_zero_eq_one]
    simp [hz1, hk]
  · have hz1 : z ≠ 1 := by
      rw [hz]
      intro h
      apply hk
      have := ZMod.injective_stdAddChar (N := d * m) (by
        rw [h, AddChar.map_zero_eq_one] : stdAddChar (-((d : ZMod (d * m)) * k))
          = stdAddChar 0)
      simpa using this
    rw [geom_sum_eq hz1, char_pow_eq_one k]
    simp [hk]

theorem fsupport_dft_indicator :
    fsupport (𝓕 (indicator d m)) = Finset.univ.filter fun k => (d : ZMod (d * m)) * k = 0 := by
  classical
  ext k
  simp only [mem_fsupport, Finset.mem_filter, Finset.mem_univ, true_and, dft_indicator_apply]
  by_cases hk : (d : ZMod (d * m)) * k = 0
  · simp [hk, NeZero.ne m]
  · simp [hk]

/-- The annihilator of the subgroup of multiples of `d` is the subgroup of multiples of `m`. -/
theorem annihilator_eq_multiples :
    (Finset.univ.filter fun k : ZMod (d * m) => (d : ZMod (d * m)) * k = 0)
      = (Finset.range d).image (fun t => ((m * t : ℕ) : ZMod (d * m))) := by
  classical
  ext k
  rw [mem_image_mul_iff (NeZero.ne m) (mul_comm d m) k]
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro h
    have hcast : (((d * k.val : ℕ)) : ZMod (d * m)) = 0 := by
      push_cast
      rw [ZMod.natCast_val, ZMod.cast_id]
      exact h
    have hdvd : (d * m) ∣ d * k.val := (ZMod.natCast_eq_zero_iff _ _).1 hcast
    obtain ⟨c, hc⟩ := hdvd
    refine ⟨c, ?_⟩
    have hd : 0 < d := Nat.pos_of_ne_zero (NeZero.ne d)
    have : d * (m * c) = d * k.val := by rw [hc]; ring
    exact (Nat.eq_of_mul_eq_mul_left hd this).symm
  · rintro ⟨c, hc⟩
    have hcast : (((d * k.val : ℕ)) : ZMod (d * m)) = 0 := by
      rw [hc, show d * (m * c) = (d * m) * c by ring, Nat.cast_mul, ZMod.natCast_self,
        zero_mul]
    have : (d : ZMod (d * m)) * k = ((d * k.val : ℕ) : ZMod (d * m)) := by
      push_cast
      rw [ZMod.natCast_val, ZMod.cast_id]
    rw [this, hcast]

theorem card_fsupport_dft_indicator : (fsupport (𝓕 (indicator d m))).card = d := by
  rw [fsupport_dft_indicator, annihilator_eq_multiples]
  exact card_image_mul (NeZero.ne m) (mul_comm d m)

omit [NeZero d] in
theorem indicator_ne_zero : indicator d m ≠ 0 := by
  classical
  intro h
  have h0 : indicator d m 0 = 0 := by rw [h]; rfl
  have hmem : (0 : ZMod (d * m)) ∈ multiples d m := by
    simp only [multiples, Finset.mem_image, Finset.mem_range]
    exact ⟨0, Nat.pos_of_ne_zero (NeZero.ne m), by simp⟩
  rw [indicator, if_pos hmem] at h0
  exact one_ne_zero h0

/-- **The Donoho–Stark bound is attained by every subgroup indicator.** For each factorisation
`N = d * m` the indicator of the multiples of `d` satisfies `|supp Φ| * |supp 𝓕Φ| = N`. Delta
functions are the case `d = N`, `m = 1`. -/
theorem donoho_stark_extremal :
    (fsupport (indicator d m)).card * (fsupport (𝓕 (indicator d m))).card = d * m := by
  rw [card_fsupport_indicator, card_fsupport_dft_indicator, Nat.mul_comm]

/-- The additive support sum of a subgroup indicator is `d + m`. -/
theorem additive_bound_le_divisor_sum :
    (fsupport (indicator d m)).card + (fsupport (𝓕 (indicator d m))).card = m + d := by
  rw [card_fsupport_indicator, card_fsupport_dft_indicator]

/-- **The prime (Tao) additive bound fails for every composite modulus.** If `N = d * m` with
`d, m ≥ 2` then the subgroup indicator is a nonzero function whose support sum `d + m` is
strictly smaller than `N + 1`. -/
theorem tao_bound_fails_of_composite (hd : 2 ≤ d) (hm : 2 ≤ m) :
    (fsupport (indicator d m)).card + (fsupport (𝓕 (indicator d m))).card < d * m + 1 := by
  rw [additive_bound_le_divisor_sum]
  nlinarith [hd, hm]

end Indicator

end SubgroupExtremals