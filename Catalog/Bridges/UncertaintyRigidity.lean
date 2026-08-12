import Bridges.FourierSymmetries

/-!
# Rigidity of the Donoho–Stark inequality: flatness and the prime classification

The previous files of this thread proved the Donoho–Stark uncertainty principle
`N ≤ |supp Φ| * |supp 𝓕Φ|` on `ZMod N`, exhibited the extremal family of (translated) subgroup
indicators, and listed as *Conjecture 3* the classification of the equality case. This file
proves the two substantive halves of that conjecture that are available without any new
arithmetic input.

## Main results

* `UncertaintyRigidity.norm_eq_max_of_extremal` : **flatness.** If `Φ ≠ 0` attains equality
  `|supp Φ| * |supp 𝓕Φ| = N`, then `‖Φ‖` is *constant on its support*: every value of `Φ` on its
  support has the maximal modulus. Equivalently `|Φ|` is a multiple of the indicator of its
  support. This is the first half of the conjectured classification "extremal ⟹ modulated
  indicator of a coset".
* `UncertaintyRigidity.flat_of_extremal` : the symmetric form of the same statement.
* `UncertaintyRigidity.dft_flat_of_extremal` : the dual flatness statement, for `𝓕Φ`.
* `UncertaintyRigidity.uncertainty_strict_of_norms_ne` : the contrapositive, a strict uncertainty
  principle: a nonzero function taking two different nonzero moduli satisfies
  `N < |supp Φ| * |supp 𝓕Φ|`. In particular Donoho–Stark is never sharp for such functions.
* `UncertaintyRigidity.prime_extremal_classification` : **the classification of extremals at
  prime modulus.** At prime `p` a nonzero extremal is either a scalar multiple of a delta
  function or a scalar multiple of a character `j ↦ χ(k₀ j)`. These are exactly the modulated
  indicators of the two cosets structures available in `ZMod p` (points, and the whole group),
  confirming Conjecture 3 for `N` prime.
* `UncertaintyRigidity.prime_extremal_additive` : the additive support sum of a prime extremal is
  exactly `p + 1`, i.e. prime extremals saturate Tao's bound.

The proofs are equality analyses of the three-step inequality chain used to prove Donoho–Stark:
`N‖Φ j₀‖ = ‖𝓕𝓕Φ(-j₀)‖ ≤ |supp 𝓕Φ| · Σ_{j ∈ supp Φ} ‖Φ j‖ ≤ |supp 𝓕Φ| · |supp Φ| · ‖Φ j₀‖`,
whose two ends coincide exactly when the transform is extremal.
-/

open Finset ZMod FourierUncertainty

namespace UncertaintyRigidity

variable {N : ℕ} [NeZero N]

/-! ## 1. A sharper bound on the Fourier coefficients -/

/-- Every Fourier coefficient is bounded by the `ℓ¹` norm of the function, computed over its
support. This refines `FourierUncertainty.norm_dft_le`, whose bound `|supp Φ| · M` is obtained
from this one by estimating each term by the maximum. -/
theorem norm_dft_le_sum (Φ : ZMod N → ℂ) (k : ZMod N) :
    ‖𝓕 Φ k‖ ≤ ∑ j ∈ fsupport Φ, ‖Φ j‖ := by
  classical
  rw [ZMod.dft_apply]
  have hsum : ∑ j : ZMod N, stdAddChar (-(j * k)) • Φ j
      = ∑ j ∈ fsupport Φ, stdAddChar (-(j * k)) • Φ j := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    have : Φ x = 0 := by
      by_contra h
      exact hx (mem_fsupport.2 h)
    simp [this]
  rw [hsum]
  refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun i _ => ?_)
  rw [smul_eq_mul, norm_mul, AddChar.norm_apply, one_mul]

omit [NeZero N] in
/-- The maximum of `‖Φ‖` is positive when `Φ ≠ 0`. -/
theorem max_norm_pos {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0) {j₀ : ZMod N}
    (hj₀ : ∀ j, ‖Φ j‖ ≤ ‖Φ j₀‖) : 0 < ‖Φ j₀‖ := by
  rcases lt_or_eq_of_le (norm_nonneg (Φ j₀)) with h | h
  · exact h
  · exact absurd (funext fun j => by
      have : ‖Φ j‖ ≤ 0 := by linarith [hj₀ j]
      simpa using le_antisymm this (norm_nonneg _)) hΦ

/-! ## 2. Flatness of the extremals -/

