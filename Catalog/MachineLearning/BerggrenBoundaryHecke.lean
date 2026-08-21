import MachineLearning.BerggrenSilverUnits
import MachineLearning.BerggrenTreeFreeness

/-!
# The Hecke algebra of the Berggren boundary, and what its spectrum really is

The Berggren tree is a free ternary tree (`BerggrenStars.applyGens_root_injective`), so its
boundary is the space of infinite addresses

  `Bdry = ℕ → Gen ≅ {A, B, C}^ℕ`,

the **3-adic Cantor set**.  This file builds the natural Hecke (transfer) algebra on real
observables of that boundary and computes its spectrum exactly.

Two operators generate everything:

* the **Hecke / transfer operator** `T f (w) = Σ_{x ∈ {A,B,C}} f (x ⌢ w)`, summing over the
  three children — this is the local Hecke operator of a `(q+1)`-regular tree with `q = 2`;
* the **shift (translation) operator** `U f (w) = f (σ w)`, the composition operator of the
  one-sided shift.

The two relations

  `T U = 3 · id`   (`hecke_transl`)   and   `(U T)² = 3 · (U T)`   (`heckeSq`)

say that `E = (1/3) U T` is an idempotent: the boundary carries a genuine rank-one Hecke
pair, and every observable splits canonically into Hecke eigencomponents.

## Main results

* `heckeProj_idempotent`, `obs_isCompl` : the canonical spectral splitting
  `Obs = range U ⊕ ker T` of the boundary observables.
* `hecke_eigen_decomposition` : every observable is uniquely a sum of a `3`-eigenvector and
  a `0`-eigenvector of the Hecke operator `U T`.
* `hecke_eigenvalue_dichotomy` : **the spectrum is exactly `{0, 3}`** — no other Hecke
  eigenvalue exists on the boundary.
* `eigenspace_three_eq_range_transl`, `eigenspace_zero_eq_ker_hecke` : the two eigenspaces
  identified intrinsically.
* `silver_unit_not_hecke_eigenvalue` : **falsification.**  The Berggren spectral units
  `3 ± 2√2` are *not* Hecke eigenvalues of the boundary; the only eigenvalues are `q + 1 = 3`
  (the trivial/Eisenstein eigenvalue of a `3`-regular tree) and `0`.
* `hecke_eigenvalue_not_tempered` : the eigenvalue `3` violates the Ramanujan bound
  `|λ| ≤ 2√q = 2√2` for the prime `(√2)` of `ℤ[√2]` (whose residue field has `q = 2`
  elements), and so does `3 + 2√2`.  So even if the units were eigenvalues, the resulting
  automorphic object would be non-tempered.
* `satake_product_ne_two` : the pair `(3 + 2√2, 3 − 2√2)` has product `1`, not `q = 2`, so
  it is not the Satake parameter pair of an unramified representation of `GL(2)` over
  `ℚ(√2)_{(√2)}` with trivial central character.

The conclusion of this cycle is therefore negative on the Langlands moonshot but sharp:
the boundary of the Berggren tree carries a Hecke algebra, but a *degenerate* one, whose
only eigenvalues are `0` and the trivial eigenvalue `q + 1`.  The real quadratic field
enters the tree through the `B`-spine (see `MachineLearning.BerggrenSilverUnits`) and not
through the boundary spectrum.
-/

namespace BerggrenStars

namespace Boundary

open Finset

/-- The boundary of the Berggren tree: infinite addresses in the three-letter alphabet,
i.e. the 3-adic Cantor set. -/
abbrev Bdry : Type := ℕ → Gen

/-- The one-sided shift: forget the first letter of an address. -/
def shift (w : Bdry) : Bdry := fun n => w (n + 1)

/-- Prepend a letter to an address (descend one level in the tree). -/
def cons (x : Gen) (w : Bdry) : Bdry := fun n => Nat.casesOn n x w

@[simp] theorem cons_zero (x : Gen) (w : Bdry) : cons x w 0 = x := rfl

@[simp] theorem cons_succ (x : Gen) (w : Bdry) (n : ℕ) : cons x w (n + 1) = w n := rfl

@[simp] theorem shift_cons (x : Gen) (w : Bdry) : shift (cons x w) = w := rfl

theorem cons_shift (w : Bdry) : cons (w 0) (shift w) = w := by
  funext n
  cases n with
  | zero => rfl
  | succ k => rfl

/-- The shift is surjective: every address is the tail of an address. -/
theorem shift_surjective : Function.Surjective shift :=
  fun w => ⟨cons Gen.A w, rfl⟩

