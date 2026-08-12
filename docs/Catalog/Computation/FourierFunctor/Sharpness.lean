import Computation.FourierFunctor.Poisson

/-!
# The equality case of the uncertainty principle

Fifth research cycle.  `Uncertainty.lean` proves `|G| ≤ |supp f| · |supp 𝓕f|`
and shows that Dirac masses attain the bound.  Here we exhibit the *whole*
family of subgroup examples: for every subgroup `K ≤ G` the indicator function
`1_K` also attains the bound, with

`𝓕(1_K) = |K| · 1_{K^⊥}`,

so `|supp 1_K| · |supp 𝓕 1_K| = |K| · |G|/|K| = |G|`.

Dirac masses are the case `K = 0` and constant functions the case `K = G`, so
this single statement subsumes both extremes of `donoho_stark_sharp`.  The final
section extends this to the full family of *modulated coset indicators*
`g ↦ χ(g)·1_K(g − a)` (`donoho_stark_equality_coset`).

-- !-- Lab Notes -- !--

* Hypothesizer (cycle 5): the equality case of Donoho–Stark should be exactly
  the "coset/subgroup" functions; a first testable consequence is that every
  subgroup gives equality.
* Experimenter: verified numerically (see `ComputationalEvidence.md`: for
  `G = ℤ/12` and `|K| = 4` one finds `|supp 1_K| = 4`, `|supp 𝓕1_K| = 3`,
  product `12 = |G|`), then proved in Lean.  The proof needs one new
  orthogonality relation, `subgroup_char_sum`, dual to `annihilator_sum`.
* Analyst: the two orthogonality relations `annihilator_sum` (sum a subgroup of
  characters at a point) and `subgroup_char_sum` (sum a character over a
  subgroup of points) are *exchanged* by Pontryagin duality; the equality case
  of the uncertainty principle is precisely the self-dual family they detect.
* Critic: the first version of this file treated subgroups only.  Since
  translates and modulations of `1_K` should also be extremal, the file was
  extended: `donoho_stark_equality_coset` covers the whole family
  `g ↦ χ(g)·1_K(g−a)`, whose transform is `χ(a)ψ(−a)|K|·1_{χ+K^⊥}(ψ)`.  The
  converse (that these are the *only* extremal functions) was left open here and
  is now proved in `Rigidity.lean` (`donoho_stark_rigidity`,
  `donoho_stark_equality_iff`).
-/

open CategoryTheory AddChar Finset
open scoped Classical

namespace FourierFunctor

variable {G : Type} [AddCommGroup G] [Fintype G]

/-- **Orthogonality over a subgroup** (dual to `annihilator_sum`): summing a
character over a subgroup gives `|K|` if the character annihilates `K` and `0`
otherwise. -/
theorem subgroup_char_sum (K : AddSubgroup G) (ψ : AddChar G ℂ) :
    (∑ k : ↥K, ψ (k : G)) = if ψ ∈ annihilator K then (Nat.card ↥K : ℂ) else 0 := by
  classical
  by_cases hψ : ψ ∈ annihilator K
  · rw [if_pos hψ]
    rw [Finset.sum_congr rfl fun k _ => mem_annihilator.1 hψ k]
    simp [Nat.card_eq_fintype_card]
  · rw [if_neg hψ]
    obtain ⟨k₀, hk₀⟩ : ∃ k₀ : ↥K, ψ (k₀ : G) ≠ 1 := by
      by_contra h
      push_neg at h
      exact hψ (mem_annihilator.2 h)
    set S : ℂ := ∑ k : ↥K, ψ (k : G) with hS
    have hshift : ψ (k₀ : G) * S = S := by
      have hbij : Function.Bijective (fun k : ↥K => k₀ + k) := (Equiv.addLeft k₀).bijective
      have hsum := Fintype.sum_bijective _ hbij
        (fun k : ↥K => ψ (k₀ : G) * ψ (k : G)) (fun k : ↥K => ψ (k : G))
        (fun k => by
          simp only [AddSubgroup.coe_add]
          rw [ψ.map_add_eq_mul])
      rw [hS, Finset.mul_sum]
      exact hsum
    have hzero : (ψ (k₀ : G) - 1) * S = 0 := by linear_combination hshift
    rcases mul_eq_zero.1 hzero with h | h
    · exact absurd (by linear_combination h : ψ (k₀ : G) = 1) hk₀
    · exact h

