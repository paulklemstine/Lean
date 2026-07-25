import Mathlib

/-!
# Forcing edges of perfect matchings, via fixed-point-free involutions

This file develops a small, self-contained theory of **forcing edges** of perfect
matchings, motivated by the structural theory of *bricks* and *b-invariant edges*
in matching theory (de Carvalho–Lucchesi–Murty; Lovász).  An edge `e` of a graph
`G` is a **forcing edge** if there is exactly one perfect matching of `G` that
contains `e`.  Equivalently, `e = uv` is forcing precisely when the graph obtained
by deleting `u` and `v` has a *unique* perfect matching — this is the classical
deletion characterisation, and it is our main theorem (`forcing_iff_unique_deletion`).

## Model

A perfect matching of a simple graph `G` is modelled as a **fixed-point-free
involution** `f : V → V` all of whose swapped pairs `{v, f v}` are edges of `G`
(`IsPM`).  This turns "the perfect matching containing `uv`" into "the involution
`f` with `f u = v`", which is very convenient for reasoning about uniqueness.

Deleting the two endpoints `u, v` of an edge is modelled by `IsPMdel`: an
involution that fixes exactly `u` and `v` and matches every other vertex to a
neighbour distinct from `u, v`.

## Main results

* `IsPM.apply_ne` — matched partners of interior vertices avoid `u, v`.
* `restrictPM_isPMdel` / `extendPM_isPM` — the deletion bijection.
* `uniquePM_all_forcing` — if `G` has a unique perfect matching, every one of its
  edges is forcing.
* `forcing_iff_unique_deletion` — **main theorem**: `uv` is forcing iff `uv` is an
  edge and `G - u - v` has a unique perfect matching.
* `forcing_comm` — forcing is a symmetric relation on the endpoints.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The property "`uv` lies in a unique perfect matching"
should be *local*: it should depend only on the perfect matchings of the graph
with `u, v` deleted. Concretely, deleting the endpoints of a forcing edge must
leave a graph with a unique perfect matching, and conversely.

Experiment (Experimenter): Modelling perfect matchings as fixed-point-free
involutions makes "the matching containing `uv`" literally the constraint
`f u = v`. The map `f ↦ (f restricted to V \ {u,v})` and its inverse `extend`
form a bijection between {perfect matchings with `f u = v`} and {perfect matchings
of the deleted graph}. We verified the bijection laws on paper for the swap/fix
pattern before formalising.

Analysis (Analyst): The only non-trivial input is that in any perfect matching
containing `uv`, no interior vertex is matched to `u` or `v` (`IsPM.apply_ne`);
this is exactly injectivity of the involution. Everything else is bookkeeping of
the if-then-else definitions of `restrict`/`extend`.

Critique (Critic): The `u ≠ v` side condition is essential; it is supplied for
free by `G.Adj u v` (loopless graphs). The theorem is non-vacuous: `uniquePM`
graphs (e.g. a single edge, or a path) exhibit genuine forcing edges.

Synthesis (PI): The deletion characterisation is the engine behind the paper's
analysis of which b-invariant edges are forcing; here it is captured cleanly and
proved in full generality (no finiteness assumption).
-- !-- Lab Notes -- !--
-/

namespace ForcingEdges

open Function

variable {V : Type*}

/-- `f` is a perfect matching of `G`: a fixed-point-free involution whose swapped
pairs are edges of `G`. -/
def IsPM (G : SimpleGraph V) (f : V → V) : Prop :=
  Involutive f ∧ (∀ v, f v ≠ v) ∧ (∀ v, G.Adj v (f v))

/-- The edge `uv` is a **forcing edge**: it is an edge, and there is exactly one
perfect matching of `G` containing it (i.e. one involution `f` with `f u = v`). -/
def Forcing (G : SimpleGraph V) (u v : V) : Prop :=
  G.Adj u v ∧ ∃! f, IsPM G f ∧ f u = v

/-- `h` is a perfect matching of `G` with the two vertices `u, v` deleted: it fixes
exactly `u` and `v`, and matches every other vertex to a neighbour `≠ u, v`. -/
def IsPMdel (G : SimpleGraph V) (u v : V) (h : V → V) : Prop :=
  Involutive h ∧ h u = u ∧ h v = v ∧
    ∀ w, w ≠ u → w ≠ v → (h w ≠ w ∧ G.Adj w (h w) ∧ h w ≠ u ∧ h w ≠ v)

/-
In a perfect matching containing the edge `uv`, no interior vertex is matched
to `u` or to `v`.
-/
theorem IsPM.apply_ne {G : SimpleGraph V} {f : V → V} (hf : IsPM G f) {u v : V}
    (huv : f u = v) {w : V} (hwu : w ≠ u) (hwv : w ≠ v) :
    f w ≠ u ∧ f w ≠ v := by
  have := hf.1 w; have := hf.1 u; aesop;

/-- Restriction of a matching `f` to the graph with `u, v` deleted: fix `u, v`,
keep everything else. -/
def restrictPM [DecidableEq V] (u v : V) (f : V → V) : V → V :=
  fun w => if w = u then u else if w = v then v else f w

/-- Extension of a deleted matching `h` back to `G` by swapping `u ↔ v`. -/
def extendPM [DecidableEq V] (u v : V) (h : V → V) : V → V :=
  fun w => if w = u then v else if w = v then u else h w

