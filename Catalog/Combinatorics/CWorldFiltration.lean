/-
# Clock-and-Switch Worlds and the Filtration Theorem for Finite Rooted Directed Posets

A **clock-and-switch world** over a clock type `A` and a switch type `B` is a pair
`⟨clock, switch⟩` with `clock : A` and `switch : B → Bool`, ordered by "the clock has
advanced and no switch has been turned off".  Concretely `CWorld (Fin n) (Fin m)` is the
product of the `n`-chain with the `m`-dimensional Boolean cube: `n` ticks of a clock and
`m` irreversible switches.

The file develops the theory of **bounded morphisms** (p-morphisms) out of these worlds
and proves the representation ("filtration") theorem they were built for.

## Main definitions

* `CWorld A B` — the clock-and-switch worlds, with their preorder (a partial order as
  soon as the clock type is one), their `Fintype` instance and the count
  `CWorld.card_eq : |CWorld (Fin n) (Fin m)| = n · 2 ^ m`.
* `BddMorphism X Y` — a bounded morphism: a `forth` (monotone) condition together with
  the `back` (lifting) condition `f x ≤ q → ∃ v ≥ x, f v = q`.
* `Representable P` — `P` is a surjective bounded morphic image of some
  `CWorld (Fin n) (Fin m)`.
* `walk t r tp s n` — the **greedy climb**: starting at the root `r`, process the
  switches `0, 1, …, n-1` of `s` in order, and when switch `l` is on move to the
  enumerated point `t l` if the current position is below it, and to the top `tp`
  otherwise.  This is the engine of the representation theorem.

## Main results

* `walk.mono`, `walk.congr_of_eq`, `walk.all_false`, `walk.open_step` — the four
  structural properties of the greedy climb.  `walk.open_step` is the substantial one:
  if the climb ends below an enumerated point `t j`, then **switching `j` on** makes it
  end exactly at `t j`.  This is precisely the `back` condition.
* `representable_of_rooted_directed` — **the filtration theorem.**  Every finite rooted
  directed partial order `P` is a surjective bounded morphic image of
  `CWorld (Fin 1) (Fin |P|)`: one clock tick and one switch per point suffice.
* `BddMorphism.antisymm_image` — a surjective bounded morphic image of a *finite partial
  order* is antisymmetric.  Hence antisymmetry cannot be dropped:
  `not_representable_cluster` shows the two-element cluster is not representable.
* `representable_iff` — **the characterisation.**  A finite nonempty preorder is
  representable iff it is rooted, directed and antisymmetric.
* `card_le_of_morphism` — the cardinality obstruction `|P| ≤ n · 2 ^ m`.
* `cardChain` / `cardChain_surjective` — the canonical morphism from the `m`-cube onto
  the `(m+1)`-chain (count the switches that are on); `forgetSwitches` — the projection
  onto the clock.

## Lab Notes (minimal switch counts, computed by hand from `card_le_of_morphism` and
the greedy climb)

| target poset | least `m` with `CWorld (Fin 1) (Fin m) ↠ P` |
|---|---|
| 3-chain | 2 |
| 4-chain | 3 |
| 5-chain | 4 |
| diamond `⊥ < a, b < ⊤` | 2 (cardinality bound `4 ≤ 2^m` already forces `m ≥ 2`) |

The chain entries are the content of `cardChain_optimal` in
`Combinatorics.CWorldFiltrationSharpness`; the diamond entry is the cardinality bound.
-/

import Mathlib

namespace CWorldFiltration

open Function

/-! ## Part A — Clock-and-switch worlds -/

/-- A **clock-and-switch world**: a clock reading in `A` together with an assignment of
Booleans to the switches `B`. -/
structure CWorld (A B : Type*) where
  /-- the clock reading -/
  clock : A
  /-- the state of each switch -/
  switch : B → Bool

namespace CWorld

variable {A B : Type*}

