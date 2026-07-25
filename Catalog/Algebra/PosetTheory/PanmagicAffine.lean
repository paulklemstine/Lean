import Mathlib

/-!
# Algebraic Characterization of Panmagic Affine Permutations over `ZMod n`

This file studies *affine permutations* of `ZMod n`, i.e. maps of the form
`x ↦ a * x + b`, and characterizes when they are **panmagic**.

An affine map `σ(x) = a*x + b` is a permutation of `ZMod n` iff `a` is a unit.
Following the classical theory connecting magic/Latin squares with permutations
of cyclic groups:

* `σ` is an **orthomorphism** iff `x ↦ σ(x) - x` is also a permutation
  (this is what makes a *broken-diagonal* of one Latin square behave like a column).
* `σ` is a **complete mapping** iff `x ↦ σ(x) + x` is also a permutation.

A permutation that is *simultaneously* an orthomorphism and a complete mapping
yields a **pandiagonal (panmagic)** Latin square — every row, column and both
families of broken diagonals are transversals.  We call such an affine map
**panmagic**.

## Main results

* `mulAdd_bijective_iff` : in any commutative ring, `x ↦ c*x + d` is a bijection
  iff `c` is a unit.
* `orthomorphism_iff` / `completeMapping_iff` : the diagonal characterizations.
* `isPanmagic_iff_units` : `σ_{a,b}` is panmagic iff `a`, `a-1`, `a+1` are all units.
* `exists_panmagic_iff_coprime_six` : a panmagic affine permutation of `ZMod n`
  exists iff `n` is coprime to `6`.

-- !-- Lab Notes -- !--
Hypothesis (H1): The orthomorphism / complete-mapping conditions for an affine
map `a*x+b` depend only on `a`, namely on whether `a-1` resp. `a+1` is a unit.
  Experiment: `a*x+b - x = (a-1)*x + b` and `a*x+b + x = (a+1)*x + b` (ring),
  so bijectivity reduces to the multiplier being a unit.  CONFIRMED.

Hypothesis (H2): Existence is governed by `gcd(n,6)=1`.
  Heuristic: we need `a`, `a-1`, `a+1` all units.  Mod 2, `a` and `a-1` cannot
  both be units (they are `0` and `1` in some order); mod 3, the three
  consecutive values `a-1, a, a+1` cover all residues so one is `0`.  Hence
  `2 ∤ n` and `3 ∤ n` are necessary.  Conversely `a = 2` works whenever
  `n` is coprime to 6 (then `1 = a-1`, `2 = a`, `3 = a+1` are all units),
  so no Chinese-Remainder construction is needed — a single explicit witness
  suffices.  CONFIRMED (`decide` on `ZMod 2`, `ZMod 3`).
-- !-- End Lab Notes -- !--
-/

namespace PanmagicAffine

open Function

/-- The affine map `x ↦ a * x + b` on `ZMod n`. -/
def affine (n : ℕ) (a b : ZMod n) : ZMod n → ZMod n := fun x => a * x + b

/--
In a commutative ring, the affine map `x ↦ c*x + d` is a bijection iff `c`
is a unit.  (Surjectivity already forces `c` to be a unit, and a unit multiplier
gives an explicit inverse, so finiteness is not needed.)
-/
lemma mulAdd_bijective_iff {R : Type*} [CommRing R] (c d : R) :
    Bijective (fun x => c * x + d) ↔ IsUnit c := by
  constructor <;> intro h;
  · obtain ⟨ x, hx ⟩ := h.2 ( 1 + d );
    grind +suggestions;
  · obtain ⟨ u, rfl ⟩ := h;
    exact ⟨ fun x y hxy => by simpa [ u.mul_left_inj ] using hxy, fun x => ⟨ u⁻¹ * ( x - d ), by simp +decide ⟩ ⟩

/--
An affine permutation is a permutation iff its multiplier is a unit.
-/
lemma affine_bijective_iff (n : ℕ) (a b : ZMod n) :
    Bijective (affine n a b) ↔ IsUnit a := by
  convert mulAdd_bijective_iff a b using 1

/--
Orthomorphism condition: `x ↦ σ(x) - x` is a bijection iff `a - 1` is a unit.
-/
lemma orthomorphism_iff (n : ℕ) (a b : ZMod n) :
    Bijective (fun x => affine n a b x - x) ↔ IsUnit (a - 1) := by
  convert PanmagicAffine.mulAdd_bijective_iff ( a - 1 ) b using 2;
  exact funext fun x => by rw [ affine ] ; ring;

/--
Complete-mapping condition: `x ↦ σ(x) + x` is a bijection iff `a + 1` is a unit.
-/
lemma completeMapping_iff (n : ℕ) (a b : ZMod n) :
    Bijective (fun x => affine n a b x + x) ↔ IsUnit (a + 1) := by
  convert mulAdd_bijective_iff (a + 1) b using 2
  exact funext fun x => by unfold affine; ring

