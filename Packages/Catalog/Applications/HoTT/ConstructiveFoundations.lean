/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Constructive Foundations from Homotopy Type Theory

A *self-contained* fragment of Homotopy Type Theory, developed inside Lean 4
**without** relying on Lean's `Eq` (which has definitional proof irrelevance and
therefore validates UIP, making genuine HoTT impossible).  Instead we introduce
a synthetic Martin-Löf identity type `Path`, valued in `Type`, eliminated only
by path induction (`Path.rec`).  Because `Path` is an *indexed inductive in
`Type`*, axiom K / UIP is **not** derivable for it, so it genuinely models the
homotopical identity type.

The load-bearing results of this file are:

* `equiv_iff_contr_fibers` — the coincidence of the two notions of equivalence:
  a map has a quasi-inverse iff all of its fibers are contractible.
* `fundamental_theorem_id` — the (full biconditional) Fundamental Theorem of
  Identity Types: a fibrewise family `f : ∀ x, Path a x → C x` is a fibrewise
  equivalence iff the total space `Σ x, C x` is contractible.
* `equivalence_induction` — the equivalence-induction principle unlocked by a
  `Univalence` hypothesis: to prove a property of every equivalence out of `A`
  it suffices to prove it of the identity equivalence.
* `PTrunc` / `PTrunc.rec` / `PTrunc.rec_unique` — propositional truncation, a
  genuine higher inductive type (the `(-1)`-truncation) realized as a quotient,
  with its recursion principle and uniqueness.

The development is deliberately library-free (no `import Mathlib`): every result
is proved from the synthetic path calculus.
-/

namespace ConstructiveFoundations

universe u v w v2 z vv

/-! ## The synthetic identity type and its groupoid structure -/

/-- Synthetic Martin-Löf identity type, valued in `Type` (not `Prop`), so that
Lean's definitional proof irrelevance does not collapse it.  Path induction is
the recursor `Path.rec`; UIP is **not** provable. -/
inductive Path {A : Type u} : A → A → Type u where
  | refl (a : A) : Path a a

/-- Path reversal (symmetry of the groupoid). -/
def Path.symm {A : Type u} {a b : A} : Path a b → Path b a
  | .refl _ => .refl _

/-- Path concatenation (composition in the groupoid). -/
def Path.trans {A : Type u} {a b c : A} : Path a b → Path b c → Path a c
  | .refl _, q => q

/-- Action on paths (functoriality): a function sends paths to paths. -/
def ap {A : Type u} {B : Type v} (f : A → B) {a b : A} : Path a b → Path (f a) (f b)
  | .refl _ => .refl _

/-- Transport along a path in a type family. -/
def transport {A : Type u} (P : A → Type v) {a b : A} : Path a b → P a → P b
  | .refl _, x => x

-- !-- Lab Notebook: groupoid laws -- !--
-- !-- Hypothesis: refl/symm/trans/ap/transport satisfy the ∞-groupoid laws up to Path. -- !--
-- !-- Result: All proved by a single `cases` (path induction) collapsing to refl. -- !--
-- !-- Insight: Because `Path` is Type-valued, `cases p` IS the J-eliminator; it never -- !--
-- !--          uses K, so these are honest homotopical identities, not UIP artifacts. -- !--
-- !-- End Lab Notebook -- !--

/-- Left unit law `refl ⬝ p = p` holds *definitionally* by the recursion pattern. -/
theorem Path.trans_refl_left {A : Type u} {a b : A} (p : Path a b) :
    Path.trans (Path.refl a) p = p := rfl

/-- Right inverse law `p ⬝ p⁻¹ = refl`, by path induction.  Returns a `Path` (the
homotopical 2-cell), hence a `def` rather than a `theorem`. -/
def Path.trans_symm {A : Type u} {a b : A} (p : Path a b) :
    Path (Path.trans p (Path.symm p)) (Path.refl a) := by
  cases p; exact Path.refl _

/-- Right unit law `p ⬝ refl = p` (the left unit holds definitionally). -/
def Path.trans_refl_right {A : Type u} {a b : A} (p : Path a b) :
    Path (Path.trans p (Path.refl b)) p := by
  cases p; exact Path.refl _

