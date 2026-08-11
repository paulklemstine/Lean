import Mathlib
import Tropical.TropicalLinearSpaceElimination

/-!
# The tropical vanishing ideal of a point is a tropical ideal

Building on `Catalog/Tropical/TropicalLinearSpaceElimination.lean` (vector
elimination for tropical hyperplanes) and on
`Catalog/Tropical/GroebnerBases.lean` (tropical ideals as subsemimodules of
`MvPolynomial σ K` for a tropical coefficient semiring `K`), this file proves
that the set of tropical polynomials *vanishing* at a fixed point `w` is

* an **ideal** of the tropical polynomial semiring `MvPolynomial σ (Tropical (WithTop ℚ))`
  (`vanishingIdeal`), the nontrivial ingredient being closure under
  multiplication (`vanishesAt_mul_left`); and
* a **tropical ideal** in the sense of Maclagan–Rincón: each truncation to a
  finite set `E` of monomials is the set of vectors of a valuated matroid
  (`truncation_isTropicalLinearSpace`), so the elimination axiom holds in every
  bounded degree.

Tropical vanishing at `w` is expressed relationally: for every monomial `u` some
*other* monomial `u'` has term value at most that of `u`.  Over the monomial
lattice this is exactly the classical requirement that the minimum in
`min_u (coeff u + ⟨u, w⟩)` be attained at least twice (or the polynomial be
tropically zero).
-/

open MvPolynomial Tropical

noncomputable section

namespace TropicalPointIdeal

/-- The min-plus tropical semiring carrier. -/
abbrev TT := WithTop ℚ

/-- The tropical coefficient semiring `(ℚ ∪ {∞}, min, +)`. -/
abbrev TropCoeff := Tropical TT

variable {σ : Type*}

/-- The value `⟨u, w⟩` of the monomial with exponent `u` at the point `w`. -/
def monVal (w : σ → ℚ) (u : σ →₀ ℕ) : ℚ := u.sum fun i k => (k : ℚ) * w i

theorem monVal_add (w : σ → ℚ) (u v : σ →₀ ℕ) :
    monVal w (u + v) = monVal w u + monVal w v := by
  classical
  simp only [monVal]
  exact Finsupp.sum_add_index' (fun i => by simp) (fun i k l => by push_cast; ring)

/-- The tropical value of the `u`-term of `f` at the point `w`. -/
def tval (w : σ → ℚ) (f : MvPolynomial σ TropCoeff) (u : σ →₀ ℕ) : TT :=
  untrop (coeff u f) + ((monVal w u : ℚ) : TT)

/-- Tropical vanishing at the point `w`: for every monomial some other monomial
has term value at most as large.  Equivalently, the tropical minimum is attained
at least twice, or the polynomial is tropically zero. -/
def VanishesAt (w : σ → ℚ) (f : MvPolynomial σ TropCoeff) : Prop :=
  ∀ u, ∃ u', u' ≠ u ∧ tval w f u' ≤ tval w f u

section Basic

theorem min_add_right (a b c : TT) : min a b + c = min (a + c) (b + c) := by
  rcases le_total a b with h | h
  · rw [min_eq_left h, min_eq_left (by gcongr)]
  · rw [min_eq_right h, min_eq_right (by gcongr)]

theorem inf_add_right (a b c : TT) : a ⊓ b + c = (a + c) ⊓ (b + c) := min_add_right a b c

theorem inf_add_const {ι : Type*} (s : Finset ι) (F : ι → TT) (c : TT) :
    s.inf F + c = s.inf fun i => F i + c := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | insert a s _ ih =>
    rw [Finset.inf_insert, Finset.inf_insert, inf_add_right, ih]

theorem tval_eq_top_of_coeff_eq_zero (w : σ → ℚ) {f : MvPolynomial σ TropCoeff}
    {u : σ →₀ ℕ} (h : coeff u f = 0) : tval w f u = ⊤ := by
  rw [tval, h, untrop_zero, top_add]

theorem tval_zero (w : σ → ℚ) (u : σ →₀ ℕ) :
    tval w (0 : MvPolynomial σ TropCoeff) u = ⊤ :=
  tval_eq_top_of_coeff_eq_zero w (by simp)

