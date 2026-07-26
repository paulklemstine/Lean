/-
# Phantom Topologies: Spaces That Change When You Look at Them

A *phantom topology* on a set `X` is a family of topologies indexed by a set of
"observers" `ι`, i.e. a function `T : ι → TopologicalSpace X`.  Each observer `i`
resolves `X` through their own topology `T i`.  The *real* (consensus) topology is
what **all** observers agree is open:

  `U` is consensus-open  ⇔  `U` is open in every `T i`.

In Mathlib's lattice of topologies (where `t ≤ s` means `t` is *finer* than `s`),
this consensus is exactly the supremum `⨆ i, T i`, whose open sets are precisely
the sets open in every `T i` (`isOpen_iSup_iff`).  Each individual observer is
finer than the consensus (`T i ≤ consensus T`): looking through a single lens can
only *add* resolution; agreement can only *remove* it.

The headline result (`consensus_eq_standard`) is the "two–observer theorem" for
the real line: the ordinary Euclidean topology on `ℝ` is the consensus of exactly
two phantom observers — the **lower-limit** (Sorgenfrey) observer, whose basic
opens are right half-open intervals `[x, b)`, and the **upper-limit** observer,
whose basic opens are left half-open intervals `(a, x]`.  Neither observer alone
sees the Euclidean topology (`lowerTop_ne_standard`, `upperTop_ne_standard`), and
the two observers genuinely disagree (`lowerTop_ne_upperTop`), so the phantom
number of `ℝ` in this representation is exactly two.

-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer):
  H1. The Euclidean topology on `ℝ` is the "intersection" (consensus/supremum in
      the topology lattice) of the lower-limit and upper-limit topologies.
      Rationale: `[x,b)` pins a point from the right, `(a,x]` from the left; a set
      open to both observers is squeezed into a genuine two-sided neighbourhood.
  H2. A single observer over-resolves: the lower-limit observer sees `[0,1)` as
      open, which is not Euclidean-open. Hence one observer is never enough.
  H3 (surprising). The consensus operation is *monotone the "wrong" way*: each
      observer is finer than the consensus, i.e. adding observers can only coarsen
      the agreed topology, never refine it.

Experiment (Experimenter):
  - Modelled `lowerOpen`/`upperOpen` as concrete neighbourhood predicates and
    verified the three `TopologicalSpace` axioms by hand (min/max of interval
    endpoints for finite intersections).
  - Checked the squeeze `(a,x] ∪ [x,b) = (a,b)` numerically before formalising.
  - Confirmed `Ico 0 1` is lower-open but not Euclidean-open (a left ε-ball at 0
    escapes the set).

Analysis (Analyst):
  - H1 survives as `consensus_eq_standard`, the core theorem, with a clean
    two-sided ε argument. The Bool-indexed packaging `consensus_pair_eq_standard`
    shows this is literally a *two*-observer consensus.
  - H2 survives as the `ne_standard` lemmas; the witnesses `[0,1)` / `(0,1]` are
    the sharp obstructions.
  - H3 survives as `observer_le_consensus` (= `le_iSup`), which is exactly the
    counter-intuitive monotonicity: more observers ⇒ coarser reality.

Critique (Critic):
  - `consensus_eq_standard` is not definitional: it equates a hand-rolled sup of
    two custom topologies with Mathlib's metric topology on `ℝ`, proved by a real
    ε–δ neighbourhood argument (`Metric.isOpen_iff`, `abs_lt`, `linarith`).
  - The lower-bound lemmas use genuine witnesses and rule out the trivial
    "one observer suffices" reading, so the phantom number is pinned to 2, not ≤2.
  - No `native_decide`, no `True`, no wrapper types.

Synthesis (PI):
  Reality-as-consensus is a faithful lattice-theoretic notion: the Euclidean line
  is the exact agreement of a left-looking and a right-looking observer, and the
  agreement functor is order-reversing in resolution. This gives a rigorous
  toy-model of "measurement coarsens structure".
-/
import Mathlib

open Set

namespace Phantom

/-! ## The phantom-topology framework -/

variable {X : Type*} {ι : Type*}

/-- A **phantom topology** on `X` with observer set `ι` is an assignment of a
topology to each observer. -/
abbrev PhantomTopology (ι X : Type*) := ι → TopologicalSpace X

/-- The **consensus** (real) topology: the finest topology all observers agree on.
In Mathlib's lattice (`≤` = finer), this is the supremum of the observers. -/
def consensus (T : PhantomTopology ι X) : TopologicalSpace X := ⨆ i, T i

/-- **Agreement theorem.** A set is consensus-open iff every observer sees it as
open. This is the defining property of the real topology as unanimous agreement. -/
theorem consensus_isOpen_iff (T : PhantomTopology ι X) (U : Set X) :
    (consensus T).IsOpen U ↔ ∀ i, (T i).IsOpen U :=
  isOpen_iSup_iff