/-- Accessibility: the clock advances, and no switch is ever turned off. -/
instance instPreorder [Preorder A] : Preorder (CWorld A B) where
  le w v := w.clock ≤ v.clock ∧ ∀ b, w.switch b = true → v.switch b = true
  le_refl _ := ⟨le_rfl, fun _ h => h⟩
  le_trans _ _ _ h₁ h₂ := ⟨le_trans h₁.1 h₂.1, fun b hb => h₂.2 b (h₁.2 b hb)⟩

theorem le_def [Preorder A] {w v : CWorld A B} :
    w ≤ v ↔ w.clock ≤ v.clock ∧ ∀ b, w.switch b = true → v.switch b = true := Iff.rfl

instance instPartialOrder [PartialOrder A] : PartialOrder (CWorld A B) :=
  { instPreorder with
    le_antisymm := by
      rintro ⟨w1, w2⟩ ⟨v1, v2⟩ h₁ h₂
      have hc : w1 = v1 := le_antisymm h₁.1 h₂.1
      subst hc
      have hs : w2 = v2 := by
        funext b
        cases hw : w2 b <;> cases hv : v2 b
        · rfl
        · exact absurd (h₂.2 b hv) (by simp [hw])
        · exact absurd (h₁.2 b hw) (by simp [hv])
        · rfl
      simp [hs] }

/-- A clock-and-switch world is the same data as a clock reading plus a subset of the
switches. -/
def equivProd : CWorld A B ≃ A × (B → Bool) where
  toFun w := (w.clock, w.switch)
  invFun p := ⟨p.1, p.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

instance instFintype [Fintype A] [Fintype B] [DecidableEq B] : Fintype (CWorld A B) :=
  Fintype.ofEquiv _ equivProd.symm

theorem card_eq (n m : ℕ) : Fintype.card (CWorld (Fin n) (Fin m)) = n * 2 ^ m := by
  rw [Fintype.card_congr (equivProd (A := Fin n) (B := Fin m)), Fintype.card_prod]
  simp

/-- Clock-and-switch worlds are rooted: reset the clock and switch everything off. -/
theorem isRooted [Preorder A] [OrderBot A] : ∃ w₀ : CWorld A B, ∀ w, w₀ ≤ w :=
  ⟨⟨⊥, fun _ => false⟩, fun _ => ⟨bot_le, fun b hb => by simp at hb⟩⟩

/-- Clock-and-switch worlds are directed: advance the clock, take the union of the
switches. -/
theorem directed [SemilatticeSup A] (w v : CWorld A B) : ∃ u, w ≤ u ∧ v ≤ u :=
  ⟨⟨w.clock ⊔ v.clock, fun b => w.switch b || v.switch b⟩,
    ⟨le_sup_left, fun b hb => by simp [hb]⟩, ⟨le_sup_right, fun b hb => by simp [hb]⟩⟩

end CWorld

/-! ## Part B — Bounded morphisms -/

/-- A **bounded morphism** (p-morphism) of preorders: monotone (`forth`) and with the
lifting property (`back`). -/
structure BddMorphism (X Y : Type*) [Preorder X] [Preorder Y] where
  /-- the underlying map -/
  toFun : X → Y
  /-- monotonicity -/
  forth : ∀ ⦃x y : X⦄, x ≤ y → toFun x ≤ toFun y
  /-- every step downstairs is realised upstairs -/
  back : ∀ (x : X) (q : Y), toFun x ≤ q → ∃ v, x ≤ v ∧ toFun v = q

namespace BddMorphism

variable {X Y Z : Type*} [Preorder X] [Preorder Y] [Preorder Z]

/-- Bounded morphisms compose. -/
def comp (g : BddMorphism Y Z) (f : BddMorphism X Y) : BddMorphism X Z where
  toFun := g.toFun ∘ f.toFun
  forth _ _ h := g.forth (f.forth h)
  back x q h := by
    obtain ⟨y, hy, hyq⟩ := g.back (f.toFun x) q h
    obtain ⟨v, hv, hvy⟩ := f.back x y hy
    exact ⟨v, hv, by simp [Function.comp, hvy, hyq]⟩