/-- Functoriality of `ap` under composition. -/
def ap_comp {A : Type u} {B : Type v} {C : Type w} (g : B → C) (f : A → B)
    {a b : A} (p : Path a b) : Path (ap g (ap f p)) (ap (fun x => g (f x)) p) := by
  cases p; exact Path.refl _

/-- `ap` of the identity is the path itself. -/
def ap_id {A : Type u} {a b : A} (p : Path a b) : Path (ap (fun x => x) p) p := by
  cases p; exact Path.refl _

/-- Naturality of a homotopy `H : f ~ g`: the naturality square commutes. -/
def homotopy_natural {A : Type u} {B : Type v} {f g : A → B}
    (H : ∀ x, Path (f x) (g x)) {a b : A} (p : Path a b) :
    Path (Path.trans (H a) (ap g p)) (Path.trans (ap f p) (H b)) := by
  cases p; exact Path.trans_refl_right (H a)

/-- Associativity of path concatenation. -/
def Path.trans_assoc {A : Type u} {a b c d : A} (p : Path a b) (q : Path b c) (r : Path c d) :
    Path (Path.trans (Path.trans p q) r) (Path.trans p (Path.trans q r)) := by
  cases p; exact Path.refl _

/-- Left inverse law `p⁻¹ ⬝ p = refl`. -/
def Path.symm_trans {A : Type u} {a b : A} (e : Path a b) :
    Path (Path.trans (Path.symm e) e) (Path.refl b) := by
  cases e; exact Path.refl _

/-- Right cancellation for path concatenation. -/
def Path.cancel_right {A : Type u} {a b c : A} (p q : Path a b) (r : Path b c)
    (H : Path (Path.trans p r) (Path.trans q r)) : Path p q := by
  cases r
  exact Path.trans (Path.symm (Path.trans_refl_right p)) (Path.trans H (Path.trans_refl_right q))

/-- Naturality consequence: `η (g (f a)) = ap (g ∘ f) (η a)` for a retraction homotopy `η`.
This is the load-bearing cancellation used in adjointification. -/
def eta_natural {A : Type u} {B : Type v} (f : A → B) (g : B → A)
    (eta : ∀ a, Path (g (f a)) a) (a : A) :
    Path (eta (g (f a))) (ap (fun x => g (f x)) (eta a)) := by
  have N := homotopy_natural eta (eta a)
  have H : Path (Path.trans (eta (g (f a))) (eta a))
               (Path.trans (ap (fun x => g (f x)) (eta a)) (eta a)) :=
    transport (fun t => Path (Path.trans (eta (g (f a))) t)
        (Path.trans (ap (fun x => g (f x)) (eta a)) (eta a))) (ap_id (eta a)) N
  exact Path.cancel_right _ _ (eta a) H

