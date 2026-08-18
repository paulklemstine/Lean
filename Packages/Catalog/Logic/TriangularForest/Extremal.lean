import Logic.TriangularForest.Complexity

/-!
# The sparsity bound is attained for every odd order

`TriangularForest.two_mul_card_edgeFinset_le` says that a triangular forest on `n ≥ 1` vertices
satisfies `2e ≤ 3(n-1)`.  Here we show that this is *sharp for every odd `n`*, by exhibiting the
friendship (windmill) graphs `Fₖ`: `k` triangles glued at a common centre.

* `TriangularForest.isTriangularForest_of_unique_far_neighbour` — a structural membership
  criterion: if every vertex other than a fixed vertex `x` has at most one neighbour besides
  `x`, then the graph is a triangular forest.  This is the "windmill" criterion, and it is proved
  by a rotation argument on cycles rather than by a finite check;
* `TriangularForest.fan` — the friendship graph `Fₖ` on `2k+1` vertices;
* `TriangularForest.isTriangularForest_fan` — `Fₖ` is a triangular forest;
* `TriangularForest.card_edgeFinset_fan` — `Fₖ` has exactly `3k` edges;
* `TriangularForest.sparsity_bound_attained` — hence `2e = 3(n-1)` for `n = 2k+1`: the bound of
  `two_mul_card_edgeFinset_le` cannot be improved for any odd order.
-/

namespace TriangularForest

open SimpleGraph Finset

variable {V : Type*} {G : SimpleGraph V}

section Criterion

/-- Rotating a closed walk preserves its length. -/
theorem length_rotate [DecidableEq V] {v x : V} (c : G.Walk v v) (h : x ∈ c.support) :
    (c.rotate h).length = c.length := by
  obtain ⟨n, hn⟩ := c.rotate_edges h
  have hlen : (c.rotate h).edges.length = c.edges.length := by
    rw [← hn, List.length_rotate]
  simpa [Walk.length_edges] using hlen

