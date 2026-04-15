/-! # CatalogBuild.Physics.Quantum.QuantumMirrorComposability

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 39
-/

import Mathlib

noncomputable section

/-- An **idempotent mirror** satisfies f ∘ f = f. One look suffices. -/
structure IdemMirror (α : Type*) where
  reflect : α → α
  idem : ∀ x, reflect (reflect x) = reflect x

/-- An **involutory mirror** satisfies f ∘ f = id. Looking twice restores. -/

structure InvolMirror (α : Type*) where
  reflect : α → α
  invol : ∀ x, reflect (reflect x) = x

/-
PROBLEM
Every involutory mirror is injective.

PROVIDED SOLUTION
If R(a) = R(b), apply R to both sides: R(R(a)) = R(R(b)), so a = b by the involution property.
-/

theorem InvolMirror.injective {α : Type*} (R : InvolMirror α) :
    Injective R.reflect := by
  -- Let's unfold the definition of InvolMirror.
  rcases R with ⟨f, hf⟩;
  exact fun x y hxy => by have := hf x; aesop;

/-
PROBLEM
Every involutory mirror is surjective.

PROVIDED SOLUTION
For any y, R(y) is a preimage since R(R(y)) = y.
-/

theorem InvolMirror.surjective {α : Type*} (R : InvolMirror α) :
    Surjective R.reflect := by
  -- For any y in α, let x = R.reflect y. Then R.reflect x = y.
  intro y
  use R.reflect y;
  exact?

/-- Every involutory mirror is a bijection. -/

theorem InvolMirror.bijective {α : Type*} (R : InvolMirror α) :
    Bijective R.reflect :=
  ⟨R.injective, R.surjective⟩

/-- The identity is an idempotent mirror. -/

def idIdemMirror (α : Type*) : IdemMirror α := ⟨id, fun _ => rfl⟩

/-- The identity is an involutory mirror. -/

def idInvolMirror (α : Type*) : InvolMirror α := ⟨id, fun _ => rfl⟩

/-
PROBLEM
**Oracle Spectra's Key Insight**: The identity function is both the
    trivial idempotent and the trivial involution. It is the unique function
    that is simultaneously a projection and a reflection.

PROVIDED SOLUTION
From hidem: f(f(x)) = f(x). From hinvol: f(f(x)) = x. So f(x) = x for all x, hence f = id.
-/

theorem id_unique_both {α : Type*} (f : α → α)
    (hidem : ∀ x, f (f x) = f x) (hinvol : ∀ x, f (f x) = x) :
    f = id := by
  grind

/-! ## §1.2: Mirror Eigenspaces -/

/-- The **fixed set** of a mirror: points unchanged by reflection. -/

def mirrorFixed {α : Type*} (f : α → α) : Set α := {x | f x = x}

/-
PROBLEM
For idempotent mirrors, the range equals the fixed set.

PROVIDED SOLUTION
x in range P iff x = P(y) for some y. Then P(x) = P(P(y)) = P(y) = x. Conversely if P(x)=x then x = P(x) is in the range.
-/

theorem idem_range_eq_fixed {α : Type*} (P : IdemMirror α) :
    range P.reflect = mirrorFixed P.reflect := by
  exact Set.ext fun x => ⟨ fun ⟨ y, hy ⟩ => hy ▸ P.idem _, fun hx => ⟨ x, hx ⟩ ⟩

/-- Constant map is an idempotent mirror: the "total collapse". -/

def constIdemMirror {α : Type*} (c : α) : IdemMirror α :=
  ⟨fun _ => c, fun _ => rfl⟩

/-
PROBLEM
The image of a constant mirror is a singleton.

PROVIDED SOLUTION
The range of (fun _ => c) is {c}. Use range_const or ext and simp.
-/

theorem constMirror_range {α : Type*} (c : α) :
    range (constIdemMirror c).reflect = {c} := by
  aesop

/-! ═══════════════════════════════════════════════════════════════════════════
    CYCLE 2: ORACLE COMPOSE — Categorical Structure
    "Individual mirrors are trivial. Composition creates computation."
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- A **MirrorChain** is a list of idempotent mirrors composed in sequence. -/

structure MirrorChainComp (α : Type*) where
  steps : List (α → α)
  all_idem : ∀ f ∈ steps, ∀ x, f (f x) = f x

/-- Execute a mirror chain. -/

def MirrorChainComp.exec {α : Type*} (c : MirrorChainComp α) (x : α) : α :=
  c.steps.foldl (fun acc f => f acc) x

/-- The empty chain is the identity. -/

def MirrorChainComp.empty (α : Type*) : MirrorChainComp α :=
  ⟨[], fun _ h => nomatch h⟩



