/-
# The Boltzmann Bridge VII — Closing the Kernel: the Interleaving Distance is a *Metric*

This file discharges **Future Direction 1** of Boltzmann Bridge VI
(`Applications.BoltzmannBridge.InterleavingQuotient`), and in doing so *corrects*
the central pessimistic claim of Bridges V and VI.

## The arc so far

* **IV — `BottleneckStability`**: the relational interleaving preorder
  (`Interleaved`, `Interleaved_refl/symm/mono/trans`) and the real-valued
  `interleavingDist`.
* **V — `InterleavingMetric`**: the `ℝ≥0∞`-valued `eInterleavingDist` and the
  representation theorem `interleavingPseudoEMetric : PseudoEMetricSpace
  (Filtration α)`.  Its Lab Notebook recorded an *honest defect*: "distinct
  filtrations can sit at distance `0`", so the structure is "only a *pseudo*metric".
* **VI — `InterleavingQuotient`**: quotients out the alleged distance-`0` kernel
  via Mathlib's `SeparationQuotient`, obtaining a genuine `EMetricSpace`, and
  characterises the kernel as the limiting relation `eInterleavingDist = 0`
  (`eInterleavingDist_eq_zero_iff`).  Its Failure analysis deferred the clean
  algebraic equivalence `eInterleavingDist F G = 0 ↔ Interleaved F G 0` to Future
  Direction 1, "requiring closedness of the witness set `{δ | Interleaved F G δ}`".

## The correction (this file)

The deferred closedness is **true and elementary**, and it has a decisive
consequence the previous bridges missed:

* The witness set `{δ | Interleaved F G δ}` is *closed from the left at its
  infimum*: if `F` and `G` are `ε`-interleaved for **every** `ε > 0`, then they are
  already `0`-interleaved (`interleaved_zero_of_forall_pos`).  The whole content is
  the Archimedean fact `(∀ ε > 0, a ≤ b + ε) → a ≤ b` applied to the weights.
* Therefore `eInterleavingDist F G = 0 ↔ Interleaved F G 0`
  (`eInterleavingDist_eq_zero_iff_interleaved_zero`) — the infimum **is attained**.
* `Interleaved F G 0` says exactly that the two sublevel families coincide at every
  scale (`interleaved_zero_iff_sublevel_eq`), which holds **iff the weight
  functions are equal** (`interleaved_zero_iff_weight_eq`).
* But a `Filtration` is determined by its weight (its other fields are
  propositions), so equal weights mean **equal filtrations** (`ext_weight`).

Chaining these:

> **`eInterleavingDist F G = 0 ↔ F = G`** (`eInterleavingDist_eq_zero_iff_eq`).

In other words, the pseudo-emetric of Bridge V is **already a genuine
`EMetricSpace`** on `Filtration α` itself (`interleavingEMetricDirect`); the
`SeparationQuotient` of Bridge VI is **trivial** — its quotient map is *injective*
(`mk_injective`, `mk_eq_mk_iff_eq`).  The "honest defect" of Bridges V–VI does not
exist: there are *no* distinct filtrations at distance `0`.  The converse that
Bridge VI declared to "fail in general" (`mk_eq_mk_of_interleaved_zero`) in fact
**holds** (`mk_eq_mk_iff_interleaved_zero`).

## Main results

* `ext_weight` — a filtration is determined by its weight function.
* `interleaved_zero_iff_sublevel_eq` / `interleaved_zero_iff_weight_eq` — the
  intrinsic description of `0`-interleaving.
* `interleaved_zero_of_forall_pos` — the deferred closedness (Future Direction 1).
* `eInterleavingDist_eq_zero_iff_interleaved_zero` — the infimum is attained.
* `eInterleavingDist_eq_zero_iff_eq` — **distance `0` ⇔ equality** (T0 separation).
* `interleavingEMetricDirect` — a genuine `EMetricSpace` on `Filtration α` itself.
* `mk_injective`, `mk_eq_mk_iff_eq`, `mk_eq_mk_iff_interleaved_zero` — the Bridge VI
  separation quotient is trivial.
-/
import Mathlib
import Applications.BoltzmannBridge.HigherPersistence
import Applications.BoltzmannBridge.PersistenceStability
import Applications.BoltzmannBridge.BottleneckStability
import Applications.BoltzmannBridge.InterleavingMetric
import Applications.BoltzmannBridge.InterleavingQuotient

