/-
# The Boltzmann Bridge VIII — The Interleaving Distance *is* the Sup-Distance of Weights

This file discharges **Future Direction 1** of Boltzmann Bridge VII
(`Applications.BoltzmannBridge.InterleavingClosure`): it upgrades the *one*
inequality `eInterleavingDist_le_supDist` of Bridge V to an exact **isometry
formula**, exhibiting `Filtration α` as the weight functions
`Finset α → ℝ` under the (extended) sup-distance.

## The arc so far

* **IV — `BottleneckStability`**: the relational interleaving preorder
  (`Interleaved`, `Interleaved_refl/symm/mono/trans`), the predicate
  `WeightCloseBy F G D := ∀ σ, |F.weight σ - G.weight σ| ≤ D`, and the CESH
  stability theorem `stability_supDist : 0 ≤ D → WeightCloseBy F G D →
  Interleaved F G D` (uniform `D`-closeness ⇒ `D`-interleaving).
* **V — `InterleavingMetric`**: the `ℝ≥0∞`-valued `eInterleavingDist` and the
  one-sided stability bound `eInterleavingDist_le_supDist`.
* **VII — `InterleavingClosure`**: the attained infimum at `0`
  (`eInterleavingDist_eq_zero_iff_eq`), proving the structure is a genuine
  `EMetricSpace` and the `0`-interleaving relation is *equality of weights*
  (`interleaved_zero_iff_weight_eq`).

## The synthesis (this file)

Bridge VII observed that `Interleaved F G 0 ↔ F.weight = G.weight`.  The decisive
generalisation is that this is *quantitative*: the converse of `stability_supDist`
holds for **every** shift, not just `0`.

* **The interleaving relation is exactly uniform closeness of weights**
  (`interleaved_iff_weightCloseBy`):
  `Interleaved F G δ ↔ 0 ≤ δ ∧ WeightCloseBy F G δ`.
  The forward direction evaluates the sublevel inclusions at the two birth times
  `t = F.weight σ` and `t = G.weight σ`; the backward direction is exactly
  `stability_supDist`.  (At `δ = 0` this *is* Bridge VII's
  `interleaved_zero_iff_weight_eq`.)
* Therefore the defining infimum of `eInterleavingDist` is an infimum of sup-norm
  bounds, and it **equals the extended sup-distance of the weights**
  (`eInterleavingDist_eq_weightSupEDist`):

  > **`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`.**

  The `≥` direction (`weightSupEDist_le_eInterleavingDist`) holds because every
  interleaving witness `δ` dominates every weight gap; the `≤` direction
  (`eInterleavingDist_le_weightSupEDist`) is the attained-infimum argument — when
  the sup is finite, its real value is itself an admissible shift.
* As a cross-check, Bridge VII's T0 separation re-derives instantly from the
  formula (`weightSupEDist_eq_zero_iff_eq`).

The metric content of the entire persistence-stability arc thus collapses to a
single, sharp, closed form: **persistence is an isometry, not merely a
contraction.**

## Main results

* `interleaved_iff_weightCloseBy` — interleaving = uniform weight closeness.
* `weightSupEDist` — the extended sup-distance of two weight functions.
* `weightSupEDist_le_eInterleavingDist` / `eInterleavingDist_le_weightSupEDist` —
  the two halves of the isometry.
* `eInterleavingDist_eq_weightSupEDist` — **the isometry formula** (Direction 1).
* `weightSupEDist_eq_zero_iff_eq` — T0 separation, recovered from the formula.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingClosure

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