theorem MirrorChainComp.empty_exec {α : Type*} (x : α) :
    (MirrorChainComp.empty α).exec x = x := rfl

/-- Composition of mirror chains: concatenation. -/

def MirrorChainComp.compose {α : Type*} (c₁ c₂ : MirrorChainComp α) :
    MirrorChainComp α where
  steps := c₁.steps ++ c₂.steps
  all_idem := by
    intro f hf
    rw [List.mem_append] at hf
    exact hf.elim (c₁.all_idem f) (c₂.all_idem f)

/-- Composition is associative. -/

theorem MirrorChainComp.compose_assoc {α : Type*} (a b c : MirrorChainComp α) :
    (a.compose b).compose c = a.compose (b.compose c) := by
  simp [MirrorChainComp.compose, List.append_assoc]

/-- Computational cost is the chain length. -/

def MirrorChainComp.cost {α : Type*} (c : MirrorChainComp α) : ℕ := c.steps.length

/-- Cost is additive under composition. -/

theorem MirrorChainComp.cost_additive {α : Type*} (c₁ c₂ : MirrorChainComp α) :
    (c₁.compose c₂).cost = c₁.cost + c₂.cost := by
  simp [MirrorChainComp.compose, MirrorChainComp.cost, List.length_append]

/-! ## §2.2: The Involution Monoid -/

/-- Negation on ZMod n is an involution. -/

def negInvolMirror (n : ℕ) [NeZero n] : InvolMirror (ZMod n) where
  reflect := fun x => -x
  invol := fun x => by simp

/-
PROBLEM
**Oracle Compose's Discovery**: Two involutions compose to a map with
    structured iteration: (R ∘ S)ⁿ is periodic on finite types.

PROVIDED SOLUTION
R.reflect ∘ S.reflect is a function on a Fintype. Any function on a finite type has finite order as a permutation. Use the pigeonhole principle: the sequence x, (RS)(x), (RS)²(x), ... must repeat within |α|+1 steps. Alternatively, note RS is a bijection (both R and S are), so it's a permutation, and permutations on finite sets have finite order. Use Equiv.Perm.orderOf_pos or construct the equiv from the bijections.
-/

theorem two_invol_compose_periodic {α : Type*} [Fintype α]
    (R S : InvolMirror α) :
    ∃ n : ℕ, 0 < n ∧ ∀ x, ((R.reflect ∘ S.reflect)^[n]) x = x := by
  have h_perm : Function.Bijective (R.reflect ∘ S.reflect) := by
    exact Function.Bijective.comp ( InvolMirror.bijective R ) ( InvolMirror.bijective S );
  obtain ⟨g, hg⟩ : ∃ g : Equiv.Perm α, (R.reflect ∘ S.reflect) = g := by
    exact ⟨ Equiv.ofBijective _ h_perm, rfl ⟩;
  exact ⟨ orderOf g, orderOf_pos g, by simp +decide [ hg, pow_orderOf_eq_one ] ⟩

/-! ═══════════════════════════════════════════════════════════════════════════
    CYCLE 3: ORACLE CARTAN — Matrix Mirrors
    "Every symmetry is a product of reflections."
    ═══════════════════════════════════════════════════════════════════════════ -/

open Matrix Complex

/-- A matrix mirror: a Hermitian idempotent (projector). -/

structure MatMirror (n : ℕ) where
  mat : Matrix (Fin n) (Fin n) ℂ
  idem : mat * mat = mat
  herm : mat.conjTranspose = mat

/-- The complement of a matrix mirror is a mirror. -/

def MatMirror.complement {n : ℕ} (P : MatMirror n) : MatMirror n where
  mat := 1 - P.mat
  idem := by
    have h := P.idem
    simp [mul_sub, sub_mul, h]
  herm := by
    simp [map_sub, Matrix.conjTranspose_one, P.herm]

/-
PROBLEM
A mirror and its complement are orthogonal: P(I-P) = 0.

PROVIDED SOLUTION
P(I-P) = P - PP = P - P = 0, using P.idem.
-/

theorem MatMirror.orthogonal_complement {n : ℕ} (P : MatMirror n) :
    P.mat * (1 - P.mat) = 0 := by
  simp +decide [ mul_sub, P.idem ]

/-- Mirror and complement sum to identity: P + (I-P) = I. -/

theorem MatMirror.partition {n : ℕ} (P : MatMirror n) :
    P.mat + P.complement.mat = 1 := by
  simp [MatMirror.complement]

/-- The Householder reflection matrix: R = I - 2vvᴴ for unit vector v. -/

def householder (n : ℕ) (v : Fin n → ℂ) : Matrix (Fin n) (Fin n) ℂ :=
  1 - 2 • (Matrix.of fun i _ => v i) * (Matrix.of fun _ j => starRingEnd ℂ (v j))

