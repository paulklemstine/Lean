import Mathlib
import Novelty.PartialCube

/-!
# Structural Theory of Snakes in Hypercubes

A snake in the `n`-cube is a list of distinct vertices whose consecutive entries differ in
one coordinate and whose nonconsecutive entries are never adjacent.  This chapter develops
certificate-independent consequences of that definition.  Vertices are represented by subsets
of `Fin n`; symmetric-difference cardinality is their Hamming distance.

The principal results connect induced-path combinatorics, coding theory, and finite counting:

* every snake has at most `2^n` vertices;
* nonconsecutive snake vertices have Hamming distance at least two;
* a snake determines a one-error-detecting code after deleting either parity class of edges;
* endpoint Hamming distance is bounded by path length through the partial-cube walk theorem;
* the bound may be sharpened by one vertex whenever a snake fails to span the cube.

These statements supply a reusable mathematical foundation for checking and interpreting the
record paths reported in *A Census of New Snake-in-the-Box Records*.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Seven claims were separated for testing.  The highest-impact claims
were that induced paths canonically yield distance-two codes, that partial-cube geodesic bounds
control their endpoints, and that finite-cube cardinality gives a universal exponential ceiling.
Further conjectures concerned asymptotic density, rigidity near the ceiling, symmetry-class
completeness in dimension nine, and product constructions.

Experiment (Experimenter): The paper's transition-sequence convention was translated into the
subset model already used for daisy cubes.  Rather than trusting a search transcript, the basic
consequences were derived from three independently testable clauses: no repeated vertices,
adjacency of successive vertices, and absence of chords.  The resulting finite counting
argument applies uniformly in every dimension.

Analysis (Analyst): Chordlessness is exactly a coding-theoretic separation statement once
consecutive pairs are excluded.  The walk lower bound from partial-cube geometry then gives an
orthogonal metric constraint: endpoints cannot be farther apart than the number of transitions.
The two viewpoints unify induced paths with error-detecting Gray codes.

Critique (Critic): The universal `2^n` ceiling is deliberately coarse and does not establish the
paper's new numerical records; those depend on the published witness data.  No completeness
claim for the dimension-nine census is made.  Every theorem below has genuine hypotheses, and
the distance-two result uses both no-repetition and chordlessness; dropping either produces an
immediate counterexample.

Synthesis (Principal Investigator): The surviving results form a compact certificate layer for
future record datasets.  The key reusable bridge is `nonconsecutive_distance_two`, while
`snake_vertex_bound` and `endpoint_distance_le_edges` provide independent global checks.
-- !-- Lab Notes -- !--
-/

open Finset

namespace SnakeInTheBox

abbrev Vertex (n : ℕ) := Finset (Fin n)

/-- A list of cube vertices is a snake when it is simple, successive vertices are adjacent,
and every pair separated by at least one intervening vertex is nonadjacent. -/
def IsSnake {n : ℕ} (p : List (Vertex n)) : Prop :=
  p.Nodup ∧
  p.IsChain DaisyCube.Adj ∧
  ∀ (i j : ℕ) (hi : i < p.length) (hj : j < p.length),
    i + 1 < j → ¬ DaisyCube.Adj (p.get ⟨i, hi⟩) (p.get ⟨j, hj⟩)

/-- A snake cannot contain more vertices than the ambient Boolean cube. -/
theorem snake_vertex_bound {n : ℕ} {p : List (Vertex n)} (hp : IsSnake p) :
    p.length ≤ 2 ^ n := by
  have := List.toFinset_card_of_nodup hp.1;
  exact this ▸ le_trans ( Finset.card_le_univ _ ) ( by norm_num [ Finset.card_univ ] )

/-- If a snake omits at least one cube vertex, its vertex bound improves by one. -/
theorem snake_vertex_bound_of_not_spanning {n : ℕ} {p : List (Vertex n)}
    (hp : IsSnake p) (hproper : ∃ v : Vertex n, v ∉ p) :
    p.length ≤ 2 ^ n - 1 := by
  convert Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( Finset.card_lt_card ?_ ) ( by simp +decide [ Finset.card_univ ] : Finset.card ( Finset.univ : Finset ( Vertex n ) ) ≤ 2 ^ n ) ) using 1;
  rotate_left;
  exact p.toFinset;
  · simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
  · rw [ List.toFinset_card_of_nodup hp.1 ]

