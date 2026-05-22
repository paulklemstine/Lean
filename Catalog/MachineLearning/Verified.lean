/-
# Erdős–Straus Conjecture: Computational Verification

This file combines the algebraic family theorems with computational search
to verify the conjecture for explicit ranges.
-/
import Speculative.ErdosStraus.Search
import Speculative.ErdosStraus.Families

/-- The coverage condition: n is even, divisible by 3, ≡ 2 mod 3, or ≡ 3 mod 4.
Together these cover all residue classes mod 12 except 1 (density 11/12). -/
def ErdosStrausCovered (n : ℕ) : Bool :=
  n % 2 == 0 || n % 3 == 0 || n % 3 == 2 || n % 4 == 3

/-
The uncovered residue class mod 12 is exactly {1}.
Since n ≡ 5 mod 12 implies n % 3 = 2, which IS covered by the mod-3 family.
-/
theorem uncovered_mod12 (n : ℕ) (hn : 2 ≤ n) :
    ErdosStrausCovered n = false ↔ n % 12 = 1 := by
  unfold ErdosStrausCovered; simp +decide [ Nat.ModEq ] ; omega;

/-- Combined check: use algebraic families first, fall back to smart search. -/
def verifyErdosStraus (n B : ℕ) : Bool :=
  ErdosStrausCovered n || smartSearchErdosStraus n B

/-
The combined verifier is sound.
-/
theorem verifyErdosStraus_sound {n B : ℕ}
    (hn : 2 ≤ n) (h : verifyErdosStraus n B = true) :
    ErdosStrausSolvable n := by
  unfold verifyErdosStraus at h;
  grind +suggestions

/-- Batch verifier: check all n in [2, N]. -/
def verifyRange (N B : ℕ) : Bool :=
  (List.range (N - 1)).all fun i => verifyErdosStraus (i + 2) B

/-
The batch verifier is sound.
-/
theorem verifyRange_sound {N B : ℕ}
    (h : verifyRange N B = true) :
    ∀ n, 2 ≤ n → n ≤ N → ErdosStrausSolvable n := by
  intro n hn hnN
  have h_valid : verifyErdosStraus n B = true := by
    have h_valid : (List.range (N - 1)).all (fun i => verifyErdosStraus (i + 2) B) := by
      exact h;
    rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
    exact h_valid n ( Nat.lt_pred_iff.mpr hnN );
  -- Apply the soundness theorem to conclude that ErdosStrausSolvable n holds.
  apply verifyErdosStraus_sound hn h_valid

/-- **Verified theorem**: Erdős–Straus holds for all n from 2 to 1000.
Verified by combining algebraic families with smart computational search. -/
theorem erdos_straus_verified_upto_1000 :
    ∀ n, 2 ≤ n → n ≤ 1000 → ErdosStrausSolvable n := by
  exact verifyRange_sound (N := 1000) (B := 1000) (by native_decide)