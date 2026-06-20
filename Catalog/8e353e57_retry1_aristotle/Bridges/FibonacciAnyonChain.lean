import Mathlib
import Physics.RandomTensorNetwork.Threshold

/-!
# Fibonacci anyon chains

A length-`n` Fibonacci anyon chain admits a Hilbert space whose dimension equals the
number of *admissible fusion paths*, i.e. the number of binary strings of length `n`
with no two consecutive `1`s.  This count obeys a Fibonacci recurrence and equals
`Nat.fib (n + 2)`.

We collect the basic facts about this dimension:

* `fusionCount_eq_fib`     – the dimension is a Fibonacci number;
* `fusionCount_le_two_pow` – the *sub-qubit area law* `fusionCount n ≤ 2 ^ n`,
  strict for `n ≥ 2`;
* `fib_chain_commensurability` – the gcd of two fusion dimensions is again a fusion
  dimension, via `Nat.fib_gcd`;
* `fib_chain_encodable_iff` – the chain is encodable in a random tensor network of
  bond dimension `φ` (the golden ratio) iff its length is below an explicit threshold.
-/

namespace Bridges.FibonacciAnyonChain

open Physics.RandomTensorNetwork

/-- The number of admissible fusion paths of a length-`n` Fibonacci anyon chain,
i.e. binary strings of length `n` with no two consecutive `1`s.  It satisfies the
Fibonacci recurrence with seeds `1, 2`. -/
def fusionCount : ℕ → ℕ
  | 0 => 1
  | 1 => 2
  | (n + 2) => fusionCount (n + 1) + fusionCount n

@[simp] lemma fusionCount_zero : fusionCount 0 = 1 := rfl
@[simp] lemma fusionCount_one : fusionCount 1 = 2 := rfl

lemma fusionCount_add_two (n : ℕ) :
    fusionCount (n + 2) = fusionCount (n + 1) + fusionCount n := rfl

/-- The fusion-path count is a Fibonacci number: `fusionCount n = fib (n + 2)`. -/
theorem fusionCount_eq_fib (n : ℕ) : fusionCount n = Nat.fib (n + 2) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  rw [ show fusionCount ( n + 2 ) = fusionCount ( n + 1 ) + fusionCount n by rfl, ih _ <| Nat.le_succ _, ih _ <| Nat.le_refl _ ] ; simp +arith +decide [ Nat.fib_add_two ]

/-- **Sub-qubit area law.**  The fusion dimension never exceeds the full qubit
Hilbert-space dimension `2 ^ n`. -/
theorem fusionCount_le_two_pow (n : ℕ) : fusionCount n ≤ 2 ^ n := by
  induction' n using Nat.twoStepInduction with n ih;
  · decide +revert;
  · decide +revert;
  · rw [ pow_succ' ] at * ; rw [ pow_succ' ] at * ; rw [ fusionCount_add_two ] ; linarith

/-- The sub-qubit area law is *strict* for chains of length at least `2`. -/
theorem fusionCount_lt_two_pow (n : ℕ) (hn : 2 ≤ n) : fusionCount n < 2 ^ n := by
  induction' hn with n hn ih;
  · decide +revert;
  · rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ' ];
    rw [ show fusionCount ( n + 3 ) = fusionCount ( n + 2 ) + fusionCount ( n + 1 ) by rfl ] ; linarith [ fusionCount_le_two_pow ( n + 1 ), pow_succ' 2 n ]

/-- **Commensurability of Fibonacci chains.**  The greatest common divisor of two
fusion dimensions is itself a fusion dimension, indexed by the gcd of the shifted
lengths.  This is the chain-level shadow of the catalog identity `Nat.fib_gcd`. -/
theorem fib_chain_commensurability (m n : ℕ)
    (h : 2 ≤ Nat.gcd (m + 2) (n + 2)) :
    Nat.gcd (fusionCount m) (fusionCount n)
      = fusionCount (Nat.gcd (m + 2) (n + 2) - 2) := by
  rw [ fusionCount_eq_fib, fusionCount_eq_fib ];
  rw [ ← Nat.fib_gcd, fusionCount_eq_fib ];
  rw [ Nat.sub_add_cancel h ]

/-- The bond dimension carried by a single Fibonacci anyon: the golden ratio
`φ = (1 + √5) / 2 ≈ 1.618`. -/
noncomputable def fibBondDimension : ℝ := Real.goldenRatio

/-- A length-`n` Fibonacci chain is *encodable* in a random tensor network when its
bond dimension `φ` exceeds the critical bond dimension for that length. -/
def ChainEncodable (n : ℕ) : Prop := critBond n < fibBondDimension

/-- The explicit critical chain length: chains of length `< 7` are encodable. -/
def N_critical : ℕ := 7

/-- Concrete small-length verification: a length-`6` chain is encodable. -/
lemma chainEncodable_six : ChainEncodable 6 := by
  unfold ChainEncodable;
  unfold fibBondDimension;
  unfold critBond; ring_nf; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ;

/-- Concrete small-length verification: a length-`7` chain is **not** encodable. -/
lemma not_chainEncodable_seven : ¬ ChainEncodable 7 := by
  unfold ChainEncodable;
  unfold critBond fibBondDimension; norm_num;
  ring_nf; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ;

/-- **Encodability threshold.**  A length-`n` Fibonacci chain (bond dimension `φ`) is
encodable in a random tensor network iff its length lies below the explicit critical
length `N_critical = 7`. -/
theorem fib_chain_encodable_iff (n : ℕ) : ChainEncodable n ↔ n < N_critical := by
  rw [ChainEncodable];
  unfold fibBondDimension critBond;
  constructor <;> intro hn <;> rw [ ← @Nat.cast_lt ℝ ] at * <;> ring_nf at * <;> norm_num at *;
  · exact_mod_cast ( by nlinarith [ Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] : ( n : ℝ ) < 7 );
  · nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ), show ( n : ℝ ) ≤ 6 by norm_cast; exact Nat.le_of_lt_succ hn ]

/-- Concrete small-`n` verification of the Fibonacci recurrence values and the
sub-qubit area law, checked numerically with `decide`/`norm_num`. -/
example : True := by
  have h0 : fusionCount 0 = 1 := by decide
  have h1 : fusionCount 1 = 2 := by decide
  have h2 : fusionCount 2 = 3 := by decide
  have h3 : fusionCount 3 = 5 := by decide
  have h4 : fusionCount 4 = 8 := by decide
  have h5 : fusionCount 5 = 13 := by decide
  -- strict sub-qubit area law for n = 5
  have hlt : fusionCount 5 < 2 ^ 5 := by rw [h5]; norm_num
  -- agreement with Fibonacci numbers for n = 5
  have hfib : fusionCount 5 = Nat.fib 7 := by rw [h5]; norm_num [Nat.fib]
  -- the critical length is 7
  have hcrit : N_critical = 7 := by norm_num [N_critical]
  trivial

end Bridges.FibonacciAnyonChain