/-
# Clock-and-Switch Worlds: a Filtration / Representation Theorem

## What this file does

A **clock-and-switch world** `CWorld A B` is a pair consisting of a *clock reading*
`clock : A` and a *switch configuration* `switch : B → Bool`.  Accessibility is the
product order: the clock may only advance, and a switch that has been flipped on can
never be flipped off again.  This is the canonical "monotone resource" frame:
`CWorld (Fin n) (Fin m)` is the product of an `n`-chain with an `m`-dimensional
Boolean cube.

The mission was to prove the **filtration lemma**: every finite rooted directed
preorder is a bounded (`p`-)morphic image of some `CWorld (Fin n) (Fin m)`, extending
the two special cases `forgetSwitches` (project a world to its clock) and `cardChain`
(count the switches that are on).

The honest answer, established here, is a **sharp characterisation** rather than the
literal statement, and both halves are nontrivial:

* `antisymm_of_representable` (adversarial finding).  A bounded morphic image of a
  *finite partial order* is again antisymmetric.  Since every `CWorld (Fin n) (Fin m)`
  is a finite partial order, a finite preorder with a genuine two-element cluster is
  **never** such an image.  So the literal statement "every finite rooted directed
  *preorder*" is false, and the correct hypothesis is "rooted directed *poset*".
  The proof is not formal: it picks a maximal element of the (finite) preimage of the
  putative cluster and pushes it up with the back condition.

* `representable_of_rooted_directed` (main theorem).  Conversely, **every** finite
  rooted directed partial order `P` is a surjective bounded morphic image of
  `CWorld (Fin 1) (Fin (card P))`.  The morphism is the *greedy climb* `walk`: fix a
  linear extension `t 0, t 1, …` of `P` (Szpilrajn), start at the root, and read the
  switches left to right; when switch `i` is on, jump to `t i` if the current point
  still lies below `t i`, and otherwise jump to the top.  The "otherwise jump to the
  top" clause is exactly what makes the map monotone — the naive greedy walk without
  it is *not* monotone (see the Lab Notes below) — and the linear-extension property
  is exactly what makes it *open* (the back condition).

Combining the two halves gives `representable_iff`: for a finite preorder,

    representable by a clock-and-switch world  ↔  rooted ∧ directed ∧ antisymmetric.

The antisymmetry clause is removed again in `Combinatorics.CWorldClusterTolerant`, by
adjoining to the source an *indiscrete* phase coordinate; there the literal preorder
statement becomes true, and the number of phases needed is exactly the largest cluster
size of the target.

## Lab Notes (experimental data behind the theorems)

Exhaustive machine search over all labelled bounded posets (`= rooted + directed +
finite`) confirmed representability before the proof was attempted:

* all 36 bounded posets on 4 labelled points: representable, cube dimension `m ≤ 3`;
* all 380 bounded posets on 5 labelled points: representable, `m ≤ 4`;
* the 6-point "bowtie" `0 < a,b < c,d < 1` (not a lattice): representable with `m = 3`
  by `000↦0, 001↦c, 010↦a, 100↦b, 011↦c, 101↦c, 110↦d, 111↦1`.

Minimal cube dimensions found: 3-chain `m = 2`, 4-chain `m = 3`, 5-chain `m = 4`,
diamond `m = 2`, so `m` must be at least the height of `P` and at least `log₂ |P|`;
the theorem below spends `m = |P|`, which is not claimed to be optimal.

Counterexample hunt for monotonicity of the naive greedy walk (no "jump to the top"):
on the diamond `0 < a,b < 1` with linear extension `0,a,b,1`, switches `{b}` walk to
`b` while switches `{a,b}` walk to `a`, and `b ≰ a`.  This is the failure the `tp`
branch of `walk` repairs.

Every theorem below is proved with no `sorry` and no `native_decide`.
-/

import Mathlib

namespace CWorldFiltration

open Function

attribute [local instance] Classical.propDecidable

/-! ## Part A — Clock-and-switch worlds -/