/-- The indicator function of a subgroup. -/
noncomputable def indicator (K : AddSubgroup G) : G → ℂ := fun g => if g ∈ K then 1 else 0

/-- **The Fourier transform of a subgroup indicator is `|K|` times the indicator
of the annihilator.** -/
theorem fourier_indicator (K : AddSubgroup G) (ψ : AddChar G ℂ) :
    fourier (indicator K) ψ = if ψ ∈ annihilator K then (Nat.card ↥K : ℂ) else 0 := by
  classical
  rw [fourier_apply]
  have hstep : ∀ g : G, indicator K g * ψ (-g) = if g ∈ K then ψ (-g) else 0 := by
    intro g
    by_cases hg : g ∈ K <;> simp [indicator, hg]
  rw [Finset.sum_congr rfl fun g _ => hstep g, ← Finset.sum_filter,
    Finset.sum_subtype (p := fun g : G => g ∈ K) (Finset.univ.filter fun g : G => g ∈ K)
      (fun x => by simp) (fun g => ψ (-g))]
  have hflip : (∑ k : ↥K, ψ (-(k : G))) = ∑ k : ↥K, ψ (k : G) := by
    refine Fintype.sum_bijective (fun k : ↥K => -k) (Equiv.neg ↥K).bijective _ _ ?_
    intro k
    simp
  rw [hflip, subgroup_char_sum]

/-- The support of a subgroup indicator has `|K|` elements. -/
theorem card_support_indicator (K : AddSubgroup G) :
    (support (indicator K)).card = Nat.card ↥K := by
  classical
  have hset : support (indicator K) = Finset.univ.filter fun g : G => g ∈ K := by
    ext g
    by_cases hg : g ∈ K <;> simp [mem_support, indicator, hg]
  rw [hset, Nat.card_eq_fintype_card, Fintype.card_subtype]

/-- The support of the transform of a subgroup indicator is the annihilator, of
size `|G|/|K|`. -/
theorem card_support_fourier_indicator (K : AddSubgroup G) :
    (support (fourier (indicator K))).card = Nat.card ↥(annihilator K) := by
  classical
  have hset : support (fourier (indicator K))
      = Finset.univ.filter fun ψ : AddChar G ℂ => ψ ∈ annihilator K := by
    ext ψ
    by_cases hψ : ψ ∈ annihilator K <;>
      simp [mem_support, fourier_indicator, hψ]
  rw [hset, Nat.card_eq_fintype_card, Fintype.card_subtype]

/-- **Equality in the uncertainty principle for subgroup indicators.**  For every
subgroup `K` of a finite abelian group `G`, the indicator of `K` satisfies
`|supp 1_K| · |supp 𝓕1_K| = |G|`. -/
theorem donoho_stark_equality_subgroup (K : AddSubgroup G) :
    (support (indicator K)).card * (support (fourier (indicator K))).card = Fintype.card G := by
  rw [card_support_indicator, card_support_fourier_indicator, mul_comm, card_annihilator K,
    Nat.card_eq_fintype_card]


/-! ### Cosets and modulations: the full extremal family -/

/-- A **modulated coset indicator**: `g ↦ χ(g) · 1_K(g − a)`, supported on the
coset `a + K`. -/
noncomputable def cosetFun (K : AddSubgroup G) (a : G) (χ : AddChar G ℂ) : G → ℂ :=
  fun g => χ g * indicator K (g - a)

/-- The Fourier transform of a modulated coset indicator is a modulated
translate of the annihilator indicator. -/
theorem fourier_cosetFun (K : AddSubgroup G) (a : G) (χ ψ : AddChar G ℂ) :
    fourier (cosetFun K a χ) ψ
      = χ a * ψ (-a) * (if χ - ψ ∈ annihilator K then (Nat.card ↥K : ℂ) else 0) := by
  classical
  rw [fourier_apply]
  have hreindex : (∑ g : G, cosetFun K a χ g * ψ (-g))
      = ∑ z : G, cosetFun K a χ (z + a) * ψ (-(z + a)) :=
    (Fintype.sum_bijective (fun z : G => z + a) (Equiv.addRight a).bijective _ _
      (fun z => rfl)).symm
  rw [hreindex]
  have hterm : ∀ z : G, cosetFun K a χ (z + a) * ψ (-(z + a))
      = χ a * ψ (-a) * (if z ∈ K then (χ - ψ) z else 0) := by
    intro z
    have hz : z + a - a = z := by abel
    by_cases hzK : z ∈ K
    · rw [cosetFun, hz, indicator, if_pos hzK, if_pos hzK, AddChar.sub_apply,
        show -(z + a) = -z + -a by abel, ψ.map_add_eq_mul, χ.map_add_eq_mul]
      ring
    · rw [cosetFun, hz, indicator, if_neg hzK, if_neg hzK]
      ring
  rw [Finset.sum_congr rfl fun z _ => hterm z, ← Finset.mul_sum, ← Finset.sum_filter,
    Finset.sum_subtype (p := fun g : G => g ∈ K) (Finset.univ.filter fun g : G => g ∈ K)
      (fun x => by simp) (fun z => (χ - ψ) z), subgroup_char_sum]

