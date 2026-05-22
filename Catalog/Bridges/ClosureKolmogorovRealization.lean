import Mathlib

/-!
# Closure-Kolmogorov Realization Duality via Idempotent Hankel Semimodules

This file establishes a complete realization theory for closure-weighted transductions over
semirings—the analogue of Schützenberger–Fliess realization theory lifted to the
idempotent/closure setting. The core results:

1. **Reconstruction Correctness** (`reconstruction_correct`): A transducer built from a valid
   Hankel presentation faithfully realizes the original bi-series.
2. **Finite Realization** (`finite_closure_realization`): Every bi-series admitting a valid
   finite Hankel presentation is realized by a finite closure transducer.
3. **Reverse Construction** (`transducerToPresentation_valid`): Every transducer canonically
   induces a valid Hankel presentation of its behavior.
4. **Minimality** (`minimal_states_bound`): A minimal-dimension presentation yields a
   transducer with the fewest states among all realizations.
5. **Round-trip Stability** (`roundtrip_behavior`): Reconstruction from the induced
   presentation recovers the original behavior.
6. **Duality** (`duality_object_level`): Realizability by a transducer is equivalent to
   admitting a valid finite Hankel presentation.

## Mathematical Overview

Given a bi-series `f : List A → List B → S` over a semiring `S`, where `A` is the input
alphabet and `B` is the output alphabet, define the *bi-Hankel row* at `(u, v)` as the
function `(u', v') ↦ f(u ++ u', v ++ v')`. The *row semimodule* is the span of all such
rows. If it is finitely generated and stable under residual actions (prepending input/output
symbols), then `f` admits a *finite Hankel presentation*.

The **realization theorem** constructs a closure transducer with `n` states whose behavior
equals `f`. The **minimality theorem** shows this is optimal: no transducer can realize `f`
with fewer states than the minimal presentation dimension.

This is the closure-automata analogue of the Kalman–Schützenberger realization theorem.
-/

open Finset BigOperators

namespace ClosureKolmogorov

/-! ## Matrix-Vector Algebra -/

/-- Matrix-vector multiplication: `(M · v)_j = ∑_i M_{j,i} · v_i`. -/
def matVecMul {n : ℕ} {S : Type*} [Semiring S]
    (M : Fin n → Fin n → S) (v : Fin n → S) : Fin n → S :=
  fun j => ∑ i : Fin n, M j i * v i

/-- Dot product of two vectors: `v · w = ∑_i v_i · w_i`. -/
def dot {n : ℕ} {S : Type*} [Semiring S] (v w : Fin n → S) : S :=
  ∑ i : Fin n, v i * w i

/-- Process a list of symbols through action matrices (right fold):
    `runSymbols act [a₁, …, aₘ] w = act(a₁) · (act(a₂) · (⋯ · (act(aₘ) · w)))`. -/
def runSymbols {n : ℕ} {S : Type*} [Semiring S] {α : Type*}
    (act : α → Fin n → Fin n → S) : List α → (Fin n → S) → (Fin n → S)
  | [], w => w
  | a :: as, w => matVecMul (act a) (runSymbols act as w)

@[simp]
lemma runSymbols_nil {n : ℕ} {S : Type*} [Semiring S] {α : Type*}
    {act : α → Fin n → Fin n → S} {w : Fin n → S} :
    runSymbols act [] w = w := rfl

@[simp]
lemma runSymbols_cons {n : ℕ} {S : Type*} [Semiring S] {α : Type*}
    {act : α → Fin n → Fin n → S} {a : α} {as : List α} {w : Fin n → S} :
    runSymbols act (a :: as) w = matVecMul (act a) (runSymbols act as w) := rfl

/-! ## Closure Transducer -/

/-- A **closure transducer** with `n` states, input alphabet `A`, output alphabet `B`,
    and weights in a semiring `S`. -/
structure ClosureTransducer (A B S : Type*) [Semiring S] where
  /-- Number of states -/
  n : ℕ
  /-- Initial weight vector -/
  init : Fin n → S
  /-- Input symbol action matrices -/
  actA : A → Fin n → Fin n → S
  /-- Output symbol action matrices -/
  actB : B → Fin n → Fin n → S
  /-- Output (observation) weight vector -/
  out : Fin n → S

variable {A B S : Type*} [Semiring S]

/-- The **behavior** of a closure transducer on input word `u` and output word `v`. -/
def behavior (T : ClosureTransducer A B S) (u : List A) (v : List B) : S :=
  dot (runSymbols T.actA u (runSymbols T.actB v T.init)) T.out

/-! ## Hankel Presentation -/

