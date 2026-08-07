/-
  # Hadwiger's conjecture for graphs with at most `k + 2` vertices

  `HadwigerSmallGraphs.lean` proves Hadwiger's conjecture for every graph with at
  most `k + 1` vertices: such a graph, if not `k`-colourable, is complete.  One
  vertex further the graph need no longer be complete, and the argument has to
  become genuinely combinatorial.  This file settles that next layer:

      every finite graph with at most `k + 2` vertices satisfies Hadwiger's
      conjecture for `k`  (`hadwiger_of_card_le_add_two`),

  for **every** `k`, including the open range `k ≥ 5`.

  ## The argument

  Write `n = |V| = k + 2`.  A `k`-colouring of an `(k+2)`-vertex graph must
  identify two pairs of vertices (or one triple), so:

  * `colorable_of_two_contractions` — if there are vertices `b ≠ d` that can be
    merged into non-neighbours `a` and `c` respectively, the graph *is*
    `k`-colourable.  (Colour the `k` vertices other than `b, d` injectively and
    give `b` the colour of `a`, `d` the colour of `c`.)

  Contrapositively, a non-`k`-colourable graph on `k + 2` vertices has

  * no independent set of size three, and
  * no two *disjoint* non-edges,

  which forces all non-edges to pass through a single vertex `x`
  (`exists_clique_of_not_colorable_card_add_two`).  Deleting `x` leaves a clique
  on `k + 1` vertices, hence a `K_{k+1}` minor.

  -- !-- Lab Notes -- !--
  * The two obstructions are packaged in a *single* lemma by allowing `a = c`:
    the independent-triple case is `a = c` (both `b` and `d` are merged into `a`),
    the disjoint-non-edge case is `a ≠ c`.  The only extra hypothesis needed is
    `G.Adj b d → a ≠ c`, which is automatic in both cases.
  * The clique extraction is a three-case analysis on how non-edges can overlap:
    two disjoint non-edges are excluded outright, and two non-edges meeting in a
    single vertex together with a third one produce an independent triple.
-/
import Mathlib
import Probability.HadwigerSmallGraphs

namespace Hadwiger

open SimpleGraph Finset

variable {V : Type*} {G : SimpleGraph V} {k : ℕ}