/-- The support of a modulated coset indicator is the coset, of size `|K|`. -/
theorem card_support_cosetFun (K : AddSubgroup G) (a : G) (χ : AddChar G ℂ) :
    (support (cosetFun K a χ)).card = Nat.card ↥K := by
  classical
  have hset : support (cosetFun K a χ)
      = (Finset.univ.filter fun g : G => g ∈ K).image (fun k => k + a) := by
    ext g
    simp only [mem_support, Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and,
      cosetFun, indicator, ne_eq, mul_eq_zero, not_or]
    constructor
    · rintro ⟨-, hg⟩
      refine ⟨g - a, ?_, by abel⟩
      by_contra hmem
      rw [if_neg hmem] at hg
      exact hg rfl
    · rintro ⟨k, hk, rfl⟩
      have hka : k + a - a = k := by abel
      refine ⟨addChar_apply_ne_zero χ _, ?_⟩
      rw [hka, if_pos hk]
      exact one_ne_zero
  rw [hset, Finset.card_image_of_injective _ (add_left_injective a),
    Nat.card_eq_fintype_card, Fintype.card_subtype]

/-- The support of its transform is a translate of the annihilator, of size
`|G|/|K|`. -/
theorem card_support_fourier_cosetFun (K : AddSubgroup G) (a : G) (χ : AddChar G ℂ) :
    (support (fourier (cosetFun K a χ))).card = Nat.card ↥(annihilator K) := by
  classical
  have hset : support (fourier (cosetFun K a χ))
      = (Finset.univ.filter fun t : AddChar G ℂ => t ∈ annihilator K).image
          (fun t => χ - t) := by
    ext ψ
    simp only [mem_support, Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and,
      fourier_cosetFun, ne_eq, mul_eq_zero, not_or]
    constructor
    · rintro ⟨-, hne⟩
      refine ⟨χ - ψ, ?_, by abel⟩
      by_contra hmem
      rw [if_neg hmem] at hne
      exact hne rfl
    · rintro ⟨t, ht, rfl⟩
      have hchi : χ - (χ - t) = t := by abel
      refine ⟨⟨addChar_apply_ne_zero χ a, addChar_apply_ne_zero (χ - t) (-a)⟩, ?_⟩
      rw [hchi, if_pos ht]
      exact_mod_cast Nat.cast_ne_zero.2 Nat.card_pos.ne'
  rw [hset, Finset.card_image_of_injective _ (fun x y h => by
      have := congrArg (fun z => χ - z) h
      simpa using this),
    Nat.card_eq_fintype_card, Fintype.card_subtype]

/-- **The full extremal family.**  Every modulated coset indicator attains
equality in the uncertainty principle. -/
theorem donoho_stark_equality_coset (K : AddSubgroup G) (a : G) (χ : AddChar G ℂ) :
    (support (cosetFun K a χ)).card * (support (fourier (cosetFun K a χ))).card
      = Fintype.card G := by
  rw [card_support_cosetFun, card_support_fourier_cosetFun, mul_comm, card_annihilator K,
    Nat.card_eq_fintype_card]

omit [Fintype G] in
/-- The indicator of a subgroup is never the zero function, so the equality case
above is a genuine instance of `donoho_stark`. -/
theorem indicator_ne_zero (K : AddSubgroup G) : indicator K ≠ (0 : G → ℂ) := by
  intro h
  have h0 : indicator K (0 : G) = 0 := congrFun h 0
  rw [indicator, if_pos K.zero_mem] at h0
  exact one_ne_zero h0

end FourierFunctor