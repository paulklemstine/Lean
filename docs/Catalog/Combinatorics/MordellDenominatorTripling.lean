import Mathlib

/-!
# Layer 3: the tripling criterion on the Mordell curve `E_N : y² = x³ + N`

The denominator study of the Mordell curve proceeds layer by layer: for a rational point
`P = (x, y)` the primes dividing the denominator of `x(2P)` are governed by the criterion
`ℓ ∣ y`, i.e. `ℓ ∣ x³ + N` (layer 2), and those dividing the denominator of `x(3P)` are
governed by the third division polynomial

  `ψ₃(x) = 3x⁴ + 12 N x = 3x (x³ + 4N)`

(layer 3), which is the specialisation to `a = 0`, `b = N` of the general
`ψ₃ = 3x⁴ + 6a x² + 12b x - a²`.

This file isolates the *local* content of layer 3, which is all the barrier argument of
`Combinatorics.MordellDenominatorBarrier` uses:

* `psi3`, `psi3_factor` — the polynomial and its factorisation;
* `vanishingClasses`, `vanishingClasses3` — the residue classes mod a prime `ℓ` at which
  the layer-2 and layer-3 criteria fire, with their membership characterisations;
* `dvd_layer2_iff_mem`, `dvd_psi3_iff_mem` — the bridge between the integral criteria and
  the residue classes: both criteria depend on `x` only through `x mod ℓ`;
* `mem_vanishingClasses3_iff_zero_or_cube` — away from characteristic `3` the layer-3
  classes are exactly `0` together with the cube roots of `-4N`, so
  `card_vanishingClasses3_le` : there are at most four of them, and
  `zero_mem_vanishingClasses3` : the class `0` always fires;
* `vanishingClasses_dependsOn_mod`, `vanishingClasses3_dependsOn_mod` — both class sets
  depend on `N` only through `N mod ℓ`, which is the observation the information barrier
  turns into an obstruction.
-/


namespace MordellDenominators

open Finset

/-- The third division polynomial of the Mordell curve `E_N : y² = x³ + N`. -/
def psi3 (N x : ℤ) : ℤ := 3 * x ^ 4 + 12 * N * x

theorem psi3_factor (N x : ℤ) : psi3 N x = 3 * x * (x ^ 3 + 4 * N) := by
  rw [psi3]; ring

@[simp] theorem psi3_zero (N : ℤ) : psi3 N 0 = 0 := by simp [psi3]

/-- The residue classes mod `ℓ` at which the **layer-2** criterion `ℓ ∣ x³ + N` fires. -/
def vanishingClasses (N : ℤ) (ℓ : ℕ) [Fact ℓ.Prime] : Finset (ZMod ℓ) :=
  Finset.univ.filter fun t => t ^ 3 + (N : ZMod ℓ) = 0

theorem mem_vanishingClasses_iff {N : ℤ} {ℓ : ℕ} [Fact ℓ.Prime] {t : ZMod ℓ} :
    t ∈ vanishingClasses N ℓ ↔ t ^ 3 + (N : ZMod ℓ) = 0 := by
  classical
  simp [vanishingClasses]

/-- The residue classes mod `ℓ` at which the **layer-3** criterion `ℓ ∣ ψ₃(x)` fires. -/
def vanishingClasses3 (N : ℤ) (ℓ : ℕ) [Fact ℓ.Prime] : Finset (ZMod ℓ) :=
  Finset.univ.filter fun t => 3 * t ^ 4 + 12 * (N : ZMod ℓ) * t = 0

theorem mem_vanishingClasses3_iff {N : ℤ} {ℓ : ℕ} [Fact ℓ.Prime] {t : ZMod ℓ} :
    t ∈ vanishingClasses3 N ℓ ↔ 3 * t ^ 4 + 12 * (N : ZMod ℓ) * t = 0 := by
  classical
  simp [vanishingClasses3]

theorem intCast_psi3 {ℓ : ℕ} [Fact ℓ.Prime] (N x : ℤ) :
    ((psi3 N x : ℤ) : ZMod ℓ) = 3 * (x : ZMod ℓ) ^ 4 + 12 * (N : ZMod ℓ) * (x : ZMod ℓ) := by
  simp [psi3]

