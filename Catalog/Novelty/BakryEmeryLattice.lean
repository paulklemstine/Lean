import Mathlib

/-!
# The integer line: a completely verified model case

The paper *Nonnegative Bakry–Émery curvature on bounded-degree graphs implies volume
doubling and Poincaré inequalities* asserts, for every bounded-degree graph with
`CD(0,∞)`, volume doubling plus a scale-invariant `L²`-Poincaré inequality with
dilation two.  This file verifies the whole chain, unconditionally and with explicit
constants, on the fundamental model: the integer line `ℤ` with its nearest-neighbour
(unnormalised) Laplacian.

* `latticeGamma2_sos` — an exact sum-of-squares identity for `Γ₂` on `ℤ`;
* `latticeCD02` — `ℤ` satisfies the (stronger) condition `CD(0,2)`:
  `Γ₂(f,f) ≥ ½ (Δ f)²`, hence a fortiori `CD(0,∞)`;
* `lattice_volume_doubling` — `#B(x,2r) ≤ 2 · #B(x,r)`, the sharp doubling constant;
* `lattice_poincare` — the scale-invariant `L²`-Poincaré inequality
  `∑_{B(x,r)} |f - f_B|² ≤ 3 r² ∑_{edges of B(x,r)} |df|²`;
* `lattice_poincare_dilation_two` — the same with the energy taken on `B(x,2r)`,
  which is the form used in the paper.

Nothing here is definitional: the curvature bound is an algebraic identity that has to
be discovered, and the Poincaré inequality goes through a telescoping/Cauchy–Schwarz
argument and the variance-minimising property of the mean.
-/

namespace BakryEmery

open Finset

/-! ### Γ-calculus on `ℤ` -/

/-- Nearest-neighbour unnormalised Laplacian on `ℤ`. -/
noncomputable def latticeDelta (f : ℤ → ℝ) (x : ℤ) : ℝ :=
  (f (x + 1) - f x) + (f (x - 1) - f x)

/-- Carré du champ on `ℤ`. -/
noncomputable def latticeGamma (f g : ℤ → ℝ) (x : ℤ) : ℝ :=
  (1 / 2) * ((f (x + 1) - f x) * (g (x + 1) - g x) + (f (x - 1) - f x) * (g (x - 1) - g x))

/-- Iterated carré du champ on `ℤ`. -/
noncomputable def latticeGamma2 (f : ℤ → ℝ) (x : ℤ) : ℝ :=
  (1 / 2) * latticeDelta (latticeGamma f f) x - latticeGamma f (latticeDelta f) x

/-- **Sum-of-squares identity for `Γ₂` on the integer line.**
Writing `u = f(x+1) - f(x)`, `w = f(x-1) - f(x)`, `p = f(x+2) - f(x+1)`,
`q = f(x-2) - f(x-1)`, one has
`Γ₂(f,f)(x) = ¼ (p-u)² + ¼ (q-w)² + ½ (u+w)²`. -/
theorem latticeGamma2_sos (f : ℤ → ℝ) (x : ℤ) :
    latticeGamma2 f x
      = (1 / 4) * ((f (x + 2) - f (x + 1)) - (f (x + 1) - f x)) ^ 2
        + (1 / 4) * ((f (x - 2) - f (x - 1)) - (f (x - 1) - f x)) ^ 2
        + (1 / 2) * ((f (x + 1) - f x) + (f (x - 1) - f x)) ^ 2 := by
  have e1 : x + 1 + 1 = x + 2 := by ring
  have e2 : x + 1 - 1 = x := by ring
  have e3 : x - 1 + 1 = x := by ring
  have e4 : x - 1 - 1 = x - 2 := by ring
  simp only [latticeGamma2, latticeDelta, latticeGamma, e1, e2, e3, e4]
  ring

/-- **The integer line satisfies `CD(0,2)`** (hence `CD(0,∞)`):
`Γ₂(f,f)(x) ≥ ½ (Δ f (x))²`. -/
theorem latticeCD02 (f : ℤ → ℝ) (x : ℤ) :
    (1 / 2) * (latticeDelta f x) ^ 2 ≤ latticeGamma2 f x := by
  rw [latticeGamma2_sos f x]
  have h : latticeDelta f x = (f (x + 1) - f x) + (f (x - 1) - f x) := rfl
  rw [h]
  nlinarith [sq_nonneg ((f (x + 2) - f (x + 1)) - (f (x + 1) - f x)),
    sq_nonneg ((f (x - 2) - f (x - 1)) - (f (x - 1) - f x))]

