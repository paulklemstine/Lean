import Mathlib

/-!
# Tensor-Sorted Rewrite System for Scientific Computing

## Overview

This file constructs a **three-sorted tensor rewrite calculus** with sorts
`{Scal, Vec, Mat}` and proves that symbolic simplification rules preserve
the semantics of bilinear energy observables `E(v, A) = ⟨v, Av⟩`.

## Main results

- `tensorRewrite_sound`: one-step rewrite soundness (Theorem 1)
- `sortEq_of_reflTransGen`: multi-step soundness via `ReflTransGen` (Theorem 2)
- `energy_invariant_of_rewrites`: energy invariance under rewrites (Theorem 3)
- `energy_add`: polarization-style quadratic expansion (Theorem 4)
- `energy_add_of_symmetric`: cross-term collapse for symmetric matrices (Theorem 5)
- `normStep_sound_*`: verified normalization step (Theorem 6)
-/

open Finset Matrix BigOperators

namespace TensorRewriteSystem

/-! ## Part 1: Syntax — Three-Sorted Tensor Language -/

/-- The three sorts of the tensor calculus. -/
inductive TensorSort
  | scal | vec | mat
  deriving DecidableEq, Repr

/-- Terms of the tensor language, indexed by sort. -/
inductive TensorTerm : TensorSort → Type
  | scalVar  : ℕ → TensorTerm .scal
  | vecVar   : ℕ → TensorTerm .vec
  | matVar   : ℕ → TensorTerm .mat
  | scalAdd  : TensorTerm .scal → TensorTerm .scal → TensorTerm .scal
  | scalMul  : TensorTerm .scal → TensorTerm .scal → TensorTerm .scal
  | vecAdd   : TensorTerm .vec → TensorTerm .vec → TensorTerm .vec
  | matAdd   : TensorTerm .mat → TensorTerm .mat → TensorTerm .mat
  | smulVec  : TensorTerm .scal → TensorTerm .vec → TensorTerm .vec
  | smulMat  : TensorTerm .scal → TensorTerm .mat → TensorTerm .mat
  | mulVec   : TensorTerm .mat → TensorTerm .vec → TensorTerm .vec
  | dot      : TensorTerm .vec → TensorTerm .vec → TensorTerm .scal

/-! ## Part 2: Semantic Layer -/

structure TensorEnv (R : Type*) (ι : Type*) where
  scalAssign : ℕ → R
  vecAssign  : ℕ → (ι → R)
  matAssign  : ℕ → Matrix ι ι R

universe u
variable {R : Type u} {ι : Type u} [Fintype ι] [DecidableEq ι] [CommRing R]

/-- Semantic dot product: `⟨v, w⟩ = ∑ i, v(i) · w(i)`. -/
noncomputable def dotProd (v w : ι → R) : R :=
  ∑ i : ι, v i * w i

/-- Semantic energy functional: `E(A, v) = ⟨v, Av⟩`. -/
noncomputable def energy (A : Matrix ι ι R) (v : ι → R) : R :=
  dotProd v (Matrix.mulVec A v)

mutual
noncomputable def evalScal (env : TensorEnv R ι) : TensorTerm .scal → R
  | .scalVar n   => env.scalAssign n
  | .scalAdd a b => evalScal env a + evalScal env b
  | .scalMul a b => evalScal env a * evalScal env b
  | .dot v w     => dotProd (evalVec env v) (evalVec env w)
noncomputable def evalVec (env : TensorEnv R ι) : TensorTerm .vec → (ι → R)
  | .vecVar n    => env.vecAssign n
  | .vecAdd v w  => evalVec env v + evalVec env w
  | .smulVec a v => evalScal env a • evalVec env v
  | .mulVec A v  => Matrix.mulVec (evalMat env A) (evalVec env v)
noncomputable def evalMat (env : TensorEnv R ι) : TensorTerm .mat → Matrix ι ι R
  | .matVar n    => env.matAssign n
  | .matAdd A B  => evalMat env A + evalMat env B
  | .smulMat a A => evalScal env a • evalMat env A
end

