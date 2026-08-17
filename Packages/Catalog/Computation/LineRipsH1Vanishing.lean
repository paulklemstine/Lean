/-
# `H₁` of a line point cloud vanishes: every Rips 1-cycle is a sum of triangles

Companion to `Computation/PrimeBarcodePoissonObstruction.lean`.  There we showed
combinatorially that the Vietoris–Rips graph of a point cloud on a line is chordal
(every cycle of length `≥ 4` has a chord).  Here we prove the corresponding
*homological* statement over `𝔽₂`, which is what "the prime point cloud has no
`H₁`" really means.

Simplicial `1`-chains of the flag (Rips) complex with `𝔽₂` coefficients are finite
sets of edges; addition is symmetric difference; the boundary of a chain is the set
of vertices of odd degree, so a *cycle* is an edge set all of whose degrees are
even.  The `2`-chains are spanned by the triangles of the complex, and the image of
the boundary map `∂₂` is exactly the span `TriangleSpan` of the triangle boundaries.
Vanishing of `H₁ = ker ∂₁ / im ∂₂` is therefore the statement

  every cycle of Rips edges is a symmetric-difference sum of Rips triangles,

which is `LineRipsH1.cycle_mem_triangleSpan` below, proved for an arbitrary strictly
increasing point cloud `p : ℕ → ℝ` and every scale `ε`.  Specialised to the primes
(`prime_cycle_mem_triangleSpan`) it says that the prime point cloud has trivial
first homology at *every* scale — so the conjectured `H₁` bars of the prime barcode,
in particular a "twin prime `H₁` bar living from `ε = 2` to `∞`", do not exist.

## Main results

* `LineRipsH1.deg_symmDiff` — degrees add modulo `2` under symmetric difference.
* `LineRipsH1.deg_triangle` — every vertex of a triangle has degree `2` in it, so a
  triangle is a cycle and adding one preserves the cycle condition.
* `LineRipsH1.cycle_mem_triangleSpan` — **the vanishing theorem**: for a strictly
  increasing point cloud on the line, every `𝔽₂` `1`-cycle of Rips edges lies in the
  span of the Rips triangles.
* `LineRipsH1.prime_H1_vanishes` — the prime specialisation: `H₁ = 0` at every scale.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  Chordality should upgrade to a genuine homological
statement: on a line, no cycle can be "essential", because the leftmost vertex of a
cycle can always be bypassed.

Experiment (Experimenter).  Formalised `𝔽₂` `1`-chains as `Finset (ℕ × ℕ)` of ordered
edges, degree as the cardinality of the incident subset, and the triangle span as an
inductive predicate.  The proof is a strong induction on the weight
`μ(E) = ∑_{(a,b) ∈ E} b` (the sum of the right endpoints).  At the maximal vertex `v`
of a cycle the degree is even and positive, so two edges `(u,v)`, `(w,v)` with
`u < w < v` are present; since `p u, p w ∈ [p v − ε, p v]` the chord `(u,w)` is a Rips
edge, so `T = {(u,w),(w,v),(u,v)}` is a Rips triangle.  Replacing `E` by `T Δ E`
preserves the cycle condition (all degrees in `T` are `2`) and strictly decreases `μ`
(two edges of weight `v` are deleted and at most one of weight `w < v` appears).

Analysis (Analyst).  The weight `μ` is the crucial device: a naive induction on the
number of edges fails, since `T Δ E` may have the same cardinality.  Weight makes the
"pull the cycle to the left" move manifestly terminating.

Critique (Critic).  The theorem is not vacuous: `prime_square_mem_span` exhibits an honest
nonzero `1`-cycle of the prime Rips complex (the quadrilateral on `3, 5, 7, 11` at
scale `8`) together with its decomposition into two Rips triangles.
The span is generated only by *Rips* triangles — the hypotheses of the constructor
carry all three edge conditions — so the statement really is `im ∂₂ ⊇ ker ∂₁` in the
flag complex, not in a larger complex.

Synthesis (PI).  On a line there is no room for a hole: all of the topology of the
prime point cloud is `H₀`, i.e. arithmetic gap data.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Novelty.PrimeBarcodeInvariants

open Finset

namespace LineRipsH1

open PrimePH

/-! ## Chains, degrees and cycles over `𝔽₂` -/

/-- An ordered edge `(a, b)`, `a < b`, of the Vietoris–Rips graph at scale `ε`. -/
def IsRipsEdge (p : ℕ → ℝ) (ε : ℝ) (e : ℕ × ℕ) : Prop := e.1 < e.2 ∧ |p e.1 - p e.2| ≤ ε

