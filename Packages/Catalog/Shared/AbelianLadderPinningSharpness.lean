/-
# Sharpness of the pinning law: sufficiency is exactly measurability

`Shared.AbelianLadderUniversality` shows that the Artin class always pins the
splitting type.  The natural adversarial question is whether the observed
identity `I(class ; T) = H(T)` is *evidence* for anything, or an artefact.  This
file answers it by proving the exact criterion behind pinning and then exhibiting
concrete degree-11 channels on both sides of it.

* `uEnt_pos_of_nonconstant` — a counting entropy is strictly positive as soon as
  the read-out is non-constant (the quantitative core).
* `condEnt_eq_zero_iff_determines` — **pinning holds if and only if the side
  channel determines the type**: `H(T | k) = 0` exactly when `k` is a sufficient
  statistic in the naive, pointwise sense.  So the reported `I = H(T)` is a
  genuine dichotomy, not a numerical coincidence.
* `pinning_iff_deg11` — the criterion at degree 11.
* `legendre_pinning_fails` — a *failing* channel at degree 11: the quadratic
  character mod 23 merges the split class `1` with the inert class `2`
  (`5² = 2` mod 23, so `2` is a square), hence loses information strictly.
  This is the arithmetic incarnation of the zero-information theorem
  `quadratic_character_carries_no_information`.
-/
import Shared.AbelianLadderUniversality

namespace AbelianLadder

open Finset CyclicTypeChannel

/-! ## 1. Strict positivity of a non-degenerate counting entropy -/