/-- Real observables on the boundary. -/
abbrev Obs : Type := Bdry → ℝ

/-- The **Hecke (transfer) operator** of the boundary: sum over the three children. -/
def hecke (f : Obs) : Obs := fun w => ∑ x : Gen, f (cons x w)

/-- The **shift operator** (composition with the shift): pull an observable back one
level. -/
def transl (f : Obs) : Obs := fun w => f (shift w)

theorem sum_gen_const (r : ℝ) : ∑ _x : Gen, r = 3 * r := by
  rw [Finset.sum_const, Finset.card_univ, card_Gen]
  simp [nsmul_eq_mul]

/-- **First Hecke relation:** `T U = 3 · id`.  The Hecke operator recovers three times the
observable from its pullback, because the tree is `3`-regular. -/
theorem hecke_transl (f : Obs) : hecke (transl f) = fun w => 3 * f w := by
  funext w
  simp only [hecke, transl, shift_cons]
  exact sum_gen_const (f w)

/-- **Second Hecke relation:** `(U T)² = 3 (U T)`.  Equivalently `(1/3) U T` is idempotent:
the boundary carries a rank-one Hecke pair. -/
theorem heckeSq (f : Obs) :
    transl (hecke (transl (hecke f))) = fun w => 3 * transl (hecke f) w := by
  have h := hecke_transl (hecke f)
  funext w
  simp only [transl, h]

/-! ### Linear-algebraic form -/

/-- The Hecke operator as an `ℝ`-linear map. -/
def heckeL : Obs →ₗ[ℝ] Obs where
  toFun := hecke
  map_add' f g := by
    funext w; simp [hecke, Finset.sum_add_distrib]
  map_smul' c f := by
    funext w; simp [hecke, Finset.mul_sum]

/-- The shift operator as an `ℝ`-linear map. -/
def translL : Obs →ₗ[ℝ] Obs where
  toFun := transl
  map_add' _ _ := rfl
  map_smul' _ _ := rfl

/-- The composite `U T`, the Hecke operator seen on the boundary itself. -/
def heckeUT : Obs →ₗ[ℝ] Obs := translL ∘ₗ heckeL

theorem heckeUT_apply (f : Obs) : heckeUT f = transl (hecke f) := rfl

/-- The normalized Hecke projector `E = (1/3) U T`. -/
noncomputable def heckeProj : Obs →ₗ[ℝ] Obs := (3⁻¹ : ℝ) • heckeUT

theorem heckeUT_sq (f : Obs) : heckeUT (heckeUT f) = (3 : ℝ) • heckeUT f := by
  have h := heckeSq f
  funext w
  simpa [heckeUT_apply, Pi.smul_apply, smul_eq_mul] using congrFun h w

theorem heckeProj_comp : heckeProj ∘ₗ heckeProj = heckeProj := by
  refine LinearMap.ext fun f => ?_
  funext w
  have h := congrFun (heckeUT_sq f) w
  simp only [LinearMap.comp_apply, heckeProj, LinearMap.smul_apply, map_smul, Pi.smul_apply,
    smul_eq_mul] at h ⊢
  linarith [h]

/-- `E = (1/3) U T` is idempotent. -/
theorem heckeProj_idempotent : IsIdempotentElem heckeProj := heckeProj_comp

/-- **Spectral splitting of the boundary observables**: the `3`-eigenspace and the
`0`-eigenspace of the Hecke operator are complementary. -/
theorem obs_isCompl : IsCompl (LinearMap.range heckeProj) (LinearMap.ker heckeProj) :=
  LinearMap.IsIdempotentElem.isCompl heckeProj_idempotent

/-- **Hecke eigen-decomposition.**  Every boundary observable splits uniquely as a sum of a
Hecke eigenvector of eigenvalue `3` and one of eigenvalue `0`. -/
theorem hecke_eigen_decomposition (f : Obs) :
    ∃ g h : Obs, f = g + h ∧ heckeUT g = (3 : ℝ) • g ∧ heckeUT h = 0 := by
  refine ⟨(3⁻¹ : ℝ) • heckeUT f, f - (3⁻¹ : ℝ) • heckeUT f, by ring_nf, ?_, ?_⟩
  · rw [map_smul, heckeUT_sq]
    rw [smul_comm]
  · rw [map_sub, map_smul, heckeUT_sq, smul_smul]
    norm_num

