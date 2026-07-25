import Mathlib

/-!
# Trail incidence counting in finite undirected multigraphs

This file develops, from scratch and self-contained, a small theory of *trails* in finite
undirected multigraphs together with a complete account of **incidence counting** along a trail,
ending with the classical necessary degree condition for Eulerian trails.

## Model

A finite undirected multigraph is modelled by a vertex type `V` and an edge type `E`
(both finite with decidable equality) and an unordered endpoint map `ends : E → Sym2 V`.
Using `Sym2 V` makes the endpoints genuinely unordered and allows **parallel edges**
(distinct `e₁ e₂ : E` may have equal endpoints) and **loops** (`ends e = s(v, v)`).

A `Trail` is a walk recorded as a list of vertices `verts` and a list of edges `edges`
with `edges.length + 1 = verts.length`, a stepwise adjacency witness saying that the `i`-th
edge has endpoints `{verts[i], verts[i+1]}`, and the trail condition `edges.Nodup`
(no edge is repeated).

## Incidence count

For a vertex `v`, `incidences T v` counts, over all steps of the trail, how many of the two
endpoints of each step equal `v`.  Concretely it is the number of occurrences of `v` among the
step *tails* (`verts.dropLast`) plus the number among the step *heads* (`verts.tail`).
A loop step `v → v` therefore contributes `2` to `incidences T v`, exactly as a loop contributes
`2` to a vertex degree.

## Main results

* `Trail.sum_incidences`         : `∑ v, incidences T v = 2 * (number of trail edges)`.
* `Trail.incidences_add_endpoint`: the exact local identity
    `incidences T v + endpointContribution T v = 2 * visits T v`,
  where `visits T v` is the total number of times `v` is visited and `endpointContribution T v`
  is `1` for each of the two trail ends equal to `v` (so `2` when `v` is both start and end of a
  closed trail).
* `Trail.incidences_eq_internal` : the "twice internal pairings plus endpoint" form
    `incidences T v = 2 * internalVisits T v + endpointContribution T v`
  for a nontrivial trail (`edges ≠ []`), where `internalVisits T v` counts occurrences of `v`
  among the interior vertices.
* Parity corollaries:
  - `Trail.even_incidences_of_not_endpoint` : a non-endpoint vertex has even incidence count;
  - `Trail.odd_incidences_imp_endpoint`     : in an open trail only the two endpoints can have
    odd incidence count;
  - `Trail.even_incidences_of_closed`       : in a closed trail every vertex has even incidence
    count.
* Eulerian necessary condition:
  - `Trail.eulerian_incidences_eq_degree`            : along an Eulerian trail the incidence
    count of every vertex equals its graph degree;
  - `Trail.eulerian_card_odd_degree_le_two`          : a graph admitting an Eulerian trail has at
    most two odd-degree vertices;
  - `Trail.eulerian_closed_card_odd_degree_eq_zero`  : if the Eulerian trail is closed there are
    no odd-degree vertices.

Loops and parallel edges are fully supported by this development.
-/

open scoped BigOperators

namespace TrailIncidence

/-- A finite undirected multigraph: an unordered endpoint map on the edge type. -/
structure Multigraph (V E : Type*) where
  /-- The unordered pair of endpoints of an edge. -/
  ends : E → Sym2 V

variable {V E : Type*}

/-- An edge `e` is incident to a vertex `v` when `v` is one of its endpoints. -/
def Multigraph.Inc (G : Multigraph V E) (e : E) (v : V) : Prop := v ∈ G.ends e

/-- A trail in `G`: a walk (vertices `verts`, edges `edges`, length compatible, with the
stepwise adjacency witness) whose edge list has no repeats. -/
structure Trail (G : Multigraph V E) where
  /-- The vertices visited, in order. -/
  verts : List V
  /-- The edges traversed, in order. -/
  edges : List E
  /-- One more vertex than edges. -/
  length_eq : edges.length + 1 = verts.length
  /-- The `i`-th edge connects the `i`-th and `(i+1)`-th vertices. -/
  adj : ∀ i : Fin edges.length,
      G.ends (edges.get i) = s(verts.get ⟨i, by omega⟩, verts.get ⟨i + 1, by omega⟩)
  /-- The defining trail condition: no repeated edge. -/
  nodup : edges.Nodup

/-! ### A list-sum lemma over a finite type -/

/-- The sum of `f` over a duplicate-free list that contains every element of a fintype equals the
sum of `f` over the whole type. -/
theorem sum_map_of_nodup_all [Fintype E] [DecidableEq E] (l : List E) (hnd : l.Nodup)
    (hall : ∀ e, e ∈ l) (f : E → ℕ) :
    (l.map f).sum = ∑ e : E, f e := by
  have hperm : List.Perm l Finset.univ.toList := by
    apply (List.perm_ext_iff_of_nodup hnd (Finset.nodup_toList _)).2
    intro e; simp [hall e]
  rw [List.Perm.sum_eq (hperm.map f), Finset.sum_map_toList]

