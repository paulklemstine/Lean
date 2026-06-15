import Mathlib

/-! # The abstract simulation preorder of proof systems, and a Fibonacci separation bridge

This file formalizes the order-theoretic core of the **Cook–Reckhow program** in proof
complexity: the *p-simulation preorder* on abstract proof systems, together with a
cross-domain bridge to the catalog's Fibonacci / entry-point number theory
(`Shared.CarmichaelProof`, `Speculative.AutoResearch.CarmichaelComposite`).

A Cook–Reckhow propositional proof system is a surjective, polynomial-time computable map
from "proofs" to the tautologies they certify.  Abstracting away the computability layer,
we model a proof system as a completeness-witnessing map `proves : Proof → Thm` equipped
with a `size : Proof → ℕ`.  System `P` *p-simulates* `Q` when `Q`-proofs can be translated
into `P`-proofs of the same theorem with only a polynomial blow-up in size.

We prove:

* `Simulates` is a **preorder** (`Simulates_refl`, `Simulates_trans`, registered as a
  genuine `Preorder` instance) — the structural heart of the theory.
* p-equivalence `PEquiv` (mutual simulation) is reflexive, symmetric and transitive,
  registered as a `Setoid` (its quotient is the poset of "p-degrees").
* **Bridge to the catalog:** Fibonacci growth is *not* polynomially bounded
  (`not_polyBounded_fib`); hence no monotone polynomial blow-up can dominate it
  (`no_poly_bound_dominates_fib`).
* **Separation theorem:** if a system `Q` proves a family of theorems with linear-size
  proofs while every `P`-proof of the same theorem needs size `≥ F n`, then `P` does *not*
  p-simulate `Q` (`no_simulation_of_fib_hard`).  This is the proof-complexity reading of
  the catalog's Fibonacci lower bounds: super-polynomial (here, Fibonacci) size lower
  bounds are exactly what *separate* proof systems in the simulation preorder.

-- !-- Lab Notebook -- !--
Hypothesis : The Cook–Reckhow simulation relation, stripped of its computability layer
             and parameterized by an abstract polynomial blow-up class, should form a
             genuine preorder, and Fibonacci growth should provide an honest separating
             witness because it is super-polynomial.
Result     : Confirmed, `sorry = 0`.  `Simulates` is reflexive and transitive (a genuine
             `Preorder`), `PEquiv` is an equivalence (`Setoid`), and the separation
             `no_simulation_of_fib_hard` follows from `not_polyBounded_fib`.
Insight    : Transitivity is *exactly* closure of the polynomial blow-up class under
             composition; encoding "polynomially bounded" as `∃ k, f n + 1 ≤ (n+2)^k`
             makes composition closure elementary (the `+2` base dodges the `n = 0`
             corner where a constant bound would otherwise fail).  Monotonicity of the
             blow-up function is the one extra ingredient transitivity needs, so the
             blow-up class is `PolyMono := Monotone ∧ PolyBounded`.
Failure analysis : A first attempt used the bound `f n ≤ (n+1)^k`, which cannot dominate a
             constant `> 1` at `n = 0` and so is *not* closed under composition.  Shifting
             to `f n + 1 ≤ (n+2)^k` repairs this since `2 ≤ n+2` always.
-- !-- Lab Notebook -- !--
-/

namespace ProofComplexity

/-! ## The polynomial blow-up class -/

-- !-- comment: "Polynomially bounded" via a single exponent `k`; the `+2` base makes the
--             class closed under composition with no `n = 0` corner case. -- !--
/-- A function `ℕ → ℕ` is *polynomially bounded* if `f n + 1 ≤ (n+2)^k` for some `k`. -/
def PolyBounded (f : ℕ → ℕ) : Prop := ∃ k : ℕ, ∀ n, f n + 1 ≤ (n + 2) ^ k

/-- The blow-up functions used by simulations: monotone **and** polynomially bounded.
Monotonicity is what lets transitivity chain two size bounds. -/
def PolyMono (f : ℕ → ℕ) : Prop := Monotone f ∧ PolyBounded f

lemma polyBounded_id : PolyBounded (fun n => n) := by
  refine ⟨1, fun n => ?_⟩
  simp only [pow_one]; omega

