import Mathlib

/-!
# The greedy packing–cover duality behind the wall–Menger separator bound

This file isolates the genuine combinatorial engine of the conjectured
*one-set wall–Menger bound* for elementary walls.  In that conjecture one fixes a
vertex set `A` and an elementary wall `W` of height at least `T(s,r) = (8s+4)r`,
and asks for the dichotomy

* either a small separator `X` with `|X| ≤ F(s) = 4s-4` cuts `A` from the branch
  vertices of `W`, or
* an `r`-subwall `W'` admits `s` pairwise vertex-disjoint `A`–`W'` paths.

The *separator side* of this dichotomy is, stripped of the wall geometry, the
classical **packing–cover duality**: if a finite family of (path-trace) sets
admits no `s` pairwise disjoint members, then a *small* hitting set meets them
all.  The greedy/maximal-packing argument gives the **explicit linear bound**
`|X| ≤ c·(s-1)` where `c` bounds the size of each member.  Instantiating `c = 4`
— the number of wall-neighbours of a nail — reproduces the paper's separator
constant `F(s) = 4s - 4` exactly.

## Main results

* `exists_maximal_packing` — a finite family has a pairwise-disjoint subfamily of
  maximum cardinality.
* `packing_cover_duality` — **no `s`-packing ⇒ hitting set of size `≤ c·(s-1)`**.
* `wall_menger_separator_bound` — the `c = 4` specialisation: the hitting set has
  size `≤ 4s - 4 = F(s)`.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): the explicit, *linear* separator constant `F(s)=4s-4`
  in the wall–Menger conjecture is not a wall phenomenon but the shadow of the
  greedy bound `cover ≤ c·(packing-1)`; the wall only fixes the local cost `c=4`.
* Experiment (Experimenter): formalised the family-of-finsets duality.  A *maximum*
  cardinality pairwise-disjoint subfamily `P` is taken; its union `X` is a hitting
  set because any `A` disjoint from `X` would enlarge `P`, contradicting maximality.
  The size bound `|X| ≤ |P|·c ≤ (s-1)·c` comes from `card_biUnion_le` + each
  member having `card ≤ c`.
* Analysis (Analyst): nonemptiness of members is *load-bearing* — an empty member
  is disjoint from everything, so it could never be hit; the hypothesis `hne`
  captures that a genuine `A`–nail path trace is nonempty.  The `s - 1` truncated
  subtraction is harmless because `P.card ≤ s - 1` follows from `P.card < s`.
* Critique (Critic): this is the *greedy* (one-sided) bound, not tight Menger
  min-max; that is exactly right — the paper claims *explicit* linear bounds, which
  are greedy, not the (non-constructive) exact min-max.  The result is fully general
  in `c`; the wall enters only through `c = 4`.
* Synthesis (PI): combined with the subwall pigeonhole of `WallMengerSubwall.lean`
  this gives the abstract one-set dichotomy.
-- !-- end Lab Notes -- !--
-/

open Finset

namespace WallMenger

variable {V : Type*} [DecidableEq V]

omit [DecidableEq V] in
/-- A finite family `F` admits a pairwise-disjoint subfamily of maximum cardinality. -/
theorem exists_maximal_packing (F : Finset (Finset V)) :
    ∃ P : Finset (Finset V), P ⊆ F ∧ (↑P : Set (Finset V)).PairwiseDisjoint id ∧
      ∀ Q : Finset (Finset V), Q ⊆ F → (↑Q : Set (Finset V)).PairwiseDisjoint id →
        Q.card ≤ P.card := by
  classical
  -- the collection of pairwise-disjoint subfamilies, as a finset of finsets
  set S : Finset (Finset (Finset V)) :=
    F.powerset.filter (fun Q => (↑Q : Set (Finset V)).PairwiseDisjoint id) with hS
  have hmem : ∀ Q : Finset (Finset V), Q ∈ S ↔
      (Q ⊆ F ∧ (↑Q : Set (Finset V)).PairwiseDisjoint id) := by
    intro Q
    simp [hS, Finset.mem_filter, Finset.mem_powerset]
  have hne : S.Nonempty := by
    refine ⟨∅, ?_⟩
    rw [hmem]
    refine ⟨by simp, ?_⟩
    simp
  -- pick a maximiser of card over S
  obtain ⟨P, hPS, hPmax⟩ := S.exists_max_image (fun Q => Q.card) hne
  rw [hmem] at hPS
  refine ⟨P, hPS.1, hPS.2, ?_⟩
  intro Q hQF hQpd
  exact hPmax Q ((hmem Q).2 ⟨hQF, hQpd⟩)

