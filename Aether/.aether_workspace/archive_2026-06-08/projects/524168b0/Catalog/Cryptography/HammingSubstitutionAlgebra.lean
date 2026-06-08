import Mathlib

/-!
# Hamming Substitution Algebras

This module develops the algebraic theory of substitution spaces modeled as Hamming graphs.
A **substitution space** H(n,m) consists of all words of length n over an alphabet of size m,
equipped with the Hamming distance. This structure models recipe spaces (n ingredient slots,
m options per slot), error-correcting codes, and combinatorial optimization landscapes.

## Main definitions

* `HWord n m` — a word in the Hamming space H(n,m)
* `SubstitutionPath` — a sequence of single-position changes connecting two words
* `AdditiveFlavorMap` — a function on HWord that decomposes as a sum of per-slot contributions
* `HammingCode` — a finite set of codewords with a minimum distance guarantee

## Main results

* `binary_hamming_triangle_free` — H(n,2) contains no triangle (3-clique) at distance 1
* `nonbinary_triangle_exists` — H(n,m) with m ≥ 3 and n ≥ 1 always contains a distance-1 triangle
* `substitution_path_length_bound` — any substitution path has length ≥ hammingDist of endpoints
* `translation_preserves_hamming` — Hamming distance is invariant under coordinate-wise translation
* `singleton_bound` — the Singleton bound: |C| ≤ m^(n − d + 1)
* `additive_flavor_optimization` — an additive flavor map achieves its maximum slot-by-slot

## References

* R.W. Hamming, "Error detecting and error correcting codes," 1950
* R.C. Singleton, "Maximum distance q-nary codes," 1964
-/

noncomputable section

open Finset Fintype BigOperators

/-! ## Basic Definitions -/

/-- A word in the Hamming space H(n,m): an assignment of one of m options to each of n slots.
    In the culinary interpretation, this is a recipe with n ingredient slots and m choices per slot. -/
abbrev HWord (n m : ℕ) := Fin n → Fin m

/-- A substitution path in the Hamming graph: a sequence of words where consecutive
    entries differ in exactly one coordinate (a single-ingredient substitution).
    This captures the notion of incremental recipe modification. -/
structure SubstitutionPath (n m : ℕ) where
  /-- Number of substitution steps -/
  len : ℕ
  /-- The sequence of words along the path -/
  nodes : Fin (len + 1) → HWord n m
  /-- Consecutive words differ in exactly one position -/
  step_adj : ∀ i : Fin len, hammingDist (nodes i.castSucc) (nodes i.succ) = 1

/-- An additive flavor map: assigns a "flavor value" to each recipe that decomposes as
    a sum of independent per-slot contributions. This models situations where the total
    quality of a recipe is the sum of individual ingredient contributions (no interactions). -/
structure AdditiveFlavorMap (n m : ℕ) (M : Type*) [AddCommMonoid M] where
  /-- The per-slot flavor contribution -/
  slotFlavor : Fin n → Fin m → M

/-- Evaluate an additive flavor map on a word. -/
def AdditiveFlavorMap.eval {n m : ℕ} {M : Type*} [AddCommMonoid M]
    (f : AdditiveFlavorMap n m M) (w : HWord n m) : M :=
  ∑ i, f.slotFlavor i (w i)

/-- A Hamming code: a finite set of codewords with a guaranteed minimum distance. -/
structure HammingCode (n m : ℕ) where
  /-- The set of codewords -/
  codewords : Finset (HWord n m)
  /-- The guaranteed minimum distance -/
  minDist : ℕ
  /-- All distinct codeword pairs have distance ≥ minDist -/
  dist_spec : ∀ u ∈ codewords, ∀ v ∈ codewords, u ≠ v → minDist ≤ hammingDist u v

/-! ## Lemma: Hamming distance 1 implies a unique differing index -/