/-- The layer-2 criterion is a condition on `x mod ℓ`. -/
theorem dvd_layer2_iff_mem {N x : ℤ} {ℓ : ℕ} [Fact ℓ.Prime] :
    (ℓ : ℤ) ∣ x ^ 3 + N ↔ ((x : ZMod ℓ)) ∈ vanishingClasses N ℓ := by
  rw [mem_vanishingClasses_iff, ← ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast
  rfl

/-- The layer-3 criterion is a condition on `x mod ℓ`. -/
theorem dvd_psi3_iff_mem {N x : ℤ} {ℓ : ℕ} [Fact ℓ.Prime] :
    (ℓ : ℤ) ∣ psi3 N x ↔ ((x : ZMod ℓ)) ∈ vanishingClasses3 N ℓ := by
  rw [mem_vanishingClasses3_iff, ← ZMod.intCast_zmod_eq_zero_iff_dvd, intCast_psi3]

/-- The class of the two-torsion-like point `x ≡ 0` always fires at layer 3. -/
theorem zero_mem_vanishingClasses3 (N : ℤ) (ℓ : ℕ) [Fact ℓ.Prime] :
    (0 : ZMod ℓ) ∈ vanishingClasses3 N ℓ := by
  rw [mem_vanishingClasses3_iff]; ring

theorem three_ne_zero_of_ne_three {ℓ : ℕ} [hl : Fact ℓ.Prime] (h3 : ℓ ≠ 3) :
    (3 : ZMod ℓ) ≠ 0 := by
  haveI : NeZero ℓ := ⟨hl.out.ne_zero⟩
  intro h
  have h' : ((3 : ℕ) : ZMod ℓ) = 0 := by exact_mod_cast h
  have hd : ℓ ∣ 3 := (ZMod.natCast_eq_zero_iff 3 ℓ).mp h'
  exact h3 ((Nat.prime_dvd_prime_iff_eq hl.out (by norm_num)).mp hd)

/-- **Structure of the layer-3 classes.**  Away from characteristic `3` the criterion
`ℓ ∣ ψ₃(x)` fires exactly at `x ≡ 0` and at the cube roots of `-4N`. -/
theorem mem_vanishingClasses3_iff_zero_or_cube {N : ℤ} {ℓ : ℕ} [Fact ℓ.Prime] (h3 : ℓ ≠ 3)
    {t : ZMod ℓ} : t ∈ vanishingClasses3 N ℓ ↔ (t = 0 ∨ t ^ 3 + 4 * (N : ZMod ℓ) = 0) := by
  have h3' : (3 : ZMod ℓ) ≠ 0 := three_ne_zero_of_ne_three h3
  rw [mem_vanishingClasses3_iff]
  constructor
  · intro h
    have hfac : 3 * t * (t ^ 3 + 4 * (N : ZMod ℓ)) = 0 := by rw [← h]; ring
    rcases mul_eq_zero.mp hfac with h1 | h2
    · rcases mul_eq_zero.mp h1 with h | h
      · exact absurd h h3'
      · exact Or.inl h
    · exact Or.inr h2
  · rintro (rfl | h)
    · ring
    · have hrw : 3 * t ^ 4 + 12 * (N : ZMod ℓ) * t = 3 * t * (t ^ 3 + 4 * (N : ZMod ℓ)) := by
        ring
      rw [hrw, h, mul_zero]

/-- The layer-2 classes are the roots of a cubic, hence at most three. -/
theorem card_vanishingClasses_le (N : ℤ) (ℓ : ℕ) [Fact ℓ.Prime] :
    (vanishingClasses N ℓ).card ≤ 3 := by
  classical
  have hsub : vanishingClasses N ℓ ⊆
      (Polynomial.X ^ 3 + Polynomial.C ((N : ZMod ℓ))).roots.toFinset := by
    intro t ht
    rw [mem_vanishingClasses_iff] at ht
    have hne : (Polynomial.X ^ 3 + Polynomial.C ((N : ZMod ℓ))) ≠ 0 :=
      Polynomial.X_pow_add_C_ne_zero (by norm_num) _
    simp only [Multiset.mem_toFinset, Polynomial.mem_roots hne, Polynomial.IsRoot.def]
    simpa using ht
  calc (vanishingClasses N ℓ).card
      ≤ (Polynomial.X ^ 3 + Polynomial.C ((N : ZMod ℓ))).roots.toFinset.card :=
        Finset.card_le_card hsub
    _ ≤ Multiset.card (Polynomial.X ^ 3 + Polynomial.C ((N : ZMod ℓ))).roots :=
        (Polynomial.X ^ 3 + Polynomial.C ((N : ZMod ℓ))).roots.toFinset_card_le
    _ ≤ (Polynomial.X ^ 3 + Polynomial.C ((N : ZMod ℓ))).natDegree :=
        Polynomial.card_roots' _
    _ = 3 := by
        rw [Polynomial.natDegree_X_pow_add_C]

/-- Away from characteristic `3` the layer-3 classes are at most four: the class `0` and
the cube roots of `-4N`. -/
theorem card_vanishingClasses3_le (N : ℤ) (ℓ : ℕ) [Fact ℓ.Prime] (h3 : ℓ ≠ 3) :
    (vanishingClasses3 N ℓ).card ≤ 4 := by
  classical
  have hsub : vanishingClasses3 N ℓ ⊆ insert (0 : ZMod ℓ) (vanishingClasses (4 * N) ℓ) := by
    intro t ht
    rcases (mem_vanishingClasses3_iff_zero_or_cube h3).mp ht with rfl | h
    · exact Finset.mem_insert_self _ _
    · refine Finset.mem_insert_of_mem (mem_vanishingClasses_iff.mpr ?_)
      push_cast
      linear_combination h
  calc (vanishingClasses3 N ℓ).card
      ≤ (insert (0 : ZMod ℓ) (vanishingClasses (4 * N) ℓ)).card := Finset.card_le_card hsub
    _ ≤ (vanishingClasses (4 * N) ℓ).card + 1 := Finset.card_insert_le _ _
    _ ≤ 4 := by have := card_vanishingClasses_le (4 * N) ℓ; omega

/-- **Both criteria depend on `N` only through `N mod ℓ`.** -/
theorem vanishingClasses_dependsOn_mod {N M : ℤ} {ℓ : ℕ} [Fact ℓ.Prime]
    (h : ((N : ZMod ℓ)) = ((M : ZMod ℓ))) : vanishingClasses N ℓ = vanishingClasses M ℓ := by
  ext t
  rw [mem_vanishingClasses_iff, mem_vanishingClasses_iff, h]

theorem vanishingClasses3_dependsOn_mod {N M : ℤ} {ℓ : ℕ} [Fact ℓ.Prime]
    (h : ((N : ZMod ℓ)) = ((M : ZMod ℓ))) : vanishingClasses3 N ℓ = vanishingClasses3 M ℓ := by
  ext t
  rw [mem_vanishingClasses3_iff, mem_vanishingClasses3_iff, h]

end MordellDenominators