import Mathlib

/-! # Tropical Factor Rank Encoding

We define tropical factor rank for matrices over `WithTop ℤ` (min-plus semiring)
and prove that the tropical identity-like matrix (0 on diagonal, ⊤ off-diagonal)
has tropical factor rank exactly equal to its dimension.

## Main results

* `tropFactorRank_encodeDiag` : For every `s : ℕ`, the `s × s` tropical identity-like
  matrix has factor rank exactly `s`.
* `tropFactorRank_encode_exact` : The encoding function `encode` maps each natural number
  to a tropical matrix whose factor rank is that number.

## Proof strategy

**Upper bound**: Exhibit `s` rank-1 tropical matrices, one per diagonal position,
whose entrywise infimum reconstructs the identity-like matrix.

**Lower bound**: Show that any rank-1 matrix contributing to a matrix with all
off-diagonal entries `⊤` can support at most one finite diagonal entry (by a
support-separation argument). Then by pigeonhole (injectivity), at least `s`
rank-1 summands are needed.
-/

noncomputable section

open Finset

/-- Tropical matrix type: `n × n` matrices over `WithTop ℤ`. -/
abbrev tropMat (n : ℕ) := Matrix (Fin n) (Fin n) (WithTop ℤ)

/-- A decomposition of a tropical matrix `A` into `k` rank-1 terms.
    A rank-1 tropical matrix has entries `u(i) + v(j)`. The tropical sum
    (entrywise infimum) of these rank-1 terms should equal `A`. -/
def IsTropFactorization {n : ℕ} (A : tropMat n) (k : ℕ)
    (u v : Fin k → Fin n → WithTop ℤ) : Prop :=
  ∀ i j : Fin n, A i j = univ.inf (fun t => u t i + v t j)

/-- A tropical matrix has factor rank at most `k`. -/
def HasTropFactorRankLE {n : ℕ} (A : tropMat n) (k : ℕ) : Prop :=
  ∃ (u v : Fin k → Fin n → WithTop ℤ), IsTropFactorization A k u v

/-
The set of valid factorization sizes is nonempty: every `n × n` matrix
    has factor rank at most `n * n`.
-/
lemma hasTropFactorRankLE_sq {n : ℕ} (A : tropMat n) :
    HasTropFactorRankLE A (n * n) := by
      -- We need to show that any n×n matrix A has factor rank ≤ n*n. We can write A as the infimum of n*n rank-1 matrices, one for each entry.
      use fun t i => if i = (Fin.mk (t.val % n) (by
      exact Nat.mod_lt _ ( Fin.pos t |> fun x => Nat.pos_of_ne_zero ( by aesop_cat ) ))) then A (Fin.mk (t.val % n) (by
      exact Nat.mod_lt _ ( Fin.pos t |> fun x => Nat.pos_of_ne_zero ( by aesop_cat ) ))) (Fin.mk (t.val / n) (by
      exact Nat.div_lt_of_lt_mul <| by linarith [ Fin.is_lt t ] ;)) else ⊤, fun t j => if j = (Fin.mk (t.val / n) (by
      exact Nat.div_lt_of_lt_mul <| by linarith [ Fin.is_lt t ] ;)) then 0 else ⊤
      generalize_proofs at *;
      intro i j;
      refine' le_antisymm _ _ <;> simp +decide [ Finset.inf_le ];
      · intro b; split_ifs <;> simp_all +decide [ Fin.ext_iff ] ;
        congr!;
      · refine' le_trans ( Finset.inf_le _ ) _;
        exact ⟨ i + j * n, by nlinarith [ Fin.is_lt i, Fin.is_lt j ] ⟩;
        · exact Finset.mem_univ _;
        · norm_num [ Nat.add_mul_div_right _ _ ( Fin.pos i ), Nat.mod_eq_of_lt ];
          simp +decide [ Nat.div_eq_of_lt, Fin.ext_iff ]

