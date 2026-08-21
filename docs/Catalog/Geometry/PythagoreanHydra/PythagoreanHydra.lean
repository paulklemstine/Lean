import Catalog.Geometry.PythagoreanHydra.BerggrenDescent
import Catalog.Geometry.PythagoreanHydra.HydraGame

/-!
# The Pythagorean Hydra

Hercules fights a hydra whose heads are **primitive Pythagorean triples**.  He chops one
head off; the hydra retaliates by regrowing finitely many heads, each of which is a
*Berggren ancestor* of the chopped head — i.e. obtained from it by a non-empty sequence of
inverse Berggren moves (`invA`, `invB`, `invC`, packaged in `PythHydra.parent`).  The
regrowth therefore follows the branching of the Berggren tree exactly, and the only head
that cannot retaliate is the root `(3,4,5)` (and, more generally, any head of hypotenuse
`≤ 5`).

Main results.

* `PythHydra.pythagorean_hydra_terminates` — Hercules always wins: no infinite battle,
  for arbitrary (even unbounded) regrowth.
* `PythHydra.pythagorean_hydra_length_le` — with branching bound `k`, every battle from
  `H` lasts at most `Phi k (H.map lvl)` moves, and this is attained
  (`longest_play_eq`), so the game length is *exactly* the potential.
* `PythHydra.pythagorean_hydra_elementary_bound` — an explicit elementary bound
  `N ≤ card H * (k+1)^(L+1)` where `L` bounds the hypotenuses.
* `PythHydra.root_battle_bound` — a completely concrete instance: a battle starting from
  the single head `(3,4,5)` with branching bound `3` lasts at most `364` moves.

