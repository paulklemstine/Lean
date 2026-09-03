import Mathlib

/-!
# The discrete spread bound: `m` distinct integers cannot huddle (T-DIAL-56, paper 178)

This is the second ingredient of the tie-block ceiling of
`Shared.TieBlockRankCeiling`.  A rank vector is *integer valued and injective*.
The ceiling theorem says the correlation loss caused by a tie block equals the
within-block sum of squares of the predictor; to turn that into a *number* one
needs a lower bound for the within-block sum of squares of a rank vector, i.e.
the statement that `m` distinct integers are least spread out when they are
consecutive.

Main results.

* `sum_pairwise_sq` — the pairwise expansion
  `∑ᵢ∑ⱼ (xᵢ - xⱼ)² = 2·m·∑ xᵢ² - 2·(∑ xᵢ)²`, the algebraic identity behind
  "variance = mean pairwise squared distance".
* `gap_ge_of_strictMono` — a strictly monotone `Fin m → ℤ` grows at least as fast
  as the identity: `f b - f a ≥ b - a`.  Proved by reducing monotonicity of
  `a ↦ f a - a` to successive steps.
* `sum_pairwise_fin` — the model computation `∑ₐ∑_b (a - b)² = m(m³ - m)/6`.
* `spread_ge_of_injOn` — **the discrete spread bound**: for `r` injective on a
  finset `s` of size `m` with integer values,
  `∑_{i∈s} (rᵢ - mean)² ≥ (m³ - m)/12`, with equality for consecutive integers.
* `spread_eq_of_ranks` — the equality case: the full rank vector `1, …, n` has
  spread exactly `(n³ - n)/12`, so the bound is sharp and the ratio appearing in
  the ceiling theorem is exactly `(m³ - m)/(n³ - n)`.
-/

namespace TieCeiling

open Finset

/-! ## The pairwise expansion of the variance -/

/-- `∑ᵢ∑ⱼ (xᵢ - xⱼ)² = 2·|s|·∑ xᵢ² - 2·(∑ xᵢ)²`. -/
lemma sum_pairwise_sq {ι : Type*} (s : Finset ι) (x : ι → ℝ) :
    ∑ i ∈ s, ∑ j ∈ s, (x i - x j) ^ 2
      = 2 * s.card * (∑ i ∈ s, (x i) ^ 2) - 2 * (∑ i ∈ s, x i) ^ 2 := by
  have hinner : ∀ i ∈ s, ∑ j ∈ s, (x i - x j) ^ 2
      = s.card * (x i) ^ 2 - 2 * x i * (∑ j ∈ s, x j) + ∑ j ∈ s, (x j) ^ 2 := by
    intro i _
    have h : ∀ j, (x i - x j) ^ 2 = (x i) ^ 2 - 2 * x i * x j + (x j) ^ 2 := fun j => by ring
    rw [Finset.sum_congr rfl (fun j _ => h j), Finset.sum_add_distrib, Finset.sum_sub_distrib,
      Finset.sum_const, ← Finset.mul_sum, nsmul_eq_mul]
  rw [Finset.sum_congr rfl hinner, Finset.sum_add_distrib, Finset.sum_sub_distrib]
  have e1 : ∑ i ∈ s, (s.card : ℝ) * (x i) ^ 2 = s.card * ∑ i ∈ s, (x i) ^ 2 := by
    rw [Finset.mul_sum]
  have e2 : ∑ i ∈ s, 2 * x i * (∑ j ∈ s, x j) = 2 * (∑ i ∈ s, x i) * (∑ j ∈ s, x j) := by
    rw [← Finset.sum_mul, ← Finset.mul_sum]
  have e3 : ∑ _i ∈ s, (∑ j ∈ s, (x j) ^ 2) = s.card * ∑ j ∈ s, (x j) ^ 2 := by
    rw [Finset.sum_const, nsmul_eq_mul]
  rw [e1, e2, e3]; ring

/-- Centred form: `2·|s|·∑ (xᵢ - x̄)² = ∑ᵢ∑ⱼ (xᵢ - xⱼ)²`. -/
lemma two_card_mul_spread {ι : Type*} (s : Finset ι) (x : ι → ℝ) :
    2 * s.card * (∑ i ∈ s, (x i - (∑ j ∈ s, x j) / s.card) ^ 2)
      = ∑ i ∈ s, ∑ j ∈ s, (x i - x j) ^ 2 := by
  rcases Nat.eq_zero_or_pos s.card with h | h
  · rw [Finset.card_eq_zero.1 h]; simp
  have hc : ((s.card : ℝ)) ≠ 0 := Nat.cast_ne_zero.2 (by omega)
  set S := ∑ j ∈ s, x j with hS
  have hexp : ∀ i ∈ s, (x i - S / s.card) ^ 2
      = (x i) ^ 2 - 2 * (S / s.card) * x i + (S / s.card) ^ 2 := fun i _ => by ring
  rw [Finset.sum_congr rfl hexp, Finset.sum_add_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, Finset.sum_const, nsmul_eq_mul, sum_pairwise_sq, ← hS]
  field_simp
  ring

