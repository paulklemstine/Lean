/-
# Hales–Jewett Theorem: Low-Dimensional Cases and Monotonicity

This module proves:
* `HJProp_monotone_dim` — if `HJProp k r n`, then `HJProp k r (n + 1)` (for k ≥ 1)
* `hales_jewett_2_2` — every 2-coloring of `[2]^2` has a monochromatic combinatorial line
* `HJProp_2_2_2` — `HJProp 2 2 2`
-/
import Mathlib
import Algebra.Ramsey.Defs

/-! ## Dimension monotonicity -/

/-- A combinatorial line in dimension `n` can be lifted to dimension `n+1`
    by making the last coordinate inactive with an arbitrary base value. -/
def CombinatorialLine.liftDim (L : CombinatorialLine n k) (c : Fin k) :
    CombinatorialLine (n + 1) k where
  active i := if h : i.val < n then L.active ⟨i.val, h⟩ else false
  nontrivial := by
    obtain ⟨i, hi⟩ := L.nontrivial
    exact ⟨⟨i.val, by omega⟩, by simp [i.isLt, hi]⟩
  base i := if h : i.val < n then L.base ⟨i.val, h⟩ else c

/-- Extension of a word from `Fin n → Fin k` to `Fin (n+1) → Fin k`
    by appending a value `c` at coordinate `n`. -/
def extendWord (w : Fin n → Fin k) (c : Fin k) : Fin (n + 1) → Fin k :=
  fun i => if h : i.val < n then w ⟨i.val, h⟩ else c

/-- The lifted line's point equals the extension of the original point. -/
theorem liftDim_point_eq (L : CombinatorialLine n k) (c : Fin k) (a : Fin k) :
    (L.liftDim c).point a = extendWord (L.point a) c := by
  ext i
  simp only [CombinatorialLine.liftDim, CombinatorialLine.point, extendWord]
  split_ifs with h1 h2 h3 <;> simp_all

/-- **Dimension monotonicity**: if every `r`-coloring of `[k]^n` contains a
    monochromatic combinatorial line, then so does every `r`-coloring of `[k]^(n+1)`.
    Requires `k ≥ 1` (the alphabet must be nonempty). -/
theorem HJProp_monotone_dim {k r n : ℕ} (hk : 0 < k) (h : HJProp k r n) :
    HJProp k r (n + 1) := by
  intro c
  set c0 : Fin k := ⟨0, hk⟩
  set c' : (Fin n → Fin k) → Fin r := fun w => c (extendWord w c0)
  obtain ⟨L, hL⟩ := h c'
  exact ⟨L.liftDim c0, fun a b => by rw [liftDim_point_eq, liftDim_point_eq]; exact hL a b⟩

/-! ## HJ(2, 2) = 2: the first nontrivial Hales–Jewett number -/

/-
**Every 2-coloring of `[2]^2` has a monochromatic combinatorial line.**
-/
theorem hales_jewett_2_2 :
    ∀ c : (Fin 2 → Fin 2) → Fin 2,
      ∃ L : CombinatorialLine 2 2,
        ∀ a b : Fin 2, c (L.point a) = c (L.point b) := by
          by_contra! h_contra;
          obtain ⟨ c, hc ⟩ := h_contra;
          have h_cases : ∀ (c : (Fin 2 → Fin 2) → Fin 2), ∃ L : Fin 2 → Bool, ∃ b : Fin 2 → Fin 2, (∃ i, L i = true) ∧ ∀ a b' : Fin 2, c (fun i => if L i then a else b i) = c (fun i => if L i then b' else b i) := by
            native_decide +revert;
          obtain ⟨ L, b, hL, hb ⟩ := h_cases c;
          exact absurd ( hc ⟨ L, hL, b ⟩ ) ( by push_neg; tauto )

/-- The Hales–Jewett property HJProp 2 2 2 holds. -/
theorem HJProp_2_2_2 : HJProp 2 2 2 := hales_jewett_2_2