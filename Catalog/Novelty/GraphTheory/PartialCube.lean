import Mathlib

/-!
# Daisy cubes are partial cubes

A *daisy cube* is, by the theorem of Klavžar and Mollard, an isometric subgraph of a hypercube,
i.e. a *partial cube*.  Here we model the vertices of the hypercube `Q_n` as elements of
`Finset (Fin n)` (a vertex is the set of coordinates equal to `1`), the Hamming distance as the
cardinality of the symmetric difference, and a daisy cube as the subgraph induced by a
*down-closed* vertex set.  We prove the foundational structural fact underlying the whole theory of
forbidden pc-minors for daisy cubes: **a daisy cube is an isometric subgraph of the hypercube**
(it is a partial cube).

The proof has two halves:
* `walk_length_ge` — in any subgraph of `Q_n`, a walk needs at least `hdist` edges (a lower bound
  that holds for *every* vertex set, by the triangle inequality);
* `daisy_geodesic` — in a daisy cube there is a walk of exactly `hdist` edges that never leaves the
  daisy cube, obtained by first descending to the meet `A ∩ B` and then ascending to `B`.

Together they give `daisy_isometric`.

References (catalog): Djokovic1973, Winkler1984 (Θ-classes of partial cubes); the daisy-cube
specialization is due to Klavžar–Mollard.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The class of daisy cubes (down-closed vertex sets of `Q_n`) is contained
in the class of partial cubes (isometric subgraphs of `Q_n`).  This is the geometric precondition
making "forbidden pc-minor" characterizations meaningful: every member of the class must itself be a
partial cube.

Experiment (Experimenter): Encode vertices as `Finset (Fin n)`, distance as symmetric-difference
cardinality.  Lower bound on any walk via the symmetric-difference triangle inequality
(`symmDiff_triangle`).  Upper bound via an explicit meet-join geodesic, built by strong induction on
`hdist A B`: while `A ≠ B`, either delete a coordinate of `A \ B` (stays `⊆ A`, hence in `D`) or
insert a coordinate of `B \ A` (stays `⊆ B`, hence in `D`), strictly decreasing the distance.

Analysis (Analyst): The lower bound is independent of down-closure — it is a pure hypercube fact.
Down-closure is used *only* to keep the constructed geodesic inside the vertex set; this isolates
exactly where the daisy-cube hypothesis is needed.

Critique (Critic): The result is not vacuous — `IsLeast` packages both an existence (geodesic in `D`)
and a genuine minimality (no shorter walk exists), and the proof uses induction, `rcases`, and the
triangle inequality rather than `decide`/`simp` alone.

Synthesis (PI): `daisy_isometric` is the structural anchor of the forbidden-minor program; see
`FUTURE_DIRECTIONS.md`.
-/

open scoped symmDiff
open Finset

namespace DaisyCube

variable {n : ℕ}

/-- Hamming distance between two vertices of `Q_n`. -/
def hdist (A B : Finset (Fin n)) : ℕ := (A ∆ B).card

/-- Adjacency in `Q_n`: Hamming distance `1`. -/
def Adj (A B : Finset (Fin n)) : Prop := hdist A B = 1

/-- A *daisy cube* is the subgraph of `Q_n` induced by a down-closed vertex set. -/
def IsDaisy (D : Finset (Fin n) → Prop) : Prop := ∀ ⦃A B⦄, D A → B ⊆ A → D B

/-- `IsWalk A l`: `l` lists the successive vertices visited after the start vertex `A`, each
adjacent to the previous one. The number of edges is `l.length`. -/
def IsWalk : Finset (Fin n) → List (Finset (Fin n)) → Prop
  | _, [] => True
  | A, B :: l => Adj A B ∧ IsWalk B l

lemma hdist_comm (A B : Finset (Fin n)) : hdist A B = hdist B A := by
  unfold hdist; rw [symmDiff_comm]

lemma hdist_self (A : Finset (Fin n)) : hdist A A = 0 := by simp [hdist]

lemma hdist_eq_zero {A B : Finset (Fin n)} (h : hdist A B = 0) : A = B := by
  unfold hdist at h; aesop;

lemma hdist_triangle (A B C : Finset (Fin n)) : hdist A C ≤ hdist A B + hdist B C := by
  calc (A ∆ C).card ≤ (A ∆ B ⊔ B ∆ C).card := Finset.card_le_card (symmDiff_triangle A B C)
    _ ≤ (A ∆ B).card + (B ∆ C).card := Finset.card_union_le _ _

/-
Deleting a coordinate present in `A` is an adjacency move.
-/
lemma adj_erase {A : Finset (Fin n)} {i : Fin n} (hi : i ∈ A) : Adj A (A.erase i) := by
  simp [Adj, hdist];
  rw [ Finset.card_eq_one ] ; use i ; ext x ; by_cases hx : x = i <;> simp_all +decide [ Finset.mem_symmDiff, Finset.mem_erase ] ;

/-
Inserting a coordinate absent from `A` is an adjacency move.
-/
lemma adj_insert {A : Finset (Fin n)} {j : Fin n} (hj : j ∉ A) : Adj A (insert j A) := by
  unfold Adj hdist;
  grind +suggestions

