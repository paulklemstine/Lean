import Algebra.NonBacktracking.RelWalkCount

/-!
# `trace (Bⁿ)` counts rooted closed non-backtracking walks of length `n`

Let `G` be a finite simple graph and let `B` be its **Hashimoto (non-backtracking)
matrix**: the `0-1` matrix indexed by the *darts* (oriented edges) of `G` with

`B d d' = 1` iff `d` and `d'` are composable (`d.snd = d'.fst`) and `d'` is not the
reversal of `d`.

The main results of this file are the two forms of the trace formula:

* `Hashimoto.trace_hashimoto_pow` :
  `trace (B ^ n) = #{ rooted closed non-backtracking walks of length n }`,
  where such a walk is a list of `n + 1` darts, consecutive darts composable without
  backtracking, whose first and last dart agree (the root);
* `Hashimoto.trace_hashimoto_pow_eq_card_nbCycles` (for `1 ≤ n`) :
  `trace (B ^ n) = #{ cyclically non-backtracking sequences of n darts }`,
  the classical "rooted closed non-backtracking walk of length `n`" of Ihara-zeta
  theory: `n` darts arranged in a cycle, non-backtracking also across the seam.

Both counts are genuine finite cardinalities (`Finset.card`), and the two counting
sets are proved to be in bijection (`Hashimoto.card_nbCycles`).

We also prove the first structural consequences:

* `Hashimoto.trace_hashimoto_pow_zero` : `trace (B ^ 0) = #darts = ∑ v, deg v`;
* `Hashimoto.trace_hashimoto` and `Hashimoto.trace_hashimoto_sq` : `trace B = trace (B²) = 0`
  (a graph has no closed non-backtracking walks of length `1` or `2`);
* `Hashimoto.rowSum_hashimoto` : the `d`-th row of `B` sums to `deg (d.snd) - 1`;
* `Hashimoto.trace_hashimoto_pow_le_of_regular` : for a `(q+1)`-regular graph,
  `trace (B ^ n) ≤ (#darts) * qⁿ`, i.e. the exponential growth rate of the number of
  closed non-backtracking walks is at most `q` (the Ihara/Alon–Boppana regime).

The underlying general digraph walk-counting machinery lives in
`Algebra.NonBacktracking.RelWalkCount`.
-/

open Finset RelWalkCount SimpleGraph

namespace Hashimoto

variable {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]