/-- The adjoint triangle coherence produced by adjointification (HoTT 4.2.3): for the
corrected right homotopy `eps' b := (eps (f (g b)))⁻¹ ⬝ ap f (eta (g b)) ⬝ eps b`, the
triangle identity `eps' (f a) = ap f (eta a)` holds. -/
def adjoint_triangle {A : Type u} {B : Type v} (f : A → B) (g : B → A)
    (eta : ∀ a, Path (g (f a)) a) (eps : ∀ b, Path (f (g b)) b) (a : A) :
    Path
      (Path.trans (Path.trans (Path.symm (eps (f (g (f a))))) (ap f (eta (g (f a))))) (eps (f a)))
      (ap f (eta a)) :=
  let e := eps (f (g (f a)))
  have c1 : Path (ap f (eta (g (f a)))) (ap (fun x => f (g (f x))) (eta a)) :=
    Path.trans (ap (ap f) (eta_natural f g eta a)) (ap_comp f (fun x => g (f x)) (eta a))
  have w1 : Path (Path.trans (Path.trans (Path.symm e) (ap f (eta (g (f a))))) (eps (f a)))
                 (Path.trans (Path.trans (Path.symm e) (ap (fun x => f (g (f x))) (eta a))) (eps (f a))) :=
    ap (fun s => Path.trans (Path.trans (Path.symm e) s) (eps (f a))) c1
  have a1 : Path (Path.trans (Path.trans (Path.symm e) (ap (fun x => f (g (f x))) (eta a))) (eps (f a)))
                 (Path.trans (Path.symm e) (Path.trans (ap (fun x => f (g (f x))) (eta a)) (eps (f a)))) :=
    Path.trans_assoc (Path.symm e) (ap (fun x => f (g (f x))) (eta a)) (eps (f a))
  have Neps := homotopy_natural eps (ap f (eta a))
  have Neps1 : Path (Path.trans e (ap f (eta a)))
                  (Path.trans (ap (fun y => f (g y)) (ap f (eta a))) (eps (f a))) :=
    transport (fun t => Path (Path.trans e t)
        (Path.trans (ap (fun y => f (g y)) (ap f (eta a))) (eps (f a)))) (ap_id (ap f (eta a))) Neps
  have Neps2 : Path (Path.trans e (ap f (eta a)))
                  (Path.trans (ap (fun x => f (g (f x))) (eta a)) (eps (f a))) :=
    transport (fun t => Path (Path.trans e (ap f (eta a))) (Path.trans t (eps (f a))))
      (ap_comp (fun y => f (g y)) f (eta a)) Neps1
  have w2 : Path (Path.trans (Path.symm e) (Path.trans (ap (fun x => f (g (f x))) (eta a)) (eps (f a))))
                 (Path.trans (Path.symm e) (Path.trans e (ap f (eta a)))) :=
    ap (fun s => Path.trans (Path.symm e) s) (Path.symm Neps2)
  have a2 : Path (Path.trans (Path.symm e) (Path.trans e (ap f (eta a))))
                 (Path.trans (Path.trans (Path.symm e) e) (ap f (eta a))) :=
    Path.symm (Path.trans_assoc (Path.symm e) e (ap f (eta a)))
  have w3 : Path (Path.trans (Path.trans (Path.symm e) e) (ap f (eta a)))
                 (Path.trans (Path.refl (f (g (f a)))) (ap f (eta a))) :=
    ap (fun s => Path.trans s (ap f (eta a))) (Path.symm_trans e)
  Path.trans w1 (Path.trans a1 (Path.trans w2 (Path.trans a2 w3)))

/-! ## Contractibility, fibers, and the two notions of equivalence -/

/-- A type is contractible if it has a center to which everything is (path-)equal. -/
structure IsContr (A : Type u) where
  center : A
  contr : ∀ a, Path center a

/-- The (homotopy) fiber of `f` over `b`. -/
structure Fib {A : Type u} {B : Type v} (f : A → B) (b : B) where
  pt : A
  path : Path (f pt) b

/-- Path introduction for fibers (the `Σ`-path rule specialized to homotopy fibers):
a path of base points together with a commuting triangle yields a path of fibers. -/
def fib_eq {A : Type u} {B : Type v} {f : A → B} {b : B} {x x' : A}
    {p : Path (f x) b} {p' : Path (f x') b}
    (γ : Path x x') (comm : Path (Path.trans (ap f γ) p') p) :
    Path (Fib.mk x p) (Fib.mk x' p') := by
  cases γ; cases comm; exact Path.refl _

/-- *Equivalence* in the contractible-fibers sense: every fiber is contractible. -/
def IsEquiv {A : Type u} {B : Type v} (f : A → B) : Type (max u v) :=
  ∀ b, IsContr (Fib f b)

/-- A *quasi-inverse*: a two-sided inverse with homotopies (the "naive" notion). -/
structure QInv {A : Type u} {B : Type v} (f : A → B) where
  inv : B → A
  rightInv : ∀ b, Path (f (inv b)) b
  leftInv : ∀ a, Path (inv (f a)) a

