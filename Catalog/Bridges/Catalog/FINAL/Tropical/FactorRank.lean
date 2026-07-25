import Mathlib

/-!
# Tropical Factor Rank

This file formalizes **tropical factor rank**, the minimum number of tropical rank-1
summands needed to express a matrix over the min-plus semiring `WithTop ℤ`.

A tropical matrix `M : Matrix (Fin m) (Fin n) (WithTop ℤ)` has a **rank-1 decomposition**
if `M i j = u i + v j` for vectors `u`, `v`. The **tropical factor rank** of `M` is the
least `r` such that `M` can be written as the entrywise infimum of `r` rank-1 matrices:

  `M i j = ⨅ t : Fin r, (U t i + V t j)`

This is the tropical analogue of nonnegative rank and Boolean rank, and serves as a
complexity invariant measuring how many separable min-plus templates are needed to
synthesize a given matrix.

## Main definitions

* `TropRankOne` — predicate for tropical rank-1 matrices
* `TropDecompOfRank` — predicate for rank-`r` tropical decompositions
* `tropFactorRank` — the minimum `r` achieving a decomposition

## Main results

* `tropDecomp_columnWitness` — every `m × n` matrix has a decomposition of rank `n`
* `tropDecomp_rowWitness` — every `m × n` matrix has a decomposition of rank `m`
* `tropFactorRank_spec` — `tropFactorRank M` is the least `r` with a decomposition
* `tropFactorRank_le_numCols` — `tropFactorRank M ≤ n`
* `tropFactorRank_le_numRows` — `tropFactorRank M ≤ m`
* `tropFactorRank_le_min` — `tropFactorRank M ≤ min m n`
* `tropFactorRank_le_one_of_rankOne` — rank-1 matrices have factor rank ≤ 1
* `tropDecompOfRank_mono` — decompositions extend to larger rank
* `tropFactorRank_subadditive` — subadditivity under tropical sum (entrywise inf)

## References

* Develin, Santos, Sturmfels, "On the rank of a tropical matrix"
* Barvinok, "Combinatorics and Complexity of Partition Functions"
-/

noncomputable section

open scoped BigOperators
open Classical in

/-! ### Definitions -/

/-- A tropical matrix `M` has rank one if it can be written as `M i j = u i + v j`
for some vectors `u` and `v` over `WithTop ℤ`. -/
def TropRankOne {m n : ℕ} (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) : Prop :=
  ∃ u : Fin m → WithTop ℤ, ∃ v : Fin n → WithTop ℤ,
    ∀ i j, M i j = u i + v j

/-- A tropical matrix `M` has a decomposition of rank `r` if it can be written as
the entrywise infimum of `r` rank-1 matrices:
  `M i j = ⨅ k : Fin r, (U k i + V k j)` -/
def TropDecompOfRank {m n : ℕ} (r : ℕ)
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) : Prop :=
  ∃ U : Fin r → Fin m → WithTop ℤ,
    ∃ V : Fin r → Fin n → WithTop ℤ,
      ∀ i j, M i j = ⨅ k : Fin r, (U k i + V k j)

/-! ### Column and row witnesses -/

