import Mathlib
import Computation.Demushkin.CupForm
import Computation.Demushkin.IsotropyLocus

/-!
# Concrete Demushkin cup-product forms over 𝔽₂

This file exhibits explicit nondegenerate symmetric cup-product forms over `𝔽₂`, showing
that the abstract theory of `CupForm.lean` and `IsotropyLocus.lean` is **non-vacuous** and
that *both* Demushkin types actually occur:

* `Demushkin.dotForm n` — the standard dot product on `𝔽₂ⁿ`.  It is symmetric,
  nondegenerate, and (for `n ≥ 1`) **not alternating**, so it realises the *odd type*.  Its
  isotropy locus is the even-weight hyperplane, of codimension one — a concrete instance of
  `isotropy_codim_one`.
* `Demushkin.hypForm` — the hyperbolic plane on `𝔽₂²`.  It is symmetric, nondegenerate and
  **alternating**, so it realises the *even type*, with vanishing Kummer class and full
  isotropy locus.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Both Demushkin types are realised by explicit small forms, so
the type dichotomy of `CupForm`/`IsotropyLocus` is not vacuous.  The dot product should be
odd type with Kummer class the all-ones vector; the hyperbolic plane should be even type.

Experiment (Experimenter): `dotForm` is built with `LinearMap.mk₂`; nondegeneracy is proved
by pairing against the standard basis vectors `Pi.single i 1` (which recovers the `i`-th
coordinate).  Not-alternating is witnessed by a single basis vector (`⟪eᵢ,eᵢ⟫ = 1`).
Instantiating `isotropy_codim_one` shows the even-weight vectors form a hyperplane.  The
hyperbolic form `x₀y₁+x₁y₀` is alternating because the cross terms cancel mod 2.

Analysis (Analyst): The dot product is odd type in *every* positive dimension, while the
hyperbolic plane is even type; combining direct sums of these realises every rank/type
combination, matching the Demushkin classification over `ℚ₂`.

Critique (Critic): These are genuine constructions with proved `Nondegenerate` and `IsSymm`
witnesses, not `sorry`ed placeholders, so the abstract hypotheses are demonstrably
inhabited.  The corollaries invoke the abstract theorems, guarding against vacuity.
-/

open LinearMap (BilinForm)

namespace Demushkin

/-! ## The dot-product form (odd type) -/