/-! ## Strictly monotone integer sequences spread out at least linearly -/

/-- A strictly monotone map `Fin m → ℤ` increases at least as fast as the identity. -/
lemma gap_ge_of_strictMono {m : ℕ} (f : Fin m → ℤ) (hf : StrictMono f) :
    ∀ a b : Fin m, a ≤ b → (b : ℤ) - (a : ℤ) ≤ f b - f a := by
  cases m with
  | zero => intro a; exact absurd a.2 (by omega)
  | succ n =>
    have hG : Monotone (fun a : Fin (n + 1) => f a - (a : ℤ)) := by
      rw [Fin.monotone_iff_le_succ]
      intro i
      have h1 : f i.castSucc < f i.succ := hf (by simp)
      have h2 : ((i.castSucc : Fin (n + 1)) : ℤ) = (i : ℤ) := by simp
      have h3 : ((i.succ : Fin (n + 1)) : ℤ) = (i : ℤ) + 1 := by simp
      simp only [h2, h3]
      omega
    intro a b hab
    have h := hG hab
    simp only at h
    omega

/-- Squared-distance domination: a strictly monotone integer sequence separates
its terms at least as much as the index sequence does. -/
lemma sq_dist_le_of_strictMono {m : ℕ} (f : Fin m → ℤ) (hf : StrictMono f) (a b : Fin m) :
    ((a : ℝ) - (b : ℝ)) ^ 2 ≤ ((f a : ℝ) - (f b : ℝ)) ^ 2 := by
  have key : ((a : ℤ) - (b : ℤ)) ^ 2 ≤ (f a - f b) ^ 2 := by
    rcases le_total a b with h | h
    · have hg := gap_ge_of_strictMono f hf a b h
      have h0 : (0 : ℤ) ≤ (b : ℤ) - (a : ℤ) := by
        have : (a : ℕ) ≤ (b : ℕ) := h
        omega
      nlinarith
    · have hg := gap_ge_of_strictMono f hf b a h
      have h0 : (0 : ℤ) ≤ (a : ℤ) - (b : ℤ) := by
        have : (b : ℕ) ≤ (a : ℕ) := h
        omega
      nlinarith
  have h2 := (Int.cast_le (R := ℝ)).2 key
  push_cast at h2
  exact h2

/-! ## The model computation -/

lemma sum_range_id_real (m : ℕ) : ∑ k ∈ Finset.range m, (k : ℝ) = m * (m - 1) / 2 := by
  induction m with
  | zero => simp
  | succ n ih => rw [Finset.sum_range_succ, ih]; push_cast; ring

lemma sum_range_sq_real (m : ℕ) :
    ∑ k ∈ Finset.range m, (k : ℝ) ^ 2 = m * (m - 1) * (2 * m - 1) / 6 := by
  induction m with
  | zero => simp
  | succ n ih => rw [Finset.sum_range_succ, ih]; push_cast; ring

/-- The consecutive-integers configuration: `∑ₐ∑_b (a - b)² = m(m³ - m)/6`. -/
lemma sum_pairwise_fin (m : ℕ) :
    ∑ a : Fin m, ∑ b : Fin m, ((a : ℝ) - (b : ℝ)) ^ 2 = m * ((m : ℝ) ^ 3 - m) / 6 := by
  have h := sum_pairwise_sq (Finset.univ : Finset (Fin m)) (fun a : Fin m => (a : ℝ))
  rw [h]
  have h1 : ∑ a : Fin m, ((a : ℕ) : ℝ) = m * (m - 1) / 2 := by
    rw [Fin.sum_univ_eq_sum_range (fun k => (k : ℝ))]; exact sum_range_id_real m
  have h2 : ∑ a : Fin m, ((a : ℕ) : ℝ) ^ 2 = m * (m - 1) * (2 * m - 1) / 6 := by
    rw [Fin.sum_univ_eq_sum_range (fun k => (k : ℝ) ^ 2)]; exact sum_range_sq_real m
  simp only [Finset.card_univ, Fintype.card_fin]
  rw [h1, h2]
  ring

/-! ## The discrete spread bound -/