/-- The edges of a chain incident to a vertex. -/
def inc (E : Finset (ℕ × ℕ)) (v : ℕ) : Finset (ℕ × ℕ) :=
  E.filter (fun e => e.1 = v ∨ e.2 = v)

/-- The degree of a vertex in a `1`-chain. -/
def deg (E : Finset (ℕ × ℕ)) (v : ℕ) : ℕ := (inc E v).card

/-- A `1`-chain is a cycle (`∂₁ = 0` over `𝔽₂`) iff every degree is even. -/
def IsCycleChain (E : Finset (ℕ × ℕ)) : Prop := ∀ v, Even (deg E v)

/-- The boundary of the triangle `a < b < c`, as a `1`-chain. -/
def triangleChain (a b c : ℕ) : Finset (ℕ × ℕ) := {(a, b), (b, c), (a, c)}

/-- The span of the boundaries of the Rips triangles: the image of `∂₂` over `𝔽₂`. -/
inductive TriangleSpan (p : ℕ → ℝ) (ε : ℝ) : Finset (ℕ × ℕ) → Prop
  | zero : TriangleSpan p ε ∅
  | add {a b c : ℕ} {E : Finset (ℕ × ℕ)} (hab : a < b) (hbc : b < c)
      (h1 : IsRipsEdge p ε (a, b)) (h2 : IsRipsEdge p ε (b, c))
      (h3 : IsRipsEdge p ε (a, c)) (hE : TriangleSpan p ε E) :
      TriangleSpan p ε (symmDiff (triangleChain a b c) E)

/-! ## Counting lemmas -/

/-- Cardinalities add modulo `2` under symmetric difference. -/
theorem card_symmDiff_add (A B : Finset (ℕ × ℕ)) :
    (symmDiff A B).card + 2 * (A ∩ B).card = A.card + B.card := by
  have h1 : symmDiff A B = (A ∪ B) \ (A ∩ B) := by
    ext x; simp [Finset.mem_symmDiff]; tauto
  have h4 : A ∩ B ∩ (A ∪ B) = A ∩ B := by ext x; simp
  have h2 : (A ∩ B) ⊆ (A ∪ B) := by intro x hx; simp at hx ⊢; tauto
  have h3 : (A ∩ B).card ≤ (A ∪ B).card := Finset.card_le_card h2
  rw [h1, Finset.card_sdiff, h4]
  have := Finset.card_union_add_card_inter A B
  omega

/-- Weights add modulo the intersection under symmetric difference. -/
theorem sum_symmDiff_add (f : ℕ × ℕ → ℕ) (A B : Finset (ℕ × ℕ)) :
    (∑ e ∈ symmDiff A B, f e) + 2 * (∑ e ∈ A ∩ B, f e)
      = (∑ e ∈ A, f e) + ∑ e ∈ B, f e := by
  have h1 : symmDiff A B = (A ∪ B) \ (A ∩ B) := by
    ext x; simp [Finset.mem_symmDiff]; tauto
  have h2 : (A ∩ B) ⊆ (A ∪ B) := by intro x hx; simp at hx ⊢; tauto
  have h3 := Finset.sum_sdiff (f := f) h2
  have h4 := Finset.sum_union_inter (s₁ := A) (s₂ := B) (f := f)
  rw [h1]
  omega

/-- The weight of a chain: the sum of the right endpoints of its edges. -/
def weight (E : Finset (ℕ × ℕ)) : ℕ := ∑ e ∈ E, e.2

/-- Weights add modulo the intersection under symmetric difference. -/
theorem weight_symmDiff (A B : Finset (ℕ × ℕ)) :
    weight (symmDiff A B) + 2 * (∑ e ∈ A ∩ B, e.2) = weight A + weight B :=
  sum_symmDiff_add (fun e => e.2) A B

/-- Incidence sets commute with symmetric difference. -/
theorem inc_symmDiff (A B : Finset (ℕ × ℕ)) (v : ℕ) :
    inc (symmDiff A B) v = symmDiff (inc A v) (inc B v) := by
  ext x
  simp [inc, Finset.mem_symmDiff]
  tauto

/-- Degrees add modulo `2` under symmetric difference. -/
theorem deg_symmDiff (A B : Finset (ℕ × ℕ)) (v : ℕ) :
    deg (symmDiff A B) v + 2 * (inc A v ∩ inc B v).card = deg A v + deg B v := by
  unfold deg
  rw [inc_symmDiff]
  exact card_symmDiff_add _ _

