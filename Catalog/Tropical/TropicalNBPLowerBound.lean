import Mathlib

/-! # Tropical Certificate Lower Bounds for Nondeterministic Branching Programs

This file establishes a structural bridge between tropical (min-plus) certificate
complexity of Boolean functions and the size of nondeterministic branching programs (NBPs).

## Overview

The central insight is that each accepting computation path in an NBP encodes a
"compressed witness" — a partial assignment that forces the function to accept.
When measured in the min-plus (tropical) semiring, the cost of such witnesses
provides information-theoretic lower bounds on the number of states required.

## Main definitions

* `BoolFun n` — Boolean functions on `n` variables
* `PartialAssign n` — partial assignments to Boolean variables
* `tropicalCost` — weighted cost of a partial assignment in the min-plus semiring
* `MinAccCertCost` — predicate: all accepting certificates have cost ≥ L
* `NBP S n` — nondeterministic branching programs with `S` states over `n` variables
* `pathVars` — variables queried along a path
* `pathCertificateOf` — certificate extracted from an accepting path

## Main results

* `pathCert_forces` — path certificates force the function value (the fulcrum lemma)
* `pow_div_le_of_le_mul_log` — arithmetic core of the exponential lower bound
* `tropical_nbp_size_lower_bound` — conditional exponential size lower bound
* `acyclic_path_length_le` — path length bound in acyclic NBPs
* `acyclic_tropical_cost_le` — linear cost bound for acyclic NBP paths
* `acyclic_nbp_linear_lower_bound` — unconditional linear lower bound
-/

noncomputable section
open Finset

-- ============================================================================
-- § 1. Boolean Functions and Partial Assignments
-- ============================================================================

/-- A Boolean function on `n` variables. -/
abbrev BoolFun (n : ℕ) := (Fin n → Bool) → Bool

/-- A partial assignment to Boolean variables indexed by `Fin n`.
    `dom` specifies which variables are assigned; `val` gives the value
    (the value at indices outside `dom` is irrelevant). -/
structure PartialAssign (n : ℕ) where
  /-- The set of assigned variables -/
  dom : Finset (Fin n)
  /-- The assigned values -/
  val : Fin n → Bool

namespace PartialAssign

/-- A partial assignment σ **agrees** with a total assignment x
    if x extends σ on its domain. -/
def Agrees {n : ℕ} (σ : PartialAssign n) (x : Fin n → Bool) : Prop :=
  ∀ i ∈ σ.dom, σ.val i = x i

/-- σ **forces** f to value b if every total assignment extending σ
    evaluates f to b. This is the key notion connecting certificates
    to Boolean function behavior. -/
def Forces {n : ℕ} (σ : PartialAssign n) (f : BoolFun n) (b : Bool) : Prop :=
  ∀ x : Fin n → Bool, σ.Agrees x → f x = b

/-- The full assignment that assigns x(i) to every variable. -/
def full {n : ℕ} (x : Fin n → Bool) : PartialAssign n where
  dom := Finset.univ
  val := x

/-- The full assignment agrees with x. -/
theorem full_agrees {n : ℕ} (x : Fin n → Bool) : (full x).Agrees x :=
  fun _ _ => rfl

/-- The full assignment forces f to its value at x. -/
theorem full_forces {n : ℕ} (f : BoolFun n) (x : Fin n → Bool) :
    (full x).Forces f (f x) := by
  intro y hy
  congr 1; ext i; exact (hy i (Finset.mem_univ i)).symm

/-- Superset domains preserve agreement: if σ₁ ⊆ σ₂ with matching values,
    then agreement with σ₂ implies agreement with σ₁. -/
theorem agrees_of_subset {n : ℕ} {σ₁ σ₂ : PartialAssign n}
    (hdom : σ₁.dom ⊆ σ₂.dom) (hval : ∀ i ∈ σ₁.dom, σ₁.val i = σ₂.val i)
    {x : Fin n → Bool} (h : σ₂.Agrees x) : σ₁.Agrees x := by
  intro i hi
  rw [hval i hi]
  exact h i (hdom hi)

