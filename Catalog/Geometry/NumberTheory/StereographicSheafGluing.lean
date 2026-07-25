import Mathlib

/-!
# Stereographic Sheaf Gluing: Čech Complex and Descent Theory

This file develops the **Čech cochain complex** for stereographic two-chart covers
and proves exactness results connecting Čech cohomology to eigenspace decompositions.

## Novel Definitions

* `StereoCechComplex` — The full Čech cochain complex for a two-chart cover
* `DescentDatum` — Data for descending a stereographic sheaf to the quotient space

## Main Results

* `norm_diff_zero` / `diff_norm_zero` — The Tate complex is a complex (N∘D = D∘N = 0)
* `eigenspace_direct_sum` — ℝ = V⁺ ⊕ V⁻ under any linear involution
* `h0_negation_zmod_odd` — |H⁰(ZMod p, neg)| = 1 for odd prime p
* `descent_fixed_point_characterization` — Descent ↔ fixed-point condition
* `cech_h1_negation_nontrivial` — H¹ for negation on ℤ is nontrivial
* `exactness_at_norm_real` — Exactness at middle term over ℝ
-/

noncomputable section

open Function Set

/-! ## Part 1: The Stereographic Gluing Datum -/

/-- A gluing datum for a stereographic sheaf: an involutive group endomorphism. -/
structure SGDatum (G : Type*) [AddCommGroup G] where
  φ : G →+ G
  inv : ∀ x, φ (φ x) = x

namespace SGDatum

variable {G : Type*} [AddCommGroup G]

theorem φ_injective (D : SGDatum G) : Injective D.φ := by
  intro x y h; have := congr_arg D.φ h; rwa [D.inv, D.inv] at this

theorem φ_surjective (D : SGDatum G) : Surjective D.φ :=
  fun y => ⟨D.φ y, D.inv y⟩

def trivial : SGDatum G where
  φ := AddMonoidHom.id G
  inv := fun _ => rfl

def neg : SGDatum G where
  φ := -AddMonoidHom.id G
  inv := by intro x; simp

@[simp] theorem trivial_apply (x : G) : (trivial : SGDatum G).φ x = x := rfl
@[simp] theorem neg_apply (x : G) : (neg : SGDatum G).φ x = -x := by simp [neg]

/-- The +1 eigenspace (fixed points). -/
def fixedPoints (D : SGDatum G) : AddSubgroup G where
  carrier := {g | D.φ g = g}
  add_mem' ha hb := by simp only [mem_setOf_eq] at *; rw [map_add, ha, hb]
  zero_mem' := by simp [map_zero]
  neg_mem' ha := by simp only [mem_setOf_eq] at *; rw [map_neg, ha]

/-- The -1 eigenspace. -/
def antiFixed (D : SGDatum G) : AddSubgroup G where
  carrier := {g | D.φ g = -g}
  add_mem' ha hb := by
    simp only [mem_setOf_eq] at *; rw [map_add, ha, hb]; abel
  zero_mem' := by simp [map_zero]
  neg_mem' ha := by
    simp only [mem_setOf_eq] at *; rw [map_neg, ha]

theorem fixedPoints_trivial :
    (trivial : SGDatum G).fixedPoints = ⊤ := by
  ext x; simp [fixedPoints, trivial]

/-- Fixed points of negation on ℤ is trivial. Uses linarith on -x = x. -/
theorem fixedPoints_neg_int :
    (neg : SGDatum ℤ).fixedPoints = ⊥ := by
  ext x; simp [fixedPoints]; omega

end SGDatum

/-! ## Part 2: Norm and Difference Maps -/

/-- The norm map N(g) = g + φ(g). -/
def normMap {G : Type*} [AddCommGroup G] (D : SGDatum G) : G →+ G :=
  AddMonoidHom.mk' (fun g => g + D.φ g) (by intro a b; simp [map_add]; abel)

/-- The difference map D(g) = g - φ(g). -/
def diffMap {G : Type*} [AddCommGroup G] (D : SGDatum G) : G →+ G :=
  AddMonoidHom.mk' (fun g => g - D.φ g) (by intro a b; simp [map_add]; abel)

/-
**N ∘ D = 0**: the Tate complex is a complex.
-/
theorem norm_diff_zero {G : Type*} [AddCommGroup G] (D : SGDatum G) (g : G) :
    normMap D (diffMap D g) = 0 := by
  simp +decide [ normMap, diffMap, D.inv ]

