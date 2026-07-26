import Mathlib

/-! # Lifebox information-theoretic identity

This file models identity as observable behavior rather than physical substrate. It proves
that behavioral equivalence of initialized finite Moore machines is decidable, proves a
finite-test obstruction for unrestricted systems, formalizes the linear no-cloning
obstruction, and gives a precise conditional version of a finite description-complexity
bound.
-/

namespace LifeboxIdentity

/-- A deterministic finite-state system whose current state has an observable output. -/
structure MooreMachine (Input State Output : Type*) where
  step : State → Input → State
  observe : State → Output

namespace MooreMachine

variable {Input S T U Output : Type*}

/-- The state reached from `s` after processing a finite input word. -/
def runFrom (M : MooreMachine Input S Output) (s : S) (w : List Input) : S :=
  w.foldl M.step s

@[simp] theorem runFrom_nil (M : MooreMachine Input S Output) (s : S) :
    M.runFrom s [] = s := by
  simp [runFrom]

@[simp] theorem runFrom_cons (M : MooreMachine Input S Output) (s : S)
    (a : Input) (w : List Input) :
    M.runFrom s (a :: w) = M.runFrom (M.step s a) w := by
  simp [runFrom]

/-- Two initialized systems are person-equivalent when every finite experiment gives the
same observation. -/
def PersonEquiv (M : MooreMachine Input S Output) (N : MooreMachine Input T Output)
    (s : S) (t : T) : Prop :=
  ∀ w : List Input, M.observe (M.runFrom s w) = N.observe (N.runFrom t w)

@[refl] theorem PersonEquiv.refl (M : MooreMachine Input S Output) (s : S) :
    M.PersonEquiv M s s := by
  intro w
  rfl

/-- Behavioral identity is symmetric across different physical state spaces. -/
theorem PersonEquiv.symm (M : MooreMachine Input S Output)
    (N : MooreMachine Input T Output) {s : S} {t : T}
    (h : M.PersonEquiv N s t) : N.PersonEquiv M t s := by
  intro w
  exact (h w).symm

/-- Behavioral identity is transitive across three implementations. -/
theorem PersonEquiv.trans (M : MooreMachine Input S Output)
    (N : MooreMachine Input T Output) (P : MooreMachine Input U Output)
    {s : S} {t : T} {u : U} (hMN : M.PersonEquiv N s t)
    (hNP : N.PersonEquiv P t u) : M.PersonEquiv P s u := by
  intro w
  exact (hMN w).trans (hNP w)

/-- A Boolean relation is a bisimulation when it preserves observations and transitions. -/
def IsBisimulation (M : MooreMachine Input S Output) (N : MooreMachine Input T Output)
    (R : S → T → Bool) : Prop :=
  ∀ s t, R s t = true →
    M.observe s = N.observe t ∧ ∀ a, R (M.step s a) (N.step t a) = true

/-- A finite certificate of behavioral identity consists of a Boolean bisimulation
containing the two initial states. -/
def HasBisimulation (M : MooreMachine Input S Output) (N : MooreMachine Input T Output)
    (s : S) (t : T) : Prop :=
  ∃ R : S → T → Bool, R s t = true ∧ M.IsBisimulation N R

/-- Every bisimulation certificate implies equality of all finite observations. -/
theorem personEquiv_of_hasBisimulation
    (M : MooreMachine Input S Output) (N : MooreMachine Input T Output)
    {s : S} {t : T} (h : M.HasBisimulation N s t) : M.PersonEquiv N s t := by
  obtain ⟨R, hst, hR⟩ := h
  intro w
  induction w generalizing s t with
  | nil => exact (hR s t hst).1
  | cons a w ih =>
      simp only [runFrom_cons]
      exact ih ((hR s t hst).2 a)

/-- Equality of all finite observations itself defines a Boolean bisimulation. -/
theorem hasBisimulation_of_personEquiv
    (M : MooreMachine Input S Output) (N : MooreMachine Input T Output)
    {s : S} {t : T} (h : M.PersonEquiv N s t) : M.HasBisimulation N s t := by
  classical
  let R : S → T → Bool := fun x y => decide (M.PersonEquiv N x y)
  refine ⟨R, ?_, ?_⟩
  · simp [R, h]
  · intro x y hxy
    have htrace : M.PersonEquiv N x y := by
      simpa [R] using hxy
    constructor
    · exact htrace []
    · intro a
      simp only [R, decide_eq_true_eq]
      intro w
      exact htrace (a :: w)

/-- Behavioral identity is equivalent to the existence of a finite bisimulation table. -/
theorem personEquiv_iff_hasBisimulation
    (M : MooreMachine Input S Output) (N : MooreMachine Input T Output)
    (s : S) (t : T) :
    M.PersonEquiv N s t ↔ M.HasBisimulation N s t := by
  exact ⟨hasBisimulation_of_personEquiv M N,
    personEquiv_of_hasBisimulation M N⟩

