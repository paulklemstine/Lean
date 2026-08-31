/-
# Cycle 4: sharpness of the `H₁`-vanishing theorem — one dimension is exactly the boundary

`PrimeRipsH1Vanishing.lean` proved that the Vietoris–Rips complex of *any* point cloud on
the real line — in particular the primes — has vanishing mod-`2` first homology at every
scale, refuting the conjectured `H₁` barcode of the primes.  The Critic stage asks the
obvious adversarial question: is that theorem saying something about the *line*, or is the
chain-level framework simply too weak to ever detect a hole?

This file settles the question by exhibiting an **essential `1`-cycle** in the same
framework, for a four-point configuration that is planar rather than linear (the vertices of
a square with the `4`-cycle metric, all other points pushed far away).  Its Rips complex at
scale `1` is a hollow square: four edges, no triangles at all, so the cycle cannot bound.

Consequently:

* the chain-level machinery is *not* vacuous — `InTriangleSpan`-style spans are proper
  subgroups of the cycle group in general;
* the vanishing theorem for the primes is genuinely a consequence of one-dimensionality of
  the prime point cloud, not of the formalism.

## Main results

* `RipsSharp.genSpan_eq_empty_of_no_triangle` — if a scale admits no `2`-simplex at all,
  the boundary subgroup is trivial.

* `RipsSharp.square_essential` — the square cycle `{01, 12, 23, 03}` is a `1`-cycle of Rips
  edges at scale `1` for the square metric, and is **not** a boundary: an essential class in
  `H₁`.

* `RipsSharp.line_gen_cycle_mem_span` — conversely, for the distance function of a monotone
  line cloud every `1`-cycle bounds (transported from `RipsH1.H1_vanishes`).

* `RipsSharp.dimension_one_sharp` — the two statements combined: essential `1`-cycles exist
  in general metric configurations but never for a cloud on a line.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  H9: the `H₁`-vanishing theorem is sharp — its only input is
one-dimensionality, and a planar four-point cloud already carries an essential class.

Experiment (Experimenter).  We generalised the chain framework from a line cloud `p` to an
arbitrary symmetric distance function `d`, re-derived the line case as a corollary, and then
instantiated `d` as the graph metric of a `4`-cycle on `{0,1,2,3}` with all other points at
distance `100`.  At scale `1` the four boundary edges are Rips edges, every vertex has
degree two, and every triple of vertices contains an antipodal pair at distance `2`, so no
`2`-simplex exists.  Hence the boundary subgroup is `{∅}` and the square cycle is essential.

Analysis (Analyst).  Comparing with the line theorem: the umbrella lemma
(`RipsH1.umbrella`) fails exactly here — the two neighbours `1` and `3` of the vertex `0`
are at distance `2` from each other, so they do not span a triangle with `0`.  This single
failure is what allows a hole, confirming that the umbrella property (equivalently, the
indifference-graph structure of the Rips graph of a line cloud) is the precise mechanism
behind the vanishing.

Critique (Critic).  The counterexample is a genuine theorem about an explicit object, not a
`decide` on an abstract claim: the "no triangle" step quantifies over *all* triples of
natural numbers, including those outside the square, and is proved by the distance-`100`
separation plus a finite case analysis.

Synthesis (PI).  One dimension is exactly the boundary between a trivial and a nontrivial
`H₁`; the primes lie on the trivial side, and the mission's conjectured `H₁` barcode cannot
exist.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.NumberTheory.PrimeRipsH1Vanishing

namespace RipsSharp

open Finset

/-! ### The chain framework for a general distance function -/

/-- A Rips edge for an arbitrary symmetric distance function. -/
def GenEdge (d : ℕ → ℕ → ℝ) (ε : ℝ) (e : ℕ × ℕ) : Prop := e.1 < e.2 ∧ d e.1 e.2 ≤ ε

/-- A `1`-chain of Rips edges. -/
def GenChain (d : ℕ → ℕ → ℝ) (ε : ℝ) (E : Finset (ℕ × ℕ)) : Prop := ∀ e ∈ E, GenEdge d ε e