open Finset BigOperators
open scoped ENNReal

namespace BoltzmannBridge

namespace Filtration

variable {α : Type*}

/-- The Bridge V pseudo-emetric structure, as a file-local instance, so the Bridge
VI separation-quotient lemmas (`edist_quotient_mk`,
`mk_eq_mk_iff_eInterleavingDist_zero`) are available here. -/
noncomputable local instance interleavingPseudoEMetricInst' :
    PseudoEMetricSpace (Filtration α) :=
  interleavingPseudoEMetric

-- !-- A `Filtration` has a single data field `weight`; its `weight_empty` and
-- !-- `weight_mono` fields are propositions, so `cases`/`congr` closes equality
-- !-- from equality of weights (proof irrelevance). -- !--
/-- **A filtration is determined by its weight.**  Two filtrations with the same
weight function are equal — the remaining fields are propositions. -/
theorem ext_weight {F G : Filtration α} (h : F.weight = G.weight) : F = G := by
  cases F; cases G; cases h; rfl

-- !-- `Interleaved F G 0` is `0 ≤ 0 ∧ (∀ t, F.sub t ⊆ G.sub (t+0)) ∧ (∀ t, G.sub t ⊆
-- !-- F.sub (t+0))`; rewrite `t + 0 = t` and read the two inclusions as set
-- !-- antisymmetry `F.sub t = G.sub t`. -- !--
/-- **`0`-interleaving = pointwise equal sublevel families.**  Two filtrations are
`0`-interleaved exactly when their sublevel complexes coincide at every scale. -/
theorem interleaved_zero_iff_sublevel_eq (F G : Filtration α) :
    Interleaved F G 0 ↔ ∀ t : ℝ, F.sublevelFaces t = G.sublevelFaces t := by
  constructor <;> intro h;
  · intro t; specialize h; have := h.2.1 t; have := h.2.2 t; aesop;
  · exact ⟨ by norm_num, fun t => by simp +decide [ h t ], fun t => by simp +decide [ h t ] ⟩

-- !-- Forward: from `interleaved_zero_iff_sublevel_eq`, for each `σ` evaluate the
-- !-- sublevel equality at `t = F.weight σ` and at `t = G.weight σ` to get
-- !-- `F.weight σ ≤ G.weight σ` and the reverse, hence equality (funext).
-- !-- Backward: equal weights make the sublevel sets `{σ | weight σ ≤ t}` identical. -- !--
/-- **`0`-interleaving = equal weights.**  Two filtrations are `0`-interleaved iff
their weight functions are equal. -/
theorem interleaved_zero_iff_weight_eq (F G : Filtration α) :
    Interleaved F G 0 ↔ F.weight = G.weight := by
  constructor <;> intro h;
  · unfold Filtration.Interleaved at h;
    ext σ; have := h.2.1 ( F.weight σ ) ; have := h.2.2 ( G.weight σ ) ; simp_all +decide [ Set.subset_def, Filtration.mem_sublevelFaces ] ;
    exact le_antisymm ( h.2 _ _ le_rfl ) ( h.1 _ _ le_rfl );
  · exact ⟨ by norm_num, fun t => by simp +decide [ h, Filtration.sublevelFaces ], fun t => by simp +decide [ h, Filtration.sublevelFaces ] ⟩

-- !-- For the nontrivial inclusion direction at scale `t`: `σ ∈ F.sub t` gives
-- !-- `F.weight σ ≤ t`; for every `ε > 0`, `(h ε).2.1 t` yields `G.weight σ ≤ t + ε`,
-- !-- so `le_of_forall_pos_le_add` gives `G.weight σ ≤ t`.  Symmetrically for the
-- !-- other inclusion; `0 ≤ 0` is trivial. -- !--
/-- **Closedness at the infimum (Future Direction 1).**  If two filtrations are
`ε`-interleaved for *every* `ε > 0`, then they are `0`-interleaved.  The only input
is the Archimedean fact `(∀ ε > 0, a ≤ b + ε) → a ≤ b`. -/
theorem interleaved_zero_of_forall_pos (F G : Filtration α)
    (h : ∀ ε : ℝ, 0 < ε → Interleaved F G ε) : Interleaved F G 0 := by
  -- By definition of `Interleaved`, we need to show that `0 ≤ 0` and for all `t`, `F.sublevelFaces t ⊆ G.sublevelFaces (t + 0)` and `G.sublevelFaces t ⊆ F.sublevelFaces (t + 0)`.
  apply And.intro;
  · norm_num;
  · constructor <;> intro t <;> intro σ hσ <;> simp_all +decide [ Filtration.sublevelFaces ];
    · exact le_of_forall_pos_le_add fun ε εpos => by have := h ε εpos; exact this.2.1 t hσ;
    · contrapose! h;
      refine' ⟨ ( F.weight σ - t ) / 2, half_pos ( sub_pos.mpr h ), _ ⟩;
      intro h_interleaved
      have h_contra : F.weight σ ≤ t + (F.weight σ - t) / 2 := by
        exact h_interleaved.2.2 t hσ;
      linarith

