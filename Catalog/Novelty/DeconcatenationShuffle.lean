/-
# The deconcatenation coproduct and the shuffle bialgebra

This file completes the picture of `Novelty.FreeMonoidUnshuffle` by treating the *other*
of the two mutually dual bialgebra structures on `K⟨X⟩`:

* `(K⟨X⟩, concatenation, Δ_⧢)` — the graded noncommutative co-commutative bialgebra,
  handled in `Novelty.FreeMonoidUnshuffle` (`unsh_append`, `unsh_coassoc`);
* `(K⟨X⟩, ⧢, Δ_conc)` — the commutative, co-noncommutative bialgebra of this file,
  where `Δ_conc(w) = Σ_{w = z₁z₂} z₁ ⊗ z₂` is the deconcatenation coproduct.

The main theorem `deconc_bind_shuf` is the bialgebra axiom for the second structure:
deconcatenation is an algebra morphism for the shuffle product,

`Δ_conc(u ⧢ v) = Δ_conc(u) ⧢₂ Δ_conc(v)`,

where `⧢₂` is the shuffle product of the tensor square.  The proof is *by duality*: both
sides are computed coefficientwise, the coefficients are transported to the unshuffle
side through `count_shuf_eq_count_unsh`, and there they become the multiplicativity of
the unshuffle coproduct `unsh_append`, up to a purely combinatorial four-fold
transposition of counting sums (`quad_transpose`).
-/
import Novelty.FreeMonoidUnshuffle

namespace FreeMonoidShuffle

variable {X : Type*}

/-! ## Elementary counting lemmas -/

section CountingLemmas
variable {A B C D : Type*}

lemma sum_map_ite_count [DecidableEq A] (a : A) (s : Multiset A) :
    (s.map (fun z => if a = z then 1 else 0)).sum = Multiset.count a s := by
  induction s using Multiset.induction with
  | empty => simp
  | cons b s ih => simp [ih, Multiset.count_cons, add_comm]

lemma count_map_eq_sum_ite [DecidableEq A] [DecidableEq B] (b : B) (f : A → B)
    (s : Multiset A) :
    Multiset.count b (s.map f) = (s.map (fun a => if b = f a then 1 else 0)).sum := by
  induction s using Multiset.induction with
  | empty => simp
  | cons a s ih => simp [ih, Multiset.count_cons, add_comm]

lemma prodsum (U : Multiset A) (V : Multiset B) (f : A → ℕ) (g : B → ℕ) :
    (U.map f).sum * (V.map g).sum = (U.map (fun x => (V.map (fun y => f x * g y)).sum)).sum := by
  rw [← Multiset.sum_map_mul_right]
  exact congrArg Multiset.sum (Multiset.map_congr rfl fun x _ =>
    (Multiset.sum_map_mul_left).symm)

lemma swap2 (P : Multiset A) (Q : Multiset B) (f : A → B → ℕ) :
    (P.map (fun p => (Q.map (f p)).sum)).sum =
      (Q.map (fun q => (P.map (fun p => f p q)).sum)).sum :=
  Multiset.sum_map_sum_map P Q