/-- A **clock-and-switch world**: a clock reading in `A` together with a configuration
of switches indexed by `B`. -/
structure CWorld (A B : Type*) where
  /-- the clock reading -/
  clock : A
  /-- which switches are on -/
  switch : B → Bool

namespace CWorld

variable {A B : Type*}

/-- Accessibility: the clock advances and switches may only be turned on. -/
instance instPreorder [Preorder A] : Preorder (CWorld A B) where
  le w v := w.clock ≤ v.clock ∧ ∀ b, w.switch b = true → v.switch b = true
  le_refl _ := ⟨le_rfl, fun _ h => h⟩
  le_trans _ _ _ h₁ h₂ := ⟨le_trans h₁.1 h₂.1, fun b hb => h₂.2 b (h₁.2 b hb)⟩

theorem le_def [Preorder A] {w v : CWorld A B} :
    w ≤ v ↔ w.clock ≤ v.clock ∧ ∀ b, w.switch b = true → v.switch b = true := Iff.rfl

instance instPartialOrder [PartialOrder A] : PartialOrder (CWorld A B) where
  le_antisymm w v h₁ h₂ := by
    obtain ⟨w1, w2⟩ := w
    obtain ⟨v1, v2⟩ := v
    have hc : w1 = v1 := le_antisymm h₁.1 h₂.1
    subst hc
    have hs : w2 = v2 := by
      funext b
      cases hw : w2 b <;> cases hv : v2 b
      · rfl
      · have := h₂.2 b (by simp [hv]); simp [hw] at this
      · have := h₁.2 b (by simp [hw]); simp [hv] at this
      · rfl
    simp [hs]

/-- The clock-and-switch world is rooted: everything is above "clock at the bottom,
all switches off". -/
theorem isRooted [Preorder A] [OrderBot A] :
    ∃ w₀ : CWorld A B, ∀ w : CWorld A B, w₀ ≤ w :=
  ⟨⟨⊥, fun _ => false⟩, fun w => ⟨bot_le, fun b hb => by simp at hb⟩⟩

/-- The clock-and-switch world is directed: advance the clock to the later of the two
readings and turn on the union of the two switch sets. -/
theorem directed [SemilatticeSup A] (w v : CWorld A B) :
    ∃ u : CWorld A B, w ≤ u ∧ v ≤ u := by
  refine ⟨⟨w.clock ⊔ v.clock, fun b => w.switch b || v.switch b⟩, ⟨le_sup_left, ?_⟩,
    ⟨le_sup_right, ?_⟩⟩ <;> intro b hb <;> simp [hb]

/-- `CWorld A B` is the product `A × (B → Bool)`. -/
def equivProd : CWorld A B ≃ A × (B → Bool) where
  toFun w := (w.clock, w.switch)
  invFun p := ⟨p.1, p.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

instance instFintype [Fintype A] [Fintype B] [DecidableEq B] : Fintype (CWorld A B) :=
  Fintype.ofEquiv _ equivProd.symm

theorem card_eq (n m : ℕ) : Fintype.card (CWorld (Fin n) (Fin m)) = n * 2 ^ m := by
  rw [Fintype.card_congr (equivProd (A := Fin n) (B := Fin m))]
  simp

end CWorld

/-! ## Part B — Bounded morphisms (p-morphisms) -/

/-- A **bounded morphism** (p-morphism) of preorders: monotone (`forth`) and open
(`back`). -/
structure BddMorphism (X Y : Type*) [Preorder X] [Preorder Y] where
  /-- the underlying map -/
  toFun : X → Y
  /-- forth condition: the map is monotone -/
  forth : ∀ ⦃x y : X⦄, x ≤ y → toFun x ≤ toFun y
  /-- back condition: every point above the image of `x` is the image of a point above `x` -/
  back : ∀ (x : X) (q : Y), toFun x ≤ q → ∃ y, x ≤ y ∧ toFun y = q

namespace BddMorphism

