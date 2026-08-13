/-
# Bounded Morphisms and Transfer between Forcing Frames

A step towards the finite-frame completeness problem for the modal logic of
forcing.  We introduce **bounded morphisms** (p-morphisms) between Kripke frames,
prove the transfer theorem for the semantics of
`Catalog/Logic/Multiverse/S42Independence.lean`, and apply it to the finite
button–switch control frames:

* `msat_pmorphism` — truth is invariant along a bounded morphism;
* `validity_transfer` — validity is inherited by surjective bounded images, so the
  modal logic of a frame is contained in the logic of each of its images;
* `forgetSwitches` — forgetting the switches is a surjective bounded morphism onto
  the pure button order: **switches are semantically free**;
* `cardChain` — the cardinality map is a surjective bounded morphism from the
  `n`-button order onto the `(n+1)`-element chain, so every finite chain is a
  bounded image of a button frame;
* `dot3_valid_of_total` — the linearity axiom `.3` is valid on every total frame;
* `control_logic_strictly_below_chain` — combining the above with the refutation of
  `.3` on two independent buttons: the logic of the control frame is *strictly*
  contained in the logic of the chains it maps onto.
-/
import Logic.Multiverse.S42Independence

namespace MultiversePMorphism

open BooleanValuedRealization S42Independence