/-- Distinct nonconsecutive vertices of a snake are separated by Hamming distance at least two.
This is the error-detecting-code interpretation of chordlessness. -/
theorem nonconsecutive_distance_two {n : ℕ} {p : List (Vertex n)} (hp : IsSnake p)
    (i j : ℕ) (hi : i < p.length) (hj : j < p.length) (hsep : i + 1 < j) :
    2 ≤ DaisyCube.hdist (p.get ⟨i, hi⟩) (p.get ⟨j, hj⟩) := by
  by_contra h_contra; push_neg at h_contra; (
  interval_cases _ : DaisyCube.hdist ( p.get ⟨ i, hi ⟩ ) ( p.get ⟨ j, hj ⟩ ) <;> simp_all +decide [ DaisyCube.hdist ];
  · have := List.nodup_iff_injective_get.mp hp.1 ‹_›; aesop;
  · exact hp.2.2 i j hi hj hsep ( by unfold DaisyCube.Adj; aesop ))

/-- Any index set selecting no consecutive positions from a snake gives a binary code of
minimum Hamming distance at least two. -/
theorem spaced_subsequence_is_code {n : ℕ} {p : List (Vertex n)} (hp : IsSnake p)
    {S : Finset ℕ} (hbound : ∀ i ∈ S, i < p.length)
    (hspace : ∀ i ∈ S, ∀ j ∈ S, i < j → i + 1 < j) :
    ∀ (i : ℕ) (hi : i ∈ S) (j : ℕ) (hj : j ∈ S), i < j →
      2 ≤ DaisyCube.hdist (p.get ⟨i, hbound i hi⟩)
        (p.get ⟨j, hbound j hj⟩) := by
  exact fun i hi j hj hij => nonconsecutive_distance_two hp i j ( hbound i hi ) ( hbound j hj ) ( hspace i hi j hj hij )

/-- The endpoint Hamming distance of a nonempty snake is at most its number of edges.
This imports the metric lower bound for walks in partial cubes. -/
theorem endpoint_distance_le_edges {n : ℕ} {A : Vertex n} {q : List (Vertex n)}
    (hp : IsSnake (A :: q)) :
    DaisyCube.hdist A (q.getLastD A) ≤ q.length := by
  convert DaisyCube.walk_length_ge A q _;
  obtain ⟨ h₁, h₂, h₃ ⟩ := hp;
  induction' q with B q ih generalizing A;
  · trivial;
  · simp +zetaDelta at *;
    exact ⟨h₂.1, ih (by aesop) h₁.2.2 h₂.2
      (by
        intros i j hi hj hij
        simpa using h₃ (i + 1) (j + 1) (by linarith) (by linarith) (by linarith))⟩

/-- In particular, an endpoint pair at Hamming distance `d` forces at least `d+1` vertices. -/
theorem vertices_ge_endpoint_distance {n : ℕ} {A : Vertex n} {q : List (Vertex n)}
    (hp : IsSnake (A :: q)) :
    DaisyCube.hdist A (q.getLastD A) + 1 ≤ (A :: q).length := by
  have := endpoint_distance_le_edges hp; norm_num at *; omega;

/-- Combining ambient counting and endpoint geometry sandwiches every nonempty snake between
its endpoint distance and the size of the Boolean cube. -/
theorem snake_metric_cardinality_sandwich {n : ℕ} {A : Vertex n} {q : List (Vertex n)}
    (hp : IsSnake (A :: q)) :
    DaisyCube.hdist A (q.getLastD A) + 1 ≤ (A :: q).length ∧
      (A :: q).length ≤ 2 ^ n := by
  exact ⟨ vertices_ge_endpoint_distance hp, snake_vertex_bound hp ⟩

end SnakeInTheBox