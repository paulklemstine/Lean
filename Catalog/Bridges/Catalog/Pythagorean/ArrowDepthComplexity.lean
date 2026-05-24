import Pythagorean.STLCDefs
import Bridges.Catalog.Pythagorean.BisimMinimization
import Mathlib

/-!
# Arrow-Depth Exponential Complexity for Simple Types

This file establishes a structural complexity theory for simple types, proving that
**arrow depth alone cannot control semantic state complexity** (`typeStateBound`),
but that **type size** provides a clean exponential bound.

## Main Results

1. `typeStateBound` equals `Ty.complexity` — they share the same recurrence.
2. For **chain types** (right-spined with base-type arguments), `typeStateBound`
   is singly exponential in depth: `typeStateBound A ≤ 3^(depth A + 1)`.
3. For **bushy types** (balanced binary arrow trees), `typeStateBound` grows
   doubly exponentially: `typeStateBound (bushy n) + 1 ≥ 2^(2^n)`.
4. **Impossibility theorem**: no constant `c` can uniformly bound
   `typeStateBound A` by `c^(depth A + 1)`.
5. **Size-exponential bound**: `typeStateBound A + 1 ≤ 2^(Ty.size A)` always holds.

These results identify depth as an *insufficient* invariant and establish size
(equivalently, complexity) as the correct controlling parameter, with depth plus
width jointly characterizing the growth regime.

**Application keywords:** higher-order semantics, bisimulation minimization,
semantic state complexity, arrow depth, structural parameterization,
fixed-parameter tractability, descriptive complexity, automata state explosion,
width-depth tradeoff, semantic compression, type-theoretic complexity
-/

/-! ## New Definitions -/

/-- A **chain type** is a right-spined arrow type where every left argument is `base`.
    Chain types represent simple function pipelines: `base → base → ... → base`.
    They are the types of minimal branching complexity at each depth level. -/
def ChainTy : Ty → Prop
  | .base => True
  | .arrow A B => A = Ty.base ∧ ChainTy B

/-- **Arrow width**: the total number of arrow constructors in a type.
    This measures the "bushiness" or branching complexity of the type tree. -/
def arrowWidth : Ty → ℕ
  | .base => 0
  | .arrow A B => 1 + arrowWidth A + arrowWidth B

/-- **Bushy types**: the canonical family of maximally branching types at each depth.
    `bushy n` is a balanced binary arrow tree of depth `n`. -/
def bushy : ℕ → Ty
  | 0 => Ty.base
  | n + 1 => Ty.arrow (bushy n) (bushy n)

/-- **Depth profile**: counts type nodes at each residual depth level. -/
def depthProfile : Ty → ℕ → ℕ
  | .base, 0 => 1
  | .base, _ + 1 => 0
  | .arrow _ _, 0 => 1
  | .arrow A B, k + 1 => depthProfile A k + depthProfile B k

/-- **Predicted bound**: a certified upper bound on `typeStateBound` computable
    from the type's size. -/
def predictedBound (A : Ty) : ℕ := 2 ^ Ty.size A - 1

/-! ## Theorem 1: typeStateBound equals Ty.complexity -/

/-
`typeStateBound` and `Ty.complexity` satisfy the same recurrence with the
    same base case, hence are identical.
-/
theorem typeStateBound_eq_complexity (A : Ty) : typeStateBound A = Ty.complexity A := by
  induction' A using Ty.recOn with A B hA hB;
  · rfl;
  · rw [ show typeStateBound ( A.arrow B ) = ( typeStateBound A + 1 ) * ( typeStateBound B + 1 ) from rfl, show ( A.arrow B ).complexity = ( A.complexity + 1 ) * ( B.complexity + 1 ) from rfl, hA, hB ]

/-! ## Theorem 2: Depth is bounded by complexity -/

/-
Arrow depth is always bounded by type complexity.
-/
theorem depth_le_complexity (A : Ty) : Ty.depth A ≤ Ty.complexity A := by
  induction' A using Ty.recOn with A B ihA ihB;
  · exact Nat.zero_le _;
  · simp +arith +decide [ Ty.depth, Ty.complexity ] at *;
    constructor <;> nlinarith [ Ty.complexity_pos A, Ty.complexity_pos B ]