/-- **Windmill criterion.**  If every vertex other than `x` has at most one neighbour different
from `x`, then `G` is a triangular forest: a cycle avoiding `x` would have a vertex with two
distinct neighbours off `x`, and a cycle through `x` must return to `x` after two steps. -/
theorem isTriangularForest_of_unique_far_neighbour (x : V)
    (h : ∀ a b c : V, a ≠ x → b ≠ x → c ≠ x → G.Adj a b → G.Adj a c → b = c) :
    IsTriangularForest G := by
  classical
  intro v c hc
  by_contra hlen
  have h3 := hc.three_le_length
  by_cases hx : x ∈ c.support
  · -- rotate so that the cycle starts at `x`; then `getVert 1, 2, 3` avoid `x`
    set c' := c.rotate hx with hc'def
    have hc' : c'.IsCycle := hc.rotate hx
    have hL : c'.length = c.length := length_rotate c hx
    have h4 : 4 ≤ c'.length := by omega
    have hne : ∀ i, 1 ≤ i → i < c'.length → c'.getVert i ≠ x := by
      intro i hi1 hi2 hcon
      have := (hc'.getVert_endpoint_iff (le_of_lt hi2)).1 hcon
      omega
    have h12 : G.Adj (c'.getVert 1) (c'.getVert 2) := c'.adj_getVert_succ (by omega)
    have h23 : G.Adj (c'.getVert 2) (c'.getVert 3) := c'.adj_getVert_succ (by omega)
    have hmid := h (c'.getVert 2) (c'.getVert 1) (c'.getVert 3) (hne 2 (by omega) (by omega))
      (hne 1 (by omega) (by omega)) (hne 3 (by omega) (by omega)) h12.symm h23
    have := hc'.getVert_injOn' (by simp only [Set.mem_setOf_eq]; omega)
      (by simp only [Set.mem_setOf_eq]; omega : (3 : ℕ) ∈ {i | i ≤ c'.length - 1}) hmid
    omega
  · -- the cycle avoids `x` entirely, so its second vertex has two distinct far neighbours
    have hne : ∀ i, c.getVert i ≠ x := fun i hcon => hx (hcon ▸ c.getVert_mem_support i)
    have h01 : G.Adj (c.getVert 0) (c.getVert 1) := c.adj_getVert_succ (by omega)
    have h12 : G.Adj (c.getVert 1) (c.getVert 2) := c.adj_getVert_succ (by omega)
    have hmid := h (c.getVert 1) (c.getVert 0) (c.getVert 2) (hne 1) (hne 0) (hne 2) h01.symm h12
    have := hc.getVert_injOn' (by simp only [Set.mem_setOf_eq]; omega)
      (by simp only [Set.mem_setOf_eq]; omega : (2 : ℕ) ∈ {i | i ≤ c.length - 1}) hmid
    omega

end Criterion

section Fan

/-- Adjacency of the friendship graph on `{0, 1, …, 2k}`: the centre `0` is adjacent to
everything, and `2i-1` is matched with `2i`. -/
def FanAdj (a b : ℕ) : Prop :=
  a ≠ b ∧ (a = 0 ∨ b = 0 ∨ (a + 1 = b ∧ a % 2 = 1) ∨ (b + 1 = a ∧ b % 2 = 1))

instance : DecidableRel FanAdj := fun a b => by unfold FanAdj; infer_instance

/-- The friendship (windmill) graph `Fₖ`: `k` triangles glued at the centre `0`. -/
def fan (k : ℕ) : SimpleGraph (Fin (2 * k + 1)) where
  Adj a b := FanAdj a.val b.val
  symm := by
    intro a b hab
    unfold FanAdj at hab ⊢
    omega
  loopless := ⟨fun a ha => by unfold FanAdj at ha; omega⟩

instance (k : ℕ) : DecidableRel (fan k).Adj := fun a b =>
  inferInstanceAs (Decidable (FanAdj a.val b.val))

theorem fan_adj {k : ℕ} {a b : Fin (2 * k + 1)} :
    (fan k).Adj a b ↔ a.val ≠ b.val ∧ (a.val = 0 ∨ b.val = 0 ∨
      (a.val + 1 = b.val ∧ a.val % 2 = 1) ∨ (b.val + 1 = a.val ∧ b.val % 2 = 1)) := Iff.rfl

/-- The friendship graph is a triangular forest. -/
theorem isTriangularForest_fan (k : ℕ) : IsTriangularForest (fan k) := by
  refine isTriangularForest_of_unique_far_neighbour (0 : Fin (2 * k + 1)) ?_
  intro a b c ha hb hc hab hac
  rw [fan_adj] at hab hac
  have ha' : a.val ≠ 0 := fun h => ha (Fin.ext (by simpa using h))
  have hb' : b.val ≠ 0 := fun h => hb (Fin.ext (by simpa using h))
  have hc' : c.val ≠ 0 := fun h => hc (Fin.ext (by simpa using h))
  exact Fin.ext (by omega)

/-- The centre of the friendship graph is adjacent to every other vertex. -/
theorem fan_neighborFinset_zero (k : ℕ) :
    (fan k).neighborFinset 0 = (univ : Finset (Fin (2 * k + 1))).erase 0 := by
  ext b
  simp only [mem_neighborFinset, Finset.mem_erase, Finset.mem_univ, and_true, fan_adj]
  constructor
  · rintro ⟨hne, -⟩
    intro hb
    exact hne (by simp [hb])
  · intro hb
    have hb' : b.val ≠ 0 := fun h => hb (Fin.ext (by simpa using h))
    have hz : ((0 : Fin (2 * k + 1)) : ℕ) = 0 := rfl
    omega

/-- Away from the centre, the friendship graph is a perfect matching: the partner of `a`. -/
def fanPartner {k : ℕ} (a : Fin (2 * k + 1)) : Fin (2 * k + 1) :=
  ⟨if a.val % 2 = 1 then a.val + 1 else a.val - 1, by
    have h := a.isLt
    split_ifs <;> omega⟩

/-- Every non-central vertex has exactly the centre and its partner as neighbours. -/
theorem fan_neighborFinset_of_ne_zero {k : ℕ} {a : Fin (2 * k + 1)} (ha : a ≠ 0) :
    (fan k).neighborFinset a = {0, fanPartner a} := by
  have ha' : a.val ≠ 0 := fun h => ha (Fin.ext (by simpa using h))
  ext b
  simp only [mem_neighborFinset, Finset.mem_insert, Finset.mem_singleton, fan_adj]
  have hz : ((0 : Fin (2 * k + 1)) : ℕ) = 0 := rfl
  have hp : (fanPartner a : ℕ) = if (a : ℕ) % 2 = 1 then (a : ℕ) + 1 else (a : ℕ) - 1 := rfl
  have haLt := a.isLt
  constructor
  · rintro ⟨hne, h⟩
    by_cases hb : b.val = 0
    · exact Or.inl (Fin.ext (by omega))
    · refine Or.inr (Fin.ext ?_)
      split_ifs at hp <;> omega
  · rintro (rfl | rfl)
    · omega
    · split_ifs at hp <;> omega

theorem fanPartner_ne_zero {k : ℕ} {a : Fin (2 * k + 1)} (ha : a ≠ 0) :
    fanPartner a ≠ (0 : Fin (2 * k + 1)) := by
  have ha' : a.val ≠ 0 := fun h => ha (Fin.ext (by simpa using h))
  intro hcon
  have hp : (fanPartner a : ℕ) = if (a : ℕ) % 2 = 1 then (a : ℕ) + 1 else (a : ℕ) - 1 := rfl
  have hz : ((0 : Fin (2 * k + 1)) : ℕ) = 0 := rfl
  have hval : (fanPartner a).val = ((0 : Fin (2 * k + 1)) : ℕ) := by rw [hcon]
  split_ifs at hp <;> omega

theorem fan_degree_of_ne_zero {k : ℕ} {a : Fin (2 * k + 1)} (ha : a ≠ 0) :
    (fan k).degree a = 2 := by
  rw [← card_neighborFinset_eq_degree, fan_neighborFinset_of_ne_zero ha,
    Finset.card_insert_of_notMem (by simpa using (fanPartner_ne_zero ha).symm)]
  simp

theorem fan_degree_zero (k : ℕ) : (fan k).degree 0 = 2 * k := by
  rw [← card_neighborFinset_eq_degree, fan_neighborFinset_zero,
    Finset.card_erase_of_mem (Finset.mem_univ _)]
  simp

/-- **The friendship graph `Fₖ` has exactly `3k` edges.** -/
theorem card_edgeFinset_fan (k : ℕ) : #(fan k).edgeFinset = 3 * k := by
  have hsum : ∑ v : Fin (2 * k + 1), (fan k).degree v = 6 * k := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ (0 : Fin (2 * k + 1)))]
    rw [fan_degree_zero]
    have hconst : ∀ v ∈ (univ : Finset (Fin (2 * k + 1))).erase 0, (fan k).degree v = 2 := by
      intro v hv
      exact fan_degree_of_ne_zero (Finset.mem_erase.1 hv).1
    rw [Finset.sum_congr rfl hconst, Finset.sum_const,
      Finset.card_erase_of_mem (Finset.mem_univ _)]
    simp only [Finset.card_univ, Fintype.card_fin, smul_eq_mul]
    omega
  have h2 := (fan k).sum_degrees_eq_twice_card_edges
  omega

/-- **The sparsity bound `2e ≤ 3(n-1)` is attained for every odd order `n = 2k+1`.**  The
friendship graph `Fₖ` is a triangular forest with `2e = 6k = 3(n-1)`, so
`TriangularForest.two_mul_card_edgeFinset_le` is sharp for infinitely many orders, not only for
the triangle. -/
theorem sparsity_bound_attained (k : ℕ) :
    IsTriangularForest (fan k) ∧
      2 * #(fan k).edgeFinset = 3 * (Fintype.card (Fin (2 * k + 1)) - 1) := by
  refine ⟨isTriangularForest_fan k, ?_⟩
  rw [card_edgeFinset_fan]
  simp only [Fintype.card_fin]
  omega

end Fan

section Thickness

/-- **Sharp linear lower bound on the triangular thickness of `Kₙ`.**  Covering the edges of `Kₙ`
(`n ≥ 2`) by `k` triangular forests forces `n ≤ 3k`.  This improves
`TriangularForest.triangularThickness_lower_bound` (`n - 1 ≤ 4k`) by feeding the sharp sparsity
bound `2e ≤ 3(n-1)` into the counting argument, and by `sparsity_bound_attained` the sparsity
input can no longer be improved. -/
theorem triangularThickness_lower_bound_sharp {n k : ℕ} (hn : 2 ≤ n)
    (H : Fin k → SimpleGraph (Fin n)) [∀ i, DecidableRel (H i).Adj]
    (hTF : ∀ i, IsTriangularForest (H i))
    (hcov : ∀ x y : Fin n, x ≠ y → ∃ i, (H i).Adj x y) :
    n ≤ 3 * k := by
  classical
  have hcard : 1 ≤ Fintype.card (Fin n) := by simpa using Nat.one_le_of_lt hn
  have hsum : #(⊤ : SimpleGraph (Fin n)).edgeFinset ≤ ∑ i, #(H i).edgeFinset :=
    card_edgeFinset_le_sum_of_cover _ H fun x y hxy => hcov x y (by simpa using hxy)
  have hbound : ∀ i, 2 * #(H i).edgeFinset ≤ 3 * (n - 1) := fun i => by
    have := two_mul_card_edgeFinset_le (H i) (hTF i) hcard
    simpa using this
  have hsum2 : ∑ i, 2 * #(H i).edgeFinset ≤ ∑ _i : Fin k, (3 * (n - 1)) :=
    Finset.sum_le_sum fun i _ => hbound i
  rw [← Finset.mul_sum] at hsum2
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul] at hsum2
  have htop : #(⊤ : SimpleGraph (Fin n)).edgeFinset = n.choose 2 := by
    rw [SimpleGraph.card_edgeFinset_top_eq_card_choose_two]
    simp
  have hchoose : 2 * n.choose 2 = n * (n - 1) := by
    obtain ⟨r, hr⟩ := Nat.even_mul_pred_self n
    rw [Nat.choose_two_right, hr]
    omega
  rw [htop] at hsum
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 2 := ⟨n - 2, by omega⟩
  have hsub : m + 2 - 1 = m + 1 := by omega
  rw [hsub] at hsum2 hchoose
  nlinarith [hsum, hsum2, hchoose]

end Thickness

end TriangularForest

/-!
## Lab notes (cycle 3)

Hypotheses entering this cycle, and their fate.

* **H20** *(the sparsity bound `2e ≤ 3(n-1)` is attained only by the triangle)* — **false**.
  A brute-force enumeration of all graphs on `n ≤ 7` vertices (see `ComputationalEvidence.md`)
  gives maxima `e = 1, 3, 4, 6, 7, 9` for `n = 2,…,7`, i.e. exactly `⌊3(n-1)/2⌋`; the maximisers
  for odd `n` are the windmills.  Formalised here as `sparsity_bound_attained`, which upgrades
  the single example `triangle_tight` to an infinite family.
* **H21** *(windmills are triangular forests)* — **true**, and the proof generalises: what is
  really needed is only that every vertex other than the hub has at most one further neighbour
  (`isTriangularForest_of_unique_far_neighbour`).  The rotation trick used for 1-sums
  (`Logic.TriangularForest.OneSum`) is what makes this a three-line cycle analysis instead of an
  induction on block decompositions.
* **H22** *(the thickness bound `n - 1 ≤ 4k` of cycle 1 is not optimal)* — **true**: replacing
  the input `e ≤ 2n - 3` by the sharp `2e ≤ 3(n-1)` yields `n ≤ 3k`
  (`triangularThickness_lower_bound_sharp`), asymptotically a factor `4/3` better, and by H20
  the counting input is now optimal.  Any further improvement must therefore come from a global
  obstruction rather than from edge counting.  A randomised search (unverified, recorded in
  `ComputationalEvidence.md`) finds covers of `Kₙ` by exactly `⌈n/3⌉` triangular forests for
  every `n ≤ 11` **except** `n = 6`, where the counting bound allows `k = 2` but
  `completeGraph_not_decomposesIntoTwo_six` rules it out.  So the counting bound is essentially
  tight, with a single small exception.
* **H23** *(decomposability into two triangular forests has succinct certificates)* — **true**
  (`decomposesIntoTwo_iff_exists_edgeColoring`), and the certificate view makes the problem
  decidable (`instDecidableDecomposesIntoTwo`); evaluating that decision procedure on `K₄`
  returns `true`, matching the explicit `K₅` decomposition of cycle 1.
-/