/-- The `𝔽₂`-span of the boundaries of the `2`-simplices (triples of diameter `≤ ε`). -/
inductive GenSpan (d : ℕ → ℕ → ℝ) (ε : ℝ) : Finset (ℕ × ℕ) → Prop
  | zero : GenSpan d ε ∅
  | add (a b c : ℕ) (hab : a < b) (hbc : b < c)
      (h1 : d a b ≤ ε) (h2 : d b c ≤ ε) (h3 : d a c ≤ ε)
      (E : Finset (ℕ × ℕ)) (hE : GenSpan d ε E) :
      GenSpan d ε (symmDiff E (RipsH1.triBoundary a b c))

/-- If the scale admits no `2`-simplex, the group of boundaries is trivial. -/
theorem genSpan_eq_empty_of_no_triangle {d : ℕ → ℕ → ℝ} {ε : ℝ}
    (hno : ∀ a b c : ℕ, a < b → b < c → ¬ (d a b ≤ ε ∧ d b c ≤ ε ∧ d a c ≤ ε))
    {E : Finset (ℕ × ℕ)} (hE : GenSpan d ε E) : E = ∅ := by
  induction hE with
  | zero => rfl
  | add a b c hab hbc h1 h2 h3 E hE ih => exact absurd ⟨h1, h2, h3⟩ (hno a b c hab hbc)

/-! ### A planar four-point cloud with a hole -/

/-- The distance function of a square: the graph metric of the `4`-cycle on `{0,1,2,3}`,
with every other point placed far away. -/
noncomputable def dSq (i j : ℕ) : ℝ :=
  if i = j then 0 else if 4 ≤ i ∨ 4 ≤ j then 100 else if (i + j) % 2 = 1 then 1 else 2

/-- The square distance is symmetric. -/
theorem dSq_symm (i j : ℕ) : dSq i j = dSq j i := by
  unfold dSq
  by_cases h : i = j
  · simp [h]
  · simp only [h, Ne.symm h, if_false, Nat.add_comm i j, or_comm]

/-- The boundary of the square: the `1`-cycle `01 + 12 + 23 + 03`. -/
def squareCycle : Finset (ℕ × ℕ) := {(0, 1), (1, 2), (2, 3), (0, 3)}

/-- The four sides of the square are Rips edges at scale `1`. -/
theorem square_chain : GenChain dSq 1 squareCycle := by
  intro e he
  simp only [squareCycle, Finset.mem_insert, Finset.mem_singleton] at he
  rcases he with rfl | rfl | rfl | rfl <;>
    refine ⟨by norm_num, ?_⟩ <;> norm_num [dSq]

/-- Every vertex of the square has degree two: the four sides form a `1`-cycle. -/
theorem square_isCycle : RipsH1.IsCycle squareCycle := by
  intro v
  by_cases h0 : v = 0
  · subst h0; decide
  · by_cases h1 : v = 1
    · subst h1; decide
    · by_cases h2 : v = 2
      · subst h2; decide
      · by_cases h3 : v = 3
        · subst h3; decide
        · have hemp : squareCycle.filter (fun e => e.1 = v ∨ e.2 = v) = ∅ := by
            ext e
            simp only [Finset.mem_filter, squareCycle, Finset.mem_insert,
              Finset.mem_singleton, Finset.notMem_empty, iff_false, not_and]
            rintro (rfl | rfl | rfl | rfl) <;> simp <;> tauto
          simp [RipsH1.deg, hemp]

