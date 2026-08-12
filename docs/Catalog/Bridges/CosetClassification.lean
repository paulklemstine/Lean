import Bridges.ExtremalCosets

/-!
# The classification of Donoho–Stark extremals: supports are cosets of subgroups

This file closes *Conjecture 3* of the thread's `FUTURE_DIRECTIONS.md` for every modulus `N`.

`Catalog/Bridges/UncertaintyRigidity.lean` proved modulus rigidity (an extremal is flat on its
support) and `Catalog/Bridges/ExtremalCosets.lean` proved phase rigidity, in the form of the
orthogonality relation `(j - j') * (k - k') = 0` between the difference set of the support and
the difference set of the spectrum. What remains is pure duality bookkeeping: the annihilator of
a subgroup `H ≤ ZMod N` has exactly `N / |H|` elements. Combining the two, the difference set of
the support is squeezed between a subgroup and a set of the same cardinality, hence *is* that
subgroup, so the support is a coset.

## Main results

* `CosetClassification.card_annihilator_mul_card` : `|ann H| * |H| = N` for every additive
  subgroup `H` of `ZMod N`, proved by a double character sum.
* `CosetClassification.extremal_support_coset` : **the classification.** If `Φ ≠ 0` attains
  `|supp Φ| * |supp 𝓕Φ| = N`, then `supp Φ` is a coset `a + K` of a subgroup `K ≤ ZMod N` with
  `|K| = |supp Φ|`; dually `supp 𝓕Φ` is a coset of the annihilator of `K`.
* `CosetClassification.extremal_eq_modulated_coset_indicator` : combined with flatness and phase
  rigidity, an extremal is a constant multiple of a character times the indicator of a coset.
* `CosetClassification.card_support_dvd_of_extremal` : in particular the support size of an
  extremal divides `N`, and `CosetClassification.extremal_additive_divisor_sum` : its additive
  support sum is the divisor sum `d + N / d` — both testable numeric consequences.
-/

open Finset ZMod FourierUncertainty UncertaintyRigidity ExtremalCosets

namespace CosetClassification

variable {N : ℕ} [NeZero N]

/-! ## 1. Annihilators and their cardinality -/

open scoped Classical in
/-- The annihilator of a finite subset of `ZMod N`. -/
noncomputable def annFinset (A : Finset (ZMod N)) : Finset (ZMod N) :=
  Finset.univ.filter fun x => ∀ a ∈ A, a * x = 0

open scoped Classical in
@[simp]
theorem mem_annFinset {A : Finset (ZMod N)} {x : ZMod N} :
    x ∈ annFinset A ↔ ∀ a ∈ A, a * x = 0 := by
  simp [annFinset]

theorem zero_mem_annFinset (A : Finset (ZMod N)) : (0 : ZMod N) ∈ annFinset A := by
  simp

theorem add_mem_annFinset {A : Finset (ZMod N)} {x y : ZMod N}
    (hx : x ∈ annFinset A) (hy : y ∈ annFinset A) : x + y ∈ annFinset A := by
  rw [mem_annFinset] at *
  intro a ha
  rw [mul_add, hx a ha, hy a ha, add_zero]