-- !-- comment: composition closure — the algebraic engine behind transitivity. -- !--
lemma polyBounded_comp {f g : ℕ → ℕ} (hf : PolyBounded f) (hg : PolyBounded g) :
    PolyBounded (fun n => f (g n)) := by
  obtain ⟨a, ha⟩ := hf
  obtain ⟨b, hb⟩ := hg
  refine ⟨a * (b + 1), fun n => ?_⟩
  -- `f (g n) + 1 ≤ (g n + 2)^a` and `g n + 2 ≤ (n+2)^(b+1)`.
  have h1 : f (g n) + 1 ≤ (g n + 2) ^ a := ha (g n)
  have hbpos : 1 ≤ (n + 2) ^ b := Nat.one_le_pow _ _ (by omega)
  have h2 : g n + 2 ≤ (n + 2) ^ (b + 1) := by
    have hbn := hb n
    have hle : g n + 2 ≤ (n + 2) ^ b + 1 := by omega
    calc g n + 2 ≤ (n + 2) ^ b + 1 := hle
      _ ≤ (n + 2) ^ b + (n + 2) ^ b := by omega
      _ = 2 * (n + 2) ^ b := by ring
      _ ≤ (n + 2) * (n + 2) ^ b := Nat.mul_le_mul_right _ (by omega)
      _ = (n + 2) ^ (b + 1) := by ring
  calc f (g n) + 1 ≤ (g n + 2) ^ a := h1
    _ ≤ ((n + 2) ^ (b + 1)) ^ a := Nat.pow_le_pow_left h2 a
    _ = (n + 2) ^ (a * (b + 1)) := by rw [← pow_mul, Nat.mul_comm]

lemma polyMono_id : PolyMono (fun n => n) := ⟨monotone_id, polyBounded_id⟩

lemma polyMono_comp {f g : ℕ → ℕ} (hf : PolyMono f) (hg : PolyMono g) :
    PolyMono (fun n => f (g n)) :=
  ⟨hf.1.comp hg.1, polyBounded_comp hf.2 hg.2⟩

/-! ## Abstract proof systems and the simulation preorder -/

universe u v

/-- An abstract (Cook–Reckhow) proof system for theorems of type `Thm`: a completeness
witness `proves` (every theorem is provable) together with a notion of proof `size`. -/
structure ProofSystem (Thm : Type u) : Type (max u (v + 1)) where
  /-- The type of proofs. -/
  Proof : Type v
  /-- The theorem certified by a proof. -/
  proves : Proof → Thm
  /-- The size (length) of a proof. -/
  size : Proof → ℕ
  /-- Completeness: every theorem has a proof. -/
  complete : Function.Surjective proves

variable {Thm : Type u}

-- !-- comment: `P` p-simulates `Q`: a polynomial-blow-up translation of `Q`-proofs into
--             `P`-proofs of the same theorem. -- !--
/-- `Simulates P Q` (`P` p-simulates `Q`): there is a monotone polynomially-bounded
blow-up `f` so that every `Q`-proof `q` has a `P`-proof of the *same* theorem with size
`≤ f (size q)`. -/
def Simulates (P Q : ProofSystem.{u, v} Thm) : Prop :=
  ∃ f : ℕ → ℕ, PolyMono f ∧
    ∀ q : Q.Proof, ∃ p : P.Proof, P.proves p = Q.proves q ∧ P.size p ≤ f (Q.size q)

/-- Reflexivity: every system p-simulates itself (identity blow-up). -/
theorem Simulates_refl (P : ProofSystem.{u, v} Thm) : Simulates P P :=
  ⟨fun n => n, polyMono_id, fun q => ⟨q, rfl, le_refl _⟩⟩

/-- Transitivity: simulation composes — the composite blow-up is the composition of the
two blow-ups, which is again monotone and polynomially bounded. -/
theorem Simulates_trans {P Q R : ProofSystem.{u, v} Thm}
    (hPQ : Simulates P Q) (hQR : Simulates Q R) : Simulates P R := by
  obtain ⟨f, hf, hfsim⟩ := hPQ
  obtain ⟨g, hg, hgsim⟩ := hQR
  refine ⟨fun n => f (g n), polyMono_comp hf hg, fun r => ?_⟩
  obtain ⟨q, hq_proves, hq_size⟩ := hgsim r
  obtain ⟨p, hp_proves, hp_size⟩ := hfsim q
  refine ⟨p, by rw [hp_proves, hq_proves], ?_⟩
  calc P.size p ≤ f (Q.size q) := hp_size
    _ ≤ f (g (R.size r)) := hf.1 hq_size

