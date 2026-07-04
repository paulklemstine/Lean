/-
# The Zariski Affine Line has Phantom Number Two (Concrete Refutation)

This file is the concrete `ℝ`-instantiation of the general cofinite result
`Catalog.Novelty.PhantomCofiniteZariski`, delivering the exact test proposed by the
phantom-topology programme: the **Zariski topology on the affine line** and its phantom
number.

Over an infinite field the Zariski topology on `𝔸¹` is exactly the cofinite topology, so we
take `zariskiLine := cofiniteTop ℝ` as the Zariski topology on the real affine line.  The
original conjecture proposed the Zariski topology "requires at least 3 observers"; we refute
this concretely and pin the number to **two**:

* `zariskiLine_phantom_number_two` — the Zariski line is the consensus of a genuine
  two-observer phantom representation (each observer strictly finer than reality), obtained
  by splitting `ℝ = Iic 0 ⊔ Ioi 0` and taking the two cofinite-within-half observers.
* `zariskiLine_not_metrizable` — the Zariski line is not metrizable (it is not Hausdorff).
* `zariskiLine_ne_euclidean` and `euclidean_lt_zariskiLine` — the Zariski line is a genuinely
  *different, strictly coarser* reality than the Euclidean line studied in the catalog, yet
  both have phantom number two.  Two distinct realities on the same carrier `ℝ`, each the
  agreement of two sharper observers.

-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer):
  H1. The Zariski affine line over `ℝ` (= cofinite topology on `ℝ`) has phantom number 2,
      not ≥ 3, witnessed by the partition `ℝ = Iic 0 ⊔ Ioi 0`.
  H2 (surprising). The Euclidean line and the Zariski line are two *different* realities on
      the same set `ℝ`, both reconstructible from exactly two observers — the phantom number
      does not distinguish them, but the consensus topologies are strictly comparable
      (Euclidean strictly finer than Zariski).

Experiment (Experimenter):
  - Checked `Iic 0` and `Ioi 0` are both infinite in `ℝ`, so the general split applies.
  - Confirmed `(0,1)` is Euclidean-open but not cofinite-open (its complement is infinite),
    so Euclidean ≠ Zariski and, since every cofinite set is Euclidean-open, Euclidean is
    strictly finer.

Analysis (Analyst):
  - H1 survives as `zariskiLine_phantom_number_two` (instantiating `cofinite_genuine_two_rep`
    at `S = Iic 0`) together with the catalog collapse (`no_topology_requires_three`).
  - H2 survives as `zariskiLine_ne_euclidean` and `euclidean_lt_zariskiLine`.
  - Uses the catalog: the general cofinite theorems, `phantom_reducible_iff`, and the
    Euclidean instance on `ℝ`.

Critique (Critic):
  - Nothing is definitional: the phantom-number statement routes through the general split
    and the catalog collapse; the strict comparison with Euclidean is a real openness
    argument (`(0,1)` witness).  No `native_decide`, no `True`, no wrapper types.

Synthesis (PI):
  On the real line two different realities coexist — the Euclidean line and the Zariski line
  — and each is the two-fold agreement of strictly sharper observers.  The Zariski line does
  not need three observers: the conjectured barrier is false on the very space that inspired
  it.
-/
import Mathlib
import Catalog.Novelty.PhantomTopology
import Catalog.Novelty.PhantomTopologyCollapse
import Catalog.Novelty.PhantomCofiniteZariski

open Set

namespace Phantom

/-- The **Zariski topology on the affine line** `𝔸¹(ℝ)`: over an infinite field this is the
cofinite topology (closed sets = finite sets and the whole line). -/
def zariskiLine : TopologicalSpace ℝ := cofiniteTop ℝ