variable {X Y Z : Type*} [Preorder X] [Preorder Y] [Preorder Z]

/-- Bounded morphisms compose. -/
def comp (g : BddMorphism Y Z) (f : BddMorphism X Y) : BddMorphism X Z where
  toFun := g.toFun ∘ f.toFun
  forth _ _ h := g.forth (f.forth h)
  back x q h := by
    obtain ⟨y, hy, rfl⟩ := g.back (f.toFun x) q h
    obtain ⟨z, hz, rfl⟩ := f.back x y hy
    exact ⟨z, hz, rfl⟩

@[simp] theorem comp_apply (g : BddMorphism Y Z) (f : BddMorphism X Y) (x : X) :
    (g.comp f).toFun x = g.toFun (f.toFun x) := rfl

/-- The image of a rooted frame is rooted. -/
theorem isRooted_image (f : BddMorphism X Y) (hf : Surjective f.toFun)
    (h : ∃ r : X, ∀ x, r ≤ x) : ∃ r : Y, ∀ y, r ≤ y := by
  obtain ⟨r, hr⟩ := h
  refine ⟨f.toFun r, fun y => ?_⟩
  obtain ⟨x, rfl⟩ := hf y
  exact f.forth (hr x)

/-- The image of a directed frame is directed. -/
theorem directed_image (f : BddMorphism X Y) (hf : Surjective f.toFun)
    (h : ∀ x y : X, ∃ z, x ≤ z ∧ y ≤ z) : ∀ p q : Y, ∃ s, p ≤ s ∧ q ≤ s := by
  intro p q
  obtain ⟨x, rfl⟩ := hf p
  obtain ⟨y, rfl⟩ := hf q
  obtain ⟨z, hz1, hz2⟩ := h x y
  exact ⟨f.toFun z, f.forth hz1, f.forth hz2⟩

/-- **Antisymmetry is inherited by images of finite posets.**  If `X` is a finite
partial order and `f : X → Y` is a surjective bounded morphism, then `Y` is
antisymmetric.  (Pick a maximal preimage of the alleged cluster `{p, q}` and push it
up along the back condition: maximality forces the two points to coincide.) -/
theorem antisymm_image {X Y : Type*} [PartialOrder X] [Finite X] [Preorder Y]
    (f : BddMorphism X Y) (hf : Surjective f.toFun) {p q : Y} (hpq : p ≤ q) (hqp : q ≤ p) :
    p = q := by
  obtain ⟨x₀, rfl⟩ := hf p
  set S : Set X := {x | f.toFun x = f.toFun x₀ ∨ f.toFun x = q} with hS
  have hne : S.Nonempty := ⟨x₀, Or.inl rfl⟩
  obtain ⟨x, hx⟩ := Set.Finite.exists_maximal (Set.toFinite S) hne
  have key : ∀ y, x ≤ y → y ∈ S → y = x := fun y hxy hyS => le_antisymm (hx.2 hyS hxy) hxy
  rcases hx.1 with hxv | hxv
  · obtain ⟨y, hxy, hy⟩ := f.back x q (hxv ▸ hpq)
    have hyx := key y hxy (Or.inr hy)
    subst hyx
    rw [← hxv, hy]
  · obtain ⟨y, hxy, hy⟩ := f.back x (f.toFun x₀) (hxv ▸ hqp)
    have hyx := key y hxy (Or.inl hy)
    subst hyx
    rw [← hy, hxv]

end BddMorphism

/-! ## Part C — The two catalogued special cases, and clock padding -/

/-- `forgetSwitches`: reading only the clock is a surjective bounded morphism onto the
clock chain.  (Back condition: to realise a later clock reading, keep the switches —
or turn them all on.) -/
def forgetSwitches (A B : Type*) [Preorder A] : BddMorphism (CWorld A B) A where
  toFun w := w.clock
  forth _ _ h := h.1
  back w a h := ⟨⟨a, w.switch⟩, ⟨h, fun _ hb => hb⟩, rfl⟩

