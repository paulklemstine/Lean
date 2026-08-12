import Bridges.UncertaintyRigidity

/-!
# Phase rigidity of Donoho–Stark extremals, and the orthogonality relation

`Catalog/Bridges/UncertaintyRigidity.lean` proved *modulus* rigidity: an extremal of the
Donoho–Stark inequality is flat on its support. This file proves *phase* rigidity, which is the
remaining analytic input to the conjectured classification of extremals as modulated coset
indicators.

The equality `‖𝓕Φ k‖ = ∑_{j ∈ supp Φ} ‖Φ j‖`, valid for every `k` in the spectrum of an
extremal, is an equality case of the triangle inequality in `ℂ`; it forces all the terms
`χ(-jk) Φ j` to point in the same direction. Comparing the resulting phases at two spectral
points yields the clean algebraic relation

`(j - j') * (k - k') = 0`  for all `j, j' ∈ supp Φ` and `k, k' ∈ supp 𝓕Φ`,

i.e. the difference set of the support annihilates the difference set of the spectrum.

## Main results

* `ExtremalCosets.sum_alignment` : the equality case of the triangle inequality for a finite sum
  of complex numbers.
* `ExtremalCosets.norm_dft_eq_of_extremal` : for an extremal, every nonzero Fourier coefficient
  has modulus exactly `∑_{j ∈ supp Φ} ‖Φ j‖ = |supp Φ| · max ‖Φ‖`.
* `ExtremalCosets.phase_of_extremal` : phase rigidity, `χ(-jk) Φ j = ‖Φ j‖ · θ_k` for a single
  unimodular `θ_k` depending only on `k`.
* `ExtremalCosets.extremal_orthogonality` : the orthogonality relation
  `(j - j') * (k - k') = 0` above.
* `ExtremalCosets.extremal_support_sub_annihilator` : consequently the differences of the support
  lie in the annihilator of the differences of the spectrum — the structural statement that makes
  the support a coset once the annihilator is counted.
* `ExtremalCosets.extremal_char_on_support` : an extremal is, on its support, a single modulated
  flat function: `Φ j = χ((j - j₀) k) Φ j₀` for every spectral point `k`.
-/

open Finset ZMod FourierUncertainty UncertaintyRigidity

namespace ExtremalCosets

/-! ## 1. The equality case of the triangle inequality in `ℂ` -/

/-- A complex number whose real part equals its modulus is a nonnegative real. -/
theorem eq_norm_of_re_eq_norm {w : ℂ} (h : w.re = ‖w‖) : w = (‖w‖ : ℂ) := by
  have hsq : ‖w‖ ^ 2 = w.re ^ 2 + w.im ^ 2 := by
    rw [← Complex.normSq_eq_norm_sq]
    simp [Complex.normSq_apply]
    ring
  have him : w.im = 0 := by
    rw [← h] at hsq
    nlinarith [sq_nonneg w.im]
  apply Complex.ext <;> simp [him, ← h]