/-- Behavioral identity of finite-state systems is decidable, despite quantifying over
infinitely many finite input histories. The decision procedure searches the finite space
of Boolean relations for a bisimulation certificate. -/
instance personEquivDecidable [Fintype Input] [Fintype S] [Fintype T]
    [DecidableEq Input] [DecidableEq S] [DecidableEq T] [DecidableEq Output]
    (M : MooreMachine Input S Output) (N : MooreMachine Input T Output)
    (s : S) (t : T) : Decidable (M.PersonEquiv N s t) := by
  rw [personEquiv_iff_hasBisimulation]
  unfold HasBisimulation IsBisimulation
  infer_instance

end MooreMachine

/-- No finite collection of probes decides extensional equality for arbitrary Boolean
systems on an infinite input space: two unequal systems can agree on every chosen probe. -/
theorem noFiniteProbeSet (probes : Finset ℕ) :
    ∃ f g : ℕ → Bool, (∀ n ∈ probes, f n = g n) ∧ f ≠ g := by
  obtain ⟨n, hn⟩ : ∃ n : ℕ, n ∉ probes := Finset.exists_notMem probes
  refine ⟨fun i => decide (i = n), fun _ => false, ?_, ?_⟩
  · intro i hi
    simp only [decide_eq_false_iff_not]
    intro hin
    exact hn (hin ▸ hi)
  · intro h
    have := congrFun h n
    simp at this

open scoped TensorProduct

/-- Linear no-cloning in dimension two: over any field, no linear operation sends every
vector `x` to the tensor square `x ⊗ x`. This is a copying obstruction, not by itself an
undecidability theorem. -/
theorem noLinearCloning (k : Type*) [Field k] :
    ¬ ∃ C : (k × k) →ₗ[k] (k × k) ⊗[k] (k × k),
      ∀ x, C x = x ⊗ₜ[k] x := by
  intro ⟨C, hC⟩
  have hlinear : C (1, 0) + C (0, 1) = C (1, 1) := by
    rw [← map_add]
    norm_num
  let B : (k × k) →ₗ[k] (k × k) →ₗ[k] k :=
    LinearMap.mk₂ k (fun a b => a.1 * b.2)
      (by simp [add_mul]) (by simp [mul_assoc])
      (by simp [mul_add]) (by simp [mul_left_comm])
  let detect : (k × k) ⊗[k] (k × k) →ₗ[k] k := TensorProduct.lift B
  rw [hC, hC, hC] at hlinear
  apply_fun detect at hlinear
  simp [detect, B] at hlinear

/-- A description scheme assigns finite bit strings to the identities they decode. -/
structure DescriptionScheme (Identity : Type*) where
  decode : List Bool → Option Identity

namespace DescriptionScheme

variable {Identity : Type*}

/-- The description complexity of an identity is the least length of a bit string that
decodes to it; it is zero when no description exists. -/
noncomputable def complexity (D : DescriptionScheme Identity) (x : Identity) : ℕ :=
  sInf {n : ℕ | ∃ code : List Bool, code.length = n ∧ D.decode code = some x}

/-- Every explicitly described identity has finite complexity, bounded by the length of
its exhibited description. -/
theorem complexity_le_code_length (D : DescriptionScheme Identity) (x : Identity)
    (code : List Bool) (hcode : D.decode code = some x) :
    D.complexity x ≤ code.length := by
  apply Nat.sInf_le
  exact ⟨code, rfl, hcode⟩

/-- If an identity has any description, a shortest description exists and realizes its
complexity exactly. -/
theorem exists_shortest_description (D : DescriptionScheme Identity) (x : Identity)
    (h : ∃ code : List Bool, D.decode code = some x) :
    ∃ code : List Bool, D.decode code = some x ∧ code.length = D.complexity x := by
  let lengths : Set ℕ := {n : ℕ | ∃ code : List Bool,
    code.length = n ∧ D.decode code = some x}
  have hne : lengths.Nonempty := by
    obtain ⟨code, hcode⟩ := h
    exact ⟨code.length, code, rfl, hcode⟩
  obtain ⟨code, hlen, hcode⟩ := Nat.sInf_mem hne
  exact ⟨code, hcode, by simpa [complexity, lengths] using hlen⟩

/-- The proposed `10^15`-bit Lifebox estimate has a precise conditional form: any identity
with an encoding of at most that length has description complexity at most `10^15`. -/
theorem lifeboxComplexityBound (D : DescriptionScheme Identity) (x : Identity)
    (code : List Bool) (hcode : D.decode code = some x)
    (hlen : code.length ≤ 10 ^ 15) :
    D.complexity x ≤ 10 ^ 15 := by
  exact (complexity_le_code_length D x code hcode).trans hlen

end DescriptionScheme

/-- There are exactly `2^b` fixed-length Boolean descriptions of length `b`. -/
theorem fixedLengthDescriptionCount (b : ℕ) :
    Fintype.card (Fin b → Bool) = 2 ^ b := by
  simp

end LifeboxIdentity