/-
Deleting a coordinate of `A \ B` decreases the distance to `B` by one.
-/
lemma hdist_erase {A B : Finset (Fin n)} {i : Fin n} (hiA : i ∈ A) (hiB : i ∉ B) :
    hdist (A.erase i) B + 1 = hdist A B := by
  convert Finset.card_erase_add_one ( show i ∈ A ∆ B from ?_ ) using 1;
  · exact congrArg₂ _ ( congr_arg Finset.card ( by ext x; by_cases hx : x = i <;> simp_all +decide [ Finset.mem_symmDiff, Finset.mem_erase ] ) ) rfl;
  · simp +decide [ *, Finset.mem_symmDiff ]

/-
Inserting a coordinate of `B \ A` decreases the distance to `B` by one.
-/
lemma hdist_insert {A B : Finset (Fin n)} {j : Fin n} (hjA : j ∉ A) (hjB : j ∈ B) :
    hdist (insert j A) B + 1 = hdist A B := by
  unfold hdist;
  rw [ ← Finset.card_erase_add_one ( show j ∈ A ∆ B from by rw [ Finset.mem_symmDiff ] ; aesop ) ];
  congr 2 with x ; by_cases hx : x = j <;> simp_all +decide [ Finset.mem_symmDiff, Finset.mem_insert ]

/-
**Lower bound.** Every walk from `A` to its last vertex uses at least `hdist` edges. This holds
in *every* subgraph of `Q_n`; it does not require down-closure.
-/
theorem walk_length_ge :
    ∀ (A : Finset (Fin n)) (l : List (Finset (Fin n))),
      IsWalk A l → hdist A (l.getLastD A) ≤ l.length := by
  intro A l h;
  induction' l with B l ih generalizing A;
  · grind +suggestions;
  · cases h;
    cases l <;> simp_all +decide [ List.getLastD ];
    · exact le_of_eq ‹_›;
    · exact le_trans ( hdist_triangle _ _ _ ) ( by linarith [ ih _ ‹_›, show hdist A B = 1 from by assumption ] )

/-
**Geodesic existence.** In a daisy cube, any two vertices are joined by a walk with exactly
`hdist` edges that never leaves the daisy cube.
-/
theorem daisy_geodesic (D : Finset (Fin n) → Prop) (hD : IsDaisy D) :
    ∀ A B, D A → D B →
      ∃ l : List (Finset (Fin n)),
        IsWalk A l ∧ (∀ z ∈ A :: l, D z) ∧ l.getLastD A = B ∧ l.length = hdist A B := by
  intro A B hA hB
  induction' m : hdist A B using Nat.strong_induction_on with m ih generalizing A B;
  by_cases hAB : A = B;
  · use []
    simp [hAB];
    exact ⟨ trivial, hB, m ▸ by simp +decide [ hAB, hdist_self ] ⟩;
  · by_cases hA_subset_B : A ⊆ B;
    · -- Since $A \subseteq B$ and $A \neq B$, there exists some $j \in B \setminus A$.
      obtain ⟨j, hjB, hjA⟩ : ∃ j, j ∈ B ∧ j ∉ A := by
        exact Finset.exists_of_ssubset ( lt_of_le_of_ne hA_subset_B hAB );
      -- Let $A' = A \cup \{j\}$.
      set A' : Finset (Fin n) := insert j A;
      -- By the induction hypothesis, there exists a walk from $A'$ to $B$ with length $hdist A' B$.
      obtain ⟨l', hl'⟩ : ∃ l' : List (Finset (Fin n)), IsWalk A' l' ∧ (∀ z ∈ A' :: l', D z) ∧ l'.getLastD A' = B ∧ l'.length = hdist A' B := by
        apply ih (hdist A' B);
        · grind +suggestions;
        · exact hD hB ( Finset.insert_subset hjB hA_subset_B );
        · assumption;
        · rfl;
      use A' :: l';
      simp_all +decide [ IsWalk ];
      exact ⟨ adj_insert hjA, by cases l' <;> aesop, by linarith [ hdist_insert hjA hjB ] ⟩;
    · obtain ⟨i, hiA, hiB⟩ : ∃ i ∈ A, i ∉ B := by
        exact Finset.not_subset.mp hA_subset_B;
      obtain ⟨l', hl'⟩ : ∃ l' : List (Finset (Fin n)), IsWalk (A.erase i) l' ∧ (∀ z ∈ A.erase i :: l', D z) ∧ l'.getLastD (A.erase i) = B ∧ l'.length = hdist (A.erase i) B := by
        apply ih (hdist (A.erase i) B);
        · linarith [ hdist_erase hiA hiB ];
        · exact hD hA ( Finset.erase_subset _ _ );
        · assumption;
        · rfl;
      use (A.erase i) :: l';
      simp_all +decide [ IsWalk ];
      exact ⟨ adj_erase hiA, by cases l' <;> aesop, by linarith [ hdist_erase hiA hiB ] ⟩

/-- **Main theorem: daisy cubes are partial cubes.** The least number of edges of a walk that stays
inside the daisy cube `D` and joins `A` to `B` equals the Hamming distance `hdist A B`; i.e. `D` is
an isometric subgraph of the hypercube. -/
theorem daisy_isometric (D : Finset (Fin n) → Prop) (hD : IsDaisy D) {A B}
    (hA : D A) (hB : D B) :
    IsLeast
      { k | ∃ l : List (Finset (Fin n)),
        IsWalk A l ∧ (∀ z ∈ A :: l, D z) ∧ l.getLastD A = B ∧ l.length = k }
      (hdist A B) := by
  constructor
  · exact daisy_geodesic D hD A B hA hB
  · rintro k ⟨l, hc, _, hlast, hlen⟩
    have h := walk_length_ge A l hc
    rw [hlast, hlen] at h
    exact h

end DaisyCube