/-- **Merging two vertices gives a colouring.**  Suppose `|V| = k + 2` and there
are two distinct vertices `b, d` together with vertices `a, c` outside `{b, d}`
such that `a` is not adjacent to `b`, `c` is not adjacent to `d`, and `a ≠ c`
whenever `b` and `d` are adjacent.  Then `G` is `k`-colourable: colour the `k`
vertices other than `b` and `d` with distinct colours and copy the colour of `a`
onto `b` and that of `c` onto `d`. -/
theorem colorable_of_two_contractions [Fintype V] [DecidableEq V]
    (hcard : Fintype.card V = k + 2) {a b c d : V}
    (hab : a ≠ b) (had : a ≠ d) (hcb : c ≠ b) (hcd : c ≠ d) (hbd : b ≠ d)
    (hnab : ¬ G.Adj a b) (hncd : ¬ G.Adj c d) (hbd' : G.Adj b d → a ≠ c) :
    G.Colorable k := by
  classical
  set S : Finset V := (Finset.univ.erase b).erase d with hS
  have hdmem : d ∈ Finset.univ.erase b := Finset.mem_erase.mpr ⟨hbd.symm, Finset.mem_univ d⟩
  have hcardS : S.card = k := by
    rw [hS, Finset.card_erase_of_mem hdmem, Finset.card_erase_of_mem (Finset.mem_univ b),
      Finset.card_univ, hcard]
    omega
  have hmem : ∀ x : V, x ≠ b → x ≠ d → x ∈ S := by
    intro x hxb hxd
    exact Finset.mem_erase.mpr ⟨hxd, Finset.mem_erase.mpr ⟨hxb, Finset.mem_univ x⟩⟩
  have hnotmem : ∀ x : V, x ∉ S → x = b ∨ x = d := by
    intro x hx
    by_contra hcon
    push_neg at hcon
    exact hx (hmem x hcon.1 hcon.2)
  have haS : a ∈ S := hmem a hab had
  have hcS : c ∈ S := hmem c hcb hcd
  let e : S ≃ Fin k := Finset.equivFinOfCardEq hcardS
  set col : V → Fin k := fun x =>
    if hx : x ∈ S then e ⟨x, hx⟩ else if x = b then e ⟨a, haS⟩ else e ⟨c, hcS⟩ with hcol
  have hinj : ∀ (x : V) (hx : x ∈ S) (y : V) (hy : y ∈ S), e ⟨x, hx⟩ = e ⟨y, hy⟩ → x = y := by
    intro x hx y hy hxy
    exact congrArg Subtype.val (e.injective hxy)
  refine ⟨Coloring.mk col ?_⟩
  intro x y hxy heq
  rw [hcol] at heq
  simp only at heq
  by_cases hxS : x ∈ S <;> by_cases hyS : y ∈ S
  · rw [dif_pos hxS, dif_pos hyS] at heq
    exact (G.ne_of_adj hxy) (hinj x hxS y hyS heq)
  · rw [dif_pos hxS, dif_neg hyS] at heq
    rcases hnotmem y hyS with rfl | rfl
    · rw [if_pos rfl] at heq
      have : x = a := hinj x hxS a haS heq
      exact hnab (this ▸ hxy)
    · rw [if_neg (Ne.symm hbd)] at heq
      have : x = c := hinj x hxS c hcS heq
      exact hncd (this ▸ hxy)
  · rw [dif_neg hxS, dif_pos hyS] at heq
    rcases hnotmem x hxS with rfl | rfl
    · rw [if_pos rfl] at heq
      have : y = a := hinj y hyS a haS heq.symm
      exact hnab (this ▸ hxy.symm)
    · rw [if_neg (Ne.symm hbd)] at heq
      have : y = c := hinj y hyS c hcS heq.symm
      exact hncd (this ▸ hxy.symm)
  · rw [dif_neg hxS, dif_neg hyS] at heq
    rcases hnotmem x hxS with rfl | rfl <;> rcases hnotmem y hyS with rfl | rfl
    · exact (G.ne_of_adj hxy) rfl
    · rw [if_pos rfl, if_neg (Ne.symm hbd)] at heq
      exact hbd' hxy (hinj a haS c hcS heq)
    · rw [if_neg (Ne.symm hbd), if_pos rfl] at heq
      exact hbd' hxy.symm (hinj a haS c hcS heq.symm)
    · exact (G.ne_of_adj hxy) rfl

/-- No independent set of size three in a non-`k`-colourable graph on `k + 2`
vertices. -/
theorem not_independent_triple_of_not_colorable [Fintype V] [DecidableEq V]
    (hcard : Fintype.card V = k + 2) (h : ¬ G.Colorable k) {a b c : V}
    (hab : a ≠ b) (hac : a ≠ c) (hbc : b ≠ c)
    (hnab : ¬ G.Adj a b) (hnac : ¬ G.Adj a c) (hnbc : ¬ G.Adj b c) : False :=
  h (colorable_of_two_contractions hcard (a := a) (b := b) (c := a) (d := c)
      hab hac hab hac hbc hnab hnac (fun hadj => absurd hadj hnbc))

/-- No two disjoint non-edges in a non-`k`-colourable graph on `k + 2`
vertices. -/
theorem not_two_disjoint_nonedges_of_not_colorable [Fintype V] [DecidableEq V]
    (hcard : Fintype.card V = k + 2) (h : ¬ G.Colorable k) {a b c d : V}
    (hab : a ≠ b) (hcd : c ≠ d) (hac : a ≠ c) (had : a ≠ d) (hbc : b ≠ c) (hbd : b ≠ d)
    (hnab : ¬ G.Adj a b) (hncd : ¬ G.Adj c d) : False :=
  h (colorable_of_two_contractions hcard hab had (Ne.symm hbc) hcd hbd hnab hncd
      (fun _ => hac))

/-- **All non-edges pass through one vertex.**  A graph on `k + 2` vertices that
is not `k`-colourable has a vertex `x` whose removal leaves a clique on `k + 1`
vertices. -/
theorem exists_clique_of_not_colorable_card_add_two [Fintype V] [DecidableEq V]
    (hcard : Fintype.card V = k + 2) (h : ¬ G.Colorable k) :
    ∃ x : V, G.IsNClique (k + 1) (Finset.univ.erase x) := by
  classical
  -- `x` works as soon as every non-edge meets `{x}`
  have key : ∀ x : V, (∀ p q : V, p ≠ q → ¬ G.Adj p q → p = x ∨ q = x) →
      G.IsNClique (k + 1) (Finset.univ.erase x) := by
    intro x hx
    refine ⟨?_, ?_⟩
    · intro p hp q hq hpq
      by_contra hadj
      rcases hx p q hpq hadj with rfl | rfl
      · exact (Finset.mem_erase.mp hp).1 rfl
      · exact (Finset.mem_erase.mp hq).1 rfl
    · rw [Finset.card_erase_of_mem (Finset.mem_univ x), Finset.card_univ, hcard]
      omega
  by_cases hcomplete : ∀ p q : V, p ≠ q → G.Adj p q
  · have hne : Nonempty V := by
      rw [← Fintype.card_pos_iff, hcard]; omega
    obtain ⟨x⟩ := hne
    exact ⟨x, key x fun p q hpq hnadj => absurd (hcomplete p q hpq) hnadj⟩
  push_neg at hcomplete
  obtain ⟨u, v, huv, hnuv⟩ := hcomplete
  by_cases hu : ∀ p q : V, p ≠ q → ¬ G.Adj p q → p = u ∨ q = u
  · exact ⟨u, key u hu⟩
  · -- some non-edge avoids `u`; then every non-edge must contain `v`
    push_neg at hu
    obtain ⟨p, q, hpq, hnpq, hpu, hqu⟩ := hu
    refine ⟨v, key v ?_⟩
    intro r s hrs hnrs
    by_contra hcon
    push_neg at hcon
    obtain ⟨hrv, hsv⟩ := hcon
    -- `{p, q}` is a non-edge avoiding `u`, `{r, s}` is a non-edge avoiding `v`
    -- first: `{p, q}` must meet `{u, v}`, hence contains `v`
    have hpqv : p = v ∨ q = v := by
      by_contra hc
      push_neg at hc
      exact not_two_disjoint_nonedges_of_not_colorable hcard h huv hpq
        (Ne.symm hpu) (Ne.symm hqu) (Ne.symm hc.1) (Ne.symm hc.2) hnuv hnpq
    have hrsu : r = u ∨ s = u := by
      by_contra hc
      push_neg at hc
      exact not_two_disjoint_nonedges_of_not_colorable hcard h huv hrs
        (Ne.symm hc.1) (Ne.symm hc.2) (Ne.symm hrv) (Ne.symm hsv) hnuv hnrs
    -- name the partner of `v` in `{p, q}` and the partner of `u` in `{r, s}`
    obtain ⟨w, hwu, hwv, hnvw⟩ : ∃ w : V, w ≠ u ∧ w ≠ v ∧ ¬ G.Adj v w := by
      rcases hpqv with rfl | rfl
      · exact ⟨q, hqu, Ne.symm hpq, hnpq⟩
      · exact ⟨p, hpu, hpq, fun hadj => hnpq hadj.symm⟩
    obtain ⟨z, hzv, hzu, hnuz⟩ : ∃ z : V, z ≠ v ∧ z ≠ u ∧ ¬ G.Adj u z := by
      rcases hrsu with rfl | rfl
      · exact ⟨s, hsv, Ne.symm hrs, hnrs⟩
      · exact ⟨r, hrv, hrs, fun hadj => hnrs hadj.symm⟩
    by_cases hwz : w = z
    · -- the two non-edges share their partner: `{u, v, w}` is independent
      have hnuw : ¬ G.Adj u w := by rw [hwz]; exact hnuz
      exact not_independent_triple_of_not_colorable hcard h huv (Ne.symm hwu) (Ne.symm hwv)
        hnuv hnuw hnvw
    · -- the non-edges `{v, w}` and `{u, z}` are disjoint
      exact not_two_disjoint_nonedges_of_not_colorable hcard h (Ne.symm hwv) (Ne.symm hzu)
        (Ne.symm huv) (Ne.symm hzv) hwu hwz hnvw hnuz

/-- **Hadwiger's conjecture holds for all graphs with at most `k + 2` vertices**,
for every `k` — including the open cases `k ≥ 5`.  This is one vertex beyond
`hadwiger_of_card_le_succ`, where the graph is no longer forced to be complete. -/
theorem hadwiger_of_card_le_add_two [Fintype V] (hcard : Fintype.card V ≤ k + 2)
    (h : ¬ G.Colorable k) : CompleteMinor (k + 1) G := by
  classical
  rcases Nat.lt_or_ge (Fintype.card V) (k + 2) with hlt | hge
  · exact hadwiger_of_card_le_succ (by omega) h
  · have hcardeq : Fintype.card V = k + 2 := le_antisymm hcard hge
    obtain ⟨x, hx⟩ := exists_clique_of_not_colorable_card_add_two hcardeq h
    exact completeMinor_of_isNClique hx

end Hadwiger

#print axioms Hadwiger.colorable_of_two_contractions
#print axioms Hadwiger.exists_clique_of_not_colorable_card_add_two
#print axioms Hadwiger.hadwiger_of_card_le_add_two