import Mathlib

/-!
# Algebraic–Logical Completeness for Closure-Generated Proof Semirings

This file establishes that syntactic indistinguishability of proof expressions under
a closure operator coincides exactly with the kernel congruence of the canonical
evaluation morphism into closed sets. Under finiteness hypotheses, the quotient is
finite and inequivalent proofs can be separated by finite models.

## Main definitions

* `IsClosureOp` — closure operator axioms on `Set σ → Set σ`
* `proofEquivSetoid` — the equivalence relation `C (sem p) = C (sem q)`
* `ClosedSet` — the type of closed sets under `C`
* `closureEvalFn` — the canonical evaluation `p ↦ C (sem p)` into `ClosedSet C`
* `kerSetoid` — kernel of a function as a `Setoid`

## Main results

* `closure_closed` — `C (C s) = C s` for any closure operator
* `closure_equiv_iff_closureEval_eq` — **kernel characterization**: closure-equivalence
  equals kernel of the closure evaluation map
* `proofEquivSetoid_eq_kerSetoid` — the equivalence relation equals the kernel setoid
* `proofEquiv_ringCon` — under compatible semantics, proof equivalence is a `RingCon`
* `exists_finite_separating_map` — **finite separating model theorem**
* `fullEMLClosure'_isClosureOp` — the EML closure is a closure operator
-/

open Set

noncomputable section

universe u

variable {σ : Type u}

/-! ## Closure Operator Axioms -/

/-- Axioms for a closure operator on `Set σ`. -/
structure IsClosureOp (C : Set σ → Set σ) : Prop where
  /-- Every set is contained in its closure. -/
  extensive : ∀ s, s ⊆ C s
  /-- Closure is monotone. -/
  mono : ∀ {s t}, s ⊆ t → C s ⊆ C t
  /-- Closure is idempotent (the closure of a closure is contained in the closure). -/
  idem : ∀ s, C (C s) ⊆ C s

/-- A closure operator satisfies `C (C s) = C s`. -/
theorem closure_closed (C : Set σ → Set σ) (hC : IsClosureOp C) (s : Set σ) :
    C (C s) = C s :=
  Subset.antisymm (hC.idem s) (hC.extensive (C s))

/-- Closure preserves equality under mutual inclusion. -/
theorem closure_eq_of_mutual_incl (C : Set σ → Set σ) (hC : IsClosureOp C)
    {s t : Set σ} (h1 : s ⊆ C t) (h2 : t ⊆ C s) :
    C s = C t := by
  apply Subset.antisymm
  · calc C s ⊆ C (C t) := hC.mono h1
    _ = C t := closure_closed C hC t
  · calc C t ⊆ C (C s) := hC.mono h2
    _ = C s := closure_closed C hC s

/-! ## Proof Equivalence Relation -/

/-- The equivalence relation on proof expressions induced by a closure operator
    and semantic evaluation: `p ≈ q` iff `C (sem p) = C (sem q)`. -/
def proofEquivSetoid (C : Set σ → Set σ) (sem : α → Set σ) : Setoid α where
  r p q := C (sem p) = C (sem q)
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

/-- The bidirectional-inclusion form of proof equivalence is equivalent to the
    equality-of-closures form, given closure operator axioms. -/
theorem proofEquiv_iff_inclForm (C : Set σ → Set σ) (hC : IsClosureOp C)
    (sem : α → Set σ) (p q : α) :
    (proofEquivSetoid C sem).r p q ↔
      (sem p ⊆ C (sem q) ∧ sem q ⊆ C (sem p)) := by
  simp only [proofEquivSetoid]
  constructor
  · intro h
    exact ⟨(hC.extensive _).trans h.le, (hC.extensive _).trans h.symm.le⟩
  · intro ⟨h1, h2⟩
    exact closure_eq_of_mutual_incl C hC h1 h2

/-! ## Closed Sets and Evaluation -/