/-- **Equality case of the triangle inequality.** If a finite sum of complex numbers has modulus
equal to the sum of the moduli, in the direction of a unimodular `θ`, then every summand is a
nonnegative real multiple of `θ`. -/
theorem sum_alignment {ι : Type*} (s : Finset ι) (f : ι → ℂ) (θ : ℂ) (hθ : ‖θ‖ = 1)
    (h : ∑ i ∈ s, f i = ((∑ i ∈ s, ‖f i‖ : ℝ) : ℂ) * θ) :
    ∀ i ∈ s, f i = (‖f i‖ : ℂ) * θ := by
  classical
  set c : ℂ := (starRingEnd ℂ) θ with hc
  have hcθ : c * θ = 1 := by
    rw [hc, mul_comm, Complex.mul_conj]
    norm_cast
    simp [Complex.normSq_eq_norm_sq, hθ]
  have hcnorm : ‖c‖ = 1 := by rw [hc, RCLike.norm_conj, hθ]
  -- the rotated summands
  set g : ι → ℂ := fun i => c * f i with hg
  have hgsum : ∑ i ∈ s, g i = ((∑ i ∈ s, ‖f i‖ : ℝ) : ℂ) := by
    calc ∑ i ∈ s, g i = c * ∑ i ∈ s, f i := by rw [hg, Finset.mul_sum]
      _ = c * (((∑ i ∈ s, ‖f i‖ : ℝ) : ℂ) * θ) := by rw [h]
      _ = (c * θ) * ((∑ i ∈ s, ‖f i‖ : ℝ) : ℂ) := by ring
      _ = ((∑ i ∈ s, ‖f i‖ : ℝ) : ℂ) := by rw [hcθ, one_mul]
  have hgnorm : ∀ i, ‖g i‖ = ‖f i‖ := by
    intro i
    rw [hg, norm_mul, hcnorm, one_mul]
  have hre : ∑ i ∈ s, (g i).re = ∑ i ∈ s, ‖f i‖ := by
    have := congrArg Complex.re hgsum
    rwa [Complex.re_sum, Complex.ofReal_re] at this
  have hle : ∀ i ∈ s, (g i).re ≤ ‖f i‖ := by
    intro i _
    rw [← hgnorm i]
    exact Complex.re_le_norm (g i)
  have heq : ∀ i ∈ s, (g i).re = ‖f i‖ :=
    (Finset.sum_eq_sum_iff_of_le hle).1 hre
  intro i hi
  have hgi : g i = (‖f i‖ : ℂ) := by
    have := eq_norm_of_re_eq_norm (w := g i) (by rw [heq i hi, hgnorm i])
    rwa [hgnorm i] at this
  calc f i = (c * θ) * f i := by rw [hcθ, one_mul]
    _ = θ * g i := by rw [hg]; ring
    _ = (‖f i‖ : ℂ) * θ := by rw [hgi]; ring

/-! ## 2. The modulus of the Fourier coefficients of an extremal -/

variable {N : ℕ} [NeZero N]

/-- The Fourier transform as a sum over the support. -/
theorem dft_sum_fsupport (Φ : ZMod N → ℂ) (k : ZMod N) :
    𝓕 Φ k = ∑ j ∈ fsupport Φ, stdAddChar (-(j * k)) * Φ j := by
  classical
  rw [ZMod.dft_apply]
  have hsub : ∑ j : ZMod N, stdAddChar (-(j * k)) • Φ j
      = ∑ j ∈ fsupport Φ, stdAddChar (-(j * k)) • Φ j := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    have : Φ x = 0 := by
      by_contra h
      exact hx (mem_fsupport.2 h)
    simp [this]
  rw [hsub]
  exact Finset.sum_congr rfl fun j _ => by rw [smul_eq_mul]

