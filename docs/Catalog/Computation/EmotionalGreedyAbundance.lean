/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Greedy Abundance: an Exponential Lower Bound for the Chromatic Counting Function

`Catalog/Computation/EmotionalGreedyColoring.lean` proves that a social network in which nobody has
more than `d` friends admits *at least one* assignment of `d + 1` emotions.  That is a statement
about existence; the mission is about *counting*.  This file upgrades the greedy argument to a
counting theorem:

  **`(q - d) ^ |V| ≤ chromVal G q`**  (`greedy_abundance`)

whenever every person has at most `d` friends.  With `d = 5` and the six basic emotions the bound
degenerates to `1` (existence), but with a slightly larger palette it is exponentially strong:
a hundred-person network of degree at most five has at least `5 ^ 100` emotionally consistent
assignments of ten emotions.

The proof refines the greedy induction of the existence theorem.  Colorings are carried as *total*
functions `V → Fin q` that are proper only on a finset `s`, and the finset is grown one person at a
time.  The counting step fibres the colorings over the map `c ↦ Function.update c a c₀`, which
forgets the color of the newly added person `a`: every fibre inside `properOn G q s` has exactly
`q` elements, while the fibre inside `properOn G q (insert a s)` still has at least `q - d`
elements, because at most `d` colors are forbidden by `a`'s already-colored friends.

## Main results

* `properOn`                        : colorings proper on a prescribed set of people.
* `card_fiber_properOn`             : each fibre of the forgetful map has exactly `q` elements.
* `card_fiber_properOn_insert_ge`   : at least `q - d` of them survive the new constraint.
* `greedy_abundance_on_finset`      : `(q-d)^{|s|} · q^{|V|-|s|} ≤ #(properOn G q s)`.
* `greedy_abundance`                : `(q-d)^{|V|} ≤ chromVal G q`.
* `greedy_abundance_maxDegree`      : `(q-Δ(G))^{|V|} ≤ chromVal G q`.
* `abundance_of_sparse_network`     : a hundred people of degree `≤ 5` have at least `5^100`
  assignments of ten emotions.

-- !-- Lab Notes -- !--
HYPOTHESIS (Stage 1, cycle 4).  Conjecture C of `FUTURE_DIRECTIONS.md`: the pigeonhole step of the
greedy colouring proof discards information — at each step at least `q - d` colors remain free —
so the existence theorem should upgrade to an exponential counting theorem.

EXPERIMENT (Stage 2).  Confirmed, by exactly the mechanism conjectured.  The two fibre lemmas are
the technical heart; the induction then reads
`#(properOn (insert a s)) ≥ (q-d) · #I` and `#(properOn s) = q · #I`, so dividing by `q` (legal
because `d < q` in the nontrivial case) transports the induction hypothesis across the step.

DATA.  `q = d + 1` gives the trivial bound `1 ≤ chromVal`, recovering the existence theorem;
`q = 2d` gives `d^{|V|}`.  For the census clique networks (`|V| = 10`, `d = 5`, `q = 6`) the bound
gives `1`, while the exact value is `933 120`: the greedy bound is exponentially weak on
clique-like networks but is the only general bound available, and it is *sharp for the empty
network*, where `chromVal = q^{|V|}` and `d = 0`.

ANALYSIS (Stage 3).  The bound is tight exactly when `d = 0`; the loss for `d ≥ 1` is the price of
ignoring which neighbours are already coloured.  Any improvement must use the graph structure of
the *uncoloured* part, which is precisely the mechanism Brooks' theorem needs — Conjecture A of
`FUTURE_DIRECTIONS.md`.
-- !-- End Lab Notes -- !--
-/

import Computation.EmotionalGreedyColoring

namespace Catalog.Computation.EmotionalGreedyAbundance

open SimpleGraph Finset
open Catalog.Combinatorics.ChromaticPolynomial

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Colorings proper on a prescribed set -/