/-! ### Edge multiplicity at a vertex -/

variable [DecidableEq V]

/-- The multiplicity of a vertex `v` in an unordered edge `s`: `0`, `1`, or (for a loop at `v`)
`2`.  This is the contribution of one edge to the degree of `v`. -/
def sym2mult (s : Sym2 V) (v : V) : ℕ := (Sym2.toMultiset s).count v

@[simp] theorem sym2mult_mk (a b v : V) :
    sym2mult s(a, b) v = (if a = v then 1 else 0) + (if b = v then 1 else 0) := by
  unfold sym2mult
  simp only [Sym2.toMultiset]
  by_cases h1 : a = v <;> by_cases h2 : b = v <;> simp [h1, h2, eq_comm]

/-! ### Generic list-counting lemmas -/

/-- Splitting off the head when counting in a list. -/
theorem count_eq_head_add_tail (l : List V) (v : V) :
    l.count v = (if l.head? = some v then 1 else 0) + l.tail.count v := by
  cases l with
  | nil => simp
  | cons a t =>
    simp only [List.head?_cons, List.tail_cons, List.count_cons, Option.some.injEq, beq_iff_eq]
    rw [add_comm]

/-- Splitting off the last element when counting in a list. -/
theorem count_eq_dropLast_add_getLast (l : List V) (v : V) :
    l.count v = l.dropLast.count v + (if l.getLast? = some v then 1 else 0) := by
  rcases eq_or_ne l [] with h | h
  · subst h; simp
  · conv_lhs => rw [← List.dropLast_append_getLast h]
    rw [List.count_append, List.getLast?_eq_some_getLast h]
    simp [List.count_singleton', eq_comm]

/-- Summing the multiplicity of every element of a fintype recovers the list length. -/
theorem sum_count_eq_length [Fintype V] (l : List V) :
    ∑ v : V, l.count v = l.length := by
  induction l with
  | nil => simp
  | cons a t ih =>
    simp only [List.count_cons, List.length_cons, Finset.sum_add_distrib, ih, beq_iff_eq]
    have : ∑ x : V, (if a = x then 1 else 0) = 1 := by simp
    rw [this]

/-- For a list of length at least two, the count split underlying the interior identity:
the step tails (`dropLast`) plus the step heads (`tail`) decompose as twice the interior count
plus the two endpoint indicators. -/
theorem count_dropLast_add_tail_interior (l : List V) (v : V) (hl : 2 ≤ l.length) :
    l.dropLast.count v + l.tail.count v
      = 2 * l.tail.dropLast.count v
        + (if l.head? = some v then 1 else 0) + (if l.getLast? = some v then 1 else 0) := by
  match l, hl with
  | a :: t, hl =>
    have ht : t ≠ [] := by intro h; subst h; simp at hl
    have hdl : (a :: t).dropLast = a :: t.dropLast := List.dropLast_cons_of_ne_nil ht
    have hgl : (a :: t).getLast? = t.getLast? := by
      cases t with
      | nil => simp at ht
      | cons b s => rw [List.getLast?_cons_cons]
    have hcount_t := count_eq_dropLast_add_getLast t v
    simp only [hdl, List.tail_cons, List.head?_cons, hgl, List.count_cons, Option.some.injEq,
      beq_iff_eq]
    rw [hcount_t]
    by_cases hav : a = v <;> simp [hav] <;> omega

/-- The count of `v` in a list is the sum of the `{0,1}`-indicators of its entries. -/
theorem count_eq_sum_map_indicator (l : List V) (v : V) :
    l.count v = (l.map (fun x => if x = v then 1 else 0)).sum := by
  induction l with
  | nil => simp
  | cons a t ih =>
    simp only [List.count_cons, List.map_cons, List.sum_cons, ih, beq_iff_eq]
    omega

/-- Summing a pointwise sum of two equal-length `ℕ`-lists splits as the sum of the two sums. -/
theorem sum_zipWith_add (p q : List ℕ) (h : p.length = q.length) :
    (List.zipWith (· + ·) p q).sum = p.sum + q.sum := by
  induction p generalizing q with
  | nil => cases q with | nil => simp | cons b q => simp at h
  | cons a p ih =>
    cases q with
    | nil => simp at h
    | cons b q =>
      simp only [List.zipWith_cons_cons, List.sum_cons, ih q (by simpa using h)]
      omega

/-- The degree of a vertex `v`: the number of incident edge-ends, with each loop at `v` counted
twice. -/
def Multigraph.degree [Fintype E] (G : Multigraph V E) (v : V) : ℕ :=
  ∑ e : E, sym2mult (G.ends e) v

namespace Trail

variable {G : Multigraph V E} (T : Trail G)

/-- The number of edge-endpoint incidences at `v` along the trail: the number of steps whose
tail is `v` plus the number whose head is `v`.  A loop step at `v` contributes `2`. -/
def incidences (v : V) : ℕ := T.verts.dropLast.count v + T.verts.tail.count v

/-- The total number of times the vertex `v` is visited by the trail. -/
def visits (v : V) : ℕ := T.verts.count v

/-- The number of occurrences of `v` among the *interior* vertices of the trail
(all vertices except the first and the last). -/
def internalVisits (v : V) : ℕ := T.verts.tail.dropLast.count v

/-- The endpoint contribution of `v`: `1` for each of the two trail ends equal to `v`.
It is `0` if `v` is neither end, `1` if `v` is exactly one end, and `2` if `v` is both the
start and the end (a closed trail returning to `v`). -/
def endpointContribution (v : V) : ℕ :=
  (if T.verts.head? = some v then 1 else 0) + (if T.verts.getLast? = some v then 1 else 0)

omit [DecidableEq V] in
/-- `verts` is nonempty. -/
theorem verts_ne_nil : T.verts ≠ [] := by
  have := T.length_eq
  intro h; rw [h] at this; simp at this

/-! ### The global incidence-count theorem -/

/-- **Main theorem.** The sum over all vertices of the trail-incidence count equals twice the
number of trail edges.  (Each step contributes exactly `2` to the global total: one for its tail
and one for its head.) -/
theorem sum_incidences [Fintype V] :
    ∑ v : V, T.incidences v = 2 * T.edges.length := by
  simp only [incidences, Finset.sum_add_distrib, sum_count_eq_length,
    List.length_dropLast, List.length_tail]
  have h := T.length_eq
  omega

/-! ### The local endpoint / internal-visits identity -/

/-- **Exact local identity.** The incidence count at `v` plus its endpoint contribution equals
twice the number of visits to `v`.  This is the precise statement underlying every parity
corollary below, and it holds for *all* trails (including the trivial one-vertex trail). -/
theorem incidences_add_endpoint (v : V) :
    T.incidences v + T.endpointContribution v = 2 * T.visits v := by
  have h1 := count_eq_dropLast_add_getLast T.verts v
  have h2 := count_eq_head_add_tail T.verts v
  simp only [incidences, endpointContribution, visits] at *
  omega

/-- For a nontrivial trail, the incidence count is twice the number of interior occurrences of
`v` plus the endpoint contribution. -/
theorem incidences_eq_internal (hne : T.edges ≠ []) (v : V) :
    T.incidences v = 2 * T.internalVisits v + T.endpointContribution v := by
  have hpos : 0 < T.edges.length := List.length_pos_of_ne_nil hne
  have hlen := T.length_eq
  have hl : 2 ≤ T.verts.length := by omega
  have hsplit := count_dropLast_add_tail_interior T.verts v hl
  simp only [incidences, internalVisits, endpointContribution]
  omega

/-! ### Parity corollaries -/

/-- A vertex that is neither the start nor the end of the trail has even incidence count. -/
theorem even_incidences_of_not_endpoint {v : V}
    (h1 : T.verts.head? ≠ some v) (h2 : T.verts.getLast? ≠ some v) :
    Even (T.incidences v) := by
  have h := incidences_add_endpoint T v
  simp only [endpointContribution, if_neg h1, if_neg h2, add_zero] at h
  exact ⟨T.visits v, by omega⟩

/-- In an **open** trail (the start and the end differ), only the two endpoints can have odd
incidence count: every vertex with odd incidence count is the start or the end.

The `open` hypothesis (start `≠` end) is part of the classical statement but is not actually
needed: a non-endpoint vertex has even incidence count in any trail, so it is kept here only to
match the usual phrasing. -/
theorem odd_incidences_imp_endpoint {v : V}
    (_hopen : T.verts.head? ≠ T.verts.getLast?) (hodd : Odd (T.incidences v)) :
    T.verts.head? = some v ∨ T.verts.getLast? = some v := by
  by_contra hcon
  push_neg at hcon
  exact (Nat.not_odd_iff_even.mpr
    (even_incidences_of_not_endpoint T hcon.1 hcon.2)) hodd

/-- In a **closed** trail (the start equals the end) every vertex has even incidence count. -/
theorem even_incidences_of_closed (hclosed : T.verts.head? = T.verts.getLast?) (v : V) :
    Even (T.incidences v) := by
  have h := incidences_add_endpoint T v
  have hep : Even (T.endpointContribution v) := by
    simp only [endpointContribution, ← hclosed]
    split <;> decide
  obtain ⟨k, hk⟩ := hep
  refine ⟨T.visits v - k, ?_⟩
  omega

/-! ### Bridge to graph degree and the Eulerian condition -/

/-- The list of per-edge multiplicities of `v` along the trail equals the pointwise sum of the
two endpoint indicators along the consecutive-vertex pairs. -/
theorem map_sym2mult_eq_zipWith (v : V) :
    T.edges.map (fun e => sym2mult (G.ends e) v)
      = List.zipWith (fun a b => (if a = v then 1 else 0) + (if b = v then 1 else 0))
          T.verts.dropLast T.verts.tail := by
  have hlen := T.length_eq
  apply List.ext_getElem
  · simp [List.length_zipWith, List.length_dropLast, List.length_tail]; omega
  · intro i h1 h2
    simp only [List.getElem_map, List.getElem_zipWith]
    have hi : i < T.edges.length := by simpa using h1
    have hadj := T.adj ⟨i, hi⟩
    rw [List.get_eq_getElem] at hadj
    simp only [hadj, sym2mult_mk, List.getElem_dropLast, List.getElem_tail, List.get_eq_getElem]

/-- **Bridge lemma.** The trail-incidence count of `v` equals the sum over the trail edges of the
edge multiplicity of `v`.  This connects the positional incidence count to the graph structure. -/
theorem incidences_eq_sum_edges (v : V) :
    T.incidences v = (T.edges.map (fun e => sym2mult (G.ends e) v)).sum := by
  rw [incidences, map_sym2mult_eq_zipWith]
  rw [show (List.zipWith (fun a b => (if a = v then 1 else 0) + (if b = v then 1 else 0))
            T.verts.dropLast T.verts.tail)
        = List.zipWith (· + ·) (T.verts.dropLast.map (fun x => if x = v then 1 else 0))
            (T.verts.tail.map (fun x => if x = v then 1 else 0)) from List.zipWith_map.symm]
  rw [sum_zipWith_add _ _ (by simp [List.length_dropLast, List.length_tail]),
      ← count_eq_sum_map_indicator, ← count_eq_sum_map_indicator]

/-- A trail is **Eulerian** if it traverses every edge of the graph.  Combined with the trail
condition `edges.Nodup`, this means it uses every edge exactly once. -/
def IsEulerian : Prop := ∀ e : E, e ∈ T.edges

/-- Along an Eulerian trail the incidence count of each vertex equals its graph degree. -/
theorem eulerian_incidences_eq_degree [Fintype E] [DecidableEq E]
    (hEul : T.IsEulerian) (v : V) : T.incidences v = G.degree v := by
  rw [incidences_eq_sum_edges, Multigraph.degree]
  exact sum_map_of_nodup_all T.edges T.nodup hEul _

/-- **Necessary condition for an Eulerian trail.** A graph that admits an Eulerian trail has at
most two vertices of odd degree (the possible endpoints of the trail). -/
theorem eulerian_card_odd_degree_le_two [Fintype V] [Fintype E] [DecidableEq E]
    (hEul : T.IsEulerian) :
    (Finset.univ.filter (fun v => Odd (G.degree v))).card ≤ 2 := by
  have hne := T.verts_ne_nil
  have hsub : (Finset.univ.filter (fun v => Odd (G.degree v)))
      ⊆ {T.verts.head hne, T.verts.getLast hne} := by
    intro v hv
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hv
    rw [← eulerian_incidences_eq_degree T hEul v] at hv
    by_contra hcon
    simp only [Finset.mem_insert, Finset.mem_singleton] at hcon
    push_neg at hcon
    have h1 : T.verts.head? ≠ some v := by
      rw [List.head?_eq_some_head hne]; simp; exact fun h => hcon.1 h.symm
    have h2 : T.verts.getLast? ≠ some v := by
      rw [List.getLast?_eq_some_getLast hne]; simp; exact fun h => hcon.2 h.symm
    exact (Nat.not_odd_iff_even.mpr (T.even_incidences_of_not_endpoint h1 h2)) hv
  refine (Finset.card_le_card hsub).trans ?_
  exact (Finset.card_insert_le _ _).trans (by simp)

/-- **Closed Eulerian trail.** If a graph admits a closed Eulerian trail (the start equals the
end), then every vertex has even degree. -/
theorem eulerian_closed_card_odd_degree_eq_zero [Fintype V] [Fintype E] [DecidableEq E]
    (hEul : T.IsEulerian) (hclosed : T.verts.head? = T.verts.getLast?) :
    (Finset.univ.filter (fun v => Odd (G.degree v))).card = 0 := by
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro v _
  rw [← eulerian_incidences_eq_degree T hEul v, Nat.not_odd_iff_even]
  exact T.even_incidences_of_closed hclosed v

end Trail

end TrailIncidence