-- !-- comment: register the simulation relation as an honest `Preorder`. -- !--
/-- The simulation **preorder** on proof systems: `P ≤ Q ↔ P` p-simulates `Q`. -/
instance simulationPreorder : Preorder (ProofSystem.{u, v} Thm) where
  le := Simulates
  le_refl := Simulates_refl
  le_trans := fun _ _ _ => Simulates_trans

/-! ## p-equivalence (mutual simulation) -/

/-- `PEquiv P Q`: the two systems p-simulate each other.  This is the symmetric core of
the simulation preorder — its equivalence classes are the "p-degrees". -/
def PEquiv (P Q : ProofSystem.{u, v} Thm) : Prop := Simulates P Q ∧ Simulates Q P

theorem PEquiv_refl (P : ProofSystem.{u, v} Thm) : PEquiv P P :=
  ⟨Simulates_refl P, Simulates_refl P⟩

theorem PEquiv_symm {P Q : ProofSystem.{u, v} Thm} (h : PEquiv P Q) : PEquiv Q P :=
  ⟨h.2, h.1⟩

theorem PEquiv_trans {P Q R : ProofSystem.{u, v} Thm}
    (hPQ : PEquiv P Q) (hQR : PEquiv Q R) : PEquiv P R :=
  ⟨Simulates_trans hPQ.1 hQR.1, Simulates_trans hQR.2 hPQ.2⟩

-- !-- comment: p-equivalence is an equivalence relation; its quotient = the p-degrees. -- !--
/-- p-equivalence as a `Setoid`; the quotient by it is the poset of p-degrees. -/
instance pEquivSetoid : Setoid (ProofSystem.{u, v} Thm) where
  r := PEquiv
  iseqv := ⟨PEquiv_refl, fun {_ _} => PEquiv_symm, fun {_ _ _} => PEquiv_trans⟩

/-! ## Bridge: Fibonacci growth is super-polynomial -/

-- !-- comment: An honest exponential lower bound `2^n ≤ F(2n+1)` from `F(m+2) ≥ 2 F(m)`. -- !--
/-- A clean exponential lower bound for Fibonacci numbers: `2^n ≤ F(2n+1)`. -/
lemma two_pow_le_fib (n : ℕ) : 2 ^ n ≤ Nat.fib (2 * n + 1) := by
  induction n with
  | zero => simp
  | succ m ih =>
      have he : 2 * (m + 1) + 1 = (2 * m + 1) + 2 := by ring
      have hmono : Nat.fib (2 * m + 1) ≤ Nat.fib (2 * m + 1 + 1) := Nat.fib_le_fib_succ
      have hge : 2 * Nat.fib (2 * m + 1) ≤ Nat.fib (2 * (m + 1) + 1) := by
        rw [he, Nat.fib_add_two]; omega
      calc 2 ^ (m + 1) = 2 * 2 ^ m := by ring
        _ ≤ 2 * Nat.fib (2 * m + 1) := Nat.mul_le_mul_left 2 ih
        _ ≤ Nat.fib (2 * (m + 1) + 1) := hge

/-
!-- comment: `F` outgrows every polynomial; reduces to "exp beats poly" via the
`2^n ≤ F(2n+1)` bound and `isLittleO_pow_const_const_pow_of_one_lt`. -- !--