/-- Nonnegative Bakry–Émery curvature `CD(0,∞)` for the integer line. -/
theorem latticeCD0 (f : ℤ → ℝ) (x : ℤ) : 0 ≤ latticeGamma2 f x := by
  have h := latticeCD02 f x
  nlinarith [sq_nonneg (latticeDelta f x)]

/-! ### Volume doubling on `ℤ` -/

/-- Closed balls in the integer line. -/
def latticeBall (x : ℤ) (r : ℕ) : Finset ℤ := Finset.Icc (x - r) (x + r)

lemma card_latticeBall (x : ℤ) (r : ℕ) : (latticeBall x r).card = 2 * r + 1 := by
  rw [latticeBall, Int.card_Icc]
  have : x + (r:ℤ) + 1 - (x - r) = 2 * r + 1 := by ring
  rw [this]
  omega

/-- **Sharp volume doubling on the integer line**: `#B(x,2r) ≤ 2 · #B(x,r)`. -/
theorem lattice_volume_doubling (x : ℤ) (r : ℕ) :
    ((latticeBall x (2 * r)).card : ℝ) ≤ 2 * ((latticeBall x r).card : ℝ) := by
  rw [card_latticeBall, card_latticeBall]
  push_cast
  linarith [Nat.cast_nonneg (α := ℝ) r]

/-! ### Telescoping and a Cauchy–Schwarz gradient estimate -/

/-- Discrete Dirichlet energy of `f` on the edge set `{(i,i+1) : a ≤ i < b}`. -/
noncomputable def latticeEnergy (f : ℤ → ℝ) (a b : ℤ) : ℝ :=
  ∑ i ∈ Finset.Ico a b, (f (i + 1) - f i) ^ 2

lemma latticeEnergy_nonneg (f : ℤ → ℝ) (a b : ℤ) : 0 ≤ latticeEnergy f a b :=
  Finset.sum_nonneg fun i _ => sq_nonneg _

lemma latticeEnergy_mono (f : ℤ → ℝ) {a b a' b' : ℤ} (h1 : a' ≤ a) (h2 : b ≤ b') :
    latticeEnergy f a b ≤ latticeEnergy f a' b' := by
  refine Finset.sum_le_sum_of_subset_of_nonneg ?_ (fun i _ _ => sq_nonneg _)
  exact Finset.Ico_subset_Ico h1 h2

/-- Telescoping over an integer interval. -/
lemma lattice_telescope (f : ℤ → ℝ) {a b : ℤ} (h : a ≤ b) :
    f b - f a = ∑ i ∈ Finset.Ico a b, (f (i + 1) - f i) := by
  induction b, h using Int.le_induction with
  | base => simp
  | succ b hb ih =>
    have hIco : Finset.Ico a (b + 1) = (Finset.Ico a b).cons b Finset.right_notMem_Ico := by
      rw [← Finset.Icc_eq_cons_Ico hb]
      exact Finset.Ico_succ_right_eq_Icc a b
    rw [hIco, Finset.sum_cons, ← ih]
    ring

/-- Cauchy–Schwarz along a geodesic: `(f b - f a)² ≤ (b-a) · E(a,b)`. -/
lemma lattice_sq_sub_le (f : ℤ → ℝ) {a b : ℤ} (h : a ≤ b) :
    (f b - f a) ^ 2 ≤ ((b - a : ℤ) : ℝ) * latticeEnergy f a b := by
  rw [lattice_telescope f h]
  have hcs := sq_sum_le_card_mul_sum_sq (s := Finset.Ico a b) (f := fun i => f (i + 1) - f i)
  have hcard : ((Finset.Ico a b).card : ℝ) = ((b - a : ℤ) : ℝ) := by
    rw [Int.card_Ico]
    have : (0:ℤ) ≤ b - a := by omega
    rw [Int.toNat_of_nonneg this] <;> simp [Int.toNat_of_nonneg this]
  calc (∑ i ∈ Finset.Ico a b, (f (i + 1) - f i)) ^ 2
      ≤ ((Finset.Ico a b).card : ℝ) * ∑ i ∈ Finset.Ico a b, (f (i + 1) - f i) ^ 2 := hcs
    _ = ((b - a : ℤ) : ℝ) * latticeEnergy f a b := by rw [hcard]; rfl