/-- A *half-adjoint equivalence*: a quasi-inverse with one coherence (`tau`)
relating the two homotopies.  This is the well-behaved, propositional notion that
mediates between `QInv` and `IsEquiv`. -/
structure IsHAE {A : Type u} {B : Type v} (f : A → B) where
  g : B → A
  eta : ∀ a, Path (g (f a)) a
  eps : ∀ b, Path (f (g b)) b
  tau : ∀ a, Path (eps (f a)) (ap f (eta a))

/-- Logical equivalence of types (maps both ways); the type-level `Iff`. -/
def LogEquiv (X : Type u) (Y : Type v) : Type (max u v) := (X → Y) × (Y → X)

/-! ### Based path spaces are contractible -/

/-- A general dependent total space (`Σ`-type) over an arbitrary index type.
Used uniformly for fibers, based path spaces, and spaces of types. -/
structure Total {I : Type w} (P : I → Type v) : Type (max w v) where
  idx : I
  val : P idx

-- !-- Lab Notebook: singleton_contr -- !--
-- !-- Hypothesis: The based path space Σ x, (a = x) is contractible. -- !--
-- !-- Result: Proved by path induction on the second component. -- !--
-- !-- Insight: This is THE workhorse: contractibility of singletons is what powers -- !--
-- !--          equivalence induction and the fundamental theorem of identity types. -- !--
-- !-- End Lab Notebook -- !--

/-- The based path space `Σ x, Path a x` is contractible. -/
def singleton_contr {A : Type u} (a : A) :
    IsContr (Total (fun x : A => Path a x)) where
  center := ⟨a, Path.refl a⟩
  contr := fun z => by obtain ⟨x, p⟩ := z; cases p; exact Path.refl _

/-! ### Closure of contractibility and total maps -/

/-- A fibrewise family of maps induces a map of total spaces. -/
def totalMap {I : Type w} {P : I → Type v} {Q : I → Type v2}
    (g : ∀ X, P X → Q X) (s : Total P) : Total Q := ⟨s.idx, g s.idx s.val⟩

-- !-- Lab Notebook: totalMap_qinv / isContr_of_qinv -- !--
-- !-- Hypothesis: A fibrewise quasi-inverse lifts to a quasi-inverse of total maps; -- !--
-- !--             and quasi-inverses preserve contractibility. -- !--
-- !-- Result: Both proved by lifting homotopies through `ap (⟨X, ·⟩)` and trans. -- !--
-- !-- Insight: Only the EASY (fibrewise → total) direction is needed downstream; it -- !--          requires no coherence, just `ap` into the fixed-index slice. -- !--
-- !-- End Lab Notebook -- !--

/-- A fibrewise quasi-inverse lifts to a quasi-inverse of the total map. -/
def totalMap_qinv {I : Type w} {P : I → Type v} {Q : I → Type v2}
    (g : ∀ X, P X → Q X) (hg : ∀ X, QInv (g X)) : QInv (totalMap g) where
  inv := fun t => ⟨t.idx, (hg t.idx).inv t.val⟩
  rightInv := fun t => by
    obtain ⟨X, q⟩ := t
    exact ap (fun y => (⟨X, y⟩ : Total Q)) ((hg X).rightInv q)
  leftInv := fun s => by
    obtain ⟨X, p⟩ := s
    exact ap (fun y => (⟨X, y⟩ : Total P)) ((hg X).leftInv p)

/-- Quasi-inverses transport contractibility. -/
def isContr_of_qinv {A : Type u} {B : Type v} {f : A → B} (q : QInv f)
    (h : IsContr A) : IsContr B where
  center := f h.center
  contr := fun b => Path.trans (ap f (h.contr (q.inv b))) (q.rightInv b)

/-- Any map between contractible types is a quasi-inverse equivalence. -/
def qinv_between_contr {A : Type u} {B : Type v} (hA : IsContr A) (hB : IsContr B)
    (f : A → B) : QInv f where
  inv := fun _ => hA.center
  rightInv := fun b => Path.trans (Path.symm (hB.contr (f hA.center))) (hB.contr b)
  leftInv := fun a => hA.contr a

/-! ## Theorem 1: the two notions of equivalence coincide -/

