import Mathlib
import Bridges.GraphTheory.K2UnionIndependentFree
import Combinatorics.K2UnionK1FreeInvariants
import Combinatorics.K2UnionK1FreeHierarchy
import Combinatorics.K2UnionK1FreeToughnessBounds

/-!
# The freeness parameter of a graph

`Combinatorics.K2UnionK1FreeHierarchy` shows that the classes of `(K₂ ∪ kK₁)`-free graphs
form a strictly increasing chain in `k`. This file turns that chain into a numerical
invariant.

* **Heredity.** `IsK2UnionK1Free.of_embedding` transports freeness along an induced
  embedding, so `IsK2UnionK1Free.induce` shows that the class is hereditary: every induced
  subgraph of a `(K₂ ∪ kK₁)`-free graph is `(K₂ ∪ kK₁)`-free.
* **Existence.** `free_of_indepNum_lt` shows that a finite graph is `(K₂ ∪ kK₁)`-free
  whenever `k` exceeds the independence number, so the set of admissible parameters is
  nonempty; `free_indepNum` sharpens this to `k = α(G)`.
* **The parameter.** `freeParam G` is the least `k` for which `G` is `(K₂ ∪ kK₁)`-free.
  `freeParam_le_iff` shows it is a genuine threshold, `freeParam_le_indepNum` bounds
  it by `α(G)`, `freeParam_eq_zero_iff` identifies the graphs with parameter `0` as the
  edgeless ones, and `freeParam_induce_le` records monotonicity under taking induced
  subgraphs.
* **Examples.** `freeParam_cycleGraph_five` computes the parameter of `C₅`,
  `freeParam_k2UnionK1` computes the parameter of the forbidden graph itself, and
  `freeParam_top_eq_one` computes it for complete graphs.
-/

open Finset SimpleGraph K2UnionIndependentFree K2UnionK1FreeInvariants
  K2UnionK1FreeHierarchy K2UnionK1FreeToughnessBounds

namespace K2UnionK1FreeParameter

variable {V W : Type*}

/-! ## Heredity -/

/-- Freeness transports along induced embeddings: if `H` embeds into `G` as an induced
subgraph and `G` is `(K₂ ∪ kK₁)`-free, then so is `H`. -/
theorem IsK2UnionK1Free.of_embedding {G : SimpleGraph V} {H : SimpleGraph W} {k : ℕ}
    (f : H ↪g G) (h : IsK2UnionK1Free G k) : IsK2UnionK1Free H k := by
  rw [free_iff_isEmpty_embedding] at h ⊢
  exact ⟨fun e => h.elim (e.trans f)⟩

/-- The class of `(K₂ ∪ kK₁)`-free graphs is hereditary. -/
theorem IsK2UnionK1Free.induce {G : SimpleGraph V} {k : ℕ} (h : IsK2UnionK1Free G k)
    (A : Set V) : IsK2UnionK1Free (G.induce A) k :=
  IsK2UnionK1Free.of_embedding (SimpleGraph.Embedding.comap _ G) h

/-! ## Existence of a freeness parameter -/

/-- A finite graph is `(K₂ ∪ kK₁)`-free as soon as `k` is larger than its independence
number: there is simply no independent set of size `k` to use. -/
theorem free_of_indepNum_lt [Finite V] {G : SimpleGraph V} {k : ℕ}
    (hk : G.indepNum < k) : IsK2UnionK1Free G k := by
  intro u v _ I hIcard hI _
  have := hI.card_le_indepNum
  omega

/-- **Sharper existence.** Every finite graph is `(K₂ ∪ α(G)K₁)`-free: an edge anticomplete
to an independent set of size `α(G)` could be used to enlarge that set. -/
theorem free_indepNum [Finite V] (G : SimpleGraph V) : IsK2UnionK1Free G G.indepNum := by
  classical
  intro u v huv I hIcard hI hanti
  have huI : u ∉ I := fun hmem => (hanti u hmem).2 huv.symm
  have hJ : G.IsIndepSet ((insert u I : Finset V) : Set V) := by
    intro x hx y hy hxy hadj
    simp only [Finset.coe_insert, Set.mem_insert_iff, Finset.mem_coe] at hx hy
    rcases hx with rfl | hx
    · rcases hy with rfl | hy
      · exact hxy rfl
      · exact (hanti y hy).1 hadj
    · rcases hy with rfl | hy
      · exact (hanti x hx).1 hadj.symm
      · exact hI hx hy hxy hadj
  have hcard := hJ.card_le_indepNum
  rw [Finset.card_insert_of_notMem huI, hIcard] at hcard
  omega