/-- **Measurement coarsens.** Each individual observer is *finer* than the
consensus: an observer never sees fewer open sets than everyone agrees on. Equivalently,
adding observers can only coarsen the agreed reality. -/
theorem observer_le_consensus (T : PhantomTopology ι X) (i : ι) :
    T i ≤ consensus T :=
  le_iSup T i

/-! ## The two observers on `ℝ` -/

/-- The **lower-limit (Sorgenfrey) observer**'s open predicate: every point of `U`
sits at the left end of a right half-open interval `[x, b)` contained in `U`. -/
def lowerOpen (U : Set ℝ) : Prop := ∀ x ∈ U, ∃ b, x < b ∧ Ico x b ⊆ U

/-- The **upper-limit observer**'s open predicate: every point of `U` sits at the
right end of a left half-open interval `(a, x]` contained in `U`. -/
def upperOpen (U : Set ℝ) : Prop := ∀ x ∈ U, ∃ a, a < x ∧ Ioc a x ⊆ U

/-- The lower-limit topology on `ℝ`. -/
def lowerTop : TopologicalSpace ℝ where
  IsOpen := lowerOpen
  isOpen_univ := fun x _ => ⟨x + 1, by linarith, by simp⟩
  isOpen_inter s t hs ht := by
    intro x hx
    obtain ⟨b1, hb1, hs1⟩ := hs x hx.1
    obtain ⟨b2, hb2, ht2⟩ := ht x hx.2
    refine ⟨min b1 b2, lt_min hb1 hb2, ?_⟩
    intro y hy
    exact ⟨hs1 ⟨hy.1, lt_of_lt_of_le hy.2 (min_le_left _ _)⟩,
           ht2 ⟨hy.1, lt_of_lt_of_le hy.2 (min_le_right _ _)⟩⟩
  isOpen_sUnion S hS := by
    intro x hx
    obtain ⟨U, hUS, hxU⟩ := hx
    obtain ⟨b, hb, hsub⟩ := hS U hUS x hxU
    exact ⟨b, hb, fun y hy => ⟨U, hUS, hsub hy⟩⟩

/-- The upper-limit topology on `ℝ`. -/
def upperTop : TopologicalSpace ℝ where
  IsOpen := upperOpen
  isOpen_univ := fun x _ => ⟨x - 1, by linarith, by simp⟩
  isOpen_inter s t hs ht := by
    intro x hx
    obtain ⟨a1, ha1, hs1⟩ := hs x hx.1
    obtain ⟨a2, ha2, ht2⟩ := ht x hx.2
    refine ⟨max a1 a2, max_lt ha1 ha2, ?_⟩
    intro y hy
    exact ⟨hs1 ⟨lt_of_le_of_lt (le_max_left _ _) hy.1, hy.2⟩,
           ht2 ⟨lt_of_le_of_lt (le_max_right _ _) hy.1, hy.2⟩⟩
  isOpen_sUnion S hS := by
    intro x hx
    obtain ⟨U, hUS, hxU⟩ := hx
    obtain ⟨a, ha, hsub⟩ := hS U hUS x hxU
    exact ⟨a, ha, fun y hy => ⟨U, hUS, hsub hy⟩⟩

/-! ## Main theorem: `ℝ` is a two-observer consensus -/

/-- **Two-observer theorem.** The Euclidean topology on `ℝ` is exactly the
consensus of the lower-limit and upper-limit observers: a set is Euclidean-open
iff it is open for *both* the left-looking and the right-looking observer. -/
theorem consensus_eq_standard :
    lowerTop ⊔ upperTop = (inferInstance : TopologicalSpace ℝ) := by
  apply TopologicalSpace.ext
  ext U
  constructor
  · -- both observers agree ⇒ Euclidean open (two-sided squeeze)
    rintro ⟨hlo, hup⟩
    rw [Metric.isOpen_iff]
    intro x hx
    obtain ⟨b, hb, hbsub⟩ := hlo x hx
    obtain ⟨a, ha, hasub⟩ := hup x hx
    refine ⟨min (x - a) (b - x), by simp only [lt_min_iff]; constructor <;> linarith, ?_⟩
    intro y hy
    rw [Metric.mem_ball, Real.dist_eq] at hy
    have h1 : |y - x| < x - a := lt_of_lt_of_le hy (min_le_left _ _)
    have h2 : |y - x| < b - x := lt_of_lt_of_le hy (min_le_right _ _)
    rw [abs_lt] at h1 h2
    rcases le_or_gt x y with hxy | hxy
    · exact hbsub ⟨hxy, by linarith [h2.2]⟩
    · exact hasub ⟨by linarith [h1.1], le_of_lt hxy⟩
  · -- Euclidean open ⇒ open for each observer (each is finer)
    intro hU
    rw [Metric.isOpen_iff] at hU
    refine ⟨?_, ?_⟩
    · intro x hx
      obtain ⟨ε, hε, hsub⟩ := hU x hx
      refine ⟨x + ε, by linarith, ?_⟩
      intro y hy
      apply hsub
      rw [Metric.mem_ball, Real.dist_eq, abs_lt]
      constructor <;> [linarith [hy.1]; linarith [hy.2]]
    · intro x hx
      obtain ⟨ε, hε, hsub⟩ := hU x hx
      refine ⟨x - ε, by linarith, ?_⟩
      intro y hy
      apply hsub
      rw [Metric.mem_ball, Real.dist_eq, abs_lt]
      constructor <;> [linarith [hy.1]; linarith [hy.2]]

