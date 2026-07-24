/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tropical weight enumerator profiles for binary linear codes

This file develops the **tropical shadow** of the classical weight enumerator that the
catalog's `SmoothPoincare` code files (`TopologicalCodes`, `CodeDirectSum`,
`MinimumDistance`, `GleasonLength`) study over `ℂ`.

The classical (Hamming) weight enumerator of a binary code `C ⊆ (ZMod 2)ⁿ` is the
two-variable polynomial `W_C(x,y) = ∑_{c∈C} x^{n−wt c} y^{wt c}`.  Its single most
important structural property, used implicitly all over `CodeDirectSum`, is that it is
**multiplicative** under the direct sum (coordinate concatenation) of codes:
`W_{C⊕D} = W_C · W_D`.

Tropicalizing — replacing the semiring `(ℝ, +, ×)` by the **min-plus tropical
semiring** `(ℝ, min, +)` of `Bridges/CategoricalTropicalUltrametric` — turns the
generating *sum* `∑` into a *minimum* and the *product* `×` into a *sum* `+`.  The
tropical weight enumerator is therefore the piecewise-linear function

  `twe C t = min_{c ∈ C} (wt c · t)`,

and the multiplicativity `W_{C⊕D} = W_C · W_D` becomes the **tropical additivity**
`twe (C ⊕ D) = twe C + twe D` (`twe_append`), the headline of this file: it is the
exact tropical mirror of `CodeDirectSum.wt_append` (`wt (a ++ b) = wt a + wt b`).

Alongside this, the **minimum distance** of a code is itself a tropical quantity: under
direct sum it behaves like tropical *addition* (a `min`):
`minDist (C ⊕ D) = min (minDist C) (minDist D)` (`minDist_append`), reflecting that the
shortest nonzero codeword of a concatenation lives entirely in one block.

The two together give a clean "tropical dictionary" for the direct-sum operation:

  | classical invariant            | direct-sum law      | tropical reading      |
  |--------------------------------|---------------------|-----------------------|
  | length `n`                     | `n_C + n_D`         | additive              |
  | `|C|`                          | `|C|·|D|`           | log-additive          |
  | weight enumerator `W_C`        | `W_C · W_D`         | `twe` additive        |
  | minimum distance `d`           | `min(d_C, d_D)`     | tropical `min`        |

Finally, instantiating on the catalog's extended Hamming `[8,4,4]` code reveals a
genuine *information-loss* phenomenon: although the classical enumerator is
`1 + 14x⁴ + x⁸` (`MinimumDistance.hamming_weightEnum_*`), the tropical enumerator is
just `twe hamming t = min(0, 8·t)` (`hamming_twe`) — the weight-`4` stratum, i.e. the
minimum distance itself, is **invisible** to the tropical enumerator because `4` is not
a vertex of the convex hull of the weight spectrum `{0,4,8}`.  This is exactly why the
minimum distance must be recorded by the *separate* tropical-min invariant `minDist`.

-- !-- Lab Notes -- !--
Hypothesis: the multiplicativity of the weight enumerator under direct sum
  (`W_{C⊕D}=W_C·W_D`, the engine behind `CodeDirectSum.appendCode_*`) tropicalizes to a
  clean additive law `twe (C⊕D)=twe C+twe D`, and the minimum distance tropicalizes to a
  `min` law `minDist (C⊕D)=min (minDist C) (minDist D)`.
Result: both laws proved `sorry`-free for arbitrary lengths via `Finset.inf'`
  antisymmetry arguments resting only on `wt_append`. Instantiated on `hamming` and
  `hamming16`: `twe hamming = min(0, 8t)` and `minDist hamming = minDist hamming16 = 4`.
Insight 1: `min_{a,b}(f a + g b) = min_a f a + min_b g b` holds for ALL real slopes `t`
  (no sign hypothesis), because the two blocks are independent — this is the tropical
  fingerprint of the factorisation `W_{C⊕D}=W_C·W_D`.