/-- A **finite Hankel presentation** encodes the algebraic data needed to reconstruct a
    closure transducer from a bi-series. -/
structure HankelPresentation (A B S : Type*) [Semiring S] where
  /-- Basis dimension (number of generators) -/
  n : ℕ
  /-- Coefficient function decomposing each bi-Hankel row in the basis -/
  coeff : List A → List B → Fin n → S
  /-- Input residual action matrices -/
  actA : A → Fin n → Fin n → S
  /-- Output residual action matrices -/
  actB : B → Fin n → Fin n → S
  /-- Initial weight vector -/
  initVec : Fin n → S
  /-- Output weight vector -/
  outVec : Fin n → S

/-- A presentation `P` is **valid** for a bi-series `f` when the action tables and
    boundary vectors correctly decompose `f` through the coefficient function. -/
structure ValidPresentation (P : HankelPresentation A B S) (f : List A → List B → S) :
    Prop where
  /-- The initial vector equals the coefficient at the empty word pair -/
  init_eq : P.initVec = P.coeff [] []
  /-- Input residual compatibility: prepending `a` to the input acts by `actA a` -/
  input_compat : ∀ (a : A) (u : List A) (v : List B) (j : Fin P.n),
    P.coeff (a :: u) v j = ∑ i : Fin P.n, P.actA a j i * P.coeff u v i
  /-- Output residual compatibility at empty input -/
  output_compat : ∀ (b : B) (v : List B) (j : Fin P.n),
    P.coeff [] (b :: v) j = ∑ i : Fin P.n, P.actB b j i * P.coeff [] v i
  /-- Series recovery: `f(u,v) = coeff(u,v) · out` -/
  series_eq : ∀ (u : List A) (v : List B),
    f u v = dot (P.coeff u v) P.outVec

/-! ## Bi-Hankel Row -/

/-- The **bi-Hankel row** at `(u, v)`: the function `(u', v') ↦ f(u ++ u', v ++ v')`. -/
def BiHankelRow (f : List A → List B → S) (u : List A) (v : List B) :
    List A × List B → S :=
  fun p => f (u ++ p.1) (v ++ p.2)

/-! ## Reconstruction -/

/-- Build a closure transducer directly from a Hankel presentation. -/
def reconstructTransducer (P : HankelPresentation A B S) : ClosureTransducer A B S where
  n := P.n
  init := P.initVec
  actA := P.actA
  actB := P.actB
  out := P.outVec

@[simp]
lemma reconstructTransducer_n (P : HankelPresentation A B S) :
    (reconstructTransducer P).n = P.n := rfl

/-! ## Core Lemmas -/

/-
Output-symbol processing on the initial vector yields the empty-input coefficients.
-/
theorem runB_eq_coeff_nil {P : HankelPresentation A B S} {f : List A → List B → S}
    (hP : ValidPresentation P f) (v : List B) :
    runSymbols P.actB v P.initVec = P.coeff [] v := by
  induction' v with b v ih;
  · exact hP.init_eq;
  · convert congr_arg ( fun w => matVecMul ( P.actB b ) w ) ih using 1;
    exact funext fun j => hP.output_compat b v j

/-
The full run (input then output) computes the coefficient function exactly.
-/
theorem run_eq_coeff {P : HankelPresentation A B S} {f : List A → List B → S}
    (hP : ValidPresentation P f) (u : List A) (v : List B) :
    runSymbols P.actA u (runSymbols P.actB v P.initVec) = P.coeff u v := by
  induction' u with a u ih generalizing v <;> simp_all +decide [ runSymbols ]
  · exact runB_eq_coeff_nil hP v
  · exact funext fun j => hP.input_compat a u v j ▸ rfl

/-! ## Theorem 1: Reconstruction Correctness -/

/-
**Reconstruction Correctness Theorem.** The transducer built from a valid Hankel
    presentation faithfully realizes the original series.
-/
theorem reconstruction_correct {P : HankelPresentation A B S} {f : List A → List B → S}
    (hP : ValidPresentation P f) (u : List A) (v : List B) :
    behavior (reconstructTransducer P) u v = f u v := by
  convert hP.series_eq u v |> Eq.symm using 1;
  exact congr_arg₂ _ ( run_eq_coeff hP u v ) rfl

/-! ## Theorem 2: Finite Realization -/

/-- **Finite Realization Theorem.** Every bi-series admitting a valid finite Hankel
    presentation is realized by a finite closure transducer. -/
theorem finite_closure_realization
    {f : List A → List B → S}
    (P : HankelPresentation A B S)
    (hP : ValidPresentation P f) :
    ∃ T : ClosureTransducer A B S, ∀ u v, behavior T u v = f u v :=
  ⟨reconstructTransducer P, fun u v => reconstruction_correct hP u v⟩

