/-
# Tropical Collatz–Wielandt Theorem

We prove the tropical analogue of the Collatz–Wielandt variational principle:
the tropical spectral radius of a real matrix equals the optimal subeigenvalue bound.

Specifically, for a matrix `W : Matrix (Fin n) (Fin n) ℝ`, we prove:
  `HasSubeig W λ ↔ tropSpec W ≤ λ`
where `tropSpec W` is the maximum cycle mean and `HasSubeig W λ` asserts the
existence of a vector `x` with `max_j (W i j + x j) ≤ x i + λ` for all `i`.
-/
import Mathlib

open Finset BigOperators

namespace TropicalSpectral

variable {n : ℕ}

/-! ## Core Definitions -/

section Defs

variable (hn : 0 < n)

/-- Tropical matrix-vector product: `(W ⊗ x)_i = max_j (W i j + x j)`. -/
noncomputable def tropMul (W : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  Finset.sup' univ Finset.univ_nonempty fun j => W i j + x j

end Defs

/-- `x` is a subeigenvector of `W` with value `l` if `(W ⊗ x)_i ≤ x_i + l` for all `i`. -/
def IsSubeig (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (l : ℝ) (x : Fin n → ℝ) : Prop :=
  ∀ i, tropMul hn W x i ≤ x i + l

/-- `W` has subeigenvalue `l` if some subeigenvector witnesses it. -/
def HasSubeig (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (l : ℝ) : Prop :=
  ∃ x, IsSubeig hn W l x

/-- Next vertex in a cycle: `(i + 1) mod k`. -/
def cycleSucc {k : ℕ} (hk : 0 < k) (i : Fin k) : Fin k :=
  ⟨(i.1 + 1) % k, Nat.mod_lt _ hk⟩

/-- Weight of a cycle `c : Fin k → Fin n` in `W`. -/
noncomputable def cycleWt {k : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (c : Fin k → Fin n) (hk : 0 < k) : ℝ :=
  ∑ i : Fin k, W (c i) (c (cycleSucc hk i))

/-- The tropical spectral radius: maximum cycle mean over all cycles of length 1 to n. -/
noncomputable def tropSpec (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  haveI : Nonempty (Σ j : Fin n, (Fin (j.1 + 1) → Fin n)) :=
    ⟨⟨⟨0, hn⟩, fun _ => ⟨0, hn⟩⟩⟩
  Finset.sup' univ Finset.univ_nonempty
    fun p : Σ j : Fin n, (Fin (j.1 + 1) → Fin n) =>
      cycleWt W p.2 (Nat.succ_pos _) / (↑(p.1.1 + 1) : ℝ)

/-! ## Edgewise Characterization -/

/-- The tropical sup is bounded iff each summand is bounded. -/
theorem tropMul_le_iff (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (i : Fin n) (b : ℝ) :
    tropMul hn W x i ≤ b ↔ ∀ j, W i j + x j ≤ b := by
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  simp [tropMul, Finset.sup'_le_iff]

/-- Subeigenvector condition is equivalent to the edgewise bound. -/
theorem isSubeig_iff (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (l : ℝ) (x : Fin n → ℝ) :
    IsSubeig hn W l x ↔ ∀ i j, W i j + x j ≤ x i + l := by
  simp only [IsSubeig, tropMul_le_iff]

/-! ## Telescoping Sum -/

/-
Key identity: summing `f i - f (cycleSucc i)` around a cycle telescopes to zero.
-/
theorem cycleSucc_sum_zero {k : ℕ} (hk : 0 < k) (f : Fin k → ℝ) :
    ∑ i : Fin k, (f i - f (cycleSucc hk i)) = 0 := by
  rcases k with ( _ | _ | k ) <;> norm_num [ Fin.ext_iff, Fin.mod_def ] at *;
  · simp +decide [ Fin.eq_zero, cycleSucc ];
  · exact sub_eq_zero_of_eq <| Equiv.sum_comp ( Equiv.addRight 1 ) f ▸ by aesop;

/-! ## Easy Direction: HasSubeig → tropSpec ≤ l -/

/-
From a subeigenvector, every cycle has total weight at most `k * l`.
-/
theorem cycleWt_le_of_isSubeig (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (l : ℝ)
    (x : Fin n → ℝ) (hx : IsSubeig hn W l x)
    {k : ℕ} (hk : 0 < k) (c : Fin k → Fin n) :
    cycleWt W c hk ≤ ↑k * l := by
  have h_sum : ∑ i : Fin k, W (c i) (c (cycleSucc hk i)) ≤ ∑ i : Fin k, (x (c i) + l - x (c (cycleSucc hk i))) := by
    exact Finset.sum_le_sum fun i _ => by linarith [ isSubeig_iff hn W l x |>.1 hx ( c i ) ( c ( cycleSucc hk i ) ) ] ;
  have h_sum : ∑ i : Fin k, (x (c i) - x (c (cycleSucc hk i))) = 0 := by
    exact cycleSucc_sum_zero hk fun i => x (c i)
  simp_all +decide [ Finset.sum_add_distrib, Finset.sum_sub_distrib ];
  linarith!

/-
Easy direction: if `W` has subeigenvalue `l`, then `tropSpec W ≤ l`.
-/
theorem easy_direction (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (l : ℝ)
    (h : HasSubeig hn W l) : tropSpec hn W ≤ l := by
  obtain ⟨ x, hx ⟩ := h;
  exact Finset.sup'_le _ _ fun p _ => div_le_iff₀' ( by positivity ) |>.2 ( cycleWt_le_of_isSubeig hn W l x hx ( Nat.succ_pos _ ) _ )

/-! ## Hard Direction: tropSpec ≤ l → HasSubeig -/

/-- Weight of a walk `i → f 0 → f 1 → ⋯ → f (m-1)` of length `m` from vertex `i`. -/
noncomputable def walkWt (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    (m : ℕ) → (Fin m → Fin n) → ℝ
  | 0, _ => 0
  | _ + 1, f => A i (f 0) + walkWt A (f 0) _ (Fin.tail f)

/-- Maximum walk weight of length `m` from vertex `i`. -/
noncomputable def bestWalk (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) (m : ℕ) : ℝ :=
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  Finset.sup' univ Finset.univ_nonempty fun f : Fin m → Fin n => walkWt A i m f

/-- The potential: maximum walk weight over lengths 0 to n−1 from vertex `i`. -/
noncomputable def potential (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) : ℝ :=
  Finset.sup' (Finset.range n) ⟨0, Finset.mem_range.mpr hn⟩
    fun m => bestWalk hn A i m

/-
Extending a walk: prepending edge `i → j` to a walk from `j`.
-/
theorem walkWt_cons (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) (m : ℕ)
    (f : Fin m → Fin n) :
    walkWt A i (m + 1) (Fin.cons j f) = A i j + walkWt A j m f := by
  rfl

/-
A walk weight is at most the best walk weight.
-/
theorem walkWt_le_bestWalk (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) (m : ℕ) (f : Fin m → Fin n) :
    walkWt A i m f ≤ bestWalk hn A i m := by
  convert Finset.le_sup' ( fun f : Fin m → Fin n => walkWt A i m f ) ( Finset.mem_univ f ) using 1

/-
Best walk of length m is at most the potential (for m < n).
-/
theorem bestWalk_le_potential (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin n) (m : ℕ) (hm : m < n) :
    bestWalk hn A i m ≤ potential hn A i := by
  exact Finset.le_sup' ( fun m => bestWalk hn A i m ) ( Finset.mem_range.mpr hm )

/-- Vertex at position `t` in walk `(i, f 0, f 1, …, f (m-1))`. -/
def walkVert {n : ℕ} (i : Fin n) {m : ℕ} (f : Fin m → Fin n) : Fin (m + 1) → Fin n
  | ⟨0, _⟩ => i
  | ⟨t + 1, h⟩ => f ⟨t, by omega⟩

/-
walkWt expressed as a sum over edge weights.
-/
theorem walkWt_eq_sum (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) (m : ℕ)
    (f : Fin m → Fin n) :
    walkWt A i m f = ∑ t : Fin m, A (walkVert i f t.castSucc) (walkVert i f t.succ) := by
  induction' m with m ih generalizing i;
  · rfl;
  · rw [ Fin.sum_univ_succ _ ];
    convert congr_arg ( fun x => A i ( f 0 ) + x ) ( ih ( f 0 ) ( Fin.tail f ) ) using 1;
    congr! 2;
    congr! 1;
    rename_i k _;
    induction' k with k ih;
    induction' k with k ih;
    · rfl;
    · exact congr_arg f ( by simp +decide [ Fin.ext_iff, Fin.val_add, Nat.mod_eq_of_lt ih ] )

/-
Walk weight additivity: splitting a walk at position `a`.
-/
theorem walkWt_split (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) (a b : ℕ)
    (f : Fin (a + b) → Fin n) :
    walkWt A i (a + b) f =
      walkWt A i a (fun t => f ⟨t.val, by omega⟩) +
      walkWt A (walkVert i f ⟨a, by omega⟩) b (fun t => f ⟨a + t.val, by omega⟩) := by
  by_contra h_contra;
  -- Applying the definition of walkWt to both sides of the equation.
  have h_walk_def : ∀ (i : Fin n) (m : ℕ) (f : Fin m → Fin n), walkWt A i m f = ∑ t : Fin m, A (walkVert i f t.castSucc) (walkVert i f t.succ) := by
    grind +suggestions;
  simp_all +decide [ Fin.sum_univ_add ];
  refine' h_contra ( congr_arg₂ ( · + · ) _ _ );
  · congr! 2;
    rename_i k hk;
    induction' k with k ih;
    induction' k with k ih;
    · rfl;
    · simp +decide [ Fin.castAdd, walkVert ];
  · refine' Finset.sum_congr rfl fun x hx => _;
    induction x.castSucc using Fin.inductionOn <;> aesop

/-
A closed walk (one that returns to its start) has non-positive weight,
    assuming all cycles have non-positive weight.
-/
theorem walkWt_closed_nonpos (A : Matrix (Fin n) (Fin n) ℝ)
    (hcyc : ∀ (k : ℕ) (hk : 0 < k) (_ : k ≤ n) (c : Fin k → Fin n),
      cycleWt A c hk ≤ 0)
    (v : Fin n) (d : ℕ) (hd : 0 < d) (hdn : d ≤ n) (f : Fin d → Fin n)
    (hloop : walkVert v f ⟨d, by omega⟩ = v) :
    walkWt A v d f ≤ 0 := by
  -- Rewrite walkWt using walkWt_eq_sum
  have h_walkWt_eq_sum : walkWt A v d f = ∑ t : Fin d, A (walkVert v f (t.castSucc)) (walkVert v f (t.succ)) := by
    exact?;
  convert hcyc d hd hdn ( fun t => walkVert v f ⟨ t.val, by linarith [ Fin.is_lt t ] ⟩ ) using 1;
  rw [ h_walkWt_eq_sum, cycleWt ];
  refine' Finset.sum_congr rfl fun i hi => _ ; cases i ; simp +decide [ Fin.ext_iff, cycleSucc ];
  cases eq_or_lt_of_le ( Nat.succ_le_of_lt ‹_› ) <;> simp_all +decide [ Nat.mod_eq_of_lt ];
  cases d <;> aesop

/-
walkVert of a prefix sub-walk equals walkVert of the full walk.
-/
theorem walkVert_prefix (i : Fin n) (m : ℕ) (f : Fin m → Fin n)
    (a : ℕ) (ha : a ≤ m) (t : ℕ) (ht : t ≤ a) :
    walkVert i (fun s : Fin a => f ⟨s.val, by omega⟩) ⟨t, by omega⟩ =
    walkVert i f ⟨t, by omega⟩ := by
  induction t <;> unfold walkVert <;> aesop

/-
walkVert of a shifted sub-walk.
-/
theorem walkVert_shift (i : Fin n) (m : ℕ) (f : Fin m → Fin n)
    (a b : ℕ) (hab : a + b ≤ m) (t : ℕ) (ht : t ≤ b) :
    walkVert (walkVert i f ⟨a, by omega⟩)
      (fun s : Fin b => f ⟨a + s.val, by omega⟩) ⟨t, by omega⟩ =
    walkVert i f ⟨a + t, by omega⟩ := by
  unfold walkVert; aesop;

/-- Concatenation of two walk step-functions. -/
def walkConcat {a b : ℕ} (f : Fin a → Fin n) (g : Fin b → Fin n) :
    Fin (a + b) → Fin n :=
  fun t => if h : t.val < a then f ⟨t.val, h⟩ else g ⟨t.val - a, by omega⟩

/-
walkVert of a concatenated walk at position ≤ a agrees with the first walk.
-/
theorem walkVert_concat_left {a b : ℕ} (i : Fin n) (f : Fin a → Fin n)
    (g : Fin b → Fin n) (t : ℕ) (ht : t ≤ a) :
    walkVert i (walkConcat f g) ⟨t, by omega⟩ = walkVert i f ⟨t, by omega⟩ := by
  induction t <;> simp_all +decide [ walkVert ];
  rename_i k hkop;
  rcases k with ( _ | k ) <;> simp_all +decide [ walkConcat ];
  · grind;
  · grind

/-
Weight of a concatenated walk splits additively.
-/
theorem walkWt_concat (A : Matrix (Fin n) (Fin n) ℝ) (i : Fin n)
    (a b : ℕ) (f : Fin a → Fin n) (g : Fin b → Fin n) :
    walkWt A i (a + b) (walkConcat f g) =
      walkWt A i a f + walkWt A (walkVert i f ⟨a, by omega⟩) b g := by
  convert walkWt_split A i a b ( walkConcat f g ) using 3;
  · unfold walkConcat; aesop;
  · convert walkVert_concat_left i f g a le_rfl |> Eq.symm;
  · funext t; simp +decide [ walkConcat ] ;

/-
For any walk of length `n` from `i`, there exists a shorter walk
    with weight at least as large (assuming non-positive cycle weights).
-/
theorem walk_shorten (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (hcyc : ∀ (k : ℕ) (hk : 0 < k) (_ : k ≤ n) (c : Fin k → Fin n),
      cycleWt A c hk ≤ 0)
    (i : Fin n) (f : Fin n → Fin n) :
    ∃ m, m < n ∧ ∃ g : Fin m → Fin n, walkWt A i n f ≤ walkWt A i m g := by
  -- Step 1: Pigeonhole
  have pig : ∃ a b : Fin (n + 1), a.val < b.val ∧ walkVert i f a = walkVert i f b := by
    by_contra h;
    exact absurd ( Finset.card_le_univ ( Finset.image ( fun a : Fin ( n + 1 ) => walkVert i f a ) Finset.univ ) ) ( by rw [ Finset.card_image_of_injective _ fun a b hab => le_antisymm ( not_lt.1 fun ha => h ⟨ b, a, ha, hab.symm ⟩ ) ( not_lt.1 fun hb => h ⟨ a, b, hb, hab ⟩ ) ] ; norm_num )
  obtain ⟨a, b, hab, hv⟩ := pig
  set d := b.val - a.val
  set m := a.val + (n - b.val)
  have hd_pos : 0 < d := Nat.sub_pos_of_lt hab
  have hd_le : d ≤ n := by omega
  have hm_lt : m < n := by omega
  have hn_eq : n = a.val + (d + (n - b.val)) := by omega
  -- Step 2: Decompose walkWt using walkWt_split twice
  let first_wt := walkWt A i a.val (fun t : Fin a.val => f ⟨t.val, by omega⟩)
  let mid_wt := walkWt A (walkVert i f ⟨a.val, by omega⟩) d
    (fun t : Fin d => f ⟨a.val + t.val, by omega⟩)
  let last_wt := walkWt A (walkVert i f ⟨b.val, by omega⟩) (n - b.val)
    (fun t : Fin (n - b.val) => f ⟨b.val + t.val, by omega⟩)
  have h_total : walkWt A i n f = first_wt + mid_wt + last_wt := by
    -- Apply the walkWt_split lemma twice to split the walk into three parts.
    have h_split : walkWt A i n f = first_wt + walkWt A (walkVert i f ⟨a.val, by omega⟩) (d + (n - b.val)) (fun t => f ⟨a.val + t.val, by omega⟩) := by
      convert walkWt_split A i a.val ( d + ( n - b.val ) ) _ using 1;
      rotate_right 1;
      use fun t => f ⟨ t.val, by omega ⟩;
      · congr! 1;
        congr! 1;
        · exact hn_eq ▸ rfl;
        · congr! 1;
          grind +splitImp;
      · congr! 3;
        · congr! 1;
          · exact hn_eq ▸ rfl;
          · congr! 1;
            grind +revert;
        · grind;
    convert congr_arg ( fun x => first_wt + x ) ( walkWt_split A ( walkVert i f ⟨ a.val, by omega ⟩ ) d ( n - b.val ) ( fun t => f ⟨ a.val + t.val, by omega ⟩ ) ) using 1;
    rw [ ← add_assoc, walkVert_shift ];
    grind;
    · linarith;
    · exact Nat.le_add_right _ _
  -- Step 3: Middle is closed, hence non-positive
  have h_mid_closed : walkVert (walkVert i f ⟨a.val, by omega⟩)
      (fun t : Fin d => f ⟨a.val + t.val, by omega⟩) ⟨d, by omega⟩ =
      walkVert i f ⟨a.val, by omega⟩ := by
    rw [walkVert_shift i n f a.val d (by omega) d (le_refl _)]
    have : a.val + d = b.val := by omega
    rw [show (⟨a.val + d, _⟩ : Fin (n + 1)) = b from Fin.ext (by omega)]
    exact hv.symm
  have h_mid_le : mid_wt ≤ 0 :=
    walkWt_closed_nonpos A hcyc _ d hd_pos hd_le _ h_mid_closed
  -- Step 4: Construct shortened walk
  set g := walkConcat (fun t : Fin a.val => f ⟨t.val, by omega⟩)
    (fun t : Fin (n - b.val) => f ⟨b.val + t.val, by omega⟩) with hg_def
  have h_short : walkWt A i m g = first_wt + last_wt := by
    convert walkWt_concat A i a.val ( n - b.val ) ( fun t => f ⟨ t.val, by omega ⟩ ) ( fun t => f ⟨ b.val + t.val, by omega ⟩ ) using 1;
    congr! 2;
    convert hv.symm using 1;
    convert walkVert_prefix i n f a.val ( by linarith [ Fin.is_lt a, Fin.is_lt b ] ) a.val ( by linarith [ Fin.is_lt a, Fin.is_lt b ] ) using 1
  -- Step 5: Conclude
  exact ⟨m, hm_lt, g, by linarith⟩

/-
Key pigeonhole lemma: best walk of length n ≤ potential,
    assuming all cycles of length 1 to n have non-positive weight.
-/
theorem bestWalk_n_le_potential (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (hcyc : ∀ (k : ℕ) (hk : 0 < k) (_ : k ≤ n) (c : Fin k → Fin n),
      cycleWt A c hk ≤ 0)
    (i : Fin n) :
    bestWalk hn A i n ≤ potential hn A i := by
  refine' Finset.sup'_le _ _ _;
  intro f hf;
  obtain ⟨ m, hm₁, g, hg ⟩ := walk_shorten hn A hcyc i f;
  exact le_trans hg ( le_trans ( walkWt_le_bestWalk hn A i m g ) ( bestWalk_le_potential hn A i m hm₁ ) )

/-
The potential is a subeigenvector of the shifted matrix:
    `A i j + potential j ≤ potential i`.
-/
theorem potential_isSubeig (hn : 0 < n) (A : Matrix (Fin n) (Fin n) ℝ)
    (hcyc : ∀ (k : ℕ) (hk : 0 < k) (_ : k ≤ n) (c : Fin k → Fin n),
      cycleWt A c hk ≤ 0) :
    ∀ i j : Fin n, A i j + potential hn A j ≤ potential hn A i := by
  intro i j;
  -- Fix arbitrary $i$ and $j$, and consider any $m < n$.
  suffices h_le : ∀ m < n, A i j + bestWalk hn A j m ≤ potential hn A i by
    refine' add_le_of_le_sub_left _;
    exact Finset.sup'_le _ _ fun m hm => by linarith [ h_le m ( Finset.mem_range.mp hm ) ] ;
  -- By definition of bestWalk, we have that for any $m < n$, $A i j + bestWalk hn A j m \leq bestWalk hn A i (m + 1)$.
  have h_bestWalk : ∀ m < n, A i j + bestWalk hn A j m ≤ bestWalk hn A i (m + 1) := by
    intro m hm
    have h_add : ∀ g : Fin m → Fin n, A i j + walkWt A j m g ≤ walkWt A i (m + 1) (Fin.cons j g) := by
      exact fun g => by rw [ walkWt_cons ] ;
    refine' le_trans _ ( Finset.sup'_le _ _ _ );
    convert Finset.le_sup' _ ( Classical.choose_spec ( Finset.exists_max_image _ ( fun g : Fin m → Fin n => walkWt A j m g ) ⟨ fun _ => ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ) |>.1 ) using 1;
    rotate_left;
    use fun g => A i j + walkWt A j m g;
    · exact fun g _ => le_trans ( h_add g ) ( Finset.le_sup' ( fun f : Fin ( m + 1 ) → Fin n => walkWt A i ( m + 1 ) f ) ( Finset.mem_univ _ ) );
    · exact congr_arg _ ( le_antisymm ( Finset.sup'_le _ _ fun g _ => Classical.choose_spec ( Finset.exists_max_image _ ( fun g : Fin m → Fin n => walkWt A j m g ) ⟨ fun _ => ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ) |>.2 g ( Finset.mem_univ _ ) ) ( Finset.le_sup' _ ( Classical.choose_spec ( Finset.exists_max_image _ ( fun g : Fin m → Fin n => walkWt A j m g ) ⟨ fun _ => ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ) |>.1 ) ) );
  intro m hm;
  by_cases hm' : m + 1 < n;
  · exact le_trans ( h_bestWalk m hm ) ( bestWalk_le_potential hn A i _ hm' );
  · -- Since $m + 1 = n$, we have $bestWalk hn A i (m + 1) = bestWalk hn A i n$.
    have h_bestWalk_n : bestWalk hn A i (m + 1) = bestWalk hn A i n := by
      rw [ show m + 1 = n by linarith ];
    exact le_trans ( h_bestWalk m hm ) ( h_bestWalk_n.symm ▸ bestWalk_n_le_potential hn A hcyc i )

/-
Shifting: cycleWt of (W − l) relates to cycleWt of W.
-/
theorem cycleWt_sub (W : Matrix (Fin n) (Fin n) ℝ) (l : ℝ) {k : ℕ} (hk : 0 < k)
    (c : Fin k → Fin n) :
    cycleWt (fun i j => W i j - l) c hk = cycleWt W c hk - ↑k * l := by
  unfold cycleWt; simp +decide [ sub_eq_add_neg, Finset.sum_add_distrib ] ;

/-
Hard direction: if `tropSpec W ≤ l`, then `W` has subeigenvalue `l`.
-/
theorem hard_direction (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (l : ℝ)
    (h : tropSpec hn W ≤ l) : HasSubeig hn W l := by
  use fun i => potential hn ( fun i j => W i j - l ) i;
  convert potential_isSubeig hn ( fun i j => W i j - l ) _ using 1;
  · convert isSubeig_iff hn W l _ using 1;
    grind;
  · intros k hk hkn c
    have h_cycleWt : cycleWt W c hk ≤ k * l := by
      unfold tropSpec at h;
      simp +zetaDelta at *;
      convert mul_le_mul_of_nonneg_left ( h ⟨ ⟨ k - 1, by omega ⟩, fun i => c ⟨ i, by linarith [ Fin.is_lt i, Nat.sub_add_cancel hk ] ⟩ ⟩ ) ( Nat.cast_nonneg k ) using 1;
      cases k <;> norm_num [ Nat.cast_add_one_ne_zero ] at *;
      · contradiction;
      · rw [ mul_div_cancel₀ _ ( by positivity ) ];
    rw [ cycleWt_sub ] ; linarith

/-! ## Main Theorem -/

/-- **Tropical Collatz–Wielandt Theorem**: `HasSubeig W l ↔ tropSpec W ≤ l`. -/
theorem tropical_collatz_wielandt (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) (l : ℝ) :
    HasSubeig hn W l ↔ tropSpec hn W ≤ l :=
  ⟨easy_direction hn W l, hard_direction hn W l⟩

/-
The tropical spectral radius equals the infimum of feasible subeigenvalues.
-/
theorem tropSpec_eq_sInf (hn : 0 < n) (W : Matrix (Fin n) (Fin n) ℝ) :
    tropSpec hn W = sInf {l : ℝ | HasSubeig hn W l} := by
  rw [ show { l | HasSubeig hn W l } = Set.Ici ( tropSpec hn W ) from _ ];
  · exact Eq.symm ( csInf_Ici );
  · exact Set.ext fun x => tropical_collatz_wielandt hn W x

end TropicalSpectral