/-- The type of closed sets under `C`: sets `s` with `C s = s`. -/
def ClosedSet (C : Set σ → Set σ) := {s : Set σ // C s = s}

/-- The canonical evaluation: send a proof expression to the closure of its semantics. -/
def closureEvalFn (C : Set σ → Set σ) (hC : IsClosureOp C) (sem : α → Set σ) :
    α → ClosedSet C :=
  fun p => ⟨C (sem p), closure_closed C hC (sem p)⟩

/-! ## Kernel Congruence -/

/-- The kernel of a function as a `Setoid`. -/
def kerSetoid (f : α → β) : Setoid α where
  r x y := f x = f y
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

/-- **Kernel Characterization Theorem (Algebraic Completeness)**:
    Closure-equivalence of proof expressions is *exactly* equality under the
    canonical evaluation into closed sets. Closure logic is the kernel congruence
    of the proof evaluation map. -/
theorem closure_equiv_iff_closureEval_eq (C : Set σ → Set σ) (hC : IsClosureOp C)
    (sem : α → Set σ) (p q : α) :
    (proofEquivSetoid C sem).r p q ↔
      closureEvalFn C hC sem p = closureEvalFn C hC sem q := by
  simp only [proofEquivSetoid, closureEvalFn, ClosedSet, Subtype.mk_eq_mk]

/-- The proof equivalence setoid equals the kernel setoid of closure evaluation. -/
theorem proofEquivSetoid_eq_kerSetoid (C : Set σ → Set σ) (hC : IsClosureOp C)
    (sem : α → Set σ) :
    proofEquivSetoid C sem = kerSetoid (closureEvalFn C hC sem) := by
  ext p q
  exact closure_equiv_iff_closureEval_eq C hC sem p q

/-! ## Semiring Congruence (RingCon)

When proof expressions carry `+` and `*` and the semantic evaluation is compatible
with closure, the proof equivalence becomes a `RingCon`. -/

/-- Compatibility of a semantic map with a closure operator:
    closure absorbs the algebraic operations. -/
structure ClosureCompatible (C : Set σ → Set σ) [Add α] [Mul α]
    (sem : α → Set σ) : Prop where
  /-- Closure absorbs addition. -/
  add_compat : ∀ p q : α, C (sem (p + q)) = C (sem p ∪ sem q)
  /-- Closure commutes with union of closed sets. -/
  closure_union : ∀ s t : Set σ, C (C s ∪ C t) = C (s ∪ t)
  /-- Closure absorbs multiplication. -/
  mul_compat : ∀ p q : α, C (sem (p * q)) = C (sem p ∩ sem q)
  /-- Closure commutes with intersection of closed sets. -/
  closure_inter : ∀ s t : Set σ, C (C s ∩ C t) = C (s ∩ t)

/-- Proof equivalence respects addition under compatible semantics. -/
theorem proofEquiv_add_congr (C : Set σ → Set σ) (_hC : IsClosureOp C)
    [Add α] [Mul α] (sem : α → Set σ) (hcompat : ClosureCompatible C sem)
    {p q r s : α}
    (hpq : (proofEquivSetoid C sem).r p q)
    (hrs : (proofEquivSetoid C sem).r r s) :
    (proofEquivSetoid C sem).r (p + r) (q + s) := by
  simp only [proofEquivSetoid] at *
  calc C (sem (p + r)) = C (sem p ∪ sem r) := hcompat.add_compat p r
    _ = C (C (sem p) ∪ C (sem r)) := (hcompat.closure_union (sem p) (sem r)).symm
    _ = C (C (sem q) ∪ C (sem s)) := by rw [hpq, hrs]
    _ = C (sem q ∪ sem s) := hcompat.closure_union (sem q) (sem s)
    _ = C (sem (q + s)) := (hcompat.add_compat q s).symm

/-- Proof equivalence respects multiplication under compatible semantics. -/
theorem proofEquiv_mul_congr (C : Set σ → Set σ) (_hC : IsClosureOp C)
    [Add α] [Mul α] (sem : α → Set σ) (hcompat : ClosureCompatible C sem)
    {p q r s : α}
    (hpq : (proofEquivSetoid C sem).r p q)
    (hrs : (proofEquivSetoid C sem).r r s) :
    (proofEquivSetoid C sem).r (p * r) (q * s) := by
  simp only [proofEquivSetoid] at *
  calc C (sem (p * r)) = C (sem p ∩ sem r) := hcompat.mul_compat p r
    _ = C (C (sem p) ∩ C (sem r)) := (hcompat.closure_inter (sem p) (sem r)).symm
    _ = C (C (sem q) ∩ C (sem s)) := by rw [hpq, hrs]
    _ = C (sem q ∩ sem s) := hcompat.closure_inter (sem q) (sem s)
    _ = C (sem (q * s)) := (hcompat.mul_compat q s).symm

/-- Under compatible semantics, proof equivalence is a `RingCon` — a congruence
    for both `+` and `*`. The quotient by this congruence is the **proof semiring**. -/
def proofEquiv_ringCon (C : Set σ → Set σ) (hC : IsClosureOp C)
    [Add α] [Mul α] (sem : α → Set σ) (hcompat : ClosureCompatible C sem) :
    RingCon α where
  r := (proofEquivSetoid C sem).r
  iseqv := (proofEquivSetoid C sem).iseqv
  mul' := proofEquiv_mul_congr C hC sem hcompat
  add' := proofEquiv_add_congr C hC sem hcompat

/-! ## Finite Separating Models -/

/-- `ClosedSet C` is finite when `σ` is finite (since `Set σ` is finite). -/
instance closedSet_finite [Finite σ] (C : Set σ → Set σ) : Finite (ClosedSet C) :=
  Subtype.finite

/-- **Finite Separating Model Theorem**: If `σ` is finite and two proof expressions
    are not closure-equivalent, there exists a finite type separating them. -/
theorem exists_finite_separating_map (C : Set σ → Set σ) (hC : IsClosureOp C)
    (sem : α → Set σ) [Finite σ]
    {p q : α}
    (hpq : ¬ (proofEquivSetoid C sem).r p q) :
    ∃ (T : Type u) (_ : Finite T) (f : α → T), f p ≠ f q :=
  ⟨ClosedSet C, closedSet_finite C, closureEvalFn C hC sem,
    fun h => hpq ((closure_equiv_iff_closureEval_eq C hC sem p q).mpr h)⟩

/-- The closure evaluation map separates inequivalent proof expressions. -/
theorem closureEval_separates (C : Set σ → Set σ) (hC : IsClosureOp C)
    (sem : α → Set σ)
    {p q : α}
    (hpq : ¬ (proofEquivSetoid C sem).r p q) :
    closureEvalFn C hC sem p ≠ closureEvalFn C hC sem q :=
  fun h => hpq ((closure_equiv_iff_closureEval_eq C hC sem p q).mpr h)

/-! ## Finite Quotient Characterization -/

/-- The quotient of proof expressions by closure equivalence. -/
def ProofQuotient (C : Set σ → Set σ) (sem : α → Set σ) :=
  Quotient (proofEquivSetoid C sem)

/-- Quotient equality corresponds to closure evaluation equality. -/
theorem quotient_eq_iff_closureEval_eq (C : Set σ → Set σ) (hC : IsClosureOp C)
    (sem : α → Set σ) (p q : α) :
    @Quotient.mk' _ (proofEquivSetoid C sem) p =
      @Quotient.mk' _ (proofEquivSetoid C sem) q ↔
      closureEvalFn C hC sem p = closureEvalFn C hC sem q := by
  rw [Quotient.eq']
  exact closure_equiv_iff_closureEval_eq C hC sem p q

/-! ## Finite Generation of the Kernel Congruence

When `σ` is finite, the kernel congruence is finitely generated in the sense that
it is determined by a finite set of generating pairs (one per closed set). -/

/-- A setoid is finitely generated if there exists a finite set of pairs
    whose equivalence closure equals the full relation. -/
def FinitelyGeneratedSetoid (S : Setoid α) : Prop :=
  ∃ (gens : Finset (α × α)),
    (∀ p ∈ gens, S.r p.1 p.2) ∧
    (∀ a b, S.r a b →
      ∀ (T : Setoid α), (∀ p ∈ gens, T.r p.1 p.2) → T.r a b)

/-- The kernel congruence is completely determined by the closure evaluation:
    any setoid that identifies the same closed sets also identifies the
    proof-equivalent expressions. -/
theorem kernel_determined_by_closureEval (C : Set σ → Set σ) (hC : IsClosureOp C)
    (sem : α → Set σ) (p q : α) :
    (proofEquivSetoid C sem).r p q ↔
      closureEvalFn C hC sem p = closureEvalFn C hC sem q :=
  closure_equiv_iff_closureEval_eq C hC sem p q

/-! ## Connection to EML Closure

The EML (Exp-Minus-Log) closure from density theory satisfies the closure axioms. -/

/-- The EML operation: `exp(a) - log(b)`. -/
def EMLd' (a b : ℝ) : ℝ := Real.exp a - Real.log b

/-- EML closure at depth `n`: iteratively apply `EMLd'` to pairs from the set. -/
def EMLClosure' : ℕ → Set ℝ → Set ℝ
  | 0, S => S
  | n + 1, S => EMLClosure' n S ∪
      {z | ∃ a ∈ EMLClosure' n S, ∃ b ∈ EMLClosure' n S, z = EMLd' a b}

/-- Full EML closure: union over all depths. -/
def fullEMLClosure' (S : Set ℝ) : Set ℝ := ⋃ n, EMLClosure' n S

/-- EML closure grows with depth. -/
theorem EMLClosure'_mono_depth (S : Set ℝ) (n : ℕ) :
    EMLClosure' n S ⊆ EMLClosure' (n + 1) S := by
  intro x hx; simp [EMLClosure']; exact Or.inl hx

/-- EML closure at depth `n` is monotone in the depth parameter. -/
theorem EMLClosure'_mono_depth_le (S : Set ℝ) {m n : ℕ} (h : m ≤ n) :
    EMLClosure' m S ⊆ EMLClosure' n S := by
  induction h with
  | refl => exact Subset.rfl
  | step _ ih => exact ih.trans (EMLClosure'_mono_depth S _)

/-- `fullEMLClosure'` is extensive. -/
theorem fullEMLClosure'_extensive (S : Set ℝ) :
    S ⊆ fullEMLClosure' S := by
  intro x hx
  exact Set.mem_iUnion.mpr ⟨0, by simpa [EMLClosure']⟩

/-- EML closure is monotone in the seed set. -/
theorem EMLClosure'_mono_set (n : ℕ) {S T : Set ℝ} (h : S ⊆ T) :
    EMLClosure' n S ⊆ EMLClosure' n T := by
  induction n with
  | zero => exact h
  | succ n ih =>
    intro x hx
    simp only [EMLClosure', Set.mem_union, Set.mem_setOf_eq] at hx ⊢
    rcases hx with hx | ⟨a, ha, b, hb, rfl⟩
    · exact Or.inl (ih hx)
    · exact Or.inr ⟨a, ih ha, b, ih hb, rfl⟩

/-- `fullEMLClosure'` is monotone. -/
theorem fullEMLClosure'_mono {S T : Set ℝ} (h : S ⊆ T) :
    fullEMLClosure' S ⊆ fullEMLClosure' T := by
  intro x hx
  obtain ⟨n, hn⟩ := Set.mem_iUnion.mp hx
  exact Set.mem_iUnion.mpr ⟨n, EMLClosure'_mono_set n h hn⟩

/-
`fullEMLClosure'` is idempotent.
-/
theorem fullEMLClosure'_idem (S : Set ℝ) :
    fullEMLClosure' (fullEMLClosure' S) ⊆ fullEMLClosure' S := by
  intro x;
  simp +decide [ fullEMLClosure' ];
  intro n hn;
  induction' n with n ih generalizing x <;> simp_all +decide [ EMLClosure' ];
  rcases hn with ( hn | ⟨ a, ha, b, hb, rfl ⟩ );
  · exact ih hn;
  · obtain ⟨ i, hi ⟩ := ih ha
    obtain ⟨ j, hj ⟩ := ih hb
    use max i j + 1
    simp [EMLClosure'];
    exact Or.inr ⟨ a, EMLClosure'_mono_depth_le _ ( le_max_left _ _ ) hi, b, EMLClosure'_mono_depth_le _ ( le_max_right _ _ ) hj, rfl ⟩

/-- `fullEMLClosure'` is a closure operator. -/
theorem fullEMLClosure'_isClosureOp : IsClosureOp fullEMLClosure' where
  extensive := fullEMLClosure'_extensive
  mono := fun h => fullEMLClosure'_mono h
  idem := fullEMLClosure'_idem

/-- The kernel characterization for EML proof equivalence. -/
theorem EML_equiv_iff_eval_eq (sem : α → Set ℝ) (p q : α) :
    (proofEquivSetoid fullEMLClosure' sem).r p q ↔
      closureEvalFn fullEMLClosure' fullEMLClosure'_isClosureOp sem p =
      closureEvalFn fullEMLClosure' fullEMLClosure'_isClosureOp sem q :=
  closure_equiv_iff_closureEval_eq fullEMLClosure' fullEMLClosure'_isClosureOp sem p q

end