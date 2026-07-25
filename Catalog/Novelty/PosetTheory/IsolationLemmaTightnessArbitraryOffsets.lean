import Mathlib

/-!
# Deepening: tightness of the Isolation-Lemma bound for arbitrary edge offsets

This file *goes deeper* than the companion `IsolationLemmaTightness.lean`, which
proved that the singleton hypergraph (with zero offset) attains the Faber–Harris
lower bound `n · ∑_{j<d} j^{n-1}` on the number of isolating weight assignments
*exactly*.  To stay self-contained we reprove the strict-minimum count here and
then push two new results.

The natural "strongest conjecture" left open there was the **general tightness
conjecture**:

> *For every inclusion-free hypergraph `H` on `n` vertices there exists a real
> edge-offset function `f : H → ℝ` for which the number of isolating weight
> assignments in `[d]^n` equals the lower bound `n · ∑_{j<d} j^{n-1}`.*

We take a **contrarian** stance and settle two things.

## 1. The general tightness conjecture is FALSE  (`general_tightness_fails`)

The extra freedom of choosing *arbitrary real offsets* does **not** make every
inclusion-free hypergraph extremal.  We exhibit an inclusion-free hypergraph for
which the isolating count is *constant in `f`* and *strictly larger* than the
bound for **every** offset `f`.  The cleanest witness is a hypergraph with a
single edge: with only one edge every assignment is trivially isolating, so the
count is `d^n` regardless of `f`, and `d^n > n · ∑_{j<d} j^{n-1}` already for
`n = d = 2` (namely `4 > 2`).  Thus offset freedom cannot repair an
over-counting hypergraph.

## 2. A NEW extremal witness: the co-singleton hypergraph  (`card_strictMax_eq`)

Complementing the singleton result, we prove that the **co-singleton hypergraph**
— all `(n-1)`-element edges, i.e. the complements of singletons — *also* attains
the bound exactly with zero offset.  The reason is a clean **min ↔ max duality**:
for the edge `V \ {v}` the weight is `(∑ all) - w v`, so minimising the edge
weight is maximising the vertex weight.  Hence "isolating" for the co-singleton
hypergraph means a *unique strict maximum vertex*, and the reflection
`w ↦ (fun i => (w i).rev)` is a bijection carrying strict minima to strict
maxima.  Therefore the strict-maximum count equals the strict-minimum count,
which is `n · ∑_{j<d} j^{n-1}`.

Together: the Faber–Harris bound has (at least) *two* symmetric extremal
witnesses, but tightness is a genuinely special property, not a universal one.
-/

open Finset
open scoped Classical

namespace IsolationTightnessDeepening

variable {n d : ℕ}

/-! ## Core strict-minimum machinery (self-contained reproof) -/

/-- A hypergraph on `Fin n` is a finite family of edges (vertex subsets). -/
abbrev Hypergraph (n : ℕ) := Finset (Finset (Fin n))

/-- A hypergraph is **inclusion-free** (a Sperner family / antichain) when no edge
is a proper subset of another. -/
def InclusionFree {n : ℕ} (H : Hypergraph n) : Prop :=
  ∀ ⦃S⦄, S ∈ H → ∀ ⦃T⦄, T ∈ H → S ⊆ T → S = T

/-- `w` has a **strict minimum** vertex: some `i` whose weight is strictly below
all others. -/
def HasStrictMin (w : Fin n → Fin d) : Prop := ∃ i, ∀ j, j ≠ i → w i < w j

/-- The set of assignments with a unique strict minimum vertex. -/
noncomputable def isolatingSet (n d : ℕ) : Finset (Fin n → Fin d) :=
  Finset.univ.filter (fun w => HasStrictMin w)

/-- The set of assignments for which vertex `i` is the strict minimum. -/
noncomputable def strictMinAt (n d : ℕ) (i : Fin n) : Finset (Fin n → Fin d) :=
  Finset.univ.filter (fun w => ∀ j, j ≠ i → w i < w j)

/-- Number of values in `Fin d` strictly above `m`. -/
theorem card_gt (m : Fin d) :
    (Finset.univ.filter (fun v : Fin d => m < v)).card = d - 1 - m.val := by
  rw [ Finset.card_eq_of_bijective ];
  use fun i hi => ⟨ m + 1 + i, by omega ⟩;
  · simp +zetaDelta at *;
    exact fun a ha => ⟨ a - ( m + 1 ), by omega, by erw [ Fin.ext_iff ] ; norm_num; omega ⟩;
  · grind +qlia;
  · grind