end PartialAssign

-- ============================================================================
-- § 2. Tropical Certificate Cost
-- ============================================================================

/-- **Tropical cost** of a partial assignment under weight function w.
    This is the additive cost in the min-plus semiring: the sum of weights
    of all assigned coordinates.

    The terminology "tropical" reflects that certificate complexity is
    measured in the min-plus algebra: we minimize over certificates
    (min operation) and sum weights within a certificate (plus operation). -/
def tropicalCost {n : ℕ} (w : Fin n → ℕ) (σ : PartialAssign n) : ℕ :=
  ∑ i ∈ σ.dom, w i

/-- Tropical cost is monotone in the domain: larger domains cost more. -/
theorem tropicalCost_le_of_dom_subset {n : ℕ} (w : Fin n → ℕ)
    {s₁ s₂ : Finset (Fin n)} (h : s₁ ⊆ s₂) :
    ∑ i ∈ s₁, w i ≤ ∑ i ∈ s₂, w i :=
  Finset.sum_le_sum_of_subset_of_nonneg h (fun _ _ _ => Nat.zero_le _)

/-- Tropical cost is bounded by dom.card times the maximum weight. -/
theorem tropicalCost_le_card_mul_max {n : ℕ} (w : Fin n → ℕ) (σ : PartialAssign n)
    (W : ℕ) (hW : ∀ i ∈ σ.dom, w i ≤ W) :
    tropicalCost w σ ≤ σ.dom.card * W := by
  exact Finset.sum_le_card_nsmul σ.dom w W hW

/-- **All accepting certificates have tropical cost at least L.**
    This is the key hardness measure: it says the function f has no
    cheap witness for acceptance under the weight function w. -/
def MinAccCertCost {n : ℕ} (f : BoolFun n) (w : Fin n → ℕ) (L : ℕ) : Prop :=
  ∀ σ : PartialAssign n, σ.Forces f true → L ≤ tropicalCost w σ

-- ============================================================================
-- § 3. Nondeterministic Branching Programs
-- ============================================================================

/-- An edge in a nondeterministic branching program.
    Reading: "at state `src`, query variable `var`; if the value equals `val`,
    transition to state `tgt`." -/
@[ext]
structure NBPEdge (S n : ℕ) where
  src : Fin S
  var : Fin n
  val : Bool
  tgt : Fin S
deriving DecidableEq

/-- A nondeterministic branching program with `S` states over `n` variables.
    Acceptance is **existential**: input x is accepted iff there exists a
    start-to-accept path whose labels are consistent with x. -/
structure NBP (S n : ℕ) where
  start : Fin S
  accept : Fin S
  edges : Finset (NBPEdge S n)

/-- A path in an NBP is a finite sequence of edges. -/
abbrev NBPPath (S n : ℕ) := List (NBPEdge S n)

/-- A path is **well-formed** if each edge belongs to the NBP
    and consecutive edges connect (target of one = source of next). -/
def NBP.ValidPath {S n : ℕ} (B : NBP S n) : NBPPath S n → Prop
  | [] => True
  | [e] => e ∈ B.edges
  | e₁ :: e₂ :: rest => e₁ ∈ B.edges ∧ e₁.tgt = e₂.src ∧ B.ValidPath (e₂ :: rest)

/-- The starting state of a path (source of the first edge). -/
def pathStartState {S n : ℕ} (p : NBPPath S n) : Option (Fin S) :=
  p.head?.map NBPEdge.src

/-- The ending state of a path (target of the last edge). -/
def pathEndState {S n : ℕ} (p : NBPPath S n) : Option (Fin S) :=
  p.getLast?.map NBPEdge.tgt

/-- A path is **accepting** if it is valid, nonempty, starts at the
    start state, and ends at the accept state. -/
def NBP.AcceptingPath {S n : ℕ} (B : NBP S n) (p : NBPPath S n) : Prop :=
  B.ValidPath p ∧ p ≠ [] ∧
  pathStartState p = some B.start ∧
  pathEndState p = some B.accept

