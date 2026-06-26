import Mathlib

/-!
# Certified Novelty Detection — the theorem embedding space

This file builds the metric core of a **novelty certification system** for an automated
research engine.  Each *known* result (a catalog entry) is mapped to a point of a metric
space `X` — the **theorem embedding space**.  The set of known points is a `Finset X`, the
*catalog* `C`.  The **novelty** of a candidate output `x` is its distance to the closest
catalog point,

  `novelty C x = min_{c ∈ C} dist x c`.

A **novelty certificate at level `ε`** is a proof that `ε ≤ novelty C x` with `ε > 0`.  The
slogan *"distance bounds novelty"* is made precise here: a certificate is *sound*
(`x` is genuinely outside the catalog), *separating* (`x` is `ε`-far from every known
result), and *stable* (novelty is `1`-Lipschitz, so a small embedding error cannot turn a
certified-novel output into a duplicate).  Monotonicity records that learning more theorems
can only lower novelty.

## Main results

* `novelty_le_dist`, `exists_eq_novelty` — `novelty` really is the minimum distance.
* `cert_sound` — a positive novelty certificate proves `x ∉ C`: *no false novelty*.
* `cert_separation` — an `ε`-certificate proves `x` is `ε`-far from **every** catalog entry.
* `novelty_le_add`, `lipschitz_novelty`, `abs_novelty_sub_le` — novelty is `1`-Lipschitz:
  *distance bounds the change in novelty*, the central robustness guarantee.
* `novelty_mono` — extending the catalog can only decrease novelty.
* `novelty_insert` — the recursive update law for an incremental catalog.

-- !-- Lab Notes -- !--
-- !-- Hypothesis: novelty defined as min-distance to a finite catalog is a *sound* and
--     *robust* certificate of genuine newness: positive distance ⇒ not already known, and
--     the certificate is stable under bounded embedding perturbations. -- !--
-- !-- Experiment: formalized `novelty` via `Finset.inf'` over a `PseudoMetricSpace`, then
--     proved soundness (`cert_sound`), separation (`cert_separation`), 1-Lipschitz
--     stability (`lipschitz_novelty`/`abs_novelty_sub_le`), monotonicity, and the
--     incremental update law (`novelty_insert`). -- !--
-- !-- Analysis: the Lipschitz bound is the load-bearing result — it is what makes a
--     *numerically computed* embedding distance a *certificate*: an embedding error of
--     size `δ` moves novelty by at most `δ`, so a certificate with margin `> δ` survives.
--     It is exactly the classical fact that distance-to-a-set is 1-Lipschitz, here for a
--     finite set, proved from `dist_triangle` + the minimizer `exists_eq_novelty`. -- !--
-- !-- Critique: `novelty` is only meaningful for a *nonempty* catalog (the empty min is
--     `+∞`); we carry the nonemptiness proof explicitly rather than picking a junk value,
--     keeping every statement honest. A `PseudoMetricSpace` (not `MetricSpace`) is used so
--     that distinct theorems with identical embeddings are correctly reported as
--     *non-novel* (`novelty = 0`), the conservative choice for a certifier. -- !--
-/

namespace NoveltyCertification

open Finset

variable {X : Type*} [PseudoMetricSpace X]

/-- The **novelty** of a candidate point `x` relative to a nonempty catalog `C`: the
minimum distance from `x` to a catalog entry. -/
noncomputable def novelty (C : Finset X) (hC : C.Nonempty) (x : X) : ℝ :=
  C.inf' hC (fun c => dist x c)

variable {C D : Finset X} {c x y : X} {ε : ℝ}