/-- The full character sum over `ZMod N`. -/
theorem sum_char_univ (h : ZMod N) :
    ∑ x : ZMod N, stdAddChar (x * h) = if h = 0 then (N : ℂ) else 0 := by
  classical
  by_cases hh : h = 0
  · subst hh
    simp [ZMod.card]
  · simp only [hh, if_false]
    have hchar : (stdAddChar h : ℂ) ≠ 1 := by
      intro hc
      apply hh
      have : stdAddChar h = stdAddChar (0 : ZMod N) := by
        rw [hc, AddChar.map_zero_eq_one]
      simpa using ZMod.injective_stdAddChar this
    have hshift : ∑ x : ZMod N, stdAddChar (x * h)
        = stdAddChar h * ∑ x : ZMod N, stdAddChar (x * h) := by
      rw [Finset.mul_sum]
      refine (Fintype.sum_equiv (Equiv.addRight (1 : ZMod N)) _ _ fun x => ?_).symm
      simp only [Equiv.coe_addRight]
      rw [← AddChar.map_add_eq_mul]
      congr 1
      ring
    have : (1 - stdAddChar h) * ∑ x : ZMod N, stdAddChar (x * h) = 0 := by
      rw [sub_mul, one_mul, ← hshift, sub_self]
    rcases mul_eq_zero.1 this with hz | hz
    · exact absurd (by linear_combination -hz : (stdAddChar h : ℂ) = 1) hchar
    · exact hz

omit [NeZero N] in
/-- Translating a finite additive subgroup by one of its elements is a bijection of the
subgroup. -/
theorem image_add_self {H : Finset (ZMod N)} (hadd : ∀ a ∈ H, ∀ b ∈ H, a + b ∈ H)
    {h₀ : ZMod N} (hh₀ : h₀ ∈ H) : H.image (fun h => h + h₀) = H := by
  classical
  refine Finset.eq_of_subset_of_card_le ?_ ?_
  · intro x hx
    simp only [Finset.mem_image] at hx
    obtain ⟨h, hh, rfl⟩ := hx
    exact hadd h hh h₀ hh₀
  · rw [Finset.card_image_of_injective _ (add_left_injective h₀)]

/-- The character sum over a finite additive subgroup: it is the order of the subgroup on the
annihilator and vanishes elsewhere. -/
theorem sum_char_subgroup {H : Finset (ZMod N)}
    (hadd : ∀ a ∈ H, ∀ b ∈ H, a + b ∈ H) (x : ZMod N) :
    ∑ h ∈ H, stdAddChar (h * x) = if x ∈ annFinset H then (H.card : ℂ) else 0 := by
  classical
  by_cases hx : x ∈ annFinset H
  · simp only [hx, if_true]
    rw [mem_annFinset] at hx
    rw [Finset.sum_congr rfl fun h hh => by rw [hx h hh, AddChar.map_zero_eq_one]]
    simp
  · simp only [hx, if_false]
    rw [mem_annFinset] at hx
    push_neg at hx
    obtain ⟨h₀, hh₀, hne⟩ := hx
    have hchar : (stdAddChar (h₀ * x) : ℂ) ≠ 1 := by
      intro hc
      apply hne
      have : stdAddChar (h₀ * x) = stdAddChar (0 : ZMod N) := by
        rw [hc, AddChar.map_zero_eq_one]
      simpa using ZMod.injective_stdAddChar this
    have hshift : ∑ h ∈ H, stdAddChar (h * x)
        = stdAddChar (h₀ * x) * ∑ h ∈ H, stdAddChar (h * x) := by
      conv_lhs => rw [← image_add_self hadd hh₀]
      rw [Finset.sum_image fun a _ b _ hab => add_left_injective h₀ hab, Finset.mul_sum]
      refine Finset.sum_congr rfl fun h _ => ?_
      rw [← AddChar.map_add_eq_mul]
      congr 1
      ring
    have hzero : (1 - stdAddChar (h₀ * x)) * ∑ h ∈ H, stdAddChar (h * x) = 0 := by
      rw [sub_mul, one_mul, ← hshift, sub_self]
    rcases mul_eq_zero.1 hzero with hz | hz
    · exact absurd (by linear_combination -hz : (stdAddChar (h₀ * x) : ℂ) = 1) hchar
    · exact hz