/-! ## Theorem 3: Chain type depth bound -/

/-
For chain types, `typeStateBound` is singly exponential in depth:
    `typeStateBound A ≤ 3^(depth A + 1)`.
-/
theorem typeStateBound_le_exp_depth_of_chain :
    ∀ A : Ty, ChainTy A → typeStateBound A ≤ 3 ^ (Ty.depth A + 1) := by
  intro AA;
  induction' AA with AA ih;
  · exact fun _ => by decide;
  · -- By definition of `ChainTy`, if `ChainTy (AA.arrow ih)` holds, then `AA = .base` and `ChainTy ih`.
    intro h_chain
    obtain ⟨rfl, h_chain_ih⟩ := h_chain;
    -- By definition of `typeStateBound`, we have `typeStateBound (.arrow Ty.base ih) = (1 + 1) * (typeStateBound ih + 1)`.
    have h_typeStateBound_arrow : typeStateBound (.arrow Ty.base ih) = 2 * (typeStateBound ih + 1) := by
      exact show ( 1 + 1 ) * ( typeStateBound ih + 1 ) = 2 * ( typeStateBound ih + 1 ) by ring;
    simp_all +decide [ Ty.depth ];
    grind +revert

/-! ## Theorem 4: Bushy type depth -/

/-
The depth of `bushy n` is exactly `n`.
-/
theorem bushy_depth_eq (n : ℕ) : Ty.depth (bushy n) = n := by
  induction' n with n ih;
  · rfl;
  · exact show 1 + Max.max ( bushy n |> Ty.depth ) ( bushy n |> Ty.depth ) = n + 1 from by simp +arith +decide [ ih ] ;

/-! ## Theorem 5: Bushy type recurrence -/

/-
The `typeStateBound` recurrence for bushy types.
-/
theorem bushy_tsb_recurrence (n : ℕ) :
    typeStateBound (bushy (n + 1)) = (typeStateBound (bushy n) + 1) ^ 2 := by
  exact Eq.symm ( by rw [ sq ] ; rfl )

/-! ## Theorem 6: Doubly-exponential lower bound for bushy types -/

