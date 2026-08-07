/-
  Complete Minors from Branch Families, and `K₃` from a Cycle
  ==========================================================

  This file supplies the *construction* side of the Hadwiger development:

  * `Hadwiger.CompleteMinor n G`               : `Kₙ` is a minor of `G`.
  * `Hadwiger.completeMinor_of_branches`       : a family of pairwise disjoint,
                                                 non-empty, connected, pairwise
                                                 linked vertex sets produces a
                                                 `Kₙ` minor.
  * `Hadwiger.completeMinor_three_of_not_isAcyclic` : **every graph containing a
                                                 cycle has `K₃` as a minor** —
                                                 the contraction half of
                                                 Hadwiger's conjecture for
                                                 `k = 2`.
  * `Hadwiger.completeMinor_two_of_adj`        : an edge gives a `K₂` minor.
  * `Hadwiger.completeMinor_one`               : a vertex gives a `K₁` minor.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): a cycle of any length `n ≥ 3` should contract to a
    triangle by splitting it into the three arcs `{g₀}`, `{g₁}`, `{g₂,…,g_{n-1}}`.
  Experiment (Experimenter): the third arc is realised as the support of the
    walk `(c.take (n-1)).drop 2`, whose vertices are exactly `c.getVert i` for
    `2 ≤ i ≤ n-1` (computed from `take_getVert`, `drop_getVert`, `take_length`,
    `drop_length`).  Connectivity is `setConnected_support`; disjointness comes
    from `IsCycle.getVert_injOn'`, injectivity of `getVert` on `{i ≤ n-1}`.
  Analysis (Analyst): the three linking edges are `g₀g₁`, `g₁g₂` and
    `g_{n-1}g_n = g_{n-1}g₀`, all instances of `adj_getVert_succ`; the corner
    case `n = 3` is *not* special — then the third arc is the singleton `{g₂}`
    and the same three edges do the job.
  Critique (Critic): a shorter "the cycle contains a triangle" argument is
    simply false for `n > 3`; contraction is genuinely needed, which is why the
    arc bookkeeping cannot be avoided.
  Synthesis (PI): combined with `colorable_two_of_isAcyclic` this closes
    Hadwiger's conjecture for `k = 2`.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerCore

namespace Hadwiger

open SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-- `CompleteMinor n G` : the complete graph `Kₙ` is a minor of `G`. -/
def CompleteMinor (n : ℕ) (G : SimpleGraph V) : Prop :=
  MinorTheory.MinorModel.IsMinor (⊤ : SimpleGraph (Fin n)) G

/-- Building a complete minor out of a family of branch sets. -/
theorem completeMinor_of_branches {n : ℕ} (b : Fin n → Set V)
    (hne : ∀ i, (b i).Nonempty)
    (hdisj : ∀ i j, i ≠ j → Disjoint (b i) (b j))
    (hconn : ∀ i, SetConnected G (b i))
    (hedge : ∀ i j, i ≠ j → ∃ x ∈ b i, ∃ y ∈ b j, G.Adj x y) :
    CompleteMinor n G := by
  refine walkMinor_iff_isMinor.mp ⟨⟨b, hne, fun i j hij => hdisj i j hij, hconn, ?_⟩⟩
  intro i j hij
  exact hedge i j (by simpa using hij.ne)

/-- One vertex already gives a `K₁` minor. -/
theorem completeMinor_one (v : V) : CompleteMinor 1 G := by
  refine completeMinor_of_branches (fun _ => {v}) (fun _ => ⟨v, rfl⟩) ?_
    (fun _ => setConnected_singleton v) ?_
  · intro i j hij
    exact absurd (Subsingleton.elim i j) hij
  · intro i j hij
    exact absurd (Subsingleton.elim i j) hij