**Calibration (the mission's "if false" branch).**  The Pythagorean Hydra is a *flat*
hydra: the Berggren descent assigns each head an ordinal `< ω` (its hypotenuse, or its
depth in the tree), so the whole game lives at `ω^ω` and its termination is proved here
by an explicit primitive recursive potential.  This is provably weaker than the
Kirby–Paris hydra, whose heads carry `ε₀`-many ordinals because regrowth may *copy
subtrees of unbounded height*.  In the Berggren tree the regrowth is always **downward**
(towards `(3,4,5)`), which is what caps the strength.  A Kirby–Paris phenomenon on the
Berggren tree therefore cannot arise from the descent structure alone: one would need a
regrowth rule producing heads of *greater* Berggren depth, which the inverse Berggren
moves never do.
-/

namespace PythHydra

/-- A head of the Pythagorean Hydra. -/
abbrev Tri := ℤ × ℤ × ℤ

/-- The level of a head: its hypotenuse. -/
def lvl (t : Tri) : ℕ := t.2.2.toNat

/-- One inverse-Berggren step: `s` is the Berggren parent of the (non-root) triple `t`. -/
def ParentStep (s t : Tri) : Prop :=
  IsPPT t.1 t.2.1 t.2.2 ∧ 5 < t.2.2 ∧ s = parent t.1 t.2.1 t.2.2

/-- `s` is a Berggren ancestor of `t`: reachable from `t` by inverse Berggren moves. -/
def IsBergAncestor (s t : Tri) : Prop := Relation.TransGen ParentStep s t

theorem parentStep_lvl_lt {s t : Tri} (h : ParentStep s t) : lvl s < lvl t := by
  obtain ⟨hppt, hc, rfl⟩ := h
  have h1 : (parent t.1 t.2.1 t.2.2).2.2 < t.2.2 := parent_hyp_lt hppt
  have h2 : 0 < (parent t.1 t.2.1 t.2.2).2.2 := hh_pos hppt
  simp only [lvl]
  omega

/-- Berggren ancestors have strictly smaller hypotenuse: **the descent is well-founded**. -/
theorem ancestor_lvl_lt {s t : Tri} (h : IsBergAncestor s t) : lvl s < lvl t := by
  induction h with
  | single hst => exact parentStep_lvl_lt hst
  | tail _ hstep ih => exact lt_trans ih (parentStep_lvl_lt hstep)

/-- The parent of a non-root Berggren triple is one of its ancestors. -/
theorem parent_isBergAncestor {a b c : ℤ} (h : IsPPT a b c) (hc : 5 < c) :
    IsBergAncestor (parent a b c) (a, b, c) :=
  Relation.TransGen.single ⟨h, hc, rfl⟩

/-- **The Pythagorean Hydra move.**  A head `t` is chopped and at most `k` heads regrow,
each one a Berggren ancestor of `t`. -/
inductive BergChop (k : ℕ) : Multiset Tri → Multiset Tri → Prop
  | chop (t : Tri) (H R : Multiset Tri) (hR : ∀ s ∈ R, IsBergAncestor s t)
      (hcard : Multiset.card R ≤ k) : BergChop k (t ::ₘ H) (R + H)

/-- The same move with no bound on the number of regrown heads. -/
inductive BergChopU : Multiset Tri → Multiset Tri → Prop
  | chop (t : Tri) (H R : Multiset Tri) (hR : ∀ s ∈ R, IsBergAncestor s t) :
      BergChopU (t ::ₘ H) (R + H)

theorem bergChop_map {k : ℕ} {H H' : Multiset Tri} (h : BergChop k H H') :
    HydraStep k (H.map lvl) (H'.map lvl) := by
  obtain ⟨t, H₀, R, hR, hcard⟩ := h
  simp only [Multiset.map_cons, Multiset.map_add]
  refine HydraStep.chop (lvl t) (H₀.map lvl) (R.map lvl) ?_ ?_
  · intro x hx
    obtain ⟨s, hs, rfl⟩ := Multiset.mem_map.mp hx
    exact ancestor_lvl_lt (hR s hs)
  · simpa using hcard

theorem bergChopU_map {H H' : Multiset Tri} (h : BergChopU H H') :
    HydraStepU (H.map lvl) (H'.map lvl) := by
  obtain ⟨t, H₀, R, hR⟩ := h
  simp only [Multiset.map_cons, Multiset.map_add]
  refine HydraStepU.chop (lvl t) (H₀.map lvl) (R.map lvl) ?_
  intro x hx
  obtain ⟨s, hs, rfl⟩ := Multiset.mem_map.mp hx
  exact ancestor_lvl_lt (hR s hs)

/-- A battle of exactly `N` moves. -/
def Battle (k : ℕ) : ℕ → Multiset Tri → Multiset Tri → Prop
  | 0, H, H' => H = H'
  | (n + 1), H, H' => ∃ M, BergChop k H M ∧ Battle k n M H'

theorem battle_to_stepsTo {k : ℕ} : ∀ (N : ℕ) (H H' : Multiset Tri),
    Battle k N H H' → StepsTo k N (H.map lvl) (H'.map lvl) := by
  intro N
  induction N with
  | zero => intro H H' h; rw [h]; rfl
  | succ n ih =>
    rintro H H' ⟨M, hstep, hrest⟩
    exact ⟨M.map lvl, bergChop_map hstep, ih M H' hrest⟩

/-- **Length bound for the Pythagorean Hydra.**  Every battle with branching bound `k`
is at most `Phi k` of the initial hydra long. -/
theorem pythagorean_hydra_length_le {k N : ℕ} {H H' : Multiset Tri} (h : Battle k N H H') :
    N ≤ Phi k (H.map lvl) :=
  play_length_le (battle_to_stepsTo N H H' h)

/-- **Explicit elementary bound.**  If every head has hypotenuse at most `L`, a battle
with branching bound `k` lasts at most `card H * (k+1)^(L+1)` moves. -/
theorem pythagorean_hydra_elementary_bound {k N L : ℕ} {H H' : Multiset Tri}
    (hL : ∀ t ∈ H, t.2.2 ≤ (L : ℤ)) (h : Battle k N H H') :
    N ≤ Multiset.card H * (k + 1) ^ (L + 1) := by
  have hmap : ∀ x ∈ H.map lvl, x ≤ L := by
    intro x hx
    obtain ⟨t, ht, rfl⟩ := Multiset.mem_map.mp hx
    have := hL t ht
    simp only [lvl]
    omega
  have := play_length_elementary_bound hmap (battle_to_stepsTo N H H' h)
  simpa using this

/-- **Hercules always wins**, even against unbounded regrowth: there is no infinite
battle against the Pythagorean Hydra. -/
theorem pythagorean_hydra_terminates (f : ℕ → Multiset Tri)
    (hf : ∀ i, BergChopU (f i) (f (i + 1))) : False :=
  no_infinite_playU (fun i => (f i).map lvl) (fun i => bergChopU_map (hf i))

/-- The maximal battle length is *exactly* the potential: the upper bound
`pythagorean_hydra_length_le` is attained on the level abstraction. -/
theorem pythagorean_hydra_sharp (k : ℕ) (H : Multiset Tri) :
    StepsTo k (Phi k (H.map lvl)) (H.map lvl) 0 ∧
      ∀ (N : ℕ) (H' : Multiset Tri), Battle k N H H' → N ≤ Phi k (H.map lvl) :=
  ⟨exists_maximal_play k _, fun _ _ h => pythagorean_hydra_length_le h⟩

/-- A concrete battle bound: starting from the single head `(3,4,5)` with at most three
regrown heads per chop, Hercules wins within `364 = 1+3+9+27+81+243` moves. -/
theorem root_battle_bound {N : ℕ} {H' : Multiset Tri}
    (h : Battle 3 N {((3 : ℤ), (4 : ℤ), (5 : ℤ))} H') : N ≤ 364 := by
  have hb := pythagorean_hydra_length_le h
  have : Phi 3 (({((3 : ℤ), (4 : ℤ), (5 : ℤ))} : Multiset Tri).map lvl) = 364 := by
    simp [Phi, lvl, phi, Finset.sum_range_succ]
  omega

/-- The root head really is inert: `(3,4,5)` has no Berggren ancestor, so chopping it
regrows nothing.  (Any purported ancestor would have smaller positive hypotenuse and
still be a primitive triple, which `small_isPPT` forbids.) -/
theorem root_has_no_ancestor (s : Tri) : ¬ IsBergAncestor s ((3 : ℤ), (4 : ℤ), (5 : ℤ)) := by
  intro h
  obtain ⟨u, _, hstep⟩ := Relation.TransGen.tail'_iff.mp h
  have h5 := hstep.2.1
  norm_num at h5

end PythHydra