/-- **Equality analysis of the Donoho–Stark chain.** If `Φ` is extremal, the `ℓ¹` norm of `Φ` is
exactly `|supp Φ|` times the maximal modulus; that is, no term of the sum is deficient. -/
theorem sum_norm_eq_of_extremal {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0) {j₀ : ZMod N}
    (hj₀ : ∀ j, ‖Φ j‖ ≤ ‖Φ j₀‖)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N) :
    ∑ j ∈ fsupport Φ, ‖Φ j‖ = (fsupport Φ).card * ‖Φ j₀‖ := by
  classical
  set M : ℝ := ‖Φ j₀‖ with hMdef
  have hMpos : 0 < M := max_norm_pos hΦ hj₀
  set s : ℕ := (fsupport Φ).card with hs
  set t : ℕ := (fsupport (𝓕 Φ)).card with ht
  set S : ℝ := ∑ j ∈ fsupport Φ, ‖Φ j‖ with hS
  -- upper bound on the `ℓ¹` norm
  have hupper : S ≤ (s : ℝ) * M := by
    have := Finset.sum_le_card_nsmul (fsupport Φ) (fun j => ‖Φ j‖) M fun j _ => hj₀ j
    simpa [hS, hs, nsmul_eq_mul] using this
  -- lower bound coming from Fourier inversion
  have h2 : ‖𝓕 (𝓕 Φ) (-j₀)‖ ≤ (t : ℝ) * S :=
    norm_dft_le (𝓕 Φ) S (fun k => norm_dft_le_sum Φ k) (-j₀)
  have h3 : 𝓕 (𝓕 Φ) (-j₀) = (N : ℂ) • Φ j₀ := by
    have := congrFun (ZMod.dft_dft Φ) (-j₀)
    simpa using this
  rw [h3, norm_smul] at h2
  have hlower : (N : ℝ) * M ≤ (t : ℝ) * S := by simpa [hMdef] using h2
  have hNpos : (0 : ℝ) < N := by
    exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne N)
  have htpos : (0 : ℝ) < t := by
    rcases Nat.eq_zero_or_pos t with h | h
    · exfalso
      rw [h] at hlower
      simp only [Nat.cast_zero, zero_mul] at hlower
      nlinarith
    · exact_mod_cast h
  have hst : (t : ℝ) * (s : ℝ) = N := by
    have : (s * t : ℕ) = N := hext
    push_cast [← this]
    ring
  have hge : (s : ℝ) * M ≤ S := by
    have h4 : (t : ℝ) * ((s : ℝ) * M) ≤ (t : ℝ) * S := by
      calc (t : ℝ) * ((s : ℝ) * M) = ((t : ℝ) * (s : ℝ)) * M := by ring
        _ = (N : ℝ) * M := by rw [hst]
        _ ≤ (t : ℝ) * S := hlower
    exact le_of_mul_le_mul_left h4 htpos
  linarith

/-- **Flatness of Donoho–Stark extremals.** If a nonzero `Φ` attains
`|supp Φ| * |supp 𝓕Φ| = N`, then every value of `Φ` on its support has the same (maximal)
modulus. So the modulus of an extremal is a positive multiple of the indicator of its support:
the first half of the conjectured classification of extremals. -/
theorem norm_eq_max_of_extremal {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0) {j₀ : ZMod N}
    (hj₀ : ∀ j, ‖Φ j‖ ≤ ‖Φ j₀‖)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N) :
    ∀ j ∈ fsupport Φ, ‖Φ j‖ = ‖Φ j₀‖ := by
  classical
  have hsum := sum_norm_eq_of_extremal hΦ hj₀ hext
  have hconst : ∑ _j ∈ fsupport Φ, ‖Φ j₀‖ = (fsupport Φ).card * ‖Φ j₀‖ := by
    rw [Finset.sum_const, nsmul_eq_mul]
  have heq : ∑ j ∈ fsupport Φ, ‖Φ j‖ = ∑ _j ∈ fsupport Φ, ‖Φ j₀‖ := by
    rw [hsum, hconst]
  exact (Finset.sum_eq_sum_iff_of_le fun j _ => hj₀ j).1 heq

/-- **Flatness, symmetric form.** An extremal takes a single modulus on its support. -/
theorem flat_of_extremal {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N)
    {a b : ZMod N} (ha : a ∈ fsupport Φ) (hb : b ∈ fsupport Φ) :
    ‖Φ a‖ = ‖Φ b‖ := by
  classical
  obtain ⟨j₀, -, hj₀⟩ :=
    Finset.exists_max_image (Finset.univ : Finset (ZMod N)) (fun j => ‖Φ j‖) ⟨0, mem_univ 0⟩
  have hmax : ∀ j, ‖Φ j‖ ≤ ‖Φ j₀‖ := fun j => hj₀ j (mem_univ j)
  rw [norm_eq_max_of_extremal hΦ hmax hext a ha,
    norm_eq_max_of_extremal hΦ hmax hext b hb]