/-- A path is **consistent** with input x if every edge label matches x. -/
def pathConsistent {S n : ℕ} (p : NBPPath S n) (x : Fin n → Bool) : Prop :=
  ∀ e ∈ p, x e.var = e.val

/-- The NBP **accepts** input x iff there exists an accepting path
    consistent with x. This is the existential nondeterministic semantics. -/
def NBP.Accepts {S n : ℕ} (B : NBP S n) (x : Fin n → Bool) : Prop :=
  ∃ p : NBPPath S n, B.AcceptingPath p ∧ pathConsistent p x

/-- The NBP **computes** Boolean function f: f(x)=true iff B accepts x. -/
def NBP.Computes {S n : ℕ} (B : NBP S n) (f : BoolFun n) : Prop :=
  ∀ x, f x = true ↔ B.Accepts x

/-- An NBP is **acyclic** if all edges go from strictly lower to
    strictly higher state indices. This ensures all paths are finite
    with length at most S - 1. -/
def NBP.IsAcyclic {S n : ℕ} (B : NBP S n) : Prop :=
  ∀ e ∈ B.edges, e.src.val < e.tgt.val

-- ============================================================================
-- § 4. Path Certificate Extraction
-- ============================================================================

/-- The set of variables queried along a path. -/
def pathVars {S n : ℕ} (p : NBPPath S n) : Finset (Fin n) :=
  (p.map NBPEdge.var).toFinset

/-- The partial assignment induced by a path, using total assignment x
    for values. For a path consistent with x, this gives a valid certificate.

    This is the key construction bridging NBP paths and tropical certificates:
    each accepting path becomes a weighted witness in the min-plus semiring. -/
def pathCertificateOf {S n : ℕ} (p : NBPPath S n) (x : Fin n → Bool) :
    PartialAssign n where
  dom := pathVars p
  val := x

-- ============================================================================
-- § 5. Path Certificate Extraction Theorem (The Fulcrum)
-- ============================================================================

/-- If a path is consistent with x, then the path certificate agrees with x.
    (This is immediate since the certificate uses x as its value function.) -/
theorem pathCert_agrees {S n : ℕ} (p : NBPPath S n) (x : Fin n → Bool) :
    (pathCertificateOf p x).Agrees x :=
  fun _ _ => rfl

/-
**Path Certificate Extraction Theorem (The Fulcrum).**

    If an NBP computes f and p is an accepting path consistent with x,
    then the path certificate forces f to `true`.

    *Proof idea:* For any y agreeing with the path certificate, y matches x
    on all queried variables. Hence p is also consistent with y, so the NBP
    accepts y, so f(y) = true.
-/
theorem pathCert_forces {S n : ℕ} {B : NBP S n} {f : BoolFun n}
    {p : NBPPath S n} {x : Fin n → Bool}
    (hcomp : B.Computes f)
    (hacc : B.AcceptingPath p)
    (hcons : pathConsistent p x) :
    (pathCertificateOf p x).Forces f true := by
  -- By definition of pathCertificateOf, if y agrees with pathCertificateOf p x on its domain (pathVars p), then y matches x on all variables queried by the path p.
  intros y hy
  have hpy : pathConsistent p y := by
    intro e he; have := hy e.var; simp_all +decide [ pathCertificateOf ] ;
    exact this ( Finset.mem_coe.mpr <| List.mem_toFinset.mpr <| List.mem_map.mpr ⟨ e, he, rfl ⟩ ) ▸ hcons e he ▸ rfl;
  exact hcomp y |>.2 ⟨ p, hacc, hpy ⟩

/-
============================================================================
§ 6. Arithmetic Core of the Lower Bound
============================================================================

**Arithmetic lemma.** If `L ≤ C * Nat.log 2 S` with `C > 0` and `S > 0`,
    then `2^(L/C) ≤ S`.

    This is the numerical engine of the lower bound: it converts
    the tropical cost gap into an exponential size requirement.