/-- The assignments of `q` emotions to the whole population that are consistent **on `s`**: no two
friends inside `s` share an emotion.  People outside `s` are unconstrained. -/
def properOn (G : SimpleGraph V) [DecidableRel G.Adj] (q : ℕ) (s : Finset V) :
    Finset (V → Fin q) :=
  Finset.univ.filter (fun c => ∀ x ∈ s, ∀ y ∈ s, G.Adj x y → c x ≠ c y)

lemma mem_properOn {G : SimpleGraph V} [DecidableRel G.Adj] {q : ℕ} {s : Finset V}
    {c : V → Fin q} : c ∈ properOn G q s ↔ ∀ x ∈ s, ∀ y ∈ s, G.Adj x y → c x ≠ c y := by
  simp [properOn]

/-- On the whole population, `properOn` is the catalog's finset of proper colorings. -/
lemma properOn_univ (G : SimpleGraph V) [DecidableRel G.Adj] (q : ℕ) :
    properOn G q Finset.univ = properColorings G (Fin q) := by
  ext c
  rw [mem_properOn, mem_properColorings]
  exact ⟨fun h x y hadj => h x (Finset.mem_univ _) y (Finset.mem_univ _) hadj,
    fun h x _ y _ hadj => h x y hadj⟩

/-! ## The two fibre lemmas -/