-- !-- Lab Notebook: equiv_iff_contr_fibers -- !--
-- !-- Hypothesis: QInv f ↔ IsEquiv f (quasi-inverse iff contractible fibers). -- !--
-- !-- Result: Easy direction (IsEquiv → QInv) is direct; hard direction goes through -- !--          half-adjoint adjointification (qinv_to_ishae) then ishae_to_isEquiv. -- !--
-- !-- Insight: Contractible fibers make "being an equivalence" a proposition; the -- !--          single coherence `tau` of IsHAE is exactly what an arbitrary QInv lacks. -- !--
-- !-- Failure analysis: A direct QInv → contractible-fiber path could not be closed -- !--          without the adjoint coherence; IsHAE is the necessary intermediary. -- !--
-- !-- End Lab Notebook -- !--

/-- Easy direction: contractible fibers give a quasi-inverse. -/
def qinv_of_isEquiv {A : Type u} {B : Type v} (f : A → B) (e : IsEquiv f) : QInv f where
  inv := fun b => (e b).center.pt
  rightInv := fun b => (e b).center.path
  leftInv := fun a => ap Fib.pt ((e (f a)).contr ⟨a, Path.refl (f a)⟩)

-- !-- Proof sketch (qinv_to_ishae): Adjointify by keeping g, eta and replacing the right -- !--
-- !-- homotopy with eps' b := (eps (f (g b)))⁻¹ ⬝ ap f (eta (g b)) ⬝ eps b; the triangle -- !--
-- !-- coherence tau is `adjoint_triangle`, proved from eta-naturality + cancellation (4.2.3). -- !--
/-- Adjointification: a quasi-inverse can be upgraded to a half-adjoint equivalence. -/
def qinv_to_ishae {A : Type u} {B : Type v} {f : A → B} (q : QInv f) : IsHAE f where
  g := q.inv
  eta := q.leftInv
  eps := fun b =>
    Path.trans (Path.trans (Path.symm (q.rightInv (f (q.inv b))))
      (ap f (q.leftInv (q.inv b)))) (q.rightInv b)
  tau := fun a => adjoint_triangle f q.inv q.leftInv q.rightInv a

-- !-- Proof sketch (ishae_to_isEquiv): Fiber center is ⟨g b, eps b⟩.  Path-induct on the -- !--
-- !-- fiber's path so b := f a; then `fib_eq (eta a) _` closes it, the triangle being -- !--
-- !-- exactly `trans_refl_right` composed with `symm tau` (HoTT 4.2.4). -- !--
/-- A half-adjoint equivalence has contractible fibers. -/
def ishae_to_isEquiv {A : Type u} {B : Type v} {f : A → B} (h : IsHAE f) : IsEquiv f :=
  fun b =>
    { center := ⟨h.g b, h.eps b⟩
      contr := fun z => by
        obtain ⟨a, p⟩ := z
        cases p
        exact fib_eq (h.eta a)
          (Path.trans (Path.trans_refl_right (ap f (h.eta a))) (Path.symm (h.tau a))) }

/-- Hard direction (via adjointification): a quasi-inverse has contractible fibers. -/
def isEquiv_of_qinv {A : Type u} {B : Type v} (f : A → B) (q : QInv f) : IsEquiv f :=
  ishae_to_isEquiv (qinv_to_ishae q)

/-- **The two notions of equivalence coincide.**  A map has a quasi-inverse iff all
its fibers are contractible. -/
def equiv_iff_contr_fibers {A : Type u} {B : Type v} (f : A → B) :
    LogEquiv (QInv f) (IsEquiv f) :=
  ⟨isEquiv_of_qinv f, qinv_of_isEquiv f⟩

/-! ### Total equivalence implies fibrewise equivalence (HoTT 4.7.7, one direction) -/

