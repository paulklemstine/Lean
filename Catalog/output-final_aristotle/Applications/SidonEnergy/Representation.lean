/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sidon sets: the representation kernel is bounded by two, and the sumset count

This file develops the *pointwise* (rather than aggregate `L²`) side of the
Sidon convolution-kernel picture begun in `EnergyCharacterization.lean`.  For a
finite set `s ⊆ ℤ`, the **representation kernel**
`r_s(x) = #{(a,b) ∈ s² : a + b = x}` is the self-convolution `1_s * 1_s`
evaluated at `x`.  For a Sidon set this kernel is uniformly bounded: it never
exceeds `2`, taking the value `1` exactly at the "doubles" `2a` and `2` at every
other representable point.  This uniform pointwise bound is the mechanism by
which the aggregate energy `E[s] = Σ_x r_s(x)²` collapses to its minimum, and it
yields the exact size of the sumset.

## Main result

* `sidon_repCount_le_two` — for a Sidon set, `r_s(x) ≤ 2` for every `x`.

## Application

* `sidon_sumset_card` — for a Sidon set, `2 · |s + s| = |s| · (|s| + 1)`, i.e.
  the sumset has exactly `|s|(|s|+1)/2` elements (all unordered pairwise sums are
  distinct).

## Tags
Sidon set, representation function, convolution kernel, sumset, B₂ set
-/
import Mathlib

open Finset

namespace Catalog.Applications.SidonEnergy.Representation

/-- A finite set of integers is **Sidon** (a `B₂` set) if all pairwise sums are
distinct. -/
def IsSidon (s : Finset ℤ) : Prop :=
  ∀ a ∈ s, ∀ b ∈ s, ∀ c ∈ s, ∀ d ∈ s, a + b = c + d → a = c ∨ a = d

/-- The **representation kernel** `r_s(x)`: the number of ordered pairs `(a,b) ∈ s²`
with `a + b = x`. -/
def repCount (s : Finset ℤ) (x : ℤ) : ℕ :=
  ((s ×ˢ s).filter (fun p => p.1 + p.2 = x)).card

/-- The sumset `{a + b : a, b ∈ s}`, as the image of `s × s` under addition. -/
def sumImg (s : Finset ℤ) : Finset ℤ :=
  (s ×ˢ s).image (fun p => p.1 + p.2)

/-- The set of "doubles" `{2a : a ∈ s}`. -/
def doubles (s : Finset ℤ) : Finset ℤ :=
  s.image (fun a => 2 * a)

/-
**Main result: the representation kernel of a Sidon set is at most `2`.**
For a Sidon set `s` and any `x`, at most two ordered pairs of elements of `s`
sum to `x` (namely `(a,b)` and `(b,a)` for the unique unordered representation).
-/
theorem sidon_repCount_le_two {s : Finset ℤ} (hs : IsSidon s) (x : ℤ) :
    repCount s x ≤ 2 := by
      by_contra h;
      -- Since `repCount s x > 2`, there exist at least three distinct pairs `(a, b)` in `s ×ˢ s` such that `a + b = x`.
      obtain ⟨a1, b1, a2, b2, a3, b3, h1, h2, h3, h_distinct⟩ : ∃ a1 b1 a2 b2 a3 b3 : ℤ, (a1, b1) ∈ s ×ˢ s ∧ (a2, b2) ∈ s ×ˢ s ∧ (a3, b3) ∈ s ×ˢ s ∧ a1 + b1 = x ∧ a2 + b2 = x ∧ a3 + b3 = x ∧ (a1, b1) ≠ (a2, b2) ∧ (a1, b1) ≠ (a3, b3) ∧ (a2, b2) ≠ (a3, b3) := by
        obtain ⟨ t, ht ⟩ := Finset.two_lt_card.mp ( by linarith! );
        rcases ht with ⟨ ht₁, u, hu₁, v, hv₁, htu, htv, huv ⟩ ; use t.1, t.2, u.1, u.2, v.1, v.2; aesop;
      simp_all +decide [ Finset.mem_product ];
      grind +locals

/-
The doubles are all representable sums.
-/
theorem doubles_subset_sumImg {s : Finset ℤ} : doubles s ⊆ sumImg s := by
  exact Finset.image_subset_iff.mpr fun x hx => Finset.mem_image.mpr ⟨ ( x, x ), Finset.mem_product.mpr ⟨ hx, hx ⟩, by ring ⟩

/-
There are exactly `|s|` doubles.
-/
theorem doubles_card (s : Finset ℤ) : (doubles s).card = s.card := by
  exact Finset.card_image_of_injective _ fun a b h => mul_left_cancel₀ two_ne_zero h

/-
For a Sidon set, a representable point has a *unique* representation iff it is
a double `2a`.
-/
theorem sidon_repCount_eq_one_iff {s : Finset ℤ} (hs : IsSidon s) {x : ℤ}
    (hx : x ∈ sumImg s) : repCount s x = 1 ↔ x ∈ doubles s := by
      constructor <;> intro H;
      · obtain ⟨ p, hp ⟩ := Finset.card_eq_one.mp H;
        simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
        grind +locals;
      · obtain ⟨ a, ha, rfl ⟩ := Finset.mem_image.mp H;
        refine' Finset.card_eq_one.mpr ⟨ ( a, a ), _ ⟩;
        grind +locals