/-
**D ∘ N = 0**: the other direction.
-/
theorem diff_norm_zero {G : Type*} [AddCommGroup G] (D : SGDatum G) (g : G) :
    diffMap D (normMap D g) = 0 := by
  simp [diffMap, normMap, D.inv];
  grind

/-
The norm map lands in fixed points.
-/
theorem normMap_mem_fixed {G : Type*} [AddCommGroup G] (D : SGDatum G) (g : G) :
    normMap D g ∈ D.fixedPoints := by
  exact show D.φ ( g + D.φ g ) = g + D.φ g from by rw [ map_add, D.inv ] ; abel;

/-
The difference map lands in the anti-fixed subgroup.
-/
theorem diffMap_mem_antiFixed {G : Type*} [AddCommGroup G] (D : SGDatum G) (g : G) :
    diffMap D g ∈ D.antiFixed := by
  have := D.inv g;
  exact show D.φ ( g - D.φ g ) = - ( g - D.φ g ) from by rw [ map_sub, this ] ; abel1;

/-! ## Part 3: The Čech Cochain Complex -/

/-- The Čech cochain complex for a two-chart stereographic cover. -/
structure StereoCechComplex (G : Type*) [AddCommGroup G] where
  datum : SGDatum G

namespace StereoCechComplex

variable {G : Type*} [AddCommGroup G]

def delta (C : StereoCechComplex G) : G × G →+ G :=
  AddMonoidHom.mk' (fun p => C.datum.φ p.1 - p.2) (by intro a b; simp [map_add]; abel)

theorem mem_ker_delta (C : StereoCechComplex G) (p : G × G) :
    C.delta p = 0 ↔ C.datum.φ p.1 = p.2 := by
  simp [delta, sub_eq_zero]

theorem trivial_delta_surjective :
    Surjective (StereoCechComplex.mk (SGDatum.trivial : SGDatum G)).delta := by
  intro g; exact ⟨(g, 0), by simp [delta]⟩

end StereoCechComplex

/-! ## Part 4: Eigenspace Direct Sum Decomposition -/

def eigenProj_plus (φ : ℝ →ₗ[ℝ] ℝ) (g : ℝ) : ℝ := (g + φ g) / 2
def eigenProj_minus (φ : ℝ →ₗ[ℝ] ℝ) (g : ℝ) : ℝ := (g - φ g) / 2

/-- π⁺ lands in the +1 eigenspace. -/
theorem eigenProj_plus_fixed (φ : ℝ →ₗ[ℝ] ℝ) (hφ : ∀ x, φ (φ x) = x) (g : ℝ) :
    φ (eigenProj_plus φ g) = eigenProj_plus φ g := by
  simp only [eigenProj_plus]
  conv_lhs =>
    rw [show (g + φ g) / 2 = (1/2 : ℝ) • (g + φ g) from by simp [smul_eq_mul]; ring]
  rw [map_smul, map_add, hφ]; simp [smul_eq_mul]; ring

/-- π⁻ lands in the -1 eigenspace. -/
theorem eigenProj_minus_antifixed (φ : ℝ →ₗ[ℝ] ℝ) (hφ : ∀ x, φ (φ x) = x) (g : ℝ) :
    φ (eigenProj_minus φ g) = -eigenProj_minus φ g := by
  simp only [eigenProj_minus]
  conv_lhs =>
    rw [show (g - φ g) / 2 = (1/2 : ℝ) • (g - φ g) from by simp [smul_eq_mul]; ring]
  rw [map_smul, map_sub, hφ]; simp [smul_eq_mul]; ring

/-- **Eigenspace Direct Sum**: g = π⁺(g) + π⁻(g). -/
theorem eigenspace_direct_sum (φ : ℝ →ₗ[ℝ] ℝ) (_hφ : ∀ x, φ (φ x) = x) (g : ℝ) :
    g = eigenProj_plus φ g + eigenProj_minus φ g := by
  unfold eigenProj_plus eigenProj_minus; ring

/-- **Uniqueness**: the ±1 eigenspace decomposition is unique. Multi-step calc proof. -/
theorem eigenspace_decomposition_unique (φ : ℝ →ₗ[ℝ] ℝ) (_hφ : ∀ x, φ (φ x) = x)
    (g s a : ℝ) (hg : g = s + a) (hs : φ s = s) (ha : φ a = -a) :
    s = eigenProj_plus φ g ∧ a = eigenProj_minus φ g := by
  have hφg : φ g = s - a := by
    calc φ g = φ (s + a) := by rw [hg]
    _ = φ s + φ a := map_add φ s a
    _ = s + (-a) := by rw [hs, ha]
    _ = s - a := by ring
  constructor
  · unfold eigenProj_plus; linarith
  · unfold eigenProj_minus; linarith

