/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sidon sets and additive energy: the L² minimisation characterisation

A finite set of integers `s` is a **Sidon set** (a `B₂` set) when all of its
pairwise sums are distinct.  Companion catalog work
(`MachineLearning/SidonKernels`) analyses the *difference-set* engine behind the
classical `|s| ≲ √N` size bound.  Here we develop the complementary **L²
(convolution-energy) side** of the theory, which is exactly the object the
"multi-kernel smoothing" / optimised-`L²`-energy programme manipulates.

For a finite set `s`, the *additive energy* `E[s]` (`Finset.addEnergy`, Mathlib)
counts the quadruples `(a,b,c,d) ∈ s⁴` with `a + b = c + d`.  Writing
`r_s(x) = #{(a,b) ∈ s² : a + b = x}` for the convolution kernel
`r_s = 1_s * 1_s`, one has the Parseval identity `E[s] = Σ_x r_s(x)²`, so `E[s]`
is precisely the squared `L²` norm of the self-convolution kernel.

## Main results

* `sidon_iff_addEnergy` — `s` is Sidon **iff** `E[s] + |s| = 2·|s|²`, i.e. iff
  the self-convolution kernel attains its minimum possible `L²` energy.
* `addEnergy_ge` — the universal lower bound `2·|s|² ≤ E[s] + |s|`: **every**
  finite set has additive energy at least `2|s|² − |s|`, so Sidon sets are the
  exact energy minimisers.

The proof runs entirely through an explicit description of the energy quadruple
set as the (almost disjoint) union of a "diagonal" copy and a "swap" copy of
`s × s`, the two elementary convolution kernels whose combination is forced.

## Tags
Sidon set, additive energy, convolution kernel, L² minimisation, B₂ set
-/
import Mathlib

open Finset
open scoped Combinatorics.Additive

namespace Catalog.Applications.SidonEnergy

/-- A finite set of integers is **Sidon** (a `B₂` set) if all pairwise sums are
distinct: whenever `a + b = c + d` with all four in `s`, then `a = c` or `a = d`. -/
def IsSidon (s : Finset ℤ) : Prop :=
  ∀ a ∈ s, ∀ b ∈ s, ∀ c ∈ s, ∀ d ∈ s, a + b = c + d → a = c ∨ a = d

/-- The set of *energy quadruples* of `s`: the elements `((a,c),(b,d))` of
`(s × s) × (s × s)` satisfying `a + b = c + d`.  Its cardinality is exactly the
additive energy `E[s]`. -/
def energySet (s : Finset ℤ) : Finset ((ℤ × ℤ) × (ℤ × ℤ)) :=
  ((s ×ˢ s) ×ˢ s ×ˢ s).filter (fun x => x.1.1 + x.2.1 = x.1.2 + x.2.2)

/-- The **diagonal kernel**: trivial energy quadruples of the form `((a,a),(b,b))`. -/
def trivA (s : Finset ℤ) : Finset ((ℤ × ℤ) × (ℤ × ℤ)) :=
  (s ×ˢ s).image (fun p => ((p.1, p.1), (p.2, p.2)))

/-- The **swap kernel**: trivial energy quadruples of the form `((a,b),(b,a))`. -/
def trivB (s : Finset ℤ) : Finset ((ℤ × ℤ) × (ℤ × ℤ)) :=
  (s ×ˢ s).image (fun p => ((p.1, p.2), (p.2, p.1)))

/-- The additive energy is the cardinality of the energy quadruple set. -/
theorem addEnergy_eq_card (s : Finset ℤ) : E[s] = (energySet s).card := rfl

/-
The diagonal kernel has `|s|²` elements.
-/
theorem trivA_card (s : Finset ℤ) : (trivA s).card = s.card ^ 2 := by
  convert Finset.card_image_of_injOn _;
  · norm_num [ sq ];
  · aesop_cat

/-
The swap kernel has `|s|²` elements.
-/
theorem trivB_card (s : Finset ℤ) : (trivB s).card = s.card ^ 2 := by
  unfold trivB;
  rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ] ; ring

/-
The two kernels overlap exactly in the fully-diagonal quadruples `((a,a),(a,a))`,
of which there are `|s|`.
-/
theorem trivAB_inter_card (s : Finset ℤ) : (trivA s ∩ trivB s).card = s.card := by
  rw [ show trivA s ∩ trivB s = Finset.image ( fun x : ℤ => ( ( x, x ), ( x, x ) ) ) s from ?_ ];
  · exact Finset.card_image_of_injective _ fun x y => by aesop;
  · ext ⟨ ⟨ a, b ⟩, c, d ⟩ ; simp +decide [ trivA, trivB ] ; aesop;

/-
Counting the union of the two kernels: `|trivA ∪ trivB| + |s| = 2|s|²`.
-/
theorem triv_union_card (s : Finset ℤ) :
    (trivA s ∪ trivB s).card + s.card = 2 * s.card ^ 2 := by
      have h_card_union : (trivA s ∪ trivB s).card + (trivA s ∩ trivB s).card = (trivA s).card + (trivB s).card := by
        exact Finset.card_union_add_card_inter _ _;
      linarith [ trivA_card s, trivB_card s, trivAB_inter_card s ]

/-
Both trivial kernels consist of genuine energy quadruples.
-/
theorem triv_subset_energy (s : Finset ℤ) : trivA s ∪ trivB s ⊆ energySet s := by
  intro x hx; simp_all +decide [ energySet, trivA, trivB ] ;
  grind