/-- There are always at least two monomials when there is at least one variable. -/
theorem exists_ne_exponent [Nonempty σ] (u : σ →₀ ℕ) : ∃ u' : σ →₀ ℕ, u' ≠ u := by
  classical
  obtain ⟨i⟩ := ‹Nonempty σ›
  refine ⟨u + Finsupp.single i 1, ?_⟩
  intro h
  have h2 := congrArg (fun t : σ →₀ ℕ => t i) h
  simp at h2

theorem vanishesAt_zero [Nonempty σ] (w : σ → ℚ) :
    VanishesAt w (0 : MvPolynomial σ TropCoeff) := by
  intro u
  obtain ⟨u', hu'⟩ := exists_ne_exponent u
  exact ⟨u', hu', by rw [tval_zero, tval_zero]⟩

theorem tval_add (w : σ → ℚ) (f g : MvPolynomial σ TropCoeff) (u : σ →₀ ℕ) :
    tval w (f + g) u = min (tval w f u) (tval w g u) := by
  rw [tval, tval, tval, coeff_add, untrop_add, min_add_right]

/-- Tropical vanishing is preserved by tropical addition (coordinatewise
minimum of coefficients). -/
theorem vanishesAt_add (w : σ → ℚ) {f g : MvPolynomial σ TropCoeff}
    (hf : VanishesAt w f) (hg : VanishesAt w g) : VanishesAt w (f + g) := by
  intro u
  rcases le_total (tval w f u) (tval w g u) with h | h
  · obtain ⟨u', hu', hle⟩ := hf u
    refine ⟨u', hu', ?_⟩
    rw [tval_add, tval_add, min_eq_left h]
    exact (min_le_left _ _).trans hle
  · obtain ⟨u', hu', hle⟩ := hg u
    refine ⟨u', hu', ?_⟩
    rw [tval_add, tval_add, min_eq_right h]
    exact (min_le_right _ _).trans hle

end Basic

section Multiplication

variable [DecidableEq σ] (w : σ → ℚ)