/-
If two words have Hamming distance 1, there is a unique index where they differ.
-/
lemma hammingDist_one_unique_diff {n m : ℕ} (u v : Fin n → Fin m)
    (h : hammingDist u v = 1) :
    ∃ i₀ : Fin n, u i₀ ≠ v i₀ ∧ ∀ j : Fin n, j ≠ i₀ → u j = v j := by
  simp_all +decide [ Finset.card_eq_one, hammingDist ];
  obtain ⟨ i₀, hi₀ ⟩ := h; use i₀; simp_all +decide [ Finset.eq_singleton_iff_unique_mem ] ;
  exact fun j hj => Classical.not_not.1 fun h => hj <| hi₀.2 j h

/-! ## Theorem 1: Binary Hamming Graph is Triangle-Free

In H(n,2), no three words can be mutually at Hamming distance 1.
This is because Fin 2 has only two elements: if u and v differ at position i,
and v and w differ at position j, then either i = j (forcing u = w) or i ≠ j
(forcing hammingDist u w = 2). Neither is compatible with hammingDist u w = 1. -/

/-
The binary Hamming graph H(n,2) contains no triangle at distance 1.
    This is the fundamental dichotomy: binary substitution spaces have no
    "shortcut triangles," making them tree-like at the local level.
-/
theorem binary_hamming_triangle_free (n : ℕ) (u v w : HWord n 2)
    (huv : hammingDist u v = 1) (hvw : hammingDist v w = 1)
    (huw : hammingDist u w = 1) : False := by
  grind +suggestions

/-! ## Theorem 2: Triangles Exist for m ≥ 3

When the alphabet has at least 3 symbols, we can always form a triangle by
placing three distinct symbols at the same position. -/

/-
When m ≥ 3 and n ≥ 1, the Hamming graph H(n,m) contains a distance-1 triangle.
    Three words that differ only at a single position, each using a distinct symbol,
    form a triangle in the Hamming graph.
