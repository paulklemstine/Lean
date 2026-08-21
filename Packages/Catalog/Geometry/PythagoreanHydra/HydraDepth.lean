import Catalog.Geometry.PythagoreanHydra.PythagoreanHydra
import Catalog.Geometry.PythagoreanHydra.BerggrenAddress

/-!
# Depth in the Berggren tree, and the sharp form of the Pythagorean Hydra bound

`PythagoreanHydra.lean` measures a head by its hypotenuse.  The *intrinsic* measure is the
depth of the head in the Berggren tree, i.e. the length of its unique address
(`BerggrenAddress.lean`).  Here we

* define `bergDepth` and prove `bergDepth (addr w) = w.length`;
* prove that the inverse Berggren move drops the depth by exactly one
  (`bergDepth_parent`), hence Berggren ancestors have strictly smaller depth;
* re-run the hydra bound with `bergDepth` as the level, obtaining the sharp statement
  `battle_depth_bound : N ≤ Phi k (H.map bergDepth)`;
* deduce that a battle starting at a node of depth `d` with branching bound `k` lasts at
  most `(k+1)^(d+1)` moves, and that a battle starting at the root `(3,4,5)` lasts at
  most **one** move.

This is the exact calibration of the Pythagorean Hydra: its length function is
`(k+1)^(depth+1)`, an elementary function of the address length — nothing like the
`ε₀`-recursive length function of the Kirby–Paris hydra.
-/

namespace PythHydra

open Classical in
/-- The depth of a triple in the Berggren tree: the length of its (unique) address. -/
noncomputable def bergDepth (t : ℤ × ℤ × ℤ) : ℕ :=
  if h : ∃ w : List BStep, addr w = t then h.choose.length else 0

theorem bergDepth_addr (w : List BStep) : bergDepth (addr w) = w.length := by
  have h : ∃ w' : List BStep, addr w' = addr w := ⟨w, rfl⟩
  rw [bergDepth, dif_pos h]
  exact congrArg List.length (addr_injective h.choose_spec)

@[simp] theorem bergDepth_root : bergDepth ((3 : ℤ), (4 : ℤ), (5 : ℤ)) = 0 :=
  bergDepth_addr []

/-- The inverse Berggren move drops the Berggren depth by exactly one. -/
theorem bergDepth_parent {a b c : ℤ} (h : IsPPT a b c) (hc : 5 < c) :
    bergDepth (parent a b c) + 1 = bergDepth (a, b, c) := by
  obtain ⟨w, hw⟩ := exists_addr h
  cases w with
  | nil =>
    exfalso
    simp only [addr] at hw
    have : (5 : ℤ) = c := congrArg (fun t => t.2.2) hw
    omega
  | cons s w' =>
    have hpar : parent (addr (s :: w')).1 (addr (s :: w')).2.1 (addr (s :: w')).2.2 = addr w' :=
      parent_addr_cons s w'
    rw [hw] at hpar
    simp only at hpar
    rw [hpar, ← hw, bergDepth_addr, bergDepth_addr]
    simp

theorem parentStep_depth_lt {s t : ℤ × ℤ × ℤ} (h : ParentStep s t) :
    bergDepth s < bergDepth t := by
  obtain ⟨hppt, hc, rfl⟩ := h
  have := bergDepth_parent hppt hc
  have ht : (t.1, t.2.1, t.2.2) = t := rfl
  rw [ht] at this
  omega

/-- Berggren ancestors sit strictly closer to the root. -/
theorem ancestor_depth_lt {s t : ℤ × ℤ × ℤ} (h : IsBergAncestor s t) :
    bergDepth s < bergDepth t := by
  induction h with
  | single hst => exact parentStep_depth_lt hst
  | tail _ hstep ih => exact lt_trans ih (parentStep_depth_lt hstep)

theorem bergChop_map_depth {k : ℕ} {H H' : Multiset (ℤ × ℤ × ℤ)} (h : BergChop k H H') :
    HydraStep k (H.map bergDepth) (H'.map bergDepth) := by
  obtain ⟨t, H₀, R, hR, hcard⟩ := h
  simp only [Multiset.map_cons, Multiset.map_add]
  refine HydraStep.chop (bergDepth t) (H₀.map bergDepth) (R.map bergDepth) ?_ ?_
  · intro x hx
    obtain ⟨s, hs, rfl⟩ := Multiset.mem_map.mp hx
    exact ancestor_depth_lt (hR s hs)
  · simpa using hcard

theorem battle_to_stepsTo_depth {k : ℕ} : ∀ (N : ℕ) (H H' : Multiset (ℤ × ℤ × ℤ)),
    Battle k N H H' → StepsTo k N (H.map bergDepth) (H'.map bergDepth) := by
  intro N
  induction N with
  | zero => intro H H' h; rw [h]; rfl
  | succ n ih =>
    rintro H H' ⟨M, hstep, hrest⟩
    exact ⟨M.map bergDepth, bergChop_map_depth hstep, ih M H' hrest⟩

/-- **Sharp length bound for the Pythagorean Hydra**, in terms of Berggren depth. -/
theorem battle_depth_bound {k N : ℕ} {H H' : Multiset (ℤ × ℤ × ℤ)} (h : Battle k N H H') :
    N ≤ Phi k (H.map bergDepth) :=
  play_length_le (battle_to_stepsTo_depth N H H' h)

/-- A battle against a single head at Berggren depth `d`, with at most `k` heads regrowing
per chop, is over after at most `(k+1)^(d+1)` moves. -/
theorem single_head_battle_bound {k N : ℕ} {t : ℤ × ℤ × ℤ} {H' : Multiset (ℤ × ℤ × ℤ)}
    (h : Battle k N {t} H') : N ≤ (k + 1) ^ (bergDepth t + 1) := by
  have h1 := battle_depth_bound h
  have h2 : Phi k (({t} : Multiset (ℤ × ℤ × ℤ)).map bergDepth) = phi k (bergDepth t) := by
    simp [Phi]
  have h3 := phi_le_pow k (bergDepth t)
  omega

/-- The root is a dead head: a battle starting from `(3,4,5)` alone lasts at most one
move, whatever the branching bound. -/
theorem root_battle_le_one {k N : ℕ} {H' : Multiset (ℤ × ℤ × ℤ)}
    (h : Battle k N {((3 : ℤ), (4 : ℤ), (5 : ℤ))} H') : N ≤ 1 := by
  have h1 := battle_depth_bound h
  have h2 : Phi k ((({((3 : ℤ), (4 : ℤ), (5 : ℤ))} : Multiset (ℤ × ℤ × ℤ))).map bergDepth) = 1 := by
    simp [Phi]
  omega

/-- The depth of the node reached by the `B`-spine of length `n` is `n`: nodes of every
depth occur, so the bound `(k+1)^(d+1)` is not vacuous. -/
theorem bergDepth_B_spine (n : ℕ) : bergDepth (addr (List.replicate n BStep.B)) = n := by
  rw [bergDepth_addr, List.length_replicate]

end PythHydra