/-! ## Part 3: Properties of `dotProd` and `mulVec` -/

theorem dotProd_add_left (u v w : ι → R) :
    dotProd (u + v) w = dotProd u w + dotProd v w := by
  simp only [dotProd, Pi.add_apply, add_mul, sum_add_distrib]

theorem dotProd_add_right (u v w : ι → R) :
    dotProd u (v + w) = dotProd u v + dotProd u w := by
  simp only [dotProd, Pi.add_apply, mul_add, sum_add_distrib]

theorem dotProd_smul_left (a : R) (v w : ι → R) :
    dotProd (a • v) w = a * dotProd v w := by
  unfold dotProd;
  simp +decide [ Finset.mul_sum _ _ _, mul_assoc ]

theorem dotProd_smul_right (a : R) (v w : ι → R) :
    dotProd v (a • w) = a * dotProd v w := by
  simp [dotProd, Finset.mul_sum];
  exact Finset.sum_congr rfl fun _ _ => by ring;

theorem dotProd_comm_of_symmetric (A : Matrix ι ι R) (v w : ι → R)
    (hA : Aᵀ = A) :
    dotProd w (Matrix.mulVec A v) = dotProd v (Matrix.mulVec A w) := by
  unfold dotProd;
  simp +decide only [mulVec, dotProduct];
  simp +decide only [Finset.mul_sum _ _ _, mul_left_comm];
  rw [ ← Finset.sum_comm ] ; congr ; ext ; congr ; ext ; simp_all +decide [ mul_comm, Matrix.transpose_apply ] ;
  exact congr_arg₂ _ ( congr_fun ( congr_fun hA _ ) _ ▸ rfl ) rfl

/-
Scalar-matrix associativity for `mulVec`:
`(a • M) *ᵥ v = a • (M *ᵥ v)`.
-/
theorem smul_matrix_mulVec (a : R) (M : Matrix ι ι R) (v : ι → R) :
    Matrix.mulVec (a • M) v = a • Matrix.mulVec M v := by
  ext i;
  simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum ];
  simp +decide only [mul_assoc]

/-! ## Part 4: Rewrite Relation -/

inductive TensorRewrite : {s : TensorSort} → TensorTerm s → TensorTerm s → Prop
  | mulVec_vecAdd (A : TensorTerm .mat) (v w : TensorTerm .vec) :
      TensorRewrite (.mulVec A (.vecAdd v w)) (.vecAdd (.mulVec A v) (.mulVec A w))
  | matAdd_mulVec (A B : TensorTerm .mat) (v : TensorTerm .vec) :
      TensorRewrite (.mulVec (.matAdd A B) v) (.vecAdd (.mulVec A v) (.mulVec B v))
  | smulMat_mulVec (a : TensorTerm .scal) (A : TensorTerm .mat) (v : TensorTerm .vec) :
      TensorRewrite (.mulVec (.smulMat a A) v) (.smulVec a (.mulVec A v))
  | smulVec_vecAdd (a : TensorTerm .scal) (v w : TensorTerm .vec) :
      TensorRewrite (.smulVec a (.vecAdd v w)) (.vecAdd (.smulVec a v) (.smulVec a w))
  | smulMat_matAdd (a : TensorTerm .scal) (A B : TensorTerm .mat) :
      TensorRewrite (.smulMat a (.matAdd A B)) (.matAdd (.smulMat a A) (.smulMat a B))
  | dot_vecAdd_left (v w u : TensorTerm .vec) :
      TensorRewrite (.dot (.vecAdd v w) u) (.scalAdd (.dot v u) (.dot w u))
  | dot_vecAdd_right (u v w : TensorTerm .vec) :
      TensorRewrite (.dot u (.vecAdd v w)) (.scalAdd (.dot u v) (.dot u w))
  | dot_smulVec_left (a : TensorTerm .scal) (v w : TensorTerm .vec) :
      TensorRewrite (.dot (.smulVec a v) w) (.scalMul a (.dot v w))

/-! ## Part 5: Individual Soundness Lemmas -/