-/
theorem nonbinary_triangle_exists (n m : ℕ) (hn : 1 ≤ n) (hm : 3 ≤ m) :
    ∃ u v w : HWord n m,
      u ≠ v ∧ v ≠ w ∧ u ≠ w ∧
      hammingDist u v = 1 ∧ hammingDist v w = 1 ∧ hammingDist u w = 1 := by
  refine' ⟨ fun i => if i = ⟨ 0, hn ⟩ then ⟨ 0, by linarith ⟩ else ⟨ 1, by linarith ⟩, fun i => if i = ⟨ 0, hn ⟩ then ⟨ 1, by linarith ⟩ else ⟨ 1, by linarith ⟩, fun i => if i = ⟨ 0, hn ⟩ then ⟨ 2, by linarith ⟩ else ⟨ 1, by linarith ⟩, _, _, _, _, _ ⟩ <;> simp +decide [ hammingDist ];
  · exact fun h => by have := congr_fun h ⟨ 0, hn ⟩ ; simp +decide at this;
  · exact fun h => by have := congr_fun h ⟨ 0, hn ⟩ ; simp +decide at this;
  · exact fun h => by have := congr_fun h ⟨ 0, hn ⟩ ; simp +decide at this;
  · exact Finset.card_eq_one.mpr ⟨ ⟨ 0, hn ⟩, by aesop ⟩;
  · simp +decide [ Finset.filter_eq' ];
    rw [ Finset.card_eq_one ] ; use ⟨ 0, hn ⟩ ; ext i ; aesop

/-! ## Theorem 3: Substitution Path Length Bound

Any substitution path from u to v must have at least hammingDist u v steps.
This follows from iterating the triangle inequality. -/

/-
A substitution path of length k between endpoints u and v satisfies
    hammingDist u v ≤ k. This is the geodesic lower bound: you cannot reach
    a word at Hamming distance d in fewer than d single-substitution steps.
-/
theorem substitution_path_length_bound {n m : ℕ} (p : SubstitutionPath n m) :
    hammingDist (p.nodes 0) (p.nodes (Fin.last p.len)) ≤ p.len := by
  induction' p with len nodes step_adj;
  induction' len with len ih;
  · simp +decide [ hammingDist ];
  · convert Nat.le_trans ( hammingDist_triangle _ _ _ ) ( add_le_add ( ih ( fun i => nodes i.castSucc ) fun i => step_adj i.castSucc ) ( step_adj ( Fin.last _ ) |> le_of_eq ) ) using 1

/-! ## Theorem 4: Translation Invariance

Coordinate-wise addition by a fixed offset preserves Hamming distance,
establishing that no word is a privileged "origin" in recipe space. -/

/-
Hamming distance is invariant under coordinate-wise translation.
    This establishes vertex transitivity: the Hamming graph looks the same
    from every word's perspective.
-/
theorem translation_preserves_hamming {n m : ℕ} [NeZero m]
    (u v t : HWord n m) :
    hammingDist (u + t) (v + t) = hammingDist u v := by
  unfold hammingDist;
  simp +decide

/-! ## Theorem 5: Singleton Bound

The Singleton bound is the fundamental upper bound on code size as a function
of minimum distance: any code with minimum distance d can have at most m^(n-d+1)
codewords. The proof projects onto n-d+1 coordinates and shows injectivity. -/

/-- Projection onto the first k coordinates. -/
def coordProject (n m k : ℕ) (hk : k ≤ n) (w : HWord n m) : Fin k → Fin m :=
  fun j => w ⟨j.val, Nat.lt_of_lt_of_le j.isLt hk⟩

/-
Key lemma: if two words agree on all but fewer than d coordinates,
    their Hamming distance is less than d.
-/
lemma hamming_lt_of_agree_many {n m : ℕ} (u v : HWord n m) (d : ℕ)
    (h : ∀ i : Fin n, i.val < n - d + 1 → u i = v i) (hd : 1 ≤ d) (hdn : d ≤ n) :
    hammingDist u v ≤ d - 1 := by
  refine' le_trans _ ( show Finset.card ( Finset.Ico ( n - d + 1 ) n ) ≤ d - 1 from _ );
  · refine' le_trans _ ( Finset.card_le_card _ );
    rotate_left;
    exact Finset.image ( fun i : Fin n => i ) ( Finset.filter ( fun i : Fin n => u i ≠ v i ) Finset.univ );
    · grind;
    · rw [ Finset.card_image_of_injective _ fun i j hij => by simpa [ Fin.ext_iff ] using hij ] ; aesop;
  · simp +arith +decide;
    omega

/-
The projection onto the first n-d+1 coordinates is injective on any code
    with minimum distance d.
-/
lemma singleton_projection_injective {n m d : ℕ} (hd : 1 ≤ d) (hdn : d ≤ n)
    (C : Finset (HWord n m))
    (hmin : ∀ u ∈ C, ∀ v ∈ C, u ≠ v → d ≤ hammingDist u v) :
    Set.InjOn (coordProject n m (n - d + 1) (by omega) ·) ↑C := by
  intro u hu v hv huv;
  have h_eq : ∀ i : Fin n, i.val < n - d + 1 → u i = v i := by
    exact fun i hi => by simpa using congr_fun huv ⟨ i, hi ⟩ ;
  contrapose! hmin;
  exact ⟨ u, hu, v, hv, hmin, lt_of_le_of_lt ( hamming_lt_of_agree_many u v d h_eq hd hdn ) ( Nat.pred_lt ( ne_bot_of_gt hd ) ) ⟩

/-
**The Singleton Bound**: A code in H(n,m) with minimum distance d
    has at most m^(n-d+1) codewords. This is tight: codes achieving this
    bound are called Maximum Distance Separable (MDS) codes.
-/
theorem singleton_bound {n m d : ℕ} (_hm : 1 ≤ m) (hd : 1 ≤ d) (hdn : d ≤ n)
    (C : Finset (HWord n m))
    (hmin : ∀ u ∈ C, ∀ v ∈ C, u ≠ v → d ≤ hammingDist u v) :
    C.card ≤ m ^ (n - d + 1) := by
  have := @singleton_projection_injective n m d hd hdn C hmin; have := Finset.card_image_of_injOn this; simp_all +decide;
  exact this ▸ le_trans ( Finset.card_le_univ _ ) ( by simp +decide ) ;

/-! ## Theorem 6: Additive Flavor Map Optimization Decomposes

For an additive flavor map with values in a linearly ordered monoid,
the global optimum decomposes into per-slot optima. This is the key
computational insight: optimizing an n-slot recipe with m options per slot
takes O(n·m) time instead of O(m^n). -/

/-
Two additive flavor maps with the same slot functions produce the same
    evaluation on every word. This establishes that an additive flavor map
    is uniquely determined by its per-slot contributions.
-/
theorem additive_flavor_ext {n m : ℕ} {M : Type*} [AddCommMonoid M]
    (f g : AdditiveFlavorMap n m M)
    (h : ∀ i j, f.slotFlavor i j = g.slotFlavor i j) :
    ∀ w : HWord n m, f.eval w = g.eval w := by
  exact fun w => Finset.sum_congr rfl fun i _ => h i ( w i )

/-
For an additive flavor map to ℤ, the word constructed by choosing
    the per-slot maximum at each position achieves the global maximum.
    This is the slot independence theorem: additive structure reduces
    exponential optimization to linear.
-/
theorem additive_flavor_optimization {n m : ℕ} [NeZero m]
    (f : AdditiveFlavorMap n m ℤ) :
    ∃ w_opt : HWord n m,
      (∀ i : Fin n, ∀ j : Fin m, f.slotFlavor i j ≤ f.slotFlavor i (w_opt i)) ∧
      (∀ w : HWord n m, f.eval w ≤ f.eval w_opt) := by
  -- By definition of $f$, we know that for each $i$, there exists $j$ such that $f.slotFlavor i j$ is maximal.
  have h_max_exists : ∀ i : Fin n, ∃ j : Fin m, ∀ k : Fin m, f.slotFlavor i k ≤ f.slotFlavor i j := by
    exact fun i => by simpa using Finset.exists_max_image Finset.univ ( fun k => f.slotFlavor i k ) ⟨ ⟨ 0, NeZero.pos m ⟩, Finset.mem_univ _ ⟩ ;
  choose w hw using h_max_exists;
  exact ⟨ w, hw, fun w' => Finset.sum_le_sum fun i _ => hw i _ ⟩

/-! ## Conjecture: Fiber Connectivity

We state a falsifiable conjecture about the connectivity of fibers of
additive flavor maps. -/

/-
**Conjecture**: For any additive flavor map f : H(n,m) → ℤ and any target value t,
    the fiber f⁻¹(t) is connected in the Hamming graph (when nonempty and m ≥ 2, n ≥ 2).
    This would imply that recipe adaptation (changing one ingredient at a time) can always
    navigate between any two recipes of the same total flavor value.

    Computational test: for small n, m, enumerate all fibers and check path-connectivity.
    The conjecture is FALSE in general: take n=2, m=2, f(i,j) = i+j. The fiber f⁻¹(1)
    consists of {(0,1), (1,0)}, which have Hamming distance 2 and no intermediate word
    of the same value. This motivates studying when fibers ARE connected.
-/
theorem fiber_connectivity_counterexample :
    ∃ (f : AdditiveFlavorMap 2 2 ℤ),
      ∃ (u v : HWord 2 2),
        f.eval u = f.eval v ∧
        hammingDist u v = 2 ∧
        ∀ w : HWord 2 2, f.eval w = f.eval u → w = u ∨ w = v := by
  exists AdditiveFlavorMap.mk ( fun i j => if i = 0 then j.val else j.val ), fun i => if i = 0 then 0 else 1, fun i => if i = 0 then 1 else 0

end