-- !-- Lab Notebook: fibrewise_of_total -- !--
-- !-- Hypothesis: If the total map `totalMap g` is an equivalence then each `g x` is. -- !--
-- !-- Result: Each fiber `Fib (g x) c` is a RETRACT of `Fib (totalMap g) ⟨x,c⟩`, and -- !--          retracts of contractible types are contractible. -- !--
-- !-- Insight: The retraction needs only ONE homotopy (ψ∘φ ~ id), which collapses to -- !--          `refl` after path-inducting on the fiber's path; the dependent Σ-path is -- !--          handled by `idxPath`/`valPath`/`transport_natural`. -- !--
-- !-- Failure analysis: A full fibrewise equivalence is unnecessary and would force the -- !--          harder φ∘ψ homotopy; the retract suffices because we only need contractibility. -- !--
-- !-- End Lab Notebook -- !--

/-- Contractibility is inherited by retracts. -/
def isContr_of_retract {X : Type u} {Y : Type v} (s : X → Y) (r : Y → X)
    (ret : ∀ x, Path (r (s x)) x) (hY : IsContr Y) : IsContr X where
  center := r hY.center
  contr := fun x => Path.trans (ap r (hY.contr (s x))) (ret x)

/-- The index component of a path in a total space. -/
def idxPath {I : Type w} {P : I → Type v} {s t : Total P} (e : Path s t) :
    Path s.idx t.idx := ap Total.idx e

/-- The (dependent) value component of a path in a total space. -/
def valPath {I : Type w} {P : I → Type v} {s t : Total P} (e : Path s t) :
    Path (transport P (idxPath e) s.val) t.val := by cases e; exact Path.refl _

/-- A fibrewise map commutes with transport. -/
def transport_natural {I : Type w} {P : I → Type v} {Q : I → Type v2}
    (g : ∀ X, P X → Q X) {i x : I} (idxp : Path i x) (v : P i) :
    Path (g x (transport P idxp v)) (transport Q idxp (g i v)) := by
  cases idxp; exact Path.refl _

/-- Inclusion of a fiber of `g x` into the corresponding fiber of `totalMap g`. -/
def fibInto {I : Type w} {P : I → Type v} {Q : I → Type v2}
    (g : ∀ X, P X → Q X) (x : I) (c : Q x) (z : Fib (g x) c) :
    Fib (totalMap g) (Total.mk x c) :=
  ⟨⟨x, z.pt⟩, ap (fun w => (⟨x, w⟩ : Total Q)) z.path⟩

/-- Retraction of a fiber of `totalMap g` back to a fiber of `g x`. -/
def fibBack {I : Type w} {P : I → Type v} {Q : I → Type v2}
    (g : ∀ X, P X → Q X) (x : I) (c : Q x) (z : Fib (totalMap g) (Total.mk x c)) :
    Fib (g x) c :=
  ⟨transport P (idxPath z.path) z.pt.val,
    Path.trans (transport_natural g (idxPath z.path) z.pt.val) (valPath z.path)⟩

/-- `fibBack` is a retraction of `fibInto`. -/
def fib_retract {I : Type w} {P : I → Type v} {Q : I → Type v2}
    (g : ∀ X, P X → Q X) (x : I) (c : Q x) (z : Fib (g x) c) :
    Path (fibBack g x c (fibInto g x c z)) z := by
  obtain ⟨v, p⟩ := z; cases p; exact Path.refl _

/-- **Total equivalence implies fibrewise equivalence.**  If `totalMap g` has a
quasi-inverse, then every component `g x` is an equivalence. -/
def fibrewise_of_total {I : Type w} {P : I → Type v} {Q : I → Type v2}
    (g : ∀ X, P X → Q X) (hg : QInv (totalMap g)) : ∀ x, IsEquiv (g x) :=
  fun x c =>
    isContr_of_retract (fibInto g x c) (fibBack g x c) (fib_retract g x c)
      (isEquiv_of_qinv (totalMap g) hg (Total.mk x c))

/-! ## Theorem 2: the Fundamental Theorem of Identity Types -/

