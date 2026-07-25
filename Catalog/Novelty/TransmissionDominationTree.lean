import Mathlib

/-!
# Domination number of paths (and the transmission–zero-forcing / domination program)

This file is the first research cycle on the direction

> *Transmission Zero Forcing Number Equals Domination Number on Trees.*

The deepest *fully verified* contribution here is an exact, closed-form evaluation of the
**domination number of the path graph** `P_n` (which is the simplest infinite family of
trees):

  `γ(P_n) = ⌈n/3⌉ = (n + 2) / 3`   (natural-number division).

We give two equivalent developments and connect them:

* a self-contained **combinatorial** model `DominatesPath` / `gammaPath` on `ℕ`, where the
  domination number of `P_n` is computed exactly (`gammaPath_eq`);
* a **genuine graph-theoretic** definition `IsDominatingSet` / `dominationNumber` for an
  arbitrary `SimpleGraph`, together with a card-preserving bridge proving that the
  graph domination number of `Mathlib`'s `SimpleGraph.pathGraph n` equals the combinatorial
  `gammaPath n` (`dominationNumber_pathGraph`), hence equals `(n+2)/3`
  (`dominationNumber_pathGraph_eq`).

The `dominationNumber` definition is stated for general finite graphs so that future cycles
can reuse it for stars, caterpillars, spiders and general trees.

-- !-- Lab Notes -- !--
## Hypothesis
The mission conjecture is `ξ_T(T) = γ(T)` for every tree `T`, where `ξ_T` is a
"transmission zero forcing number".  Ordinary zero forcing fails this badly
(`Z(P_n) = 1` but `γ(P_n) = ⌈n/3⌉`), so any equality must use a *transmission-weighted*
variant.  The first scientific task is therefore to pin down `γ` itself exactly on the
canonical tree family, which is what this file does rigorously.

## Experimental outcome (see ComputationalEvidence.md)
Brute-force enumeration over `P_1 … P_9` confirms `γ(P_n) = ⌈n/3⌉ = 1,1,1,2,2,2,3,3,3`.
The same enumeration shows ordinary `Z(P_n) = 1` for all `n`, decisively separating ordinary
zero forcing from domination and motivating the "transmission" weighting in the conjecture.

## Insights
* The lower bound is a pure *closed-neighbourhood counting* argument: in a path every closed
  neighbourhood has at most `3` vertices, so a dominating set `S` satisfies `n ≤ 3·|S|`.
  This is exactly the `Δ`-degree bound `γ(G) ≥ n/(Δ+1)` specialised to `Δ = 2`, and it is the
  reusable kernel for the general tree program (`lower_bound`).
* The upper bound needs only the *existence* of a small dominating set, not its exact size:
  placing a guard at `min(3k+1, n-1)` for `k < ⌈n/3⌉` dominates everything, and
  `Finset.card_image_le` caps the cardinality without any injectivity bookkeeping
  (`dominates_construction`, `card_construction`).
* Encoding distance-≤1 as `i ≤ s+1 ∧ s ≤ i+1` over `ℕ` lets `omega` discharge every
  metric obligation, including the Euclidean-division case split `3k ≤ i ≤ 3k+2`.

## Failure analysis
* Working directly in `Fin n` makes the counting argument painful (wrap-around `s-1`,
  `Fin`-valued `Finset.Icc`).  Proving the value over `ℕ` and then *bridging* to
  `SimpleGraph.pathGraph` via `Finset.attachFin` / `Finset.image Fin.val` is dramatically
  cleaner and keeps `omega` in charge.
* `omega` does not reduce `(⟨i, hi⟩ : Fin n).val` to `i` by itself; an empty `simp only []`
  (projection reduction) before `omega` is load-bearing in the bridge lemmas.
-/

open Finset SimpleGraph

/-! ## Combinatorial model of domination on the path `P_n` -/