/-- Transposition of a four-fold counting sum. -/
lemma swap4 (P : Multiset A) (Q : Multiset B) (R : Multiset C) (S : Multiset D)
    (T : A → B → C → D → ℕ) :
    (P.map (fun p => (Q.map (fun q =>
        (R.map (fun r => (S.map (fun s => T p q r s)).sum)).sum)).sum)).sum
      = (R.map (fun r => (S.map (fun s =>
        (P.map (fun p => (Q.map (fun q => T p q r s)).sum)).sum)).sum)).sum := by
  calc (P.map (fun p => (Q.map (fun q =>
          (R.map (fun r => (S.map (fun s => T p q r s)).sum)).sum)).sum)).sum
      = (P.map (fun p => (R.map (fun r =>
          (Q.map (fun q => (S.map (fun s => T p q r s)).sum)).sum)).sum)).sum :=
        congrArg Multiset.sum (Multiset.map_congr rfl fun p _ =>
          swap2 Q R (fun q r => (S.map (fun s => T p q r s)).sum))
    _ = (R.map (fun r => (P.map (fun p =>
          (Q.map (fun q => (S.map (fun s => T p q r s)).sum)).sum)).sum)).sum := swap2 P R _
    _ = (R.map (fun r => (P.map (fun p =>
          (S.map (fun s => (Q.map (fun q => T p q r s)).sum)).sum)).sum)).sum := by
        refine congrArg Multiset.sum (Multiset.map_congr rfl fun r _ => ?_)
        exact congrArg Multiset.sum (Multiset.map_congr rfl fun p _ =>
          swap2 Q S (fun q s => T p q r s))
    _ = (R.map (fun r => (S.map (fun s =>
          (P.map (fun p => (Q.map (fun q => T p q r s)).sum)).sum)).sum)).sum := by
        refine congrArg Multiset.sum (Multiset.map_congr rfl fun r _ => ?_)
        exact swap2 P S _

/-- The four-fold transposition identity for counting matched pairs. -/
theorem quad_transpose [DecidableEq A] [DecidableEq B] [DecidableEq C] [DecidableEq D]
    (P : Multiset (A × B)) (Q : Multiset (C × D))
    (R : Multiset (A × C)) (S : Multiset (B × D)) :
    (P.map (fun p => (Q.map (fun q =>
        Multiset.count (p.1, q.1) R * Multiset.count (p.2, q.2) S)).sum)).sum
      = (R.map (fun r => (S.map (fun s =>
        Multiset.count (r.1, s.1) P * Multiset.count (r.2, s.2) Q)).sum)).sum := by
  have hL : ∀ (p : A × B) (q : C × D),
      Multiset.count (p.1, q.1) R * Multiset.count (p.2, q.2) S
        = (R.map (fun r => (S.map (fun s =>
            (if (p.1, q.1) = r then 1 else 0) * (if (p.2, q.2) = s then 1 else 0))).sum)).sum := by
    intro p q
    rw [← sum_map_ite_count (p.1, q.1) R, ← sum_map_ite_count (p.2, q.2) S, prodsum]
  have hR : ∀ (r : A × C) (s : B × D),
      Multiset.count (r.1, s.1) P * Multiset.count (r.2, s.2) Q
        = (P.map (fun p => (Q.map (fun q =>
            (if (r.1, s.1) = p then 1 else 0) * (if (r.2, s.2) = q then 1 else 0))).sum)).sum := by
    intro r s
    rw [← sum_map_ite_count (r.1, s.1) P, ← sum_map_ite_count (r.2, s.2) Q, prodsum]
  have hT : ∀ (p : A × B) (q : C × D) (r : A × C) (s : B × D),
      (if (p.1, q.1) = r then 1 else 0) * (if (p.2, q.2) = s then 1 else 0)
        = (if (r.1, s.1) = p then 1 else 0) * ((if (r.2, s.2) = q then 1 else 0) : ℕ) := by
    rintro ⟨p1, p2⟩ ⟨q1, q2⟩ ⟨r1, r2⟩ ⟨s1, s2⟩
    simp only [Prod.mk.injEq]
    by_cases h1 : p1 = r1 <;> by_cases h2 : q1 = r2 <;> by_cases h3 : p2 = s1 <;>
      by_cases h4 : q2 = s2 <;> simp [h1, h2, h3, h4, eq_comm]
  calc (P.map (fun p => (Q.map (fun q =>
          Multiset.count (p.1, q.1) R * Multiset.count (p.2, q.2) S)).sum)).sum
      = (P.map (fun p => (Q.map (fun q => (R.map (fun r => (S.map (fun s =>
          (if (p.1, q.1) = r then 1 else 0) *
            (if (p.2, q.2) = s then 1 else 0))).sum)).sum)).sum)).sum :=
        congrArg Multiset.sum (Multiset.map_congr rfl fun p _ =>
          congrArg Multiset.sum (Multiset.map_congr rfl fun q _ => hL p q))
    _ = (R.map (fun r => (S.map (fun s => (P.map (fun p => (Q.map (fun q =>
          (if (p.1, q.1) = r then 1 else 0) *
            (if (p.2, q.2) = s then 1 else 0))).sum)).sum)).sum)).sum := swap4 _ _ _ _ _
    _ = (R.map (fun r => (S.map (fun s => (P.map (fun p => (Q.map (fun q =>
          (if (r.1, s.1) = p then 1 else 0) *
            (if (r.2, s.2) = q then 1 else 0))).sum)).sum)).sum)).sum :=
        congrArg Multiset.sum (Multiset.map_congr rfl fun r _ =>
          congrArg Multiset.sum (Multiset.map_congr rfl fun s _ =>
            congrArg Multiset.sum (Multiset.map_congr rfl fun p _ =>
              congrArg Multiset.sum (Multiset.map_congr rfl fun q _ => hT p q r s))))
    _ = (R.map (fun r => (S.map (fun s =>
          Multiset.count (r.1, s.1) P * Multiset.count (r.2, s.2) Q)).sum)).sum :=
        congrArg Multiset.sum (Multiset.map_congr rfl fun r _ =>
          congrArg Multiset.sum (Multiset.map_congr rfl fun s _ => (hR r s).symm))