/-- A surjective bounded morphic image of a rooted preorder is rooted. -/
theorem isRooted_image (f : BddMorphism X Y) (hf : Surjective f.toFun)
    (h : ∃ x₀ : X, ∀ x, x₀ ≤ x) : ∃ r : Y, ∀ q, r ≤ q := by
  obtain ⟨x₀, hx₀⟩ := h
  refine ⟨f.toFun x₀, fun q => ?_⟩
  obtain ⟨x, rfl⟩ := hf q
  exact f.forth (hx₀ x)

/-- A surjective bounded morphic image of a directed preorder is directed. -/
theorem directed_image (f : BddMorphism X Y) (hf : Surjective f.toFun)
    (h : ∀ x y : X, ∃ z, x ≤ z ∧ y ≤ z) : ∀ p q : Y, ∃ z, p ≤ z ∧ q ≤ z := by
  intro p q
  obtain ⟨x, rfl⟩ := hf p
  obtain ⟨y, rfl⟩ := hf q
  obtain ⟨z, hz₁, hz₂⟩ := h x y
  exact ⟨f.toFun z, f.forth hz₁, f.forth hz₂⟩

/-- Auxiliary form of `antisymm_image`, proved by well-founded induction upwards in the
finite source: a cluster downstairs would lift to an infinite strictly ascending chain
upstairs. -/
theorem eq_of_le_of_le_image {X Y : Type*} [PartialOrder X] [Finite X] [Preorder Y]
    (f : BddMorphism X Y) : ∀ a : X, ∀ q : Y, f.toFun a ≤ q → q ≤ f.toFun a →
      f.toFun a = q := by
  intro a
  induction a using WellFoundedGT.induction with
  | _ a ih =>
      intro q h1 h2
      obtain ⟨b, hab, hb⟩ := f.back a q h1
      rcases eq_or_ne b a with rfl | hne
      · exact hb
      · have hlt : a < b := lt_of_le_of_ne hab (Ne.symm hne)
        have := ih b hlt (f.toFun a) (by rw [hb]; exact h2) (by rw [hb]; exact h1)
        rw [hb] at this
        exact this.symm

/-- **Images of finite posets are antisymmetric.**  This is the obstruction that makes
antisymmetry unavoidable in `representable_iff`. -/
theorem antisymm_image {X Y : Type*} [PartialOrder X] [Finite X] [Preorder Y]
    (f : BddMorphism X Y) (hf : Surjective f.toFun) {p q : Y} (hpq : p ≤ q) (hqp : q ≤ p) :
    p = q := by
  obtain ⟨a, rfl⟩ := hf p
  exact eq_of_le_of_le_image f a q hpq hqp

end BddMorphism

/-- `P` is **representable** if it is a surjective bounded morphic image of a finite
clock-and-switch world. -/
def Representable (P : Type*) [Preorder P] : Prop :=
  ∃ (n m : ℕ) (f : BddMorphism (CWorld (Fin n) (Fin m)) P), Surjective f.toFun

/-- The cardinality obstruction: an image of `CWorld (Fin n) (Fin m)` has at most
`n · 2 ^ m` points. -/
theorem card_le_of_morphism {P : Type*} [Preorder P] [Fintype P] {n m : ℕ}
    (f : BddMorphism (CWorld (Fin n) (Fin m)) P) (hf : Surjective f.toFun) :
    Fintype.card P ≤ n * 2 ^ m := by
  classical
  have := Fintype.card_le_of_surjective f.toFun hf
  rwa [CWorld.card_eq] at this

/-! ## Part C — The two canonical morphisms -/

/-- Forgetting the switches is a surjective bounded morphism onto the clock. -/
def forgetSwitches (A B : Type*) [Preorder A] : BddMorphism (CWorld A B) A where
  toFun w := w.clock
  forth _ _ h := h.1
  back w a h := ⟨⟨a, w.switch⟩, ⟨h, fun _ hb => hb⟩, rfl⟩

theorem forgetSwitches_surjective (A B : Type*) [Preorder A] :
    Surjective (forgetSwitches A B).toFun := fun a => ⟨⟨a, fun _ => false⟩, rfl⟩

