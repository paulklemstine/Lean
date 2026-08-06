import Novelty.ArithmetizedQFTReflection

/-!
# Sharpness of the independence-transfer theorem: one-sided transfer is insufficient

`Novelty.ArithmetizedQFTReflection` proved (Future Direction 5) that if an arithmetic
`PA` proves **both** transfer implications `Con u → Con t` and `Con t → Con u`, then
`Con u` is PA-independent exactly when `Con t` is (`independence_transfer`).  The
accompanying conjecture list asked whether the *mutual* hypothesis is really needed,
or whether a single PA-provable implication already forces the biconditional.

This file settles that question: **one-sided transfer is strictly insufficient**
(`one_sided_transfer_insufficient`, `mutual_transfer_not_weakenable`).

The obstruction to building such a witness with the catalog's standard Kripke
satisfaction `sat` is that `sat` interprets `box i` *independently of the tag* `i`, so
all consistency sentences are semantically identified there (this is exactly why
`capSys` proves every transfer axiom, cf. `capSys_provable_transferAxiom`).  We
therefore introduce a **tag-sensitive** Kripke semantics `satC c`: tag `i` is given
its own accessibility relation

  `m ⟶ᵢ n  ↔  n < m ∧ m ≤ c i`,

a sub-relation of `<` truncated at the tag-dependent height `c i`.  Each `⟶ᵢ` is
transitive and conversely well-founded, so all GL schemata remain valid
(`isGL_capC`), while different tags now genuinely disagree about boxed falsum.

Choosing heights `c u = 0` and `c t = 1` and taking the theory `sepSys u t` of all
formulas valid at the worlds `0, 1` gives an explicit consistent GL theory which

* proves `¬Con u` (so `Con u` is **not** independent),
* leaves `Con t` independent, and
* proves the transfer implication `Con u → Con t`.

Consequently the biconditional of `independence_transfer` fails for one-sided
transfer, and the reverse implication `Con t → Con u` is unprovable in that theory
(`sepSys_no_reverse_transfer`).  A by-product is that the minimal soundness condition
`MinSoundness` of Future Direction 2 is genuinely **tag-local**
(`sepSys_min_soundness_tag_local`).
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

/-! ## §1. A tag-sensitive Kripke semantics -/

/-- **Tag-sensitive Kripke satisfaction.**  The frame for tag `i` is `<` truncated at
height `c i`: world `m` sees world `n` iff `n < m` and `m ≤ c i`.  Above its height a
tag sees nothing, so all of its boxes are vacuously true there. -/
def satC (c : ℕ → ℕ) : ℕ → Form → Bool
  | _, bot => false
  | _, atom _ => true
  | m, imp a b => (!(satC c m a)) || satC c m b
  | m, box i a => if m ≤ c i then (List.range m).all (fun n => satC c n a) else true

/-- Satisfaction of an implication is classical and local. -/
theorem satC_imp (c : ℕ → ℕ) (m : ℕ) (a b : Form) :
    satC c m (imp a b) = true ↔ (satC c m a = true → satC c m b = true) := by
  simp only [satC]; cases satC c m a <;> cases satC c m b <;> simp

/-- Satisfaction of a box: below the tag's height it quantifies over strictly smaller
worlds; above the height it is vacuously true. -/
theorem satC_box (c : ℕ → ℕ) (m i : ℕ) (a : Form) :
    satC c m (box i a) = true ↔ (m ≤ c i → ∀ n, n < m → satC c n a = true) := by
  simp only [satC]
  by_cases h : m ≤ c i <;> simp [h, List.all_eq_true, List.mem_range]

/-- Above its height a tag's box is unconditionally true. -/
theorem satC_box_of_gt (c : ℕ → ℕ) {m i : ℕ} (h : c i < m) (a : Form) :
    satC c m (box i a) = true := by
  rw [satC_box]; intro hle; omega