/-! ### The variance and the mean -/

/-- The mean of `f` over a finite set. -/
noncomputable def meanOn (f : ℤ → ℝ) (s : Finset ℤ) : ℝ := (∑ y ∈ s, f y) / s.card

/-- The mean minimises the quadratic deviation: this is the only property of the mean
used in the Poincaré inequality. -/
lemma variance_le_of_const (f : ℤ → ℝ) (s : Finset ℤ) (hs : s.Nonempty) (m : ℝ) :
    ∑ y ∈ s, (f y - meanOn f s) ^ 2 ≤ ∑ y ∈ s, (f y - m) ^ 2 := by
  have hcard : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.2 hs
  set A := meanOn f s with hA
  have hsum : ∑ y ∈ s, f y = s.card * A := by
    field_simp [hA, meanOn]
  have key : ∑ y ∈ s, (f y - m) ^ 2
      = (∑ y ∈ s, (f y - A) ^ 2) + s.card * (A - m) ^ 2 := by
    have expand : ∀ y : ℤ, (f y - m) ^ 2 = (f y - A) ^ 2 + 2 * (A - m) * (f y - A) + (A - m) ^ 2 := by
      intro y; ring
    calc ∑ y ∈ s, (f y - m) ^ 2
        = ∑ y ∈ s, ((f y - A) ^ 2 + 2 * (A - m) * (f y - A) + (A - m) ^ 2) := by
          exact Finset.sum_congr rfl fun y _ => expand y
      _ = (∑ y ∈ s, (f y - A) ^ 2) + 2 * (A - m) * (∑ y ∈ s, (f y - A)) + s.card * (A - m) ^ 2 := by
          rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum,
            Finset.sum_const, nsmul_eq_mul]
      _ = (∑ y ∈ s, (f y - A) ^ 2) + s.card * (A - m) ^ 2 := by
          have : ∑ y ∈ s, (f y - A) = 0 := by
            rw [Finset.sum_sub_distrib, hsum, Finset.sum_const, nsmul_eq_mul]
            ring
          rw [this]; ring
  rw [key]
  nlinarith [sq_nonneg (A - m), hcard]

/-! ### The Poincaré inequality on the integer line -/

/-- Pointwise gradient estimate inside a ball: for `y ∈ B(x,r)`,
`(f y - f x)² ≤ r · E(x-r, x+r)`. -/
lemma lattice_pointwise_bound (f : ℤ → ℝ) (x : ℤ) (r : ℕ) {y : ℤ}
    (hy : y ∈ latticeBall x r) :
    (f y - f x) ^ 2 ≤ (r : ℝ) * latticeEnergy f (x - r) (x + r) := by
  rw [latticeBall, Finset.mem_Icc] at hy
  obtain ⟨hy1, hy2⟩ := hy
  rcases le_total x y with h | h
  · have h1 : (f y - f x) ^ 2 ≤ ((y - x : ℤ) : ℝ) * latticeEnergy f x y :=
      lattice_sq_sub_le f h
    have h2 : latticeEnergy f x y ≤ latticeEnergy f (x - r) (x + r) :=
      latticeEnergy_mono f (by omega) (by omega)
    have h3 : ((y - x : ℤ) : ℝ) ≤ (r : ℝ) := by
      have : (y - x : ℤ) ≤ (r : ℤ) := by omega
      exact_mod_cast this
    have h4 : (0:ℝ) ≤ ((y - x : ℤ) : ℝ) := by
      have : (0:ℤ) ≤ y - x := by omega
      exact_mod_cast this
    nlinarith [latticeEnergy_nonneg f x y, latticeEnergy_nonneg f (x - r) (x + r)]
  · have h1 : (f x - f y) ^ 2 ≤ ((x - y : ℤ) : ℝ) * latticeEnergy f y x :=
      lattice_sq_sub_le f h
    have h2 : latticeEnergy f y x ≤ latticeEnergy f (x - r) (x + r) :=
      latticeEnergy_mono f (by omega) (by omega)
    have h3 : ((x - y : ℤ) : ℝ) ≤ (r : ℝ) := by
      have : (x - y : ℤ) ≤ (r : ℤ) := by omega
      exact_mod_cast this
    have h4 : (0:ℝ) ≤ ((x - y : ℤ) : ℝ) := by
      have : (0:ℤ) ≤ x - y := by omega
      exact_mod_cast this
    have hsq : (f y - f x) ^ 2 = (f x - f y) ^ 2 := by ring
    rw [hsq]
    nlinarith [latticeEnergy_nonneg f y x, latticeEnergy_nonneg f (x - r) (x + r)]

