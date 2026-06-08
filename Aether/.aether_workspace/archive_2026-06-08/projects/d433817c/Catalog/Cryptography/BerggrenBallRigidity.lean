import Mathlib

/-!
# Finite-Ball Rigidity and Generic-Group Lower-Bound Transfer for the Berggren Embedding

This file establishes finite-ball injectivity theorems for quotients of Berggren semigroup
elements in `SL₂(ℤ)`, and derives algebraic consequences for generic-group style
discrete-log attacks on reduced Berggren images.

## Main results

### Layer 1: Finite-ball injectivity

* `exists_modulus_injective_on_finite_int_matrix_set`: For any finite set of 2×2 integer
  matrices, there exists a modulus `N ≥ 2` such that reduction mod `N` is injective.

* `exists_modulus_injective_on_pairwiseDiffSet`: Injectivity of reduction on the set
  of pairwise differences from a Berggren ball.

* `berggren_ball_quotient_powers_injective_up_to`: Injectivity of reduction on all
  bounded powers of pairwise differences.

### Layer 2: Generic-group transfer

* `reduced_relation_lifts`: Any equality mod `N` among bounded-complexity power expressions
  built from Berggren ball elements already holds over the integers.

* `berggren_ball_power_collision_lifts`: Any power collision mod `N` among quotient elements
  from the Berggren ball is already a genuine collision over `ℤ`.

* `exists_modulus_injective_on_bounded_wordExprs`: Bounded symbolic manipulations in the
  reduced group cannot create new equalities not already present over `ℤ`.

## Strategy

The core mathematical argument is:
1. The Berggren ball of radius `R` is finite, hence all derived expression sets are finite.
2. For any finite set of distinct integer matrices, a sufficiently large prime separates them
   upon reduction — this is residual separation.
3. Power collision avoidance and relation lifting follow by applying residual separation to
   enlarged finite expression sets.

## References

The Berggren tree parametrizes all primitive Pythagorean triples via three generators
acting on (3,4,5). The 2×2 matrix representation embeds this into `GL₂(ℤ)`, with two
of the three generators (M₁ and M₃) lying in `SL₂(ℤ)`.
-/

open Matrix Finset

noncomputable section

/-! ## Section 1: The three Berggren 2×2 generators -/

/-- Berggren generator M₁ (A-branch): det = 1, in SL₂(ℤ) -/
def berggren_M₁ : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

/-- Berggren generator M₂ (B-branch): det = -1, in GL₂(ℤ) -/
def berggren_M₂ : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]

/-- Berggren generator M₃ (C-branch): det = 1, in SL₂(ℤ) -/
def berggren_M₃ : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

theorem det_berggren_M₁ : Matrix.det berggren_M₁ = 1 := by native_decide
theorem det_berggren_M₃ : Matrix.det berggren_M₃ = 1 := by native_decide

/-! ## Section 2: Berggren ball definition -/

/-- A Berggren generator index. -/
inductive BerggrenGen : Type
  | g1 | g2 | g3
  deriving DecidableEq, Fintype

/-- Map generator index to its 2×2 matrix. -/
def BerggrenGen.toMatrix : BerggrenGen → Matrix (Fin 2) (Fin 2) ℤ
  | .g1 => berggren_M₁
  | .g2 => berggren_M₂
  | .g3 => berggren_M₃

/-- Evaluate a word (list of generators) to a matrix product. -/
def berggrenWordEval : List BerggrenGen → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: gs => g.toMatrix * berggrenWordEval gs

/-- All words of exactly length `n` over the 3 generators. -/
def berggrenWordsOfLength : ℕ → Finset (List BerggrenGen)
  | 0 => {[]}
  | n + 1 => Fintype.elems.biUnion fun g =>
      (berggrenWordsOfLength n).image (g :: ·)

/-- All words of length at most `R`. -/
def berggrenWordsUpTo (R : ℕ) : Finset (List BerggrenGen) :=
  (range (R + 1)).biUnion berggrenWordsOfLength

/-- The Berggren ball of radius `R`: all matrices obtainable as products of at most `R`
    generators. This is manifestly a `Finset`. -/
def berggrenBall (R : ℕ) : Finset (Matrix (Fin 2) (Fin 2) ℤ) :=
  (berggrenWordsUpTo R).image berggrenWordEval

/-- The identity matrix is always in the Berggren ball. -/
theorem one_mem_berggrenBall (R : ℕ) : (1 : Matrix (Fin 2) (Fin 2) ℤ) ∈ berggrenBall R := by
  simp only [berggrenBall, berggrenWordsUpTo, mem_image, mem_biUnion, mem_range]
  exact ⟨[], ⟨0, Nat.zero_lt_succ _, by simp [berggrenWordsOfLength]⟩,
    by simp [berggrenWordEval]⟩

