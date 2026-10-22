import Computation.FourierFunctor.Uncertainty

/-!
# Convolution, Plancherel, and the fourth-power identity

Second research cycle.  The Fourier transform of `Transform.lean` is a natural
isomorphism of *linear* functors; here we show it carries far more structure.

* `fourier_conv` — **the convolution theorem**: `𝓕(f ⋆ g) = 𝓕f · 𝓕g`.  Thus the
  group algebra (convolution) and the algebra of functions on the dual
  (pointwise product) are isomorphic as rings, naturally in `G`.
* `conv_comm`, `conv_assoc`, `conv_delta` — the ring axioms of the group algebra
  are *derived* from the convolution theorem by transporting them along the
  injective transform: an example of "algebra proved by analysis".
* `plancherel` — `∑_ψ ‖𝓕f ψ‖² = |G| · ∑_g ‖f g‖²`.
* `fourier_fourier` — the transform composed with the transform of the dual
  group is `|G|` times the flip `x ↦ -x`, *under the double dual identification*.
  Hence `𝓕⁴ = |G|²`: the Fourier transform has order four up to scaling, and the
  identification used is exactly the unit of `pontryagin`.

-- !-- Lab Notes -- !--

* Hypothesizer (cycle 2): if `𝓕` is natural, then the *monoidal* structure
  should also be natural: convolution ↦ pointwise product.  Bold form: every
  algebraic identity of the group algebra is a shadow of a pointwise identity on
  the dual side, so commutativity/associativity of convolution should be
  provable *without* any group-theoretic computation.
* Experimenter: confirmed.  `conv_comm` and `conv_assoc` are proved by applying
  `fourierEquiv.injective` and then `mul_comm`/`mul_assoc` in `ℂ`.  The
  translation-invariance reindexing `x ↦ x + y` is the only group-theoretic
  input, and it appears once, inside `fourier_conv`.
* Analyst: the fourth-power identity shows the double-dual isomorphism is not
  merely an abstract unit: it is the identification that makes `𝓕²` equal to the
  antipode.  This links `pontryagin` (Duality.lean) with `fourierNatIso`
  (Transform.lean) quantitatively.
* Critic: the constant in `fourier_fourier` is `|G|`, not `1`; a
  unitary normalisation `|G|^{-1/2}` would remove it but would break the
  integrality of the statement, so we keep the constant explicit.  Plancherel is
  stated with the same asymmetric convention and is consistent with it.
-/

open CategoryTheory AddChar Finset

namespace FourierFunctor

section Convolution

variable {G : Type} [AddCommGroup G] [Fintype G]

/-- Convolution of two functions on a finite abelian group. -/
noncomputable def conv (f g : G → ℂ) : G → ℂ := fun x => ∑ y : G, f y * g (x - y)

lemma conv_apply (f g : G → ℂ) (x : G) : conv f g x = ∑ y : G, f y * g (x - y) := rfl

/-- Reindexing lemma: translating the argument of `g` multiplies its transform
by a character value. -/
lemma sum_translate (g : G → ℂ) (ψ : AddChar G ℂ) (y : G) :
    (∑ x : G, g (x - y) * ψ (-x)) = ψ (-y) * fourier g ψ := by
  rw [fourier_apply, Finset.mul_sum]
  refine (Fintype.sum_bijective (fun z : G => z + y) (Equiv.addRight y).bijective
    (fun z => ψ (-y) * (g z * ψ (-z))) (fun x => g (x - y) * ψ (-x)) ?_).symm
  intro z
  show ψ (-y) * (g z * ψ (-z)) = g (z + y - y) * ψ (-(z + y))
  rw [show z + y - y = z by abel, show -(z + y) = -z + -y by abel, ψ.map_add_eq_mul]
  ring

/-- **The convolution theorem**: the Fourier transform turns convolution into
pointwise multiplication. -/
theorem fourier_conv (f g : G → ℂ) (ψ : AddChar G ℂ) :
    fourier (conv f g) ψ = fourier f ψ * fourier g ψ := by
  rw [fourier_apply]
  have step : ∀ x : G, conv f g x * ψ (-x) = ∑ y : G, f y * (g (x - y) * ψ (-x)) := by
    intro x
    rw [conv_apply, Finset.sum_mul]
    exact Finset.sum_congr rfl fun y _ => by ring
  rw [Finset.sum_congr rfl fun x _ => step x, Finset.sum_comm]
  have inner : ∀ y : G, (∑ x : G, f y * (g (x - y) * ψ (-x)))
      = f y * ψ (-y) * fourier g ψ := by
    intro y
    rw [← Finset.mul_sum, sum_translate g ψ y]
    ring
  rw [Finset.sum_congr rfl fun y _ => inner y, ← Finset.sum_mul]
  rfl