/-- **Certified Reconstruction.** The reconstructed transducer realizes `f` with exactly
    `P.n` states. -/
theorem reconstruct_certified
    {f : List A → List B → S}
    (P : HankelPresentation A B S)
    (hP : ValidPresentation P f) :
    let T := reconstructTransducer P
    (∀ u v, behavior T u v = f u v) ∧ T.n = P.n :=
  ⟨fun u v => reconstruction_correct hP u v, rfl⟩

/-! ## Reverse Direction: Transducer → Presentation -/

/-- Construct a Hankel presentation from a transducer by recording state trajectories. -/
def transducerToPresentation (T : ClosureTransducer A B S) : HankelPresentation A B S where
  n := T.n
  coeff := fun u v => runSymbols T.actA u (runSymbols T.actB v T.init)
  actA := T.actA
  actB := T.actB
  initVec := T.init
  outVec := T.out

@[simp]
lemma transducerToPresentation_n (T : ClosureTransducer A B S) :
    (transducerToPresentation T).n = T.n := rfl

/-
**Reverse Validity Theorem.** The presentation derived from any transducer is
    valid for that transducer's behavior.
-/
theorem transducerToPresentation_valid (T : ClosureTransducer A B S) :
    ValidPresentation (transducerToPresentation T) (fun u v => behavior T u v) :=
  { init_eq := rfl,
    input_compat := fun _ _ _ => congrFun rfl,
    output_compat := fun _ _ => congrFun rfl,
    series_eq := fun _ => congrFun rfl }

/-! ## Theorem 3: Minimality -/

/-
**Minimality Theorem.** If `P` has the smallest dimension among all valid presentations
    of `f`, then every transducer realizing `f` has at least `P.n` states.
-/
theorem minimal_states_bound
    {f : List A → List B → S}
    (P : HankelPresentation A B S)
    (_hP : ValidPresentation P f)
    (hmin : ∀ Q : HankelPresentation A B S, ValidPresentation Q f → P.n ≤ Q.n)
    (T' : ClosureTransducer A B S)
    (hT' : ∀ u v, behavior T' u v = f u v) :
    P.n ≤ T'.n := by
  have := hmin (transducerToPresentation T') (by
    convert transducerToPresentation_valid T'
    exact funext fun u => funext fun v => hT' u v ▸ rfl)
  exact this

/-! ## Theorem 4: Round-trip Stability -/

/-
**Round-trip Theorem.** Reconstructing a transducer from its induced presentation
    recovers the original behavior.
-/
theorem roundtrip_behavior (T : ClosureTransducer A B S) (u : List A) (v : List B) :
    behavior (reconstructTransducer (transducerToPresentation T)) u v =
    behavior T u v := by
  unfold behavior reconstructTransducer transducerToPresentation;
  grind

/-! ## Theorem 5: Realization–Presentation Duality -/

/-
**Duality Theorem.** A bi-series is realizable by a finite closure transducer if and
    only if it admits a valid finite Hankel presentation.
-/
theorem duality_object_level (f : List A → List B → S) :
    (∃ T : ClosureTransducer A B S, ∀ u v, behavior T u v = f u v) ↔
    (∃ P : HankelPresentation A B S, ValidPresentation P f) := by
  constructor <;> intro h;
  · exact ⟨ _, by rw [ show f = _ from funext fun u => funext fun v => Eq.symm ( h.choose_spec u v ) ] ; exact transducerToPresentation_valid _ ⟩;
  · exact finite_closure_realization h.choose h.choose_spec

/-! ## Theorem 6: Minimal Realization Existence -/

/-- **Minimal Realization Existence.** Given a valid presentation `P` of minimal dimension,
    there exists a transducer with `P.n` states that realizes `f` and is state-minimal. -/
theorem minimal_realization_exists
    {f : List A → List B → S}
    (P : HankelPresentation A B S)
    (hP : ValidPresentation P f)
    (hmin : ∀ Q : HankelPresentation A B S, ValidPresentation Q f → P.n ≤ Q.n) :
    ∃ T : ClosureTransducer A B S,
      (∀ u v, behavior T u v = f u v) ∧
      T.n = P.n ∧
      ∀ T' : ClosureTransducer A B S,
        (∀ u v, behavior T' u v = f u v) → P.n ≤ T'.n := by
  exact ⟨reconstructTransducer P,
    fun u v => reconstruction_correct hP u v,
    rfl,
    fun T' hT' => minimal_states_bound P hP hmin T' hT'⟩

end ClosureKolmogorov