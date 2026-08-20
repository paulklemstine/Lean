import Catalog.Shared.ImmuneAstCore

/-!
# Algorithmic Immune System, Part II: semantics, effects and self-execution

We equip the parasite calculus of Part I with a *total* denotational semantics
consisting of two layers:

* `PAst.eval t x` — the value computed by `t` when its input register holds `x`;
* `PAst.effect t x` — whether running `t` on input `x` *executes the forbidden
  action* `attack` (only the branch actually taken counts, so dead code is truly
  dead).

The runtime is *self-referential*: a program is always run on its own
attestation tag (`PAst.run t = PAst.effect t (PAst.code t)`), which is exactly
the ability of real self-modifying code to inspect its own source.  A program is
`malicious` when its self-execution performs the forbidden action.

Main results:

* `PAst.eval_const_of_inpFree` / `PAst.effect_const_of_inpFree`: programs without
  the self register are input-oblivious;
* `PAst.staticScan_correct`: the naive static scanner
  `staticScan t = effect t 0` is **sound and complete** on self-reference-free
  programs — the immune system wins outright in the absence of quining;
* `PAst.malicious_decidable_of_inpFree`: consequently maliciousness is decidable
  there.

Part III shows that both properties fail, unavoidably, once the self register is
available.
-/

namespace ImmuneSystem
namespace PAst

/-- Value semantics.  `x` is the content of the input (self) register. -/
def eval : PAst → ℕ → ℕ
  | inp, x => x
  | attack, _ => 1
  | lit n, _ => n
  | ite c a b, x => if eval c x ≠ 0 then eval a x else eval b x
  | call f a, x => eval f (eval a x)

/-- Effect semantics: `true` iff the forbidden action `attack` is actually
executed.  Only the branch that is really taken contributes. -/
def effect : PAst → ℕ → Bool
  | inp, _ => false
  | attack, _ => true
  | lit _, _ => false
  | ite c a b, x => effect c x || (if eval c x ≠ 0 then effect a x else effect b x)
  | call f a, x => effect a x || effect f (eval a x)

@[simp] theorem eval_inp (x : ℕ) : eval inp x = x := rfl
@[simp] theorem eval_attack (x : ℕ) : eval attack x = 1 := rfl
@[simp] theorem eval_lit (n x : ℕ) : eval (lit n) x = n := rfl
@[simp] theorem eval_ite (c a b : PAst) (x : ℕ) :
    eval (ite c a b) x = if eval c x ≠ 0 then eval a x else eval b x := rfl
@[simp] theorem eval_call (f a : PAst) (x : ℕ) : eval (call f a) x = eval f (eval a x) := rfl

@[simp] theorem effect_inp (x : ℕ) : effect inp x = false := rfl
@[simp] theorem effect_attack (x : ℕ) : effect attack x = true := rfl
@[simp] theorem effect_lit (n x : ℕ) : effect (lit n) x = false := rfl
@[simp] theorem effect_ite (c a b : PAst) (x : ℕ) :
    effect (ite c a b) x = (effect c x || (if eval c x ≠ 0 then effect a x else effect b x)) :=
  rfl
@[simp] theorem effect_call (f a : PAst) (x : ℕ) :
    effect (call f a) x = (effect a x || effect f (eval a x)) := rfl

/-- Self-execution: the runtime feeds a program its own attestation tag. -/
def run (t : PAst) : Bool := effect t (code t)

/-- A program is *malicious* when its self-execution performs the forbidden
action.  This is a purely behavioural (semantic) notion. -/
def malicious (t : PAst) : Prop := run t = true

instance : DecidablePred malicious := fun t => by
  unfold malicious; infer_instance

theorem malicious_iff (t : PAst) : malicious t ↔ effect t (code t) = true := Iff.rfl

/-- A program is *self-reference free* if it never reads the input register. -/
def inpFree : PAst → Bool
  | inp => false
  | attack => true
  | lit _ => true
  | ite c a b => inpFree c && inpFree a && inpFree b
  | call f a => inpFree f && inpFree a

@[simp] theorem inpFree_inp : inpFree inp = false := rfl
@[simp] theorem inpFree_attack : inpFree attack = true := rfl
@[simp] theorem inpFree_lit (n : ℕ) : inpFree (lit n) = true := rfl
@[simp] theorem inpFree_ite (c a b : PAst) :
    inpFree (ite c a b) = (inpFree c && inpFree a && inpFree b) := rfl
@[simp] theorem inpFree_call (f a : PAst) :
    inpFree (call f a) = (inpFree f && inpFree a) := rfl