/-- **A strict uncertainty principle.** A nonzero function taking two distinct nonzero moduli is
never a Donoho–Stark extremal: for it the inequality is strict. This is the contrapositive of
flatness, and it strengthens `FourierUncertainty.donoho_stark` for all non-flat functions. -/
theorem uncertainty_strict_of_norms_ne {Φ : ZMod N → ℂ} {a b : ZMod N}
    (ha : Φ a ≠ 0) (hb : Φ b ≠ 0) (hne : ‖Φ a‖ ≠ ‖Φ b‖) :
    N < (fsupport Φ).card * (fsupport (𝓕 Φ)).card := by
  classical
  have hΦ : Φ ≠ 0 := fun h => ha (by rw [h]; rfl)
  refine lt_of_le_of_ne (donoho_stark Φ hΦ) fun hEq => hne ?_
  exact flat_of_extremal hΦ hEq.symm (mem_fsupport.2 ha) (mem_fsupport.2 hb)

/-- If `Φ` is extremal then so is its Fourier transform, since the double transform has the same
support size as `Φ`. -/
theorem dft_extremal_of_extremal {Φ : ZMod N → ℂ}
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N) :
    (fsupport (𝓕 Φ)).card * (fsupport (𝓕 (𝓕 Φ))).card = N := by
  rw [FourierSymmetries.card_fsupport_dft_dft, Nat.mul_comm]
  exact hext

theorem dft_ne_zero_of_ne_zero {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0) : 𝓕 Φ ≠ 0 := by
  intro h
  apply hΦ
  funext j
  have h3 : 𝓕 (𝓕 Φ) (-j) = (N : ℂ) • Φ j := by
    have := congrFun (ZMod.dft_dft Φ) (-j)
    simpa using this
  have hzero : 𝓕 (𝓕 Φ) (-j) = 0 := by rw [h]; simp
  rw [hzero] at h3
  have hN : (N : ℂ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne N)
  have := (smul_eq_zero.1 h3.symm).resolve_left hN
  simpa using this

/-- **Dual flatness.** The Fourier transform of an extremal is also flat on its support. Hence an
extremal pair `(Φ, 𝓕Φ)` consists of two modulated indicators of their supports. -/
theorem dft_flat_of_extremal {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N)
    {a b : ZMod N} (ha : a ∈ fsupport (𝓕 Φ)) (hb : b ∈ fsupport (𝓕 Φ)) :
    ‖𝓕 Φ a‖ = ‖𝓕 Φ b‖ :=
  flat_of_extremal (dft_ne_zero_of_ne_zero hΦ) (dft_extremal_of_extremal hext) ha hb

/-! ## 3. The classification of extremals at prime modulus -/

section Structure

/-- A function with one-point support is a scalar multiple of a delta function. -/
theorem eq_smul_delta_of_card_support_eq_one {Φ : ZMod N → ℂ}
    (h : (fsupport Φ).card = 1) :
    ∃ a : ZMod N, ∃ c : ℂ, c ≠ 0 ∧ ∀ j, Φ j = c * delta a j := by
  classical
  obtain ⟨a, ha⟩ := Finset.card_eq_one.1 h
  refine ⟨a, Φ a, ?_, ?_⟩
  · have : a ∈ fsupport Φ := by rw [ha]; exact Finset.mem_singleton_self a
    exact mem_fsupport.1 this
  · intro j
    by_cases hj : j = a
    · subst hj
      simp [delta]
    · have : j ∉ fsupport Φ := by
        rw [ha, Finset.mem_singleton]
        exact hj
      have h0 : Φ j = 0 := by
        by_contra hne
        exact this (mem_fsupport.2 hne)
      simp [delta, hj, h0]