/-- `DominatesPath n S`: the finite set `S ⊆ {0,…,n-1}` is a dominating set of the path
graph `P_n`, i.e. every vertex `i < n` is within graph distance `≤ 1` of some `s ∈ S`
(distance `≤ 1` over `ℕ` is `i ≤ s + 1 ∧ s ≤ i + 1`). -/
def DominatesPath (n : ℕ) (S : Finset ℕ) : Prop :=
  S ⊆ Finset.range n ∧ ∀ i ∈ Finset.range n, ∃ s ∈ S, i ≤ s + 1 ∧ s ≤ i + 1

/-- The (combinatorial) domination number of the path `P_n`. -/
noncomputable def gammaPath (n : ℕ) : ℕ :=
  sInf {k | ∃ S, DominatesPath n S ∧ S.card = k}

/-- The closed neighbourhood `{s-1, s, s+1}` of a path vertex, used for the counting bound. -/
def blockP (s : ℕ) : Finset ℕ := Finset.Icc (s - 1) (s + 1)

/-- A small dominating set: a guard at `min(3k+1, n-1)` for each `k < ⌈n/3⌉`. -/
noncomputable def domConstruction (n : ℕ) : Finset ℕ :=
  (Finset.range ((n + 2) / 3)).image (fun k => min (3 * k + 1) (n - 1))

/-- The whole vertex set dominates `P_n`; in particular dominating sets exist. -/
theorem dominates_full (n : ℕ) : DominatesPath n (Finset.range n) :=
  ⟨Finset.Subset.refl _, fun i hi => ⟨i, hi, by omega, by omega⟩⟩

/-- **Counting lower bound.** Every dominating set `S` of `P_n` satisfies `n ≤ 3·|S|`,
because each closed neighbourhood covers at most `3` vertices. -/
theorem lower_bound (n : ℕ) (S : Finset ℕ) (h : DominatesPath n S) : n ≤ 3 * S.card := by
  obtain ⟨_, hdom⟩ := h
  have hcover : Finset.range n ⊆ S.biUnion blockP := by
    intro i hi
    obtain ⟨s, hs, h1, h2⟩ := hdom i hi
    rw [Finset.mem_biUnion]
    exact ⟨s, hs, by unfold blockP; rw [Finset.mem_Icc]; omega⟩
  calc n = (Finset.range n).card := by rw [Finset.card_range]
    _ ≤ (S.biUnion blockP).card := Finset.card_le_card hcover
    _ ≤ ∑ s ∈ S, (blockP s).card := Finset.card_biUnion_le
    _ ≤ ∑ _s ∈ S, 3 := by
        apply Finset.sum_le_sum; intro s _; unfold blockP; rw [Nat.card_Icc]; omega
    _ = 3 * S.card := by rw [Finset.sum_const, smul_eq_mul, Nat.mul_comm]

/-- The explicit construction is a dominating set. -/
theorem dominates_construction (n : ℕ) : DominatesPath n (domConstruction n) := by
  constructor
  · intro s hs
    unfold domConstruction at hs; rw [Finset.mem_image] at hs
    obtain ⟨k, hk, rfl⟩ := hs; rw [Finset.mem_range] at hk ⊢; omega
  · intro i hi
    rw [Finset.mem_range] at hi
    refine ⟨min (3 * (i / 3) + 1) (n - 1), ?_, by omega, by omega⟩
    unfold domConstruction; rw [Finset.mem_image]
    exact ⟨i / 3, by rw [Finset.mem_range]; omega, rfl⟩

/-- The explicit construction has at most `⌈n/3⌉` vertices. -/
theorem card_construction (n : ℕ) : (domConstruction n).card ≤ (n + 2) / 3 :=
  le_trans Finset.card_image_le (le_of_eq (Finset.card_range _))

/-- **Main combinatorial theorem: `γ(P_n) = ⌈n/3⌉`.** -/
theorem gammaPath_eq (n : ℕ) : gammaPath n = (n + 2) / 3 := by
  apply le_antisymm
  · exact le_trans (Nat.sInf_le (m := (domConstruction n).card)
      ⟨domConstruction n, dominates_construction n, rfl⟩) (card_construction n)
  · unfold gammaPath
    have hne : {k | ∃ S, DominatesPath n S ∧ S.card = k}.Nonempty :=
      ⟨(Finset.range n).card, Finset.range n, dominates_full n, rfl⟩
    obtain ⟨S, hS, hcard⟩ := Nat.sInf_mem hne
    have hb := lower_bound n S hS
    rw [hcard] at hb
    omega