/-- An edge gives a `K₂` minor. -/
theorem completeMinor_two_of_adj {u v : V} (huv : G.Adj u v) : CompleteMinor 2 G := by
  refine completeMinor_of_branches ![{u}, {v}] ?_ ?_ ?_ ?_
  · intro i; fin_cases i <;> simp
  · intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [huv.ne, huv.ne']
  · intro i; fin_cases i <;> simpa using setConnected_singleton _
  · intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [huv.symm]

/-- Three pairwise disjoint, non-empty, connected and pairwise linked vertex
sets give a `K₃` minor. -/
theorem completeMinor_three_of_triple {S0 S1 S2 : Set V}
    (h0 : S0.Nonempty) (h1 : S1.Nonempty) (h2 : S2.Nonempty)
    (d01 : Disjoint S0 S1) (d02 : Disjoint S0 S2) (d12 : Disjoint S1 S2)
    (c0 : SetConnected G S0) (c1 : SetConnected G S1) (c2 : SetConnected G S2)
    (e01 : ∃ x ∈ S0, ∃ y ∈ S1, G.Adj x y)
    (e02 : ∃ x ∈ S0, ∃ y ∈ S2, G.Adj x y)
    (e12 : ∃ x ∈ S1, ∃ y ∈ S2, G.Adj x y) :
    CompleteMinor 3 G := by
  have esymm : ∀ {A B : Set V}, (∃ x ∈ A, ∃ y ∈ B, G.Adj x y) →
      ∃ x ∈ B, ∃ y ∈ A, G.Adj x y := by
    rintro A B ⟨x, hx, y, hy, hxy⟩
    exact ⟨y, hy, x, hx, hxy.symm⟩
  refine completeMinor_of_branches ![S0, S1, S2] ?_ ?_ ?_ ?_
  · intro i; fin_cases i <;> simpa using ‹_›
  · intro i j hij
    fin_cases i <;> fin_cases j <;>
      first
        | exact absurd rfl hij
        | exact d01 | exact d02 | exact d12
        | exact d01.symm | exact d02.symm | exact d12.symm
  · intro i; fin_cases i <;> simpa using ‹_›
  · intro i j hij
    fin_cases i <;> fin_cases j <;>
      first
        | exact absurd rfl hij
        | exact e01 | exact e02 | exact e12
        | exact esymm e01 | exact esymm e02 | exact esymm e12

/-! ### A cycle contracts to a triangle -/

/-- **Every graph containing a cycle has `K₃` as a minor.** -/
theorem completeMinor_three_of_not_isAcyclic (h : ¬ G.IsAcyclic) : CompleteMinor 3 G := by
  classical
  simp only [SimpleGraph.IsAcyclic, not_forall, not_not] at h
  obtain ⟨v, c, hc⟩ := h
  set n := c.length with hn
  have h3 : 3 ≤ n := hc.three_le_length
  -- the third arc: the walk running from `g₂` to `g_{n-1}`
  set q := (c.take (n - 1)).drop 2 with hqdef
  have hqlen : q.length = n - 3 := by
    simp [hqdef]
    omega
  have hqvert : ∀ m, q.getVert m = c.getVert (min (n - 1) (2 + m)) := by
    intro m
    simp [hqdef]
  -- membership in the arc
  have hmem : ∀ z : V, z ∈ q.support ↔ ∃ m, m ≤ n - 3 ∧ c.getVert (2 + m) = z := by
    intro z
    rw [Walk.mem_support_iff_exists_getVert]
    constructor
    · rintro ⟨m, hm, hmlen⟩
      rw [hqlen] at hmlen
      refine ⟨m, hmlen, ?_⟩
      rw [← hm, hqvert m, Nat.min_eq_right (by omega)]
    · rintro ⟨m, hm, hmz⟩
      exact ⟨m, by rw [hqvert m, Nat.min_eq_right (by omega), hmz], by omega⟩
  -- injectivity of `getVert` on the first `n` indices
  have hinj := hc.getVert_injOn'
  have hne_vert : ∀ i j, i ≤ n - 1 → j ≤ n - 1 → i ≠ j → c.getVert i ≠ c.getVert j := by
    intro i j hi hj hij hcon
    exact hij (hinj (by simpa using hi) (by simpa using hj) hcon)
  have hg2 : c.getVert 2 ∈ {z | z ∈ q.support} := (hmem _).mpr ⟨0, by omega, by norm_num⟩
  have hglast : c.getVert (n - 1) ∈ {z | z ∈ q.support} :=
    (hmem _).mpr ⟨n - 3, le_rfl, by congr 1; omega⟩
  have harc_ne : ∀ i, i ≤ 1 → c.getVert i ∉ {z | z ∈ q.support} := by
    intro i hi hcon
    obtain ⟨m, hm, hmz⟩ := (hmem _).mp hcon
    exact hne_vert i (2 + m) (by omega) (by omega) (by omega) hmz.symm
  have h01 : c.getVert 0 ≠ c.getVert 1 := hne_vert 0 1 (by omega) (by omega) (by omega)
  have e01 : G.Adj (c.getVert 0) (c.getVert 1) := c.adj_getVert_succ (by omega)
  have e12 : G.Adj (c.getVert 1) (c.getVert 2) := by
    simpa using c.adj_getVert_succ (i := 1) (by omega)
  have elast : G.Adj (c.getVert (n - 1)) (c.getVert 0) := by
    have hadj := c.adj_getVert_succ (i := n - 1) (by omega)
    have hlast : c.getVert (n - 1 + 1) = c.getVert 0 := by
      rw [show n - 1 + 1 = n by omega, hn]
      simp
    rwa [hlast] at hadj
  refine completeMinor_three_of_triple (S0 := {c.getVert 0}) (S1 := {c.getVert 1})
    (S2 := {z | z ∈ q.support}) ⟨_, rfl⟩ ⟨_, rfl⟩ ⟨_, hg2⟩ ?_ ?_ ?_
    (setConnected_singleton _) (setConnected_singleton _) (setConnected_support q)
    ⟨_, rfl, _, rfl, e01⟩ ⟨_, rfl, _, hglast, elast.symm⟩ ⟨_, rfl, _, hg2, e12⟩
  · simpa using h01
  · rw [Set.disjoint_left]
    rintro a rfl
    exact harc_ne 0 (by omega)
  · rw [Set.disjoint_left]
    rintro a rfl
    exact harc_ne 1 (by omega)

end Hadwiger