end CountingLemmas

/-! ## The deconcatenation coproduct -/

/-- The deconcatenation coproduct `Δ_conc(w) = Σ_{w = z₁z₂} z₁ ⊗ z₂`. -/
def deconc : List X → Multiset (List X × List X)
  | [] => {([], [])}
  | a :: w => (([], a :: w) : List X × List X) ::ₘ ((deconc w).map (fun p => (a :: p.1, p.2)))

@[simp] lemma deconc_nil : deconc ([] : List X) = {([], [])} := rfl

lemma deconc_cons (a : X) (w : List X) :
    deconc (a :: w) =
      (([], a :: w) : List X × List X) ::ₘ ((deconc w).map (fun p => (a :: p.1, p.2))) := rfl

@[simp] lemma deconc_card (w : List X) : (deconc w).card = w.length + 1 := by
  induction w with
  | nil => simp
  | cons a w ih => simp [deconc_cons, ih]

/-- The coefficients of the deconcatenation coproduct: `(z₁, z₂)` occurs in `Δ_conc(z)`
exactly when `z = z₁ z₂`, and then with multiplicity one. -/
theorem count_deconc [DecidableEq X] (z1 z2 z : List X) :
    Multiset.count (z1, z2) (deconc z) = if z1 ++ z2 = z then 1 else 0 := by
  induction z generalizing z1 with
  | nil =>
    cases z1 with
    | nil => cases z2 <;> simp
    | cons b z1 => simp
  | cons a w ih =>
    rw [deconc_cons]
    cases z1 with
    | nil =>
      rw [Multiset.count_cons, count_map_consL_nil]
      by_cases h : z2 = a :: w <;> simp [h]
    | cons b z1 =>
      rw [Multiset.count_cons_of_ne (by simp), count_map_consL a b z1 z2 (deconc w)]
      by_cases h : a = b
      · subst h
        rw [if_pos rfl, ih z1]
        simp
      · rw [if_neg h, if_neg]
        rintro ⟨rfl, -⟩
        exact h rfl

/-! ## The shuffle product of the tensor square -/

/-- Shuffle product of two elementary tensors of words. -/
def shufPair (p q : List X × List X) : Multiset (List X × List X) :=
  (shuf p.1 q.1).bind (fun r => (shuf p.2 q.2).map (fun s => (r, s)))

/-- `Δ_conc(u) ⧢₂ Δ_conc(v)`, the shuffle product on the tensor square applied to the two
deconcatenation coproducts. -/
def deconcShufProd (u v : List X) : Multiset (List X × List X) :=
  (deconc u).bind (fun p => (deconc v).bind (fun q => shufPair p q))