/-- Every vertex of a triangle has degree `2` in it; all other vertices degree `0`. -/
theorem deg_triangle (a b c v : ℕ) (hab : a < b) (hbc : b < c) :
    deg (triangleChain a b c) v = if v = a ∨ v = b ∨ v = c then 2 else 0 := by
  have n1 : a ≠ b := hab.ne
  have n2 : b ≠ c := hbc.ne
  have n3 : a ≠ c := (hab.trans hbc).ne
  have m1 : b ≠ a := hab.ne'
  have m2 : c ≠ b := hbc.ne'
  have m3 : c ≠ a := (hab.trans hbc).ne'
  unfold deg inc triangleChain
  rw [Finset.filter_insert, Finset.filter_insert, Finset.filter_singleton]
  by_cases h1 : v = a
  · simp_all [Prod.ext_iff, Finset.card_insert_of_notMem]
  by_cases h2 : v = b
  · simp_all [Prod.ext_iff, Finset.card_insert_of_notMem]
  by_cases h3 : v = c
  · simp_all [Prod.ext_iff, Finset.card_insert_of_notMem]
  · have k1 : a ≠ v := fun h => h1 h.symm
    have k2 : b ≠ v := fun h => h2 h.symm
    have k3 : c ≠ v := fun h => h3 h.symm
    simp [k1, k2, k3, h1, h2, h3]

/-- A triangle is itself a cycle. -/
theorem isCycleChain_triangle {a b c : ℕ} (hab : a < b) (hbc : b < c) :
    IsCycleChain (triangleChain a b c) := by
  intro v
  rw [deg_triangle a b c v hab hbc]
  split <;> decide

/-- The weight of a triangle `a < b < c`. -/
theorem weight_triangle {a b c : ℕ} (hab : a < b) (hbc : b < c) :
    weight (triangleChain a b c) = b + c + c := by
  have n1 : ((a, b) : ℕ × ℕ) ≠ (b, c) := by simp [Prod.ext_iff]; omega
  have n2 : ((a, b) : ℕ × ℕ) ≠ (a, c) := by simp [Prod.ext_iff]; omega
  have n3 : ((b, c) : ℕ × ℕ) ≠ (a, c) := by simp [Prod.ext_iff]; omega
  unfold weight triangleChain
  rw [Finset.sum_insert (by simp [n1, n2]), Finset.sum_insert (by simp [n3])]
  simp
  omega

/-! ## The vanishing theorem -/