section CardChain

variable {m : ℕ}

/-- The switches that are on. -/
def onSet (w : CWorld (Fin 1) (Fin m)) : Finset (Fin m) :=
  Finset.univ.filter fun b => w.switch b = true

theorem onSet_card_le (w : CWorld (Fin 1) (Fin m)) : (onSet w).card ≤ m := by
  have := Finset.card_filter_le (Finset.univ : Finset (Fin m)) fun b => w.switch b = true
  simpa [onSet] using this

theorem onSet_subset {w v : CWorld (Fin 1) (Fin m)} (h : w ≤ v) : onSet w ⊆ onSet v := by
  intro b hb
  simp only [onSet, Finset.mem_filter, Finset.mem_univ, true_and] at hb ⊢
  exact h.2 b hb

/-- **Counting the switches that are on** is a bounded morphism onto the `(m+1)`-chain. -/
def cardChain (m : ℕ) : BddMorphism (CWorld (Fin 1) (Fin m)) (Fin (m + 1)) where
  toFun w := ⟨(onSet w).card, by have := onSet_card_le w; omega⟩
  forth _ _ h := by
    simp only [Fin.mk_le_mk]
    exact Finset.card_le_card (onSet_subset h)
  back w q h := by
    classical
    have h' : (onSet w).card ≤ (q : ℕ) := h
    clear h
    set off : Finset (Fin m) := Finset.univ \ onSet w with hoff
    have hoffcard : off.card = m - (onSet w).card := by
      rw [hoff, Finset.card_sdiff_of_subset (Finset.subset_univ _)]
      simp
    have hq : (q : ℕ) ≤ m := by omega
    have hd : (q : ℕ) - (onSet w).card ≤ off.card := by
      rw [hoffcard]; omega
    obtain ⟨T, hT, hTcard⟩ := Finset.exists_subset_card_eq hd
    refine ⟨⟨w.clock, fun b => w.switch b || decide (b ∈ T)⟩, ⟨le_rfl, fun b hb => by simp [hb]⟩,
      ?_⟩
    have honv : onSet ⟨w.clock, fun b => w.switch b || decide (b ∈ T)⟩ = onSet w ∪ T := by
      ext b
      simp only [onSet, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_union,
        Bool.or_eq_true, decide_eq_true_eq]
    have hdisj : Disjoint (onSet w) T := by
      refine Finset.disjoint_left.mpr fun b hb hbT => ?_
      have := hT hbT
      rw [hoff, Finset.mem_sdiff] at this
      exact this.2 hb
    have : ((onSet w) ∪ T).card = (onSet w).card + T.card := Finset.card_union_of_disjoint hdisj
    apply Fin.ext
    show (onSet ⟨w.clock, fun b => w.switch b || decide (b ∈ T)⟩).card = (q : ℕ)
    rw [honv, this, hTcard]
    omega

theorem cardChain_surjective (m : ℕ) : Surjective (cardChain m).toFun := by
  intro q
  have h : (cardChain m).toFun ⟨0, fun _ => false⟩ ≤ q := by
    simp only [cardChain]
    have : onSet (⟨0, fun _ => false⟩ : CWorld (Fin 1) (Fin m)) = ∅ := by
      ext b; simp [onSet]
    simp [this]
  obtain ⟨v, -, hv⟩ := (cardChain m).back ⟨0, fun _ => false⟩ q h
  exact ⟨v, hv⟩

end CardChain

/-! ## Part D — The greedy climb -/

section Walk

attribute [local instance 0] Classical.propDecidable

variable {P : Type*} [PartialOrder P]

/-- The **greedy climb**.  Starting from the root `r`, the switches `0, 1, …, n-1` are
processed in order; when switch `l` is on the walker moves to the enumerated point `t l`
if it is still below it, and to the top `tp` otherwise.  Jumping to `tp` when the target
is not above the current position is what makes the climb monotone in the switch set. -/
noncomputable def walk (t : ℕ → P) (r tp : P) (s : ℕ → Bool) : ℕ → P
  | 0 => r
  | n + 1 => if s n = true then (if walk t r tp s n ≤ t n then t n else tp) else walk t r tp s n