/-- **Duality counting.** An additive subgroup of `ZMod N` and its annihilator have orders
multiplying to `N`. The proof evaluates the double character sum `∑_x ∑_{h ∈ H} χ(hx)` in the two
possible orders. -/
theorem card_annihilator_mul_card {H : Finset (ZMod N)} (h0 : (0 : ZMod N) ∈ H)
    (hadd : ∀ a ∈ H, ∀ b ∈ H, a + b ∈ H) :
    (annFinset H).card * H.card = N := by
  classical
  have key : ((annFinset H).card * H.card : ℂ) = (N : ℂ) := by
    have hswap : ∑ x : ZMod N, ∑ h ∈ H, (stdAddChar (h * x) : ℂ)
        = ∑ h ∈ H, ∑ x : ZMod N, (stdAddChar (h * x) : ℂ) := Finset.sum_comm
    have hleft : ∑ x : ZMod N, ∑ h ∈ H, (stdAddChar (h * x) : ℂ)
        = ((annFinset H).card * H.card : ℂ) := by
      rw [Finset.sum_congr rfl fun x _ => sum_char_subgroup hadd x]
      rw [Finset.sum_ite_mem]
      simp [Finset.univ_inter, Finset.sum_const, nsmul_eq_mul]
    have hright : ∑ h ∈ H, ∑ x : ZMod N, (stdAddChar (h * x) : ℂ) = (N : ℂ) := by
      have : ∀ h ∈ H, ∑ x : ZMod N, (stdAddChar (h * x) : ℂ)
          = if h = 0 then (N : ℂ) else 0 := by
        intro h _
        rw [← sum_char_univ h]
        exact Finset.sum_congr rfl fun x _ => by rw [mul_comm]
      rw [Finset.sum_congr rfl this, Finset.sum_ite_eq' H (0 : ZMod N) (fun _ => (N : ℂ)),
        if_pos h0]
    rw [← hleft, hswap, hright]
  exact_mod_cast key

/-! ## 2. The classification of extremals -/