/-- Auxiliary form of the vanishing theorem, with an explicit bound on the weight to
support strong induction. -/
theorem cycle_mem_triangleSpan_aux {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ} :
    ∀ N : ℕ, ∀ E : Finset (ℕ × ℕ), weight E ≤ N → (∀ e ∈ E, IsRipsEdge p ε e) →
      IsCycleChain E → TriangleSpan p ε E := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro E hw hedges hcyc
    rcases E.eq_empty_or_nonempty with rfl | hne
    · exact TriangleSpan.zero
    -- the rightmost vertex of the chain
    obtain ⟨e₀, he₀mem, he₀max⟩ := Finset.exists_max_image E (fun e => e.2) hne
    set v := e₀.2 with hv
    -- every edge incident to `v` has `v` as its right endpoint
    have hincident : ∀ e ∈ inc E v, e.2 = v ∧ e.1 < v := by
      intro e he
      simp only [inc, Finset.mem_filter] at he
      obtain ⟨heE, hcase⟩ := he
      have h2 : e.2 ≤ v := he₀max e heE
      have h1 : e.1 < e.2 := (hedges e heE).1
      rcases hcase with h | h
      · omega
      · omega
    -- the degree at `v` is even and positive, hence at least two
    have hdegpos : 0 < deg E v := by
      have : e₀ ∈ inc E v := by
        simp only [inc, Finset.mem_filter]
        exact ⟨he₀mem, Or.inr rfl⟩
      exact Finset.card_pos.mpr ⟨e₀, this⟩
    have hdeg2 : 2 ≤ deg E v := by
      obtain ⟨m, hm⟩ := hcyc v
      omega
    have hdeg2' : 1 < (inc E v).card := by
      unfold deg at hdeg2
      omega
    obtain ⟨e₁, he₁, e₂, he₂, hne12⟩ := Finset.one_lt_card.mp hdeg2'
    obtain ⟨he₁v, he₁lt⟩ := hincident e₁ he₁
    obtain ⟨he₂v, he₂lt⟩ := hincident e₂ he₂
    -- name the two neighbours of `v`, in increasing order
    obtain ⟨u, w, huw, hwv, huE, hwE⟩ :
        ∃ u w : ℕ, u < w ∧ w < v ∧ (u, v) ∈ E ∧ (w, v) ∈ E := by
      have h1 : e₁ = (e₁.1, v) := by simp [← he₁v]
      have h2 : e₂ = (e₂.1, v) := by simp [← he₂v]
      have hE1 : (e₁.1, v) ∈ E := by
        have hm : e₁ ∈ E := (Finset.mem_filter.mp he₁).1
        rwa [h1] at hm
      have hE2 : (e₂.1, v) ∈ E := by
        have hm : e₂ ∈ E := (Finset.mem_filter.mp he₂).1
        rwa [h2] at hm
      have hne' : e₁.1 ≠ e₂.1 := by
        intro h
        exact hne12 (by rw [h1, h2, h])
      rcases lt_or_gt_of_ne hne' with h | h
      · exact ⟨e₁.1, e₂.1, h, he₂lt, hE1, hE2⟩
      · exact ⟨e₂.1, e₁.1, h, he₁lt, hE2, hE1⟩
    have huv : u < v := lt_trans huw hwv
    -- the chord `(u, w)` is a Rips edge: `p u` and `p w` both lie in `[p v − ε, p v]`
    have hedge_uv : IsRipsEdge p ε (u, v) := hedges _ huE
    have hedge_wv : IsRipsEdge p ε (w, v) := hedges _ hwE
    have hedge_uw : IsRipsEdge p ε (u, w) := by
      refine ⟨huw, ?_⟩
      have h1 : p u < p w := hp huw
      have h2 : p w < p v := hp hwv
      have h3 := abs_le.mp hedge_uv.2
      simp only at h3
      rw [abs_le]
      constructor
      · linarith [h3.1, h3.2]
      · linarith [h3.1, h3.2]
    -- swap the two edges at `v` for the chord
    set T := triangleChain u w v with hT
    have hTcyc : IsCycleChain T := isCycleChain_triangle huw hwv
    set E' := symmDiff T E with hE'
    have hE'edges : ∀ e ∈ E', IsRipsEdge p ε e := by
      intro e he
      rw [hE', Finset.mem_symmDiff] at he
      rcases he with ⟨hTe, -⟩ | ⟨hEe, -⟩
      · rw [hT] at hTe
        simp only [triangleChain, Finset.mem_insert, Finset.mem_singleton] at hTe
        rcases hTe with rfl | rfl | rfl
        · exact hedge_uw
        · exact hedge_wv
        · exact hedge_uv
      · exact hedges e hEe
    have hE'cyc : IsCycleChain E' := by
      intro x
      have hd := deg_symmDiff T E x
      obtain ⟨m, hm⟩ := hTcyc x
      obtain ⟨k, hk⟩ := hcyc x
      rw [Nat.even_iff]
      rw [hE']
      omega
    have hweight : weight E' < weight E := by
      have hsum : weight E' + 2 * (∑ e ∈ T ∩ E, e.2) = weight T + weight E := by
        rw [hE']
        exact weight_symmDiff T E
      have hTw : weight T = w + v + v := weight_triangle huw hwv
      have hpair : ({(u, v), (w, v)} : Finset (ℕ × ℕ)) ⊆ T ∩ E := by
        intro e he
        simp only [Finset.mem_insert, Finset.mem_singleton] at he
        rcases he with rfl | rfl
        · exact Finset.mem_inter.mpr ⟨by simp [hT, triangleChain], huE⟩
        · exact Finset.mem_inter.mpr ⟨by simp [hT, triangleChain], hwE⟩
      have hne_pair : ((u, v) : ℕ × ℕ) ≠ (w, v) := by
        simp [Prod.ext_iff]
        omega
      have hge : 2 * v ≤ ∑ e ∈ T ∩ E, e.2 := by
        have hle : ∑ e ∈ ({(u, v), (w, v)} : Finset (ℕ × ℕ)), e.2 ≤ ∑ e ∈ T ∩ E, e.2 :=
          Finset.sum_le_sum_of_subset hpair
        rw [Finset.sum_pair hne_pair] at hle
        omega
      omega
    have hspan' : TriangleSpan p ε E' := ih (weight E') (by omega) E' le_rfl hE'edges hE'cyc
    have hEeq : E = symmDiff T E' := by
      rw [hE', symmDiff_symmDiff_cancel_left]
    rw [hEeq, hT]
    exact TriangleSpan.add huw hwv hedge_uw hedge_wv hedge_uv hspan'

/-- **`H₁` vanishes for line point clouds.**  Every `𝔽₂` `1`-cycle of Rips edges of a
strictly increasing point cloud on the real line is a sum of Rips triangles. -/
theorem cycle_mem_triangleSpan {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ}
    (E : Finset (ℕ × ℕ)) (hedges : ∀ e ∈ E, IsRipsEdge p ε e) (hcyc : IsCycleChain E) :
    TriangleSpan p ε E :=
  cycle_mem_triangleSpan_aux hp (weight E) E le_rfl hedges hcyc

/-- **The prime point cloud has no `H₁` at any scale.** -/
theorem prime_H1_vanishes {ε : ℝ} (E : Finset (ℕ × ℕ))
    (hedges : ∀ e ∈ E, IsRipsEdge P ε e) (hcyc : IsCycleChain E) :
    TriangleSpan P ε E :=
  cycle_mem_triangleSpan P_strictMono E hedges hcyc

/-! ## Non-vacuity: an honest `1`-cycle of the prime cloud and its triangle decomposition -/

/-- A quadrilateral `a < b < c < d` is the sum of the two triangles `abc` and `acd`. -/
theorem square_eq_symmDiff_triangles (a b c d : ℕ) (hab : a < b) (hbc : b < c) (hcd : c < d) :
    ({(a, b), (b, c), (c, d), (a, d)} : Finset (ℕ × ℕ))
      = symmDiff (triangleChain a b c) (triangleChain a c d) := by
  ext x
  simp [triangleChain, Finset.mem_symmDiff, Prod.ext_iff]
  omega

/-- A quadrilateral is a genuine (nonzero) `1`-cycle. -/
theorem isCycleChain_square {a b c d : ℕ} (hab : a < b) (hbc : b < c) (hcd : c < d) :
    IsCycleChain ({(a, b), (b, c), (c, d), (a, d)} : Finset (ℕ × ℕ)) := by
  rw [square_eq_symmDiff_triangles a b c d hab hbc hcd]
  intro x
  have hd := deg_symmDiff (triangleChain a b c) (triangleChain a c d) x
  obtain ⟨m, hm⟩ := isCycleChain_triangle hab hbc x
  obtain ⟨k, hk⟩ := isCycleChain_triangle (hab.trans hbc) hcd x
  rw [Nat.even_iff]
  omega

/-- The quadrilateral on the primes `3, 5, 7, 11` is a nonzero `1`-cycle of the prime
Rips complex at scale `8`, and it is the sum of the two Rips triangles `(3,5,7)` and
`(3,7,11)` — an explicit instance of the vanishing theorem. -/
theorem prime_square_mem_span :
    TriangleSpan P 8 ({(1, 2), (2, 3), (3, 4), (1, 4)} : Finset (ℕ × ℕ)) := by
  have p1 : P 1 = 3 := by simp [P]
  have p2 : P 2 = 5 := by simp [P]
  have p3 : P 3 = 7 := by simp [P]
  have p4 : P 4 = 11 := by simp [P]
  have e12 : IsRipsEdge P 8 (1, 2) := by
    refine ⟨by norm_num, ?_⟩; simp only [p1, p2]; rw [abs_le]; constructor <;> norm_num
  have e23 : IsRipsEdge P 8 (2, 3) := by
    refine ⟨by norm_num, ?_⟩; simp only [p2, p3]; rw [abs_le]; constructor <;> norm_num
  have e13 : IsRipsEdge P 8 (1, 3) := by
    refine ⟨by norm_num, ?_⟩; simp only [p1, p3]; rw [abs_le]; constructor <;> norm_num
  have e34 : IsRipsEdge P 8 (3, 4) := by
    refine ⟨by norm_num, ?_⟩; simp only [p3, p4]; rw [abs_le]; constructor <;> norm_num
  have e14 : IsRipsEdge P 8 (1, 4) := by
    refine ⟨by norm_num, ?_⟩; simp only [p1, p4]; rw [abs_le]; constructor <;> norm_num
  have h1 : TriangleSpan P 8 (triangleChain 1 3 4) := by
    have h := TriangleSpan.add (p := P) (ε := 8) (a := 1) (b := 3) (c := 4) (E := ∅)
      (by norm_num) (by norm_num) e13 e34 e14 TriangleSpan.zero
    simpa using h
  have h2 := TriangleSpan.add (p := P) (ε := 8) (a := 1) (b := 2) (c := 3)
    (by norm_num) (by norm_num) e12 e23 e13 h1
  rw [square_eq_symmDiff_triangles 1 2 3 4 (by norm_num) (by norm_num) (by norm_num)]
  exact h2

end LineRipsH1