/-! ## Section 3: Core residual separation lemmas -/

/-- For any finite set of integers, there exists a prime larger than all their absolute values. -/
theorem exists_prime_gt_finset_natAbs (s : Finset ℤ) :
    ∃ p : ℕ, Nat.Prime p ∧ ∀ z ∈ s, Int.natAbs z < p := by
  obtain ⟨p, hp, hle⟩ := Nat.exists_infinite_primes ((s.image Int.natAbs).sup id + 1)
  exact ⟨p, hle, fun z hz => by
    have h1 : Int.natAbs z ≤ (s.image Int.natAbs).sup id :=
      Finset.le_sup_of_le (Finset.mem_image_of_mem _ hz) le_rfl
    omega⟩

/-- If |z| < p and z ≠ 0, then z is nonzero mod p. -/
theorem int_cast_ne_zero_of_natAbs_lt
    {z : ℤ} {p : ℕ} (h : Int.natAbs z < p) (hz : z ≠ 0) :
    (z : ZMod p) ≠ 0 := by
  rw [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  intro hdvd
  have h1 : p ∣ z.natAbs := Int.ofNat_dvd_left.mp hdvd
  exact absurd (Nat.le_of_dvd (Int.natAbs_pos.mpr hz) h1) (by omega)

/-- The set of all entrywise differences between pairs of matrices in a finite set. -/
def allEntryDiffs (T : Finset (Matrix (Fin 2) (Fin 2) ℤ)) : Finset ℤ :=
  T.biUnion fun A =>
    T.biUnion fun B =>
      Finset.univ.biUnion fun i =>
        Finset.univ.image fun j => A i j - B i j

theorem allEntryDiffs_mem {T : Finset (Matrix (Fin 2) (Fin 2) ℤ)}
    {A B : Matrix (Fin 2) (Fin 2) ℤ} {i j : Fin 2}
    (hA : A ∈ T) (hB : B ∈ T) :
    A i j - B i j ∈ allEntryDiffs T := by
  simp only [allEntryDiffs, mem_biUnion, mem_image, Finset.mem_univ, true_and]
  exact ⟨A, hA, B, hB, i, ⟨j, rfl⟩⟩

/-
**Key lemma**: For any finite set of 2×2 integer matrices, there exists `N ≥ 2`
    such that reduction mod `N` is injective on the set.

    The proof picks a prime larger than all entrywise differences, ensuring that
    distinct matrices remain distinct upon reduction.
-/
theorem exists_modulus_injective_on_finite_int_matrix_set
    (T : Finset (Matrix (Fin 2) (Fin 2) ℤ)) :
    ∃ N : ℕ, 2 ≤ N ∧
      Set.InjOn
        (fun M : Matrix (Fin 2) (Fin 2) ℤ =>
          M.map (Int.castRingHom (ZMod N)))
        (↑T : Set (Matrix (Fin 2) (Fin 2) ℤ)) := by
  obtain ⟨ p, hp, hp' ⟩ := exists_prime_gt_finset_natAbs ( allEntryDiffs T );
  refine' ⟨ p, hp.two_le, fun M hM M' hM' hMM' => _ ⟩;
  ext i j; replace hMM' := congr_fun ( congr_fun hMM' i ) j; simp_all +decide [ ZMod.intCast_eq_intCast_iff ] ;
  contrapose! hp';
  exact ⟨ M i j - M' i j, allEntryDiffs_mem hM hM', Nat.le_of_dvd ( Int.natAbs_pos.mpr ( sub_ne_zero.mpr hp' ) ) ( Int.natCast_dvd.mp ( hMM'.symm.dvd ) ) ⟩

/-! ## Section 4: Pairwise difference sets and injectivity -/

/-- The set of pairwise differences `{x - y | x, y ∈ berggrenBall R}`. -/
def pairwiseDiffSet (R : ℕ) : Finset (Matrix (Fin 2) (Fin 2) ℤ) :=
  (berggrenBall R).biUnion fun x =>
    (berggrenBall R).image fun y => x - y

/-- Injectivity of reduction on pairwise differences from the Berggren ball. -/
theorem exists_modulus_injective_on_pairwiseDiffSet (R : ℕ) :
    ∃ N : ℕ, 2 ≤ N ∧
      Set.InjOn
        (fun M : Matrix (Fin 2) (Fin 2) ℤ =>
          M.map (Int.castRingHom (ZMod N)))
        (↑(pairwiseDiffSet R) : Set (Matrix (Fin 2) (Fin 2) ℤ)) :=
  exists_modulus_injective_on_finite_int_matrix_set (pairwiseDiffSet R)