/-- Self-reference-free programs compute a constant: their value does not depend
on the input register. -/
theorem eval_const_of_inpFree :
    ∀ {t : PAst}, inpFree t = true → ∀ x y : ℕ, eval t x = eval t y := by
  intro t
  induction t with
  | inp => intro h; simp at h
  | attack => intro _ x y; rfl
  | lit n => intro _ x y; rfl
  | ite c a b ihc iha ihb =>
      intro h x y
      simp only [inpFree_ite, Bool.and_eq_true] at h
      obtain ⟨⟨hc, ha⟩, hb⟩ := h
      simp only [eval_ite, ihc hc x y, iha ha x y, ihb hb x y]
  | call f a ihf iha =>
      intro h x y
      simp only [inpFree_call, Bool.and_eq_true] at h
      obtain ⟨hf, ha⟩ := h
      simp only [eval_call, iha ha x y]

/-- Self-reference-free programs have an input-independent effect. -/
theorem effect_const_of_inpFree :
    ∀ {t : PAst}, inpFree t = true → ∀ x y : ℕ, effect t x = effect t y := by
  intro t
  induction t with
  | inp => intro h; simp at h
  | attack => intro _ x y; rfl
  | lit n => intro _ x y; rfl
  | ite c a b ihc iha ihb =>
      intro h x y
      simp only [inpFree_ite, Bool.and_eq_true] at h
      obtain ⟨⟨hc, ha⟩, hb⟩ := h
      simp only [effect_ite, ihc hc x y, iha ha x y, ihb hb x y,
        eval_const_of_inpFree hc x y]
  | call f a ihf iha =>
      intro h x y
      simp only [inpFree_call, Bool.and_eq_true] at h
      obtain ⟨hf, ha⟩ := h
      simp only [effect_call, iha ha x y, eval_const_of_inpFree ha x y]


/-! ### A benign padding family

`pad` is an exponentially large family of *semantically identical* benign
programs (all compute `0`, none has any effect).  It is the raw material both for
the immune-escape counting theorem of Part III and for the false-positive
counting theorem of Part IV. -/

/-- `pad l` is a chunk of dead code encoding the bit list `l`.  Every `pad l`
evaluates to `0` and is effect-free, yet distinct `l` give distinct ASTs. -/
def pad : List Bool → PAst
  | [] => lit 0
  | b :: bs => ite (lit 0) (lit (if b then 1 else 0)) (pad bs)

@[simp] theorem eval_pad (l : List Bool) (x : ℕ) : eval (pad l) x = 0 := by
  induction l with
  | nil => rfl
  | cons b bs ih => simp [pad, ih]

@[simp] theorem effect_pad (l : List Bool) (x : ℕ) : effect (pad l) x = false := by
  induction l with
  | nil => rfl
  | cons b bs ih => simp [pad, ih]

theorem size_pad (l : List Bool) : size (pad l) = 3 * l.length + 1 := by
  induction l with
  | nil => rfl
  | cons b bs ih => simp [pad, ih]; omega

theorem pad_injective : Function.Injective pad := by
  intro l
  induction l with
  | nil =>
      intro l' h
      cases l' with
      | nil => rfl
      | cons b bs => simp [pad] at h
  | cons b bs ih =>
      intro l' h
      cases l' with
      | nil => simp [pad] at h
      | cons b' bs' =>
          simp only [pad, PAst.ite.injEq, PAst.lit.injEq] at h
          obtain ⟨-, hb, hbs⟩ := h
          have : b = b' := by
            by_cases hb1 : b <;> by_cases hb2 : b' <;> simp [hb1, hb2] at hb ⊢
          rw [this, ih hbs]

/-- The naive static scanner of the immune system: symbolically execute the
program on the neutral input. -/
def staticScan (t : PAst) : Bool := effect t 0

/-- **The immune system wins on non-quining code.**  On self-reference-free
programs the static scanner is sound *and* complete for maliciousness. -/
theorem staticScan_correct {t : PAst} (h : inpFree t = true) : staticScan t = true ↔ malicious t := by
  unfold staticScan malicious run
  rw [effect_const_of_inpFree h 0 (code t)]

/-- Maliciousness restricted to self-reference-free programs is decidable, with
an explicitly computable decision procedure. -/
theorem malicious_decidable_of_inpFree {t : PAst} (h : inpFree t = true) :
    malicious t ↔ staticScan t = true := (staticScan_correct h).symm

end PAst
end ImmuneSystem