/-
For a Sidon set, *every* energy quadruple is trivial: it lies in the diagonal
or the swap kernel.
-/
theorem sidon_energy_subset {s : Finset ℤ} (hs : IsSidon s) :
    energySet s ⊆ trivA s ∪ trivB s := by
      intro x hx;
      simp_all +decide [ energySet, trivA, trivB ];
      rcases hs _ hx.1.1.1 _ hx.1.2.1 _ hx.1.1.2 _ hx.1.2.2 hx.2 with ( h | h ) <;> simp_all +decide [ Prod.ext_iff ];
      omega

/-
Conversely, if every energy quadruple is trivial then `s` is Sidon.
-/
theorem energy_subset_sidon {s : Finset ℤ}
    (h : energySet s ⊆ trivA s ∪ trivB s) : IsSidon s := by
      intro a ha b hb c hc d hd habcd;
      have := @h ( ( ( a, c ), ( b, d ) ) ) ?_ <;> simp_all +decide [ trivA, trivB ];
      · grind;
      · unfold energySet; aesop;

/-
**Universal additive-energy lower bound.**  Every finite set of integers
satisfies `2·|s|² ≤ E[s] + |s|`, i.e. `E[s] ≥ 2|s|² − |s|`.  Equivalently, the
self-convolution kernel `1_s * 1_s` always carries `L²` energy at least
`2|s|² − |s|`.
-/
theorem addEnergy_ge (s : Finset ℤ) : 2 * s.card ^ 2 ≤ E[s] + s.card := by
  rw [ addEnergy_eq_card ];
  linarith [ triv_union_card s, Finset.card_le_card ( triv_subset_energy s ) ]

/-
**Sidon ⇔ minimal additive energy.**  A finite set of integers is Sidon iff
its additive energy attains the universal lower bound, `E[s] + |s| = 2·|s|²`.
This is the exact `L²`-energy minimisation statement for the self-convolution
kernel.
-/
theorem sidon_iff_addEnergy {s : Finset ℤ} :
    IsSidon s ↔ E[s] + s.card = 2 * s.card ^ 2 := by
      constructor;
      · intro hs
        have h_eq : (energySet s).card = (trivA s ∪ trivB s).card := by
          exact congr_arg Finset.card ( Finset.Subset.antisymm ( sidon_energy_subset hs ) ( triv_subset_energy s ) );
        rw [ addEnergy_eq_card, h_eq, triv_union_card ];
      · intro h
        have h_card : (energySet s).card = (trivA s ∪ trivB s).card := by
          linarith [ addEnergy_eq_card s, triv_union_card s ];
        apply energy_subset_sidon;
        exact Finset.eq_of_subset_of_card_le ( triv_subset_energy s ) ( by linarith ) ▸ Finset.Subset.refl _

/-
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  The mission's "multi-kernel smoothing / optimised
L²-energy" theme is, at its combinatorial core, a statement about the additive
energy `E[s] = Σ_x r_s(x)²` of the self-convolution kernel `r_s = 1_s * 1_s`.
We conjectured, ranked by impact: (1, main) `s` is Sidon **iff** `E[s]` attains
its minimum `2|s|²−|s|`; (2) this minimum is a *universal* lower bound valid for
every finite set (so Sidon sets are exactly the L²-energy minimisers); (3,
surprising) the whole minimisation is witnessed by exactly **two** elementary
convolution kernels -- a "diagonal" copy and a "swap" copy of `s×s` -- whose
almost-disjoint union already saturates the bound, so no third kernel is ever
needed.  Sub-conjecture (3) is the crisp finite-family ("finite family {K_i}")
statement lurking behind the vague `γ₀` numerology.

**Experiment (Experimenter).**  Computed `E[s]` directly (ComputationalEvidence.md):
Sidon `{0,1,3,7}` gives `E=28=2·4²−4`; the arithmetic progression `{0,1,2}` gives
`E=19>2·3²−3=15`; `{0,1,2,3}` gives `E=44>28`.  These confirmed both the exact
Sidon value and the strict gap for non-Sidon sets, i.e. that the lower bound is
sharp precisely on Sidon sets.

**Analysis (Analyst).**  Survived: `sidon_iff_addEnergy` and `addEnergy_ge`, both
factoring through the explicit `energySet = trivA ∪ trivB` description.  The
two-kernel decomposition made every step elementary: cardinalities via
`card_image_of_injOn`, the union count via inclusion–exclusion
(`card_union_add_card_inter`), and both containments via the Sidon algebra
`a+b=c+d ⇒ a=c ∨ a=d`.  Failed / deferred: pinning the *analytic* constant
`γ₀≈0.94601` -- that is a genuinely different (windowed Fourier / real
optimisation) object, TRUE-BUT-HARD, and provably beyond the two-kernel
combinatorial identity, which is exact and constant-free.

**Critique (Critic).**  No result is vacuous: `addEnergy_ge` holds for all `s`
(including `∅`, both sides `0`), and `sidon_iff_addEnergy` has explicit
witnesses on both sides (Sidon `{0,1,3,7}` saturates; the AP `{0,1,2}` is a
strict non-example).  Proofs use `card_image_of_injOn`, inclusion–exclusion,
`Finset.eq_of_subset_of_card_le`, `rcases` on the Sidon disjunction and `omega`
-- insight-bearing, not `decide`/`simp`-only.  Corner case `|s|≤1`: `2|s|²−|s|`
stays `≤ |s|²`, consistent.

**Synthesis (PI).**  Additive energy gives a clean, exact, constant-free
characterisation of Sidon sets as the unique L²-energy minimisers, realised by a
finite family of exactly two convolution kernels.  This isolates the *hard*
part of the `γ₀` programme (the sub-leading analytic constant) from the *exact*
combinatorial skeleton, which is fully settled here.
-/

end Catalog.Applications.SidonEnergy