/-- **The Zariski affine line has phantom number two.**  The cofinite (Zariski) topology on
`ℝ` is the consensus of a genuine finite phantom representation with two strictly-finer
observers, obtained from the partition `ℝ = Iic 0 ⊔ Ioi 0`.  Together with the catalog
collapse principle (`no_topology_requires_three`), the phantom number is exactly two — the
"requires ≥ 3 observers" conjecture is false on the affine line. -/
theorem zariskiLine_phantom_number_two :
    ∃ (k : ℕ) (T : Fin k → TopologicalSpace ℝ),
      2 ≤ k ∧ consensus T = zariskiLine ∧ ∀ i, T i < zariskiLine := by
  have hS : (Set.Iic (0:ℝ)).Infinite := Set.Iic_infinite 0
  have hSc : (Set.Iic (0:ℝ))ᶜ.Infinite := by rw [Set.compl_Iic]; exact Set.Ioi_infinite 0
  exact cofinite_genuine_two_rep (Set.Iic (0:ℝ)) hS hSc

/-- Any genuine finite phantom representation of the Zariski line — with any number `k ≥ 2`
of strictly-finer observers — collapses to a genuine two-observer one (catalog collapse
principle).  Hence its phantom number is never more than two. -/
theorem zariskiLine_never_needs_three {k : ℕ} (h2 : 2 ≤ k)
    (T : Fin k → TopologicalSpace ℝ) (hcon : consensus T = zariskiLine)
    (hlt : ∀ i, T i < zariskiLine) :
    ∃ S : Fin 2 → TopologicalSpace ℝ, consensus S = zariskiLine ∧ ∀ i, S i < zariskiLine :=
  finite_collapses_to_two zariskiLine T h2 hcon hlt

/-- **The Zariski line is not metrizable.** -/
theorem zariskiLine_not_metrizable :
    ¬ @TopologicalSpace.MetrizableSpace ℝ zariskiLine :=
  cofinite_not_metrizable

/-- The Zariski line is `T₁`: points are closed (zero loci of degree-one polynomials). -/
theorem zariskiLine_t1 : @T1Space ℝ zariskiLine :=
  cofinite_t1

/-! ## Zariski vs. Euclidean: two distinct phantom-number-two realities on `ℝ` -/

/-- The open interval `(0,1)` is open in the Euclidean topology but **not** in the Zariski
line (its complement is infinite and it is nonempty). -/
theorem euclidean_Ioo_not_zariskiOpen : ¬ zariskiLine.IsOpen (Set.Ioo (0:ℝ) 1) := by
  rw [zariskiLine, cofiniteTop]
  rintro (h | h)
  · exact (Set.nonempty_Ioo.2 (by norm_num)).ne_empty h
  · -- (Ioo 0 1)ᶜ ⊇ Ici 1, which is infinite
    have hsub : Set.Ici (1:ℝ) ⊆ (Set.Ioo (0:ℝ) 1)ᶜ := by
      intro x hx
      simp only [Set.mem_Ici] at hx
      simp only [Set.mem_compl_iff, Set.mem_Ioo, not_and, not_lt]
      intro _; linarith
    exact (Set.Infinite.mono hsub (Set.Ici_infinite (1:ℝ))) h

/-- **Zariski ≠ Euclidean.**  The Zariski line and the Euclidean line are genuinely different
topologies on `ℝ`. -/
theorem zariskiLine_ne_euclidean :
    zariskiLine ≠ (inferInstance : TopologicalSpace ℝ) := by
  intro h
  have : zariskiLine.IsOpen (Set.Ioo (0:ℝ) 1) := by
    rw [h]; exact isOpen_Ioo
  exact euclidean_Ioo_not_zariskiOpen this

/-- **Euclidean is strictly finer than Zariski.**  Every cofinite set is Euclidean-open, so
the Euclidean topology refines the Zariski line; and `(0,1)` shows the refinement is strict.
Thus on `ℝ` the Euclidean and Zariski lines are two *distinct, strictly comparable* realities,
each with phantom number two. -/
theorem euclidean_lt_zariskiLine :
    (inferInstance : TopologicalSpace ℝ) < zariskiLine := by
  refine lt_of_le_of_ne ?_ (Ne.symm zariskiLine_ne_euclidean)
  rw [TopologicalSpace.le_def]
  intro U hU
  rcases hU with rfl | hUf
  · exact isOpen_empty
  · -- cofinite ⇒ complement finite ⇒ Euclidean-closed complement ⇒ U Euclidean-open
    rw [← isClosed_compl_iff]
    exact hUf.isClosed

end Phantom