theorem forgetSwitches_surjective (A B : Type*) [Preorder A] :
    Surjective (forgetSwitches A B).toFun :=
  fun a => ⟨⟨a, fun _ => false⟩, rfl⟩

/-- The number of switches that are currently on. -/
def switchCount {m : ℕ} (w : CWorld (Fin 1) (Fin m)) : ℕ :=
  (Finset.univ.filter fun b => w.switch b = true).card

theorem switchCount_lt {m : ℕ} (w : CWorld (Fin 1) (Fin m)) : switchCount w < m + 1 := by
  have h := Finset.card_filter_le (Finset.univ : Finset (Fin m)) (fun b => w.switch b = true)
  simp only [Finset.card_univ, Fintype.card_fin] at h
  simpa [switchCount] using Nat.lt_succ_of_le h

theorem switchCount_indicator {m : ℕ} (c : Fin 1) (u : Finset (Fin m)) :
    switchCount ⟨c, fun b => decide (b ∈ u)⟩ = u.card := by
  have hset : (Finset.univ.filter fun b : Fin m => (decide (b ∈ u)) = true) = u := by
    ext b; simp
  simp only [switchCount, hset]

/-- `cardChain`: counting the switches that are on is a surjective bounded morphism from
the `m`-cube onto the chain `Fin (m+1)`.  (Back condition: any target count can be
realised by enlarging the set of switches that are on.) -/
def cardChain (m : ℕ) : BddMorphism (CWorld (Fin 1) (Fin m)) (Fin (m + 1)) where
  toFun w := ⟨switchCount w, switchCount_lt w⟩
  forth w v h := by
    refine Fin.mk_le_mk.mpr (Finset.card_le_card ?_)
    intro b hb
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hb ⊢
    exact h.2 b hb
  back w j h := by
    have hle : switchCount w ≤ (j : ℕ) := h
    have hj : (j : ℕ) ≤ (Finset.univ : Finset (Fin m)).card := by
      have := j.isLt
      simp only [Finset.card_univ, Fintype.card_fin]
      omega
    obtain ⟨u, hu₁, -, hu₃⟩ :=
      Finset.exists_subsuperset_card_eq
        (Finset.subset_univ (Finset.univ.filter fun b => w.switch b = true)) hle hj
    refine ⟨⟨w.clock, fun b => decide (b ∈ u)⟩, ⟨le_rfl, ?_⟩, Fin.ext ?_⟩
    · intro b hb
      have : b ∈ u := hu₁ (by simpa using hb)
      simpa using this
    · show switchCount _ = (j : ℕ)
      rw [switchCount_indicator, hu₃]

theorem cardChain_surjective (m : ℕ) : Surjective (cardChain m).toFun := by
  intro j
  obtain ⟨u, -, hu⟩ := Finset.exists_subset_card_eq (s := (Finset.univ : Finset (Fin m)))
    (n := (j : ℕ)) (by simpa using Nat.lt_succ_iff.mp j.isLt)
  exact ⟨⟨0, fun b => decide (b ∈ u)⟩, Fin.ext (by
    show switchCount _ = (j : ℕ)
    rw [switchCount_indicator, hu])⟩

/-- Padding the clock: collapsing a long clock to a trivial one is a surjective bounded
morphism, so the switch dimension is what matters and the clock length may be chosen
freely. -/
def clockPad (n m : ℕ) : BddMorphism (CWorld (Fin (n + 1)) (Fin m)) (CWorld (Fin 1) (Fin m)) where
  toFun w := ⟨0, w.switch⟩
  forth _ _ h := ⟨le_rfl, h.2⟩
  back w v h := ⟨⟨w.clock, v.switch⟩, ⟨le_rfl, h.2⟩, by
    obtain ⟨v1, v2⟩ := v
    simp only [CWorld.mk.injEq, and_true]
    exact Subsingleton.elim _ _⟩