/-- At scale `1` the square carries no `2`-simplex: every triple of points contains a pair
at distance at least `2`. -/
theorem square_no_triangle :
    ∀ a b c : ℕ, a < b → b < c → ¬ (dSq a b ≤ 1 ∧ dSq b c ≤ 1 ∧ dSq a c ≤ 1) := by
  intro a b c hab hbc ⟨h1, h2, h3⟩
  have hc : c < 4 := by
    by_contra hc
    push_neg at hc
    rw [dSq] at h2
    have hne : b ≠ c := Nat.ne_of_lt hbc
    simp only [hne, if_false] at h2
    rw [if_pos (Or.inr hc)] at h2
    norm_num at h2
  have ha : a < 4 := by omega
  have hb : b < 4 := by omega
  interval_cases a <;> interval_cases b <;> interval_cases c <;>
    simp_all [dSq]

/-- **An essential `1`-cycle.**  The square cycle is a cycle of Rips edges at scale `1`
which is not a boundary: `H₁` of this planar four-point cloud is nontrivial. -/
theorem square_essential : ¬ GenSpan dSq 1 squareCycle := by
  intro h
  have := genSpan_eq_empty_of_no_triangle square_no_triangle h
  rw [squareCycle] at this
  simp at this

/-! ### The line case, transported to the general framework -/

/-- Boundaries in the sense of `PrimeRipsH1Vanishing.lean` are boundaries in the general
framework. -/
theorem inTriangleSpan_to_genSpan {p : ℕ → ℝ} {ε : ℝ} (hp : Monotone p)
    {E : Finset (ℕ × ℕ)} (h : RipsH1.InTriangleSpan p ε E) :
    GenSpan (fun i j => |p i - p j|) ε E := by
  induction h with
  | zero => exact GenSpan.zero
  | add a b c hab hbc hac E' hE' ih =>
      have hpa : p a ≤ p b := hp hab.le
      have hpb : p b ≤ p c := hp hbc.le
      refine GenSpan.add a b c hab hbc ?_ ?_ ?_ E' ih
      · rw [abs_sub_comm, abs_of_nonneg (by linarith)]; linarith
      · rw [abs_sub_comm, abs_of_nonneg (by linarith)]; linarith
      · rw [abs_sub_comm, abs_of_nonneg (by linarith)]; linarith

/-- For a monotone line cloud the general framework agrees with the one of
`PrimeRipsH1Vanishing.lean`, so every `1`-cycle bounds. -/
theorem line_gen_cycle_mem_span {p : ℕ → ℝ} (hp : Monotone p) (ε : ℝ)
    (E : Finset (ℕ × ℕ)) (hE : GenChain (fun i j => |p i - p j|) ε E)
    (hcyc : RipsH1.IsCycle E) : GenSpan (fun i j => |p i - p j|) ε E := by
  have hchain : RipsH1.IsRipsChain p ε E := by
    intro e he
    obtain ⟨h1, h2⟩ := hE e he
    refine ⟨h1, ?_⟩
    have : p e.1 ≤ p e.2 := hp h1.le
    calc p e.2 - p e.1 = |p e.1 - p e.2| := by
          rw [abs_sub_comm, abs_of_nonneg (by linarith)]
      _ ≤ ε := h2
  exact inTriangleSpan_to_genSpan hp (RipsH1.H1_vanishes hp E hchain hcyc)

/-- **Sharpness of the vanishing theorem.**  Essential `1`-cycles exist for general distance
functions (the square), but never for a point cloud on a line. -/
theorem dimension_one_sharp :
    (∃ (d : ℕ → ℕ → ℝ) (ε : ℝ) (E : Finset (ℕ × ℕ)),
        GenChain d ε E ∧ RipsH1.IsCycle E ∧ ¬ GenSpan d ε E) ∧
    (∀ (p : ℕ → ℝ), Monotone p → ∀ (ε : ℝ) (E : Finset (ℕ × ℕ)),
        GenChain (fun i j => |p i - p j|) ε E → RipsH1.IsCycle E →
        GenSpan (fun i j => |p i - p j|) ε E) := by
  refine ⟨⟨dSq, 1, squareCycle, square_chain, square_isCycle, square_essential⟩, ?_⟩
  intro p hp ε E hE hcyc
  exact line_gen_cycle_mem_span hp ε E hE hcyc

end RipsSharp