/-- An affine map `σ_{a,b}` is **panmagic** when it is a permutation that is
both an orthomorphism and a complete mapping. -/
def IsPanmagic (n : ℕ) (a b : ZMod n) : Prop :=
  Bijective (affine n a b) ∧
    Bijective (fun x => affine n a b x - x) ∧
    Bijective (fun x => affine n a b x + x)

/--
**Algebraic characterization.** `σ_{a,b}` is panmagic iff `a`, `a-1`, `a+1`
are all units of `ZMod n`.
-/
theorem isPanmagic_iff_units (n : ℕ) (a b : ZMod n) :
    IsPanmagic n a b ↔ IsUnit a ∧ IsUnit (a - 1) ∧ IsUnit (a + 1) := by
  constructor;
  · exact fun h => ⟨ affine_bijective_iff n a b |>.1 h.1, orthomorphism_iff n a b |>.1 h.2.1, completeMapping_iff n a b |>.1 h.2.2 ⟩;
  · exact fun h => ⟨ affine_bijective_iff n a b |>.2 h.1, orthomorphism_iff n a b |>.2 h.2.1, completeMapping_iff n a b |>.2 h.2.2 ⟩

/-- No element of `ZMod 2` makes both `x` and `x-1` units. -/
lemma not_units_zmod_two : ∀ x : ZMod 2, ¬ (IsUnit x ∧ IsUnit (x - 1)) := by
  decide

/-- No element of `ZMod 3` makes all of `x`, `x-1`, `x+1` units. -/
lemma not_units_zmod_three : ∀ x : ZMod 3, ¬ (IsUnit x ∧ IsUnit (x - 1) ∧ IsUnit (x + 1)) := by
  decide

/--
If `a`, `a-1` are units of `ZMod n`, then `2 ∤ n`.
-/
lemma not_two_dvd_of_units {n : ℕ} {a : ZMod n}
    (ha : IsUnit a) (ha1 : IsUnit (a - 1)) : ¬ (2 ∣ n) := by
  intro h;
  convert PanmagicAffine.not_units_zmod_two ( ZMod.castHom h ( ZMod 2 ) a ) ?_ using 1;
  convert And.intro ( ha.map ( ZMod.castHom h ( ZMod 2 ) ) ) ( ha1.map ( ZMod.castHom h ( ZMod 2 ) ) ) using 1;
  rw [ map_sub, map_one ]

/--
If `a`, `a-1`, `a+1` are units of `ZMod n`, then `3 ∤ n`.
-/
lemma not_three_dvd_of_units {n : ℕ} {a : ZMod n}
    (ha : IsUnit a) (ha1 : IsUnit (a - 1)) (ha2 : IsUnit (a + 1)) : ¬ (3 ∣ n) := by
  intro h;
  -- Consider the natural ring homomorphism `ZMod n →+* ZMod 3` induced by `3 ∣ n`.
  obtain ⟨f, hf⟩ : ∃ f : ZMod n →+* ZMod 3, True := by
    obtain ⟨ k, rfl ⟩ := h;
    exact ⟨ ZMod.castHom ( by norm_num ) _, trivial ⟩;
  exact not_units_zmod_three ( f a ) ⟨ f.isUnit_map ha, f.isUnit_map ha1 |> fun h => by simpa [ map_sub, map_one ] using h, f.isUnit_map ha2 |> fun h => by simpa [ map_add, map_one ] using h ⟩

/--
**Existence.** A panmagic affine permutation of `ZMod n` exists iff `n` is
coprime to `6`.
-/
theorem exists_panmagic_iff_coprime_six (n : ℕ) :
    (∃ a b : ZMod n, IsPanmagic n a b) ↔ Nat.Coprime n 6 := by
  constructor <;> intro h;
  · obtain ⟨ a, b, h ⟩ := h;
    have h_coprime : Nat.Coprime n 2 ∧ Nat.Coprime n 3 := by
      have h_coprime : ¬(2 ∣ n) ∧ ¬(3 ∣ n) := by
        exact ⟨ not_two_dvd_of_units ( isPanmagic_iff_units n a b |>.1 h |>.1 ) ( isPanmagic_iff_units n a b |>.1 h |>.2.1 ), not_three_dvd_of_units ( isPanmagic_iff_units n a b |>.1 h |>.1 ) ( isPanmagic_iff_units n a b |>.1 h |>.2.1 ) ( isPanmagic_iff_units n a b |>.1 h |>.2.2 ) ⟩;
      exact ⟨ Nat.Coprime.symm ( Nat.prime_two.coprime_iff_not_dvd.mpr h_coprime.1 ), Nat.Coprime.symm ( Nat.prime_three.coprime_iff_not_dvd.mpr h_coprime.2 ) ⟩;
    exact Nat.Coprime.mul_right h_coprime.1 h_coprime.2;
  · use 2, 0;
    convert isPanmagic_iff_units n 2 0 |>.2 ⟨ ?_, ?_, ?_ ⟩;
    · convert ( ZMod.isUnit_iff_coprime 2 n ).2 _;
      exact h.symm.coprime_dvd_left ( by decide );
    · norm_num;
    · convert ZMod.isUnit_iff_coprime 3 n |>.2 ( show Nat.Coprime 3 n from Nat.Coprime.symm <| h.coprime_dvd_right <| by decide ) using 1;
      norm_num