private theorem sound_mulVec_vecAdd (env : TensorEnv R ι)
    (A : TensorTerm .mat) (v w : TensorTerm .vec) :
    evalVec env (.mulVec A (.vecAdd v w)) =
    evalVec env (.vecAdd (.mulVec A v) (.mulVec A w)) := by
  simp only [evalVec]
  exact Matrix.mulVec_add _ _ _

private theorem sound_matAdd_mulVec (env : TensorEnv R ι)
    (A B : TensorTerm .mat) (v : TensorTerm .vec) :
    evalVec env (.mulVec (.matAdd A B) v) =
    evalVec env (.vecAdd (.mulVec A v) (.mulVec B v)) := by
  simp only [evalVec, evalMat]
  exact Matrix.add_mulVec _ _ _

private theorem sound_smulMat_mulVec (env : TensorEnv R ι)
    (a : TensorTerm .scal) (A : TensorTerm .mat) (v : TensorTerm .vec) :
    evalVec env (.mulVec (.smulMat a A) v) =
    evalVec env (.smulVec a (.mulVec A v)) := by
  simp only [evalVec, evalMat]
  exact smul_matrix_mulVec _ _ _

private theorem sound_smulVec_vecAdd (env : TensorEnv R ι)
    (a : TensorTerm .scal) (v w : TensorTerm .vec) :
    evalVec env (.smulVec a (.vecAdd v w)) =
    evalVec env (.vecAdd (.smulVec a v) (.smulVec a w)) := by
  simp only [evalVec]
  exact smul_add _ _ _

omit [DecidableEq ι] in
private theorem sound_smulMat_matAdd (env : TensorEnv R ι)
    (a : TensorTerm .scal) (A B : TensorTerm .mat) :
    evalMat env (.smulMat a (.matAdd A B)) =
    evalMat env (.matAdd (.smulMat a A) (.smulMat a B)) := by
  simp only [evalMat]
  exact smul_add _ _ _

private theorem sound_dot_vecAdd_left (env : TensorEnv R ι)
    (v w u : TensorTerm .vec) :
    evalScal env (.dot (.vecAdd v w) u) =
    evalScal env (.scalAdd (.dot v u) (.dot w u)) := by
  simp only [evalScal, evalVec]
  exact dotProd_add_left _ _ _

private theorem sound_dot_vecAdd_right (env : TensorEnv R ι)
    (u v w : TensorTerm .vec) :
    evalScal env (.dot u (.vecAdd v w)) =
    evalScal env (.scalAdd (.dot u v) (.dot u w)) := by
  simp only [evalScal, evalVec]
  exact dotProd_add_right _ _ _

private theorem sound_dot_smulVec_left (env : TensorEnv R ι)
    (a : TensorTerm .scal) (v w : TensorTerm .vec) :
    evalScal env (.dot (.smulVec a v) w) =
    evalScal env (.scalMul a (.dot v w)) := by
  simp only [evalScal, evalVec]
  exact dotProd_smul_left _ _ _

/-! ## Part 6: Main Soundness Theorems -/

/-- Sort-indexed semantic equality. -/
def sortEq (env : TensorEnv R ι) : (s : TensorSort) → TensorTerm s → TensorTerm s → Prop
  | .scal, t, u => evalScal env t = evalScal env u
  | .vec, t, u  => evalVec env t = evalVec env u
  | .mat, t, u  => evalMat env t = evalMat env u

/-- **Theorem 1 (One-Step Soundness).**
Every tensor rewrite step preserves denotation. -/
theorem tensorRewrite_sound
    (env : TensorEnv R ι)
    {s : TensorSort} {t u : TensorTerm s}
    (h : TensorRewrite t u) : sortEq env s t u := by
  cases h with
  | mulVec_vecAdd A v w => exact sound_mulVec_vecAdd env A v w
  | matAdd_mulVec A B v => exact sound_matAdd_mulVec env A B v
  | smulMat_mulVec a A v => exact sound_smulMat_mulVec env a A v
  | smulVec_vecAdd a v w => exact sound_smulVec_vecAdd env a v w
  | smulMat_matAdd a A B => exact sound_smulMat_matAdd env a A B
  | dot_vecAdd_left v w u => exact sound_dot_vecAdd_left env v w u
  | dot_vecAdd_right u v w => exact sound_dot_vecAdd_right env u v w
  | dot_smulVec_left a v w => exact sound_dot_smulVec_left env a v w