-- !-- Backward: `eInterleavingDist_le F G h` with `Interleaved F G 0` gives
-- !-- `≤ ofReal 0 = 0`.  Forward: `eInterleavingDist_eq_zero_iff` gives, for each
-- !-- `ε > 0`, a witness `δ < ε` with `Interleaved F G δ`; since `δ ≥ 0` and `δ < ε`,
-- !-- `Interleaved_mono` upgrades it to `Interleaved F G ε`; then
-- !-- `interleaved_zero_of_forall_pos` concludes. -- !--
/-- **The infimum is attained.**  The extended interleaving distance is `0` iff the
filtrations are *literally* `0`-interleaved — the clean algebraic equivalence
deferred by Bridge VI. -/
theorem eInterleavingDist_eq_zero_iff_interleaved_zero (F G : Filtration α) :
    eInterleavingDist F G = 0 ↔ Interleaved F G 0 := by
  constructor <;> intro h;
  · apply interleaved_zero_of_forall_pos;
    intro ε hε;
    contrapose! h;
    refine' ne_of_gt ( lt_of_lt_of_le _ ( le_iInf fun δ => _ ) );
    exact ENNReal.ofReal_pos.mpr hε;
    exact ENNReal.ofReal_le_ofReal ( le_of_not_gt fun h' => h <| Interleaved_mono δ.2 h'.le );
  · exact le_antisymm ( le_trans ( eInterleavingDist_le F G h ) ( by simp +decide ) ) ( zero_le _ )

/-
!-- Chain `eInterleavingDist_eq_zero_iff_interleaved_zero`,
!-- `interleaved_zero_iff_weight_eq` and `ext_weight` (with `congrArg weight` for
!-- the trivial direction). -- !--

**Distance `0` ⇔ equality.**  The extended interleaving distance separates
points: it is `0` exactly when the filtrations are equal.  Hence the Bridge V
pseudo-emetric is in fact a genuine emetric, and the alleged distance-`0` defect
does not exist.
-/
theorem eInterleavingDist_eq_zero_iff_eq (F G : Filtration α) :
    eInterleavingDist F G = 0 ↔ F = G := by
  rw [ eInterleavingDist_eq_zero_iff_interleaved_zero, interleaved_zero_iff_weight_eq ];
  exact ⟨ fun h => ext_weight h, fun h => h ▸ rfl ⟩

-- !-- Upgrade `interleavingPseudoEMetric` by supplying the `eq_of_edist_eq_zero`
-- !-- field from `eInterleavingDist_eq_zero_iff_eq` (the `edist` of the pseudo
-- !-- structure is `eInterleavingDist` definitionally). -- !--
/-- **A genuine `EMetricSpace` on `Filtration α` itself** — no quotient required.
The interleaving distance makes `Filtration α` an extended metric space. -/
noncomputable def interleavingEMetricDirect : EMetricSpace (Filtration α) :=
  { interleavingPseudoEMetric with
    eq_of_edist_eq_zero := fun {F G} h => (eInterleavingDist_eq_zero_iff_eq F G).mp h }

-- !-- `mk_eq_mk_iff_eInterleavingDist_zero` (Bridge VI) composed with
-- !-- `eInterleavingDist_eq_zero_iff_eq`. -- !--
/-- **The separation quotient is trivial: its map is injective.**  Two filtration
classes coincide in the Bridge VI `SeparationQuotient` iff the filtrations are
equal. -/
theorem mk_eq_mk_iff_eq (F G : Filtration α) :
    (SeparationQuotient.mk F : SeparationQuotient (Filtration α)) = SeparationQuotient.mk G
      ↔ F = G := by
  rw [mk_eq_mk_iff_eInterleavingDist_zero, eInterleavingDist_eq_zero_iff_eq]

