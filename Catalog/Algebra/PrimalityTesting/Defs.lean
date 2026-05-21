import Mathlib

/-!
# Primality Testing Definitions

Core definitions for Miller-Rabin and AKS primality testing formalization.

## Main definitions

* `DecomposeTwos` - Two-adic decomposition: write m = 2^s * d with d odd
* `StrongPseudoprimeBase` - Predicate for Miller-Rabin strong pseudoprime witnesses
* `MRLiars` - The set of Miller-Rabin liars for a given modulus
* `PolynomialCongruenceModXRMinusOne` - AKS polynomial congruence condition

## References

* Rabin, M. O. "Probabilistic algorithm for testing primality." (1980)
* Agrawal, Kayal, Saxena. "PRIMES is in P." (2004)
-/

open Finset Nat

/-! ### Two-adic decomposition -/

/-- Compute the 2-adic valuation of a natural number (number of trailing zeros). -/
def twoAdicVal : ℕ → ℕ
  | 0 => 0
  | n + 1 =>
    if (n + 1) % 2 = 0 then 1 + twoAdicVal ((n + 1) / 2)
    else 0

/-- Remove all factors of 2 from a natural number. -/
def oddPart : ℕ → ℕ
  | 0 => 0
  | n + 1 =>
    if (n + 1) % 2 = 0 then oddPart ((n + 1) / 2)
    else n + 1

/-- Two-adic decomposition: returns (s, d) where m = 2^s * d and d is odd.
    For m = 0, returns (0, 0). -/
def DecomposeTwos (m : ℕ) : ℕ × ℕ :=
  (twoAdicVal m, oddPart m)

/-
The two-adic decomposition satisfies m = 2^s * d.
-/
theorem decomposeTwos_spec (m : ℕ) (hm : 0 < m) :
    m = 2 ^ (DecomposeTwos m).1 * (DecomposeTwos m).2 ∧
    (DecomposeTwos m).2 % 2 = 1 := by
      unfold DecomposeTwos;
      induction' m using Nat.strongRecOn with m ih;
      rcases Nat.even_or_odd' m with ⟨ c, rfl | rfl ⟩ <;> simp +arith +decide at *;
      · unfold twoAdicVal oddPart;
        rcases c with ( _ | _ | c ) <;> simp +arith +decide [ Nat.add_mod, Nat.mul_mod, Nat.pow_succ' ] at *;
        · native_decide +revert;
        · grind;
      · unfold twoAdicVal oddPart; simp +arith +decide;

/-
Existence form of two-adic decomposition.
-/
theorem exists_two_adic_decomposition (m : ℕ) (hm : 0 < m) :
    ∃ s d : ℕ, m = 2 ^ s * d ∧ d % 2 = 1 := by
      exact ⟨ Nat.factorization m 2, m / 2 ^ Nat.factorization m 2, by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ], Nat.mod_two_ne_zero.mp fun hd_even => absurd ( Nat.dvd_of_mod_eq_zero hd_even ) ( Nat.not_dvd_ordCompl ( by norm_num ) ( by aesop ) ) ⟩

/-! ### Miller-Rabin strong pseudoprime definitions -/

/-- A base `a` is a *strong pseudoprime base* for `n` if `a` is coprime to `n` and
    either `a^d ≡ 1 (mod n)` or `a^(d·2^r) ≡ n-1 (mod n)` for some `r < s`,
    where `n - 1 = 2^s · d` with `d` odd. -/
def StrongPseudoprimeBase (n a : ℕ) : Prop :=
  Nat.Coprime a n ∧
  let sd := DecomposeTwos (n - 1)
  let s := sd.1
  let d := sd.2
  (a ^ d ≡ 1 [MOD n]) ∨ ∃ r, r < s ∧ (a ^ (d * 2 ^ r) ≡ n - 1 [MOD n])

/-- Decidable (computable) version of strong pseudoprime base check. -/
def strongPseudoprimeBaseDecide (n a : ℕ) : Bool :=
  Nat.Coprime a n &&
  let sd := DecomposeTwos (n - 1)
  let s := sd.1
  let d := sd.2
  (a ^ d % n == 1 % n) ||
    (List.range s).any fun r => a ^ (d * 2 ^ r) % n == (n - 1) % n

