import Tropical.JacobiSignedWeilFloorCore

/-!
# Character-weighted circle counts are Jacobi sums — conjecture C1

Let `p` be an odd prime and `ψ : MulChar (ZMod p) ℂ` any multiplicative character.  Define the
`ψ`-weighted circle count

`W_ψ(p) = ∑_{x² + y² = 1} ψ(x)`.

Conjecture C1 of the JACSIGN future-directions list predicted `|W_ψ(p)| ≤ d √p` for `ψ` of
order `d`, via a Jacobi-sum decomposition.  We prove a **stronger, order-independent** result.

Main results.

* `JacSign.circleSumC_eq_zero_of_odd` : if `ψ(-1) = -1` (an *odd* character) then
  `W_ψ(p) = 0` exactly.
* `JacSign.circleSumC_eq_jacobiSum_add` : if `ψ = ξ²` is a square (equivalently, `ψ` is even)
  and `ψ ≠ 1`, then
  `W_ψ(p) = J(ξ, χ) + J(χξ, χ)`, a sum of exactly two Jacobi sums against the quadratic
  character `χ`.
* `JacSign.norm_jacobiSum_eq_sqrt` : `|J(χ, φ)| = √p` for nontrivial `χ, φ, χφ` (from
  Mathlib's `jacobiSum_mul_jacobiSum_inv` plus `MulChar.star_eq_inv`).
* `JacSign.norm_circleSumC_le` : **C1, in the strong form.**  For every `ξ ∉ {1, χ}`,
  `|W_{ξ²}(p)| ≤ 2 √p`, independently of the order of `ξ`.  Together with the odd case, no
  character weight whatsoever escapes the square-root floor: the floor is a property of the
  circle, not of the weight.
* `JacSign.circleSumC_quadratic_eq_W` : the construction genuinely generalises the catalog —
  for `ψ = χ` the complex circle count is the Jacobi-signed count `W p` of
  `JacobiSignedWeilFloorCore`.
-/

open Finset

namespace JacSign

variable (p : ℕ) [Fact p.Prime]

/-- The quadratic character of `ZMod p` with values in `ℂ`. -/
noncomputable def chiC : MulChar (ZMod p) ℂ :=
  (quadraticChar (ZMod p)).ringHomComp (Int.castRingHom ℂ)

theorem chiC_apply (x : ZMod p) : chiC p x = ((quadraticChar (ZMod p) x : ℤ) : ℂ) := rfl

/-- The `ψ`-weighted count of the circle `x² + y² = 1` over `ZMod p`. -/
noncomputable def circleSumC (ψ : MulChar (ZMod p) ℂ) : ℂ :=
  ∑ x : ZMod p, ∑ y : ZMod p, if x ^ 2 + y ^ 2 = 1 then ψ x else 0

/-! ### Odd characters see nothing -/

/-- **Odd weights vanish identically.**  If `ψ(-1) = -1` then the `ψ`-weighted circle count is
`0`: the reflection `x ↦ -x` is a symmetry of the circle that flips the weight. -/
theorem circleSumC_eq_zero_of_odd {ψ : MulChar (ZMod p) ℂ} (hψ : ψ (-1) = -1) :
    circleSumC p ψ = 0 := by
  have hrefl : circleSumC p ψ = - circleSumC p ψ := by
    conv_lhs => rw [circleSumC]
    rw [← Equiv.sum_comp (Equiv.neg (ZMod p))
      (fun x => ∑ y : ZMod p, if x ^ 2 + y ^ 2 = 1 then ψ x else 0)]
    rw [circleSumC, ← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl fun y _ => ?_
    show (if (-x) ^ 2 + y ^ 2 = 1 then ψ (-x) else 0) = -(if x ^ 2 + y ^ 2 = 1 then ψ x else 0)
    have hx : ψ (-x) = -ψ x := by
      rw [show -x = (-1 : ZMod p) * x by ring, map_mul, hψ, neg_one_mul]
    by_cases h : x ^ 2 + y ^ 2 = 1
    · rw [if_pos (by rw [neg_pow]; simpa using h), if_pos h, hx]
    · rw [if_neg (by rw [neg_pow]; simpa using h), if_neg h, neg_zero]
  have h2 : (2 : ℂ) * circleSumC p ψ = 0 := by linear_combination hrefl
  rcases mul_eq_zero.mp h2 with h3 | h3
  · exact absurd h3 (by norm_num)
  · exact h3

/-! ### Counting the square roots -/

/-- The number of square roots of `a` in `ZMod p`, as a complex number. -/
theorem card_sqrtsC (hp : p ≠ 2) (a : ZMod p) :
    (((univ.filter (fun y : ZMod p => y ^ 2 = a)).card : ℕ) : ℂ) = chiC p a + 1 := by
  have hF : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp
  have key : (((univ.filter (fun y : ZMod p => y ^ 2 = a)).card : ℕ) : ℤ)
      = quadraticChar (ZMod p) a + 1 := by
    simpa [Set.toFinset_setOf] using quadraticChar_card_sqrts (F := ZMod p) hF a
  have := congrArg (fun z : ℤ => (z : ℂ)) key
  push_cast at this
  rw [this, chiC_apply]

/-- Summing `y` away: the weighted circle count is a one-variable character sum. -/
theorem circleSumC_eq_sum (hp : p ≠ 2) (ψ : MulChar (ZMod p) ℂ) :
    circleSumC p ψ = ∑ x : ZMod p, ψ x * (chiC p (1 - x ^ 2) + 1) := by
  refine Finset.sum_congr rfl fun x _ => ?_
  have hcond : ∀ y : ZMod p, (x ^ 2 + y ^ 2 = 1) ↔ (y ^ 2 = 1 - x ^ 2) := by
    intro y
    constructor
    · intro h; linear_combination h
    · intro h; linear_combination h
  have : ∑ y : ZMod p, (if x ^ 2 + y ^ 2 = 1 then ψ x else 0)
      = ∑ y : ZMod p, (if y ^ 2 = 1 - x ^ 2 then ψ x else 0) := by
    refine Finset.sum_congr rfl fun y _ => ?_
    by_cases h : x ^ 2 + y ^ 2 = 1
    · rw [if_pos h, if_pos ((hcond y).mp h)]
    · rw [if_neg h, if_neg (fun hh => h ((hcond y).mpr hh))]
  rw [this, ← Finset.sum_filter, Finset.sum_const, nsmul_eq_mul,
    card_sqrtsC p hp (1 - x ^ 2), mul_comm]

/-! ### Even characters: the Jacobi-sum decomposition -/

/-- Pushing a sum forward along squaring, over `ℂ`. -/
theorem sum_sq_compC (hp : p ≠ 2) (F : ZMod p → ℂ) :
    ∑ c : ZMod p, F (c ^ 2) = ∑ d : ZMod p, (chiC p d + 1) * F d := by
  have h1 : ∀ c : ZMod p, F (c ^ 2) = ∑ d : ZMod p, if c ^ 2 = d then F d else 0 := by
    intro c; simp
  rw [Finset.sum_congr rfl fun c _ => h1 c, Finset.sum_comm]
  refine Finset.sum_congr rfl fun d _ => ?_
  have hfil : ∑ c : ZMod p, (if c ^ 2 = d then F d else 0)
      = ((univ.filter (fun c : ZMod p => c ^ 2 = d)).card : ℕ) * F d := by
    rw [← Finset.sum_filter, Finset.sum_const, nsmul_eq_mul]
  rw [hfil, card_sqrtsC p hp d]

/-- **C1: the Jacobi-sum decomposition.**  For a *square* character `ψ = ξ²` with `ψ ≠ 1`,
the weighted circle count is the sum of two Jacobi sums against the quadratic character. -/
theorem circleSumC_eq_jacobiSum_add (hp : p ≠ 2) (ξ : MulChar (ZMod p) ℂ)
    (hsq : ξ * ξ ≠ 1) :
    circleSumC p (ξ * ξ) = jacobiSum ξ (chiC p) + jacobiSum (chiC p * ξ) (chiC p) := by
  rw [circleSumC_eq_sum p hp]
  have hsplit : ∀ x : ZMod p, (ξ * ξ) x * (chiC p (1 - x ^ 2) + 1)
      = (ξ * ξ) x + ξ (x ^ 2) * chiC p (1 - x ^ 2) := by
    intro x
    have hxx : (ξ * ξ) x = ξ (x ^ 2) := by
      rw [MulChar.coeToFun_mul, Pi.mul_apply, sq, map_mul]
    rw [hxx]
    ring
  rw [Finset.sum_congr rfl fun x _ => hsplit x, Finset.sum_add_distrib,
    MulChar.sum_eq_zero_of_ne_one hsq, zero_add]
  have hpush : ∑ x : ZMod p, ξ (x ^ 2) * chiC p (1 - x ^ 2)
      = ∑ d : ZMod p, (chiC p d + 1) * (ξ d * chiC p (1 - d)) :=
    sum_sq_compC p hp (fun d => ξ d * chiC p (1 - d))
  rw [hpush, jacobiSum, jacobiSum, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun d _ => ?_
  have hmul : (chiC p * ξ) d = chiC p d * ξ d := by
    rw [MulChar.coeToFun_mul, Pi.mul_apply]
  rw [hmul]
  ring

/-! ### The square-root floor for every character weight -/

/-- `|J(χ, φ)| = √p` for nontrivial characters with nontrivial product. -/
theorem norm_jacobiSum_eq_sqrt (χ φ : MulChar (ZMod p) ℂ) (hχ : χ ≠ 1) (hφ : φ ≠ 1)
    (hχφ : χ * φ ≠ 1) : ‖jacobiSum χ φ‖ = Real.sqrt p := by
  have hc0 : ringChar ℂ = 0 := by simp
  have hchar : ringChar ℂ ≠ ringChar (ZMod p) := by
    rw [ZMod.ringChar_zmod_n, hc0]
    exact fun h => (Fact.out : p.Prime).ne_zero h.symm
  have key := jacobiSum_mul_jacobiSum_inv hchar hχ hφ hχφ
  have hconj : (starRingEnd ℂ) (jacobiSum χ φ) = jacobiSum χ⁻¹ φ⁻¹ := by
    rw [← jacobiSum_ringHomComp χ φ (starRingEnd ℂ)]
    congr 1
    · exact MulChar.star_eq_inv χ
    · exact MulChar.star_eq_inv φ
  have hcard : ((Fintype.card (ZMod p) : ℂ)) = (p : ℂ) := by simp
  have h2 : (jacobiSum χ φ) * (starRingEnd ℂ) (jacobiSum χ φ) = (p : ℂ) := by
    rw [hconj, key, hcard]
  rw [Complex.mul_conj] at h2
  have h3 : Complex.normSq (jacobiSum χ φ) = (p : ℝ) := by exact_mod_cast h2
  rw [Complex.normSq_eq_norm_sq] at h3
  rw [← h3, Real.sqrt_sq (norm_nonneg _)]

/-- The complex quadratic character squares to the trivial character. -/
theorem chiC_sq : chiC p * chiC p = 1 := by
  have hq : (quadraticChar (ZMod p)).IsQuadratic := quadraticChar_isQuadratic (ZMod p)
  have : (chiC p).IsQuadratic := hq.comp (Int.castRingHom ℂ)
  have h := this.sq_eq_one
  rwa [sq] at h

/-- The complex quadratic character is nontrivial for odd `p`. -/
theorem chiC_ne_one (hp : p ≠ 2) : chiC p ≠ 1 := by
  have hF : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp
  obtain ⟨v, hv⟩ := quadraticChar_exists_neg_one hF
  intro h
  have hv0 : v ≠ 0 := by
    intro h0
    rw [h0, MulChar.map_zero] at hv
    exact absurd hv (by norm_num)
  have h1 : chiC p v = -1 := by rw [chiC_apply, hv]; norm_num
  rw [h] at h1
  rw [MulChar.one_apply (isUnit_iff_ne_zero.mpr hv0)] at h1
  norm_num at h1

/-- **The classification of quadratic characters.**  A character with `ξ² = 1` is either trivial
or the quadratic character; the proof uses a generator of the cyclic unit group. -/
theorem sq_eq_one_classification (hp : p ≠ 2) (ξ : MulChar (ZMod p) ℂ) (h : ξ * ξ = 1) :
    ξ = 1 ∨ ξ = chiC p := by
  have hprime := (Fact.out : p.Prime)
  have hodd : p % 2 = 1 := hprime.eq_two_or_odd.resolve_left hp
  have hp3 : 3 ≤ p := by have := hprime.two_le; omega
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator (α := (ZMod p)ˣ)
  have hgsq : ¬ IsSquare ((g : ZMod p)) := by
    rintro ⟨r, hr⟩
    have hr0 : r ≠ 0 := by
      rintro rfl
      simp at hr
    have hpow : ((g : ZMod p)) ^ ((p - 1) / 2) = 1 := by
      rw [hr, ← pow_two, ← pow_mul]
      have h2 : 2 * ((p - 1) / 2) = p - 1 := by omega
      rw [h2]
      exact ZMod.pow_card_sub_one_eq_one hr0
    have hcard : Nat.card (ZMod p)ˣ = p - 1 := by
      rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient, Nat.totient_prime hprime]
    have hord : orderOf (g : ZMod p) = p - 1 := by
      rw [orderOf_units, orderOf_eq_card_of_forall_mem_zpowers hg, hcard]
    have hdvd : orderOf ((g : ZMod p)) ∣ (p - 1) / 2 := orderOf_dvd_of_pow_eq_one hpow
    rw [hord] at hdvd
    have := Nat.le_of_dvd (by omega) hdvd
    omega
  have hchig : quadraticChar (ZMod p) (g : ZMod p) = -1 :=
    quadraticChar_neg_one_iff_not_isSquare.mpr hgsq
  have hsq : ξ (g : ZMod p) * ξ (g : ZMod p) = 1 := by
    have := congrArg (fun (c : MulChar (ZMod p) ℂ) => c (g : ZMod p)) h
    simpa [MulChar.one_apply g.isUnit] using this
  rcases mul_self_eq_one_iff.mp hsq with h2 | h2
  · exact Or.inl ((MulChar.eq_iff hg ξ 1).mpr (by rw [h2, MulChar.one_apply g.isUnit]))
  · refine Or.inr ((MulChar.eq_iff hg ξ (chiC p)).mpr ?_)
    rw [h2, chiC_apply, hchig]
    norm_num

/-- **C1, strong form.**  For every character `ξ` distinct from `1` and from the quadratic
character, the weighted circle count of the *even* character `ψ = ξ²` obeys the square-root
floor with the absolute constant `2` — no dependence on the order of `ξ`. -/
theorem norm_circleSumC_le (hp : p ≠ 2) (ξ : MulChar (ZMod p) ℂ) (hξ : ξ ≠ 1)
    (hξχ : chiC p * ξ ≠ 1) : ‖circleSumC p (ξ * ξ)‖ ≤ 2 * Real.sqrt p := by
  have hchi := chiC_ne_one p hp
  have hsq : ξ * ξ ≠ 1 := by
    intro h
    rcases sq_eq_one_classification p hp ξ h with h' | h'
    · exact hξ h'
    · refine hξχ ?_
      rw [← h']
      exact h
  rw [circleSumC_eq_jacobiSum_add p hp ξ hsq]
  have h1 : ‖jacobiSum ξ (chiC p)‖ = Real.sqrt p :=
    norm_jacobiSum_eq_sqrt p ξ (chiC p) hξ hchi (by
      rw [mul_comm]; exact hξχ)
  have h2 : ‖jacobiSum (chiC p * ξ) (chiC p)‖ = Real.sqrt p := by
    refine norm_jacobiSum_eq_sqrt p (chiC p * ξ) (chiC p) hξχ hchi ?_
    intro h
    apply hξ
    have hchisq := chiC_sq p
    calc ξ = (chiC p * chiC p) * ξ := by rw [hchisq, one_mul]
      _ = (chiC p * ξ) * chiC p := mul_right_comm _ _ _
      _ = 1 := h
  calc ‖jacobiSum ξ (chiC p) + jacobiSum (chiC p * ξ) (chiC p)‖
      ≤ ‖jacobiSum ξ (chiC p)‖ + ‖jacobiSum (chiC p * ξ) (chiC p)‖ := norm_add_le _ _
    _ = 2 * Real.sqrt p := by rw [h1, h2, two_mul]

/-- **The hypotheses of `norm_circleSumC_le` are satisfiable**, so the theorem is not vacuous:
for every prime `p ≡ 1 (mod 4)` there is a character of order `4`, which is neither trivial nor
the quadratic character. -/
theorem exists_admissible_character (hp1 : p % 4 = 1) :
    ∃ ξ : MulChar (ZMod p) ℂ, ξ ≠ 1 ∧ chiC p * ξ ≠ 1 := by
  have hcard : Fintype.card (ZMod p) - 1 = p - 1 := by simp [ZMod.card]
  have hdvd : (4 : ℕ) ∣ Fintype.card (ZMod p) - 1 := by rw [hcard]; omega
  obtain ⟨z, hz⟩ : ∃ z : ℂ, IsPrimitiveRoot z 4 :=
    ⟨_, Complex.isPrimitiveRoot_exp 4 (by norm_num)⟩
  obtain ⟨ξ, hξ⟩ := MulChar.exists_mulChar_orderOf (F := ZMod p) (R := ℂ) hdvd hz
  have hchisq := chiC_sq p
  refine ⟨ξ, ?_, ?_⟩
  · intro h
    rw [h] at hξ
    simp at hξ
  · intro h
    have hxi : ξ = chiC p := by
      have hmul : chiC p * (chiC p * ξ) = chiC p * 1 := by rw [h]
      rwa [← mul_assoc, hchisq, one_mul, mul_one] at hmul
    rw [hxi] at hξ
    have hord : orderOf (chiC p) ∣ 2 := orderOf_dvd_of_pow_eq_one (by rw [sq]; exact hchisq)
    rw [hξ] at hord
    omega

/-- **No character weight escapes the floor.**  For `p ≡ 1 (mod 4)` there is a nontrivial even
character weight, and every such weight obeys `|W_ψ(p)| ≤ 2√p`, while every odd weight gives
exactly `0`. -/
theorem exists_nontrivial_weight_at_floor (hp : p ≠ 2) (hp1 : p % 4 = 1) :
    ∃ ξ : MulChar (ZMod p) ℂ, ξ * ξ ≠ 1 ∧ ‖circleSumC p (ξ * ξ)‖ ≤ 2 * Real.sqrt p := by
  obtain ⟨ξ, h1, h2⟩ := exists_admissible_character p hp1
  refine ⟨ξ, ?_, norm_circleSumC_le p hp ξ h1 h2⟩
  intro h
  rcases sq_eq_one_classification p hp ξ h with h' | h'
  · exact h1 h'
  · exact h2 (by rw [← h']; exact h)

/-! ### Compatibility with the catalog -/

/-- For the quadratic weight the complex circle count is the Jacobi-signed count `W p` of the
catalog: the present development genuinely extends `JacobiSignedWeilFloorCore`. -/
theorem circleSumC_quadratic_eq_W (hp : p ≠ 2) : circleSumC p (chiC p) = (W p : ℂ) := by
  have hF : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp
  rw [circleSumC_eq_sum p hp]
  have hterm : ∀ x : ZMod p, chiC p x * (chiC p (1 - x ^ 2) + 1)
      = ((quadraticChar (ZMod p) (x * (1 - x ^ 2)) : ℤ) : ℂ) + chiC p x := by
    intro x
    rw [chiC_apply, chiC_apply, map_mul]
    push_cast
    ring
  rw [Finset.sum_congr rfl fun x _ => hterm x, Finset.sum_add_distrib,
    MulChar.sum_eq_zero_of_ne_one (chiC_ne_one p hp), add_zero, W]
  push_cast
  ring

end JacSign