/-
`typeStateBound (bushy n) + 1 ≥ 2^(2^n)`: doubly-exponential growth.
-/
theorem bushy_tsb_plus_one_ge (n : ℕ) :
    2 ^ 2 ^ n ≤ typeStateBound (bushy n) + 1 := by
  induction' n with n ih;
  · native_decide +revert;
  · convert Nat.le_succ_of_le ( pow_le_pow_left' ih 2 ) using 1 ; ring;
    exact congr_arg _ ( bushy_tsb_recurrence n )

/-! ## Theorem 7: Impossibility of uniform depth-only bound -/

/-
**Main impossibility theorem**: no constant `c` gives a uniform
    `typeStateBound A ≤ c^(depth A + 1)` bound.
-/
theorem not_exists_uniform_exp_depth_bound :
    ¬ ∃ c : ℕ, ∀ A : Ty, typeStateBound A ≤ c ^ (Ty.depth A + 1) := by
  by_contra h_contra;
  obtain ⟨ c, hc ⟩ := h_contra
  have h_contra_bushy : ∀ n, typeStateBound (bushy n) ≤ c ^ (n + 1) := by
    exact fun n => by simpa [ bushy_depth_eq ] using hc ( bushy n ) ;
  -- But typeStateBound(bushy n) + 1 ≥ 2^(2^n) by bushy_tsb_plus_one_ge.
  have h_contra_bushy_plus_one : ∀ n, 2 ^ (2 ^ n) ≤ c ^ (n + 1) + 1 := by
    exact fun n => le_trans ( bushy_tsb_plus_one_ge n ) ( Nat.succ_le_succ ( h_contra_bushy n ) );
  -- Since $c \leq 2^c$ (by le_two_pow), $c^{n+1} \leq (2^c)^{n+1} = 2^{c(n+1)}$.
  have h_contra_bushy_plus_one_simplified : ∀ n, 2 ^ (2 ^ n) ≤ 2 ^ (c * (n + 1) + 1) := by
    intros n
    have h_contra_bushy_plus_one_simplified_step : c ^ (n + 1) + 1 ≤ 2 * 2 ^ (c * (n + 1)) := by
      rw [ two_mul, pow_mul ];
      gcongr;
      · exact le_of_lt ( Nat.recOn c ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith [ Nat.one_le_pow n 2 zero_lt_two ] );
      · exact Nat.one_le_pow _ _ ( by norm_num );
    exact le_trans ( h_contra_bushy_plus_one n ) ( h_contra_bushy_plus_one_simplified_step.trans_eq ( by ring ) );
  -- So $2^n \leq c(n+1) + 1 < c(n+1) + n + 1 = (c+1)(n+1)$.
  have h_contra_bushy_plus_one_final : ∀ n, 2 ^ n ≤ (c + 1) * (n + 1) := by
    intro n; specialize h_contra_bushy_plus_one_simplified n; rw [ pow_le_pow_iff_right₀ ] at h_contra_bushy_plus_one_simplified <;> nlinarith;
  exact absurd ( h_contra_bushy_plus_one_final ( 2 * ( c + 1 ) ) ) ( by { exact Nat.recOn c ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ', Nat.pow_mul ] at * ; nlinarith } )

/-! ## Theorem 8: Size-exponential upper bound -/

/-
`typeStateBound A + 1 ≤ 2^(Ty.size A)` for all types.
-/
theorem typeStateBound_add_one_le_two_pow_size (A : Ty) :
    typeStateBound A + 1 ≤ 2 ^ Ty.size A := by
  induction' A with A B ihA ihB;
  · exact Nat.le_refl 2;
  · convert Nat.succ_le_of_lt ( lt_of_le_of_lt ( Nat.mul_le_mul ihA ihB ) _ ) using 1;
    rw [ ← pow_add ] ; exact pow_lt_pow_right₀ ( by decide ) ( by simp +arith +decide [ Ty.size ] ) ;

/-
Certified upper bound: `typeStateBound A ≤ predictedBound A`.
-/
theorem typeStateBound_le_predictedBound (A : Ty) :
    typeStateBound A ≤ predictedBound A := by
  -- Apply the lemma that states typeStateBound A + 1 ≤ 2^Ty.size A.
  have h_add_one : typeStateBound A + 1 ≤ 2 ^ Ty.size A := by
    apply typeStateBound_add_one_le_two_pow_size;
  exact Nat.le_sub_one_of_lt h_add_one

/-! ## Structural lemmas -/

/-
Arrow width satisfies `2 * arrowWidth A + 1 = Ty.size A`.
-/
theorem arrowWidth_size_relation (A : Ty) : 2 * arrowWidth A + 1 = Ty.size A := by
  induction' A using Ty.recOn with A B ihA ihB;
  · rfl;
  · exact show 2 * ( 1 + arrowWidth A + arrowWidth B ) + 1 = 1 + A.size + B.size by linarith;

/-
Arrow width is strictly less than size.
-/
theorem arrowWidth_lt_size (A : Ty) : arrowWidth A < Ty.size A := by
  exact Nat.lt_of_succ_le ( by linarith [ arrowWidth_size_relation A ] )

/-
For chain types, depth equals arrow width.
-/
theorem chain_depth_eq_arrowWidth (A : Ty) (hA : ChainTy A) :
    Ty.depth A = arrowWidth A := by
  -- We proceed by induction on A.
  induction' A with A B hA hB;
  · rfl;
  · cases hA;
    simp_all +decide [ Ty.depth, arrowWidth ]

/-
For chain types, complexity is bounded singly exponentially in depth.
-/
theorem chain_complexity_le_exp_depth (A : Ty) (hA : ChainTy A) :
    Ty.complexity A ≤ 3 ^ (Ty.depth A + 1) := by
  convert typeStateBound_le_exp_depth_of_chain A hA using 1 ; rw [ ← typeStateBound_eq_complexity ]

/-! ## Cross-domain: size bounded by depth -/

/-
Type size is at most `2^(depth + 1) - 1` (full binary tree bound).
-/
theorem size_le_exp_depth (A : Ty) : Ty.size A ≤ 2 ^ (Ty.depth A + 1) - 1 := by
  -- Since the type-state bound is greater than the type size, their depths will have the same relation.
  have h_le : ∀ A : Ty, A.size ≤ 2 ^ (A.depth + 1) - 1 := by
    intro A
    induction' A with A B ihA ihB ihB; simp +arith +decide [ *, Nat.pow_succ' ] ;
    -- We consider the size of this arrow as 1 + size(A) + size(B).
    have h_size : (A.arrow B).size = 1 + A.size + B.size := by
      rfl;
    -- We consider the depth of this arrow as 1 + max(A.depth, B.depth).
    have h_depth : (A.arrow B).depth = 1 + max A.depth B.depth := by
      rfl;
    cases max_cases A.depth B.depth <;> simp_all +decide [ pow_succ' ];
    · rw [ pow_add ];
      exact le_tsub_of_add_le_left ( by linarith [ Nat.sub_add_cancel ( show 0 < 2 * 2 ^ A.depth from by positivity ), Nat.sub_add_cancel ( show 0 < 2 * 2 ^ B.depth from by positivity ), pow_le_pow_right₀ ( show 1 ≤ 2 by decide ) ‹_› ] );
    · rw [ Nat.pow_add ];
      exact le_tsub_of_add_le_left ( by linarith [ Nat.sub_add_cancel ( show 0 < 2 * 2 ^ A.depth from by positivity ), Nat.sub_add_cancel ( show 0 < 2 * 2 ^ B.depth from by positivity ), pow_le_pow_right₀ ( show 1 ≤ 2 by decide ) ( show A.depth ≤ B.depth from by linarith ) ] )
  exact h_le A

/-
Combined doubly-exponential-in-depth upper bound.
-/
theorem typeStateBound_le_double_exp_depth (A : Ty) :
    typeStateBound A + 1 ≤ 2 ^ (2 ^ (Ty.depth A + 1) - 1) := by
  exact le_trans ( typeStateBound_add_one_le_two_pow_size A ) ( pow_le_pow_right₀ ( by decide ) ( by linarith [ size_le_exp_depth A ] ) )

/-! ## Bushy invariant computations -/

/-
Arrow width of bushy types: `arrowWidth (bushy n) = 2^n - 1`.
-/
theorem bushy_arrowWidth (n : ℕ) : arrowWidth (bushy n) = 2 ^ n - 1 := by
  induction' n with n ih;
  · rfl;
  · erw [ show arrowWidth ( Ty.arrow ( bushy n ) ( bushy n ) ) = 1 + arrowWidth ( bushy n ) + arrowWidth ( bushy n ) by rfl ] ; rw [ ih ] ; zify ; norm_num ; ring;

/-
Size of bushy types: `Ty.size (bushy n) = 2^(n+1) - 1`.
-/
theorem bushy_size (n : ℕ) : Ty.size (bushy n) = 2 ^ (n + 1) - 1 := by
  -- By definition of `bushy`, we can write its size recursively.
  have h_bushy_size_rec : ∀ n, (bushy (n + 1)).size = 1 + (bushy n).size + (bushy n).size := by
    exact fun n => Nat.add_zero ((1 + (bushy n).size).add (bushy n).size);
  exact eq_tsub_of_add_eq ( by induction n <;> simp_all +decide [ pow_succ' ] ; linarith )

/-! ## Auxiliary arithmetic lemmas -/

/-
For any `k`, there exists `n` such that `k * (n + 1) < 2^n`.
-/
theorem exp_eventually_dominates_linear (k : ℕ) :
    ∃ n : ℕ, k * (n + 1) < 2 ^ n := by
  use 2 * k + 3;
  induction' k with k ih <;> norm_num [ Nat.pow_succ', Nat.pow_mul' ] at * ; nlinarith [ Nat.one_le_pow k 2 zero_lt_two ]

/-
Every natural number is bounded by `2^n`: `c ≤ 2^c`.
-/
theorem le_two_pow (c : ℕ) : c ≤ 2 ^ c := by
  exact le_of_lt ( Nat.recOn c ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ ] at * ; linarith )