/-! ## Section 5: Power collision avoidance -/

/-- The set of all power expressions `{(x - y) ^ n | x, y ∈ berggrenBall R, n ≤ K}`. -/
def quotientPowerSet (R K : ℕ) : Finset (Matrix (Fin 2) (Fin 2) ℤ) :=
  (berggrenBall R).biUnion fun x =>
    (berggrenBall R).biUnion fun y =>
      (range (K + 1)).image fun n => (x - y) ^ n

/-- Injectivity of reduction on all bounded powers of pairwise differences. -/
theorem berggren_ball_quotient_powers_injective_up_to (R K : ℕ) :
    ∃ N : ℕ, 2 ≤ N ∧
      Set.InjOn
        (fun M : Matrix (Fin 2) (Fin 2) ℤ =>
          M.map (Int.castRingHom (ZMod N)))
        (↑(quotientPowerSet R K) : Set (Matrix (Fin 2) (Fin 2) ℤ)) :=
  exists_modulus_injective_on_finite_int_matrix_set (quotientPowerSet R K)

/-- Short power collision predicate: element `g` has a power collision within bound `K`. -/
def HasShortPowerCollisionMod (N K : ℕ) (g : Matrix (Fin 2) (Fin 2) (ZMod N)) : Prop :=
  ∃ a b : ℕ, a < b ∧ b ≤ K ∧ g ^ a = g ^ b

/-! ## Section 6: Relation lifting (Layer 2) -/

/-
**Relation lifting theorem**: For bounded-complexity power expressions from the
    Berggren ball, any equality in the reduced quotient mod `N` already holds over `ℤ`.

    This is the exact statement needed in generic-group lower-bound arguments:
    any equality discovered among bounded expressions in the finite quotient was
    already present in the ambient integer matrix ring.
-/
theorem reduced_relation_lifts (R K : ℕ) :
    ∃ N : ℕ, 2 ≤ N ∧
      ∀ x y u v : Matrix (Fin 2) (Fin 2) ℤ,
        x ∈ berggrenBall R →
        y ∈ berggrenBall R →
        u ∈ berggrenBall R →
        v ∈ berggrenBall R →
        ∀ a b : ℕ, a ≤ K → b ≤ K →
        ((x - y) ^ a).map (Int.castRingHom (ZMod N)) =
        ((u - v) ^ b).map (Int.castRingHom (ZMod N)) →
        (x - y) ^ a = (u - v) ^ b := by
  obtain ⟨ N, hN₁, hN₂ ⟩ := berggren_ball_quotient_powers_injective_up_to R K; use N; simp_all +decide [ Set.InjOn ] ;
  intro x y u v hx hy hu hv a b ha hb h; specialize @hN₂ ( ( x - y ) ^ a ) ?_ ( ( u - v ) ^ b ) ?_ h <;> simp_all +decide [ quotientPowerSet ] ;
  · exact ⟨ x, hx, y, hy, a, ha, rfl ⟩;
  · exact ⟨ u, hu, v, hv, b, hb, rfl ⟩

/-- **Power collision lifting**: Any power collision mod `N` among quotient elements from
    the Berggren ball already holds over `ℤ`. Reduction mod `N` introduces no *spurious*
    power collisions.

    This is the correct formulation of subgroup-witness avoidance: a generic-group
    algorithm that finds a power collision mod `N` has merely rediscovered a relation
    that was already present over the integers. -/
theorem berggren_ball_power_collision_lifts (R K : ℕ) :
    ∃ N : ℕ, 2 ≤ N ∧
      ∀ x y : Matrix (Fin 2) (Fin 2) ℤ,
        x ∈ berggrenBall R →
        y ∈ berggrenBall R →
        ∀ a b : ℕ, a ≤ K → b ≤ K →
        ((x - y) ^ a).map (Int.castRingHom (ZMod N)) =
        ((x - y) ^ b).map (Int.castRingHom (ZMod N)) →
        (x - y) ^ a = (x - y) ^ b := by
  exact reduced_relation_lifts R K |>.imp fun N ⟨hN, hf⟩ => ⟨hN, fun x y hx hy a b ha hb h =>
    hf x y x y hx hy hx hy a b ha hb h⟩

/-! ## Section 7: Bounded word expression language and injectivity -/