/-
Monotonicity: if a matrix has factor rank ≤ k, then it has factor rank ≤ k' for k ≤ k'.
-/
lemma hasTropFactorRankLE_mono {n : ℕ} {A : tropMat n} {k k' : ℕ} (hk : k ≤ k')
    (h : HasTropFactorRankLE A k) : HasTropFactorRankLE A k' := by
      obtain ⟨ u, v, h ⟩ := h;
      refine' ⟨ fun i j => if hi : i.val < k then u ⟨ i.val, hi ⟩ j else ⊤, fun i j => if hi : i.val < k then v ⟨ i.val, hi ⟩ j else ⊤, fun i j => _ ⟩;
      simp_all +decide [ Finset.inf ];
      convert h i j using 1;
      refine' le_antisymm _ _ <;> simp +decide [ Finset.inf, fold ];
      · rw [ List.ofFn_eq_map, List.ofFn_eq_map ];
        rw [ ← List.take_append_drop k ( List.finRange k' ), List.map_append, List.foldr_append ];
        rw [ show List.take k ( List.finRange k' ) = List.map ( fun x : Fin k => ⟨ x, by linarith [ Fin.is_lt x ] ⟩ ) ( List.finRange k ) from ?_ ];
        · induction ( List.finRange k ) <;> aesop;
        · refine' List.ext_get _ _ <;> aesop;
      · rw [ List.ofFn_eq_map, List.ofFn_eq_map ];
        have h_foldr_le : ∀ (l : List (WithTop ℤ)), List.foldr (fun x1 x2 => min x1 x2) ⊤ l ≤ List.foldr (fun x1 x2 => min x1 x2) ⊤ (l ++ List.replicate (k' - k) ⊤) := by
          induction ( k' - k ) <;> simp_all +decide [ List.replicate ];
        convert h_foldr_le _ using 2;
        refine' List.ext_get _ _ <;> simp +decide [ List.get ];
        · rw [ Nat.add_sub_of_le hk ];
        · intro n hn hn'; split_ifs <;> simp_all +decide [ List.getElem_append ] ;

/-- The tropical factor rank: minimum `k` such that `A` is the entrywise infimum
    of `k` tropical rank-1 matrices. -/
noncomputable def tropFactorRank {n : ℕ} (A : tropMat n) : ℕ :=
  sInf {k : ℕ | HasTropFactorRankLE A k}

/-- Factor rank is at most `k` if we have a factorization of size `k`. -/
lemma tropFactorRank_le {n : ℕ} {A : tropMat n} {k : ℕ}
    (h : HasTropFactorRankLE A k) : tropFactorRank A ≤ k :=
  Nat.sInf_le h

/-- Factor rank is at least `k` if every factorization has size ≥ `k`. -/
lemma le_tropFactorRank {n : ℕ} {A : tropMat n} {k : ℕ}
    (h : ∀ m : ℕ, HasTropFactorRankLE A m → k ≤ m) : k ≤ tropFactorRank A :=
  le_csInf ⟨n * n, hasTropFactorRankLE_sq A⟩ h

/-- The tropical identity-like matrix: `0` on diagonal, `⊤` off-diagonal. -/
def encodeDiag (s : ℕ) : tropMat s := fun i j =>
  if i = j then (0 : WithTop ℤ) else ⊤

/-- The encoding function: maps `s` to an `s × s` tropical identity-like matrix. -/
def encode (s : ℕ) : Σ n : ℕ, tropMat n := ⟨s, encodeDiag s⟩

/-! ## Upper bound: `tropFactorRank (encodeDiag s) ≤ s`

We exhibit an explicit factorization using `s` rank-1 matrices.
The `t`-th rank-1 matrix places `0` at position `(t, t)` and `⊤` elsewhere.
-/

/-- The explicit factorization vectors for the upper bound. -/
def ubVec (s : ℕ) (t : Fin s) (i : Fin s) : WithTop ℤ :=
  if i = t then (0 : WithTop ℤ) else ⊤

/-
The explicit vectors give the correct factorization of `encodeDiag`.
-/
lemma ubVec_factorization (s : ℕ) :
    IsTropFactorization (encodeDiag s) s (ubVec s) (ubVec s) := by
      -- We need to show that for all $i j : Fin s$, $\text{encodeDiag s i j} = \text{univ.inf} (\lambda t, \text{ubVec s t i} + \text{ubVec s t j})$.
      intro i j
      simp [encodeDiag, ubVec];
      refine' Eq.symm ( le_antisymm _ _ );
      · exact Finset.inf_le ( Finset.mem_univ i ) |> le_trans <| by aesop;
      · refine' Finset.le_inf fun t _ => _;
        split_ifs <;> simp_all +decide [ Finset.inf_eq_iInf ]

/-- Upper bound on the factor rank of the tropical identity-like matrix. -/
theorem tropFactorRank_encodeDiag_le (s : ℕ) :
    tropFactorRank (encodeDiag s) ≤ s :=
  tropFactorRank_le ⟨ubVec s, ubVec s, ubVec_factorization s⟩

/-! ## Lower bound: `s ≤ tropFactorRank (encodeDiag s)`

### Key lemma: support separation

A tropical rank-1 matrix whose off-diagonal entries are all `⊤` can have
at most one finite diagonal entry. This is because if `u(i₁) + v(i₁) ≠ ⊤`
and `u(i₂) + v(i₂) ≠ ⊤` for `i₁ ≠ i₂`, then all four values are finite,
so `u(i₁) + v(i₂) ≠ ⊤`, contradicting the off-diagonal requirement.
-/

/-
From a factorization of `encodeDiag s`, each rank-1 term has all
    off-diagonal entries equal to `⊤`.
-/
lemma factorization_offDiag_top {s k : ℕ} {u v : Fin k → Fin s → WithTop ℤ}
    (hfact : IsTropFactorization (encodeDiag s) k u v)
    (t : Fin k) (i j : Fin s) (hij : i ≠ j) :
    u t i + v t j = ⊤ := by
      -- By definition of `IsTropFactorization`, we know that `encodeDiag s i j = (Finset.univ : Finset (Fin k)).inf (fun t' => u t' i + v t' j)`. Since `i ≠ j`, this infimum is `⊤`.
      have h_inf : (Finset.univ : Finset (Fin k)).inf (fun t' => u t' i + v t' j) = ⊤ := by
        exact hfact i j ▸ by simp +decide [ hij, encodeDiag ] ;
      contrapose! h_inf;
      exact ne_of_lt ( lt_of_le_of_lt ( Finset.inf_le ( Finset.mem_univ t ) ) ( lt_top_iff_ne_top.mpr h_inf ) )

/-
Key support-separation lemma: if all off-diagonal entries of a rank-1
    matrix are `⊤`, it cannot have finite entries at two distinct diagonal
    positions simultaneously.
-/
lemma rankOne_no_two_finite_diag {s : ℕ} {u v : Fin s → WithTop ℤ}
    (hoff : ∀ i j : Fin s, i ≠ j → u i + v j = ⊤)
    {i₁ i₂ : Fin s} (hne : i₁ ≠ i₂)
    (h₁ : u i₁ + v i₁ ≠ ⊤) (h₂ : u i₂ + v i₂ ≠ ⊤) : False := by
      cases b : v i₂ <;> simp_all +decide [ WithTop.add_eq_top ];
      grind +extAll

/-
Each diagonal position of `encodeDiag s` must be covered by some rank-1 term.
-/
lemma diag_covered {s k : ℕ} {u v : Fin k → Fin s → WithTop ℤ}
    (hfact : IsTropFactorization (encodeDiag s) k u v) (i : Fin s) :
    ∃ t : Fin k, u t i + v t i ≠ ⊤ := by
      -- By definition of `IsTropFactorization`, we know that `encodeDiag s i i = (Finset.univ.inf (fun t => u t i + v t i))`.
      have h_eq_inf : encodeDiag s i i = Finset.univ.inf (fun t => u t i + v t i) := by
        exact hfact i i;
      -- Since `encodeDiag s i i = 0`, we have `0 = Finset.univ.inf (fun t => u t i + v t i)`.
      have h_zero_inf : 0 = Finset.univ.inf (fun t => u t i + v t i) := by
        grind +locals;
      contrapose! h_zero_inf;
      cases k <;> simp +decide [ h_zero_inf ]

/-
From a factorization, we can build an injective function from `Fin s` to `Fin k`,
    proving `s ≤ k`.
-/
theorem factorization_size_ge {s k : ℕ} {u v : Fin k → Fin s → WithTop ℤ}
    (hfact : IsTropFactorization (encodeDiag s) k u v) :
    s ≤ k := by
      -- By diag_covered, for each i : Fin s, there exists t : Fin k with u t i + v t i ≠ ⊤.
      have h_diag_covered : ∀ i : Fin s, ∃ t : Fin k, u t i + v t i ≠ ⊤ := by
        exact?;
      -- Define a function `f` that maps each `i : Fin s` to a `t : Fin k` such that `u t i + v t i ≠ ⊤`.
      obtain ⟨f, hf⟩ : ∃ f : Fin s → Fin k, ∀ i : Fin s, u (f i) i + v (f i) i ≠ ⊤ := by
        exact ⟨ fun i => Classical.choose ( h_diag_covered i ), fun i => Classical.choose_spec ( h_diag_covered i ) ⟩;
      -- We prove that `f` is injective.
      have h_injective : Function.Injective f := by
        intros i₁ i₂ hij
        have h_contradiction : u (f i₁) i₁ + v (f i₁) i₁ ≠ ⊤ ∧ u (f i₁) i₂ + v (f i₁) i₂ ≠ ⊤ := by
          grind;
        exact Classical.not_not.1 fun hi => rankOne_no_two_finite_diag ( fun i j hij => factorization_offDiag_top hfact ( f i₁ ) i j hij ) hi h_contradiction.1 h_contradiction.2;
      simpa using Fintype.card_le_of_injective f h_injective

/-- Lower bound on the factor rank of the tropical identity-like matrix. -/
theorem tropFactorRank_encodeDiag_ge (s : ℕ) :
    s ≤ tropFactorRank (encodeDiag s) := by
  apply le_tropFactorRank
  intro m ⟨u, v, hfact⟩
  exact factorization_size_ge hfact

/-! ## Main theorem -/

/-- **Tropical Factor Rank Encoding Theorem.**
    For every natural number `s`, the `s × s` tropical identity-like matrix
    has factor rank exactly `s`. -/
theorem tropFactorRank_encodeDiag (s : ℕ) :
    tropFactorRank (encodeDiag s) = s :=
  le_antisymm (tropFactorRank_encodeDiag_le s) (tropFactorRank_encodeDiag_ge s)

/-- **Encoding Exactness Theorem.**
    The encoding `encode` maps each natural number to a tropical matrix
    whose factor rank is exactly that number. -/
theorem tropFactorRank_encode_exact (s : ℕ) :
    tropFactorRank (encode s).2 = s :=
  tropFactorRank_encodeDiag s

/-- Tropical factor rank is surjective onto `ℕ`:
    every natural number is realized as the factor rank of some tropical matrix. -/
theorem tropFactorRank_surjective :
    Function.Surjective (fun s => @tropFactorRank s (encodeDiag s)) :=
  fun s => ⟨s, tropFactorRank_encodeDiag s⟩

end