/-- **The Fourier coefficients of an extremal are as large as possible.** For a Donoho–Stark
extremal, every nonzero Fourier coefficient has modulus equal to the full `ℓ¹` norm of `Φ`. -/
theorem norm_dft_eq_of_extremal {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N)
    {k : ZMod N} (hk : k ∈ fsupport (𝓕 Φ)) :
    ‖𝓕 Φ k‖ = ∑ j ∈ fsupport Φ, ‖Φ j‖ := by
  classical
  obtain ⟨j₀, -, hj₀'⟩ :=
    Finset.exists_max_image (Finset.univ : Finset (ZMod N)) (fun j => ‖Φ j‖) ⟨0, mem_univ 0⟩
  have hj₀ : ∀ j, ‖Φ j‖ ≤ ‖Φ j₀‖ := fun j => hj₀' j (mem_univ j)
  set M : ℝ := ‖Φ j₀‖ with hM
  have hMpos : 0 < M := max_norm_pos hΦ hj₀
  set s : ℕ := (fsupport Φ).card with hs
  set t : ℕ := (fsupport (𝓕 Φ)).card with ht
  set S : ℝ := ∑ j ∈ fsupport Φ, ‖Φ j‖ with hS
  have hSval : S = (s : ℝ) * M := sum_norm_eq_of_extremal hΦ hj₀ hext
  -- a maximiser of the Fourier coefficients
  obtain ⟨k₁, -, hk₁'⟩ :=
    Finset.exists_max_image (Finset.univ : Finset (ZMod N)) (fun k => ‖𝓕 Φ k‖) ⟨0, mem_univ 0⟩
  have hk₁ : ∀ k, ‖𝓕 Φ k‖ ≤ ‖𝓕 Φ k₁‖ := fun k => hk₁' k (mem_univ k)
  have h2 : ‖𝓕 (𝓕 Φ) (-j₀)‖ ≤ (t : ℝ) * ‖𝓕 Φ k₁‖ := norm_dft_le (𝓕 Φ) _ hk₁ (-j₀)
  have h3 : 𝓕 (𝓕 Φ) (-j₀) = (N : ℂ) • Φ j₀ := by
    have := congrFun (ZMod.dft_dft Φ) (-j₀)
    simpa using this
  rw [h3, norm_smul] at h2
  have hlower : (N : ℝ) * M ≤ (t : ℝ) * ‖𝓕 Φ k₁‖ := by simpa [hM] using h2
  have hupper : ‖𝓕 Φ k₁‖ ≤ S := norm_dft_le_sum Φ k₁
  have hst : (t : ℝ) * (s : ℝ) = N := by
    have hcast : (s * t : ℕ) = N := hext
    push_cast [← hcast]; ring
  have htpos : (0 : ℝ) < t := by
    rcases Nat.eq_zero_or_pos t with h | h
    · exfalso
      rw [h] at hlower
      simp only [Nat.cast_zero, zero_mul] at hlower
      have hNpos : (0 : ℝ) < N := by exact_mod_cast Nat.pos_of_ne_zero (NeZero.ne N)
      nlinarith
    · exact_mod_cast h
  have hk₁eq : ‖𝓕 Φ k₁‖ = S := by
    have hge : S ≤ ‖𝓕 Φ k₁‖ := by
      have h4 : (t : ℝ) * S ≤ (t : ℝ) * ‖𝓕 Φ k₁‖ := by
        calc (t : ℝ) * S = ((t : ℝ) * (s : ℝ)) * M := by rw [hSval]; ring
          _ = (N : ℝ) * M := by rw [hst]
          _ ≤ (t : ℝ) * ‖𝓕 Φ k₁‖ := hlower
      exact le_of_mul_le_mul_left h4 htpos
    linarith
  -- `k₁` lies in the spectrum, so flatness of the spectrum transfers the value to `k`
  have hk₁mem : k₁ ∈ fsupport (𝓕 Φ) := by
    refine mem_fsupport.2 fun hzero => ?_
    have : S = 0 := by rw [← hk₁eq, hzero, norm_zero]
    rw [hSval] at this
    have hspos : (0 : ℝ) < s := by
      rcases Nat.eq_zero_or_pos s with h | h
      · exfalso
        rw [hs] at h
        have : Φ j₀ = 0 := by
          by_contra hne
          have : j₀ ∈ fsupport Φ := mem_fsupport.2 hne
          rw [Finset.card_eq_zero.1 h] at this
          simp at this
        rw [hM, this] at hMpos
        simp at hMpos
      · exact_mod_cast h
    nlinarith
  rw [dft_flat_of_extremal hΦ hext hk hk₁mem, hk₁eq]

/-! ## 3. Phase rigidity -/

/-- **Phase rigidity of extremals.** For every spectral point `k` of a Donoho–Stark extremal, all
the terms `χ(-jk) Φ j`, `j ∈ supp Φ`, are equal to `‖Φ j‖` times one and the same unimodular
number, namely the phase of `𝓕Φ k`. -/
theorem phase_of_extremal {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N)
    {k : ZMod N} (hk : k ∈ fsupport (𝓕 Φ)) :
    ∀ j ∈ fsupport Φ,
      stdAddChar (-(j * k)) * Φ j = (‖Φ j‖ : ℂ) * (𝓕 Φ k / (‖𝓕 Φ k‖ : ℂ)) := by
  classical
  have hkne : 𝓕 Φ k ≠ 0 := mem_fsupport.1 hk
  have hnormne : (‖𝓕 Φ k‖ : ℂ) ≠ 0 := by
    simpa using (norm_ne_zero_iff.2 hkne)
  set θ : ℂ := 𝓕 Φ k / (‖𝓕 Φ k‖ : ℂ) with hθdef
  have hθ : ‖θ‖ = 1 := by
    rw [hθdef, norm_div, Complex.norm_real, norm_norm,
      div_self (norm_ne_zero_iff.2 hkne)]
  set f : ZMod N → ℂ := fun j => stdAddChar (-(j * k)) * Φ j with hf
  have hfnorm : ∀ j, ‖f j‖ = ‖Φ j‖ := by
    intro j
    rw [hf, norm_mul, AddChar.norm_apply, one_mul]
  have hsum : ∑ j ∈ fsupport Φ, f j = ((∑ j ∈ fsupport Φ, ‖f j‖ : ℝ) : ℂ) * θ := by
    have h1 : ∑ j ∈ fsupport Φ, f j = 𝓕 Φ k := (dft_sum_fsupport Φ k).symm
    have h2 : (∑ j ∈ fsupport Φ, ‖f j‖) = ‖𝓕 Φ k‖ := by
      simp only [hfnorm]
      exact (norm_dft_eq_of_extremal hΦ hext hk).symm
    rw [h1, h2, hθdef]
    field_simp
  intro j hj
  have := sum_alignment (fsupport Φ) f θ hθ hsum j hj
  rw [hfnorm j] at this
  exact this

