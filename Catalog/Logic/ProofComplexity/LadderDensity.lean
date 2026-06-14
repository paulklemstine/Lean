import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder
import Catalog.Logic.ProofComplexity.SimulationDegrees
import Catalog.Logic.ProofComplexity.DegreeLattice

/-! # Density along the whole height ladder of p-degrees

This file is a **fifth-cycle** companion to the order-type development.  `OrderType.lean`
exhibited a *single* density witness `interSys`, strictly between `linSystem` and
`fibSystem`.  `DegreeLattice.lean` built the infinite height ladder `powSystem k`
(size `2 ^ (n ^ k)`) with `powSystem k < powSystem (k+1)` for `k ≥ 1`.

Here we prove **density at every rung of the ladder simultaneously**: between any two
consecutive ladder degrees there is a strictly intermediate p-degree
(`exists_strictly_between_powSystem`).  The witness `interPowSys k` is the *parity-glued*
size function that runs the upper rate `2 ^ (n ^ (k+1))` on the even indices and the lower
rate `2 ^ (n ^ k)` on the odd indices: super-polynomially above the lower rung (the even
indices keep the faster rate), yet too thin to recover the upper rung (the odd indices fall
back to the slower rate).  This is a *local-to-global* glueing: a degree is assembled from
the two rates prescribed on the two residue classes mod 2.

The engine is the domination characterisation `simulates_sysOfSize_iff` together with the
uniform gap `pow_pow_succ_gap_strong`, an "all-large-`n`" strengthening of
`DegreeLattice.pow_pow_succ_gap` that lets us select a witness of prescribed parity.

-- !-- Lab Notebook -- !--
Hypothesis : The single Fibonacci-vs-linear density witness should generalise to *every*
             consecutive pair `powSystem k < powSystem (k+1)` on the height ladder, via the
             same parity-thinning trick applied to the ladder's exponents.
Result     : Confirmed, `sorry = 0`.  `interPowSys k` lies strictly between `powSystem k`
             and `powSystem (k+1)` for every `k ≥ 1` (`powSystem_lt_interPow`,
             `interPow_lt_powSystem_succ`, `exists_strictly_between_powSystem`).
Insight    : Whereas `DegreeLattice.pow_pow_succ_gap` only produced *one* exponent `n`
             realising the super-polynomial gap, density needs a gap witness of a *chosen
             parity*.  Strengthening to "the gap holds for **all** `n ≥ c + 2`"
             (`pow_pow_succ_gap_strong`) makes the parity free: pick an even or odd witness
             above the threshold as needed.  The clean bound is
             `(2^(n^k)+2)^c ≤ 2^(c·n^k + c) < 2^(n^(k+1))` whenever `n ≥ c + 2`, since then
             `c·n^k + c < n·n^k = n^(k+1)`.
Failure analysis : Reusing `pow_pow_succ_gap` verbatim fails because its witness `n = c + 2`
             has a fixed parity, so it can only refute *one* of the two simulations needed
             to sandwich `interPowSys`.  The all-large-`n` form removes that coupling.
-- !-- Lab Notebook -- !--
-/

set_option maxHeartbeats 1000000

namespace ProofComplexity

/-! ## A uniform (all-large-`n`) super-polynomial gap -/

/-
!-- comment: For `k ≥ 1` the rungs `2^(n^k)` and `2^(n^(k+1))` are super-polynomially
apart for *every* `n ≥ c + 2`, not just one — so a witness of either parity
is available. -- !--