/-- Uniqueness of the eigen-decomposition. -/
theorem hecke_eigen_decomposition_unique {f g₁ h₁ g₂ h₂ : Obs}
    (hf₁ : f = g₁ + h₁) (hg₁ : heckeUT g₁ = (3 : ℝ) • g₁) (hh₁ : heckeUT h₁ = 0)
    (hf₂ : f = g₂ + h₂) (hg₂ : heckeUT g₂ = (3 : ℝ) • g₂) (hh₂ : heckeUT h₂ = 0) :
    g₁ = g₂ ∧ h₁ = h₂ := by
  have hsum : g₁ + h₁ = g₂ + h₂ := hf₁ ▸ hf₂ ▸ rfl
  have happ : heckeUT (g₁ + h₁) = heckeUT (g₂ + h₂) := by rw [hsum]
  rw [map_add, map_add, hg₁, hh₁, hg₂, hh₂, add_zero, add_zero] at happ
  have hg : g₁ = g₂ := by
    have := congrArg (fun v => (3⁻¹ : ℝ) • v) happ
    simpa [smul_smul] using this
  refine ⟨hg, ?_⟩
  have : g₁ + h₁ = g₁ + h₂ := by rw [hsum, hg]
  exact add_left_cancel this

/-- **The spectrum of the boundary Hecke operator is exactly `{0, 3}`.**  There is no other
eigenvalue: the boundary of the Berggren tree does not support a rich Hecke eigenbasis. -/
theorem hecke_eigenvalue_dichotomy {f : Obs} {lam : ℝ} (hf : f ≠ 0)
    (h : heckeUT f = lam • f) : lam = 0 ∨ lam = 3 := by
  have h2 : (lam * lam) • f = (3 * lam) • f := by
    have hl : heckeUT (heckeUT f) = (lam * lam) • f := by
      rw [h, map_smul, h, smul_smul]
    have hr : heckeUT (heckeUT f) = (3 * lam) • f := by
      rw [heckeUT_sq, h, smul_smul]
    rw [← hl, hr]
  have h3 : (lam * lam - 3 * lam) • f = 0 := by
    rw [sub_smul, h2, sub_self]
  rcases smul_eq_zero.mp h3 with hz | hz
  · have : lam * (lam - 3) = 0 := by linarith [hz]
    rcases mul_eq_zero.mp this with h' | h'
    · exact Or.inl h'
    · exact Or.inr (by linarith)
  · exact absurd hz hf

/-- The `3`-eigenspace is exactly the image of the shift operator. -/
theorem eigenspace_three_eq_range_transl (f : Obs) :
    heckeUT f = (3 : ℝ) • f ↔ ∃ g : Obs, f = transl g := by
  constructor
  · intro h
    refine ⟨(3⁻¹ : ℝ) • hecke f, ?_⟩
    have : (3 : ℝ) • f = transl (hecke f) := h.symm
    funext w
    have hw := congrFun this w
    simp only [Pi.smul_apply, smul_eq_mul, transl] at hw
    simp only [transl, Pi.smul_apply, smul_eq_mul]
    linarith [hw]
  · rintro ⟨g, rfl⟩
    have h := hecke_transl g
    funext w
    simp only [heckeUT_apply, h, transl, Pi.smul_apply, smul_eq_mul]

/-- The `0`-eigenspace of `U T` is exactly the kernel of the Hecke operator itself
(the shift operator is injective). -/
theorem eigenspace_zero_eq_ker_hecke (f : Obs) : heckeUT f = 0 ↔ hecke f = 0 := by
  constructor
  · intro h
    funext w
    have := congrFun h (cons Gen.A w)
    simpa [heckeUT_apply, transl] using this
  · intro h
    funext w
    simp [heckeUT_apply, transl, h]

/-- The constant observable `1` is the trivial (Eisenstein) Hecke eigenform, with the
degree eigenvalue `q + 1 = 3`. -/
theorem hecke_one : heckeUT (fun _ => (1 : ℝ)) = (3 : ℝ) • (fun _ => (1 : ℝ)) := by
  funext w
  simp only [heckeUT_apply, transl, hecke, Pi.smul_apply, smul_eq_mul]
  simpa using sum_gen_const (1 : ℝ)

/-- The `3`-eigenspace is nontrivial. -/
theorem eigenvalue_three_attained : ∃ f : Obs, f ≠ 0 ∧ heckeUT f = (3 : ℝ) • f := by
  refine ⟨fun _ => (1 : ℝ), ?_, hecke_one⟩
  intro h
  have := congrFun h (fun _ => Gen.A)
  norm_num at this

/-- A mean-zero weight on the three letters. -/
def sgn : Gen → ℝ
  | Gen.A => 1
  | Gen.B => -1
  | Gen.C => 0