Insight 2 (information loss): the tropical enumerator only sees the *convex hull* of the
  weight spectrum. For `hamming` the spectrum `{0,4,8}` has hull vertices `{0,8}`, so the
  minimum distance `4` is erased by `twe` — a concrete reason the `minDist` invariant is
  not redundant.
Failure analysis: `Finset.inf'` nonemptiness side-goals are routed through `C.erase 0`
  (nonzero codewords) and the membership witnesses `append a 0`, `append 0 b`, which keep
  the additivity/min proofs free of any `Fin`-index arithmetic — the same routing as
  `CodeDirectSum.appendCode_selfDual`.
-/

import Mathlib
import Applications.SmoothPoincare.CodeDirectSum

open scoped BigOperators

namespace SmoothPoincare
namespace Codes

variable {m n : ℕ}

/-! ## The tropical weight enumerator -/

/-- **Tropical weight enumerator.** The min-plus tropicalization of the classical
weight enumerator: `twe C t = min_{c ∈ C} (wt c · t)`.  As a function of the tropical
variable `t : ℝ` it is concave and piecewise linear, its slopes being the codeword
weights. -/
noncomputable def twe (C : Finset (Fin n → ZMod 2)) (hC : C.Nonempty) (t : ℝ) : ℝ :=
  C.inf' hC (fun c => (wt c : ℝ) * t)

/-- The tropical enumerator is a lower bound for every codeword's linear term. -/
theorem twe_le_of_mem {C : Finset (Fin n → ZMod 2)} (hC : C.Nonempty) (t : ℝ)
    {c : Fin n → ZMod 2} (hc : c ∈ C) : twe C hC t ≤ (wt c : ℝ) * t :=
  Finset.inf'_le _ hc

/-- The tropical enumerator is *attained* by some codeword. -/
theorem twe_attained {C : Finset (Fin n → ZMod 2)} (hC : C.Nonempty) (t : ℝ) :
    ∃ c ∈ C, twe C hC t = (wt c : ℝ) * t :=
  Finset.exists_mem_eq_inf' hC _

/-- A lower bound certificate: if `b ≤ wt c · t` for every codeword `c`, then
`b ≤ twe C t`. -/
theorem le_twe {C : Finset (Fin n → ZMod 2)} (hC : C.Nonempty) (t : ℝ) {b : ℝ}
    (h : ∀ c ∈ C, b ≤ (wt c : ℝ) * t) : b ≤ twe C hC t :=
  Finset.le_inf' hC _ h

/-! ## Headline: tropical additivity under direct sum -/