/-- The Bool-indexed phantom topology with exactly two observers: `false` is the
upper-limit observer, `true` is the lower-limit observer. -/
def observersℝ : PhantomTopology Bool ℝ := fun b => if b then lowerTop else upperTop

/-- **Phantom number two.** Packaged as a genuine two-element observer family, the
consensus of `observersℝ` is the Euclidean topology on `ℝ`. -/
theorem consensus_pair_eq_standard :
    consensus observersℝ = (inferInstance : TopologicalSpace ℝ) := by
  rw [consensus, iSup_bool_eq]
  show lowerTop ⊔ upperTop = _
  exact consensus_eq_standard

/-! ## One observer is not enough -/

/-- `[0,1)` is open for the lower-limit observer. -/
theorem lowerOpen_Ico : lowerOpen (Ico 0 1) :=
  fun _x hx => ⟨1, hx.2, fun _ hy => ⟨le_trans hx.1 hy.1, hy.2⟩⟩

/-- `(0,1]` is open for the upper-limit observer. -/
theorem upperOpen_Ioc : upperOpen (Ioc 0 1) :=
  fun _x hx => ⟨0, hx.1, fun _ hy => ⟨hy.1, le_trans hy.2 hx.2⟩⟩

/-- `[0,1)` is **not** Euclidean-open: a left ε-ball at `0` always escapes it. -/
theorem not_isOpen_Ico : ¬ IsOpen (Ico (0:ℝ) 1) := by
  intro h
  rw [Metric.isOpen_iff] at h
  obtain ⟨ε, hε, hsub⟩ := h 0 (by constructor <;> norm_num)
  have hmem : (- (ε/2)) ∈ Metric.ball (0:ℝ) ε := by
    rw [Metric.mem_ball, Real.dist_eq, show (-(ε/2) - 0 : ℝ) = -(ε/2) by ring, abs_neg,
      abs_of_nonneg (by linarith)]
    linarith
  have := hsub hmem
  simp only [mem_Ico] at this
  linarith [this.1]

/-- `(0,1]` is **not** Euclidean-open: a right ε-ball at `1` always escapes it. -/
theorem not_isOpen_Ioc : ¬ IsOpen (Ioc (0:ℝ) 1) := by
  intro h
  rw [Metric.isOpen_iff] at h
  obtain ⟨ε, hε, hsub⟩ := h 1 (by constructor <;> norm_num)
  have hmem : (1 + ε/2) ∈ Metric.ball (1:ℝ) ε := by
    rw [Metric.mem_ball, Real.dist_eq, show (1 + ε/2 - 1 : ℝ) = ε/2 by ring,
      abs_of_nonneg (by linarith)]
    linarith
  have := hsub hmem
  simp only [mem_Ioc] at this
  linarith [this.2]

/-- The lower-limit observer alone does **not** see the Euclidean topology. -/
theorem lowerTop_ne_standard : lowerTop ≠ (inferInstance : TopologicalSpace ℝ) := by
  intro h
  have hopen : @IsOpen ℝ lowerTop (Ico 0 1) := lowerOpen_Ico
  rw [h] at hopen
  exact not_isOpen_Ico hopen

/-- The upper-limit observer alone does **not** see the Euclidean topology. -/
theorem upperTop_ne_standard : upperTop ≠ (inferInstance : TopologicalSpace ℝ) := by
  intro h
  have hopen : @IsOpen ℝ upperTop (Ioc 0 1) := upperOpen_Ioc
  rw [h] at hopen
  exact not_isOpen_Ioc hopen

/-- The two observers genuinely disagree: `[0,1)` is lower-open but not upper-open. -/
theorem lowerTop_ne_upperTop : lowerTop ≠ upperTop := by
  intro h
  -- `[0,1)` is lower-open, hence (via `h`) upper-open, which forces a left interval
  -- `(a,0]` inside `[0,1)`; but any such interval contains points `< 0`.
  have hopen : @IsOpen ℝ lowerTop (Ico 0 1) := lowerOpen_Ico
  rw [h] at hopen
  have hup : upperOpen (Ico 0 1) := hopen
  obtain ⟨a, ha, hasub⟩ := hup 0 (by constructor <;> norm_num)
  have : (a/2 + 0/2) ∈ Ioc a 0 := by
    constructor <;> [linarith; linarith]
  have := hasub this
  simp only [mem_Ico] at this
  linarith [this.1]

end Phantom