/-! ## Genuine graph-theoretic domination number, and the bridge to `pathGraph` -/

/-- `D` is a dominating set of `G`: every vertex is in `D` or adjacent to a member of `D`. -/
def IsDominatingSet {V} (G : SimpleGraph V) (D : Finset V) : Prop :=
  ∀ v, v ∈ D ∨ ∃ d ∈ D, G.Adj d v

/-- The domination number of a finite graph: the least size of a dominating set. -/
noncomputable def dominationNumber {V} [Fintype V] (G : SimpleGraph V) : ℕ :=
  sInf {k | ∃ D : Finset V, IsDominatingSet G D ∧ D.card = k}

/-- **General counting lower bound (kernel of FUTURE_DIRECTIONS Conjecture 2).**
For any finite graph `G`, every dominating set `D` satisfies `|V| ≤ (Δ+1)·|D|`, because each
closed neighbourhood has at most `Δ+1` vertices.  The path bound `lower_bound` is the
`Δ = 2` instance.

-- !-- Lab Notes -- !--
## Insight
This is the reusable engine for the whole tree program: the same `Finset.card_biUnion_le`
over closed neighbourhoods drives both the path computation and every future spider/star/tree
bound.  Keeping it stated for an arbitrary `SimpleGraph` (not just paths) is the main
structural payoff of this cycle. -/
theorem domination_lower_bound_general {V} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] (D : Finset V) (h : IsDominatingSet G D) :
    Fintype.card V ≤ (G.maxDegree + 1) * D.card := by
  classical
  have hcover : (Finset.univ : Finset V)
      ⊆ D.biUnion (fun d => insert d (G.neighborFinset d)) := by
    intro v _
    rw [Finset.mem_biUnion]
    rcases h v with hv | ⟨d, hd, hadj⟩
    · exact ⟨v, hv, Finset.mem_insert_self _ _⟩
    · exact ⟨d, hd, Finset.mem_insert_of_mem (by rw [mem_neighborFinset]; exact hadj)⟩
  calc Fintype.card V = (Finset.univ : Finset V).card := by rw [Finset.card_univ]
    _ ≤ (D.biUnion (fun d => insert d (G.neighborFinset d))).card := Finset.card_le_card hcover
    _ ≤ ∑ d ∈ D, (insert d (G.neighborFinset d)).card := Finset.card_biUnion_le
    _ ≤ ∑ _d ∈ D, (G.maxDegree + 1) := by
        apply Finset.sum_le_sum
        intro d _
        have hnotin : d ∉ G.neighborFinset d := by simp [mem_neighborFinset]
        rw [Finset.card_insert_of_notMem hnotin, SimpleGraph.card_neighborFinset_eq_degree]
        have := G.degree_le_maxDegree d
        omega
    _ = (G.maxDegree + 1) * D.card := by rw [Finset.sum_const, smul_eq_mul, Nat.mul_comm]

/-- Corollary: `|V| ≤ (Δ+1)·γ(G)` for every finite graph. -/
theorem domination_card_lower_bound {V} [Fintype V] [DecidableEq V] (G : SimpleGraph V)
    [DecidableRel G.Adj] :
    Fintype.card V ≤ (G.maxDegree + 1) * dominationNumber G := by
  classical
  have hne : {k | ∃ D : Finset V, IsDominatingSet G D ∧ D.card = k}.Nonempty :=
    ⟨Finset.univ.card, Finset.univ, fun v => Or.inl (Finset.mem_univ v), rfl⟩
  obtain ⟨D, hD, hcard⟩ := Nat.sInf_mem hne
  have := domination_lower_bound_general G D hD
  rw [hcard] at this
  exact this