-- !-- `mk_eq_mk_iff_eq` says `mk F = mk G ↔ F = G`, i.e. injectivity. -- !--
/-- The Bridge VI quotient map `SeparationQuotient.mk` is injective: the quotient
collapses nothing. -/
theorem mk_injective :
    Function.Injective (SeparationQuotient.mk : Filtration α → SeparationQuotient (Filtration α)) :=
  fun F G h => (mk_eq_mk_iff_eq F G).mp h

-- !-- Compose `mk_eq_mk_iff_eInterleavingDist_zero` (Bridge VI) with
-- !-- `eInterleavingDist_eq_zero_iff_interleaved_zero`. -- !--
/-- **The Bridge VI converse holds.**  `mk_eq_mk_of_interleaved_zero` declared its
converse to "fail in general"; in fact two filtrations are identified in the
separation quotient **iff** they are `0`-interleaved. -/
theorem mk_eq_mk_iff_interleaved_zero (F G : Filtration α) :
    (SeparationQuotient.mk F : SeparationQuotient (Filtration α)) = SeparationQuotient.mk G
      ↔ Interleaved F G 0 := by
  rw [mk_eq_mk_iff_eInterleavingDist_zero, eInterleavingDist_eq_zero_iff_interleaved_zero]

end Filtration

/-
-- !-- Lab Notebook -- !--

## Hypothesis
Bridges V and VI both asserted an "honest defect": the `ℝ≥0∞`-valued interleaving
distance is only a *pseudo*metric because "distinct filtrations can sit at distance
`0`".  Bridge VI deferred the clean equivalence `eInterleavingDist = 0 ↔
Interleaved 0` to a future "closedness of the witness set" argument.  The
adversarial hypothesis: that defect is illusory, the deferred closedness is
elementary, and the distance is in fact a genuine metric that separates points.

## Result
Confirmed, and stronger than expected.  The deferred closedness
(`interleaved_zero_of_forall_pos`) is exactly `le_of_forall_pos_le_add` applied to
the weight functions.  It yields `eInterleavingDist F G = 0 ↔ Interleaved F G 0`
(`..._iff_interleaved_zero`), and since `Interleaved F G 0` means equal sublevel
families (`interleaved_zero_iff_sublevel_eq`) ⇔ equal weights
(`interleaved_zero_iff_weight_eq`) ⇔ equal filtrations (`ext_weight`), we obtain
`eInterleavingDist F G = 0 ↔ F = G` (`eInterleavingDist_eq_zero_iff_eq`).  Hence
`Filtration α` is a genuine `EMetricSpace` (`interleavingEMetricDirect`) and the
Bridge VI `SeparationQuotient` map is injective (`mk_injective`, `mk_eq_mk_iff_eq`),
with the converse Bridge VI called "failing in general" actually holding
(`mk_eq_mk_iff_interleaved_zero`).

## Insight
The infimum defining `eInterleavingDist` *is attained* because the witness set is
upward closed (`Interleaved_mono`) and closed from the left at its infimum (the
Archimedean squeeze on weights).  An attained infimum at `0` plus the structural
fact that a `Filtration` is its weight collapses the entire pseudometric/quotient
apparatus of Bridges V–VI: the `T0` separation is automatic, so no quotient is
needed.  The earlier "defect" was an artefact of stopping at the limiting
characterisation instead of pushing the squeeze through.

## Failure analysis
The genuine boundary condition is *where* this collapse fails.  It fails the moment
the weight space is not Archimedean/Hausdorff in the relevant sense, or the index
of `Filtration` carries extra non-propositional data: then equal sublevel families
no longer force equal objects and a real distance-`0` kernel can appear.  For these
specific `ℝ`-weighted `Filtration`s, though, the kernel is provably empty.  The
remaining open question (Future Direction) is the *quantitative* refinement: is the
attained `0`-interleaving the boundary of a genuine *isometry* onto a sup-metric on
weight functions, i.e. `eInterleavingDist F G = ENNReal.ofReal ‖F.weight - G.weight‖`?
-/

end BoltzmannBridge