instance : DecidableEq G.Dart := fun d d' =>
  decidable_of_iff _ (SimpleGraph.Dart.ext_iff d d').symm

/-! ## The non-backtracking relation on darts -/

/-- Two darts are **non-backtracking adjacent** when the head of the first is the tail of
the second and the second is not the reversal of the first. -/
def NBAdj (d d' : G.Dart) : Prop := d.snd = d'.fst ∧ d'.snd ≠ d.fst

instance : DecidableRel (NBAdj G) := fun d d' => by unfold NBAdj; infer_instance

variable {G}

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
lemma nbAdj_iff_ne_symm {d d' : G.Dart} :
    NBAdj G d d' ↔ (d.snd = d'.fst ∧ d' ≠ d.symm) := by
  constructor
  · rintro ⟨h1, h2⟩
    refine ⟨h1, ?_⟩
    intro hd
    exact h2 (by rw [hd]; rfl)
  · rintro ⟨h1, h2⟩
    refine ⟨h1, ?_⟩
    intro h3
    exact h2 (SimpleGraph.Dart.ext _ _ (Prod.ext h1.symm h3))

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Non-backtracking adjacency is irreflexive: a dart never follows itself. -/
lemma nbAdj_irrefl (d : G.Dart) : ¬ NBAdj G d d := by
  rintro ⟨h1, h2⟩
  exact h2 h1

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- There are no non-backtracking `2`-cycles of darts. -/
lemma not_nbAdj_symm {d d' : G.Dart} (h : NBAdj G d d') : ¬ NBAdj G d' d := by
  rintro ⟨h1, h2⟩
  exact h.2 h1

variable (G)

/-! ## The Hashimoto matrix -/

/-- The **Hashimoto (non-backtracking) matrix** of a finite simple graph: the `0-1`
matrix indexed by darts of the non-backtracking adjacency relation. -/
def hashimoto : Matrix G.Dart G.Dart ℕ := relMatrix (NBAdj G)

omit [Fintype V] [DecidableRel G.Adj] in
@[simp] lemma hashimoto_apply (d d' : G.Dart) :
    hashimoto G d d' = if NBAdj G d d' then 1 else 0 := rfl

/-! ## Rooted closed non-backtracking walks -/

/-- A **rooted closed non-backtracking walk of length `n`** in `G`: a list of `n + 1`
darts, consecutive darts non-backtracking adjacent, whose first and last dart agree.
The first dart is the root. -/
def IsClosedNBWalk (n : ℕ) (l : List G.Dart) : Prop :=
  l.length = n + 1 ∧ List.IsChain (NBAdj G) l ∧ l.head? = l.getLast?

/-- The finset of rooted closed non-backtracking walks of length `n`. -/
def closedNBWalks (n : ℕ) : Finset (List G.Dart) := closedWalks (NBAdj G) n

@[simp] lemma mem_closedNBWalks {n : ℕ} {l : List G.Dart} :
    l ∈ closedNBWalks G n ↔ IsClosedNBWalk G n l :=
  mem_closedWalks (NBAdj G) n l

/-- **Main theorem.** The trace of the `n`-th power of the Hashimoto matrix is the number
of rooted closed non-backtracking walks of length `n`. -/
theorem trace_hashimoto_pow (n : ℕ) :
    (hashimoto G ^ n).trace = (closedNBWalks G n).card :=
  trace_relMatrix_pow (NBAdj G) n

/-! ## The cyclic description -/

/-- The finset of **cyclically non-backtracking closed sequences of `n` darts**, obtained
from rooted closed non-backtracking walks by deleting the repeated final dart. -/
def nbCycles (n : ℕ) : Finset (List G.Dart) := (closedNBWalks G n).image List.dropLast

variable {G}

/-- `getLast?` ignores a prepended element as long as the tail is nonempty. -/
private lemma head?_dropLast {α : Type*} {l : List α} (h : 2 ≤ l.length) :
    l.dropLast.head? = l.head? := by
  match l, h with
  | x :: y :: t, _ => simp [List.dropLast]

/-- A closed walk is its own truncation with the root appended again. -/
private lemma eq_dropLast_append {α : Type*} {l : List α} (hne : l ≠ []) {x : α}
    (hx : l.head? = some x) (hend : l.head? = l.getLast?) : l = l.dropLast ++ [x] := by
  have hg : l.getLast? = some (l.getLast hne) := List.getLast?_eq_some_getLast hne
  have hsome : some (l.getLast hne) = some x := by rw [← hg, ← hend, hx]
  have hgx : l.getLast hne = x := by simpa using hsome
  conv_lhs => rw [← List.dropLast_append_getLast hne, hgx]

/-- Membership in `nbCycles`: sequences of `n` darts which are non-backtracking along the
sequence **and across the seam** from the last dart back to the first. -/
theorem mem_nbCycles {n : ℕ} (hn : 1 ≤ n) {c : List G.Dart} :
    c ∈ nbCycles G n ↔
      c.length = n ∧ List.IsChain (NBAdj G) c ∧
        ∀ x ∈ c.getLast?, ∀ y ∈ c.head?, NBAdj G x y := by
  constructor
  · rintro hc
    simp only [nbCycles, Finset.mem_image] at hc
    obtain ⟨l, hl, rfl⟩ := hc
    rw [mem_closedNBWalks] at hl
    obtain ⟨hlen, hchain, hend⟩ := hl
    have h2 : 2 ≤ l.length := by omega
    have hne : l ≠ [] := by intro h; rw [h] at hlen; simp at hlen
    obtain ⟨x, hx⟩ : ∃ x, l.head? = some x := by
      cases l with
      | nil => exact absurd rfl hne
      | cons a t => exact ⟨a, rfl⟩
    have hrep : l = l.dropLast ++ [x] := eq_dropLast_append hne hx hend
    have hchain' := hchain
    rw [hrep, List.isChain_append] at hchain'
    refine ⟨by simp [List.length_dropLast, hlen], hchain'.1, ?_⟩
    intro z hz y hy
    rw [head?_dropLast h2, hx] at hy
    have hxy : x = y := by simpa using hy
    have hfin := hchain'.2.2 z hz x (by simp)
    rwa [hxy] at hfin
  · rintro ⟨hlen, hchain, hseam⟩
    have hne : c ≠ [] := by
      intro h; rw [h] at hlen; simp at hlen; omega
    obtain ⟨x, hx⟩ : ∃ x, c.head? = some x := by
      cases c with
      | nil => exact absurd rfl hne
      | cons a t => exact ⟨a, rfl⟩
    simp only [nbCycles, Finset.mem_image]
    refine ⟨c ++ [x], ?_, by simp⟩
    rw [mem_closedNBWalks]
    refine ⟨by simp [hlen], ?_, ?_⟩
    · rw [List.isChain_append]
      refine ⟨hchain, List.isChain_singleton _, ?_⟩
      intro z hz y hy
      have hxy : x = y := by simpa using hy
      rw [← hxy]
      exact hseam z hz x hx
    · have h1 : (c ++ [x]).head? = some x := by
        cases c with
        | nil => exact absurd rfl hne
        | cons a t => simpa using hx
      rw [h1]
      simp

/-- Deleting the repeated final dart is a bijection between rooted closed
non-backtracking walks of length `n ≥ 1` and cyclically non-backtracking dart cycles. -/
theorem card_nbCycles {n : ℕ} (hn : 1 ≤ n) :
    (nbCycles G n).card = (closedNBWalks G n).card := by
  refine Finset.card_image_of_injOn ?_
  intro l₁ h₁ l₂ h₂ hEq
  rw [Finset.mem_coe, mem_closedNBWalks] at h₁ h₂
  obtain ⟨hlen₁, -, hend₁⟩ := h₁
  obtain ⟨hlen₂, -, hend₂⟩ := h₂
  have hne₁ : l₁ ≠ [] := by intro h; rw [h] at hlen₁; simp at hlen₁
  have hne₂ : l₂ ≠ [] := by intro h; rw [h] at hlen₂; simp at hlen₂
  have h2₁ : 2 ≤ l₁.length := by omega
  have h2₂ : 2 ≤ l₂.length := by omega
  obtain ⟨x, hx⟩ : ∃ x, l₁.head? = some x := by
    cases l₁ with
    | nil => exact absurd rfl hne₁
    | cons a t => exact ⟨a, rfl⟩
  obtain ⟨y, hy⟩ : ∃ y, l₂.head? = some y := by
    cases l₂ with
    | nil => exact absurd rfl hne₂
    | cons a t => exact ⟨a, rfl⟩
  have hxy : x = y := by
    have e₁ : l₁.dropLast.head? = some x := by rw [head?_dropLast h2₁, hx]
    have e₂ : l₂.dropLast.head? = some y := by rw [head?_dropLast h2₂, hy]
    rw [hEq, e₂] at e₁
    simpa using e₁.symm
  subst hxy
  rw [eq_dropLast_append hne₁ hx hend₁, eq_dropLast_append hne₂ hy hend₂, hEq]

variable (G)

/-- **Main theorem, cyclic form.** For `n ≥ 1`, the trace of `Bⁿ` is the number of
cyclically non-backtracking closed sequences of `n` darts. -/
theorem trace_hashimoto_pow_eq_card_nbCycles {n : ℕ} (hn : 1 ≤ n) :
    (hashimoto G ^ n).trace = (nbCycles G n).card := by
  rw [trace_hashimoto_pow, card_nbCycles hn]

/-! ## First consequences -/

/-- The trace of `B ^ 0` is the number of darts, i.e. the sum of the degrees. -/
theorem trace_hashimoto_pow_zero :
    (hashimoto G ^ 0).trace = ∑ v, G.degree v := by
  rw [pow_zero, Matrix.trace_one, ← SimpleGraph.dart_card_eq_sum_degrees]
  simp

/-- A graph has no rooted closed non-backtracking walk of length `1`. -/
theorem trace_hashimoto : (hashimoto G ^ 1).trace = 0 := by
  rw [pow_one, Matrix.trace]
  refine Finset.sum_eq_zero fun d _ => ?_
  simp [Matrix.diag, nbAdj_irrefl d]

/-- A graph has no rooted closed non-backtracking walk of length `2`: after leaving a dart
you may not come straight back. -/
theorem trace_hashimoto_sq : (hashimoto G ^ 2).trace = 0 := by
  rw [Matrix.trace]
  refine Finset.sum_eq_zero fun d _ => ?_
  simp only [Matrix.diag, pow_two, Matrix.mul_apply]
  refine Finset.sum_eq_zero fun d' _ => ?_
  simp only [hashimoto_apply]
  by_cases h : NBAdj G d d'
  · simp [if_neg (not_nbAdj_symm h)]
  · simp [if_neg h]

/-- There is no rooted closed non-backtracking walk of length `1` or `2`. -/
theorem card_closedNBWalks_one : (closedNBWalks G 1).card = 0 := by
  rw [← trace_hashimoto_pow, trace_hashimoto]

theorem card_closedNBWalks_two : (closedNBWalks G 2).card = 0 := by
  rw [← trace_hashimoto_pow, trace_hashimoto_sq]

/-! ## Length three: closed non-backtracking walks are oriented triangles -/

/-- Ordered triangles of `G`: triples of vertices that are cyclically adjacent.
Adjacency forces the three vertices to be pairwise distinct, so each (unordered)
triangle of `G` is counted `6` times. -/
def orderedTriangles : Finset (V × V × V) :=
  Finset.univ.filter fun t => G.Adj t.1 t.2.1 ∧ G.Adj t.2.1 t.2.2 ∧ G.Adj t.2.2 t.1

variable {G}

omit [DecidableEq V] in
@[simp] lemma mem_orderedTriangles {t : V × V × V} :
    t ∈ orderedTriangles G ↔ G.Adj t.1 t.2.1 ∧ G.Adj t.2.1 t.2.2 ∧ G.Adj t.2.2 t.1 := by
  simp [orderedTriangles]

/-- The three darts running around an ordered triangle. -/
def triDarts (t : V × V × V)
    (h : G.Adj t.1 t.2.1 ∧ G.Adj t.2.1 t.2.2 ∧ G.Adj t.2.2 t.1) : List G.Dart :=
  [⟨(t.1, t.2.1), h.1⟩, ⟨(t.2.1, t.2.2), h.2.1⟩, ⟨(t.2.2, t.1), h.2.2⟩]

variable (G)

/-- **Length-three trace.** `trace (B ^ 3)` is the number of ordered triangles of `G`
(equivalently `6` times the number of triangles): a closed non-backtracking walk of
length three has no choice but to run around a triangle. -/
theorem trace_hashimoto_cube :
    (hashimoto G ^ 3).trace = (orderedTriangles G).card := by
  rw [trace_hashimoto_pow_eq_card_nbCycles G (by norm_num)]
  refine (Finset.card_bij (fun t ht => triDarts t (mem_orderedTriangles.1 ht)) ?_ ?_ ?_).symm
  · intro t ht
    have hadj := mem_orderedTriangles.1 ht
    rw [mem_nbCycles (by norm_num : (1:ℕ) ≤ 3)]
    refine ⟨by simp [triDarts], ?_, ?_⟩
    · simp only [triDarts, List.isChain_cons_cons, List.IsChain.singleton, and_true]
      exact ⟨⟨rfl, by simpa using hadj.2.2.ne⟩, ⟨rfl, by simpa using hadj.1.ne⟩⟩
    · intro x hx y hy
      simp only [triDarts, List.getLast?_cons_cons, List.getLast?_singleton, Option.mem_def,
        Option.some.injEq] at hx
      simp only [triDarts, List.head?_cons, Option.mem_def, Option.some.injEq] at hy
      subst hx; subst hy
      exact ⟨rfl, by simpa using hadj.2.1.ne⟩
  · intro t₁ h₁ t₂ h₂ hEq
    simp only [triDarts, List.cons.injEq, and_true] at hEq
    obtain ⟨e1, e2, -⟩ := hEq
    have q1 : ((t₁.1, t₁.2.1) : V × V) = (t₂.1, t₂.2.1) :=
      congrArg SimpleGraph.Dart.toProd e1
    have q2 : ((t₁.2.1, t₁.2.2) : V × V) = (t₂.2.1, t₂.2.2) :=
      congrArg SimpleGraph.Dart.toProd e2
    simp only [Prod.mk.injEq] at q1 q2
    exact Prod.ext q1.1 (Prod.ext q1.2 q2.2)
  · intro c hc
    rw [mem_nbCycles (by norm_num : (1:ℕ) ≤ 3)] at hc
    obtain ⟨hlen, hchain, hseam⟩ := hc
    match c, hlen with
    | [d0, d1, d2], _ =>
      simp only [List.isChain_cons_cons, List.IsChain.singleton, and_true] at hchain
      have hs : NBAdj G d2 d0 := hseam d2 (by simp) d0 (by simp)
      have hadj : G.Adj d0.fst d1.fst ∧ G.Adj d1.fst d2.fst ∧ G.Adj d2.fst d0.fst := by
        refine ⟨?_, ?_, ?_⟩
        · rw [← hchain.1.1]; exact d0.adj
        · rw [← hchain.2.1]; exact d1.adj
        · rw [← hs.1]; exact d2.adj
      refine ⟨(d0.fst, d1.fst, d2.fst), mem_orderedTriangles.2 hadj, ?_⟩
      show triDarts (d0.fst, d1.fst, d2.fst) _ = _
      simp only [triDarts, List.cons.injEq, and_true]
      refine ⟨SimpleGraph.Dart.ext _ _ (Prod.ext rfl hchain.1.1.symm), ?_, ?_⟩
      · exact SimpleGraph.Dart.ext _ _ (Prod.ext rfl hchain.2.1.symm)
      · exact SimpleGraph.Dart.ext _ _ (Prod.ext rfl hs.1.symm)

/-! ## Row sums and the Ihara growth bound -/

/-- The row of `B` indexed by a dart `d` sums to `deg (d.snd) - 1`: from the head of `d`
one may continue along any incident edge except the one just traversed. -/
theorem rowSum_hashimoto (d : G.Dart) :
    ∑ d' : G.Dart, hashimoto G d d' = G.degree d.snd - 1 := by
  have hcard : ∑ d' : G.Dart, hashimoto G d d'
      = (Finset.univ.filter fun d' : G.Dart => NBAdj G d d').card := by
    rw [Finset.card_filter]
    rfl
  rw [hcard]
  have hbij : (Finset.univ.filter fun d' : G.Dart => NBAdj G d d').card
      = ((G.neighborFinset d.snd).erase d.fst).card := by
    refine Finset.card_bij (fun d' _ => d'.snd) ?_ ?_ ?_
    · intro d' hd'
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hd'
      obtain ⟨h1, h2⟩ := hd'
      refine Finset.mem_erase.2 ⟨h2, ?_⟩
      rw [SimpleGraph.mem_neighborFinset, h1]
      exact d'.adj
    · intro d₁ h₁ d₂ h₂ hEq
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at h₁ h₂
      exact SimpleGraph.Dart.ext _ _ (Prod.ext (h₁.1 ▸ h₂.1 ▸ rfl) hEq)
    · intro w hw
      obtain ⟨hw1, hw2⟩ := Finset.mem_erase.1 hw
      rw [SimpleGraph.mem_neighborFinset] at hw2
      refine ⟨⟨(d.snd, w), hw2⟩, ?_, rfl⟩
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨rfl, hw1⟩
  rw [hbij, Finset.card_erase_of_mem, SimpleGraph.card_neighborFinset_eq_degree]
  rw [SimpleGraph.mem_neighborFinset]
  exact d.adj.symm

/-- For a `(q+1)`-regular graph every row of `B` sums to `q`. -/
theorem rowSum_hashimoto_of_regular {q : ℕ} (hreg : ∀ v, G.degree v = q + 1) (d : G.Dart) :
    ∑ d' : G.Dart, hashimoto G d d' = q := by
  rw [rowSum_hashimoto, hreg]
  omega

/-- **Ihara growth bound.** In a `(q+1)`-regular graph the number of rooted closed
non-backtracking walks of length `n` is at most `(#darts) · qⁿ`. -/
theorem trace_hashimoto_pow_le_of_regular {q : ℕ} (hreg : ∀ v, G.degree v = q + 1) (n : ℕ) :
    (hashimoto G ^ n).trace ≤ Fintype.card G.Dart * q ^ n := by
  rw [trace_hashimoto_pow]
  exact card_closedWalks_le (NBAdj G) (rowSum_hashimoto_of_regular G hreg) n

end Hashimoto