-- !-- Lab Notebook: fundamental_theorem_id -- !--
-- !-- Hypothesis: For f : ∀ x, Path a x → C x, (∀ x, IsEquiv (f x)) ↔ IsContr (Σ x, C x). -- !--
-- !-- Result: Forward direction is clean from singleton_contr + totalMap_qinv + -- !--          isContr_of_qinv. Backward direction manufactures the equivalences from a -- !--          single contractibility witness (encode-decode engine). -- !--
-- !-- Insight: The total space of f is Σ x, C x; over the contractible Σ x, Path a x it -- !--          is contractible iff f is a fibrewise equivalence. -- !--
-- !-- End Lab Notebook -- !--

/-- Forward direction: a fibrewise equivalence makes the total space contractible. -/
def ftid_forward {A : Type u} (a : A) (C : A → Type v)
    (f : ∀ x, Path a x → C x) (hf : ∀ x, IsEquiv (f x)) :
    IsContr (Total C) :=
  isContr_of_qinv (totalMap_qinv f (fun x => qinv_of_isEquiv (f x) (hf x)))
    (singleton_contr a)

-- !-- Proof sketch (ftid_backward) -- !--
-- totalMap f : Σ x, Path a x → Σ x, C x is a map between contractible spaces, hence a
-- quasi-inverse (qinv_between_contr).  Transferring fibrewise (total equivalence →
-- fibrewise equivalence, the converse of totalMap_qinv) gives each f x its inverse,
-- whence IsEquiv (f x) by isEquiv_of_qinv.
-- !-- End sketch -- !--
/-- Backward direction: contractibility of the total space forces fibrewise
equivalence.  `totalMap f` maps the contractible based-path space to the contractible
total space, hence is a quasi-inverse; `fibrewise_of_total` then transfers. -/
def ftid_backward {A : Type u} (a : A) (C : A → Type v)
    (f : ∀ x, Path a x → C x) (hc : IsContr (Total C)) :
    ∀ x, IsEquiv (f x) :=
  fibrewise_of_total f (qinv_between_contr (singleton_contr a) hc (totalMap f))

/-- **The Fundamental Theorem of Identity Types** (full biconditional). -/
def fundamental_theorem_id {A : Type u} (a : A) (C : A → Type v)
    (f : ∀ x, Path a x → C x) :
    LogEquiv (∀ x, IsEquiv (f x)) (IsContr (Total C)) :=
  ⟨ftid_forward a C f, ftid_backward a C f⟩

/-! ## Theorem 3: equivalence induction from univalence -/

/-- Homotopy equivalence of types, packaged as a map with a quasi-inverse. -/
structure HEquiv (A B : Type u) where
  toFun : A → B
  isEq : QInv toFun

/-- The identity equivalence. -/
def idEquiv (A : Type u) : HEquiv A A := ⟨id, ⟨id, Path.refl, Path.refl⟩⟩

/-- Coercion of a path of types into an equivalence (by transport). -/
def idToEquiv {A B : Type u} (p : Path A B) : HEquiv A B :=
  transport (fun X => HEquiv A X) p (idEquiv A)

/-- The **univalence** hypothesis: `idToEquiv` is a (fibrewise) quasi-equivalence,
i.e. it has an inverse `toId` with both homotopies. -/
structure Univalence.{zz} where
  toId : ∀ {A B : Type zz}, HEquiv A B → Path A B
  rightInv : ∀ {A B : Type zz} (e : HEquiv A B), Path (idToEquiv (toId e)) e
  leftInv : ∀ {A B : Type zz} (p : Path A B), Path (toId (idToEquiv p)) p

-- !-- Lab Notebook: equivalence_induction -- !--
-- !-- Hypothesis: Univalence makes the space of equivalences out of A contractible, -- !--             yielding an induction principle based at the identity equivalence. -- !--
-- !-- Result: equivSpace_contr transfers singleton_contr_types across idToEquiv; then -- !--          transport along the contraction discharges the induction. -- !--
-- !-- Insight: The base case lands DEFINITIONALLY on the center ⟨A, idEquiv A⟩ because -- !--          idToEquiv refl = idEquiv A reduces, so `transport ... base` typechecks. -- !--
-- !-- End Lab Notebook -- !--