/-
Novelty is nonnegative.
-/
theorem novelty_nonneg (hC : C.Nonempty) (x : X) : 0 ≤ novelty C hC x := by
  exact le_trans ( by positivity ) ( Finset.le_inf' _ _ fun a ha => show dist x a ≥ 0 from dist_nonneg )

/-
Novelty is at most the distance to any specific catalog entry.
-/
theorem novelty_le_dist (hC : C.Nonempty) (hc : c ∈ C) (x : X) :
    novelty C hC x ≤ dist x c := by
  exact Finset.inf'_le _ hc

/-
The minimum is attained: some catalog entry realizes the novelty distance.
-/
theorem exists_eq_novelty (hC : C.Nonempty) (x : X) :
    ∃ c ∈ C, dist x c = novelty C hC x := by
  obtain ⟨c, hc⟩ : ∃ c ∈ C, ∀ d ∈ C, dist x c ≤ dist x d := by
    exact Finset.exists_min_image _ _ hC;
  exact ⟨ c, hc.1, le_antisymm ( by exact Finset.le_inf' _ _ hc.2 ) ( Finset.inf'_le _ hc.1 ) ⟩

/-
A lower bound on every catalog distance is a lower bound on novelty.
-/
theorem le_novelty (hC : C.Nonempty) (x : X) (h : ∀ c ∈ C, ε ≤ dist x c) :
    ε ≤ novelty C hC x := by
  convert Finset.le_inf' _ _ _ using 1;
  exact h

/-
**Soundness of the certificate**: positive novelty proves `x` is not already in the
catalog — the system never falsely certifies a known result as novel.
-/
theorem cert_sound (hC : C.Nonempty) (h : 0 < novelty C hC x) : x ∉ C := by
  contrapose! h;
  exact le_trans ( novelty_le_dist hC h x ) ( by simp +decide )

/-
**Separation guarantee**: an `ε`-novelty certificate proves `x` is at distance at least
`ε` from *every* catalog entry.
-/
theorem cert_separation (hC : C.Nonempty) (h : ε ≤ novelty C hC x) :
    ∀ c ∈ C, ε ≤ dist x c := by
  exact fun c hc => h.trans ( NoveltyCertification.novelty_le_dist hC hc x )

/-
**Lipschitz stability (additive form)**: moving the embedding from `y` to `x` changes
novelty by at most `dist x y`.
-/
theorem novelty_le_add (hC : C.Nonempty) (x y : X) :
    novelty C hC x ≤ novelty C hC y + dist x y := by
  obtain ⟨ c, hc, h ⟩ := exists_eq_novelty hC y;
  exact le_trans ( novelty_le_dist hC hc x ) ( by rw [ ← h, add_comm ] ; exact dist_triangle _ _ _ )

/-
**1-Lipschitz stability**: `|novelty x - novelty y| ≤ dist x y`.  A bounded embedding
error perturbs the certified novelty by at most the same bound.
-/
theorem abs_novelty_sub_le (hC : C.Nonempty) (x y : X) :
    |novelty C hC x - novelty C hC y| ≤ dist x y := by
  rw [ abs_sub_le_iff ];
  constructor <;> linarith [ NoveltyCertification.novelty_le_add hC x y, NoveltyCertification.novelty_le_add hC y x, dist_comm x y ]

/-
Novelty is a `1`-Lipschitz function of the candidate point.
-/
theorem lipschitz_novelty (hC : C.Nonempty) : LipschitzWith 1 (novelty C hC) := by
  exact LipschitzWith.mk_one fun x y => by simpa using abs_novelty_sub_le hC x y;

/-
**Monotonicity**: enlarging the catalog can only *decrease* novelty.  Learning more
known results makes genuine novelty harder, never easier, to certify.
-/
theorem novelty_mono (hC : C.Nonempty) (hCD : C ⊆ D) (x : X) :
    novelty D (hC.mono hCD) x ≤ novelty C hC x := by
  obtain ⟨ c, hc ⟩ := exists_eq_novelty hC x;
  exact hc.2 ▸ Finset.inf'_le _ ( hCD hc.1 )

/-
**Incremental update law**: adding one theorem `a` to the catalog updates novelty by a
single `min` against the distance to `a`.
-/
theorem novelty_insert [DecidableEq X] (hC : C.Nonempty) (a : X) (x : X) :
    novelty (insert a C) (by exact insert_nonempty a C) x
      = min (dist x a) (novelty C hC x) := by
  by_cases ha : a ∈ C <;> simp_all +decide [ NoveltyCertification.novelty ];
  exact ⟨ a, ha, le_rfl ⟩

end NoveltyCertification