lemma count_shufPair [DecidableEq X] (z1 z2 : List X) (p q : List X × List X) :
    Multiset.count (z1, z2) (shufPair p q)
      = Multiset.count z1 (shuf p.1 q.1) * Multiset.count z2 (shuf p.2 q.2) := by
  rw [shufPair, Multiset.count_bind]
  have hstep : ∀ r : List X,
      Multiset.count (z1, z2) ((shuf p.2 q.2).map (fun s => (r, s)))
        = (if z1 = r then 1 else 0) * Multiset.count z2 (shuf p.2 q.2) := by
    intro r
    induction (shuf p.2 q.2) using Multiset.induction with
    | empty => simp
    | cons b t ih =>
      simp only [Multiset.map_cons, Multiset.count_cons, ih, Multiset.count_cons]
      by_cases h : z1 = r <;> by_cases h2 : z2 = b <;>
        simp [h, h2, Prod.ext_iff, mul_add]
  rw [Multiset.map_congr rfl (fun r _ => hstep r), Multiset.sum_map_mul_right,
    sum_map_ite_count z1]

/-! ## The bialgebra axiom -/

/-- **Deconcatenation is an algebra morphism for the shuffle product.**  This is the
bialgebra axiom for the commutative, co-noncommutative bialgebra `(K⟨X⟩, ⧢, Δ_conc)`,
dual to the concatenation/unshuffle bialgebra. -/
theorem deconc_bind_shuf [DecidableEq X] (u v : List X) :
    (shuf u v).bind deconc = deconcShufProd u v := by
  ext z
  obtain ⟨z1, z2⟩ := z
  -- the left hand side counts the shuffles of `u` and `v` equal to `z₁z₂`
  have hleft : Multiset.count (z1, z2) ((shuf u v).bind deconc)
      = Multiset.count (u, v) (pairMul (unsh z1) (unsh z2)) := by
    rw [Multiset.count_bind,
      Multiset.map_congr rfl (fun z _ => count_deconc z1 z2 z)]
    have : (Multiset.map (fun z => if z1 ++ z2 = z then 1 else 0) (shuf u v)).sum
        = Multiset.count (z1 ++ z2) (shuf u v) := sum_map_ite_count _ _
    rw [this, count_shuf_eq_count_unsh, unsh_append]
  -- the right hand side is the same count, transposed
  have hright : Multiset.count (z1, z2) (deconcShufProd u v)
      = ((unsh z1).map (fun al => ((unsh z2).map (fun be =>
          Multiset.count (al.1, be.1) (deconc u) *
            Multiset.count (al.2, be.2) (deconc v))).sum)).sum := by
    rw [deconcShufProd, Multiset.count_bind]
    have hin : ∀ p : List X × List X,
        Multiset.count (z1, z2) ((deconc v).bind (fun q => shufPair p q))
          = ((deconc v).map (fun q =>
              Multiset.count (p.1, q.1) (unsh z1) * Multiset.count (p.2, q.2) (unsh z2))).sum := by
      intro p
      rw [Multiset.count_bind]
      refine congrArg Multiset.sum (Multiset.map_congr rfl fun q _ => ?_)
      rw [count_shufPair, count_shuf_eq_count_unsh, count_shuf_eq_count_unsh]
    rw [Multiset.map_congr rfl (fun p _ => hin p)]
    exact quad_transpose (deconc u) (deconc v) (unsh z1) (unsh z2)
  rw [hleft, hright, pairMul, Multiset.count_bind]
  refine congrArg Multiset.sum (Multiset.map_congr rfl fun al _ => ?_)
  rw [count_map_eq_sum_ite]
  refine congrArg Multiset.sum (Multiset.map_congr rfl fun be _ => ?_)
  rw [count_deconc, count_deconc]
  by_cases h1 : al.1 ++ be.1 = u <;> by_cases h2 : al.2 ++ be.2 = v <;>
    simp [h1, h2, Prod.ext_iff, eq_comm] <;> tauto

end FreeMonoidShuffle