/-- **Theorem 2 (Multi-Step Soundness).**
Multi-step rewriting preserves sort-indexed semantics. -/
theorem sortEq_of_reflTransGen
    (env : TensorEnv R ι)
    {s : TensorSort} {t u : TensorTerm s}
    (h : Relation.ReflTransGen (fun a b => @TensorRewrite s a b) t u) :
    sortEq env s t u := by
  induction h with
  | refl => cases s <;> simp [sortEq]
  | tail _ hbc ih =>
    have h2 := tensorRewrite_sound env hbc
    cases s <;> simp only [sortEq] at * <;> exact ih.trans h2

/-- Multi-step rewriting preserves scalar evaluation. -/
theorem tensorRewrites_sound_scal (env : TensorEnv R ι)
    {t u : TensorTerm .scal}
    (h : Relation.ReflTransGen (fun a b => @TensorRewrite .scal a b) t u) :
    evalScal env t = evalScal env u :=
  sortEq_of_reflTransGen env h

/-- Multi-step rewriting preserves vector evaluation. -/
theorem tensorRewrites_sound_vec (env : TensorEnv R ι)
    {t u : TensorTerm .vec}
    (h : Relation.ReflTransGen (fun a b => @TensorRewrite .vec a b) t u) :
    evalVec env t = evalVec env u :=
  sortEq_of_reflTransGen env h

/-- Multi-step rewriting preserves matrix evaluation. -/
theorem tensorRewrites_sound_mat (env : TensorEnv R ι)
    {t u : TensorTerm .mat}
    (h : Relation.ReflTransGen (fun a b => @TensorRewrite .mat a b) t u) :
    evalMat env t = evalMat env u :=
  sortEq_of_reflTransGen env h