/-- Every fibre of the forgetful map `c ↦ Function.update c a c₀` inside `properOn G q s` has
exactly `q` elements: the color of `a` is a free parameter as long as `a ∉ s`. -/
lemma card_fiber_properOn (G : SimpleGraph V) [DecidableRel G.Adj] (q : ℕ) (s : Finset V) {a : V}
    (ha : a ∉ s) (c0 : Fin q) {t : V → Fin q} (htA : t ∈ properOn G q s) (hta : t a = c0) :
    ((properOn G q s).filter (fun c => Function.update c a c0 = t)).card = q := by
  classical
  have himg : (properOn G q s).filter (fun c => Function.update c a c0 = t)
      = Finset.univ.image (fun v : Fin q => Function.update t a v) := by
    ext c
    simp only [Finset.mem_filter, Finset.mem_image, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨hcA, hphi⟩
      refine ⟨c a, ?_⟩
      funext v
      by_cases hv : v = a
      · subst hv; simp
      · have hcv := congrFun hphi v
        rw [Function.update_of_ne hv] at hcv
        rw [Function.update_of_ne hv, hcv]
    · rintro ⟨v, rfl⟩
      refine ⟨?_, ?_⟩
      · rw [mem_properOn] at htA ⊢
        intro x hx y hy hadj
        have hxa : x ≠ a := fun h => ha (h ▸ hx)
        have hya : y ≠ a := fun h => ha (h ▸ hy)
        rw [Function.update_of_ne hxa, Function.update_of_ne hya]
        exact htA x hx y hy hadj
      · funext w
        by_cases hw : w = a
        · subst hw; simp [hta]
        · simp [Function.update_of_ne hw]
  rw [himg, Finset.card_image_of_injective _ (by
    intro v1 v2 h
    simpa using congrFun h a)]
  simp

/-- After adding `a` to the colored set, the fibre loses at most `d` elements: the colors of `a`'s
already-colored friends are the only ones excluded. -/
lemma card_fiber_properOn_insert_ge (G : SimpleGraph V) [DecidableRel G.Adj] {q d : ℕ}
    (hd : ∀ v, G.degree v ≤ d) (s : Finset V) {a : V} (ha : a ∉ s) (c0 : Fin q)
    {t : V → Fin q} (htA : t ∈ properOn G q s) (hta : t a = c0) :
    q - d ≤ ((properOn G q (insert a s)).filter
      (fun c => Function.update c a c0 = t)).card := by
  classical
  set C : Finset (Fin q) := (G.neighborFinset a ∩ s).image t with hC
  have hCcard : C.card ≤ d := by
    have h1 : C.card ≤ (G.neighborFinset a ∩ s).card := Finset.card_image_le
    have h2 : (G.neighborFinset a ∩ s).card ≤ (G.neighborFinset a).card :=
      Finset.card_le_card Finset.inter_subset_left
    have h3 : (G.neighborFinset a).card = G.degree a := rfl
    have h4 := hd a
    omega
  have himg : (properOn G q (insert a s)).filter (fun c => Function.update c a c0 = t)
      = (Finset.univ.filter (fun v : Fin q => v ∉ C)).image (fun v => Function.update t a v) := by
    ext c
    simp only [Finset.mem_filter, Finset.mem_image, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨hcA, hphi⟩
      have hc_eq : c = Function.update t a (c a) := by
        funext v
        by_cases hv : v = a
        · subst hv; simp
        · have hcv := congrFun hphi v
          rw [Function.update_of_ne hv] at hcv
          rw [Function.update_of_ne hv, hcv]
      refine ⟨c a, ?_, hc_eq.symm⟩
      intro hmem
      rw [hC, Finset.mem_image] at hmem
      obtain ⟨y, hy, hty⟩ := hmem
      rw [Finset.mem_inter, SimpleGraph.mem_neighborFinset] at hy
      rw [mem_properOn] at hcA
      have hya : y ≠ a := fun h => ha (h ▸ hy.2)
      have hcy : c y = t y := by rw [hc_eq, Function.update_of_ne hya]
      exact hcA a (Finset.mem_insert_self _ _) y (Finset.mem_insert_of_mem hy.2) hy.1
        (by rw [hcy, hty])
    · rintro ⟨v, hv, rfl⟩
      have hvC : v ∉ C := by simpa using hv
      refine ⟨?_, ?_⟩
      · rw [mem_properOn]
        rw [mem_properOn] at htA
        intro x hx y hy hadj
        rcases Finset.mem_insert.1 hx with rfl | hxs
        · rcases Finset.mem_insert.1 hy with rfl | hys
          · exact absurd rfl hadj.ne
          · have hya : y ≠ x := fun h => ha (h ▸ hys)
            rw [Function.update_self, Function.update_of_ne hya]
            intro hcon
            exact hvC (hC ▸ Finset.mem_image.2
              ⟨y, Finset.mem_inter.2 ⟨by simpa using hadj, hys⟩, hcon.symm⟩)
        · rcases Finset.mem_insert.1 hy with rfl | hys
          · have hxa : x ≠ y := fun h => ha (h ▸ hxs)
            rw [Function.update_self, Function.update_of_ne hxa]
            intro hcon
            exact hvC (hC ▸ Finset.mem_image.2
              ⟨x, Finset.mem_inter.2 ⟨by simpa using hadj.symm, hxs⟩, hcon⟩)
          · have hxa : x ≠ a := fun h => ha (h ▸ hxs)
            have hya : y ≠ a := fun h => ha (h ▸ hys)
            rw [Function.update_of_ne hxa, Function.update_of_ne hya]
            exact htA x hxs y hys hadj
      · funext w
        by_cases hw : w = a
        · subst hw; simp [hta]
        · simp [Function.update_of_ne hw]
  rw [himg, Finset.card_image_of_injective _ (by
    intro v1 v2 h
    simpa using congrFun h a)]
  have hcompl : (Finset.univ.filter (fun v : Fin q => v ∉ C)).card = q - C.card := by
    rw [Finset.filter_not]
    simp [Finset.card_sdiff, Finset.filter_mem_eq_inter]
  omega

/-! ## The counting induction -/

/-- **Greedy abundance, partial form.**  If nobody has more than `d` friends, then the number of
`q`-emotion assignments consistent on a set `s` of people is at least
`(q - d)^{|s|} · q^{|V| - |s|}`. -/
theorem greedy_abundance_on_finset (G : SimpleGraph V) [DecidableRel G.Adj] {d q : ℕ}
    (hd : ∀ v, G.degree v ≤ d) (s : Finset V) :
    (q - d) ^ s.card * q ^ (Fintype.card V - s.card) ≤ (properOn G q s).card := by
  classical
  induction s using Finset.induction_on with
  | empty =>
      have h : properOn G q (∅ : Finset V) = Finset.univ := by
        ext c; simp [properOn]
      rw [h]
      simp
  | @insert a s ha ih =>
      rcases le_or_gt q d with hqd | hdq
      · -- the palette is too small for the bound to say anything
        have h0 : q - d = 0 := by omega
        rw [Finset.card_insert_of_notMem ha, h0]
        simp
      · have hq : 0 < q := by omega
        set c0 : Fin q := ⟨0, hq⟩ with hc0
        set φ : (V → Fin q) → (V → Fin q) := fun c => Function.update c a c0 with hφ
        set A := properOn G q s with hA
        set B := properOn G q (insert a s) with hB
        set I := A.image φ with hI
        -- every element of `I` is itself proper on `s` and sends `a` to `c₀`
        have hIprop : ∀ t ∈ I, t ∈ A ∧ t a = c0 := by
          intro t ht
          rw [hI, Finset.mem_image] at ht
          obtain ⟨c, hc, rfl⟩ := ht
          refine ⟨?_, by simp [hφ]⟩
          rw [hA, mem_properOn] at hc ⊢
          intro x hx y hy hadj
          have hxa : x ≠ a := fun h => ha (h ▸ hx)
          have hya : y ≠ a := fun h => ha (h ▸ hy)
          rw [hφ]
          simp only
          rw [Function.update_of_ne hxa, Function.update_of_ne hya]
          exact hc x hx y hy hadj
        -- fibering `A`
        have hAsum : A.card = ∑ t ∈ I, (A.filter (fun c => φ c = t)).card :=
          Finset.card_eq_sum_card_fiberwise (fun c hc => Finset.mem_image_of_mem φ hc)
        have hAeq : A.card = I.card * q := by
          rw [hAsum, Finset.sum_congr rfl (fun t ht => ?_), Finset.sum_const, smul_eq_mul]
          obtain ⟨htA, hta⟩ := hIprop t ht
          exact card_fiber_properOn G q s ha c0 htA hta
        -- fibering `B`
        have hBsub : B ⊆ A := by
          intro c hc
          rw [hB, mem_properOn] at hc
          rw [hA, mem_properOn]
          exact fun x hx y hy hadj =>
            hc x (Finset.mem_insert_of_mem hx) y (Finset.mem_insert_of_mem hy) hadj
        have hBsum : B.card = ∑ t ∈ I, (B.filter (fun c => φ c = t)).card :=
          Finset.card_eq_sum_card_fiberwise
            (fun c hc => Finset.mem_image_of_mem φ (hBsub hc))
        have hBge : I.card * (q - d) ≤ B.card := by
          rw [hBsum]
          calc I.card * (q - d) = ∑ _t ∈ I, (q - d) := by
                rw [Finset.sum_const, smul_eq_mul]
            _ ≤ ∑ t ∈ I, (B.filter (fun c => φ c = t)).card := by
                refine Finset.sum_le_sum (fun t ht => ?_)
                obtain ⟨htA, hta⟩ := hIprop t ht
                exact card_fiber_properOn_insert_ge G hd s ha c0 htA hta
        -- the population has room for `a`
        have hcards : s.card + 1 ≤ Fintype.card V := by
          have := Finset.card_le_univ (insert a s)
          rw [Finset.card_insert_of_notMem ha] at this
          simpa [Finset.card_univ] using this
        -- transport the induction hypothesis through the fibering
        have hIH := ih
        have hsplit : q ^ (Fintype.card V - s.card)
            = q ^ (Fintype.card V - s.card - 1) * q := by
          rw [← pow_succ]
          congr 1
          omega
        have hIcard : (q - d) ^ s.card * q ^ (Fintype.card V - s.card - 1) ≤ I.card := by
          have h1 : (q - d) ^ s.card * q ^ (Fintype.card V - s.card - 1) * q ≤ I.card * q := by
            calc (q - d) ^ s.card * q ^ (Fintype.card V - s.card - 1) * q
                = (q - d) ^ s.card * q ^ (Fintype.card V - s.card) := by
                  rw [hsplit]; ring
              _ ≤ A.card := hIH
              _ = I.card * q := hAeq
          exact Nat.le_of_mul_le_mul_right h1 hq
        rw [Finset.card_insert_of_notMem ha]
        have hgoal : (q - d) ^ (s.card + 1) * q ^ (Fintype.card V - (s.card + 1))
            ≤ I.card * (q - d) := by
          have hexp : Fintype.card V - (s.card + 1) = Fintype.card V - s.card - 1 := by omega
          rw [hexp, pow_succ]
          calc (q - d) ^ s.card * (q - d) * q ^ (Fintype.card V - s.card - 1)
              = ((q - d) ^ s.card * q ^ (Fintype.card V - s.card - 1)) * (q - d) := by ring
            _ ≤ I.card * (q - d) := Nat.mul_le_mul_right _ hIcard
        exact le_trans hgoal hBge

/-! ## The abundance theorems -/

/-- **Greedy abundance.**  If every person has at most `d` friends, then there are at least
`(q - d)^{|V|}` emotionally consistent assignments of `q` emotions. -/
theorem greedy_abundance (G : SimpleGraph V) [DecidableRel G.Adj] {d q : ℕ}
    (hd : ∀ v, G.degree v ≤ d) : (q - d) ^ Fintype.card V ≤ chromVal G q := by
  have h := greedy_abundance_on_finset G (d := d) (q := q) hd (Finset.univ : Finset V)
  rw [properOn_univ] at h
  simpa [Finset.card_univ] using h

/-- The maximum-degree form of the abundance bound. -/
theorem greedy_abundance_maxDegree (G : SimpleGraph V) [DecidableRel G.Adj] (q : ℕ) :
    (q - G.maxDegree) ^ Fintype.card V ≤ chromVal G q :=
  greedy_abundance G (fun v => G.degree_le_maxDegree v)

/-- **Exponential abundance in sparse networks.**  A hundred people in which nobody has more than
five friends admit at least `5 ^ 100` consistent assignments of ten emotions. -/
theorem abundance_of_sparse_network (G : SimpleGraph V) [DecidableRel G.Adj]
    (hcard : Fintype.card V = 100) (hΔ : G.maxDegree ≤ 5) : 5 ^ 100 ≤ chromVal G 10 := by
  have h := greedy_abundance_maxDegree G 10
  rw [hcard] at h
  have hpow : (5 : ℕ) ^ 100 ≤ (10 - G.maxDegree) ^ 100 :=
    Nat.pow_le_pow_left (by omega) 100
  omega

/-- The bound is sharp for the friendless population: with no friendships at all the count is
exactly `q ^ {|V|}`. -/
theorem greedy_abundance_sharp_on_empty (q : ℕ) :
    (q - 0) ^ Fintype.card V ≤ chromVal (⊥ : SimpleGraph V) q ∧
      chromVal (⊥ : SimpleGraph V) q = q ^ Fintype.card V := by
  refine ⟨?_, chromVal_bot q⟩
  have h := greedy_abundance (G := (⊥ : SimpleGraph V)) (d := 0) (q := q) (fun v => by simp)
  simpa using h

/-
-- !-- Lab Notes (critique, cycle 4) -- !--
ADVERSARIAL REVIEW.
* Is the bound vacuous?  For `q ≤ d` it reads `0 ≤ chromVal` and is indeed vacuous; the content is
  for `q > d`, where it is exponential, and `greedy_abundance_sharp_on_empty` shows it is attained.
* Is the counting genuine, or does truncated subtraction hide an error?  The nontrivial branch of
  the induction assumes `d < q` explicitly, and the degenerate branch is discharged separately, so
  no ℕ-subtraction identity is used outside its range of validity.
* Circularity: this file imports only the *existence* greedy file for shared context; the counting
  induction is independent of the existence theorem and re-derives it as the special case
  `q = d + 1`.
-- !-- End Lab Notes -- !--
-/

end Catalog.Computation.EmotionalGreedyAbundance