/-- **Greedy packing–cover duality.**  If a finite family `F` of nonempty finsets,
each of size at most `c`, has no `s` pairwise-disjoint members, then there is a
hitting set `X` of size at most `c·(s-1)` meeting every member of `F`. -/
theorem packing_cover_duality
    (F : Finset (Finset V)) (c s : ℕ)
    (hne : ∀ A ∈ F, A.Nonempty)
    (hc : ∀ A ∈ F, A.card ≤ c)
    (hpack : ¬ ∃ P : Finset (Finset V), P ⊆ F ∧
      (↑P : Set (Finset V)).PairwiseDisjoint id ∧ s ≤ P.card) :
    ∃ X : Finset V, X.card ≤ c * (s - 1) ∧ ∀ A ∈ F, ¬ Disjoint A X := by
  classical
  obtain ⟨P, hPF, hPpd, hPmax⟩ := exists_maximal_packing F
  -- the maximal packing has fewer than `s` members
  have hPlt : P.card < s := by
    by_contra h
    push_neg at h
    exact hpack ⟨P, hPF, hPpd, h⟩
  have hPle : P.card ≤ s - 1 := by omega
  refine ⟨P.biUnion id, ?_, ?_⟩
  · -- size bound
    calc (P.biUnion id).card ≤ ∑ A ∈ P, (id A).card := Finset.card_biUnion_le
      _ ≤ ∑ _A ∈ P, c := by
            apply Finset.sum_le_sum
            intro A hA
            exact hc A (hPF hA)
      _ = P.card * c := by rw [Finset.sum_const, smul_eq_mul]
      _ ≤ (s - 1) * c := by exact Nat.mul_le_mul_right c hPle
      _ = c * (s - 1) := by ring
  · -- hitting property
    intro A hAF hdisj
    -- `A` is disjoint from every member of `P`
    have hAdisjP : ∀ B ∈ P, Disjoint A B := by
      intro B hB
      have hBsub : (id B : Finset V) ⊆ P.biUnion id := Finset.subset_biUnion_of_mem id hB
      exact Finset.disjoint_of_subset_right hBsub hdisj
    -- so `insert A P` is a strictly larger packing
    have hAnotP : A ∉ P := by
      intro hAP
      have : Disjoint A A := hAdisjP A hAP
      rw [Finset.disjoint_self_iff_empty] at this
      exact (hne A hAF).ne_empty this
    have hins_sub : insert A P ⊆ F := Finset.insert_subset hAF hPF
    have hins_pd : (↑(insert A P) : Set (Finset V)).PairwiseDisjoint id := by
      rw [Finset.coe_insert]
      refine hPpd.insert ?_
      intro B hB _
      exact hAdisjP B hB
    have hcard : (insert A P).card = P.card + 1 := Finset.card_insert_of_notMem hAnotP
    have := hPmax (insert A P) hins_sub hins_pd
    omega

/-- **Wall–Menger separator bound (`c = 4`).**  With the wall's local cost `c = 4`
(a nail has four wall-neighbours), the absence of `s` pairwise vertex-disjoint
`A`–nail path traces yields a separator of size at most `F(s) = 4s - 4`. -/
theorem wall_menger_separator_bound
    (F : Finset (Finset V)) (s : ℕ) (hs : 1 ≤ s)
    (hne : ∀ A ∈ F, A.Nonempty)
    (hc : ∀ A ∈ F, A.card ≤ 4)
    (hpack : ¬ ∃ P : Finset (Finset V), P ⊆ F ∧
      (↑P : Set (Finset V)).PairwiseDisjoint id ∧ s ≤ P.card) :
    ∃ X : Finset V, X.card ≤ 4 * s - 4 ∧ ∀ A ∈ F, ¬ Disjoint A X := by
  obtain ⟨X, hXcard, hXhit⟩ := packing_cover_duality F 4 s hne hc hpack
  refine ⟨X, ?_, hXhit⟩
  -- `4 * (s - 1) = 4 * s - 4` for `s ≥ 1`
  have : 4 * (s - 1) = 4 * s - 4 := by omega
  omega

end WallMenger