/-- The direct sum of two nonempty codes is nonempty. -/
theorem appendCode_nonempty {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (hC : C.Nonempty) (hD : D.Nonempty) : (C ⊕c D).Nonempty :=
  (hC.product hD).image _

/-
**Tropical additivity of the weight enumerator under direct sum.** This is the
min-plus tropicalization of the classical multiplicativity `W_{C⊕D} = W_C · W_D`, and
the exact tropical mirror of `wt_append`. It holds for *all* real slopes `t`.
-/
theorem twe_append {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (hC : C.Nonempty) (hD : D.Nonempty) (t : ℝ) :
    twe (C ⊕c D) (appendCode_nonempty hC hD) t = twe C hC t + twe D hD t := by
  refine' le_antisymm _ _ <;> norm_num [ twe ] at *;
  · obtain ⟨ a, ha, hae ⟩ := twe_attained hC t; obtain ⟨ b, hb, hbe ⟩ := twe_attained hD t; use Fin.append a b; simp_all +decide [ wt_append ] ; ring;
    simp_all +decide [ mul_comm, Finset.mem_image, Finset.mem_product, twe ];
    exact Finset.mem_image.mpr ⟨ ( a, b ), Finset.mem_product.mpr ⟨ ha, hb ⟩, rfl ⟩;
  · intro b hb; obtain ⟨ a, ha, b, hb, rfl ⟩ := mem_appendCode_iff_exists.mp hb; simp +decide [ wt_append ] ;
    rw [ add_mul ] ; exact add_le_add ( Finset.inf'_le _ ha ) ( Finset.inf'_le _ ‹_› ) ;

/-! ## The minimum distance as a tropical-min invariant -/

/-- **Minimum distance.** The least weight of a *nonzero* codeword, defined over
`C.erase 0`. -/
noncomputable def minDist (C : Finset (Fin n → ZMod 2))
    (h : (C.erase 0).Nonempty) : ℕ :=
  (C.erase 0).inf' h wt

/-- `minDist` is a lower bound for the weight of every nonzero codeword. -/
theorem minDist_le_of_mem {C : Finset (Fin n → ZMod 2)} (h : (C.erase 0).Nonempty)
    {c : Fin n → ZMod 2} (hc : c ∈ C) (hc0 : c ≠ 0) : minDist C h ≤ wt c :=
  Finset.inf'_le _ (Finset.mem_erase.mpr ⟨hc0, hc⟩)

/-- A lower bound certificate for `minDist`. -/
theorem le_minDist {C : Finset (Fin n → ZMod 2)} (h : (C.erase 0).Nonempty) {b : ℕ}
    (hb : ∀ c ∈ C, c ≠ 0 → b ≤ wt c) : b ≤ minDist C h :=
  Finset.le_inf' h _ (fun c hc => hb c (Finset.mem_of_mem_erase hc)
    (Finset.ne_of_mem_erase hc))

/-- The nonzero codewords of a direct sum form a nonempty set, provided each factor
contains `0` and the left factor has at least one nonzero codeword. -/
theorem appendCode_erase_nonempty {C : Finset (Fin m → ZMod 2)}
    {D : Finset (Fin n → ZMod 2)} (h0D : (0 : Fin n → ZMod 2) ∈ D)
    (hCne : (C.erase 0).Nonempty) : ((C ⊕c D).erase 0).Nonempty := by
  obtain ⟨a, ha⟩ := hCne
  refine ⟨Fin.append a (0 : Fin n → ZMod 2), ?_⟩
  rw [Finset.mem_erase]
  refine ⟨?_, mem_appendCode_iff_exists.mpr
    ⟨a, Finset.mem_of_mem_erase ha, 0, h0D, rfl⟩⟩
  intro h
  have ha0 : a = 0 := by
    funext i
    have hi := congrFun h (Fin.castAdd n i)
    rwa [Fin.append_left] at hi
  exact (Finset.ne_of_mem_erase ha) ha0

/-
**Minimum distance is a tropical-min invariant.** Under direct sum the minimum
distance behaves like tropical addition (a `min`): the shortest nonzero codeword of a
concatenation lives entirely in one block.
-/
theorem minDist_append {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (h0C : (0 : Fin m → ZMod 2) ∈ C) (h0D : (0 : Fin n → ZMod 2) ∈ D)
    (hCne : (C.erase 0).Nonempty) (hDne : (D.erase 0).Nonempty) :
    minDist (C ⊕c D) (appendCode_erase_nonempty h0D hCne)
      = min (minDist C hCne) (minDist D hDne) := by
  refine' le_antisymm _ _;
  · nontriviality;
    refine' le_min _ _;
    · obtain ⟨ a, ha, hae ⟩ := Finset.exists_mem_eq_inf' hCne wt;
      refine' le_trans ( minDist_le_of_mem _ _ _ ) _;
      exact Fin.append a 0;
      · exact mem_appendCode_iff_exists.mpr ⟨ a, Finset.mem_of_mem_erase ha, 0, h0D, rfl ⟩;
      · intro h; have := congr_fun h ( Fin.castAdd n ( Classical.choose ( show ∃ i, a i ≠ 0 from not_forall.mp fun h' => Finset.ne_of_mem_erase ha <| funext h' ) ) ) ; simp_all +decide [ Fin.append ] ;
        exact Classical.choose_spec ( show ∃ i, a i ≠ 0 from not_forall.mp fun h' => Finset.ne_of_mem_erase ha <| funext h' ) this;
      · convert hae.ge using 1;
        convert wt_append a 0;
        unfold wt; aesop;
    · obtain ⟨ b, hb, hbe ⟩ := Finset.exists_mem_eq_inf' hDne wt;
      refine' le_trans ( minDist_le_of_mem _ _ _ ) _;
      exact Fin.append 0 b;
      · exact mem_appendCode_iff_exists.mpr ⟨ 0, h0C, b, Finset.mem_of_mem_erase hb, rfl ⟩;
      · simp_all +decide [ funext_iff, Fin.append ];
        exact Exists.elim hb.1 fun x hx => ⟨ Fin.natAdd m x, by simp +decide [ hx, Fin.addCases ] ⟩;
      · convert hbe.ge using 1;
        convert wt_append 0 b using 1;
        simp +decide [ wt ];
  · refine' le_minDist _ _;
    intro c hc hc0
    obtain ⟨a, ha, b, hb, rfl⟩ := mem_appendCode_iff_exists.mp hc
    have hwt : wt (Fin.append a b) = wt a + wt b := by
      convert wt_append a b using 1
    by_cases ha0 : a = 0 <;> by_cases hb0 : b = 0 <;> simp_all +decide [ min_le_iff ];
    · exact False.elim <| hc0 <| by ext i; cases i using Fin.addCases <;> simp +decide ;
    · exact Or.inr ( le_trans ( minDist_le_of_mem hDne hb hb0 ) ( by simp +decide [ wt ] ) );
    · exact Or.inl ( le_trans ( minDist_le_of_mem hCne ha ha0 ) ( by simp +decide [ wt ] ) );
    · exact Or.inl ( le_trans ( minDist_le_of_mem hCne ha ha0 ) ( Nat.le_add_right _ _ ) )

/-! ## Instantiation on the extended Hamming `[8,4,4]` code -/

/-- The extended Hamming code is nonempty. -/
theorem hamming_nonempty : hamming.Nonempty :=
  ⟨encode 0, Finset.mem_image_of_mem encode (Finset.mem_univ 0)⟩

/-- The Hamming weight spectrum is supported on `{0, 4, 8}`. -/
theorem hamming_wt_cases : ∀ c ∈ hamming, wt c = 0 ∨ wt c = 4 ∨ wt c = 8 := by
  native_decide

/-- The zero word lies in the Hamming code (weight-`0` witness). -/
theorem zero_mem_hamming : (0 : Fin 8 → ZMod 2) ∈ hamming := by
  native_decide

/-- The all-ones word lies in the Hamming code (weight-`8` witness). -/
theorem ones_mem_hamming : (ones 8) ∈ hamming := by
  native_decide

/-
**The tropical enumerator of the extended Hamming code is `min(0, 8·t)`.**
Strikingly, the weight-`4` stratum (the minimum distance) is *invisible*: `4` is not a
vertex of the convex hull of the spectrum `{0,4,8}`, so it never realizes the minimum.
This is the concrete "information loss" of tropicalization, and the reason `minDist`
must be recorded separately.
-/
theorem hamming_twe (t : ℝ) : twe hamming hamming_nonempty t = min 0 (8 * t) := by
  refine' le_antisymm _ _;
  · exact le_min ( twe_le_of_mem _ _ zero_mem_hamming |> le_trans <| by norm_num ) ( twe_le_of_mem _ _ ones_mem_hamming |> le_trans <| by norm_num [ wt_ones ] );
  · refine' le_twe _ _ _;
    intro c hc; rcases hamming_wt_cases c hc with h | h | h <;> norm_num [ h ] ;
    contrapose! h; linarith;

/-- Nonzero Hamming codewords exist. -/
theorem hamming_erase_nonempty : (hamming.erase (0 : Fin 8 → ZMod 2)).Nonempty := by
  native_decide

/-- Every nonzero Hamming codeword has weight at least `4` (the `d = 4` lower bound). -/
theorem hamming_wt_ge : ∀ c ∈ hamming, c ≠ 0 → 4 ≤ wt c := by
  native_decide

/-- There is a nonzero Hamming codeword of weight exactly `4` (attaining `d = 4`). -/
theorem hamming_wt4_witness : ∃ c ∈ hamming, c ≠ 0 ∧ wt c = 4 := by
  native_decide

/-- **The minimum distance of the extended Hamming code is `4`.** -/
theorem hamming_minDist : minDist hamming hamming_erase_nonempty = 4 := by
  apply le_antisymm
  · obtain ⟨c, hc, hc0, hcw⟩ := hamming_wt4_witness
    calc minDist hamming hamming_erase_nonempty ≤ wt c :=
          minDist_le_of_mem _ hc hc0
      _ = 4 := hcw
  · exact le_minDist _ hamming_wt_ge

/-! ## The headline direct sum `hamming ⊕ hamming` -/

/-- Tropical additivity, instantiated: the tropical enumerator of `hamming ⊕ hamming` is
twice that of `hamming`. -/
theorem hamming16_twe (t : ℝ) :
    twe (hamming ⊕c hamming) (appendCode_nonempty hamming_nonempty hamming_nonempty) t
      = 2 * twe hamming hamming_nonempty t := by
  rw [twe_append hamming_nonempty hamming_nonempty]; ring

/-- The nonzero codewords of `hamming ⊕ hamming` form a nonempty set. -/
theorem hamming16_erase_nonempty :
    ((hamming ⊕c hamming).erase (0 : Fin (8 + 8) → ZMod 2)).Nonempty :=
  appendCode_erase_nonempty zero_mem_hamming hamming_erase_nonempty

/-- **The minimum distance of `hamming ⊕ hamming` is `4 = min(4,4)`** — the tropical-min
law in action: stacking two copies of the same code does not improve the minimum
distance. -/
theorem hamming16_minDist :
    minDist (hamming ⊕c hamming) hamming16_erase_nonempty = 4 := by
  rw [minDist_append zero_mem_hamming zero_mem_hamming
        hamming_erase_nonempty hamming_erase_nonempty, hamming_minDist]
  norm_num

/-! ## The max-plus dual enumerator and tropical profile self-duality

-- !-- Lab Notes (cycle 2) -- !--
Hypothesis (this realizes FUTURE_DIRECTIONS Conjecture 4): the *max-plus* dual
  `twePlus C t = max_{c∈C} (wt c · t)` is also additive under direct sum (`max` of a sum
  of independent blocks splits), and for a code containing both `0` and the all-ones word
  the two enumerators satisfy the clean *profile self-duality* `twePlus + twe = n · t`,
  because `min a b + max a b = a + b`.
Result: `twePlus_append` proved for arbitrary lengths; `hamming_twePlus = max(0, 8t)` and
  the self-duality `twePlus hamming + twe hamming = 8·t` proved `sorry`-free. The slope of
  `twePlus` at negative `t` is the *maximum* weight `8` (a covering-radius envelope),
  complementing the *minimum* distance recorded by `minDist`.
Insight: the pair `(twe, twePlus)` brackets the weight spectrum by its convex-hull
  endpoints `{0, 8}`; their sum collapsing to `n·t` is the tropical fingerprint of the
  code being self-complementary (closed under adding the all-ones word).
-/

/-- **Max-plus dual enumerator.** `twePlus C t = max_{c ∈ C} (wt c · t)`. Its negative-`t`
slope is the *maximum* codeword weight, a covering-radius envelope dual to `minDist`. -/
noncomputable def twePlus (C : Finset (Fin n → ZMod 2)) (hC : C.Nonempty) (t : ℝ) : ℝ :=
  C.sup' hC (fun c => (wt c : ℝ) * t)

/-- `twePlus` is an upper bound for every codeword's linear term. -/
theorem le_twePlus_of_mem {C : Finset (Fin n → ZMod 2)} (hC : C.Nonempty) (t : ℝ)
    {c : Fin n → ZMod 2} (hc : c ∈ C) : (wt c : ℝ) * t ≤ twePlus C hC t :=
  Finset.le_sup' (fun c => (wt c : ℝ) * t) hc

/-- The max-plus enumerator is *attained* by some codeword. -/
theorem twePlus_attained {C : Finset (Fin n → ZMod 2)} (hC : C.Nonempty) (t : ℝ) :
    ∃ c ∈ C, twePlus C hC t = (wt c : ℝ) * t :=
  Finset.exists_mem_eq_sup' hC _

/-- An upper bound certificate: if `wt c · t ≤ b` for every codeword `c`, then
`twePlus C t ≤ b`. -/
theorem twePlus_le {C : Finset (Fin n → ZMod 2)} (hC : C.Nonempty) (t : ℝ) {b : ℝ}
    (h : ∀ c ∈ C, (wt c : ℝ) * t ≤ b) : twePlus C hC t ≤ b :=
  Finset.sup'_le hC _ h

/-- **Max-plus additivity under direct sum.** The dual of `twe_append`: the covering
envelope is additive too. -/
theorem twePlus_append {C : Finset (Fin m → ZMod 2)} {D : Finset (Fin n → ZMod 2)}
    (hC : C.Nonempty) (hD : D.Nonempty) (t : ℝ) :
    twePlus (C ⊕c D) (appendCode_nonempty hC hD) t = twePlus C hC t + twePlus D hD t := by
  refine le_antisymm ?_ ?_
  · refine twePlus_le _ _ ?_
    intro z hz
    obtain ⟨a, ha, b, hb, rfl⟩ := mem_appendCode_iff_exists.mp hz
    have : (wt (Fin.append a b) : ℝ) * t = (wt a : ℝ) * t + (wt b : ℝ) * t := by
      rw [wt_append]; push_cast; ring
    rw [this]
    exact add_le_add (le_twePlus_of_mem _ _ ha) (le_twePlus_of_mem _ _ hb)
  · obtain ⟨a, ha, hae⟩ := twePlus_attained hC t
    obtain ⟨b, hb, hbe⟩ := twePlus_attained hD t
    have hmem : Fin.append a b ∈ C ⊕c D :=
      mem_appendCode_iff_exists.mpr ⟨a, ha, b, hb, rfl⟩
    have hval : (wt (Fin.append a b) : ℝ) * t = (wt a : ℝ) * t + (wt b : ℝ) * t := by
      rw [wt_append]; push_cast; ring
    calc twePlus C hC t + twePlus D hD t
        = (wt a : ℝ) * t + (wt b : ℝ) * t := by rw [hae, hbe]
      _ = (wt (Fin.append a b) : ℝ) * t := hval.symm
      _ ≤ twePlus (C ⊕c D) _ t := le_twePlus_of_mem _ _ hmem

/-- **The max-plus enumerator of the extended Hamming code is `max(0, 8·t)`** — the dual
profile, whose negative slope `8` is the maximum weight (covering-radius envelope). -/
theorem hamming_twePlus (t : ℝ) : twePlus hamming hamming_nonempty t = max 0 (8 * t) := by
  refine le_antisymm ?_ ?_
  · refine twePlus_le _ _ ?_
    intro c hc
    rcases hamming_wt_cases c hc with h | h | h <;> norm_num [h]
    · rcases le_total 0 (8 * t) with h8 | h8
      · right; linarith
      · left; linarith
  · refine max_le ?_ ?_
    · have := le_twePlus_of_mem hamming_nonempty t zero_mem_hamming
      simpa [wt] using this
    · have := le_twePlus_of_mem hamming_nonempty t ones_mem_hamming
      simpa [wt_ones] using this

/-- **Tropical profile self-duality of the extended Hamming code:**
`twePlus hamming t + twe hamming t = 8 · t`. The covering envelope and the minimum-weight
envelope sum to the full length-`8` line, the tropical fingerprint of the code being
self-complementary. Here it is the identity `max a b + min a b = a + b`. -/
theorem hamming_twePlus_add_twe (t : ℝ) :
    twePlus hamming hamming_nonempty t + twe hamming hamming_nonempty t = 8 * t := by
  rw [hamming_twePlus, hamming_twe]
  rcases le_total 0 (8 * t) with h8 | h8
  · rw [max_eq_right h8, min_eq_left h8]; ring
  · rw [max_eq_left h8, min_eq_right h8]; ring

end Codes
end SmoothPoincare