/-- Every finite graph is `(K₂ ∪ (α(G) + 1)K₁)`-free. -/
theorem free_succ_indepNum [Finite V] (G : SimpleGraph V) :
    IsK2UnionK1Free G (G.indepNum + 1) :=
  free_of_indepNum_lt (Nat.lt_succ_self _)

/-! ## The parameter itself -/

/-- The least `k` for which `G` is `(K₂ ∪ kK₁)`-free. -/
noncomputable def freeParam (G : SimpleGraph V) : ℕ := sInf {k | IsK2UnionK1Free G k}

theorem freeParam_spec [Finite V] (G : SimpleGraph V) :
    IsK2UnionK1Free G (freeParam G) := by
  have hmem : sInf {k | IsK2UnionK1Free G k} ∈ {k | IsK2UnionK1Free G k} :=
    Nat.sInf_mem ⟨G.indepNum + 1, free_succ_indepNum G⟩
  exact hmem

/-- `freeParam` is a genuine threshold: `G` is `(K₂ ∪ kK₁)`-free exactly for the `k` at
least as large as `freeParam G`. -/
theorem freeParam_le_iff [Finite V] {G : SimpleGraph V} {k : ℕ} :
    freeParam G ≤ k ↔ IsK2UnionK1Free G k := by
  constructor
  · intro hle
    exact mono_parameter (freeParam_spec G) hle
  · intro hfree
    exact Nat.sInf_le hfree

theorem freeParam_le_of_free {G : SimpleGraph V} {k : ℕ} (h : IsK2UnionK1Free G k) :
    freeParam G ≤ k :=
  Nat.sInf_le h

theorem not_free_of_lt_freeParam {G : SimpleGraph V} {k : ℕ} (h : k < freeParam G) :
    ¬ IsK2UnionK1Free G k :=
  fun hfree => absurd (freeParam_le_of_free hfree) (not_le.mpr h)

/-- **The parameter is at most the independence number.** -/
theorem freeParam_le_indepNum [Finite V] (G : SimpleGraph V) :
    freeParam G ≤ G.indepNum :=
  freeParam_le_of_free (free_indepNum G)

/-- The parameter is at most one more than the independence number. -/
theorem freeParam_le_succ_indepNum [Finite V] (G : SimpleGraph V) :
    freeParam G ≤ G.indepNum + 1 :=
  freeParam_le_of_free (free_succ_indepNum G)

/-- The graphs of parameter `0` are exactly the edgeless graphs. -/
theorem freeParam_eq_zero_iff [Finite V] {G : SimpleGraph V} :
    freeParam G = 0 ↔ G = ⊥ := by
  rw [← Nat.le_zero, freeParam_le_iff, zero_iff_bot]

/-- The parameter does not increase when passing to an induced subgraph. -/
theorem freeParam_induce_le [Finite V] (G : SimpleGraph V) (A : Set V) :
    freeParam (G.induce A) ≤ freeParam G :=
  freeParam_le_of_free (IsK2UnionK1Free.induce (freeParam_spec G) A)

/-- The parameter does not increase along induced embeddings. -/
theorem freeParam_le_of_embedding [Finite V] [Finite W] {G : SimpleGraph V}
    {H : SimpleGraph W} (f : H ↪g G) : freeParam H ≤ freeParam G :=
  freeParam_le_of_free (IsK2UnionK1Free.of_embedding f (freeParam_spec G))

/-! ## Toughness bounds the parameter -/