theorem restrictPM_isPMdel [DecidableEq V] {G : SimpleGraph V} {f : V → V}
    (hf : IsPM G f) {u v : V} (huv : f u = v) (hne : u ≠ v) :
    IsPMdel G u v (restrictPM u v f) := by
  have := hf.1;
  refine' ⟨ _, _, _, _ ⟩ <;> simp_all +decide [ Involutive, restrictPM ];
  · grind +ring;
  · exact fun w hwu hwv => ⟨ hf.2.1 w, hf.2.2 w, by have := IsPM.apply_ne hf huv hwu hwv; tauto, by have := IsPM.apply_ne hf huv hwu hwv; tauto ⟩

theorem extendPM_isPM [DecidableEq V] {G : SimpleGraph V} {u v : V} {h : V → V}
    (hh : IsPMdel G u v h) (hadj : G.Adj u v) :
    IsPM G (extendPM u v h) ∧ extendPM u v h u = v := by
  constructor;
  · refine' ⟨ _, _, _ ⟩;
    · intro w; unfold extendPM; by_cases hwu : w = u <;> by_cases hwv : w = v <;> simp +decide [ * ] ;
      have := hh.2.2.2 w hwu hwv; split_ifs <;> simp_all +decide ;
      exact hh.1 _;
    · intro w; cases eq_or_ne w u <;> cases eq_or_ne w v <;> simp_all +decide [ extendPM ] ;
      · grind +splitImp;
      · grind;
      · exact hh.2.2.2 w ‹_› ‹_› |>.1;
    · intro w; by_cases hwu : w = u <;> by_cases hwv : w = v <;> simp_all +decide [ extendPM ] ;
      · exact hadj.symm;
      · exact hh.2.2.2 w hwu hwv |>.2.1;
  · unfold extendPM; aesop;

theorem restrictPM_extendPM [DecidableEq V] {G : SimpleGraph V} {u v : V} {h : V → V}
    (hh : IsPMdel G u v h) (hne : u ≠ v) :
    restrictPM u v (extendPM u v h) = h := by
  funext w; cases eq_or_ne w u <;> cases eq_or_ne w v <;> simp_all +decide [ restrictPM, extendPM ] ;
  · exact hh.2.1.symm;
  · exact hh.2.2.1.symm

theorem extendPM_restrictPM [DecidableEq V] {G : SimpleGraph V} {f : V → V}
    (hf : IsPM G f) {u v : V} (huv : f u = v) (hne : u ≠ v) :
    extendPM u v (restrictPM u v f) = f := by
  funext w; by_cases hw : w = u <;> by_cases hw' : w = v <;> simp_all +decide [ extendPM, restrictPM ] ;
  have := hf.1 u; aesop;

/-
**Deletion characterisation of forcing edges.**  The edge `uv` is a forcing
edge of `G` iff `uv ∈ E(G)` and the graph with `u, v` deleted has a *unique*
perfect matching.
-/
theorem forcing_iff_unique_deletion [DecidableEq V] (G : SimpleGraph V) (u v : V) :
    Forcing G u v ↔ G.Adj u v ∧ ∃! h, IsPMdel G u v h := by
  constructor <;> intro h;
  · obtain ⟨hadj, f₀, hf₀⟩ := h;
    refine' ⟨ hadj, restrictPM u v f₀, _, _ ⟩;
    · exact restrictPM_isPMdel hf₀.1.1 hf₀.1.2 hadj.ne;
    · intro h hh;
      have := hf₀.2 ( extendPM u v h ) ?_;
      · rw [ ← this, restrictPM_extendPM hh hadj.ne ];
      · exact extendPM_isPM hh hadj;
  · obtain ⟨hadj, ⟨h₀, ⟨hpmdel₀, huniq⟩⟩⟩ := h;
    use hadj;
    use extendPM u v h₀;
    constructor;
    · exact extendPM_isPM hpmdel₀ hadj;
    · intro f hf;
      rw [ ← huniq ( restrictPM u v f ) ( restrictPM_isPMdel hf.1 hf.2 ( hadj.ne ) ), extendPM_restrictPM hf.1 hf.2 ( hadj.ne ) ]

/-
If `G` has a unique perfect matching `f₀`, then every edge `{v, f₀ v}` of that
matching is a forcing edge.
-/
theorem uniquePM_all_forcing {G : SimpleGraph V} {f₀ : V → V} (hpm : IsPM G f₀)
    (huniq : ∀ g, IsPM G g → g = f₀) (v : V) : Forcing G v (f₀ v) := by
  constructor;
  · exact hpm.2.2 v;
  · exact ⟨ f₀, ⟨ hpm, rfl ⟩, fun g hg => huniq g hg.1 ⟩

/-
Forcing is symmetric in the two endpoints of the edge.
-/
theorem forcing_comm {G : SimpleGraph V} {u v : V} :
    Forcing G u v ↔ Forcing G v u := by
  by_cases h : ∃! f, IsPM G f ∧ f u = v <;> simp_all +decide [ Forcing ];
  · obtain ⟨ f, hf, hf' ⟩ := h;
    refine' ⟨ fun h => ⟨ h.symm, f, ⟨ hf.1, _ ⟩, _ ⟩, _ ⟩;
    · have := hf.1.1 u; aesop;
    · intro g hg; specialize hf' g; simp_all +decide [ IsPM ] ;
      exact hf' ( by have := hg.1.1 v; aesop );
    · exact fun h => h.1.symm;
  · exact fun _ => fun ⟨ f, hf1, hf2 ⟩ => h ⟨ f, by
      exact ⟨ hf1.1, by simpa [ hf1.2 ] using hf1.1.1 v ⟩, by
      intro g hg; have := hf2 g; simp_all +decide [ IsPM ] ;
      exact hf2 g hg.1.1 hg.1.2.1 hg.1.2.2 ( by have := hg.1.1 u; aesop ) ⟩

end ForcingEdges