/-- The set of Miller-Rabin liars: bases in {1, ..., n-1} that pass the strong
    pseudoprime test. Uses the decidable version for computability. -/
def MRLiars (n : ℕ) : Finset ℕ :=
  (Finset.range n).filter fun a => 1 ≤ a ∧ strongPseudoprimeBaseDecide n a

/-! ### AKS definitions -/

/-- The multiplicative order of `n` modulo `r`: smallest positive `k` with `n^k ≡ 1 (mod r)`. -/
noncomputable def orderMod (n r : ℕ) : ℕ :=
  if hr : Nat.Coprime n r then
    orderOf (ZMod.unitOfCoprime n hr)
  else 0

/-- The AKS bound: ⌊√(φ(r)) · log₂(n)⌋. -/
noncomputable def bound_AKS (n r : ℕ) : ℕ :=
  Nat.sqrt (Nat.totient r) * (Nat.log 2 n)

/-- AKS polynomial congruence condition:
    `(X + a)^n ≡ X^n + a` in `(ℤ/nℤ)[X]/(X^r - 1)`.

    This is formalized as: when we reduce `(X + C a)^n - (X^n + C a)` modulo
    `X^r - 1` in `(ZMod n)[X]`, we get the zero polynomial. -/
def PolynomialCongruenceModXRMinusOne (n r a : ℕ) : Prop :=
  let poly := (Polynomial.X + Polynomial.C (a : ZMod n)) ^ n -
              (Polynomial.X ^ n + Polynomial.C (a : ZMod n))
  poly %ₘ (Polynomial.X ^ r - 1 : Polynomial (ZMod n)) = 0

/-! ### Modular expression reflection -/

/-- Abstract syntax for modular arithmetic expressions. -/
inductive ModExpr where
  | lit (v : ℕ)
  | var (i : ℕ)
  | add (e₁ e₂ : ModExpr)
  | mul (e₁ e₂ : ModExpr)
  | pow (e : ModExpr) (k : ℕ)
  deriving Repr, DecidableEq

/-- Denotation of a modular expression in `ZMod n`. -/
def denoteModExpr (n : ℕ) [NeZero n] (env : ℕ → ZMod n) : ModExpr → ZMod n
  | .lit v => (v : ZMod n)
  | .var i => env i
  | .add e₁ e₂ => denoteModExpr n env e₁ + denoteModExpr n env e₂
  | .mul e₁ e₂ => denoteModExpr n env e₁ * denoteModExpr n env e₂
  | .pow e k => denoteModExpr n env e ^ k

/-- Normalize a modular expression by evaluating literals. -/
def normModExpr (n : ℕ) : ModExpr → ModExpr
  | .lit v => .lit (v % n)
  | .var i => .var i
  | .add e₁ e₂ =>
    match normModExpr n e₁, normModExpr n e₂ with
    | .lit a, .lit b => .lit ((a + b) % n)
    | e₁', e₂' => .add e₁' e₂'
  | .mul e₁ e₂ =>
    match normModExpr n e₁, normModExpr n e₂ with
    | .lit a, .lit b => .lit ((a * b) % n)
    | e₁', e₂' => .mul e₁' e₂'
  | .pow e k =>
    match normModExpr n e with
    | .lit a => .lit (a ^ k % n)
    | e' => .pow e' k