/-- Combining `freeParam_le_indepNum` with the toughness bound on the independence number:
a graph with `τ(G) > t ≥ 0` and `|V(G)| > t + 1` satisfies `(t + 1)·freeParam G < |V(G)|`. -/
theorem succ_mul_freeParam_lt [Fintype V] {G : SimpleGraph V} {t : ℚ} (ht : 0 ≤ t)
    (h : ToughGreaterThan G t) (hcard : t + 1 < (Fintype.card V : ℚ)) :
    (t + 1) * (freeParam G : ℚ) < (Fintype.card V : ℚ) := by
  have hle : (freeParam G : ℚ) ≤ (G.indepNum : ℚ) := by
    exact_mod_cast freeParam_le_indepNum G
  have hpos : (0 : ℚ) < t + 1 := by linarith
  have := succ_mul_indepNum_lt ht h hcard
  nlinarith

/-- In particular, in a graph with `τ(G) > 1` on at least three vertices the freeness
parameter is smaller than half the order. -/
theorem two_mul_freeParam_lt [Fintype V] {G : SimpleGraph V} (h : ToughGreaterThan G 1)
    (hcard : 3 ≤ Fintype.card V) : 2 * freeParam G < Fintype.card V := by
  have hq : ((1 : ℚ) + 1) < (Fintype.card V : ℚ) := by
    have : (3 : ℚ) ≤ (Fintype.card V : ℚ) := by exact_mod_cast hcard
    linarith
  have := succ_mul_freeParam_lt (by norm_num) h hq
  have h2 : (2 : ℚ) * (freeParam G : ℚ) < (Fintype.card V : ℚ) := by linarith
  exact_mod_cast h2

/-! ## Examples -/

/-- The five-cycle has freeness parameter `2`. -/
theorem freeParam_cycleGraph_five : freeParam (cycleGraph 5) = 2 := by
  have h2 : freeParam (cycleGraph 5) ≤ 2 := freeParam_le_of_free cycleGraph_five_free_two
  have h1 : ¬ freeParam (cycleGraph 5) ≤ 1 := by
    intro hle
    exact cycleGraph_five_not_free_one (freeParam_le_iff.mp hle)
  omega

/-- The forbidden graph `K₂ ∪ kK₁` itself has freeness parameter exactly `k + 1`. -/
theorem freeParam_k2UnionK1 (k : ℕ) : freeParam (k2UnionK1 k) = k + 1 := by
  have hle : freeParam (k2UnionK1 k) ≤ k + 1 :=
    freeParam_le_of_free (k2UnionK1_free_succ k)
  have hge : ¬ freeParam (k2UnionK1 k) ≤ k := by
    intro hlek
    exact k2UnionK1_not_free_self k (freeParam_le_iff.mp hlek)
  omega

/-- The edgeless graph has parameter `0`. -/
theorem freeParam_bot [Finite V] : freeParam (⊥ : SimpleGraph V) = 0 :=
  freeParam_eq_zero_iff.mpr rfl

/-- A complete graph on at least two vertices has parameter `1`: every edge dominates
every vertex, but the graph does have an edge. -/
theorem freeParam_top_eq_one [Finite V] (h : 1 < Nat.card V) :
    freeParam (⊤ : SimpleGraph V) = 1 := by
  have hne : (⊤ : SimpleGraph V) ≠ ⊥ := by
    have hnt : Nontrivial V := Finite.one_lt_card_iff_nontrivial.mp h
    obtain ⟨x, y, hxy⟩ := hnt
    intro hEq
    have hadj : (⊤ : SimpleGraph V).Adj x y := by simpa using hxy
    rw [hEq] at hadj
    simp at hadj
  have hle : freeParam (⊤ : SimpleGraph V) ≤ 1 := by
    refine freeParam_le_of_free ?_
    intro u v huv I hIcard _ hanti
    obtain ⟨x, rfl⟩ := Finset.card_eq_one.mp hIcard
    have hx : x ∈ ({x} : Finset V) := Finset.mem_singleton_self x
    obtain ⟨hux, hvx⟩ := hanti x hx
    have hxu : x = u := by
      by_contra hc
      exact hux (by simpa using fun hEq => hc hEq.symm)
    have hxv : x = v := by
      by_contra hc
      exact hvx (by simpa using fun hEq => hc hEq.symm)
    exact huv.ne (hxu ▸ hxv ▸ rfl)
  have hpos : freeParam (⊤ : SimpleGraph V) ≠ 0 := fun h0 => hne (freeParam_eq_zero_iff.mp h0)
  omega

end K2UnionK1FreeParameter