/-! ## 4. The orthogonality relation -/

/-- On its support, an extremal is a single modulated flat function: the ratio of two values is
the character of the difference, evaluated at any spectral point. -/
theorem extremal_char_on_support {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N)
    {j j' k : ZMod N} (hj : j ∈ fsupport Φ) (hj' : j' ∈ fsupport Φ)
    (hk : k ∈ fsupport (𝓕 Φ)) :
    Φ j = stdAddChar ((j - j') * k) * Φ j' := by
  have hnorm : ‖Φ j‖ = ‖Φ j'‖ := flat_of_extremal hΦ hext hj hj'
  have h1 := phase_of_extremal hΦ hext hk j hj
  have h2 := phase_of_extremal hΦ hext hk j' hj'
  have h3 : stdAddChar (-(j * k)) * Φ j = stdAddChar (-(j' * k)) * Φ j' := by
    rw [h1, h2, hnorm]
  have hcancel : stdAddChar (j * k) * stdAddChar (-(j * k)) = 1 := by
    rw [← AddChar.map_add_eq_mul, add_neg_cancel, AddChar.map_zero_eq_one]
  have hcomb : stdAddChar (j * k) * stdAddChar (-(j' * k)) = stdAddChar ((j - j') * k) := by
    rw [← AddChar.map_add_eq_mul]
    congr 1
    ring
  calc Φ j = (stdAddChar (j * k) * stdAddChar (-(j * k))) * Φ j := by rw [hcancel, one_mul]
    _ = stdAddChar (j * k) * (stdAddChar (-(j * k)) * Φ j) := by ring
    _ = stdAddChar (j * k) * (stdAddChar (-(j' * k)) * Φ j') := by rw [h3]
    _ = (stdAddChar (j * k) * stdAddChar (-(j' * k))) * Φ j' := by ring
    _ = stdAddChar ((j - j') * k) * Φ j' := by rw [hcomb]

/-- **The orthogonality relation for Donoho–Stark extremals.** For an extremal, the difference
set of the support annihilates the difference set of the spectrum. This is the algebraic shadow
of phase rigidity, and the structural statement behind the conjecture that extremal supports are
cosets of subgroups. -/
theorem extremal_orthogonality {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N)
    {j j' k k' : ZMod N} (hj : j ∈ fsupport Φ) (hj' : j' ∈ fsupport Φ)
    (hk : k ∈ fsupport (𝓕 Φ)) (hk' : k' ∈ fsupport (𝓕 Φ)) :
    (j - j') * (k - k') = 0 := by
  have e1 := extremal_char_on_support hΦ hext hj hj' hk
  have e2 := extremal_char_on_support hΦ hext hj hj' hk'
  have hj'ne : Φ j' ≠ 0 := mem_fsupport.1 hj'
  have hchar : stdAddChar ((j - j') * k) = stdAddChar ((j - j') * k') :=
    mul_right_cancel₀ hj'ne (e1.symm.trans e2)
  have harg : (j - j') * k = (j - j') * k' := ZMod.injective_stdAddChar hchar
  have : (j - j') * (k - k') = (j - j') * k - (j - j') * k' := by ring
  rw [this, harg, sub_self]

/-- Restatement: the differences of the support lie in the annihilator of the differences of the
spectrum. -/
theorem extremal_support_sub_annihilator {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N)
    {j₀ k₀ : ZMod N} (hj₀ : j₀ ∈ fsupport Φ) (hk₀ : k₀ ∈ fsupport (𝓕 Φ)) :
    ∀ j ∈ fsupport Φ, ∀ k ∈ fsupport (𝓕 Φ), (j - j₀) * (k - k₀) = 0 := by
  intro j hj k hk
  exact extremal_orthogonality hΦ hext hj hj₀ hk hk₀

end ExtremalCosets