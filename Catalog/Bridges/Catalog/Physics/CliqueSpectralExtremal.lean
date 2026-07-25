import Mathlib

/-!
# Clique counts in complete multipartite graphs

This file formalizes a finite combinatorial core of clique extremal arguments.
If `parts = [n₁, ..., nᵣ]`, then `multipartiteCliqueCount s parts` is the
number of `s`-cliques in the complete multipartite graph with those part sizes:
one chooses `s` different parts and one vertex from each chosen part.

The main theorem proves the exact effect of moving one vertex from a larger
part to a smaller part.  Such balancing preserves vertices and cannot decrease
any clique count; for cliques using both affected parts, the gain is explicit.
-/

namespace CliqueSpectralExtremal

/-- The number of ways to choose one vertex from each of `s` distinct parts. -/
def multipartiteCliqueCount : ℕ → List ℕ → ℕ
  | 0, _ => 1
  | _ + 1, [] => 0
  | s + 1, a :: parts =>
      multipartiteCliqueCount (s + 1) parts + a * multipartiteCliqueCount s parts

@[simp] theorem multipartiteCliqueCount_zero (parts : List ℕ) :
    multipartiteCliqueCount 0 parts = 1 := by
      cases parts <;> rfl

@[simp] theorem multipartiteCliqueCount_nil (s : ℕ) :
    multipartiteCliqueCount (s + 1) [] = 0 := by
      rfl

@[simp] theorem multipartiteCliqueCount_cons (s a : ℕ) (parts : List ℕ) :
    multipartiteCliqueCount (s + 1) (a :: parts) =
      multipartiteCliqueCount (s + 1) parts + a * multipartiteCliqueCount s parts := by
        rfl

/-
Expanding according to whether a clique uses neither, one, or both of two parts.
-/
theorem two_part_expansion (s a b : ℕ) (parts : List ℕ) :
    multipartiteCliqueCount (s + 2) (a :: b :: parts) =
      multipartiteCliqueCount (s + 2) parts
        + (a + b) * multipartiteCliqueCount (s + 1) parts
        + a * b * multipartiteCliqueCount s parts := by
          grind +suggestions

/-
Exact gain in `(s+2)`-cliques after transferring a vertex from a part of
size `a` to one of size `b`, assuming `a ≥ b+1`.
-/
theorem balancing_gain (s a b : ℕ) (parts : List ℕ) (h : b + 1 ≤ a) :
    multipartiteCliqueCount (s + 2) ((a - 1) :: (b + 1) :: parts) =
      multipartiteCliqueCount (s + 2) (a :: b :: parts)
        + (a - b - 1) * multipartiteCliqueCount s parts := by
          rw [ two_part_expansion, two_part_expansion ];
          zify;
          grind

/-
Balancing two parts cannot decrease the number of cliques of any size.
-/
theorem balancing_monotone (k a b : ℕ) (parts : List ℕ) (h : b + 1 ≤ a) :
    multipartiteCliqueCount k (a :: b :: parts) ≤
      multipartiteCliqueCount k ((a - 1) :: (b + 1) :: parts) := by
        rcases k with ( _ | _ | k );
        · rfl;
        · simp +arith +decide [ multipartiteCliqueCount ];
          omega;
        · grind +suggestions

/-
If the two part sizes differ by at least two and there is a way to select
`s` further parts, balancing strictly increases the number of `(s+2)`-cliques.
-/
theorem balancing_strict (s a b : ℕ) (parts : List ℕ)
    (hgap : b + 2 ≤ a) (hrest : 0 < multipartiteCliqueCount s parts) :
    multipartiteCliqueCount (s + 2) (a :: b :: parts) <
      multipartiteCliqueCount (s + 2) ((a - 1) :: (b + 1) :: parts) := by
        rcases a with ( _ | _ | a ) <;> simp_all +decide;
        nlinarith

/-
In particular, balancing unequal parts strictly increases the edge count.
-/
theorem balancing_edges_strict (a b : ℕ) (parts : List ℕ) (hgap : b + 2 ≤ a) :
    multipartiteCliqueCount 2 (a :: b :: parts) <
      multipartiteCliqueCount 2 ((a - 1) :: (b + 1) :: parts) := by
        convert balancing_strict 0 a b parts hgap _ using 1 ; norm_num [ multipartiteCliqueCount_zero ]

/-
The balancing operation preserves the total number of vertices in the two parts.
-/
theorem balancing_preserves_vertices (a b : ℕ) (h : 1 ≤ a) :
    (a - 1) + (b + 1) = a + b := by
      omega

/-
A closed form for edges in a complete bipartite graph.
-/
theorem bipartite_edge_count (a b : ℕ) :
    multipartiteCliqueCount 2 [a, b] = a * b := by
      simp +arith +decide [ multipartiteCliqueCount ]

/-
A closed form for triangles in a complete tripartite graph.
-/
theorem tripartite_triangle_count (a b c : ℕ) :
    multipartiteCliqueCount 3 [a, b, c] = a * b * c := by
      simp +arith +decide [ multipartiteCliqueCount ];
      ring

/-
There are no `s`-cliques if fewer than `s` parts are available.
-/
theorem cliqueCount_eq_zero_of_length_lt (s : ℕ) (parts : List ℕ)
    (h : parts.length < s) : multipartiteCliqueCount s parts = 0 := by
      induction' parts with a parts ih generalizing s <;> cases s <;> simp_all +arith +decide;
      grind

/-
Exact clique count in the complete `r`-partite graph whose parts all have
size `a`: choose the participating parts, then one of `a` vertices in each.
-/
theorem equal_part_clique_count (s r a : ℕ) :
    multipartiteCliqueCount s (List.replicate r a) = r.choose s * a ^ s := by
      induction' s with s ih generalizing r;
      · induction r <;> aesop;
      · induction' r with r ih';
        · simp +decide [ Nat.choose_eq_zero_of_lt ];
        · simp_all +decide [ Nat.choose_succ_succ, List.replicate ];
          ring

/-
The balanced complete bipartite graph on `2m` vertices has `m²` edges.
-/
theorem balanced_bipartite_even (m : ℕ) :
    multipartiteCliqueCount 2 [m, m] = m ^ 2 := by
      rw [ bipartite_edge_count, pow_two ]

/-
The balanced complete tripartite graph with part size `m` has `m³` triangles.
-/
theorem balanced_tripartite_triangles (m : ℕ) :
    multipartiteCliqueCount 3 [m, m, m] = m ^ 3 := by
      rw [ tripartite_triangle_count ] ; ring

end CliqueSpectralExtremal