variable {α W W' W'' : Type*}

/-- A **bounded morphism** (p-morphism) of Kripke frames. -/
structure PMorphism (R : W → W → Prop) (R' : W' → W' → Prop) where
  /-- The underlying map of worlds. -/
  toFun : W → W'
  /-- Accessibility is preserved. -/
  forth : ∀ {w v : W}, R w v → R' (toFun w) (toFun v)
  /-- Accessibility is reflected: every successor of an image is the image of a
  successor. -/
  back : ∀ {w : W} {u : W'}, R' (toFun w) u → ∃ v, R w v ∧ toFun v = u

/-- Composition of bounded morphisms. -/
def PMorphism.comp {R : W → W → Prop} {R' : W' → W' → Prop} {R'' : W'' → W'' → Prop}
    (g : PMorphism R' R'') (f : PMorphism R R') : PMorphism R R'' where
  toFun := g.toFun ∘ f.toFun
  forth := fun h => g.forth (f.forth h)
  back := by
    intro w u hu
    obtain ⟨v', hv', rfl⟩ := g.back hu
    obtain ⟨v, hv, rfl⟩ := f.back hv'
    exact ⟨v, hv, rfl⟩

/-- **Transfer theorem.**  A modal formula holds at a world iff it holds at its
image under a bounded morphism, for the pulled-back valuation. -/
theorem msat_pmorphism {R : W → W → Prop} {R' : W' → W' → Prop}
    (f : PMorphism R R') (V' : α → W' → Prop) (p : MForm α) (w : W) :
    msat R (fun a x => V' a (f.toFun x)) p w ↔ msat R' V' p (f.toFun w) := by
  induction p generalizing w with
  | atom a => exact Iff.rfl
  | fls => exact Iff.rfl
  | imp p q ih1 ih2 => simp only [msat_imp, ih1, ih2]
  | box p ih =>
      simp only [msat_box]
      constructor
      · intro h u hu
        obtain ⟨v, hv, rfl⟩ := f.back hu
        exact (ih v).1 (h v hv)
      · intro h v hv
        exact (ih v).2 (h _ (f.forth hv))

/-- **Validity transfer.**  The modal logic of a frame is contained in the logic of
any of its surjective bounded images. -/
theorem validity_transfer {R : W → W → Prop} {R' : W' → W' → Prop}
    (f : PMorphism R R') (hsurj : Function.Surjective f.toFun) {p : MForm α}
    (h : ∀ (V : α → W → Prop) (w : W), msat R V p w) :
    ∀ (V' : α → W' → Prop) (u : W'), msat R' V' p u := by
  intro V' u
  obtain ⟨w, rfl⟩ := hsurj u
  exact (msat_pmorphism f V' p w).1 (h _ w)

/-! ## Switches are semantically free -/

section Frames

variable {Btn Sw : Type*}

/-- Forgetting the switches is a bounded morphism onto the pure button order. -/
def forgetSwitches :
    PMorphism (cacc (Btn := Btn) (Sw := Sw)) (fun S T : Finset Btn => S ⊆ T) where
  toFun := Prod.fst
  forth := id
  back := fun {w} {u} h => ⟨(u, w.2), h, rfl⟩

theorem forgetSwitches_surjective :
    Function.Surjective (forgetSwitches (Btn := Btn) (Sw := Sw)).toFun :=
  fun S => ⟨(S, fun _ => false), rfl⟩

/-- The cardinality map is a bounded morphism from the `n`-button order onto the
`(n+1)`-element chain: every finite chain is a bounded image of a button frame. -/
def cardChain (n : ℕ) :
    PMorphism (fun S T : Finset (Fin n) => S ⊆ T) (fun i j : Fin (n + 1) => i ≤ j) where
  toFun := fun S => ⟨S.card, by
    have h := Finset.card_le_univ S
    simp only [Fintype.card_fin] at h
    omega⟩
  forth := fun {S T} h => Finset.card_le_card h
  back := by
    intro S u hu
    have h1 : S.card ≤ (u : ℕ) := hu
    have h2 : (u : ℕ) ≤ Fintype.card (Fin n) := by
      simp only [Fintype.card_fin]
      omega
    obtain ⟨T, hST, hT⟩ := Finset.exists_superset_card_eq h1 h2
    exact ⟨T, hST, by ext; simpa using hT⟩

theorem cardChain_surjective (n : ℕ) : Function.Surjective (cardChain n).toFun := by
  intro u
  have h2 : (u : ℕ) ≤ Fintype.card (Fin n) := by
    simp only [Fintype.card_fin]
    omega
  obtain ⟨T, _, hT⟩ :=
    Finset.exists_superset_card_eq (s := (∅ : Finset (Fin n))) (by simp) h2
  exact ⟨T, by ext; simpa using hT⟩

/-- The composite bounded morphism from the full control frame onto a chain. -/
def controlToChain (n : ℕ) (Sw : Type*) :
    PMorphism (cacc (Btn := Fin n) (Sw := Sw)) (fun i j : Fin (n + 1) => i ≤ j) :=
  (cardChain n).comp forgetSwitches

theorem controlToChain_surjective (n : ℕ) (Sw : Type*) :
    Function.Surjective (controlToChain n Sw).toFun :=
  (cardChain_surjective n).comp (forgetSwitches_surjective)

end Frames

/-! ## Linearity is valid on total frames -/

/-- The linearity axiom `.3` for two formulas. -/
def dot3F (p q : MForm α) : MForm α :=
  MForm.disj (.box (.imp (.box p) q)) (.box (.imp (.box q) p))

/-- **`.3` is valid on every total frame**, in particular on every chain. -/
theorem dot3_valid_of_total {R : W → W → Prop} (htot : ∀ x y, R x y ∨ R y x)
    (V : α → W → Prop) (p q : MForm α) (w : W) : msat R V (dot3F p q) w := by
  rw [dot3F, msat_disj]
  by_contra hc
  push_neg at hc
  obtain ⟨h1, h2⟩ := hc
  simp only [msat_box, msat_imp] at h1 h2
  push_neg at h1 h2
  obtain ⟨v, hwv, hboxp, hnq⟩ := h1
  obtain ⟨u, hwu, hboxq, hnp⟩ := h2
  rcases htot v u with h | h
  · exact hnp (hboxp u h)
  · exact hnq (hboxq v h)

/-- Chains are total. -/
theorem chain_total (n : ℕ) : ∀ i j : Fin (n + 1), i ≤ j ∨ j ≤ i :=
  fun i j => le_total i j

/-! ## The logic of the control frame is strictly below the logic of its chains -/

/-- The `.3` instance refuted by two independent buttons, for an arbitrary button
type: the valuation reads the atom `true` as "button `b₁` pushed" and `false` as
"button `b₂` pushed". -/
theorem dot3_fails_buttons {Btn Sw : Type*} (b₁ b₂ : Btn) (hne : b₁ ≠ b₂)
    (g : Sw → Bool) :
    ¬ msat (cacc (Btn := Btn) (Sw := Sw))
        (fun a w => (if a then b₁ else b₂) ∈ w.1)
        (dot3F (.atom true) (.atom false)) ((∅ : Finset Btn), g) := by
  rw [dot3F, msat_disj]
  rintro (h | h)
  · have hb : msat (cacc (Btn := Btn) (Sw := Sw))
        (fun a w => (if a then b₁ else b₂) ∈ w.1) (.box (.atom true))
        (({b₁} : Finset Btn), g) := fun u hu => hu (Finset.mem_singleton_self b₁)
    have hq := h ({b₁}, g) (Finset.empty_subset _) hb
    simp only [msat_atom, if_neg (Bool.false_ne_true), Finset.mem_singleton] at hq
    exact hne hq.symm
  · have hb : msat (cacc (Btn := Btn) (Sw := Sw))
        (fun a w => (if a then b₁ else b₂) ∈ w.1) (.box (.atom false))
        (({b₂} : Finset Btn), g) := fun u hu => hu (Finset.mem_singleton_self b₂)
    have hq := h ({b₂}, g) (Finset.empty_subset _) hb
    simp only [msat_atom, Finset.mem_singleton] at hq
    exact hne hq

/-- **Strict containment.**  The modal logic of the `n`-button control frame
(`n ≥ 2`) is contained in the logic of the `(n+1)`-chain, and the containment is
strict: the linearity axiom `.3` is valid on the chain but refuted on the frame.
The bounded morphism `controlToChain` therefore cannot be inverted, and no
linearity principle can be added to the logic of forcing. -/
theorem control_logic_strictly_below_chain (n : ℕ) (hn : 2 ≤ n) (Sw : Type*) :
    (∀ p : MForm Bool,
        (∀ (V : Bool → CWorld (Fin n) Sw → Prop) (w : CWorld (Fin n) Sw),
            msat cacc V p w) →
        ∀ (V' : Bool → Fin (n + 1) → Prop) (i : Fin (n + 1)), msat (· ≤ ·) V' p i) ∧
    (∃ p : MForm Bool,
        (∀ (V' : Bool → Fin (n + 1) → Prop) (i : Fin (n + 1)), msat (· ≤ ·) V' p i) ∧
        ¬ ∀ (V : Bool → CWorld (Fin n) Sw → Prop) (w : CWorld (Fin n) Sw),
            msat cacc V p w) := by
  constructor
  · intro p hp
    exact validity_transfer (controlToChain n Sw) (controlToChain_surjective n Sw) hp
  · refine ⟨dot3F (.atom true) (.atom false), ?_, ?_⟩
    · intro V' i
      exact dot3_valid_of_total (chain_total n) V' _ _ i
    · intro hall
      have h0 : (⟨0, by omega⟩ : Fin n) ≠ ⟨1, by omega⟩ := by
        simp [Fin.ext_iff]
      exact dot3_fails_buttons (Sw := Sw) ⟨0, by omega⟩ ⟨1, by omega⟩ h0
        (fun _ => false) (hall _ _)

end MultiversePMorphism