/-- The term values of a product are the tropical convolution of the term values
of the factors. -/
theorem tval_mul (f g : MvPolynomial σ TropCoeff) (v : σ →₀ ℕ) :
    tval w (f * g) v =
      (Finset.antidiagonal v).inf fun p => tval w f p.1 + tval w g p.2 := by
  classical
  rw [tval, coeff_mul, Finset.untrop_sum', inf_add_const]
  refine Finset.inf_congr rfl ?_
  intro p hp
  rw [Finset.mem_antidiagonal] at hp
  simp only [Function.comp_apply, untrop_mul, tval]
  rw [← hp, monVal_add]
  push_cast
  simp [add_left_comm, add_assoc]

/-- **Key theorem: tropical vanishing at a point is preserved by multiplication.**

If `f` vanishes at `w` then so does `f * g` for every `g`.  The proof exhibits
two *distinct* monomials at which the tropical minimum of `f * g` is attained,
namely `a + b` and `a' + b` where `a ≠ a'` are two minimizing monomials of `f`
and `b` is any minimizing monomial of `g`. -/
theorem vanishesAt_mul_left [Nonempty σ] {f : MvPolynomial σ TropCoeff}
    (hf : VanishesAt w f) (g : MvPolynomial σ TropCoeff) : VanishesAt w (f * g) := by
  classical
  by_cases hg0 : g = 0
  · subst hg0; rw [mul_zero]; exact vanishesAt_zero w
  by_cases hf0 : f = 0
  · subst hf0; rw [zero_mul]; exact vanishesAt_zero w
  -- global minimizers of the term values of `f` and of `g`
  obtain ⟨a, ha_mem, ha⟩ :=
    Finset.exists_min_image f.support (tval w f) (MvPolynomial.support_nonempty.mpr hf0)
  obtain ⟨b, hb_mem, hb⟩ :=
    Finset.exists_min_image g.support (tval w g) (MvPolynomial.support_nonempty.mpr hg0)
  have hamin : ∀ u, tval w f a ≤ tval w f u := by
    intro u
    by_cases hu : u ∈ f.support
    · exact ha u hu
    · rw [tval_eq_top_of_coeff_eq_zero w (MvPolynomial.notMem_support_iff.mp hu)]
      exact le_top
  have hbmin : ∀ u, tval w g b ≤ tval w g u := by
    intro u
    by_cases hu : u ∈ g.support
    · exact hb u hu
    · rw [tval_eq_top_of_coeff_eq_zero w (MvPolynomial.notMem_support_iff.mp hu)]
      exact le_top
  -- `f` has a second minimizing monomial
  obtain ⟨a', ha'ne, ha'le⟩ := hf a
  have ha'min : ∀ u, tval w f a' ≤ tval w f u := fun u =>
    (le_antisymm ha'le (hamin a') ▸ hamin u)
  -- the minimum value of the product
  set M : TT := tval w f a + tval w g b with hM
  have hlower : ∀ v, M ≤ tval w (f * g) v := by
    intro v
    rw [tval_mul]
    refine Finset.le_inf ?_
    intro p _
    exact add_le_add (hamin p.1) (hbmin p.2)
  have hattain : ∀ c : σ →₀ ℕ, (∀ u, tval w f c ≤ tval w f u) →
      tval w (f * g) (c + b) = M := by
    intro c hc
    refine le_antisymm ?_ (hlower _)
    rw [tval_mul]
    have hmem : (c, b) ∈ Finset.antidiagonal (c + b) := by
      rw [Finset.mem_antidiagonal]
    calc (Finset.antidiagonal (c + b)).inf (fun p => tval w f p.1 + tval w g p.2)
        ≤ tval w f c + tval w g b := Finset.inf_le hmem
      _ = M := by
          rw [hM]
          exact congrArg (· + tval w g b) (le_antisymm (hc a) (hamin c))
  have h1 : tval w (f * g) (a + b) = M := hattain a hamin
  have h2 : tval w (f * g) (a' + b) = M := hattain a' ha'min
  have hne : a + b ≠ a' + b := fun h => ha'ne (add_right_cancel h).symm
  intro v
  by_cases hv : v = a + b
  · exact ⟨a' + b, by rw [hv]; exact fun h => hne h.symm, by rw [h2, hv, h1]⟩
  · exact ⟨a + b, fun h => hv h.symm, by rw [h1]; exact hlower v⟩

/-- **The tropical vanishing set of a point is an ideal** of the tropical
polynomial semiring. -/
def vanishingIdeal [Nonempty σ] : Ideal (MvPolynomial σ TropCoeff) where
  carrier := {f | VanishesAt w f}
  add_mem' := fun hf hg => vanishesAt_add w hf hg
  zero_mem' := vanishesAt_zero w
  smul_mem' := fun c f hf => by
    have := vanishesAt_mul_left w hf c
    rwa [smul_eq_mul, mul_comm]

theorem mem_vanishingIdeal [Nonempty σ] {f : MvPolynomial σ TropCoeff} :
    f ∈ vanishingIdeal w ↔ VanishesAt w f := Iff.rfl

end Multiplication

section Bridge

open TropicalElimination

variable [Nonempty σ] (w : σ → ℚ) (E : Finset (σ →₀ ℕ))

/-- The coefficient vector of `f` on the finite monomial set `E`. -/
def coeffVec (f : MvPolynomial σ TropCoeff) : {u // u ∈ E} → TT :=
  fun u => untrop (coeff (u : σ →₀ ℕ) f)

/-- The evaluation weights of the point `w` on the monomial set `E`. -/
def pointVec : {u // u ∈ E} → TT := fun u => ((monVal w (u : σ →₀ ℕ) : ℚ) : TT)

omit [Nonempty σ] in
theorem tval_eq (f : MvPolynomial σ TropCoeff) (u : {u // u ∈ E}) :
    pointVec w E u + coeffVec E f u = tval w f (u : σ →₀ ℕ) := by
  rw [pointVec, coeffVec, tval, add_comm]

omit [Nonempty σ] in
/-- Truncating a vanishing polynomial supported on `E` produces a vector of the
tropical hyperplane cut out by the point. -/
theorem coeffVec_mem_tropVanishing (hE : 1 < E.card) {f : MvPolynomial σ TropCoeff}
    (hf : VanishesAt w f) (hsupp : f.support ⊆ E) :
    coeffVec E f ∈ tropVanishing (pointVec w E) := by
  classical
  intro u
  obtain ⟨u', hu'ne, hu'le⟩ := hf (u : σ →₀ ℕ)
  by_cases hmem : u' ∈ E
  · refine ⟨⟨u', hmem⟩, ?_, ?_⟩
    · intro h
      exact hu'ne (congrArg Subtype.val h)
    · rw [tval_eq, tval_eq]; exact hu'le
  · -- `u'` is outside `E`, hence its term vanishes, hence so does the term at `u`
    have hu'top : tval w f u' = ⊤ := by
      refine tval_eq_top_of_coeff_eq_zero w ?_
      by_contra hcoeff
      exact hmem (hsupp (MvPolynomial.mem_support_iff.mpr hcoeff))
    have hutop : tval w f (u : σ →₀ ℕ) = ⊤ := by
      rw [hu'top] at hu'le
      exact top_le_iff.mp hu'le
    obtain ⟨x, hx, y, hy, hxy⟩ := Finset.one_lt_card.mp hE
    by_cases hux : (u : σ →₀ ℕ) = x
    · refine ⟨⟨y, hy⟩, ?_, ?_⟩
      · intro h
        exact hxy (hux ▸ congrArg Subtype.val h.symm ▸ rfl)
      · rw [tval_eq, tval_eq, hutop]; exact le_top
    · refine ⟨⟨x, hx⟩, ?_, ?_⟩
      · intro h
        exact hux (congrArg Subtype.val h).symm
      · rw [tval_eq, tval_eq, hutop]; exact le_top

omit [Nonempty σ] in
/-- Every vector of the tropical hyperplane is the truncation of a vanishing
polynomial supported on `E`. -/
theorem exists_vanishing_of_mem_tropVanishing (hE : E.Nonempty)
    {x : {u // u ∈ E} → TT} (hx : x ∈ tropVanishing (pointVec w E)) :
    ∃ f : MvPolynomial σ TropCoeff, VanishesAt w f ∧ f.support ⊆ E ∧ coeffVec E f = x := by
  classical
  set F : MvPolynomial σ TropCoeff := ∑ u ∈ E.attach, monomial (u : σ →₀ ℕ) (trop (x u)) with hF
  have hcoeff : ∀ v : σ →₀ ℕ, coeff v F = if h : v ∈ E then trop (x ⟨v, h⟩) else 0 := by
    intro v
    rw [hF, coeff_sum]
    by_cases hv : v ∈ E
    · rw [dif_pos hv]
      refine (Finset.sum_eq_single (⟨v, hv⟩ : {u // u ∈ E}) ?_ ?_).trans ?_
      · intro c _ hcne
        rw [coeff_monomial, if_neg]
        intro h
        exact hcne (Subtype.ext h)
      · intro h
        exact absurd (Finset.mem_attach _ _) h
      · rw [coeff_monomial, if_pos rfl]
    · rw [dif_neg hv]
      refine Finset.sum_eq_zero ?_
      intro c _
      rw [coeff_monomial, if_neg]
      intro h
      exact hv (h ▸ c.2)
  have hval : ∀ u : {u // u ∈ E}, tval w F (u : σ →₀ ℕ) = pointVec w E u + x u := by
    intro u
    rw [tval, hcoeff, dif_pos u.2, untrop_trop, pointVec, add_comm]
  refine ⟨F, ?_, ?_, ?_⟩
  · -- vanishing
    intro v
    by_cases hv : v ∈ E
    · obtain ⟨j, hj, hjle⟩ := hx ⟨v, hv⟩
      refine ⟨(j : σ →₀ ℕ), ?_, ?_⟩
      · intro h
        exact hj (Subtype.ext h)
      · rw [hval j, hval ⟨v, hv⟩]
        exact hjle
    · obtain ⟨y, hy⟩ := hE
      refine ⟨y, ?_, ?_⟩
      · intro h; exact hv (h ▸ hy)
      · have htop : tval w F v = ⊤ :=
          tval_eq_top_of_coeff_eq_zero w (by rw [hcoeff, dif_neg hv])
        rw [htop]
        exact le_top
  · -- support
    intro v hv
    by_contra hvE
    rw [MvPolynomial.mem_support_iff, hcoeff, dif_neg hvE] at hv
    exact hv rfl
  · -- coefficient vector
    funext u
    simp only [coeffVec, hcoeff, dif_pos u.2, untrop_trop]

omit [Nonempty σ] in
/-- **The truncation of the vanishing set of a point to a finite monomial set is
exactly a tropical hyperplane.** -/
theorem truncation_eq_tropVanishing (hE : 1 < E.card) :
    {x : {u // u ∈ E} → TT |
        ∃ f : MvPolynomial σ TropCoeff, VanishesAt w f ∧ f.support ⊆ E ∧ coeffVec E f = x}
      = tropVanishing (pointVec w E) := by
  ext x
  constructor
  · rintro ⟨f, hf, hsupp, rfl⟩
    exact coeffVec_mem_tropVanishing w E hE hf hsupp
  · intro hx
    exact exists_vanishing_of_mem_tropVanishing w E (Finset.card_pos.mp (by omega)) hx

omit [Nonempty σ] in
/-- **The vanishing ideal of a point is a tropical ideal** in the sense of
Maclagan–Rincón: each finite-monomial truncation is a tropical linear space,
i.e. the set of vectors of a valuated matroid. -/
theorem truncation_isTropicalLinearSpace (hE : 1 < E.card) :
    IsTropicalLinearSpace
      {x : {u // u ∈ E} → TT |
        ∃ f : MvPolynomial σ TropCoeff, VanishesAt w f ∧ f.support ⊆ E ∧ coeffVec E f = x} := by
  classical
  obtain ⟨p, hp, q, hq, hpq⟩ := Finset.one_lt_card.mp hE
  haveI : Nontrivial {u // u ∈ E} := ⟨⟨⟨p, hp⟩, ⟨q, hq⟩, fun h => hpq (congrArg Subtype.val h)⟩⟩
  rw [truncation_eq_tropVanishing w E hE]
  exact tropVanishing_isTropicalLinearSpace _

omit [Nonempty σ] in
/-- Consequently the elimination axiom holds degreewise for the vanishing ideal
of a point: two vanishing polynomials supported on `E` agreeing in a nonzero
coefficient can be combined into a vanishing polynomial in which that monomial
has been eliminated. -/
theorem vanishing_elimination (hE : 1 < E.card) {f g : MvPolynomial σ TropCoeff}
    (hf : VanishesAt w f) (hg : VanishesAt w g)
    (hfE : f.support ⊆ E) (hgE : g.support ⊆ E) (e : {u // u ∈ E})
    (hfg : coeffVec E f e = coeffVec E g e) (hne : coeffVec E f e ≠ ⊤) :
    ∃ h : MvPolynomial σ TropCoeff, VanishesAt w h ∧ h.support ⊆ E ∧
      coeffVec E h e = ⊤ ∧
      (∀ u, min (coeffVec E f u) (coeffVec E g u) ≤ coeffVec E h u) ∧
      (∀ u, coeffVec E f u ≠ coeffVec E g u →
        coeffVec E h u = min (coeffVec E f u) (coeffVec E g u)) := by
  classical
  obtain ⟨p, hp, q, hq, hpq⟩ := Finset.one_lt_card.mp hE
  haveI : Nontrivial {u // u ∈ E} := ⟨⟨⟨p, hp⟩, ⟨q, hq⟩, fun h => hpq (congrArg Subtype.val h)⟩⟩
  have hfmem : coeffVec E f ∈ tropVanishing (pointVec w E) :=
    coeffVec_mem_tropVanishing w E hE hf hfE
  have hgmem : coeffVec E g ∈ tropVanishing (pointVec w E) :=
    coeffVec_mem_tropVanishing w E hE hg hgE
  obtain ⟨z, hzmem, hze, hzge, hzeq⟩ :=
    tropVanishing_elimination (pointVec w E) _ hfmem _ hgmem e hfg hne
  obtain ⟨h, hh, hhE, hhz⟩ :=
    exists_vanishing_of_mem_tropVanishing w E (Finset.card_pos.mp (by omega)) hzmem
  exact ⟨h, hh, hhE, by rw [hhz]; exact hze, by rw [hhz]; exact hzge, by rw [hhz]; exact hzeq⟩

end Bridge

end TropicalPointIdeal