/-- **Scale-invariant `L²`-Poincaré inequality on the integer line.**
For every `r ≥ 1`, every centre `x` and every `f : ℤ → ℝ`,
`∑_{y ∈ B(x,r)} |f y - f_{B(x,r)}|² ≤ 3 r² · E(B(x,r))`. -/
theorem lattice_poincare (f : ℤ → ℝ) (x : ℤ) (r : ℕ) (hr : 1 ≤ r) :
    ∑ y ∈ latticeBall x r, (f y - meanOn f (latticeBall x r)) ^ 2
      ≤ 3 * (r : ℝ) ^ 2 * latticeEnergy f (x - r) (x + r) := by
  have hne : (latticeBall x r).Nonempty := by
    refine ⟨x, ?_⟩
    rw [latticeBall, Finset.mem_Icc]
    constructor <;> omega
  have h1 : ∑ y ∈ latticeBall x r, (f y - meanOn f (latticeBall x r)) ^ 2
      ≤ ∑ y ∈ latticeBall x r, (f y - f x) ^ 2 :=
    variance_le_of_const f (latticeBall x r) hne (f x)
  have h2 : ∑ y ∈ latticeBall x r, (f y - f x) ^ 2
      ≤ ∑ _y ∈ latticeBall x r, (r : ℝ) * latticeEnergy f (x - r) (x + r) :=
    Finset.sum_le_sum fun y hy => lattice_pointwise_bound f x r hy
  have h3 : ∑ _y ∈ latticeBall x r, (r : ℝ) * latticeEnergy f (x - r) (x + r)
      = (2 * (r:ℝ) + 1) * ((r : ℝ) * latticeEnergy f (x - r) (x + r)) := by
    rw [Finset.sum_const, card_latticeBall, nsmul_eq_mul]
    push_cast
    ring
  have hE : 0 ≤ latticeEnergy f (x - r) (x + r) := latticeEnergy_nonneg _ _ _
  have hr1 : (1:ℝ) ≤ (r:ℝ) := by exact_mod_cast hr
  have h4 : (2 * (r:ℝ) + 1) * ((r : ℝ) * latticeEnergy f (x - r) (x + r))
      ≤ 3 * (r : ℝ) ^ 2 * latticeEnergy f (x - r) (x + r) := by
    nlinarith
  linarith

/-- **Poincaré inequality with dilation two**, the form appearing in the paper:
the energy is measured on the doubled ball. -/
theorem lattice_poincare_dilation_two (f : ℤ → ℝ) (x : ℤ) (r : ℕ) (hr : 1 ≤ r) :
    ∑ y ∈ latticeBall x r, (f y - meanOn f (latticeBall x r)) ^ 2
      ≤ 3 * (r : ℝ) ^ 2 * latticeEnergy f (x - 2 * r) (x + 2 * r) := by
  have h := lattice_poincare f x r hr
  have hmono : latticeEnergy f (x - r) (x + r) ≤ latticeEnergy f (x - 2 * r) (x + 2 * r) := by
    refine latticeEnergy_mono f ?_ ?_ <;> [skip; skip] <;>
      · have : (0:ℤ) ≤ (r:ℤ) := Int.natCast_nonneg r
        omega
  have hr0 : (0:ℝ) ≤ 3 * (r:ℝ) ^ 2 := by positivity
  nlinarith

end BakryEmery