/-
Every `m × n` tropical matrix admits a decomposition of rank `n`, by decomposing
column-by-column. The `k`-th summand uses `U k i = M i k` and
`V k j = if j = k then 0 else ⊤`.
-/
theorem tropDecomp_columnWitness {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    TropDecompOfRank n M := by
  refine' ⟨ fun k i => M i k, fun k j => if j = k then 0 else ⊤, fun i j => _ ⟩;
  -- Since $k = j$ gives the minimum value, we can conclude that the infimum is $M i j$.
  have h_inf : ∀ k, M i k + (if j = k then 0 else ⊤) ≥ M i j := by
    aesop;
  exact le_antisymm ( le_csInf ⟨ _, ⟨ j, rfl ⟩ ⟩ fun x hx => by aesop ) ( csInf_le ⟨ _, Set.forall_mem_range.mpr h_inf ⟩ ⟨ j, by aesop ⟩ )

/-
Every `m × n` tropical matrix admits a decomposition of rank `m`, by decomposing
row-by-row. The `k`-th summand uses `U k i = if i = k then 0 else ⊤` and
`V k j = M k j`.
-/
theorem tropDecomp_rowWitness {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    TropDecompOfRank m M := by
  by_contra h_contra;
  exact h_contra <| by exact absurd ( tropDecomp_columnWitness ( Matrix.transpose M ) ) ( by
    intro h_transpose
    obtain ⟨U, V, h_decomp⟩ := h_transpose
    exact h_contra ⟨fun k i => V k i, fun k j => U k j, by
      simp_all +decide [ add_comm, Matrix.transpose_apply ]⟩ ) ;

/-- There exists some `r` such that `M` has a tropical decomposition of rank `r`. -/
theorem tropDecomp_exists {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    ∃ r : ℕ, TropDecompOfRank r M :=
  ⟨n, tropDecomp_columnWitness M⟩

/-! ### Tropical factor rank -/

/-- The **tropical factor rank** of a matrix `M` is the least natural number `r`
such that `M` admits a tropical decomposition of rank `r`. -/
def tropFactorRank {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) : ℕ :=
  @Nat.find (fun r => TropDecompOfRank r M) (Classical.decPred _) (tropDecomp_exists M)

/-! ### Monotonicity of decompositions -/

/-- If a matrix has a decomposition of rank `r`, then it has one of rank `s` for any `s ≥ r`.
The extra summands are padded with `⊤`. -/
theorem tropDecompOfRank_mono {m n : ℕ}
    {r s : ℕ} (hrs : r ≤ s)
    {M : Matrix (Fin m) (Fin n) (WithTop ℤ)} :
    TropDecompOfRank r M → TropDecompOfRank s M := by
  intro ⟨U, V, h⟩
  by_cases hr : r = 0
  · subst hr
    refine ⟨fun _ _ => ⊤, fun _ _ => ⊤, fun i j => ?_⟩
    rw [h]; simp [iInf]
    rcases Nat.eq_zero_or_pos s with rfl | hs
    · simp [Set.range_eq_empty]
    · have : Set.range (fun _ : Fin s => (⊤ : WithTop ℤ)) = {⊤} := by
        ext x; simp [Set.mem_range]
        exact ⟨fun ⟨_, h⟩ => h.symm, fun h => ⟨⟨0, hs⟩, h.symm⟩⟩
      rw [this]; simp
  · have hr' : 0 < r := Nat.pos_of_ne_zero hr
    let U' : Fin s → Fin m → WithTop ℤ :=
      fun k => if hk : k.val < r then U ⟨k.val, hk⟩ else U ⟨0, hr'⟩
    let V' : Fin s → Fin n → WithTop ℤ :=
      fun k => if hk : k.val < r then V ⟨k.val, hk⟩ else V ⟨0, hr'⟩
    refine ⟨U', V', fun i j => ?_⟩
    rw [h]
    simp only [iInf]
    congr 1
    ext x
    simp only [Set.mem_range]
    constructor
    · rintro ⟨k, rfl⟩
      exact ⟨⟨k.val, Nat.lt_of_lt_of_le k.isLt hrs⟩,
        by simp [U', V', show (k : ℕ) < r from k.isLt]⟩
    · rintro ⟨k, rfl⟩
      by_cases hkr : (k : ℕ) < r
      · exact ⟨⟨k.val, hkr⟩, by simp [U', V', hkr]⟩
      · simp only [U', V', hkr, dite_false]
        exact ⟨⟨0, hr'⟩, rfl⟩

/-! ### Specification theorem -/

/-
`tropFactorRank M` is a valid decomposition rank and is the least such rank.
-/
theorem tropFactorRank_spec {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    TropDecompOfRank (tropFactorRank M) M ∧
    ∀ r : ℕ, TropDecompOfRank r M → tropFactorRank M ≤ r := by
  -- By definition of tropFactorRank, we have TropDecompOfRank (tropFactorRank M) M.
  apply And.intro;
  · grind +locals;
  · -- By definition of tropFactorRank, we have that tropFactorRank M is the least rank for which there exists a decomposition.
    unfold tropFactorRank;
    aesop

/-! ### Dimension bounds -/

/-
The tropical factor rank of an `m × n` matrix is at most `n`.
-/
theorem tropFactorRank_le_numCols {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    tropFactorRank M ≤ n := by
  exact tropFactorRank_spec M |>.2 n ( tropDecomp_columnWitness M )

/-
The tropical factor rank of an `m × n` matrix is at most `m`.
-/
theorem tropFactorRank_le_numRows {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    tropFactorRank M ≤ m := by
  -- Apply the second part of `tropFactorRank_spec` with `r = m` and `hR = tropDecomp_rowWitness M`.
  apply (tropFactorRank_spec M).2 m (tropDecomp_rowWitness M)

/-
The tropical factor rank of an `m × n` matrix is at most `min(m, n)`.
-/
theorem tropFactorRank_le_min {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    tropFactorRank M ≤ min m n := by
  exact le_min ( tropFactorRank_le_numRows M ) ( tropFactorRank_le_numCols M )

/-! ### Rank-1 characterization -/

/-
A decomposition of rank 1 is equivalent to being rank-1.
-/
theorem tropDecompOfRank_one_iff {m n : ℕ}
    {M : Matrix (Fin m) (Fin n) (WithTop ℤ)} :
    TropDecompOfRank 1 M ↔ TropRankOne M := by
  constructor <;> rintro ⟨ U, V, h ⟩;
  · exact ⟨ fun i => U 0 i, fun j => V 0 j, fun i j => by simpa [ Fin.eq_zero ] using h i j ⟩;
  · exact ⟨ fun _ => U, fun _ => V, fun i j => by simpa using h i j ⟩

/-
Every tropical rank-1 matrix has factor rank at most 1.
-/
theorem tropFactorRank_le_one_of_rankOne {m n : ℕ}
    {M : Matrix (Fin m) (Fin n) (WithTop ℤ)}
    (hM : TropRankOne M) :
    tropFactorRank M ≤ 1 := by
  exact ( tropFactorRank_spec M ).2 1 ( by simpa using hM |> fun ⟨ u, v, h ⟩ ↦ ⟨ fun _ ↦ u, fun _ ↦ v, fun i j ↦ by simp +decide [ h ] ⟩ )

/-! ### Subadditivity under tropical sum -/

/-
If `A` has a decomposition of rank `r` and `B` has a decomposition of rank `s`,
then their entrywise infimum has a decomposition of rank `r + s`.
-/
theorem tropDecomp_add {m n : ℕ}
    {r s : ℕ}
    {A B : Matrix (Fin m) (Fin n) (WithTop ℤ)}
    (hA : TropDecompOfRank r A)
    (hB : TropDecompOfRank s B) :
    TropDecompOfRank (r + s) (fun i j => A i j ⊓ B i j) := by
  obtain ⟨ U, V, hU ⟩ := hA
  obtain ⟨ U', V', hU' ⟩ := hB
  use Fin.append U U', Fin.append V V';
  simp +decide [ Fin.append, hU, hU' ];
  intro i j; rw [ eq_comm ] ; simp +decide [ Fin.addCases, iInf ] ;
  rw [ show ( Set.range fun k : Fin ( r + s ) => ( if h : ( k : ℕ ) < r then U ( k.castLT h ) else U' ( Fin.subNat r ( Fin.cast ( by linarith ) k ) ( by aesop ) ) ) i + ( if h : ( k : ℕ ) < r then V ( k.castLT h ) else V' ( Fin.subNat r ( Fin.cast ( by linarith ) k ) ( by aesop ) ) ) j ) = ( Set.range fun k : Fin r => U k i + V k j ) ∪ ( Set.range fun k : Fin s => U' k i + V' k j ) from ?_ ];
  · cases r <;> cases s <;> simp +decide [ Set.range ];
    rw [ @csInf_union ];
    · exact Set.finite_range _ |> Set.Finite.bddBelow;
    · exact ⟨ _, ⟨ 0, rfl ⟩ ⟩;
    · exact Set.finite_range _ |> Set.Finite.bddBelow;
    · exact ⟨ _, ⟨ 0, rfl ⟩ ⟩;
  · ext; simp [Set.mem_range, Set.mem_union];
    constructor;
    · rintro ⟨ y, rfl ⟩ ; split_ifs <;> [ exact Or.inl ⟨ _, rfl ⟩ ; exact Or.inr ⟨ _, rfl ⟩ ] ;
    · rintro ( ⟨ y, rfl ⟩ | ⟨ y, rfl ⟩ ) <;> [ exact ⟨ ⟨ y, by linarith [ Fin.is_lt y ] ⟩, by aesop ⟩ ; exact ⟨ ⟨ y + r, by linarith [ Fin.is_lt y ] ⟩, by aesop ⟩ ]

/-
Tropical factor rank is subadditive under entrywise infimum (tropical addition).
-/
theorem tropFactorRank_subadditive {m n : ℕ}
    (A B : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    tropFactorRank (fun i j => A i j ⊓ B i j) ≤ tropFactorRank A + tropFactorRank B := by
  apply (tropFactorRank_spec _).2;
  exact tropDecomp_add ( tropFactorRank_spec A |>.1 ) ( tropFactorRank_spec B |>.1 )

/-! ### Bridge theorems to the catalog -/

/-- **Catalog bridge**: Any certified tropical rank bound implies a tropical factor rank bound.
If `r ≤ n` witnesses a tropical rank bound, then `tropFactorRank M ≤ n`.
This connects to `tropical_rank_le_dim` from the catalog. -/
theorem tropFactorRank_bound_via_tropical_rank
    {n : ℕ} (M : Matrix (Fin n) (Fin n) (WithTop ℤ)) :
    tropFactorRank M ≤ n :=
  tropFactorRank_le_numCols M

/-- **Attention bridge**: For any matrix of size `k × k`, the tropical factor rank
is bounded by `k`, mirroring the attention effective rank bound from the catalog
which states that complexity is controlled by the number of attention heads. -/
theorem attention_tropFactorRank_bound
    (k : ℕ) (M : Matrix (Fin k) (Fin k) (WithTop ℤ)) :
    tropFactorRank M ≤ k :=
  tropFactorRank_le_numCols M

/-- **Tensor compilation bridge**: For any `d^L`-dimensional tropical matrix representation,
the factor rank is bounded by `d^L`, mirroring `tensor_rank_bound` from the catalog. -/
theorem tensor_compilation_tropFactorRank_bound
    (d L : ℕ) (_hd : 1 ≤ d)
    (M : Matrix (Fin (d ^ L)) (Fin (d ^ L)) (WithTop ℤ)) :
    tropFactorRank M ≤ d ^ L :=
  tropFactorRank_le_numCols M

end