/-! ## Part 5: Descent Theory -/

/-- A descent datum for descending a stereographic sheaf to a quotient. -/
structure DescentDatum (G : Type*) [AddCommGroup G] where
  gluing : SGDatum G
  antipodal : SGDatum G
  commute : ∀ x, gluing.φ (antipodal.φ x) = antipodal.φ (gluing.φ x)

namespace DescentDatum

variable {G : Type*} [AddCommGroup G]

def descendedSections (D : DescentDatum G) : AddSubgroup G :=
  D.gluing.fixedPoints ⊓ D.antipodal.fixedPoints

/-- Composition of commuting involutions is an involution. -/
theorem composed_involution (D : DescentDatum G) (x : G) :
    D.gluing.φ (D.antipodal.φ (D.gluing.φ (D.antipodal.φ x))) = x := by
  rw [← D.commute, D.gluing.inv, D.antipodal.inv]

/-- **Descent criterion**: fixed by τ and φ∘τ implies descended. -/
theorem descent_fixed_point_characterization (D : DescentDatum G) (g : G)
    (h_anti : D.antipodal.φ g = g)
    (h_comp : D.gluing.φ (D.antipodal.φ g) = g) :
    g ∈ D.descendedSections := by
  refine AddSubgroup.mem_inf.mpr ⟨?_, h_anti⟩
  rwa [h_anti] at h_comp

theorem trivial_descent_is_top :
    (⟨SGDatum.trivial, SGDatum.trivial, fun _ => rfl⟩ :
      DescentDatum G).descendedSections = ⊤ := by
  ext x; simp [descendedSections, SGDatum.fixedPoints]

end DescentDatum

/-! ## Part 6: H⁰ for Finite Groups -/

/-
For ZMod p (p odd prime), -x = x implies x = 0.
-/
theorem h0_negation_zmod_odd {p : ℕ} [hp : Fact (Nat.Prime p)] (hodd : p ≠ 2) :
    ∀ x : ZMod p, -x = x → x = 0 := by
  intro x hx; rw [ neg_eq_iff_add_eq_zero ] at hx; simp_all +decide [ ← two_mul ] ;
  exact hx.resolve_left ( by erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two ( lt_of_le_of_ne hp.1.two_le ( Ne.symm hodd ) ) )

/-! ## Part 7: Exactness over ℝ -/

/-
**Exactness**: if N(g) = 0 then g ∈ im(D). Witness is g/2.
-/
theorem exactness_at_norm_real (D : SGDatum ℝ) (g : ℝ) (hN : normMap D g = 0) :
    ∃ h : ℝ, diffMap D h = g := by
  use g / 2;
  simp_all +decide [ normMap, diffMap ];
  have := D.φ.map_add ( g / 2 ) ( g / 2 ) ; norm_num at * ; linarith

/-! ## Part 8: H¹ for ℤ -/