**Uniform ladder gap.**  For `k ≥ 1` and every exponent `c`, the inequality
`(2 ^ (n ^ k) + 2) ^ c < 2 ^ (n ^ (k + 1))` holds for *all* `n ≥ c + 2`.
-/
lemma pow_pow_succ_gap_strong (k : ℕ) (hk : 1 ≤ k) (c : ℕ) :
    ∀ n, c + 2 ≤ n → (2 ^ (n ^ k) + 2) ^ c < 2 ^ (n ^ (k + 1)) := by
  -- Apply the power inequality: $(2^{n^k} + 2)^c \leq 2^{c \cdot (n^k + 1)}$
  have h_pow : ∀ n, c + 2 ≤ n → (2 ^ (n ^ k) + 2) ^ c ≤ 2 ^ (c * (n ^ k + 1)) := by
    intros n hn; rw [ pow_mul' ] ; gcongr;
    rw [ pow_succ' ] ; linarith [ Nat.pow_le_pow_right ( by decide : 1 ≤ 2 ) ( show n ^ k ≥ 1 by exact Nat.one_le_pow _ _ ( by linarith ) ) ];
  refine fun n hn ↦ lt_of_le_of_lt ( h_pow n hn ) ?_;
  gcongr <;> norm_num;
  rw [ pow_succ' ] ; nlinarith [ Nat.pow_le_pow_right ( by linarith : 1 ≤ n ) hk ] ;

/-! ## The parity-glued intermediate system -/

-- !-- comment: Upper rate `2^(n^(k+1))` on even indices, lower rate `2^(n^k)` on odd
--             indices: a degree glued from the two rates on the two residue classes. -- !--
/-- The parity-glued intermediate system: size `2 ^ (n ^ (k+1))` on even `n`, size
`2 ^ (n ^ k)` on odd `n`. -/
def interPowSys (k : ℕ) : ProofSystem.{0, 0} ℕ :=
  sysOfSize (fun n => if Even n then 2 ^ (n ^ (k + 1)) else 2 ^ (n ^ k))

/-! ## `powSystem k < interPowSys k` -/

/-
!-- comment: Lower rung simulates the glued system (its size is everywhere `≥ 2^(n^k)`),
but the glued system cannot be simulated by the lower rung because the even
indices keep the faster rate (uniform gap at an even witness). -- !--

The lower ladder rung is strictly below the glued system: `powSystem k < interPowSys k`
for `k ≥ 1`.
-/
theorem powSystem_lt_interPow (k : ℕ) (hk : 1 ≤ k) :
    powSystem k < interPowSys k := by
  constructor;
  · convert simulates_sysOfSize_iff _ _ |>.2 ⟨ id, polyMono_id, ?_ ⟩;
    intro n; split_ifs <;> simp_all +decide [ Nat.pow_succ ] ;
    rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.pow_succ', Nat.pow_mul ];
    · cases k <;> norm_num at *;
    · exact Nat.one_le_iff_ne_zero.mpr ( by positivity );
  · intro h;
    obtain ⟨ f, hf_mono, hf_bound ⟩ := simulates_sysOfSize_iff _ _ |>.1 h;
    obtain ⟨ c, hc ⟩ := hf_mono.2;
    have := pow_pow_succ_gap_strong k hk c ( 2 * ( c + 2 ) ) ( by linarith );
    grind

/-! ## `interPowSys k < powSystem (k+1)` -/

/-
!-- comment: The glued system simulates the upper rung (its size is everywhere
`≤ 2^(n^(k+1))`), but the upper rung cannot be simulated by the glued system
because the odd indices fall back to the slower rate (uniform gap at an odd
witness). -- !--

The glued system is strictly below the upper ladder rung: `interPowSys k < powSystem
(k+1)` for `k ≥ 1`.
-/
theorem interPow_lt_powSystem_succ (k : ℕ) (hk : 1 ≤ k) :
    interPowSys k < powSystem (k + 1) := by
  refine' lt_of_le_not_ge _ _;
  · refine' simulates_sysOfSize_iff _ _ |>.2 ⟨ _, polyMono_id, fun n => _ ⟩;
    split_ifs <;> [ exact le_rfl; exact pow_le_pow_right₀ ( by decide ) ( Nat.pow_le_pow_right ( Nat.pos_of_ne_zero ( by aesop ) ) ( by linarith ) ) ];
  · -- Suppose for contradiction that `powSystem (k+1) ≤ interPowSys k`.
    by_contra h_contra
    unfold powSystem interPowSys at h_contra;
    obtain ⟨ f, hf_mono, hf_bound ⟩ := simulates_sysOfSize_iff _ _ |>.1 h_contra;
    -- Choose an ODD witness `n := 2 * (c + 2) + 1`. Then `¬ Even n` (so the if-branch is `2^(n^k)`) and `c + 2 ≤ n`.
    obtain ⟨c, hc⟩ : ∃ c, ∀ m, f m + 1 ≤ (m + 2) ^ c := by
      exact hf_mono.2
    set n := 2 * (c + 2) + 1 with hn_def
    have hn_odd : ¬Even n := by
      grind
    have hn_ge : c + 2 ≤ n := by
      grind;
    have := pow_pow_succ_gap_strong k hk c n hn_ge;
    grind

/-! ## Density at every rung -/

-- !-- comment: Sandwiching the two strict steps: a strictly intermediate degree exists
--             between every pair of consecutive ladder rungs. -- !--
/-- **Density along the ladder.**  For every `k ≥ 1` there is a p-degree strictly between
the consecutive ladder rungs `powSystem k` and `powSystem (k+1)`. -/
theorem exists_strictly_between_powSystem (k : ℕ) (hk : 1 ≤ k) :
    ∃ S : ProofSystem.{0, 0} ℕ, powSystem k < S ∧ S < powSystem (k + 1) :=
  ⟨interPowSys k, powSystem_lt_interPow k hk, interPow_lt_powSystem_succ k hk⟩

end ProofComplexity