/-- Transfer a sum over a finset of integers to a sum over `Fin m` along the
order isomorphism given by sorting. -/
lemma sum_eq_sum_orderIso (T : Finset ℤ) {m : ℕ} (hm : T.card = m) (h : ℤ → ℝ) :
    ∑ y ∈ T, h y = ∑ a : Fin m, h ((T.orderIsoOfFin hm a : T) : ℤ) := by
  rw [← Finset.sum_coe_sort T h]
  exact (Equiv.sum_comp (T.orderIsoOfFin hm).toEquiv (fun y : T => h (y : ℤ))).symm

/-- **The discrete spread bound.**  If `r` takes `|s|` distinct integer values on
`s`, its sum of squared deviations from its own mean is at least `(m³ - m)/12`,
where `m = |s|`.  Equality holds exactly for consecutive integers, so this is the
sharp "rank vectors cannot huddle" inequality. -/
theorem spread_ge_of_injOn {ι : Type*} (s : Finset ι) (r : ι → ℤ) (hinj : Set.InjOn r s) :
    (((s.card : ℝ)) ^ 3 - s.card) / 12
      ≤ ∑ i ∈ s, ((r i : ℝ) - (∑ j ∈ s, (r j : ℝ)) / s.card) ^ 2 := by
  classical
  rcases Finset.eq_empty_or_nonempty s with rfl | hne
  · simp
  set m := s.card with hm
  have h0 : 0 < m := by rw [hm]; exact Finset.card_pos.2 hne
  -- the image is a finset of `m` integers
  set T : Finset ℤ := s.image r with hT
  have hTcard : T.card = m := by rw [hT, Finset.card_image_of_injOn hinj]
  -- the sorted enumeration
  set f : Fin m → ℤ := fun a => ((T.orderIsoOfFin hTcard a : T) : ℤ) with hf
  have hfmono : StrictMono f := fun a b hab => by
    exact_mod_cast (T.orderIsoOfFin hTcard).strictMono hab
  -- pairwise sum over `Fin m` equals pairwise sum over `s`
  have himg : ∀ g : ℤ → ℝ, ∑ a : Fin m, g (f a) = ∑ i ∈ s, g (r i) := by
    intro g
    rw [← sum_eq_sum_orderIso T hTcard g, hT]
    exact Finset.sum_image fun x hx y hy hxy => hinj hx hy hxy
  have hpair : ∑ a : Fin m, ∑ b : Fin m, ((f a : ℝ) - (f b : ℝ)) ^ 2
      = ∑ i ∈ s, ∑ j ∈ s, ((r i : ℝ) - (r j : ℝ)) ^ 2 := by
    rw [himg (fun y => ∑ b : Fin m, ((y : ℝ) - (f b : ℝ)) ^ 2)]
    exact Finset.sum_congr rfl fun i _ => himg (fun z => ((r i : ℝ) - (z : ℝ)) ^ 2)
  -- domination by the consecutive-integer model
  have hdom : ∑ a : Fin m, ∑ b : Fin m, ((a : ℝ) - (b : ℝ)) ^ 2
      ≤ ∑ a : Fin m, ∑ b : Fin m, ((f a : ℝ) - (f b : ℝ)) ^ 2 :=
    Finset.sum_le_sum fun a _ => Finset.sum_le_sum fun b _ => sq_dist_le_of_strictMono f hfmono a b
  rw [sum_pairwise_fin m, hpair] at hdom
  have hkey := two_card_mul_spread s (fun i => (r i : ℝ))
  simp only [← hm] at hkey
  have hmpos : (0 : ℝ) < m := by exact_mod_cast h0
  nlinarith [hkey, hdom, hmpos]

/-- Sharpness: the full rank vector `0, 1, …, n-1` (equivalently `1, …, n`) has
spread exactly `(n³ - n)/12`.  Hence the loss ratio in the ceiling theorem is
exactly `(m³ - m)/(n³ - n)`. -/
theorem spread_eq_of_ranks (n : ℕ) :
    ∑ a : Fin n, ((a : ℝ) - (∑ b : Fin n, (b : ℝ)) / n) ^ 2 = ((n : ℝ) ^ 3 - n) / 12 := by
  rcases Nat.eq_zero_or_pos n with h | h
  · subst h; simp
  have hn : ((n : ℝ)) ≠ 0 := Nat.cast_ne_zero.2 (by omega)
  have hkey := two_card_mul_spread (Finset.univ : Finset (Fin n)) (fun a : Fin n => (a : ℝ))
  rw [sum_pairwise_fin n] at hkey
  simp only [Finset.card_univ, Fintype.card_fin] at hkey
  field_simp at hkey ⊢
  linarith [hkey]

end TieCeiling