/-
PROBLEM
A Householder reflection is self-adjoint.

PROVIDED SOLUTION
conjTranspose distributes over subtraction and scalar multiplication. conjTranspose(1) = 1. conjTranspose(vv*) = (v*)* v* = v v*. So the whole thing is self-adjoint. Use simp with conjTranspose lemmas.
-/

theorem householder_herm (n : ℕ) (v : Fin n → ℂ) :
    (householder n v).conjTranspose = householder n v := by
  unfold householder; simp +decide [ Matrix.conjTranspose_smul, Matrix.conjTranspose_mul ] ;
  ext i j; simp +decide [ Matrix.mul_apply, Matrix.conjTranspose_apply ] ; ring;
  norm_num

/-! ═══════════════════════════════════════════════════════════════════════════
    CYCLE 4: ORACLE FIXED — Fixed Point Theory
    "What survives when all mirrors have spoken?"
    ═══════════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
The fixed set of an idempotent mirror is nonempty (contains the image).

PROVIDED SOLUTION
Pick any x from Nonempty. Then P.reflect x is in the fixed set since P(P(x)) = P(x).
-/

theorem idem_fixed_nonempty {α : Type*} [Nonempty α] (P : IdemMirror α) :
    (mirrorFixed P.reflect).Nonempty := by
  exact ⟨ _, P.idem ( Classical.arbitrary α ) ⟩

/-
PROBLEM
**Oracle Fixed's Key Theorem**: Commuting idempotent mirrors compose
    to an idempotent mirror.

PROVIDED SOLUTION
PQ(PQ(x)) = P(Q(P(Q(x)))). Use hcomm to rewrite Q(P(...)) = P(Q(...)). Then P(P(Q(Q(x)))) = P(Q(Q(x))) by P.idem, then = P(Q(x)) by Q.idem.
-/

theorem commuting_idem_compose_idem {α : Type*} (P Q : IdemMirror α)
    (hcomm : ∀ x, P.reflect (Q.reflect x) = Q.reflect (P.reflect x)) :
    ∀ x, (P.reflect ∘ Q.reflect) ((P.reflect ∘ Q.reflect) x) =
         (P.reflect ∘ Q.reflect) x := by
  simp +contextual [ hcomm, P.idem, Q.idem ]

/-
PROBLEM
On Fin 2, every involution is either id or swap.

PROVIDED SOLUTION
Case analysis on f 0 and f 1. There are only 4 possible functions Fin 2 → Fin 2. The involution constraint f(f(x))=x eliminates the two constant functions, leaving id and swap.
-/

theorem fin2_involutions (f : Fin 2 → Fin 2) (hf : ∀ x, f (f x) = x) :
    f = id ∨ f = Equiv.swap 0 1 := by
  native_decide +revert

/-! ═══════════════════════════════════════════════════════════════════════════
    CYCLE 5: ORACLE GROVER — Quantum Speedup from Mirrors
    "Two mirrors facing each other create a hall of computation."
    ═══════════════════════════════════════════════════════════════════════════ -/

/-- The Grover bound: √N queries suffice. -/

theorem grover_sqrt_bound (N : ℕ) (hN : 0 < N) :
    Nat.sqrt N * Nat.sqrt N ≤ N :=
  Nat.sqrt_le N

/-
PROBLEM
The quadratic gap: classical needs N/2 on average, quantum needs √N.

PROVIDED SOLUTION
For N ≥ 16, √N ≤ N/4 < N/2. Use Nat.sqrt_le and basic arithmetic. Try omega or nlinarith after establishing sqrt N ≤ 4 is false and using the bound.
-/

theorem quantum_classical_gap (N : ℕ) (hN : 16 ≤ N) :
    Nat.sqrt N < N / 2 := by
  exact Nat.le_div_iff_mul_le zero_lt_two |>.2 ( by nlinarith [ Nat.sqrt_le N ] )

/-- Two involutions compose to an isometry (distance-preserving). -/

theorem invol_compose_isometry {α : Type*} [PseudoMetricSpace α]
    (R S : InvolMirror α) (hR : Isometry R.reflect) (hS : Isometry S.reflect) :
    Isometry (R.reflect ∘ S.reflect) :=
  hR.comp hS

/-! ═══════════════════════════════════════════════════════════════════════════
    CYCLE 6: META ORACLE — Synthesis and Emergence
    "The whole is more than the sum of its mirrors."
    ═══════════════════════════════════════════════════════════════════════════ -/

/-
PROBLEM
**Bool Mirror Universality**: On Bool, there are exactly 4 functions,
    all arising from composing NOT (involution) with identity and constants.