**Fibonacci growth is not polynomially bounded.**
-/
theorem not_polyBounded_fib : ¬ PolyBounded Nat.fib := by
  by_contra h_poly_bounded;
  -- Apply the `isLittleO_pow_const_const_pow_of_one_lt` lemma to obtain a contradiction.
  have h_contradiction : ∃ m : ℕ, (2 * m + 3 : ℝ) ^ (Classical.choose h_poly_bounded) < 2 ^ m := by
    have h_contradiction : Filter.Tendsto (fun m : ℕ => ((2 * m + 3 : ℝ) ^ (Classical.choose h_poly_bounded)) / (2 ^ m)) Filter.atTop (nhds 0) := by
      have h_exp_growth : Filter.Tendsto (fun m : ℕ => (m : ℝ) ^ (Classical.choose h_poly_bounded) / 2 ^ m) Filter.atTop (nhds 0) := by
        convert ( isLittleO_pow_const_const_pow_of_one_lt ( Classical.choose h_poly_bounded ) ( by norm_num : ( 1 : ℝ ) < 2 ) ) |> fun h => h.tendsto_div_nhds_zero using 1;
      -- We can factor out $2^m$ from the numerator and denominator.
      suffices h_factor : Filter.Tendsto (fun m : ℕ => ((2 + 3 / (m : ℝ)) ^ (Classical.choose h_poly_bounded)) * ((m : ℝ) ^ (Classical.choose h_poly_bounded) / 2 ^ m)) Filter.atTop (nhds 0) by
        refine h_factor.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with m hm using by rw [ show ( 2 * m + 3 : ℝ ) = ( 2 + 3 / m ) * m by rw [ add_mul, div_mul_cancel₀ _ ( by positivity ) ] ] ; rw [ mul_pow ] ; ring );
      simpa using Filter.Tendsto.mul ( Filter.Tendsto.pow ( tendsto_const_nhds.add ( tendsto_const_nhds.mul tendsto_inv_atTop_nhds_zero_nat ) ) _ ) h_exp_growth;
    exact Filter.Eventually.exists ( h_contradiction.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ m, hm ⟩ => ⟨ m, by rw [ div_lt_one ( by positivity ) ] at hm; exact_mod_cast hm ⟩;
  obtain ⟨ m, hm ⟩ := h_contradiction;
  have := Classical.choose_spec h_poly_bounded ( 2 * m + 1 ) ; norm_cast at * ; simp_all +decide ;
  linarith! [ two_pow_le_fib m ]

-- !-- comment: Domination corollary — no monotone polynomial blow-up can stay above `F`. -- !--
/-- No polynomially-bounded function can dominate Fibonacci growth pointwise. -/
theorem no_poly_bound_dominates_fib {f : ℕ → ℕ}
    (hdom : ∀ n, Nat.fib n ≤ f n) : ¬ PolyBounded f := by
  rintro ⟨k, hk⟩
  exact not_polyBounded_fib ⟨k, fun n => le_trans (by have := hdom n; omega) (hk n)⟩

/-! ## Separation theorem in the simulation preorder -/

-- !-- comment: Fibonacci-size lower bounds separate proof systems: a system needing
--             `F n`-size proofs of theorems that another proves in linear size cannot be
--             p-simulated by it. -- !--
/-- **Separation via Fibonacci lower bounds.**  Suppose `Q` proves a family of theorems
`t n` with proofs of size `≤ n`, but every `P`-proof of `t n` has size `≥ F n`.  Then `P`
does **not** p-simulate `Q`: any simulation blow-up would have to dominate Fibonacci
growth, contradicting `no_poly_bound_dominates_fib`. -/
theorem no_simulation_of_fib_hard {P Q : ProofSystem.{u, v} Thm}
    (t : ℕ → Thm) (q : ℕ → Q.Proof)
    (hq : ∀ n, Q.proves (q n) = t n) (hqs : ∀ n, Q.size (q n) ≤ n)
    (hhard : ∀ n (pf : P.Proof), P.proves pf = t n → Nat.fib n ≤ P.size pf) :
    ¬ Simulates P Q := by
  rintro ⟨f, ⟨hmono, hpb⟩, hsim⟩
  -- Every `t n` then has a `P`-proof of size `≤ f n`, but also `≥ F n`; so `F n ≤ f n`.
  have hdom : ∀ n, Nat.fib n ≤ f n := by
    intro n
    obtain ⟨p, hp_proves, hp_size⟩ := hsim (q n)
    have hp_t : P.proves p = t n := by rw [hp_proves, hq]
    have h1 : Nat.fib n ≤ P.size p := hhard n p hp_t
    have h3 : f (Q.size (q n)) ≤ f n := hmono (hqs n)
    omega
  exact no_poly_bound_dominates_fib hdom hpb

end ProofComplexity