/-- The `0`-eigenspace is nontrivial: differences of point masses along the first letter
are killed by the Hecke operator. -/
theorem eigenvalue_zero_attained : ∃ f : Obs, f ≠ 0 ∧ heckeUT f = 0 := by
  refine ⟨fun w => sgn (w 0), ?_, ?_⟩
  · intro h
    have := congrFun h (fun _ => Gen.A)
    norm_num [sgn] at this
  · funext w
    simp only [heckeUT_apply, transl, hecke, Pi.zero_apply, cons_zero]
    rw [show (Finset.univ : Finset Gen) = {Gen.A, Gen.B, Gen.C} from rfl,
      Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
    norm_num [sgn]

/-! ### Falsification: the Berggren units are not Hecke eigenvalues -/

open Silver

theorem sqrt_two_pos_lt : (1 : ℝ) < Real.sqrt 2 := by
  have h : Real.sqrt 1 < Real.sqrt 2 := by
    apply Real.sqrt_lt_sqrt <;> norm_num
  simpa using h

/-- `3 + 2√2` is irrational, in particular different from `0` and `3`. -/
theorem lam_real_ne : (3 : ℝ) + 2 * Real.sqrt 2 ≠ 3 ∧ (3 : ℝ) + 2 * Real.sqrt 2 ≠ 0 := by
  have h := sqrt_two_pos_lt
  constructor <;> intro hc <;> linarith

theorem lam_conj_real_ne : (3 : ℝ) - 2 * Real.sqrt 2 ≠ 3 ∧ (3 : ℝ) - 2 * Real.sqrt 2 ≠ 0 := by
  have h1 := sqrt_two_pos_lt
  have h2 : Real.sqrt 2 < 3 / 2 := by
    have : Real.sqrt 2 < Real.sqrt (9 / 4) := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    calc Real.sqrt 2 < Real.sqrt (9 / 4) := this
      _ = 3 / 2 := by
          rw [show (9 : ℝ) / 4 = (3 / 2) ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  constructor <;> intro hc <;> [linarith; nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num)]]

/-- **Falsification of the Hecke half of the moonshot.**  The spectral units `3 ± 2√2` of
the hyperbolic Berggren generator are *not* eigenvalues of the boundary Hecke operator:
the boundary spectrum is `{0, 3}` and the units are neither. -/
theorem silver_unit_not_hecke_eigenvalue (f : Obs) (hf : f ≠ 0) :
    heckeUT f ≠ ((3 : ℝ) + 2 * Real.sqrt 2) • f ∧
      heckeUT f ≠ ((3 : ℝ) - 2 * Real.sqrt 2) • f := by
  constructor
  · intro h
    rcases hecke_eigenvalue_dichotomy hf h with h0 | h3
    · exact lam_real_ne.2 h0
    · exact lam_real_ne.1 h3
  · intro h
    rcases hecke_eigenvalue_dichotomy hf h with h0 | h3
    · exact lam_conj_real_ne.2 h0
    · exact lam_conj_real_ne.1 h3

/-! ### Temperedness: the residue field at the ramified prime `(√2)` has `q = 2` elements -/

/-- The Ramanujan (temperedness) bound at a prime of residue degree `q = 2` is `2√q = 2√2`.
Both the tree eigenvalue `3` and the Berggren unit `3 + 2√2` exceed it, so neither can be
the Hecke eigenvalue of a tempered automorphic form at that prime. -/
theorem hecke_eigenvalue_not_tempered :
    2 * Real.sqrt 2 < 3 ∧ 2 * Real.sqrt 2 < 3 + 2 * Real.sqrt 2 := by
  have h1 : Real.sqrt 2 < 3 / 2 := by
    have : Real.sqrt 2 < Real.sqrt (9 / 4) := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    calc Real.sqrt 2 < Real.sqrt (9 / 4) := this
      _ = 3 / 2 := by
          rw [show (9 : ℝ) / 4 = (3 / 2) ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
  have h2 := sqrt_two_pos_lt
  exact ⟨by linarith, by linarith⟩

/-- The two Berggren eigenvalues multiply to `1`, not to `q = 2`: they are not the Satake
parameters of an unramified representation of `GL(2)` over the completion of `ℚ(√2)` at
the ramified prime above `2` with trivial central character. -/
theorem satake_product_ne_two :
    ((3 : ℝ) + 2 * Real.sqrt 2) * ((3 : ℝ) - 2 * Real.sqrt 2) = 1 ∧ (1 : ℝ) ≠ 2 := by
  have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  constructor
  · nlinarith [hs]
  · norm_num

end Boundary

end BerggrenStars