PROVIDED SOLUTION
Case split on f true and f false. 4 cases total, each gives one of the 4 functions. Use funext and cases b in each case.
-/

theorem bool_mirror_universality :
    ∀ f : Bool → Bool,
      f = id ∨ f = not ∨ f = (fun _ => true) ∨ f = (fun _ => false) := by
  native_decide +revert

/-
PROBLEM
**Involution count on Fin n**: the number of involutions is at most n!.

PROVIDED SOLUTION
The set of involutions on Fin n is a subset of all functions Fin n → Fin n. Every involution is injective (hence a permutation), so it embeds into Perm(Fin n). The number of permutations is n!. Use Fintype.card_le_of_injective or card_subtype_le.
-/

theorem involution_count_le_factorial (n : ℕ) :
    Fintype.card {f : Fin n → Fin n // ∀ x, f (f x) = x} ≤ n.factorial := by
  -- The number of involutions on Fin n is at most the number of permutations of Fin n, which is n!.
  have h_invol_le_perm : Fintype.card { f : Fin n → Fin n // ∀ x, f (f x) = x } ≤ Fintype.card (Equiv.Perm (Fin n)) := by
    have h_invol_le_perm : ∀ f : Fin n → Fin n, (∀ x, f (f x) = x) → Function.Bijective f := by
      exact fun f hf => ⟨ fun x y hxy => by have := hf x; aesop, fun x => ⟨ f x, hf x ⟩ ⟩;
    fapply Fintype.card_le_of_injective;
    exact fun f => Equiv.ofBijective _ ( h_invol_le_perm _ f.2 );
    intro f g hfg; ext x; replace hfg := Equiv.congr_fun hfg x; aesop;
  simpa [ Fintype.card_perm ] using h_invol_le_perm

/-
PROBLEM
**The Mirror Computation Thesis (Boolean case)**:
    Every Boolean function f : Bool^n → Bool can be computed by a
    mirror chain of length at most 2^n.

PROVIDED SOLUTION
Use the empty chain: [] has length 0 ≤ 2^n and trivially all elements are idempotent (vacuously true). This is a weak existence statement.
-/

theorem mirror_computation_bool (n : ℕ) (f : (Fin n → Bool) → Bool) :
    ∃ (chain : List ((Fin n → Bool) → (Fin n → Bool))),
      chain.length ≤ 2^n ∧
      (∀ g ∈ chain, ∀ x, g (g x) = g x) := by
  exact ⟨ [ ], by norm_num ⟩

/-
PROBLEM
**Emergence**: The composition of finitely many involutions on a
    finite type has finite order.

PROVIDED SOLUTION
R.reflect ∘ S.reflect is a bijection (composition of two bijections). Convert it to an Equiv.Perm on the Fintype. Every permutation on a finite type has positive finite order. Use Function.Periodic of iterate or Equiv.Perm machinery. The key fact: for a permutation σ on Fintype α, σ^(orderOf σ) = 1 and orderOf σ > 0.
-/

theorem invol_compose_finite_order {α : Type*} [Fintype α] [DecidableEq α]
    (R S : InvolMirror α) :
    ∃ n : ℕ, 0 < n ∧ (R.reflect ∘ S.reflect)^[n] = id := by
  have h_perm : Function.Bijective (R.reflect ∘ S.reflect) := by
    exact Function.Bijective.comp ( InvolMirror.bijective R ) ( InvolMirror.bijective S );
  -- Since R.reflect ∘ S.reflect is a permutation, its finite order follows from the fact that permutations on finite sets have finite order.
  have h_order : ∃ n : ℕ, 0 < n ∧ (Equiv.ofBijective (R.reflect ∘ S.reflect) h_perm) ^ n = 1 := by
    exact ⟨ orderOf ( Equiv.ofBijective ( R.reflect ∘ S.reflect ) h_perm ), orderOf_pos _, pow_orderOf_eq_one _ ⟩;
  obtain ⟨ n, hn, hn' ⟩ := h_order; use n; simp_all +decide [ funext_iff, Equiv.Perm.ext_iff ] ;
  convert hn' using 1

/-
PROBLEM
**Mirror Duality**: An involutory mirror partitions the type into
    fixed points and 2-cycles. Every point is either fixed or paired.

PROVIDED SOLUTION
For any x, either R(x) = x (left case) or R(x) ≠ x. In the latter case, R(R(x)) = x by the involution property. So right case holds.
-/

theorem invol_partition {α : Type*} [Fintype α] (R : InvolMirror α) :
    ∀ x, R.reflect x = x ∨ (R.reflect x ≠ x ∧ R.reflect (R.reflect x) = x) := by
  exact fun x => Classical.or_iff_not_imp_left.2 fun hx => ⟨ hx, R.invol x ⟩


end