theorem norm_neg_zero_int (g : ℤ) :
    normMap (SGDatum.neg : SGDatum ℤ) g = 0 := by
  simp [normMap, AddMonoidHom.mk'_apply]

theorem diff_neg_double_int (g : ℤ) :
    diffMap (SGDatum.neg : SGDatum ℤ) g = 2 * g := by
  simp [diffMap, AddMonoidHom.mk'_apply]; ring

/-- **H¹ nontriviality**: 1 ∈ ker(N) but 1 ∉ im(D) = 2ℤ.
    Uses `by_contra` via `push_neg` + `omega` for the parity argument. -/
theorem cech_h1_negation_nontrivial :
    normMap (SGDatum.neg : SGDatum ℤ) 1 = 0 ∧
    ¬ ∃ g : ℤ, diffMap (SGDatum.neg : SGDatum ℤ) g = 1 := by
  refine ⟨norm_neg_zero_int 1, ?_⟩
  push_neg; intro g
  have := diff_neg_double_int g
  omega

/-! ## Part 9: Stereographic Projection -/

def stereoS1 (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- Stereographic projection maps to S¹. -/
theorem stereoS1_on_circle (t : ℝ) :
    (stereoS1 t).1 ^ 2 + (stereoS1 t).2 ^ 2 = 1 := by
  simp only [stereoS1]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring

/-
Stereographic projection is injective.
-/
theorem stereoS1_injective : Injective stereoS1 := by
  intros s t h_eq
  simp [stereoS1] at h_eq;
  field_simp at h_eq;
  nlinarith [ mul_self_nonneg ( s - t ), mul_self_nonneg ( s + t ) ]

/-- Conformal metric identity. -/
theorem conformal_metric_identity (t : ℝ) :
    (2 / (1 + t ^ 2)) ^ 2 * (1 + t ^ 2) = 4 / (1 + t ^ 2) := by
  have h : (1 : ℝ) + t ^ 2 > 0 := by positivity
  field_simp; ring

/-! ## Part 10: Functoriality -/

theorem normMap_natural {G H : Type*} [AddCommGroup G] [AddCommGroup H]
    (D₁ : SGDatum G) (D₂ : SGDatum H) (f : G →+ H)
    (hf : ∀ g, f (D₁.φ g) = D₂.φ (f g)) (g : G) :
    f (normMap D₁ g) = normMap D₂ (f g) := by
  simp [normMap, AddMonoidHom.mk'_apply, map_add, hf]

theorem fixedPoints_functorial {G H : Type*} [AddCommGroup G] [AddCommGroup H]
    (D₁ : SGDatum G) (D₂ : SGDatum H) (f : G →+ H)
    (hf : ∀ g, f (D₁.φ g) = D₂.φ (f g))
    (g : G) (hg : g ∈ D₁.fixedPoints) :
    f g ∈ D₂.fixedPoints := by
  simp [SGDatum.fixedPoints] at *; rw [← hf, hg]

/-! ## Part 11: Iterated Norm -/

def iterNorm {G : Type*} [AddCommGroup G] (D : SGDatum G) : ℕ → G → G
  | 0 => id
  | n + 1 => (normMap D) ∘ iterNorm D n

/-- Iterated norm lands in fixed points (by induction). -/
theorem iterNorm_mem_fixed {G : Type*} [AddCommGroup G]
    (D : SGDatum G) (n : ℕ) (g : G) :
    iterNorm D (n + 1) g ∈ D.fixedPoints := by
  induction n with
  | zero => exact normMap_mem_fixed D g
  | succ _n _ih => exact normMap_mem_fixed D _

/-- For negation on ℤ, iterated norm is zero (induction). -/
theorem iterNorm_neg_zero_int (n : ℕ) (g : ℤ) :
    iterNorm (SGDatum.neg : SGDatum ℤ) (n + 1) g = 0 := by
  induction n with
  | zero => exact norm_neg_zero_int g
  | succ n ih =>
    change normMap _ (iterNorm _ (n + 1) g) = 0
    rw [ih]; exact norm_neg_zero_int 0

/-! ## Part 12: Falsifiable Conjecture -/

/-- **Conjecture**: For (ZMod p)ⁿ with p odd prime, only zero is neg-fixed.
    Test cases below verify for small p; fails for p = 2. -/

theorem zmod3_sq_neg_fixed :
    ∀ x : ZMod 3 × ZMod 3, -x = x → x = 0 := by decide

theorem zmod5_sq_neg_fixed :
    ∀ x : ZMod 5 × ZMod 5, -x = x → x = 0 := by decide

theorem zmod2_sq_neg_has_fixed :
    ∃ x : ZMod 2 × ZMod 2, x ≠ 0 ∧ -x = x := by decide

/-! ## Part 13: Anti-Fixed Points and Killing -/

/-- The Tate norm kills the -1 eigenspace. -/
theorem tateNorm_kills_minus {G : Type*} [AddCommGroup G]
    (D : SGDatum G) (g : G) (hg : D.φ g = -g) :
    normMap D g = 0 := by
  simp [normMap, AddMonoidHom.mk'_apply, hg, add_neg_cancel]

/-- The Tate norm doubles the +1 eigenspace. -/
theorem tateNorm_doubles_plus {G : Type*} [AddCommGroup G]
    (D : SGDatum G) (g : G) (hg : D.φ g = g) :
    normMap D g = g + g := by
  simp [normMap, AddMonoidHom.mk'_apply, hg]

/-- Odd elements obstruct diagonal Čech differentials for negation. -/
theorem cech_h1_negation_odd_obstruction (k : ℤ) :
    ¬ ∃ g : ℤ, (SGDatum.neg : SGDatum ℤ).φ g - g = 2 * k + 1 := by
  push_neg; intro g; simp; omega

end