/-- Convolution is commutative — proved by transporting `mul_comm` through the
Fourier isomorphism. -/
theorem conv_comm (f g : G → ℂ) : conv f g = conv g f := by
  refine (fourierEquiv (G := G)).injective ?_
  funext ψ
  show fourier (conv f g) ψ = fourier (conv g f) ψ
  rw [fourier_conv, fourier_conv, mul_comm]

/-- Convolution is associative — again transported from `mul_assoc` in `ℂ`. -/
theorem conv_assoc (f g h : G → ℂ) : conv (conv f g) h = conv f (conv g h) := by
  refine (fourierEquiv (G := G)).injective ?_
  funext ψ
  show fourier (conv (conv f g) h) ψ = fourier (conv f (conv g h)) ψ
  rw [fourier_conv, fourier_conv, fourier_conv, fourier_conv, mul_assoc]

/-- The Dirac mass at `0` is the unit for convolution. -/
theorem conv_delta (f : G → ℂ) : conv (delta (0 : G)) f = f := by
  classical
  funext x
  rw [conv_apply, Finset.sum_eq_single (0 : G)]
  · simp [delta]
  · intro y _ hy; simp [delta, hy]
  · intro h; exact absurd (Finset.mem_univ (0 : G)) h

/-- Convolution distributes over addition. -/
theorem conv_add (f g h : G → ℂ) : conv f (g + h) = conv f g + conv f h := by
  funext x
  simp only [conv_apply, Pi.add_apply]
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun y _ => by ring

/-! ### Plancherel -/

lemma conj_addChar (ψ : AddChar G ℂ) (x : G) : (starRingEnd ℂ) (ψ x) = ψ (-x) := by
  rw [← Complex.inv_eq_conj (ψ.norm_apply x), ← ψ.map_neg_eq_inv]