/-- **Converse well-foundedness of the truncated frame**, the semantic content of the
Löb axiom: if `□ᵢ a → a` holds at every world below `m`, then `a` holds at every world
below `m`.  (No height restriction is needed: above its height a tag's box is
vacuously true, which only makes the antecedent easier to discharge.) -/
theorem satC_loeb_engine (c : ℕ → ℕ) (i : ℕ) (a : Form) (m : ℕ)
    (h : ∀ n, n < m → satC c n (imp (box i a) a) = true) :
    ∀ n, n < m → satC c n a = true := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn
    have hstep := h n hn
    rw [satC_imp] at hstep
    refine hstep ?_
    rw [satC_box]
    intro _ k hk
    exact ih k hk (hk.trans hn)

/-! ## §2. Finite-height theories of the tag-sensitive semantics -/

/-- The theory of the tag-sensitive semantics `satC c` truncated to the worlds
`0, …, N`: its theorems are the formulas true at all those worlds. -/
def capC (c : ℕ → ℕ) (N : ℕ) : ProofSys Form where
  Proof := { a : Form // ∀ m ≤ N, satC c m a = true }
  concl := Subtype.val
  size := fun _ => 0

/-- Provability in `capC c N` is truth at the worlds `0, …, N`. -/
theorem provable_capC (c : ℕ → ℕ) (N : ℕ) (a : Form) :
    Provable (capC c N) a ↔ ∀ m ≤ N, satC c m a = true := by
  constructor
  · rintro ⟨⟨b, hb⟩, rfl⟩; exact hb
  · intro h; exact ⟨⟨a, h⟩, rfl⟩

/-- **Every truncated tag-sensitive frame is a GL theory for every tag.**  Each tag's
accessibility relation is transitive and conversely well founded, which is exactly
what the `K`, `4` and Löb schemata require. -/
theorem isGL_capC (c : ℕ → ℕ) (N i : ℕ) : IsGLTheory i (capC c N) := by
  constructor
  · intro a b hab ha
    rw [provable_capC] at *
    intro m hm
    exact (satC_imp c m a b).1 (hab m hm) (ha m hm)
  · intro a ha
    rw [provable_capC] at *
    intro m _
    rw [satC_box]
    intro _ n hn
    exact ha n (by omega)
  · intro a ha
    rw [provable_capC]
    intro m _
    exact ha (satC c m) rfl (fun _ _ => rfl)
  · intro a b
    rw [provable_capC]
    intro m _
    rw [satC_imp]; intro hab
    rw [satC_imp]; intro ha
    rw [satC_box] at hab ha ⊢
    intro hle n hn
    exact (satC_imp c n a b).1 (hab hle n hn) (ha hle n hn)
  · intro a
    rw [provable_capC]
    intro m _
    rw [satC_imp]; intro h
    rw [satC_box] at h ⊢
    intro hle n hn
    rw [satC_box]
    intro _ k hk
    exact h hle k (hk.trans hn)
  · intro a
    rw [provable_capC]
    intro m _
    rw [satC_imp]; intro h
    rw [satC_box] at h ⊢
    intro hle
    exact satC_loeb_engine c i a m (fun n hn => h hle n hn)

/-- **Every truncated tag-sensitive theory is consistent**: falsum fails at world
`0`. -/
theorem consistent_capC (c : ℕ → ℕ) (N : ℕ) : Consistent (capC c N) := by
  intro h
  rw [provable_capC] at h
  have := h 0 (Nat.zero_le N)
  simp [satC] at this

/-! ## §3. The separating theory: heights `0` for tag `u`, `1` for tag `t` -/

/-- The separating height assignment: tag `u` has height `0` (it sees nothing at all,
so it "proves falsum" everywhere), every other tag has height `1`. -/
def sepHeight (u : ℕ) : ℕ → ℕ := fun j => if j = u then 0 else 1

/-- The distinguished tag has height `0`. -/
@[simp] theorem sepHeight_self (u : ℕ) : sepHeight u u = 0 := if_pos rfl

/-- Every other tag has height `1`. -/
@[simp] theorem sepHeight_of_ne {u j : ℕ} (h : j ≠ u) : sepHeight u j = 1 := if_neg h

/-- The **separating theory**: all formulas of the tag-sensitive semantics with
heights `sepHeight u` that are valid at the two worlds `0` and `1`. -/
def sepSys (u : ℕ) : ProofSys Form := capC (sepHeight u) 1

/-- The separating theory is a GL theory at every tag. -/
theorem isGL_sepSys (u i : ℕ) : IsGLTheory i (sepSys u) := isGL_capC _ _ i

/-- The separating theory is consistent. -/
theorem consistent_sepSys (u : ℕ) : Consistent (sepSys u) := consistent_capC _ _

/-- **The zero-height tag proves falsum**: `□_u ⊥` is valid in the separating
theory. -/
theorem sepSys_provable_box_u_bot (u : ℕ) : Provable (sepSys u) (box u bot) := by
  rw [sepSys, provable_capC]
  intro m hm
  rw [satC_box]
  intro hle n hn
  rw [sepHeight_self] at hle
  omega

/-- **The height-one tag does not prove falsum**: `□_t ⊥` fails at world `1`, because
that world still sees world `0`. -/
theorem sepSys_not_provable_box_t_bot {u t : ℕ} (h : t ≠ u) :
    ¬ Provable (sepSys u) (box t bot) := by
  rw [sepSys, provable_capC]
  intro hprov
  have h1 := hprov 1 le_rfl
  rw [satC_box] at h1
  have hle : (1 : ℕ) ≤ sepHeight u t := by rw [sepHeight_of_ne h]
  have := h1 hle 0 (by omega)
  simp [satC] at this

/-- **The consistency sentence of the height-one tag is not provable either**: at
world `0` the tag `t` sees nothing, so `□_t ⊥` holds there and `Con t` fails. -/
theorem sepSys_not_provable_Con_t (u t : ℕ) : ¬ Provable (sepSys u) (Con t) := by
  rw [sepSys, provable_capC]
  intro hprov
  have h0 := hprov 0 (by omega)
  rw [Con, neg, satC_imp] at h0
  have hbox : satC (sepHeight u) 0 (box t bot) = true := by
    rw [satC_box]; intro _ n hn; omega
  have := h0 hbox
  simp [satC] at this

/-- **`Con t` is independent of the separating theory.** -/
theorem sepSys_Con_t_independent {u t : ℕ} (h : t ≠ u) :
    Independent (sepSys u) (Con t) :=
  ⟨sepSys_not_provable_Con_t u t,
    (negative_half_iff_min_soundness (isGL_sepSys u t)).2
      (sepSys_not_provable_box_t_bot h)⟩

/-- **`Con u` is refuted, hence not independent**: the separating theory proves
`¬Con u`. -/
theorem sepSys_provable_neg_Con_u (u : ℕ) : Provable (sepSys u) (neg (Con u)) := by
  have hGL := isGL_sepSys u u
  exact hGL.mp (hGL.taut (taut_dni (box u bot))) (sepSys_provable_box_u_bot u)

/-- `Con u` is **not** independent of the separating theory. -/
theorem sepSys_Con_u_not_independent (u : ℕ) : ¬ Independent (sepSys u) (Con u) :=
  fun h => h.2 (sepSys_provable_neg_Con_u u)

/-- The separating theory proves the transfer implication `Con u → Con t`, vacuously:
it refutes the antecedent. -/
theorem sepSys_provable_transfer (u t : ℕ) :
    Provable (sepSys u) (imp (Con u) (Con t)) := by
  rw [sepSys, provable_capC]
  intro m _
  rw [satC_imp]
  intro hcon
  exfalso
  rw [Con, neg, satC_imp] at hcon
  have hbox : satC (sepHeight u) m (box u bot) = true := by
    rw [satC_box]
    intro hle n hn
    rw [sepHeight_self] at hle
    omega
  have := hcon hbox
  simp [satC] at this

/-! ## §4. Main results -/

/-- **One-sided transfer is insufficient.**  There is an explicit consistent GL theory
`PA` and two tags `u ≠ t` such that `PA` proves `Con u → Con t`, the sentence `Con t`
is independent of `PA`, and `Con u` is not.  Hence the mutual hypothesis of
`independence_transfer` cannot be weakened to a single implication. -/
theorem one_sided_transfer_insufficient {u t : ℕ} (h : t ≠ u) (pa : ℕ) :
    IsGLTheory pa (sepSys u) ∧ Consistent (sepSys u) ∧
      Provable (sepSys u) (imp (Con u) (Con t)) ∧
      Independent (sepSys u) (Con t) ∧ ¬ Independent (sepSys u) (Con u) :=
  ⟨isGL_sepSys u pa, consistent_sepSys u, sepSys_provable_transfer u t,
    sepSys_Con_t_independent h, sepSys_Con_u_not_independent u⟩

/-- **The mutual hypothesis of `independence_transfer` is not weakenable.**  No
theorem of the form "one PA-provable transfer implication forces simultaneous
independence" can hold, even restricted to consistent GL theories. -/
theorem mutual_transfer_not_weakenable :
    ¬ ∀ (u t pa : ℕ) (PA : ProofSys.{0, 0} Form), IsGLTheory pa PA → Consistent PA →
        Provable PA (imp (Con u) (Con t)) →
        (Independent PA (Con u) ↔ Independent PA (Con t)) := by
  intro hall
  have h := hall 0 1 0 (sepSys 0) (isGL_sepSys 0 0) (consistent_sepSys 0)
    (sepSys_provable_transfer 0 1)
  exact sepSys_Con_u_not_independent 0
    (h.2 (sepSys_Con_t_independent (u := 0) (t := 1) (by decide)))

/-- **The reverse transfer implication is genuinely unavailable** in the separating
theory: adding it would collapse the example, by `transfer_one_direction`. -/
theorem sepSys_no_reverse_transfer {u t : ℕ} (h : t ≠ u) :
    ¬ Provable (sepSys u) (imp (Con t) (Con u)) := by
  intro hrev
  have hGL := isGL_sepSys u u
  have := (transfer_one_direction (u := t) (t := u) (PA := sepSys u)
    hGL.mp hGL.taut hrev).2
  exact this (sepSys_Con_t_independent h).2 (sepSys_provable_neg_Con_u u)

/-- **Minimal soundness is tag-local.**  The separating theory satisfies the minimal
soundness condition of Future Direction 2 at tag `t` but violates it at tag `u`; so
the negative independence half can hold for one theory and fail for another inside a
single consistent arithmetic. -/
theorem sepSys_min_soundness_tag_local {u t : ℕ} (h : t ≠ u) :
    MinSoundness t (sepSys u) ∧ ¬ MinSoundness u (sepSys u) :=
  ⟨sepSys_not_provable_box_t_bot h, fun hns => hns (sepSys_provable_box_u_bot u)⟩

/-! ## §5. The exact repair: one-sided transfer plus minimal soundness -/

/-- **One-sided transfer suffices once minimal soundness is assumed at the source
tag.**  If `PA` proves `Con u → Con t`, is minimally sound at `u` (it does not prove
`□_u ⊥`), and `Con t` is independent of `PA`, then `Con u` is independent of `PA` as
well.  Only the *positive* half of the independence of `Con t` is used. -/
theorem one_sided_transfer_with_min_soundness {u t pa : ℕ} {PA : ProofSys Form}
    (hGL : IsGLTheory pa PA) (himp : Provable PA (imp (Con u) (Con t)))
    (hms : MinSoundness u PA) (ht : ¬ Provable PA (Con t)) :
    Independent PA (Con u) := by
  refine ⟨fun hu => ht (hGL.mp himp hu), fun hneg => hms ?_⟩
  exact hGL.mp (hGL.taut (taut_dne (box u bot))) hneg

/-- **The repair is optimal.**  Minimal soundness at the source tag cannot be dropped
from `one_sided_transfer_with_min_soundness`: the separating theory satisfies every
other hypothesis and yet `Con u` is not independent there. -/
theorem min_soundness_hypothesis_necessary {u t : ℕ} (h : t ≠ u) :
    Provable (sepSys u) (imp (Con u) (Con t)) ∧ ¬ Provable (sepSys u) (Con t) ∧
      ¬ MinSoundness u (sepSys u) ∧ ¬ Independent (sepSys u) (Con u) :=
  ⟨sepSys_provable_transfer u t, sepSys_not_provable_Con_t u t,
    (sepSys_min_soundness_tag_local h).2, sepSys_Con_u_not_independent u⟩

end PhysicsConsistency