/-- Pushing a dominating set of `pathGraph n` to `ℕ` (via `Fin.val`) gives a `DominatesPath`. -/
theorem domImage (n : ℕ) (D : Finset (Fin n)) (h : IsDominatingSet (pathGraph n) D) :
    DominatesPath n (D.image (Fin.val)) := by
  constructor
  · intro s hs; rw [Finset.mem_image] at hs; obtain ⟨a, _, rfl⟩ := hs
    rw [Finset.mem_range]; exact a.isLt
  · intro i hi; rw [Finset.mem_range] at hi
    rcases h ⟨i, hi⟩ with hin | ⟨d, hd, hadj⟩
    · exact ⟨i, by rw [Finset.mem_image]; exact ⟨⟨i, hi⟩, hin, rfl⟩, by omega, by omega⟩
    · rw [pathGraph_adj] at hadj
      simp only [] at hadj
      refine ⟨d.val, by rw [Finset.mem_image]; exact ⟨d, hd, rfl⟩, ?_, ?_⟩ <;> omega

/-- Pulling a `DominatesPath` set back to `Fin n` (via `attachFin`) gives a dominating set
of `pathGraph n`. -/
theorem domAttach (n : ℕ) (S : Finset ℕ) (h : DominatesPath n S) :
    IsDominatingSet (pathGraph n) (S.attachFin (fun _ hm => Finset.mem_range.1 (h.1 hm))) := by
  intro v
  obtain ⟨s, hs, h1, h2⟩ := h.2 v.val (Finset.mem_range.2 v.isLt)
  have hsn : s < n := Finset.mem_range.1 (h.1 hs)
  by_cases heq : v.val = s
  · left; rw [Finset.mem_attachFin, heq]; exact hs
  · right; refine ⟨⟨s, hsn⟩, by rw [Finset.mem_attachFin]; exact hs, ?_⟩
    rw [pathGraph_adj]; simp only []; omega

/-- **Bridge:** the graph-theoretic domination number of `Mathlib`'s `pathGraph n`
coincides with the combinatorial `gammaPath n`. -/
theorem dominationNumber_pathGraph (n : ℕ) :
    dominationNumber (pathGraph n) = gammaPath n := by
  apply le_antisymm
  · have hne : {k | ∃ S, DominatesPath n S ∧ S.card = k}.Nonempty :=
      ⟨_, _, dominates_full n, rfl⟩
    obtain ⟨S, hS, hcard⟩ := Nat.sInf_mem hne
    have hle : dominationNumber (pathGraph n)
        ≤ (S.attachFin (fun _ hm => Finset.mem_range.1 (hS.1 hm))).card :=
      Nat.sInf_le ⟨_, domAttach n S hS, rfl⟩
    rw [Finset.card_attachFin, hcard] at hle
    exact hle
  · have hne : {k | ∃ D : Finset (Fin n),
        IsDominatingSet (pathGraph n) D ∧ D.card = k}.Nonempty := by
      refine ⟨Finset.univ.card, Finset.univ, ?_, rfl⟩
      intro v; exact Or.inl (Finset.mem_univ v)
    obtain ⟨D, hD, hcard⟩ := Nat.sInf_mem hne
    have hle : gammaPath n ≤ (D.image Fin.val).card :=
      Nat.sInf_le ⟨_, domImage n D hD, rfl⟩
    rw [Finset.card_image_of_injective _ Fin.val_injective, hcard] at hle
    exact hle

/-- **Headline result.** The domination number of the path graph `P_n` (the canonical
infinite family of trees) is exactly `⌈n/3⌉`. -/
theorem dominationNumber_pathGraph_eq (n : ℕ) :
    dominationNumber (pathGraph n) = (n + 2) / 3 := by
  rw [dominationNumber_pathGraph, gammaPath_eq]

/-- Small sanity checks of the closed form. -/
example : dominationNumber (pathGraph 1) = 1 := by rw [dominationNumber_pathGraph_eq]
example : dominationNumber (pathGraph 4) = 2 := by rw [dominationNumber_pathGraph_eq]
example : dominationNumber (pathGraph 9) = 3 := by rw [dominationNumber_pathGraph_eq]