-- !-- Forward: from `Interleaved F G δ`, evaluate `h.2.1` at `t = F.weight σ` and
-- !-- `h.2.2` at `t = G.weight σ` to get `G.weight σ ≤ F.weight σ + δ` and
-- !-- `F.weight σ ≤ G.weight σ + δ`, then `abs_sub_le_iff`.  Backward: this is
-- !-- exactly `stability_supDist`. -- !--
/-- **Interleaving is exactly uniform closeness of the weights.**  Two filtrations
are `δ`-interleaved iff `δ ≥ 0` and their weight functions are uniformly within `δ`
in sup-norm.  This is the quantitative converse of `stability_supDist`, and at
`δ = 0` it is Bridge VII's `interleaved_zero_iff_weight_eq`. -/
theorem interleaved_iff_weightCloseBy (F G : Filtration α) (δ : ℝ) :
    Interleaved F G δ ↔ 0 ≤ δ ∧ WeightCloseBy F G δ := by
  -- By definition of Interleaved, we have that F and G are δ-interleaved if and only if for every time t, F.sublevelFaces t is a subset of G.sublevelFaces (t + δ) and vice versa.
  rw [Filtration.Interleaved];
  constructor <;> intro h <;> simp_all +decide [ Set.subset_def, Filtration.mem_sublevelFaces ];
  · exact fun σ => abs_sub_le_iff.mpr ⟨ by linarith [ h.2.1 ( F.weight σ ) σ le_rfl, h.2.2 ( G.weight σ ) σ le_rfl ], by linarith [ h.2.1 ( F.weight σ ) σ le_rfl, h.2.2 ( G.weight σ ) σ le_rfl ] ⟩;
  · exact ⟨ fun t x hx => by linarith [ abs_le.mp ( h.2 x ) ], fun t x hx => by linarith [ abs_le.mp ( h.2 x ) ] ⟩

/-- **The extended sup-distance of two weight functions**: the supremum over all
simplices of the `ℝ≥0∞`-valued gap `ENNReal.ofReal |F.weight σ - G.weight σ|`.
The index type `Finset α` is always nonempty (it contains `∅`). -/
noncomputable def weightSupEDist (F G : Filtration α) : ℝ≥0∞ :=
  ⨆ σ : Finset α, ENNReal.ofReal |F.weight σ - G.weight σ|

-- !-- `eInterleavingDist` is `⨅` over witnesses `δ`; for each witness,
-- !-- `interleaved_iff_weightCloseBy` gives `|F.weight σ - G.weight σ| ≤ δ` for all
-- !-- `σ`, so `ofReal |…| ≤ ofReal δ`; `iSup_le` then `le_iInf`. -- !--
/-- **Lower half of the isometry.**  The extended sup-distance of the weights is at
most the extended interleaving distance: every interleaving witness dominates every
weight gap. -/
theorem weightSupEDist_le_eInterleavingDist (F G : Filtration α) :
    weightSupEDist F G ≤ eInterleavingDist F G := by
  refine le_iInf fun δ => ?_
  have h_weightCloseBy : WeightCloseBy F G δ :=
    ((interleaved_iff_weightCloseBy F G δ).1 δ.2).2
  exact iSup_le fun σ => ENNReal.ofReal_le_ofReal (h_weightCloseBy σ)

-- !-- If `weightSupEDist F G = ⊤`, the bound is `le_top`.  Otherwise set
-- !-- `c := weightSupEDist F G ≠ ⊤`; for each `σ`, `ofReal |…| ≤ c` (`le_iSup`) gives
-- !-- `|…| ≤ c.toReal`, i.e. `WeightCloseBy F G c.toReal`; with `0 ≤ c.toReal`,
-- !-- `stability_supDist` yields `Interleaved F G c.toReal`, and `eInterleavingDist_le`
-- !-- gives `≤ ofReal c.toReal = c` (`ENNReal.ofReal_toReal`). -- !--
/-- **Upper half of the isometry (attained infimum).**  The extended interleaving
distance is at most the extended sup-distance of the weights: when the sup is
finite its real value is itself an admissible interleaving shift. -/
theorem eInterleavingDist_le_weightSupEDist (F G : Filtration α) :
    eInterleavingDist F G ≤ weightSupEDist F G := by
  by_cases h : F.weightSupEDist G = ⊤;
  · exact h.symm ▸ le_top;
  · have h_weightCloseBy : ∀ σ : Finset α, |F.weight σ - G.weight σ| ≤ (F.weightSupEDist G).toReal := by
      intro σ
      have h_abs : ENNReal.ofReal |F.weight σ - G.weight σ| ≤ F.weightSupEDist G := by
        exact le_iSup ( fun σ : Finset α => ENNReal.ofReal |F.weight σ - G.weight σ| ) σ;
      convert ENNReal.toReal_mono h h_abs using 1 ; norm_num;
    convert Filtration.stability_supDist F G ( ENNReal.toReal_nonneg ) h_weightCloseBy |> fun h => Filtration.eInterleavingDist_le F G h using 1;
    rw [ ENNReal.ofReal_toReal h ]