/-
Soundness of modular expression normalization.
-/
theorem eval_mod_norm_sound (n : ℕ) [NeZero n] (e : ModExpr) (env : ℕ → ZMod n) :
    denoteModExpr n env (normModExpr n e) = denoteModExpr n env e := by
      induction' e with _ _ ih1 ih2 _ ih3;
      · simp +decide [ normModExpr, denoteModExpr ];
      · rfl;
      · -- By definition of `normModExpr`, we know that `normModExpr n (ih1.add ih2)` is either a literal or an addition of two normalized expressions.
        by_cases h : ∃ a b : ℕ, normModExpr n ih1 = ModExpr.lit a ∧ normModExpr n ih2 = ModExpr.lit b;
        · obtain ⟨ a, b, ha, hb ⟩ := h;
          -- By definition of `normModExpr`, we know that `normModExpr n (ih1.add ih2)` is either a literal or an addition of two normalized expressions. Since both `normModExpr n ih1` and `normModExpr n ih2` are literals, their sum is also a literal.
          have h_sum : normModExpr n (ih1.add ih2) = ModExpr.lit ((a + b) % n) := by
            exact Eq.symm ( by rw [ show normModExpr n ( ih1.add ih2 ) = match normModExpr n ih1, normModExpr n ih2 with | ModExpr.lit a, ModExpr.lit b => ModExpr.lit ( ( a + b ) % n ) | e₁', e₂' => e₁'.add e₂' from rfl ] ; aesop );
          simp_all +decide [ denoteModExpr ];
        · rw [ show normModExpr n ( ih1.add ih2 ) = ModExpr.add ( normModExpr n ih1 ) ( normModExpr n ih2 ) from ?_ ];
          · exact congr_arg₂ ( · + · ) ‹denoteModExpr n env ( normModExpr n ih1 ) = denoteModExpr n env ih1› ‹denoteModExpr n env ( normModExpr n ih2 ) = denoteModExpr n env ih2›;
          · rw [normModExpr];
            cases h1 : normModExpr n ih1 <;> cases h2 : normModExpr n ih2 <;> aesop;
      · rename_i e₁ e₂ ih₁ ih₂;
        by_cases h₁ : ∃ v₁, normModExpr n e₁ = .lit v₁;
        · by_cases h₂ : ∃ v₂, normModExpr n e₂ = ModExpr.lit v₂;
          · obtain ⟨ v₁, hv₁ ⟩ := h₁; obtain ⟨ v₂, hv₂ ⟩ := h₂; simp_all +decide [ denoteModExpr ] ;
            -- By definition of `normModExpr`, we know that `normModExpr n (e₁.mul e₂)` is either `ModExpr.lit ((v₁ * v₂) % n)` or `ModExpr.mul (normModExpr n e₁) (normModExpr n e₂)`.
            have h_norm_mul : normModExpr n (e₁.mul e₂) = ModExpr.lit ((v₁ * v₂) % n) := by
              exact Eq.symm ( by rw [ show normModExpr n ( e₁.mul e₂ ) = match normModExpr n e₁, normModExpr n e₂ with | .lit a, .lit b => .lit ( ( a * b ) % n ) | e₁', e₂' => .mul e₁' e₂' from rfl ] ; aesop );
            simp +decide [ h_norm_mul, ← ih₁, ← ih₂, denoteModExpr ];
          · cases h₁ ; simp_all +decide [ normModExpr ];
            convert congr_arg₂ ( · * · ) ih₁ ih₂ using 1;
        · rw [ show normModExpr n ( e₁.mul e₂ ) = ( normModExpr n e₁ ).mul ( normModExpr n e₂ ) from ?_ ];
          · exact congr_arg₂ ( · * · ) ih₁ ih₂;
          · cases h : normModExpr n e₁ <;> cases h' : normModExpr n e₂ <;> simp_all +decide [ normModExpr ];
      · rename_i e k ih;
        by_cases h : ∃ a : ℕ, normModExpr n e = .lit a;
        · obtain ⟨ a, ha ⟩ := h;
          unfold normModExpr; simp +decide [ ha ] ;
          simp_all +decide [ denoteModExpr ];
        · -- Since `normModExpr n e` is not a literal, it must be a power of some expression.
          have h_pow : normModExpr n (e.pow k) = .pow (normModExpr n e) k := by
            exact Eq.symm ( by rw [ show normModExpr n ( e.pow k ) = match normModExpr n e with | .lit a => .lit ( a ^ k % n ) | e' => .pow e' k from rfl ] ; aesop );
          exact h_pow.symm ▸ by exact congr_arg ( · ^ k ) ih;