-/
theorem pow_div_le_of_le_mul_log {L C S : ℕ} (hC : 0 < C) (hS : 0 < S)
    (h : L ≤ C * Nat.log 2 S) : 2 ^ (L / C) ≤ S := by
  exact le_trans ( Nat.pow_le_pow_right ( by decide ) ( Nat.div_le_div_right h ) ) ( by rw [ Nat.mul_div_cancel_left _ hC ] ; exact Nat.pow_log_le_self 2 hS.ne' )

/-
============================================================================
§ 7. Main Conditional Lower Bound Theorem
============================================================================

**Main Theorem: Tropical Certificate Lower Bound for NBP Size.**

    If every accepting certificate for f has tropical cost at least L,
    and every accepting path in an NBP computing f yields a certificate
    of cost at most `C * log₂(S)`, then the NBP must have at least
    `2^(L/C)` states.

    The hypothesis `hpath` encodes the structural property of the specific
    NBP class (read-once, layered, etc.). The theorem shows that high
    tropical certificate complexity forces exponential branching-program size.

    This theorem creates a new lower-bound paradigm: tropical certificate
    complexity → NBP size lower bounds, mediated by the min-plus semiring.
-/
theorem tropical_nbp_size_lower_bound
    {S n : ℕ} (f : BoolFun n) (w : Fin n → ℕ) (L : ℕ) (B : NBP S n)
    (C : ℕ) (hC : 0 < C)
    (hcomp : B.Computes f)
    (hcert : MinAccCertCost f w L)
    (hpath : ∀ p x, B.AcceptingPath p → pathConsistent p x →
      tropicalCost w (pathCertificateOf p x) ≤ C * Nat.log 2 S)
    (hnonempty : ∃ x, f x = true) :
    2 ^ (L / C) ≤ S := by
  -- By definition of `NBP.Computes`, B accepts x, so get accepting path p with pathConsistent p x.
  obtain ⟨x, hx⟩ := hnonempty
  obtain ⟨p, hp⟩ : ∃ p : NBPPath S n, B.AcceptingPath p ∧ pathConsistent p x := by
    exact hcomp x |>.1 hx;
  apply pow_div_le_of_le_mul_log hC;
  · linarith [ Fin.is_lt B.start ];
  · exact le_trans ( hcert _ ( pathCert_forces hcomp hp.1 hp.2 ) ) ( hpath _ _ hp.1 hp.2 )

/-
============================================================================
§ 8. Acyclic NBP Path Bounds
============================================================================

In an acyclic NBP, every valid path visits distinct states (by strict
    monotonicity of state indices), so path length ≤ S.
-/
theorem acyclic_path_length_le {S n : ℕ} {B : NBP S n}
    (hacyclic : B.IsAcyclic) (p : NBPPath S n) (hvalid : B.ValidPath p) :
    p.length ≤ S := by
  -- By induction on the path p, we can show that the length of the path is at most S.
  induction' p with e p ih;
  · grind +splitImp;
  · rcases p with ( _ | ⟨ f, p ⟩ ) <;> simp_all +decide;
    · rcases S with ( _ | _ | S ) <;> norm_num at *;
      exact Fin.elim0 e.src;
    · have h_ind : ∀ (p : NBPPath S n), B.ValidPath p → ∀ (k : Fin S), p.head?.map NBPEdge.src = some k → p.length ≤ S - k.val := by
        intros p hp k hk;
        induction' p with e p ih generalizing k;
        · cases hk;
        · rcases p with ( _ | ⟨ f, p ⟩ ) <;> simp_all +decide;
          · exact Nat.sub_pos_of_lt ( Fin.is_lt k );
          · grind +locals;
      have := h_ind ( e :: f :: p ) ( by tauto ) e.src ( by aesop ) ; simp_all +decide [ Nat.sub_sub ] ;
      exact this.trans_le ( Nat.sub_le _ _ )

/-
The number of queried variables on a path is at most the path length.
-/
theorem pathVars_card_le_length {S n : ℕ} (p : NBPPath S n) :
    (pathVars p).card ≤ p.length := by
  exact le_trans ( Finset.card_le_card ( show _ ⊆ ( p.map NBPEdge.var ).toFinset from Finset.Subset.refl _ ) ) ( List.toFinset_card_le _ ) |> le_trans <| by simp +decide ;

/-
**Cost bound for acyclic NBPs.**
    In an acyclic NBP, the tropical cost of any accepting path's certificate
    is at most `S * W_max`, where `W_max` is the maximum weight.
-/
theorem acyclic_tropical_cost_le {S n : ℕ} {B : NBP S n}
    (w : Fin n → ℕ) (W : ℕ) (hW : ∀ i, w i ≤ W)
    (hacyclic : B.IsAcyclic)
    (p : NBPPath S n) (x : Fin n → Bool)
    (hvalid : B.ValidPath p) :
    tropicalCost w (pathCertificateOf p x) ≤ S * W := by
  refine' le_trans ( tropicalCost_le_card_mul_max _ _ _ _ ) _;
  exact W;
  · aesop;
  · exact Nat.mul_le_mul_right _ ( by simpa using pathVars_card_le_length p |> le_trans <| acyclic_path_length_le hacyclic p hvalid )

/-
============================================================================
§ 9. Unconditional Linear Lower Bound for Acyclic NBPs
============================================================================

**Linear Lower Bound for Acyclic NBPs.**

    If every accepting certificate has tropical cost at least L, and
    the maximum weight is W > 0, then any acyclic NBP computing f
    has at least ⌈L / W⌉ states.

    This is the first unconditional lower bound connecting tropical
    certificates to branching-program size. While linear rather than
    exponential, it establishes the fundamental structural link.
-/
theorem acyclic_nbp_linear_lower_bound
    {S n : ℕ} (f : BoolFun n) (w : Fin n → ℕ) (L : ℕ)
    (B : NBP S n) (W : ℕ) (hW : ∀ i, w i ≤ W) (_hWpos : 0 < W)
    (hcomp : B.Computes f)
    (hcert : MinAccCertCost f w L)
    (hacyclic : B.IsAcyclic)
    (hnonempty : ∃ x, f x = true) :
    L / W ≤ S := by
  obtain ⟨ x, hx ⟩ := hnonempty;
  -- By hcomp, B accepts x, get accepting path p consistent with x.
  obtain ⟨ p, hpacc, hpcons ⟩ : ∃ p : NBPPath S n, B.AcceptingPath p ∧ pathConsistent p x := by
    exact hcomp x |>.1 hx;
  -- By pathCert_forces, the path certificate forces f to true.
  have hpathcert : (pathCertificateOf p x).Forces f true := by
    exact pathCert_forces hcomp hpacc hpcons;
  -- By acyclic_tropical_cost_le, tropicalCost ≤ S * W.
  have htropicalcost : tropicalCost w (pathCertificateOf p x) ≤ S * W :=
    acyclic_tropical_cost_le w W hW hacyclic p x hpacc.1
  exact Nat.div_le_of_le_mul <| by linarith [ hcert _ hpathcert ] ;

/-
============================================================================
§ 10. Tropical Cost Composition and Refinement
============================================================================

**Tropical additivity:** the cost of a certificate over a disjoint union
    of variable sets equals the sum of costs over each part.
-/
theorem tropicalCost_union {n : ℕ} (w : Fin n → ℕ)
    (s₁ s₂ : Finset (Fin n)) (hdisj : Disjoint s₁ s₂) :
    ∑ i ∈ s₁ ∪ s₂, w i = ∑ i ∈ s₁, w i + ∑ i ∈ s₂, w i := by
  exact Finset.sum_union hdisj

/-
A certificate with all unit weights has cost equal to its domain size.
    This connects tropical certificate complexity to classical certificate complexity.
-/
theorem tropicalCost_unit_weights {n : ℕ} (σ : PartialAssign n) :
    tropicalCost (fun _ => 1) σ = σ.dom.card := by
  -- Apply the fact that the sum of a constant function over a finite set is the constant times the cardinality of the set.
  simp [tropicalCost, Finset.sum_const]

end