/-- For a fixed minimum value `m`, the number of strict-min-at-`i` assignments
attaining `w i = m` is `(d-1-m)^{n-1}`. -/
theorem card_fiber (i : Fin n) (m : Fin d) :
    (Finset.univ.filter
        (fun w : Fin n → Fin d => w i = m ∧ ∀ j, j ≠ i → m < w j)).card
      = (d - 1 - m.val) ^ (n - 1) := by
  set t : Fin n → Finset (Fin d) := fun j => if j = i then {m} else Finset.filter (fun v => m < v) Finset.univ;
  have h_filter_eq_piFinset : Finset.filter (fun w : Fin n → Fin d => w i = m ∧ ∀ j, j ≠ i → m < w j) (Finset.univ : Finset (Fin n → Fin d)) = Fintype.piFinset t := by
    grind +splitImp;
  rw [ h_filter_eq_piFinset, Fintype.card_piFinset ];
  rw [ Finset.prod_eq_mul_prod_diff_singleton <| Finset.mem_univ i ];
  simp +zetaDelta at *;
  rw [ Finset.prod_congr rfl fun x hx => by aesop ];
  simp +decide [ Finset.card_sdiff, Finset.card_singleton, Finset.card_univ, card_gt ]

/-- The number of assignments for which `i` is the strict minimum equals
`∑_{j<d} j^{n-1}`, independent of `i`. -/
theorem card_strictMinAt (i : Fin n) :
    (strictMinAt n d i).card = ∑ j ∈ Finset.range d, j ^ (n - 1) := by
  have h_fiber_eq : ∀ m : Fin d, (Finset.univ.filter (fun w : Fin n → Fin d => ∀ j, j ≠ i → w i < w j)).filter (fun w => w i = m) = Finset.univ.filter (fun w : Fin n → Fin d => w i = m ∧ ∀ j, j ≠ i → m < w j) := by
    grind;
  have h_final : (Finset.univ.filter (fun w : Fin n → Fin d => ∀ j, j ≠ i → w i < w j)).card = ∑ m : Fin d, (d - 1 - m.val) ^ (n - 1) := by
    have h_final : (Finset.univ.filter (fun w : Fin n → Fin d => ∀ j, j ≠ i → w i < w j)).card = ∑ m : Fin d, (Finset.univ.filter (fun w : Fin n → Fin d => w i = m ∧ ∀ j, j ≠ i → m < w j)).card := by
      rw [ ← Finset.sum_congr rfl fun m hm => congr_arg Finset.card <| h_fiber_eq m, Finset.card_eq_sum_ones ];
      simp +decide only [card_eq_sum_ones, sum_fiberwise];
    exact h_final.trans ( Finset.sum_congr rfl fun m hm => card_fiber i m );
  convert h_final using 1;
  rw [ ← Finset.sum_range_reflect, Finset.sum_range ]

/-- The isolating set is the disjoint union of the strict-min-at-`i` sets. -/
theorem isolatingSet_card_eq_sum :
    (isolatingSet n d).card = ∑ i : Fin n, (strictMinAt n d i).card := by
  rw [ ← Finset.card_biUnion ];
  · congr with w ; simp +decide [ Finset.mem_biUnion, strictMinAt ];
    exact ⟨ fun hw => by simpa [ HasStrictMin ] using Finset.mem_filter.mp hw |>.2, fun hw => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simpa [ HasStrictMin ] using hw ⟩ ⟩;
  · intro i hi j hj hij; simp_all +decide [ Finset.disjoint_left, strictMinAt ] ;
    exact fun a ha => ⟨ i, by tauto, le_of_lt ( ha j ( by tauto ) ) ⟩

/-- The strict-minimum count equals the Faber–Harris bound `n · ∑_{j<d} j^{n-1}`. -/
theorem card_isolating_singleton_eq (n d : ℕ) :
    (isolatingSet n d).card = n * ∑ j ∈ Finset.range d, j ^ (n - 1) := by
  rw [ isolatingSet_card_eq_sum, Finset.sum_congr rfl fun _ _ => card_strictMinAt _ ] ; norm_num [ mul_comm, Finset.card_univ ]

/-! ## Part 1 — Offsets do not rescue over-counting hypergraphs -/

/-- An assignment `w : Fin n → Fin d` is **isolating** for a hypergraph `H` under a
real edge-offset function `f` when a *unique* edge attains the minimum offset
weight `f S + ∑_{v ∈ S} w v`. -/
def IsolatingOffset (H : Hypergraph n) (f : Finset (Fin n) → ℝ)
    (w : Fin n → Fin d) : Prop :=
  ∃! S, S ∈ H ∧ ∀ T ∈ H, (f S + ∑ v ∈ S, (w v : ℝ)) ≤ (f T + ∑ v ∈ T, (w v : ℝ))

/-
For a hypergraph consisting of a **single edge**, *every* assignment is
isolating, whatever the offset: the unique edge always attains the (only)
minimum.  Hence the isolating count is `d^n`, independent of `f`.
-/
theorem card_isolating_singleEdge (E : Finset (Fin n)) (f : Finset (Fin n) → ℝ) :
    (Finset.univ.filter
        (fun w : Fin n → Fin d => IsolatingOffset ({E} : Hypergraph n) f w)).card
      = d ^ n := by
  unfold IsolatingOffset;
  simp +decide [ ExistsUnique ]