/-- **A non-constant read-out has strictly positive entropy.**  Every fibre omits
a point, so the average fibre log is at most `log₂ (|s| - 1) < log₂ |s|`. -/
theorem uEnt_pos_of_nonconstant {α β : Type*} [DecidableEq β] {s : Finset α} {g : α → β}
    {x y : α} (hx : x ∈ s) (hy : y ∈ s) (hxy : g x ≠ g y) : 0 < uEnt s g := by
  classical
  have hne : x ≠ y := fun h => hxy (by rw [h])
  have hN2 : 2 ≤ s.card := Finset.one_lt_card.2 ⟨x, hx, y, hy, hne⟩
  have hN0 : (0 : ℝ) < s.card := by
    have : (0 : ℕ) < s.card := by omega
    exact_mod_cast this
  have hM0 : (0 : ℝ) < (s.card : ℝ) - 1 := by
    have : (2 : ℝ) ≤ s.card := by exact_mod_cast hN2
    linarith
  -- every fibre misses one of the two witnesses
  have hfib : ∀ a ∈ s, (#{z ∈ s | g z = g a}) ≤ s.card - 1 := by
    intro a ha
    by_cases hax : g a = g x
    · have hsub : {z ∈ s | g z = g a} ⊆ s.erase y := by
        intro z hz
        simp only [mem_filter] at hz
        refine Finset.mem_erase.2 ⟨?_, hz.1⟩
        rintro rfl
        exact hxy (by rw [← hax, ← hz.2])
      calc (#{z ∈ s | g z = g a}) ≤ (s.erase y).card := Finset.card_le_card hsub
        _ = s.card - 1 := Finset.card_erase_of_mem hy
    · have hsub : {z ∈ s | g z = g a} ⊆ s.erase x := by
        intro z hz
        simp only [mem_filter] at hz
        refine Finset.mem_erase.2 ⟨?_, hz.1⟩
        rintro rfl
        exact hax hz.2.symm
      calc (#{z ∈ s | g z = g a}) ≤ (s.erase x).card := Finset.card_le_card hsub
        _ = s.card - 1 := Finset.card_erase_of_mem hx
  have hterm : ∀ a ∈ s, Real.logb 2 (#{z ∈ s | g z = g a} : ℝ)
      ≤ Real.logb 2 ((s.card : ℝ) - 1) := by
    intro a ha
    have hle : ((#{z ∈ s | g z = g a} : ℕ) : ℝ) ≤ (s.card : ℝ) - 1 := by
      have h := hfib a ha
      have : ((#{z ∈ s | g z = g a} : ℕ) : ℝ) ≤ ((s.card - 1 : ℕ) : ℝ) := by exact_mod_cast h
      rwa [Nat.cast_sub (by omega), Nat.cast_one] at this
    have hpos : (0 : ℝ) < (#{z ∈ s | g z = g a} : ℝ) := by
      exact_mod_cast fiber_card_pos ha
    exact Real.logb_le_logb_of_le (by norm_num) hpos hle
  have hsum : (∑ a ∈ s, Real.logb 2 (#{z ∈ s | g z = g a} : ℝ))
      ≤ (s.card : ℝ) * Real.logb 2 ((s.card : ℝ) - 1) := by
    calc (∑ a ∈ s, Real.logb 2 (#{z ∈ s | g z = g a} : ℝ))
        ≤ ∑ _a ∈ s, Real.logb 2 ((s.card : ℝ) - 1) := Finset.sum_le_sum hterm
      _ = (s.card : ℝ) * Real.logb 2 ((s.card : ℝ) - 1) := by
          simp [Finset.sum_const, nsmul_eq_mul]
  have hstrict : Real.logb 2 ((s.card : ℝ) - 1) < Real.logb 2 (s.card : ℝ) :=
    Real.logb_lt_logb (by norm_num) hM0 (by linarith)
  rw [uEnt]
  have hdiv : (∑ a ∈ s, Real.logb 2 (#{z ∈ s | g z = g a} : ℝ)) / s.card
      ≤ Real.logb 2 ((s.card : ℝ) - 1) := by
    rw [div_le_iff₀ hN0]
    linarith [hsum]
  linarith

/-- Conditional entropy is non-negative. -/
theorem condEnt_nonneg {α β γ : Type*} [DecidableEq β] [DecidableEq γ]
    (s : Finset α) (g : α → β) (k : α → γ) : 0 ≤ condEnt s g k :=
  Finset.sum_nonneg fun c _ => mul_nonneg (by positivity) (uEnt_nonneg _ _)

/-! ## 2. Pinning is exactly measurability -/

/-- **The pinning criterion.**  The conditional entropy of the type given a side
channel vanishes *if and only if* the side channel determines the type.  Hence an
observed identity `I(k ; T) = H(T)` is equivalent to the exact structural
statement "`T` factors through `k`". -/
theorem condEnt_eq_zero_iff_determines {α β γ : Type*} [DecidableEq β] [DecidableEq γ]
    {s : Finset α} {g : α → β} {k : α → γ} :
    condEnt s g k = 0 ↔ ∀ x ∈ s, ∀ y ∈ s, k x = k y → g x = g y := by
  classical
  refine ⟨fun h x hx y hy hxy => ?_, condEnt_eq_zero_of_determines⟩
  by_contra hgxy
  have hmem : k x ∈ s.image k := mem_image.2 ⟨x, hx, rfl⟩
  have hxfib : x ∈ {z ∈ s | k z = k x} := by simp [hx]
  have hyfib : y ∈ {z ∈ s | k z = k x} := by simp [hy, hxy.symm]
  have hpos : 0 < uEnt {z ∈ s | k z = k x} g := uEnt_pos_of_nonconstant hxfib hyfib hgxy
  have hcardpos : (0 : ℝ) < (#{z ∈ s | k z = k x} : ℝ) / s.card := by
    have h1 : (0 : ℕ) < #{z ∈ s | k z = k x} := card_pos.2 ⟨x, hxfib⟩
    have h2 : (0 : ℕ) < s.card := card_pos.2 ⟨x, hx⟩
    have h1' : (0 : ℝ) < (#{z ∈ s | k z = k x} : ℝ) := by exact_mod_cast h1
    have h2' : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast h2
    positivity
  have hterm : 0 < ((#{z ∈ s | k z = k x} : ℝ) / s.card) * uEnt {z ∈ s | k z = k x} g :=
    mul_pos hcardpos hpos
  have hnonneg : ∀ c ∈ s.image k,
      0 ≤ ((#{z ∈ s | k z = c} : ℝ) / s.card) * uEnt {z ∈ s | k z = c} g := by
    intro c _
    have h1 : (0 : ℝ) ≤ (#{z ∈ s | k z = c} : ℝ) / s.card := by positivity
    exact mul_nonneg h1 (uEnt_nonneg _ _)
  have hle : ((#{z ∈ s | k z = k x} : ℝ) / s.card) * uEnt {z ∈ s | k z = k x} g
      ≤ condEnt s g k := Finset.single_le_sum hnonneg hmem
  rw [h] at hle
  linarith

/-! ## 3. The criterion at degree 11 -/

/-- **Exact pinning criterion for `Q(ζ₂₃)⁺`.**  A channel `k` on the residues mod
`23` attains the full type entropy precisely when it never merges a split class
with an inert one. -/
theorem pinning_iff_deg11 {γ : Type*} [DecidableEq γ] (k : (ZMod 23)ˣ → γ) :
    mutInfo (univ : Finset (ZMod 23)ˣ) (realDeg 23) k = typeEntropy 11 ↔
      ∀ u v, k u = k v → realDeg 23 u = realDeg 23 v := by
  rw [mutInfo, uEnt_realDeg_23_eq_typeEntropy]
  constructor
  · intro h u v huv
    have hz : condEnt (univ : Finset (ZMod 23)ˣ) (realDeg 23) k = 0 := by linarith
    exact condEnt_eq_zero_iff_determines.1 hz u (mem_univ u) v (mem_univ v) huv
  · intro h
    have hz : condEnt (univ : Finset (ZMod 23)ˣ) (realDeg 23) k = 0 :=
      condEnt_eq_zero_iff_determines.2 fun x _ y _ hxy => h x y hxy
    rw [hz, sub_zero]

/-- **A strictly lossy channel at degree 11.**  Any channel merging the split
class `1` with an inert class carries strictly less than `H(T)`. -/
theorem pinning_fails_of_merge {γ : Type*} [DecidableEq γ] (k : (ZMod 23)ˣ → γ)
    {u : (ZMod 23)ˣ} (hu : realDeg 23 u = 11) (hk : k u = k 1) :
    mutInfo (univ : Finset (ZMod 23)ˣ) (realDeg 23) k < typeEntropy 11 := by
  have hone : realDeg 23 (1 : (ZMod 23)ˣ) = 1 := realDeg_eq_one_iff.2 (Or.inl rfl)
  have hne : realDeg 23 u ≠ realDeg 23 1 := by rw [hu, hone]; norm_num
  have hnz : condEnt (univ : Finset (ZMod 23)ˣ) (realDeg 23) k ≠ 0 := by
    intro h
    exact hne (condEnt_eq_zero_iff_determines.1 h u (mem_univ u) 1 (mem_univ 1) hk)
  have hpos : 0 < condEnt (univ : Finset (ZMod 23)ˣ) (realDeg 23) k := by
    rcases lt_or_eq_of_le (condEnt_nonneg (univ : Finset (ZMod 23)ˣ) (realDeg 23) k) with h | h
    · exact h
    · exact absurd h.symm hnz
  rw [mutInfo, uEnt_realDeg_23_eq_typeEntropy]
  linarith

/-! ## 4. The quadratic character really is lossy at degree 11 -/

/-- The quadratic-residue channel on `(Z/23)ˣ`. -/
def isSq23 (u : (ZMod 23)ˣ) : Prop := ∃ w : (ZMod 23)ˣ, w * w = u

instance : DecidablePred isSq23 :=
  fun u => decidable_of_iff (∃ w : (ZMod 23)ˣ, w * w = u) Iff.rfl

/-- `2` is a square mod `23` (namely `5² = 2`) yet is inert in `Q(ζ₂₃)⁺`. -/
theorem two_isSq23 (h : Nat.Coprime 2 23 := by decide) :
    isSq23 (ZMod.unitOfCoprime 2 h) := by
  refine ⟨ZMod.unitOfCoprime 5 (by decide), Units.ext ?_⟩
  push_cast [ZMod.coe_unitOfCoprime]
  decide

/-- **The Legendre channel loses information at degree 11.**  Because `2` is a
quadratic residue mod `23` but is inert in `Q(ζ₂₃)⁺`, the quadratic character
merges a split class with an inert class and therefore carries strictly less
than the full type entropy — the arithmetic form of
`quadratic_character_carries_no_information`. -/
theorem legendre_pinning_fails (h : Nat.Coprime 2 23 := by decide) :
    mutInfo (univ : Finset (ZMod 23)ˣ) (realDeg 23)
        (fun u => decide (isSq23 u)) < typeEntropy 11 := by
  refine pinning_fails_of_merge _ (realDeg_23_two h) ?_
  have h1 : isSq23 (1 : (ZMod 23)ˣ) := ⟨1, by simp⟩
  simp [two_isSq23 h, h1]

end AbelianLadder