theorem clockPad_surjective (n m : ℕ) : Surjective (clockPad n m).toFun := by
  intro v
  exact ⟨⟨0, v.switch⟩, by obtain ⟨v1, v2⟩ := v; simp [clockPad, Subsingleton.elim (0 : Fin 1) v1]⟩

/-! ## Part D — The greedy climb and the representation theorem -/

/-- A finite nonempty directed preorder has a greatest element. -/
theorem exists_top_of_directed {P : Type*} [Preorder P] [Fintype P] [Nonempty P]
    (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) : ∃ tp : P, ∀ p, p ≤ tp := by
  have key : ∀ s : Finset P, ∃ z : P, ∀ x ∈ s, x ≤ z := by
    intro s
    induction s using Finset.induction with
    | empty => exact ⟨Classical.arbitrary P, by simp⟩
    | insert a s _ ih =>
        obtain ⟨z, hz⟩ := ih
        obtain ⟨u, hu₁, hu₂⟩ := hdir a z
        exact ⟨u, by
          intro x hx
          rcases Finset.mem_insert.mp hx with rfl | hx
          · exact hu₁
          · exact le_trans (hz x hx) hu₂⟩
  obtain ⟨z, hz⟩ := key Finset.univ
  exact ⟨z, fun p => hz p (Finset.mem_univ p)⟩

/-- Every finite nonempty partial order admits a **linear extension enumeration**:
a listing `t 0, …, t (k-1)` of all its points in which `t i ≤ t j` forces `i ≤ j`. -/
theorem exists_linear_enumeration (P : Type*) [PartialOrder P] [Fintype P] [Nonempty P] :
    ∃ (k : ℕ) (t : ℕ → P), (∀ p : P, ∃ j, j < k ∧ t j = p) ∧
      (∀ i j, i < k → j < k → t i ≤ t j → i ≤ j) ∧ k = Fintype.card P := by
  letI : Fintype (LinearExtension P) := inferInstanceAs (Fintype P)
  set k := Fintype.card P with hk
  have hcard : Fintype.card (LinearExtension P) = k := rfl
  let e : Fin k ≃o LinearExtension P := monoEquivOfFin (LinearExtension P) hcard
  refine ⟨k, fun i => if h : i < k then (id (e ⟨i, h⟩) : P) else Classical.arbitrary P, ?_, ?_, rfl⟩
  · intro p
    refine ⟨(e.symm (id p : LinearExtension P)).1, (e.symm _).2, ?_⟩
    simp [e]
  · intro i j hi hj hij
    simp only [dif_pos hi, dif_pos hj] at hij
    have h1 := toLinearExtension.monotone hij
    exact e.le_iff_le.mp h1

/-- The **greedy climb**.  Reading the switches `s 0, s 1, …` from left to right,
starting at the root `r`: when switch `i` is on, jump to `t i` if the current point is
still below `t i`, and jump to the top `tp` otherwise. -/
noncomputable def walk {P : Type*} [PartialOrder P] (t : ℕ → P) (r tp : P) (s : ℕ → Bool) :
    ℕ → P
  | 0 => r
  | i + 1 => if s i = true then (if walk t r tp s i ≤ t i then t i else tp)
             else walk t r tp s i

namespace walk

variable {P : Type*} [PartialOrder P] {t : ℕ → P} {r tp : P}

@[simp] theorem zero (s : ℕ → Bool) : walk t r tp s 0 = r := rfl

theorem succ (s : ℕ → Bool) (i : ℕ) :
    walk t r tp s (i + 1) =
      if s i = true then (if walk t r tp s i ≤ t i then t i else tp) else walk t r tp s i := by
  rw [walk]

/-- The climb after `i` steps only depends on the first `i` switches. -/
theorem congr_of_eq {s s' : ℕ → Bool} {i : ℕ} (h : ∀ l, l < i → s l = s' l) :
    walk t r tp s i = walk t r tp s' i := by
  induction i with
  | zero => rfl
  | succ i ih =>
      have hi := ih fun l hl => h l (by omega)
      rw [succ, succ, hi, h i (by omega)]