/-- **Plancherel's theorem** (complex form): `∑_ψ 𝓕f ψ · conj(𝓕f ψ) = |G| ∑_g f g · conj(f g)`. -/
theorem plancherel_complex (f : G → ℂ) :
    (∑ ψ : AddChar G ℂ, fourier f ψ * (starRingEnd ℂ) (fourier f ψ))
      = (Fintype.card G : ℂ) * ∑ g : G, f g * (starRingEnd ℂ) (f g) := by
  classical
  have expand : ∀ ψ : AddChar G ℂ, fourier f ψ * (starRingEnd ℂ) (fourier f ψ)
      = ∑ g : G, ∑ h : G, f g * (starRingEnd ℂ) (f h) * ψ (h - g) := by
    intro ψ
    rw [fourier_apply, map_sum, Finset.sum_mul]
    refine Finset.sum_congr rfl fun g _ => ?_
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun h _ => ?_
    rw [map_mul, conj_addChar, neg_neg, show h - g = h + -g by abel, ψ.map_add_eq_mul]
    ring
  rw [Finset.sum_congr rfl fun ψ _ => expand ψ]
  rw [Finset.sum_comm]
  have inner : ∀ g : G, (∑ ψ : AddChar G ℂ, ∑ h : G, f g * (starRingEnd ℂ) (f h) * ψ (h - g))
      = (Fintype.card G : ℂ) * (f g * (starRingEnd ℂ) (f g)) := by
    intro g
    rw [Finset.sum_comm]
    have hh : ∀ h : G, (∑ ψ : AddChar G ℂ, f g * (starRingEnd ℂ) (f h) * ψ (h - g))
        = f g * (starRingEnd ℂ) (f h) * (if h - g = 0 then (Fintype.card G : ℂ) else 0) := by
      intro h
      rw [← Finset.mul_sum, AddChar.sum_apply_eq_ite]
    rw [Finset.sum_congr rfl fun h _ => hh h]
    have hh2 : ∀ h : G, f g * (starRingEnd ℂ) (f h) * (if h - g = 0 then (Fintype.card G : ℂ) else 0)
        = if h = g then (Fintype.card G : ℂ) * (f g * (starRingEnd ℂ) (f g)) else 0 := by
      intro h
      by_cases hhg : h = g
      · subst hhg; simp; ring
      · rw [if_neg hhg, if_neg (by simpa [sub_eq_zero] using hhg), mul_zero]
    rw [Finset.sum_congr rfl fun h _ => hh2 h, Finset.sum_ite_eq' Finset.univ g]
    simp
  rw [Finset.sum_congr rfl fun g _ => inner g, ← Finset.mul_sum]

/-- **Plancherel's theorem** (norm form): the Fourier transform is an isometry
up to the factor `|G|`. -/
theorem plancherel (f : G → ℂ) :
    (∑ ψ : AddChar G ℂ, ‖fourier f ψ‖ ^ 2) = (Fintype.card G : ℝ) * ∑ g : G, ‖f g‖ ^ 2 := by
  have h := plancherel_complex f
  have hL : (∑ ψ : AddChar G ℂ, fourier f ψ * (starRingEnd ℂ) (fourier f ψ))
      = ((∑ ψ : AddChar G ℂ, ‖fourier f ψ‖ ^ 2 : ℝ) : ℂ) := by
    push_cast
    exact Finset.sum_congr rfl fun ψ _ => by
      rw [Complex.mul_conj]; norm_cast; exact Complex.normSq_eq_norm_sq _
  have hR : ((Fintype.card G : ℂ) * ∑ g : G, f g * (starRingEnd ℂ) (f g))
      = (((Fintype.card G : ℝ) * ∑ g : G, ‖f g‖ ^ 2 : ℝ) : ℂ) := by
    push_cast
    refine congrArg _ (Finset.sum_congr rfl fun g _ => ?_)
    rw [Complex.mul_conj]; norm_cast; exact Complex.normSq_eq_norm_sq _
  rw [hL, hR] at h
  exact_mod_cast h

/-! ### The fourth-power identity -/

/-- **The Fourier transform squares to the antipode.**  Transforming twice — the
second time on the dual group, and evaluating at the double dual embedding of
`x` — returns `|G| · f(-x)`.  In particular `𝓕⁴ = |G|²·id`: under the
identification provided by the unit of `pontryagin`, the Fourier transform has
order four. -/
theorem fourier_fourier (f : G → ℂ) (x : G) :
    fourier (fourier f) (AddChar.doubleDualEmb x) = (Fintype.card G : ℂ) * f (-x) := by
  have hstep : ∀ ψ : AddChar G ℂ,
      fourier f ψ * (AddChar.doubleDualEmb (M := ℂ) x) (-ψ) = fourier f ψ * ψ (-x) := by
    intro ψ
    rw [AddChar.doubleDualEmb_apply, AddChar.neg_apply]
  rw [fourier_apply, Finset.sum_congr rfl fun ψ _ => hstep ψ]
  have hinv : f (-x) = (Fintype.card G : ℂ)⁻¹ * ∑ ψ : AddChar G ℂ, fourier f ψ * ψ (-x) := by
    conv_lhs => rw [← fourierInv_fourier f]
    rw [fourierInv_apply]
  rw [hinv, ← mul_assoc, mul_inv_cancel₀ (card_ne_zero_complex (G := G)), one_mul]

/-- The fourth power of the Fourier transform is multiplication by `|G|²`
(after the two double-dual identifications). -/
theorem fourier_four (f : G → ℂ) (x : G) :
    fourier (G := AddChar (AddChar (AddChar G ℂ) ℂ) ℂ)
        (fourier (G := AddChar (AddChar G ℂ) ℂ) (fourier (G := AddChar G ℂ) (fourier f)))
        (AddChar.doubleDualEmb (AddChar.doubleDualEmb x))
      = (Fintype.card G : ℂ) ^ 2 * f x := by
  have h1 := fourier_fourier (G := AddChar (AddChar G ℂ) ℂ)
    (fourier (G := AddChar G ℂ) (fourier f)) (AddChar.doubleDualEmb x)
  have hcard : (Fintype.card (AddChar (AddChar G ℂ) ℂ) : ℂ) = (Fintype.card G : ℂ) := by
    have h := AddChar.card_eq (α := AddChar G ℂ)
    have h' := AddChar.card_eq (α := G)
    exact_mod_cast congrArg (fun n : ℕ => (n : ℂ)) (h.trans h')
  rw [h1, hcard, ← map_neg, fourier_fourier f (-x), neg_neg]
  ring

end Convolution

end FourierFunctor