/-- **Donoho–Stark extremals have coset supports.** If a nonzero `Φ : ZMod N → ℂ` satisfies
`|supp Φ| * |supp 𝓕Φ| = N`, then its support is a coset `j₀ + K` of an additive subgroup `K` of
`ZMod N` of order `|supp Φ|`. Together with `UncertaintyRigidity.flat_of_extremal` and
`ExtremalCosets.extremal_char_on_support` this identifies the extremals as the modulated coset
indicators, confirming the conjectured classification for every modulus. -/
theorem extremal_support_coset {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N) :
    ∃ (K : Finset (ZMod N)) (a : ZMod N),
      (0 : ZMod N) ∈ K ∧ (∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) ∧
        K.card = (fsupport Φ).card ∧ fsupport Φ = K.image (fun x => a + x) := by
  classical
  -- base points of the support and of the spectrum
  obtain ⟨j₀, hj₀⟩ : (fsupport Φ).Nonempty := by
    rcases Function.ne_iff.1 hΦ with ⟨j, hj⟩
    exact ⟨j, mem_fsupport.2 (by simpa using hj)⟩
  obtain ⟨k₀, hk₀⟩ : (fsupport (𝓕 Φ)).Nonempty := by
    rcases Function.ne_iff.1 (dft_ne_zero_of_ne_zero hΦ) with ⟨k, hk⟩
    exact ⟨k, mem_fsupport.2 (by simpa using hk)⟩
  set B : Finset (ZMod N) := (fsupport Φ).image (fun j => j - j₀) with hB
  set C : Finset (ZMod N) := (fsupport (𝓕 Φ)).image (fun k => k - k₀) with hC
  set H : Finset (ZMod N) := annFinset B with hH
  set K : Finset (ZMod N) := annFinset H with hK
  -- the orthogonality relation puts the spectrum differences in `H`
  have hCH : C ⊆ H := by
    intro y hy
    rw [hC, Finset.mem_image] at hy
    obtain ⟨k, hk, rfl⟩ := hy
    rw [hH, mem_annFinset]
    intro b hb
    rw [hB, Finset.mem_image] at hb
    obtain ⟨j, hj, rfl⟩ := hb
    exact extremal_support_sub_annihilator hΦ hext hj₀ hk₀ j hj k hk
  -- `B` sits inside the double annihilator `K`
  have hBK : B ⊆ K := by
    intro b hb
    rw [hK, mem_annFinset]
    intro y hy
    rw [hH, mem_annFinset] at hy
    rw [mul_comm]
    exact hy b hb
  have h0H : (0 : ZMod N) ∈ H := zero_mem_annFinset B
  have haddH : ∀ a ∈ H, ∀ b ∈ H, a + b ∈ H := fun a ha b hb => add_mem_annFinset ha hb
  have hcount : K.card * H.card = N := card_annihilator_mul_card h0H haddH
  -- cardinalities
  have hsB : B.card = (fsupport Φ).card := by
    rw [hB, Finset.card_image_of_injective _ (sub_left_injective)]
  have htC : C.card = (fsupport (𝓕 Φ)).card := by
    rw [hC, Finset.card_image_of_injective _ (sub_left_injective)]
  have hsK : B.card ≤ K.card := Finset.card_le_card hBK
  have htH : C.card ≤ H.card := Finset.card_le_card hCH
  have hprod : B.card * C.card = N := by rw [hsB, htC]; exact hext
  have hCpos : 0 < C.card :=
    Finset.card_pos.2 ⟨0, by rw [hC, Finset.mem_image]; exact ⟨k₀, hk₀, sub_self k₀⟩⟩
  have hKpos : 0 < K.card := Finset.card_pos.2 ⟨0, zero_mem_annFinset H⟩
  have hHC : H.card = C.card := by
    have h1 : K.card * H.card ≤ K.card * C.card := by
      calc K.card * H.card = B.card * C.card := hcount.trans hprod.symm
        _ ≤ K.card * C.card := Nat.mul_le_mul_right _ hsK
    have h2 : K.card * C.card ≤ K.card * H.card := Nat.mul_le_mul_left _ htH
    exact Nat.eq_of_mul_eq_mul_left hKpos (le_antisymm h1 h2)
  have hBeqK : B.card = K.card := by
    refine Nat.eq_of_mul_eq_mul_right hCpos ?_
    rw [hprod, ← hHC]
    exact hcount.symm
  refine ⟨K, j₀, zero_mem_annFinset H, fun x hx y hy => add_mem_annFinset hx hy, ?_, ?_⟩
  · rw [← hBeqK, hsB]
  · have hBK' : B = K := Finset.eq_of_subset_of_card_le hBK (le_of_eq hBeqK.symm)
    ext j
    simp only [Finset.mem_image]
    constructor
    · intro hj
      refine ⟨j - j₀, ?_, by ring⟩
      rw [← hBK', hB, Finset.mem_image]
      exact ⟨j, hj, rfl⟩
    · rintro ⟨x, hx, rfl⟩
      rw [← hBK', hB, Finset.mem_image] at hx
      obtain ⟨j, hj, rfl⟩ := hx
      simpa using hj

/-- **The spectrum of an extremal is a coset as well**, of the annihilator subgroup. -/
theorem extremal_spectrum_coset {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N) :
    ∃ (K : Finset (ZMod N)) (a : ZMod N),
      (0 : ZMod N) ∈ K ∧ (∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) ∧
        K.card = (fsupport (𝓕 Φ)).card ∧ fsupport (𝓕 Φ) = K.image (fun x => a + x) :=
  extremal_support_coset (dft_ne_zero_of_ne_zero hΦ) (dft_extremal_of_extremal hext)

/-- The support size of an extremal divides `N`. -/
theorem card_support_dvd_of_extremal {Φ : ZMod N → ℂ}
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N) :
    (fsupport Φ).card ∣ N := ⟨_, hext.symm⟩

/-- **The full classification.** A Donoho–Stark extremal is a nonzero constant times a character
times the indicator function of a coset of a subgroup of `ZMod N` whose order is the size of the
support. This is the conjectured description of the equality case, for every modulus `N`. -/
theorem extremal_eq_modulated_coset_indicator {Φ : ZMod N → ℂ} (hΦ : Φ ≠ 0)
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N) :
    ∃ (K : Finset (ZMod N)) (a k₀ : ZMod N) (c : ℂ),
      c ≠ 0 ∧ (0 : ZMod N) ∈ K ∧ (∀ x ∈ K, ∀ y ∈ K, x + y ∈ K) ∧
        K.card = (fsupport Φ).card ∧
        ∀ j, Φ j = if j - a ∈ K then c * stdAddChar (j * k₀) else 0 := by
  classical
  obtain ⟨K, a, h0K, haddK, hcard, himg⟩ := extremal_support_coset hΦ hext
  obtain ⟨k₀, hk₀⟩ : (fsupport (𝓕 Φ)).Nonempty := by
    rcases Function.ne_iff.1 (dft_ne_zero_of_ne_zero hΦ) with ⟨k, hk⟩
    exact ⟨k, mem_fsupport.2 (by simpa using hk)⟩
  have hmem : ∀ j, j ∈ fsupport Φ ↔ j - a ∈ K := by
    intro j
    rw [himg, Finset.mem_image]
    constructor
    · rintro ⟨x, hx, rfl⟩
      simpa using hx
    · intro h
      exact ⟨j - a, h, by ring⟩
  have hamem : a ∈ fsupport Φ := (hmem a).2 (by simpa using h0K)
  refine ⟨K, a, k₀, stdAddChar (-(a * k₀)) * Φ a, ?_, h0K, haddK, hcard, ?_⟩
  · exact mul_ne_zero (by
      intro hz
      have h1 : ‖stdAddChar (-(a * k₀))‖ = 1 := AddChar.norm_apply _ _
      rw [hz] at h1
      simp at h1) (mem_fsupport.1 hamem)
  · intro j
    by_cases hj : j - a ∈ K
    · rw [if_pos hj]
      have hjs : j ∈ fsupport Φ := (hmem j).2 hj
      have := extremal_char_on_support hΦ hext hjs hamem hk₀
      rw [this]
      have hsplit : stdAddChar ((j - a) * k₀)
          = stdAddChar (j * k₀) * stdAddChar (-(a * k₀)) := by
        rw [← AddChar.map_add_eq_mul]
        congr 1
        ring
      rw [hsplit]
      ring
    · rw [if_neg hj]
      by_contra hne
      exact hj ((hmem j).1 (mem_fsupport.2 hne))

/-- **Extremal support sums are divisor sums.** For a Donoho–Stark extremal the additive
uncertainty functional takes the value `d + N / d` for the divisor `d = |supp Φ|` of `N`. This is
the "≥ min over divisors" half of the conjectured exact additive bound, restricted to the
multiplicative extremals. -/
theorem extremal_additive_divisor_sum {Φ : ZMod N → ℂ}
    (hext : (fsupport Φ).card * (fsupport (𝓕 Φ)).card = N) :
    ∃ d, d ∣ N ∧ (fsupport Φ).card + (fsupport (𝓕 Φ)).card = d + N / d := by
  classical
  refine ⟨(fsupport Φ).card, ⟨_, hext.symm⟩, ?_⟩
  have hspos : 0 < (fsupport Φ).card := by
    rcases Nat.eq_zero_or_pos (fsupport Φ).card with h | h
    · exfalso
      rw [h, Nat.zero_mul] at hext
      exact NeZero.ne N hext.symm
    · exact h
  have hdiv : N / (fsupport Φ).card = (fsupport (𝓕 Φ)).card :=
    Nat.div_eq_of_eq_mul_left hspos (hext.symm.trans (Nat.mul_comm _ _))
  rw [hdiv]


end CosetClassification