/-- **Theorem 3 (Energy Invariance under Rewrites).**
Independent normalization of vector and matrix subexpressions
preserves the quadratic energy functional. -/
theorem energy_invariant_of_rewrites
    (env : TensorEnv R ι)
    {v v' : TensorTerm .vec} {A A' : TensorTerm .mat}
    (hv : Relation.ReflTransGen (fun a b => @TensorRewrite .vec a b) v v')
    (hA : Relation.ReflTransGen (fun a b => @TensorRewrite .mat a b) A A') :
    energy (evalMat env A) (evalVec env v) =
    energy (evalMat env A') (evalVec env v') := by
  rw [tensorRewrites_sound_vec env hv, tensorRewrites_sound_mat env hA]

/-! ## Part 7: Energy Expansion Theorems -/

/-- **Theorem 4 (Energy Expansion / Polarization).**
`E(A, v+w) = E(A,v) + ⟨v,Aw⟩ + ⟨w,Av⟩ + E(A,w)`. -/
theorem energy_add (A : Matrix ι ι R) (v w : ι → R) :
    energy A (v + w) =
      energy A v + dotProd v (Matrix.mulVec A w) +
      dotProd w (Matrix.mulVec A v) + energy A w := by
  unfold energy
  rw [Matrix.mulVec_add, dotProd_add_left, dotProd_add_right, dotProd_add_right]
  abel

/-- **Theorem 5 (Symmetric Energy Expansion).**
When `Aᵀ = A`, the cross terms collapse:
`E(A, v+w) = E(A,v) + (⟨v,Aw⟩ + ⟨v,Aw⟩) + E(A,w)`. -/
theorem energy_add_of_symmetric (A : Matrix ι ι R) (hA : Aᵀ = A)
    (v w : ι → R) :
    energy A (v + w) =
      energy A v + (dotProd v (Matrix.mulVec A w) +
        dotProd v (Matrix.mulVec A w)) + energy A w := by
  rw [energy_add, ← dotProd_comm_of_symmetric A v w hA]
  abel

/-! ## Part 8: Verified Normalization -/

/-- One-step top-level normalization. -/
def normStep : {s : TensorSort} → TensorTerm s → TensorTerm s
  | _, .mulVec A (.vecAdd v w) => .vecAdd (.mulVec A v) (.mulVec A w)
  | _, .mulVec (.matAdd A B) v => .vecAdd (.mulVec A v) (.mulVec B v)
  | _, .mulVec (.smulMat a A) v => .smulVec a (.mulVec A v)
  | _, .smulVec a (.vecAdd v w) => .vecAdd (.smulVec a v) (.smulVec a w)
  | _, .smulMat a (.matAdd A B) => .matAdd (.smulMat a A) (.smulMat a B)
  | _, .dot (.vecAdd v w) u => .scalAdd (.dot v u) (.dot w u)
  | _, .dot u (.vecAdd v w) => .scalAdd (.dot u v) (.dot u w)
  | _, .dot (.smulVec a v) w => .scalMul a (.dot v w)
  | _, t => t

theorem normStep_sound_scal (env : TensorEnv R ι) (t : TensorTerm .scal) :
    evalScal env (normStep t) = evalScal env t := by
  by_cases h : ∃ v w u : TensorTerm TensorSort.vec, t = .dot v w <;> [ simp_all +decide; (
  rcases t with ( _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | t ) <;> simp +decide [ normStep ] at h ⊢;
  exact False.elim <| h.elim' ‹_›) ];
  rcases h with ⟨ ⟨ v ⟩, w, x, rfl ⟩;
  rcases w with ( _ | _ | _ | _ | _ | _ | w ) <;> rcases x with ( _ | _ | _ | _ | _ | _ | x ) <;> simp +decide [ normStep ];
  all_goals symm; apply_rules [ sound_dot_vecAdd_left, sound_dot_vecAdd_right, sound_dot_smulVec_left ] ;

theorem normStep_sound_vec (env : TensorEnv R ι) (t : TensorTerm .vec) :
    evalVec env (normStep t) = evalVec env t := by
  rcases t with ( _ | _ | _ | _ );
  · rfl;
  · rfl;
  · rename_i a v;
    cases v <;> simp +decide [ normStep ];
    rename_i v w;
    convert sound_smulVec_vecAdd env a v w |> Eq.symm using 1;
  · rename_i A v;
    rcases A with ( _ | _ | _ | _ ) <;> rcases v with ( _ | _ | _ | _ ) <;> try rfl;
    all_goals unfold normStep; simp +decide [ sound_mulVec_vecAdd, sound_matAdd_mulVec, sound_smulMat_mulVec, sound_smulVec_vecAdd ] ;

omit [DecidableEq ι] in
theorem normStep_sound_mat (env : TensorEnv R ι) (t : TensorTerm .mat) :
    evalMat env (normStep t) = evalMat env t := by
  rcases t with ( _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | t ) <;> simp +decide [ normStep ];
  rename_i a b;
  rcases b with ( _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | _ | b ) <;> simp +decide [];
  convert sound_smulMat_matAdd env a _ _ |> Eq.symm using 1

/-! ## Part 9: Term Weight -/

/-- Structural weight of a tensor term. -/
def tensorWeight : {s : TensorSort} → TensorTerm s → ℕ
  | _, .scalVar _    => 1
  | _, .vecVar _     => 1
  | _, .matVar _     => 1
  | _, .scalAdd a b  => 1 + tensorWeight a + tensorWeight b
  | _, .scalMul a b  => 1 + tensorWeight a + tensorWeight b
  | _, .vecAdd v w   => 1 + tensorWeight v + tensorWeight w
  | _, .matAdd A B   => 1 + tensorWeight A + tensorWeight B
  | _, .smulVec a v  => 1 + tensorWeight a + tensorWeight v
  | _, .smulMat a A  => 1 + tensorWeight a + tensorWeight A
  | _, .mulVec A v   => 1 + tensorWeight A + tensorWeight v
  | _, .dot v w      => 1 + tensorWeight v + tensorWeight w

end TensorRewriteSystem