/-!
## Companion thresholds: orthomorphisms and complete mappings

-- !-- Lab Notes -- !--
Hypothesis (H3): Dropping one diagonal lowers the threshold from `gcd(n,6)=1`
to `gcd(n,2)=1` (i.e. `n` odd).  An affine *orthomorphism* needs `a` and `a-1`
units; an affine *complete mapping* needs `a` and `a+1` units.  Mod 2 these are
the obstruction (`a` and `a±1` are `0` and `1` in some order), and any odd `n`
admits an explicit witness (`a=2` for orthomorphisms, `a=1` for complete
mappings).  CONFIRMED.  This matches the classical Hall–Paige fact that a cyclic
group `Z_n` admits a complete mapping iff `n` is odd.
-- !-- End Lab Notes -- !--
-/

/-- An affine permutation that is an orthomorphism. -/
def IsOrthomorphism (n : ℕ) (a b : ZMod n) : Prop :=
  Bijective (affine n a b) ∧ Bijective (fun x => affine n a b x - x)

/-- An affine permutation that is a complete mapping. -/
def IsCompleteMapping (n : ℕ) (a b : ZMod n) : Prop :=
  Bijective (affine n a b) ∧ Bijective (fun x => affine n a b x + x)

/-- A panmagic affine permutation is in particular an orthomorphism. -/
theorem IsPanmagic.isOrthomorphism {n : ℕ} {a b : ZMod n}
    (h : IsPanmagic n a b) : IsOrthomorphism n a b :=
  ⟨h.1, h.2.1⟩

/-- A panmagic affine permutation is in particular a complete mapping. -/
theorem IsPanmagic.isCompleteMapping {n : ℕ} {a b : ZMod n}
    (h : IsPanmagic n a b) : IsCompleteMapping n a b :=
  ⟨h.1, h.2.2⟩

/--
If `a` and `a+1` are units of `ZMod n`, then `2 ∤ n`.  (Mod 2, `a+1 = a-1`,
so this reduces to `not_two_dvd_of_units`.)
-/
lemma not_two_dvd_of_units_add {n : ℕ} {a : ZMod n}
    (ha : IsUnit a) (ha1 : IsUnit (a + 1)) : ¬ (2 ∣ n) := by
  intro h
  set f := ZMod.castHom h (ZMod 2) with hf
  have h1 : IsUnit (f a) := ha.map f
  have h2 : IsUnit (f a + 1) := by simpa [map_add, map_one] using ha1.map f
  revert h1 h2
  generalize f a = x
  revert x
  decide

/--
**Existence of affine orthomorphisms.** `ZMod n` admits an affine
orthomorphism iff `n` is odd (coprime to `2`).
-/
theorem exists_orthomorphism_iff_coprime_two (n : ℕ) :
    (∃ a b : ZMod n, IsOrthomorphism n a b) ↔ Nat.Coprime n 2 := by
  constructor;
  · rintro ⟨ a, b, h ⟩;
    have := PanmagicAffine.not_two_dvd_of_units ( PanmagicAffine.affine_bijective_iff n a b |>.1 h.1 ) ( PanmagicAffine.orthomorphism_iff n a b |>.1 h.2 );
    exact Nat.Coprime.symm ( Nat.prime_two.coprime_iff_not_dvd.mpr this );
  · intro h;
    use 2, 0;
    constructor;
    · exact affine_bijective_iff n 2 0 |>.2 ( by exact ( ZMod.isUnit_iff_coprime _ _ |>.2 h.symm ) );
    · convert orthomorphism_iff n 2 0 |>.2 _ using 1;
      norm_num

/--
**Existence of affine complete mappings.** `ZMod n` admits an affine
complete mapping iff `n` is odd (coprime to `2`).
-/
theorem exists_completeMapping_iff_coprime_two (n : ℕ) :
    (∃ a b : ZMod n, IsCompleteMapping n a b) ↔ Nat.Coprime n 2 := by
  constructor;
  · rintro ⟨ a, b, ha, hb ⟩;
    -- By definition of IsCompleteMapping, we need to show that if there exist a and b such that IsCompleteMapping n a b, then n is coprime to 2.
    have h_units : IsUnit a ∧ IsUnit (a + 1) := by
      exact ⟨ affine_bijective_iff n a b |>.1 ha, completeMapping_iff n a b |>.1 hb ⟩;
    exact Nat.Coprime.symm ( Nat.prime_two.coprime_iff_not_dvd.mpr ( not_two_dvd_of_units_add h_units.1 h_units.2 ) );
  · intro h;
    use 1, 0;
    constructor;
    · convert PanmagicAffine.affine_bijective_iff n 1 0 |>.2 ?_;
      exact isUnit_one;
    · convert PanmagicAffine.completeMapping_iff n 1 0 |>.2 _;
      convert ( ZMod.isUnit_iff_coprime 2 n ).mpr h.symm using 1;
      norm_num

end PanmagicAffine