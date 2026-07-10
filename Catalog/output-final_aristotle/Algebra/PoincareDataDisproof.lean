import Mathlib

/-!
# A disproof: the Poincaré-for-data threshold is *not* an exact power law

The informal conjecture asserts a clean equality for the detection threshold,

  `ε_⋆(n) = C · d^{1/2} · n^{-1/d}`   for some universal constant `C`.

We refute the *equality* (as opposed to the correct `≳`/`≍` scaling) already in the
one-dimensional model `d = 1`. There the minimal Chebyshev covering radius of the
`m`-point cube using `n` samples is a genuine **step function** of `n`: it is *constant*
on ranges of `n`, whereas any `C · n^{-1}` law is strictly decreasing and injective.

Concretely, for `m = 7`:

* covering by radius `1` is possible with `3` samples and impossible with radius `0`
  unless one uses all `7` points, so the minimal radius for `n = 3` samples is `1`;
* the same holds for `n = 4`.

Hence `minRad 7 3 = minRad 7 4 = 1` while `3 ≠ 4`. A law `ε_⋆(n) = C/n` would force
`C/3 = C/4`, i.e. `C = 0`, contradicting `C > 0`. So **no positive constant reproduces
the threshold exactly** — the conjecture holds only up to constants, as a scaling law.
-/

open Finset

namespace PoincareData

/-- `coverable m n r`: the `m`-point 1-D cube can be `r`-covered (in the Chebyshev metric)
using at most `n` samples. -/
def coverable (m n r : ℕ) : Prop :=
  ∃ S : Finset (Fin m), S.card ≤ n ∧
    ∀ x : Fin m, ∃ s ∈ S, ((x : ℤ) - (s : ℤ)).natAbs ≤ r

instance (m n r : ℕ) : Decidable (coverable m n r) := by
  unfold coverable; infer_instance

/-- The minimal Chebyshev covering radius of the `m`-point cube using `≤ n` samples. -/
noncomputable def minRad (m n : ℕ) : ℕ := sInf {r | coverable m n r}

/-- Radius `1` suffices to cover the 7-point cube with 3 samples (centers `{1,3,5}`). -/
lemma coverable_7_3_1 : coverable 7 3 1 :=
  ⟨{1, 3, 5}, by decide, by decide⟩

/-- Radius `0` cannot cover the 7-point cube with only 3 samples. -/
lemma not_coverable_7_3_0 : ¬ coverable 7 3 0 := by
  rintro ⟨S, hcard, hcov⟩
  have huniv : (Finset.univ : Finset (Fin 7)) ⊆ S := by
    intro x _
    obtain ⟨s, hs, h⟩ := hcov x
    have hxs : x = s := by
      have h0 : ((x : ℤ) - (s : ℤ)).natAbs = 0 := Nat.le_zero.mp h
      have : (x : ℤ) = (s : ℤ) := by
        have := Int.natAbs_eq_zero.mp h0
        omega
      exact Fin.ext (by exact_mod_cast this)
    rwa [hxs]
  have : (7 : ℕ) ≤ S.card := by simpa using Finset.card_le_card huniv
  omega

/-- Radius `1` suffices to cover the 7-point cube with 4 samples. -/
lemma coverable_7_4_1 : coverable 7 4 1 :=
  ⟨{1, 3, 5}, by decide, by decide⟩

/-- Radius `0` cannot cover the 7-point cube with only 4 samples. -/
lemma not_coverable_7_4_0 : ¬ coverable 7 4 0 := by
  rintro ⟨S, hcard, hcov⟩
  have huniv : (Finset.univ : Finset (Fin 7)) ⊆ S := by
    intro x _
    obtain ⟨s, hs, h⟩ := hcov x
    have hxs : x = s := by
      have h0 : ((x : ℤ) - (s : ℤ)).natAbs = 0 := Nat.le_zero.mp h
      have : (x : ℤ) = (s : ℤ) := by
        have := Int.natAbs_eq_zero.mp h0
        omega
      exact Fin.ext (by exact_mod_cast this)
    rwa [hxs]
  have : (7 : ℕ) ≤ S.card := by simpa using Finset.card_le_card huniv
  omega

/-
The minimal covering radius for `n = 3` samples on the 7-cube is exactly `1`.
-/
lemma minRad_7_3 : minRad 7 3 = 1 := by
  refine' le_antisymm _ _;
  · exact Nat.sInf_le coverable_7_3_1;
  · exact le_csInf ⟨ 1, by exact PoincareData.coverable_7_3_1 ⟩ fun x hx => Nat.pos_of_ne_zero fun h => PoincareData.not_coverable_7_3_0 <| h ▸ hx

/-
The minimal covering radius for `n = 4` samples on the 7-cube is exactly `1`.
-/
lemma minRad_7_4 : minRad 7 4 = 1 := by
  refine' le_antisymm _ _;
  · exact Nat.sInf_le coverable_7_4_1;
  · refine' le_csInf _ _;
    · exact ⟨ 1, coverable_7_4_1 ⟩;
    · exact fun n hn => Nat.pos_of_ne_zero fun h => not_coverable_7_4_0 <| h ▸ hn

/-
**Step function.** The minimal covering radius is constant across `n = 3` and `n = 4`,
even though the sample counts differ.
-/
theorem minRad_step : minRad 7 3 = minRad 7 4 ∧ (3 : ℕ) ≠ 4 := by
  simp [minRad_7_3, minRad_7_4]

/-
**Disproof of the exact power law.** No positive constant `C` makes the minimal
covering radius equal to `C / n` for both `n = 3` and `n = 4` on the 7-cube.
-/
theorem no_exact_inverse_power_law :
    ¬ ∃ C : ℝ, 0 < C ∧ (minRad 7 3 : ℝ) = C / 3 ∧ (minRad 7 4 : ℝ) = C / 4 := by
  rw [ minRad_7_3, minRad_7_4 ] ; norm_num ; intros ; linarith;

end PoincareData