variable {t : ℕ → P} {r tp : P}

@[simp] theorem walk_zero (s : ℕ → Bool) : walk t r tp s 0 = r := rfl

theorem walk_succ (s : ℕ → Bool) (n : ℕ) :
    walk t r tp s (n + 1) =
      if s n = true then (if walk t r tp s n ≤ t n then t n else tp) else walk t r tp s n := by
  rw [walk]

theorem walk_le_succ (htp : ∀ p, p ≤ tp) (s : ℕ → Bool) (n : ℕ) :
    walk t r tp s n ≤ walk t r tp s (n + 1) := by
  rw [walk_succ]
  by_cases hs : s n = true
  · rw [if_pos hs]
    by_cases hle : walk t r tp s n ≤ t n
    · rw [if_pos hle]; exact hle
    · rw [if_neg hle]; exact htp _
  · rw [if_neg hs]

/-- **Monotonicity in the switch set.**  Turning more switches on can only move the
climb up. -/
theorem walk.mono (htp : ∀ p, p ≤ tp) {s s' : ℕ → Bool} (h : ∀ l, s l = true → s' l = true)
    (n : ℕ) : walk t r tp s n ≤ walk t r tp s' n := by
  induction n with
  | zero => exact le_rfl
  | succ n ih =>
      rw [walk_succ, walk_succ]
      by_cases hs : s n = true
      · have hs' : s' n = true := h n hs
        rw [if_pos hs, if_pos hs']
        by_cases hle : walk t r tp s n ≤ t n
        · rw [if_pos hle]
          by_cases hle' : walk t r tp s' n ≤ t n
          · rw [if_pos hle']
          · rw [if_neg hle']; exact htp _
        · rw [if_neg hle]
          by_cases hle' : walk t r tp s' n ≤ t n
          · exact absurd (le_trans ih hle') hle
          · rw [if_neg hle']
      · rw [if_neg hs]
        by_cases hs' : s' n = true
        · rw [if_pos hs']
          by_cases hle' : walk t r tp s' n ≤ t n
          · rw [if_pos hle']; exact le_trans ih hle'
          · rw [if_neg hle']; exact htp _
        · rw [if_neg hs']; exact ih

/-- The climb of length `n` only reads the first `n` switches. -/
theorem walk.congr_of_eq {s s' : ℕ → Bool} {n : ℕ} (h : ∀ l, l < n → s l = s' l) :
    walk t r tp s n = walk t r tp s' n := by
  induction n with
  | zero => rfl
  | succ n ih =>
      have ih' := ih fun l hl => h l (by omega)
      rw [walk_succ, walk_succ, ih', h n (by omega)]

/-- With every switch off the climb stays at the root. -/
theorem walk.all_false (n : ℕ) : walk t r tp (fun _ => false) n = r := by
  induction n with
  | zero => rfl
  | succ n ih => rw [walk_succ, ih]; simp

theorem walk_stable {s : ℕ → Bool} {a n : ℕ} (ha : a ≤ n)
    (h : ∀ l, a ≤ l → l < n → s l = false) : walk t r tp s n = walk t r tp s a := by
  induction n with
  | zero =>
      have : a = 0 := by omega
      subst this; rfl
  | succ n ih =>
      rcases Nat.lt_or_ge a (n + 1) with h1 | h1
      · have han : a ≤ n := by omega
        rw [walk_succ, if_neg (by rw [h n han (by omega)]; simp)]
        exact ih han fun l hl hln => h l hl (by omega)
      · have : a = n + 1 := by omega
        subst this; rfl

/-- After firing switch `L` the climb never falls below `t L` — unless it has been sent
to the top. -/
theorem walk_ge_of_true (htp : ∀ p, p ≤ tp) {s : ℕ → Bool} {L n : ℕ} (hL : L < n)
    (hs : s L = true) : t L ≤ walk t r tp s n ∨ walk t r tp s n = tp := by
  induction n with
  | zero => omega
  | succ n ih =>
      rcases Nat.lt_or_ge L n with h1 | h1
      · rcases ih h1 with h | h
        · exact Or.inl (le_trans h (walk_le_succ htp s n))
        · exact Or.inr (le_antisymm (htp _) (le_of_eq_of_le h.symm (walk_le_succ htp s n)))
      · have hLn : L = n := by omega
        subst hLn
        rw [walk_succ, if_pos hs]
        by_cases hle : walk t r tp s L ≤ t L
        · rw [if_pos hle]; exact Or.inl le_rfl
        · rw [if_neg hle]; exact Or.inr rfl

/-- **The lifting step.**  If the climb ends below the enumerated point `t j`, then
turning switch `j` on (and nothing else) makes it end *exactly* at `t j`.  This is the
`back` condition of the representation theorem, and the only place where the linear
extension hypothesis `hlin` is used. -/
theorem walk.open_step (htp : ∀ p, p ≤ tp) {N : ℕ}
    (hlin : ∀ i j, i < N → j < N → t i ≤ t j → i ≤ j) (n : ℕ) (hn : n ≤ N)
    (s : ℕ → Bool) (j : ℕ) (hj : j < n) (hq : walk t r tp s n ≤ t j) :
    ∃ s', (∀ l, s l = true → s' l = true) ∧ (∀ l, s' l = true → s l = true ∨ l = j) ∧
      walk t r tp s' n = t j := by
  classical
  refine ⟨fun l => s l || decide (l = j), fun l hl => by simp [hl], fun l hl => ?_, ?_⟩
  · rcases Bool.or_eq_true_iff.mp hl with h | h
    · exact Or.inl h
    · exact Or.inr (of_decide_eq_true h)
  set s' : ℕ → Bool := fun l => s l || decide (l = j) with hs'def
  have hmono : walk t r tp s n ≤ walk t r tp s' n :=
    walk.mono htp (fun l hl => by simp [hs'def, hl]) n
  by_cases hcase : walk t r tp s n = tp
  · have htj : t j = tp := le_antisymm (htp _) (le_of_eq_of_le hcase.symm hq)
    have h1 : tp ≤ walk t r tp s' n := le_of_eq_of_le hcase.symm hmono
    rw [htj]
    exact le_antisymm (htp _) h1
  · -- no switch of `s` strictly above `j` is on
    have hno : ∀ L, j < L → L < n → s L = false := by
      intro L hjL hLn
      by_contra hcon
      have hs : s L = true := by
        cases h : s L
        · exact absurd h hcon
        · rfl
      rcases walk_ge_of_true (t := t) (r := r) htp hLn hs with h | h
      · have := hlin L j (by omega) (by omega) (le_trans h hq)
        omega
      · exact hcase h
    have hstab : walk t r tp s n = walk t r tp s (j + 1) :=
      walk_stable (by omega) fun l hl hln => hno l (by omega) hln
    have hbelow : walk t r tp s' j = walk t r tp s j :=
      (walk.congr_of_eq fun l hl => by simp [hs'def]; omega).symm
    have hle : walk t r tp s j ≤ t j := by
      by_cases hsj : s j = true
      · rw [walk_succ, if_pos hsj] at hstab
        by_cases h : walk t r tp s j ≤ t j
        · exact h
        · rw [if_neg h] at hstab; exact absurd hstab hcase
      · rw [walk_succ, if_neg hsj] at hstab
        exact hstab ▸ hq
    have hstab' : walk t r tp s' n = walk t r tp s' (j + 1) :=
      walk_stable (by omega) fun l hl hln => by
        simp only [hs'def, Bool.or_eq_false_iff]
        exact ⟨hno l (by omega) hln, by simp; omega⟩
    rw [hstab', walk_succ, if_pos (by simp [hs'def]), hbelow, if_pos hle]

end Walk

/-! ## Part E — The filtration theorem -/

/-- A finite nonempty directed preorder has a greatest element. -/
theorem exists_top_of_directed {P : Type*} [Preorder P] [Fintype P] [Nonempty P]
    (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) : ∃ tp : P, ∀ p, p ≤ tp := by
  haveI : IsDirectedOrder P := ⟨fun x y => hdir x y⟩
  obtain ⟨M, hM⟩ := Finset.exists_le (Finset.univ : Finset P)
  exact ⟨M, fun p => hM p (Finset.mem_univ p)⟩

/-- A finite partial order admits a **linear extension enumeration**: a listing
`t 0, …, t (k-1)` of all its points in which `t i ≤ t j` forces `i ≤ j`. -/
theorem exists_linear_enumeration (P : Type*) [PartialOrder P] [Fintype P] [Nonempty P] :
    ∃ (k : ℕ) (t : ℕ → P), (∀ p : P, ∃ j, j < k ∧ t j = p) ∧
      (∀ i j, i < k → j < k → t i ≤ t j → i ≤ j) ∧ k = Fintype.card P := by
  classical
  letI : Fintype (LinearExtension P) := inferInstanceAs (Fintype P)
  have hcard : Fintype.card (LinearExtension P) = Fintype.card P := rfl
  set k := Fintype.card P with hk
  let e : Fin k ≃o LinearExtension P := monoEquivOfFin (LinearExtension P) hcard
  let bk : LinearExtension P → P := fun x => x
  have hbk : ∀ x, toLinearExtension (bk x) = x := fun _ => rfl
  refine ⟨k, fun j => if h : j < k then bk (e ⟨j, h⟩) else Classical.arbitrary P, ?_, ?_, rfl⟩
  · intro p
    obtain ⟨i, hi⟩ := e.surjective (toLinearExtension p)
    refine ⟨i, i.isLt, ?_⟩
    simp only [dif_pos i.isLt]
    have : toLinearExtension (bk (e ⟨(i : ℕ), i.isLt⟩)) = toLinearExtension p := by
      rw [hbk]
      simpa using hi
    exact this
  · intro i j hi hj hij
    simp only [dif_pos hi, dif_pos hj] at hij
    have h2 : toLinearExtension (bk (e ⟨i, hi⟩)) ≤ toLinearExtension (bk (e ⟨j, hj⟩)) :=
      toLinearExtension.monotone hij
    rw [hbk, hbk] at h2
    have := e.le_iff_le.mp h2
    simpa using this

/-- **The filtration theorem.**  Every finite rooted directed partial order is a
surjective bounded morphic image of a *one-tick* clock-and-switch world with one switch
per point.  The morphism is the greedy climb along a linear extension. -/
theorem representable_of_rooted_directed (P : Type*) [PartialOrder P] [Fintype P]
    (hroot : ∃ r : P, ∀ p, r ≤ p) (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) :
    ∃ f : BddMorphism (CWorld (Fin 1) (Fin (Fintype.card P))) P, Surjective f.toFun := by
  classical
  obtain ⟨r, hr⟩ := hroot
  haveI : Nonempty P := ⟨r⟩
  obtain ⟨tp, htp⟩ := exists_top_of_directed hdir
  obtain ⟨k, t, hsurj, hlin, hk⟩ := exists_linear_enumeration P
  rw [← hk]
  set ext : (Fin k → Bool) → (ℕ → Bool) :=
    fun s l => if h : l < k then s ⟨l, h⟩ else false with hext
  have hext_lt : ∀ (s : Fin k → Bool) (b : Fin k), ext s b.1 = s b := by
    intro s b
    simp [hext, b.isLt]
  have hforth : ∀ ⦃w v : CWorld (Fin 1) (Fin k)⦄, w ≤ v →
      walk t r tp (ext w.switch) k ≤ walk t r tp (ext v.switch) k := by
    intro w v h
    refine walk.mono htp ?_ k
    intro l hl
    simp only [hext] at hl ⊢
    by_cases hlk : l < k
    · rw [dif_pos hlk] at hl ⊢
      exact h.2 _ hl
    · rw [dif_neg hlk] at hl
      exact absurd hl (by simp)
  have hback : ∀ (w : CWorld (Fin 1) (Fin k)) (q : P),
      walk t r tp (ext w.switch) k ≤ q →
      ∃ v, w ≤ v ∧ walk t r tp (ext v.switch) k = q := by
    intro w q hq
    obtain ⟨j, hjk, rfl⟩ := hsurj q
    obtain ⟨s', h1, -, h3⟩ :=
      walk.open_step htp hlin k le_rfl (ext w.switch) j hjk hq
    refine ⟨⟨w.clock, fun b => s' b.1⟩, ⟨le_rfl, ?_⟩, ?_⟩
    · intro b hb
      exact h1 b.1 (by rw [hext_lt]; exact hb)
    · show walk t r tp (ext fun b : Fin k => s' b.1) k = t j
      rw [walk.congr_of_eq (s' := s') fun l hl => by simp [hext, hl], h3]
  refine ⟨⟨fun w => walk t r tp (ext w.switch) k, hforth, hback⟩, ?_⟩
  intro q
  have hbot : walk t r tp (ext fun _ => false) k = r := by
    rw [walk.congr_of_eq (s' := fun _ => false) fun l _ => by simp [hext]]
    exact walk.all_false k
  obtain ⟨v, -, hv⟩ := hback ⟨0, fun _ => false⟩ q (by
    show walk t r tp (ext fun _ => false) k ≤ q
    rw [hbot]; exact hr q)
  exact ⟨v, hv⟩

/-- **Characterisation of representability.**  A finite nonempty preorder is a surjective
bounded morphic image of a clock-and-switch world iff it is rooted, directed and
antisymmetric. -/
theorem representable_iff (P : Type*) [Preorder P] [Fintype P] [Nonempty P] :
    Representable P ↔ ((∃ r : P, ∀ p, r ≤ p) ∧ (∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) ∧
      (∀ p q : P, p ≤ q → q ≤ p → p = q)) := by
  classical
  constructor
  · rintro ⟨n, m, f, hf⟩
    have hn : 0 < n := by
      rcases Nat.eq_zero_or_pos n with rfl | h
      · obtain ⟨w, -⟩ := hf (Classical.arbitrary P)
        exact w.clock.elim0
      · exact h
    obtain ⟨i, rfl⟩ : ∃ i, n = i + 1 := ⟨n - 1, by omega⟩
    exact ⟨f.isRooted_image hf CWorld.isRooted, f.directed_image hf CWorld.directed,
      fun _ _ hpq hqp => f.antisymm_image hf hpq hqp⟩
  · rintro ⟨hroot, hdir, hanti⟩
    letI : PartialOrder P := { ‹Preorder P› with le_antisymm := hanti }
    obtain ⟨f, hf⟩ := representable_of_rooted_directed P hroot hdir
    exact ⟨1, Fintype.card P, f, hf⟩

/-! ## Part F — Antisymmetry cannot be dropped -/

/-- The two-element **cluster**: two points, each accessible from the other. -/
inductive Cluster : Type
  | a : Cluster
  | b : Cluster
  deriving DecidableEq, Fintype

instance : Inhabited Cluster := ⟨Cluster.a⟩

instance : Preorder Cluster where
  le _ _ := True
  le_refl _ := trivial
  le_trans _ _ _ _ _ := trivial

theorem cluster_isRooted : ∃ r : Cluster, ∀ p, r ≤ p := ⟨Cluster.a, fun _ => trivial⟩

theorem cluster_directed : ∀ x y : Cluster, ∃ z, x ≤ z ∧ y ≤ z :=
  fun _ _ => ⟨Cluster.a, trivial, trivial⟩

theorem cluster_not_antisymm : ¬ ∀ p q : Cluster, p ≤ q → q ≤ p → p = q := by
  intro h
  exact absurd (h Cluster.a Cluster.b trivial trivial) (by simp)

/-- **The mission statement is false without antisymmetry.**  The two-element cluster is
rooted and directed but not representable. -/
theorem not_representable_cluster : ¬ Representable Cluster := by
  intro h
  exact cluster_not_antisymm ((representable_iff Cluster).mp h).2.2

end CWorldFiltration