@[simp] theorem all_false (i : ℕ) : walk t r tp (fun _ => false) i = r := by
  induction i with
  | zero => rfl
  | succ i ih => rw [succ, ih]; simp

/-- **Forth.**  Turning on more switches can only move the climb upwards.  This is
where the "jump to the top" branch is indispensable. -/
theorem mono (htop : ∀ p : P, p ≤ tp) {s s' : ℕ → Bool}
    (hss : ∀ l, s l = true → s' l = true) (i : ℕ) :
    walk t r tp s i ≤ walk t r tp s' i := by
  induction i with
  | zero => exact le_rfl
  | succ i ih =>
      rw [succ, succ]
      by_cases h : s i = true
      · have h' := hss i h
        simp only [h, h', if_true]
        by_cases hb : walk t r tp s' i ≤ t i
        · have ha : walk t r tp s i ≤ t i := le_trans ih hb
          simp [ha, hb]
        · simp only [hb, if_false]
          exact htop _
      · simp only [h, if_false, Bool.false_eq_true]
        by_cases h' : s' i = true
        · simp only [h', if_true]
          by_cases hb : walk t r tp s' i ≤ t i
          · simp only [hb, if_true]; exact le_trans ih hb
          · simp only [hb, if_false]; exact htop _
        · simp only [h', if_false, Bool.false_eq_true]; exact ih

/-- **Back.**  Any point of `P` above the current position of the climb is reached by
turning on more switches — and only switches that have not been read yet are touched.
The linear-extension hypothesis `hlin` is what makes this work. -/
theorem open_step (htop : ∀ p : P, p ≤ tp) {k : ℕ}
    (hlin : ∀ i j, i < k → j < k → t i ≤ t j → i ≤ j) :
    ∀ (i : ℕ), i ≤ k → ∀ (s : ℕ → Bool) (j : ℕ), j < i → walk t r tp s i ≤ t j →
      ∃ s' : ℕ → Bool, (∀ l, s l = true → s' l = true) ∧ (∀ l, i ≤ l → s' l = s l) ∧
        walk t r tp s' i = t j := by
  intro i
  induction i with
  | zero => intro _ s j hj; omega
  | succ i ih =>
      intro hik s j hj hq
      have hik' : i < k := by omega
      rw [succ] at hq
      by_cases hs : s i = true
      · rw [if_pos hs] at hq
        by_cases hb : walk t r tp s i ≤ t i
        · rw [if_pos hb] at hq
          have hij : i ≤ j := hlin i j hik' (by omega) hq
          have hji : j = i := by omega
          exact ⟨s, fun _ h => h, fun _ _ => rfl, by rw [succ, if_pos hs, if_pos hb, hji]⟩
        · rw [if_neg hb] at hq
          have hqe : t j = tp := le_antisymm (htop _) hq
          exact ⟨s, fun _ h => h, fun _ _ => rfl, by rw [succ, if_pos hs, if_neg hb, hqe]⟩
      · rw [if_neg hs] at hq
        by_cases hji : j < i
        · obtain ⟨s'', h1, h2, h3⟩ := ih (by omega) s j hji hq
          refine ⟨s'', h1, fun l hl => h2 l (by omega), ?_⟩
          rw [succ, h2 i (le_refl i), if_neg hs, h3]
        · have hji' : j = i := by omega
          subst hji'
          refine ⟨Function.update s j true, ?_, ?_, ?_⟩
          · intro l hl
            by_cases h : l = j
            · subst h; simp
            · simpa [Function.update_of_ne h] using hl
          · intro l _
            exact Function.update_of_ne (by omega) _ _
          · have hw : walk t r tp (Function.update s j true) j = walk t r tp s j :=
              (congr_of_eq fun l hl => (Function.update_of_ne (by omega) _ _).symm).symm
            rw [succ, hw]
            simp [hq]

end walk

/-- `P` is **representable** if it is a surjective bounded morphic image of some
clock-and-switch world on finitely many clock ticks and finitely many switches. -/
def Representable (P : Type*) [Preorder P] : Prop :=
  ∃ (n m : ℕ) (f : BddMorphism (CWorld (Fin n) (Fin m)) P), Surjective f.toFun

/-- **Main theorem (filtration / representation lemma).**  Every finite rooted directed
partial order is a surjective bounded morphic image of the clock-and-switch world with
one clock tick and one switch per point.  The morphism is the greedy climb along a
linear extension. -/
theorem representable_of_rooted_directed (P : Type*) [PartialOrder P] [Fintype P]
    (hroot : ∃ r : P, ∀ p, r ≤ p) (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) :
    ∃ f : BddMorphism (CWorld (Fin 1) (Fin (Fintype.card P))) P, Surjective f.toFun := by
  obtain ⟨r, hr⟩ := hroot
  haveI : Nonempty P := ⟨r⟩
  obtain ⟨tp, htp⟩ := exists_top_of_directed hdir
  obtain ⟨k, t, hsurj, hlin, hk⟩ := exists_linear_enumeration P
  rw [← hk]
  set ext : (Fin k → Bool) → (ℕ → Bool) := fun s l => if h : l < k then s ⟨l, h⟩ else false
    with hext
  have hext_lt : ∀ (s : Fin k → Bool) (b : Fin k), ext s b.1 = s b := by
    intro s b
    simp [hext, b.isLt]
  refine ⟨⟨fun w => walk t r tp (ext w.switch) k, ?_, ?_⟩, ?_⟩
  · -- forth
    intro w v h
    refine walk.mono htp ?_ k
    intro l hl
    simp only [hext] at hl ⊢
    by_cases hlk : l < k
    · rw [dif_pos hlk] at hl ⊢
      exact h.2 _ hl
    · rw [dif_neg hlk] at hl
      exact absurd hl (by simp)
  · -- back
    intro w q hq
    obtain ⟨j, hjk, rfl⟩ := hsurj q
    obtain ⟨s', h1, -, h3⟩ := walk.open_step htp hlin k le_rfl (ext w.switch) j hjk hq
    refine ⟨⟨w.clock, fun b => s' b.1⟩, ⟨le_rfl, ?_⟩, ?_⟩
    · intro b hb
      exact h1 b.1 (by rw [hext_lt]; exact hb)
    · show walk t r tp (ext fun b : Fin k => s' b.1) k = t j
      rw [walk.congr_of_eq (s' := s') (fun l hl => by simp [hext, hl]), h3]
  · -- surjectivity
    intro q
    obtain ⟨j, hjk, rfl⟩ := hsurj q
    have hbot : walk t r tp (ext fun _ => false) k = r := by
      rw [walk.congr_of_eq (s' := fun _ => false) (fun l _ => by simp [hext])]
      exact walk.all_false k
    obtain ⟨s', -, -, h3⟩ :=
      walk.open_step htp hlin k le_rfl (ext fun _ => false) j hjk (hbot ▸ hr (t j))
    refine ⟨⟨0, fun b => s' b.1⟩, ?_⟩
    show walk t r tp (ext fun b : Fin k => s' b.1) k = t j
    rw [walk.congr_of_eq (s' := s') (fun l hl => by simp [hext, hl]), h3]

/-- Restatement of the main theorem in terms of `Representable`. -/
theorem representable_of_rooted_directed' (P : Type*) [PartialOrder P] [Fintype P]
    (hroot : ∃ r : P, ∀ p, r ≤ p) (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) :
    Representable P := by
  obtain ⟨f, hf⟩ := representable_of_rooted_directed P hroot hdir
  exact ⟨1, Fintype.card P, f, hf⟩

/-! ## Part E — The characterisation, and its consequences -/

/-- **The characterisation.**  A finite preorder is a bounded morphic image of a
clock-and-switch world **iff** it is rooted, directed and antisymmetric.  Antisymmetry
is not a technicality: it rules out every preorder with a genuine cluster. -/
theorem representable_iff (P : Type*) [Preorder P] [Fintype P] [Nonempty P] :
    Representable P ↔
      ((∃ r : P, ∀ p, r ≤ p) ∧ (∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) ∧
        ∀ p q : P, p ≤ q → q ≤ p → p = q) := by
  constructor
  · rintro ⟨n, m, f, hf⟩
    refine ⟨?_, ?_, ?_⟩
    · rcases n with _ | n
      · exact absurd (hf (Classical.arbitrary P)) (by rintro ⟨⟨c, -⟩, -⟩; exact c.elim0)
      · exact f.isRooted_image hf CWorld.isRooted
    · exact f.directed_image hf fun x y => CWorld.directed x y
    · exact fun p q hpq hqp => f.antisymm_image hf hpq hqp
  · rintro ⟨hroot, hdir, hanti⟩
    letI : PartialOrder P := { ‹Preorder P› with le_antisymm := hanti }
    exact representable_of_rooted_directed' P hroot hdir

/-- Cardinality obstruction: a representable poset has at most `n * 2 ^ m` points, so
the number of switches must be at least `log₂ |P|`. -/
theorem card_le_of_morphism {P : Type*} [Preorder P] [Fintype P] {n m : ℕ}
    (f : BddMorphism (CWorld (Fin n) (Fin m)) P) (hf : Surjective f.toFun) :
    Fintype.card P ≤ n * 2 ^ m := by
  have := Fintype.card_le_of_surjective _ hf
  rwa [CWorld.card_eq] at this

/-- The catalogued special case `forgetSwitches` is subsumed: the clock chain `Fin (n+1)`
is representable. -/
theorem representable_chain (n : ℕ) : Representable (Fin (n + 1)) := by
  refine representable_of_rooted_directed' _ ⟨0, fun p => Fin.zero_le p⟩ ?_
  intro x y
  exact ⟨max x y, le_max_left _ _, le_max_right _ _⟩

/-- The catalogued special case `cardChain` is subsumed and re-proved abstractly:
the switch-count chain is a bounded morphic image of the `m`-cube. -/
theorem representable_cardChain (m : ℕ) : Representable (Fin (m + 1)) :=
  ⟨1, m, cardChain m, cardChain_surjective m⟩

/-- Clock-and-switch worlds are themselves representable — the class of representable
finite posets is exactly the class of bounded morphic images of that class. -/
theorem representable_cworld (n m : ℕ) : Representable (CWorld (Fin (n + 1)) (Fin m)) :=
  representable_of_rooted_directed' _ CWorld.isRooted CWorld.directed

/-- The two-element **cluster**: two distinct points, each accessible from the other.
It is finite, rooted and directed, but not antisymmetric. -/
def Cluster : Type := Bool

instance : Preorder Cluster where
  le _ _ := True
  le_refl _ := trivial
  le_trans _ _ _ _ _ := trivial

instance : Fintype Cluster := inferInstanceAs (Fintype Bool)

instance : Nonempty Cluster := inferInstanceAs (Nonempty Bool)

theorem cluster_isRooted : ∃ r : Cluster, ∀ p, r ≤ p :=
  ⟨(false : Bool), fun _ => trivial⟩

theorem cluster_directed : ∀ x y : Cluster, ∃ z, x ≤ z ∧ y ≤ z :=
  fun x _ => ⟨x, trivial, trivial⟩

/-- **The boundary of the theorem.**  A two-element cluster is finite, rooted and
directed, yet it is *not* a bounded morphic image of any clock-and-switch world.  So the
literal statement "every finite rooted directed *preorder*" is false, and the
antisymmetry hypothesis in the main theorem cannot be dropped. -/
theorem not_representable_cluster : ¬ Representable Cluster := by
  intro h
  have hanti := ((representable_iff Cluster).mp h).2.2
  have : (false : Bool) = (true : Bool) := hanti (false : Bool) (true : Bool) trivial trivial
  exact absurd this (by simp)

end CWorldFiltration