/-- The space of types equipped with a path from `A` is contractible. -/
def singleton_contr_types {A : Type z} :
    IsContr (Total (fun B : Type z => Path A B)) where
  center := ⟨A, Path.refl A⟩
  contr := fun zz => by obtain ⟨B, p⟩ := zz; cases p; exact Path.refl _

/-- Under univalence, the space of equivalences out of `A` is contractible. -/
def equivSpace_contr (uv : Univalence.{z}) (A : Type z) :
    IsContr (Total (fun B : Type z => HEquiv A B)) :=
  isContr_of_qinv
    (totalMap_qinv (fun X => @idToEquiv A X)
      (fun _ => ⟨uv.toId, uv.rightInv, uv.leftInv⟩))
    singleton_contr_types

/-- **Equivalence induction.**  Under univalence, to prove a property `P B e` of every
equivalence `e : A ≃ B` it suffices to prove it of the identity equivalence. -/
def equivalence_induction (uv : Univalence.{z}) {A : Type z}
    (P : ∀ B, HEquiv A B → Type vv) (base : P A (idEquiv A)) :
    ∀ B (e : HEquiv A B), P B e :=
  fun B e =>
    transport (fun s : Total (fun B : Type z => HEquiv A B) => P s.idx s.val)
      ((equivSpace_contr uv A).contr ⟨B, e⟩) base

/-! ## Theorem 4: propositional truncation as a higher inductive type -/

-- !-- Lab Notebook: PTrunc -- !--
-- !-- Hypothesis: The (-1)-truncation ‖A‖ is the quotient of A by the total relation; -- !--             it is a mere proposition with the universal recursion principle. -- !--
-- !-- Result: PTrunc.is_prop (all elements equal), PTrunc.rec into any subsingleton, -- !--          PTrunc.rec_beta (computation) and PTrunc.rec_unique (uniqueness). -- !--
-- !-- Insight: Quot by `fun _ _ => True` IS propositional truncation; Quot.sound gives -- !--          the path constructor and Quot.lift the recursor, with the round-trip free. -- !--
-- !-- Failure analysis: Using synthetic `Path` here is unnecessary — a (-1)-type is an -- !--          h-prop, so Lean's `Eq` (which is proof-irrelevant) is exactly correct. -- !--
-- !-- End Lab Notebook -- !--

/-- Propositional truncation `‖A‖₋₁`, the `(-1)`-truncation, realized as the quotient
of `A` by the always-true relation. -/
def PTrunc (A : Type u) : Type u := Quot (fun (_ _ : A) => True)

/-- The point constructor `|a| : ‖A‖`. -/
def PTrunc.mk {A : Type u} (a : A) : PTrunc A := Quot.mk _ a

/-- `‖A‖` is a mere proposition: any two elements are equal (the path constructor). -/
theorem PTrunc.is_prop {A : Type u} (x y : PTrunc A) : x = y := by
  induction x using Quot.ind with | _ a =>
  induction y using Quot.ind with | _ b =>
  exact Quot.sound trivial

/-- The recursion principle: to map `‖A‖ → B` it suffices to give `A → B` with `B`
a mere proposition (a subsingleton). -/
def PTrunc.rec {A : Type u} {B : Type v} (hB : ∀ x y : B, x = y) (f : A → B) :
    PTrunc A → B :=
  Quot.lift f (fun a b _ => hB (f a) (f b))

/-- Computation (β) rule for the recursor. -/
theorem PTrunc.rec_beta {A : Type u} {B : Type v} (hB : ∀ x y : B, x = y) (f : A → B)
    (a : A) : PTrunc.rec hB f (PTrunc.mk a) = f a := rfl

/-- Uniqueness of the recursor: any map agreeing with `f` on points equals `PTrunc.rec`. -/
theorem PTrunc.rec_unique {A : Type u} {B : Type v} (hB : ∀ x y : B, x = y) (f : A → B)
    (g : PTrunc A → B) (hg : ∀ a, g (PTrunc.mk a) = f a) :
    ∀ t, g t = PTrunc.rec hB f t := by
  intro t
  induction t using Quot.ind with | _ a => exact hg a

end ConstructiveFoundations