/-
The total mass of the representation kernel is `|s|²` (there are `|s|²` ordered
pairs, each counted at its sum).
-/
theorem sum_repCount (s : Finset ℤ) :
    ∑ x ∈ sumImg s, repCount s x = s.card ^ 2 := by
      unfold repCount; simp +decide [ pow_two ] ;
      rw [ ← Finset.card_biUnion ];
      · convert Finset.card_product s s using 2 ; ext ; simp +decide [ sumImg ] ; aesop;
      · exact fun x hx y hy hxy => Finset.disjoint_left.mpr fun p hp hp' => hxy <| by aesop;

/-
Every representable point has at least one representation.
-/
theorem one_le_repCount_of_mem {s : Finset ℤ} {x : ℤ} (hx : x ∈ sumImg s) :
    1 ≤ repCount s x := by
      exact Finset.card_pos.mpr ( by obtain ⟨ a, b, ha, hb, rfl ⟩ := by simpa using Finset.mem_image.mp hx; ; exact ⟨ ( a, b ), by aesop ⟩ )

/-
**Application: the sumset of a Sidon set has exactly `|s|(|s|+1)/2` elements.**
Equivalently `2 · |s + s| = |s| · (|s| + 1)`: every unordered pairwise sum of a
Sidon set is distinct.
-/
theorem sidon_sumset_card {s : Finset ℤ} (hs : IsSidon s) :
    2 * (sumImg s).card = s.card * (s.card + 1) := by
      -- Split the sum into two parts: one over the doubles set and one over the remaining elements.
      have h_split_sum : ∑ x ∈ sumImg s, repCount s x = ∑ x ∈ doubles s, 1 + ∑ x ∈ sumImg s \ doubles s, 2 := by
        rw [ ← Finset.sum_sdiff <| doubles_subset_sumImg ];
        rw [ add_comm ];
        refine' congrArg₂ ( · + · ) ( Finset.sum_congr rfl fun x hx => _ ) ( Finset.sum_congr rfl fun x hx => _ );
        · exact sidon_repCount_eq_one_iff hs ( doubles_subset_sumImg hx ) |>.2 hx;
        · exact le_antisymm ( sidon_repCount_le_two hs x ) ( Nat.lt_of_le_of_ne ( one_le_repCount_of_mem ( Finset.mem_sdiff.mp hx |>.1 ) ) ( Ne.symm ( by intro t; have := sidon_repCount_eq_one_iff hs ( Finset.mem_sdiff.mp hx |>.1 ) ; aesop ) ) );
      simp_all +decide [ mul_comm, Finset.card_sdiff ];
      rw [ show doubles s ∩ sumImg s = doubles s from Finset.inter_eq_left.mpr <| doubles_subset_sumImg ] at h_split_sum;
      linarith [ sum_repCount s, doubles_card s, Nat.sub_add_cancel ( show # ( doubles s ) ≤ # ( sumImg s ) from Finset.card_le_card <| doubles_subset_sumImg ) ]

/-
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  Complementing the aggregate `L²` result of
`EnergyCharacterization.lean`, we conjectured a *pointwise* mechanism: for a
Sidon set the self-convolution kernel `r_s = 1_s * 1_s` is uniformly bounded by
`2`, and this crude pointwise ceiling already forces the exact sumset size
`|s+s| = |s|(|s|+1)/2`.  Ranked conjectures: (1, main) `r_s(x) ≤ 2` always for
Sidon `s`; (2, surprising) `r_s(x) = 1` happens *exactly* at the doubles `2a`,
nowhere else -- so the kernel is essentially two-valued; (3) consequently the
sumset has no "extra" coincidences and hits the maximal count `|s|(|s|+1)/2`.

**Experiment (Experimenter).**  Enumerated `|s+s|` (ComputationalEvidence.md):
Sidon `{0,1,3,7}` gives `2·|s+s| = 20 = 4·5`; the non-Sidon `{0,2,5,11,13}` gives
`2·|s+s| = 28 ≠ 30`, so the sumset identity is *exactly* the Sidon condition.
The representation counts for `{0,1,2,3}` (non-Sidon) reach `r(3)=4>2`,
confirming the bound `≤ 2` is special to Sidon sets.

**Analysis (Analyst).**  Survived: `sidon_repCount_le_two` (fiber `⊆ {(u,x-u),
(v,x-v)}`), the doubling dichotomy `sidon_repCount_eq_one_iff`, and the sumset
count `sidon_sumset_card` (fiberwise mass `Σ r_s = |s|²` split over doubles vs.
the rest, each contributing `1` resp. `2`).  The decisive step was the
fiberwise identity `sum_repCount` combined with the two-valuedness of `r_s`.
Failed / deferred: an analogous sharp count for `B_h` (higher-order Sidon)
sets -- true but requiring an `h`-fold convolution bookkeeping, a different
definition.

**Critique (Critic).**  `sidon_repCount_le_two` is non-trivial (the AP
`{0,1,2,3}` violates it with `r(3)=4`), and `sidon_sumset_card` genuinely uses
the Sidon hypothesis (it fails for `{0,2,5,11,13}`).  Proofs use
`Finset.card_biUnion`, fiberwise summation, `card_image_of_injective`, a
`le_antisymm` squeeze `1 ≤ r_s ≤ 2` with `r_s ≠ 1`, and `omega`
-- insight-bearing, not `decide`-only.  Corner cases: `x ∉ s+s` gives `r_s = 0`,
consistent with `≤ 2`; `s = ∅` gives `0 = 0`.

**Synthesis (PI).**  The pointwise kernel bound `r_s ≤ 2` and its two-valued
refinement are the local shadow of the global `L²` minimisation: they pin the
sumset size exactly, closing the elementary combinatorial account of Sidon
convolution kernels and marking precisely where the analytic `γ₀` optimisation
must take over.
-/

end Catalog.Applications.SidonEnergy.Representation