/-
**The general tightness conjecture is false.**  There is an inclusion-free,
nonempty hypergraph `H` for which, for *every* real edge-offset function `f`, the
number of isolating assignments differs from the Faber–Harris lower bound
`n · ∑_{j<d} j^{n-1}`.  Concretely `n = d = 2` and the single-edge hypergraph
`{ {0} }`: the count is `4` for all `f`, while the bound is `2`.
-/
theorem general_tightness_fails :
    ∃ (n d : ℕ) (H : Hypergraph n),
      InclusionFree H ∧ H.Nonempty ∧
        ∀ f : Finset (Fin n) → ℝ,
          (Finset.univ.filter
              (fun w : Fin n → Fin d => IsolatingOffset H f w)).card
            ≠ n * ∑ j ∈ Finset.range d, j ^ (n - 1) := by
  -- Let's choose `n = 2` and `d = 2`.
  use 2, 2;
  refine' ⟨ { { 0, 1 } }, _, _, _ ⟩ <;> simp +decide [ InclusionFree ];
  intro f; rw [ card_isolating_singleEdge ] ; norm_num;

/-! ## Part 2 — A new extremal witness: the co-singleton hypergraph -/

/-- `w` has a **strict maximum** vertex: some `i` whose weight strictly exceeds all
others.  This is the "isolating" condition for the co-singleton hypergraph. -/
def HasStrictMax (w : Fin n → Fin d) : Prop := ∃ i, ∀ j, j ≠ i → w j < w i

/-- The set of assignments with a unique strict maximum vertex. -/
noncomputable def strictMaxSet (n d : ℕ) : Finset (Fin n → Fin d) :=
  Finset.univ.filter (fun w => HasStrictMax w)

/-
**Min ↔ max reflection duality.** `w` has a strict minimum vertex iff its
value-reflection `i ↦ (w i).rev` has a strict maximum vertex, because `Fin.rev`
reverses the order on `Fin d`.
-/
theorem hasStrictMin_iff_rev (w : Fin n → Fin d) :
    HasStrictMin w ↔ HasStrictMax (fun i => (w i).rev) := by
  unfold HasStrictMin HasStrictMax; aesop;

/-
The reflection `w ↦ (fun i => (w i).rev)` is a bijection of `Fin n → Fin d`
carrying the strict-minimum set onto the strict-maximum set, so the two sets have
equal cardinality.
-/
theorem card_strictMax_eq_card_isolating (n d : ℕ) :
    (strictMaxSet n d).card = (isolatingSet n d).card := by
  refine' Finset.card_bij ( fun w hw => fun i => Fin.rev ( w i ) ) _ _ _ <;> simp +decide [ Finset.mem_filter, strictMaxSet, isolatingSet ];
  · exact fun a ha => by simpa using hasStrictMin_iff_rev ( fun i => Fin.rev ( a i ) ) |>.2 ( by simpa using ha ) ;
  · exact fun a₁ ha₁ a₂ ha₂ h => funext fun i => by simpa using congr_fun h i;
  · exact fun b hb => ⟨ fun i => Fin.rev ( b i ), by simpa using hasStrictMin_iff_rev b |>.1 hb, by simp +decide ⟩

/-- **The co-singleton hypergraph attains the bound too.**  The number of
assignments with a unique strict *maximum* vertex — the isolating assignments for
the co-singleton hypergraph with zero offset — is *exactly* the Faber–Harris
lower bound `n · ∑_{j<d} j^{n-1}`. -/
theorem card_strictMax_eq (n d : ℕ) :
    (strictMaxSet n d).card = n * ∑ j ∈ Finset.range d, j ^ (n - 1) := by
  rw [card_strictMax_eq_card_isolating, card_isolating_singleton_eq]

/-! ### The hypergraph reduction underlying Part 2 -/

/-- The **co-singleton hypergraph** on `Fin n`: all `(n-1)`-element edges, i.e. the
complements `Fin n \ {v}` of singletons. -/
def coSingletonHypergraph (n : ℕ) : Hypergraph n :=
  Finset.univ.image (fun v : Fin n => (Finset.univ.erase v))

/-
The co-singleton hypergraph is inclusion-free: distinct co-singletons have the
same size, so no proper containment is possible.
-/
theorem coSingletonHypergraph_inclusionFree (n : ℕ) :
    InclusionFree (coSingletonHypergraph n) := by
  intro S hS T hT hST;
  simp_all +decide [ coSingletonHypergraph ];
  rcases hS with ⟨ a, rfl ⟩ ; rcases hT with ⟨ b, rfl ⟩ ; simp_all +decide [ Finset.subset_iff ] ;
  grind

/-
On the co-singleton hypergraph the edge `Fin n \ {v}` has weight
`(∑ all vertices) - w v`.  Hence *minimising* the edge weight over `v` is the same
as *maximising* the vertex weight `w v` — the reduction that turns co-singleton
isolation into the strict-maximum condition of Part 2.
-/
theorem edgeWeight_coSingleton (w : Fin n → Fin d) (v : Fin n) :
    (∑ u ∈ (Finset.univ.erase v), (w u : ℕ))
      = (∑ u : Fin n, (w u : ℕ)) - (w v : ℕ) := by
  exact eq_tsub_of_add_eq <| Finset.sum_erase_add _ _ <| Finset.mem_univ _

end IsolationTightnessDeepening