-- !-- `le_antisymm` of the two halves. -- !--
/-- **The isometry formula (Future Direction 1).**  The extended interleaving
distance equals the extended sup-distance of the weight functions:
`eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`.  Hence
`Filtration α` embeds isometrically into `(Finset α → ℝ)` under the sup-distance —
persistence is an isometry, not merely a `1`-Lipschitz contraction. -/
theorem eInterleavingDist_eq_weightSupEDist (F G : Filtration α) :
    eInterleavingDist F G = weightSupEDist F G :=
  le_antisymm (eInterleavingDist_le_weightSupEDist F G)
    (weightSupEDist_le_eInterleavingDist F G)

-- !-- Rewrite via `eInterleavingDist_eq_weightSupEDist` and apply Bridge VII's
-- !-- `eInterleavingDist_eq_zero_iff_eq`. -- !--
/-- **T0 separation, recovered from the formula.**  The extended sup-distance of the
weights vanishes iff the filtrations are equal — a one-line corollary of the
isometry and Bridge VII's `eInterleavingDist_eq_zero_iff_eq`. -/
theorem weightSupEDist_eq_zero_iff_eq (F G : Filtration α) :
    weightSupEDist F G = 0 ↔ F = G := by
  rw [← eInterleavingDist_eq_weightSupEDist, eInterleavingDist_eq_zero_iff_eq]

end Filtration

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridge V proved only one inequality (`eInterleavingDist_le_supDist`: weight gap
bounds distance) and Bridge VII proved the boundary case (distance `0` ⇔ equal
weights).  The adversarial hypothesis: the boundary case is the shadow of a full
quantitative isometry — the interleaving distance is *exactly* the sup-distance of
the weights, with the defining infimum attained at every scale, not just `0`.

## Result
Confirmed.  The key engine is `interleaved_iff_weightCloseBy`: an interleaving of
shift `δ` is *exactly* uniform `δ`-closeness of the weights (the converse of
`stability_supDist`, proved by evaluating the sublevel inclusions at the two birth
times).  This collapses `eInterleavingDist` to an infimum of sup-norm bounds, and
the attained-infimum argument (`eInterleavingDist_le_weightSupEDist`) plus the
witness-domination argument (`weightSupEDist_le_eInterleavingDist`) give the exact
formula `eInterleavingDist F G = ⨆ σ, ENNReal.ofReal |F.weight σ - G.weight σ|`
(`eInterleavingDist_eq_weightSupEDist`).  Bridge VII's T0 separation drops out as a
one-liner (`weightSupEDist_eq_zero_iff_eq`).

## Insight
The whole metric theory of persistence stability is a *closed form*, not a chain of
one-sided estimates.  The single nontrivial step is the converse of CESH stability,
and it is elementary: the sublevel order encodes the weight order exactly, so
"sublevel families `δ`-shift into each other" is literally "weights are `δ`-close".
Moving to `ℝ≥0∞` makes the `⨆/⨅` duality unconditional (the `⊤` case is automatic),
so the isometry holds with no boundedness hypothesis.

## Failure analysis
The formula is an *extended* isometry: the sup can be `⊤` (unbounded weight gap),
which is correct (`eInterleavingDist = ⊤` exactly when no interleaving exists).  The
remaining frontier is *realising* the sup for the Vietoris–Rips functor — turning
`⨆ σ` over simplices into `⨆ x y` over the underlying distance matrices — which
needs the diameter sup to be attained at a single edge; that is deferred to a future
direction.  The collapse also rests on the codomain `ℝ` being Archimedean (via the
`abs_sub_le_iff` step), exactly the load-bearing hypothesis isolated by Bridge VII.
-/

end BoltzmannBridge