/-- A function whose spectrum is a single point is a scalar multiple of a character: this is
Fourier inversion for a one-term spectrum. -/
theorem eq_smul_char_of_card_spectrum_eq_one {Φ : ZMod N → ℂ}
    (h : (fsupport (𝓕 Φ)).card = 1) :
    ∃ k₀ : ZMod N, ∃ c : ℂ, c ≠ 0 ∧ ∀ j, Φ j = c * stdAddChar (k₀ * j) := by
  classical
  obtain ⟨k₀, hk₀⟩ := Finset.card_eq_one.1 h
  have hne : 𝓕 Φ k₀ ≠ 0 := by
    have : k₀ ∈ fsupport (𝓕 Φ) := by rw [hk₀]; exact Finset.mem_singleton_self k₀
    exact mem_fsupport.1 this
  have hsub : ∀ k, k ≠ k₀ → 𝓕 Φ k = 0 := by
    intro k hk
    by_contra hkne
    have : k ∈ fsupport (𝓕 Φ) := mem_fsupport.2 hkne
    rw [hk₀, Finset.mem_singleton] at this
    exact hk this
  have hN : (N : ℂ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne N)
  refine ⟨k₀, 𝓕 Φ k₀ / N, div_ne_zero hne hN, ?_⟩
  intro j
  have hdd : 𝓕 (𝓕 Φ) (-j) = (N : ℂ) • Φ j := by
    have := congrFun (ZMod.dft_dft Φ) (-j)
    simpa using this
  have hsingle : 𝓕 (𝓕 Φ) (-j) = stdAddChar (-(k₀ * -j)) * 𝓕 Φ k₀ :=
    FourierSymmetries.dft_of_single_support hsub (-j)
  rw [hsingle] at hdd
  have hchar : (-(k₀ * -j)) = k₀ * j := by ring
  rw [hchar] at hdd
  rw [smul_eq_mul] at hdd
  field_simp
  linear_combination -hdd

variable {p : ℕ} [Fact p.Prime]

theorem card_support_eq_one_or_card_spectrum_eq_one {Φ : ZMod p → ℂ}
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = p) :
    (fsupport Φ).card = 1 ∨ (fsupport (𝓕 Φ)).card = 1 := by
  have hp : p.Prime := Fact.out
  have hdvd : (fsupport Φ).card ∣ p := ⟨_, hext.symm⟩
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h | h
  · exact Or.inl h
  · right
    rw [h] at hext
    have hppos : 0 < p := hp.pos
    have : p * (fsupport (𝓕 Φ)).card = p * 1 := by rw [hext, Nat.mul_one]
    exact Nat.eq_of_mul_eq_mul_left hppos this

/-- **Classification of Donoho–Stark extremals at prime modulus (Conjecture 3 for `N = p`).**
A nonzero function on `ZMod p` attaining `|supp Φ| * |supp 𝓕Φ| = p` is either a scalar multiple
of a delta function, or a scalar multiple of an additive character. These are precisely the
modulated indicators of the cosets of the two subgroups of `ZMod p`, so the conjectured
"extremal ⟹ modulated coset indicator" holds at prime modulus. -/
theorem prime_extremal_classification {Φ : ZMod p → ℂ}
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = p) :
    (∃ a : ZMod p, ∃ c : ℂ, c ≠ 0 ∧ ∀ j, Φ j = c * delta a j) ∨
      (∃ k₀ : ZMod p, ∃ c : ℂ, c ≠ 0 ∧ ∀ j, Φ j = c * stdAddChar (k₀ * j)) := by
  rcases card_support_eq_one_or_card_spectrum_eq_one hext with h | h
  · exact Or.inl (eq_smul_delta_of_card_support_eq_one h)
  · exact Or.inr (eq_smul_char_of_card_spectrum_eq_one h)

/-- **Prime extremals saturate Tao's bound.** At prime modulus the additive support sum of a
Donoho–Stark extremal is exactly `p + 1`, the value conjectured to be the global minimum. -/
theorem prime_extremal_additive {Φ : ZMod p → ℂ}
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = p) :
    (fsupport Φ).card + (fsupport (𝓕 Φ)).card = p + 1 := by
  rcases card_support_eq_one_or_card_spectrum_eq_one hext with h | h
  · have := FourierSymmetries.full_spectrum_of_card_support_eq_one h
    omega
  · have := FourierSymmetries.full_support_of_card_spectrum_eq_one h
    omega

/-- At prime modulus a flat non-extremal example is easy to see from the classification: any
function with support of size `2 ≤ k ≤ p - 1` is *not* extremal. -/
theorem not_extremal_of_card_support_between {Φ : ZMod p → ℂ}
    (h1 : 2 ≤ (fsupport Φ).card) (h2 : (fsupport Φ).card < p) :
    (fsupport Φ).card * (fsupport (𝓕 Φ)).card ≠ p := by
  intro hext
  rcases card_support_eq_one_or_card_spectrum_eq_one hext with h | h
  · omega
  · have := FourierSymmetries.full_support_of_card_spectrum_eq_one h
    omega

end Structure

end UncertaintyRigidity