/-- The standard dot-product bilinear form on `𝔽₂ⁿ`. -/
noncomputable def dotForm (n : ℕ) : BilinForm (ZMod 2) (Fin n → ZMod 2) :=
  LinearMap.mk₂ (ZMod 2) (fun x y => ∑ i, x i * y i)
    (by intro x y z; simp [Finset.sum_add_distrib, add_mul])
    (by intro c x y; simp only [Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
        exact Finset.sum_congr rfl (fun i _ => by ring))
    (by intro x y z; simp [Finset.sum_add_distrib, mul_add])
    (by intro c x y; simp only [Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
        exact Finset.sum_congr rfl (fun i _ => by ring))

@[simp] theorem dotForm_apply (n : ℕ) (x y : Fin n → ZMod 2) :
    dotForm n x y = ∑ i, x i * y i := rfl

theorem dotForm_single (n : ℕ) (x : Fin n → ZMod 2) (i : Fin n) :
    dotForm n x (Pi.single i 1) = x i := by
  simp only [dotForm_apply]
  rw [Finset.sum_eq_single i]
  · simp
  · intro j _ hj; simp [Pi.single_eq_of_ne hj]
  · intro h; simp at h

theorem dotForm_symm (n : ℕ) : (dotForm n).IsSymm := by
  refine ⟨fun x y => ?_⟩
  simp only [dotForm_apply]
  exact Finset.sum_congr rfl (fun i _ => mul_comm _ _)

theorem dotForm_nondeg (n : ℕ) : (dotForm n).Nondegenerate := by
  constructor
  · intro x hx; funext i; have := hx (Pi.single i 1); rwa [dotForm_single] at this
  · intro y hy; funext i
    have h := hy (Pi.single i 1)
    rw [(dotForm_symm n).eq (Pi.single i 1) y, dotForm_single] at h
    exact h

/-- The dot product is **not alternating** in positive dimension: `⟪e₀, e₀⟫ = 1`. -/
theorem dotForm_not_alt (n : ℕ) (hn : 0 < n) : ¬ ∀ x, dotForm n x x = 0 := by
  intro h
  have := h (Pi.single ⟨0, hn⟩ 1)
  rw [dotForm_single] at this
  simp at this

/-- **Concrete odd-type Demushkin form.** For `n ≥ 1` the isotropy locus of the dot
product (the *even-weight* vectors) is a hyperplane: its dimension is `n - 1`. -/
theorem dotForm_isotropy_codim (n : ℕ) (hn : 0 < n) :
    Module.finrank (ZMod 2)
        (DemushkinCupForm.isotropic (dotForm n) (dotForm_symm n)) + 1 = n := by
  have h := DemushkinCupForm.isotropy_codim_one (dotForm n) (dotForm_symm n)
    (dotForm_not_alt n hn)
  simpa using h

/-! ## The hyperbolic plane (even type) -/

/-- The hyperbolic plane `⟪x, y⟫ = x₀y₁ + x₁y₀` on `𝔽₂²`. -/
noncomputable def hypForm : BilinForm (ZMod 2) (Fin 2 → ZMod 2) :=
  LinearMap.mk₂ (ZMod 2) (fun x y => x 0 * y 1 + x 1 * y 0)
    (by intro x y z; simp; ring)
    (by intro c x y; simp; ring)
    (by intro x y z; simp; ring)
    (by intro c x y; simp; ring)

@[simp] theorem hypForm_apply (x y : Fin 2 → ZMod 2) :
    hypForm x y = x 0 * y 1 + x 1 * y 0 := rfl

theorem hypForm_symm : hypForm.IsSymm := by
  refine ⟨fun x y => ?_⟩; simp only [hypForm_apply]; ring

/-- The hyperbolic plane is **alternating** (even type): `⟪x, x⟫ = 0` for all `x`. -/
theorem hypForm_alt : ∀ x, hypForm x x = 0 := by
  intro x
  simp only [hypForm_apply]
  have : x 0 * x 1 + x 1 * x 0 = (x 0 * x 1) + (x 0 * x 1) := by ring
  rw [this, CharTwo.add_self_eq_zero]

theorem hypForm_nondeg : hypForm.Nondegenerate := by
  constructor
  · intro x hx
    funext i
    fin_cases i
    · have := hx (Pi.single 1 1); simpa [hypForm_apply, Pi.single] using this
    · have := hx (Pi.single 0 1); simpa [hypForm_apply, Pi.single] using this
  · intro y hy
    funext i
    fin_cases i
    · have := hy (Pi.single 1 1); simpa [hypForm_apply, Pi.single] using this
    · have := hy (Pi.single 0 1); simpa [hypForm_apply, Pi.single] using this

/-- **Concrete even-type Demushkin form.** The hyperbolic plane has full isotropy locus. -/
theorem hypForm_isotropic_top :
    DemushkinCupForm.isotropic hypForm hypForm_symm = ⊤ :=
  (DemushkinCupForm.isotropic_eq_top_iff_alt hypForm hypForm_symm).mpr hypForm_alt

/-- **Concrete even-type Demushkin form.** The hyperbolic plane has vanishing Kummer
class. -/
theorem hypForm_kummer_zero :
    DemushkinCupForm.kummer hypForm hypForm_symm hypForm_nondeg = 0 :=
  (DemushkinCupForm.alternating_iff_kummer_zero hypForm hypForm_symm hypForm_nondeg).mp
    hypForm_alt

end Demushkin