/-- A symbolic expression language for bounded group computations over Berggren generators. -/
inductive WordExpr : Type
  | gen : BerggrenGen → WordExpr
  | one : WordExpr
  | mul : WordExpr → WordExpr → WordExpr
  | pow : WordExpr → ℕ → WordExpr
  deriving DecidableEq

/-- Complexity measure for word expressions.
    Includes the exponent value to ensure the set of bounded-size expressions is finite. -/
def WordExpr.size : WordExpr → ℕ
  | .gen _ => 1
  | .one => 1
  | .mul e₁ e₂ => 1 + e₁.size + e₂.size
  | .pow e n => 1 + e.size + n

/-- Evaluate a word expression to an integer matrix. -/
def WordExpr.eval : WordExpr → Matrix (Fin 2) (Fin 2) ℤ
  | .gen g => g.toMatrix
  | .one => 1
  | .mul e₁ e₂ => e₁.eval * e₂.eval
  | .pow e n => e.eval ^ n

/-- Evaluate a word expression modulo `N`. -/
def WordExpr.evalMod (N : ℕ) (e : WordExpr) : Matrix (Fin 2) (Fin 2) (ZMod N) :=
  e.eval.map (Int.castRingHom (ZMod N))

/-- The `Finset` of all matrix values obtainable by evaluating word expressions
    of size at most `K`. Constructed by induction on `K`. -/
def wordExprEvalFinset : ℕ → Finset (Matrix (Fin 2) (Fin 2) ℤ)
  | 0 => ∅
  | K + 1 =>
    let prev := wordExprEvalFinset K
    -- gen(_) and one have size 1, so they appear at K+1 ≥ 1
    let gens : Finset (Matrix (Fin 2) (Fin 2) ℤ) :=
      (Finset.univ : Finset BerggrenGen).image BerggrenGen.toMatrix
    let ones : Finset (Matrix (Fin 2) (Fin 2) ℤ) := {1}
    -- mul(e1,e2) with 1 + size(e1) + size(e2) ≤ K+1, i.e., size(e1) + size(e2) ≤ K
    let muls : Finset (Matrix (Fin 2) (Fin 2) ℤ) :=
      prev.biUnion fun m1 => prev.image fun m2 => m1 * m2
    -- pow(e, n) with 1 + size(e) + n ≤ K+1, i.e., size(e) + n ≤ K
    -- For each evaluation value m in prev and n ≤ K, include m^n
    let pows : Finset (Matrix (Fin 2) (Fin 2) ℤ) :=
      prev.biUnion fun m => (Finset.range (K + 1)).image fun n => m ^ n
    prev ∪ gens ∪ ones ∪ muls ∪ pows

/-
Every word expression of bounded size evaluates to a member of `wordExprEvalFinset`.
-/
theorem wordExpr_eval_mem_evalFinset {e : WordExpr} {K : ℕ} (h : e.size ≤ K) :
    e.eval ∈ wordExprEvalFinset K := by
  induction' K with K ih generalizing e <;> simp_all +decide [ wordExprEvalFinset ];
  · cases e <;> simp_all +decide [ WordExpr.size ];
  · rcases e with ( _ | _ | _ | _ ) <;> simp +arith +decide [ WordExpr.size ] at h ⊢;
    · exact Or.inr <| Or.inr <| Or.inl ⟨ _, rfl ⟩;
    · exact Or.inr <| Or.inr <| Or.inr <| Or.inl ⟨ _, ih <| by linarith, _, ih <| by linarith, rfl ⟩;
    · exact Or.inr <| Or.inr <| Or.inr <| Or.inr <| ⟨ _, ih <| by linarith, _, by linarith, rfl ⟩

/-- **Bounded expression injectivity**: There exists a modulus `N` such that if two
    bounded-size word expressions evaluate to the same matrix mod `N`, they already
    evaluate to the same matrix over `ℤ`.

    This is a clean generic-group surrogate: bounded symbolic manipulations in the
    reduced group cannot create new equalities not already present over `ℤ`. -/
theorem exists_modulus_injective_on_bounded_wordExprs (K : ℕ) :
    ∃ N : ℕ, 2 ≤ N ∧
      ∀ e₁ e₂ : WordExpr,
        e₁.size ≤ K → e₂.size ≤ K →
        e₁.evalMod N = e₂.evalMod N →
        e₁.eval = e₂.eval := by
  obtain ⟨N, hN, hinj⟩ := exists_modulus_injective_on_finite_int_matrix_set (wordExprEvalFinset K)
  exact ⟨N, hN, fun e₁ e₂ h₁ h₂ heq => hinj
    (wordExpr_eval_mem_evalFinset h₁) (wordExpr_eval_mem_evalFinset h₂) heq⟩

end